import SwiftUI

struct AccountLoginView: View {
@StateObject private var viewModel = AccountLoginViewModel()

var body: some View {
    VStack {
        Button {
            viewModel.authenticateUser()
        } label: {
            Text("Be a Scriborrr\n by Authenticating\nyour Blocto Wallet")
                    .font(.title)
                    .foregroundColor(UI.dellow)
        }
    }
}

}

struct AccountLoginView_Previews: PreviewProvider {
static var previews: some View {
AccountLoginView()
.preferredColorScheme(.dark)
}
}