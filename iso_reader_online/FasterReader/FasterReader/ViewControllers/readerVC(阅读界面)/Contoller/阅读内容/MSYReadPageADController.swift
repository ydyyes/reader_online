//
//  MSYReadPageADController.swift
//  FasterReader
//
//  Created by apple on 2019/7/10.
//  Copyright © 2019 Restver. All rights reserved.
//

import UIKit
import SnapKit
import BUAdSDK

@objcMembers class MSYReadPageADController: UIViewController {
    var pageIndex: Int = 0
    var chapterIndex: Int = 0
    var chapterTitle: String?
    
    
    private weak var adContentView: UIView?

    private var chuanShanJiaRewardedVideoAd: BURewardedVideoAd?
    private var chuanShanJiaNativeAdManager: BUNativeAdsManager?
    lazy var chuanShanJiaNavtiveAdView: ZJPChuanShanJiaView = {
        let frame = CGRect(x: 0, y: 35, width: JL_SCREEN_W, height: 200)
        let jp = ZJPChuanShanJiaView(frame: frame)
        jp.backgroundColor = .white
        return jp
    }()
    private var guangDianTongNativeAd: GDTNativeExpressAd?
    
    
    private let adLeftOrRight = 5 * JPTool.widthScale()
    private var adViewWidth: CGFloat = 0
    private var adViewHeight: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = MSYReaderSetting.shareInstance()?.getReaderBackgroundColor()?.withAlphaComponent(0.95)
        
        setUpADContentView()
     
        
        let chapterLabel = UILabel()
        view.addSubview(chapterLabel)
        chapterLabel.snp.makeConstraints { (maker) in
            maker.left.equalToSuperview().offset(15)
            maker.height.equalTo(13)
            if #available(iOS 11.0, *) {
                maker.top.equalTo(self.view.safeAreaLayoutGuide)
            } else {
                maker.top.equalToSuperview().offset(20)
            }
        }
        chapterLabel.font = UIFont.systemFont(ofSize: 12)
        chapterLabel.textColor = .black
        chapterLabel.text = chapterTitle

        
        let contentLabel = UILabel()
        view.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { (maker) in
            maker.left.equalToSuperview().offset(adLeftOrRight)
            maker.top.equalTo(chapterLabel.snp.bottom).offset(5)
        }
        contentLabel.font = UIFont.systemFont(ofSize: MSYReaderSetting.shareInstance()?.setting.fontSize ?? 12)
        contentLabel.textColor = MSYReaderSetting.shareInstance()?.getReaderTextColor()
        contentLabel.text = "    精彩还在继续"

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if JPTool.isThirtyMinuteMianAd() {
            self.adContentView?.removeAllSubviews()
        }
    }
    
    private func setUpADContentView() {
        adViewWidth = JPTool.screenWidth() - adLeftOrRight * 2
        adViewHeight = adViewWidth * 0.85
        
        let adContentView = UIView()
        //    self.adContentView.backgroundColor = [UIColor greenColor];
        adContentView.backgroundColor = .clear
        view.addSubview(adContentView)
        adContentView.snp.makeConstraints { (maker) in
            maker.left.right.equalToSuperview()
            maker.bottom.equalToSuperview().offset(-65)
            maker.height.equalTo(adViewHeight + 35)
        }
        self.adContentView = adContentView
        
        //激励视频
        if JPTool.isShowRewardAd() {
            setUpChuanShanJiaRewardAd()
        }
        
        let showAd = JPTool.showChapterAD()
        if showAd == "1"
        {
            setUpGuangDianTongNativeAd()
        }
        else if showAd == "2"
        {
            setUpChuanShanJiaNativeAd()
        }
    }
    
}

//MARK: -穿山甲广告
extension MSYReadPageADController: BUNativeAdsManagerDelegate, BUNativeAdDelegate, BURewardedVideoAdDelegate {
    
    private func setUpChuanShanJiaRewardAd() {
        
        let rewardButton = UIButton(type: .custom)
        rewardButton.setTitle("  观看视频免30分钟广告  ", for: .normal)
        rewardButton.backgroundColor = JLRGB(38, 125, 244)
        rewardButton.layer.cornerRadius = 8;
        rewardButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        rewardButton.addTarget(self, action: #selector(goToRewardController), for: .touchUpInside)
        adContentView?.addSubview(rewardButton)
        rewardButton.snp.makeConstraints { (maker) in
            maker.top.centerX.equalToSuperview()
            maker.height.greaterThanOrEqualTo(30)
        }
        
        
        let model = BURewardedVideoModel()
        model.userId = JPTool.user_ID()
        model.isShowDownloadBar = true
        chuanShanJiaRewardedVideoAd = BURewardedVideoAd(slotID: BURewardAdId, rewardedVideoModel: model)
        chuanShanJiaRewardedVideoAd?.delegate = self
        chuanShanJiaRewardedVideoAd?.loadData()
        
        MobClick.event("ttad_reward_adv_load")
        
    }
    
    @objc private func goToRewardController() {
        
        if let navigationController = self.navigationController, let isAdValid = chuanShanJiaRewardedVideoAd?.isAdValid, isAdValid {
            chuanShanJiaRewardedVideoAd?.show(fromRootViewController: navigationController)
        }else{
            ZJPAlert.show(withMessage: "激励视频加载失败", time: 1.0)
        }
    }
    
    //MARK: -穿山甲广告-BURewardedVideoAdDelegate
    func rewardedVideoAdDidLoad(_ rewardedVideoAd: BURewardedVideoAd) {
        MobClick.event("ttad_reward_adv_load_success")
    }
    func rewardedVideoAd(_ rewardedVideoAd: BURewardedVideoAd, didFailWithError error: Error) {
        MobClick.event("ttad_reward_adv_load_fail")
    }
    func rewardedVideoAdDidClick(_ rewardedVideoAd: BURewardedVideoAd) {
        MobClick.event("ttad_reward_adv_load_click")
    }
    func rewardedVideoAdDidVisible(_ rewardedVideoAd: BURewardedVideoAd) {
        MobClick.event("ttad_reward_adv_load_show")
    }
    
    func rewardedVideoAdServerRewardDidSucceed(_ rewardedVideoAd: BURewardedVideoAd, verify: Bool) {
        if verify {
            print("rewardedVideoAdServerRewardDidSucceed,认证成功,处理免30分钟广告");
            JPTool.thirtyMinuteMianAd()
            JPTool.changeRewardAdInfo()
        }else{
            print("虽然rewardedVideoAdServerRewardDidSucceed,但是没有认证成功")
        }
    }
    
    private func setUpChuanShanJiaNativeAd() {
        chuanShanJiaNativeAdManager = BUNativeAdsManager()
        let slot1 = BUAdSlot()
        slot1.id = "916892990"
        slot1.adType = .feed
        slot1.position = .top
        slot1.imgSize = BUSize.init(by: .feed690_388)
        slot1.isSupportDeepLink = true
        chuanShanJiaNativeAdManager?.adslot = slot1
        chuanShanJiaNativeAdManager?.delegate = self
        chuanShanJiaNativeAdManager?.loadAdData(withCount: 1)
        MobClick.event("ttad_feed_adv_load")
    }
    
    func nativeAdsManager(_ adsManager: BUNativeAdsManager, didFailWithError error: Error?) {
        MobClick.event("ttad_feed_adv_load_fail")
    }
    
    //MARK: -穿山甲广告-BUNativeAdsManagerDelegate
    func nativeAdsManagerSuccess(toLoad adsManager: BUNativeAdsManager, nativeAds nativeAdDataArray: [BUNativeAd]?) {
        
        if let nativeAd = nativeAdDataArray?.first
        {
            chuanShanJiaNativeAdReloadData(nativeAd)
            MobClick.event("ttad_feed_adv_load_success")
        }
    }
    
    private func chuanShanJiaNativeAdReloadData(_ nativeAd: BUNativeAd) {
        
        adContentView?.addSubview(chuanShanJiaNavtiveAdView)
        
        nativeAd.rootViewController = self
        nativeAd.delegate = self
        
        nativeAd.registerContainer(chuanShanJiaNavtiveAdView, withClickableViews: [chuanShanJiaNavtiveAdView.customBtn])
        chuanShanJiaNavtiveAdView.nativeAd = nativeAd
        chuanShanJiaNavtiveAdView.height = ZJPChuanShanJiaView.cellHeight(withModel: nativeAd, width: JL_SCREEN_W)
    }
    
    
    //MARK -穿山甲广告-BUNativeAdDelegate
    func nativeAdDidBecomeVisible(_ nativeAd: BUNativeAd) {
        let userDefaults = UserDefaults.standard
        // 当前时间存入本地
        userDefaults.setValue(NSDate(), forKey: LAST_CHAPTER_AD_SHOW_TIME_KEY)
        userDefaults.synchronize()
        MobClick.event("ttad_feed_adv_show")
    }
    
    func nativeAdDidClick(_ nativeAd: BUNativeAd, with view: UIView?) {
        MobClick.event("ttad_feed_adv_click")
    }
    
    func nativeAd(_ nativeAd: BUNativeAd, dislikeWithReason filterWords: [BUDislikeWords]) {
        print("click dislike");
        chuanShanJiaNavtiveAdView.removeFromSuperview()
//        adContentView?.removeFromSuperview()
    }
    
}


//MARK: -广点通广告
extension MSYReadPageADController: GDTNativeExpressAdDelegete {
    
    private func setUpGuangDianTongNativeAd() {

        let size = CGSize(width: adViewWidth, height: adViewHeight)
        guangDianTongNativeAd = GDTNativeExpressAd(appId: kGDTMobSDKAppId, placementId: YplacementId, adSize: size)
        guangDianTongNativeAd?.delegate = self
        //非 WiFi 网络，是否自动播放。默认 NO。loadAd 前设置。
        guangDianTongNativeAd?.videoAutoPlayOnWWAN = false
        //自动播放时，是否静音。默认 YES。loadAd 前设置。
        guangDianTongNativeAd?.videoMuted = true;
        guangDianTongNativeAd?.load(1)
        
        MobClick.event("gdt_native_adv_load")
    }
    
    //MARK -广点通广告-GDTNativeExpressAdDelegete
    func nativeExpressAdFail(toLoad nativeExpressAd: GDTNativeExpressAd!, error: Error!) {
        MobClick.event("gdt_native_adv_load_fail")
    }
    
    func nativeExpressAdSuccess(toLoad nativeExpressAd: GDTNativeExpressAd!, views: [GDTNativeExpressAdView]!) {
        if views.count == 0 { return }

        for expressAdView in views {
            expressAdView.controller = self
            expressAdView.render()
        }
        // 广告的位置
        let view = views[0]
        view.frame = CGRect(x: adLeftOrRight, y: 35, width: adViewWidth, height: adViewHeight)
        adContentView?.addSubview(view)
        
        MobClick.event("gdt_native_adv_load_success")
    }
    
    func nativeExpressAdViewExposure(_ nativeExpressAdView: GDTNativeExpressAdView!) {
        let userDefaults = UserDefaults.standard
        // 当前时间存入本地
        userDefaults.setValue(NSDate(), forKey: LAST_CHAPTER_AD_SHOW_TIME_KEY)
        userDefaults.synchronize()
        MobClick.event("gdt_native_adv_show")
    }
    
    func nativeExpressAdViewClicked(_ nativeExpressAdView: GDTNativeExpressAdView!) {
        MobClick.event("gdt_native_adv_click")
    }
    
    func nativeExpressAdViewClosed(_ nativeExpressAdView: GDTNativeExpressAdView!) {
        
        nativeExpressAdView.removeFromSuperview()
//        adContentView?.removeFromSuperview()

    }
    
    
}
