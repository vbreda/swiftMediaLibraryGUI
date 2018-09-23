//
//  LibraryViewController.swift
//  MediaLibraryManager
//
//  Created by Nikolah Pearce on 20/09/18.
//  Copyright © 2018 Nikolah Pearce. All rights reserved.
//

import Cocoa

class LibraryViewController: NSViewController {
    
    @IBOutlet weak var importFilesButton: NSButton!
    @IBOutlet weak var tableView: NSTableView!
    
    @IBAction func importFilesButtonAction(_ sender: Any) {
        
        let openPanel : NSOpenPanel = NSOpenPanel()
        let userChoice = openPanel.runModal()
        
        switch userChoice {
        case .OK :
            let panelResult = openPanel.url
            if let panelResult = panelResult {
                
                let filename : String = panelResult.absoluteString
                var commandInput: String = ""
                
                commandInput += "load "
                commandInput += filename
                
                LibraryMainWindow.model.runCommand(input: commandInput)
                LibraryMainWindow.model.makeInitialBookmarks()
                
                tableView.reloadData()
                
            }
        case .cancel :
            print("> user cancelled importing files")
        default:
            print("> An open panel will never return anything other than OK or cancel")
        }
    }
    
    @IBOutlet weak var addBookmarkButton: NSButton!
    
    @IBAction func addBookmarkButtonAction(_ sender: Any) {
        // Check what is selected in the table view
        var filesToSave : [MMFile] = []
        // build this files array
        
        // Create a new result set from the selected files
        LibraryMainWindow.model.last = MMResultSet()
        
    }
    
    @IBOutlet weak var searchTextField: NSTextField!
    
    @IBOutlet weak var searchButton: NSButton!
    
    @IBAction func searchButtonAction(_ sender: Any) {
        
        let searchTerm : String = searchTextField.stringValue
        let commandInput = "list \(searchTerm)"
        
        LibraryMainWindow.model.runCommand(input: commandInput)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
}

extension LibraryViewController : NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return LibraryMainWindow.model.library.count
    }
}

extension LibraryViewController : NSTableViewDelegate {
    
    fileprivate enum CellIdentifiers {
        
        static let CellNumber = "CellNumberID"
        static let CellName = "CellNameID"
        static let CellType = "CellTypeID"
        static let CellCreator = "CellCreatorID"
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        var text: String = ""
        var cellIdentifier: String = ""
        
        let item = LibraryMainWindow.model.library.all()[row]
        
        if tableColumn == tableView.tableColumns[0] {
            text = String(row+1)
            cellIdentifier = CellIdentifiers.CellNumber
            
        } else if tableColumn == tableView.tableColumns[1] {
            text = item.filename
            cellIdentifier = CellIdentifiers.CellName
        } else if tableColumn == tableView.tableColumns[2] {
            text = item.type
            cellIdentifier = CellIdentifiers.CellType
        } else if tableColumn == tableView.tableColumns[3] {
            text = item.creator
            cellIdentifier = CellIdentifiers.CellType
        }
        
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
        return nil
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        // updateStatus()
    }
}
