//
//  CircularProgressView.swift
//  auther
//
//  Created by Nafish Ahmed on 04/07/25.
//

import SwiftUI

struct CircularProgressView: View {
    let progress: Double // Should be between 0.0 and 1.0
    var lineWidth: CGFloat = 10
    var primaryColor: Color = .blue
    var secondaryColor: Color = Color.blue.opacity(0.3)
    var animationDuration: Double = 0.5

    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(secondaryColor, lineWidth: lineWidth)

            // Progress arc
            ProgressArc(progress: progress)
                .stroke(primaryColor, lineWidth: lineWidth)
                .rotationEffect(.degrees(-90)) // Start from the top
                .animation(.easeOut(duration: animationDuration), value: progress)
        }
    }
}

// Custom Shape for the progress arc
struct ProgressArc: Shape, Animatable {
    var progress: Double

    // Conformance to Animatable for smooth transitions
    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addArc(center: CGPoint(x: rect.midX, y: rect.midY),
                    radius: rect.width / 2,
                    startAngle: .degrees(0),
                    endAngle: .degrees(360 * progress),
                    clockwise: false)
        return path
    }
}
