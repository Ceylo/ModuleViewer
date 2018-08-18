//
//  Document.swift
//  ModuleViewer
//
//  Created by Ceylo on 11/08/2018.
//  Copyright © 2018 Yalir. All rights reserved.
//

import Cocoa
import os

class Document: NSDocument {

    var architectures : [String]? = nil
    var symbols : [Symbol]? = nil
    var dependencies : [String]? = nil
    
    override init() {
        super.init()
        // Add your subclass-specific initialization here.
    }

    override class var autosavesInPlace: Bool {
        return true
    }

    override func makeWindowControllers() {
        // Returns the Storyboard that contains your Document window.
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Document Window Controller")) as! NSWindowController
        self.addWindowController(windowController)
        
        let myView = windowController.contentViewController as! DocumentViewController
        myView.representedObject = self
    }

    override func data(ofType typeName: String) throws -> Data {
        // Insert code here to write your document to data of the specified type, throwing an error in case of failure.
        // Alternatively, you could remove this method and override fileWrapper(ofType:), write(to:ofType:), or write(to:ofType:for:originalContentsURL:) instead.
        throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
    }

//    override func read(from data: Data, ofType typeName: String) throws {
//        // Insert code here to read your document from the given data of the specified type, throwing an error in case of failure.
//        // Alternatively, you could remove this method and override read(from:ofType:) instead.
//        // If you do, you should also override isEntireFileLoaded to return false if the contents are lazily loaded.
////        throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
////        self.windowCon
//        os_log("Load data of size %d", log: .default, type: .debug, data.count)
//    }
    
    override func read(from url: URL, ofType typeName: String) throws {
        let lipo = try LipoTool()
        let nm = try NmTool()
        
        self.architectures = try lipo.architectures(for: url)
        if let architectures = self.architectures {
            self.symbols = try nm.symbols(for: url, architectures: architectures)
        }
        
        let objdump = try ObjdumpTool()
        self.dependencies = try objdump.dependencies(for: url)
        
        os_log("Found %d architectures, %d dependencies and %d symbols in: %@", log: .default, type: .debug,
               self.architectures?.count ?? 0, self.dependencies?.count ?? 0, self.symbols?.count ?? 0, url.path)
    }
}

