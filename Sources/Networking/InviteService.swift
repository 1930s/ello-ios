////
///  InviteService.swift
//

import Moya
import SwiftyJSON

public typealias InviteFriendsSuccessCompletion = () -> Void
public typealias FindFriendsSuccessCompletion = ([User]) -> Void

public struct InviteService {

    public init(){}

    public func invite(contact: String, success: InviteFriendsSuccessCompletion, failure: ElloFailureCompletion) {
        ElloProvider.shared.elloRequest(ElloAPI.InviteFriends(contact: contact),
            success: { _ in success() },
            failure: failure)
    }

    public func find(contacts: [String: [String]], currentUser: User?, success: FindFriendsSuccessCompletion, failure: ElloFailureCompletion) {
        ElloProvider.shared.elloRequest(ElloAPI.FindFriends(contacts: contacts),
            success: { (data, responseConfig) in
                if let data = data as? [User] {
                    success(InviteService.filterUsers(data, currentUser: currentUser))
                }
                else {
                    ElloProvider.unCastableJSONAble(failure)
                }
            }, failure: failure)
    }

    static func filterUsers(users: [User], currentUser: User?) -> [User] {
        return users.filter { $0.identifiableBy != .None && $0.id != currentUser?.id }
    }

}
