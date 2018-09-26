//
//  LibraryViewController.swift
//  MediaLibraryManager
//
//  Created by Nikolah Pearce on 20/09/18.
//  Copyright © 2018 Nikolah Pearce. All rights reserved.
//

import Cocoa

class LibraryViewController: NSViewController, ModelLibraryDelegate {
	
	@IBOutlet weak var tableView: NSTableView!
	@IBOutlet weak var statusLabel: NSTextField!

    @IBOutlet weak var importFilesButton: NSButton!
	@IBOutlet weak var exportFilesButton: NSButton!
	@IBOutlet weak var openViewerButton: NSButton!
	@IBOutlet weak var addBookmarkButton: NSButton!
	
	@IBOutlet weak var searchTextField: NSTextField!
	@IBOutlet weak var searchButton: NSButton!
	
	var filesInTable : [MMFile] = []
	
	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.delegate = self
		tableView.dataSource = self
		LibraryMainWindow.model.libraryDelegate = self
		tableView.doubleAction = #selector(tableViewDoubleClick(_:))
		openViewerButton.isEnabled = false
		addBookmarkButton.isEnabled = false
		searchButton.isEnabled = false
		exportFilesButton.isEnabled = false
	}
	
    @IBAction func importFilesButtonAction(_ sender: Any) {
		
		//TODO put the open panel back!
//        let openPanel : NSOpenPanel = NSOpenPanel()
//        let userChoice = openPanel.runModal()
//
//		  openPanel.allowedFileTypes=["json"]
//        switch userChoice {
//        case .OK :
//            let panelResult = openPanel.url
//            if let panelResult = panelResult {
//
//                let filename : String = panelResult.absoluteString
//                var commandInput: String = ""
//
//                commandInput += "load "
//                commandInput += filename
//
//                LibraryMainWindow.model.runCommand(input: commandInput)
//				LibraryMainWindow.model.makeInitialBookmarks()
//				changeFilesInTable(newFiles: LibraryMainWindow.model.library.all())
//				tableDataDidChange()
//            }
//        case .cancel :
//            print("> user cancelled importing files")
//        default:
//            print("> An open panel will never return anything other than OK or cancel")
//        }
//
		let filename : String = "~/346/media/jsonData.json"
		var commandInput: String = ""

		commandInput += "load "
		commandInput += filename

		LibraryMainWindow.model.runCommand(input: commandInput)
		LibraryMainWindow.model.makeInitialBookmarks()
		changeFilesInTable(newFiles: LibraryMainWindow.model.library.all())
		tableDataDidChange()
	}
	
	/**
	Exports the selected files (or all) and saves as a .json
	*/
	@IBAction func exportFIlesButtonAction(_ sender: Any) {
		
		guard filesInTable.count >= 0 else {
			return
		}
		
		let numItemsSelected = tableView.selectedRowIndexes.count
		let indexSetOfFiles = tableView.selectedRowIndexes
		let indexes = Array(indexSetOfFiles)
		var filesToSave : [MMFile] = []
		var commandInput : String = ""
		
		if numItemsSelected == 0 {
			// Save the entire table view
			filesToSave = filesInTable
		} else {
			// Save-search
			for i in indexes {
				filesToSave.append(filesInTable[i])
			}
		}
		
		let savePanel : NSSavePanel = NSSavePanel()
		let userChoice = savePanel.runModal()

		switch userChoice {
		case .OK :
			let url = savePanel.directoryURL
			let panelResult = url?.path
			let filename = savePanel.nameFieldStringValue
			
			if let panelResult = panelResult {

				// Success place specified so save!
				commandInput += "save-search "
				commandInput += panelResult
				commandInput += "/"
				commandInput += filename
				
				LibraryMainWindow.model.last = MMResultSet(filesToSave)
				LibraryMainWindow.model.runCommand(input: commandInput)
				
			}
		case .cancel :
			print("> user cancelled exporting files")
		default:
			print("> An open panel will never return anything other than OK or cancel")
		}

	}
	
	/**
	Adds a new bookmark based on the user's currrent selection.
	Prompts for bookmark name via NSAlert with NSTextField.
	*/
    @IBAction func addBookmarkButtonAction(_ sender: Any) {
		
        // Check what is selected in the table view
		let numItemsSelected = tableView.selectedRowIndexes.count
		
		// Prompt for a name for the bookmark
		let newBookmarkName = getString(title: "New Bookmark Name:", question: "Please enter a name for your bookmark. You cannot use the same name as already existing bookmark.", defaultValue: "New Bookmark")
		
		let allBookmarks = LibraryMainWindow.model.getBookmarkNames()
		
		// Check if the name will overwrite existing bookmark
		if allBookmarks.contains(newBookmarkName) {
			let canEdit : Bool = LibraryMainWindow.bookmarksVC.checkBookmarkIsEditable(bookmark: newBookmarkName)
			if !canEdit {
				// Bookmark is one of the permanent, cannot overwrite
				LibraryMainWindow.bookmarksVC.alertUserOfForbidden(bookmark: newBookmarkName)
			} else {
				// Prompt user to convirm overwrite
				let msg = NSAlert()
				msg.addButton(withTitle: "Yes")
				msg.addButton(withTitle: "Cancel")
				msg.messageText = "Overwrite Bookmark"
				msg.informativeText = "A bookmark with that name already exists. Are you sure you wish to overwrite these  the bookmark '\(newBookmarkName)?'"
				
				let response: NSApplication.ModalResponse = msg.runModal()
				if (response == NSApplication.ModalResponse.alertFirstButtonReturn) {
					if numItemsSelected == 1 {
						let fileIndex = tableView.selectedRow
						let file = filesInTable[fileIndex]
						LibraryMainWindow.model.addBookmarks(name: newBookmarkName, files: [file])
					} else {
						let indexSetOfFiles = tableView.selectedRowIndexes
						let indexes = Array(indexSetOfFiles)
						var filesToSave : [MMFile] = []
						for i in indexes {
							filesToSave.append(filesInTable[i])
						}
						LibraryMainWindow.model.addBookmarks(name: newBookmarkName, files: filesToSave)
					}
				} else {
					return
				}
			}
		} else {
			// New bookmark name, nothing overwritten, simply create it
			if numItemsSelected == 1 {
				let fileIndex = tableView.selectedRow
				let file = filesInTable[fileIndex]
				LibraryMainWindow.model.addBookmarks(name: newBookmarkName, files: [file])
			} else {
				let indexSetOfFiles = tableView.selectedRowIndexes
				let indexes = Array(indexSetOfFiles)
				var filesToSave : [MMFile] = []
				for i in indexes {
					filesToSave.append(filesInTable[i])
				}
				LibraryMainWindow.model.addBookmarks(name: newBookmarkName, files: filesToSave)
			}
		}
    }

	/**
	Alternative to double clicking a file name
	*/
	@IBAction func openViewerButtonAction(_ sender: Any) {
		guard tableView.selectedRow >= 0 else {
			return
		}
		let numItemsSelected = tableView.selectedRowIndexes.count
		let item = filesInTable[tableView.selectedRow]
		
		// Open the file in MediaViewerWindow if only one selected
		if numItemsSelected == 1 {
			// Open the media viewer right away, only one file
//            LibraryMainWindow.newViewerWindow(file: item)
            LibraryMainWindow.newViewerWindow(file: item, files: filesInTable)

		} else {
			// TODO
		}	
	}
	
	/**
	Prompt the user to enter some text e.g. the Book
	*/
	func getString(title: String, question: String, defaultValue: String) -> String {
		let msg = NSAlert()
		msg.addButton(withTitle: "OK")      // 1st button
		msg.addButton(withTitle: "Cancel")  // 2nd button
		msg.messageText = title
		msg.informativeText = question
		
		let txt = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
		txt.stringValue = defaultValue
		
		msg.accessoryView = txt
		let response: NSApplication.ModalResponse = msg.runModal()
		
		if (response == NSApplication.ModalResponse.alertFirstButtonReturn) {
			return txt.stringValue
		} else {
			return ""
		}
	}
	
	/**
	Actions that occurs when user clicks the search button
	*/
    @IBAction func searchButtonAction(_ sender: Any) {
        
        let searchTerm : String = searchTextField.stringValue
        let commandInput = "list \(searchTerm)"
        LibraryMainWindow.model.runCommand(input: commandInput)
		do {
			changeFilesInTable(newFiles: try LibraryMainWindow.model.last.getAll())
		} catch { }
		
		tableDataDidChange()
    }
	
	/**
	Finds the selected files, and removes these from the current bookmark
	*/
	func removeFilesFromTable(bookmark: String) {
		
		let numFiles = tableView.selectedRowIndexes.count
		let msg = NSAlert()
		msg.addButton(withTitle: "Yes")
		msg.addButton(withTitle: "Cancel")
		msg.messageText = "Delete Files from Bookmark"
		if numFiles == 1 {
			msg.informativeText = "Are you sure you wish to remove \(filesInTable[tableView.selectedRow].filename) from the bookmark '\(bookmark)?'"
		} else {
			msg.informativeText = "Are you sure you wish to remove \(numFiles) files from the bookmark '\(bookmark)?'"

		}
		
		let response: NSApplication.ModalResponse = msg.runModal()
		
		if (response == NSApplication.ModalResponse.alertFirstButtonReturn) {
			var filesToDelete : [MMFile] = []
			var filesToKeep :[MMFile] = []
			let indexSetOfFiles = tableView.selectedRowIndexes
			let indexes = Array(indexSetOfFiles)
			var n : Int = 0
			while n < filesInTable.count {
				if indexes.contains(n) {
					// We don't want this file
					filesToDelete.append(filesInTable[n])
				} else {
					// We do want this file
					filesToKeep.append(filesInTable[n])
				}
				n += 1
			}
			LibraryMainWindow.model.addBookmarks(name: bookmark, files: filesToKeep)
			changeFilesInTable(newFiles: filesToKeep)
			tableDataDidChange()
		} else {
			return
		}

	}
	
	// Required function to conform to LibraryDelegate
	func tableDataDidChange() {
		tableView.reloadData()
		manageButtons()
		updateStatus()
	}
	
	// Updates the data field of filesInTable
	func changeFilesInTable(newFiles: [MMFile]) {
		filesInTable = newFiles
	}
	
	/**
	Disables and enables the buttons based upon whats selected in the table
	*/
	func manageButtons() {
		
		importFilesButton.isEnabled = true
		let numItemsSelected = tableView.selectedRowIndexes.count

		if filesInTable.count == 0 {
			searchButton.isEnabled = false
			exportFilesButton.isEnabled = false
			LibraryMainWindow.bookmarksVC.toggleRemoveFilesButton(isOn: false)
		} else {
			searchButton.isEnabled = true
			exportFilesButton.isEnabled = true
			
			if numItemsSelected == 0 {
				// no files selected
				openViewerButton.isEnabled = false
				addBookmarkButton.isEnabled = false
				LibraryMainWindow.bookmarksVC.toggleRemoveFilesButton(isOn: false)
			} else if numItemsSelected == 1 {
				// 1 file selected
				openViewerButton.isEnabled = true
				addBookmarkButton.isEnabled = true
				LibraryMainWindow.bookmarksVC.toggleRemoveFilesButton(isOn: true)
			} else {
				// more than one file selected
				openViewerButton.isEnabled = false
				addBookmarkButton.isEnabled = true
				LibraryMainWindow.bookmarksVC.toggleRemoveFilesButton(isOn: true)
			}
		}
	}
	
	
	/**
	Updates the label at bottom of table.
	Shows the total items and those selected.
	*/
	func updateStatus() {
		let text: String
		let numItemsSelected = tableView.selectedRowIndexes.count
		
		if LibraryMainWindow.model.library.count == 0 {
			text = "No items"
		} else if numItemsSelected == 0 {
			text = "\(filesInTable.count) items"
		} else {
			text = "\(numItemsSelected) of \(filesInTable.count) selected"
		}
		statusLabel.stringValue = text
	}
	
	/**
	Respond to double clickings a file
	*/
	@objc func tableViewDoubleClick(_ sender:AnyObject) {
		openViewerButtonAction(self)
	}
}


extension LibraryViewController : NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
		return filesInTable.count
    }
}


extension LibraryViewController : NSTableViewDelegate {
    
    fileprivate enum CellIdentifiers {
        
        static let CellNumber = "CellNumberID"
        static let CellName = "CellNameID"
        static let CellType = "CellTypeID"
        static let CellCreator = "CellCreatorID"
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        var text: String = ""
        var cellIdentifier: String = ""
        
		let item = filesInTable[row]
        
        if tableColumn == tableView.tableColumns[0] {
            text = String(row+1)
            cellIdentifier = CellIdentifiers.CellNumber
        } else if tableColumn == tableView.tableColumns[1] {
            text = item.filename
            cellIdentifier = CellIdentifiers.CellName
        } else if tableColumn == tableView.tableColumns[2] {
            text = item.type
            cellIdentifier = CellIdentifiers.CellType
        } else if tableColumn == tableView.tableColumns[3] {
            text = item.creator
            cellIdentifier = CellIdentifiers.CellType
        }
        
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
        return nil
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        updateStatus()
		manageButtons()
    }
}
