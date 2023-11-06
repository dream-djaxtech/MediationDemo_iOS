//
//  Interstitial_Image_Ad.swift
//  DemoApp
//
//  Created by Djax on 08/09/22.
//

import UIKit
import SDK_Lib

class Interstitial_Image_Ad: UIViewController {
    
    @IBOutlet weak var svView: UIScrollView!
    
    var adResponse = AdResponse()
    var fromPage :String? = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if fromPage == "Interstitial Video Ad" {
            adResponse.interstitialVideoAdIntegration()
        } else {
            adResponse.interstitialImageAdIntegration()
        }
    }
}
