const c = @cImport(@cInclude("mupdf/fitz.h"));

pub const PdfImage = struct {
    data: [*]u8,
    width: c_int,
    height: c_int,
};

pub fn image(file: [:0]const u8) PdfImage {
    const ctx = c.fz_new_context(null, null, 0);
    const doc = c.fz_open_document(ctx, file);
    const page = c.fz_load_page(ctx, doc, 0);
    const ctm: c.fz_matrix = undefined;

    const pix = c.fz_new_pixmap_from_page(ctx, page, ctm, null, 0);

    return PdfImage{
        .data = c.fz_pixmap_samples(ctx, pix),
        .width = c.fz_pixmap_width(ctx, pix),
        .height = c.fz_pixmap_height(ctx, pix),
    };
}
