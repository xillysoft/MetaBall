//
//  MetaBallModel.m
//  test_metaball
//
//  Created by 赵小健 on 3/7/16.
//  Copyright © 2016 赵小健. All rights reserved.
//

#import "MetaBallModel.h"

@implementation MetaBallModel


-(instancetype)init
{
    self = [super init];
    if(self) {
        self.metaBalls = ({
            [[NSMutableArray alloc] init];
        });
        
        self.goo = 1.5;
        self.threshold = 5;
    }
    return self;
}

@end
