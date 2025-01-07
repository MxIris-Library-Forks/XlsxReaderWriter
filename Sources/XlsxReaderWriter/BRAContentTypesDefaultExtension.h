//
//  BRAContentTypesDefaultExtension.h
//  BRAXlsxReaderWriter
//
//  Created by René BIGOT on 23/10/2014.
//  Copyright (c) 2014 René Bigot. All rights reserved.
//

#import "BRAOpenXmlSubElement.h"

@class BRARelationship;

NS_ASSUME_NONNULL_BEGIN

@interface BRAContentTypesDefaultExtension : BRAOpenXmlSubElement

- (nullable instancetype)initWithExtension:(NSString *)extension;

@property (nonatomic, strong) NSString *extension;
@property (nonatomic, strong) NSString *contentType;

@end


NS_ASSUME_NONNULL_END
