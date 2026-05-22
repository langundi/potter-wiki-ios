//
//  StaffSectionView.swift
//  PotterWiki
//
//  Created by Ziqa on 16/05/26.
//

import UIKit

class StaffSectionView: UIView {
    
    
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
        label.text = "Production Staff"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let directors = AttributesView(title: "Directors:")
    private let producers = AttributesView(title: "Producers:")
    private let editors = AttributesView(title: "Editors:")
    private let cinematographers = AttributesView(title: "Cinematographers:")
    private let musicComposers = AttributesView(title: "Music Composers:")
    private let screenWriters = AttributesView(title: "Screen Writers:")
    
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
        contentStack.addArrangedSubview(directors)
        contentStack.addArrangedSubview(producers)
        contentStack.addArrangedSubview(editors)
        contentStack.addArrangedSubview(cinematographers)
        contentStack.addArrangedSubview(musicComposers)
        contentStack.addArrangedSubview(screenWriters)
        
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
    func configure(attributes: MovieAttributes) {
        directors.configure(attributes: attributes.directors)
        producers.configure(attributes: attributes.producers)
        editors.configure(attributes: attributes.editors)
        cinematographers.configure(attributes: attributes.cinematographers)
        musicComposers.configure(attributes: attributes.musicComposers)
        screenWriters.configure(attributes: attributes.screenwriters)
    }
}
