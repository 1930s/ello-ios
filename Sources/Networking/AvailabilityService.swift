////
///  AvailabilityService.swift
//

import Moya
import SwiftyJSON

public typealias AvailabilitySuccessCompletion = (Availability) -> Void

public struct AvailabilityService {

    public init(){}

    func usernameAvailability(username: String, success: AvailabilitySuccessCompletion, failure: ElloFailureCompletion) {
        availability(["username": username], success: success, failure: failure)
    }

    func emailAvailability(email: String, success: AvailabilitySuccessCompletion, failure: ElloFailureCompletion) {
        availability(["email": email], success: success, failure: failure)
    }

    public func availability(content: [String: String], success: AvailabilitySuccessCompletion, failure: ElloFailureCompletion) {
        let endpoint = ElloAPI.Availability(content: content)
        ElloProvider.shared.elloRequest(endpoint,
            success: { data, _ in
                if let data = data as? Availability {
                    success(data)
                } else {
                    ElloProvider.unCastableJSONAble(failure)
                }
            },
            failure: failure)
    }
}
