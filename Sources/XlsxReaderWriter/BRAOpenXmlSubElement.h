//
//  BRAOpenXmlSubElement.h
//  BRAXlsxReaderWriter
//
//  Created by René BIGOT on 22/10/2014.
//  Copyright (c) 2014 René Bigot. All rights reserved.
//

#import <Foundation/Foundation.h>
#if __has_include(<XMLDictionary/XMLDictionary.h>)
#import <XMLDictionary/XMLDictionary.h>
#else
#import "XMLDictionary.h"
#endif
#import "NativeColor+HTML.h"
#import "NativeFont+BoldItalic.h"
#import "NSDictionary+DeepCopy.h"
#import "NSDictionary+OpenXmlString.h"
#import "NSDictionary+OpenXMLDictionaryParser.h"
@class BRAStyles, BRAWorksheet;

NS_ASSUME_NONNULL_BEGIN

@interface BRAOpenXmlSubElement : NSObject

@property (nonatomic, strong, nullable) NSDictionary *dictionaryRepresentation;

- (instancetype)initWithOpenXmlAttributes:(nullable NSDictionary *)attributes;
- (void)loadAttributes;

@end


@interface BRAOpenXmlSubElementWithStyle : BRAOpenXmlSubElement

@property (nonatomic, weak, nullable) BRAStyles *styles;

- (instancetype)initWithOpenXmlAttributes:(nullable NSDictionary *)attributes inStyles:(BRAStyles *)styles;

@end

@interface BRAOpenXmlSubElementWithWorksheet : BRAOpenXmlSubElement

@property (nonatomic, weak, nullable) BRAWorksheet *worksheet;

- (instancetype)initWithOpenXmlAttributes:(nullable NSDictionary *)attributes inWorksheet:(BRAWorksheet *)worksheet;

@end

NS_ASSUME_NONNULL_END
