//
//  ViewController.swift
//  ChatterUp Swift
//
//  Created by Supriyo Dey on 28/04/24.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var vwNameFormContainer: UIView!
    @IBOutlet weak var vwTxtContainer: UIView!
    @IBOutlet weak var btnJoin: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialUISetup()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    func initialUISetup() {
        vwTxtContainer.layer.cornerRadius = 10
        vwNameFormContainer.layer.shadowOpacity = 0.25
        vwNameFormContainer.layer.shadowRadius = 5
        vwNameFormContainer.layer.shadowColor = UIColor.black.cgColor
        vwNameFormContainer.layer.shadowOffset = CGSize(width: 0, height: 2)
        
        vwTxtContainer.layer.borderColor = UIColor.appGrayAEAEAE.cgColor
        vwTxtContainer.layer.borderWidth = 1
        vwTxtContainer.layer.cornerRadius = 10
        
        btnJoin.layer.cornerRadius = 10
    }
}

