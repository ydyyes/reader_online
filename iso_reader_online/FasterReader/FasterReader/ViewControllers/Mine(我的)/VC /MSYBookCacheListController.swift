//
//  MSYBookCacheListController.swift
//  FasterReader
//
//  Created by apple on 2019/7/5.
//  Copyright © 2019 Restver. All rights reserved.
//

import UIKit
import SnapKit

class MSYBookCacheListController: JLXXTableViewController {
    
    private var originTableViewFrame: CGRect!
    private var deleteView: MSYCacheListDeleteView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        originTableViewFrame = tableView.frame

        tableView.deselectRowWhenSelectRow = false
        
        setUpNav()
     
        MSYBookDownloadManager.share().delegate = self
    }
    
    override func createDataSourceProvider() {
        provider = JLXXTableViewDataSourceProvider(dataSource: MSYBookCacheListDataSource(), delegate: self)
        let section0 = JLXXTableViewSectionItem()
        provider.sectionItems.append(section0)
        getData()
    }
    
    private func getData() {
        let section0 = provider.getSectionItem(at: 0)
        section0.rowItems.removeAllObjects()
        
        let allCachedBooks = MSYBookCache.getAllBookCacheArray()
        let cacheListModels = allCachedBooks.map { (model) -> MSYBookCacheModel in
            model.downloadStatus = MSYBookCache.getDownloadState(withBookid: model.bookId)
            model.chaptersCount = MSYChapterCache.getBookAllChapters(withBookid: model.bookId).count
            model.downloadChaptersCount = MSYChapterCache.getBookDownloadChapterCount(model.bookId).count
            return model
        }
        section0.rowItems.addObjects(from: cacheListModels)
    }
    
    func didSelectRow(for tableView: UITableView, with item: Any?, at indexPath: IndexPath) {
        
        guard let model = item as? MSYBookCacheModel, !tableView.isEditing else {
            //编辑状态,选择一个cell后改变删除view的删除按钮的文字
            setDeleteViewDeleteButtonTitle()
            return
        }
        
        //不是编辑状态
        
        if model.downloadStatus == .successDownloaded {
            //下载完成的书籍点击后跳转到阅读界面
            let reading = ADPageViewController()
            reading.cover = model.cover
            reading.bookId = model.bookId
            reading.bookName = model.bookName
            reading.lastChapter = model.lastChapter
            reading.author = model.author
            reading.majorCate = model.majorCate
            reading.updated = model.updated
            self.navigationController?.pushViewController(reading, animated: true)
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        
        if MSYBookCache.share().isCanDownloadBook(withBookid: model.bookId)
        {
            //可以下载
            changeDownloadStatus(with: model)
        }
        else
        {
            //不可下载
            tableView.deselectRow(at: indexPath, animated: true)
            ZJPAlert.show(withMessage: "每天只可以免费下载三次", time: 1.5)
        }
    }
    
    func didDeselectRowAt(for tableView: UITableView, with item: Any?, at indexPath: IndexPath) {
        guard tableView.isEditing else { return }
        //编辑状态,选择一个cell后改变删除view的删除按钮的文字
        setDeleteViewDeleteButtonTitle()
    }
    
    func deleteRow(for tableView: UITableView, with item: Any?, at indexPath: IndexPath) -> Bool {
        
        guard let model = item as? MSYBookCacheModel else { return false }
        
        //要删除了,取消下载
        MSYBookDownloadManager.share().cancelDownload(with: model)
        
        MSYChapterCache.share().removeBookAllInfo(withBookId: model.bookId)
        
        return true
    }
    
    private func changeDownloadStatus(with model: MSYBookCacheModel) {
        if model.downloadStatus == .downloaing {
            MSYBookDownloadManager.share().suspendedDownload(with: model)
        }else if model.downloadStatus == .suspendDownload {
            MSYBookDownloadManager.share().restartDownload(with: model)
        }else if model.downloadStatus == .notDownload {
            MSYBookDownloadManager.share().startDownloadBook(with: model)
        }else {
            debugPrint("点击了.下载完成的那一个小说")
        }
    }
    
}

extension MSYBookCacheListController: MSYBookDownloadManagerDelegate {
    
    func msyBookDownloadManager(_ manager: MSYBookDownloadManager, bookDownloaderStartDownload bookDownloader: MSYBookDownloader) {
        
        chngeModelDownloadStatus(with: bookDownloader.bookId, status: .downloaing)
    }
    
    func msyBookDownloadManager(_ manager: MSYBookDownloadManager, bookDownloaderSuspendDownload bookDownloader: MSYBookDownloader) {
        
        chngeModelDownloadStatus(with: bookDownloader.bookId, status: .suspendDownload)
    }
    
    func msyBookDownloadManager(_ manager: MSYBookDownloadManager, bookDownloaderSuccessDownload bookDownloader: MSYBookDownloader) {
        
        chngeModelDownloadStatus(with: bookDownloader.bookId, status: .successDownloaded)
    }
    
    func msyBookDownloadManager(_ manager: MSYBookDownloadManager, bookDownloader: MSYBookDownloader, alreadyDownloadChapterCount alreadyDownloadCount: Int, totalChapterCount totalCount: Int) {
        
        let tuple = getModelAndIndexFromDatasource(with: bookDownloader.bookId)
        guard let model = tuple.model, let row = tuple.row else { return }
        
        if (model.downloadStatus != .downloaing)
        {
            //在下载章节时,点击了暂停下载按钮
            //由于网络是异步执行的 主线程点击暂停按钮了,网络还在下载,还会走这里,所以当发现状态是暂停时,不能再去设置标题了
            return;
        }
        
        let indexPath = IndexPath(row: row, section: 0)
        if let msyCacheListCell = tableView.cellForRow(at: indexPath) as? MSYBookCacheListCell {
            model.downloadChaptersCount = alreadyDownloadCount
            msyCacheListCell.setDesLabelTextAndProgress(with: model)
            debugPrint("找到cell了????????????")
        }else{
            debugPrint("找不到cell了!!!!!!!!!!!!!!!!!")
        }
    }

    private func chngeModelDownloadStatus(with bookId: String, status: MSYBookDownloadStatus) {
        if let model = getModelAndIndexFromDatasource(with: bookId).model {
            model.downloadStatus = status
            self.reloadData()
        }
    }
    
    private func getModelAndIndexFromDatasource(with bookId: String) -> (model: MSYBookCacheModel?, row: Int?) {
        guard let rowItems = provider.getSectionItem(at: 0).rowItems as? [MSYBookCacheModel] else {
            return (nil, nil)
        }
        let result = rowItems.filter { $0.bookId == bookId }
        if let model = result.first, let index = rowItems.firstIndex(of: model) {
            return (model, index)
        }
        return (nil, nil)
    }
}

extension MSYBookCacheListController {
    
    private func setUpNav() {

        let titleView = UILabel(frame: CGRect(x: 0, y: 0 , width: 180, height: 44))
        titleView.text = "缓存列表"
        titleView.textAlignment = .center
        titleView.font = JLPingFangSCFont(style: "Semibold", size: 16.0)
        titleView.textColor = COLOR_666666
        navigationItem.titleView = titleView
        
        //右按钮
        let right = UIButton(type: .custom)
        right.frame = CGRect(x: 0, y: 0, width: 40, height: 44)
        right.titleLabel?.font = JLPingFangSCFont(size: 14.0)
        right.setTitle("编辑", for: .normal)
        right.setTitleColor(COLOR_666666, for: .normal)
        right.addTarget(self, action: #selector(rightButtonClick), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: right)
    }
    
    @objc private func rightButtonClick() {
        
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.setEditing(!tableView.isEditing, animated: true)
        
        if tableView.isEditing {
            //改变tableView的frame
            let width = originTableViewFrame.width
            let height = originTableViewFrame.height - 50
            let x = originTableViewFrame.origin.x
            let y = originTableViewFrame.origin.y
            tableView.frame = CGRect(x: x, y: y, width: width, height: height)
            //展示删除view
            setUpDeleteCacheView()
        }else{
            //退出编辑模式了,恢复frame
            tableView.frame = originTableViewFrame
            self.deleteView?.removeFromSuperview()
        }
        
        if let button = navigationItem.rightBarButtonItem?.customView as? UIButton {
            let title = tableView.isEditing ? "取消  " : "编辑  "
            button.setTitle(title, for: .normal)
        }
    }
    
}

extension MSYBookCacheListController: MSYCacheListDeleteViewDelegate {
    
    private func setUpDeleteCacheView() {
        let deleteView = MSYCacheListDeleteView.fromNib()
        deleteView.delegate = self
        view.addSubview(deleteView)
        deleteView.snp.makeConstraints { (maker) in
            maker.left.right.bottom.equalToSuperview()
            maker.height.equalTo(50)
        }
        self.deleteView = deleteView
    }
    
    func msyCacheListDeleteView(deleteView: MSYCacheListDeleteView, isSelectAll: Bool) {
        
        let rowItems = provider.getSectionItem(at: 0).rowItems
        if isSelectAll
        {
            for i in 0..<rowItems.count
            {
                let indexPath = IndexPath(row: i, section: 0)
                tableView.selectRow(at: indexPath, animated: false, scrollPosition: .middle)
            }
        }
        else
        {
            for i in 0..<rowItems.count
            {
                let indexPath = IndexPath(row: i, section: 0)
                tableView.deselectRow(at: indexPath, animated: false)
            }
        }

        setDeleteViewDeleteButtonTitle()
    }
    
    func msyCacheListDeleteViewDidClickDelete(deleteView: MSYCacheListDeleteView) {
        guard let selectedIndexPaths = tableView.indexPathsForSelectedRows else { return }
        let rowItems = provider.getSectionItem(at: 0).rowItems
        
        //取出要删除的model
        var deleteModels = [MSYBookCacheModel]()
        for indexPath in selectedIndexPaths {
            if let model = rowItems[indexPath.row] as? MSYBookCacheModel {
                deleteModels.append(model)
            }
        }
        //删除
        for model in deleteModels {
            //要删除了,暂停下载
            MSYBookDownloadManager.share().cancelDownload(with: model)
            //删除缓存的信息
            MSYChapterCache.share().removeBookAllInfo(withBookId: model.bookId)
            rowItems.remove(model)
        }
        //取消编辑状态
        rightButtonClick()
        //移除底部删除视图
        deleteView.removeFromSuperview()
        //刷新数据
        self.getData()
        self.reloadData()
    }
    
    private func setDeleteViewDeleteButtonTitle() {
        //设置标题
        var buttonTitle = "删除"
        if let selectedRows = tableView.indexPathsForSelectedRows
        {
            buttonTitle = "删除(\(selectedRows.count))"
        }
        deleteView?.deleteButton.setTitle(buttonTitle, for: .normal)
    }
    
}
