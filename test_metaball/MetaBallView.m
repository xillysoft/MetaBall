//
//  MetaBallView.m
//  test_metaball
//
//  Created by 赵小健 on 3/7/16.
//  Copyright © 2016 赵小健. All rights reserved.
//

#import "MetaBallView.h"


@interface MetaBallView()

@property int panIndex;
@property CGPoint panLastLocation;

@end


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

//quick invert of square root
float InvSqrt(float x){
    float xhalf = 0.5f * x;
    int i = *(int*)&x;            // store floating-point bits in integer
    i = 0x5f3759df - (i >> 1);    // initial guess for Newton's method
    x = *(float*)&i;              // convert new bits into float
    x = x*(1.5f - xhalf*x*x);     // One round of Newton's method
    return x;
}

float metaball(float size1, float x,  float y, float x1, float y1, float goo)
{
    return size1/pow(distance(x, y, x1, y1), goo);
//    return size1/distance(x, y, x1, y1);
}

void triangle(float x0, float y0, float x1, float y1, float x2, float y2, CGContextRef context)
{
    CGContextMoveToPoint(context, x0, y0);
    CGContextAddLineToPoint(context, x1, y1);
    CGContextAddLineToPoint(context, x2, y2);
    CGContextClosePath(context);
}

//must be in CCW winding
void fan5(float x0, float y0, float x1, float y1, float x2, float y2, float x3, float y3, float x4, float y4, CGContextRef context)
{
    CGContextMoveToPoint(context, x0, y0);
    CGContextAddLineToPoint(context, x1, y1);
    CGContextAddLineToPoint(context, x2, y2);
    CGContextAddLineToPoint(context, x3, y3);
    CGContextAddLineToPoint(context, x4, y4);
    CGContextClosePath(context);
}

void fan6(float x0, float y0, float x1, float y1, float x2, float y2, float x3, float y3, float x4, float y4, float x5, float y5, CGContextRef context)
{
    CGContextMoveToPoint(context, x0, y0);
    CGContextAddLineToPoint(context, x1, y1);
    CGContextAddLineToPoint(context, x2, y2);
    CGContextAddLineToPoint(context, x3, y3);
    CGContextAddLineToPoint(context, x4, y4);
    CGContextAddLineToPoint(context, x5, y5);
    CGContextClosePath(context);
}

void rectangle(float x0, float y0, float x1, float y1, float x2, float y2, float x3, float y3, CGContextRef context)
{
    CGContextMoveToPoint(context, x0, y0);
    CGContextAddLineToPoint(context, x1, y1);
    CGContextAddLineToPoint(context, x2, y2);
    CGContextAddLineToPoint(context, x3, y3);
    CGContextClosePath(context);
}

@implementation MetaBallView

-(void)setThreshold:(CGFloat)threshold
{
    _threshold = threshold;
    [self setNeedsDisplay];
}

-(void)setGridSize:(CGFloat)gridSize
{
    _gridSize = gridSize;
    [self setNeedsDisplay];
}

-(void)setInterpolation:(BOOL)interpolation
{
    _interpolation = interpolation;
    [self setNeedsDisplay];
}

-(void)setUseNaivePainting:(BOOL)useNaivePainting
{
    _useNaivePainting = useNaivePainting;
    [self setNeedsDisplay];
}


-(void)didMoveToSuperview
{
    if(self.superview == nil)
        return;
    self.panIndex = -1;
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc]
                                                    initWithTarget:self
                                                    action:@selector(handlePanGesture:)];
    panGestureRecognizer.minimumNumberOfTouches = panGestureRecognizer.maximumNumberOfTouches = 1;
    [self addGestureRecognizer:panGestureRecognizer];

    UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
    [longPressGestureRecognizer requireGestureRecognizerToFail:panGestureRecognizer];
    [self addGestureRecognizer:longPressGestureRecognizer];
}

-(void)handleLongPressGesture:(UILongPressGestureRecognizer *)recognizer
{
    if(recognizer.state != UIGestureRecognizerStateEnded)
        return;
    
    CGPoint location = [recognizer locationInView:recognizer.view];
    int minMetaballSize = 10;
    int maxMetaballSize = 50;
    float size = (arc4random() % (maxMetaballSize-minMetaballSize)) + minMetaballSize;

    MetaBall *metaBall = [[MetaBall alloc] initWithSize:size x:location.x y:location.y z:0];
    [self.metaBallModel.metaBalls addObject:metaBall];
    [self setNeedsDisplay];
}

-(void)handlePanGesture:(UIPanGestureRecognizer *)recognizer
{
    CGPoint pan = [recognizer locationInView:recognizer.view];
    
    if(recognizer.state == UIGestureRecognizerStateBegan){
        //determine which metaball will be translated
        for(int i=0; i<self.metaBallModel.metaBalls.count; i++){
            MetaBall *metaBall = self.metaBallModel.metaBalls[i];
            float dx = pan.x - metaBall.x;
            float dy = pan.y - metaBall.y;
            if((dx*dx+dy*dy) <= metaBall.size*metaBall.size){ //calculate whether pan(x,y) in this metaball circle
                self.panIndex = i;
                break;
            }
        }
        if(self.panIndex != -1){
            self.panLastLocation = pan;
            [self setNeedsDisplay];
        }
    }else if(recognizer.state == UIGestureRecognizerStateChanged){
        if(self.panIndex != -1){
            float dx = pan.x - self.panLastLocation.x; //delta distance from last pan location
            float dy = pan.y - self.panLastLocation.y;
            self.metaBallModel.metaBalls[self.panIndex].x += dx;
            self.metaBallModel.metaBalls[self.panIndex].y += dy;
            self.panLastLocation = pan; //set as last pan loation
            
            [self setNeedsDisplay];
        }
    }else if(recognizer.state == UIGestureRecognizerStateEnded){
        self.panIndex = -1;
        
        [self setNeedsDisplay];
    }
}


-(void)_drawRect:(CGRect)rect //naively paint metaballs
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    int width = (int)self.bounds.size.width;
    int height = (int)self.bounds.size.height;
    
    const float goo = self.metaBallModel.goo;
    const float threshold = self.metaBallModel.threshold;
    {
        CGFloat grid = 3;
        for(unsigned y=0; y<height; y+=grid){
            for(unsigned x=0; x<width; x+=grid){
                //compute metabball for location (x,y)
                float sum = 0;
                for(MetaBall *metaBall in self.metaBallModel.metaBalls){
                    const BOOL bUseGoo = YES;
                    const float dist = distance(x, y, metaBall.x, metaBall.y);
                    float intensity;
                    if(bUseGoo)
                        intensity = metaBall.size/pow(dist, goo);
                    else
                        intensity = metaBall.size/dist;
                    
                    sum += intensity;
                    if(sum >= threshold)
                        break;
                }
                if(sum-threshold >= 0){
                    UIColor *color = [[UIColor alloc] initWithRed:0 green:0 blue:1 alpha:0.25];
                    CGContextSetFillColorWithColor(context, color.CGColor);
                    CGContextFillRect(context, CGRectMake(x, y, grid, grid));
                }
                
            }
        }
    }
    
}



- (void)drawRect:(CGRect)rect //paint metaballs by marching square algorithm
{
    
    NSDate *t0 = [NSDate date];
    
    if(self.useNaivePainting)
        [self _drawRect:rect];
    
    CGSize size = self.bounds.size;
    unsigned grid = self.gridSize;
    //    if(grid < 1) grid = 1;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    const float threshold = self.metaBallModel.threshold; //intensity threshold of metaball model
    const float goo = self.metaBallModel.goo; //goo of metaball model
    
    //compute and store grid values
    const int numRowGrids = size.height/grid;
    const int numColumnGrids = size.width/grid;
    float *gridValues = (float *)malloc(sizeof(float)*(numRowGrids+1)*(numColumnGrids+1));
    BOOL *gridInside = (BOOL *)malloc(sizeof(BOOL)*(numRowGrids+1)*(numColumnGrids+1));
    for(int r=0; r < numRowGrids + 1; r++){
        for(int c=0; c < numColumnGrids + 1; c++){
            const float x = c*grid;
            const float y = r*grid;
            float sumxy = 0;
            for(MetaBall *metaBall in self.metaBallModel.metaBalls){
                float intensity = [metaBall intensityWithX:x y:y goo:goo];
                sumxy += intensity;
            }
            gridValues[r*(numColumnGrids+1)+c] = sumxy;
            BOOL b = sumxy-threshold >= 0;
            gridInside[r*(numColumnGrids+1)+c] = b;
        }
    }

    //butriangulate grids
    for(int r=0; r<numRowGrids; r++){
        for(int c=0; c<numColumnGrids; c++){
            const float x0 = c*grid;
            const float y0 = r*grid;
            const float x1= x0+grid;
            const float y1 = y0+grid;
            
            const int offset = r*(numColumnGrids+1)+c;
            const float d0 = gridValues[offset]; //[r][c]; top-left
            const float d1 = gridValues[offset+1]; //[r][c+1]; top-right
            const float d2 = gridValues[offset+numColumnGrids+1+1]; //[r+1][c+1]; bottom-right
            const float d3 = gridValues[offset+numColumnGrids+1]; //[r+1][c]; bottom-left

            
            const BOOL b0 = gridInside[offset]; //[r][c];
            const BOOL b1 = gridInside[offset+1]; //[r][c+1]
            const BOOL b2 = gridInside[offset+numColumnGrids+1+1]; //[r+1][c+1]
            const BOOL b3 = gridInside[offset+numColumnGrids+1]; //[r+1][c]
            unsigned gridTypeIndex = b0 | (b1<<1) | (b2<<2) | (b3<<3); //4 bit representation, 16 cases totally

            int half = grid/2;
            
            //calculate intersection point (over threshold) on edge of grid via interpolation
            //t:=(T-a0)/(a1-a0), mid:=(1-t)*V0+t*V1, V0=0 so mid=t*V1
            float xMidTopOff = grid*(threshold-d0)/(d1-d0);
            float xMidBottomOff = grid*(threshold-d3)/(d2-d3);
            float yMidLeftOff = grid*(threshold-d0)/(d3-d0);
            float yMidRightOff = grid*(threshold-d1)/(d2-d1);
            if(! self.interpolation){ //use mid-way
                xMidTopOff = half;
                xMidBottomOff = half;
                yMidLeftOff = half;
                yMidRightOff = half;
            }
            
            BOOL bFillMarchingSquare = YES;
            if(bFillMarchingSquare) {
                static UIColor *fillColor;
                if(!fillColor) fillColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.5];
                CGContextSetFillColorWithColor(context, fillColor.CGColor);
                CGContextSetStrokeColorWithColor(context, [UIColor yellowColor].CGColor);
                CGContextBeginPath(context);
                
//                float xMidTop = x0 + xOffTop;
//                float xMidBottom = x0 + xOffBottom;
//                float yMidLeft = y0 + yOffLeft;
//                float yMidRight = y0+yOffRight;
                
                switch(gridTypeIndex){
                    case 0:
                        break;
                    case 15:
                        rectangle(x0, y0, x0, y1, x1, y1, x1, y0, context);
                        break;
                    case 1:
                        triangle(x0+xMidTopOff, y0,  x0,y0+yMidLeftOff, x0, y0, context);
                        break;
                    case 14:
                        fan5(x0+xMidTopOff, y0, x0, y0+yMidLeftOff, x0,y1, x1,y1, x1, y0, context);
                        break;
                    case 2:
                        triangle(x0+xMidTopOff, y0, x1, y0, x1, y0+yMidRightOff, context);
                        break;
                    case 13:
                        fan5(x0+xMidTopOff,y0, x0,y0, x0,y1, x1, y1, x1, y0+yMidRightOff, context);
                        break;
                    case 3:
                        rectangle(x0, y0+yMidLeftOff, x1, y0+yMidRightOff, x1, y0, x0, y0, context);
                        break;
                    case 12:
                        rectangle(x0, y0+yMidLeftOff, x0, y1, x1, y1, x1, y0+yMidRightOff, context);
                        break;
                    case 4:
                        triangle(x1, y0+yMidRightOff, x1, y1, x0+xMidBottomOff, y1, context);
                        break;
                    case 11:
                        fan5(x1, y0+yMidRightOff, x1, y0, x0, y0, x0, y1, x0+xMidBottomOff, y1, context);
                        break;
                    case 6:
                        rectangle(x0+xMidTopOff, y0, x0+xMidBottomOff, y1, x1,y1, x1, y0, context);
                        break;
                    case 9:
                        rectangle(x0+xMidTopOff, y0, x0, y0, x0, y1, x0+xMidBottomOff, y1, context);
                        break;
                    case 7:
                        fan5(x0, y0+yMidLeftOff, x0+xMidBottomOff, y1, x1, y1, x1, y0, x0, y0, context);
                        break;
                    case 8:
                        triangle(x0, y0+yMidLeftOff, x0, y1, x0+xMidBottomOff, y1, context);
                        break;
                    case 5:
                            fan6(x0, y0+yMidLeftOff,  x0+xMidBottomOff, y1,  x1, y1,  x1, y0+yMidRightOff,  x0+xMidTopOff, y0,  x0, y0,  context);
                        break;
                    case 10:
                        fan6(x0, y0+yMidLeftOff,  x0, y1,  x0+xMidBottomOff, y1,  x1, y0+yMidRightOff,  x1, y0, x0+xMidTopOff, y0, context);
                        break;
                }
                CGContextDrawPath(context, kCGPathFill);
            }
            
            
            { //stroke grid
                BOOL bStrikeGrid = NO;
                if(bStrikeGrid){
                    CGContextSetLineWidth(context, 1);
                    CGContextSetStrokeColorWithColor(context, [UIColor grayColor].CGColor);
                    CGRect gridRect = CGRectMake(x0, y0, grid, grid);
                    CGContextStrokeRect(context, gridRect);
                    
                    if(gridTypeIndex==15){ //fully inside
                        UIColor *fillColor;
                        if(!fillColor)fillColor = [UIColor colorWithRed:1 green:1 blue:0 alpha:0.3];
                        CGContextSetFillColorWithColor(context, fillColor.CGColor);
                        CGContextFillRect(context, CGRectMake(x0, y0, grid, grid));
                    }
                }
                BOOL bDrawValue = NO;
                if(bDrawValue){
                    NSString *str = [NSString stringWithFormat:@"%d", gridTypeIndex];
                    NSDictionary *attri = @{NSFontAttributeName:[UIFont systemFontOfSize:10], NSForegroundColorAttributeName:[UIColor blueColor]};
                    CGSize fontsize = [str sizeWithAttributes:attri];
                    CGPoint point = CGPointMake(x0+(grid-fontsize.width)/2, y0+(grid-fontsize.height)/2);
                    [str drawAtPoint:point withAttributes:attri];
                }
                //fill grid corner circle
                BOOL bFillGridCornerCircles = NO;
                if(bFillGridCornerCircles){
                    CGFloat r = 2;
                    CGFloat d = r*2;
                    if(b0){
                        CGContextSetFillColorWithColor(context, [UIColor yellowColor].CGColor);
                    }else{
                        CGContextSetFillColorWithColor(context, [UIColor grayColor].CGColor);
                    }
                    CGContextFillEllipseInRect(context, CGRectMake(x0-r, y0-r, d, d));
                }
            }
            
            
            
        }
    }
    
    free(gridValues);
    free(gridInside);
    
    
    BOOL bDrawOutline = YES; //draw metaball circle
    if(bDrawOutline){
        //draw individual metabal
        for(int i=0; i<self.metaBallModel.metaBalls.count; i++){
            MetaBall *metaBall = self.metaBallModel.metaBalls[i];
            float r = metaBall.size;
            float diameter = 2*r;
            CGContextAddEllipseInRect(context, CGRectMake(metaBall.x-r, metaBall.y-r, diameter, diameter));
            
            if(self.panIndex == i){
                CGContextSetStrokeColorWithColor(context, [UIColor greenColor].CGColor); //on-pan gesture
            }else{
                CGContextSetStrokeColorWithColor(context, [UIColor darkGrayColor].CGColor);
            }
            CGContextSetLineWidth(context, 1);
            CGContextDrawPath(context, kCGPathStroke);
        }
        
    }
    
    NSTimeInterval dt = -[t0 timeIntervalSinceNow];
    NSString *strFps = [NSString stringWithFormat:@"FPS: %.1f", 1.0/dt];
    [strFps drawAtPoint:CGPointMake(10, 10) withAttributes:nil];
    
}
@end
