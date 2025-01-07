//
//  BRATheme.h
//  XlsxReaderWriter
//
//  Created by René BIGOT on 06/07/2015.
//  Copyright (c) 2015 BRAE. All rights reserved.
//

#import "BRARelationship.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRATheme : BRARelationship

@property (nonatomic, strong, readonly) NSArray<BRANativeColor *> *colors;

@end

NS_ASSUME_NONNULL_END
