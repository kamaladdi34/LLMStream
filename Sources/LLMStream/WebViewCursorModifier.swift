//
//  WebViewCursorModifier.swift
//  LLMStream
//

#if os(macOS)
import SwiftUI
import AppKit

// MARK: - Public API

/// Closure that takes a window-space point and returns `true` if that
/// point is occluded by something above the web view.
public typealias OcclusionCheck = @MainActor (CGPoint) -> Bool

extension View {
    /// Overlays an invisible tracking layer on top of the web view content.
    /// This layer receives all mouse events (since it's above the WKWebView)
    /// and forwards them through only when the cursor should be active.
    ///
    /// - Parameter isOccluded: Closure the host app provides to check if
    ///   a window-coordinate point is blocked by an overlay (e.g. header,
    ///   toolbar, sheet). If `nil`, only the overlay layer itself is used.
    public func suppressWebViewCursor(
        isOccluded: OcclusionCheck? = nil
    ) -> some View {
        self.overlay(
            _WebViewCursorOverlayRepresentable(isOccluded: isOccluded)
                .allowsHitTesting(true)
        )
    }
}

// MARK: - NSViewRepresentable

private struct _WebViewCursorOverlayRepresentable: NSViewRepresentable {
    let isOccluded: OcclusionCheck?

    func makeNSView(context: Context) -> _CursorOverlayNSView {
        let v = _CursorOverlayNSView()
        v.occlusionCheck = isOccluded
        return v
    }

    func updateNSView(_ nsView: _CursorOverlayNSView, context: Context) {
        nsView.occlusionCheck = isOccluded
    }
}

// MARK: - Transparent overlay NSView

/// Sits on top of the WKWebView. Because it's higher in the view hierarchy,
/// it receives mouse events before WebKit does. It decides whether to:
///   - Pass events through (mouse is over content, not occluded) → WebKit cursor
///   - Block events (mouse is occluded or outside content) → arrow cursor
final class _CursorOverlayNSView: NSView {

    var occlusionCheck: OcclusionCheck?

    private var trackingArea: NSTrackingArea?
    private var isActive = false

    // MARK: Setup

    override func updateTrackingAreas() {
        if let existing = trackingArea {
            removeTrackingArea(existing)
        }
        let area = NSTrackingArea(
            rect: bounds,
            options: [
                .mouseEnteredAndExited,
                .mouseMoved,
                .activeInKeyWindow,
                .inVisibleRect
            ],
            owner: self,
            userInfo: nil
        )
        addTrackingArea(area)
        trackingArea = area
        super.updateTrackingAreas()
    }

    // MARK: Hit testing

    /// This is the key: we ALWAYS claim the hit so WebKit doesn't get it
    /// directly. Then we decide in mouse event handlers what to do.
    override func hitTest(_ point: NSPoint) -> NSView? {
        let local = convert(point, from: superview)
        guard bounds.contains(local) else { return nil }

        // If not occluded at this point, return nil so the event
        // falls through to the WebView underneath.
        let windowPoint = convert(local, to: nil)
        if !isPointOccluded(windowPoint) {
            enableWebViews(true)
            return nil
        }

        // Occluded — we claim the hit to block WebKit.
        enableWebViews(false)
        return self
    }

    // MARK: Mouse events

    override func mouseEntered(with event: NSEvent) {
        evaluate(event.locationInWindow)
    }

    override func mouseMoved(with event: NSEvent) {
        evaluate(event.locationInWindow)
    }

    override func mouseExited(with event: NSEvent) {
        enableWebViews(false)
        NSCursor.arrow.set()
        isActive = false
    }

    // MARK: Cursor

    override func resetCursorRects() {
        discardCursorRects()
        addCursorRect(bounds, cursor: .arrow)
    }

    override func cursorUpdate(with event: NSEvent) {
        if !isActive {
            NSCursor.arrow.set()
        }
    }

    // MARK: Core logic

    private func evaluate(_ windowPoint: CGPoint) {
        let occluded = isPointOccluded(windowPoint)

        if occluded {
            if isActive {
                enableWebViews(false)
                NSCursor.arrow.set()
                isActive = false
            }
        } else {
            if !isActive {
                enableWebViews(true)
                isActive = true
            }
        }
    }

    private func isPointOccluded(_ windowPoint: CGPoint) -> Bool {
        if let check = occlusionCheck, check(windowPoint) {
            return true
        }
        return false
    }

    private func enableWebViews(_ enabled: Bool) {
        for wv in findAllWebViews() {
            wv.isCursorDisabled = !enabled
            wv.isInteractionDisabled = !enabled
        }
        if !enabled {
            NSCursor.arrow.set()
        }
    }

    // MARK: Hierarchy

    private func findAllWebViews() -> [VerticalScrollPassthroughWebView] {
        guard let window = self.window,
              let contentView = window.contentView else { return [] }
        return contentView.allDescendants(ofType: VerticalScrollPassthroughWebView.self)
    }
}

// MARK: - NSView hierarchy helper

private extension NSView {
    func allDescendants<T: NSView>(ofType type: T.Type) -> [T] {
        var result: [T] = []
        for sub in subviews {
            if let match = sub as? T { result.append(match) }
            result.append(contentsOf: sub.allDescendants(ofType: type))
        }
        return result
    }
}
#endif