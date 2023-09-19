const c = @cImport({
    @cInclude("pwd.h");
    @cInclude("shadow.h");
    @cInclude("crypt.h");
    @cInclude("string.h");
});

pub fn check_password(name: []const u8, password: []const u8) bool {
    var pwd = c.getpwnam(@ptrCast(name));

    if (pwd == null) {
        return false;
    }

    if (c.strcmp(pwd.*.pw_passwd, @ptrCast("x")) != 0) {
        if (c.strcmp(pwd.*.pw_passwd, c.crypt(@ptrCast(password), pwd.*.pw_passwd)) == 0) {
            return true;
        }
        return false;
    }

    var spwd = c.getspnam(@ptrCast(name));
    if (spwd == null) {
        return false;
    }

    if (c.strcmp(spwd.*.sp_pwdp, c.crypt(@ptrCast(password), spwd.*.sp_pwdp)) == 0) {
        return true;
    }
    return false;
}
