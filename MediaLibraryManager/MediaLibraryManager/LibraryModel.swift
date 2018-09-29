//
//  LibraryModel.swift
//  MediaLibraryManager
//
//  Created by Nikolah Pearce on 23/09/18.
//  Copyright © 2018 Nikolah Pearce. All rights reserved.
//

import Foundation

public protocol ModelBookmarksDelegate {
	func tableDataDidChange()
}

public protocol ModelLibraryDelegate {
	func tableDataDidChange()
}

public class LibraryModel {
	
	var library : Library = Library()
	var last = MMResultSet()
	var bookmarks : [String: [MMFile]] = [:]
	
	public var bookmarksDelegate: ModelBookmarksDelegate? = nil;
	public var libraryDelegate: ModelLibraryDelegate? = nil;
	public var viewerDelegate: ModelLibraryDelegate? = nil
	
	// Returns the number of current bookmarks
	var numBookmarks : Int {
		get {
			return bookmarks.count
		}
	}
	
	init() { }
	
	// Alert delegate 1
	func alertBookmarksDelegate() {
		bookmarksDelegate?.tableDataDidChange()
	}
	
	// Alert delegate 2
	func alertLibraryDelegate() {
		libraryDelegate?.tableDataDidChange()
		viewerDelegate?.tableDataDidChange()
	}
	
	func runCommand(input: String) {
		
		var parts = input.split(separator: " ").map({String($0)})
		var commandString : String = ""
		var command: MMCommand = HelpCommand()
		
		do {
			guard parts.count > 0 else {
				throw MMCliError.unknownCommand
			}
		
			commandString = parts.removeFirst();
		
			// Handles the commands passed by the user.
			switch(commandString) {
			case "load" :
				command = LoadCommand(loadfiles: parts, library: library)
				alertLibraryDelegate()
				break
			case "list":
				command = ListCommand(keyword: parts, library: library)
				//alertLibraryDelegate()
				break
			case "add":
				command = AddCommand(data: parts, library: library, lastsearch: try last.getAll())
				alertLibraryDelegate()
				break
			case "set":
				command = SetCommand(data: parts, library: library, lastsearch: try last.getAll())
				alertLibraryDelegate()
				break
			case "del":
				command = DeleteCommand(data: parts, library: library, lastsearch: try last.getAll())
				alertLibraryDelegate()
				break
			case "save-search":
				command = SaveSearchCommand(data: parts, lastsearch: try last.getAll())
				break
			case "save":
				command = SaveCommand(data: parts, library: library)
			case "help":
				command = HelpCommand()
				break
			case "quit":
				command = QuitCommand()
				break
			default:
				throw MMCliError.unknownCommand
			}
		
			// try execute the command and catch any thrown errors below.
			try command.execute()
		
			// if there are any results from the command, print them out here.
			if let results = command.results {
				results.show()
				last = results
			}
			
		
		} catch MMCliError.unknownCommand {
			print("Command \"\(commandString)\" not found -- see \"help\" for list.")
		} catch MMCliError.invalidParameters {
			print("Invalid parameters for \"\(commandString)\" -- see \"help\" for list.")
		} catch MMCliError.unimplementedCommand {
			print("\"\(commandString)\" is unimplemented.")
		} catch MMCliError.missingResultSet {
			print("No previous results to work from.")
		} catch MMCliError.dataDoesntExist {
			print("Provided term could not be found. Try again.")
		} catch MMCliError.indexOutOfRange {
			print("Index provided is out of bounds. Try again.")
		} catch MMCliError.removingRequiredKey {
			print("Cannot remove required metadata for File. Try again.")
		} catch MMCliError.invalidType {
			print("Invalid file type, expecting image document audio or video.")
		} catch MMCliError.invalidMetadataForType {
			print("Invalid metadata for provided media type.")
		} catch MMCliError.invalidJsonFile {
			print("Invalid JSON file...")
			print("\tCheck your filename and/or contents and try again.")
		} catch MMCliError.libraryEmpty {
			print("Library is empty. Load files and try again.")
		} catch MMCliError.writeFailure {
			print("Unable to write JSON file...")
			print("\tCheck your last search and try again.")
		} catch MMCliError.duplicateMetadataKey {
			print("Attempting to add duplicate metadata. Try 'set' instead.")
		} catch {
			print("Oops - a new error")
		}
	}
	
	/*
	Adds notes to a particular file in the library.
	*/
	func addNotesToFile(notes: String, file: MMFile) {
		library.addNotesToFile(notes: notes, file: file)
		makeInitialBookmarks()
		alertLibraryDelegate()
	}
	
	/*
	Returns the current bookmarks.
	*/
	func getBookmarks() -> [String: [MMFile]] {
		return bookmarks
	}
	
	/*
	Returns the current bookmark names only
	*/
	func getBookmarkNames() -> [String] {
		let keys : [String] = Array(bookmarks.keys)
		let sortedArray = keys.sorted { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending }
		return sortedArray
	}
	
	/*
	Returns the file list of a bookmark given the bookmark name.
	*/
	func getBookmarkValues(key: String) -> [MMFile] {
		if let files : [MMFile] = bookmarks[key] {
			return files
		} else {
			return []
		}
	}
	
	/**
	Adds a new bookmark to the bookmarks dictionary
	*/
	func addBookmarks(name: String, files: [MMFile]) {
		bookmarks.updateValue(files, forKey: name)
		alertBookmarksDelegate()
	}
	
	/**
	Deletes a bookmark by its name/key
	*/
	func deleteBookmark(name: String) {
		bookmarks[name] = nil
		alertBookmarksDelegate()
	}
	
	/**
	Creates the default bookmarks for newly imported media
	*/
	func makeInitialBookmarks() {
		// Create bookmark for ALL, images, documents, audios, videos.
		
		let b1 = "All"
		let b1Files = callListCommand(term: "")
		addBookmarks(name: b1, files: b1Files)
		
		let b2 = "Images"
		let b2Files = callListCommand(term: "image")
		addBookmarks(name: b2, files: b2Files)
		
		let b3 = "Videos"
		let b3Files = callListCommand(term: "video")
		addBookmarks(name: b3, files: b3Files)
		
		let b4 = "Documents"
		let b4Files = callListCommand(term: "document")
		addBookmarks(name: b4, files: b4Files)
		
		let b5 = "Audio"
		let b5Files = callListCommand(term: "audio")
		addBookmarks(name: b5, files: b5Files)
		
		alertBookmarksDelegate()
	}
	
	/**
	Call the list commmand on a search term.
	Return the files found if
	*/
	func callListCommand(term: String) -> [MMFile] {
		
		var files : [MMFile] = []
		
		var commandInput = "list "
		commandInput += term
		LibraryMainWindow.model.runCommand(input: commandInput)
		
		do {
			try files = LibraryMainWindow.model.last.getAll()
		} catch {
			print("well oops - what happened here? ---------------")
		}
		return files
	}
	
}
