import SwiftData
import SwiftUI

@main
struct ExampleApp: App {
    @State var viewModel = ViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(viewModel)
        }
    }
}
