//
//  VideoViewController.swift
//  MediaLibraryManager
//
//  Created by Nikolah Pearce and Vivian Breda on 9/26/18.
//  Copyright © 2018 Nikolah Pearce and Vivian Breda. All rights reserved.
//

import Cocoa
import AVFoundation;
import AVKit;

/**
The View Controller for our Video media.
Sets up and displays the media.
*/
class AVViewController: NSViewController {

    var fileToOpen : MMFile = File(filename: "default")
    var fullpath : String = ""
    var playView = AVPlayer();
    
    @IBOutlet weak var avView: AVPlayerView!
    
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
        showAV()
    }
	
	/**
	Sets up the necessary components to display the video.
	Leaves it at ready to play (when user chooses
     */
    func showAV() {
        let filepath : String = NSString(string: fullpath).expandingTildeInPath
        let fileURL = NSURL(fileURLWithPath: filepath)
//        print("Printing filepath: \(filepath)")
        playView = AVPlayer(url: fileURL as URL)
        avView.player = playView
    }
}
