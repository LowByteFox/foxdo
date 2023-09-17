const std = @import("std");
const foxconfig = @import("foxconfig");
const Value = foxconfig.Value;

const Config = struct {
    timeout: struct {
        seconds: Value,
        minutes: Value,
        hours: Value
    },
    allow: struct {
        users: Value,
        groups: Value
    }
};

pub fn main() !void {
    var code =
        \\allow {
        \\    users = ["root" "jani" "lol"]
        \\    groups = ["wheel"]
        \\}
        \\
        \\timeout {
        \\    seconds = 0
        \\    minutes = 5
        \\    hours = 0
        \\}
        ;

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    defer std.debug.assert(gpa.deinit() == .ok);

    var config: Config = undefined;
    var store = try foxconfig.Store.init(allocator);
    defer store.deinit(allocator);

    try store.add("allow.users", &config.allow.users, allocator);
    try store.add("allow.groups", &config.allow.groups, allocator);
    try store.add("timeout.seconds", &config.timeout.seconds, allocator);
    try store.add("timeout.minutes", &config.timeout.minutes, allocator);
    try store.add("timeout.hours", &config.timeout.hours, allocator);

    var parse = foxconfig.Parser.init(code, &store);

    try parse.exec(allocator);

    defer config.allow.users.a_s.deinit();
    defer for (config.allow.users.a_s.items) |item| {
        var nonconst: []u8 = @constCast(item);
        allocator.free(nonconst);
    };
    defer config.allow.groups.a_s.deinit();
    defer for (config.allow.groups.a_s.items) |item| {
        var nonconst: []u8 = @constCast(item);
        allocator.free(nonconst);
    };

    std.debug.print("{any}\n{any}\n", .{config.allow.users.a_s.items, config.allow.groups.a_s.items});
    std.debug.print("{}\n{}\n{}\n", .{config.timeout.seconds, config.timeout.minutes, config.timeout.hours});
}
