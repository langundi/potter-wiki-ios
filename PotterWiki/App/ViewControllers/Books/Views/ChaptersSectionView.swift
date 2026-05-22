//
//  ChaptersSectionView.swift
//  PotterWiki
//
//  Created by Ziqa on 14/05/26.
//

import UIKit

class ChaptersSectionView: UIView {
    
    
    // MARK: - Variables
    var chapters: [ChapterModel] = [] {
        didSet { populateChapters() }
    }
    
    var onChapterTapped: ((ChapterModel) -> Void)?
    
    
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
        label.text = "Chapters"
        return label
    }()
    
    private let chapterStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.hidesWhenStopped = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        return spinner
    }()
    
    
    // MARK: - Lifecycle
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(contentStack)
        addSubview(spinner)
        contentStack.addArrangedSubview(title)
        contentStack.addArrangedSubview(chapterStack)
            
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: topAnchor),
            contentStack.bottomAnchor.constraint(equalTo: bottomAnchor),
            contentStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            chapterStack.widthAnchor.constraint(equalTo: contentStack.widthAnchor),
            
            spinner.centerYAnchor.constraint(equalTo: centerYAnchor),
            spinner.centerXAnchor.constraint(equalTo: centerXAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func populateChapters() {
        chapterStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for chapter in chapters {
            let row = ChaptersRowView(chapter: chapter)
            row.onTap = { [weak self] in
                self?.onChapterTapped?(chapter)
            }
            chapterStack.addArrangedSubview(row)
            
            let separator = UIView()
            separator.backgroundColor = .separator
            separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
            chapterStack.addArrangedSubview(separator)
        }
    }
}
