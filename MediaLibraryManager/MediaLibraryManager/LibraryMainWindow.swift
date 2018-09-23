//
//  LibraryMainWindow.swift
//  MediaLibraryManager
//
//  Created by Nikolah Pearce on 20/09/18.
//  Copyright © 2018 Nikolah Pearce. All rights reserved.
//

import Cocoa

class LibraryMainWindow: NSWindowController {
	
	static let model : LibraryModel = LibraryModel()
	
	@IBOutlet var mainWindow: NSWindow!
	
	@IBOutlet weak var mainView: NSView!

	
	convenience init() {
		self.init(windowNibName: NSNib.Name(rawValue: "LibraryMainWindow"));

	}
	
    override func windowDidLoad() {
        super.windowDidLoad()

		//self.window?.title = "MediaLibraryManager"
		mainWindow.title = "Media Library Manager"
		
		let splitVC = NSSplitViewController()
		let bookmarksVC = BookmarksViewController()
		let libraryVC = LibraryViewController()
		
	splitVC.addSplitViewItem(NSSplitViewItem(contentListWithViewController: bookmarksVC))
	splitVC.addSplitViewItem(NSSplitViewItem(contentListWithViewController: libraryVC))
		
		mainWindow.contentViewController = splitVC
    }
    
}
