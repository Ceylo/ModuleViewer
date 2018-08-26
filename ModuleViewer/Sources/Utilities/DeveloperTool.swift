//
//  SystemTool.swift
//  ModuleViewer
//
//  Created by Ceylo on 11/08/2018.
//  Copyright © 2018 Yalir. All rights reserved.
//

import Cocoa
import os

class DeveloperTool {
    enum DeveloperToolError : Error {
        case badToolchain
        case badStatus
        case badOutput
    }
    
    let executableUrl : URL
    
    init(url toolUrl : URL) throws {
        guard let toolchainURL = ToolchainProvider.shared.selectToolchain() else {
            throw DeveloperToolError.badToolchain
        }
        
        executableUrl = toolchainURL.appendingPathComponent(toolUrl.path)
        assert(FileManager().fileExists(atPath: executableUrl.path))
    }
    
    func execute(with args : [String]) throws -> String {
        let subprocess = Process()
        
        if #available(OSX 10.13, *) {
            subprocess.executableURL = self.executableUrl
        } else {
            subprocess.launchPath = self.executableUrl.path
        }
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
