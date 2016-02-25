//
//  Options.h
//  imglyKit
//
//  Created by Sascha Schwabbauer on 19/02/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

typedef NS_ENUM(NSInteger, IMGLYFocusType) { IMGLYFocusTypeOff, IMGLYFocusTypeLinear, IMGLYFocusTypeRadial };

typedef NS_ENUM(NSInteger, IMGLYOrientation) {
    IMGLYOrientationNormal = 1,
    IMGLYOrientationFlipX,
    IMGLYOrientationRotate180,
    IMGLYOrientationFlipY,
    IMGLYOrientationTranspose,
    IMGLYOrientationRotate90,
    IMGLYOrientationTransverse,
    IMGLYOrientationRotate270
};
