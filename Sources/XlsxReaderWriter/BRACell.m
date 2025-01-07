//
//  BRACell.m
//  BRAXlsxReaderWriter
//
//  Created by René BIGOT on 17/10/2014.
//  Copyright (c) 2014 René Bigot. All rights reserved.
//

#import "BRACell.h"
#import "BRAColumn.h"
#import "BRARow.h"
#import "BRAImage.h"
#import "BRAWorksheet.h"
#import "BRADrawing.h"
#import "BRACellFormat.h"
#import "NSArray+Sugar.h"

@interface BRACell () {
    NSDate *_dateValue;
    NSString *_formulaString;
    NSString *_inlineString;
}
@end

@implementation BRACell

+ (NSString *)cellReferenceForColumnIndex:(NSInteger)columnIndex andRowIndex:(NSInteger)rowIndex {
    return [NSString stringWithFormat:@"%@%ld", [BRAColumn columnNameForColumnIndex:columnIndex], (long)rowIndex];
}

- (instancetype)initWithReference:(NSString *)reference andStyleId:(NSInteger)styleId inWorksheet:(BRAWorksheet *)worksheet {
    NSMutableDictionary *openXmlAttributes = @{
        @"_r": reference,
    }.mutableCopy;
    if (styleId > 0) {
        openXmlAttributes[@"_s"] = [NSString stringWithFormat:@"%ld", (long)styleId];
    }
    
    self = [super initWithOpenXmlAttributes:openXmlAttributes inWorksheet:worksheet];
    
    return self;
}

- (void)loadAttributes {
    NSDictionary *dictionaryRepresentation = [super dictionaryRepresentation];
    
    _reference = dictionaryRepresentation.attributes[@"r"];
    
    if (dictionaryRepresentation.attributes[@"s"]) {
        _styleId = [dictionaryRepresentation.attributes[@"s"] integerValue];
    }
    _hasStyle = dictionaryRepresentation.attributes[@"s"] != nil;
    _hasType = dictionaryRepresentation.attributes[@"t"] != nil;
    _hasValue = dictionaryRepresentation[@"v"] != nil;
    //Check cell type
    if (dictionaryRepresentation.attributes[@"t"]) {
        
        NSString *cellType = dictionaryRepresentation.attributes[@"t"];
        
        //Boolean
        if ([cellType isEqual:@"b"]) {
            _type = BRACellContentTypeBoolean;
            [self setStringValueForAttributes:dictionaryRepresentation[@"v"]];
            [self setFormulaStringForAttributes:dictionaryRepresentation[@"f"]];
        }
        
        //Date
        else if ([cellType isEqual:@"d"]) {
            _type = BRACellContentTypeDate;
            [self setFormulaStringForAttributes:dictionaryRepresentation[@"f"]];
            // TODO
        }
        
        //Error
        else if ([cellType isEqual:@"e"]) {
            _type = BRACellContentTypeError;
            _error = YES;
            [self setFormulaStringForAttributes:dictionaryRepresentation[@"f"]];
            [self setStringValueForAttributes:dictionaryRepresentation[@"v"]];
        }
        
        //Inline String
        else if ([cellType isEqual:@"inlineStr"]) {
            _type = BRACellContentTypeInlineString;
            [self setFormulaStringForAttributes:dictionaryRepresentation[@"f"]];
            [self setStringValueForAttributes:[dictionaryRepresentation valueForKeyPath:@"is.t"]];
            // TODO
        }
        
        //Number
        else if ([cellType isEqual:@"n"]) {
            _type = BRACellContentTypeNumber;
            [self setFormulaStringForAttributes:dictionaryRepresentation[@"f"]];
            [self setStringValueForAttributes:dictionaryRepresentation[@"v"]];
        }
        
        //Shared String
        else if ([cellType isEqual:@"s"]) {
            _type = BRACellContentTypeSharedString;
            [self setFormulaStringForAttributes:dictionaryRepresentation[@"f"]];
            _sharedStringIndex = [dictionaryRepresentation[@"v"] integerValue];
            [self setStringValueForAttributes:dictionaryRepresentation[@"v"]];
        }
        
        //Formula string
        else if ([cellType isEqual:@"str"]) {
            _type = BRACellContentTypeString;
            [self setFormulaStringForAttributes:dictionaryRepresentation[@"f"]];
            [self setStringValueForAttributes:dictionaryRepresentation[@"v"]];
        }
    }
    
    //Unknown
    else {
        //then read raw value
        _type = BRACellContentTypeUnknown;
        [self setStringValueForAttributes:dictionaryRepresentation[@"v"]];
        [self setFormulaStringForAttributes:dictionaryRepresentation[@"f"]];
    }
    
    super.dictionaryRepresentation = nil;
    
}

- (void)setFormulaStringForAttributes:(id)maybeFormulaString {
    if ([maybeFormulaString isKindOfClass:[NSString class]]) {
        _formulaString = maybeFormulaString;
    }
}

- (void)setStringValueForAttributes:(id)maybeStringValue {
    if ([maybeStringValue isKindOfClass:[NSString class]]) {
        _value = maybeStringValue;
    }
}

- (NSInteger)columnIndex {
    return [BRAColumn columnIndexForCellReference:_reference];
}

- (NSString *)columnName {
    return [BRAColumn columnNameForColumnIndex:[self columnIndex]];
}


- (NSInteger)rowIndex {
    return [BRARow rowIndexForCellReference:_reference];
}

#pragma mark - Styles

- (void)setNumberFormat:(NSString *)numberFormatCode {
    if (numberFormatCode == nil) {
        numberFormatCode = @"@";
    }
    
    BRANumberFormat *numberFormat = [[BRANumberFormat alloc] initWithFormatCode:numberFormatCode andId:NSNotFound];
    
    _styleId = [self.worksheet.styles addStyleByCopyingStyleWithId:_styleId];
    [(BRACellFormat *)self.worksheet.styles.cellFormats[_styleId] setNumberFormat:numberFormat];
}

- (void)setCellFillWithForegroundColor:(BRANativeColor *)foregroundColor backgroundColor:(BRANativeColor *)backgroundColor andPatternType:(BRACellFillPatternType)patternType {
    BRACellFill *cellFill = [[BRACellFill alloc] initWithForegroundColor:foregroundColor backgroundColor:backgroundColor andPatternType:patternType inStyles:self.worksheet.styles];
    
    _styleId = [self.worksheet.styles addStyleByCopyingStyleWithId:_styleId];
    [(BRACellFormat *)self.worksheet.styles.cellFormats[_styleId] setCellFill:cellFill];
}

- (void)setCellFill:(BRACellFill *)cellFill {
    _styleId = [self.worksheet.styles addStyleByCopyingStyleWithId:_styleId];
    [(BRACellFormat *)self.worksheet.styles.cellFormats[_styleId] setCellFill:cellFill];
}

- (void)setTextAlignment:(NSTextAlignment)alignment {
    _styleId = [self.worksheet.styles addStyleByCopyingStyleWithId:_styleId];
    [(BRACellFormat *)self.worksheet.styles.cellFormats[_styleId] setTextHorizontalAlignment:alignment];
}

- (BRANativeColor *)cellFillColor {
    BRANativeColor *cellFillColor = [(BRACellFormat *)self.worksheet.styles.cellFormats[_styleId] cellFill].patternedColor;
    return cellFillColor ? cellFillColor : [BRANativeColor clearColor];
}

- (BRACellFill *)cellFill {
    return [self.worksheet.styles.cellFormats[_styleId] cellFill];
}

- (NSString *)numberFormatCode {
    return [(BRACellFormat *)self.worksheet.styles.cellFormats[_styleId] numberFormat].formatCode;
}

- (NSTextAlignment)textAlignment {
    return [(BRACellFormat *)self.worksheet.styles.cellFormats[_styleId] textHorizontalAlignment];
}

#pragma mark - Cell content setters

- (void)setBoolValue:(BOOL)boolValue {
    _type = BRACellContentTypeBoolean;
    _value = boolValue ? @"1" : @"0";
    _sharedStringIndex = 0;
    _dateValue = nil;
    _error = NO;
}

- (void)setIntegerValue:(NSInteger)integerValue {
    _type = BRACellContentTypeNumber;
    _value = [NSString stringWithFormat:@"%ld", (long)integerValue];
    _sharedStringIndex = 0;
    _dateValue = nil;
    _error = NO;
}

- (void)setFloatValue:(float)floatValue {
    _type = BRACellContentTypeNumber;
    _value = [NSString stringWithFormat:@"%f", floatValue];
    _sharedStringIndex = 0;
    _dateValue = nil;
    _error = NO;
    
    BRACellFormat *cellFormat = self.worksheet.styles.cellFormats[_styleId];
    if (!cellFormat.numberFormat || [cellFormat.numberFormat.formatCode isEqual:@"@"]) {
        [self setNumberFormat:@"0"];
    }
}

- (void)setStringValue:(NSString *)stringValue {
    if (stringValue == nil) {
        return;
    }
    
    BRASharedString *sharedString = [[BRASharedString alloc] initWithAttributedString:[[NSAttributedString alloc] initWithString:stringValue]
                                                                             inStyles:self.worksheet.styles];
    [self.worksheet.sharedStrings addSharedString:sharedString];
    _type = BRACellContentTypeSharedString;
    _value = nil;
    _sharedStringIndex = [self.worksheet.sharedStrings.sharedStrings indexOfObject:sharedString];
    _dateValue = nil;
    _error = NO;
}

- (void)setAttributedStringValue:(NSAttributedString *)attributedStringValue {
    if (attributedStringValue == nil) {
        return;
    }
    
    BRASharedString *sharedString = [[BRASharedString alloc] initWithAttributedString:attributedStringValue
                                                                             inStyles:self.worksheet.styles];
    [self.worksheet.sharedStrings addSharedString:sharedString];
    _type = BRACellContentTypeSharedString;
    _value = nil;
    _sharedStringIndex = [self.worksheet.sharedStrings.sharedStrings indexOfObject:sharedString];
    _dateValue = nil;
    _error = NO;
}

- (void)setDateValue:(NSDate *)date {
    if (date == nil) {
        return;
    }
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
    _type = BRACellContentTypeDate;
    _value = [df stringFromDate:date];
    _sharedStringIndex = 0;
    _dateValue = nil;
    _error = NO;
}

- (void)setFormulaString:(NSString *)formulaString {
    if (formulaString == nil) {
        return;
    }
    
    _type = BRACellContentTypeString;
    _formulaString = formulaString;
}

- (void)setErrorValue:(NSString *)errorValue {
    if (errorValue == nil) {
        return;
    }
    
    _error = YES;
    _type = BRACellContentTypeError;
    _value = errorValue;
}

#pragma mark - Cell content getters

- (BOOL)boolValue {
    if (_type == BRACellContentTypeBoolean) {
        return [_value boolValue];
    } else if (_type == BRACellContentTypeNumber) {
        return [_value floatValue] != 0;
    }
    
    return [_value floatValue] != 0;
}

- (NSInteger)integerValue {
    if (_type == BRACellContentTypeBoolean) {
        return [_value boolValue];
    } else if (_type == BRACellContentTypeNumber) {
        return [_value integerValue];
    }
    
    return [[self stringValue] integerValue];
}

- (float)floatValue {
    if (_type == BRACellContentTypeBoolean) {
        return [_value boolValue];
    } else if (_type == BRACellContentTypeNumber || _type == BRACellContentTypeUnknown) {
        return [_value floatValue];
    }
    
    return [[self stringValue] floatValue];
}

- (NSString *)stringValue {
    return [[self attributedStringValue] string];
}

- (NSAttributedString *)attributedStringValue {
    NSMutableDictionary *attributedTextAttributes = self.worksheet.styles.cellFormats[_styleId].textAttributes.mutableCopy;
    if (attributedTextAttributes == nil) {
        attributedTextAttributes = @{}.mutableCopy;
    }
    
    if (_type == BRACellContentTypeBoolean) {
        return [[NSAttributedString alloc] initWithString:[_value boolValue] ? @"TRUE" : @"FALSE" attributes:attributedTextAttributes];
        
    } else if (_type == BRACellContentTypeError) {
        return [[NSAttributedString alloc] initWithString:_value attributes:attributedTextAttributes];
        
    } else if (_type == BRACellContentTypeDate) {
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        //Get localized date format from system
        df.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"dMYhms" options:0 locale:[NSLocale currentLocale]];
        return [[NSAttributedString alloc] initWithString:[df stringFromDate:_dateValue] attributes:attributedTextAttributes];
        
    } else if (_type == BRACellContentTypeString) {
        if (_value) {
            return [[NSAttributedString alloc] initWithString:_value attributes:attributedTextAttributes];
        }
        
    } else if (_type == BRACellContentTypeInlineString) {
        
        return [[NSAttributedString alloc] initWithString:_value ? : @"" attributes:attributedTextAttributes];
        
    } else if (_type == BRACellContentTypeNumber || _type == BRACellContentTypeUnknown) {
        BRACellFormat *cellFormat = self.worksheet.styles.cellFormats[_styleId];
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@""];
        if (_value) {
            BRANumberFormat *numberFormat = cellFormat.numberFormat;
            if (numberFormat) {
                attributedString = [numberFormat formatNumber:[_value doubleValue]].mutableCopy;
            } else {
                attributedString = [[NSMutableAttributedString alloc] initWithString:_value];
            }
        }
        [attributedString addAttributes:attributedTextAttributes range:NSMakeRange(0, attributedString.length)];
        return attributedString;
    } else if (_type == BRACellContentTypeSharedString) {
        NSMutableAttributedString *attributedString = [self.worksheet.sharedStrings.sharedStrings BRA_objectAtSafeIndex:_sharedStringIndex].attributedString.mutableCopy;
        if (attributedString) {
            [attributedString beginEditing];
            
            [attributedString enumerateAttributesInRange:NSMakeRange(0, attributedString.length) options:0 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
                if (attributedTextAttributes[NSForegroundColorAttributeName] && !attrs[NSForegroundColorAttributeName]) {
                    [attributedString addAttributes:@{NSForegroundColorAttributeName: attributedTextAttributes[NSForegroundColorAttributeName]}
                                              range:range];
                }
                
                if (attributedTextAttributes[NSFontAttributeName] && !attrs[NSFontAttributeName]) {
                    [attributedString addAttributes:@{NSFontAttributeName: attributedTextAttributes[NSFontAttributeName]}
                                              range:range];
                }
                
                if (attributedTextAttributes[NSUnderlineStyleAttributeName] && !attrs[NSUnderlineStyleAttributeName]) {
                    [attributedString addAttributes:@{NSUnderlineStyleAttributeName: attributedTextAttributes[NSUnderlineStyleAttributeName]}
                                              range:range];
                }
                
                if (attributedTextAttributes[NSParagraphStyleAttributeName] && !attrs[NSParagraphStyleAttributeName]) {
                    [attributedString addAttributes:@{NSParagraphStyleAttributeName: attributedTextAttributes[NSParagraphStyleAttributeName]}
                                              range:range];
                }
                
            }];
            
            [attributedString endEditing];
            
            return attributedString;
        }
    }
    
    return [[NSAttributedString alloc] initWithString:@"" attributes:attributedTextAttributes];
}

- (NSDate *)dateValue {
    if (_type == BRACellContentTypeDate) {
        return _dateValue;
    }
    
    return nil;
}

- (NSString *)formulaString {
    return _formulaString;
}

- (NSString *)errorValue {
    if (_error) {
        return _value;
    }
    
    return nil;
}

#pragma mark -

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dictionaryRepresentation = [super dictionaryRepresentation].mutableCopy;
    
    dictionaryRepresentation[@"_r"] = _reference;
    
    if (_type == BRACellContentTypeBoolean) {
        dictionaryRepresentation[@"_t"] = @"b";
        if (_formulaString) {
            dictionaryRepresentation[@"f"] = _formulaString;
        } else {
            [dictionaryRepresentation removeObjectForKey:@"f"];
        }
        
        if (_value) {
            dictionaryRepresentation[@"v"] = _value;
        } else {
            [dictionaryRepresentation removeObjectForKey:@"v"];
        }
        
    } else if (_type == BRACellContentTypeDate) {
        dictionaryRepresentation[@"_t"] = @"d";
        if (_formulaString) {
            dictionaryRepresentation[@"f"] = _formulaString;
        } else {
            [dictionaryRepresentation removeObjectForKey:@"f"];
        }
        
        if (_value) {
            dictionaryRepresentation[@"v"] = _value;
        } else {
            [dictionaryRepresentation removeObjectForKey:@"v"];
        }
        
    } else if (_type == BRACellContentTypeError) {
        dictionaryRepresentation[@"_t"] = @"e";
        if (_formulaString) {
            dictionaryRepresentation[@"f"] = _formulaString;
        } else {
            [dictionaryRepresentation removeObjectForKey:@"f"];
        }
        
        if (_value) {
            dictionaryRepresentation[@"v"] = _value;
        } else {
            [dictionaryRepresentation removeObjectForKey:@"v"];
        }
        
    } else if (_type == BRACellContentTypeInlineString) {
        dictionaryRepresentation[@"_t"] = @"inlineStr";
        if (_formulaString) {
            dictionaryRepresentation[@"f"] = _formulaString;
        } else {
            [dictionaryRepresentation removeObjectForKey:@"f"];
        }
        
        // TODO : inlineStr
        
    } else if (_type == BRACellContentTypeNumber) {
        dictionaryRepresentation[@"_t"] = @"n";
        if (_formulaString) {
            dictionaryRepresentation[@"f"] = _formulaString;
        } else {
            [dictionaryRepresentation removeObjectForKey:@"f"];
        }
        
        if (_value) {
            dictionaryRepresentation[@"v"] = _value;
        } else {
            [dictionaryRepresentation removeObjectForKey:@"v"];
        }
        
    } else if (_type == BRACellContentTypeSharedString) {
        dictionaryRepresentation[@"_t"] = @"s";
        if (_formulaString) {
            dictionaryRepresentation[@"f"] = _formulaString;
        } else {
            [dictionaryRepresentation removeObjectForKey:@"f"];
        }
        
        dictionaryRepresentation[@"v"] = [NSString stringWithFormat:@"%ld", (long)_sharedStringIndex];
        
    } else if (_type == BRACellContentTypeString) {
        dictionaryRepresentation[@"_t"] = @"str";
        if (_formulaString) {
            dictionaryRepresentation[@"f"] = _formulaString;
        } else {
            [dictionaryRepresentation removeObjectForKey:@"f"];
        }
        
        if (_value) {
            dictionaryRepresentation[@"v"] = _value;
        } else {
            [dictionaryRepresentation removeObjectForKey:@"v"];
        }
        
    } else {
        [dictionaryRepresentation removeObjectForKey:@"_t"];
        
        if (_value) {
            dictionaryRepresentation[@"v"] = _value;
        } else {
            [dictionaryRepresentation removeObjectForKey:@"v"];
        }
        
    }
    
    if (_styleId > 0) {
        dictionaryRepresentation[@"_s"] = [NSString stringWithFormat:@"%ld", (long)_styleId];
    }
    
    
    [super setDictionaryRepresentation:dictionaryRepresentation];
    
    return dictionaryRepresentation;
}

- (BOOL)hasNumberFormat {
    return self.worksheet.styles.cellFormats[self.styleId].numberFormat != nil;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p> : %@", [self class], self, _reference];
}

@end
