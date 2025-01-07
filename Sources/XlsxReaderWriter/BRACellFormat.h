//
//  BRACellFormat.h
//  BRAXlsxReaderWriter
//
//  Created by René BIGOT on 08/10/2014.
//  Copyright (c) 2014 René Bigot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BRAOpenXmlSubElement.h"
#import "BRATextAttributes.h"
#import "BRACellBorder.h"

@class BRAStyles, BRACellFill, BRANumberFormat;

typedef NS_ENUM(NSUInteger, BRATextVerticalAlignment) {
    BRATextVerticalAlignmentTop,
    BRATextVerticalAlignmentCenter,
    BRATextVerticalAlignmentBottom,
};


NS_ASSUME_NONNULL_BEGIN

@interface BRACellFormat : BRAOpenXmlSubElementWithStyle

@property (nonatomic, getter=isProtected) BOOL protected;
@property (nonatomic, assign) NSTextAlignment textHorizontalAlignment;
@property (nonatomic, assign) BRATextVerticalAlignment textVerticalAlignment;
@property (nonatomic, assign, getter=isWrapText) BOOL wrapText;
@property (nonatomic, strong) NSDictionary<NSAttributedStringKey, id> *textAttributes;
@property (nonatomic, strong) BRATextAttributes *rawTextAttributes;
@property (nonatomic, strong, nullable) BRACellFill *cellFill;
@property (nonatomic, strong, nullable) BRACellBorder *cellBorder;
@property (nonatomic, strong, nullable) BRANumberFormat *numberFormat;
//Cell format (cellXfs) may have a reference to a cell style format (cellStyleXfs)
@property (nonatomic, weak, nullable) BRACellFormat *cellStyleFormat;

@end

NS_ASSUME_NONNULL_END
