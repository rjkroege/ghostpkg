const std = @import("std");
const NativeTargetInfo = std.zig.system.NativeTargetInfo;

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const libxml2_enabled = b.option(bool, "enable-libxml2", "Build libxml2") orelse true;
    const freetype_enabled = b.option(bool, "enable-freetype", "Build freetype") orelse true;

    const upstream = b.dependency("fontconfig", .{});

    const lib = b.addStaticLibrary(.{
        .name = "fontconfig",
        .target = target,
        .optimize = optimize,
    });
    lib.linkLibC();
    if (!target.isWindows()) {
        lib.linkSystemLibrary("pthread");
    }
    if (freetype_enabled) {
        const freetype_dep = b.dependency("freetype", .{ .target = target, .optimize = optimize });
        lib.linkLibrary(freetype_dep.artifact("freetype"));
    }
    if (libxml2_enabled) {
        // const libxml2_dep = b.dependency("libxml2", .{ .target = target, .optimize = optimize });
        // lib.linkLibrary(libxml2_dep.artifact("xml2"));
    }

    lib.addIncludePath(upstream.path(""));
    lib.addIncludePath(.{ .path = "override/include" });

    var flags = std.ArrayList([]const u8).init(b.allocator);
    defer flags.deinit();
    try flags.appendSlice(&.{
        "-DHAVE_DIRENT_H",
        "-DHAVE_FCNTL_H",
        "-DHAVE_STDLIB_H",
        "-DHAVE_STRING_H",
        "-DHAVE_UNISTD_H",
        "-DHAVE_SYS_STATVFS_H",
        "-DHAVE_SYS_PARAM_H",
        "-DHAVE_SYS_MOUNT_H",

        "-DHAVE_LINK",
        "-DHAVE_MKSTEMP",
        "-DHAVE_MKOSTEMP",
        "-DHAVE__MKTEMP_S",
        "-DHAVE_MKDTEMP",
        "-DHAVE_GETOPT",
        "-DHAVE_GETOPT_LONG",
        //"-DHAVE_GETPROGNAME",
        //"-DHAVE_GETEXECNAME",
        "-DHAVE_RAND",
        "-DHAVE_RANDOM",
        "-DHAVE_LRAND48",
        //"-DHAVE_RANDOM_R",
        "-DHAVE_RAND_R",
        "-DHAVE_READLINK",
        "-DHAVE_FSTATVFS",
        "-DHAVE_FSTATFS",
        "-DHAVE_LSTAT",
        "-DHAVE_MMAP",
        "-DHAVE_VPRINTF",

        "-DHAVE_FT_GET_BDF_PROPERTY",
        "-DHAVE_FT_GET_PS_FONT_INFO",
        "-DHAVE_FT_HAS_PS_GLYPH_NAMES",
        "-DHAVE_FT_GET_X11_FONT_FORMAT",
        "-DHAVE_FT_DONE_MM_VAR",

        "-DHAVE_POSIX_FADVISE",

        //"-DHAVE_STRUCT_STATVFS_F_BASETYPE",
        // "-DHAVE_STRUCT_STATVFS_F_FSTYPENAME",
        // "-DHAVE_STRUCT_STATFS_F_FLAGS",
        // "-DHAVE_STRUCT_STATFS_F_FSTYPENAME",
        // "-DHAVE_STRUCT_DIRENT_D_TYPE",

        "-DFLEXIBLE_ARRAY_MEMBER",

        "-DHAVE_STDATOMIC_PRIMITIVES",

        "-DFC_GPERF_SIZE_T=size_t",

        // Default errors that fontconfig can't handle
        "-Wno-implicit-function-declaration",
        "-Wno-int-conversion",

        // https://gitlab.freedesktop.org/fontconfig/fontconfig/-/merge_requests/231
        "-fno-sanitize=undefined",
        "-fno-sanitize-trap=undefined",
    });
    const target_info = try NativeTargetInfo.detect(target);
    switch (target_info.target.ptrBitWidth()) {
        32 => try flags.appendSlice(&.{
            "-DSIZEOF_VOID_P=4",
            "-DALIGNOF_VOID_P=4",
        }),

        64 => try flags.appendSlice(&.{
            "-DSIZEOF_VOID_P=8",
            "-DALIGNOF_VOID_P=8",
        }),

        else => @panic("unsupported arch"),
    }
    if (target.isWindows()) {
        try flags.appendSlice(&.{
            "-DFC_CACHEDIR=\"LOCAL_APPDATA_FONTCONFIG_CACHE\"",
            "-DFC_TEMPLATEDIR=\"c:/share/fontconfig/conf.avail\"",
            "-DCONFIGDIR=\"c:/etc/fonts/conf.d\"",
            "-DFC_DEFAULT_FONTS=\"\\t<dir>WINDOWSFONTDIR</dir>\\n\\t<dir>WINDOWSUSERFONTDIR</dir>\\n\"",
        });
    } else {
        try flags.appendSlice(&.{
            "-DHAVE_SYS_STATVFS_H",
            "-DHAVE_SYS_MOUNT_H",
            "-DHAVE_LINK",
            "-DHAVE_MKOSTEMP",
            "-DHAVE_RANDOM",
            "-DHAVE_LRAND48",
            "-DHAVE_RAND_R",
            "-DHAVE_READLINK",
            "-DHAVE_LSTAT",
            "-DHAVE_MMAP",
            "-DHAVE_PTHREAD",

            "-DFC_CACHEDIR=\"/var/cache/fontconfig\"",
            "-DFC_TEMPLATEDIR=\"/usr/share/fontconfig/conf.avail\"",
            "-DFONTCONFIG_PATH=\"/etc/fonts\"",
            "-DCONFIGDIR=\"/usr/local/fontconfig/conf.d\"",
            "-DFC_DEFAULT_FONTS=\"<dir>/usr/share/fonts</dir><dir>/usr/local/share/fonts</dir>\"",
        });
        if (target.isLinux()) {
            try flags.appendSlice(&.{
                "-DHAVE_SYS_STATFS_H",
                "-DHAVE_SYS_VFS_H",
            });
        }
    }
    if (libxml2_enabled) {
        try flags.appendSlice(&.{
            "-DENABLE_LIBXML2",
            "-DLIBXML_STATIC",
            "-DLIBXML_PUSH_ENABLED",
        });
        if (target.isWindows()) {
            // NOTE: this should be defined on all targets
            try flags.appendSlice(&.{
                "-Werror=implicit-function-declaration",
            });
        }
    }

    for (srcs) |src| {
        lib.addCSourceFile(.{
            .file = upstream.path(src),
            .flags = flags.items,
        });
    }

    lib.installHeadersDirectoryOptions(.{
        .source_dir = upstream.path("fontconfig"),
        .install_dir = .header,
        .install_subdir = "",
        .include_extensions = &.{".h"},
    });

    b.installArtifact(lib);
}

const headers = &.{
    "fontconfig/fontconfig.h",
    "fontconfig/fcprivate.h",
    "fontconfig/fcfreetype.h",
};

const srcs: []const []const u8 = &.{
    "src/fcatomic.c",
    "src/fccache.c",
    "src/fccfg.c",
    "src/fccharset.c",
    "src/fccompat.c",
    "src/fcdbg.c",
    "src/fcdefault.c",
    "src/fcdir.c",
    "src/fcformat.c",
    "src/fcfreetype.c",
    "src/fcfs.c",
    "src/fcptrlist.c",
    "src/fchash.c",
    "src/fcinit.c",
    "src/fclang.c",
    "src/fclist.c",
    "src/fcmatch.c",
    "src/fcmatrix.c",
    "src/fcname.c",
    "src/fcobjs.c",
    "src/fcpat.c",
    "src/fcrange.c",
    "src/fcserialize.c",
    "src/fcstat.c",
    "src/fcstr.c",
    "src/fcweight.c",
    "src/fcxml.c",
    "src/ftglue.c",
};
