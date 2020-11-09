const std = @import("std");
const Builder = @import("std").build.Builder;

pub fn build(b: *Builder) void {
    const mode = b.standardReleaseOptions();

    const lib = b.addStaticLibrary("zeb", "src/main.zig");
    lib.setBuildMode(mode);
    lib.install();
    lib.addPackagePath("hzzp", "hzzp/src/main.zig");

    var main_tests = b.addTest("src/main.zig");
    main_tests.setBuildMode(mode);

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&main_tests.step);

    const target = b.standardTargetOptions(.{});

    const exe = b.addExecutable("example", "example/hello.zig");
    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.install();

    exe.addPackage(.{
        .name = "zeb",
        .path = "src/main.zig",
        .dependencies = &[_]std.build.Pkg{
            .{
                .name = "hzzp",
                .path = "hzzp/src/main.zig",
            },
        },
    });

    exe.addPackagePath("hzzp", "hzzp/src/main.zig");

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
