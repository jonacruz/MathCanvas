//
//  File.swift
//  MathCanvas
//
//  Created by Jonathan Abimael on 05/03/26.
//

import Foundation

// PlatformTypes.swift
#if canImport(UIKit)
import UIKit
public typealias PlatformColor = UIColor
public typealias PlatformFont = UIFont
#elseif canImport(AppKit)
import AppKit
public typealias PlatformColor = NSColor
public typealias PlatformFont = NSFont
#endif
