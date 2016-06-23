//
//  StreamHeaderCell.swift
//  Ello
//
//  Created by Sean Dougherty on 11/22/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

public class StreamHeaderCell: UICollectionViewCell {
    static let reuseIdentifier = "StreamHeaderCell"

    public var indexPath = NSIndexPath(forItem: 0, inSection: 0)
    public var ownPost = false {
        didSet {
            self.updateItems()
        }
    }

    public var ownComment = false {
        didSet {
            self.updateItems()
        }
    }

    public var followButtonVisible = false {
        didSet {
            setNeedsLayout()
        }
    }

    var revealWidth: CGFloat {
        if let items = bottomToolBar.items where items.count == 4 {
            return 106.0
        }
        else {
            return 54.0
        }
    }
    public var canReply = false {
        didSet {
            self.setNeedsLayout()
        }
    }

    var cellOpenObserver: NotificationObserver?
    var isOpen = false

    @IBOutlet var avatarButton: AvatarButton!
    @IBOutlet var goToPostView: UIView!
    @IBOutlet var bottomToolBar: UIToolbar!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var innerContentView: UIView!
    @IBOutlet var bottomContentView: UIView!
    @IBOutlet var categoryButton: UIButton!
    @IBOutlet var timestampLabel: UILabel!
    @IBOutlet var chevronButton: StreamFooterButton!
    @IBOutlet var usernameButton: UIButton!
    @IBOutlet var relationshipControl: RelationshipControl!
    @IBOutlet var replyButton: UIButton!

    @IBOutlet var repostedByButton: UIButton!
    @IBOutlet var repostIconView: UIImageView!

    var isGridLayout = false
    var showUsername = true {
        didSet {
            setNeedsLayout()
        }
    }

    public weak var relationshipDelegate: RelationshipDelegate? {
        get { return relationshipControl.relationshipDelegate }
        set { relationshipControl.relationshipDelegate = newValue }
    }
    public weak var postbarDelegate: PostbarDelegate?
    public weak var userDelegate: UserDelegate?
    public weak var categoryDelegate: CategoryDelegate?
    public weak var streamEditingDelegate: StreamEditingDelegate?

    var avatarHeight: CGFloat = 60.0 {
        didSet { setNeedsDisplay() }
    }

    var timeStamp: String {
        get { return self.timestampLabel.text ?? "" }
        set {
            if isGridLayout {
                timestampLabel.text = ""
            }
            else {
                timestampLabel.text = newValue
            }
            timestampLabel.sizeToFit()
            setNeedsLayout()
        }
    }

    var chevronHidden = false

    var streamKind: StreamKind?

    let flagItem = ElloPostToolBarOption.Flag.barButtonItem()
    public var flagControl: ImageLabelControl {
        return self.flagItem.customView as! ImageLabelControl
    }

    let editItem = ElloPostToolBarOption.Edit.barButtonItem()
    public var editControl: ImageLabelControl {
       return self.editItem.customView as! ImageLabelControl
    }

    let deleteItem = ElloPostToolBarOption.Delete.barButtonItem()
    public var deleteControl: ImageLabelControl {
        return self.deleteItem.customView as! ImageLabelControl
    }

    func setUser(user: User?) {
        avatarButton.setUser(user)
        let username = user?.atName ?? ""
        usernameButton.setTitle(username, forState: UIControlState.Normal)
        usernameButton.sizeToFit()

        relationshipControl.relationshipPriority = user?.relationshipPriority ?? .Inactive
        relationshipControl.userId = user?.id ?? ""
        relationshipControl.userAtName = user?.atName ?? ""
    }

    func setRepostedBy(user: User?) {
        if let atName = user?.atName
        where !isGridLayout {
            repostedByButton.hidden = false
            repostIconView.hidden = false
            repostedByButton.setTitle("by \(atName)", forState: .Normal)
            repostedByButton.sizeToFit()
        }
        else {
            repostedByButton.hidden = true
            repostIconView.hidden = true
        }
        setNeedsLayout()
    }

    func setCategory(category: Category?) {
        let reposted = !repostedByButton.hidden
        guard let category = category
        where !isGridLayout && !reposted else {
            categoryButton.hidden = true
            return
        }

        let attributedString = NSAttributedString(string: "in ", attributes: [
            NSFontAttributeName: UIFont.defaultFont(),
            NSForegroundColorAttributeName: UIColor.greyA(),
            ])
        let categoryName = NSAttributedString(string: category.name, attributes: [
            NSFontAttributeName: UIFont.defaultFont(),
            NSForegroundColorAttributeName: UIColor.greyA(),
            NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue,
            ])
        categoryButton.setAttributedTitle(attributedString + categoryName, forState: UIControlState.Normal)
    }

    override public func awakeFromNib() {
        super.awakeFromNib()

        bottomToolBar.translucent = false
        bottomToolBar.barTintColor = UIColor.whiteColor()
        bottomToolBar.clipsToBounds = true
        bottomToolBar.layer.borderColor = UIColor.whiteColor().CGColor

        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.scrollsToTop = false
        addObservers()
        addButtonHandlers()

        styleUsernameButton()
        styleTimestampLabel()

        let goToPostTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(postTapped(_:)))
        goToPostView.addGestureRecognizer(goToPostTapRecognizer)

        let longPressGesture = UILongPressGestureRecognizer()
        longPressGesture.addTarget(self, action: #selector(longPressed(_:)))
        contentView.addGestureRecognizer(longPressGesture)

        replyButton.setTitle("", forState: .Normal)
        replyButton.setImages(.Reply)

        repostIconView.image = InterfaceImage.Repost.selectedImage
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = bounds
        innerContentView.frame = bounds
        bottomContentView.frame = bounds
        scrollView.frame = bounds
        bottomToolBar.frame = bounds
        goToPostView.frame = bounds
        chevronButton.setImages(.AngleBracket)
        scrollView.contentSize = CGSize(width: contentView.frame.size.width + revealWidth, height: scrollView.frame.size.height)
        positionTopContent()
        repositionBottomContent()
    }

// MARK: - Public

    public func close() {
        isOpen = false
        closeChevron()
        scrollView.contentOffset = CGPointZero
    }

// MARK: - Private

    private func updateItems() {
        if ownComment {
            bottomToolBar.items = [
                flexibleItem(), editItem, deleteItem, fixedItem(-10)
            ]
        }
        else if ownPost {
            bottomToolBar.items = [
                flexibleItem(), flagItem, deleteItem, fixedItem(-10)
            ]
        }
        else {
            bottomToolBar.items = [
                flexibleItem(), flagItem, fixedItem(-10)
            ]
        }
    }

    private func positionTopContent() {
        let leftSidePadding: CGFloat = 15
        let rightSidePadding: CGFloat = 15
        let avatarPadding: CGFloat = 15

        let timestampMargin: CGFloat = 11.5
        let buttonWidth: CGFloat = 30
        let buttonMargin: CGFloat = 5
        let minimumUsernameWidth: CGFloat = 44
        let minimumRepostedWidth: CGFloat = 44

        avatarButton.frame = CGRect(
            x: leftSidePadding,
            y: contentView.frame.midY - avatarHeight/2,
            width: avatarHeight,
            height: avatarHeight
            )
        let usernameX = avatarButton.frame.maxX + avatarPadding

        if chevronHidden {
            chevronButton.frame = CGRect(
                x: contentView.frame.width - rightSidePadding,
                y: 0,
                width: 0,
                height: frame.height
                )
        }
        else {
            chevronButton.frame = CGRect(
                x: contentView.frame.width - buttonWidth - buttonMargin,
                y: 0,
                width: buttonWidth,
                height: frame.height
                )
        }

        timestampLabel.sizeToFit()
        var timestampX = chevronButton.frame.x - timestampLabel.frame.width

        relationshipControl.hidden = !followButtonVisible
        usernameButton.hidden = followButtonVisible
        if followButtonVisible {
            let relationshipControlSize = relationshipControl.intrinsicContentSize()
            relationshipControl.frame.size = relationshipControlSize
            relationshipControl.frame.origin.y = (contentView.frame.height - relationshipControlSize.height) / 2

            if showUsername {
                let relationshipControlPadding: CGFloat = 7
                relationshipControl.frame.origin.x = contentView.frame.width - relationshipControlPadding - relationshipControlSize.width
            }
            else {
                let relationshipControlPadding: CGFloat = 15
                relationshipControl.frame.origin.x = avatarButton.frame.maxX + relationshipControlPadding
            }
        }

        replyButton.frame.size.width = buttonWidth
        replyButton.frame.size.height = contentView.frame.size.height
        replyButton.frame.origin.x = timestampX - buttonWidth - buttonMargin - buttonMargin - rightSidePadding
        replyButton.hidden = isGridLayout || !canReply

        var maxUsernameWidth: CGFloat = 0
        if !isGridLayout {
            maxUsernameWidth = timestampX - usernameX - rightSidePadding

            if canReply {
                maxUsernameWidth -= replyButton.frame.width - timestampMargin
                timestampX -= timestampMargin
            }
        }
        else {
            maxUsernameWidth = contentView.frame.width - usernameX - rightSidePadding
        }
        let maxRepostedWidth = maxUsernameWidth - 26

        timestampLabel.frame = CGRect(
            x: timestampX,
            y: 0,
            width: timestampLabel.frame.width,
            height: contentView.frame.height
            )

        let usernameWidth = max(minimumUsernameWidth, min(usernameButton.frame.width, maxUsernameWidth))
        let repostedWidth = max(minimumRepostedWidth, min(repostedByButton.frame.width, maxRepostedWidth))

        let hasRepostAuthor = !isGridLayout && !repostedByButton.hidden
        let hasCategory = !isGridLayout && !categoryButton.hidden
        let usernameButtonHeight: CGFloat
        let usernameButtonY: CGFloat

        if hasRepostAuthor || hasCategory {
            usernameButtonHeight = 27
            usernameButtonY = contentView.frame.height / 2 - usernameButtonHeight
        }
        else {
            usernameButtonHeight = contentView.frame.height
            usernameButtonY = 0
        }

        let secondaryLabelY: CGFloat
        if hasRepostAuthor || hasCategory {
            if followButtonVisible {
                let relationshipControlCorrection: CGFloat = 2
                let repostLabelCorrection: CGFloat = 2
                relationshipControl.frame.origin.y -= usernameButtonHeight / 2 - relationshipControlCorrection
                secondaryLabelY = relationshipControl.frame.maxY + repostLabelCorrection
            }
            else {
                secondaryLabelY = contentView.frame.height / 2
            }
        }
        else {
            secondaryLabelY = 0
        }

        usernameButton.frame = CGRect(
            x: usernameX,
            y: usernameButtonY,
            width: usernameWidth,
            height: usernameButtonHeight
        )
        repostedByButton.frame.size = CGSize(
            width: repostedWidth,
            height: usernameButtonHeight
        )
        let repostIconY = secondaryLabelY + (repostedByButton.frame.size.height - repostIconView.frame.height) / 2
        repostIconView.frame.origin = CGPoint(
            x: usernameX,
            y: repostIconY
        )
        repostedByButton.frame.origin = CGPoint(
            x: repostIconView.frame.maxX + 6,
            y: secondaryLabelY
        )
        let delta = repostedByButton.frame.origin.x - usernameX
        categoryButton.frame = repostedByButton.frame.growLeft(delta)
    }

    private func fixedItem(width: CGFloat) -> UIBarButtonItem {
        let item = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil)
        item.width = width
        return item
    }

    private func flexibleItem() -> UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
    }

    private func addObservers() {
        cellOpenObserver = NotificationObserver(notification: streamCellDidOpenNotification) { cell in
            if cell != self && self.isOpen {
                nextTick {
                    animate(duration: 0.25) {
                        self.close()
                    }
                }
            }
        }
    }

    private func addButtonHandlers() {
        flagControl.addTarget(self, action: #selector(StreamHeaderCell.flagButtonTapped(_:)), forControlEvents: .TouchUpInside)
        replyButton.addTarget(self, action: #selector(StreamHeaderCell.replyButtonTapped(_:)), forControlEvents: .TouchUpInside)
        deleteControl.addTarget(self, action: #selector(StreamHeaderCell.deleteButtonTapped(_:)), forControlEvents: .TouchUpInside)
        editControl.addTarget(self, action: #selector(StreamHeaderCell.editButtonTapped(_:)), forControlEvents: .TouchUpInside)
    }

    private func styleUsernameButton() {
        usernameButton.titleLabel?.font = UIFont.defaultFont()
        usernameButton.setTitleColor(UIColor.greyA(), forState: UIControlState.Normal)
        usernameButton.titleLabel?.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        usernameButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
    }

    private func styleTimestampLabel() {
        timestampLabel.textColor = UIColor.greyA()
        timestampLabel.font = UIFont.defaultFont()
    }

    private func repositionBottomContent() {
        var frame = bottomContentView.frame
        frame.size.height = innerContentView.bounds.height
        frame.size.width = innerContentView.bounds.width
        frame.origin.y = innerContentView.frame.origin.y
        frame.origin.x = scrollView.contentOffset.x
        bottomContentView.frame = frame
    }

// MARK: - IBActions

    func postTapped(recognizer: UITapGestureRecognizer) {
        postbarDelegate?.viewsButtonTapped(self.indexPath)
    }

    @IBAction func userTapped(sender: AvatarButton) {
        userDelegate?.userTappedAuthor(self)
    }

    @IBAction func usernameTapped(sender: UIButton) {
        userDelegate?.userTappedAuthor(self)
    }

    @IBAction func categoryTapped(sender: UIButton) {
        categoryDelegate?.categoryCellTapped(self)
    }

    @IBAction func reposterTapped(sender: UIButton) {
        userDelegate?.userTappedReposter(self)
    }

    @IBAction func flagButtonTapped(sender: StreamFooterButton) {
        postbarDelegate?.flagCommentButtonTapped(self.indexPath)
    }

    @IBAction func replyButtonTapped(sender: StreamFooterButton) {
        postbarDelegate?.replyToCommentButtonTapped(self.indexPath)
    }

    @IBAction func deleteButtonTapped(sender: StreamFooterButton) {
        postbarDelegate?.deleteCommentButtonTapped(self.indexPath)
    }

    @IBAction func editButtonTapped(sender: StreamFooterButton) {
        postbarDelegate?.editCommentButtonTapped(self.indexPath)
    }

    @IBAction func chevronButtonTapped(sender: StreamFooterButton) {
        let contentOffset = isOpen ? CGPointZero : CGPoint(x: revealWidth, y: 0)
        UIView.animateWithDuration(0.25) {
            self.scrollView.contentOffset = contentOffset
            self.openChevron(isOpen: self.isOpen)
        }
        Tracker.sharedTracker.commentBarVisibilityChanged(isOpen)
    }

    @IBAction func longPressed(gesture: UIGestureRecognizer) {
        if gesture.state == .Began {
            streamEditingDelegate?.cellLongPressed(self)
        }
    }
}

extension StreamHeaderCell {

    private func openChevron(isOpen isOpen: Bool) {
        if isOpen {
            rotateChevron(CGFloat(0))
        }
        else {
            rotateChevron(CGFloat(M_PI))
        }
    }

    private func closeChevron() {
        openChevron(isOpen: false)
    }

    private func rotateChevron(angle: CGFloat) {
        var normalized = angle
        if angle < CGFloat(-M_PI) {
            normalized = CGFloat(-M_PI)
        }
        else if angle > CGFloat(M_PI) {
            normalized = CGFloat(M_PI)
        }
        self.chevronButton.transform = CGAffineTransformMakeRotation(normalized)
    }

}

extension StreamHeaderCell: ElloTextViewDelegate {
    func textViewTapped(link: String, object: ElloAttributedObject) {
        userDelegate?.userTappedAuthor(self)
    }
    func textViewTappedDefault() {}
}

// MARK: UIScrollViewDelegate
extension StreamHeaderCell: UIScrollViewDelegate {

    public func scrollViewDidScroll(scrollView: UIScrollView) {
        repositionBottomContent()

        if scrollView.contentOffset.x < 0 {
            scrollView.contentOffset = CGPointZero
        }

        if scrollView.contentOffset.x >= revealWidth {
            if !isOpen {
                isOpen = true
                openChevron(isOpen: true)
                postNotification(streamCellDidOpenNotification, value: self)
                Tracker.sharedTracker.commentBarVisibilityChanged(true)
            }
        } else {
            let angle: CGFloat = -CGFloat(M_PI) + CGFloat(M_PI) * scrollView.contentOffset.x / revealWidth
            rotateChevron(angle)
            isOpen = false
        }
    }

    public func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if velocity.x > 0 {
            targetContentOffset.memory.x = revealWidth
        }
        else {
            targetContentOffset.memory.x = 0
        }
    }

}
