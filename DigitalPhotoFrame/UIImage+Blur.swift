//
//  UIImage+Blur.swift
//  DigitalPhotoFrame
//
//  Created by Andrei Marincas on 1/10/18.
//  Copyright © 2018 Andrei Marincas. All rights reserved.
//

import UIKit

extension UIImage {
    
    func getImageFromRect(rect: CGRect) -> UIImage? {
        if let cg = self.cgImage,
            let mySubimage = cg.cropping(to: rect) {
            return UIImage(cgImage: mySubimage)
        }
        return nil
    }
    
//    func blurImage(withRadius radius: Double) -> UIImage? {
//        let inputImage = CIImage(cgImage: self.cgImage!)
//        if let filter = CIFilter(name: "CIGaussianBlur") {
//            filter.setValue(inputImage, forKey: kCIInputImageKey)
//            filter.setValue((radius), forKey: kCIInputRadiusKey)
//            if let blurred = filter.outputImage {
//                return UIImage(ciImage: blurred)
//            }
//        }
//        return nil
//    }
    
    func blurImage(withRadius radius: Double) -> UIImage? {
        guard let cgImage = self.cgImage else { return nil }
        let inputImage = CIImage(cgImage: cgImage)
        
        // Apply Affine-Clamp filter to stretch the image so that it does not
        // look shrunken when gaussian blur is applied
        let transform = CGAffineTransform.identity
        let clampFilter = CIFilter(name: "CIAffineClamp")
        clampFilter?.setValue(inputImage, forKey: kCIInputImageKey)
        clampFilter?.setValue(NSValue(cgAffineTransform: transform), forKey: kCIInputTransformKey)
        
        // Apply gaussian blur filter with radius
        let blurFilter = CIFilter(name: "CIGaussianBlur")
        blurFilter?.setValue(clampFilter?.outputImage, forKey: kCIInputImageKey)
        blurFilter?.setValue(radius, forKey: kCIInputRadiusKey)
        
        var outputImage: UIImage?
        let ciContext = CIContext(options: nil)
//        let colorSpace = CGColorSpaceCreateDeviceRGB()
//        let wkColorSpace = CGColorSpaceCreateDeviceRGB()
//        let ciContext = CIContext(options: [kCIContextUseSoftwareRenderer: true,
//                                            kCIContextOutputColorSpace: colorSpace,
//                                            kCIContextWorkingColorSpace: wkColorSpace,
//                                            kCIContextHighQualityDownsample: false])
        
        if let outputImageData: CIImage = blurFilter?.value(forKey: kCIOutputImageKey) as? CIImage {
            if let outputImageRef: CGImage = ciContext.createCGImage(outputImageData, from: inputImage.extent) {
                outputImage = UIImage(cgImage: outputImageRef)
            }
        }
        
        return outputImage
    }
    
    func drawImageInRect(inputImage: UIImage, inRect imageRect: CGRect) -> UIImage? {
        UIGraphicsBeginImageContext(self.size)
        self.draw(in: CGRect(x: 0.0, y: 0.0, width: self.size.width, height: self.size.height))
        inputImage.draw(in: imageRect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func applyBlurInRect(rect: CGRect, withRadius radius: Double) -> UIImage? {
        if let subImage = self.getImageFromRect(rect: rect),
            let blurredZone = subImage.blurImage(withRadius: radius) {
            return self.drawImageInRect(inputImage: blurredZone, inRect: rect)
        }
        return nil
    }
    
    func applyBlurInRect(firstRect: CGRect, secondRect: CGRect, withRadius blurRadius: CGFloat) -> UIImage? {
        let tint = UIColor(white: 0.11, alpha: 0.2)
        let saturation: CGFloat = 1.8
        
        let subImage1 = self.getImageFromRect(rect: firstRect)
        let blurredZone1 = subImage1?.applyBlurWithRadius(blurRadius, tintColor: tint, saturationDeltaFactor: saturation)
        guard let blurred1 = blurredZone1 else { return nil }
        
        let subImage2 = self.getImageFromRect(rect: secondRect)
        let blurredZone2 = subImage2?.applyBlurWithRadius(blurRadius, tintColor: tint, saturationDeltaFactor: saturation)
        guard let blurred2 = blurredZone2 else { return nil }
        
        UIGraphicsBeginImageContext(self.size)
        blurred1.draw(in: firstRect)
        blurred2.draw(in: secondRect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}

extension UIImage {
    
    static func imageWithImage(_ sourceImage: UIImage, scaledToWidth i_width: CGFloat) -> UIImage? {
        let oldWidth: CGFloat = sourceImage.size.width
        let scaleFactor: CGFloat = i_width / oldWidth
        
        let newHeight: CGFloat = sourceImage.size.height * scaleFactor
        let newWidth: CGFloat = oldWidth * scaleFactor
        
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        sourceImage.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func scaled(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContext(size)
        self.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}
