//
//  LOKManager.m
//  LOK
//
//  Created by Madao on 12/21/15.
//  Copyright © 2015 Madao. All rights reserved.
//

#import "LOKManager.h"

@interface LOKManager ()
@property (nonatomic, assign) NSInteger maxCount;
@end

@implementation LOKManager

+ (instancetype)defaultManager {
    static LOKManager *defaultManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultManager = [[self alloc] init];
    });
    return defaultManager;
}


- (void)addLOKModel:(LOKModel *)model {
    
}

- (NSString *)dbPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSString *dbPath = [documentDirectory stringByAppendingPathComponent:@""];
    dbPath = [dbPath stringByAppendingString:@"/_LOKManagerData.db"];
    NSLog(@"dbPath is : %@",dbPath);
    return dbPath;
}

#pragma mark - private method
- (BOOL)IsEmpty:(id)thing {
    return !thing
    || ([thing respondsToSelector:@selector(length)]
        && [(NSData *)thing length] == 0)
    || ([thing respondsToSelector:@selector(count)]
        && [(NSArray *)thing count] == 0)
    || ([thing isKindOfClass:[NSNull class]]);
}

- (NSArray *)getValueArray:(NSDictionary *)storeDict {
    NSMutableArray *valueArray = [@[] mutableCopy];
    for(NSString *key in storeDict){
        NSString *value = storeDict[key];
        if (![self IsEmpty:value] && [value isKindOfClass:[NSString class]]) {
            value = [value stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        }
        [valueArray addObject:[NSString stringWithFormat:@"%@",value]];
    }
    return [valueArray copy];
}

@end
