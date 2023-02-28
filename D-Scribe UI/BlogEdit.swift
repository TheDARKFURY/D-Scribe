import SwiftUI

struct BlogEditorView: View {
    @EnvironmentObject private var viewModel: MyBlogsVM
@Environment(\.dismiss) private var dismissAction

@State private var blogTitle = ""
@State private var blogBody = ""

private var canSaveblog: Bool { !blogTitle.isEmpty && !blogBody.isEmpty}

private var saveButton: some View {
    Button("Save") {
        viewModel.createblog(title: blogTitle, body: blogBody)
        dismissAction()
    }
    .opacity(canSaveblog ? 1 : 0.5)
    .disabled(!canSaveblog)
}

var body: some View {
    NavigationView {
        VStack {
            VStack {
                TextField("Title", text: $blogTitle)
                    .foregroundColor(.black)
                    .font(.body.weight(.bold))
                    .accentColor(.black)
                    .padding(.vertical, 7)
                
                TextField("Body", text: $blogBody)
                    .foregroundColor(.black)
                    .accentColor(.black)
                    .padding(.vertical, 7)
            }
            .padding(.horizontal)
            .background(UI.dellow.opacity(0.5))
            .cornerRadius(10)
            
            Spacer()
        }
        .padding()
        .navigationTitle("New blog")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: saveButton)
    }
    .tint(UI.dellow)
}
}

struct blogEditorView_Previews: PreviewProvider {
static var previews: some View {
blogEditorView()
.preferredColorScheme(.dark)
.environmentObject(MyblogsVM())
}
}