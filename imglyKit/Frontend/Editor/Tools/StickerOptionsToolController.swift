//
//  StickerOptionsToolController.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 23/02/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import UIKit

@objc(IMGLYStickerOptionsToolController) public class StickerOptionsToolController: PhotoEditToolController {

    // MARK: - Statics

    private static let IconCaptionCollectionViewCellReuseIdentifier = "IconCaptionCollectionViewCellReuseIdentifier"
    private static let IconCaptionCollectionViewCellSize = CGSize(width: 64, height: 80)
    private static let SeparatorCollectionViewCellReuseIdentifier = "SeparatorCollectionViewCellReuseIdentifier"
    private static let SeparatorCollectionViewCellSize = CGSize(width: 15, height: 80)

    // MARK: - Properties

    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = StickerOptionsToolController.IconCaptionCollectionViewCellSize
        flowLayout.scrollDirection = .Horizontal
        flowLayout.minimumLineSpacing = 8

        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.registerClass(IconCaptionCollectionViewCell.self, forCellWithReuseIdentifier: StickerOptionsToolController.IconCaptionCollectionViewCellReuseIdentifier)
        collectionView.registerClass(SeparatorCollectionViewCell.self, forCellWithReuseIdentifier: StickerOptionsToolController.SeparatorCollectionViewCellReuseIdentifier)
        collectionView.backgroundColor = UIColor.clearColor()
        collectionView.delegate = self
        collectionView.dataSource = self

        return collectionView
    }()

    // MARK: - UIViewController

    /**
     :nodoc:
     */
    public override func viewDidLoad() {
        super.viewDidLoad()

        view.userInteractionEnabled = false

        toolStackItem.performChanges {
            toolStackItem.mainToolbarView = collectionView
            toolStackItem.titleLabel?.text = Localize("STICKER OPTIONS")
            toolStackItem.applyButton?.addTarget(self, action: "apply:", forControlEvents: .TouchUpInside)
            toolStackItem.discardButton = nil
        }
    }

    // MARK: - PhotoEditToolController

    public override var wantsScrollingInDefaultPreviewViewEnabled: Bool {
        return false
    }

    // MARK: - Actions

    @objc private func apply(sender: UIButton) {
        delegate?.photoEditToolControllerDidFinish(self)
    }

}

extension StickerOptionsToolController: UICollectionViewDelegate {
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)

        guard let overlayView = delegate?.photoEditToolControllerSelectedOverlayView(self) as? StickerImageView else {
            return
        }

        if indexPath.item == 0 {
            guard let image = overlayView.image, cgImage = image.CGImage else {
                return
            }

            if let flippedOrientation = UIImageOrientation(rawValue: (image.imageOrientation.rawValue + 4) % 8) {
                overlayView.image = UIImage(CGImage: cgImage, scale: image.scale, orientation: flippedOrientation)
            }
        } else if indexPath.item == 1 {
            guard let image = overlayView.image, cgImage = image.CGImage else {
                return
            }

            if let flippedOrientation = UIImageOrientation(rawValue: (image.imageOrientation.rawValue + 4) % 8) {
                overlayView.image = UIImage(CGImage: cgImage, scale: image.scale, orientation: flippedOrientation)
                overlayView.transform = CGAffineTransformRotate(overlayView.transform, CGFloat(M_PI))
            }
        } else if indexPath.item == 3 {
            overlayView.superview?.bringSubviewToFront(overlayView)
        } else if indexPath.item == 4 {
            overlayView.removeFromSuperview()
            delegate?.photoEditToolControllerDidFinish(self)
        }
    }
}

extension StickerOptionsToolController: UICollectionViewDataSource {
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }

    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if indexPath.item == 2 {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(StickerOptionsToolController.SeparatorCollectionViewCellReuseIdentifier, forIndexPath: indexPath)

            if let separatorCell = cell as? SeparatorCollectionViewCell {
                separatorCell.separator.backgroundColor = UIColor(red: 0.27, green: 0.27, blue: 0.27, alpha: 1)
                //                separatorCell.separator.backgroundColor = options.separatorColor
                // TODO
            }

            return cell
        } else {

        }

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(StickerOptionsToolController.IconCaptionCollectionViewCellReuseIdentifier, forIndexPath: indexPath)

        if let iconCaptionCell = cell as? IconCaptionCollectionViewCell {
            if indexPath.item == 0 {
                iconCaptionCell.imageView.image = UIImage(named: "icon_orientation_flip-h", inBundle: NSBundle(forClass: StickerOptionsToolController.self), compatibleWithTraitCollection: nil)
                iconCaptionCell.captionLabel.text = Localize("Flip H")
            } else if indexPath.item == 1 {
                iconCaptionCell.imageView.image = UIImage(named: "icon_orientation_flip-v", inBundle: NSBundle(forClass: StickerOptionsToolController.self), compatibleWithTraitCollection: nil)
                iconCaptionCell.captionLabel.text = Localize("Flip V")
            } else if indexPath.item == 3 {
                iconCaptionCell.imageView.image = UIImage(named: "icon_bringtofront", inBundle: NSBundle(forClass: StickerOptionsToolController.self), compatibleWithTraitCollection: nil)
                iconCaptionCell.captionLabel.text = Localize("To Front")
            } else if indexPath.item == 4 {
                iconCaptionCell.imageView.image = UIImage(named: "icon_delete", inBundle: NSBundle(forClass: StickerOptionsToolController.self), compatibleWithTraitCollection: nil)
                iconCaptionCell.captionLabel.text = Localize("Delete")
            }
        }

        return cell
    }
}

extension StickerOptionsToolController: UICollectionViewDelegateFlowLayout {
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else {
            return UIEdgeInsetsZero
        }

        let cellCount = collectionView.numberOfItemsInSection(section)
        let cellSpacing = flowLayout.minimumLineSpacing

        var width: CGFloat = 0

        for i in 0..<cellCount {
            let size = self.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAtIndexPath: NSIndexPath(forItem: i, inSection: section))
            width = width + size.width + cellSpacing
        }

        let inset = max((collectionView.bounds.width - width) * 0.5, 0)

        return UIEdgeInsets(top: 0, left: inset, bottom: 0, right: 0)
    }

    /**
     :nodoc:
     */
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if indexPath.item == 2 {
            return StickerOptionsToolController.SeparatorCollectionViewCellSize
        }

        return StickerOptionsToolController.IconCaptionCollectionViewCellSize
    }
}
