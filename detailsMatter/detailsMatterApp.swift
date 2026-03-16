import SwiftUI
import FirebaseCore

@main
struct detailsMatterApp: App {
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
