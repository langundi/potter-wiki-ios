//
//  AppButton.swift
//  PotterWiki
//
//  Created by Ziqa on 10/05/26.
//

import UIKit

final class AppButton: UIButton {
    
    enum ButtonStyle {
        case primary
        case secondary
    }
    
    private let overlayView = UIView()
    
    init(style: ButtonStyle, title: String, icon: String? = nil) {
        super.init(frame: .zero)
        setupConfiguration(style: style, title: title, icon: icon)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Button
    private func setupConfiguration(style: ButtonStyle, title: String, icon: String? = nil) {
        var config: UIButton.Configuration
        
        switch style {
        case .primary:
            config = .filled()
            config.baseBackgroundColor = .systemPink
            config.baseForegroundColor = .white
        case .secondary:
            config = .plain()
            config.baseForegroundColor = .systemPink
            config.background.backgroundColor = .clear
            config.background.strokeColor = .systemPink
            config.background.strokeWidth = 1.5
        }
        config.title = title
        config.cornerStyle = .capsule
//        config.buttonSize = .large
        
        if let icon {
            config.image = UIImage(systemName: icon)
            config.imagePlacement = .leading
            config.imagePadding = 8
        }
        
        self.configuration = config
        self.clipsToBounds = true
        // Disable OnPressed default animations
        self.configurationUpdateHandler = nil
        self.automaticallyUpdatesConfiguration = false
        // Button height
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 55).isActive = true
        
        // OnPressed Button Overlay
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        overlayView.isUserInteractionEnabled = false
        overlayView.alpha = 0
        addSubview(overlayView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        overlayView.frame = bounds
    }
    
    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.15) {
                self.overlayView.alpha = self.isHighlighted ? 1.0 : 0.0
                self.transform = self.isHighlighted ? CGAffineTransform(scaleX: 0.97, y: 0.97) : .identity
            }
        }
    }
}
