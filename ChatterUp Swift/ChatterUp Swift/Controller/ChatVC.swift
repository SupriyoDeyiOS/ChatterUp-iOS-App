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
    @IBOutlet weak var txtMessage: UITextField!
    @IBOutlet weak var btnCamera: UIButton!
    @IBOutlet weak var svwPickedImgOuter: UIStackView!
    @IBOutlet weak var imgPickedImage: UIImageView!
    @IBOutlet weak var vwPickedImgInnerContainer: UIView!
    
    private var webServerLiveUrl = "wss://techknowgraphy-chatterup.onrender.com/"
    private var webServiceLocalUrl = "ws://localhost:8080/"
    lazy private var baseUrl = webServerLiveUrl  //change url here
    
    var userName: String = ""
    var userId: String = ""
    private var webSocketTask: URLSessionWebSocketTask!
    private let imagePicker = UIImagePickerController()
    private var pickedImage: UIImage?
    private var loader: UIView = UIView()
    
    private var messages: [MessageDataModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialUISetup()
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        tblMessages.delegate = self
        tblMessages.dataSource = self
        imagePicker.delegate = self
        
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
    @IBAction func sendBtnAction(_ sender: UIButton) {
        if txtMessage.text?.isEmpty == false || pickedImage != nil {
            sendMessage()
        }
    }
    @IBAction func pickImgBtnAction(_ sender: UIButton) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Choose from Library", style: .default) { _ in
            self.showImagePicker(sourceType: .photoLibrary)
        })
        
        actionSheet.addAction(UIAlertAction(title: "Take Photo", style: .default) { _ in
            self.showImagePicker(sourceType: .camera)
        })
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        actionSheet.popoverPresentationController?.sourceView = sender
        actionSheet.popoverPresentationController?.sourceRect = sender.bounds
        actionSheet.view.tintColor = UIColor.accent
        present(actionSheet, animated: true, completion: nil)
    }
    @IBAction func removePickedImgBtnAction(_ sender: UIButton) {
        resetPickedImg()
    }
    
}

//MARK: - users defined methods
extension ChatVC {
    func initialUISetup() {
        resetPickedImg()
        vwNavContainer.layer.cornerRadius = 15
        
        vwTxtMsgContainer.layer.borderColor = UIColor.appGrayAEAEAE.cgColor
        vwTxtMsgContainer.layer.borderWidth = 0.8
    }
    
    func showImagePicker(sourceType: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            imagePicker.sourceType = sourceType
            imagePicker.allowsEditing = false
            present(imagePicker, animated: true, completion: nil)
        } else {
            print("Selected source type is not available")
        }
    }
    
    func resetPickedImg() {
        pickedImage = nil
        vwPickedImgInnerContainer.isHidden = true
        svwPickedImgOuter.isHidden = true
        imgPickedImage.image = nil
        btnCamera.isHidden = false
    }
    
    func connectWebSocket() {
        loader = self.addLoader(msg: "Joining...")
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        webSocketTask = session.webSocketTask(with: URL(string: baseUrl)!)
        webSocketTask.maximumMessageSize = 20 * 1024 * 1024
        webSocketTask.resume()
        
        receiveMessage()
    }
    
    func disconnectWebSocket() {
        webSocketTask.cancel(with: .normalClosure, reason: nil)
    }
    
    func sendMessage() {
        let dataToSend = MessageResponseModel(action: "message", data: MessageDataModel(sender: self.userName, senderId: self.userId, id: UUID().uuidString, message: txtMessage.text ?? "", image: pickedImage?.jpegData(compressionQuality: 0.5)?.base64EncodedString(), deleteId: nil))
        
        // Encode to JSON
        do {
            let jsonEncoder = JSONEncoder()
            let jsonData = try jsonEncoder.encode(dataToSend)
            
            resetPickedImg()
            self.txtMessage.text = ""
            self.messages.append(dataToSend.data!)
            self.tblMessages.reloadData()
            // Scroll to the bottom
            let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
            self.tblMessages.scrollToRow(at: indexPath, at: .bottom, animated: true)
            
            // Send the JSON data over WebSocket
            let message = URLSessionWebSocketTask.Message.data(jsonData)
            webSocketTask.send(message) { error in
                if let error = error {
                    //TODO: - Resend the message if not send
                    print("WebSocket couldn't send message because: \(error)")
                }
            }
            
        } catch {
            print("Error encoding JSON data: \(error)")
        }
    }
    
    func sendDeleteMessage(msgOfIndex: Int) {
        let dataToSend = MessageResponseModel(action: "delete", data: MessageDataModel(sender: nil, senderId: nil, id: nil, message: nil, image: nil, deleteId: messages[msgOfIndex].id))
        do {
            let jsonEncoder = JSONEncoder()
            let jsonData = try jsonEncoder.encode(dataToSend)
            
            let message = URLSessionWebSocketTask.Message.data(jsonData)
            webSocketTask.send(message) { error in
                DispatchQueue.main.async {
                    self.messages.remove(at: msgOfIndex)
                    self.tblMessages.reloadData()
                }
                if let error = error {
                    print("WebSocket couldn't send message because: \(error)")
                }
            }
        } catch {
            print("Error encoding JSON data: \(error)")
        }
    }
    
    func receiveMessage() {
        webSocketTask.receive { result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    print("Received message: \(text)")
                    if let jsonData = text.data(using: .utf8) {
                        self.showReceivedMessage(jsonData: jsonData)
                    } else {
                        print("Failed to convert received message to data")
                    }
                case .data(let data):
                    print("Received data: \(data)")
                    self.showReceivedMessage(jsonData: data)
                @unknown default:
                    print("Received unknown message")
                }
                self.receiveMessage() // Continue listening for messages
            case .failure(let error):
                print("WebSocket couldn't receive message because: \(error)")
            }
        }
    }
    
    func showReceivedMessage(jsonData: Data) {
        do {
            let decodedData = try JSONDecoder().decode(MessageResponseModel.self, from: jsonData)
            print("Decoded message: \(decodedData)")
            if decodedData.action == "message" {
                if let msgData = decodedData.data {
                    DispatchQueue.main.async {
                        self.messages.append(msgData)
                        self.tblMessages.reloadData()
                        // Scroll to the bottom
                        let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                        self.tblMessages.scrollToRow(at: indexPath, at: .bottom, animated: true)
                    }
                }
            } else if decodedData.action == "delete" {
                if let deleteIndex = self.messages.firstIndex(where: {$0.id == decodedData.data?.deleteId}) {
                    DispatchQueue.main.async {
                        self.messages.remove(at: deleteIndex)
                        self.tblMessages.reloadData()
                    }
                }
            }
        } catch {
            print("Error decoding JSON: \(error)")
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

    @objc private func handleLongPress(_ gestureRecognizer: CustomLongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            actionSheet.addAction(UIAlertAction(title: "Copy Message", style: .default, handler: { _ in
                UIPasteboard.general.string = self.messages[gestureRecognizer.rowNumber].message ?? ""
            }))
            
            actionSheet.addAction(UIAlertAction(title: "Delete from me", style: .destructive, handler: { _ in
                self.messages.remove(at: gestureRecognizer.rowNumber)
                self.tblMessages.reloadData()
            }))
            
            if messages[gestureRecognizer.rowNumber].senderId == self.userId {
                actionSheet.addAction(UIAlertAction(title: "Delete from everyone", style: .destructive, handler: { _ in
                    self.sendDeleteMessage(msgOfIndex: gestureRecognizer.rowNumber)
                }))
            }
            
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
            actionSheet.popoverPresentationController?.sourceView = gestureRecognizer.view
            actionSheet.popoverPresentationController?.sourceRect = gestureRecognizer.view?.bounds ?? CGRect(x: 100, y: 100, width: 10, height: 10)
            actionSheet.view.tintColor = UIColor.accent
            
            self.present(actionSheet, animated: true)
        }
    }
}

//MARK: - websocket delegates
extension ChatVC: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        DispatchQueue.main.async {
            self.removeLoader(loader: self.loader) {}
        }
        print("WebSocket did open with protocol: \(`protocol` ?? "No protocol")")
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("WebSocket did close with code: \(closeCode)")
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: (any Error)?) {
        DispatchQueue.main.async {
            self.removeLoader(loader: self.loader) {}
            self.showAlertWithAction(msg: "Sorry, can't proceed now. Try again later.") {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: (any Error)?) {
        DispatchQueue.main.async {
            self.removeLoader(loader: self.loader) {}
            self.showAlertWithAction(msg: "Sorry, can't proceed now. Try again later.") {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}

//MARK: - Table view delegate and datasource
extension ChatVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if messages[indexPath.row].senderId == userId {
            //outgoing message
            if let cell = tableView.dequeueReusableCell(withIdentifier: "outgoingMsgCell", for: indexPath) as? outgoingMsgCell {
                cell.longPressGesture.rowNumber = indexPath.row
                cell.longPressGesture = CustomLongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
                cell.contentView.addGestureRecognizer(cell.longPressGesture)
                cell.lblMessage.text = messages[indexPath.row].message ?? ""
                if let imageBaseStr = messages[indexPath.row].image, let imgData = Data(base64Encoded: imageBaseStr), let image = UIImage(data: imgData) {
                    cell.setImage(with: image)
                } else {
                    cell.setImage(with: nil)
                }
                return cell
            }
        } else {
            //incoming message
            if let cell = tableView.dequeueReusableCell(withIdentifier: "IncomingMsgCell", for: indexPath) as? IncomingMsgCell {
                cell.longPressGesture.rowNumber = indexPath.row
                cell.longPressGesture = CustomLongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
                cell.contentView.addGestureRecognizer(cell.longPressGesture)
                cell.lblMessage.text = messages[indexPath.row].message ?? ""
                cell.lblSender.text = "~ \(messages[indexPath.row].sender ?? "Unknown")"
                if let imageBaseStr = messages[indexPath.row].image, let imgData = Data(base64Encoded: imageBaseStr), let image = UIImage(data: imgData) {
                    cell.setImage(with: image)
                } else {
                    cell.setImage(with: nil)
                }
                return cell
            }
        }
        return UITableViewCell()
    }
}

//MARK: - image picker delegates
extension ChatVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            // imageView.image = pickedImage
            print("point 3.0 --> ", pickedImage)
            self.pickedImage = pickedImage
            self.svwPickedImgOuter.isHidden = false
            self.imgPickedImage.image = pickedImage
            self.vwPickedImgInnerContainer.isHidden = false
            self.btnCamera.isHidden = true

        }
        
        dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - handling interactivePopGestureRecognizer - back gesture
extension ChatVC: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
