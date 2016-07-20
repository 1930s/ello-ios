////
///  InviteControllerSpec.swift
//

import Ello
import Quick
import Nimble


class InviteCacheSpec: QuickSpec {
    override func spec() {
        describe("saveInvite") {
            it("saves the contact id to the cache") {
                let layer = FakePersistentLayer()
                let inviteCache = InviteCache(persistentLayer: layer)
                inviteCache.saveInvite("contact id")
                expect(layer.object?.last) == "contact id"
            }
        }

        describe("has") {
            context("contact has been saved") {
                it("returns true") {
                    let layer = FakePersistentLayer()
                    layer.object = ["something", "else"]
                    let inviteCache = InviteCache(persistentLayer: layer)
                    expect(inviteCache.has("else")).to(beTrue())
                }
            }

            context("contact has not been saved") {
                it("returns false") {
                    let layer = FakePersistentLayer()
                    layer.object = ["something", "else"]
                    let inviteCache = InviteCache(persistentLayer: layer)
                    expect(inviteCache.has("something else")).to(beFalse())
                }
            }
        }
    }
}
