//
//  GradientView.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 18/02/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import UIKit

@objc(IMGLYGradientView) public class GradientView: UIView {

    // MARK: - Properties

    let topColor: UIColor
    let bottomColor: UIColor

    // MARK: - Initializers

    public init(topColor: UIColor, bottomColor: UIColor) {
        self.topColor = topColor
        self.bottomColor = bottomColor
        super.init(frame: CGRect.zero)
        opaque = false
    }

    required public init?(coder aDecoder: NSCoder) {
        self.topColor = UIColor.clearColor()
        self.bottomColor = UIColor.blackColor()
        super.init(frame: CGRect.zero)
        opaque = false
    }

    // MARK: - UIView

    public override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        let gradient = CGGradientCreateWithColors(CGColorSpaceCreateDeviceRGB(), [topColor.CGColor, bottomColor.CGColor], [0, 1])
        CGContextDrawLinearGradient(context, gradient, CGPoint(x: bounds.midX, y: bounds.minY), CGPoint(x: bounds.midX, y: bounds.maxY), [])
    }

}
