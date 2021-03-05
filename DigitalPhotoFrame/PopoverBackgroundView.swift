////
////  PopoverBackgroundView.swift
////  DigitalPhotoFrame
////
////  Created by Andrei Marincas on 1/9/18.
////  Copyright © 2018 Andrei Marincas. All rights reserved.
////
//
//import UIKit
//
//class PopoverBackgroundView: UIPopoverBackgroundView {
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        self.layer.shadowColor = UIColor.black.cgColor
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    override static func contentViewInsets() -> UIEdgeInsets {
//        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
//    }
//    
//    override static func arrowHeight() -> CGFloat {
//        return 20
//    }
//    
//    override static func arrowBase() -> CGFloat {
//        return 20
//    }
//    
//    private var _arrowDirection: UIPopoverArrowDirection = .up
//    override var arrowDirection: UIPopoverArrowDirection {
//        set {
//            _arrowDirection = newValue
//        }
//        get {
//            return _arrowDirection
//        }
//    }
//    
//    private var _arrowOffset: CGFloat = 10
//    override var arrowOffset: CGFloat {
//        set {
//            _arrowOffset = newValue
//        }
//        get {
//            return _arrowOffset
//        }
//    }
//}
