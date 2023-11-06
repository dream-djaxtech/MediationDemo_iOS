//
//  Rewarded_Video_Ad.swift
//  DemoApp
//
//  Created by Djax on 05/09/22.
//

import UIKit
import SDK_Lib
import WebKit
import AVFoundation

class Rewarded_Video_Ad: UIViewController {
    
    @IBOutlet weak var rewardPointsLbl: UILabel!
    
    var adResponse = AdResponse()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.adResponse.rewardDelegate = self
        self.adResponse.rewardedAdIntegration()
    }
}
extension Rewarded_Video_Ad : RewardUpdateDelegate {
    func passAPIvalues(point: NSInteger) {
        var receivedInt : Int = 0
        if UserDefaults.standard.string(forKey: "RewardPoint") == "" || UserDefaults.standard.string(forKey: "RewardPoint") == nil
                   {
            receivedInt = point
            UserDefaults.standard.set(receivedInt, forKey: "RewardPoint")
        }
        else if receivedInt != 0 {
            receivedInt = UserDefaults.standard.integer(forKey: "RewardPoint")
            receivedInt = receivedInt + point
            UserDefaults.standard.set(receivedInt, forKey: "RewardPoint")
        }
        self.rewardPointsLbl.text = "Total Reward Points: \n \n \(UserDefaults.standard.string(forKey: "RewardPoint") ?? "")"
    }
    
//    func passAPIvalues(point: Array<Dictionary<String, AnyObject>>) {
////        self.rewardPoints = point
//        var rewardP: Int = 0
//        for i in 0..<self.rewardPoints.count {
//            let dic = self.rewardPoints[i]
//            if UserDefaults.standard.string(forKey: "RewardPoints") == "" || UserDefaults.standard.string(forKey: "RewardPoints") == nil
//            {
//                if dic["amount"] as! String == "" || UserDefaults.standard.string(forKey: "RewardPoints") == "" || UserDefaults.standard.string(forKey: "RewardPoints") == nil {
//                    rewardP = 0
//                }
//                else{
//                    if rewardP == 0 {
//                        rewardP = Int((dic["amount"] as? String)!)! + Int(UserDefaults.standard.string(forKey: "RewardPoints")!)!
//                    }
//                    else {
//                        rewardP = Int((dic["amount"] as? String)!)! + Int(UserDefaults.standard.string(forKey: "RewardPoints")!)!
//                        }
//                }
//                UserDefaults.standard.set(rewardP, forKey: "RewardPoints")
//            }
//            else {
//                if UserDefaults.standard.string(forKey: "RewardPoints") != nil
//                {
//                    if dic["amount"] as! String == "" {
//                        rewardP = 0  + Int(UserDefaults.standard.string(forKey: "RewardPoints")!)!
//                    }
//                    else{
//                        rewardP = Int((dic["amount"] as? String)!)! + Int(UserDefaults.standard.string(forKey: "RewardPoints")!)!
//                    }
//                    UserDefaults.standard.set(rewardP, forKey: "RewardPoints")
//                }
//            }
//        }
//        self.rewardPointsLbl.text = "Total Reward Points: \n \n \(UserDefaults.standard.string(forKey: "RewardPoints") ?? "")"
//    }
}
