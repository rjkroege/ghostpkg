const std = @import("std");
const assert = std.debug.assert;
const Allocator = std.mem.Allocator;
const foundation = @import("../foundation.zig");
const graphics = @import("../graphics.zig");
const c = @import("c.zig");

pub const Path = opaque {
    pub fn createWithRect(
        rect: graphics.Rect,
        transform: ?*const graphics.AffineTransform,
    ) Allocator.Error!*Path {
        return @intToPtr(
            ?*Path,
            @ptrToInt(c.CGPathCreateWithRect(
                rect.cval(),
                @ptrCast(?[*]const c.struct_CGAffineTransform, transform),
            )),
        ) orelse Allocator.Error.OutOfMemory;
    }

    pub fn release(self: *Path) void {
        foundation.CFRelease(self);
    }
};

pub const MutablePath = opaque {
    pub fn create() Allocator.Error!*MutablePath {
        return @intToPtr(
            ?*MutablePath,
            @ptrToInt(c.CGPathCreateMutable()),
        ) orelse Allocator.Error.OutOfMemory;
    }

    pub fn release(self: *MutablePath) void {
        foundation.CFRelease(self);
    }

    pub fn addRect(
        self: *MutablePath,
        transform: ?*const graphics.AffineTransform,
        rect: graphics.Rect,
    ) void {
        c.CGPathAddRect(
            @ptrCast(c.CGMutablePathRef, self),
            @ptrCast(?[*]const c.struct_CGAffineTransform, transform),
            rect.cval(),
        );
    }
};

test "mutable path" {
    //const testing = std.testing;

    const path = try MutablePath.create();
    defer path.release();

    path.addRect(null, graphics.Rect.init(0, 0, 100, 200));
}

test "path from rect" {
    const path = try Path.createWithRect(graphics.Rect.init(0, 0, 100, 200), null);
    defer path.release();
}
