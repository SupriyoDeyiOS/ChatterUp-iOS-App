//
//  UIViewController+Alert.swift
//  ChatterUp Swift
//
//  Created by Supriyo Dey on 05/05/24.
//

import Foundation
import UIKit

//'Ok' action default alert to show message with no action.
extension UIViewController {
    func showAlert(withMsg: String) {
        let alert = UIAlertController(title: withMsg, message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
        alert.view.tintColor = UIColor.appGreenThree007212
        self.present(alert, animated: true)
    }
    
    func showAlertWithAction(msg: String, completion: @escaping () -> Void) {
        let alert = UIAlertController(title: msg, message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { _ in
            completion()
        }))
        alert.view.tintColor = UIColor.appGreenThree007212
        self.present(alert, animated: true)
    }
    
}
