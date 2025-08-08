//
//  ProgressRingView.swift
//  AdoraWellness
//
//  Created by Hashini Ranasinghe on 2025-08-08.
//
import SwiftUI

struct ProgressRingView: View {
    let progress: Double
    let lineWidth: CGFloat = 8
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: lineWidth)
            
            // Progress circle
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    Color(red: 0.4, green: 0.3, blue: 0.8),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 1.0), value: progress)
            
            // Progress text
            Text("\(Int(progress * 100))%")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
        }
    }
}
