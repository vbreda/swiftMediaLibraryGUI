//
//  VideoViewController.swift
//  MediaLibraryManager
//
//  Created by Vivian Breda Bezerra Rego on 9/26/18.
//  Copyright © 2018 Nikolah Pearce. All rights reserved.
//

import Cocoa
import AVFoundation;
import AVKit;

class VideoViewController: NSViewController {

    var fileToOpen : MMFile = File(filename: "default")
    var fullpath : String = ""
    
    convenience init(file: MMFile) {
        self.init()
        fileToOpen = file
        fullpath = file.path+"/"+file.filename
    }
    
    var playView = AVPlayer();
    
    @IBOutlet weak var videoView: AVPlayerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showVideo()
    }
    
    func showVideo() {
        let filepath : String = NSString(string: fullpath).expandingTildeInPath
        let fileURL = NSURL(fileURLWithPath: filepath)
        print("Printing filepath: \(filepath)")
        playView = AVPlayer(url: fileURL as URL)
        videoView.player = playView
    }
}
