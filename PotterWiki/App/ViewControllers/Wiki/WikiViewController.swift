//
//  WikiViewController.swift
//  PotterWiki
//
//  Created by Ziqa on 04/05/26.
//

import UIKit

class WikiViewController: UIViewController {
    
    
    // MARK: - Variables
    weak var coordinator: WikiCoordinator?
    private let cacheManager: CacheManager
    
    
    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.delaysContentTouches = false
        sv.isScrollEnabled = false
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private lazy var vStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .top
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let charactersButton = AppButton(style: .primary, title: "Characters", icon: "person.fill")
    private let potionsButton = AppButton(style: .primary, title: "Potions", icon: "flask.fill")
    private let spellsButton = AppButton(style: .primary, title: "Spells", icon: "wand.and.sparkles.inverse")
    
    private let dataProvider: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.text = "All data provided by:"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let potterDB: UITextView = {
        let symbol = NSTextAttachment()
        symbol.image = UIImage(
            systemName: "link",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 16))?
            .withTintColor(.systemBlue)
        
        let attributedString = NSMutableAttributedString()
        attributedString.append(NSAttributedString(attachment: symbol))
        attributedString.append(NSAttributedString(string: " PotterDB"))
        attributedString.addAttributes([
            .font: UIFont.systemFont(ofSize: 16, weight: .regular),
            .foregroundColor: UIColor.systemBlue
        ], range: NSRange(location: 0, length: attributedString.length))
        
        let textView = UITextView()
        textView.attributedText = attributedString
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.backgroundColor = .clear
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private var clearCacheButton: UIButton = {
        let button = UIButton()
        button.setTitle("Clear Cache", for: .normal)
        if #available(iOS 26.0, *) {
            button.configuration = .clearGlass()
        } else {
            button.configuration = .bordered()
        }
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    // MARK: - Lifecycle
    init(cacheManager: CacheManager) {
        self.cacheManager = cacheManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Wiki"
        navigationItem.largeTitleDisplayMode = .always
        view.backgroundColor = .systemBackground
        
        setupUI()
        setupSelectors()
    }
    
    
    // MARK: - UI Setup
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(vStack)
        scrollView.addSubview(dataProvider)
        scrollView.addSubview(potterDB)
        scrollView.addSubview(clearCacheButton)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            vStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            vStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            vStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16),
            
            dataProvider.topAnchor.constraint(equalTo: vStack.bottomAnchor, constant: 250),
            dataProvider.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            potterDB.topAnchor.constraint(equalTo: dataProvider.bottomAnchor, constant: 8),
            potterDB.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            
            clearCacheButton.topAnchor.constraint(equalTo: potterDB.bottomAnchor, constant: 20),
            clearCacheButton.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -16),
            clearCacheButton.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor)
        ])
        
        vStack.addArrangedSubview(charactersButton)
        vStack.addArrangedSubview(potionsButton)
        vStack.addArrangedSubview(spellsButton)
        
        NSLayoutConstraint.activate([
            charactersButton.widthAnchor.constraint(equalTo: vStack.widthAnchor),
            potionsButton.widthAnchor.constraint(equalTo: vStack.widthAnchor),
            spellsButton.widthAnchor.constraint(equalTo: vStack.widthAnchor),
        ])
    }
    
    
    // MARK: - Selectors
    private func setupSelectors() {
        charactersButton.addAction(UIAction { [weak self] _ in
            self?.coordinator?.showCharacters()
        }, for: .touchUpInside)
        
        potionsButton.addAction(UIAction { [weak self] _ in
            self?.coordinator?.showPotions()
        }, for: .touchUpInside)
        
        spellsButton.addAction(UIAction { [weak self] _ in
            self?.coordinator?.showSpells()
        }, for: .touchUpInside)
        
        clearCacheButton.addAction(UIAction { [weak self] _ in
            self?.cacheManager.clearAll()
        }, for: .touchUpInside)
        
        potterDB.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleLinkTap)))
    }
    
    @objc private func handleLinkTap() {
        guard let url = URL(string: "https://potterdb.com/") else { return }
        UIApplication.shared.open(url)
    }
}

