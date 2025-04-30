const std = @import("std");
const dvui = @import("dvui");
const c = @cImport(@cInclude("mupdf/fitz.h"));
const pdf = @import("pdf.zig");

const Backend = dvui.backend;
const Window = dvui.Window;

var gpa_instance = std.heap.GeneralPurposeAllocator(.{}){};
const gpa = gpa_instance.allocator();

pub const Mode = enum { pdf, images };

pub const vsync = true;
pub var scale_val: f32 = 1.0;

pub var show_dialog_outside_frame: bool = false;
pub var g_backend: ?Backend = null;
pub var g_win: ?Window = null;

// pdf
pub var doc: ?*c.fz_document = null;
pub var ctx: ?*c.fz_context = null;
pub var pages_total: u16 = 0;
pub var page_current: u16 = 0;

pub var files = std.ArrayList([:0]const u8).init(gpa);

pub const PdfImages = std.MultiArrayList(pdf.PdfImage);
pub var pdfs: PdfImages = PdfImages{};

pub const NonPdfImages = std.MultiArrayList(pdf.NonPdfImage);
pub var images: NonPdfImages = NonPdfImages{};

pub var mode: Mode = undefined;

pub fn clearState() void {
    doc = null;
    ctx = null;
    pages_total = 0;
    page_current = 0;
    files.clearRetainingCapacity();
    pdfs.clearRetainingCapacity();
    images.clearRetainingCapacity();
}
