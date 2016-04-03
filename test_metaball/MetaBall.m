//
//  MetaBall.m
//  test_metaball
//
//  Created by 赵小健 on 3/7/16.
//  Copyright © 2016 赵小健. All rights reserved.
//

#import "MetaBall.h"


static inline float distance2(float x1, float y1, float x2, float y2)
{
    float dx = x2-x1;
    float dy = y2-y1;
    return (dx*dx+dy*dy);
}

static inline float distance(float x1, float y1, float x2, float y2)
{
    return sqrt(distance2(x1, y1, x2, y2));
}




@implementation MetaBall

-(instancetype)initWithSize:(float)size x:(float)x y:(float)y
{
    self = [super init];
    if(self){
        _size = size;
        _x = x;
        _y = y;
    }
    return self;
}

-(NSString *)description
{
    return [NSString stringWithFormat:@"MetaBall[size=%.2f, location=(%.2f,%.2f)]", self.size, self.x, self.y];
}

-(float)intensityWithX:(float)x y:(float)y goo:(float)goo
{
    float dis = distance(self.x, self.y, x, y);
//    float v = dis<=self.size ? 1.0 : self.size/pow(dis, goo);
    float v = dis<=self.size ? 1.0 : pow(self.size/dis, goo);
    return v;
}
@end
