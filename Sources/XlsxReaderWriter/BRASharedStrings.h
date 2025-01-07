//
//  BRASharedStrings.h
//  BRAXlsxReaderWriter
//
//  Created by René BIGOT on 05/10/2014.
//  Copyright (c) 2014 René Bigot. All rights reserved.
//

#import "BRARelationship.h"
#import "BRASharedString.h"

@class BRAStyles;

NS_ASSUME_NONNULL_BEGIN

@interface BRASharedStrings : BRARelationship

- (void)addSharedString:(BRASharedString *)sharedString;

@property (nonatomic, weak, nullable) BRAStyles *styles;
@property (nonatomic, strong) NSArray<BRASharedString *> *sharedStrings;

@end

NS_ASSUME_NONNULL_END
