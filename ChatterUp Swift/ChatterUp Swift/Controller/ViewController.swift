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
    @IBOutlet weak var txtUserName: UITextField!
    
    var userId = UUID().uuidString //create userId only once on app opening
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialUISetup()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        print(userId)
    }

    @IBAction func joinBtnAction(_ sender: UIButton) {
        txtUserName.resignFirstResponder()
        if txtUserName.text?.isEmpty == true {
            showAlert(withMsg: "Please enter your name.")
        } else {
            if let chatVc = self.storyboard?.instantiateViewController(withIdentifier: "ChatVC") as? ChatVC {
                chatVc.userName = txtUserName.text ?? "Unknown"
                chatVc.userId = userId
                self.navigationController?.pushViewController(chatVc, animated: true)
            }
        }
    }
    
}

//MARK: - user defined methods
extension ViewController {
    func initialUISetup() {
        vwTxtContainer.layer.cornerRadius = 10
        vwNameFormContainer.layer.shadowOpacity = 0.2
        vwNameFormContainer.layer.shadowRadius = 5
        vwNameFormContainer.layer.shadowColor = UIColor.black.cgColor
        vwNameFormContainer.layer.shadowOffset = CGSize(width: 0, height: 2)
        
        vwTxtContainer.layer.borderColor = UIColor.appGrayAEAEAE.cgColor
        vwTxtContainer.layer.borderWidth = 0.8
        vwTxtContainer.layer.cornerRadius = 10
        
        btnJoin.layer.cornerRadius = 10
    }
}
