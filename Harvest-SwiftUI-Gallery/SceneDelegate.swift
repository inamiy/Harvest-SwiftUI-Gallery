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

            let scheduler = DispatchQueue(label: "com.inamiy.Harvest-SwiftUI-Gallery")

            let store = Store<Root.Input, Root.State>(
                state: Root.State(current: nil),
                mapping: Root.effectMapping(scheduler: scheduler),
                scheduler: scheduler
            )

            window.rootViewController = UIHostingController(
                rootView: AppView(store: store)
            )

            self.window = window
            window.makeKeyAndVisible()
        }
    }
}

