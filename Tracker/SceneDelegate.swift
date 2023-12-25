import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let scene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: scene)
        if UserDefaults.standard.bool(forKey: "isOnboardingShown") {
                let tabBarController = TabBarController() 
                window.rootViewController = tabBarController
            } else {
                let onboardingViewController = OnboardingViewController()
                window.rootViewController = onboardingViewController
            }
        self.window = window
        window.makeKeyAndVisible()
    }
}

