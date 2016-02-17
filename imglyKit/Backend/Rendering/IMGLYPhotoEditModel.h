//
//  IMGLYPhotoEditModel.h
//  imglyKit
//
//  Created by Sascha Schwabbauer on 05/02/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

@import Foundation;
@import CoreGraphics;

typedef NS_ENUM(NSInteger, IMGLYOrientation) {
    IMGLYOrientationUnknown,
    IMGLYOrientationNormal,
    IMGLYOrientationFlipX,
    IMGLYOrientationRotate180,
    IMGLYOrientationFlipY,
    IMGLYOrientationTranspose,
    IMGLYOrientationRotate90,
    IMGLYOrientationTransverse,
    IMGLYOrientationRotate270
};

@interface IMGLYPhotoEditModel : NSObject <NSCopying> {
  @protected
    IMGLYOrientation _appliedOrientation;
    BOOL _autoEnhancementEnabled;
    CGFloat _brightness;
    CGFloat _contrast;
    NSString *_effectFilterIdentifier;
    CGFloat _effectFilterIntensity;
    CGRect _normalizedCropRect;
    CGFloat _saturation;
    CGFloat _straightenAngle;
}

NS_ASSUME_NONNULL_BEGIN

/**
 *  The orientation of the image.
 */
@property(nonatomic, readonly) IMGLYOrientation appliedOrientation;

/**
 *  Enable auto enhancement.
 */
@property(nonatomic, readonly, getter=isAutoEnhancementEnabled) BOOL autoEnhancementEnabled;

/**
 *  The brightness of the image.
 */
@property(nonatomic, readonly) CGFloat brightness;

/**
 *  The contrast of the image.
 */
@property(nonatomic, readonly) CGFloat contrast;

/**
 *  The identifier of the effect filter to apply to the image.
 */
@property(nonatomic, readonly, copy) NSString *effectFilterIdentifier;

/**
 *  The intensity of the effect filter.
 */
@property(nonatomic, readonly) CGFloat effectFilterIntensity;

/**
 *  The normalized crop rect of the image.
 */
@property(nonatomic, readonly) CGRect normalizedCropRect;

/**
 *  The saturation of the image.
 */
@property(nonatomic, readonly) CGFloat saturation;

/**
 *  The straighten angle of the image.
 */
@property(nonatomic, readonly) CGFloat straightenAngle;

- (BOOL)isEqualToPhotoEditModel:(IMGLYPhotoEditModel *)photoEditModel;

+ (IMGLYOrientation)identityOrientation;
+ (CGRect)identityNormalizedCropRect;

NS_ASSUME_NONNULL_END

@end
