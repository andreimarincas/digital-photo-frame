//
//  AppDelegate.swift
//  DigitalPhotoFrame
//
//  Created by Andrei Marincas on 12/27/17.
//  Copyright © 2017 Andrei Marincas. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let bounds = UIScreen.main.bounds
        let window = UIWindow(frame: bounds)
        window.backgroundColor = .black
        
        let vc = MainViewController(nibName: "MainViewController", bundle: nil)
        vc.view.frame = bounds
        window.rootViewController = vc
        
        window.makeKeyAndVisible()
        self.window = window
        
        UIDevice.current.isProximityMonitoringEnabled = true // keep screen alive
        
        return true
    }
}
