//
//  IMGLYRenderMode.h
//  imglyKit
//
//  Created by Sascha Schwabbauer on 08/02/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

typedef NS_OPTIONS(NSUInteger, IMGLYRenderMode) {
    IMGLYRenderModeNone = 0,
    IMGLYRenderModeAutoEnhancement = 1 << 0,
    IMGLYRenderModeOrientationCrop = 1 << 1,
    IMGLYRenderModeFocus = 1 << 2,
    IMGLYRenderModePhotoEffect = 1 << 3,
    IMGLYRenderModeColorAdjustments = 1 << 4,
    IMGLYRenderModeOverlays = 1 << 5,
    IMGLYRenderModeAll = IMGLYRenderModeAutoEnhancement | IMGLYRenderModeOrientationCrop | IMGLYRenderModeFocus |
                         IMGLYRenderModePhotoEffect | IMGLYRenderModeColorAdjustments | IMGLYRenderModeOverlays
};
