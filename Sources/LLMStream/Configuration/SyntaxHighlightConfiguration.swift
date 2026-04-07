//
//  SyntaxHighlightConfiguration.swift
//  LLMStream
//

import SwiftUI

/// Identifies a built-in highlight.js theme by name.
public enum HighlightJSTheme: String, CaseIterable, Sendable {
    case `default` = "default"
    case a11yDark = "a11y-dark"
    case a11yLight = "a11y-light"
    case agate = "agate"
    case androidstudio = "androidstudio"
    case atomOneDark = "atom-one-dark"
    case atomOneDarkReasonable = "atom-one-dark-reasonable"
    case atomOneLight = "atom-one-light"
    case dark = "dark"
    case devibeans = "devibeans"
    case felipec = "felipec"
    case foundation = "foundation"
    case github = "github"
    case githubDark = "github-dark"
    case githubDarkDimmed = "github-dark-dimmed"
    case googlecode = "googlecode"
    case gradientDark = "gradient-dark"
    case gradientLight = "gradient-light"
    case grayscale = "grayscale"
    case hybrid = "hybrid"
    case idea = "idea"
    case intellijLight = "intellij-light"
    case irBlack = "ir-black"
    case monokaiSublime = "monokai-sublime"
    case monokai = "monokai"
    case nightOwl = "night-owl"
    case nord = "nord"
    case obsidian = "obsidian"
    case pandaSyntaxDark = "panda-syntax-dark"
    case pandaSyntaxLight = "panda-syntax-light"
    case rosePine = "rose-pine"
    case rosePineDawn = "rose-pine-dawn"
    case rosePineMoon = "rose-pine-moon"
    case shadesOfPurple = "shades-of-purple"
    case srcery = "srcery"
    case stackoverflowDark = "stackoverflow-dark"
    case stackoverflowLight = "stackoverflow-light"
    case sunburst = "sunburst"
    case tokyoNightDark = "tokyo-night-dark"
    case tokyoNightLight = "tokyo-night-light"
    case tomorrowNightBlue = "tomorrow-night-blue"
    case tomorrowNightBright = "tomorrow-night-bright"
    case vs = "vs"
    case vs2015 = "vs2015"
    case xcode = "xcode"
    case xt256 = "xt256"

    /// CDN URL for this theme's CSS file.
    public var cdnURL: String {
        "https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/\(rawValue).min.css"
    }

    /// The background color used by this theme's `.hljs` class.
    public var backgroundColor: String {
        switch self {
        case .default:                   return "#F3F3F3"
        case .a11yDark:                  return "#2B2B2B"
        case .a11yLight:                 return "#FEFEFE"
        case .agate:                     return "#333"
        case .androidstudio:             return "#282B2E"
        case .atomOneDark:               return "#282C34"
        case .atomOneDarkReasonable:     return "#282C34"
        case .atomOneLight:              return "#FAFAFA"
        case .dark:                      return "#444"
        case .devibeans:                 return "#1F1F1F"
        case .felipec:                   return "#1F1F1F"
        case .foundation:                return "#EEEEEE"
        case .github:                    return "#F8F8F8"
        case .githubDark:                return "#0D1117"
        case .githubDarkDimmed:          return "#22272E"
        case .googlecode:                return "#FFFFFF"
        case .gradientDark:              return "#1A1A2E"
        case .gradientLight:             return "#F0F0F0"
        case .grayscale:                 return "#FAFAFA"
        case .hybrid:                    return "#1D1F21"
        case .idea:                      return "#FFFFFF"
        case .intellijLight:             return "#FFFFFF"
        case .irBlack:                   return "#000000"
        case .monokaiSublime:            return "#23241F"
        case .monokai:                   return "#272822"
        case .nightOwl:                  return "#011627"
        case .nord:                      return "#2E3440"
        case .obsidian:                  return "#282B2E"
        case .pandaSyntaxDark:           return "#292A2B"
        case .pandaSyntaxLight:          return "#E6E6E6"
        case .rosePine:                  return "#191724"
        case .rosePineDawn:              return "#FAF4ED"
        case .rosePineMoon:              return "#232136"
        case .shadesOfPurple:            return "#2D2B57"
        case .srcery:                    return "#1C1B19"
        case .stackoverflowDark:         return "#1C1B1B"
        case .stackoverflowLight:        return "#FFFFFF"
        case .sunburst:                  return "#000000"
        case .tokyoNightDark:            return "#1A1B26"
        case .tokyoNightLight:           return "#D5D6DB"
        case .tomorrowNightBlue:         return "#002451"
        case .tomorrowNightBright:       return "#000000"
        case .vs:                        return "#FFFFFF"
        case .vs2015:                    return "#1E1E1E"
        case .xcode:                     return "#FFFFFF"
        case .xt256:                     return "#000000"
        }
    }

    /// The base text color defined by this hljs theme (the `.hljs` color property).
    /// This matches the color used for variables, parameters, and plain identifiers.
    public var textColor: String {
        switch self {
        case .default:                   return "#444"
        case .a11yDark:                  return "#F8F8F2"
        case .a11yLight:                 return "#545454"
        case .agate:                     return "#DDD"
        case .androidstudio:             return "#A9B7C6"
        case .atomOneDark:               return "#ABB2BF"
        case .atomOneDarkReasonable:     return "#ABB2BF"
        case .atomOneLight:              return "#383A42"
        case .dark:                      return "#DDD"
        case .devibeans:                 return "#ABB2BF"
        case .felipec:                   return "#F8F8F2"
        case .foundation:                return "#000000"
        case .github:                    return "#333333"
        case .githubDark:                return "#C9D1D9"
        case .githubDarkDimmed:          return "#ADBAC7"
        case .googlecode:                return "#000000"
        case .gradientDark:              return "#E0E0E0"
        case .gradientLight:             return "#333333"
        case .grayscale:                 return "#333333"
        case .hybrid:                    return "#C5C8C6"
        case .idea:                      return "#000000"
        case .intellijLight:             return "#000000"
        case .irBlack:                   return "#F8F8F8"
        case .monokaiSublime:            return "#F8F8F2"
        case .monokai:                   return "#DDD"
        case .nightOwl:                  return "#D6DEEB"
        case .nord:                      return "#D8DEE9"
        case .obsidian:                  return "#E0E2E4"
        case .pandaSyntaxDark:           return "#E6E6E6"
        case .pandaSyntaxLight:          return "#2A2A2A"
        case .rosePine:                  return "#E0DEF4"
        case .rosePineDawn:              return "#575279"
        case .rosePineMoon:              return "#E0DEF4"
        case .shadesOfPurple:            return "#E3DFFF"
        case .srcery:                    return "#FCE8C3"
        case .stackoverflowDark:         return "#FFFFFF"
        case .stackoverflowLight:        return "#2F3337"
        case .sunburst:                  return "#F8F8F8"
        case .tokyoNightDark:            return "#9AA5CE"
        case .tokyoNightLight:           return "#343B58"
        case .tomorrowNightBlue:         return "#FFFFFF"
        case .tomorrowNightBright:       return "#EAEAEA"
        case .vs:                        return "#000000"
        case .vs2015:                    return "#DCDCDC"
        case .xcode:                     return "#000000"
        case .xt256:                     return "#EAEAEA"
        }
    }

    /// Whether this is a dark theme.
    public var isDark: Bool {
        switch self {
        case .a11yLight, .atomOneLight, .foundation, .github, .googlecode,
             .gradientLight, .grayscale, .idea, .intellijLight,
             .pandaSyntaxLight, .rosePineDawn, .stackoverflowLight,
             .tokyoNightLight, .vs, .xcode, .default:
            return false
        default:
            return true
        }
    }
}

/// Configuration for syntax highlighting theme selection (light/dark mode).
public struct SyntaxHighlightConfiguration {
    public var lightTheme: HighlightJSTheme
    public var darkTheme: HighlightJSTheme

    public init(
        lightTheme: HighlightJSTheme = .github,
        darkTheme: HighlightJSTheme = .githubDark
    ) {
        self.lightTheme = lightTheme
        self.darkTheme = darkTheme
    }

    /// Inline SVG for the copy icon, encoded as a data URI for use in CSS mask-image.
    /// This avoids relative URL resolution issues in WKWebView masks.
    private static let copyIconDataURI = "url(\"data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='black' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Crect x='9' y='9' width='13' height='13' rx='2' ry='2'/%3E%3Cpath d='M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1'/%3E%3C/svg%3E\")"

    func generateOverrideCSS() -> String {
        let copyIcon = Self.copyIconDataURI
        return """
        /* ═══ Light mode ═══ */
        @media (prefers-color-scheme: light) {
            pre code.hljs {
                background: \(lightTheme.backgroundColor) !important;
            }

            .code-container {
                background: \(lightTheme.backgroundColor) !important;
                border-color: \(lightTheme.backgroundColor) !important;
            }

            .code-title-bar {
                background: \(lightTheme.backgroundColor) !important;
                border-bottom-color: \(lightTheme.isDark ? "rgba(255,255,255,0.1)" : "rgba(0,0,0,0.08)") !important;
            }

            .code-title-bar .language {
                color: \(lightTheme.textColor) !important;
            }

            .code-title-bar .copy-button {
                background-image: none !important;
                background-color: \(lightTheme.textColor) !important;
                -webkit-mask-image: \(copyIcon) !important;
                -webkit-mask-size: contain !important;
                -webkit-mask-repeat: no-repeat !important;
                -webkit-mask-position: center !important;
                mask-image: \(copyIcon) !important;
                mask-size: contain !important;
                mask-repeat: no-repeat !important;
                mask-position: center !important;
                opacity: 1 !important;
                filter: none !important;
            }
            .code-title-bar .copy-button:hover {
                background-color: \(lightTheme.textColor) !important;
                opacity: 0.7 !important;
            }

            .code-content {
                background: \(lightTheme.backgroundColor) !important;
            }
            .code-content pre {
                background: \(lightTheme.backgroundColor) !important;
            }
        }

        /* ═══ Dark mode ═══ */
        @media (prefers-color-scheme: dark) {
            pre code.hljs {
                background: \(darkTheme.backgroundColor) !important;
            }

            .code-container {
                background: \(darkTheme.backgroundColor) !important;
                border-color: \(darkTheme.backgroundColor) !important;
            }

            .code-title-bar {
                background: \(darkTheme.backgroundColor) !important;
                border-bottom-color: \(darkTheme.isDark ? "rgba(255,255,255,0.1)" : "rgba(0,0,0,0.08)") !important;
            }

            .code-title-bar .language {
                color: \(darkTheme.textColor) !important;
            }

            .code-title-bar .copy-button {
                background-image: none !important;
                background-color: \(darkTheme.textColor) !important;
                -webkit-mask-image: \(copyIcon) !important;
                -webkit-mask-size: contain !important;
                -webkit-mask-repeat: no-repeat !important;
                -webkit-mask-position: center !important;
                mask-image: \(copyIcon) !important;
                mask-size: contain !important;
                mask-repeat: no-repeat !important;
                mask-position: center !important;
                opacity: 1 !important;
                filter: none !important;
            }
            .code-title-bar .copy-button:hover {
                background-color: \(darkTheme.textColor) !important;
                opacity: 0.7 !important;
            }

            .code-content {
                background: \(darkTheme.backgroundColor) !important;
            }
            .code-content pre {
                background: \(darkTheme.backgroundColor) !important;
            }
        }
        """
    }
}