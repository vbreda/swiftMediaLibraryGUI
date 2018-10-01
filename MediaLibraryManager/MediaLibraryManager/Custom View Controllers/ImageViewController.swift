//
//  ViewController.swift
//  MediaLibraryManager
//
//  Created by Vivian Breda Bezerra Rego on 9/25/18.
//  Copyright © 2018 Nikolah Pearce. All rights reserved.
//

import Cocoa

/**
The View Controller for our Image media.
Sets up and displays the media.
*/
class ImageViewController: NSViewController {
    
    var fileToOpen : MMFile = File(filename: "default")
    var fullpath : String = ""
    
    @IBOutlet weak var imageView: NSImageView!
	
	/**
	Initialises the View Controller with a specific file as the start point.
	Sets the fullpath.
	*/
	convenience init(file: MMFile) {
		self.init()
		fileToOpen = file
		fullpath = file.path+"/"+file.filename
	}
	
	/**
	Called when the view loaded successfully.
	Shows the media file.
	*/
    override func viewDidLoad() {
        super.viewDidLoad()
        showImage()
    }
    
    func showImage() {
        let directory : String = NSString(string: fullpath).expandingTildeInPath
        imageView.image = NSImage(contentsOfFile: directory)
    }
}
