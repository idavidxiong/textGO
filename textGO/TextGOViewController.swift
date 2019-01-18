//
//  TextGOViewController.swift
//  textGO
//
//  Created by 5km on 2019/1/19.
//  Copyright © 2019 5km. All rights reserved.
//

import Cocoa

class TextGOViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func quitApp(_ sender: Any) {
        NSApplication.shared.terminate(self)
    }
    
}
