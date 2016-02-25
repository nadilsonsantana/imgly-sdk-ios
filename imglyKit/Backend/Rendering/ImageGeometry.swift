//
//  ImageGeometry.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 24/02/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import Foundation

@objc(IMGLYImageGeometry) public class ImageGeometry: NSObject, NSCopying {

    // MARK: - Properties

    public let inputRect: CGRect
    public var appliedOrientation: IMGLYOrientation

    // MARK: - Initializers

    public convenience override init() {
        self.init(inputSize: CGSize.zero)
    }

    public init(inputSize: CGSize) {
        inputRect = CGRect(origin: CGPoint.zero, size: inputSize)
        appliedOrientation = .Normal
        super.init()
    }

    public convenience init(inputSize: CGSize, initialOrientation: IMGLYOrientation) {
        self.init(inputSize: inputSize)
        applyOrientation(initialOrientation)
    }

    public convenience init(outputSize: CGSize, appliedOrientation: IMGLYOrientation) {
        // TODO: transformImageSize(outputSize, appliedOrientation)
        self.init(inputSize: CGSize.zero, initialOrientation: appliedOrientation)
    }

    // MARK: - Orientation Handling

    public func flipVertically() {
        applyOrientation(.FlipY)
    }

    public func flipHorizontally() {
        applyOrientation(.FlipX)
    }

    public func rotateClockwise() {
        applyOrientation(.Rotate90)
    }

    public func rotateCounterClockwise() {
        applyOrientation(.Rotate270)
    }

    public func applyOrientation(orientation: IMGLYOrientation) {
        appliedOrientation = IMGLYOrientation(firstOrientation: appliedOrientation, secondOrientation: orientation)
    }

    public var outputRect: CGRect {
        // TODO: transformImageRect(inputRect, appliedOrientation)
        return CGRect.zero
    }

    // MARK: - NSObject

    public override var description: String {
        return "Input size: {\(inputRect.size.width), \(inputRect.size.height)}, applied orientation: \(appliedOrientation)"
    }

    // MARK: - NSCopying

    public func copyWithZone(zone: NSZone) -> AnyObject {
        let geometry = ImageGeometry(inputSize: inputRect.size)
        geometry.appliedOrientation = appliedOrientation
        return geometry
    }
}
