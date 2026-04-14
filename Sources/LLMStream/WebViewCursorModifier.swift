//
//  WebViewCursorModifier.swift
//  LLMStream
//

#if os(macOS)
import SwiftUI
import AppKit

// MARK: - Public API

extension View {
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
        nsView.setDisabled(disabled)
    }
}

// MARK: - The actual NSView that walks the hierarchy

private class _CursorSuppressorNSView: NSView {

    private var workItem: DispatchWorkItem?

    func setDisabled(_ disabled: Bool) {
        workItem?.cancel()
        let item = DispatchWorkItem { [weak self] in
            self?.applyDisabled(disabled)
        }
        workItem = item
        DispatchQueue.main.async(execute: item)
    }

    private func applyDisabled(_ disabled: Bool) {
        allWebViews().forEach { webView in
            webView.isCursorDisabled = disabled
            webView.isInteractionDisabled = disabled   // ← NEW: blocks hit-testing + hover
        }
    }

    private func allWebViews() -> [VerticalScrollPassthroughWebView] {
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