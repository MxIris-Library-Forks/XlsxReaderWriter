//
//  SSZipArchive.m
//  SSZipArchive
//
//  Created by Sam Soffes on 7/21/10.
//  Copyright (c) Sam Soffes 2010-2013. All rights reserved.
//

#import "SSZipArchive.h"
#if __has_include("../minizip/zip.h")
#include "../minizip/zip.h"
#else
#include "zip.h"
#endif
#import "zlib.h"
#import "zconf.h"

#include <sys/stat.h>

#define CHUNK 16384

@interface SSZipArchive ()
+ (NSDate *)_dateWithMSDOSFormat:(UInt32)msdosDateTime;
@end


@implementation SSZipArchive {
	NSString *_path;
	NSString *_filename;
    zipFile _zip;
}


#pragma mark - Unzipping

+ (BOOL)unzipFileAtPath:(NSString *)path toDestination:(NSString *)destination {
	return [self unzipFileAtPath:path toDestination:destination delegate:nil];
}


+ (BOOL)unzipFileAtPath:(NSString *)path toDestination:(NSString *)destination overwrite:(BOOL)overwrite password:(NSString *)password error:(NSError **)error {
	return [self unzipFileAtPath:path toDestination:destination overwrite:overwrite password:password error:error delegate:nil];
}


+ (BOOL)unzipFileAtPath:(NSString *)path toDestination:(NSString *)destination delegate:(id<SSZipArchiveDelegate>)delegate {
	return [self unzipFileAtPath:path toDestination:destination overwrite:YES password:nil error:nil delegate:delegate];
}


+ (BOOL)unzipFileAtPath:(NSString *)path toDestination:(NSString *)destination overwrite:(BOOL)overwrite password:(NSString *)password error:(NSError **)error delegate:(id<SSZipArchiveDelegate>)delegate {
	// Begin opening
	zipFile zip = unzOpen((const char*)[path UTF8String]);	
	if (zip == NULL) {
		NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"failed to open zip file" forKey:NSLocalizedDescriptionKey];
		if (error) {
			*error = [NSError errorWithDomain:@"SSZipArchiveErrorDomain" code:-1 userInfo:userInfo];
		}
		return NO;
	}
	
	unz_global_info  globalInfo = {0ul, 0ul};
	unzGetGlobalInfo(zip, &globalInfo);
	
	// Begin unzipping
	if (unzGoToFirstFile(zip) != UNZ_OK) {
		NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"failed to open first file in zip file" forKey:NSLocalizedDescriptionKey];
		if (error) {
			*error = [NSError errorWithDomain:@"SSZipArchiveErrorDomain" code:-2 userInfo:userInfo];
		}
		return NO;
	}
	
	BOOL success = YES;
	int ret = 0;
	unsigned char buffer[4096] = {0};
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSMutableSet *directoriesModificationDates = [[NSMutableSet alloc] init];
	
	// Message delegate
	if ([delegate respondsToSelector:@selector(zipArchiveWillUnzipArchiveAtPath:zipInfo:)]) {
		[delegate zipArchiveWillUnzipArchiveAtPath:path zipInfo:globalInfo];
	}
	
	NSInteger currentFileNumber = 0;
	do {
		@autoreleasepool {
			if ([password length] == 0) {
				ret = unzOpenCurrentFile(zip);
			} else {
				ret = unzOpenCurrentFilePassword(zip, [password cStringUsingEncoding:NSASCIIStringEncoding]);
			}
			
			if (ret != UNZ_OK) {
				success = NO;
				break;
			}
			
			// Reading data and write to file
			unz_file_info fileInfo;
			memset(&fileInfo, 0, sizeof(unz_file_info));
			
			ret = unzGetCurrentFileInfo(zip, &fileInfo, NULL, 0, NULL, 0, NULL, 0);
			if (ret != UNZ_OK) {
				success = NO;
				unzCloseCurrentFile(zip);
				break;
			}
			
			// Message delegate
			if ([delegate respondsToSelector:@selector(zipArchiveWillUnzipFileAtIndex:totalFiles:archivePath:fileInfo:)]) {
				[delegate zipArchiveWillUnzipFileAtIndex:currentFileNumber totalFiles:(NSInteger)globalInfo.number_entry
											 archivePath:path fileInfo:fileInfo];
			}
	        
			char *filename = (char *)malloc(fileInfo.size_filename + 1);
			unzGetCurrentFileInfo(zip, &fileInfo, filename, fileInfo.size_filename + 1, NULL, 0, NULL, 0);
			filename[fileInfo.size_filename] = '\0';
	        
	        //
	        // NOTE
	        // I used the ZIP spec from here:
	        // http://www.pkware.com/documents/casestudies/APPNOTE.TXT
	        //
	        // ...to deduce this method of detecting whether the file in the ZIP is a symbolic link.
	        // If it is, it is listed as a directory but has a data size greater than zero (real 
	        // directories have it equal to 0) and the included, uncompressed data is the symbolic link path.
	        //
	        // ZIP files did not originally include support for symbolic links so the specification
	        // doesn't include anything in them that isn't part of a unix extension that isn't being used
	        // by the archivers we're testing. Most of this is figured out through trial and error and
	        // reading ZIP headers in hex editors. This seems to do the trick though.
	        //
	        
	        const uLong ZipCompressionMethodStore = 0;
	        
	        BOOL fileIsSymbolicLink = NO;
	        
	        if((fileInfo.compression_method == ZipCompressionMethodStore) && // Is it compressed?
	           (S_ISDIR(fileInfo.external_fa)) && // Is it marked as a directory
	           (fileInfo.compressed_size > 0)) // Is there any data?
	        {
	            fileIsSymbolicLink = YES;
	        }
	        
			// Check if it contains directory
			NSString *strPath = [NSString stringWithCString:filename encoding:NSUTF8StringEncoding];
			BOOL isDirectory = NO;
			if (filename[fileInfo.size_filename-1] == '/' || filename[fileInfo.size_filename-1] == '\\') {
				isDirectory = YES;
			}
			free(filename);
			
			// Contains a path
			if ([strPath rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"/\\"]].location != NSNotFound) {
				strPath = [strPath stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
			}
			
			NSString *fullPath = [destination stringByAppendingPathComponent:strPath];
			NSError *err = nil;
	        NSDate *modDate = [[self class] _dateWithMSDOSFormat:(UInt32)fileInfo.dosDate];
	        NSDictionary *directoryAttr = [NSDictionary dictionaryWithObjectsAndKeys:modDate, NSFileCreationDate, modDate, NSFileModificationDate, nil];
			
			if (isDirectory) {
				[fileManager createDirectoryAtPath:fullPath withIntermediateDirectories:YES attributes:directoryAttr  error:&err];
			} else {
				[fileManager createDirectoryAtPath:[fullPath stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:directoryAttr error:&err];
			}
	        if (nil != err) {
	            NSLog(@"[SSZipArchive] Error: %@", err.localizedDescription);
	        }
	
	        if(!fileIsSymbolicLink)
	            [directoriesModificationDates addObject: [NSDictionary dictionaryWithObjectsAndKeys:fullPath, @"path", modDate, @"modDate", nil]];
	
	        if ([fileManager fileExistsAtPath:fullPath] && !isDirectory && !overwrite) {
				unzCloseCurrentFile(zip);
				ret = unzGoToNextFile(zip);
				continue;
			}
	        
			if(!fileIsSymbolicLink)
	        {
	            FILE *fp = fopen((const char*)[fullPath UTF8String], "wb");
	            while (fp) {
	                int readBytes = unzReadCurrentFile(zip, buffer, 4096);
	
	                if (readBytes > 0) {
	                    fwrite(buffer, readBytes, 1, fp );
	                } else {
	                    break;
	                }
	            }
	            
	            if (fp) {
	                fclose(fp);
	                
	                // Set the original datetime property
	                if (fileInfo.dosDate != 0) {
	                    NSDate *orgDate = [[self class] _dateWithMSDOSFormat:(UInt32)fileInfo.dosDate];
	                    NSDictionary *attr = [NSDictionary dictionaryWithObject:orgDate forKey:NSFileModificationDate];
	                    
	                    if (attr) {
	                        if ([fileManager setAttributes:attr ofItemAtPath:fullPath error:nil] == NO) {
	                            // Can't set attributes 
	                            NSLog(@"[SSZipArchive] Failed to set attributes - whilst setting modification date");
	                        }
	                    }
	                }
                    
                    // Set the original permissions on the file
                    uLong permissions = fileInfo.external_fa >> 16;
                    if (permissions != 0) {
                        // Store it into a NSNumber
                        NSNumber *permissionsValue = @(permissions);
                        
                        // Retrieve any existing attributes
                        NSMutableDictionary *attrs = [[NSMutableDictionary alloc] initWithDictionary:[fileManager attributesOfItemAtPath:fullPath error:nil]];
                        
                        // Set the value in the attributes dict
                        attrs[NSFilePosixPermissions] = permissionsValue;
                        
                        // Update attributes
                        if ([fileManager setAttributes:attrs ofItemAtPath:fullPath error:nil] == NO) {
                            // Unable to set the permissions attribute
                            NSLog(@"[SSZipArchive] Failed to set attributes - whilst setting permissions");
                        }
                    }
	            }
	        }
            else
            {
                // Assemble the path for the symbolic link
                NSMutableString* destinationPath = [NSMutableString string];
                int bytesRead = 0;
                while((bytesRead = unzReadCurrentFile(zip, buffer, 4096)) > 0)
                {
                    buffer[bytesRead] = 0;
                    [destinationPath appendString:[NSString stringWithUTF8String:(const char*)buffer]];
                }

                // Create the symbolic link (making sure it stays relative if it was relative before)
                int symlinkError = symlink([destinationPath cStringUsingEncoding:NSUTF8StringEncoding],
                                           [fullPath cStringUsingEncoding:NSUTF8StringEncoding]);

                if(symlinkError != 0)
                {
                    NSLog(@"Failed to create symbolic link at \"%@\" to \"%@\". symlink() error code: %d", fullPath, destinationPath, errno);
                }
            }

			unzCloseCurrentFile( zip );
			ret = unzGoToNextFile( zip );
			
			// Message delegate
			if ([delegate respondsToSelector:@selector(zipArchiveDidUnzipFileAtIndex:totalFiles:archivePath:fileInfo:)]) {
				[delegate zipArchiveDidUnzipFileAtIndex:currentFileNumber totalFiles:(NSInteger)globalInfo.number_entry
											 archivePath:path fileInfo:fileInfo];
			}
			
			currentFileNumber++;
		}
	} while(ret == UNZ_OK && ret != UNZ_END_OF_LIST_OF_FILE);
	
	// Close
	unzClose(zip);
	
	// The process of decompressing the .zip archive causes the modification times on the folders
    // to be set to the present time. So, when we are done, they need to be explicitly set.
    // set the modification date on all of the directories.
    NSError * err = nil;
    for (NSDictionary * d in directoriesModificationDates) {
        if (![[NSFileManager defaultManager] setAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[d objectForKey:@"modDate"], NSFileModificationDate, nil] ofItemAtPath:[d objectForKey:@"path"] error:&err]) {
            NSLog(@"[SSZipArchive] Set attributes failed for directory: %@.", [d objectForKey:@"path"]);
        }
        if (err) {
            NSLog(@"[SSZipArchive] Error setting directory file modification date attribute: %@",err.localizedDescription);
        }
    }
	
#if !__has_feature(objc_arc)
	[directoriesModificationDates release];
#endif
	
	// Message delegate
	if (success && [delegate respondsToSelector:@selector(zipArchiveDidUnzipArchiveAtPath:zipInfo:unzippedPath:)]) {
		[delegate zipArchiveDidUnzipArchiveAtPath:path zipInfo:globalInfo unzippedPath:destination];
	}
	
	return success;
}


#pragma mark - Zipping

+ (BOOL)createZipFileAtPath:(NSString *)path withFilesAtPaths:(NSArray *)paths {
	BOOL success = NO;
	SSZipArchive *zipArchive = [[SSZipArchive alloc] initWithPath:path];
	if ([zipArchive open]) {
		for (NSString *path in paths) {
			[zipArchive writeFile:path];
		}
		success = [zipArchive close];        
	}
	
#if !__has_feature(objc_arc)
	[zipArchive release];
#endif

	return success;
}


+ (BOOL)createZipFileAtPath:(NSString *)path withContentsOfDirectory:(NSString *)directoryPath {
    BOOL success = NO;
    
    NSFileManager *fileManager = nil;
	SSZipArchive *zipArchive = [[SSZipArchive alloc] initWithPath:path];
    
	if ([zipArchive open]) {
        // use a local filemanager (queue/thread compatibility)
        fileManager = [[NSFileManager alloc] init];
        NSDirectoryEnumerator *dirEnumerator = [fileManager enumeratorAtPath:directoryPath];
        
		NSString *fileName;
        while ((fileName = [dirEnumerator nextObject])) {
            BOOL isDir;
            NSString *fullFilePath = [directoryPath stringByAppendingPathComponent:fileName];
            [fileManager fileExistsAtPath:fullFilePath isDirectory:&isDir];
            if (!isDir) {
                [zipArchive writeFileAtPath:fullFilePath withFileName:fileName];
            }
        }
        success = [zipArchive close];
	}
	
#if !__has_feature(objc_arc)
    [fileManager release];
	[zipArchive release];
#endif
    
	return success;
}


- (id)initWithPath:(NSString *)path {
	if ((self = [super init])) {
		_path = [path copy];
	}
	return self;
}


#if !__has_feature(objc_arc)
- (void)dealloc {
    [_path release];
	[super dealloc];
}
#endif


- (BOOL)open {    
	NSAssert((_zip == NULL), @"Attempting open an archive which is already open");
	_zip = zipOpen([_path UTF8String], APPEND_STATUS_CREATE);
	return (NULL != _zip);
}


- (void)zipInfo:(zip_fileinfo*)zipInfo setDate:(NSDate*)date {
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    uint flags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *components = [currentCalendar components:flags fromDate:date];
    zipInfo->tmz_date.tm_sec = (unsigned int)components.second;
    zipInfo->tmz_date.tm_min = (unsigned int)components.minute;
    zipInfo->tmz_date.tm_hour = (unsigned int)components.hour;
    zipInfo->tmz_date.tm_mday = (unsigned int)components.day;
    zipInfo->tmz_date.tm_mon = (unsigned int)components.month - 1;
    zipInfo->tmz_date.tm_year = (unsigned int)components.year;
}


- (BOOL)writeFile:(NSString *)path
{
    return [self writeFileAtPath:path withFileName:nil];
}

// supports writing files with logical folder/directory structure
// *path* is the absolute path of the file that will be compressed
// *fileName* is the relative name of the file how it is stored within the zip e.g. /folder/subfolder/text1.txt
- (BOOL)writeFileAtPath:(NSString *)path withFileName:(NSString *)fileName {
    NSAssert((_zip != NULL), @"Attempting to write to an archive which was never opened");
    
	FILE *input = fopen([path UTF8String], "r");
	if (NULL == input) {
		return NO;
	}
    
    const char *afileName;
    if (!fileName) {
        afileName = [path.lastPathComponent UTF8String];
    }
    else {
        afileName = [fileName UTF8String];
    }
    
    zip_fileinfo zipInfo = {{0}};

    NSDictionary *attr = [[NSFileManager defaultManager] attributesOfItemAtPath:path error: nil];
    if( attr )
    {
        NSDate *fileDate = (NSDate *)[attr objectForKey:NSFileModificationDate];
        if( fileDate )
        {
            [self zipInfo:&zipInfo setDate: fileDate ];
        }
        
        // Write permissions into the external attributes, for details on this see here: http://unix.stackexchange.com/a/14727
        // Get the permissions value from the files attributes
        NSNumber *permissionsValue = (NSNumber *)[attr objectForKey:NSFilePosixPermissions];
        if (permissionsValue) {
            // Get the short value for the permissions
            short permissionsShort = permissionsValue.shortValue;
            
            // Convert this into an octal by adding 010000, 010000 being the flag for a regular file
            NSInteger permissionsOctal = 0100000 + permissionsShort;
            
            // Convert this into a long value
            uLong permissionsLong = @(permissionsOctal).unsignedLongValue;
            
            // Store this into the external file attributes once it has been shifted 16 places left to form part of the second from last byte
            zipInfo.external_fa = permissionsLong << 16L;
        }
    }
	
    zipOpenNewFileInZip(_zip, afileName, &zipInfo, NULL, 0, NULL, 0, NULL, Z_DEFLATED, Z_DEFAULT_COMPRESSION);
    
	void *buffer = malloc(CHUNK);
	unsigned int len = 0;
	
    while (!feof(input))
    {
		len = (unsigned int) fread(buffer, 1, CHUNK, input);
		zipWriteInFileInZip(_zip, buffer, len);
	}
    
	zipCloseFileInZip(_zip);
	free(buffer);
	fclose(input);
	return YES;
}


- (BOOL)writeData:(NSData *)data filename:(NSString *)filename {
    if (!_zip) {
		return NO;
    }
    if (!data) {
		return NO;
    }
    zip_fileinfo zipInfo = {{0,0,0,0,0,0},0,0,0};
    [self zipInfo:&zipInfo setDate:[NSDate date]];

	zipOpenNewFileInZip(_zip, [filename UTF8String], &zipInfo, NULL, 0, NULL, 0, NULL, Z_DEFLATED, Z_DEFAULT_COMPRESSION);

    zipWriteInFileInZip(_zip, data.bytes, (unsigned int)data.length);

	zipCloseFileInZip(_zip);
	return YES;
}


- (BOOL)close {    
	NSAssert((_zip != NULL), @"[SSZipArchive] Attempting to close an archive which was never opened");
	zipClose(_zip, NULL);
	return YES;
}


#pragma mark - Private

// Format from http://newsgroups.derkeiler.com/Archive/Comp/comp.os.msdos.programmer/2009-04/msg00060.html
// Two consecutive words, or a longword, YYYYYYYMMMMDDDDD hhhhhmmmmmmsssss
// YYYYYYY is years from 1980 = 0
// sssss is (seconds/2).
//
// 3658 = 0011 0110 0101 1000 = 0011011 0010 11000 = 27 2 24 = 2007-02-24
// 7423 = 0111 0100 0010 0011 - 01110 100001 00011 = 14 33 2 = 14:33:06
+ (NSDate *)_dateWithMSDOSFormat:(UInt32)msdosDateTime {
	static const UInt32 kYearMask = 0xFE000000;
	static const UInt32 kMonthMask = 0x1E00000;
	static const UInt32 kDayMask = 0x1F0000;
	static const UInt32 kHourMask = 0xF800;
	static const UInt32 kMinuteMask = 0x7E0;
	static const UInt32 kSecondMask = 0x1F;
	
	static NSCalendar *gregorian;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
        gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
	});
    
    NSDateComponents *components = [[NSDateComponents alloc] init];

    NSAssert(0xFFFFFFFF == (kYearMask | kMonthMask | kDayMask | kHourMask | kMinuteMask | kSecondMask), @"[SSZipArchive] MSDOS date masks don't add up");
	    
    [components setYear:1980 + ((msdosDateTime & kYearMask) >> 25)];
    [components setMonth:(msdosDateTime & kMonthMask) >> 21];
    [components setDay:(msdosDateTime & kDayMask) >> 16];
    [components setHour:(msdosDateTime & kHourMask) >> 11];
    [components setMinute:(msdosDateTime & kMinuteMask) >> 5];
    [components setSecond:(msdosDateTime & kSecondMask) * 2];
    
    NSDate *date = [NSDate dateWithTimeInterval:0 sinceDate:[gregorian dateFromComponents:components]];
	
#if !__has_feature(objc_arc)
	[components release];
#endif
	
	return date;
}

@end
