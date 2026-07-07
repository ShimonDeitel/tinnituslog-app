import XCTest
@testable import EarRingLog

@MainActor
final class EarRingLogTests: XCTestCase {

    func testSeedDataBelowFreeLimit() {
        let store = Store()
        XCTAssertLessThan(store.entries.count, Store.freeTierLimit)
    }

    func testAddEntryIncreasesCount() {
        let store = Store()
        let before = store.entries.count
        store.add(EntryEntry(note: "test"))
        XCTAssertEqual(store.entries.count, before + 1)
    }

    func testCanAddWithinFreeLimit() {
        let store = Store()
        XCTAssertTrue(store.canAdd(isPro: false))
    }

    func testCanAddBlockedAtLimitWhenNotPro() {
        let store = Store()
        store.entries = (0..<Store.freeTierLimit).map { _ in EntryEntry() }
        XCTAssertFalse(store.canAdd(isPro: false))
    }

    func testCanAddAlwaysAllowedWhenPro() {
        let store = Store()
        store.entries = (0..<(Store.freeTierLimit + 5)).map { _ in EntryEntry() }
        XCTAssertTrue(store.canAdd(isPro: true))
    }

    func testDeleteEntryRemovesIt() {
        let store = Store()
        let entry = EntryEntry(note: "to delete")
        store.add(entry)
        store.delete(entry)
        XCTAssertFalse(store.entries.contains(where: { $0.id == entry.id }))
    }

    func testUpdateEntryPersistsChange() {
        let store = Store()
        var entry = EntryEntry(note: "original")
        store.add(entry)
        entry.note = "updated"
        store.update(entry)
        XCTAssertEqual(store.entries.first(where: { $0.id == entry.id })?.note, "updated")
    }

    func testDeleteAtOffsets() {
        let store = Store()
        let countBefore = store.entries.count
        store.delete(at: IndexSet(integer: 0))
        XCTAssertEqual(store.entries.count, countBefore - 1)
    }
}
