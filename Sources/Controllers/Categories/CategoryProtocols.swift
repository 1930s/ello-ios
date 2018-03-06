////
///  CategoryProtocols.swift
//

protocol CategoryScreenDelegate: class {
    func scrollToTop()
    func backButtonTapped()
    func shareTapped(sender: UIView)
    func gridListToggled(sender: UIButton)
    func allCategoriesTapped()
    func seeAllCategoriesTapped()
    func subscribedCategoryTapped()
    func categorySelected(index: Int)
    func searchButtonTapped()
}

protocol CategoryScreenProtocol: StreamableScreenProtocol {
    var topInsetView: UIView { get }
    var showSubscribed: Bool { get set }
    var showSeeAll: Bool { get set }
    var isGridView: Bool { get set }
    var categoriesLoaded: Bool { get set }
    func set(categoriesInfo: [CategoryCardListView.CategoryInfo], completion: @escaping Block)
    func toggleCategoriesList(navBarVisible: Bool, animated: Bool)
    func scrollToCategory(_ selection: CategoryScreen.Selection)
    func selectCategory(_ index: CategoryScreen.Selection)
    func setupNavBar(back: Bool, animated: Bool)
}
