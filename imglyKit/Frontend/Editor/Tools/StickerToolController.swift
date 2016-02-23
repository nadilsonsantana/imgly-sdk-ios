//
//  StickerToolController.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 18/02/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import UIKit

@objc(IMGLYStickerToolController) public class StickerToolController: PhotoEditToolController {

    // MARK: - Statics

    private static let IconCollectionViewCellReuseIdentifier = "IconCollectionViewCellReuseIdentifier"
    private static let IconCollectionViewCellSize = CGSize(width: 64, height: 80)

    // MARK: - Properties

    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = StickerToolController.IconCollectionViewCellSize
        flowLayout.scrollDirection = .Horizontal
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        flowLayout.minimumLineSpacing = 8

        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.registerClass(IconCollectionViewCell.self, forCellWithReuseIdentifier: StickerToolController.IconCollectionViewCellReuseIdentifier)
        collectionView.backgroundColor = UIColor.clearColor()
        collectionView.delegate = self
        collectionView.dataSource = self

        return collectionView
    }()

    private var options: StickersEditorViewControllerOptions {
        return configuration.stickersEditorViewControllerOptions
    }

    // MARK: - UIViewController

    /**
    :nodoc:
    */
    public override func viewDidLoad() {
        super.viewDidLoad()

        view.userInteractionEnabled = false

        toolStackItem.performChanges {
            toolStackItem.mainToolbarView = collectionView
            toolStackItem.titleLabel?.text = Localize("STICKER")
            toolStackItem.applyButton?.addTarget(self, action: "apply:", forControlEvents: .TouchUpInside)
            toolStackItem.discardButton = nil
        }
    }

    // MARK: - Actions

    @objc private func apply(sender: UIButton) {
        delegate?.photoEditToolControllerDidFinish(self)
    }

}

extension StickerToolController: UICollectionViewDataSource {
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return options.stickersDataSource.stickerCount
    }

    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(StickerToolController.IconCollectionViewCellReuseIdentifier, forIndexPath: indexPath)

        if let iconCell = cell as? IconCollectionViewCell {
            let sticker = options.stickersDataSource.stickerAtIndex(indexPath.item)
            iconCell.imageView.image = sticker.thumbnail ?? sticker.image

            if let label = sticker.label {
                iconCell.accessibilityLabel = Localize(label)
            }
        }

        return cell
    }
}

extension StickerToolController: UICollectionViewDelegate {
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)

        guard let previewView = delegate?.photoEditToolControllerPreviewView(self) else {
            return
        }

        let sticker = options.stickersDataSource.stickerAtIndex(indexPath.item)
        let imageView = StickerImageView(image: sticker.image)

        // One third of the size of the photo's smaller side should be the size of the sticker's longest side
        let longestStickerSide = min(previewView.bounds.width, previewView.bounds.height) * 0.33
        let stickerSize: CGSize

        if sticker.image.size.width < sticker.image.size.height {
            stickerSize = CGSize(width: longestStickerSide * (sticker.image.size.width / sticker.image.size.height), height: longestStickerSide)
        } else {
            stickerSize = CGSize(width: longestStickerSide, height: longestStickerSide * (sticker.image.size.height / sticker.image.size.width))
        }

        imageView.frame.size = stickerSize
        imageView.center = CGPoint(x: previewView.bounds.midX, y: previewView.bounds.midY)

        if let label = sticker.label {
            imageView.accessibilityLabel = Localize(label)
            options.addedStickerClosure?(label)
        }

        imageView.decrementHandler = { [unowned imageView] in
            // Decrease by 10 %
            imageView.transform = CGAffineTransformScale(imageView.transform, 0.9, 0.9)
            UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil)
        }

        imageView.incrementHandler = { [unowned imageView] in
            // Increase by 10 %
            imageView.transform = CGAffineTransformScale(imageView.transform, 1.1, 1.1)
            UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil)
        }

        imageView.rotateLeftHandler = { [unowned imageView] in
            // Rotate by 10 degrees to the left
            imageView.transform = CGAffineTransformRotate(imageView.transform, -10 * CGFloat(M_PI) / 180)
            UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil)
        }

        imageView.rotateRightHandler = { [unowned imageView] in
            // Rotate by 10 degrees to the right
            imageView.transform = CGAffineTransformRotate(imageView.transform, 10 * CGFloat(M_PI) / 180)
            UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil)
        }

        imageView.transform = CGAffineTransformMakeScale(0, 0)

        previewView.addSubview(imageView)
        imageView.transform = CGAffineTransformMakeScale(0, 0)

        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [], animations: { () -> Void in
            imageView.transform = CGAffineTransformIdentity
        }) { _ in
            self.delegate?.photoEditToolController(self, didAddOverlayView: imageView)

            UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, imageView)
        }
    }
}
