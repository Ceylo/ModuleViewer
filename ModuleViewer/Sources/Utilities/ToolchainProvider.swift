//
//  XcodeSelector.swift
//  ModuleViewer
//
//  Created by Ceylo on 15/08/2018.
//  Copyright © 2018 Yalir. All rights reserved.
//

import Cocoa
import os

class ToolchainProvider {
    static let shared = ToolchainProvider()
    
    var selectedXcode : URL? {
        get {
            let savedXcodeUrl = UserDefaults.standard.url(forKey: "SelectedXcodeURL")
            
            // Go through these checks to allow executables like lipo or nm to be usable
            // in sandbox
            guard savedXcodeUrl != nil && FileManager.default.fileExists(atPath: (savedXcodeUrl?.path)!) else {
                return nil
            }
            
            return savedXcodeUrl
        }
        
        set(newUrl) {
            UserDefaults.standard.set(newUrl, forKey: "SelectedXcodeURL")
        }
    }
    
    func selectToolchain() -> URL? {
        if self.selectedXcode == nil {
            self.selectedXcode = askXcodeUrl()
        }
        
        return self.selectedXcode?.appendingPathComponent("Contents/Developer/Toolchains/XcodeDefault.xctoolchain")
    }
    
    // Forbid external instantiation
    private init() {
    }
    
    func askXcodeUrl() -> URL? {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canChooseFiles = true
        openPanel.allowedFileTypes = [ "app" ]
        openPanel.directoryURL = URL(fileURLWithPath: "/Applications")
        openPanel.message = "Select the Xcode app from which tools like lipo will be run"
        let result = openPanel.runModal()
        
        guard result == .OK else {
            return nil
        }
        
        assert(openPanel.urls.count == 1)
        let xcodeURL = openPanel.urls[0]
        if !xcodeURL.path.contains("Xcode") {
            let alert = NSAlert()
            alert.messageText = "The selected application is not Xcode."
            alert.runModal()
            return nil
        }
        
        return xcodeURL
    }
}
