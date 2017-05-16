////
///  CategoryViewControllerSpec.swift
//

@testable import Ello
import Quick
import Nimble


class CategoryViewControllerSpec: QuickSpec {
    class MockCategoryScreen: CategoryScreenProtocol {
        let topInsetView = UIView()
        let streamContainer = UIView()
        var categoryCardsVisible = true
        var isGridView = true
        var navigationBarTopConstraint: NSLayoutConstraint!
        let navigationBar = ElloNavigationBar()
        var navigationItem: UINavigationItem?
        var categoryTitles: [String] = []
        var scrollTo: Int?
        var select: Int?
        var showShare: CategoryScreen.NavBarItems
        var showBack = false

        func set(categoriesInfo: [CategoryCardListView.CategoryInfo], animated: Bool, completion: @escaping ElloEmptyCompletion) {
            categoryTitles = categoriesInfo.map { $0.title }
        }
        func animateCategoriesList(navBarVisible: Bool) {}
        func scrollToCategory(index: Int) {
            scrollTo = index
        }

        func selectCategory(index: Int) {
            select = index
        }

        func viewForStream() -> UIView {
            return streamContainer
        }

        func setupNavBar(show: CategoryScreen.NavBarItems, back: Bool, animated: Bool) {
            self.showShare = show
            self.showBack = backVisible
        }
    }

    override func spec() {
        describe("CategoryViewController") {
            let currentUser: User = stub([:])
            var subject: CategoryViewController!
            var screen: MockCategoryScreen!

            beforeEach {
                let category: Ello.Category = Ello.Category.stub([:])
                subject = CategoryViewController(slug: category.slug)
                screen = MockCategoryScreen()
                subject.currentUser = currentUser
                subject.screen = screen
                showController(subject)
            }

            it("has a nice looking nav bar") {
                expectValidSnapshot(subject)
            }

            it("shows the back button when necessary") {
                let category: Ello.Category = Ello.Category.stub([:])
                subject = CategoryViewController(slug: category.slug)
                screen = MockCategoryScreen()
                subject.currentUser = currentUser
                subject.screen = screen

                let nav = UINavigationController(rootViewController: UIViewController())
                nav.pushViewController(subject, animated: false)
                showController(nav)
                expect(screen.showBack) == true
            }

            it("restores the previous category") {
                subject.slug = "shop"
                subject.allCategoriesTapped()
                expect(subject.slug).to(beNil())
                expect(screen.showBack) == true
                subject.backTapped()
                expect(subject.slug) == "shop"
                expect(screen.showBack) == false
            }

            context("setCategories(_:)") {
                it("accepts meta categories") {
                    subject.set(categories: [
                        Category.featured,
                        Category.stub(["name": "Art"])
                        ])
                    expect(screen.categoryTitles) == ["Featured", "Art"]
                }
            }
        }
    }
}
