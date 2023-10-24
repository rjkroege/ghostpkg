const std = @import("std");
const NativeTargetInfo = std.zig.system.NativeTargetInfo;

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    _ = b.addModule("cimgui", .{ .source_file = .{ .path = "main.zig" } });

    const imgui = b.dependency("imgui", .{});
    const lib = b.addStaticLibrary(.{
        .name = "cimgui",
        .target = target,
        .optimize = optimize,
    });
    lib.linkLibC();
    lib.linkLibCpp();
    if (target.isWindows()) {
        lib.linkSystemLibrary("imm32");
    }

    lib.addIncludePath(imgui.path(""));

    var flags = std.ArrayList([]const u8).init(b.allocator);
    defer flags.deinit();
    try flags.appendSlice(&.{
        "-DIMGUI_DISABLE_OBSOLETE_FUNCTIONS=1",
    });
    if (target.isWindows()) {
        try flags.appendSlice(&.{
            "-DIMGUI_IMPL_API=extern\t\"C\"\t__declspec(dllexport)",
        });
    } else {
        try flags.appendSlice(&.{
            "-DIMGUI_IMPL_API=extern\t\"C\"",
        });
    }

    lib.addCSourceFile(.{ .file = .{ .path = "vendor/cimgui.cpp" }, .flags = flags.items });
    lib.addCSourceFile(.{ .file = imgui.path("imgui.cpp"), .flags = flags.items });
    lib.addCSourceFile(.{ .file = imgui.path("imgui_draw.cpp"), .flags = flags.items });
    lib.addCSourceFile(.{ .file = imgui.path("imgui_demo.cpp"), .flags = flags.items });
    lib.addCSourceFile(.{ .file = imgui.path("imgui_widgets.cpp"), .flags = flags.items });
    lib.addCSourceFile(.{ .file = imgui.path("imgui_tables.cpp"), .flags = flags.items });

    lib.addCSourceFile(.{
        .file = imgui.path("backends/imgui_impl_opengl3.cpp"),
        .flags = flags.items,
    });

    if (target.isDarwin()) {
        if (!target.isNative()) try @import("apple_sdk").addPaths(b, lib);
        lib.addCSourceFile(.{
            .file = imgui.path("backends/imgui_impl_metal.mm"),
            .flags = flags.items,
        });
        lib.addCSourceFile(.{
            .file = imgui.path("backends/imgui_impl_osx.mm"),
            .flags = flags.items,
        });
    }

    lib.installHeadersDirectoryOptions(.{
        .source_dir = .{ .path = "vendor" },
        .install_dir = .header,
        .install_subdir = "",
        .include_extensions = &.{".h"},
    });

    b.installArtifact(lib);

    const test_exe = b.addTest(.{
        .name = "test",
        .root_source_file = .{ .path = "main.zig" },
        .target = target,
        .optimize = optimize,
    });
    test_exe.linkLibrary(lib);
    const tests_run = b.addRunArtifact(test_exe);
    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&tests_run.step);
}
