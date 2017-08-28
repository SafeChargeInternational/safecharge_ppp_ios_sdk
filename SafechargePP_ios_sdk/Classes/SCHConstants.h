//
//  SCHConstants.h
//  SafechargePP
//
//  Created by Bozhidar Dimitrov on 3/16/15.
//  Copyright (c) 2015-2016 SafeCharge. All rights reserved.
//

//default settings
static NSString * const DefaultPPPRequestVersion = @"4.0.0";
static NSString * const DefaultSCHSafeChargePPPServerURL = @"https://dev-mobile.safecharge.com/ppp/purchase.do";
static NSString * const DefaultSCHSafeChargeWithdrawServerURL = @"";
static NSString * const DefaultcheckSumMethod = @"MD5";

// Withdraw support constants
static NSString * const DefaultWhitdrawRequestVersion = @"4.0.0";

static NSString * const SCHPaymentPagePath = @"/ppp/purchase.do";
static NSString * const SCHBlankPagePath = @"/blank.html";
static NSString * const SCHReviewPagePath = @"/ppp/review.do";

static NSString * const SCHAPMResponsePagePath = @"/ppp/apmgwresponse.do";
static NSString * const SCHCloseWindowURL = @"schppclose://window";
static NSString * const SCHNewWindowURLSuffix = @"//newwindow";

static NSString * const SCHApplePayCaptureURL = @"http://apple.pay.capture.me.invaliddomain/";
static NSString * const SCHApplePaySuccessURL = @"http://apple.pay.capture.me.invaliddomain/success";
static NSString * const SCHApplePayFailureURL = @"http://apple.pay.capture.me.invaliddomain/failure";

static NSString * const SCHSetPopupClosedJS = @"_popupWindow.closed = true; window.unblockUI();";
static NSString * const SCHOverrideWindowOpenJS =
   @"var _popupWindow;"
    ""
    "if (!window.openIsOverriden)"
    "{"
    "    var _open = window.open;"
    ""
    "    window.open = function(url, name, properties)"
    "    {"
    "        _open(url + '//newwindow', name, properties);"
    ""
    "        _popupWindow = {"
    "            closed : false,"
    "            focus : function() { },"
    "            close : function() { }"
    "        };"
    ""
    "        return _popupWindow;"
    "    };"
    ""
    "    window.openIsOverriden = true;"
    "}";

static NSString * const SCHOverrideWindowOpenJSForWK =
    @"var _popupWindow;"
    ""
    "if (!window.openIsOverriden)"
    "{"
    "    var _open = window.open;"
    ""
    "    window.open = function(url, name, properties)"
    "    {"
    "        _open(url, name, properties);"
    ""
    "        _popupWindow = {"
    "            closed : false,"
    "            focus : function() { },"
    "            close : function() { }"
    "        };"
    ""
    "        return _popupWindow;"
    "    };"
    ""
    "    window.openIsOverriden = true;"
    "}";

static NSString * const SCHOverrideWindowCloseJS =
   @"if (!window.closeIsOverriden)"
    "{"
    "   window.close = function()"
    "   {"
    "       window.location.assign('schppclose://window');"
    "   };"
    ""
    "   window.closeIsOverriden = true;"
    "}";

///////////////////////////////////////////////////////////////////////////////////////////////////
// override getClient version JS call
///////////////////////////////////////////////////////////////////////////////////////////////////
static NSString * const SCHOverrideVersion =
    @"function getIOSClientVersion() {"
    @"return _version_;"
    @"}";

static NSString * const SCHAppleEventName = @"APSDK";

static NSString * const SCHSDKVersion = @"1.4";
static NSString * const SCHSDKNonApplePayVersion = @"1.0";
