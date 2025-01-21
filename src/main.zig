const std = @import("std");
const mpsc = @import("mpsc.zig");
const strings = @import("strings.zig");

const MESSAGE: []const u8 = "🚀🚨🔥🎥";

fn sender_fn(channel: *mpsc.UnboundedChannel([]const u8)) !void {
  const size = try strings.len(MESSAGE) - 1;

  while (true) {
    try channel.send(try strings.at(MESSAGE, std.crypto.random.intRangeAtMost(usize, 0, size)));
    std.time.sleep(std.time.ns_per_ms * 100);
  }
}

fn receiver_fn(channel: *mpsc.UnboundedChannel([]const u8)) !void {
  while (true) {
    const value = try channel.recv();
    std.debug.print("Received: {s}\n", .{value});
  }
}

pub fn main() !void {
  var channel = mpsc.UnboundedChannel([]const u8).init(std.heap.page_allocator);
  defer channel.deinit();

  _ = try std.Thread.spawn(.{}, sender_fn, .{&channel});
  _ = try std.Thread.spawn(.{}, receiver_fn, .{&channel});

  while (true) {
    std.debug.print("Main thread running...\n", .{});
    std.time.sleep(std.time.ns_per_s);
  }
}
