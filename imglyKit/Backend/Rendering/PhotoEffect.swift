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
    /// The name of the `CIFilter` that should be used to apply this effect.
    public let CIFilterName: String?
    /// The URL of the lut image that should be used to generate a color cube. This is only used if `CIFilterName` is
    /// `CIColorCube` or `CIColorCubeWithColorSpace` and `options` does not include a key named `inputCubeData`.
    public let lutURL: NSURL?
    /// The name that is displayed to the user.
    public let displayName: String
    /// Additional options that should be passed to the `CIFilter` object that will be created when applying this effect.
    public let options: [String: AnyObject]?

    // MARK: - Initializers

    /**
    Returns a newly initialized photo effect.

    - parameter identifier:  An identifier that uniquely identifies the effect.
    - parameter filterName:  The name of the `CIFilter` that should be used to apply this effect.
    - parameter lutURL:      The URL of the lut image that should be used to generate a color cube. This is only used if `filterName` is `CIColorCube` or `CIColorCubeWithColorSpace` and `options` does not include a key named `inputCubeData`.
    - parameter displayName: The name that is displayed to the user.
    - parameter options:     Additional options that should be passed to the `CIFilter` object that will be created when applying this effect.

    - returns: A newly initialized `PhotoEffect` object.
    */
    public init(identifier: String, CIFilterName filterName: String?, lutURL: NSURL?, displayName: String, options: [String: AnyObject]?) {
        self.identifier = identifier
        self.CIFilterName = filterName
        self.lutURL = lutURL
        self.displayName = displayName
        self.options = options
        super.init()
    }

    /**
     Returns a newly initialized photo effect that uses a `CIColorCubeWithColorSpace` filter and the LUT at url `lutURL` to generate the color cube data.

     - parameter identifier:  An identifier that uniquely identifies the effect.
     - parameter lutURL:      The URL of the lut image that should be used to generate a color cube.
     - parameter displayName: The name that is displayed to the user.

     - returns: A newly initialized `PhotoEffect` object.
     */
    public init(identifier: String, lutURL: NSURL?, displayName: String) {
        self.identifier = identifier
        self.CIFilterName = "CIColorCubeWithColorSpace"
        self.lutURL = lutURL
        self.displayName = displayName

        var options: [String: AnyObject] = ["inputCubeDimension": 64]

        if let colorSpace = CGColorSpaceCreateDeviceRGB() {
            options["inputColorSpace"] = colorSpace
        }

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

    // MARK: - Statics

    /// Change this array to only support a subset of all available filters or to include custom
    /// filters. By default this array includes all available filters.
    public static var allEffects: [PhotoEffect] = [
        PhotoEffect(identifier: "None", CIFilterName: nil, lutURL: nil, displayName: Localize("None"), options: nil),
        PhotoEffect(identifier: "K1", lutURL: NSBundle(forClass: PhotoEffect.self).URLForResource("K1", withExtension: "png"), displayName: Localize("K1")),
        PhotoEffect(identifier: "K2", lutURL: NSBundle(forClass: PhotoEffect.self).URLForResource("K2", withExtension: "png"), displayName: Localize("K2")),
        PhotoEffect(identifier: "K6", lutURL: NSBundle(forClass: PhotoEffect.self).URLForResource("K6", withExtension: "png"), displayName: Localize("K6")),
        PhotoEffect(identifier: "Dynamic", lutURL: NSBundle(forClass: PhotoEffect.self).URLForResource("Dynamic", withExtension: "png"), displayName: Localize("Dynamic")),
        PhotoEffect(identifier: "Fridge", lutURL: NSBundle(forClass: PhotoEffect.self).URLForResource("Fridge", withExtension: "png"), displayName: Localize("Fridge")),
        PhotoEffect(identifier: "Breeze", lutURL: NSBundle(forClass: PhotoEffect.self).URLForResource("Breeze", withExtension: "png"), displayName: Localize("Breeze")),
        PhotoEffect(identifier: "Orchid", lutURL: NSBundle(forClass: PhotoEffect.self).URLForResource("Orchid", withExtension: "png"), displayName: Localize("Orchid")),
        PhotoEffect(identifier: "Chest", lutURL: NSBundle(forClass: PhotoEffect.self).URLForResource("Chest", withExtension: "png"), displayName: Localize("Chest")),
        PhotoEffect(identifier: "Front", lutURL: NSBundle(forClass: PhotoEffect.self).URLForResource("Front", withExtension: "png"), displayName: Localize("Front")),
        PhotoEffect(identifier: "Fixie", lutURL: NSBundle(forClass: PhotoEffect.self).URLForResource("Fixie", withExtension: "png"), displayName: Localize("Fixie")),
        PhotoEffect(identifier: "X400", lutURL: NSBundle(forClass: PhotoEffect.self).URLForResource("X400", withExtension: "png"), displayName: Localize("X400")),
        PhotoEffect(identifier: "BW", lutURL: NSBundle(forClass: PhotoEffect.self).URLForResource("BW", withExtension: "png"), displayName: Localize("BW")),
        PhotoEffect(identifier: "AD1920", lutURL: NSBundle(forClass: PhotoEffect.self).URLForResource("AD1920", withExtension: "png"), displayName: Localize("AD1920")),
        PhotoEffect(identifier: "Lenin", lutURL: NSBundle(forClass: PhotoEffect.self).URLForResource("Lenin", withExtension: "png"), displayName: Localize("Lenin")),
        PhotoEffect(identifier: "Quozi", lutURL: NSBundle(forClass: PhotoEffect.self).URLForResource("Quozi", withExtension: "png"), displayName: Localize("Quozi")),
        PhotoEffect(identifier: "669", lutURL: NSBundle(forClass: PhotoEffect.self).URLForResource("669", withExtension: "png"), displayName: Localize("669")),
        PhotoEffect(identifier: "SX", lutURL: NSBundle(forClass: PhotoEffect.self).URLForResource("SX", withExtension: "png"), displayName: Localize("SX")),
        PhotoEffect(identifier: "Food", lutURL: NSBundle(forClass: PhotoEffect.self).URLForResource("Food", withExtension: "png"), displayName: Localize("Food")),
        PhotoEffect(identifier: "Glam", lutURL: NSBundle(forClass: PhotoEffect.self).URLForResource("Glam", withExtension: "png"), displayName: Localize("Glam")),
        PhotoEffect(identifier: "Celsius", lutURL: NSBundle(forClass: PhotoEffect.self).URLForResource("Celsius", withExtension: "png"), displayName: Localize("Celsius")),
        PhotoEffect(identifier: "Texas", lutURL: NSBundle(forClass: PhotoEffect.self).URLForResource("Texas", withExtension: "png"), displayName: Localize("Texas")),
        PhotoEffect(identifier: "Lomo", lutURL: NSBundle(forClass: PhotoEffect.self).URLForResource("Lomo", withExtension: "png"), displayName: Localize("Lomo")),
        PhotoEffect(identifier: "Goblin", lutURL: NSBundle(forClass: PhotoEffect.self).URLForResource("Goblin", withExtension: "png"), displayName: Localize("Goblin")),
        PhotoEffect(identifier: "Sin", lutURL: NSBundle(forClass: PhotoEffect.self).URLForResource("Sin", withExtension: "png"), displayName: Localize("Sin")),
        PhotoEffect(identifier: "Mellow", lutURL: NSBundle(forClass: PhotoEffect.self).URLForResource("Mellow", withExtension: "png"), displayName: Localize("Mellow")),
        PhotoEffect(identifier: "Soft", lutURL: NSBundle(forClass: PhotoEffect.self).URLForResource("Soft", withExtension: "png"), displayName: Localize("Soft")),
        PhotoEffect(identifier: "Blues", lutURL: NSBundle(forClass: PhotoEffect.self).URLForResource("Blues", withExtension: "png"), displayName: Localize("Blues")),
        PhotoEffect(identifier: "Elder", lutURL: NSBundle(forClass: PhotoEffect.self).URLForResource("Elder", withExtension: "png"), displayName: Localize("Elder")),
        PhotoEffect(identifier: "Sunset", lutURL: NSBundle(forClass: PhotoEffect.self).URLForResource("Sunset", withExtension: "png"), displayName: Localize("Sunset")),
        PhotoEffect(identifier: "Evening", lutURL: NSBundle(forClass: PhotoEffect.self).URLForResource("Evening", withExtension: "png"), displayName: Localize("Evening")),
        PhotoEffect(identifier: "Steel", lutURL: NSBundle(forClass: PhotoEffect.self).URLForResource("Steel", withExtension: "png"), displayName: Localize("Steel")),
        PhotoEffect(identifier: "70s", lutURL: NSBundle(forClass: PhotoEffect.self).URLForResource("70s", withExtension: "png"), displayName: Localize("70s")),
        PhotoEffect(identifier: "Hicon", lutURL: NSBundle(forClass: PhotoEffect.self).URLForResource("Hicon", withExtension: "png"), displayName: Localize("Hicon")),
        PhotoEffect(identifier: "Blue Shade", lutURL: NSBundle(forClass: PhotoEffect.self).URLForResource("BlueShade", withExtension: "png"), displayName: Localize("Blue Shade")),
        PhotoEffect(identifier: "Carb", lutURL: NSBundle(forClass: PhotoEffect.self).URLForResource("Carb", withExtension: "png"), displayName: Localize("Carb")),
        PhotoEffect(identifier: "80s", lutURL: NSBundle(forClass: PhotoEffect.self).URLForResource("80s", withExtension: "png"), displayName: Localize("80s")),
        PhotoEffect(identifier: "Colorful", lutURL: NSBundle(forClass: PhotoEffect.self).URLForResource("Colorful", withExtension: "png"), displayName: Localize("Colorful")),
        PhotoEffect(identifier: "Lomo 100", lutURL: NSBundle(forClass: PhotoEffect.self).URLForResource("Lomo100", withExtension: "png"), displayName: Localize("Lomo 100")),
        PhotoEffect(identifier: "Pro 400", lutURL: NSBundle(forClass: PhotoEffect.self).URLForResource("Pro400", withExtension: "png"), displayName: Localize("Pro 400")),
        PhotoEffect(identifier: "Twilight", lutURL: NSBundle(forClass: PhotoEffect.self).URLForResource("Twilight", withExtension: "png"), displayName: Localize("Twilight")),
        PhotoEffect(identifier: "Candy", lutURL: NSBundle(forClass: PhotoEffect.self).URLForResource("Candy", withExtension: "png"), displayName: Localize("Candy")),
        PhotoEffect(identifier: "Pale", lutURL: NSBundle(forClass: PhotoEffect.self).URLForResource("Pale", withExtension: "png"), displayName: Localize("Pale")),
        PhotoEffect(identifier: "Settled", lutURL: NSBundle(forClass: PhotoEffect.self).URLForResource("Settled", withExtension: "png"), displayName: Localize("Settled")),
        PhotoEffect(identifier: "Cool", lutURL: NSBundle(forClass: PhotoEffect.self).URLForResource("Cool", withExtension: "png"), displayName: Localize("Cool")),
        PhotoEffect(identifier: "Litho", lutURL: NSBundle(forClass: PhotoEffect.self).URLForResource("Litho", withExtension: "png"), displayName: Localize("Litho")),
        PhotoEffect(identifier: "Ancient", lutURL: NSBundle(forClass: PhotoEffect.self).URLForResource("Ancient", withExtension: "png"), displayName: Localize("Ancient")),
        PhotoEffect(identifier: "Pitched", lutURL: NSBundle(forClass: PhotoEffect.self).URLForResource("Pitched", withExtension: "png"), displayName: Localize("Pitched")),
        PhotoEffect(identifier: "Lucid", lutURL: NSBundle(forClass: PhotoEffect.self).URLForResource("Lucid", withExtension: "png"), displayName: Localize("Lucid")),
        PhotoEffect(identifier: "Creamy", lutURL: NSBundle(forClass: PhotoEffect.self).URLForResource("Creamy", withExtension: "png"), displayName: Localize("Creamy")),
        PhotoEffect(identifier: "Keen", lutURL: NSBundle(forClass: PhotoEffect.self).URLForResource("Keen", withExtension: "png"), displayName: Localize("Keen")),
        PhotoEffect(identifier: "Tender", lutURL: NSBundle(forClass: PhotoEffect.self).URLForResource("Tender", withExtension: "png"), displayName: Localize("Tender")),
        PhotoEffect(identifier: "Bleached", lutURL: NSBundle(forClass: PhotoEffect.self).URLForResource("Bleached", withExtension: "png"), displayName: Localize("Bleached")),
        PhotoEffect(identifier: "B-Blue", lutURL: NSBundle(forClass: PhotoEffect.self).URLForResource("B-Blue", withExtension: "png"), displayName: Localize("B-Blue")),
        PhotoEffect(identifier: "Fall", lutURL: NSBundle(forClass: PhotoEffect.self).URLForResource("Fall", withExtension: "png"), displayName: Localize("Fall")),
        PhotoEffect(identifier: "Winter", lutURL: NSBundle(forClass: PhotoEffect.self).URLForResource("Winter", withExtension: "png"), displayName: Localize("Winter")),
        PhotoEffect(identifier: "Sepia High", lutURL: NSBundle(forClass: PhotoEffect.self).URLForResource("SepiaHigh", withExtension: "png"), displayName: Localize("Sepia High")),
        PhotoEffect(identifier: "Summer", lutURL: NSBundle(forClass: PhotoEffect.self).URLForResource("Summer", withExtension: "png"), displayName: Localize("Summer")),
        PhotoEffect(identifier: "Classic", lutURL: NSBundle(forClass: PhotoEffect.self).URLForResource("Classic", withExtension: "png"), displayName: Localize("Classic")),
        PhotoEffect(identifier: "No Green", lutURL: NSBundle(forClass: PhotoEffect.self).URLForResource("NoGreen", withExtension: "png"), displayName: Localize("No Green")),
        PhotoEffect(identifier: "Neat", lutURL: NSBundle(forClass: PhotoEffect.self).URLForResource("Neat", withExtension: "png"), displayName: Localize("Neat")),
        PhotoEffect(identifier: "Plate", lutURL: NSBundle(forClass: PhotoEffect.self).URLForResource("Plate", withExtension: "png"), displayName: Localize("Plate"))
    ]

    /**
     This method returns the photo effect with the given identifier if such an effect exists.

     - parameter identifier: The identifier of the photo effect.

     - returns: A `PhotoEffect` object.
     */
    public static func effectWithIdentifier(identifier: String) -> PhotoEffect? {
        guard let index = allEffects.indexOf({ $0.identifier == identifier }) else {
            return nil
        }

        return allEffects[index]
    }
}
