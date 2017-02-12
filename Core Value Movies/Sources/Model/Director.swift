//
//  Director.swift
//  Core Value Movies
//
//  Created by Leandro Perez on 2/10/17.
//  Copyright © 2017 Leandro Perez. All rights reserved.
//

import Foundation
import CoreValue
import CoreData

struct Director : CVManagedPersistentStruct{
    //MARK : - CoreValue stuff
    typealias StructureType = Director
    static var EntityName: String = entityName(from:Director.self)
    
    static func fromObject(_ o: NSManagedObject)  throws -> Director {
        //Notice I am not using curry
        let director =  self.init(objectID: o <|? "objectID",
                                  name: try o <| "name")

        return director
    }
    
    var objectID: NSManagedObjectID? = nil
    
    //MARK : - Director
    var name : String
}

extension Director : Equatable{}

func == (lhs:Director, rhs: Director) ->Bool{
    return lhs.objectID == rhs.objectID
}
