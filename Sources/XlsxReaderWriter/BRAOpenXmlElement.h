//
//  BRAOpenXmlElement.h
//  BRAXlsxReaderWriter
//
//  Created by René BIGOT on 05/10/2014.
//  Copyright (c) 2014 René Bigot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSDictionary+OpenXMLDictionaryParser.h"

#define NOT_IMPLEMENTED NSAssert2(NO, @"%s is not implemented in %@", __PRETTY_FUNCTION__, [super class]);

NS_ASSUME_NONNULL_BEGIN

@interface BRAOpenXmlElement : NSObject

@property (nonatomic, strong, nullable) NSString *target;
@property (nonatomic, strong, nullable) NSString *parentDirectory;
@property (nonatomic, strong, nullable) NSString *xmlRepresentation;
@property (nonatomic, strong, nullable) NSData *dataRepresentation;

- (nullable instancetype)initWithContentsOfTarget:(nullable NSString *)target inParentDirectory:(nullable NSString *)parentDirectory;
- (instancetype)initWithTarget:(NSString *)target inParentDirectory:(NSString *)parentDirectory;
- (void)loadXmlContents;
- (void)save;

@end


NS_ASSUME_NONNULL_END
