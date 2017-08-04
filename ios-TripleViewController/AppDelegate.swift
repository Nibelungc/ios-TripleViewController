//
//  AppDelegate.swift
//  ios-TripleViewController
//
//  Created by Nikolay on 03/08/2017.
//  Copyright © 2017 Nikolay. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Create required root controller, in the middle
        let root = ViewController()
        root.view.backgroundColor = .blue
        root.title = "Root Controller"
        
        // Create Triple controller
        let Triple = TripleViewController(rootController: UINavigationController(rootViewController: root))
        Triple.view.backgroundColor = .gray
        
        // Create left controller
        let left = UIViewController()
        left.view.backgroundColor = UIColor.groupTableViewBackground
        left.title = "Left Controller"
        
        // Add left controller to Triple controller
        Triple.set(controller: UINavigationController(rootViewController: left), at: .left)
        
        // Create right controller
        let right = UIViewController()
        right.view.backgroundColor = .red
        right.title = "Right Controller"
        
        // Add right controller to Triple controller
        Triple.set(controller: UINavigationController(rootViewController: right), at: .right)
        
        // Setup window with tabbar controller
        let _window = UIWindow(frame: UIScreen.main.bounds)
        let tabController = UITabBarController()
        tabController.viewControllers = [Triple]
        _window.rootViewController = tabController
        _window.makeKeyAndVisible()
        window = _window
        
        return true
    }
}

