const std = @import("std");
const zeb = @import("../main.zig");

pub fn helloHandler(request: zeb.Request) !zeb.Response {
    return zeb.Response.ok().entity("hello world");
}

pub fn main() !void {
    var server = zeb.Server(void).create();
    server.addHandler("/", helloHandler);
    server.run();
}
