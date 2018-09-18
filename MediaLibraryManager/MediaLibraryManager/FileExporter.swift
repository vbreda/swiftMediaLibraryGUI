//
//  FileExporter.swift
//  MediaLibraryManager
//
//  Created by Nikolah Pearce and Vivian Breda on 14/08/18.
//  Copyright © 2018 Paul Crane. All rights reserved.
//

import Foundation

class FileExporter: MMFileExport {
    
    /**
      Support exporting the media collection to a file (by name).
     
      - parameter filename: The name of the file to be created.
      - parameter items: What to export into the file.
     */
    func write(filename: String, items: [MMFile]) throws {
        
        var expFiles = [Media]()
        var mdata = [String:String]()
        
        // Fills up the Media struct with the files and metadata to save.
        for f in items {
            mdata = [:]
            for m in f.metadata {
                mdata.updateValue(m.value, forKey: m.keyword)
            }
            let filetoAdd = Media(fullpath: "\(f.path)/\(f.filename)", type: f.type, metadata: mdata)
            expFiles.append(filetoAdd)
        }
        
        // Determines the directory of the users.
        let fileManager = FileManager.default
        var fileToWrite: URL
        
        if filename.hasPrefix("/") || filename.hasPrefix("~") {
            let fname = ("\(filename).json")
            let directory = NSString(string: fname).expandingTildeInPath
            fileToWrite = URL(fileURLWithPath: directory)
        } else {
            let working = fileManager.currentDirectoryPath
            let workingDirectory = URL(fileURLWithPath: working)
            
            fileToWrite = workingDirectory.appendingPathComponent("\(filename).json")
        }
        
        // Serialises the data out to file.
        do {
            let encodedData = try JSONEncoder().encode(expFiles)
            try encodedData.write(to: fileToWrite)
        } catch {
			throw MMCliError.writeFailure
        }
    }
}
