//
//  WebViewCursorModifier.swift
//  LLMStream
//

#if os(macOS)
import SwiftUI
import AppKit

// MARK: - Public API

extension View {
    /// Suppresses the WKWebView I-beam cursor.
    ///
    /// - Parameter overlayIsVisible: When `true`, force-suppresses regardless
    ///   of mouse position. When `false`, the modifier self-monitors and only
    ///   allows the I-beam while the mouse is directly over the web view with
    ///   nothing on top of it.
    public func suppressWebViewCursor(when overlayIsVisible: Bool = false) -> some View {
        self.background(
            _WebViewCursorSuppressorRepresentable(forceDisabled: overlayIsVisible)
        )
    }
}

// MARK: - NSViewRepresentable

private struct _WebViewCursorSuppressorRepresentable: NSViewRepresentable {
    let forceDisabled: Bool

    func makeNSView(context: Context) -> _CursorSuppressorNSView {
        _CursorSuppressorNSView()
    }

    func updateNSView(_ nsView: _CursorSuppressorNSView, context: Context) {
        nsView.forceDisabled = forceDisabled
    }
}

// MARK: - Polling NSView

private final class _CursorSuppressorNSView: NSView {

    var forceDisabled: Bool = false {
        didSet { poll() }
    }

    private var timer: Timer?
    private var lastApplied: Bool?

    // MARK: Lifecycle

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        if window != nil {
            startTimer()
        } else {
            stopTimer()
        }
    }

    override func removeFromSuperview() {
        stopTimer()
        super.removeFromSuperview()
    }

    deinit {
        stopTimer()
    }

    // MARK: Timer

    private func startTimer() {
        guard timer == nil else { return }
        timer = Timer(timeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
            self?.poll()
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    // MARK: Poll

    private func poll() {
        let shouldDisable: Bool

        if forceDisabled {
            shouldDisable = true
        } else {
            shouldDisable = !isMouseDirectlyOverWebView()
        }

        guard shouldDisable != lastApplied else { return }
        lastApplied = shouldDisable

        let webViews = findAllWebViews()
        for wv in webViews {
            wv.isCursorDisabled = shouldDisable
            wv.isInteractionDisabled = shouldDisable
        }

        if shouldDisable {
            NSCursor.arrow.set()
        }
    }

    // MARK: Hit testing

    private func isMouseDirectlyOverWebView() -> Bool {
        guard let window = self.window,
              let contentView = window.contentView else { return false }

        // 1. Is the mouse even over our window?
        let screenPoint = NSEvent.mouseLocation
        let windowPoint = window.convertPoint(fromScreen: screenPoint)
        guard contentView.bounds.contains(windowPoint) else { return false }

        // 2. Check if the mouse is within any web view's frame
        let webViews = findAllWebViews()
        var mouseIsOverWebViewFrame = false
        for wv in webViews {
            let frameInWindow = wv.convert(wv.bounds, to: nil)
            if frameInWindow.contains(windowPoint) {
                mouseIsOverWebViewFrame = true
                break
            }
        }
        guard mouseIsOverWebViewFrame else { return false }

        // 3. Temporarily allow hit-testing on all web views so
        //    contentView.hitTest can reach them.
        let previousStates = webViews.map { $0.isInteractionDisabled }
        for wv in webViews { wv.isInteractionDisabled = false }

        let hitView = contentView.hitTest(windowPoint)

        // Restore previous interaction states
        for (wv, wasDisabled) in zip(webViews, previousStates) {
            wv.isInteractionDisabled = wasDisabled
        }

        // 4. Walk up from the hit view — if we reach a web view,
        //    nothing is covering it at this point.
        guard let hit = hitView else { return false }
        var v: NSView? = hit
        while let current = v {
            if current is VerticalScrollPassthroughWebView { return true }
            v = current.superview
        }

        return false
    }

    // MARK: Hierarchy

    private func findAllWebViews() -> [VerticalScrollPassthroughWebView] {
        guard let window = self.window, let contentView = window.contentView else {
            return []
        }
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