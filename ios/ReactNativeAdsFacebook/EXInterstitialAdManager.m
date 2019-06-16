#import "EXInterstitialAdManager.h"
#import "EXUnversioned.h"

#import <FBAudienceNetwork/FBAudienceNetwork.h>
#import <React/RCTUtils.h>
#import <React/RCTLog.h>

@interface EXInterstitialAdManager () <FBInterstitialAdDelegate>

@property (nonatomic, strong) RCTPromiseResolveBlock resolve;
@property (nonatomic, strong) RCTPromiseRejectBlock reject;
@property (nonatomic, strong) FBInterstitialAd *interstitialAd;
@property (nonatomic, strong) UIViewController *adViewController;
@property (nonatomic) bool didClick;
@property (nonatomic) bool isBackground;

@end

@implementation EXInterstitialAdManager

@synthesize bridge = _bridge;

RCT_EXPORT_MODULE(CTKInterstitialAdManager)

- (void)setBridge:(RCTBridge *)bridge
{
  _bridge = bridge;
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(bridgeDidForeground:)
                                               name:EX_UNVERSIONED(@"EXKernelBridgeDidForegroundNotification")
                                             object:self.bridge];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(bridgeDidBackground:)
                                               name:EX_UNVERSIONED(@"EXKernelBridgeDidBackgroundNotification")
                                             object:self.bridge];
}

RCT_EXPORT_METHOD(
  requestAd:(NSString *)placementId
)
{
    RCTAssert(_isBackground == false, @"`showAd` can be called only when experience is running in foreground");
    //  if (![EXFacebook facebookAppIdFromNSBundle]) {
    //    RCTLogWarn(@"No Facebook app id is specified. Facebook ads may have undefined behavior.");
    //  }
    
    _interstitialAd = [[FBInterstitialAd alloc] initWithPlacementID:placementId];
    _interstitialAd.delegate = self;
    //  [EXUtil performSynchronouslyOnMainThread:^{
    [self->_interstitialAd loadAd];
    //  }];
}

RCT_EXPORT_METHOD(
  showAd:
  (RCTPromiseResolveBlock)resolve
  rejecter:(RCTPromiseRejectBlock)reject
)
{
  RCTAssert(_resolve == nil && _reject == nil, @"Only one `showAd` can be called at once");
  RCTAssert(_isBackground == false, @"`showAd` can be called only when experience is running in foreground");
//  if (![EXFacebook facebookAppIdFromNSBundle]) {
//    RCTLogWarn(@"No Facebook app id is specified. Facebook ads may have undefined behavior.");
//  }
  
  _resolve = resolve;
  _reject = reject;
    
    if(_interstitialAd == nil || !_interstitialAd.isAdValid){
        _reject(@"E_FAILED_TO_LOAD", @"Ad not loaded", nil);
        [self cleanUpAd];
        return;
    }

    [_interstitialAd showAdFromRootViewController:RCTPresentedViewController()];
}

#pragma mark - FBInterstitialAdDelegate

- (void)interstitialAdDidLoad:(__unused FBInterstitialAd *)interstitialAd
{
  [self.bridge.eventDispatcher sendDeviceEventWithName:@"fbInterstitialDidLoad" body:nil];
}

- (void)interstitialAd:(FBInterstitialAd *)interstitialAd didFailWithError:(NSError *)error
{
  [self.bridge.eventDispatcher sendDeviceEventWithName:@"fbInterstitialDidFail" body:@{@"error": [error localizedDescription]}];
  [self cleanUpAd];
}

- (void)interstitialAdDidClick:(FBInterstitialAd *)interstitialAd
{
  _didClick = true;
}

- (void)interstitialAdDidClose:(FBInterstitialAd *)interstitialAd
{
  _resolve(@(_didClick));
  [self.bridge.eventDispatcher sendDeviceEventWithName:@"fbInterstitialDidClose" body:nil];
  [self cleanUpAd];
}

- (void)bridgeDidForeground:(NSNotification *)notification
{
  _isBackground = false;
  
  if (_adViewController) {
    [RCTPresentedViewController() presentViewController:_adViewController animated:NO completion:nil];
    _adViewController = nil;
  }
}

- (void)bridgeDidBackground:(NSNotification *)notification
{
  _isBackground = true;
  
  if (_interstitialAd) {
    _adViewController = RCTPresentedViewController();
    [_adViewController dismissViewControllerAnimated:NO completion:nil];
  }
}

- (void)cleanUpAd
{
  _reject = nil;
  _resolve = nil;
  _interstitialAd = nil;
  _adViewController = nil;
  _didClick = false;
}

@end
