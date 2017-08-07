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
        root.title = "Root Controller"
        root.view.backgroundColor = .blue
        
        // Create Triple controller
        let triple = TripleViewController(rootController: NavigationController(rootViewController: root))
        triple.view.backgroundColor = .gray
        
        // Create left controller
        let left = BaseViewController()
        left.title = "Left Controller"
        left.view.backgroundColor = UIColor.groupTableViewBackground
        
        // Add left controller to Triple controller
        triple.set(controller: UINavigationController(rootViewController: left), at: .left)
        
        // Create right controller
        let right = BaseViewController()
        right.title = "Right Controller"
        right.view.backgroundColor = .red
        
        // Add right controller to Triple controller
        triple.set(controller: UINavigationController(rootViewController: right), at: .right)
        
        // Setup window with tabbar controller
        let _window = UIWindow(frame: UIScreen.main.bounds)
        let tabController = UITabBarController()
        tabController.viewControllers = [triple]
        _window.rootViewController = tabController
        _window.makeKeyAndVisible()
        window = _window
        
        return true
    }
}

