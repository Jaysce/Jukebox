//
//  MetalView.swift
//  Jukebox
//
//  Created by Sasindu Jayasinghe on 28/10/21.
//

import Foundation
import SwiftUI
import MetalKit

struct MetalView: NSViewRepresentable {
    
    var popoverIsShown: Bool
    
    func makeNSView(context: Context) -> MTKView {
        
        let mtkView = MTKView()
        mtkView.delegate = context.coordinator
        mtkView.preferredFramesPerSecond = 60
        
        // Create our device, which is an abstract representation of the GPU
        if let device = MTLCreateSystemDefaultDevice() {
            mtkView.device = device
        }
        
        mtkView.framebufferOnly = false
        
        // Clear color is what is displayed between each frame as each draw is discarded
        mtkView.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1)
        mtkView.drawableSize = mtkView.frame.size
        
        return mtkView
        
    }
    
    func updateNSView(_ mtkView: MTKView, context: Context) {
        if (popoverIsShown) {
            mtkView.isPaused = false
            print("Drawing shader...")
        } else {
            mtkView.enableSetNeedsDisplay = false
            mtkView.isPaused = true
            print("Pausing shader...")
        }
    }
    
}

extension MetalView {
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    class Coordinator: NSObject, MTKViewDelegate {
        
        let timeStep = Float(1.0 / 60.0)
        var time = Float.zero
        
        var parent: MetalView // The view we are rendering
        var device: MTLDevice! // Abstract representation of GPU
        var commandQueue: MTLCommandQueue! // The queue which holds a number of command buffers
        var computePipelineState: MTLComputePipelineState! // The pipeline which our renderer runs through
        
        // MTLBuffer is Unformatted Device Accessible Space, we can reserve a certain amount
        // of space (allocate space), and have a reference to it to write and read to / from it.
        // The CPU and GPU can read / write to this buffer
        var timeBuffer: MTLBuffer!
        
        init(_ parent: MetalView) {
            
            self.parent = parent
            if let metalDevice = MTLCreateSystemDefaultDevice() {
                self.device = metalDevice
            }
            self.commandQueue = device.makeCommandQueue()
            
            super.init()
            
            createComputePipelineState()
            createBuffers()
            
        }
        
        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
        
        func createComputePipelineState() {
            
            // Get all .metal files in project and compile into a default library
            guard let library = device.makeDefaultLibrary() else { return }
        
            // Get our 'compute' function for the shader from the library of Metal files
            guard let computeFunction = library.makeFunction(name: "compute") else { return }
            
            // Create the pipeline state
            do {
                computePipelineState = try device.makeComputePipelineState(function: computeFunction)
            } catch let error {
                print("Error creating pipline: \(error)")
            }
        }
        
        // Initialise the buffers, length is the allocation size in bytes we want
        func createBuffers() {
            timeBuffer = device.makeBuffer(length: MemoryLayout<Float>.size, options: [])
        }
        
        func draw(in view: MTKView) {
            
            guard let drawable = view.currentDrawable else { return }
            
            // Time
            time += timeStep
            let timeBufferPtr = timeBuffer.contents().bindMemory(to: Float.self, capacity: 1)
            timeBufferPtr.pointee = time
            
            // A Command Buffer is a container that stores encoded commands for the GPU to execute
            // Command Buffers are what are put into the command queue, ready for execution by the GPU
            guard let commandBuffer = commandQueue.makeCommandBuffer() else { return }
            
            // A command encoder is telling our command buffer what to do when it is committed
            // The actual commands that the GPU will execute once committed
            guard let commandEncoder = commandBuffer.makeComputeCommandEncoder() else { return }
            
            // First thing we do is set the commandEncoder's computePiplineState that we created above
            commandEncoder.setComputePipelineState(computePipelineState)
            
            // Send info to commandEncoder
            commandEncoder.setTexture(drawable.texture, index: 0)
            
            // Set the buffer (the time buffer which we allocated before) at index 0 of the device space
            commandEncoder.setBuffer(timeBuffer, offset: 0, index: 0)
            
            let width = computePipelineState.threadExecutionWidth
            let height = computePipelineState.maxTotalThreadsPerThreadgroup / width
            let threadGroupCount = MTLSizeMake(width, height, 1)
            let threadGroups = MTLSize(
                width: (drawable.texture.width + width - 1) / width,
                height: (drawable.texture.height + height - 1) / height,
                depth: 1)
            
            commandEncoder.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadGroupCount)
            
            // Finish encoding
            commandEncoder.endEncoding()
            
            // Get the drawable ready for presentation to screen and commit Command Buffer for execution by GPU
            commandBuffer.present(drawable)
            commandBuffer.commit()
            
        }
        
    }
    
}
