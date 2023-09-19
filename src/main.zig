const std = @import("std");
const conf = @import("config.zig");
const grp = @import("groups.zig");
const timeout = @import("timeout.zig");
const auth = @import("auth.zig");
const root = @import("rootize.zig");
const launch = @import("launch.zig");

const c = @cImport({
    @cInclude("unistd.h");
});

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

    var has_group = grp.check_groups(&config);
    var has_user = grp.check_users(&config);

    if (!(has_group or has_user)) {
        std.debug.print("foxdo: not allowed!\n", .{});
        std.os.exit(1);
    }

    const login = std.os.getenv("USER").?;

    const time: i64 = std.time.timestamp();

    const result = !try timeout.check_self(login, time, allocator);

    if (args.len == 2) {
        if (result) {
            std.debug.print("Enter password for [{s}]: ", .{login});
        }

        if (result and auth.check_password(login, std.mem.span(c.getpass("")))) {
            if (c.getuid() != 0) {
                root.rootize();
            }

            if (result) {
                try timeout.register_self(login, time
                    + config.timeout.seconds.i
                    + config.timeout.minutes.i * 60
                    + config.timeout.hours.i * 60 * 60,
                    allocator);
            }

            launch.without_args(args[1]);
        } else {
            if (!result) {
                if (c.geteuid() != 0) {
                    root.rootize();
                }
            } else {
                std.debug.print("Wrong password!\n", .{});
            }
        }

        std.os.exit(0);
    }
}
