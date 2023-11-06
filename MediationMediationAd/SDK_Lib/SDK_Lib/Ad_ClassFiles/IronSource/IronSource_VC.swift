//
//  IronSource.swift
//  SDK_Lib
//
//  Created by Djax on 26/05/23.
//

import UIKit
import IronSource
import ObjectiveC.runtime

class IronSource_VC: UIViewController {

    var levelBannerView = UIView()
    
    var bannerView: ISBannerView! = nil
    var kAPPKEY = "19e639475"
    var kAPPKEY_New = ""

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    func setupIronSourceSDK(view:UIView,fromStr:String,appkey:String) {
        self.levelBannerView = view
        self.levelBannerView.backgroundColor = UIColor.yellow
        self.kAPPKEY_New = appkey
        
        ISIntegrationHelper.validateIntegration()
        
        if fromStr == "Banner" {
            IronSource.setLevelPlayBannerDelegate(self)
        }
        else if fromStr == "InterstitialVideo" {
            IronSource.setLevelPlayInterstitialDelegate(self)
        }
        else if fromStr == "RewardedVideo" {
            IronSource.setLevelPlayRewardedVideoDelegate(self)
        }
        IronSource.add(self)
        IronSource.initWithAppKey(kAPPKEY)

        let BNSize: ISBannerSize = ISBannerSize(description: "BANNER",width:320 ,height:50)
        IronSource.loadBanner(with: self, size: BNSize)
        
//        self.bannerAction()
    }
}
extension IronSource_VC {
    func bannerAction() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            DispatchQueue.main.async {
                let BNSize: ISBannerSize = ISBannerSize(description: "BANNER",width:320 ,height:50)
                IronSource.loadBanner(with: self, size: BNSize)
            }
        }
    }
    func interstitialAction() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            DispatchQueue.main.async {
                IronSource.showInterstitial(with: self)
            }
        }
    }
    func rewardedAction() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            DispatchQueue.main.async {
                IronSource.showRewardedVideo(with: self)
            }
        }
    }
}
extension IronSource_VC :  ISImpressionDataDelegate {
    func impressionDataDidSucceed(_ impressionData: ISImpressionData!) {
        print("Impression data - \(impressionData.description)")
    }
}
extension IronSource_VC : LevelPlayBannerDelegate {
    func didLoad(_ bannerView: ISBannerView!, with adInfo: ISAdInfo!) {
        self.bannerView = bannerView
        self.levelBannerView.addSubview(self.bannerView)
    }
    func didFailToLoadWithError(_ error: Error!) {
        print("Banner ad error - \(error.localizedDescription)")
    }
    func didClick(with adInfo: ISAdInfo!) {
        print("Banner ad click - \(adInfo.description)")
    }
    func didLeaveApplication(with adInfo: ISAdInfo!) {
        print("Banner ad leave - \(adInfo.description)")
        if bannerView != nil {
            IronSource.destroyBanner(bannerView)
        }
    }
    func didPresentScreen(with adInfo: ISAdInfo!) {
        print("Banner ad Present - \(adInfo.description)")
    }
    func didDismissScreen(with adInfo: ISAdInfo!) {
        print("Banner ad dismiss - \(adInfo.description)")
        if bannerView != nil {
            IronSource.destroyBanner(bannerView)
        }
    }
}
extension IronSource_VC : LevelPlayInterstitialDelegate {
    func interstitialDidLoad() {
        print("Interstitial ad load")
    }
    
    func interstitialDidFailToLoadWithError(_ error: Error!) {
        print("Interstitial ad load - \(error.debugDescription)")
    }
    
    func interstitialDidOpen() {
        print("Interstitial ad open")
    }
    
    func interstitialDidClose() {
        print("Interstitial ad close")
    }
    
    func interstitialDidShow() {
        print("Interstitial ad did show")
    }
    
    func interstitialDidFailToShowWithError(_ error: Error!) {
        print("Interstitial ad error - \(error.debugDescription)")
    }
    
    func didClickInterstitial() {
        print("Interstitial ad Click")
    }
    
    func didLoad(with adInfo: ISAdInfo!) {
        print("Interstitial ad load - \(adInfo.description)")
    }
    func didOpen(with adInfo: ISAdInfo!) {
        print("Interstitial ad open - \(adInfo.description)")
    }
    func didShow(with adInfo: ISAdInfo!) {
        print("Interstitial ad show - \(adInfo.description)")
    }
    func didFailToShowWithError(_ error: Error!, andAdInfo adInfo: ISAdInfo!) {
        print("Interstitial ad error - \(error.debugDescription)")
    }
    func didClose(with adInfo: ISAdInfo!) {
        print("Interstitial ad close - \(adInfo.description)")
    }
}
extension IronSource_VC : LevelPlayRewardedVideoDelegate {
    func hasAvailableAd(with adInfo: ISAdInfo!) {
        
    }
    func hasNoAvailableAd() {
        
    }
    func didReceiveReward(forPlacement placementInfo: ISPlacementInfo!, with adInfo: ISAdInfo!) {
        
    }
    func didClick(_ placementInfo: ISPlacementInfo!, with adInfo: ISAdInfo!) {
        
    }
    func rewardedVideoHasChangedAvailability(_ available: Bool) {
        
    }
    func didReceiveReward(forPlacement placementInfo: ISPlacementInfo!) {
        
    }
    func rewardedVideoDidFailToShowWithError(_ error: Error!) {
        
    }
    func rewardedVideoDidOpen() {
        
    }
    func rewardedVideoDidClose() {
        
    }
    func rewardedVideoDidStart() {
        
    }
    func rewardedVideoDidEnd() {
        
    }
    func didClickRewardedVideo(_ placementInfo: ISPlacementInfo!) {
        
    }
}
