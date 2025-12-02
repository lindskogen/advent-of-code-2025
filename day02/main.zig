const std = @import("std");

const inputfile = @embedFile("input");

fn run_part1(untrimmed_input: anytype) !usize {
    const input = std.mem.trimEnd(u8, untrimmed_input, "\n");
    var buf: [15]u8 = undefined;
    var iterator = std.mem.tokenizeScalar(u8, input, ',');
    var sum: usize = 0;

    while (iterator.next()) |range| {
        if (std.mem.indexOfScalar(u8, range, '-')) |dashpos| {
            const from = try std.fmt.parseInt(usize, range[0..dashpos], 10);
            const to = try std.fmt.parseInt(usize, range[dashpos + 1 ..], 10);
            var curr = from;

            while (curr <= to) {
                const max = std.fmt.printInt(&buf, curr, 10, .lower, .{});
                if (max % 2 != 0) {
                    // 101 (len 3) -> 1000 (len 4)
                    curr = try std.math.powi(@TypeOf(curr), 10, max);
                    continue;
                }

                const p = max / 2;
                if (std.mem.eql(u8, buf[0..p], buf[p..max])) {
                    sum += curr;
                }
                curr += 1;
            }
        }
    }

    return sum;
}

fn is_invalid(buf: anytype) bool {
    const max = buf.len;

    if (max == 1) {
        return false;
    }

    if (std.mem.allEqual(u8, buf, buf[0])) {
        return true;
    }

    var len: usize = max / 2;

    o: while (len > 1) : (len -= 1) {
        if (@rem(max, len) != 0) {
            continue;
        }
        var idx: usize = 1;

        while (idx * len + len <= max) : (idx += 1) {
            const p = len * idx;
            if (!std.mem.eql(u8, buf[0..len], buf[p .. p + len])) {
                continue :o;
            }
        }
        return true;
    }
    return false;
}

fn run_part2(untrimmed_input: anytype) !usize {
    const input = std.mem.trimEnd(u8, untrimmed_input, "\n");
    var buf: [15]u8 = undefined;
    var iterator = std.mem.tokenizeScalar(u8, input, ',');
    var sum: usize = 0;

    while (iterator.next()) |range| {
        if (std.mem.indexOfScalar(u8, range, '-')) |dashpos| {
            const from = try std.fmt.parseInt(usize, range[0..dashpos], 10);
            const to = try std.fmt.parseInt(usize, range[dashpos + 1 ..], 10);

            var curr = from;
            while (curr <= to) : (curr += 1) {
                const max = std.fmt.printInt(&buf, curr, 10, .lower, .{});

                if (is_invalid(buf[0..max])) {
                    sum += curr;
                }
            }
        }
    }

    return sum;
}

pub fn main() !void {
    const p1 = try run_part1(inputfile);
    const p2 = try run_part2(inputfile);

    std.debug.print("Part 1: {d}\n", .{p1});
    std.debug.print("Part 2: {d}\n", .{p2});
}

const test_input = "11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124";

test "input1" {
    try std.testing.expectEqual(1227775554, run_part1(test_input));
}

test "input2" {
    try std.testing.expectEqual(4174379265, run_part2(test_input));
}

test "star 1" {
    try std.testing.expectEqual(44854383294, run_part1(inputfile));
}

test "star 2" {
    try std.testing.expectEqual(55647447017, run_part2(inputfile));
}

test "is_invalid" {
    try std.testing.expectEqual(false, is_invalid("1"));
    try std.testing.expectEqual(true, is_invalid("12341234"));
    try std.testing.expectEqual(true, is_invalid("123123123"));
    try std.testing.expectEqual(true, is_invalid("1212121212"));
    try std.testing.expectEqual(true, is_invalid("38593859"));
    try std.testing.expectEqual(true, is_invalid("824824824"));
    try std.testing.expectEqual(true, is_invalid("1111111"));
    try std.testing.expectEqual(false, is_invalid("9999999979"));
    try std.testing.expectEqual(false, is_invalid("799999999"));
}
