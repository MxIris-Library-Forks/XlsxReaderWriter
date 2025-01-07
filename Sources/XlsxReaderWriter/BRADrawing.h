//
//  BRADrawing.h
//  BRAXlsxReaderWriter
//
//  Created by René BIGOT on 22/10/2014.
//  Copyright (c) 2014 René Bigot. All rights reserved.
//

#import "BRARelationship.h"
#import "BRARelationships.h"
#import "BRARelatedToColumnAndRowProtocol.h"
#import "BRAWorksheetDrawing.h"
#import "BRAImage.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRADrawing : BRARelationship <BRARelatedToColumnAndRowProtocol>

- (BRAWorksheetDrawing *)addDrawingForImage:(BRAImage *)image withAnchor:(BRAAnchor *)anchor;

@property (nonatomic, strong) NSArray<BRAWorksheetDrawing *> *worksheetDrawings;

@end

NS_ASSUME_NONNULL_END
