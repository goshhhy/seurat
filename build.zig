const Builder = @import("std").build.Builder;

pub fn build(b: *Builder) void {
    const mode = b.standardReleaseOptions();
    const lib = b.addStaticLibrary("seurat", "src/main.zig");
    lib.setBuildMode(mode);

    var main_tests = b.addTest("src/main.zig");
    main_tests.setBuildMode(mode);

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&main_tests.step);

    lib.linkSystemLibrary("c");
    lib.linkSystemLibrary("SDL2");

    b.default_step.dependOn(&lib.step);
    b.installArtifact(lib);
}
