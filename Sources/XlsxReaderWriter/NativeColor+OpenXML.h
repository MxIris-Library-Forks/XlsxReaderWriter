//
//  NativeColor+OpenXml.h
//  Levé
//
//  Created by René BIGOT on 14/04/2014.
//  Copyright (c) 2014 René Bigot. All rights reserved.
//

#import "BRAPlatformSpecificDefines.h"
#import "NativeColor+HTML.h"

@interface BRANativeColor (OpenXml)
@property (nonatomic, strong, readonly, class) NSArray<BRANativeColor *> *defaultIndexedColors;
- (BRANativeColor *)colorWithTint:(CGFloat)tint;
@end
