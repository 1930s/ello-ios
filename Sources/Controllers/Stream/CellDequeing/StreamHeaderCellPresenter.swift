//
//  StreamHeaderCellPresenter.swift
//  Ello
//
//  Created by Sean on 2/18/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation
import TimeAgoInWords

public struct StreamHeaderCellPresenter {

    static func configure(
        cell: UICollectionViewCell,
        streamCellItem: StreamCellItem,
        streamKind: StreamKind,
        indexPath: NSIndexPath,
        currentUser: User?)
    {
        if let cell = cell as? StreamHeaderCell,
            authorable = streamCellItem.jsonable as? Authorable
        {
            let post = streamCellItem.jsonable as? Post

            cell.close()
            cell.indexPath = indexPath
            cell.streamKind = streamKind
            cell.ownPost = false
            cell.ownComment = false
            cell.isGridLayout = streamKind.isGridView

            switch streamKind {
            case .PostDetail:
                cell.showUsername = false
            default:
                cell.showUsername = true
            }

            if let currentUser = currentUser,
                comment = streamCellItem.jsonable as? ElloComment
            {
                if currentUser.isOwnComment(comment) {
                    cell.ownComment = true
                }
                else if currentUser.isOwnParentPost(comment) {
                    cell.ownPost = true
                }
            }

            var author = authorable.author
            var repostedBy: User? = nil
            var followButtonVisible = false
            if streamCellItem.type == .Header {
                cell.avatarHeight = streamKind.avatarHeight
                cell.scrollView.scrollEnabled = false
                cell.chevronHidden = true
                cell.goToPostView.hidden = false

                if let repostAuthor = post?.repostAuthor {
                    repostedBy = author
                    author = repostAuthor
                }

                if streamKind.isDetail {
                    followButtonVisible = true
                }
                cell.canReply = false
            }
            else {
                cell.showUsername = true
                cell.avatarHeight = 30.0
                cell.scrollView.scrollEnabled = true
                cell.chevronHidden = false
                cell.goToPostView.hidden = true
                cell.canReply = true
            }

            if author?.id == currentUser?.id {
                followButtonVisible = false
            }

            cell.setUser(author)
            cell.setRepostedBy(repostedBy)
            cell.followButtonVisible = followButtonVisible
            if streamKind.isGridView {
                cell.timeStamp = ""
                cell.setCategory(nil)
            }
            else {
                cell.setCategory(post?.category)
                cell.timeStamp = authorable.createdAt.timeAgoInWords()
            }
            cell.layoutIfNeeded()
        }
    }
}
