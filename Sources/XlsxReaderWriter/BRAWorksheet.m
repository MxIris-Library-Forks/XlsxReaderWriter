//
//  BRAWorksheet.m
//  BRAXlsxReaderWriter
//
//  Created by René BIGOT on 10/10/2014.
//  Copyright (c) 2014 René Bigot. All rights reserved.
//

#import "BRAWorksheet.h"
#import "BRAColumn.h"
#import "BRARow.h"
#import "BRARelationships.h"
#import "BRAPlatformSpecificDefines.h"

@interface BRAWorksheet ()
//@property (nonatomic, strong) NSMutableArray<BRACell *> *mutableCells;
//@property (nonatomic, strong) NSMutableArray<BRAMergeCell *> *mutableMergeCells;
@property (nonatomic, strong) NSMutableArray<BRAMergeCell *> *mutableMergeCells;
@property (nonatomic, strong) NSMutableArray<BRARow *> *mutableRows;
@property (nonatomic, strong) NSMutableArray<BRAColumn *> *mutableColumns;
@property (nonatomic, strong) BRACellRange *dimension;
@property (nonatomic, strong) BRADrawing *drawings;
@property (nonatomic, strong) BRAComments *comments;

@end

@implementation BRAWorksheet

//NSArrayCRUDOperationImplementation(BRACell *, Cell, cell)

+ (NSString *)fullRelationshipType {
    return @"http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet";
}

- (NSString *)contentType {
    return @"application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml";
}

- (NSString *)targetFormat {
    return @"worksheets/sheet%ld.xml";
}

- (void)loadXmlContents {
    [super loadXmlContents];
    
    NSMutableDictionary *openXmlAttributes = [NSDictionary dictionaryWithOpenXmlString:super.xmlRepresentation].BRA_mutableDeepCopy;
    //Get dimension
    NSString *rangeReference = [openXmlAttributes valueForKeyPath:@"dimension._ref"];
    if (rangeReference == nil) {
        rangeReference = @"A1:A1";
    }
    _dimension = [[BRACellRange alloc] initWithRangeReference:rangeReference];
    //Create merge cells
    NSArray *mergeCellsArray = [openXmlAttributes arrayValueForKeyPath:@"mergeCells.mergeCell"];
    if (mergeCellsArray) {

        for (NSDictionary *mergeCellDict in mergeCellsArray) {
            NSString *ref = mergeCellDict.attributes[@"ref"];
            BRAMergeCell *mergeCell = [[BRAMergeCell alloc] initWithRangeReference:ref];
            
            if (mergeCell) {
//                [self.mutableMergeCells addObject:mergeCell];
                [self.mutableMergeCells addObject:mergeCell];
            }
            
        }
    }
    
    // Create sheetFormatProperties
    
    NSDictionary *sheetFormatProperties = openXmlAttributes[@"sheetFormatPr"];
    _defaultRowHeight = [[sheetFormatProperties valueForKeyPath:@"_defaultRowHeight"] integerValue];
    _defaultColumnWidth = [[sheetFormatProperties valueForKeyPath:@"_defaultColWidth"] integerValue];
    
    
    //Create columns
    NSDictionary *cols = openXmlAttributes[@"cols"];
    if (!cols || cols.count == 0) {
        openXmlAttributes[@"cols"] = @{}.mutableCopy;
    }
    if (!openXmlAttributes[@"cols"][@"col"]) {
        openXmlAttributes[@"cols"][@"col"] = @[];
    }
    NSArray *sheetColumns = [openXmlAttributes arrayValueForKeyPath:@"cols.col"];

    for (NSDictionary *columnDict in sheetColumns) {
        [self.mutableColumns addObject:[[BRAColumn alloc] initWithOpenXmlAttributes:columnDict]];
    }
    
    //Create cells and rows
    NSDictionary *sheetData = openXmlAttributes[@"sheetData"];
    if (!sheetData || sheetData.count == 0) {
        openXmlAttributes[@"sheetData"] = [NSMutableDictionary dictionary];
        
    }
    if (!openXmlAttributes[@"sheetData"][@"row"]) {
        openXmlAttributes[@"sheetData"][@"row"] = @[].mutableCopy;
    }
    
    NSArray *sheetRows = [openXmlAttributes arrayValueForKeyPath:@"sheetData.row"];
    
//    NSInteger rowsCount = [sheetRows count];
    

    for (NSDictionary *rowDict in sheetRows) {
        BRARow *row = [[BRARow alloc] initWithOpenXmlAttributes:rowDict inWorksheet:self];
        _cellsCount += row.cells.count;
        [self.mutableRows addObject:row];
//        [self.mutableCells addObjectsFromArray:row.cells];
    }
    
    _drawings = [self.relationships anyRelationshipWithType:[BRADrawing fullRelationshipType]];
    _comments = [self.relationships anyRelationshipWithType:[BRAComments fullRelationshipType]];
    
    [super setXmlRepresentation:nil];
}

#pragma mark - 

- (NSString *)xmlRepresentation {
    NSMutableDictionary *dictionaryRepresentation = [NSDictionary dictionaryWithOpenXmlString:super.xmlRepresentation].mutableCopy;
    
    NSString *xmlHeader = @"<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>\r\n";

    //Tab selected
    [dictionaryRepresentation setValue:[self isTabSelected] ? @"1" : @"0"
                            forKeyPath:@"sheetViews.sheetView._tabSelected"];
    
    //Dimension
    dictionaryRepresentation[@"dimension"] = [self.dimension dictionaryRepresentation];

    //Merge Cells
    NSMutableArray *mergeCells = @[].mutableCopy;
    for (BRAMergeCell *mergeCell in self.mergeCells) {
        [mergeCells addObject:[mergeCell dictionaryRepresentation]];
    }
    if (mergeCells.count > 0) {
        dictionaryRepresentation[@"mergeCells"] = @{
                                                    @"_count": [NSString stringWithFormat:@"%ld", (long)[self.mergeCells count]],
                                                    @"mergeCell": mergeCells
                                                    };
    }

    //Columns
    NSMutableArray *columns = @[].mutableCopy;
    for (BRAColumn *column in self.columns) {
        [columns addObject:[column dictionaryRepresentation]];
    }
    [columns sortUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
        return [obj1[@"_min"] integerValue] < [obj2[@"_min"] integerValue] ? NSOrderedAscending : NSOrderedDescending;
    }];
    if (columns.count > 0) {
        dictionaryRepresentation[@"cols"] = @{
                                              @"col": columns
                                              };
    }

    //Rows
    NSMutableArray *rows = @[].mutableCopy;
    for (BRARow *row in self.rows) {
        [rows addObject:[row dictionaryRepresentation]];
    }
    [rows sortUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
        return [obj1[@"_r"] integerValue] < [obj2[@"_r"] integerValue] ? NSOrderedAscending : NSOrderedDescending;
    }];
    if (rows.count > 0) {
        dictionaryRepresentation[@"sheetData"] = @{
                                                   @"row": rows
                                                   };
    }
    
    //Drawing
    BRADrawing *drawing = [self.relationships anyRelationshipWithType:[BRADrawing fullRelationshipType]];
    if (drawing) {
        dictionaryRepresentation[@"drawing"] = @{@"_r:id": drawing.identifier};
    }
    
    //Return xmlRepresentation
    super.xmlRepresentation = [xmlHeader stringByAppendingString:[dictionaryRepresentation openXmlStringInNodeNamed:@"worksheet"]];
    
    return super.xmlRepresentation;
}

#pragma mark - Content

//- (BRAMergeCell *)mergeCellForCell:(BRACell *)cell {
//    return self.mutableMergeCells[cell.reference];
//    for (BRAMergeCell *mergeCell in self.mergeCells) {
//        if (cell.columnIndex >= mergeCell.leffColumnIndex
//            && cell.columnIndex <= mergeCell.rightColumnIndex
//            && cell.rowIndex >= mergeCell.topRowIndex
//            && cell.rowIndex <= mergeCell.bottomRowIndex) {
//            
//            return mergeCell;
//        }
//    }
//    
//    return nil;
//}

- (BRACell *)cellForCellReference:(NSString *)cellReference {
    return [self cellForCellReference:cellReference shouldCreate:NO];
}

- (BRACell *)cellForCellReference:(NSString *)cellReference shouldCreate:(BOOL)shouldCreate {
    NSUInteger cellIndex = NSNotFound;
    BRARow *targetRow = nil;
    for (BRARow *row in self.rows) {
        cellIndex = [row.cells indexOfObjectPassingTest:^BOOL(BRACell *cell, NSUInteger idx, BOOL *stop) {
            if ([cell.reference isEqual:cellReference]) {
                *stop = YES;
                return YES;
            }
            return NO;
        }];
        
        if (cellIndex != NSNotFound) {
            targetRow = row;
            break;
        }
    }
    
    if (cellIndex != NSNotFound && targetRow) {
        return targetRow.cells[cellIndex];
    } else if (shouldCreate) {
        return [self newCellForCellReference:cellReference];
    } else {
        return nil;
    }
}

//- (BRACell *)cellOrFirstCellInMergeCellForCellReference:(NSString *)cellReference {
//    BRACell *cell = [self cellForCellReference:cellReference];
//    
//    if (cell.mergeCell == nil) {
//        return cell;
//    } else {
//        return [self cellForCellReference:cell.mergeCell.firstCellReference];
//    }
//}

- (BRACell *)newCellForCellReference:(NSString *)cellReference {
    //check if row exists
    NSUInteger rowIndexToFind = [BRARow rowIndexForCellReference:cellReference];
    NSInteger __block maxRowIndex = 0;
    
    //indexes of objects in _rows are not the same as their own rowIndex
    NSUInteger rowIndexInRows = [self.rows indexOfObjectPassingTest:^BOOL(BRARow *obj, NSUInteger idx, BOOL *stop) {
        maxRowIndex = MAX(obj.rowIndex, maxRowIndex);
        if (obj.rowIndex == rowIndexToFind) {
            *stop = YES;
            return YES;
        }
        return NO;
    }];
    
    BRARow *row = nil;
    if (rowIndexInRows != NSNotFound) {
        row = [self.rows objectAtIndex:rowIndexInRows];
    }
    
    if (!row) {
        for (NSInteger rowIndex = maxRowIndex + 1; rowIndex <= [BRARow rowIndexForCellReference:cellReference]; rowIndex++) {
            //If row doesn't exist, create it
            row = [[BRARow alloc] initWithRowIndex:rowIndex inWorksheet:self];
            [self.mutableRows addObject:row];
            
            //Adjust sheet dimension
            _dimension.bottomRowIndex = MAX(row.rowIndex, self.dimension.bottomRowIndex);
        }
    }
    
    //Create cell and add it to the row
    BRACell *cell = [[BRACell alloc] initWithReference:cellReference andStyleId:0 inWorksheet:self];
    [row addCell:cell];
    
    NSInteger lastColumnIndex = 0;
    
    for (BRAColumn *column in self.columns) {
        if (lastColumnIndex < column.maximum) {
            lastColumnIndex = column.maximum;
        }
    }
    
    _dimension.rightColumnIndex = MAX(cell.columnIndex, _dimension.rightColumnIndex);
    
    if (lastColumnIndex < cell.columnIndex) {
        [self.mutableColumns addObject:[[BRAColumn alloc] initWithMinimum:lastColumnIndex + 1 andMaximum:cell.columnIndex]];
    }
    
    return cell;
}

- (BRAImage *)imageForCellReference:(NSString *)cellReference {
    for (BRAWorksheetDrawing *drawing in _drawings.worksheetDrawings) {
        
        //If anchor type is absolute, there's no cell reference
        if (drawing.anchor && ![drawing.anchor isKindOfClass:[BRAAbsoluteAnchor class]]) {
            
            if ([((BRAOneCellAnchor *)drawing.anchor).topLeftCellReference isEqualToString:cellReference]) {
                return [_drawings.relationships relationshipWithId:drawing.identifier];
            }
        }
    }
    
    return nil;
}

- (BRAWorksheetDrawing *)addImage:(BRANativeImage *)image betweenCellsReferenced:(NSString *)firstCellReference and:(NSString *)secondCellReference
      withInsets:(BRANativeEdgeInsets)insets preserveTransparency:(BOOL)transparency {
    
    NSData *dataRepresentation = transparency ? BRANativeImagePNGRepresentation(image) : BRANativeImageJPEGRepresentation(image, .9);
    
    BRAImage *newImage = [[BRAImage alloc] initWithDataRepresentation:dataRepresentation
                                                        forRelationId:[_drawings.relationships relationshipIdForNewRelationship]
                                                    inParentDirectory:_drawings.parentDirectory];
    newImage.jpeg = !transparency;
    
    BRATwoCellAnchor *anchor = [[BRATwoCellAnchor alloc] init];
    anchor.topLeftCellReference = firstCellReference;
    anchor.bottomRightCellReference = secondCellReference;
    anchor.topLeftCellOffset = CGPointMake(insets.left, insets.top);
    anchor.bottomRightCellOffset = CGPointMake(insets.right, insets.bottom);
    
    //Use self.drawings to create drawings if necessary
    return [self.drawings addDrawingForImage:newImage withAnchor:anchor];
}

- (BRAWorksheetDrawing *)addImage:(BRANativeImage *)image inCellReferenced:(NSString *)cellReference withOffset:(CGPoint)offset size:(CGSize)size preserveTransparency:(BOOL)transparency {
    NSData *dataRepresentation = transparency ? BRANativeImagePNGRepresentation(image) : BRANativeImageJPEGRepresentation(image, .9);
    
    BRAImage *newImage = [[BRAImage alloc] initWithDataRepresentation:dataRepresentation
                                                        forRelationId:[_drawings.relationships relationshipIdForNewRelationship]
                                                    inParentDirectory:_drawings.parentDirectory];
    newImage.jpeg = !transparency;
    
    BRAOneCellAnchor *anchor = [[BRAOneCellAnchor alloc] init];
    anchor.topLeftCellReference = cellReference;
    anchor.topLeftCellOffset = offset;
    anchor.size = size;
    
    //Use self.drawings to create drawings if necessary
    return [self.drawings addDrawingForImage:newImage withAnchor:anchor];
}

- (BRAWorksheetDrawing *)addImage:(BRANativeImage *)image inFrame:(CGRect)frame preserveTransparency:(BOOL)transparency {
    NSData *dataRepresentation = transparency ? BRANativeImagePNGRepresentation(image) : BRANativeImageJPEGRepresentation(image, .9);
    
    BRAImage *newImage = [[BRAImage alloc] initWithDataRepresentation:dataRepresentation
                                                        forRelationId:[_drawings.relationships relationshipIdForNewRelationship]
                                                    inParentDirectory:_drawings.parentDirectory];
    newImage.jpeg = !transparency;
    
    BRAAbsoluteAnchor *anchor = [[BRAAbsoluteAnchor alloc] init];
    anchor.frame = frame;
    
    //Use self.drawings to create drawings if necessary
    return [self.drawings addDrawingForImage:newImage withAnchor:anchor];
}

- (BRADrawing *)drawings {
    if (_drawings) {
        return _drawings;
    }
    
    NSString *relationId = [self.relationships relationshipIdForNewRelationship];
    
    _drawings = [[BRADrawing alloc] initWithXmlRepresentation:@"<xdr:wsDr xmlns:xdr=\"http://schemas.openxmlformats.org/drawingml/2006/spreadsheetDrawing\" xmlns:a=\"http://schemas.openxmlformats.org/drawingml/2006/main\"></xdr:wsDr>"
                                                forRelationId:relationId
                                            inParentDirectory:[self.parentDirectory stringByAppendingPathComponent:@"xl/worksheets"]];
    
    [self.relationships addRelationship:_drawings];
    
    return _drawings;
}

- (BRAComments *)comments {
    if (_comments) {
        return _comments;
    }
    
    NSString *relationId = [self.relationships relationshipIdForNewRelationship];
    
    _comments = [[BRAComments alloc] initWithXmlRepresentation:@"<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?><comments xmlns=\"http://schemas.openxmlformats.org/spreadsheetml/2006/main\"></comments>"
                                                forRelationId:relationId
                                            inParentDirectory:[self.parentDirectory stringByAppendingPathComponent:@"xl/worksheets"]];
    
    [self.relationships addRelationship:_comments];
    
    return _comments;
}

#pragma mark -

//- (void)addRowAt:(NSInteger)rowIndex {
//    [self addRowsAt:rowIndex count:1];
//}
//
//- (void)addRowsAt:(NSInteger)rowIndex count:(NSInteger)numberOfRowsToAdd {
//    //-----Adjust worksheet dimension
//    _dimension.bottomRowIndex = MAX(numberOfRowsToAdd + _dimension.bottomRowIndex, rowIndex + numberOfRowsToAdd - 1);
//    
//    //-----Adjust mergeCells
//    for (BRAMergeCell *mergeCell in self.mergeCells) {
//        //If rowIndex is above top mergeCell, change top index
//        if (rowIndex <= mergeCell.topRowIndex) {
//            mergeCell.topRowIndex += numberOfRowsToAdd;
//        }
//        
//        //If rowIndex is above bottom mergeCell, change bottom index
//        if (rowIndex <= mergeCell.bottomRowIndex) {
//            mergeCell.bottomRowIndex += numberOfRowsToAdd;
//        }
//    }
//    
//    //-----Add cells and rows
//    BRARow *currentRow = nil;
//    NSArray *currentRowCells = nil;
//    NSMutableArray *newRows = @[].mutableCopy;
//    BRARow *newRow = nil;
//    BRACell *newCell = nil;
//    NSInteger maxRowIndex = 0;
//    
//    for (NSInteger i = 0; i < [self.rows count]; i++) {
//        currentRow = self.rows[i];
//        maxRowIndex = MAX(maxRowIndex, currentRow.rowIndex);
//        
//        if (currentRow.rowIndex == rowIndex) {
//            currentRowCells = currentRow.cells;
//            
//            for (NSInteger jj = 0; jj < numberOfRowsToAdd; jj++) {
//                newRow = [[BRARow alloc] initWithRowIndex:rowIndex + jj inWorksheet:self];
//                
//                for (NSInteger ii = 0; ii < [currentRowCells count]; ii++) {
//                    NSInteger columnIndex = [BRAColumn columnIndexForCellReference:[currentRowCells[ii] reference]];
//                    
//                    newCell = [[BRACell alloc] initWithReference:[BRACell cellReferenceForColumnIndex:columnIndex andRowIndex:rowIndex + jj]
//                                                      andStyleId:[currentRowCells[ii] styleId]
//                                                     inWorksheet:self];
//                    
//                    [newRow addCell:newCell];
//                    
//                    [newCell setCellFill:nil];
//                }
//                
//                [newRows addObject:newRow];
//                
//            }
//
//            currentRow.rowIndex += numberOfRowsToAdd;
//            
//        } else if (currentRow.rowIndex > rowIndex) {
//            currentRow.rowIndex += numberOfRowsToAdd;
//        }
//    }
//    
//    if (rowIndex > maxRowIndex) {
//        currentRowCells = currentRow.cells;
//        
//        for (NSInteger jj = 0; jj < numberOfRowsToAdd; jj++) {
//            newRow = [[BRARow alloc] initWithRowIndex:rowIndex + jj inWorksheet:self];
//            
//            for (NSInteger ii = 0; ii < [currentRowCells count]; ii++) {
//                NSInteger columnIndex = [BRAColumn columnIndexForCellReference:[currentRowCells[ii] reference]];
//                
//                newCell = [[BRACell alloc] initWithReference:[BRACell cellReferenceForColumnIndex:columnIndex andRowIndex:rowIndex + jj]
//                                                  andStyleId:[currentRowCells[ii] styleId]
//                                                 inWorksheet:self];
//                
//                [newRow addCell:newCell];
//                
//                [newCell setCellFill:nil];
//            }
//            
//            [newRows addObject:newRow];
//        }
//        
//    }
//    
//    if (newRows.count > 0) {
//        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(rowIndex, numberOfRowsToAdd)];
//        if (rowIndex > maxRowIndex) {
//            [self.mutableRows addObjectsFromArray:newRows];
//        } else {
//            [self.mutableRows insertObjects:newRows atIndexes:indexSet];
//        }
//       
//        [_calcChain didAddRowsAtIndexes:indexSet];
//        [_drawings didAddRowsAtIndexes:indexSet];
//        [_comments didAddRowsAtIndexes:indexSet];
//    }
//}
//
//
//- (void)removeRow:(NSInteger)rowIndex {
//    [self removeRow:rowIndex count:1];
//}
//
//- (void)removeRow:(NSInteger)rowIndex count:(NSInteger)numberOfRowsToRemove {
//    //-----Adjust worksheet dimension
//    _dimension.bottomRowIndex -= numberOfRowsToRemove;
//    
////    NSMutableArray *mergeCellsToBeRemoved = @[].mutableCopy;
//    
//    //-----Adjust mergeCells
//    for (BRAMergeCell *mergeCell in self.mergeCells) {
//        //if horizontal mergeCell -> remove mergeCell
//        if (mergeCell.topRowIndex == rowIndex
//            && mergeCell.bottomRowIndex == rowIndex) {
//            
////            [mergeCellsToBeRemoved addObject:mergeCell];
//            [self.mutableMergeCells removeObjectForKey:mergeCell.reference];
//        } else {
//            
//            //If rowIndex is above top mergeCell, change top index
//            //strictly lower than !
//            if (rowIndex < mergeCell.topRowIndex - numberOfRowsToRemove + 1) {
//                mergeCell.topRowIndex -= numberOfRowsToRemove;
//                
//                //strictly lower than !
//            } else if (rowIndex < mergeCell.topRowIndex) {
//                mergeCell.topRowIndex -= mergeCell.topRowIndex - rowIndex;
//            }
//            
//            //If rowIndex is above bottom mergeCell, change bottom index
//            if (rowIndex <= mergeCell.bottomRowIndex - numberOfRowsToRemove + 1) {
//                mergeCell.bottomRowIndex -= numberOfRowsToRemove;
//
//            } else if (rowIndex <= mergeCell.bottomRowIndex) {
//                mergeCell.bottomRowIndex -= mergeCell.bottomRowIndex - rowIndex;
//            }
//        }
//    }
//    
////    [self.mutableMergeCells removeObjectsInArray:mergeCellsToBeRemoved];
//    
//    //-----Remove cells and rows
//    NSMutableIndexSet *indexesOfRowToRemove = [[NSMutableIndexSet alloc] init];
//    
//    NSMutableArray *newRows = [self.rows mutableCopy];
//    NSMutableArray *modifiedRows = [[NSMutableArray alloc] initWithCapacity:[self.rows count]];
//    
//    BRARow *currentRow = nil;
//    BRACell *currentCell = nil;
//    
//    //i must start at 0 since rows count isn't equal to last row index
//    for (NSInteger i = 0; i < [self.rows count]; i++) {
//        currentRow = self.rows[i];
//        
//        if (currentRow.rowIndex >= rowIndex && currentRow.rowIndex < rowIndex + numberOfRowsToRemove) {
//            [currentRow.cells enumerateObjectsUsingBlock:^(BRACell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                //Fix a bug : If we delete row 16 and there's a merged cell starting at A17
//                //            The new A16 will have the old A16 value
//                [obj setReference:@"-1"];
//            }];
//            [indexesOfRowToRemove addIndex:i];
//            
//        } else if (currentRow.rowIndex > rowIndex) {
//            //don't change row index now
//            [modifiedRows addObject:currentRow];
//            
//            //modify cells in row
//            for (NSInteger j = 0; j < [currentRow.cells count]; j++) {
//                currentCell = currentRow.cells[j];
//                
//                //If mergeCells firstCell is deleted, we put its value in the new firstCell
//                //get row index from rowIndexForCellReference instead of .rowIndex since .rowIndex could have be modified
//                if (currentCell.mergeCell
//                    && currentCell.columnIndex == currentCell.mergeCell.leffColumnIndex
//                    && [BRARow rowIndexForCellReference:currentCell.mergeCell.firstCellReference] == rowIndex
//                    && [BRARow rowIndexForCellReference:currentCell.reference] == rowIndex + numberOfRowsToRemove) {
//                    
//                    BRACell *cell = [self cellForCellReference:currentCell.mergeCell.firstCellReference];
//                    
//                    if (cell) {
//                        [currentRow setCell:cell atIndex:j];
//                    }
//                }
//            }
//        }
//    }
//    
//    [_calcChain didRemoveRowsAtIndexes:indexesOfRowToRemove];
//    [_drawings didRemoveRowsAtIndexes:indexesOfRowToRemove];
//    [_comments didRemoveRowsAtIndexes:indexesOfRowToRemove];
//    
//    
//    //change rows indexes
//    for (BRARow *row in modifiedRows) {
//        row.rowIndex -= numberOfRowsToRemove;
//    }
//    
//    //Remove row
//    if ([indexesOfRowToRemove count] > 0) {
//        [newRows removeObjectsAtIndexes:indexesOfRowToRemove];
//    }
//    self.mutableRows = newRows.mutableCopy;
//}

//- (void)removeColumn:(NSString *)columnName {
//#warning TODO
//}


//- (NSArray<BRACell *> *)cells {
//    return self.mutableCells;
//}

//- (NSArray<BRAMergeCell *> *)mergeCells {
//    return self.mutableMergeCells;
//}

- (NSArray<BRAMergeCell *> *)mergeCells {
    return self.mutableMergeCells;
}

- (NSArray<BRARow *> *)rows {
    return self.mutableRows;
}

- (NSArray<BRAColumn *> *)columns {
    return self.mutableColumns;
}

//- (NSMutableArray<BRACell *> *)mutableCells {
//    if (_mutableCells == nil) {
//        _mutableCells = [[NSMutableArray<BRACell *> alloc] init];
//    }
//    return _mutableCells;
//}

//- (NSMutableArray<BRAMergeCell *> *)mutableMergeCells {
//    if (_mutableMergeCells == nil) {
//        _mutableMergeCells = [[NSMutableArray<BRAMergeCell *> alloc] init];
//    }
//    return _mutableMergeCells;
//}
- (NSMutableArray<BRAMergeCell *> *)mutableMergeCells {
    if (_mutableMergeCells == nil) {
        _mutableMergeCells = [[NSMutableArray alloc] init];
    }
    return _mutableMergeCells;
}
- (NSMutableArray<BRARow *> *)mutableRows {
    if (_mutableRows == nil) {
        _mutableRows = [[NSMutableArray<BRARow *> alloc] init];
    }
    return _mutableRows;
}

- (NSMutableArray<BRAColumn *> *)mutableColumns {
    if (_mutableColumns == nil) {
        _mutableColumns = [[NSMutableArray<BRAColumn *> alloc] init];
    }
    return _mutableColumns;
}


@end
