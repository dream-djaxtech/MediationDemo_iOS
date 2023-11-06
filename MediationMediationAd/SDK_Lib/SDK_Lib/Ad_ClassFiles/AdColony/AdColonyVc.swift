//
//  AdColony.swift
//  SDK_Lib
//
//  Created by Djax on 26/05/23.
//

import UIKit
import AdColony
import ObjectiveC.runtime

class AdColonyVc: UIViewController {

    weak var ad: AdColonyAdView? = nil
    var adInt: AdColonyInterstitial?

    var bannerView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    func setupAdcolonySDK(view:UIView,fromStr:String) {
        self.bannerView = view
        self.bannerView.backgroundColor = UIColor.orange
        AdColony.configure(withAppID: "appbdee68ae27024084bb334a", options: nil) { (zones) in
            if fromStr == "RewardedVideo" {
                
            }
            else if fromStr == "Banner" {
                self.requestBanner()
            }
        }
    }
    func requestBanner() {
        AdColony.requestAdView(inZone: "vz77f5db656e2840c4ab", with: kAdColonyAdSizeBanner, viewController: self, andDelegate: self)
    }
    func clearBanner() {
        if let adView = self.ad {
            adView.destroy()
            self.ad = nil
        }
    }
    func requestInterstitial() {
        //        AdColony.configure(withAppID: "app75d5d509ff774fab8f", options: nil) { [weak self] (zones) in
                    NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification,
                                                           object: nil,
                                                           queue: OperationQueue.main,
                                                           using: { notification in
                        //If our ad has expired, request a new interstitial
                        if (self.adInt == nil) {
                            self.requestInterstitials()
                        }
                    })
                    //AdColony has finished configuring, so let's request an interstitial ad
                    self.requestInterstitials()
        //        }
            }
 
    func requestRewarded() {
        //        let rewardedZones:Array<String> = ["vz882f53b8196d4b5a80"]
        //        AdColony.configure(withAppID: "appbdee68ae27024084bb334a", options: nil) { [weak self] (zones) in
        //            for zone in zones {
        //                if rewardedZones.contains(zone.identifier) {
        //                    zone.setReward({ [weak self] (success, name, amount) in
        //                        if (success) {
        //                            if (self?.adInt == nil) {
        //                                self?.requestInterstitials()
        ////                                AdColony.requestInterstitial(inZone: "vz882f53b8196d4b5a80", options: nil, andDelegate: self!)
        //                            }
        //                        }
        //                    })
        //                }
        //            }
        //        }
        /* Swift */
        
        let rewardedZones:Array<String> = ["v4vcb31d349f777e41ee8c"]
        AdColony.configure(withAppID: "app75d5d509ff774fab8f", options: nil) { [weak self] (zones) in
            for zone in zones {
                if rewardedZones.contains(zone.identifier) {
                    zone.setReward({ [weak self] (success, name, amount) in
                        if (success != nil) {
                            print(success)
                            print(name)
                            print(amount)
                            
//                            self?.rewardUser(coinsAmount: amount, currencyName: name)
                        }
                    } )
                }
            }
        }
    }
    func loadAd() {
//        AdColony.configure(withAppID: "app75d5d509ff774fab8f", options: nil) { [weak self] (zones) in
            NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification,
                                                   object: nil,
                                                   queue: OperationQueue.main,
                                                   using: { notification in
                //If our ad has expired, request a new interstitial
                if (self.adInt == nil) {
                    self.requestInterstitial()
                }
            })
            //AdColony has finished configuring, so let's request an interstitial ad
            self.requestInterstitials()
//        }
    }
    func requestInterstitials() {
        //Request an interstitial ad from AdColony
        AdColony.requestInterstitial(inZone: "vzcf396c0e429c45f092", options: nil, andDelegate: self)
        if let ad = self.adInt, !ad.expired {
            self.adInt?.show(withPresenting: self)
        }
    }
    func loadAds(){
        //vzb2fc4d9b99454bb982 - new
        //vz882f53b8196d4b5a80 - old
//        let appOptions = AdColonyAppOptions()
//        appOptions.userID = "newuserid"
//        AdColony.setAppOptions(appOptions)
        
        let rewardedZones:Array<String> = ["vz882f53b8196d4b5a80"]
        AdColony.configure(withAppID: "app75d5d509ff774fab8f", options: nil) { [weak self] (zones) in
            for zone in zones {
                if rewardedZones.contains(zone.identifier) {
                    let zone = zones.first
                    zone?.setReward({ [weak self] (success, name, amount) in
                        if (success) {
                        }
                    })
                }
            }
        }
        let options = AdColonyAdOptions()
        options.showPrePopup = false
        options.showPostPopup = false

        AdColony.requestInterstitial(inZone: "vzb2fc4d9b99454bb982", options: options, andDelegate: self)
        self.loadAd()
    }
}
extension AdColonyVc : AdColonyAdViewDelegate {
    func adColonyAdViewDidLoad(_ adView: AdColonyAdView) {
        self.clearBanner()
        self.ad = adView
        let placementSize = self.bannerView.frame.size
        adView.frame = CGRect(x: 0, y: 0, width: placementSize.width, height: placementSize.height)
        self.bannerView.addSubview(adView)
    }
    func adColonyAdViewDidFail(toLoad error: AdColonyAdRequestError) {
        if let reason = error.localizedFailureReason {
            print("SAMPLE_APP: Banner request failed in zone \(error.zoneId) with error: \(error.localizedDescription) and failure reason: \(reason)")
        } else if let recoverySuggestion = error.localizedRecoverySuggestion {
            print("SAMPLE_APP: Banner request failed in zone \(error.zoneId) with error: \(error.localizedDescription) and recovery suggestion: \(recoverySuggestion)")
        } else {
            print("SAMPLE_APP: Banner request failed in zone \(error.zoneId) with error: \(error.localizedDescription)")
        }
    }
}
extension AdColonyVc : AdColonyInterstitialDelegate {
    func adColonyInterstitialDidLoad(_ interstitial: AdColonyInterstitial) {
        self.adInt = interstitial
        if let ad = self.adInt, !ad.expired {
            ad.show(withPresenting: self)
        }
    }
    func adColonyInterstitialDidFail(toLoad error: AdColonyAdRequestError) {
        if let reason = error.localizedFailureReason {
            print("SAMPLE_APP: Request failed in zone \(error.zoneId) with error: \(error.localizedDescription) and failure reason: \(reason)")
        } else if let recoverySuggestion = error.localizedRecoverySuggestion {
            print("SAMPLE_APP: Request failed in zone \(error.zoneId) with error: \(error.localizedDescription) and recovery suggestion: \(recoverySuggestion)")
        } else {
            print("SAMPLE_APP: Request failed in zone \(error.zoneId) with error: \(error.localizedDescription)")
        }
    }
    func adColonyInterstitialExpired(_ interstitial: AdColonyInterstitial) {
        self.ad = nil
        self.requestInterstitial()
    }
    func adColonyInterstitialDidClose(_ interstitial: AdColonyInterstitial) {
        self.ad = nil
        self.requestInterstitial()
    }
}
