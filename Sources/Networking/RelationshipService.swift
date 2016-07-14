////
///  RelationshipService.swift
//

import Moya
import SwiftyJSON

public class RelationshipService: NSObject {

    public func updateRelationship(
        currentUserId currentUserId: String,
        userId: String,
        relationshipPriority: RelationshipPriority,
        success: ElloSuccessCompletion,
        failure: ElloFailureCompletion)
    {

        // optimistic success
        let optimisticRelationship =
            Relationship(
                id: Tmp.uniqueName(),
                createdAt: NSDate(),
                ownerId: currentUserId,
                subjectId: userId
            )

        optimisticRelationship.subject?.relationshipPriority = relationshipPriority
        success(data: optimisticRelationship, responseConfig: ResponseConfig(isFinalValue: false))

        let endpoint = ElloAPI.Relationship(userId: userId, relationship: relationshipPriority.rawValue)
        ElloProvider.shared.elloRequest(endpoint, success: { (data, responseConfig) in
            Tracker.sharedTracker.relationshipStatusUpdated(relationshipPriority, userId: userId)
            success(data: data, responseConfig: responseConfig)
        }, failure: { (error, statusCode) in
            Tracker.sharedTracker.relationshipStatusUpdateFailed(relationshipPriority, userId: userId)
            failure(error: error, statusCode: statusCode)
        })
    }

    public func bulkUpdateRelationships(userIds userIds: [String], relationshipPriority: RelationshipPriority, success: ElloSuccessCompletion, failure: ElloFailureCompletion) {
        let endpoint = ElloAPI.RelationshipBatch(userIds: userIds, relationship: relationshipPriority.rawValue)
        ElloProvider.shared.elloRequest(endpoint,
            success: success,
            failure: failure
        )
    }
}
