import Foundation
import RealmSwift
import MultipeerConnectivity

protocol MPCManagerPublicDelegate {
    func foundPeer()
    func lostPeer()
    func invitationWasReceived(fromPeer : String)
    func connectedWithPeer(peerName : String)
    func receivedData(message : String, fromPeer:MCPeerID)
    
}

protocol MPCManagerPrivateDelegate {
    func receivePrivateData(message:String, fromPeer:MCPeerID)
}

protocol MPCAlertPrivateMessageDelegate {
    func receivePrivateMessage(message:String,sender:String)
}

protocol MPCManagerConnectionStatus {
    func connectionDidChange()
}

class MPCManager: NSObject {
    
    let realm = try! Realm()
    
    var publicDelegate:             MPCManagerPublicDelegate?
    var privateMessageDelegate:     MPCManagerPrivateDelegate?
    var alertPrivateMessageDelegate:MPCAlertPrivateMessageDelegate?
    var connectionStatusDelegate:   MPCManagerConnectionStatus?
    
    var session : MCSession!
    var peer : MCPeerID!
    var browser : MCNearbyServiceBrowser!
    var advertiser : MCNearbyServiceAdvertiser!
    
    var foundPeers = [MCPeerID]()
    var connectedPeers = [MCPeerID]()
    var invitationHandler : ((Bool,MCSession)->Void)!
    
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var myUID : String?
    var myName : String?
    
    //====== Inintialize =================================================
    
    override init(){
        super.init()
    }
    
    init(userName:String){
        super.init()
        myUID = appDelegate.myUID
        myName = appDelegate.myName
        setupManager(userName: userName)
    }
    
//====== Functions and Methods =============================================
    
    //====== Setup =======
    
    func setupManager(userName:String){
        peer = MCPeerID(displayName: userName)
        
        session = MCSession(peer: peer, securityIdentity: nil, encryptionPreference: .none)
        session.delegate = self
        
        browser = MCNearbyServiceBrowser(peer: peer, serviceType: "MANetChat")
        browser.delegate = self
        
        advertiser = MCNearbyServiceAdvertiser(peer: peer, discoveryInfo: nil, serviceType: "MANetChat")
        advertiser.delegate = self
    }
    

    //====== Send data to specific peer =======
    
    func sendPrivateData(TextMessage text:String, toUID uid:String) -> Bool {
        let dataToSend = NSKeyedArchiver.archivedData(withRootObject: "PrivateFor191\(uid)\(text)")
        
        do {
            try session.send(dataToSend, toPeers: session.connectedPeers, with:.reliable)
            return true
        } catch {
            return false
        }
    }
    
    //====== Send data to all connectedPeers =======
    
    func sendDataToAllConnectedPeers(TextMessage text:String) -> Bool {
        let dataToSend = NSKeyedArchiver.archivedData(withRootObject: text)
        
        do {
            try session.send(dataToSend, toPeers: session.connectedPeers, with:.reliable)
            return true
        } catch {
            return false
        }
    }
    
    //====== InvatePeer =======
    
    func invatePeer(peerID:MCPeerID,to session:MCSession,timeout:Int){
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
    }
}

//====== Session ========================================================

extension MPCManager : MCSessionDelegate{
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        
        switch state {
            
        case MCSessionState.connected:
            print("\n\(peerID.displayName) connect to session: \(session)")
            publicDelegate?.connectedWithPeer(peerName : peerID.displayName)
            connectedPeers.append(peerID)
            
        case MCSessionState.connecting:
            print("\n\(peerID.displayName) connecting to session: \(session)")
            
        case MCSessionState.notConnected:
            print("\n\(peerID.displayName) Did not connect to session: \(session)")
            if let indexOfLostPeer = connectedPeers.index(of: peerID){
                connectedPeers.remove(at: indexOfLostPeer)
            }
        }
        
        let friends = appDelegate.friends
        let onlineFriends = friends.filter {
            let name = $0.name
            if connectedPeers.contains(where: {$0.displayName == name}) {
                return true
            }
            return false
        }
        appDelegate.onlineFriends = onlineFriends
        print("Online friend : \(onlineFriends)")
        connectionStatusDelegate?.connectionDidChange()
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print("didReceiveData: \(data)")
        var message = NSKeyedUnarchiver.unarchiveObject(with: data)! as! String
        if message.contains("PrivateFor191") {
            if message.contains(myUID!){
                message = message.replacingOccurrences(of: myUID!, with: "")
                message = message.replacingOccurrences(of: "PrivateFor191", with: "")
                
                let realmMessage = RealmMessage()
                realmMessage.message = message
                realmMessage.sender = peerID.displayName
                realmMessage.receiver = myName
                realmMessage.timestamp = NSDate(timeIntervalSinceNow: 1)
                
                DispatchQueue.main.async {
                    try! self.realm.write {
                        self.realm.add(realmMessage)
                    }
                }
                alertPrivateMessageDelegate?.receivePrivateMessage(message: message, sender: peerID.displayName)
            }
        } else {
            publicDelegate?.receivedData(message:message, fromPeer: peerID)
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        print("didReceiveStream")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        print("didFinishReceivingResourceWithName")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?) {
        print("didStartReceivingResourceWithName")
    }
}

//========= Advertiser function =============================================

extension MPCManager : MCNearbyServiceAdvertiserDelegate {
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print(error.localizedDescription)
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
//        print("\n========= didReceiveInvitationFromPeer \(peerID) =========\n")
        //        self.invitationHandler = invitationHandler
        invitationHandler(true, session)
        //        delegate?.invitationWasReceived(fromPeer: peerID.displayName)
    }
}

//========= Browser function ================================================

extension MPCManager : MCNearbyServiceBrowserDelegate {
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        foundPeers.append(peerID)
//        print("-----------------------------\nFound & invitePeer : " + peerID.displayName)
//        print(foundPeers)
//        print("--------------------------")
        invatePeer(peerID: peerID, to: self.session, timeout: 10)
        publicDelegate?.foundPeer()
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        for (index, aPeer) in foundPeers.enumerated(){
            if aPeer == peerID {
                foundPeers.remove(at: index)
                break
            }
        }
//        print("-----------------------------\nLost : " + peerID.displayName)
//        print(foundPeers)
//        print("--------------------------")
        publicDelegate?.lostPeer()
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        print(error.localizedDescription)
    }
}
