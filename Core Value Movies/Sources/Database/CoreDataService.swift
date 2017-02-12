//
//  CoreDataService.swift
//  Core Value Movies
//
//  Created by Leandro Perez on 2/3/17.
//  Copyright © 2017 Leandro Perez. All rights reserved.
//

import Foundation
import CoreData

protocol CoreDataService{
    var context : NSManagedObjectContext {get}
}

class CoreDataServiceImpl : CoreDataService {
    var context: NSManagedObjectContext{
        return self.persistentContainer.viewContext
    }
    
    init() {
        self.saveContextWhenAppTerminates()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func saveContextWhenAppTerminates(){
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.saveContext),
                                               name: NSNotification.Name.UIApplicationWillTerminate,
                                               object: nil)
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "Core_Value_Movies")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    @objc func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
