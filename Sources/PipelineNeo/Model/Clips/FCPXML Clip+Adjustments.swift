//
//  FCPXML Clip+Adjustments.swift
//  Pipeline Neo • https://github.com/TheAcharya/pipeline-neo
//  © 2026 • Licensed under MIT License
//

//
//	Clip adjustments extension for typed adjustment models.
//

import Foundation

extension FinalCutPro.FCPXML.Clip {
    /// The crop adjustment applied to the clip.
    public var cropAdjustment: FinalCutPro.FCPXML.CropAdjustment? {
        get {
            guard let adjustElement = element.firstChildElement(named: "adjust-crop") else {
                return nil
            }
            
            guard let modeString = adjustElement.stringValue(forAttributeNamed: "mode"),
                  let mode = FinalCutPro.FCPXML.CropAdjustment.Mode(rawValue: modeString) else {
                return nil
            }
            
            let enabledString = adjustElement.stringValue(forAttributeNamed: "enabled") ?? "1"
            let isEnabled = enabledString == "1"
            
            var crop = FinalCutPro.FCPXML.CropAdjustment(mode: mode, isEnabled: isEnabled)
            
            // Parse crop-rect
            if let cropRectElement = adjustElement.firstChildElement(named: "crop-rect"),
               let left = Double(cropRectElement.stringValue(forAttributeNamed: "left") ?? "0"),
               let top = Double(cropRectElement.stringValue(forAttributeNamed: "top") ?? "0"),
               let right = Double(cropRectElement.stringValue(forAttributeNamed: "right") ?? "0"),
               let bottom = Double(cropRectElement.stringValue(forAttributeNamed: "bottom") ?? "0") {
                crop.cropRect = FinalCutPro.FCPXML.CropAdjustment.CropRect(left: left, top: top, right: right, bottom: bottom)
            }
            
            // Parse trim-rect
            if let trimRectElement = adjustElement.firstChildElement(named: "trim-rect"),
               let left = Double(trimRectElement.stringValue(forAttributeNamed: "left") ?? "0"),
               let top = Double(trimRectElement.stringValue(forAttributeNamed: "top") ?? "0"),
               let right = Double(trimRectElement.stringValue(forAttributeNamed: "right") ?? "0"),
               let bottom = Double(trimRectElement.stringValue(forAttributeNamed: "bottom") ?? "0") {
                crop.trimRect = FinalCutPro.FCPXML.CropAdjustment.TrimRect(left: left, top: top, right: right, bottom: bottom)
            }
            
            // Parse pan-rect elements
            let panRectElements = adjustElement.childElements.filter { $0.name == "pan-rect" }
            if !panRectElements.isEmpty {
                crop.panRects = panRectElements.compactMap { panElement -> FinalCutPro.FCPXML.CropAdjustment.PanRect? in
                    guard let left = Double(panElement.stringValue(forAttributeNamed: "left") ?? "0"),
                          let top = Double(panElement.stringValue(forAttributeNamed: "top") ?? "0"),
                          let right = Double(panElement.stringValue(forAttributeNamed: "right") ?? "0"),
                          let bottom = Double(panElement.stringValue(forAttributeNamed: "bottom") ?? "0") else {
                        return nil
                    }
                    return FinalCutPro.FCPXML.CropAdjustment.PanRect(left: left, top: top, right: right, bottom: bottom)
                }
            }
            
            return crop
        }
        nonmutating set {
            // Remove existing adjust-crop element
            if let existing = element.firstChildElement(named: "adjust-crop") {
                element.removeChild(at: existing.index)
            }
            
            guard let adjustment = newValue else { return }
            
            // Create new adjust-crop element
            let adjustElement = XMLElement(name: "adjust-crop")
            adjustElement.addAttribute(withName: "mode", value: adjustment.mode.rawValue)
            if !adjustment.isEnabled {
                adjustElement.addAttribute(withName: "enabled", value: "0")
            }
            
            // Add crop-rect if present
            if let cropRect = adjustment.cropRect {
                let cropRectElement = XMLElement(name: "crop-rect")
                cropRectElement.addAttribute(withName: "left", value: String(cropRect.left))
                cropRectElement.addAttribute(withName: "top", value: String(cropRect.top))
                cropRectElement.addAttribute(withName: "right", value: String(cropRect.right))
                cropRectElement.addAttribute(withName: "bottom", value: String(cropRect.bottom))
                adjustElement.addChild(cropRectElement)
            }
            
            // Add trim-rect if present
            if let trimRect = adjustment.trimRect {
                let trimRectElement = XMLElement(name: "trim-rect")
                trimRectElement.addAttribute(withName: "left", value: String(trimRect.left))
                trimRectElement.addAttribute(withName: "top", value: String(trimRect.top))
                trimRectElement.addAttribute(withName: "right", value: String(trimRect.right))
                trimRectElement.addAttribute(withName: "bottom", value: String(trimRect.bottom))
                adjustElement.addChild(trimRectElement)
            }
            
            // Add pan-rect elements if present
            if let panRects = adjustment.panRects {
                for panRect in panRects {
                    let panRectElement = XMLElement(name: "pan-rect")
                    panRectElement.addAttribute(withName: "left", value: String(panRect.left))
                    panRectElement.addAttribute(withName: "top", value: String(panRect.top))
                    panRectElement.addAttribute(withName: "right", value: String(panRect.right))
                    panRectElement.addAttribute(withName: "bottom", value: String(panRect.bottom))
                    adjustElement.addChild(panRectElement)
                }
            }
            
            element.addChild(adjustElement)
        }
    }
    
    /// The transform adjustment applied to the clip.
    public var transformAdjustment: FinalCutPro.FCPXML.TransformAdjustment? {
        get {
            guard let adjustElement = element.firstChildElement(named: "adjust-transform") else {
                return nil
            }
            
            let enabledString = adjustElement.stringValue(forAttributeNamed: "enabled") ?? "1"
            let isEnabled = enabledString == "1"
            
            let positionString = adjustElement.stringValue(forAttributeNamed: "position") ?? "0 0"
            let position = FinalCutPro.FCPXML.Point(fromString: positionString) ?? .zero
            
            let scaleString = adjustElement.stringValue(forAttributeNamed: "scale") ?? "1 1"
            let scale = FinalCutPro.FCPXML.Point(fromString: scaleString) ?? FinalCutPro.FCPXML.Point(x: 1, y: 1)
            
            let rotationString = adjustElement.stringValue(forAttributeNamed: "rotation") ?? "0"
            let rotation = Double(rotationString) ?? 0
            
            let anchorString = adjustElement.stringValue(forAttributeNamed: "anchor") ?? "0 0"
            let anchor = FinalCutPro.FCPXML.Point(fromString: anchorString) ?? .zero
            
            return FinalCutPro.FCPXML.TransformAdjustment(
                position: position,
                scale: scale,
                rotation: rotation,
                anchor: anchor,
                isEnabled: isEnabled
            )
        }
        nonmutating set {
            // Remove existing adjust-transform element
            if let existing = element.firstChildElement(named: "adjust-transform") {
                element.removeChild(at: existing.index)
            }
            
            guard let adjustment = newValue else { return }
            
            // Create new adjust-transform element
            let adjustElement = XMLElement(name: "adjust-transform")
            if !adjustment.isEnabled {
                adjustElement.addAttribute(withName: "enabled", value: "0")
            }
            adjustElement.addAttribute(withName: "position", value: adjustment.position.stringValue)
            adjustElement.addAttribute(withName: "scale", value: adjustment.scale.stringValue)
            adjustElement.addAttribute(withName: "rotation", value: String(adjustment.rotation))
            adjustElement.addAttribute(withName: "anchor", value: adjustment.anchor.stringValue)
            
            element.addChild(adjustElement)
        }
    }
    
    /// The blend adjustment applied to the clip.
    public var blendAdjustment: FinalCutPro.FCPXML.BlendAdjustment? {
        get {
            guard let adjustElement = element.firstChildElement(named: "adjust-blend") else {
                return nil
            }
            
            let amountString = adjustElement.stringValue(forAttributeNamed: "amount") ?? "1"
            let amount = Double(amountString) ?? 1.0
            
            let mode = adjustElement.stringValue(forAttributeNamed: "mode")
            
            return FinalCutPro.FCPXML.BlendAdjustment(mode: mode, amount: amount)
        }
        nonmutating set {
            // Remove existing adjust-blend element
            if let existing = element.firstChildElement(named: "adjust-blend") {
                element.removeChild(at: existing.index)
            }
            
            guard let adjustment = newValue else { return }
            
            // Create new adjust-blend element
            let adjustElement = XMLElement(name: "adjust-blend")
            adjustElement.addAttribute(withName: "amount", value: String(adjustment.amount))
            if let mode = adjustment.mode {
                adjustElement.addAttribute(withName: "mode", value: mode)
            }
            
            element.addChild(adjustElement)
        }
    }
    
    /// The stabilization adjustment applied to the clip.
    public var stabilizationAdjustment: FinalCutPro.FCPXML.StabilizationAdjustment? {
        get {
            guard let adjustElement = element.firstChildElement(named: "adjust-stabilization") else {
                return nil
            }
            
            let typeString = adjustElement.stringValue(forAttributeNamed: "type") ?? "automatic"
            guard let type = FinalCutPro.FCPXML.StabilizationAdjustment.Mode(rawValue: typeString) else {
                return FinalCutPro.FCPXML.StabilizationAdjustment()
            }
            
            return FinalCutPro.FCPXML.StabilizationAdjustment(type: type)
        }
        nonmutating set {
            // Remove existing adjust-stabilization element
            if let existing = element.firstChildElement(named: "adjust-stabilization") {
                element.removeChild(at: existing.index)
            }
            
            guard let adjustment = newValue else { return }
            
            // Create new adjust-stabilization element
            let adjustElement = XMLElement(name: "adjust-stabilization")
            adjustElement.addAttribute(withName: "type", value: adjustment.type.rawValue)
            
            element.addChild(adjustElement)
        }
    }
    
    /// The volume adjustment applied to the clip.
    public var volumeAdjustment: FinalCutPro.FCPXML.VolumeAdjustment? {
        get {
            guard let adjustElement = element.firstChildElement(named: "adjust-volume") else {
                return nil
            }
            
            let amountString = adjustElement.stringValue(forAttributeNamed: "amount") ?? "0dB"
            if let volume = FinalCutPro.FCPXML.VolumeAdjustment(fromDecibelString: amountString) {
                return volume
            }
            
            // Fallback: try parsing as plain number
            if let amount = Double(amountString) {
                return FinalCutPro.FCPXML.VolumeAdjustment(amount: amount)
            }
            
            return FinalCutPro.FCPXML.VolumeAdjustment(amount: 0)
        }
        nonmutating set {
            // Remove existing adjust-volume element
            if let existing = element.firstChildElement(named: "adjust-volume") {
                element.removeChild(at: existing.index)
            }
            
            guard let adjustment = newValue else { return }
            
            // Create new adjust-volume element
            let adjustElement = XMLElement(name: "adjust-volume")
            adjustElement.addAttribute(withName: "amount", value: adjustment.decibelString)
            
            element.addChild(adjustElement)
        }
    }
    
    /// The loudness adjustment applied to the clip.
    public var loudnessAdjustment: FinalCutPro.FCPXML.LoudnessAdjustment? {
        get {
            guard let adjustElement = element.firstChildElement(named: "adjust-loudness") else {
                return nil
            }
            
            let amountString = adjustElement.stringValue(forAttributeNamed: "amount") ?? "0"
            let uniformityString = adjustElement.stringValue(forAttributeNamed: "uniformity") ?? "0"
            
            guard let amount = Double(amountString),
                  let uniformity = Double(uniformityString) else {
                return FinalCutPro.FCPXML.LoudnessAdjustment(amount: 0, uniformity: 0)
            }
            
            return FinalCutPro.FCPXML.LoudnessAdjustment(amount: amount, uniformity: uniformity)
        }
        nonmutating set {
            // Remove existing adjust-loudness element
            if let existing = element.firstChildElement(named: "adjust-loudness") {
                element.removeChild(at: existing.index)
            }
            
            guard let adjustment = newValue else { return }
            
            // Create new adjust-loudness element
            let adjustElement = XMLElement(name: "adjust-loudness")
            adjustElement.addAttribute(withName: "amount", value: String(adjustment.amount))
            adjustElement.addAttribute(withName: "uniformity", value: String(adjustment.uniformity))
            
            element.addChild(adjustElement)
        }
    }
    
    /// The noise reduction adjustment applied to the clip.
    public var noiseReductionAdjustment: FinalCutPro.FCPXML.NoiseReductionAdjustment? {
        get {
            guard let adjustElement = element.firstChildElement(named: "adjust-noiseReduction") else {
                return nil
            }
            
            let amountString = adjustElement.stringValue(forAttributeNamed: "amount") ?? "0"
            guard let amount = Double(amountString) else {
                return FinalCutPro.FCPXML.NoiseReductionAdjustment(amount: 0)
            }
            
            return FinalCutPro.FCPXML.NoiseReductionAdjustment(amount: amount)
        }
        nonmutating set {
            // Remove existing adjust-noiseReduction element
            element.removeChildren { $0.name == "adjust-noiseReduction" }
            
            guard let adjustment = newValue else { return }
            
            // Create new adjust-noiseReduction element
            let adjustElement = XMLElement(name: "adjust-noiseReduction")
            adjustElement.addAttribute(withName: "amount", value: String(adjustment.amount))
            
            element.addChild(adjustElement)
        }
    }
    
    /// The hum reduction adjustment applied to the clip.
    public var humReductionAdjustment: FinalCutPro.FCPXML.HumReductionAdjustment? {
        get {
            guard let adjustElement = element.firstChildElement(named: "adjust-humReduction") else {
                return nil
            }
            
            let frequencyString = adjustElement.stringValue(forAttributeNamed: "frequency") ?? "50"
            guard let frequency = FinalCutPro.FCPXML.HumReductionFrequency(rawValue: frequencyString) else {
                return FinalCutPro.FCPXML.HumReductionAdjustment(frequency: .hz50)
            }
            
            return FinalCutPro.FCPXML.HumReductionAdjustment(frequency: frequency)
        }
        nonmutating set {
            // Remove existing adjust-humReduction element
            element.removeChildren { $0.name == "adjust-humReduction" }
            
            guard let adjustment = newValue else { return }
            
            // Create new adjust-humReduction element
            let adjustElement = XMLElement(name: "adjust-humReduction")
            adjustElement.addAttribute(withName: "frequency", value: adjustment.frequency.rawValue)
            
            element.addChild(adjustElement)
        }
    }
    
    /// The equalization adjustment applied to the clip.
    public var equalizationAdjustment: FinalCutPro.FCPXML.EqualizationAdjustment? {
        get {
            guard let adjustElement = element.firstChildElement(named: "adjust-EQ") else {
                return nil
            }
            
            let modeString = adjustElement.stringValue(forAttributeNamed: "mode") ?? "flat"
            guard let mode = FinalCutPro.FCPXML.EqualizationMode(rawValue: modeString) else {
                return FinalCutPro.FCPXML.EqualizationAdjustment(mode: .flat)
            }
            
            // Parse param elements
            let parameters = Array(adjustElement.childElements
                .filter { $0.name == "param" }
                .compactMap { paramElement -> FinalCutPro.FCPXML.FilterParameter? in
                    guard let name = paramElement.stringValue(forAttributeNamed: "name") else {
                        return nil
                    }
                    let key = paramElement.stringValue(forAttributeNamed: "key")
                    let value = paramElement.stringValue(forAttributeNamed: "value")
                    let enabledString = paramElement.stringValue(forAttributeNamed: "enabled") ?? "1"
                    let isEnabled = enabledString == "1"
                    return FinalCutPro.FCPXML.FilterParameter(
                        name: name,
                        key: key,
                        value: value,
                        isEnabled: isEnabled
                    )
                })
            
            return FinalCutPro.FCPXML.EqualizationAdjustment(mode: mode, parameters: parameters)
        }
        nonmutating set {
            // Remove existing adjust-EQ element
            element.removeChildren { $0.name == "adjust-EQ" }
            
            guard let adjustment = newValue else { return }
            
            // Create new adjust-EQ element
            let adjustElement = XMLElement(name: "adjust-EQ")
            adjustElement.addAttribute(withName: "mode", value: adjustment.mode.rawValue)
            
            // Add param elements
            for param in adjustment.parameters {
                let paramElement = XMLElement(name: "param")
                paramElement.addAttribute(withName: "name", value: param.name)
                if let key = param.key {
                    paramElement.addAttribute(withName: "key", value: key)
                }
                if let value = param.value {
                    paramElement.addAttribute(withName: "value", value: value)
                }
                if !param.isEnabled {
                    paramElement.addAttribute(withName: "enabled", value: "0")
                }
                adjustElement.addChild(paramElement)
            }
            
            element.addChild(adjustElement)
        }
    }
    
    /// The match equalization adjustment applied to the clip.
    public var matchEqualizationAdjustment: FinalCutPro.FCPXML.MatchEqualizationAdjustment? {
        get {
            guard let adjustElement = element.firstChildElement(named: "adjust-matchEQ") else {
                return nil
            }
            
            // Parse data element
            guard let dataElement = adjustElement.firstChildElement(named: "data") else {
                return nil
            }
            
            let key = dataElement.stringValue(forAttributeNamed: "key")
            let value = dataElement.stringValue ?? ""
            let data = FinalCutPro.FCPXML.KeyedData(key: key, value: value)
            
            return FinalCutPro.FCPXML.MatchEqualizationAdjustment(data: data)
        }
        nonmutating set {
            // Remove existing adjust-matchEQ element
            element.removeChildren { $0.name == "adjust-matchEQ" }
            
            guard let adjustment = newValue else { return }
            
            // Create new adjust-matchEQ element
            let adjustElement = XMLElement(name: "adjust-matchEQ")
            
            // Add data element
            let dataElement = XMLElement(name: "data")
            if let key = adjustment.data.key {
                dataElement.addAttribute(withName: "key", value: key)
            }
            dataElement.stringValue = adjustment.data.value
            adjustElement.addChild(dataElement)
            
            element.addChild(adjustElement)
        }
    }
    
    /// The 360° transform adjustment applied to the clip.
    public var transform360Adjustment: FinalCutPro.FCPXML.Transform360Adjustment? {
        get {
            guard let adjustElement = element.firstChildElement(named: "adjust-360-transform") else {
                return nil
            }
            
            guard let coordinatesString = adjustElement.stringValue(forAttributeNamed: "coordinates"),
                  let coordinateType = FinalCutPro.FCPXML.Transform360CoordinateType(rawValue: coordinatesString) else {
                return nil
            }
            
            let enabledString = adjustElement.stringValue(forAttributeNamed: "enabled") ?? "1"
            let isEnabled = enabledString == "1"
            
            let autoOrientString = adjustElement.stringValue(forAttributeNamed: "autoOrient") ?? "1"
            let autoOrient = autoOrientString == "1"
            
            // Parse coordinate-specific attributes
            let latitude = adjustElement.stringValue(forAttributeNamed: "latitude").flatMap { Double($0) }
            let longitude = adjustElement.stringValue(forAttributeNamed: "longitude").flatMap { Double($0) }
            let distance = adjustElement.stringValue(forAttributeNamed: "distance").flatMap { Double($0) }
            let xPosition = adjustElement.stringValue(forAttributeNamed: "xPosition").flatMap { Double($0) }
            let yPosition = adjustElement.stringValue(forAttributeNamed: "yPosition").flatMap { Double($0) }
            let zPosition = adjustElement.stringValue(forAttributeNamed: "zPosition").flatMap { Double($0) }
            let xOrientation = adjustElement.stringValue(forAttributeNamed: "xOrientation").flatMap { Double($0) }
            let yOrientation = adjustElement.stringValue(forAttributeNamed: "yOrientation").flatMap { Double($0) }
            let zOrientation = adjustElement.stringValue(forAttributeNamed: "zOrientation").flatMap { Double($0) }
            let convergence = adjustElement.stringValue(forAttributeNamed: "convergence").flatMap { Double($0) }
            let interaxial = adjustElement.stringValue(forAttributeNamed: "interaxial").flatMap { Double($0) }
            
            // Parse param elements
            let parameters = Array(adjustElement.childElements
                .filter { $0.name == "param" }
                .compactMap { paramElement -> FinalCutPro.FCPXML.FilterParameter? in
                    guard let name = paramElement.stringValue(forAttributeNamed: "name") else {
                        return nil
                    }
                    let key = paramElement.stringValue(forAttributeNamed: "key")
                    let value = paramElement.stringValue(forAttributeNamed: "value")
                    let enabledString = paramElement.stringValue(forAttributeNamed: "enabled") ?? "1"
                    let isEnabled = enabledString == "1"
                    return FinalCutPro.FCPXML.FilterParameter(
                        name: name,
                        key: key,
                        value: value,
                        isEnabled: isEnabled
                    )
                })
            
            var adjustment = FinalCutPro.FCPXML.Transform360Adjustment(
                coordinateType: coordinateType,
                isEnabled: isEnabled,
                autoOrient: autoOrient,
                parameters: parameters
            )
            
            adjustment.latitude = latitude
            adjustment.longitude = longitude
            adjustment.distance = distance
            adjustment.xPosition = xPosition
            adjustment.yPosition = yPosition
            adjustment.zPosition = zPosition
            adjustment.xOrientation = xOrientation
            adjustment.yOrientation = yOrientation
            adjustment.zOrientation = zOrientation
            adjustment.convergence = convergence
            adjustment.interaxial = interaxial
            
            return adjustment
        }
        nonmutating set {
            // Remove existing adjust-360-transform element
            element.removeChildren { $0.name == "adjust-360-transform" }
            
            guard let adjustment = newValue else { return }
            
            // Create new adjust-360-transform element
            let adjustElement = XMLElement(name: "adjust-360-transform")
            adjustElement.addAttribute(withName: "coordinates", value: adjustment.coordinateType.rawValue)
            if !adjustment.isEnabled {
                adjustElement.addAttribute(withName: "enabled", value: "0")
            }
            if !adjustment.autoOrient {
                adjustElement.addAttribute(withName: "autoOrient", value: "0")
            }
            
            // Add coordinate-specific attributes
            if let latitude = adjustment.latitude {
                adjustElement.addAttribute(withName: "latitude", value: String(latitude))
            }
            if let longitude = adjustment.longitude {
                adjustElement.addAttribute(withName: "longitude", value: String(longitude))
            }
            if let distance = adjustment.distance {
                adjustElement.addAttribute(withName: "distance", value: String(distance))
            }
            if let xPosition = adjustment.xPosition {
                adjustElement.addAttribute(withName: "xPosition", value: String(xPosition))
            }
            if let yPosition = adjustment.yPosition {
                adjustElement.addAttribute(withName: "yPosition", value: String(yPosition))
            }
            if let zPosition = adjustment.zPosition {
                adjustElement.addAttribute(withName: "zPosition", value: String(zPosition))
            }
            if let xOrientation = adjustment.xOrientation {
                adjustElement.addAttribute(withName: "xOrientation", value: String(xOrientation))
            }
            if let yOrientation = adjustment.yOrientation {
                adjustElement.addAttribute(withName: "yOrientation", value: String(yOrientation))
            }
            if let zOrientation = adjustment.zOrientation {
                adjustElement.addAttribute(withName: "zOrientation", value: String(zOrientation))
            }
            if let convergence = adjustment.convergence {
                adjustElement.addAttribute(withName: "convergence", value: String(convergence))
            }
            if let interaxial = adjustment.interaxial {
                adjustElement.addAttribute(withName: "interaxial", value: String(interaxial))
            }
            
            // Add param elements
            for param in adjustment.parameters {
                let paramElement = XMLElement(name: "param")
                paramElement.addAttribute(withName: "name", value: param.name)
                if let key = param.key {
                    paramElement.addAttribute(withName: "key", value: key)
                }
                if let value = param.value {
                    paramElement.addAttribute(withName: "value", value: value)
                }
                if !param.isEnabled {
                    paramElement.addAttribute(withName: "enabled", value: "0")
                }
                adjustElement.addChild(paramElement)
            }
            
            element.addChild(adjustElement)
        }
    }
}
