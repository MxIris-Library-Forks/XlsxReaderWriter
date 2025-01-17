//
//  BRARelatedToColumnAndRowProtocol.h
//  XlsxReaderWriter
//
//  Created by René BIGOT on 23/09/2015.
//  Copyright © 2015 BRAE. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol BRARelatedToColumnAndRowProtocol <NSObject>

@required
- (void)didAddRowsAtIndexes:(NSIndexSet *)indexes;
- (void)didRemoveRowsAtIndexes:(NSIndexSet *)indexes;
- (void)didAddColumnsAtIndexes:(NSIndexSet *)indexes;
- (void)didRemoveColumnsAtIndexes:(NSIndexSet *)indexes;

@end

NS_ASSUME_NONNULL_END
