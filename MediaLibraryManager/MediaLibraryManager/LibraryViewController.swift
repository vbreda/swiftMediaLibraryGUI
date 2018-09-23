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
	}
	
	@IBOutlet weak var addBookmarkButton: NSButton!
	
	@IBAction func addBookmarkButtonAction(_ sender: Any) {
	}
	
	@IBOutlet weak var searchTextField: NSTextField!
	
	@IBOutlet weak var searchButton: NSButton!
	
	@IBAction func searchButtonAction(_ sender: Any) {
		
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
