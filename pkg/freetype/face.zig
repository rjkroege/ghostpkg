const std = @import("std");
const c = @import("c.zig");
const errors = @import("errors.zig");
const Library = @import("Library.zig");
const Error = errors.Error;
const intToError = errors.intToError;

pub const Face = struct {
    handle: c.FT_Face,

    pub fn deinit(self: Face) void {
        _ = c.FT_Done_Face(self.handle);
    }

    /// A macro that returns true whenever a face object contains some
    /// embedded bitmaps. See the available_sizes field of the FT_FaceRec structure.
    pub fn hasFixedSizes(self: Face) bool {
        return c.FT_HAS_FIXED_SIZES(self.handle);
    }

    /// A macro that returns true whenever a face object contains tables for
    /// color glyphs.
    pub fn hasColor(self: Face) bool {
        return c.FT_HAS_COLOR(self.handle);
    }

    /// Select a given charmap by its encoding tag (as listed in freetype.h).
    pub fn selectCharmap(self: Face, encoding: Encoding) Error!void {
        return intToError(c.FT_Select_Charmap(self.handle, @enumToInt(encoding)));
    }

    /// Call FT_Request_Size to request the nominal size (in points).
    pub fn setCharSize(
        self: Face,
        char_width: i32,
        char_height: i32,
        horz_resolution: u16,
        vert_resolution: u16,
    ) Error!void {
        return intToError(c.FT_Set_Char_Size(
            self.handle,
            char_width,
            char_height,
            horz_resolution,
            vert_resolution,
        ));
    }

    /// Select a bitmap strike. To be more precise, this function sets the
    /// scaling factors of the active FT_Size object in a face so that bitmaps
    /// from this particular strike are taken by FT_Load_Glyph and friends.
    pub fn selectSize(self: Face, idx: i32) Error!void {
        return intToError(c.FT_Select_Size(self.handle, idx));
    }

    /// Return the glyph index of a given character code. This function uses
    /// the currently selected charmap to do the mapping.
    pub fn getCharIndex(self: Face, char: u32) ?u32 {
        const i = c.FT_Get_Char_Index(self.handle, char);
        return if (i == 0) null else i;
    }

    /// Load a glyph into the glyph slot of a face object.
    pub fn loadGlyph(self: Face, glyph_index: u32, load_flags: LoadFlags) Error!void {
        return intToError(c.FT_Load_Glyph(
            self.handle,
            glyph_index,
            @bitCast(i32, load_flags),
        ));
    }
};

/// An enumeration to specify character sets supported by charmaps. Used in the
/// FT_Select_Charmap API function.
pub const Encoding = enum(u31) {
    none = c.FT_ENCODING_NONE,
    ms_symbol = c.FT_ENCODING_MS_SYMBOL,
    unicode = c.FT_ENCODING_UNICODE,
    sjis = c.FT_ENCODING_SJIS,
    prc = c.FT_ENCODING_PRC,
    big5 = c.FT_ENCODING_BIG5,
    wansung = c.FT_ENCODING_WANSUNG,
    johab = c.FT_ENCODING_JOHAB,
    adobe_standard = c.FT_ENCODING_ADOBE_STANDARD,
    adobe_expert = c.FT_ENCODING_ADOBE_EXPERT,
    adobe_custom = c.FT_ENCODING_ADOBE_CUSTOM,
    adobe_latin_1 = c.FT_ENCODING_ADOBE_LATIN_1,
    old_latin_2 = c.FT_ENCODING_OLD_LATIN_2,
    apple_roman = c.FT_ENCODING_APPLE_ROMAN,
};

/// A list of bit field constants for FT_Load_Glyph to indicate what kind of
/// operations to perform during glyph loading.
pub const LoadFlags = packed struct {
    no_scale: bool = false,
    no_hinting: bool = false,
    render: bool = false,
    no_bitmap: bool = false,
    vertical_layout: bool = false,
    force_autohint: bool = false,
    crop_bitmap: bool = false,
    pedantic: bool = false,
    ignore_global_advance_with: bool = false,
    no_recurse: bool = false,
    ignore_transform: bool = false,
    monochrome: bool = false,
    linear_design: bool = false,
    no_autohint: bool = false,
    target_normal: bool = false,
    target_light: bool = false,
    target_mono: bool = false,
    target_lcd: bool = false,
    target_lcd_v: bool = false,
    color: bool = false,
    compute_metrics: bool = false,
    bitmap_metrics_only: bool = false,
    _padding: u10 = 0,

    test {
        // This must always be an i32 size so we can bitcast directly.
        const testing = std.testing;
        try testing.expectEqual(@sizeOf(i32), @sizeOf(LoadFlags));
    }

    test "bitcast" {
        const testing = std.testing;
        const cval: i32 = c.FT_LOAD_RENDER | c.FT_LOAD_PEDANTIC;
        const flags = @bitCast(LoadFlags, cval);
        try testing.expect(!flags.no_hinting);
        try testing.expect(flags.render);
        try testing.expect(flags.pedantic);
    }
};

test "loading memory font" {
    const testing = std.testing;
    const font_data = @import("test.zig").font_regular;

    var lib = try Library.init();
    defer lib.deinit();
    var face = try lib.initMemoryFace(font_data, 0);
    defer face.deinit();

    // Try APIs
    try face.selectCharmap(.unicode);
    try testing.expect(!face.hasFixedSizes());
    try face.setCharSize(12, 0, 0, 0);

    // Try loading
    const idx = face.getCharIndex('A').?;
    try face.loadGlyph(idx, .{});
}
