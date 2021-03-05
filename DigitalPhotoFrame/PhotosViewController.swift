//
//  PhotosViewController.swift
//  DigitalPhotoFrame
//
//  Created by Andrei Marincas on 1/1/18.
//  Copyright © 2018 Andrei Marincas. All rights reserved.
//

import UIKit
import Photos

enum Transition {
    case transitionCrossDissolve
    case transitionCurlUp
    case transitionCurlDown
    case transitionFlipFromRight
    case transitionFlipFromTop
    case transitionFlipFromLeft
    case transitionFlipFromBottom
    case transitionSlideFromRight
    case transitionSlideFromTop
    case transitionSlideFromLeft
    case transitionSlideFromBottom
}

extension UIViewAnimationOptions {
    
    init?(transition: Transition) {
        switch transition {
        case .transitionCrossDissolve:
            self = .transitionCrossDissolve
        case .transitionCurlUp:
            self = .transitionCurlUp
        case .transitionCurlDown:
            self = .transitionCurlDown
        case .transitionFlipFromRight:
            self = .transitionFlipFromRight
        case .transitionFlipFromTop:
            self = .transitionFlipFromTop
        case .transitionFlipFromLeft:
            self = .transitionFlipFromLeft
        case .transitionFlipFromBottom:
            self = .transitionFlipFromBottom
        default:
            return nil
        }
    }
}

extension PhotoAnimation {
    
    var transitions: [Transition]? {
        switch self {
        case .crossDissolve:
            return [.transitionCrossDissolve]
        case .curl:
            return [.transitionCurlUp, .transitionCurlDown]
        case .flip:
            return [.transitionFlipFromRight, .transitionFlipFromTop, .transitionFlipFromLeft, .transitionFlipFromBottom]
        case .slide:
            return [.transitionSlideFromRight, .transitionSlideFromTop, .transitionSlideFromLeft, .transitionSlideFromBottom]
        default:
            return nil
        }
    }
    
    static let allTransitions: [Transition]  = {
        var all = [Transition]()
        for raw in 0..<PhotoAnimation.count {
            if let transitions = PhotoAnimation(rawValue: raw)?.transitions {
                all += transitions
            }
        }
        return all
    }()
}

class PhotosViewController: UIViewController {
    
    @IBOutlet var imageView1: UIImageView!
    @IBOutlet var imageView2: UIImageView!
    
    private var photos: [Photo] = []
    private var currentIndex: Int = 0
    private var timer: Timer?
    private let displayDuration: TimeInterval = TimeInterval(Settings.time)
    private let transitionDuration: TimeInterval = 1.5
    
    private let isRandom = Settings.isRandom
    private var photoRandom: Random?
    
    private let animation: PhotoAnimation = Settings.animation
    
    private let transitions: [Transition]? = {
        let anim = Settings.animation
        switch anim {
        case .crossDissolve, .curl, .flip, .slide:
            return anim.transitions
        case .any:
            return PhotoAnimation.allTransitions
        default:
            return nil
        }
    }()
    private var transitionIdx = 0
    private var transitionRandom: Random?
    
    var isReady = false {
        didSet {
            if isReady {
                guard let mainVC = self.parent as? MainViewController else { return }
                mainVC.onPhotosViewControllerIsReady(self)
            }
        }
    }
    
    init(photos: [Photo]) {
        self.photos = photos
        if self.isRandom {
            self.photoRandom = Random(photos.count)
        }
        if self.animation == .any {
            self.transitionRandom = Random((self.transitions)!.count)
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadImage(at: currentIndex, in: imageView1) {
            if self.photos.count == 1 {
                self.isReady = true
            }
        }
        if photos.count > 1 {
            if isRandom {
                currentIndex = (photoRandom?.next)!
                if currentIndex == 0 {
                    currentIndex = (photoRandom?.next)!
                }
            } else {
                currentIndex = 1
            }
            loadImage(at: currentIndex, in: imageView2) {
                self.isReady = true
            }
        }
        imageView2.isHidden = true
        restartTimer()
    }
    
    func restartTimer() {
        timer = Timer.scheduledTimer(timeInterval: displayDuration, target: self, selector: #selector(onTransition), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func loadImage(at index: Int, in imageView: UIImageView, completion: (() -> Void)?) {
        guard index >= 0 && index < photos.count else { return }
        let asset = photos[index].asset
        let requestOptions = PHImageRequestOptions()
        requestOptions.resizeMode = PHImageRequestOptionsResizeMode.exact
        requestOptions.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
        DispatchQueue.global().async {
            PHImageManager.default().requestImage(for: asset!, targetSize: PHImageManagerMaximumSize, contentMode: PHImageContentMode.default, options: requestOptions, resultHandler: { (pickedImage, info) in
                DispatchQueue.main.async { [weak self] in
                    guard let _ = self else { return }
                    if let img = pickedImage {
                        imageView.image = img
                    }
                    completion?()
                }
            })
        }
    }
    
    private var nextTransition: Transition? {
        guard self.animation != .none else { return nil }
        var transition: Transition?
        if self.animation != .any {
            // Cycle through animation's transitions
            let transitions = self.animation.transitions!
            transition = transitions[self.transitionIdx]
            if self.transitionIdx < transitions.count - 1 {
                self.transitionIdx = self.transitionIdx + 1
            } else {
                self.transitionIdx = 0
            }
        } else {
            // Random transition
            let random = self.transitionRandom!
            let idx = random.next!
            return PhotoAnimation.allTransitions[idx]
        }
        return transition
    }
    
    private func getConstraint(for imageView: UIImageView, with attribute: NSLayoutAttribute) -> NSLayoutConstraint? {
        for constraint in self.view.constraints {
            if let firstItem = constraint.firstItem as? NSObject, firstItem == imageView {
                if constraint.firstAttribute == attribute {
                    return constraint
                }
            }
            if let secondItem = constraint.secondItem as? NSObject, secondItem == imageView {
                if constraint.secondAttribute == attribute {
                    return constraint
                }
            }
        }
        return nil
    }
    
    @objc private func onTransition() {
        print("on transition")
        guard photos.count > 1 else { return }
        if self.isRandom {
            self.currentIndex = (self.photoRandom!).next!
        } else {
            if self.currentIndex < self.photos.count - 1 {
                self.currentIndex = self.currentIndex + 1
            } else {
                self.currentIndex = 0
            }
        }
        let fromImageView, toImageView: UIImageView?
        if self.imageView1.isHidden {
            fromImageView = self.imageView2
            toImageView = self.imageView1
        } else {
            fromImageView = self.imageView1
            toImageView = self.imageView2
        }
        if self.animation != .none {
            let transition = self.nextTransition!
            if let uiViewTransition = UIViewAnimationOptions(transition: transition) {
                let options: UIViewAnimationOptions = [.showHideTransitionViews, uiViewTransition, .curveEaseInOut]
                UIView.transition(from: fromImageView!, to: toImageView!, duration: self.transitionDuration, options: options) { [weak self] finished in
                    guard let weakSelf = self else { return }
                    weakSelf.view.bringSubview(toFront: toImageView!)
                    weakSelf.loadImage(at: weakSelf.currentIndex, in: fromImageView!, completion: nil)
                }
            } else {
                // Custom transition
                performCustomTransition(transition, from: fromImageView!, to: toImageView!)
            }
            
        } else { // no animation
            self.view.bringSubview(toFront: toImageView!)
            toImageView!.isHidden = false
            self.loadImage(at: self.currentIndex, in: fromImageView!, completion: nil)
            fromImageView!.isHidden = true
        }
    }
    
    private func performCustomTransition(_ transition: Transition, from fromImageView: UIImageView, to toImageView: UIImageView) {
        print("perform custom transition")
        let spacing: CGFloat = 50
        let completion: (() -> Void) = { [weak self] in
            guard let weakSelf = self else { return }
            weakSelf.view.bringSubview(toFront: toImageView)
            toImageView.isHidden = false
            weakSelf.loadImage(at: weakSelf.currentIndex, in: fromImageView, completion: nil)
            fromImageView.isHidden = true
        }
        switch transition {
        case .transitionSlideFromLeft:
            let fromImageViewCenterX = getConstraint(for: fromImageView, with: .centerX)
            let toImageViewCenterX = getConstraint(for: toImageView, with: .centerX)
            let offset = view.frame.width + spacing
            toImageViewCenterX?.constant = -offset
            view.layoutIfNeeded()
            toImageView.isHidden = false
            UIView.animate(withDuration: self.transitionDuration, delay: 0, options: .curveEaseInOut, animations: { [weak self] in
                guard let weakSelf = self else { return }
                fromImageViewCenterX?.constant = offset
                toImageViewCenterX?.constant = 0
                weakSelf.view.layoutIfNeeded()
            }, completion: { [weak self] finished in
                guard let weakSelf = self else { return }
                fromImageView.isHidden = true
                fromImageViewCenterX?.constant = 0
                weakSelf.view.layoutIfNeeded()
                completion()
            })
            break
        case .transitionSlideFromRight:
            let fromImageViewCenterX = getConstraint(for: fromImageView, with: .centerX)
            let toImageViewCenterX = getConstraint(for: toImageView, with: .centerX)
            let offset = view.frame.width + spacing
            toImageViewCenterX?.constant = offset
            view.layoutIfNeeded()
            toImageView.isHidden = false
            UIView.animate(withDuration: self.transitionDuration, delay: 0, options: .curveEaseInOut, animations: { [weak self] in
                guard let weakSelf = self else { return }
                fromImageViewCenterX?.constant = -offset
                toImageViewCenterX?.constant = 0
                weakSelf.view.layoutIfNeeded()
            }, completion: { [weak self] finished in
                guard let weakSelf = self else { return }
                fromImageView.isHidden = true
                fromImageViewCenterX?.constant = 0
                weakSelf.view.layoutIfNeeded()
                completion()
            })
            break
        case .transitionSlideFromTop:
            let fromImageViewCenterY = getConstraint(for: fromImageView, with: .centerY)
            let toImageViewCenterY = getConstraint(for: toImageView, with: .centerY)
            let offset = view.frame.height + spacing
            toImageViewCenterY?.constant = -offset
            view.layoutIfNeeded()
            toImageView.isHidden = false
            UIView.animate(withDuration: self.transitionDuration, delay: 0, options: .curveEaseInOut, animations: { [weak self] in
                guard let weakSelf = self else { return }
                fromImageViewCenterY?.constant = offset
                toImageViewCenterY?.constant = 0
                weakSelf.view.layoutIfNeeded()
            }, completion: { [weak self] finished in
                guard let weakSelf = self else { return }
                fromImageView.isHidden = true
                fromImageViewCenterY?.constant = 0
                weakSelf.view.layoutIfNeeded()
                completion()
            })
            break
        case .transitionSlideFromBottom:
            let fromImageViewCenterY = getConstraint(for: fromImageView, with: .centerY)
            let toImageViewCenterY = getConstraint(for: toImageView, with: .centerY)
            let offset = view.frame.height + spacing
            toImageViewCenterY?.constant = offset
            view.layoutIfNeeded()
            toImageView.isHidden = false
            UIView.animate(withDuration: self.transitionDuration, delay: 0, options: .curveEaseInOut, animations: { [weak self] in
                guard let weakSelf = self else { return }
                fromImageViewCenterY?.constant = -offset
                toImageViewCenterY?.constant = 0
                weakSelf.view.layoutIfNeeded()
            }, completion: { [weak self] finished in
                guard let weakSelf = self else { return }
                fromImageView.isHidden = true
                fromImageViewCenterY?.constant = 0
                weakSelf.view.layoutIfNeeded()
                completion()
            })
            break
        default:
            print("what are you doing here?")
            break
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func handleTap(gesture: UITapGestureRecognizer) {
        guard let mainVC = parent as? MainViewController else { return }
        stopTimer()
        mainVC.returnToAlbums(animated: true)
    }
    
    deinit {
        print("deinit photos vc")
    }
}
