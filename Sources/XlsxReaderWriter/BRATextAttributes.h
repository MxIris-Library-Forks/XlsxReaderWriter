//
//  BRATextAttributes.h
//  
//
//  Created by JH on 2024/3/25.
//

#import <Foundation/Foundation.h>
#import "BRAPlatformSpecificDefines.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRATextAttributes : NSObject
@property (nonatomic, strong, nullable) BRANativeColor *foregroundColor;
@property (nonatomic, strong, nullable) BRANativeColor *strikeColor;
@property (nonatomic, assign) BOOL hasStrike;
@property (nonatomic, assign) BOOL hasDoubleStrike;
@property (nonatomic, assign) BOOL hasUnderline;
@property (nonatomic, assign) BOOL hasBold;
@property (nonatomic, assign) BOOL hasItalic;
@property (nonatomic, assign) NSInteger fontSize;
@property (nonatomic, strong) NSString *fontName;
@end

NS_ASSUME_NONNULL_END
