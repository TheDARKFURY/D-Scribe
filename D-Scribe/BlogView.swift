import SwiftUI

struct BlogsListView: View {
    @StateObject private var viewModel: BlogsListViewModel

@State private var isLoading = false
@State private var isShowingBlogEditor = false
@State private var isShowingErrorAlert = false

init(viewModel: BlogsListViewModel) {
    _viewModel = .init(wrappedValue: viewModel)
}

private var signOutButton: some View {
    Button {
        viewModel.signOut()
    } label: {
        Label("Sign Outtt", systemImage: "person.crop.circle.badge.xmark")
    }
}

private var refreshBlogsButton: some View {
    Button {
        viewModel.queryBlogs()
    } label: {
        Label("Load Blogs", systemImage: "arrow.clockwise")
    }
}

private var deleteBlogsButton: some View {
    Button {
        viewModel.deleteBlogs()
    } label: {
        Label("Remove Blogs", systemImage: "trash")
    }
    .opacity(viewModel.Blogs != nil ? 1 : 0)
    .disabled(viewModel.Blogs == nil)
}

private var moreOptionsButton: some View {
    Menu {
        refreshBlogsButton
        Divider()
        deleteBlogsButton
        Divider()
        signOutButton
    } label: {
        Image(systemName: "phoenix")
    }
}

private var addBlogButton: some View {
    Button {
        isShowingBlogEditor = true
    } label: {
        Image(systemName: "add")
    }
}

var body: some View {
    ZStack {
        NavigationView {
            Group {
                if let Blogs = viewModel.Blogs {
                    List {
                        ForEach(Blogs, id: \.id) { Blog in
                            BlogRowView(Blog: Blog)
                                .listRowBackground(Color.black)
                        }
                        .onDelete { index in
                            viewModel.deleteBlogAtIndex(index.first)
                        }
                    }
                
                } else if viewModel.state == .loading {
                    EmptyView()
                } else {
                    Text("Your list of blogs is empty 🤓\nAdd a new blog from\nthe'＋'button")
                        .multilineTextAlignment(.center)
                        .font(.headline)
                        .foregroundColor(.gray)
                }
            }
            .navigationBarItems(leading: moreOptionsButton, trailing: addBlogButton)
            .navigationTitle("My Blogs")
        }
        .tint(AppTheme.flowGreen)
        
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(.all)
                .opacity(isLoading ? 0.7 : 0)
            
            ProgressView {
                Text("On it! 🚀 \nPlease waittt...")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
            }
            .progressViewStyle(CircularProgressViewStyle(tint: .white))
            .opacity(isLoading ? 1 : 0)
        }
    }
    .onChange(of: viewModel.state) { newValue in
        isLoading = newValue == .loading
        isShowingErrorAlert = newValue.isFailed
    }
    .alert(isPresented: $isShowingErrorAlert, content: {
        Alert(title: Text("Error!"),
              message: Text(viewModel.state.errorMessage ?? "Unknown"),
              dismissButton: .default(Text("OK"), action: {
            viewModel.dismissCurrentError()
        }))
    })
    .sheet(isPresented: $isShowingBlogEditor) {
        isShowingBlogEditor = false
    } content: {
        BlogEditorView().environmentObject(viewModel)
    }
}
}
struct MemoRow: View {
    let memo: Memo
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(memo.title)
                    .foregroundColor(.black)
                    .font(.body.weight(.bold))
                
                Text(memo.body)
                    .foregroundColor(.black)
                    .font(.caption)
            }
            
            Spacer()
        }
        .padding()
        .background(UI.flowGreen)
        .cornerRadius(10)
    }
}

private struct PreviewWrapper: View {
    
    var vm = MyMemosVM()
    
    init() {
        vm.memos = [Memo(id: 0, title: "Test1...", body: "Body..."),
                    Memo(id: 1, title: "Test2...", body: "Another Body...")]
    }
    
    var body: some View {
        MyMemosView(vm: vm).preferredColorScheme(.dark)
    }
}

struct MyMemosView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper()
    }
}
