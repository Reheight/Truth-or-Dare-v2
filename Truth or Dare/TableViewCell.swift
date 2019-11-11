//
//  TableViewCell.swift
//  truthordare
//
//  Created by Dustin Palmatier on 11/2/19.
//  Copyright © 2019 Hexham Network. All rights reserved.
//

import UIKit

struct Variables {
    var message: String
    var sku: String
}

class TableViewCell: UITableViewCell {
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    var buttonProceed: ((Any) -> Void)?
}
