////
///  NotificationCell.swift
//

import FLAnimatedImage
import TimeAgoInWords

@objc
public protocol NotificationDelegate {
    func userTapped(user: User)
    func commentTapped(comment: ElloComment)
    func postTapped(post: Post)
}

public class NotificationCell: UICollectionViewCell, UIWebViewDelegate {
    static let reuseIdentifier = "NotificationCell"

    struct Size {
        static let BuyButtonSize: CGFloat = 15
        static let BuyButtonMargin: CGFloat = 5
        static let ButtonHeight: CGFloat = 30
        static let ButtonMargin: CGFloat = 15
        static let WebHeightCorrection: CGFloat = -10
        static let SideMargins: CGFloat = 15
        static let AvatarSize: CGFloat = 30
        static let ImageWidth: CGFloat = 87
        static let InnerMargin: CGFloat = 10
        static let MessageMargin: CGFloat = 0
        static let CreatedAtHeight: CGFloat = 12
        // height of created at and margin from title / notification text
        static let CreatedAtFixedHeight = CreatedAtHeight + InnerMargin

        static func messageHtmlWidth(forCellWidth cellWidth: CGFloat, hasImage: Bool) -> CGFloat {
            let messageLeftMargin: CGFloat = SideMargins + AvatarSize + InnerMargin
            var messageRightMargin: CGFloat = SideMargins
            if hasImage {
                messageRightMargin += InnerMargin + ImageWidth
            }
            return cellWidth - messageLeftMargin - messageRightMargin
        }

        static func imageHeight(imageRegion imageRegion: ImageRegion?) -> CGFloat {
            if let imageRegion = imageRegion {
                let aspectRatio = StreamImageCellSizeCalculator.aspectRatioForImageRegion(imageRegion)
                return ceil(ImageWidth / aspectRatio)
            }
            else {
                return 0
            }
        }
    }

    typealias WebContentReady = (webView: UIWebView) -> Void

    weak var webLinkDelegate: WebLinkDelegate?
    weak var userDelegate: UserDelegate?
    weak var delegate: NotificationDelegate?
    var webContentReady: WebContentReady?
    var onHeightMismatch: OnHeightMismatch?

    var avatarButton: AvatarButton!
    var buyButtonImage: UIImageView!
    var replyButton: ReplyButton!
    var relationshipControl: RelationshipControl!
    var titleTextView: ElloTextView!
    var createdAtLabel: UILabel!
    var messageWebView: UIWebView!
    var notificationImageView: FLAnimatedImageView!
    var aspectRatio: CGFloat = 4/3
    var separator = UIView()

    var canReplyToComment: Bool {
        set {
            replyButton.hidden = !newValue
            setNeedsLayout()
        }
        get { return !replyButton.hidden }
    }
    var canBackFollow: Bool {
        set {
            relationshipControl.hidden = !newValue
            setNeedsLayout()
        }
        get { return !relationshipControl.hidden }
    }
    var buyButtonVisible: Bool {
        get { return !buyButtonImage.hidden }
        set { buyButtonImage.hidden = !newValue }
    }

    private var messageVisible = false
    private var _messageHtml = ""
    var messageHeight: CGFloat = 0
    var messageHtml: String? {
        get { return _messageHtml }
        set {
            if let value = newValue {
                messageVisible = true
                if value != _messageHtml {
                    messageWebView.hidden = true
                }
                else {
                    messageWebView.hidden = false
                }
                messageWebView.loadHTMLString(StreamTextCellHTML.postHTML(value), baseURL: NSURL(string: "/"))
                _messageHtml = value
            }
            else {
                messageWebView.hidden = true
                messageVisible = false
            }
        }
    }

    var imageURL: NSURL? {
        didSet {
            self.notificationImageView.pin_setImageFromURL(imageURL) { result in
                let success = result.image != nil || result.animatedImage != nil
                let isAnimated = result.animatedImage != nil
                if success {
                    let imageSize = isAnimated ? result.animatedImage.size : result.image.size
                    self.aspectRatio = imageSize.width / imageSize.height
                    let currentRatio = self.notificationImageView.frame.width / self.notificationImageView.frame.height
                    if currentRatio != self.aspectRatio {
                        self.setNeedsLayout()
                    }
                }
            }
            self.setNeedsLayout()
        }
    }

    var title: NSAttributedString? {
        didSet {
            titleTextView.attributedText = title
        }
    }

    var createdAt: NSDate? {
        didSet {
            if let date = createdAt {
                createdAtLabel.text = date.timeAgoInWords()
            }
            else {
                createdAtLabel.text = ""
            }
        }
    }

    var user: User? {
        didSet {
            setUser(user)
        }
    }
    var post: Post?
    var comment: ElloComment?

    override init(frame: CGRect) {
        super.init(frame: frame)

        avatarButton = AvatarButton()
        avatarButton.addTarget(self, action: #selector(avatarTapped), forControlEvents: .TouchUpInside)
        titleTextView = ElloTextView(frame: .zero, textContainer: nil)
        titleTextView.textViewDelegate = self

        buyButtonImage = UIImageView()
        buyButtonImage.hidden = true
        buyButtonImage.image = InterfaceImage.BuyButton.normalImage
        buyButtonImage.frame.size = CGSize(width: Size.BuyButtonSize, height: Size.BuyButtonSize)
        buyButtonImage.backgroundColor = .greenD1()
        buyButtonImage.layer.cornerRadius = Size.BuyButtonSize / 2

        replyButton = ReplyButton()
        replyButton.hidden = true
        replyButton.addTarget(self, action: #selector(replyTapped), forControlEvents: .TouchUpInside)

        relationshipControl = RelationshipControl()
        relationshipControl.hidden = true
        relationshipControl.showStarButton = false

        notificationImageView = FLAnimatedImageView()
        notificationImageView.contentMode = .ScaleAspectFit
        messageWebView = UIWebView()
        messageWebView.opaque = false
        messageWebView.backgroundColor = .clearColor()
        messageWebView.scrollView.scrollEnabled = false
        messageWebView.delegate = self

        createdAtLabel = UILabel()
        createdAtLabel.textColor = UIColor.greyA()
        createdAtLabel.font = UIFont.defaultFont(12)
        createdAtLabel.text = ""

        separator.backgroundColor = .greyE5()

        for view in [avatarButton, titleTextView, messageWebView,
                     notificationImageView, buyButtonImage, createdAtLabel,
                     replyButton, relationshipControl, separator] {
            self.contentView.addSubview(view)
        }
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func onWebContentReady(handler: WebContentReady?) {
        webContentReady = handler
    }

    private func setUser(user: User?) {
        avatarButton.setUser(user)

        if let user = user {
            relationshipControl.userId = user.id
            relationshipControl.userAtName = user.atName
            relationshipControl.relationshipPriority = user.relationshipPriority
        }
        else {
            relationshipControl.userId = ""
            relationshipControl.userAtName = ""
            relationshipControl.relationshipPriority = RelationshipPriority.None
        }
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        let outerFrame = contentView.bounds.inset(all: Size.SideMargins)
        let titleWidth = Size.messageHtmlWidth(forCellWidth: self.frame.width, hasImage: imageURL != nil)
        separator.frame = contentView.bounds.fromBottom().growUp(1)

        avatarButton.frame = outerFrame.withSize(CGSize(width: Size.AvatarSize, height: Size.AvatarSize))

        if imageURL == nil {
            notificationImageView.frame = .zero
        }
        else {
            notificationImageView.frame = outerFrame.fromRight()
                .growLeft(Size.ImageWidth)
                .withHeight(Size.ImageWidth / aspectRatio)
            buyButtonImage.frame.origin = CGPoint(
                x: notificationImageView.frame.maxX - Size.BuyButtonSize - Size.BuyButtonMargin,
                y: notificationImageView.frame.minY + Size.BuyButtonMargin
                )
        }

        titleTextView.frame = avatarButton.frame.fromRight()
            .shiftRight(Size.InnerMargin)
            .withWidth(titleWidth)

        let tvSize = titleTextView.sizeThatFits(CGSize(width: titleWidth, height: .max))
        titleTextView.frame.size.height = ceil(tvSize.height)

        var createdAtY = titleTextView.frame.maxY + Size.InnerMargin

        if messageVisible {
            createdAtY += messageHeight + Size.MessageMargin
            let remainingHeight = outerFrame.height - Size.InnerMargin - titleTextView.frame.height
            messageWebView.frame = titleTextView.frame.fromBottom()
                .withWidth(titleWidth)
                .shiftDown(Size.InnerMargin)
                .withHeight(remainingHeight)
        }

        createdAtLabel.frame = CGRect(
            x: avatarButton.frame.maxX + Size.InnerMargin,
            y: createdAtY,
            width: titleWidth,
            height: Size.CreatedAtHeight
            )

        let replyButtonWidth = replyButton.intrinsicContentSize().width
        replyButton.frame = CGRect(
            x: createdAtLabel.frame.x,
            y: createdAtY + Size.CreatedAtHeight + Size.InnerMargin,
            width: replyButtonWidth,
            height: Size.ButtonHeight
            )
        let relationshipControlWidth = relationshipControl.intrinsicContentSize().width
        relationshipControl.frame = replyButton.frame.withWidth(relationshipControlWidth)

        let bottomControl: UIView
        if !replyButton.hidden {
            bottomControl = replyButton
        }
        else if !relationshipControl.hidden {
            bottomControl = relationshipControl
        }
        else {
            bottomControl = createdAtLabel
        }

        let actualHeight = ceil(max(notificationImageView.frame.maxY, bottomControl.frame.maxY)) + Size.SideMargins
        // don't update the height if
        // - imageURL is set, but hasn't finished loading, OR
        // - messageHTML is set, but hasn't finished loading
        if actualHeight != frame.size.height && (imageURL == nil || notificationImageView.image != nil) && (!messageVisible || !messageWebView.hidden) {
            self.onHeightMismatch?(actualHeight)
        }
    }

    override public func prepareForReuse() {
        super.prepareForReuse()
        messageWebView.stopLoading()
        messageWebView.hidden = true
        avatarButton.pin_cancelImageDownload()
        avatarButton.setImage(nil, forState: .Normal)
        notificationImageView.pin_cancelImageDownload()
        notificationImageView.image = nil
        aspectRatio = 4/3
        canReplyToComment = false
        canBackFollow = false
        imageURL = nil
        buyButtonImage.hidden = true
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
        if messageVisible {
            messageWebView.hidden = !messageVisible
        }
        webContentReady?(webView: webView)
        if let height = webView.windowContentSize()?.height {
            messageHeight = height
        }
        else {
            messageHeight = 0
        }
        setNeedsLayout()
    }
}

extension NotificationCell: ElloTextViewDelegate {
    func textViewTapped(link: String, object: ElloAttributedObject) {
        switch object {
        case let .AttributedPost(post):
            delegate?.postTapped(post)
        case let .AttributedComment(comment):
            delegate?.commentTapped(comment)
        case let .AttributedUser(user):
            delegate?.userTapped(user)
        default: break
        }
    }

    func textViewTappedDefault() {
        userDelegate?.userTappedText(self)
    }
}

extension NotificationCell {

    public func replyTapped() {
        if let post = post {
            delegate?.postTapped(post)
        }
        else if let comment = comment {
            delegate?.commentTapped(comment)
        }
    }

    public func avatarTapped() {
        userDelegate?.userTappedAuthor(self)
    }

}
