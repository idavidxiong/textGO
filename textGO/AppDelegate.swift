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
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        if let button = statusItem.button {
            button.image = NSImage(named: "statusIcon")
            button.window?.delegate = self
            button.window?.registerForDraggedTypes([NSPasteboard.PasteboardType("NSFilenamesPboardType")])
        }
        constructMenu()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func constructMenu() {
        let menu = NSMenu()
//        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "退出", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusItem.menu = menu
    }
}

extension AppDelegate: NSWindowDelegate, NSDraggingDestination {
    
    func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        if let button = statusItem.button {
            button.image = NSImage(named: "uploadIcon")
        }
        return .copy
    }
    
    func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        if sender.isImageFile {
            print(sender.draggedFileURL!)
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

