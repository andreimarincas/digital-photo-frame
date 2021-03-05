//
//  SettingsBar.swift
//  DigitalPhotoFrame
//
//  Created by Andrei Marincas on 1/3/18.
//  Copyright © 2018 Andrei Marincas. All rights reserved.
//

import UIKit

protocol SettingsBarDelegate: class {
    
    func settingsBar(_ bar: SettingsBar, didSelectTime value: Int)
    func settingsBar(_ bar: SettingsBar, didSelectAnimation value: PhotoAnimation)
    func settingsBar(_ bar: SettingsBar, didChangeIsRandom value: Bool)
}

class SettingsBar: UIView {
    
    @IBOutlet var photosButton: UIButton!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var timeButton: UIButton!
    @IBOutlet var animationLabel: UILabel!
    @IBOutlet var animationButton: UIButton!
    @IBOutlet var randomLabel: UILabel!
    @IBOutlet var randomButton: UIButton!
    
    var time: Int = 15 { // seconds
        didSet {
            timeButton.setTitle(formatValue(time), for: .normal)
        }
    }
    
    var animation: PhotoAnimation = .curl {
        didSet {
            animationButton.setTitle(animation.localizedName, for: .normal)
        }
    }
    
    var isRandom: Bool = false {
        didSet {
            randomButton.isSelected = isRandom
        }
    }
    
    weak var delegate: SettingsBarDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.text = String.localized("albums_title")
        photosButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        
        timeLabel.text = String.localized("settings_time_txt")
        animationLabel.text = String.localized("settings_animation_txt")
        randomLabel.text = String.localized("settings_random_txt")
        
        applyButtonStyle(to: timeButton)
        applyButtonStyle(to: animationButton)
        applyButtonStyle(to: randomButton)
        
        randomButton.setTitle(String.localized("settings_random_no_btn"), for: .normal)
        randomButton.setTitle(String.localized("settings_random_yes_btn"), for: .selected)
        randomButton.setTitle(String.localized("settings_random_yes_btn"), for: [.selected, .highlighted])
        
        // Set dummy values
        time = 15
        animation = PhotoAnimation.curl
        isRandom = false
    }
    
    private func applyButtonStyle(to button: UIButton!) {
        button.setTitleColor(Color.blueRibbon, for: .normal)
        button.setTitleColor(Color.blueRibbon.withAlphaComponent(0.3), for: .highlighted)
        button.setTitleColor(Color.blueRibbon.withAlphaComponent(0.3), for: [.selected, .highlighted])
    }
    
    func formatValue(_ seconds: Int) -> String {
        var res = ""
        if seconds < 60 {
            res = "\(seconds % 60) s"
        } else {
            res = "\(seconds / 60) m"
        }
        return res
    }
    
    @IBAction func openPhotosApp() {
        UIApplication.shared.open(URL(string:"photos-redirect://")!)
    }
    
    @IBAction func onTimePressed() {
        print("time pressed")
        delegate?.settingsBar(self, didSelectTime: time)
    }
    
    @IBAction func onAnimationPressed() {
        print("animation pressed")
        delegate?.settingsBar(self, didSelectAnimation: animation)
    }
    
    @IBAction func onRandomPressed() {
        print("random pressed")
        isRandom = !isRandom
        delegate?.settingsBar(self, didChangeIsRandom: isRandom)
    }
}
