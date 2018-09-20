//
//  AppDelegate.swift
//  MediaLibraryManager
//
//  Created by Nikolah Pearce on 18/09/18.
//  Copyright © 2018 Nikolah Pearce. All rights reserved.
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


}

