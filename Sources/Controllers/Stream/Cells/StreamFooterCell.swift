////
///  StreamFooterCell.swift
//

let streamCellDidOpenNotification = TypedNotification<UICollectionViewCell>(name: "StreamCellDidOpenNotification")

public class StreamFooterCell: UICollectionViewCell {
    static let reuseIdentifier = "StreamFooterCell"

    @IBOutlet weak public var toolBar: UIToolbar!
    @IBOutlet weak public var containerView: UIView!
    @IBOutlet weak public var innerContentView: UIView!

    public var commentsOpened = false
    public weak var delegate: PostbarDelegate?
    public weak var streamEditingDelegate: StreamEditingDelegate?

    public let viewsItem = ElloPostToolBarOption.Views.barButtonItem()
    public var viewsControl: ImageLabelControl {
        return self.viewsItem.customView as! ImageLabelControl
    }

    public let lovesItem = ElloPostToolBarOption.Loves.barButtonItem()
    public var lovesControl: ImageLabelControl {
        return self.lovesItem.customView as! ImageLabelControl
    }

    public let commentsItem = ElloPostToolBarOption.Comments.barButtonItem()
    public var commentsControl: ImageLabelControl {
        return self.commentsItem.customView as! ImageLabelControl
    }

    public let repostItem = ElloPostToolBarOption.Repost.barButtonItem()
    public var repostControl: ImageLabelControl {
        return self.repostItem.customView as! ImageLabelControl
    }

    public let shareItem = ElloPostToolBarOption.Share.barButtonItem()
    public var shareControl: ImageLabelControl {
        return self.shareItem.customView as! ImageLabelControl
    }

    public let replyItem = ElloPostToolBarOption.Reply.barButtonItem()
    public var replyControl: ImageLabelControl {
        return self.replyItem.customView as! ImageLabelControl
    }

    private func updateButtonVisibility(button: UIControl, visibility: InteractionVisibility) {
        button.hidden = !visibility.isVisible
        button.enabled = visibility.isEnabled
        button.selected = visibility.isSelected
    }

    public func updateToolbarItems(
        streamKind streamKind: StreamKind,
        repostVisibility: InteractionVisibility,
        commentVisibility: InteractionVisibility,
        shareVisibility: InteractionVisibility,
        loveVisibility: InteractionVisibility
        )
    {
        updateButtonVisibility(self.repostControl, visibility: repostVisibility)
        updateButtonVisibility(self.lovesControl, visibility: loveVisibility)
        var toolbarItems: [UIBarButtonItem] = []

        let desiredCount: Int
        if streamKind.isGridView {
            desiredCount = 3

            if commentVisibility.isVisible {
                toolbarItems.append(commentsItem)
            }

            if loveVisibility.isVisible {
                toolbarItems.append(lovesItem)
            }

            if repostVisibility.isVisible {
                toolbarItems.append(repostItem)
            }
        }
        else {
            desiredCount = 5

            toolbarItems.append(viewsItem)

            if commentVisibility.isVisible {
                toolbarItems.append(commentsItem)
            }

            if loveVisibility.isVisible {
                toolbarItems.append(lovesItem)
            }

            if repostVisibility.isVisible {
                toolbarItems.append(repostItem)
            }

            if shareVisibility.isVisible {
                toolbarItems.append(shareItem)
            }
        }

        while toolbarItems.count < desiredCount {
            toolbarItems.append(fixedItem(44))
        }
        self.toolBar.items = Array(toolbarItems.flatMap { [self.flexibleItem(), $0] }.dropFirst())
    }

    override public func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
    }

    override public func awakeFromNib() {
        super.awakeFromNib()
        toolBar.translucent = false
        toolBar.barTintColor = UIColor.whiteColor()
        toolBar.clipsToBounds = true
        toolBar.layer.borderColor = UIColor.whiteColor().CGColor

        let longPressGesture = UILongPressGestureRecognizer()
        longPressGesture.addTarget(self, action: #selector(longPressed(_:)))
        contentView.addGestureRecognizer(longPressGesture)

        addButtonHandlers()
    }

    public var views: String? {
        get { return viewsControl.title }
        set { viewsControl.title = newValue }
    }

    public var comments: String? {
        get { return commentsControl.title }
        set { commentsControl.title = newValue }
    }

    public var loves: String? {
        get { return lovesControl.title }
        set { lovesControl.title = newValue }
    }

    public var reposts: String? {
        get { return repostControl.title }
        set { repostControl.title = newValue }
    }

// MARK: - Private

    private func fixedItem(width: CGFloat) -> UIBarButtonItem {
        let item = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil)
        item.width = width
        return item
    }

    private func flexibleItem() -> UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
    }

    private func addButtonHandlers() {
        commentsControl.addTarget(self, action: #selector(StreamFooterCell.commentsButtonTapped), forControlEvents: .TouchUpInside)
        lovesControl.addTarget(self, action: #selector(StreamFooterCell.lovesButtonTapped), forControlEvents: .TouchUpInside)
        replyControl.addTarget(self, action: #selector(StreamFooterCell.replyButtonTapped), forControlEvents: .TouchUpInside)
        repostControl.addTarget(self, action: #selector(StreamFooterCell.repostButtonTapped), forControlEvents: .TouchUpInside)
        shareControl.addTarget(self, action: #selector(StreamFooterCell.shareButtonTapped), forControlEvents: .TouchUpInside)
        viewsControl.addTarget(self, action: #selector(StreamFooterCell.viewsButtonTapped), forControlEvents: .TouchUpInside)
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        let newBounds = CGRect(x: 0, y: 0, width: bounds.width, height: 44)
        contentView.frame = newBounds
        innerContentView.frame = newBounds
        containerView.frame = newBounds
        toolBar.frame = newBounds
    }

// MARK: - IBActions

    @IBAction func viewsButtonTapped() {
        guard let indexPath = indexPath else { return }
        delegate?.viewsButtonTapped(indexPath)
    }

    @IBAction func commentsButtonTapped() {
        commentsOpened = !commentsOpened
        delegate?.commentsButtonTapped(self, imageLabelControl: commentsControl)
    }

    func cancelCommentLoading() {
        commentsControl.enabled = true
        commentsControl.finishAnimation()
        commentsControl.selected = false
        commentsOpened = false
    }

    @IBAction func lovesButtonTapped() {
        guard let indexPath = indexPath else { return }
        delegate?.lovesButtonTapped(self, indexPath: indexPath)
    }

    @IBAction func repostButtonTapped() {
        guard let indexPath = indexPath else { return }
        delegate?.repostButtonTapped(indexPath)
    }

    @IBAction func shareButtonTapped() {
        guard let indexPath = indexPath else { return }
        delegate?.shareButtonTapped(indexPath, sourceView: shareControl)
    }

    @IBAction func replyButtonTapped() {
    }

    @IBAction func longPressed(gesture: UIGestureRecognizer) {
        if gesture.state == .Began {
            streamEditingDelegate?.cellLongPressed(self)
        }
    }
}
