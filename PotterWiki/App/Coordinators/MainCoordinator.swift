//
//  MainCoordinator.swift
//  PotterWiki
//
//  Created by Ziqa on 04/05/26.
//

import UIKit

/// Main app flow coordinator
final class MainCoordinator: Coordinator {
    
    var childCoordinators: [Coordinator] = []
    var tabBarConttroller: UITabBarController
    private var dependencies: AppDependencies
    
    init(dependencies: AppDependencies) {
        self.tabBarConttroller = UITabBarController()
        self.dependencies = dependencies
    }
    
    func start() {
        let booksCoordinator = BooksCoordinator(dependencies: dependencies)
        let moviesCoordinator = MoviesCoordinator(dependencies: dependencies)
        let wikiCoordinator = WikiCoordinator(dependencies: dependencies)
        
        let tabs: [Coordinator] = [
            booksCoordinator,
            moviesCoordinator,
            wikiCoordinator
        ]
        
        tabs.forEach {
            addChild($0)
            $0.start()
        }
        
        tabBarConttroller.viewControllers = [
            booksCoordinator.navigationController,
            moviesCoordinator.navigationController,
            wikiCoordinator.navigationController
        ]
    }
}
