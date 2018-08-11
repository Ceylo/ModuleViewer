//
//  AppDelegate.swift
//  ModuleViewer
//
//  Created by Ceylo on 11/08/2018.
//  Copyright © 2018 Yalir. All rights reserved.
//

import Cocoa
import os

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationWillFinishLaunching(_ notification: Notification) {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canChooseFiles = true
        openPanel.allowedFileTypes = [ "app" ]
        openPanel.message = "Select the Xcode app from which tools like lipo will be run"
        let result = openPanel.runModal()
        
        if result != .OK {
            NSApp.terminate(self)
        }
        
        assert(openPanel.urls.count == 1)
        let xcodeURL = openPanel.urls[0]
        if !xcodeURL.path.contains("Xcode") {
            let alert = NSAlert()
            alert.messageText = "The selected application is not Xcode."
            alert.runModal()
            NSApp.terminate(self)
        }
        
        DeveloperTool.xcodeToolchainURL = xcodeURL.appendingPathComponent("Contents/Developer/Toolchains/XcodeDefault.xctoolchain")
        os_log("Will use Xcode toolchain at: %@", log: .default, type: .debug, DeveloperTool.xcodeToolchainURL!.path)
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application

    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

