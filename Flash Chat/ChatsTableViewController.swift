//
//  ChatsTableViewController.swift
//  Flash Chat
//
//  Created by Findl MAC on 24/09/2018.
//

import UIKit
import Firebase

class ChatsTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate {

    // Declare instance variables here
    var chatsArray: [ChatRoom] = [ChatRoom]()
    var searchActive : Bool = false
    var filtered:[ChatRoom] = []

    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var chatTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()


        
        
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(),for:.default)
        
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
        searchBar.delegate = self

        
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
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    

}
