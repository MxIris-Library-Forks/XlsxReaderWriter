//
//  NSArray+Sugar.h
//  FormMaster
//
//  Created by JH on 2022/11/22.
//  Copyright © 2022 FormMaster. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray<ObjectType> (Sugar)
- (NSSet<ObjectType> *)BRA_toSet;
- (NSMutableSet<ObjectType> *)BRA_toMutableSet;
- (NSMutableArray<ObjectType> *)BRA_toMutable;
- (nullable ObjectType)BRA_objectAtSafeIndex:(NSUInteger)safeIndex;
- (NSNumber *)BRA_countValue;
@end

NS_ASSUME_NONNULL_END
