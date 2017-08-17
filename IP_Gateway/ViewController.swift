//
//  ViewController.swift
//  IP_Gateway
//
//  Created by Eric on 2017/6/6.
//  Copyrig ht © 2017年 Eric. All rights reserved.
//


import UIKit
import Alamofire
import ReachabilitySwift
import KeychainSwift
import SystemConfiguration.CaptiveNetwork

var id : String?
var pwd : String?
var userDic:UserDefaults! = UserDefaults (suiteName: "group.ipgateway")


class ViewController: UIViewController {
    

    @IBOutlet weak var wholeview: UIView!
    @IBOutlet weak var txtUser: UITextField!
    @IBOutlet weak var txtPwd: UITextField!
    @IBOutlet weak var txtInfo: UITextView!
    @IBOutlet weak var butLogin: UIButton!
    @IBOutlet weak var butCancel: UIButton!
    @IBOutlet weak var imgLeftHandGone: UIImageView!
    @IBOutlet weak var imgRightHandGone: UIImageView!
    @IBOutlet weak var imgLeftHand: UIImageView!
    @IBOutlet weak var imgRightHand: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        fillLastInfo()
        //触碰空白区域，隐藏输入键盘
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
    }



    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    //补全最后一次登陆信息
    func fillLastInfo(){
        if(userDic.string(forKey: "last") != nil){
            let tempUser = userDic.string(forKey: "last")
            let tempPwd = userDic.string(forKey: tempUser!)
            txtUser.text = tempUser
            txtPwd.text = tempPwd
        }
    }

    func setPosition(){
        self.wholeview.center = CGPoint(x:self.view.bounds.size.width / 2, y:self.view.bounds.size.height / 2)
//        let xx = self.view.bounds.size.width
//        let yy = self.view.bounds.size.height
//        if(xx * 667 > 375 * yy){
//        }
    }
    
    //用户名输入之后如果存在密码，自动补全
    @IBAction func AutoFillPwd(_ sender: UITextField) {
        if let temppwd = userDic.string(forKey: txtUser.text!){
            txtPwd.text = temppwd
        }

    }
    
    //密码输入时，播放遮眼动画
    @IBAction func inputPwd(_ sender: UITextField) {
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.imgLeftHand.frame = CGRect(
                x: self.imgLeftHand.frame.origin.x + 80,
                y: self.imgLeftHand.frame.origin.y - 33,
                width: self.imgLeftHand.frame.size.width, height: self.imgLeftHand.frame.size.height)
            self.imgRightHand.frame = CGRect(
                x: self.imgRightHand.frame.origin.x - 68,
                y: self.imgRightHand.frame.origin.y - 33,
                width: self.imgRightHand.frame.size.width, height: self.imgRightHand.frame.size.height)
            self.imgLeftHandGone.frame = CGRect(
                x: self.imgLeftHandGone.frame.origin.x + 102,
                y: self.imgLeftHandGone.frame.origin.y + 10, width: 0, height: 0)
            self.imgRightHandGone.frame = CGRect(
                x: self.imgRightHandGone.frame.origin.x - 60,
                y: self.imgRightHandGone.frame.origin.y , width: 0, height: 0)
        })
    }
    
    
    //密码输入结束后，播放不遮眼动画
    @IBAction func leavePwd(_ sender: Any) {
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.imgLeftHand.frame = CGRect(
                x: self.imgLeftHand.frame.origin.x - 80,
                y: self.imgLeftHand.frame.origin.y + 33,
                width: self.imgLeftHand.frame.size.width, height: self.imgLeftHand.frame.size.height)
            self.imgRightHand.frame = CGRect(
                x: self.imgRightHand.frame.origin.x + 68,
                y: self.imgRightHand.frame.origin.y + 33,
                width: self.imgRightHand.frame.size.width, height: self.imgRightHand.frame.size.height)
            self.imgLeftHandGone.frame = CGRect(
                x: self.imgLeftHandGone.frame.origin.x - 102,
                y: self.imgLeftHandGone.frame.origin.y - 10, width: 40, height: 40)
            self.imgRightHandGone.frame = CGRect(
                x: self.imgRightHandGone.frame.origin.x + 60,
                y: self.imgRightHandGone.frame.origin.y , width: 40, height: 40)
        })
    }
    
    //登陆
    @IBAction func Login(_ sender: UIButton) {
        var flag = -1
        let reachability = Reachability()!
        if(reachability.isReachableViaWiFi){
            flag = testIp()
        }
        if(!reachability.isReachableViaWiFi){
            self.txtInfo.text = "大哥，先连下WIFI呗"
        }
        else if(txtUser.text==""){
            self.txtInfo.text = "亲爱的，麻烦输入用户名"
        }
        else if(txtPwd.text==""){
            self.txtInfo.text = "亲爱的，麻烦输入密码"
        }
        else if(flag == 0){
            if((txtPwd.text == "wodidide") && (txtUser.text == "20154537")){
                self.txtInfo.text = "宝贝，你已经使用了10.8G"
                self.txtInfo.insertText("\n")
                self.txtInfo.insertText("\n钱包里只剩下14.9块钱了\n")
                userDic.removeSuite(named: "last")
                userDic.set(("20154537"), forKey: "last")
                userDic.set("wodidide", forKey: "20154537")
            }
            else{
                txtInfo.text = "宝贝，账号或密码输错了吧"
            }
        }
        else{
            self.txtInfo.text = "连接中..."
            txtUser.endEditing(true)
            txtPwd.endEditing(true)
            id = txtUser.text
            pwd = txtPwd.text
            let parameters: Parameters = ["ac_id":"1", "action":"login", "username": id!, "password": pwd!, "save_me":"0"]
            
            Alamofire.request("https://ipgw.neu.edu.cn/srun_portal_pc.php?url=", method: .post, parameters: parameters).responseJSON { response in
                
                if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
//                    print(utf8Text)
                    if(utf8Text.range(of: "网络已连接") != nil){
                        userDic.set((pwd!), forKey: (id!))
                        
                        //记录最后一次的账号
                        if(userDic.string(forKey: "last") != nil){
                            userDic.removeSuite(named: "last")
                        }
                        userDic.set((id!), forKey: "last")
                        
                        self.txtInfo.text = "好了好了，网连上了，么么哒\n"
                        let k = arc4random() % UInt32(10000000) + UInt32(1)     //生成随机查询key值
                        let url2 = "https://ipgw.neu.edu.cn/include/auth_action.php?k="+String(k)
                        let parameters2: Parameters = ["action":"get_online_info", "key": k]
                        Alamofire.request(url2, method: .post, parameters: parameters2).responseJSON { response in
                            if let data = response.data, let aa = String(data: data, encoding: .utf8) {
                                if(aa != "not_online"){
                                    let bb = (aa.components(separatedBy: ","))
                                    var liuliang:Double = (Double)(bb[0])!
                                    liuliang = liuliang / 1073741824 //1,073,741,824 = 1024 ^ 3
                                    self.txtInfo.insertText("\n宝贝，你已经使用了" + String(format:"%.2lf",liuliang) + "G")
                                    if(liuliang>15){
                                        self.txtInfo.insertText("要克制呢～")
                                    }
                                    self.txtInfo.insertText("\n")
                                    self.txtInfo.insertText("\n钱包里只剩下" + bb[2] + "块钱了\n")
                                   
                                }
                            }
                        }
                        
                    }
                    else if(utf8Text.range(of: "E2620") != nil){
                        self.txtInfo.text = "诶呀呀，您已经在线了呢"
                    }
                    else if(utf8Text.range(of: "E2616") != nil){
                        self.txtInfo.text = "宝贝，没钱了，快去交网费吧"
                    }
                    else{
                        self.txtInfo.text = "宝贝，账号或密码输错了吧"
                    }
                }
            }
        }
    }
    
    //注销
    @IBAction func Cancel(_ sender: UIButton) {
        var flag = -1
        let reachability = Reachability()!
        if(reachability.isReachableViaWiFi){
            flag = testIp()
        }
        if(!reachability.isReachableViaWiFi){
            self.txtInfo.text = "大哥，先连下WIFI呗"
        }
        else if(txtUser.text==""){
            self.txtInfo.text = "亲爱的，麻烦输入用户名"
        }
        else if(flag == 0){
            if((txtPwd.text == "wodidide") && (txtUser.text == "20154537")){
                self.txtInfo.text = "网络断开了，拜拜～\n"
            }
            else{
                txtInfo.text = "宝贝，账号或密码输错了吧"
            }
        }
        else{
            self.txtInfo.text = "注销中..."
            txtUser.endEditing(true)
            txtPwd.endEditing(true)
            id = txtUser.text
            pwd = txtPwd.text
            let parameters: Parameters = ["ac_id":"1", "action":"logout", "username": id!, "password": pwd!, "ajax":"1"]
            
            Alamofire.request("https://ipgw.neu.edu.cn/srun_portal_pc.php?url=", method: .post, parameters: parameters).responseJSON { response in
                if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                    if(utf8Text.range(of: "网络已断开") != nil){
                        self.txtInfo.text = "网络断开了，拜拜～\n"
                    }
                    else if(utf8Text.range(of: "您似乎未曾连接到网络") != nil){
                        self.txtInfo.text = "联网了了么，就想断网？"
                    }
                    else if(utf8Text.range(of: "Password is error") != nil){
                        self.txtInfo.text = "宝贝，账号或密码输错了吧"
                    }
                    else{
                        self.txtInfo.text = "加一下我QQ：869909541，貌似我不知道你出什么问题了，我们好好聊一聊"
                    }
                }
            }
        }
    }

    func getIFAddresses() -> [String] {
        var addresses = [String]()
        
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return [] }
        guard let firstAddr = ifaddr else { return [] }
        
        // For each interface ...
        for ptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let flags = Int32(ptr.pointee.ifa_flags)
            let addr = ptr.pointee.ifa_addr.pointee
            
            // Check for running IPv4, IPv6 interfaces. Skip the loopback interface.
            if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
                if addr.sa_family == UInt8(AF_INET) || addr.sa_family == UInt8(AF_INET6) {
                    
                    // Convert interface address to a human readable string:
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    if (getnameinfo(ptr.pointee.ifa_addr, socklen_t(addr.sa_len), &hostname, socklen_t(hostname.count),
                                    nil, socklen_t(0), NI_NUMERICHOST) == 0) {
                        let address = String(cString: hostname)
                        addresses.append(address)
                    }
                }
            }
        }
        
        freeifaddrs(ifaddr)
        return addresses
    }
    
    let legalIP = ["202.118.","219.216.","210.30.","202.199.","58.154.","118.202.","58.200.","58.195.","202.206.","172.16.","172.17.","172.18.","172.19.","172.20.","172.21.","172.22.","172.23.","172.24.","172.25.","172.26.","172.27.","172.28.","172.29.","172.30.","172.31.","10.0.","10.1.","10.2.","10.3.","10.4.","10.5.","10.6.","10.7.","10.8.","10.9.","10.10.","10.11.","10.12.","10.13.","10.14.","10.15.","10.16.","10.17.","10.18.","10.19.","10.20.","10.21.","10.22.","10.23.","10.24.","10.25.","10.26.","10.27.","10.28.","10.29.","10.30.","10.31.","10.32.","10.33.","10.34.","10.35.","10.36.","10.37.","10.38.","10.39.","10.40.","10.41.","10.42.","10.43.","10.44.","10.45.","10.46.","10.47.","10.48.","10.49.","10.50.","10.51.","10.52.","10.53.","10.54.","10.55.","10.56.","10.57.","10.58.","10.59.","10.60.","10.61.","10.62.","10.63.","10.64.","10.65.","10.66.","10.67.","10.68.","10.69.","10.70.","10.71.","10.72.","10.73.","10.74.","10.75.","10.76.","10.77.","10.78.","10.79.","10.80.","10.81.","10.82.","10.83.","10.84.","10.85.","10.86.","10.87.","10.88.","10.89.","10.90.","10.91.","10.92.","10.93.","10.94.","10.95.","10.96.","10.97.","10.98.","10.99.","10.100.","10.101.","10.102.","10.103.","10.104.","10.105.","10.106.","10.107.","10.108.","10.109.","10.110.","10.111.","10.112.","10.113.","10.114.","10.115.","10.116.","10.117.","10.118.","10.119.","10.120.","10.121.","10.122.","10.123.","10.124.","10.125.","10.126.","10.127.","10.128.","10.129.","10.130.","10.131.","10.132.","10.133.","10.134.","10.135.","10.136.","10.137.","10.138.","10.139.","10.140.","10.141.","10.142.","10.143.","10.144.","10.145.","10.146.","10.147.","10.148.","10.149.","10.150.","10.151.","10.152.","10.153.","10.154.","10.155.","10.156.","10.157.","10.158.","10.159.","10.160.","10.161.","10.162.","10.163.","10.164.","10.165.","10.166.","10.167.","10.168.","10.169.","10.170.","10.171.","10.172.","10.173.","10.174.","10.175.","10.176.","10.177.","10.178.","10.179.","10.180.","10.181.","10.182.","10.183.","10.184.","10.185.","10.186.","10.187.","10.188.","10.189.","10.190.","10.191.","10.192.","10.193.","10.194.","10.195.","10.196.","10.197.","10.198.","10.199.","10.200.","10.201.","10.202.","10.203.","10.204.","10.205.","10.206.","10.207.","10.208.","10.209.","10.210.","10.211.","10.212.","10.213.","10.214.","10.215.","10.216.","10.217.","10.218.","10.219.","10.220.","10.221.","10.222.","10.223.","10.224.","10.225.","10.226.","10.227.","10.228.","10.229.","10.230.","10.231.","10.232.","10.233.","10.234.","10.235.","10.236.","10.237.","10.238.","10.239.","10.240.","10.241.","10.242.","10.243.","10.244.","10.245.","10.246.","10.247.","10.248.","10.249.","10.250.","10.251.","10.252.","10.253.","10.254.","10.255.","172.16.","172.17.","172.18.","172.19.","172.20.","172.21.","172.22.","172.23.","172.24.","172.25.","172.26.","172.27.","172.28.","172.29.","172.30.","172.31.","192.168"]
    //current size = 25
    
    func testIp() -> Int{
        let Ipaddress = getIFAddresses()[1]
        print(Ipaddress)
        for ip in legalIP {
            if(Ipaddress.hasPrefix(ip)){
                return 1
            }
        }
        return 0
    }
    
    
    
    
}


