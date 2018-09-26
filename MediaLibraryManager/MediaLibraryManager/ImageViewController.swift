//
//  ViewController.swift
//  MediaLibraryManager
//
//  Created by Vivian Breda Bezerra Rego on 9/25/18.
//  Copyright © 2018 Nikolah Pearce. All rights reserved.
//

import Cocoa

class ImageViewController: NSViewController {
    
    var fileToOpen : MMFile = File(filename: "default")
    var fullpath : String = ""
    
    convenience init(file: MMFile) {
        self.init()
        fileToOpen = file
        fullpath = file.path+"/"+file.filename
    }
    
    
    @IBOutlet weak var imageView: NSImageView!
    
    func showImage() {
        let directory : String = NSString(string: fullpath).expandingTildeInPath
        print("showImage(): \(directory)")
        imageView.image = NSImage(contentsOfFile: directory)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showImage()
    }
    
}
