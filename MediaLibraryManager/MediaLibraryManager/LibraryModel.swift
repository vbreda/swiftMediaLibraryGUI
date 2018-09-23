//
//  LibraryModel.swift
//  MediaLibraryManager
//
//  Created by Nikolah Pearce on 23/09/18.
//  Copyright © 2018 Nikolah Pearce. All rights reserved.
//

import Foundation

public class LibraryModel {
	
	var library : Library = Library()
	var last = MMResultSet()
	
	init() {
		
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
				break
			case "list":
				command = ListCommand(keyword: parts, library: library)
				break
			case "add":
				command = AddCommand(data: parts, library: library, lastsearch: try last.getAll())
				break
			case "set":
				command = SetCommand(data: parts, library: library, lastsearch: try last.getAll())
				break
			case "del":
				command = DeleteCommand(data: parts, library: library, lastsearch: try last.getAll())
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
			case "test":
				command = TestCommand()
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

	
}
