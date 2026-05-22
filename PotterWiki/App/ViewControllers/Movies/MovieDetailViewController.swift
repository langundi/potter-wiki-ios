//
//  MovieDetailViewController.swift
//  PotterWiki
//
//  Created by Ziqa on 04/05/26.
//

import UIKit
import Kingfisher

class MovieDetailViewController: UIViewController {
    
    
    // MARK: - Variables
    weak var coordinator: MoviesCoordinator?
    var movie: MovieModel

    
    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.delaysContentTouches = false
        sv.isScrollEnabled = true
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private lazy var headerVStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private var moviePoster: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 12
        return iv
    }()
    
    private var movieTitle: UILabel = {
        let label = UILabel()
        let descriptor = UIFontDescriptor
            .preferredFontDescriptor(withTextStyle: .body)
            .withDesign(.serif)!
            .addingAttributes([
                .traits: [UIFontDescriptor.TraitKey.weight: UIFont.Weight.medium]
            ])
        label.font = UIFont(descriptor: descriptor, size: 18)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let studio: UILabel = {
        let label = UILabel()
        let descriptor = UIFontDescriptor
            .preferredFontDescriptor(withTextStyle: .body)
            .withDesign(.monospaced)!
        label.font = UIFont(descriptor: descriptor, size: 18)
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()
    
    private let releaseDate: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()
    
    private let divider: UIView = {
        let view = UIView()
        view.backgroundColor = .separator
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let summarySection = SummarySectionView()
    
    private let aboutSection = AboutSectionView()
    
    private let staffSection = StaffSectionView()
    
    private let linksSection = LinksSectionView()
    
    
    // MARK: - Lifecycle
    init(movie: MovieModel) {
        self.movie = movie
        super.init(nibName: nil, bundle: nil)
        
        let imageURL = URL(string: movie.attributes.poster)
        moviePoster.kf.setImage(with: imageURL, options: [.transition(.fade(0.2)), .cacheOriginalImage])
        movieTitle.text = movie.attributes.title
        studio.text = movie.attributes.distributors.first
        releaseDate.text = movie.attributes.releaseDate
        
        summarySection.configure(summary: movie.attributes.summary)
        
        aboutSection.configure(attributes: movie.attributes)
        
        staffSection.configure(attributes: movie.attributes)
        
        linksSection.configure(attributes: movie.attributes)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = ""
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .systemBackground
        
        setupUI()
    }
    
    
    // MARK: - UI Setup
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(headerVStack)
        scrollView.addSubview(divider)
        scrollView.addSubview(summarySection)
        scrollView.addSubview(aboutSection)
        scrollView.addSubview(staffSection)
        scrollView.addSubview(linksSection)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            headerVStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            headerVStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            headerVStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16),
            
            divider.topAnchor.constraint(equalTo: headerVStack.bottomAnchor, constant: 50),
            divider.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            divider.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16),
            divider.heightAnchor.constraint(equalToConstant: 1.5),
            
            summarySection.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 40),
            summarySection.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            summarySection.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16),
            
            aboutSection.topAnchor.constraint(equalTo: summarySection.bottomAnchor, constant: 40),
            aboutSection.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            aboutSection.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16),
            
            staffSection.topAnchor.constraint(equalTo: aboutSection.bottomAnchor, constant: 40),
            staffSection.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            staffSection.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16),
            
            linksSection.topAnchor.constraint(equalTo: staffSection.bottomAnchor, constant: 40),
            linksSection.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            linksSection.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16),
            linksSection.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -16),
        ])
        
        headerVStack.addArrangedSubview(moviePoster)
        headerVStack.addArrangedSubview(movieTitle)
        headerVStack.addArrangedSubview(studio)
        headerVStack.addArrangedSubview(releaseDate)
        
        NSLayoutConstraint.activate([
            moviePoster.widthAnchor.constraint(equalToConstant: 180),
            moviePoster.heightAnchor.constraint(equalTo: moviePoster.widthAnchor, multiplier: 1.5),
            movieTitle.widthAnchor.constraint(equalTo: headerVStack.widthAnchor, multiplier: 0.7),
        ])
    }
}

