import RealmSwift
import JSQMessagesViewController
import MultipeerConnectivity
import AudioToolbox

class PrivateChatVC: JSQMessagesViewController {
    
    let realm = try! Realm()
    var realmMessages : Results<RealmMessage>?
    var messages = [JSQMessage]()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var mpcManager : MPCManager?
    var chatingFriend : String?
    var friendUID : String?
    
    var audioPlayer:AVAudioPlayer!
    let audioFilePath = Bundle.main.path(forResource: "POP6", ofType: "WAV")

    override func viewDidLoad() {
        super.viewDidLoad()
        mpcManager = appDelegate.mpcManager!
        mpcManager?.alertPrivateMessageDelegate = self
        self.title = chatingFriend
        self.senderId = appDelegate.myName
        self.senderDisplayName = appDelegate.myName
        
        realmMessages = realm.objects(RealmMessage.self)
        
        for i in realmMessages! {
            let message = JSQMessage(senderId: i.sender, displayName: i.sender, text: i.message)
            messages.append(message!)
        }
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
    }
}

extension PrivateChatVC {
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        if (mpcManager?.sendPrivateData(TextMessage: text, toUID: friendUID!))!{
            let message = JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text)
            messages.append(message!)
            try! realm.write {
                let realmMessage = RealmMessage()
                realmMessage.message = message?.text
                realmMessage.sender = appDelegate.myName
                realmMessage.receiver = chatingFriend
                realm.add(realmMessage)
            }
//            DispatchQueue.main.async {
//                self.tabBarController?.tabBar.items?.first?.badgeValue = " "
//            }
            finishSendingMessage()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let message = messages[indexPath.item]
        
        if message.senderDisplayName == senderDisplayName {
            cell.textView?.textColor = UIColor.white
        } else {
            cell.textView?.textColor = UIColor.black
        }
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let message = messages[indexPath.row]
        let messageUsername = message.senderDisplayName
        
        return NSAttributedString(string: messageUsername!)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.row]
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        return 15
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        let message = messages[indexPath.row]
        
        if senderDisplayName == message.senderDisplayName {
            return bubbleFactory?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleRed())
        } else {
            return bubbleFactory?.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
        }
    }
}

extension PrivateChatVC: MPCAlertPrivateMessageDelegate {
    func receivePrivateMessage(message: String, sender: String) {
        let message = JSQMessage(senderId: "0", displayName: sender, text: message)
        messages.append(message!)
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        if self.audioFilePath != nil {
            let audioFileUrl = NSURL.fileURL(withPath: self.audioFilePath!)
            do {
                try self.audioPlayer = AVAudioPlayer(contentsOf: audioFileUrl)
            } catch {
                print("Error")
            }
            self.audioPlayer.play()
        } else {
            print("audio file is not found")
        }
    }
}
