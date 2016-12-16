////
///  RePostService.swift
//

public class RePostService {
    typealias RePostSuccessCompletion = (repost: Post) -> Void

    func repost(post post: Post, success: RePostSuccessCompletion, failure: ElloFailureCompletion) {
        let endpoint = ElloAPI.RePost(postId: post.id)
        ElloProvider.shared.elloRequest(endpoint,
            success: { data, responseConfig in
                if let repost = data as? Post {
                    success(repost: repost)
                }
                else {
                    ElloProvider.unCastableJSONAble(failure)
                }
            },
            failure: failure
        )
    }
}
