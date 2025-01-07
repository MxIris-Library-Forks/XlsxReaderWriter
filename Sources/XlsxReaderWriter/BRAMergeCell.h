//
//  BRAMergeCell.h
//  BRAXlsxReaderWriter
//
//  Created by René BIGOT on 17/10/2014.
//  Copyright (c) 2014 René Bigot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BRACellRange.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRAMergeCell : BRACellRange

- (NSString *)firstCellReference;

@end

NS_ASSUME_NONNULL_END
