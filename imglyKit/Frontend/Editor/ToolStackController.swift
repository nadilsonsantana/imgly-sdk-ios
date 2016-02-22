//
//  ToolStackController.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 16/02/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import UIKit

@objc(IMGLYToolStackControllerDelegate) public protocol ToolStackControllerDelegate {
    func toolStackController(toolStackController: ToolStackController, didFinishWithImage image: UIImage)
    func toolStackControllerDidCancel(toolStackController: ToolStackController)
}

/**
 *  An instance of `ToolStackController` manages the presentation and dismissal of `PhotoEditToolController` instances
 *  onto an instance of a `PhotoEditViewController`.
 */
@objc(IMGLYToolStackController) public class ToolStackController: UIViewController {

    private struct ToolbarContainer {
        let mainToolbar = UIView()
        let secondaryToolbar = UIView()
    }

    // MARK: - Properties

    private let configuration: Configuration

    public weak var delegate: ToolStackControllerDelegate?

    /// The `PhotoEditViewController` that acts as the root view controller.
    public let photoEditViewController: PhotoEditViewController

    private var photoEditViewControllerConstraints: [NSLayoutConstraint]?
    private var photoEditViewControllerToolbarContainer: ToolbarContainer?
    private var toolbarShadowView: UIView?

    /// The tools that are currently on the stack. The top controller is at index `n-1`, where `n` is the number of items in the array.
    public private(set) var toolControllers = [PhotoEditToolController]()

    private var toolToToolbarContainer = [PhotoEditToolController: ToolbarContainer]()

    private var options: ToolStackControllerOptions {
        return self.configuration.toolStackControllerOptions
    }

    // MARK: - Initializers

    /**
    Initializes and returns a newly created tool stack controller with a default configuration.

    - parameter photoEditViewController: The view controller that acts as the root view controller and handles all rendering.

    - returns: The initialized tool stack controller object.
    */
    public convenience init(photoEditViewController: PhotoEditViewController) {
        self.init(photoEditViewController: photoEditViewController, configuration: Configuration())
    }

    /**
     Initializes and returns a newly created tool stack controller with the given configuration.

     - parameter photoEditViewController: The view controller that acts as the root view controller and handles all rendering.
     - parameter configuration:           The configuration options to apply.

     - returns: The initialized and configured tool stack controller object.
     */
    public init(photoEditViewController: PhotoEditViewController, configuration: Configuration) {
        self.photoEditViewController = photoEditViewController
        self.configuration = configuration
        super.init(nibName: nil, bundle: nil)

        self.photoEditViewController.delegate = self
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "toolStackItemDidChange:", name: ToolStackItemDidChangeNotification, object: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    // MARK: - UIViewController

    /**
     :nodoc:
     */
    override public func viewDidLoad() {
        super.viewDidLoad()

        addChildViewController(photoEditViewController)
        view.addSubview(photoEditViewController.view)
        photoEditViewController.didMoveToParentViewController(self)

        let toolbarContainer = newToolbarContainer()
        view.addSubview(toolbarContainer.mainToolbar)
        view.addSubview(toolbarContainer.secondaryToolbar)
        photoEditViewControllerToolbarContainer = toolbarContainer

        let shadowView = UIView()
        shadowView.backgroundColor = UIColor.blackColor()
        view.addSubview(shadowView)
        toolbarShadowView = shadowView

        updateSubviewsOrdering()

        view.setNeedsUpdateConstraints()
    }

    /**
     :nodoc:
     */
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        let topChildViewController = toolControllers.last ?? photoEditViewController
        topChildViewController.beginAppearanceTransition(true, animated: animated)
    }

    /**
     :nodoc:
     */
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        let topChildViewController = toolControllers.last ?? photoEditViewController
        topChildViewController.endAppearanceTransition()
    }

    /**
     :nodoc:
     */
    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        let topChildViewController = toolControllers.last ?? photoEditViewController
        topChildViewController.beginAppearanceTransition(false, animated: animated)
    }

    /**
     :nodoc:
     */
    public override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)

        let topChildViewController = toolControllers.last ?? photoEditViewController
        topChildViewController.endAppearanceTransition()
    }

    public override func updateViewConstraints() {
        super.updateViewConstraints()

        if let toolbarContainer = photoEditViewControllerToolbarContainer where photoEditViewControllerConstraints == nil {
            photoEditViewController.view.translatesAutoresizingMaskIntoConstraints = false
            toolbarShadowView?.translatesAutoresizingMaskIntoConstraints = false
            toolbarContainer.mainToolbar.translatesAutoresizingMaskIntoConstraints = false
            toolbarContainer.secondaryToolbar.translatesAutoresizingMaskIntoConstraints = false

            var constraints = [NSLayoutConstraint]()

            constraints.append(NSLayoutConstraint(item: photoEditViewController.view, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1, constant: 0))
            constraints.append(NSLayoutConstraint(item: photoEditViewController.view, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1, constant: 0))
            constraints.append(NSLayoutConstraint(item: photoEditViewController.view, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1, constant: 0))
            constraints.append(NSLayoutConstraint(item: photoEditViewController.view, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: 0))

            if let toolbarShadowView = toolbarShadowView {
                constraints.append(NSLayoutConstraint(item: toolbarShadowView, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1, constant: 0))
                constraints.append(NSLayoutConstraint(item: toolbarShadowView, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1, constant: 0))
                constraints.append(NSLayoutConstraint(item: toolbarShadowView, attribute: .Top, relatedBy: .Equal, toItem: toolbarContainer.mainToolbar, attribute: .Top, multiplier: 1, constant: 0))
                constraints.append(NSLayoutConstraint(item: toolbarShadowView, attribute: .Bottom, relatedBy: .Equal, toItem: toolbarContainer.mainToolbar, attribute: .Bottom, multiplier: 1, constant: 0))
            }

            constraints.appendContentsOf(constraintsForToolbarContainer(toolbarContainer))

            NSLayoutConstraint.activateConstraints(constraints)
            photoEditViewControllerConstraints = constraints
        }
    }

    private func constraintsForToolbarContainer(toolbarContainer: ToolbarContainer) -> [NSLayoutConstraint] {
        var constraints = [NSLayoutConstraint]()

        constraints.append(NSLayoutConstraint(item: toolbarContainer.mainToolbar, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: toolbarContainer.mainToolbar, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: toolbarContainer.mainToolbar, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: toolbarContainer.mainToolbar, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 124))

        constraints.append(NSLayoutConstraint(item: toolbarContainer.secondaryToolbar, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: toolbarContainer.secondaryToolbar, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: toolbarContainer.secondaryToolbar, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: toolbarContainer.secondaryToolbar, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 44))

        return constraints
    }

    /**
     :nodoc:
     */
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    public override func childViewControllerForStatusBarHidden() -> UIViewController? {
        return photoEditViewController
    }

    public override func childViewControllerForStatusBarStyle() -> UIViewController? {
        return photoEditViewController
    }

    public override func shouldAutomaticallyForwardAppearanceMethods() -> Bool {
        return false
    }

    /**
     :nodoc:
     */
    public override func shouldAutorotate() -> Bool {
        return false
    }

    /**
     :nodoc:
     */
    public override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return .Portrait
    }

    // MARK: - Notifications

    @objc private func toolStackItemDidChange(notification: NSNotification) {
        if let toolStackItem = notification.object as? ToolStackItem {
            if let toolbarContainer = photoEditViewControllerToolbarContainer where toolStackItem == photoEditViewController.toolStackItem {
                updateToolbarContainer(toolbarContainer, forToolStackItem: toolStackItem)
                return
            }

            if let index = toolControllers.indexOf({ $0.toolStackItem == toolStackItem }), toolbarContainer = toolToToolbarContainer[toolControllers[index]] {
                updateToolbarContainer(toolbarContainer, forToolStackItem: toolStackItem)
                return
            }
        }
    }

    // MARK: - Helpers

    private func newToolbarContainer() -> ToolbarContainer {
        let toolbarContainer = ToolbarContainer()
        toolbarContainer.mainToolbar.backgroundColor = options.mainToolbarBackgroundColor
        toolbarContainer.secondaryToolbar.backgroundColor = options.secondaryToolbarBackgroundColor
        return toolbarContainer
    }

    private func updateToolbarContainer(toolbarContainer: ToolbarContainer, forToolStackItem toolStackItem: ToolStackItem) {
        // Cleanup
        for view in toolbarContainer.mainToolbar.subviews {
            view.removeFromSuperview()
        }

        for view in toolbarContainer.secondaryToolbar.subviews {
            view.removeFromSuperview()
        }

        // Restore
        if let toolbarView = toolStackItem.mainToolbarView {
            toolbarContainer.mainToolbar.addSubview(toolbarView)
            toolbarView.translatesAutoresizingMaskIntoConstraints = false

            var constraints = [NSLayoutConstraint]()

            constraints.append(NSLayoutConstraint(item: toolbarView, attribute: .Left, relatedBy: .Equal, toItem: toolbarContainer.mainToolbar, attribute: .Left, multiplier: 1, constant: 0))
            constraints.append(NSLayoutConstraint(item: toolbarView, attribute: .Top, relatedBy: .Equal, toItem: toolbarContainer.mainToolbar, attribute: .Top, multiplier: 1, constant: 0))
            constraints.append(NSLayoutConstraint(item: toolbarView, attribute: .Right, relatedBy: .Equal, toItem: toolbarContainer.mainToolbar, attribute: .Right, multiplier: 1, constant: 0))
            constraints.append(NSLayoutConstraint(item: toolbarView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 80))

            NSLayoutConstraint.activateConstraints(constraints)
        }

        var constraints = [NSLayoutConstraint]()

        if let discardButton = toolStackItem.discardButton {
            discardButton.translatesAutoresizingMaskIntoConstraints = false
            toolbarContainer.secondaryToolbar.addSubview(discardButton)

            constraints.append(NSLayoutConstraint(item: discardButton, attribute: .Left, relatedBy: .Equal, toItem: toolbarContainer.secondaryToolbar, attribute: .Left, multiplier: 1, constant: 0))
            constraints.append(NSLayoutConstraint(item: discardButton, attribute: .CenterY, relatedBy: .Equal, toItem: toolbarContainer.secondaryToolbar, attribute: .CenterY, multiplier: 1, constant: 0))
        }

        if let applyButton = toolStackItem.applyButton {
            applyButton.translatesAutoresizingMaskIntoConstraints = false
            toolbarContainer.secondaryToolbar.addSubview(applyButton)

            constraints.append(NSLayoutConstraint(item: applyButton, attribute: .Right, relatedBy: .Equal, toItem: toolbarContainer.secondaryToolbar, attribute: .Right, multiplier: 1, constant: 0))
            constraints.append(NSLayoutConstraint(item: applyButton, attribute: .CenterY, relatedBy: .Equal, toItem: toolbarContainer.secondaryToolbar, attribute: .CenterY, multiplier: 1, constant: 0))
        }

        if let titleLabel = toolStackItem.titleLabel {
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            toolbarContainer.secondaryToolbar.addSubview(titleLabel)

            constraints.append(NSLayoutConstraint(item: titleLabel, attribute: .CenterX, relatedBy: .Equal, toItem: toolbarContainer.secondaryToolbar, attribute: .CenterX, multiplier: 1, constant: 0))
            constraints.append(NSLayoutConstraint(item: titleLabel, attribute: .CenterY, relatedBy: .Equal, toItem: toolbarContainer.secondaryToolbar, attribute: .CenterY, multiplier: 1, constant: 0))

            if let discardButton = toolStackItem.discardButton {
                constraints.append(NSLayoutConstraint(item: titleLabel, attribute: .Left, relatedBy: .GreaterThanOrEqual, toItem: discardButton, attribute: .Right, multiplier: 1, constant: 0))
            }

            if let applyButton = toolStackItem.applyButton {
                constraints.append(NSLayoutConstraint(item: applyButton, attribute: .Left, relatedBy: .GreaterThanOrEqual, toItem: titleLabel, attribute: .Right, multiplier: 1, constant: 0))
            }
        }

        NSLayoutConstraint.activateConstraints(constraints)
    }

    private func updateSubviewsOrdering() {
        view.sendSubviewToBack(photoEditViewController.view)

        for toolController in toolControllers {
            view.bringSubviewToFront(toolController.view)
        }

        if let toolbarContainer = photoEditViewControllerToolbarContainer {
            if let toolbarShadowView = toolbarShadowView {
                view.bringSubviewToFront(toolbarShadowView)
            }

            view.bringSubviewToFront(toolbarContainer.mainToolbar)
            view.bringSubviewToFront(toolbarContainer.secondaryToolbar)
        }

        for toolController in toolControllers {
            if let toolbarContainer = toolToToolbarContainer[toolController] {
                view.bringSubviewToFront(toolbarContainer.mainToolbar)
                view.bringSubviewToFront(toolbarContainer.secondaryToolbar)
            }
        }
    }

    // MARK: - Public API

    /**
    Pushes a tool controller onto the receiver's stack and updates the display.

    - parameter toolController:     The tool controller to push onto the stack. If the tool controller is already on the tool stack, this method throws an exception.
    - parameter animated: Specify `true` to animate the transition and `false` if you do not want the transition to be animated
    */
    public func pushToolController(toolController: PhotoEditToolController, animated: Bool) {
        if toolControllers.contains(toolController) {
            fatalError("Trying to push a tool controller that is already on the tool stack.")
        }

        // Tell current top tool controller (or `photoEditViewController` if no tool is pushed)
        // that it is about to disappear
        let topChildViewController = toolControllers.last ?? photoEditViewController
        topChildViewController.beginAppearanceTransition(false, animated: animated)

        // Add child view controller, forward appearance methods and add views
        toolController.willBecomeActiveTool()
        toolControllers.append(toolController)
        addChildViewController(toolController)
        toolController.beginAppearanceTransition(true, animated: animated)
        toolController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toolController.view)

        // Create new toolbar container for new tool controller
        let toolbarContainer = newToolbarContainer()
        toolToToolbarContainer[toolController] = toolbarContainer
        updateToolbarContainer(toolbarContainer, forToolStackItem: toolController.toolStackItem)

        view.addSubview(toolbarContainer.mainToolbar)
        view.addSubview(toolbarContainer.secondaryToolbar)

        updateSubviewsOrdering()

        toolbarContainer.mainToolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbarContainer.secondaryToolbar.translatesAutoresizingMaskIntoConstraints = false

        // Add constraints for new toolbar container
        var constraints = [NSLayoutConstraint]()
        constraints.appendContentsOf(constraintsForToolbarContainer(toolbarContainer))

        constraints.append(NSLayoutConstraint(item: toolController.view, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: toolController.view, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: toolController.view, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: toolController.view, attribute: .Bottom, relatedBy: .Equal, toItem: toolbarShadowView, attribute: .Top, multiplier: 1, constant: 0))

        NSLayoutConstraint.activateConstraints(constraints)

        // Fetch toolbar that's 'behind' the toolbar that's about to be pushed
        let previousToolbarContainer: ToolbarContainer?
        if toolControllers.count > 1 {
            previousToolbarContainer = toolToToolbarContainer[toolControllers[toolControllers.count - 2]]
        } else {
            previousToolbarContainer = photoEditViewControllerToolbarContainer
        }

        // This will be executed regardless of animating the transition or not
        let cleanupClosure = {
            previousToolbarContainer?.mainToolbar.hidden = true
            previousToolbarContainer?.secondaryToolbar.hidden = true
            toolController.didMoveToParentViewController(self)
            toolController.endAppearanceTransition()
            topChildViewController.endAppearanceTransition()
            self.photoEditViewController.updateLastKnownImageSize()
            self.photoEditViewController.updateRenderedPreviewForceRender(false)
            toolController.didBecomeActiveTool()
        }

        if animated {
            // Hide child view
            toolController.view.alpha = 0

            // Move toolbars offscreen
            toolbarContainer.mainToolbar.transform = CGAffineTransformMakeTranslation(0, 124)
            toolbarContainer.secondaryToolbar.transform = CGAffineTransformMakeTranslation(0, 44)

            // Fade out toolbar that's 'behind' the newly pushed toolbar, fade in child view and update layout
            UIView.animateWithDuration(0.28, delay: 0, options: [.CurveEaseInOut], animations: {
                toolController.view.alpha = 1
                previousToolbarContainer?.mainToolbar.alpha = 0.3
                self.photoEditViewController.updateLayoutForNewToolController()
                }) { _ in
                    cleanupClosure()
            }

            // Move main toolbar onscreen
            UIView.animateWithDuration(0.24, delay: 0, options: [.CurveEaseInOut], animations: {
                toolbarContainer.mainToolbar.transform = CGAffineTransformIdentity
                }, completion: nil)

            // Move secondary toolbar onscreen
            UIView.animateWithDuration(0.12, delay: 0.16, options: [.CurveEaseInOut], animations: {
                toolbarContainer.secondaryToolbar.transform = CGAffineTransformIdentity
                }, completion: nil)
        } else {
            photoEditViewController.updateLayoutForNewToolController()
            cleanupClosure()
        }
    }

    /**
     Pops the top tool controller from the tool stack and updates the display.

     - parameter animated: Set this value to `true` to animate the transition. Pass `false` otherwise.
     */
    public func popToolControllerAnimated(animated: Bool) {
        guard let toolController = toolControllers.last, toolbarContainer = toolToToolbarContainer[toolController] else {
            return
        }

        // Fetch toolbar that's 'behind' the toolbar that's about to be popped
        let previousToolbarContainer: ToolbarContainer?
        if toolControllers.count > 1 {
            previousToolbarContainer = toolToToolbarContainer[toolControllers[toolControllers.count - 2]]
        } else {
            previousToolbarContainer = photoEditViewControllerToolbarContainer
        }

        toolToToolbarContainer[toolController] = nil
        toolControllers.removeAtIndex(self.toolControllers.count - 1)

        // Tell tool controller (or `photoEditViewController`) that's 'behind' the view controller that is
        // about to be popped, that it is about to appear
        let topChildViewController = toolControllers.last ?? photoEditViewController
        topChildViewController.beginAppearanceTransition(true, animated: animated)

        // Tell tool controller that will be popped that it is about to disappear
        toolController.willResignActiveTool()
        toolController.willMoveToParentViewController(nil)
        toolController.beginAppearanceTransition(false, animated: animated)

        // Show toolbars that are about to become visible
        previousToolbarContainer?.mainToolbar.hidden = false
        previousToolbarContainer?.secondaryToolbar.hidden = false

        // This will be executed regardless of animating the transition or not
        let cleanupClosure = {
            toolbarContainer.mainToolbar.removeFromSuperview()
            toolbarContainer.secondaryToolbar.removeFromSuperview()
            toolController.view.removeFromSuperview()
            toolController.removeFromParentViewController()
            toolController.endAppearanceTransition()
            topChildViewController.endAppearanceTransition()
            self.photoEditViewController.updateLastKnownImageSize()
            self.photoEditViewController.updateRenderedPreviewForceRender(false)
            toolController.didResignActiveTool()
        }

        if animated {
            // Fade in toolbar that's 'behind' the popped toolbar, fade out child view and update layout
            UIView.animateWithDuration(0.28, delay: 0, options: [.CurveEaseInOut], animations: {
                toolController.view.alpha = 0
                previousToolbarContainer?.mainToolbar.alpha = 1
                self.photoEditViewController.updateLayoutForNewToolController()
                }) { _ in
                    cleanupClosure()
                    toolController.view.alpha = 1
            }

            // Move main toolbar offscreen
            UIView.animateWithDuration(0.24, delay: 0.04, options: [.CurveEaseInOut], animations: {
                toolbarContainer.mainToolbar.transform = CGAffineTransformMakeTranslation(0, 124)
                }, completion: nil)

            // Move secondary toolbar offscreen
            UIView.animateWithDuration(0.12, delay: 0, options: [.CurveEaseInOut], animations: {
                toolbarContainer.secondaryToolbar.transform = CGAffineTransformMakeTranslation(0, 44)
                }, completion: nil)
        } else {
            photoEditViewController.updateLayoutForNewToolController()
            previousToolbarContainer?.mainToolbar.alpha = 1
            cleanupClosure()
        }
    }
}

extension ToolStackController: PhotoEditViewControllerDelegate {
    public func photoEditViewController(photoEditViewController: PhotoEditViewController, didSelectToolController toolController: PhotoEditToolController) {
        pushToolController(toolController, animated: true)
    }

    public func photoEditViewControllerPopToolController(photoEditViewController: PhotoEditViewController) {
        popToolControllerAnimated(true)
    }

    public func photoEditViewControllerCurrentEditingTool(photoEditViewController: PhotoEditViewController) -> PhotoEditToolController? {
        return toolControllers.last
    }

    public func photoEditViewController(photoEditViewController: PhotoEditViewController, didSaveImage image: UIImage) {
        delegate?.toolStackController(self, didFinishWithImage: image)
    }

    public func photoEditViewControllerDidCancel(photoEditviewController: PhotoEditViewController) {
        delegate?.toolStackControllerDidCancel(self)
    }
}
