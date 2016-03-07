//
//  ViewController.m
//  test_metaball
//
//  Created by 赵小健 on 3/7/16.
//  Copyright © 2016 赵小健. All rights reserved.
//

#import "ViewController.h"
#import "MetaBallModel.h"
#import "MetaBallView.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet MetaBallView *metaBallView;
@property(strong) MetaBallModel *metaBallModel;
@end

int _rand(int low, int high)
{
    return low + arc4random_uniform(high-low);
}

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    CGRect bounds = self.view.bounds;
    
    //initialize MetaBall model
    self.metaBallModel = [[MetaBallModel alloc] init];
    {
        self.metaBallModel.goo = 1.5;
        self.metaBallModel.threshold = 1.0;
        
        int numberOfMetaBalls = 5;
        CGFloat minSize = 30;
        CGFloat maxSize = 150;
        for(int i=0; i<numberOfMetaBalls; i++){
            MetaBall *metaBall = [[MetaBall alloc] initWithSize:_rand(minSize, maxSize) location:CGPointMake(_rand(maxSize, bounds.size.width-maxSize), _rand(maxSize, bounds.size.height-maxSize))];
            [self.metaBallModel.metaBalls addObject:metaBall];
        }
    }
    
    self.metaBallView.metaBallModel = self.metaBallModel;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
