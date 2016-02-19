//
//  FilterToolController.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 15/02/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import UIKit

@objc(IMGLYFilterToolController) public class FilterToolController: PhotoEditToolController {

    // MARK: - Properties

    private lazy var filterSelectionController = FilterSelectionController()

    private var sliderContainerView: UIView?
    private var slider: UISlider?

    private var sliderConstraints: [NSLayoutConstraint]?

    // MARK: - UIViewController

    /**
     :nodoc:
     */
    public override func viewDidLoad() {
        super.viewDidLoad()

        toolStackItem.performChanges {
            toolStackItem.mainToolbarView = filterSelectionController.collectionView
            toolStackItem.titleLabel?.text = Localize("FILTER")
            toolStackItem.applyButton?.addTarget(self, action: "apply:", forControlEvents: .TouchUpInside)
            toolStackItem.discardButton?.addTarget(self, action: "discard:", forControlEvents: .TouchUpInside)
        }

        let sliderContainerView = UIView()
        sliderContainerView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        sliderContainerView.translatesAutoresizingMaskIntoConstraints = false
//        sliderContainerView.alpha = activeAdjustTool == nil ? 0 : 1
        view.addSubview(sliderContainerView)
        self.sliderContainerView = sliderContainerView

        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.continuous = true
        slider.setThumbImage(UIImage(named: "slider_knob", inBundle: NSBundle(forClass: AdjustToolController.self), compatibleWithTraitCollection: nil), forState: .Normal)
        sliderContainerView.addSubview(slider)
        slider.addTarget(self, action: "changeValue:", forControlEvents: .ValueChanged)
        self.slider = slider

        view.setNeedsUpdateConstraints()
    }

    public override func updateViewConstraints() {
        super.updateViewConstraints()

        if let sliderContainerView = sliderContainerView, slider = slider where sliderConstraints == nil {
            var constraints = [NSLayoutConstraint]()

            constraints.append(NSLayoutConstraint(item: sliderContainerView, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1, constant: 0))
            constraints.append(NSLayoutConstraint(item: sliderContainerView, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1, constant: 0))
            constraints.append(NSLayoutConstraint(item: sliderContainerView, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: 0))
            constraints.append(NSLayoutConstraint(item: sliderContainerView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 44))

            constraints.append(NSLayoutConstraint(item: slider, attribute: .CenterY, relatedBy: .Equal, toItem: sliderContainerView, attribute: .CenterY, multiplier: 1, constant: 0))
            constraints.append(NSLayoutConstraint(item: slider, attribute: .Left, relatedBy: .Equal, toItem: sliderContainerView, attribute: .Left, multiplier: 1, constant: 20))
            constraints.append(NSLayoutConstraint(item: slider, attribute: .Right, relatedBy: .Equal, toItem: sliderContainerView, attribute: .Right, multiplier: 1, constant: -20))

            NSLayoutConstraint.activateConstraints(constraints)
            sliderConstraints = constraints
        }
    }

    // MARK: - Actions

    @objc private func apply(sender: UIButton) {
        delegate?.photoEditToolControllerDidFinish(self)
    }

    @objc private func discard(sender: UIButton) {
        delegate?.photoEditToolController(self, didDiscardChangesInFavorOfPhotoEditModel: uneditedPhotoEditModel)
    }

}
