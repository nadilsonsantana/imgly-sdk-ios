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
