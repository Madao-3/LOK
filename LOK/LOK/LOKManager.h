//
//  LOKManager.h
//  LOK
//
//  Created by Madao on 12/21/15.
//  Copyright © 2015 Madao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LOKModel.h"

static NSString * const LOKSqlitePassword = @"LOKSqlitePassword";

@interface LOKManager : NSObject

+ (instancetype)defaultManager;
- (void)addLOKModel:(LOKModel *)model;
@end
