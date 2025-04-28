const dvui = @import("dvui");
const c = @cImport(@cInclude("mupdf/fitz.h"));

const Backend = dvui.backend;
const Window = dvui.Window;

pub const vsync = true;
pub const show_demo = true;
pub var scale_val: f32 = 1.0;

pub var show_dialog_outside_frame: bool = false;
pub var g_backend: ?Backend = null;
pub var g_win: ?Window = null;

// pdf
pub var doc: ?*c.fz_document = null;
pub var ctx: ?*c.fz_context = null;

pub var loaded_texture: ?dvui.Texture = null;
pub var height: u32 = 0;
pub var width: u32 = 0;
pub var page_number: u16 = 0;
pub var max_page: u16 = 0;
pub var loaded_texture1: ?dvui.Texture = null;
pub var loaded_texture2: ?dvui.Texture = null;
pub var loaded_texture3: ?dvui.Texture = null;
pub var loaded_texture4: ?dvui.Texture = null;
pub var loaded_texture5: ?dvui.Texture = null;
pub var loaded_texture6: ?dvui.Texture = null;
pub var loaded_texture7: ?dvui.Texture = null;
pub var loaded_texture8: ?dvui.Texture = null;
pub var loaded_texture9: ?dvui.Texture = null;
pub var loaded_texture10: ?dvui.Texture = null;
pub var loaded_texture11: ?dvui.Texture = null;
pub var loaded_texture12: ?dvui.Texture = null;

