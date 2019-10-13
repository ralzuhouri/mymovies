//
//  SplitViewController.swift
//  My Movies
//
//  Created by Ramy Al Zuhouri on 13/10/19.
//  Copyright © 2019 Ramy Al Zuhouri. All rights reserved.
//

import UIKit

class SplitViewController: UISplitViewController, UISplitViewControllerDelegate {
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.initialize()
    }
    
    private func initialize() {
        self.delegate = self
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        // I want to be able to show the master view controller when the split
        // view controller is collapsed (e.g. on an iPhone it wouldn't make
        // sense to start the application from an empty movie detail view)
        return true
    }
}
