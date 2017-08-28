//
//  SCHBasePaymentWebView.m
//  SafechargePP
//
//  Created by Miroslav Chernev on 4/27/17.
//  Copyright © 2017 SafeCharge. All rights reserved.
//

#import "SCHBasePaymentWebView.h"
#import <WebKit/WebKit.h>
#import "SCHConstants.h"
#import "SCHLogging.h"
#import "SCHJsFunction.h"


@interface SCHBasePaymentWebView () <WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler,SCHJsFunctionDelegate>
{
    SCHJsFunction   *overrideWebviewClose;
    SCHJsFunction   *overrideWebviewPopup;
    SCHJsFunction   *versionJSHandler;
    SCHJsFunction   *webviewSetPopupClosed;
    SCHJsFunction   *apmCloseOverrideHandler;
}

@property (strong,nonatomic) NSMutableArray<WKWebView*> *webViewStack;
@property (strong,nonatomic) NSURLRequest               *boundRequest;
@property (assign,nonatomic) BOOL                        rootWebViewLoadedCalled;

@end

@implementation SCHBasePaymentWebView


-(id) initWithRequest:(NSURLRequest*) request {
    self = [super init];
    if ( self ) {
        [self loadFromUrlRequest: request ];
    }
    return self;
}

-(void) loadFromUrlRequest:(NSURLRequest*) request {
    self.boundRequest = request;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.webViewStack = [[NSMutableArray alloc] initWithCapacity:4];
    
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc]
                                             init];
    
    WKUserContentController *controller = [[WKUserContentController alloc]
                                           init];
    
    [controller addScriptMessageHandler:self name:SCHAppleEventName];
    configuration.userContentController = controller;

    
    WKWebView *rootWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
                                                configuration:configuration];
    
    [rootWebView setNavigationDelegate:self];
    [rootWebView setUIDelegate:self];
    
    [self.webViewStack addObject:rootWebView];
    [self.view addSubview:rootWebView];
}

-(void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ( !self.rootWebViewLoadedCalled ) {
         [self.webViewStack.firstObject loadRequest:self.boundRequest];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//ignore use older for base payment view
-(NSString*) getVersionBasedOnAppleSupport {
    return SCHSDKVersion;
}


/////////////////////////////////////////////////////////////////////////////////////////////////////////
//SCHJsFunctionDelegate
/////////////////////////////////////////////////////////////////////////////////////////////////////////

-(void) onFunctionCallSuccessfull:(SCHJsFunction * _Nonnull) caller
                       withResult:(id _Nullable) result
                           caller:(NSString* _Nullable) callerName {
    
}

-(void) onFunctionCallError:(SCHJsFunction * _Nonnull) caller
                  withError:(NSError* _Nullable) error {
    SCHLog(@"invalid js result %@",error.description);
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//WKScriptMessageHandler
/////////////////////////////////////////////////////////////////////////////////////////////////////////


-(void) registerHandlers : (WKWebView *) webView{
   // if(versionJSHandler == nil ) {
        versionJSHandler = [[SCHJsFunction alloc] init];
        [versionJSHandler setDelegate:self];
        [versionJSHandler executeFunction:[self getVersionBasedOnAppleSupport] inWebView:webView];
   // }
   // if ( overrideWebviewPopup == nil ) {
        overrideWebviewPopup = [[SCHJsFunction alloc] init];
        [overrideWebviewPopup setDelegate:self];
        [overrideWebviewPopup executeFunction:SCHOverrideWindowOpenJSForWK inWebView:webView];
   // }
    //if ( overrideWebviewClose == nil ) {
        overrideWebviewClose = [[SCHJsFunction alloc] init];
        [overrideWebviewClose setDelegate:self];
        [overrideWebviewClose executeFunction:SCHOverrideWindowCloseJS inWebView:webView];
   // }
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//WKScriptMessageHandler
/////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)userContentController:(WKUserContentController *)userContentController
      didReceiveScriptMessage:(WKScriptMessage *)message {
    
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//WKNavigationDelegate
/////////////////////////////////////////////////////////////////////////////////////////////////////////

/// stack helpers
-(BOOL) isPopupPushed {
    return self.webViewStack.count > 1;
}

-(BOOL) isRootWebView:(WKWebView*) webview {
    return ( [self.webViewStack indexOfObject:webview] == 0 );
}


- (void) webView:(WKWebView *)webView
decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
 decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    NSURLRequest *request   = navigationAction.request;
    WKNavigationActionPolicy decision = WKNavigationActionPolicyAllow;
    
    [self registerHandlers:webView];
    
#ifdef DEBUG
    SCHLog(@"webview requesting : %@ ", request.URL.absoluteString);
#endif
    
    if ( [self isRootWebView:webView] )
    {
        if ([request.URL.absoluteString rangeOfString:SCHReviewPagePath].location != NSNotFound && [self isPopupPushed] ) {
            
        }
        else // continue
        {
            decision = WKNavigationActionPolicyAllow;
        }
    }
    else {
        if ( [request.URL.absoluteString isEqualToString:SCHCloseWindowURL] )
        {
            [self closeCurrentWebView];
            decision = WKNavigationActionPolicyCancel;
        } /*else if ( [request.URL.absoluteString rangeOfString:SCHAPMResponsePagePath].location != NSNotFound ) {
            
            [webView evaluateJavaScript:@"window.close()" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
                
            }]; */
        //}
        
    }
    
    decisionHandler(decision);
}


- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation
{
    if ([self isRootWebView:webView] == false && [webView.URL.absoluteString rangeOfString:SCHAPMResponsePagePath].location != NSNotFound)
    {
        
        [self closeCurrentWebView];
    }
}


- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
/*     if ( [self isRootWebView:webView]) {
         [webView evaluateJavaScript:SCHOverrideWindowOpenJSForWK completionHandler:nil];
         
     }  else {
         apmCloseOverrideHandler = [[SCHJsFunction alloc] init];
         [apmCloseOverrideHandler setDelegate:self];
         [apmCloseOverrideHandler executeFunction:SCHOverrideWindowCloseJS inWebView:webView];
    } */

}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
}


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//WKUI delegate
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message
initiatedByFrame:(WKFrameInfo *)frame
completionHandler:(void (^)(void))completionHandler
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *action) {
                                                          completionHandler();
                                                      }]];
    [self presentViewController:alertController animated:YES completion:^{}];
}



/////////////////////////////////////////////////////////////////////////////////////////////////////////
//APM Webview show/hide logic
/////////////////////////////////////////////////////////////////////////////////////////////////////////

- (WKWebView*) createAndPushWebView:(WKWebView*) parentWebView withConfiguration:(WKWebViewConfiguration*) configuration {
    CGRect frame = CGRectMake(0.0f, 0.0f, parentWebView.bounds.size.width, parentWebView.bounds.size.height);
    
    WKWebView *webview = [[WKWebView alloc] initWithFrame:frame configuration:configuration];
    [self.view addSubview:webview];
    [self.webViewStack addObject:webview];

    return webview;
}

- (WKWebView*) popWebView {
    //SCHAssert(self.webViewStack.count < 1);
    WKWebView *lastObj = self.webViewStack.lastObject;
    [self.webViewStack removeLastObject];
    return lastObj;
}

- (WKWebView *)             webView:(WKWebView *)webView
     createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration
                forNavigationAction:(WKNavigationAction *)navigationAction
                     windowFeatures:(WKWindowFeatures *)windowFeatures
{
    WKWebView *newWebView = [self createAndPushWebView:webView withConfiguration:configuration];
    
    newWebView.scrollView.contentInset = webView.scrollView.contentInset;
    newWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    newWebView.navigationDelegate = self;
    newWebView.UIDelegate = self;
    
    [self.view addSubview:newWebView];
    
    [overrideWebviewPopup executeFunction:SCHOverrideWindowOpenJSForWK inWebView:newWebView];
    [overrideWebviewClose executeFunction:SCHOverrideWindowCloseJS inWebView:newWebView];

    
    return newWebView;
}

- (void) closeCurrentWebView
{
    WKWebView *lastWebview = [self popWebView];
    
    lastWebview.navigationDelegate = nil;
    lastWebview.UIDelegate = nil;
    
    [lastWebview stopLoading];
    [webviewSetPopupClosed executeFunction:SCHSetPopupClosedJS inWebView:lastWebview];
    
    [lastWebview removeFromSuperview];
    
    WKWebView *prevWebView = self.webViewStack.lastObject;
    
    [prevWebView setNavigationDelegate:self];
    [prevWebView setUIDelegate:self];
    
    [webviewSetPopupClosed executeFunction:SCHSetPopupClosedJS inWebView:prevWebView];
    [prevWebView evaluateJavaScript:@"window.unblock()" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        
    }];
}


////////////////////////////////////////////////////////////////////////////////////////////////////////
// authentication challenge ignore
////////////////////////////////////////////////////////////////////////////////////////////////////////


- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler {
    
    NSURLProtectionSpace *protectionSpace = [challenge protectionSpace];
    id<NSURLAuthenticationChallengeSender> sender = [challenge sender];
    NSURLCredential *credential = challenge.proposedCredential;
    
    if ([[protectionSpace authenticationMethod] isEqualToString:NSURLAuthenticationMethodServerTrust] && credential)
    {
        SecTrustRef trust = [[challenge protectionSpace] serverTrust];
        credential = [NSURLCredential credentialForTrust:trust];
        
        [sender continueWithoutCredentialForAuthenticationChallenge:challenge];
    }
    
    completionHandler(NSURLSessionAuthChallengeUseCredential,credential);
}



@end
