//
//  BooksViewController.swift
//  PotterWiki
//
//  Created by Ziqa on 04/05/26.
//

import UIKit
import Combine
import Kingfisher

class BooksViewController: UIViewController {
    
    // MARK: - Variables
    weak var coordinator: BooksCoordinator?
    private let vm: BooksViewModel
    private var cancellables = Set<AnyCancellable>()
    
    
    // MARK: - UI Components
    private var dataSource: UICollectionViewDiffableDataSource<SectionEnum, BookModel>!
    
    private var collectionView: UICollectionView = {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(GridCell.itemHeight))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 2)
        group.interItemSpacing = NSCollectionLayoutSpacing.fixed(16)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 16
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.register(GridCell.self, forCellWithReuseIdentifier: GridCell.identifier)
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
    init(viewModel: BooksViewModel) {
        self.vm = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Books"
        view.backgroundColor = .systemBackground
        
        bindViewModel()
        setupUI()
        setupDataSource()
        vm.fetchBooks()
    }
    
    
    // MARK: - UI Setup
    private func setupUI() {
        collectionView.delegate = self
        view.addSubview(collectionView)
        view.addSubview(spinner)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    private func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView) { collectionView, indexPath, book in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GridCell.identifier, for: indexPath) as! GridCell
            let imageURL = URL(string: book.attributes.cover)
            cell.configure(title: book.attributes.title, imageURL: imageURL)
            return cell
        }
    }
    
    private func bindViewModel() {
        vm.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                isLoading ? self?.spinner.startAnimating() : self?.spinner.stopAnimating()
            }
            .store(in: &cancellables)
        
        vm.$books
            .receive(on: DispatchQueue.main)
            .sink { [weak self] books in
                self?.contentUnavailableConfiguration = nil
                self?.collectionView.reloadData()
                self?.applySnapshot(books: books)
            }
            .store(in: &cancellables)
        
        vm.$error
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink{ [weak self] error in
                guard let self = self else { return }
                
                switch error {
                case .noInternet:
                    if !self.vm.books.isEmpty {
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
    
    private func applySnapshot(books: [BookModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<SectionEnum, BookModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems(books, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func showErrorState(icon: String, title: String, message: String) {
        var config = UIContentUnavailableConfiguration.empty()
        config.image = UIImage(systemName: icon)
        config.text = title
        config.secondaryText = message
        
        let buttonConfig = AppButton(style: .primary, title: "Retry").configuration
        
        config.button = buttonConfig!
        config.buttonProperties.primaryAction = UIAction { [weak self] _ in
            self?.contentUnavailableConfiguration = nil
            self?.vm.fetchBooks()
        }
        
        contentUnavailableConfiguration = config
    }
}


// MARK: - Collection View Delegate
extension BooksViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let book = dataSource.itemIdentifier(for: indexPath) else { return }
        let cell = collectionView.cellForItem(at: indexPath)
        coordinator?.showBookDetail(book: book, sourceView: cell)
    }
}
