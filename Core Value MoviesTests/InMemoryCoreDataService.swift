//
//  InMemoryCoreDataService.swift
//  Core Value Movies
//
//  Created by Leandro Perez on 2/10/17.
//  Copyright © 2017 Leandro Perez. All rights reserved.
//

import Foundation
@testable import Core_Value_Movies
import CoreData

class InMemoryCoreDataService : CoreDataService{
    var persistentContainer  : NSPersistentContainer!
    
    var context : NSManagedObjectContext{
        return self.persistentContainer.viewContext
    }
    
    init() {
        self.setupPersistentContainer()
    }
    
    func setupPersistentContainer(){
        persistentContainer = NSPersistentContainer(name: "Core_Value_Movies")
        
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        persistentContainer.persistentStoreDescriptions = [description]
        
        persistentContainer.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
}
