////
///  RelationshipControlSpec.swift
//

@testable import Ello
import Quick
import Nimble
import Moya
import Nimble_Snapshots


class RelationshipControlSpec: QuickSpec {
    override func spec() {
        describe("RelationshipControl") {
            var subject: RelationshipControl!
            var presentingController: UIViewController!
            var relationshipController: RelationshipController!
            beforeEach {
                subject = RelationshipControl()
                presentingController = UIViewController()
                showController(presentingController)
                relationshipController = RelationshipController(presentingController: presentingController)
                subject.relationshipDelegate = relationshipController
            }

            describe("snapshots") {
                let relationships: [(RelationshipControlStyle, RelationshipPriority)] = [
                    (.Default, .Following),
                    (.Default, .Starred),
                    (.Default, .Mute),
                    (.Default, .None),
                    (.ProfileView, .Following),
                    (.ProfileView, .Starred),
                    (.ProfileView, .Mute),
                    (.ProfileView, .None),
                ]
                for (style, relationship) in relationships {
                    it("setting style to \(style) and relationshipPriority to \(relationship)") {
                        subject.style = style
                        subject.relationshipPriority = relationship
                        expectValidSnapshot(subject, named: "style_\(style)_relationshipPriority_\(relationship)", device: .Custom(subject.intrinsicContentSize()))
                    }
                }
            }

            describe("intrinsicContentSize()") {
                it("should calculate when showStarButton=false") {
                    subject.showStarButton = false
                    let expectedSize = CGSize(width: 105, height: 30)
                    expect(subject.intrinsicContentSize()) == expectedSize
                    subject.frame = CGRect(origin: CGPointZero, size: expectedSize)
                    subject.layoutIfNeeded()
                    expect(subject.starButton.frame) == CGRectZero
                    expect(subject.followingButton.frame) == CGRect(x: 0, y: 0, width: 105, height: 30)
                }
                it("should calculate when showStarButton=true") {
                    subject.showStarButton = true
                    let expectedSize = CGSize(width: 142, height: 30)
                    expect(subject.intrinsicContentSize()) == expectedSize
                    subject.frame = CGRect(origin: CGPointZero, size: expectedSize)
                    subject.layoutIfNeeded()
                    expect(subject.starButton.frame) == CGRect(x: 112, y: 0, width: 30, height: 30)
                    expect(subject.followingButton.frame) == CGRect(x: 0, y: 0, width: 105, height: 30)
                }
            }

            describe("button targets") {

                context("not muted") {

                    describe("tapping the following button") {

                        for relationshipPriority in [RelationshipPriority.Inactive, RelationshipPriority.None, RelationshipPriority.Null] {
                            context("RelationshipPriority.\(relationshipPriority)") {

                                it("unfollows the user") {
                                    subject.relationshipPriority = relationshipPriority
                                    subject.followingButton.sendActionsForControlEvents(.TouchUpInside)
                                    expect(subject.relationshipPriority) == RelationshipPriority.Following
                                }
                            }
                        }

                        context("RelationshipPriority.Following") {

                            it("unfollows the user") {
                                subject.relationshipPriority = .Following
                                subject.followingButton.sendActionsForControlEvents(.TouchUpInside)
                                expect(subject.relationshipPriority) == RelationshipPriority.Inactive
                            }
                        }

                        context("RelationshipPriority.Starred") {

                            it("unstars the user") {
                                subject.relationshipPriority = .Starred
                                subject.followingButton.sendActionsForControlEvents(.TouchUpInside)
                                expect(subject.relationshipPriority) == RelationshipPriority.Following
                            }
                        }
                    }

                    describe("tapping the starred button") {

                        for relationshipPriority in [RelationshipPriority.Inactive, RelationshipPriority.None, RelationshipPriority.Null] {
                            context("RelationshipPriority.\(relationshipPriority)") {

                                it("stars the user") {
                                    subject.relationshipPriority = relationshipPriority
                                    subject.starButton.sendActionsForControlEvents(.TouchUpInside)
                                    expect(subject.relationshipPriority) == RelationshipPriority.Starred
                                }
                            }
                        }

                        context("RelationshipPriority.Following") {

                            it("stars the user") {
                                subject.relationshipPriority = .Following
                                subject.starButton.sendActionsForControlEvents(.TouchUpInside)
                                expect(subject.relationshipPriority) == RelationshipPriority.Starred
                            }
                        }

                        context("RelationshipPriority.Starred") {

                            it("unstars the user") {
                                subject.relationshipPriority = .Starred
                                subject.starButton.sendActionsForControlEvents(.TouchUpInside)
                                expect(subject.relationshipPriority) == RelationshipPriority.Following
                            }
                        }
                    }
                }

                context("muted") {

                    describe("tapping the main button") {

                        it("launches the block modal") {
                            subject.relationshipPriority = .Mute
                            subject.followingButton.sendActionsForControlEvents(.TouchUpInside)
                            let presentedVC = relationshipController.presentingController?.presentedViewController as? BlockUserModalViewController
                            expect(presentedVC).notTo(beNil())
                        }
                    }
                }
            }
        }
    }
}
