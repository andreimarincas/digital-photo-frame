////
////  GradientView.swift
////  DigitalPhotoFrame
////
////  Created by Andrei Marincas on 1/7/18.
////  Copyright © 2018 Andrei Marincas. All rights reserved.
////
//
//import UIKit
//
//class GradientView: UIView {
//    
//    var firstColor: UIColor = UIColor.red {
//        didSet {
//            applyGradient()
//        }
//    }
//    var secondColor: UIColor = UIColor.green {
//        didSet {
//            applyGradient()
//        }
//    }
//    
//    var vertical: Bool = true {
//        didSet {
//            applyGradient()
//        }
//    }
//    
//    private var _gradientLayer: CAGradientLayer?
//    var gradientLayer: CAGradientLayer {
//        if _gradientLayer == nil {
//            _gradientLayer = CAGradientLayer()
//            layer.addSublayer(_gradientLayer!)
//        }
//        return _gradientLayer!
//    }
//    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        applyGradient()
//    }
//    
//    func applyGradient() {
//        let colors = [firstColor.cgColor, secondColor.cgColor]
//        gradientLayer.colors = colors
//        gradientLayer.frame = self.bounds
//        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
//        gradientLayer.endPoint = vertical ? CGPoint(x: 0, y: 1) : CGPoint(x: 1, y: 0)
//    }
//    
//    override func draw(_ rect: CGRect) {
//        super.draw(rect)
//        
//        #if TARGET_INTERFACE_BUILDER
//            applyGradient()
//        #endif
//    }
//}
