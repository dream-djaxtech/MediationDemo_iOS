//
//  HomePage.swift
//  Demo_App
//
//  Created by Djax on 17/08/22.
//

import UIKit


class HomePage: UIViewController {
    
    @IBOutlet weak var loginBtn: UIButton!
    
    @IBOutlet weak var phoneNoTf: UITextField!
    @IBOutlet weak var ageTf: UITextField!
    @IBOutlet weak var genderTf: UITextField!
    @IBOutlet weak var emailTf: UITextField!
    @IBOutlet weak var nameTf: UITextField!
    
    var arrayOfArray : NSMutableArray = []
    var loginInfo :Dictionary<String,AnyObject> = [:]
    var loginDetails :Array<Dictionary<String,AnyObject>> = []
    var arryInfo : Array<Dictionary<String,AnyObject>> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func loginBtn(_ sender: Any) {
        arryInfo.removeAll()
        let parameterDictionary = ["name" : nameTf.text!,
                                   "email" : emailTf.text!,
                                   "gender" : genderTf.text!,
                                   "phoneno" : phoneNoTf.text!,
                                   "age" : ageTf.text!] as [String:AnyObject]
        
        let parameterDictionary1 = ["user_info" : parameterDictionary] as [String:AnyObject]
        arryInfo.append(parameterDictionary1)
        self.loginInfo = arryInfo[0]["user_info"]! as! Dictionary<String, AnyObject>
        self.getCustomParam()
    }
    
    func getCustomParam() {
        let session = URLSession.shared
        let url = "https://app.yeahads.net/api/target_api.php"
        let request = NSMutableURLRequest(url: NSURL(string: url)! as URL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        var params :[String: Any]?
        params = [:]
        do{
            request.httpBody = try JSONSerialization.data(withJSONObject: params!, options: JSONSerialization.WritingOptions())
            let task = session.dataTask(with: request as URLRequest as URLRequest, completionHandler: {(data, response, error) in
                if let response = response {
                    let nsHTTPResponse = response as! HTTPURLResponse
                    let _ = nsHTTPResponse.statusCode
                }
                if let error = error {
                    print ("\(error)")
                }
                DispatchQueue.main.async {
                    
                    if let data = data {
                        do{
                            self.nameTf.text = ""
                            self.phoneNoTf.text = ""
                            self.ageTf.text = ""
                            self.emailTf.text = ""
                            self.genderTf.text = ""
                            
                            let resultJson = try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]
                            var dictInfo = [String: String]()
                            var arrayKey : Array<String> = []
                            var arrayValue : Array<String> = []
                            
                            var loginArrayKey : Array<String> = []
                            loginArrayKey.removeAll()
                            for (key,_) in self.loginInfo {
                                loginArrayKey.append(key)
                            }
                            if let dictionary = resultJson {
                                let dict = dictionary["custom_target_info"] as! [String : String]
                                dictInfo = dict
                                if dict is [String: String] {
                                    arrayKey.removeAll()
                                    arrayValue.removeAll()
                                    for (_, key) in dictInfo.enumerated() {
                                        arrayValue.append(key.value)
                                        arrayKey.append(key.key)
                                    }
                                }
                            }
                            for i in (0 ..< arrayValue.count) {
                                for j in (0 ..< loginArrayKey.count) {
                                    if loginArrayKey[j].contains(arrayValue[i]) {
                                        dictInfo.updateValue(self.loginInfo[loginArrayKey[j]] as! String, forKey: arrayValue[i])
                                        arrayValue[i] = self.loginInfo[loginArrayKey[j]] as! String
                                    }
                                }
                                if arrayValue[i].contains(arrayKey[i]) {
                                    dictInfo.updateValue("", forKey: arrayValue[i])
                                    arrayValue[i] = ""
                                }
                            }
                            
                            let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserInputVc") as! UserInputVc
                            nextVC.dicSet = dictInfo  as [String : Any]
                            self.navigationController?.pushViewController(nextVC, animated: false)
                            
                        }catch _ {
                            print ("OOps not good JSON formatted response")
                        }
                    }
                }
            })
            task.resume()
        }catch _ {
            print ("Oops something happened buddy")
        }
    }
    
}

extension Dictionary {
    func contains(key: Key) -> Bool {
        self.index(forKey: key) != nil
    }
}
