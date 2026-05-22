//
//  PhysicalSectionView.swift
//  PotterWiki
//
//  Created by Ziqa on 16/05/26.
//

import UIKit

class PhysicalSectionView: UIView {
    
    
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
        label.text = "Physical Description"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let species = AttributesView(title: "Species:")
    private let gender = AttributesView(title: "Gender:")
    private let weight = AttributesView(title: "Weight:")
    private let height = AttributesView(title: "Height:")
    private let hairColor = AttributesView(title: "Hair Color:")
    private let eyeColor = AttributesView(title: "Eye Color:")
    private let skinColor = AttributesView(title: "Skin Color:")
    
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
        contentStack.addArrangedSubview(species)
        contentStack.addArrangedSubview(gender)
        contentStack.addArrangedSubview(weight)
        contentStack.addArrangedSubview(height)
        contentStack.addArrangedSubview(hairColor)
        contentStack.addArrangedSubview(eyeColor)
        contentStack.addArrangedSubview(skinColor)
        
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
        species.configure(attributes: [attributes.species ?? "-"])
        gender.configure(attributes: [attributes.gender ?? "-"])
        weight.configure(attributes: [attributes.weight ?? "-"])
        height.configure(attributes: [attributes.height ?? "-"])
        hairColor.configure(attributes: [attributes.hairColor ?? "-"])
        eyeColor.configure(attributes: [attributes.eyeColor ?? "-"])
        skinColor.configure(attributes: [attributes.skinColor ?? "-"])
    }
}
