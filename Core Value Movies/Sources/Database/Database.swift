//
//  Database.swift
//  Core Value Movies
//
//  Created by Leandro Perez on 2/10/17.
//  Copyright © 2017 Leandro Perez. All rights reserved.
//

import Foundation
import CoreValue
import CoreData

protocol Database  {
    func save<T : CVManagedPersistentStruct>( element: inout T) throws
    func delete<T : CVManagedPersistentStruct>(element: inout T) throws
    
    func find<T : CVManagedPersistentStruct>(where isTrue:(T)->Bool )  -> [T]
    func first<T : CVManagedPersistentStruct>(where isTrue: (T)->Bool)  ->T?
    func all<T : CVManagedPersistentStruct>()  -> [T]
}


struct CoreDataDatabase : Database{
    
    var coreDataService : CoreDataService
    
    var context : NSManagedObjectContext{
        return self.coreDataService.context
    }
        
    func save<T : CVManagedPersistentStruct>( element:  inout T) throws {
        try element.save(self.context)
    }
    
    func delete<T : CVManagedPersistentStruct>(element: inout T) throws {
        try element.delete(self.context)
    }
    
    func find<T : CVManagedPersistentStruct>(where isTrue:(T)->Bool )  -> [T]{
        if let result =  try? T.find(in: self.context, where: isTrue) {
            return result
        }
        return []
    }
    
    func first<T : CVManagedPersistentStruct>(where isTrue: (T)->Bool)  ->T?{
        if let result = try? T.find(in: self.context, where: isTrue).first {
            return result
        }
        return nil
    }
    
    func all<T : CVManagedPersistentStruct>() -> [T]{
        return self.find{_ in true}
    }
}


extension BoxingStruct {
    
    public static func find<T: UnboxingStruct>(in context: NSManagedObjectContext,
                            where isTrue: (T)->Bool = {t in true}) throws -> Array<T> {
        
        let results : [T] = try self.query(context, predicate:nil)
        
        return results.filter(isTrue)
    }
    
}

func entityName(from c:Any)->String{
    return "\(c)" + "Entity"
}
