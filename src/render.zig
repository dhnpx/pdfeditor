const dvui = @import("dvui");
const state = @import("state.zig");
const pdf = @import("pdf.zig");
const enums = dvui.enums;
const c = @cImport(@cInclude("mupdf/fitz.h"));
const Backend = dvui.backend;
//just test bud
const std = @import("std");


// // both dvui and SDL drawing
pub fn gui_frame() !void {
    //const backend = state.g_backend orelse return;
    {
        
        var m = try dvui.menu(@src(),  .horizontal, .{ .background = true, .expand = .horizontal });
        defer m.deinit();

        if (try dvui.menuItemLabel(@src(), "File", .{ .submenu = true }, .{  .expand = .none })) |r| {
            var fw = try dvui.floatingMenu(@src(), r, .{});
            defer fw.deinit();
            if (try dvui.menuItemLabel(@src(), "Open", .{}, .{}) != null) {
                //before
                std.debug.print("Before\n", .{});

                const file = try dvui.dialogNativeFileOpen(dvui.currentWindow().arena(), .{ .title = "Pick file" });

                if (file) |val| {
                    const image = try pdf.init(val);
                    state.height = @intCast(image.height);
                    state.width = @intCast(image.width);
                    state.loaded_texture = dvui.textureCreate(image.data, @intCast(image.width), @intCast(image.height), enums.TextureInterpolation.nearest);
                    state.loaded_texture1 = state.loaded_texture;
                } else {
                    std.debug.print("File is null\n", .{});
                }
                m.close();
            }
            if (try dvui.menuItemLabel(@src(), "Save", .{}, .{}) != null) {
                const path = try dvui.dialogNativeFileSave(dvui.currentWindow().arena(), .{ .title = "Save" });
                if (path) |val| {
                    try pdf.save(state.ctx.?, state.doc.?, val);
                }
                m.close();
            }
        }

        if (try dvui.menuItemLabel(@src(), "Edit", .{ .submenu = true }, .{ .expand = .none })) |r| {
            var fw = try dvui.floatingMenu(@src(), r, .{});
            defer fw.deinit();
            _ = try dvui.menuItemLabel(@src(), "Dummy", .{}, .{ .expand = .horizontal });
            _ = try dvui.menuItemLabel(@src(), "Dummy Long", .{}, .{ .expand = .horizontal });
            _ = try dvui.menuItemLabel(@src(), "Dummy Super Long", .{}, .{ .expand = .horizontal });
        }
    }

//    const width2: u32 = state.width + 10;
//    const fwidth2: f32 = @floatFromInt(width2);
//    const height2: u32 = state.height + 10;
//    const fheight2: f32 = @floatFromInt(height2);
    var scroll = try dvui.scrollArea( @src(), .{ .vertical_bar = .show}, .{ .expand = .both, .min_size_content = .{ .h = @floatFromInt(100000) , .w = @floatFromInt(100000) } }, );
    defer scroll.deinit();
    //var t12 = try dvui.textLayout(@src(), .{}, .{ .expand = .horizontal });
    //try t12.addText(
    //\\DVUI
    //,.{});
    //try t12.addText("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n", .{});   
    //t12.deinit();
    //var t12 = try dvui.texture
    var pageBox = try dvui.box( @src(), .vertical, .{ .expand = .both, .min_size_content = .{ .w = @floatFromInt(state.width), .h = @floatFromInt(state.height) }, },);
    
    //var pageBox = try dvui.box( @src(), .vertical, .{ .expand = .both, .min_size_content = .{ .w = fwidth2, .h = fheight2 }, },);
    defer pageBox.deinit();
    
        const drawRect = dvui.RectScale{ .r = .{
            .x = scroll.data().contentRect().x,
            .y = scroll.data().contentRect().y,
            .w = @floatFromInt(state.width),
            //.w = scroll.data().contentRect().w,
            .h = @floatFromInt(state.height),
        }, .s = state.scale_val};
    

       
    // render texture maybe
    if (state.loaded_texture) |tex| {
    std.debug.print("Ok now so like ok dude\n", .{});
    
        var hbox = try dvui.box(@src(), .horizontal, .{});
        defer hbox.deinit();
        try dvui.renderTexture(tex, drawRect, .{ .debug = false });
        if (try dvui.button(@src(), "Previous", .{}, .{})){
            std.debug.print("Before\n", .{});
            state.loaded_texture = state.loaded_texture1; 

        }
        if (try dvui.button(@src(),"Next",.{}, .{})){
            std.debug.print("Next\n", .{});
            state.loaded_texture = state.loaded_texture2;
        }


        //try dvui.renderTexture(tex, .{ .r = .{ .x = 0, .y = 0, .w = @floatFromInt(state.width), .h = @floatFromInt(state.height) }, .s = state.scale_val }, .{ .rotation = 0, .colormod = .{}, .uv = .{ .x = -1, .y = -1 }, .debug = false });
    } 
    //if (state.loaded_texture2) |text| {
      //  std.debug.print("2nd texture\n", .{});
        //try dvui.renderTexture(text, .{ .r = .{ .x = 0, .y = fheight2, .w = @floatFromInt(state.width), .h = @floatFromInt(state.height) }, .s = state.scale_val }, .{ .rotation = 0, .colormod = .{}, .uv = .{ .x = -1, .y = -1 }, .debug = false });


       // try dvui.renderTexture(text, .{ .r = .{ .x = 0, .y = fheight2, .w = scroll.data().contentRect().w, .h = scroll.data().contentRect().h }, .s = state.scale_val }, .{ .rotation = 0, .colormod = .{}, .uv = .{ .x = -1, .y = -1 }, .debug = false });

    //}
}
