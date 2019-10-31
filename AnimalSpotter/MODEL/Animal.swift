//
//  Animal.swift
//  AnimalSpotter
//
//  Created by John Pitts on 10/31/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

class Animal: Codable {
    
    let id: Int
    var name: String
    var timeSeen: Date
    var latitude: Double
    var longitude: Double
    let description: String
    let imageURL: String

}
