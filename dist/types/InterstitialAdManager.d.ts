declare const _default: {
    /**
     * Shows interstitial ad for a given placementId
     */
    showAd(): Promise<boolean>;
    requestAd(placementId: string): void;
    addEventListener: (type: string, handler: (error?: string | undefined) => void) => void;
    removeEventListener: (type: string, handler: () => void) => void;
    removeAllListeners: () => void;
};
export default _default;
