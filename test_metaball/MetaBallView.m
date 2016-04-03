//
//  MetaBallView.m
//  test_metaball
//
//  Created by 赵小健 on 3/7/16.
//  Copyright © 2016 赵小健. All rights reserved.
//

#import "MetaBallView.h"
#import <OpenGLES/ES1/gl.h>

#define EPSILION 1e-10

//(p-p0)/(p1-p0)==(isolevel-v0)/(v1-v0),
//p=(isolevel-v0)/(v1-v0)*(p1-p0)+p0
//使用时注意参数顺序
static inline float interpolate(float isolevel, float p1, float p0, float v1, float v0)
{
    if(ABS(v1-v0) < EPSILION)
        return p0;
    return (isolevel-v0)*(p1-p0)/(v1-v0)+p0;
}



//---------------------------------------------------

@interface MetaBallView(){
    GLfloat _left;
    GLfloat _right;
    GLfloat _bottom;
    GLfloat _top;
    GLfloat _zNear;
    GLfloat _zFar;
}

@property int panIndex;
@property CGPoint panLastLocation;

@end


@implementation MetaBallView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initGL];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    [self initGL];
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initGL];
    }
    return self;
}

-(void)initGL
{
    //set EAGL context
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
    [EAGLContext setCurrentContext:self.context];
    
    glEnable(GL_DEPTH_TEST);
    glDepthFunc(GL_LEQUAL);
    self.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    glMatrixMode(GL_PROJECTION);
    {
        _zNear = 1;
        _zFar = 1000;
        _left = -1;
        _right = 1;
        _bottom = -1;
        _top = 1;
        //        glOrthof(0, size.width, 0, size.height, _zNear, _zFar);
        //        glOrthof(0, 1/_right, 0, 1/_top, _zNear, _zFar);
        //tgFOV::=left/zNear
        glOrthof(_left, _right, _bottom, _top, _zNear, _zFar);
    }
    glMatrixMode(GL_MODELVIEW);
    
    glClearColor(0, 1, 1, 1);
}


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
    int maxMetaballSize = 40;
    float size = (arc4random() % (maxMetaballSize-minMetaballSize)) + minMetaballSize;

    MetaBall *metaBall = [[MetaBall alloc] initWithSize:size x:location.x y:location.y];
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


- (void)drawRect:(CGRect)rect //paint metaballs by marching square algorithm
{
    glEnableClientState(GL_VERTEX_ARRAY);
    glLoadIdentity();
    glTranslatef(0, 0, -_zNear);
    
    CGSize size = self.bounds.size;
    glClear(GL_COLOR_BUFFER_BIT);
    
    //transform x:(0, width) ==> (_left, _right); y:(0, height) ==> (_bottom, _top)
    glTranslatef(_left, _bottom, 0);
    glScalef((_right-_left)/size.width, (_top-_bottom)/size.height, 1);
    
    //flip y-
    //y'=-y+height  y:(0, height)==>y':(height, 0)
    glTranslatef(0, size.height, 0);
    glScalef(1, -1, 1);

    //    NSDate *t0 = [NSDate date];

    float gridSize = self.gridSize;
    
    //    if(grid < 1) grid = 1;
    
    const float isolevel = self.metaBallModel.threshold; //intensity threshold of metaball model
    const float goo = self.metaBallModel.goo; //goo of metaball model
    

    //compute and store grid values
    const int numRowGrids = size.height/gridSize;
    const int numColumnGrids = size.width/gridSize;
    float *gridValues = (float *)malloc(sizeof(float)*(numRowGrids+1)*(numColumnGrids+1));
    BOOL *gridInside = (BOOL *)malloc(sizeof(BOOL)*(numRowGrids+1)*(numColumnGrids+1));
    for(int r=0; r < numRowGrids + 1; r++){
        for(int c=0; c < numColumnGrids + 1; c++){
            const float x = c*gridSize;
            const float y = r*gridSize;
            float sumxy = 0;
            for(MetaBall *metaBall in self.metaBallModel.metaBalls){
                float intensity = [metaBall intensityWithX:x y:y goo:goo];
                sumxy += intensity;
            }
            gridValues[r*(numColumnGrids+1)+c] = sumxy;
            BOOL b = sumxy-isolevel >= 0;
            gridInside[r*(numColumnGrids+1)+c] = b;
        }
    }

    glColor4f(1, 0, 0, 1);

    //triangulate grids
    for(int r=0; r<numRowGrids; r++){
        for(int c=0; c<numColumnGrids; c++){
            const float x0 = c*gridSize;
            const float y0 = r*gridSize;
//            const float x1= x0+gridSize;
//            const float y1 = y0+gridSize;
            
            const int offset = r*(numColumnGrids+1)+c;
            const float d0 = gridValues[offset]; //[r][c]; top-left
            const float d1 = gridValues[offset+1]; //[r][c+1]; top-right
            const float d2 = gridValues[offset+numColumnGrids+1+1]; //[r+1][c+1]; bottom-right
            const float d3 = gridValues[offset+numColumnGrids+1]; //[r+1][c]; bottom-left

            
            const BOOL b0 = gridInside[offset]; //[r][c];
            const BOOL b1 = gridInside[offset+1]; //[r][c+1]
            const BOOL b2 = gridInside[offset+numColumnGrids+1+1]; //[r+1][c+1]
            const BOOL b3 = gridInside[offset+numColumnGrids+1]; //[r+1][c]
            unsigned gridIndex = b0 | (b1<<1) | (b2<<2) | (b3<<3); //4 bit representation:<v3,v2,v1,v0>, 16 cases totally

            if(gridIndex == 0) //4 vertices are completely outside
                continue;

            static const int edgeTable[] = { //edgeTable[gridIndex]为相关联的边,(使用bitfield表示法:<e3,e2,e1,e0>)
                0, //0:0000-->0000
                9, //1:0001-->1001
                3, //2:0010-->0011
                10, //3:0011-->1010
                6, //4:0100-->0110
                15, //5:0101-->1111
                5, //6:0110-->0101
                12, //7:0111-->1100
                12, //8:1000-->1100
                5, //9:1001-->0101
                15, //10:1010-->1111
                6, //11:1011-->0110
                10, //12:1100-->1010
                3, //13:1101-->0011
                9, //14:1110-->1001
                0//15:1111-->0000
            };
            
            //交点序列为(e3, v3, e2, v2, e1, v1, e0, v0) 每个交点用一个二进制位表示
            static const int triangleFanTable[][7] = { //gridindex=0..15 (2^4)，每个grid最多可产生6个顶点的多边形
                {-1, }, //0:0000-->()
                {0, 1, 7, -1, }, //1:0001-->(v0,e3,e0)
                {2, 1, 3, -1, }, //2:0010-->(v1,e0,e1)
                {0, 2, 3, 7, -1, }, //3:0011-->(v0,v1,e1,e3)
                {4, 3, 5, -1, }, //4:0100-->(v2,e1,e2)
                {0, 1, 3, 4, 5, 7, -1, }, //5:0101-->(v0,e0,e1,v2,e2,e3)
                {1, 2, 4, 5, -1, }, //6:0110-->(e0,v1,v2,e2)
                {0, 2, 4, 5, 7, -1, }, //7:0111-->(v0,v1,v2,e2,e3)
                {7, 6, 5, -1, }, //8:1000-->(e3,v3,e2)
                {0, 1, 5, 6, -1, }, //9:1001-->(v0,e0,e2,v3)
                {1, 2, 3, 5, 6, 7, -1, }, //10:1010-->(e0,v1,e1,e2,v2,e3)
                {0, 2, 3, 5, 6, -1, }, //11:1011-->(v0,v1,e1,e2,v3)
                {7, 3, 4, 6, -1, }, //12:1100-->(e3,e1,v2,v3)
                {0, 1, 3, 4, 6, -1, }, //13:1101-->(v0,e0,e1, v2,v3)
                {1, 2, 4, 6, 7, -1, }, //14:1110-->(e0,v1,v2,v3,e3)
                {6, 4, 2, 0, -1, } //15:1111-->(v3,v2,v1,v0)
            };
            
            int edgeIndex = edgeTable[gridIndex];
            
            //交点序列为(e3, v3, e2, v2, e1, v1, e0, v0)
            float vertlist[16]; //相交顶点列表。8*2 4个顶点，4条边上的交点，一共使用8个顶点
            vertlist[0] = 0; //v0.x
            vertlist[1] = 0; //v0.y
            
            if(edgeIndex & (1<<0)){ //e0
                vertlist[2] = interpolate(isolevel, gridSize, 0, d1, d0); //e0.x
                vertlist[3] = 0; //e0.y
            }
            vertlist[4] = gridSize; //v1.x
            vertlist[5] = 0; //v1.y
            if(edgeIndex & (1<<1)){ //e1
                vertlist[6] = gridSize; //e1.x
                vertlist[7] = interpolate(isolevel, gridSize, 0, d2, d1); //e1.y
            }
            vertlist[8] = gridSize; //v2.x
            vertlist[9] = gridSize; //v2.y
            if(edgeIndex & (1<<2)){ //e2
                vertlist[10] = interpolate(isolevel, gridSize, 0, d2, d3); //e2.x
                vertlist[11] = gridSize; //e2.y
            }
            vertlist[12] = 0; //v3.x
            vertlist[13] = gridSize; //v3.y
            if(edgeIndex & (1<<3)){ //e3
                vertlist[14] = 0; //e3.x
                vertlist[15] = interpolate(isolevel, gridSize, 0, d3, d0); //e3.y
            }
            
            //构造多边扇形
            int numVerticesOfFan = 0;
            float triangleFan[12]; //多边扇形最多由6个顶点组成，每个顶点由(x,y)两个分量组成，最多共6*2=12个分量
            for(int i=0; triangleFanTable[gridIndex][i]!=-1; i++){
                const int vertIndex = triangleFanTable[gridIndex][i];
                triangleFan[i*2+0] = vertlist[vertIndex*2+0];
                triangleFan[i*2+1] = vertlist[vertIndex*2+1];
                numVerticesOfFan++;
            }
            //draw this triangle-fan
            {
                glVertexPointer(2, GL_FLOAT, 0, triangleFan);
                glTranslatef(x0, y0, 0);
                glDrawArrays(GL_TRIANGLE_FAN, 0, numVerticesOfFan);
//                glDrawArrays(GL_LINE_LOOP, 0, numVerticesOfFan);
                glTranslatef(-x0, -y0, 0);
            }
        }
    }
    
    free(gridValues);
    free(gridInside);
    
    
    
//    NSTimeInterval dt = -[t0 timeIntervalSinceNow];
//    NSString *strFps = [NSString stringWithFormat:@"FPS: %.1f", 1.0/dt];
//    [strFps drawAtPoint:CGPointMake(10, 10) withAttributes:nil];
//    NSLog(@"--%@", strFps);
    
}
@end

