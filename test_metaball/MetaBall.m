//
//  MetaBall.m
//  test_metaball
//
//  Created by 赵小健 on 3/7/16.
//  Copyright © 2016 赵小健. All rights reserved.
//

#import "MetaBall.h"

@implementation MetaBall

-(instancetype)initWithSize:(CGFloat)size location:(CGPoint)location
{
    self = [super init];
    self.size = size;
    self.location = location;
    return self;
}

@end
