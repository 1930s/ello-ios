////
///  HomeViewController.swift
//


class HomeViewController: BaseElloViewController, HomeScreenDelegate {
    override func trackerName() -> String? { return nil }

    var visibleViewController: UIViewController?
    var editorialsViewController: EditorialsViewController!
    var artistInvitesViewController: ArtistInvitesViewController!
    var followingViewController: FollowingViewController!
    var discoverViewController: CategoryViewController!

    enum Usage {
        case loggedOut
        case loggedIn
    }

    override var tabBarItem: UITabBarItem? {
        get { return UITabBarItem.item(.home, insets: ElloTab.home.insets) }
        set { self.tabBarItem = newValue }
    }

    private let usage: Usage

    init(usage: Usage) {
        self.usage = usage
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var _mockScreen: HomeScreenProtocol?
    var screen: HomeScreenProtocol {
        set(screen) { _mockScreen = screen }
        get { return _mockScreen ?? self.view as! HomeScreen }
    }

    override func didSetCurrentUser() {
        super.didSetCurrentUser()
        editorialsViewController?.currentUser = currentUser
        artistInvitesViewController?.currentUser = currentUser
        followingViewController?.currentUser = currentUser
        discoverViewController?.currentUser = currentUser
    }

    override func loadView() {
        let screen = HomeScreen()
        screen.delegate = self

        self.view = screen
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupControllers()
    }

}

extension HomeViewController: HomeResponder {
    func showEditorialsViewController() {
        showController(editorialsViewController)
    }

    func showArtistInvitesViewController() {
        showController(artistInvitesViewController)
    }

    func showFollowingViewController() {
        showController(followingViewController)
    }

    func showDiscoverViewController() {
        showController(discoverViewController)
    }

    private func setupControllers() {
        let editorialsViewController = EditorialsViewController(usage: usage)
        editorialsViewController.currentUser = currentUser
        addChildViewController(editorialsViewController)
        editorialsViewController.didMove(toParentViewController: self)
        self.editorialsViewController = editorialsViewController

        let artistInvitesViewController = ArtistInvitesViewController(usage: usage)
        artistInvitesViewController.currentUser = currentUser
        addChildViewController(artistInvitesViewController)
        artistInvitesViewController.didMove(toParentViewController: self)
        self.artistInvitesViewController = artistInvitesViewController

        let followingViewController = FollowingViewController()
        followingViewController.currentUser = currentUser
        addChildViewController(followingViewController)
        followingViewController.didMove(toParentViewController: self)
        self.followingViewController = followingViewController

        let discoverViewController = CategoryViewController(slug: Category.featured.slug, name: Category.featured.name, usage: .largeNav)
        discoverViewController.category = Category.featured
        discoverViewController.currentUser = currentUser
        addChildViewController(discoverViewController)
        discoverViewController.didMove(toParentViewController: self)
        self.discoverViewController = discoverViewController

        showController(editorialsViewController)
    }

    private func showController(_ viewController: UIViewController) {
        guard visibleViewController != viewController else { return }

        if let visibleViewController = visibleViewController {
            screen.controllerContainer.insertSubview(viewController.view, aboveSubview: visibleViewController.view)
            visibleViewController.view.removeFromSuperview()
        }
        else {
            screen.controllerContainer.addSubview(viewController.view)
        }

        viewController.view.frame = screen.controllerContainer.bounds
        viewController.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]

        visibleViewController = viewController
    }

}

let drawerAnimator = DrawerAnimator()

extension HomeViewController: DrawerResponder {

    func showDrawerViewController() {
        let drawer = DrawerViewController()
        drawer.currentUser = currentUser

        drawer.transitioningDelegate = drawerAnimator
        drawer.modalPresentationStyle = .custom

        self.present(drawer, animated: true, completion: nil)
    }

}
