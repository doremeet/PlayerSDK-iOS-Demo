//
//  YBSlider.h
//  YBSlider
//
//  Created by Yogev Barber on 21/08/2017.
//  Copyright © 2017 Yogev Barber. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YBSlider;

@protocol YBSliderDelegate <NSObject>

-(void)sliderDragBegin:(YBSlider*)slider value:(float)value;
-(void)sliderDragMove:(YBSlider*)slider value:(float)value;
-(void)sliderDragEnd:(YBSlider*)slider value:(float)value;

@end

@interface YBSlider : UIView
@property (nonatomic, weak) id<YBSliderDelegate> delegate;

- (void)setCurrentPosition:(float)currentPosition; // move slider at fixed velocity (i.e. duration depends on distance). does not send action
-(void)setBufferPosition:(float)bufferPosition; // move buffer at fixed velocity (i.e. duration depends on distance). does not send action
@end
