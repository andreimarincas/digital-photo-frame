//
//  MainViewController.swift
//  DigitalPhotoFrame
//
//  Created by Andrei Marincas on 1/1/18.
//  Copyright © 2018 Andrei Marincas. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    private var albumsVC: AlbumsViewController!
    
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
        albumsVC.loadViewIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addChildViewController(albumsVC)
        view.addSubview(albumsVC.view)
        albumsVC.view.frame = view.bounds
        albumsVC.collectionView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        albumsVC.collectionView.alpha = 0.0
        albumsVC.settingsViewTop.constant = -64
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(animateAlbums), userInfo: nil, repeats: false)
    }
    
    @objc private func animateAlbums() {
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: { [weak self] in
            guard let weakSelf = self else { return }
            weakSelf.albumsVC.settingsViewTop.constant = 0
            weakSelf.albumsVC.view.layoutIfNeeded()
            weakSelf.albumsVC.collectionView.transform = CGAffineTransform.identity
            weakSelf.albumsVC.collectionView.alpha = 1.0
            weakSelf.currentController = weakSelf.albumsVC
            }, completion: { [weak self] finished in
                self?.albumsVC.didMove(toParentViewController: self)
        })
    }
    
    func presentPhotosViewController(_ photosVC: PhotosViewController) {
        print("main: present photos view controller")
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
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: { [weak self] in
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
    
    func resumePhotosViewController(_ photosVC: PhotosViewController) {
        guard !isTransitioning else { return }
        isTransitioning = true
        addChildViewController(photosVC)
        photosVC.view.alpha = 0
        view.insertSubview(photosVC.view, belowSubview: albumsVC.view)
        photosVC.view.frame = view.bounds
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: { [weak self] in
            guard let weakSelf = self else { return }
            weakSelf.albumsVC.settingsViewTop.constant = -64
            weakSelf.albumsVC.view.layoutIfNeeded()
            photosVC.view.alpha = 1
            weakSelf.albumsVC.view.alpha = 0
            weakSelf.currentController = photosVC
        }, completion: { [weak self] finished in
            photosVC.didMove(toParentViewController: self)
            photosVC.restartTimer()
            self?.view.bringSubview(toFront: photosVC.view)
            self?.isTransitioning = false
        })
    }
    
    func returnToAlbums() {
        guard !isTransitioning else { return }
        isTransitioning = true
        guard let photosVC = currentController as? PhotosViewController else { return }
        photosVC.willMove(toParentViewController: nil)
        albumsVC.view.alpha = 1
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: { [weak self] in
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
}
