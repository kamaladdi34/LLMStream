//
//  WebViewCursorModifier.swift
//  LLMStream
//

#if os(macOS)
import SwiftUI
import AppKit

// MARK: - Public API

extension View {
    /// Suppresses the I-beam cursor on all `VerticalScrollPassthroughWebView`
    /// instances that are descendants of this view while `overlayIsVisible` is `true`.
    ///
    /// Place this on `LLMStreamView` at your call site:
    /// ```swift
    /// LLMStreamView(text: text, onUrlClicked: { _ in })
    ///     .suppressWebViewCursor(when: showSettings)
    /// ```
    public func suppressWebViewCursor(when overlayIsVisible: Bool) -> some View {
        self.background(
            _WebViewCursorSuppressorView(disabled: overlayIsVisible)
        )
    }
}

// MARK: - Internal NSViewRepresentable

private struct _WebViewCursorSuppressorView: NSViewRepresentable {
    let disabled: Bool

    func makeNSView(context: Context) -> _CursorSuppressorNSView {
        _CursorSuppressorNSView()
    }

    func updateNSView(_ nsView: _CursorSuppressorNSView, context: Context) {
        // Push the new value; the NSView does the work on the next run-loop
        // tick so SwiftUI's layout pass has fully committed first.
        nsView.setDisabled(disabled)
    }
}

// MARK: - The actual NSView that walks the hierarchy

/// An invisible zero-size view placed in the background of LLMStreamView.
/// It walks up to the window root and toggles `isCursorDisabled` on every
/// `VerticalScrollPassthroughWebView` it finds.
private class _CursorSuppressorNSView: NSView {

    private var pendingDisabled: Bool = false
    private var workItem: DispatchWorkItem?

    func setDisabled(_ disabled: Bool) {
        // Cancel any previously scheduled work so rapid state changes
        // (e.g. animated sheet open/close) don't fire stale toggles.
        workItem?.cancel()
        let item = DispatchWorkItem { [weak self] in
            self?.applyDisabled(disabled)
        }
        workItem = item
        DispatchQueue.main.async(execute: item)
    }

    private func applyDisabled(_ disabled: Bool) {
        allAncestorWebViews().forEach { $0.isCursorDisabled = disabled }
    }

    /// Climbs to the window content view then recursively finds every
    /// `VerticalScrollPassthroughWebView` in the entire window hierarchy.
    private func allAncestorWebViews() -> [VerticalScrollPassthroughWebView] {
        var root: NSView = self
        while let parent = root.superview { root = parent }
        return root.allDescendants(ofType: VerticalScrollPassthroughWebView.self)
    }
}

// MARK: - NSView hierarchy helper

private extension NSView {
    func allDescendants<T: NSView>(ofType type: T.Type) -> [T] {
        var result: [T] = []
        for subview in subviews {
            if let match = subview as? T { result.append(match) }
            result.append(contentsOf: subview.allDescendants(ofType: type))
        }
        return result
    }
}
#endif