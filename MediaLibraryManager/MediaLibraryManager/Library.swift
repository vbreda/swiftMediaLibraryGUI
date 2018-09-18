//
//  MediaLibrary.swift
//  MediaLibraryManager
//
//  Created by Nikolah Pearce and Vivian Breda on 13/08/18.
//  Copyright © 2018 Paul Crane. All rights reserved.
//

import Foundation

/**
 Contains the main functions needed to modify the media metadata collection.
 */
class Library : MMCollection {
    
    private var files: [MMFile] = []                        //the files in the collection.
    private var keysDictionary: [String:[MMFile]] = [:]     //indexed dictionary of all the metadata in the collection.
    private var valuesDictionary: [String:[MMFile]] = [:]   //inverted indexed dictionary of all the metadata in the collection.
    
    /**
     String representation of the Media Library collection
     - returns: String: String representation of the library.
     */
    var description: String {
        return "> Media library contains \(count) files."
    }
    
    /**
     The size of the library.
     - returns: Int: number of files in the library.
     */
    var count: Int {
        return files.count
    }
    
    /**
     Default initialiser
     */
    init() {
        
    }
    
    
    /**
     Adds a file's metadata to the media metadata collection.
     
     - parameter file: The file and associated metadata to add to the collection.
     */
    func add(file: MMFile) {
        
        files.append(file)
        loadDictionaries(file: file)
    }
    
    /**
     Adds a specific instance of a metadata to the collection.
     - parameter metadata: The metadata to add to the given file.
     - parameter file: The file where the metadata will be added to.
     */
    func add(metadata: MMMetadata, file: MMFile)  {
        var i: Int = 0
        var toUpdate: MMFile?
        for f in files {
            if f as! File == file as! File {
                files[i].metadata.append(metadata)
                toUpdate = files[i]
                updateDictionaries(metadata: metadata, file: file, update: toUpdate)
                break
            }
            i += 1
        }
        
    }
    
    /**
     Finds all the files associated with the keyword.
     
     - parameter keyword: The keyword to search for.
     - returns: [MMFile]: A list of all the metadata associated with the
     keyword, possibly an empty list.
     */
    func search(term: String) -> [MMFile]  {
        let searchterm: String = term.lowercased()
        
        // Checks if either return results and return the one that does? or combine
        var results: [MMFile] = []
        if let keyResults = keysDictionary[searchterm] {
            results.append(contentsOf: keyResults)
        }
        if let valueResults = valuesDictionary[searchterm] {
            results.append(contentsOf: valueResults)
        }
        
        return results
    }
    
    /**
     Finds all the metadata associated with the keyword of the item.
     
     - parameter item: The item's metadata keypair to search for.
     - returns: [MMFiles]: A list of all the metadata associated with the item's
     keyword, possibly an empty list.
     */
    func search(item: MMMetadata) -> [MMFile]  {
        //Unimplemented as our Library does not need this functionality
        return []
    }
    
    /**
     Returns a list of all the files in the index
     
     - returns: [MMFile]: A list of all the files in the index, possibly an empty list.
     */
    func all() -> [MMFile]  {
        return files
    }
    
    /**
     Removes a specific instance of a metadata from the collection.
     
     - parameter metadata: The item to remove from the collection.
     */
    func remove(metadata: MMMetadata)  {
        // Removes metadata term from all files. *NOT* a functionality in our library.
        var i: Int = 0
        for _ in files {
            if let indexM = files[i].metadata.index(where: {$0.keyword == metadata.keyword && $0.value == metadata.value}) {
                files[i].metadata.remove(at: indexM)
            }
            i += 1
        }
    }
    
    /**
     Removes a specific instance of a metadata from a file in the collection.
     - Note: not in protocols.swift - added this method ourselves.
     
     - parameter metadata: The item to remove from the file.
     - parameter file: file to remove metadata from.
     */
    func remove(key: String, file: MMFile)  {
        if let indexF = files.index(where: {$0.filename == file.filename}){
            if let indexM = files[indexF].metadata.index(where: {$0.keyword.lowercased() == key.lowercased()}) {
                let rmv = files[indexF].metadata.remove(at: indexM)
                rmvDictionaries(key: key, rmv: rmv, file: file)
            }
        }
    }
    
    /**
     Removes all files from this library.
     */
    func removeAllFiles() {
        files.removeAll()
    }
    
    /**
     Checks the current library for this exact file.
     - Note: not in protocols.swift - added this method ourselves.
     
     - parameter file: file to look for in the Library.
     - returns: Bool: true if file already exists in the Library.
     */
    func isDuplicate(file: MMFile) -> Bool {
        var found: Bool = false
        
        for f in files {
            if f as! File == file as! File {
                found = true
            }
        }
        
        return found
    }
    
    /**
     Checks the current file for this exact keyword
     - Note: not in protocols.swift - added this method ourselves.
     
     - parameter file: file to look into.
     - parameter keyword: the key to check.
     - returns: Bool: true if file already exists in the library.
     */
    func isMetadataDuplicate(file: MMFile, key: String) -> Bool {
        var found: Bool = false
        
        for m in file.metadata {
            if m.keyword == key {
                found = true
            }
        }
        
        return found
    }
    
    /**
     Finds all the files of a particular type
     
     - Parameters: type the file type to list
     - Returns: [MMFile]: A list of all files of that type in the library.
     */
    
    func listByType(type: String) -> [MMFile] {
        var results: [MMFile] = []
        for f in files {
            if f.type == type {
                results.append(f)
            }
        }
        return results
    }
    
    /**
     Loads the metadata dictionaries of the new file.
     Adds both keywords and values to the Library dictionaries.
     - Note: not in protocols.swift - added this method ourselves.
     
     - parameter file: the new file added to the library.
     */
    func loadDictionaries(file: MMFile) {
        
        var copy = [MMFile]()
        
        for m in file.metadata {
            
            var toLowerCase = m.keyword.lowercased()
            
            // Adds to the keys Dictionary
            if keysDictionary.keys.contains(toLowerCase) {
                copy = keysDictionary[toLowerCase]!
                copy.append(file)
                keysDictionary.updateValue(copy, forKey: toLowerCase)
            } else {
                keysDictionary.updateValue([file], forKey: toLowerCase)
            }
            
            toLowerCase = m.value.lowercased()
            
            // Adds to the values Dictionary
            if valuesDictionary.keys.contains(toLowerCase) {
                copy = valuesDictionary[toLowerCase]!
                copy.append(file)
                valuesDictionary.updateValue(copy, forKey: toLowerCase)
            } else {
                valuesDictionary.updateValue([file], forKey: toLowerCase)
            }
        }
    }
    
    /**
     Updates the dictionaries if either keywords or values are removed
     from the collection.
     - Note: not in protocols.swift - added this method ourselves.
     
     - parameter key: the keyword which will be updated.
     - parameter rmv: value to be removed.
     - parameter update: the file which will be updated.
     */
    func rmvDictionaries(key: String, rmv: MMMetadata, file: MMFile) {
        
        var toLowerCase = key.lowercased()
        
        // How many items are currently in the dictionary.
        var size = keysDictionary[toLowerCase]?.count
        
        if size == 1 {
            keysDictionary.removeValue(forKey: toLowerCase)
        } else {
            var values = keysDictionary[toLowerCase]
            let index = values?.index(where: {$0 as! File == file as! File})
            values?.remove(at: index!)
            keysDictionary.updateValue(values!, forKey: toLowerCase)
        }
        
        toLowerCase = rmv.value.lowercased()
        size = valuesDictionary[toLowerCase]?.count
        
        if size == 1 {
            valuesDictionary.removeValue(forKey: toLowerCase)
        } else {
            var values = valuesDictionary[toLowerCase]
            let index = values?.index(where: {$0 as! File == file as! File})
            values?.remove(at: index!)
            valuesDictionary.updateValue(values!, forKey: toLowerCase)
        }
    }
    
    /**
     Updates the dictionaries if either keywords or values are added
     to the collection.
     - Note: not in protocols.swift - added this method ourselves.
     
     - parameter metadata: the value which will be updated.
     - parameter file: the file currently in dictionary.
     - parameter update: the modified file which will be updated in the dictionaries.
     */
    func updateDictionaries(metadata: MMMetadata, file: MMFile, update: MMFile?){
        
        var toLowerCase = metadata.keyword.lowercased()
        
        // How many items are currently in the dictionary.
        var size = keysDictionary[toLowerCase]?.count
        
        if size == nil {
            keysDictionary.updateValue([update!], forKey: toLowerCase)
        } else {
            var values = keysDictionary[toLowerCase]
            let index = values?.index(where: {$0 as! File == file as! File})
            if index == nil {
                values?.append(update!)
            } else {
                values?[index!] = update!
            }
            keysDictionary.updateValue(values!, forKey: toLowerCase)
        }
        
        toLowerCase = metadata.value.lowercased()
        size = valuesDictionary[toLowerCase]?.count
        
        if size == nil {
            valuesDictionary.updateValue([update!], forKey: toLowerCase)
        } else {
            var values = valuesDictionary[toLowerCase]
            let index = values?.index(where: {$0 as! File == file as! File})
            if index == nil {
                values?.append(update!)
            } else{
                values?[index!] = update!
            }
            valuesDictionary.updateValue(values!, forKey: toLowerCase)
        }
    }
}
