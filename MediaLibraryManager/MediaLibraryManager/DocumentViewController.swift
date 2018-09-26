//
//  DocumentViewController.swift
//  MediaLibraryManager
//
//  Created by Vivian Breda Bezerra Rego on 9/26/18.
//  Copyright © 2018 Nikolah Pearce. All rights reserved.
//

import Cocoa

class DocumentViewController: NSViewController {
    
    var fileToOpen : MMFile = File(filename: "default")
    var fullpath : String = ""
    
    convenience init(file: MMFile) {
        self.init()
        fileToOpen = file
        fullpath = file.path+"/"+file.filename
    }

    @IBOutlet weak var documentView: NSScrollView!
    @IBOutlet var textView: NSTextView!
    @IBOutlet weak var pdfView: NSImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showText()
    }
    
    func showText() {
        
        let filepath : String = NSString(string: fullpath).expandingTildeInPath
        
        print("Printing filepath: \(filepath)")

        let separateExtension: [String] = fileToOpen.filename.split(separator: ".").map({String($0)})
        let ext : String = separateExtension[1]
        
        if(ext == "txt") {
        do {
            let contents = try String(contentsOfFile: filepath)
            print(contents)
            textView.string = contents;
            textView.isEditable = false ;
        } catch {}
        } else if (ext == "pdf") {
            pdfView.image = NSImage(contentsOfFile: filepath)
        } else {
            textView.string = "SORRY, UNABLE TO RETRIEVE DATA. FILE MUST BE .txt OR .pdf";
        }
    }
    
}
