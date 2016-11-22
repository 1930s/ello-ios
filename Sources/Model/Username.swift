////
///  Username.swift
//

import SwiftyJSON

let UsernameVersion: Int = 1

@objc(Username)
public final class Username: JSONAble {
    public let username: String
    public var atName: String { return "@\(username)"}

    public init(username: String) {
        self.username = username
        super.init(version: UsernameVersion)
    }

    public required init(coder: NSCoder) {
        let decoder = Coder(coder)
        self.username = decoder.decodeKey("username")
        super.init(coder: coder)
    }

    public override func encodeWithCoder(coder: NSCoder) {
        let encoder = Coder(coder)
        encoder.encodeObject(username, forKey: "username")
        super.encodeWithCoder(coder)
    }

    override public class func fromJSON(data: [String: AnyObject]) -> JSONAble {
        let json = JSON(data)
        return Username(username: json["username"].stringValue)
    }

}
