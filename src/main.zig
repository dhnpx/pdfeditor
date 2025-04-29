const std = @import("std");
const builtin = @import("builtin");
const dvui = @import("dvui");

const state = @import("state.zig");
const render = @import("render.zig");
const pdf = @import("pdf.zig");
//const BBackend = @import("SDLBackend");
const Backend = dvui.backend;
comptime {
    std.debug.assert(@hasDecl(Backend, "SDLBackend"));
}

const window_icon_png = @embedFile("assets/pdf.png");

var gpa_instance = std.heap.GeneralPurposeAllocator(.{}){};
const gpa = gpa_instance.allocator();

/// This example shows how to use the dvui for a normal application:
/// - dvui renders the whole application
/// - render frames only when needed
///
pub fn main() !void {
    std.log.info("SDL version: {}", .{Backend.getSDLVersion()});

    dvui.Examples.show_demo_window = state.show_demo;

    defer if (gpa_instance.deinit() != .ok) @panic("Memory leak on exit!");

    // init SDL backend (creates and owns OS window)
    var backend = try Backend.initWindow(.{
        .allocator = gpa,
        .size = .{ .w = 800.0, .h = 600.0 },
        .min_size = .{ .w = 250.0, .h = 350.0 },
        .vsync = state.vsync,
        .title = "DVUI SDL Standalone Example",
        .icon = window_icon_png, // can also call setIconFromFileContent()
    });


    //testing scroll stuff
    //const sa_opts = dvui.ScrollAreaWidget.InitOpts{
    //    .scroll_info    = null,
    //   .vertical       = null,                 // let DVUI pick auto/given
    //    .horizontal     = null,
    //    .vertical_bar   = .show,                // always show vertical bar
    //    .horizontal_bar = .show,                // always show horizontal bar
    //    .focus_id       = null,
    //    .lock_visible   = false,
    //};
    //var sa = try dvui.ScrollAreaWidget.init(@src(), sa_opts, .{ .expand = .both });
    //defer sa.deinit();
    //try sa.install();


    

    
    state.g_backend = backend;
    defer backend.deinit();

    _ = Backend.c.SDL_EnableScreenSaver();
    // init dvui Window (maps onto a single OS window)
    var win = try dvui.Window.init(@src(), gpa, backend.backend(), .{});
    defer win.deinit();
    main_loop: while (true) {

        // beginWait coordinates with waitTime below to run frames only when needed
        const nstime = win.beginWait(backend.hasEvent());

        // marks the beginning of a frame for dvui, can call dvui functions after this
        try win.begin(nstime);
        
        // send all SDL events to dvui for processing
        const quit = try backend.addAllEvents(&win);
        if (quit) break :main_loop;
        

        // Start a scrollable area that fills the window
//        var scroll = try dvui.scrollArea(@src(), .{}, .{ .expand = .both });   // scrollArea widget :contentReference[oaicite:15]{index=15}
//        defer scroll.deinit();

        // Push some content—DVUI will handle clipping & offset
//        for (0..50) |i| {
            //try dvui.label(@src(), "Item {d}", .{i});                           // label inside scroll :contentReference[oaicite:16]{index=16}
  //      }



        // if dvui widgets might not cover the whole window, then need to clear
        // the previous frame's render
        _ = Backend.c.SDL_SetRenderDrawColor(backend.renderer, 0, 0, 0, 255);
        _ = Backend.c.SDL_RenderClear(backend.renderer);

        // The demos we pass in here show up under "Platform-specific demos"
        try render.gui_frame();

        // marks end of dvui frame, don't call dvui functions after this
        // - sends all dvui stuff to backend for rendering, must be called before renderPresent()
        const end_micros = try win.end(.{});

        // cursor management
        backend.setCursor(win.cursorRequested());
        backend.textInputRect(win.textInputRequested());

        // render frame to OS
        backend.renderPresent();

        // waitTime and beginWait combine to achieve variable framerates
        const wait_event_micros = win.waitTime(end_micros, null);
        backend.waitEventTimeout(wait_event_micros);

        // Example of how to show a dialog from another thread (outside of win.begin/win.end)
        if (state.show_dialog_outside_frame) {
            state.show_dialog_outside_frame = false;
            try dvui.dialog(@src(), .{ .window = &win, .modal = false, .title = "Dialog from Outside", .message = "This is a non modal dialog that was created outside win.begin()/win.end(), usually from another thread." });
        }
    }
}
