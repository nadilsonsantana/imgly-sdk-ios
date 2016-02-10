//
//  PhotoEditRenderer.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 08/02/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import Foundation
import CoreImage

@objc(IMGLYPhotoEditRenderer) public class PhotoEditRenderer: NSObject {
    public var originalImage: CIImage? {
        didSet {
            if oldValue != originalImage {
                invalidateCachedFilters()
            }
        }
    }

    public var photoEditModel: IMGLYPhotoEditModel? {
        didSet {
            if oldValue != photoEditModel {
                invalidateCachedFilters()
            }
        }
    }

    public var renderMode = IMGLYRenderMode.All {
        didSet {
            if oldValue != renderMode {
                invalidateCachedFilters()
            }
        }
    }

    public var effectFilter: EffectFilter?

    private lazy var renderingQueue = dispatch_queue_create("photo_edit_rendering", DISPATCH_QUEUE_SERIAL)

    private var cachedOutputImage: CIImage?
    @NSCopying private var photoEditModelInCachedOutputImage: IMGLYPhotoEditModel?

    public var outputImage: CIImage {
        // Preconditions
        guard let originalImage = originalImage else {
            fatalError("originalImage cannot be nil while rendering")
        }

        guard let photoEditModel = photoEditModel else {
            fatalError("photoEditModel cannot be nil while rendering")
        }

        // Invalidate cache if cached photoEditModel does not exist or is not equal to the current photoEditModel
        if let cachedPhotoEditModel = photoEditModelInCachedOutputImage where cachedPhotoEditModel != photoEditModel {
            invalidateCachedFilters()
            photoEditModelInCachedOutputImage = photoEditModel
        } else if photoEditModelInCachedOutputImage == nil {
            invalidateCachedFilters()
            photoEditModelInCachedOutputImage = photoEditModel
        }

        // Return cachedOutputImage if still available
        if let cachedOutputImage = cachedOutputImage {
            return cachedOutputImage
        }

        // Apply filters
        var editedImage = originalImage

        // AutoEnhancement
        if renderMode.contains(.AutoEnhancement) && photoEditModel.autoEnhancementEnabled {
            let filters = editedImage.autoAdjustmentFiltersWithOptions([kCIImageAutoAdjustRedEye: false])

            // Set inputImage of each filter to the previous filter's outputImage
            for i in 0..<filters.count {
                if i == 0 {
                    filters[i].setValue(editedImage, forKey: kCIInputImageKey)
                } else {
                    filters[i].setValue(filters[i - 1], forKey: kCIInputImageKey)
                }
            }

            // Get the outputImage of the last filter
            if let outputImage = filters.last?.outputImage {
                editedImage = outputImage
            }

            // Set all inputImages back to nil to free memory
            _ = filters.map { $0.setValue(nil, forKey: kCIInputImageKey) }
        }

        // Orientation
        if renderMode.contains(.OrientationCrop) {
            editedImage = editedGeometryImageWithBaseImage(editedImage)
        }

        // TiltShift
        // TODO

        // EffectFilter
        // TODO

        // Color Adjustments
        if renderMode.contains(.ColorAdjustments) {
            if let filter = CIFilter(name: "CIColorControls") {
                filter.setValue(photoEditModel.contrast, forKey: kCIInputContrastKey)
                filter.setValue(photoEditModel.brightness, forKey: kCIInputBrightnessKey)
                filter.setValue(photoEditModel.saturation, forKey: kCIInputSaturationKey)
                filter.setValue(editedImage, forKey: kCIInputImageKey)
            }
        }

        // Cache image
        cachedOutputImage = editedImage

        return editedImage
    }

    public var outputImageSize: CGSize {
        // Preconditions
        guard let originalImage = originalImage else {
            fatalError("originalImage cannot be nil while rendering")
        }

        return editedGeometryImageWithBaseImage(originalImage).extent.size
    }

    private func editedGeometryImageWithBaseImage(inputImage: CIImage) -> CIImage {
        // Preconditions
        guard let photoEditModel = photoEditModel else {
            fatalError("photoEditModel cannot be nil while rendering")
        }

        var editedImage = inputImage
        var straightenAngle: Float

        if !orientationMirrored {
            straightenAngle = 1
        } else {
            straightenAngle = -1
        }

        straightenAngle *= Float(photoEditModel.straightenAngle)

        let normalizedCropRect = photoEditModel.normalizedCropRect
        let inputImageExtent = inputImage.extent

        var denormalizedCropRect = CGRect(
            x: normalizedCropRect.origin.x * inputImageExtent.size.width + inputImageExtent.origin.x,
            y: normalizedCropRect.origin.y * inputImageExtent.size.height + inputImageExtent.origin.y,
            width: normalizedCropRect.size.width * inputImageExtent.size.width,
            height: normalizedCropRect.size.height * inputImageExtent.size.height
        )

        // TODO: `referenceAngle` instead of 0?
        if straightenAngle != 0 {
            let rotationTransform = CGAffineTransformMakeRotation(-1 * CGFloat(straightenAngle))
            editedImage = editedImage.imageByApplyingTransform(rotationTransform)
            editedImage = editedImage.imageByApplyingTransform(CGAffineTransformMakeTranslation(-1 * editedImage.extent.origin.x, -1 * editedImage.extent.origin.y))

            let transform = CGAffineTransformConcat(CGAffineTransformConcat(CGAffineTransformInvert(CGAffineTransformMakeTranslation(inputImageExtent.midX, inputImageExtent.midY)), CGAffineTransformInvert(rotationTransform)), CGAffineTransformMakeTranslation(editedImage.extent.midX, editedImage.extent.midY))

            denormalizedCropRect.origin.x = (transform.a * denormalizedCropRect.midX + transform.c * denormalizedCropRect.midY + transform.tx) - (denormalizedCropRect.size.width * 0.5)
            denormalizedCropRect.origin.y = (transform.b * denormalizedCropRect.midX + transform.d * denormalizedCropRect.midY + transform.ty) - (denormalizedCropRect.size.height * 0.5)
        }

        if !CGRectEqualToRect(photoEditModel.normalizedCropRect, IMGLYPhotoEditModel.identityNormalizedCropRect()) {
            editedImage = editedImage.imageByCroppingToRect(CGRect(x: round(denormalizedCropRect.origin.x), y: round(denormalizedCropRect.origin.y), width: round(denormalizedCropRect.size.width), height: round(denormalizedCropRect.size.height)))
            editedImage = editedImage.imageByApplyingTransform(CGAffineTransformMakeTranslation(-1 * denormalizedCropRect.origin.x, -1 * denormalizedCropRect.origin.y))
        }

        if photoEditModel.appliedOrientation != IMGLYPhotoEditModel.identityOrientation() {
            editedImage = editedImage.imageByApplyingOrientation(Int32(photoEditModel.appliedOrientation.rawValue))
        }

        return editedImage
    }

    private var orientationMirrored: Bool {
        // TODO
        return false
    }

    private func invalidateCachedFilters() {
        effectFilter = nil
        cachedOutputImage = nil
    }

    private var generatingCIContext: CIContext?

    private func newCGImageFromOutputCIImage(outputImage: CIImage) -> CGImage {
        if generatingCIContext == nil {
            generatingCIContext = CIContext(EAGLContext: EAGLContext(API: .OpenGLES2))
        }

        guard let generatingCIContext = generatingCIContext else {
            fatalError("Unable to initialize CIContext")
        }

        return generatingCIContext.createCGImage(outputImage, fromRect: outputImage.extent)
    }

    public func newOutputImage() -> CGImage {
        return newCGImageFromOutputCIImage(outputImage)
    }

    public func createOutputImageWithCompletion(completion: ((outputImage: CGImage) -> Void)?) {
        dispatch_async(renderingQueue) {
            let image = self.newCGImageFromOutputCIImage(self.outputImage)
            completion?(outputImage: image)
        }
    }

    private var drawingCIContext: CIContext?
    private var lastUsedEAGLContext: EAGLContext?

    public func drawOutputImageInContext(context: EAGLContext, inRect rect: CGRect, viewportWidth: Int, viewportHeight: Int) {
        glClearColor(0, 0, 0, 1.0)
        glViewport(0, 0, GLsizei(viewportWidth), GLsizei(viewportHeight))
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))

        let outputImage = self.outputImage

        if drawingCIContext == nil || lastUsedEAGLContext != context {
            drawingCIContext = CIContext(EAGLContext: context)
            lastUsedEAGLContext = context
        }

        guard let drawingCIContext = drawingCIContext else {
            fatalError("Unable to initialize CIContext")
        }

        drawingCIContext.drawImage(outputImage, inRect: rect, fromRect: CGRect(origin: CGPoint.zero, size: outputImage.extent.size))
    }

}
