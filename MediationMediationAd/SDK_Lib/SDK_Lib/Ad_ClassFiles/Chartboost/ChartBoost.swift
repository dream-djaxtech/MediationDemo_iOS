//
//  ChartBoost.swift
//  SDK_Lib
//
//  Created by Djax on 26/05/23.
//

import UIKit
import ChartboostSDK
import StoreKit

class ChartBoost: UIViewController {
    
    var adView = UIView()
    
    private lazy var banner = CHBBanner(size: CHBBannerSizeStandard, location: "default", delegate: self)
    private lazy var interstitial = CHBInterstitial(location: "default", delegate: self)
    private lazy var rewarded = CHBRewarded(location: "default", delegate: self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func setupChartBoostSDK(view:UIView,fromStr:String,dict:[String:AnyObject]) {
        
        self.adView = view
        self.adView.backgroundColor = UIColor.orange
        
        if #available(iOS 11.3, *) {
            SKAdNetwork.registerAppForAdNetworkAttribution()
        }
        Chartboost.addDataUseConsent(.CCPA(.optInSale))
        Chartboost.addDataUseConsent(.GDPR(.behavioral))
        Chartboost.setLoggingLevel(.info)
        Chartboost.start(withAppID: dict["app_id"] as! String,
                         appSignature: dict["app_signature"] as! String) { error in
            print(error == nil ? "Chartboost initialized successfully!" : "Chartboost failed to initialize.")
        }
        if fromStr == "Banner" {
            self.banner.cache()
            self.bannerAd()
        }
        else if fromStr == "RewardedVideo" {
            self.rewarded.cache()
        }
        else if fromStr == "InterstitialVideo" {
            self.interstitial.cache()
        }
    }
    func bannerAd() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            DispatchQueue.main.async {
                self.banner.show(from: self)
                self.adView.addSubview(self.banner)
            }
        }
    }
    func interstitialAd() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            DispatchQueue.main.async {
                self.interstitial.show(from: self)
            }
        }
    }
    func rewardedAd() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            DispatchQueue.main.async {
                self.rewarded.show(from: self)
            }
        }
    }
}
extension ChartBoost : CHBBannerDelegate {
    func didFinishHandlingClick(_ event: CHBClickEvent, error: CHBClickError?)
    {
        print(event.ad)
        print(error.debugDescription)
    }
}
extension ChartBoost : CHBRewardedDelegate {
    func didEarnReward(_ event: CHBRewardEvent) {
        print("didEarnReward: " + String(event.reward))
    }
    func didDismissAd(_ event: CHBDismissEvent) {
        print("didDismissAd: \(type(of: event.ad))")
    }
}
extension ChartBoost : CHBInterstitialDelegate {
    func didCacheAd(_ event: CHBCacheEvent, error: CHBCacheError?) {
        print("didCacheAd: \(type(of: event.ad)) \(statusWithError(error))")
    }
    
    func willShowAd(_ event: CHBShowEvent) {
        print("willShowAd: \(type(of: event.ad))")
    }
    
    func didShowAd(_ event: CHBShowEvent, error: CHBShowError?) {
        print("didShowAd: \(type(of: event.ad)) \(statusWithError(error))")
    }
    
    func didClickAd(_ event: CHBClickEvent, error: CHBClickError?) {
        print("didClickAd: \(type(of: event.ad)) \(statusWithError(error))")
    }
    func statusWithError(_ error: Any?) -> String {
        if let error = error {
            return "FAILED (\(error))"
        }
        return "SUCCESS"
    }
}
