//
//  RelationshipSectionView.swift
//  PotterWiki
//
//  Created by Ziqa on 16/05/26.
//

import UIKit

class RelationshipSectionView: UIView {
    
    
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
        label.text = "Relationships"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let familyMembers = AttributesView(title: "Family Members:")
    private let romances = AttributesView(title: "Romances:")
    
    private lazy var contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
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
        contentStack.addArrangedSubview(familyMembers)
        contentStack.addArrangedSubview(romances)
        
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
    
    
    // MARK: - UI Setup
    func configure(attributes: CharacterAttributes) {
        familyMembers.configure(attributes: attributes.familyMembers ?? [])
        romances.configure(attributes: attributes.romances ?? [])
    }
}
