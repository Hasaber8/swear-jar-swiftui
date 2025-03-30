//
//  Date+Extensions.swift
//  SwearJar
//
//  Created for SwearJar app
//

import Foundation

extension Date {
    /// Get string representation in "MMM d, yyyy" format (e.g., "Jan 1, 2025")
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }
    
    /// Get string representation in "h:mm a" format (e.g., "2:30 PM")
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
    
    /// Get string representation in "MMM d, yyyy h:mm a" format (e.g., "Jan 1, 2025 2:30 PM")
    var formattedDateTime: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
    
    /// Get relative date string (e.g., "Today", "Yesterday", "Last week")
    var relativeDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
    
    /// Get start of day
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    /// Get end of day
    var endOfDay: Date {
        let components = DateComponents(day: 1, second: -1)
        return Calendar.current.date(byAdding: components, to: startOfDay) ?? self
    }
    
    /// Check if date is today
    var isToday: Bool {
        return Calendar.current.isDateInToday(self)
    }
    
    /// Check if date is yesterday
    var isYesterday: Bool {
        return Calendar.current.isDateInYesterday(self)
    }
    
    /// Get date by adding days
    /// - Parameter days: Number of days to add
    /// - Returns: New date with days added
    func addingDays(_ days: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: days, to: self) ?? self
    }
    
    /// Get date by subtracting days
    /// - Parameter days: Number of days to subtract
    /// - Returns: New date with days subtracted
    func subtractingDays(_ days: Int) -> Date {
        return addingDays(-days)
    }
}