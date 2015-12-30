//
//  demoViewController.m
//  LOK
//
//  Created by Madao on 12/30/15.
//  Copyright © 2015 Madao. All rights reserved.
//

#import "demoViewController.h"
#import "LOKServer.h"

@interface demoViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webview;
@property (weak, nonatomic) IBOutlet UITextField *urlString;

@end

@implementation demoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[LOKServer shareServer] setServerStart:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - event response
- (IBAction)gotoNewPage:(id)sender {
    NSURL *url = [NSURL URLWithString:self.urlString.text];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    [self.webview loadRequest:request];
}

@end
