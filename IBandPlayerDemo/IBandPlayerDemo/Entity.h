//
//  Entitie.h
//  IBand.live
//
//  Created by Yogev Barber on 16/08/2017.
//  Copyright © 2017 Yogev Barber. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Entity : NSObject
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *subTitle;
@property (nonatomic, strong) NSString *artwork;
@property (nonatomic, strong) NSArray<NSString*> *streams;
+(Entity*)parseEntity:(id)unparsedEntity;
@end
