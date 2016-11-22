////
///  SimpleStreamController.swift
//

import Foundation

public class SimpleStreamViewController: StreamableViewController {
    override public func trackerName() -> String {
        return "\(endpoint.description)ViewController"
    }

    var navigationBar: ElloNavigationBar!
    let endpoint: ElloAPI

    required public init(endpoint: ElloAPI, title: String) {
        self.endpoint = endpoint
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .whiteColor()
        let streamKind = StreamKind.SimpleStream(endpoint: endpoint, title: title ?? "")

        setupNavigationBar()
        setupNavigationItems(streamKind: streamKind)

        scrollLogic.prevOffset = streamViewController.collectionView.contentOffset
        scrollLogic.navBarHeight = 44
        streamViewController.streamKind = streamKind
        ElloHUD.showLoadingHudInView(streamViewController.view)
        streamViewController.loadInitialPage()
    }

    override func viewForStream() -> UIView {
        return view
    }

    override public func didSetCurrentUser() {
        if isViewLoaded() {
            streamViewController.currentUser = currentUser
        }
        super.didSetCurrentUser()
    }

    override public func showNavBars(scrollToBottom: Bool) {
        super.showNavBars(scrollToBottom)
        positionNavBar(navigationBar, visible: true)
        updateInsets()

        if scrollToBottom {
            self.scrollToBottom(streamViewController)
        }
    }

    override public func hideNavBars() {
        super.hideNavBars()
        positionNavBar(navigationBar, visible: false)
        updateInsets()
    }

    // MARK: Private

    private func updateInsets() {
        updateInsets(navBar: navigationBar, streamController: streamViewController)
    }

    private func setupNavigationBar() {
        navigationBar = ElloNavigationBar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: ElloNavigationBar.Size.height))
        navigationBar.autoresizingMask = [.FlexibleBottomMargin, .FlexibleWidth]
        view.addSubview(navigationBar)
    }

    private func setupNavigationItems(streamKind streamKind: StreamKind) {
        let backItem = UIBarButtonItem.backChevron(withController: self)
        elloNavigationItem.leftBarButtonItems = [backItem]
        elloNavigationItem.fixNavBarItemPadding()
        navigationBar.items = [elloNavigationItem]

        var rightBarButtonItems: [UIBarButtonItem] = []
        rightBarButtonItems.append(UIBarButtonItem.searchItem(controller: self))
        if streamKind.hasGridViewToggle {
            rightBarButtonItems.append(UIBarButtonItem.gridListItem(delegate: streamViewController, isGridView: streamKind.isGridView))
        }
        elloNavigationItem.rightBarButtonItems = rightBarButtonItems
    }

}
