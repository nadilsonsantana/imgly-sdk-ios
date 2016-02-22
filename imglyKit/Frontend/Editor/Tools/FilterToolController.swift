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

    private var filterSelectionController: FilterSelectionController?

    private var sliderContainerView: UIView?
    private var slider: UISlider?

    private var sliderConstraints: [NSLayoutConstraint]?
    private var didPerformInitialScrollToReveal = false

    // MARK: - UIViewController

    /**
     :nodoc:
     */
    public override func viewDidLoad() {
        super.viewDidLoad()

        filterSelectionController = FilterSelectionController(inputImage: delegate?.photoEditToolControllerBaseImage(self))
        filterSelectionController?.activePhotoEffectBlock = { [weak self] in
            guard let strongSelf = self else {
                return nil
            }

            return PhotoEffect.effectWithIdentifier(strongSelf.photoEditModel.effectFilterIdentifier) ?? PhotoEffect.effectWithIdentifier("None")
        }

        filterSelectionController?.selectedBlock = { [weak self] photoEffect in
            guard let strongSelf = self else {
                return
            }

            if photoEffect.identifier == "None" {
                UIView.animateWithDuration(0.25, delay: 0, options: [.CurveEaseInOut], animations: {
                    strongSelf.sliderContainerView?.alpha = 0
                    }, completion: nil)
            } else {
                UIView.animateWithDuration(0.25, delay: 0, options: [.CurveEaseInOut], animations: {
                    strongSelf.sliderContainerView?.alpha = 1
                    }, completion: nil)
            }

            strongSelf.photoEditModel.performChangesWithBlock {
                strongSelf.photoEditModel.effectFilterIntensity = 0.75 // TODO: Options
                strongSelf.photoEditModel.effectFilterIdentifier = photoEffect.identifier
            }

            strongSelf.slider?.value = 0.75 // TODO: Options
        }

        toolStackItem.performChanges {
            toolStackItem.mainToolbarView = filterSelectionController?.collectionView
            toolStackItem.titleLabel?.text = Localize("FILTER")
            toolStackItem.applyButton?.addTarget(self, action: "apply:", forControlEvents: .TouchUpInside)
            toolStackItem.discardButton?.addTarget(self, action: "discard:", forControlEvents: .TouchUpInside)
        }

        let photoEffect = PhotoEffect.effectWithIdentifier(photoEditModel.effectFilterIdentifier)

        let sliderContainerView = UIView()
        sliderContainerView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        sliderContainerView.translatesAutoresizingMaskIntoConstraints = false
        sliderContainerView.alpha = photoEffect?.identifier == "None" ? 0 : 1
        view.addSubview(sliderContainerView)
        self.sliderContainerView = sliderContainerView

        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.value = Float(photoEditModel.effectFilterIntensity)
        slider.continuous = true
        slider.setThumbImage(UIImage(named: "slider_knob", inBundle: NSBundle(forClass: AdjustToolController.self), compatibleWithTraitCollection: nil), forState: .Normal)
        sliderContainerView.addSubview(slider)
        slider.addTarget(self, action: "changeValue:", forControlEvents: .ValueChanged)
        self.slider = slider

        view.setNeedsUpdateConstraints()
    }

    /**
    :nodoc:
    */
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        if let photoEffect = PhotoEffect.effectWithIdentifier(photoEditModel.effectFilterIdentifier), index = PhotoEffect.allEffects.indexOf(photoEffect) where !didPerformInitialScrollToReveal {
            filterSelectionController?.collectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: index, inSection: 0), atScrollPosition: .CenteredHorizontally, animated: animated)
            didPerformInitialScrollToReveal = true
        }
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

    // MARK: - PhotoEditToolController

    /**
    :nodoc:
    */
    public override func photoEditModelDidChange(notification: NSNotification) {
        super.photoEditModelDidChange(notification)

        if let selectedIndexPath = filterSelectionController?.collectionView.indexPathsForSelectedItems()?.first {
            if photoEditModel.effectFilterIdentifier != PhotoEffect.allEffects[selectedIndexPath.item].identifier {
                filterSelectionController?.updateSelectionAnimated(true)
            }
        } else {
            filterSelectionController?.updateSelectionAnimated(true)
        }
    }

    // MARK: - Actions

    @objc private func changeValue(sender: UISlider) {
        photoEditModel.performChangesWithBlock {
            self.photoEditModel.effectFilterIntensity = CGFloat(sender.value)
        }
    }

    @objc private func apply(sender: UIButton) {
        delegate?.photoEditToolControllerDidFinish(self)
    }

    @objc private func discard(sender: UIButton) {
        delegate?.photoEditToolController(self, didDiscardChangesInFavorOfPhotoEditModel: uneditedPhotoEditModel)
    }

}
