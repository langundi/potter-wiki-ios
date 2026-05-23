//
//  CharacterDetailViewController.swift
//  PotterWiki
//
//  Created by Ziqa on 04/05/26.
//

import UIKit
import Kingfisher

class CharacterDetailViewController: UIViewController {
    
    // MARK: - Variables
    weak var coordinator: WikiCoordinator?
    var character: CharacterModel

    
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
    
    private var characterImage: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.tintColor = .systemGray
        iv.backgroundColor = .systemGray6
        iv.layer.cornerRadius = 12
        return iv
    }()
    
    private var name: UILabel = {
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
    
    private let wikiLink: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.backgroundColor = .clear
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private var urlString: String = ""
    
    private let biographySection = BiographySectionView()
    
    private let physicalSection = PhysicalSectionView()
    
    private let relationshipSection = RelationshipSectionView()
    
    private let magicalSection = MagicalSectionView()
    
    private let affiliationSection = AffiliationSectionView()
    
    
    // MARK: - Lifecycle
    init(character: CharacterModel) {
        self.character = character
        super.init(nibName: nil, bundle: nil)
        
        if let url = character.attributes.image {
            let imageURL = URL(string: url)
            characterImage.kf.setImage(with: imageURL, options: [.transition(.fade(0.2)), .cacheOriginalImage])
        } else {
            characterImage.image = .none
        }
        
        name.text = character.attributes.name
        
        biographySection.configure(attributes: character.attributes)
        
        physicalSection.configure(attributes: character.attributes)
        
        relationshipSection.configure(attributes: character.attributes)
        
        magicalSection.configure(attributes: character.attributes)
        
        affiliationSection.configure(attributes: character.attributes)
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
        scrollView.addSubview(biographySection)
        scrollView.addSubview(physicalSection)
        scrollView.addSubview(relationshipSection)
        scrollView.addSubview(magicalSection)
        scrollView.addSubview(affiliationSection)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            headerVStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            headerVStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            headerVStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16),
            
            biographySection.topAnchor.constraint(equalTo: headerVStack.bottomAnchor, constant: 50),
            biographySection.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            biographySection.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16),
            
            physicalSection.topAnchor.constraint(equalTo: biographySection.bottomAnchor, constant: 40),
            physicalSection.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            physicalSection.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16),
            
            relationshipSection.topAnchor.constraint(equalTo: physicalSection.bottomAnchor, constant: 40),
            relationshipSection.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            relationshipSection.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16),
            
            magicalSection.topAnchor.constraint(equalTo: relationshipSection.bottomAnchor, constant: 40),
            magicalSection.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            magicalSection.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16),
            
            affiliationSection.topAnchor.constraint(equalTo: magicalSection.bottomAnchor, constant: 40),
            affiliationSection.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            affiliationSection.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16),
            affiliationSection.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -16),
        ])
        
        headerVStack.addArrangedSubview(characterImage)
        headerVStack.addArrangedSubview(name)
        
        if let link = character.attributes.wiki {
            headerVStack.addArrangedSubview(wikiLink)
            configure(link: link, displayText: "Fandom")
        }
        
        NSLayoutConstraint.activate([
            characterImage.widthAnchor.constraint(equalToConstant: 180),
            characterImage.heightAnchor.constraint(equalTo: characterImage.widthAnchor, multiplier: 1.5),
            name.widthAnchor.constraint(equalTo: headerVStack.widthAnchor, multiplier: 0.7),
        ])
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleLinkTap))
        wikiLink.addGestureRecognizer(tap)
    }
    
    func configure(link: String, displayText: String) {
        self.urlString = link
        
        let symbol = NSTextAttachment()
        symbol.image = UIImage(
            systemName: "link",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 16))?
            .withTintColor(.systemBlue)
        
        let attributed = NSMutableAttributedString()
        attributed.append(NSAttributedString(attachment: symbol))
        attributed.append(NSAttributedString(string: " \(displayText)"))
        
        let fullText = NSRange(location: 0, length: attributed.length)
        attributed.addAttributes([
            .font: UIFont.systemFont(ofSize: 16),
            .foregroundColor: UIColor.systemBlue
        ], range: fullText)
        
        self.wikiLink.attributedText = attributed
    }
    
    @objc private func handleLinkTap() {
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }
}

