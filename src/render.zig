const dvui = @import("dvui");
const state = @import("state.zig");
const pdf = @import("pdf.zig");
const errors = @import("errors.zig");

const enums = dvui.enums;
const c = @cImport(@cInclude("mupdf/fitz.h"));
//just test bud
const std = @import("std");

// // both dvui and SDL drawing
pub fn gui_frame() !void {
    //const backend = state.g_backend orelse return;
    //var win = state.g_win orelse return;
    var pixmap: ?pdf.PdfImage = null;
    var texture: ?dvui.Texture = null;
    var filename: ?[:0]const u8 = null;
    var box = try dvui.box(@src(), .vertical, .{ .margin = .{ .x = 10 } });
    defer box.deinit();

    {
        var m = try dvui.menu(@src(), .horizontal, .{ .background = true, .expand = .horizontal });
        defer m.deinit();

        if (try dvui.menuItemLabel(@src(), "File", .{ .submenu = true }, .{ .expand = .none })) |r| {
            var fw = try dvui.floatingMenu(@src(), r, .{});
            defer fw.deinit();
            if (try dvui.menuItemLabel(@src(), "Open", .{}, .{}) != null) {
                filename = try dvui.dialogNativeFileOpen(dvui.currentWindow().arena(), .{ .title = "Pick file" });
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

    var scroll = try dvui.scrollArea(@src(), .{ .vertical = .auto }, .{ .expand = .both, .background = false });
    defer scroll.deinit();

    if (filename != null) {
        pixmap = try pdf.init(filename.?);
        std.debug.print("pixmap rendered\n", .{});

        texture = dvui.textureCreate(pixmap.?.data, @intCast(pixmap.?.width), @intCast(pixmap.?.height), enums.TextureInterpolation.nearest);
        if (texture != null) {
            std.debug.print("Render texture at {d}x{d}\n", .{ texture.?.width, texture.?.height });
        }
        var frame_box = try dvui.box(@src(), .horizontal, .{ .min_size_content = .{ .w = 500, .h = 500 } });
        try dvui.renderTexture(texture.?, frame_box.data().contentRectScale(), .{ .debug = true });
        frame_box.deinit();
    }
}
