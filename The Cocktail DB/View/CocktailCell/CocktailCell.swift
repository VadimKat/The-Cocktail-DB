//
//  CocktailCell.swift
//  The Cocktail DB
//
//  Created by Vadim Katenin on 22.06.2020.
//  Copyright © 2020 Vadim Katenin. All rights reserved.
//

import UIKit
import SDWebImage

class CocktailCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var cocktailImage: UIImageView!
    
    func configure(result: Cocktail) {
        nameLabel.text = result.name
        let url = result.thumbnailUrl
        cocktailImage.sd_setImage(with: url, placeholderImage: UIImage(named: "Placeholder1"), options: .highPriority)
    }
    
}
