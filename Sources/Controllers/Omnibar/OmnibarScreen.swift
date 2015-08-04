//
//  OmnibarScreen.swift
//  Ello
//
//  Created by Colin Gray on 2/26/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//
// This screen tracks two sets of "changes": the attributed text of the textView
// (`currentText: NSAttributedString`), and the image uploaded by the image
// picker (`currentImage`).
//
// When the cancel button is tapped, the editor is reset and they keyboard is
// dismissed
//
// Lots of views and actions are exposed, this is for testing.
//
// In layoutSubviews(), the avatar, buttons, and text editor are placed
// according to the keyboard state (using the custom Keyboard class to get the
// height and animation properties).
//
// The events that are sent back to the controller: presenting and dismissing
// the UIImagePickerController, and submitting the text and image.

import UIKit
import Photos
import MobileCoreServices
import FLAnimatedImage
import SVGKit
import SDWebImage

@objc
public protocol OmnibarScreenDelegate {
    func omnibarCancel()
    func omnibarPushController(controller: UIViewController)
    func omnibarPresentController(controller: UIViewController)
    func omnibarDismissController(controller: UIViewController)
    func omnibarSubmitted(text: NSAttributedString?, image: UIImage, data: NSData, type: String)
    func omnibarSubmitted(text: NSAttributedString?, image: UIImage?)
}


@objc
public protocol OmnibarScreenProtocol {
    var delegate: OmnibarScreenDelegate? { get set }
    var title: String { get set }
    var avatarURL: NSURL? { get set }
    var avatarImage: UIImage? { get set }
    var currentUser: User? { get set }
    var canGoBack: Bool { get set }
    var text: String? { get set }
    var image: UIImage? { get set }
    var imageURL: NSURL? { get set }
    var attributedText: NSAttributedString? { get set }
    var isEditing: Bool { get set }
    func appendAttributedText(text: NSAttributedString)
    func reportSuccess(title: String)
    func reportError(title: String, error: NSError)
    func reportError(title: String, errorMessage: String)
    func keyboardWillShow()
    func keyboardWillHide()
    func startEditing()
    func updatePostState()
}

public class OmnibarScreen: UIView, OmnibarScreenProtocol {
    struct Size {
        static let margins = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
        static let textMargins = UIEdgeInsets(top: 22, left: 30, bottom: 9, right: 30)
        static let labelCorrection = CGFloat(8.5)
        static let innerTextMargin = CGFloat(11)
        static let bottomTextMargin = CGFloat(1)
        static let toolbarHeight = CGFloat(60)
        static let buttonHeight = CGFloat(45)
        static let buttonWidth = CGFloat(70)
    }

    var autoCompleteVC = AutoCompleteViewController()

// MARK: public access to text and image
    public var isEditing: Bool = false {
        didSet {
            submitButton.setTitle(NSLocalizedString("Update", comment: "Update button"), forState: .Normal)
        }
    }

    // Styles the text and assigns it as an NSAttributedString to
    // `attributedText`
    public var text: String? {
        set {
            if let value = newValue {
                self.attributedText = ElloAttributedString.style(value)
            }
            else {
                self.attributedText = nil
            }
        }
        get {
            return attributedText?.string
        }
    }

    // assigns the NSAttributedString to the UITextView and assigns
    // `currentText`
    public var attributedText: NSAttributedString? {
        set { userSetCurrentText(newValue) }
        get { return currentText }
    }

    public var title: String = "" {
        didSet {
            navigationItem.title = title
        }
    }
    let navigationItem = UINavigationItem()

    public func appendAttributedText(text: NSAttributedString) {
        let mutableString = NSMutableAttributedString()
        if let attributedText = attributedText {
            mutableString.appendAttributedString(attributedText)
        }
        mutableString.appendAttributedString(text)
        attributedText = mutableString
    }

    public var image: UIImage? {
        set { userSetCurrentImage(newValue) }
        get { return currentImage }
    }

    public var imageURL: NSURL? {
        set {
            if let url = newValue {
                userSetCurrentURL(url)
            }
            else {
                userSetCurrentImage(nil)
            }
        }
        get { return nil }
    }

    public var avatarURL: NSURL? {
        willSet(newValue) {
            if avatarURL != newValue {
                if let avatarURL = newValue {
                    self.avatarButtonView.sd_setImageWithURL(avatarURL, forState: .Normal)
                }
                else {
                    self.avatarButtonView.setImage(nil, forState: .Normal)
                }
            }
        }
    }

    public var avatarImage: UIImage? {
        willSet(newValue) {
            if avatarImage != newValue {
                if let avatarImage = newValue {
                    self.avatarButtonView.setImage(avatarImage, forState: .Normal)
                }
                else {
                    self.avatarButtonView.setImage(nil, forState: .Normal)
                }
            }
        }
    }

    public var canGoBack: Bool = false {
        didSet { setNeedsLayout() }
    }

    public var currentUser: User?

// MARK: internal and/or private vars

    weak public var delegate: OmnibarScreenDelegate?

    public let avatarButtonView = UIButton()

    let cancelButton = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
    public let cameraButton = UIButton(frame: CGRect(x: 44, y: 0, width: 44, height: 44))
    public let imageSelectedButton = UIButton(frame: CGRect(x: 44, y: 0, width: 44, height: 44))
    let imageTrashIcon = FLAnimatedImageView()
    let navigationBar = ElloNavigationBar(frame: CGRectZero)
    let submitButton = PostElloButton(frame: CGRect(x: 98, y: 0, width: 90, height: 44))
    let buttonContainer = UIView(frame: CGRect(x: 0, y: 0, width: 190, height: 60))
    let statusBarUnderlay = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 20))

    public let sayElloOverlay = UIControl()
    let sayElloLabel = UILabel()

    let textContainer = UIView()
    public let textView = UITextView()
    var autoCompleteContainer: UIView
    var autoCompleteThrottle: ThrottledBlock
    var autoCompleteShowing = false
    private var currentText: NSAttributedString?
    private var currentImage: UIImage?
    private var data: NSData?
    private var type: String?

// MARK: init

    override public init(frame: CGRect) {
        self.autoCompleteContainer = UIView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: 0))
        self.autoCompleteThrottle = debounce(0.4)
        super.init(frame: frame)
        self.backgroundColor = UIColor.whiteColor()

        setupAvatarView()
        setupSayElloViews()
        setupImageSelectedViews()
        setupNavigationBar()
        setupToolbarButtons()
        setupTextViews()
        setupViewHierarchy()
        setupSwipeGesture()
        autoCompleteVC.view.frame = autoCompleteContainer.frame
        autoCompleteVC.delegate = self
        autoCompleteContainer.addSubview(autoCompleteVC.view)
        textView.autocorrectionType = .Yes
        textView.inputAccessoryView = autoCompleteContainer
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

// MARK: View setup code

    // Avatar view (in the upper right corner) just needs to round its corners,
    // which is done in layoutSubviews.
    private func setupAvatarView() {
        avatarButtonView.backgroundColor = UIColor.blackColor()
        avatarButtonView.clipsToBounds = true
        avatarButtonView.addTarget(self, action: Selector("profileImageTapped"), forControlEvents: .TouchUpInside)
    }

    // the label and overlay cover the text view; on tap they are hidden and the
    // textView is given first responder status.  This is basically a workaround
    // for UITextView not having a `placeholder` property.
    private func setupSayElloViews() {
        sayElloLabel.text = "Say Ello…"
        sayElloLabel.textColor = UIColor.greyA()
        sayElloLabel.font = UIFont.typewriterFont(12)

        sayElloOverlay.addTarget(self, action: Selector("startEditingAction"), forControlEvents: .TouchUpInside)
    }
    // This is the button, image, and icon that appear in lieu of the camera
    // button after an image is selected.  Tapping this button removes the
    // selected image.
    private func setupImageSelectedViews() {
        imageSelectedButton.contentMode = .ScaleAspectFit
        imageSelectedButton.addTarget(self, action: Selector("removeButtonAction"), forControlEvents: .TouchUpInside)

        imageTrashIcon.contentMode = .Center
        imageTrashIcon.layer.cornerRadius = 13
        imageTrashIcon.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.7)
        imageTrashIcon.image = SVGKImage(named: "trash_white.svg").UIImage!
        imageTrashIcon.frame = CGRect.at(x: imageSelectedButton.frame.width / 2, y: imageSelectedButton.frame.height / 2).grow(all: imageTrashIcon.layer.cornerRadius)
        imageTrashIcon.autoresizingMask = .FlexibleBottomMargin | .FlexibleTopMargin | .FlexibleLeftMargin | .FlexibleRightMargin
        imageSelectedButton.addSubview(imageTrashIcon)
    }
    private func setupNavigationBar() {
        let backItem = UIBarButtonItem.backChevronWithTarget(self, action: Selector("backAction"))
        navigationItem.leftBarButtonItem = backItem
        navigationItem.fixNavBarItemPadding()
        navigationBar.items = [navigationItem]

        statusBarUnderlay.frame.size.width = frame.width
        statusBarUnderlay.backgroundColor = .blackColor()
        statusBarUnderlay.autoresizingMask = .FlexibleWidth | .FlexibleBottomMargin
        addSubview(statusBarUnderlay)
    }

    // buttons that make up the "toolbar"
    private func setupToolbarButtons() {
        cameraButton.setSVGImages("camera")
        cameraButton.addTarget(self, action: Selector("addImageAction"), forControlEvents: .TouchUpInside)

        cancelButton.setSVGImages("x")
        cancelButton.addTarget(self, action: Selector("cancelEditingAction"), forControlEvents: .TouchUpInside)

        submitButton.addTarget(self, action: Selector("submitAction"), forControlEvents: .TouchUpInside)
        submitButton.setTitle(NSLocalizedString("Post", comment: "Post button"), forState: .Normal)
        submitButton.setTitleColor(UIColor.whiteColor(), forState: .Disabled)
        let image = SVGKImage(named: "arrow_white").UIImage!
        let imageView = UIImageView(image: image)
        imageView.center = CGPoint(x: submitButton.frame.width - image.size.width / 2 - 13, y: submitButton.frame.height / CGFloat(2))
        imageView.autoresizingMask = .FlexibleLeftMargin | .FlexibleTopMargin | .FlexibleBottomMargin
        submitButton.addSubview(imageView)
        submitButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: submitButton.frame.width - imageView.frame.minX - 2)
    }

    // The textContainer is the outer gray background.  The text view is
    // configured to fill that container (only the container and the text view
    // insets are modified in layoutSubviews)
    private func setupTextViews() {
        textContainer.backgroundColor = UIColor.greyE5()
        textView.editable = true
        textView.allowsEditingTextAttributes = true
        textView.selectable = true
        textView.textColor = UIColor.blackColor()
        textView.font = UIFont.typewriterFont(12)
        textView.textContainer.lineFragmentPadding = 0
        textView.backgroundColor = UIColor.greyE5()
        textView.delegate = self
        textView.autoresizingMask = .FlexibleHeight | .FlexibleWidth
    }

    private func setupViewHierarchy() {
        for view in [navigationBar, avatarButtonView, buttonContainer, textContainer, sayElloOverlay] as [UIView] {
            self.addSubview(view)
        }
        for view in [cancelButton, cameraButton, submitButton] as [UIView] {
            buttonContainer.addSubview(view)
        }
        sayElloOverlay.addSubview(sayElloLabel)
        textContainer.addSubview(textView)
    }
    private func setupSwipeGesture() {
        let gesture = UISwipeGestureRecognizer()
        gesture.direction = .Down
        gesture.addTarget(self, action: Selector("swipedDown"))
        self.addGestureRecognizer(gesture)
    }

// MARK: Public interface

    public func reportSuccess(title: String) {
        let alertController = AlertViewController(message: title)

        let cancelAction = AlertAction(title: NSLocalizedString("OK", comment: "ok button"), style: .Light, handler: .None)
        alertController.addAction(cancelAction)

        delegate?.omnibarPresentController(alertController)
        self.resetAfterSuccessfulPost()
    }

    private func resetAfterSuccessfulPost() {
        resetEditor()
    }

    public func profileImageTapped() {
        if let userParam = currentUser?.id {
            let profileVC = ProfileViewController(userParam: userParam)
            profileVC.currentUser = self.currentUser
            self.delegate?.omnibarPushController(profileVC)
        }
    }

    public func startEditing() {
        sayElloOverlay.hidden = true
        textView.becomeFirstResponder()
    }

    public func reportError(title: String, error: NSError) {
        let errorMessage = error.elloErrorMessage ?? error.localizedDescription
        reportError(title, errorMessage: errorMessage)
    }

    public func reportError(title: String, errorMessage: String) {
        let alertController = AlertViewController(message: title)

        let cancelAction = AlertAction(title: NSLocalizedString("OK", comment: "ok button"), style: .Light, handler: .None)
        alertController.addAction(cancelAction)

        delegate?.omnibarPresentController(alertController)
    }

// MARK: Keyboard events - animate layout update in conjunction with keyboard animation

    public func keyboardWillShow() {
        self.setNeedsLayout()
        UIView.animateWithDuration(Keyboard.shared().duration,
            delay: 0.0,
            options: Keyboard.shared().options,
            animations: {
                self.layoutIfNeeded()
            },
            completion: nil)
    }

    public func keyboardWillHide() {
        self.setNeedsLayout()
        UIView.animateWithDuration(Keyboard.shared().duration,
            delay: 0.0,
            options: Keyboard.shared().options,
            animations: {
                self.layoutIfNeeded()
            },
            completion: nil)
    }

    private func resignKeyboard() {
        if text == nil || text! == "" {
            sayElloOverlay.hidden = false
        }
        textView.resignFirstResponder()
    }

// MARK: Layout and update views

    override public func layoutSubviews() {
        super.layoutSubviews()

        var screenTop = CGFloat(20)
        if canGoBack {
            UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Slide)
            navigationBar.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: ElloNavigationBar.Size.height)
            screenTop += navigationBar.frame.height
            statusBarUnderlay.hidden = true
        }
        else {
            statusBarUnderlay.hidden = false
        }

        var avatarViewLeft = Size.margins.left
        avatarButtonView.frame = CGRect(x: avatarViewLeft, y: screenTop + Size.margins.top, width: Size.toolbarHeight, height: Size.toolbarHeight)
        avatarButtonView.layer.cornerRadius = Size.toolbarHeight / CGFloat(2)

        buttonContainer.frame = CGRect(x: frame.width - Size.margins.right, y: screenTop + Size.margins.top, width: 0, height: Size.toolbarHeight)
            .growLeft(buttonContainer.frame.width)
        for view in buttonContainer.subviews as! [UIView] {
            view.center.y = buttonContainer.frame.height / 2
        }

        // make sure the textContainer is above the keboard, with a 1pt line
        // margin at the bottom.
        // size the textContainer and sayElloOverlay to be identical.
        var localKbdHeight = Keyboard.shared().keyboardBottomInset(inView: self)
        if localKbdHeight < 0 {
            localKbdHeight = Size.margins.bottom
        }
        else {
            localKbdHeight += Size.bottomTextMargin
        }
        textContainer.frame = CGRect.make(x: Size.margins.left, y: buttonContainer.frame.maxY + Size.innerTextMargin,
            right: bounds.size.width - Size.margins.right, bottom: bounds.size.height - localKbdHeight)
        sayElloOverlay.frame = textContainer.frame
        sayElloLabel.frame = CGRect(x: Size.textMargins.left, y: Size.textMargins.top + Size.labelCorrection, width: 0, height: 0)
        sayElloLabel.sizeToFit()

        // size so that it is offset from the textContainer
        textView.frame = textContainer.bounds.inset(top: 0, left: Size.textMargins.left, bottom: 0, right: Size.textMargins.right)
        textView.contentInset = UIEdgeInsets(top: Size.textMargins.top, left: 0, bottom: Size.textMargins.bottom, right: 0)
        textView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -Size.textMargins.right)
        textContainer.clipsToBounds = true
        textView.clipsToBounds = false
    }

    private func resetEditor() {
        hideAutoComplete()
        sayElloOverlay.hidden = false
        textView.resignFirstResponder()
        textView.text = ""
        currentText = nil
        setCurrentImage(nil)
        updatePostState()
    }

    public func updatePostState() {
        submitButton.enabled = canPost()
    }

// MARK: Button Actions

    func backAction() {
        delegate?.omnibarCancel()
    }

    public func startEditingAction() {
        startEditing()
    }

    public func cancelEditingAction() {
        if canPost() && !isEditing {
            let alertController = AlertViewController()

            let deleteAction = AlertAction(title: NSLocalizedString("Delete", comment: "Delete button"), style: ActionStyle.Dark, handler: { _ in
                self.resetEditor()
            })
            alertController.addAction(deleteAction)

            let cancelAction = AlertAction(title: NSLocalizedString("Cancel", comment: "Cancel button"), style: .Light, handler: .None)
            alertController.addAction(cancelAction)

            delegate?.omnibarPresentController(alertController)
        }
        else {
            delegate?.omnibarCancel()
        }
    }

    public func submitAction() {
        if canPost() {
            textView.resignFirstResponder()
            var submittedText: NSAttributedString?
            if currentTextIsPresent() {
                submittedText = currentText
            }

            if let image = currentImage, let data = data, let type = type {
                delegate?.omnibarSubmitted(submittedText, image: image, data: data, type: type)
            }
            else {
                delegate?.omnibarSubmitted(submittedText, image: currentImage)
            }
        }
    }

    public func removeButtonAction() {
        userSetCurrentImage(nil)
    }

    public func swipedDown() {
        resignKeyboard()
    }

// MARK: Post logic

    private func currentTextIsPresent() -> Bool {
        return currentText != nil && count(currentText!.string) > 0
    }

    private func currentImageIsPresent() -> Bool {
        return currentImage != nil
    }

    public func canPost() -> Bool {
        return currentTextIsPresent() || currentImageIsPresent()
    }

// MARK: Images

    func userSetCurrentImage(image: UIImage?, data: NSData? = nil, type: String? = nil) {
        setCurrentImage(image)
        self.data = data
        self.type = type

        updatePostState()
    }

    func userSetCurrentURL(imageURL: NSURL) {
        SDWebImageManager.sharedManager().downloadImageWithURL(imageURL,
            options: SDWebImageOptions.LowPriority,
            progress: { (_, _) in }, completed: { (image, _, _, _, _) in
                self.userSetCurrentImage(image)
            }
        )
    }

    // this updates the currentImage and buttons
    private func setCurrentImage(image: UIImage?) {
        self.currentImage = image

        if let image = image {
            cameraButton.removeFromSuperview()
            imageSelectedButton.setImage(image, forState: .Normal)
            if let imageSelectedImageView = imageSelectedButton.imageView {
                imageSelectedImageView.contentMode = .ScaleAspectFill
                imageSelectedImageView.clipsToBounds = true
            }
            imageSelectedButton.center = cameraButton.center
            buttonContainer.insertSubview(imageSelectedButton, atIndex: 0)
            buttonContainer.layoutIfNeeded()

            imageSelectedButton.transform = CGAffineTransformMakeScale(1.3, 1.3)
            imageSelectedButton.alpha = 0
            UIView.animateWithDuration(0.3) {
                self.imageSelectedButton.transform = CGAffineTransformIdentity
            }
            UIView.animateWithDuration(0.2) {
                self.imageSelectedButton.alpha = 1
            }
        }
        else {
            if imageSelectedButton.superview != nil {
                imageSelectedButton.removeFromSuperview()
                let convertedFrame = convertRect(imageSelectedButton.frame, fromView: buttonContainer)
                imageSelectedButton.frame = convertedFrame
                addSubview(imageSelectedButton)
                UIView.animateWithDuration(0.3) {
                    self.imageSelectedButton.transform = CGAffineTransformMakeScale(0.1, 0.1)
                }
                UIView.animateWithDuration(0.2) {
                    self.imageSelectedButton.alpha = 0
                }
            }
            buttonContainer.insertSubview(cameraButton, atIndex: 0)
        }

        // disable the cancel button during animations (fixes weird scaling bug in iOS 8)
        cancelButton.userInteractionEnabled = false
        delay(0.3) {
            self.cancelButton.userInteractionEnabled = true
        }
    }

// MARK: Camera / Image Picker

    public func addImageAction() {
        let alert = UIImagePickerController.alertControllerForImagePicker(openImagePicker)
        alert.map { self.delegate?.omnibarPresentController($0) }
    }

    private func isGif(buffer: UnsafeMutablePointer<UInt8>, length: Int) -> Bool {
        if length >= 4 {
            let isG = Int(buffer[0]) == 71
            let isI = Int(buffer[1]) == 73
            let isF = Int(buffer[2]) == 70
            let is8 = Int(buffer[3]) == 56

            return isG && isI && isF && is8
        }
        else {
            return false
        }
    }


// MARK: Text View editing

    // Updates the text view, including the overlay
    // and first responder state.  This method is meant to be used during
    // initialization.
    private func userSetCurrentText(value: NSAttributedString?) {
        if currentText != value {
            if let text = value {
                textView.attributedText = text
                sayElloOverlay.hidden = true
            }
            else {
                textView.text = ""
                sayElloOverlay.hidden = false
            }
        }

        currentText = value
        textView.resignFirstResponder()
    }

}


// MARK: UITextViewDelegate
extension OmnibarScreen: UITextViewDelegate {
    public func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        return true
    }

    private func throttleAutoComplete(range: NSRange) {
        self.autoCompleteThrottle { [unowned self] in
            let autoComplete = AutoComplete()
            // deleting characters yields a range.length > 0, go back 1 character for deletes
            let location = range.length > 0 && range.location > 0 ? range.location - 1 : range.location
            if let match = autoComplete.check(self.textView.text, location: location) {
                self.autoCompleteVC.load(match) { count in
                    if count > 0 {
                        self.showAutoComplete(count)
                    }
                    else if count == 0 {
                        self.hideAutoComplete()
                    }
                }
            } else {
                self.hideAutoComplete()
            }
        }
    }

    public func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText: String) -> Bool {

        if autoCompleteShowing && emojiKeyboardShowing() {
            return false
        }

        let newText = NSString(string: textView.text).stringByReplacingCharactersInRange(range, withString: replacementText)
        currentText = ElloAttributedString.style(newText)

        updatePostState()
        throttleAutoComplete(range)
        return true
    }

    private func emojiKeyboardShowing() -> Bool {
        return textView.textInputMode?.primaryLanguage == nil || textView.textInputMode?.primaryLanguage == "emoji"
    }

    private func hideAutoComplete() {
        if autoCompleteShowing {
            autoCompleteShowing = false
            textView.autocorrectionType = .Yes
            textView.inputAccessoryView = nil
            textView.resignFirstResponder()
            textView.becomeFirstResponder()
        }
    }

    private func showAutoComplete(count: Int) {
        if !autoCompleteShowing {
            autoCompleteShowing = true
            textView.inputAccessoryView = autoCompleteContainer
            textView.autocorrectionType = .No
            textView.resignFirstResponder()
            textView.becomeFirstResponder()
        }

        let height: CGFloat = count > 3 ? AutoCompleteCell.cellHeight() * 3 : AutoCompleteCell.cellHeight() * CGFloat(count)
        if let constraint = textView.inputAccessoryView?.constraints().first as? NSLayoutConstraint {
            constraint.constant = height
        }
        autoCompleteContainer.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: height)
        autoCompleteVC.view.frame = autoCompleteContainer.frame
    }
}


extension OmnibarScreen: AutoCompleteDelegate {
    public func itemSelected(item: AutoCompleteItem) {
        if let name = item.result.name {
            let prefix = item.type == .Username ? "@" : ":"
            let newText = textView.text.stringByReplacingCharactersInRange(item.match.range, withString: prefix + name + " ")
            currentText = ElloAttributedString.style(newText)
            textView.attributedText = currentText
            updatePostState()
            hideAutoComplete()
        }
    }
}


// MARK: UIImagePickerControllerDelegate
extension OmnibarScreen: UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    private func openImagePicker(imageController: UIImagePickerController) {
        imageController.delegate = self
        delegate?.omnibarPresentController(imageController)
    }

    public func imagePickerController(controller: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject: AnyObject]) {
        let library = PHPhotoLibrary.sharedPhotoLibrary()
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            if let url = info[UIImagePickerControllerReferenceURL] as? NSURL,
               let asset = PHAsset.fetchAssetsWithALAssetURLs([url], options: nil).firstObject as? PHAsset
            {
                    PHImageManager.defaultManager().requestImageDataForAsset(asset, options: nil) { imageData, dataUTI, orientation, info in
                        var buffer = UnsafeMutablePointer<UInt8>.alloc(imageData.length)
                        imageData.getBytes(buffer, length: imageData.length)
                        if self.isGif(buffer, length: imageData.length) {
                            self.userSetCurrentImage(image, data: imageData, type: "image/gif")
                        }
                        else {
                            self.userSetCurrentImage(image)
                        }
                        buffer.dealloc(imageData.length)
                        self.delegate?.omnibarDismissController(controller)
                    }
            }
            else {
                image.copyWithCorrectOrientationAndSize() { image in
                    self.userSetCurrentImage(image)
                    self.delegate?.omnibarDismissController(controller)
                }
            }
        }
        else {
            delegate?.omnibarDismissController(controller)
        }
    }

    public func imagePickerControllerDidCancel(controller: UIImagePickerController) {
        delegate?.omnibarDismissController(controller)
    }
}
