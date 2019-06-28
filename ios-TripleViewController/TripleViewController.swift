//
//  TripleViewController.swift
//  ios-TripleViewController
//
//  Created by Nikolay on 03/08/2017.
//  Copyright © 2017 Nikolay. All rights reserved.
//

import UIKit

@objc protocol TripleViewControllerDelegate: class {
    @objc optional func tripleViewController(_ tripleController: TripleViewController, willChangeMiddleControllerToSize size: CGSize)
    @objc optional func tripleViewController(_ tripleController: TripleViewController, didChangeMiddleControllerToSize size: CGSize)
}

class TripleControllerContainer: UIView {}

enum TripleViewControllerPosition {
    case left, right
    
    static var all: [TripleViewControllerPosition] {
        return [left, right]
    }
}

class TripleViewController: UIViewController {
    
    private struct Constants {
        static let countOfContainters = 3
        static let appearanceAnimationDuration: TimeInterval = 0.5
        static let separatorWidth: CGFloat = 1.0
        static let separatorColor: UIColor = .gray
    }
    
    // MARK: - Public properties
    
    var shouldEndEditingControllerOnHide = true
    private(set) var middleController: UIViewController
    private(set) var leftController: UIViewController?
    private(set) var rightController: UIViewController?
    
    // MARK: - Private properties
    
    weak var delegate: TripleViewControllerDelegate?
    private let leftControllerContainer = TripleControllerContainer(frame: .zero)
    private let middleControllerContainer = TripleControllerContainer(frame: .zero)
    private let rightControllerContainer = TripleControllerContainer(frame: .zero)
    
    private var leftSeparatorView = UIView(frame: .zero)
    private var rightSeparatorView = UIView(frame: .zero)
    
    private var leftControllerContainerLeadingConstraint: NSLayoutConstraint!
    private var rightControllerContainerTrailingConstraint: NSLayoutConstraint!
    
    private var isPortraitOrientation: Bool {
        return UIApplication.shared.statusBarOrientation.isPortrait
    }
    private var sideViewControllers: [UIViewController] {
        return TripleViewControllerPosition.all.map { self.controller(at: $0) }.compactMap { $0 }
    }
    private var allVisibleControllers: [UIViewController] {
        return [middleController] + TripleViewControllerPosition.all
            .filter { !isControllerHidden(at: $0) }
            .compactMap { controller(at: $0) }
    }
    
    // MARK: - Initialization
    
    init(leftController: UIViewController, middleController: UIViewController) {
        precondition(UIDevice.current.userInterfaceIdiom == .pad,
                     "TripleViewController supports only the pad user interface idiom")
        self.leftController = leftController
        self.middleController = middleController
        super.init(nibName: nil, bundle: nil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    
    func controller(at position: TripleViewControllerPosition) -> UIViewController? {
        switch position {
        case .left: return leftController
        case .right: return rightController
        }
    }
    
    func set(controller: UIViewController, at position: TripleViewControllerPosition) {
        installChildController(controller: controller,
                               oldController: self.controller(at: position),
                               into: container(forControllerAt: position))
        if !isControllerHidden(at: position) {
            controller.beginAppearanceTransition(true, animated: false)
        }
        switch position {
        case .left: leftController = controller
        case .right: rightController = controller
        }
        updateOverrideTraitCollection()
        if !isControllerHidden(at: position) {
            controller.endAppearanceTransition()
        }
    }
    
    func set(middleController controller: UIViewController) {
        installChildController(controller: controller,
                               oldController: middleController,
                               into: middleControllerContainer)
        let oldController = middleController
        oldController.beginAppearanceTransition(false, animated: false)
        controller.beginAppearanceTransition(true, animated: false)
        middleController = controller
        updateOverrideTraitCollection()
        oldController.endAppearanceTransition()
        controller.endAppearanceTransition()
    }
    
    func isControllerHidden(at position: TripleViewControllerPosition) -> Bool {
        switch position {
        case .left: return leftControllerContainerLeadingConstraint.constant > 0.0
        case .right: return rightControllerContainerTrailingConstraint.constant > 0.0
        }
    }
    
    func toggleContoller(at position: TripleViewControllerPosition) {
        let isHidden = isControllerHidden(at: position)
        setController(at: position, hidden: !isHidden)
    }
    
    func setController(at position: TripleViewControllerPosition, hidden: Bool) {
        if isPortraitOrientation {
            switch position {
            case .left: setViewController(at: .right, hidden: true)
            case .right: setViewController(at: .left, hidden: true)
            }
        }
        setViewController(at: position, hidden: hidden)
    }
    
    // MARK: - Appearance
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        allVisibleControllers.forEach { $0.beginAppearanceTransition(true, animated: animated) }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        allVisibleControllers.forEach { $0.endAppearanceTransition() }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        allVisibleControllers.forEach { $0.beginAppearanceTransition(false, animated: animated) }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        allVisibleControllers.forEach { $0.endAppearanceTransition() }
    }
    
    override var shouldAutomaticallyForwardAppearanceMethods: Bool {
        return false
    }
    
    override var childForStatusBarStyle: UIViewController? {
        return middleController
    }
    
    // MARK: - Trait Collection and sizing
    
    private func updateOverrideTraitCollection() {
        updateOverrideTraitCollectionForSideControllers()
        updateOverrideTraitCollectionForMiddleController()
    }
    
    private func updateOverrideTraitCollectionForSideControllers() {
        let childHorisontal = UITraitCollection(horizontalSizeClass: .compact)
        let childVertical = UITraitCollection(verticalSizeClass: .regular)
        let childTrait = UITraitCollection(traitsFrom: [childHorisontal, childVertical])
        sideViewControllers.forEach {
            self.setOverrideTraitCollection(childTrait, forChild: $0)
        }
    }
    
    private func updateOverrideTraitCollectionForMiddleController() {
        let middleVertical = UITraitCollection(verticalSizeClass: .regular)
        var middleHorizontal: UIUserInterfaceSizeClass
        if isPortraitOrientation {
            middleHorizontal = isControllerHidden(at: .left) && isControllerHidden(at: .right) ? .regular : .compact
        } else {
            middleHorizontal = !isControllerHidden(at: .left) && !isControllerHidden(at: .right) ? .compact : .regular
        }
        let middleTrait = UITraitCollection(traitsFrom: [UITraitCollection(horizontalSizeClass: middleHorizontal), middleVertical])
        setOverrideTraitCollection(middleTrait, forChild: middleController)
    }
    
    private func sideContainerWidth(for size: CGSize) -> CGFloat {
        let width = max(size.height, size.width)
        return (width / CGFloat(Constants.countOfContainters) - Constants.separatorWidth * 2).rounded()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) {
            _ in
            
            self.updateOverrideTraitCollection()
        }
        if !isControllerHidden(at: .left) && !isControllerHidden(at: .right) && !isPortraitOrientation {
            setController(at: .right, hidden: true)
        }
    }
    
    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        let containerWidth = sideContainerWidth(for: parentSize)
        if container === middleController {
            var size = parentSize
            let leftContainerWidth = isControllerHidden(at: .left) ? 0.0 : containerWidth
            let rightContainerWidth = isControllerHidden(at: .right) ? 0.0 : containerWidth
            let separators = leftSeparatorView.bounds.width + rightSeparatorView.bounds.width
            size.width -= (leftContainerWidth + rightContainerWidth + separators)
            size.height -= bottomLayoutGuide.length
            return size
        }
        if container === leftController || container === rightController {
            return CGSize(width: containerWidth, height: parentSize.height)
        }
        return super.size(forChildContentContainer: container, withParentContainerSize: parentSize)
    }
    
    // MARK: - Private
    
    private func setViewController(at position: TripleViewControllerPosition, hidden: Bool, animated: Bool = true) {
        assert(controller(at: position) != nil, "Can't show/hide controller, because it doesn't exist")
        guard isControllerHidden(at: position) != hidden else { return }
        
        func updateConstraint(_ constraint: NSLayoutConstraint, withConstant constant: CGFloat, completion: @escaping (Bool) -> Void) {
            let duration = animated ? Constants.appearanceAnimationDuration : 0.0
            UIView.animate(withDuration: duration, animations: {
                constraint.constant = constant
                self.view.layoutIfNeeded()
                let newSize = self.size(forChildContentContainer: self.middleController, withParentContainerSize: self.view.bounds.size)
                self.delegate?.tripleViewController?(self, willChangeMiddleControllerToSize: newSize)
            }, completion: {
                isFinished in
                
                self.delegate?.tripleViewController?(self, didChangeMiddleControllerToSize: self.middleController.view.bounds.size)
                completion(isFinished)
            })
        }
        switch position {
        case .left:
            let constant: CGFloat = hidden ? leftController!.view.bounds.width : 0.0
            self.leftController?.beginAppearanceTransition(!hidden, animated: animated)
            if shouldEndEditingControllerOnHide && hidden {
                self.leftController?.view.endEditing(true)
            }
            updateConstraint(leftControllerContainerLeadingConstraint, withConstant: constant) {
                _ in
                
                self.leftController?.endAppearanceTransition()
            }
        case .right:
            self.rightController?.beginAppearanceTransition(!hidden, animated: animated)
            if shouldEndEditingControllerOnHide && hidden {
                self.rightController?.view.endEditing(true)
            }
            let constant: CGFloat = hidden ? rightController!.view.bounds.width : 0.0
            updateConstraint(rightControllerContainerTrailingConstraint, withConstant: constant) {
                _ in
                
                self.rightController?.endAppearanceTransition()
            }
        }
        updateOverrideTraitCollection()
    }
    
    private func container(forControllerAt position: TripleViewControllerPosition) -> TripleControllerContainer {
        switch position {
        case .left: return leftControllerContainer
        case .right: return rightControllerContainer
        }
    }
    
    private func setup() {
        setupContainers()
        setupUI()
        set(middleController: middleController)
        set(controller: leftController!, at: .left)
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        leftSeparatorView.backgroundColor = Constants.separatorColor
        rightSeparatorView.backgroundColor = Constants.separatorColor
    }
    
    private func installChildController(controller: UIViewController,
                                        oldController: UIViewController?,
                                        into contatiner: TripleControllerContainer) {
        if let old = oldController {
            setOverrideTraitCollection(nil, forChild: old)
            old.removeFromParentController()
        }
        addChildViewController(controller) {
            childView, _ in
            
            contatiner.addSubview(childView)
            childView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            childView.frame = contatiner.bounds
        }
    }
    
    private func setupContainers() {
        let sideWidth = sideContainerWidth(for: view.bounds.size)
        let metrics = [
            "width": sideWidth,
            "separatorWidth": Constants.separatorWidth
        ]
        
        var views = [
            "left": leftControllerContainer,
            "root": middleControllerContainer,
            "right": rightControllerContainer,
            "leftSeparator": leftSeparatorView,
            "rightSeparator": rightSeparatorView
        ]
        views.keys.map { views[$0]! }.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        var constraints = [NSLayoutConstraint]()
        
        let horisontalFormat = "H:[left(==width)]-0-[leftSeparator(==separatorWidth)]-0-[root]-0-[rightSeparator(==separatorWidth)]-0-[right(==width)]"
        constraints.append(contentsOf:
            NSLayoutConstraint.constraints(withVisualFormat: horisontalFormat,
                                           options: .directionLeadingToTrailing,
                                           metrics: metrics,
                                           views: views)
        )
        leftControllerContainerLeadingConstraint = NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal, toItem: leftControllerContainer, attribute: .leading, multiplier: 1.0, constant: 0.0)
        constraints.append(leftControllerContainerLeadingConstraint)
        
        rightControllerContainerTrailingConstraint = NSLayoutConstraint(item: rightControllerContainer, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: sideWidth)
        constraints.append(rightControllerContainerTrailingConstraint)
        
        var elements: [String: Any] = views
        elements["bottomLayoutGuide"] = bottomLayoutGuide
        let verticalConstraints: [[NSLayoutConstraint]] = views.keys.map {
            return NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[\($0)]-0-[bottomLayoutGuide]",
                options: .directionLeadingToTrailing,
                metrics: nil,
                views: elements)
        }
        constraints.append(contentsOf: verticalConstraints.flatMap { $0 })
        NSLayoutConstraint.activate(constraints)
    }
}

extension UIViewController {
    
    var tripleViewController: TripleViewController? {
        guard let parent = parent else { return nil }
        if parent is TripleViewController { return parent as? TripleViewController }
        return parent.tripleViewController
    }
    
    func addChildViewController(_ child: UIViewController, setup: (_ childView: UIView, _ superView: UIView) -> Void) {
        addChild(child)
        setup(child.view, view)
        child.didMove(toParent: self)
    }
    
    func removeFromParentController() {
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
}
