//
//  ViewController.swift
//  ModuleViewer
//
//  Created by Ceylo on 11/08/2018.
//  Copyright © 2018 Yalir. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    @IBOutlet weak var architecturesField: NSTokenField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
            if let doc = self.representedObject as? Document {
                architecturesField.stringValue = doc.architectures?.joined(separator: ",") ?? "No architecture found"
            }
        }
    }
    
    weak var document: Document? {
        return self.representedObject as? Document
    }
}

