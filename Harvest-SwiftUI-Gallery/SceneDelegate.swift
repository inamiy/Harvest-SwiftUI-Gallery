import UIKit
import Combine
import SwiftUI
import HarvestStore

class SceneDelegate: UIResponder, UIWindowSceneDelegate
{
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    )
    {
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)

            let store = Store<DebugRoot.Input, DebugRoot.State>(
                state: DebugRoot.State(inner: Root.State(current: nil), usesTimeTravel: usesTimeTravel),
                mapping: DebugRoot.effectMapping(usesTimeTravel: usesTimeTravel),
                world: makeRealWorld()
            )

            window.rootViewController = UIHostingController(
                rootView: AppView(store: store)
            )

            self.window = window
            window.makeKeyAndVisible()
        }
    }
}

private let usesTimeTravel: Bool = true
