const c = @cImport(@cInclude("mupdf/fitz.h"));
const std = @import("std");
const e = @import("errors.zig");
const state = @import("state.zig");

pub const PdfImage = struct {
    data: [*]u8,
    width: c_int,
    height: c_int,
};

pub fn init(file: [:0]const u8) !PdfImage {
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
    for(0..total_page) |i|{
        std.debug.print("page {} of {}\n", .{i+1,total_page});
}
    
        
    const page = c.fz_load_page(ctx, doc, state.page_number);

    const scale: f32 = 1.0;
    const ctm = c.fz_scale(scale, scale);

    const pix = c.fz_new_pixmap_from_page(ctx, page, ctm, c.fz_device_rgb(ctx), 1);

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

pub fn save(ctx: *c.fz_context, doc: *c.fz_document, path: [:0]const u8) !void {
    const writer_pdf = c.fz_new_pdf_writer(ctx, path, null) orelse {
        std.debug.print("Failed to create writer", .{});
        return e.WriterError.FailedToCreateWriter;
    };
    defer c.fz_drop_document_writer(ctx, writer_pdf);
    c.fz_write_document(ctx, writer_pdf, doc);
    c.fz_close_document_writer(ctx, writer_pdf);
}
