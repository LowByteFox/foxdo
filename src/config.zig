const std = @import("std");
const foxconfig = @import("foxconfig");
const Value = foxconfig.Value;

pub const Config = struct {
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

fn copy_over(buff: []u8, start: usize, str: []const u8) void {
    for (0..str.len) |i| {
        buff[i + start] = str[i];
    }
}

pub fn parse_config(allocator: std.mem.Allocator) !?Config {
    var config_file: std.fs.File = std.fs.openFileAbsolute("/etc/foxdo", .{}) catch |e| {
        std.debug.print("/etc/foxdo not found! {}\n", .{e});
        std.os.exit(1);
    };

    var buff: [1024]u8 = undefined;
    var data: ?[]u8 = null;
    var bytes_read: usize = 1;

    while (bytes_read > 0) {
        bytes_read = try config_file.readAll(&buff);
        if (data == null) {
            data = try allocator.alloc(u8, bytes_read);
            @memcpy(data.?, buff[0..bytes_read]);
            continue;
        }

        data = try allocator.realloc(data.?, data.?.len + bytes_read);
        copy_over(data.?, data.?.len - bytes_read, buff[0..bytes_read]);
    }

    if (data != null) {
        var config: Config = undefined;


        var store = try foxconfig.Store.init(allocator);
        defer store.deinit(allocator);

        try store.add("allow.users", &config.allow.users, allocator);
        try store.add("allow.groups", &config.allow.groups, allocator);
        try store.add("timeout.seconds", &config.timeout.seconds, allocator);
        try store.add("timeout.minutes", &config.timeout.minutes, allocator);
        try store.add("timeout.hours", &config.timeout.hours, allocator);

        var parse = foxconfig.Parser.init(data.?, &store);

        try parse.exec(allocator);

        defer allocator.free(data.?);

        return config;
    }

    return undefined;
}

pub fn deinit_config(config: *Config, allocator: std.mem.Allocator) void {
    for (config.allow.groups.a_s.items) |item| {
        var nonconst: []u8 = @constCast(item);
        allocator.free(nonconst);
    }

    config.allow.groups.a_s.deinit();

    for (config.allow.users.a_s.items) |item| {
        var nonconst: []u8 = @constCast(item);
        allocator.free(nonconst);
    }

    config.allow.users.a_s.deinit();
}
