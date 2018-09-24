//
//  BookmarksViewController.swift
//  MediaLibraryManager
//
//  Created by Nikolah Pearce on 20/09/18.
//  Copyright © 2018 Nikolah Pearce. All rights reserved.
//

import Cocoa

class BookmarksViewController: NSViewController, BookmarksDelegate {
	

	@IBOutlet weak var labelBookmarks: NSTextField!
	
	@IBOutlet weak var labelTotalBookmarks: NSTextField!
	
	@IBOutlet weak var tableView: NSTableView!
	
	var fontSize = (NSFont.systemFontSize(for: NSControl.ControlSize.regular) + 2)
	
	
	override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
		tableView.delegate = self
		tableView.dataSource = self
		LibraryMainWindow.model.bookmarksDelegate = self
		
    }
	
	// Delegate method
	func tableDataDidChange() {
		tableView.reloadData()
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
		
//		cellView.textField?.textColor = NSColor.black
		
		return cellView
//
//		var text: String = ""
//		var cellIdentifier: String = ""
//
//		let item = LibraryMainWindow.model.getBookmarkNames()[row]
//
//		if tableColumn == tableView.tableColumns[0] {
//			text = String(item)
//			cellIdentifier = CellIdentifiers.CellNumber
//		}
//
//		if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
//			cell.textField?.stringValue = text
//			return cell
//		}
//		return nil
	}
	
	func tableViewSelectionDidChange(_ notification: Notification) {
		// updateStatus()
	}
	
}
