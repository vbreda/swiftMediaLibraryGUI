//
//  commands.swift
//  MediaLibraryManager
//
//  Created by Paul Crane on 15/08/18.
//  Modified by Nikolah Pearce and Vivian Breda.
//  Copyright © 2018 Paul Crane. All rights reserved.
//
import Foundation

/**
 The list of exceptions that can be thrown by the CLI command handlers
 */
enum MMCliError: Error {
    
    /// Thrown if there is something wrong with the input parameters for the command
    case invalidParameters
    
    /// Thrown if there is no result set to work with (and this command depends
    /// on the previous command)
    case missingResultSet
    
    /// Thrown when the command is not understood
    case unknownCommand
    
    /// Thrown if the command has yet to be implemented
    case unimplementedCommand
    
    // Thrown if the user trys to remove/search for something that does not exist
    case dataDoesntExist
    
    // Thrown if user trys to reference an index that doesnt exist
    case indexOutOfRange
    
    // Thrown if user trys to delete a required metadata per that filetype
    case removingRequiredKey
    
    // Thrown if there is something wrong with the type of media
    case invalidType
    
    // Thrown if there is something wrong with metadata for a specific type
    // e.g. image does not have resolution
    case invalidMetadataForType
    
    // Thrown if there is something wrong with the json file
    // e.g. file doesn't exist or conform. Or contents has a grammatical error.
    case invalidJsonFile
    
    // Thrown if the library is empty but user wants to use/save it
    case libraryEmpty
    
    // Thrown if exporting encounters any error
    case writeFailure
    
    // Thrown if the user tries to duplicate a metadata key
    case duplicateMetadataKey
}

/**
 This class represents a set of results. It could be extended to include
 the command and a history of commands and the results.
 */
class MMResultSet {
    
    /// The list of files produced by the command
    fileprivate var results: [MMFile]
    
    /// Constructs a new result set.
    /// - parameter results: the list of files produced by the executed
    /// command, could be empty.
    init(_ results:[MMFile]){
        self.results = results
    }
    /// Constructs a new result set with an empty list.
    convenience init(){
        self.init([MMFile]())
    }
    
    /// If there are some results to show, enumerate them and print them out.
    /// - note: this enumeration is used to identify the files in subsequent
    /// commands.
    func show(){
        guard self.results.count > 0 else{
            return
        }
        for (i,file) in self.results.enumerated() {
            print("\t\(i): \(file)")
        }
    }
    
    func get(index: Int) throws -> MMFile{
        return self.results[index]
    }
    
    func getAll() throws -> [MMFile] {
        return self.results
    }
}


/**
 This protocol specifies the new 'Command' pattern, and is more
 Object Oriented.
 */
protocol MMCommand {
    var results: MMResultSet? {get}
    func execute() throws
}

/**
 Handle unimplemented commands by throwing an exception when trying to
 execute this command.
 */
class UnimplementedCommand: MMCommand {
    var results: MMResultSet? = nil
    func execute() throws {
        throw MMCliError.unimplementedCommand
    }
}

/**
 Handle the help command.
 */
class HelpCommand: MMCommand {
    var results: MMResultSet? = nil
    func execute() throws{
        print("""
\thelp                              - this text
\tload <filename> ...               - load file into the collection
\tlist <term> ...                   - list all the files that have the term specified
\tlist                              - list all the files in the collection
\tadd <number> <key> <value> ...    - add some metadata to a file
\tset <number> <key> <value> ...    - this is really a del followed by an add
\tdel <number> <key> ...            - removes a metadata item from a file
\tsave-search <filename>            - saves the last list results to a file
\tsave <filename>                   - saves the whole collection to a file
\tquit                              - exit the program (without prompts)
\ttest                              - runs the test framework created by Vivian and Nikolah
""")
    }
}

/**
 Handle the quit command.
 
 Exits the program (with exit code 0) without
 checking if there is anything to save.
 */
class QuitCommand : MMCommand {
    var results: MMResultSet? = nil
    func execute() throws{
        exit(0)
    }
}

/**
 Handle the load command.
 
 It loads files into the collection.
 */
class LoadCommand: MMCommand {
    var results: MMResultSet? = nil
    var library : Library
    
    var jsonFilesToLoad : [String]
    
    /**
     Constructs a new load file handler.
     
     - parameter files: the file to be loaded.
     - parameter library: the target collection.
     */
    init(loadfiles: [String], library: Library) {
        self.library = library
        self.jsonFilesToLoad = loadfiles
    }
    
    func execute() throws {
        let oldCount = library.count
        let importer : FileImporter = FileImporter()
        var newFiles : [MMFile] = []
        var duplicatedNotAdded: [MMFile] = []
        
        // Ensure the user passed at least one parameter.
        guard jsonFilesToLoad.count > 0 else {
            throw MMCliError.invalidParameters
        }
        
        // While there are filenames to read from.
        var i = jsonFilesToLoad.count
        while i > 0 {
            
            // Get the filename from the parameters.
            let fileName: String = jsonFilesToLoad.removeFirst()
            
            // Pass the file to the importer.
            newFiles = try importer.read(filename: fileName)
            // Add the files to the library
            for f in newFiles {
                
                // Only add the file if it isn't a duplicate
                let found = library.isDuplicate(file: f)
                if !found {
                    library.add(file: f)
                } else {
                    duplicatedNotAdded.append(f)
                }
            }
            i = i-1
        }
        
        // Confirm to the user that the Library grew in size.
        let newCount = library.count
        let diff = newCount-oldCount
        
        if diff == 1 {
            print ("> \(diff) file added to library")
        } else {
            print ("> \(diff) files added to library")
        }
        
        
        // Print out the names of the added files.
        if newCount > oldCount {
            var allFiles = library.all()
            var index: Int = 1
            for i in library.count-diff...library.count-1 {
                print("\t\(index): \(allFiles[i].filename)")
                index += 1
            }
        }
        
        // Print out the names of any duplicate files not added
        if duplicatedNotAdded.count > 0 {
            print ("> Duplicates found:")
            var index: Int = 1
            for d in duplicatedNotAdded {
                print("\t\(index): \(d.filename) not added")
                index += 1
            }
        }
    }
}

/**
 Handle the list command.
 
 It lists the files contained in the collection.
 Either listing by a keyword (aka searching) or listing all files.
 */
class ListCommand : MMCommand {
    var results: MMResultSet? = nil
    var library: Library
    var keywords: [String]
    
    /**
     Constructs a new list handler.
     
     - parameter keyword: filter the files according to the given keyword.
     - parameter library: the collection from which the files will be listed.
     */
    init(keyword: [String], library: Library) {
        self.keywords = keyword;
        self.library = library
    }
    
    func execute() throws {
        
        // Ensures there is a file in the library to save.
        guard library.count > 0 else {
            throw MMCliError.libraryEmpty
        }
        
        // Lists all the files in the library ("list").
        if (keywords.count == 0) {
            let allFiles = library.all()
            self.results = MMResultSet(allFiles)
            print(library.description)
            
        // Lists all the files that have the given term ("list <term>").
		} else {
			
			var param = keywords.count
			let term = keywords[0].lowercased()
			var listresults: [MMFile] = []
			var filenamesFound: [String] = []
			
			if param == 1 && (term == "image" || term == "video" || term == "document" || term == "audio") {
				listresults = library.listByType(type: term)
			} else {
				
				// Continue adding while there are 1+ data items left.
				while param > 0 {
					let word: String = keywords.removeFirst()
					let res1 = library.search(term: word)
					
					for f in res1 {
						if !filenamesFound.contains(f.filename) {
							listresults.append(f)
							filenamesFound.append(f.filename)
						}
					}
					
					param -= 1
				}
			}
			
			// Check that results were found, else throw.
			guard listresults.count > 0 else {
				throw MMCliError.dataDoesntExist
			}
			
			self.results = MMResultSet(listresults)
		}
	}
}

/**
 Handle the add command.
 
 It adds the given metadata keypair to the file at given position.
 Position specified depends on the previous results set of the last command.
 */
class AddCommand : MMCommand {
    var results: MMResultSet? = nil
    var library: Library
    var data: [String]
    var lastsearch: [MMFile]
    
    /**
     Constructs a new add handler.
     
     - parameter data: the position of file and metadata to be added.
     - parameter library: the collection where the files will be added.
     - parameter lastsearch: the array of Files of the last result set.
     */
    init(data: [String], library: Library, lastsearch: [MMFile]) {
        self.data = data
        self.library = library
        self.lastsearch = lastsearch
    }
    
    func execute() throws {
        
        // Ensures there is a file in the library to save.
        guard library.count > 0 else {
            throw MMCliError.libraryEmpty
        }
        
        // Ensures the user passed at least two parameters and the first is an Int.
        guard data.count > 2 && (Int(data[0]) != nil) else {
            throw MMCliError.invalidParameters
        }
        
        // Ensures there is a previous result set to use.
        guard lastsearch.count > 0 else {
            throw MMCliError.missingResultSet
        }
        
        let index = Int(data.removeFirst())!
        
        // Checks the index is within acceptable range.
        guard index < lastsearch.count else {
            throw MMCliError.indexOutOfRange
        }
        
        var param = data.count
        
        // Continues adding while there are 2+ data items left.
        while param > 1 {
            let key = data.removeFirst()
            let value = data.removeFirst()
            let newdata = Metadata(keyword: key, value: value)
            let fileToAddTo = lastsearch[index]
            let check: Bool = library.isMetadataDuplicate(file: fileToAddTo, key: key)
            if !check {
                library.add(metadata: newdata, file: fileToAddTo)
            } else {
                throw MMCliError.duplicateMetadataKey
            }
            print("> \"\(newdata)\" added to \(fileToAddTo.filename)")
            param -= 2
        }
    }
}

/**
 Handles the set command.
 
 It adds the given metadata keypair to the file at given position,
 first removing the original metadata.
 A set is a delete followed by an add.
 */
class SetCommand : MMCommand {
    var results: MMResultSet? = nil
    var library: Library
    var data: [String]
    var lastsearch: [MMFile]
    
    /**
     Constructs a new set handler.
     
     - parameter data: the position of file and metadata to be added.
     - parameter library: the collection that contains the file which will be modified.
     - parameter lastsearch: the array of Files of the last result set.
     */
    init(data: [String], library: Library, lastsearch: [MMFile]) {
        self.data = data
        self.library = library
        self.lastsearch = lastsearch
    }
    
    func execute() throws {
        
        // Ensures there is a file in the library to save.
        guard library.count > 0 else {
            throw MMCliError.libraryEmpty
        }
        
        // Ensures the user passed at least two parameters.
        guard data.count > 2 && (Int(data[0]) != nil) else {
            throw MMCliError.invalidParameters
        }
        
        // Ensures there is a result set to use.
        guard lastsearch.count > 0 else {
            throw MMCliError.missingResultSet
        }
        
        let index = Int(data.removeFirst())!
        
        // Checks the index is within acceptable range.
        guard index < lastsearch.count else {
            throw MMCliError.indexOutOfRange
        }
        
        var param = data.count
        
        // Continues setting while there are 2+ data items remaining.
        while param > 1 {
            let key : String = data.removeFirst()
            let valueToModify : String = data.removeFirst()
            let dataToAdd = Metadata(keyword: key, value: valueToModify)
            let fileToModify : MMFile = lastsearch[index]
            
            if fileToModify.metadata.contains(where: {$0.keyword == dataToAdd.keyword}){
                library.remove(key: key, file: fileToModify)
                library.add(metadata: dataToAdd, file: fileToModify)
                print("> \"\(dataToAdd)\" set in \(fileToModify.filename)")
                
                
            } else {
                throw MMCliError.dataDoesntExist
            }
            param -= 2
        }
    }
}

/**
 Handles the delete command.
 
 It deletes the given metadata keypair from the file at given position,
 if and only if that metadata is an optional keypair.
 Does not delete required metadata.
 */
class DeleteCommand : MMCommand {
    var results: MMResultSet? = nil
    var library: Library
    var data: [String]
    var lastsearch: [MMFile]
    
    /**
     Constructs a new delete handler.
     
     - parameter data: the position of file and the metadata to be deleted.
     - parameter library: the collection that contains the file from which the metadata will be deleted.
     - parameter lastsearch: the array of Files of the last result set.
     */
    init(data: [String], library: Library, lastsearch: [MMFile]) {
        self.data = data
        self.library = library
        self.lastsearch = lastsearch
    }
    
    func execute() throws {
        
        // Ensures there is a file in the library to save.
        guard library.count > 0 else {
            throw MMCliError.libraryEmpty
        }
        
        // Ensures the user passed at least two parameters.
        guard data.count > 1 && (Int(data[0]) != nil) else {
            throw MMCliError.invalidParameters
        }
        
        // Ensures there is a result set to use.
        guard lastsearch.count > 0 else {
            throw MMCliError.missingResultSet
        }
        
        let index = Int(data.removeFirst())!
        
        // Checks the index is within acceptable range.
        guard index < lastsearch.count else {
            throw MMCliError.indexOutOfRange
        }
        
        var param = data.count
        
        // Continues deleting while there is 1+ data items remaining.
        while param > 0 {
            
            let key: String = data.removeFirst()
            let delFile : MMFile = lastsearch[index]
            
            // Checks it is not a required key before removing.
            let allowed = try FileValidator.safeToDelete(key: key, typeOfFile: delFile.type)
            
            if allowed {
                // Checks that key can be deleted.
                if delFile.metadata.contains(where: {$0.keyword == key}) {
                    library.remove(key: key, file: delFile)
                    print("> \"\(key)\" deleted from \(delFile.filename)")
                } else {
                    throw MMCliError.dataDoesntExist
                }
            }
            param -= 1
        }
    }
}

/**
 Handles the save-search command.
 
 It exports the last searched list into a file.
 Filename and path given by the user as an input.
 */
class SaveSearchCommand : MMCommand {
    var results: MMResultSet? = nil
    var data: [String]
    var lastsearch: [MMFile]
    
    /**
     Constructs a new save-search handler.
     
     - parameter data: the path to the file or the filename to save the search.
     - parameter lastsearch: the array of Files of the last result set.
     */
    init(data: [String], lastsearch: [MMFile]) {
        self.data = data
        self.lastsearch = lastsearch
    }
    
    func execute() throws {
        
        // Ensures the user passed one parameter.
        guard data.count == 1 else {
            throw MMCliError.invalidParameters
        }
        
        // Ensures there is a result set to use.
        guard lastsearch.count > 0 else {
            throw MMCliError.missingResultSet
        }
        
        let fileName: String = data.removeFirst()
        let exporter: FileExporter = FileExporter()
        
        try exporter.write(filename: fileName, items: lastsearch)
        print("> Search saved to \(fileName)")
        
    }
}

/**
 Handles the save command.
 
 It exports the library into a file.
 Filename and path given by the user as an input.
 */
class SaveCommand : MMCommand {
    var results: MMResultSet? = nil
    var data: [String]
    var library: Library
    
    /**
     Constructs a new save handler.
     
     - parameter data: the path to the file or the filename to save the search to.
     - parameter lastsearch: the collection of Files.
     */
    init(data: [String], library: Library) {
        self.data = data
        self.library = library
    }
    
    func execute() throws {
        
        // Ensures there is a file in the library to save.
        guard library.count > 0 else {
            throw MMCliError.libraryEmpty
        }
        
        // Ensures the user passed one parameter.
        guard data.count == 1 else {
            throw MMCliError.invalidParameters
        }
        
        let fileName: String = data.removeFirst()
        let exporter : FileExporter = FileExporter()
        
        try exporter.write(filename: fileName, items: library.all())
        print("> Collection saved to \(fileName)")
        
    }
}

/**
 Handles the testing framework.
 Instatiates the test class and calls the run all method.
 */
class TestCommand : MMCommand {
    var results: MMResultSet? = nil
    
    func execute() throws {
        
        let tester: MediaLibraryTests = MediaLibraryTests()
        tester.runAllTests()
        
    }
}
