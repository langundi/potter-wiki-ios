//
//  SpellsViewController.swift
//  PotterWiki
//
//  Created by Ziqa on 10/05/26.
//

import UIKit

class SpellsViewController: UIViewController {
    
    
    // MARK: - Variables
    weak var coordinator: WikiCoordinator?
    private var vm: SpellsViewModel
    
    
    // MARK: - UI Components
    private var searchButton: UIBarButtonItem!
    private var prevButton: UIBarButtonItem!
    private var nextButton: UIBarButtonItem!
    private var representative: UIBarButtonItem!
    
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
    init(viewModel: SpellsViewModel) {
        self.vm = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Potions"
        navigationItem.largeTitleDisplayMode = .never
        
        bindViewModel()
        setupNavigationBar()
        setupSearchController()
        setupUI()
        vm.fetchSpells()
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
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search potions..."
        searchController.searchBar.keyboardAppearance = .light
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
    }
    
    private func setupUI() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
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
    
    private func bindViewModel() {
        vm.onLoading = { [weak self] isLoading in
            DispatchQueue.main.async {
                isLoading ? self?.spinner.startAnimating() : self?.spinner.stopAnimating()
            }
        }
        
        vm.onSpellsUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.contentUnavailableConfiguration = nil
                self?.enableNavBar()
                self?.collectionView.reloadData()
            }
        }
        
        vm.onError = { [weak self] error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch error {
                case .noInternet:
                    if self.vm.isSearching || !self.vm.currentSpells.isEmpty {
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
        }
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
            self?.vm.fetchSpells()
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


// MARK: - Collection Delegate
extension SpellsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        vm.currentSpells.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WikiCell.identifier, for: indexPath) as! WikiCell
        let potion = vm.currentSpells[indexPath.row]
        
        if let url = potion.attributes.image {
            let imageURL = URL(string: url)
            cell.configure(title: potion.attributes.name!, imageURL: imageURL)
        } else {
            cell.configure(title: potion.attributes.name!, imageURL: nil)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let spell = vm.currentSpells[indexPath.row]
        coordinator?.showSpellDetail(spell: spell)
    }
}


// MARK: - Search
extension SpellsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let query = searchController.searchBar.text ?? ""
        vm.search(query: query)
    }
}

