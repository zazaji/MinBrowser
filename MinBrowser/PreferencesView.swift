import SwiftUI
import WebKit

struct WebViewWrapper: NSViewRepresentable {
    var webView: WKWebView

    func makeNSView(context: Context) -> WKWebView {
        return webView
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {
    }
}

struct Website: Codable {
    let name: String
    let url: String
    let order: Int
}

struct WebsiteList: Codable {
    let data: [Website]
    let customUserAgent: String

}

func loadWebsiteList() -> (websites: [Website], customUserAgent: String) {
    let fileManager = FileManager.default
    let homeDirectory = fileManager.homeDirectoryForCurrentUser
    let jsonFilePath = homeDirectory.appendingPathComponent(".miniViewer.json")

    do {
        let data = try Data(contentsOf: jsonFilePath)
        let websiteList = try JSONDecoder().decode(WebsiteList.self, from: data)
        return (websiteList.data.sorted(by: { $0.order < $1.order }),websiteList.customUserAgent)
    } catch {
        print("Error reading or parsing JSON: \(error)")
        return ([], "")
    }
}

struct PreferencesView: View {
    @ObservedObject var webViewManager: WebViewManager
    private var websites: [Website]
    @Binding var isPresented: Bool

    init(webViewManager: WebViewManager, isPresented: Binding<Bool>) {
        _webViewManager = ObservedObject(wrappedValue: webViewManager)
        _isPresented = isPresented
        let websiteList = loadWebsiteList()
        websites = websiteList.websites
    }

    var body: some View {
        VStack {
            TabView {
                ForEach(websites, id: \.order) { website in
                    if let url = URL(string: website.url),
                       let webView = webViewManager.webViews[url] {
                        WebViewWrapper(webView: webView)
                            .tabItem {
                                Text(website.name)
                            }
                            .frame(minWidth: 300, maxWidth: 800, minHeight: 300, maxHeight: .infinity)
                    }
                }
            }
        }
    }
}



