//
//  AppDelegate.swift
//  MediaLibraryManager
//
//  Created by Nikolah Pearce and Vivian Breda on 18/09/18.
//  Copyright © 2018 Nikolah Pearce and Vivian Breda. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

	let mainWindow = LibraryMainWindow()
	let saveStateIn : String = "library-backup.json"
	let saveStateOut : String = "library-backup"
	
	/**
	Called when the application launches succesfully.
	Our first chance for an interaction with the user.
	Prompts user to choose to open new library or reload last files.
	*/
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		mainWindow.showWindow(self)

		// Look for any previously saved library state
		let working = FileManager.default.currentDirectoryPath
		let fullStringPath = "\(working)/\(saveStateIn)"
//        print("")
//        print("\(fullStringPath)")
//        print("")
		let fileDoesExist = FileManager.default.fileExists(atPath: fullStringPath)
		if fileDoesExist {
			// State exists, ask the user if they want to use it
			let needToOpenSavedState = userWantsToSaveState(title:"Open Previous Library State?", text:"Would you like to open the same files as you had last opened?")
			if needToOpenSavedState {
				// If use chose yes, load it
				LibraryMainWindow.libraryVC.loadAtStart(filename: fullStringPath)
			}
		} else {
			// Error loading the saved state
			print("> No previously saved state.")
		}
	}

	/**
	Called when the application is about to close
	Our last chance for an interaction with the user.
	Prompts user to choose to open new library or reload last files.
	*/
	func applicationWillTerminate(_ aNotification: Notification) {
		let userWantsToSave = userWantsToSaveState(title:"Save Current Library", text:"Would you like to save the current state of your library, in order for it to be available next time you open the application?")
		if userWantsToSave {
			LibraryMainWindow.model.runCommand(input: "save \(saveStateOut)")
		}
	}

	/**
	Allows our application to fully quit if the user closes all windows.
	*/
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
	
	/**
	Prompt the user to save their library is they hit close.
	*/
	func userWantsToSaveState(title: String, text: String) -> Bool {
		let msg = NSAlert()
		msg.addButton(withTitle: "Yes")
		msg.addButton(withTitle: "No")
		msg.messageText = title
		msg.informativeText = text
		let response: NSApplication.ModalResponse = msg.runModal()
		if (response == NSApplication.ModalResponse.alertFirstButtonReturn) {
			return true
		} else {
			return false
		}
	}
}

