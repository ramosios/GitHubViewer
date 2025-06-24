//
//  WebView.swift
//  GitHubViewer
//
//  Created by Jorge Ramos on 23/06/25.
//
//  Displays a GitHub repository webpage using WKWebView inside a SwiftUI wrapper.
//  Includes navigation and share functionality.
//

import SwiftUI
import WebKit

/// A `UIViewRepresentable` wrapper for displaying web content using `WKWebView`.
struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
    }
}

/// A SwiftUI view presenting a GitHub page with share and dismiss controls.
struct WebViewer: View {
    let url: URL
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            WebView(url: url)
                .navigationTitle(url.host ?? "GitHub")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    // Dismiss button
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Done") {
                            dismiss()
                        }
                    }

                    // Share button
                    ToolbarItem(placement: .primaryAction) {
                        ShareLink(item: url) {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                }
        }
    }
}
