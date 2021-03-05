//
//  AlbumCell.swift
//  DigitalPhotoFrame
//
//  Created by Andrei Marincas on 12/31/17.
//  Copyright © 2017 Andrei Marincas. All rights reserved.
//

import UIKit

class AlbumCell: UICollectionViewCell {
    
    @IBOutlet weak var frontImageView: UIImageView!
    @IBOutlet weak var middleImageView: UIImageView!
    @IBOutlet weak var backImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nrPhotosLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.applyBorderStyle(to: self.frontImageView)
        self.applyBorderStyle(to: self.middleImageView)
        self.applyBorderStyle(to: self.backImageView)
    }
    
    private func applyBorderStyle(to imageView: UIImageView) {
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 2.0
        imageView.layer.cornerRadius = 6.0
        imageView.layer.masksToBounds = true
    }
    
    func imageView(at index: Int) -> UIImageView? {
        switch index {
        case 0: return backImageView
        case 1: return middleImageView
        case 2: return frontImageView
        default: return nil
        }
    }
}
