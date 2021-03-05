//
//  AlbumsViewController.swift
//  DigitalPhotoFrame
//
//  Created by Andrei Marincas on 12/31/17.
//  Copyright © 2017 Andrei Marincas. All rights reserved.
//

import UIKit
import Photos

struct Album {
    var asset: PHAssetCollection!
    var photos: PHFetchResult<PHAsset>!
    var title: String {
        if asset.assetCollectionType == .smartAlbum && asset.assetCollectionSubtype == .smartAlbumUserLibrary {
            return String.localized("user_library_album_title")
        }
        return asset.localizedTitle ?? ""
    }
    var isReversed: Bool {
        if asset.assetCollectionType == .smartAlbum {
            if asset.assetCollectionSubtype == .smartAlbumUserLibrary || asset.assetCollectionSubtype == .smartAlbumRecentlyAdded {
                return true
            }
        }
        return false
    }
}

struct Photo {
    var asset: PHAsset!
}

class AlbumsViewController: UIViewController {
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var settingsBar: SettingsBar!
    @IBOutlet var settingsViewTop: NSLayoutConstraint!
    fileprivate let cellReuseID = "cellReuseID"
    fileprivate var albums: [Album] = []
    var photosVC: PhotosViewController?
    var selectedIndexPath: IndexPath?
    
    var thumbnailSize: CGSize {
        if Device.IS_IPAD {
            return CGSize(width: 200.0, height: 200.0)
        } else { // iPhone
            return CGSize(width: 120.0, height: 120.0)
        }
    }
    
    var effectView: UIVisualEffectView!
    var effectViewContainer: UIView!
    
    private func createBlurEffectView() {
        let blur = UIBlurEffect(style: .dark)
        let effectView = UIVisualEffectView(effect: blur)
        let vibrancy = UIVibrancyEffect(blurEffect: blur)
        effectView.effect = vibrancy
        let effectViewContainer = UIView()
        effectViewContainer.isUserInteractionEnabled = true
        effectViewContainer.backgroundColor = UIColor(white: 0, alpha: 0.5)
        effectViewContainer.addSubview(effectView)
        effectViewContainer.isHidden = true
        effectView.alpha = 0
        collectionView.addSubview(effectViewContainer)
        self.effectView = effectView
        self.effectViewContainer = effectViewContainer
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "AlbumCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: cellReuseID)
        
        createBlurEffectView()
        
        let bgView = UIView()
        bgView.backgroundColor = .clear
        let tapGr = UITapGestureRecognizer(target: self, action: #selector(didTapOutsideCells(_:)))
        bgView.addGestureRecognizer(tapGr)
        collectionView.backgroundView = bgView
        
        setupPhotos()
        
        // Initialize settings
        settingsBar.time = Settings.time
        settingsBar.animation = Settings.animation
        settingsBar.isRandom = Settings.isRandom
        settingsBar.delegate = self
        
        collectionView.disableDelaysContentTouches()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateUI()
    }
    
    private func updateUI() {
        effectViewContainer.frame = collectionView.bounds
        effectView.frame = effectViewContainer.bounds
    }
    
    private func setupPhotos() {
        let fetchOptions = PHFetchOptions()
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: fetchOptions)
        let topLevelfetchOptions = PHFetchOptions()
        let topLevelUserCollections = PHCollectionList.fetchTopLevelUserCollections(with: topLevelfetchOptions)
        let allAlbums = [topLevelUserCollections, smartAlbums]
        var userLibrary: Album?
        var recentlyAdded: Album?
        for i in 0 ..< allAlbums.count {
            let result = allAlbums[i] as! PHFetchResult<PHCollection>
            result.enumerateObjects(using: { (asset, index, stop) -> Void in
                if let a = asset as? PHAssetCollection {
                    let opts = PHFetchOptions()
                    opts.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
                    let photos = PHAsset.fetchAssets(in: a, options: opts)
                    if let _ = photos.firstObject {
                        let obj = Album(asset: a, photos: photos)
                        if a.assetCollectionSubtype == .smartAlbumUserLibrary {
                            userLibrary = obj
                        } else if a.assetCollectionSubtype == .smartAlbumRecentlyAdded {
                            recentlyAdded = obj
                        } else {
                            self.albums.append(obj)
                        }
                    }
                }
                if i == (allAlbums.count - 1) && index == (result.count - 1) {
                    self.albums.sort(by: { (a, b) -> Bool in
                        return a.title < b.title
                    })
                    if let recentlyAdded = recentlyAdded {
                        self.albums.insert(recentlyAdded, at: 0)
                    }
                    if let userLibrary = userLibrary {
                        self.albums.insert(userLibrary, at: 0)
                    }
                    self.didFetchAlbums()
                }
            })
        }
    }
    
    private func didFetchAlbums() {
        self.printAlbums()
        self.collectionView.reloadData()
    }
    
    private func printAlbums() {
        for a in albums {
            print("\(a.title), \(a.photos.count) photos")
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @objc func didTapOutsideCells(_ gesture: UITapGestureRecognizer) {
        print("did tap outside cells")
//        if let photosVC = self.photosVC, let mainVC = parent as? MainViewController {
//            mainVC.resumePhotosViewController(photosVC)
//        }
    }
}

extension AlbumsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.albums.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseID, for: indexPath) as! AlbumCell
        let album = self.albums[indexPath.row]
        cell.titleLabel.text = album.title
        if album.photos.count == 1 {
            cell.nrPhotosLabel.text = String.localized("albums_subtitle_one_photo")
        } else {
            cell.nrPhotosLabel.text = String.localized("albums_subtitle_nr_photos", album.photos.count)
        }
        for i in 0..<3 {
            let idx = album.isReversed ? (album.photos.count - 1 - i) : i
            if idx >= 0 && idx < album.photos.count {
                cell.imageView(at: 2 - i)!.isHidden = false
                let asset = album.photos[idx]
                let requestOptions = PHImageRequestOptions()
                requestOptions.resizeMode = PHImageRequestOptionsResizeMode.fast
                requestOptions.deliveryMode = PHImageRequestOptionsDeliveryMode.opportunistic
                requestOptions.isSynchronous = true
                
                DispatchQueue.global().async {
                    PHImageManager.default().requestImage(for: asset, targetSize: self.thumbnailSize, contentMode: PHImageContentMode.aspectFit, options: requestOptions, resultHandler: { (pickedImage, info) in
                        if let img = pickedImage {
                            if cell.titleLabel.text == album.title {
                                DispatchQueue.main.async {
                                    if album.photos.count == 1 {
                                        cell.middleImageView.image = img
                                        cell.middleImageView.isHidden = false
                                        cell.frontImageView.isHidden = true
                                    } else {
                                        cell.imageView(at: 2 - i)!.image = img
                                    }
                                }
                            }
                        }
                    })
                }
            } else {
                cell.imageView(at: 2 - i)!.isHidden = true
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let _ = self.photosVC {
            self.photosVC = nil
        }
        selectedIndexPath = indexPath
        let selectedAlbum = albums[indexPath.row]
        var photos: [Photo] = []
        for i in 0..<selectedAlbum.photos.count {
            let idx = selectedAlbum.isReversed ? (selectedAlbum.photos.count - 1 - i) : i
            let asset = selectedAlbum.photos[idx]
            photos.append(Photo(asset: asset))
        }
        let photosVC = PhotosViewController(photos: photos)
        let mainVC = parent as? MainViewController
        mainVC?.presentPhotosViewController(photosVC)
        self.photosVC = photosVC
    }
}

extension AlbumsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if Device.IS_IPAD {
            return CGSize(width: 140.0, height: 180.0)
        } else { // iPhone
            return CGSize(width: 80.0, height: 120.0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if Device.IS_IPAD {
            return 50.0
        } else { // iPhone
            return 30.0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if Device.IS_IPAD {
            return 50.0
        } else { // iPhone
            return 30.0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        if Device.IS_IPAD {
            return UIEdgeInsets(top: 100.0, left: 80.0, bottom: 60.0, right: 80.0)
        } else { // iPhone
            return UIEdgeInsets(top: 30.0, left: 50.0, bottom: 30.0, right: 50.0)
        }
    }
}

extension AlbumsViewController: SettingsBarDelegate, TimePopoverDelegate, AnimationsPopoverDelegate {
    
    func settingsBar(_ bar: SettingsBar, didSelectTime value: Int) {
        let vc = TimePopoverController(seconds: value)
        vc.delegate = self
        vc.modalPresentationStyle = .popover
        vc.preferredContentSize = CGSize(width: 180, height: 200)
        present(vc, animated: true, completion: nil)
        let popover = vc.popoverPresentationController
        popover?.backgroundColor = vc.view.backgroundColor
        popover?.permittedArrowDirections = .up
        popover?.sourceView = settingsBar
        popover?.sourceRect = settingsBar.timeButton.frame.insetBy(dx: 0, dy: -15)
    }
    
    func settingsBar(_ bar: SettingsBar, didSelectAnimation value: PhotoAnimation) {
        let vc = AnimationsPopoverController(animation: value)
        vc.delegate = self
        vc.modalPresentationStyle = .popover
        vc.loadViewIfNeeded()
        vc.preferredContentSize = CGSize(width: 180, height: 230)
        present(vc, animated: true, completion: nil)
        let popover = vc.popoverPresentationController
        popover?.backgroundColor = vc.view.backgroundColor
        popover?.permittedArrowDirections = .up
        popover?.sourceView = settingsBar
        popover?.sourceRect = settingsBar.animationButton.frame.insetBy(dx: 0, dy: -15)
    }
    
    func settingsBar(_ bar: SettingsBar, didChangeIsRandom value: Bool) {
        Settings.isRandom = value
    }
    
    func timePopover(_ popover: TimePopoverController, didChangeValue seconds: Int) {
        settingsBar.time = seconds
        Settings.time = seconds
    }
    
    func animationsPopover(_ popover: AnimationsPopoverController, didSelectAnimation animation: PhotoAnimation) {
        settingsBar.animation = animation
        Settings.animation = animation
        popover.dismiss(animated: true, completion: nil)
    }
}
