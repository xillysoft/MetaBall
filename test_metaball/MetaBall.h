//
//  MetaBall.h
//  test_metaball
//
//  Created by 赵小健 on 3/7/16.
//  Copyright © 2016 赵小健. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

@interface MetaBall : NSObject

@property(nonatomic) float size; //size of this metaball, the radius.
@property(nonatomic) float x;
@property(nonatomic) float y;
@property(nonatomic) UIColor *color;

-(instancetype)initWithSize:(float)size x:(float)x y:(float)y;

//f(xi,yi,Si, x,y)::= r<=Si ? 1.0 : Si/r   {r=|(xi,yi), (x,y)|}
-(float)intensityWithX:(float)x y:(float)y goo:(float)goo;
@end
