//
//  Genre.swift
//  Core Value Movies
//
//  Created by Leandro Perez on 2/10/17.
//  Copyright © 2017 Leandro Perez. All rights reserved.
//

import Foundation
import CoreValue

enum Genre : String{
    case Action, Comedy, Drama
    
    static var EntityName: String = entityName(from:Genre.self)
}

extension Genre: Boxing,Unboxing {}
