//
//  BRARow.h
//  BRAXlsxReaderWriter
//
//  Created by René BIGOT on 17/10/2014.
//  Copyright (c) 2014 René Bigot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BRAOpenXmlSubElement.h"
#import "ArrayOperationMacro.h"


@class BRACell, BRAWorksheet;

NS_ASSUME_NONNULL_BEGIN

@interface BRARow : BRAOpenXmlSubElementWithWorksheet

@property (nonatomic, getter=hasCustomHeight) BOOL customHeight;
@property (nonatomic) NSInteger rowIndex;
@property (nonatomic) NSInteger height;
@property (nonatomic, strong, readonly) NSArray<BRACell *> *cells;

- (instancetype)initWithRowIndex:(NSInteger)rowIndex inWorksheet:(BRAWorksheet *)worksheet;
+ (NSInteger)rowIndexForCellReference:(NSString *)cellReference;

NSArrayCRUDOperationInterface(BRACell *, Cell, cell)

@end

NS_ASSUME_NONNULL_END
