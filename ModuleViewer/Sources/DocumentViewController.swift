//
//  ViewController.swift
//  ModuleViewer
//
//  Created by Ceylo on 11/08/2018.
//  Copyright © 2018 Yalir. All rights reserved.
//

import Cocoa
import os

class DocumentViewController: NSViewController, NSTableViewDataSource, NSSearchFieldDelegate {
    @IBOutlet weak var architecturesField: NSTokenField!
    @IBOutlet weak var symbolsTableView: NSTableView!
    @IBOutlet weak var symbolsSearchField: NSSearchField!
    
    @IBOutlet weak var localSymbolsButton: NSButton!
    @IBOutlet weak var externalSymbolsButton: NSButton!
    @IBOutlet weak var undefinedSymbolsButton: NSButton!
    @IBOutlet weak var absoluteSymbolsButton: NSButton!
    @IBOutlet weak var commonSymbolsButton: NSButton!
    @IBOutlet weak var textSymbolsButton: NSButton!
    @IBOutlet weak var dataSymbolsButton: NSButton!
    @IBOutlet weak var bssSymbolsButton: NSButton!
    @IBOutlet weak var indirectSymbolsButton: NSButton!
    @IBOutlet weak var otherSymbolsButton: NSButton!
    @IBOutlet weak var debuggerSymbolsButton: NSButton!
    
    var filteredSymbols : [Symbol]? = nil
    
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
    
    // MARK: - Table view data source
    func numberOfRows(in tableView: NSTableView) -> Int {
        guard let unfilteredSymbols = self.document?.symbols else {
            return 0
        }
        
        let symbols = filteredSymbols != nil ? filteredSymbols! : unfilteredSymbols
        
        return symbols.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        guard let unfilteredSymbols = self.document?.symbols else {
            return nil
        }
        
        let symbols = filteredSymbols != nil ? filteredSymbols! : unfilteredSymbols
        
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
    
    // MARK: - Symbols filtering
    func filterSymbols() {
        guard let unfilteredSymbols = self.document?.symbols else {
            return
        }
        
        let searchText = self.symbolsSearchField.stringValue
        self.filteredSymbols = unfilteredSymbols.filter({ (symbol : Symbol) -> Bool in
            return searchText.isEmpty || symbol.name.contains(searchText)
        })
        
        let buttonPerType = [
            "u" : undefinedSymbolsButton,
            "a" : absoluteSymbolsButton,
            "c" : commonSymbolsButton,
            "t" : textSymbolsButton,
            "d" : dataSymbolsButton,
            "b" : bssSymbolsButton,
            "i" : indirectSymbolsButton,
            "s" : otherSymbolsButton,
            "-" : debuggerSymbolsButton
        ]
        
        self.filteredSymbols = self.filteredSymbols?.filter({ (symbol : Symbol) -> Bool in
            if symbol.type.uppercased() == symbol.type && externalSymbolsButton.state == .off {
                return false
            }
            
            if symbol.type.lowercased() == symbol.type && localSymbolsButton.state == .off {
                return false
            }
            
            let key = symbol.type.lowercased()
            if buttonPerType[key]??.state == .off {
                return false
            }
            
            return true
        })
        
        symbolsTableView.reloadData()
    }
    
    override func controlTextDidEndEditing(_ obj: Notification) {
        filterSymbols()
    }
    
    @IBAction func filterSymbolType(_ sender: NSButton) {
        filterSymbols()
    }
    
}

