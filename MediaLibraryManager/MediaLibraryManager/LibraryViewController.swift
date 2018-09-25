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
	@IBOutlet weak var searchTextField: NSTextField!
	@IBOutlet weak var searchButton: NSButton!
	@IBOutlet weak var addBookmarkButton: NSButton!
    @IBOutlet weak var importFilesButton: NSButton!
	
//	var libraryViewController : LibraryViewController = LibraryViewController()
//	var mainWindowController : LibraryMainWindow = LibraryMainWindow()
	
	var filesInTable : [MMFile] = []
	
	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.delegate = self
		tableView.dataSource = self
		LibraryMainWindow.model.libraryDelegate = self
		tableView.doubleAction = #selector(tableViewDoubleClick(_:))
		
//		libraryViewController = self.view.window?.contentViewController as! LibraryViewController
//		mainWindowController = self.view.window?.windowController as! LibraryMainWindow
	}
	
    @IBAction func importFilesButtonAction(_ sender: Any) {
		
		//TODO put the open panel back!
//        let openPanel : NSOpenPanel = NSOpenPanel()
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
//				tableView.reloadData()
//				updateStatus()
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
		tableView.reloadData()
		updateStatus()
		
	}
    
	
    @IBAction func addBookmarkButtonAction(_ sender: Any) {
        // Check what is selected in the table view
        var filesToSave : [MMFile] = []
		let numItemsSelected = tableView.selectedRowIndexes.count
        // build this files array
        // Create a new result set from the selected files
        LibraryMainWindow.model.last = MMResultSet()
        
    }

    
    @IBAction func searchButtonAction(_ sender: Any) {
        
        let searchTerm : String = searchTextField.stringValue
        let commandInput = "list \(searchTerm)"
        
        LibraryMainWindow.model.runCommand(input: commandInput)
		do {
			changeFilesInTable(newFiles: try LibraryMainWindow.model.last.getAll())
		} catch { }
		tableView.noteNumberOfRowsChanged()
		tableView.reloadData();
    }
	
	// Required function to conform to LibraryDelegate
	func tableDataDidChange() {
		tableView.reloadData()
	}
	
	// Updates the data field of filesInTable
	func changeFilesInTable(newFiles: [MMFile]) {
		filesInTable = newFiles
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
			text = "\(LibraryMainWindow.model.library.count) items"
		} else {
			text = "\(numItemsSelected) of \(LibraryMainWindow.model.library.count) selected"
		}
		statusLabel.stringValue = text
	}
	
	/**
	Respond to double clickings a file
	*/
	@objc func tableViewDoubleClick(_ sender:AnyObject) {
		
		guard tableView.selectedRow >= 0 else {
				return
		}
		let numItemsSelected = tableView.selectedRowIndexes.count
		let item = filesInTable[tableView.selectedRow]
		
		
		// Open the file in MediaViewerWindow if only one selected
		if numItemsSelected == 1 {
			// Open the media viewer right away, only one file
			LibraryMainWindow.newViewerWindow(file: item)
			print("Double clicked to open: \(item.filename)")
		} else {
			print("double clicked more than one!!!!!")
		}

		
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
    }
}
