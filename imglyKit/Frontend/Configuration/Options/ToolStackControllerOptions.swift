//
//  ToolStackControllerOptions.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 16/02/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import UIKit

@objc(IMGLYToolStackControllerOptions) public class ToolStackControllerOptions: EditorViewControllerOptions {
    /// The background color of the main toolbar
    public let mainToolbarBackgroundColor: UIColor

    /// The background color of the secondary toolbar
    public let secondaryToolbarBackgroundColor: UIColor

    /**
     Returns a newly allocated instance of `ToolStackControllerOptions` using the default builder.

     - returns: An instance of `ToolStackControllerOptions`.
     */
    public convenience init() {
        self.init(builder: ToolStackControllerOptionsBuilder())
    }

    /**
     Returns a newly allocated instance of `ToolStackControllerOptions` using the given builder.

     - parameter builder: A `ToolStackControllerOptionsBuilder` instance.

     - returns: An instance of `ToolStackControllerOptions`.
     */
    public init(builder: ToolStackControllerOptionsBuilder) {
        mainToolbarBackgroundColor = builder.mainToolbarBackgroundColor
        secondaryToolbarBackgroundColor = builder.secondaryToolbarBackgroundColor
        super.init(editorBuilder: builder)
    }
}

@objc(IMGLYToolStackControllerOptionsBuilder) public class ToolStackControllerOptionsBuilder: EditorViewControllerOptionsBuilder {
    /// The background color of the main toolbar
    public var mainToolbarBackgroundColor = UIColor(red: 0.17, green: 0.17, blue: 0.17, alpha: 1)

    /// The background color of the secondary toolbar
    public var secondaryToolbarBackgroundColor = UIColor(red: 0.11, green: 0.11, blue: 0.11, alpha: 1)

    /**
     :nodoc:
     */
    public override init() {
        super.init()

        /// Override inherited properties with default values
        self.title = nil
    }
}
