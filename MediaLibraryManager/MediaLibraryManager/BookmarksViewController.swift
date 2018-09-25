//
//  BookmarksViewController.swift
//  MediaLibraryManager
//
//  Created by Nikolah Pearce on 20/09/18.
//  Copyright © 2018 Nikolah Pearce. All rights reserved.
//

import Cocoa

public protocol BookmarksViewDelegate {
	func selectionDidChange()
}

class BookmarksViewController: NSViewController, ModelBookmarksDelegate {
	

	@IBOutlet weak var labelBookmarks: NSTextField!
	@IBOutlet weak var statusLabel: NSTextField!
	@IBOutlet weak var tableView: NSTableView!
	
	var delegate : BookmarksViewDelegate? = nil
//	var libraryViewController : LibraryViewController = LibraryViewController()
//	var mainWindowController : LibraryMainWindow = LibraryMainWindow()
	
	var fontSize = (NSFont.systemFontSize(for: NSControl.ControlSize.regular) + 2)
	
	
	override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
		tableView.delegate = self
		tableView.dataSource = self
		tableView.allowsMultipleSelection = false
//		tableView.allowsEmptySelection = false
		LibraryMainWindow.model.bookmarksDelegate = self
		
//		libraryViewController = self.view.window?.contentViewController as! LibraryViewController
//		let mainWindowController = self.view.window?.windowController as! LibraryMainWindow
    }
	
	// Delegate method
	func tableDataDidChange() {
		tableView.reloadData()
		updateStatus()
	}
	
	/**
	Updates the label at bottom of table.
	Shows the total items and those selected.
	*/
	func updateStatus() {
		let text: String
		if LibraryMainWindow.model.numBookmarks == 0 {
			text = "No bookmarks"
		} else {
			text = "\(LibraryMainWindow.model.numBookmarks) bookmarks"
		}
		statusLabel.stringValue = text
	}
}


extension BookmarksViewController : NSTableViewDataSource {
	
	func numberOfRows(in tableView: NSTableView) -> Int {
		return LibraryMainWindow.model.numBookmarks
	}
}

extension BookmarksViewController : NSTableViewDelegate {
	
	fileprivate enum CellIdentifiers {
		static let CellNumber = "CellBookmark"
	}
	
	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		
		let cellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "CellBookmark"), owner: self) as! NSTableCellView
		
		let textField = cellView.textField!
		textField.textColor = NSColor.black
		
		let fontDescriptor = textField.font!.fontDescriptor
		textField.font = NSFont(descriptor: fontDescriptor, size: self.fontSize)
		
		let item = LibraryMainWindow.model.getBookmarkNames()[row]
		textField.stringValue = item
		textField.sizeToFit()
		textField.setFrameOrigin(NSZeroPoint)
		
		tableView.rowHeight = textField.frame.height + 2
		
		return cellView
	}
	
	/**
	When a new bookmark is selected, open it!
	*/
	func tableViewSelectionDidChange(_ notification: Notification) {
		
		guard tableView.selectedRow > 0 else {
			return
		}
		
		let bookmark = LibraryMainWindow.model.getBookmarkNames()[tableView.selectedRow]
		let files = LibraryMainWindow.model.getBookmarkValues(key: bookmark)
		
		if files.count == 1 {
			// Open the media viewer right away, only one file
			LibraryMainWindow.newViewerWindow(file: files[0])
			print("single clicked: \(bookmark)")
		} else {
			// update LibraryViewController tableView
			print("should update table view")
			LibraryMainWindow.libraryVC.changeFilesInTable(newFiles: files)
			LibraryMainWindow.libraryVC.tableDataDidChange()
			//	libraryViewController.changeFilesInTable(newFiles: files)
		}
		
		
	}
	
}
