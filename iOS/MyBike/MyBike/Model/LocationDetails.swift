//
//  LocationDetails.swift
//  MyBike
//
//  Created by Apoorva Reed(Personal) on 2/21/19.
//  Copyright © 2019 Apoorva Reed(Personal). All rights reserved.
//

import Foundation

class LocationDetails{
    let bikeId: Int
    let bikeType: Int
    let lattitude: Double
    let longitude: Double
    
    init(bikeid: Int, biketype: Int, lat: Double, long: Double) {
        bikeId = bikeid
        bikeType = biketype
        lattitude = lat
        longitude = long
        
    }
    
}
