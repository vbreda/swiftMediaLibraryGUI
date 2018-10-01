//
//  LibraryViewController.swift
//  MediaLibraryManager
//
//  Created by Nikolah Pearce on 20/09/18.
//  Copyright © 2018 Nikolah Pearce and Vivian Breda. All rights reserved.
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
    static var rowSelection : Int = 0
	
	/**
	Called when the view loaded successfully.
	Sets the delegates, and disables some buttons.
	*/
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
	
	/**
	Prompts the user with an NSOpenPanel to choose a .json file.
	Calles the import command and populates the table.
	*/
    @IBAction func importFilesButtonAction(_ sender: Any) {
		
//        let openPanel : NSOpenPanel = NSOpenPanel()
//		openPanel.allowedFileTypes = ["json", "JSON"]
//        let userChoice = openPanel.runModal()
//
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
        LibraryMainWindow.model.runCommand(input: "list")
	}
	
	/**
	Exports the selected files (or all) and saves as a .json file.
	Uses the path as specified by the Save panel.
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
				// Successful place specified so save!
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
	Adds a new bookmark based on the user's currrent file selection.
	Prompts for bookmark name via NSAlert with an NSTextField.
	*/
    @IBAction func addBookmarkButtonAction(_ sender: Any) {
		
        // Check what is selected in the table view
		let numItemsSelected = tableView.selectedRowIndexes.count
		
		// Prompt for a name for the bookmark
        if let newBookmarkName = getString(title: "New Bookmark Name:", question: "Please enter a name for your bookmark. You cannot use the same name as already existing bookmark.", defaultValue: "New Bookmark") {

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
                    msg.informativeText = "A bookmark with that name already exists. Are you sure you wish to overwrite the bookmark '\(newBookmarkName)?'"
                    
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
						// User did not chose Cancel, so do nothing.
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
    }

	/**
	Alternative to double clicking a file name.
	Opens the Media Viewer Window
	*/
	@IBAction func openViewerButtonAction(_ sender: Any) {
        LibraryViewController.rowSelection = tableView.selectedRow
        guard LibraryViewController.rowSelection >= 0 else {
			return
		}
		let numItemsSelected = tableView.selectedRowIndexes.count

		// Open the file in MediaViewerWindow if only one selected
		if numItemsSelected == 1 {
            let index = tableView.selectedRow
            LibraryMainWindow.newViewerWindow(index: index, files: filesInTable)
		} else {
			return
		}	
	}
	
	/**
	Prompt the user to enter some text e.g. the Bookmarks new name.
	- parameter title: the title of the Alert prompt.
	- parameter question: the full text question to inform user.
	- parameter defaultValue: the placeholder string to put in the text field.
	- returns: String?: the text entered by the user or nil.
	
	@author Marc Fearby on Stack Overflow, + minor changes by Nikolah.
	*/
	func getString(title: String, question: String, defaultValue: String) -> String? {
		let msg = NSAlert()
		msg.addButton(withTitle: "OK")      // 1st button
		msg.addButton(withTitle: "Cancel")  // 2nd button
		msg.messageText = title
		msg.informativeText = question
		
		let txt = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
		txt.placeholderString = defaultValue
		msg.accessoryView = txt
		let response: NSApplication.ModalResponse = msg.runModal()
		
		if (response == NSApplication.ModalResponse.alertFirstButtonReturn) {
            guard txt.stringValue.count >= 1 else {
                return nil
            }
			return txt.stringValue
		} else {
			return nil
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
			let results = try LibraryMainWindow.model.last.getAll()
			changeFilesInTable(newFiles: results)
		} catch {
			print("catched in search")
		}
		
		tableDataDidChange()
    }
	
	/**
	Finds the selected files, and removes these from the current bookmark.
	- parameter bookmark: the name of the bookmark to delete from.
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
	/**
	Delegate method. Called whenever the Model's library changes.
	Reload the table data, also updates the buttons and the status label.
	*/
	func tableDataDidChange() {
		tableView.reloadData()
		manageButtons()
		updateStatus()
	}
	
	/**
	Updates the variable that is the files in the table.
	Allows a new set of files to be displayed.
	- parameter newFiles: the new files to be displayed.
	*/
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
//			searchButton.isEnabled = false
			exportFilesButton.isEnabled = false
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
	Respond to double clickings a file.
	The same as choosing 'open media' button from the window.
	Simply a shortcut that calls the aove button's action.
	*/
	@objc func tableViewDoubleClick(_ sender:AnyObject) {
		openViewerButtonAction(self)
	}
}

/**
Extension that confirms to the NSTableViewDataSource.
Allows us to define the number of rows in our table.
*/
extension LibraryViewController : NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
		return filesInTable.count
    }
}

/**
Extension that conforms to the NSTableViewDelegate.
Allows the table data to be filled.
*/
extension LibraryViewController : NSTableViewDelegate {
	
	/**
	Enum to store the Cell Identifiers of the table.
	*/
    fileprivate enum CellIdentifiers {
        
        static let CellNumber = "CellNumberID"
        static let CellName = "CellNameID"
        static let CellType = "CellTypeID"
        static let CellCreator = "CellCreatorID"
		static let CellNotes = "CellNotesID"
    }
	
	/**
	Called when the table needs to reload data.
	*/
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
            text = item.type.capitalized
            cellIdentifier = CellIdentifiers.CellType
        } else if tableColumn == tableView.tableColumns[3] {
            text = item.creator
            cellIdentifier = CellIdentifiers.CellType
		} else if tableColumn == tableView.tableColumns[4] {
			text = item.notes
			cellIdentifier = CellIdentifiers.CellType
		}
        
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
        return nil
    }
	
	/**
	In built delegate method that is called whenever the selection within the table changes.
	Updates the buttons and status to reflect the new changes
	*/
    func tableViewSelectionDidChange(_ notification: Notification) {
        updateStatus()
		manageButtons()
    }
}
