//
//  IMGLYPhotoEditMutableModel.m
//  imglyKit
//
//  Created by Sascha Schwabbauer on 05/02/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

#import "IMGLYPhotoEditModel+Private.h"
#import "IMGLYPhotoEditMutableModel.h"

NSString *const IMGLYPhotoEditModelDidChangeNotification = @"IMGLYPhotoEditModelDidChangeNotification";

@interface IMGLYPhotoEditMutableModel () {
    NSInteger _transactionDepth;
}

@end

@implementation IMGLYPhotoEditMutableModel

@dynamic appliedOrientation;
@dynamic autoEnhancementEnabled;
@dynamic brightness;
@dynamic contrast;
@dynamic effectFilterIdentifier;
@dynamic effectFilterIntensity;
@dynamic focusNormalizedControlPoint1;
@dynamic focusNormalizedControlPoint2;
@dynamic focusBlurRadius;
@dynamic focusType;
@dynamic normalizedCropRect;
@dynamic saturation;
@dynamic straightenAngle;

#pragma mark - Changes

- (void)performChangesWithBlock:(void (^)())changesBlock {
    NSParameterAssert(changesBlock);

    _transactionDepth = _transactionDepth + 1;
    changesBlock();
    _transactionDepth = _transactionDepth - 1;

    if (_transactionDepth == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:IMGLYPhotoEditModelDidChangeNotification
                                                            object:self
                                                          userInfo:nil];
    }
}

- (void)copyValuesFromModel:(IMGLYPhotoEditModel *)photoEditModel {
    [self performChangesWithBlock:^{
      [self _copyValuesFromModel:photoEditModel];
    }];
}

#pragma mark - Accessors

- (void)setAppliedOrientation:(IMGLYOrientation)appliedOrientation {
    if (_appliedOrientation != appliedOrientation) {
        [self performChangesWithBlock:^{
          _appliedOrientation = appliedOrientation;
        }];
    }
}

- (void)setAutoEnhancementEnabled:(BOOL)autoEnhancementEnabled {
    if (_autoEnhancementEnabled != autoEnhancementEnabled) {
        [self performChangesWithBlock:^{
          _autoEnhancementEnabled = autoEnhancementEnabled;
        }];
    }
}

- (void)setBrightness:(CGFloat)brightness {
    if (_brightness != brightness) {
        [self performChangesWithBlock:^{
          _brightness = brightness;
        }];
    }
}

- (void)setContrast:(CGFloat)contrast {
    if (_contrast != contrast) {
        [self performChangesWithBlock:^{
          _contrast = contrast;
        }];
    }
}

- (void)setEffectFilterIdentifier:(NSString *)effectFilterIdentifier {
    if (![_effectFilterIdentifier isEqualToString:effectFilterIdentifier]) {
        [self performChangesWithBlock:^{
          _effectFilterIdentifier = effectFilterIdentifier.copy;
        }];
    }
}

- (void)setEffectFilterIntensity:(CGFloat)effectFilterIntensity {
    if (_effectFilterIntensity != effectFilterIntensity) {
        [self performChangesWithBlock:^{
          _effectFilterIntensity = effectFilterIntensity;
        }];
    }
}

- (void)setFocusNormalizedControlPoint1:(CGPoint)focusNormalizedControlPoint1 {
    if (!CGPointEqualToPoint(_focusNormalizedControlPoint1, focusNormalizedControlPoint1)) {
        [self performChangesWithBlock:^{
          _focusNormalizedControlPoint1 = focusNormalizedControlPoint1;
        }];
    }
}

- (void)setFocusNormalizedControlPoint2:(CGPoint)focusNormalizedControlPoint2 {
    if (!CGPointEqualToPoint(_focusNormalizedControlPoint2, focusNormalizedControlPoint2)) {
        [self performChangesWithBlock:^{
          _focusNormalizedControlPoint2 = focusNormalizedControlPoint2;
        }];
    }
}

- (void)setFocusBlurRadius:(CGFloat)focusBlurRadius {
    if (_focusBlurRadius != focusBlurRadius) {
        [self performChangesWithBlock:^{
          _focusBlurRadius = focusBlurRadius;
        }];
    }
}

- (void)setFocusType:(IMGLYFocusType)focusType {
    if (_focusType != focusType) {
        [self performChangesWithBlock:^{
          _focusType = focusType;
        }];
    }
}

- (void)setNormalizedCropRect:(CGRect)normalizedCropRect {
    if (!CGRectEqualToRect(_normalizedCropRect, normalizedCropRect)) {
        [self performChangesWithBlock:^{
          _normalizedCropRect = normalizedCropRect;
        }];
    }
}

- (void)setSaturation:(CGFloat)saturation {
    if (_saturation != saturation) {
        [self performChangesWithBlock:^{
          _saturation = saturation;
        }];
    }
}

- (void)setStraightenAngle:(CGFloat)straightenAngle {
    if (_straightenAngle != straightenAngle) {
        [self performChangesWithBlock:^{
          _straightenAngle = straightenAngle;
        }];
    }
}

#pragma mark - NSObject

- (id)copyWithZone:(NSZone *)zone {
    IMGLYPhotoEditModel *photoEditModel = [[IMGLYPhotoEditModel alloc] init];
    [photoEditModel _copyValuesFromModel:self];

    return photoEditModel;
}

@end
