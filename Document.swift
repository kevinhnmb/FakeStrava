//
//  Document.swift
//  assign4
//
//  Created by Kevin Nogales on 4/22/20.
//  Copyright © 2020 Kevin Nogales. All rights reserved.
//

import UIKit

class Document: UIDocument {
    
    override func contents(forType typeName: String) throws -> Any {
        // Encode your document with an instance of NSData or NSFileWrapper
        return Data()
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        // Load your document from contents
    }
}

