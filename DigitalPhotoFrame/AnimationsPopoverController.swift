//
//  AnimationsPopoverController.swift
//  DigitalPhotoFrame
//
//  Created by Andrei Marincas on 1/4/18.
//  Copyright © 2018 Andrei Marincas. All rights reserved.
//

import UIKit

enum PhotoAnimation: Int {
    case none = 0
    case any
    case slide
    case crossDissolve
    case curl
    case flip
    
    var localizedName: String {
        switch self {
        case .none:
            return String.localized("settings_animation_none_btn")
        case .crossDissolve:
            return String.localized("settings_animation_cross_dissolve_btn")
        case .curl:
            return String.localized("settings_animation_curl_btn")
        case .flip:
            return String.localized("settings_animation_flip_btn")
        case .any:
            return String.localized("settings_animation_any_btn")
        case .slide:
            return String.localized("settings_animation_slide_btn")
        }
    }
    
    static let count: Int = {
        var n = 0
        while let _ = PhotoAnimation(rawValue: n) {
            n += 1
        }
        return n
    }()
}

protocol AnimationsPopoverDelegate: class {
    
    func animationsPopover(_ popover: AnimationsPopoverController, didSelectAnimation animation: PhotoAnimation)
}

class AnimationsPopoverController: UIViewController {
    
    class Cell: UITableViewCell {
        
        override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            commonInit()
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            commonInit()
        }
        
        private func commonInit() {
            textLabel?.font = UIFont.systemFont(ofSize: 17)
            textLabel?.textColor = Color.blueRibbon
            textLabel?.textAlignment = .center
            backgroundColor = .clear
            let selectedBg = UIView()
            selectedBg.backgroundColor = .clear
            selectedBackgroundView = selectedBg
            accessoryView = dummyAccessory
        }
        
        override func setHighlighted(_ highlighted: Bool, animated: Bool) {
            super.setHighlighted(highlighted, animated: animated)
            backgroundColor = isHighlighted ? UIColor(white: 0.05, alpha: 1) : .clear
        }
        
        override func setSelected(_ selected: Bool, animated: Bool) {
            super.setSelected(selected, animated: animated)
            if isSelected {
                accessoryType = .checkmark
                accessoryView = nil
            } else {
                accessoryView = dummyAccessory
                accessoryType = .none
            }
            
        }
        
        var dummyAccessory: UIView {
            let accessory = UIView()
            accessory.frame = CGRect(x: 0, y: 0, width: 24, height: 11)
            return accessory
        }
    }
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var tableViewHeight: NSLayoutConstraint!
    fileprivate let cellReuseID = "cellReuseID"
    
    fileprivate let animations: [PhotoAnimation] = [.none, .any, .crossDissolve, .slide, .curl, .flip]
    fileprivate var selectedRow: Int
    
    weak var delegate: AnimationsPopoverDelegate?
    
    init(animation: PhotoAnimation) {
        selectedRow = animations.index(of: animation)!
        super.init(nibName: "AnimationsPopoverController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(Cell.self, forCellReuseIdentifier: cellReuseID)
        tableView.reloadData()
        tableViewHeight.constant = tableView.contentSize.height
        tableView.disableDelaysContentTouches()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.selectRow(at: IndexPath(row: selectedRow, section: 0), animated: false, scrollPosition: .none)
    }
}

extension AnimationsPopoverController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return animations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: cellReuseID) as? Cell
        if cell == nil {
            cell = Cell(style: .default, reuseIdentifier: cellReuseID)
        }
        let anim = animations[indexPath.row]
        cell?.textLabel?.text = anim.localizedName
        if anim == .any || anim == .none {
            cell?.textLabel?.textColor = Color.chileanFire
            cell?.tintColor = Color.chileanFire
        } else {
            cell?.textLabel?.textColor = Color.blueRibbon
            cell?.tintColor = Color.blueRibbon
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRow = indexPath.row
        delegate?.animationsPopover(self, didSelectAnimation: animations[selectedRow])
    }
}
