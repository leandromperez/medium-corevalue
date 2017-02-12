//
//  CoreDataDatabaseTests.swift
//  directors
//
//  Created by Leandro Perez on 2/3/17.
//  Copyright © 2017 Leandro Perez. All rights reserved.
//


import XCTest
import CoreData
import Foundation
@testable import Core_Value_Movies

class CoreDataDatabaseTests : CoreDataServiceTest{
   let spielbergName = "Spielberg"
    
   func testSaveAddsOne(){
        var director = Director(objectID:nil, name:spielbergName)
        try! self.database.save(element: &director)
    
        let directors : [Director] = self.database.all()
        XCTAssertEqual(directors.count, 1)
    }
    
    func testSavePreservesState(){
        let theName = "E.T."
        
        let director = Director(objectID:nil, name:spielbergName)
        var et = Movie(objectID: nil, name: theName, director: director, genre: .Drama)
        
        try! self.database.save(element: &et)
        
        let found : Movie? = self.database.first{$0.name == theName}
        XCTAssertEqual(found, et)
        
        XCTAssertEqual(et.name, theName)
        XCTAssertEqual(et.genre, .Drama)
    }
    
    func testSaveCreatesObjectID(){
        var director = Director(objectID:nil, name:spielbergName)
        XCTAssertNil(director.objectID)
        
        try! self.database.save(element: &director)
    
        XCTAssertNotNil(director.objectID)
    }
    
    func testDeleteRemovesOne(){
        var director = Director(objectID:nil, name:spielbergName)
        try! self.database.save(element: &director)
        
        try! self.database.delete(element: &director)
        let directorsAfterDelete : [Director] = self.database.all()
        XCTAssertEqual(directorsAfterDelete.count, 0)
    }
    
    func testDeleteThrowsExceptionWhenNoID(){
        do{
            var director = Director(objectID:nil, name:spielbergName)
            try self.database.delete(element: &director)
        }
        catch{
            XCTAssertNotNil(error)
        }
    }
    
    func testAddObjectGraph(){
        let spielberg = Director(objectID: nil, name: spielbergName)
        var movie = Movie(objectID: nil, name: "E.T.", director: spielberg, genre: .Drama)
        
        try! self.database.save(element: &movie)
        
        let movies : [Movie] = self.database.all()
        XCTAssertEqual(movies.count, 1)
        
        let directors : [Director] = self.database.all()
        XCTAssertEqual(directors.count, 1)
        
    }


    func test2Movies1Director(){
        let context = self.coreDataService.context
        XCTAssertNotNil(context)
        
        let spielberg = Director(objectID: nil, name: "Spielberg")
        
        var et = Movie(objectID: nil, name: "E.T.", director: spielberg, genre: .Drama)
        var jurassic = Movie(objectID: nil, name: "Jurassic Park", director: spielberg, genre: .Drama)
        
        try! et.save(context)
        try! jurassic.save(context)
        
        
        let directors : [Director] = try! Director.query(context, predicate: nil)
        XCTAssertEqual(directors.count, 1)//FAILS, got 2 instead of 1
        
        let movies : [Movie] = try! Movie.query(context, predicate: nil)
        XCTAssertEqual(movies.count, 2)
    }

    func test2Movies1DirectorSavingDirector(){
        let context = self.coreDataService.context
        XCTAssertNotNil(context)
        
        var spielberg = Director(objectID: nil, name: "Spielberg")
        try! spielberg.save(context)
        XCTAssertNotNil(spielberg.objectID)
        
        var et = Movie(objectID: nil, name: "E.T.", director: spielberg, genre: .Drama)
        var jurassic = Movie(objectID: nil, name: "Jurassic Park", director: spielberg, genre: .Drama)
        
        try! et.save(context)
        try! jurassic.save(context)
        
        
        let directors : [Director] = try! Director.query(context, predicate: nil)
        XCTAssertEqual(directors.count, 1)//FAILS, got 3 instead of 1
        
        let movies : [Movie] = try! Movie.query(context, predicate: nil)
        XCTAssertEqual(movies.count, 2)
    }

}
