//
//  SCHWebKitPaymentViewController.m
//  SafechargePP
//
//  Created by Miroslav Chernev on 1/25/17.
//  Copyright © 2017 SafeCharge. All rights reserved.
//

#import "SCHWebKitPaymentViewController.h"
#import <WebKit/WebKit.h>
#import "SCHLogging.h"

#import "SCHConstants.h"
#import "SCHJsFunction.h"
#import "SCHApplePayment.h"
#import "SCHPaymentData.h"
#import "SCHEventData.h"
#import "SCHConfiguration.h"
#import "SCHPaymentRequestBuilder.h"
#import "SCHPPResult.h"

//////////////////////////////////////////////////////////////////////
#define SCHBUILDER          (1)
//////////////////////////////////////////////////////////////////////



@interface SCHWebKitPaymentViewController() <WKScriptMessageHandler,WKNavigationDelegate,WKUIDelegate,SCHJsFunctionDelegate>
{
    NSMutableArray<WKWebView*> *webViewsArray;
    
    WKWebView *_webView;
    WKWebView *_APMWebView;
    
    SCHJsFunction   *overrideWebviewClose;
    SCHJsFunction   *overrideWebviewPopup;
    SCHJsFunction   *versionJSHandler;
    SCHJsFunction   *onTokenAvaibleHandler;
    SCHJsFunction   *onCancelHandler;
    SCHJsFunction   *apmCloseOverrideHandler;
    SCHJsFunction   *webviewSetPopupClosed;
    SCHEventData    *eventData;
    SCHPaymentData  *eventPaymentData;
    SCHApplePayment *applePayment;
    
    //
    PKPaymentAuthorizationViewController *authorizationController;
    
    SCHPaymentRequestBuilder             *schRequestBuilder;
    NSURLRequest                         *remoteRequest;
    
    BOOL paymentPageLoaded;
}

@end

@implementation SCHWebKitPaymentViewController


- (instancetype) initWithSCHRequestBuilder:(SCHPaymentRequestBuilder *) schRequest {
    self = [super init] ;
    if ( self ) {
        schRequestBuilder = schRequest;
    }
    
    return self;
}

- (instancetype) initWithURLRequest:(NSURLRequest*) request {
    self = [super init];
    if ( self ) {
        remoteRequest = request;
    }
    return self;
}

-(void) loadView {
    [super loadView];
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc]
                                             init];
    
    WKUserContentController *controller = [[WKUserContentController alloc]
                                           init];
    
    [controller addScriptMessageHandler:self name:SCHAppleEventName];    
    configuration.userContentController = controller;
    
    
    //intiialize the event
    eventData = [[SCHEventData alloc] init];
    eventPaymentData = [[SCHPaymentData alloc] init];
    
    //initialize the event handlers
    onCancelHandler = [[SCHJsFunction alloc] init];
    [onCancelHandler setDelegate:self];
    onTokenAvaibleHandler = [[SCHJsFunction alloc] init];
    [onTokenAvaibleHandler setDelegate:self];

    //standard close handler
    webviewSetPopupClosed = [[SCHJsFunction alloc] init];

    
    _webView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:configuration];
    _webView.backgroundColor = [UIColor whiteColor];
    [_webView setNavigationDelegate:self];
    [_webView setUIDelegate:self];
    self.view = _webView;
    
    //adjust
    _webView.scrollView.scrollEnabled = [SCHConfiguration configurationInstance].enableWebViewScroll.boolValue;
    
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadRemote];
}

-(void) loadRemote {
    NSURLRequest *urlRequest = nil;
    if ( self->schRequestBuilder )
        urlRequest = [self->schRequestBuilder constructURLRequest];
    else if ( self->remoteRequest )
        urlRequest = self->remoteRequest;
    
    if ( urlRequest ) {
        [_webView loadRequest:urlRequest];
    } else {
        SCHLog(@"urlRequest error");
        SCHAssert(false);
    }
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//event handler
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)userContentController:(WKUserContentController *)userContentController
      didReceiveScriptMessage:(WKScriptMessage *)message
{
    id params = message.body;
    if( [message.name isEqualToString:SCHAppleEventName] ) {
        
        if ([params isKindOfClass:[NSDictionary class]]) {
            
            NSString *eventName = [(NSDictionary*)params objectForKey:@"event"];
            
            if([eventName isEqualToString:@"initiatePayment"]) {
                [eventData updateWithPayload:params];
                [self initAndShowApplePay];
                SCHLog(@"initiatePayment");
            }
            else if ( [eventName isEqualToString:@"finishPayment"] ) {
                [eventPaymentData updateWithPayload:params];
                
                if( self->applePayment == nil ) {
                    SCHLog(@"self->applePayment == nil, ignore");
                    return;
                }
                
                if ( [eventPaymentData->status isEqualToString:@"CANCELED"] ) {
                    self->applePayment->completitionBlock(PKPaymentAuthorizationStatusFailure);
                } else if ( [eventPaymentData->status isEqualToString:@"SUCCESS"] ) {
                    self->applePayment->completitionBlock(PKPaymentAuthorizationStatusSuccess);
                    [_delegate paymentPageController:self didFinishWithResult:[[SCHPPResult alloc] initWithEventData:eventPaymentData]];
                }
                
                self->applePayment->completitionBlock = nil;
                self->applePayment = nil;
                
                SCHLog(@"finishPayment with status : %@",eventPaymentData->status);
            }
        }
    }
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//JSFunction caller delegate
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(void) onFunctionCallSuccessfull:(SCHJsFunction * _Nonnull) caller
                       withResult:(id _Nullable) result
                           caller:(NSString* _Nullable) callerName {
    NSLog(@"handler call ok:%@",callerName);
}

-(void) onFunctionCallError:(SCHJsFunction * _Nonnull) caller
                  withError:(NSError* _Nullable) error {
    NSLog(@"handler call bad with error:%@",error.localizedDescription);
    
    if ( self->applePayment && self->applePayment->completitionBlock ) {
        self->applePayment->completitionBlock(PKPaymentAuthorizationStatusFailure);
        self->applePayment->completitionBlock = nil;
    }
    
    if ( authorizationController ) {
        [authorizationController setDelegate:nil];
        [authorizationController dismissViewControllerAnimated:TRUE completion:^{
            [self callApplePayCancel];
            [_delegate paymentPageController:self didFailLoadPaymentPageWithError:error];
            
        }];
        authorizationController = nil;
    } else {
        [_delegate paymentPageController:self didFailLoadPaymentPageWithError:error];
    }
    
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

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/// apple pay protocol
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(void) applePayNewBuilder {
    
    if ( schRequestBuilder.allowsApplePay.boolValue == FALSE &&
        schRequestBuilder.applePaySupport == SCHApplePaySupportNotSupported) {
        return;
    }
    
    PKPaymentRequest *paymentRequest = [schRequestBuilder constructApplePayRequest:eventData];
    if( !paymentRequest ){
        SCHLog(@"paymentRequest nil");
        SCHAssert(false);
        return;
    }
    
    authorizationController = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:paymentRequest];
    if ( authorizationController == nil ) {
        SCHLog(@"authorizationController - unsupported apple pay");
        return;
    }

    authorizationController.delegate = self;
    
    
    
    
    self->applePayment = [[SCHApplePayment alloc] init];
    
    
    [self presentViewController:authorizationController animated:YES completion:^{
        
    }];
}

-(void) initAndShowApplePay {
    [self applePayNewBuilder];
}

- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                       didAuthorizePayment:(PKPayment *)payment
                                completion:(void (^)(PKPaymentAuthorizationStatus status))completion
{
    NSData *paymentData = payment.token.paymentData;
    if( paymentData && paymentData.length > 0 ) {
        NSString *jsonDataString = [NSString stringWithUTF8String:paymentData.bytes];
        NSString *jsonPPData = [NSString stringWithFormat:@"{\"paymentData\":%@}", jsonDataString];
        NSString *formattedFunction = [NSString stringWithFormat:@"%@(%@);",eventData->onTokenAvaible,jsonPPData];
        [onTokenAvaibleHandler executeFunction:formattedFunction inWebView:self->_webView];
        self->applePayment->completitionBlock = completion;
    } else {
        SCHLog(@"paymentData.length is 0");
        [controller dismissViewControllerAnimated:FALSE completion:^{
            [_delegate paymentPageController:self didFailLoadPaymentPageWithError:[NSError errorWithDomain:@"APP error" code:-100 userInfo:@{@"error":@"not working on sim"}]];
        }];
        
    }
}

-(NSString*) reformatCancelFunction:(NSString*) inAnonymous {
    NSRange foundBracket = [inAnonymous rangeOfString:@"()"];
    NSString *functionName = @"executeCancel";
    NSMutableString *result = [[NSMutableString alloc] initWithString:inAnonymous];
    [result insertString:functionName atIndex:foundBracket.location];
    [result appendString:[NSString stringWithFormat:@" %@();",functionName]];
    return result;
}

-(void) callApplePayCancel {
    NSString *handleCancelResult = @"cancel_var.toString();";
    handleCancelResult = [handleCancelResult stringByReplacingOccurrencesOfString:@"cancel_var" withString:eventData->onCancel];
    
    SCHJsFunction *preHandler = [[SCHJsFunction alloc] init];
    [preHandler executeFunctionWithBlock:handleCancelResult
                               inWebView:self->_webView
                        withCompletition:^(BOOL executed, id result) {
                            if (executed ){
                                if ( [result isKindOfClass:[NSString class]] ){
                                    NSString *casted = [self reformatCancelFunction:result];
                                    [onCancelHandler executeFunction:casted inWebView:self->_webView];
                                }
                            } else {
                                assert(false);
                            }
                        }];

}

- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller
{
    if( self->applePayment && self->applePayment->completitionBlock == nil ) {
        [self callApplePayCancel];
    }
    
    self->applePayment = nil;
    [controller dismissViewControllerAnimated:TRUE completion:^{
        
    }];
}

-(NSString*) getVersionBasedOnAppleSupport {
    NSString *verApple = @"1.4";
    NSString *verNoApple = @"1.0";
    
    if ( self->schRequestBuilder.applePaySupport == SCHApplePaySupportNotSupported ) {
        return [SCHOverrideVersion stringByReplacingOccurrencesOfString:@"_version_" withString:verNoApple];
    } else {
        return [SCHOverrideVersion stringByReplacingOccurrencesOfString:@"_version_" withString:verApple];
    }
}


-(void) registerHandlers : (WKWebView *) webView{
    if(versionJSHandler == nil ) {
        versionJSHandler = [[SCHJsFunction alloc] init];
        [versionJSHandler setDelegate:self];
        [versionJSHandler executeFunction:[self getVersionBasedOnAppleSupport] inWebView:webView];
    }
    if ( overrideWebviewPopup == nil ) {
        overrideWebviewPopup = [[SCHJsFunction alloc] init];
        [overrideWebviewPopup setDelegate:self];
        [overrideWebviewPopup executeFunction:SCHOverrideWindowOpenJSForWK inWebView:webView];
    }
    if ( overrideWebviewClose == nil ) {
        overrideWebviewClose = [[SCHJsFunction alloc] init];
        [overrideWebviewClose setDelegate:self];
        [overrideWebviewClose executeFunction:SCHOverrideWindowCloseJS inWebView:webView];
    }
}


- (void)                    webView:(WKWebView *)webView
    decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
                    decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    NSURLRequest *request   = navigationAction.request;
    WKNavigationActionPolicy decision = WKNavigationActionPolicyAllow;
 
   [self registerHandlers:_webView];
 
#ifdef DEBUG
    SCHLog(@"webview requesting : %@ ", request.URL.absoluteString);
#endif
    
    if (webView == _webView)
    {
        if ([request.URL.absoluteString rangeOfString:SCHReviewPagePath].location != NSNotFound && _APMWebView != nil) {
        }
        
        if ([request.URL.absoluteString rangeOfString:SCHApplePaySuccessURL].location != NSNotFound)
        {
            //[self finishApplePayPaymentWithSuccess];
            decision = WKNavigationActionPolicyCancel;
        }
        else if ([request.URL.absoluteString rangeOfString:SCHApplePayFailureURL].location != NSNotFound)
        {
            //[self finishApplePayPaymentWithFailure];
            decision = WKNavigationActionPolicyCancel;
        }
        else if ([request.URL.absoluteString rangeOfString:SCHApplePayCaptureURL].location != NSNotFound)
        {
            //[self beginApplePayPaymentWithRequestBuilder:_requestBuilder];
            decision = WKNavigationActionPolicyCancel;
        }
        else
        {
            SCHPPResult *result = [[SCHPPResult alloc] initWithURL:request.URL];
            
            if (result)
            {
                [_delegate paymentPageController:self didFinishWithResult:result];
               decision = WKNavigationActionPolicyCancel;
                
            }
            
        }
    }
    else if (webView == _APMWebView && [request.URL.absoluteString isEqualToString:SCHCloseWindowURL])
    {
        [self APMFlowDidFinish];
        
        decision = WKNavigationActionPolicyCancel;
    }
    
    decisionHandler(decision);
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//navigation delegate
/////////////////////////////////////////////////////////////////////////////////////////////////////////


- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation
{
    if (webView == _APMWebView && [webView.URL.absoluteString rangeOfString:SCHAPMResponsePagePath].location != NSNotFound)
    {
       
        [self APMFlowDidFinish];
    }
}
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    if (webView == _APMWebView) {
        apmCloseOverrideHandler = [[SCHJsFunction alloc] init];
        [apmCloseOverrideHandler setDelegate:self];
        [apmCloseOverrideHandler executeFunction:SCHOverrideWindowCloseJS inWebView:_APMWebView];
    }  else if (webView == _webView) {
        [_webView evaluateJavaScript:SCHOverrideWindowOpenJSForWK completionHandler:nil];
    }
}



- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    //[_delegate paymentPageController:self didFailLoadPaymentPageWithError:error];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    NSString *failingURL = error.userInfo[NSURLErrorFailingURLStringErrorKey];
    if ([failingURL rangeOfString:SCHBlankPagePath].location == NSNotFound) {
        [_delegate paymentPageController:self didFailLoadPaymentPageWithError:error];
        
        if ( webView == _APMWebView ) {
            [self APMFlowDidFinish];
        }
    }
    
  
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//APM Webview show/hide logic
/////////////////////////////////////////////////////////////////////////////////////////////////////////

- (WKWebView *)             webView:(WKWebView *)webView
     createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration
                forNavigationAction:(WKNavigationAction *)navigationAction
                     windowFeatures:(WKWindowFeatures *)windowFeatures
{
    CGRect frame = CGRectMake(0.0f, 0.0f, _webView.bounds.size.width, _webView.bounds.size.height);
    _APMWebView = [[WKWebView alloc] initWithFrame:frame configuration:configuration];
    [self.view addSubview:_APMWebView];
    _APMWebView.scrollView.contentInset = _webView.scrollView.contentInset;
    _APMWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _APMWebView.navigationDelegate = self;
    
    return _APMWebView;
}

- (void)APMFlowDidFinish
{
    [_APMWebView stopLoading];
    [_APMWebView removeFromSuperview];
    _APMWebView.navigationDelegate = nil;
    _APMWebView.UIDelegate = nil;
    _APMWebView = nil;
    
    [webviewSetPopupClosed executeFunction:SCHSetPopupClosedJS inWebView:_webView];
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
    /*else
    {
        if ( challenge )
            [sender performDefaultHandlingForAuthenticationChallenge:challenge];
    } */
    
    completionHandler(NSURLSessionAuthChallengeUseCredential,credential);
}

@end
