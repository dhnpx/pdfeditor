const dvui = @import("dvui");
const state = @import("state.zig");
const pdf = @import("pdf.zig");
const enums = dvui.enums;
const c = @cImport(@cInclude("mupdf/fitz.h"));
const Backend = dvui.backend;
//just test bud
const std = @import("std");

// // both dvui and SDL drawing

pub fn gui_frame() !void {
    //const backend = state.g_backend orelse return;
    {
        var m = try dvui.menu(@src(), .horizontal, .{ .background = true, .expand = .horizontal });
        defer m.deinit();

        if (try dvui.menuItemLabel(@src(), "File", .{ .submenu = true }, .{ .expand = .none })) |r| {
            var fw = try dvui.floatingMenu(@src(), r, .{});
            defer fw.deinit();
            if (try dvui.menuItemLabel(@src(), "Open", .{}, .{}) != null) {
                //before
                std.debug.print("Before\n", .{});

                const file = try dvui.dialogNativeFileOpen(dvui.currentWindow().arena(), .{ .title = "Pick file" });

                if (file) |val| {
                    const image = try pdf.init(val);
                    state.height = @intCast(image.height);
                    state.width = @intCast(image.width);
                    state.loaded_texture = dvui.textureCreate(image.data, @intCast(image.width), @intCast(image.height), enums.TextureInterpolation.nearest);
                } else {
                    std.debug.print("File is null\n", .{});
                }
                m.close();
            }
            if (try dvui.menuItemLabel(@src(), "Save", .{}, .{}) != null) {
                const path = try dvui.dialogNativeFileSave(dvui.currentWindow().arena(), .{ .title = "Save" });
                if (path) |val| {
                    try pdf.save(state.ctx.?, state.doc.?, val);
                }
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

    var scroll = try dvui.scrollArea(@src(), .{}, .{ .expand = .both, .color_fill = .{ .name = .fill_window } });
    defer scroll.deinit();

    // render texture maybe
    if (state.loaded_texture) |tex| {
        std.debug.print("Ok now so like ok dude\n", .{});

        try dvui.renderTexture(tex, .{ .r = .{ .x = 0, .y = 0, .w = @floatFromInt(state.width), .h = @floatFromInt(state.height) }, .s = state.scale_val }, .{ .rotation = 0, .colormod = .{}, .uv = .{ .x = -1, .y = -1 }, .debug = true });
    }
}
