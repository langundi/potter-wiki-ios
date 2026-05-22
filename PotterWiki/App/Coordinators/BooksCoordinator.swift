//
//  BooksCoordinator.swift
//  PotterWiki
//
//  Created by Ziqa on 04/05/26.
//

import UIKit

final class BooksCoordinator: Coordinator {
    
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    private var dependencies: AppDependencies
    private var viewModel: BooksViewModel
    
    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
        
        self.viewModel = BooksViewModel(
            potterService: dependencies.potterService,
            cacheManager: dependencies.cacheManager
        )
        
        self.navigationController = UINavigationController()
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.tabBarItem = UITabBarItem(
            title: "Books",
            image: UIImage(systemName: "book"),
            selectedImage: UIImage(systemName: "book.fill"))
    }
    
    func start() {
        let vc = BooksViewController(viewModel: viewModel)
        vc.coordinator = self
        navigationController.setViewControllers([vc], animated: false)
    }
    
    func showBookDetail(book: BookModel, sourceView: UIView?) {
        let vc = BookDetailViewController(book: book, viewModel: viewModel)
        vc.coordinator = self
        vc.preferredTransition = .zoom { context in
            return sourceView
        }
        
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showChapterDetail(chapter: ChapterModel) {
        let sheet = ChapterDetailSheet(chapter: chapter)
        let nav = UINavigationController(rootViewController: sheet)
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.large()]
        }
        
        navigationController.present(nav, animated: true)
    }
    
    func didFinishDetail() {
        navigationController.popViewController(animated: true)
    }
    
}
