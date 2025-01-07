//
//  BRARelationship.h
//  BRAXlsxReaderWriter
//
//  Created by René BIGOT on 05/10/2014.
//  Copyright (c) 2014 René Bigot. All rights reserved.
//

#import <Foundation/Foundation.h>
#if __has_include(<XMLDictionary/XMLDictionary.h>)
#import <XMLDictionary/XMLDictionary.h>
#else
#import "XMLDictionary.h"
#endif
#import "NativeColor+OpenXML.h"
#import "BRAElementWithRelationships.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRARelationship : BRAElementWithRelationships

+ (NSString *)fullRelationshipType;
- (instancetype)initWithId:(NSString *)relationshipId type:(NSString *)relationshipType andTarget:(NSString *)relationTarget inParentDirectory:(NSString *)parentDirectory;
- (instancetype)initWithXmlRepresentation:(NSString *)xmlRepresentation forRelationId:(NSString *)relationId inParentDirectory:(NSString *)parentDirectory;
- (instancetype)initWithDataRepresentation:(NSData *)dataRepresentation forRelationId:(NSString *)relationId inParentDirectory:(NSString *)parentDirectory;
- (NSString *)contentType;
- (NSString *)targetFormat;
- (NSString *)newTarget;

@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *type;

@end

NS_ASSUME_NONNULL_END
