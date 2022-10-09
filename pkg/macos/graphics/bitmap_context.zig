const std = @import("std");
const assert = std.debug.assert;
const Allocator = std.mem.Allocator;
const graphics = @import("../graphics.zig");
const context = @import("context.zig");
const c = @import("c.zig");

pub const BitmapContext = opaque {
    pub usingnamespace context.Context(BitmapContext);

    pub fn create(
        data: ?[]u8,
        width: usize,
        height: usize,
        bits_per_component: usize,
        bytes_per_row: usize,
        space: *graphics.ColorSpace,
        opts: c_uint,
    ) Allocator.Error!*BitmapContext {
        return @intToPtr(
            ?*BitmapContext,
            @ptrToInt(c.CGBitmapContextCreate(
                @ptrCast(?*anyopaque, if (data) |d| d.ptr else null),
                width,
                height,
                bits_per_component,
                bytes_per_row,
                @ptrCast(c.CGColorSpaceRef, space),
                opts,
            )),
        ) orelse Allocator.Error.OutOfMemory;
    }
};

test {
    //const testing = std.testing;

    const cs = try graphics.ColorSpace.createDeviceGray();
    defer cs.release();
    const ctx = try BitmapContext.create(null, 80, 80, 8, 80, cs, 0);
    defer ctx.release();

    ctx.setShouldAntialias(true);
    ctx.setShouldSmoothFonts(false);
    ctx.setGrayFillColor(1, 1);
    ctx.setGrayStrokeColor(1, 1);
    ctx.setTextDrawingMode(.fill);
    ctx.setTextMatrix(graphics.AffineTransform.identity());
    ctx.setTextPosition(0, 0);
}
