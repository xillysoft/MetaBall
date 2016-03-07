//
//  MetaBallView.m
//  test_metaball
//
//  Created by 赵小健 on 3/7/16.
//  Copyright © 2016 赵小健. All rights reserved.
//

#import "MetaBallView.h"


@interface MetaBallView()

@property int index;
@property CGPoint pan0;

@end


CGFloat distance(CGFloat x1, CGFloat y1, CGFloat x2, CGFloat y2)
{
    CGFloat dx = x2-x1;
    CGFloat dy = y2-y1;
    return sqrt(dx*dx+dy*dy);
}
@implementation MetaBallView

-(void)didMoveToSuperview
{
    if(self.superview == nil)
        return;
    self.index = -1;
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc]
                                                    initWithTarget:self
                                                    action:@selector(handlePanGesture:)];
    panGestureRecognizer.minimumNumberOfTouches = panGestureRecognizer.maximumNumberOfTouches = 1;
    [self addGestureRecognizer:panGestureRecognizer];

}


-(void)handlePanGesture:(UIPanGestureRecognizer *)panGestureRecognizer
{
    CGPoint pan = [panGestureRecognizer locationInView:panGestureRecognizer.view];
    
    if(panGestureRecognizer.state == UIGestureRecognizerStateBegan){
        //determine which metaball will be translated
        for(int i=0; i<self.metaBallModel.metaBalls.count; i++){
            MetaBall *metaBall = self.metaBallModel.metaBalls[i];
            CGFloat dx = pan.x - metaBall.location.x;
            CGFloat dy = pan.y - metaBall.location.y;
            if((dx*dx+dy*dy) <= metaBall.size*metaBall.size){ //calculate whether pan(x,y) in this metaball circle
                self.index = i;
                break;
            }
        }
        if(self.index != -1){
            self.pan0 = pan;
            [self setNeedsDisplay];
        }
    }else if(panGestureRecognizer.state == UIGestureRecognizerStateChanged){
        if(self.index != -1){
            CGFloat dx = pan.x - self.pan0.x; //delta distance from last pan location
            CGFloat dy = pan.y - self.pan0.y;
            CGPoint location = self.metaBallModel.metaBalls[self.index].location;
            location.x += dx;
            location.y += dy;
            self.metaBallModel.metaBalls[self.index].location = location;
            self.pan0 = pan; //set as last pan loation
            
            [self setNeedsDisplay];
        }
    }else if(panGestureRecognizer.state == UIGestureRecognizerStateEnded){
        self.index = -1;
    }
}



-(void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    
    CGFloat goo = self.metaBallModel.goo;
    CGFloat threshold = self.metaBallModel.threshold;
    
    int *pixels = malloc(width*height*sizeof(int));
    {
        
        for(int y=0; y<height; y++){
            for(int x=0; x<width; x++){
                //compute metabball for location (x,y)
                CGFloat sum = 0;
                for(MetaBall *metaBall in self.metaBallModel.metaBalls){
                    CGPoint loc = metaBall.location;
                    CGFloat dis = distance(loc.x, loc.y, x, y);
                    CGFloat v = metaBall.size/pow(dis, goo);
                    sum += v;
                }
                if(sum > threshold){
                    //draw pixel (x,y)
                    int y1 = height-1-y;
                    pixels[(int)(y1*width+x)] = 0xff0000ff;
//                    CGContextAddRect(bitmapContext, CGRectMake(x, y, 1, 1));
//                    CGContextDrawPath(bitmapContext, kCGPathStroke); //TODO: draw pixel with CGBitmapContext
                }
            }
        }
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef bitmapContext = CGBitmapContextCreate(pixels, width, height, 8, width*4, colorSpace, kCGImageAlphaNoneSkipLast|kCGBitmapByteOrder32Big);
        CGImageRef image = CGBitmapContextCreateImage(bitmapContext);
        CGContextDrawImage(context, self.bounds, image);
        CGImageRelease(image);
        CGContextRelease(bitmapContext);
        CGColorSpaceRelease(colorSpace);
    }
    free(pixels);
    
    
    {
        //draw individual metabal
        for(int i=0; i<self.metaBallModel.metaBalls.count; i++){
            MetaBall *metaBall = self.metaBallModel.metaBalls[i];
            CGFloat mbSize = metaBall.size;
            CGContextAddEllipseInRect(context, CGRectMake(metaBall.location.x-mbSize/2, metaBall.location.y-mbSize/2, mbSize, mbSize));
            
            if(self.index == i){
                CGContextSetStrokeColorWithColor(context, [UIColor greenColor].CGColor);
            }else{
                CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
            }
            CGContextDrawPath(context, kCGPathStroke);
        }

    }
}

@end
