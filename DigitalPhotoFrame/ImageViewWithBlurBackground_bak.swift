//
//  ImageViewWithBlurBackground_bak.swift
//  DigitalPhotoFrame
//
//  Created by Andrei Marincas on 1/10/18.
//  Copyright © 2018 Andrei Marincas. All rights reserved.
//

import UIKit
import GPUImage

class ImageViewWithBlurBackground: UIView {
    
//    private var filterView: GPUImageView!
//    private var imageView: UIImageView!
//    private var backgroundImageView: UIImageView!
//    private var effectView: UIVisualEffectView!
    
//    private static var blurFilter: GPUImageiOSBlurFilter = {
//        let filter = GPUImageiOSBlurFilter()
//        filter.blurRadiusInPixels = 10
//        return filter
//    }()
    
//    -(UIImage *) getBlurImage{
//    GPUImagePicture *sourcePicture = [[GPUImagePicture alloc] initWithImage:self.originalImage];
//    GPUImageOutput *filter = [[GPUImageGaussianBlurFilter alloc] init];
//    [(GPUImageGaussianBlurFilter *)filter setBlurSize:8];
//    [sourcePicture addTarget:filter];
//    [sourcePicture processImage];
//    UIImage *image = [filter imageFromCurrentlyProcessedOutputWithOrientation:UIImageOrientationUp];
//    return image;
//    
//    }
    
    private var imageLayer: CALayer!
    private var backgroundImageLayer: CALayer!
    
    /*private func getBlurImage(_ image: UIImage) -> UIImage? {
//        let sourcePicture = GPUImagePicture(image: image)
//        let filter = GPUImageGaussianBlurFilter()
//        filter.blurRadiusInPixels = 1.5
//        sourcePicture?.addTarget(filter)
//        sourcePicture?.processImage()
//        let cgImage = filter.newCGImageFromCurrentlyProcessedOutput()
//        var image: UIImage?
//        if let cgImageValue = cgImage {
//            image = UIImage(cgImage: cgImageValue.takeUnretainedValue())
//        }
//        return image
        
//        let blurFilter = GPUImageiOSBlurFilter()
//        blurFilter.blurRadiusInPixels = 10
//        blurFilter.useNextFrameForImageCapture()
//        let outputImage = blurFilter.image(byFilteringImage: image)
//        return outputImage
        
//        let blurFilter = ImageViewWithBlurBackground.blurFilter
////        blurFilter.useNextFrameForImageCapture()
//        let outputImage = blurFilter.image(byFilteringImage: image)
////        let imageInput = GPUImageInput()
////        blurFilter.setInputFramebufferForTarget(, at: <#T##Int#>)
////        let outputImage = blurFilter.imageFromCurrentFramebuffer(with: .up)
//        return outputImage
        
//        let ciContext = CIContext(options: nil)
//        
//        let blurFilter = CIFilter(name: "CIGaussianBlur")
//        blurFilter?.setValue(CIImage(image: image), forKey: "inputImage")
//        blurFilter?.setValue(10, forKey: "inputRadius")
//        
//        let outputImageData = blurFilter?.value(forKey: "outputImage") as! CIImage!
//        let outputImageRef: CGImage = ciContext.createCGImage(outputImageData!, from: outputImageData!.extent)!
//        
//        let outputImage = UIImage(cgImage: outputImageRef)
//        return outputImage
        
        
        let imageToBlur = CIImage(image: image)
        let blurfilter = CIFilter(name: "CIGaussianBlur")
        blurfilter?.setValue(imageToBlur, forKey: "inputImage")
        blurfilter?.setValue(2, forKey: "inputRadius")
        let resultImage = blurfilter?.value(forKey: "outputImage") as! CIImage
        let blurredImage = UIImage(ciImage: resultImage)
        return blurredImage
    }*/
    
    private var _image: UIImage?
    var image: UIImage? {
        get {
            return _image
        }
        set {
            _image = newValue
            
            
            
//            self.backgroundImageView.image = image
            
//            if let imageValue = _image {
//                DispatchQueue.global().async { [weak self] in
//                    guard let weakSelf = self else { return }
//                    if let blurImage = weakSelf.getBlurImage(imageValue) {
//                        DispatchQueue.main.async {
//                            if imageValue == weakSelf.image {
//                                weakSelf.backgroundImageView.image = blurImage
//                            }
//                        }
//                    }
//                }
//            } else {
//                self.backgroundImageView.image = nil
//            }
            
            
//            GPUImagePicture *stillImageSource = [[GPUImagePicture alloc] initWithImage:[self screenshot]];
//            
//            GPUImageTiltShiftFilter *boxBlur = [[GPUImageTiltShiftFilter alloc] init];
//            boxBlur.blurSize = 0.5;
//            
//            [stillImageSource addTarget:boxBlur];
//            
//            [stillImageSource processImage];
//            
//            UIImage *processedImage = [stillImageSource imageFromCurrentlyProcessedOutput];
            
            
            
            
//            self.blendImage = GPUImagePicture(image: inputImage)
//            GPUImageAlphaBlendFilter *blendFilter = [[GPUImageAlphaBlendFilter alloc] init];
//            blendFilter.mix = 1.0;
//            let blendFilter = GPUImageAlphaBlendFilter()
//            blendFilter.mix = 1
//            let uiElementInput = GPUImageUIElement(view: filterView)
//            blendFilter
            
//            [filter addTarget:blendFilter];
//            [uiElementInput addTarget:blendFilter];
//            
//            [blendFilter addTarget:filterView];
//            
//            __unsafe_unretained GPUImageUIElement *weakUIElementInput = uiElementInput;
//            
//            [filter setFrameProcessingCompletionBlock:^(GPUImageOutput * filter, CMTime frameTime){
//                timeLabel.text = [NSString stringWithFormat:@"Time: %f s", -[startTime timeIntervalSinceNow]];
//                [weakUIElementInput update];
//                }];
            
//            self.filterView
            
//            self.imageView.image = image
            
//            if let imageValue = _image {
//                backgroundImageLayer.contents = imageValue.cgImage
//                imageLayer.contents = imageValue.cgImage
//            } else {
//                backgroundImageLayer.contents = nil
//                imageLayer.contents = nil
//            }
            
            if let image = _image {
                
//                applyBlurBackground(with: image)
                
//                DispatchQueue.global().async { [weak self] in
//                    guard let weakSelf = self else { return }
//                    var blurImage: UIImage?
//                    if let scaledImage = UIImage.imageWithImage(image, scaledToWidth: image.size.width / 2) {
//                        let rect = CGRect(x: 0, y: 0, width: scaledImage.size.width, height: scaledImage.size.height)
//                        logDebug("Scaled image size: \(rect)")
//                        logDebug("Start blurring the image...")
//                        blurImage = scaledImage.applyBlurInRect(rect: rect, withRadius: 30)
//                        if let _ = blurImage {
//                            logDebug("Blurring complete.")
//                        } else {
//                            logError("Couldn't generate blur image!")
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
                
//                DispatchQueue.global().async { [weak self] in
//                    guard let weakSelf = self else { return }
//                    logDebug("Start blurring the image...")
//                    var blurImage: UIImage?
//                    let rect = CGRect(x: 0, y: 0, width: imageValue.size.width, height: imageValue.size.height)
//                    blurImage = imageValue.applyBlurInRect(rect: rect, withRadius: 70)
//                    if blurImage == nil {
//                        logError("Couldn't generate blur image!")
//                    } else {
//                        logDebug("Blurring complete.")
//                    }
//                    DispatchQueue.main.async {
//                        if imageValue == weakSelf.image {
//                            weakSelf.backgroundImageLayer.contents = blurImage?.cgImage
//                        }
//                    }
//                }
                
                backgroundImageLayer.contents = image.cgImage
                backgroundImageLayer.opacity = 0.5
                
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
    
    private func applyBlurBackground(with image: UIImage) -> UIImage? {
        let backgroundAspect: CGFloat = self.backgroundImageLayer.frame.size.width / self.backgroundImageLayer.frame.size.height
        let imageAspect: CGFloat = image.size.width / image.size.height
        guard imageAspect != backgroundAspect else { return nil }
        
        var blurImage: UIImage?
        let blurRadius: CGFloat = 30
        
        if imageAspect > backgroundAspect {
            // Image is wider than the background layer, we have top and bottom black bars
            
//            let scaledImage = UIImage.imageWithImage(image, scaledToWidth: image.size.width / 2)!
//            let width = scaledImage.size.width
//            let height: CGFloat = width / backgroundAspect
//            let scaledImageForBackgroundAspect = scaledIma
//            let blackBar: CGFloat = (height - scaledImage.size.height) / 2
//            let topBar = CGRect(x: 0, y: 0, width: width, height: blackBar)
//            let bottomBar = CGRect(x: 0, y: scaledImage.size.height - blackBar, width: width, height: blackBar)
//            blurImage = scaledImage.applyBlurInRect(firstRect: topBar, secondRect: bottomBar, withRadius: blurRadius)
            
            let scaledWidth: CGFloat = min(UIScreen.main.scale * self.backgroundImageLayer.frame.size.width, image.size.width)
            let scaledHeight: CGFloat = scaledWidth / imageAspect
            let scaledHeightForBgAspect: CGFloat = scaledWidth / backgroundAspect
            let scaledImage = image.scaled(to: CGSize(width: scaledWidth, height: scaledHeightForBgAspect))
            let blackBar: CGFloat = (scaledHeightForBgAspect - scaledHeight) / 2
            let topBar = CGRect(x: 0, y: 0, width: scaledWidth, height: blackBar)
            let bottomBar = CGRect(x: 0, y: scaledHeightForBgAspect - blackBar, width: scaledWidth, height: blackBar)
            blurImage = scaledImage?.applyBlurInRect(firstRect: topBar, secondRect: bottomBar, withRadius: blurRadius)
            
        } else {
            // Image is taller than the background layer, we have left and right black bars
        }
        
        return blurImage
    }
    
//    override func draw(_ layer: CALayer, in ctx: CGContext) {
//        if layer == self.backgroundImageLayer {
//            
//        }
//    }
    
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
        
//        backgroundImageView = UIImageView(frame: self.bounds)
//        backgroundImageView.backgroundColor = .black
//        backgroundImageView.contentMode = .scaleAspectFill
//        self.addSubview(backgroundImageView)
        
        backgroundImageLayer = CALayer()
        backgroundImageLayer.backgroundColor = UIColor.black.cgColor
        backgroundImageLayer.contentsGravity = kCAGravityResizeAspectFill
//        backgroundImageLayer.opacity = 0.3
//        backgroundImageLayer.frame = self.layer.bounds.insetBy(dx: -20, dy: -20)
        backgroundImageLayer.frame = self.layer.bounds
        self.layer.addSublayer(backgroundImageLayer)
//        backgroundImageLayer.position = CGPoint(x: self.layer.frame.size.width / 2, y: self.layer.frame.size.height / 2)
//        backgroundImageLayer.transform = CATransform3DMakeScale(1.2, 1.2, 1)
        
//        let blur = UIBlurEffect(style: .dark)
//        let effectView = UIVisualEffectView(effect: blur)
//        let vibrancy = UIVibrancyEffect(blurEffect: blur)
//        effectView.effect = vibrancy
//        backgroundImageView.addSubview(effectView)
//        self.effectView = effectView
        
//        filterView = GPUImageView(frame: self.bounds)
//        filterView.backgroundColor = .black
//        filterView.contentMode = .scaleAspectFill
//        self.addSubview(filterView)
        
//        imageView = UIImageView(frame: self.bounds)
//        imageView.backgroundColor = .clear
//        imageView.contentMode = .scaleAspectFit
//        self.addSubview(imageView)
        
        imageLayer = CALayer()
        imageLayer.backgroundColor = UIColor.clear.cgColor
        imageLayer.contentsGravity = kCAGravityResizeAspect
//        imageLayer.opacity = 0.3
        imageLayer.frame = self.layer.bounds
        self.layer.addSublayer(imageLayer)
//        imageLayer.position = CGPoint(x: self.layer.frame.size.width / 2, y: self.layer.frame.size.height / 2)
        
//        if let filter = CIFilter(name:"CIGaussianBlur") {
//            filter.name = "myFilter"
////            imageLayer.backgroundFilters = [filter]
////            imageLayer.setValue(10, forKeyPath: "backgroundFilters.myFilter.inputRadius")
////            imageView.layer.masksToBounds = false
//            
//            filter.setValue(10, forKey: "inputRadius")
//            imageLayer.backgroundFilters = [filter]
////            backgroundImageLayer.setValue(10, forKeyPath: "filters.myFilter.inputRadius")
//        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateUI()
    }
    
    private func updateUI() {
//        backgroundImageView.frame = self.bounds
////        effectView.frame = backgroundImageView.bounds
////        filterView.frame = self.bounds
//        imageView.frame = self.bounds
        
//        backgroundImageLayer.frame = self.layer.bounds
//        imageLayer.frame = backgroundImageLayer.bounds
//        imageLayer.position = CGPoint(x: backgroundImageLayer.frame.size.width / 2, y: backgroundImageLayer.frame.size.height / 2)
        
//        backgroundImageLayer.frame = self.layer.bounds.insetBy(dx: -200, dy: -200)
        backgroundImageLayer.frame = self.layer.bounds
//        backgroundImageLayer.position = CGPoint(x: self.layer.frame.size.width / 2, y: self.layer.frame.size.height / 2)
        imageLayer.frame = self.layer.bounds
//        imageLayer.position = CGPoint(x: self.layer.frame.size.width / 2, y: self.layer.frame.size.height / 2)
    }
}
