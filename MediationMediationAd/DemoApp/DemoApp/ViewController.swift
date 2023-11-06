//
//  ViewController.swift
//  DemoApp
//
//  Created by Djax on 23/08/22.
//

import UIKit
import SDK_Lib
import CoreTelephony

class ViewController: UIViewController {
    
    @IBOutlet var listView: UITableView!
    
    var imageArray :Array<Any> = []
    var videoArray :Array<Any> = []
    var adResponse = AdResponse()
    
    var zoneId: String? = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.title = "dJAX Mediation Demo App"
        imageArray = ["Image Ad","Interstitial Image Ad"]
        videoArray = ["Rewarded Video Ad", "Interstitial Video Ad"]
        self.registerTableViewCells()
    }
    func registerTableViewCells() {
        listView.dataSource = self
        listView.delegate = self
        self.listView.reloadData()
    }
}
//MARK: - UITableView DataSource & Delegate
extension ViewController: UITableViewDelegate,UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return imageArray.count
        }
        else if section == 1 {
            return videoArray.count
        }
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:  "reuseCell") as? ListTvCell
        if indexPath.section == 0 {
            cell!.titleLblNew.text = imageArray[indexPath.row] as? String
            cell!.titleImgNew.image = UIImage(named: "send_b.png")
            cell!.clickBtn.tag = indexPath.row
            cell!.clickBtn.addTarget(self, action: #selector(ViewController.selectedItemBtn(_:)), for: .touchUpInside)
        }
        else if indexPath.section == 1 {
            cell!.titleLblNew.text = videoArray[indexPath.row] as? String
            cell!.titleImgNew.image = UIImage(named: "send_r.png")
            cell!.clickBtn.tag = indexPath.row
            cell!.clickBtn.addTarget(self, action: #selector(ViewController.selectedItemBtn(_:)), for: .touchUpInside)
        }
        return cell!
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    @objc func selectedItemBtn(_ sender: UIButton) {
        let buttonPosition:CGPoint = sender.convert(CGPoint(), to: self.listView)
        let indexP = self.listView.indexPathForRow(at: buttonPosition)
        if indexP?.section == 0 {
            if self.imageArray[indexP!.row] as! String == "Image Ad"
            {
                let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BannerAd_Vc") as! BannerAd_Vc
                self.navigationController?.pushViewController(nextVC, animated: false)
            }
            else if self.imageArray[indexP!.row] as! String == "Interstitial Image Ad"
            {
                let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "InterstitialImageAd") as! Interstitial_Image_Ad
                self.navigationController?.pushViewController(nextVC, animated: false)
            }
        }
        if indexP?.section == 1 {
            if self.videoArray[indexP!.row] as! String == "Rewarded Video Ad"
            {
                let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Rewarded_Video_Ad") as! Rewarded_Video_Ad
                self.navigationController?.pushViewController(nextVC, animated: false)
            }
            else if self.videoArray[indexP!.row] as! String == "Interstitial Video Ad"
            {
                let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "InterstitialImageAd") as! Interstitial_Image_Ad
                nextVC.fromPage = self.videoArray[indexP!.row] as? String
                self.navigationController?.pushViewController(nextVC, animated: false)
            }
            
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let img = UIImageView()
        img.frame = CGRect(x: 12, y: 10, width: 30, height: 30)
        
        let myLabel = UILabel()
        myLabel.frame = CGRect(x: 55, y: 6, width: 320, height: 30)
        myLabel.font = UIFont(name: "Times New Roman", size: 25)
        myLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
        
        if section == 0 {
            img.image = UIImage(named: "video.png")
        }
        else if section == 1 {
            img.image = UIImage(named: "video_r.png")
        }
        
        let myLabel1 = UILabel()
        myLabel1.frame = CGRect(x: 0, y: 47, width: UIScreen.main.bounds.size.width, height: 1)
        myLabel1.backgroundColor = UIColor(red: 0.0 / 255.0, green: 116.0 / 255.0, blue: 183.0 / 255.0, alpha: 1.0)
        
        let headerView = UIView()
        headerView.addSubview(myLabel)
        headerView.addSubview(img)
        headerView.addSubview(myLabel1)
        return headerView
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Basic Ads"
        }
        else if section == 1 {
            return "Video Ads"
        }
        return ""
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(50)
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(40)
    }
    
}
