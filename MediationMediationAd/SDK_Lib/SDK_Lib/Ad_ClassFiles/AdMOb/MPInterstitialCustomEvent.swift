//
//  MPInterstitialCustomEvent.swift
//  SDK_Lib
//
//  Created by Djax on 11/10/22.
//

import UIKit
import GoogleMobileAds

@objc(MPGoogleAdMobInterstitialCustomEvent)
class MPInterstitialCustomEvent: UIViewController {
    
    let webSc = WebService()

    var interstitial: GADInterstitialAd?
    
    var strError:String? = ""
    var dict:[String:AnyObject] = [:]
    
    func loadInterstitial(vc:UIViewController,adUnit:String,fromStr:String,zone:String,dictR:[String:AnyObject]) {
        dict = dictR
        let request = GADRequest()
        GADInterstitialAd.load(
            withAdUnitID: adUnit, request: request
        ) { (ad, error) in
            if let error = error {
                print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                if error.localizedDescription == "Cannot determine request type. Is your ad unit id correct?" || error.localizedDescription == "Ad unit doesn't match format. <https://support.google.com/admob/answer/9905175#4>" {
                    self.strError = error.localizedDescription
                    self.manageIntImage()
                }
               
                return
            }
            self.interstitial = ad
            self.interstitial?.fullScreenContentDelegate = self
            
            if let ad = self.interstitial {
                self.webSc.trackingUrl(url: self.dict["request_url"] as! String)
                ad.present(fromRootViewController: vc)
            }
            else {
                print("Ad wasn't ready")
            }
        }
    }
    func manageIntImage() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name("adMobIntImage"), object:self.strError )
        }
    }
}
extension MPInterstitialCustomEvent : GADFullScreenContentDelegate {
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad will present full screen content.")
//        self.webSc.trackingUrl(url: self.dict["imp_url"] as! String)
    }
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error)
    {
        print("Ad failed to present full screen content with error \(error.localizedDescription).")
    }
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did dismiss full screen content.")
    }
    func adDidRecordClick(_ ad: GADFullScreenPresentingAd) {
        self.webSc.trackingUrl(url: self.dict["click_url"] as! String)

    }
    func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {
        self.webSc.trackingUrl(url: self.dict["imp_url"] as! String)

    }
}
