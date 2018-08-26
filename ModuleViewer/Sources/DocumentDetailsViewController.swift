//
//  DocumentDetailsViewController.swift
//  ModuleViewer
//
//  Created by Ceylo on 26/08/2018.
//  Copyright © 2018 Yalir. All rights reserved.
//

import Cocoa
import os

private class HeaderItem {
    let title : String
    
    init(withTitle title : String) {
        self.title = title
    }
}

private class DependencyItem {
    let dependencyUrl : URL?
    
    init(withUrl url : URL?) {
        self.dependencyUrl = url
    }
}

private class ArchitectureItem {
    let architecture : String
    
    init(withArchitecture architecture : String) {
        self.architecture = architecture
    }
}

class DocumentDetailsViewController : NSViewController, NSOutlineViewDataSource, NSOutlineViewDelegate {
    
    @IBOutlet weak var detailsOutlineView: NSOutlineView!
    
    private let outlineViewHeaders : [HeaderItem]
    private var outlineViewArchitectures = [ArchitectureItem]()
    private var outlineViewDependencies = [DependencyItem]()
    
    required init?(coder: NSCoder) {
        self.outlineViewHeaders = [
            HeaderItem(withTitle: "Architectures"),
            HeaderItem(withTitle: "Dependencies")
        ]
        
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        detailsOutlineView.target = self
        detailsOutlineView.doubleAction = #selector(didDoubleClickRow)
    }
    
    override var representedObject: Any? {
        didSet {
            if (self.representedObject as? Document) != nil {
                rebuildOutlineViewItems()
                self.detailsOutlineView.reloadData()
                self.detailsOutlineView.expandItem(nil, expandChildren: true)
            }
        }
    }
    
    weak var document: Document? {
        return self.representedObject as? Document
    }
    
    @objc func didDoubleClickRow() {
        let selectedItem = detailsOutlineView.item(atRow: detailsOutlineView.selectedRow)
        if selectedItem is DependencyItem {
            if let dependencyView = detailsOutlineView.view(atColumn: 0, row: detailsOutlineView.selectedRow, makeIfNecessary: false) as? DependencyCellView {
                dependencyView.openDependency(nil)
            }
        }
    }
    
    func rebuildOutlineViewItems() {
        self.outlineViewArchitectures = self.document?.architectures?.map({
            (arch : String) -> ArchitectureItem in
            return ArchitectureItem(withArchitecture: arch)
        }) ?? []
        
        self.outlineViewDependencies = self.document?.dependencies?.map({
            (dependency : String) -> DependencyItem in
            if FileManager.default.fileExists(atPath: dependency) {
                return DependencyItem(withUrl: URL(fileURLWithPath: dependency))
            } else {
                return DependencyItem(withUrl: URL(string: dependency))
            }
        }) ?? []
    }
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if item == nil {
            return outlineViewHeaders.count
        } else if let header = item as? HeaderItem {
            switch header.title {
            case "Architectures":
                return self.outlineViewArchitectures.count
            case "Dependencies":
                return self.outlineViewDependencies.count
            default:
                return 0
            }
        } else {
            return 0
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return item is HeaderItem
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if item == nil {
            return outlineViewHeaders[index]
        } else if let header = item as? HeaderItem {
            switch header.title {
            case "Architectures":
                return self.outlineViewArchitectures[index]
            case "Dependencies":
                return self.outlineViewDependencies[index]
            default:
                os_log("Unhandled NSOutlineView group with title \"%@\"",
                       type: .error, header.title)
                return NSNull()
            }
        } else {
            os_log("Cannot return NSOutlineView children for item of type \"%@\"",
                   type: .error, String(describing: type(of: item)))
            return NSNull()
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        let headerCellId = NSUserInterfaceItemIdentifier("DefaultTextCell")
        let architectureCellId = NSUserInterfaceItemIdentifier("DefaultTextCell")
        let dependencyPathCellId = NSUserInterfaceItemIdentifier("DependencyPathCell")
        
        if let headerItem = item as? HeaderItem {
            if let view = detailsOutlineView.makeView(withIdentifier: headerCellId,
                                                      owner: self) as? NSTableCellView {
                view.textField?.stringValue = headerItem.title
                return view
            }
        } else if let architectureItem = item as? ArchitectureItem {
            if let view = detailsOutlineView.makeView(withIdentifier: architectureCellId,
                                                      owner: self) as? NSTableCellView {
                view.textField?.stringValue = architectureItem.architecture
                return view
            }
        } else if let dependencyItem = item as? DependencyItem {
            if let view = detailsOutlineView.makeView(withIdentifier: dependencyPathCellId,
                                                      owner: self) as? DependencyCellView {
                view.pathControl.url = dependencyItem.dependencyUrl
                view.openButton.isEnabled = FileManager.default.fileExists(atPath: dependencyItem.dependencyUrl?.path ?? "")
                return view
            }
        }
        
        return nil
    }
    
    func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
        return item is HeaderItem
    }
}
