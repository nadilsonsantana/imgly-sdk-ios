//
//  PhotoEditViewController.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 09/02/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import UIKit
import GLKit

@objc(IMGLYPhotoEditViewController) public class PhotoEditViewController: UIViewController {

    // MARK: - Initializers

    let photo: UIImage
    let configuration: Configuration

    convenience public init(photo: UIImage) {
        self.init(photo: photo, configuration: Configuration())
    }

    required public init(photo: UIImage, configuration: Configuration) {
        self.photo = photo
        self.configuration = configuration
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UIViewController

    private var previewViewScrollingContainer: UIScrollView!
    private var mainPreviewView: GLKView!

    public override func viewDidLoad() {
        super.viewDidLoad()

        previewViewScrollingContainer = UIScrollView()
        view.addSubview(previewViewScrollingContainer)
        previewViewScrollingContainer.maximumZoomScale = 0
        previewViewScrollingContainer.minimumZoomScale = 0
        previewViewScrollingContainer.clipsToBounds = false

        automaticallyAdjustsScrollViewInsets = false

        let context = EAGLContext(API: .OpenGLES2)
        mainPreviewView = GLKView(frame: CGRect.zero, context: context)
        mainPreviewView.delegate = self
        previewViewScrollingContainer.addSubview(mainPreviewView)

        view.setNeedsUpdateConstraints()
    }

    public override func updateViewConstraints() {
        super.updateViewConstraints()


    }

    private var previewViewScrollingContainerLayoutValid = false
    private var previewViewScrollingContainerConstraints: [NSLayoutConstraint]?

    private func updatePreviewContainerLayout() {
        if previewViewScrollingContainerLayoutValid {
            return
        }

        if let previewViewScrollingContainerConstraints = previewViewScrollingContainerConstraints {
            NSLayoutConstraint.deactivateConstraints(previewViewScrollingContainerConstraints)
            self.previewViewScrollingContainerConstraints = nil
        }

        previewViewScrollingContainer.translatesAutoresizingMaskIntoConstraints = false

        var constraints = [NSLayoutConstraint]()

        constraints.append(NSLayoutConstraint(item: previewViewScrollingContainer, attribute: .Left, relatedBy: .Equal, toItem: previewViewScrollingContainer.superview, attribute: .Left, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: previewViewScrollingContainer, attribute: .Right, relatedBy: .Equal, toItem: previewViewScrollingContainer.superview, attribute: .Right, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: previewViewScrollingContainer, attribute: .Top, relatedBy: .Equal, toItem: previewViewScrollingContainer.superview, attribute: .Top, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: previewViewScrollingContainer, attribute: .Bottom, relatedBy: .Equal, toItem: previewViewScrollingContainer.superview, attribute: .Bottom, multiplier: 1, constant: 0))

        NSLayoutConstraint.activateConstraints(constraints)
        previewViewScrollingContainerConstraints = constraints
        previewViewScrollingContainerLayoutValid = true
    }
}

extension PhotoEditViewController: GLKViewDelegate {
    public func glkView(view: GLKView, drawInRect rect: CGRect) {

    }
}
