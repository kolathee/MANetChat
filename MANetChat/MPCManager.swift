import Foundation
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

class MPCManager: NSObject {
    
    var PublicDelegate: MPCManagerPublicDelegate?
    var privateMessageDelegate: MPCManagerPrivateDelegate?
    
    var session : MCSession!
    var peer : MCPeerID!
    var browser : MCNearbyServiceBrowser!
    var advertiser : MCNearbyServiceAdvertiser!
    
    var foundPeers = [MCPeerID]()
    var connectedPeers = [MCPeerID]()
    var invitationHandler : ((Bool,MCSession)->Void)!
    
    //====== Inintialize =================================================
    
    override init(){
        super.init()
    }
    
    init(userName:String){
        super.init()
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
    
    func sendPrivateData(TextMessage text:String, toPeer targetPeer:MCPeerID) -> Bool {
        let dataToSend = NSKeyedArchiver.archivedData(withRootObject: "PRIVATEMESSAGE191" + text)
        let peersArray = NSArray(object: targetPeer)
        
        do {
            try session.send(dataToSend, toPeers: peersArray as! [MCPeerID], with:.reliable)
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
            print("\n\(peerID.displayName) connect to session: \(session)\n")
            PublicDelegate?.connectedWithPeer(peerName : peerID.displayName)
            connectedPeers.append(peerID)
            
        case MCSessionState.connecting:
            print("\n\(peerID.displayName) connecting to session: \(session)\n")
            
        case MCSessionState.notConnected:
            print("\n\(peerID.displayName) Did not connect to session: \(session)\n")
            if let indexOfLostPeer = connectedPeers.index(of: peerID){
                connectedPeers.remove(at: indexOfLostPeer)
            }
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print("didReceiveData: \(data)")
        let message = NSKeyedUnarchiver.unarchiveObject(with: data)! as! String
        if message.contains("PRIVATEMESSAGE191") {
            _ = message.replacingOccurrences(of: "PRIVATEMESSAGE191", with: "")
            privateMessageDelegate?.receivePrivateData(message: message, fromPeer: peerID)
        } else {
            PublicDelegate?.receivedData(message:message, fromPeer: peerID)
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
        print("\n========= didReceiveInvitationFromPeer \(peerID) =========\n")
        //        self.invitationHandler = invitationHandler
        invitationHandler(true, session)
        //        delegate?.invitationWasReceived(fromPeer: peerID.displayName)
    }
}

//========= Browser function ================================================

extension MPCManager : MCNearbyServiceBrowserDelegate {
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        foundPeers.append(peerID)
        print("-----------------------------\nFound & invitePeer : " + peerID.displayName)
        print(foundPeers)
        print("--------------------------")
        invatePeer(peerID: peerID, to: self.session, timeout: 10)
        PublicDelegate?.foundPeer()
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        for (index, aPeer) in foundPeers.enumerated(){
            if aPeer == peerID {
                foundPeers.remove(at: index)
                break
            }
        }
        print("-----------------------------\nLost : " + peerID.displayName)
        print(foundPeers)
        print("--------------------------")
        PublicDelegate?.lostPeer()
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        print(error.localizedDescription)
    }
}
