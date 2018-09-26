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
	@IBOutlet weak var deleteButton: NSButton!
	@IBOutlet weak var removeFilesFromButton: NSButton!
	
	var delegate : BookmarksViewDelegate? = nil
	var fontSize = (NSFont.systemFontSize(for: NSControl.ControlSize.regular) + 2)
	var currentNumBookmarks : Int = 0
	
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
	Allows the user to rename the bookmark
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
	Removes specific files from this bookmark.
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
	*/
	func toggleRemoveFilesButton(isOn: Bool) {
		removeFilesFromButton.isEnabled = isOn
	}
	
	/**
	Prompts the user with an alert to warn them they cannot do that.
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
	Check action is allowed on this bookmark
	*/
	func checkBookmarkIsEditable(bookmark: String) -> Bool {
		if bookmark == "All" ||  bookmark == "Images" ||  bookmark == "Audio" ||  bookmark == "Documents" ||  bookmark == "Videos" {
			return false
		} else {
			return true
		}
	}

	/**
	Delegate method
	*/
	func tableDataDidChange() {
		// TODO
		if currentNumBookmarks == 0 {
			currentNumBookmarks = LibraryMainWindow.model.numBookmarks
		}
		if currentNumBookmarks == LibraryMainWindow.model.numBookmarks {
			tableView.reloadDataKeepingSelection()
		} else {
			tableView.reloadData()
		}
		updateStatus()
	}
	
	/**
	Updates the label at bottom of table.
	Shows the total items and those selected.
	*/
	func updateStatus() {
		let text: String
		if LibraryMainWindow.model.numBookmarks == 0 {
			deleteButton.isEnabled = false
			text = "No bookmarks"
		} else {
			deleteButton.isEnabled = true
			text = "\(LibraryMainWindow.model.numBookmarks) bookmarks"
		}
		statusLabel.stringValue = text
	}

}

extension NSTableView {
	func reloadDataKeepingSelection() {
		let selectedRowIndexes = self.selectedRowIndexes
		self.reloadData()
		self.selectRowIndexes(selectedRowIndexes, byExtendingSelection: true)
		print("attempting to maintain selection!!! -----------------------------")
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
		
		let index = NSIndexSet(index: 0)
		self.tableView.scrollRowToVisible(0)
		self.tableView.selectRowIndexes(index as IndexSet, byExtendingSelection: true)
		
		return cellView
	}
	
	/**
	When a new bookmark is selected, open it!
	*/
	func tableViewSelectionDidChange(_ notification: Notification) {

		let bookmark = LibraryMainWindow.model.getBookmarkNames()[tableView.selectedRow]
		let files = LibraryMainWindow.model.getBookmarkValues(key: bookmark)
		
		if files.count == 1 {
			// Open the media viewer right away, only one file
//			LibraryMainWindow.newViewerWindow(file: files[0])
			print("single clicked: \(bookmark)")
			LibraryMainWindow.libraryVC.changeFilesInTable(newFiles: files)
			LibraryMainWindow.libraryVC.tableDataDidChange()
		} else {
			// update LibraryViewController tableView
			print("single clicked should open: \(bookmark)")
			LibraryMainWindow.libraryVC.changeFilesInTable(newFiles: files)
			LibraryMainWindow.libraryVC.tableDataDidChange()
		}
	}
	
}
