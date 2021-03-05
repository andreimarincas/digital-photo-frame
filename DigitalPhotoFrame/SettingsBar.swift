//
//  SettingsBar.swift
//  DigitalPhotoFrame
//
//  Created by Andrei Marincas on 1/3/18.
//  Copyright © 2018 Andrei Marincas. All rights reserved.
//

import UIKit

class RandomSwitch: UISwitch {
    
    override var alignmentRectInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 0)
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if self.point(inside: point, with: event) {
            return super.hitTest(.zero, with: event)
        }
        return super.hitTest(point, with: event)
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let padding: CGFloat = 30
        let area = self.bounds.insetBy(dx: -padding, dy: -padding)
        return area.contains(point)
    }
}

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
    @IBOutlet var randomSwitch: UISwitch!
    
    var time: Int = 15 { // seconds
        didSet {
            timeButton.setTitle(formatValue(time), for: .normal)
        }
    }
    
    var animation: PhotoAnimation = .curl {
        didSet {
            animationButton.setTitle(animation.localizedName, for: .normal)
            layoutIfNeeded()
        }
    }
    
    var isRandom: Bool = false {
        didSet {
            randomSwitch.isOn = isRandom
        }
    }
    
    weak var delegate: SettingsBarDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        photosButton.setImage(UIImage(named: "photos_icon")!.withAlpha(0.3), for: .highlighted)
        titleLabel.text = String.localized("albums_title")
        photosButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        
        timeLabel.text = String.localized("settings_time_txt")
        animationLabel.text = String.localized("settings_animation_txt")
        randomLabel.text = String.localized("settings_random_txt")
        
        applyButtonStyle(to: timeButton)
        applyButtonStyle(to: animationButton)
        
        randomSwitch.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        randomSwitch.onTintColor = Color.blueRibbon
        
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
        logIN()
        delegate?.settingsBar(self, didSelectTime: time)
        logOUT()
    }
    
    @IBAction func onAnimationPressed() {
        logIN()
        delegate?.settingsBar(self, didSelectAnimation: animation)
        logOUT()
    }
    
    @IBAction func onRandomChanged(_ sender: UISwitch) {
        logIN()
        isRandom = sender.isOn
        delegate?.settingsBar(self, didChangeIsRandom: isRandom)
        logOUT()
    }
}
