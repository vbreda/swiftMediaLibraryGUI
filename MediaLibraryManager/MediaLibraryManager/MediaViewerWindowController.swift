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

    @IBOutlet weak var customView: NSView!
    @IBOutlet var viewerWindow: NSWindow!
    
    var fileToOpen: MMFile = File(filename: "MLM - Media Viewer")
    
	convenience init() {
		self.init(windowNibName: NSNib.Name(rawValue: "MediaViewerWindowController"));
	}

	/**
	Initialises the new controller with a specific file as the start point.
	*/
	convenience init(file: MMFile) {
		self.init(windowNibName: NSNib.Name(rawValue: "MediaViewerWindowController"));
		fileToOpen = file
	}
	
    override func windowDidLoad() {
        super.windowDidLoad()
		viewerWindow.title = "Viewing \(fileToOpen.filename)"
		setCorrectController()
    }
	
	
	/**
	Based upon the file type, set the current View Controller
	*/
	func setCorrectController() {
                switch (fileToOpen.type) {
                    case "document" :
                        let documentView = DocumentViewController(file: fileToOpen)
                        documentView.view.setFrameOrigin(NSPoint(x:0, y:0))
                        documentView.view.setFrameSize(customView.frame.size)
                        customView.addSubview(documentView.view)
                       // documentView.textView.isEditable = true
                    
                    case "image" :
                        let imageView = ImageViewController(file: fileToOpen)
                        imageView.view.setFrameOrigin(NSPoint(x:0, y:0))
                        imageView.view.setFrameSize(customView.frame.size)
                        customView.addSubview(imageView.view)
                    case "video" :
                        let videoView = VideoViewController(file: fileToOpen)
                        videoView.view.setFrameOrigin(NSPoint(x:0, y:0))
                        videoView.view.setFrameSize(customView.frame.size)
                        customView.addSubview(videoView.view)
                    case "audio" :
                        let audioView = AudioViewController(file: fileToOpen)
                        audioView.view.setFrameOrigin(NSPoint(x:0, y:0))
                        audioView.view.setFrameSize(customView.frame.size)
                        customView.addSubview(audioView.view)
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
