'use strict';

import { NativeModules, DeviceEventEmitter } from 'react-native';

const { CTKInterstitialAdManager } = NativeModules;

const eventHandlers:{ [index:string] : Map<(error?: string)=>void, any> } = {
    fbInterstitialDidLoad: new Map<()=>void, any>(),
    fbInterstitialDidFail: new Map<(error?: string)=>void, any>(),
    fbInterstitialDidClose: new Map<()=>void, any>(),
};

const addEventListener = (type: string, handler: (error?: string)=>void) => {
    switch (type) {
        case 'fbInterstitialDidLoad':
            eventHandlers[type].set(handler, DeviceEventEmitter.addListener(type, handler));
            break;
        case 'fbInterstitialDidFail':
            eventHandlers[type].set(handler, DeviceEventEmitter.addListener(type, (error) => { handler(error); }));
            break;
        case 'fbInterstitialDidClose':
            eventHandlers[type].set(handler, DeviceEventEmitter.addListener(type, handler));
            break;
        default:
            console.log(`Event with type ${type} does not exist.`);
    }
}

const removeEventListener = (type: string, handler: ()=>void) => {
    if (!eventHandlers[type].has(handler)) {
        return;
    }
    eventHandlers[type].get(handler).remove();
    eventHandlers[type].delete(handler);
}

const removeAllListeners = () => {
    DeviceEventEmitter.removeAllListeners('fbInterstitialDidLoad');
    DeviceEventEmitter.removeAllListeners('fbInterstitialDidFail');
    DeviceEventEmitter.removeAllListeners('fbInterstitialDidClose');
};


export default {
  /**
   * Shows interstitial ad for a given placementId
   */
  showAd(): Promise<boolean> {
    return CTKInterstitialAdManager.showAd();
  },

  requestAd(placementId: string): void {
    CTKInterstitialAdManager.requestAd(placementId);
  },

  addEventListener,
  removeEventListener,
  removeAllListeners
};
