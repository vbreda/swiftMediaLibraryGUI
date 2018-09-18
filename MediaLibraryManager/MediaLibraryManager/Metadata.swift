//
//  Metadata.swift
//  MediaLibraryManager
//
//  Created by Nikolah Pearce and Vivian Breda on 13/08/18.
//  Copyright © 2018 Paul Crane. All rights reserved.
//

import Foundation

extension MMMetadata {
    
    static func == (lhs: Self, rhs: MMMetadata) -> Bool {
        return lhs.keyword == rhs.keyword && lhs.value == rhs.value
    }
    
    static func != (lhs: Self, rhs: MMMetadata) -> Bool{
        return !(lhs == rhs)
    }
}

/**
  Creates the metadata for a media file.
 */
class Metadata: MMMetadata {
   
    //STORED PROPERTIES
    private var _mdKeyword : String = ""
    private var _mdValue : String = ""
    
    /**
      Designated initialiser
     
      Metadata property/value pair is passed in the arguments of the initialiser.
     
      - parameter keyword: Metadata's keyword
      - parameter value: Metadata's value
     */
    init(keyword: String, value: String) {
        self._mdKeyword = keyword
        self._mdValue = value
    }
    
    //COMPUTED PROPERTIES
    
    //The metadata property.
    var keyword: String  {
        get {
            return self._mdKeyword
        }
        set (newKeyword) {
            self._mdKeyword = newKeyword
        }
    }
    
    //The value of the metadata property.
    var value: String {
        get {
            return self._mdValue
        }
        set (newValue) {
            self._mdValue = newValue
        }
    }
    
    /**
      String representation of the metadata
     
      - returns: String: String representation of the metadata.
     */
    var description: String {
        return "\(self.keyword): \(self.value)"
    }
}
