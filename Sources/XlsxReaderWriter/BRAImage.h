//
//  BRAImage.h
//  BRAXlsxReaderWriter
//
//  Created by René BIGOT on 22/10/2014.
//  Copyright (c) 2014 René Bigot. All rights reserved.
//

#import "BRARelationship.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRAImage : BRARelationship

@property (nonatomic, getter=isJpeg) BOOL jpeg;
@property (nonatomic, strong, nullable) BRANativeImage *nativeImage;

@end

NS_ASSUME_NONNULL_END
