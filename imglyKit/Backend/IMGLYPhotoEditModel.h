//
//  IMGLYPhotoEditModel.h
//  imglyKit
//
//  Created by Sascha Schwabbauer on 05/02/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

@import Foundation;
@import CoreGraphics;

@interface IMGLYPhotoEditModel : NSObject <NSCopying>

NS_ASSUME_NONNULL_BEGIN

@property(nonatomic, readonly, getter=isAutoEnhancementEnabled) BOOL autoEnhancementEnabled;
@property(nonatomic, readonly) CGRect normalizedCropRect;
@property(nonatomic, readonly) id appliedOrientation;
@property(nonatomic, readonly) CGFloat brightness;
@property(nonatomic, readonly) CGFloat contrast;
@property(nonatomic, readonly) CGFloat saturation;

NS_ASSUME_NONNULL_END

@end
