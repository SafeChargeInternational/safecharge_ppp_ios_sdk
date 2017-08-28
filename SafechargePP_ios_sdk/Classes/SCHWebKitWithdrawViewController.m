//
//  SCHWebKitWithdrawViewController.m
//  SafechargePP
//
//  Created by Miroslav Chernev on 2/10/17.
//  Copyright © 2017 SafeCharge. All rights reserved.
//

#import "SCHWebKitWithdrawViewController.h"
#import "SCHWithdrawRequestBuilder.h"
#import "SCHConfiguration.h"
#import "SCHLogging.h"
#import <WebKit/WebKit.h>

@interface SCHWebKitWithdrawViewController ()

@property (nonatomic,strong) WKWebView *webView;
@property (nonatomic,strong) SCHWithdrawRequestBuilder *schRequestBuilder;
@end

@implementation SCHWebKitWithdrawViewController

- (instancetype) initWithSCHRequestBuilder:(SCHWithdrawRequestBuilder *) schRequest {
    self = [super init] ;
    if ( self ) {
        _schRequestBuilder = schRequest;
    }
    
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc]
                                             init];
    _webView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:configuration];
    _webView.backgroundColor = [UIColor whiteColor];
    self.view = _webView;
    
    //adjust
    _webView.scrollView.scrollEnabled = [SCHConfiguration configurationInstance].enableWebViewScroll.boolValue;

}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self loadRemote];
}
    
-(void) loadRemote {
    NSURLRequest *request = [_schRequestBuilder constructURLRequest];
    if ( request == nil ) {
        SCHLog(@"nil request constructed");
        SCHAssert(false);
        return;
    }
    [_webView loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - WKNavigationDelegate Protocol

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    if (self.delegate)
        [self.delegate withdrawalPageController:self didFailLoadWithdrawalPageWithError:error];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    if (self.delegate)
        [self.delegate withdrawalPageController:self didFailLoadWithdrawalPageWithError:error];
}



@end
