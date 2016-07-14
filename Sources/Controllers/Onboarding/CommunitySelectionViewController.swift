////
///  CommunitySelectionViewController.swift
//

public class CommunitySelectionViewController: OnboardingUserListViewController {

    override public func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Onboarding Community Selection"
    }

    override func setupStreamController() {
        super.setupStreamController()

        streamViewController.streamKind = .SimpleStream(endpoint: .CommunitiesStream, title: "Communities")
    }

    override func usersLoaded(users: [User]) {
        let header = InterfaceString.Onboard.Community.Title
        let message = InterfaceString.Onboard.Community.Description
        appendHeaderCellItem(header: header, message: message)

        super.usersLoaded(users)
    }

}
