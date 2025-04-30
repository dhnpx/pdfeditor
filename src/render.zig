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
                    state.files.clearAndFree();
                    try state.files.append(file.?);
                    state.textures.clearAndFree(gpa);
                    state.mode = state.Mode.pdf;
                    _ = try pdf.initSingle(state.files.items[0]);
                }
                m.close();
            }
            if (try dvui.menuItemLabel(@src(), "Open images", .{}, .{}) != null) {
                const files = try dvui.dialogNativeFileOpenMultiple(dvui.currentWindow().arena(), .{ .title = "Open images" });
                if (files.?.len != 0) {
                    state.files.clearAndFree();
                    state.mode = state.Mode.images;
                    for (0..files.?.len) |i| {
                        try state.files.append(files.?[i]);
                    }
                    _ = try pdf.initMultiple(state.files);
                }
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

    var scroll = try dvui.scrollArea(@src(), .{}, .{ .expand = .both });
    defer scroll.deinit();

    if (state.mode == .pdf) {
        if (state.textures.len != 0) {
            std.debug.print("File name: {s}\n", .{state.files.items[0]});
            const texture = state.textures.get(state.page_current);
            std.debug.print("image: {}\n", .{texture});
            const drawRect = dvui.RectScale{
                .r = .{
                    .x = scroll.data().contentRect().x,
                    .y = scroll.data().contentRect().y,
                    .w = @floatFromInt(texture.width),
                    .h = @floatFromInt(texture.height),
                },
                .s = state.scale_val,
            };
            var hbox = try dvui.box(@src(), .horizontal, .{});
            defer hbox.deinit();

            try dvui.renderTexture(texture.data, drawRect, .{ .debug = false });
            if (try dvui.button(@src(), "Previous", .{}, .{})) {
                std.debug.print("Prev button\n", .{});
                if (state.page_current != 0) {
                    state.page_current -= 1;
                }
            }
            if (try dvui.button(@src(), "Next", .{}, .{})) {
                std.debug.print("Next button\n", .{});
                if (state.page_current < state.pages_total - 1) {
                    state.page_current += 1;
                }
            }
        }
    }
    if (state.mode == .images) {
        if (state.images.len != 0) {
            std.debug.print("File name: {s}\n", .{state.files.items[state.page_current]});
            const image = state.images.get(state.page_current);
            std.debug.print("image: {}\n", .{image});
            const drawRect = dvui.RectScale{
                .r = .{
                    .x = scroll.data().contentRect().x,
                    .y = scroll.data().contentRect().y,
                    .w = @floatFromInt(image.width),
                    .h = @floatFromInt(image.height),
                },
                .s = state.scale_val,
            };
            var hbox = try dvui.box(@src(), .horizontal, .{});
            defer hbox.deinit();

            try dvui.renderTexture(image.data, drawRect, .{ .debug = false });
            if (try dvui.button(@src(), "Previous", .{}, .{})) {
                std.debug.print("Prev button\n", .{});
                if (state.page_current != 0) {
                    state.page_current -= 1;
                }
            }
            if (try dvui.button(@src(), "Next", .{}, .{})) {
                std.debug.print("Next button\n", .{});
                if (state.page_current < state.pages_total - 1) {
                    state.page_current += 1;
                }
            }
        }
    }
}
