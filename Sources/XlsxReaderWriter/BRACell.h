//
//  BRACell.h
//  BRAXlsxReaderWriter
//
//  Created by René BIGOT on 17/10/2014.
//  Copyright (c) 2014 René Bigot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BRAOpenXmlSubElement.h"
#import "BRACellFill.h"

@class BRAMergeCell, BRACellFormat, BRARow, BRAImage;

typedef NS_ENUM(NSUInteger, BRACellContentType) {
    BRACellContentTypeBoolean,
    BRACellContentTypeDate,
    BRACellContentTypeError,
    BRACellContentTypeInlineString,
    BRACellContentTypeNumber,
    BRACellContentTypeSharedString,
    BRACellContentTypeString,
    BRACellContentTypeUnknown
};

NS_ASSUME_NONNULL_BEGIN

@interface BRACell : BRAOpenXmlSubElementWithWorksheet
@property (nonatomic, copy) NSString *reference;
//@property (nonatomic, strong, nullable) BRAMergeCell *mergeCell;
@property (nonatomic) NSInteger styleId;
@property (nonatomic) NSInteger sharedStringIndex;
@property (nonatomic) BRACellContentType type;
@property (nonatomic, getter=hasError) BOOL error;
@property (nonatomic, copy, nullable) NSString *value;
@property (nonatomic) BOOL hasStyle;
@property (nonatomic) BOOL hasType;
@property (nonatomic) BOOL hasValue;
@property (nonatomic) BOOL hasNumberFormat;
//General
+ (NSString *)cellReferenceForColumnIndex:(NSInteger)columnIndex andRowIndex:(NSInteger)rowIndex;
- (instancetype)initWithReference:(NSString *)reference andStyleId:(NSInteger)styleId inWorksheet:(BRAWorksheet *)worksheet;
- (NSInteger)columnIndex;
- (NSString *)columnName;
- (NSInteger)rowIndex;

//Styles
- (void)setNumberFormat:(NSString *)numberFormat;
- (void)setCellFillWithForegroundColor:(BRANativeColor *)foregroundColor backgroundColor:(BRANativeColor *)backgroundColor andPatternType:(BRACellFillPatternType)patternType;
- (void)setCellFill:(nullable BRACellFill *)cellFill;
- (void)setTextAlignment:(NSTextAlignment)alignment;
- (nullable BRACellFill *)cellFill;
- (BRANativeColor *)cellFillColor;
- (nullable NSString *)numberFormatCode;
- (NSTextAlignment)textAlignment;

//Cell content setters
- (void)setBoolValue:(BOOL)boolValue;
- (void)setIntegerValue:(NSInteger)integerValue;
- (void)setFloatValue:(float)floatValue;
- (void)setStringValue:(NSString *)stringValue;
- (void)setAttributedStringValue:(NSAttributedString *)attributedStringValue;
- (void)setDateValue:(NSDate *)date;
- (void)setFormulaString:(NSString *)formulaString;
- (void)setErrorValue:(NSString *)errorValue;

//Cell content getters
- (BOOL)boolValue;
- (NSInteger)integerValue;
- (float)floatValue;
- (NSString *)stringValue;
- (NSAttributedString *)attributedStringValue;
- (nullable NSDate *)dateValue;
- (nullable NSString *)formulaString;
- (nullable NSString *)errorValue;





@end

NS_ASSUME_NONNULL_END
