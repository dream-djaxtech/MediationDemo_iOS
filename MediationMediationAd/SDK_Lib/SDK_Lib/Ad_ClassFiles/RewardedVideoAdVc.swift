//
//  Rewarded_Video_Ads.swift
//  SDK_Lib
//
//  Created by Djax on 05/09/22.
//

import UIKit
import AVFoundation
import ChartboostSDK
import IronSource
import UnityAds
import AdColony
import GoogleInteractiveMediaAds

class RewardedVideoAdVc: UIViewController {
    
    var adColonyInterstitial: AdColonyInterstitial? = nil //Interstitial

    var AdTagURLString = ""
    var layout = ""
    var playerViewController: AVPlayerViewController!
    var contentPlayhead: IMAAVPlayerContentPlayhead?
    var adsLoader: IMAAdsLoader!
    var adsManager: IMAAdsManager!
    
    var strError:String? = ""

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    var rewardPointsReceived : Array<Dictionary<String,AnyObject>> = []
    
    weak var interstitialImage_Delegate : Ad_Delegate?
    
    var statusBarState = false
    
    override var prefersStatusBarHidden: Bool{
        return statusBarState
    }
    var fromStr:String? = ""

    var mediationNetworkType:String? = ""
    var mediationNetwork:String? = ""
    private lazy var rewarded = CHBRewarded(location: "default", delegate: self)

    
      var dictResponse :[String:AnyObject] = [:]

      let webSc = WebService()
    
    var adInt: AdColonyInterstitial?

    override func viewWillAppear(_ animated: Bool) {
        statusBarState = true
        self.interstitialImage_Delegate?.managerWillPresentInterstitial(fromStr: Interstitial_Video)
        if layout == "landscape" {
            let value = UIInterfaceOrientation.landscapeLeft.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
        }
        else {
            let value = UIInterfaceOrientation.portrait.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
        }
        UIDevice.current.setValue("landscape", forKey: "orientation")
        UIView.animate(withDuration: 0.5) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
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
        
//        self.interstitialImage_Delegate?.managerWillDismissInterstitial(fromStr: Interstitial_Video)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clear
        let button = UIButton(frame: CGRect(x: 100, y: 60, width: 40, height: 40))
        button.setImage(InterstitialVideoAdVc.getMyImage()?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: .normal)
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
        super.viewDidAppear(animated);
  
        print(self.dictResponse)
        print(self.mediationNetworkType)
        print(self.mediationNetwork)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if self.mediationNetworkType == AdType_Mediation_Network {
                if self.dictResponse["ad_network_type"] as? String == AdType_Internal_Unity {
                    self.loadRewardedAdUnity()
                }
                else if  self.dictResponse["ad_network_type"] as? String == AdType_Internal_IronSource {
                    self.rewardedAction()
                }
                else if  self.dictResponse["ad_network_type"] as? String == AdType_Internal_ChartBoost {
                    self.rewardedAd()
                }
                else if self.dictResponse["ad_network_type"] as? String == AdType_Internal_AdColony {
//                    self.loadAds()
                    self.loadAdsAdColony()
                }
            }
            else if self.mediationNetwork == AdType_Internal_Network {
                self.requestAds()
            }
        }
    }
    func loadAdsAdColony(){
        let placeId = self.dictResponse["ad_tag"] as! [String:AnyObject]
print(placeId)
        let rewardedZones:Array<String> = [placeId["zone_id"] as! String]
        print(rewardedZones)
        AdColony.configure(withAppID: placeId["app_id"] as! String, options: nil) { [weak self] (zones) in
            print(zones)
            for zone in zones {
                print(zone)
                if rewardedZones.contains(zone.identifier) {
                    let zone = zones.first
                    print(zone)
                    zone?.setReward({ [weak self] (success, name, amount) in
                        if (success) {
                            print(success.description)
                            print(name)
                            print(amount)
                        }
                    })
                }
            }
        }
        let options = AdColonyAdOptions()
        options.showPrePopup = false
        options.showPostPopup = false
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            AdColony.requestInterstitial(inZone: placeId["zone_id"] as! String, options: options, andDelegate: self)
            self.loadAdColony()
//        }
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
    @objc func becomeactive() {
        adsManager.resume()
        adsManager.start()
    }
    @objc func shutItDown() { }
    //Chartboost
    func rewardedAd() {
//        self.rewarded.cache()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//            DispatchQueue.main.async {
                    self.rewarded.show(from: self)
//                }
            }
    }
    //Ironsource
    func rewardedAction() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                IronSource.showRewardedVideo(with: self)
            }
        }
    }
    //Unity
    func loadRewardedAdUnity() {
        if dictResponse.count != 0  {
              
                                                let placeId = dictResponse["ad_tag"] as! [String:AnyObject]
                                                UnityAds.show(self, placementId: placeId["placement_id"] as! String, showDelegate: self)
//                        UnityAds.show(self, placementId:  self.dictResponse["ad_tag"]?["placement_id"] as! String, showDelegate: self)
                        
                        //                    }
                
            }
        }
}
//MARK:- button actions
extension RewardedVideoAdVc
{
    @objc func buttonClick() {
        self.dismiss(animated: true)
    }
    class func getMyImage() -> UIImage? {
        let bundle = Bundle(for: self)
        return UIImage(named: "close.png", in: bundle, compatibleWith: nil)
    }
}

extension RewardedVideoAdVc : CHBRewardedDelegate {
    func didEarnReward(_ event: CHBRewardEvent) {
       print("didEarnReward: " + String(event.reward))
    }
    func didDismissAd(_ event: CHBDismissEvent) {
        print("didDismissAd: \(type(of: event.ad))")
        self.buttonClick()
    }
    func didRecordImpression(_ event: CHBImpressionEvent) {
        print("didRecordImpression")
        webSc.trackingUrl(url: self.dictResponse["imp_url"] as! String)
    }
    func didClickAd(_ event: CHBClickEvent, error: CHBClickError?) {
        print("didClickAd")
            webSc.trackingUrl(url: self.dictResponse["click_url"] as! String)
        
        print(error.debugDescription)
    }
   
}
extension RewardedVideoAdVc : LevelPlayRewardedVideoDelegate {
    func didFailToShowWithError(_ error: Error!, andAdInfo adInfo: ISAdInfo!) {
        print("didFailToShowWithError")
        print(error)

    }
    
    func didOpen(with adInfo: ISAdInfo!) {
        print("didOpen")

    }
    
    func didClose(with adInfo: ISAdInfo!) {
        print("didClose")

    }
    
    func hasAvailableAd(with adInfo: ISAdInfo!) {
        print("hasAvailableAd")

    }
    func hasNoAvailableAd() {
        print("hasNoAvailableAd")

    }
    func didReceiveReward(forPlacement placementInfo: ISPlacementInfo!, with adInfo: ISAdInfo!) {
        print("didReceiveReward")

    }
    func didClick(_ placementInfo: ISPlacementInfo!, with adInfo: ISAdInfo!) {
        print("didClick")

    }
    func rewardedVideoHasChangedAvailability(_ available: Bool) {
       
        print("rewardedVideoHasChangedAvailability")

    }
    func didReceiveReward(forPlacement placementInfo: ISPlacementInfo!) {
        print("didReceiveReward")

    }
    func rewardedVideoDidFailToShowWithError(_ error: Error!) {
        print(error)

        print("rewardedVideoDidFailToShowWithError")

    }
    func rewardedVideoDidOpen() {
        print("rewardedVideoDidOpen")

    }
    func rewardedVideoDidClose() {
        print("rewardedVideoDidClose")

    }
    func rewardedVideoDidStart() {
        print("rewardedVideoDidStart")

    }
    func rewardedVideoDidEnd() {
        print("rewardedVideoDidEnd")

    }
    func didClickRewardedVideo(_ placementInfo: ISPlacementInfo!) {
        print("didClickRewardedVideo")

    }
}
extension RewardedVideoAdVc : UnityAdsShowDelegate {
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
extension RewardedVideoAdVc : UnityAdsLoadDelegate {
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
extension RewardedVideoAdVc {
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

//MARK:- button actions
extension RewardedVideoAdVc
{

    func manageRewardPoints() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name("RewardPoints"), object: self.rewardPointsReceived)
        }
    }
}
//MARK:- PlayerViewcontroller Methods
extension RewardedVideoAdVc
{
    func setUpContentPlayer() {
        // Load AVPlayer with path to your content.
        let contentURL = URL(string: "nil")!
        let player = AVPlayer(url: contentURL)
        playerViewController = AVPlayerViewController()
        playerViewController.player = player
        playerViewController.showsPlaybackControls = false

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
}
//MARK:- IMAAdsLoader Delegate
extension RewardedVideoAdVc : IMAAdsLoaderDelegate {
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
extension RewardedVideoAdVc : IMAAdsManagerDelegate {
    func adsManager(_ adsManager: IMAAdsManager, didReceive event: IMAAdEvent) {
        // Play each ad once it has been loaded
        if event.type == IMAAdEventType.LOADED {
            adsManager.start()
        }
        else if event.type == IMAAdEventType.COMPLETE {
            self.manageRewardPoints()
//            self.buttonClick()
        }
        else if event.type == IMAAdEventType.SKIPPED {
            self.manageRewardPoints()
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
extension RewardedVideoAdVc : AdColonyInterstitialDelegate {
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
            self.manageRewVideo()
    }
    func adColonyInterstitialExpired(_ interstitial: AdColonyInterstitial) {
        print("adColonyInterstitialExpired")

        self.adColonyInterstitial = nil
        //        self.requestInterstitial()
    }
    
    func adColonyInterstitialDidClose(_ interstitial: AdColonyInterstitial) {
        print("adColonyInterstitialDidClose")
        self.buttonClick()

        self.adColonyInterstitial = nil
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
    func manageRewVideo() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name("adColonyRewVideo"), object:self.strError )
        }
    }
}
