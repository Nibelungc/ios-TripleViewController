//
//  ViewController.swift
//  ios-TripleViewController
//
//  Created by Nikolay on 03/08/2017.
//  Copyright © 2017 Nikolay. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .rewind, target: self, action: #selector(toogleLeftController))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .fastForward, target: self, action: #selector(toogleRightController))
    }
    
    func toogleLeftController() {
        tripleViewController?.toogleContoller(at: .left)
    }
    
    func toogleRightController() {
        tripleViewController?.toogleContoller(at: .right)
    }
}

