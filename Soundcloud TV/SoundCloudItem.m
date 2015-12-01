//
//  SoundCloudItem.m
//  SoundcloudPlayer
//
//  Created by Philip Brechler on 14.01.15.
//  Copyright (c) 2015 Call a Nerd. All rights reserved.
//

#import "SoundCloudItem.h"
#import "SoundCloudUser.h"
#import "SoundCloudTrack.h"
#import "SoundCloudPlaylist.h"

@implementation SoundCloudItem

- (instancetype)initWithCollectionDict:(NSDictionary *)dict {
    self = [super init];
    if (self){
        self.createdAt = [NSDate date];
        self.type = SoundCloudItemTypeUnknown;
        NSString *typeString = [dict objectForKey:@"type"];
        NSString *kindString = [dict objectForKey:@"kind"];
        self.user = [SoundCloudUser userForDict:[dict objectForKey:@"user"]];

        if (kindString && [kindString isEqualToString:@"track"] && [dict isKindOfClass:[NSDictionary class]]){
            self.type = SoundCloudItemTypeTrack;
            self.item = [SoundCloudTrack trackForDict:dict withPlaylist:nil repostedBy:nil];
//            if ([dict objectForKey:@"track"] && [[dict objectForKey:@"track"] isKindOfClass:[NSDictionary class]]){
//                self.type = SoundCloudItemTypeTrack;
//                self.item = [SoundCloudTrack trackForDict:[dict objectForKey:@"origin"] withPlaylist:nil repostedBy:nil];
//            } else if ([dict objectForKey:@"playlist"] && [[dict objectForKey:@"playlist"] isKindOfClass:[NSDictionary class]]){
//                self.type = SoundCloudItemTypePlaylist;
//                self.item = [SoundCloudPlaylist playlistForDict:[dict objectForKey:@"playlist"] repostedBy:nil];
//            }
        } else {
            if ([typeString isEqualToString:@"track"] && [[dict objectForKey:@"origin"] isKindOfClass:[NSDictionary class]]) {
                self.type = SoundCloudItemTypeTrack;
                self.item = [SoundCloudTrack trackForDict:[dict objectForKey:@"origin"] withPlaylist:nil repostedBy:nil];
            } else if ([typeString isEqualToString:@"track-repost"] && [[dict objectForKey:@"origin"] isKindOfClass:[NSDictionary class]]) {
                self.type = SoundCloudItemTypeTrackRepost;
                self.item = [SoundCloudTrack trackForDict:[dict objectForKey:@"origin"] withPlaylist:nil repostedBy:self.user];
            } else if ([typeString isEqualToString:@"playlist"]){
                // TODO: playlist object does not exist
                self.type = SoundCloudItemTypePlaylist;
                self.item = [SoundCloudPlaylist playlistForDict:[dict objectForKey:@"origin"] repostedBy:nil];
            } else if ([typeString isEqualToString:@"playlist-repost"]) {
                self.type = SoundCloudItemTypePlaylistRepost;
                self.item = [SoundCloudPlaylist playlistForDict:[dict objectForKey:@"origin"] repostedBy:self.user];
            }
            self.uuid = [dict objectForKey:@"uuid"];
        }
    }
    return self;
}

+ (NSArray *)soundCloudItemsFromResponse:(id)response {
    if ([response isKindOfClass:[NSDictionary class]]){
        NSMutableArray *arrayToReturn = [NSMutableArray array];
        NSArray *collectionArray = [response objectForKey:@"collection"];
        if (collectionArray && [collectionArray isKindOfClass:[NSArray class]]) {
            for (NSDictionary *collectionItem in collectionArray){
                SoundCloudItem *itemFromCollectionItem = [[SoundCloudItem alloc]initWithCollectionDict:collectionItem];
                if ([[response objectForKey:@"next_href"] isKindOfClass:[NSString class]])
                    itemFromCollectionItem.nextHref = [NSURL URLWithString:[response objectForKey:@"next_href"]];
                [arrayToReturn addObject:itemFromCollectionItem];
            }
        }
        return [NSArray arrayWithArray:arrayToReturn];
    } else {
        return nil;
    }
}
@end
