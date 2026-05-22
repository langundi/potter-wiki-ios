//
//  MoviesCoordinator.swift
//  PotterWiki
//
//  Created by Ziqa on 04/05/26.
//

import UIKit

final class MoviesCoordinator: Coordinator {
    
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    private var dependencies: AppDependencies
    
    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
        
        self.navigationController = UINavigationController()
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.tabBarItem = UITabBarItem(
            title: "Movies",
            image: UIImage(systemName: "film"),
            selectedImage: UIImage(systemName: "film.fill"))
    }
    
    func start() {
        let vm = MoviesViewModel(
            potterService: dependencies.potterService,
            cacheManager: dependencies.cacheManager
        )
        
        let vc = MoviesViewController(viewModel: vm)
        vc.coordinator = self
        
        navigationController.setViewControllers([vc], animated: false)
    }
    
    func showMovieDetail(movie: MovieModel, sourceView: UIView?) {
        let vc = MovieDetailViewController(movie: movie)
        vc.coordinator = self
        vc.preferredTransition = .zoom { _ in
            return sourceView
        }
        
        navigationController.pushViewController(vc, animated: true)
    }
    
    func didFinishDetail() {
        navigationController.popViewController(animated: true)
    }
    
}
