////
///  SearchViewControllerSpec.swift
//

import Ello
import Quick
import Nimble



class SearchMockScreen: NSObject, SearchScreenProtocol {
    var delegate: SearchScreenDelegate?
    var hasBackButton: Bool = true
    var hasGridViewToggle: Bool = false
    var gridListItem: UIBarButtonItem?

    func viewForStream() -> UIView {
        return UIView()
    }

    func updateInsets(bottom bottom: CGFloat) {
    }

}

//public class TestTracker: Tracker {
//    public var searchCalledWith: String = ""
//    override public func searchFor(term: String) {
//        searchCalledWith = term
//    }
//}

class SearchViewControllerSpec: QuickSpec {
    override func spec() {

//        var subject = SearchViewController()
//
//        describe("SearchViewController") {
//
//            describe("trackSearch(_:isPostSearch:)") {
//
//                beforeEach {
//                    Tracker.sharedTracker = TestTracker()
//                }
//
//                context("user search") {
//
//                    it("tracks properly") {
//                        subject.trackSearch("username", isPostSearch: false)
//                        expect((Tracker.sharedTracker as? TestTracker)?.searchCalledWith) == "users"
//                    }
//
//                }
//
//                context("post search") {
//
//                    it("tracks properly") {
//                        subject.trackSearch("posts", isPostSearch: true)
//                        expect((Tracker.sharedTracker as? TestTracker)?.searchCalledWith) == "posts"
//                    }
//
//                }
//
//                context("hashtag search") {
//
//                    it("tracks properly") {
//                        subject.trackSearch("#posts", isPostSearch: true)
//                        expect((Tracker.sharedTracker as? TestTracker)?.searchCalledWith) == "hashtags"
//                    }
//
//                }
//            }
//
//        }
    }
}
