//
//  GPX536Container.swift
//  assign4
//
//  Created by Kevin Nogales on 4/22/20.
//  Copyright © 2020 Kevin Nogales. All rights reserved.
//

import Foundation
import UIKit

struct GPX436Point: Codable {
    var latitude: Double
    var longitude: Double
    
    init(lat: Double, long: Double) {
        latitude = lat
        longitude = long
        
    }
}

class GPX436Container: Codable {
    var points: [GPX436Point] = []
    var distance: CGFloat = 0
    var miles: CGFloat = 0
    
    init() {
        self.points = []
        self.distance = 0
        self.miles = 0
    }
    
    // Load data from disk, and decode.
    init?(json: Data) {
        if let decoded = try? JSONDecoder().decode(GPX436Container.self, from: json) {
            self.points = decoded.points
            self.distance = decoded.distance
            self.miles = decoded.miles
        }
    }
    
    // Convert to data that can be written.
    var json: Data? {
        return try? JSONEncoder().encode(self)
    }
}
