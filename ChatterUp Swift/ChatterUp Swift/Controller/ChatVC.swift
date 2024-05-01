//
//  ChatVC.swift
//  ChatterUp Swift
//
//  Created by Supriyo Dey on 28/04/24.
//

import UIKit

class ChatVC: UIViewController {
    @IBOutlet weak var vwNavContainer: UIView!
    @IBOutlet weak var tblMessages: UITableView!
    @IBOutlet weak var vwTxtMsgContainer: UIView!
    @IBOutlet weak var constBottom: NSLayoutConstraint!
    
    private var webServerLiveUrl = "wss://techknowgraphy-chatterup.onrender.com/"
    private var webServiceLocalUrl = "ws://localhost:8080/"
    var webSocketTask: URLSessionWebSocketTask!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialUISetup()
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        tblMessages.delegate = self
        tblMessages.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tap.cancelsTouchesInView = false
        tblMessages.addGestureRecognizer(tap)
        connectWebSocket()
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        disconnectWebSocket()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func backBtnAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

//MARK: - users defined methods
extension ChatVC {
    func initialUISetup() {
        vwNavContainer.layer.cornerRadius = 20
        
        vwTxtMsgContainer.layer.borderColor = UIColor.appGrayAEAEAE.cgColor
        vwTxtMsgContainer.layer.borderWidth = 0.8
    }
    
    func connectWebSocket() {
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        webSocketTask = session.webSocketTask(with: URL(string: webServiceLocalUrl)!)
        webSocketTask.resume()
        
        receiveMessage()
    }
    
    func disconnectWebSocket() {
        webSocketTask.cancel(with: .normalClosure, reason: nil)
    }
    
    func sendMessage(message: String) {
        let message = URLSessionWebSocketTask.Message.string(message)
        webSocketTask.send(message) { error in
            if let error = error {
                print("WebSocket couldn't send message because: \(error)")
            }
        }
    }
    
    func receiveMessage() {
        webSocketTask.receive { result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    print("Received message: \(text)")
                case .data(let data):
                    print("Received data: \(data)")
                @unknown default:
                    print("Received unknown message")
                }
                self.receiveMessage() // Continue listening for messages
            case .failure(let error):
                print("WebSocket couldn't receive message because: \(error)")
            }
        }
    }
    
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardFrameInView = view.convert(keyboardFrame, from: nil)
            let intersection = view.safeAreaLayoutGuide.layoutFrame.intersection(keyboardFrameInView)
            if intersection.height > 0 {
                constBottom.constant = intersection.height+5
                UIView.animate(withDuration: 0.3) {
                    self.view.layoutIfNeeded()
                }
            }
        }
    }

    @objc func keyboardWillHide(notification: Notification) {
        constBottom.constant = 5
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }

}

//MARK: - websocket delegates
extension ChatVC: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("WebSocket did open with protocol: \(`protocol` ?? "No protocol")")
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("WebSocket did close with code: \(closeCode)")
    }
}

//MARK: - Table view delegate and datasource
extension ChatVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row % 2 == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "IncomingMsgCell", for: indexPath) as? IncomingMsgCell {
                return cell
            }
        } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "outgoingMsgCell", for: indexPath) as? outgoingMsgCell {
                return cell
            }
        }
        return UITableViewCell()
    }
}

//MARK: - handling interactivePopGestureRecognizer - back gesture
extension ChatVC: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
