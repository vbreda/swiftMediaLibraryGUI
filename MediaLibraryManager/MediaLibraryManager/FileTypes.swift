//
//  FileTypes.swift
//  MediaLibraryManager
//
//  Created by Nikolah Pearce and Vivian Breda on 22/08/18.
//  Copyright © 2018 Paul Crane. All rights reserved.
//

import Foundation

/**
 Image class extends file.
 Required metadata fields: creator and resolution
 */
class Image : File {
    
    // The resolution of the image, as specified at load time.
    var originalResolution : String
    
    //The image's current resolution.
    var resolution : String {
        var res: String = ""
        for m in metadata {
            if m.keyword.lowercased() == "resolution" {
                res = m.value
            }
        }
        return res
    }
    
    /**
     Designated initialiser
     
     - parameter metadata: All the metadata associated with the Image file.
     - parameter filename: The name of the Image file.
     - parameter path: The path to the Image file.
     - parameter creator: The creator of the Image file.
     - parameter resolution: The resolution of the Image file.
     */
    init(metadata: [MMMetadata], filename: String, path: String, creator: String, resolution: String) {
        self.originalResolution = resolution
        super.init(metadata: metadata, filename: filename, path: path, creator: creator)
    }
    
}

/**
 Video class extends file.
 Required metadata fields: creator, resolution and runtime.
 */
class Video : File {
    
    // The resolution of the video, as specified at load time.
    var originalResolution : String
    
    // The runtime of the video, as specified at load time.
    var originalRuntime: String
    
    // The video's current resolution.
    var resolution : String {
        var res: String = ""
        for m in metadata {
            if m.keyword.lowercased() == "resolution" {
                res = m.value
            }
        }
        return res
    }
    
    // The video's current runtime.
    var runtime : String {
        var run: String = ""
        for m in metadata {
            if m.keyword.lowercased() == "runtime" {
                run = m.value
            }
        }
        return run
    }
    
    /**
     Designated initialiser
     
     - parameter metadata: All the metadata associated with the Video file.
     - parameter filename: The name of the Video file.
     - parameter path: The path to the Video file.
     - parameter creator: The creator of the Video file.
     - parameter resolution: The resolution of the Video file.
     - parameter runtime: The runtime of the Video file.
     */
    init(metadata: [MMMetadata], filename: String, path: String, creator: String, resolution: String, runtime: String) {
        self.originalResolution = resolution
        self.originalRuntime = runtime
        super.init(metadata: metadata, filename: filename, path: path, creator: creator)
    }
}

/**
 Audio class extends file.
 Required metadata fields: creator and runtime
 */
class Audio : File {
    
    // The runtime of the audio, as specified at load time.
    var originalRuntime: String
    
    // The audio's current runtime.
    var runtime : String {
        var run: String = ""
        for m in metadata {
            if m.keyword.lowercased() == "runtime" {
                run = m.value
            }
        }
        return run
    }
    
    /**
     Designated initialiser
     
     - parameter metadata: All the metadata associated with the Audio file.
     - parameter filename: The name of the Audio file.
     - parameter path: The path to the Audio file.
     - parameter creator: The creator of the Audio file.
     - parameter runtime: The runtime of the Audio file.
     */
    init(metadata: [MMMetadata], filename: String, path: String, creator: String, runtime: String) {
        self.originalRuntime = runtime
        super.init(metadata: metadata, filename: filename, path: path, creator: creator)
    }
    
}

/**
 Audio class extends file.
 Required metadata fields: creator
 */
class Document : File {
    
}
