//
//  NSDragingInfoExt.swift
//  textGO
//
//  Created by 5km on 2019/1/19.
//  Copyright © 2019 5km. All rights reserved.
//

import Cocoa

extension NSDraggingInfo {
    
    var imageFileExtensions: [String] {
        get {
            return ["png", "tiff", "jpg", "gif"]
        }
    }
    
    var draggedFileURL: NSURL? {
        let filenames = draggingPasteboard.propertyList(forType: NSPasteboard.PasteboardType("NSFilenamesPboardType")) as? [String]
        let path = filenames?.first
        return path.map(NSURL.init)
    }
    
    var isImageFile: Bool {
        get {
            guard let fileExtension = draggedFileURL?.pathExtension?.lowercased() else {
                return false
            }
            return imageFileExtensions.contains(fileExtension)
        }
    }
}
