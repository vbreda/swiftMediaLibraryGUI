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
	static var viewerWindows : [MediaViewerWindowController] = []
	let splitVC = NSSplitViewController()
	static let bookmarksVC = BookmarksViewController()
	static let libraryVC = LibraryViewController()

	@IBOutlet var mainWindow: NSWindow!
	
	@IBAction func menuEditNotes(_ sender: Any) {
		print("MENU ITEM: edit notes")
	}
	
	convenience init() {
		self.init(windowNibName: NSNib.Name(rawValue: "LibraryMainWindow"));

	}
	
    override func windowDidLoad() {
        super.windowDidLoad()
		mainWindow.title = "Media Library Manager"
		
		splitVC.addSplitViewItem(NSSplitViewItem(contentListWithViewController: LibraryMainWindow.bookmarksVC))
		splitVC.addSplitViewItem(NSSplitViewItem(contentListWithViewController: LibraryMainWindow.libraryVC))
		
		mainWindow.contentViewController = splitVC
    }
	
    static func newViewerWindow(index: Int, files: [MMFile]) {
        let viewer = MediaViewerWindowController(index: index, files: files)
		viewerWindows.append(viewer)
		viewer.showWindow(self)
	}
    
}
