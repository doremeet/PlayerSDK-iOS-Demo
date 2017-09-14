//
//  Entitie.m
//  IBand.live
//
//  Created by Yogev Barber on 16/08/2017.
//  Copyright © 2017 Yogev Barber. All rights reserved.
//

#import "Entity.h"

@implementation Entity

+(Entity *)parseEntity:(id)unparsedEntity{
    Entity *entity = [[Entity alloc] init];
    entity.title = unparsedEntity[@"title"];
    entity.subTitle = unparsedEntity[@"subtitle"];
    entity.artwork = unparsedEntity[@"artwork"];
    entity.streams = [self parseStreamsArray:unparsedEntity[@"streams"]];
    return entity;
}

+(NSArray<NSString*>*)parseStreamsArray:(NSArray*)unparsedStreams{
    NSMutableArray<NSString*> * streams = [[NSMutableArray alloc] init];
    for (id stream in unparsedStreams) {
        NSString *streamId = stream[@"id"];
        [streams addObject:streamId];
    }
    return streams;
}

@end
