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

    var isInteractive: Bool = true {
        didSet {
            guard oldValue != isInteractive else { return }
            injectShieldElement(!isInteractive)
            window?.invalidateCursorRects(for: self)
            if !isInteractive { NSCursor.arrow.set() }
        }
    }

    override func hitTest(_ point: NSPoint) -> NSView? {
        if !isInteractive { return nil }
        return super.hitTest(point)
    }

    override func resetCursorRects() {
        if !isInteractive {
            discardCursorRects()
            addCursorRect(bounds, cursor: .arrow)
        } else {
            super.resetCursorRects()
        }
    }

    override func cursorUpdate(with event: NSEvent) {
        if !isInteractive {
            NSCursor.arrow.set()
        } else {
            super.cursorUpdate(with: event)
        }
    }

    override func mouseExited(with event: NSEvent) {
        NSCursor.arrow.set()
        super.mouseExited(with: event)
    }

    // MARK: - HTML shield element

    private func injectShieldElement(_ inject: Bool) {
        let js: String
        if inject {
            js = """
            (function() {
                if (document.getElementById('__llmstream_shield')) return;
                var d = document.createElement('div');
                d.id = '__llmstream_shield';
                d.style.cssText = 'position:fixed;inset:0;z-index:2147483647;cursor:default;';
                document.body.appendChild(d);
            })();
            """
        } else {
            js = """
            (function() {
                var d = document.getElementById('__llmstream_shield');
                if (d) d.remove();
            })();
            """
        }
        evaluateJavaScript(js)
    }

    // MARK: - Scroll passthrough

    override func scrollWheel(with event: NSEvent) {
        if abs(event.scrollingDeltaX) > abs(event.scrollingDeltaY) {
            super.scrollWheel(with: event)
        } else {
            nextResponder?.scrollWheel(with: event)
        }
    }
}
#endif