//
//  SpellDetailViewController.swift.swift
//  PotterWiki
//
//  Created by Ziqa on 04/05/26.
//

import UIKit
import Kingfisher

class SpellDetailViewController: UIViewController {
    
    
    // MARK: - Variables
    weak var coordinator: WikiCoordinator?
    var spell: SpellModel

    
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
    
    private var spellImage: UIImageView = {
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
        textView.textColor = .systemBlue
        textView.font = .systemFont(ofSize: 16, weight: .regular)
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.backgroundColor = .clear
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private let informationSection = SpellInformationSectionView()

    
    // MARK: - Lifecycle
    init(spell: SpellModel) {
        self.spell = spell
        super.init(nibName: nil, bundle: nil)
        
        if let url = spell.attributes.image {
            let imageURL = URL(string: url)
            spellImage.kf.setImage(with: imageURL, options: [.transition(.fade(0.2)), .cacheOriginalImage])
        } else {
            spellImage.image = .none
        }
        
        name.text = spell.attributes.name
        
        informationSection.configure(attributes: spell.attributes)
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
        scrollView.addSubview(informationSection)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            headerVStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            headerVStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            headerVStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16),
            
            informationSection.topAnchor.constraint(equalTo: headerVStack.bottomAnchor, constant: 50),
            informationSection.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            informationSection.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16),
            informationSection.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -16),
        ])
        
        headerVStack.addArrangedSubview(spellImage)
        headerVStack.addArrangedSubview(name)
        
        if let link = spell.attributes.wiki {
            headerVStack.addArrangedSubview(wikiLink)
            configure(link: link, displayText: "Fandom")
        }
        
        NSLayoutConstraint.activate([
            spellImage.widthAnchor.constraint(equalTo: spellImage.widthAnchor),
            spellImage.heightAnchor.constraint(equalTo: spellImage.widthAnchor, multiplier: 0.7),
            name.widthAnchor.constraint(equalTo: headerVStack.widthAnchor, multiplier: 0.7),
        ])
    }
    
    func configure(link: String, displayText: String) {
        guard let url = URL(string: link) else { return }
        
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
            .link: url,
            .font: UIFont.systemFont(ofSize: 16)
        ], range: fullText)
        
        
        self.wikiLink.attributedText = attributed
    }
}

