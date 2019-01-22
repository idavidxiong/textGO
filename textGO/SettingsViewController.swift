//
//  SettingsViewController.swift
//  textGO
//
//  Created by 5km on 2019/1/22.
//  Copyright © 2019 5km. All rights reserved.
//

import Cocoa

class SettingsViewController: NSViewController {

    @IBOutlet weak var versionLabel: NSTextField!
    @IBOutlet weak var apiKeyTextField: NSTextField!
    @IBOutlet weak var secretKeyFeild: NSTextField!
    
    override func viewDidLoad() {
        
        let visualEffect = self.view as! NSVisualEffectView
        visualEffect.blendingMode = .behindWindow
        visualEffect.state = .active
        visualEffect.material = .appearanceBased
        
        super.viewDidLoad()
        
        versionLabel.stringValue = getAppInfo()
        resetKeyData(self)
    }
    
    @IBAction func resetKeyData(_ sender: Any) {
        let baiduAI = BaiduAI()
        apiKeyTextField.stringValue = baiduAI.apiKey!
        secretKeyFeild.stringValue = baiduAI.secretKey!
    }
    
    @IBAction func saveKeyData(_ sender: Any) {
        let baiduAI = BaiduAI()
        baiduAI.apiKey = apiKeyTextField.stringValue
        baiduAI.secretKey = secretKeyFeild.stringValue
    }
}
