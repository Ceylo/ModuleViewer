//
//  LipoTool.swift
//  ModuleViewer
//
//  Created by Ceylo on 11/08/2018.
//  Copyright © 2018 Yalir. All rights reserved.
//

import Foundation
import os

class LipoTool : DeveloperTool {
    
    init() {
        let lipoUrl = DeveloperTool.xcodeToolchainURL!.appendingPathComponent("/usr/bin/lipo")
        super.init(url: lipoUrl)
    }
    
    func architectures(for fileUrl : URL) throws -> [String] {
        let output = try self.execute(with: [ "-info", fileUrl.path ])
        os_log("Lipo output: %@", log: .default, type: .debug, output)
        
        let regex = try NSRegularExpression(pattern: ".*is architecture: (.*)", options: [])
        guard let match = regex.firstMatch(in: output, options: [], range: NSMakeRange(0, output.count)) else {
            throw ExecutionError.badOutput
        }
        
        let range = Range(match.range(at: 1), in: output)
        let archs = output[range!].split(separator: " ").map { (sub : Substring) -> String in
            return String(sub)
        }
        os_log("Match: %@", log: .default, type: .debug, archs)
        
        return archs
    }
}
