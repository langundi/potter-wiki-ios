//
//  MoviesViewController.swift
//  PotterWiki
//
//  Created by Ziqa on 04/05/26.
//

import UIKit

class MoviesViewController: UIViewController {
    
    
    // MARK: - Variables
    weak var coordinator: MoviesCoordinator?
    private var vm: MoviesViewModel

    
    // MARK: - UI Components
    /// Legacy way to implement `UICollectionView` using `UICollectionViewFlowLayout`.
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
        vm.fetchMovies()
    }
    
    
    // MARK: - UI Setup
    private func setupUI() {
        collectionView.dataSource = self
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
    
    private func bindViewModel() {
        vm.onLoading = { [weak self] isLoading in
            DispatchQueue.main.async {
                isLoading ? self?.spinner.startAnimating() : self?.spinner.stopAnimating()
            }
        }
        
        vm.onMoviesUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.contentUnavailableConfiguration = nil
                self?.collectionView.reloadData()
            }
        }
        
        vm.onError = { [weak self] error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
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
        }
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
extension MoviesViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        vm.movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GridCell.identifier, for: indexPath) as! GridCell
        let movie = vm.movies[indexPath.item]
        
        let imageURL = URL(string: movie.attributes.poster)
        cell.configure(title: movie.attributes.title, imageURL: imageURL)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        let movie = vm.movies[indexPath.row]
        coordinator?.showMovieDetail(movie: movie, sourceView: cell)
    }
}
