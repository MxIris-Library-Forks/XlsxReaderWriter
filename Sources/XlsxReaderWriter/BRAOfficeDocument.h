//
//  BRAOfficeDocument.h
//  BRAXlsxReaderWriter
//
//  Created by René BIGOT on 03/10/2014.
//  Copyright (c) 2014 René Bigot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BRARelationship.h"
#import "BRAStyles.h"
#import "BRACalcChain.h"
#import "BRAComments.h"
#import "BRAOpenXmlSubElement.h"

@class BRASharedStrings, BRASheet;

NS_ASSUME_NONNULL_BEGIN

@interface BRAOfficeDocument : BRARelationship

- (nullable BRAWorksheet *)worksheetNamed:(NSString *)worksheetName;
- (BRAWorksheet *)createWorksheetNamed:(NSString *)worksheetName;
- (BRAWorksheet *)createWorksheetNamed:(NSString *)worksheetName byCopyingWorksheet:(BRAWorksheet *)worksheet;
- (void)removeWorksheetNamed:(NSString *)worksheetName;

@property (nonatomic, weak, nullable) BRACalcChain *calcChain;
@property (nonatomic, weak, nullable) BRASharedStrings *sharedStrings;
@property (nonatomic, weak, nullable) BRAStyles *styles;
@property (nonatomic, strong) NSArray<BRASheet *> *sheets;
@property (nonatomic, strong, readonly) NSArray<BRAWorksheet *> *worksheets;

@end

NS_ASSUME_NONNULL_END
