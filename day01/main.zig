const std = @import("std");

const inputfile = @embedFile("input");

fn run_part1(input: anytype) !u32 {
    var iterator = std.mem.tokenizeScalar(u8, input, '\n');

    var initial: i32 = 50;
    var count: u32 = 0;

    while (iterator.next()) |line| {
        const dir = line[0];
        const steps = try std.fmt.parseInt(i32, line[1..], 10);

        if (dir == 'R') {
            initial += steps;
        } else {
            initial -= steps;
        }

        initial = @mod(initial, 100);

        if (initial == 0) {
            count += 1;
        }
    }

    return count;
}

fn run_part2(input: anytype) !u32 {
    var iterator = std.mem.tokenizeScalar(u8, input, '\n');

    var state: i32 = 50;
    var count: u32 = 0;

    while (iterator.next()) |line| {
        const dir = line[0];
        var c: u32 = 0;
        var x = try std.fmt.parseInt(i32, line[1..], 10);

        if (x > 99) {
            c += @intCast(@divTrunc(x, 100));
            x = @mod(x, 100);
        }

        if (dir == 'L') {
            x = -x;
        }

        const prev = state;
        state += x;

        if (prev != 0 and (state > 100 or state < 0)) {
            c += 1;
        }

        state = @mod(state, 100);

        if (state == 0) {
            c += 1;
        }
        count += c;
    }

    return count;
}

pub fn main() !void {
    const p1 = try run_part1(inputfile);
    const p2 = try run_part2(inputfile);

    std.debug.print("Part 1: {d}\n", .{p1});
    std.debug.print("Part 2: {d}\n", .{p2});
}

test "input1" {
    const test_input_1 =
        \\
        \\L68
        \\L30
        \\R48
        \\L5
        \\R60
        \\L55
        \\L1
        \\L99
        \\R14
        \\L82
    ;
    try std.testing.expectEqual(6, run_part2(test_input_1));
}

test "star 1" {
    try std.testing.expectEqual(1029, run_part1(inputfile));
}

test "star 2" {
    try std.testing.expectEqual(5892, run_part2(inputfile));
}
