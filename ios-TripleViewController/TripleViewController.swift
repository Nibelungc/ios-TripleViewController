//
//  TripleViewController.swift
//  ios-TripleViewController
//
//  Created by Nikolay on 03/08/2017.
//  Copyright © 2017 Nikolay. All rights reserved.
//

import UIKit

class TripleControllerContainer: UIView {}

enum TripleViewControllerPosition {
    case left, right
}

class TripleViewController: UIViewController {
    
    private struct Constants {
        static let countOfContainters = 3
        static let leftControllerLeadingPadding: CGFloat = 0
        static let rightControllerTrailingPadding: CGFloat = 0
    }
    
    // MARK: - Public properties
    
    let rootController: UIViewController
    
    // MARK: - Private properties
    
    private var leftController: UIViewController?
    private var rightController: UIViewController?
    
    private let rootControllerContainer = TripleControllerContainer(frame: .zero)
    private let leftControllerContainer = TripleControllerContainer(frame: .zero)
    private let rightControllerContainer = TripleControllerContainer(frame: .zero)
    
    private var leftControllerContainerLeadingConstraint: NSLayoutConstraint!
    private var rightControllerContainerTrailingConstraint: NSLayoutConstraint!
    
    private var isPortraitOrientation: Bool {
        return UIApplication.shared.statusBarOrientation.isPortrait
    }
    
    // MARK: - Initialization

    init(rootController: UIViewController) {
        precondition(UIDevice.current.userInterfaceIdiom == .pad,
                     "TripleViewController supports only the pad user interface idiom")
        self.rootController = rootController
        super.init(nibName: nil, bundle: nil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Rotation
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        guard !isControllerHidden(at: .left) && !isControllerHidden(at: .right) else { return }
        guard !isPortraitOrientation else { return }
        setController(at: .right, hidden: true)
    }
    
    // MARK: - Public
    
    func controller(at position: TripleViewControllerPosition) -> UIViewController? {
        switch position {
        case .left: return leftController
        case .right: return rightController
        }
    }
    
    func set(controller: UIViewController, at position: TripleViewControllerPosition) {
        guard self.controller(at: position) !== controller else { return }
        self.controller(at: position)?.removeFromParent()
        installController(controller: controller, into: container(forControllerAt: position))
        switch position {
        case .left: leftController = controller
        case .right: rightController = controller
        }
    }
    
    func isControllerHidden(at position: TripleViewControllerPosition) -> Bool {
        switch position {
        case .left: return leftControllerContainerLeadingConstraint.constant > Constants.leftControllerLeadingPadding
        case .right: return rightControllerContainerTrailingConstraint.constant > Constants.rightControllerTrailingPadding
        }
    }
    
    func toogleContoller(at position: TripleViewControllerPosition) {
        let isHidden = isControllerHidden(at: position)
        setController(at: position, hidden: !isHidden)
    }
    
    func setController(at position: TripleViewControllerPosition, hidden: Bool) {
        if isPortraitOrientation {
            switch position {
            case .left: _setController(at: .right, hidden: true)
            case .right: _setController(at: .left, hidden: true)
            }
        }
        _setController(at: position, hidden: hidden)
    }
    
    // MARK: - Private
    
    func _setController(at position: TripleViewControllerPosition, hidden: Bool) {
        assert(controller(at: position) != nil, "Can't show/hide controller, because it doesn't exist")
        guard isControllerHidden(at: position) != hidden else { return }
        
        func updateConstraint(_ constraint: NSLayoutConstraint, withConstant constant: CGFloat) {
            UIView.animate(withDuration: 0.3) {
                constraint.constant = constant
                self.view.layoutIfNeeded()
            }
        }
        switch position {
        case .left:
            let constant: CGFloat = hidden ? self.leftController!.view.bounds.width : Constants.leftControllerLeadingPadding
            updateConstraint(leftControllerContainerLeadingConstraint, withConstant: constant)
        case .right:
            let constant: CGFloat = hidden ? self.rightController!.view.bounds.width : Constants.rightControllerTrailingPadding
            updateConstraint(rightControllerContainerTrailingConstraint, withConstant: constant)
        }
    }
    
    private func container(forControllerAt position: TripleViewControllerPosition) -> TripleControllerContainer {
        switch position {
        case .left: return leftControllerContainer
        case .right: return rightControllerContainer
        }
    }
    
    private func setup() {
        setupContainers()
        installController(controller: rootController, into: rootControllerContainer)
    }
    
    private func installController(controller: UIViewController, into contatiner: TripleControllerContainer) {
        addChildViewController(controller) {
            childView, superView in
            contatiner.addSubview(childView)
            childView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            childView.frame = contatiner.bounds
        }
    }
    
    private func setupContainers() {
        let width = isPortraitOrientation ? view.bounds.height : view.bounds.width
        let sideContainerWidth = (width / CGFloat(Constants.countOfContainters)).rounded()
        let metrics = ["width": sideContainerWidth]
        let views = ["left": leftControllerContainer,
                     "root": rootControllerContainer,
                     "right": rightControllerContainer]
        views.keys.map { views[$0]! }.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        var constraints = [NSLayoutConstraint]()
        
        constraints.append(contentsOf:
            NSLayoutConstraint.constraints(withVisualFormat: "H:[left(==width)]-0-[root]-0-[right(==width)]",
                                           options: .directionLeadingToTrailing,
                                           metrics: metrics,
                                           views: views)
        )
        leftControllerContainerLeadingConstraint = NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal, toItem: leftControllerContainer, attribute: .leading, multiplier: 1.0, constant: Constants.leftControllerLeadingPadding)
        constraints.append(leftControllerContainerLeadingConstraint)
        
        rightControllerContainerTrailingConstraint = NSLayoutConstraint(item: rightControllerContainer, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: sideContainerWidth)
        constraints.append(rightControllerContainerTrailingConstraint)
        
        let verticalConstraints: [NSLayoutConstraint] = views.keys.map {
            return NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[\($0)]-0-|",
                                                  options: .directionLeadingToTrailing,
                                                  metrics: nil,
                                                  views: views)
            }.flatMap { $0 }
        constraints.append(contentsOf: verticalConstraints)
        NSLayoutConstraint.activate(constraints)
    }
}

extension UIViewController {
    
    var tripleViewController: TripleViewController? {
        guard let parent = parent else { return nil }
        if parent is TripleViewController { return parent as? TripleViewController }
        return parent.tripleViewController
    }
}

fileprivate extension UIViewController {
    
    func addChildViewController(_ child: UIViewController, setup: (_ childView: UIView, _ superView: UIView) -> Void) {
        addChildViewController(child)
        setup(child.view, view)
        child.didMove(toParentViewController: self)
    }
    
    func removeFromParent() {
        willMove(toParentViewController: nil)
        view.removeFromSuperview()
        removeFromParentViewController()
    }
}
