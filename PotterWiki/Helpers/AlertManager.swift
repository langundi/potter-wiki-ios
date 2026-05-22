//
//  AlertManager.swift
//  PotterWiki
//
//  Created by Ziqa on 21/05/26.
//

import UIKit

final class AlertManager {
    
    static let shared = AlertManager()
    init() { }
    
    func showAlert(
        on vc: UIViewController,
        title: String? = nil,
        message: String,
        showCancel: Bool = false,
        action: (() -> Void)? = nil
    ) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        if let action {
            let confirmAction = UIAlertAction(title: "OK", style: .default) { _ in
                action()
            }
            alert.addAction(confirmAction)
        } else {
            alert.addAction(UIAlertAction(title: "OK", style: .default))
        }
        
        if showCancel {
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        }
        
        vc.present(alert, animated: true)
    }
    
    func showAlert(on vc: UIViewController, for error: Error) {
        showAlert(on: vc, title: "An error occured", message: error.localizedDescription)
    }
    
    func showGeneralAlert(on vc: UIViewController) {
        showAlert(on: vc, message: "An unexpected issue occured. Please try again later.")
    }
    
}
