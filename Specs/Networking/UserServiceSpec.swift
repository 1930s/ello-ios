////
///  UserServiceSpec.swift
//

import Foundation

import Ello
import Quick
import Moya
import Nimble


class UserServiceSpec: QuickSpec {
    override func spec() {
        var subject = UserService()

        describe("-join") {

            context("success") {

                it("Calls success with a User") {
                    var loadedUser: User?

                    subject.join(email: "fake@example.com",
                        username: "fake-username",
                        password: "fake-password",
                        invitationCode: .None,
                        success: {
                            (user, responseConfig) in
                            loadedUser = user
                        }, failure: .None)

                    expect(loadedUser).toNot(beNil())

                    //smoke test the user
                    expect(loadedUser!.userId) == "1"
                    expect(loadedUser!.email) == "sterling@isisagency.com"
                    expect(loadedUser!.username) == "archer"
                }
            }

            xcontext("failure") {}

        }
    }
}
