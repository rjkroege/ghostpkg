const std = @import("std");
const assert = std.debug.assert;
const c = @import("c.zig").c;

/// sentry_uuid_t
pub const UUID = struct {
    value: c.sentry_uuid_t,

    pub fn isNil(self: UUID) bool {
        return c.sentry_uuid_is_nil(&self.value) != 0;
    }

    pub fn string(self: UUID) [37]u8 {
        var buf: [37]u8 = undefined;
        c.sentry_uuid_as_string(&self.value, &buf);
        return buf;
    }
};
