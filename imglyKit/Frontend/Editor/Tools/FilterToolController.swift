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
    }

    // MARK: - Actions

    @objc private func apply(sender: UIButton) {
        delegate?.photoEditToolControllerDidFinish(self)
    }

    @objc private func discard(sender: UIButton) {
        delegate?.photoEditToolController(self, didDiscardChangesInFavorOfPhotoEditModel: uneditedPhotoEditModel)
    }

}
