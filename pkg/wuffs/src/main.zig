const std = @import("std");

pub const png = @import("png.zig");
pub const jpeg = @import("jpeg.zig");
pub const swizzle = @import("swizzle.zig");

pub const ImageData = struct {
    width: u32,
    height: u32,
    data: []const u8,
};

test {
    std.testing.refAllDeclsRecursive(@This());
}
