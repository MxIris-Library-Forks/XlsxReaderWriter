//
//  BRAElementWithRelationships.h
//  BRAXlsxReaderWriter
//
//  Created by René BIGOT on 03/10/2014.
//  Copyright (c) 2014 René Bigot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BRAOpenXmlElement.h"
#import "NSDictionary+OpenXMLDictionaryParser.h"

@class BRARelationships;

NS_ASSUME_NONNULL_BEGIN

@interface BRAElementWithRelationships : BRAOpenXmlElement

@property (nonatomic, strong, nullable) BRARelationships *relationships;

- (NSString *)relationshipsTarget;

@end


NS_ASSUME_NONNULL_END
