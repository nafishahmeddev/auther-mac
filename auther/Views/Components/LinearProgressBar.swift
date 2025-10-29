//
//  LinearProgess.swift
//  auther
//
//  Created by Nafish Ahmed on 04/07/25.
//

import SwiftUI
import AppKit

struct LinearProgressBar: View {
    var progress: CGFloat // 0.0 to 1.0
    var height: CGFloat
    var width: CGFloat?

    var body: some View {
       GeometryReader { geometry in
           ZStack(alignment: .leading) {
               RoundedRectangle(cornerRadius: height / 2)
                   .fill(Color.gray.opacity(0.3))
                   .frame(height: height)

               RoundedRectangle(cornerRadius: height / 2)
                   .fill(Color.blue)
                   .frame(width: geometry.size.width * progress, height: height)
           }
       }
       .frame(height: height)
       .frame(maxWidth: width ?? .infinity)
        
   }
}
