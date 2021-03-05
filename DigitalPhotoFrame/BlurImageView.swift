//
//  BlurImageView.swift
//  DigitalPhotoFrame
//
//  Created by Andrei Marincas on 1/10/18.
//  Copyright © 2018 Andrei Marincas. All rights reserved.
//

import UIKit
import GPUImage

class BlurImageView: UIView {
    
    private var imageLayer: CALayer!
    private var backgroundImageLayer: CALayer!
    
    private let blurRadius: CGFloat = 30
    
    private var _image: UIImage?
    var image: UIImage? {
        get {
            return _image
        }
        set {
            _image = newValue
            
            if let image = _image {
                // Load the background layer temporarily until the blur is drawn
                backgroundImageLayer.contents = image.cgImage
//                backgroundImageLayer.opacity = 0.5
                
                // Draw the blur outside the main thread
                DispatchQueue.global().async { [weak self] in
                    guard let weakSelf = self else { return }
                    logDebug("Start blurring...")
                    let blurImage = weakSelf.applyBlurBackground(with: image)
                    if let _ = blurImage {
                        logDebug("Blurring done.")
                    } else {
                        logError("Failed to blur!")
                    }
                    DispatchQueue.main.async {
                        if image == weakSelf.image {
                            weakSelf.backgroundImageLayer.contents = blurImage?.cgImage
                            weakSelf.backgroundImageLayer.opacity = 1
                        }
                    }
                }
                
//                DispatchQueue.global().async { [weak self] in
//                    guard let weakSelf = self else { return }
//                    var blurImage: UIImage?
//                    if let scaledImage = UIImage.imageWithImage(image, scaledToWidth: image.size.width / 2) {
//                        let rect = CGRect(x: 0, y: 0, width: scaledImage.size.width, height: scaledImage.size.height)
//                        logDebug("Scaled image size: \(rect)")
//                        logDebug("Start blurring...")
//                        //blurImage = scaledImage.applyBlurInRect(rect: rect, withRadius: 30)
////                        blurImage = scaledImage.applyLightEffect()
//                        blurImage = scaledImage.applyBlurWithRadius(30, tintColor: nil, saturationDeltaFactor: 1.2)
//                        if let _ = blurImage {
//                            logDebug("Blurring done.")
//                        } else {
//                            logError("Failed to generate blur image!")
//                        }
//                    } else {
//                        logError("Couldn't scale image!")
//                    }
//                    DispatchQueue.main.async {
//                        if image == weakSelf.image {
//                            weakSelf.backgroundImageLayer.contents = blurImage?.cgImage
//                        }
//                    }
//                }
                
                imageLayer.contents = image.cgImage
            } else {
                backgroundImageLayer.contents = nil
                imageLayer.contents = nil
            }
        }
    }
    
    /* 
     Applies blur effect only on the black bars, when the image and background layer have different aspect ratios.
     */
    private func applyBlurBackground(with image: UIImage) -> UIImage? {
        let backgroundAspect: CGFloat = self.backgroundImageLayer.frame.size.width / self.backgroundImageLayer.frame.size.height
        let imageAspect: CGFloat = image.size.width / image.size.height
        guard imageAspect != backgroundAspect else { return nil }
        
        var blurImage: UIImage?
        
        if imageAspect > backgroundAspect {
            // The image is wider than the background layer, we have top and bottom black bars
            let scaledWidth: CGFloat = min(UIScreen.main.scale * self.backgroundImageLayer.frame.size.width, image.size.width)
            let scaledHeight: CGFloat = scaledWidth / imageAspect
            let scaledHeightForBgAspect: CGFloat = scaledWidth / backgroundAspect
            let scaledImage = image.scaled(to: CGSize(width: scaledWidth, height: scaledHeightForBgAspect))
            let blackBar: CGFloat = (scaledHeightForBgAspect - scaledHeight) / 2
            let topBar = CGRect(x: 0, y: 0, width: scaledWidth, height: blackBar)
            let bottomBar = CGRect(x: 0, y: scaledHeightForBgAspect - blackBar, width: scaledWidth, height: blackBar)
            blurImage = scaledImage?.applyBlurInRect(firstRect: topBar, secondRect: bottomBar, withRadius: self.blurRadius)
        } else {
            // The image is taller than the background layer, we have left and right black bars
            // TODO: Calculate left and right bars
        }
        
        return blurImage
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
        // Create background image layer
        backgroundImageLayer = CALayer()
        backgroundImageLayer.backgroundColor = UIColor.black.cgColor
        backgroundImageLayer.contentsGravity = kCAGravityResizeAspectFill
        backgroundImageLayer.frame = self.layer.bounds
        self.layer.addSublayer(backgroundImageLayer)
        // Create foreground image layer
        imageLayer = CALayer()
        imageLayer.backgroundColor = UIColor.clear.cgColor
        imageLayer.contentsGravity = kCAGravityResizeAspect
        imageLayer.frame = self.layer.bounds
        self.layer.addSublayer(imageLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundImageLayer.frame = self.layer.bounds
        imageLayer.frame = self.layer.bounds
    }
}
