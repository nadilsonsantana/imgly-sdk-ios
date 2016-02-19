//
//  CGPointExtension.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 19/02/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import Foundation

func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}

func * (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
    return CGPoint(x: lhs.x * rhs, y: lhs.y * rhs)
}

func * (lhs: CGFloat, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs * rhs.x, y: lhs * rhs.y)
}
