//
//  RelationshipControlSpec.swift
//  Ello
//
//  Created by Ryan Boyajian on 2/20/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

@testable import Ello
import Quick
import Nimble
import Moya
import Nimble_Snapshots


class RelationshipControlSpec: QuickSpec {
    override func spec() {
        describe("RelationshipControl") {
            let subject = RelationshipControl()
            var presentingController = UIViewController()
            showController(presentingController)
            var relationshipController = RelationshipController(presentingController: presentingController)

            describe("@relationship") {

                it("sets button state properly when set to friend") {
                    subject.relationshipPriority = .Following
                    expect(subject.followingButton.currentTitle) == "Following"
                    expect(subject.followingButton.backgroundColor) == UIColor.blackColor()
                }

                it("sets button state properly when set to noise") {
                    subject.relationshipPriority = .Starred
                    expect(subject.followingButton.currentTitle) == "Starred"
                    expect(subject.followingButton.backgroundColor) == UIColor.blackColor()
                }

                it("sets button state properly when set to mute") {
                    subject.relationshipPriority = .Mute
                    expect(subject.followingButton.currentTitle) == "Muted"
                    expect(subject.followingButton.backgroundColor) == UIColor.redColor()
                }

                it("sets button state properly when set to anything else") {
                    for relationshipPriority in [RelationshipPriority.Inactive, RelationshipPriority.None, RelationshipPriority.Null, RelationshipPriority.Me] {
                        subject.relationshipPriority = relationshipPriority
                        expect(subject.followingButton.currentTitle) == "Follow"
                        expect(subject.followingButton.backgroundColor) == UIColor.whiteColor()
                    }
                }
            }

            describe("intrinsicContentSize()") {
                it("should calculate when showStarredButton=false") {
                    subject.showStarredButton = false
                    let expectedSize = CGSize(width: 105, height: 30)
                    expect(subject.intrinsicContentSize()) == expectedSize
                    subject.frame = CGRect(origin: CGPointZero, size: expectedSize)
                    subject.layoutIfNeeded()
                    expect(subject.starredButton.frame) == CGRectZero
                    expect(subject.followingButton.frame) == CGRect(x: 0, y: 0, width: 105, height: 30)
                    expect(subject).to(recordSnapshot())
                }
                it("should calculate when showStarredButton=true") {
                    subject.showStarredButton = true
                    let expectedSize = CGSize(width: 142, height: 30)
                    expect(subject.intrinsicContentSize()) == expectedSize
                    subject.frame = CGRect(origin: CGPointZero, size: expectedSize)
                    subject.layoutIfNeeded()
                    expect(subject.starredButton.frame) == CGRect(x: 112, y: 0, width: 30, height: 30)
                    expect(subject.followingButton.frame) == CGRect(x: 0, y: 0, width: 105, height: 30)
                    expect(subject).to(recordSnapshot())
                }
            }

            describe("button targets") {

                beforeEach {
                    presentingController = UIViewController()
                    showController(presentingController)
                    relationshipController = RelationshipController(presentingController: presentingController)
                    subject.relationshipDelegate = relationshipController
                }

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
                                    subject.starredButton.sendActionsForControlEvents(.TouchUpInside)
                                    expect(subject.relationshipPriority) == RelationshipPriority.Starred
                                }
                            }
                        }

                        context("RelationshipPriority.Following") {

                            it("stars the user") {
                                subject.relationshipPriority = .Following
                                subject.starredButton.sendActionsForControlEvents(.TouchUpInside)
                                expect(subject.relationshipPriority) == RelationshipPriority.Starred
                            }
                        }

                        context("RelationshipPriority.Starred") {

                            it("unstars the user") {
                                subject.relationshipPriority = .Starred
                                subject.starredButton.sendActionsForControlEvents(.TouchUpInside)
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
                            let presentedVC = relationshipController.presentingController.presentedViewController as? BlockUserModalViewController
                            expect(presentedVC).notTo(beNil())
                        }
                    }
                }
            }
        }
    }
}
