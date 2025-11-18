//
//  SceneDelegate.swift
//  Financial Management
//
//  Created by Ziyang Xu on 11/18/25.
//

import UIKit
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        
        // Check auth state and set the appropriate root view controller
        setupRootViewController()
        
        window?.makeKeyAndVisible()
        
        // Listen for login/logout events
        setupAuthStateListener()
    }
    
    // Decide which root view controller to show based on auth state
    private func setupRootViewController() {
        if Auth.auth().currentUser != nil {
            // User is already signed in – show main interface
            showMainInterface()
        } else {
            // User is not signed in – show login flow
            showLoginInterface()
        }
    }
    
    // Show the main tab bar after login
    private func showMainInterface() {
        let mainTabBarController = MainTabBarController()
        window?.rootViewController = mainTabBarController
    }
    
    // Show login screen wrapped in a navigation controller
    private func showLoginInterface() {
        let loginViewController = LoginViewController()
        let navigationController = UINavigationController(rootViewController: loginViewController)
        window?.rootViewController = navigationController
    }
    
    // Set up observers for custom login/logout notifications
    private func setupAuthStateListener() {
        // User logged in
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(userDidLogin),
            name: .userDidLogin,
            object: nil
        )
        
        // User logged out
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(userDidLogout),
            name: .userDidLogout,
            object: nil
        )
    }
    
    @objc private func userDidLogin() {
        DispatchQueue.main.async { [weak self] in
            self?.showMainInterface()
        }
    }
    
    @objc private func userDidLogout() {
        DispatchQueue.main.async { [weak self] in
            self?.showLoginInterface()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called when the scene is being released by the system.
        // This occurs shortly after the scene enters the background,
        // or when its session is discarded.
        // Release any resources that can be recreated the next time
        // the scene connects.
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene moves from an inactive state to active.
        // Restart any tasks that were paused (or not yet started)
        // while the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene moves from active to inactive.
        // This can happen due to temporary interruptions
        // (e.g. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background
        // back into the foreground.
        // Undo the changes made when entering the background here.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground
        // into the background.
        // Use this method to save data, release shared resources,
        // and store enough scene-specific state information to
        // restore the scene to its current state later.
    }
}
