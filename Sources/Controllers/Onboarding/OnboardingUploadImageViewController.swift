////
///  OnboardingUploadImageViewController.swift
//

public class OnboardingUploadImageViewController: BaseElloViewController, OnboardingStep {
    struct Size {
        static let maxWidth = CGFloat(500)
    }
    weak var onboardingViewController: OnboardingViewController?
    var onboardingData: OnboardingData? {
        didSet {
            if let image = onboardingData?.coverImage {
                chooseCoverImageView?.image = image
                onboardingViewController?.canGoNext = true
            }

            if let image = onboardingData?.avatarImage {
                chooseAvatarImageView?.image = image
                onboardingViewController?.canGoNext = true
            }
        }
    }
    var chooseCoverImageView: UIImageView?
    var chooseAvatarImageView: UIImageView?
    var chooseImageButton: UIButton?
    var selectedImage: UIImage?

    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .None)
        UIApplication.sharedApplication().statusBarStyle = .LightContent
    }

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if let button = chooseImageButton {
            let bottomMargin = CGFloat(10)
            if button.frame.maxY + bottomMargin > view.frame.height {
                button.frame.origin.y = view.frame.height - (button.frame.height + bottomMargin)
            }
        }
    }

    func onboardingWillProceed(_: (OnboardingData?) -> Void) {
        print("implemented but intentionally left blank")
    }

    func onboardingStepBegin() {
        print("implemented but intentionally left blank")
    }

}

// MARK: Default images
extension OnboardingUploadImageViewController {
    func chooseCoverImageDefault() -> UIImage { return UIImage(named: "choose-header-image")! }
    func chooseAvatarImageDefault() -> UIImage { return UIImage(named: "choose-avatar-image")! }
}

// MARK: Loading the image picker controller and getting results
extension OnboardingUploadImageViewController {
    func chooseImageTapped() {
        if let alertController = UIImagePickerController.alertControllerForImagePicker(openImagePicker) {
            logPresentingAlert("OnboardingUploadImageViewController")
            presentViewController(alertController, animated: true, completion: nil)
        }
    }

    private func openImagePicker(imageController: UIImagePickerController) {
        imageController.delegate = self
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .None)
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        self.presentViewController(imageController, animated: true, completion: nil)
    }

    public func userSetImage(image: UIImage) {
        chooseImageButton?.setTitle(InterfaceString.Onboard.PickAnotherImage, forState: .Normal)
        onboardingViewController?.canGoNext = true
        selectedImage = image
    }

    public func userUploadFailed() {
        let message = InterfaceString.Onboard.UploadFailed
        let alertController = AlertViewController(message: message)

        let action = AlertAction(title: InterfaceString.OK, style: .Dark, handler: nil)
        alertController.addAction(action)

        logPresentingAlert("OnboardingUploadImageViewController")
        presentViewController(alertController, animated: true, completion: nil)
    }
}

// MARK: UIImagePickerControllerDelegate
extension OnboardingUploadImageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    public func imagePickerController(controller: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let orientedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            orientedImage.copyWithCorrectOrientationAndSize() { image in
                self.userSetImage(image)
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        else {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }

    public func imagePickerControllerDidCancel(controller: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }

}
