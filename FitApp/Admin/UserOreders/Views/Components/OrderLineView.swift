//
//  OrderLineView.swift
//  FitApp
//
//  Created by Ofir Elias on 29/07/2023.
//

import SwiftUI

struct OrderLineView: View {
    
    var title: String
    var subTitle: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
            Text(subTitle)
                .font(.body)
        }
    }
}
