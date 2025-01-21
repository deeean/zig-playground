const std = @import("std");

pub fn UnboundedChannel(comptime T: type) type {
  return struct {
    const Self = @This();

    allocator: std.mem.Allocator,
    queue: std.ArrayList(T),
    mutex: std.Thread.Mutex,
    cond: std.Thread.Condition,

    pub fn init(allocator: std.mem.Allocator) Self {
      return Self {
        .allocator = allocator,
        .queue = std.ArrayList(T).init(allocator),
        .mutex = std.Thread.Mutex{},
        .cond = std.Thread.Condition{},
      };
    }

    pub fn deinit(self: *Self) void {
      self.queue.deinit();
    }

    pub fn send(self: *Self, value: T) !void {
      self.mutex.lock();
      defer self.mutex.unlock();

      try self.queue.append(value);
      self.cond.signal();
    }

    pub fn recv(self: *Self) !T {
      self.mutex.lock();
      defer self.mutex.unlock();

      while (self.queue.items.len == 0) {
        self.cond.wait(&self.mutex);
      }

      return self.queue.orderedRemove(0);
    }
  };
}
