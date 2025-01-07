//
//  UIColor+OpenXml.m
//  Levé
//
//  Created by René BIGOT on 14/04/2014.
//  Copyright (c) 2014 René Bigot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NativeColor+OpenXML.h"

@implementation BRANativeColor (OpenXml)

+ (NSArray *)defaultIndexedColors {
    static dispatch_once_t pred;
    static NSArray *_defaultIndexedColors = nil;
    dispatch_once(&pred, ^{
      NSArray *hexVals = @[@"000000",@"FFFFFF",@"FF0000",@"00FF00",@"0000FF",
                           @"FFFF00",@"FF00FF",@"00FFFF",@"000000",@"FFFFFF",
                           @"FF0000",@"00FF00",@"0000FF",@"FFFF00",@"FF00FF",
                           @"00FFFF",@"800000",@"008000",@"000080",@"808000",
                           @"800080",@"008080",@"C0C0C0",@"808080",@"9999FF",
                           @"993366",@"FFFFCC",@"CCFFFF",@"660066",@"FF8080",
                           @"0066CC",@"CCCCFF",@"000080",@"FF00FF",@"FFFF00",
                           @"00FFFF",@"800080",@"800000",@"008080",@"0000FF",
                           @"00CCFF",@"CCFFFF",@"CCFFCC",@"FFFF99",@"99CCFF",
                           @"FF99CC",@"CC99FF",@"FFCC99",@"3366FF",@"33CCCC",
                           @"99CC00",@"FFCC00",@"FF9900",@"FF6600",@"666699",
                           @"969696",@"003366",@"339966",@"003300",@"333300",
                           @"993300",@"993366",@"333399",@"333333",@"000000",
                           @"FFFFFF"];
      
      NSMutableArray *defaultIndexedColors = [NSMutableArray new];
      for (NSString *hex in hexVals) {
        [defaultIndexedColors addObject:[BRANativeColor colorWithHexString:hex]];
      }
      _defaultIndexedColors = defaultIndexedColors;
      
    });
    
    return _defaultIndexedColors;
}

- (BRANativeColor *)colorWithTint:(CGFloat)tint {
    CGFloat r, g, b, a;
#if !TARGET_OS_OSX
    if (
#endif
        [self getRed:&r green:&g blue:&b alpha:&a]
#if TARGET_OS_OSX
        ;
#else
        ) {
#endif
        if (tint == 0) return self;
        
        if (tint > 0) {
            r += (1.0 - r) * tint;
            g += (1.0 - g) * tint;
            b += (1.0 - b) * tint;
        } else {
            r += r * tint;
            g += g * tint;
            b += b * tint;
        }
        
        return [BRANativeColor colorWithRed:MAX(MIN(r, 1.0), 0.0)
                               green:MAX(MIN(g, 1.0), 0.0)
                                blue:MAX(MIN(b, 1.0), 0.0)
                               alpha:a];
#if !TARGET_OS_OSX
    } else {
        // 对于不是基于RGB的颜色，直接返回原色
        return self;
    }
#endif
}

@end
