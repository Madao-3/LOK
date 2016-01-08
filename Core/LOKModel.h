//
//  LOKModel.h
//  LOK
//
//  Created by Madao on 12/21/15.
//  Copyright © 2015 Madao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LOKModel : NSObject

@property (nonatomic,strong) NSURLRequest *lok_request;
@property (nonatomic,strong) NSHTTPURLResponse *lok_response;
@property (nonatomic, assign) NSInteger _id;
@property (nonatomic, copy) NSString *connectId;
@property (nonatomic, copy) NSString *JSONString;
@property (nonatomic, assign) double requestInterval;
@property (nonatomic, assign) CFAbsoluteTime startTime;
@property (nonatomic, assign) CFAbsoluteTime endTime;

@property (nonatomic, assign) double requestTimeoutInterval;
@property (nonatomic, copy) NSString *requestURLString;
@property (nonatomic, copy) NSString *requestCachePolicy;
@property (nonatomic, copy) NSString *requestHTTPMethod;
@property (nonatomic, copy) NSString *requestAllHTTPHeaderFields;
@property (nonatomic, copy) NSString *requestHTTPBody;

@property (nonatomic, assign) NSInteger responseStatusCode;
@property (nonatomic, assign) double responseDataSize;
@property (nonatomic, copy) NSString *responseMIMEType;
@property (nonatomic, copy) NSString *responseTextEncodingName;
@property (nonatomic, copy) NSString *responseSuggestedFilename;
@property (nonatomic, copy) NSString *responseAllHeaderFields;
@property (nonatomic, assign) NSString *responseExpectedContentLength;


@property (nonatomic, copy) NSNumber *datetime;

@property (nonatomic, copy) NSString *messageString;
@end
