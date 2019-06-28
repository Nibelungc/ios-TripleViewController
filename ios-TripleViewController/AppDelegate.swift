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
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Create left controller
        let left = BaseViewController()
        left.title = "Left Controller"
        left.view.backgroundColor = UIColor.groupTableViewBackground

        // Create middle controller
        let middle = ViewController()
        middle.title = "Middle Controller"
        middle.view.backgroundColor = .blue
        
        // Create Triple controller
        let triple = TripleViewController(leftController: UINavigationController(rootViewController: left),
                                          middleController: UINavigationController(rootViewController: middle))
        triple.view.backgroundColor = .gray
        
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

