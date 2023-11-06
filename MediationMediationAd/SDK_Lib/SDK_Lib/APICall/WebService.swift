//
//  WebService.swift
//  SDK_Lib
//
//  Created by Djax on 30/08/22.
//

import Foundation
import UIKit
import CommonCrypto

class WebService {
    var response_Dict : Dictionary<String,AnyObject> = [:]
}
extension WebService {
    func requestAPIResponse(url:String,theRequest: URLRequest, header headerParams: inout [AnyHashable : Any],completion: @escaping (Dictionary<String,AnyObject>) -> Void) {
        let session = URLSession.shared
            let mData = session.dataTask(with: theRequest ) { (data, response, error) -> Void in
            guard let _ = data,
                  error == nil else {
                print("\(Error) -   \(error?.localizedDescription ?? "Response Error")")
                return
            }
            do{
                UserDefaults.standard.removeObject(forKey: "apiResponse")
                //here dataResponse received from a network request
                let str = String(decoding: data!, as: UTF8.self)
                var dictonary:NSDictionary?
                if let data = str.data(using: String.Encoding.utf8) {
                    do {
                        dictonary = try JSONSerialization.jsonObject(with: data, options: [])  as! NSDictionary?
                        do {
                            guard let _ = try? JSONSerialization.data(withJSONObject: dictonary!, options: []) else {
                                // Log error
                                return
                            }
                            
                            //self.response_Dict = dictonary as! Dictionary<String, AnyObject>
                            let encodedData = try NSKeyedArchiver.archivedData(withRootObject: dictonary!, requiringSecureCoding: false)
                            UserDefaults.standard.set(encodedData, forKey: "apiResponse")
                            completion(dictonary as! Dictionary<String, AnyObject>)
                        }
                    }
                    catch let error as NSError {
                        print("\(Error) -   \(error.localizedDescription)")
                    }
                }
            }
        }
        mData.resume()
    }
    func trackingUrl(url:String) {
        guard let url = URL(string: url) else { return }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
          guard let data = data, error == nil else { return }
            print("trakcing error \(error.debugDescription)")
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
            }
            catch {
                print(error.localizedDescription.debugDescription)
            }
        }
        task.resume()
    }
}
extension String {
    func sha1() -> String {
        let data = Data(self.utf8)
        var digest = [UInt8](repeating: 0, count:Int(CC_SHA1_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA1($0.baseAddress, CC_LONG(data.count), &digest)
        }
        let hexBytes = digest.map { String(format: "%02hhx", $0) }
        return hexBytes.joined()
    }
}
