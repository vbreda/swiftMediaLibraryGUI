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
		
		let filename: String = "~/346/media/jsonData.json"
		
		var commandInput: String = ""
		
		commandInput += "load "
		commandInput += filename
		
		//let main : LibraryModel = LibraryModel()
		
		LibraryMainWindow.model.runCommand(input: commandInput)
		
		// Populate table
		
	}
	
	@IBOutlet weak var addBookmarkButton: NSButton!
	
	@IBAction func addBookmarkButtonAction(_ sender: Any) {
		// Check what is selected in the table view
		var filesToSave : [MMFile] = []
		// build this files array
		
		// Create a new result set from the selected files
		LibraryMainWindow.model.last = MMResultSet()
		
		
		let commandInput = "save-search newFilename.json"
		LibraryMainWindow.model.runCommand(input: commandInput)
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
