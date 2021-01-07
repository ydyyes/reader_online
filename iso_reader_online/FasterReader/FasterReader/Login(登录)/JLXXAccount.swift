//
//  JLXXUserProfileModel.swift
//  JinglanIM
//
//  Created by apple on 2019/3/25.
//  Copyright © 2019年 JLXX. All rights reserved.
//

import Foundation
import HandyJSON

class JLXXAccount: HandyJSON {
    
    /*
     
     loginIn返回的数据
     [
     "token": 51075abd96abea5066ebf773e92fb53cbc15d1af0776e644,
     "expire": 0,
     "sex": -1,
     "nickname": ,
     "u_type": 普通用户,
     "cover":
     "uni_id": 3ee7b9e7d5b6f2608be88de9a25dfbc4i2Y,
     "invitation_code": QTYB20,
     "gold": 100,
     "reader_time": 0,
     ]
     
     getUserInfo(已登录)返回的数据字段
     [
     "mobile": 17610700398,
     "expire": 0,
     "sex": -1,
     "nickname": ,
     "invitation": 0,
     "username": ,
     "u_type": 普通用户,
     "utid": 2,
     "cover": ,
     "uni_id": 3ee7b9e7d5b6f2608be88de9a25dfbc4i2Y,
     "invitation_code": QTYB20,
     "devid": 1628DDDD-B94C-48CF-AC61-F5AD0339E711,
     "gold": 100,
     "id": 203963,
     "reader_time": 0
     ]
     
     loginIn中有,而getUserInfo中没有的字段: token
     
     getUserInfo(未登录)返回的数据字段
     [
     "create_time": 1561976709,
     "mobile": ,
     "expire": 1562063109,
     "sex": -1,
     "nickname": ,
     "invitation": 0,
     "username": ,
     "u_type": 游客,
     "utid": 1,
     "cover": ,
     "uni_id": 95c755f9d8651dbccd707c44f79b0397PnM,
     "invitation_code": OSGHV1,
     "devid": 7E71CAF4-D3F2-4C27-BB5D-9711FB9D0DF4,
     "gold": 0,
     "id": 205743,
     "reader_time": 0
     ]
     
     getUserInfo(未登录)中有,而getUserInfo(已登录)中没有的字段: create_time

     */
    
    required init() {}
    
    func mapping(mapper: HelpingMapper) {
        mapper <<<
            self.gender <-- "sex"
    }
    
    enum Gender: Int, HandyJSONEnum {
        case unknow = -1
        case male = 1
        case female = 2
    }
    
    static var shared: JLXXAccount =  JLXXAccount()
    
    /// 用户创建时间?
    var create_time: TimeInterval = 0
    /// 用户id
    var uni_id = ""
    var id = ""
    /// 昵称
    var nickname = ""
    /// 头像?
    var cover = ""
    /// 设备id ?
    var devid = ""
    /// 过期时间?
    var expire: Int64 = 0
    /// 手机
    var mobile = ""
    /// token
    var token = ""
    /// 金币
    var gold: Int64 = 0
    /// 邀请码
    var invitation_code = ""
    /// 书籍阅读的时间
    var reader_time: Int64 = 0
    /// 用户类型(默认游客)
    var u_type = "游客"
    
    var gender: Gender = .unknow

    /// 是否已经登录
    var isLogin: Bool {
        return !JPTool.user_TOKEN().isEmpty
    }
    /// 是否已经绑定手机
    var isBindPhone: Bool {
        return !mobile.isEmpty
    }
    
    class func loginIn(phone: String, varCode: String, success: @escaping () -> (), failed: @escaping (String?) -> () ) {
        
        let paramsDict = NSMutableDictionary(dictionary: ["areacode":"+86", "mobile":phone, "code": varCode])
        JPNetWork.sharedManager()?.requestPostMethod(withPathUrl: JPTool.loginRegisterPath(), withParamsDict: paramsDict, withSuccessBlock: { (response) in
            
            guard let responseObject = response as? Dictionary<String, Any> else {
                failed("网络请求返回的,不是需要的数据")
                return
            }
            //有数据
            if let data = responseObject["data"] as? Dictionary<String, Any>, let model = JLXXAccount.deserialize(from: data) {
                JLXXAccount.shared = model
                self.setInfoToUserDefault()
                success()
            }else {
                failed(nil)
            }
            
            }, withFailurBlock: { (error) in
                failed("error")
        })
        
    }
    
    static func getUserInfo(success: @escaping () -> (), failed: @escaping (String) -> () ) {
        /*
         
         if ([responseObject[@"errorno"] integerValue] == 300108) {
         
         if ([JPTool USER_ID]) {
         [[SureCanceAlert shareAlert] setTitleText:@"登录已经过期" withSureBtnTitle:@"去登录" withMaxHeight:100 withAlertStyle:(AlertButtonTypeStyleDefault) withSureBtnClick:^(UIButton *sender) {
         
         //                    LoginViewController *vc = [[LoginViewController alloc]init];
         //                    vc.hidesBottomBarWhenPushed = YES;
         //                    vc.isFrom = @"登录";
         //                    [self.navigationController pushViewController:vc animated:YES];
         
         } withCancelBtnClick:^(UIButton *sender) {
         [ClearPersonalInformation clearInformation];//退出登录清除信息
         [self basicSetting];
         [self.tableView reloadData];
         }];
         }
         }
         
         */
        let token = JPTool.user_TOKEN()
        let paramsDict = NSMutableDictionary(dictionary: ["token" : token])
        JPNetWork.sharedManager()?.requestPostMethod(withPathUrl: JPTool.userInPath(), withParamsDict: paramsDict, withSuccessBlock: { (response) in
            
            guard let responseObject = response as? Dictionary<String, Any>, let errorno = responseObject["errorno"] as? UInt64, let msg = responseObject["msg"] as? String else {
                failed("服务器返回的数据不是有效的数据")
                return
            }
            
            if errorno == 200, let data = responseObject["data"] as? Dictionary<String, Any>,
                let model = JLXXAccount.deserialize(from: data) {
                //赋值
                JLXXAccount.shared = model
                if !token.isEmpty
                {
                    JLXXAccount.shared.token = token
                }
                //存储用户信息
                setInfoToUserDefault()
                //回调
                success()
            }else if errorno == 300108 {
                //Token失效或者不存在
                resetUserInfo()
                failed("登录状态已过期,请重新登录!")
            }else {
                failed(msg)
            }
            
            }, withFailurBlock: { (err) in
                failed("error")
        })
    }
    
    
    class func bindPhone(_ phone: String, varCode: String, success: @escaping () -> (), failed: @escaping (String?) -> () ) {
        
        let token = JPTool.user_TOKEN()
        let paramsDict = NSMutableDictionary(dictionary: ["token" : token,"type":"","areacode":"+86", "mobile":phone, "code": varCode])
        JPNetWork.sharedManager()?.requestPostMethod(withPathUrl: JPTool.myMineBindphonePath(), withParamsDict: paramsDict, withSuccessBlock: { (response) in
            
            guard let responseObject = response as? Dictionary<String, Any> else {
                failed("网络请求返回的,不是需要的数据")
                return
            }
            //有数据
            if let _ = responseObject["data"] as? Dictionary<String, Any> {
                success()
            }else {
                failed(nil)
            }
            
        }, withFailurBlock: { (error) in
            failed("error")
        })
        
    }
    
    static func setInfoToUserDefault() {
        let user = JLXXAccount.shared
        let userDedault = UserDefaults.standard
        /// K_TOKEN
        userDedault.setValue(user.token, forKey: "APP_token")
        /// 用户身份
        userDedault.setValue(user.u_type, forKey: "u_type")
        /// 用户昵称
        userDedault.setValue(user.nickname, forKey: "username")
        /// 用户邀请码
        userDedault.setValue(user.invitation_code, forKey: "invitation_code")
        /// 用户头像
        userDedault.setValue(user.cover, forKey: "USER_AVATAR")
        /// 用户性别
        userDedault.setValue(user.gender.rawValue, forKey: "gender")
        /// expire
        userDedault.setValue(user.expire, forKey: "expire")
        /// 用户id就是存手机号
        userDedault.setValue(user.uni_id, forKey: "userid")
        /// 用户金币
        userDedault.setValue(user.gold, forKey: "gold")
        userDedault.synchronize()
        
//        if (![dataDict[@"mobile"] isEqualToString:@""]) {
//            [def setValue:@"1" forKey:@"bindPhone"];//设备和手机绑定过了
//        }else{
//            [def setValue:@"" forKey:@"bindPhone"];//设备和手机绑定
//        }
    }
    /// 退出登录,或者一切与退出登录有关的逻辑
    static func resetUserInfo(_ isNeedResetAccount: Bool = true) {
        
        if isNeedResetAccount {
            JLXXAccount.shared = JLXXAccount()
        }
        
        let userDedault = UserDefaults.standard
        
        userDedault.removeObject(forKey: "APP_token")// 用户token
        userDedault.removeObject(forKey: "u_type")// 用户类型 普通、会员
        userDedault.removeObject(forKey: "username")// 存本地的昵称
        userDedault.removeObject(forKey: "invitation_code")// 用户邀请码
        userDedault.removeObject(forKey: "USER_AVATAR") //存本地的头像url
        userDedault.removeObject(forKey: "gender")
        userDedault.removeObject(forKey: "userid")// 用户ID 手机号
        userDedault.synchronize()
    }
    
    static func getInfoFromUserDefault() {
        // 用户token
        let token = JPTool.user_TOKEN()
        // 用户类型 普通、会员
        let u_type = JPTool.user_TYPE().isEmpty ? "游客" : JPTool.user_TYPE()
        // 用户昵称
        let nickname = JPTool.user_NAME()
        // 用户头像
        let avatar = JPTool.user_AVATAR()
        // 用户邀请码
        let invitation_code = JPTool.userInvitationCode()
        // 用户性别
        let gender = JPTool.user_SEX()

        let user = JLXXAccount.shared
        user.token = token
        user.u_type = u_type
        user.nickname = nickname
        user.cover = avatar
        user.invitation_code = invitation_code
        if let g = JLXXAccount.Gender(rawValue: gender.intValue) {
            user.gender = g
        }

    }
    
}
