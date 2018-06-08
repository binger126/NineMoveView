//
//  SplitScreenSwitch.m
//  NineMoveView
//
//  Created by Mac on 2018/6/8.
//  Copyright © 2018年 xgkj. All rights reserved.
//

#import "SplitScreenSwitch.h"

//一个点是否在一个区域内
bool CGRectContainsPoint (CGRect rect,CGPoint point);

static NSInteger margSpaceX = 10.0f;  //间距x
static NSInteger margSpaceY = 8.0f;  //间距y
static NSInteger columnNumber = 3.0f;//列数

@interface SplitScreenSwitch ()<UIScrollViewDelegate>

@property (nonatomic, strong) NSMutableArray *frameArray;
@property (nonatomic, strong) NSMutableArray *bigArray;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, strong) UIButton *btn;
@property (nonatomic, assign) CGPoint lastPoint;

@end

@implementation SplitScreenSwitch

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.frame];
        scrollView.delegate = self;
        [self addSubview:scrollView];
        self.scrollView = scrollView;
        scrollView.showsHorizontalScrollIndicator =YES; //垂直方向的滚动指示
        //    scrollView.bounces = YES;//控制控件遇到边框是否反弹
        scrollView.directionalLockEnabled = YES; //只能一个方向滑动
        scrollView.scrollEnabled = YES;//控制控件是否能滚动
        scrollView.pagingEnabled = YES;//是否翻页
        scrollView.contentSize = CGSizeMake(self.frame.size.width*self.bigArray.count, self.frame.size.height);
        
        NSInteger spaceCount = columnNumber + 1 ; //(间隙count永远比列数多1)
        NSInteger width = (CGRectGetWidth(self.frame) - spaceCount*margSpaceX)/columnNumber;
        for (NSInteger i=0;i<self.bigArray.count;i++) {
            NSInteger x = (CGRectGetWidth(self.frame))*i;
            NSMutableArray *tempArray = [NSMutableArray array];
            for (NSInteger j=0;j<[self.bigArray[i] count];j++) {
                @autoreleasepool {
                    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                    [btn setBackgroundColor:[UIColor brownColor]];
                    [btn setTitle:self.bigArray[i][j] forState:UIControlStateNormal];
                    btn.frame = CGRectMake(margSpaceX+(width+margSpaceX)*(j%columnNumber) + x, margSpaceY+(width+margSpaceY)*(j/columnNumber), width, width);
                    [scrollView addSubview:btn];
                    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressMethod:)];
                    longPressGesture.minimumPressDuration = 0.3f;
                    [btn addGestureRecognizer:longPressGesture];
                    [tempArray addObject:btn];
                }
            }
            [self.frameArray addObject:tempArray];
            
        }
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.bounds = CGRectMake(0, 0, width, width);
        btn.hidden = YES;
        [btn setBackgroundColor:[UIColor lightGrayColor]];
        self.btn = btn;
        [self addSubview:btn];
        self.currentPage = 0;
    }
    return self;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // 赋值给记录当前坐标的变
    self.currentPage = scrollView.contentOffset.x/scrollView.frame.size.width;
}


#pragma mark - 长按手势方法
-(void)longPressMethod:(UILongPressGestureRecognizer*)gesture{
    static UIButton *fromBtn = nil;
    static NSMutableArray *lastArray = nil;
    if (gesture.state==UIGestureRecognizerStateBegan) {
        //获取长按的按钮视图
        fromBtn = (UIButton *)gesture.view;
        //把拖动的视图放在屏幕最前端
        [self bringSubviewToFront:self.btn];
        
        //获取长按视图的中心点
        CGPoint fromPoint = fromBtn.center;
        //根据当前的scrollView的偏移量更新拖动按钮的中心点
        NSInteger x = CGRectGetWidth(self.frame)*self.currentPage;
        fromPoint.x-=x;
        self.btn.center = fromPoint;
        self.btn.hidden = NO;
        [self.btn setTitle:fromBtn.currentTitle forState:UIControlStateNormal];
        [UIView animateWithDuration:0.2 animations:^{
            self.btn.transform = CGAffineTransformMakeScale(1.1, 1.1);
            self.btn.alpha = 0.7;
        }];
        //获取初始中心点
        _lastPoint = fromBtn.center;
    }else if (gesture.state==UIGestureRecognizerStateChanged) {
        //获取拖动中的中心点
        CGPoint fromPoint = [gesture locationInView:self.scrollView];
        //根据当前的scrollView的偏移量更新拖动按钮的中心点
        NSInteger x = CGRectGetWidth(self.frame)*self.currentPage;
        fromPoint.x-=x;
        self.btn.center = fromPoint;
        //查找拖动中交换的目标按钮
        for (NSInteger i=0,count = [self.frameArray[self.currentPage] count]; i<count; i++) {
            UIButton *toBtn = self.frameArray[self.currentPage][i];
            CGRect toFrame = toBtn.frame;
            //根据偏移量更新frame
            toFrame.origin.x-=x;
            //计算目标按钮和移动按钮重合区域大小
            CGRect rect = CGRectIntersection(toFrame, self.btn.frame);
            //判断重合区域面积 大于等于 移动按钮的一半+5视为交换目标按钮为本身而直接返回不做交换处理
            //+5为防止两个目标临界值相等而不知道哪一个是真正的目标
            if (rect.size.width*rect.size.height>=self.btn.frame.size.width*self.btn.frame.size.height/2+5) {
                return;
            }
            //判断拖动的按钮中心点是否在目标按钮区域范围内
            if (CGRectContainsPoint(toFrame, self.btn.center)) {
                NSMutableArray *currentArray = self.frameArray[self.currentPage];
                if (!lastArray) {
                    //当前屏幕内部完成数据交换
                    [currentArray exchangeObjectAtIndex:[currentArray indexOfObject:toBtn] withObjectAtIndex:[currentArray indexOfObject:fromBtn]];
                }else {
                    //切屏完成数据交换
                    NSInteger currentIndex = [currentArray indexOfObject:toBtn];
                    NSInteger lastIndex = [lastArray indexOfObject:fromBtn];
                    [lastArray insertObject:toBtn atIndex:lastIndex];
                    [lastArray removeObject:fromBtn];
                    [currentArray insertObject:fromBtn atIndex:currentIndex];
                    [currentArray removeObject:toBtn];
                    lastArray = nil;
                }
                //执行交换动画
                CGPoint fromPoint = fromBtn.center;
                CGPoint toPoint = toBtn.center;
                [UIView animateWithDuration:.2 animations:^{
                    toBtn.center = fromPoint;
                    fromBtn.center = toPoint;
                }];
                break;
            }
        }
        //向右切屏
        if (self.btn.center.x>CGRectGetWidth(self.frame)-10&&_lastPoint.x<self.btn.center.x) {
            if (self.currentPage==self.bigArray.count-1) {
                return;
            }
            lastArray = self.frameArray[self.currentPage];
            self.currentPage++;
            fromPoint.x+=(CGRectGetWidth(self.frame)*.8);
            self.btn.center = fromPoint;
            // 赋值给记录当前坐标的变
            [UIView animateWithDuration:.5 animations:^{
                self.scrollView.contentOffset = CGPointMake(self.currentPage*CGRectGetWidth(self.frame), 0);
            }];
        }
        //向左切屏
        if (self.btn.center.x<10&&_lastPoint.x>self.btn.center.x) {
            if (self.currentPage==0) {
                return;
            }
            lastArray = self.frameArray[self.currentPage];
            self.currentPage--;
            fromPoint.x-=(CGRectGetWidth(self.frame)*.8);
            self.btn.center = fromPoint;
            // 赋值给记录当前坐标的变
            [UIView animateWithDuration:.5 animations:^{
                self.scrollView.contentOffset = CGPointMake(self.currentPage*CGRectGetWidth(self.frame), 0);
            }];
        }
    }else if (gesture.state==UIGestureRecognizerStateEnded) {
        
        [UIView animateWithDuration:0.2 animations:^{
            self.btn.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            self.btn.hidden = YES;
        }];
        fromBtn = nil;
        lastArray = nil;
    }
}

-(NSMutableArray *)bigArray {
    if (!_bigArray) {
        _bigArray = [NSMutableArray array];
        [_bigArray addObject:@[@"屏一按钮1",@"屏一按钮2",@"屏一按钮3",@"屏一按钮4",@"屏一按钮5",@"屏一按钮6",@"屏一按钮7",@"屏一按钮8",@"屏一按钮9",]];
        [_bigArray addObject:@[@"屏二按钮1",@"屏二按钮2",@"屏二按钮3",@"屏二按钮4",@"屏二按钮5",@"屏二按钮6",@"屏二按钮7",@"屏二按钮8",@"屏二按钮9",]];
    }
    return _bigArray;
}
- (NSMutableArray *)frameArray {
    if (!_frameArray) {
        _frameArray = [NSMutableArray array];
    }
    return _frameArray;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
