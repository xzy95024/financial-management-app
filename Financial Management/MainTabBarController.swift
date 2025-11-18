//
//  MainTabBarController.swift
//  Financial Management
//
//  Created by Ziyang Xu on 11/18/25.
//
//

import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        setupViewControllers()
    }
    
    private func setupTabBar() {
        // TabBar style configuration
        tabBar.backgroundColor = UIColor.systemBackground
        tabBar.tintColor = UIColor(red: 0.4, green: 0.49, blue: 0.92, alpha: 1.0) // #667eea
        tabBar.unselectedItemTintColor = UIColor.systemGray
        
        // Shadow effect
        tabBar.layer.shadowColor = UIColor.black.cgColor
        tabBar.layer.shadowOpacity = 0.1
        tabBar.layer.shadowOffset = CGSize(width: 0, height: -2)
        tabBar.layer.shadowRadius = 4
    }
    
    private func setupViewControllers() {
        
        let homeVC = createNavigationController(
            rootViewController: DashboardViewController(),
            title: "Home",
            imageName: "house.fill"
        )
        
        let insightsVC = createNavigationController(
            rootViewController: StatisticsViewController(),
            title: "Insights",
            imageName: "chart.pie.fill"
        )
        
        let spendingVC = createNavigationController(
            rootViewController: MerchantsViewController(),
            title: "Spending",
            imageName: "creditcard.fill"
        )
        
        let profileVC = createNavigationController(
            rootViewController: SettingsViewController(),
            title: "Profile",
            imageName: "person.crop.circle.fill"
        )
        
        viewControllers = [homeVC, insightsVC, spendingVC, profileVC]
    }
    
    private func createNavigationController(
        rootViewController: UIViewController,
        title: String,
        imageName: String
    ) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: rootViewController)
        
        // Tab bar item
        navigationController.tabBarItem = UITabBarItem(
            title: title,
            image: UIImage(systemName: imageName),
            selectedImage: UIImage(systemName: imageName)
        )
        
        // Navigation bar style
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
        
        navigationController.navigationBar.standardAppearance = appearance
        navigationController.navigationBar.scrollEdgeAppearance = appearance
        navigationController.navigationBar.prefersLargeTitles = true
        
        return navigationController
    }
}
