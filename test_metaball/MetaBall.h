//
//  MetaBall.h
//  test_metaball
//
//  Created by 赵小健 on 3/7/16.
//  Copyright © 2016 赵小健. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface MetaBall : NSObject

@property float size; //size of this metaball, the radius.
@property CGPoint location; //location of this metabal

-(instancetype)initWithSize:(float)size location:(CGPoint)location;

@end
