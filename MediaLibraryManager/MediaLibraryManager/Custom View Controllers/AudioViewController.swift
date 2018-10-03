//
//  AudioViewController.swift
//  MediaLibraryManager
//
//  Created by Vivian Breda Bezerra Rego on 9/26/18.
//  Copyright © 2018 Nikolah Pearce. All rights reserved.
//

import Cocoa
import AVFoundation;
import AVKit;

/**
The View Controller for our Audio media.
Sets up and displays the media.
*/
class AudioViewController: NSViewController {

    var fileToOpen : MMFile = File(filename: "default")
    var fullpath : String = ""
    var soundPlayer =  AVAudioPlayer();
	
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
        callAudioShow()
	}
    
    func callAudioShow() {
        do {
            let filepath : String = NSString(string: fullpath).expandingTildeInPath
            print("Filepath: \(filepath)")
            let fileURL = NSURL(fileURLWithPath: filepath)
            soundPlayer = try AVAudioPlayer(contentsOf: fileURL as URL)
            print("Am I an audio?")
            soundPlayer.prepareToPlay()
            
        } catch {
        }
    }
	
    @IBAction func play(_ sender: NSButton) {
            print("playing")
    }
	

    
}
