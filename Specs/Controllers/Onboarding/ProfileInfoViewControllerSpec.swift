////
///  ProfileInfoViewControllerSpec.swift
//

@testable
import Ello
import Quick
import Nimble
import Nimble_Snapshots


class ProfileInfoViewControllerSpec: QuickSpec {
    override func spec() {
        describe("ProfileInfoViewController") {
            let subject = ProfileInfoViewController()
            let onboardingData = OnboardingData()
            onboardingData.avatarImage = UIImage.imageWithColor(.redColor(), size: CGSize(width: 500, height: 500))
            onboardingData.coverImage = UIImage.imageWithColor(.greenColor(), size: CGSize(width: 1000, height: 1000))
            subject.onboardingData = onboardingData

            context("iPad in landscape") {
                beforeEach {
                    let parent = UIView(frame: CGRect(x: 0, y: 0, width: 1024, height: 768))
                    subject.view.frame = parent.bounds
                    parent.addSubview(subject.view)
                    subject.view.layoutIfNeeded()
                    showView(parent)
                }
                describe("view") {
                    it("should match the screenshot") {
                        let view = subject.view
                        expect(view).to(haveValidSnapshot())
                    }
                }
            }
            context("iPad in portrait") {
                beforeEach {
                    let parent = UIView(frame: CGRect(x: 0, y: 0, width: 768, height: 1024))
                    subject.view.frame = parent.bounds
                    parent.addSubview(subject.view)
                    subject.view.layoutIfNeeded()
                    showView(parent)
                }
                describe("view") {
                    it("should match the screenshot") {
                        let view = subject.view
                        expect(view).to(haveValidSnapshot())
                    }
                }
            }
            context("iPad in portrait multitasking") {
                beforeEach {
                    let parent = UIView(frame: CGRect(x: 0, y: 0, width: 438, height: 1024))
                    subject.view.frame = parent.bounds
                    parent.addSubview(subject.view)
                    subject.view.layoutIfNeeded()
                    showView(parent)
                }
                describe("view") {
                    it("should match the screenshot") {
                        let view = subject.view
                        expect(view).to(haveValidSnapshot())
                    }
                }
            }
            context("iPhone5 in portrait") {
                beforeEach {
                    let parent = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 568))
                    subject.view.frame = parent.bounds
                    parent.addSubview(subject.view)
                    subject.view.layoutIfNeeded()
                    showView(parent)
                }
                describe("view") {
                    it("should match the screenshot") {
                        let view = subject.view
                        expect(view).to(haveValidSnapshot())
                    }
                }
            }
            context("iPhone6 in portrait") {
                beforeEach {
                    let parent = UIView(frame: CGRect(x: 0, y: 0, width: 375, height: 667))
                    subject.view.frame = parent.bounds
                    parent.addSubview(subject.view)
                    subject.view.layoutIfNeeded()
                    showView(parent)
                }
                describe("view") {
                    it("should match the screenshot") {
                        let view = subject.view
                        expect(view).to(haveValidSnapshot())
                    }
                }
            }
            context("iPhone6Plus in portrait") {
                beforeEach {
                    let parent = UIView(frame: CGRect(x: 0, y: 0, width: 414, height: 736))
                    subject.view.frame = parent.bounds
                    parent.addSubview(subject.view)
                    subject.view.layoutIfNeeded()
                    showView(parent)
                }
                describe("view") {
                    it("should match the screenshot") {
                        let view = subject.view
                        expect(view).to(haveValidSnapshot())
                    }
                }
            }
        }
    }
}
