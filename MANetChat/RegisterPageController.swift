//
//  RegisterPageController.swift
//  MANetChat
//
//  Created by Kolathee Payuhawatthana on 12/23/2559 BE.
//  Copyright © 2559 Kolathee Payuhawattana. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class RegisterPageController: UIViewController {

    @IBOutlet weak var inputNameTextBox: UITextField!
    @IBOutlet weak var inputEmailTextBox: UITextField!
    @IBOutlet weak var inputPasswordTextBox: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func cencelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendButtonTapped(_ sender: Any) {
        guard let email = inputEmailTextBox.text,let password = inputPasswordTextBox.text else {
            
            //Alert when data is nil
            let optionMenu = UIAlertController(title: "Error", message: "Please insert information", preferredStyle: .actionSheet)
            let cancelAction = UIAlertAction(title: "Done", style: .cancel, handler:nil)
            optionMenu.addAction(cancelAction)
            self.present(optionMenu, animated: true, completion: nil)
            
            print("Form is not valid")
            return
        }
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user: FIRUser?, error) in
            
            if error != nil {
                print("LOOOOOKKK 1! \(error!)")
            }
            
            guard let uid = user?.uid else {
                return
            }
            //successfully created user by email
            
            //insert user data to database
            let name = self.inputNameTextBox.text
            let ref = FIRDatabase.database().reference(fromURL: "https://manetchat.firebaseio.com")
            let usersReference = ref.child("users").child(uid)
            let values = ["name":name, "email":email]
            
            usersReference.updateChildValues(values,withCompletionBlock: {(err, ref) in
                
                if err != nil{
                    print("LOOOOOOK 2 !! \(err!)")
                    return
                }
                print("Saved user successfully into Firebase's db")
                self.dismissAllModalStackBackToInitialView()
            })
        })
    }
    
    func dismissAllModalStackBackToInitialView() {
        var vc = presentingViewController
        while ((vc?.presentingViewController) != nil) {
            vc = vc?.presentingViewController
        }
        vc?.dismiss(animated: true, completion: nil)
    }
}
