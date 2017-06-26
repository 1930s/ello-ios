////
///  Editorial.swift
//

import SwiftyJSON

// Version 1: initial
let EditorialVersion = 3

final class Editorial: JSONAble, Groupable {
    typealias JoinInfo = (email: String?, username: String?, password: String?, submitted: Bool)
    typealias InviteInfo = (emails: String, sent: Bool)

    enum Kind: String {
        case post
        case postStream = "post_stream"
        case external
        case `internal`
        case invite
        case join
        case unknown
    }
    enum Size: String {
        case size1x1 = "one_by_one_image"
        // case size2x1 = "two_by_one_image"
        // case size1x2 = "one_by_two_image"
        case size2x2 = "two_by_two_image"

        static let all: [Size] = [size1x1, size2x2]
    }

    let id: String
    let title: String
    let subtitle: String?
    var join: JoinInfo?
    var invite: InviteInfo?
    let url: URL?
    let kind: Kind
    var groupId: String { return "Category-\(id)" }
    let postId: String?
    var post: Post? {
        guard let postId = postId else { return nil }
        return ElloLinkedStore.sharedInstance.getObject(postId, type: .postsType) as? Post
    }
    var postStreamURL: URL?
    var posts: [Post]?
    var images: [Size: Asset] = [:]

    init(
        id: String,
        kind: Kind,
        title: String,
        subtitle: String? = nil,
        postId: String? = nil,
        postStreamURL: URL? = nil,
        url: URL? = nil)
    {
        self.id = id
        self.kind = kind
        self.title = title
        self.subtitle = subtitle
        self.postId = postId
        self.postStreamURL = postStreamURL
        self.url = url
        super.init(version: EditorialVersion)
    }

    required init(coder: NSCoder) {
        let decoder = Coder(coder)
        id = decoder.decodeKey("id")
        kind = Kind(rawValue: decoder.decodeKey("kind")) ?? .post
        title = decoder.decodeKey("title")
        subtitle = decoder.decodeOptionalKey("subtitle")
        postId = decoder.decodeOptionalKey("postId")
        postStreamURL = decoder.decodeOptionalKey("postStreamURL")
        url = decoder.decodeOptionalKey("url")
        super.init(coder: coder)
    }

    override func encode(with coder: NSCoder) {
        let encoder = Coder(coder)
        encoder.encodeObject(id, forKey: "id")
        encoder.encodeObject(kind.rawValue, forKey: "kind")
        encoder.encodeObject(title, forKey: "title")
        encoder.encodeObject(subtitle, forKey: "subtitle")
        encoder.encodeObject(postId, forKey: "postId")
        encoder.encodeObject(postStreamURL, forKey: "postStreamURL")
        encoder.encodeObject(url, forKey: "url")
        super.encode(with: coder)
    }

    override class func fromJSON(_ data: [String: Any]) -> JSONAble {
        let json = JSON(data)
        let id = json["id"].stringValue
        let kind = Kind(rawValue: json["kind"].stringValue) ?? .unknown
        let title = json["title"].stringValue
        let subtitle = json["subtitle"].string
        let postId = json["links"]["post"]["id"].string
        let postStreamURL = json["links"]["post_stream"]["href"].string.flatMap { URL(string: $0) }
        let externalURL: URL? = json["url"].string.flatMap { URL(string: $0) }
        let internalURL: URL? = json["path"].string.flatMap { URL(string: "\(ElloURI.baseURL)\($0)") }

        let editorial = Editorial(
            id: id,
            kind: kind,
            title: title,
            subtitle: subtitle,
            postId: postId,
            postStreamURL: postStreamURL,
            url: externalURL ?? internalURL)
        editorial.links = data["links"] as? [String: Any]

        for size in Size.all {
            if let assetData = data[size.rawValue] as? [String: Any] {
                let asset = Asset.parseAsset("", node: assetData)
                editorial.images[size] = asset
            }
        }
        return editorial
    }
}

extension Editorial: JSONSaveable {
    var uniqueId: String? { return "Editorial-\(id)" }
    var tableId: String? { return id }
}
