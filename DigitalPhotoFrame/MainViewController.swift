//
//  MainViewController.swift
//  DigitalPhotoFrame
//
//  Created by Andrei Marincas on 1/1/18.
//  Copyright © 2018 Andrei Marincas. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    fileprivate var albumsVC: AlbumsViewController!
    
    private var isPreparingPhotosPresentation = false
    private var isTransitioning = false
    private var selectedCell: AlbumCell?
    
    private var currentController: UIViewController? {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        albumsVC = AlbumsViewController(nibName: "AlbumsViewController", bundle: nil)
        albumsVC.delegate = self
        albumsVC.loadViewIfNeeded()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: Notification.Name.UIApplicationDidEnterBackground, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addChildViewController(albumsVC)
        view.addSubview(albumsVC.view)
        albumsVC.view.frame = view.bounds
        self.currentController = albumsVC
        albumsVC.didMove(toParentViewController: self)
    }
    
    func presentPhotosViewController(_ photosVC: PhotosViewController) {
        logIN()
        guard !isTransitioning else { return }
        isTransitioning = true
        addChildViewController(photosVC)
        photosVC.loadViewIfNeeded()
        photosVC.view.alpha = 0
        view.insertSubview(photosVC.view, belowSubview: albumsVC.view)
        photosVC.view.frame = view.bounds
        isPreparingPhotosPresentation = true
        
        selectedCell = albumsVC.collectionView.cellForItem(at: albumsVC.selectedIndexPath!) as? AlbumCell
        albumsVC.collectionView.bringSubview(toFront: albumsVC.effectViewContainer)
        albumsVC.collectionView.bringSubview(toFront: selectedCell!)
        albumsVC.effectViewContainer.isHidden = false
        
        selectedCell?.prepareToUnfold()
        
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 1.8, initialSpringVelocity: 1, options: .curveEaseOut, animations: { [weak self] in
            guard let weakSelf = self else { return }
            weakSelf.albumsVC.effectView.alpha = 1
            weakSelf.selectedCell?.unfold()
            weakSelf.albumsVC.settingsViewTop.constant = -64
            weakSelf.albumsVC.view.layoutIfNeeded()
            weakSelf.currentController = photosVC
        }, completion: { [weak self] finished in
            guard let weakSelf = self else { return }
            weakSelf.isPreparingPhotosPresentation = false
            if photosVC.isReady {
                weakSelf.onPhotosViewControllerIsReady(photosVC)
            }
        })
        logOUT()
    }
    
    func onPhotosViewControllerIsReady(_ photosVC: PhotosViewController) {
        guard !isPreparingPhotosPresentation else { return }
        view.bringSubview(toFront: photosVC.view)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: { [weak self] in
            guard let weakSelf = self else { return }
            photosVC.view.alpha = 1
            weakSelf.albumsVC.view.alpha = 0
        }, completion: { [weak self] finished in
            guard let weakSelf = self else { return }
            weakSelf.albumsVC.effectView.alpha = 0
            weakSelf.albumsVC.effectViewContainer.isHidden = true
            photosVC.didMove(toParentViewController: weakSelf)
            weakSelf.isTransitioning = false
        })
    }
    
    func returnToAlbums(animated: Bool) {
        guard !isTransitioning else { return }
        guard let photosVC = currentController as? PhotosViewController else { return }
        isTransitioning = true
        photosVC.willMove(toParentViewController: nil)
        albumsVC.view.alpha = 1
        UIView.animate(withDuration: animated ? 0.7 : 0, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: { [weak self] in
            guard let weakSelf = self else { return }
            photosVC.view.alpha = 0
            weakSelf.selectedCell?.foldup()
            weakSelf.albumsVC.settingsViewTop.constant = 0
            weakSelf.albumsVC.view.layoutIfNeeded()
            weakSelf.currentController = weakSelf.albumsVC
        }, completion: { [weak self] finished in
            self?.selectedCell?.finalizeFoldup()
            photosVC.view.removeFromSuperview()
            photosVC.removeFromParentViewController()
            self?.isTransitioning = false
        })
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        guard let ctrl = currentController else { return super.preferredStatusBarStyle }
        return ctrl.preferredStatusBarStyle
    }
    
    override var prefersStatusBarHidden: Bool {
        guard let ctrl = currentController else { return super.prefersStatusBarHidden }
        return ctrl.prefersStatusBarHidden
    }
    
    @objc func appMovedToBackground() {
        logIN()
        if let photosVC = currentController as? PhotosViewController {
            photosVC.stopTimer()
            photosVC.view.layer.removeAllAnimations()
            returnToAlbums(animated: false)
        }
        logOUT()
    }
}

extension MainViewController: AlbumsViewControllerDelegate {
    
    func albumsViewController(_ albumsVC: AlbumsViewController, didChangeState newState: AlbumsViewController.State) {
        guard albumsVC == self.albumsVC else { return }
        switch newState {
        case .fetching:
            albumsVC.collectionView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            albumsVC.collectionView.alpha = 0.0
            break
        case .ready:
//            albumsVC.collectionView.collectionViewLayout.invalidateLayout()
            UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 1.8, initialSpringVelocity: 1, options: .curveEaseOut, animations: { [weak self] in
                guard let weakSelf = self else { return }
                weakSelf.albumsVC.collectionView.transform = CGAffineTransform.identity
                weakSelf.albumsVC.collectionView.alpha = 1.0
            }, completion: nil)
            break
        default:
            break
        }
    }
}
