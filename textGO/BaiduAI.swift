//
//  BaiduAI.swift
//  textGO
//
//  Created by 5km on 2019/1/20.
//  Copyright © 2019 5km. All rights reserved.
//

import Cocoa


class BaiduAI {
    
    enum ErrorType: Int {
        case accessTokenInvalid = 110
        case connectInvalid = 111
    }
    
    private var tryCount: Int = 0
    var delegate: BaiduAIDelegate!
    private var _baiduParams: [String: String]? = [String: String]()
    var baiduParams: [String: String]? {
        get {
            if UserDefaults.standard.dictionary(forKey: "baiduAIParams") == nil {
                _baiduParams!["apiKey"] = ""
                _baiduParams!["secretKey"] = ""
                _baiduParams!["accessToken"] = ""
                UserDefaults.standard.set(_baiduParams, forKey: "baiduAIParams")
            }
            return  (UserDefaults.standard.dictionary(forKey: "baiduAIParams") as? [String : String])
        }
        set {
            _baiduParams = newValue
            UserDefaults.standard.set(newValue, forKey: "baiduAIParams")
        }
    }
    
    var apiKey: String? {
        get {
            return baiduParams!["apiKey"]
        }
        
        set {
            baiduParams!["apiKey"] = newValue
        }
    }
    
    var secretKey: String? {
        get {
            return baiduParams!["secretKey"]
        }
        
        set {
            baiduParams!["secretKey"] = newValue
        }
    }
    
    var accessToken: String? {
        get {
            return baiduParams!["accessToken"]
        }
        
        set {
            baiduParams!["accessToken"] = newValue
        }
    }
    
    func reset() {
        apiKey = ""
        secretKey = ""
        accessToken = ""
    }
    
    func ocr(_ imgData: NSData) {
        
        if accessToken == nil {
            return
        }
        
        let session = URLSession(configuration: .default)
        let url = URL(string: "https://aip.baidubce.com/rest/2.0/ocr/v1/accurate?access_token=\(accessToken ?? "")")
        var request = URLRequest(url: url!)
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let postData = ["image_type": "BASE64", "image": base64From(imgData)!, "group_id": "textGO", "user_id": "5km"]
        let postString = postData.compactMap({ (key, value) -> String in
            return "\(key)=\(value)"
        }).joined(separator: "&")
        request.httpBody = postString.data(using: .utf8)
        let task = session.dataTask(with: request) {(data, response, error) in
            do {
                let r = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                if let error_code = r.value(forKey: "error_code") as? ErrorType {
                    if self.delegate != nil {
                        self.delegate.ocrError(type: error_code, msg: r.value(forKey: "error_msg") as! String)
                    }
                    if error_code == ErrorType.accessTokenInvalid {
                        if self.tryCount < 3 {
                            self.tryCount += 1
                            self.getAccessToken()
                            self.ocr(imgData)
                        }
                    }
                } else {
                    let wordsResult = r.value(forKey: "words_result") as! NSArray
                    var wordsArray = [String]()
                    for lineResult in wordsResult {
                        let words = (lineResult as! NSDictionary).value(forKey: "words") as! String
                        wordsArray.append(words)
                    }
                    let wordsStr = wordsArray.joined(separator: "\n")
                    print(wordsStr)
                    if self.delegate != nil {
                        self.delegate.ocrResult(text: wordsStr)
                    }
                }
            } catch {
                if self.delegate != nil {
                    self.delegate.ocrError(type: ErrorType.connectInvalid, msg: "can not connect to server")
                }
                return
            }
        }
        task.resume()
    }
    
    private func base64From(_ imgData: NSData) -> String? {
        let b64Str = imgData.base64EncodedString()
        return b64Str.urlEncoded
    }
    
    private func getAccessToken() {
        if apiKey == "" || secretKey == "" {
            accessToken = nil
            return
        }
        let session = URLSession(configuration: .default)
        let url = URL(string: "https://aip.baidubce.com/oauth/2.0/token?grant_type=client_credentials&client_id=\(apiKey ?? "")&client_secret=\(secretKey ?? "")")
        let task = session.dataTask(with: url!) {
            (data, response, error) in
            guard error == nil else {
                print("error calling GET on /todos/1")
                print(error!)
                return
            }
            // make sure we got data
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            // parse the result as JSON, since that's what the API provides
            do {
                guard let jsonDict = try JSONSerialization.jsonObject(with: responseData, options: [])
                    as? [String: Any] else {
                        print("error trying to convert data to JSON")
                        return
                }
                // now we have the todo
                self.accessToken = jsonDict["access_token"] as? String
            } catch  {
                print("error trying to convert data to JSON")
                return
            }
        }
        task.resume()
    }
    
}

protocol BaiduAIDelegate {
    func ocrResult(text: String)
    func ocrError(type: BaiduAI.ErrorType, msg: String)
}

extension String {
    //将原始的url编码为合法的url
    var urlEncoded: String? {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        var allowedCharacterSet = CharacterSet.urlQueryAllowed
        allowedCharacterSet.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return addingPercentEncoding(withAllowedCharacters: allowedCharacterSet)
    }
    
    //将编码后的url转换回原始的url
    var urlDecoded: String? {
        return removingPercentEncoding
    }
}
