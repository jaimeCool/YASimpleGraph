//
//  ViewController.m
//  Demo
//
//  Created by Jaime on 2017/7/30.
//  Copyright © 2017年 Yaso. All rights reserved.
//

#import "ViewController.h"
#import "YASimpleGraphView.h"
@interface ViewController () <YASimpleGraphDelegate> {
    NSArray *allValues;
    NSArray *allDates;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor grayColor];
    [self setupUI];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setupUI {
    allValues = @[@"20.00",@"0",@"110.00",@"70",@"80",@"40"];
    allDates = @[@"06/01",@"06/02",@"06/03",@"06/04",@"06/05",@"06/06"];
    
    // Create a gradient to apply to the bottom portion of the graph
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    CGFloat components[8] = {
        0.33, 0.67, 0.93, 0.25,
        1.0, 1.0, 1.0, 1.0
    };
    
    YASimpleGraphView *graphView = [[YASimpleGraphView alloc]init];
    graphView.frame = CGRectMake(15, 200, 375-30, 200);
    graphView.backgroundColor = [UIColor whiteColor];
    graphView.allValues = allValues;
    graphView.allDates = allDates;
    graphView.defaultShowIndex = allDates.count-1;
    graphView.delegate = self;
    graphView.lineColor = [UIColor grayColor];
    graphView.lineWidth = 1.0/[UIScreen mainScreen].scale;
    graphView.lineAlpha = 1.0;
    graphView.enableTouchLine = YES;
    
    //graphView.topAlpha = 1.0;
    //graphView.topColor = [UIColor orangeColor];
    //graphView.topGradient = CGGradientCreateWithColorComponents(colorspace, components, locations, num_locations);
    //graphView.bottomAlpha = 1.0;
    //graphView.bottomColor = [UIColor orangeColor];
    graphView.bottomGradient = CGGradientCreateWithColorComponents(colorspace, components, locations, num_locations);
    
    [self.view addSubview:graphView];
    [graphView startDraw];
}

//自定义X轴 显示标签索引
- (NSArray *)incrementPositionsForXAxisOnLineGraph:(YASimpleGraphView *)graph {
    return @[@0,@1,@2,@3,@4,@5];
}

//Y轴坐标点数
- (NSInteger)numberOfYAxisLabelsOnLineGraph:(YASimpleGraphView *)graph {
    return 5;
}

//自定义popUpView
- (UIView *)popUpViewForLineGraph:(YASimpleGraphView *)graph {
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    label.backgroundColor = [UIColor colorWithRed:146/255.0 green:191/255.0 blue:239/255.0 alpha:1];
    label.numberOfLines = 0;
    label.font = [UIFont systemFontOfSize:10];
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}

//修改相应点位弹出视图
- (void)lineGraph:(YASimpleGraphView *)graph modifyPopupView:(UIView *)popupView forIndex:(NSUInteger)index {
    UILabel *label = (UILabel*)popupView;
    NSString *date = [NSString stringWithFormat:@"%@",allDates[index]];
    NSString *str = [NSString stringWithFormat:@" %@ \n %@元 ",date,allValues[index]];
    
    CGRect rect = [str boundingRectWithSize:CGSizeMake(MAXFLOAT, 40) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:10]} context:nil];
    
    [label setFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
    label.textColor = [UIColor whiteColor];
    label.text = str;
}
@end
