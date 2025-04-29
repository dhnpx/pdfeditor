const dvui = @import("dvui");
const state = @import("state.zig");
const pdf = @import("pdf.zig");
const enums = dvui.enums;
const c = @cImport(@cInclude("mupdf/fitz.h"));
const Backend = dvui.backend;
//just test bud
const std = @import("std");
const ArrayList = std.ArrayList;

var gpa_instance = std.heap.GeneralPurposeAllocator(.{}){};
const gpa = gpa_instance.allocator();

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

                if (file != null) {
                    state.file = try std.mem.Allocator.dupeZ(gpa, u8, file.?);
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
    var scroll_info: dvui.ScrollInfo = .{ .vertical = .given };
    var scroll = try dvui.scrollArea(@src(), .{ .scroll_info = &scroll_info }, .{ .expand = .both });
    defer scroll.deinit();

    if (state.file != null) {
        std.debug.print("File name: {s}", .{state.file.?});
        const viewport = scroll.data().contentRect();
        const images = try pdf.init(state.file.?, viewport);
        for (0..images.len) |i| {
            state.height = @as(f32, @floatFromInt(images.height[i]));
            state.width = @as(f32, @floatFromInt(images.width[i]));
            state.loaded_texture = dvui.textureCreate(images.data[i], @intCast(images.width[i]), @intCast(images.height[i]), enums.TextureInterpolation.nearest);
            const drawRect = dvui.RectScale{ .r = .{
                .x = scroll.data().contentRect().x,
                .y = scroll.data().contentRect().y,
                .w = scroll.data().contentRect().w,
                .h = state.height,
            }, .s = 1 };
            try dvui.renderTexture(state.loaded_texture, drawRect, .{ .debug = true });
        }
    }

    // render texture maybe
    // if (state.loaded_texture) |tex| {
    //     std.debug.print("Ok now so like ok dude\n", .{});
    //     //const scale: f32 = scroll.data().contentRect().w / @as(f32, @floatFromInt(tex.width));
    //     //const display_height: f32 = @round(@as(f32, @floatFromInt(tex.height)) * scale);
    // }
}
