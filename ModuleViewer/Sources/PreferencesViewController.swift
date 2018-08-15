//
//  PreferencesViewController.swift
//  ModuleViewer
//
//  Created by Ceylo on 15/08/2018.
//  Copyright © 2018 Yalir. All rights reserved.
//

import Cocoa

class PreferencesViewController: NSViewController {
    @IBOutlet weak var xcodePathControl: NSPathControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        xcodePathControl.url = ToolchainProvider.shared.selectedXcode
    }
    
    @IBAction func selectXcode(_ sender: NSButton) {
        let provider = ToolchainProvider.shared
        if let newXcodeUrl = provider.askXcodeUrl() {
            provider.selectedXcode = newXcodeUrl
            xcodePathControl.url = newXcodeUrl
        }
    }
}
