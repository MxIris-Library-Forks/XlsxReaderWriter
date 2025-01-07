//
//  BRACellBorder.m
//  
//
//  Created by JH on 2024/3/25.
//

#import "BRACellBorder.h"
#import "BRAStyles.h"

@implementation BRACellBorderEdge

@end


@implementation BRACellBorder

- (void)loadAttributes {
    
    NSDictionary *dictionaryRepresentation = [super dictionaryRepresentation];
    
    NSString *topStyle = [dictionaryRepresentation valueForKeyPath:@"top._style"];
    if (topStyle) {
        _topEdge = [[BRACellBorderEdge alloc] init];
        _topEdge.style = topStyle;
        _topEdge.color = [self.styles colorWithOpenXmlAttributes:[dictionaryRepresentation valueForKeyPath:@"top.color"]];
    }
    
    
    NSString *leftStyle = [dictionaryRepresentation valueForKeyPath:@"left._style"];
    if (leftStyle) {
        _leftEdge = [[BRACellBorderEdge alloc] init];
        _leftEdge.style = leftStyle;
        _leftEdge.color = [self.styles colorWithOpenXmlAttributes:[dictionaryRepresentation valueForKeyPath:@"left.color"]];
    }
    
    NSString *rightStyle = [dictionaryRepresentation valueForKeyPath:@"right._style"];
    if (rightStyle) {
        _rightEdge = [[BRACellBorderEdge alloc] init];
        _rightEdge.style = rightStyle;
        _rightEdge.color = [self.styles colorWithOpenXmlAttributes:[dictionaryRepresentation valueForKeyPath:@"right.color"]];
    }
    
    NSString *bottomStyle = [dictionaryRepresentation valueForKeyPath:@"bottom._style"];
    if (bottomStyle) {
        _bottomEdge = [[BRACellBorderEdge alloc] init];
        _bottomEdge.style = bottomStyle;
        _bottomEdge.color = [self.styles colorWithOpenXmlAttributes:[dictionaryRepresentation valueForKeyPath:@"bottom.color"]];
    }
    
}


@end
