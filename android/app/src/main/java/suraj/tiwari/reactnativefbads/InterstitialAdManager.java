package suraj.tiwari.reactnativefbads;

import android.support.annotation.Nullable;

import com.facebook.ads.Ad;
import com.facebook.ads.AdError;
import com.facebook.ads.InterstitialAd;
import com.facebook.ads.InterstitialAdListener;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.LifecycleEventListener;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;

public class InterstitialAdManager extends ReactContextBaseJavaModule implements InterstitialAdListener, LifecycleEventListener {

  private Promise mPromise;
  private boolean mDidClick = false;
  private InterstitialAd mInterstitial;

  public InterstitialAdManager(ReactApplicationContext reactContext) {
    super(reactContext);
    reactContext.addLifecycleEventListener(this);
  }

  @ReactMethod
  public void requestAd(String placementId) {
    ReactApplicationContext reactContext = this.getReactApplicationContext();

    mInterstitial = new InterstitialAd(reactContext, placementId);
    mInterstitial.setAdListener(this);
    mInterstitial.loadAd();
  }

  @ReactMethod
  public void showAd(Promise p) {
    if (mPromise != null) {
      p.reject("E_FAILED_TO_SHOW", "Only one `showAd` can be called at once");
      return;
    }

    mPromise = p;
    if(!mInterstitial.isAdLoaded()){
      mPromise.reject("E_FAILED_TO_LOAD", "Ad not loaded");
      cleanUp();
      return;
    }

    mInterstitial.show();
  }

  @Override
  public String getName() {
    return "CTKInterstitialAdManager";
  }

  @Override
  public void onError(Ad ad, AdError adError) {
    WritableMap event = Arguments.createMap();
    event.putString("error", adError.getErrorMessage());
    sendEvent("fbInterstitialDidFail", event);

    cleanUp();
  }

  @Override
  public void onAdLoaded(Ad ad) {
    sendEvent("fbInterstitialDidLoad", null);
  }

  @Override
  public void onAdClicked(Ad ad) {
    mDidClick = true;
  }

  @Override
  public void onInterstitialDismissed(Ad ad) {
    mPromise.resolve(mDidClick);
    sendEvent("fbInterstitialDidClose", null);
    cleanUp();
  }

  @Override
  public void onInterstitialDisplayed(Ad ad) {

  }

  @Override
  public void onLoggingImpression(Ad ad) {
  }

  private void cleanUp() {
    mPromise = null;
    mDidClick = false;

    if (mInterstitial != null) {
      mInterstitial.destroy();
      mInterstitial = null;
    }
  }

  @Override
  public void onHostResume() {

  }

  @Override
  public void onHostPause() {

  }

  @Override
  public void onHostDestroy() {
    cleanUp();
  }


  private void sendEvent(String eventName, @Nullable WritableMap params) {
    getReactApplicationContext().getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class).emit(eventName, params);
  }
}
