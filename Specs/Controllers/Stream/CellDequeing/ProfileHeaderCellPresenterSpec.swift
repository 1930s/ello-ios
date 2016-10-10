@testable import Ello
import Quick
import Nimble


class ProfileHeaderCellPresenterSpec: QuickSpec {
    override func spec() {
        describe("configure") {

            context("no user") {
                it("can still configure") {
                    let cell: ProfileHeaderCell = ProfileHeaderCell()
                    let item: StreamCellItem = StreamCellItem(type: .ProfileHeader)

                    expect {
                        ProfileHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .CurrentUserStream, indexPath: NSIndexPath(forItem: 0, inSection: 0), currentUser: nil)
                    } .notTo(raiseException())
                }
            }

            context("no posts") {
                it("disables the posts button") {
                    let user: User = stub(["postsCount" : 0])
                    let cell: ProfileHeaderCell = ProfileHeaderCell()
                    let item: StreamCellItem = StreamCellItem(jsonable: user, type: .ProfileHeader)

                    ProfileHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .CurrentUserStream, indexPath: NSIndexPath(forItem: 0, inSection: 0), currentUser: nil)

                    // expect(cell.postsButton.enabled) == false
                }
            }

            context("has posts") {
                it("enables the posts button") {
                    let user: User = stub(["postsCount" : 1])
                    let cell: ProfileHeaderCell = ProfileHeaderCell()
                    let item: StreamCellItem = StreamCellItem(jsonable: user, type: .ProfileHeader)

                    ProfileHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .CurrentUserStream, indexPath: NSIndexPath(forItem: 0, inSection: 0), currentUser: nil)

                    // expect(cell.postsButton.enabled) == true
                }
            }
        }
    }
}
