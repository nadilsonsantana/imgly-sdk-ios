//
//  PhotoProcessor.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 03/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation
#if os(iOS)
import CoreImage
import UIKit
#elseif os(OSX)
import QuartzCore
import AppKit
#endif

/**
All types of response-filters.
*/

@objc(IMGLYPhotoProcessor) public class PhotoProcessor: NSObject {
    public class func processWithCIImage(image: CIImage, filters: [Filter]) -> CIImage? {
        if filters.count == 0 {
            return image
        }

        var currentImage: CIImage? = image

        for filter in filters {
            filter.inputImage = currentImage
            currentImage = filter.outputImage
            filter.inputImage = nil
        }

        if let currentImage = currentImage where CGRectIsEmpty(currentImage.extent) {
            return nil
        }

        return currentImage
    }

    #if os(iOS)

    public class func processWithUIImage(image: UIImage, filters: [Filter]) -> UIImage? {
        let imageOrientation = image.imageOrientation
        guard let coreImage = CIImage(image: image) else {
            return nil
        }

        let filteredCIImage = processWithCIImage(coreImage, filters: filters)
        let filteredCGImage = CIContext(options: nil).createCGImage(filteredCIImage!, fromRect: filteredCIImage!.extent)
        return UIImage(CGImage: filteredCGImage, scale: 1.0, orientation: imageOrientation)
    }

    #elseif os(OSX)

    public class func processWithNSImage(image: NSImage, filters: [Filter]) -> NSImage? {
        if let tiffRepresentation = image.TIFFRepresentation, image = CIImage(data: tiffRepresentation) {
            let filteredCIImage = processWithCIImage(image, filters: filters)

            if let filteredCIImage = filteredCIImage {
                let rep = NSCIImageRep(CIImage: filteredCIImage)
                let image = NSImage(size: NSSize(width: filteredCIImage.extent.size.width, height: filteredCIImage.extent.size.height))
                image.addRepresentation(rep)
                return image
            }
        }

        return nil
    }

    #endif
}
