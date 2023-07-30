//
//  OrederView.swift
//  FitApp
//
//  Created by Ofir Elias on 27/07/2023.
//

import SwiftUI

struct OrederView: View {
    
    @StateObject var viewModel: ViewModel
    
    var body: some View {
        
        if viewModel.order != nil {
            Form {
                Section(header:Text("פרטי מנוי").font(.title3)) {
                    OrderLineView(title: "מועד רכישת מנוי:", subTitle: viewModel.dateOfTranasction)
                    OrderLineView(title: "תקופת מנוי:", subTitle: viewModel.period)
                    OrderLineView(title: "מחיר:", subTitle: viewModel.transactionAmount)
                    OrderLineView(title: "כתובת:", subTitle: viewModel.address)
                    OrderLineView(title: "טלפון:", subTitle: viewModel.phoneNumber)
                    OrderLineView(title: "אימייל:", subTitle: viewModel.email)
                }
            }
            .navigationTitle(viewModel.orderID)
        } else {
            ProgressView("טוען")
        }
    }
}

struct OrederView_Previews: PreviewProvider {
    static var previews: some View {
        OrederView(viewModel: OrederView.ViewModel(userID: "", orderID: ""))
    }
}
