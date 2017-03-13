
import UIKit
import FirebaseDatabase
import FirebaseAuth

class ContactsPageController: UIViewController {
    
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var chatsContainer: UIView!
    @IBOutlet weak var contactsContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    @IBAction func contactsSegmentHasBeenChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            contactsContainer.isHidden = false
            chatsContainer.isHidden = true
        default:
            contactsContainer.isHidden = true
            chatsContainer.isHidden = false
        }
    }
    
    @IBAction func showUsersInDatabaseButtonTapped(_ sender: Any) {
        
    }
}
