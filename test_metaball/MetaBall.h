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

@property CGFloat size; //size of this metaball
@property CGPoint location; //location of this metabal

-(instancetype)initWithSize:(CGFloat)size location:(CGPoint)location NS_DESIGNATED_INITIALIZER;

@end
