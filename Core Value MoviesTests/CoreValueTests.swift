//
//  CoreDataTests.swift
//  Routes
//
//  Created by Leandro Perez on 2/2/17.
//  Copyright © 2017 Leandro Perez. All rights reserved.
//

import XCTest
import CoreData
import Foundation
import Dip
@testable import Core_Value_Movies

class TestDependencies : AppDependencies{
    
    override init() {
        super.init()
        
        //it uses the test core data service, that uses an in-memory database
        self.container.register{
            InMemoryCoreDataService() as CoreDataService
        }
    }
}

class CoreDataServiceTest: XCTestCase {
    
    
    var testDependencies : AppDependencies!
    var coreDataService : CoreDataService!
    var database : Database!
    
    
    
    override func setUp() {
        super.setUp()
        self.testDependencies = TestDependencies()
        self.coreDataService = try! self.container.resolve()
        self.database = try! self.container.resolve()
    }
    
    override func tearDown() {
        self.context.reset()
        super.tearDown()
    }
    
    func testCoreDataServiceIsTheTestOne(){
        let resolved : CoreDataService =  try! self.container.resolve()
        XCTAssertNotNil( resolved as? InMemoryCoreDataService)
    }
  
    var container : DependencyContainer {
        get{
            return self.testDependencies.container
        }
    }
    
    var context : NSManagedObjectContext{
        return self.coreDataService.context
    }
}


class CoreValueIntegrationTests: CoreDataServiceTest {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testEntityNames(){
        XCTAssertEqual( Movie.EntityName, "MovieEntity")
        XCTAssertEqual( Director.EntityName, "DirectorEntity")
        XCTAssertEqual( Genre.EntityName, "GenreEntity")
        
    }
    

    
    
    
}
