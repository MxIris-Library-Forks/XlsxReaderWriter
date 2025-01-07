//
//  BRARelationships.h
//  BRAXlsxReaderWriter
//
//  Created by René BIGOT on 04/10/2014.
//  Copyright (c) 2014 René Bigot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BRARelationship.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRARelationships : BRAOpenXmlElement

@property (nonatomic, strong, readonly) NSArray<__kindof BRARelationship *> *relationships;

- (nullable id)relationshipWithId:(NSString *)rId;
- (nullable id)anyRelationshipWithType:(NSString *)relationshipType;
- (void)addRelationship:(BRARelationship *)relationship;
- (void)removeRelationshipWithId:(NSString *)identifier;
- (NSArray<__kindof BRARelationship *> *)allRelationships;
- (nullable NSString *)relationshipIdForNewRelationship;

- (void)setRelationships:(NSArray<__kindof BRARelationship *> *)relationshipsArray;

@end

NS_ASSUME_NONNULL_END
