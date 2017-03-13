

import UIKit
import FirebaseDatabase
import FirebaseAuth

class SearchFriendPageController: UIViewController {

    @IBOutlet weak var notFoundLabel: UILabel!
    @IBOutlet weak var outputFriendNameTextBox: UILabel!
    @IBOutlet weak var inputSearchTextBox: UITextField!
    @IBOutlet weak var addFriendButton: UIButton!
    
    @IBOutlet weak var friendStack: UIStackView!
    
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let myUID = FIRAuth.auth()?.currentUser?.uid
    let myEmail = FIRAuth.auth()?.currentUser?.email
    var friendUID:String?
    var friendName:String?
    var friendEmail:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func setup(){
        friendStack.isHidden = true
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func searchButtonTapped(_ sender: Any) {
        fetchUser()
    }

    @IBAction func addButtonTapped(_ sender: Any) {
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
                self.friendStack.isHidden = false
                self.notFoundLabel.isHidden = true
                self.setOutputSearchResult(name: self.friendName!)
                
            } else {
                self.notFoundLabel.isHidden = false
                self.friendStack.isHidden = true
            }
        })
    }
    
    func setOutputSearchResult(name:String) -> Void {
        outputFriendNameTextBox.text = name
    }
    
}
