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
    @IBOutlet var activity: UIActivityIndicatorView!
    let scale = CGAffineTransform(scaleX: 1.1, y: 1.1)
    
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
        albumsVC.collectionView.transform = scale
        albumsVC.collectionView.alpha = 0.0
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut, animations: { [weak self] in
            guard let weakSelf = self else { return }
            weakSelf.albumsVC.collectionView.transform = CGAffineTransform.identity
            weakSelf.albumsVC.collectionView.alpha = 1.0
            weakSelf.currentController = weakSelf.albumsVC
        }, completion: { [weak self] finished in
            self?.albumsVC.didMove(toParentViewController: self)
        })
    }
    
    func presentPhotosViewController(_ photosVC: PhotosViewController) {
        addChildViewController(photosVC)
        photosVC.loadViewIfNeeded()
        photosVC.view.alpha = 0
        view.insertSubview(photosVC.view, belowSubview: albumsVC.view)
        photosVC.view.frame = view.bounds
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations: { [weak self] in
            guard let weakSelf = self else { return }
            weakSelf.albumsVC.collectionView.transform = weakSelf.scale
            weakSelf.albumsVC.collectionView.alpha = 0.0
        }, completion: { [weak self] finished in
            guard let weakSelf = self else { return }
            if photosVC.isReady {
                if photosVC != weakSelf.currentController {
                    weakSelf.onPhotosViewControllerIsReady(photosVC)
                }
            } else {
                weakSelf.activity.alpha = 1
                weakSelf.activity.startAnimating()
                weakSelf.view.bringSubview(toFront: weakSelf.activity)
            }
        })
    }
    
    func onPhotosViewControllerIsReady(_ photosVC: PhotosViewController) {
        view.bringSubview(toFront: photosVC.view)
        activity.stopAnimating()
        activity.alpha = 0
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: { [weak self] in
            guard let weakSelf = self else { return }
            photosVC.view.alpha = 1
            weakSelf.albumsVC.view.alpha = 0
            weakSelf.currentController = photosVC
        }, completion: { [weak self] finished in
            guard let weakSelf = self else { return }
            photosVC.didMove(toParentViewController: weakSelf)
        })
    }
    
    func resumePhotosViewController(_ photosVC: PhotosViewController) {
        addChildViewController(photosVC)
        photosVC.view.alpha = 0
        view.insertSubview(photosVC.view, belowSubview: albumsVC.view)
        photosVC.view.frame = view.bounds
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations: { [weak self] in
            guard let weakSelf = self else { return }
            weakSelf.albumsVC.collectionView.transform = weakSelf.scale
            weakSelf.albumsVC.collectionView.alpha = 0.0
            photosVC.view.alpha = 1
            weakSelf.albumsVC.view.alpha = 0
            weakSelf.currentController = photosVC
        }, completion: { [weak self] finished in
            photosVC.didMove(toParentViewController: self)
            photosVC.restartTimer()
            self?.view.bringSubview(toFront: photosVC.view)
        })
    }
    
    func returnToAlbums() {
        guard let photosVC = currentController else { return }
        photosVC.willMove(toParentViewController: nil)
        albumsVC.collectionView.transform = scale
        albumsVC.collectionView.alpha = 0.0
        photosVC.view.alpha = 0
        albumsVC.view.alpha = 1
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations: { [weak self] in
            guard let weakSelf = self else { return }
            weakSelf.albumsVC.collectionView.transform = CGAffineTransform.identity
            weakSelf.albumsVC.collectionView.alpha = 1
            weakSelf.currentController = weakSelf.albumsVC
        }, completion: { finished in
            photosVC.view.removeFromSuperview()
            photosVC.removeFromParentViewController()
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
