//
//  WQLChartView.m
//  TestChartView
//
//  Created by WQL on 16/3/3.
//  Copyright © 2016年 WQL. All rights reserved.
//

#import "WQLChartView.h"
NSInteger const singleChartSpaceWidth = 10;
NSInteger const singleChartWidth = 25;
NSInteger const yPointNumber = 5;
NSInteger const yArrowHeight = 20;
NSInteger const xAxleTitleWidth = 20;

@interface WQLChartView ()
{
    //x轴上的个数 也就是有多少个柱子
    NSInteger xCount;
    
    //y的最大值
    NSInteger yMax;
    
    //y坐标的最大值
    NSInteger yAxleMax;
    
    //坐标轴的标题的宽度
    CGFloat titleWidth;
    
    //坐标轴的宽度
    CGFloat axleWidth;
    
    //x轴的layer
    CAShapeLayer *xAxleLayer;
    
    //y轴的layer
    CAShapeLayer *yAxleLayer;
    
    //y轴的标题的数组
    NSMutableArray *yTitleArray;
    
    //各个柱子顶部中点的x坐标
    NSMutableArray *topCenterPointXArray;
    
    //顶部的x起点坐标数组
    NSMutableArray *topPointXArray;
    
    //顶部的y起点坐标数组
    NSMutableArray *topPointYArray;
    
    //图形的点 array
    NSMutableArray *pointShapeLayerArray;
    
    //柱状图 array
    NSMutableArray *columnShapeLayerArray;
    
    //连线 数组
    NSMutableArray *lineArray;
    
    //之前的type
    ChartViewType beforeType;
    
    //是否为修改的
    BOOL isChange;
    
    //柱子的实际宽度
    CGFloat realWidth;
    
}
@end


@implementation WQLChartView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        titleWidth = 30;
        axleWidth = 2;
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

//设置x值的数组
- (void)setXValueArray:(NSArray *)xValueArray
{
    _xValueArray = xValueArray;
    
    //获取到有多少个柱子
    xCount = xValueArray.count;
    
}

//设置Y值的数组
- (void)setYValueArray:(NSArray *)yValueArray
{
    _yValueArray = yValueArray;
    
    //获取到y的最大值
    CGFloat maxValue = 0;
    
    for (int i = 0;i<yValueArray.count;i++) {
        
        NSString *y = yValueArray[i];
        
        CGFloat value = [y floatValue];
        
        //取最大值
        if (value > maxValue) {
            maxValue = value;
        }
        
        
        if (i == xCount -1) {
            
            //取不小于y最大值的最小整数
            yMax = (maxValue+1)/1;
            
            //y最大值与数值的最大值之间的差
            CGFloat point = yMax - maxValue;
            
            //如果之前最大值为整数，则为该值
            if (point == 1) {
                yMax = maxValue;
            }
            
        }
        
    }
    
    if (yAxleMax) {
        yMax = yAxleMax;
    }
    
}

- (void)setYPointArray:(NSArray *)yPointArray
{
    _yPointArray = yPointArray;
    
    CGFloat maxV = 0;
    
    for (int i = 0; i< yPointArray.count; i++) {
        NSString *yValue = yPointArray[i];
        
        CGFloat y = [yValue floatValue];
        
        if (maxV<y) {
            maxV = y;
        }
    }
    self.yAxlePointNumber = yPointArray.count;
    yAxleMax = maxV;
    yMax = maxV;
    
}

#pragma  mark - 更新视图
- (void)updateView
{
    
    for (UILabel *label in self.subviews) {
        [label removeFromSuperview];
    }
    
    //坐标轴的文本和刻度发生变化了 要更新
    [self loadTitleAndAxle];
    
    //视图也发生了变化 需要重新添加
    [self loadChartWithView:self.superview];
    
    //重新绘制
    [self setNeedsDisplay];
}

#pragma  mark - 展示表格
- (void)showChartInView:(UIView*)superView
{
    //加载标题和坐标轴
    [self loadTitleAndAxle];
    
    //默认的是柱状图
    if (!self.type) {
        self.type = ChartViewTypeColumn;
        //设置之前的类型为柱状图
        beforeType = ChartViewTypeColumn;
    }
    
    //加载表格
    [self loadChartWithView:superView];
    
}
#pragma  mark 设置类型
- (void)setType:(ChartViewType)type
{
    _type = type;
    
    //如果没有设置之前的类型 说明该次设置是第一次赋值
    switch (beforeType) {
        case ChartViewTypeColumn:
        {
            //如果新赋的值和之前的一样 则不需要做调整
            if (type == ChartViewTypeColumn) {
                isChange = NO;
            }else{
                isChange = YES;
            }
            //此时赋的值 成为之前设置的类型
            beforeType = type;
        }
            break;
        case ChartViewTypePoint:
        {
            if (type == ChartViewTypePoint) {
                isChange = NO;
            }else{
                isChange = YES;
            }
            beforeType = type;
        }
            
        default:
        {
            //如果都不符合 那么说明没有之前的类型
            beforeType = type;
        }
            break;
    }
    
    //更新视图
    [self updateView];
}




#pragma  mark - 加载标题与坐标轴
- (void)loadTitleAndAxle
{
    //y轴上分为几等分
    NSInteger pointNumber;
    if (self.yAxlePointNumber>0) {
        pointNumber = self.yAxlePointNumber;
    }else{
        pointNumber = yPointNumber;
    }
    //每个坐标点之间的值
    
    CGFloat y = yMax;
    
    CGFloat singleValue = y/pointNumber;
    
    
    
    if (!self.yPointArray) {
        //坐标点的标示
        yTitleArray = [NSMutableArray array];
        
        //从大到小 依次添加y轴的每个值
        for (int i = 0; i<pointNumber+1; i++) {
            
            NSString *yValue = [NSString stringWithFormat:@"%.1f",singleValue*i];
            
            [yTitleArray addObject:yValue];
        }
        
    }else{
        yTitleArray = [NSMutableArray arrayWithArray:self.yPointArray];
        [yTitleArray insertObject:@"0" atIndex:0];
    }
    
    
    CGFloat viewHeight = self.bounds.size.height;
    CGFloat viewWidth = self.bounds.size.width;
    
    //y轴上 每个点的垂直距离
    CGFloat singlePointVerticalSpace = (viewHeight-yArrowHeight-titleWidth)/(pointNumber );
    
    //y轴坐标的title
    NSInteger titleNumber = yTitleArray.count-1;
    for (int j = 0; j< pointNumber+1; j++) {
        UILabel *yTitleLabel = [[UILabel alloc]init];
        //顶部是一个箭头 然后是每个坐标点之间的间距 减10是为了让label的中分点对齐于坐标轴上的点
        yTitleLabel.frame = CGRectMake(0, yArrowHeight+j*singlePointVerticalSpace-10, titleWidth-axleWidth, 20);
        yTitleLabel.font = [UIFont systemFontOfSize:12.f];
        yTitleLabel.textAlignment = NSTextAlignmentRight;
        //假如分为5等份 则有6个点 最后一个是原点0
        if (j< pointNumber) {
            yTitleLabel.text = yTitleArray[titleNumber - j];
        }else{
            yTitleLabel.text = @"0";
        }
        [self addSubview:yTitleLabel];
    }
    //这里是y轴顶部的单位的label
    UILabel *unitLabel = [[UILabel alloc]init];
    unitLabel.frame = CGRectMake(0, 0, titleWidth-axleWidth, yArrowHeight/2);
    unitLabel.text = self.yAxleTitle;
    unitLabel.textAlignment = NSTextAlignmentRight;
    unitLabel.font = [UIFont systemFontOfSize:12.0f];
    [self addSubview:unitLabel];
    
    
    //单个柱子 不包括间距需要的宽度
    CGFloat singleWidth =  [self preferGetUserSettingWidthValue];
    //柱子之间的间距
    CGFloat singleSpace =  [self preferGetUserSettingSpaceValue];
    //总共需要的宽度 （单个柱子的间距＋单个柱子的宽度）＊柱子总个数＋y轴的标示的宽度＋额外的柱子间距＋坐标轴的宽度
    CGFloat needTotolWidth = (singleSpace+singleWidth)*xCount+titleWidth+singleSpace+axleWidth;
    
    if (viewWidth< needTotolWidth) {
        //所给的宽度不足时
        //平均一下 （总宽度－标题的宽度－x箭头的宽度（等于y箭头的高度）－x坐标的单位的宽度）除以柱子总个数
        CGFloat averageWidth = (viewWidth-titleWidth-yArrowHeight-xAxleTitleWidth)/xCount;
        //间距占1／4
        singleSpace = averageWidth/4;
        //宽度占3/4
        singleWidth = averageWidth*3/4;
        
    }
    
    topCenterPointXArray = [NSMutableArray array];
    topPointXArray = [NSMutableArray array];
    
    //循环添加x轴坐标的title
    for (int k = 0; k<xCount; k++) {
        UILabel *xTitleLabel = [[UILabel alloc]init];
        //起始位置是title＋单个柱子的间距＋（单个柱子的间距＋单个柱子的宽度）＊个数
        //y是总高度－底部的label的高度
        xTitleLabel.frame = CGRectMake(titleWidth+singleSpace+(singleSpace+singleWidth)*k, viewHeight-titleWidth, singleWidth, titleWidth);
        xTitleLabel.text = _xValueArray[k];
        
        //各个柱子顶部的中点的x坐标
        NSString *topPointX = [NSString stringWithFormat:@"%f",(xTitleLabel.frame.origin.x+xTitleLabel.frame.size.width/2)];
        [topCenterPointXArray addObject:topPointX];
        
        //各个柱子的顶部的x的起始坐标
        NSString *topStartPointX = [NSString stringWithFormat:@"%f",xTitleLabel.frame.origin.x];
        [topPointXArray addObject:topStartPointX];
        
        xTitleLabel.font = [UIFont systemFontOfSize:12.0f];
        xTitleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:xTitleLabel];
    }
    realWidth = singleWidth;
    //x轴的右侧的单位lable
    UILabel *xUnitLabel = [[UILabel alloc]init];
    //x为总宽度－单个柱子间距－x轴箭头的宽度－x轴标题label的宽度
    xUnitLabel.frame = CGRectMake(self.bounds.size.width-singleSpace-yArrowHeight-xAxleTitleWidth, viewHeight-titleWidth, yArrowHeight+xAxleTitleWidth, titleWidth);
    xUnitLabel.text = self.xAxleTitle;
    xUnitLabel.font = [UIFont systemFontOfSize:12.0f];
    xUnitLabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:xUnitLabel];
    
    
}

- (void)drawRect:(CGRect)rect
{
    CGFloat viewHeight = self.bounds.size.height;
    
    UIBezierPath *yAxle = [UIBezierPath bezierPath];
    //画y轴
    [yAxle moveToPoint:CGPointMake(titleWidth, 0)];
    [yAxle addLineToPoint:CGPointMake(titleWidth, viewHeight-titleWidth)];
    //画x轴
    [yAxle addLineToPoint:CGPointMake(self.bounds.size.width, viewHeight-titleWidth)];
    
    //y轴箭头
    [yAxle moveToPoint:CGPointMake(titleWidth-4, 4)];
    [yAxle addLineToPoint:CGPointMake(titleWidth, 0)];
    [yAxle addLineToPoint:CGPointMake(titleWidth+4, 4)];
    
    //x轴箭头
    [yAxle moveToPoint: CGPointMake(self.bounds.size.width-4, viewHeight-titleWidth-4)];
    [yAxle addLineToPoint:CGPointMake(self.bounds.size.width, viewHeight-titleWidth)];
    [yAxle addLineToPoint:CGPointMake(self.bounds.size.width-4, viewHeight-titleWidth+4)];
    
    
    
    //y轴上 有多少个点
    NSInteger pointNumber;
    if (self.yAxlePointNumber>0) {
        pointNumber = self.yAxlePointNumber;
    }else{
        pointNumber = yPointNumber;
    }
    
    
    //y轴上 每个点的垂直距离
    CGFloat singlePointVerticalSpace = (viewHeight-yArrowHeight-titleWidth)/(pointNumber );
    
    //y轴坐标上的小标记 也就是一格一格的刻度
    for (int j = 0; j<pointNumber+1; j++) {
        
        [yAxle moveToPoint:CGPointMake(titleWidth, yArrowHeight+j*singlePointVerticalSpace)];
        [yAxle addLineToPoint:CGPointMake(titleWidth+4, yArrowHeight+j*singlePointVerticalSpace)];
        
    }
    
    [yAxle stroke];
    
    if (!self.isHideNumber) {
        [self drawYValue];
    }
    
}

//标记各个点的y值
- (void)drawYValue
{
    NSInteger fontSize;
    UIColor *fontColor;
    
    //用户是否设置了属性值
    if (self.colorOfNumber) {
        fontColor = self.colorOfNumber;
    }else{
        fontColor = [UIColor blackColor];
    }
    
    if (self.fontSizeOfNumber>0) {
        fontSize = self.fontSizeOfNumber;
    }else{
        fontSize = 14;
    }
    
    for (int i = 0;i< self.yValueArray.count ; i++) {
        
        //y的值
        NSString *yValue = self.yValueArray[i];
        
        //y的文本宽度
        CGFloat textW = [self widthForTextString:yValue height:yArrowHeight fontSize:fontSize];
        
        //x的起始点
        CGFloat originX = [topPointXArray[i] floatValue];
        
        //y的坐标点（实际为柱子的顶点的y值）
        CGFloat originY = [topPointYArray[i] floatValue];
        
        //柱子的宽度
        CGFloat width = realWidth;
        
        //可用高度
        CGFloat height = yArrowHeight;
        
        
        if (textW < width) {
            [yValue drawInRect:CGRectMake(originX+(width-textW)/2, originY-yArrowHeight, width, height) withAttributes:@{ NSFontAttributeName:[UIFont systemFontOfSize:fontSize],                                        NSForegroundColorAttributeName:[fontColor colorWithAlphaComponent:1.0]}];
        }else{
            [yValue drawInRect:CGRectMake(originX, originY-yArrowHeight, width, height) withAttributes:@{ NSFontAttributeName:[UIFont systemFontOfSize:fontSize],NSForegroundColorAttributeName:[fontColor colorWithAlphaComponent:1.0]}];
        }
        
        
        
    }
    
}

#pragma  mark 加载图表视图
- (void)loadChartWithView:(UIView*)superView
{
    CGFloat viewWidth = self.bounds.size.width;
    
    //单个柱子 不包括间距需要的宽度
    CGFloat singleWidth =  [self preferGetUserSettingWidthValue];
    //柱子之间的间距
    CGFloat singleSpace =  [self preferGetUserSettingSpaceValue];
    
    //所需要的总宽度
    CGFloat needTotolWidth = (singleSpace+singleWidth)*xCount+titleWidth+singleSpace+axleWidth;
    
    if (viewWidth< needTotolWidth) {
        
        //所给的宽度不足时
        //总宽度－y轴的title的宽度－x轴的箭头宽度－x轴的右侧单位label
        CGFloat averageWidth = (viewWidth-titleWidth-yArrowHeight-xAxleTitleWidth)/xCount;
        singleSpace = averageWidth/4;
        singleWidth = averageWidth*3/4;
        
    }
    
    //根据类型加载视图
    switch (self.type) {
        case ChartViewTypeColumn:
        {
            [self loadColumnShapeWithSingleWidth:singleWidth withSpace:singleSpace];
        }
            break;
        case ChartViewTypePoint:
        {
            [self loadPointInChartView];
        }
            break;
            
        default:
            break;
    }
    
    
    [superView addSubview:self];
    
}
#pragma  mark 将上一次显示的视图从界面中移除
- (void)deletePointLayer
{
    //如果之前 添加了 则把之前的删了
    if (pointShapeLayerArray.count > 0) {
        for (CAShapeLayer *layer in pointShapeLayerArray) {
            [layer removeFromSuperlayer];
        }
    }
    
}

- (void)deleteColumnLayer
{
    //如果之前 添加了 则把之前的删了
    if (columnShapeLayerArray.count > 0) {
        for (CAShapeLayer *layer in columnShapeLayerArray) {
            [layer removeFromSuperlayer];
        }
    }
    
}

#pragma  mark 添加柱状图
- (void)loadColumnShapeWithSingleWidth:(CGFloat)singleW withSpace:(CGFloat)singleSpace
{
    
    CGFloat viewHeight = self.bounds.size.height;
    //如果改动了 则把之前的显示部分移除掉
    if (isChange) {
        [self deletePointLayer];
    }
    
    //如果之前 添加了 则把之前的删了
    if (columnShapeLayerArray.count > 0) {
        for (CAShapeLayer *layer in columnShapeLayerArray) {
            [layer removeFromSuperlayer];
        }
    }
    
    //把之前添加的线 移除掉
    if (lineArray.count > 0) {
        for (CAShapeLayer *lineLayer in lineArray) {
            [lineLayer removeFromSuperlayer];
        }
    }
    
    columnShapeLayerArray = [NSMutableArray array];
    lineArray = [NSMutableArray array];
    
    UIBezierPath *column = [UIBezierPath bezierPath];
    
    CGFloat xPosition = 0;
    if (!topPointYArray) {
        topPointYArray = [NSMutableArray array];
    }else{
        [topPointYArray removeAllObjects];
    }
    
    for (int i = 0; i<xCount; i++) {
        CAShapeLayer *columnLayer = [CAShapeLayer layer];
        //当前的y值
        NSString *value = _yValueArray[i];
        CGFloat yValue = [value floatValue];
        //y值 占坐标最大值的比率
        CGFloat rate = yValue/yMax;
        //单个柱子的高度
        CGFloat singleHeight = (viewHeight-titleWidth-yArrowHeight)*rate;
        
        NSString *topPointY = [NSString stringWithFormat:@"%f",viewHeight-titleWidth-singleHeight];
        [topPointYArray addObject:topPointY];
        
        //x轴 为柱子左下侧的点 y为坐标轴
        [column moveToPoint:CGPointMake(xPosition+singleSpace+titleWidth, viewHeight-titleWidth)];
        //柱子的左侧垂直线
        [column addLineToPoint:CGPointMake(xPosition+singleSpace+titleWidth, viewHeight-titleWidth-singleHeight)];
        //柱子的顶部水平线
        [column addLineToPoint:CGPointMake(xPosition+singleSpace+titleWidth+singleW, viewHeight-titleWidth-singleHeight)];
        //柱子的右侧垂直线
        [column addLineToPoint:CGPointMake(xPosition+singleSpace+titleWidth+singleW, viewHeight-titleWidth)];
        
        if (self.showLine) {
            
            UIBezierPath *line = [UIBezierPath bezierPath];
            
            CAShapeLayer *lineLayer = [CAShapeLayer layer];
            
            if (i>0) {
                //上一个点的y值
                NSString *lastValue = _yValueArray[i-1];
                CGFloat lastYValue = [lastValue floatValue];
                CGFloat lastRate = lastYValue/yMax;
                //取到上一个点的高度
                CGFloat lastSingleHeight = (viewHeight-titleWidth-yArrowHeight)*lastRate;
                
                //移到柱子的顶部中点
                [line moveToPoint:CGPointMake(xPosition+singleSpace+titleWidth+singleW/2, viewHeight-titleWidth-singleHeight)];
                //向上一个点 添加连线
                if (self.lineIsCurve) {
                    //曲线连接
                    //上一个点的x坐标
                    CGFloat lastPointX = xPosition+singleSpace+titleWidth+singleW/2-(singleW+singleSpace);
                    //上一个点的y坐标
                    CGFloat lastPointY = viewHeight - titleWidth-lastSingleHeight;
                    //该柱子顶部中点的x坐标
                    CGFloat pointX = xPosition+singleSpace+titleWidth+singleW/2;
                    //该柱子顶部中点的y坐标
                    CGFloat pointY = viewHeight-titleWidth-singleHeight;
                    //添加曲线 两个控制点 x为两个点的中间点 y为首末点的y坐标 为了实现平滑连接
                    [line addCurveToPoint:CGPointMake(lastPointX, lastPointY) controlPoint1:CGPointMake((pointX+lastPointX)/2, pointY) controlPoint2:CGPointMake((pointX+lastPointX)/2, lastPointY)];
                }else{
                    //直线连接
                    [line addLineToPoint:CGPointMake(xPosition+singleSpace+titleWidth+singleW/2-(singleW+singleSpace), viewHeight-titleWidth-lastSingleHeight)];
                }
                
            }
            lineLayer.path = line.CGPath;
            //线条宽度
            lineLayer.lineWidth = self.lineWidth>0?self.lineWidth:2;
            if (!self.lineColor) {
                self.lineColor = [UIColor redColor];
            }
            //线条颜色
            lineLayer.strokeColor = self.lineColor.CGColor;
            lineLayer.fillColor = [UIColor clearColor].CGColor;
            [lineArray addObject:lineLayer];
            
        }
        
        columnLayer.path = column.CGPath;
        if (!self.columnColor) {
            self.columnColor = [UIColor orangeColor];
        }
        
        columnLayer.fillColor = CGColorCreateCopyWithAlpha(self.columnColor.CGColor, 1.0);
        columnLayer.strokeStart = 0;
        columnLayer.strokeEnd = 1.0;
        [columnShapeLayerArray addObject:columnLayer];
        
        [self.layer addSublayer:columnLayer];
        
        for (CAShapeLayer *lineLayer in lineArray) {
            [self.layer addSublayer:lineLayer];
        }
        
        xPosition += (singleW+singleSpace);
        
    }
}

#pragma  mark  添加 点视图
- (void)loadPointInChartView
{
    if (isChange) {
        [self deleteColumnLayer];
    }
    
    UIBezierPath *circle = [UIBezierPath bezierPath];
    
    CGFloat viewHeight = self.bounds.size.height;
    
    //如果之前 添加了 则把之前的删了
    if (pointShapeLayerArray.count > 0) {
        for (CAShapeLayer *layer in pointShapeLayerArray) {
            [layer removeFromSuperlayer];
        }
    }
    
    //把之前添加的线条删除了
    if (lineArray.count > 0) {
        for (CAShapeLayer *lineLayer in lineArray) {
            [lineLayer removeFromSuperlayer];
        }
    }
    
    pointShapeLayerArray = [NSMutableArray array];
    lineArray = [NSMutableArray array];
    
    if (!topPointYArray) {
        topPointYArray = [NSMutableArray array];
    }else{
        [topPointYArray removeAllObjects];
    }
    //顶部中点连线
    NSInteger count = topCenterPointXArray.count;
    if (count >0) {
        
        for (int i = 0; i<topCenterPointXArray.count; i++) {
            
            CAShapeLayer *circleLayer = [CAShapeLayer layer];
            
            NSString *topPoint = topCenterPointXArray[i];
            CGFloat pointX = [topPoint floatValue];
            //y值
            CGFloat yValues = [self.yValueArray[i] floatValue];
            //y坐标又是不一样了 y值越大，柱子越高，坐标其实是越小
            CGFloat pointY = (1-(yValues/yMax))*(viewHeight-yArrowHeight-titleWidth)+yArrowHeight;
            
            [topPointYArray addObject:[NSString stringWithFormat:@"%f",pointY]];
            
            [circle moveToPoint:CGPointMake(pointX, pointY)];
            
            CGFloat radius = self.pointWidth >0 ?self.pointWidth:5.0;
            //标示点 为圆
            [circle  addArcWithCenter:CGPointMake(pointX, pointY) radius:radius startAngle:0 endAngle:M_PI*2 clockwise:YES];
            circleLayer.path = circle.CGPath;
            if (!self.pointColor) {
                self.pointColor = [UIColor orangeColor];
            }
            if (self.isFillLine) {
                self.pointColor = [UIColor whiteColor];
            }
            //圆点的填充色
            circleLayer.fillColor = CGColorCreateCopyWithAlpha(self.pointColor.CGColor, 1.0);
            circleLayer.strokeStart = 0;
            circleLayer.strokeEnd = 1.0;
            circleLayer.lineWidth = 1;
            [pointShapeLayerArray addObject:circleLayer];
            
            if (self.showLine) {
                
                UIBezierPath *line = [UIBezierPath bezierPath];
                
                CAShapeLayer *lineLayer = [CAShapeLayer layer];
                
                if (i>0) {
                    NSString *lastXValue = topCenterPointXArray[i-1];
                    CGFloat lastPointX = [lastXValue floatValue];
                    
                    NSString *lastValue = _yValueArray[i-1];
                    CGFloat lastYValue = [lastValue floatValue];
                    //y坐标又是不一样了 y值越大，柱子越高，坐标其实是越小
                    CGFloat lastPointY = (1-(lastYValue/yMax))*(viewHeight-yArrowHeight-titleWidth)+yArrowHeight;
                    
                    //移到中点
                    if (self.isFillLine) {
                        [line moveToPoint:CGPointMake(pointX, viewHeight-titleWidth)];
                        [line addLineToPoint:CGPointMake(pointX, pointY)];
                        
                    }else{
                        [line moveToPoint:CGPointMake(pointX,pointY)];
                    }
                    
                    
                    if (self.lineIsCurve) {
                        //曲线连接 两个控制点 x为两个点的中间点 y为首末点的y坐标 为了实现平滑连接
                        [line addCurveToPoint:CGPointMake(lastPointX, lastPointY) controlPoint1:CGPointMake((pointX+lastPointX)/2, pointY) controlPoint2:CGPointMake((pointX+lastPointX)/2, lastPointY)];
                    }else{
                        //向上一个点 添加连线
                        [line addLineToPoint:CGPointMake(lastPointX,lastPointY)];
                    }
                    
                    if (self.isFillLine) {
                        [line addLineToPoint:CGPointMake(lastPointX, viewHeight-titleWidth)];
                    }
                    
                }
                lineLayer.path = line.CGPath;
                lineLayer.lineWidth = self.lineWidth>0?self.lineWidth:2;
                if (!self.lineColor) {
                    self.lineColor = [UIColor blackColor];
                }
                lineLayer.strokeColor = self.lineColor.CGColor;
                if (self.isFillLine) {
                    UIColor *fillColor;
                    
                    if (self.lineFillColor) {
                        fillColor = self.lineFillColor;
                    }else{
                        fillColor = [UIColor orangeColor];
                    }
                    lineLayer.fillColor = fillColor.CGColor;
                    
                }else{
                    lineLayer.fillColor = [UIColor clearColor].CGColor;
                }
                
                [lineArray addObject:lineLayer];
                
            }
            
        }
    }
    
    for (CAShapeLayer *layer  in pointShapeLayerArray) {
        [self.layer addSublayer:layer];
    }
    
    for (CAShapeLayer *lineLayer in lineArray) {
        [self.layer addSublayer:lineLayer];
    }
    
}

#pragma  mark 优先获取用户设置的宽度值
- (CGFloat)preferGetUserSettingWidthValue
{
    //单个柱子 不包括间距需要的宽度
    CGFloat singleWidth = 0;
    
    if (self.singleRowWidth>0 ) {
        //如果用户设置了每个柱子的宽度
        singleWidth = self.singleRowWidth;
        
    }else{
        //如果没有设置柱子的宽度
        singleWidth = singleChartWidth;
    }
    return singleWidth;
}

#pragma  mark 优先获取用户设置的间距值
- (CGFloat)preferGetUserSettingSpaceValue
{
    //柱子之间的间距
    CGFloat singleSpace = 0;
    
    if (self.singleChartSpace) {
        //如果设置了柱子之间的间距
        singleSpace = self.singleChartSpace;
        
    }else{
        //如果没有设置柱子之间的间距
        singleSpace = singleChartSpaceWidth;
    }
    
    return singleSpace;
}

#pragma  mark - 计算文本的宽度
- (CGFloat) widthForTextString:(NSString *)tStr height:(CGFloat)tHeight fontSize:(CGFloat)tSize{
    
    NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:tSize]};
    CGRect rect = [tStr boundingRectWithSize:CGSizeMake(MAXFLOAT, tHeight) options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil];
    return rect.size.width+5;
    
}


@end
