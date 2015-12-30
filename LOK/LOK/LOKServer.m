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
#import "LOKManager.h"
#import "UsageManager.h"
#import <RoutingHTTPServer.h>
#import <PocketSocket/PSWebSocketServer.h>

#define MAX_SOCKET_CONNECT_COUNT 5

@interface LOKServer ()<PSWebSocketServerDelegate>
@property (nonatomic, strong) RoutingHTTPServer *httpServer;
@property (nonatomic, strong) PSWebSocketServer *socketServer;
@property (nonatomic, strong) NSMutableArray *socketList;
@end

@implementation LOKServer

+ (instancetype)shareServer {
    static LOKServer *shareServer;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareServer = [[self alloc] init];
    });
    return shareServer;
}

#pragma mark - private method
- (void)serverStart {
    NSError *error;
    if([self.httpServer start:&error]) {
        NSLog(@"Started HTTP Server on port %hu", [self.httpServer listeningPort]);
        NSString *webPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"WebSite.bundle"];
        NSLog(@"Setting document root: %@", webPath);
        [self.httpServer setDocumentRoot:webPath];
        [self setupRouting];
        [self setupSocket];

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
    if (self.socketList.count < MAX_SOCKET_CONNECT_COUNT) {
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

- (void)setServerStart:(BOOL)isStart {
    [[NSUserDefaults standardUserDefaults] setBool:isStart forKey:@"LOKServerIsStart"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [NSURLProtocol registerClass:[LOKURLProtocol class]];
    [LOKManager defaultManager];
    [self serverStart];
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateUsage) userInfo:nil repeats:YES];
}

- (NSString *)serverId {
    if (!_serverId) {
        _serverId = [[self.class defaultDateFormatter] stringFromDate:[NSDate date]];
    }
    return _serverId;
}


+ (NSDateFormatter *)defaultDateFormatter {
    static NSDateFormatter *staticDateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        staticDateFormatter=[[NSDateFormatter alloc] init];
        [staticDateFormatter setDateFormat:@"yyyy-MM-dd/HH:mm:ss"];
    });
    return staticDateFormatter;
}


@end
