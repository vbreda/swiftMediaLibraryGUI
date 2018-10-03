//
//  DocumentViewController.swift
//  MediaLibraryManager
//
//  Created by Vivian Breda Bezerra Rego on 9/26/18.
//  Copyright © 2018 Nikolah Pearce. All rights reserved.
//

import Cocoa
import Quartz

/**
The View Controller for our Document media.
Sets up and displays the media.
*/
class DocumentViewController: NSViewController {
    
    var fileToOpen : MMFile = File(filename: "default")
    var fullpath : String = ""
	
    @IBOutlet weak var documentView: NSScrollView!
    @IBOutlet var textView: NSTextView!
    @IBOutlet weak var pdfView: PDFView!
    @IBOutlet weak var failIndicator: NSProgressIndicator!
    @IBOutlet weak var failMessage: NSTextField!
	
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
        failIndicator.isHidden = true
        failMessage.isHidden = true
        super.viewDidLoad()
        showText()
    }
	
    func showText() {
        
        let filepath : String = NSString(string: fullpath).expandingTildeInPath
        let separateExtension: [String] = fileToOpen.filename.split(separator: ".").map({String($0)})
        let ext : String = separateExtension[1]
        
        if(ext == "txt") {
			do {
				let contents = try String(contentsOfFile: filepath)
				textView.string = contents;
				textView.isEditable = false ;
			} catch {}
        } else if (ext == "pdf") {
            //pdfView.image = NSImage(contentsOfFile: filepath)
                let url = URL(fileURLWithPath: filepath)
                if let pdfDocument = PDFDocument(url: url) {
                    pdfView.displayMode = .singlePageContinuous
                    pdfView.autoScales = true
                    // pdfView.displayDirection = .horizontal
                    pdfView.document = pdfDocument
            }
        } else {
            failIndicator.isHidden = false
            failIndicator.startAnimation(self)
            failMessage.isHidden = false
        }
    }
    
}
