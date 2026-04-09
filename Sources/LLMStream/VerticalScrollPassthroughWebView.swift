//
//  VerticalScrollPassthroughWebView.swift
//  MarkdownLatexWebview
//
//  Created by Kévin Naudin on 19/03/2025.
//

import WebKit

#if os(iOS)
import UIKit

class VerticalScrollPassthroughWebView: WKWebView, UIGestureRecognizerDelegate, UIScrollViewDelegate {
    private var panGesture: UIPanGestureRecognizer?

    override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        panGesture?.delegate = self
        addGestureRecognizer(panGesture!)

        scrollView.delegate = self
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 1
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        if abs(translation.x) > abs(translation.y) {
            self.scrollView.panGestureRecognizer.isEnabled = true
        } else {
            self.scrollView.panGestureRecognizer.isEnabled = false
            superview?.gestureRecognizers?.forEach { $0.isEnabled = true }
        }
    }

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        return true
    }

    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollView.pinchGestureRecognizer?.isEnabled = false
    }
}

#else
import AppKit

class VerticalScrollPassthroughWebView: WKWebView {

    // MARK: - Cursor suppression

    /// Set to `true` when a SwiftUI overlay covers this web view.
    /// Uses the two-pronged approach:
    ///   1. CSS injection into the web content (beats WebKit render process)
    ///   2. AppKit cursor rect + tracking area override (beats AppKit layer)
    var isCursorDisabled: Bool = false {
        didSet {
            guard oldValue != isCursorDisabled else { return }
            applyCSSCursorOverride(disabled: isCursorDisabled)
            window?.invalidateCursorRects(for: self)
        }
    }

    // MARK: - Tracking area

    private var cursorTrackingArea: NSTrackingArea?

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        // Remove our previous tracking area before adding a fresh one.
        if let existing = cursorTrackingArea {
            removeTrackingArea(existing)
        }
        let area = NSTrackingArea(
            rect: bounds,
            options: [.mouseEnteredAndExited, .mouseMoved, .cursorUpdate, .activeInKeyWindow],
            owner: self,
            userInfo: nil
        )
        addTrackingArea(area)
        cursorTrackingArea = area
    }

    // MARK: - AppKit cursor override

    override func resetCursorRects() {
        if isCursorDisabled {
            discardCursorRects()
            addCursorRect(bounds, cursor: .arrow)
        } else {
            super.resetCursorRects()
        }
    }

    /// Overriding `cursorUpdate` with NO super call stops AppKit from
    /// re-applying WebKit's tracking-area cursor after we set ours.
    /// This is the correct AppKit interception point per Apple DTS guidance.
    override func cursorUpdate(with event: NSEvent) {
        if isCursorDisabled {
            NSCursor.arrow.set()
            // Intentionally do NOT call super — that would let WebKit
            // re-install the I-beam through its own tracking area handler.
        } else {
            super.cursorUpdate(with: event)
        }
    }

    override func mouseMoved(with event: NSEvent) {
        if isCursorDisabled {
            NSCursor.arrow.set()
            // Do NOT call super for the same reason as cursorUpdate above.
        } else {
            super.mouseMoved(with: event)
        }
    }

    override func mouseEntered(with event: NSEvent) {
        if isCursorDisabled {
            NSCursor.arrow.set()
        } else {
            super.mouseEntered(with: event)
        }
    }

    // MARK: - Scroll passthrough

    override func scrollWheel(with event: NSEvent) {
        if abs(event.scrollingDeltaX) > abs(event.scrollingDeltaY) {
            super.scrollWheel(with: event)
        } else {
            nextResponder?.scrollWheel(with: event)
        }
    }

    // MARK: - CSS cursor injection

    /// Injects / removes a `* { cursor: default !important; }` style into the
    /// live web content. This is necessary because WebKit sets its cursor from
    /// a sandboxed render process that races with — and often wins over —
    /// AppKit-level overrides.
    private func applyCSSCursorOverride(disabled: Bool) {
        let js: String
        if disabled {
            js = """
            (function() {
                if (document.getElementById('__llmstream_cursor_override')) return;
                var s = document.createElement('style');
                s.id = '__llmstream_cursor_override';
                s.innerHTML = '* { cursor: default !important; }';
                document.head.appendChild(s);
            })();
            """
        } else {
            js = """
            (function() {
                var s = document.getElementById('__llmstream_cursor_override');
                if (s) s.parentNode.removeChild(s);
            })();
            """
        }
        evaluateJavaScript(js)
    }
}
#endif