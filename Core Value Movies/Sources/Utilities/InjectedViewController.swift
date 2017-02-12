//
//  UIViewContoller Extensions.swift
//  Core Value Movies
//
//  Created by Leandro Perez on 1/9/17.
//  Copyright © 2017 Leandro Perez. All rights reserved.
//

import Foundation
import Dip
import UIKit
import Dip_UI

/**
 Use This inconjunction to StoryboardInstantiatable to let your UIViewControllers automatically be injected.
 */
class InjectedViewController : UIViewController, Injectable {
    
    override func loadView() {
        self.inject()
        super.loadView()
    }
}

protocol Injectable{
    func inject()
}

extension Injectable where Self : InjectedViewController{

    func inject(){
        
        guard let instantiatable = self as? StoryboardInstantiatable else {
            fatalError("The View Controller \(self) does not implement StoryboardInstantiatable")
        }
        
        let tag = dipTag.map(DependencyContainer.Tag.String)
        
        for container in DependencyContainer.uiContainers {
            do {
                try instantiatable.didInstantiateFromStoryboard(container, tag: tag)
                break
            } catch {
                print(error)
            }
        }
    }
}
