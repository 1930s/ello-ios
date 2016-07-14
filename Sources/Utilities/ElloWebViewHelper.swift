////
///  ElloWebViewHelper.swift
//

public struct ElloWebViewHelper {
    static let jsCommandProtocol = "ello://"

    public static func handleRequest(request: NSURLRequest, webLinkDelegate: WebLinkDelegate?, fromWebView: Bool = false) -> Bool {
        let requestURL = request.URLString
        if requestURL.hasPrefix(jsCommandProtocol) {
            return false
        }
        else if requestURL.rangeOfString("(https?:\\/\\/|mailto:)", options: .RegularExpressionSearch) != nil {
            let (type, data) = ElloURI.match(requestURL)
            if type == .Email {
                if let url = NSURL(string: requestURL) {
                    UIApplication.sharedApplication().openURL(url)
                }
                return false
            }
            else {
                if fromWebView && type.loadsInWebViewFromWebView { return true }
                webLinkDelegate?.webLinkTapped(type, data: data)
                return false
            }
        }
        return true
    }
}
