//
//  MetaBallModel.h
//  test_metaball
//
//  Created by 赵小健 on 3/7/16.
//  Copyright © 2016 赵小健. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "MetaBall.h"

@interface MetaBallModel : NSObject

@property float goo; //"goo"-value, which affects the way how metaballs are drawn.
@property float threshold; //theshold for metaballs
@property NSMutableArray<MetaBall *> *metaBalls; //metaballs of this model

//initialize with no metaball
-(instancetype)init NS_DESIGNATED_INITIALIZER;

@end
