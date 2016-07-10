//
//  MovieCollectionViewCell.swift
//  TheMovieDB
//
//  Created by Dinh Quang Hieu on 7/10/16.
//  Copyright © 2016 Dinh Quang Hieu. All rights reserved.
//

import UIKit

class MovieCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgViewPhoto: UIImageView!
    @IBOutlet weak var lblRating: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        //imgViewPhoto.image = nil
        //lblName.text = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layer.cornerRadius = 15
    }
    

}
