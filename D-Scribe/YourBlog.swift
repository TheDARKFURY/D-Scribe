import Combine
import FCL
import Flow
import Foundation

enum LoadingState: Equatable {
    case idle
    case loading
    case didFail(error: String)
    
    var isFailed: Bool {
        guard case .didFail = self else { return false }
        return true
    }
    
    var errorMessage: String? {
        guard case let .didFail(error) = self else { return nil }
        return error
    }
}

final class MyblogsVM: ObservableObject {
    
    @Published private(set) var state = LoadingState.idle
    @Published var blogs: [blog]?
    
    private let blogspaceManagerAddress = Blocto.wallet
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        defer {
            queryblogs()
        }
    }
    
    func createblog(title: String, body: String) {
        guard fcl.currentUser?.addr != nil else { return }
        
        state = .loading
        
        fcl.mutate {
            cadence {
                 """
                 import blogspaceManagerV1 from \(blogspaceManagerAddress)
                 
                 transaction {
                     prepare(acct: AuthAccount) {
                         var blogspace = acct.borrow<&blogspaceManagerV1.blogspace>(from: /storage/blogspaceV1)

                         if blogspace == nil { // Create it and make it public
                             acct.save(<- blogspaceManagerV1.createblogspace(), to: /storage/blogspaceV1)
                             acct.link<&blogspaceManagerV1.blogspace>(/public/PublicblogspaceV1, target: /storage/blogspaceV1)
                         }
                 
                         var theblogspace = acct.borrow<&blogspaceManagerV1.blogspace>(from: /storage/blogspaceV1)
                         theblogspace?.addblog(title: "\(title)", body: "\(body)")
                     }
                 }
                 """
            }
            
            gasLimit {
                1000
            }
        }
        .receive(on: DispatchQueue.main)
        .sink { completion in
            if case let .failure(error) = completion {
                self.state = .didFail(error: error.localizedDescription)
            }
        } receiveValue: { [weak self] transactionId in
            guard let self = self else { return }
            
            self.waitForSealedTransaction(transactionId) {
                self.queryblogs()
            }
        }
        .store(in: &cancellables)
    }
    
    func deleteblog(atIndex index: Int?) {
        guard fcl.currentUser?.addr != nil, let index = index, let idToDelete = blogs?[index].id else { return }
                
        state = .loading
        
        fcl.mutate {
            cadence {
                 """
                 import blogspaceManagerV1 from \(blogspaceManagerAddress)
                 
                 transaction {
                     prepare(acct: AuthAccount) {
                            let blogspace = acct.borrow<&blogspaceManagerV1.blogspace>(from: /storage/blogspaceV1)
                            blogspace?.deleteblog(blogID: \(idToDelete))
                     }
                 }
                 """
            }
            
            gasLimit {
                1000
            }
        }
        .receive(on: DispatchQueue.main)
        .sink { completion in
            if case let .failure(error) = completion {
                self.state = .didFail(error: error.localizedDescription)
            }
        } receiveValue: { [weak self] transactionId in
            guard let self = self else { return }
            
            self.waitForSealedTransaction(transactionId) {
                self.queryblogs()
            }
        }
        .store(in: &cancellables)
    }
        
    func deleteblogspace() {
        guard fcl.currentUser?.addr != nil else { return }
        
        state = .loading
        
        fcl.mutate {
            cadence {
                 """
                 import blogspaceManagerV1 from \(blogspaceManagerAddress)
                 
                 transaction {
                     prepare(acct: AuthAccount) {
                         var blogspace <- acct.load<@blogspaceManagerV1.blogspace>(from: /storage/blogspaceV1)!
                         blogspaceManagerV1.deleteblogspace(blogspace: <- blogspace)
                     }
                 }
                 """
            }
            
            gasLimit {
                1000
            }
        }
        .receive(on: DispatchQueue.main)
        .sink { completion in
            if case let .failure(error) = completion {
                self.state = .didFail(error: error.localizedDescription)
            }
        } receiveValue: { [weak self] transactionId in
            guard let self = self else { return }
                        
            self.waitForSealedTransaction(transactionId) {
                self.blogs = nil
                self.state = .idle
            }
        }
        .store(in: &cancellables)
    }
    
    func queryblogs() {
        guard let currentUserAddress = fcl.currentUser?.addr else { return }
        
        state = .loading
        
        fcl.query {
            cadence {
                """
                import blogspaceManagerV1 from \(blogspaceManagerAddress)
                
                pub fun main(): [blogspaceManagerV1.blogDTO]? {
                    let blogspaceAccount = getAccount(0x\(currentUserAddress))
                
                    let blogspaceCapability = blogspaceAccount.getCapability<&blogspaceManagerV1.blogspace>(/public/PublicblogspaceV1)
                    let blogspaceReference = blogspaceCapability.borrow()
                
                    return blogspaceReference == nil ? nil : blogspaceReference?.allblogs()
                }
                """
            }
        }
        .receive(on: DispatchQueue.main)
        .sink { [weak self] completion in
            guard let self = self else { return }
            
            if case let .failure(error) = completion {
                self.state = .didFail(error: error.localizedDescription)
            }
        } receiveValue: { [weak self] result in
            print(result)
            
            guard let self = self else { return }
            guard let valuesArray = result.fields?.value.toOptional()?.value.toArray() else {
                self.blogs = nil
                self.state = .idle
                return
            }
            
            let blogs: [blog] = valuesArray.compactMap {
                guard let blogData = $0.value.toStruct()?.fields else { return nil }
                let id = blogData[0].value.value.toUInt64()
                let title = blogData[1].value.value.toString()
                let body = blogData[2].value.value.toString()
                
                guard let id = id, let title = title, let body = body else { return nil }
                return blog(id: id, title: title, body: body)
            }
            
            self.blogs = blogs
            self.state = .idle
        }.store(in: &cancellables)
    }
    
    func currentErrorDidDismiss() {
        state = .idle
    }
    
    func signOut() {
        fcl.currentUser = nil
    }
    
    private func waitForSealedTransaction(_ transactionId: String, onSuccess: @escaping () -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {.
                let result = try Flow.ID(hex: transactionId).onceSealed().wait()
                DispatchQueue.main.async {
                    print(result)
                    
                    if !result.errorMessage.isEmpty {
                        self.state = .didFail(error: result.errorMessage)
                    } else {
                        onSuccess()
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.state = .didFail(error: error.localizedDescription)
                }
            }
        }
    }
}
