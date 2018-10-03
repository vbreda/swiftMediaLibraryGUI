//
//  MediaLibraryManagerTests.swift
//  MediaLibraryManagerTests
//
//  Created by Nikolah Pearce on 18/09/18.
//  Copyright © 2018 Nikolah Pearce. All rights reserved.
//

import XCTest
@testable import MediaLibraryManager

class MediaLibraryManagerTests: XCTestCase {
    
	var model = LibraryModel()
	
	/**
	Called before every test to set up conditions as expected.
	*/
    override func setUp() {
        super.setUp()

        print("setting up for tests")
		let filename : String = "~/346/media/jsonData.json"
		var commandInput: String = ""
		commandInput += "load "
		commandInput += filename

		model.runCommand(input: commandInput)
		model.makeInitialBookmarks()
		LibraryMainWindow.libraryVC.changeFilesInTable(newFiles: model.library.all())
		LibraryMainWindow.libraryVC.tableDataDidChange()
    }
	
	/**
	Called after every test to tear down any changed conditions.
	*/
    override func tearDown() {
		model = LibraryModel()
		LibraryMainWindow.libraryVC.changeFilesInTable(newFiles: [])
		LibraryMainWindow.libraryVC.tableDataDidChange()
        super.tearDown()
    }
	
	/**
	Tests the import files to works as expected.
	*/
	func testImportWorks() {
		let filename : String = "~/346/media/jsonData.json"
		var commandInput: String = ""
		commandInput += "load "
		commandInput += filename
		
		let mockModel = LibraryModel()
		assert(mockModel.library.count == 0, "Mock should have 0 files before loading")
		mockModel.runCommand(input: commandInput)
		
		// Note if the JSON data is not in home > 346 > media for the test to read
		// this test will definitely fail! Please copy JSON data to the directory.
		assert(mockModel.library.count == 14, "Mock should have 14 files")

	}
	
	/**
	Tests the permanent bookmarks are made as expected.
	*/
	func testMakeInitialBookmarks() {
		let filename : String = "~/346/media/jsonData.json"
		var commandInput: String = ""
		commandInput += "load "
		commandInput += filename
		
		let mockModel = LibraryModel()
		assert(mockModel.numBookmarks == 0, "No bookmarks should exist yet")
		mockModel.runCommand(input: commandInput)
		mockModel.makeInitialBookmarks()
		assert(mockModel.numBookmarks == 5, "All permanent bookmarks should have been created")
	}
	
	/**
	Tests the import button on the homescreen load the library.
	*/
    func testFilesInTable() {
		let libraryFiles = LibraryMainWindow.model.library.all()
        assert(libraryFiles.count == 0, "There should be no files in the proper library yet.")
		let filesInTable = LibraryMainWindow.libraryVC.filesInTable
		assert(filesInTable.count == model.library.count, "The files displayed should match our mock library.")
    }
	
	/**
	Tests the adding a bookmark through the model.
	*/
    func testAddBookmark() {
		assert(model.numBookmarks == 5, "only the permanent bookmarks should have been created")
		model.addBookmarks(name: "test", files: [])
		assert(model.numBookmarks == 6, "Now there should be 6 bookmarks")
	}
	
	/**
	Tests the retrieving of bookmarks through the model.
	*/
	func testGetBookmarks() {
		assert(model.numBookmarks == 5, "only the permanent bookmarks should have been created")
		
		let bookmarkNames = model.getBookmarkNames()
		assert(bookmarkNames.count == 5, "only the permanent bookmarks should have been created")
		let bookmarks = model.getBookmarks()
		assert(bookmarks.count == 5, "only the permanent bookmarks should have been created")
		
		assert(bookmarkNames.contains("1. All"), "All bookmark should exist")
		assert(!bookmarkNames.contains("testtttt"), "Test bookmark should not exist")
	}
	
	/**
	Tests the deleting a permanent bookmark through the model.
	*/
	func testDeletePermanentBookmark() {
		assert(model.numBookmarks == 5, "only the permanent bookmarks should have been created")
		model.deleteBookmark(name: "1. All")
		assert(model.numBookmarks == 4, "Bookmarks should have been deleted as model does not care for 'permanent'.")
	}
	
	/**
	Tests the deleting a bookmark the user made through the model.
	*/
	func testDeleteUserMadeBookmark() {
		assert(model.numBookmarks == 5, "only the permanent bookmarks should have been created")
		model.addBookmarks(name: "test", files: [])
		assert(model.numBookmarks == 6, "Now there should be 6 bookmarks")
		model.deleteBookmark(name: "test")
		assert(model.numBookmarks == 5, "Bookmarks should have been deleted.")
	}
    
}
