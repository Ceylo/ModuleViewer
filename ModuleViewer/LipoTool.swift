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
    
    init() throws {
        try super.init(url: URL(fileURLWithPath:"/usr/bin/lipo"))
    }
    
    func architectures(for fileUrl : URL) throws -> [String] {
        let output = try execute(with: [ "-info", fileUrl.path ])
        
        let regex = try NSRegularExpression(pattern:
            "Non-fat file:.*is architecture: (.*)|Architectures in the fat file: .*are: (.*)",
                                            options: [])
        guard let match = regex.firstMatch(in: output, options: [], range: NSMakeRange(0, output.count)) else {
            throw DeveloperToolError.badOutput
        }
        
        // Single arch case
        let firstRange = Range(match.range(at: 1), in: output)
        
        // Multi arch case
        let secondRange = Range(match.range(at: 2), in: output)
        
        let validRange = firstRange != nil ? firstRange : secondRange
        guard validRange != nil else {
            throw DeveloperToolError.badOutput
        }
        
        let archs = output[validRange!].split(separator: " ").map { (sub : Substring) -> String in
            return String(sub)
        }
        
        return archs
    }
}
