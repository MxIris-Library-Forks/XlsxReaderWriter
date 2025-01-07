//
//  BRANumberFormat.h
//  BRAXlsxReaderWriter
//
//  Created by René BIGOT on 08/10/2014.
//  Copyright (c) 2014 René Bigot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BRAOpenXmlSubElement.h"

@class BRAStyles;

typedef NS_ENUM(NSUInteger, BRAFormatCodeType) {
    kBRAFormatCodeTypeNone = 0,
    kBRAFormatCodeTypePercentage,
    kBRAFormatCodeTypeDateTime,
    kBRAFormatCodeTypeCurrency,
    kBRAFormatCodeTypeFraction,
    kBRAFormatCodeTypeNumber,
    kBRAFormatCodeTypeAccounting,
};

typedef struct {
    NSInteger numerator;
    NSInteger denominator;
    CGFloat error;
} BRAFraction;

typedef NS_ENUM(NSInteger, BRANegativeStyle) {
    BRANegativeStyleBlackWithMinusSign,
    BRANegativeStyleRedWithMinusSign,
    BRANegativeStyleRedWithoutMinusSign,
    BRANegativeStyleBlackWithoutMinusSignInBraces,
    BRANegativeStyleRedWithoutMinusSignInBraces,
} NS_SWIFT_NAME(NegativeStyle);
NS_ASSUME_NONNULL_BEGIN

@interface BRANumberFormatData : NSObject

- (instancetype)initWithCode:(NSString *)code;

@property (nonatomic) BOOL hasThousands;
@property (nonatomic) BOOL isScientific;
@property (nonatomic) NSInteger exponentLength;
@property (nonatomic) NSInteger minWidth;
@property (nonatomic) NSInteger decimals;
@property (nonatomic) NSInteger precision;
@property (nonatomic) BRAFormatCodeType type;
@property (nonatomic) CGFloat scale;
@property (nonatomic, copy, nullable) NSString *exponentSymbol;
@property (nonatomic, copy, nullable) NSString *code;
@property (nonatomic, copy, nullable) NSString *currency;
@property (nonatomic, copy, nullable) NSString *pattern;
@property (nonatomic, strong, nullable) BRANativeColor *color;
@property (nonatomic) BRANegativeStyle negativeStyle;
@end

@interface BRANumberFormat : BRAOpenXmlSubElement

@property (nonatomic, strong) BRANumberFormatData *cacheData;
@property (nonatomic, strong) NSArray<BRANumberFormatData *> *numberFormatParts;
@property (nonatomic, strong) NSString *formatCode;
@property (nonatomic, strong) NSString *formatId;

- (instancetype)initWithFormatCode:(NSString *)formatCode andId:(NSInteger)formatId;
- (NSAttributedString *)formatNumber:(CGFloat)number;

@end

NS_ASSUME_NONNULL_END
