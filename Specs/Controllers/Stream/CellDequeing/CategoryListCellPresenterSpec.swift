////
///  CategoryListCellPresenterSpec.swift
//

@testable import Ello
import Quick
import Nimble


class CategoryListCellPresenterSpec: QuickSpec {
    override func spec() {
        describe("CategoryListCellPresenter") {
            it("sets the categoriesInfo on a cell") {
                let categoryList: CategoryList = CategoryList.metaCategories()
                let cell: CategoryListCell = CategoryListCell()
                let item: StreamCellItem = StreamCellItem(jsonable: categoryList, type: .CategoryList)

                CategoryListCellPresenter.configure(cell, streamCellItem: item, streamKind: .CategoryPosts(slug: "art"), indexPath: NSIndexPath(forItem: 0, inSection: 0), currentUser: nil)

                expect(cell.categoriesInfo.count) == categoryList.categories.count

                expect(cell.categoriesInfo[0].title) == categoryList.categories[0].name
                expect(cell.categoriesInfo[0].endpoint.path) == ElloAPI.Discover(type: .Featured).path

                expect(cell.categoriesInfo[1].title) == categoryList.categories[1].name
                expect(cell.categoriesInfo[1].endpoint.path) == ElloAPI.CategoryPosts(slug: "art").path
            }
        }
    }
}
