//
//  BottomDialogView.swift
//  CarExample
//
//  Created by やきそば on 2025/03/22.
//  Copyright © 2025 Apple. All rights reserved.
//

import SwiftUI

struct BottomDialogView: View {
    @Binding var mes: String
    
    var body: some View {
        VStack {
            Spacer()
            VStack {
                Text(mes)
                    .padding()
            }
            .frame(maxWidth: 300)
            .background(.ultraThinMaterial)
            .cornerRadius(16)
            .padding()
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

#Preview {
    BottomDialogView(mes: .constant("test"))
}
