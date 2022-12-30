//
//  ObjdumpTool.swift
//  ModuleViewer
//
//  Created by Ceylo on 18/08/2018.
//  Copyright © 2018 Yalir. All rights reserved.
//

import Foundation
import os

class ObjdumpTool : DeveloperTool {
    init() throws {
        try super.init(url: URL(fileURLWithPath: "/usr/bin/objdump"))
    }
    
    func dependencies(for fileUrl : URL) throws -> [String] {
        let output = try execute(with: [ "--macho", "--dylibs-used", "--non-verbose", "--no-leading-headers", fileUrl.path ])
        let lines = output.components(separatedBy: .newlines)
        let regex = try NSRegularExpression(pattern: "\t(.+) \\(.*", options: [])
        
        var dependencies = [String]()
        for line in lines.dropFirst() {
            guard let match = regex.firstMatch(in: line, options: [], range: NSMakeRange(0, line.count)) else {
                os_log("Failed parsing line: %@", type: .debug, line)
                continue
            }
            
            let dependencyRange = Range(match.range(at: 1), in: output)
            let dependency = String(line[dependencyRange!])
            dependencies.append(dependency)
        }
        
        return dependencies
    }
}
