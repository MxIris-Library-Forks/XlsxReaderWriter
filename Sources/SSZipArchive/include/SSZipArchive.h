//
//  Header.h
//  
//
//  Created by JH on 2024/3/22.
//

#ifndef Header_h
#define Header_h

#if __has_include(<SSZipArchive/SSZipArchive.h>)
#import <SSZipArchive/SSZipArchive.h>
#elif __has_include("../SSZipArchive.h")
#import "../SSZipArchive.h"
#else
#import "SSZipArchive.h"
#endif

#endif /* Header_h */
