'use strict';
import { NativeModules, DeviceEventEmitter } from 'react-native';
const { CTKInterstitialAdManager } = NativeModules;
const eventHandlers = {
    fbInterstitialDidLoad: new Map(),
    fbInterstitialDidFail: new Map(),
    fbInterstitialDidClose: new Map(),
};
const addEventListener = (type, handler) => {
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
};
const removeEventListener = (type, handler) => {
    if (!eventHandlers[type].has(handler)) {
        return;
    }
    eventHandlers[type].get(handler).remove();
    eventHandlers[type].delete(handler);
};
const removeAllListeners = () => {
    DeviceEventEmitter.removeAllListeners('fbInterstitialDidLoad');
    DeviceEventEmitter.removeAllListeners('fbInterstitialDidFail');
    DeviceEventEmitter.removeAllListeners('fbInterstitialDidClose');
};
export default {
    /**
     * Shows interstitial ad for a given placementId
     */
    showAd() {
        return CTKInterstitialAdManager.showAd();
    },
    requestAd(placementId) {
        CTKInterstitialAdManager.requestAd(placementId);
    },
    addEventListener,
    removeEventListener,
    removeAllListeners
};
