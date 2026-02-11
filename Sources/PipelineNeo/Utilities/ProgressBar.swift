//
//  ProgressBar.swift
//  Pipeline Neo • https://github.com/TheAcharya/pipeline-neo
//  © 2026 • Licensed under MIT License
//

//
//	CLI progress bar (TQDM-inspired): iterate over a sequence or update by steps.
//

import Foundation

/// A progress bar for terminal output. Not thread-safe; use from one thread (e.g. main/CLI).
public final class ProgressBar: ProgressReporter, @unchecked Sendable {

    private var total: Int?
    private var n: Int = 0
    private var lastPrintN: Int = 0
    private let minIntervalSeconds: TimeInterval = 0.1
    private let maxIntervalSeconds: TimeInterval = 10.0
    private var lastPrintTime: Date = .init()
    private var width: Int = 40
    private let unitScale: Double
    private let unitDivisor: Double
    private var startTime: Date
    private var desc: String
    private var postfix: String = ""
    private var style: ProgressBarStyle

    /// Creates a progress bar with a known total.
    public init(total: Int, desc: String = "", style: ProgressBarStyle = .default) {
        self.total = total
        self.desc = desc
        self.style = style
        unitScale = style.unitScale
        unitDivisor = style.unitDivisor
        startTime = Date()
        width = style.ncols ?? 40
    }

    /// Creates a progress bar without a known total (no percentage).
    public init(total: Int? = nil, desc: String = "", style: ProgressBarStyle = .default) {
        self.total = total
        self.desc = desc
        self.style = style
        unitScale = style.unitScale
        unitDivisor = style.unitDivisor
        startTime = Date()
        width = style.ncols ?? 40
    }

    /// Advances the bar by `n` steps and redraws when needed.
    public func update(_ n: Int = 1) {
        self.n += n
        if shouldPrint() {
            printProgress()
            lastPrintN = self.n
            lastPrintTime = Date()
        }
    }

    /// ProgressReporter conformance: advance by n steps.
    public func advance(by n: Int) {
        update(n)
    }

    /// Closes the bar and moves to the next line.
    public func close() {
        if n != lastPrintN {
            printProgress()
        }
        print()
        fflush(stdout)
    }

    /// ProgressReporter conformance: finish and newline.
    public func finish() {
        close()
    }

    /// Sets the description text.
    public func setDescription(_ desc: String) {
        self.desc = desc
        printProgress()
    }

    /// Sets the postfix text.
    public func setPostfix(_ postfix: String) {
        self.postfix = postfix
        printProgress()
    }

    private func shouldPrint() -> Bool {
        let now = Date()
        let timeSinceLastPrint = now.timeIntervalSince(lastPrintTime)
        return timeSinceLastPrint >= minIntervalSeconds ||
            (total != nil && Double(n - lastPrintN) / Double(total!) >= 0.01) ||
            timeSinceLastPrint >= maxIntervalSeconds
    }

    private func printProgress() {
        let now = Date()
        let elapsedSeconds = now.timeIntervalSince(startTime)

        var values: [String: String] = [:]

        if let total = total {
            let percentage = min(100.0, max(0.0, Double(n) / Double(total) * 100.0))
            values["percentage"] = String(format: "%3.0f%%", percentage)
        } else {
            values["percentage"] = "    "
        }

        if let total = total {
            let filledLength = min(width, max(0, Int(Double(width) * Double(n) / Double(total))))
            let bar = String(repeating: style.fill, count: filledLength) + String(repeating: style.emptyFill, count: width - filledLength)
            values["bar"] = "\(style.leftBracket)\(bar)\(style.rightBracket)"
        } else {
            values["bar"] = ""
        }

        let unit = style.unitScale == 1.0 && style.unitDivisor == 1.0 ? "" : "it"
        values["n_fmt"] = formatNumber(Double(n) * style.unitScale / style.unitDivisor)
        values["total_fmt"] = total.map { formatNumber(Double($0) * style.unitScale / style.unitDivisor) } ?? "?"
        values["unit"] = unit

        if elapsedSeconds > 0 {
            let rate = Double(n) / elapsedSeconds
            let scaledRate = rate * style.unitScale / style.unitDivisor
            let unitSuffix = unit.isEmpty ? "it" : unit
            values["rate_fmt"] = String(format: "%.2f %@/s", scaledRate, unitSuffix)
        } else {
            values["rate_fmt"] = "? it/s"
        }

        values["elapsed"] = formatInterval(elapsedSeconds)

        if let total = total, n > 0 {
            let remainingSeconds = elapsedSeconds * Double(total - n) / Double(n)
            values["remaining"] = formatInterval(remainingSeconds)
        } else {
            values["remaining"] = "?"
        }

        values["desc"] = desc
        values["postfix"] = postfix
        values["l_bar"] = "\(values["desc"]!) \(values["percentage"]!)\(style.barSeparator)"

        var output = style.barFormat.format
        for (key, value) in values {
            output = output.replacingOccurrences(of: "{\(key)}", with: value)
        }

        if let barColor = style.barColor, let barStr = values["bar"] {
            let coloredBar = barColor.rawValue + barStr + ProgressBarStyle.Color.reset.rawValue
            output = output.replacingOccurrences(of: barStr, with: coloredBar)
        }
        if let descColor = style.descColor, let descStr = values["desc"] {
            let coloredDesc = descColor.rawValue + descStr + ProgressBarStyle.Color.reset.rawValue
            output = output.replacingOccurrences(of: descStr, with: coloredDesc)
        }

        print("\r\(output)", terminator: "")
        fflush(stdout)
    }

    private func formatInterval(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        let seconds = Int(interval) % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func formatNumber(_ n: Double) -> String {
        if n >= 1_000_000_000 {
            return String(format: "%.1fB", n / 1_000_000_000)
        } else if n >= 1_000_000 {
            return String(format: "%.1fM", n / 1_000_000)
        } else if n >= 1000 {
            return String(format: "%.1fK", n / 1000)
        }
        return String(format: "%.1f", n)
    }
}
