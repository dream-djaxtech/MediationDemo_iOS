//
//  APICall.swift
//  SDK_Lib
//
//  Created by Djax on 23/08/22.
//

import UIKit
import CoreLocation
import AdSupport
import CommonCrypto
import CryptoKit
import WebKit
import CoreTelephony
import Network
import SystemConfiguration
import Foundation

protocol api_Response_Delegate: AnyObject {
    func response_Dict(passValue: Dictionary<String,AnyObject>)
}
class APICall: NSObject {
    
    var display_type :String? = ""
    var zoneId_ApiCall:String? = ""
    var device_type :String? = ""
    var webV = WKWebView()
    var mediationAdId:Int? = 0

    var latitude :String = ""
    var longitude :String = ""
    
    var dictArrays: [String] = []
    var dicSet = [String:Any]()

    let webSc = WebService()
    weak var delegate_API : api_Response_Delegate?
    
    func callApiMethods(zone:String) {
        if UserDefaults.standard.integer(forKey: "isAdtype") != nil {
            if UserDefaults.standard.integer(forKey: "isAdtype") == 1 {
                mediationAdId = 1
            }
            else if UserDefaults.standard.integer(forKey: "isAdtype")  == 2 {
                mediationAdId = 2
            }
            else if UserDefaults.standard.integer(forKey: "isAdtype")  == 0 {
                mediationAdId = 0
            }
        }
        else {
            mediationAdId = 0
        }
        print(mediationAdId)
        print(UserDefaults.standard.integer(forKey: "isAdtype"))
        
        UserDefaults.standard.removeObject(forKey: "isAdtype")
        zoneId_ApiCall = zone
        self.internetConnection()
    }
    func internetConnection() {
        if Reachability.isConnectedToNetwork(){
            self.getLocation()
            self.getParams()
        }else{
            print(Internet_Not_available)
        }
    }
    func getLocation() {
        var locationManager: CLLocationManager?
        locationManager = CLLocationManager()
        locationManager?.requestAlwaysAuthorization()
        locationManager?.startUpdatingLocation()
        latitude = String(Float(locationManager?.location?.coordinate.latitude ?? 0.0))
        longitude = String(Float(locationManager?.location?.coordinate.longitude ?? 0.0))
    }
    func getParams() {
        var system_Language = Locale.preferredLanguages[0]
        let languageDic = NSLocale.components(fromLocaleIdentifier: system_Language)
        let languageCode = languageDic["kCFLocaleLanguageCodeKey"]
        system_Language = languageCode ?? "en"
        
        //Device Type
        if UIDevice.current.userInterfaceIdiom == .pad {
            display_type = "IPAD"
        } else {
            display_type = "Mobile"
        }
        
        device_type = UIDevice.current.model
        if device_type == "iPhone" {
            device_type = "Mobile"
        } else {
            device_type = "Tablet"
        }
        var cnxnTp :String? = ""
        let nwPathMonitor = NWPathMonitor()
        nwPathMonitor.pathUpdateHandler = { path in
            if path.usesInterfaceType(.wifi) {
                cnxnTp = "WIFI"
            } else if path.usesInterfaceType(.cellular) {
                cnxnTp = "MOBILE"
            } else if path.usesInterfaceType(.wiredEthernet) {
                cnxnTp = "LAN"
            } else if path.usesInterfaceType(.loopback) {
                cnxnTp = "LOOPBACK"
            } else if path.usesInterfaceType(.other) {
                cnxnTp = "OTHER"
            }
        }
        let queue = DispatchQueue(label: "Monitor")
        nwPathMonitor.start(queue: queue)
        
//        var carrier:String? = ""
//        if #available(iOS 12.0, *) {
//            if let providers = CTTelephonyNetworkInfo().serviceSubscriberCellularProviders {
//                providers.forEach { (key, value) in
////                    print(value)
//                    carrier = value.carrierName
//                }
//            }
//        } else {
//            let provider = CTTelephonyNetworkInfo().subscriberCellularProvider
//            carrier = provider?.carrierName
//        }
        
        var dataSpeed :String? = ""
        dataSpeed = self.getConnectionType()
        
        var headerParams: [AnyHashable : Any] =
        [
            "timezone" : TimeZone.current.identifier,
            "js":"true",
            "App_cat":"iOS",
            "userid" : "",
            "Dmp_id" : "",
            "language": system_Language,
            "connectionType": cnxnTp,
            "useragent" : webV.value(forKey: "userAgent") as? String,
            "dataSpeed" : dataSpeed ?? "",
            "Dpidsha1": UIDevice.current.identifierForVendor?.uuidString.sha1() ?? "",
            "Dpidmd5": self.MD5(UIDevice.current.identifierForVendor?.uuidString ?? ""),
            "model": UIDevice.current.name,
            "udid": UIDevice.current.identifierForVendor?.uuidString ?? "",
            "appId": Bundle.main.bundleIdentifier ?? "",
            "make": UIDevice.current.model,
            "brand": "Apple",
            "Longitude": self.longitude,
            "Latitude": self.latitude,
            "deviceType": device_type,
            "screenwidth": "\(UIScreen.main.bounds.size.width)",
            "screenheight": "\(UIScreen.main.bounds.size.height)",
            "displaywidth": "\(UIScreen.main.bounds.size.width)",
            "displayheight": "\(UIScreen.main.bounds.size.height)",
            "os": UIDevice.current.systemName,
            "osv":  UIDevice.current.systemVersion,
            "ip": getExternalIP()!,
            "carrier": "vodafone",
            "network": "vodafone",
            "viewerEmail": "rose@gmail.com",
            "viewerPhone": "9876543210",
            "viewerGender": "Female",
            "viewerName" : "rose",
            "device_email" : "rose@gmail.com"
            //"viewerage": "25",

        ] as [String : AnyObject]
        
        print(headerParams)
        
        var strT:String? = ""
        for (key, value) in headerParams {
            strT = key as? String
            if dictArrays.count == 0 {
                strT = "&"
            }
            else {
                strT = strT! + "=\(value)&"
            }
//            print(strT)
            dictArrays.append((strT)!)
         }
//        print(dictArrays)
//        print(headerParams)
        
        var customstr = ""
        for str in dictArrays {
            customstr = customstr + str
        }
        let urlString = "\(apiBaseUrl)\("zoneid=\(zoneId_ApiCall ?? "")&mediation=\(mediationAdId ?? 0)")"
        print("API Url: \(urlString)")
        
        let finalStr = "\(urlString)\(customstr)"
//        let finalStr = "\(urlString)\(customstr)&keywords="

        let encodes = (finalStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)?.replacingOccurrences(of: "+", with: "%2b")
        )!
//        print(encodes)

        let _ = "\(apiBaseUrl)\("zoneid=\(zoneId_ApiCall ?? "")")"
        
        var theRequest: NSMutableURLRequest? = nil
        if let anUrl = URL(string: encodes) {
            theRequest = NSMutableURLRequest(url: anUrl)
        }
        theRequest?.httpMethod = "GET"
        for key in headerParams.keys {
            guard let key = key as? String else {
                continue
            }
            let value = headerParams[key] as? String
            theRequest?.addValue(value ?? "", forHTTPHeaderField: key)
        }
        webSc.requestAPIResponse(url: encodes,theRequest: theRequest! as URLRequest, header: &headerParams, completion:  { (response) in
            self.delegate_API?.response_Dict(passValue:response)
        })
    }
   
    func getExternalIP() -> String? {
        var address: String?
          var ifaddr: UnsafeMutablePointer<ifaddrs>? = nil
          if getifaddrs(&ifaddr) == 0 {
              var ptr = ifaddr
              while ptr != nil {
                  defer { ptr = ptr?.pointee.ifa_next }

                  guard let interface = ptr?.pointee else { return "" }
                  let addrFamily = interface.ifa_addr.pointee.sa_family
                  if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {

                      // wifi = ["en0"]
                      // wired = ["en2", "en3", "en4"]
                      // cellular = ["pdp_ip0","pdp_ip1","pdp_ip2","pdp_ip3"]

                      let name: String = String(cString: (interface.ifa_name))
                      if  name == "en0" || name == "en2" || name == "en3" || name == "en4" || name == "pdp_ip0" || name == "pdp_ip1" || name == "pdp_ip2" || name == "pdp_ip3" {
                          var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                          getnameinfo(interface.ifa_addr, socklen_t((interface.ifa_addr.pointee.sa_len)), &hostname, socklen_t(hostname.count), nil, socklen_t(0), NI_NUMERICHOST)
                          address = String(cString: hostname)
                      }
                  }
              }
              freeifaddrs(ifaddr)
          }
          return address ?? ""
    }
    func identifierForAdvertising() -> String? {
        // Check whether advertising tracking is enabled
        guard ASIdentifierManager.shared().isAdvertisingTrackingEnabled else {
            return nil
        }
        // Get and return IDFA
        return ASIdentifierManager.shared().advertisingIdentifier.uuidString
    }
    
    func MD5(_ string: String) -> String? {
        let length = Int(CC_MD5_DIGEST_LENGTH)
        var digest = [UInt8](repeating: 0, count: length)
        if let d = string.data(using: String.Encoding.utf8) {
            _ = d.withUnsafeBytes { (body: UnsafePointer<UInt8>) in
                CC_MD5(body, CC_LONG(d.count), &digest)
            }
        }
        return (0..<length).reduce("") {
            $0 + String(format: "%02x", digest[$1])
        }
    }
    func getConnectionType() -> String {
           guard let reachability = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, "www.google.com") else {
               return "NO INTERNET"
           }
           var flags = SCNetworkReachabilityFlags()
           SCNetworkReachabilityGetFlags(reachability, &flags)
           let isReachable = flags.contains(.reachable)
           let isWWAN = flags.contains(.isWWAN)
           if isReachable {
               if isWWAN {
                   let networkInfo = CTTelephonyNetworkInfo()
                   let carrierType = networkInfo.serviceCurrentRadioAccessTechnology
                   guard let carrierTypeName = carrierType?.first?.value else {
                       return "UNKNOWN"
                   }
                   switch carrierTypeName {
                   case CTRadioAccessTechnologyGPRS, CTRadioAccessTechnologyEdge, CTRadioAccessTechnologyCDMA1x:
                       return "2G"
                   case CTRadioAccessTechnologyLTE:
                       return "4G"
                   default:
                       return "3G"
                   }
               } else {
                   return "WIFI"
               }
           } else {
               return "NO INTERNET"
           }
       }
}
