//
//  StreamInviteFriendsCellPresenter.swift
//  Ello
//
//  Created by Ryan Boyajian on 6/11/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

public struct StreamInviteFriendsCellPresenter {

    public static func configure(
        cell: UICollectionViewCell,
        streamCellItem: StreamCellItem,
        streamKind: StreamKind,
        indexPath: NSIndexPath,
        currentUser: User?)
    {
        if let cell = cell as? StreamInviteFriendsCell,
            person = streamCellItem.jsonable as? LocalPerson
        {
            cell.person = person
        }
    }
}
