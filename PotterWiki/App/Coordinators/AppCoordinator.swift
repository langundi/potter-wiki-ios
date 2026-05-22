//
//  AppCoordinator.swift
//  PotterWiki
//
//  Created by Ziqa on 04/05/26.
//

import UIKit

/// Root app coordinator
final class AppCoordinator: Coordinator {
    
    var childCoordinators: [Coordinator] = []
    private let window: UIWindow
    private let dependencies: AppDependencies
    
    init(window: UIWindow, dependencies: AppDependencies) {
        self.window = window
        self.dependencies = dependencies
    }
    
    func start() {
        let tabBarCoordinator = MainCoordinator(dependencies: dependencies)
        addChild(tabBarCoordinator)
        tabBarCoordinator.start()
        
        window.rootViewController = tabBarCoordinator.tabBarConttroller
        window.backgroundColor = .systemBackground
        window.makeKeyAndVisible()
    }
}
