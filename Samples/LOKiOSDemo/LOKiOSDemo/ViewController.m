//
//  ViewController.m
//  LOKiOSDemo
//
//  Created by Madao on 1/8/16.
//  Copyright © 2016 LOK. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *input;
@property (weak, nonatomic) IBOutlet UIWebView *webview;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)GO:(id)sender {
    [self.webview loadRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:self.input.text]]];
}

@end
