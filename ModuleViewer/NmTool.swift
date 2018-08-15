//
//  NmTool.swift
//  ModuleViewer
//
//  Created by Ceylo on 12/08/2018.
//  Copyright © 2018 Yalir. All rights reserved.
//

import Foundation
import os

class Symbol : NSObject {
    let name : String
    let type : String
    let architecture : String
    
    init(name : String, type : String, architecture : String) {
        self.name = name
        self.type = type
        self.architecture = architecture
    }
    
    override var description : String {
        get {
            return "\(name) (\(type)) (\(architecture))"
        }
    }
}

class NmTool : DeveloperTool {
    
    init() throws {
        try super.init(url: URL(fileURLWithPath: "/usr/bin/nm"))
    }
    
    func symbols(for fileUrl : URL, architectures : [String]) throws -> [Symbol] {
        var symbols = [Symbol]()
        
        for architecture in architectures {
            let output = try execute(with: ["-P", "-arch", architecture, fileUrl.path])
            let lines = output.components(separatedBy: .newlines)
            
            // Match both ObjC style symbols and C/C++ symbols
            let regex = try NSRegularExpression(pattern: "([-+]\\[.+\\]) (\\S+).*|(\\S+) (\\S+).*",
                                                options: [])
            
            for line in lines {
                if line.isEmpty {
                    continue
                }
                
                guard let match = regex.firstMatch(in: line, options: [], range: NSMakeRange(0, line.count)) else {
                    os_log("Failed parsing line: %@", type: .debug, line)
                    continue
                }
                
                let objcSymbolNameRange = Range(match.range(at: 1), in: output)
                let objcSymbolTypeRange = Range(match.range(at: 2), in: output)
                let cSymbolNameRange = Range(match.range(at: 3), in: output)
                let cSymbolTypeRange = Range(match.range(at: 4), in: output)
                
                let symbolNameRange = objcSymbolNameRange != nil ? objcSymbolNameRange : cSymbolNameRange
                let symbolTypeRange = objcSymbolTypeRange != nil ? objcSymbolTypeRange : cSymbolTypeRange
                let symbolName = DemangleCXXSymbol(String(line[symbolNameRange!]))
                let symbolType = String(line[symbolTypeRange!])
                
                symbols.append(Symbol(name: symbolName, type: symbolType, architecture: architecture))
            }
        }
        
        return symbols
    }
}
