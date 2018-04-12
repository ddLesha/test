//
//  BackEndTableViewCell.swift
//  funbox-test
//
//  Created by Alexey Kuznetsov on 04.04.2018.
//  Copyright © 2018 Alexey Kuznetsov. All rights reserved.
//

import UIKit

class BackEndTableViewCell: UITableViewCell {

    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelQuantity: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setupCell(name: String, quantity: String) {
        labelName.text = name
        labelQuantity.text = quantity + " шт."
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
