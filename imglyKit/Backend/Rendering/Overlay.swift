//
//  Overlay.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 25/02/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import UIKit

@objc(IMGLYOverlay) public class Overlay: NSObject, NSCopying {

    // MARK: - Properties

    public let image: CIImage
    public let rotation: CGFloat
    public let xScale: CGFloat
    public let yScale: CGFloat
    public let normalizedCenter: CGPoint

    // MARK: - Initializers

    public init(image: CIImage, rotation: CGFloat, xScale: CGFloat, yScale: CGFloat, normalizedCenter: CGPoint) {
        self.image = image
        self.rotation = rotation
        self.xScale = xScale
        self.yScale = yScale
        self.normalizedCenter = normalizedCenter
        super.init()
    }

    // MARK: - NSCopying

    public func copyWithZone(zone: NSZone) -> AnyObject {
        return self
    }
}
