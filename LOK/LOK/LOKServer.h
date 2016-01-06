//
//  LOKServer.h
//  LOK
//
//  Created by Madao on 12/21/15.
//  Copyright © 2015 Madao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LOKModel.h"

@interface LOKServer : NSObject

@property (nonatomic, copy) NSString *serverId;
@property (nonatomic, copy) NSString *listeningPort;

@property (nonatomic, assign) NSInteger maxConnectCount;
@property (nonatomic, assign) id updateData;
@property (nonatomic, assign) BOOL debugMode;
@property (nonatomic, strong) NSMutableArray *socketList;

- (void)setServerStart:(BOOL)isStart;
+ (instancetype)shareServer;
- (void)newRequestDidHandle:(LOKModel *)model;
@end
