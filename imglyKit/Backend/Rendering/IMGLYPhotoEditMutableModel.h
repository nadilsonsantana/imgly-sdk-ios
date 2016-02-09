//
//  IMGLYPhotoEditMutableModel.h
//  imglyKit
//
//  Created by Sascha Schwabbauer on 05/02/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

#import "IMGLYPhotoEditModel.h"

extern NSString *__nonnull const IMGLYPhotoEditModelDidChangeNotification;

@interface IMGLYPhotoEditMutableModel : IMGLYPhotoEditModel

NS_ASSUME_NONNULL_BEGIN

@property(nonatomic) IMGLYOrientation appliedOrientation;
@property(nonatomic, getter=isAutoEnhancementEnabled) BOOL autoEnhancementEnabled;
@property(nonatomic) CGFloat brightness;
@property(nonatomic) CGFloat contrast;
@property(nonatomic) CGRect normalizedCropRect;
@property(nonatomic) CGFloat saturation;
@property(nonatomic) CGFloat straightenAngle;

- (void)performChangesWithBlock:(void (^)())changesBlock;

NS_ASSUME_NONNULL_END

@end
