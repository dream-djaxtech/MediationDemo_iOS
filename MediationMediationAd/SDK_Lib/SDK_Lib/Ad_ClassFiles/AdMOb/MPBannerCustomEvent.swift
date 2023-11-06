//
//  BannerCustomEvent.swift
//  SDK_Lib
//
//  Created by Djax on 04/10/22.
//

import UIKit
import GoogleMobileAds

@objc(MPGoogleAdMobBannerCustomEvent)
class MPBannerCustomEvent: UIViewController {
    
    var adBannerView = GADBannerView()
    var adSize_ = CGSize()
    var strError:String? = ""
    var dict:[String:AnyObject] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    func create_Basic_ad(size: String, adUnit: String?) -> GADBannerView
    {
//        let sizeArr = size.components(separatedBy: "x")

        self.adBannerView = GADBannerView(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        self.adBannerView.adUnitID = adUnit
        self.adBannerView.rootViewController = self
        self.adBannerView.delegate = self
        self.adBannerView.load(GADRequest())
        return self.adBannerView
    }
}
extension MPBannerCustomEvent : GADBannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("bannerViewDidReceiveAd")
        let receivedWidth = bannerView.adSize.size.width
        let receivedHeight = bannerView.adSize.size.height
       
        if receivedWidth > adSize_.width || receivedHeight > adSize_.height
        {
//            let failureReason = String(format: "Google served an ad but it was invalidated because its size of %.0f x %.0f exceeds the publisher-specified size of %.0f x %.0f", receivedWidth, receivedHeight, adSize_.width, adSize_.height)
//            let error = NSError(domain: "Admon banner", code: 101, userInfo: [NSLocalizedDescriptionKey : failureReason])
//            print(error)
        }
        else {
            print("did load ad")
            self.bannerViewDidReceiveAd(adBannerView)
        }
    }
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        print("bannerView:didFailToReceiveAdWithError: \(error.localizedDescription)")
        self.strError = error.localizedDescription
        self.manageBanner()
    }
    func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
        print("bannerViewDidRecordImpression")
    }
    func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("bannerViewWillPresentScreen")
    }
    func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("bannerViewWillDIsmissScreen")
    }
    func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("bannerViewDidDismissScreen")
    }
    func manageBanner() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name("admobBannerImage"), object: self.strError)
        }
    }
}
