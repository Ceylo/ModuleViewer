//
//  SystemTool.swift
//  ModuleViewer
//
//  Created by Ceylo on 11/08/2018.
//  Copyright © 2018 Yalir. All rights reserved.
//

import Foundation
import AppKit
import os

func askXcodeURL() -> URL? {
    let openPanel = NSOpenPanel()
    openPanel.allowsMultipleSelection = false
    openPanel.canChooseDirectories = false
    openPanel.canChooseFiles = true
    openPanel.allowedFileTypes = [ "app" ]
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
    
    let xcodeToolchainURL = xcodeURL.appendingPathComponent("Contents/Developer/Toolchains/XcodeDefault.xctoolchain")
    os_log("Will use Xcode toolchain at: %@", log: .default, type: .debug, xcodeToolchainURL as CVarArg)
    
    return xcodeToolchainURL
}

class DeveloperTool {
    enum DeveloperToolError : Error {
        case badToolchain
        case badStatus
        case badOutput
    }
    
    let executableUrl : URL
    
    init(url toolUrl : URL) throws {
        var toolchainURL = UserDefaults.standard.url(forKey: "XcodeToolchainURL")
        
        // Go through these checks to allow executables like lipo or nm to be usable
        // in sandbox
        if toolchainURL == nil || !FileManager.default.fileExists(atPath: (toolchainURL?.path)!) {
            toolchainURL = askXcodeURL()
            if toolchainURL == nil {
                throw DeveloperToolError.badToolchain
            }
            
            UserDefaults.standard.set(toolchainURL, forKey: "XcodeToolchainURL")
        }
        
        executableUrl = (toolchainURL?.appendingPathComponent(toolUrl.path))!
        assert(FileManager().fileExists(atPath: executableUrl.path))
    }
    
    func execute(with args : [String]) throws -> String {
        let subprocess = Process()
        subprocess.executableURL = self.executableUrl
        subprocess.arguments = args
        
        let pipe = Pipe()
        subprocess.standardOutput = pipe
        
        subprocess.launch()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        subprocess.waitUntilExit()
        
        if subprocess.terminationStatus != 0 {
            throw DeveloperToolError.badStatus
        }
        
        if let output = String(data: data, encoding: String.Encoding.utf8) {
            return output
        } else {
            return ""
        }
    }
}
