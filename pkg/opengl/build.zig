const std = @import("std");

pub fn build(b: *std.Build) !void {
    _ = b.addModule("opengl", .{ .root_source_file = .{ .path = "main.zig" } });
}
