const dvui = @import("dvui");
const state = @import("state.zig");
const pdf = @import("pdf.zig");
const enums = dvui.enums;
const c = @cImport(@cInclude("mupdf/fitz.h"));
//just test bud
const std = @import("std");

// // both dvui and SDL drawing
pub fn gui_frame() !void {
    //const backend = state.g_backend orelse return;
    var win = state.g_win orelse return;
    var pixmap: pdf.PdfImage = undefined;
    var texture: dvui.Texture = undefined;

    {
        var m = try dvui.menu(@src(), .horizontal, .{ .background = true, .expand = .horizontal });
        defer m.deinit();

        if (try dvui.menuItemLabel(@src(), "File", .{ .submenu = true }, .{ .expand = .none })) |r| {
            var fw = try dvui.floatingMenu(@src(), r, .{});
            defer fw.deinit();
            if (try dvui.menuItemLabel(@src(), "Open", .{}, .{}) != null) {
                //before
                std.debug.print("Before\n", .{});

                const filename = try dvui.dialogNativeFileOpen(dvui.currentWindow().arena(), .{ .title = "Pick file" });

                std.debug.print("After\n", .{});
                if (filename != null) {
                    std.debug.print("filename is not equal to null\n", .{});

                    pixmap = try pdf.init(filename.?);

                    texture = dvui.textureCreate(pixmap.data, @intCast(pixmap.width), @intCast(pixmap.height), enums.TextureInterpolation.nearest);

                    var frame_box = try dvui.box(@src(), .horizontal, .{ .min_size_content = .{ .w = 50, .h = 50 } });

                    try dvui.renderTexture(texture, frame_box.data().contentRectScale(), .{ .debug = true });
                    win.refreshWindow(@src(), win.captureID);
                    frame_box.deinit();
                    // try dvui.renderTexture(texture, .{ .r = .{ .x = 0, .y = 0, .w = @floatFromInt(pixmap.width), .h = @floatFromInt(pixmap.height) }, .s = state.scale_val }, .{ .rotation = 0, .colormod = .{}, .uv = .{ .x = 1, .y = 1 }, .debug = true });
                }
                m.close();
            }
            if (try dvui.menuItemLabel(@src(), "Close Menu", .{}, .{}) != null) {
                m.close();
            }
        }

        if (try dvui.menuItemLabel(@src(), "Edit", .{ .submenu = true }, .{ .expand = .none })) |r| {
            var fw = try dvui.floatingMenu(@src(), r, .{});
            defer fw.deinit();
            _ = try dvui.menuItemLabel(@src(), "Dummy", .{}, .{ .expand = .horizontal });
            _ = try dvui.menuItemLabel(@src(), "Dummy Long", .{}, .{ .expand = .horizontal });
            _ = try dvui.menuItemLabel(@src(), "Dummy Super Long", .{}, .{ .expand = .horizontal });
        }
    }

    var scroll = try dvui.scrollArea(@src(), .{ .vertical = .auto }, .{ .expand = .both, .color_fill = .{ .name = .fill_window } });
    defer scroll.deinit();

    // var tl = try dvui.textLayout(@src(), .{}, .{ .expand = .horizontal, .font_style = .title_4 });
    // const lorem = "This example shows how to use dvui in a normal application.";
    // try tl.addText(lorem, .{});
    // tl.deinit();
    //
    // var tl2 = try dvui.textLayout(@src(), .{}, .{ .expand = .horizontal });
    // try tl2.addText(
    //     \\DVUI
    //     \\- paints the entire window
    //     \\- can show floating windows and dialogs
    //     \\- example menu at the top of the window
    //     \\- rest of the window is a scroll area
    // , .{});
    // try tl2.addText("\n\n", .{});
    // try tl2.addText("Framerate is variable and adjusts as needed for input events and animations.", .{});
    // try tl2.addText("\n\n", .{});
    // if (state.vsync) {
    //     try tl2.addText("Framerate is capped by vsync.", .{});
    // } else {
    //     try tl2.addText("Framerate is uncapped.", .{});
    // }
    // try tl2.addText("\n\n", .{});
    // try tl2.addText("Cursor is always being set by dvui.", .{});
    // try tl2.addText("\n\n", .{});
    // if (dvui.useFreeType) {
    //     try tl2.addText("Fonts are being rendered by FreeType 2.", .{});
    // } else {
    //     try tl2.addText("Fonts are being rendered by stb_truetype.", .{});
    // }
    // tl2.deinit();
    //
    // const label = if (dvui.Examples.show_demo_window) "Hide Demo Window" else "Show Demo Window";
    // if (try dvui.button(@src(), label, .{}, .{})) {
    //     dvui.Examples.show_demo_window = !dvui.Examples.show_demo_window;
    // }
    //
    // {
    //     var scaler = try dvui.scale(@src(), state.scale_val, .{ .expand = .horizontal });
    //     defer scaler.deinit();
    //
    //     {
    //         var hbox = try dvui.box(@src(), .horizontal, .{});
    //         defer hbox.deinit();
    //
    //         if (try dvui.button(@src(), "Zoom In", .{}, .{})) {
    //             state.scale_val = @round(dvui.themeGet().font_body.size * state.scale_val + 1.0) / dvui.themeGet().font_body.size;
    //         }
    //
    //         if (try dvui.button(@src(), "Zoom Out", .{}, .{})) {
    //             state.scale_val = @round(dvui.themeGet().font_body.size * state.scale_val - 1.0) / dvui.themeGet().font_body.size;
    //         }
    //     }
    //
    //     try dvui.labelNoFmt(@src(), "Below is drawn directly by the backend, not going through DVUI.", .{ .margin = .{ .x = 4 } });
    //
    //     var box = try dvui.box(@src(), .horizontal, .{ .expand = .horizontal, .min_size_content = .{ .h = 40 }, .background = true, .margin = .{ .x = 8, .w = 8 } });
    //     defer box.deinit();
    //
    //     // Here is some arbitrary drawing that doesn't have to go through DVUI.
    //     // It can be interleaved with DVUI drawing.
    //     // NOTE: This only works in the main window (not floating subwindows
    //     // like dialogs).
    //
    //     // get the screen rectangle for the box
    //     const rs = box.data().contentRectScale();
    //
    //     // rs.r is the pixel rectangle, rs.s is the scale factor (like for
    //     // hidpi screens or display scaling)
    //     var rect: if (Backend.sdl3) Backend.c.SDL_FRect else Backend.c.SDL_Rect = undefined;
    //     if (Backend.sdl3) rect = .{
    //         .x = (rs.r.x + 4 * rs.s),
    //         .y = (rs.r.y + 4 * rs.s),
    //         .w = (20 * rs.s),
    //         .h = (20 * rs.s),
    //     } else rect = .{
    //         .x = @intFromFloat(rs.r.x + 4 * rs.s),
    //         .y = @intFromFloat(rs.r.y + 4 * rs.s),
    //         .w = @intFromFloat(20 * rs.s),
    //         .h = @intFromFloat(20 * rs.s),
    //     };
    //     _ = Backend.c.SDL_SetRenderDrawColor(backend.renderer, 255, 0, 0, 255);
    //     _ = Backend.c.SDL_RenderFillRect(backend.renderer, &rect);
    //
    //     rect.x += if (Backend.sdl3) 24 * rs.s else @intFromFloat(24 * rs.s);
    //     _ = Backend.c.SDL_SetRenderDrawColor(backend.renderer, 0, 255, 0, 255);
    //     _ = Backend.c.SDL_RenderFillRect(backend.renderer, &rect);
    //
    //     rect.x += if (Backend.sdl3) 24 * rs.s else @intFromFloat(24 * rs.s);
    //     _ = Backend.c.SDL_SetRenderDrawColor(backend.renderer, 0, 0, 255, 255);
    //     _ = Backend.c.SDL_RenderFillRect(backend.renderer, &rect);
    //
    //     _ = Backend.c.SDL_SetRenderDrawColor(backend.renderer, 255, 0, 255, 255);
    //
    //     if (Backend.sdl3)
    //         _ = Backend.c.SDL_RenderLine(backend.renderer, (rs.r.x + 4 * rs.s), (rs.r.y + 30 * rs.s), (rs.r.x + rs.r.w - 8 * rs.s), (rs.r.y + 30 * rs.s))
    //     else
    //         _ = Backend.c.SDL_RenderDrawLine(backend.renderer, @intFromFloat(rs.r.x + 4 * rs.s), @intFromFloat(rs.r.y + 30 * rs.s), @intFromFloat(rs.r.x + rs.r.w - 8 * rs.s), @intFromFloat(rs.r.y + 30 * rs.s));
    // }
    //
    // if (try dvui.button(@src(), "Show Dialog From\nOutside Frame", .{}, .{})) {
    //     state.show_dialog_outside_frame = true;
    // }

    // look at demo() for examples of dvui widgets, shows in a floating window
    //try dvui.Examples.demo();
}
