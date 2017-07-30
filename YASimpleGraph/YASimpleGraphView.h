//
//  YASimpleGraphView.h
//  TestGraphView
//
//  Created by Jaime on 2017/6/15.
//  Copyright © 2017年 Jaime. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YASimpleGraphView;
@protocol YASimpleGraphDelegate <NSObject>

//高度自定义X轴 显示标签索引
- (NSArray *)incrementPositionsForXAxisOnLineGraph:(YASimpleGraphView *)graph;

//Y轴坐标点数
- (NSInteger)numberOfYAxisLabelsOnLineGraph:(YASimpleGraphView *)graph;

//弹出视图
- (UIView *)popUpViewForLineGraph:(YASimpleGraphView *)graph;

//修改相应点位弹出视图
- (void)lineGraph:(YASimpleGraphView *)graph modifyPopupView:(UIView *)popupView forIndex:(NSUInteger)index;

@end

@interface YASimpleGraphView : UIView

@property (nonatomic,weak) id <YASimpleGraphDelegate>delegate;

- (void)startDraw;



//----- Data ------//

//所有点的值
@property (nonatomic,strong) NSArray *allValues;
//所有点的key
@property (nonatomic,strong) NSArray *allDates;
// Default show dot index
@property (nonatomic,assign) NSInteger defaultShowIndex;



/// The line color
@property (nonatomic, strong) UIColor *lineColor;

/// The line width
@property (nonatomic, assign) CGFloat lineWidth;

/// The line alpha
@property (assign, nonatomic) float lineAlpha;



/// The Dot color
@property (nonatomic, strong) UIColor *dotColor;

/// The Dot borderColor
@property (nonatomic, strong) UIColor *dotBorderColor;

/// The Dot width
@property (nonatomic, assign) CGFloat dotWidth;

/// The Dot borderWidth
@property (nonatomic, assign) CGFloat dotBorderWidth;



/// The dashLine color
@property (nonatomic, strong) UIColor *dashLineColor;

/// The dashLine width
@property (nonatomic, assign) CGFloat dashLineWidth;

/// The bottomLine color
@property (nonatomic, strong) UIColor *bottomLineColor;

/// The bottomLine width
@property (nonatomic, assign) CGFloat bottomLineHeight;

/// The XAxisDot color
@property (nonatomic, strong) UIColor *XAxisDotColor;

/// The XAxisDot width
@property (nonatomic, assign) CGFloat XAxisDotWidth;

/// The XAxisDot height
@property (nonatomic, assign) CGFloat XAxisDotHeight;



/// The touchInputLine
@property (strong, nonatomic) UIView *touchInputLine;

/// Enable the touchInputLine
@property (nonatomic) BOOL enableTouchLine;

/// The touchInputLine color
@property (strong, nonatomic) UIColor *colorTouchInputLine;

/// The touchInputLine color
@property (nonatomic) CGFloat widthTouchInputLine;

/// The touchInputLine alpha
@property (nonatomic) CGFloat alphaTouchInputLine;



/// The YAxisLabel color
@property (nonatomic, strong) UIColor *YAxisLabelTextColor;

/// The YAxisLabel font
@property (nonatomic, strong) UIFont *YAxisLabelFont;

/// The XAxisLabel color
@property (nonatomic, strong) UIColor *XAxisLabelTextColor;

/// The XAxisLabel font
@property (nonatomic, strong) UIFont *XAxisLabelFont;





/// The alpha value of the area above the line, inside of its superview
@property (assign, nonatomic) float topAlpha;

/// The alpha value of the area below the line, inside of its superview
@property (assign, nonatomic) float bottomAlpha;

/// The color of the area above the line, inside of its superview
@property (strong, nonatomic) UIColor *topColor;

/// A color gradient applied to the area above the line, inside of its superview. If set, it will be drawn on top of the fill from the \p topColor property.
@property (assign, nonatomic) CGGradientRef topGradient;

/// The color of the area below the line, inside of its superview
@property (strong, nonatomic) UIColor *bottomColor;

/// A color gradient applied to the area below the line, inside of its superview. If set, it will be drawn on top of the fill from the \p bottomColor property.
@property (assign, nonatomic) CGGradientRef bottomGradient;

@end
