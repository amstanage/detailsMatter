import SwiftUI

struct ContentView: View {
    private var auth = AuthService.shared

    var body: some View {
        Group {
            if auth.isLoading {
                ProgressView("Loading...")
            } else if !auth.isAuthenticated {
                LoginView()
            } else if let user = auth.currentUser {
                if user.isAdmin {
                    AdminDashboardView()
                } else {
                    ClientHomeView(user: user)
                }
            } else {
                ProgressView("Loading...")
            }
        }
    }
}

#Preview("Login") {
    LoginView()
}
#Preview("Client Home") {
    ClientHomeView(user: DemoData.clientUser)
}

#Preview("Admin Dashboard") {
    AdminDashboardView()
}

