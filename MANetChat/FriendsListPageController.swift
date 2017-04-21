
import UIKit
import FirebaseAuth
import FirebaseDatabase

class FriendsListPageController: UIViewController, UITableViewDelegate,UITableViewDataSource {
    
    let appDeledate = UIApplication.shared.delegate as? AppDelegate
    var FirstTimeViewAppear = true
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var userDisplayName: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if FirstTimeViewAppear {
            setUpPage()
            FirstTimeViewAppear = false
            imageView.layer.cornerRadius = imageView.frame.size.width / 2
            imageView.clipsToBounds = true
        }
    }

    func setUpPage(){
        //Set display name
        userDisplayName.text = appDeledate?.myEmail
        getFriendsListFromFirebase()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendsCell", for: indexPath) as! FriendViewCell
        cell.friendName.text = appDeledate?.friends[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (appDeledate?.friends.count)!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 51
    }
    
    func getFriendsListFromFirebase(){
        if let myUID = FIRAuth.auth()?.currentUser?.uid {
            //Create listener
            let ref = FIRDatabase.database().reference().child("users").child(myUID).child("friends")
            ref.queryOrdered(byChild: "date").observe(.value, with: { (snapshot) in
                //Get friends and put it into friends in AppDelegate
                if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot]{
                    for snap in snapshot {
                        if let detail = snap.value as? [String:AnyObject] {
                            let user = User()
                            user.uid = snap.key
                            user.email = detail["email"] as! String
                            user.name = detail["name"] as! String
                            
                            //Keep each user's requesting into friendsRequest in share application.
                            self.appDeledate!.friends.append(user)
                            print(self.appDeledate?.friends ?? "nil")
                            self.tableView.reloadData()
                        }
                    }
                }
            })
        }
    }
}
