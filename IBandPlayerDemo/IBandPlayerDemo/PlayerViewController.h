//
//  ViewController.h
//  IBand.live
//
//  Created by Yogev Barber on 15/08/2017.
//  Copyright © 2017 Yogev Barber. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Entity;

@interface PlayerViewController : UIViewController

- (instancetype)initWithEntity:(Entity*)entity;
@end

