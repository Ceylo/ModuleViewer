//
//  ViewController.swift
//  ModuleViewer
//
//  Created by Ceylo on 11/08/2018.
//  Copyright © 2018 Yalir. All rights reserved.
//

import Cocoa
import os

class DocumentViewController: NSSplitViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
            for splitViewItem in self.splitViewItems {
                splitViewItem.viewController.representedObject = self.representedObject
            }
        }
    }
}

