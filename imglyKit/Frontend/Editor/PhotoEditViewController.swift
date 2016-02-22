//
//  PhotoEditViewController.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 09/02/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import UIKit
import GLKit

@objc(IMGLYPhotoEditViewControllerDelegate) public protocol PhotoEditViewControllerDelegate {
    func photoEditViewController(photoEditViewController: PhotoEditViewController, didSelectToolController toolController: PhotoEditToolController)
    func photoEditViewControllerPopToolController(photoEditViewController: PhotoEditViewController)
    func photoEditViewControllerCurrentEditingTool(photoEditViewController: PhotoEditViewController) -> PhotoEditToolController?
    func photoEditViewController(photoEditViewController: PhotoEditViewController, didSaveImage image: UIImage)
    func photoEditViewControllerDidCancel(photoEditviewController: PhotoEditViewController)
}

@objc(IMGLYPhotoEditViewController) public class PhotoEditViewController: UIViewController {

    // MARK: - Statics

    static let IconCaptionCollectionViewCellReuseIdentifier = "IconCaptionCollectionViewCellReuseIdentifier"
    static let SeparatorCollectionViewCellReuseIdentifier = "SeparatorCollectionViewCellReuseIdentifier"
    static let ButtonCollectionViewCellSize = CGSize(width: 64, height: 80)
    static let SeparatorCollectionViewCellSize = CGSize(width: 15, height: 80)

    // MARK: - View Properties

    private var collectionView: UICollectionView?
    private var previewViewScrollingContainer: UIScrollView?
    private var mainPreviewView: GLKView?
    private var placeholderImageView: UIImageView?

    // MARK: - Constraint Properties

    private var placeholderImageViewConstraints: [NSLayoutConstraint]?
    private var previewViewScrollingContainerConstraints: [NSLayoutConstraint]?

    // MARK: - Model Properties

    public private(set) lazy var toolStackItem = ToolStackItem()

    private var toolControllers: [PhotoEditToolController]?

    private var photo: UIImage? {
        didSet {
        updatePlaceholderImage()
        }
    }

    private var photoFileURL: NSURL?

    private let configuration: Configuration

    private var photoEditModel: IMGLYPhotoEditMutableModel? {
        didSet {
        if oldValue != photoEditModel {
            if let oldPhotoEditModel = oldValue {
                NSNotificationCenter.defaultCenter().removeObserver(self, name: IMGLYPhotoEditModelDidChangeNotification, object: oldPhotoEditModel)
            }

            if let photoEditModel = photoEditModel {
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "photoEditModelDidChange:", name: IMGLYPhotoEditModelDidChangeNotification, object: photoEditModel)
                updateMainRenderer()
            }
        }
        }
    }

    @NSCopying private var uneditedPhotoEditModel: IMGLYPhotoEditModel?

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
                if let photo = photo {
                    // Write full resolution image to disc to free memory
                    let fileName = "\(NSProcessInfo.processInfo().globallyUniqueString)_photo.png"
                    let fileURL = NSURL(fileURLWithPath: (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent(fileName))
                    UIImagePNGRepresentation(photo)?.writeToURL(fileURL, atomically: true)
                    photoFileURL = fileURL
                    self.photo = nil
                }
            }
        }
        }
    }

    private var baseWorkCIImage: CIImage?

    private var mainRenderer: PhotoEditRenderer?

    private var nextRenderCompletionBlock: (() -> Void)?

    // MARK: - State Properties

    private var previewViewScrollingContainerLayoutValid = false
    private var lastKnownWorkImageSize = CGSize.zero
    private var lastKnownPreviewViewSize = CGSize.zero

    /// The identifier of the photo effect to apply to the photo immediately. This is useful if you
    /// pass a photo that already has an effect applied by the `CameraViewController`. Note that you
    /// must set this property before presenting the view controller.
    public var initialPhotoEffectIdentifier: String?

    /// The intensity of the photo effect that is applied to the photo immediately. See
    /// `initialPhotoEffectIdentifier` for more information.
    public var initialPhotoEffectIntensity: Float?

    private var toolForAction: [MainEditorActionType: PhotoEditToolController]?

    // MARK: - Other Properties

    weak var delegate: PhotoEditViewControllerDelegate?

    // MARK: - Initializers

    /**
    Returns a newly initialized photo edit view controller for the given photo with a default configuration.

    - parameter photo: The photo to edit.

    - returns: A newly initialized `PhotoEditViewController` object.
    */
    convenience public init(photo: UIImage) {
        self.init(photo: photo, configuration: Configuration())
    }

    /**
     Returns a newly initialized photo edit view controller for the given photo with the given configuration options.

     - parameter photo:         The photo to edit.
     - parameter configuration: The configuration options to apply.

     - returns: A newly initialized and configured `PhotoEditViewController` object.
     */
    required public init(photo: UIImage, configuration: Configuration) {
        self.photo = photo
        self.configuration = configuration
        super.init(nibName: nil, bundle: nil)

        updateLastKnownImageSize()
    }

    /**
     :nodoc:
     */
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    private var options: MainEditorViewControllerOptions {
        return self.configuration.mainEditorViewControllerOptions
    }

    // MARK: - UIViewController

    /**
     :nodoc:
     */
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

    /**
     :nodoc:
     */
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        loadPhotoEditModelIfNecessary()
        loadToolsIfNeeded()
        updateToolStackItem()
        updateBackgroundColor()
        updatePlaceholderImage()
        updateRenderedPreviewForceRender(false)
    }

    /**
     :nodoc:
     */
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        updateScrollViewContentSize()
    }

    /**
     :nodoc:
     */
    public override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

    /**
     :nodoc:
     */
    public override func prefersStatusBarHidden() -> Bool {
        return true
    }

    /**
     :nodoc:
     */
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
    }

    // MARK: - Notification Callbacks

    @objc private func photoEditModelDidChange(notification: NSNotification) {
        updateRenderedPreviewForceRender(false)
    }

    // MARK: - Setup

    internal func updateLayoutForNewToolController() {
        previewViewScrollingContainerLayoutValid = false
        updatePreviewContainerLayout()
        previewViewScrollingContainer?.zoomScale = 1
        view.layoutIfNeeded()
        updateScrollViewContentSize()
        updateBackgroundColor()
    }

    private func loadPhotoEditModelIfNecessary() {
        if photoEditModel == nil {
            let editModel = IMGLYPhotoEditMutableModel()

            if let photoEffectIdentifier = initialPhotoEffectIdentifier where editModel.effectFilterIdentifier != photoEffectIdentifier {
                editModel.effectFilterIdentifier = photoEffectIdentifier
            }

            if let photoEffectIntensity = initialPhotoEffectIntensity where editModel.effectFilterIntensity != CGFloat(photoEffectIntensity) {
                editModel.effectFilterIntensity = CGFloat(photoEffectIntensity)
            }

            loadBaseImageIfNecessary()
            photoEditModel = editModel
            uneditedPhotoEditModel = editModel
        }
    }

    private func updateToolStackItem() {
        if collectionView == nil {
            let flowLayout = UICollectionViewFlowLayout()
            flowLayout.scrollDirection = .Horizontal
            flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
            flowLayout.minimumLineSpacing = 8

            let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
            collectionView.showsVerticalScrollIndicator = false
            collectionView.showsHorizontalScrollIndicator = false
            collectionView.dataSource = self
            collectionView.delegate = self
            collectionView.backgroundColor = UIColor.clearColor()
            collectionView.registerClass(IconCaptionCollectionViewCell.self, forCellWithReuseIdentifier: PhotoEditViewController.IconCaptionCollectionViewCellReuseIdentifier)
            collectionView.registerClass(SeparatorCollectionViewCell.self, forCellWithReuseIdentifier: PhotoEditViewController.SeparatorCollectionViewCellReuseIdentifier)

            self.collectionView = collectionView
        }

        toolStackItem.performChanges {
            toolStackItem.mainToolbarView = collectionView
            toolStackItem.applyButton?.addTarget(self, action: "save:", forControlEvents: .TouchUpInside)
            toolStackItem.discardButton?.addTarget(self, action: "cancel:", forControlEvents: .TouchUpInside)
            toolStackItem.titleLabel?.text = Localize("EDITOR")
        }
    }

    private func updateBackgroundColor() {
        view.backgroundColor = delegate?.photoEditViewControllerCurrentEditingTool(self)?.preferredPreviewBackgroundColor ?? UIColor.blackColor()
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

    internal func updateLastKnownImageSize() {
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

        if let mainPreviewView = mainPreviewView {
            previewViewScrollingContainer.sendSubviewToBack(mainPreviewView)
        }

        if let placeholderImageView = placeholderImageView {
            previewViewScrollingContainer.sendSubviewToBack(placeholderImageView)
        }
    }

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

        var previewViewInsets = UIEdgeInsets(top: 0, left: 0, bottom: 124, right: 0)
        if let currentEditingTool = delegate?.photoEditViewControllerCurrentEditingTool(self) {
            previewViewInsets = previewViewInsets + currentEditingTool.preferredPreviewViewInsets
        }

        constraints.append(NSLayoutConstraint(item: previewViewScrollingContainer, attribute: .Left, relatedBy: .Equal, toItem: previewViewScrollingContainer.superview, attribute: .Left, multiplier: 1, constant: previewViewInsets.left))
        constraints.append(NSLayoutConstraint(item: previewViewScrollingContainer, attribute: .Right, relatedBy: .Equal, toItem: previewViewScrollingContainer.superview, attribute: .Right, multiplier: 1, constant: -1 * previewViewInsets.right))
        constraints.append(NSLayoutConstraint(item: previewViewScrollingContainer, attribute: .Top, relatedBy: .Equal, toItem: previewViewScrollingContainer.superview, attribute: .Top, multiplier: 1, constant: previewViewInsets.top))
        constraints.append(NSLayoutConstraint(item: previewViewScrollingContainer, attribute: .Bottom, relatedBy: .Equal, toItem: previewViewScrollingContainer.superview, attribute: .Bottom, multiplier: 1, constant: -1 * previewViewInsets.bottom))

        NSLayoutConstraint.activateConstraints(constraints)
        previewViewScrollingContainerConstraints = constraints
        previewViewScrollingContainerLayoutValid = true
    }

    internal func updateRenderedPreviewForceRender(forceRender: Bool) {
        mainRenderer?.renderMode = delegate?.photoEditViewControllerCurrentEditingTool(self)?.preferredRenderMode ?? .All

        let updatePreviewView: Bool

        if let currentEditingTool = delegate?.photoEditViewControllerCurrentEditingTool(self) where !currentEditingTool.wantsDefaultPreviewView {
            updatePreviewView = false
        } else {
            updatePreviewView = baseWorkUIImage == nil ? false : true
        }

        mainPreviewView?.hidden = !updatePreviewView

        if let _ = mainRenderer where updatePreviewView || forceRender {
            mainPreviewView?.setNeedsDisplay()
        }
    }

    // MARK: - Helpers

    private func workImageSizeForScreen(screen: UIScreen) -> CGSize {
        let screenSize = screen.bounds.size
        let screenScale = screen.scale

        let scaledScreenSize = screenSize * screenScale
        let maxLength = max(scaledScreenSize.width, scaledScreenSize.height)

        return CGSize(width: maxLength, height: maxLength)
    }

    private func orientedCIImageFromUIImage(image: UIImage) -> CIImage {
        guard let cgImage = image.CGImage else {
            return CIImage.emptyImage()
        }

        var ciImage = CIImage(CGImage: cgImage)
        ciImage = ciImage.imageByApplyingOrientation(Int32(image.imageOrientation.rawValue))
        return ciImage
    }

    private func scaleSize(size: CGSize, toFitSize targetSize: CGSize) -> CGSize {
        if size == CGSize.zero {
            return CGSize.zero
        }

        let scale = min(targetSize.width / size.width, targetSize.height / size.height)

        return size * scale
    }

    // MARK: - Tools

    private func loadToolsIfNeeded() {
        if toolForAction == nil {
            var toolForAction = [MainEditorActionType: PhotoEditToolController]()

            for i in 0 ..< options.editorActionsDataSource.actionCount {
                let action = options.editorActionsDataSource.actionAtIndex(i)

                if let photoEditModel = photoEditModel, toolController = InstanceFactory.toolControllerForEditorActionType(action.editorType, withPhotoEditModel: photoEditModel, configuration: configuration) {
                    toolController.delegate = self
                    toolForAction[action.editorType] = toolController
                }
            }

            self.toolForAction = toolForAction
        }
    }

    // MARK: - Actions

    @objc private func save(sender: UIButton) {
        // Load photo from disc
        if let photoFileURL = photoFileURL, path = photoFileURL.path, photo = UIImage(contentsOfFile: path) {
            if photoEditModel == uneditedPhotoEditModel {
                delegate?.photoEditViewController(self, didSaveImage: photo)
            } else if let cgImage = photo.CGImage {
                let ciImage = CIImage(CGImage: cgImage)
                let photoEditRenderer = PhotoEditRenderer()
                photoEditRenderer.photoEditModel = photoEditModel
                photoEditRenderer.originalImage = ciImage

                photoEditRenderer.createOutputImageWithCompletion { outputImage in
                    let image = UIImage(CGImage: outputImage)

                    dispatch_async(dispatch_get_main_queue()) {
                        self.delegate?.photoEditViewController(self, didSaveImage: image)

                        // Remove temporary file from disc
                        _ = try? NSFileManager.defaultManager().removeItemAtURL(photoFileURL)
                    }
                }
            }
        }
    }

    @objc private func cancel(sender: UIButton) {
        if let photoFileURL = photoFileURL {
            // Remove temporary file from disc
            _ = try? NSFileManager.defaultManager().removeItemAtURL(photoFileURL)
        }

        delegate?.photoEditViewControllerDidCancel(self)
    }
}

extension PhotoEditViewController: GLKViewDelegate {
    /**
     :nodoc:
     */
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
        }

        updateScrollViewCentering()
    }

    /**
     :nodoc:
     */
    public func scrollViewDidZoom(scrollView: UIScrollView) {
        if previewViewScrollingContainer == scrollView {
            updateScrollViewCentering()
        }
    }

    /**
     :nodoc:
     */
    public func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView?, atScale scale: CGFloat) {
        if previewViewScrollingContainer == scrollView {
            mainPreviewView?.contentScaleFactor = scale * UIScreen.mainScreen().scale
            updateRenderedPreviewForceRender(false)
        }
    }

    /**
     :nodoc:
     */
    public func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        if previewViewScrollingContainer == scrollView {
            return mainPreviewView
        }

        return nil
    }
}

extension PhotoEditViewController: UICollectionViewDataSource {
    /**
     :nodoc:
     */
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return options.editorActionsDataSource.actionCount
    }

    /**
     :nodoc:
     */
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let dataSource = options.editorActionsDataSource
        let action = dataSource.actionAtIndex(indexPath.item)

        if action.editorType == .Separator {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(PhotoEditViewController.SeparatorCollectionViewCellReuseIdentifier, forIndexPath: indexPath)

            if let separatorCell = cell as? SeparatorCollectionViewCell {
                separatorCell.separator.backgroundColor = options.separatorColor
            }

            return cell
        } else {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(PhotoEditViewController.IconCaptionCollectionViewCellReuseIdentifier, forIndexPath: indexPath)

            if let iconCaptionCell = cell as? IconCaptionCollectionViewCell {
                iconCaptionCell.captionLabel.text = action.title
                iconCaptionCell.imageView.image = action.image
                iconCaptionCell.accessibilityLabel = action.title
            }

            return cell
        }
    }
}

extension PhotoEditViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    /**
     :nodoc:
     */
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let action = options.editorActionsDataSource.actionAtIndex(indexPath.item)

        if action.editorType == .Separator {
            return PhotoEditViewController.SeparatorCollectionViewCellSize
        }

        return PhotoEditViewController.ButtonCollectionViewCellSize
    }

    /**
     :nodoc:
     */
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let action = options.editorActionsDataSource.actionAtIndex(indexPath.item)

        if action.editorType == .Separator {
            return
        }

        if action.editorType == .Magic {
            guard let photoEditModel = photoEditModel else {
                return
            }

            photoEditModel.performChangesWithBlock {
                photoEditModel.autoEnhancementEnabled = !photoEditModel.autoEnhancementEnabled
            }
        } else {
            if let toolController = toolForAction?[action.editorType] {
                delegate?.photoEditViewController(self, didSelectToolController: toolController)
            }
        }

        collectionView.reloadItemsAtIndexPaths([indexPath])
    }

    /**
     :nodoc:
     */
    public func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        let action = options.editorActionsDataSource.actionAtIndex(indexPath.item)

        if action.editorType == .Magic {
            if let iconCaptionCell = cell as? IconCaptionCollectionViewCell, let selectedImage = action.selectedImage {
                if photoEditModel?.autoEnhancementEnabled ?? false {
                    iconCaptionCell.accessibilityTraits |= UIAccessibilityTraitSelected
                    iconCaptionCell.imageView.image = selectedImage
                    iconCaptionCell.imageView.tintAdjustmentMode = .Dimmed
                } else {
                    iconCaptionCell.accessibilityTraits &= ~UIAccessibilityTraitSelected
                    iconCaptionCell.imageView.image = action.image
                    iconCaptionCell.imageView.tintAdjustmentMode = .Normal
                }
            }
        }
    }
}

extension PhotoEditViewController: PhotoEditToolControllerDelegate {
    public func photoEditToolControllerBaseImage(photoEditToolController: PhotoEditToolController) -> UIImage? {
        return baseWorkUIImage
    }

    public func photoEditToolControllerPreviewView(photoEditToolController: PhotoEditToolController) -> UIView? {
        return mainPreviewView
    }

    public func photoEditToolControllerDidFinish(photoEditToolController: PhotoEditToolController) {
        delegate?.photoEditViewControllerPopToolController(self)
    }

    public func photoEditToolController(photoEditToolController: PhotoEditToolController, didDiscardChangesInFavorOfPhotoEditModel photoEditModel: IMGLYPhotoEditModel) {
        self.photoEditModel?.copyValuesFromModel(photoEditModel)
        delegate?.photoEditViewControllerPopToolController(self)
    }
}
