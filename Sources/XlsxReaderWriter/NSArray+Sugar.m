//
//  NSArray+Sugar.m
//  FormMaster
//
//  Created by JH on 2022/11/22.
//  Copyright © 2022 FormMaster. All rights reserved.
//

#import "NSArray+Sugar.h"

@implementation NSArray (Sugar)

- (NSMutableSet *)BRA_toMutableSet {
    return [NSMutableSet setWithArray:self];
}

- (NSSet *)BRA_toSet {
    return [NSSet setWithArray:self];
}

- (NSMutableArray *)BRA_toMutable {
    return [NSMutableArray arrayWithArray:self];
}

- (nullable id)BRA_objectAtSafeIndex:(NSUInteger)safeIndex {
    return safeIndex < self.count ? self[safeIndex] : nil;
}

- (NSNumber *)BRA_countValue {
    return [NSNumber numberWithUnsignedInteger:self.count];
}

@end
