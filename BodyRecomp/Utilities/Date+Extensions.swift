import Foundation

extension Date {
    /// Midnight of the day containing this date
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    /// Monday of the ISO week containing this date
    var mondayOfWeek: Date {
        var cal = Calendar(identifier: .iso8601)
        cal.firstWeekday = 2 // Monday
        let comps = cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return cal.date(from: comps) ?? self
    }

    /// All 7 days Mon–Sun of the week containing this date
    var weekDays: [Date] {
        let monday = mondayOfWeek
        return (0..<7).compactMap { Calendar.current.date(byAdding: .day, value: $0, to: monday) }
    }

    var isSameDay: (Date) -> Bool {
        { other in Calendar.current.isDate(self, inSameDayAs: other) }
    }

    var isToday: Bool { Calendar.current.isDateInToday(self) }

    var shortDayLabel: String {
        let f = DateFormatter()
        f.dateFormat = "EEE"
        return f.string(from: self)
    }

    var dayNumber: String {
        let f = DateFormatter()
        f.dateFormat = "d"
        return f.string(from: self)
    }

    var monthDayLabel: String {
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return f.string(from: self)
    }

    /// ISO 8601 date string
    var isoDateString: String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f.string(from: self)
    }
}

extension Calendar {
    static var iso: Calendar {
        var cal = Calendar(identifier: .iso8601)
        cal.firstWeekday = 2
        return cal
    }
}
