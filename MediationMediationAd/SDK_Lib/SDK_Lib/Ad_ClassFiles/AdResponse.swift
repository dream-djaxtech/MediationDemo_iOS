//
//  AdResponse.swift
//  SDK_Lib
//
//  Created by Djax on 15/04/23.
//

import UIKit
import WebKit
import AdColony
import StoreKit
import ChartboostSDK
import UnityAds
import IronSource
import Foundation
import ObjectiveC.runtime
import GoogleMobileAds

public protocol RewardUpdateDelegate: AnyObject {
    func passAPIvalues(point:NSInteger)
}
public protocol WebViewUpdateDelegate: AnyObject {
    func updateMediationWebView(webV:GADBannerView)
    func updateWebView(webV:WKWebView)
}


public class AdResponse: UIViewController {
    
    var api_call = APICall()
    var chartBoost = ChartBoost()
    var ironSource = IronSource_VC()
    var unity = Unity()
    var adColony = AdColonyVc()
    let webSc = WebService()
    var basic_ad = BasicAd()
    
    var admobBannerView = GADBannerView()
    var admobInterstitial: GADInterstitialAd?
    var admobRewardedAd: GADRewardedAd?
    var coinCount = 0
    
    var topBannerView: UADSBannerView?
    var bannerIronSourceView: ISBannerView! = nil
   
    private lazy var bannerChartboost = CHBBanner(size: CHBBannerSizeStandard, location: "default", delegate: self)
    private lazy var interstitial = CHBInterstitial(location: "default", delegate: self)
    private lazy var rewarded = CHBRewarded(location: "default", delegate: self)
   
    weak var adColonyBanner: AdColonyAdView? = nil //Banner
    var adInterstitial: AdColonyInterstitial? = nil //Interstitial
    
    var webView = WKWebView()
    var adView = UIView()
    var adSize_ = CGSize()
    var adBtn = UIButton()
    
    var adRespon:String? = ""
    
    var adType:String? = ""
    var zoneId:String? = ""
    var kAPPKEY_New:String? = ""
    var rewardedLayout:String? = ""
    var interstitialLayout:String? = ""
    var bannerHeight:String? = ""
    var bannerWidth:String? = ""
    var HTMLHeight:String? = ""
    var HTMLWidth:String? = ""
    var HTML5Height:String? = ""
    
    var adNetworkType:String? = ""

    var selectedMediationIndex:Int? = 0
    var zoneArrayCount:Int? = 0
    
    var currentResponseArrayList : Array<AnyObject> = Array()
    var ZoneArrayList : Array<AnyObject> = Array()
    
    var apiResponse : Dictionary<String,AnyObject> = [:]
    var totalRewardPoints : Dictionary<String,AnyObject> = [:]
    var rewardPoints : Array<Dictionary<String,AnyObject>> = []
    var adDictResponse :[String:AnyObject] = [:]
    var dictResponse :[String:AnyObject] = [:]
    
    public weak var rewardDelegate: RewardUpdateDelegate?
    public weak var webViewDelegate: WebViewUpdateDelegate?
    
    var bannerCustomEvent = MPBannerCustomEvent()
    var interstitialCustomEvent = MPInterstitialCustomEvent()
    var rewardedCustomEvent = MPRewardedCustomEvent()
    
    
    func SDK_Initialize() {
        Swift.print(sdkInitialize)
        //api_call.getLocation()
    }
}
//MARK: User default and API Call
extension AdResponse {
    public func getUserDefaultValue(zones:String, str:String) {
        self.zoneId = zones
        if str == "SDK" {
            self.clearData()
        }
        if UserDefaults.standard.value(forKey:"apiResponse") == nil {
            self.clearData()
            self.SDK_Initialize()
            api_call.delegate_API = self
            api_call.callApiMethods(zone: zones)
        }
        else {
            self.currentResponseArrayList.removeAll()
            let recovedUserJsonData = UserDefaults.standard.object(forKey: "apiResponse")
            let recovedUserJson = NSKeyedUnarchiver.unarchiveObject(with: recovedUserJsonData as! Data)
            apiResponse = recovedUserJson as! Dictionary<String, AnyObject>
            if apiResponse["response"] as! String == Success {
                currentResponseArrayList = apiResponse["ads"] as! Array<AnyObject>
                self.adTypeUserdefault()
            }
            else {
                Swift.print(Error_Invalid_Request)
            }
        }
    }
    func clearData() {
        UserDefaults.standard.removeObject(forKey: "apiResponse")
        UserDefaults.standard.removeObject(forKey: "BannerResponse")
        UserDefaults.standard.removeObject(forKey: "InterstitialImageResponse")
        UserDefaults.standard.removeObject(forKey: "RewardedResponse")
        UserDefaults.standard.removeObject(forKey: "InterstitialVideoResponse")
//        UserDefaults.standard.removeObject(forKey: "isAdtype")
    }
    func adTypeUserdefault() {
        print(self.currentResponseArrayList)
        if self.currentResponseArrayList.count != 0 {
            for it in 0 ..< self.currentResponseArrayList.count {
                let dict = self.currentResponseArrayList[it] as! Dictionary<String,AnyObject>
                if dict["response"] as? String == Success {
                    self.adType = dict["ad_type"] as? String
                    if self.adType == AdType_Internal_Banner
                    {
                        UserDefaults.standard.removeObject(forKey: "BannerResponse")
                        let data = NSKeyedArchiver.archivedData(withRootObject: dict)
                        UserDefaults.standard.set(data, forKey: "BannerResponse")
                        if dict["ad_network"] as! String == AdType_Internal_Network {
                            if dict["response"] as! String == Success {
                                if UserDefaults.standard.string(forKey: "isAdtype") == "Success" {
                                    self.imageAdIntegration(fromStr: "", view: self.adView, webV: self.webView)
                                }
                            }
                        }
                    }
                    else if self.adType == AdType_Internal_InterstitialImage
                    {
                        UserDefaults.standard.removeObject(forKey: "InterstitialImageResponse")
                        let data = NSKeyedArchiver.archivedData(withRootObject: dict)
                        UserDefaults.standard.set(data, forKey: "InterstitialImageResponse")
                        if dict["ad_network"] as! String == AdType_Internal_Network {
                            if dict["response"] as! String == Success {
                                if dict["ad_check"] as! Int == 0 {
                                    print("No ad to show")
                                }
                                else {
                                    if UserDefaults.standard.string(forKey: "isAdtype") == "Success" {
                                        interstitialImageAdIntegration()
                                    }
                                }
                            }
                        }
                    }
                    else if self.adType == AdType_Internal_RewardedVideo
                    {
                        UserDefaults.standard.removeObject(forKey: "RewardedResponse")
                        let data = NSKeyedArchiver.archivedData(withRootObject: dict)
                        UserDefaults.standard.set(data, forKey: "RewardedResponse")
                        if dict["ad_network"] as! String == AdType_Internal_Network {
                            if dict["response"] as! String == Success {
                                if dict["ad_check"] as! Int == 0 {
                                    print("No ad to show")
                                }
                                else {
                                    if UserDefaults.standard.string(forKey: "isAdtype") == "Success" {
                                        rewardedAdIntegration()
                                    }
                                }
                            }
                        }
                    }
                    else if self.adType == AdType_Internal_InterstitialVideo
                    {
                        UserDefaults.standard.removeObject(forKey: "InterstitialVideoResponse")
                        let data = NSKeyedArchiver.archivedData(withRootObject: dict)
                        UserDefaults.standard.set(data, forKey: "InterstitialVideoResponse")
                        if dict["ad_network"] as! String == AdType_Internal_Network {
                            if dict["response"] as! String == Success {
                                if dict["ad_check"] as! Int == 0 {
                                    print("No ad to show")
                                }
                                else {
                                    if UserDefaults.standard.string(forKey: "isAdtype") == "Success" {
                                        interstitialVideoAdIntegration()
                                    }
                                }
                            }
                        }
                    }
                }
                else if dict["response"] as? String == Error {
                    print("Invalid Request Failed")
                    print("Error - \(dict["error"]?["description"]! ?? "Target Failed")")
                    if UserDefaults.standard.object(forKey: "isAdtype") as! Int == 0 {
                        print("First time called")
                        UserDefaults.standard.set(2, forKey: "isAdtype")
                        self.getUserDefaultValue(zones: self.zoneId ?? "", str: "SDK")
                    }
                    else {
                        print("Second time called")
                    }
                }
            }
        }
    }
    func dummyDataResponse() {
        self.selectedMediationIndex = 0
        if self.currentResponseArrayList.count != 0 {
            for it in 0 ..< self.currentResponseArrayList.count {
                let dict = self.currentResponseArrayList[it] as! Dictionary<String,AnyObject>
                if dict["response"] as? String == Success {
                    self.adType = dict["ad_type"] as? String
                    //Mediation
                    if dict["ad_network"] as! String == AdType_Mediation_Network {
                        if self.adType == AdType_Internal_Banner
                        {
                            print(dict)
                            UserDefaults.standard.removeObject(forKey: "BannerResponse")
                            let data = NSKeyedArchiver.archivedData(withRootObject: dict)
                            UserDefaults.standard.set(data, forKey: "BannerResponse")
                        }
                        else if self.adType == AdType_Internal_InterstitialImage
                        {
                            UserDefaults.standard.removeObject(forKey: "InterstitialImageResponse")
                            let data = NSKeyedArchiver.archivedData(withRootObject: dict)
                            UserDefaults.standard.set(data, forKey: "InterstitialImageResponse")
                          
                        }
                        else if self.adType == AdType_Internal_RewardedVideo
                        {
                            UserDefaults.standard.removeObject(forKey: "RewardedResponse")
                            let data = NSKeyedArchiver.archivedData(withRootObject: dict)
                            UserDefaults.standard.set(data, forKey: "RewardedResponse")
                           
                        }
                        else if self.adType == AdType_Internal_InterstitialVideo
                        {
                            UserDefaults.standard.removeObject(forKey: "InterstitialVideoResponse")
                            let data = NSKeyedArchiver.archivedData(withRootObject: dict)
                            UserDefaults.standard.set(data, forKey: "InterstitialVideoResponse")
                            
                        }
                    }
                    //Internal
                    else if dict["ad_network"] as! String == AdType_Internal_Network {
                        if self.adType == AdType_Internal_Banner
                        {
                            UserDefaults.standard.removeObject(forKey: "BannerResponse")
                            let data = NSKeyedArchiver.archivedData(withRootObject: dict)
                            UserDefaults.standard.set(data, forKey: "BannerResponse")
                            
                        }
                        else if self.adType == AdType_Internal_InterstitialImage
                        {
                            UserDefaults.standard.removeObject(forKey: "InterstitialImageResponse")
                            let data = NSKeyedArchiver.archivedData(withRootObject: dict)
                            UserDefaults.standard.set(data, forKey: "InterstitialImageResponse")
                        }
                        else if self.adType == AdType_Internal_RewardedVideo
                        {
                            //                            UserDefaults.standard.removeObject(forKey: "RewardedVideoAd")
                            self.rewardedLayout = dict["layout"] as? String
                            self.totalRewardPoints = (dict["ad_values"] as AnyObject) as! Dictionary<String, AnyObject>
                            UserDefaults.standard.removeObject(forKey: "RewardedResponse")
                            let data = NSKeyedArchiver.archivedData(withRootObject: dict)
                            UserDefaults.standard.set(data, forKey: "RewardedResponse")
                        }
                        else if self.adType == AdType_Internal_InterstitialVideo
                        {
                            self.interstitialLayout = ""
                            
                            self.interstitialLayout = dict["layout"] as? String
                            
                            UserDefaults.standard.removeObject(forKey: "InterstitialVideoResponse")
                            let data = NSKeyedArchiver.archivedData(withRootObject: dict)
                            UserDefaults.standard.set(data, forKey: "InterstitialVideoResponse")
                        }
                    }
                }
                else if dict["response"] as? String == Error {
                    print("Invalid Request Failed")
                    print("Error - \(dict["error"]?["description"]! ?? "Target Failed")")
                    if UserDefaults.standard.object(forKey: "isAdtype") as! Int == 0 {
                        print("First time called")
                        UserDefaults.standard.set(2, forKey: "isAdtype")
                        self.getUserDefaultValue(zones: self.zoneId ?? "", str: "SDK")
                    }
                    else {
                        print("Second time called")
                    }
                }
            }
        }
    }
}
extension AdResponse {
    @objc func methodOfReceivedNotification(notification: Notification) {
        print("Value of notification : ", notification.object ?? "")
        //        self.rewardDelegate?.passAPIvalues(point: notification.object as! NSInteger)
    }
    @objc func admobIntImage(notification:Notification) {
        UserDefaults.standard.set(1, forKey: "isAdtype")
        if self.zoneArrayCount == self.selectedMediationIndex {
            self.getUserDefaultValue(zones: UserDefaults.standard.object(forKey: "adMobIntId") as! String, str: "SDK")
        }
        else { }
    }
    @objc func admobRewImage(notification:Notification) {
        UserDefaults.standard.set(1, forKey: "isAdtype")
        if self.zoneArrayCount == self.selectedMediationIndex {
            self.getUserDefaultValue(zones: UserDefaults.standard.object(forKey: "adMobIntId") as! String, str: "SDK")
        }
        else { }
    }
    @objc func adColnyRewVideo(notification:Notification) {
        UserDefaults.standard.set(1, forKey: "isAdtype")
        if self.zoneArrayCount == self.selectedMediationIndex {
            self.getUserDefaultValue(zones: UserDefaults.standard.object(forKey: "adColonyRewId") as! String, str: "SDK")
        }
        else { }
    }
    @objc func adColnyIntVideo(notification:Notification) {
        UserDefaults.standard.set(1, forKey: "isAdtype")
        if self.zoneArrayCount == self.selectedMediationIndex {
            self.getUserDefaultValue(zones: UserDefaults.standard.object(forKey: "adColonyIntId") as! String, str: "SDK")
        }
        else { }
    }
    @objc func admobBannerImage(notification:Notification) {
        UserDefaults.standard.set(1, forKey: "isAdtype")
        if self.zoneArrayCount == self.selectedMediationIndex {
            self.getUserDefaultValue(zones: UserDefaults.standard.object(forKey: "adMobBannerId") as! String, str: "SDK")
        }
        else { }
    }
    @objc func chartBoostIntVideo(notification:Notification)
    {
        UserDefaults.standard.set(1, forKey: "isAdtype")
        if self.zoneArrayCount == self.selectedMediationIndex {
            self.getUserDefaultValue(zones: UserDefaults.standard.object(forKey: "chartBoostIntId") as! String, str: "SDK")
        }
        else { }
    }
    @objc func chartBoostRewVideo(notification:Notification)
    {
        UserDefaults.standard.set(1, forKey: "isAdtype")
        if self.zoneArrayCount == self.selectedMediationIndex {
            self.getUserDefaultValue(zones: UserDefaults.standard.object(forKey: "chartBoostRewId") as! String, str: "SDK")
        }
        else { }
    }
}
//MARK: Delegate methods
extension AdResponse : RewardUpdateDelegate {
    public func passAPIvalues(point: NSInteger) {}
}
//MARK: Based on the ad type calling API's
extension AdResponse {
    //image ad method2 call
    public func imageAdIntegration(fromStr:String,view:UIView,webV:WKWebView)
    {
        var dict : Dictionary<String,AnyObject> = [:]
        if UserDefaults.standard.object(forKey: "BannerResponse") == nil {}
        else {
            let outData = UserDefaults.standard.data(forKey: "BannerResponse")
            dict = (NSKeyedUnarchiver.unarchiveObject(with: outData!) as! NSDictionary) as! Dictionary<String, AnyObject>
        }
        print(dict)
        if dict.count != 0  {
            if dict["response"] as! String == Success {
                if dict["ad_network"] as! String == AdType_Internal_Network {
                    //                    if dict["ad_check"] as! Int == 0 {
                    //                        print("No ad to show")
                    //                    }
                    //                    else {
                    DispatchQueue.main.async {
                        self.webViewDelegate?.updateWebView(webV:  self.basic_ad.html_update_method2(str: dict["ad_tag"] as! String, width: Int(dict["width"] as! String) ?? 0, height: Int(dict["height"] as! String) ?? 0 , fromStr: "Banner"))
                    }
                    //                    }
                }
                else if dict["ad_network"] as! String == AdType_Mediation_Network
                {
                    self.zoneId = dict["zoneid"] as? String
                    var dict1:[String:AnyObject] = [:]
                    self.ZoneArrayList = dict["zoneidList"] as! Array<AnyObject>
                    
                    if self.ZoneArrayList.count > 0 {
                        self.zoneArrayCount = self.ZoneArrayList.count
                        print(self.zoneArrayCount)
                        print(self.selectedMediationIndex)
                        
                        if self.selectedMediationIndex != self.zoneArrayCount {
                        if self.selectedMediationIndex == 0 {
                            dict1 = self.ZoneArrayList[self.selectedMediationIndex ?? -1] as! [String : AnyObject]
                        }
                        else if self.selectedMediationIndex! > 0 {
                            dict1 = self.ZoneArrayList[self.selectedMediationIndex ?? -1] as! [String : AnyObject]
                        }
                        webSc.trackingUrl(url: dict1["request_url"] as! String)
                            self.adView = view
                            self.webView = webV
                        if dict1["ad_network_type"] as! String == AdType_Internal_Admob {
                            self.webViewDelegate?.updateMediationWebView(webV: self.create_Basic_ad(size:"", adUnit: (dict1["ad_tag"]?["adunit"])! as? String ?? "", dict: dict1))
                            NotificationCenter.default.addObserver(self, selector: #selector(self.admobBannerImage(notification:)), name: Notification.Name("admobBannerImage"), object: nil)
                        }
                        else if dict1["ad_network_type"] as! String == AdType_Internal_Unity {
                            UserDefaults.standard.set(true, forKey: "UBanner")
                            self.setupUnitySDK(view: view,fromStr: "Banner",dict: dict1 , zone: dict["zoneid"] as? String ?? "")
                        }
                        else if dict1["ad_network_type"] as! String == AdType_Internal_IronSource {
                            self.kAPPKEY_New = dict1["ad_tag"]?["app_id"] as? String
                            UserDefaults.standard.set(true, forKey: "ISBanner")
                            self.setupIronSourceSDK(view: view,fromStr:"Banner",appkey: dict1["ad_tag"]?["app_id"] as! String, zone: dict["zoneid"] as? String ?? "",dict: dict1)
                        }
                        else if dict1["ad_network_type"] as! String == AdType_Internal_ChartBoost {
                            self.setupChartBoostSDK(view: view,fromStr: "Banner",dict:  dict1, zone: dict["zoneid"] as? String ?? "")
                        }
                        else if dict1["ad_network_type"] as! String == AdType_Internal_AdColony {
                            self.setupAdcolonySDK(view: view, fromStr: "Banner",dict: dict1, zone: dict["zoneid"] as? String ?? "")
                        }
                    }
                        else {
                            print("array values smae")
                        }
                    }
                    else {
                        print("Zonelist array empty")
                    }
                }
            }
            else if dict["response"] as? String == Error {
                print("Error - \(dict["error"]?["description"]! ?? "Target Failed")")
            }
        }
    }
    //interstitial image ad method
    public func interstitialImageAdIntegration()
    {
        var dict : Dictionary<String,AnyObject> = [:]
        if UserDefaults.standard.object(forKey: "InterstitialImageResponse") == nil { }
        else {
            let outData =
            UserDefaults.standard.data(forKey: "InterstitialImageResponse")
            dict = (NSKeyedUnarchiver.unarchiveObject(with: outData!) as! NSDictionary) as! Dictionary<String, AnyObject>
        }
        print(dict)
        if dict.count != 0  {
            if dict["response"] as! String == Success {
                if dict["ad_network"] as! String == AdType_Internal_Network {
                    //                    if dict["ad_check"] as! Int == 0 {
                    //                        print("No ad to show")
                    //                    }
                    //                    else {
                    DispatchQueue.main.async {
                        self.levelDidEnd(vc:"InterstitialImage", adTag: dict["ad_tag"] as! String, layout: "")
                    }
                    //                    }
                }
                else if dict["ad_network"] as! String == AdType_Mediation_Network
                {
                    self.zoneId = dict["zoneid"] as? String
                    var dict1:[String:AnyObject] = [:]
                    self.ZoneArrayList = dict["zoneidList"] as! Array<AnyObject>
                    if self.ZoneArrayList.count > 0 {
                        self.zoneArrayCount = self.ZoneArrayList.count
                        if self.selectedMediationIndex == 0 {
                            dict1 = self.ZoneArrayList[self.selectedMediationIndex ?? -1] as! [String : AnyObject]
                        }
                        else if self.selectedMediationIndex! > 0 {
                            dict1 = self.ZoneArrayList[self.selectedMediationIndex ?? -1] as! [String : AnyObject]
                        }
                        webSc.trackingUrl(url: dict1["request_url"] as! String)
                        if dict1["ad_network_type"] as! String == AdType_Internal_Admob {
                            UserDefaults.standard.set(dict["zoneid"], forKey: "adMobIntId")
                            self.zoneId = dict["zoneid"] as? String
                            let object = MPInterstitialCustomEvent.init()
                            self.interstitialCustomEvent = object
                            
                            self.interstitialCustomEvent.loadInterstitial(vc: self.getCurrentViewController() as! UIViewController, adUnit: (dict1["ad_tag"]?["adunit"])! as? String ?? "", fromStr:  dict1["ad_network_type"] as! String, zone: (dict["zoneid"])! as? String ?? "",dictR: dict1)
                            NotificationCenter.default.addObserver(self, selector: #selector(self.admobIntImage(notification:)), name: Notification.Name("adMobIntImage"), object: nil)
                        }
                    }
                    else {
                        print("Zonelist array empty")
                    }
                }
            }
            else if dict["response"] as? String == Error {
                print("Error - \(dict["error"]?["description"]! ?? "Target Failed")")
            }
        }
    }
    
    //interstitial video ad method
    public func interstitialVideoAdIntegration()
    {
        var dict : Dictionary<String,AnyObject> = [:]
        if UserDefaults.standard.object(forKey: "InterstitialVideoResponse") == nil { }
        else {
            let outData = UserDefaults.standard.data(forKey: "InterstitialVideoResponse")
            dict = (NSKeyedUnarchiver.unarchiveObject(with: outData!) as! NSDictionary) as! Dictionary<String, AnyObject>
        }
        if dict.count != 0  {
            if dict["response"] as! String == Success {
                if dict["ad_network"] as! String == AdType_Internal_Network {
                    //                    if dict["ad_check"] as! Int == 0 {
                    //                        print("No ad to show")
                    //                    }
                    //                    else {
                    self.adDictResponse = dict
                    DispatchQueue.main.async {
                        self.levelDidEnd(vc:"InterstitialVideo", adTag: dict["ad_tag"] as! String ,layout:dict["layout"] as! String)
                    }
                    //                    }
                }
                else if dict["ad_network"] as! String == AdType_Mediation_Network
                {
                    self.adNetworkType = dict["ad_network"] as? String

                    self.zoneId = dict["zoneid"] as? String
                    var dict1:[String:AnyObject] = [:]
                    self.ZoneArrayList = dict["zoneidList"] as! Array<AnyObject>
                    
                    if self.ZoneArrayList.count > 0 {
                        self.zoneArrayCount = self.ZoneArrayList.count
                        
                        if self.selectedMediationIndex == 0 {
                            dict1 = self.ZoneArrayList[self.selectedMediationIndex ?? -1] as! [String : AnyObject]
                        }
                        else if self.selectedMediationIndex! > 0 {
                            dict1 = self.ZoneArrayList[self.selectedMediationIndex ?? -1] as! [String : AnyObject]
                        }
                        self.adDictResponse = dict1

                        webSc.trackingUrl(url: dict1["request_url"] as! String)
                        if dict1["ad_network_type"] as! String == AdType_Internal_Admob {
                            UserDefaults.standard.set(dict["zoneid"], forKey: "adMobIntId")
                            self.zoneId = dict["zoneid"] as? String
                            let object = MPInterstitialCustomEvent.init()
                            self.interstitialCustomEvent = object
                            self.interstitialCustomEvent.loadInterstitial(vc: self.getCurrentViewController() as! UIViewController, adUnit: (dict1["ad_tag"]?["adunit"])! as? String ?? "", fromStr:  dict1["ad_network_type"] as! String, zone: (dict["zoneid"])! as? String ?? "",dictR: dict1)
                            NotificationCenter.default.addObserver(self, selector: #selector(self.admobIntImage(notification:)), name: Notification.Name("adMobIntImage"), object: nil)
                        }
                        else if dict1["ad_network_type"] as! String == AdType_Internal_Unity {
                            self.setupUnitySDK(view: view,fromStr: "InterstitialVideo",dict: dict1, zone: dict["zoneid"] as? String ?? "")
                        }
                        else if dict1["ad_network_type"] as! String == AdType_Internal_IronSource {
                            self.kAPPKEY_New = dict1["ad_tag"]?["app_id"] as? String
                            UserDefaults.standard.set(true, forKey: "ISBanner")
                            self.setupIronSourceSDK(view: view,fromStr:"InterstitialVideo",appkey: dict1["ad_tag"]?["app_id"] as! String, zone: dict["zoneid"] as? String ?? "",dict: dict1)
                        }
                        else if dict1["ad_network_type"] as! String == AdType_Internal_ChartBoost {
                            UserDefaults.standard.set(dict["zoneid"], forKey: "chartBoostIntId")

                            self.setupChartBoostSDK(view: view,fromStr: "InterstitialVideo",dict:  dict1, zone: dict["zoneid"] as? String ?? "")
                            NotificationCenter.default.addObserver(self, selector: #selector(self.chartBoostIntVideo(notification:)), name: Notification.Name("chartBoostIntVideo"), object: nil)

                        }
                        else if dict1["ad_network_type"] as! String == AdType_Internal_AdColony {
                            self.setupAdcolonySDK(view: view, fromStr: "InterstitialVideo",dict: dict1, zone: dict["zoneid"] as? String ?? "")
                        }
                        if dict1["ad_network_type"] as! String != AdType_Internal_Admob {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute:   {
                                self.levelDidEnd(vc: "InterstitialVideo", adTag: "", layout: "")
                            })
                        }
                    }
                    else {
                        print("Zonelist array empty")
                    }
                }
            }
            else if dict["response"] as? String == Error {
                print("Error - \(dict["error"]?["description"]! ?? "Target Failed")")
            }
        }
    }
    //rewarded video ad method
    public func rewardedAdIntegration()
    {
        var dict : Dictionary<String,AnyObject> = [:]
        if UserDefaults.standard.object(forKey: "RewardedResponse") == nil { }
        else {
            let outData = UserDefaults.standard.data(forKey: "RewardedResponse")
            dict = (NSKeyedUnarchiver.unarchiveObject(with: outData!) as! NSDictionary) as! Dictionary<String, AnyObject>
        }
        if dict.count != 0  {
            if dict["response"] as! String == Success {
                if dict["ad_network"] as! String == AdType_Internal_Network {
                    //                    if dict["ad_check"] as! Int == 0 {
                    //                        print("No ad to show")
                    //                    }
                    //                    else {
                    self.adDictResponse = dict
                    
                    DispatchQueue.main.async {
                        self.levelDidEnd(vc:"RewardedVideo", adTag: dict["ad_tag"] as! String ,layout:dict["layout"] as! String)
                    }
                    //                    }
                }
                else if dict["ad_network"] as! String == AdType_Mediation_Network
                {
                    self.adNetworkType = dict["ad_network"] as? String
                    self.zoneId = dict["zoneid"] as? String
                    var dict1:[String:AnyObject] = [:]
                    self.ZoneArrayList = dict["zoneidList"] as! Array<AnyObject>
                    
                    if self.ZoneArrayList.count > 0 {
                        self.zoneArrayCount = self.ZoneArrayList.count
                        
                        if self.selectedMediationIndex == 0 {
                            dict1 = self.ZoneArrayList[self.selectedMediationIndex ?? -1] as! [String : AnyObject]
                        }
                        else if self.selectedMediationIndex! > 0 {
                            dict1 = self.ZoneArrayList[self.selectedMediationIndex ?? -1] as! [String : AnyObject]
                        }
                        self.adDictResponse = dict1
                        webSc.trackingUrl(url: dict1["request_url"] as! String)
                        if dict1["ad_network_type"] as! String == AdType_Internal_Admob {
                            UserDefaults.standard.set(dict["zoneid"], forKey: "adMobIntId")
                            self.zoneId = dict["zoneid"] as? String
                            let object = MPRewardedCustomEvent.init()
                            self.rewardedCustomEvent = object
                            self.rewardedCustomEvent.loadInterstitial(vc: self.getCurrentViewController() as! UIViewController, adUnit: ((dict1["ad_tag"]?["adunit"])! as? String) ?? "",zone: dict["zoneid"] as? String ?? "", dictR: dict1)
                            NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name("RewardPoints"), object: nil)
                            NotificationCenter.default.addObserver(self, selector: #selector(self.admobRewImage(notification:)), name: Notification.Name("adMobRewImage"), object: nil)
                        }
                        else if dict1["ad_network_type"] as! String == AdType_Internal_Unity {
                            self.setupUnitySDK(view: view,fromStr: "RewardedVideo",dict: dict1, zone: dict["zoneid"] as? String ?? "")
                        }
                        else if dict1["ad_network_type"] as! String == AdType_Internal_IronSource {
                            self.kAPPKEY_New = dict1["ad_tag"]?["app_id"] as? String
                            UserDefaults.standard.set(true, forKey: "ISBanner")
                            self.setupIronSourceSDK(view: view,fromStr:"RewardedVideo",appkey: dict1["ad_tag"]?["app_id"] as! String, zone: dict["zoneid"] as? String ?? "",dict: dict1)
                        }
                        else if dict1["ad_network_type"] as! String == AdType_Internal_ChartBoost {
                            self.setupChartBoostSDK(view: view,fromStr: "RewardedVideo",dict:  dict1, zone: dict["zoneid"] as? String ?? "")
                            NotificationCenter.default.addObserver(self, selector: #selector(self.chartBoostRewVideo(notification:)), name: Notification.Name("chartBoostRewVideo"), object: nil)
                            UserDefaults.standard.set(dict["zoneid"], forKey: "chartBoostRewId")

                        }
                        else if dict1["ad_network_type"] as! String == AdType_Internal_AdColony {
                            self.setupAdcolonySDK(view: view, fromStr: "RewardedVideo",dict: dict1, zone: dict["zoneid"] as? String ?? "")
                        }
                        if dict1["ad_network_type"] as! String != AdType_Internal_Admob {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute:   {
                                self.levelDidEnd(vc: "RewardedVideo", adTag: "", layout: "")
                            })
                        }
                    }
                    else {
                        print("Zonelist array empty")
                    }
                }
            }
        }
        //        if dict.count != 0  {
        //            if dict["ad_network"] as! String == AdType_Internal_Network {
        //                if dict["response"] as! String == Success {
        //                    self.adDictResponse = dict
        ////                    if dict["ad_check"] as! Int == 0 {
        ////                        print("No ad to show")
        ////                    }
        ////                    else {
        //                        DispatchQueue.main.async {
        //                            self.levelDidEnd(vc:"RewardedVideo", adTag: dict["ad_tag"] as! String ,layout:dict["layout"] as! String)
        //                        }
        ////                    }
        //                }
        //            }
        //            else if dict["ad_network"] as! String == AdType_Mediation_Network
        //            {
        //                if dict["response"] as! String == Success {
        //                    self.adDictResponse = dict
        //                    self.zoneId = dict["zoneid"] as? String
        //                    webSc.trackingUrl(url: dict["request_url"] as! String)
        //                    if dict["ad_network_type"] as! String == AdType_Internal_Admob {
        //
        //                        UserDefaults.standard.set(dict["zoneid"], forKey: "adMobIntId")
        //                        self.zoneId = dict["zoneid"] as? String
        //                        let object = MPRewardedCustomEvent.init()
        //                        self.rewardedCustomEvent = object
        //                        self.rewardedCustomEvent.loadInterstitial(vc: self.getCurrentViewController() as! UIViewController, adUnit: ((dict["ad_tag"]?["adunit"])! as? String) ?? "",zone: dict["zoneid"] as? String ?? "", dictR: dict)
        //                        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name("RewardPoints"), object: nil)
        //                        NotificationCenter.default.addObserver(self, selector: #selector(self.admobRewImage(notification:)), name: Notification.Name("adMobRewImage"), object: nil)
        //                    }
        //                    else if dict["ad_network_type"] as! String == AdType_Internal_Unity {
        //                        self.setupUnitySDK(view: view,fromStr: "RewardedVideo",dict: dict, zone: dict["zoneid"] as? String ?? "")
        //                    }
        //                    else if dict["ad_network_type"] as! String == AdType_Internal_IronSource {
        //                        UserDefaults.standard.set(true, forKey: "ISBanner")
        //
        //                        self.setupIronSourceSDK(view:  view,fromStr:"RewardedVideo", appkey: dict["ad_tag"]?["app_id"] as! String, zone: dict["zoneid"] as? String ?? "", dict: dict)
        //                    }
        //                    else if dict["ad_network_type"] as! String == AdType_Internal_ChartBoost {
        //                        self.chartBoost.setupChartBoostSDK(view:  UIView(),fromStr: "RewardedVideo",dict: dict["ad_tag"] as! [String : AnyObject])
        //                    }
        //                    else if dict["ad_network_type"] as! String == AdType_Internal_AdColony {
        //                        self.setupAdcolonySDK(view: view, fromStr: "RewardedVideo",dict: dict, zone: dict["zoneid"] as? String ?? "")
        //                        UserDefaults.standard.set(dict["zoneid"], forKey: "adColonyRewId")
        //
        //                        NotificationCenter.default.addObserver(self, selector: #selector(self.adColnyRewVideo(notification:)), name: Notification.Name("adColonyRewVideo"), object: nil)
        //
        //                    }
        //                    if dict["ad_network_type"] as! String != AdType_Internal_Admob {
        //                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute:   {
        //                            self.levelDidEnd(vc: "RewardedVideo", adTag: "", layout: "")
        //                        })
        //                    }
        //                }
        //                else if dict["response"] as? String == Error {
        //                    print("Error - \(dict["error"]?["description"]! ?? "Target Failed")")
        //                }
        //            }
        //        }
    }
}
//MARK: Get current Viewcontroller
extension AdResponse : WKUIDelegate, WKNavigationDelegate {
    func getCurrentViewController() -> Any? {
        let WindowRootVC = UIApplication.shared.delegate?.window??.rootViewController
        let currentViewController = findTopViewController(WindowRootVC)
        return currentViewController
    }
    func levelDidEnd(vc:String, adTag:String, layout:String) {
        let currentVC = getCurrentViewController()
        if currentVC != nil {}
        if vc == "InterstitialImage" {
            let detailVC = InterstitialImageAdVc()
            detailVC.adStatus = layout
            //            detailVC.interstitialImage_Delegate = self
            detailVC.html_tag_update(str: adTag)
            detailVC.modalPresentationStyle = .fullScreen
            (currentVC as AnyObject).present(detailVC, animated: true, completion: nil)
        }
        else if vc == "InterstitialVideo" {
            print(self.adDictResponse)
            let detailVC = InterstitialVideoAdVc()
            //            detailVC.interstitialImage_Delegate = self
            detailVC.AdTagURLString = adTag
            detailVC.layout = layout
            detailVC.mediationNetwork = self.adDictResponse["ad_network"] as? String
            detailVC.mediationNetworkType = self.adNetworkType
            detailVC.dictResponse = self.adDictResponse
            detailVC.modalPresentationStyle = .fullScreen
            (currentVC as AnyObject).present(detailVC, animated: true, completion: nil)
        }
        else  if vc == "RewardedVideo" {
            print(self.adDictResponse)
            
            let detailVC = RewardedVideoAdVc()
            //            detailVC.interstitialImage_Delegate = self
            detailVC.modalPresentationStyle = .fullScreen
            detailVC.AdTagURLString = adTag
            detailVC.mediationNetwork = self.adDictResponse["ad_network"] as? String
            detailVC.mediationNetworkType = self.adNetworkType
            detailVC.dictResponse = self.adDictResponse
            detailVC.rewardPointsReceived = self.rewardPoints
            detailVC.layout = layout
            (currentVC as AnyObject).present(detailVC, animated: true, completion: nil)
        }
    }
    func findTopViewController(_ inController: Any?) -> Any? {
        if inController is UITabBarController {
            return findTopViewController((inController as AnyObject).selectedViewController!)
        }
        else if inController is UINavigationController {
            return findTopViewController((inController as AnyObject).visibleViewController!)
        }
        else if inController is UIViewController {
            return inController
        }
        else {
            if let inController = inController {
                print("Unhandled ViewController class : \(inController)")
            }
            return nil
        }
    }
}
extension AdResponse : WebViewUpdateDelegate {
    public func updateWebView(webV: WKWebView) {  }
    public func updateMediationWebView(webV: GADBannerView) {}
}
//MARK: API repsonse delegate
extension AdResponse: api_Response_Delegate {
    func response_Dict(passValue: Dictionary<String, AnyObject>) {
        self.currentResponseArrayList.removeAll()
        print(passValue)
        if passValue["response"] as! String == Success {
            currentResponseArrayList = passValue["ads"] as! Array<AnyObject>
            self.dummyDataResponse()
        }
        else {
            print(Error_Invalid_Request)
        }
    }
}
//MARK: Unity
extension AdResponse {
    func setupUnitySDK(view:UIView,fromStr:String,dict:[String:AnyObject],zone:String) {
        self.adView = view
        self.adView.backgroundColor = UIColor.brown
        self.dictResponse = dict
        print(self.dictResponse)
        
        UnityAds.initialize(self.dictResponse["ad_tag"]?["game_id"] as! String, testMode: Bool(self.dictResponse["ad_tag"]?["testmode"] as! String) ?? true, initializationDelegate: self)
        if fromStr == "RewardedVideo" {
            UnityAds.load( self.dictResponse["ad_tag"]?["placement_id"] as! String, loadDelegate: self)
        }
        else if fromStr == "InterstitialVideo" {
            UnityAds.load( self.dictResponse["ad_tag"]?["placement_id"] as! String, loadDelegate: self)
        }
        else if fromStr == "Banner" {
            self.initializationComplete()
        }
    }
    func loadBanner() {
        print(self.dictResponse)
        
        UnityAds.load(self.dictResponse["ad_tag"]?["placement_id"] as! String, loadDelegate: self)
        self.topBannerView = UADSBannerView(placementId:  self.dictResponse["ad_tag"]?["placement_id"] as! String, size: CGSize(width: 320, height: 50))
        self.topBannerView?.delegate = self
        self.addBannerViewToTopView(self.topBannerView!)
        self.topBannerView?.load()
    }
    func addBannerViewToTopView( _ view: UIView) {
        self.adView.addSubview(view)
    }
    func loadRewarded() {
        UnityAds.show(self, placementId: self.dictResponse["ad_tag"]?["placement_id"] as! String, showDelegate: self)
    }
    func loadInterstitial() {
        var dict : Dictionary<String,AnyObject> = [:]
        if UserDefaults.standard.object(forKey: "InterstitialVideoResponse") == nil { }
        else {
            let outData = UserDefaults.standard.data(forKey: "InterstitialVideoResponse")
            dict = (NSKeyedUnarchiver.unarchiveObject(with: outData!) as! NSDictionary) as! Dictionary<String, AnyObject>
        }
        if dict.count != 0  {
            if dict["ad_type"] as! String  == AdType_Internal_InterstitialVideo {
                UnityAds.show(self, placementId: (dict["ad_tag"]?["placement_id"])! as! String, showDelegate: self)
            }
        }
    }
}
extension AdResponse : UnityAdsInitializationDelegate {
    public func initializationComplete() {
        self.loadBanner()
    }
    public func initializationFailed(_ error: UnityAdsInitializationError, withMessage message: String) {
        print("initializationFailed")
        print(error)
        print(message)
    }
}
extension AdResponse : UnityAdsLoadDelegate {
    public func unityAdsAdLoaded(_ placementId: String) {
        print("unityAdsAdLoaded")
        
    }
    public func unityAdsAdFailed(toLoad placementId: String, withError error: UnityAdsLoadError, withMessage message: String) {
        print("unityAdsAdFailed")
        //this one calling
        print(message)
        print(error)
    
    }
}
extension AdResponse : UnityAdsShowDelegate {
    public func unityAdsShowComplete(_ placementId: String, withFinish state: UnityAdsShowCompletionState) {
        print(state)
        print("UnityAdsShowCompletionState")
    }
    public func unityAdsShowFailed(_ placementId: String, withError error: UnityAdsShowError, withMessage message: String) {
        print("unityAdsShowFailed")
        
        print(message)
        print(error)
   
    }
    public func unityAdsShowStart(_ placementId: String) {
        print("unityAdsShowStart")
        
    }
    public func unityAdsShowClick(_ placementId: String) {
        print("unityAdsShowClick")
        
    }
}
extension AdResponse : UADSBannerViewDelegate {
    public func bannerViewDidLoad(_ bannerView: UADSBannerView!) {
        print("bannerViewDidLoad")
        if UserDefaults.standard.bool(forKey: "UBanner") == true {
            webSc.trackingUrl(url: self.dictResponse["imp_url"] as! String)
            UserDefaults.standard.set(false, forKey: "UBanner")
        }
    }
    public func bannerViewDidClick(_ bannerView: UADSBannerView!) {
        print("bannerViewDidClick")
        
    }
    public func bannerViewDidError(_ bannerView: UADSBannerView!, error: UADSBannerError!) {
        print("bannerViewDidError")
        print(error!)
        self.selectedMediationIndex! += 1
        print("unity failure")
        print(self.zoneArrayCount)
        print(self.selectedMediationIndex)

        guard let heightA = self.selectedMediationIndex, let heightB = self.zoneArrayCount else {
        print("Some paremter is nil")
        return
        }
        if (heightA >= heightB) { //error here
            UserDefaults.standard.set(1, forKey: "isAdtype")
            print(UserDefaults.standard.object(forKey: "isAdtype"))
            
            self.getUserDefaultValue(zones: self.zoneId ?? "0", str: "SDK")
        }
        else {
            self.imageAdIntegration(fromStr: "", view: self.adView, webV: self.webView)
        }
    }
    public func bannerViewDidLeaveApplication(_ bannerView: UADSBannerView!) {
        print("bannerViewDidLeaveApplication")
        webSc.trackingUrl(url: self.dictResponse["click_url"] as! String)
    }
    
}
//MARK: Chartboost
extension AdResponse {
    func setupChartBoostSDK(view:UIView,fromStr:String,dict:[String:AnyObject],zone:String) {
        
        self.zoneId = zone
        self.adView = view
        self.adView.backgroundColor = UIColor.orange
        self.dictResponse = dict
        
        if #available(iOS 11.3, *) {
            SKAdNetwork.registerAppForAdNetworkAttribution()
        }
        Chartboost.addDataUseConsent(.CCPA(.optInSale))
        Chartboost.addDataUseConsent(.GDPR(.behavioral))
        Chartboost.setLoggingLevel(.info)
        Chartboost.start(withAppID: dict["ad_tag"]?["app_id"] as! String,
                         appSignature: dict["ad_tag"]?["app_signature"] as! String) { error in
            print(error.debugDescription)
            if error.debugDescription == "Chartboost failed to initialize." {
                self.selectedMediationIndex! += 1
                print("chartboost failure")
                print(self.zoneArrayCount)
                print(self.selectedMediationIndex)
                self.bannerChartboost.clearCache()
                if self.zoneArrayCount == self.selectedMediationIndex {
                    UserDefaults.standard.set(1, forKey: "isAdtype")
                    self.getUserDefaultValue(zones: self.zoneId ?? "0", str: "SDK")
                }
                else {
                    self.imageAdIntegration(fromStr: "", view: self.adView, webV: self.webView)
                }
            }
            print(error == nil ? "Chartboost initialized successfully!" : "Chartboost failed to initialize.")
        }
        if fromStr == "Banner" {
            self.bannerChartboost.cache()
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            DispatchQueue.main.async {
                self.bannerChartboost.show(from: self)
                self.adView.addSubview(self.bannerChartboost)
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

extension AdResponse : CHBBannerDelegate {
    public func didFinishHandlingClick(_ event: CHBClickEvent, error: CHBClickError?)
    {
        print("didFinishHandlingClick")
        print(event.ad)
        print(error.debugDescription)
        webSc.trackingUrl(url: self.dictResponse["click_url"] as! String)
    }
}
extension AdResponse : CHBRewardedDelegate {
    public func didEarnReward(_ event: CHBRewardEvent) {
        print("didEarnReward: " + String(event.reward))
    }
    public func didDismissAd(_ event: CHBDismissEvent) {
        print("didDismissAd: \(type(of: event.ad))")
    }
}
extension AdResponse : CHBInterstitialDelegate {
    public func didCacheAd(_ event: CHBCacheEvent, error: CHBCacheError?) {
        print("didCacheAd: \(type(of: event.ad)) \(statusWithError(error))")
    }
    
    public func willShowAd(_ event: CHBShowEvent) {
        print("willShowAd: \(type(of: event.ad))")
    }
    
    public func didShowAd(_ event: CHBShowEvent, error: CHBShowError?) {
        print("didShowAd: \(type(of: event.ad)) \(statusWithError(error))")
        print(statusWithError(error))
        print(self.dictResponse)
        if statusWithError(error) == "SUCCESS" {
            webSc.trackingUrl(url: self.dictResponse["imp_url"] as! String)
        }
    }
    
    public func didClickAd(_ event: CHBClickEvent, error: CHBClickError?) {
        print("didClickAd: \(type(of: event.ad)) \(statusWithError(error))")
    }
    public func statusWithError(_ error: Any?) -> String {
        if let error = error {
            self.selectedMediationIndex! += 1
            print("chartboost failure")
            print(self.zoneArrayCount)
            print(self.selectedMediationIndex)
            self.bannerChartboost.clearCache()
            if self.zoneArrayCount == self.selectedMediationIndex {
                UserDefaults.standard.set(1, forKey: "isAdtype")
                self.getUserDefaultValue(zones: self.zoneId ?? "0", str: "SDK")
            }
            else {
                self.imageAdIntegration(fromStr: "", view: self.adView, webV: self.webView)
            }
            
            return "FAILED (\(error))"
        }
        return "SUCCESS"
    }
}
//MARK: Ironsource
extension AdResponse {
    func setupIronSourceSDK(view:UIView,fromStr:String,appkey:String,zone:String,dict:[String:AnyObject]) {
        self.zoneId = zone
        self.adView = view
        self.adView.backgroundColor = UIColor.yellow
        self.kAPPKEY_New = appkey
        self.dictResponse = dict
        
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
        IronSource.initWithAppKey(kAPPKEY_New ?? "")
        
        if fromStr == "Banner" {
            let BNSize: ISBannerSize = ISBannerSize(description: "BANNER",width:320 ,height:50)
            IronSource.loadBanner(with: self, size: BNSize)
        }
    }
}
extension AdResponse {
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
extension AdResponse :  ISImpressionDataDelegate {
    public func impressionDataDidSucceed(_ impressionData: ISImpressionData!) {
        print("Impression data - \(impressionData.description)")
        if UserDefaults.standard.bool(forKey: "ISBanner") == true {
            webSc.trackingUrl(url: self.dictResponse["imp_url"] as! String)
            UserDefaults.standard.set(false, forKey: "ISBanner")
        }
    }
}
extension AdResponse : LevelPlayBannerDelegate {
    public func didLoad(_ bannerView: ISBannerView!, with adInfo: ISAdInfo!) {
        self.bannerIronSourceView = bannerView
        self.adView.addSubview(self.bannerIronSourceView)
    }
    public func didFailToLoadWithError(_ error: Error!) {
        print("Banner ad error - \(error.localizedDescription)")
//        self.selectedMediationIndex! += 1
        print("ironsource failure")
//        print(self.zoneArrayCount)
//        print(self.selectedMediationIndex)
//
//        if self.zoneArrayCount == self.selectedMediationIndex {
//            UserDefaults.standard.set("1", forKey: "isAdtype")
//            self.getUserDefaultValue(zones: self.zoneId ?? "0", str: "SDK")
//        }
//        else {
//            self.imageAdIntegration(fromStr: "", view: self.adView, webV: self.webView)
//        }
    }
    public func didClick(with adInfo: ISAdInfo!) {
        print("Banner ad click - \(adInfo.description)")
        webSc.trackingUrl(url: self.dictResponse["click_url"] as! String)
    }
    public func didLeaveApplication(with adInfo: ISAdInfo!) {
        print("Banner ad leave - \(adInfo.description)")
        if bannerView != nil {
            IronSource.destroyBanner(bannerIronSourceView)
        }
    }
    public func didPresentScreen(with adInfo: ISAdInfo!) {
        print("Banner ad Present - \(adInfo.description)")
    }
    public func didDismissScreen(with adInfo: ISAdInfo!) {
        print("Banner ad dismiss - \(adInfo.description)")
        if bannerView != nil {
            IronSource.destroyBanner(bannerIronSourceView)
        }
    }
}
extension AdResponse : LevelPlayInterstitialDelegate {
    public func interstitialDidLoad() {
        print("Interstitial ad load")
    }
    
    public func interstitialDidFailToLoadWithError(_ error: Error!) {
        print("Interstitial ad load - \(error.debugDescription)")
    }
    
    public func interstitialDidOpen() {
        print("Interstitial ad open")
    }
    
    public func interstitialDidClose() {
        print("Interstitial ad close")
    }
    
    public func interstitialDidShow() {
        print("Interstitial ad did show")
    }
    
    public func interstitialDidFailToShowWithError(_ error: Error!) {
        print("Interstitial ad error - \(error.debugDescription)")
    }
    
    public func didClickInterstitial() {
        print("Interstitial ad Click")
        webSc.trackingUrl(url: self.dictResponse["click_url"] as! String)
    }
    
    public func didLoad(with adInfo: ISAdInfo!) {
        print("Interstitial ad load - \(adInfo.description)")
    }
    public func didOpen(with adInfo: ISAdInfo!) {
        print("Interstitial ad open - \(adInfo.description)")
    }
    public func didShow(with adInfo: ISAdInfo!) {
        print("Interstitial ad show - \(adInfo.description)")
    }
    public func didFailToShowWithError(_ error: Error!, andAdInfo adInfo: ISAdInfo!) {
        print("Interstitial ad error - \(error.debugDescription)")
        print(error)
        print(error.localizedDescription)
        print("ironsource failure")

        if error.localizedDescription == "showRewardedVideo error: can't show ad while an ad is already showing" || error.localizedDescription == "Rewarded Video Show Fail - Show Rewarded Video cannot be called before Init is complete" {
          
        }
        else if error.localizedDescription == "showInterstitial error: show called while no ads are available" {
         
        }
    }
    public func didClose(with adInfo: ISAdInfo!) {
        print("Interstitial ad close - \(adInfo.description)")
    }
}
extension AdResponse : LevelPlayRewardedVideoDelegate {
    public func hasAvailableAd(with adInfo: ISAdInfo!) {
        print("adInfo \(adInfo)")
    }
    public func hasNoAvailableAd() {
        
    }
    public func didReceiveReward(forPlacement placementInfo: ISPlacementInfo!, with adInfo: ISAdInfo!) {
        print("didReceiveReward placementInfo \(placementInfo),\(adInfo)")
    }
    public func didClick(_ placementInfo: ISPlacementInfo!, with adInfo: ISAdInfo!) {
        print("didClick placementInfo \(placementInfo),\(adInfo)")
        print(self.dictResponse["click_url"] as! String)
        webSc.trackingUrl(url: self.dictResponse["click_url"] as! String)
        
    }
    public func rewardedVideoHasChangedAvailability(_ available: Bool) {
        
    }
    public func didReceiveReward(forPlacement placementInfo: ISPlacementInfo!) {
        print("didReceiveReward placementInfo \(placementInfo)")
        
    }
    public func rewardedVideoDidFailToShowWithError(_ error: Error!) {
        print("rewardedVideoDidFailToShowWithError")
        print(error)
        
    }
    public func rewardedVideoDidOpen() {
        
    }
    public func rewardedVideoDidClose() {
        print(rewardedVideoDidClose)
        
    }
    public func rewardedVideoDidStart() {
        
    }
    public func rewardedVideoDidEnd() {
        
    }
    public func didClickRewardedVideo(_ placementInfo: ISPlacementInfo!) {
        print("didClickRewardedVideo")
    }
}
//MARK: AdColony
extension AdResponse {
    func setupAdcolonySDK(view:UIView,fromStr:String,dict:[String:AnyObject],zone:String) {
        self.zoneId = zone
        self.adView = view
        self.adView.backgroundColor = UIColor.orange
        self.dictResponse = dict
        
        AdColony.configure(withAppID: dict["ad_tag"]?["app_id"] as! String, options: nil) { (zones) in
            if fromStr == "RewardedVideo" {
//                self.loadAds()
            }
            else if fromStr == "Banner" {
                self.requestBanner()
            }
            else if fromStr == "InterstitialVideo" {
//                self.loadAd()
            }
        }
    }
    
}
extension AdResponse : AdColonyAdViewDelegate {
    func requestBanner() {
        AdColony.requestAdView(inZone: self.dictResponse["ad_tag"]?["zone_id"] as! String, with: kAdColonyAdSizeBanner, viewController: self, andDelegate: self)
    }
    public func adColonyAdViewDidShow(_ adView: AdColonyAdView) {
        print("adColonyAdViewDidShow")
        print(self.dictResponse)
        webSc.trackingUrl(url: self.dictResponse["imp_url"] as! String)
    }
    
    public func adColonyAdViewDidLoad(_ adView: AdColonyAdView) {
        self.clearBanner()
        self.adColonyBanner = adView
        let placementSize = self.adView.frame.size
        adView.frame = CGRect(x: 0, y: 0, width: placementSize.width, height: placementSize.height)
        self.adView.addSubview(adView)
    }
    
    public func adColonyAdViewDidFail(toLoad error: AdColonyAdRequestError) {
        if let reason = error.localizedFailureReason {
            print("SAMPLE_APP: Banner request failed in zone \(error.zoneId) with error: \(error.localizedDescription) and failure reason: \(reason)")
        } else if let recoverySuggestion = error.localizedRecoverySuggestion {
            //banner
            print("SAMPLE_APP: Banner request failed in zone \(error.zoneId) with error: \(error.localizedDescription) and recovery suggestion: \(recoverySuggestion)")
            
        } else {
            print("SAMPLE_APP: Banner request failed in zone \(error.zoneId) with error: \(error.localizedDescription)")
        }
        self.selectedMediationIndex! += 1
        print("Adcolony failure")
        print(self.zoneArrayCount)
        print(self.selectedMediationIndex)
        
        if self.zoneArrayCount == self.selectedMediationIndex {
            UserDefaults.standard.set(1, forKey: "isAdtype")
            self.getUserDefaultValue(zones: self.zoneId ?? "0", str: "SDK")
        }
        else {
            self.imageAdIntegration(fromStr: "", view: self.adView, webV: self.webView)
        }
    }
    
    func clearBanner() {
        if let adView = self.adColonyBanner {
            adView.destroy()
            self.adColonyBanner = nil
        }
    }
    public func adColonyAdViewWillOpen(_ adView: AdColonyAdView) {
        print("AdView will open fullscreen view")
    }
    
    public func adColonyAdViewDidClose(_ adView: AdColonyAdView) {
        print("AdView did close fullscreen views")
    }
    
    public func adColonyAdViewWillLeaveApplication(_ adView: AdColonyAdView) {
        print("AdView will send used outside the app")
    }
    
    public  func adColonyAdViewDidReceiveClick(_ adView: AdColonyAdView) {
        print("AdView received a click")
        webSc.trackingUrl(url: self.dictResponse["click_url"] as! String)
    }
}
extension AdResponse : AdColonyInterstitialDelegate {
    public func adColonyInterstitialDidLoad(_ interstitial: AdColonyInterstitial) {
        //Store a reference to the returned interstitial object
        self.adInterstitial = interstitial
    }
    
    public func adColonyInterstitialDidFail(toLoad error: AdColonyAdRequestError) {
        if let reason = error.localizedFailureReason {
            print("SAMPLE_APP: Request failed in zone \(error.zoneId) with error: \(error.localizedDescription) and failure reason: \(reason)")
        } else if let recoverySuggestion = error.localizedRecoverySuggestion {
            print("SAMPLE_APP: Request failed in zone \(error.zoneId) with error: \(error.localizedDescription) and recovery suggestion: \(recoverySuggestion)")
        } else {
            print("SAMPLE_APP: Request failed in zone \(error.zoneId) with error: \(error.localizedDescription)")
        }
//        self.selectedMediationIndex! += 1
//
        print("Adcolony failure")
//
//        print(self.zoneArrayCount)
//        print(self.selectedMediationIndex)
//
//        if self.zoneArrayCount == self.selectedMediationIndex {
//            UserDefaults.standard.set("1", forKey: "isAdtype")
//            self.getUserDefaultValue(zones: self.zoneId ?? "0", str: "SDK")
//        }
//        else {
//            self.imageAdIntegration(fromStr: "", view: self.adView, webV: self.webView)
//        }
    }
    public func adColonyInterstitialExpired(_ interstitial: AdColonyInterstitial) {
        self.adInterstitial = nil
        //        self.requestInterstitial()
    }
    
    public func adColonyInterstitialDidClose(_ interstitial: AdColonyInterstitial) {
        self.adInterstitial = nil
        //        self.requestInterstitial()
    }
    func loadAd() {
        //        AdColony.configure(withAppID: "app75d5d509ff774fab8f", options: nil) { [weak self] (zones) in
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification,
                                               object: nil,
                                               queue: OperationQueue.main,
                                               using: { notification in
            //If our ad has expired, request a new interstitial
            if (self.adInterstitial == nil) {
                self.requestInterstitial()
            }
        })
        //AdColony has finished configuring, so let's request an interstitial ad
        self.requestInterstitial()
        //        }
    }
    func requestInterstitial() {
        //Request an interstitial ad from AdColony
        var dict : Dictionary<String,AnyObject> = [:]
        if UserDefaults.standard.object(forKey: "InterstitialVideoResponse") == nil { }
        else {
            let outData = UserDefaults.standard.data(forKey: "InterstitialVideoResponse")
            dict = (NSKeyedUnarchiver.unarchiveObject(with: outData!) as! NSDictionary) as! Dictionary<String, AnyObject>
        }
        print(self.dictResponse)
        if self.dictResponse.count != 0  {
            AdColony.requestInterstitial(inZone: self.dictResponse["ad_tag"]?["zone_id"] as! String, options: nil, andDelegate: self)
                if let ad = self.adInterstitial, !ad.expired {
                    self.adInterstitial?.show(withPresenting: self)
                }
            
        }
        
    }
}
extension AdResponse  {
    func loadAds(){
        //vzb2fc4d9b99454bb982 - new
        //vz882f53b8196d4b5a80 - old
        //        let appOptions = AdColonyAppOptions()
        //        appOptions.userID = "newuserid"
        //        AdColony.setAppOptions(appOptions)
        
//        var dict : Dictionary<String,AnyObject> = [:]
//        if UserDefaults.standard.object(forKey: "RewardedResponse") == nil { }
//        else {
//            let outData = UserDefaults.standard.data(forKey: "RewardedResponse")
//            dict = (NSKeyedUnarchiver.unarchiveObject(with: outData!) as! NSDictionary) as! Dictionary<String, AnyObject>
//        }
//        if dict.count != 0  {
//            print(dict)
//            if dict["ad_type"] as! String  == AdType_Internal_InterstitialVideo {
                let rewardedZones:Array<String> = [self.dictResponse["zone_id"] as! String]
                AdColony.configure(withAppID:  self.dictResponse["ad_tag"]?["app_id"] as! String, options: nil) { [weak self] (zones) in
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
                
                AdColony.requestInterstitial(inZone: self.dictResponse["ad_tag"]?["zone_id"] as! String, options: options, andDelegate: self)
                self.loadAd()
//            }
//        }
    }
}

//MARK: Admob
extension AdResponse {
    func updateAd() {
      
    }
    func create_Basic_ad(size: String, adUnit: String?,dict:[String:AnyObject]) -> GADBannerView
    {
        self.dictResponse = dict
        self.admobBannerView = GADBannerView(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        self.admobBannerView.rootViewController = self
        self.admobBannerView.delegate = self
        self.admobBannerView.adUnitID = adUnit
        self.admobBannerView.load(GADRequest())

        return self.admobBannerView
    }
    func loadInterstitial(vc:UIViewController,adUnit:String,fromadNetwork:String, dict:[String:AnyObject]) {
        self.dictResponse = dict
        print(dict)
        
        DispatchQueue.main.async {
            let request = GADRequest()
            GADInterstitialAd.load(
                withAdUnitID: self.dictResponse["ad_tag"]?["adunit"] as! String, request: request
            ) { (ad, error) in
                if let error = error {
                    UserDefaults.standard.set(1, forKey: "isAdtype")
                    if self.zoneArrayCount == self.selectedMediationIndex {
                        self.getUserDefaultValue(zones: self.zoneId ?? "0", str: "SDK")
                    }
                    else {
                    }
                    print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                    return
                }
                self.admobInterstitial = ad
                self.admobInterstitial?.fullScreenContentDelegate = self
                if let ad = self.admobInterstitial {
                    ad.present(fromRootViewController: vc)
                }
                else {
                    print("Ad wasn't ready")
                }
            }
        }
    }
    func loadRewarded(vc:UIViewController,adUnit:String,dict:[String:AnyObject]) {
        self.dictResponse = dict
        
        let request = GADRequest()
        GADRewardedAd.load(
            withAdUnitID: adUnit, request: request
        ) { (ad, error) in
            if let error = error {
                UserDefaults.standard.set(1, forKey: "isAdtype")
                if self.zoneArrayCount == self.selectedMediationIndex {
                    self.getUserDefaultValue(zones: self.zoneId ?? "0", str: "SDK")
                }
                else {
                }
                print("Rewarded ad failed to load with error: \(error.localizedDescription)")
                return
            }
            self.admobRewardedAd = ad
            self.admobRewardedAd?.fullScreenContentDelegate = self
            if let ad = self.admobRewardedAd {
                ad.present(fromRootViewController: vc) {
                    let reward = ad.adReward
                    
                    print("Reward received with currency \(reward.amount), amount \(reward.amount.doubleValue)")
                    self.earnCoins(NSInteger(truncating: reward.amount))
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
    func manageRewardPoints() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name("RewardPoints"), object: self.coinCount)
        }
    }
}
extension AdResponse : GADBannerViewDelegate {
    public func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
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
            self.bannerViewDidReceiveAd(admobBannerView)
        }
    }
    public func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        print("bannerView:didFailToReceiveAdWithError: \(error.localizedDescription)")
        
                print(self.selectedMediationIndex)

        self.selectedMediationIndex! += 1
        self.admobBannerView.removeFromSuperview()
        self.admobBannerView.rootViewController = nil
        print("Admob failure")
        
        print(self.zoneArrayCount)
        print(self.selectedMediationIndex)
//
        if self.zoneArrayCount == self.selectedMediationIndex {
            UserDefaults.standard.set(1, forKey: "isAdtype")
            self.getUserDefaultValue(zones: self.zoneId ?? "0", str: "SDK")
        }
        else {
            self.imageAdIntegration(fromStr: "", view: self.adView, webV: self.webView)
        }
    }
    public func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
        print("bannerViewDidRecordImpression")
        webSc.trackingUrl(url: self.dictResponse["imp_url"] as! String)
    }
    public func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("bannerViewWillPresentScreen")
    }
    public func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("bannerViewWillDIsmissScreen")
    }
    public func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("bannerViewDidDismissScreen")
    }
    public func bannerViewDidRecordClick(_ bannerView: GADBannerView) {
        print("bannerViewDidRecordClick")
        webSc.trackingUrl(url: self.dictResponse["click_url"] as! String)
    }
    
}
extension AdResponse : GADFullScreenContentDelegate {
    public func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad will present full screen content.")
    }
    public func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error)
    {
        print("Ad failed to present full screen content with error \(error.localizedDescription).")
    }
    public func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did dismiss full screen content.")
    }
}
extension String {
    func toJSON() -> Any? {
        guard let data = self.data(using: .utf8, allowLossyConversion: false) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
    }
}
