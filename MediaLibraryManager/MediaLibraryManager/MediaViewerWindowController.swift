//
//  MediaViewerWindowController.swift
//  MediaLibraryManager
//
//  Created by Nikolah Pearce on 23/09/18.
//  Copyright © 2018 Nikolah Pearce. All rights reserved.
//

import Cocoa

//public protocol MediaViewerDelegate {
//    
//}

class MediaViewerWindowController: NSWindowController {

    @IBOutlet weak var customView: NSView!
    @IBOutlet var viewerWindow: NSWindow!
    @IBOutlet weak var editDetails: NSSegmentedControl!
    @IBOutlet weak var detailsView: NSTableView!
    
    var fileToOpen: MMFile = File(filename: "MLM - Media Viewer")
    var allFiles: [MMFile] = []
    
	convenience init() {
		self.init(windowNibName: NSNib.Name(rawValue: "MediaViewerWindowController"));
	}

	/**
	Initialises the new controller with a specific file as the start point.
	*/
	convenience init(file: MMFile) {
		self.init(windowNibName: NSNib.Name(rawValue: "MediaViewerWindowController"));
		fileToOpen = file
	}
    
    /**
     Initialises the new controller with a specific file as the start point.
     */
    convenience init(file: MMFile, files: [MMFile]) {
        self.init(windowNibName: NSNib.Name(rawValue: "MediaViewerWindowController"));
        fileToOpen = file
        allFiles = files
    }
	
    override func windowDidLoad() {
        super.windowDidLoad()
        detailsView.delegate = self
        detailsView.dataSource = self
		viewerWindow.title = "Viewing \(fileToOpen.filename)"
		setCorrectController()
    }
	
    @IBAction func editDetailsAction(_ sender: Any) {
        var commandInput : String = ""
        
        if (editDetails.isSelected(forSegment: 0)) {
            print("ADD")
        } else {
            let row = detailsView.selectedRow
            let selectedFile = LibraryViewController.rowSelection
            commandInput = "del \(selectedFile) \(fileToOpen.metadata[row].keyword)"
            LibraryMainWindow.model.runCommand(input: commandInput)
            detailsView.reloadData()
        }
        //TODO make it overwrite the file instead of just re-adding all the info
        //commandInput = "save ~/346/media/jsonData"
        LibraryMainWindow.model.runCommand(input: commandInput)
    }
    
	/**
	Based upon the file type, set the current View Controller
	*/
	func setCorrectController() {
                switch (fileToOpen.type) {
                    case "document" :
                        let documentView = DocumentViewController(file: fileToOpen)
                        documentView.view.setFrameOrigin(NSPoint(x:0, y:0))
                        documentView.view.setFrameSize(customView.frame.size)
                        customView.addSubview(documentView.view)
                       // documentView.textView.isEditable = true
                    
                    case "image" :
                        let imageView = ImageViewController(file: fileToOpen)
                        imageView.view.setFrameOrigin(NSPoint(x:0, y:0))
                        imageView.view.setFrameSize(customView.frame.size)
                        customView.addSubview(imageView.view)
                    case "video" :
                        let videoView = VideoViewController(file: fileToOpen)
                        videoView.view.setFrameOrigin(NSPoint(x:0, y:0))
                        videoView.view.setFrameSize(customView.frame.size)
                        customView.addSubview(videoView.view)
                    case "audio" :
                        let audioView = AudioViewController(file: fileToOpen)
                        audioView.view.setFrameOrigin(NSPoint(x:0, y:0))
                        audioView.view.setFrameSize(customView.frame.size)
                        customView.addSubview(audioView.view)
                    default:
                        print("")

                }
        detailsView.reloadData()
	}
	
	/**
	Reset the file being show. If it is different type, reset the type of view controller too
	*/
	func updateCurrentViewController(file: MMFile) {
		let oldFileType = self.fileToOpen.type
		self.fileToOpen = file
		if oldFileType != fileToOpen.type {
			setCorrectController()
		}
	}
}


extension MediaViewerWindowController : NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return fileToOpen.metadata.count
    }
}

extension MediaViewerWindowController : NSTableViewDelegate {

    fileprivate enum CellIdentifiers {
        static let KeywordCell = "CellKeywordID"
        static let ValueCell = "CellValueID"
    }
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {

        var text: String = ""
        var cellIdentifier: String = ""

        let item = fileToOpen.metadata[row]

        if tableColumn == detailsView.tableColumns[0] {
            text = item.keyword
            cellIdentifier = CellIdentifiers.KeywordCell
        } else if tableColumn == detailsView.tableColumns[1] {
            text = item.value
            cellIdentifier = CellIdentifiers.ValueCell
        }

       if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
        return nil
    }

//    func tableViewSelectionDidChange(_ notification: Notification) {
//        updateStatus()
//        manageButtons()
//    }
}

