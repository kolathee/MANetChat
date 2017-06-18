import UIKit

class NoticesDetailVC: UIViewController {

    var noticeId:String?
    var headtitle:String?
    var detail:String?
    
    @IBOutlet weak var outputTitleViewBox: UITextView!
    @IBOutlet weak var outputDetailViewBox: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        outputTitleViewBox.text = headtitle
        outputDetailViewBox.text = detail
    }
}
