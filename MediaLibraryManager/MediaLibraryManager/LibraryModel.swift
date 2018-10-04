//
//  LibraryModel.swift
//  MediaLibraryManager
//
//  Created by Nikolah Pearce on 23/09/18.
//  Copyright © 2018 Nikolah Pearce and Vivian Breda. All rights reserved.
//

import Foundation

/**
Protocol that alerts the BookmarksViewController.
Whenever the Bookmarks change within the Model.
*/
public protocol ModelBookmarksDelegate {
	func tableDataDidChange()
}

/**
Protocol that alerts the LibraryViewController.
Whenever the Files change within the Model's library.
*/
public protocol ModelLibraryDelegate {
	func tableDataDidChange()
}

/**
Library Model - the base of the MVC pattern.
Similar to the main.swift of asgn1.
Creates an instance of the Library and handles the bookmarks.
Handles all commands for interacting with the library.
*/
public class LibraryModel {
	
	var library : Library = Library()
	var last = MMResultSet()
	var bookmarks : [String: [MMFile]] = [:]
	var filesFromTable : [MMFile] = []
	
	public var bookmarksDelegate: ModelBookmarksDelegate? = nil;
	public var libraryDelegate: ModelLibraryDelegate? = nil;

	// Returns the number of current bookmarks
	var numBookmarks : Int {
		get {
			return bookmarks.count
		}
	}
	
	init() { }
	
	/**
	Alert delegate 1.
	Called whenever the bookmarks are edited.
	*/
	func alertBookmarksDelegate() {
		bookmarksDelegate?.tableDataDidChange()
	}
	
	/**
	Alert delegate 2 + 3.
	Called whenever the library's files may be edited.
	*/
	func alertLibraryDelegate() {
		libraryDelegate?.tableDataDidChange()
	}
	
	/**
	Handles all input commands as per asgn1 terminal prompt.
	Takes input as a string and calls the right command through a switch case.

	- parameter input: the keyword and needed parameters to call the command, as a String.
	*/
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
			case "search-table":
				let newLibrary = Library()
				newLibrary.loadNewFiles(newFiles: filesFromTable)
				command = ListCommand(keyword: parts, library: newLibrary)
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
			print("Oops - a new error. Shouldn't ever be called.")
		}
	}
	
	/**
	Takes files and make a reference in this model.
	Assists with searching only particular bookmark
	- parameter files: the new files to reference.
	*/
	func loadFilesFromTable(files: [MMFile]) {
		self.filesFromTable = files
	}
	
	/**
	Adds notes to a particular file in the library.
	- parameter notes: the String of notes to add.
	- parameter file: the MMFile to add the notes to.
	*/
	func addNotesToFile(notes: String, file: MMFile) {
		library.addNotesToFile(notes: notes, file: file)
		makeInitialBookmarks()
		alertLibraryDelegate()
	}
	
	/**
	Returns all of the currently loaded bookmarks.
	- returns: [String: [MMFile]]: the dictionary of bookmark names and associated files.
	*/
	func getBookmarks() -> [String: [MMFile]] {
		return bookmarks
	}
	
	/**
	Returns the current bookmark names only, as Strings.
	- returns: [String]: the currently loaded bookmark names.
	*/
	func getBookmarkNames() -> [String] {
		let keys : [String] = Array(bookmarks.keys)
		let sortedArray = keys.sorted { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending }
		return sortedArray
	}
	
	/**
	Returns the files associated with a bookmark, given the bookmark name.
	- parameter key: the name of the bookmark.
	- returns: [MMFile]: the files for that bookmark.
	*/
	func getBookmarkValues(key: String) -> [MMFile] {
		if let files : [MMFile] = bookmarks[key] {
			return files
		} else {
			return []
		}
	}
	
	/**
	Adds a new bookmark to the bookmarks dictionary.
	- parameter name: the name of the new bookmark.
	- parameter files: the files to go in that bookmark.
	*/
	func addBookmarks(name: String, files: [MMFile]) {
		bookmarks.updateValue(files, forKey: name)
		alertBookmarksDelegate()
	}
	
	/**
	Deletes a bookmark by its name/key.
	- parameter name: the bookmark name (key) to delete in the boomarks dictionary.
	*/
	func deleteBookmark(name: String) {
		bookmarks[name] = nil
		alertBookmarksDelegate()
	}
	
	/**
	Creates the default bookmarks for newly imported media.
	e.g. All media and the 4 specific types.
	*/
	func makeInitialBookmarks() {
		let b1 = "1. All"
		let b1Files = callListCommand(term: "")
		addBookmarks(name: b1, files: b1Files)
		
		let b2 = "2. Images"
		let b2Files = callListCommand(term: "image")
		addBookmarks(name: b2, files: b2Files)
		
		let b3 = "3. Videos"
		let b3Files = callListCommand(term: "video")
		addBookmarks(name: b3, files: b3Files)
		
		let b4 = "5. Documents"
		let b4Files = callListCommand(term: "document")
		addBookmarks(name: b4, files: b4Files)
		
		let b5 = "4. Audio"
		let b5Files = callListCommand(term: "audio")
		addBookmarks(name: b5, files: b5Files)
		
		alertBookmarksDelegate()
	}
	
	/**
	Call the list commmand on a search term and returns the results.
	- parameter term: the term to search for.
	- returns: [MMFile]: the files found for the search term.
	*/
	func callListCommand(term: String) -> [MMFile] {
		
		var files : [MMFile] = []
		
		var commandInput = "list "
		commandInput += term
		LibraryMainWindow.model.runCommand(input: commandInput)
		
		do {
			try files = LibraryMainWindow.model.last.getAll()
		} catch {
			print("well oops - this should never be called.")
		}
		return files
	}
	
}
