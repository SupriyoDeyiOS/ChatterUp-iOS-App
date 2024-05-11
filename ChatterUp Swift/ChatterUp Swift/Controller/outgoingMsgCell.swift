//
//  outgoingMsgCell.swift
//  ChatterUp Swift
//
//  Created by Supriyo Dey on 01/05/24.
//

import UIKit

class outgoingMsgCell: UITableViewCell {
    @IBOutlet weak var vwContainer: UIView!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var constImgHeight: NSLayoutConstraint!
    @IBOutlet weak var constImgWidth: NSLayoutConstraint!
    @IBOutlet weak var vwImgContainer: UIView!
    
    var longPressGesture = CustomLongPressGestureRecognizer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        img.layer.cornerRadius = 5
        
        vwContainer.layer.cornerRadius = 20
        vwContainer.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func addLongPress() {
        contentView.addGestureRecognizer(longPressGesture)
    }
    
    func setImage(with image: UIImage?) {
        vwImgContainer.isHidden = false
        if let image = image {
            img.image = image
            let imageSize = image.size
            let aspectRatio = imageSize.width / imageSize.height
            
            // Calculate the desired width and height for the image view
            let imageViewWidth = min((bounds.width-130), imageSize.width)
            let imageViewHeight = imageViewWidth / aspectRatio
            
            // Set the constraints of the image view
            constImgWidth.constant = imageViewWidth
            constImgHeight.constant = imageViewHeight
            
            img.contentMode = .scaleAspectFill
        } else {
            img.image = nil
            vwImgContainer.isHidden = true
        }
    }
}
