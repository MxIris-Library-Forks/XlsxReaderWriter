//
//  BRACellBorder.h
//  
//
//  Created by JH on 2024/3/25.
//

#import <Foundation/Foundation.h>
#import "BRAPlatformSpecificDefines.h"
#import "BRAOpenXmlSubElement.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRACellBorderEdge : NSObject
@property (nonatomic, copy) NSString *style;
@property (nonatomic, strong, nullable) BRANativeColor *color;
@end


@interface BRACellBorder : BRAOpenXmlSubElementWithStyle

@property (nonatomic, strong, nullable) BRACellBorderEdge *leftEdge;
@property (nonatomic, strong, nullable) BRACellBorderEdge *topEdge;
@property (nonatomic, strong, nullable) BRACellBorderEdge *rightEdge;
@property (nonatomic, strong, nullable) BRACellBorderEdge *bottomEdge;



@end

NS_ASSUME_NONNULL_END
