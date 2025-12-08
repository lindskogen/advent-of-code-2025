const std = @import("std");

const example_input =
    \\162,817,812
    \\57,618,57
    \\906,360,560
    \\592,479,940
    \\352,342,300
    \\466,668,158
    \\542,29,236
    \\431,825,988
    \\739,650,466
    \\52,470,668
    \\216,146,977
    \\819,987,18
    \\117,168,530
    \\805,96,715
    \\346,949,466
    \\970,615,88
    \\941,993,340
    \\862,61,35
    \\984,92,344
    \\425,690,689
;

const inputfile = @embedFile("input");

const Coord = struct { x: isize, y: isize, z: isize };

fn distance(c1: Coord, c2: Coord) f32 {
    return @sqrt(std.math.pow(f32, @floatFromInt(c1.x - c2.x), 2) + std.math.pow(f32, @floatFromInt(c1.y - c2.y), 2) + std.math.pow(f32, @floatFromInt(c1.z - c2.z), 2));
}

fn run_part1(input: anytype, iters: usize, _: std.mem.Allocator) !usize {
    var boxes_iter = std.mem.tokenizeScalar(u8, input, '\n');

    var boxes: [1000]Coord = undefined;
    var boxes_count: usize = 0;
    var dist_matrix: [1000][1000]f32 = undefined;
    var checked_matrix: [1000][1000]bool = undefined;
    var grouping: [1000]usize = undefined;
    var groupings_count: [1000]usize = undefined;

    while (boxes_iter.next()) |line| {
        var coord_iter = std.mem.tokenizeScalar(u8, line, ',');
        const x = try std.fmt.parseInt(isize, coord_iter.next().?, 10);
        const y = try std.fmt.parseInt(isize, coord_iter.next().?, 10);
        const z = try std.fmt.parseInt(isize, coord_iter.next().?, 10);

        boxes[boxes_count] = .{ .x = x, .y = y, .z = z };
        grouping[boxes_count] = boxes_count;
        groupings_count[boxes_count] = 1;
        boxes_count += 1;
    }

    for (0..boxes_count) |i| {
        for (i + 1..boxes_count) |j| {
            const dist: f32 = blk: {
                break :blk distance(boxes[i], boxes[j]);
            };

            dist_matrix[i][j] = dist;
            dist_matrix[j][i] = dist;
            checked_matrix[i][j] = false;
            checked_matrix[j][i] = false;
        }
    }

    // var context = .{ .dist_matrix = dist_matrix, .boxes = boxes[0..boxes_count], .grouping = grouping };

    for (0..iters) |_| {
        var closest_pair_cand: ?struct { i: usize, j: usize } = null;
        var shortest_distance = std.math.inf(f32);
        for (0..boxes_count) |i| {
            for (i + 1..boxes_count) |j| {
                if (!checked_matrix[i][j]) {
                    if (dist_matrix[i][j] < shortest_distance) {
                        closest_pair_cand = .{ .i = i, .j = j };
                        shortest_distance = dist_matrix[i][j];
                    }
                }
            }
        }

        if (closest_pair_cand) |closest_pair| {
            const i = closest_pair.i;
            const j = closest_pair.j;
            // std.debug.print("closest! {any} {any}\n", .{boxes[i], boxes[j]});
            if (grouping[i] != grouping[j]) {
                const grouping_to_dissolve = grouping[j];
                const grouping_to_merge = grouping[i];

                var count: usize = 0;
                for (0..boxes_count) |g| {
                    if (grouping[g] == grouping_to_dissolve) {
                        grouping[g] = grouping_to_merge;
                        groupings_count[grouping_to_dissolve] -= 1;
                        groupings_count[grouping_to_merge] += 1;
                        count += 1;
                    }
                }
                // std.debug.print("merging {d} from {d} into {d}\n", .{ count, grouping_to_dissolve, grouping_to_merge });

            } else {
                // std.debug.print("closest are same grouping...\n", .{});
            }
            checked_matrix[i][j] = true;
            checked_matrix[j][i] = true;
        }
    }

    var max1: usize = 0;
    var max2: usize = 0;
    var max3: usize = 0;

    for (groupings_count[0..boxes_count]) |value| {
        if (value > max1) {
            max3 = max2;
            max2 = max1;
            max1 = value;
        } else if (value > max2) {
            max3 = max2;
            max2 = value;
        } else if (value > max3) {
            max3 = value;
        }
    }

    return max1 * max2 * max3;
}

fn run_part2(input: anytype, _: std.mem.Allocator) !isize {
    var boxes_iter = std.mem.tokenizeScalar(u8, input, '\n');

    var boxes: [1000]Coord = undefined;
    var boxes_count: usize = 0;
    var dist_matrix: [1000][1000]f32 = undefined;
    var grouping: [1000]usize = undefined;

    while (boxes_iter.next()) |line| {
        var coord_iter = std.mem.tokenizeScalar(u8, line, ',');
        const x = try std.fmt.parseInt(isize, coord_iter.next().?, 10);
        const y = try std.fmt.parseInt(isize, coord_iter.next().?, 10);
        const z = try std.fmt.parseInt(isize, coord_iter.next().?, 10);

        boxes[boxes_count] = .{ .x = x, .y = y, .z = z };
        grouping[boxes_count] = boxes_count;
        boxes_count += 1;
    }

    for (0..boxes_count) |i| {
        for (i + 1..boxes_count) |j| {
            const dist: f32 = blk: {
                break :blk distance(boxes[i], boxes[j]);
            };

            dist_matrix[i][j] = dist;
            dist_matrix[j][i] = dist;
        }
    }

    var closest_pair_cand: ?struct { i: usize, j: usize } = null;
    var shortest_distance = std.math.inf(f32);

    while (!std.mem.allEqual(usize, grouping[0..boxes_count], grouping[0])) {
        closest_pair_cand = null;
        shortest_distance = std.math.inf(f32);
        for (0..boxes_count) |i| {
            for (i + 1..boxes_count) |j| {
                if (grouping[i] != grouping[j]) {
                    if (dist_matrix[i][j] < shortest_distance) {
                        closest_pair_cand = .{ .i = i, .j = j };
                        shortest_distance = dist_matrix[i][j];
                    }
                }
            }
        }

        if (closest_pair_cand) |closest_pair| {
            const i = closest_pair.i;
            const j = closest_pair.j;
            // std.debug.print("closest! {any} {any}\n", .{boxes[i], boxes[j]});
            const grouping_to_dissolve = grouping[j];
            const grouping_to_merge = grouping[i];

            for (0..boxes_count) |g| {
                if (grouping[g] == grouping_to_dissolve) {
                    grouping[g] = grouping_to_merge;
                }
            }
        }
    }

    const last_join = closest_pair_cand orelse return error.InvalidState;

    return boxes[last_join.i].x * boxes[last_join.j].x;
}

pub fn main() !void {
    var arena_allocator = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena_allocator.deinit();
    const alloc = arena_allocator.allocator();
    const p1 = try run_part1(inputfile, 1000, alloc);
    const p2 = try run_part2(inputfile, alloc);

    std.debug.print("Part 1: {d}\n", .{p1});
    std.debug.print("Part 2: {d}\n", .{p2});
}

test "input1" {
    var arena_allocator = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena_allocator.deinit();
    const alloc = arena_allocator.allocator();
    try std.testing.expectEqual(40, run_part1(example_input, 10, alloc));
}

test "input2" {
    var arena_allocator = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena_allocator.deinit();
    const alloc = arena_allocator.allocator();
    try std.testing.expectEqual(25272, run_part2(example_input, alloc));
}

test "star1" {
    var arena_allocator = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena_allocator.deinit();
    const alloc = arena_allocator.allocator();
    try std.testing.expectEqual(163548, run_part1(inputfile, 1000, alloc));
}

test "star2" {
    var arena_allocator = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena_allocator.deinit();
    const alloc = arena_allocator.allocator();
    try std.testing.expectEqual(772452514, run_part2(inputfile, alloc));
}
