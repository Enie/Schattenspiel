//
//  DirectoryMonitor.swift
//  Schattenspiel
//
//  Created by Enie Weiß on 01.02.23.
//

import Foundation

/// A protocol that allows delegates of `DirectoryMonitor` to respond to changes in a directory.
protocol DirectoryMonitorDelegate: class {
    func directoryMonitorDidObserveChange(directoryMonitor: DirectoryMonitor)
}

class DirectoryMonitor {
    // MARK: Properties
    
    /// The `DirectoryMonitor`'s delegate who is responsible for responding to `DirectoryMonitor` updates.
    weak var delegate: DirectoryMonitorDelegate?
    
    /// A file descriptor for the monitored directory.
    var monitoredDirectoryFileDescriptor: CInt = -1
    
    /// A dispatch queue used for sending file changes in the directory.
    let directoryMonitorQueue =  DispatchQueue(label: "directorymonitor", attributes: .concurrent)
    
    /// A dispatch source to monitor a file descriptor created from the directory.
    var directoryMonitorSource: DispatchSource?
    
    /// URL for the directory being monitored.
    var url: URL
    
    // MARK: Initializers
    init(url: URL) {
        self.url = url
    }
    
    // MARK: Monitoring
    
    func startMonitoring() {
        // Listen for changes to the directory (if we are not already).
        if directoryMonitorSource == nil && monitoredDirectoryFileDescriptor == -1 {
            // Open the directory referenced by URL for monitoring only.
            monitoredDirectoryFileDescriptor = open((url as NSURL).fileSystemRepresentation, O_EVTONLY)
            
            // Define a dispatch source monitoring the directory for additions, deletions, and renamings.
            directoryMonitorSource = DispatchSource.makeFileSystemObjectSource(fileDescriptor: monitoredDirectoryFileDescriptor, eventMask: DispatchSource.FileSystemEvent.write, queue: directoryMonitorQueue) as? DispatchSource
            
            // Define the block to call when a file change is detected.
            directoryMonitorSource?.setEventHandler{
                // Call out to the `DirectoryMonitorDelegate` so that it can react appropriately to the change.
                self.delegate?.directoryMonitorDidObserveChange(directoryMonitor: self)
            }
            
            // Define a cancel handler to ensure the directory is closed when the source is cancelled.
            directoryMonitorSource?.setCancelHandler{
                close(self.monitoredDirectoryFileDescriptor)
                
                self.monitoredDirectoryFileDescriptor = -1
                
                self.directoryMonitorSource = nil
            }
            
            // Start monitoring the directory via the source.
            directoryMonitorSource?.resume()
        }
    }
    
    func stopMonitoring() {
        // Stop listening for changes to the directory, if the source has been created.
        if directoryMonitorSource != nil {
            // Stop monitoring the directory via the source.
            directoryMonitorSource?.cancel()
        }
    }
}
