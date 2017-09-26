//
//  UIColor+Hex.h
//  IBand.live
//
//  Created by Yogev Barber on 17/08/2017.
//  Copyright © 2017 Yogev Barber. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Hex)
+ (UIColor *) colorFromHexCode:(NSString *)hexString;
@end
