

import UIKit
import FirebaseDatabase
import FirebaseAuth

class SearchFriendPageController: UIViewController {

    @IBOutlet weak var outputUIDTextBox: UILabel!
    @IBOutlet weak var outputFriendNameTextBox: UILabel!
    @IBOutlet weak var inputSearchTextBox: UITextField!
    @IBOutlet weak var addFriendButton: UIButton!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let myUID = FIRAuth.auth()?.currentUser?.uid
    let myEmail = FIRAuth.auth()?.currentUser?.email
    var friendUID:String?
    var friendName:String?
    var friendEmail:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func searchButtonTapped(_ sender: Any) {
        fetchUser()
    }
    
    @IBAction func addFriendButtonTapped(_ sender: Any) {
        addfriend()
        dismiss(animated: true, completion: nil)
    }
    
    func addfriend(){
        //insert user data to database
        let ref = FIRDatabase.database().reference(fromURL: "https://manetchat.firebaseio.com")
        let myReference = ref.child("users").child(myUID!).child("requested").child(friendUID!)
        let friendReference = ref.child("users").child(friendUID!).child("friendRequests").child(myUID!)
        
        let dataToMyDB = [friendName,friendEmail]
        let dataToFriendDB = [appDelegate.myName,myEmail]

        myReference.setValue(dataToMyDB)
        friendReference.setValue(dataToFriendDB)
    }
    
    
    func fetchUser(){
        let referance = FIRDatabase.database().reference(fromURL: "https://manetchat.firebaseio.com")
        let email = inputSearchTextBox.text
        
        referance.child("users").queryOrdered(byChild: "email").queryEqual(toValue: email).observeSingleEvent(of:.value, with:{ (snapshot) in
            // Get user value
            print(snapshot.value!)
            if let users = snapshot.value as? Dictionary<String,AnyObject>{
                for (key, value) in users {
                    self.friendUID = key
                    if let dict = value as? Dictionary<String,AnyObject>{
                        self.friendName = dict["name"] as! String?
                        self.friendEmail = dict["email"] as! String?
                    }
                }
                self.addFriendButton.isHidden = false
                self.setOutputSearchResult(uid: self.friendUID!, name: self.friendName!)
            } else {
                self.outputFriendNameTextBox.text = ""
                self.addFriendButton.isHidden = true
                self.outputUIDTextBox.text = "Not found this email"
            }
        })
    }
    
    func setOutputSearchResult(uid:String,name:String) -> Void {
        outputUIDTextBox.text = uid
        outputFriendNameTextBox.text = name
    }
    
}
