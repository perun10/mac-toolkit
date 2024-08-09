//
//  ContentView.swift
//  iToolkit
//
//  Created by Djuradj Perunovic on 9.8.24..
//

import SwiftUI
import Carbon

struct ContentView: View {
    @State private var isCleanModeEnabled = false

    var body: some View {
        VStack {
            Toggle(isOn: $isCleanModeEnabled) {
                Text("Enable Clean Mode")
            }
            .padding()

            if isCleanModeEnabled {
                Text("Keyboard Disabled")
                    .foregroundColor(.red)
            } else {
                Text("Keyboard Enabled")
                    .foregroundColor(.green)
            }
        }
        .padding()
        .onChange(of: isCleanModeEnabled) { newValue in
            toggleKeyboardCleanMode(isEnabled: newValue)
        }
    }

    func toggleKeyboardCleanMode(isEnabled: Bool) {
        if isEnabled {
            // Code to disable the keyboard
            startIgnoringKeyboardEvents()
        } else {
            // Code to enable the keyboard
            stopIgnoringKeyboardEvents()
        }
    }
}

var eventTap: CFMachPort?

func startIgnoringKeyboardEvents() {
    let eventMask = (1 << CGEventType.keyDown.rawValue) | (1 << CGEventType.keyUp.rawValue)
    eventTap = CGEvent.tapCreate(tap: .cghidEventTap,
                                 place: .headInsertEventTap,
                                 options: .defaultTap,
                                 eventsOfInterest: CGEventMask(eventMask),
                                 callback: { (proxy, type, event, refcon) -> Unmanaged<CGEvent>? in
        return nil // By returning nil, we ignore the event
    }, userInfo: nil)

    if let eventTap = eventTap {
        let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)
    }
}

func stopIgnoringKeyboardEvents() {
    if let eventTap = eventTap {
        CGEvent.tapEnable(tap: eventTap, enable: false)
        CFMachPortInvalidate(eventTap)
    }
}

#Preview {
    ContentView()
}
