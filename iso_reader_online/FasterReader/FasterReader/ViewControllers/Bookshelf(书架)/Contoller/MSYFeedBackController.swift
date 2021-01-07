//
//  MSYFeedBackController.swift
//  NightReader
//
//  Created by apple on 2019/7/1.
//  Copyright © 2019 MSYMobile. All rights reserved.
//

import UIKit

class MSYFeedBackController: UIViewController {

    @IBOutlet weak var pleaceHolderLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var emailTextFiled: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        submitButton.layer.cornerRadius = 8
        textView.delegate = self
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 6, bottom: 0, right: 0)

        setUpNav()
    }
    
    @IBAction func clickSubmit(_ sender: UIButton) {
        
        guard let contentText = textView.text, contentText.count > 11 else {
            ZJPAlert.show(withMessage: "反馈内容过短", time: 1.5)
            return
        }
//        guard let emailText = emailTextFiled.text, emailText.count > 0, emailText.contains("@") else {
//            ZJPAlert.show(withMessage: "邮箱不能为空", time: 1.5)
//            return
//        }
        
        let emailText = emailTextFiled.text ?? ""
        //提交反馈
         guard ZJPNetWork.netWorkAvailable() else {
            ZJPAlert.show(withMessage: JPTool.noNetWorkAlert(), time: 1.5)
            return
        }
//        self.contentTextView.text  =  [Utils disable_emoji:self.contentTextView.text];
//        self.emailTextField.text   =  [Utils disable_emoji:self.emailTextField.text];// 过滤表情
        let paramsDict = NSMutableDictionary(dictionary: ["content": contentText, "email": emailText, "token": JPTool.user_TOKEN()])
        JPNetWork.sharedManager()?.requestPostMethod(withPathUrl: JPTool.myMineFeecbackPath(), withParamsDict: paramsDict, withSuccessBlock: { [weak self] (response) in
        
            guard let self = self, let responseObject = response as? Dictionary<String, Any>,
                let errorNum = responseObject["errorno"] as? Int64 else {
                    print("网络请求返回的,不是需要的数据")
                    return
            }
            
            debugPrint(responseObject)
            
            if errorNum == 200 {
                ZJPAlert.show(withMessage: "反馈成功", time: 1.5)
                self.navigationController?.popViewController(animated: true)
            }else {
                
            }
        }, withFailurBlock: { (err) in
//            NSInteger errorNum = [responseObject[@"errorno"]  integerValue];
//            [SVProgressHUD showErrorWithStatus:@"数据上传失败"];
        })
        
    }
    
}

extension MSYFeedBackController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if text != "" {
            pleaceHolderLabel.isHidden = true
        }
        
        if text == "", range.location == 0, range.length == 1 {
            pleaceHolderLabel.isHidden = false
        }
        
        return true
    }
}

// MARK: - 导航栏相关设置
extension MSYFeedBackController {
    
    private func setUpNav() {
        let titleView = UILabel(frame: CGRect(x: 0, y: 0 , width: 180, height: 44))
        titleView.text = "意见反馈"
        titleView.textAlignment = .center
        titleView.font = JLPingFangSCFont(style: "Semibold", size: 16.0)
        titleView.textColor = COLOR_666666
        navigationItem.titleView = titleView
    }
    
}
