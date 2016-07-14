////
///  Comment.swift
//

import Crashlytics
import SwiftyJSON

let CommentVersion = 1

@objc(ElloComment)
public final class ElloComment: JSONAble, Authorable, Groupable {

    // active record
    public let id: String
    public let createdAt: NSDate
    // required
    public let authorId: String
    public let postId: String
    public var content: [Regionable]
    public var body: [Regionable]?
    // optional
    public var summary: [Regionable]?
    // links
    public var assets: [Asset]? {
        return getLinkArray("assets") as? [Asset]
    }
    public var author: User? {
        return ElloLinkedStore.sharedInstance.getObject(self.authorId, inCollection: MappingType.UsersType.rawValue) as? User
    }
    public var parentPost: Post? {
        return ElloLinkedStore.sharedInstance.getObject(self.postId, inCollection: MappingType.PostsType.rawValue) as? Post
    }
    public var loadedFromPost: Post? {
        return (ElloLinkedStore.sharedInstance.getObject(self.loadedFromPostId, inCollection: MappingType.PostsType.rawValue) as? Post) ?? parentPost
    }
    // computed properties
    public var groupId: String {
        get { return postId }
    }
    // to show hide in the stream, and for comment replies
    public var loadedFromPostId: String

// MARK: Initialization

    public init(id: String,
        createdAt: NSDate,
        authorId: String,
        postId: String,
        content: [Regionable])
    {
        self.id = id
        self.createdAt = createdAt
        self.authorId = authorId
        self.postId = postId
        self.loadedFromPostId = postId
        self.content = content
        self.loadedFromPostId = postId
        super.init(version: CommentVersion)
    }


// MARK: NSCoding

    public required init(coder aDecoder: NSCoder) {
        let decoder = Coder(aDecoder)
        // active record
        self.id = decoder.decodeKey("id")
        self.createdAt = decoder.decodeKey("createdAt")
        // required
        self.authorId = decoder.decodeKey("authorId")
        self.postId = decoder.decodeKey("postId")
        self.content = decoder.decodeKey("content")
        self.loadedFromPostId = decoder.decodeKey("loadedFromPostId")
        // optional
        self.body = decoder.decodeOptionalKey("body")
        self.summary = decoder.decodeOptionalKey("summary")
        super.init(coder: decoder.coder)
    }

    public override func encodeWithCoder(encoder: NSCoder) {
        let coder = Coder(encoder)
        // active record
        coder.encodeObject(id, forKey: "id")
        coder.encodeObject(createdAt, forKey: "createdAt")
        // required
        coder.encodeObject(authorId, forKey: "authorId")
        coder.encodeObject(postId, forKey: "postId")
        coder.encodeObject(content, forKey: "content")
        coder.encodeObject(loadedFromPostId, forKey: "loadedFromPostId")
        // optional
        coder.encodeObject(body, forKey: "body")
        coder.encodeObject(summary, forKey: "summary")
        super.encodeWithCoder(coder.coder)
    }

// MARK: JSONAble

    override class public func fromJSON(data: [String: AnyObject], fromLinked: Bool = false) -> JSONAble {
        let json = JSON(data)
        Crashlytics.sharedInstance().setObjectValue(json.rawString(), forKey: CrashlyticsKey.CommentFromJSON.rawValue)
        // create comment
        var createdAt: NSDate
        if let date = json["created_at"].stringValue.toNSDate() {
            // good to go
            createdAt = date
        }
        else {
            createdAt = NSDate()
            // send data to segment to try to get more data about this
            Tracker.sharedTracker.createdAtCrash("Comment", json: json.rawString())
        }
        let comment = ElloComment(
            id: json["id"].stringValue,
            createdAt: createdAt,
            authorId: json["author_id"].stringValue,
            postId: json["post_id"].stringValue,
            content: RegionParser.regions("content", json: json)
            )
        // optional
        comment.body = RegionParser.regions("body", json: json)
        comment.summary = RegionParser.regions("summary", json: json)
        // links
        comment.links = data["links"] as? [String: AnyObject]
        // store self in collection
        if !fromLinked {
            ElloLinkedStore.sharedInstance.setObject(comment, forKey: comment.id, inCollection: MappingType.CommentsType.rawValue)
        }
        return comment
    }

    public class func newCommentForPost(post: Post, currentUser: User) -> ElloComment {
        let comment = ElloComment(
            id: NSUUID().UUIDString,
            createdAt: NSDate(),
            authorId: currentUser.id,
            postId: post.id,
            content: [Regionable]()
        )
        return comment
    }
}
