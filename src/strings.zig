const std = @import("std");

pub const StringsError = error{
    InvalidUtf8,
    IndexOutOfBounds,
    EmptySeparator,
    OutOfMemory,
};

pub fn at(str: []const u8, index: usize) StringsError![]const u8 {
    var view = std.unicode.Utf8View.init(str) catch {
        return StringsError.InvalidUtf8;
    };

    var iter = view.iterator();
    var count: usize = 0;

    while (iter.nextCodepointSlice()) |slice| {
        if (count == index) {
            return slice;
        }

        count += 1;
    }

    return StringsError.IndexOutOfBounds;
}

pub fn len(str: []const u8) StringsError!usize {
    var view = std.unicode.Utf8View.init(str) catch {
        return StringsError.InvalidUtf8;
    };

    var iter = view.iterator();
    var count: usize = 0;

    while (iter.nextCodepoint()) |_| {
        count += 1;
    }

    return count;
}

pub fn split(allocator: std.mem.Allocator, str: []const u8, sep: []const u8) StringsError![]const []const u8 {
    if (sep.len == 0) {
        return StringsError.EmptySeparator;
    }

    var iter = std.mem.splitAny(u8, str, sep);
    var res = std.ArrayList([]const u8).init(allocator);

    while (iter.next()) |slice| {
        res.append(slice) catch {
            return StringsError.OutOfMemory;
        };
    }

    return res.toOwnedSlice();
}

pub fn chars(allocator: std.mem.Allocator, str: []const u8) StringsError![]const []const u8 {
    var view = std.unicode.Utf8View.init(str) catch {
        return StringsError.InvalidUtf8;
    };

    var iter = view.iterator();
    var res = std.ArrayList([]const u8).init(allocator);
    defer res.deinit();

    while (iter.nextCodepointSlice()) |slice| {
        res.append(slice) catch {
            return StringsError.OutOfMemory;
        };
    }

    return res.toOwnedSlice();
}


