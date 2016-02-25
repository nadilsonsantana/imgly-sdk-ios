//
//  Orientation.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 08/02/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import Foundation

extension IMGLYOrientation: CustomStringConvertible {
    public var description: String {
        switch self {
        case .Normal:
            return "Normal"
        case .FlipX:
            return "FlipX"
        case .Rotate180:
            return "Rotate180"
        case .FlipY:
            return "FlipY"
        case .Transpose:
            return "Transpose"
        case .Rotate90:
            return "Rotate90"
        case .Transverse:
            return "Transverse"
        case .Rotate270:
            return "Rotate270"
        }
    }

    public init(firstOrientation: IMGLYOrientation, secondOrientation: IMGLYOrientation) {
        switch firstOrientation {
        case .Normal:
            self = secondOrientation
        case .FlipX:
            switch secondOrientation {
            case .Normal:
                self = .FlipX
            case .FlipX:
                self = .Normal
            case .Rotate180:
                self = .FlipY
            case .FlipY:
                self = .Rotate180
            case .Transpose:
                self = .Rotate270
            case .Rotate90:
                self = .Transverse
            case .Transverse:
                self = .Rotate90
            case .Rotate270:
                self = .Transpose
            }
        case .Rotate180:
            switch secondOrientation {
            case .Normal:
                self = .Rotate180
            case .FlipX:
                self = .FlipY
            case .Rotate180:
                self = .Normal
            case .FlipY:
                self = .FlipX
            case .Transpose:
                self = .Transverse
            case .Rotate90:
                self = .Rotate270
            case .Transverse:
                self = .Transpose
            case .Rotate270:
                self = .Rotate90
            }
        case .FlipY:
            switch secondOrientation {
            case .Normal:
                self = .FlipY
            case .FlipX:
                self = .Rotate180
            case .Rotate180:
                self = .FlipX
            case .FlipY:
                self = .Normal
            case .Transpose:
                self = .Rotate90
            case .Rotate90:
                self = .Transpose
            case .Transverse:
                self = .Rotate270
            case .Rotate270:
                self = .Transverse
            }
        case .Transpose:
            switch secondOrientation {
            case .Normal:
                self = .Transpose
            case .FlipX:
                self = .Rotate90
            case .Rotate180:
                self = .Transverse
            case .FlipY:
                self = .Rotate270
            case .Transpose:
                self = .Normal
            case .Rotate90:
                self = .FlipX
            case .Transverse:
                self = .Rotate180
            case .Rotate270:
                self = .FlipY
            }
        case .Rotate90:
            switch secondOrientation {
            case .Normal:
                self = .Rotate90
            case .FlipX:
                self = .Transpose
            case .Rotate180:
                self = .Rotate270
            case .FlipY:
                self = .Transverse
            case .Transpose:
                self = .FlipY
            case .Rotate90:
                self = .Rotate180
            case .Transverse:
                self = .FlipX
            case .Rotate270:
                self = .Normal
            }
        case .Transverse:
            switch secondOrientation {
            case .Normal:
                self = .Transverse
            case .FlipX:
                self = .Rotate270
            case .Rotate180:
                self = .Transpose
            case .FlipY:
                self = .Rotate90
            case .Transpose:
                self = .Rotate180
            case .Rotate90:
                self = .FlipY
            case .Transverse:
                self = .Normal
            case .Rotate270:
                self = .FlipX
            }
        case .Rotate270:
            switch secondOrientation {
            case .Normal:
                self = .Rotate270
            case .FlipX:
                self = .Transverse
            case .Rotate180:
                self = .Rotate90
            case .FlipY:
                self = .Transpose
            case .Transpose:
                self = .FlipX
            case .Rotate90:
                self = .Normal
            case .Transverse:
                self = .FlipY
            case .Rotate270:
                self = .Rotate180
            }
        }
    }

    public var inverseOrientation: IMGLYOrientation {
        switch self {
        case .Normal:
            return .Normal
        case .FlipX:
            return .FlipX
        case .Rotate180:
            return .Rotate180
        case .FlipY:
            return .FlipY
        case .Transpose:
            return .Transverse
        case .Rotate90:
            return .Rotate270
        case .Transverse:
            return .Transpose
        case .Rotate270:
            return .Rotate90
        }
    }

    public func transformWithSize(size: CGSize) -> CGAffineTransform {
        switch self {
        case .Normal:
            return CGAffineTransformIdentity
        case .FlipX:
            return CGAffineTransform(a: -1, b: 0, c: 0, d: 1, tx: size.width, ty: 0)
        case .Rotate180:
            return CGAffineTransform(a: -1, b: 0, c: 0, d: -1, tx: size.width, ty: size.height)
        case .FlipY:
            return CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: size.height)
        case .Transpose:
            return CGAffineTransform(a: 0, b: 1, c: 1, d: 0, tx: 0, ty: 0)
        case .Rotate90:
            return CGAffineTransform(a: 0, b: -1, c: 1, d: 0, tx: 0, ty: size.width)
        case .Transverse:
            return CGAffineTransform(a: 0, b: -1, c: -1, d: 0, tx: size.height, ty: size.width)
        case .Rotate270:
            return CGAffineTransform(a: 0, b: 1, c: -1, d: 0, tx: size.height, ty: 0)
        }
    }
}
