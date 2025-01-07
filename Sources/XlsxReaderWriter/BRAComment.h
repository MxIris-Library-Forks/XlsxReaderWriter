//
//  BRAComment.h
//  XlsxReaderWriter
//
//  Created by René BIGOT on 23/09/2015.
//  Copyright © 2015 BRAE. All rights reserved.
//

#import "BRAOpenXmlSubElement.h"

/** This class does not change the comments content.
  * It just handles rows and columns deletions / additions */

NS_ASSUME_NONNULL_BEGIN

@interface BRAComment : BRAOpenXmlSubElement

@property (nonatomic, strong, nullable) NSString *reference;

@end

NS_ASSUME_NONNULL_END

