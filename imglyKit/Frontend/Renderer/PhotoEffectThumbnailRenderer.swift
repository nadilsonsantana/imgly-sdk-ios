//
//  PhotoEffectThumbnailRenderer.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 19/02/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import UIKit

@objc(IMGLYPhotoEffectThumbnailRenderer) public class PhotoEffectThumbnailRenderer: NSObject {

    // MARK: - Properties

    public let inputImage: UIImage
    private let renderQueue = dispatch_queue_create("photo_effect_thumbnail_rendering", DISPATCH_QUEUE_SERIAL)
    private let ciContext: CIContext
    private let eaglContext: EAGLContext
    public var thumbnailImage: UIImage?

    // MARK: - Initializers

    public init(inputImage: UIImage) {
        self.inputImage = inputImage
        eaglContext = EAGLContext(API: .OpenGLES2)
        ciContext = CIContext(EAGLContext: eaglContext)
        super.init()
    }

    // MARK: - Rendering

    public func generateThumbnailsForPhotoEffects(photoEffects: [PhotoEffect], ofSize size: CGSize, singleCompletion: ((thumbnail: UIImage, index: Int) -> Void)) {

        dispatch_async(renderQueue) {
            self.renderBaseThumbnailIfNeededOfSize(size)
            var index = 0

            for effect in photoEffects {
                let thumbnail: UIImage?

                if let filter = effect.newEffectFilter {
                    thumbnail = self.renderThumbnailWithFilter(filter)
                } else {
                    thumbnail = self.thumbnailImage
                }

                if let thumbnail = thumbnail {
                    singleCompletion(thumbnail: thumbnail, index: index)
                }

                index = index + 1
            }
        }
    }

    private func renderBaseThumbnailIfNeededOfSize(size: CGSize) {
        let renderThumbnail = {
            UIGraphicsBeginImageContextWithOptions(size, true, 0)
            self.inputImage.imgly_drawInRect(CGRect(origin: CGPoint.zero, size: size), withContentMode: .ScaleAspectFill)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            self.thumbnailImage = image
        }

        if let thumbnailImage = thumbnailImage where thumbnailImage.size != size {
            renderThumbnail()
        } else if thumbnailImage == nil {
            renderThumbnail()
        }
    }

    private func renderThumbnailWithFilter(filter: CIFilter) -> UIImage? {
        guard let thumbnailImage = thumbnailImage?.CGImage else {
            return nil
        }

        let inputImage = CIImage(CGImage: thumbnailImage)
        filter.setValue(inputImage, forKey: kCIInputImageKey)

        guard let outputImage = filter.outputImage else {
            return nil
        }

        let cgOutputImage = ciContext.createCGImage(outputImage, fromRect: outputImage.extent)

        return UIImage(CGImage: cgOutputImage)
    }
}
