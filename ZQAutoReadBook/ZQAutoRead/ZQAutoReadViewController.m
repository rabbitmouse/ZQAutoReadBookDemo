//
//  ZQAutoReadViewController.m
//  ZQAutoReadBook
//
//  Created by zzq on 2018/9/29.
//  Copyright © 2018年 zzq. All rights reserved.
//

#import "ZQAutoReadViewController.h"
#import "ZQAutoReadToolBar.h"

@interface ZQAutoReadViewController ()<AutoReadToolBarDelegate>

@property (nonatomic, strong) CADisplayLink *link;
@property (nonatomic, strong) CAShapeLayer  *shapeLayer;
@property (nonatomic, strong) UIImageView  *backImage;
@property (nonatomic, strong) UIImageView  *shadowImage;

@property (nonatomic, assign) CGFloat topY;
@property (nonatomic, assign) CGFloat speed;

@property (nonatomic, assign) BOOL isPaused;

@property (nonatomic, strong) ZQAutoReadToolBar *toolBar;
@property (nonatomic, strong) UIView *tapView;

@end

@interface ZQAutoReadViewController ()

@end

@implementation ZQAutoReadViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        _speed = 3;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _backImage = [[UIImageView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:_backImage];
    
    _shapeLayer = [CAShapeLayer layer];
    _backImage.layer.mask = _shapeLayer;
    
    _shadowImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 5)];
    _shadowImage.image = [UIImage imageNamed:@"line"];
    [self.view addSubview:_shadowImage];
    
    [self addToolBar];
}

- (void)addToolBar {
    [self.view addSubview:self.tapView];
    [self.view addSubview:self.toolBar];
    
    CGFloat toolH = CGRectGetHeight(self.toolBar.frame);
    self.toolBar.frame = CGRectMake(0, self.view.bounds.size.height + toolH, self.view.bounds.size.width, toolH);    
    self.tapView.frame = self.view.bounds;

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap)];
    [self.tapView addGestureRecognizer:tap];
}


- (void)updateWithView:(UIImage *)image {
    _shapeLayer.path = [UIBezierPath bezierPathWithRect:self.view.frame].CGPath;
    self.backImage.image = image;
}

- (void)startAuto {
    if (_link == nil) {
        // 启动定时调用
        _link = [CADisplayLink displayLinkWithTarget:self selector:@selector(getCurrent:)];
        [_link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
}

-(void)getCurrent:(CADisplayLink *)displayLink{
    if(_topY >= self.view.frame.size.height) {
        _topY = 0;
        self.shadowImage.center = CGPointMake(self.view.center.x, self.shadowImage.bounds.size.height/2);
        
        [_link invalidate];
        _link = nil;
        
        [_delegate finishReadPage:self];
        return;
    }
    _topY += _speed;
    [self setCurrentShadowLayer];
    [self setCurrentMaskLayer];
}

- (void)setCurrentMaskLayer {
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, nil, 0, _topY);
    CGPathAddLineToPoint(path, nil, self.view.frame.size.width, _topY);
    CGPathAddLineToPoint(path, nil, self.view.frame.size.width, self.view.frame.size.height);
    CGPathAddLineToPoint(path, nil, 0, self.view.frame.size.height);
    CGPathCloseSubpath(path);
    
    _shapeLayer.path = path;
    CGPathRelease(path);
}

- (void)setCurrentShadowLayer {
    [UIView animateWithDuration:0.1 animations:^{
        CGPoint pos = self.shadowImage.center;
        pos.y += _speed;
        self.shadowImage.center = pos;
    }];
}


- (void)singleTap {
    _isPaused ^= 1;
    [_link setPaused:_isPaused];
    [UIView animateWithDuration:0.25 animations:^{
        if(_isPaused) {
            //显示
            CGRect frame = _toolBar.frame;
            CGFloat h = CGRectGetHeight(_toolBar.frame);
            frame.origin.y -= h;
            _toolBar.frame = frame;
            _toolBar.alpha = 1;
        }
        else {
            //隐藏
            CGRect frame = _toolBar.frame;
            CGFloat h = CGRectGetHeight(_toolBar.frame);
            frame.origin.y += h;
            _toolBar.frame = frame;
            _toolBar.alpha = 0;
        }
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - autoReadToolBarDelegate
- (void)speedUp:(CGFloat)speed {
    _speed = speed/5;
}

- (void)speedLow:(CGFloat)speed {
    _speed = speed/5;
}

- (void)endAutoRead {
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [_link invalidate];
    _link = nil;
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

#pragma mark - getter && setter
- (ZQAutoReadToolBar *)toolBar {
    if(!_toolBar) {
        _toolBar = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([ZQAutoReadToolBar class]) owner:self options:nil].firstObject;
        _toolBar.alpha = 0;
        _toolBar.delegate = self;
        _toolBar.speed = _speed * 5;
    }
    return _toolBar;
}

- (UIView *)tapView {
    if(!_tapView) {
        _tapView = [UIView new];
        _tapView.backgroundColor = [UIColor clearColor];
    }
    return _tapView;
}

@end
