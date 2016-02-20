//
//  FocusToolController.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 18/02/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import UIKit

@objc(IMGLYFocusToolController) public class FocusToolController: PhotoEditToolController {

    // MARK: - Statics

    private static let IconCaptionCollectionViewCellReuseIdentifier = "IconCaptionCollectionViewCellReuseIdentifier"
    private static let IconCaptionCollectionViewCellSize = CGSize(width: 64, height: 80)

    // MARK: - Properties

    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = FocusToolController.IconCaptionCollectionViewCellSize
        flowLayout.scrollDirection = .Horizontal
        flowLayout.minimumLineSpacing = 8

        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.registerClass(IconCaptionCollectionViewCell.self, forCellWithReuseIdentifier: FocusToolController.IconCaptionCollectionViewCellReuseIdentifier)
        collectionView.backgroundColor = UIColor.clearColor()
        collectionView.delegate = self
        collectionView.dataSource = self

        return collectionView
    }()

    private var activeFocusType: IMGLYFocusType = .Off {
        didSet {
            if oldValue != activeFocusType {
                switch activeFocusType {
                case .Off:
                    UIView.animateWithDuration(0.25, delay: 0, options: [.CurveEaseInOut], animations: {
                        self.circleGradientView?.alpha = 0
                        self.boxGradientView?.alpha = 0
                        }) { _ in
                            self.circleGradientView?.hidden = true
                            self.boxGradientView?.hidden = true
                    }
                case .Linear:
                    boxGradientView?.hidden = false

                    UIView.animateWithDuration(0.25, delay: 0, options: [.CurveEaseInOut], animations: {
                        self.circleGradientView?.alpha = 0
                        self.boxGradientView?.alpha = 1
                        }) { _ in
                            self.circleGradientView?.hidden = true
                    }
                case .Radial:
                    circleGradientView?.hidden = false

                    UIView.animateWithDuration(0.25, delay: 0, options: [.CurveEaseInOut], animations: {
                        self.circleGradientView?.alpha = 1
                        self.boxGradientView?.alpha = 0
                        }) { _ in
                            self.boxGradientView?.hidden = true
                    }
                }
            }
        }
    }

    private var boxGradientView: BoxGradientView?
    private var circleGradientView: CircleGradientView?

    private var gradientViewConstraints: [NSLayoutConstraint]?

    // MARK: - UIViewController

    /**
    :nodoc:
    */
    public override func viewDidLoad() {
        super.viewDidLoad()

        toolStackItem.performChanges {
            toolStackItem.mainToolbarView = collectionView
            toolStackItem.titleLabel?.text = Localize("FOCUS")
            toolStackItem.applyButton?.addTarget(self, action: "apply:", forControlEvents: .TouchUpInside)
            toolStackItem.discardButton?.addTarget(self, action: "discard:", forControlEvents: .TouchUpInside)
        }

        let boxGradientView = BoxGradientView()
        boxGradientView.gradientViewDelegate = self
        boxGradientView.hidden = true
        boxGradientView.alpha = 0
        view.addSubview(boxGradientView)
        self.boxGradientView = boxGradientView

        let circleGradientView = CircleGradientView()
        circleGradientView.gradientViewDelegate = self
        circleGradientView.hidden = true
        circleGradientView.alpha = 0
        view.addSubview(circleGradientView)
        self.circleGradientView = circleGradientView

        switch photoEditModel.focusType {
        case .Off:
            collectionView.selectItemAtIndexPath(NSIndexPath(forItem: IMGLYFocusType.Off.rawValue, inSection: 0), animated: false, scrollPosition: .None)
        case .Linear:
            collectionView.selectItemAtIndexPath(NSIndexPath(forItem: IMGLYFocusType.Linear.rawValue, inSection: 0), animated: false, scrollPosition: .None)
            boxGradientView.hidden = false
            boxGradientView.alpha = 1
            activeFocusType = .Linear
        case .Radial:
            collectionView.selectItemAtIndexPath(NSIndexPath(forItem: IMGLYFocusType.Radial.rawValue, inSection: 0), animated: false, scrollPosition: .None)
            circleGradientView.hidden = false
            circleGradientView.alpha = 1
            activeFocusType = .Radial
        }

        view.setNeedsUpdateConstraints()
    }

    public override func updateViewConstraints() {
        super.updateViewConstraints()

        if let boxGradientView = boxGradientView, circleGradientView = circleGradientView where gradientViewConstraints == nil {
            var constraints = [NSLayoutConstraint]()

            boxGradientView.translatesAutoresizingMaskIntoConstraints = false
            circleGradientView.translatesAutoresizingMaskIntoConstraints = false

            constraints.append(NSLayoutConstraint(item: boxGradientView, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1, constant: 0))
            constraints.append(NSLayoutConstraint(item: boxGradientView, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1, constant: 0))
            constraints.append(NSLayoutConstraint(item: boxGradientView, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1, constant: 0))
            constraints.append(NSLayoutConstraint(item: boxGradientView, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: 0))

            constraints.append(NSLayoutConstraint(item: circleGradientView, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1, constant: 0))
            constraints.append(NSLayoutConstraint(item: circleGradientView, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1, constant: 0))
            constraints.append(NSLayoutConstraint(item: circleGradientView, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1, constant: 0))
            constraints.append(NSLayoutConstraint(item: circleGradientView, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: 0))

            NSLayoutConstraint.activateConstraints(constraints)
            gradientViewConstraints = constraints
        }
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        boxGradientView?.centerGUIElements()
        circleGradientView?.centerGUIElements()
    }

    // MARK: - Actions

    @objc private func apply(sender: UIButton) {
        delegate?.photoEditToolControllerDidFinish(self)
    }

    @objc private func discard(sender: UIButton) {
        delegate?.photoEditToolController(self, didDiscardChangesInFavorOfPhotoEditModel: uneditedPhotoEditModel)
    }

    // MARK: - Helpers

    private func normalizeControlPoint(point: CGPoint) -> CGPoint {
        guard let previewView = delegate?.photoEditToolControllerPreviewView(self) else {
            return point
        }

        if let boxGradientView = boxGradientView where activeFocusType == .Linear {
            let convertedPoint = previewView.convertPoint(point, fromView: boxGradientView)
            return CGPoint(x: convertedPoint.x / previewView.bounds.size.width, y: convertedPoint.y / previewView.bounds.size.height)
        } else if let circleGradientView = circleGradientView where activeFocusType == .Radial {
            let convertedPoint = previewView.convertPoint(point, fromView: circleGradientView)
            return CGPoint(x: convertedPoint.x / previewView.bounds.size.width, y: convertedPoint.y / previewView.bounds.size.height)
        }

        return point
    }

    private func denormalizeControlPoint(point: CGPoint) -> CGPoint {
        guard let previewView = delegate?.photoEditToolControllerPreviewView(self) else {
            return point
        }

        if let boxGradientView = boxGradientView where activeFocusType == .Linear {
            let denormalizedPoint = CGPoint(x: point.x * previewView.bounds.size.width, y: point.y * previewView.bounds.size.height)
            return previewView.convertPoint(denormalizedPoint, toView: boxGradientView)
        } else if let circleGradientView = circleGradientView where activeFocusType == .Radial {
            let denormalizedPoint = CGPoint(x: point.x * previewView.bounds.size.width, y: point.y * previewView.bounds.size.height)
            return previewView.convertPoint(denormalizedPoint, toView: circleGradientView)
        }

        return point
    }

    private func flipNormalizedPointVertically(point: CGPoint) -> CGPoint {
        return CGPoint(x: point.x, y: 1 - point.y)
    }

}

extension FocusToolController: UICollectionViewDelegate {
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if indexPath.item == IMGLYFocusType.Off.rawValue {
            activeFocusType = .Off
            photoEditModel.focusType = .Off
        } else if indexPath.item == IMGLYFocusType.Linear.rawValue {
            activeFocusType = .Linear
            photoEditModel.focusType = .Linear
            photoEditModel.focusNormalizedControlPoint1 = flipNormalizedPointVertically(normalizeControlPoint(boxGradientView?.controlPoint1 ?? CGPoint.zero))
            photoEditModel.focusNormalizedControlPoint2 = flipNormalizedPointVertically(normalizeControlPoint(boxGradientView?.controlPoint2 ?? CGPoint.zero))
        } else if indexPath.item == IMGLYFocusType.Radial.rawValue {
            activeFocusType = .Radial
            photoEditModel.focusType = .Radial
            photoEditModel.focusNormalizedControlPoint1 = flipNormalizedPointVertically(normalizeControlPoint(circleGradientView?.controlPoint1 ?? CGPoint.zero))
            photoEditModel.focusNormalizedControlPoint2 = flipNormalizedPointVertically(normalizeControlPoint(circleGradientView?.controlPoint2 ?? CGPoint.zero))
        }
    }
}

extension FocusToolController: UICollectionViewDataSource {
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }

    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(FocusToolController.IconCaptionCollectionViewCellReuseIdentifier, forIndexPath: indexPath)

        if let iconCaptionCell = cell as? IconCaptionCollectionViewCell {
            if indexPath.item == IMGLYFocusType.Off.rawValue {
                iconCaptionCell.imageView.image = UIImage(named: "icon_focus_off", inBundle: NSBundle(forClass: AdjustToolController.self), compatibleWithTraitCollection: nil)
                iconCaptionCell.captionLabel.text = Localize("No Focus")
            } else if indexPath.item == IMGLYFocusType.Linear.rawValue {
                iconCaptionCell.imageView.image = UIImage(named: "icon_focus_linear", inBundle: NSBundle(forClass: AdjustToolController.self), compatibleWithTraitCollection: nil)
                iconCaptionCell.captionLabel.text = Localize("Linear")
            } else if indexPath.item == IMGLYFocusType.Radial.rawValue {
                iconCaptionCell.imageView.image = UIImage(named: "icon_focus_radial", inBundle: NSBundle(forClass: AdjustToolController.self), compatibleWithTraitCollection: nil)
                iconCaptionCell.captionLabel.text = Localize("Radial")
            }
        }

        return cell
    }
}

extension FocusToolController: UICollectionViewDelegateFlowLayout {
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

extension FocusToolController: GradientViewDelegate {
    public func gradientViewUserInteractionStarted(gradientView: UIView) {
    }

    public func gradientViewUserInteractionEnded(gradientView: UIView) {
    }

    public func gradientViewControlPointChanged(gradientView: UIView) {
        if let gradientView = gradientView as? CircleGradientView where gradientView == circleGradientView {
            photoEditModel.focusNormalizedControlPoint1 = flipNormalizedPointVertically(normalizeControlPoint(gradientView.controlPoint1))
            photoEditModel.focusNormalizedControlPoint2 = flipNormalizedPointVertically(normalizeControlPoint(gradientView.controlPoint2))
        } else if let gradientView = gradientView as? BoxGradientView where gradientView == boxGradientView {
            photoEditModel.focusNormalizedControlPoint1 = flipNormalizedPointVertically(normalizeControlPoint(gradientView.controlPoint1))
            photoEditModel.focusNormalizedControlPoint2 = flipNormalizedPointVertically(normalizeControlPoint(gradientView.controlPoint2))
        }

    }
}
