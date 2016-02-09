//
//  IMGLYPhotoEditMutableModel.h
//  imglyKit
//
//  Created by Sascha Schwabbauer on 05/02/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

#import "IMGLYPhotoEditModel.h"
#import "IMGLYPhotoEditModel+Private.h"

extern NSString * __nonnull const IMGLYPhotoEditModelDidChangeNotification;

@interface IMGLYPhotoEditMutableModel : IMGLYPhotoEditModel

NS_ASSUME_NONNULL_BEGIN

@property(nonatomic) CGRect normalizedCropRect;
@property(nonatomic) CGFloat brightness;
@property(nonatomic) CGFloat contrast;
@property(nonatomic) CGFloat saturation;

- (void)performChangesWithBlock:(void (^)())changesBlock;

NS_ASSUME_NONNULL_END

@end
