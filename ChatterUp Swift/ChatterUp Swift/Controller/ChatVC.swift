//
//  ChatVC.swift
//  ChatterUp Swift
//
//  Created by Supriyo Dey on 28/04/24.
//

import UIKit

class ChatVC: UIViewController {
    @IBOutlet weak var vwNavContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialUISetup()
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    @IBAction func backBtnAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

//MARK: - users defined methods
extension ChatVC {
    func initialUISetup() {
        vwNavContainer.layer.cornerRadius = 20
    }
}

//MARK: - handling interactivePopGestureRecognizer - back gesture
extension ChatVC: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
