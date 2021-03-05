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

protocol AlbumsViewControllerDelegate: class {
    
    func albumsViewController(_ albumsVC: AlbumsViewController, didChangeState newState: AlbumsViewController.State)
}

class AlbumsViewController: UIViewController {
    
    enum State: String {
        case setup
        case fetching
        case ready
        case noPhotos
        case permissionDenied
    }
    
    @IBOutlet var settingsBar: SettingsBar!
    @IBOutlet var settingsViewTop: NSLayoutConstraint!
    @IBOutlet var noPhotosLabel: UILabel!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var separator: UIView!
    @IBOutlet var pageControl: UIPageControl!
    
    private(set) var effectView: UIVisualEffectView!
    private(set) var effectViewContainer: UIView!
    
    fileprivate let cellReuseID = "cellReuseID"
    fileprivate var albums: [Album] = []
    var selectedIndexPath: IndexPath?
    
    weak var delegate: AlbumsViewControllerDelegate?
    
    fileprivate var thumbnailSize: CGSize {
        if Device.IS_IPAD {
            return CGSize(width: 200.0, height: 200.0)
        } else { // iPhone
            return CGSize(width: 120.0, height: 120.0)
        }
    }
    
    fileprivate var collectionViewFrame: CGRect {
        let top: CGFloat = 64
        let viewSize = self.view.frame.size
        return CGRect(x: 0, y: top, width: viewSize.max, height: viewSize.min - top)
    }
    
    private var _collectionView: UICollectionView?
    var collectionView: UICollectionView {
        if _collectionView == nil {
            let pageHorizontalLayout = PageHorizontalLayout()
            _collectionView = UICollectionView(frame: self.collectionViewFrame, collectionViewLayout: pageHorizontalLayout)
            _collectionView?.showsHorizontalScrollIndicator = false
            _collectionView?.showsVerticalScrollIndicator = false
            let nib = UINib(nibName: "AlbumCell", bundle: nil)
            _collectionView?.register(nib, forCellWithReuseIdentifier: cellReuseID)
            _collectionView?.isPagingEnabled = true
            _collectionView?.layer.masksToBounds = false
            _collectionView?.disableDelaysContentTouches()
            _collectionView?.delegate = self
            _collectionView?.dataSource = self
            _collectionView?.backgroundColor = .clear
            self.view.insertSubview(_collectionView!, at: 0)
        }
        return _collectionView!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Color.codGray
        separator.backgroundColor = Color.mineShaftLight
        
        initializeSettingsBar()
        createBlurEffectView()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground),
                                       name: Notification.Name.UIApplicationDidEnterBackground, object: nil)
        
        handleAuthorization()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateUI()
    }
    
    @objc func appMovedToBackground() {
        logIN()
        if let presentedVC = self.presentedViewController {
            if presentedVC is TimePopoverController || presentedVC is AnimationsPopoverController {
                presentedVC.dismiss(animated: false, completion: nil)
            }
        }
        logOUT()
    }
    
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
        self.collectionView.addSubview(effectViewContainer)
        self.effectView = effectView
        self.effectViewContainer = effectViewContainer
    }
    
    private func initializeSettingsBar() {
        settingsBar.time = Settings.time
        settingsBar.animation = Settings.animation
        settingsBar.isRandom = Settings.isRandom
        settingsBar.delegate = self
        settingsBar.backgroundColor = Color.mineShaft
    }
    
    private func updateUI() {
        self.collectionView.frame = self.collectionViewFrame
        let contentRect = CGRect(origin: .zero, size: self.collectionView.contentSize)
        effectViewContainer.frame = contentRect.insetBy(dx: 0, dy: -64)
        effectView.frame = effectViewContainer.bounds
    }
    
    private func handleAuthorization() {
        logIN()
        let auth = PHPhotoLibrary.authorizationStatus()
        logDebug("Authorization status: \(auth.rawValue)")
        switch auth {
        case .authorized:
            state = .fetching
            break
        case .denied, .restricted:
            state = .permissionDenied
            break
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({ (auth) in
                DispatchQueue.main.async { [weak self] in
                    guard let weakSelf = self else { return }
                    logDebug("auth: \(auth.rawValue)")
                    switch auth {
                    case .authorized:
                        weakSelf.state = .fetching
                        break
                    case .denied, .restricted:
                        weakSelf.state = .permissionDenied
                        break
                    default:
                        break
                    }
                }
            })
            break
        }
        logOUT()
    }
    
    private func fetchAlbums() {
        logIN()
        PHPhotoLibrary.authorizationStatus()
        let fetchOptions = PHFetchOptions()
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: fetchOptions)
        let topLevelfetchOptions = PHFetchOptions()
        let topLevelUserCollections = PHCollectionList.fetchTopLevelUserCollections(with: topLevelfetchOptions)
        let allAlbums = [topLevelUserCollections, smartAlbums]
        var userLibrary: Album?
        var recentlyAdded: Album?
        var albums = [Album]()
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
                            albums.append(obj)
                        }
                    }
                }
                if i == (allAlbums.count - 1) && index == (result.count - 1) {
                    albums.sort(by: { (a, b) -> Bool in
                        return a.title < b.title
                    })
                    if let recentlyAdded = recentlyAdded {
                        albums.insert(recentlyAdded, at: 0)
                    }
                    if let userLibrary = userLibrary {
                        albums.insert(userLibrary, at: 0)
                    }
                    DispatchQueue.main.async { [weak self] in
                        self?.didFetchAlbums(albums)
                    }
                }
            })
        }
        logOUT()
    }
    
    private func didFetchAlbums(_ albums: [Album]) {
        logIN()
        self.printAlbums(albums)
        self.albums = albums
        logDebug("Reload albums collection view.")
        self.collectionView.reloadData()
        pageControl.numberOfPages = (self.collectionView.collectionViewLayout as! PageHorizontalLayout).pageCount
        if self.albums.count == 0 {
            self.state = .noPhotos
        }
        logOUT()
    }
    
    fileprivate var isReady: Bool {
        for indexPath in collectionView.indexPathsForVisibleItems {
            let cell = collectionView.cellForItem(at: indexPath) as! AlbumCell
            var imgCount = 0
            for i in 0..<3 {
                let imageView = cell.imageView(at: i)!
                if let _ = imageView.image, !imageView.isHidden {
                    imgCount += 1
                }
            }
            let album = albums[indexPath.row]
            if (album.photos.count < 3 && imgCount < album.photos.count) || (album.photos.count >= 3 && imgCount < 3) {
                return false
            }
        }
        return true
    }
    
    private var _state: State = .setup
    var state: State {
        get {
            return _state
        }
        set (newState) {
            guard newState != _state else { return }
            logDebug("Change state from '\(_state)' to '\(newState)'.")
            let oldState = _state
            _state = newState
            switch newState {
            case .fetching:
                assert(oldState == .setup)
                collectionView.isHidden = false
                noPhotosLabel.isHidden = true
                pageControl.numberOfPages = 0
                activityIndicator.alpha = 1
                activityIndicator.startAnimating()
                fetchAlbums()
                break
            case .ready:
                assert(oldState == .fetching)
                self.collectionView.collectionViewLayout.invalidateLayout()
                activityIndicator.stopAnimating()
                activityIndicator.alpha = 0
                break
            case .noPhotos:
                assert(oldState == .fetching)
                collectionView.isHidden = true
                noPhotosLabel.isHidden = false
                activityIndicator.stopAnimating()
                activityIndicator.alpha = 0
                break
            case .permissionDenied:
                assert(oldState == .setup)
                collectionView.isHidden = true
                noPhotosLabel.isHidden = false
                activityIndicator.stopAnimating()
                activityIndicator.alpha = 0
                break
            default:
                break
            }
            delegate?.albumsViewController(self, didChangeState: newState)
        }
    }
    
    private func printAlbums(_ albums: [Album]) {
        for a in albums {
            logDebug("\(a.title), \(a.photos.count) photos")
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func changePage(_ sender: Any) {
        var frame: CGRect = self.collectionView.frame
        frame.origin = CGPoint(x: self.collectionView.frame.size.width * CGFloat(self.pageControl.currentPage), y: 0)
        self.collectionView.scrollRectToVisible(frame, animated: true)
    }
}

extension AlbumsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.albums.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        logDebug("Request cell for item at index path: \(indexPath.row)")
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
                logDebug("Request image '\(idx)' (\(album.photos.count) photos) for album '\(album.title)'")
                DispatchQueue.global().async {
                    PHImageManager.default().requestImage(for: asset, targetSize: self.thumbnailSize, contentMode: PHImageContentMode.aspectFit, options: requestOptions, resultHandler: { (pickedImage, info) in
                        logDebug("Did pick image '\(idx)' (\(album.photos.count) photos) for album '\(album.title)'")
                        if let img = pickedImage {
                            print("")
                            if cell.titleLabel.text == album.title {
                                DispatchQueue.main.async { [weak self] in
                                    guard let weakSelf = self else { return }
                                    if album.photos.count == 1 {
                                        cell.middleImageView.image = img
                                        cell.middleImageView.isHidden = false
                                        cell.frontImageView.isHidden = true
                                    } else {
                                        cell.imageView(at: 2 - i)!.image = img
                                    }
                                    if weakSelf.state == .fetching && weakSelf.isReady {
                                        weakSelf.state = .ready
                                    }
                                }
                            } else {
                                logDebug("Album changed for this cell, do nothing.")
                            }
                        } else {
                            logError("Couldn't load image!")
                            // TODO: Load dummy image instead
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
        self.selectedIndexPath = indexPath
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
    }
}

extension AlbumsViewController: SettingsBarDelegate, TimePopoverDelegate, AnimationsPopoverDelegate {
    
    func settingsBar(_ bar: SettingsBar, didSelectTime value: Int) {
        let vc = TimePopoverController(seconds: value)
        vc.delegate = self
        vc.modalPresentationStyle = .popover
        vc.preferredContentSize = CGSize(width: 160, height: 200)
        
        let popover = vc.popoverPresentationController
        popover?.backgroundColor = vc.view.backgroundColor
        popover?.permittedArrowDirections = .up
        popover?.sourceView = settingsBar
        popover?.sourceRect = settingsBar.timeButton.frame.insetBy(dx: 0, dy: -15)
        
        present(vc, animated: true, completion: nil)
    }
    
    func settingsBar(_ bar: SettingsBar, didSelectAnimation value: PhotoAnimation) {
        let vc = AnimationsPopoverController(animation: value)
        vc.delegate = self
        vc.modalPresentationStyle = .popover
        vc.loadViewIfNeeded()
        vc.preferredContentSize = CGSize(width: 160, height: 274)
        
        let popover = vc.popoverPresentationController
        popover?.backgroundColor = vc.view.backgroundColor
        popover?.permittedArrowDirections = .up
        popover?.sourceView = settingsBar
        popover?.sourceRect = settingsBar.animationButton.frame.insetBy(dx: 0, dy: -15)
        
        present(vc, animated: true, completion: nil)
    }
    
    func settingsBar(_ bar: SettingsBar, didChangeIsRandom value: Bool) {
        Settings.isRandom = value
    }
    
    func timePopover(_ popover: TimePopoverController, didChangeValue seconds: Int) {
        settingsBar.time = seconds
        Settings.time = seconds
    }
    
    func animationsPopover(_ popover: AnimationsPopoverController, didSelectAnimation animation: PhotoAnimation) {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1.5, initialSpringVelocity: 1, options: .curveEaseOut, animations: { [weak self] in
            self?.settingsBar.animation = animation
        }, completion: nil)
        Settings.animation = animation
        popover.dismiss(animated: true, completion: nil)
    }
}

extension AlbumsViewController: CollectionViewLayoutDelegate {
    
    var preferredCollectionViewFrame: CGRect {
        return self.collectionViewFrame
    }
}

extension AlbumsViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var pageIndex: Int = 0
        let offset: CGFloat = scrollView.contentOffset.x / scrollView.frame.size.width
        
        if CGFloat(pageControl.currentPage) <= offset {
            pageIndex = lroundf(floorf(Float(offset)))
        } else {
            pageIndex = lroundf(ceilf(Float(offset)))
        }
        self.pageControl.currentPage = pageIndex
    }
}
