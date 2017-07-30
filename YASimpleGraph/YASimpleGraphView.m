//
//  YASimpleGraphView.m
//  TestGraphView
//
//  Created by Jaime on 2017/6/15.
//  Copyright © 2017年 Jaime. All rights reserved.
//

#import "YASimpleGraphView.h"


#define START_X_VALUE 15
#define BOTTOM_DASH_SPACE 35
#define DOUBLE_VALUE_COMPARE_ZERO(__VALUE__) ((fabs(__VALUE__) < 0.000000000000001)?0:(__VALUE__ > 0.0f?1:-1))

@interface YASimpleGraphView() <UIGestureRecognizerDelegate> {
    NSMutableArray *YAxisLabels;
    NSMutableArray *XAxisLabels;
    
    CAShapeLayer *lineLayer;
    CAShapeLayer *dashLayer;
    
    CGFloat valueOfYAxis;
    CGFloat vHeight;
    CGFloat vWidth;
    CGFloat spaceY;  //垂直间隔
    CGFloat spaceX;  //水平间隔
    NSInteger numberOfYAxis;
}

//Y轴显示坐标值
@property (nonatomic,strong) NSMutableArray *YAxisValues;
@property (nonatomic,strong) NSMutableArray *points;


@property (nonatomic, strong) UIView       *panGestureView;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) NSMutableArray *dotViews;
@property (strong, nonatomic) UIView *popUpView;

@end

@implementation YASimpleGraphView

- (instancetype)init {
    if (self = [super init]) {
        XAxisLabels = [[NSMutableArray alloc]init];
        YAxisLabels = [[NSMutableArray alloc]init];
        self.YAxisValues = [[NSMutableArray alloc]init];
        
        _dashLineColor = [UIColor orangeColor];
        _dashLineWidth = 1.0/[UIScreen mainScreen].scale;
        _bottomLineColor = [UIColor orangeColor];
        _bottomLineHeight = 1.0/[UIScreen mainScreen].scale;
        _XAxisDotColor = [UIColor grayColor];
        _XAxisDotWidth = 1.0;
        _XAxisDotHeight = 3.0;
        
        _enableTouchLine = NO;
        _alphaTouchInputLine = 0.5;
        _colorTouchInputLine = [UIColor grayColor];
        _widthTouchInputLine = 1.0/[UIScreen mainScreen].scale;
        
        _YAxisLabelFont = [UIFont systemFontOfSize:9];
        _XAxisLabelFont = [UIFont systemFontOfSize:9];
        _YAxisLabelTextColor = [UIColor grayColor];
        _XAxisLabelTextColor = [UIColor grayColor];
        
        _dotColor = [UIColor whiteColor];
        _dotBorderColor = [UIColor orangeColor];
        _dotWidth = 8.0;
        _dotBorderWidth = 1.0;
        
    }
    
    return self;
}

- (void)startDraw {
    numberOfYAxis = 0;
    if ([self.delegate respondsToSelector:@selector(numberOfYAxisLabelsOnLineGraph:)]) {
        numberOfYAxis = [self.delegate numberOfYAxisLabelsOnLineGraph:self];
    }
    
    vHeight = CGRectGetHeight(self.frame);
    vWidth = CGRectGetWidth(self.frame);
    spaceY = (vHeight-BOTTOM_DASH_SPACE)/numberOfYAxis;
    spaceX = (vWidth-2*START_X_VALUE)/(self.allDates.count-1);
    [self createYAxisValues];
    
    [self drawDashLines];
}

- (void)drawRect:(CGRect)rect {
    [self drawLine];
    [self drawDots];
}

-  (void)drawDashLines {
    if (dashLayer) {
        [dashLayer removeFromSuperlayer];
        dashLayer = nil;
    }
    
    dashLayer = [CAShapeLayer layer];
    dashLayer.frame = self.bounds;
    dashLayer.fillColor = nil;
    dashLayer.lineWidth = _dashLineWidth;
    dashLayer.strokeColor = _dashLineColor.CGColor;
    dashLayer.lineDashPattern = @[@2,@2];
    
    //分割线
    UIBezierPath *dashPath = [UIBezierPath bezierPath];
    for (int i=0; i<self.YAxisValues.count; i++) {
        [dashPath moveToPoint:CGPointMake(START_X_VALUE, spaceY*(i+1))];
        [dashPath addLineToPoint:CGPointMake(vWidth-START_X_VALUE, spaceY*(i+1))];
        
        UILabel *YAxisLabel = [[UILabel alloc]initWithFrame:CGRectMake(START_X_VALUE, spaceY*(i+1)-10, 100, 10)];
        YAxisLabel.textAlignment = NSTextAlignmentLeft;
        YAxisLabel.font = _YAxisLabelFont;
        YAxisLabel.textColor = _YAxisLabelTextColor;
        YAxisLabel.text = self.YAxisValues[self.YAxisValues.count-i-1];
        [YAxisLabel sizeToFit];
        [self addSubview:YAxisLabel];
    }
    
    dashLayer.path = dashPath.CGPath;
    [self.layer addSublayer:dashLayer];
    
    //底部实线
    UIView *bottomLine = [[UIView alloc]initWithFrame:CGRectMake(START_X_VALUE, vHeight-20, vWidth-2*START_X_VALUE, _bottomLineHeight)];
    bottomLine.backgroundColor = _bottomLineColor;
    [self addSubview:bottomLine];
    
    //x坐标轴
    NSArray *XAxisIndexs = @[].mutableCopy;
    if ([self.delegate respondsToSelector:@selector(incrementPositionsForXAxisOnLineGraph:)]) {
        XAxisIndexs = [self.delegate incrementPositionsForXAxisOnLineGraph:self];
    }
    
    if (XAxisIndexs.count >0 && self.allDates.count > 0) {
        for (int i = 0; i<XAxisIndexs.count; i++) {
            NSInteger k = [XAxisIndexs[i] integerValue];
            UIView *xLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _XAxisDotWidth, _XAxisDotHeight)];
            xLineView.backgroundColor = _XAxisDotColor;
            xLineView.center = CGPointMake(START_X_VALUE+k*spaceX, vHeight-20+3/2);
            [self addSubview:xLineView];
            
            UILabel *xAxisLabel = [UILabel new];
            //xAxisLabel.backgroundColor = [UIColor orangeColor];
            xAxisLabel.text = self.allDates[k];
            xAxisLabel.font = _XAxisLabelFont;
            [xAxisLabel sizeToFit];
            xAxisLabel.textColor = _XAxisLabelTextColor;
            xAxisLabel.center = CGPointMake(START_X_VALUE+k*spaceX, vHeight-xAxisLabel.bounds.size.height/2);
            [self addSubview:xAxisLabel];
        }
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(popUpViewForLineGraph:)]) {
        self.popUpView = [self.delegate popUpViewForLineGraph:self];
        self.popUpView.alpha = 0;
        [self addSubview:self.popUpView];
    }
    
    if (self.enableTouchLine) {
        self.touchInputLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.widthTouchInputLine, vHeight)];
        self.touchInputLine.backgroundColor = self.colorTouchInputLine;
        self.touchInputLine.alpha = 0;
        [self addSubview:self.touchInputLine];
    }
}

- (void)drawLine {
    UIBezierPath *line = [UIBezierPath bezierPath];
    UIBezierPath *fillTop = [UIBezierPath bezierPath];  //上下两个填充区用来填充渐变
    UIBezierPath *fillBottom;
    
    self.points = [NSMutableArray arrayWithCapacity:self.allValues.count];
    for (int i = 0; i<self.allValues.count; i++) {
        double value = [self.allValues[i] doubleValue];
        CGFloat yValue = vHeight - BOTTOM_DASH_SPACE - value/valueOfYAxis;
        CGFloat xValue = START_X_VALUE + i*spaceX;
        CGPoint point = CGPointMake(xValue, yValue);
        if (yValue != CGFLOAT_MAX) {
            [self.points addObject:[NSValue valueWithCGPoint:point]];
        }
    }
    
    line = [YASimpleGraphView quadCurvedPathWithPoints:self.points];
    fillBottom = [YASimpleGraphView quadCurvedPathWithPoints:self.bottomPointsArray];
    fillTop = [YASimpleGraphView quadCurvedPathWithPoints:self.topPointsArray];
    
    //----------------------------//
    //----- Draw Fill Colors -----//
    //----------------------------//  此处利用图形上下文绘图，必须放在drawRect:里实现，否则获取不到
    
    [self.topColor set];
    [fillTop fillWithBlendMode:kCGBlendModeNormal alpha:self.topAlpha];
    
    [self.bottomColor set];
    [fillBottom fillWithBlendMode:kCGBlendModeNormal alpha:self.bottomAlpha];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    if (self.topGradient != nil) {
        CGContextSaveGState(ctx);
        CGContextAddPath(ctx, [fillTop CGPath]);
        CGContextClip(ctx);
        CGContextDrawLinearGradient(ctx, self.topGradient, CGPointZero, CGPointMake(0, CGRectGetMaxY(fillTop.bounds)), 0);
        CGContextRestoreGState(ctx);
    }
    
    if (self.bottomGradient != nil) {
        CGContextSaveGState(ctx);
        CGContextAddPath(ctx, [fillBottom CGPath]);
        CGContextClip(ctx);
        CGContextDrawLinearGradient(ctx, self.bottomGradient, CGPointZero, CGPointMake(0, CGRectGetMaxY(fillBottom.bounds)), 0);
        CGContextRestoreGState(ctx);
    }
    
    
    CAShapeLayer *pathLayer = [CAShapeLayer layer];
    //pathLayer.frame = CGRectMake(0, 0, vWidth-2*START_X_VALUE, vHeight-BOTTOM_DASH_SPACE); //可不指定
    pathLayer.path = line.CGPath;
    pathLayer.strokeColor = self.lineColor.CGColor;
    pathLayer.fillColor = nil;
    pathLayer.opacity = self.lineAlpha;
    pathLayer.lineWidth = self.lineWidth;
    pathLayer.lineJoin = kCALineJoinBevel;
    pathLayer.lineCap = kCALineCapRound;
    [self.layer addSublayer:pathLayer];
}


- (void)drawDots {
    if (self.points.count == 0) return;
    self.dotViews = [NSMutableArray arrayWithCapacity:self.points.count];
    
    for (int i =0; i<self.points.count; i++) {
        NSValue *value = self.points[i];
        CGPoint point = [value CGPointValue];
        
        UIView *dot = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _dotWidth, _dotWidth)];
        dot.backgroundColor = _dotColor;
        dot.center = CGPointMake(point.x, point.y);
        dot.layer.borderColor = _dotBorderColor.CGColor;
        dot.layer.borderWidth = _dotBorderWidth;
        dot.layer.cornerRadius = _dotWidth/2;
        dot.layer.masksToBounds = YES;
        if (i != self.defaultShowIndex) dot.hidden = YES;
        [self addSubview:dot];
        [self.dotViews addObject:dot];
    }
    
    //添加手势view
    self.panGestureView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, vWidth, vHeight)];
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(catchedGestureViewEvent:)];
    self.panGesture.delegate = self;
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(catchedGestureViewEvent:)];
    [self.panGestureView addGestureRecognizer:self.panGesture];
    [self.panGestureView addGestureRecognizer:self.tapGesture];
    [self addSubview:self.panGestureView];
    
    [self showPopUpViewWithIndex:self.defaultShowIndex];
    [self.popUpView setNeedsLayout];
    [self.popUpView layoutIfNeeded];
}

- (void)catchedGestureViewEvent:(UIGestureRecognizer *) gesture{
    CGFloat touchX = [gesture locationInView:self.panGestureView].x;
    CGFloat preIndex = floor((touchX - START_X_VALUE) / spaceX);
    NSInteger index = ((touchX - START_X_VALUE) < 0)?0:((((touchX - START_X_VALUE) - (preIndex * spaceX))>spaceX/2.0f)?preIndex+1:preIndex);
    index = (index > self.dotViews.count - 1)?(self.dotViews.count - 1):index;
    
    if (_enableTouchLine) {
        _touchInputLine.frame = CGRectMake(touchX-_widthTouchInputLine/2, 0, _widthTouchInputLine, vHeight);
        _touchInputLine.alpha = _alphaTouchInputLine;
    }
    
    BOOL needUpdateContent = YES;
    for (UIView *view in self.dotViews) {
        NSInteger showingViewIndex = [self.dotViews indexOfObject:view];
        if (showingViewIndex == index) {
            if (!view.hidden) {
                needUpdateContent = NO;
            }
            view.hidden = NO;
        }else{
            view.hidden = YES;
        }
    }
    
    if (needUpdateContent) {
        [self showPopUpViewWithIndex:index];
    }
    
    if (gesture.state == UIGestureRecognizerStateEnded) {
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            _touchInputLine.alpha = 0;
        } completion:nil];
    }
}

- (void)showPopUpViewWithIndex:(NSInteger)index {
    
    if (_delegate && [_delegate respondsToSelector:@selector(lineGraph:modifyPopupView:forIndex:)]) {
        [_delegate lineGraph:self modifyPopupView:self.popUpView forIndex:index];
    }
    
    UIView *dotView = self.dotViews[index];
    CGFloat x = dotView.center.x;
    CGFloat y = dotView.center.y-dotView.frame.size.height/2 - self.popUpView.frame.size.height/2 - 2;
    
    if (index == 0) {
        x = x+self.popUpView.frame.size.width/2;
    } else if (index == self.dotViews.count-1) {
        x = x-self.popUpView.frame.size.width/2;
    }
    
    self.popUpView.center = CGPointMake(x, y);
    self.popUpView.alpha = 1;
}


//获取Y轴所有坐标值
- (void)createYAxisValues {
    double realMaxValue = 0.0f;
    double realMinValue = 0.0f;
    double maxOrdinateValue = 0.0f;
    double minOrdinateValue = 0.0f;
    
    for (int i = 0; i<self.allValues.count; i++) {
        double value = [self.allValues[i] doubleValue];
        if (i == 0) { //初始化数据
            realMaxValue = value;
            realMinValue = value;
        }else{
            if (value > realMaxValue) {
                realMaxValue = value;
            }
            if (value < realMinValue) {
                realMinValue = value;
            }
        }
    }
    
    //纵坐标取整算法
    realMaxValue = MAX(0.0f, realMaxValue);
    realMinValue = MIN(0.0f, realMinValue);
    //调整最小值
    minOrdinateValue = DOUBLE_VALUE_COMPARE_ZERO(realMinValue) >= 0?[self ajustIntegerValue:realMinValue]:(-1 * [self ajustIntegerValue:ABS(realMinValue)]);
    if ((DOUBLE_VALUE_COMPARE_ZERO(realMaxValue) == 0) && (DOUBLE_VALUE_COMPARE_ZERO(realMinValue) == 0)) {
        minOrdinateValue = -200;
    }
    
    NSInteger deltaValue = [self calcIntegerDeltaValue:realMaxValue minValue:realMinValue];
    
    maxOrdinateValue = minOrdinateValue + (numberOfYAxis * deltaValue);
    
    valueOfYAxis = (maxOrdinateValue - minOrdinateValue)/(vHeight-BOTTOM_DASH_SPACE);
    for (int i = 0; i < numberOfYAxis; i++) {
        [self.YAxisValues addObject:[NSString stringWithFormat:@"%.0f",(minOrdinateValue + i*deltaValue)]];
    }
}

- (NSInteger) calcIntegerDeltaValue:(double) maxValue minValue:(double) minValue{
    NSInteger integerDetla = ceil((maxValue - minValue) / (numberOfYAxis-1));
    //对得到的整数进一步取整 如： 101 -> 110, 1001 -> 1100
    if (integerDetla == 0) { //值为0的水平直线则返回100一个值的间距
        return 100;
    }else{
        return [self ajustIntegerValue:integerDetla];
    }
    
}

- (NSInteger)ajustIntegerValue:(NSInteger) origalValue{
    if (origalValue < 100) {
        return origalValue;
    }else{
        NSInteger base = origalValue;
        NSInteger round = 1;
        while (origalValue > 100) {
            origalValue = origalValue / 10;
            round *= 10;
        }
        return base - base % round + round;
    }
}

//绘线函数

- (NSArray *)topPointsArray {
    CGPoint topPointZero = CGPointMake(START_X_VALUE,0);
    CGPoint topPointFull = CGPointMake(self.frame.size.width-START_X_VALUE, 0);
    NSMutableArray *topPoints = [NSMutableArray arrayWithArray:self.points];
    [topPoints insertObject:[NSValue valueWithCGPoint:topPointZero] atIndex:0];
    [topPoints addObject:[NSValue valueWithCGPoint:topPointFull]];
    return topPoints;
}

- (NSArray *)bottomPointsArray {
    CGPoint bottomPointZero = CGPointMake(START_X_VALUE, self.frame.size.height - BOTTOM_DASH_SPACE);
    CGPoint bottomPointFull = CGPointMake(self.frame.size.width-START_X_VALUE, self.frame.size.height - BOTTOM_DASH_SPACE);
    NSMutableArray *bottomPoints = [NSMutableArray arrayWithArray:self.points];
    [bottomPoints insertObject:[NSValue valueWithCGPoint:bottomPointZero] atIndex:0];
    [bottomPoints addObject:[NSValue valueWithCGPoint:bottomPointFull]];
    return bottomPoints;
}

+ (UIBezierPath *)linesToPoints:(NSArray *)points {
    UIBezierPath *path = [UIBezierPath bezierPath];
    NSValue *value = points[0];
    CGPoint p1 = [value CGPointValue];
    [path moveToPoint:p1];
    
    for (NSUInteger i = 1; i < points.count; i++) {
        value = points[i];
        CGPoint p2 = [value CGPointValue];
        [path addLineToPoint:p2];
    }
    return path;
}

+ (UIBezierPath *)quadCurvedPathWithPoints:(NSArray *)points {
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    NSValue *value = points[0];
    CGPoint p1 = [value CGPointValue];
    [path moveToPoint:p1];
    
    if (points.count == 2) {
        value = points[1];
        CGPoint p2 = [value CGPointValue];
        [path addLineToPoint:p2];
        return path;
    }
    
    for (NSUInteger i = 1; i < points.count; i++) {
        value = points[i];
        CGPoint p2 = [value CGPointValue];
        
        CGPoint midPoint = midPointForPoints(p1, p2);
        [path addQuadCurveToPoint:midPoint controlPoint:controlPointForPoints(midPoint, p1)];
        [path addQuadCurveToPoint:p2 controlPoint:controlPointForPoints(midPoint, p2)];
        
        p1 = p2;
    }
    return path;
}

static CGPoint midPointForPoints(CGPoint p1, CGPoint p2) {
    return CGPointMake((p1.x + p2.x) / 2, (p1.y + p2.y) / 2);
}

static CGPoint controlPointForPoints(CGPoint p1, CGPoint p2) {
    CGPoint controlPoint = midPointForPoints(p1, p2);
    CGFloat diffY = fabs(p2.y - controlPoint.y);
    
    if (p1.y < p2.y)
        controlPoint.y += diffY;
    else if (p1.y > p2.y)
        controlPoint.y -= diffY;
    
    return controlPoint;
}

@end
