////
///  JoinScreen.swift
//

import SnapKit


public class JoinScreen: CredentialsScreen {
    struct Size {
        static let fieldsTopMargin: CGFloat = 55
        static let fieldsErrorMargin: CGFloat = 15
        static let fieldsInnerMargin: CGFloat = 30
        static let buttonHeight: CGFloat = 50
        static let buttonInset: CGFloat = 10
        static let termsFontSize: CGFloat = 11
        static let termsBottomInset: CGFloat = 5
    }

    weak var delegate: JoinDelegate?
    var emailValid: Bool? = nil {
        didSet {
            if let emailValid = emailValid {
                emailField.validationState = emailValid ? .OKSmall : .Error
                styleDiscoverButton()
            }
            else {
                emailField.validationState = .None
            }
        }
    }
    var email: String {
        get { return emailField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) ?? "" }
        set { emailField.text = newValue }
    }
    var usernameValid: Bool? = nil {
        didSet {
            if let usernameValid = usernameValid {
                usernameField.validationState = usernameValid ? .OKSmall : .Error
                styleDiscoverButton()
            }
            else {
                usernameField.validationState = .None
            }
        }
    }
    var username: String {
        get { return usernameField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) ?? "" }
        set { usernameField.text = newValue }
    }
    var passwordValid: Bool? = nil {
        didSet {
            if let passwordValid = passwordValid {
                passwordField.validationState = passwordValid ? .OKSmall : .Error
                styleDiscoverButton()
            }
            else {
                passwordField.validationState = .None
            }
        }
    }
    var password: String {
        get { return passwordField.text ?? "" }
        set { passwordField.text = newValue }
    }
    var onePasswordAvailable = false {
        didSet { passwordField.hasOnePassword = onePasswordAvailable }
    }

    let emailField = ClearTextField()
    let emailErrorLabel = ElloSizeableLabel()
    var emailMargin: Constraint!

    let usernameField = ClearTextField()
    let usernameErrorLabel = ElloSizeableLabel()
    var usernameMargin: Constraint!

    let passwordField = ClearTextField()
    let passwordErrorLabel = ElloSizeableLabel()
    var passwordMargin: Constraint!

    let messageLabel = ElloSizeableLabel()
    var messageMargin: Constraint!
    let termsButtonNormal = UIButton()
    let termsButtonKeyboard = UIButton()

    let discoverButton = StyledButton(style: .RoundedGray)
    let continueBackground = UIView()

    override func setText() {
        titleLabel.text = InterfaceString.Startup.SignUp
        discoverButton.setTitle(InterfaceString.Join.Discover, forState: .Normal)
    }

    override func bindActions() {
        super.bindActions()
        discoverButton.addTarget(self, action: #selector(submitAction), forControlEvents: .TouchUpInside)
        termsButtonNormal.addTarget(self, action: #selector(termsAction), forControlEvents: .TouchUpInside)
        termsButtonKeyboard.addTarget(self, action: #selector(termsAction), forControlEvents: .TouchUpInside)
        passwordField.onePasswordButton.addTarget(self, action: #selector(onePasswordAction(_:)), forControlEvents: .TouchUpInside)
    }

    override func style() {
        super.style()

        let attrs = ElloAttributedString.attrs([
            NSForegroundColorAttributeName: UIColor.greyA(),
            NSFontAttributeName: UIFont.defaultFont(Size.termsFontSize),
        ])
        let linkAttrs = ElloAttributedString.attrs(ElloAttributedString.linkAttrs(), [
            NSForegroundColorAttributeName: UIColor.greyA(),
            NSFontAttributeName: UIFont.defaultFont(Size.termsFontSize),
        ])
        let attributedTitle = NSAttributedString(string: "By clicking Continue you are agreeing to our ", attributes: attrs) + NSAttributedString(string: "Terms", attributes: linkAttrs)
        termsButtonNormal.setAttributedTitle(attributedTitle, forState: .Normal)
        termsButtonKeyboard.setAttributedTitle(attributedTitle, forState: .Normal)

        ElloTextFieldView.styleAsEmailField(emailField)
        emailField.placeholder = InterfaceString.Join.EmailPlaceholder
        emailField.delegate = self
        emailErrorLabel.font = UIFont.defaultFont(12)
        emailErrorLabel.textColor = .whiteColor()

        ElloTextFieldView.styleAsUsernameField(usernameField)
        usernameField.placeholder = InterfaceString.Join.UsernamePlaceholder
        usernameField.delegate = self
        usernameErrorLabel.font = UIFont.defaultFont(12)
        usernameErrorLabel.textColor = .whiteColor()

        ElloTextFieldView.styleAsPasswordField(passwordField)
        passwordField.placeholder = InterfaceString.Join.PasswordPlaceholder
        passwordField.delegate = self
        passwordField.returnKeyType = .Join
        passwordField.hasOnePassword = onePasswordAvailable
        passwordErrorLabel.font = UIFont.defaultFont(12)
        passwordErrorLabel.textColor = .whiteColor()

        messageLabel.font = UIFont.defaultFont(12)
        messageLabel.textColor = .whiteColor()
        messageLabel.numberOfLines = 0

        termsButtonNormal.hidden = Keyboard.shared.active
        termsButtonKeyboard.hidden = !Keyboard.shared.active

        continueBackground.backgroundColor = .whiteColor()
    }

    override func arrange() {
        super.arrange()

        scrollView.addSubview(emailField)
        scrollView.addSubview(emailErrorLabel)
        scrollView.addSubview(usernameField)
        scrollView.addSubview(usernameErrorLabel)
        scrollView.addSubview(messageLabel)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(passwordErrorLabel)

        scrollView.addSubview(termsButtonKeyboard)

        addSubview(termsButtonNormal)
        addSubview(continueBackground)
        continueBackground.addSubview(discoverButton)

        scrollView.snp_makeConstraints { make in
            make.leading.trailing.equalTo(self)
            make.top.equalTo(blackBar.snp_bottom)
            make.bottom.equalTo(continueBackground.snp_top)
        }

        let scrollViewAnchor = UIView()
        scrollView.addSubview(scrollViewAnchor)
        scrollViewAnchor.snp_makeConstraints { make in
            make.leading.trailing.top.equalTo(scrollView)
            scrollViewWidth = make.width.equalTo(frame.size.width).priorityRequired().constraint
        }

        emailField.snp_makeConstraints { make in
            make.top.equalTo(titleLabel.snp_bottom).offset(Size.fieldsTopMargin)
            make.leading.trailing.equalTo(scrollView).inset(CredentialsScreen.Size.inset)
        }
        emailErrorLabel.snp_makeConstraints { make in
            emailMargin = make.top.equalTo(emailField.snp_bottom).offset(Size.fieldsErrorMargin).priorityRequired().constraint
            make.top.equalTo(emailField.snp_bottom).priorityMedium()
            make.leading.trailing.equalTo(scrollView).inset(CredentialsScreen.Size.inset)
        }
        emailMargin.deactivate()

        usernameField.snp_makeConstraints { make in
            make.top.equalTo(emailErrorLabel.snp_bottom).offset(Size.fieldsInnerMargin)
            make.leading.trailing.equalTo(scrollView).inset(CredentialsScreen.Size.inset)
        }
        usernameErrorLabel.snp_makeConstraints { make in
            usernameMargin = make.top.equalTo(usernameField.snp_bottom).offset(Size.fieldsErrorMargin).priorityRequired().constraint
            make.top.equalTo(usernameField.snp_bottom).priorityMedium()
            make.leading.trailing.equalTo(scrollView).inset(CredentialsScreen.Size.inset)
        }
        usernameMargin.deactivate()

        messageLabel.snp_makeConstraints { make in
            messageMargin = make.top.equalTo(usernameErrorLabel.snp_bottom).offset(Size.fieldsErrorMargin).priorityRequired().constraint
            make.top.equalTo(usernameErrorLabel.snp_bottom).priorityMedium()
            make.leading.trailing.equalTo(scrollView).inset(CredentialsScreen.Size.inset)
        }
        messageMargin.deactivate()

        passwordField.snp_makeConstraints { make in
            make.top.equalTo(messageLabel.snp_bottom).offset(Size.fieldsInnerMargin)
            make.leading.trailing.equalTo(scrollView).inset(CredentialsScreen.Size.inset)
        }
        passwordErrorLabel.snp_makeConstraints { make in
            passwordMargin = make.top.equalTo(passwordField.snp_bottom).offset(Size.fieldsErrorMargin).priorityRequired().constraint
            make.top.equalTo(passwordField.snp_bottom).priorityMedium()
            make.leading.trailing.equalTo(scrollView).inset(CredentialsScreen.Size.inset)
            make.bottom.lessThanOrEqualTo(scrollView).inset(Size.inset)
        }
        passwordMargin.deactivate()

        termsButtonKeyboard.snp_makeConstraints { make in
            make.leading.equalTo(scrollView).inset(CredentialsScreen.Size.inset)
            make.top.equalTo(passwordErrorLabel.snp_bottom).offset(Size.inset)
            make.bottom.equalTo(scrollView).inset(CredentialsScreen.Size.inset)
        }

        termsButtonNormal.snp_makeConstraints { make in
            make.leading.equalTo(scrollView).inset(CredentialsScreen.Size.inset)
            make.bottom.equalTo(continueBackground.snp_top).offset(-Size.termsBottomInset)
        }

        discoverButton.snp_makeConstraints { make in
            make.leading.trailing.equalTo(self).inset(Size.buttonInset)
            make.bottom.equalTo(keyboardAnchor.snp_top).offset(-Size.buttonInset)
            make.height.equalTo(Size.buttonHeight)
        }

        continueBackground.snp_makeConstraints { make in
            make.leading.trailing.bottom.equalTo(self)
            make.top.equalTo(discoverButton).offset(-Size.buttonInset)
        }
    }

    override public func resignFirstResponder() -> Bool {
        emailField.resignFirstResponder()
        usernameField.resignFirstResponder()
        passwordField.resignFirstResponder()
        return super.resignFirstResponder()
    }

    override public func keyboardIsAnimating(keyboard: Keyboard) {
        termsButtonNormal.hidden = keyboard.active
        termsButtonKeyboard.hidden = !keyboard.active
    }
}

extension JoinScreen {
    private func styleDiscoverButton() {
        let allValid: Bool
        if let emailValid = emailValid,
            usernameValid = usernameValid,
            passwordValid = passwordValid
        {
            allValid = emailValid && usernameValid && passwordValid
        }
        else {
            allValid = false
        }

        if allValid {
            discoverButton.style = .Green
        }
        else {
            discoverButton.style = .RoundedGray
        }
    }
}

extension JoinScreen {
    override public func backAction() {
        delegate?.backAction()
    }

    public func submitAction() {
        delegate?.submit(email: email, username: username, password: password)
    }

    public func termsAction() {
        delegate?.termsAction()
    }

    public func onePasswordAction(sender: UIView) {
        delegate?.onePasswordAction(sender)
    }
}

extension JoinScreen: UITextFieldDelegate {

    public func textFieldDidEndEditing(textField: UITextField) {
        textField.setNeedsLayout()
        textField.layoutIfNeeded()
    }

    public func textField(textField: UITextField, shouldChangeCharactersInRange nsrange: NSRange, replacementString: String) -> Bool {
        guard let delegate = delegate else { return true }

        var text = textField.text ?? ""
        if let range = text.rangeFromNSRange(nsrange) {
            text.replaceRange(range, with: replacementString)
        }
        var email = self.email,
            username = self.username,
            password = self.password
        switch textField {
        case emailField:
            email = text
        case usernameField:
            username = text
        case passwordField:
            password = text
        default:
            break
        }

        delegate.validate(email: email, username: username, password: password)
        return true
    }

    public func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField {
        case emailField:
            Tracker.sharedTracker.enteredEmail()
            usernameField.becomeFirstResponder()
            return true
        case usernameField:
            Tracker.sharedTracker.enteredEmail()
            passwordField.becomeFirstResponder()
            return true
        case passwordField:
            Tracker.sharedTracker.enteredPassword()
            delegate?.submit(email: email, username: username, password: password)
            return false
        default:
            return true
        }
    }
}

extension JoinScreen: JoinScreenProtocol {
    func enableInputs() {
        emailField.enabled = true
        usernameField.enabled = true
        passwordField.enabled = true
        userInteractionEnabled = true
    }

    func disableInputs() {
        emailField.enabled = false
        usernameField.enabled = false
        passwordField.enabled = false
        userInteractionEnabled = false
    }

    func showUsernameSuggestions(usernames: [String]) {
        let usernameAttrs = [
            NSFontAttributeName: UIFont.defaultFont(12),
            NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue,
        ]
        let plainAttrs = [
            NSFontAttributeName: UIFont.defaultFont(12),
        ]
        let suggestions: NSAttributedString = usernames.reduce(NSAttributedString(string: "", attributes: plainAttrs)) { attrdString, username in
            let usernameAttrd = NSAttributedString(string: username, attributes: usernameAttrs)
            if attrdString.string.isEmpty {
                return usernameAttrd
            }
            return attrdString + NSAttributedString(string: ", ", attributes: plainAttrs) + usernameAttrd
        }
        let msg = NSAttributedString(string: InterfaceString.Join.UsernameSuggestionPrefix, attributes: plainAttrs) + suggestions
        showMessageAttributed(msg)
    }

    func showMessage(text: String) {
        let plainAttrs = [
            NSFontAttributeName: UIFont.defaultFont(12),
        ]
        showMessageAttributed(NSAttributedString(string: text, attributes: plainAttrs))
    }

    func showMessageAttributed(attrd: NSAttributedString) {
        messageLabel.attributedText = attrd

        animate {
            self.messageMargin.activate()
            self.messageLabel.alpha = 1.0
            self.layoutIfNeeded()
        }
    }

    func hideMessage() {
        animate {
            self.messageMargin.deactivate()
            self.messageLabel.alpha = 0.0
            self.layoutIfNeeded()
        }
    }

    func showUsernameError(text: String) {
        usernameErrorLabel.text = text
        usernameValid = false

        animate {
            self.usernameMargin.activate()
            self.usernameErrorLabel.alpha = 1.0
            self.layoutIfNeeded()
        }
    }

    func hideUsernameError() {
        animate {
            self.usernameMargin.deactivate()
            self.usernameErrorLabel.alpha = 0.0
            self.layoutIfNeeded()
        }
    }

    func showEmailError(text: String) {
        emailErrorLabel.text = text
        emailValid = false

        animate {
            self.emailMargin.activate()
            self.emailErrorLabel.alpha = 1.0
            self.layoutIfNeeded()
        }
    }

    func hideEmailError() {
        animate {
            self.emailMargin.deactivate()
            self.emailErrorLabel.alpha = 0.0
            self.layoutIfNeeded()
        }
    }

    func showPasswordError(text: String) {
        passwordErrorLabel.text = text
        passwordValid = false

        animate {
            self.passwordMargin.activate()
            self.passwordErrorLabel.alpha = 1.0
            self.layoutIfNeeded()
        }
    }

    func hidePasswordError() {
        animate {
            self.passwordMargin.deactivate()
            self.passwordErrorLabel.alpha = 0.0
            self.layoutIfNeeded()
        }
    }

    func showError(text: String) {
        showPasswordError(text)
    }
}
