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

    // MARK: - Interaction & cursor suppression

    /// When `true`, blocks ALL mouse interaction (hit-testing, hover, clicks, cursor).
    /// Set alongside `isCursorDisabled` by the suppressor modifier.
    var isInteractionDisabled: Bool = false                          // ← NEW

    /// Set to `true` when a SwiftUI overlay covers this web view.
    /// Uses a multi-pronged approach:
    ///   1. `hitTest` returns nil → no hover events reach WebKit at all
    ///   2. CSS injection into the web content (kills :hover styles & pointer-events)
    ///   3. AppKit cursor rect + tracking area override (beats AppKit layer)
    var isCursorDisabled: Bool = false {
        didSet {
            guard oldValue != isCursorDisabled else { return }
            applyCSSOverride(disabled: isCursorDisabled)
            window?.invalidateCursorRects(for: self)
        }
    }

    // MARK: - Hit-test blocking                                     ← NEW

    /// Returning `nil` makes this view and all its subviews invisible to
    /// AppKit's mouse-event dispatch. WebKit never receives mouseEntered /
    /// mouseMoved, so its internal `:hover` tracking never fires.
    override func hitTest(_ point: NSPoint) -> NSView? {
        if isInteractionDisabled {
            return nil
        }
        return super.hitTest(point)
    }

    // MARK: - Tracking area

    private var cursorTrackingArea: NSTrackingArea?

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
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

    override func cursorUpdate(with event: NSEvent) {
        if isCursorDisabled {
            NSCursor.arrow.set()
        } else {
            super.cursorUpdate(with: event)
        }
    }

    override func mouseMoved(with event: NSEvent) {
        if isCursorDisabled {
            NSCursor.arrow.set()
        } else {
            super.mouseMoved(with: event)
        }
    }
override func mouseExited(with event: NSEvent) {
    // Always reset to arrow when the mouse leaves the web view,
    // regardless of isCursorDisabled. This prevents the I-beam
    // from "leaking" into surrounding UI.
    NSCursor.arrow.set()
    super.mouseExited(with: event)
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

    // MARK: - CSS cursor + hover injection                          ← CHANGED

    /// Injects / removes styles that:
    ///   1. Force `cursor: default` on everything
    ///   2. Disable `pointer-events` so `:hover` CSS rules can't activate
    ///      even if a mouse event somehow reaches the web content
    private func applyCSSOverride(disabled: Bool) {
        let js: String
        if disabled {
            js = """
            (function() {
                if (document.getElementById('__llmstream_cursor_override')) return;
                var s = document.createElement('style');
                s.id = '__llmstream_cursor_override';
                s.innerHTML = '*, *::before, *::after { cursor: default !important; pointer-events: none !important; }';
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