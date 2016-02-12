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
    CGRect _normalizedCropRect;
    CGFloat _saturation;
    CGFloat _straightenAngle;
}

NS_ASSUME_NONNULL_BEGIN

@property(nonatomic, readonly) IMGLYOrientation appliedOrientation;
@property(nonatomic, readonly, getter=isAutoEnhancementEnabled) BOOL autoEnhancementEnabled;
@property(nonatomic, readonly) CGFloat brightness;
@property(nonatomic, readonly) CGFloat contrast;
@property(nonatomic, readonly) CGRect normalizedCropRect;
@property(nonatomic, readonly) CGFloat saturation;
@property(nonatomic, readonly) CGFloat straightenAngle;

- (BOOL)isEqualToPhotoEditModel:(IMGLYPhotoEditModel *)photoEditModel;
+ (IMGLYOrientation)identityOrientation;
+ (CGRect)identityNormalizedCropRect;

NS_ASSUME_NONNULL_END

@end
