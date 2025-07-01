const std = @import("std");
const assert = std.debug.assert;
const c = @import("c.zig").c;

pub const Range = opaque {
    pub fn destroy(self: *Range) void {
        c.FcRangeDestroy(self.cval());
    }

    pub inline fn cval(self: *Range) *c.struct__FcRange {
        return @ptrCast(self);
    }
};
