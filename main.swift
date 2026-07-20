import Cocoa
import WebKit

let APP_URL = "https://m.openmindclub.com/"
let APP_NAME = "开智元学"

class WebViewController: NSViewController, WKNavigationDelegate, WKUIDelegate {
    var webView: WKWebView!
    var progressBar: NSProgressIndicator!

    override func loadView() {
        let config = WKWebViewConfiguration()
        // 使用默认的持久化数据存储，保留 cookie / 登录状态
        config.websiteDataStore = WKWebsiteDataStore.default()
        config.preferences.setValue(true, forKey: "developerExtrasEnabled")

        webView = WKWebView(frame: NSRect(x: 0, y: 0, width: 480, height: 820), configuration: config)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.autoresizingMask = [.width, .height]

        let container = NSView(frame: NSRect(x: 0, y: 0, width: 480, height: 820))
        container.addSubview(webView)

        progressBar = NSProgressIndicator(frame: NSRect(x: 0, y: 816, width: 480, height: 4))
        progressBar.style = .bar
        progressBar.isIndeterminate = false
        progressBar.minValue = 0
        progressBar.maxValue = 1
        progressBar.autoresizingMask = [.width, .minYMargin]
        progressBar.isHidden = true
        container.addSubview(progressBar)

        self.view = container
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        if let url = URL(string: APP_URL) {
            webView.load(URLRequest(url: url))
        }
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            let p = webView.estimatedProgress
            progressBar.isHidden = p >= 1.0
            progressBar.doubleValue = p
        }
    }

    // 处理 target=_blank / window.open，在同一窗口内打开
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration,
                 for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let url = navigationAction.request.url {
            webView.load(URLRequest(url: url))
        }
        return nil
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        progressBar.isHidden = true
    }

    // 导航动作
    @objc func reload(_ sender: Any?) { webView.reload() }
    @objc func goBack(_ sender: Any?) { if webView.canGoBack { webView.goBack() } }
    @objc func goForward(_ sender: Any?) { if webView.canGoForward { webView.goForward() } }
    @objc func goHome(_ sender: Any?) {
        if let url = URL(string: APP_URL) { webView.load(URLRequest(url: url)) }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    var vc: WebViewController!

    func applicationDidFinishLaunching(_ notification: Notification) {
        vc = WebViewController()

        let screen = NSScreen.main?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1440, height: 900)
        let w: CGFloat = 480
        let h: CGFloat = 820
        let rect = NSRect(x: screen.midX - w/2, y: screen.midY - h/2, width: w, height: h)

        window = NSWindow(contentRect: rect,
                          styleMask: [.titled, .closable, .miniaturizable, .resizable],
                          backing: .buffered, defer: false)
        window.title = APP_NAME
        window.contentViewController = vc
        window.setFrameAutosaveName("MainWindow")
        window.minSize = NSSize(width: 360, height: 480)
        window.makeKeyAndOrderFront(nil)

        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)

        setupMenu()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    // 点击 Dock 图标时若无窗口则重开
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag { window.makeKeyAndOrderFront(nil) }
        return true
    }

    func setupMenu() {
        let mainMenu = NSMenu()

        // App 菜单
        let appMenuItem = NSMenuItem()
        mainMenu.addItem(appMenuItem)
        let appMenu = NSMenu()
        appMenu.addItem(withTitle: "关于 \(APP_NAME)", action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)), keyEquivalent: "")
        appMenu.addItem(NSMenuItem.separator())
        appMenu.addItem(withTitle: "隐藏 \(APP_NAME)", action: #selector(NSApplication.hide(_:)), keyEquivalent: "h")
        appMenu.addItem(withTitle: "退出 \(APP_NAME)", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        appMenuItem.submenu = appMenu

        // 编辑菜单（复制/粘贴/全选）
        let editMenuItem = NSMenuItem()
        mainMenu.addItem(editMenuItem)
        let editMenu = NSMenu(title: "编辑")
        editMenu.addItem(withTitle: "撤销", action: Selector(("undo:")), keyEquivalent: "z")
        editMenu.addItem(withTitle: "重做", action: Selector(("redo:")), keyEquivalent: "Z")
        editMenu.addItem(NSMenuItem.separator())
        editMenu.addItem(withTitle: "剪切", action: #selector(NSText.cut(_:)), keyEquivalent: "x")
        editMenu.addItem(withTitle: "复制", action: #selector(NSText.copy(_:)), keyEquivalent: "c")
        editMenu.addItem(withTitle: "粘贴", action: #selector(NSText.paste(_:)), keyEquivalent: "v")
        editMenu.addItem(withTitle: "全选", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a")
        editMenuItem.submenu = editMenu

        // 浏览菜单
        let navMenuItem = NSMenuItem()
        mainMenu.addItem(navMenuItem)
        let navMenu = NSMenu(title: "浏览")
        navMenu.addItem(withTitle: "刷新", action: #selector(WebViewController.reload(_:)), keyEquivalent: "r")
        navMenu.addItem(withTitle: "后退", action: #selector(WebViewController.goBack(_:)), keyEquivalent: "[")
        navMenu.addItem(withTitle: "前进", action: #selector(WebViewController.goForward(_:)), keyEquivalent: "]")
        navMenu.addItem(NSMenuItem.separator())
        navMenu.addItem(withTitle: "回到首页", action: #selector(WebViewController.goHome(_:)), keyEquivalent: "H")
        navMenuItem.submenu = navMenu

        // 窗口菜单
        let windowMenuItem = NSMenuItem()
        mainMenu.addItem(windowMenuItem)
        let windowMenu = NSMenu(title: "窗口")
        windowMenu.addItem(withTitle: "最小化", action: #selector(NSWindow.performMiniaturize(_:)), keyEquivalent: "m")
        windowMenu.addItem(withTitle: "缩放", action: #selector(NSWindow.performZoom(_:)), keyEquivalent: "")
        windowMenuItem.submenu = windowMenu
        NSApp.windowsMenu = windowMenu

        NSApp.mainMenu = mainMenu
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
