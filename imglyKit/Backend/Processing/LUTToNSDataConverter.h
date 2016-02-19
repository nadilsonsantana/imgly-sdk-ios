//
//  LUTToNSDataConverter.h
//  imglyKit
//
//  Created by Carsten Przyluczky on 29/01/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>

@interface LUTToNSDataConverter : NSObject

- (nonnull instancetype)initWithIdentityLUTAtURL:(nonnull NSURL *)identityLUTURL NS_DESIGNATED_INITIALIZER;
- (nonnull instancetype)init NS_UNAVAILABLE;

@property(nonatomic, nullable, strong) NSURL *lutURL;
@property(nonatomic) float intensity;
@property(nonatomic, nullable, readonly) NSData *colorCubeData;

/*
 This method reads an LUT image and converts it to a cube color space representation.
 The resulting data can be used to feed an CIColorCube filter, so that the transformation
 realised by the LUT is applied with a core image standard filter
 */
+ (nullable NSData *)colorCubeDataFromLUTAtURL:(nonnull NSURL *)lutURL;

@end
