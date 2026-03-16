import SwiftUI
#if !DEMO_MODE
import FirebaseCore
#endif

@main
struct detailsMatterApp: App {
    init() {
        #if !DEMO_MODE
        // Skip Firebase in Xcode Previews (no GoogleService-Info.plist available)
        let isPreview = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
        if !isPreview {
            FirebaseApp.configure()
        }
        #endif
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
