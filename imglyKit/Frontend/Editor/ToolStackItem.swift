//
//  ToolStackItem.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 16/02/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import UIKit

let ToolStackItemDidChangeNotification = "ToolStackItemDidChangeNotification"

/**
 *  A `ToolStackItem` object manages the views to be displayed in the toolbars of a `ToolStackController`.
 */
@objc(IMGLYToolStackItem) public class ToolStackItem: NSObject {

    private var transactionDepth: Int = 0
    private var _mainToolbarView: UIView?

    /// The view that should be displayed in the main toolbar.
    public var mainToolbarView: UIView? {
        get {
            return _mainToolbarView
        }

        set {
            performChanges {
                _mainToolbarView = newValue
            }
        }
    }

    /**
    Use this method to apply changes to an instance of `ToolStackItem`.

    - parameter block: The changes to apply.
    */
    public func performChanges(@noescape block: () -> Void) {
        transactionDepth = transactionDepth + 1
        block()
        transactionDepth = transactionDepth - 1

        if transactionDepth == 0 {
            NSNotificationCenter.defaultCenter().postNotificationName(ToolStackItemDidChangeNotification, object: self)
        }
    }
}
