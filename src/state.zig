const std = @import("std");
const dvui = @import("dvui");
const c = @cImport(@cInclude("mupdf/fitz.h"));

const Backend = dvui.backend;
const Window = dvui.Window;

var gpa_instance = std.heap.GeneralPurposeAllocator(.{}){};
const gpa = gpa_instance.allocator();

pub const vsync = true;
pub const show_demo = true;
pub var scale_val: f32 = 1.0;

pub var show_dialog_outside_frame: bool = false;
pub var g_backend: ?Backend = null;
pub var g_win: ?Window = null;

// pdf
pub var doc: ?*c.fz_document = null;
pub var ctx: ?*c.fz_context = null;

pub var file: ?[:0]const u8 = null;
pub var loaded_texture: ?dvui.Texture = null;
pub var height: f32 = 0;
pub var width: f32 = 0;
