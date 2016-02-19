//
//  AdjustToolController.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 18/02/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import UIKit

@objc(IMGLYAdjustToolController) public class AdjustToolController: PhotoEditToolController {

    // MARK: - Private Enums

    private enum AdjustTool: Int {
        case Brightness
        case Contrast
        case Saturation
    }

    // MARK: - Statics

    private static let IconCaptionCollectionViewCellReuseIdentifier = "IconCaptionCollectionViewCellReuseIdentifier"
    private static let IconCaptionCollectionViewCellSize = CGSize(width: 64, height: 80)

    // MARK: - Properties

    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = AdjustToolController.IconCaptionCollectionViewCellSize
        flowLayout.scrollDirection = .Horizontal
        flowLayout.minimumLineSpacing = 8

        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.registerClass(IconCaptionCollectionViewCell.self, forCellWithReuseIdentifier: AdjustToolController.IconCaptionCollectionViewCellReuseIdentifier)
        collectionView.backgroundColor = UIColor.clearColor()
        collectionView.delegate = self
        collectionView.dataSource = self

        return collectionView
    }()

    private var activeAdjustTool: AdjustTool? {
        didSet {
            if oldValue == nil || activeAdjustTool == nil {
                UIView.animateWithDuration(0.25, delay: 0, options: [.CurveEaseInOut], animations: {
                    self.sliderContainerView?.alpha = 1
                    }, completion: nil)
            } else if activeAdjustTool == nil {
                UIView.animateWithDuration(0.25, delay: 0, options: [.CurveEaseInOut], animations: {
                    self.sliderContainerView?.alpha = 0
                    }, completion: nil)
            }
        }
    }

    private var sliderContainerView: UIView?
    private var slider: UISlider?

    private var sliderConstraints: [NSLayoutConstraint]?

    // MARK: - Actions

    @objc private func changeValue(sender: UISlider) {
        guard let activeAdjustTool = activeAdjustTool else {
            return
        }

        switch activeAdjustTool {
        case .Brightness:
            photoEditModel.performChangesWithBlock {
                self.photoEditModel.brightness = CGFloat(sender.value)
            }
        case .Contrast:
            photoEditModel.performChangesWithBlock {
                self.photoEditModel.contrast = CGFloat(sender.value)
            }
        case .Saturation:
            photoEditModel.performChangesWithBlock {
                self.photoEditModel.saturation = CGFloat(sender.value)
            }
        }
    }

    // MARK: - UIViewController

    /**
    :nodoc:
    */
    public override func viewDidLoad() {
        super.viewDidLoad()

        toolStackItem.performChanges {
            toolStackItem.mainToolbarView = collectionView
            toolStackItem.titleLabel?.text = Localize("ADJUST")
            toolStackItem.applyButton?.addTarget(self, action: "apply:", forControlEvents: .TouchUpInside)
            toolStackItem.discardButton?.addTarget(self, action: "discard:", forControlEvents: .TouchUpInside)
        }

        let sliderContainerView = UIView()
        sliderContainerView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        sliderContainerView.translatesAutoresizingMaskIntoConstraints = false
        sliderContainerView.alpha = activeAdjustTool == nil ? 0 : 1
        view.addSubview(sliderContainerView)
        self.sliderContainerView = sliderContainerView

        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
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

extension AdjustToolController: UICollectionViewDelegate {
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if indexPath.item == AdjustTool.Brightness.rawValue {
            activeAdjustTool = .Brightness
            slider?.minimumValue = -1
            slider?.maximumValue = 1
            slider?.value = Float(photoEditModel.brightness)
        } else if indexPath.item == AdjustTool.Contrast.rawValue {
            activeAdjustTool = .Contrast
            slider?.minimumValue = 0
            slider?.maximumValue = 2
            slider?.value = Float(photoEditModel.contrast)
        } else if indexPath.item == AdjustTool.Saturation.rawValue {
            activeAdjustTool = .Saturation
            slider?.minimumValue = 0
            slider?.maximumValue = 2
            slider?.value = Float(photoEditModel.saturation)
        }
    }
}

extension AdjustToolController: UICollectionViewDataSource {
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }

    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(AdjustToolController.IconCaptionCollectionViewCellReuseIdentifier, forIndexPath: indexPath)

        if let iconCaptionCell = cell as? IconCaptionCollectionViewCell {
            if indexPath.item == AdjustTool.Brightness.rawValue {
                iconCaptionCell.imageView.image = UIImage(named: "icon_option_brightness", inBundle: NSBundle(forClass: AdjustToolController.self), compatibleWithTraitCollection: nil)
                iconCaptionCell.captionLabel.text = Localize("Brightness")
            } else if indexPath.item == AdjustTool.Contrast.rawValue {
                iconCaptionCell.imageView.image = UIImage(named: "icon_option_contrast", inBundle: NSBundle(forClass: AdjustToolController.self), compatibleWithTraitCollection: nil)
                iconCaptionCell.captionLabel.text = Localize("Contrast")
            } else if indexPath.item == AdjustTool.Saturation.rawValue {
                iconCaptionCell.imageView.image = UIImage(named: "icon_option_saturation", inBundle: NSBundle(forClass: AdjustToolController.self), compatibleWithTraitCollection: nil)
                iconCaptionCell.captionLabel.text = Localize("Saturation")
            }
        }

        return cell
    }
}

extension AdjustToolController: UICollectionViewDelegateFlowLayout {
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else {
            return UIEdgeInsetsZero
        }

        let cellSpacing = flowLayout.minimumLineSpacing
        let cellWidth = flowLayout.itemSize.width
        let cellCount = collectionView.numberOfItemsInSection(section)
        let inset = max((collectionView.bounds.width - (CGFloat(cellCount) * (cellWidth + cellSpacing))) * 0.5, 0)

        return UIEdgeInsets(top: 0, left: inset, bottom: 0, right: 0)
    }
}
