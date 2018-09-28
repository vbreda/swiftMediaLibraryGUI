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
    @IBOutlet weak var notesView: NSTextField!
    @IBOutlet weak var addNotes: NSButton!
    
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
        notesView.isEnabled = false
		setCorrectController()
    }
	
    @IBAction func editDetailsAction(_ sender: Any) {
        var commandInput : String = ""
        let selectedFile = LibraryViewController.rowSelection
        
        if (editDetails.isSelected(forSegment: 0)) {
            let detailToAdd = getString(title: "Add New Detail to \(fileToOpen.filename):", question: "Please enter a new key-value information. You cannot use a keyword that already exists", defaultValue: "Ex: color purple")
            if (detailToAdd != nil) {
                commandInput = "add \(selectedFile) \(detailToAdd!)"
                LibraryMainWindow.model.runCommand(input: commandInput)
                detailsView.reloadData()
            }
        } else {
            let row = detailsView.selectedRow
            commandInput = "del \(selectedFile) \(fileToOpen.metadata[row].keyword)"
            LibraryMainWindow.model.runCommand(input: commandInput)
            detailsView.reloadData()
        }
        //TODO make it overwrite the file instead of just re-adding all the info
        //commandInput = "save ~/346/media/jsonData"
//        LibraryMainWindow.model.runCommand(input: commandInput)
    }
    
    @IBAction func addNotesAction(_ sender: Any) {
        
    }
    
    
    
    /**
	Based upon the file type, set the current View Controller
	*/
	func setCorrectController() {
                switch (fileToOpen.type.capitalized) {
                    case "Document" :
                        let documentView = DocumentViewController(file: fileToOpen)
                        documentView.view.setFrameOrigin(NSPoint(x:0, y:0))
                        documentView.view.setFrameSize(customView.frame.size)
                        customView.addSubview(documentView.view)
                       // documentView.textView.isEditable = true
                    
                    case "Image" :
                        let imageView = ImageViewController(file: fileToOpen)
                        imageView.view.setFrameOrigin(NSPoint(x:0, y:0))
                        imageView.view.setFrameSize(customView.frame.size)
                        customView.addSubview(imageView.view)
                    case "Video" :
                        let videoView = VideoViewController(file: fileToOpen)
                        videoView.view.setFrameOrigin(NSPoint(x:0, y:0))
                        videoView.view.setFrameSize(customView.frame.size)
                        customView.addSubview(videoView.view)
                    case "Audio" :
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
    
    func getString(title: String, question: String, defaultValue: String) -> String? {
        let msg = NSAlert()
        msg.addButton(withTitle: "OK")      // 1st button
        msg.addButton(withTitle: "Cancel")  // 2nd button
        msg.messageText = title
        msg.informativeText = question
        
        let txt = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        txt.placeholderString = defaultValue
        
        msg.accessoryView = txt
        let response: NSApplication.ModalResponse = msg.runModal()
        
        if (response == NSApplication.ModalResponse.alertFirstButtonReturn) {
            return txt.stringValue
        } else {
            return nil
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
            text = item.keyword.capitalized
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

