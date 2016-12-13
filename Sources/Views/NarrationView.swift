////
///  NarrationView.swift
//

public class NarrationView: UIView {
    struct Size {
        static let margins = CGFloat(15)
        static let height = CGFloat(112)
        static let pointer = CGSize(width: 12, height: 6)
    }
    private let closeButton: StyledButton = {
        let closeButton = StyledButton()
        closeButton.setTitle("\u{2573}", forState: .Normal)
        closeButton.sizeToFit()
        closeButton.userInteractionEnabled = false
        return closeButton
    }()
    private let bg: UIView = {
        let bg = UIView()
        bg.backgroundColor = .blackColor()
        return bg
    }()
    private let label: ElloTextView = {
        let label = ElloTextView()
        label.userInteractionEnabled = false
        label.editable = false
        label.allowsEditingTextAttributes = false
        label.selectable = false
        label.textColor = .whiteColor()
        label.textContainer.lineFragmentPadding = 0
        label.backgroundColor = .clearColor()
        return label
    }()
    private let pointer: UIImageView = {
        let pointer = UIImageView()
        pointer.contentMode = .ScaleAspectFit
        pointer.image = InterfaceImage.NarrationPointer.normalImage
        return pointer
    }()

    public var pointerX: CGFloat {
        get { return pointer.frame.midX }
        set { pointer.frame.origin.x = newValue - pointer.frame.size.width / 2 }
    }

    public var title: String = "" {
        didSet {
            updateTitleAndText()
        }
    }
    public var text: String = "" {
        didSet {
            updateTitleAndText()
        }
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(bg)
        addSubview(pointer)
        addSubview(label)
        addSubview(closeButton)
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func updateTitleAndText() {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 6

        let titleAttributes = [
            NSFontAttributeName : UIFont.defaultBoldFont(),
            NSForegroundColorAttributeName : UIColor.whiteColor(),
            NSParagraphStyleAttributeName : style
        ]
        let textAttributes = [
            NSFontAttributeName : UIFont.defaultFont(),
            NSForegroundColorAttributeName : UIColor.whiteColor(),
            NSParagraphStyleAttributeName : style
        ]

        label.attributedText = NSMutableAttributedString(string: title + "\n", attributes: titleAttributes) + NSMutableAttributedString(string: text, attributes: textAttributes)
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        pointer.frame.size = Size.pointer
        pointer.frame.origin.y = bounds.height - pointer.frame.height

        closeButton.frame.origin = CGPoint(
            x: bounds.width - Size.margins - closeButton.frame.width,
            y: Size.margins
            )

        bg.frame = CGRect(
            x: 0,
            y: 0,
            width: bounds.width,
            height: bounds.height - pointer.frame.height
            )
        label.frame = bg.frame.inset(top: Size.margins, left: Size.margins, bottom: 0, right: 2 * Size.margins + closeButton.frame.width)
    }

}
