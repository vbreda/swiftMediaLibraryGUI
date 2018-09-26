//
//  MediaViewerWindowController.swift
//  MediaLibraryManager
//
//  Created by Nikolah Pearce on 23/09/18.
//  Copyright © 2018 Nikolah Pearce. All rights reserved.
//

import Cocoa

//public protocol MediaViewerDelegate {
//    
//}

class MediaViewerWindowController: NSWindowController {

	@IBOutlet var viewerWindow: NSWindow!
	var fileToOpen: MMFile = File(filename: "MLM - Media Viewer")
	
	var currentViewController = NSViewController()
	
	convenience init() {
		self.init(windowNibName: NSNib.Name(rawValue: "MediaViewerWindowController"));
	}

	/**
	Initialises the new controller with a specific file as the start point.
	*/
	convenience init(file: MMFile) {
		self.init(windowNibName: NSNib.Name(rawValue: "MediaViewerWindowController"));
		fileToOpen = file
		setCorrectController()
		
	}
	
    override func windowDidLoad() {
        super.windowDidLoad()
		viewerWindow.title = "Viewing \(fileToOpen.filename)"
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
		viewerWindow.contentViewController = currentViewController
		
    }
	
	
	/**
	Based upon the file type, set the current View Controller
	*/
	func setCorrectController() {
                switch (fileToOpen.type) {
                    case "document" :
                        print("")
//                        currentViewController = DocumentViewController()
                    case "image" :
                        currentViewController = ImageViewController(file: fileToOpen)
                    case "video" :
                        print("")

//                        currentViewController = VideoViewController()
                    case "audio" :
                        print("")

//                        currentViewController = AudioViewController()
                    default:
                        print("")

                }
	}
	
	/**
	Reset the file being show. If it is different type, reset the type of view controller too
	*/
	func updateCurrentViewController(file: MMFile) {
		let oldFileType = self.fileToOpen.type
		self.fileToOpen = file
		if oldFileType != fileToOpen.type {
			setCorrectController()
		}
	}
}
