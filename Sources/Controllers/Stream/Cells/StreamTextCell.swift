////
///  StreamTextCell.swift
//

import WebKit
import Foundation

public class StreamTextCell: StreamRegionableCell, UIWebViewDelegate, UIGestureRecognizerDelegate {
    static let reuseIdentifier = "StreamTextCell"

    typealias WebContentReady = (webView: UIWebView) -> Void

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    weak var webLinkDelegate: WebLinkDelegate?
    var userDelegate: UserDelegate?
    var streamEditingDelegate: StreamEditingDelegate?
    var webContentReady: WebContentReady?

    override public func awakeFromNib() {
        super.awakeFromNib()
        webView.scrollView.scrollEnabled = false
        webView.scrollView.scrollsToTop = false

        let doubleTapGesture = UITapGestureRecognizer()
        doubleTapGesture.delegate = self
        doubleTapGesture.numberOfTapsRequired = 2
        doubleTapGesture.addTarget(self, action: #selector(doubleTapped(_:)))
        webView.addGestureRecognizer(doubleTapGesture)

        let longPressGesture = UILongPressGestureRecognizer()
        longPressGesture.addTarget(self, action: #selector(longPressed(_:)))
        webView.addGestureRecognizer(longPressGesture)
    }

    public func gestureRecognizer(_: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer _: UIGestureRecognizer) -> Bool {
        return true
    }

    @IBAction func doubleTapped(gesture: UIGestureRecognizer) {
        let location = gesture.locationInView(nil)
        streamEditingDelegate?.cellDoubleTapped(self, location: location)
    }

    @IBAction func longPressed(gesture: UIGestureRecognizer) {
        if gesture.state == .Began {
            streamEditingDelegate?.cellLongPressed(self)
        }
    }

    func onWebContentReady(handler: WebContentReady?) {
        webContentReady = handler
    }

    override public func prepareForReuse() {
        super.prepareForReuse()
        hideBorder()
        webView.stopLoading()
        webView.loadHTMLString("", baseURL: nil)
    }

    public func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if let scheme = request.URL?.scheme
            where scheme == "default"
        {
            userDelegate?.userTappedText(self)
            return false
        }
        else {
            return ElloWebViewHelper.handleRequest(request, webLinkDelegate: webLinkDelegate)
        }
    }

    public func webViewDidFinishLoad(webView: UIWebView) {
        webContentReady?(webView: webView)
    }
}
