load("//jvm:build.bzl", "kt_player_module")
load(":deps.bzl", "main_deps", "main_exports", "main_resources", "test_deps")
load(":build.bzl", "j2v8_platform")

# TODO: Add core as associates and remove InternalPlayerApi?
#       May require creating shared module_name space.
kt_player_module(
    name = "j2v8",
    main_deps = main_deps,
    main_exports = main_exports,
    main_resources = main_resources + glob(["src/main/resources/**"]),
    test_deps = test_deps,
    test_package = "com.intuit.player.jvm.j2v8",
)

j2v8_platform("macos")

j2v8_platform("linux")

j2v8_platform("android")

j2v8_platform("all")
