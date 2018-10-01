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
	
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		mainWindow.showWindow(self)
	}

	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

