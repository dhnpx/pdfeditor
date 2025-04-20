const dvui = @import("dvui");
const Backend = dvui.backend;
const Window = dvui.Window;

pub const vsync = true;
pub const show_demo = true;
pub var scale_val: f32 = 1.0;

pub var show_dialog_outside_frame: bool = false;
pub var g_backend: ?Backend = null;
pub var g_win: ?Window = null;
