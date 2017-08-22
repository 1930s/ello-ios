////
///  ResponseConfig.swift
//

class ResponseConfig: CustomStringConvertible {
    var description: String {
        let descripArray = [
            "ResponseConfig:",
            "nextQuery: \(String(describing: nextQuery))",
            "totalPages: \(String(describing: totalPages))",
            "totalCount: \(String(describing: totalCount))",
            "totalPagesRemaining: \(String(describing: totalPagesRemaining))"
        ]
        return descripArray.joined(separator: "\n\t")
    }
    var nextQuery: URLComponents? // before (older)
    var totalCount: String?
    var totalPages: String?
    var totalPagesRemaining: String?
    var statusCode: Int?
    var lastModified: String?
    var isFinalValue: Bool

    init(isFinalValue: Bool = true) {
        self.isFinalValue = isFinalValue
    }

    func isOutOfData() -> Bool {

        return totalPagesRemaining == "0"
            || totalPagesRemaining == nil
            || nextQuery?.queryItems?.count == 0
            || nextQuery?.queryItems == nil
            || nextQuery == nil
    }
}
