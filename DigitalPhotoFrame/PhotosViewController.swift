//
//  PhotosViewController.swift
//  DigitalPhotoFrame
//
//  Created by Andrei Marincas on 1/1/18.
//  Copyright © 2018 Andrei Marincas. All rights reserved.
//

import UIKit
import Photos

class PhotosViewController: UIViewController {
    
    @IBOutlet var imageView1: UIImageView!
    @IBOutlet var imageView2: UIImageView!
    
    var photos: [Photo] = []
    var currentIndex: Int = 0
    var timer: Timer?
    let displayDuration: TimeInterval = 5
    let transitionDuration: TimeInterval = 2
    let transitions: [UIViewAnimationOptions] = [.transitionCrossDissolve,
                                                 .transitionCurlUp, .transitionCurlDown,
                                                 .transitionFlipFromLeft, .transitionFlipFromRight, .transitionFlipFromTop, .transitionFlipFromBottom]
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
            currentIndex = 1
            loadImage(at: currentIndex, in: imageView2) {
                self.isReady = true
            }
        }
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
    
    @objc private func onTransition() {
        print("on transition")
        guard photos.count > 1 else { return }
        if self.currentIndex < self.photos.count - 1 {
            self.currentIndex = self.currentIndex + 1
        } else {
            self.currentIndex = 0
        }
        let fromImageView, toImageView: UIImageView?
        if self.imageView1.isHidden {
            fromImageView = self.imageView2
            toImageView = self.imageView1
        } else {
            fromImageView = self.imageView1
            toImageView = self.imageView2
        }
        let transitionIdx = random_int(self.transitions.count)
        UIView.transition(from: fromImageView!, to: toImageView!, duration: self.transitionDuration, options: [.showHideTransitionViews, self.transitions[transitionIdx]]) { [weak self] finished in
            guard let weakSelf = self else { return }
            weakSelf.view.bringSubview(toFront: toImageView!)
            weakSelf.loadImage(at: weakSelf.currentIndex, in: fromImageView!, completion: nil)
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func handleTap(gesture: UITapGestureRecognizer) {
        guard let mainVC = parent as? MainViewController else { return }
        mainVC.returnToAlbums()
        stopTimer()
    }
    
    deinit {
        print("deinit photos vc")
    }
}
