//
//  qualityCell.m
//  IBand.live
//
//  Created by Yogev Barber on 22/08/2017.
//  Copyright © 2017 Yogev Barber. All rights reserved.
//

#import "QualityCell.h"
#import "UIColor+Hex.h"

@interface QualityCell()
@property (weak, nonatomic) IBOutlet UIView *activeQualityIndecator;
@property (weak, nonatomic) IBOutlet UILabel *lblQuality;
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, strong) id<IBandPlayerVariant> variant;
@property (weak, nonatomic) IBOutlet UIButton *buttonOverlay;
- (IBAction)setSelectedQuality:(UIButton *)sender;
@end

@implementation QualityCell

-(void)layoutSubviews{
    [super layoutSubviews];
    self.activeQualityIndecator.layer.cornerRadius = 3.f;
    self.activeQualityIndecator.layer.masksToBounds = true;
}

-(id<IBandPlayerVariant>)getVariant{
    return self.variant;
}

-(void)setVariant:(id<IBandPlayerVariant>)variant{
    _variant = variant;
    if (variant) {
        self.lblQuality.text = [NSString stringWithFormat:@"%dp", (int)[variant getHeight]];
    }else{
        self.lblQuality.text = @"Auto";
    }
    
}

-(void)setSelected:(BOOL)selected{
    
    _selected = selected;
    
    if (selected) {
        self.activeQualityIndecator.backgroundColor = [UIColor colorFromHexCode:@"50E3C2"];
        self.lblQuality.textColor = [UIColor colorFromHexCode:@"50E3C2"];
    }else{
        self.activeQualityIndecator.backgroundColor = [UIColor clearColor];
        self.lblQuality.textColor = [UIColor whiteColor];
    }
}

-(void)setActive:(BOOL)active{
    if (active) {
        self.activeQualityIndecator.backgroundColor = [UIColor colorFromHexCode:@"50E3C2"];
    }else{
        self.activeQualityIndecator.backgroundColor = [UIColor clearColor];
    }
}

-(BOOL)getSelected{
    return self.selected;
}

- (IBAction)setSelectedQuality:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(qualitySelected:variant:)]) {
        [self.delegate qualitySelected:self variant:self.variant];
        [self setSelected:true];
    }
}
@end
