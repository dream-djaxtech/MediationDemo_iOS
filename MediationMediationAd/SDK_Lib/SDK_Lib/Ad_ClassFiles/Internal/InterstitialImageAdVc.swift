//
//  Interstitial_Image_Ad.swift
//  SDK_Lib
//
//  Created by Djax on 23/08/22.
//

import UIKit
import WebKit

protocol Ad_Delegate : AnyObject {
    func managerDidLoadInterstitial(fromStr:String)
    func managerWillPresentInterstitial(fromStr:String)
    func managerDidPresentInterstitial(fromStr:String)
    func managerWillDismissInterstitial(fromStr:String)
    func managerDidDismissInterstitial(fromStr:String)
    func managerDidReceiveTapEventFromInterstitial(fromStr:String)
    func didFailToLoadInterstitialWithError(str:String)
}
class InterstitialImageAdVc: UIViewController {
    
    var adStatus: String? = ""

    var web_Interstitial_image = WKWebView()
    weak var interstitialImage_Delegate : Ad_Delegate?
    
    var statusBarState = false
    override var prefersStatusBarHidden: Bool{
        return statusBarState
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.interstitialImage_Delegate?.managerDidLoadInterstitial(fromStr: Interstitial_Image)
        self.view.backgroundColor = UIColor.white
    }
    override func viewWillAppear(_ animated: Bool) {
        statusBarState = true
        UIView.animate(withDuration: 0.5) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
        self.interstitialImage_Delegate?.managerWillPresentInterstitial(fromStr: Interstitial_Image)
    }
    override func viewDidAppear(_ animated: Bool) {
        self.interstitialImage_Delegate?.managerDidPresentInterstitial(fromStr: Interstitial_Image)
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.interstitialImage_Delegate?.managerWillDismissInterstitial(fromStr: Interstitial_Image)
    }
    override func viewDidDisappear(_ animated: Bool) {
        self.interstitialImage_Delegate?.managerDidDismissInterstitial(fromStr: Interstitial_Image)
    }
    class func getMyImage() -> UIImage? {
        let bundle = Bundle(for: self)
        return UIImage(named: "close.png", in: bundle, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
    }
    class func getBackImage() -> UIImage? {
        let bundle = Bundle(for: self)
        return UIImage(named: "back.png", in: bundle, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
    }
    func create_ad(str:String) -> WKWebView
    {
        self.view.backgroundColor = UIColor.white
        
        web_Interstitial_image = WKWebView()
        web_Interstitial_image.frame =  CGRect(x: 0 , y: 0, width: UIScreen.main.bounds.size.width , height: UIScreen.main.bounds.size.height)
        web_Interstitial_image.uiDelegate = self
        web_Interstitial_image.navigationDelegate = self
        
        let button = UIButton(frame: CGRect(x: 100, y: 60, width: 40, height: 40))
        button.setImage(InterstitialImageAdVc.getMyImage(), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(buttonClick), for: .touchUpInside)
        
        let backBtn = UIButton(frame: CGRect(x: 30, y: 60, width: 40, height: 40))
        backBtn.setImage(InterstitialImageAdVc.getBackImage(), for: .normal)
        backBtn.translatesAutoresizingMaskIntoConstraints = false
        backBtn.addTarget(self, action: #selector(buttonClick), for: .touchUpInside)
        self.view.addSubview(web_Interstitial_image)
        
        if adStatus == "Bottom Slider Ad" {
            button.isHidden = true
            backBtn.isHidden = false
            self.view.addSubview(backBtn)
            self.view.bringSubviewToFront(backBtn)
            NSLayoutConstraint.activate([
                backBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
                backBtn.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0),
                backBtn.widthAnchor.constraint(equalToConstant: 40),
                backBtn.heightAnchor.constraint(equalToConstant: 40)
            ])
        }
        else {
            self.view.addSubview(button)
            button.isHidden = false
            self.view.bringSubviewToFront(button)
            backBtn.isHidden = true
            NSLayoutConstraint.activate([
                button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
                button.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
                button.widthAnchor.constraint(equalToConstant: 75),
                button.heightAnchor.constraint(equalToConstant: 75)
            ])
          
        }
        let htmlStr = "<!DOCTYPE html><html><style type='text/css'>html,body {margin: 0;padding: 0;width: 100%;height: 100%;}html {display: table;}body {display: table-cell;vertical-align: middle;text-align: center;}</style><meta name=\"viewport\" content=\"user-scalable=no, width=device-width\"><body style= \"width=\"100%\";height=\"100%\";initial-scale=\"1.0\"; maximum-scale=\"1.0\"; user-scalable=\"no\";\">" + str + "</body></html>"
        web_Interstitial_image.loadHTMLString(htmlStr, baseURL: nil)
        return web_Interstitial_image
    }
    func html_tag_update(str:String)  {
        web_Interstitial_image = self.create_ad(str: str)
    }
    @objc func buttonClick() {
        self.dismiss(animated: true)
    }
}
extension InterstitialImageAdVc: WKUIDelegate, WKNavigationDelegate {
    //Navigate to corresponding destination url method
    func webView(_ webView: WKWebView, createWebViewWith inConfig: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        var webView = webView
        webView = WKWebView(frame: web_Interstitial_image.frame, configuration: inConfig)
        
        if !(navigationAction.targetFrame?.isMainFrame ?? false) {
            if let URL = navigationAction.request.url {
                UIApplication.shared.open(URL, options: [:]) { success in
                    if success {
                    }
                }
            }
        }
        return webView
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("\(Ad_Interstitial_Image) -- \(Finish_reqest) -- \(String(describing: webView.url!))")
    }
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("\(Ad_Interstitial_Image) -- \(start_request)")
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("\(Ad_Interstitial_Image) -- \(Failed_to_load) -- \(error.localizedDescription)")
    }
}
extension InterstitialImageAdVc : Ad_Delegate{
    func managerDidLoadInterstitial(fromStr: String) {
        print("\(fromStr) -- \(Interstitial_Load)")
    }
    func managerWillPresentInterstitial(fromStr: String) {
        print("\(fromStr) -- \(Interstitial_Will_Appear)")
    }
    func managerDidPresentInterstitial(fromStr: String) {
        print("\(fromStr) -- \(Interstitial_Did_Appear)")
    }
    func managerWillDismissInterstitial(fromStr: String) {
        print("\(fromStr) -- \(Interstitial_Will_Dismiss)")
    }
    func managerDidDismissInterstitial(fromStr: String) {
        print("\(fromStr) -- \(Interstitial_Did_Dismiss)")
    }
    func managerDidReceiveTapEventFromInterstitial(fromStr: String) {
        print("\(fromStr)")
    }
    func didFailToLoadInterstitialWithError(str: String) {
        print("\(Error) -- \(str)")
    }
}
