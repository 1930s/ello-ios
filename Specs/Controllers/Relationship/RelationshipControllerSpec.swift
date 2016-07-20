////
///  RelationshipControllerSpec.swift
//

import Ello
import Quick
import Nimble
import Moya


class RelationshipControllerSpec: QuickSpec {
    override func spec() {
        var subject = RelationshipController(presentingController: UIViewController())

        beforeEach({
            let presentingController = UIViewController()
            showController(presentingController)
            subject = RelationshipController(presentingController: presentingController)

        })

        context("RelationshipDelegate") {

            describe("-relationshipTapped:relationship:complete:") {
                // extensively tested in RelationshipControlSpec
            }

            describe("-updateRelationship:relationship:complete:") {

                it("succeeds") {
                    var expectedStatus = RelationshipRequestStatus.Failure

                    subject.updateRelationship("", userId: "test-user-id", prev: .None, relationshipPriority: RelationshipPriority.Following) {
                        (status, _, _) in
                        expectedStatus = status
                    }
                    expect(expectedStatus).to(equal(RelationshipRequestStatus.Success))
                }

                it("fails") {
                    ElloProvider.sharedProvider = ElloProvider.ErrorStubbingProvider()

                    var expectedStatus = RelationshipRequestStatus.Success

                    subject.updateRelationship("", userId: "test-user-id", prev: .None, relationshipPriority: RelationshipPriority.Following) {
                        (status, _, _) in
                        expectedStatus = status
                    }
                    expect(expectedStatus).to(equal(RelationshipRequestStatus.Failure))
                }
            }

            describe("-launchBlockModal:userAtName:relationship:changeClosure:") {

                it("launches the block user modal view controller") {
                    subject.launchBlockModal("user-id", userAtName: "@666", relationshipPriority: RelationshipPriority.Following) {
                        _ in
                    }
                    let presentedVC = subject.presentingController.presentedViewController as! BlockUserModalViewController
                    // TODO: figure this out
//                    expect(presentedVC.relationshipDelegate).to(beIdenticalTo(subject))
                    expect(presentedVC).to(beAKindOf(BlockUserModalViewController.self))
                }

            }

        }
    }
}
