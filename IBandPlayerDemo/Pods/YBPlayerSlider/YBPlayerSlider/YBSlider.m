//
//  YBSlider.m
//  YBSlider
//
//  Created by Yogev Barber on 21/08/2017.
//  Copyright © 2017 Yogev Barber. All rights reserved.
//

#import "YBSlider.h"
#import "UIColor+HexString.h"

@interface YBSlider(){
//    float oldX, oldY;
    BOOL dragging;
}
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *markerView;
@property (nonatomic, strong) UIView *filledView;
@property (nonatomic, strong) UIView *bufferView;
@property (nonatomic, strong) UIView *markerWrapper;
@property (nonatomic, assign) float currentPosition;                                 // default 0.0. this value will be pinned to min/max
@property (nonatomic, assign) float currentBuffer;                                 // default 0.0. this value will be pinned to min/max
@end

@implementation YBSlider

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setupView];
    }
    return self;
}


-(void)setupView{
    CGRect backgroundFrame = CGRectMake(20, 20, self.bounds.size.width - 40, 10);
    self.backgroundView = [[UIView alloc] initWithFrame:backgroundFrame];
    [self insertSubview:self.backgroundView atIndex:0];
    self.backgroundView.layer.cornerRadius = 5.f;
    self.backgroundView.layer.masksToBounds = true;
    self.backgroundView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    self.backgroundView.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.backgroundView.layer.borderWidth = 0.5;
    
    CGFloat backgroundViewHeight = CGRectGetHeight(self.backgroundView.frame);
    
    CGRect markerWrapperFrame = CGRectMake(0 , 0, 50, 50);
    self.markerWrapper = [[UIView alloc] initWithFrame:markerWrapperFrame];
    [self insertSubview:self.markerWrapper atIndex:3];
    self.markerWrapper.backgroundColor = [UIColor clearColor];
    
    CGRect markerFrame = CGRectMake(20, 18, backgroundViewHeight + 4, backgroundViewHeight + 4);
    self.markerView = [[UIView alloc] initWithFrame:markerFrame];
    [self.markerWrapper addSubview:self.markerView];
    self.markerView.backgroundColor = [UIColor colorWithHexString:@"50E3C2"];
    self.markerView.layer.cornerRadius = 7.f;
    self.markerView.layer.masksToBounds = true;

    CGRect bufferViewFrame = CGRectMake(0, 0, 0, backgroundViewHeight);
    self.bufferView = [[UIView alloc] initWithFrame:bufferViewFrame];
    [self.backgroundView insertSubview:self.bufferView atIndex:1];
    self.bufferView.backgroundColor = [UIColor colorWithHexString:@"737373"];
    self.bufferView.layer.cornerRadius = backgroundViewHeight / 2;
    self.bufferView.layer.masksToBounds = true;
    
    CGRect filledViewFrame = CGRectMake(0, 0, 0, backgroundViewHeight);
    self.filledView = [[UIView alloc] initWithFrame:filledViewFrame];
    [self.backgroundView insertSubview:self.filledView atIndex:2];
    self.filledView.backgroundColor = [UIColor colorWithHexString:@"50E3C2"];
    
    self.currentPosition = 0;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    CGRect backgroundFrame = self.backgroundView.frame;
    backgroundFrame.size.width = self.bounds.size.width - 40;
    self.backgroundView.frame = backgroundFrame;
    
    [self updatePosition];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:self];
    
    if (CGRectContainsPoint(self.markerWrapper.frame, touchLocation)) {
        dragging = YES;
    }
    
    if (dragging && self.delegate && [self.delegate respondsToSelector:@selector(sliderDragBegin:value:)]) {
        [self.delegate sliderDragBegin:self value:self.currentPosition];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    double distX = [touch locationInView:self].x - [touch previousLocationInView:self].x;
    distX *= 0.9;
    
    if (dragging) {
        CGRect markerFrame = self.markerWrapper.frame;
        CGFloat newXPosition = markerFrame.origin.x + distX;
        if (newXPosition + CGRectGetHeight(self.backgroundView.frame) + 4 > CGRectGetWidth(self.backgroundView.frame)) {
            newXPosition = CGRectGetWidth(self.backgroundView.frame) - CGRectGetHeight(self.backgroundView.frame) - 4;
        }
        
        if (newXPosition < 0) {
            newXPosition = 0;
        }
        
        markerFrame.origin.x = newXPosition;
        self.markerWrapper.frame = markerFrame;
        
        
        CGRect filledViewFrame = self.filledView.frame;
        filledViewFrame.size.width = self.backgroundView.frame.size.width - (self.backgroundView.frame.size.width - newXPosition) + 4;
        self.filledView.frame = filledViewFrame;
        
        self.currentPosition = newXPosition / (self.backgroundView.frame.size.width - 14);
        if (self.delegate && [self.delegate respondsToSelector:@selector(sliderDragMove:value:)]) {
            [self.delegate sliderDragMove:self value:self.currentPosition];
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    dragging = NO;
    if (self.delegate && [self.delegate respondsToSelector:@selector(sliderDragEnd:value:)]) {
        [self.delegate sliderDragEnd:self value:self.currentPosition];
    }
}

-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    dragging = NO;
    if (self.delegate && [self.delegate respondsToSelector:@selector(sliderDragEnd:value:)]) {
        [self.delegate sliderDragEnd:self value:self.currentPosition];
    }
}

-(void)updatePosition{
    CGRect markerFrame = self.markerWrapper.bounds;
    markerFrame.origin.x = self.currentPosition * (self.backgroundView.bounds.size.width - 14);
    self.markerWrapper.frame = markerFrame;
    
    CGRect filledViewFrame = self.filledView.bounds;
    filledViewFrame.size.width = self.backgroundView.bounds.size.width - (self.backgroundView.bounds.size.width - markerFrame.origin.x) + 4;
    self.filledView.frame = filledViewFrame;
    
    CGRect bufferViewFrame = self.bufferView.bounds;
    bufferViewFrame.size.width = self.backgroundView.bounds.size.width * self.currentBuffer;
    self.bufferView.frame = bufferViewFrame;
}

#pragma mark - public
- (void)setCurrentPosition:(float)currentPosition{
    if (currentPosition > 0) {
        _currentPosition = currentPosition;
        [self updatePosition];
    }
}

-(void)setBufferPosition:(float)bufferPosition{
    if (bufferPosition > 0) {
        self.currentBuffer = bufferPosition;
        [self updatePosition];
    }
}


@end
