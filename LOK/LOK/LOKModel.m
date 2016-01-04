//
//  LOKModel.m
//  LOK
//
//  Created by Madao on 12/21/15.
//  Copyright © 2015 Madao. All rights reserved.
//

#import "LOKModel.h"

@interface LOKModel ()
@end

@implementation LOKModel
@synthesize lok_request,lok_response;

#pragma mark - JSON Keys & map for migration
- (instancetype)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
    }
    return self;
}

#pragma getters & setters

- (NSString *)messageString {
    if (!_messageString) {
        NSArray *keyList = @[@"_id",
                             @"connectId",
                             @"JSONString",
                             @"requestTimeoutInterval",
                             @"requestURLString",
                             @"requestCachePolicy",
                             @"requestHTTPMethod",
                             @"requestAllHTTPHeaderFields",
                             @"requestHTTPBody",
                             @"responseStatusCode",
                             @"responseDataSize",
                             @"responseMIMEType",
                             @"responseTextEncodingName",
                             @"responseSuggestedFilename",
                             @"responseAllHeaderFields",
                             @"responseExpectedContentLength"];
        NSMutableDictionary *dict = [@{} mutableCopy];
        for (NSString *key in keyList) {
            id value = [self valueForKey:key];
            if (!value) {
                dict[key] = @"";
            }
            if ([value isKindOfClass:[NSString class]]) {
                dict[key] = value;
            } else {
                dict[key] = [NSString stringWithFormat:@"%@",value];
            }
        }
        dict[@"time"] = @(self.endTime - self.startTime);
        
        NSDictionary *result = @{@"type":@"request",@"data":dict};
        NSData *jsonData     = [NSJSONSerialization dataWithJSONObject:result options:0 error:nil];
        _messageString       = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return _messageString;
}


- (void)setLok_response:(NSHTTPURLResponse *)lok_response_new {
    lok_response = lok_response_new;
    self.responseStatusCode            = (NSInteger)lok_response.statusCode;
    self.responseMIMEType              = [lok_response MIMEType];
    self.responseExpectedContentLength = [NSString stringWithFormat:@"%lld",[lok_response expectedContentLength]];
    self.responseTextEncodingName      = lok_response.textEncodingName ? lok_response.textEncodingName : @"" ;
    self.responseSuggestedFilename     = lok_response.suggestedFilename ? lok_response.suggestedFilename : @"" ;
    self.responseDataSize              = lok_response.expectedContentLength;
    for ( NSString *key in [lok_response.allHeaderFields allKeys] ) {
        NSString *headerFieldValue = [lok_response.allHeaderFields objectForKey:key];
        if ([key isEqualToString:@"Content-Security-Policy"]) {
            if ([[headerFieldValue substringFromIndex:12] isEqualToString:@"'none'"]) {
                headerFieldValue = [headerFieldValue substringToIndex:11];
            }
        }
        self.responseAllHeaderFields = [NSString stringWithFormat:@"%@%@:%@\n",self.responseAllHeaderFields,key,headerFieldValue];
    }
    
    if ( self.responseAllHeaderFields.length>1 ) {
        if ([[self.responseAllHeaderFields substringFromIndex:self.responseAllHeaderFields.length-1] isEqualToString:@"\n"]) {
            self.responseAllHeaderFields = [self.responseAllHeaderFields substringToIndex:self.responseAllHeaderFields.length-1];
        }
    }
}


- (void)setLok_request:(NSURLRequest *)lok_request_new {
    NSArray *cachePolicyList    = @[@"NSURLRequestUseProtocolCachePolicy",@"NSURLRequestReloadIgnoringLocalCacheData",@"NSURLRequestReturnCacheDataElseLoad",@"NSURLRequestReturnCacheDataDontLoad",@"NSURLRequestReloadIgnoringLocalAndRemoteCacheData",@"NSURLRequestReloadRevalidatingCacheData"];
    lok_request                 = lok_request_new;
    self.requestURLString       = [lok_request.URL absoluteString];
    self.requestCachePolicy     = cachePolicyList[lok_request.cachePolicy];
    self.requestTimeoutInterval = [[NSString stringWithFormat:@"%.1lf",lok_request.timeoutInterval] doubleValue];
    self.requestHTTPMethod      = lok_request.HTTPMethod;
    for (NSString *key in [lok_request.allHTTPHeaderFields allKeys]) {
        self.requestAllHTTPHeaderFields = [NSString stringWithFormat:@"%@%@:%@\n",self.requestAllHTTPHeaderFields,key,[lok_request.allHTTPHeaderFields objectForKey:key]];
    }
    if (self.requestAllHTTPHeaderFields.length>1) {
        if ([[self.requestAllHTTPHeaderFields substringFromIndex:self.requestAllHTTPHeaderFields.length-1] isEqualToString:@"\n"]) {
            self.requestAllHTTPHeaderFields = [self.requestAllHTTPHeaderFields substringToIndex:self.requestAllHTTPHeaderFields.length-1];
        }
    }
    if (self.requestAllHTTPHeaderFields.length>6) {
        if ([[self.requestAllHTTPHeaderFields substringToIndex:6] isEqualToString:@"(null)"]) {
            self.requestAllHTTPHeaderFields = [self.requestAllHTTPHeaderFields substringFromIndex:6];
        }
    }
    if ([lok_request HTTPBody].length>512) {
        self.requestHTTPBody = @"requestHTTPBody too long";
    }else{
        self.requestHTTPBody = [[NSString alloc] initWithData:[lok_request HTTPBody] encoding:NSUTF8StringEncoding];
    }
    if (self.requestHTTPBody.length>1) {
        if ([[self.requestHTTPBody substringFromIndex:self.requestHTTPBody.length-1] isEqualToString:@"\n"]) {
            self.requestHTTPBody=[self.requestHTTPBody substringToIndex:self.requestHTTPBody.length-1];
        }
    }
}
@end
