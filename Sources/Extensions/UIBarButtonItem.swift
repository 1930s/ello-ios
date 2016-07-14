////
///  UIBarButtonItem.swift
//

extension UIBarButtonItem {

    class func backChevronWithTarget(target: AnyObject, action: Selector) -> UIBarButtonItem {
        let frame = CGRect(x: 0, y: 0, width: 36.0, height: 44.0)
        let button = UIButton(frame: frame)
        button.setImage(.AngleBracket, imageStyle: .Normal, forState: .Normal)
        // rotate 180 degrees to flip
        button.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
        button.addTarget(target, action: action, forControlEvents: .TouchUpInside)

        return UIBarButtonItem(customView: button)
    }

    class func closeButton(target target: AnyObject, action: Selector) -> UIBarButtonItem {
        let closeItem = UIBarButtonItem(image: InterfaceImage.X.normalImage, style: UIBarButtonItemStyle.Plain, target: target, action: action)
        return closeItem
    }

    convenience init(image: InterfaceImage, target: AnyObject, action: Selector) {
        let frame = CGRect(x: 0, y: 0, width: 36.0, height: 44.0)
        let button = UIButton(frame: frame)
        button.setImage(image, imageStyle: .Normal, forState: .Normal)
        button.addTarget(target, action: action, forControlEvents: .TouchUpInside)

        self.init(customView: button)
    }

}
