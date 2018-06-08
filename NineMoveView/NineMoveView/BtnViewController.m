//
//  BtnViewController.m
//  NineMoveView
//
//  Created by Mac on 2018/6/7.
//  Copyright © 2018年 xgkj. All rights reserved.
//

#import "BtnViewController.h"

#define UIColorFromRGB(rgbValue) [UIColor \ colorWithRed:((float)((rgbValue & 0xFF0000) >>16))/255.0 \ green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \ blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]



#define RGBCOLOR(r,g,b) [UIColor colorWithRed:r/255.f green:g/255.f blue:b/255.f alpha:1]

@interface BtnViewController ()
{
    
    CGPoint _ButtonPoint;
    
    CGPoint startPoint;
    
    
    
    NSInteger beginPos;
    
    NSInteger endPos;
    
    
    
}

@property (strong ,nonatomic) NSArray *textArray;

@property (strong ,nonatomic) NSMutableArray *deshArray;

@property (strong ,nonatomic) NSMutableArray *buttonArray;
@end

@implementation BtnViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = RGBCOLOR(239, 239, 239);
    
    self.view.alpha = 1.0f;
    
    _textArray = @[@"我的关注",@"逛一逛",@"搞笑集锦",@"团战集锦",@"编辑选推"];
    
    [self initalizeAppearance];
}
- (void)initalizeAppearance

{
    
    _deshArray = [NSMutableArray array];
    
    int itemWidth = ((self.view.bounds.size.width - 50) / 4);
    
    for (int i = 0; i < _textArray.count + 1; i++) {
        
        CGRect frame = CGRectMake((i % 4) * (itemWidth + 10) +10, 35 + (i / 4) * 40 + 5, itemWidth, 30);
        
        frame = CGRectInset(frame, 1, 1);
        
        UIView *lb = [[UIView alloc] initWithFrame:frame];
        
        [self.view addSubview:lb];
        
        [_deshArray addObject:lb];
        
    }
    
    [self initMenuButton:_textArray];
    
}



- (void)initMenuButton:(NSArray *)array

{
    
    _buttonArray = [NSMutableArray array];
    
    int buttonWidth = ((self.view.bounds.size.width - 50) / 4);
    
    for (int i = 0; i < array.count; i ++) {
        
        UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        
        menuButton.tag = i;
        
        menuButton.frame = CGRectMake((i%4)*(buttonWidth+10)+10,35+(i/4)*40+5,buttonWidth,30);
        
        menuButton.backgroundColor = [UIColor whiteColor];
        
        [menuButton setTitle:array[i] forState:UIControlStateNormal];
        
        [menuButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        
        menuButton.titleLabel.font = [UIFont systemFontOfSize:14];
        
//        menuButton.layer.borderColor = UIColorFromRGB(0xe5e5e5).CGColor;
        
        menuButton.layer.borderWidth = 0.3f;
        
        UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognizerAction:)];
        
        [menuButton addGestureRecognizer:longGesture];
        
        [self.view addSubview:menuButton];
        
        [self.buttonArray addObject:menuButton];
        
    }
    
    NSLog(@"_buttonArray = %@",_buttonArray);
    
}



- (void)longPressGestureRecognizerAction:(UILongPressGestureRecognizer *)sender

{
    
    UIButton *btn = (UIButton *)sender.view;
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        
        
        
        startPoint = [sender locationInView:sender.view];
        
        beginPos = btn.tag;
        
        _ButtonPoint = btn.center;
        
        NSLog(@"btn = %@",btn);
        
        NSLog(@"btn.tag = %lu",btn.tag);
        
        [UIView animateWithDuration:0.2 animations:^{
            
            btn.transform = CGAffineTransformMakeScale(1.1, 1.1);
            
            btn.alpha = 0.7;
            
            
            
        }];
        
    } else if (sender.state == UIGestureRecognizerStateChanged){
        
        CGPoint newPoint = [sender locationInView:sender.view];
        
        CGFloat deltaX = newPoint.x - startPoint.x;
        
        CGFloat deltaY = newPoint.y - startPoint.y;
        
        btn.center = CGPointMake(btn.center.x + deltaX, btn.center.y + deltaY);
        
        NSInteger fromIndex = btn.tag;
        
        
        
        NSInteger toIndex = [self judgeMoveByButtonPoint:btn.center moveButton:btn];
        
        
        
        if (toIndex < 0) {
            
            return;
            
        } else {
            
            btn.tag = toIndex;
            
            // 向后移动
            
            if (fromIndex - toIndex < 0) {
                
                for (NSInteger i = fromIndex; i < toIndex; i ++) {
                    
                    UIButton *nextBtn = _buttonArray[i+1];
                    
                    // 改变按钮中心点的位置
                    
                    CGPoint temp = nextBtn.center;
                    
                    [UIView animateWithDuration:0.5 animations:^{
                        
                        nextBtn.center = _ButtonPoint;
                        
                    }];
                    
                    _ButtonPoint = temp;
                    
                    // 交换tag值
                    
                    nextBtn.tag = i;
                    
                    
                    
                }
                
                [self sortArray];
                
            } else if (fromIndex - toIndex > 0) {
                
                // 向前移动
                
                for (NSInteger i = fromIndex; i > toIndex; i --) {
                    
                    UIButton *beforBtn = _buttonArray[i - 1];
                    
                    CGPoint temp = beforBtn.center;
                    
                    [UIView animateWithDuration:0.5 animations:^{
                        
                        beforBtn.center = _ButtonPoint;
                        
                    }];
                    
                    _ButtonPoint = temp;
                    
                    beforBtn.tag = i;
                    
                }
                
                [self sortArray];
                
            }
            
            
            
            
            
        }
        
        
        
    }
    
    
    
    
    
    else {
        
        [UIView animateWithDuration:0.2 animations:^{
            
            btn.transform = CGAffineTransformIdentity;
            
            btn.alpha = 1.0f;
            
            btn.center = _ButtonPoint;
            
        }];
        
    }
    
}





- (void)sortArray

{
    
    // 对已改变按钮的数组进行排序
    
    [_buttonArray sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        
        UIButton *temp1 = (UIButton *)obj1;
        
        UIButton *temp2 = (UIButton *)obj2;
        
        return temp1.tag > temp2.tag;    //将tag值大的按钮向后移
        
    }];
    
    
    
}



- (NSInteger)judgeMoveByButtonPoint:(CGPoint)point moveButton:(UIButton *)btn

{
    
    /**
     
     * 判断移动按钮的中心点是否包含了所在按钮的中心点如果是将i返回
     
     */
    
    for (NSInteger i = 0; i < _buttonArray.count; i++) {
        
        UIButton *button = _buttonArray[i];
        
        if (!btn || button != btn) {
            
            if (CGRectContainsPoint(button.frame, point)) {
                
                return i;
                
            }
            
        }
        
    }
    
    return -1;
    
}



- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    
    
    
}

@end
