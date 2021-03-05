//
//  ViewController.swift
//  DigitalPhotoFrame
//
//  Created by Andrei Marincas on 12/27/17.
//  Copyright © 2017 Andrei Marincas. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController {
    
    @IBOutlet var imageView1: UIImageView!
    @IBOutlet var imageView2: UIImageView!
    
    //let selectedAlbum = "Crăciun 2017"
//    let selectedAlbum = "Camera Roll"
//    let selectedAlbum = "All Photos"
//    let selectedAlbum = "Family"
    let selectedAlbum = "Familia"
    var album: Album!
    
//    let displayDuration: TimeInterval = 10.0
    let displayDuration: TimeInterval = 15
    let transitionDuration: TimeInterval = 2.0
    
    var currentIndex: Int = 0
    var timer: Timer!
    
    let transitions: [UIViewAnimationOptions] = [.transitionCrossDissolve, .transitionCurlUp, .transitionCurlDown,
                                                 .transitionFlipFromLeft, .transitionFlipFromRight, .transitionFlipFromTop, .transitionFlipFromBottom]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        setupPhotos()
    }
    
//    private func didFetchAlbums() {
//        self.printAlbums()
//        
//        let selectedAlbum = albums.first(where: { $0.title == self.selectedAlbum })
//        guard let album = selectedAlbum else { return }
//        
////        // Load images for selected album
////        for a in albums {
////            if a.title == selectedAlbum {
////                self.fetchPhotos(in: a)
////                self.imageView1.image = self.images.first
////                // Start the transition timer
////                self.timer = Timer.scheduledTimer(timeInterval: self.waitingTime, target: self, selector: #selector(onTransition), userInfo: nil, repeats: true)
////                break
////            }
////        }
//        
////        let idx = random_int(album.photos.count)
//        let idx = 0
//        self.loadImage(from: album.photos[idx], in: self.imageView1)
//        self.currentIndex = idx
//        if album.photos.count > 1 {
////            let idx2 = random_int(album.photos.count)
//            let idx2 = 1
//            self.loadImage(from: album.photos[idx2], in: self.imageView2)
//            self.currentIndex = idx2
//        }
//        
//        self.album = album
//        self.timer = Timer.scheduledTimer(timeInterval: self.displayDuration, target: self, selector: #selector(onTransition), userInfo: nil, repeats: true)
//    }
    
//    private func fetchPhotos(in album: Album) {
//        let requestOptions = PHImageRequestOptions()
//        requestOptions.resizeMode = PHImageRequestOptionsResizeMode.exact
//        requestOptions.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
//        requestOptions.isSynchronous = true
//        
//        for i in 0..<album.photos.count {
//            let asset: PHAsset = album.photos[i]
//            
//            PHImageManager.default().requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: PHImageContentMode.default, options: requestOptions, resultHandler: { (pickedImage, info) in
//                if let img = pickedImage {
//                    self.images.append(img)
//                }
//            })
//        }
//    }
    
    private func loadImage(from asset: PHAsset, in imageView: UIImageView) {
        let requestOptions = PHImageRequestOptions()
        requestOptions.resizeMode = PHImageRequestOptionsResizeMode.exact
        requestOptions.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
        requestOptions.isSynchronous = true
        
        PHImageManager.default().requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: PHImageContentMode.default, options: requestOptions, resultHandler: { (pickedImage, info) in
            if let img = pickedImage {
                imageView.image = img
            }
        })
    }
    
    @objc private func onTransition() {
//        let nextIndex: Int = self.currentIndex
//        if nextIndex < self.images.count - 1 {
//            self.currentIndex = self.currentIndex + 1
//        }
//        
//        self.nextImageView.image = self.images[nextIndex]
//        
////        UIView.transition(with: self.imageView, duration: self.transitionTime, options: .transitionCrossDissolve, animations: {
////            self.imageView.image = self.images[self.currentIndex]
////        }, completion: nil)
//        
//        UIView.transition(from: self.currentImageView, to: self.nextImageView, duration: self.transitionTime, options: .transitionCrossDissolve, completion: nil)
//        
//        self.currentIndex = nextIndex
        
        if self.currentIndex < self.album.photos.count - 1 {
            self.currentIndex = self.currentIndex + 1
        } else {
            self.currentIndex = 0
        }
        
//        self.currentIndex = Int(arc4random_uniform(UInt32(self.album.photos.count)))
//        self.currentIndex = random_int(self.album.photos.count)
        
        let fromImageView, toImageView: UIImageView?
        if self.imageView1.isHidden {
            fromImageView = self.imageView2
            toImageView = self.imageView1
        } else {
            fromImageView = self.imageView1
            toImageView = self.imageView2
        }
        
        //let transitionIdx = Int(arc4random_uniform(UInt32(self.transitions.count)))
        let transitionIdx = random_int(self.transitions.count)
        UIView.transition(from: fromImageView!, to: toImageView!, duration: self.transitionDuration, options: [.showHideTransitionViews, self.transitions[transitionIdx]]) { finished in
            self.view.bringSubview(toFront: toImageView!)
            self.loadImage(from: self.album.photos[self.currentIndex], in: fromImageView!)
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
//    private func randomInt(upperBound: Int) -> Int {
//        return Int(arc4random_uniform(UInt32(upperBound)))
//    }
}
