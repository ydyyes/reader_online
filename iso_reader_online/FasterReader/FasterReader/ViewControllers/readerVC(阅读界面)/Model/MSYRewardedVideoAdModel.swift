//
//  MSYRewardedVideoAdModel.swift
//  FasterReader
//
//  Created by apple on 2019/7/13.
//  Copyright © 2019 Restver. All rights reserved.
//

import UIKit
import BUAdSDK

@objcMembers class MSYRewardedVideoAdModel: NSObject {
    private var chuanShanJiaRewardedVideoAd: BURewardedVideoAd?
    private var chuanShanJiaNativeAdManager: BUNativeAdsManager?
    
    weak var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
        super.init()
    }
    
    func loadRewardAd() {
        let model = BURewardedVideoModel()
        model.userId = JPTool.user_ID()
        model.isShowDownloadBar = true
        chuanShanJiaRewardedVideoAd = BURewardedVideoAd(slotID: BURewardAdId, rewardedVideoModel: model)
        chuanShanJiaRewardedVideoAd?.delegate = self
        chuanShanJiaRewardedVideoAd?.loadData()
        MobClick.event("ttad_download_adv_load")
        
    }
    
    private func goToRewardController() {
        
        if let navigationController = self.navigationController, let isAdValid = chuanShanJiaRewardedVideoAd?.isAdValid, isAdValid {
            chuanShanJiaRewardedVideoAd?.show(fromRootViewController: navigationController)
        }else{
            ZJPAlert.show(withMessage: "激励视频加载失败", time: 1.0)
        }
    }
}


extension MSYRewardedVideoAdModel: BURewardedVideoAdDelegate {
    //MARK: -穿山甲广告-BURewardedVideoAdDelegate
    func rewardedVideoAdDidLoad(_ rewardedVideoAd: BURewardedVideoAd) {
        MobClick.event("ttad_download_adv_load_success")
        goToRewardController()
    }
    func rewardedVideoAd(_ rewardedVideoAd: BURewardedVideoAd, didFailWithError error: Error) {
        MobClick.event("ttad_download_adv_load_fail")
    }
    func rewardedVideoAdDidClick(_ rewardedVideoAd: BURewardedVideoAd) {
        MobClick.event("ttad_download_adv_load_click")
    }
    func rewardedVideoAdDidVisible(_ rewardedVideoAd: BURewardedVideoAd) {
        MobClick.event("ttad_download_adv_load_show")
    }
    
    func rewardedVideoAdServerRewardDidSucceed(_ rewardedVideoAd: BURewardedVideoAd, verify: Bool) {
        if verify {
            debugPrint("rewardedVideoAdServerRewardDidSucceed");
        }else{
            debugPrint("虽然rewardedVideoAdServerRewardDidSucceed")
        }
    }
}
