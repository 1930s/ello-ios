////
///  StreamKindSpec.swift
//

import Ello
import Quick
import Nimble
import Moya


class StreamKindSpec: QuickSpec {

    override func spec() {

        describe("StreamKind") {

            // TODO: convert these tests to the looping input/output style used on other enums

            describe("name") {

                it("is correct for all cases") {
                    expect(StreamKind.Discover(type: .Featured).name) == "Discover"
                    expect(StreamKind.Following.name) == "Following"
                    expect(StreamKind.Starred.name) == "Starred"
                    expect(StreamKind.Notifications(category: "").name) == "Notifications"
                    expect(StreamKind.PostDetail(postParam: "param").name) == ""
                    expect(StreamKind.CurrentUserStream.name) == "Profile"
                    expect(StreamKind.SimpleStream(endpoint: ElloAPI.SearchForPosts(terms: "meat"), title: "meat").name) == "meat"
                    expect(StreamKind.Unknown.name) == ""
                    expect(StreamKind.UserStream(userParam: "n/a").name) == ""
                }
            }

            describe("cacheKey") {

                it("is correct for all cases") {
                    expect(StreamKind.Discover(type: .Featured).cacheKey) == "CategoryPosts"
                    expect(StreamKind.CategoryPosts(slug: "art").cacheKey) == "CategoryPosts"
                    expect(StreamKind.Following.cacheKey) == "Following"
                    expect(StreamKind.Starred.cacheKey) == "Starred"
                    expect(StreamKind.Notifications(category: "").cacheKey) == "Notifications"
                    expect(StreamKind.PostDetail(postParam: "param").cacheKey) == "PostDetail"
                    expect(StreamKind.CurrentUserStream.cacheKey) == "Profile"
                    expect(StreamKind.SimpleStream(endpoint: ElloAPI.SearchForPosts(terms: "meat"), title: "meat").cacheKey) == "SearchForPosts"
                    expect(StreamKind.SimpleStream(endpoint: ElloAPI.SearchForUsers(terms: "meat"), title: "meat").cacheKey) == "SimpleStream.meat"
                    expect(StreamKind.Unknown.cacheKey) == "unknown"
                    expect(StreamKind.UserStream(userParam: "NA").cacheKey) == "UserStream"
                }
            }

            describe("lastViewedCreatedAtKey") {

                it("is correct for all cases") {
                    expect(StreamKind.Discover(type: .Featured).lastViewedCreatedAtKey) == "CategoryPosts_createdAt"
                    expect(StreamKind.CategoryPosts(slug: "art").lastViewedCreatedAtKey) == "CategoryPosts_createdAt"
                    expect(StreamKind.Following.lastViewedCreatedAtKey) == "Following_createdAt"
                    expect(StreamKind.Starred.lastViewedCreatedAtKey) == "Starred_createdAt"
                    expect(StreamKind.Notifications(category: "").lastViewedCreatedAtKey) == "Notifications_createdAt"
                    expect(StreamKind.PostDetail(postParam: "param").lastViewedCreatedAtKey) == "PostDetail_createdAt"
                    expect(StreamKind.CurrentUserStream.lastViewedCreatedAtKey) == "Profile_createdAt"
                    expect(StreamKind.SimpleStream(endpoint: ElloAPI.SearchForPosts(terms: "meat"), title: "meat").lastViewedCreatedAtKey) == "SearchForPosts_createdAt"
                    expect(StreamKind.SimpleStream(endpoint: ElloAPI.SearchForUsers(terms: "meat"), title: "meat").lastViewedCreatedAtKey) == "SimpleStream.meat_createdAt"
                    expect(StreamKind.Unknown.lastViewedCreatedAtKey) == "unknown_createdAt"
                    expect(StreamKind.UserStream(userParam: "NA").lastViewedCreatedAtKey) == "UserStream_createdAt"
                }
            }

            describe("columnCount") {

                beforeEach {
                    StreamKind.Discover(type: .Featured).setIsGridView(false)
                    StreamKind.CategoryPosts(slug: "art").setIsGridView(false)
                    StreamKind.Following.setIsGridView(false)
                    StreamKind.Starred.setIsGridView(false)
                    StreamKind.Notifications(category: "").setIsGridView(false)
                    StreamKind.PostDetail(postParam: "param").setIsGridView(false)
                    StreamKind.CurrentUserStream.setIsGridView(false)
                    StreamKind.Following.setIsGridView(false)
                    StreamKind.SimpleStream(endpoint: ElloAPI.SearchForPosts(terms: "meat"), title: "meat").setIsGridView(false)
                    StreamKind.Unknown.setIsGridView(false)
                    StreamKind.UserStream(userParam: "NA").setIsGridView(false)
                }

                it("is correct for all cases") {
                    StreamKind.Discover(type: .Featured).setIsGridView(true)
                    expect(StreamKind.Discover(type: .Featured).columnCount) == 2

                    StreamKind.Discover(type: .Featured).setIsGridView(false)
                    expect(StreamKind.Discover(type: .Featured).columnCount) == 1

                    StreamKind.CategoryPosts(slug: "art").setIsGridView(true)
                    expect(StreamKind.CategoryPosts(slug: "art").columnCount) == 2

                    StreamKind.CategoryPosts(slug: "art").setIsGridView(false)
                    expect(StreamKind.CategoryPosts(slug: "art").columnCount) == 1

                    StreamKind.Following.setIsGridView(false)
                    expect(StreamKind.Following.columnCount) == 1

                    StreamKind.Following.setIsGridView(true)
                    expect(StreamKind.Following.columnCount) == 2

                    StreamKind.Starred.setIsGridView(true)
                    expect(StreamKind.Starred.columnCount) == 2

                    StreamKind.Starred.setIsGridView(false)
                    expect(StreamKind.Starred.columnCount) == 1

                    expect(StreamKind.Notifications(category: "").columnCount) == 1
                    expect(StreamKind.PostDetail(postParam: "param").columnCount) == 1
                    expect(StreamKind.CurrentUserStream.columnCount) == 1

                    StreamKind.SimpleStream(endpoint: ElloAPI.SearchForPosts(terms: "meat"), title: "meat").setIsGridView(true)
                    expect(StreamKind.SimpleStream(endpoint: ElloAPI.SearchForPosts(terms: "meat"), title: "meat").columnCount) == 2

                    StreamKind.SimpleStream(endpoint: ElloAPI.SearchForPosts(terms: "meat"), title: "meat").setIsGridView(false)
                    expect(StreamKind.SimpleStream(endpoint: ElloAPI.SearchForUsers(terms: "meat"), title: "meat").columnCount) == 1

                    expect(StreamKind.Unknown.columnCount) == 1
                    expect(StreamKind.UserStream(userParam: "NA").columnCount) == 1
                }
            }

            describe("showsCategory") {
                let expectations: [(StreamKind, Bool)] = [
                    (.CurrentUserStream, false),
                    (.AllCategories, false),
                    (.Discover(type: .Featured), true),
                    (.Discover(type: .Trending), false),
                    (.Discover(type: .Recent), false),
                    (.CategoryPosts(slug: "art"), false),
                    (.Following, false),
                    (.Starred, false),
                    (.Notifications(category: nil), false),
                    (.Notifications(category: "comments"), false),
                    (.PostDetail(postParam: "postId"), false),
                    (.UserStream(userParam: "userId"), false),
                    (.Unknown, false),
                ]
                for (streamKind, expectedValue) in expectations {
                    it("\(streamKind) \(expectedValue ? "can" : "cannot") show category") {
                        expect(streamKind.showsCategory) == expectedValue
                    }
                }
            }

            describe("tappingTextOpensDetail in grid view") {
                let expectations: [(StreamKind, Bool)] = [
                    (.Discover(type: .Featured), true),
                    (.CategoryPosts(slug: "art"), true),
                    (.Following, true),
                    (.Starred, true),
                    (.Notifications(category: ""), true),
                    (.PostDetail(postParam: "param"), false),
                    (.CurrentUserStream, true),
                    (.SimpleStream(endpoint: ElloAPI.SearchForPosts(terms: "meat"), title: "meat"), true),
                    (.Unknown, true),
                    (.UserStream(userParam: "NA"), true),
                ]
                for (streamKind, expected) in expectations {
                    it("is \(expected) for \(streamKind) in grid view") {
                        let wasInGrid = streamKind.isGridView
                        streamKind.setIsGridView(true)
                        expect(streamKind.tappingTextOpensDetail) == expected
                        streamKind.setIsGridView(wasInGrid)
                    }
                }
            }

            describe("isProfileStream") {
                let expectations: [(StreamKind, Bool)] = [
                    (.Discover(type: .Featured), false),
                    (.CategoryPosts(slug: "art"), false),
                    (.Following, false),
                    (.Starred, false),
                    (.Notifications(category: ""), false),
                    (.PostDetail(postParam: "param"), false),
                    (.CurrentUserStream, true),
                    (.SimpleStream(endpoint: ElloAPI.SearchForPosts(terms: "meat"), title: "meat"), false),
                    (.Unknown, false),
                    (.UserStream(userParam: "NA"), true),
                ]
                for (streamKind, expected) in expectations {
                    it("is \(expected) for \(streamKind)") {
                        expect(streamKind.isProfileStream) == expected
                    }
                }
            }

            describe("endpoint") {

                it("is correct for all cases") {
                    expect(StreamKind.Discover(type: .Featured).endpoint.path) == "/api/\(ElloAPI.apiVersion)/categories/posts/recent"
                    expect(StreamKind.CategoryPosts(slug: "art").endpoint.path) == "/api/\(ElloAPI.apiVersion)/categories/art/posts/recent"
                    expect(StreamKind.Following.endpoint.path) == "/api/\(ElloAPI.apiVersion)/streams/friend"
                    expect(StreamKind.Starred.endpoint.path) == "/api/\(ElloAPI.apiVersion)/streams/noise"
                    expect(StreamKind.Notifications(category: "").endpoint.path) == "/api/\(ElloAPI.apiVersion)/notifications"
                    expect(StreamKind.PostDetail(postParam: "param").endpoint.path) == "/api/\(ElloAPI.apiVersion)/posts/param"
                    expect(StreamKind.PostDetail(postParam: "param").endpoint.parameters!["comment_count"] as? Bool) == true
                    expect(StreamKind.CurrentUserStream.endpoint.path) == "/api/\(ElloAPI.apiVersion)/profile"
                    expect(StreamKind.SimpleStream(endpoint: ElloAPI.SearchForPosts(terms: "meat"), title: "meat").endpoint.path) == "/api/\(ElloAPI.apiVersion)/posts"
                    expect(StreamKind.SimpleStream(endpoint: ElloAPI.SearchForUsers(terms: "meat"), title: "meat").endpoint.path) == "/api/\(ElloAPI.apiVersion)/users"
                    expect(StreamKind.Unknown.endpoint.path) == "/api/\(ElloAPI.apiVersion)/notifications"
                    expect(StreamKind.UserStream(userParam: "NA").endpoint.path) == "/api/\(ElloAPI.apiVersion)/users/NA"
                }
            }

            describe("relationship") {

                it("is correct for all cases") {
                    expect(StreamKind.Discover(type: .Featured).relationship) == RelationshipPriority.Null
                    expect(StreamKind.CategoryPosts(slug: "art").relationship) == RelationshipPriority.Null
                    expect(StreamKind.Following.relationship) == RelationshipPriority.Following
                    expect(StreamKind.Starred.relationship) == RelationshipPriority.Starred
                    expect(StreamKind.Notifications(category: "").relationship) == RelationshipPriority.Null
                    expect(StreamKind.PostDetail(postParam: "param").relationship) == RelationshipPriority.Null
                    expect(StreamKind.CurrentUserStream.relationship) == RelationshipPriority.Null
                    expect(StreamKind.SimpleStream(endpoint: ElloAPI.SearchForPosts(terms: "meat"), title: "meat").relationship) == RelationshipPriority.Null
                    expect(StreamKind.Unknown.relationship) == RelationshipPriority.Null
                    expect(StreamKind.UserStream(userParam: "NA").relationship) == RelationshipPriority.Null
                }
            }

            describe("filter(_:viewsAdultContent:)") {
                // important but time consuming to implement this one, little by little!
                context("Discover") {

                    var postJsonables: [JSONAble] = []
                    var userJsonables: [JSONAble] = []

                    // trending is users, everything else are posts
                    beforeEach {
                        let post1 = Post.stub(["id": "post1", "isAdultContent" : true])
                        let post2 = Post.stub(["id": "post2"])
                        let post3 = Post.stub(["id": "post3"])

                        let user1 = User.stub(["mostRecentPost": post1])
                        let user2 = User.stub(["mostRecentPost": post2])
                        let user3 = User.stub(["mostRecentPost": post3])

                        postJsonables = [post1, post2, post3]
                        userJsonables = [user1, user2, user3]
                    }

                    context("Discover(recommended)") {
                        it("returns the correct posts regardless of views adult content") {
                            let kind = StreamKind.Discover(type: .Featured)
                            var filtered = kind.filter(postJsonables, viewsAdultContent: false) as! [Post]

                            expect(filtered.count) == 3
                            expect(filtered[0].id) == "post1"
                            expect(filtered[1].id) == "post2"
                            expect(filtered[2].id) == "post3"

                            filtered = kind.filter(postJsonables, viewsAdultContent: true) as! [Post]

                            expect(filtered.count) == 3
                            expect(filtered[0].id) == "post1"
                            expect(filtered[1].id) == "post2"
                            expect(filtered[2].id) == "post3"
                        }
                    }

                    context("Discover(trending)") {
                        it("returns the correct posts regardless of views adult content") {
                            let kind = StreamKind.Discover(type: .Trending)
                            var filtered = kind.filter(userJsonables, viewsAdultContent: false) as! [Post]

                            expect(filtered.count) == 3
                            expect(filtered[0].id) == "post1"
                            expect(filtered[1].id) == "post2"
                            expect(filtered[2].id) == "post3"

                            filtered = kind.filter(userJsonables, viewsAdultContent: true) as! [Post]

                            expect(filtered.count) == 3
                            expect(filtered[0].id) == "post1"
                            expect(filtered[1].id) == "post2"
                            expect(filtered[2].id) == "post3"
                        }
                    }

                    context("Discover(recent)") {
                        it("returns the correct posts regardless of views adult content") {
                            let kind = StreamKind.Discover(type: .Recent)
                            var filtered = kind.filter(postJsonables, viewsAdultContent: false) as! [Post]

                            expect(filtered.count) == 3
                            expect(filtered[0].id) == "post1"
                            expect(filtered[1].id) == "post2"
                            expect(filtered[2].id) == "post3"

                            filtered = kind.filter(postJsonables, viewsAdultContent: true) as! [Post]

                            expect(filtered.count) == 3
                            expect(filtered[0].id) == "post1"
                            expect(filtered[1].id) == "post2"
                            expect(filtered[2].id) == "post3"
                        }
                    }
                }
            }

            describe("showStarButton") {

                let tests: [(Bool, StreamKind)] = [
                    (true, StreamKind.Discover(type: .Featured)),
                    (true, StreamKind.CategoryPosts(slug: "art")),
                    (true, StreamKind.Following),
                    (true, StreamKind.Starred),
                    (false, StreamKind.Notifications(category: "")),
                    (true, StreamKind.PostDetail(postParam: "param")),
                    (true, StreamKind.CurrentUserStream),
                    (true, StreamKind.Unknown),
                    (true, StreamKind.UserStream(userParam: "NA")),
                    (true, StreamKind.SimpleStream(endpoint: ElloAPI.SearchForPosts(terms: "meat"), title: "meat")),
                    (true, StreamKind.SimpleStream(endpoint: ElloAPI.UserStreamFollowers(userId: "12345"), title: "")),
                ]
                for (shouldStar, streamKind) in tests {
                    it("is \(shouldStar) for \(streamKind)") {
                        expect(streamKind.showStarButton) == shouldStar
                    }
                }
            }

            describe("isGridView") {

                beforeEach {
                    StreamKind.Discover(type: .Featured).setIsGridView(false)
                    StreamKind.CategoryPosts(slug: "art").setIsGridView(false)
                    StreamKind.Following.setIsGridView(false)
                    StreamKind.Starred.setIsGridView(false)
                    StreamKind.Notifications(category: "").setIsGridView(false)
                    StreamKind.PostDetail(postParam: "param").setIsGridView(false)
                    StreamKind.CurrentUserStream.setIsGridView(false)
                    StreamKind.Following.setIsGridView(false)
                    StreamKind.SimpleStream(endpoint: ElloAPI.SearchForPosts(terms: "meat"), title: "meat").setIsGridView(false)
                    StreamKind.SimpleStream(endpoint: ElloAPI.Loves(userId: "123"), title: "123").setIsGridView(false)
                    StreamKind.Unknown.setIsGridView(false)
                    StreamKind.UserStream(userParam: "NA").setIsGridView(false)
                }


                it("is correct for all cases") {
                    StreamKind.Discover(type: .Featured).setIsGridView(true)
                    expect(StreamKind.Discover(type: .Featured).isGridView) == true

                    StreamKind.Discover(type: .Featured).setIsGridView(false)
                    expect(StreamKind.Discover(type: .Featured).isGridView) == false

                    StreamKind.CategoryPosts(slug: "art").setIsGridView(true)
                    expect(StreamKind.CategoryPosts(slug: "art").isGridView) == true

                    StreamKind.CategoryPosts(slug: "art").setIsGridView(false)
                    expect(StreamKind.CategoryPosts(slug: "art").isGridView) == false

                    StreamKind.Following.setIsGridView(false)
                    expect(StreamKind.Following.isGridView) == false

                    StreamKind.Following.setIsGridView(true)
                    expect(StreamKind.Following.isGridView) == true

                    StreamKind.Starred.setIsGridView(true)
                    expect(StreamKind.Starred.isGridView) == true

                    StreamKind.Starred.setIsGridView(false)
                    expect(StreamKind.Starred.isGridView) == false

                    expect(StreamKind.Notifications(category: "").isGridView) == false
                    expect(StreamKind.PostDetail(postParam: "param").isGridView) == false
                    expect(StreamKind.CurrentUserStream.isGridView) == false

                    StreamKind.SimpleStream(endpoint: ElloAPI.SearchForPosts(terms: "meat"), title: "meat").setIsGridView(true)
                    expect(StreamKind.SimpleStream(endpoint: ElloAPI.SearchForPosts(terms: "meat"), title: "meat").isGridView) == true

                    StreamKind.SimpleStream(endpoint: ElloAPI.SearchForPosts(terms: "meat"), title: "meat").setIsGridView(false)
                    expect(StreamKind.SimpleStream(endpoint: ElloAPI.SearchForPosts(terms: "meat"), title: "meat").isGridView) == false

                    StreamKind.SimpleStream(endpoint: ElloAPI.Loves(userId: "123"), title: "123").setIsGridView(true)
                    expect(StreamKind.SimpleStream(endpoint: ElloAPI.Loves(userId: "123"), title: "123").isGridView) == true

                    StreamKind.SimpleStream(endpoint: ElloAPI.Loves(userId: "123"), title: "123").setIsGridView(false)
                    expect(StreamKind.SimpleStream(endpoint: ElloAPI.Loves(userId: "123"), title: "123").isGridView) == false

                    expect(StreamKind.SimpleStream(endpoint: ElloAPI.SearchForUsers(terms: "meat"), title: "meat").isGridView) == false
                    expect(StreamKind.Unknown.isGridView) == false
                    expect(StreamKind.UserStream(userParam: "NA").isGridView) == false
                }
            }

            describe("hasGridViewToggle") {

                it("is correct for all cases") {
                    expect(StreamKind.Discover(type: .Featured).hasGridViewToggle) == true
                    expect(StreamKind.CategoryPosts(slug: "art").hasGridViewToggle) == true
                    expect(StreamKind.Following.hasGridViewToggle) == true
                    expect(StreamKind.Starred.hasGridViewToggle) == true
                    expect(StreamKind.Notifications(category: "").hasGridViewToggle) == false
                    expect(StreamKind.PostDetail(postParam: "param").hasGridViewToggle) == false
                    expect(StreamKind.CurrentUserStream.hasGridViewToggle) == false
                    expect(StreamKind.SimpleStream(endpoint: ElloAPI.SearchForPosts(terms: "meat"), title: "meat").hasGridViewToggle) == true
                    expect(StreamKind.SimpleStream(endpoint: ElloAPI.Loves(userId: "123"), title: "123").hasGridViewToggle) == true
                    expect(StreamKind.SimpleStream(endpoint: ElloAPI.SearchForUsers(terms: "meat"), title: "meat").hasGridViewToggle) == false
                    expect(StreamKind.Unknown.hasGridViewToggle) == false
                    expect(StreamKind.UserStream(userParam: "NA").hasGridViewToggle) == false
                }
            }

            describe("avatarHeight") {

                it("is correct for list mode") {
                    StreamKind.Following.setIsGridView(false)
                    expect(StreamKind.Following.avatarHeight) == 40
                }

                it("is correct for grid mode") {
                    StreamKind.Following.setIsGridView(true)
                    expect(StreamKind.Following.avatarHeight) == 30
                }
            }

            describe("contentForPost(:_)") {
                var post: Post!

                beforeEach {
                    post = Post.stub([
                        "id" : "768",
                        "content" : [TextRegion.stub([:]), TextRegion.stub([:])],
                        "summary" : [TextRegion.stub([:])]
                    ])
                }


                it("is correct for list mode") {
                    StreamKind.Following.setIsGridView(false)
                    expect(StreamKind.Following.contentForPost(post)?.count) == 2
                }

                it("is correct for grid mode") {
                    StreamKind.Following.setIsGridView(true)
                    expect(StreamKind.Following.contentForPost(post)?.count) == 1
                }
            }

            describe("isDetail") {

                it("is correct for all cases") {
                    expect(StreamKind.Discover(type: .Featured).isDetail) == false
                    expect(StreamKind.CategoryPosts(slug: "art").isDetail) == false
                    expect(StreamKind.Following.isDetail) == false
                    expect(StreamKind.Starred.isDetail) == false
                    expect(StreamKind.Notifications(category: "").isDetail) == false
                    expect(StreamKind.PostDetail(postParam: "param").isDetail) == true
                    expect(StreamKind.CurrentUserStream.isDetail) == false
                    expect(StreamKind.SimpleStream(endpoint: ElloAPI.SearchForPosts(terms: "meat"), title: "meat").isDetail) == false
                    expect(StreamKind.SimpleStream(endpoint: ElloAPI.SearchForUsers(terms: "meat"), title: "meat").isDetail) == false
                    expect(StreamKind.Unknown.isDetail) == false
                    expect(StreamKind.UserStream(userParam: "NA").isDetail) == false
                }
            }

            describe("supportsLargeImages") {

                it("is correct for all cases") {
                    expect(StreamKind.Discover(type: .Featured).supportsLargeImages) == false
                    expect(StreamKind.CategoryPosts(slug: "art").supportsLargeImages) == false
                    expect(StreamKind.Following.supportsLargeImages) == false
                    expect(StreamKind.Starred.supportsLargeImages) == false
                    expect(StreamKind.Notifications(category: "").supportsLargeImages) == false
                    expect(StreamKind.PostDetail(postParam: "param").supportsLargeImages) == true
                    expect(StreamKind.CurrentUserStream.supportsLargeImages) == false
                    expect(StreamKind.SimpleStream(endpoint: ElloAPI.SearchForPosts(terms: "meat"), title: "meat").supportsLargeImages) == false
                    expect(StreamKind.SimpleStream(endpoint: ElloAPI.SearchForUsers(terms: "meat"), title: "meat").supportsLargeImages) == false
                    expect(StreamKind.Unknown.supportsLargeImages) == false
                    expect(StreamKind.UserStream(userParam: "NA").supportsLargeImages) == false
                }
            }
        }
    }
}
