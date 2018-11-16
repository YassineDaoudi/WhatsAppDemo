//
//  ChatsTableViewController.swift
//  Flash Chat
//
//  Created by Findl MAC on 24/09/2018.
//

import UIKit
import Firebase
import ChameleonFramework

class ChatsTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate {

    //MARK: -Declare instance variables here
    var chatsArray:[ChatRoom] = [ChatRoom]()
    var searchActive : Bool = false
    var filtered:[ChatRoom] = []
    let searchController = UISearchController(searchResultsController: nil)
    private lazy var toolBar: UIToolbar = {
        return UIToolbar()
    }()
    private var toolBarConstraints = [NSLayoutConstraint]()
    private var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
    var currentState: Bool = false
    private var toolBarYPos: CGFloat {
        if currentState == false {
            return screenHeight
        }
            // Ideally check for other states here, but since we only have two, keep it
            // simple; would do something like: else if currentState == .edit {
        else {
            return screenHeight - toolBar.frame.height
        }
    }
    
    //MARK: - IBOutlet
    @IBOutlet weak var chatTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

     
        

        navigationController!.isToolbarHidden = true
        
        view.addSubview(toolBar)
        toolBar.translatesAutoresizingMaskIntoConstraints = false
        toolBarConstraints.append(contentsOf: [
            toolBar.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            toolBar.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            toolBar.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            toolBar.topAnchor.constraint(equalTo: (navigationController?.tabBarController?.tabBar.topAnchor)!)
            ])
        
        
        self.definesPresentationContext = true
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false

        
        //Retrieve the data from DB
        
        let currentUserEmail = Auth.auth().currentUser?.email
        
        let messageDB = Database.database().reference().child("Messages")
        
        messageDB.observe(.childAdded) { (snapshot) in
            let snapshotValue = snapshot.value as! Dictionary<String,Any>
            
            let text = snapshotValue["MessageBody"]! as! String

            let sender = snapshotValue["Sender"]! as! String
            
            let time = snapshotValue["Time"]! as! String

            
           // if currentUserEmail != sender {
                
            let message = ChatRoom()
                message.LastMessage = text
                message.senderName = sender
                message.Time = time
            
            self.chatsArray.append(message)
            
            //self.configureTableView()
            self.chatTableView.reloadData()
            }
       // }
        
        
        
        //TODO: Set yourself as the delegate and datasource here:
        chatTableView.delegate = self
        chatTableView.dataSource = self

        
        //TODO: Register your ChatCell.xib file here:
        chatTableView.register(UINib(nibName: "ChatCell", bundle: nil), forCellReuseIdentifier: "customChatCell")
        
     
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

      func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

      func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if(searchActive) {
            return filtered.count
        }
        return chatsArray.count
    }

    
      func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customChatCell", for: indexPath) as! CustomChatCell
        if searchActive {
            cell.senderNameLabel.text = filtered[indexPath.row].senderName
            cell.lastMessageLabel.text = filtered[indexPath.row].LastMessage
            cell.receivedTimeLabel.text = filtered[indexPath.row].Time
        } else {
            cell.senderNameLabel.text = chatsArray[indexPath.row].senderName
            cell.lastMessageLabel.text = chatsArray[indexPath.row].LastMessage
            cell.receivedTimeLabel.text = chatsArray[indexPath.row].Time
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      performSegue(withIdentifier: "goToChat", sender: self)
    }
    
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        filtered = chatsArray.filter({ (text) -> Bool in
            let tmp: NSString = text.senderName as NSString
            let range = tmp.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
            return range.location != NSNotFound
        })
        if(filtered.count == 0){
            searchActive = false;
        } else {
            searchActive = true;
        }
        self.chatTableView.reloadData()
    }
 
    
    
    @IBAction func onEditBtnTouchUp(_ sender: UIBarButtonItem) {
        
        // Switch to the editing mode
        if currentState == false {
            currentState = true

           // fade(navigationController?.tabBarController?.tabBar, toAlpha: 0, withDuration: 0.2, andHide: true)
            UIView.animate(withDuration: 0.2, animations: {
                // Set edit to done
                self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self,
                                                                        action: #selector(self.onDoneBtnTouchUp))
                // Fade away + btn
//                self.plusBtn.isEnabled = false
//                self.plusBtn.tintColor = UIColor.clear
                
                // Position the toolbar
                self.toolBar.frame.origin.y = self.toolBarYPos
            })
        }
        
    }
    
    @objc func onDoneBtnTouchUp(_ sender: Any) {
        // Switch to normal state
        if currentState == true {
            currentState = false

//            fade(tabBar, toAlpha: 1, withDuration: 0.2, andHide: false)
            UIView.animate(withDuration: 0.2, animations: {
                // Set edit to done
                self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self,
                                                                        action: #selector(self.onEditBtnTouchUp))
                
                // Fade in + btn
//                self.plusBtn.isEnabled = true
//                self.plusBtn.tintColor = nil
                
                // Position the toolbar
                self.toolBar.frame.origin.y = self.toolBarYPos
            })
        }
 
    
    }

}
