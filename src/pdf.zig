const std = @import("std");
const dvui = @import("dvui");
const ArrayList = std.ArrayList;

const c = @cImport(@cInclude("mupdf/fitz.h"));
const e = @import("errors.zig");
const state = @import("state.zig");
const dvui = @import("dvui");
const enums = dvui.enums;



pub const PdfImage = struct {
    data: dvui.Texture,
    width: c_int,
    height: c_int,
};

var gpa_instance = std.heap.GeneralPurposeAllocator(.{}){};
const gpa = gpa_instance.allocator();

pub fn init(file: [:0]const u8) !void {
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
    const total_page: u16 = @intCast(c.fz_count_pages(ctx,doc));
    //const page_num: u16 = 0;
    state.max_page = total_page;

    const pages_total: u16 = @as(u16, @intCast(c.fz_count_pages(ctx, doc)));
    state.pages_total = pages_total;


    const colorspace = c.fz_device_rgb(ctx);

    for (0..pages_total) |i| {
        const page = c.fz_load_page(ctx, doc, @as(u16, @intCast(i)));

        const ctm = c.fz_scale(1, 1);
        const pix = c.fz_new_pixmap_from_page(ctx, page, ctm, colorspace, 1);
        defer c.fz_drop_pixmap(ctx, pix);

        const width = c.fz_pixmap_width(ctx, pix);
        const height = c.fz_pixmap_height(ctx, pix);
        try state.images.append(gpa, .{
            .data = dvui.textureCreate(c.fz_pixmap_samples(ctx, pix), @as(u32, @intCast(width)), @as(u32, @intCast(height)), dvui.enums.TextureInterpolation.linear),
            .width = width,
            .height = height,
        });
    }

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
