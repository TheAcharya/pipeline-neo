//
//  XMLDocumentExtension.swift
//  Pipeline Neo • https://github.com/TheAcharya/pipeline-neo
//  © 2025 • Licensed under MIT License
//

import Foundation
import CoreMedia

#if canImport(Logging)
import Logging
#endif

@available(macOS 12.0, *)
extension XMLDocument {
	
	// MARK: - Initializing XMLDocument Objects
	
	/// Initializes a new XMLDocument using the contents of an existing FCPXML file.
	///
	/// - Parameter url: The URL to the FCPXML file.
	/// - Throws: An error object that, on return, identifies any parsing errors and warnings or connection problems.
	public convenience init(contentsOfFCPXML url: URL) throws {
		try self.init(contentsOf: url, options: [.nodePreserveWhitespace, .nodePrettyPrint, .nodeCompactEmptyElement])
	}
	
	/// Initializes a new XMLDocument as FCPXML.
	///
	/// - Parameters:
	///   - resources: Resources an array of XMLElement objects
	///   - events: Events as an array of XMLElement objects
	///   - fcpxmlVersion: The FCPXML version of the document to use.
	public convenience init(resources: [XMLElement], events: [XMLElement], fcpxmlVersion: String) {
		
		self.init()
		self.documentContentKind = XMLDocument.ContentKind.xml
		self.characterEncoding = "UTF-8"
		self.version = "1.0"
		
		self.dtd = XMLDTD()
		self.dtd!.name = "fcpxml"
		self.isStandalone = false
		
		self.setRootElement(XMLElement(name: "fcpxml"))
		self.fcpxmlVersion = fcpxmlVersion
		
		self.add(resourceElements: resources)
		self.add(events: events)
	}
	
	// MARK: - FCPXML Document Properties
	
	/// The FCPXML document as a properly formatted string.
	public var fcpxmlString: String {
		let formattedData = self.xmlData(options: [.nodePreserveWhitespace, .nodePrettyPrint, .nodeCompactEmptyElement])
		if let formattedString = String(data: formattedData, encoding: .utf8) {
			return formattedString
		} else {
			return ""
		}
	}
	
	/// The "fcpxml" element at the root of the XMLDocument
	public var fcpxmlElement: XMLElement? {
		guard let children = self.children else {
			return nil
		}
		
		for child in children {
			let childElement = child as! XMLElement
			
			if childElement.name == "fcpxml" {
				return childElement
			}
		}
		return nil
	}

	/// The "resource" element child of the "fcpxml" element.
	public var fcpxResourceElement: XMLElement? {
		guard let fcpxmlElement = self.fcpxmlElement, fcpxmlElement.elements(forName: "resources").count > 0 else {
			return nil
		}
		return fcpxmlElement.elements(forName: "resources")[0]
	}
	
	/// An array of all resources in the FCPXML document.
	public var fcpxResources: [XMLElement] {
		if let resourceNodes = self.fcpxResourceElement?.children {
			return resourceNodes as! [XMLElement]
		} else {
			return []
		}
	}
	
	/// The library XMLElement in the FCPXML document.
	public var fcpxLibraryElement: XMLElement? {
		guard let fcpxmlElement = self.fcpxmlElement, fcpxmlElement.elements(forName: "library").count > 0 else {
			return nil
		}
		return fcpxmlElement.elements(forName: "library")[0]
	}
	
	/// An array of all event elements in the FCPXML document.
	public var fcpxEvents: [XMLElement] {
		guard let libraryElement = self.fcpxLibraryElement else {
			return []
		}
		return libraryElement.elements(forName: "event")
	}
	
	/// An array of format resources in the FCPXML document.
	public var fcpxFormatResources: [XMLElement] {
		let utility = FCPXMLUtility()
		return utility.filter(fcpxElements: self.fcpxResources, ofTypes: [.formatResource])
	}
	
	/// An array of asset resources in the FCPXML document.
	public var fcpxAssetResources: [XMLElement] {
		let utility = FCPXMLUtility()
		return utility.filter(fcpxElements: self.fcpxResources, ofTypes: [.assetResource])
	}
	
	/// An array of multicam resources in the FCPXML document.
	public var fcpxMulticamResources: [XMLElement] {
		let utility = FCPXMLUtility()
		return utility.filter(fcpxElements: self.fcpxResources, ofTypes: [.multicamResource])
	}
	
	/// An array of compound clip resources in the FCPXML document.
	public var fcpxCompoundResources: [XMLElement] {
		let utility = FCPXMLUtility()
		return utility.filter(fcpxElements: self.fcpxResources, ofTypes: [.compoundResource])
	}
	
	/// An array of effect resources in the FCPXML document.
	public var fcpxEffectResources: [XMLElement] {
		let utility = FCPXMLUtility()
		return utility.filter(fcpxElements: self.fcpxResources, ofTypes: [.effectResource])
	}
	
	/// An array of all projects in all events in the FCPXML document.
	public var fcpxAllProjects: [XMLElement] {
		var projects: [XMLElement] = []
		let utility = FCPXMLUtility()
		for event in self.fcpxEvents {
			guard let eventChildren = event.children else {
				continue
			}
			
			let eventChildrenElements = eventChildren as! [XMLElement]
			let eventProjects = utility.filter(fcpxElements: eventChildrenElements, ofTypes: [.project])
			projects.append(contentsOf: eventProjects)
		}
		return projects
	}
	
	/// An array of all clips in all events in the FCPXML document.
	public var fcpxAllClips: [XMLElement] {
		var clips: [XMLElement] = []
		let utility = FCPXMLUtility()
		for event in self.fcpxEvents {
			guard let eventChildren = event.children else {
				continue
			}
			
			let eventChildrenElements = eventChildren as! [XMLElement]
			let eventClips = utility.filter(fcpxElements: eventChildrenElements, ofTypes: [.clip, .assetClip, .compoundClip, .multicamClip, .synchronizedClip])
			clips.append(contentsOf: eventClips)
		}
		return clips
	}
	
	// The FCPXML version number is obtained here, not during parsing. This way, the version number can be checked before parsing, which could break depending on the FCPXML version.
	/// The version of FCPXML used in this document.
	public var fcpxmlVersion: String? {
		get {
			guard let fcpxmlElement = self.fcpxmlElement else {
				return nil
			}
			
			guard let versionAttribute = fcpxmlElement.attribute(forName: "version") else {
				return nil
			}
			
			guard let versionNumber = versionAttribute.stringValue else {
				return nil
			}
			
			return versionNumber
		}
		
		set {
			if let newValue {
				let version = XMLNode.attribute(withName: "version", stringValue: newValue)
				self.fcpxmlElement?.addAttribute(version as! XMLNode)
			} else {
				self.fcpxmlElement?.removeAttribute(forName: "version")
			}
		}
	}
	
	/// The names of all events as a String array.
	public var fcpxEventNames: [String] {
		var names: [String] = []
		
		for event in self.fcpxEvents {
			guard let name = event.fcpxName else {
				continue
			}
			
			names.append(name)
		}
		
		return names
	}
	
	/// All items from all events as a XMLElement array.
	public var fcpxAllEventItems: [XMLElement] {
		var allItems: [XMLElement] = []
		
		for event in self.fcpxEvents {
			guard let eventItems = event.eventItems else {
				continue
			}
			
			allItems.append(contentsOf: eventItems)
		}
		
		return allItems
	}
	
	/// The names of all items from all events as a XMLElement array.
	public var fcpxAllEventItemNames: [String] {
		var names: [String] = []
		
		for event in self.fcpxEvents {
			guard let clips = event.eventClips else {
				continue
			}
			
			for clip in clips {
				guard let name = clip.fcpxName else {
					continue
				}
				
				names.append(name)
			}
		}
		
		return names
	}
	
	/// The names of all projects from all events as a XMLElement array.
	public var fcpxAllProjectNames: [String] {
		var names: [String] = []
		
		for project in self.fcpxAllProjects {
			guard let name = project.fcpxName else {
				continue
			}
			
			names.append(name)
		}
		
		return names
	}
	
	// MARK: - Roles and IDs
	
	/// Returns an array of all roles used in the FCPXML document.
	///
	/// This function parses the entire XML document whenever called. Avoid calling it repeatedly and store the value separately instead.
	/// - Returns: An array of String values.
	public func fcpxAllRoles() -> [String] {
		self.parseFCPXML()
		
		return self.fcpxRoleAttributeValues
	}
	
	/// Returns the highest resource ID number used in the FCPXML document.
	///
	/// This function parses the entire XML document whenever called. Avoid calling it repeatedly and store the value separately instead.
	/// - Returns: An integer value.
	public func fcpxLastResourceID() -> Int {
		self.parseFCPXML()
		
		return self.fcpxResourceIDs.max() ?? 0
	}
	
	/// Returns the highest text style ID number used in the FCPXML document.
	///
	/// This function parses the entire XML document whenever called. Avoid calling it repeatedly and store the value separately instead.
	/// - Returns: An integer value.
	public func fcpxLastTextStyleID() -> Int {
		self.parseFCPXML()
		
		return self.fcpxTextStyleIDs.max() ?? 0
	}
	
	// MARK: - Retrieving Resources
	
	/// Returns the resource that matches the given ID string.
	///
	/// - Parameter id: The resource ID as a string in the form of "r1"
	/// - Returns: The matching resource NSXMLElement
	public func resource(matchingID id: String) -> XMLElement? {
		for resource in self.fcpxResources {
			if resource.fcpxID == id {
				return resource
			}
		}
		
		return nil
	}
	
	/// Returns asset resources that match the given URL.
	///
	/// - Parameters:
	///   - url: The URL to match with.
	///   - usingFilenameOnly: True if matching with just the filename, false if matching with the entire URL path.
	///   - omittingExtension: True if matching without the extension in the filename, false if matching with the entire filename.
	///   - caseSensitive: True if the search should be case sensitive, false if it should not.
	/// - Returns: An array of XMLElement objects that are matching asset resources.
	public func assetResources(matchingURL url: URL, usingFilenameOnly: Bool, omittingExtension: Bool, caseSensitive: Bool) -> [XMLElement] {
		
		let matchURL: URL
		
		if omittingExtension {
			matchURL = url.deletingPathExtension()
		} else {
			matchURL = url
		}
		
		var matchPath: String
		
		if usingFilenameOnly {
			matchPath = matchURL.lastPathComponent
		} else {
			matchPath = matchURL.path
		}
		
		if !caseSensitive {
			matchPath = matchPath.lowercased()
		}
		
		var matchingResources: [XMLElement] = []
		
		for resource in self.fcpxAssetResources {
			guard let resourceURL = resource.fcpxSrc else {
				continue
			}
			
			var resourcePath: String
			
			if omittingExtension {
				resourcePath = resourceURL.deletingPathExtension().path
			} else {
				resourcePath = resourceURL.path
			}
			
			if usingFilenameOnly {
				resourcePath = resourceURL.lastPathComponent
			}
			
			if !caseSensitive {
				resourcePath = resourcePath.lowercased()
			}
			
			if resourcePath == matchPath {
				matchingResources.append(resource)
			}
		}
		
		return matchingResources
	}
	
	// MARK: - Adding Elements
	
	/// Adds resource elements to the FCPXML document.
	///
	/// - Parameter resourceElements: An array of XMLElement objects to add as resources.
	public func add(resourceElements: [XMLElement]) {
		guard let resourceElement = self.fcpxResourceElement else {
			return
		}
		
		for resource in resourceElements {
			resourceElement.addChild(resource)
		}
	}
	
	/// Adds events to the FCPXML document.
	///
	/// - Parameter events: An array of XMLElement objects to add as events.
	public func add(events: [XMLElement]) {
		guard let libraryElement = self.fcpxLibraryElement else {
			return
		}
		
		for event in events {
			libraryElement.addChild(event)
		}
	}
	
	/// Removes a resource from the FCPXML document.
	///
	/// - Parameter resourceAtIndex: The index of the resource to remove.
	public func remove(resourceAtIndex index: Int) {
		guard let resourceElement = self.fcpxResourceElement else {
			return
		}
		
		guard let resourceChildren = resourceElement.children else {
			return
		}
		
		if index < resourceChildren.count {
			resourceElement.removeChild(at: index)
		}
	}
	
	// MARK: - Validation
	
	/// Validates the FCPXML document against the specified version's DTD.
	///
	/// - Parameter version: A String of the version number.
	/// - Throws: An error describing the reason for the XML being invalid or another error, such as not being able to read or set the associated DTD file.
	public func validateFCPXMLAgainst(version: String) throws {
		do {
			try self.setDTDToFCPXML(version: version)
		} catch {
			debugLog("Error setting the DTD.")
			self.dtd = nil
			throw error
		}
		
		do {
			try self.validate()
		} catch {
			debugLog("The document is invalid. It does not conform to the FCPXML v\(version) Document Type Definition.")
			debugLog("Validation Error: \(error)")
			self.dtd = nil
			throw error
		}
		
		debugLog("The document conforms to the FCPXML v\(version) Document Type Definition.")
		self.dtd = nil
	}
	
	/// Generates the DTD filename for a given FCPXML version.
	///
	/// - Parameters:
	///   - version: The FCPXML version number as a string.
	///   - withExtension: Whether to include the .dtd extension in the returned filename.
	/// - Returns: The DTD filename for the specified version.
	private func fcpxmlDTDFilename(fromVersion version: String, withExtension: Bool) -> String {
		let baseName = "Final_Cut_Pro_XML_DTD_version_\(version)"
		return withExtension ? "\(baseName).dtd" : baseName
	}
	
	/// Sets the XMLDocument's DTD to the specified FCPXML version number. The version number must match a DTD resource included in the bundle.
	///
	/// - Parameter version: The version number as a String.
	/// - Throws: If the DTD file cannot be read properly, an error is thrown describing the issue.
	private func setDTDToFCPXML(version: String) throws {
		let resourceName = self.fcpxmlDTDFilename(fromVersion: version, withExtension: false)
		try self.setDTDToBundleResource(named: resourceName)
	}
	
	/// Sets the DTD to a specified bundle resource in this framework.
	///
	/// - Parameter name: The name of the resource as a String. Do not include the extension of the filename. It is assumed to be "dtd".
	/// - Throws: An FCPXMLDocumentError or an error describing why the file cannot be read.
	private func setDTDToBundleResource(named name: String) throws {
		var dtdURL: URL? = nil
		
		for frameworkBundle in Bundle.allFrameworks {
			if let fileURL = frameworkBundle.url(forResource: name, withExtension: "dtd", subdirectory: "DTDs") {
				dtdURL = fileURL
			}
		}
		
		guard let unwrappedURL = dtdURL else {
			debugLog("Couldn't find the DTD file.")
			throw FCPXMLDocumentError.DTDResourceNotFound
		}
		
		do {
			self.dtd? = try XMLDTD(contentsOf: unwrappedURL, options: [.nodePreserveWhitespace, .nodePrettyPrint, .nodeCompactEmptyElement])
		} catch {
			debugLog("Error reading the DTD file.")
			throw error
		}
		
		if self.dtd != nil {
			self.dtd!.name = "fcpxml"
			self.isStandalone = false
			
			debugLog("DTD set successfully.")
			return
			
		} else {
			debugLog("Failed to set the DTD.")
			return
		}
	}
	
	// MARK: - XML Parsing Methods
	
	/// Parses the resource IDs, text style IDs, and roles, refreshing the fcpxLastResourceID, fcpxLastTextStyleID, and fcpxRoles properties. Call this method when initially loading an FCPXML document and when the IDs or roles change.
	public func parseFCPXML() {
		let xmlParser = XMLParser(data: self.xmlData)
		let delegate = FCPXMLParserDelegate()
		
		xmlParser.delegate = delegate
		xmlParser.parse()
		
		// Extract resource ID numbers from resource IDs
		let resourceIDs = delegate.getResourceIDs()
		self.fcpxResourceIDs = resourceIDs.compactMap { resourceID in
			let idSlice = resourceID.dropFirst()
			return Int(idSlice)
		}.sorted()
		
		// Extract text style ID numbers from text style IDs
		let textStyleIDs = delegate.getTextStyleIDs()
		self.fcpxTextStyleIDs = textStyleIDs.compactMap { textStyleID in
			let idSlice = textStyleID.dropFirst(2)
			return Int(idSlice)
		}.sorted()
		
		// Get unique roles
		let roles = delegate.getRoles()
		self.fcpxRoleAttributeValues = Array(Set(roles)).sorted()
		
		return
	}
	
	// MARK: - Private Properties
	
	// Since extensions cannot contain stored properties, the properties below are defined as Objective-C associated objects.
	
	// A struct that defines stored property types in this extension.
	private struct ParsedData {
		static let resourceIDs = "resourceIDs"
		static let textStyleIDs = "textStyleIDs"
		static let roles = "roles"
	}
	
	// A stored property for all resource IDs in the FCPXML document.
	private var fcpxResourceIDs: [Int] {
		get {
			let key = UnsafeRawPointer(bitPattern: "resourceIDs".hashValue)!
			guard (objc_getAssociatedObject(self, key)) != nil else {
				return []
			}
			
			return objc_getAssociatedObject(self, key) as! [Int]
		}
		set {
			let key = UnsafeRawPointer(bitPattern: "resourceIDs".hashValue)!
			objc_setAssociatedObject(self, key, newValue as [Int], .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
		}
	}
	
	// A stored property for all text style IDs in the FCPXML document.
	private var fcpxTextStyleIDs: [Int] {
		get {
			let key = UnsafeRawPointer(bitPattern: "textStyleIDs".hashValue)!
			guard (objc_getAssociatedObject(self, key)) != nil else {
				return []
			}
			
			return objc_getAssociatedObject(self, key) as! [Int]
		}
		set {
			let key = UnsafeRawPointer(bitPattern: "textStyleIDs".hashValue)!
			objc_setAssociatedObject(self, key, newValue as [Int], .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
		}
	}
	
	// A stored property for all roles in the FCPXML document.
	private var fcpxRoleAttributeValues: [String] {
		get {
			let key = UnsafeRawPointer(bitPattern: "roles".hashValue)!
			guard (objc_getAssociatedObject(self, key)) != nil else {
				return []
			}
			
			return objc_getAssociatedObject(self, key) as! [String]
		}
		set {
			let key = UnsafeRawPointer(bitPattern: "roles".hashValue)!
			objc_setAssociatedObject(self, key, newValue as [String], .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
		}
	}
	
	// MARK: - Private Methods
	private func xmlElementArrayToStringArray(usingXMLArray xmlArray: [XMLElement]) -> [String] {
		xmlArray.map { $0.xmlString }
	}
	
	private func stringArrayToXMLElementArray(usingStringArray stringArray: [String]) -> [XMLElement] {
		stringArray.compactMap { stringItem in
			try? XMLElement(xmlString: stringItem)
		}
	}
	
	// MARK: - Constants
	
	/// Type used to define FCPXML document errors.
	///
	/// - DTDResourceNotFound: The DTD resource in the Pipeline framework was not found.
	/// - DTDResourceUnreadable: The DTD resource in the Pipeline framework was not readable.
	enum FCPXMLDocumentError: Error {
		case DTDResourceNotFound
		case DTDResourceUnreadable
	}

#if canImport(Logging)
  	private static let logger = Logger(label: "PipelineNeo.XMLDocument")

  	private func debugLog(_ message: String) {
		XMLDocument.logger.debug("\(message)")
	}
#else
	private func debugLog(_ message: String) {
		print(message)
	}
#endif
}
