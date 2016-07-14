////
///  OnboardingHeaderCell.swift
//

public class OnboardingHeaderCell: UICollectionViewCell {
    static let reuseIdentifier = "OnboardingHeaderCell"

    lazy var onboardingHeaderView: OnboardingHeaderView = {
        let view = OnboardingHeaderView()
        view.frame = self.frame
        view.autoresizingMask =  [.FlexibleWidth, .FlexibleHeight]
        return view
    }()
    var headerLabel: UILabel { return onboardingHeaderView.headerLabel }
    var messageLabel: ElloLabel { return onboardingHeaderView.messageLabel }

    var header: String {
        get { return headerLabel.text ?? "" }
        set {
            headerLabel.text = newValue
        }
    }

    var message: String {
        get { return messageLabel.text ?? "" }
        set {
            messageLabel.setLabelText(newValue, color: .greyA())
        }
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.whiteColor()

        setupHeaderView()
    }

    required public init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupHeaderView() {
        contentView.addSubview(onboardingHeaderView)
    }

    public func height() -> CGFloat {
        return onboardingHeaderView.intrinsicContentSize().height
    }

}
