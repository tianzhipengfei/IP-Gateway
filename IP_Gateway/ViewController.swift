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
        let reachability = Reachability()!
        if(!reachability.isReachableViaWiFi){
            self.txtInfo.text = "大哥，先连下WIFI呗"
        }
        else if(txtUser.text==""){
            self.txtInfo.text = "亲爱的，麻烦输入用户名"
        }
        else if(txtPwd.text==""){
            self.txtInfo.text = "亲爱的，麻烦输入密码"
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
                    print(utf8Text)
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
        let reachability = Reachability()!
        if(!reachability.isReachableViaWiFi){
            self.txtInfo.text = "大哥，先连下WIFI呗"
        }
        else if(txtUser.text==""){
            self.txtInfo.text = "亲爱的，麻烦输入用户名"
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
}


