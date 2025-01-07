//
//  BRAStyles.h
//  BRAXlsxReaderWriter
//
//  Created by René BIGOT on 07/10/2014.
//  Copyright (c) 2014 René Bigot. All rights reserved.
//

#import "BRARelationship.h"
#import "BRACellFill.h"
#import "BRACellFormat.h"
#import "BRANumberFormat.h"
#import "BRATheme.h"
#import "BRAPlatformSpecificDefines.h"
#import "BRATextAttributes.h"
#import "BRACellBorder.h"

NS_ASSUME_NONNULL_BEGIN
@interface BRAStyles : BRARelationship {
    NSDictionary *_attributes;
}

@property (nonatomic, strong) NSArray<BRANativeColor *> *indexedColors;
@property (nonatomic, strong) NSArray<NSDictionary<NSAttributedStringKey, id> *> *textsAttributes;
@property (nonatomic, strong) NSArray<BRATextAttributes *> *rawTextsAttributes;
@property (nonatomic, strong) NSArray<BRACellFormat *> *cellFormats;
@property (nonatomic, strong) NSArray<BRACellFormat *> *cellStyleFormats;
@property (nonatomic, strong) NSArray<BRACellFill *> *cellFills;
@property (nonatomic, strong) NSArray<BRACellBorder *> *cellBorders;
@property (nonatomic, strong) NSDictionary<NSString *, BRANumberFormat *> *numberFormats;
@property (nonatomic, weak, nullable) BRATheme *theme;

- (void)loadThemableContent;
+ (NSDictionary<NSString *, BRANumberFormat *> *)defaultNumberFormats;
- (nullable NSDictionary<NSAttributedStringKey, id> *)attributedStringAttributesFromOpenXmlAttributes:(NSDictionary *)attributes;
- (nullable BRANativeColor *)colorWithOpenXmlAttributes:(NSDictionary *)attributes;
- (nullable NSDictionary<NSString *, BRANativeColor *> *)openXmlAttributesWithColor:(BRANativeColor *)color;
- (NSString *)addNumberFormat:(BRANumberFormat *)numberFormat;
- (NSInteger)addStyleByCopyingStyleWithId:(NSInteger)styleId;

@end
NS_ASSUME_NONNULL_END
