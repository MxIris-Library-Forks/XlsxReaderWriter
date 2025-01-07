//
//  ArrayOperationMacro.h
//  Pods
//
//  Created by JH on 2024/3/20.
//

#ifndef ArrayOperationMacro_h
#define ArrayOperationMacro_h

#define NSArrayCRUDOperationInterface(Class, Element, ParamName)        \
- (void)add##Element:(Class)ParamName;                                  \
- (void)remove##Element:(Class)ParamName;                               \
- (void)set##Element:(Class)ParamName atIndex:(NSInteger)index;         \
- (void)set##Element##s:(NSArray<Class> *)ParamName##s;

#define NSArrayCRUDOperationImplementation(Class, Element, ParamName)   \
- (void)add##Element:(Class)ParamName {                                 \
    [self.mutable##Element##s addObject:ParamName];                     \
}                                                                       \
- (void)remove##Element:(Class)ParamName {                              \
    [self.mutable##Element##s removeObject:ParamName];                  \
}                                                                       \
- (void)set##Element##s:(NSArray<Class> *)ParamName##s {                \
    self.mutable##Element##s = ParamName##s.mutableCopy;                \
}                                                                       \
- (void)set##Element:(Class)ParamName atIndex:(NSInteger)index {        \
    self.mutable##Element##s[index] = ParamName;                        \
}

#define NSArrayAddOperationImplementation(Class, Element, ParamName)    \
- (void)add##Element:(Class)ParamName {                                 \
    [self.mutable##Element##s addObject:ParamName];                     \
}

#define NSArrayRemoveOperationImplementation(Class, Element, ParamName) \
- (void)remove##Element:(Class)ParamName {                              \
    [self.mutable##Element##s removeObject:ParamName];                  \
}

#define NSArraySetsOperationImplementation(Class, Element, ParamName)   \
- (void)set##Element##s:(NSArray<Class> *)ParamName##s {                \
    self.mutable##Element##s = ParamName##s.mutableCopy;                \
}

#define NSArraySetOperationImplementation(Class, Element, ParamName)    \
- (void)set##Element:(Class)ParamName atIndex:(NSInteger)index {        \
    self.mutable##Element##s[index] = ParamName;                        \
}

#endif /* ArrayOperationMacro_h */
