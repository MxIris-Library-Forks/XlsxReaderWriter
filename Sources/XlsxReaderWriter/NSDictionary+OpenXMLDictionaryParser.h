//
//  NSDictionary+OpenXmlDictionaryParser.h
//  BRAXlsxReaderWriter
//
//  Created by René BIGOT on 19/06/2014.
//  Copyright (c) 2014 René Bigot. All rights reserved.
//

#if __has_include(<XMLDictionary/XMLDictionary.h>)
#import <XMLDictionary/XMLDictionary.h>
#else
#import "XMLDictionary.h"
#endif

@interface NSDictionary (OpenXmlDictionaryParser)

+ (NSDictionary *)dictionaryWithOpenXmlParser:(NSXMLParser *)parser;
+ (NSDictionary *)dictionaryWithOpenXmlData:(NSData *)data;
+ (NSDictionary *)dictionaryWithOpenXmlString:(NSString *)string;
+ (NSDictionary *)dictionaryWithOpenXmlFile:(NSString *)path;

@end
