//
//  PhotoEditToolController.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 11/02/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import UIKit

@objc(IMGLYPhotoEditToolControllerDelegate) public protocol PhotoEditToolControllerDelegate {
    func photoEditToolControllerBaseImage(photoEditToolController: PhotoEditToolController) -> UIImage?
    func photoEditToolControllerPreviewView(photoEditToolController: PhotoEditToolController) -> UIView?
    func photoEditToolControllerDidFinish(photoEditToolController: PhotoEditToolController)
    func photoEditToolController(photoEditToolController: PhotoEditToolController, didDiscardChangesInFavorOfPhotoEditModel photoEditModel: IMGLYPhotoEditModel)
}

/**
 *  A `PhotoEditToolController` is the base class for any tool controllers. Subclass this class if you
 *  want to add additional tools to the editor.
 */
@objc(IMGLYPhotoEditToolController) public class PhotoEditToolController: UIViewController {

    // MARK: - Configuration Properties

    /// The render mode that the preview image should be rendered with when this tool is active.
    public var preferredRenderMode: IMGLYRenderMode

    let photoEditModel: IMGLYPhotoEditMutableModel
    let uneditedPhotoEditModel: IMGLYPhotoEditModel
    private let configuration: Configuration

    weak var delegate: PhotoEditToolControllerDelegate?

    // MARK: - Initializers

    /**
    Initializes and returns a newly created tool stack controller with the given configuration.

    - parameter configuration: The configuration options to apply.

    - returns: The initialized and configured tool stack controller object.
    */
    public init(photoEditModel: IMGLYPhotoEditMutableModel, configuration: Configuration) {
        preferredRenderMode = .All
        self.photoEditModel = photoEditModel
        // swiftlint:disable force_cast
        self.uneditedPhotoEditModel = photoEditModel.copy() as! IMGLYPhotoEditModel
        // swiftlint:enable force_cast
        self.configuration = configuration
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UIViewController

    /**
     :nodoc:
     */
    public override func viewDidLoad() {
        super.viewDidLoad()
    }

    /**
     :nodoc:
     */
    public override func updateViewConstraints() {
        super.updateViewConstraints()
    }

    /**
     :nodoc:
     */
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - PhotoEditToolController

    /// If set to `true`, the default preview view is used. If set to `false`, the default preview view
    /// is hidden and you are responsible for displaying the image.
    public var wantsDefaultPreviewView: Bool {
        return true
    }

    /// The background color that should be used when this tool is active.
    public var preferredPreviewBackgroundColor: UIColor? {
        return nil
    }

    /// The insets that should be applied to the preview view when this tool is active.
    public var preferredPreviewViewInsets: UIEdgeInsets {
        return UIEdgeInsetsZero
    }

    /// The tool stack configuration item.
    public private(set) lazy var toolStackItem = ToolStackItem()

}
