//
//  ViewController.swift
//  ios-TripleViewController
//
//  Created by Nikolay on 03/08/2017.
//  Copyright © 2017 Nikolay. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {
    
    override var childForStatusBarStyle: UIViewController? {
        return children.first
    }
}

class Logger {
    
    func log(_ message: String) {
        print(message)
    }
}

class BaseViewController: UIViewController {

    var label: UILabel!
    var appearanceLogger: Logger? = Logger()
    var traitAndSizeLogger: Logger?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appearanceLogger?.log("\(String(describing: title)) - " + #function)
        
        label = UILabel(frame: .zero)
        label.textColor = .gray
        label.shadowColor = .black
        view.addSubview(label)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        label.center = view.center
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        traitAndSizeLogger?.log("\(title!): traitCollectionDidChange previousTraitCollection: \(previousTraitCollection?.shortDescription ?? "nil")")
        label.text = traitCollection.shortDescription
        label.sizeToFit()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appearanceLogger?.log("\(String(describing: title)) - " + #function)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        appearanceLogger?.log("\(String(describing: title)) - " + #function)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        appearanceLogger?.log("\(String(describing: title)) - " + #function)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        appearanceLogger?.log("\(String(describing: title)) - " + #function)
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        traitAndSizeLogger?.log("\(title!): viewWillTransition to newCollection: \(newCollection.shortDescription)")
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        traitAndSizeLogger?.log("\(title!): viewWillTransition toSize: \(size)")
    }
}

class ViewController: BaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .rewind, target: self, action: #selector(toogleLeftController))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .fastForward, target: self, action: #selector(toogleRightController))
    }
    
    @objc func toogleLeftController() {
        tripleViewController?.toggleContoller(at: .left)
    }
    
    @objc func toogleRightController() {
        tripleViewController?.toggleContoller(at: .right)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

extension UIUserInterfaceSizeClass {
    
    var symbol: String {
        switch self {
        case .compact: return "C"
        case .regular: return "R"
        default: return "U"
        }
    }
}

extension UITraitCollection {
    
    var shortDescription: String {
        return "h: \(horizontalSizeClass.symbol)" + " v: \(horizontalSizeClass.symbol)"
    }
}

