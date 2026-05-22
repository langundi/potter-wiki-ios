//
//  ChapterDetailSheet.swift
//  PotterWiki
//
//  Created by Ziqa on 14/05/26.
//

import UIKit

class ChapterDetailSheet: UIViewController {

    // MARK: - Variables
    var chapter: ChapterModel
    
    
    // MARK: - UI Components
    private let chapterTitle: UILabel = {
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
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var summary: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.numberOfLines = 0
        label.textColor = .label
        label.textAlignment = .justified
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    // MARK: - Lifecycle
    init(chapter: ChapterModel) {
        self.chapter = chapter
        self.chapterTitle.text = chapter.attributes.title
        self.summary.text = chapter.attributes.summary
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(dismissSheet)
        )
        navigationItem.title = ""
        setupUI()
    }
    
    
    // MARK: - UI Setup
    private func setupUI() {
        view.addSubview(chapterTitle)
        view.addSubview(summary)
        
        NSLayoutConstraint.activate([
            chapterTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            chapterTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            chapterTitle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            summary.topAnchor.constraint(equalTo: chapterTitle.bottomAnchor, constant: 20),
            summary.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            summary.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }
    
    
    // MARK: - Selector
    @objc private func dismissSheet() {
        dismiss(animated: true)
    }
}
