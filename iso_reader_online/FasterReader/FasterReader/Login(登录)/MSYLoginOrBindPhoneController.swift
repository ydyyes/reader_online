//
//  JLXXLoginViewController.swift
//  JinglanEx
//
//  Created by apple on 2018/9/17.
//  Copyright © 2018年 JLXX. All rights reserved.
//

import UIKit
import Schedule
import SVProgressHUD

class MSYLoginOrBindPhoneController: JLXXViewController {
    
    enum ControllerType {
        case login
        case bindPhone
    }
    
    @IBOutlet weak var appIconToTop: NSLayoutConstraint!
    
    @IBOutlet weak var phoneTextFiled: UITextField!
    @IBOutlet weak var varCodeTextFiled: UITextField!
    @IBOutlet weak var varCodeButton: UIButton!
    @IBOutlet weak var varCodeLabel: UILabel!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var bindPhoneButton: UIButton!
    @IBOutlet weak var userProtocolLabel: UILabel!
    
    var type: ControllerType = .login
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appIconToTop.constant += JL_STATUS_NAV_BAR_H(self)
        
        if type == .bindPhone {
            bindPhoneButton.isHidden = false
            userProtocolLabel.text = "绑定即代表同意"
            navigationItem.title = "绑定手机"
        }else{
            navigationItem.title = "登录"
        }
        
    }
    
    @IBAction func userProtocolButtonClick() {
        let web = JLXXWKWebViewController()
        web.urlString = "http://drapi.17k.ren/pact.html"
        navigationController?.pushViewController(web, animated: true)
    }
    
    
    @IBAction func loginButtonClick() {
        loginOrBindPhone()
    }
    
    @IBAction func bindPhoneButtonClick(_ sender: UIButton) {
    
        loginOrBindPhone()
    }
    
	@IBAction func getVarCodeClick() {
        
        guard let phone = phoneTextFiled.text, !phone.isEmpty else {
            ZJPAlert.show(withMessage: "请输入手机号", time: 0.8)
            return
        }
        
//        if (![self valiMobile:self.phoneNumberTextField.text]) {
//            return;
//        }
        guard ZJPNetWork.netWorkAvailable() else {
            ZJPAlert.show(withMessage: JPTool.noNetWorkAlert(), time: 1.0)
            return
        }
        
        //禁止再次点击
        isVarCodeButtonEnabled(false)
        // 获取验证码
        let paramsDict = NSMutableDictionary(dictionary: ["areacode":"+86", "mobile":phone])
        JPNetWork.sharedManager()?.requestPostMethod(withPathUrl: JPTool.myMineSendCodePath(), withParamsDict: paramsDict, withSuccessBlock: { [weak self] (response) in
            
            self?.isVarCodeButtonEnabled(true)
            
            guard let self = self, let responseObject = response as? Dictionary<String, Any> else {
                
                debugPrint("网络请求返回的,不是需要的数据,或self对象被释放")
                return
            }

            if let errorno = responseObject["errorno"] as? Int64, errorno == 200 {
                self.countDown()
            }
           
            }, withFailurBlock: { [weak self] (error) in
                ZJPAlert.show(withMessage: "获取验证码失败", time: 1.0)
                self?.isVarCodeButtonEnabled(true)
        })
        
    }
	
    private func countDown() {
        isHiddenVarCodeButton(true)
        Plan.every(1.second).do(queue: DispatchQueue.main, host: self) { [weak self] task in
            
            self?.varCodeLabel.text = String(60 - task.countOfExecutions)
            if task.isCancelled {
                self?.isHiddenVarCodeButton(false)
            }
            debugPrint(task.restOfLifetime)
            }.setLifetime(1.minute)
    }
    
    private func isHiddenVarCodeButton(_ isHidden: Bool) {
        self.varCodeButton.isHidden = isHidden
        self.varCodeLabel.isHidden = !isHidden
        self.varCodeLabel.text = "60"
    }
    
    private func isVarCodeButtonEnabled(_ isEnabled: Bool) {
        self.varCodeButton.isUserInteractionEnabled = isEnabled
    }
}

extension MSYLoginOrBindPhoneController {
	
	private func loginOrBindPhone() {
        guard let phone = phoneTextFiled.text, !phone.isEmpty else {
            ZJPAlert.show(withMessage: "请输入手机号", time: 0.8)
            return
        }
		guard let varCode = varCodeTextFiled.text, !varCode.isEmpty else {
            ZJPAlert.show(withMessage: "请输入验证码", time: 0.8)
			return
		}
        guard ZJPNetWork.netWorkAvailable() else {
            ZJPAlert.show(withMessage: JPTool.noNetWorkAlert(), time: 1.0)
            return
        }
		
        if type == .login {
            loginIn(phone: phone, varCode: varCode)
        }else {
            bind(phone: phone, varCode: varCode)
        }
	}
    
    private func loginIn(phone: String, varCode: String) {
        SVProgressHUD.show(withStatus: "登录中...")
        JLXXAccount.loginIn(phone: phone, varCode: varCode, success: { [weak self] in
            guard let self = self else { print("self对象被释放"); return; }
            
            SVProgressHUD.dismiss()
            self.navigationController?.popViewController(animated: true)
            
            }, failed: { (errMsg) in
                SVProgressHUD.dismiss()
                if let msg = errMsg {
                    ZJPAlert.show(withMessage: msg, time: 1.0)
                }
        })
    }

    
    private func bind(phone: String, varCode: String) {
        SVProgressHUD.show(withStatus: "绑定中...")
        JLXXAccount.bindPhone(phone, varCode: varCode, success: { [weak self] in
            guard let self = self else { print("self对象被释放"); return; }
            
            SVProgressHUD.dismiss()
            self.navigationController?.popViewController(animated: true)
            
            }, failed: { (errMsg) in
                SVProgressHUD.dismiss()
                if let msg = errMsg {
                    ZJPAlert.show(withMessage: msg, time: 1.0)
                }
        })
    }
    

}

