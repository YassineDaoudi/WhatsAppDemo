//
//  ViewController.swift
//  Flash Chat
//
//  Created by Angela Yu on 29/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import Firebase
import ChameleonFramework
import Speech


class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, SFSpeechRecognizerDelegate {
    
    // Declare instance variables here
    var messageArray: [Message] = [Message]()
    var cameraState:Bool = true
    let audioEngine = AVAudioEngine()
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()
    let request = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask: SFSpeechRecognitionTask?
    

    // We've pre-linked the IBOutlets
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var messageTableView: UITableView!

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = Auth.auth().currentUser?.email
        
        messageTableView.backgroundView = UIImageView(image: UIImage(named: "chat-backgroundImage"))
        
        //TODO: Set yourself as the delegate and datasource here:
        messageTableView.delegate = self
        messageTableView.dataSource = self
        
        
        //TODO: Set yourself as the delegate of the text field here:
        messageTextfield.delegate = self
        
        
        //TODO: Set the tapGesture here:
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        messageTableView.addGestureRecognizer(tapGesture)
        

        //TODO: Register your MessageCell.xib file here:
        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")
      
        configureTableView()
        
        retrieveMessages()
        
        messageTableView.separatorStyle = .none
        
        
    }

    ///////////////////////////////////////////
    
    //MARK: - TableView DataSource Methods
    
    
    
    //TODO: Declare cellForRowAtIndexPath here:
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
        cell.messageBody.text = messageArray[indexPath.row].messageBody
        cell.messageTameLabel.text = messageArray[indexPath.row].time
        //cell.avatarImageView.image = UIImage(named: "phoenix")
        cell.setTransparent()
        cell.messageBackground.backgroundColor = UIColor.flatWhiteColorDark()
//        if cell.senderUsername.text == Auth.auth().currentUser?.email{
//
//            //Messages we sent
//
//
//        } else {
//            cell.messageBackground.backgroundColor = UIColor.flatWhiteColorDark()
//        }
        
        return cell
    }
    
    
    //TODO: Declare numberOfRowsInSection here:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    
    //TODO: Declare tableViewTapped here:
    @objc func tableViewTapped () {
        messageTextfield.endEditing(true)
    }
    
    
    //TODO: Declare configureTableView here:
    func configureTableView() {
        messageTableView.rowHeight = UITableView.automaticDimension
        messageTableView.estimatedRowHeight = 120.0
    }
    
    
    ///////////////////////////////////////////
    
    //MARK:- TextField Delegate Methods
   

    
    //TODO: Declare textFieldDidBeginEditing here:
    func textFieldDidBeginEditing(_ textField: UITextField) {
    sendButton.setImage(nil, for: .normal)
    sendButton.setTitle("Send", for: UIControl.State.normal)
    cameraState = false
     UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 308
            self.view.layoutIfNeeded()
        }
    }
    
    
    
    //TODO: Declare textFieldDidEndEditing here:
    func textFieldDidEndEditing(_ textField: UITextField) {
        sendButton.setImage(UIImage(named: "black_photo_btn"), for: UIControl.State.normal)
        sendButton.setTitle("", for: UIControl.State.normal)
        cameraState = true
        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 50
            self.view.layoutIfNeeded()
        }
    }

    
    ///////////////////////////////////////////
    
    
    //MARK: - Send & Recieve from Firebase

    @IBAction func sendPressed(_ sender: AnyObject) {
        
        if cameraState == false {
            messageTextfield.endEditing(true)
            
            //TODO: Send the message to Firebase and save it in our database
            
            messageTextfield.isEnabled = false
            sendButton.isEnabled = false
            
            let messagesDB = Database.database().reference().child("Messages")
            
            let now = Date()
            
            let formatter = DateFormatter()
            
            formatter.timeZone = TimeZone.current
            
            formatter.dateFormat = "HH:mm"
            
            let dateString = formatter.string(from: now)
            
            
            
            let messageDictionary = ["Sender": Auth.auth().currentUser?.email!,
                                     "MessageBody": messageTextfield.text!,
                                     "Time": dateString] as [String : Any]
            
            messagesDB.childByAutoId().setValue(messageDictionary) {
                (error, refrence) in
                if error != nil {
                    print(error!)
                } else {
                    print("Message saved successfully!")
                    self.messageTextfield.isEnabled = true
                    self.sendButton.isEnabled = true
                    self.messageTextfield.text = " "
                }
            }
        } else if cameraState == true {
            
            let imagePickerController = UIImagePickerController()
            
            imagePickerController.delegate = self
            
            imagePickerController.sourceType = UIImagePickerController.SourceType.camera
            
            imagePickerController.allowsEditing = true
            
            self.present(imagePickerController, animated: true, completion: nil)
        }
        
    }
    
    //TODO: Create the retrieveMessages method here:
    func retrieveMessages() {
        
        let messageDB = Database.database().reference().child("Messages")
        
        messageDB.observe(.childAdded) { (snapshot) in
           let snapshotValue = snapshot.value as! Dictionary<String,Any>
            
            let text = snapshotValue["MessageBody"]!
            let sender = snapshotValue["Sender"]!
            let time = snapshotValue["Time"]!
            
           
            
           
            
            let message = Message()
            message.messageBody = text as! String
            message.sender = sender as! String
            message.time  = time as! String
            
            self.messageArray.append(message)
            
            self.configureTableView()
            self.messageTableView.reloadData()
        }
    }
    
    func recordAndRecognizeSpeech() {
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer,_ in
            self.request.append(buffer)
        }
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            return print(error)
        }
        
        guard let myRecognizer = SFSpeechRecognizer() else {
            // A recognizer is not supported for the current locale
            return
        }
        if !myRecognizer.isAvailable {
            // A recognizer is not available right now
            return
        }
        
        recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: { (result, error) in
            
            if let result = result {
                _ =  result.bestTranscription.formattedString
            } else if let error = error {
                print(error)
            }
            
        }
        
    )}

    @IBAction func micButton(_ sender: Any) {
        
        recordAndRecognizeSpeech()
        
    }
    
    
    
    @IBAction func logOutPressed(_ sender: AnyObject) {
        
        //TODO: Log out the user and send them back to WelcomeViewController
       
        do {
            try  Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch {
            print("error, there was a problem signing out.")
        }
    }
    


}
