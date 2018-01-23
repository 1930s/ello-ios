////
///  CategoryCardListViewSpec.swift
//

@testable import Ello
import Quick
import Nimble


class CategoryCardListViewSpec: QuickSpec {
    class MockCategoryCardListDelegate: CategoryCardListDelegate {
        var selectedIndex: Int?
        var allCategoriesTappedCount = 0
        func categoryCardSelected(_ index: Int) {
            selectedIndex = index
        }
        func allCategoriesTapped() {
            allCategoriesTappedCount += 1
        }
    }

    override func spec() {
        var subject: CategoryCardListView!
        var delegate: MockCategoryCardListDelegate!
        beforeEach {
            subject = CategoryCardListView(frame: CGRect(origin: .zero, size: CGSize(width: 320, height: CategoryCardListView.Size.height)))
            let infoA = CategoryCardListView.CategoryInfo(
                title: "Art",
                imageURL: URL(string: "https://example.com")
            )
            let infoB = CategoryCardListView.CategoryInfo(
                title: "Lorem ipsum dolor sit amet",
                imageURL: URL(string: "https://example.com")
            )
            subject.categoriesInfo = [infoA, infoB, infoA, infoB]
            delegate = MockCategoryCardListDelegate()
            subject.delegate = delegate
        }

        describe("CategoryCardListView") {
            it("should have a valid snapshot") {
                expectValidSnapshot(subject, named: "CategoryCardListView")
            }

            describe("CategoryCardListDelegate") {
                it("informs delegates of all categories selection") {
                    let button: UIButton! = allSubviews(of: subject).first
                    button.sendActions(for: .touchUpInside)
                    expect(delegate.allCategoriesTappedCount) == 1
                }

                it("informs delegates of category selection") {
                    let button: UIButton! = allSubviews(of: subject).last
                    button.sendActions(for: .touchUpInside)
                    expect(delegate.selectedIndex) == subject.categoriesInfo.count - 1
                }
            }
        }
    }
}
