//
//  ChaptersRowView.swift
//  PotterWiki
//
//  Created by Ziqa on 14/05/26.
//

import UIKit

class ChaptersRowView: UIView {
        
    // MARK: - Variables
    var onTap: (() -> Void)?
    
    
    // MARK: - UI Components
    private let orderNumber: UILabel = {
        let label = UILabel()
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 16, weight: .regular)
        label.textColor = .systemGray
        label.textAlignment = .left
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let chapterTitle: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let chevron: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "chevron.right"))
        iv.tintColor = .systemGray
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    
    // MARK: - Lifecycle
    init(chapter: ChapterModel) {
        super.init(frame: .zero)
        orderNumber.text = String(chapter.attributes.order) + "."
        chapterTitle.text = chapter.attributes.title
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - UI Setup
    private func setupUI() {
        addSubview(orderNumber)
        addSubview(chapterTitle)
        addSubview(chevron)
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 72),
            
            orderNumber.leadingAnchor.constraint(equalTo: leadingAnchor),
            orderNumber.centerYAnchor.constraint(equalTo: centerYAnchor),
            orderNumber.widthAnchor.constraint(equalToConstant: 40),
            
            chevron.trailingAnchor.constraint(equalTo: trailingAnchor),
            chevron.centerYAnchor.constraint(equalTo: centerYAnchor),
            chevron.widthAnchor.constraint(equalToConstant: 12),
            
            chapterTitle.leadingAnchor.constraint(equalTo: orderNumber.trailingAnchor, constant: 12),
            chapterTitle.centerYAnchor.constraint(equalTo: centerYAnchor),
            chapterTitle.trailingAnchor.constraint(equalTo: chevron.leadingAnchor, constant: -8),
        ])
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }
    
    func configure(chapter: ChapterModel) {
        orderNumber.text = String(chapter.attributes.order)
        chapterTitle.text = chapter.attributes.title
    }
    
    
    // MARK: - Selectors
    @objc private func handleTap() { onTap?() }
}
