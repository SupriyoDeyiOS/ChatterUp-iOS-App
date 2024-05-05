//
//  IncomingMsgCell.swift
//  ChatterUp Swift
//
//  Created by Supriyo Dey on 01/05/24.
//

import UIKit

class IncomingMsgCell: UITableViewCell {
    @IBOutlet weak var vwContainer: UIView!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var lblSender: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        vwContainer.layer.cornerRadius = 20
        vwContainer.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner]
    }

}
