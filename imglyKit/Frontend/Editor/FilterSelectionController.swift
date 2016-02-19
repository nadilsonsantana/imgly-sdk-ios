//
//  FilterSelectionController.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 08/04/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

public typealias PhotoEffectSelectedBlock = (PhotoEffect) -> (Void)
public typealias PhotoEffectActiveBlock = () -> (PhotoEffect?)

@objc(IMGLYFilterSelectionController) public class FilterSelectionController: NSObject {

    // MARK: - Statics

    private static let FilterCollectionViewCellReuseIdentifier = "FilterCollectionViewCell"
    private static let FilterCollectionViewCellSize = CGSize(width: 64, height: 80)
    private static let FilterActivationDuration = NSTimeInterval(0.15)

    private var thumbnails = [Int: UIImage]()

    // MARK: - Properties

    public let collectionView: UICollectionView
    public var selectedBlock: PhotoEffectSelectedBlock?
    public var activePhotoEffectBlock: PhotoEffectActiveBlock?

    private var photoEffectThumbnailRenderer: PhotoEffectThumbnailRenderer?

    // MARK: - Initializers

    public convenience override init() {
        self.init(inputImage: nil)
    }

    public init(inputImage: UIImage?) {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = FilterSelectionController.FilterCollectionViewCellSize
        flowLayout.scrollDirection = .Horizontal
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        flowLayout.minimumInteritemSpacing = 7
        flowLayout.minimumLineSpacing = 7

        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        super.init()

        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.registerClass(FilterCollectionViewCell.self, forCellWithReuseIdentifier: FilterSelectionController.FilterCollectionViewCellReuseIdentifier)
        collectionView.backgroundColor = UIColor.clearColor()
        collectionView.delegate = self
        collectionView.dataSource = self

        let renderer = PhotoEffectThumbnailRenderer(inputImage: inputImage ?? UIImage(named: "nonePreview", inBundle: NSBundle(forClass: FilterSelectionController.self), compatibleWithTraitCollection: nil)!)
        renderer.generateThumbnailsForPhotoEffects(PhotoEffect.allEffects, ofSize: CGSize(width: 64, height: 64)) { thumbnail, index in
            dispatch_async(dispatch_get_main_queue()) {
                self.saveThumbnail(thumbnail, forIndex: index)
            }
        }
    }

    private func saveThumbnail(thumbnail: UIImage, forIndex index: Int) {
        thumbnails[index] = thumbnail

        if let cell = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: index, inSection: 0)) as? FilterCollectionViewCell where collectionView.superview != nil {
            cell.imageView.image = thumbnail
            cell.activityIndicator.stopAnimating()
        }
    }

}

extension FilterSelectionController: UICollectionViewDataSource {
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return PhotoEffect.allEffects.count
    }

    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(FilterSelectionController.FilterCollectionViewCellReuseIdentifier, forIndexPath: indexPath)

        if let filterCell = cell as? FilterCollectionViewCell {
            let effectFilter = PhotoEffect.allEffects[indexPath.item]

            if effectFilter == activePhotoEffectBlock?() {
                dispatch_async(dispatch_get_main_queue()) {
                    // Unfortunately this does not work the first time it is called, so we are doing it in the next
                    // layout pass
                    collectionView.selectItemAtIndexPath(indexPath, animated: false, scrollPosition: .None)
                }
            }

            filterCell.accessibilityLabel = effectFilter.displayName
            filterCell.captionLabel.text = effectFilter.displayName

            if let image = thumbnails[indexPath.item] {
                filterCell.imageView.image = image
            } else {
                filterCell.activityIndicator.startAnimating()
            }
        }

        return cell
    }
}

extension FilterSelectionController: UICollectionViewDelegate {
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let layoutAttributes = collectionView.collectionViewLayout.layoutAttributesForItemAtIndexPath(indexPath) {
            let extendedCellRect = CGRectInset(layoutAttributes.frame, -60, 0)
            collectionView.scrollRectToVisible(extendedCellRect, animated: true)
        }

        let photoEffect = PhotoEffect.allEffects[indexPath.item]
        selectedBlock?(photoEffect)
    }
}
