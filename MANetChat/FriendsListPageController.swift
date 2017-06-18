
import UIKit
import FirebaseAuth
import FirebaseDatabase

class FriendsListPageController: UIViewController, UITableViewDelegate,UITableViewDataSource {
    
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    var FirstTimeViewAppear = true
    var reachability:Reachability?

    @IBOutlet weak var friendRequestButton: UIBarButtonItem!
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var userDisplayName: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            try reachability = Reachability()
        } catch let error {
            print(error)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (reachability?.isReachable)! {
            friendRequestButton.isEnabled = true
            addButton.isEnabled = true
        } else {
            friendRequestButton.isEnabled = false
            addButton.isEnabled = false
        }
        
        if FirstTimeViewAppear {
            setUpPage()
            FirstTimeViewAppear = false
            imageView.layer.cornerRadius = imageView.frame.size.width / 2
            imageView.clipsToBounds = true
        }
    }
    
    func setUpPage(){
        //Set display name
        userDisplayName.text = appDelegate?.myName
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendsCell", for: indexPath) as! FriendViewCell
        cell.friendName.text = appDelegate?.friends[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (appDelegate?.friends.count)!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 51
    }
    
    
}
