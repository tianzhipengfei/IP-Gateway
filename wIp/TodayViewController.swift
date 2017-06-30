//
//  TodayViewController.swift
//  wIp
//
//  Created by Eric on 2017/6/15.
//  Copyright © 2017年 Eric. All rights reserved.
//

import UIKit
import NotificationCenter
import Alamofire
import ReachabilitySwift
import KeychainSwift
import SystemConfiguration.CaptiveNetwork

let userDic:UserDefaults! = UserDefaults (suiteName: "group.ipgateway")


class TodayViewController: UIViewController, NCWidgetProviding {
    
//    @IBOutlet weak var wtxtInfo: UITextField!
//    @IBAction func cancel(_ sender: UIButton) {
//        
//    }
//    @IBAction func login(_ sender: UIButton) {
//    }
    
    
    @IBOutlet weak var wbotLogin: UIButton!
    @IBOutlet weak var wbotCancel: UIButton!
    @IBOutlet weak var wtxtInfo: UILabel!
    
    @IBAction func Cancel(_ sender: UIButton) {
        let reachability = Reachability()!
        if(!reachability.isReachableViaWiFi){
            self.wtxtInfo.text = "大哥，先连下WIFI呗"
        }
        else if(userDic.string(forKey: "last") != nil){
            self.wtxtInfo.text = "注销中..."
            let id = userDic.string(forKey: "last")
            let pwd = userDic.string(forKey: id!)
            let parameters: Parameters = ["ac_id":"1", "action":"logout", "username": id!, "password": pwd!, "ajax":"1"]
            Alamofire.request("https://ipgw.neu.edu.cn/srun_portal_pc.php?url=&ac_id=1", method: .post, parameters: parameters).responseJSON { response in
                if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                    if(utf8Text.range(of: "网络已断开") != nil){
                        self.wtxtInfo.text = "注销成功"
                    }
                    else if(utf8Text.range(of: "您似乎未曾连接到网络") != nil){
                        self.wtxtInfo.text = "未曾联网"
                    }
                    else if(utf8Text.range(of: "Password is error") != nil){
                        self.wtxtInfo.text = "账号或密码错误"
                    }
                    else{
                        self.wtxtInfo.text = "未知错误"
                    }
                }
            }
        }
        else{
            self.wtxtInfo.text = "请先到主应用登陆一次让我记住账号"
        }
        
    }
    
    @IBAction func Login(_ sender: UIButton) {
        let reachability = Reachability()!
        if(!reachability.isReachableViaWiFi){
            self.wtxtInfo.text = "大哥，先连下WIFI呗"
        }
        else if(userDic.string(forKey: "last") != nil){
            self.wtxtInfo.text = "登陆中..."
            let id = userDic.string(forKey: "last")
            let pwd = userDic.string(forKey: id!)
            let parameters: Parameters = ["ac_id":"1", "action":"login", "username": id!, "password": pwd!, "save_me":"0"]
            
            Alamofire.request("https://ipgw.neu.edu.cn/srun_portal_pc.php?ac_id=1&", method: .post, parameters: parameters).responseJSON { response in
                
                if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                    if(utf8Text.range(of: "网络已连接") != nil){
                        let k = arc4random() % UInt32(10000000) + UInt32(1)     //生成随机查询key值
                        let url2 = "https://ipgw.neu.edu.cn/include/auth_action.php?k="+String(k)
                        let parameters2: Parameters = ["action":"get_online_info", "key": k]
                        Alamofire.request(url2, method: .post, parameters: parameters2).responseJSON { response in
                            if let data = response.data, let aa = String(data: data, encoding: .utf8) {
                                if(aa != "not_online"){
                                    let bb = (aa.components(separatedBy: ","))
                                    var liuliang:Double = (Double)(bb[0])!
                                    liuliang = liuliang / 1073741824
                                    self.wtxtInfo.text = "登陆成功，已使用了" + String(format:"%.2lf",liuliang) + "G"
                                }
                            }
                        }
                        
                    }
                    else if(utf8Text.range(of: "You are already online") != nil){
                        self.wtxtInfo.text = "已经在线"
                    }
                    else if(utf8Text.range(of: "E2616") != nil){
                        self.wtxtInfo.text = "已欠费"
                    }
                    else{
                        self.wtxtInfo.text = "账户或密码错误"
                    }
                }
            }
        }
        else{
            self.wtxtInfo.text = "请先到主应用登陆一次让我记住账号"
        }
        
    }
    
    func getMAC()->(success:Bool,ssid:String,mac:String){
        
        if let cfa:NSArray = CNCopySupportedInterfaces() {
            for x in cfa {
                if let dict = CFBridgingRetain(CNCopyCurrentNetworkInfo(x as! CFString)) {
                    let ssid = dict["SSID"]!
                    let mac  = dict["BSSID"]!
                    return (true,ssid as! String,mac as! String)
                }
            }
        }
        return (false,"","")
    }
    
    func showWifi(){
        //test WIFI's name
        let x = self.getMAC()
        if (x.success) {
            self.wtxtInfo.text = ("当前连接的WI-FI为: " + x.ssid)
        }
    }
    
    override func viewDidLoad() {
        //showWifi()
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
}
