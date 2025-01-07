//
//  NSDictionary+OpenXmlString.h
//  BRAXlsxReaderWriter
//
//  Created by René BIGOT on 03/09/2014.
//  Copyright (c) 2014 René Bigot. All rights reserved.
//

#if __has_include(<XMLDictionary/XMLDictionary.h>)
#import <XMLDictionary/XMLDictionary.h>
#else
#import "XMLDictionary.h"
#endif


@interface NSDictionary (OpenXmlString)

- (NSString *)openXmlStringInNodeNamed:(NSString *)nodeName;

@end
