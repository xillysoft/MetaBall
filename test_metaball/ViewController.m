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

@property (weak, nonatomic) IBOutlet UISwitch *switchInterpolation;
@property (weak, nonatomic) IBOutlet UISwitch *switchPaintNaive;
@property (weak, nonatomic) IBOutlet UISlider *sliderGridSize;
@property (weak, nonatomic) IBOutlet UILabel *labelGridSizeValue;

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
        self.metaBallModel.goo = 1.0;
        self.metaBallModel.threshold = 1;
        
        float width = bounds.size.width;
        float height = bounds.size.height;
        
        int numberOfMetaBalls = 1;
        float minMetaballSize = 6;
        float maxMetaballSize = 40;
        for(int i=0; i<numberOfMetaBalls; i++){
            MetaBall *metaBall = [[MetaBall alloc] initWithSize:_rand(minMetaballSize, maxMetaballSize) location:CGPointMake(_rand(maxMetaballSize, width-maxMetaballSize*2), _rand(maxMetaballSize, height-maxMetaballSize*2))];
            [self.metaBallModel.metaBalls addObject:metaBall];
        }
    }
    
    self.metaBallView.metaBallModel = self.metaBallModel;
    
    self.metaBallView.gridSize = 10;
    self.metaBallView.threshold = 1.0;
    self.metaBallView.interpolation = YES;
    
    self.sliderGridSize.minimumValue = 2;
    self.sliderGridSize.maximumValue = 50;
    self.sliderGridSize.value = self.metaBallView.gridSize;
    self.labelGridSizeValue.text = [NSString stringWithFormat:@"%.0f", self.sliderGridSize.value];
    [self.sliderGridSize addTarget:self action:@selector(sliderGridSizeValueChanged:) forControlEvents:UIControlEventValueChanged];

    self.switchInterpolation.on = self.metaBallView.interpolation;
    [self.switchInterpolation addTarget:self action:@selector(switchInterpolationValueChanged:) forControlEvents:UIControlEventValueChanged];

    self.metaBallView.useNaivePainting = NO;
    self.switchPaintNaive.on = self.metaBallView.useNaivePainting;
    [self.switchPaintNaive addTarget:self action:@selector(switchPaintNaiveValueChanged:) forControlEvents:UIControlEventValueChanged];
}

-(void)sliderGridSizeValueChanged:(UISlider *)slider
{
    self.labelGridSizeValue.text = [NSString stringWithFormat:@"%.0f", slider.value];
    self.metaBallView.gridSize = slider.value;
}
-(void)switchInterpolationValueChanged:(UISwitch *)switcher
{
    self.metaBallView.interpolation = switcher.on;
}
-(void)switchPaintNaiveValueChanged:(UISwitch *)switcher
{
    self.metaBallView.useNaivePainting = switcher.on;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
