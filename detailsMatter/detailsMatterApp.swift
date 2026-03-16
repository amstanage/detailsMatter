import SwiftUI
#if !DEMO_MODE
import FirebaseCore
#endif

@main
struct detailsMatterApp: App {
    init() {
        #if !DEMO_MODE
        FirebaseApp.configure()
        #endif
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
