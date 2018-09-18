//
//  FileValidator.swift
//  MediaLibraryManager
//
//  Created by Nikolah Pearce and Vivian Breda on 25/08/18.
//  Copyright © 2018 Paul Crane. All rights reserved.
//

import Foundation

/**
  Validator for checking Files.

  Converts Media struct to File and performs all validation.
*/
class FileValidator {
	
	// Dictionaries that store valid metadata needed per type.
	private static let validImage = ["resolution": true, "runtime": false,"creator": true]
	private static let validDocument = ["resolution": false, "runtime": false,"creator": true]
	private static let validVideo = ["resolution": true, "runtime": true,"creator": true]
	private static let validAudio = ["resolution": false, "runtime": true,"creator": true]
	private static let types = ["image","document","video","audio"]
	
	private var errorMessages: [String] = []
	
	private var type: String = ""
	private var filename: String = ""
	private var path: String = ""
	private var creator: String?
	private var res: String?
	private var runtime: String?
	
	private var mdata: [Metadata] = []
	private var keys: [String] = []
	private var validatedFile: MMFile? = nil
	
	/**
	  Sets up the Validator for the new File
	
	  - parameter Media: the Media struct to validate as a File
	*/
	init() {
		clearFields()
	}
	
	func validate(media: Media) throws -> MMFile? {
		
		clearFields()
		
		type = media.type
		filename = getFilename(fullpath: media.fullpath)
		path = getPath(fullpath: media.fullpath)
		
		
		// Loop through to fill the required values.
		for (key, value) in media.metadata {
			if key.lowercased()=="creator" {
				creator = value.lowercased()
			}
			if key.lowercased()=="runtime" {
				runtime = value.lowercased()
			}
			if key.lowercased()=="resolution" {
				res = value.lowercased()
			}
			let tempMetadata : Metadata = Metadata(keyword: key, value: value)
			mdata.append(tempMetadata)
			keys.append(key)
		}
		
		// "No need to validate the media path or media name, we won't
		// be testing with bad data of these" - Paul 22/08/18
		
		let validType = try validateType()
		if validType {
			validatedFile = try createFile()
		}
		return validatedFile
	}
	
	/**
	  Designed to validate Files depending upon their type.
	
	  Performs type checking and required metadata checking.
	  Throws MMCLiErrors where media does not conform.
	
	  - parameter Media: the Media struct to validate as a File.
	  - returns: MMFile? the validated File.
	*/
	func validateType() throws -> Bool {
		
		var typeValid: Bool = true
		var errorAppendedAlready: Bool = false
		
		switch(type) {
		case FileValidator.types[0] :
			for (keyword, compulsory) in FileValidator.validImage {
				if compulsory == true && !keys.contains(keyword) {
					typeValid = false
				}
			}
			break
		case FileValidator.types[1]:
			for (keyword, compulsory) in FileValidator.validDocument {
				if compulsory == true && !keys.contains(keyword) {
					typeValid = false
				}
			}
			break
		case FileValidator.types[2]:
			for (keyword, compulsory) in FileValidator.validVideo {
				if compulsory == true && !keys.contains(keyword) {
					typeValid = false
				}
			}
			break
		case FileValidator.types[3]:
			for (keyword, compulsory) in FileValidator.validAudio {
				if compulsory == true && !keys.contains(keyword) {
					typeValid = false
				}
			}
			break
		default:
			typeValid = false
			errorMessages.append("\(filename) not a valid type.")
			errorAppendedAlready = true
		}
		
		// Ammends any messages why invalid.
		if !typeValid && !errorAppendedAlready {
			errorMessages.append("\(filename) missing required metadata.")
		}
		return typeValid
	}
	
	/**
	  Creates the MMFile if type is valid.
	
      - returns: MMFile?: The file created.
	*/
	func createFile() throws -> MMFile? {
		switch(type) {
		case FileValidator.types[0] :
			validatedFile = Image(metadata: mdata, filename: filename, path: path, creator: creator!, resolution: res!)
			break
		case FileValidator.types[1]:
			validatedFile = Document(metadata: mdata, filename: filename, path: path, creator: creator!)
			break
		case FileValidator.types[2]:
			validatedFile = Video(metadata: mdata, filename: filename, path: path, creator: creator!, resolution: res!, runtime: runtime!)
			break
		case FileValidator.types[3]:
			validatedFile = Audio(metadata: mdata, filename: filename, path: path, creator: creator!, runtime: runtime!)
			break
		default:
			throw MMCliError.invalidType
		}
		return validatedFile!
	}
	
	/**
      Checks whether a metadata key is OK to delete from a file.
	
      - parameter key: The key to check if allowed to delete.
      - returns: Bool: true if that key is not compulsory.
	*/
	static func safeToDelete(key: String, typeOfFile: String) throws -> Bool {
		var allowed: Bool = true
		
		switch(typeOfFile) {
		case FileValidator.types[0] :
			for (keyword, compulsory) in validImage {
				if keyword == key && compulsory == true {
					allowed = false
				}
			}
			break
		case FileValidator.types[1] :
			for (keyword, compulsory) in validDocument {
				if keyword == key && compulsory == true {
					allowed = false
				}
			}
			break
		case FileValidator.types[2] :
			for (keyword, compulsory) in validVideo {
				if keyword == key && compulsory == true {
					allowed = false
				}
			}
			break
		case FileValidator.types[3] :
			for (keyword, compulsory) in validAudio {
				if keyword == key && compulsory == true {
					allowed = false
				}
			}
			break
		default:
			allowed = false
			throw MMCliError.removingRequiredKey
		}
		
		if allowed {
			return allowed
		} else {
			throw MMCliError.removingRequiredKey
		}
	}
	
	/**
	  Clears and resets all data fields.
	*/
	func clearFields() {
		type = ""
		filename = ""
		path = ""
		creator = nil
		res = nil
		runtime = nil
		mdata = []
		keys = []
		validatedFile = nil
	}
	
	/**
	  Returns any error message created.
      - returns: String: the error message created.
	*/
	func getErrorMessages() -> [String] {
		return errorMessages
	}
	
	/**
	  Calculates a filename of a file from the fullpath string.
	
	  - parameter fullpath: The full path to the file including file name.
	  - returns: String: The name of the file.
	*/
	func getFilename(fullpath: String) -> String {
		
		var parts = fullpath.split(separator: "/")
		let name = String(parts[parts.count-1])
		return name
	}
	
	/**
	  Calculates a path to a file from the fullpath string.
	
	  - parameter fullpath: The full path to the file including file name.
	  - returns: String: The path to the file.
	*/
	func getPath(fullpath: String) -> String {
		
		var parts = fullpath.split(separator: "/")
		var path: String = ""
		let lastIndex = parts.count-2
		for i in 0...lastIndex {
			if parts[i] != "~" {
				path += "/"
			}
			path += parts[i]
		}
		return path
	}
	
}
