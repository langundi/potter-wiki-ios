//
//  BooksDetailViewController.swift
//  PotterWiki
//
//  Created by Ziqa on 04/05/26.
//

import UIKit
import Kingfisher

class BookDetailViewController: UIViewController {
    
    
    // MARK: - Variables
    weak var coordinator: BooksCoordinator?
    private let vm: BooksViewModel
    var book: BookModel
    
    
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
    
    private var bookCover: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 12
        return iv
    }()
    
    private var bookTitle: UILabel = {
        let label = UILabel()
        let descriptor = UIFontDescriptor
            .preferredFontDescriptor(withTextStyle: .body)
            .withDesign(.serif)!
            .addingAttributes([
                .traits: [UIFontDescriptor.TraitKey.weight: UIFont.Weight.medium]
            ])
        label.font = UIFont(descriptor: descriptor, size: 18)
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
    private let author: UILabel = {
        let label = UILabel()
        let descriptor = UIFontDescriptor
            .preferredFontDescriptor(withTextStyle: .body)
            .withDesign(.monospaced)!
        label.font = UIFont(descriptor: descriptor, size: 18)
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()
    
    private let releaseDateAndPages: UILabel = {
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
    
    private let chaptersSection = ChaptersSectionView()
    
    
    // MARK: - Lifecycle
    init(book: BookModel, viewModel: BooksViewModel) {
        self.book = book
        self.vm = viewModel
        super.init(nibName: nil, bundle: nil)
        
        let imageURL = URL(string: (book.attributes.cover))
        bookCover.kf.setImage(with: imageURL, options: [.transition(.fade(0.2)), .cacheOriginalImage])
        
        bookTitle.text = book.attributes.title
        
        author.text = book.attributes.author
        
        releaseDateAndPages.text = book.attributes.releaseDate + " • " + String(book.attributes.pages) + " pages"
        
        summarySection.configure(summary: book.attributes.summary)
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
        bindViewModel()
        vm.fetchChapters(bookID: book.id)
    }
    
    
    // MARK: - UI Setup
    private func setupUI() {
        self.view.addSubview(scrollView)
        scrollView.addSubview(headerVStack)
        scrollView.addSubview(divider)
        scrollView.addSubview(summarySection)
        scrollView.addSubview(chaptersSection)
        
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
            
            summarySection.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 30),
            summarySection.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            summarySection.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16),
            
            chaptersSection.topAnchor.constraint(equalTo: summarySection.bottomAnchor, constant: 30),
            chaptersSection.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            chaptersSection.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16),
            chaptersSection.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -16),
        ])
        
        headerVStack.addArrangedSubview(bookCover)
        headerVStack.addArrangedSubview(bookTitle)
        headerVStack.addArrangedSubview(author)
        headerVStack.addArrangedSubview(releaseDateAndPages)
        
        NSLayoutConstraint.activate([
            bookCover.widthAnchor.constraint(equalToConstant: 180),
            bookCover.heightAnchor.constraint(equalTo: bookCover.widthAnchor, multiplier: 1.5),
            bookTitle.widthAnchor.constraint(equalTo: headerVStack.widthAnchor, multiplier: 0.5),
        ])
    }
    
    private func bindViewModel() {
        vm.onLoading = { [weak self] isLoading in
            DispatchQueue.main.async {
                isLoading ? self?.chaptersSection.spinner.startAnimating() : self?.chaptersSection.spinner.stopAnimating()
            }
        }
        
        vm.onChaptersUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.chaptersSection.chapters = self?.vm.chapters ?? []
            }
        }
        
        chaptersSection.onChapterTapped = { [weak self] chapter in
            self?.coordinator?.showChapterDetail(chapter: chapter)
        }
        
        vm.onError = { [weak self] error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch error {
                case .noInternet:
                    if self.vm.chapters.isEmpty {
                        AlertManager.shared.showAlert(
                            on: self,
                            title: "Couldn't Load Chapters",
                            message: "Please check your internet connection and try again."
                        )
                    }
                case .responseError:
                    AlertManager.shared.showAlert(
                        on: self,
                        title: "Couldn't Load Chapters",
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
}
