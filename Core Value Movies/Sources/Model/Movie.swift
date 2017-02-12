//
//  Movie.swift
//  Core Value Movies
//
//  Created by Leandro Perez on 2/10/17.
//  Copyright © 2017 Leandro Perez. All rights reserved.
//

import Foundation
import CoreValue
import CoreData

struct Movie : CVManagedPersistentStruct
{
    //MARK : - CoreValue stuff
    typealias StructureType = Movie
    static var EntityName: String = entityName(from:Movie.self)
    
    static func fromObject(_ o: NSManagedObject)  throws -> Movie {
        //The order is important, change the order and it doesn't compile
        let movie =  try curry(self.init(objectID:name:director:genre:))
            <^> o <|? "objectID"
            <^> o <| "name"
            <^> o <| "director"
            <^> o <| "genre"
        
        return movie
    }
    
    var objectID: NSManagedObjectID? = nil
    
    //MARK : - CoreValue stuff
    
    var name : String
    var director : Director
    var genre : Genre
}

extension Movie : Equatable{}

func == (lhs:Movie, rhs: Movie) ->Bool{
    return lhs.objectID == rhs.objectID
}
