//
//  MediaLibraryTests.swift
//  MediaLibraryManager
//
//  Created by Nikolah Pearce and Vivian Breda on 28/08/18.
//  Copyright © 2018 Paul Crane. All rights reserved.
//

/**
test.json contains:

[{"fullpath": "/346/to/image1","type": "image","metadata": {"creator": "cre1","resolution": "res1"}},{"fullpath": "/346/to/image2","type": "image","metadata": {"creator": "cre2","resolution": "res2"}},{"fullpath": "/346/to/video3","type": "video","metadata": {"creator": "cre3","resolution": "res3","runtime": "run3"}}]

test2.json contains:

[{"fullpath": "/346/to/doc1","type": "document","metadata": {"creator": "cre1"}},{"fullpath": "/346/to/doc2","type": "document","metadata": {"creator": "cre2"}},{"fullpath": "/346/to/vid3","type": "video","metadata": {"creator": "cre3","resolution": "res3","runtime": "run3"}}]

Located in the working directory and Home Directory of user in order to test.
*/

import Foundation

/**
  Runs tests that ignore user prompt.
  Exhausts all action paths in MediaLibrary project.
*/
class MediaLibraryTests {
	
	var library: Library
	var f1: MMFile
	var f2: MMFile
	var f3: MMFile
	var m1: [MMMetadata]
	var m2: [MMMetadata]
	var m3: [MMMetadata]
	
	var kv11: Metadata
	var kv12: Metadata
	var kv21: Metadata
	var kv22: Metadata
	var kv31: Metadata
	var kv32: Metadata
	var kv33: Metadata
	
	/**
	  Initialiser that sets all datafields to base form
	*/
	init() {
		library = Library()
		kv11 = Metadata(keyword: "creator", value: "cre1")
		kv12 = Metadata(keyword: "resolution", value: "res1")
		kv21 = Metadata(keyword: "creator", value: "cre2")
		kv22 = Metadata(keyword: "resolution", value: "res2")
		kv31 = Metadata(keyword: "creator", value: "cre3")
		kv32 = Metadata(keyword: "resolution", value: "res3")
		kv33 = Metadata(keyword: "runtime", value: "run3")
		m1 = [kv11, kv12]
		m2 = [kv21, kv22]
		m3 = [kv31, kv32, kv33]
		f1 = Image(metadata: m1, filename: "image1", path: "/346/to", creator: "cre1", resolution: "res1")
		f2 = Image(metadata: m2, filename: "image2", path: "/346/to", creator: "cre2", resolution: "res2")
		f3 = Video(metadata: m3, filename: "video3", path: "/346/to", creator: "cre3", resolution: "res3", runtime: "run3")
	}
	
	/**
	  Set up called before each tests.
	  Ensures all data fields in their base form.
	*/
	func setUp() {
		library = Library()
		kv11 = Metadata(keyword: "creator", value: "cre1")
		kv12 = Metadata(keyword: "resolution", value: "res1")
		kv21 = Metadata(keyword: "creator", value: "cre2")
		kv22 = Metadata(keyword: "resolution", value: "res2")
		kv31 = Metadata(keyword: "creator", value: "cre3")
		kv32 = Metadata(keyword: "resolution", value: "res3")
		kv33 = Metadata(keyword: "runtime", value: "run3")
		m1 = [kv11, kv12]
		m2 = [kv21,kv22]
		m3 = [kv31, kv32, kv33]
		f1 = Image(metadata: m1, filename: "image1", path: "/346/to", creator: "cre1", resolution: "res1")
		f2 = Image(metadata: m2, filename: "image2", path: "/346/to", creator: "cre2", resolution: "res2")
		f3 = Video(metadata: m3, filename: "video3", path: "/346/to", creator: "cre3", resolution: "res3", runtime: "run3")
	}
	
	/**
	  Tear down called after each test.
	  Ensures state is restored to base.
	*/
	func tearDown() {
		m1 = []
		m2 = []
		m3 = []
		f1.metadata = m1
		f2.metadata = m2
		f3.metadata = m3
		library.removeAllFiles()
	}
	
	// Calls all tests and runs them.
	func runAllTests() {
		
		setUp()
		testMetadata()
		print("\t✅ testMetadata() passed")
		tearDown()
		
		setUp()
		testFile()
		print("\t✅ testFile() passed")
		tearDown()

		setUp()
		testAddToLibrary()
		print("\t✅ testAddToLibrary() passed")
		tearDown()
		
		setUp()
		testAddMetadataToFile()
		print("\t✅ testAddMetadataToFile() passed")
		tearDown()
		
		setUp()
		testRemove()
		print("\t✅ testRemove() passed")
		tearDown()
		
		setUp()
		testRemoveAllFiles()
		print("\t✅ testRemoveAllFiles() passed")
		tearDown()
		
		setUp()
		testSearch()
		print("\t✅ testSearch() passed")
		tearDown()

		setUp()
		testAll()
		print("\t✅ testAll() passed")
		tearDown()
		
		setUp()
		testFileValidator()
		print("\t✅ testFileValidator() passed")
		tearDown()

		setUp()
		testFileImporter()
		print("\t✅ testFileImporter() passed")
		tearDown()
		
		setUp()
		testFileExporter()
		print("\t✅ testFileExporter() passed")
		tearDown()
		
		setUp()
		testLoadCommand()
		print("\t✅ testLoadCommand() passed")
		tearDown()
		
		setUp()
		testListCommand()
		print("\t✅ testListCommand() passed")
		tearDown()
		
		setUp()
		testListAllCommand()
		print("\t✅ testListAllCommand() passed")
		tearDown()
		
		setUp()
		testListByType()
		print("\t✅ testListByType() passed")
		tearDown()
		
		setUp()
		testAddCommand()
		print("\t✅ testAddCommand() passed")
		tearDown()
		
		setUp()
		testSetCommand()
		print("\t✅ testSetCommand() passed")
		tearDown()
		
		setUp()
		testDeleteCommand()
		print("\t✅ testDeleteCommand() passed")
		tearDown()
		
		setUp()
		testSaveSearchCommand()
		print("\t✅ testSaveSearchCommand() passed")
		tearDown()
		
		setUp()
		testSaveCommand()
		print("\t✅ testSaveCommand() passed")
		tearDown()
        
        print("\t✅ Nikolah and Vivian passed asgn1 - woohoo!")
	}
	
	/**
	Tests that creating a Metadata works as it should.
	*/
	func testMetadata() {
		let m3 = Metadata(keyword: "key3", value: "val3")
		assert(m3.keyword == "key3", "Keyword should match")
		assert(m3.value == "val3", "Value should match")
	}
	
	/**
	Tests that creating a File works as it should.
	*/
	func testFile() {
		let f = Image(metadata: m1, filename: "f1", path: "p1", creator: "cre1", resolution: "res1")
		
		assert(f.type == "image", "File should be of type image")
		assert(f.path == "p1", "File should have correct path")
		assert(f.filename == "f1", "File should have correct filename ")
		assert(f.creator == "cre1", "File should have the same creator ")
		
		var metadata: [MMMetadata] = f.metadata
		var kv = metadata[0]
		var kv2 = metadata[1]
		
		assert(metadata.count == m1.count, "Metadata shold have the same size")
		
		assert(kv as! Metadata == kv11, "File metadata should be the same")
		assert(kv.keyword == "creator", "File m1 kv Keyword should match")
		assert(kv.value == "cre1", "File m1 kv Value should match")
		
		assert(kv2 as! Metadata == kv12, "File metadata should be the same")
		assert(kv2.keyword == "resolution", "File m1 kv2 Keyword should match")
		assert(kv2.value == "res1", "File m1 kv2 Value should match")
	}

	/**
	  Tests that adding a file to the Library works as it should.
	*/
	func testAddToLibrary() {
		precondition(library.count == 0, "Library should be empty.")
		
		library.add(file: f1)
		library.add(file: f2)

		var files = library.all()
		assert(library.count == 2, "Library should contain two files.")
		assert(files.count == 2, "Library should contain two files.")
		
		assert(files[0] as! File == f1 as! File,"F1 should exist in library.")
		assert(files[1] as! File == f2 as! File,"F2 should exist in library.")
	}
	
	/**
	  Tests that adding metadata to a file works as it should.
	*/
	func testAddMetadataToFile() {
		precondition(library.count == 0, "Library should be empty.")
		
		library.add(file: f1)
		assert(library.count == 1, "Library should contain one file.")
		
		var files = library.all()
		var file1 = files[0]
		var mdata: [MMMetadata] = file1.metadata
		
		assert(mdata[0] as! Metadata == kv11 , "Metadata should match original")
		assert(mdata[1] as! Metadata == kv12 , "Metadata should match original")
		assert(mdata.count == 2, "Metadata should contai only two values")
		
		let newKV: MMMetadata = Metadata(keyword: "newKey", value: "newVal")
		library.add(metadata: newKV, file: file1)
		
		assert(library.count == 1, "Library should contain one file still.")
		var newfiles = library.all()
		var newfile1 = newfiles[0]
		var newmdata: [MMMetadata] = newfile1.metadata
		
		assert(newmdata[0] as! Metadata == kv11 , "Metadata should match original")
		assert(newmdata[1] as! Metadata == kv12 , "Metadata should match original")
		assert(newmdata[2] as! Metadata == newKV , "Metadata should contain new value")
		assert(newmdata.count == 3, "Metadata should contain three values now")
		
		
	}
	
	/**
	  Tests that removing a metadata from a file works as it should.
	*/
	func testRemove() {
		precondition(library.count == 0, "Library should be empty.")
		precondition(f1.metadata.count == 2, "f1 Metadata 1 should have two kv pairs.")
		precondition(m1.count == 2, "Metadata 1 should have two kv pairs.")
		
		let newKV: Metadata = Metadata(keyword: "test", value: "test1")
		let dummyKV: Metadata = Metadata(keyword: "dummy", value: "dummy1")
		
		m1.append(newKV)
		f1.metadata.append(newKV)
		library.add(file: f1)
		library.add(file: f2)
		
		assert(library.count == 2, "Library should contain two files.")
		assert(f1.metadata.count == 3, "f1 Metadata 1 should have three kv pairs.")
		assert(m1.count == 3, "Metadata 1 should have three kv pairs.")
		
		// remove not existing shouldn't crash
		library.remove(key: dummyKV.keyword, file: f1)
		assert(f1.metadata.count == 3, "f1 Metadata 1 should have three kv pairs still.")
		
		// remove a required should still be there
		// - except this check is never done in Library, only in DeleteCommand.
		//library.remove(key: kv11.keyword, file: f1)
		//assert(f1.metadata.count == 3, "f1 Metadata 1 should have three kv pairs still.")
		
		// remove existing should work
		library.remove(key: newKV.keyword, file: f1)
		assert(library.count == 2, "Library should contain two files.")
		assert(f1.metadata.count == 2, "f1 Metadata 1 should have two kv pairs after removing.")
		assert(m1.count == 3, "Metadata 1 should have three kv pairs.")
	}
	
	/**
	  Tests that remove all files in library is working.
	*/
	func testRemoveAllFiles() {
		precondition(library.count == 0, "Library should be empty.")
		library.add(file: f1)
		library.add(file: f2)
		assert(library.count == 2, "Library should contain two files.")
		library.removeAllFiles()
		assert(library.count == 0, "Library should contain 0 files after removing.")
	}
	
	/**
	  Tests that searching for terms in metadata works as it should.
	*/
	func testSearch() {
		precondition(library.count == 0, "Library should be empty.")
		library.add(file: f1)
		library.add(file: f2)
		assert(library.count == 2, "Library should contain two files.")

		// search for value should return 1 file
		var result: [MMFile] = library.search(term: "cre1")
		assert(result.count == 1, "search for value cre1 should return 1 file")
		assert(result[0] as! File == f1, "results should be f1")
		
		//search for requried mdata should return 2 files
		result = library.search(term: "creator")
		assert(result.count == 2, "search for key creator should return 2 files")
		assert(result[0] as! File == f1, "results should be f1")
		assert(result[1] as! File == f2, "results should be f2")
		
		// search for non existing should return nil
		result = library.search(term: "test")
		assert(result.count == 0, "search should be 0 files")
		
		
		// search for added metadata should return f1
		let newKV: MMMetadata = Metadata(keyword: "newkey", value: "newval")
		library.add(metadata: newKV, file: f1)
		assert(library.count == 2, "Library should contain two files.")
		result = library.search(term: "newkey")
		assert(result.count == 1, "search should be 1 file")
		assert(result[0] as! File == f1, "search should be 1 file")
		result = library.search(term: "newKey")
		assert(result.count == 1, "search should be 1 file")
		assert(result[0] as! File == f1, "search should be 1 file")

		// Search for removed metadata should return nil
		library.remove(key: "newkey", file: f1)
		result = library.search(term: "newval")
		assert(result.count == 0, "search should be 0 files")
		result = library.search(term: "newKey")
		assert(result.count == 0, "search should be 0 files")
	}
	
	/**
	  Tests that the get all files in Library works as it should.
	*/
	func testAll() {
		precondition(library.count == 0, "Library should be empty.")
		library.add(file: f1)
		library.add(file: f2)
		assert(library.count == 2, "Library should contain two files.")
		
		var result = library.all()
		assert(result.count == 2, "search for key creator should return 2 files")
		assert(result[0] as! File == f1, "results should be f1")
		assert(result[1] as! File == f2, "results should be f2")
		
		library.add(file: f3)
		result = library.all()
		assert(result.count == 3, "search for key creator should return 2 files")
		assert(result[0] as! File == f1, "results should be f1")
		assert(result[1] as! File == f2, "results should be f2")
		assert(result[2] as! File == f3, "results should be f3")
	}
	
	/**
	  Tests that the file validator works as it should.
	  e.g. does not validate invalid files
	*/
	func testFileValidator() {
		let vDoc: Media = Media(fullpath: "fake/path/to/doc1", type: "document", metadata: ["creator":"me"])
		let vIm: Media = Media(fullpath: "fake/path/to/ima1", type: "image", metadata: ["creator":"me","resolution":"r1"])
		let vVid: Media = Media(fullpath: "fake/path/to/vid1", type: "video", metadata: ["creator":"me","resolution":"r1","runtime":"r2"])
		let vAud: Media = Media(fullpath: "fake/path/to/aud1", type: "audio", metadata: ["creator":"me","runtime":"r2"])

		let invDoc: Media = Media(fullpath: "fake/path/to/invdoc1", type: "document", metadata: ["notcreator":"me"])
		let invIm: Media = Media(fullpath: "fake/path/to/invima1", type: "image", metadata: ["creator":"me","notresolution":"r1"])
		let invVid: Media = Media(fullpath: "fake/path/to/invvid1", type: "video", metadata: ["creator":"me","resolution":"r1","notruntime":"r2"])
		let invAud: Media = Media(fullpath: "fake/path/to/invaud1", type: "audio", metadata: ["creator":"me","notruntime":"r2"])
		
		let invType: Media = Media(fullpath: "fake/path/to/notype", type: "none", metadata: ["creator":"me","resolution":"r1","runtime":"r2"])
		let invMD: Media = Media(fullpath: "fake/path/to/noMDdoc", type: "document", metadata: [:])
		
		let validator: FileValidator = FileValidator()
		var validatedFile: MMFile
		
		do {
			// Test all four valid types can load
			validatedFile = try validator.validate(media: vDoc)!
			assert(validatedFile.type == "document", "should be of type ")
			assert(validatedFile.filename == "doc1", "should have name ")
			assert(validatedFile.path == "/fake/path/to", "should have path correct")
			assert(validatedFile.metadata.count == 1,"should have 1 MD keypair")
			
			validatedFile = try validator.validate(media: vIm)!
			assert(validatedFile.type == "image", "should be of type ")
			assert(validatedFile.filename == "ima1", "should have name ")
			assert(validatedFile.path == "/fake/path/to", "should have path correct")
			assert(validatedFile.metadata.count == 2,"should have 1 MD keypair")
			
			validatedFile = try validator.validate(media: vVid)!
			assert(validatedFile.type == "video", "should be of type ")
			assert(validatedFile.filename == "vid1", "should have name ")
			assert(validatedFile.path == "/fake/path/to", "should have path correct")
			assert(validatedFile.metadata.count == 3,"should have 3 MD keypair")
			
			validatedFile = try validator.validate(media: vAud)!
			assert(validatedFile.type == "audio", "should be of type ")
			assert(validatedFile.filename == "aud1", "should have name ")
			assert(validatedFile.path == "/fake/path/to", "should have path correct")
			assert(validatedFile.metadata.count == 2,"should have 2 MD keypair")
			
			// test invaid metadata for all four types
			if (try validator.validate(media: invDoc)) != nil {
				assertionFailure("Invalid metadata shouldn't validate.")
			}
			if (try validator.validate(media: invIm)) != nil {
				assertionFailure("Invalid metadata shouldn't validate.")
			}
			if (try validator.validate(media: invVid)) != nil {
				assertionFailure("Invalid metadata shouldn't validate.")
			}
			if (try validator.validate(media: invAud)) != nil {
				assertionFailure("Invalid metadata shouldn't validate.")
			}
			
			// test wrong type won't load
			if (try validator.validate(media: invType)) != nil {
				assertionFailure("Invalid type of file shouldn't validate.")
			}
			
			// test wrong MD won't load
			if (try validator.validate(media: invMD)) != nil {
				assertionFailure("Invalid or empty metadata shouldn't validate.")
			}
		} catch {
			assertionFailure()
		}
	}
	
	/**
	  Tests that the file importer and read function works as it should.
	*/
	func testFileImporter() {
		let testFilename = "test.json"
		let testHomeFilename = "~/test.json"
		let dummyFilename = "doesntexist.json"
		
		let importer: FileImporter = FileImporter()
		var results: [MMFile] = []
		
		precondition(results.count == 0, "results should be empty.")

		do {
			// import from working directory should work
			results = try importer.read(filename: testFilename)
			assert(results.count == 3, "Results should have three files after read.")
			assert(results[0] as! File == f1, "results should be f1")
			assert(results[1] as! File == f2, "results should be f2")
			assert(results[2] as! File == f3, "results should be f3")
			
			// import from home directory also should work
			results = try importer.read(filename: testHomeFilename)
			assert(results.count == 3, "Results should have three files after read.")
			assert(results[0] as! File == f1, "results should be f1")
			assert(results[1] as! File == f2, "results should be f2")
			assert(results[2] as! File == f3, "results should be f3")
			
			// import from full path should work as well - but cannot test automatically
			
			// import from nonexist file should fail
			results = []
			do {
				results = try importer.read(filename: dummyFilename)
			} catch {
				assert(results.count == 0, "No files should be returned")
			}
			
		} catch {
			assertionFailure()
		}
	}
	
	/**
	  Tests that file exporter works as it should.
	*/
	func testFileExporter() {
		precondition(library.count == 0, "Library should be empty.")
		
		let filename: String = "exporterOutput"
		let filename2: String = "~/exporterOutput"
		let exporter = FileExporter()
		
		do {
			// Test empty
			try exporter.write(filename: filename, items: [])
			
			library.add(file: f1)
			library.add(file: f2)
			assert(library.count == 2, "Library should contain two files.")
			
			// Test no file name
			try exporter.write(filename: "", items: library.all())

			// Test exports to working directory
			try exporter.write(filename: filename, items: library.all())
			
			// Test exports to home directory
			try exporter.write(filename: filename2, items: library.all())

			// test exporting random extension stays as json working
			try exporter.write(filename: "notJson.mp3", items: library.all())
			
			// test exporting random extension stays as json home
			try exporter.write(filename: "~/notJson.mp3", items: library.all())
			
			// Would test that exporter writes to fullpath but can only do this manually.

		} catch {
			assertionFailure()
		}
	}
	
	/**
	  Tests that the load command works as it should.
	*/
	func testLoadCommand() {
		precondition(library.count == 0, "Library should be empty.")

		let testFilename = "test.json"
		let testHomeFilename = "test2.json"
		let dummyFilename = "doesntexist.json"
		
		let oneFile: [String] = [testFilename]
		let twoFiles: [String] = [testFilename, testHomeFilename]
		let dummyFile: [String] = [dummyFilename]
		
		var command: MMCommand
		
		do {
			// Test working directory file loads
			command = LoadCommand(loadfiles: oneFile, library: library)
			try command.execute()
			assert(library.count == 3, "Library should be contain 3 files after loading.")
			library.removeAllFiles()
			assert(library.count == 0, "Library should be contain 0 files.")
			
			// Test home directory file loads
			command = LoadCommand(loadfiles: twoFiles, library: library)
			try command.execute()
			assert(library.count == 6, "Library should be contain 6 files after loading.")
			library.removeAllFiles()
			assert(library.count == 0, "Library should be contain 0 files.")
			
			// Test invalid file does not load
			command = LoadCommand(loadfiles: dummyFile, library: library)
			do {
				try command.execute()
			} catch {
				assert(library.count == 0, "Library should be contain 0 files.")
			}
			
			// Test loading in an output file
			
			
		} catch {
			assertionFailure()
		}
	}
	
	/**
	  Tests that the list command works as it should.
	*/
	func testListCommand() {
		precondition(library.count == 0, "Library should be empty.")
		
		var command: MMCommand
		var results: [MMFile]
		var rSet: MMResultSet
		var errorThrown: Bool
		
		// Test listing an empty library
		command = ListCommand(keyword: [""], library: library)
		errorThrown = false
		do {
			try command.execute()
		} catch {
			errorThrown = true
			if (command.results) != nil {
				assertionFailure("No results should exist")
			}
		}
		assert(errorThrown, "Library is empty error should have been thrown")
		
		library.add(file: f1)
		library.add(file: f2)
		assert(library.count == 2, "Library should contain two files.")
		
		do {
			// Test listing via key
			command = ListCommand(keyword: ["creator"], library: library)
			try command.execute()
			rSet = command.results!
			results = try rSet.getAll()
			assert(results.count == 2, "results should be two files")
			
			// Test listing via value
			command = ListCommand(keyword: ["cre1"], library: library)
			try command.execute()
			rSet = command.results!
			results = try rSet.getAll()
			assert(results.count == 1, "results should be 1 file")
			assert(results[0] as! File == f1, "File found should be f1")
			
			// Test listing results to two terms
			command = ListCommand(keyword: ["cre1", "cre2"], library: library)
			try command.execute()
			rSet = command.results!
			results = try rSet.getAll()
			assert(results.count == 2, "results should be two files")
			

			// Test listing results for terms that dont exist
			command = ListCommand(keyword: ["none"], library: library)
			errorThrown = false
			do {
				try command.execute()
			} catch {
				errorThrown = true
				if (command.results) != nil {
					assertionFailure("No results should exist")
				}
			}
			assert(errorThrown, "Data doesnt exist error should have been thrown")
			
			// Test listing results for one exist one not
			command = ListCommand(keyword: ["noeafd","cre1", "none"], library: library)
			do {
				try command.execute()
			} catch {
				assertionFailure("Error should not have been thrown as data exists!")
			}
			rSet = command.results!
			results = try rSet.getAll()
			assert(results.count == 1, "results should be 1 file")
			
			// Test listing for added metadata
			let newKV: MMMetadata = Metadata(keyword: "newKey", value: "newVal")
			library.add(metadata: newKV, file: f1)
			command = ListCommand(keyword: ["newKey"], library: library)
			do {
				try command.execute()
			} catch {
				assertionFailure()
			}
			rSet = command.results!
			results = try rSet.getAll()
			assert(results.count == 1, "results should be 1 file")
			assert(results[0] as! File == f1, "File found should be f1")
			
			// Test listing for removed metadata
			errorThrown = false
			library.remove(key: "newKey", file: f1)
			command = ListCommand(keyword: ["newkey"], library: library)
			do {
				try command.execute()
			} catch {
				errorThrown = true
			}
			assert(errorThrown, "Data doesnt exist error should have been thrown")
			
		} catch {
			assertionFailure()
		}
		
	}
	
	/**
	Tests that the list all command works as it should.
	*/
	func testListAllCommand() {
		precondition(library.count == 0, "Library should be empty.")
		library.add(file: f1)
		library.add(file: f2)
		assert(library.count == 2, "Library should contain two files.")
		
		var command: MMCommand
		var results: [MMFile]
		var rSet: MMResultSet
		do {
			command = ListCommand(keyword: [], library: library)
			try command.execute()
			rSet = command.results!
			results = try rSet.getAll()
			assert(results.count == 2, "Entire library should be returned")
		} catch {
			assertionFailure()
		}
	}
	
	/**
	Tests that the list command works as it should for type attributes.
	*/
	func testListByType() {
		let d = "document"
		let i = "image"
		let a = "audio"
		let v = "video"
		precondition(library.count == 0, "Library should be empty.")
		library.add(file: f1)
		library.add(file: f2)
		library.add(file: f3)
		assert(library.count == 3, "Library should contain three files.")
		
		var command: MMCommand
		var results: [MMFile]
		var rSet: MMResultSet
		var errorThrown: Bool = false
		do {
			// Test list all image
			command = ListCommand(keyword: [i], library: library)
			try command.execute()
			rSet = command.results!
			results = try rSet.getAll()
			assert(results.count == 2, "Two images should be returned")
			assert(results[0].type == i, "Type should be image")
			assert(results[1].type == i, "Type should be image")
			
			// Test list all document
			command = ListCommand(keyword: [d], library: library)
			do {
				try command.execute()
			} catch {
				errorThrown = true
			}
			assert(errorThrown, "Data doesnt exist error should have been thrown")
			
			// Test list all video
			command = ListCommand(keyword: [v], library: library)
			try command.execute()
			rSet = command.results!
			results = try rSet.getAll()
			assert(results.count == 1, "Two images should be returned")
			assert(results[0].type == v, "Type should be video")
			
			// Test list all audio
			command = ListCommand(keyword: [a], library: library)
			do {
				try command.execute()
			} catch {
				errorThrown = true
			}
			assert(errorThrown, "Data doesnt exist error should have been thrown")
			
		} catch {
			assertionFailure()
		}
	}
	
	/**
	  Tests that the add command works as it should.
	*/
	func testAddCommand() {
		precondition(library.count == 0, "Library should be empty.")
		
		var command: MMCommand
		var errorThrown: Bool
		var prevResults: [MMFile] = library.all()
		
		// Test adding to an empty library
		command = AddCommand(data: ["0", "test1", "new"], library: library, lastsearch: prevResults)
		errorThrown = false
		do {
			try command.execute()
		} catch {
			errorThrown = true
		}
		assert(errorThrown, "Library is empty error should have been thrown")
		
		library.add(file: f1)
		library.add(file: f2)
		assert(library.count == 2, "Library should contain two files.")
		
		do {
			// Test setting to an empty result set
			command = AddCommand(data: ["0", "test1", "new"], library: library, lastsearch: prevResults)
			errorThrown = false
			do {
				try command.execute()
			} catch {
				errorThrown = true
			}
			assert(errorThrown, "Library is empty error should have been thrown")
			
			// Test adding one MD to a file
			prevResults = library.all()
			assert(prevResults[0] as! File == f1, "f1 should be at results 0 index.")
			assert(prevResults[0].metadata.count == 2, "f1 should have 2 md key pairs only.")
			command = AddCommand(data: ["0", "test1", "new"], library: library, lastsearch: prevResults)
			try command.execute()
			prevResults = library.all()
			assert(prevResults[0] as! File == f1, "f1 should be at results 0 index still.")
			var mArr = prevResults[0].metadata
			var md = mArr[2]
			assert(mArr.count == 3, "f1 should have 3 md key pairs now")
			assert(md.keyword == "test1", "Keyword should be test1.")
			assert(md.value == "new", "value should be new.")
			
			// Test setting more than one works
			prevResults = library.all()
			assert(prevResults[1] as! File == f2, "f2 should be at results 1 index.")
			assert(prevResults[1].metadata.count == 2, "f2 should have 2 md key pairs only.")
			command = AddCommand(data: ["1", "test1", "new","test2","other"], library: library, lastsearch: prevResults)
			try command.execute()
			prevResults = library.all()
			assert(prevResults[1] as! File == f2, "f2 should be at results 1 index still.")
			mArr = prevResults[1].metadata
			var md1 = mArr[2]
			var md2 = mArr[3]
			assert(mArr.count == 4, "f2 should have 4 md key pairs now")
			assert(md1.keyword == "test1", "Keyword should be test1.")
			assert(md1.value == "new", "value should be new.")
			assert(md2.keyword == "test2", "Keyword should be test2.")
			assert(md2.value == "other", "value should be other.")
			
			// Check adding duplicate metadata fails
			command = AddCommand(data: ["0", "creator", "newCreator"], library: library, lastsearch: prevResults)
			errorThrown = false
			do {
				try command.execute()
			} catch {
				errorThrown = true
			}
			assert(errorThrown, "Duplicate metadata error should have been thrown")
			
		} catch {
			assertionFailure()
		}
	}
	
	/**
	  Tests that the set command works as it should.
	*/
	func testSetCommand() {
		precondition(library.count == 0, "Library should be empty.")
		
		var command: MMCommand
		var errorThrown: Bool
		var prevResults: [MMFile] = library.all()
		
		// Test setting an empty library
		command = SetCommand(data: ["0", "creator", "new"], library: library, lastsearch: prevResults)
		errorThrown = false
		do {
			try command.execute()
		} catch {
			errorThrown = true
		}
		assert(errorThrown, "Library is empty error should have been thrown")
		
		library.add(file: f1)
		library.add(file: f2)
		assert(library.count == 2, "Library should contain two files.")
		
		do {
			// Test setting an empty result set
			command = SetCommand(data: ["0", "creator", "new"], library: library, lastsearch: prevResults)
			errorThrown = false
			do {
				try command.execute()
			} catch {
				errorThrown = true
			}
			assert(errorThrown, "Library is empty error should have been thrown")
			
			// Test setting one file works
			prevResults = library.all()
			assert(prevResults[0] as! File == f1, "f1 should be at results 0 index.")
			var mArr = prevResults[0].metadata
			var md = mArr[0]
			assert(md.keyword == kv11.keyword, "Keyword should be creator.")
			assert(md.value == kv11.value, "value should be cre1.")
			assert(md.keyword == "creator", "Keyword should be creator.")
			assert(md.value == "cre1", "value should be cre1.")
			command = SetCommand(data: ["0", "creator", "new"], library: library, lastsearch: prevResults)
			try command.execute()
			prevResults = library.all()
			assert(prevResults[0] as! File == f1, "f1 should be at results 0 index still.")
			mArr = prevResults[0].metadata
			md = mArr[1]
			assert(md.keyword == kv11.keyword, "Keyword should be creator.")
			assert(md.value != kv11.value, "value should not be cre1.")
			assert(md.keyword == "creator", "Keyword should be creator.")
			assert(md.value == "new", "value should be new.")
			
			// Test setting more than one works
			prevResults = library.all()
			assert(prevResults[1] as! File == f2, "f1 should be at results 0 index.")
			command = SetCommand(data: ["1", "creator","new","resolution","420"], library: library, lastsearch: prevResults)
			try command.execute()
			mArr = prevResults[1].metadata
			var md1 = mArr[0]
			var md2 = mArr[1]
			assert(md1.keyword == kv21.keyword, "Keyword should be creator.")
			assert(md1.value != kv21.value, "value should not be cre2.")
			assert(md1.keyword == "creator", "Keyword should be creator.")
			assert(md1.value == "new", "value should be new.")
			assert(md2.keyword == kv22.keyword, "Keyword should be resolution.")
			assert(md2.value != kv22.value, "value should not be res2.")
			assert(md2.keyword == "resolution", "Keyword should be resolution.")
			assert(md2.value == "420", "value should be 420.")
			
			// Test setting non existent throws
			command = SetCommand(data: ["0", "notthere", "new"], library: library, lastsearch: prevResults)
			errorThrown = false
			do {
				try command.execute()
			} catch {
				errorThrown = true
			}
			assert(errorThrown, "Data doesn't exist error should have been thrown")

		} catch {
			assertionFailure()
		}
	}
	
	/**
	  Tests that the delete command works as it should.
	*/
	func testDeleteCommand() {
		precondition(library.count == 0, "Library should be empty.")
		library.add(file: f1)
		library.add(file: f2)
		assert(library.count == 2, "Library should contain two files.")
		
		var prevResults = library.all()
		assert(prevResults[0].metadata.count == 2, "file 1 should have 2 metadata")
		assert(prevResults[1].metadata.count == 2, "file 2 should have 2 metadata")
		
		var command: MMCommand
		var errorThrown: Bool = false
		
		do {
			// Test delete required fails
			command = DeleteCommand(data: ["0", "creator"], library: library, lastsearch: prevResults)
			do {
				try command.execute()
			} catch {
				errorThrown = true
			}
			assert(errorThrown, "Data doesnt exist error should have been thrown")
			prevResults = library.all()
			assert(prevResults[0].metadata.count == 2, "file 1 should have 2 metadata")
			assert(prevResults[1].metadata.count == 2, "file 2 should have 2 metadata")
			
			// Test delete non exist throws
			command = DeleteCommand(data: ["0","test"], library: library, lastsearch: prevResults)
			errorThrown = false
			do {
				try command.execute()
			} catch {
				errorThrown = true
			}
			assert(errorThrown, "Data doesnt exist error should have been thrown")
			prevResults = library.all()
			assert(prevResults[0].metadata.count == 2, "file 1 should have 2 metadata")
			assert(prevResults[1].metadata.count == 2, "file 2 should have 2 metadata")
			
			// Test delete existing works
			library.add(metadata: Metadata(keyword: "test", value: "new"), file: f1)
			prevResults = library.all()
			assert(prevResults[0].metadata.count == 3, "file 1 should have 3 metadata")
			assert(prevResults[1].metadata.count == 2, "file 2 should have 2 metadata")
			command = DeleteCommand(data: ["0","test"], library: library, lastsearch: prevResults)
			try command.execute()
			assert(prevResults[0].metadata.count == 2, "file 1 should have 2 metadata")
			assert(prevResults[1].metadata.count == 2, "file 2 should have 2 metadata")
		} catch {
			assertionFailure()
		}
	}
	
	/**
	  Tests that the save search command works as it should.
	*/
	func testSaveSearchCommand() {
		precondition(library.count == 0, "Library should be empty.")
		library.add(file: f1)
		library.add(file: f2)
		assert(library.count == 2, "Library should contain two files.")
		
		var prevResults = library.search(term: "cre1")
		assert(prevResults[0] as! File == f1, "file 1 should have been found")
		assert(prevResults.count == 1, "only one file should be found")
	
		var errorThrown: Bool = false
		let filename: String = "saveSearchOutput"
		let filename2: String = "~/saveSearchOutput"

		var command: MMCommand
		do {
			
			// Search for one key and save this to working directory
			command = SaveSearchCommand(data: [filename+"1"], lastsearch: prevResults)
			try command.execute()

			// Search for one key and save this to home
			command = SaveSearchCommand(data: [filename2+"1"], lastsearch: prevResults)
			try command.execute()
			
			// Search for non exist and save should throw
			prevResults = library.search(term: "none")
			command = SaveSearchCommand(data: [filename+"2"], lastsearch: prevResults)
			do {
				try command.execute()
			} catch {
				errorThrown = true
			}
			assert(errorThrown, "No result set error should have been thrown")
			
			// Search for more than one key and save this
			prevResults = library.search(term: "creator")
			assert(prevResults.count == 2, "two files should exist")
			command = SaveSearchCommand(data: [filename+"3"], lastsearch: prevResults)
			try command.execute()
			
			// Would test that save search writes to fullpath but can only do this manually.
			
		} catch {
			assertionFailure()
		}
	}
	
	/**
	  Tests that the save command works as it should.
	*/
	func testSaveCommand() {
		precondition(library.count == 0, "Library should be empty.")
		var errorThrown: Bool = false
		let filename: String = "wholeLibraryOutput"
		let filename2: String = "~/wholeLibraryOutput"
		var command: MMCommand
		
		// Test no library throws an error
		command = SaveCommand(data: [filename+"1"], library: library)
		do {
			try command.execute()
		} catch {
			errorThrown = true
		}
		assert(errorThrown, "Library empty error should have been thrown")
		
		library.add(file: f1)
		library.add(file: f2)
		assert(library.count == 2, "Library should contain two files.")
		
		do {
			// Test whole library saves to working
			command = SaveCommand(data: [filename+"2"], library: library)
			try command.execute()
			
			// Test whole library +1 saves to home
			library.add(file: f3)
			command = SaveCommand(data: [filename2+"3"], library: library)
			try command.execute()
			
			// Would test that save command writes to fullpath but can only do this manually.
			
		} catch {
			assertionFailure()
		}
	}
}
