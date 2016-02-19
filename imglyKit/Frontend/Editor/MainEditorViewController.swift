//
//  MainEditorViewController.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 07/04/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

@objc public enum EditorResult: Int {
    case Done
    case Cancel
}

@objc public enum MainEditorActionType: Int {
    case Crop
    case Orientation
    case Filter
    case Adjust
    case Text
    case Sticker
    case Focus
    case Frame
    case Magic
    case Separator

    // TODO: Remove
    case Stickers
    case Border
    case Brightness
    case Contrast
    case Saturation
}
