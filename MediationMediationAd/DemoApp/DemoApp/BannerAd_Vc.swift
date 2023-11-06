//
//  BannerAd_Vc.swift
//  DemoApp
//
//  Created by Djax on 26/08/22.
//

import UIKit
import SDK_Lib
import WebKit
import GoogleMobileAds

class BannerAd_Vc: UIViewController {

    @IBOutlet weak var svView: UIScrollView!
    @IBOutlet weak var bannerView1: WKWebView!
    @IBOutlet weak var txtLbl: UILabel!
    @IBOutlet weak var txtLbl1: UILabel!

    @IBOutlet weak var webSubView: UIView!

    
    @IBOutlet weak var banner1WebHeightConstraint: NSLayoutConstraint?
    @IBOutlet weak var webSubViewHeightConstraint: NSLayoutConstraint?

    var zoneId: String? = ""
    var strUrl:String? = ""
    var fromPage:String? = ""

    var adResponse = AdResponse()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bannerView1.isHidden = false
        self.banner1WebHeightConstraint?.constant = 0
//        self.webSubViewHeightConstraint?.constant = 0
            adResponse.webViewDelegate = self
        adResponse.imageAdIntegration(fromStr: self.fromPage ?? "",view: webSubView,webV: self.bannerView1)
    }
}
extension BannerAd_Vc : WebViewUpdateDelegate {
    func updateMediationWebView(webV: GADBannerView) {
        webSubViewHeightConstraint?.constant = webV.frame.size.height
        webSubView?.addSubview(webV)
    }
    func updateWebView(webV: WKWebView) {
        webSubViewHeightConstraint?.constant = webV.frame.size.height
        webSubView?.addSubview(webV)
    }
}
