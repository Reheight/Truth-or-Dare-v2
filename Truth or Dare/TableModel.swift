//
//  TableModel.swift
//  truthordare
//
//  Created by Dustin Palmatier on 11/2/19.
//  Copyright © 2019 Hexham Network. All rights reserved.
//

import UIKit

class TableModel: NSObject {
    //properties
    
    var sku: String?
    var message: String?
    var latitude: String?
    var longitude: String?
    
    
    //empty constructor
    
    override init()
    {
        
    }
    
    //construct with @name, @address, @latitude, and @longitude parameters
    
    init(sku: String, message: String) {
        
        self.sku = sku
        self.message = message
        
    }
    
    
    //prints object's current state
    
    override var description: String {
        return "SKU: \(sku), Message: \(message)"
        
    }
}
