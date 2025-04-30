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
                    state.images.len = 0;
                    _ = try pdf.init(state.file.?);
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

    if (state.images.len != 0) {
        std.debug.print("File name: {s}", .{state.file.?});
        var hbox = try dvui.box(@src(), .horizontal, .{});
        defer hbox.deinit();
        const image = state.images.get(state.page_current);
        const texture = dvui.textureCreate(image.data, @as(u32, @intCast(image.width)), @as(u32, @intCast(image.height)), enums.TextureInterpolation.linear);
        const drawRect = dvui.RectScale{ .r = .{
            .x = scroll.data().contentRect().x,
            .y = scroll.data().contentRect().y,
            .w = @floatFromInt(state.images.items(.width)[state.page_current]),
            .h = @floatFromInt(state.images.items(.width)[state.page_current]),
        }, .s = 1 };
        try dvui.renderTexture(texture, drawRect, .{ .debug = true });
        if (try dvui.button(@src(), "Previous", .{}, .{})) {
            if (state.page_current != 0) {
                state.page_current -= 1;
            }
        }
        if (try dvui.button(@src(), "Next", .{}, .{})) {
            if (state.page_current != state.images.len - 1) {
                state.page_current += 1;
            }
        }
    }
}
