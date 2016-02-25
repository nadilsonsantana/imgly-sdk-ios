//
//  IMGLYPhotoEditModel.h
//  imglyKit
//
//  Created by Sascha Schwabbauer on 05/02/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

@import Foundation;
@import CoreGraphics;

#import "Enums.h"

@class IMGLYOverlay;

@interface IMGLYPhotoEditModel : NSObject <NSCopying> {
  @protected
    IMGLYOrientation _appliedOrientation;
    BOOL _autoEnhancementEnabled;
    CGFloat _brightness;
    CGFloat _contrast;
    NSString *_effectFilterIdentifier;
    CGFloat _effectFilterIntensity;
    CGPoint _focusNormalizedControlPoint1;
    CGPoint _focusNormalizedControlPoint2;
    CGFloat _focusBlurRadius;
    IMGLYFocusType _focusType;
    CGRect _normalizedCropRect;
    NSArray<IMGLYOverlay *> *_overlays;
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
 *  The first normalized control point of the focus. This control point should use the coordinate system of Core Image,
 * which means that (0,0) is at the top left.
 */
@property(nonatomic, readonly) CGPoint focusNormalizedControlPoint1;

/**
 *  The second normalized control point of the focus. This control point should use the coordinate system of Core Image,
 * which means that (0,0) is at the top left.
 */
@property(nonatomic, readonly) CGPoint focusNormalizedControlPoint2;

/**
 *  The blur radius to use for focus. Default is 10.
 */
@property(nonatomic, readonly) CGFloat focusBlurRadius;

/**
 *  The `IMGLYFocusType` to apply to the image.
 */
@property(nonatomic, readonly) IMGLYFocusType focusType;

/**
 *  The normalized crop rect of the image.
 */
@property(nonatomic, readonly) CGRect normalizedCropRect;

/**
 *  The overlays that should be added to the image.
 */
@property(nonatomic, readonly, copy) NSArray<IMGLYOverlay *> *overlays;

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
