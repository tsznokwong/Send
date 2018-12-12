//
//  MessagesTableViewController.swift
//  Send
//
//  Created by Tsznok Wong on 9/7/2016.
//  Copyright © 2016 Tsznok Wong. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class MessagesTableViewController: UITableViewController {

    var dbRef: DatabaseReference!
    var messages = [Message]()
    var userName: String = ""
    
    @IBOutlet weak var loginButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dbRef = Database.database().reference().child("messageItems")
        startObeservingDB()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                self.loginButton.title = "Logout"
                print("Welcome \(user.email!)")
                self.userName = (user.email?.components(separatedBy: CharacterSet.init(charactersIn: "@")).first)!
                self.startObeservingDB()
                
            } else {
                self.loginButton.title = "Login"
                print("You need to login/sign up first")
            }
        }
    }
    
    @IBAction func loginAndSignUp(_ sender: AnyObject) {
        if userName == "" {
            let userAlert = UIAlertController(title: "Login / Sign Up", message: "Enter email and password", preferredStyle: .alert)
            userAlert.addTextField{
                (textField: UITextField) in
                textField.placeholder = "email"
                textField.keyboardType = .emailAddress
            }
            userAlert.addTextField{
                (textField: UITextField) in
                textField.isSecureTextEntry = true
                textField.placeholder = "password"
            }
            /* FIRAuth.auth()?.signIn(withEmail:self.EmailTF.text!, password: self.PasswordTF.text!, completion: { (user, err) in
             if let error = err {
             print(error.localizedDescription)
             } else {

             
             }
             })
             */
            userAlert.addAction(UIAlertAction(title: "Login", style: .default, handler: {
                (action: UIAlertAction) in
                let emailTextField = userAlert.textFields!.first!
                let passwordTextField = userAlert.textFields!.last!
                Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!, completion: {
                    (user, error) in
                    
                    if error != nil{
                        print(error.debugDescription)
                    } else {
                        
                        self.userName = (user?.user.email?.components(separatedBy: CharacterSet.init(charactersIn: "@")).first)!
                        self.loginButton.title = "Logout"
                    }
                })
                
            }))
            userAlert.addAction(UIAlertAction(title: "Sign Up", style: .default, handler: {
                (action: UIAlertAction) in
                let emailTextField = userAlert.textFields!.first!
                let passwordTextField = userAlert.textFields!.last!
                
                Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!, completion: {
                    (user, error) in
                    
                    if error != nil{
                        print(error.debugDescription)
                    } else {
                        self.userName = (user?.user.email?.components(separatedBy: CharacterSet.init(charactersIn: "@")).first)!
                        self.loginButton.title = "Logout"
                    }
                })
                
            }))
            
            self.present(userAlert, animated: true, completion: nil)
        } else {
            print("Try Logout")
            do{
                try Auth.auth().signOut()
                let userAlert = UIAlertController(title: "Logout", message: "Logout successfully", preferredStyle: .alert)
                userAlert.addAction(UIAlertAction(title: "Done", style: .default, handler: {
                    (action: UIAlertAction) in
                    
                }))
                self.messages.removeAll()
                self.tableView.reloadData()
                self.loginButton.title = "Login"
                self.userName = ""
                self.present(userAlert, animated: true, completion: nil)
            } catch { }
            
        }
    }
    func startObeservingDB() {
        
        dbRef.queryOrdered(byChild: "timeStamp").observe(.value, with: {
            (snapshot: DataSnapshot) in
            var newMessages = [Message]()
            for message in snapshot.children {
                let messageObj = Message(snapshot: message as! DataSnapshot)
                newMessages.append(messageObj)
            }
            self.messages = newMessages.reversed()
            self.tableView.reloadData()
            
        }) {(error) in
            //print(error.description)
        }
    }

    @IBAction func addMessage(_ sender: AnyObject) {
        let messageAlert = UIAlertController(title: "New Message", message: "Enter your message", preferredStyle: .alert)
        messageAlert.addTextField {
            (textField: UITextField) in
            textField.placeholder = "Your Message"
        }
        messageAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        messageAlert.addAction(UIAlertAction(title: "Send", style: .default, handler: {
            (action: UIAlertAction) in
           
            let messageContent = messageAlert.textFields?.first?.text
            if  messageContent != nil && messageContent != "" {
                let message = Message(content: messageContent!, sentByUser: self.userName)
                let messageRef = self.dbRef.child(messageContent!.lowercased())
                messageRef.setValue(message.toAnyObject())
            }
        }))
        
        
        self.present(messageAlert, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return messages.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let message = messages[indexPath.row]
        cell.textLabel?.text = message.content
        cell.detailTextLabel?.text = DateFormatter.localizedString(from: Date(timeIntervalSince1970: message.timeStamp), dateStyle: .short, timeStyle: .medium) + " " + message.sentByUser
        
        

        return cell
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let message = messages[indexPath.row]
            message.itemRef?.removeValue()
        }
    }
    
    
    @IBAction func clearAll(_ sender: AnyObject) {
        let clearAlert = UIAlertController(title: "Clear All", message: "Clear All Message", preferredStyle: .actionSheet)
        clearAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        clearAlert.addAction(UIAlertAction(title: "Clear All", style: .destructive, handler: {
            (action: UIAlertAction) in
            for message in self.messages {
                message.itemRef?.removeValue()
            }
            self.tableView.reloadData()
        }))
        self.present(clearAlert, animated: true, completion: nil)
    }
 
}






