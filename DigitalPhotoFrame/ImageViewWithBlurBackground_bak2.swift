//
//  ImageViewWithBlurBackground.swift
//  DigitalPhotoFrame
//
//  Created by Andrei Marincas on 1/10/18.
//  Copyright © 2018 Andrei Marincas. All rights reserved.
//

import UIKit

class ImageViewWithBlurBackground_bak2: UIView {
    
    var imageView: UIImageView!
    var backgroundImageView: UIImageView!
    var effectView: UIVisualEffectView!
    
    private var _image: UIImage?
    var image: UIImage? {
        get {
            return _image
        }
        set {
            _image = newValue
            self.backgroundImageView.image = _image
            self.imageView.image = _image
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        self.backgroundColor = .black
        self.layer.masksToBounds = true
        
        backgroundImageView = UIImageView(frame: self.bounds)
        backgroundImageView.backgroundColor = .black
        backgroundImageView.contentMode = .scaleAspectFill
        self.addSubview(backgroundImageView)
        
        let blur = UIBlurEffect(style: .dark)
        let effectView = UIVisualEffectView(effect: blur)
        let vibrancy = UIVibrancyEffect(blurEffect: blur)
        effectView.effect = vibrancy
        effectView.frame = backgroundImageView.bounds
//        backgroundImageView.addSubview(effectView)
        self.addSubview(effectView)
        self.effectView = effectView
        
        imageView = UIImageView(frame: self.bounds)
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFit
        self.addSubview(imageView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateUI()
    }
    
    private func updateUI() {
        backgroundImageView.frame = self.bounds
//        effectView.frame = backgroundImageView.bounds
        effectView.frame = self.bounds
        imageView.frame = self.bounds
    }
}
