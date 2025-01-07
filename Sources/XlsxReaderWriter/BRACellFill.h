//
//  BRACellFill.h
//  BRAXlsxReaderWriter
//
//  Created by René BIGOT on 07/10/2014.
//  Copyright (c) 2014 René Bigot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BRAOpenXmlSubElement.h"

@class BRAStyles;

NS_ASSUME_NONNULL_BEGIN


typedef NSString * BRACellFillPatternType NS_TYPED_ENUM;
FOUNDATION_EXTERN const BRACellFillPatternType kBRACellFillPatternTypeNone          ;
FOUNDATION_EXTERN const BRACellFillPatternType kBRACellFillPatternTypeSolid         ;
FOUNDATION_EXTERN const BRACellFillPatternType kBRACellFillPatternTypeDarkGray      ;
FOUNDATION_EXTERN const BRACellFillPatternType kBRACellFillPatternTypeMediumGray    ;
FOUNDATION_EXTERN const BRACellFillPatternType kBRACellFillPatternTypeLightGray     ;
FOUNDATION_EXTERN const BRACellFillPatternType kBRACellFillPatternTypeGray125       ;
FOUNDATION_EXTERN const BRACellFillPatternType kBRACellFillPatternTypeGray0625      ;
FOUNDATION_EXTERN const BRACellFillPatternType kBRACellFillPatternTypeDarkHorizontal;
FOUNDATION_EXTERN const BRACellFillPatternType kBRACellFillPatternTypeDarkVertical  ;
FOUNDATION_EXTERN const BRACellFillPatternType kBRACellFillPatternTypeDarkDown      ;
FOUNDATION_EXTERN const BRACellFillPatternType kBRACellFillPatternTypeDarkUp        ;
FOUNDATION_EXTERN const BRACellFillPatternType kBRACellFillPatternTypeDarkGrid      ;
FOUNDATION_EXTERN const BRACellFillPatternType kBRACellFillPatternTypeDarkTrellis   ;
FOUNDATION_EXTERN const BRACellFillPatternType kBRACellFillPatternTypeLightHorizonta;
FOUNDATION_EXTERN const BRACellFillPatternType kBRACellFillPatternTypeLightVertical ;
FOUNDATION_EXTERN const BRACellFillPatternType kBRACellFillPatternTypeLightDown     ;
FOUNDATION_EXTERN const BRACellFillPatternType kBRACellFillPatternTypeLightUp       ;
FOUNDATION_EXTERN const BRACellFillPatternType kBRACellFillPatternTypeLightGrid     ;
FOUNDATION_EXTERN const BRACellFillPatternType kBRACellFillPatternTypeLightTrellis  ;


@interface BRACellFill : BRAOpenXmlSubElementWithStyle

- (instancetype)initWithForegroundColor:(BRANativeColor *)foregroundColor backgroundColor:(BRANativeColor *)backgroundColor andPatternType:(BRACellFillPatternType)patternType inStyles:(BRAStyles *)styles;
- (nullable BRANativeColor *)patternedColor;

@property (nonatomic, strong, nullable) BRANativeColor *backgroundColor;
@property (nonatomic, strong, nullable) BRANativeColor *foregroundColor;
@property (nonatomic, strong, nullable) BRACellFillPatternType patternType;

@end


NS_ASSUME_NONNULL_END
