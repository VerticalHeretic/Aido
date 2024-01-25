//
//  Logger+init.swift
//  Aido
//
//  Created by Łukasz Stachnik on 25/01/2024.
//

import Foundation
import OSLog

extension Logger {

    private static var subsystem = Bundle.main.bundleIdentifier!

    static let general = Logger(subsystem: subsystem, category: "General")

}

