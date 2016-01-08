//
//  LOKServer.m
//  LOK
//
//  Created by Madao on 12/21/15.
//  Copyright © 2015 Madao. All rights reserved.
//

#import "LOKServer.h"
#import "LOKURLSessionConfiguration.h"
#import "LOKURLProtocol.h"
#import "UsageManager.h"
#import <RoutingHTTPServer.h>
#import <PocketSocket/PSWebSocketServer.h>
#include <ifaddrs.h>
#include <arpa/inet.h>
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
@import AppKit;
#endif



#define MAX_SOCKET_CONNECT_COUNT 5

@interface LOKServer ()<PSWebSocketServerDelegate>
@property (nonatomic, strong) RoutingHTTPServer *httpServer;
@property (nonatomic, strong) PSWebSocketServer *socketServer;
@property (nonatomic, strong) NSTimer *usageTimer;
@end

@implementation LOKServer

+ (instancetype)shareServer {
    static LOKServer *shareServer;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareServer = [[self alloc] init];
        shareServer.debugMode = YES;
        shareServer.updateData = nil;
    });
    return shareServer;
}

#pragma mark - private method

- (void)setServerStart:(BOOL)isStart {
    [[NSUserDefaults standardUserDefaults] setBool:isStart forKey:@"LOKServerIsStart"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    if (!isStart) {
        [NSURLProtocol unregisterClass:[LOKURLProtocol class]];
        if (self.usageTimer) {
            [self.usageTimer invalidate];
            self.usageTimer = nil;
        }
        return;
    }
    [NSURLProtocol registerClass:[LOKURLProtocol class]];
    [self serverStart];
    self.usageTimer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(updateUsage) userInfo:nil repeats:YES];
}

- (void)setServerStartWithPort:(NSInteger)port {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"LOKServerIsStart"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [NSURLProtocol registerClass:[LOKURLProtocol class]];
    [self serverStartWithPort:port];
    [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(updateUsage) userInfo:nil repeats:YES];

}

- (void)serverStartWithPort:(NSInteger)port {
    [self serverStart];
}

- (void)serverStart {
    NSError *error;
    if([self.httpServer start:&error]) {
        NSLog(@"Started HTTP Server on port %hu", [self.httpServer listeningPort]);
        NSString *webPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"WebSite.bundle"];
        NSLog(@"Setting document root: %@", webPath);
        [self.httpServer setDocumentRoot:webPath];
        [self setupRouting];
        [self setupSocket];
        NSString *urlString = [NSString stringWithFormat:@"http://%@:%hu",self.getIPAddress,[self.httpServer listeningPort]];

        #if TARGET_OS_IPHONE
        UIPasteboard *pb = [UIPasteboard generalPasteboard];
        [pb setString:urlString];
        #else
        NSPasteboard *pb = [NSPasteboard generalPasteboard];
        [pb setString:urlString forType:NSPasteboardTypeString];
        #endif

        NSLog(@"url did paste:%@",urlString);
    } else {
        NSLog(@"Error starting HTTP Server: %@", error);
    }
}

- (void)setupSocket {
    [self.socketServer start];
}

- (void)setupRouting {
    [self.httpServer handleMethod:@"GET" withPath:@"/hello" block:^(RouteRequest *request, RouteResponse *response) {
        [response setHeader:@"Content-Type" value:@"application/json"];
        NSError * err;
        NSData * jsonData = [NSJSONSerialization dataWithJSONObject:@{@"hello":@"world"} options:0 error:&err];
        NSString * myString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        [response respondWithString:myString];
    }];
}

- (void)updateUsage {
    if (self.socketList.count > 0) {
        NSString *jsonString = [UsageManager getUsageJSONString];
        for (PSWebSocket *socket in self.socketList) {
            [socket send:jsonString];
        }
    }
}

- (void)newRequestDidHandle:(LOKModel *)model {
    if (self.socketList.count > 0) {
        model.datetime = @([[NSDate date] timeIntervalSince1970]);
        NSString *jsonString = model.messageString;
        for (PSWebSocket *socket in self.socketList) {
            [socket send:jsonString];
        }
    }
}

#pragma mark - PSWebSocketServerDelegate

- (void)serverDidStart:(PSWebSocketServer *)server {
}
- (void)serverDidStop:(PSWebSocketServer *)server {
}
- (BOOL)server:(PSWebSocketServer *)server acceptWebSocketWithRequest:(NSURLRequest *)request {
    return YES;
}

- (void)server:(PSWebSocketServer *)server webSocket:(PSWebSocket *)webSocket didReceiveMessage:(id)message {
    if ([self.socketList containsObject:webSocket]) {
        NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
        if (data) {
            [LOKServer shareServer].updateData = data;
        }
        return;
    }
    if (self.socketList.count < MAX_SOCKET_CONNECT_COUNT) {
        NSString *name = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
        if (!name) {
            name = @"";
        }
        NSError * err;
        NSData * jsonData = [NSJSONSerialization dataWithJSONObject:@{@"type":@"base_info",@"name":name,@"start_time":self.serverId,@"memory_size":@([NSProcessInfo processInfo].physicalMemory)}
                                                            options:0 error:&err];
        NSString * jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        [webSocket send:jsonString];
        [self.socketList addObject:webSocket];
    }

}
- (void)server:(PSWebSocketServer *)server webSocketDidOpen:(PSWebSocket *)webSocket {
    
}
- (void)server:(PSWebSocketServer *)server webSocket:(PSWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    [self.socketList removeObject:webSocket];
    NSLog(@"Server websocket did close with code: %@, reason: %@, wasClean: %@", @(code), reason, @(wasClean));
}
- (void)server:(PSWebSocketServer *)server webSocket:(PSWebSocket *)webSocket didFailWithError:(NSError *)error {
    [self.socketList removeObject:webSocket];
    [LOKServer shareServer].debugMode = NO;
    
    NSLog(@"Server websocket did fail with error: %@", error);
}


#pragma mark - getters & setters
- (NSString *)listeningPort {
    if (!_listeningPort) {
        _listeningPort = [NSString stringWithFormat:@":%hu",self.httpServer.listeningPort];
    }
    return _listeningPort;
}

- (PSWebSocketServer *)socketServer {
    if (!_socketServer) {
        _socketServer          = [PSWebSocketServer serverWithHost:nil port:self.httpServer.listeningPort+1];
        _socketServer.delegate = self;
    }
    return _socketServer;
}

- (RoutingHTTPServer *)httpServer {
    if (!_httpServer) {
        _httpServer = [[RoutingHTTPServer alloc] init];
        _httpServer.port = 12355;
    }
    return _httpServer;
}

- (NSMutableArray *)socketList {
    if (!_socketList) {
        _socketList = [@[] mutableCopy];
    }
    return _socketList;
}

- (NSString *)serverId {
    if (!_serverId) {
        _serverId = [NSString stringWithFormat:@"%@",@([[NSDate date] timeIntervalSince1970])];
    }
    return _serverId;
}


+ (NSDateFormatter *)defaultDateFormatter {
    static NSDateFormatter *staticDateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        staticDateFormatter=[[NSDateFormatter alloc] init];
        [staticDateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZ"];
    });
    return staticDateFormatter;
}

- (NSString *)getIPAddress {
    
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    
                }
                
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
    
}
@end
