//
//  AppDelegate.swift
//  textGO
//
//  Created by 5km on 2019/1/18.
//  Copyright © 2019 5km. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    let baiduAI = BaiduAI()
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    
    let settingWinC: NSWindowController = NSWindowController(window: NSWindow(contentViewController: SettingsViewController()))
  
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        if let button = statusItem.button {
            button.image = NSImage(named: "statusIcon")
            button.window?.delegate = self
            button.window?.registerForDraggedTypes([NSPasteboard.PasteboardType("NSFilenamesPboardType")])
        }
        
        constructMenu()
        
        baiduAI.delegate = self
        
        if let win = settingWinC.window {
            win.title = "偏好设置"
            win.minSize = NSSize(width: 420, height: 150)
            win.maxSize = NSSize(width: 420, height: 150)
            win.titlebarAppearsTransparent = true
            win.styleMask.insert(NSWindow.StyleMask.fullSizeContentView)
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func constructMenu() {
        let menu = NSMenu()
        let helpMenu = NSMenu()
        let mainDropdown = NSMenuItem(title: "帮助选项", action: nil, keyEquivalent: "")
        
        helpMenu.addItem(withTitle: "教程", action: #selector(howToUse), keyEquivalent: "")
        helpMenu.addItem(withTitle: "反馈", action: #selector(feedbackApp), keyEquivalent: "")
        helpMenu.addItem(withTitle: "关于", action: #selector(showAboutMe), keyEquivalent: "")
        
        menu.addItem(withTitle: "截图识别", action: #selector(screenshotAndOCR), keyEquivalent: "s")
        menu.addItem(.separator())
        menu.addItem(withTitle: "偏好设置...", action: #selector(preferencesWindow), keyEquivalent: ",")
        menu.addItem(.separator())
        menu.addItem(mainDropdown)
        menu.setSubmenu(helpMenu, for: mainDropdown)
        menu.addItem(.separator())
        menu.addItem(withTitle: "退出 textGO", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        statusItem.menu = menu
    }
    
    @objc func screenshotAndOCR() {

        let task = Process()
        task.launchPath = "/usr/sbin/screencapture"
        task.arguments = ["-i", "-c"]
        task.launch()
        task.waitUntilExit()
        
        if (NSPasteboard.general.types?.contains(NSPasteboard.PasteboardType.png))! {
            let imgData = NSPasteboard.general.data(forType: NSPasteboard.PasteboardType.png)
            baiduAI.ocr(imgData! as NSData)
        }
        
    }
    
    @objc func preferencesWindow() {
        settingWinC.window!.makeKeyAndOrderFront(self)
        settingWinC.showWindow(self)
    }
    
    @objc func showAboutMe() {
        tipInfo(withTitle:"关于", withMessage: "\(getAppInfo()) 帮助您提取图片中的文字。")
    }
    
    @objc func feedbackApp() {
        let emailBody           = ""
        let emailService        =  NSSharingService.init(named: NSSharingService.Name.composeEmail)!
        emailService.recipients = ["5km@smslit.cn"]
        emailService.subject    = "textGO 反馈"
        
        if emailService.canPerform(withItems: [emailBody]) {
            emailService.perform(withItems: [emailBody])
        } else {
            tipInfo(withTitle: "反馈信息", withMessage: "您有什么问题向 5km@smslit.cn 发送邮件反馈即可！感谢您的支持！")
        }
    }
    
    @objc func howToUse() {
        
    }
    
}

extension AppDelegate: NSWindowDelegate, NSDraggingDestination {
    
    func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        if sender.isImageFile {
            if let button = statusItem.button {
                button.image = NSImage(named: "uploadIcon")
            }
            return .copy
        }
        return .generic
    }
    
    func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        if sender.isImageFile {
            let imgurl = sender.draggedFileURL!.absoluteURL
            let imgData = NSData(contentsOf: imgurl!)
            baiduAI.ocr(imgData!)
            return true
        }
        return false
    }
    
    func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        return true
    }
    
    func draggingExited(_ sender: NSDraggingInfo?) {
        if let button = statusItem.button {
            button.image = NSImage(named: "statusIcon")
        }
    }
    
    func draggingEnded(_ sender: NSDraggingInfo) {
        if let button = statusItem.button {
            button.image = NSImage(named: "statusIcon")
        }
    }
    
}

extension AppDelegate: BaiduAIDelegate {
    func ocrError(type: BaiduAI.ErrorType, msg: String) {
        print(type)
        print(msg)
    }
    func ocrResult(text: String) {
        NSPasteboard.general.declareTypes([.string], owner: nil)
        NSPasteboard.general.setString(text, forType: .string)
    }
}

