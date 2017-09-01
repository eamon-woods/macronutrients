//
//  Food.swift
//  Food
//
//  Created by Eamon Woods on 7/31/17.
//
//

import Foundation

class Food {
    var ndbno: String
    var name: String
    var type: String?
    var nutrients: [String: [String: Double]]?
    var acceptableMeasurements: [String]?
    
    init(ndbno: String, name: String) {
        self.ndbno = ndbno
        self.name = name
    }
}
