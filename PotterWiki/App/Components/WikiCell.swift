//
//  WikiCell.swift
//  PotterWiki
//
//  Created by Ziqa on 07/05/26.
//

import UIKit
import Kingfisher

final class WikiCell: UICollectionViewCell {
    
    // MARK: - Variables
    static let identifier = "WikiCell"
    static var labelHeight: CGFloat {
        let font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        let lineHeight = font.lineHeight
        return (lineHeight * 2) + 4  // 2 lines + line spacing
    }
    static var itemWidth: CGFloat {
        (UIScreen.main.bounds.width - 32 - 16) / 2
    }
    static var itemHeight: CGFloat {
        let padding: CGFloat = 16
        return itemWidth + labelHeight + padding
    }
    
    
    // MARK: - UI Components
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.tintColor = .systemGray
        iv.backgroundColor = .systemGray4
        iv.clipsToBounds = true
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.hidesWhenStopped = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        return spinner
    }()
    
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.kf.cancelDownloadTask()
        imageView.image = nil
        spinner.stopAnimating()
    }
    
    // MARK: - UI Setup
    private func setup() {
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds = true
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(spinner)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8),
            
            spinner.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
        ])
    }
    
    func configure(title: String, imageURL: URL?) {
        titleLabel.text = title
        
        spinner.startAnimating()
        
        if imageURL != nil {
            imageView.kf.setImage(
                with: imageURL,
                options: [
                    .transition(.fade(0.2)),
                    .cacheOriginalImage
                ]) { [weak self] _ in
                    self?.spinner.stopAnimating()
                }
        } else {
            spinner.stopAnimating()
            imageView.image = .none
        }
    }
}
