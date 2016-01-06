//
//  LOKURLProtocol.m
//  LOK
//
//  Created by Madao on 12/21/15.
//  Copyright © 2015 Madao. All rights reserved.
//

#import "LOKURLProtocol.h"
#import "LOKServer.h"
#import "LOKManager.h"
#import "LOKModel.h"

@interface LOKURLProtocol ()<NSURLConnectionDelegate, NSURLConnectionDataDelegate>
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSURLResponse *response;
@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, strong) LOKModel *model;

@end

@implementation LOKURLProtocol

#pragma mark - private method
- (void)addNewRequest {
    if (!self.response) {
        return;
    }
    self.model.endTime      = CFAbsoluteTimeGetCurrent();
    self.model.lok_response = (NSHTTPURLResponse *)self.response;
    NSString *mimeType      = self.response.MIMEType;
    self.model.JSONString   = @"";
    
    NSLog(@"%@ ===== \n %@ ===== \n %@",mimeType,self.request,self.response);
    if ([mimeType isEqualToString:@"application/json"]) {
        self.model.JSONString = [[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding];
    } else if ([mimeType isEqualToString:@"text/javascript"]) {
        NSString *jsonString = [[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding];
        jsonString = [NSString stringWithFormat:@"(%@);",jsonString];
        NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        self.model.JSONString = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                options:NSJSONReadingMutableContainers
                                                                  error:nil];
        
    } else if ([mimeType isEqualToString:@"text/html"]) {
        self.model.JSONString = [[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding];
    } else if ([mimeType isEqualToString:@"application/xml"] ||[mimeType isEqualToString:@"text/xml"]) {
        NSString *xmlString = [[NSString alloc]initWithData:self.data encoding:NSUTF8StringEncoding];
        if (xmlString && xmlString.length>0) {
            self.model.JSONString = xmlString;
        }
    }
    if (self.model.responseDataSize < 0) {
        if (self.data.length < 200) {
            return;
        }
        self.model.responseDataSize = self.data.length;
    }
    [[LOKServer shareServer] newRequestDidHandle:self.model];
}

- (void)waitingForReplay {
    __weak __typeof__(self) weakSelf = self;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([LOKServer shareServer].socketList.count == 0 || ![LOKServer shareServer].debugMode) {
            return ;
        }
        if ([LOKServer shareServer].updateData) {
            [[weakSelf client] URLProtocol:self didLoadData:[LOKServer shareServer].updateData];
            [self.connection cancel];
            [LOKServer shareServer].updateData = nil;
            return;
        }
        [weakSelf waitingForReplay];
    });
}


#pragma mark - NSURLProtocol Public Method
+ (void)load {
    
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    if (![request.URL.scheme isEqualToString:@"http"] &&
        ![request.URL.scheme isEqualToString:@"https"]) {
        return NO;
    }
    if ([NSURLProtocol propertyForKey:@"LOK" inRequest:request] ||
        [request.URL.absoluteString containsString:[NSString stringWithFormat:@":%@",[LOKServer shareServer].listeningPort]]) {
        return NO;
    }
    
    return YES;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    NSMutableURLRequest *mutableReqeust = [request mutableCopy];
    [NSURLProtocol setProperty:@YES
                        forKey:@"LOK"
                     inRequest:mutableReqeust];
    return [mutableReqeust copy];
}


- (void)startLoading {
    self.data            = [NSMutableData data];
    self.model           = [[LOKModel alloc] init];
    self.model.startTime = CFAbsoluteTimeGetCurrent();
    self.model.connectId = [LOKServer shareServer].serverId;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    self.connection = [[NSURLConnection alloc] initWithRequest:[[self class] canonicalRequestForRequest:self.request] delegate:self startImmediately:YES];
#pragma clang diagnostic pop
    self.model.lok_request = self.request;
}

- (void)stopLoading {
    [self addNewRequest];
    [self.connection cancel];
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error {
    [[self client] URLProtocol:self didFailWithError:error];
}

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection {
    return YES;
}

- (void)connection:(NSURLConnection *)connection
didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    [[self client] URLProtocol:self didReceiveAuthenticationChallenge:challenge];
}

- (void)connection:(NSURLConnection *)connection
didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    [[self client] URLProtocol:self didCancelAuthenticationChallenge:challenge];
}

#pragma mark - NSURLConnectionDataDelegate
- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response {
    if (response != nil){
        [[self client] URLProtocol:self wasRedirectedToRequest:request redirectResponse:response];
    }
    return request;
}

- (void)connection:(NSURLConnection *)connection
didReceiveResponse:(NSURLResponse *)response {
    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
    self.response = response;
}

- (void)connection:(NSURLConnection *)connection
    didReceiveData:(NSData *)data {
    data = [data copy];
    [[self client] URLProtocol:self didLoadData:data];
    [self.data appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return cachedResponse;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [[self client] URLProtocolDidFinishLoading:self];
}

#pragma mark - getters & setters
- (NSDictionary *)submitParams:(NSDictionary *)dict{
    NSMutableDictionary *data = [@{
                                   @"connectId" : [LOKServer shareServer].serverId
                                   } mutableCopy];
    if (dict) {
        [data addEntriesFromDictionary:dict];
    }
    return data;
}
@end
