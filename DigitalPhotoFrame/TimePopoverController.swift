//
//  TimePopoverController.swift
//  DigitalPhotoFrame
//
//  Created by Andrei Marincas on 1/3/18.
//  Copyright © 2018 Andrei Marincas. All rights reserved.
//

import UIKit

protocol TimePopoverDelegate: class {
    
    func timePopover(_ popover: TimePopoverController, didChangeValue seconds: Int)
}

class TimePopoverController: UIViewController {
    
    @IBOutlet var picker: UIPickerView!
    
    fileprivate let values: [Int] = [5, 10, 15, 20, 25, 30, 45, 60, 120] // animation time in seconds
    fileprivate var currentIndex: Int
    
    weak var delegate: TimePopoverDelegate?
    
    init(seconds: Int) {
        currentIndex = values.index(of: seconds)!
        super.init(nibName: "TimePopoverController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Color.mineShaft
//        view.backgroundColor = UIColor(white: 0.15, alpha: 1)
//        view.layer.shadowColor = UIColor.red.cgColor
//        view.layer.shadowRadius = 1
//        view.layer.shadowOpacity = 1
//        view.layer.masksToBounds = false
        picker.selectRow(currentIndex, inComponent: 0, animated: false)
    }
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        view.layer.shadowPath = CGPath(rect: view.bounds, transform: nil)
////        view.superview?.layer.shadowColor = UIColor.green.cgColor
////        view.superview?.layer.masksToBounds = false
////        view.superview?.superview?.layer.shadowColor = UIColor.green.cgColor
//        for subview in (view.superview?.subviews)! {
//            subview.layer.shadowColor = UIColor.green.cgColor
//        }
//    }
    
    func formatTime(_ seconds: Int) -> String {
        var res = ""
        if seconds < 60 {
            res = String.localized("settings_nr_seconds", seconds % 60)
        } else if seconds == 60 {
            res = String.localized("settings_one_minute") //"1 minute"
        } else { // seconds > 60
            res = String.localized("settings_nr_minutes", seconds / 60)
        }
        return res
    }
}

extension TimePopoverController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return values.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var label = view as? UILabel
        if label == nil {
            label = UILabel()
            label?.font = UIFont.systemFont(ofSize: 17)
            label?.textColor = Color.blueRibbon
            label?.textAlignment = .center
        }
        label?.text = formatTime(values[row])
        return label!
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 30
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentIndex = row
        delegate?.timePopover(self, didChangeValue: values[currentIndex])
    }
}
