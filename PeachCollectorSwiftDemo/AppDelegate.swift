//
//  AppDelegate.swift
//  PeachCollectorSwiftDemo
//
//  Created by Rayan Arnaout on 25.09.19.
//  Copyright © 2019 European Broadcasting Union. All rights reserved.
//

import UIKit
import CoreData
import PeachCollector

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        PeachCollector.implementationVersion = "1"
        PeachCollector.shared.isUnitTesting = true
        let publisher = PeachCollectorPublisher.init(siteKey: "zzebu00000000017")
        PeachCollector.setPublisher(publisher, withUniqueName: "My Publisher")
        
        let customPublisher = MyCustomPublisher.init(siteKey: "zzebu00000000017")
        PeachCollector.setPublisher(customPublisher, withUniqueName: "My Custom Publisher")

        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "PeachCollectorSwiftDemo")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}



class MyCustomPublisher: PeachCollectorPublisher {
    
    override func processEvents(_ events: [PeachCollectorEvent], withCompletionHandler completionHandler: @escaping (Error?) -> Void) {
        var dictionary: Dictionary = [String: AnyObject]()
        dictionary["sessionStart"] = PeachCollector.sessionStartTimestamp as AnyObject
        dictionary["sentTime"] = Int(Date().timeIntervalSince1970) as AnyObject
        if (PeachCollector.userID != nil) {
            dictionary["userID"] = PeachCollector.userID as AnyObject
        }
        
        
        var eventsArray: [Dictionary<String, AnyObject>] = []
        for event in events {
            // default is `event.dictionaryRepresentation()`
            
            var eventDictionary: Dictionary = [String: AnyObject]()
            eventDictionary["type"] = event.type as AnyObject
            eventDictionary["date"] = Int(event.creationDate!.timeIntervalSince1970) as AnyObject
            
            if (event.eventID != nil) {
                eventDictionary["id"] = event.eventID as AnyObject
            }
            if (event.props != nil) {
                eventDictionary["properties"] = event.props as AnyObject
            }
            if (event.metadata != nil) {
                eventDictionary["metadata"] = event.metadata as AnyObject
            }
            if (event.context != nil) {
                eventDictionary["context"] = event.context as AnyObject
            }
            
            eventsArray.append(eventDictionary)
        }
        dictionary["events"] = eventsArray as AnyObject
        
        // publishData can also be overriden if need be, default implementation is pretty simple :
        // It converts the dictionary to a json data and sends it to the configured service URL
        publishData(dictionary, withCompletionHandler: completionHandler)
        
        print(dictionary)
        
    }

    
}
