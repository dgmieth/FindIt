//
//  FilterView.swift
//  Findit
//
//  Created by Diego Mieth on 2026-04-12.
//

import SwiftUI

enum FilterOptions: Hashable {
    case next14Days
    case next30Days
    case next60Days
    case custom(startDate: Date?, endDate: Date?)
    
    var rawValue: String {
        switch self {
        case .next14Days:
            return R.string.localizable.viewsFilterOptionNext14Days()
        case .next30Days:
            return R.string.localizable.viewsFilterOptionNext30Days()
        case .next60Days:
            return R.string.localizable.viewsFilterOptionNext60Days()
        case .custom:
            return R.string.localizable.viewsFilterOptionCustom()
        }
    }
    
    static var allCases: [FilterOptions] {
        [.next14Days, .next30Days, .next60Days, .custom(startDate: nil, endDate: nil)]
    }
    
    func isCustom() -> Bool {
        switch self {
        case .custom:
            return true
        default:
            return false
        }
    }
}

struct FilterView: View {
    @Binding var filterOption: FilterOptions
    
    @State private var startDate: Date = .now
    @State private var endDate: Date? = Calendar.current.date(byAdding: .day, value: 1, to: .now) ?? .now
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()
            HStack(alignment: .center, spacing: 0) {
                Text("Show results for")
                    .font(.body)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Picker("", selection: self.$filterOption) {
                    ForEach(FilterOptions.allCases, id: \.hashValue) { option in
                        Text(option.rawValue)
                            .tag(option)
                    }
                }
            }
            .pickerStyle(.wheel)
            
            if self.filterOption.isCustom() {
                HStack(alignment: .center, spacing: 0) {
                    DatePicker(
                        "From",
                        selection: self.$startDate,
                        displayedComponents: [.date]
                    )
                    
                    DatePicker(
                        "From",
                        selection: self.$endDate,
                        displayedComponents: [.date]
                    )
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 12)
    }
}

#Preview {
    @Previewable @State var filter: FilterOptions = .next14Days
    
    FilterView(filterOption: $filter)
}
