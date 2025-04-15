const c = @cImport(@cInclude("mupdf/fitz.h"));
const std = @import("std");
pub const PdfImage = struct {
    data: [*]u8,
    width: c_int,
    height: c_int,
};

pub fn image(file: [:0]const u8) !PdfImage {
    const c_file: [*c]const u8 = file.ptr;
    
    const ctx = c.fz_new_context(null, null, c.FZ_STORE_UNLIMITED);
    c.fz_register_document_handlers(ctx);
    std.debug.print("New Context Done\n", .{});

    //other test
    const doc = c.fz_open_document(ctx, c_file.?);
   
    //const doc = c.fz_open_document(ctx, file.ptr);
    std.debug.print("Document Opened\n", .{});
    const page = c.fz_load_page(ctx, doc, 0);

    std.debug.print("Page Loaded\n", .{});
    const ctm: c.fz_matrix = undefined;

    const pix = c.fz_new_pixmap_from_page(ctx, page, ctm, null, 0);

    return PdfImage{
        .data = c.fz_pixmap_samples(ctx, pix),
        .width = c.fz_pixmap_width(ctx, pix),
        .height = c.fz_pixmap_height(ctx, pix),
    };
}


