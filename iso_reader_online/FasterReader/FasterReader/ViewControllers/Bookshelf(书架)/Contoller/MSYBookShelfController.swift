//
//  MSYBookShelfController.swift
//  NightReader
//
//  Created by apple on 2019/6/27.
//  Copyright © 2019 MSYMobile. All rights reserved.
//

import UIKit
import SnapKit

class MSYBookShelfController: JLXXRefreshCollectionViewController {

    // 第一次更新
    private var isFirstRefresh = true
    
    private var redPacketView: UIView?
    private var redPacketModel: MSYAdModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpNav()
        getFloadAdRequest()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        appDelegate?.addOrRemoveModeView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        refreshBookshelf()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MobClick.event("book_shelf_fragment")
    }
    
    override func createDataSourceProvider() {
        let layout = MSYBookShelfCollectionViewLayout()
        provider = JLXXCollectionViewDataSourceProvider(dataSource: MSYBookShelfDataSource(), layout: layout, delegate: self)
        
        let sectionItem0 = JLXXCollectionViewSectionItem()
        provider.sectionItems.append(sectionItem0)
        
    }
    
    override func loadRequest() {
        
        guard ZJPNetWork.netWorkAvailable() else {
            
            ZJPAlert.show(withMessage: JPTool.noNetWorkAlert(), time: 1.5)
            
            stopRefreshing()
            
            return
        }
        
        let queue = DispatchQueue.global()
        let group = DispatchGroup()
        //获取每日推荐
        group.enter()
        queue.async {
            self.getDayRecommendData(group)
        }
        //根据已有的书籍id,循环请求去查询书籍信息
        let rowItems = self.provider.getSectionItem(at: 0).rowItems
        for item in rowItems
        {
            if let model = item as? BookCityBookModel
            {
                group.enter()
                queue.async {
                    self.getBookInfo(with: model, group: group)
                }
            }
        }
        //所有请求完成后的方法
        group.notify(queue: DispatchQueue.main) { [weak self] in
            guard let self = self else {  return }
            //在所有的数据末尾添加一个元素用来展示add图标
            self.appendAddIconToTheLast()
            //刷新
            self.reloadData()
        }
    }
    
    private func appendAddIconToTheLast () {
        let rowItems = self.provider.getSectionItem(at: 0).rowItems
        //保证数据源中只有一个
        if !(rowItems.lastObject is String) {
            rowItems.append("addIcon")
        }
    }
    
    func didSelect(for collectionView: UICollectionView, with item: Any?, at indexPath: IndexPath) {
        
        if let model = item as? BookCityBookModel
        {
            //跳转到阅读界面
            let reading = ADPageViewController()
            reading.cover = model.cover
            reading.bookId = model.bookId
            reading.bookName = model.title
            reading.lastChapter = model.lastChapter
            reading.author = model.author
            reading.majorCate = model.majorCate
            reading.updated = model.updated
            navigationController?.pushViewController(reading, animated: true)
        }
        else if item is String,
            let keyWindow = UIApplication.shared.keyWindow,
            let tab = keyWindow.rootViewController as? RootTabBarController
        {
            //点击了添加,跳转到书城添加书籍
            tab.selectControl(at: 1)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.redPacketView?.isHidden = true
    }
    
    func scrollViewDidEndScroll(_ scrollView: UIScrollView) {
        self.redPacketView?.isHidden = false
    }
}

extension MSYBookShelfController: MSYBookShelfCellDelegate {
    
    func msyBookShelfCell(msyBookShelfCell: MSYBookShelfCell, delete bookMolde: BookCityBookModel) {
        
        let deleteAction = UIAlertAction(title: "确定", style: .default) { [weak self] (action) in
            guard let self = self else { return }
            
            ADSherfCache.removeBookShelf(withBookId: bookMolde.bookId)
            let rowItems = self.provider.getSectionItem(at: 0).rowItems
            rowItems.remove(bookMolde)
            self.reloadData()
        }
        JLXXAlertController.alert(title: "确认删除", message: "确定要从书架删除这本书吗?", cancelTitle: "取消", presentingController: self, actions: [deleteAction])
    }
    
}


// MARK: -  网络请求、数据获取
extension MSYBookShelfController {
    
    // MARK: -  书架🧧广告
    private func getFloadAdRequest() {
        MSYAdModel.getFloadAdRequest { [weak self] (model) in
            guard let self = self else { return }
            self.setRedPacketView(with: model)
            self.redPacketModel = model
        }
    }
    
    // MARK: -  每日推荐
    private func getDayRecommendData(_ group: DispatchGroup) {
        
        guard ZJPNetWork.netWorkAvailable() else {
            //提示没有网络
            DispatchQueue.main.async {
                ZJPAlert.show(withMessage: JPTool.noNetWorkAlert(), time: 1.5)
            }
            //查看本地是否有数据
            if let model =  ADCache.share()?.cache.object(forKey: "DayRecommendData") as? BookCityBookModel {
                //更新数据
                let sectionItem = self.provider.getSectionItem(at: 0)
                sectionItem.sectionHeaderItem = model
            }
            //离开dispatchGroup
            group.leave()

            return
        }
        
        let paramsDict = NSMutableDictionary()
        JPNetWork.sharedManager()?.requestPostMethod(withPathUrl: JPTool.bookshelfDayRecommendPath(), withParamsDict: paramsDict, withSuccessBlock: { [weak self] (response) in
            
            guard let self = self, let responseObject = response as? Dictionary<String, Any>, let data = responseObject["data"] as? Dictionary<String, Any> else {
                //离开dispatchGroup
                group.leave()
                debugPrint("网络请求返回的,不是需要的数据,或self对象被释放")
                return
            }
            //数据h转模型
            let model = BookCityBookModel.yy_model(withJSON: data)
            let sectionItem = self.provider.getSectionItem(at: 0)
            sectionItem.sectionHeaderItem = model
            //缓存到本地
            ADCache.share()?.cache.setObject(model, forKey: "DayRecommendData")
            //离开dispatchGroup
            group.leave()

            }, withFailurBlock: { (error) in
                //离开dispatchGroup
                group.leave()
                debugPrint("withFailurBlock")
        })
    }
    
    // MARK: -  更新书架
    private func refreshBookshelf() {
        
        let sectionItem = provider.getSectionItem(at: 0)
        
        let firstLogin = UserDefaults.standard.object(forKey: "FirstLogin")
        if firstLogin == nil
        {//第一次安装APP
            let group = DispatchGroup()
            //获取推荐书籍
            group.enter()
            getBookRecommendData(group)
            //加载每日推荐
            group.enter()
            getDayRecommendData(group)
            //加载完全部网络请求的回调
            group.notify(queue: DispatchQueue.main) { [weak self] in
                guard let self = self else { return }
                //在所有的数据末尾添加一个元素用来展示add图标
                self.appendAddIconToTheLast()
                //刷新数据
                self.reloadData()
            }
            //存值
            UserDefaults.standard.set("FirstLogin", forKey: "FirstLogin")
            UserDefaults.standard.synchronize()
        }
        else
        {
            //先清空数据源中所有数据,因为有可能在其他页面添加书籍到书架了
            sectionItem.rowItems.removeAllObjects()
            //本地有缓存
            if let models = ADSherfCache.queryDesending() as? [Any]
            {
                //添加到数据源中
                sectionItem.rowItems.addObjects(from: models)
                //添加addIcon数据
                appendAddIconToTheLast()
                //是从appdelegate启动后到的书架页面
                if isFirstRefresh
                {
                    loadRequest()
                    isFirstRefresh = false
                }
                else
                {
                    reloadData()
                }
            }
            else
            {
                reloadData()
            }
        }
    }
    
    // MARK: -  更新书架上的每一本书的信息
    private func getBookInfo(with bookModel: BookCityBookModel, group: DispatchGroup) {
        
        guard ZJPNetWork.netWorkAvailable() else {
            //离开dispatchGroup
            group.leave()
            return
        }
        
        let paramsDict = NSMutableDictionary(dictionary: ["id": bookModel.bookId])
        JPNetWork.sharedManager()?.requestPostMethod(withPathUrl: JPTool.bookshelfBookDetailPath(), withParamsDict: paramsDict, withSuccessBlock: { (response) in
            
            guard let responseObject = response as? Dictionary<String, Any>,
                let data = responseObject["data"] as? Dictionary<String, Any>,
                let detailDic = data["detail"] as? Dictionary<String, Any>,
                detailDic.values.count > 0 else {
                    //离开dispatchGroup
                    group.leave()
                    debugPrint("网络请求返回的,不是需要的数据")
                    return
            }

            if let updated = detailDic["updated"] as? Int64, updated != Int64(bookModel.updated) {
                bookModel.redSpot = true
                bookModel.updated = String(10)
            }else{
                bookModel.redSpot = false
            }
            bookModel.title = detailDic["title"] as! String
            bookModel.lastChapter = detailDic["lastChapter"] as! String
            //更新本地缓存
            ADSherfCache.update(withBookInfo: bookModel)
            //离开dispatchGroup
            group.leave()
//            let indexPath = IndexPath(row: index, section: 0)
//            self.collectionView.reloadItems(at: [indexPath])

//            let model = BookCityBookModel.yy_model(withJSON: data)
//            let sectionItem = self.provider.getSectionItem(at: 0)
//            sectionItem.sectionHeaderItem = model
            
            }, withFailurBlock: {(error) in
                //离开dispatchGroup
                group.leave()
                debugPrint(error ?? "失败网络请求")
        })
    }
    
    // MARK: -  推荐书籍
    private func getBookRecommendData(_ group: DispatchGroup) {
    
        let rowItems = provider.getSectionItem(at: 0).rowItems
        if rowItems.count == 0
        {
            var sex = "\(JPTool.user_SEX())"
            if sex == "-1" {
                sex = "0"
            }
            let paramsDict = NSMutableDictionary(dictionary: ["gender": sex, "page": "1", "size": "6"])
            getRecommendData(paramsDict: paramsDict, pathUrl: JPTool.bookcityRecommendPath(), group: group)
        }else {
            //离开dispatchGroup
            group.leave()
        }
    }
    
    private func getRecommendData(paramsDict: NSMutableDictionary, pathUrl: String, group: DispatchGroup) {
        
        guard ZJPNetWork.netWorkAvailable() else {
            //提示没有网络
            ZJPAlert.show(withMessage: JPTool.noNetWorkAlert(), time: 1.5)
            //离开dispatchGroup
            group.leave()
            return
        }
        
        JPNetWork.sharedManager()?.requestPostMethod(withPathUrl: pathUrl, withParamsDict: paramsDict, withSuccessBlock: { [weak self] (response) in
            guard let self = self else { return }
            guard let responseObject = response as? Dictionary<String, Any>, let data = responseObject["data"] as? [Any] else {
                //离开dispatchGroup
                group.leave()
                debugPrint("网络请求返回的,不是需要的数据,responseObject:\(response)")
                return
            }
            
            let rowItems = self.provider.getSectionItem(at: 0).rowItems
            rowItems.removeAllObjects()
            
            for i in 0..<data.count {
                guard let model = BookCityBookModel.yy_model(withJSON: data[i]) else {
                    continue
                }
                rowItems.add(model)
                //添加到书架缓存
                ADSherfCache.addBook(model)
            }
            //离开dispatchGroup
            group.leave()
            //隐藏hud
            ZJPAlert.share().hiddenHUD()
            
            }, withFailurBlock: { (error) in
                //离开dispatchGroup
                group.leave()
                //隐藏hud
                ZJPAlert.share().hiddenHUD()
        })
    }
    
}

// MARK: - 导航栏相关设置
extension MSYBookShelfController {
    
    private func setUpNav() {
        //左边按钮
        let left = UILabel()
        left.text = "书架"
        left.textColor = COLOR_333333
        left.font = JLPingFangSCFont(style: "Semibold", size: 16.0)
        left.frame = CGRect(x: 0, y: 0, width: 40, height: 44)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: left)
        
        //右按钮
        let right = UIButton(type: .custom)
        right.frame = CGRect(x: 0, y: 0, width: 40, height: 44)
        right.setImage(UIImage.init(named: "more"), for: .normal)
        right.addTarget(self, action: #selector(rightButtonClick(_:)), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: right)
        //搜索
        let titleViewHeight: CGFloat = 28
        let titleView = UIButton(frame: CGRect(x: 0, y: (44 - titleViewHeight) / 2 , width: JL_SCREEN_W - 100, height: titleViewHeight))
        titleView.addTarget(self, action: #selector(titleViewClick), for: .touchUpInside)
        titleView.backgroundColor = COLOR_F0F0F0
        titleView.layer.cornerRadius = titleViewHeight / 2
        
        let imageView = UIImageView(image: UIImage.init(named: "gray_sousuo"))
        imageView.frame = CGRect(x: 14, y: titleViewHeight / 2 - 4, width: 13, height: 13)
        titleView.addSubview(imageView)

        let label = UILabel(frame: CGRect(x: imageView.frame.maxX + 8, y: imageView.frame.minY, width: 180, height: 14))
        label.text = "搜索书名、作者"
        label.font = JLPingFangSCFont(size: 14.0)
        label.textColor = COLOR_666666
        titleView.addSubview(label)
        navigationItem.titleView = titleView
    }
    
    @objc private func titleViewClick() {
        let search = SerachViewController()
        navigationController?.pushViewController(search, animated: true)
    }
    
    private func setRedPacketView(with model: MSYAdModel) {
        let redPacketView = UIButton(type: .custom)
        redPacketView.yy_setBackgroundImage(with: URL(string: model.cover), for: .normal)
        redPacketView.backgroundColor = .clear
        view.addSubview(redPacketView)
        redPacketView.addTarget(self, action: #selector(redPacketViewClick), for: .touchUpInside)
        let bottomMargin = JL_TAB_BAR_H(self) + 60
        redPacketView.snp.makeConstraints { (maker) in
            maker.bottom.equalToSuperview().offset(-bottomMargin)
            maker.right.equalToSuperview().offset(-10)
            maker.size.equalTo(CGSize(width: 50, height: 60))
        }
        self.redPacketView = redPacketView
    }
    
    @objc private func redPacketViewClick() {
        let web = JLXXWKWebViewController()
        web.urlString = redPacketModel?.link
        navigationController?.pushViewController(web, animated: true)
    }
}


extension MSYBookShelfController : YBPopupMenuDelegate {
    
    @objc private func rightButtonClick(_ button: UIButton) {
        
        guard let keyWindow = UIApplication.shared.keyWindow, let layout = provider.layout as? MSYBookShelfCollectionViewLayout else { return }
        
        let absoluteRect = button.convert(button.bounds, to: keyWindow)
        let relyPoint = CGPoint(x: absoluteRect.origin.x + absoluteRect.size.width / 2, y: absoluteRect.origin.y + absoluteRect.size.height)
        
        let showStyleTitle = layout.layoutStyle == .list ? "图文模式" : "列表模式"
        let modeTitle = MSYReaderSetting.shareInstance()!.setting.dayModel ? "夜间模式" : "日间模式"
        let modeIcon = MSYReaderSetting.shareInstance()!.setting.dayModel ? "yejian_icon" : "rijian_icon"
        let titles = ["书架排序", "清除缓存", showStyleTitle, "意见反馈", "阅读记录", modeTitle]
        let icons = ["paixu_icon", "huancun_icon", "liebiao_icon", "yijian_icon", "jilu_icon", modeIcon]
        YBPopupMenu.show(at: relyPoint, titles: titles, icons: icons, menuWidth: 128) { (popMenu) in
            popMenu?.fontSize = 12
            popMenu?.offset = -12
            popMenu?.maxVisibleCount = 6
            popMenu?.delegate = self
        }
    }
    
    func ybPopupMenu(_ ybPopupMenu: YBPopupMenu!, didSelectedAt index: Int) {
        switch index {
        case 0:
            excuteSort()
            break
        case 1:
            clearCache()
            break
        case 2:
            changShowStyle()
            break
        case 3:
            feedBack()
            break
        case 4:
            browseHostiy()
            break
        case 5:
            changedMode()
            break
        default:
            break
        }
    }
    
    // 改变模式
    private func changedMode() {
        let dayModel = MSYReaderSetting.shareInstance()!.setting.dayModel
        MSYReaderSetting.shareInstance()!.setting.dayModel = !dayModel
    }

    //意见反馈
    private func feedBack() {
        if JLXXAccount.shared.isLogin
        {
            let fankui = MSYFeedBackController()
            navigationController?.pushViewController(fankui, animated: true)
        }
        else
        {
            let login = MSYLoginOrBindPhoneController()
            navigationController?.pushViewController(login, animated: true)
        }
    }
    //浏览记录
    private func browseHostiy() {
        let controller = MSYBookBrowseHistoryController()
        navigationController?.pushViewController(controller, animated: true)
    }
    //改变展示样式
    private func changShowStyle() {
    
        guard let layout = collectionView.collectionViewLayout as? MSYBookShelfCollectionViewLayout else {
            return
        }
        //切换layoutStyle
        layout.layoutStyle = layout.layoutStyle == .bookShelf ? .list : .bookShelf
        //刷新列表
        self.reloadData()
    }
    
    //排序
    private func excuteSort() {
        let readTimeAction = UIAlertAction(title: "按最近阅读", style: .default) { [weak self] (action) in
            guard let self = self else { return }
            JPTool.changeBookshelfSortType(with: .readTime)
            self.sort(by: "readTime")
        }
        
        let updateTimeAction = UIAlertAction(title: "按更新时间", style: .default) { [weak self] (action) in
            guard let self = self else { return }
            JPTool.changeBookshelfSortType(with: .updateTime)
            self.sort(by: "updateTime")
        }
        JLXXAlertController.alert(title: "书架排序", cancelTitle: "取消", presentingController: self, actions: [readTimeAction, updateTimeAction])
    }
    
    private func sort(by style: String) {
        let rowItems = provider.getSectionItem(at: 0).rowItems
        rowItems.removeLastObject()
        if let models = rowItems as? [BookCityBookModel] {
            let results = models.sorted { (model0, model1) -> Bool in
                if style == "readTime" {
                    return (model0.readDate as NSString).doubleValue > (model1.readDate as NSString).doubleValue
                }else{
                    return (model0.updated as NSString).doubleValue > (model1.updated as NSString).doubleValue
                }
            }
            rowItems.removeAllObjects()
            rowItems.addObjects(from: results)
        }
        self.appendAddIconToTheLast()
        self.reloadData()
    }
    
    //清空缓存
    private func clearCache() {
        let clearBrowse = UIAlertAction(title: "清空阅读记录", style: .default) { [weak self] (action) in
            guard let self = self else { return }
            self.clearKindOfCache(browseHistory: true, bookShelf: false)
        }
        
        let clearBookShelf = UIAlertAction(title: "清空书架列表", style: .default) { [weak self] (action) in
            guard let self = self else { return }
            self.clearKindOfCache(browseHistory: false, bookShelf: true)
        }
        let clearAll = UIAlertAction(title: "清空阅读记录和书架列表", style: .default) { [weak self] (action) in
            guard let self = self else { return }
            self.clearKindOfCache(browseHistory: true, bookShelf: true)
        }
        JLXXAlertController.alert(title: "清除缓存", cancelTitle: "取消", presentingController: self, actions: [clearBrowse, clearBookShelf, clearAll])
    }
    
    private func clearKindOfCache(browseHistory: Bool, bookShelf: Bool) {
        if browseHistory {
            MSYBrowseHistoryCache.share().removeBrowseHistory()
        }
        if bookShelf {
            ADSherfCache.removeAllBooks()
            let sectionItem = provider.getSectionItem(at: 0)
            sectionItem.rowItems.removeAllObjects()
            //添加addIcon数据
            appendAddIconToTheLast()
            self.reloadData()
        }
    }
    
}

extension MSYBookShelfController: MSYBookShelfHeaderViewDelegate {
    func bookShelfHeaderViewBookInfoViewClick(bookShelfHeaderView: MSYBookShelfHeaderView, bookModel: BookCityBookModel) {

        
        let bookDetail = BookDetailViewController()
        bookDetail.bookId = bookModel.bookId
        navigationController?.pushViewController(bookDetail, animated: true)

    }
    
}


//搜索
//        let searchTextField = UITextField(frame: CGRect(x: 0, y: 0, width: JL_SCREEN_W - 80, height: 44))
//        searchTextField.background = UIImage.init(named: "sousuokuang")
//
//        searchTextField.font = JLPingFangSCFont(size: 15.0)
//        searchTextField.contentVerticalAlignment = .center
//        searchTextField.delegate = self
//        searchTextField.returnKeyType = UIReturnKeySearch;
//        searchTextField.clearButtonMode = .always
//        searchTextField.leftViewMode = .always
//        searchTextField.textColor = JLRGB(153, 153, 153)
//MARK:设置输入框leftView
//        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
//        leftView.backgroundColor = . clear
//        let leftImage = UIImageView(frame: CGRect(x: 8, y: 5.5, width: 21, height: 21))
//        leftImage.image = UIImage.init(named: "gray_sousuo")
//        leftView.addSubview(leftImage)
//        searchTextField.leftView = leftView
