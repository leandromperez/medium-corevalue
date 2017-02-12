//
//  AppDependencies.swift
//  Core Value Movies
//
//  Created by Leandro Perez on 1/4/17.
//  Copyright © 2017 Leandro Perez. All rights reserved.
//

import Foundation
import Dip
import Dip_UI
import CoreData

//It's a class so I can subclass it in tests so I don't have to write all the mapping
class AppDependencies  {
    
    var container : DependencyContainer = DependencyContainer()

    init() {
        self.configureDependencies()
    }
    
    func configureDependencies(){
    
        //MARK: Core Data
        self.container.register(.singleton){ CoreDataServiceImpl() as CoreDataService}
        
        self.container.register{CoreDataDatabase(coreDataService:try self.container.resolve()) as Database }
        
        self.container.register{MoviesViewController()}.resolvingProperties { container, vc in
            vc.database = try container.resolve()
        }
        
        //MARK: Storyboard container
        DependencyContainer.uiContainers = [container]
    }
}

