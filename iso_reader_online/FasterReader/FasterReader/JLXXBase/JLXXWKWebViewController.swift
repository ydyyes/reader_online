//
//  JLXXWKWebViewController.swift
//  JinglanEx
//
//  Created by apple on 2018/9/14.
//  Copyright © 2018年 JLXX. All rights reserved.
//

import UIKit
import WebKit

protocol JLXXWKWebViewNavigationDelegate: class {
	
	func jlxxWebView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) -> WKNavigationActionPolicy
	
	func jlxxWebView(_ webView: WKWebView, didFinish navigation: WKNavigation)
	
}

open class JLXXWKWebViewController: JLXXViewController {
	
	enum OriginPosition {
		case origin
		case statusBar
		case navgationBar
	}
	
	var webView: WKWebView?
	
	weak var navigationDelegate: JLXXWKWebViewNavigationDelegate?
	
	var scriptMessageHandler: JLXXWKWebViewScriptMessageHandler?
	var scriptMessages: [String]?
	var webViewFrame: CGRect?
	var urlString: String?
	var url: URL?
	var baseDecidePolicy = true
	
	private var observation: NSKeyValueObservation?
	
	var originY: OriginPosition = .navgationBar
	
	open override func viewDidLoad() {
		super.viewDidLoad()
		
		creatWebView()
		
		loadUrl()
		
		observation = webView?.observe(\.title, options: [.old, .new]) { [weak self] (web, change) in
			//如果没有设置title,则设置为网页的title
			guard let self = self else { return }
			if self.navigationItem.title == nil {
				self.navigationItem.title = web.title
			}
		}
	}
	
	func loadUrl() {
		if let url = url {
			let urlrequest = URLRequest(url: url)
			webView?.load(urlrequest)
		}else if let string = urlString, let url = URL(string: string) {
			let urlrequest = URLRequest(url: url)
			webView?.load(urlrequest)
		}
	}
	
	func setUpConfiguration(_ configuration: WKWebViewConfiguration?, scriptMessageHandler: WKScriptMessageHandler?) {
		
		guard let messageHandler = scriptMessageHandler, let methods = scriptMessages else { return }
		
		for method in methods {
			configuration?.userContentController.add(messageHandler, name: method)
		}
	}
	
	private func creatWebView() {
		
		var tabBarHeight = tabBarController?.tabBar.bounds.height ?? 0.0
		if (hidesBottomBarWhenPushed) {
			//当tabbar不显示时,高度应设置为0
			tabBarHeight = 0.0
		}
		let statusBar = UIApplication.shared.statusBarFrame.height
		let width = view.bounds.width
		var height = view.bounds.height - tabBarHeight
		
		var frame = CGRect(x: 0, y: 0, width: width, height: height)
		
		if originY == .statusBar {
			height -= statusBar
			frame = CGRect(x: 0, y: statusBar, width: view.bounds.width, height: height)
		}else if originY == .navgationBar {
			let navgationBarHeight = navigationController?.navigationBar.bounds.height ?? 0.0
			let statusNavgationBarHeight = statusBar + navgationBarHeight
			height -= statusNavgationBarHeight
			frame = CGRect(x: 0, y: statusNavgationBarHeight, width: view.bounds.width, height: height)
		}
		if let webViewFrame = webViewFrame {
			frame = webViewFrame
		}
		
		let config = WKWebViewConfiguration()
		setUpConfiguration(config, scriptMessageHandler: scriptMessageHandler)
		webView = WKWebView(frame: frame, configuration: config)
		webView?.navigationDelegate = self
		webView?.uiDelegate = self
        webView?.allowsBackForwardNavigationGestures = true
		view.addSubview(webView!)
		
		if #available(iOS 11.0, *) {
			webView?.scrollView.contentInsetAdjustmentBehavior = .never
		}else {
			automaticallyAdjustsScrollViewInsets = false
		}
	}
	
}

extension JLXXWKWebViewController: WKUIDelegate {
	
	public func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
		
		let alert = UIAlertController(title: "提示", message: message, preferredStyle: .alert)
		let action = UIAlertAction(title: "好的", style: .cancel) { (_) in
			completionHandler()
		}
		alert.addAction(action)
		present(alert, animated: true, completion: nil)
	}
	
	public func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
		
		let alert = UIAlertController(title: "提示", message: message, preferredStyle: .alert)
		let action = UIAlertAction(title: "确定", style: .default) { (_) in
			completionHandler(true)
		}
		let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (_) in
			completionHandler(false)
		}
		
		alert.addAction(action)
		alert.addAction(cancelAction)
		present(alert, animated: true, completion: nil)
	}
	
	//	public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
	//		let url = navigationAction.request.url
	//		if let urlString = url?.absoluteString, !urlString.contains("etbank.kinlink.cn"), let scheme = url?.scheme, scheme.contains("http") {
	//			gotoNewController(url)
	//		}
	//		return nil
	//	}
}

extension JLXXWKWebViewController: WKNavigationDelegate {
	
	public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
		
		navigationDelegate?.jlxxWebView(webView, didFinish: navigation)
	}
	
	public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
		debugPrint(error)
	}
	
	public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
		
		if let navigationDelegate = navigationDelegate, !baseDecidePolicy {
			
			let policy = navigationDelegate.jlxxWebView(webView, decidePolicyFor: navigationAction)
			decisionHandler(policy)
			return
		}
		
		decisionHandler(.allow)
		
		let url = navigationAction.request.url
		if let isMainFrame = navigationAction.targetFrame?.isMainFrame, isMainFrame {
			debugPrint("ben ye mian da kai")
		}else{
			gotoNewController(url)
		}
	}
	
	func gotoNewController(_ url: URL? ) {
		let web = JLXXWKWebViewController()
		web.urlString = url?.absoluteString
		
		if let navigationController = navigationController {
			navigationController.pushViewController(web, animated: true)
		}else {
			// 关闭按钮
			//			let close = UIButton(type: .custom)
			//			close.setImage(UIImage.init(named: "icon_back"), for: .normal)
			//			close.addTarget(self, action: #selector(closeWeb), for: .touchUpInside)
			//			close.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
			let closeItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(_closeWeb))
			web.navigationItem.leftBarButtonItem = closeItem
			let nav = UINavigationController(rootViewController: web)
			present(nav, animated: true, completion: nil)
		}
	}
	
	@objc private func _closeWeb() {
		dismiss(animated: true, completion: nil)
	}
}

protocol JLXXWKWebViewScriptMessageDelegate: class {
	
	func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage)
	
}

public class JLXXWKWebViewScriptMessageHandler: NSObject {
	
	private weak var delegate: JLXXWKWebViewScriptMessageDelegate?
	
	init(delegate: JLXXWKWebViewScriptMessageDelegate) {
		self.delegate = delegate
		super.init()
	}
	
	deinit {
		debugPrint("JLXXWKWebViewScriptMessageHandler dealloc")
	}
	
}

extension JLXXWKWebViewScriptMessageHandler: WKScriptMessageHandler {
	
	public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
		
		delegate?.userContentController(userContentController, didReceive: message)
	}
}

