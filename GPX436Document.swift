//
//  GPX436Document.swift
//  assign4
//
//  Created by Kevin Nogales on 4/22/20.
//  Copyright © 2020 Kevin Nogales. All rights reserved.
//

import Foundation
import UIKit

class GPX436Document: UIDocument {
    var container: GPX436Container?
    
    override func contents(forType typeName: String) throws -> Any {
        //Encode document with an instance of NSData or NSFileWrapper.
        return container?.json ?? Data()
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        // Load document from contents.
        if let data = contents as? Data {
            container = GPX436Container(json: data)
        }
    }
}
