//
//  NoticesVC.swift
//  MANetChat
//
//  Created by Kolathee Payuhawatthana on 5/27/2560 BE.
//  Copyright © 2560 Kolathee Payuhawattana. All rights reserved.
//

import UIKit
import FirebaseDatabase

class NoticesVC: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    let noticeRef = FIRDatabase.database().reference().child("notices")
    
    struct Notice {
        let noticeId:String
        let title:String
        let detail:String
        let postedDate:Int
    }
    
    var notices = [Notice]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    func setup(){
        noticeRef.queryOrdered(byChild: "postedDate").observe(.value, with: { (snapshot) in
            self.notices.removeAll()
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot]{
                print(snapshot)
                for snap in snapshot {
                    if let notice = snap.value as? [String:AnyObject] {
                        let notice = Notice(noticeId: snap.key,
                                            title: notice[ "title" ] as! String,
                                            detail: notice[ "detail" ] as! String,
                                            postedDate: notice["postedDate"] as! Int
                        )
                        self.notices.append(notice)
                        print(self.notices[self.notices.count-1].title)
                        print(self.notices[self.notices.count-1].detail)
                    }
                }
            }
            print("*****")
            print(self.notices)
            self.tableView.reloadData()
        })
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let notice = notices[indexPath.row]
        
        tableView.backgroundColor = UIColor(red:0.95, green:0.95, blue:0.95, alpha:1.0)
        let cell = tableView.dequeueReusableCell(withIdentifier: "noticeViewCell", for: indexPath) as! NoticeViewCell
        cell.title.text = notice.title
        cell.detail.text = notice.detail
        cell.backgroundColor = UIColor.white
        return cell
        
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToNoticeView" {
            let cell = sender as! UITableViewCell
            let indexPath = self.tableView!.indexPath(for: cell)
            
            let controller = segue.destination as! NoticesDetailVC
            controller.headtitle = notices[(indexPath?.row)!].title
            controller.detail = notices[(indexPath?.row)!].detail
            controller.noticeId = notices[(indexPath?.row)!].noticeId
        }
    }
}
