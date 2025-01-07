//
//  BRAContentTypesOverride.h
//  BRAXlsxReaderWriter
//
//  Created by René BIGOT on 23/10/2014.
//  Copyright (c) 2014 René Bigot. All rights reserved.
//

#import "BRAOpenXmlSubElement.h"

@class BRARelationship;

NS_ASSUME_NONNULL_BEGIN

@interface BRAContentTypesOverride : BRAOpenXmlSubElement

- (instancetype)initWithContentType:(NSString *)contentType forPart:(NSString *)partName;

@property (nonatomic, strong) NSString *partName;
@property (nonatomic, strong) NSString *contentType;

@end


NS_ASSUME_NONNULL_END
