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

    private var photo: UIImage? {
        didSet {
            updatePlaceholderImage()
        }
    }

    let configuration: Configuration

    convenience public init(photo: UIImage) {
        self.init(photo: photo, configuration: Configuration())
    }

    required public init(photo: UIImage, configuration: Configuration) {
        self.photo = photo
        self.configuration = configuration
        super.init(nibName: nil, bundle: nil)

        updateLastKnownImageSize()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UIViewController

    private var mainToolbar: UIView?
    private var secondaryToolbar: UIView?

    private var previewViewScrollingContainer: UIScrollView?
    private var mainPreviewView: GLKView?

    public override func viewDidLoad() {
        super.viewDidLoad()

        previewViewScrollingContainer = UIScrollView()
        view.addSubview(previewViewScrollingContainer!)
        previewViewScrollingContainer!.delegate = self
        previewViewScrollingContainer!.alwaysBounceHorizontal = true
        previewViewScrollingContainer!.alwaysBounceVertical = true
        previewViewScrollingContainer!.showsHorizontalScrollIndicator = false
        previewViewScrollingContainer!.showsVerticalScrollIndicator = false
        previewViewScrollingContainer!.maximumZoomScale = 3
        previewViewScrollingContainer!.minimumZoomScale = 1
        previewViewScrollingContainer!.clipsToBounds = false

        automaticallyAdjustsScrollViewInsets = false

        let context = EAGLContext(API: .OpenGLES2)
        mainPreviewView = GLKView(frame: CGRect.zero, context: context)
        mainPreviewView!.delegate = self
        previewViewScrollingContainer!.addSubview(mainPreviewView!)

        view.setNeedsUpdateConstraints()
    }

    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        loadPhotoEditModelIfNecessary()
        updateToolbars()
        updateBackgroundColor()
        updatePlaceholderImage()
        updateRenderedPreviewForceRender(false)
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        updateScrollViewContentSize()
    }

    private var mainToolbarConstraints: [NSLayoutConstraint]?
    private var secondaryToolbarConstraints: [NSLayoutConstraint]?

    public override func updateViewConstraints() {
        super.updateViewConstraints()

        updatePreviewContainerLayout()

        if let placeholderImageView = placeholderImageView, _ = previewViewScrollingContainer where placeholderImageViewConstraints == nil {
            placeholderImageView.translatesAutoresizingMaskIntoConstraints = false

            var constraints = [NSLayoutConstraint]()

            constraints.append(NSLayoutConstraint(item: placeholderImageView, attribute: .Width, relatedBy: .Equal, toItem: mainPreviewView, attribute: .Width, multiplier: 1, constant: 0))
            constraints.append(NSLayoutConstraint(item: placeholderImageView, attribute: .Height, relatedBy: .Equal, toItem: mainPreviewView, attribute: .Height, multiplier: 1, constant: 0))
            constraints.append(NSLayoutConstraint(item: placeholderImageView, attribute: .CenterX, relatedBy: .Equal, toItem: mainPreviewView, attribute: .CenterX, multiplier: 1, constant: 0))
            constraints.append(NSLayoutConstraint(item: placeholderImageView, attribute: .CenterY, relatedBy: .Equal, toItem: mainPreviewView, attribute: .CenterY, multiplier: 1, constant: 0))

            placeholderImageViewConstraints = constraints
            NSLayoutConstraint.activateConstraints(constraints)
        }

        if let mainToolbar = mainToolbar where mainToolbarConstraints == nil {
            mainToolbar.translatesAutoresizingMaskIntoConstraints = false

            var constraints = [NSLayoutConstraint]()

            constraints.append(NSLayoutConstraint(item: mainToolbar, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1, constant: 0))
            constraints.append(NSLayoutConstraint(item: mainToolbar, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1, constant: 0))
            constraints.append(NSLayoutConstraint(item: mainToolbar, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: 0))
            constraints.append(NSLayoutConstraint(item: mainToolbar, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 110))

            mainToolbarConstraints = constraints
            NSLayoutConstraint.activateConstraints(constraints)
        }

        if let secondaryToolbar = secondaryToolbar where secondaryToolbarConstraints == nil {
            secondaryToolbar.translatesAutoresizingMaskIntoConstraints = false

            var constraints = [NSLayoutConstraint]()

            constraints.append(NSLayoutConstraint(item: secondaryToolbar, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1, constant: 0))
            constraints.append(NSLayoutConstraint(item: secondaryToolbar, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1, constant: 0))
            constraints.append(NSLayoutConstraint(item: secondaryToolbar, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: 0))
            constraints.append(NSLayoutConstraint(item: secondaryToolbar, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 40))

            mainToolbarConstraints = constraints
            NSLayoutConstraint.activateConstraints(constraints)
        }
    }

    private var photoEditModel: IMGLYPhotoEditMutableModel? {
        didSet {
            if oldValue != photoEditModel {
                if let oldPhotoEditModel = oldValue {
                    NSNotificationCenter.defaultCenter().removeObserver(self, name: IMGLYPhotoEditModelDidChangeNotification, object: oldPhotoEditModel)
                }

                if let photoEditModel = photoEditModel {
                    NSNotificationCenter.defaultCenter().addObserver(self, selector: "photoEditModelDidChange:", name: IMGLYPhotoEditModelDidChangeNotification, object: photoEditModel)
                    updateMainRenderer()
                    setupToolsIfNeeded()
                }
            }
        }
    }

    @objc private func photoEditModelDidChange(notification: NSNotification) {
        updateRenderedPreviewForceRender(false)
    }

    private func setupToolsIfNeeded() {
        // TODO
    }

    @NSCopying private var uneditedPhotoEditModel: IMGLYPhotoEditModel?

    private func loadPhotoEditModelIfNecessary() {
        if photoEditModel == nil {
            let editModel = IMGLYPhotoEditMutableModel()
            loadBaseImageIfNecessary()
            photoEditModel = editModel
            uneditedPhotoEditModel = editModel
        }
    }

    private func updateToolbars() {
        if mainToolbar == nil {
            mainToolbar = UIView()
            mainToolbar!.backgroundColor = UIColor(red: 0.17, green: 0.17, blue: 0.17, alpha: 1)
            view.addSubview(mainToolbar!)
            updateSubviewsOrdering()
            view.setNeedsUpdateConstraints()
        }

        if secondaryToolbar == nil {
            secondaryToolbar = UIView()
            secondaryToolbar!.backgroundColor = UIColor(red: 0.11, green: 0.11, blue: 0.11, alpha: 1)
            view.addSubview(secondaryToolbar!)
            updateSubviewsOrdering()
            view.setNeedsUpdateConstraints()
        }
    }

    private func updateBackgroundColor() {
        view.backgroundColor = currentEditingTool?.preferredPreviewBackgroundColor ?? UIColor.blackColor()
    }

    private func loadBaseImageIfNecessary() {
        if let _ = baseWorkUIImage {
            return
        }

        guard let photo = photo else {
            return
        }

        let screen = UIScreen.mainScreen()
        var targetSize = workImageSizeForScreen(screen)

        if photo.size.width > photo.size.height {
            let aspectRatio = photo.size.height / photo.size.width
            targetSize = CGSize(width: targetSize.width, height: targetSize.height * aspectRatio)
        } else if photo.size.width < photo.size.height {
            let aspectRatio = photo.size.width / photo.size.height
            targetSize = CGSize(width: targetSize.width * aspectRatio, height: targetSize.height)
        }

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            let resizedImage = photo.imgly_normalizedImageOfSize(targetSize)

            dispatch_async(dispatch_get_main_queue()) {
                self.baseWorkUIImage = resizedImage
                self.updateRenderedPreviewForceRender(false)
            }
        }
    }

    private func workImageSizeForScreen(screen: UIScreen) -> CGSize {
        let screenSize = screen.bounds.size
        let screenScale = screen.scale

        let scaledScreenSize = screenSize * screenScale
        let maxLength = max(scaledScreenSize.width, scaledScreenSize.height)

        return CGSize(width: maxLength, height: maxLength)
    }

    private var baseWorkUIImage: UIImage? {
        didSet {
            if oldValue != baseWorkUIImage {

                let ciImage: CIImage?
                if let baseWorkUIImage = baseWorkUIImage {
                    ciImage = orientedCIImageFromUIImage(baseWorkUIImage)
                } else {
                    ciImage = nil
                }

                baseWorkCIImage = ciImage
                updateMainRenderer()

                if baseWorkUIImage != nil {
                    // TODO: Save to disc
                    photo = nil
                }
            }
        }
    }

    private var baseWorkCIImage: CIImage?

    private func orientedCIImageFromUIImage(image: UIImage) -> CIImage {
        // TODO: Fix force unwrap
        var ciImage = CIImage(CGImage: image.CGImage!)
        ciImage = ciImage.imageByApplyingOrientation(Int32(image.imageOrientation.rawValue))
        return ciImage
    }

    private func updateMainRenderer() {
        if mainRenderer == nil {
            if let photoEditModel = photoEditModel, baseWorkCIImage = baseWorkCIImage {
                mainRenderer = PhotoEditRenderer()
                mainRenderer!.photoEditModel = photoEditModel
                mainRenderer!.originalImage = baseWorkCIImage
                updateLastKnownImageSize()
                view.setNeedsLayout()
                updateRenderedPreviewForceRender(false)
            }
        }
    }

    private func updateLastKnownImageSize() {
        let workImageSize: CGSize

        if let renderer = mainRenderer {
            workImageSize = renderer.outputImageSize
        } else if let photo = photo {
            workImageSize = photo.size * UIScreen.mainScreen().scale
        } else {
            workImageSize = CGSize.zero
        }

        if workImageSize != lastKnownWorkImageSize {
            lastKnownWorkImageSize = workImageSize
            updateScrollViewContentSize()
            updateRenderedPreviewForceRender(false)
        }
    }

    private var placeholderImageView: UIImageView?
    private var placeholderImageViewConstraints: [NSLayoutConstraint]?

    private func updatePlaceholderImage() {
        if isViewLoaded() {
            let showPlaceholderImageView: Bool

            if let _ = baseWorkUIImage {
                showPlaceholderImageView = false
            } else {
                showPlaceholderImageView = true
            }

            if let photo = photo where showPlaceholderImageView {
                if placeholderImageView == nil {
                    placeholderImageView = UIImageView(image: photo)
                    placeholderImageView!.contentMode = .ScaleAspectFit
                    previewViewScrollingContainer?.addSubview(placeholderImageView!)
                    updateSubviewsOrdering()
                    view.setNeedsUpdateConstraints()
                }

                placeholderImageView?.hidden = false
            } else {
                if let placeholderImageView = placeholderImageView {
                    placeholderImageView.hidden = true

                    if photo == nil {
                        placeholderImageView.removeFromSuperview()
                        self.placeholderImageView = nil
                        placeholderImageViewConstraints = nil
                    }
                }
            }
        }
    }

    private func updateSubviewsOrdering() {
        guard let previewViewScrollingContainer = previewViewScrollingContainer else {
            return
        }

        view.sendSubviewToBack(previewViewScrollingContainer)

        if let currentEditingTool = currentEditingTool {
            view.bringSubviewToFront(currentEditingTool.view)
        }

        if let mainToolbar = mainToolbar {
            view.bringSubviewToFront(mainToolbar)
        }

        if let secondaryToolbar = secondaryToolbar {
            view.bringSubviewToFront(secondaryToolbar)
        }

        if let mainPreviewView = mainPreviewView {
            previewViewScrollingContainer.sendSubviewToBack(mainPreviewView)
        }

        if let placeholderImageView = placeholderImageView {
            previewViewScrollingContainer.sendSubviewToBack(placeholderImageView)
        }
    }

    private var previewViewScrollingContainerLayoutValid = false
    private var previewViewScrollingContainerConstraints: [NSLayoutConstraint]?

    private func updatePreviewContainerLayout() {
        if previewViewScrollingContainerLayoutValid {
            return
        }

        guard let previewViewScrollingContainer = previewViewScrollingContainer else {
            return
        }

        if let previewViewScrollingContainerConstraints = previewViewScrollingContainerConstraints {
            NSLayoutConstraint.deactivateConstraints(previewViewScrollingContainerConstraints)
            self.previewViewScrollingContainerConstraints = nil
        }

        previewViewScrollingContainer.translatesAutoresizingMaskIntoConstraints = false

        var constraints = [NSLayoutConstraint]()

        let previewViewInsets: UIEdgeInsets
        if let currentEditingTool = currentEditingTool {
            previewViewInsets = currentEditingTool.preferredPreviewViewInsets
        } else {
            previewViewInsets = UIEdgeInsets(top: 0, left: 0, bottom: 110, right: 0)
        }

        constraints.append(NSLayoutConstraint(item: previewViewScrollingContainer, attribute: .Left, relatedBy: .Equal, toItem: previewViewScrollingContainer.superview, attribute: .Left, multiplier: 1, constant: previewViewInsets.left))
        constraints.append(NSLayoutConstraint(item: previewViewScrollingContainer, attribute: .Right, relatedBy: .Equal, toItem: previewViewScrollingContainer.superview, attribute: .Right, multiplier: 1, constant: -1 * previewViewInsets.right))
        constraints.append(NSLayoutConstraint(item: previewViewScrollingContainer, attribute: .Top, relatedBy: .Equal, toItem: previewViewScrollingContainer.superview, attribute: .Top, multiplier: 1, constant: previewViewInsets.top))
        constraints.append(NSLayoutConstraint(item: previewViewScrollingContainer, attribute: .Bottom, relatedBy: .Equal, toItem: previewViewScrollingContainer.superview, attribute: .Bottom, multiplier: 1, constant: -1 * previewViewInsets.bottom))

        NSLayoutConstraint.activateConstraints(constraints)
        previewViewScrollingContainerConstraints = constraints
        previewViewScrollingContainerLayoutValid = true
    }

    private var lastKnownWorkImageSize = CGSize.zero
    private var lastKnownPreviewViewSize = CGSize.zero

    private var currentEditingTool: PhotoEditToolController?

    private func updateRenderedPreviewForceRender(forceRender: Bool) {
        mainRenderer?.renderMode = currentEditingTool?.preferredRenderMode ?? .All

        let updatePreviewView: Bool

        if let currentEditingTool = currentEditingTool where !currentEditingTool.wantsDefaultPreviewView {
            updatePreviewView = false
        } else {
            updatePreviewView = baseWorkUIImage == nil ? false : true
        }

        mainPreviewView?.hidden = !updatePreviewView

        if let _ = mainRenderer where updatePreviewView || forceRender {
            mainPreviewView?.setNeedsDisplay()
        }
    }

    private var mainRenderer: PhotoEditRenderer?

    private var nextRenderCompletionBlock: (() -> Void)?
}

extension PhotoEditViewController: GLKViewDelegate {
    public func glkView(view: GLKView, drawInRect rect: CGRect) {
        if let renderer = mainRenderer {
            renderer.drawOutputImageInContext(view.context, inRect: CGRect(x: 0, y: 0, width: view.drawableWidth, height: view.drawableHeight), viewportWidth: view.drawableWidth, viewportHeight: view.drawableHeight)

            nextRenderCompletionBlock?()
            nextRenderCompletionBlock = nil
        }
    }
}

extension PhotoEditViewController: UIScrollViewDelegate {
    private func updateScrollViewCentering() {
        guard let previewViewScrollingContainer = previewViewScrollingContainer else {
            return
        }

        let containerSize = previewViewScrollingContainer.bounds.size
        let contentSize = previewViewScrollingContainer.contentSize

        let horizontalCenterOffset: CGFloat

        if contentSize.width < containerSize.width {
            horizontalCenterOffset = (containerSize.width - contentSize.width) * 0.5
        } else {
            horizontalCenterOffset = 0
        }

        let verticalCenterOffset: CGFloat

        if contentSize.height < containerSize.height {
            verticalCenterOffset = (containerSize.height - contentSize.height) * 0.5
        } else {
            verticalCenterOffset = 0
        }

        mainPreviewView?.center = CGPoint(
            x: contentSize.width * 0.5 + horizontalCenterOffset,
            y: contentSize.height * 0.5 + verticalCenterOffset
        )
    }

    private func updateScrollViewContentSize() {
        guard let previewViewScrollingContainer = previewViewScrollingContainer else {
            return
        }

        let zoomScale = previewViewScrollingContainer.zoomScale
        let workImageSize = lastKnownWorkImageSize
        let containerSize = previewViewScrollingContainer.bounds.size

        let fittedSize = scaleSize(workImageSize, toFitSize: containerSize)

        if lastKnownPreviewViewSize != fittedSize {
            previewViewScrollingContainer.zoomScale = 1
            lastKnownPreviewViewSize = fittedSize

            mainPreviewView?.frame = CGRect(x: 0, y: 0, width: fittedSize.width, height: fittedSize.height)
            previewViewScrollingContainer.contentSize = fittedSize
            previewViewScrollingContainer.zoomScale = zoomScale

            // currentEditingTool?.resetForZoomAndPan()
        }

        updateScrollViewCentering()
    }

    private func scaleSize(size: CGSize, toFitSize targetSize: CGSize) -> CGSize {
        if size == CGSize.zero {
            return CGSize.zero
        }

        let scale = min(targetSize.width / size.width, targetSize.height / size.height)

        return size * scale
    }

    public func scrollViewDidZoom(scrollView: UIScrollView) {
        if previewViewScrollingContainer == scrollView {
            updateScrollViewCentering()
        }
    }

    public func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView?, atScale scale: CGFloat) {
        if previewViewScrollingContainer == scrollView {
            mainPreviewView?.contentScaleFactor = scale * UIScreen.mainScreen().scale
            updateRenderedPreviewForceRender(false)
        }
    }

    public func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        if previewViewScrollingContainer == scrollView {
            return mainPreviewView
        }

        return nil
    }
}
