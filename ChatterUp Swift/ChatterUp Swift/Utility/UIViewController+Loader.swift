//
//  UIViewController+Loader.swift
//  ChatterUp Swift
//
//  Created by Supriyo Dey on 05/05/24.
//

import Foundation
import UIKit

extension UIViewController {
    func addLoader(msg: String) -> UIView {
        let containerView = UIView(frame: UIScreen.main.bounds)
        containerView.backgroundColor = UIColor(white: 0, alpha: 0)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        let loaderView = UIView()
        loaderView.backgroundColor = .white
        loaderView.layer.cornerRadius = 10
        loaderView.layer.shadowColor = UIColor.black.cgColor
        loaderView.layer.shadowOpacity = 0.5
        loaderView.layer.shadowOffset = CGSize(width: 0, height: 0)
        loaderView.layer.shadowRadius = 8
        loaderView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(loaderView)
        
        let loadingIndicator = UIActivityIndicatorView(style: .medium)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loaderView.addSubview(loadingIndicator)
        
        let label = UILabel()
        label.text = msg
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        loaderView.addSubview(label)
        
        loadingIndicator.centerXAnchor.constraint(equalTo: loaderView.centerXAnchor).isActive = true
        loadingIndicator.topAnchor.constraint(equalTo: loaderView.topAnchor, constant: 20).isActive = true
        
        label.centerXAnchor.constraint(equalTo: loaderView.centerXAnchor).isActive = true
        label.topAnchor.constraint(equalTo: loadingIndicator.bottomAnchor, constant: 10).isActive = true
        label.bottomAnchor.constraint(equalTo: loaderView.bottomAnchor, constant: -20).isActive = true
        
        loaderView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        loaderView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        loaderView.widthAnchor.constraint(equalToConstant: 180).isActive = true
        
        loadingIndicator.startAnimating()
        
        self.view.addSubview(containerView)
        
        containerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        return containerView
    }
    
    func removeLoader(loader: UIView, completion: @escaping () -> Void) {
        loader.removeFromSuperview()
        completion()
    }
}
