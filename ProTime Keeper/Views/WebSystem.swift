//
//  WebSystem.swift
//  ProTime Keeper
//
//  Created on 2025
//

import SwiftUI
import Combine
import WebKit

struct WebSystem: View {
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea(.all)
            
            WebControllerRepresentable()
        }
    }
}

class WebController: UIViewController, WKNavigationDelegate, WKUIDelegate {
    
    @AppStorage("first_open") var firstOpen: Bool = true
    @AppStorage("silka") var silka: String = ""
    
    @Published var url_link: URL = URL(string: "https://google.com")!
    
    var webView = WKWebView()
    var loadCheckTimer: Timer?
    var isPageLoadedSuccessfully = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupKeyboardObservers()
        getRequest()
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        // Позволяем клавиатуре просто появиться поверх WebView
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        // Позволяем клавиатуре просто исчезнуть
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func getRequest() {
        guard let url = URL(string: DataManager().server) else { return }
        self.url_link = url
        self.getInfo()
    }
    
    private func getInfo() {
        var request: URLRequest?
        
        if silka == "about:blank" || silka.isEmpty {
            request = URLRequest(url: self.url_link)
        } else {
            if let currentURL = URL(string: silka) {
                request = URLRequest(url: currentURL)
            }
        }
        
        let cookies = HTTPCookieStorage.shared.cookies ?? []
        let headers = HTTPCookie.requestHeaderFields(with: cookies)
        request?.allHTTPHeaderFields = headers
        
        DispatchQueue.main.async {
            self.setupWebView()
        }
    }
    
    private func setupWebView() {
        let urlString = silka.isEmpty ? url_link.absoluteString : silka
        
        let config = WKWebViewConfiguration()
        config.preferences.javaScriptEnabled = true
        config.preferences.javaScriptCanOpenWindowsAutomatically = true
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        
        config.suppressesIncrementalRendering = false
        if #available(iOS 13.0, *) {
            config.defaultWebpagePreferences.allowsContentJavaScript = true
        }
        
        webView = WKWebView(frame: .zero, configuration: config)
        
        view.backgroundColor = .black
        view.addSubview(webView)
        
        webView.scrollView.bounces = false
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.scrollView.contentInset = .zero
        webView.scrollView.scrollIndicatorInsets = .zero
        
        if #available(iOS 11.0, *) {
            webView.scrollView.contentInsetAdjustmentBehavior = .never
        }
        
        if #available(iOS 11.0, *) {
            let insets = view.safeAreaInsets
            webView.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -insets.bottom, right: 0)
            webView.scrollView.scrollIndicatorInsets = webView.scrollView.contentInset
        }
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.leftAnchor.constraint(equalTo: view.leftAnchor),
            webView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        
        webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"
        
        webView.allowsBackForwardNavigationGestures = true
        webView.uiDelegate = self
        webView.navigationDelegate = self
        
        loadCookie()
        
        if urlString == url_link.absoluteString {
            var request = URLRequest(url: URL(string: urlString)!)
            request.httpMethod = "POST"
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            addBrowserHeaders(to: &request)
            webView.load(request)
        } else {
            print("DEFAULT TO: \(urlString)")
            if let requestURL = URL(string: urlString) {
                var request = URLRequest(url: requestURL)
                addBrowserHeaders(to: &request)
                webView.load(request)
            }
        }
    }
    
    private func addBrowserHeaders(to request: inout URLRequest) {
        request.setValue("text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", forHTTPHeaderField: "Accept")
        request.setValue("ru-RU,ru;q=0.9,en;q=0.8", forHTTPHeaderField: "Accept-Language")
        request.setValue("gzip, deflate, br", forHTTPHeaderField: "Accept-Encoding")
        request.setValue("1", forHTTPHeaderField: "DNT")
        request.setValue("keep-alive", forHTTPHeaderField: "Connection")
        request.setValue("same-origin", forHTTPHeaderField: "Sec-Fetch-Site")
        request.setValue("navigate", forHTTPHeaderField: "Sec-Fetch-Mode")
        request.setValue("?1", forHTTPHeaderField: "Sec-Fetch-Dest")
        request.setValue("?1", forHTTPHeaderField: "Upgrade-Insecure-Requests")
        
        if let currentURL = webView.url {
            request.setValue(currentURL.absoluteString, forHTTPHeaderField: "Referer")
        }
    }
    
    func webView(_ webView: WKWebView, contextMenuConfigurationForElement elementInfo: WKContextMenuElementInfo, completionHandler: @escaping (UIContextMenuConfiguration?) -> Void) {
        completionHandler(nil)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        isPageLoadedSuccessfully = false
        loadCheckTimer?.invalidate()
        loadCheckTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { [weak self] _ in
            if let strongSelf = self, !strongSelf.isPageLoadedSuccessfully {
                print("Страница не загрузилась в течение 5 секунд.")
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        isPageLoadedSuccessfully = true
        loadCheckTimer?.invalidate()
        
        if let currentURL = webView.url?.absoluteString, currentURL != url_link.absoluteString {
            silka = currentURL
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        isPageLoadedSuccessfully = false
        loadCheckTimer?.invalidate()
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        isPageLoadedSuccessfully = false
        loadCheckTimer?.invalidate()
    }
    
    func saveCookie() {
        let cookieJar = HTTPCookieStorage.shared
        
        if let cookies = cookieJar.cookies {
            let data = NSKeyedArchiver.archivedData(withRootObject: cookies)
            UserDefaults.standard.set(data, forKey: "cookie")
        }
    }
    
    func loadCookie() {
        let ud = UserDefaults.standard
        
        if let data = ud.object(forKey: "cookie") as? Data, let cookies = NSKeyedUnarchiver.unarchiveObject(with: data) as? [HTTPCookie] {
            for cookie in cookies {
                HTTPCookieStorage.shared.setCookie(cookie)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
}

struct WebControllerRepresentable: UIViewControllerRepresentable {
    typealias UIViewControllerType = WebController
    
    func makeUIViewController(context: Context) -> WebController {
        return WebController()
    }
    
    func updateUIViewController(_ uiViewController: WebController, context: Context) {}
}

// SSL Delegate для обработки сертификатов
class SSLDelegate: NSObject, URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
}

// Класс для отключения автоматических редиректов
class RedirectHandler: NSObject, URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        print("🔄 Redirect blocked: \(response.statusCode) -> \(request.url?.absoluteString ?? "unknown")")
        completionHandler(nil)
    }
}

