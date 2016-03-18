//
//  GridValue.h
//  test_metaball
//
//  Created by 赵小健 on 3/18/16.
//  Copyright © 2016 赵小健. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//computed grid value
@interface GridValue : NSObject

@property(readwrite, nonatomic) float intensity;
@property(readwrite, nonatomic) BOOL binary; //inside: 1; outside:0;
@property(readwrite, nonatomic) UIColor *color; //color of this grid

@end
