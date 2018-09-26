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

class AudioViewController: NSViewController {

    var fileToOpen : MMFile = File(filename: "default")
    var fullpath : String = ""
    
    convenience init(file: MMFile) {
        self.init()
        fileToOpen = file
        fullpath = file.path+"/"+file.filename
    }
    
    var soundPlayer =  AVAudioPlayer();
    
    @IBAction func play(_ sender: NSButton) {
            print("playing")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
}
