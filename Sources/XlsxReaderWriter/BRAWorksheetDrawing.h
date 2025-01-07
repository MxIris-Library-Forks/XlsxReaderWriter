//
//  BRAWorksheetDrawing.h
//  BRAXlsxReaderWriter
//
//  Created by René BIGOT on 22/10/2014.
//  Copyright (c) 2014 René Bigot. All rights reserved.
//
#import "BRAPlatformSpecificDefines.h"
#import "BRAOpenXmlSubElement.h"
#import "BRAImage.h"

@class BRADrawing;
NS_ASSUME_NONNULL_BEGIN

@interface BRAAnchor : NSObject

- (NSDictionary<NSString *, NSString *> *)openXmlAttributesForNewAnchoredDrawing;

@end

@interface BRAAbsoluteAnchor : BRAAnchor

@property (nonatomic) CGRect frame;

@end

@interface BRAOneCellAnchor : BRAAnchor

@property (nonatomic) CGSize size;
@property (nonatomic) CGPoint topLeftCellOffset;
@property (nonatomic, strong, nullable) NSString *topLeftCellReference;

@end

@interface BRATwoCellAnchor : BRAOneCellAnchor

@property (nonatomic) CGPoint bottomRightCellOffset;
@property (nonatomic, strong, nullable) NSString *bottomRightCellReference;

@end

@interface BRAWorksheetDrawing : BRAOpenXmlSubElement
@property (nonatomic, weak, nullable) BRADrawing *drawing;
@property (nonatomic, getter=shouldKeepAspectRatio) BOOL keepAspectRatio;
@property (nonatomic) BRANativeEdgeInsets insets;
@property (nonatomic, strong) BRAAnchor *anchor;
@property (nonatomic, strong, nullable) NSString *name;
@property (nonatomic, strong, nullable) NSString *identifier;
@property (nonatomic, strong, nullable) NSString *drawingIdentifier;
@property (nonatomic, strong, nullable) BRAImage *image;

- (instancetype)initWithImage:(BRAImage *)image andAnchor:(BRAAnchor *)anchor;

@end


NS_ASSUME_NONNULL_END
