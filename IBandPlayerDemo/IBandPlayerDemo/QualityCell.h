//
//  qualityCell.h
//  IBand.live
//
//  Created by Yogev Barber on 22/08/2017.
//  Copyright © 2017 Yogev Barber. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <IBandPlayerSDK/IBandPlayerSDK.h>

@class QualityCell;

@protocol QualityCellDelegate <NSObject>
-(void)qualitySelected:(QualityCell*)quality variant:(id<IBandPlayerVariant>)variant;
@end

@interface QualityCell : UIView
@property (nonatomic, weak) id<QualityCellDelegate> delegate;
-(id<IBandPlayerVariant>)getVariant;
-(void)setVariant:(id<IBandPlayerVariant>)variant;
-(BOOL)getSelected;
-(void)setSelected:(BOOL)selected;
-(void)setActive:(BOOL)active;
@end
