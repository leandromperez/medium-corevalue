//
//  AppDelegate.swift
//  Core Value Movies
//
//  Created by Leandro Perez on 2/10/17.
//  Copyright © 2017 Leandro Perez. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    //Initializing this will create the app dependencies
    var dependencies = AppDependencies()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        self.addSomeMovies()
        return true
    }
    
    private func addSomeMovies(){
        let database : Database = try! dependencies.container.resolve()
        
        let movies : [Movie] = database.all()
        if movies.count == 0{
            let spielberg = Director(objectID: nil, name: "Spielberg")
            let coppola = Director(objectID: nil, name: "Coppola")
            
            var et = Movie(objectID: nil, name: "E.T.", director: spielberg, genre: .Drama)
            var jurassic = Movie(objectID: nil, name: "Jurassic Park", director: spielberg, genre: .Drama)
            
            var apocalypse = Movie(objectID: nil, name: "Apocalypse Now", director: coppola, genre: .Drama)
            
            try! database.save(element: &et)
            try! database.save(element: &jurassic)
            try! database.save(element: &apocalypse)
        }

    }
}

