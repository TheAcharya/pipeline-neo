//
//  FCPXMLUtility.swift
//  Pipeline Neo • https://github.com/TheAcharya/pipeline-neo
//  © 2025 • Licensed under MIT License
//

import Foundation
import CoreMedia
import SwiftTimecode

#if canImport(Logging)
import Logging
#endif

/// Contains miscellaneous utility methods for processing FCPXML data with modern Swift concurrency support.
@available(macOS 12.0, *)
public final class FCPXMLUtility: @unchecked Sendable {
	
	// MARK: - Dependencies
	
	private let parser: FCPXMLParsing & FCPXMLElementFiltering
	private let timecodeConverter: TimecodeConversion & FCPXMLTimeStringConversion & TimeConforming
	private let documentManager: XMLDocumentOperations & XMLElementOperations
	private let errorHandler: ErrorHandling
	
	// MARK: - Initializing
	
	/// Initializer with dependency injection
	public init(
		parser: FCPXMLParsing & FCPXMLElementFiltering = FCPXMLParser(),
		timecodeConverter: TimecodeConversion & FCPXMLTimeStringConversion & TimeConforming = TimecodeConverter(),
		documentManager: XMLDocumentOperations & XMLElementOperations = XMLDocumentManager(),
		errorHandler: ErrorHandling = ErrorHandler()
	) {
		self.parser = parser
		self.timecodeConverter = timecodeConverter
		self.documentManager = documentManager
		self.errorHandler = errorHandler
	}

	// MARK: - Default for Extension APIs

	/// Default instance used by extension APIs (e.g. `XMLElement.fcpxDuration`, `XMLDocument.fcpxAssetResources`) that cannot receive dependency injection. Concurrency-safe (immutable). For custom implementations use the modular API: inject dependencies into `FCPXMLService` / `FCPXMLUtility` and use the `+Modular` extensions (e.g. `element.setAttribute(name:value:using: documentManager)`) or service methods.
	public static let defaultForExtensions: FCPXMLUtility = FCPXMLUtility()
	
	// MARK: - Retrieval Methods
	
	/// Returns an array of elements that match specified FCPXML element types.
	///
	/// - Parameters:
	///   - elements: An array of XMLElement objects
	///   - types: An array of FCPXMLElementType enumeration values
	/// - Returns: A filtered array of XMLElement objects
	public func filter(fcpxElements elements: [XMLElement], ofTypes types: [FCPXMLElementType]) -> [XMLElement] {
		return parser.filter(elements: elements, ofTypes: types)
	}
	
	// MARK: - Time Conversion Methods
	
	/// Creates a CMTime value that represents real time from timecode values.
	///
	/// - Parameters:
	///   - timecodeHours: The hours element of the timecode value.
	///   - timecodeMinutes: The minutes element of the timecode value.
	///   - timecodeSeconds: The seconds element of the timecode value.
	///   - timecodeFrames: The frames element of the timecode value.
	///   - frameDuration: The duration of a single frame as a CMTime value.
	/// - Returns: A CMTime value equivalent to the timecode value in real time.
	public func CMTimeFrom(timecodeHours: Int, timecodeMinutes: Int, timecodeSeconds: Int, timecodeFrames: Int, frameDuration: CMTime) -> CMTime {
		return timecodeConverter.cmTimeFrom(timecodeHours: timecodeHours, timecodeMinutes: timecodeMinutes, timecodeSeconds: timecodeSeconds, timecodeFrames: timecodeFrames, frameDuration: frameDuration)
	}

	/// Converts an FCPXML time value to a CMTime value.
	///
	/// - Parameter timeString: The FCPXML time value as a string.
	/// - Returns: The equivalent CMTime value.
	public func CMTime(fromFCPXMLTime timeString: String) -> CMTime {
		return timecodeConverter.cmTime(fromFCPXMLTime: timeString)
	}
	
	/// Converts a CMTime value to an FCPXML time value.
	///
	/// - Parameter time: A CMTime value to convert.
	/// - Returns: The FCPXML time value as a string.
	public func fcpxmlTime(fromCMTime time: CMTime) -> String {
		return timecodeConverter.fcpxmlTime(fromCMTime: time)
	}
	
	/// Conforms a given CMTime value to the frameDuration so that the value falls on an edit frame boundary. The function rounds the edit frame down.
	///
	/// - Parameters:
	///   - time: A CMTime value to conform.
	///   - frameDuration: The frame duration to conform to, represented as a CMTime.
	/// - Returns: A CMTime of the conformed value.
	public func conform(time: CMTime, toFrameDuration frameDuration: CMTime) -> CMTime {
		return timecodeConverter.conform(time: time, toFrameDuration: frameDuration)
	}
	
	/// Converts a project counter value to the project's timecode.
	///
	/// - Parameters:
	///   - counterValue: The counter value to convert.
	///   - project: The project to convert against, as an NSXMLElement.
	/// - Returns: An optional CMTime value of the timecode value.
	@available(*, deprecated, message: "Use sequenceTimecode(fromCounterValue:inSequence:) instead.")
	public func projectTimecode(fromCounterValue counterValue: CMTime, inProject project: XMLElement) -> CMTime? {
		
        guard let projectSequence = project.fcpxProjectSequence else {
            return nil
        }
        
		guard let projectSequenceTCStart = projectSequence.fcpxTCStart else {
			return nil
		}
		
		let timecodeValue = CMTimeAdd(projectSequenceTCStart, counterValue)
		
		return timecodeValue
	}
	
	/// Converts a project timecode value to the project's counter time.
	///
	/// - Parameters:
	///   - timecodeValue: The timecode value to convert.
	///   - project: The project to convert against, as an NSXMLElement.
	/// - Returns: An optional CMTime value of the counter time.
	@available(*, deprecated, message: "Use sequenceCounterTime(fromTimecodeValue:inSequence:) instead.")
	public func projectCounterTime(fromTimecodeValue timecodeValue: CMTime, inProject project: XMLElement) -> CMTime? {
		
        // Convert the timecode values to sequence counter time values
        guard let projectSequence = project.fcpxProjectSequence else {
            return nil
        }
		
		guard let projectSequenceTCStart = projectSequence.fcpxTCStart else {
			return nil
		}
		
		let counterValue = CMTimeSubtract(timecodeValue, projectSequenceTCStart)
		
		return counterValue
	}
    
    /// Converts a sequence counter value to the sequence's timecode.
    ///
    /// - Parameters:
    ///   - counterValue: The counter value to convert.
    ///   - sequence: The sequence to convert against, as an NSXMLElement.
    /// - Returns: An optional CMTime value of the timecode value.
    public func sequenceTimecode(fromCounterValue counterValue: CMTime, inSequence sequence: XMLElement) -> CMTime? {
        
        guard sequence.fcpxType == .sequence else {
            return nil
        }
        
        guard let sequenceTCStart = sequence.fcpxTCStart else {
            return nil
        }
        
        let timecodeValue = CMTimeAdd(sequenceTCStart, counterValue)
        
        return timecodeValue
    }
    
    /// Converts a sequence timecode value to the sequence counter time.
    ///
    /// - Parameters:
    ///   - timecodeValue: The timecode value to convert.
    ///   - sequence: The sequence to convert against, as an NSXMLElement.
    /// - Returns: An optional CMTime value of the counter time.
    public func sequenceCounterTime(fromTimecodeValue timecodeValue: CMTime, inSequence sequence: XMLElement) -> CMTime? {
        
        // Convert the timecode values to sequence counter time values
        guard sequence.fcpxType == .sequence else {
            return nil
        }
        
        guard let sequenceTCStart = sequence.fcpxTCStart else {
            return nil
        }
        
        let counterValue = CMTimeSubtract(timecodeValue, sequenceTCStart)
        
        return counterValue
    }
	
	/// Converts a local time value to a clip's parent time value. In FCPXML, this would be converting a time value that is in the start value timescale to the offset value timescale.
	///
	/// For example, if a clip on the primary storyline has an attached clip, this will convert the attached clip's offset value to its parent clip's offset value timescale.
	///
	/// - Parameters:
	///   - fromLocalTime: The local time value to convert.
	///   - forClip: The clip to convert against.
	/// - Returns: A CMTime value of the resulting parent time value.
	public func parentTime(fromLocalTime localTimeValue: CMTime, forClip clip: XMLElement) -> CMTime? {
		
		guard let parentInPoint = clip.fcpxParentInPoint else {
			return nil
		}
		
		let localTimeOffset = CMTimeSubtract(localTimeValue, clip.fcpxLocalInPoint)
		
		let localTimeAsParentTime = CMTimeAdd(parentInPoint, localTimeOffset)
		
		return localTimeAsParentTime
	}
	
	/// Converts a parent time value to a clip's local time value. In FCPXML, this would be converting a time value that is in the offset value timescale to the start value timescale.
	///
	/// For example, if a clip on the primary storyline has an attached clip, this will tell you what the attached clip's offset should be based on where you want it to be placed along the primary storyline.
	///
	/// - Parameters:
	///   - fromParentTime: The parent time value to convert.
	///   - forClip: The clip to convert against.
	/// - Returns: A CMTime value of the resulting parent time value.
	public func localTime(fromParentTime parentTimeValue: CMTime, forClip clip: XMLElement) -> CMTime? {
		
		guard let parentInPoint = clip.fcpxParentInPoint else {
			return nil
		}
		
		let parentTimeOffset = CMTimeSubtract(parentTimeValue, parentInPoint)
		
		let parentTimeAsLocalTime = CMTimeAdd(clip.fcpxLocalInPoint, parentTimeOffset)
		
		return parentTimeAsLocalTime
	}
	
	/// Provides the start time of the given clip within the project timeline.
	///
	/// - Parameters:
	///   - forClip: The clip on the timeline to return the start time value for. The clip can be a clip on the primary storyline, a secondary storyline or it can be a connected clip.
	///   - inProject: The project that the clip resides in.
	/// - Returns: A CMTime value of the resulting project time value.
	public func projectTime(forClip clip: XMLElement, inProject project: XMLElement) -> CMTime? {
		
		guard let clipElementOffset = clip.fcpxOffset else {
			debugLog("clipElementOffset is nil")
			return nil
		}
		
		var startTime: CMTime
		let clipParentElement = clip.parent as! XMLElement
		if clipParentElement.name == "spine" && clipParentElement.fcpxOffset != nil { // If the clip is in a secondary storyline
			
			guard let spineOffset = clipParentElement.fcpxOffset else {
				debugLog("spineOffset is nil")
				return nil
			}
			
			guard let spineParent = clipParentElement.parent else {
				debugLog("spineParent is nil")
				return nil
			}
			
			let spineParentElement = spineParent as! XMLElement
			
			let newSpineOffset = CMTimeAdd(spineOffset, clipElementOffset)
			
			guard let spineParentOffset = self.parentTime(fromLocalTime: newSpineOffset, forClip: spineParentElement) else {
				debugLog("spineParentOffset is nil")
				return nil
			}
			
			startTime = spineParentOffset
			
		} else if clipParentElement.name != "spine" { // If the clip is an attached clip
			
			guard let clipOffset = self.parentTime(fromLocalTime: clipElementOffset, forClip: clipParentElement) else {
				return nil
			}
			
			startTime = clipOffset
			
		} else { // If the clip is in the primary storyline or any other case
			
			guard let clipOffset = clip.fcpxOffset else {
				return nil
			}
			
			startTime = clipOffset
			
		}
		
		return startTime
	}
	
	/// Returns the clip's parent's equivalent offset timings for the specified in and out times. This is useful for walking up an XMLElement hierarchy in order to get the time values of the clip on the project timeline.
	///
	/// - Parameters:
	///   - inTime: The in time to convert, given as a CMTime value.
	///   - outTime: The out time to convert, given as a CMTime value.
	///   - clip: The clip that the time values are from. The parent time values will be drawn from this clip's parent.
	/// - Returns: A tuple of the converted in time, the converted out time, and the parent XMLElement of the specified clip.
	public func parentClipTime(forInTime inTime: CMTime, outTime: CMTime, forClip clip: XMLElement) -> (in: CMTime, out: CMTime, parent: XMLElement)? {
		
		guard let parentClip = clip.parentElement else {
			return nil
		}
		
		guard let parentIn = self.parentTime(fromLocalTime: inTime, forClip: parentClip) else {
			return nil
		}
		
		guard let parentOut = self.parentTime(fromLocalTime: outTime, forClip: parentClip) else {
			return nil
		}
		
		return (parentIn, parentOut, parentClip)
	}
	
	// MARK: - SwiftTimecode Integration
	
	/// Converts a CMTime to a SwiftTimecode Timecode object.
	///
	/// - Parameters:
	///   - time: The CMTime to convert
	///   - frameRate: The frame rate for the timecode
	/// - Returns: A Timecode object or nil if conversion fails
	public func timecode(from time: CMTime, frameRate: TimecodeFrameRate) -> Timecode? {
		do {
			// Convert CMTime to real time (seconds) and create Timecode
			let realTime = time.seconds
			return try Timecode(.realTime(seconds: realTime), at: frameRate)
		} catch {
			return nil
		}
	}
	
	/// Converts a SwiftTimecode Timecode object to CMTime.
	///
	/// - Parameter timecode: The Timecode object to convert
	/// - Returns: A CMTime value
	public func cmTime(from timecode: Timecode) -> CMTime {
		// Convert Timecode to real time and create CMTime
		let realTime = timecode.realTimeValue
		return CoreMedia.CMTime(seconds: realTime, preferredTimescale: 60000)
	}
	
	// MARK: - Async Methods
	
	/// Asynchronously converts line breaks in attributes to safe XML entities in an XML file.
	///
	/// When text values contain line breaks, such as in markers, Final Cut Pro X exports FCPXML files with the line break as is, not encoded into a valid XML line break character. This function will replace line breaks in _attribute nodes_ in FCPXML files with the &#xA; character entity.
	///
	/// - Parameter url: A URL object pointing to the XML file to convert.
	/// - Returns: An XMLDocument or nil if there was a file read or conversion error.
	public func convertLineBreaksInAttributes(inXMLDocumentURL url: URL) async -> XMLDocument? {
		
		do {
			let document = try String(contentsOf: url, encoding: .utf8)
			
			let splitDocument = document.components(separatedBy: "=\"")
			var newSplitDocument: [String] = []
			var skipNextNewLineReplacement = false
			
			for segment in splitDocument {
				
				var newSegment = ""
				var reachedAttributeEnd = false
				
				for (charIndex, char) in segment.enumerated() {
					
					if reachedAttributeEnd == false {
						
						if char == "\n" && skipNextNewLineReplacement == false {
							
							newSegment += "&#xA;"
							debugLog("Found new line character in attribute value")
							
						} else if char == "\"" {
							
							newSegment += String(char)
							reachedAttributeEnd = true
							
						} else {
							
							newSegment += String(char)
							
							if charIndex == segment.count - 1 {
								skipNextNewLineReplacement = true
							}
							
						}
						
					} else {
						
						newSegment += String(char)
						skipNextNewLineReplacement = false
						
					}
					
				}
				
				newSplitDocument.append(newSegment)
				
			}
			
			let newDocument = newSplitDocument.joined(separator: "=\"")
			
			let newXMLDocument = try XMLDocument(xmlString: newDocument, options: [.nodePreserveWhitespace, .nodePrettyPrint, .nodeCompactEmptyElement])
			
			return newXMLDocument
			
		} catch {
			debugLog("Error converting line breaks: \(error)")
			return nil
		}
	}
	
	// MARK: - Other Conversion Methods
	
	/// Returns the FFVideoFormat identifier based on the given parameters. If the parameters don't match a defined identifier according to FCPXML v1.5, the method will return the string "FFVideoFormatRateUndefined".
	///
	/// - Parameters:
	///   - width: The width of the frame as an integer.
	///   - height: The height of the frame as an integer.
	///   - frameRate: The frame rate as a float.
	///   - isInterlaced: A boolean value indicating if the format is interlaced.
	///   - isSD16x9: A boolean value indicating if the format has an aspect ratio of 16:9.
	/// - Returns: A string of the FFVideoFormat identifier.
	public func FFVideoFormat(fromWidth width: Int, height: Int, frameRate: Float, isInterlaced: Bool, isSD16x9: Bool) -> String {
		
		var ffVideoFormat = "FFVideoFormat"
		let undefined = "FFVideoFormatRateUndefined"
		
		switch width {
		case 1920:
			if height == 1080 {
				ffVideoFormat += "1080"
			} else {
				return undefined
			}
		case 1280:
			switch height {
			case 1080:
				ffVideoFormat += "1280x1080"
			case 720:
				ffVideoFormat += "720"
			default:
				return undefined
			}
		case 1440:
			if height == 1080 {
				ffVideoFormat += "1440x1080"
			} else {
				return undefined
			}
		case 2048:
			switch height {
			case 1080:
				ffVideoFormat += "2048x1080"
			case 1024:
				ffVideoFormat += "2048x1024"
			case 1152:
				ffVideoFormat += "2048x1152"
			case 1536:
				ffVideoFormat += "2048x1536"
			case 1556:
				ffVideoFormat += "2048x1556"
			default:
				return undefined
			}
		case 3840:
			if height == 2160 {
				ffVideoFormat += "3840x2160"
			} else {
				return undefined
			}
		case 4096:
			switch height {
			case 2048:
				ffVideoFormat += "4096x2048"
			case 2160:
				ffVideoFormat += "4096x2160"
			case 2304:
				ffVideoFormat += "4096x2304"
			case 3112:
				ffVideoFormat += "4096x3112"
			default:
				return undefined
			}
		case 5120:
			switch height {
			case 2160:
				ffVideoFormat += "5120x2160"
			case 2560:
				ffVideoFormat += "5120x2560"
			case 2700:
				ffVideoFormat += "5120x2700"
			default:
				return undefined
			}
		case 640:
			switch height {
			case 360:
				ffVideoFormat += "640x360"
			case 480:
				ffVideoFormat += "640x480"
			default:
				return undefined
			}
		case 720:
			switch height {
			case 480:
				ffVideoFormat += "DV720x480"
			case 486:
				ffVideoFormat += "720x486"
			case 576:
				ffVideoFormat += "720x576"
			default:
				return undefined
			}
		case 960:
			switch height {
			case 540:
				ffVideoFormat += "960x540"
			case 720:
				ffVideoFormat += "960x720"
			default:
				return undefined
			}
		default:
			return undefined
		}
		
		if isInterlaced == false {
			ffVideoFormat += "p"
		} else {
			if frameRate == 59.94 || frameRate == 50 {
				ffVideoFormat += "i"
			} else {
				return undefined
			}
		}
		
		switch frameRate {
		case 23.98:
			ffVideoFormat += "2398"
		case 24:
			ffVideoFormat += "24"
		case 25:
			ffVideoFormat += "25"
		case 29.97:
			ffVideoFormat += "2997"
		case 30:
			ffVideoFormat += "30"
		case 50:
			ffVideoFormat += "50"
		case 59.94:
			ffVideoFormat += "5994"
		case 60:
			ffVideoFormat += "60"
		default:
			return undefined
		}
		
		if isSD16x9 {
			ffVideoFormat += "_16x9"
		}
		
		return ffVideoFormat
	}

#if canImport(Logging)
  	private static let logger = Logger(label: "PipelineNeo.FCPXMLUtility")

  	private func debugLog(_ message: String) {
		FCPXMLUtility.logger.debug("\(message)")
	}
#else
	private func debugLog(_ message: String) {
		print(message)
	}
#endif
}
