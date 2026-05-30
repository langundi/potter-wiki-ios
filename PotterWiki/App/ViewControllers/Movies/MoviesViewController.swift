//
//  MoviesViewController.swift
//  PotterWiki
//
//  Created by Ziqa on 04/05/26.
//

import UIKit
import Combine

class MoviesViewController: UIViewController {
    
    
    // MARK: - Variables
    weak var coordinator: MoviesCoordinator?
    private var vm: MoviesViewModel
    private var cancellables = Set<AnyCancellable>()

    
    // MARK: - UI Components
    private var dataSource: UICollectionViewDiffableDataSource<SectionEnum, MovieModel>!
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: GridCell.itemWidth, height: GridCell.itemHeight)
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .systemBackground
        cv.register(GridCell.self, forCellWithReuseIdentifier: "GridCell")
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
    init(viewModel: MoviesViewModel) {
        self.vm = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Movies"
        view.backgroundColor = .systemBackground
        
        bindViewModel()
        setupUI()
        setupDataSource()
        vm.fetchMovies()
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
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView) { collectionView, indexPath, movie in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GridCell.identifier, for: indexPath) as! GridCell
            let imageURL = URL(string: movie.attributes.poster)
            cell.configure(title: movie.attributes.title, imageURL: imageURL)
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
        
        vm.$movies
            .receive(on: DispatchQueue.main)
            .sink{ [weak self] movies in
                self?.contentUnavailableConfiguration = nil
                self?.applySnapshot(movies: movies)
            }
            .store(in: &cancellables)
        
        vm.$error
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] error in
                guard let self = self else { return }
                switch error {
                case .noInternet:
                    if !self.vm.movies.isEmpty {
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
    
    private func applySnapshot(movies: [MovieModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<SectionEnum, MovieModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems(movies, toSection: .main)
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
            self?.vm.fetchMovies()
        }
        
        contentUnavailableConfiguration = config
    }
}


// MARK: - Collection View Delegate
extension MoviesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let movie = dataSource.itemIdentifier(for: indexPath) else { return }
        let cell = collectionView.cellForItem(at: indexPath)
        coordinator?.showMovieDetail(movie: movie, sourceView: cell)
    }
}
