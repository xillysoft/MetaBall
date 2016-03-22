//
//  MetaBallView.h
//  test_metaball
//
//  Created by 赵小健 on 3/7/16.
//  Copyright © 2016 赵小健. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MetaBallModel.h"
#import <GLKit/GLKit.h>

@interface MetaBallView : GLKView

@property(weak) MetaBallModel *metaBallModel;

@property(readwrite, nonatomic) CGFloat threshold;
@property(readwrite, nonatomic) CGFloat gridSize;
@property(readwrite, nonatomic) BOOL interpolation;
@property(readwrite, nonatomic) BOOL useNaivePainting;


@end
