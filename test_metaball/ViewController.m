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
#import <GLKit/GLKit.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet MetaBallView *metaBallView;
@property(strong) MetaBallModel *metaBallModel;

@property (weak, nonatomic) IBOutlet UISlider *sliderGridSize;
@property (weak, nonatomic) IBOutlet UILabel *labelGridSizeValue;
@property (weak, nonatomic) IBOutlet UISlider *sliderGooValue;
@property (weak, nonatomic) IBOutlet UILabel *labelGooValue;

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
        self.metaBallModel.goo = 1.2;
        self.metaBallModel.threshold = 1;
        
        float width = bounds.size.width;
        float height = bounds.size.height;
        
        int numberOfMetaBalls = 10;
        float minMetaballSize = 10;
        float maxMetaballSize = 20;
        for(int i=0; i<numberOfMetaBalls; i++){
            const float size = _rand(minMetaballSize, maxMetaballSize);
            const float x = _rand(maxMetaballSize, width-maxMetaballSize*2);
            const float y = _rand(maxMetaballSize, height-maxMetaballSize*2);
            MetaBall *metaBall = [[MetaBall alloc] initWithSize:size x:x  y:y];

            [self.metaBallModel.metaBalls addObject:metaBall];
        }
    }
    
    self.metaBallView.metaBallModel = self.metaBallModel;
    
    self.metaBallView.gridSize = 5;
    self.metaBallView.threshold = 1.0;

    
    self.sliderGridSize.minimumValue = 1;
    self.sliderGridSize.maximumValue = 20;
    self.sliderGridSize.value = self.metaBallView.gridSize;
    self.labelGridSizeValue.text = [NSString stringWithFormat:@"%.0f", self.sliderGridSize.value];
    [self.sliderGridSize addTarget:self action:@selector(sliderGridSizeValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    self.sliderGooValue.minimumValue = 0.9;
    self.sliderGooValue.maximumValue = 1.5;
    self.sliderGooValue.value = 1.1;
    self.labelGooValue.text = [NSString stringWithFormat:@"%.2f", self.sliderGooValue.value];
    [self.sliderGooValue addTarget:self action:@selector(sliderGooValueChanged:) forControlEvents:UIControlEventValueChanged];
}

-(void)sliderGridSizeValueChanged:(UISlider *)slider
{
    self.labelGridSizeValue.text = [NSString stringWithFormat:@"%.0f", slider.value];
    self.metaBallView.gridSize = slider.value;
}

-(void)sliderGooValueChanged:(UISlider *)slider
{
    self.labelGooValue.text = [NSString stringWithFormat:@"%.2f", self.sliderGooValue.value];
    self.metaBallModel.goo = slider.value;
    [self.metaBallView setNeedsDisplay];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
