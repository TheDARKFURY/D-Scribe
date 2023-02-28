import Foundation
import FCL
import Combine

final class AccountLoginViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()

func authenticateUser() {
    fcl
        .authenticate()
        .receive(on: DispatchQueue.main)
        .sink { completion in
            print(completion)
        } receiveValue: { response in
            print(response)
        }
        .store(in: &cancellables)
}
}