//
//  DocumentDependenciesViewController.swift
//  ModuleViewer
//
//  Created by Ceylo on 18/08/2018.
//  Copyright © 2018 Yalir. All rights reserved.
//

import Cocoa

class DocumentDependenciesViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    
    @IBOutlet weak var architecturesField: NSTokenField!
    @IBOutlet weak var dependenciesTableView: NSTableView!
    
    override var representedObject: Any? {
        didSet {
            if let doc = self.representedObject as? Document {
                self.architecturesField.stringValue = doc.architectures?.joined(separator: ",") ?? "None"
                self.dependenciesTableView.reloadData()
            }
        }
    }
    
    weak var document: Document? {
        return self.representedObject as? Document
    }
    
    // MARK: - Table view data source
    func numberOfRows(in tableView: NSTableView) -> Int {
        guard let dependencies = self.document?.dependencies else {
            return 0
        }
        
        return dependencies.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let dependencyPathCellId = NSUserInterfaceItemIdentifier("DependencyPathCell")
        let dependencyPathColumnId = NSUserInterfaceItemIdentifier("DependencyPathColumn")
        guard tableColumn?.identifier == dependencyPathColumnId else {
            return nil
        }
        
        guard let dependencies = self.document?.dependencies else {
            return nil
        }
        
        if let view = tableView.makeView(withIdentifier: dependencyPathCellId, owner: self) as? DependencyCellView {
            let dependencyPath = dependencies[row]
            if FileManager.default.fileExists(atPath: dependencyPath) {
                view.pathControl.url = URL(fileURLWithPath: dependencyPath)
            } else {
                view.pathControl.url = URL(string: dependencyPath)
            }
            
            view.openButton.isEnabled = FileManager.default.fileExists(atPath: dependencyPath)
            
            return view
        }
        
        return nil
    }
}
