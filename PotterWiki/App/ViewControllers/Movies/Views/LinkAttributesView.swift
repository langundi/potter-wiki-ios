//
//  LinkAttributesView.swift
//  PotterWiki
//
//  Created by Ziqa on 16/05/26.
//

import UIKit

class LinkAttributesView: UIView {
    
    
    // MARK: - UI Components
    private let attributeTitle: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let link: UITextView = {
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
    
    
    // MARK: - Lifecycle
    init(title: String) {
        super.init(frame: .zero)
        attributeTitle.text = title
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleLinkTap))
        link.addGestureRecognizer(tap)
        
        addSubview(attributeTitle)
        addSubview(link)
        
        NSLayoutConstraint.activate([
            attributeTitle.topAnchor.constraint(equalTo: topAnchor),
            attributeTitle.leadingAnchor.constraint(equalTo: leadingAnchor),
            
            link.topAnchor.constraint(equalTo: topAnchor),
            link.leadingAnchor.constraint(equalTo: attributeTitle.trailingAnchor, constant: 8),
            link.trailingAnchor.constraint(equalTo: trailingAnchor),
            link.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        
        self.link.attributedText = attributed
    }
    
    @objc private func handleLinkTap() {
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }
}
