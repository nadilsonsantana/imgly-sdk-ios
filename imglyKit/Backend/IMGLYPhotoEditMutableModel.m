//
//  IMGLYPhotoEditMutableModel.m
//  imglyKit
//
//  Created by Sascha Schwabbauer on 05/02/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

#import "IMGLYPhotoEditMutableModel.h"

NSString * const IMGLYPhotoEditModelDidChangeNotification = @"IMGLYPhotoEditModelDidChangeNotification";

@interface IMGLYPhotoEditMutableModel () {
    NSInteger _transactionDepth;
}

@end

@implementation IMGLYPhotoEditMutableModel

@synthesize normalizedCropRect = _normalizedCropRect;
@synthesize brightness = _brightness;
@synthesize contrast = _contrast;
@synthesize saturation = _saturation;

#pragma mark - Changes

- (void)performChangesWithBlock:(void (^)())changesBlock {
    NSParameterAssert(changesBlock);

    _transactionDepth = _transactionDepth + 1;
    changesBlock();
    _transactionDepth = _transactionDepth - 1;

    if (_transactionDepth == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:IMGLYPhotoEditModelDidChangeNotification object:self userInfo:nil];
    }
}

#pragma mark - Accessors

- (void)setNormalizedCropRect:(CGRect)normalizedCropRect {
    if (!CGRectEqualToRect(_normalizedCropRect, normalizedCropRect)) {
        [self performChangesWithBlock:^{
            _normalizedCropRect = normalizedCropRect;
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

- (void)setSaturation:(CGFloat)saturation {
    if (_saturation != saturation) {
        [self performChangesWithBlock:^{
            _saturation = saturation;
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
