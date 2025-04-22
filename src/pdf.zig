const c = @cImport(@cInclude("mupdf/fitz.h"));
const std = @import("std");
const errors = @import("errors.zig");

pub const PdfImage = struct {
    data: [*]u8,
    width: c_int,
    height: c_int,
};

pub fn init(file: [:0]const u8) !PdfImage {
    const ctx = c.fz_new_context(null, null, c.FZ_STORE_UNLIMITED) orelse {
        std.debug.print("Filed to create mupdf conext\n", .{});
        return errors.DocumentError.FailedToCreateContext;
    };
    errdefer c.fz_drop_context(ctx);

    c.fz_register_document_handlers(ctx);
    const page_num: u16 = 0;

    //other test
    const doc = c.fz_open_document(ctx, file.ptr) orelse {
        std.debug.print("Failed to open document: {s}\n", .{c.fz_caught_message(ctx)});
        return errors.DocumentError.FailedToOpenDocument;
    };
    errdefer c.fz_drop_document(ctx, doc);
    std.debug.print("File Path: {s}\n", .{file});

    //const page_count = @as(u16, @intCast(c.fz_count_pages(ctx, doc)));
    const page = c.fz_load_page(ctx, doc, page_num);
    defer c.fz_drop_page(ctx, page);

    //const bound = c.fz_bound_page(ctx, page);

    const view_width: f32 = 500;
    const view_height: f32 = 500;

    const bbox = c.fz_make_irect(
        0,
        0,
        @intFromFloat(view_width),
        @intFromFloat(view_height),
    );

    //const scale: f32 = 1.0;

    std.debug.print("ctm created\n", .{});
    const pix = c.fz_new_pixmap_with_bbox(ctx, c.fz_device_rgb(ctx), bbox, null, 1);

    //const ctm = c.fz_scale(scale, scale);

    const data = c.fz_pixmap_samples(ctx, pix);
    const width = c.fz_pixmap_width(ctx, pix);
    const height = c.fz_pixmap_height(ctx, pix);
    std.debug.print("Width: {d}\n", .{width});
    std.debug.print("Height: {d}\n", .{height});

    return PdfImage{
        .data = data,
        .width = width,
        .height = height,
    };
}
