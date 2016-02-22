//
//  IMGLYPhotoEditModel.m
//  imglyKit
//
//  Created by Sascha Schwabbauer on 05/02/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

#import "IMGLYPhotoEditModel+Private.h"
#import "IMGLYPhotoEditModel.h"
#import "IMGLYPhotoEditMutableModel.h"

@implementation IMGLYPhotoEditModel

#pragma mark - Initializers

- (instancetype)init {
    if ((self = [super init])) {
        _appliedOrientation = IMGLYOrientationNormal;
        _autoEnhancementEnabled = false;
        _brightness = 0;
        _contrast = 1;
        _effectFilterIdentifier = @"None";
        _effectFilterIntensity = 0.75;
        _focusNormalizedControlPoint1 = CGPointZero;
        _focusNormalizedControlPoint2 = CGPointZero;
        _focusBlurRadius = 10;
        _focusType = IMGLYFocusTypeOff;
        _normalizedCropRect = [[self class] identityNormalizedCropRect];
        _saturation = 1;
        _straightenAngle = 0;
    }

    return self;
}

#pragma mark - Public API

+ (IMGLYOrientation)identityOrientation {
    return IMGLYOrientationNormal;
}

+ (CGRect)identityNormalizedCropRect {
    return CGRectMake(0, 0, 1, 1);
}

#pragma mark - Copying

- (void)_copyValuesFromModel:(IMGLYPhotoEditModel *)photoEditModel {
    _appliedOrientation = photoEditModel.appliedOrientation;
    _autoEnhancementEnabled = photoEditModel.isAutoEnhancementEnabled;
    _brightness = photoEditModel.brightness;
    _contrast = photoEditModel.contrast;
    _effectFilterIdentifier = photoEditModel.effectFilterIdentifier.copy;
    _effectFilterIntensity = photoEditModel.effectFilterIntensity;
    _focusNormalizedControlPoint1 = photoEditModel.focusNormalizedControlPoint1;
    _focusNormalizedControlPoint2 = photoEditModel.focusNormalizedControlPoint2;
    _focusBlurRadius = photoEditModel.focusBlurRadius;
    _focusType = photoEditModel.focusType;
    _normalizedCropRect = photoEditModel.normalizedCropRect;
    _saturation = photoEditModel.saturation;
    _straightenAngle = photoEditModel.straightenAngle;
}

#pragma mark - NSObject

- (id)mutableCopy {
    IMGLYPhotoEditMutableModel *photoEditMutableModel = [[IMGLYPhotoEditMutableModel alloc] init];
    [photoEditMutableModel _copyValuesFromModel:self];

    return photoEditMutableModel;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }

    if (![object isKindOfClass:IMGLYPhotoEditModel.class]) {
        return NO;
    }

    return [object isEqualToPhotoEditModel:self];
}

- (BOOL)isEqualToPhotoEditModel:(IMGLYPhotoEditModel *)photoEditModel {
    if (photoEditModel.appliedOrientation != self.appliedOrientation) {
        return NO;
    }

    if (photoEditModel.isAutoEnhancementEnabled != self.isAutoEnhancementEnabled) {
        return NO;
    }

    if (photoEditModel.brightness != self.brightness) {
        return NO;
    }

    if (photoEditModel.contrast != self.contrast) {
        return NO;
    }

    if (![photoEditModel.effectFilterIdentifier isEqualToString:self.effectFilterIdentifier]) {
        return NO;
    }

    if (photoEditModel.effectFilterIntensity != self.effectFilterIntensity) {
        return NO;
    }

    if (!CGPointEqualToPoint(photoEditModel.focusNormalizedControlPoint1, self.focusNormalizedControlPoint1)) {
        return NO;
    }

    if (!CGPointEqualToPoint(photoEditModel.focusNormalizedControlPoint2, self.focusNormalizedControlPoint2)) {
        return NO;
    }

    if (photoEditModel.focusBlurRadius != self.focusBlurRadius) {
        return NO;
    }

    if (photoEditModel.focusType != self.focusType) {
        return NO;
    }

    if (!CGRectEqualToRect(photoEditModel.normalizedCropRect, self.normalizedCropRect)) {
        return NO;
    }

    if (photoEditModel.saturation != self.saturation) {
        return NO;
    }

    if (photoEditModel.straightenAngle != self.straightenAngle) {
        return NO;
    }

    return YES;
}

#pragma mark - <NSCopying>

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

@end
