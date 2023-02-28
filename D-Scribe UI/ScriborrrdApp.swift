import FCL
import SwiftUI
import Combine

enum UI {
    static let dellow = Color(red: 0.6, green: 0.4, blue: 0.2)
}

@main
struct ScriborrrdApp: App {
    @State private var currentUser: User?
    
    init() {
        fcl.config(appName: "D-Scribe",
                   appIcon: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSDoiPkaduLjZwCDaUhH2kHFmKZC6EimkX9vf7WbKPZCA&s",
                   walletNode: "https://fcl-discovery.onflow.org/testnet/authn",
                   accessNode: "https://access-testnet.onflow.org",
                   env: "testnet",
                   scope: "email",
                   authn: "https://flow-wallet-testnet.blocto.app/api/flow/authn")
        
        let dellowColor = UIColor(cgColor: UI.dellow.cgColor ?? UIColor.green.cgColor) 
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: dellowColor]
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: dellowColor]
    }
    
    var body: some Scene {
        WindowGroup {
            VStack {
                if currentUser != nil {
                    MyBlogsView(vm: MyBlogsVM())
                } else {
                    LoginView()
                }
            }
            .preferredColorScheme(.dark)
            .onReceive(fcl.$currentUser) { user in
                currentUser = user
            }
        }
    }
}
