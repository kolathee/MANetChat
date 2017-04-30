//
//  CoreDataManager.swift
//  MANetChat
//
//  Created by Kolathee Payuhawatthana on 4/26/2560 BE.
//  Copyright © 2560 Kolathee Payuhawattana. All rights reserved.
//

import CoreData

class CoreDataManager: NSObject {
    
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    var managedContext : NSManagedObjectContext?

    override init() {
        managedContext = appDelegate?.persistentContainer.viewContext
    }
    
    func fetchAllData(enitityName:String) -> [NSManagedObject]{
        var friends = [NSManagedObject]()
        let managedContext =
            appDelegate?.persistentContainer.viewContext
        
        let fetchRequest =
        NSFetchRequest<NSManagedObject>(entityName: enitityName)
        
        do {
            friends = try managedContext!.fetch(fetchRequest)
        } catch let error as NSError {
            print("Error : \(error)")
        }
        
        return friends
    }
    
    func fetchData(enitityName:String, at attribute : String, value : String) -> [NSManagedObject]{
        var friends = [NSManagedObject]()
        let managedContext =
            appDelegate?.persistentContainer.viewContext
        
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: enitityName)
        fetchRequest.predicate = NSPredicate(format: "\(attribute) = %@", value)
        
        do {
            friends = try managedContext!.fetch(fetchRequest)
        } catch let error as NSError {
            print("Error : \(error)")
        }
        
        return friends
    }
    
    func addMyInformation(uid:String,name:String,email:String) -> Bool {
        
        let inEntity = NSEntityDescription.entity(forEntityName: "MyInformation", in: managedContext!)
        let data = NSManagedObject(entity: inEntity!, insertInto: managedContext)
        
        data.setValue(uid, forKey: "uid")
        data.setValue(name, forKey: "name")
        data.setValue(email, forKey: "email")
        
        do {
            try managedContext?.save()
            return true
        } catch let error {
            print(error)
            return false
        }
    }
    
    func addFriend( uid : String,
                    name : String,
                    email : String,
                    date : String ) -> Bool {
        let inEntity = NSEntityDescription.entity(forEntityName: "Friend", in: managedContext!)
        let data = NSManagedObject(entity: inEntity!, insertInto: managedContext)
        
        data.setValue(uid, forKey: "uid")
        data.setValue(name, forKey: "name")
        data.setValue(email, forKey: "email")
        data.setValue(date, forKey: "date")
        
        do {
            try managedContext?.save()
            return true
        } catch {
            return false
        }
    }
    
    func deleteAllData(entity: String){
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        
        do{
            let results = try managedContext!.fetch(fetchRequest)
            for managedObject in results
            {
                let managedObjectData:NSManagedObject = managedObject as! NSManagedObject
                managedContext!.delete(managedObjectData)
            }
        } catch let error as NSError {
            print("Detele all data in \(entity) error : \(error) \(error.userInfo)")
        }
    }
}
