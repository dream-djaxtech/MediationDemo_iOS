//
//  Unity.swift
//  SDK_Lib
//
//  Created by Djax on 26/05/23.
//

import UIKit
import UnityAds

class Unity: UIViewController {
        
    var topBannerView: UADSBannerView?
    
    var bannerView1 = UIView()
    var dictResponse :[String:AnyObject] = [:]
    var froms:String? = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    func setupUnitySDK(view:UIView,fromStr:String,dict:[String:AnyObject]) {
        self.froms = fromStr
        self.dictResponse = dict
        self.bannerView1 = view
        self.bannerView1.backgroundColor = UIColor.brown

//        UnityAds.initialize( self.dictResponse["game_id"] as! String, testMode: Bool(self.dictResponse["testmode"] as! String) ?? true, initializationDelegate: self)
//        
//        if fromStr == "RewardedVideo" {
//            UnityAds.load( self.dictResponse["placement_id"] as! String, loadDelegate: self)
//        }
//        else if fromStr == "InterstitialVideo" {
//            UnityAds.load( self.dictResponse["placement_id"] as! String, loadDelegate: self)
//        }
//        else if fromStr == "Banner" {
//            self.initializationComplete()
//        }
    }
}
extension Unity {
    func loadBanner() {
        UnityAds.load( self.dictResponse["placement_id"] as! String, loadDelegate: self)
        self.topBannerView = UADSBannerView(placementId:  self.dictResponse["placement_id"] as! String, size: CGSize(width: 320, height: 50))
        self.topBannerView?.delegate = self
        self.addBannerViewToTopView(self.topBannerView!)
        self.topBannerView?.load()
    }
    func addBannerViewToTopView( _ view: UIView) {
        self.bannerView1.addSubview(view)
    }
    func loadRewarded() {
        UnityAds.show(self, placementId: self.dictResponse["placement_id"] as! String, showDelegate: self)
    }
}
extension Unity : UnityAdsInitializationDelegate {
    func initializationComplete() {
        if self.froms == "Banner" {
            self.loadBanner()
        }
    }
    func initializationFailed(_ error: UnityAdsInitializationError, withMessage message: String) {
        print(error)
        print(message)
    }
}
extension Unity : UnityAdsLoadDelegate {
    func unityAdsAdLoaded(_ placementId: String) {}
    func unityAdsAdFailed(toLoad placementId: String, withError error: UnityAdsLoadError, withMessage message: String) {
        print(message)
        print(error)
        
    }
}
extension Unity : UnityAdsShowDelegate {
    func unityAdsShowComplete(_ placementId: String, withFinish state: UnityAdsShowCompletionState) {
        print(state)
    }
    func unityAdsShowFailed(_ placementId: String, withError error: UnityAdsShowError, withMessage message: String) {
        print(message)
        print(error)
    }
    func unityAdsShowStart(_ placementId: String) {}
    func unityAdsShowClick(_ placementId: String) {}
}
extension Unity : UADSBannerViewDelegate {
    func bannerViewDidLoad(_ bannerView: UADSBannerView!) {}
    func bannerViewDidClick(_ bannerView: UADSBannerView!) {}
    func bannerViewDidError(_ bannerView: UADSBannerView!, error: UADSBannerError!) {
        print(error!)
    }
    func bannerViewDidLeaveApplication(_ bannerView: UADSBannerView!) {}
}
