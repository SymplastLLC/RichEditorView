import XCTest
@testable import RichEditorView

final class RichEditorViewTests: XCTestCase {
    func testDefaults() {
        let editor = RichEditorView()
        XCTAssertEqual(editor.contentHTML, "")
        XCTAssertFalse(editor.autoHeight)
    }

    func testAutoHeightReportsContentHeightAndRefitsToWidth() {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 800, height: 600))
        let editor = RichEditorView(frame: CGRect(x: 0, y: 0, width: 600, height: 40))
        let delegate = HeightRecorder()
        editor.delegate = delegate
        editor.isScrollEnabled = false
        editor.autoHeight = true
        window.addSubview(editor)
        window.isHidden = false

        let paragraph = String(repeating: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. ", count: 6)
        editor.html = String(repeating: "<p>\(paragraph)</p>", count: 4)

        // Content taller than the 40pt frame: the height is not bound to the viewport
        delegate.waitForHeight(in: self) { $0 > 100 }
        let wideHeight = delegate.lastHeight

        // A narrower width re-wraps the text, so the content grows
        editor.frame.size.width = 300
        delegate.waitForHeight(in: self) { $0 > wideHeight }
        let narrowHeight = delegate.lastHeight

        // And shrinks back once the width is restored
        editor.frame.size.width = 600
        delegate.waitForHeight(in: self) { $0 < narrowHeight }
        XCTAssertEqual(delegate.lastHeight, wideHeight, accuracy: 2)
    }

    func testAutoHeightKeepsWideContentInsideTheEditor() {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 800, height: 600))
        let editor = RichEditorView(frame: CGRect(x: 0, y: 0, width: 300, height: 40))
        let delegate = HeightRecorder()
        editor.delegate = delegate
        editor.isScrollEnabled = false
        editor.autoHeight = true
        window.addSubview(editor)
        window.isHidden = false

        let paragraph = String(repeating: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. ", count: 6)
        editor.html = "<p>\(paragraph)</p><div style=\"width:2000px;height:20px\"></div><p>\(paragraph)</p>"

        // Wide content neither collapses the height nor shrinks the page to fit
        delegate.waitForHeight(in: self) { $0 > 100 }
        XCTAssertLessThan(delegate.lastHeight, 2000)

        // The overflow scrolls inside the editor: the document itself stays as wide as the view
        let documentWidth = expectation(description: "document width")
        editor.runJS("String(document.documentElement.scrollWidth)") { width in
            XCTAssertEqual(Int(width) ?? .max, 300, accuracy: 1)
            documentWidth.fulfill()
        }
        wait(for: [documentWidth], timeout: 10)
    }

    static var allTests = [
        ("testDefaults", testDefaults),
        ("testAutoHeightReportsContentHeightAndRefitsToWidth", testAutoHeightReportsContentHeightAndRefitsToWidth),
        ("testAutoHeightKeepsWideContentInsideTheEditor", testAutoHeightKeepsWideContentInsideTheEditor),
    ]
}

private final class HeightRecorder: NSObject, RichEditorDelegate {
    private(set) var lastHeight = 0
    private var onHeight: ((Int) -> Void)?

    func richEditor(_ editor: RichEditorView, heightDidChange height: Int) {
        lastHeight = height
        onHeight?(height)
    }

    func waitForHeight(in testCase: XCTestCase, timeout: TimeInterval = 10, _ condition: @escaping (Int) -> Bool) {
        if condition(lastHeight) { return }
        let expectation = testCase.expectation(description: "height")
        expectation.assertForOverFulfill = false
        onHeight = { height in
            if condition(height) { expectation.fulfill() }
        }
        testCase.wait(for: [expectation], timeout: timeout)
        onHeight = nil
    }
}
