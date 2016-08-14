//
//  WQLChartView.h
//  MyChartView
//
//  Created by WQL on 16/3/3.
//  Copyright © 2016年 WQL. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger ,ChartViewType) {
    ChartViewTypeColumn,
    ChartViewTypePoint
};

@interface WQLChartView : UIView
/**
 *  图表的类型
 */
@property (nonatomic,assign) ChartViewType type;
/**
 *  单列的宽度
 */
@property (nonatomic,assign) CGFloat singleRowWidth;
/**
 *  每个柱子之间的间距
 */
@property (nonatomic,assign) CGFloat singleChartSpace;
/**
 *  x的值 数组
 */
@property (nonatomic,strong) NSArray *xValueArray;
/**
 *  y的值 数组
 */
@property (nonatomic,strong) NSArray *yValueArray;
/**
 *  x轴的右侧标题（比如：时间）
 */
@property (nonatomic,copy) NSString *xAxleTitle;
/**
 *  y轴的顶部标题 （比如：万件）
 */
@property (nonatomic,copy) NSString *yAxleTitle;
/**
 *  y轴上有几个点
 */
@property (nonatomic,assign) NSInteger yAxlePointNumber;
/**
 *  y轴的坐标点 数组
 */
@property (nonatomic,strong) NSArray *yPointArray;
/**
 *  柱子的颜色
 */
@property (nonatomic,strong) UIColor *columnColor;
/**
 *  是否显示线条
 */
@property (nonatomic,assign) BOOL showLine;
/**
 *  连线的颜色
 */
@property (nonatomic,strong) UIColor *lineColor;
/**
 *  连线的宽度（粗细）
 */
@property (nonatomic,assign) CGFloat lineWidth;
/**
 *  点的颜色（只有是point类型才有效）
 */
@property (nonatomic,strong) UIColor *pointColor;
/**
 *  点的宽度（只有point类型才有效）
 */
@property (nonatomic,assign) CGFloat pointWidth;
/**
 *  连接是否使用平滑的曲线
 */
@property (nonatomic,assign) BOOL lineIsCurve;
/**
 *  是否隐藏数值 默认不隐藏
 */
@property (nonatomic,assign) BOOL isHideNumber;
/**
 *  数值的颜色
 */
@property (nonatomic,strong) UIColor *colorOfNumber;
/**
 *  数值的字号
 */
@property (nonatomic,assign) NSInteger fontSizeOfNumber;
/**
 *  是否填充线状图
 */
@property (nonatomic,assign) BOOL isFillLine;
/**
 *  填充连线与X轴之间的颜色
 */
@property (nonatomic,strong) UIColor *lineFillColor;

//在superView上展示视图 必须调用 参数配置完毕后调用
- (void)showChartInView:(UIView*)superView;

//更新视图
- (void)updateView;


@end
