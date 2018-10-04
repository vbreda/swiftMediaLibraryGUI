//
//  LibraryMainWindow.swift
//  MediaLibraryManager
//
//  Created by Nikolah Pearce and Vivian Breda on 20/09/18.
//  Copyright © 2018 Nikolah Pearce and Vivian Breda. All rights reserved.
//

import Cocoa

/**
The main window for our MediaLibraryManager.
Has a split view with Bookmarks LHS and Library Table RHS.
*/
class LibraryMainWindow: NSWindowController {
	
	static let model : LibraryModel = LibraryModel()
	static var viewerWindows : [MediaViewerWindowController] = []
	let splitVC = NSSplitViewController()
	static let bookmarksVC = BookmarksViewController()
	static let libraryVC = LibraryViewController()

	@IBOutlet var mainWindow: NSWindow!

	/**
	Convenience initialiser that loads the NIB file.
	*/
	convenience init() {
		self.init(windowNibName: NSNib.Name(rawValue: "LibraryMainWindow"));
	}
	
	/**
	Called after the window loads successfully.
	Adds the two view controllers into the split view.
	*/
    override func windowDidLoad() {
        super.windowDidLoad()
		mainWindow.title = "Media Library Manager"
		splitVC.addSplitViewItem(NSSplitViewItem(contentListWithViewController: LibraryMainWindow.bookmarksVC))
		splitVC.addSplitViewItem(NSSplitViewItem(contentListWithViewController: LibraryMainWindow.libraryVC))
		mainWindow.contentViewController = splitVC
    }
	
	/**
	Creates a new instance of a MediaViewWindowController.
	Passes the files currently displayed in the LibraryViewController.
	- parameter index: the index of whichever file is to open first.
	- parameter files: the files allowed in this instance of the MediaViewer.
	*/
    static func newViewerWindow(index: Int, files: [MMFile]) {
        let viewer = MediaViewerWindowController(index: index, files: files)
		viewerWindows.append(viewer)
		viewer.showWindow(self)
	}
    
}
