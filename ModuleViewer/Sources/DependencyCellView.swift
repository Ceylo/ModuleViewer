//
//  DependencyCellView.swift
//  ModuleViewer
//
//  Created by Ceylo on 18/08/2018.
//  Copyright © 2018 Yalir. All rights reserved.
//

import Cocoa

class DependencyCellView : NSTableCellView {
    @IBOutlet weak var pathControl : NSPathControl!
    @IBOutlet weak var openButton : NSButton!
    
    @IBAction func openDependency(_ sender : NSButton?) {
        if let fileUrl = pathControl.url {
            if FileManager.default.fileExists(atPath: fileUrl.path) {
                NSDocumentController.shared.openDocument(withContentsOf: fileUrl, display: true) { (document : NSDocument?, wasAlreadyOpen : Bool, error : Error?) in
                    // Nothing to handle
                }
            }
        }
    }
}
