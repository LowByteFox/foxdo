const std = @import("std");
const conf = @import("config.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    defer std.debug.assert(gpa.deinit() == .ok);

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len == 1) {
        std.debug.print("foxdo [PROG] [ARGS]\n", .{});
        std.os.exit(1);
    }

    var test_config: ?conf.Config = try conf.parse_config(allocator);
    if (test_config == null) {
        std.debug.print("foxdo: failed to parse config\n", .{});
        std.os.exit(1);
    }
    var config = test_config.?;
    defer conf.deinit_config(&config, allocator);

    std.debug.print("{any}\n{any}\n", .{config.allow.users.a_s.items, config.allow.groups.a_s.items});
    std.debug.print("{}\n{}\n{}\n", .{config.timeout.seconds, config.timeout.minutes, config.timeout.hours});
}
