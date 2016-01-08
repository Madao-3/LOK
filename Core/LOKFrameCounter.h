//
//  LOKFrameCounter.h
//  LOK
//
//  Created by Madao on 12/30/15.
//  Copyright © 2015 Madao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LOKFrameCounter : NSObject


+ (instancetype)shareCounter;
- (NSInteger)fps;
@end
