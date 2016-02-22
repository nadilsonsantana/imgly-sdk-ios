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
@property(nonatomic, copy) NSString *effectFilterIdentifier;
@property(nonatomic) CGFloat effectFilterIntensity;
@property(nonatomic) CGPoint focusNormalizedControlPoint1;
@property(nonatomic) CGPoint focusNormalizedControlPoint2;
@property(nonatomic) CGFloat focusBlurRadius;
@property(nonatomic) IMGLYFocusType focusType;
@property(nonatomic) CGRect normalizedCropRect;
@property(nonatomic) CGFloat saturation;
@property(nonatomic) CGFloat straightenAngle;

- (void)performChangesWithBlock:(void (^)())changesBlock;
- (void)copyValuesFromModel:(IMGLYPhotoEditModel *)photoEditModel;

NS_ASSUME_NONNULL_END

@end
