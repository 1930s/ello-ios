////
///  S3UploadingService.swift
//

import Moya
import Foundation
import UIKit

public class S3UploadingService: NSObject {
    typealias S3UploadSuccessCompletion = (url: NSURL?) -> Void

    var uploader: ElloS3?

    func upload(image: UIImage, filename: String, success: S3UploadSuccessCompletion, failure: ElloFailureCompletion) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            if let data = UIImageJPEGRepresentation(image, 0.8) {
                // Head back to the thread the original caller was on before heading into the service calls. I may be overthinking it.
                nextTick {
                    self.upload(data, filename: filename, contentType: "image/jpeg", success: success, failure: failure)
                }
            }
        }
    }

    func upload(data: NSData, filename: String, contentType: String, success: S3UploadSuccessCompletion, failure: ElloFailureCompletion) {
        ElloProvider.shared.elloRequest(ElloAPI.AmazonCredentials,
            success: { credentialsData, responseConfig in
                if let credentials = credentialsData as? AmazonCredentials {
                    self.uploader = ElloS3(credentials: credentials, filename: filename, data: data, contentType: contentType)
                        .onSuccess({ (data: NSData) in
                            let endpoint: String = credentials.endpoint
                            let prefix: String = credentials.prefix
                            success(url: NSURL(string: "\(endpoint)/\(prefix)/\(filename)"))
                        })
                        .onFailure({ (error: NSError) in
                            _ = failure(error: error, statusCode: nil)
                        })
                        .start()
                }
                else {
                    ElloProvider.unCastableJSONAble(failure)
                }
            },
            failure: failure
        )
    }
}
