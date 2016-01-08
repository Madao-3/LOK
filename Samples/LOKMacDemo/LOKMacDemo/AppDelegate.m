//
//  AppDelegate.m
//  LOKMacDemo
//
//  Created by Madao on 1/8/16.
//  Copyright © 2016 LOK. All rights reserved.
//

#import "AppDelegate.h"
#import "LOKServer.h"
@import WebKit;

@interface AppDelegate ()
@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTextField *urlInput;
@property (weak) IBOutlet WebView *webview;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [[LOKServer shareServer] setServerStart:YES];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (IBAction)GO:(id)sender {
    NSString *urlString = [self.urlInput stringValue];
    NSURL *url          = [NSURL URLWithString:urlString];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    [[self.webview mainFrame] loadRequest:request];
}

@end
