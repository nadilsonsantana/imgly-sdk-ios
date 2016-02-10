//
//  PhotoEffect.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 10/02/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import Foundation
import CoreImage

/**
 *  The `PhotoEffect` class describes an effect that can be applied to a photo.
 */
@objc(IMGLYPhotoEffect) public class PhotoEffect: NSObject {

    // MARK: - Accessors

    /// The identifier of the effect.
    public let identifier: String
    // swiftlint:disable variable_name
    /// The name of the `CIFilter` that should be used to apply this effect.
    public let CIFilterName: String?
    // swiftlint:enable variable_name
    /// The name that is displayed to the user.
    public let displayName: String
    /// Additional options that should be passed to the `CIFilter` object that will be created when applying this effect.
    public let options: [String: AnyObject]?

    // MARK: - Initializers

    /**
    Returns a newly initialized photo effect.

    - parameter identifier:  An identifier that uniquely identifies the effect.
    - parameter filterName:  The name of the `CIFilter` that should be used to apply this effect.
    - parameter displayName: The name that is displayed to the user.
    - parameter options:     Additional options that should be passed to the `CIFilter` object that will be created when applying this effect.

    - returns: A newly initialized `PhotoEffect` object.
    */
    public init(identifier: String, CIFilterName filterName: String?, displayName: String, options: [String: AnyObject]?) {
        self.identifier = identifier
        self.CIFilterName = filterName
        self.displayName = displayName
        self.options = options
        super.init()
    }

    /// Returns a new `CIFilter` object with the given name and options.
    public var newEffectFilter: CIFilter? {
        guard let CIFilterName = CIFilterName, filter = CIFilter(name: CIFilterName, withInputParameters: options) else {
            return nil
        }

        return filter
    }
}
