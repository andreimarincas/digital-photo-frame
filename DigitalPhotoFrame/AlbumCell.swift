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
    
    fileprivate var frontImageCenter: CGPoint?
    fileprivate var middleImageCenter: CGPoint?
    fileprivate var backImageCenter: CGPoint?
    
    override var isHighlighted: Bool {
        didSet {
            alpha = isHighlighted ? 0.5 : 1
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        applyBorderStyle(to: frontImageView)
        applyBorderStyle(to: middleImageView)
        applyBorderStyle(to: backImageView)
    }
    
    private func applyBorderStyle(to imageView: UIImageView) {
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 3.0
        imageView.layer.cornerRadius = 3.0
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
    
    var photosCount: Int {
        var count = 0
        for imageView in [frontImageView, middleImageView, backImageView] {
            if imageView!.image != nil && !(imageView!.isHidden) {
                count += 1
            }
        }
        return count
    }
}

/* Unfold / Foldup animations */
extension AlbumCell {
    
    func prepareToUnfold() {
        guard photosCount > 1 else { return }
        let frontFrame = frontImageView.frame
        frontImageView.layer.anchorPoint = CGPoint(x: 0.3, y: 1)
        frontImageView.frame = frontFrame
        let backFrame = backImageView.frame
        backImageView.layer.anchorPoint = CGPoint(x: 0.3, y: 1)
        backImageView.frame = backFrame
    }
    
    func unfold() {
        guard photosCount > 1 else { return }
        frontImageCenter = frontImageView.center
        frontImageView.center = frontImageCenter!.offsetBy(dx: 0, dy: -25)
        frontImageView.transform = CGAffineTransform(rotationAngle: -CGFloat.pi_12)
        frontImageView.alpha = 0.9
        middleImageCenter = middleImageView.center
        middleImageView.center = middleImageCenter!.offsetBy(dx: 0, dy: -30)
        middleImageView.alpha = 0.9
        backImageCenter = backImageView.center
        backImageView.center = backImageCenter!.offsetBy(dx: 0, dy: -25)
        backImageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi_12)
    }
    
    func foldup() {
        guard photosCount > 1 else { return }
        frontImageView.center = frontImageCenter!
        frontImageView.transform = CGAffineTransform.identity
        frontImageView.alpha = 1
        middleImageView.center = middleImageCenter!
        middleImageView.alpha = 1
        backImageView.center = backImageCenter!
        backImageView.transform = CGAffineTransform.identity
    }
    
    func finalizeFoldup() {
        guard photosCount > 1 else { return }
        let frontImageFrame = frontImageView.frame
        frontImageView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        frontImageView.frame = frontImageFrame
        let backImageFrame = backImageView.frame
        backImageView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        backImageView.frame = backImageFrame
    }
}
