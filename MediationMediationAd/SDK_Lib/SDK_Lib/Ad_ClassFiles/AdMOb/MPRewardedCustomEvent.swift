//
//  MPRewardedCustomEvent.swift
//  SDK_Lib
//
//  Created by Djax on 12/10/22.
//

import UIKit
import GoogleMobileAds

@objc(MPGoogleAdMobRewardedVideoCustomEvent)
class MPRewardedCustomEvent: UIViewController {
    
    let webSc = WebService()

    var strError:String? = ""
    var dict:[String:AnyObject] = [:]
    
    var rewardedAd: GADRewardedAd?
    var coinCount = 0
    
    func loadInterstitial(vc:UIViewController,adUnit:String,zone:String,dictR:[String:AnyObject]) {
        dict = dictR
        let request = GADRequest()
        GADRewardedAd.load(
            withAdUnitID: adUnit, request: request
        ) { (ad, error) in
            if let error = error {
                print("Rewarded ad failed to load with error: \(error.localizedDescription)")
                if error.localizedDescription == "Cannot determine request type. Is your ad unit id correct?" || error.localizedDescription == "Ad unit doesn't match format. <https://support.google.com/admob/answer/9905175#4>" {
                    self.strError = error.localizedDescription
                    self.manageRewImage()
                }
                return
            }
            self.rewardedAd = ad
            self.rewardedAd?.fullScreenContentDelegate = self
            if let ad = self.rewardedAd {
                ad.present(fromRootViewController: vc) {
                    let reward = ad.adReward
                    self.webSc.trackingUrl(url: self.dict["request_url"] as! String)

                    print("Reward received with currency \(reward.amount), amount \(reward.amount.doubleValue)")
                    self.earnCoins(NSInteger(truncating: reward.amount))
                    // TODO: Reward the user.
                }
            } else {
                print("Rewarded ad isn't available yet. \n The rewarded ad cannot be shown at this time")
            }
        }
    }
    func earnCoins(_ coins: NSInteger) {
        coinCount += coins
        print("Coins: \(self.coinCount)")
        self.manageRewardPoints()
    }
    func manageRewImage() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name("adMobRewImage"), object:self.strError )
        }
    }

    func manageRewardPoints() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name("RewardPoints"), object: self.coinCount)
        }
    }
}
extension MPRewardedCustomEvent : GADFullScreenContentDelegate {
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Rewarded ad will be presented.")
    }
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Rewarded ad dismissed.")
    }
    func ad(_ ad: GADFullScreenPresentingAd,didFailToPresentFullScreenContentWithError error: Error)
    {
        print("Rewarded ad failed to present with error: \(error.localizedDescription).")
    }
    func adDidRecordClick(_ ad: GADFullScreenPresentingAd) {
        self.webSc.trackingUrl(url: self.dict["click_url"] as! String)

    }
    func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {
        self.webSc.trackingUrl(url: self.dict["imp_url"] as! String)

    }
}
