//
//  SystemTool.swift
//  ModuleViewer
//
//  Created by Ceylo on 11/08/2018.
//  Copyright © 2018 Yalir. All rights reserved.
//

import Foundation
import os

class DeveloperTool {
    static var xcodeToolchainURL : URL? = nil
    let url : URL
    
    init(url toolUrl : URL) {
        url = toolUrl
        assert(FileManager().fileExists(atPath: url.path))
        os_log("Created DeveloperTool (%@) with path: %@", log: .default, type: .debug, String(describing: self.self), url.path)
    }
    
    enum ExecutionError : Error {
        case badStatus
        case badOutput
    }
    
    func execute(with args : [String]) throws -> String {
        let subprocess = Process()
        subprocess.executableURL = self.url
        subprocess.arguments = args
        
        let pipe = Pipe()
        subprocess.standardOutput = pipe
        
        subprocess.launch()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        assert(!subprocess.isRunning)
        
        if subprocess.terminationStatus != 0 {
            throw ExecutionError.badStatus
        }
        
        if let output = String(data: data, encoding: String.Encoding.utf8) {
            return output
        } else {
            return ""
        }
    }
}
