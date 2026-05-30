//
//  CharactersViewController.swift
//  PotterWiki
//
//  Created by Ziqa on 10/05/26.
//

import UIKit
import Combine

class CharactersViewController: UIViewController {

    
    // MARK: - Variables
    weak var coordinator: WikiCoordinator?
    private var vm: CharactersViewModel
    private var cancellables = Set<AnyCancellable>()
    
    
    // MARK: - UI Components
    private var searchButton: UIBarButtonItem!
    private var prevButton: UIBarButtonItem!
    private var nextButton: UIBarButtonItem!
    private var representative: UIBarButtonItem!
    
    private var dataSource: UICollectionViewDiffableDataSource<SectionEnum, CharacterModel>!
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: WikiCell.itemWidth, height: WikiCell.itemHeight)
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .systemBackground
        cv.register(WikiCell.self, forCellWithReuseIdentifier: WikiCell.identifier)
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.hidesWhenStopped = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        return spinner
    }()
    

    // MARK: - Lifecycle
    init(viewModel: CharactersViewModel) {
        self.vm = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Characters"
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .systemBackground
        
        bindViewModel()
        setupNavigationBar()
        setupSearchController()
        setupUI()
        setupDataSource()
        vm.fetchCharacters()
    }
    
    
    // MARK: - UI Setup
    private func setupNavigationBar() {
        searchButton = UIBarButtonItem(
            image: UIImage(systemName: "magnifyingglass"),
            style: .plain,
            target: self,
            action: #selector(onTapSearch)
        )
        
        prevButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(handlePrev),
        )
        
        nextButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.right"),
            style: .plain,
            target: self,
            action: #selector(handleNext)
        )
        
        representative = UIBarButtonItem(
            image: UIImage(systemName: "ellipsis.circle"),
            style: .plain,
            target: nil,
            action: nil
        )
        
        let filter = UIBarButtonItemGroup(
            barButtonItems: [searchButton],
            representativeItem: representative
        )
        
        let pagination = UIBarButtonItemGroup(
            barButtonItems: [prevButton, nextButton],
            representativeItem: representative
        )
        navigationItem.trailingItemGroups = [filter, pagination]
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search characters..."
        searchController.searchBar.keyboardAppearance = .dark
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
    }
    
    private func setupUI() {
        collectionView.delegate = self
        
        view.addSubview(collectionView)
        view.addSubview(spinner)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    private func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView) { collectionView, indexPath, character in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WikiCell.identifier, for: indexPath) as! WikiCell
            
            if let name = character.attributes.name {
                if let image = character.attributes.image {
                    let url = URL(string: image)
                    cell.configure(title: name, imageURL: url)
                } else {
                    cell.configure(title: name, imageURL: nil)
                }
            }
            
            return cell
        }
    }
    
    private func applySnapshot(characters: [CharacterModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<SectionEnum, CharacterModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems(characters, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func bindViewModel() {
        vm.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                isLoading ? self?.spinner.startAnimating() : self?.spinner.stopAnimating()
            }
            .store(in: &cancellables)
        
        vm.$currentCharacters
            .receive(on: DispatchQueue.main)
            .sink { [weak self] characters in
                self?.contentUnavailableConfiguration = nil
                self?.enableNavBar()
                self?.applySnapshot(characters: characters)
            }
            .store(in: &cancellables)
        
        vm.$error
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] error in
                guard let self = self else { return }
                switch error {
                case .noInternet:
                    if self.vm.isSearching || !self.vm.currentCharacters.isEmpty {
                        AlertManager.shared.showAlert(
                            on: self,
                            title: "No Connection",
                            message: "Please check your internet connection and try again."
                        )
                    } else {
                        self.showErrorState(
                            icon: "wifi.slash",
                            title: "No Connection",
                            message: "Please check your internet connection and try again."
                        )
                    }
                case .responseError:
                    self.showErrorState(
                        icon: "exclamationmark.triangle",
                        title: "Server Error",
                        message: "Something went wrong on our end. Please try again later."
                    )
                default:
                    AlertManager.shared.showAlert(
                        on: self,
                        title: "An Error Occured",
                        message: error.message
                    )
                }
            }
            .store(in: &cancellables)
    }
    
    private func showErrorState(icon: String, title: String, message: String) {
        disableNavBar()
        
        var config = UIContentUnavailableConfiguration.empty()
        config.image = UIImage(systemName: icon)
        config.text = title
        config.secondaryText = message
        
        let buttonConfig = AppButton(style: .primary, title: "Retry").configuration
        
        config.button = buttonConfig!
        config.buttonProperties.primaryAction = UIAction { [weak self] _ in
            self?.contentUnavailableConfiguration = nil
            self?.vm.fetchCharacters()
        }
        
        contentUnavailableConfiguration = config
    }
    
    private func enableNavBar() {
        searchButton.isEnabled = true
        prevButton.isEnabled = true
        nextButton.isEnabled = true
        navigationItem.searchController = searchController
    }
    
    private func disableNavBar() {
        searchButton.isEnabled = false
        prevButton.isEnabled = false
        nextButton.isEnabled = false
        navigationItem.searchController = nil
    }
    
    
    // MARK: - Selectors
    @objc private func onTapSearch() {
        searchController.isActive = true
        searchController.searchBar.becomeFirstResponder()
    }
    
    @objc private func handleNext() {
        vm.nextPage()
    }
    
    @objc private func handlePrev() {
        vm.prevPage()
    }
}


// MARK: - Collection View Delegate
extension CharactersViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let character = dataSource.itemIdentifier(for: indexPath) else { return }
        coordinator?.showCharacterDetail(character: character)
    }
}


// MARK: - Search Result
extension CharactersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let query = searchController.searchBar.text ?? ""
        vm.searchQuery.send(query)
    }
}
