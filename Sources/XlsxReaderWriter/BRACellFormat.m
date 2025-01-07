//
//  BRACellFormat.m
//  BRAXlsxReaderWriter
//
//  Created by René BIGOT on 08/10/2014.
//  Copyright (c) 2014 René Bigot. All rights reserved.
//

#import "BRACellFormat.h"
#import "BRAStyles.h"
#import "BRACellFill.h"

@interface BRACellFormat () {
    BOOL _isCellStyleXf;
    NSDictionary *_stylesTextsAttributes;
    BRACellFill *_cellFill;
    BRANumberFormat *_numberFormat;
    BRACellBorder *_cellBorder;
}

@end

@implementation BRACellFormat

- (void)loadAttributes {
    _isCellStyleXf = NO;
    
    NSDictionary *dictionaryRepresentation = [super dictionaryRepresentation];
    
    //Text alignment
    if (![dictionaryRepresentation.attributes[@"applyAlignment"] isEqual:@"0"]) {
        NSString *horizontalAlignment = [dictionaryRepresentation valueForKeyPath:@"alignment._horizontal"];
        
        if ([horizontalAlignment isEqual:@"center"]) {
            _textHorizontalAlignment = NSTextAlignmentCenter;
        } else if ([horizontalAlignment isEqual:@"right"]) {
            _textHorizontalAlignment = NSTextAlignmentRight;
        } else if ([horizontalAlignment isEqual:@"left"]) {
            _textHorizontalAlignment = NSTextAlignmentLeft;
        } else if ([horizontalAlignment isEqual:@"justified"]) {
            _textHorizontalAlignment = NSTextAlignmentJustified;
        }
        
        NSString *verticalAlignment = [dictionaryRepresentation valueForKeyPath:@"alignment._vertical"];
        
        if ([verticalAlignment isEqual:@"top"]) {
            _textVerticalAlignment = BRATextVerticalAlignmentTop;
        } else if ([verticalAlignment isEqual:@"center"]) {
            _textVerticalAlignment = BRATextVerticalAlignmentCenter;
        } else {
            _textVerticalAlignment = BRATextVerticalAlignmentBottom;
        }
        
        NSString *wrapText = [dictionaryRepresentation valueForKeyPath:@"alignment._wrapText"];
        _wrapText = [wrapText boolValue];
    } else {
        _textHorizontalAlignment = NSTextAlignmentLeft;
        _textVerticalAlignment = BRATextVerticalAlignmentCenter;
        _wrapText = NO;
    }
    
    id applyBorder = dictionaryRepresentation.attributes[@"applyBorder"];
    BOOL isApplyBorder = applyBorder ? [applyBorder boolValue] : YES;
    NSString *borderId = dictionaryRepresentation.attributes[@"borderId"];
    if (isApplyBorder && borderId) {
        _cellBorder = self.styles.cellBorders[borderId.integerValue];
    }
    
    
    //Cell fill
    id applyFill = dictionaryRepresentation.attributes[@"applyFill"];
    BOOL isApplyFill = applyFill ? [applyFill boolValue] : YES;
    NSString *fillId = dictionaryRepresentation.attributes[@"fillId"];
    if (isApplyFill && fillId) {
        _cellFill = self.styles.cellFills[fillId.integerValue];
    }

    //String attributes
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = [self textHorizontalAlignment];
    
    NSMutableDictionary *attributedStringAttributes = nil;
    
    NSString *fontId = dictionaryRepresentation.attributes[@"fontId"];
    if (fontId != nil) {
        _stylesTextsAttributes = self.styles.textsAttributes[fontId.integerValue];
        _rawTextAttributes = self.styles.rawTextsAttributes[fontId.integerValue];
        attributedStringAttributes = @{
            NSParagraphStyleAttributeName: paragraphStyle
        }.mutableCopy;
        [attributedStringAttributes addEntriesFromDictionary:_stylesTextsAttributes];
        
        _textAttributes = attributedStringAttributes;
    }
    
    NSString *applyNumberFormat = dictionaryRepresentation.attributes[@"applyNumberFormat"];
    //Number format
    if (![applyNumberFormat isEqual:@"0"]) {
        NSString *numberFormatID = dictionaryRepresentation.attributes[@"numFmtId"];
        if (![numberFormatID isEqualToString:@"0"]) {
            _numberFormat = self.styles.numberFormats[dictionaryRepresentation.attributes[@"numFmtId"]];
        }
    }
    
    //Protection
    _protected = [dictionaryRepresentation.attributes[@"applyProtection"] boolValue];
    
    //cellXfs xf entries may have a reference to an existing cellStyleXfs xf entry
    if (dictionaryRepresentation.attributes[@"xfId"] == nil) {
        _isCellStyleXf = YES;
        _cellStyleFormat = self.styles.cellStyleFormats[[dictionaryRepresentation.attributes[@"xfId"] integerValue]];
    }
}

- (NSDictionary *)dictionaryRepresentation {
    NSDictionary *dictionaryRepresentation = [super dictionaryRepresentation];
    
    //Text alignment
    if (_textHorizontalAlignment == 0) {
        [dictionaryRepresentation setValue:@"0" forKeyPath:@"_applyAlignment"];
    } else {
        [dictionaryRepresentation setValue:@"1" forKeyPath:@"_applyAlignment"];
        switch (_textHorizontalAlignment) {
            case NSTextAlignmentCenter:
                [dictionaryRepresentation setValue:@"center" forKeyPath:@"alignment._horizontal"];
                break;

            case NSTextAlignmentJustified:
                [dictionaryRepresentation setValue:@"justified" forKeyPath:@"alignment._horizontal"];
                break;

            case NSTextAlignmentRight:
                [dictionaryRepresentation setValue:@"right" forKeyPath:@"alignment._horizontal"];
                break;

            default:
                [dictionaryRepresentation setValue:@"left" forKey:@"alignment._horizontal"];
                break;
        }
    }
    
    //Fill
    if (_cellFill == nil) {
        [dictionaryRepresentation setValue:@"0" forKey:@"_applyFill"];
        [dictionaryRepresentation setValue:@"0" forKey:@"_fillId"];
    } else {
        [dictionaryRepresentation setValue:@"1" forKey:@"_applyFill"];
        [dictionaryRepresentation setValue:[NSString stringWithFormat:@"%ld", (long)[self.styles.cellFills indexOfObject:_cellFill]] forKey:@"_fillId"];
    }
    
    //String attributes
    if (_textAttributes == nil) {
        [dictionaryRepresentation setValue:@"0" forKey:@"_fontId"];
    } else {
        [dictionaryRepresentation setValue:[NSString stringWithFormat:@"%ld", (long)[self.styles.textsAttributes indexOfObject:_stylesTextsAttributes]] forKey:@"_fontId"];
    }

    //Number format
    if (_numberFormat == nil || [_numberFormat isEqual:self.styles.numberFormats[@"@"]]) {
        [dictionaryRepresentation setValue:@"0" forKey:@"_applyNumberFormat"];
        [dictionaryRepresentation setValue:@"0" forKey:@"_numFmtId"];
    } else {
        [dictionaryRepresentation setValue:@"1" forKey:@"_applyNumberFormat"];
        NSString __block *numFmtId = @"0";
        [self.styles.numberFormats enumerateKeysAndObjectsUsingBlock:^(NSString *key, BRANumberFormat *obj, BOOL *stop) {
            if ([obj isEqual:_numberFormat]) {
                numFmtId = key;
                *stop = YES;
            }
        }];
        [dictionaryRepresentation setValue:numFmtId forKey:@"_numFmtId"];
    }
    
    //Protection
    if (_isCellStyleXf) {
        [dictionaryRepresentation setValue:self.isProtected ? @"1" : @"0" forKey:@"_applyProtection"];
    }
    
    //Cell style format
    NSInteger cellStyleFormatId = [self.styles.cellStyleFormats indexOfObject:_cellStyleFormat];
    if (cellStyleFormatId == NSNotFound) {
        cellStyleFormatId = 0;
    }
    [dictionaryRepresentation setValue:[NSString stringWithFormat:@"%ld", (long)cellStyleFormatId] forKey:@"_xfId"];
    
    [super setDictionaryRepresentation:dictionaryRepresentation];

    return dictionaryRepresentation;
}

#pragma mark - Getters

- (BOOL)isProtected {
    if (_cellStyleFormat) {
        return _cellStyleFormat.protected || _protected;
    } else {
        return _protected;
    }
}

- (NSTextAlignment)textHorizontalAlignment {
    if (_cellStyleFormat && _cellStyleFormat.textHorizontalAlignment != 0) {
        return _cellStyleFormat.textHorizontalAlignment;
    } else {
        return _textHorizontalAlignment;
    }
}

- (BRACellFill *)cellFill {
    if (_cellStyleFormat && _cellStyleFormat.cellFill != nil) {
        return _cellStyleFormat.cellFill;
    } else {
        return _cellFill;
    }
}

- (BRACellBorder *)cellBorder {
    if (_cellStyleFormat && _cellStyleFormat.cellBorder != nil) {
        return _cellStyleFormat.cellBorder;
    } else {
        return _cellBorder;
    }
}

- (NSDictionary *)textAttributes {
    if (_cellStyleFormat && _cellStyleFormat.textAttributes != nil) {
        return _cellStyleFormat.textAttributes;
    } else {
        return _textAttributes;
    }
}

- (BRANumberFormat *)numberFormat {
    if (_cellStyleFormat && _cellStyleFormat.numberFormat != nil) {
        return _cellStyleFormat.numberFormat;
    } else {
        return _numberFormat;
    }
}

#pragma mark - Setters

- (void)setCellBorder:(BRACellBorder *)cellBorder {
    if (cellBorder) {
        NSInteger index = [self.styles.cellBorders indexOfObject:cellBorder];
        if (index == NSNotFound) {
            NSMutableArray *cellBorders = self.styles.cellBorders.mutableCopy;
            [cellBorders addObject:cellBorder];
            self.styles.cellBorders = cellBorders;
        }
    }
    _cellBorder = cellBorder;
}

- (void)setCellFill:(BRACellFill *)cellFill {
    if (cellFill) {
        NSInteger index = [self.styles.cellFills indexOfObject:cellFill];
        
        if (index == NSNotFound) {
            NSMutableArray *cellFills = self.styles.cellFills.mutableCopy;
            [cellFills addObject:cellFill];
            self.styles.cellFills = cellFills;
        }
    }

    _cellFill = cellFill;
}

- (void)setNumberFormat:(BRANumberFormat *)numberFormat {
    if (numberFormat) {
        NSString *key = [[self.styles.numberFormats keysOfEntriesPassingTest:^BOOL(id key, BRANumberFormat *obj, BOOL *stop) {
            if ([obj.formatCode isEqual:numberFormat.formatCode]) {
                *stop = YES;
                return YES;
            }
            
            return NO;
        }] anyObject];
        
        if (key) {
            numberFormat.formatId = key;
            
        } else {
            NSInteger tmpId = 100;
            NSString *formatId = [NSString stringWithFormat:@"%ld", (long)tmpId];
            while (self.styles.numberFormats[formatId]) {
                formatId = [NSString stringWithFormat:@"%ld", (long)++tmpId];
            }
            
            numberFormat.formatId = formatId;
            NSMutableDictionary *numberFormats = self.styles.numberFormats.mutableCopy;
            numberFormats[formatId] = numberFormat;
            self.styles.numberFormats = numberFormats;
        }
    }
    _numberFormat = numberFormat;
}

#pragma mark - NSObject

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p>: Protected: %@  Number format: %@", [self class], self, _protected ? @"YES": @"NO", _numberFormat.formatCode];
}

@end
