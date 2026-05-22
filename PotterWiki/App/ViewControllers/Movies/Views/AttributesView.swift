//
//  AttributesView.swift
//  PotterWiki
//
//  Created by Ziqa on 16/05/26.
//

import UIKit

class AttributesView: UIView {
    
    
    // MARK: - UI Components
    private let attributeTitle: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let attributeStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 2
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    
    // MARK: - Lifecycle
    init(title: String) {
        super.init(frame: .zero)
        attributeTitle.text = title
        
        addSubview(attributeTitle)
        addSubview(attributeStack)
        attributeTitle.setContentCompressionResistancePriority(.required, for: .horizontal)
        attributeStack.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        NSLayoutConstraint.activate([
            attributeTitle.topAnchor.constraint(equalTo: topAnchor),
            attributeTitle.leadingAnchor.constraint(equalTo: leadingAnchor),
            
            attributeStack.topAnchor.constraint(equalTo: topAnchor),
            attributeStack.leadingAnchor.constraint(equalTo: attributeTitle.trailingAnchor, constant: 4),
            attributeStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            attributeStack.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(attributes: [String]) {
        if attributes.isEmpty {
            let label = UILabel()
            label.text = "-"
            label.textColor = .systemGray
            label.textAlignment = .left
            label.font = .systemFont(ofSize: 16, weight: .regular)
            label.translatesAutoresizingMaskIntoConstraints = false
            attributeStack.addArrangedSubview(label)
        } else {
            for attribute in attributes {
                var row: UILabel {
                    let label = UILabel()
                    label.text = attribute
                    label.textColor = .systemGray
                    label.numberOfLines = 0
                    label.textAlignment = .left
                    label.font = .systemFont(ofSize: 16, weight: .regular)
                    label.translatesAutoresizingMaskIntoConstraints = false
                    return label
                }
                attributeStack.addArrangedSubview(row)
            }
        }
    }
}
