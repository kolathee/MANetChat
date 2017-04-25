import JSQMessagesViewController
import MultipeerConnectivity

class PublicChatVC: JSQMessagesViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var mpcManager:MPCManager?
    
    //All messages
    var messages = [JSQMessage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // tell JSQMessagesViewController
        // who is the current user
        
        self.senderId = appDelegate.myUID
        self.senderDisplayName = appDelegate.myName
        self.mpcManager = appDelegate.mpcManager
        mpcManager?.PublicDelegate = self
        
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
    }
    
    @IBAction func chatsButtonWasTapped(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }
}

extension PublicChatVC {
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        if (mpcManager?.sendDataToAllConnectedPeers(TextMessage: text))! {
            let message = JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text)
            messages.append(message!)
            finishSendingMessage()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let message = messages[indexPath.item]
        
        if message.senderId == senderId {
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
        
        if senderId == message.senderId {
            return bubbleFactory?.outgoingMessagesBubbleImage(with: .green)
        } else {
            return bubbleFactory?.incomingMessagesBubbleImage(with: .lightGray)
        }
    }
    
}

extension PublicChatVC: MPCManagerPublicDelegate {
    
    func foundPeer(){
        print("found found found found")
    }
    
    func lostPeer(){
        print("lost lost lost lost lost")
    }
    
    func invitationWasReceived(fromPeer : String){
        
    }
    
    func connectedWithPeer(peerName : String){
        print("Connect with -------- \(peerName)")
    }
    
    func receivedData(message: String, fromPeer: MCPeerID) {
        let message = JSQMessage(senderId: "0", displayName: fromPeer.displayName , text: message)
        messages.append(message!)
        OperationQueue.main.addOperation { () -> Void in
            self.finishReceivingMessage()
        }
    }
}
