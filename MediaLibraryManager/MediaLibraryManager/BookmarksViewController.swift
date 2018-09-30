//
//  BookmarksViewController.swift
//  MediaLibraryManager
//
//  Created by Nikolah Pearce on 20/09/18.
//  Copyright © 2018 Nikolah Pearce. All rights reserved.
//

import Cocoa

/**
View Controller that handles the bookmarks side bar.
*/
class BookmarksViewController: NSViewController, ModelBookmarksDelegate {
	
	@IBOutlet weak var labelBookmarks: NSTextField!
	@IBOutlet weak var statusLabel: NSTextField!
	@IBOutlet weak var tableView: NSTableView!
	@IBOutlet weak var deleteButton: NSButton!
	@IBOutlet weak var removeFilesFromButton: NSButton!
	
	// Variable that allows the bookmakrs table font to be larger than standard.
	var fontSize = (NSFont.systemFontSize(for: NSControl.ControlSize.regular) + 2)
	
	/**
	Called when the view loaded successfully.
	Sets the delegates, and disables some buttons.
	*/
	override func viewDidLoad() {
        super.viewDidLoad()
		tableView.delegate = self
		tableView.dataSource = self
		tableView.allowsMultipleSelection = false
		tableView.allowsEmptySelection = false
		LibraryMainWindow.model.bookmarksDelegate = self
		deleteButton.isEnabled = false
		removeFilesFromButton.isEnabled = false
	}
	
	/**
	Allows the user to delete a bookmark.
	The button is only enabled when there are bookmarks to delete.
	*/
	@IBAction func deleteButtonAction(_ sender: Any) {
		let bookmark = LibraryMainWindow.model.getBookmarkNames()[tableView.selectedRow]
		
		let canEdit : Bool = checkBookmarkIsEditable(bookmark: bookmark)
		if !canEdit{
			alertUserOfForbidden(bookmark: bookmark)
		} else {
			let msg = NSAlert()
			msg.addButton(withTitle: "OK")
			msg.addButton(withTitle: "Cancel")
			msg.messageText = "Delete bookmark"
			msg.informativeText = "Are you sure you wish to delete the bookmark '\(bookmark)?'"

			let response: NSApplication.ModalResponse = msg.runModal()
			if (response == NSApplication.ModalResponse.alertFirstButtonReturn) {
				LibraryMainWindow.model.deleteBookmark(name: bookmark)
			} else {
				return
			}
		}
	}
	
	/**
	Removes specific files from bookmark that is currently open.
	*/
	@IBAction func removeFilesFromButtonAction(_ sender: Any) {
		let bookmark = LibraryMainWindow.model.getBookmarkNames()[tableView.selectedRow]
		let canEdit : Bool = checkBookmarkIsEditable(bookmark: bookmark)
		if !canEdit {
			alertUserOfForbidden(bookmark: bookmark)
		} else {
			LibraryMainWindow.libraryVC.removeFilesFromTable(bookmark: bookmark)
		}
	}
	
	/**
	Toggles whether the button needs to be enabled or disabled, based upon the selections in LibraryVC.
	- paramater isOn: whether the button should be enabled or not.
	*/
	func toggleRemoveFilesButton(isOn: Bool) {
		let bookmark = LibraryMainWindow.model.getBookmarkNames()[tableView.selectedRow]
		let canEdit : Bool = checkBookmarkIsEditable(bookmark: bookmark)
		if !canEdit {
			removeFilesFromButton.isEnabled = false
		} else if isOn {
			removeFilesFromButton.isEnabled = true
		} else {
			removeFilesFromButton.isEnabled = false
		}
	}
	
	/**
	Prompts the user with an alert to warn them they cannot do that.
	- parameter bookmark:  the name of the bookmark to check.
	*/
	func alertUserOfForbidden(bookmark: String) {
		let msg = NSAlert()
		msg.addButton(withTitle: "OK")
		msg.messageText = "Error: Permanent Bookmark"
		msg.informativeText = "You cannot change or remove the permanent bookmark '\(bookmark)'. These are managed by the system."
		let _: NSApplication.ModalResponse = msg.runModal()
		return
	}
	
	/**
	Check action is allowed on this bookmark.
	- parameter bookmark:  the name of the bookmark to check.
	*/
	func checkBookmarkIsEditable(bookmark: String) -> Bool {
		if bookmark == "All" ||  bookmark == "Images" ||  bookmark == "Audio" ||  bookmark == "Documents" ||  bookmark == "Videos" {
			return false
		} else {
			return true
		}
	}

	/*
	Delegate method.
	Called whenevere the Model has a change in its bookmarks.
	*/
	func tableDataDidChange() {
		tableView.reloadData()
		updateStatus()
	}
	
	/*
	Updates the label at bottom of table.
	Shows the total items and those selected.
	Also adjusts the delete button depending on the current bookmark.
	*/
	func updateStatus() {
		let text: String
		if LibraryMainWindow.model.numBookmarks == 0 {
			deleteButton.isEnabled = false
			text = "No bookmarks"
		} else {
			
			let bookmark = LibraryMainWindow.model.getBookmarkNames()[tableView.selectedRow]
			let canEdit : Bool = checkBookmarkIsEditable(bookmark: bookmark)
			if !canEdit {
				deleteButton.isEnabled = false
			} else {
				deleteButton.isEnabled = true
			}
			text = "\(LibraryMainWindow.model.numBookmarks) bookmarks"
		}
		statusLabel.stringValue = text
	}
}

/**
Extension that confirms to the NSTableViewDataSource.
Allows us to define the number of rows in our table.
*/
extension BookmarksViewController : NSTableViewDataSource {
	
	func numberOfRows(in tableView: NSTableView) -> Int {
		return LibraryMainWindow.model.numBookmarks
	}
}

/**
Extension that conforms to the NSTableViewDelegate.
Allows the table data to be filled.
*/
extension BookmarksViewController : NSTableViewDelegate {
	
	/**
	Enum to store the Cell Identifiers of the table.
	*/
	fileprivate enum CellIdentifiers {
		static let CellNumber = "CellBookmark"
	}
	
	/**
	Called when the table needs to reload data.
	*/
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
		
		let index = NSIndexSet(index: 0)
		self.tableView.scrollRowToVisible(0)
		self.tableView.selectRowIndexes(index as IndexSet, byExtendingSelection: true)
		
		return cellView
	}
	
	/**
	In built delegate method that is called whenever the selection within the table changes.
	When a new bookmark is selected, we open it!
	*/
	func tableViewSelectionDidChange(_ notification: Notification) {
		let bookmark = LibraryMainWindow.model.getBookmarkNames()[tableView.selectedRow]
		let files = LibraryMainWindow.model.getBookmarkValues(key: bookmark)
		LibraryMainWindow.libraryVC.changeFilesInTable(newFiles: files)
		LibraryMainWindow.libraryVC.tableDataDidChange()
		updateStatus()
	}
	
}
