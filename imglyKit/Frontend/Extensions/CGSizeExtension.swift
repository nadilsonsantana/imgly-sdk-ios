//
//  CGSizeExtension.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 11/02/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import Foundation

func * (lhs: CGSize, rhs: CGFloat) -> CGSize {
    return CGSize(width: lhs.width * rhs, height: lhs.height * rhs)
}

func * (lhs: CGFloat, rhs: CGSize) -> CGSize {
    return CGSize(width: lhs * rhs.width, height: lhs * rhs.height)
}
