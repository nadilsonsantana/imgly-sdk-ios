//
//  InstanceFactory.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 03/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

/**
  A singleton that is out to create objects. It is used within the SDK to
  create filters, views, viewcontrollers and such.
*/
@objc(IMGLYInstanceFactory) public class InstanceFactory: NSObject {

    /**
    Creates a text filter.

    - returns: A text filter
    */
    public class func textFilter() -> TextFilter {
        return TextFilter()
    }

    /**
    Creates a sticker filter.

    - returns: A sticker filter
    */
    public class func stickerFilter() -> StickerFilter {
        return StickerFilter()
    }

    /**
    Creates a crop filter.

    - returns: A crop filter
    */
    public class func orientationCropFilter() -> OrientationCropFilter {
        return OrientationCropFilter()
    }

    /**
    Creates a tiltshift filter.

    - returns: A tiltshift filter.
    */
    public class func tiltShiftFilter() -> TiltshiftFilter {
        return TiltshiftFilter()
    }

    /**
     Creates a border filter.

     - returns: A border filter.
     */
    public class func borderFilter() -> BorderFilter {
        return BorderFilter()
    }

    /**
    Creates a color-adjustment filter.

    - returns: A color-adjustment filter.
    */
    public class func colorAdjustmentFilter() -> ContrastBrightnessSaturationFilter {
        return ContrastBrightnessSaturationFilter()
    }

    /**
    Creates an enhancement filter.

    - returns: A enhancement filter.
    */
    public class func enhancementFilter() -> EnhancementFilter {
        return EnhancementFilter()
    }

    /**
    Creates an scale filter.

    - returns: A scale filter.
    */
    public class func scaleFilter() -> ScaleFilter {
        return ScaleFilter()
    }

    // MARK: - Font Related

    /**
    Returns a list that determins what fonts will be available within
    the text-dialog.

    - returns: An array of fontnames.
    */
    public class var availableFontsList: [String] {
        return [
            "AmericanTypewriter",
            "Avenir-Heavy",
            "ChalkboardSE-Regular",
            "ArialMT",
            "KohinoorBangla-Regular",
            "Liberator",
            "Muncie",
            "AbrahamLincoln",
            "Airship27",
            "ArvilSans",
            "Bender-Inline",
            "Blanch-Condensed",
            "Cubano-Regular",
            "Franchise-Bold",
            "GearedSlab-Regular",
            "Governor",
            "Haymaker",
            "Homestead-Regular",
            "MavenProLight200-Regular",
            "MenschRegular",
            "Sullivan-Regular",
            "Tommaso",
            "ValenciaRegular",
            "Vevey"
        ]
    }

    /**
     Some font names are long and ugly therefor.
     In that case its possible to add an entry into this dictionary.
     The SDK will perform a lookup first and will use that name in the UI.

     - returns: A map to beautfy the names.
     */
    public class var fontDisplayNames: [String:String] {
        return [
            "AmericanTypewriter" : "Typewriter",
             "Avenir-Heavy" :"Avenir",
            "ChalkboardSE-Regular" : "Chalkboard",
            "ArialMT" : "Arial",
            "KohinoorBangla-Regular" : "Kohinoor",
            "AbrahamLincoln" : "Lincoln",
            "Airship27" : "Airship",
            "ArvilSans" : "Arvil",
            "Bender-Inline" : "Bender",
            "Blanch-Condensed" : "Blanch",
            "Cubano-Regular" : "Cubano",
            "Franchise-Bold" : "Franchise",
            "GearedSlab-Regular" : "Geared",
            "Homestead-Regular" : "Homestead",
            "MavenProLight200-Regular" : "Maven Pro",
            "MenschRegular" : "Mensch",
            "Sullivan-Regular" : "Sullivan",
            "ValenciaRegular" : "Valencia"
        ]
    }

    public class func fontImporter() -> FontImporter {
        return FontImporter()
    }

}
