//
//  CurrentOrderView.swift
//  FitApp
//
//  Created by Ofir Elias on 27/07/2023.
//

import SwiftUI

struct CurrentOrderView: View {
    
    @StateObject var viewModel: ViewModel
    
    var body: some View {
        if viewModel.currentOrder != nil {
            Form {
                Section(header:Text("מנוי נוחכי").font(.title3)) {
                    OrderLineView(title: "מספר הזמנה:", subTitle: viewModel.currentOrderId)
                    OrderLineView(title: "מועד רכישת מנוי:", subTitle: viewModel.dateOfTransaction)
                    OrderLineView(title: "מועד סיום מנוי", subTitle: viewModel.dateOfExperation)
                    OrderLineView(title: "תקופת המנוי:", subTitle: viewModel.period + " " + "חודשים")
                    OrderLineView(title: "ימים נוצלו:", subTitle: viewModel.periodUsed)
                    OrderLineView(title: "ימים נשארו:", subTitle: viewModel.periodLeft)
                }
                
                Section(header:Text("היסטוריית רכישות").font(.title3)) {
                    ForEach(viewModel.orderIds, id: \.self) { orderId in
                        NavigationLink {
                            OrederView(viewModel: OrederView.ViewModel(userID: viewModel.userID, orderID: orderId))
                        } label: {
                            Text(orderId)
                        }
                    }
                }
            }
            .navigationTitle("רכישות")
        } else {
            ProgressView("טוען")
        }
    }
}

struct CurrentOrderView_Previews: PreviewProvider {
    static var previews: some View {
        CurrentOrderView(viewModel: CurrentOrderView.ViewModel(userID: ""))
    }
}
