<a href="https://github.com/TheAcharya/pipeline-neo"><img src="https://github.com/TheAcharya/pipeline-neo/blob/main/assets/Pipeline%20Neo_Icon.png?raw=true" width="200" alt="App icon" align="left"/>

<div>
<h1>Pipeline Neo</h1>
<!-- license -->
<a href="https://github.com/TheAcharya/pipeline-neo/blob/main/LICENSE">
<img src="http://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat" alt="license"/>
</a>
<!-- platform -->
<a href="https://github.com/TheAcharya/pipeline-neo">
<img src="https://img.shields.io/badge/platform-macOS-lightgrey.svg?style=flat" alt="platform"/>
</a>
<p>
<p>A Swift framework for working with Final Cut Pro's FCPXML.</p>

<br>
<br>
</div>

## Core Features

- Access an FCPXML document's resources, events, clips, and projects through simple object properties.
- Create and modify resources, events, clips, and projects with included properties and methods.
- Easily manipulate timing values.
- Output FCPXML files with proper text formatting.
- Validate FCPXML documents with the DTD.
- Works with FCPXML v1.6 through v1.8 files

## Table of contents

- [Background](#background)
- [Documentation](#documentation)
- [Usage](#Usage)
- [Examples](#examples)
  - [Open an FCPXML File](#open-an-fcpxml-file)
  - [List the Names of All Events](#list-the-names-of-all-events)
  - [Create and Add a New Event](#create-and-add-a-new-event)
  - [Get Clips That Match a Resource ID and Delete Them](#get-clips-that-match-a-resource-id-and-delete-them)
  - [Display the Duration of a Clip](#display-the-duration-of-a-clip)
  - [Save the FCPXML File](#save-the-fcpxml-file)
- [Credits](#credits)
- [License](#license)
- [Reporting Bugs](#reporting-bugs)

## Background

[Pipeline](https://github.com/reuelk/pipeline) was originally developed by [Reuel Kim](https://github.com/reuelk) and it is no longer maintained. **Pipeline Neo** was created as a spin-off project to fix and update the library when necessary.

**Pipeline Neo** extends the XMLDocument and XMLElement classes in the Foundation framework. It adds properties and methods that simplify the creation and management of FCPXML document structure.

**Pipeline Neo** also includes supplemental classes and a CMTime extension to help in the processing of FCPXML data. For example, you can easily convert a timing value that looks like `59983924/30000s` in the XML to `00:33:19,464` for display in an app.

## Documentation
The latest framework documentation is viewable at [reuelk.github.io/pipeline](https://reuelk.github.io/pipeline) and is also included in the project's `docs` folder as HTML files.

## Usage

To use this package in a SwiftPM project, you need to set it up as a package dependency:

```swift
// swift-tools-version:5.6
import PackageDescription

let package = Package(
  name: "MyPackage",
  dependencies: [
    .package(
      url: "https://github.com/TheAcharya/pipeline-neo",
      .upToNextMajor(from: "0.1.0") // or `.upToNextMinor
    )
  ],
  targets: [
    .target(
      name: "MyTarget",
      dependencies: [
        .product(name: "pipeline-neo", package: "pipeline-neo")
      ]
    )
  ]
)
```

## Examples

### Open an FCPXML File
Subsequent examples use the `fcpxmlDoc` object declared here.

```swift
// Change the path below to your FCPXML file's path
let fileURL = URL(fileURLWithPath: "/Users/[username]/Documents/sample.fcpxml")  // Create a new URL object that points to the FCPXML file's path.

do {
	try fileURL.checkResourceIsReachable()
} catch {
	print("The file cannot be found at the given path.")
	return
}

let fcpxmlDoc: XMLDocument  // Declare the fcpxmlDoc constant as an XMLDocument object

do {
	fcpxmlDoc = try XMLDocument(contentsOfFCPXML: fileURL)  // Load the FCPXML file using the fileURL object
} catch {
	print("Error loading FCPXML file.")
	return
}
```

### List the Names of All Events

```swift
let eventNames = fcpxmlDoc.fcpxEventNames  // Get the event names in the FCPXML document
dump(eventNames)  // Neatly display all of the event names
```

### Create and Add a New Event

```swift
let newEvent = XMLElement().fcpxEvent(name: "My New Event")  // Create a new empty event
fcpxmlDoc.add(event: newEvent)  // Add the new event to the FCPXML document
dump(fcpxmlDoc.fcpxEventNames) // Neatly display all of the event names
```

### Get Clips That Match a Resource ID and Delete Them

```swift
let firstEvent = fcpxmlDoc.fcpxEvents[0]  // Get the first event in the FCPXML document
let matchingClips = try! firstEvent.eventClips(forResourceID: "r1")  // Get any clips that match resource ID "r1".

// The eventClips(forResourceID:) method throws an error if the XMLElement that calls it is not an event. Since we know that firstEvent is an event, it is safe to use "try!" to override the error handling.

try! firstEvent.removeFromEvent(items: matchingClips)  // Remove the clips that reference resource "r1".

guard let resource = fcpxmlDoc.resource(matchingID: "r1") else {  // Get the "r1" resource
	return
}
fcpxmlDoc.remove(resourceAtIndex: resource.index)  // Remove the "r1" resource from the FCPXML document
```

### Display the Duration of a Clip

```swift
let firstEvent = fcpxmlDoc.fcpxEvents[0]  // Get the first event in the FCPXML document

guard let eventClips = firstEvent.eventClips else {  // Get the event clips while guarding against a potential nil value
	return
}

if eventClips.count > 0 {  // Make sure there's at least one clip in the event
	let firstClip = eventClips[0]  // Get the first clip in the event
	let duration = firstClip.fcpxDuration  // Get the duration of the clip
	let timeDisplay = duration?.timeAsCounter().counterString  // Convert the duration, which is a CMTime value, to a String formatted as HH:MM:SS,MMM
	print(timeDisplay) 
}
```

### Save the FCPXML File

```swift
do {
	// Change the path below to your new FCPXML file's path
	try fcpxmlDoc.fcpxmlString.write(toFile: "/Users/[username]/Documents/sample-output.fcpxml", atomically: false, encoding: String.Encoding.utf8)
	print("Wrote FCPXML file.")
} catch {
	print("Error writing to file.")
}
```

## Credits

Original Work by [Reuel Kim](https://github.com/reuelk) ([0.5 ... 0.6](https://github.com/reuelk/pipeline))

## License

Licensed under the MIT license. See [LICENSE](https://github.com/TheAcharya/pipeline-neo/blob/main/LICENSE) for details.

## Reporting Bugs

For bug reports, feature requests and other suggestions you can create [a new issue](https://github.com/TheAcharya/pipeline-neo/issues) to discuss.
