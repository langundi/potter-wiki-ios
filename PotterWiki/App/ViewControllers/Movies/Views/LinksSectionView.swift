//
//  LinksSectionView.swift
//  PotterWiki
//
//  Created by Ziqa on 13/05/26.
//

import UIKit

class LinksSectionView: UIView {
    
    
    // MARK: - UI Components
    private let title: UILabel = {
        let label = UILabel()
        let descriptor = UIFontDescriptor
            .preferredFontDescriptor(withTextStyle: .body)
            .withDesign(.serif)!
            .addingAttributes([
                .traits: [UIFontDescriptor.TraitKey.weight: UIFont.Weight.semibold]
            ])
        label.font = UIFont(descriptor: descriptor, size: 22)
        label.textColor = .label
        label.textAlignment = .center
        label.text = "Links"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let trailerLink = LinkAttributesView(title: "Trailer:")
    private let wikiLink = LinkAttributesView(title: "Wiki:")
    
    private lazy var contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .leading
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let divider: UIView = {
        let view = UIView()
        view.backgroundColor = .separator
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    // MARK: - Lifecycle
    init() {
        super.init(frame: .zero)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(divider)
        addSubview(title)
        addSubview(contentStack)
        contentStack.addArrangedSubview(trailerLink)
        contentStack.addArrangedSubview(wikiLink)
        
        NSLayoutConstraint.activate([
            divider.topAnchor.constraint(equalTo: topAnchor),
            divider.leadingAnchor.constraint(equalTo: leadingAnchor),
            divider.trailingAnchor.constraint(equalTo: trailingAnchor),
            divider.heightAnchor.constraint(equalToConstant: 1.5),
            
            title.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 40),
            title.leadingAnchor.constraint(equalTo: leadingAnchor),
            
            contentStack.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 16),
            contentStack.bottomAnchor.constraint(equalTo: bottomAnchor),
            contentStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(attributes: MovieAttributes) {
        trailerLink.configure(link: attributes.trailer, displayText: "YouTube")
        wikiLink.configure(link: attributes.wiki, displayText: "Fandom")
    }
}
