const std = @import("std");

pub fn length(str: []const u8) !usize {
    var view = std.unicode.Utf8View.init(str) catch {
        return error.InvalidUtf8;
    };

    var iter = view.iterator();
    var count: usize = 0;

    while (iter.nextCodepoint()) |_| {
        count += 1;
    }

    return count;
}

pub fn split(str: []const u8, sep: []const u8, allocator: std.mem.Allocator) ![]const []const u8 {
    if (sep.len == 0) {
        return error.EmptySeparator;
    }

    var iter = std.mem.splitAny(u8, str, sep);
    var res = std.ArrayList([]const u8).init(allocator);

    while (iter.next()) |slice| {
        res.append(slice) catch {
            return error.OutOfMemory;
        };
    }

    return res.toOwnedSlice();
}

pub fn chars(str: []const u8, allocator: std.mem.Allocator) ![]const []const u8 {
    var view = std.unicode.Utf8View.init(str) catch {
        return error.InvalidUtf8;
    };

    var iter = view.iterator();
    var res = std.ArrayList([]const u8).init(allocator);

    while (iter.nextCodepointSlice()) |slice| {
        res.append(slice) catch {
            return error.OutOfMemory;
        };
    }

    return res.toOwnedSlice();
}
