//
//  Interstitial_Video_Ads.swift
//  SDK_Lib
//
//  Created by Djax on 05/09/22.
//

import UIKit
import AVFoundation
import ChartboostSDK
import StoreKit
import UnityAds
import IronSource
import GoogleInteractiveMediaAds
import AdColony

class InterstitialVideoAdVc: UIViewController {
    
    var mediationNetworkType:String? = ""
    var mediationNetwork:String? = ""
    
    var adColonyInterstitial: AdColonyInterstitial? = nil //Interstitial
    
    private lazy var interstitial = CHBInterstitial(location: "default", delegate: self)
    
    var adInt: AdColonyInterstitial?
    weak var ad: AdColonyAdView? = nil
    
    var rewardPointsReceived : Array<Dictionary<String,AnyObject>> = []
    
    var strError:String? = ""
    
    var statusBarState = false
    
    var AdTagURLString = ""
    var layout = ""
    var playerViewController: AVPlayerViewController!
    var contentPlayhead: IMAAVPlayerContentPlayhead?
    var adsLoader: IMAAdsLoader!
    var adsManager: IMAAdsManager!
    
    var dictResponse :[String:AnyObject] = [:]
    
    let webSc = WebService()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    override var prefersStatusBarHidden: Bool{
        return statusBarState
    }
    override func viewWillAppear(_ animated: Bool) {
        statusBarState = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        if #available(iOS 16.0, *) {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
            self.setNeedsUpdateOfSupportedInterfaceOrientations()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait)){
                    error in
                    print(error)
                }
            })
        }
        
    }
    override func viewDidLoad() {
        
        
        NotificationCenter.default.addObserver(self, selector:#selector(InterstitialVideoAdVc.shutItDown), name: UIApplication.didEnterBackgroundNotification, object: UIApplication.shared)
        NotificationCenter.default.addObserver(self, selector:#selector(InterstitialVideoAdVc.becomeactive), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clear
        let button = UIButton(frame: CGRect(x: 100, y: 60, width: 40, height: 40))
        button.setImage(Self.getMyImage()?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: .normal)
        button.tintColor = UIColor.white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(buttonClick), for: .touchUpInside)
        self.view.addSubview(button)
        self.view.bringSubviewToFront(button)
        
        NSLayoutConstraint.activate([
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            button.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            button.widthAnchor.constraint(equalToConstant: 75),
            button.heightAnchor.constraint(equalToConstant: 75)
        ])
        
        setUpContentPlayer()
        setUpAdsLoader()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print(self.dictResponse)
        print(self.mediationNetworkType)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0)
        {
            if self.mediationNetworkType == AdType_Mediation_Network {
                if self.dictResponse["ad_network_type"] as? String == AdType_Internal_Unity {
                    self.loadInterstitialUnity()
                }
                else if  self.dictResponse["ad_network_type"] as? String == AdType_Internal_IronSource {
                    self.interstitialAction()
                }
                else if  self.dictResponse["ad_network_type"] as? String == AdType_Internal_ChartBoost {
                    self.interstitialAd()
                }
                else if self.dictResponse["ad_network_type"] as? String == AdType_Internal_AdColony {
                    //                    self.requestInterstitialAdcolony()
                    self.loadAdColony()
                }
            }
            else if self.mediationNetwork == AdType_Internal_Network {
                self.requestAds()
            }
        }
    }
    func loadAdColony() {
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification,
                                               object: nil,
                                               queue: OperationQueue.main,
                                               using: { notification in
            //If our ad has expired, request a new interstitial
            if (self.adColonyInterstitial == nil) {
                self.requestInterstitial()
            }
        })
        self.requestInterstitial()
    }
    func requestInterstitial() {
        //Request an interstitial ad from AdColony
        let placeId = self.dictResponse["ad_tag"] as! [String:AnyObject]
        AdColony.requestInterstitial(inZone: placeId["zone_id"] as! String, options: nil, andDelegate: self)
        if let ad = self.adColonyInterstitial, !ad.expired {
            self.adColonyInterstitial?.show(withPresenting: self)
        }
    }
    func requestInterstitialAdcolony() {
        
        //        AdColony.configure(withAppID: "app75d5d509ff774fab8f", options: nil) { [weak self] (zones) in
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification,
                                               object: nil,
                                               queue: OperationQueue.main,
                                               using: { notification in
            //If our ad has expired, request a new interstitial
            if (self.adInt == nil) {
                self.requestInterstitialsAdcolony()
            }
        })
        //AdColony has finished configuring, so let's request an interstitial ad
        self.requestInterstitialsAdcolony()
        //        }
        
    }
    func requestInterstitialsAdcolony() {
        //Request an interstitial ad from AdColony
        let placeId = self.dictResponse["ad_tag"] as! [String:AnyObject]
        
        AdColony.requestInterstitial(inZone:placeId["zone_id"] as! String, options: nil, andDelegate: self)
        if let ad = self.adInt, !ad.expired {
            self.adInt?.show(withPresenting: self)
        }
    }
    func interstitialAd() {
        self.interstitial.cache()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            DispatchQueue.main.async {
                self.interstitial.show(from: self)
            }
        }
    }
    
    func interstitialAction() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                IronSource.showInterstitial(with: self)
            }
        }
    }
    func loadInterstitialUnity() {
        if dictResponse.count != 0  {
            let placeId = dictResponse["ad_tag"] as! [String:AnyObject]
            UnityAds.show(self, placementId: placeId["placement_id"] as! String, showDelegate: self)
            //                        UnityAds.show(self, placementId:  self.dictResponse["ad_tag"]?["placement_id"] as! String, showDelegate: self)
        }
    }
    @objc func becomeactive() {
        if adsManager != nil {
            adsManager.resume()
            adsManager.start()
        }
    }
    @objc func shutItDown() {}
}
//MARK:- button actions
extension InterstitialVideoAdVc
{
    @objc func buttonClick() {
        self.dismiss(animated: true)
    }
    class func getMyImage() -> UIImage? {
        let bundle = Bundle(for: self)
        return UIImage(named: "close.png", in: bundle, compatibleWith: nil)
    }
}

extension InterstitialVideoAdVc : CHBInterstitialDelegate {
    func didCacheAd(_ event: CHBCacheEvent, error: CHBCacheError?) {
        print("didCacheAd: \(type(of: event.ad)) \(statusWithError(error))")
    }
    
    func willShowAd(_ event: CHBShowEvent) {
        print("willShowAd: \(type(of: event.ad))")
    }
    func didRecordImpression(_ event: CHBImpressionEvent) {
        webSc.trackingUrl(url: self.dictResponse["imp_url"] as! String)
    }
    func didShowAd(_ event: CHBShowEvent, error: CHBShowError?) {
        print("didShowAd: \(type(of: event.ad)) \(statusWithError(error.debugDescription))")
        self.strError = error?.userInfo.description.debugDescription
        let dict = error?.userInfo.description
        print(dict)
        print(dict?.debugDescription)
        print(error?.userInfo.debugDescription.startIndex)
        print(self.strError)
        
        self.manageChartBoostIntVideo()
    }
    func manageChartBoostIntVideo() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name("chartBoostIntId"), object:self.strError )
        }
    }
    func didClickAd(_ event: CHBClickEvent, error: CHBClickError?) {
        print("didClickAd: \(type(of: event.ad)) \(statusWithError(error.debugDescription))")
        webSc.trackingUrl(url: self.dictResponse["click_url"] as! String)
        
    }
    func didDismissAd(_ event: CHBDismissEvent) {
        print("didDismissAd: \(type(of: event.ad))")
        self.buttonClick()
    }
    func statusWithError(_ error: Any?) -> String {
        if let error = error {
            return "FAILED (\(error))"
        }
        return "SUCCESS"
    }
}
extension InterstitialVideoAdVc : UnityAdsLoadDelegate {
    func unityAdsAdLoaded(_ placementId: String) {
        print(placementId)
        print("unityAdsAdLoaded")
        webSc.trackingUrl(url: self.dictResponse["request_url"] as! String)
    }
    
    func unityAdsAdFailed(toLoad placementId: String, withError error: UnityAdsLoadError, withMessage message: String) {
        print(message)
        print(error)
        print("unityAdsAdFailed")
        
    }
}
extension InterstitialVideoAdVc : UnityAdsShowDelegate {
    func unityAdsShowComplete(_ placementId: String, withFinish state: UnityAdsShowCompletionState) {
        self.dismiss(animated: true)
        print("unityAdsShowComplete")
    }
    
    func unityAdsShowFailed(_ placementId: String, withError error: UnityAdsShowError, withMessage message: String) {
        print(message)
        print(error)
        print("unityAdsShowFailed")
        
    }
    
    func unityAdsShowStart(_ placementId: String) {
        print(placementId)
        print("unityAdsShowStart")
        webSc.trackingUrl(url: self.dictResponse["imp_url"] as! String)
        
    }
    
    func unityAdsShowClick(_ placementId: String) {
        print(placementId)
        print("unityAdsShowClick")
        webSc.trackingUrl(url: self.dictResponse["click_url"] as! String)
    }
}
extension InterstitialVideoAdVc : LevelPlayInterstitialDelegate {
    func didFailToLoadWithError(_ error: Error!) {
        print("didFailToLoadWithError")
        print(error)
    }
    
    func didClick(with adInfo: ISAdInfo!) {
        print(adInfo)
        print("didClick")
        
    }
    
    func interstitialDidLoad() {
        print("Interstitial ad load")
    }
    
    func interstitialDidFailToLoadWithError(_ error: Error!) {
        print("interstitialDidFailToLoadWithError")
        
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
        print("interstitialDidFailToShowWithError")
        
    }
    
    func didClickInterstitial() {
        print("Interstitial ad Click")
    }
    
    func didLoad(with adInfo: ISAdInfo!) {
        print("Interstitial ad load - \(adInfo.description)")
        print("didLoad")
        
    }
    func didOpen(with adInfo: ISAdInfo!) {
        print("Interstitial ad open - \(adInfo.description)")
        print("didOpen")
        
    }
    func didShow(with adInfo: ISAdInfo!) {
        print("Interstitial ad show - \(adInfo.description)")
        print("didShow")
        
    }
    func didFailToShowWithError(_ error: Error!, andAdInfo adInfo: ISAdInfo!) {
        print("Interstitial ad error - \(error.debugDescription)")
        print("didFailToShowWithError")
        
    }
    func didClose(with adInfo: ISAdInfo!) {
        print("Interstitial ad close - \(adInfo.description)")
        print("didClose.")
        
    }
}
extension InterstitialVideoAdVc {
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if layout == "landscape" {
            return .landscape
        }
        else {
            return .portrait
        }
    }
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        if layout == "landscape" {
            return .landscapeLeft
        }
        else {
            return .portrait
        }
    }
    override var shouldAutorotate: Bool {
        return true
    }
    
}

//MARK:- PlayerViewcontroller Methods
extension InterstitialVideoAdVc
{
    func setUpContentPlayer() {
        // Load AVPlayer with path to your content.
        let contentURL = URL(string: "nil")!
        let player = AVPlayer(url: contentURL)
        playerViewController = AVPlayerViewController()
        playerViewController.player = player
        playerViewController.showsPlaybackControls = true
        
        // Set up your content playhead and contentComplete callback.
        contentPlayhead = IMAAVPlayerContentPlayhead(avPlayer: player)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(InterstitialVideoAdVc.contentDidFinishPlaying(_:)),
            name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
            object: player.currentItem);
        showContentPlayer()
    }
    func showContentPlayer() {
        self.addChild(playerViewController)
        playerViewController.view.frame = self.view.bounds
        self.view.insertSubview(playerViewController.view, at: 0)
        playerViewController.didMove(toParent:self)
    }
    func hideContentPlayer() {
        // The whole controller needs to be detached so that it doesn't capture  events from the remote.
        playerViewController.willMove(toParent:nil)
        playerViewController.view.removeFromSuperview()
        playerViewController.removeFromParent()
    }
    func setUpAdsLoader() {
        adsLoader = IMAAdsLoader(settings: nil)
        adsLoader.delegate = self
    }
    func requestAds() {
        // Create ad display container for ad rendering.
        let adDisplayContainer = IMAAdDisplayContainer(adContainer: self.view, viewController: self)
        // Create an ad request with our ad tag, display container, and optional user context.
        let request = IMAAdsRequest(
            adTagUrl: AdTagURLString,
            adDisplayContainer: adDisplayContainer,
            contentPlayhead: contentPlayhead,
            userContext: nil)
        adsLoader.requestAds(with: request)
    }
    @objc func contentDidFinishPlaying(_ notification: Notification)
    {
        adsLoader.contentComplete()
    }
    func manageRewardPoints() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name("RewardPoints"), object: self.rewardPointsReceived)
        }
    }
}
//MARK:- IMAAdsLoader Delegate
extension InterstitialVideoAdVc : IMAAdsLoaderDelegate {
    func adsLoader(_ loader: IMAAdsLoader, failedWith adErrorData: IMAAdLoadingErrorData) {
        print("Error loading ads: " + adErrorData.adError.message!)
        showContentPlayer()
        playerViewController.player?.play()
    }
    func adsLoader(_ loader: IMAAdsLoader, adsLoadedWith adsLoadedData: IMAAdsLoadedData) {
        // Grab the instance of the IMAAdsManager and set yourself as the delegate.
        adsManager = adsLoadedData.adsManager
        adsManager.delegate = self
        adsManager.initialize(with: nil)
    }
}
//MARK:- IMAAdsManager Delegate
extension InterstitialVideoAdVc : IMAAdsManagerDelegate {
    func adsManager(_ adsManager: IMAAdsManager, didReceive event: IMAAdEvent) {
        if event.type == IMAAdEventType.LOADED {
            //            print("Load")
            adsManager.start()
        }
        else if event.type == IMAAdEventType.COMPLETE {
            //            print("Complete")
            self.manageRewardPoints()
            //            self.buttonClick()
        }
        else if event.type == IMAAdEventType.SKIPPED {
            //            print("skip")
            self.manageRewardPoints()
        }
        else if event.type == IMAAdEventType.RESUME {
            //            print("resume")
            //            self.manageRewardPoints()
        }
        else if event.type == IMAAdEventType.PAUSE {
            //            print("pause")
            //            self.manageRewardPoints()
        }
        else if event.type == IMAAdEventType.TAPPED {
            //            print("tapped")
            //            self.manageRewardPoints()
        }
        else if event.type == IMAAdEventType.CLICKED {
            //            print("clicked")
            //            self.manageRewardPoints()
        }
        else if event.type == IMAAdEventType.AD_PERIOD_STARTED {
            //            print("ad started")
            //            self.manageRewardPoints()
        }
        else if event.type == IMAAdEventType.AD_PERIOD_ENDED {
            //            print("ad ended")
            //            self.manageRewardPoints()
        }
    }
    func adsManager(_ adsManager: IMAAdsManager, didReceive error: IMAAdError) {
        // Fall back to playing content
        print("AdsManager error: " + error.message!)
        showContentPlayer()
        playerViewController.player?.play()
    }
    func adsManagerDidRequestContentPause(_ adsManager: IMAAdsManager) {
        // Pause the content for the SDK to play ads.
        playerViewController.player?.pause()
        hideContentPlayer()
    }
    func adsManagerDidRequestContentResume(_ adsManager: IMAAdsManager) {
        // Resume the content since the SDK is done playing ads (at least for now).
        showContentPlayer()
        playerViewController.player?.play()
    }
}
extension UINavigationController {
    
    open override var shouldAutorotate: Bool {
        return true
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return (visibleViewController?.supportedInterfaceOrientations)!
    }
}
extension InterstitialVideoAdVc : AdColonyInterstitialDelegate {
    func adColonyInterstitialDidLoad(_ interstitial: AdColonyInterstitial) {
        self.adColonyInterstitial = interstitial
        if let ad = self.adColonyInterstitial, !ad.expired {
            ad.show(withPresenting: self)
            webSc.trackingUrl(url: self.dictResponse["imp_url"] as! String)
            
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
        self.manageIntVideo()
    }
    func adColonyInterstitialExpired(_ interstitial: AdColonyInterstitial) {
        print("adColonyInterstitialExpired")
        
        self.adColonyInterstitial = nil
        //        self.requestInterstitial()
    }
    
    func adColonyInterstitialDidClose(_ interstitial: AdColonyInterstitial) {
        print("adColonyInterstitialDidClose")
        
        self.adColonyInterstitial = nil
        self.buttonClick()
        //        self.requestInterstitial()
    }
    func adColonyInterstitialDidReceiveClick(_ interstitial: AdColonyInterstitial) {
        print("adColonyInterstitialDidReceiveClick")
        print("adColonyInterstitialDidReceiveClick")
        webSc.trackingUrl(url: self.dictResponse["click_url"] as! String)
        
        
    }
    func adColonyInterstitialWillLeaveApplication(_ interstitial: AdColonyInterstitial) {
        print("adColonyInterstitialWillLeaveApplication")
        
    }
    func manageIntVideo() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name("adColonyIntVideo"), object:self.strError )
        }
    }
}
