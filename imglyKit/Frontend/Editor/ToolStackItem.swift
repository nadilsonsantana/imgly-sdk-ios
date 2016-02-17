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
    private var _titleLabel: UILabel? = {
        let label = UILabel()
        label.font = UIFont.boldSystemFontOfSize(14)
        label.textColor = UIColor.whiteColor()
        return label
    }()

    private var _discardButton: UIButton? = {
        let button = UIButton(type: .Custom)
        button.setImage(UIImage(named: "discard_changes_icon", inBundle: NSBundle(forClass: ToolStackItem.self), compatibleWithTraitCollection: nil), forState: .Normal)
        return button
    }()

    private var _applyButton: UIButton? = {
        let button = UIButton(type: .Custom)
        button.setImage(UIImage(named: "apply_changes_icon", inBundle: NSBundle(forClass: ToolStackItem.self), compatibleWithTraitCollection: nil), forState: .Normal)
        return button
    }()


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

    /// The title label that is shown in the secondary toolbar.
    public var titleLabel: UILabel? {
        get {
            return _titleLabel
        }

        set {
            performChanges {
                _titleLabel = newValue
            }
        }
    }

    /// The discard button that is shown in the secondary toolbar. Set to `nil` to remove.
    public var discardButton: UIButton? {
        get {
            return _discardButton
        }

        set {
            performChanges {
                _discardButton = newValue
            }
        }
    }

    /// The apply button that is shown in the secondary toolbar. Set to `nil` to remove.
    public var applyButton: UIButton? {
        get {
            return _applyButton
        }

        set {
            performChanges {
                _applyButton = newValue
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
