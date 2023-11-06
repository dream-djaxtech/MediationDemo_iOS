//
//  ListTvCell.swift
//  SwiftProject
//
//  Created by Djax on 25/07/22.
//

import UIKit

class ListTvCell: UITableViewCell {
    
    @IBOutlet weak var titleLblNew: UILabel!
    @IBOutlet weak var titleImgNew: UIImageView!
    @IBOutlet weak var clickBtn: UIButton!

     override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
