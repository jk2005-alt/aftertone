import MetalKit
import SwiftUI

/// Orthographic globe with fixed atmospheric lighting and a rotating surface atlas.
struct EarthSurface: NSViewRepresentable {
    let playing: Bool

    func makeCoordinator() -> Renderer { Renderer() }

    func makeNSView(context: Context) -> MTKView {
        let view = MTKView(frame: .zero, device: MTLCreateSystemDefaultDevice())
        view.colorPixelFormat = .bgra8Unorm_srgb
        view.clearColor = MTLClearColorMake(0, 0, 0, 0)
        view.preferredFramesPerSecond = 30
        view.isPaused = true
        view.enableSetNeedsDisplay = false
        context.coordinator.prepare(view)
        return view
    }

    func updateNSView(_ view: MTKView, context: Context) {
        context.coordinator.setPlaying(playing, in: view)
    }

    static func dismantleNSView(_ view: MTKView, coordinator: Renderer) {
        view.isPaused = true
        view.delegate = nil
    }

    final class Renderer: NSObject, MTKViewDelegate {
        private var pipeline: MTLRenderPipelineState?
        private var texture: MTLTexture?
        private var nightLighting: MTLTexture?
        private var queue: MTLCommandQueue?
        private var accumulated: TimeInterval = 0
        private var started: TimeInterval?

        func prepare(_ view: MTKView) {
            guard let device = view.device,
                  let url = Bundle.main.url(forResource: "EarthSurface", withExtension: "png"),
                  let nightURL = Bundle.main.url(forResource: "EarthHorizon", withExtension: "jpg"),
                  let library = try? device.makeLibrary(source: Self.shader, options: nil) else {
                view.isHidden = true
                return
            }
            let descriptor = MTLRenderPipelineDescriptor()
            descriptor.vertexFunction = library.makeFunction(name: "earthVertex")
            descriptor.fragmentFunction = library.makeFunction(name: "earthFragment")
            descriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
            pipeline = try? device.makeRenderPipelineState(descriptor: descriptor)
            texture = try? MTKTextureLoader(device: device).newTexture(URL: url, options: [
                .SRGB: true, .generateMipmaps: true, .origin: MTKTextureLoader.Origin.topLeft
            ])
            nightLighting = try? MTKTextureLoader(device: device).newTexture(URL: nightURL, options: [
                .SRGB: true, .generateMipmaps: true, .origin: MTKTextureLoader.Origin.topLeft
            ])
            queue = device.makeCommandQueue()
            view.isHidden = pipeline == nil || texture == nil || nightLighting == nil || queue == nil
            view.delegate = self
        }

        func setPlaying(_ active: Bool, in view: MTKView) {
            guard !view.isHidden else { return }
            let now = ProcessInfo.processInfo.systemUptime
            if active, started == nil { started = now }
            if !active, let start = started {
                accumulated += now - start
                started = nil
            }
            view.isPaused = !active
            if !active { view.draw() }
        }

        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
            if view.isPaused { view.draw() }
        }

        func draw(in view: MTKView) {
            guard let pipeline, let texture, let nightLighting, let pass = view.currentRenderPassDescriptor,
                  let drawable = view.currentDrawable, let buffer = queue?.makeCommandBuffer(),
                  let encoder = buffer.makeRenderCommandEncoder(descriptor: pass) else { return }
            let elapsed = accumulated + (started.map { ProcessInfo.processInfo.systemUptime - $0 } ?? 0)
            var phase = Float(elapsed.truncatingRemainder(dividingBy: 360) / 360)
            encoder.setRenderPipelineState(pipeline)
            encoder.setFragmentTexture(texture, index: 0)
            encoder.setFragmentTexture(nightLighting, index: 1)
            encoder.setFragmentBytes(&phase, length: MemoryLayout<Float>.size, index: 0)
            encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
            encoder.endEncoding()
            buffer.present(drawable)
            buffer.commit()
        }

        private static let shader = """
        #include <metal_stdlib>
        using namespace metal;
        struct Vertex { float4 position [[position]]; float2 uv; };
        vertex Vertex earthVertex(uint id [[vertex_id]]) {
            float2 uv = float2((id << 1) & 2, id & 2);
            return {float4(uv.x * 2 - 1, 1 - uv.y * 2, 0, 1), uv};
        }
        fragment float4 earthFragment(Vertex in [[stage_in]], texture2d<float> atlas [[texture(0)]],
                                      texture2d<float> night [[texture(1)]], constant float &phase [[buffer(0)]]) {
            constexpr sampler surface(coord::normalized, s_address::repeat, t_address::clamp_to_edge,
                                      filter::linear, mip_filter::linear);
            // Fit the silhouette of the original wide painting in its image coordinates.
            float2 p = float2(in.uv.x - 0.765, (0.059 - in.uv.y) / 2.15 + 1.38) / 1.38;
            float radius = length(p);
            float inside = 1.0 - radius;
            constexpr sampler lightSampler(coord::normalized, address::clamp_to_edge, filter::linear, mip_filter::linear);
            float3 rim = night.sample(lightSampler, in.uv).rgb;
            if (inside <= 0.0) return float4(rim, 1);
            float3 normal = float3(p, sqrt(max(0.0, 1.0 - dot(p,p))));
            // Tilt the viewing latitude so the visible cap includes inhabited latitudes.
            float3 globe = float3(normal.x, 0.85 * normal.y - 0.5268 * normal.z,
                                  0.5268 * normal.y + 0.85 * normal.z);
            float2 uv = float2(0.42 + atan2(globe.x, globe.z) / 6.2831853 - phase,
                               0.5 - asin(clamp(globe.y,-1.0,1.0)) / 3.14159265);
            float3 terrain = atlas.sample(surface, uv).rgb;
            // Low-pass the reference so its lighting stays fixed while all cloud detail rotates.
            float3 illumination = night.sample(lightSampler, in.uv, level(6)).rgb;
            float reflectance = dot(terrain, float3(0.2126, 0.7152, 0.0722));
            constexpr float3 luma = float3(0.2126, 0.7152, 0.0722);
            float localMean = sqrt(dot(atlas.sample(surface, uv, bias(2.5)).rgb, luma));
            float cloud = sqrt(reflectance);
            // Recover small-scale cloud structure from the reference storm. Both
            // samples use globe coordinates so the filaments stay on the surface.
            float2 fold = 1.0 - abs(fract(uv * float2(6, 3)) * 2.0 - 1.0);
            float2 stormUV = float2(0.035, 0.57) + fold * float2(0.34, 0.36);
            float filament = dot(night.sample(lightSampler, stormUV).rgb, luma);
            float envelope = dot(night.sample(lightSampler, stormUV, bias(3.0)).rgb, luma);
            float relief = clamp((filament - envelope) / (envelope + 0.0008), -0.75, 1.5);
            float detail = max(0.12, 0.32 + 2.35 * cloud + 3.2 * (cloud - localMean));
            detail *= 1.0 + relief * smoothstep(0.08, 0.55, cloud);
            float3 surfaceColor = illumination * detail;
            return float4(mix(rim, surfaceColor, smoothstep(0.0, 0.008, inside)), 1);
        }
        """
    }
}
