////
///  ErrorStatusCode.swift
//

import Foundation

public enum ErrorStatusCode: Int {
    case Status401_Unauthorized = 401
    case Status403 = 403
    case Status404 = 404
    case Status410 = 410
    case Status420 = 420
    case Status422 = 422
    case Status500 = 500
    case Status502 = 502
    case Status503 = 503
    case StatusUnknown = 1_000_000

    var defaultData: NSData {
        return stubbedData(String(self.rawValue))
    }

    public var notification: TypedNotification<NSError> {
        switch self {
        case .StatusUnknown:
            return TypedNotification(name: "ElloProviderNotificationUnknown")
        default:
            return TypedNotification(name: "ElloProviderNotification\(self.rawValue)")
        }
    }
}
