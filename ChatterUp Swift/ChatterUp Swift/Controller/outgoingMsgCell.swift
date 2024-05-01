//
//  outgoingMsgCell.swift
//  ChatterUp Swift
//
//  Created by Supriyo Dey on 01/05/24.
//

import UIKit

class outgoingMsgCell: UITableViewCell {
    @IBOutlet weak var vwContainer: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        vwContainer.layer.cornerRadius = 20
        vwContainer.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner]
    }

}
