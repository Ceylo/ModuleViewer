//
//  ViewController.swift
//  ModuleViewer
//
//  Created by Ceylo on 11/08/2018.
//  Copyright © 2018 Yalir. All rights reserved.
//

import Cocoa
import os

class ViewController: NSViewController, NSTableViewDataSource {
    @IBOutlet weak var architecturesField: NSTokenField!
    @IBOutlet weak var symbolsTableView: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
            if let doc = self.representedObject as? Document {
                architecturesField.stringValue = doc.architectures?.joined(separator: ",") ?? "No architecture found"
                symbolsTableView.reloadData()
            }
        }
    }

    weak var document: Document? {
        return self.representedObject as? Document
    }
    
    // MARK: Table view data source
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.document?.symbols?.count ?? 0
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        guard let symbols = self.document?.symbols else {
            return nil
        }
        
        let symbolNameId = NSUserInterfaceItemIdentifier("name")
        let symbolTypeId = NSUserInterfaceItemIdentifier("type")
        let symbolArchitectureId = NSUserInterfaceItemIdentifier("architecture")
        
        let symbol = symbols[row]
        switch tableColumn?.identifier {
        case symbolNameId:
            return symbol.name
        case symbolTypeId:
            return symbol.type
        case symbolArchitectureId:
            return symbol.architecture
        default:
            os_log("Unknown column identifier: %@", tableColumn?.identifier.rawValue ?? "null")
            return nil
        }
    }
}

