//
//  LibraryViewController.swift
//  MediaLibraryManager
//
//  Created by Nikolah Pearce on 20/09/18.
//  Copyright © 2018 Nikolah Pearce. All rights reserved.
//

import Cocoa

class LibraryViewController: NSViewController {

	@IBOutlet weak var importFilesButton: NSButton!
	
	@IBAction func importFilesButtonAction(_ sender: Any) {
		
		let openPanel : NSOpenPanel = NSOpenPanel()
		let userChoice = openPanel.runModal()
		
		switch userChoice {
		case .OK :
			let panelResult = openPanel.url
			if let panelResult = panelResult {
				
				let filename : String = panelResult.absoluteString
				var commandInput: String = ""
				
				commandInput += "load "
				commandInput += filename
				
				LibraryMainWindow.model.runCommand(input: commandInput)
				LibraryMainWindow.model.makeInitialBookmarks()
				
			}
		case .cancel :
			print("> user cancelled importing files")
		default:
			print("> An open panel will never return anything other than OK or cancel")
		}
	}
	
	@IBOutlet weak var addBookmarkButton: NSButton!
	
	@IBAction func addBookmarkButtonAction(_ sender: Any) {
		// Check what is selected in the table view
		var filesToSave : [MMFile] = []
		// build this files array
		
		// Create a new result set from the selected files
		LibraryMainWindow.model.last = MMResultSet()
		
		}
	
	@IBOutlet weak var searchTextField: NSTextField!
	
	@IBOutlet weak var searchButton: NSButton!
	
	@IBAction func searchButtonAction(_ sender: Any) {
		
		let searchTerm : String = searchTextField.stringValue
		let commandInput = "list \(searchTerm)"
		
		LibraryMainWindow.model.runCommand(input: commandInput)
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
	
	

    
}
