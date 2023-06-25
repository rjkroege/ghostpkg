const std = @import("std");
const Allocator = std.mem.Allocator;
const foundation = @import("../foundation.zig");
const c = @import("c.zig");

pub const Data = opaque {
    pub fn createWithBytesNoCopy(data: []const u8) Allocator.Error!*Data {
        return @ptrFromInt(
            ?*Data,
            @intFromPtr(c.CFDataCreateWithBytesNoCopy(
                null,
                data.ptr,
                @intCast(c_long, data.len),
                c.kCFAllocatorNull,
            )),
        ) orelse error.OutOfMemory;
    }

    pub fn release(self: *Data) void {
        foundation.CFRelease(self);
    }
};

test {
    //const testing = std.testing;

    var raw = "hello world";
    const data = try Data.createWithBytesNoCopy(raw);
    defer data.release();
}
