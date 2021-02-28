//
//  ActivityIndicator.swift
//  Courser
//
//  Created by c on 2021/2/28.
//

import Foundation
import SwiftUI

/// 等待进度条
///
/// Refer: [stackoverflow #activity-indicator-in-swiftui](https://stackoverflow.com/questions/56496638/activity-indicator-in-swiftui)
///
/// Xcode 12 可以用 SwiftUI 的 ProgressView 替代
struct ActivityIndicator: UIViewRepresentable {
    @Binding var isAnimating: Bool
    
    let style: UIActivityIndicatorView.Style
    
    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style)
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}
