//
//  UserInputVc.swift
//  Demo_App
//
//  Created by Djax on 26/07/22.
//

import UIKit
import SDK_Lib
import CoreTelephony
import SystemConfiguration

class UserInputVc: UIViewController
{
    @IBOutlet weak var zoneIdTf: UITextField!
    @IBOutlet weak var adLoadBtn: UIButton!
    
    var adResponse = AdResponse()
    
    var dicSet = [String:Any]()

    override func viewDidLoad()
    {
        super.viewDidLoad()

      
    }
    override func viewWillAppear(_ animated: Bool)
    {
        navigationItem.title = UserDefaults.standard.object(forKey: "selectedItem") as? String
        navigationController?.navigationBar.backgroundColor = UIColor(red: 0.0 / 255.0, green: 116.0 / 255.0, blue: 183.0 / 255.0, alpha: 1.0)
        if let font = UIFont(name: "Times New Roman", size: 20) {
            navigationController?.navigationBar.titleTextAttributes = [
                NSAttributedString.Key.font: font,
                NSAttributedString.Key.foregroundColor: UIColor.white
            ]
        }
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.backItem?.title = ""
    }
    override func viewDidAppear(_ animated: Bool) {
        self.zoneIdTf.becomeFirstResponder()
    }
    @IBAction func adLoadBtnAction(sender:UIButton)
    {
        if zoneIdTf.text == ""
        {
            let alert = UIAlertController(title: "Error", message: "Enter your zone id", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default))
            self.present(alert, animated: true)
        }
        else if zoneIdTf.text != ""
        {
            adResponse.getUserDefaultValue(zones: self.zoneIdTf.text ?? "", str: "SDK")
            let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController") as! ViewController
            nextVC.zoneId = zoneIdTf.text!
            self.navigationController?.pushViewController(nextVC, animated: false)
        }
    }
}
//MARK: - UITextField Delegate
extension UserInputVc: UITextFieldDelegate
{
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        textField.resignFirstResponder()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        if textField == zoneIdTf
        {
            textField.resignFirstResponder()
        }
        return true
    }
}
