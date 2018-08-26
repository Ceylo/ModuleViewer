//
//  ClickLessPathControl.swift
//  ModuleViewer
//
//  Created by Ceylo on 26/08/2018.
//  Copyright © 2018 Yalir. All rights reserved.
//

import Cocoa

class ClickLessPathControl : NSPathControl {
    override func mouseDown(with event: NSEvent) {
        if let responder = self.nextResponder {
            responder.mouseDown(with: event)
        } else {
            self.noResponder(for: #selector(keyDown(with:)))
        }
    }
}
