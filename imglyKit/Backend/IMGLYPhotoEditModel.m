//
//  IMGLYPhotoEditModel.m
//  imglyKit
//
//  Created by Sascha Schwabbauer on 05/02/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

#import "IMGLYPhotoEditModel.h"
#import "IMGLYPhotoEditModel+Private.h"
#import "IMGLYPhotoEditMutableModel.h"

@implementation IMGLYPhotoEditModel

#pragma mark - Initializers

- (instancetype)init {
    if ((self = [super init])) {
        _normalizedCropRect = CGRectZero;
        _brightness = 0;
        _contrast = 1;
        _saturation = 1;
    }

    return self;
}

#pragma mark - Copying

- (void)_copyValuesFromModel:(IMGLYPhotoEditModel *)photoEditModel {
    _normalizedCropRect = photoEditModel.normalizedCropRect;
    _brightness = photoEditModel.brightness;
    _contrast = photoEditModel.contrast;
    _saturation = photoEditModel.saturation;
}

#pragma mark - NSObject

- (id)mutableCopy {
    IMGLYPhotoEditMutableModel *photoEditMutableModel = [[IMGLYPhotoEditMutableModel alloc] init];
    [photoEditMutableModel _copyValuesFromModel:self];

    return photoEditMutableModel;
}

#pragma mark - <NSCopying>

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

@end
