const std = @import("std");
const dvui = @import("dvui");
const ArrayList = std.ArrayList;

const c = @cImport(@cInclude("mupdf/fitz.h"));
const e = @import("errors.zig");
const state = @import("state.zig");

pub const PdfImage = struct {
    data: ArrayList([*]u8),
    width: ArrayList(c_int),
    height: ArrayList(c_int),
};

pub fn init(file: [:0]const u8, vp: dvui.Rect) !PdfImage {
    var images: PdfImage = PdfImage{};
    const ctx = c.fz_new_context(null, null, c.FZ_STORE_UNLIMITED) orelse {
        std.debug.print("Failed to create mupdf context\n", .{});
        return e.DocumentError.FailedToCreateContext;
    };
    errdefer c.fz_drop_context(ctx);
    state.ctx = ctx;

    c.fz_register_document_handlers(ctx);
    c.fz_set_error_callback(ctx, null, null);
    c.fz_set_warning_callback(ctx, null, null);

    const doc = c.fz_open_document(ctx, file.ptr) orelse {
        std.debug.print("Failed to open document: {s}\n", .{c.fz_caught_message(ctx)});
        return e.DocumentError.FailedToOpenDocument;
    };
    errdefer c.fz_drop_document(ctx, doc);
    state.doc = doc;

    const pages_total: u16 = c.fz_count_pages(ctx, doc);
    state.pages_total = pages_total;

    const colorspace = c.fz_device_rgb(ctx);

    for (0..pages_total) |i| {
        const page = c.fz_load_page(ctx, doc, i);
        var bounds = c.fz_bound_page(ctx, page);
        const scale = vp.w / bounds.x1;
        const ctm = c.fz_scale(scale, scale);
        bounds = c.fz_transform_rect(bounds, ctm);
        const view_width = @max(1, @min(
            scale * bounds.x1,
            vp.w,
        ));
        const view_height = @max(1, @min(
            scale * bounds.y1,
            vp.h,
        ));
        const bbox = c.fz_make_irect(
            0,
            0,
            @intFromFloat(view_width),
            @intFromFloat(view_height),
        );
        const pix = c.fz_new_pixmap_with_bbox(ctx, colorspace, bbox, null, 1);
        defer c.fz_drop_pixmap(ctx, pix);
        images.data.append(c.fz_pixmap_samples(ctx, pix));
        images.width.append(c.fz_pixamp_width(ctx, pix));
        images.height.append(c.fz_pixmap_height(ctx, pix));
    }

    return images;
}

pub fn save(ctx: *c.fz_context, doc: *c.fz_document, path: [:0]const u8) !void {
    const writer_pdf = c.fz_new_pdf_writer(ctx, path, null) orelse {
        std.debug.print("Failed to create writer", .{});
        return e.WriterError.FailedToCreateWriter;
    };
    defer c.fz_drop_document_writer(ctx, writer_pdf);
    c.fz_write_document(ctx, writer_pdf, doc);
    c.fz_close_document_writer(ctx, writer_pdf);
}
