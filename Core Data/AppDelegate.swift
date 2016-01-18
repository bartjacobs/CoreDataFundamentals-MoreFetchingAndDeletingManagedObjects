//
//  AppDelegate.swift
//  Core Data
//
//  Created by Bart Jacobs on 03/01/16.
//  Copyright © 2016 Bart Jacobs. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    lazy var coreDataManager = CoreDataManager()

    let didSeedPersistentStore = "didSeedPersistentStore"

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let managedObjectContext = coreDataManager.managedObjectContext

        // Seed Persistent Store
        seedPersistentStoreWithManagedObjectContext(managedObjectContext)

        /*
        // Create Fetch Request
        let fetchRequest = NSFetchRequest(entityName: "List")

        // Add Sort Descriptor
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]

        // Add Predicate
        let predicate = NSPredicate(format: "name CONTAINS[c] %@", "o")
        fetchRequest.predicate = predicate
        */

        // Create Fetch Request
        let fetchRequest = NSFetchRequest(entityName: "Item")

        // Add Sort Descriptor
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]

        // Add Predicate
        let predicate1 = NSPredicate(format: "completed = 1")
        let predicate2 = NSPredicate(format: "%K = %@", "list.name", "Home")
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2])

        do {
            let records = try managedObjectContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]

            for record in records {
                print(record.valueForKey("name"))
            }

        } catch {
            let saveError = error as NSError
            print("\(saveError), \(saveError.userInfo)")
        }

        /*
        // Helpers
        var list: NSManagedObject? = nil

        // Fetch List Records
        let lists = fetchRecordsForEntity("List", inManagedObjectContext: managedObjectContext)

        if let listRecord = lists.first {
            list = listRecord
        } else if let listRecord = createRecordForEntity("List", inManagedObjectContext: managedObjectContext) {
            list = listRecord
        }

        // print("number of lists: \(lists.count)")
        // print("--")

        if let list = list {
            // print(list.valueForKey("name"))
            // print(list.valueForKey("createdAt"))

            if list.valueForKey("name") == nil {
                list.setValue("Shopping List", forKey: "name")
            }

            if list.valueForKey("createdAt") == nil {
                list.setValue(NSDate(), forKey: "createdAt")
            }

            let items = list.mutableSetValueForKey("items")

            if let anyItem = items.anyObject() as? NSManagedObject {
                managedObjectContext.deleteObject(anyItem)
            } else {
                managedObjectContext.deleteObject(list)
            }

            /*
            // Create Item Record
            if let item = createRecordForEntity("Item", inManagedObjectContext: managedObjectContext) {
                // Set Attributes
                item.setValue("Item \(items.count + 1)", forKey: "name")
                item.setValue(NSDate(), forKey: "createdAt")

                // Set Relationship
                item.setValue(list, forKey: "list")

                // Add Item to Items
                items.addObject(item)
            }
            */
            
            print("number of items: \(items.count)")
            print("---")
            
            for itemRecord in items {
                print(itemRecord.valueForKey("name"))
            }
        }

        do {
            // Save Managed Object Context
            try managedObjectContext.save()
            
        } catch {
            print("Unable to save managed object context.")
        }
        */

        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        coreDataManager.saveContext()
    }

    // MARK: -
    // MARK: Helper Methods
    func createRecordForEntity(entity: String, inManagedObjectContext managedObjectContext: NSManagedObjectContext) -> NSManagedObject? {
        // Helpers
        var result: NSManagedObject? = nil

        // Create Entity Description
        let entityDescription = NSEntityDescription.entityForName(entity, inManagedObjectContext: managedObjectContext)

        if let entityDescription = entityDescription {
            // Create Managed Object
            result = NSManagedObject(entity: entityDescription, insertIntoManagedObjectContext: managedObjectContext)
        }
        
        return result
    }

    func fetchRecordsForEntity(entity: String, inManagedObjectContext managedObjectContext: NSManagedObjectContext) -> [NSManagedObject] {
        // Create Fetch Request
        let fetchRequest = NSFetchRequest(entityName: entity)

        // Helpers
        var result = [NSManagedObject]()

        do {
            // Execute Fetch Request
            let records = try managedObjectContext.executeFetchRequest(fetchRequest)

            if let records = records as? [NSManagedObject] {
                result = records
            }

        } catch {
            print("Unable to fetch managed objects for entity \(entity).")
        }
        
        return result
    }

    // MARK: -
    func seedPersistentStoreWithManagedObjectContext(managedObjectContext: NSManagedObjectContext) {
        guard !NSUserDefaults.standardUserDefaults().boolForKey(didSeedPersistentStore) else { return }

        let listNames = ["Home", "Work", "Leisure"]

        for listName in listNames {
            // Create List
            if let list = createRecordForEntity("List", inManagedObjectContext: managedObjectContext) {
                // Populate List
                list.setValue(listName, forKey: "name")
                list.setValue(NSDate(), forKey: "createdAt")

                // Add Items
                for i in 1...10 {
                    // Create Item
                    if let item = createRecordForEntity("Item", inManagedObjectContext: managedObjectContext) {
                        // Set Attributes
                        item.setValue("Item \(i)", forKey: "name")
                        item.setValue(NSDate(), forKey: "createdAt")
                        item.setValue(NSNumber(bool: (i % 3 == 0)), forKey: "completed")

                        // Set List Relationship
                        item.setValue(list, forKey: "list")
                    }
                }
            }
        }
        
        if saveChanges() {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: didSeedPersistentStore)
        }
    }

    // MARK: -
    func saveChanges() -> Bool {
        var result = true

        do {
            try coreDataManager.managedObjectContext.save()

        } catch {
            result = false
            let saveError = error as NSError
            print("\(saveError), \(saveError.userInfo)")
        }

        return result
    }

}
