//
//  BasicAd.swift
//  SDK_Lib
//
//  Created by Djax on 15/04/23.
//

import UIKit
import WebKit

class BasicAd: UIViewController {
   
    var web = WKWebView()
    var frameNew = CGRect()
    var closeAction:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    func create_Basic_ad(frame:CGRect) -> WKWebView
    {
        frameNew = frame
        web = WKWebView(frame: CGRect(x: frameNew.origin.x , y: 0, width:frameNew.width , height: 60) )
        print(web.frame)
        web.isOpaque = true
        web.scrollView.maximumZoomScale = 1.0
        web.isUserInteractionEnabled = true
        web.allowsBackForwardNavigationGestures = true
        web.allowsLinkPreview = true
        web.configuration.preferences.javaScriptEnabled = true
        web.uiDelegate = self
        web.navigationDelegate = self
        return web
    }
    func html_update_method1(str:String) {
        web.loadHTMLString("<html><meta name=viewport content=width=device-width, shrink-to-fit=YES><body style='margin:0.0px;'>\(str)</body></html>", baseURL: nil)
    }
    func html_update_method2(str:String,width:Int,height:Int,fromStr:String) -> WKWebView  {
        web = WKWebView(frame: CGRect(x: frameNew.origin.x , y:0, width:self.view.frame.size.width, height: CGFloat(height)) )
        web.isOpaque = true
        web.scrollView.maximumZoomScale = 1.0
        web.isUserInteractionEnabled = true
        web.allowsBackForwardNavigationGestures = true
        web.allowsLinkPreview = true
        web.configuration.preferences.javaScriptEnabled = true
        web.uiDelegate = self
        web.navigationDelegate = self
        web.loadHTMLString("<html><meta name=viewport content=width=device-width, shrink-to-fit=YES><body style='margin:0.0px;'>\(str)</body></html>", baseURL: nil)
        return web
    }
    class func getMyImage() -> UIImage? {
        let bundle = Bundle(for: self)
        return UIImage(named: "close.png", in: bundle, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
    }
    @objc func buttonClick() {
        self.web.isHidden = true
        self.closeAction = true
        self.manageRewardPoints()
    }
    func manageRewardPoints() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name("TopBanner"), object: self.closeAction)
        }
    }
}
extension BasicAd: WKUIDelegate, WKNavigationDelegate {
    //Navigate to corresponding destination url method
    func webView(_ webView: WKWebView, createWebViewWith inConfig: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        var webView = webView
        webView = WKWebView(frame: web.frame, configuration: inConfig)
        if !(navigationAction.targetFrame?.isMainFrame ?? false) {
            if let URL = navigationAction.request.url {
                UIApplication.shared.open(URL, options: [:]) { success in
                    if success {}}}}
        return webView
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!)
    {
        UserDefaults.standard.set(true, forKey: "InternalBannerAdDelivered")
        print("\(Webview) -- \(Finish_reqest) -- \(String(describing: webView.url!))")
    }
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("\(Webview) -- \(start_request)")
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("\(Webview) -- \(Failed_to_load) -- \(error.localizedDescription)")
    }
}
