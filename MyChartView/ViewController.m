//
//  ViewController.m
//  TestChartView
//
//  Created by WQL on 16/3/3.
//  Copyright © 2016年 WQL. All rights reserved.
//

#import "ViewController.h"
#import "WQLChartView.h"
#define RGBColorMaker(r, g, b, a) [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:(a)]
#define PhoneScreen_HEIGHT [UIScreen mainScreen].bounds.size.height
#define PhoneScreen_WIDTH [UIScreen mainScreen].bounds.size.width

@interface ViewController ()
{
    WQLChartView *chartView;
    
    NSMutableArray *xValuesArray;
    
    NSMutableArray *yValuesArray;
    
    NSInteger chartWidth;
    
    NSInteger chartHeight;
    
    NSInteger xStartValue;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //    CGFloat x = 4.0f/5.0f;
    //    NSLog(@"%f",x);
    
    [self loadData];
    
    [self loadChartView];
    
    [self loadButton];
    
}

- (void)loadData
{
    chartWidth = PhoneScreen_WIDTH-20;
    chartHeight = 300;
    xValuesArray = [NSMutableArray arrayWithObjects:@"1",nil];
    yValuesArray = [NSMutableArray arrayWithObjects:@"4",nil];
    xStartValue = 1;
}

- (void)loadChartView
{
    chartView = [[WQLChartView alloc]initWithFrame:CGRectMake(10, 100,chartWidth, chartHeight)];
    chartView.singleRowWidth = 50;//可注释掉
    chartView.xValueArray = xValuesArray;
    chartView.yValueArray = yValuesArray;
    chartView.columnColor = [UIColor lightGrayColor];//可注释掉
    chartView.pointColor = [UIColor orangeColor];//可注释掉
    chartView.xAxleTitle = @"日";//可注释掉
    chartView.yAxleTitle = @"件";//可注释掉
    chartView.type = ChartViewTypeColumn;//可注释掉
    chartView.showLine = YES;//可注释掉
//    chartView.lineColor = [UIColor blueColor];//可注释掉
    chartView.lineIsCurve = YES;//可注释掉
    chartView.colorOfNumber = [UIColor redColor];//可注释掉
    chartView.yPointArray = @[@"20",@"40",@"60",@"80",@"100"];//可注释掉
    [chartView showChartInView:self.view];

}

- (void)loadButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake((PhoneScreen_WIDTH-100)/2, 140+chartHeight, 100, 50);
    button.backgroundColor = RGBColorMaker(43, 163, 236, 1.0);
    [button setTitle:@"添加" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(addData:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    
    UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    deleteBtn.frame = CGRectMake((PhoneScreen_WIDTH-100)/2, 200+chartHeight, 100, 50);
    deleteBtn.backgroundColor = RGBColorMaker(43, 163, 236, 1.0);
    [deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
    [deleteBtn addTarget:self action:@selector(deleteData:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:deleteBtn];
    
    UIButton *changeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    changeBtn.frame = CGRectMake((PhoneScreen_WIDTH-100)/2, 260+chartHeight, 100, 50);
    changeBtn.backgroundColor = RGBColorMaker(43, 163, 236, 1.0);
    [changeBtn setTitle:@"修改类型" forState:UIControlStateNormal];
    [changeBtn addTarget:self action:@selector(changeAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:changeBtn];
    
    UIButton *lineBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    lineBtn.frame = CGRectMake((PhoneScreen_WIDTH-100)/2, 320+chartHeight, 100, 50);
    lineBtn.backgroundColor = RGBColorMaker(43, 163, 236, 1.0);
    [lineBtn setTitle:@"修改线条" forState:UIControlStateNormal];
    [lineBtn addTarget:self action:@selector(lineTypeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:lineBtn];
    
}

- (void)lineTypeButtonAction:(UIButton*)btn
{
    chartView.lineIsCurve = !chartView.lineIsCurve;
    
    [chartView updateView];
}

- (void)changeAction:(UIButton*)btn
{
    if (chartView.type == ChartViewTypeColumn) {
        chartView.type = ChartViewTypePoint;
    }else{
        chartView.type = ChartViewTypeColumn;
    }
}

- (void)addData:(UIButton*)btn
{
    NSInteger yValue = [self getRadomFromValue:5 toValue:100];
    
    xStartValue += 1;
    
    NSString *xString = [NSString stringWithFormat:@"%ld",xStartValue];
    NSString *yString = [NSString stringWithFormat:@"%ld",yValue];
    
    [xValuesArray addObject:xString];
    [yValuesArray addObject:yString];
    
    chartView.xValueArray = xValuesArray;
    chartView.yValueArray = yValuesArray;
    
    [chartView updateView];
    
    
}

- (void)deleteData:(UIButton*)btn
{
    if (xValuesArray.count > 1 ) {
        [xValuesArray removeLastObject];
        [yValuesArray removeLastObject];
    }else{
        NSLog(@"数组内数据不可为空");
    }
    
    chartView.xValueArray = xValuesArray;
    chartView.yValueArray = yValuesArray;
    
    [chartView updateView];
}

- (NSInteger)getRadomFromValue:(NSInteger)from toValue:(NSInteger)to
{
    return (from+arc4random()%(to-from));
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
