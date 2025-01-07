//
//  BRAWorksheet.h
//  BRAXlsxReaderWriter
//
//  Created by René BIGOT on 10/10/2014.
//  Copyright (c) 2014 René Bigot. All rights reserved.
//

#import "BRARelationship.h"
#import "BRACell.h"
#import "BRACellRange.h"
#import "BRAMergeCell.h"
#import "BRAStyles.h"
#import "BRADrawing.h"
#import "BRAImage.h"
#import "BRACalcChain.h"
#import "BRASharedStrings.h"
#import "BRAComments.h"
#import "ArrayOperationMacro.h"

@class BRAColumn;

NS_ASSUME_NONNULL_BEGIN

@interface BRAWorksheet : BRARelationship

@property (nonatomic, getter=isTabSelected) BOOL tabSelected;
//@property (nonatomic, strong, readonly) NSArray<BRACell *> *cells;
//@property (nonatomic, strong, readonly) NSArray<BRAMergeCell *> *mergeCells;
@property (nonatomic, assign, readonly) NSInteger cellsCount;
@property (nonatomic, strong, readonly) NSArray<BRAMergeCell *> *mergeCells;
@property (nonatomic, strong, readonly) NSArray<BRARow *> *rows;
@property (nonatomic, strong, readonly) NSArray<BRAColumn *> *columns;
@property (nonatomic, strong, readonly) BRACellRange *dimension;
@property (nonatomic, strong, readonly) BRADrawing *drawings;
@property (nonatomic, strong, readonly) BRAComments *comments;
@property (nonatomic, strong, nullable) BRASharedStrings *sharedStrings;
@property (nonatomic, strong, nullable) BRAStyles *styles;
@property (nonatomic, strong, nullable) BRACalcChain *calcChain;
@property (nonatomic, assign) NSInteger defaultRowHeight;
@property (nonatomic, assign) NSInteger defaultColumnWidth;
//- (nullable BRAMergeCell *)mergeCellForCell:(BRACell *)cell;
- (nullable BRACell *)cellForCellReference:(NSString *)cellReference;
- (nullable BRACell *)cellForCellReference:(NSString *)cellReference shouldCreate:(BOOL)shouldCreate;
//- (nullable BRACell *)cellOrFirstCellInMergeCellForCellReference:(NSString *)cellReference;

//Image
- (nullable BRAImage *)imageForCellReference:(NSString *)cellReference;
- (BRAWorksheetDrawing *)addImage:(BRANativeImage *)image betweenCellsReferenced:(NSString *)firstCellReference and:(NSString *)secondCellReference withInsets:(BRANativeEdgeInsets)insets preserveTransparency:(BOOL)transparency;
- (BRAWorksheetDrawing *)addImage:(BRANativeImage *)image inCellReferenced:(NSString *)cellReference withOffset:(CGPoint)offset size:(CGSize)size preserveTransparency:(BOOL)transparency;
- (BRAWorksheetDrawing *)addImage:(BRANativeImage *)image inFrame:(CGRect)frame preserveTransparency:(BOOL)transparency;

//Column

//Rows
//- (void)addRowAt:(NSInteger)rowIndex;
//- (void)addRowsAt:(NSInteger)rowIndex count:(NSInteger)numberOfRowsToAdd;
//- (void)removeRow:(NSInteger)rowIndex;
//- (void)removeRow:(NSInteger)rowIndex count:(NSInteger)numberOfRowsToRemove;

//NSArrayCRUDOperationInterface(BRACell *, Cell, cell)

@end

NS_ASSUME_NONNULL_END
