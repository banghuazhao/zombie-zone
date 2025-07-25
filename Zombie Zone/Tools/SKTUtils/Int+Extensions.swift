import CoreGraphics

extension Int {
    /**
     * Ensures that the integer value stays with the specified range.
     */
    func clamped(_ range: Range<Int>) -> Int {
        return (self < range.lowerBound) ? range.lowerBound : ((self >= range.upperBound) ? range.upperBound - 1 : self)
    }

    func clamped(_ range: ClosedRange<Int>) -> Int {
        return (self < range.lowerBound) ? range.lowerBound : ((self > range.upperBound) ? range.upperBound : self)
    }

    /**
     * Ensures that the integer value stays with the specified range.
     */
    @discardableResult
    mutating func clamp(_ range: Range<Int>) -> Int {
        self = clamped(range)
        return self
    }

    @discardableResult
    mutating func clamp(_ range: ClosedRange<Int>) -> Int {
        self = clamped(range)
        return self
    }

    /**
     * Ensures that the integer value stays between the given values, inclusive.
     */
    func clamped(_ v1: Int, _ v2: Int) -> Int {
        let min = v1 < v2 ? v1 : v2
        let max = v1 > v2 ? v1 : v2
        return self < min ? min : (self > max ? max : self)
    }

    /**
     * Ensures that the integer value stays between the given values, inclusive.
     */
    @discardableResult
    mutating func clamp(_ v1: Int, _ v2: Int) -> Int {
        self = clamped(v1, v2)
        return self
    }

    /**
     * Returns a random integer in the specified range.
     */
    static func random(_ range: Range<Int>) -> Int {
        return Int(arc4random_uniform(UInt32(range.upperBound - range.lowerBound - 1))) + range.lowerBound
    }

    static func random(_ range: ClosedRange<Int>) -> Int {
        return Int(arc4random_uniform(UInt32(range.upperBound - range.lowerBound))) + range.lowerBound
    }

    /**
     * Returns a random integer between 0 and n-1.
     */
    static func random(_ n: Int) -> Int {
        return Int(arc4random_uniform(UInt32(n)))
    }

    /**
     * Returns a random integer in the range min...max, inclusive.
     */
    static func random(min: Int, max: Int) -> Int {
        assert(min < max)
        return Int(arc4random_uniform(UInt32(max - min + 1))) + min
    }
}
