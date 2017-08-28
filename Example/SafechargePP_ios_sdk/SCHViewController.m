//
//  SCHViewController.m
//  SafechargePP_ios_sdk
//
//  Created by miroslavch@safecharge.com on 08/28/2017.
//  Copyright (c) 2017 miroslavch@safecharge.com. All rights reserved.
//

#import "SCHViewController.h"
#import <SafechargePP_ios_sdk/SafechargePP.h>

@interface SCHViewController () < SCHPaymentPageProtocol >
    
    
    @property (weak, nonatomic) IBOutlet UITextView *urlTextField;
    
    
    @end

@implementation SCHViewController
    
- (void)viewDidLoad
    {
        [super viewDidLoad];
        // Do any additional setup after loading the view, typically from a nib.
    }
    
- (void)didReceiveMemoryWarning
    {
        [super didReceiveMemoryWarning];
        // Dispose of any resources that can be recreated.
    }
    
-( void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}
    
- (IBAction)onOpenURL:(id)sender {
    if ( self.urlTextField.text.length  == 0 )
    return;
    
    NSString *urlToOpen = self.urlTextField.text;
    NSURL *url = [[NSURL alloc] initWithString:urlToOpen];
    
    if ( url != nil && [url scheme] != nil && [url host]  != nil) {
        NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:url];
        
        SCHWebKitPaymentViewController *next = [[SCHWebKitPaymentViewController alloc] initWithURLRequest:urlRequest];
        
        [next setDelegate:self];
        [self.navigationController pushViewController:next animated:YES];
    } else {
        [self showURLError];
    }
}
    
-(void) showURLError {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error"                                                                             message:@"Unable to open the url, check the format"
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"Ok"
                                                           style:UIAlertActionStyleDefault
                                                         handler:nil];
        [alertController addAction:actionOk];
        [self presentViewController:alertController animated:YES completion:nil];
        
    }
    
- (void)paymentPageController:(SCHWebKitPaymentViewController *)paymentPageController
          didFinishWithResult:(SCHPPResult *)result {
    NSLog(@"paymentPageController didFinishWithResult called");
}
    
- (void)paymentPageController:(SCHWebKitPaymentViewController *)paymentPageController
didFailLoadPaymentPageWithError:(NSError *)error {
    NSLog(@"paymentPageController didFailLoadPaymentPageWithError called");
}
    
    
    @end
