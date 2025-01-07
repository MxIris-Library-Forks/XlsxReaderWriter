//
//  BRACellRange.h
//  BRAXlsxReaderWriter
//
//  Created by René BIGOT on 17/10/2014.
//  Copyright (c) 2014 René Bigot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BRAOpenXmlSubElement.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRACellRange : BRAOpenXmlSubElement

- (nullable instancetype)initWithRangeReference:(NSString *)rangeReference;
- (NSString *)reference;

@property (nonatomic) NSInteger topRowIndex;
@property (nonatomic) NSInteger bottomRowIndex;
@property (nonatomic) NSInteger leftColumnIndex;
@property (nonatomic) NSInteger rightColumnIndex;
@property (nonatomic, copy, nullable) NSString *leftColumnName;
@property (nonatomic, copy, nullable) NSString *rightColumnName;

@end

NS_ASSUME_NONNULL_END
