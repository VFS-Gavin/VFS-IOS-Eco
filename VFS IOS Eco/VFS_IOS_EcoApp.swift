import SwiftUI
import SwiftData

@main
struct VFS_IOS_EcoApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([CachedAccount.self])
        let configuration = ModelConfiguration("account-cache", schema: schema)
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
