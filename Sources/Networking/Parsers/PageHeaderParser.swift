////
///  PageHeaderParser.swift
//

import SwiftyJSON


class PageHeaderParser: IdParser {

    init() {
        super.init(table: .categoriesType)
        linkObject(.usersType)
    }

    override func parse(json: JSON) -> PageHeader {
        let kind: PageHeader.Kind = PageHeader.Kind(rawValue: json["kind"].stringValue) ?? .generic
        let image = Asset.parseAsset("page_header_\(json["id"].stringValue)", node: json["image"].dictionaryObject)

        let header = PageHeader(
            id: json["id"].stringValue,
            postToken: json["postToken"].string,
            header: json["header"].stringValue,
            subheader: json["subheader"].stringValue,
            ctaCaption: json["ctaLink"]["text"].stringValue,
            ctaURL: json["ctaLink"]["url"].string.flatMap { URL(string: $0) },
            image: image,
            kind: kind
        )

        header.links = json["links"].dictionaryObject

        return header
    }
}
