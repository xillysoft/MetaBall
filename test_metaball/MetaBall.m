//
//  MetaBall.m
//  test_metaball
//
//  Created by 赵小健 on 3/7/16.
//  Copyright © 2016 赵小健. All rights reserved.
//

#import "MetaBall.h"

@implementation MetaBall

-(instancetype)initWithSize:(float)size location:(CGPoint)location
{
    self = [super init];
    self.size = size;
    self.location = location;
    return self;
}

-(NSString *)description
{
    return [NSString stringWithFormat:@"MetaBall[size=%.2f, location=(%.2f,%.2f)]", self.size, self.location.x, self.location.y];
}
@end
