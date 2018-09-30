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

class MediaViewerWindowController: NSWindowController, ModelLibraryDelegate {

    @IBOutlet weak var customView: NSView!
    @IBOutlet var viewerWindow: NSWindow!
    @IBOutlet weak var editDetails: NSSegmentedControl!
    @IBOutlet weak var detailsView: NSTableView!
    
    @IBOutlet var notesTextView: NSTextView!
    @IBOutlet weak var editNotesButton: NSView!
    @IBOutlet weak var saveNotesButton: NSButton!
    
    @IBOutlet weak var previousButton: NSButton!
    @IBOutlet weak var nextButton: NSButton!
    @IBOutlet weak var zoomInButton: NSButton!
    @IBOutlet weak var zoomOutButton: NSButton!
    
    @IBOutlet weak var statusLabel: NSTextField!
    
    var fileToOpen: MMFile = File(filename: "MLM - Media Viewer")
    var allFiles: [MMFile] = []
    var currentFileIndex : Int = -1
	var bookmark: String = ""
	
	/**
	Convenience initialiser that loads the NIB file.
	*/
	convenience init() {
		self.init(windowNibName: NSNib.Name(rawValue: "MediaViewerWindowController"));
	}
    
    /**
	Convenience initialiser that loads the NIB file.
	Initialises the new controller with a specific file as the start point.
	*/
    convenience init(index: Int, files: [MMFile]) {
        self.init(windowNibName: NSNib.Name(rawValue: "MediaViewerWindowController"));
        allFiles = files
        currentFileIndex = index
        fileToOpen = allFiles[currentFileIndex]
    }
	
	/**
	Called when the Window loaded successfully.
	Sets the delegates, and disables some buttons.
	Also sets the Custom View to the correct controller by calling helper method.
	*/
    override func windowDidLoad() {
        super.windowDidLoad()
        detailsView.delegate = self
        detailsView.dataSource = self
		LibraryMainWindow.model.viewerDelegate = self
		notesTextView.isEditable = false
		setCorrectController()
    }
	
    @IBAction func editDetailsAction(_ sender: Any) {
        var commandInput : String = ""
        let selectedFile : Int = currentFileIndex
        
        // Set the last result set to be current bookmark - in case of it wasn't already
        LibraryMainWindow.model.last = MMResultSet(allFiles)
        
        if (editDetails.isSelected(forSegment: 0)) {
            let detailToAdd = getString(title: "Add New Detail to \(fileToOpen.filename):", question: "Please enter a new key-value information. You cannot use a keyword that already exists", defaultValue: "Ex: color purple")
            if (detailToAdd != nil) {
                commandInput = "add \(selectedFile) \(detailToAdd!)"
                LibraryMainWindow.model.runCommand(input: commandInput)
            }
        } else {
            let row = detailsView.selectedRow
			
			// Check that its allowed
			let key = fileToOpen.metadata[row].keyword
			do {
				let isAllowed = try FileValidator.safeToDelete(key: key, typeOfFile: fileToOpen.type)
				if isAllowed {
					commandInput = "del \(selectedFile) \(key)"
					LibraryMainWindow.model.runCommand(input: commandInput)
				}
			} catch {
				print(" Can't do that!!! Deleting required metadata")
				alertUserOfFailure(methodThatFailed: "Deleting Metadata", maintext: "Cannot delete a required metadata keypair for the file type.")
			}
        }
		fileViewingDidChange()
		
        //TODO make it overwrite the file instead of just re-adding all the info
        //commandInput = "save ~/346/media/jsonData"
//        LibraryMainWindow.model.runCommand(input: commandInput)
		
    }
    
    @IBAction func editNotesButtonAction(_ sender: Any) {
		notesTextView.isEditable = true
    }
    
    @IBAction func saveNotesButtonAction(_ sender: Any) {
		let text = notesTextView.string
		LibraryMainWindow.model.library.addNotesToFile(notes: text, file: allFiles[currentFileIndex])
		notesTextView.isEditable = false
    }
    
    @IBAction func previousButtonAction(_ sender: Any) {
		guard currentFileIndex >= 1 else {
			return
		}
		currentFileIndex -= 1
		setCorrectController()
		fileViewingDidChange()
    }
    
    @IBAction func nextButtonAction(_ sender: Any) {
		guard currentFileIndex < allFiles.count else {
			return
		}
		currentFileIndex += 1
		setCorrectController()
		fileViewingDidChange()
    }
    
    @IBAction func zoomInButtonAction(_ sender: Any) {
		print("zoom in +")
    }
    
    @IBAction func zoomOutButtonAction(_ sender: Any) {
		print("zoom out -")
    }
	
	/*
	Delegate method called everytime notes added or other changes to real library files.
	*/
	func tableDataDidChange() {
		
	}
	
    /**
	Based upon the file type, set the current View Controller
	*/
	func setCorrectController() {
		fileToOpen = allFiles[currentFileIndex]
        switch (fileToOpen.type.capitalized) {
            case "Document" :
                let documentView = DocumentViewController(file: fileToOpen)
                documentView.view.setFrameOrigin(NSPoint(x:0, y:0))
                documentView.view.setFrameSize(customView.frame.size)
				self.customView.subviews.removeAll()
                customView.addSubview(documentView.view)
            case "Image" :
                let imageView = ImageViewController(file: fileToOpen)
                imageView.view.setFrameOrigin(NSPoint(x:0, y:0))
                imageView.view.setFrameSize(customView.frame.size)
				self.customView.subviews.removeAll()
                customView.addSubview(imageView.view)
            case "Video" :
                let videoView = VideoViewController(file: fileToOpen)
                videoView.view.setFrameOrigin(NSPoint(x:0, y:0))
                videoView.view.setFrameSize(customView.frame.size)
				self.customView.subviews.removeAll()
                customView.addSubview(videoView.view)
            case "Audio" :
                let audioView = AudioViewController(file: fileToOpen)
                audioView.view.setFrameOrigin(NSPoint(x:0, y:0))
                audioView.view.setFrameSize(customView.frame.size)
				self.customView.subviews.removeAll()
                customView.addSubview(audioView.view)
            default:
                print("")

        }
		viewerWindow.title = "\(fileToOpen.filename)"
        fileViewingDidChange()
	}
	
	/**
	Prompt the user to enter some text e.g. the new metadata key pair.
	- parameter title: the title of the Alert prompt.
	- parameter question: the full text question to inform user.
	- parameter defaultValue: the placeholder string to put in the text field.
	- returns: String?: the metadata keypair entered by the user or nil.
	
	@author Marc Fearby on Stack Overflow, + minor changes by Vivian.
	*/
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
			guard txt.stringValue.count >= 3 else {
				alertUserOfFailure(methodThatFailed: "Adding Metadata", maintext: "Please enter a key followed by a space and then your value. Extra spaces will be ignored.")
				return nil
			}
			let parts = txt.stringValue.split(separator: " ").map({String($0)})
			guard parts.count >= 2 else {
				alertUserOfFailure(methodThatFailed: "Adding Metadata", maintext: "Please enter a key followed by a space and then your value. Extra spaces will be ignored.")
				return nil
			}
            return txt.stringValue
        } else {
            return nil
        }
    }
	
	/**
	Prompts the user with an alert to warn them their metadata deletion failed
	- parameter bookmark:  the name of the bookmark to check.
	*/
	func alertUserOfFailure(methodThatFailed: String, maintext: String) {
		let msg = NSAlert()
		msg.addButton(withTitle: "OK")
		var title = "Error: "
		title += methodThatFailed
		title += " Failure."
		msg.messageText = title
		msg.informativeText = maintext
		let _: NSApplication.ModalResponse = msg.runModal()
		return
	}
    /**
     Disables and enables the buttons based upon whats selected being viewed
     */
    func manageButtons() {
		if currentFileIndex == 0 {
			previousButton.isEnabled = false
		} else {
			previousButton.isEnabled = true
		}
		
		if currentFileIndex == (allFiles.count-1) {
			nextButton.isEnabled = false
		} else {
			nextButton.isEnabled = true
		}
		if allFiles[currentFileIndex].type == "audio" {
			zoomInButton.isEnabled = false
			zoomOutButton.isEnabled = false
		} else {
			zoomInButton.isEnabled = true
			zoomOutButton.isEnabled = true
		}
    }
    
    
    /**
     Updates the label at bottom of table.
     Shows the total items and those selected.
     */
    func updateStatus() {
        var text = "Viewing item "
        text += String(currentFileIndex+1)
        text += " of "
        text += String(allFiles.count)
        statusLabel.stringValue = text
    }
    
    func fileViewingDidChange() {
        detailsView.reloadData()
        notesTextView.string = allFiles[currentFileIndex].notes
        manageButtons()
        updateStatus()
    }
}

/**
Extension the the NSTableViewDataSource that allows us to define the number of rows in our table.
*/
extension MediaViewerWindowController : NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return fileToOpen.metadata.count
    }
}

/**
Extension the the NSTableViewDelegate that allows the table data to be filled.
*/
extension MediaViewerWindowController : NSTableViewDelegate {

    fileprivate enum CellIdentifiers {
        static let KeywordCell = "CellKeywordID"
        static let ValueCell = "CellValueID"
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {

        var text: String = ""
        var cellIdentifier: String = ""

        let item = allFiles[currentFileIndex].metadata[row]

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

