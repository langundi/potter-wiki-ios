//
//  WikiCoordinator.swift
//  PotterWiki
//
//  Created by Ziqa on 04/05/26.
//

import UIKit

final class WikiCoordinator: Coordinator {
    
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    private var dependencies: AppDependencies
    
    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
        
        self.navigationController = UINavigationController()
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.tabBarItem = UITabBarItem(
            title: "Wiki",
            image: UIImage(systemName: "wand.and.sparkles.inverse"),
            selectedImage: UIImage(systemName: "wand.and.sparkles"))
    }
    
    func start() {
        let vc = WikiViewController(cacheManager: dependencies.cacheManager)
        vc.coordinator = self
        navigationController.setViewControllers([vc], animated: false)
    }
    
    
    // MARK: - Characters
    func showCharacters() {
        let vm = CharactersViewModel(
            potterService: dependencies.potterService,
            cacheManager: dependencies.cacheManager
        )
        
        let vc = CharactersViewController(viewModel: vm)
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showCharacterDetail(character: CharacterModel) {
        let vc = CharacterDetailViewController(character: character)
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    
    // MARK: - Potions
    func showPotions() {
        let vm = PotionsViewModel(
            potterService: dependencies.potterService,
            cacheManager: dependencies.cacheManager
        )
        
        let vc = PotionsViewController(viewModel: vm)
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showPotionDetail(potion: PotionModel) {
        let vc = PotionDetailViewController(potion: potion)
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    
    // MARK: - Spells
    func showSpells() {
        let vm = SpellsViewModel(
            potterService: dependencies.potterService,
            cacheManager: dependencies.cacheManager
        )
        
        let vc = SpellsViewController(viewModel: vm)
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showSpellDetail(spell: SpellModel) {
        let vc = SpellDetailViewController(spell: spell)
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
}
