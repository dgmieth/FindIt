//
//  FilterView.swift
//  Findit
//
//  Created by Diego Mieth on 2026-04-12.
//

import SwiftUI

enum FilterOptions: Hashable, CaseIterable {
    case next14Days
    case next30Days
    case next60Days
    case custom
    
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
}

private struct DatePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selection: Date
    let label: String
    let range: ClosedRange<Date>
    
    var body: some View {
        VStack(spacing: 0) {
            DatePicker(
                label,
                selection: $selection,
                in: range,
                displayedComponents: [.date]
            )
            .datePickerStyle(.graphical)
            .padding(.horizontal)
            .onChange(of: selection) { _, _ in dismiss() }
        }
    }
}

struct FilterView: View {
    @Environment(\.dismiss) private var dismiss
    @State var filterOption: FilterOptions
    @State var startDate: Date?
    @State var endDate: Date?
    
    @State private var showStartPicker = false
    @State private var showEndPicker = false
    
    let onApply: (FilterOptions, Date?, Date?) -> Void
    
    init(filterOption: FilterOptions, startDate: Date?, endDate: Date?, onApply: @escaping (FilterOptions, Date?, Date?) -> Void) {
        self.filterOption = filterOption
        self.startDate = startDate
        self.endDate = endDate
        self.onApply = onApply
    }
    
    private var today: Date { Calendar.current.startOfDay(for: .now) }
    
    private var startDateBinding: Binding<Date> {
        Binding(
            get: { startDate ?? today },
            set: { startDate = $0 }
        )
    }
    
    private var endDateBinding: Binding<Date> {
        Binding(
            get: { endDate ?? Calendar.current.date(byAdding: .day, value: 1, to: today) ?? today },
            set: { endDate = $0 }
        )
    }
    
    private var startDateRange: ClosedRange<Date> {
        let min = today
        if let end = endDate, end >= min {
            return min...end
        }
        return min...Date.distantFuture
    }
    
    private var endDateRange: ClosedRange<Date> {
        let min: Date
        if let start = startDate, start >= today {
            min = start
        } else {
            min = today
        }
        return min...Date.distantFuture
    }
    
    private var showResultsDisabled: Bool {
        switch self.filterOption {
        case .custom:
            return self.startDate == nil && self.endDate == nil
        default:
            return false
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()
            HStack(alignment: .center, spacing: 0) {
                Text(R.string.localizable.viewsFilterPickerTitle())
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
            
            if self.filterOption == .custom {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(R.string.localizable.viewsFilterDatePickerFrom())
                            .font(.body)
                        Spacer()
                        Button(
                            startDate.map {
                                DateFormatter.formatter(
                                    for: .apiQueryFormat
                                )
                                .string(from: $0) } ?? R.string.localizable.viewsFilterDatePickerSelectDate()
                        ) {
                            showStartPicker = true
                        }
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(startDate == nil ? Color.secondary : Color.accentColor)
                        .padding(.horizontal, 10)
                        .frame(minWidth: 44, minHeight: 44)
                        .background(Color(.systemFill), in: RoundedRectangle(cornerRadius: 8))
                    }
                    
                    HStack {
                        Text(R.string.localizable.viewsFilterDatePickerTo())
                            .font(.body)
                        Spacer()
                        Button(
                            endDate.map {
                                DateFormatter.formatter(
                                    for: .apiQueryFormat
                                )
                                .string(from: $0) } ?? R.string.localizable.viewsFilterDatePickerSelectDate()
                        ) {
                            showEndPicker = true
                        }
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(endDate == nil ? Color.secondary : Color.accentColor)
                        .padding(.horizontal, 10)
                        .frame(minWidth: 44, minHeight: 44)
                        .background(Color(.systemFill), in: RoundedRectangle(cornerRadius: 8))
                    }
                    
                    switch (self.startDate, self.endDate) {
                    case (.some(let startDate), .some(let endDate)):
                        let startDateString = DateFormatter.formatter(for: .apiQueryFormat).string(from: startDate)
                        let endDateString = DateFormatter.formatter(for: .apiQueryFormat).string(from: endDate)
                        Text(R.string.localizable.viewsFilterOptionLowerUpperBounds(startDateString, endDateString))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .frame(alignment: .center)
                    case (.some(let startDate), _):
                        let startDateString = DateFormatter.formatter(for: .apiQueryFormat).string(from: startDate)
                        Text(R.string.localizable.viewsFilterOptionOnlyLowerBound(startDateString))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .frame(alignment: .center)
                    case (_, .some(let endDate)):
                        let endDateString = DateFormatter.formatter(for: .apiQueryFormat).string(from: endDate)
                        Text(R.string.localizable.viewsFilterOptionOnlyUpperBound(endDateString))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .frame(alignment: .center)
                    default:
                        EmptyView()
                    }
                }
                .animation(.linear, value: self.filterOption)
            }
            
            Spacer()
            
            HStack(alignment: .center, spacing: 12) {
                Button {
                    self.filterOption = .next14Days
                    self.startDate = nil
                    self.endDate = nil
                    
                    self.commitFilters()
                } label: {
                    Text(R.string.localizable.viewsFilterButtonReset())
                        .font(.body)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(
                    RoundedRectangle(cornerRadius: 8.0).stroke(.secondary, lineWidth: 1.0)
                )
                
                Button {
                    self.commitFilters()
                } label: {
                    Text(R.string.localizable.viewsFilterPickerShowResults())
                        .font(.body)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(
                    RoundedRectangle(cornerRadius: 8.0).fill(self.showResultsDisabled ? .gray : .blue)
                )
                .disabled(self.showResultsDisabled)
            }
        }
        .padding(.horizontal, 12)
        .sheet(isPresented: $showStartPicker) {
            DatePickerSheet(
                selection: startDateBinding,
                label: R.string.localizable.viewsFilterDatePickerFrom(),
                range: startDateRange
            )
            .presentationDetents([.height(400)])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showEndPicker) {
            DatePickerSheet(
                selection: endDateBinding,
                label: R.string.localizable.viewsFilterDatePickerTo(),
                range: endDateRange
            )
            .presentationDetents([.height(400)])
            .presentationDragIndicator(.visible)
        }
    }
    
    private func commitFilters() {
        self.onApply(self.filterOption, self.startDate, self.endDate)
        self.dismiss()
    }
}

#Preview {
    @Previewable @State var filter: FilterOptions = .custom
    @Previewable @State var startDate: Date? = nil
    @Previewable @State var endDate: Date? = nil
    
    FilterView(filterOption: filter, startDate: startDate, endDate: endDate) { _, _, _ in }
}
