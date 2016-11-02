////
///  Array.swift
//

extension Array {
    func safeValue(index: Int) -> Element? {
        return (startIndex..<endIndex).contains(index) ? self[index] : .None
    }

    func find(@noescape test: (el: Element) -> Bool) -> Element? {
        for ob in self {
            if test(el: ob) {
                return ob
            }
        }
        return nil
    }

    func randomItem() -> Element? {
        guard count > 0 else { return nil }
        let index = Int(arc4random_uniform(UInt32(count)))
        return self[index]
    }
}

extension SequenceType {

    func any(@noescape test: (el: Generator.Element) -> Bool) -> Bool {
        for ob in self {
            if test(el: ob) {
                return true
            }
        }
        return false
    }

    func all(test: (el: Generator.Element) -> Bool) -> Bool {
        for ob in self {
            if !test(el: ob) {
                return false
            }
        }
        return true
    }

}

extension Array where Element: Equatable {
    func unique() -> [Element] {
        return self.reduce([Element]()) { elements, el in
            if elements.contains(el) {
                return elements
            }
            return elements + [el]
        }
    }

}
