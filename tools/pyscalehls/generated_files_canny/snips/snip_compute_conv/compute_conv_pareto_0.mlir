func @compute_conv(%arg0: memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>, %arg1: memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>, %arg2: memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>) attributes {func_directive = #hlscpp.fd<pipeline=false, targetInterval=1, dataflow=false, topFunc=true>, llvm.linkage = #llvm.linkage<external>, resource = #hlscpp.r<lut=0, dsp=15, bram=0>, timing = #hlscpp.t<0 -> 8121616, 8121616, 8121616>} {
  affine.for %arg3 = 0 to 240 {
    affine.for %arg4 = 0 to 72 {
      affine.if affine_set<(d0) : (d0 * 8 == 0)>(%arg3) {
        affine.if affine_set<(d0) : (d0 * 15 == 0)>(%arg4) {
          %1800 = affine.load %arg0[%arg3 * 8, %arg4 * 15 - 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<21 -> 23, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
          %1801 = affine.load %arg2[1, 0] {partition_indices = [1, 0], timing = #hlscpp.t<400 -> 402, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1802 = arith.mulf %1800, %1801 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
          %1803 = affine.load %arg0[%arg3 * 8 + 1, %arg4 * 15 - 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<22 -> 24, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
          %1804 = affine.load %arg2[0, 0] {partition_indices = [0, 0], timing = #hlscpp.t<400 -> 402, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1805 = arith.mulf %1803, %1804 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
          %1806 = arith.addf %1802, %1805 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
          %1807 = affine.load %arg2[2, 0] {partition_indices = [2, 0], timing = #hlscpp.t<405 -> 407, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1808 = arith.mulf %1803, %1807 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
          %1809 = arith.addf %1806, %1808 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
          %1810 = affine.load %arg0[%arg3 * 8, %arg4 * 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<23 -> 25, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
          %1811 = affine.load %arg2[1, 1] {partition_indices = [1, 1], timing = #hlscpp.t<410 -> 412, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1812 = arith.mulf %1810, %1811 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
          %1813 = arith.addf %1809, %1812 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
          %1814 = affine.load %arg0[%arg3 * 8 + 1, %arg4 * 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<24 -> 26, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
          %1815 = affine.load %arg2[0, 1] {partition_indices = [0, 1], timing = #hlscpp.t<415 -> 417, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1816 = arith.mulf %1814, %1815 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
          %1817 = arith.addf %1813, %1816 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
          %1818 = affine.load %arg2[2, 1] {partition_indices = [2, 1], timing = #hlscpp.t<420 -> 422, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1819 = arith.mulf %1814, %1818 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
          %1820 = arith.addf %1817, %1819 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
          %1821 = affine.load %arg2[1, 2] {partition_indices = [1, 2], timing = #hlscpp.t<425 -> 427, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1822 = arith.mulf %1800, %1821 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
          %1823 = arith.addf %1820, %1822 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
          %1824 = affine.load %arg2[0, 2] {partition_indices = [0, 2], timing = #hlscpp.t<430 -> 432, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1825 = arith.mulf %1803, %1824 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
          %1826 = arith.addf %1823, %1825 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
          %1827 = affine.load %arg2[2, 2] {partition_indices = [2, 2], timing = #hlscpp.t<435 -> 437, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1828 = arith.mulf %1803, %1827 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
          %1829 = arith.addf %1826, %1828 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
          affine.store %1829, %arg1[%arg3 * 8, %arg4 * 15] {partition_indices = [0, 0], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
        } else {
          %1800 = affine.load %arg0[%arg3 * 8, %arg4 * 15 - 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<15 -> 17, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
          %1801 = affine.load %arg2[1, 0] {partition_indices = [1, 0], timing = #hlscpp.t<399 -> 401, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1802 = arith.mulf %1800, %1801 {timing = #hlscpp.t<436 -> 440, 4, 1>} : f32
          %1803 = affine.load %arg0[%arg3 * 8 + 1, %arg4 * 15 - 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<16 -> 18, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
          %1804 = affine.load %arg2[0, 0] {partition_indices = [0, 0], timing = #hlscpp.t<399 -> 401, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1805 = arith.mulf %1803, %1804 {timing = #hlscpp.t<436 -> 440, 4, 1>} : f32
          %1806 = arith.addf %1802, %1805 {timing = #hlscpp.t<440 -> 445, 5, 1>} : f32
          %1807 = affine.load %arg2[2, 0] {partition_indices = [2, 0], timing = #hlscpp.t<404 -> 406, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1808 = arith.mulf %1803, %1807 {timing = #hlscpp.t<441 -> 445, 4, 1>} : f32
          %1809 = arith.addf %1806, %1808 {timing = #hlscpp.t<445 -> 450, 5, 1>} : f32
          %1810 = affine.load %arg0[%arg3 * 8, %arg4 * 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<17 -> 19, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
          %1811 = affine.load %arg2[1, 1] {partition_indices = [1, 1], timing = #hlscpp.t<409 -> 411, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1812 = arith.mulf %1810, %1811 {timing = #hlscpp.t<446 -> 450, 4, 1>} : f32
          %1813 = arith.addf %1809, %1812 {timing = #hlscpp.t<450 -> 455, 5, 1>} : f32
          %1814 = affine.load %arg0[%arg3 * 8 + 1, %arg4 * 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<18 -> 20, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
          %1815 = affine.load %arg2[0, 1] {partition_indices = [0, 1], timing = #hlscpp.t<414 -> 416, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1816 = arith.mulf %1814, %1815 {timing = #hlscpp.t<451 -> 455, 4, 1>} : f32
          %1817 = arith.addf %1813, %1816 {timing = #hlscpp.t<455 -> 460, 5, 1>} : f32
          %1818 = affine.load %arg2[2, 1] {partition_indices = [2, 1], timing = #hlscpp.t<419 -> 421, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1819 = arith.mulf %1814, %1818 {timing = #hlscpp.t<456 -> 460, 4, 1>} : f32
          %1820 = arith.addf %1817, %1819 {timing = #hlscpp.t<460 -> 465, 5, 1>} : f32
          %1821 = affine.load %arg0[%arg3 * 8, %arg4 * 15 + 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<19 -> 21, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
          %1822 = affine.load %arg2[1, 2] {partition_indices = [1, 2], timing = #hlscpp.t<424 -> 426, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1823 = arith.mulf %1821, %1822 {timing = #hlscpp.t<461 -> 465, 4, 1>} : f32
          %1824 = arith.addf %1820, %1823 {timing = #hlscpp.t<465 -> 470, 5, 1>} : f32
          %1825 = affine.load %arg0[%arg3 * 8 + 1, %arg4 * 15 + 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<20 -> 22, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
          %1826 = affine.load %arg2[0, 2] {partition_indices = [0, 2], timing = #hlscpp.t<429 -> 431, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1827 = arith.mulf %1825, %1826 {timing = #hlscpp.t<466 -> 470, 4, 1>} : f32
          %1828 = arith.addf %1824, %1827 {timing = #hlscpp.t<470 -> 475, 5, 1>} : f32
          %1829 = affine.load %arg2[2, 2] {partition_indices = [2, 2], timing = #hlscpp.t<434 -> 436, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1830 = arith.mulf %1825, %1829 {timing = #hlscpp.t<471 -> 475, 4, 1>} : f32
          %1831 = arith.addf %1828, %1830 {timing = #hlscpp.t<475 -> 480, 5, 1>} : f32
          affine.store %1831, %arg1[%arg3 * 8, %arg4 * 15] {partition_indices = [0, 0], timing = #hlscpp.t<480 -> 481, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
        } {timing = #hlscpp.t<15 -> 482, 467, 0>}
        %1540 = affine.load %arg0[%arg3 * 8, %arg4 * 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<25 -> 27, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1541 = affine.load %arg2[1, 0] {partition_indices = [1, 0], timing = #hlscpp.t<401 -> 403, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1542 = arith.mulf %1540, %1541 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
        %1543 = affine.load %arg0[%arg3 * 8 + 1, %arg4 * 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<26 -> 28, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1544 = affine.load %arg2[0, 0] {partition_indices = [0, 0], timing = #hlscpp.t<401 -> 403, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1545 = arith.mulf %1543, %1544 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
        %1546 = arith.addf %1542, %1545 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
        %1547 = affine.load %arg2[2, 0] {partition_indices = [2, 0], timing = #hlscpp.t<406 -> 408, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1548 = arith.mulf %1543, %1547 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
        %1549 = arith.addf %1546, %1548 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
        %1550 = affine.load %arg0[%arg3 * 8, %arg4 * 15 + 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<27 -> 29, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1551 = affine.load %arg2[1, 1] {partition_indices = [1, 1], timing = #hlscpp.t<411 -> 413, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1552 = arith.mulf %1550, %1551 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
        %1553 = arith.addf %1549, %1552 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
        %1554 = affine.load %arg0[%arg3 * 8 + 1, %arg4 * 15 + 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<28 -> 30, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1555 = affine.load %arg2[0, 1] {partition_indices = [0, 1], timing = #hlscpp.t<416 -> 418, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1556 = arith.mulf %1554, %1555 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
        %1557 = arith.addf %1553, %1556 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
        %1558 = affine.load %arg2[2, 1] {partition_indices = [2, 1], timing = #hlscpp.t<421 -> 423, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1559 = arith.mulf %1554, %1558 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
        %1560 = arith.addf %1557, %1559 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
        %1561 = affine.load %arg0[%arg3 * 8, %arg4 * 15 + 2] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<29 -> 31, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1562 = affine.load %arg2[1, 2] {partition_indices = [1, 2], timing = #hlscpp.t<426 -> 428, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1563 = arith.mulf %1561, %1562 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
        %1564 = arith.addf %1560, %1563 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
        %1565 = affine.load %arg0[%arg3 * 8 + 1, %arg4 * 15 + 2] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<30 -> 32, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1566 = affine.load %arg2[0, 2] {partition_indices = [0, 2], timing = #hlscpp.t<431 -> 433, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1567 = arith.mulf %1565, %1566 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
        %1568 = arith.addf %1564, %1567 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
        %1569 = affine.load %arg2[2, 2] {partition_indices = [2, 2], timing = #hlscpp.t<436 -> 438, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1570 = arith.mulf %1565, %1569 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
        %1571 = arith.addf %1568, %1570 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
        affine.store %1571, %arg1[%arg3 * 8, %arg4 * 15 + 1] {partition_indices = [0, 1], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
        %1572 = arith.mulf %1550, %1541 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
        %1573 = arith.mulf %1554, %1544 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
        %1574 = arith.addf %1572, %1573 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
        %1575 = arith.mulf %1554, %1547 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
        %1576 = arith.addf %1574, %1575 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
        %1577 = arith.mulf %1561, %1551 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
        %1578 = arith.addf %1576, %1577 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
        %1579 = arith.mulf %1565, %1555 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
        %1580 = arith.addf %1578, %1579 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
        %1581 = arith.mulf %1565, %1558 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
        %1582 = arith.addf %1580, %1581 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
        %1583 = affine.load %arg0[%arg3 * 8, %arg4 * 15 + 3] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<31 -> 33, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1584 = arith.mulf %1583, %1562 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
        %1585 = arith.addf %1582, %1584 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
        %1586 = affine.load %arg0[%arg3 * 8 + 1, %arg4 * 15 + 3] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<32 -> 34, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1587 = arith.mulf %1586, %1566 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
        %1588 = arith.addf %1585, %1587 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
        %1589 = arith.mulf %1586, %1569 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
        %1590 = arith.addf %1588, %1589 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
        affine.store %1590, %arg1[%arg3 * 8, %arg4 * 15 + 2] {partition_indices = [0, 2], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
        %1591 = arith.mulf %1561, %1541 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
        %1592 = arith.mulf %1565, %1544 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
        %1593 = arith.addf %1591, %1592 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
        %1594 = arith.mulf %1565, %1547 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
        %1595 = arith.addf %1593, %1594 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
        %1596 = arith.mulf %1583, %1551 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
        %1597 = arith.addf %1595, %1596 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
        %1598 = arith.mulf %1586, %1555 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
        %1599 = arith.addf %1597, %1598 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
        %1600 = arith.mulf %1586, %1558 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
        %1601 = arith.addf %1599, %1600 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
        %1602 = affine.load %arg0[%arg3 * 8, %arg4 * 15 + 4] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<33 -> 35, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1603 = arith.mulf %1602, %1562 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
        %1604 = arith.addf %1601, %1603 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
        %1605 = affine.load %arg0[%arg3 * 8 + 1, %arg4 * 15 + 4] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<34 -> 36, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1606 = arith.mulf %1605, %1566 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
        %1607 = arith.addf %1604, %1606 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
        %1608 = arith.mulf %1605, %1569 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
        %1609 = arith.addf %1607, %1608 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
        affine.store %1609, %arg1[%arg3 * 8, %arg4 * 15 + 3] {partition_indices = [0, 3], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
        %1610 = arith.mulf %1583, %1541 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
        %1611 = arith.mulf %1586, %1544 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
        %1612 = arith.addf %1610, %1611 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
        %1613 = arith.mulf %1586, %1547 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
        %1614 = arith.addf %1612, %1613 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
        %1615 = arith.mulf %1602, %1551 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
        %1616 = arith.addf %1614, %1615 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
        %1617 = arith.mulf %1605, %1555 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
        %1618 = arith.addf %1616, %1617 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
        %1619 = arith.mulf %1605, %1558 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
        %1620 = arith.addf %1618, %1619 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
        %1621 = affine.load %arg0[%arg3 * 8, %arg4 * 15 + 5] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<35 -> 37, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1622 = arith.mulf %1621, %1562 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
        %1623 = arith.addf %1620, %1622 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
        %1624 = affine.load %arg0[%arg3 * 8 + 1, %arg4 * 15 + 5] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<36 -> 38, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1625 = arith.mulf %1624, %1566 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
        %1626 = arith.addf %1623, %1625 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
        %1627 = arith.mulf %1624, %1569 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
        %1628 = arith.addf %1626, %1627 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
        affine.store %1628, %arg1[%arg3 * 8, %arg4 * 15 + 4] {partition_indices = [0, 4], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
        %1629 = arith.mulf %1602, %1541 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
        %1630 = arith.mulf %1605, %1544 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
        %1631 = arith.addf %1629, %1630 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
        %1632 = arith.mulf %1605, %1547 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
        %1633 = arith.addf %1631, %1632 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
        %1634 = arith.mulf %1621, %1551 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
        %1635 = arith.addf %1633, %1634 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
        %1636 = arith.mulf %1624, %1555 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
        %1637 = arith.addf %1635, %1636 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
        %1638 = arith.mulf %1624, %1558 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
        %1639 = arith.addf %1637, %1638 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
        %1640 = affine.load %arg0[%arg3 * 8, %arg4 * 15 + 6] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<37 -> 39, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1641 = arith.mulf %1640, %1562 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
        %1642 = arith.addf %1639, %1641 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
        %1643 = affine.load %arg0[%arg3 * 8 + 1, %arg4 * 15 + 6] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<38 -> 40, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1644 = arith.mulf %1643, %1566 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
        %1645 = arith.addf %1642, %1644 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
        %1646 = arith.mulf %1643, %1569 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
        %1647 = arith.addf %1645, %1646 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
        affine.store %1647, %arg1[%arg3 * 8, %arg4 * 15 + 5] {partition_indices = [0, 5], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
        %1648 = arith.mulf %1621, %1541 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
        %1649 = arith.mulf %1624, %1544 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
        %1650 = arith.addf %1648, %1649 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
        %1651 = arith.mulf %1624, %1547 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
        %1652 = arith.addf %1650, %1651 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
        %1653 = arith.mulf %1640, %1551 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
        %1654 = arith.addf %1652, %1653 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
        %1655 = arith.mulf %1643, %1555 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
        %1656 = arith.addf %1654, %1655 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
        %1657 = arith.mulf %1643, %1558 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
        %1658 = arith.addf %1656, %1657 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
        %1659 = affine.load %arg0[%arg3 * 8, %arg4 * 15 + 7] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<39 -> 41, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1660 = arith.mulf %1659, %1562 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
        %1661 = arith.addf %1658, %1660 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
        %1662 = affine.load %arg0[%arg3 * 8 + 1, %arg4 * 15 + 7] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<40 -> 42, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1663 = arith.mulf %1662, %1566 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
        %1664 = arith.addf %1661, %1663 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
        %1665 = arith.mulf %1662, %1569 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
        %1666 = arith.addf %1664, %1665 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
        affine.store %1666, %arg1[%arg3 * 8, %arg4 * 15 + 6] {partition_indices = [0, 6], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
        %1667 = arith.mulf %1640, %1541 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
        %1668 = arith.mulf %1643, %1544 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
        %1669 = arith.addf %1667, %1668 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
        %1670 = arith.mulf %1643, %1547 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
        %1671 = arith.addf %1669, %1670 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
        %1672 = arith.mulf %1659, %1551 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
        %1673 = arith.addf %1671, %1672 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
        %1674 = arith.mulf %1662, %1555 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
        %1675 = arith.addf %1673, %1674 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
        %1676 = arith.mulf %1662, %1558 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
        %1677 = arith.addf %1675, %1676 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
        %1678 = affine.load %arg0[%arg3 * 8, %arg4 * 15 + 8] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<41 -> 43, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1679 = arith.mulf %1678, %1562 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
        %1680 = arith.addf %1677, %1679 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
        %1681 = affine.load %arg0[%arg3 * 8 + 1, %arg4 * 15 + 8] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<42 -> 44, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1682 = arith.mulf %1681, %1566 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
        %1683 = arith.addf %1680, %1682 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
        %1684 = arith.mulf %1681, %1569 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
        %1685 = arith.addf %1683, %1684 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
        affine.store %1685, %arg1[%arg3 * 8, %arg4 * 15 + 7] {partition_indices = [0, 7], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
        %1686 = arith.mulf %1659, %1541 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
        %1687 = arith.mulf %1662, %1544 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
        %1688 = arith.addf %1686, %1687 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
        %1689 = arith.mulf %1662, %1547 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
        %1690 = arith.addf %1688, %1689 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
        %1691 = arith.mulf %1678, %1551 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
        %1692 = arith.addf %1690, %1691 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
        %1693 = arith.mulf %1681, %1555 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
        %1694 = arith.addf %1692, %1693 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
        %1695 = arith.mulf %1681, %1558 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
        %1696 = arith.addf %1694, %1695 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
        %1697 = affine.load %arg0[%arg3 * 8, %arg4 * 15 + 9] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<43 -> 45, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1698 = arith.mulf %1697, %1562 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
        %1699 = arith.addf %1696, %1698 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
        %1700 = affine.load %arg0[%arg3 * 8 + 1, %arg4 * 15 + 9] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<44 -> 46, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1701 = arith.mulf %1700, %1566 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
        %1702 = arith.addf %1699, %1701 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
        %1703 = arith.mulf %1700, %1569 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
        %1704 = arith.addf %1702, %1703 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
        affine.store %1704, %arg1[%arg3 * 8, %arg4 * 15 + 8] {partition_indices = [0, 8], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
        %1705 = arith.mulf %1678, %1541 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
        %1706 = arith.mulf %1681, %1544 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
        %1707 = arith.addf %1705, %1706 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
        %1708 = arith.mulf %1681, %1547 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
        %1709 = arith.addf %1707, %1708 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
        %1710 = arith.mulf %1697, %1551 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
        %1711 = arith.addf %1709, %1710 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
        %1712 = arith.mulf %1700, %1555 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
        %1713 = arith.addf %1711, %1712 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
        %1714 = arith.mulf %1700, %1558 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
        %1715 = arith.addf %1713, %1714 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
        %1716 = affine.load %arg0[%arg3 * 8, %arg4 * 15 + 10] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<45 -> 47, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1717 = arith.mulf %1716, %1562 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
        %1718 = arith.addf %1715, %1717 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
        %1719 = affine.load %arg0[%arg3 * 8 + 1, %arg4 * 15 + 10] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<46 -> 48, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1720 = arith.mulf %1719, %1566 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
        %1721 = arith.addf %1718, %1720 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
        %1722 = arith.mulf %1719, %1569 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
        %1723 = arith.addf %1721, %1722 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
        affine.store %1723, %arg1[%arg3 * 8, %arg4 * 15 + 9] {partition_indices = [0, 9], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
        %1724 = arith.mulf %1697, %1541 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
        %1725 = arith.mulf %1700, %1544 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
        %1726 = arith.addf %1724, %1725 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
        %1727 = arith.mulf %1700, %1547 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
        %1728 = arith.addf %1726, %1727 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
        %1729 = arith.mulf %1716, %1551 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
        %1730 = arith.addf %1728, %1729 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
        %1731 = arith.mulf %1719, %1555 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
        %1732 = arith.addf %1730, %1731 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
        %1733 = arith.mulf %1719, %1558 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
        %1734 = arith.addf %1732, %1733 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
        %1735 = affine.load %arg0[%arg3 * 8, %arg4 * 15 + 11] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<47 -> 49, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1736 = arith.mulf %1735, %1562 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
        %1737 = arith.addf %1734, %1736 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
        %1738 = affine.load %arg0[%arg3 * 8 + 1, %arg4 * 15 + 11] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<48 -> 50, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1739 = arith.mulf %1738, %1566 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
        %1740 = arith.addf %1737, %1739 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
        %1741 = arith.mulf %1738, %1569 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
        %1742 = arith.addf %1740, %1741 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
        affine.store %1742, %arg1[%arg3 * 8, %arg4 * 15 + 10] {partition_indices = [0, 10], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
        %1743 = arith.mulf %1716, %1541 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
        %1744 = arith.mulf %1719, %1544 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
        %1745 = arith.addf %1743, %1744 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
        %1746 = arith.mulf %1719, %1547 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
        %1747 = arith.addf %1745, %1746 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
        %1748 = arith.mulf %1735, %1551 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
        %1749 = arith.addf %1747, %1748 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
        %1750 = arith.mulf %1738, %1555 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
        %1751 = arith.addf %1749, %1750 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
        %1752 = arith.mulf %1738, %1558 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
        %1753 = arith.addf %1751, %1752 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
        %1754 = affine.load %arg0[%arg3 * 8, %arg4 * 15 + 12] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<49 -> 51, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1755 = arith.mulf %1754, %1562 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
        %1756 = arith.addf %1753, %1755 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
        %1757 = affine.load %arg0[%arg3 * 8 + 1, %arg4 * 15 + 12] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<50 -> 52, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1758 = arith.mulf %1757, %1566 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
        %1759 = arith.addf %1756, %1758 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
        %1760 = arith.mulf %1757, %1569 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
        %1761 = arith.addf %1759, %1760 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
        affine.store %1761, %arg1[%arg3 * 8, %arg4 * 15 + 11] {partition_indices = [0, 11], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
        %1762 = arith.mulf %1735, %1541 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
        %1763 = arith.mulf %1738, %1544 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
        %1764 = arith.addf %1762, %1763 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
        %1765 = arith.mulf %1738, %1547 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
        %1766 = arith.addf %1764, %1765 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
        %1767 = arith.mulf %1754, %1551 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
        %1768 = arith.addf %1766, %1767 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
        %1769 = arith.mulf %1757, %1555 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
        %1770 = arith.addf %1768, %1769 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
        %1771 = arith.mulf %1757, %1558 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
        %1772 = arith.addf %1770, %1771 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
        %1773 = affine.load %arg0[%arg3 * 8, %arg4 * 15 + 13] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<51 -> 53, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1774 = arith.mulf %1773, %1562 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
        %1775 = arith.addf %1772, %1774 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
        %1776 = affine.load %arg0[%arg3 * 8 + 1, %arg4 * 15 + 13] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<52 -> 54, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1777 = arith.mulf %1776, %1566 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
        %1778 = arith.addf %1775, %1777 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
        %1779 = arith.mulf %1776, %1569 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
        %1780 = arith.addf %1778, %1779 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
        affine.store %1780, %arg1[%arg3 * 8, %arg4 * 15 + 12] {partition_indices = [0, 12], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
        %1781 = arith.mulf %1754, %1541 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
        %1782 = arith.mulf %1757, %1544 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
        %1783 = arith.addf %1781, %1782 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
        %1784 = arith.mulf %1757, %1547 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
        %1785 = arith.addf %1783, %1784 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
        %1786 = arith.mulf %1773, %1551 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
        %1787 = arith.addf %1785, %1786 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
        %1788 = arith.mulf %1776, %1555 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
        %1789 = arith.addf %1787, %1788 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
        %1790 = arith.mulf %1776, %1558 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
        %1791 = arith.addf %1789, %1790 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
        %1792 = affine.load %arg0[%arg3 * 8, %arg4 * 15 + 14] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<53 -> 55, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1793 = arith.mulf %1792, %1562 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
        %1794 = arith.addf %1791, %1793 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
        %1795 = affine.load %arg0[%arg3 * 8 + 1, %arg4 * 15 + 14] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<54 -> 56, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1796 = arith.mulf %1795, %1566 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
        %1797 = arith.addf %1794, %1796 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
        %1798 = arith.mulf %1795, %1569 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
        %1799 = arith.addf %1797, %1798 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
        affine.store %1799, %arg1[%arg3 * 8, %arg4 * 15 + 13] {partition_indices = [0, 13], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
        affine.if affine_set<(d0) : (d0 * 15 - 1065 == 0)>(%arg4) {
          %1800 = affine.load %arg0[%arg3 * 8, %arg4 * 15 + 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<61 -> 63, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
          %1801 = affine.load %arg2[1, 0] {partition_indices = [1, 0], timing = #hlscpp.t<403 -> 405, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1802 = arith.mulf %1800, %1801 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
          %1803 = affine.load %arg0[%arg3 * 8 + 1, %arg4 * 15 + 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<62 -> 64, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
          %1804 = affine.load %arg2[0, 0] {partition_indices = [0, 0], timing = #hlscpp.t<403 -> 405, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1805 = arith.mulf %1803, %1804 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
          %1806 = arith.addf %1802, %1805 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
          %1807 = affine.load %arg2[2, 0] {partition_indices = [2, 0], timing = #hlscpp.t<408 -> 410, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1808 = arith.mulf %1803, %1807 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
          %1809 = arith.addf %1806, %1808 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
          %1810 = affine.load %arg0[%arg3 * 8, %arg4 * 15 + 14] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<63 -> 65, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
          %1811 = affine.load %arg2[1, 1] {partition_indices = [1, 1], timing = #hlscpp.t<413 -> 415, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1812 = arith.mulf %1810, %1811 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
          %1813 = arith.addf %1809, %1812 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
          %1814 = affine.load %arg0[%arg3 * 8 + 1, %arg4 * 15 + 14] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<64 -> 66, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
          %1815 = affine.load %arg2[0, 1] {partition_indices = [0, 1], timing = #hlscpp.t<418 -> 420, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1816 = arith.mulf %1814, %1815 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
          %1817 = arith.addf %1813, %1816 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
          %1818 = affine.load %arg2[2, 1] {partition_indices = [2, 1], timing = #hlscpp.t<423 -> 425, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1819 = arith.mulf %1814, %1818 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
          %1820 = arith.addf %1817, %1819 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
          %1821 = affine.load %arg2[1, 2] {partition_indices = [1, 2], timing = #hlscpp.t<428 -> 430, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1822 = arith.mulf %1800, %1821 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
          %1823 = arith.addf %1820, %1822 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
          %1824 = affine.load %arg2[0, 2] {partition_indices = [0, 2], timing = #hlscpp.t<433 -> 435, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1825 = arith.mulf %1803, %1824 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
          %1826 = arith.addf %1823, %1825 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
          %1827 = affine.load %arg2[2, 2] {partition_indices = [2, 2], timing = #hlscpp.t<438 -> 440, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1828 = arith.mulf %1803, %1827 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
          %1829 = arith.addf %1826, %1828 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
          affine.store %1829, %arg1[%arg3 * 8, %arg4 * 15 + 14] {partition_indices = [0, 14], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
        } else {
          %1800 = affine.load %arg0[%arg3 * 8, %arg4 * 15 + 13] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<55 -> 57, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
          %1801 = affine.load %arg2[1, 0] {partition_indices = [1, 0], timing = #hlscpp.t<402 -> 404, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1802 = arith.mulf %1800, %1801 {timing = #hlscpp.t<436 -> 440, 4, 1>} : f32
          %1803 = affine.load %arg0[%arg3 * 8 + 1, %arg4 * 15 + 13] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<56 -> 58, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
          %1804 = affine.load %arg2[0, 0] {partition_indices = [0, 0], timing = #hlscpp.t<402 -> 404, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1805 = arith.mulf %1803, %1804 {timing = #hlscpp.t<436 -> 440, 4, 1>} : f32
          %1806 = arith.addf %1802, %1805 {timing = #hlscpp.t<440 -> 445, 5, 1>} : f32
          %1807 = affine.load %arg2[2, 0] {partition_indices = [2, 0], timing = #hlscpp.t<407 -> 409, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1808 = arith.mulf %1803, %1807 {timing = #hlscpp.t<441 -> 445, 4, 1>} : f32
          %1809 = arith.addf %1806, %1808 {timing = #hlscpp.t<445 -> 450, 5, 1>} : f32
          %1810 = affine.load %arg0[%arg3 * 8, %arg4 * 15 + 14] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<57 -> 59, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
          %1811 = affine.load %arg2[1, 1] {partition_indices = [1, 1], timing = #hlscpp.t<412 -> 414, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1812 = arith.mulf %1810, %1811 {timing = #hlscpp.t<446 -> 450, 4, 1>} : f32
          %1813 = arith.addf %1809, %1812 {timing = #hlscpp.t<450 -> 455, 5, 1>} : f32
          %1814 = affine.load %arg0[%arg3 * 8 + 1, %arg4 * 15 + 14] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<58 -> 60, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
          %1815 = affine.load %arg2[0, 1] {partition_indices = [0, 1], timing = #hlscpp.t<417 -> 419, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1816 = arith.mulf %1814, %1815 {timing = #hlscpp.t<451 -> 455, 4, 1>} : f32
          %1817 = arith.addf %1813, %1816 {timing = #hlscpp.t<455 -> 460, 5, 1>} : f32
          %1818 = affine.load %arg2[2, 1] {partition_indices = [2, 1], timing = #hlscpp.t<422 -> 424, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1819 = arith.mulf %1814, %1818 {timing = #hlscpp.t<456 -> 460, 4, 1>} : f32
          %1820 = arith.addf %1817, %1819 {timing = #hlscpp.t<460 -> 465, 5, 1>} : f32
          %1821 = affine.load %arg0[%arg3 * 8, %arg4 * 15 + 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<59 -> 61, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
          %1822 = affine.load %arg2[1, 2] {partition_indices = [1, 2], timing = #hlscpp.t<427 -> 429, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1823 = arith.mulf %1821, %1822 {timing = #hlscpp.t<461 -> 465, 4, 1>} : f32
          %1824 = arith.addf %1820, %1823 {timing = #hlscpp.t<465 -> 470, 5, 1>} : f32
          %1825 = affine.load %arg0[%arg3 * 8 + 1, %arg4 * 15 + 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<60 -> 62, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
          %1826 = affine.load %arg2[0, 2] {partition_indices = [0, 2], timing = #hlscpp.t<432 -> 434, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1827 = arith.mulf %1825, %1826 {timing = #hlscpp.t<466 -> 470, 4, 1>} : f32
          %1828 = arith.addf %1824, %1827 {timing = #hlscpp.t<470 -> 475, 5, 1>} : f32
          %1829 = affine.load %arg2[2, 2] {partition_indices = [2, 2], timing = #hlscpp.t<437 -> 439, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1830 = arith.mulf %1825, %1829 {timing = #hlscpp.t<471 -> 475, 4, 1>} : f32
          %1831 = arith.addf %1828, %1830 {timing = #hlscpp.t<475 -> 480, 5, 1>} : f32
          affine.store %1831, %arg1[%arg3 * 8, %arg4 * 15 + 14] {partition_indices = [0, 14], timing = #hlscpp.t<480 -> 481, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
        } {timing = #hlscpp.t<55 -> 482, 427, 0>}
      } else {
        affine.if affine_set<(d0) : (d0 * 15 - 1065 == 0)>(%arg4) {
          %1540 = affine.load %arg0[%arg3 * 8, %arg4 * 15 + 13] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<9 -> 11, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
          %1541 = affine.load %arg2[1, 0] {partition_indices = [1, 0], timing = #hlscpp.t<398 -> 400, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1542 = arith.mulf %1540, %1541 {timing = #hlscpp.t<435 -> 439, 4, 1>} : f32
          %1543 = affine.load %arg0[%arg3 * 8 - 1, %arg4 * 15 + 13] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
          %1544 = affine.load %arg2[0, 0] {partition_indices = [0, 0], timing = #hlscpp.t<398 -> 400, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1545 = arith.mulf %1543, %1544 {timing = #hlscpp.t<435 -> 439, 4, 1>} : f32
          %1546 = arith.addf %1542, %1545 {timing = #hlscpp.t<439 -> 444, 5, 1>} : f32
          %1547 = affine.load %arg0[%arg3 * 8 + 1, %arg4 * 15 + 13] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<11 -> 13, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
          %1548 = affine.load %arg2[2, 0] {partition_indices = [2, 0], timing = #hlscpp.t<403 -> 405, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1549 = arith.mulf %1547, %1548 {timing = #hlscpp.t<440 -> 444, 4, 1>} : f32
          %1550 = arith.addf %1546, %1549 {timing = #hlscpp.t<444 -> 449, 5, 1>} : f32
          %1551 = affine.load %arg0[%arg3 * 8, %arg4 * 15 + 14] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<12 -> 14, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
          %1552 = affine.load %arg2[1, 1] {partition_indices = [1, 1], timing = #hlscpp.t<408 -> 410, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1553 = arith.mulf %1551, %1552 {timing = #hlscpp.t<445 -> 449, 4, 1>} : f32
          %1554 = arith.addf %1550, %1553 {timing = #hlscpp.t<449 -> 454, 5, 1>} : f32
          %1555 = affine.load %arg0[%arg3 * 8 - 1, %arg4 * 15 + 14] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<13 -> 15, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
          %1556 = affine.load %arg2[0, 1] {partition_indices = [0, 1], timing = #hlscpp.t<413 -> 415, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1557 = arith.mulf %1555, %1556 {timing = #hlscpp.t<450 -> 454, 4, 1>} : f32
          %1558 = arith.addf %1554, %1557 {timing = #hlscpp.t<454 -> 459, 5, 1>} : f32
          %1559 = affine.load %arg0[%arg3 * 8 + 1, %arg4 * 15 + 14] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<14 -> 16, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
          %1560 = affine.load %arg2[2, 1] {partition_indices = [2, 1], timing = #hlscpp.t<418 -> 420, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1561 = arith.mulf %1559, %1560 {timing = #hlscpp.t<455 -> 459, 4, 1>} : f32
          %1562 = arith.addf %1558, %1561 {timing = #hlscpp.t<459 -> 464, 5, 1>} : f32
          %1563 = affine.load %arg2[1, 2] {partition_indices = [1, 2], timing = #hlscpp.t<423 -> 425, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1564 = arith.mulf %1540, %1563 {timing = #hlscpp.t<460 -> 464, 4, 1>} : f32
          %1565 = arith.addf %1562, %1564 {timing = #hlscpp.t<464 -> 469, 5, 1>} : f32
          %1566 = affine.load %arg2[0, 2] {partition_indices = [0, 2], timing = #hlscpp.t<428 -> 430, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1567 = arith.mulf %1543, %1566 {timing = #hlscpp.t<465 -> 469, 4, 1>} : f32
          %1568 = arith.addf %1565, %1567 {timing = #hlscpp.t<469 -> 474, 5, 1>} : f32
          %1569 = affine.load %arg2[2, 2] {partition_indices = [2, 2], timing = #hlscpp.t<433 -> 435, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1570 = arith.mulf %1547, %1569 {timing = #hlscpp.t<470 -> 474, 4, 1>} : f32
          %1571 = arith.addf %1568, %1570 {timing = #hlscpp.t<474 -> 479, 5, 1>} : f32
          affine.store %1571, %arg1[%arg3 * 8, %arg4 * 15 + 14] {partition_indices = [0, 14], timing = #hlscpp.t<479 -> 480, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
        } else {
          %1540 = affine.load %arg0[%arg3 * 8, %arg4 * 15 + 13] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
          %1541 = affine.load %arg2[1, 0] {partition_indices = [1, 0], timing = #hlscpp.t<397 -> 399, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1542 = arith.mulf %1540, %1541 {timing = #hlscpp.t<434 -> 438, 4, 1>} : f32
          %1543 = affine.load %arg0[%arg3 * 8 - 1, %arg4 * 15 + 13] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<1 -> 3, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
          %1544 = affine.load %arg2[0, 0] {partition_indices = [0, 0], timing = #hlscpp.t<397 -> 399, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1545 = arith.mulf %1543, %1544 {timing = #hlscpp.t<434 -> 438, 4, 1>} : f32
          %1546 = arith.addf %1542, %1545 {timing = #hlscpp.t<438 -> 443, 5, 1>} : f32
          %1547 = affine.load %arg0[%arg3 * 8 + 1, %arg4 * 15 + 13] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<2 -> 4, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
          %1548 = affine.load %arg2[2, 0] {partition_indices = [2, 0], timing = #hlscpp.t<402 -> 404, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1549 = arith.mulf %1547, %1548 {timing = #hlscpp.t<439 -> 443, 4, 1>} : f32
          %1550 = arith.addf %1546, %1549 {timing = #hlscpp.t<443 -> 448, 5, 1>} : f32
          %1551 = affine.load %arg0[%arg3 * 8, %arg4 * 15 + 14] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<3 -> 5, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
          %1552 = affine.load %arg2[1, 1] {partition_indices = [1, 1], timing = #hlscpp.t<407 -> 409, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1553 = arith.mulf %1551, %1552 {timing = #hlscpp.t<444 -> 448, 4, 1>} : f32
          %1554 = arith.addf %1550, %1553 {timing = #hlscpp.t<448 -> 453, 5, 1>} : f32
          %1555 = affine.load %arg0[%arg3 * 8 - 1, %arg4 * 15 + 14] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
          %1556 = affine.load %arg2[0, 1] {partition_indices = [0, 1], timing = #hlscpp.t<412 -> 414, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1557 = arith.mulf %1555, %1556 {timing = #hlscpp.t<449 -> 453, 4, 1>} : f32
          %1558 = arith.addf %1554, %1557 {timing = #hlscpp.t<453 -> 458, 5, 1>} : f32
          %1559 = affine.load %arg0[%arg3 * 8 + 1, %arg4 * 15 + 14] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
          %1560 = affine.load %arg2[2, 1] {partition_indices = [2, 1], timing = #hlscpp.t<417 -> 419, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1561 = arith.mulf %1559, %1560 {timing = #hlscpp.t<454 -> 458, 4, 1>} : f32
          %1562 = arith.addf %1558, %1561 {timing = #hlscpp.t<458 -> 463, 5, 1>} : f32
          %1563 = affine.load %arg0[%arg3 * 8, %arg4 * 15 + 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<6 -> 8, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
          %1564 = affine.load %arg2[1, 2] {partition_indices = [1, 2], timing = #hlscpp.t<422 -> 424, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1565 = arith.mulf %1563, %1564 {timing = #hlscpp.t<459 -> 463, 4, 1>} : f32
          %1566 = arith.addf %1562, %1565 {timing = #hlscpp.t<463 -> 468, 5, 1>} : f32
          %1567 = affine.load %arg0[%arg3 * 8 - 1, %arg4 * 15 + 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<7 -> 9, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
          %1568 = affine.load %arg2[0, 2] {partition_indices = [0, 2], timing = #hlscpp.t<427 -> 429, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1569 = arith.mulf %1567, %1568 {timing = #hlscpp.t<464 -> 468, 4, 1>} : f32
          %1570 = arith.addf %1566, %1569 {timing = #hlscpp.t<468 -> 473, 5, 1>} : f32
          %1571 = affine.load %arg0[%arg3 * 8 + 1, %arg4 * 15 + 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<8 -> 10, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
          %1572 = affine.load %arg2[2, 2] {partition_indices = [2, 2], timing = #hlscpp.t<432 -> 434, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1573 = arith.mulf %1571, %1572 {timing = #hlscpp.t<469 -> 473, 4, 1>} : f32
          %1574 = arith.addf %1570, %1573 {timing = #hlscpp.t<473 -> 478, 5, 1>} : f32
          affine.store %1574, %arg1[%arg3 * 8, %arg4 * 15 + 14] {partition_indices = [0, 14], timing = #hlscpp.t<478 -> 479, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
        } {timing = #hlscpp.t<0 -> 482, 482, 0>}
      } {timing = #hlscpp.t<0 -> 482, 482, 0>}
      affine.if affine_set<(d0) : (d0 * 15 == 0)>(%arg4) {
        %1540 = affine.load %arg0[%arg3 * 8 + 1, %arg4 * 15 + 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<74 -> 76, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1541 = affine.load %arg2[1, 0] {partition_indices = [1, 0], timing = #hlscpp.t<405 -> 407, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1542 = arith.mulf %1540, %1541 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
        %1543 = affine.load %arg0[%arg3 * 8, %arg4 * 15 + 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<75 -> 77, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1544 = affine.load %arg2[0, 0] {partition_indices = [0, 0], timing = #hlscpp.t<405 -> 407, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1545 = arith.mulf %1543, %1544 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
        %1546 = arith.addf %1542, %1545 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
        %1547 = affine.load %arg0[%arg3 * 8 + 2, %arg4 * 15 + 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<76 -> 78, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1548 = affine.load %arg2[2, 0] {partition_indices = [2, 0], timing = #hlscpp.t<410 -> 412, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1549 = arith.mulf %1547, %1548 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
        %1550 = arith.addf %1546, %1549 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
        %1551 = affine.load %arg0[%arg3 * 8 + 1, %arg4 * 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<77 -> 79, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1552 = affine.load %arg2[1, 1] {partition_indices = [1, 1], timing = #hlscpp.t<415 -> 417, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1553 = arith.mulf %1551, %1552 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
        %1554 = arith.addf %1550, %1553 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
        %1555 = affine.load %arg0[%arg3 * 8, %arg4 * 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<78 -> 80, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1556 = affine.load %arg2[0, 1] {partition_indices = [0, 1], timing = #hlscpp.t<420 -> 422, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1557 = arith.mulf %1555, %1556 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
        %1558 = arith.addf %1554, %1557 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
        %1559 = affine.load %arg0[%arg3 * 8 + 2, %arg4 * 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<79 -> 81, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1560 = affine.load %arg2[2, 1] {partition_indices = [2, 1], timing = #hlscpp.t<425 -> 427, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1561 = arith.mulf %1559, %1560 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
        %1562 = arith.addf %1558, %1561 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
        %1563 = affine.load %arg2[1, 2] {partition_indices = [1, 2], timing = #hlscpp.t<430 -> 432, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1564 = arith.mulf %1540, %1563 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
        %1565 = arith.addf %1562, %1564 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
        %1566 = affine.load %arg2[0, 2] {partition_indices = [0, 2], timing = #hlscpp.t<435 -> 437, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1567 = arith.mulf %1543, %1566 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
        %1568 = arith.addf %1565, %1567 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
        %1569 = affine.load %arg2[2, 2] {partition_indices = [2, 2], timing = #hlscpp.t<440 -> 442, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1570 = arith.mulf %1547, %1569 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
        %1571 = arith.addf %1568, %1570 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
        affine.store %1571, %arg1[%arg3 * 8 + 1, %arg4 * 15] {partition_indices = [1, 0], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      } else {
        %1540 = affine.load %arg0[%arg3 * 8 + 1, %arg4 * 15 - 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<65 -> 67, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1541 = affine.load %arg2[1, 0] {partition_indices = [1, 0], timing = #hlscpp.t<404 -> 406, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1542 = arith.mulf %1540, %1541 {timing = #hlscpp.t<436 -> 440, 4, 1>} : f32
        %1543 = affine.load %arg0[%arg3 * 8, %arg4 * 15 - 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<66 -> 68, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1544 = affine.load %arg2[0, 0] {partition_indices = [0, 0], timing = #hlscpp.t<404 -> 406, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1545 = arith.mulf %1543, %1544 {timing = #hlscpp.t<436 -> 440, 4, 1>} : f32
        %1546 = arith.addf %1542, %1545 {timing = #hlscpp.t<440 -> 445, 5, 1>} : f32
        %1547 = affine.load %arg0[%arg3 * 8 + 2, %arg4 * 15 - 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<67 -> 69, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1548 = affine.load %arg2[2, 0] {partition_indices = [2, 0], timing = #hlscpp.t<409 -> 411, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1549 = arith.mulf %1547, %1548 {timing = #hlscpp.t<441 -> 445, 4, 1>} : f32
        %1550 = arith.addf %1546, %1549 {timing = #hlscpp.t<445 -> 450, 5, 1>} : f32
        %1551 = affine.load %arg0[%arg3 * 8 + 1, %arg4 * 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<68 -> 70, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1552 = affine.load %arg2[1, 1] {partition_indices = [1, 1], timing = #hlscpp.t<414 -> 416, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1553 = arith.mulf %1551, %1552 {timing = #hlscpp.t<446 -> 450, 4, 1>} : f32
        %1554 = arith.addf %1550, %1553 {timing = #hlscpp.t<450 -> 455, 5, 1>} : f32
        %1555 = affine.load %arg0[%arg3 * 8, %arg4 * 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<69 -> 71, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1556 = affine.load %arg2[0, 1] {partition_indices = [0, 1], timing = #hlscpp.t<419 -> 421, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1557 = arith.mulf %1555, %1556 {timing = #hlscpp.t<451 -> 455, 4, 1>} : f32
        %1558 = arith.addf %1554, %1557 {timing = #hlscpp.t<455 -> 460, 5, 1>} : f32
        %1559 = affine.load %arg0[%arg3 * 8 + 2, %arg4 * 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<70 -> 72, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1560 = affine.load %arg2[2, 1] {partition_indices = [2, 1], timing = #hlscpp.t<424 -> 426, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1561 = arith.mulf %1559, %1560 {timing = #hlscpp.t<456 -> 460, 4, 1>} : f32
        %1562 = arith.addf %1558, %1561 {timing = #hlscpp.t<460 -> 465, 5, 1>} : f32
        %1563 = affine.load %arg0[%arg3 * 8 + 1, %arg4 * 15 + 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<71 -> 73, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1564 = affine.load %arg2[1, 2] {partition_indices = [1, 2], timing = #hlscpp.t<429 -> 431, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1565 = arith.mulf %1563, %1564 {timing = #hlscpp.t<461 -> 465, 4, 1>} : f32
        %1566 = arith.addf %1562, %1565 {timing = #hlscpp.t<465 -> 470, 5, 1>} : f32
        %1567 = affine.load %arg0[%arg3 * 8, %arg4 * 15 + 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<72 -> 74, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1568 = affine.load %arg2[0, 2] {partition_indices = [0, 2], timing = #hlscpp.t<434 -> 436, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1569 = arith.mulf %1567, %1568 {timing = #hlscpp.t<466 -> 470, 4, 1>} : f32
        %1570 = arith.addf %1566, %1569 {timing = #hlscpp.t<470 -> 475, 5, 1>} : f32
        %1571 = affine.load %arg0[%arg3 * 8 + 2, %arg4 * 15 + 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<73 -> 75, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1572 = affine.load %arg2[2, 2] {partition_indices = [2, 2], timing = #hlscpp.t<439 -> 441, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1573 = arith.mulf %1571, %1572 {timing = #hlscpp.t<471 -> 475, 4, 1>} : f32
        %1574 = arith.addf %1570, %1573 {timing = #hlscpp.t<475 -> 480, 5, 1>} : f32
        affine.store %1574, %arg1[%arg3 * 8 + 1, %arg4 * 15] {partition_indices = [1, 0], timing = #hlscpp.t<480 -> 481, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      } {timing = #hlscpp.t<65 -> 482, 417, 0>}
      %0 = affine.load %arg0[%arg3 * 8 + 1, %arg4 * 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<80 -> 82, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %1 = affine.load %arg2[1, 0] {partition_indices = [1, 0], timing = #hlscpp.t<426 -> 428, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
      %2 = arith.mulf %0, %1 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %3 = affine.load %arg0[%arg3 * 8, %arg4 * 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<81 -> 83, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %4 = affine.load %arg2[0, 0] {partition_indices = [0, 0], timing = #hlscpp.t<426 -> 428, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
      %5 = arith.mulf %3, %4 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %6 = arith.addf %2, %5 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
      %7 = affine.load %arg0[%arg3 * 8 + 2, %arg4 * 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<82 -> 84, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %8 = affine.load %arg2[2, 0] {partition_indices = [2, 0], timing = #hlscpp.t<431 -> 433, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
      %9 = arith.mulf %7, %8 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
      %10 = arith.addf %6, %9 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
      %11 = affine.load %arg0[%arg3 * 8 + 1, %arg4 * 15 + 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<83 -> 85, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %12 = affine.load %arg2[1, 1] {partition_indices = [1, 1], timing = #hlscpp.t<436 -> 438, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
      %13 = arith.mulf %11, %12 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
      %14 = arith.addf %10, %13 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
      %15 = affine.load %arg0[%arg3 * 8, %arg4 * 15 + 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<84 -> 86, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %16 = affine.load %arg2[0, 1] {partition_indices = [0, 1], timing = #hlscpp.t<441 -> 443, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
      %17 = arith.mulf %15, %16 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
      %18 = arith.addf %14, %17 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
      %19 = affine.load %arg0[%arg3 * 8 + 2, %arg4 * 15 + 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<85 -> 87, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %20 = affine.load %arg2[2, 1] {partition_indices = [2, 1], timing = #hlscpp.t<446 -> 448, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
      %21 = arith.mulf %19, %20 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
      %22 = arith.addf %18, %21 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
      %23 = affine.load %arg0[%arg3 * 8 + 1, %arg4 * 15 + 2] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<86 -> 88, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %24 = affine.load %arg2[1, 2] {partition_indices = [1, 2], timing = #hlscpp.t<451 -> 453, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
      %25 = arith.mulf %23, %24 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
      %26 = arith.addf %22, %25 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
      %27 = affine.load %arg0[%arg3 * 8, %arg4 * 15 + 2] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<87 -> 89, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %28 = affine.load %arg2[0, 2] {partition_indices = [0, 2], timing = #hlscpp.t<456 -> 458, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
      %29 = arith.mulf %27, %28 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
      %30 = arith.addf %26, %29 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
      %31 = affine.load %arg0[%arg3 * 8 + 2, %arg4 * 15 + 2] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<88 -> 90, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %32 = affine.load %arg2[2, 2] {partition_indices = [2, 2], timing = #hlscpp.t<461 -> 463, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
      %33 = arith.mulf %31, %32 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
      %34 = arith.addf %30, %33 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
      affine.store %34, %arg1[%arg3 * 8 + 1, %arg4 * 15 + 1] {partition_indices = [1, 1], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      %35 = arith.mulf %11, %1 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %36 = arith.mulf %15, %4 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %37 = arith.addf %35, %36 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
      %38 = arith.mulf %19, %8 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
      %39 = arith.addf %37, %38 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
      %40 = arith.mulf %23, %12 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
      %41 = arith.addf %39, %40 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
      %42 = arith.mulf %27, %16 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
      %43 = arith.addf %41, %42 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
      %44 = arith.mulf %31, %20 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
      %45 = arith.addf %43, %44 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
      %46 = affine.load %arg0[%arg3 * 8 + 1, %arg4 * 15 + 3] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<89 -> 91, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %47 = arith.mulf %46, %24 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
      %48 = arith.addf %45, %47 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
      %49 = affine.load %arg0[%arg3 * 8, %arg4 * 15 + 3] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<90 -> 92, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %50 = arith.mulf %49, %28 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
      %51 = arith.addf %48, %50 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
      %52 = affine.load %arg0[%arg3 * 8 + 2, %arg4 * 15 + 3] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<91 -> 93, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %53 = arith.mulf %52, %32 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
      %54 = arith.addf %51, %53 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
      affine.store %54, %arg1[%arg3 * 8 + 1, %arg4 * 15 + 2] {partition_indices = [1, 2], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      %55 = arith.mulf %23, %1 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %56 = arith.mulf %27, %4 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %57 = arith.addf %55, %56 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
      %58 = arith.mulf %31, %8 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
      %59 = arith.addf %57, %58 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
      %60 = arith.mulf %46, %12 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
      %61 = arith.addf %59, %60 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
      %62 = arith.mulf %49, %16 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
      %63 = arith.addf %61, %62 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
      %64 = arith.mulf %52, %20 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
      %65 = arith.addf %63, %64 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
      %66 = affine.load %arg0[%arg3 * 8 + 1, %arg4 * 15 + 4] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<92 -> 94, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %67 = arith.mulf %66, %24 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
      %68 = arith.addf %65, %67 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
      %69 = affine.load %arg0[%arg3 * 8, %arg4 * 15 + 4] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<93 -> 95, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %70 = arith.mulf %69, %28 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
      %71 = arith.addf %68, %70 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
      %72 = affine.load %arg0[%arg3 * 8 + 2, %arg4 * 15 + 4] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<94 -> 96, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %73 = arith.mulf %72, %32 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
      %74 = arith.addf %71, %73 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
      affine.store %74, %arg1[%arg3 * 8 + 1, %arg4 * 15 + 3] {partition_indices = [1, 3], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      %75 = arith.mulf %46, %1 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %76 = arith.mulf %49, %4 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %77 = arith.addf %75, %76 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
      %78 = arith.mulf %52, %8 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
      %79 = arith.addf %77, %78 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
      %80 = arith.mulf %66, %12 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
      %81 = arith.addf %79, %80 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
      %82 = arith.mulf %69, %16 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
      %83 = arith.addf %81, %82 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
      %84 = arith.mulf %72, %20 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
      %85 = arith.addf %83, %84 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
      %86 = affine.load %arg0[%arg3 * 8 + 1, %arg4 * 15 + 5] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<95 -> 97, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %87 = arith.mulf %86, %24 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
      %88 = arith.addf %85, %87 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
      %89 = affine.load %arg0[%arg3 * 8, %arg4 * 15 + 5] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<96 -> 98, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %90 = arith.mulf %89, %28 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
      %91 = arith.addf %88, %90 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
      %92 = affine.load %arg0[%arg3 * 8 + 2, %arg4 * 15 + 5] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<97 -> 99, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %93 = arith.mulf %92, %32 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
      %94 = arith.addf %91, %93 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
      affine.store %94, %arg1[%arg3 * 8 + 1, %arg4 * 15 + 4] {partition_indices = [1, 4], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      %95 = arith.mulf %66, %1 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %96 = arith.mulf %69, %4 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %97 = arith.addf %95, %96 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
      %98 = arith.mulf %72, %8 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
      %99 = arith.addf %97, %98 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
      %100 = arith.mulf %86, %12 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
      %101 = arith.addf %99, %100 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
      %102 = arith.mulf %89, %16 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
      %103 = arith.addf %101, %102 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
      %104 = arith.mulf %92, %20 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
      %105 = arith.addf %103, %104 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
      %106 = affine.load %arg0[%arg3 * 8 + 1, %arg4 * 15 + 6] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<98 -> 100, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %107 = arith.mulf %106, %24 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
      %108 = arith.addf %105, %107 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
      %109 = affine.load %arg0[%arg3 * 8, %arg4 * 15 + 6] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<99 -> 101, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %110 = arith.mulf %109, %28 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
      %111 = arith.addf %108, %110 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
      %112 = affine.load %arg0[%arg3 * 8 + 2, %arg4 * 15 + 6] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<100 -> 102, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %113 = arith.mulf %112, %32 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
      %114 = arith.addf %111, %113 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
      affine.store %114, %arg1[%arg3 * 8 + 1, %arg4 * 15 + 5] {partition_indices = [1, 5], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      %115 = arith.mulf %86, %1 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %116 = arith.mulf %89, %4 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %117 = arith.addf %115, %116 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
      %118 = arith.mulf %92, %8 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
      %119 = arith.addf %117, %118 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
      %120 = arith.mulf %106, %12 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
      %121 = arith.addf %119, %120 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
      %122 = arith.mulf %109, %16 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
      %123 = arith.addf %121, %122 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
      %124 = arith.mulf %112, %20 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
      %125 = arith.addf %123, %124 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
      %126 = affine.load %arg0[%arg3 * 8 + 1, %arg4 * 15 + 7] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<101 -> 103, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %127 = arith.mulf %126, %24 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
      %128 = arith.addf %125, %127 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
      %129 = affine.load %arg0[%arg3 * 8, %arg4 * 15 + 7] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<102 -> 104, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %130 = arith.mulf %129, %28 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
      %131 = arith.addf %128, %130 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
      %132 = affine.load %arg0[%arg3 * 8 + 2, %arg4 * 15 + 7] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<103 -> 105, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %133 = arith.mulf %132, %32 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
      %134 = arith.addf %131, %133 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
      affine.store %134, %arg1[%arg3 * 8 + 1, %arg4 * 15 + 6] {partition_indices = [1, 6], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      %135 = arith.mulf %106, %1 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %136 = arith.mulf %109, %4 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %137 = arith.addf %135, %136 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
      %138 = arith.mulf %112, %8 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
      %139 = arith.addf %137, %138 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
      %140 = arith.mulf %126, %12 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
      %141 = arith.addf %139, %140 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
      %142 = arith.mulf %129, %16 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
      %143 = arith.addf %141, %142 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
      %144 = arith.mulf %132, %20 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
      %145 = arith.addf %143, %144 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
      %146 = affine.load %arg0[%arg3 * 8 + 1, %arg4 * 15 + 8] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<104 -> 106, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %147 = arith.mulf %146, %24 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
      %148 = arith.addf %145, %147 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
      %149 = affine.load %arg0[%arg3 * 8, %arg4 * 15 + 8] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<105 -> 107, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %150 = arith.mulf %149, %28 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
      %151 = arith.addf %148, %150 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
      %152 = affine.load %arg0[%arg3 * 8 + 2, %arg4 * 15 + 8] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<106 -> 108, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %153 = arith.mulf %152, %32 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
      %154 = arith.addf %151, %153 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
      affine.store %154, %arg1[%arg3 * 8 + 1, %arg4 * 15 + 7] {partition_indices = [1, 7], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      %155 = arith.mulf %126, %1 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %156 = arith.mulf %129, %4 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %157 = arith.addf %155, %156 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
      %158 = arith.mulf %132, %8 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
      %159 = arith.addf %157, %158 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
      %160 = arith.mulf %146, %12 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
      %161 = arith.addf %159, %160 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
      %162 = arith.mulf %149, %16 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
      %163 = arith.addf %161, %162 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
      %164 = arith.mulf %152, %20 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
      %165 = arith.addf %163, %164 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
      %166 = affine.load %arg0[%arg3 * 8 + 1, %arg4 * 15 + 9] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<107 -> 109, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %167 = arith.mulf %166, %24 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
      %168 = arith.addf %165, %167 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
      %169 = affine.load %arg0[%arg3 * 8, %arg4 * 15 + 9] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<108 -> 110, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %170 = arith.mulf %169, %28 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
      %171 = arith.addf %168, %170 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
      %172 = affine.load %arg0[%arg3 * 8 + 2, %arg4 * 15 + 9] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<109 -> 111, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %173 = arith.mulf %172, %32 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
      %174 = arith.addf %171, %173 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
      affine.store %174, %arg1[%arg3 * 8 + 1, %arg4 * 15 + 8] {partition_indices = [1, 8], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      %175 = arith.mulf %146, %1 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %176 = arith.mulf %149, %4 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %177 = arith.addf %175, %176 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
      %178 = arith.mulf %152, %8 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
      %179 = arith.addf %177, %178 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
      %180 = arith.mulf %166, %12 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
      %181 = arith.addf %179, %180 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
      %182 = arith.mulf %169, %16 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
      %183 = arith.addf %181, %182 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
      %184 = arith.mulf %172, %20 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
      %185 = arith.addf %183, %184 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
      %186 = affine.load %arg0[%arg3 * 8 + 1, %arg4 * 15 + 10] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<110 -> 112, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %187 = arith.mulf %186, %24 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
      %188 = arith.addf %185, %187 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
      %189 = affine.load %arg0[%arg3 * 8, %arg4 * 15 + 10] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<111 -> 113, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %190 = arith.mulf %189, %28 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
      %191 = arith.addf %188, %190 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
      %192 = affine.load %arg0[%arg3 * 8 + 2, %arg4 * 15 + 10] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<112 -> 114, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %193 = arith.mulf %192, %32 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
      %194 = arith.addf %191, %193 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
      affine.store %194, %arg1[%arg3 * 8 + 1, %arg4 * 15 + 9] {partition_indices = [1, 9], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      %195 = arith.mulf %166, %1 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %196 = arith.mulf %169, %4 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %197 = arith.addf %195, %196 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
      %198 = arith.mulf %172, %8 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
      %199 = arith.addf %197, %198 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
      %200 = arith.mulf %186, %12 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
      %201 = arith.addf %199, %200 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
      %202 = arith.mulf %189, %16 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
      %203 = arith.addf %201, %202 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
      %204 = arith.mulf %192, %20 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
      %205 = arith.addf %203, %204 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
      %206 = affine.load %arg0[%arg3 * 8 + 1, %arg4 * 15 + 11] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<113 -> 115, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %207 = arith.mulf %206, %24 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
      %208 = arith.addf %205, %207 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
      %209 = affine.load %arg0[%arg3 * 8, %arg4 * 15 + 11] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<114 -> 116, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %210 = arith.mulf %209, %28 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
      %211 = arith.addf %208, %210 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
      %212 = affine.load %arg0[%arg3 * 8 + 2, %arg4 * 15 + 11] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<115 -> 117, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %213 = arith.mulf %212, %32 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
      %214 = arith.addf %211, %213 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
      affine.store %214, %arg1[%arg3 * 8 + 1, %arg4 * 15 + 10] {partition_indices = [1, 10], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      %215 = arith.mulf %186, %1 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %216 = arith.mulf %189, %4 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %217 = arith.addf %215, %216 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
      %218 = arith.mulf %192, %8 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
      %219 = arith.addf %217, %218 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
      %220 = arith.mulf %206, %12 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
      %221 = arith.addf %219, %220 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
      %222 = arith.mulf %209, %16 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
      %223 = arith.addf %221, %222 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
      %224 = arith.mulf %212, %20 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
      %225 = arith.addf %223, %224 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
      %226 = affine.load %arg0[%arg3 * 8 + 1, %arg4 * 15 + 12] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<116 -> 118, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %227 = arith.mulf %226, %24 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
      %228 = arith.addf %225, %227 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
      %229 = affine.load %arg0[%arg3 * 8, %arg4 * 15 + 12] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<117 -> 119, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %230 = arith.mulf %229, %28 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
      %231 = arith.addf %228, %230 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
      %232 = affine.load %arg0[%arg3 * 8 + 2, %arg4 * 15 + 12] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<118 -> 120, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %233 = arith.mulf %232, %32 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
      %234 = arith.addf %231, %233 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
      affine.store %234, %arg1[%arg3 * 8 + 1, %arg4 * 15 + 11] {partition_indices = [1, 11], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      %235 = arith.mulf %206, %1 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %236 = arith.mulf %209, %4 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %237 = arith.addf %235, %236 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
      %238 = arith.mulf %212, %8 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
      %239 = arith.addf %237, %238 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
      %240 = arith.mulf %226, %12 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
      %241 = arith.addf %239, %240 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
      %242 = arith.mulf %229, %16 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
      %243 = arith.addf %241, %242 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
      %244 = arith.mulf %232, %20 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
      %245 = arith.addf %243, %244 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
      %246 = affine.load %arg0[%arg3 * 8 + 1, %arg4 * 15 + 13] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<119 -> 121, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %247 = arith.mulf %246, %24 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
      %248 = arith.addf %245, %247 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
      %249 = affine.load %arg0[%arg3 * 8, %arg4 * 15 + 13] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<120 -> 122, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %250 = arith.mulf %249, %28 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
      %251 = arith.addf %248, %250 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
      %252 = affine.load %arg0[%arg3 * 8 + 2, %arg4 * 15 + 13] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<121 -> 123, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %253 = arith.mulf %252, %32 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
      %254 = arith.addf %251, %253 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
      affine.store %254, %arg1[%arg3 * 8 + 1, %arg4 * 15 + 12] {partition_indices = [1, 12], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      %255 = arith.mulf %226, %1 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %256 = arith.mulf %229, %4 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %257 = arith.addf %255, %256 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
      %258 = arith.mulf %232, %8 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
      %259 = arith.addf %257, %258 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
      %260 = arith.mulf %246, %12 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
      %261 = arith.addf %259, %260 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
      %262 = arith.mulf %249, %16 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
      %263 = arith.addf %261, %262 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
      %264 = arith.mulf %252, %20 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
      %265 = arith.addf %263, %264 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
      %266 = affine.load %arg0[%arg3 * 8 + 1, %arg4 * 15 + 14] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<122 -> 124, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %267 = arith.mulf %266, %24 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
      %268 = arith.addf %265, %267 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
      %269 = affine.load %arg0[%arg3 * 8, %arg4 * 15 + 14] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<123 -> 125, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %270 = arith.mulf %269, %28 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
      %271 = arith.addf %268, %270 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
      %272 = affine.load %arg0[%arg3 * 8 + 2, %arg4 * 15 + 14] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<124 -> 126, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %273 = arith.mulf %272, %32 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
      %274 = arith.addf %271, %273 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
      affine.store %274, %arg1[%arg3 * 8 + 1, %arg4 * 15 + 13] {partition_indices = [1, 13], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      affine.if affine_set<(d0) : (d0 * 15 - 1065 == 0)>(%arg4) {
        %1540 = affine.load %arg0[%arg3 * 8 + 1, %arg4 * 15 + 13] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<134 -> 136, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1541 = affine.load %arg2[1, 0] {partition_indices = [1, 0], timing = #hlscpp.t<407 -> 409, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1542 = arith.mulf %1540, %1541 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
        %1543 = affine.load %arg0[%arg3 * 8, %arg4 * 15 + 13] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<135 -> 137, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1544 = affine.load %arg2[0, 0] {partition_indices = [0, 0], timing = #hlscpp.t<407 -> 409, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1545 = arith.mulf %1543, %1544 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
        %1546 = arith.addf %1542, %1545 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
        %1547 = affine.load %arg0[%arg3 * 8 + 2, %arg4 * 15 + 13] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<136 -> 138, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1548 = affine.load %arg2[2, 0] {partition_indices = [2, 0], timing = #hlscpp.t<412 -> 414, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1549 = arith.mulf %1547, %1548 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
        %1550 = arith.addf %1546, %1549 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
        %1551 = affine.load %arg0[%arg3 * 8 + 1, %arg4 * 15 + 14] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<137 -> 139, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1552 = affine.load %arg2[1, 1] {partition_indices = [1, 1], timing = #hlscpp.t<417 -> 419, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1553 = arith.mulf %1551, %1552 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
        %1554 = arith.addf %1550, %1553 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
        %1555 = affine.load %arg0[%arg3 * 8, %arg4 * 15 + 14] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<138 -> 140, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1556 = affine.load %arg2[0, 1] {partition_indices = [0, 1], timing = #hlscpp.t<422 -> 424, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1557 = arith.mulf %1555, %1556 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
        %1558 = arith.addf %1554, %1557 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
        %1559 = affine.load %arg0[%arg3 * 8 + 2, %arg4 * 15 + 14] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<139 -> 141, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1560 = affine.load %arg2[2, 1] {partition_indices = [2, 1], timing = #hlscpp.t<427 -> 429, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1561 = arith.mulf %1559, %1560 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
        %1562 = arith.addf %1558, %1561 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
        %1563 = affine.load %arg2[1, 2] {partition_indices = [1, 2], timing = #hlscpp.t<432 -> 434, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1564 = arith.mulf %1540, %1563 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
        %1565 = arith.addf %1562, %1564 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
        %1566 = affine.load %arg2[0, 2] {partition_indices = [0, 2], timing = #hlscpp.t<437 -> 439, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1567 = arith.mulf %1543, %1566 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
        %1568 = arith.addf %1565, %1567 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
        %1569 = affine.load %arg2[2, 2] {partition_indices = [2, 2], timing = #hlscpp.t<442 -> 444, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1570 = arith.mulf %1547, %1569 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
        %1571 = arith.addf %1568, %1570 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
        affine.store %1571, %arg1[%arg3 * 8 + 1, %arg4 * 15 + 14] {partition_indices = [1, 14], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      } else {
        %1540 = affine.load %arg0[%arg3 * 8 + 1, %arg4 * 15 + 13] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<125 -> 127, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1541 = affine.load %arg2[1, 0] {partition_indices = [1, 0], timing = #hlscpp.t<406 -> 408, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1542 = arith.mulf %1540, %1541 {timing = #hlscpp.t<436 -> 440, 4, 1>} : f32
        %1543 = affine.load %arg0[%arg3 * 8, %arg4 * 15 + 13] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<126 -> 128, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1544 = affine.load %arg2[0, 0] {partition_indices = [0, 0], timing = #hlscpp.t<406 -> 408, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1545 = arith.mulf %1543, %1544 {timing = #hlscpp.t<436 -> 440, 4, 1>} : f32
        %1546 = arith.addf %1542, %1545 {timing = #hlscpp.t<440 -> 445, 5, 1>} : f32
        %1547 = affine.load %arg0[%arg3 * 8 + 2, %arg4 * 15 + 13] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<127 -> 129, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1548 = affine.load %arg2[2, 0] {partition_indices = [2, 0], timing = #hlscpp.t<411 -> 413, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1549 = arith.mulf %1547, %1548 {timing = #hlscpp.t<441 -> 445, 4, 1>} : f32
        %1550 = arith.addf %1546, %1549 {timing = #hlscpp.t<445 -> 450, 5, 1>} : f32
        %1551 = affine.load %arg0[%arg3 * 8 + 1, %arg4 * 15 + 14] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<128 -> 130, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1552 = affine.load %arg2[1, 1] {partition_indices = [1, 1], timing = #hlscpp.t<416 -> 418, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1553 = arith.mulf %1551, %1552 {timing = #hlscpp.t<446 -> 450, 4, 1>} : f32
        %1554 = arith.addf %1550, %1553 {timing = #hlscpp.t<450 -> 455, 5, 1>} : f32
        %1555 = affine.load %arg0[%arg3 * 8, %arg4 * 15 + 14] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<129 -> 131, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1556 = affine.load %arg2[0, 1] {partition_indices = [0, 1], timing = #hlscpp.t<421 -> 423, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1557 = arith.mulf %1555, %1556 {timing = #hlscpp.t<451 -> 455, 4, 1>} : f32
        %1558 = arith.addf %1554, %1557 {timing = #hlscpp.t<455 -> 460, 5, 1>} : f32
        %1559 = affine.load %arg0[%arg3 * 8 + 2, %arg4 * 15 + 14] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<130 -> 132, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1560 = affine.load %arg2[2, 1] {partition_indices = [2, 1], timing = #hlscpp.t<426 -> 428, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1561 = arith.mulf %1559, %1560 {timing = #hlscpp.t<456 -> 460, 4, 1>} : f32
        %1562 = arith.addf %1558, %1561 {timing = #hlscpp.t<460 -> 465, 5, 1>} : f32
        %1563 = affine.load %arg0[%arg3 * 8 + 1, %arg4 * 15 + 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<131 -> 133, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1564 = affine.load %arg2[1, 2] {partition_indices = [1, 2], timing = #hlscpp.t<431 -> 433, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1565 = arith.mulf %1563, %1564 {timing = #hlscpp.t<461 -> 465, 4, 1>} : f32
        %1566 = arith.addf %1562, %1565 {timing = #hlscpp.t<465 -> 470, 5, 1>} : f32
        %1567 = affine.load %arg0[%arg3 * 8, %arg4 * 15 + 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<132 -> 134, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1568 = affine.load %arg2[0, 2] {partition_indices = [0, 2], timing = #hlscpp.t<436 -> 438, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1569 = arith.mulf %1567, %1568 {timing = #hlscpp.t<466 -> 470, 4, 1>} : f32
        %1570 = arith.addf %1566, %1569 {timing = #hlscpp.t<470 -> 475, 5, 1>} : f32
        %1571 = affine.load %arg0[%arg3 * 8 + 2, %arg4 * 15 + 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<133 -> 135, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1572 = affine.load %arg2[2, 2] {partition_indices = [2, 2], timing = #hlscpp.t<441 -> 443, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1573 = arith.mulf %1571, %1572 {timing = #hlscpp.t<471 -> 475, 4, 1>} : f32
        %1574 = arith.addf %1570, %1573 {timing = #hlscpp.t<475 -> 480, 5, 1>} : f32
        affine.store %1574, %arg1[%arg3 * 8 + 1, %arg4 * 15 + 14] {partition_indices = [1, 14], timing = #hlscpp.t<480 -> 481, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      } {timing = #hlscpp.t<125 -> 482, 357, 0>}
      affine.if affine_set<(d0) : (d0 * 15 == 0)>(%arg4) {
        %1540 = affine.load %arg0[%arg3 * 8 + 2, %arg4 * 15 + 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<149 -> 151, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1541 = affine.load %arg2[1, 0] {partition_indices = [1, 0], timing = #hlscpp.t<409 -> 411, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1542 = arith.mulf %1540, %1541 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
        %1543 = affine.load %arg0[%arg3 * 8 + 1, %arg4 * 15 + 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<150 -> 152, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1544 = affine.load %arg2[0, 0] {partition_indices = [0, 0], timing = #hlscpp.t<409 -> 411, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1545 = arith.mulf %1543, %1544 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
        %1546 = arith.addf %1542, %1545 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
        %1547 = affine.load %arg0[%arg3 * 8 + 3, %arg4 * 15 + 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<151 -> 153, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1548 = affine.load %arg2[2, 0] {partition_indices = [2, 0], timing = #hlscpp.t<414 -> 416, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1549 = arith.mulf %1547, %1548 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
        %1550 = arith.addf %1546, %1549 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
        %1551 = affine.load %arg0[%arg3 * 8 + 2, %arg4 * 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<152 -> 154, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1552 = affine.load %arg2[1, 1] {partition_indices = [1, 1], timing = #hlscpp.t<419 -> 421, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1553 = arith.mulf %1551, %1552 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
        %1554 = arith.addf %1550, %1553 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
        %1555 = affine.load %arg0[%arg3 * 8 + 1, %arg4 * 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<153 -> 155, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1556 = affine.load %arg2[0, 1] {partition_indices = [0, 1], timing = #hlscpp.t<424 -> 426, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1557 = arith.mulf %1555, %1556 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
        %1558 = arith.addf %1554, %1557 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
        %1559 = affine.load %arg0[%arg3 * 8 + 3, %arg4 * 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<154 -> 156, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1560 = affine.load %arg2[2, 1] {partition_indices = [2, 1], timing = #hlscpp.t<429 -> 431, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1561 = arith.mulf %1559, %1560 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
        %1562 = arith.addf %1558, %1561 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
        %1563 = affine.load %arg2[1, 2] {partition_indices = [1, 2], timing = #hlscpp.t<434 -> 436, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1564 = arith.mulf %1540, %1563 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
        %1565 = arith.addf %1562, %1564 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
        %1566 = affine.load %arg2[0, 2] {partition_indices = [0, 2], timing = #hlscpp.t<439 -> 441, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1567 = arith.mulf %1543, %1566 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
        %1568 = arith.addf %1565, %1567 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
        %1569 = affine.load %arg2[2, 2] {partition_indices = [2, 2], timing = #hlscpp.t<444 -> 446, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1570 = arith.mulf %1547, %1569 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
        %1571 = arith.addf %1568, %1570 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
        affine.store %1571, %arg1[%arg3 * 8 + 2, %arg4 * 15] {partition_indices = [2, 0], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      } else {
        %1540 = affine.load %arg0[%arg3 * 8 + 2, %arg4 * 15 - 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<140 -> 142, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1541 = affine.load %arg2[1, 0] {partition_indices = [1, 0], timing = #hlscpp.t<408 -> 410, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1542 = arith.mulf %1540, %1541 {timing = #hlscpp.t<436 -> 440, 4, 1>} : f32
        %1543 = affine.load %arg0[%arg3 * 8 + 1, %arg4 * 15 - 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<141 -> 143, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1544 = affine.load %arg2[0, 0] {partition_indices = [0, 0], timing = #hlscpp.t<408 -> 410, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1545 = arith.mulf %1543, %1544 {timing = #hlscpp.t<436 -> 440, 4, 1>} : f32
        %1546 = arith.addf %1542, %1545 {timing = #hlscpp.t<440 -> 445, 5, 1>} : f32
        %1547 = affine.load %arg0[%arg3 * 8 + 3, %arg4 * 15 - 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<142 -> 144, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1548 = affine.load %arg2[2, 0] {partition_indices = [2, 0], timing = #hlscpp.t<413 -> 415, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1549 = arith.mulf %1547, %1548 {timing = #hlscpp.t<441 -> 445, 4, 1>} : f32
        %1550 = arith.addf %1546, %1549 {timing = #hlscpp.t<445 -> 450, 5, 1>} : f32
        %1551 = affine.load %arg0[%arg3 * 8 + 2, %arg4 * 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<143 -> 145, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1552 = affine.load %arg2[1, 1] {partition_indices = [1, 1], timing = #hlscpp.t<418 -> 420, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1553 = arith.mulf %1551, %1552 {timing = #hlscpp.t<446 -> 450, 4, 1>} : f32
        %1554 = arith.addf %1550, %1553 {timing = #hlscpp.t<450 -> 455, 5, 1>} : f32
        %1555 = affine.load %arg0[%arg3 * 8 + 1, %arg4 * 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<144 -> 146, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1556 = affine.load %arg2[0, 1] {partition_indices = [0, 1], timing = #hlscpp.t<423 -> 425, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1557 = arith.mulf %1555, %1556 {timing = #hlscpp.t<451 -> 455, 4, 1>} : f32
        %1558 = arith.addf %1554, %1557 {timing = #hlscpp.t<455 -> 460, 5, 1>} : f32
        %1559 = affine.load %arg0[%arg3 * 8 + 3, %arg4 * 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<145 -> 147, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1560 = affine.load %arg2[2, 1] {partition_indices = [2, 1], timing = #hlscpp.t<428 -> 430, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1561 = arith.mulf %1559, %1560 {timing = #hlscpp.t<456 -> 460, 4, 1>} : f32
        %1562 = arith.addf %1558, %1561 {timing = #hlscpp.t<460 -> 465, 5, 1>} : f32
        %1563 = affine.load %arg0[%arg3 * 8 + 2, %arg4 * 15 + 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<146 -> 148, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1564 = affine.load %arg2[1, 2] {partition_indices = [1, 2], timing = #hlscpp.t<433 -> 435, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1565 = arith.mulf %1563, %1564 {timing = #hlscpp.t<461 -> 465, 4, 1>} : f32
        %1566 = arith.addf %1562, %1565 {timing = #hlscpp.t<465 -> 470, 5, 1>} : f32
        %1567 = affine.load %arg0[%arg3 * 8 + 1, %arg4 * 15 + 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<147 -> 149, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1568 = affine.load %arg2[0, 2] {partition_indices = [0, 2], timing = #hlscpp.t<438 -> 440, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1569 = arith.mulf %1567, %1568 {timing = #hlscpp.t<466 -> 470, 4, 1>} : f32
        %1570 = arith.addf %1566, %1569 {timing = #hlscpp.t<470 -> 475, 5, 1>} : f32
        %1571 = affine.load %arg0[%arg3 * 8 + 3, %arg4 * 15 + 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<148 -> 150, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1572 = affine.load %arg2[2, 2] {partition_indices = [2, 2], timing = #hlscpp.t<443 -> 445, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1573 = arith.mulf %1571, %1572 {timing = #hlscpp.t<471 -> 475, 4, 1>} : f32
        %1574 = arith.addf %1570, %1573 {timing = #hlscpp.t<475 -> 480, 5, 1>} : f32
        affine.store %1574, %arg1[%arg3 * 8 + 2, %arg4 * 15] {partition_indices = [2, 0], timing = #hlscpp.t<480 -> 481, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      } {timing = #hlscpp.t<140 -> 482, 342, 0>}
      %275 = affine.load %arg0[%arg3 * 8 + 2, %arg4 * 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<155 -> 157, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %276 = affine.load %arg2[1, 0] {partition_indices = [1, 0], timing = #hlscpp.t<426 -> 428, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
      %277 = arith.mulf %275, %276 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %278 = affine.load %arg0[%arg3 * 8 + 1, %arg4 * 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<156 -> 158, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %279 = affine.load %arg2[0, 0] {partition_indices = [0, 0], timing = #hlscpp.t<426 -> 428, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
      %280 = arith.mulf %278, %279 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %281 = arith.addf %277, %280 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
      %282 = affine.load %arg0[%arg3 * 8 + 3, %arg4 * 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<157 -> 159, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %283 = affine.load %arg2[2, 0] {partition_indices = [2, 0], timing = #hlscpp.t<431 -> 433, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
      %284 = arith.mulf %282, %283 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
      %285 = arith.addf %281, %284 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
      %286 = affine.load %arg0[%arg3 * 8 + 2, %arg4 * 15 + 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<158 -> 160, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %287 = affine.load %arg2[1, 1] {partition_indices = [1, 1], timing = #hlscpp.t<436 -> 438, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
      %288 = arith.mulf %286, %287 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
      %289 = arith.addf %285, %288 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
      %290 = affine.load %arg0[%arg3 * 8 + 1, %arg4 * 15 + 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<159 -> 161, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %291 = affine.load %arg2[0, 1] {partition_indices = [0, 1], timing = #hlscpp.t<441 -> 443, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
      %292 = arith.mulf %290, %291 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
      %293 = arith.addf %289, %292 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
      %294 = affine.load %arg0[%arg3 * 8 + 3, %arg4 * 15 + 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<160 -> 162, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %295 = affine.load %arg2[2, 1] {partition_indices = [2, 1], timing = #hlscpp.t<446 -> 448, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
      %296 = arith.mulf %294, %295 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
      %297 = arith.addf %293, %296 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
      %298 = affine.load %arg2[1, 2] {partition_indices = [1, 2], timing = #hlscpp.t<451 -> 453, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
      %299 = arith.mulf %31, %298 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
      %300 = arith.addf %297, %299 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
      %301 = affine.load %arg2[0, 2] {partition_indices = [0, 2], timing = #hlscpp.t<456 -> 458, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
      %302 = arith.mulf %23, %301 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
      %303 = arith.addf %300, %302 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
      %304 = affine.load %arg0[%arg3 * 8 + 3, %arg4 * 15 + 2] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<161 -> 163, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %305 = affine.load %arg2[2, 2] {partition_indices = [2, 2], timing = #hlscpp.t<461 -> 463, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
      %306 = arith.mulf %304, %305 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
      %307 = arith.addf %303, %306 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
      affine.store %307, %arg1[%arg3 * 8 + 2, %arg4 * 15 + 1] {partition_indices = [2, 1], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      %308 = arith.mulf %286, %276 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %309 = arith.mulf %290, %279 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %310 = arith.addf %308, %309 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
      %311 = arith.mulf %294, %283 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
      %312 = arith.addf %310, %311 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
      %313 = arith.mulf %31, %287 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
      %314 = arith.addf %312, %313 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
      %315 = arith.mulf %23, %291 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
      %316 = arith.addf %314, %315 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
      %317 = arith.mulf %304, %295 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
      %318 = arith.addf %316, %317 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
      %319 = arith.mulf %52, %298 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
      %320 = arith.addf %318, %319 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
      %321 = arith.mulf %46, %301 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
      %322 = arith.addf %320, %321 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
      %323 = affine.load %arg0[%arg3 * 8 + 3, %arg4 * 15 + 3] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<162 -> 164, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %324 = arith.mulf %323, %305 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
      %325 = arith.addf %322, %324 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
      affine.store %325, %arg1[%arg3 * 8 + 2, %arg4 * 15 + 2] {partition_indices = [2, 2], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      %326 = arith.mulf %31, %276 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %327 = arith.mulf %23, %279 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %328 = arith.addf %326, %327 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
      %329 = arith.mulf %304, %283 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
      %330 = arith.addf %328, %329 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
      %331 = arith.mulf %52, %287 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
      %332 = arith.addf %330, %331 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
      %333 = arith.mulf %46, %291 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
      %334 = arith.addf %332, %333 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
      %335 = arith.mulf %323, %295 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
      %336 = arith.addf %334, %335 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
      %337 = arith.mulf %72, %298 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
      %338 = arith.addf %336, %337 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
      %339 = arith.mulf %66, %301 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
      %340 = arith.addf %338, %339 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
      %341 = affine.load %arg0[%arg3 * 8 + 3, %arg4 * 15 + 4] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<163 -> 165, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %342 = arith.mulf %341, %305 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
      %343 = arith.addf %340, %342 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
      affine.store %343, %arg1[%arg3 * 8 + 2, %arg4 * 15 + 3] {partition_indices = [2, 3], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      %344 = arith.mulf %52, %276 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %345 = arith.mulf %46, %279 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %346 = arith.addf %344, %345 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
      %347 = arith.mulf %323, %283 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
      %348 = arith.addf %346, %347 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
      %349 = arith.mulf %72, %287 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
      %350 = arith.addf %348, %349 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
      %351 = arith.mulf %66, %291 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
      %352 = arith.addf %350, %351 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
      %353 = arith.mulf %341, %295 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
      %354 = arith.addf %352, %353 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
      %355 = arith.mulf %92, %298 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
      %356 = arith.addf %354, %355 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
      %357 = arith.mulf %86, %301 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
      %358 = arith.addf %356, %357 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
      %359 = affine.load %arg0[%arg3 * 8 + 3, %arg4 * 15 + 5] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<164 -> 166, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %360 = arith.mulf %359, %305 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
      %361 = arith.addf %358, %360 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
      affine.store %361, %arg1[%arg3 * 8 + 2, %arg4 * 15 + 4] {partition_indices = [2, 4], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      %362 = arith.mulf %72, %276 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %363 = arith.mulf %66, %279 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %364 = arith.addf %362, %363 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
      %365 = arith.mulf %341, %283 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
      %366 = arith.addf %364, %365 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
      %367 = arith.mulf %92, %287 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
      %368 = arith.addf %366, %367 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
      %369 = arith.mulf %86, %291 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
      %370 = arith.addf %368, %369 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
      %371 = arith.mulf %359, %295 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
      %372 = arith.addf %370, %371 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
      %373 = arith.mulf %112, %298 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
      %374 = arith.addf %372, %373 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
      %375 = arith.mulf %106, %301 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
      %376 = arith.addf %374, %375 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
      %377 = affine.load %arg0[%arg3 * 8 + 3, %arg4 * 15 + 6] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<165 -> 167, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %378 = arith.mulf %377, %305 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
      %379 = arith.addf %376, %378 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
      affine.store %379, %arg1[%arg3 * 8 + 2, %arg4 * 15 + 5] {partition_indices = [2, 5], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      %380 = arith.mulf %92, %276 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %381 = arith.mulf %86, %279 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %382 = arith.addf %380, %381 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
      %383 = arith.mulf %359, %283 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
      %384 = arith.addf %382, %383 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
      %385 = arith.mulf %112, %287 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
      %386 = arith.addf %384, %385 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
      %387 = arith.mulf %106, %291 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
      %388 = arith.addf %386, %387 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
      %389 = arith.mulf %377, %295 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
      %390 = arith.addf %388, %389 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
      %391 = arith.mulf %132, %298 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
      %392 = arith.addf %390, %391 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
      %393 = arith.mulf %126, %301 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
      %394 = arith.addf %392, %393 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
      %395 = affine.load %arg0[%arg3 * 8 + 3, %arg4 * 15 + 7] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<166 -> 168, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %396 = arith.mulf %395, %305 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
      %397 = arith.addf %394, %396 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
      affine.store %397, %arg1[%arg3 * 8 + 2, %arg4 * 15 + 6] {partition_indices = [2, 6], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      %398 = arith.mulf %112, %276 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %399 = arith.mulf %106, %279 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %400 = arith.addf %398, %399 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
      %401 = arith.mulf %377, %283 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
      %402 = arith.addf %400, %401 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
      %403 = arith.mulf %132, %287 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
      %404 = arith.addf %402, %403 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
      %405 = arith.mulf %126, %291 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
      %406 = arith.addf %404, %405 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
      %407 = arith.mulf %395, %295 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
      %408 = arith.addf %406, %407 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
      %409 = arith.mulf %152, %298 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
      %410 = arith.addf %408, %409 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
      %411 = arith.mulf %146, %301 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
      %412 = arith.addf %410, %411 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
      %413 = affine.load %arg0[%arg3 * 8 + 3, %arg4 * 15 + 8] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<167 -> 169, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %414 = arith.mulf %413, %305 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
      %415 = arith.addf %412, %414 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
      affine.store %415, %arg1[%arg3 * 8 + 2, %arg4 * 15 + 7] {partition_indices = [2, 7], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      %416 = arith.mulf %132, %276 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %417 = arith.mulf %126, %279 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %418 = arith.addf %416, %417 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
      %419 = arith.mulf %395, %283 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
      %420 = arith.addf %418, %419 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
      %421 = arith.mulf %152, %287 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
      %422 = arith.addf %420, %421 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
      %423 = arith.mulf %146, %291 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
      %424 = arith.addf %422, %423 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
      %425 = arith.mulf %413, %295 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
      %426 = arith.addf %424, %425 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
      %427 = arith.mulf %172, %298 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
      %428 = arith.addf %426, %427 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
      %429 = arith.mulf %166, %301 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
      %430 = arith.addf %428, %429 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
      %431 = affine.load %arg0[%arg3 * 8 + 3, %arg4 * 15 + 9] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<168 -> 170, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %432 = arith.mulf %431, %305 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
      %433 = arith.addf %430, %432 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
      affine.store %433, %arg1[%arg3 * 8 + 2, %arg4 * 15 + 8] {partition_indices = [2, 8], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      %434 = arith.mulf %152, %276 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %435 = arith.mulf %146, %279 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %436 = arith.addf %434, %435 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
      %437 = arith.mulf %413, %283 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
      %438 = arith.addf %436, %437 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
      %439 = arith.mulf %172, %287 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
      %440 = arith.addf %438, %439 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
      %441 = arith.mulf %166, %291 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
      %442 = arith.addf %440, %441 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
      %443 = arith.mulf %431, %295 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
      %444 = arith.addf %442, %443 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
      %445 = arith.mulf %192, %298 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
      %446 = arith.addf %444, %445 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
      %447 = arith.mulf %186, %301 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
      %448 = arith.addf %446, %447 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
      %449 = affine.load %arg0[%arg3 * 8 + 3, %arg4 * 15 + 10] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<169 -> 171, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %450 = arith.mulf %449, %305 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
      %451 = arith.addf %448, %450 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
      affine.store %451, %arg1[%arg3 * 8 + 2, %arg4 * 15 + 9] {partition_indices = [2, 9], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      %452 = arith.mulf %172, %276 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %453 = arith.mulf %166, %279 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %454 = arith.addf %452, %453 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
      %455 = arith.mulf %431, %283 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
      %456 = arith.addf %454, %455 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
      %457 = arith.mulf %192, %287 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
      %458 = arith.addf %456, %457 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
      %459 = arith.mulf %186, %291 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
      %460 = arith.addf %458, %459 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
      %461 = arith.mulf %449, %295 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
      %462 = arith.addf %460, %461 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
      %463 = arith.mulf %212, %298 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
      %464 = arith.addf %462, %463 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
      %465 = arith.mulf %206, %301 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
      %466 = arith.addf %464, %465 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
      %467 = affine.load %arg0[%arg3 * 8 + 3, %arg4 * 15 + 11] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<170 -> 172, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %468 = arith.mulf %467, %305 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
      %469 = arith.addf %466, %468 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
      affine.store %469, %arg1[%arg3 * 8 + 2, %arg4 * 15 + 10] {partition_indices = [2, 10], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      %470 = arith.mulf %192, %276 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %471 = arith.mulf %186, %279 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %472 = arith.addf %470, %471 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
      %473 = arith.mulf %449, %283 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
      %474 = arith.addf %472, %473 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
      %475 = arith.mulf %212, %287 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
      %476 = arith.addf %474, %475 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
      %477 = arith.mulf %206, %291 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
      %478 = arith.addf %476, %477 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
      %479 = arith.mulf %467, %295 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
      %480 = arith.addf %478, %479 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
      %481 = arith.mulf %232, %298 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
      %482 = arith.addf %480, %481 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
      %483 = arith.mulf %226, %301 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
      %484 = arith.addf %482, %483 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
      %485 = affine.load %arg0[%arg3 * 8 + 3, %arg4 * 15 + 12] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<171 -> 173, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %486 = arith.mulf %485, %305 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
      %487 = arith.addf %484, %486 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
      affine.store %487, %arg1[%arg3 * 8 + 2, %arg4 * 15 + 11] {partition_indices = [2, 11], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      %488 = arith.mulf %212, %276 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %489 = arith.mulf %206, %279 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %490 = arith.addf %488, %489 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
      %491 = arith.mulf %467, %283 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
      %492 = arith.addf %490, %491 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
      %493 = arith.mulf %232, %287 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
      %494 = arith.addf %492, %493 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
      %495 = arith.mulf %226, %291 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
      %496 = arith.addf %494, %495 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
      %497 = arith.mulf %485, %295 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
      %498 = arith.addf %496, %497 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
      %499 = affine.load %arg0[%arg3 * 8 + 2, %arg4 * 15 + 13] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<172 -> 174, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %500 = arith.mulf %499, %298 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
      %501 = arith.addf %498, %500 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
      %502 = affine.load %arg0[%arg3 * 8 + 1, %arg4 * 15 + 13] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<173 -> 175, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %503 = arith.mulf %502, %301 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
      %504 = arith.addf %501, %503 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
      %505 = affine.load %arg0[%arg3 * 8 + 3, %arg4 * 15 + 13] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<174 -> 176, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %506 = arith.mulf %505, %305 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
      %507 = arith.addf %504, %506 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
      affine.store %507, %arg1[%arg3 * 8 + 2, %arg4 * 15 + 12] {partition_indices = [2, 12], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      %508 = arith.mulf %232, %276 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %509 = arith.mulf %226, %279 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %510 = arith.addf %508, %509 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
      %511 = arith.mulf %485, %283 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
      %512 = arith.addf %510, %511 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
      %513 = arith.mulf %499, %287 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
      %514 = arith.addf %512, %513 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
      %515 = arith.mulf %502, %291 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
      %516 = arith.addf %514, %515 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
      %517 = arith.mulf %505, %295 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
      %518 = arith.addf %516, %517 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
      %519 = affine.load %arg0[%arg3 * 8 + 2, %arg4 * 15 + 14] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<175 -> 177, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %520 = arith.mulf %519, %298 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
      %521 = arith.addf %518, %520 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
      %522 = affine.load %arg0[%arg3 * 8 + 1, %arg4 * 15 + 14] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<176 -> 178, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %523 = arith.mulf %522, %301 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
      %524 = arith.addf %521, %523 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
      %525 = affine.load %arg0[%arg3 * 8 + 3, %arg4 * 15 + 14] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<177 -> 179, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %526 = arith.mulf %525, %305 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
      %527 = arith.addf %524, %526 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
      affine.store %527, %arg1[%arg3 * 8 + 2, %arg4 * 15 + 13] {partition_indices = [2, 13], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      affine.if affine_set<(d0) : (d0 * 15 - 1065 == 0)>(%arg4) {
        %1540 = affine.load %arg0[%arg3 * 8 + 2, %arg4 * 15 + 13] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<187 -> 189, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1541 = affine.load %arg2[1, 0] {partition_indices = [1, 0], timing = #hlscpp.t<411 -> 413, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1542 = arith.mulf %1540, %1541 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
        %1543 = affine.load %arg0[%arg3 * 8 + 1, %arg4 * 15 + 13] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<188 -> 190, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1544 = affine.load %arg2[0, 0] {partition_indices = [0, 0], timing = #hlscpp.t<411 -> 413, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1545 = arith.mulf %1543, %1544 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
        %1546 = arith.addf %1542, %1545 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
        %1547 = affine.load %arg0[%arg3 * 8 + 3, %arg4 * 15 + 13] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<189 -> 191, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1548 = affine.load %arg2[2, 0] {partition_indices = [2, 0], timing = #hlscpp.t<416 -> 418, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1549 = arith.mulf %1547, %1548 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
        %1550 = arith.addf %1546, %1549 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
        %1551 = affine.load %arg0[%arg3 * 8 + 2, %arg4 * 15 + 14] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<190 -> 192, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1552 = affine.load %arg2[1, 1] {partition_indices = [1, 1], timing = #hlscpp.t<421 -> 423, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1553 = arith.mulf %1551, %1552 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
        %1554 = arith.addf %1550, %1553 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
        %1555 = affine.load %arg0[%arg3 * 8 + 1, %arg4 * 15 + 14] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<191 -> 193, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1556 = affine.load %arg2[0, 1] {partition_indices = [0, 1], timing = #hlscpp.t<426 -> 428, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1557 = arith.mulf %1555, %1556 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
        %1558 = arith.addf %1554, %1557 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
        %1559 = affine.load %arg0[%arg3 * 8 + 3, %arg4 * 15 + 14] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<192 -> 194, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1560 = affine.load %arg2[2, 1] {partition_indices = [2, 1], timing = #hlscpp.t<431 -> 433, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1561 = arith.mulf %1559, %1560 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
        %1562 = arith.addf %1558, %1561 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
        %1563 = affine.load %arg2[1, 2] {partition_indices = [1, 2], timing = #hlscpp.t<436 -> 438, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1564 = arith.mulf %1540, %1563 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
        %1565 = arith.addf %1562, %1564 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
        %1566 = affine.load %arg2[0, 2] {partition_indices = [0, 2], timing = #hlscpp.t<441 -> 443, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1567 = arith.mulf %1543, %1566 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
        %1568 = arith.addf %1565, %1567 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
        %1569 = affine.load %arg2[2, 2] {partition_indices = [2, 2], timing = #hlscpp.t<446 -> 448, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1570 = arith.mulf %1547, %1569 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
        %1571 = arith.addf %1568, %1570 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
        affine.store %1571, %arg1[%arg3 * 8 + 2, %arg4 * 15 + 14] {partition_indices = [2, 14], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      } else {
        %1540 = affine.load %arg0[%arg3 * 8 + 2, %arg4 * 15 + 13] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<178 -> 180, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1541 = affine.load %arg2[1, 0] {partition_indices = [1, 0], timing = #hlscpp.t<410 -> 412, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1542 = arith.mulf %1540, %1541 {timing = #hlscpp.t<436 -> 440, 4, 1>} : f32
        %1543 = affine.load %arg0[%arg3 * 8 + 1, %arg4 * 15 + 13] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<179 -> 181, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1544 = affine.load %arg2[0, 0] {partition_indices = [0, 0], timing = #hlscpp.t<410 -> 412, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1545 = arith.mulf %1543, %1544 {timing = #hlscpp.t<436 -> 440, 4, 1>} : f32
        %1546 = arith.addf %1542, %1545 {timing = #hlscpp.t<440 -> 445, 5, 1>} : f32
        %1547 = affine.load %arg0[%arg3 * 8 + 3, %arg4 * 15 + 13] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<180 -> 182, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1548 = affine.load %arg2[2, 0] {partition_indices = [2, 0], timing = #hlscpp.t<415 -> 417, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1549 = arith.mulf %1547, %1548 {timing = #hlscpp.t<441 -> 445, 4, 1>} : f32
        %1550 = arith.addf %1546, %1549 {timing = #hlscpp.t<445 -> 450, 5, 1>} : f32
        %1551 = affine.load %arg0[%arg3 * 8 + 2, %arg4 * 15 + 14] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<181 -> 183, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1552 = affine.load %arg2[1, 1] {partition_indices = [1, 1], timing = #hlscpp.t<420 -> 422, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1553 = arith.mulf %1551, %1552 {timing = #hlscpp.t<446 -> 450, 4, 1>} : f32
        %1554 = arith.addf %1550, %1553 {timing = #hlscpp.t<450 -> 455, 5, 1>} : f32
        %1555 = affine.load %arg0[%arg3 * 8 + 1, %arg4 * 15 + 14] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<182 -> 184, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1556 = affine.load %arg2[0, 1] {partition_indices = [0, 1], timing = #hlscpp.t<425 -> 427, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1557 = arith.mulf %1555, %1556 {timing = #hlscpp.t<451 -> 455, 4, 1>} : f32
        %1558 = arith.addf %1554, %1557 {timing = #hlscpp.t<455 -> 460, 5, 1>} : f32
        %1559 = affine.load %arg0[%arg3 * 8 + 3, %arg4 * 15 + 14] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<183 -> 185, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1560 = affine.load %arg2[2, 1] {partition_indices = [2, 1], timing = #hlscpp.t<430 -> 432, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1561 = arith.mulf %1559, %1560 {timing = #hlscpp.t<456 -> 460, 4, 1>} : f32
        %1562 = arith.addf %1558, %1561 {timing = #hlscpp.t<460 -> 465, 5, 1>} : f32
        %1563 = affine.load %arg0[%arg3 * 8 + 2, %arg4 * 15 + 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<184 -> 186, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1564 = affine.load %arg2[1, 2] {partition_indices = [1, 2], timing = #hlscpp.t<435 -> 437, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1565 = arith.mulf %1563, %1564 {timing = #hlscpp.t<461 -> 465, 4, 1>} : f32
        %1566 = arith.addf %1562, %1565 {timing = #hlscpp.t<465 -> 470, 5, 1>} : f32
        %1567 = affine.load %arg0[%arg3 * 8 + 1, %arg4 * 15 + 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<185 -> 187, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1568 = affine.load %arg2[0, 2] {partition_indices = [0, 2], timing = #hlscpp.t<440 -> 442, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1569 = arith.mulf %1567, %1568 {timing = #hlscpp.t<466 -> 470, 4, 1>} : f32
        %1570 = arith.addf %1566, %1569 {timing = #hlscpp.t<470 -> 475, 5, 1>} : f32
        %1571 = affine.load %arg0[%arg3 * 8 + 3, %arg4 * 15 + 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<186 -> 188, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1572 = affine.load %arg2[2, 2] {partition_indices = [2, 2], timing = #hlscpp.t<445 -> 447, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1573 = arith.mulf %1571, %1572 {timing = #hlscpp.t<471 -> 475, 4, 1>} : f32
        %1574 = arith.addf %1570, %1573 {timing = #hlscpp.t<475 -> 480, 5, 1>} : f32
        affine.store %1574, %arg1[%arg3 * 8 + 2, %arg4 * 15 + 14] {partition_indices = [2, 14], timing = #hlscpp.t<480 -> 481, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      } {timing = #hlscpp.t<178 -> 482, 304, 0>}
      affine.if affine_set<(d0) : (d0 * 15 == 0)>(%arg4) {
        %1540 = affine.load %arg0[%arg3 * 8 + 3, %arg4 * 15 + 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<202 -> 204, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1541 = affine.load %arg2[1, 0] {partition_indices = [1, 0], timing = #hlscpp.t<413 -> 415, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1542 = arith.mulf %1540, %1541 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
        %1543 = affine.load %arg0[%arg3 * 8 + 2, %arg4 * 15 + 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<203 -> 205, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1544 = affine.load %arg2[0, 0] {partition_indices = [0, 0], timing = #hlscpp.t<413 -> 415, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1545 = arith.mulf %1543, %1544 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
        %1546 = arith.addf %1542, %1545 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
        %1547 = affine.load %arg0[%arg3 * 8 + 4, %arg4 * 15 + 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<204 -> 206, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1548 = affine.load %arg2[2, 0] {partition_indices = [2, 0], timing = #hlscpp.t<418 -> 420, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1549 = arith.mulf %1547, %1548 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
        %1550 = arith.addf %1546, %1549 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
        %1551 = affine.load %arg0[%arg3 * 8 + 3, %arg4 * 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<205 -> 207, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1552 = affine.load %arg2[1, 1] {partition_indices = [1, 1], timing = #hlscpp.t<423 -> 425, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1553 = arith.mulf %1551, %1552 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
        %1554 = arith.addf %1550, %1553 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
        %1555 = affine.load %arg0[%arg3 * 8 + 2, %arg4 * 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<206 -> 208, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1556 = affine.load %arg2[0, 1] {partition_indices = [0, 1], timing = #hlscpp.t<428 -> 430, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1557 = arith.mulf %1555, %1556 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
        %1558 = arith.addf %1554, %1557 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
        %1559 = affine.load %arg0[%arg3 * 8 + 4, %arg4 * 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<207 -> 209, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1560 = affine.load %arg2[2, 1] {partition_indices = [2, 1], timing = #hlscpp.t<433 -> 435, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1561 = arith.mulf %1559, %1560 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
        %1562 = arith.addf %1558, %1561 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
        %1563 = affine.load %arg2[1, 2] {partition_indices = [1, 2], timing = #hlscpp.t<438 -> 440, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1564 = arith.mulf %1540, %1563 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
        %1565 = arith.addf %1562, %1564 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
        %1566 = affine.load %arg2[0, 2] {partition_indices = [0, 2], timing = #hlscpp.t<443 -> 445, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1567 = arith.mulf %1543, %1566 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
        %1568 = arith.addf %1565, %1567 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
        %1569 = affine.load %arg2[2, 2] {partition_indices = [2, 2], timing = #hlscpp.t<448 -> 450, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1570 = arith.mulf %1547, %1569 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
        %1571 = arith.addf %1568, %1570 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
        affine.store %1571, %arg1[%arg3 * 8 + 3, %arg4 * 15] {partition_indices = [3, 0], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      } else {
        %1540 = affine.load %arg0[%arg3 * 8 + 3, %arg4 * 15 - 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<193 -> 195, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1541 = affine.load %arg2[1, 0] {partition_indices = [1, 0], timing = #hlscpp.t<412 -> 414, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1542 = arith.mulf %1540, %1541 {timing = #hlscpp.t<436 -> 440, 4, 1>} : f32
        %1543 = affine.load %arg0[%arg3 * 8 + 2, %arg4 * 15 - 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<194 -> 196, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1544 = affine.load %arg2[0, 0] {partition_indices = [0, 0], timing = #hlscpp.t<412 -> 414, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1545 = arith.mulf %1543, %1544 {timing = #hlscpp.t<436 -> 440, 4, 1>} : f32
        %1546 = arith.addf %1542, %1545 {timing = #hlscpp.t<440 -> 445, 5, 1>} : f32
        %1547 = affine.load %arg0[%arg3 * 8 + 4, %arg4 * 15 - 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<195 -> 197, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1548 = affine.load %arg2[2, 0] {partition_indices = [2, 0], timing = #hlscpp.t<417 -> 419, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1549 = arith.mulf %1547, %1548 {timing = #hlscpp.t<441 -> 445, 4, 1>} : f32
        %1550 = arith.addf %1546, %1549 {timing = #hlscpp.t<445 -> 450, 5, 1>} : f32
        %1551 = affine.load %arg0[%arg3 * 8 + 3, %arg4 * 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<196 -> 198, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1552 = affine.load %arg2[1, 1] {partition_indices = [1, 1], timing = #hlscpp.t<422 -> 424, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1553 = arith.mulf %1551, %1552 {timing = #hlscpp.t<446 -> 450, 4, 1>} : f32
        %1554 = arith.addf %1550, %1553 {timing = #hlscpp.t<450 -> 455, 5, 1>} : f32
        %1555 = affine.load %arg0[%arg3 * 8 + 2, %arg4 * 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<197 -> 199, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1556 = affine.load %arg2[0, 1] {partition_indices = [0, 1], timing = #hlscpp.t<427 -> 429, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1557 = arith.mulf %1555, %1556 {timing = #hlscpp.t<451 -> 455, 4, 1>} : f32
        %1558 = arith.addf %1554, %1557 {timing = #hlscpp.t<455 -> 460, 5, 1>} : f32
        %1559 = affine.load %arg0[%arg3 * 8 + 4, %arg4 * 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<198 -> 200, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1560 = affine.load %arg2[2, 1] {partition_indices = [2, 1], timing = #hlscpp.t<432 -> 434, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1561 = arith.mulf %1559, %1560 {timing = #hlscpp.t<456 -> 460, 4, 1>} : f32
        %1562 = arith.addf %1558, %1561 {timing = #hlscpp.t<460 -> 465, 5, 1>} : f32
        %1563 = affine.load %arg0[%arg3 * 8 + 3, %arg4 * 15 + 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<199 -> 201, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1564 = affine.load %arg2[1, 2] {partition_indices = [1, 2], timing = #hlscpp.t<437 -> 439, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1565 = arith.mulf %1563, %1564 {timing = #hlscpp.t<461 -> 465, 4, 1>} : f32
        %1566 = arith.addf %1562, %1565 {timing = #hlscpp.t<465 -> 470, 5, 1>} : f32
        %1567 = affine.load %arg0[%arg3 * 8 + 2, %arg4 * 15 + 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<200 -> 202, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1568 = affine.load %arg2[0, 2] {partition_indices = [0, 2], timing = #hlscpp.t<442 -> 444, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1569 = arith.mulf %1567, %1568 {timing = #hlscpp.t<466 -> 470, 4, 1>} : f32
        %1570 = arith.addf %1566, %1569 {timing = #hlscpp.t<470 -> 475, 5, 1>} : f32
        %1571 = affine.load %arg0[%arg3 * 8 + 4, %arg4 * 15 + 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<201 -> 203, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1572 = affine.load %arg2[2, 2] {partition_indices = [2, 2], timing = #hlscpp.t<447 -> 449, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1573 = arith.mulf %1571, %1572 {timing = #hlscpp.t<471 -> 475, 4, 1>} : f32
        %1574 = arith.addf %1570, %1573 {timing = #hlscpp.t<475 -> 480, 5, 1>} : f32
        affine.store %1574, %arg1[%arg3 * 8 + 3, %arg4 * 15] {partition_indices = [3, 0], timing = #hlscpp.t<480 -> 481, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      } {timing = #hlscpp.t<193 -> 482, 289, 0>}
      %528 = affine.load %arg0[%arg3 * 8 + 3, %arg4 * 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<208 -> 210, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %529 = affine.load %arg2[1, 0] {partition_indices = [1, 0], timing = #hlscpp.t<426 -> 428, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
      %530 = arith.mulf %528, %529 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %531 = affine.load %arg0[%arg3 * 8 + 2, %arg4 * 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<209 -> 211, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %532 = affine.load %arg2[0, 0] {partition_indices = [0, 0], timing = #hlscpp.t<426 -> 428, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
      %533 = arith.mulf %531, %532 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %534 = arith.addf %530, %533 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
      %535 = affine.load %arg0[%arg3 * 8 + 4, %arg4 * 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<210 -> 212, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %536 = affine.load %arg2[2, 0] {partition_indices = [2, 0], timing = #hlscpp.t<431 -> 433, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
      %537 = arith.mulf %535, %536 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
      %538 = arith.addf %534, %537 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
      %539 = affine.load %arg0[%arg3 * 8 + 3, %arg4 * 15 + 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<211 -> 213, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %540 = affine.load %arg2[1, 1] {partition_indices = [1, 1], timing = #hlscpp.t<436 -> 438, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
      %541 = arith.mulf %539, %540 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
      %542 = arith.addf %538, %541 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
      %543 = affine.load %arg0[%arg3 * 8 + 2, %arg4 * 15 + 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<212 -> 214, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %544 = affine.load %arg2[0, 1] {partition_indices = [0, 1], timing = #hlscpp.t<441 -> 443, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
      %545 = arith.mulf %543, %544 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
      %546 = arith.addf %542, %545 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
      %547 = affine.load %arg0[%arg3 * 8 + 4, %arg4 * 15 + 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<213 -> 215, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %548 = affine.load %arg2[2, 1] {partition_indices = [2, 1], timing = #hlscpp.t<446 -> 448, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
      %549 = arith.mulf %547, %548 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
      %550 = arith.addf %546, %549 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
      %551 = affine.load %arg2[1, 2] {partition_indices = [1, 2], timing = #hlscpp.t<451 -> 453, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
      %552 = arith.mulf %304, %551 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
      %553 = arith.addf %550, %552 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
      %554 = affine.load %arg2[0, 2] {partition_indices = [0, 2], timing = #hlscpp.t<456 -> 458, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
      %555 = arith.mulf %31, %554 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
      %556 = arith.addf %553, %555 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
      %557 = affine.load %arg0[%arg3 * 8 + 4, %arg4 * 15 + 2] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<214 -> 216, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %558 = affine.load %arg2[2, 2] {partition_indices = [2, 2], timing = #hlscpp.t<461 -> 463, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
      %559 = arith.mulf %557, %558 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
      %560 = arith.addf %556, %559 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
      affine.store %560, %arg1[%arg3 * 8 + 3, %arg4 * 15 + 1] {partition_indices = [3, 1], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      %561 = arith.mulf %539, %529 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %562 = arith.mulf %543, %532 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %563 = arith.addf %561, %562 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
      %564 = arith.mulf %547, %536 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
      %565 = arith.addf %563, %564 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
      %566 = arith.mulf %304, %540 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
      %567 = arith.addf %565, %566 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
      %568 = arith.mulf %31, %544 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
      %569 = arith.addf %567, %568 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
      %570 = arith.mulf %557, %548 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
      %571 = arith.addf %569, %570 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
      %572 = arith.mulf %323, %551 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
      %573 = arith.addf %571, %572 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
      %574 = arith.mulf %52, %554 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
      %575 = arith.addf %573, %574 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
      %576 = affine.load %arg0[%arg3 * 8 + 4, %arg4 * 15 + 3] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<215 -> 217, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %577 = arith.mulf %576, %558 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
      %578 = arith.addf %575, %577 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
      affine.store %578, %arg1[%arg3 * 8 + 3, %arg4 * 15 + 2] {partition_indices = [3, 2], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      %579 = arith.mulf %304, %529 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %580 = arith.mulf %31, %532 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %581 = arith.addf %579, %580 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
      %582 = arith.mulf %557, %536 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
      %583 = arith.addf %581, %582 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
      %584 = arith.mulf %323, %540 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
      %585 = arith.addf %583, %584 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
      %586 = arith.mulf %52, %544 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
      %587 = arith.addf %585, %586 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
      %588 = arith.mulf %576, %548 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
      %589 = arith.addf %587, %588 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
      %590 = arith.mulf %341, %551 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
      %591 = arith.addf %589, %590 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
      %592 = arith.mulf %72, %554 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
      %593 = arith.addf %591, %592 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
      %594 = affine.load %arg0[%arg3 * 8 + 4, %arg4 * 15 + 4] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<216 -> 218, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %595 = arith.mulf %594, %558 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
      %596 = arith.addf %593, %595 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
      affine.store %596, %arg1[%arg3 * 8 + 3, %arg4 * 15 + 3] {partition_indices = [3, 3], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      %597 = arith.mulf %323, %529 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %598 = arith.mulf %52, %532 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %599 = arith.addf %597, %598 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
      %600 = arith.mulf %576, %536 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
      %601 = arith.addf %599, %600 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
      %602 = arith.mulf %341, %540 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
      %603 = arith.addf %601, %602 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
      %604 = arith.mulf %72, %544 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
      %605 = arith.addf %603, %604 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
      %606 = arith.mulf %594, %548 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
      %607 = arith.addf %605, %606 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
      %608 = arith.mulf %359, %551 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
      %609 = arith.addf %607, %608 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
      %610 = arith.mulf %92, %554 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
      %611 = arith.addf %609, %610 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
      %612 = affine.load %arg0[%arg3 * 8 + 4, %arg4 * 15 + 5] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<217 -> 219, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %613 = arith.mulf %612, %558 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
      %614 = arith.addf %611, %613 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
      affine.store %614, %arg1[%arg3 * 8 + 3, %arg4 * 15 + 4] {partition_indices = [3, 4], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      %615 = arith.mulf %341, %529 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %616 = arith.mulf %72, %532 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %617 = arith.addf %615, %616 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
      %618 = arith.mulf %594, %536 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
      %619 = arith.addf %617, %618 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
      %620 = arith.mulf %359, %540 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
      %621 = arith.addf %619, %620 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
      %622 = arith.mulf %92, %544 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
      %623 = arith.addf %621, %622 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
      %624 = arith.mulf %612, %548 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
      %625 = arith.addf %623, %624 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
      %626 = arith.mulf %377, %551 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
      %627 = arith.addf %625, %626 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
      %628 = arith.mulf %112, %554 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
      %629 = arith.addf %627, %628 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
      %630 = affine.load %arg0[%arg3 * 8 + 4, %arg4 * 15 + 6] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<218 -> 220, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %631 = arith.mulf %630, %558 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
      %632 = arith.addf %629, %631 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
      affine.store %632, %arg1[%arg3 * 8 + 3, %arg4 * 15 + 5] {partition_indices = [3, 5], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      %633 = arith.mulf %359, %529 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %634 = arith.mulf %92, %532 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %635 = arith.addf %633, %634 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
      %636 = arith.mulf %612, %536 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
      %637 = arith.addf %635, %636 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
      %638 = arith.mulf %377, %540 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
      %639 = arith.addf %637, %638 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
      %640 = arith.mulf %112, %544 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
      %641 = arith.addf %639, %640 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
      %642 = arith.mulf %630, %548 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
      %643 = arith.addf %641, %642 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
      %644 = arith.mulf %395, %551 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
      %645 = arith.addf %643, %644 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
      %646 = arith.mulf %132, %554 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
      %647 = arith.addf %645, %646 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
      %648 = affine.load %arg0[%arg3 * 8 + 4, %arg4 * 15 + 7] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<219 -> 221, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %649 = arith.mulf %648, %558 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
      %650 = arith.addf %647, %649 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
      affine.store %650, %arg1[%arg3 * 8 + 3, %arg4 * 15 + 6] {partition_indices = [3, 6], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      %651 = arith.mulf %377, %529 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %652 = arith.mulf %112, %532 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %653 = arith.addf %651, %652 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
      %654 = arith.mulf %630, %536 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
      %655 = arith.addf %653, %654 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
      %656 = arith.mulf %395, %540 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
      %657 = arith.addf %655, %656 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
      %658 = arith.mulf %132, %544 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
      %659 = arith.addf %657, %658 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
      %660 = arith.mulf %648, %548 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
      %661 = arith.addf %659, %660 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
      %662 = arith.mulf %413, %551 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
      %663 = arith.addf %661, %662 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
      %664 = arith.mulf %152, %554 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
      %665 = arith.addf %663, %664 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
      %666 = affine.load %arg0[%arg3 * 8 + 4, %arg4 * 15 + 8] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<220 -> 222, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %667 = arith.mulf %666, %558 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
      %668 = arith.addf %665, %667 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
      affine.store %668, %arg1[%arg3 * 8 + 3, %arg4 * 15 + 7] {partition_indices = [3, 7], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      %669 = arith.mulf %395, %529 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %670 = arith.mulf %132, %532 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %671 = arith.addf %669, %670 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
      %672 = arith.mulf %648, %536 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
      %673 = arith.addf %671, %672 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
      %674 = arith.mulf %413, %540 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
      %675 = arith.addf %673, %674 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
      %676 = arith.mulf %152, %544 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
      %677 = arith.addf %675, %676 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
      %678 = arith.mulf %666, %548 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
      %679 = arith.addf %677, %678 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
      %680 = arith.mulf %431, %551 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
      %681 = arith.addf %679, %680 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
      %682 = arith.mulf %172, %554 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
      %683 = arith.addf %681, %682 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
      %684 = affine.load %arg0[%arg3 * 8 + 4, %arg4 * 15 + 9] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<221 -> 223, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %685 = arith.mulf %684, %558 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
      %686 = arith.addf %683, %685 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
      affine.store %686, %arg1[%arg3 * 8 + 3, %arg4 * 15 + 8] {partition_indices = [3, 8], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      %687 = arith.mulf %413, %529 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %688 = arith.mulf %152, %532 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %689 = arith.addf %687, %688 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
      %690 = arith.mulf %666, %536 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
      %691 = arith.addf %689, %690 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
      %692 = arith.mulf %431, %540 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
      %693 = arith.addf %691, %692 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
      %694 = arith.mulf %172, %544 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
      %695 = arith.addf %693, %694 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
      %696 = arith.mulf %684, %548 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
      %697 = arith.addf %695, %696 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
      %698 = arith.mulf %449, %551 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
      %699 = arith.addf %697, %698 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
      %700 = arith.mulf %192, %554 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
      %701 = arith.addf %699, %700 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
      %702 = affine.load %arg0[%arg3 * 8 + 4, %arg4 * 15 + 10] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<222 -> 224, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %703 = arith.mulf %702, %558 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
      %704 = arith.addf %701, %703 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
      affine.store %704, %arg1[%arg3 * 8 + 3, %arg4 * 15 + 9] {partition_indices = [3, 9], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      %705 = arith.mulf %431, %529 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %706 = arith.mulf %172, %532 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %707 = arith.addf %705, %706 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
      %708 = arith.mulf %684, %536 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
      %709 = arith.addf %707, %708 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
      %710 = arith.mulf %449, %540 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
      %711 = arith.addf %709, %710 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
      %712 = arith.mulf %192, %544 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
      %713 = arith.addf %711, %712 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
      %714 = arith.mulf %702, %548 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
      %715 = arith.addf %713, %714 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
      %716 = arith.mulf %467, %551 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
      %717 = arith.addf %715, %716 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
      %718 = arith.mulf %212, %554 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
      %719 = arith.addf %717, %718 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
      %720 = affine.load %arg0[%arg3 * 8 + 4, %arg4 * 15 + 11] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<223 -> 225, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %721 = arith.mulf %720, %558 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
      %722 = arith.addf %719, %721 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
      affine.store %722, %arg1[%arg3 * 8 + 3, %arg4 * 15 + 10] {partition_indices = [3, 10], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      %723 = arith.mulf %449, %529 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %724 = arith.mulf %192, %532 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %725 = arith.addf %723, %724 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
      %726 = arith.mulf %702, %536 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
      %727 = arith.addf %725, %726 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
      %728 = arith.mulf %467, %540 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
      %729 = arith.addf %727, %728 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
      %730 = arith.mulf %212, %544 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
      %731 = arith.addf %729, %730 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
      %732 = arith.mulf %720, %548 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
      %733 = arith.addf %731, %732 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
      %734 = arith.mulf %485, %551 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
      %735 = arith.addf %733, %734 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
      %736 = arith.mulf %232, %554 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
      %737 = arith.addf %735, %736 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
      %738 = affine.load %arg0[%arg3 * 8 + 4, %arg4 * 15 + 12] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<224 -> 226, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %739 = arith.mulf %738, %558 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
      %740 = arith.addf %737, %739 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
      affine.store %740, %arg1[%arg3 * 8 + 3, %arg4 * 15 + 11] {partition_indices = [3, 11], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      %741 = arith.mulf %467, %529 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %742 = arith.mulf %212, %532 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %743 = arith.addf %741, %742 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
      %744 = arith.mulf %720, %536 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
      %745 = arith.addf %743, %744 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
      %746 = arith.mulf %485, %540 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
      %747 = arith.addf %745, %746 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
      %748 = arith.mulf %232, %544 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
      %749 = arith.addf %747, %748 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
      %750 = arith.mulf %738, %548 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
      %751 = arith.addf %749, %750 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
      %752 = affine.load %arg0[%arg3 * 8 + 3, %arg4 * 15 + 13] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<225 -> 227, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %753 = arith.mulf %752, %551 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
      %754 = arith.addf %751, %753 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
      %755 = affine.load %arg0[%arg3 * 8 + 2, %arg4 * 15 + 13] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<226 -> 228, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %756 = arith.mulf %755, %554 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
      %757 = arith.addf %754, %756 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
      %758 = affine.load %arg0[%arg3 * 8 + 4, %arg4 * 15 + 13] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<227 -> 229, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %759 = arith.mulf %758, %558 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
      %760 = arith.addf %757, %759 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
      affine.store %760, %arg1[%arg3 * 8 + 3, %arg4 * 15 + 12] {partition_indices = [3, 12], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      %761 = arith.mulf %485, %529 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %762 = arith.mulf %232, %532 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %763 = arith.addf %761, %762 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
      %764 = arith.mulf %738, %536 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
      %765 = arith.addf %763, %764 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
      %766 = arith.mulf %752, %540 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
      %767 = arith.addf %765, %766 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
      %768 = arith.mulf %755, %544 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
      %769 = arith.addf %767, %768 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
      %770 = arith.mulf %758, %548 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
      %771 = arith.addf %769, %770 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
      %772 = affine.load %arg0[%arg3 * 8 + 3, %arg4 * 15 + 14] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<228 -> 230, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %773 = arith.mulf %772, %551 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
      %774 = arith.addf %771, %773 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
      %775 = affine.load %arg0[%arg3 * 8 + 2, %arg4 * 15 + 14] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<229 -> 231, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %776 = arith.mulf %775, %554 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
      %777 = arith.addf %774, %776 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
      %778 = affine.load %arg0[%arg3 * 8 + 4, %arg4 * 15 + 14] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<230 -> 232, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %779 = arith.mulf %778, %558 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
      %780 = arith.addf %777, %779 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
      affine.store %780, %arg1[%arg3 * 8 + 3, %arg4 * 15 + 13] {partition_indices = [3, 13], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      affine.if affine_set<(d0) : (d0 * 15 - 1065 == 0)>(%arg4) {
        %1540 = affine.load %arg0[%arg3 * 8 + 3, %arg4 * 15 + 13] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<240 -> 242, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1541 = affine.load %arg2[1, 0] {partition_indices = [1, 0], timing = #hlscpp.t<415 -> 417, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1542 = arith.mulf %1540, %1541 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
        %1543 = affine.load %arg0[%arg3 * 8 + 2, %arg4 * 15 + 13] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<241 -> 243, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1544 = affine.load %arg2[0, 0] {partition_indices = [0, 0], timing = #hlscpp.t<415 -> 417, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1545 = arith.mulf %1543, %1544 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
        %1546 = arith.addf %1542, %1545 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
        %1547 = affine.load %arg0[%arg3 * 8 + 4, %arg4 * 15 + 13] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<242 -> 244, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1548 = affine.load %arg2[2, 0] {partition_indices = [2, 0], timing = #hlscpp.t<420 -> 422, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1549 = arith.mulf %1547, %1548 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
        %1550 = arith.addf %1546, %1549 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
        %1551 = affine.load %arg0[%arg3 * 8 + 3, %arg4 * 15 + 14] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<243 -> 245, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1552 = affine.load %arg2[1, 1] {partition_indices = [1, 1], timing = #hlscpp.t<425 -> 427, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1553 = arith.mulf %1551, %1552 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
        %1554 = arith.addf %1550, %1553 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
        %1555 = affine.load %arg0[%arg3 * 8 + 2, %arg4 * 15 + 14] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<244 -> 246, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1556 = affine.load %arg2[0, 1] {partition_indices = [0, 1], timing = #hlscpp.t<430 -> 432, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1557 = arith.mulf %1555, %1556 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
        %1558 = arith.addf %1554, %1557 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
        %1559 = affine.load %arg0[%arg3 * 8 + 4, %arg4 * 15 + 14] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<245 -> 247, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1560 = affine.load %arg2[2, 1] {partition_indices = [2, 1], timing = #hlscpp.t<435 -> 437, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1561 = arith.mulf %1559, %1560 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
        %1562 = arith.addf %1558, %1561 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
        %1563 = affine.load %arg2[1, 2] {partition_indices = [1, 2], timing = #hlscpp.t<440 -> 442, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1564 = arith.mulf %1540, %1563 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
        %1565 = arith.addf %1562, %1564 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
        %1566 = affine.load %arg2[0, 2] {partition_indices = [0, 2], timing = #hlscpp.t<445 -> 447, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1567 = arith.mulf %1543, %1566 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
        %1568 = arith.addf %1565, %1567 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
        %1569 = affine.load %arg2[2, 2] {partition_indices = [2, 2], timing = #hlscpp.t<450 -> 452, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1570 = arith.mulf %1547, %1569 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
        %1571 = arith.addf %1568, %1570 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
        affine.store %1571, %arg1[%arg3 * 8 + 3, %arg4 * 15 + 14] {partition_indices = [3, 14], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      } else {
        %1540 = affine.load %arg0[%arg3 * 8 + 3, %arg4 * 15 + 13] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<231 -> 233, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1541 = affine.load %arg2[1, 0] {partition_indices = [1, 0], timing = #hlscpp.t<414 -> 416, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1542 = arith.mulf %1540, %1541 {timing = #hlscpp.t<436 -> 440, 4, 1>} : f32
        %1543 = affine.load %arg0[%arg3 * 8 + 2, %arg4 * 15 + 13] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<232 -> 234, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1544 = affine.load %arg2[0, 0] {partition_indices = [0, 0], timing = #hlscpp.t<414 -> 416, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1545 = arith.mulf %1543, %1544 {timing = #hlscpp.t<436 -> 440, 4, 1>} : f32
        %1546 = arith.addf %1542, %1545 {timing = #hlscpp.t<440 -> 445, 5, 1>} : f32
        %1547 = affine.load %arg0[%arg3 * 8 + 4, %arg4 * 15 + 13] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<233 -> 235, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1548 = affine.load %arg2[2, 0] {partition_indices = [2, 0], timing = #hlscpp.t<419 -> 421, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1549 = arith.mulf %1547, %1548 {timing = #hlscpp.t<441 -> 445, 4, 1>} : f32
        %1550 = arith.addf %1546, %1549 {timing = #hlscpp.t<445 -> 450, 5, 1>} : f32
        %1551 = affine.load %arg0[%arg3 * 8 + 3, %arg4 * 15 + 14] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<234 -> 236, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1552 = affine.load %arg2[1, 1] {partition_indices = [1, 1], timing = #hlscpp.t<424 -> 426, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1553 = arith.mulf %1551, %1552 {timing = #hlscpp.t<446 -> 450, 4, 1>} : f32
        %1554 = arith.addf %1550, %1553 {timing = #hlscpp.t<450 -> 455, 5, 1>} : f32
        %1555 = affine.load %arg0[%arg3 * 8 + 2, %arg4 * 15 + 14] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<235 -> 237, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1556 = affine.load %arg2[0, 1] {partition_indices = [0, 1], timing = #hlscpp.t<429 -> 431, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1557 = arith.mulf %1555, %1556 {timing = #hlscpp.t<451 -> 455, 4, 1>} : f32
        %1558 = arith.addf %1554, %1557 {timing = #hlscpp.t<455 -> 460, 5, 1>} : f32
        %1559 = affine.load %arg0[%arg3 * 8 + 4, %arg4 * 15 + 14] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<236 -> 238, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1560 = affine.load %arg2[2, 1] {partition_indices = [2, 1], timing = #hlscpp.t<434 -> 436, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1561 = arith.mulf %1559, %1560 {timing = #hlscpp.t<456 -> 460, 4, 1>} : f32
        %1562 = arith.addf %1558, %1561 {timing = #hlscpp.t<460 -> 465, 5, 1>} : f32
        %1563 = affine.load %arg0[%arg3 * 8 + 3, %arg4 * 15 + 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<237 -> 239, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1564 = affine.load %arg2[1, 2] {partition_indices = [1, 2], timing = #hlscpp.t<439 -> 441, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1565 = arith.mulf %1563, %1564 {timing = #hlscpp.t<461 -> 465, 4, 1>} : f32
        %1566 = arith.addf %1562, %1565 {timing = #hlscpp.t<465 -> 470, 5, 1>} : f32
        %1567 = affine.load %arg0[%arg3 * 8 + 2, %arg4 * 15 + 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<238 -> 240, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1568 = affine.load %arg2[0, 2] {partition_indices = [0, 2], timing = #hlscpp.t<444 -> 446, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1569 = arith.mulf %1567, %1568 {timing = #hlscpp.t<466 -> 470, 4, 1>} : f32
        %1570 = arith.addf %1566, %1569 {timing = #hlscpp.t<470 -> 475, 5, 1>} : f32
        %1571 = affine.load %arg0[%arg3 * 8 + 4, %arg4 * 15 + 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<239 -> 241, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1572 = affine.load %arg2[2, 2] {partition_indices = [2, 2], timing = #hlscpp.t<449 -> 451, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1573 = arith.mulf %1571, %1572 {timing = #hlscpp.t<471 -> 475, 4, 1>} : f32
        %1574 = arith.addf %1570, %1573 {timing = #hlscpp.t<475 -> 480, 5, 1>} : f32
        affine.store %1574, %arg1[%arg3 * 8 + 3, %arg4 * 15 + 14] {partition_indices = [3, 14], timing = #hlscpp.t<480 -> 481, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      } {timing = #hlscpp.t<231 -> 482, 251, 0>}
      affine.if affine_set<(d0) : (d0 * 15 == 0)>(%arg4) {
        %1540 = affine.load %arg0[%arg3 * 8 + 4, %arg4 * 15 + 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<255 -> 257, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1541 = affine.load %arg2[1, 0] {partition_indices = [1, 0], timing = #hlscpp.t<417 -> 419, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1542 = arith.mulf %1540, %1541 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
        %1543 = affine.load %arg0[%arg3 * 8 + 3, %arg4 * 15 + 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<256 -> 258, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1544 = affine.load %arg2[0, 0] {partition_indices = [0, 0], timing = #hlscpp.t<417 -> 419, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1545 = arith.mulf %1543, %1544 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
        %1546 = arith.addf %1542, %1545 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
        %1547 = affine.load %arg0[%arg3 * 8 + 5, %arg4 * 15 + 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<257 -> 259, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1548 = affine.load %arg2[2, 0] {partition_indices = [2, 0], timing = #hlscpp.t<422 -> 424, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1549 = arith.mulf %1547, %1548 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
        %1550 = arith.addf %1546, %1549 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
        %1551 = affine.load %arg0[%arg3 * 8 + 4, %arg4 * 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<258 -> 260, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1552 = affine.load %arg2[1, 1] {partition_indices = [1, 1], timing = #hlscpp.t<427 -> 429, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1553 = arith.mulf %1551, %1552 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
        %1554 = arith.addf %1550, %1553 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
        %1555 = affine.load %arg0[%arg3 * 8 + 3, %arg4 * 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<259 -> 261, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1556 = affine.load %arg2[0, 1] {partition_indices = [0, 1], timing = #hlscpp.t<432 -> 434, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1557 = arith.mulf %1555, %1556 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
        %1558 = arith.addf %1554, %1557 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
        %1559 = affine.load %arg0[%arg3 * 8 + 5, %arg4 * 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<260 -> 262, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1560 = affine.load %arg2[2, 1] {partition_indices = [2, 1], timing = #hlscpp.t<437 -> 439, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1561 = arith.mulf %1559, %1560 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
        %1562 = arith.addf %1558, %1561 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
        %1563 = affine.load %arg2[1, 2] {partition_indices = [1, 2], timing = #hlscpp.t<442 -> 444, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1564 = arith.mulf %1540, %1563 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
        %1565 = arith.addf %1562, %1564 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
        %1566 = affine.load %arg2[0, 2] {partition_indices = [0, 2], timing = #hlscpp.t<447 -> 449, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1567 = arith.mulf %1543, %1566 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
        %1568 = arith.addf %1565, %1567 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
        %1569 = affine.load %arg2[2, 2] {partition_indices = [2, 2], timing = #hlscpp.t<452 -> 454, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1570 = arith.mulf %1547, %1569 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
        %1571 = arith.addf %1568, %1570 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
        affine.store %1571, %arg1[%arg3 * 8 + 4, %arg4 * 15] {partition_indices = [4, 0], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      } else {
        %1540 = affine.load %arg0[%arg3 * 8 + 4, %arg4 * 15 - 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<246 -> 248, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1541 = affine.load %arg2[1, 0] {partition_indices = [1, 0], timing = #hlscpp.t<416 -> 418, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1542 = arith.mulf %1540, %1541 {timing = #hlscpp.t<436 -> 440, 4, 1>} : f32
        %1543 = affine.load %arg0[%arg3 * 8 + 3, %arg4 * 15 - 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<247 -> 249, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1544 = affine.load %arg2[0, 0] {partition_indices = [0, 0], timing = #hlscpp.t<416 -> 418, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1545 = arith.mulf %1543, %1544 {timing = #hlscpp.t<436 -> 440, 4, 1>} : f32
        %1546 = arith.addf %1542, %1545 {timing = #hlscpp.t<440 -> 445, 5, 1>} : f32
        %1547 = affine.load %arg0[%arg3 * 8 + 5, %arg4 * 15 - 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<248 -> 250, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1548 = affine.load %arg2[2, 0] {partition_indices = [2, 0], timing = #hlscpp.t<421 -> 423, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1549 = arith.mulf %1547, %1548 {timing = #hlscpp.t<441 -> 445, 4, 1>} : f32
        %1550 = arith.addf %1546, %1549 {timing = #hlscpp.t<445 -> 450, 5, 1>} : f32
        %1551 = affine.load %arg0[%arg3 * 8 + 4, %arg4 * 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<249 -> 251, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1552 = affine.load %arg2[1, 1] {partition_indices = [1, 1], timing = #hlscpp.t<426 -> 428, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1553 = arith.mulf %1551, %1552 {timing = #hlscpp.t<446 -> 450, 4, 1>} : f32
        %1554 = arith.addf %1550, %1553 {timing = #hlscpp.t<450 -> 455, 5, 1>} : f32
        %1555 = affine.load %arg0[%arg3 * 8 + 3, %arg4 * 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<250 -> 252, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1556 = affine.load %arg2[0, 1] {partition_indices = [0, 1], timing = #hlscpp.t<431 -> 433, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1557 = arith.mulf %1555, %1556 {timing = #hlscpp.t<451 -> 455, 4, 1>} : f32
        %1558 = arith.addf %1554, %1557 {timing = #hlscpp.t<455 -> 460, 5, 1>} : f32
        %1559 = affine.load %arg0[%arg3 * 8 + 5, %arg4 * 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<251 -> 253, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1560 = affine.load %arg2[2, 1] {partition_indices = [2, 1], timing = #hlscpp.t<436 -> 438, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1561 = arith.mulf %1559, %1560 {timing = #hlscpp.t<456 -> 460, 4, 1>} : f32
        %1562 = arith.addf %1558, %1561 {timing = #hlscpp.t<460 -> 465, 5, 1>} : f32
        %1563 = affine.load %arg0[%arg3 * 8 + 4, %arg4 * 15 + 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<252 -> 254, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1564 = affine.load %arg2[1, 2] {partition_indices = [1, 2], timing = #hlscpp.t<441 -> 443, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1565 = arith.mulf %1563, %1564 {timing = #hlscpp.t<461 -> 465, 4, 1>} : f32
        %1566 = arith.addf %1562, %1565 {timing = #hlscpp.t<465 -> 470, 5, 1>} : f32
        %1567 = affine.load %arg0[%arg3 * 8 + 3, %arg4 * 15 + 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<253 -> 255, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1568 = affine.load %arg2[0, 2] {partition_indices = [0, 2], timing = #hlscpp.t<446 -> 448, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1569 = arith.mulf %1567, %1568 {timing = #hlscpp.t<466 -> 470, 4, 1>} : f32
        %1570 = arith.addf %1566, %1569 {timing = #hlscpp.t<470 -> 475, 5, 1>} : f32
        %1571 = affine.load %arg0[%arg3 * 8 + 5, %arg4 * 15 + 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<254 -> 256, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1572 = affine.load %arg2[2, 2] {partition_indices = [2, 2], timing = #hlscpp.t<451 -> 453, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1573 = arith.mulf %1571, %1572 {timing = #hlscpp.t<471 -> 475, 4, 1>} : f32
        %1574 = arith.addf %1570, %1573 {timing = #hlscpp.t<475 -> 480, 5, 1>} : f32
        affine.store %1574, %arg1[%arg3 * 8 + 4, %arg4 * 15] {partition_indices = [4, 0], timing = #hlscpp.t<480 -> 481, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      } {timing = #hlscpp.t<246 -> 482, 236, 0>}
      %781 = affine.load %arg0[%arg3 * 8 + 4, %arg4 * 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<261 -> 263, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %782 = affine.load %arg2[1, 0] {partition_indices = [1, 0], timing = #hlscpp.t<426 -> 428, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
      %783 = arith.mulf %781, %782 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %784 = affine.load %arg0[%arg3 * 8 + 3, %arg4 * 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<262 -> 264, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %785 = affine.load %arg2[0, 0] {partition_indices = [0, 0], timing = #hlscpp.t<426 -> 428, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
      %786 = arith.mulf %784, %785 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %787 = arith.addf %783, %786 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
      %788 = affine.load %arg0[%arg3 * 8 + 5, %arg4 * 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<263 -> 265, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %789 = affine.load %arg2[2, 0] {partition_indices = [2, 0], timing = #hlscpp.t<431 -> 433, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
      %790 = arith.mulf %788, %789 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
      %791 = arith.addf %787, %790 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
      %792 = affine.load %arg0[%arg3 * 8 + 4, %arg4 * 15 + 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<264 -> 266, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %793 = affine.load %arg2[1, 1] {partition_indices = [1, 1], timing = #hlscpp.t<436 -> 438, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
      %794 = arith.mulf %792, %793 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
      %795 = arith.addf %791, %794 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
      %796 = affine.load %arg0[%arg3 * 8 + 3, %arg4 * 15 + 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<265 -> 267, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %797 = affine.load %arg2[0, 1] {partition_indices = [0, 1], timing = #hlscpp.t<441 -> 443, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
      %798 = arith.mulf %796, %797 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
      %799 = arith.addf %795, %798 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
      %800 = affine.load %arg0[%arg3 * 8 + 5, %arg4 * 15 + 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<266 -> 268, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %801 = affine.load %arg2[2, 1] {partition_indices = [2, 1], timing = #hlscpp.t<446 -> 448, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
      %802 = arith.mulf %800, %801 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
      %803 = arith.addf %799, %802 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
      %804 = affine.load %arg2[1, 2] {partition_indices = [1, 2], timing = #hlscpp.t<451 -> 453, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
      %805 = arith.mulf %557, %804 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
      %806 = arith.addf %803, %805 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
      %807 = affine.load %arg2[0, 2] {partition_indices = [0, 2], timing = #hlscpp.t<456 -> 458, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
      %808 = arith.mulf %304, %807 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
      %809 = arith.addf %806, %808 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
      %810 = affine.load %arg0[%arg3 * 8 + 5, %arg4 * 15 + 2] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<267 -> 269, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %811 = affine.load %arg2[2, 2] {partition_indices = [2, 2], timing = #hlscpp.t<461 -> 463, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
      %812 = arith.mulf %810, %811 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
      %813 = arith.addf %809, %812 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
      affine.store %813, %arg1[%arg3 * 8 + 4, %arg4 * 15 + 1] {partition_indices = [4, 1], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      %814 = arith.mulf %792, %782 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %815 = arith.mulf %796, %785 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %816 = arith.addf %814, %815 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
      %817 = arith.mulf %800, %789 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
      %818 = arith.addf %816, %817 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
      %819 = arith.mulf %557, %793 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
      %820 = arith.addf %818, %819 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
      %821 = arith.mulf %304, %797 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
      %822 = arith.addf %820, %821 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
      %823 = arith.mulf %810, %801 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
      %824 = arith.addf %822, %823 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
      %825 = arith.mulf %576, %804 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
      %826 = arith.addf %824, %825 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
      %827 = arith.mulf %323, %807 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
      %828 = arith.addf %826, %827 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
      %829 = affine.load %arg0[%arg3 * 8 + 5, %arg4 * 15 + 3] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<268 -> 270, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %830 = arith.mulf %829, %811 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
      %831 = arith.addf %828, %830 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
      affine.store %831, %arg1[%arg3 * 8 + 4, %arg4 * 15 + 2] {partition_indices = [4, 2], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      %832 = arith.mulf %557, %782 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %833 = arith.mulf %304, %785 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %834 = arith.addf %832, %833 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
      %835 = arith.mulf %810, %789 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
      %836 = arith.addf %834, %835 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
      %837 = arith.mulf %576, %793 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
      %838 = arith.addf %836, %837 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
      %839 = arith.mulf %323, %797 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
      %840 = arith.addf %838, %839 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
      %841 = arith.mulf %829, %801 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
      %842 = arith.addf %840, %841 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
      %843 = arith.mulf %594, %804 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
      %844 = arith.addf %842, %843 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
      %845 = arith.mulf %341, %807 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
      %846 = arith.addf %844, %845 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
      %847 = affine.load %arg0[%arg3 * 8 + 5, %arg4 * 15 + 4] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<269 -> 271, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %848 = arith.mulf %847, %811 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
      %849 = arith.addf %846, %848 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
      affine.store %849, %arg1[%arg3 * 8 + 4, %arg4 * 15 + 3] {partition_indices = [4, 3], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      %850 = arith.mulf %576, %782 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %851 = arith.mulf %323, %785 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %852 = arith.addf %850, %851 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
      %853 = arith.mulf %829, %789 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
      %854 = arith.addf %852, %853 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
      %855 = arith.mulf %594, %793 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
      %856 = arith.addf %854, %855 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
      %857 = arith.mulf %341, %797 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
      %858 = arith.addf %856, %857 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
      %859 = arith.mulf %847, %801 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
      %860 = arith.addf %858, %859 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
      %861 = arith.mulf %612, %804 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
      %862 = arith.addf %860, %861 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
      %863 = arith.mulf %359, %807 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
      %864 = arith.addf %862, %863 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
      %865 = affine.load %arg0[%arg3 * 8 + 5, %arg4 * 15 + 5] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<270 -> 272, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %866 = arith.mulf %865, %811 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
      %867 = arith.addf %864, %866 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
      affine.store %867, %arg1[%arg3 * 8 + 4, %arg4 * 15 + 4] {partition_indices = [4, 4], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      %868 = arith.mulf %594, %782 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %869 = arith.mulf %341, %785 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %870 = arith.addf %868, %869 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
      %871 = arith.mulf %847, %789 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
      %872 = arith.addf %870, %871 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
      %873 = arith.mulf %612, %793 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
      %874 = arith.addf %872, %873 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
      %875 = arith.mulf %359, %797 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
      %876 = arith.addf %874, %875 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
      %877 = arith.mulf %865, %801 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
      %878 = arith.addf %876, %877 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
      %879 = arith.mulf %630, %804 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
      %880 = arith.addf %878, %879 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
      %881 = arith.mulf %377, %807 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
      %882 = arith.addf %880, %881 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
      %883 = affine.load %arg0[%arg3 * 8 + 5, %arg4 * 15 + 6] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<271 -> 273, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %884 = arith.mulf %883, %811 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
      %885 = arith.addf %882, %884 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
      affine.store %885, %arg1[%arg3 * 8 + 4, %arg4 * 15 + 5] {partition_indices = [4, 5], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      %886 = arith.mulf %612, %782 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %887 = arith.mulf %359, %785 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %888 = arith.addf %886, %887 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
      %889 = arith.mulf %865, %789 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
      %890 = arith.addf %888, %889 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
      %891 = arith.mulf %630, %793 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
      %892 = arith.addf %890, %891 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
      %893 = arith.mulf %377, %797 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
      %894 = arith.addf %892, %893 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
      %895 = arith.mulf %883, %801 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
      %896 = arith.addf %894, %895 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
      %897 = arith.mulf %648, %804 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
      %898 = arith.addf %896, %897 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
      %899 = arith.mulf %395, %807 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
      %900 = arith.addf %898, %899 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
      %901 = affine.load %arg0[%arg3 * 8 + 5, %arg4 * 15 + 7] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<272 -> 274, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %902 = arith.mulf %901, %811 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
      %903 = arith.addf %900, %902 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
      affine.store %903, %arg1[%arg3 * 8 + 4, %arg4 * 15 + 6] {partition_indices = [4, 6], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      %904 = arith.mulf %630, %782 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %905 = arith.mulf %377, %785 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %906 = arith.addf %904, %905 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
      %907 = arith.mulf %883, %789 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
      %908 = arith.addf %906, %907 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
      %909 = arith.mulf %648, %793 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
      %910 = arith.addf %908, %909 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
      %911 = arith.mulf %395, %797 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
      %912 = arith.addf %910, %911 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
      %913 = arith.mulf %901, %801 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
      %914 = arith.addf %912, %913 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
      %915 = arith.mulf %666, %804 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
      %916 = arith.addf %914, %915 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
      %917 = arith.mulf %413, %807 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
      %918 = arith.addf %916, %917 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
      %919 = affine.load %arg0[%arg3 * 8 + 5, %arg4 * 15 + 8] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<273 -> 275, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %920 = arith.mulf %919, %811 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
      %921 = arith.addf %918, %920 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
      affine.store %921, %arg1[%arg3 * 8 + 4, %arg4 * 15 + 7] {partition_indices = [4, 7], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      %922 = arith.mulf %648, %782 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %923 = arith.mulf %395, %785 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %924 = arith.addf %922, %923 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
      %925 = arith.mulf %901, %789 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
      %926 = arith.addf %924, %925 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
      %927 = arith.mulf %666, %793 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
      %928 = arith.addf %926, %927 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
      %929 = arith.mulf %413, %797 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
      %930 = arith.addf %928, %929 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
      %931 = arith.mulf %919, %801 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
      %932 = arith.addf %930, %931 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
      %933 = arith.mulf %684, %804 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
      %934 = arith.addf %932, %933 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
      %935 = arith.mulf %431, %807 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
      %936 = arith.addf %934, %935 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
      %937 = affine.load %arg0[%arg3 * 8 + 5, %arg4 * 15 + 9] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<274 -> 276, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %938 = arith.mulf %937, %811 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
      %939 = arith.addf %936, %938 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
      affine.store %939, %arg1[%arg3 * 8 + 4, %arg4 * 15 + 8] {partition_indices = [4, 8], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      %940 = arith.mulf %666, %782 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %941 = arith.mulf %413, %785 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %942 = arith.addf %940, %941 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
      %943 = arith.mulf %919, %789 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
      %944 = arith.addf %942, %943 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
      %945 = arith.mulf %684, %793 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
      %946 = arith.addf %944, %945 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
      %947 = arith.mulf %431, %797 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
      %948 = arith.addf %946, %947 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
      %949 = arith.mulf %937, %801 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
      %950 = arith.addf %948, %949 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
      %951 = arith.mulf %702, %804 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
      %952 = arith.addf %950, %951 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
      %953 = arith.mulf %449, %807 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
      %954 = arith.addf %952, %953 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
      %955 = affine.load %arg0[%arg3 * 8 + 5, %arg4 * 15 + 10] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<275 -> 277, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %956 = arith.mulf %955, %811 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
      %957 = arith.addf %954, %956 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
      affine.store %957, %arg1[%arg3 * 8 + 4, %arg4 * 15 + 9] {partition_indices = [4, 9], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      %958 = arith.mulf %684, %782 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %959 = arith.mulf %431, %785 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %960 = arith.addf %958, %959 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
      %961 = arith.mulf %937, %789 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
      %962 = arith.addf %960, %961 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
      %963 = arith.mulf %702, %793 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
      %964 = arith.addf %962, %963 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
      %965 = arith.mulf %449, %797 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
      %966 = arith.addf %964, %965 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
      %967 = arith.mulf %955, %801 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
      %968 = arith.addf %966, %967 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
      %969 = arith.mulf %720, %804 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
      %970 = arith.addf %968, %969 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
      %971 = arith.mulf %467, %807 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
      %972 = arith.addf %970, %971 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
      %973 = affine.load %arg0[%arg3 * 8 + 5, %arg4 * 15 + 11] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<276 -> 278, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %974 = arith.mulf %973, %811 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
      %975 = arith.addf %972, %974 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
      affine.store %975, %arg1[%arg3 * 8 + 4, %arg4 * 15 + 10] {partition_indices = [4, 10], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      %976 = arith.mulf %702, %782 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %977 = arith.mulf %449, %785 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %978 = arith.addf %976, %977 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
      %979 = arith.mulf %955, %789 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
      %980 = arith.addf %978, %979 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
      %981 = arith.mulf %720, %793 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
      %982 = arith.addf %980, %981 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
      %983 = arith.mulf %467, %797 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
      %984 = arith.addf %982, %983 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
      %985 = arith.mulf %973, %801 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
      %986 = arith.addf %984, %985 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
      %987 = arith.mulf %738, %804 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
      %988 = arith.addf %986, %987 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
      %989 = arith.mulf %485, %807 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
      %990 = arith.addf %988, %989 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
      %991 = affine.load %arg0[%arg3 * 8 + 5, %arg4 * 15 + 12] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<277 -> 279, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %992 = arith.mulf %991, %811 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
      %993 = arith.addf %990, %992 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
      affine.store %993, %arg1[%arg3 * 8 + 4, %arg4 * 15 + 11] {partition_indices = [4, 11], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      %994 = arith.mulf %720, %782 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %995 = arith.mulf %467, %785 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %996 = arith.addf %994, %995 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
      %997 = arith.mulf %973, %789 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
      %998 = arith.addf %996, %997 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
      %999 = arith.mulf %738, %793 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
      %1000 = arith.addf %998, %999 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
      %1001 = arith.mulf %485, %797 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
      %1002 = arith.addf %1000, %1001 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
      %1003 = arith.mulf %991, %801 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
      %1004 = arith.addf %1002, %1003 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
      %1005 = affine.load %arg0[%arg3 * 8 + 4, %arg4 * 15 + 13] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<278 -> 280, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %1006 = arith.mulf %1005, %804 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
      %1007 = arith.addf %1004, %1006 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
      %1008 = affine.load %arg0[%arg3 * 8 + 3, %arg4 * 15 + 13] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<279 -> 281, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %1009 = arith.mulf %1008, %807 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
      %1010 = arith.addf %1007, %1009 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
      %1011 = affine.load %arg0[%arg3 * 8 + 5, %arg4 * 15 + 13] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<280 -> 282, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %1012 = arith.mulf %1011, %811 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
      %1013 = arith.addf %1010, %1012 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
      affine.store %1013, %arg1[%arg3 * 8 + 4, %arg4 * 15 + 12] {partition_indices = [4, 12], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      %1014 = arith.mulf %738, %782 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %1015 = arith.mulf %485, %785 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %1016 = arith.addf %1014, %1015 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
      %1017 = arith.mulf %991, %789 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
      %1018 = arith.addf %1016, %1017 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
      %1019 = arith.mulf %1005, %793 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
      %1020 = arith.addf %1018, %1019 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
      %1021 = arith.mulf %1008, %797 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
      %1022 = arith.addf %1020, %1021 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
      %1023 = arith.mulf %1011, %801 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
      %1024 = arith.addf %1022, %1023 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
      %1025 = affine.load %arg0[%arg3 * 8 + 4, %arg4 * 15 + 14] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<281 -> 283, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %1026 = arith.mulf %1025, %804 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
      %1027 = arith.addf %1024, %1026 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
      %1028 = affine.load %arg0[%arg3 * 8 + 3, %arg4 * 15 + 14] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<282 -> 284, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %1029 = arith.mulf %1028, %807 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
      %1030 = arith.addf %1027, %1029 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
      %1031 = affine.load %arg0[%arg3 * 8 + 5, %arg4 * 15 + 14] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<283 -> 285, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %1032 = arith.mulf %1031, %811 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
      %1033 = arith.addf %1030, %1032 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
      affine.store %1033, %arg1[%arg3 * 8 + 4, %arg4 * 15 + 13] {partition_indices = [4, 13], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      affine.if affine_set<(d0) : (d0 * 15 - 1065 == 0)>(%arg4) {
        %1540 = affine.load %arg0[%arg3 * 8 + 4, %arg4 * 15 + 13] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<293 -> 295, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1541 = affine.load %arg2[1, 0] {partition_indices = [1, 0], timing = #hlscpp.t<419 -> 421, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1542 = arith.mulf %1540, %1541 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
        %1543 = affine.load %arg0[%arg3 * 8 + 3, %arg4 * 15 + 13] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<294 -> 296, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1544 = affine.load %arg2[0, 0] {partition_indices = [0, 0], timing = #hlscpp.t<419 -> 421, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1545 = arith.mulf %1543, %1544 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
        %1546 = arith.addf %1542, %1545 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
        %1547 = affine.load %arg0[%arg3 * 8 + 5, %arg4 * 15 + 13] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<295 -> 297, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1548 = affine.load %arg2[2, 0] {partition_indices = [2, 0], timing = #hlscpp.t<424 -> 426, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1549 = arith.mulf %1547, %1548 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
        %1550 = arith.addf %1546, %1549 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
        %1551 = affine.load %arg0[%arg3 * 8 + 4, %arg4 * 15 + 14] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<296 -> 298, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1552 = affine.load %arg2[1, 1] {partition_indices = [1, 1], timing = #hlscpp.t<429 -> 431, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1553 = arith.mulf %1551, %1552 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
        %1554 = arith.addf %1550, %1553 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
        %1555 = affine.load %arg0[%arg3 * 8 + 3, %arg4 * 15 + 14] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<297 -> 299, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1556 = affine.load %arg2[0, 1] {partition_indices = [0, 1], timing = #hlscpp.t<434 -> 436, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1557 = arith.mulf %1555, %1556 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
        %1558 = arith.addf %1554, %1557 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
        %1559 = affine.load %arg0[%arg3 * 8 + 5, %arg4 * 15 + 14] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<298 -> 300, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1560 = affine.load %arg2[2, 1] {partition_indices = [2, 1], timing = #hlscpp.t<439 -> 441, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1561 = arith.mulf %1559, %1560 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
        %1562 = arith.addf %1558, %1561 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
        %1563 = affine.load %arg2[1, 2] {partition_indices = [1, 2], timing = #hlscpp.t<444 -> 446, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1564 = arith.mulf %1540, %1563 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
        %1565 = arith.addf %1562, %1564 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
        %1566 = affine.load %arg2[0, 2] {partition_indices = [0, 2], timing = #hlscpp.t<449 -> 451, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1567 = arith.mulf %1543, %1566 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
        %1568 = arith.addf %1565, %1567 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
        %1569 = affine.load %arg2[2, 2] {partition_indices = [2, 2], timing = #hlscpp.t<454 -> 456, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1570 = arith.mulf %1547, %1569 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
        %1571 = arith.addf %1568, %1570 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
        affine.store %1571, %arg1[%arg3 * 8 + 4, %arg4 * 15 + 14] {partition_indices = [4, 14], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      } else {
        %1540 = affine.load %arg0[%arg3 * 8 + 4, %arg4 * 15 + 13] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<284 -> 286, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1541 = affine.load %arg2[1, 0] {partition_indices = [1, 0], timing = #hlscpp.t<418 -> 420, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1542 = arith.mulf %1540, %1541 {timing = #hlscpp.t<436 -> 440, 4, 1>} : f32
        %1543 = affine.load %arg0[%arg3 * 8 + 3, %arg4 * 15 + 13] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<285 -> 287, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1544 = affine.load %arg2[0, 0] {partition_indices = [0, 0], timing = #hlscpp.t<418 -> 420, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1545 = arith.mulf %1543, %1544 {timing = #hlscpp.t<436 -> 440, 4, 1>} : f32
        %1546 = arith.addf %1542, %1545 {timing = #hlscpp.t<440 -> 445, 5, 1>} : f32
        %1547 = affine.load %arg0[%arg3 * 8 + 5, %arg4 * 15 + 13] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<286 -> 288, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1548 = affine.load %arg2[2, 0] {partition_indices = [2, 0], timing = #hlscpp.t<423 -> 425, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1549 = arith.mulf %1547, %1548 {timing = #hlscpp.t<441 -> 445, 4, 1>} : f32
        %1550 = arith.addf %1546, %1549 {timing = #hlscpp.t<445 -> 450, 5, 1>} : f32
        %1551 = affine.load %arg0[%arg3 * 8 + 4, %arg4 * 15 + 14] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<287 -> 289, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1552 = affine.load %arg2[1, 1] {partition_indices = [1, 1], timing = #hlscpp.t<428 -> 430, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1553 = arith.mulf %1551, %1552 {timing = #hlscpp.t<446 -> 450, 4, 1>} : f32
        %1554 = arith.addf %1550, %1553 {timing = #hlscpp.t<450 -> 455, 5, 1>} : f32
        %1555 = affine.load %arg0[%arg3 * 8 + 3, %arg4 * 15 + 14] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<288 -> 290, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1556 = affine.load %arg2[0, 1] {partition_indices = [0, 1], timing = #hlscpp.t<433 -> 435, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1557 = arith.mulf %1555, %1556 {timing = #hlscpp.t<451 -> 455, 4, 1>} : f32
        %1558 = arith.addf %1554, %1557 {timing = #hlscpp.t<455 -> 460, 5, 1>} : f32
        %1559 = affine.load %arg0[%arg3 * 8 + 5, %arg4 * 15 + 14] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<289 -> 291, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1560 = affine.load %arg2[2, 1] {partition_indices = [2, 1], timing = #hlscpp.t<438 -> 440, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1561 = arith.mulf %1559, %1560 {timing = #hlscpp.t<456 -> 460, 4, 1>} : f32
        %1562 = arith.addf %1558, %1561 {timing = #hlscpp.t<460 -> 465, 5, 1>} : f32
        %1563 = affine.load %arg0[%arg3 * 8 + 4, %arg4 * 15 + 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<290 -> 292, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1564 = affine.load %arg2[1, 2] {partition_indices = [1, 2], timing = #hlscpp.t<443 -> 445, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1565 = arith.mulf %1563, %1564 {timing = #hlscpp.t<461 -> 465, 4, 1>} : f32
        %1566 = arith.addf %1562, %1565 {timing = #hlscpp.t<465 -> 470, 5, 1>} : f32
        %1567 = affine.load %arg0[%arg3 * 8 + 3, %arg4 * 15 + 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<291 -> 293, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1568 = affine.load %arg2[0, 2] {partition_indices = [0, 2], timing = #hlscpp.t<448 -> 450, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1569 = arith.mulf %1567, %1568 {timing = #hlscpp.t<466 -> 470, 4, 1>} : f32
        %1570 = arith.addf %1566, %1569 {timing = #hlscpp.t<470 -> 475, 5, 1>} : f32
        %1571 = affine.load %arg0[%arg3 * 8 + 5, %arg4 * 15 + 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<292 -> 294, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1572 = affine.load %arg2[2, 2] {partition_indices = [2, 2], timing = #hlscpp.t<453 -> 455, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1573 = arith.mulf %1571, %1572 {timing = #hlscpp.t<471 -> 475, 4, 1>} : f32
        %1574 = arith.addf %1570, %1573 {timing = #hlscpp.t<475 -> 480, 5, 1>} : f32
        affine.store %1574, %arg1[%arg3 * 8 + 4, %arg4 * 15 + 14] {partition_indices = [4, 14], timing = #hlscpp.t<480 -> 481, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      } {timing = #hlscpp.t<284 -> 482, 198, 0>}
      affine.if affine_set<(d0) : (d0 * 15 == 0)>(%arg4) {
        %1540 = affine.load %arg0[%arg3 * 8 + 5, %arg4 * 15 + 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<307 -> 309, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1541 = affine.load %arg2[1, 0] {partition_indices = [1, 0], timing = #hlscpp.t<421 -> 423, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1542 = arith.mulf %1540, %1541 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
        %1543 = affine.load %arg0[%arg3 * 8 + 4, %arg4 * 15 + 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<308 -> 310, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1544 = affine.load %arg2[0, 0] {partition_indices = [0, 0], timing = #hlscpp.t<421 -> 423, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1545 = arith.mulf %1543, %1544 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
        %1546 = arith.addf %1542, %1545 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
        %1547 = affine.load %arg0[%arg3 * 8 + 6, %arg4 * 15 + 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<309 -> 311, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1548 = affine.load %arg2[2, 0] {partition_indices = [2, 0], timing = #hlscpp.t<426 -> 428, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1549 = arith.mulf %1547, %1548 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
        %1550 = arith.addf %1546, %1549 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
        %1551 = affine.load %arg0[%arg3 * 8 + 5, %arg4 * 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<310 -> 312, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1552 = affine.load %arg2[1, 1] {partition_indices = [1, 1], timing = #hlscpp.t<431 -> 433, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1553 = arith.mulf %1551, %1552 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
        %1554 = arith.addf %1550, %1553 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
        %1555 = affine.load %arg0[%arg3 * 8 + 4, %arg4 * 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<311 -> 313, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1556 = affine.load %arg2[0, 1] {partition_indices = [0, 1], timing = #hlscpp.t<436 -> 438, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1557 = arith.mulf %1555, %1556 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
        %1558 = arith.addf %1554, %1557 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
        %1559 = affine.load %arg0[%arg3 * 8 + 6, %arg4 * 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<312 -> 314, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1560 = affine.load %arg2[2, 1] {partition_indices = [2, 1], timing = #hlscpp.t<441 -> 443, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1561 = arith.mulf %1559, %1560 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
        %1562 = arith.addf %1558, %1561 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
        %1563 = affine.load %arg2[1, 2] {partition_indices = [1, 2], timing = #hlscpp.t<446 -> 448, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1564 = arith.mulf %1540, %1563 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
        %1565 = arith.addf %1562, %1564 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
        %1566 = affine.load %arg2[0, 2] {partition_indices = [0, 2], timing = #hlscpp.t<451 -> 453, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1567 = arith.mulf %1543, %1566 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
        %1568 = arith.addf %1565, %1567 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
        %1569 = affine.load %arg2[2, 2] {partition_indices = [2, 2], timing = #hlscpp.t<456 -> 458, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1570 = arith.mulf %1547, %1569 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
        %1571 = arith.addf %1568, %1570 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
        affine.store %1571, %arg1[%arg3 * 8 + 5, %arg4 * 15] {partition_indices = [5, 0], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      } else {
        %1540 = affine.load %arg0[%arg3 * 8 + 5, %arg4 * 15 - 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<299 -> 301, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1541 = affine.load %arg2[1, 0] {partition_indices = [1, 0], timing = #hlscpp.t<420 -> 422, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1542 = arith.mulf %1540, %1541 {timing = #hlscpp.t<436 -> 440, 4, 1>} : f32
        %1543 = affine.load %arg0[%arg3 * 8 + 4, %arg4 * 15 - 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<300 -> 302, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1544 = affine.load %arg2[0, 0] {partition_indices = [0, 0], timing = #hlscpp.t<420 -> 422, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1545 = arith.mulf %1543, %1544 {timing = #hlscpp.t<436 -> 440, 4, 1>} : f32
        %1546 = arith.addf %1542, %1545 {timing = #hlscpp.t<440 -> 445, 5, 1>} : f32
        %1547 = affine.load %arg0[%arg3 * 8 + 6, %arg4 * 15 - 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<301 -> 303, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1548 = affine.load %arg2[2, 0] {partition_indices = [2, 0], timing = #hlscpp.t<425 -> 427, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1549 = arith.mulf %1547, %1548 {timing = #hlscpp.t<441 -> 445, 4, 1>} : f32
        %1550 = arith.addf %1546, %1549 {timing = #hlscpp.t<445 -> 450, 5, 1>} : f32
        %1551 = affine.load %arg0[%arg3 * 8 + 5, %arg4 * 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<302 -> 304, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1552 = affine.load %arg2[1, 1] {partition_indices = [1, 1], timing = #hlscpp.t<430 -> 432, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1553 = arith.mulf %1551, %1552 {timing = #hlscpp.t<446 -> 450, 4, 1>} : f32
        %1554 = arith.addf %1550, %1553 {timing = #hlscpp.t<450 -> 455, 5, 1>} : f32
        %1555 = affine.load %arg0[%arg3 * 8 + 4, %arg4 * 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<303 -> 305, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1556 = affine.load %arg2[0, 1] {partition_indices = [0, 1], timing = #hlscpp.t<435 -> 437, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1557 = arith.mulf %1555, %1556 {timing = #hlscpp.t<451 -> 455, 4, 1>} : f32
        %1558 = arith.addf %1554, %1557 {timing = #hlscpp.t<455 -> 460, 5, 1>} : f32
        %1559 = affine.load %arg0[%arg3 * 8 + 6, %arg4 * 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<304 -> 306, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1560 = affine.load %arg2[2, 1] {partition_indices = [2, 1], timing = #hlscpp.t<440 -> 442, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1561 = arith.mulf %1559, %1560 {timing = #hlscpp.t<456 -> 460, 4, 1>} : f32
        %1562 = arith.addf %1558, %1561 {timing = #hlscpp.t<460 -> 465, 5, 1>} : f32
        %1563 = affine.load %arg0[%arg3 * 8 + 5, %arg4 * 15 + 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<305 -> 307, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1564 = affine.load %arg2[1, 2] {partition_indices = [1, 2], timing = #hlscpp.t<445 -> 447, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1565 = arith.mulf %1563, %1564 {timing = #hlscpp.t<461 -> 465, 4, 1>} : f32
        %1566 = arith.addf %1562, %1565 {timing = #hlscpp.t<465 -> 470, 5, 1>} : f32
        %1567 = affine.load %arg0[%arg3 * 8 + 4, %arg4 * 15 + 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<306 -> 308, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1568 = affine.load %arg2[0, 2] {partition_indices = [0, 2], timing = #hlscpp.t<450 -> 452, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1569 = arith.mulf %1567, %1568 {timing = #hlscpp.t<466 -> 470, 4, 1>} : f32
        %1570 = arith.addf %1566, %1569 {timing = #hlscpp.t<470 -> 475, 5, 1>} : f32
        %1571 = affine.load %arg0[%arg3 * 8 + 6, %arg4 * 15 + 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<465 -> 467, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1572 = affine.load %arg2[2, 2] {partition_indices = [2, 2], timing = #hlscpp.t<455 -> 457, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1573 = arith.mulf %1571, %1572 {timing = #hlscpp.t<471 -> 475, 4, 1>} : f32
        %1574 = arith.addf %1570, %1573 {timing = #hlscpp.t<475 -> 480, 5, 1>} : f32
        affine.store %1574, %arg1[%arg3 * 8 + 5, %arg4 * 15] {partition_indices = [5, 0], timing = #hlscpp.t<480 -> 481, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      } {timing = #hlscpp.t<299 -> 482, 183, 0>}
      %1034 = affine.load %arg0[%arg3 * 8 + 5, %arg4 * 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<313 -> 315, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %1035 = affine.load %arg2[1, 0] {partition_indices = [1, 0], timing = #hlscpp.t<426 -> 428, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
      %1036 = arith.mulf %1034, %1035 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %1037 = affine.load %arg0[%arg3 * 8 + 4, %arg4 * 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<314 -> 316, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %1038 = affine.load %arg2[0, 0] {partition_indices = [0, 0], timing = #hlscpp.t<426 -> 428, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
      %1039 = arith.mulf %1037, %1038 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %1040 = arith.addf %1036, %1039 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
      %1041 = affine.load %arg0[%arg3 * 8 + 6, %arg4 * 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<315 -> 317, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %1042 = affine.load %arg2[2, 0] {partition_indices = [2, 0], timing = #hlscpp.t<431 -> 433, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
      %1043 = arith.mulf %1041, %1042 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
      %1044 = arith.addf %1040, %1043 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
      %1045 = affine.load %arg0[%arg3 * 8 + 5, %arg4 * 15 + 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<316 -> 318, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %1046 = affine.load %arg2[1, 1] {partition_indices = [1, 1], timing = #hlscpp.t<436 -> 438, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
      %1047 = arith.mulf %1045, %1046 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
      %1048 = arith.addf %1044, %1047 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
      %1049 = affine.load %arg0[%arg3 * 8 + 4, %arg4 * 15 + 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<317 -> 319, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %1050 = affine.load %arg2[0, 1] {partition_indices = [0, 1], timing = #hlscpp.t<441 -> 443, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
      %1051 = arith.mulf %1049, %1050 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
      %1052 = arith.addf %1048, %1051 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
      %1053 = affine.load %arg0[%arg3 * 8 + 6, %arg4 * 15 + 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<318 -> 320, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %1054 = affine.load %arg2[2, 1] {partition_indices = [2, 1], timing = #hlscpp.t<446 -> 448, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
      %1055 = arith.mulf %1053, %1054 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
      %1056 = arith.addf %1052, %1055 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
      %1057 = affine.load %arg2[1, 2] {partition_indices = [1, 2], timing = #hlscpp.t<451 -> 453, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
      %1058 = arith.mulf %810, %1057 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
      %1059 = arith.addf %1056, %1058 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
      %1060 = affine.load %arg2[0, 2] {partition_indices = [0, 2], timing = #hlscpp.t<456 -> 458, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
      %1061 = arith.mulf %557, %1060 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
      %1062 = arith.addf %1059, %1061 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
      %1063 = affine.load %arg0[%arg3 * 8 + 6, %arg4 * 15 + 2] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<319 -> 321, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %1064 = affine.load %arg2[2, 2] {partition_indices = [2, 2], timing = #hlscpp.t<461 -> 463, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
      %1065 = arith.mulf %1063, %1064 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
      %1066 = arith.addf %1062, %1065 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
      affine.store %1066, %arg1[%arg3 * 8 + 5, %arg4 * 15 + 1] {partition_indices = [5, 1], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      %1067 = arith.mulf %1045, %1035 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %1068 = arith.mulf %1049, %1038 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %1069 = arith.addf %1067, %1068 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
      %1070 = arith.mulf %1053, %1042 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
      %1071 = arith.addf %1069, %1070 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
      %1072 = arith.mulf %810, %1046 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
      %1073 = arith.addf %1071, %1072 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
      %1074 = arith.mulf %557, %1050 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
      %1075 = arith.addf %1073, %1074 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
      %1076 = arith.mulf %1063, %1054 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
      %1077 = arith.addf %1075, %1076 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
      %1078 = arith.mulf %829, %1057 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
      %1079 = arith.addf %1077, %1078 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
      %1080 = arith.mulf %576, %1060 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
      %1081 = arith.addf %1079, %1080 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
      %1082 = affine.load %arg0[%arg3 * 8 + 6, %arg4 * 15 + 3] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<320 -> 322, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %1083 = arith.mulf %1082, %1064 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
      %1084 = arith.addf %1081, %1083 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
      affine.store %1084, %arg1[%arg3 * 8 + 5, %arg4 * 15 + 2] {partition_indices = [5, 2], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      %1085 = arith.mulf %810, %1035 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %1086 = arith.mulf %557, %1038 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %1087 = arith.addf %1085, %1086 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
      %1088 = arith.mulf %1063, %1042 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
      %1089 = arith.addf %1087, %1088 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
      %1090 = arith.mulf %829, %1046 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
      %1091 = arith.addf %1089, %1090 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
      %1092 = arith.mulf %576, %1050 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
      %1093 = arith.addf %1091, %1092 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
      %1094 = arith.mulf %1082, %1054 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
      %1095 = arith.addf %1093, %1094 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
      %1096 = arith.mulf %847, %1057 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
      %1097 = arith.addf %1095, %1096 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
      %1098 = arith.mulf %594, %1060 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
      %1099 = arith.addf %1097, %1098 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
      %1100 = affine.load %arg0[%arg3 * 8 + 6, %arg4 * 15 + 4] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<321 -> 323, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %1101 = arith.mulf %1100, %1064 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
      %1102 = arith.addf %1099, %1101 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
      affine.store %1102, %arg1[%arg3 * 8 + 5, %arg4 * 15 + 3] {partition_indices = [5, 3], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      %1103 = arith.mulf %829, %1035 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %1104 = arith.mulf %576, %1038 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %1105 = arith.addf %1103, %1104 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
      %1106 = arith.mulf %1082, %1042 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
      %1107 = arith.addf %1105, %1106 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
      %1108 = arith.mulf %847, %1046 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
      %1109 = arith.addf %1107, %1108 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
      %1110 = arith.mulf %594, %1050 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
      %1111 = arith.addf %1109, %1110 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
      %1112 = arith.mulf %1100, %1054 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
      %1113 = arith.addf %1111, %1112 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
      %1114 = arith.mulf %865, %1057 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
      %1115 = arith.addf %1113, %1114 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
      %1116 = arith.mulf %612, %1060 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
      %1117 = arith.addf %1115, %1116 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
      %1118 = affine.load %arg0[%arg3 * 8 + 6, %arg4 * 15 + 5] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<322 -> 324, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %1119 = arith.mulf %1118, %1064 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
      %1120 = arith.addf %1117, %1119 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
      affine.store %1120, %arg1[%arg3 * 8 + 5, %arg4 * 15 + 4] {partition_indices = [5, 4], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      %1121 = arith.mulf %847, %1035 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %1122 = arith.mulf %594, %1038 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %1123 = arith.addf %1121, %1122 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
      %1124 = arith.mulf %1100, %1042 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
      %1125 = arith.addf %1123, %1124 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
      %1126 = arith.mulf %865, %1046 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
      %1127 = arith.addf %1125, %1126 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
      %1128 = arith.mulf %612, %1050 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
      %1129 = arith.addf %1127, %1128 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
      %1130 = arith.mulf %1118, %1054 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
      %1131 = arith.addf %1129, %1130 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
      %1132 = arith.mulf %883, %1057 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
      %1133 = arith.addf %1131, %1132 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
      %1134 = arith.mulf %630, %1060 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
      %1135 = arith.addf %1133, %1134 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
      %1136 = affine.load %arg0[%arg3 * 8 + 6, %arg4 * 15 + 6] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<323 -> 325, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %1137 = arith.mulf %1136, %1064 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
      %1138 = arith.addf %1135, %1137 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
      affine.store %1138, %arg1[%arg3 * 8 + 5, %arg4 * 15 + 5] {partition_indices = [5, 5], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      %1139 = arith.mulf %865, %1035 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %1140 = arith.mulf %612, %1038 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %1141 = arith.addf %1139, %1140 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
      %1142 = arith.mulf %1118, %1042 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
      %1143 = arith.addf %1141, %1142 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
      %1144 = arith.mulf %883, %1046 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
      %1145 = arith.addf %1143, %1144 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
      %1146 = arith.mulf %630, %1050 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
      %1147 = arith.addf %1145, %1146 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
      %1148 = arith.mulf %1136, %1054 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
      %1149 = arith.addf %1147, %1148 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
      %1150 = arith.mulf %901, %1057 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
      %1151 = arith.addf %1149, %1150 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
      %1152 = arith.mulf %648, %1060 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
      %1153 = arith.addf %1151, %1152 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
      %1154 = affine.load %arg0[%arg3 * 8 + 6, %arg4 * 15 + 7] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<324 -> 326, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %1155 = arith.mulf %1154, %1064 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
      %1156 = arith.addf %1153, %1155 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
      affine.store %1156, %arg1[%arg3 * 8 + 5, %arg4 * 15 + 6] {partition_indices = [5, 6], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      %1157 = arith.mulf %883, %1035 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %1158 = arith.mulf %630, %1038 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %1159 = arith.addf %1157, %1158 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
      %1160 = arith.mulf %1136, %1042 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
      %1161 = arith.addf %1159, %1160 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
      %1162 = arith.mulf %901, %1046 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
      %1163 = arith.addf %1161, %1162 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
      %1164 = arith.mulf %648, %1050 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
      %1165 = arith.addf %1163, %1164 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
      %1166 = arith.mulf %1154, %1054 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
      %1167 = arith.addf %1165, %1166 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
      %1168 = arith.mulf %919, %1057 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
      %1169 = arith.addf %1167, %1168 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
      %1170 = arith.mulf %666, %1060 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
      %1171 = arith.addf %1169, %1170 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
      %1172 = affine.load %arg0[%arg3 * 8 + 6, %arg4 * 15 + 8] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<325 -> 327, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %1173 = arith.mulf %1172, %1064 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
      %1174 = arith.addf %1171, %1173 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
      affine.store %1174, %arg1[%arg3 * 8 + 5, %arg4 * 15 + 7] {partition_indices = [5, 7], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      %1175 = arith.mulf %901, %1035 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %1176 = arith.mulf %648, %1038 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %1177 = arith.addf %1175, %1176 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
      %1178 = arith.mulf %1154, %1042 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
      %1179 = arith.addf %1177, %1178 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
      %1180 = arith.mulf %919, %1046 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
      %1181 = arith.addf %1179, %1180 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
      %1182 = arith.mulf %666, %1050 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
      %1183 = arith.addf %1181, %1182 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
      %1184 = arith.mulf %1172, %1054 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
      %1185 = arith.addf %1183, %1184 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
      %1186 = arith.mulf %937, %1057 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
      %1187 = arith.addf %1185, %1186 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
      %1188 = arith.mulf %684, %1060 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
      %1189 = arith.addf %1187, %1188 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
      %1190 = affine.load %arg0[%arg3 * 8 + 6, %arg4 * 15 + 9] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<326 -> 328, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %1191 = arith.mulf %1190, %1064 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
      %1192 = arith.addf %1189, %1191 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
      affine.store %1192, %arg1[%arg3 * 8 + 5, %arg4 * 15 + 8] {partition_indices = [5, 8], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      %1193 = arith.mulf %919, %1035 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %1194 = arith.mulf %666, %1038 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %1195 = arith.addf %1193, %1194 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
      %1196 = arith.mulf %1172, %1042 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
      %1197 = arith.addf %1195, %1196 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
      %1198 = arith.mulf %937, %1046 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
      %1199 = arith.addf %1197, %1198 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
      %1200 = arith.mulf %684, %1050 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
      %1201 = arith.addf %1199, %1200 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
      %1202 = arith.mulf %1190, %1054 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
      %1203 = arith.addf %1201, %1202 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
      %1204 = arith.mulf %955, %1057 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
      %1205 = arith.addf %1203, %1204 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
      %1206 = arith.mulf %702, %1060 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
      %1207 = arith.addf %1205, %1206 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
      %1208 = affine.load %arg0[%arg3 * 8 + 6, %arg4 * 15 + 10] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<327 -> 329, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %1209 = arith.mulf %1208, %1064 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
      %1210 = arith.addf %1207, %1209 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
      affine.store %1210, %arg1[%arg3 * 8 + 5, %arg4 * 15 + 9] {partition_indices = [5, 9], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      %1211 = arith.mulf %937, %1035 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %1212 = arith.mulf %684, %1038 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %1213 = arith.addf %1211, %1212 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
      %1214 = arith.mulf %1190, %1042 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
      %1215 = arith.addf %1213, %1214 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
      %1216 = arith.mulf %955, %1046 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
      %1217 = arith.addf %1215, %1216 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
      %1218 = arith.mulf %702, %1050 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
      %1219 = arith.addf %1217, %1218 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
      %1220 = arith.mulf %1208, %1054 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
      %1221 = arith.addf %1219, %1220 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
      %1222 = arith.mulf %973, %1057 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
      %1223 = arith.addf %1221, %1222 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
      %1224 = arith.mulf %720, %1060 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
      %1225 = arith.addf %1223, %1224 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
      %1226 = affine.load %arg0[%arg3 * 8 + 6, %arg4 * 15 + 11] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<328 -> 330, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %1227 = arith.mulf %1226, %1064 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
      %1228 = arith.addf %1225, %1227 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
      affine.store %1228, %arg1[%arg3 * 8 + 5, %arg4 * 15 + 10] {partition_indices = [5, 10], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      %1229 = arith.mulf %955, %1035 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %1230 = arith.mulf %702, %1038 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %1231 = arith.addf %1229, %1230 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
      %1232 = arith.mulf %1208, %1042 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
      %1233 = arith.addf %1231, %1232 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
      %1234 = arith.mulf %973, %1046 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
      %1235 = arith.addf %1233, %1234 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
      %1236 = arith.mulf %720, %1050 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
      %1237 = arith.addf %1235, %1236 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
      %1238 = arith.mulf %1226, %1054 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
      %1239 = arith.addf %1237, %1238 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
      %1240 = arith.mulf %991, %1057 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
      %1241 = arith.addf %1239, %1240 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
      %1242 = arith.mulf %738, %1060 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
      %1243 = arith.addf %1241, %1242 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
      %1244 = affine.load %arg0[%arg3 * 8 + 6, %arg4 * 15 + 12] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<329 -> 331, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %1245 = arith.mulf %1244, %1064 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
      %1246 = arith.addf %1243, %1245 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
      affine.store %1246, %arg1[%arg3 * 8 + 5, %arg4 * 15 + 11] {partition_indices = [5, 11], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      %1247 = arith.mulf %973, %1035 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %1248 = arith.mulf %720, %1038 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %1249 = arith.addf %1247, %1248 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
      %1250 = arith.mulf %1226, %1042 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
      %1251 = arith.addf %1249, %1250 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
      %1252 = arith.mulf %991, %1046 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
      %1253 = arith.addf %1251, %1252 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
      %1254 = arith.mulf %738, %1050 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
      %1255 = arith.addf %1253, %1254 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
      %1256 = arith.mulf %1244, %1054 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
      %1257 = arith.addf %1255, %1256 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
      %1258 = affine.load %arg0[%arg3 * 8 + 5, %arg4 * 15 + 13] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<330 -> 332, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %1259 = arith.mulf %1258, %1057 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
      %1260 = arith.addf %1257, %1259 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
      %1261 = affine.load %arg0[%arg3 * 8 + 4, %arg4 * 15 + 13] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<331 -> 333, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %1262 = arith.mulf %1261, %1060 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
      %1263 = arith.addf %1260, %1262 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
      %1264 = affine.load %arg0[%arg3 * 8 + 6, %arg4 * 15 + 13] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<332 -> 334, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %1265 = arith.mulf %1264, %1064 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
      %1266 = arith.addf %1263, %1265 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
      affine.store %1266, %arg1[%arg3 * 8 + 5, %arg4 * 15 + 12] {partition_indices = [5, 12], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      %1267 = arith.mulf %991, %1035 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %1268 = arith.mulf %738, %1038 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %1269 = arith.addf %1267, %1268 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
      %1270 = arith.mulf %1244, %1042 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
      %1271 = arith.addf %1269, %1270 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
      %1272 = arith.mulf %1258, %1046 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
      %1273 = arith.addf %1271, %1272 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
      %1274 = arith.mulf %1261, %1050 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
      %1275 = arith.addf %1273, %1274 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
      %1276 = arith.mulf %1264, %1054 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
      %1277 = arith.addf %1275, %1276 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
      %1278 = affine.load %arg0[%arg3 * 8 + 5, %arg4 * 15 + 14] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<333 -> 335, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %1279 = arith.mulf %1278, %1057 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
      %1280 = arith.addf %1277, %1279 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
      %1281 = affine.load %arg0[%arg3 * 8 + 4, %arg4 * 15 + 14] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<334 -> 336, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %1282 = arith.mulf %1281, %1060 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
      %1283 = arith.addf %1280, %1282 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
      %1284 = affine.load %arg0[%arg3 * 8 + 6, %arg4 * 15 + 14] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<335 -> 337, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %1285 = arith.mulf %1284, %1064 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
      %1286 = arith.addf %1283, %1285 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
      affine.store %1286, %arg1[%arg3 * 8 + 5, %arg4 * 15 + 13] {partition_indices = [5, 13], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      affine.if affine_set<(d0) : (d0 * 15 - 1065 == 0)>(%arg4) {
        %1540 = affine.load %arg0[%arg3 * 8 + 5, %arg4 * 15 + 13] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<344 -> 346, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1541 = affine.load %arg2[1, 0] {partition_indices = [1, 0], timing = #hlscpp.t<423 -> 425, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1542 = arith.mulf %1540, %1541 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
        %1543 = affine.load %arg0[%arg3 * 8 + 4, %arg4 * 15 + 13] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<345 -> 347, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1544 = affine.load %arg2[0, 0] {partition_indices = [0, 0], timing = #hlscpp.t<423 -> 425, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1545 = arith.mulf %1543, %1544 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
        %1546 = arith.addf %1542, %1545 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
        %1547 = affine.load %arg0[%arg3 * 8 + 6, %arg4 * 15 + 13] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<346 -> 348, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1548 = affine.load %arg2[2, 0] {partition_indices = [2, 0], timing = #hlscpp.t<428 -> 430, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1549 = arith.mulf %1547, %1548 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
        %1550 = arith.addf %1546, %1549 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
        %1551 = affine.load %arg0[%arg3 * 8 + 5, %arg4 * 15 + 14] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<347 -> 349, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1552 = affine.load %arg2[1, 1] {partition_indices = [1, 1], timing = #hlscpp.t<433 -> 435, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1553 = arith.mulf %1551, %1552 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
        %1554 = arith.addf %1550, %1553 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
        %1555 = affine.load %arg0[%arg3 * 8 + 4, %arg4 * 15 + 14] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<348 -> 350, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1556 = affine.load %arg2[0, 1] {partition_indices = [0, 1], timing = #hlscpp.t<438 -> 440, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1557 = arith.mulf %1555, %1556 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
        %1558 = arith.addf %1554, %1557 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
        %1559 = affine.load %arg0[%arg3 * 8 + 6, %arg4 * 15 + 14] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<349 -> 351, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1560 = affine.load %arg2[2, 1] {partition_indices = [2, 1], timing = #hlscpp.t<443 -> 445, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1561 = arith.mulf %1559, %1560 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
        %1562 = arith.addf %1558, %1561 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
        %1563 = affine.load %arg2[1, 2] {partition_indices = [1, 2], timing = #hlscpp.t<448 -> 450, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1564 = arith.mulf %1540, %1563 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
        %1565 = arith.addf %1562, %1564 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
        %1566 = affine.load %arg2[0, 2] {partition_indices = [0, 2], timing = #hlscpp.t<453 -> 455, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1567 = arith.mulf %1543, %1566 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
        %1568 = arith.addf %1565, %1567 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
        %1569 = affine.load %arg2[2, 2] {partition_indices = [2, 2], timing = #hlscpp.t<458 -> 460, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1570 = arith.mulf %1547, %1569 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
        %1571 = arith.addf %1568, %1570 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
        affine.store %1571, %arg1[%arg3 * 8 + 5, %arg4 * 15 + 14] {partition_indices = [5, 14], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      } else {
        %1540 = affine.load %arg0[%arg3 * 8 + 5, %arg4 * 15 + 13] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<336 -> 338, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1541 = affine.load %arg2[1, 0] {partition_indices = [1, 0], timing = #hlscpp.t<422 -> 424, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1542 = arith.mulf %1540, %1541 {timing = #hlscpp.t<436 -> 440, 4, 1>} : f32
        %1543 = affine.load %arg0[%arg3 * 8 + 4, %arg4 * 15 + 13] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<337 -> 339, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1544 = affine.load %arg2[0, 0] {partition_indices = [0, 0], timing = #hlscpp.t<422 -> 424, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1545 = arith.mulf %1543, %1544 {timing = #hlscpp.t<436 -> 440, 4, 1>} : f32
        %1546 = arith.addf %1542, %1545 {timing = #hlscpp.t<440 -> 445, 5, 1>} : f32
        %1547 = affine.load %arg0[%arg3 * 8 + 6, %arg4 * 15 + 13] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<338 -> 340, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1548 = affine.load %arg2[2, 0] {partition_indices = [2, 0], timing = #hlscpp.t<427 -> 429, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1549 = arith.mulf %1547, %1548 {timing = #hlscpp.t<441 -> 445, 4, 1>} : f32
        %1550 = arith.addf %1546, %1549 {timing = #hlscpp.t<445 -> 450, 5, 1>} : f32
        %1551 = affine.load %arg0[%arg3 * 8 + 5, %arg4 * 15 + 14] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<339 -> 341, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1552 = affine.load %arg2[1, 1] {partition_indices = [1, 1], timing = #hlscpp.t<432 -> 434, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1553 = arith.mulf %1551, %1552 {timing = #hlscpp.t<446 -> 450, 4, 1>} : f32
        %1554 = arith.addf %1550, %1553 {timing = #hlscpp.t<450 -> 455, 5, 1>} : f32
        %1555 = affine.load %arg0[%arg3 * 8 + 4, %arg4 * 15 + 14] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<340 -> 342, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1556 = affine.load %arg2[0, 1] {partition_indices = [0, 1], timing = #hlscpp.t<437 -> 439, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1557 = arith.mulf %1555, %1556 {timing = #hlscpp.t<451 -> 455, 4, 1>} : f32
        %1558 = arith.addf %1554, %1557 {timing = #hlscpp.t<455 -> 460, 5, 1>} : f32
        %1559 = affine.load %arg0[%arg3 * 8 + 6, %arg4 * 15 + 14] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<341 -> 343, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1560 = affine.load %arg2[2, 1] {partition_indices = [2, 1], timing = #hlscpp.t<442 -> 444, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1561 = arith.mulf %1559, %1560 {timing = #hlscpp.t<456 -> 460, 4, 1>} : f32
        %1562 = arith.addf %1558, %1561 {timing = #hlscpp.t<460 -> 465, 5, 1>} : f32
        %1563 = affine.load %arg0[%arg3 * 8 + 5, %arg4 * 15 + 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<342 -> 344, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1564 = affine.load %arg2[1, 2] {partition_indices = [1, 2], timing = #hlscpp.t<447 -> 449, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1565 = arith.mulf %1563, %1564 {timing = #hlscpp.t<461 -> 465, 4, 1>} : f32
        %1566 = arith.addf %1562, %1565 {timing = #hlscpp.t<465 -> 470, 5, 1>} : f32
        %1567 = affine.load %arg0[%arg3 * 8 + 4, %arg4 * 15 + 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<343 -> 345, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1568 = affine.load %arg2[0, 2] {partition_indices = [0, 2], timing = #hlscpp.t<452 -> 454, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1569 = arith.mulf %1567, %1568 {timing = #hlscpp.t<466 -> 470, 4, 1>} : f32
        %1570 = arith.addf %1566, %1569 {timing = #hlscpp.t<470 -> 475, 5, 1>} : f32
        %1571 = affine.load %arg0[%arg3 * 8 + 6, %arg4 * 15 + 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<466 -> 468, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1572 = affine.load %arg2[2, 2] {partition_indices = [2, 2], timing = #hlscpp.t<457 -> 459, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1573 = arith.mulf %1571, %1572 {timing = #hlscpp.t<471 -> 475, 4, 1>} : f32
        %1574 = arith.addf %1570, %1573 {timing = #hlscpp.t<475 -> 480, 5, 1>} : f32
        affine.store %1574, %arg1[%arg3 * 8 + 5, %arg4 * 15 + 14] {partition_indices = [5, 14], timing = #hlscpp.t<480 -> 481, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      } {timing = #hlscpp.t<336 -> 482, 146, 0>}
      affine.if affine_set<(d0) : (d0 * 15 == 0)>(%arg4) {
        %1540 = affine.load %arg0[%arg3 * 8 + 6, %arg4 * 15 + 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<357 -> 359, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1541 = affine.load %arg2[1, 0] {partition_indices = [1, 0], timing = #hlscpp.t<425 -> 427, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1542 = arith.mulf %1540, %1541 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
        %1543 = affine.load %arg0[%arg3 * 8 + 5, %arg4 * 15 + 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<358 -> 360, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1544 = affine.load %arg2[0, 0] {partition_indices = [0, 0], timing = #hlscpp.t<425 -> 427, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1545 = arith.mulf %1543, %1544 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
        %1546 = arith.addf %1542, %1545 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
        %1547 = affine.load %arg0[%arg3 * 8 + 7, %arg4 * 15 + 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<359 -> 361, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1548 = affine.load %arg2[2, 0] {partition_indices = [2, 0], timing = #hlscpp.t<430 -> 432, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1549 = arith.mulf %1547, %1548 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
        %1550 = arith.addf %1546, %1549 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
        %1551 = affine.load %arg0[%arg3 * 8 + 6, %arg4 * 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<360 -> 362, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1552 = affine.load %arg2[1, 1] {partition_indices = [1, 1], timing = #hlscpp.t<435 -> 437, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1553 = arith.mulf %1551, %1552 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
        %1554 = arith.addf %1550, %1553 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
        %1555 = affine.load %arg0[%arg3 * 8 + 5, %arg4 * 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<361 -> 363, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1556 = affine.load %arg2[0, 1] {partition_indices = [0, 1], timing = #hlscpp.t<440 -> 442, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1557 = arith.mulf %1555, %1556 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
        %1558 = arith.addf %1554, %1557 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
        %1559 = affine.load %arg0[%arg3 * 8 + 7, %arg4 * 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<451 -> 453, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1560 = affine.load %arg2[2, 1] {partition_indices = [2, 1], timing = #hlscpp.t<445 -> 447, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1561 = arith.mulf %1559, %1560 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
        %1562 = arith.addf %1558, %1561 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
        %1563 = affine.load %arg2[1, 2] {partition_indices = [1, 2], timing = #hlscpp.t<450 -> 452, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1564 = arith.mulf %1540, %1563 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
        %1565 = arith.addf %1562, %1564 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
        %1566 = affine.load %arg2[0, 2] {partition_indices = [0, 2], timing = #hlscpp.t<455 -> 457, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1567 = arith.mulf %1543, %1566 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
        %1568 = arith.addf %1565, %1567 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
        %1569 = affine.load %arg2[2, 2] {partition_indices = [2, 2], timing = #hlscpp.t<460 -> 462, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1570 = arith.mulf %1547, %1569 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
        %1571 = arith.addf %1568, %1570 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
        affine.store %1571, %arg1[%arg3 * 8 + 6, %arg4 * 15] {partition_indices = [6, 0], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      } else {
        %1540 = affine.load %arg0[%arg3 * 8 + 6, %arg4 * 15 - 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<350 -> 352, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1541 = affine.load %arg2[1, 0] {partition_indices = [1, 0], timing = #hlscpp.t<424 -> 426, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1542 = arith.mulf %1540, %1541 {timing = #hlscpp.t<436 -> 440, 4, 1>} : f32
        %1543 = affine.load %arg0[%arg3 * 8 + 5, %arg4 * 15 - 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<351 -> 353, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1544 = affine.load %arg2[0, 0] {partition_indices = [0, 0], timing = #hlscpp.t<424 -> 426, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1545 = arith.mulf %1543, %1544 {timing = #hlscpp.t<436 -> 440, 4, 1>} : f32
        %1546 = arith.addf %1542, %1545 {timing = #hlscpp.t<440 -> 445, 5, 1>} : f32
        %1547 = affine.load %arg0[%arg3 * 8 + 7, %arg4 * 15 - 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<352 -> 354, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1548 = affine.load %arg2[2, 0] {partition_indices = [2, 0], timing = #hlscpp.t<429 -> 431, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1549 = arith.mulf %1547, %1548 {timing = #hlscpp.t<441 -> 445, 4, 1>} : f32
        %1550 = arith.addf %1546, %1549 {timing = #hlscpp.t<445 -> 450, 5, 1>} : f32
        %1551 = affine.load %arg0[%arg3 * 8 + 6, %arg4 * 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<353 -> 355, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1552 = affine.load %arg2[1, 1] {partition_indices = [1, 1], timing = #hlscpp.t<434 -> 436, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1553 = arith.mulf %1551, %1552 {timing = #hlscpp.t<446 -> 450, 4, 1>} : f32
        %1554 = arith.addf %1550, %1553 {timing = #hlscpp.t<450 -> 455, 5, 1>} : f32
        %1555 = affine.load %arg0[%arg3 * 8 + 5, %arg4 * 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<354 -> 356, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1556 = affine.load %arg2[0, 1] {partition_indices = [0, 1], timing = #hlscpp.t<439 -> 441, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1557 = arith.mulf %1555, %1556 {timing = #hlscpp.t<451 -> 455, 4, 1>} : f32
        %1558 = arith.addf %1554, %1557 {timing = #hlscpp.t<455 -> 460, 5, 1>} : f32
        %1559 = affine.load %arg0[%arg3 * 8 + 7, %arg4 * 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<355 -> 357, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1560 = affine.load %arg2[2, 1] {partition_indices = [2, 1], timing = #hlscpp.t<444 -> 446, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1561 = arith.mulf %1559, %1560 {timing = #hlscpp.t<456 -> 460, 4, 1>} : f32
        %1562 = arith.addf %1558, %1561 {timing = #hlscpp.t<460 -> 465, 5, 1>} : f32
        %1563 = affine.load %arg0[%arg3 * 8 + 6, %arg4 * 15 + 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<356 -> 358, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1564 = affine.load %arg2[1, 2] {partition_indices = [1, 2], timing = #hlscpp.t<449 -> 451, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1565 = arith.mulf %1563, %1564 {timing = #hlscpp.t<461 -> 465, 4, 1>} : f32
        %1566 = arith.addf %1562, %1565 {timing = #hlscpp.t<465 -> 470, 5, 1>} : f32
        %1567 = affine.load %arg0[%arg3 * 8 + 5, %arg4 * 15 + 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<460 -> 462, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1568 = affine.load %arg2[0, 2] {partition_indices = [0, 2], timing = #hlscpp.t<454 -> 456, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1569 = arith.mulf %1567, %1568 {timing = #hlscpp.t<466 -> 470, 4, 1>} : f32
        %1570 = arith.addf %1566, %1569 {timing = #hlscpp.t<470 -> 475, 5, 1>} : f32
        %1571 = affine.load %arg0[%arg3 * 8 + 7, %arg4 * 15 + 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<468 -> 470, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1572 = affine.load %arg2[2, 2] {partition_indices = [2, 2], timing = #hlscpp.t<459 -> 461, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1573 = arith.mulf %1571, %1572 {timing = #hlscpp.t<471 -> 475, 4, 1>} : f32
        %1574 = arith.addf %1570, %1573 {timing = #hlscpp.t<475 -> 480, 5, 1>} : f32
        affine.store %1574, %arg1[%arg3 * 8 + 6, %arg4 * 15] {partition_indices = [6, 0], timing = #hlscpp.t<480 -> 481, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      } {timing = #hlscpp.t<350 -> 482, 132, 0>}
      %1287 = affine.load %arg0[%arg3 * 8 + 6, %arg4 * 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<362 -> 364, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %1288 = affine.load %arg2[1, 0] {partition_indices = [1, 0], timing = #hlscpp.t<426 -> 428, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
      %1289 = arith.mulf %1287, %1288 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %1290 = affine.load %arg0[%arg3 * 8 + 5, %arg4 * 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<363 -> 365, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %1291 = affine.load %arg2[0, 0] {partition_indices = [0, 0], timing = #hlscpp.t<426 -> 428, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
      %1292 = arith.mulf %1290, %1291 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %1293 = arith.addf %1289, %1292 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
      %1294 = affine.load %arg0[%arg3 * 8 + 7, %arg4 * 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<364 -> 366, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %1295 = affine.load %arg2[2, 0] {partition_indices = [2, 0], timing = #hlscpp.t<431 -> 433, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
      %1296 = arith.mulf %1294, %1295 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
      %1297 = arith.addf %1293, %1296 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
      %1298 = affine.load %arg0[%arg3 * 8 + 6, %arg4 * 15 + 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<365 -> 367, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %1299 = affine.load %arg2[1, 1] {partition_indices = [1, 1], timing = #hlscpp.t<436 -> 438, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
      %1300 = arith.mulf %1298, %1299 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
      %1301 = arith.addf %1297, %1300 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
      %1302 = affine.load %arg0[%arg3 * 8 + 5, %arg4 * 15 + 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<366 -> 368, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %1303 = affine.load %arg2[0, 1] {partition_indices = [0, 1], timing = #hlscpp.t<441 -> 443, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
      %1304 = arith.mulf %1302, %1303 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
      %1305 = arith.addf %1301, %1304 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
      %1306 = affine.load %arg0[%arg3 * 8 + 7, %arg4 * 15 + 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<367 -> 369, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %1307 = affine.load %arg2[2, 1] {partition_indices = [2, 1], timing = #hlscpp.t<446 -> 448, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
      %1308 = arith.mulf %1306, %1307 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
      %1309 = arith.addf %1305, %1308 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
      %1310 = affine.load %arg2[1, 2] {partition_indices = [1, 2], timing = #hlscpp.t<451 -> 453, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
      %1311 = arith.mulf %1063, %1310 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
      %1312 = arith.addf %1309, %1311 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
      %1313 = affine.load %arg2[0, 2] {partition_indices = [0, 2], timing = #hlscpp.t<456 -> 458, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
      %1314 = arith.mulf %810, %1313 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
      %1315 = arith.addf %1312, %1314 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
      %1316 = affine.load %arg0[%arg3 * 8 + 7, %arg4 * 15 + 2] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<368 -> 370, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %1317 = affine.load %arg2[2, 2] {partition_indices = [2, 2], timing = #hlscpp.t<461 -> 463, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
      %1318 = arith.mulf %1316, %1317 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
      %1319 = arith.addf %1315, %1318 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
      affine.store %1319, %arg1[%arg3 * 8 + 6, %arg4 * 15 + 1] {partition_indices = [6, 1], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      %1320 = arith.mulf %1298, %1288 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %1321 = arith.mulf %1302, %1291 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %1322 = arith.addf %1320, %1321 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
      %1323 = arith.mulf %1306, %1295 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
      %1324 = arith.addf %1322, %1323 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
      %1325 = arith.mulf %1063, %1299 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
      %1326 = arith.addf %1324, %1325 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
      %1327 = arith.mulf %810, %1303 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
      %1328 = arith.addf %1326, %1327 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
      %1329 = arith.mulf %1316, %1307 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
      %1330 = arith.addf %1328, %1329 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
      %1331 = arith.mulf %1082, %1310 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
      %1332 = arith.addf %1330, %1331 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
      %1333 = arith.mulf %829, %1313 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
      %1334 = arith.addf %1332, %1333 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
      %1335 = affine.load %arg0[%arg3 * 8 + 7, %arg4 * 15 + 3] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<369 -> 371, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %1336 = arith.mulf %1335, %1317 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
      %1337 = arith.addf %1334, %1336 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
      affine.store %1337, %arg1[%arg3 * 8 + 6, %arg4 * 15 + 2] {partition_indices = [6, 2], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      %1338 = arith.mulf %1063, %1288 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %1339 = arith.mulf %810, %1291 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %1340 = arith.addf %1338, %1339 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
      %1341 = arith.mulf %1316, %1295 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
      %1342 = arith.addf %1340, %1341 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
      %1343 = arith.mulf %1082, %1299 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
      %1344 = arith.addf %1342, %1343 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
      %1345 = arith.mulf %829, %1303 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
      %1346 = arith.addf %1344, %1345 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
      %1347 = arith.mulf %1335, %1307 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
      %1348 = arith.addf %1346, %1347 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
      %1349 = arith.mulf %1100, %1310 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
      %1350 = arith.addf %1348, %1349 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
      %1351 = arith.mulf %847, %1313 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
      %1352 = arith.addf %1350, %1351 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
      %1353 = affine.load %arg0[%arg3 * 8 + 7, %arg4 * 15 + 4] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<370 -> 372, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %1354 = arith.mulf %1353, %1317 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
      %1355 = arith.addf %1352, %1354 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
      affine.store %1355, %arg1[%arg3 * 8 + 6, %arg4 * 15 + 3] {partition_indices = [6, 3], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      %1356 = arith.mulf %1082, %1288 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %1357 = arith.mulf %829, %1291 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %1358 = arith.addf %1356, %1357 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
      %1359 = arith.mulf %1335, %1295 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
      %1360 = arith.addf %1358, %1359 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
      %1361 = arith.mulf %1100, %1299 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
      %1362 = arith.addf %1360, %1361 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
      %1363 = arith.mulf %847, %1303 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
      %1364 = arith.addf %1362, %1363 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
      %1365 = arith.mulf %1353, %1307 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
      %1366 = arith.addf %1364, %1365 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
      %1367 = arith.mulf %1118, %1310 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
      %1368 = arith.addf %1366, %1367 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
      %1369 = arith.mulf %865, %1313 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
      %1370 = arith.addf %1368, %1369 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
      %1371 = affine.load %arg0[%arg3 * 8 + 7, %arg4 * 15 + 5] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<371 -> 373, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %1372 = arith.mulf %1371, %1317 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
      %1373 = arith.addf %1370, %1372 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
      affine.store %1373, %arg1[%arg3 * 8 + 6, %arg4 * 15 + 4] {partition_indices = [6, 4], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      %1374 = arith.mulf %1100, %1288 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %1375 = arith.mulf %847, %1291 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %1376 = arith.addf %1374, %1375 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
      %1377 = arith.mulf %1353, %1295 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
      %1378 = arith.addf %1376, %1377 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
      %1379 = arith.mulf %1118, %1299 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
      %1380 = arith.addf %1378, %1379 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
      %1381 = arith.mulf %865, %1303 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
      %1382 = arith.addf %1380, %1381 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
      %1383 = arith.mulf %1371, %1307 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
      %1384 = arith.addf %1382, %1383 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
      %1385 = arith.mulf %1136, %1310 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
      %1386 = arith.addf %1384, %1385 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
      %1387 = arith.mulf %883, %1313 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
      %1388 = arith.addf %1386, %1387 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
      %1389 = affine.load %arg0[%arg3 * 8 + 7, %arg4 * 15 + 6] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<372 -> 374, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %1390 = arith.mulf %1389, %1317 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
      %1391 = arith.addf %1388, %1390 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
      affine.store %1391, %arg1[%arg3 * 8 + 6, %arg4 * 15 + 5] {partition_indices = [6, 5], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      %1392 = arith.mulf %1118, %1288 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %1393 = arith.mulf %865, %1291 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %1394 = arith.addf %1392, %1393 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
      %1395 = arith.mulf %1371, %1295 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
      %1396 = arith.addf %1394, %1395 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
      %1397 = arith.mulf %1136, %1299 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
      %1398 = arith.addf %1396, %1397 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
      %1399 = arith.mulf %883, %1303 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
      %1400 = arith.addf %1398, %1399 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
      %1401 = arith.mulf %1389, %1307 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
      %1402 = arith.addf %1400, %1401 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
      %1403 = arith.mulf %1154, %1310 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
      %1404 = arith.addf %1402, %1403 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
      %1405 = arith.mulf %901, %1313 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
      %1406 = arith.addf %1404, %1405 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
      %1407 = affine.load %arg0[%arg3 * 8 + 7, %arg4 * 15 + 7] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<373 -> 375, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %1408 = arith.mulf %1407, %1317 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
      %1409 = arith.addf %1406, %1408 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
      affine.store %1409, %arg1[%arg3 * 8 + 6, %arg4 * 15 + 6] {partition_indices = [6, 6], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      %1410 = arith.mulf %1136, %1288 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %1411 = arith.mulf %883, %1291 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %1412 = arith.addf %1410, %1411 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
      %1413 = arith.mulf %1389, %1295 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
      %1414 = arith.addf %1412, %1413 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
      %1415 = arith.mulf %1154, %1299 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
      %1416 = arith.addf %1414, %1415 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
      %1417 = arith.mulf %901, %1303 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
      %1418 = arith.addf %1416, %1417 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
      %1419 = arith.mulf %1407, %1307 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
      %1420 = arith.addf %1418, %1419 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
      %1421 = arith.mulf %1172, %1310 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
      %1422 = arith.addf %1420, %1421 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
      %1423 = arith.mulf %919, %1313 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
      %1424 = arith.addf %1422, %1423 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
      %1425 = affine.load %arg0[%arg3 * 8 + 7, %arg4 * 15 + 8] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<374 -> 376, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %1426 = arith.mulf %1425, %1317 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
      %1427 = arith.addf %1424, %1426 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
      affine.store %1427, %arg1[%arg3 * 8 + 6, %arg4 * 15 + 7] {partition_indices = [6, 7], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      %1428 = arith.mulf %1154, %1288 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %1429 = arith.mulf %901, %1291 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %1430 = arith.addf %1428, %1429 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
      %1431 = arith.mulf %1407, %1295 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
      %1432 = arith.addf %1430, %1431 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
      %1433 = arith.mulf %1172, %1299 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
      %1434 = arith.addf %1432, %1433 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
      %1435 = arith.mulf %919, %1303 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
      %1436 = arith.addf %1434, %1435 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
      %1437 = arith.mulf %1425, %1307 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
      %1438 = arith.addf %1436, %1437 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
      %1439 = arith.mulf %1190, %1310 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
      %1440 = arith.addf %1438, %1439 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
      %1441 = arith.mulf %937, %1313 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
      %1442 = arith.addf %1440, %1441 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
      %1443 = affine.load %arg0[%arg3 * 8 + 7, %arg4 * 15 + 9] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<375 -> 377, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %1444 = arith.mulf %1443, %1317 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
      %1445 = arith.addf %1442, %1444 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
      affine.store %1445, %arg1[%arg3 * 8 + 6, %arg4 * 15 + 8] {partition_indices = [6, 8], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      %1446 = arith.mulf %1172, %1288 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %1447 = arith.mulf %919, %1291 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %1448 = arith.addf %1446, %1447 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
      %1449 = arith.mulf %1425, %1295 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
      %1450 = arith.addf %1448, %1449 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
      %1451 = arith.mulf %1190, %1299 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
      %1452 = arith.addf %1450, %1451 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
      %1453 = arith.mulf %937, %1303 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
      %1454 = arith.addf %1452, %1453 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
      %1455 = arith.mulf %1443, %1307 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
      %1456 = arith.addf %1454, %1455 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
      %1457 = arith.mulf %1208, %1310 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
      %1458 = arith.addf %1456, %1457 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
      %1459 = arith.mulf %955, %1313 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
      %1460 = arith.addf %1458, %1459 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
      %1461 = affine.load %arg0[%arg3 * 8 + 7, %arg4 * 15 + 10] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<376 -> 378, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %1462 = arith.mulf %1461, %1317 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
      %1463 = arith.addf %1460, %1462 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
      affine.store %1463, %arg1[%arg3 * 8 + 6, %arg4 * 15 + 9] {partition_indices = [6, 9], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      %1464 = arith.mulf %1190, %1288 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %1465 = arith.mulf %937, %1291 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %1466 = arith.addf %1464, %1465 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
      %1467 = arith.mulf %1443, %1295 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
      %1468 = arith.addf %1466, %1467 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
      %1469 = arith.mulf %1208, %1299 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
      %1470 = arith.addf %1468, %1469 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
      %1471 = arith.mulf %955, %1303 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
      %1472 = arith.addf %1470, %1471 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
      %1473 = arith.mulf %1461, %1307 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
      %1474 = arith.addf %1472, %1473 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
      %1475 = arith.mulf %1226, %1310 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
      %1476 = arith.addf %1474, %1475 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
      %1477 = arith.mulf %973, %1313 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
      %1478 = arith.addf %1476, %1477 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
      %1479 = affine.load %arg0[%arg3 * 8 + 7, %arg4 * 15 + 11] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<377 -> 379, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %1480 = arith.mulf %1479, %1317 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
      %1481 = arith.addf %1478, %1480 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
      affine.store %1481, %arg1[%arg3 * 8 + 6, %arg4 * 15 + 10] {partition_indices = [6, 10], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      %1482 = arith.mulf %1208, %1288 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %1483 = arith.mulf %955, %1291 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %1484 = arith.addf %1482, %1483 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
      %1485 = arith.mulf %1461, %1295 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
      %1486 = arith.addf %1484, %1485 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
      %1487 = arith.mulf %1226, %1299 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
      %1488 = arith.addf %1486, %1487 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
      %1489 = arith.mulf %973, %1303 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
      %1490 = arith.addf %1488, %1489 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
      %1491 = arith.mulf %1479, %1307 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
      %1492 = arith.addf %1490, %1491 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
      %1493 = arith.mulf %1244, %1310 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
      %1494 = arith.addf %1492, %1493 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
      %1495 = arith.mulf %991, %1313 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
      %1496 = arith.addf %1494, %1495 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
      %1497 = affine.load %arg0[%arg3 * 8 + 7, %arg4 * 15 + 12] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<378 -> 380, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %1498 = arith.mulf %1497, %1317 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
      %1499 = arith.addf %1496, %1498 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
      affine.store %1499, %arg1[%arg3 * 8 + 6, %arg4 * 15 + 11] {partition_indices = [6, 11], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      %1500 = arith.mulf %1226, %1288 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %1501 = arith.mulf %973, %1291 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %1502 = arith.addf %1500, %1501 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
      %1503 = arith.mulf %1479, %1295 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
      %1504 = arith.addf %1502, %1503 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
      %1505 = arith.mulf %1244, %1299 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
      %1506 = arith.addf %1504, %1505 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
      %1507 = arith.mulf %991, %1303 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
      %1508 = arith.addf %1506, %1507 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
      %1509 = arith.mulf %1497, %1307 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
      %1510 = arith.addf %1508, %1509 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
      %1511 = affine.load %arg0[%arg3 * 8 + 6, %arg4 * 15 + 13] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<379 -> 381, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %1512 = arith.mulf %1511, %1310 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
      %1513 = arith.addf %1510, %1512 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
      %1514 = affine.load %arg0[%arg3 * 8 + 5, %arg4 * 15 + 13] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<380 -> 382, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %1515 = arith.mulf %1514, %1313 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
      %1516 = arith.addf %1513, %1515 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
      %1517 = affine.load %arg0[%arg3 * 8 + 7, %arg4 * 15 + 13] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<381 -> 383, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %1518 = arith.mulf %1517, %1317 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
      %1519 = arith.addf %1516, %1518 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
      affine.store %1519, %arg1[%arg3 * 8 + 6, %arg4 * 15 + 12] {partition_indices = [6, 12], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      %1520 = arith.mulf %1244, %1288 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %1521 = arith.mulf %991, %1291 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
      %1522 = arith.addf %1520, %1521 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
      %1523 = arith.mulf %1497, %1295 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
      %1524 = arith.addf %1522, %1523 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
      %1525 = arith.mulf %1511, %1299 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
      %1526 = arith.addf %1524, %1525 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
      %1527 = arith.mulf %1514, %1303 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
      %1528 = arith.addf %1526, %1527 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
      %1529 = arith.mulf %1517, %1307 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
      %1530 = arith.addf %1528, %1529 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
      %1531 = affine.load %arg0[%arg3 * 8 + 6, %arg4 * 15 + 14] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<382 -> 384, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %1532 = arith.mulf %1531, %1310 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
      %1533 = arith.addf %1530, %1532 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
      %1534 = affine.load %arg0[%arg3 * 8 + 5, %arg4 * 15 + 14] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<383 -> 385, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %1535 = arith.mulf %1534, %1313 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
      %1536 = arith.addf %1533, %1535 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
      %1537 = affine.load %arg0[%arg3 * 8 + 7, %arg4 * 15 + 14] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<384 -> 386, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
      %1538 = arith.mulf %1537, %1317 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
      %1539 = arith.addf %1536, %1538 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
      affine.store %1539, %arg1[%arg3 * 8 + 6, %arg4 * 15 + 13] {partition_indices = [6, 13], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      affine.if affine_set<(d0) : (d0 * 15 - 1065 == 0)>(%arg4) {
        %1540 = affine.load %arg0[%arg3 * 8 + 6, %arg4 * 15 + 13] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<390 -> 392, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1541 = affine.load %arg2[1, 0] {partition_indices = [1, 0], timing = #hlscpp.t<428 -> 430, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1542 = arith.mulf %1540, %1541 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
        %1543 = affine.load %arg0[%arg3 * 8 + 5, %arg4 * 15 + 13] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<391 -> 393, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1544 = affine.load %arg2[0, 0] {partition_indices = [0, 0], timing = #hlscpp.t<428 -> 430, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1545 = arith.mulf %1543, %1544 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
        %1546 = arith.addf %1542, %1545 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
        %1547 = affine.load %arg0[%arg3 * 8 + 7, %arg4 * 15 + 13] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<392 -> 394, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1548 = affine.load %arg2[2, 0] {partition_indices = [2, 0], timing = #hlscpp.t<433 -> 435, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1549 = arith.mulf %1547, %1548 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
        %1550 = arith.addf %1546, %1549 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
        %1551 = affine.load %arg0[%arg3 * 8 + 6, %arg4 * 15 + 14] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<393 -> 395, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1552 = affine.load %arg2[1, 1] {partition_indices = [1, 1], timing = #hlscpp.t<438 -> 440, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1553 = arith.mulf %1551, %1552 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
        %1554 = arith.addf %1550, %1553 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
        %1555 = affine.load %arg0[%arg3 * 8 + 5, %arg4 * 15 + 14] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<394 -> 396, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1556 = affine.load %arg2[0, 1] {partition_indices = [0, 1], timing = #hlscpp.t<443 -> 445, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1557 = arith.mulf %1555, %1556 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
        %1558 = arith.addf %1554, %1557 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
        %1559 = affine.load %arg0[%arg3 * 8 + 7, %arg4 * 15 + 14] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<455 -> 457, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1560 = affine.load %arg2[2, 1] {partition_indices = [2, 1], timing = #hlscpp.t<448 -> 450, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1561 = arith.mulf %1559, %1560 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
        %1562 = arith.addf %1558, %1561 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
        %1563 = affine.load %arg2[1, 2] {partition_indices = [1, 2], timing = #hlscpp.t<453 -> 455, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1564 = arith.mulf %1540, %1563 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
        %1565 = arith.addf %1562, %1564 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
        %1566 = affine.load %arg2[0, 2] {partition_indices = [0, 2], timing = #hlscpp.t<458 -> 460, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1567 = arith.mulf %1543, %1566 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
        %1568 = arith.addf %1565, %1567 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
        %1569 = affine.load %arg2[2, 2] {partition_indices = [2, 2], timing = #hlscpp.t<463 -> 465, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1570 = arith.mulf %1547, %1569 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
        %1571 = arith.addf %1568, %1570 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
        affine.store %1571, %arg1[%arg3 * 8 + 6, %arg4 * 15 + 14] {partition_indices = [6, 14], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      } else {
        %1540 = affine.load %arg0[%arg3 * 8 + 6, %arg4 * 15 + 13] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<385 -> 387, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1541 = affine.load %arg2[1, 0] {partition_indices = [1, 0], timing = #hlscpp.t<427 -> 429, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1542 = arith.mulf %1540, %1541 {timing = #hlscpp.t<436 -> 440, 4, 1>} : f32
        %1543 = affine.load %arg0[%arg3 * 8 + 5, %arg4 * 15 + 13] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<386 -> 388, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1544 = affine.load %arg2[0, 0] {partition_indices = [0, 0], timing = #hlscpp.t<427 -> 429, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1545 = arith.mulf %1543, %1544 {timing = #hlscpp.t<436 -> 440, 4, 1>} : f32
        %1546 = arith.addf %1542, %1545 {timing = #hlscpp.t<440 -> 445, 5, 1>} : f32
        %1547 = affine.load %arg0[%arg3 * 8 + 7, %arg4 * 15 + 13] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<387 -> 389, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1548 = affine.load %arg2[2, 0] {partition_indices = [2, 0], timing = #hlscpp.t<432 -> 434, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1549 = arith.mulf %1547, %1548 {timing = #hlscpp.t<441 -> 445, 4, 1>} : f32
        %1550 = arith.addf %1546, %1549 {timing = #hlscpp.t<445 -> 450, 5, 1>} : f32
        %1551 = affine.load %arg0[%arg3 * 8 + 6, %arg4 * 15 + 14] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<388 -> 390, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1552 = affine.load %arg2[1, 1] {partition_indices = [1, 1], timing = #hlscpp.t<437 -> 439, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1553 = arith.mulf %1551, %1552 {timing = #hlscpp.t<446 -> 450, 4, 1>} : f32
        %1554 = arith.addf %1550, %1553 {timing = #hlscpp.t<450 -> 455, 5, 1>} : f32
        %1555 = affine.load %arg0[%arg3 * 8 + 5, %arg4 * 15 + 14] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<389 -> 391, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1556 = affine.load %arg2[0, 1] {partition_indices = [0, 1], timing = #hlscpp.t<442 -> 444, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1557 = arith.mulf %1555, %1556 {timing = #hlscpp.t<451 -> 455, 4, 1>} : f32
        %1558 = arith.addf %1554, %1557 {timing = #hlscpp.t<455 -> 460, 5, 1>} : f32
        %1559 = affine.load %arg0[%arg3 * 8 + 7, %arg4 * 15 + 14] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<454 -> 456, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1560 = affine.load %arg2[2, 1] {partition_indices = [2, 1], timing = #hlscpp.t<447 -> 449, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1561 = arith.mulf %1559, %1560 {timing = #hlscpp.t<456 -> 460, 4, 1>} : f32
        %1562 = arith.addf %1558, %1561 {timing = #hlscpp.t<460 -> 465, 5, 1>} : f32
        %1563 = affine.load %arg0[%arg3 * 8 + 6, %arg4 * 15 + 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<456 -> 458, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1564 = affine.load %arg2[1, 2] {partition_indices = [1, 2], timing = #hlscpp.t<452 -> 454, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1565 = arith.mulf %1563, %1564 {timing = #hlscpp.t<461 -> 465, 4, 1>} : f32
        %1566 = arith.addf %1562, %1565 {timing = #hlscpp.t<465 -> 470, 5, 1>} : f32
        %1567 = affine.load %arg0[%arg3 * 8 + 5, %arg4 * 15 + 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<461 -> 463, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1568 = affine.load %arg2[0, 2] {partition_indices = [0, 2], timing = #hlscpp.t<457 -> 459, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1569 = arith.mulf %1567, %1568 {timing = #hlscpp.t<466 -> 470, 4, 1>} : f32
        %1570 = arith.addf %1566, %1569 {timing = #hlscpp.t<470 -> 475, 5, 1>} : f32
        %1571 = affine.load %arg0[%arg3 * 8 + 7, %arg4 * 15 + 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<469 -> 471, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1572 = affine.load %arg2[2, 2] {partition_indices = [2, 2], timing = #hlscpp.t<462 -> 464, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1573 = arith.mulf %1571, %1572 {timing = #hlscpp.t<471 -> 475, 4, 1>} : f32
        %1574 = arith.addf %1570, %1573 {timing = #hlscpp.t<475 -> 480, 5, 1>} : f32
        affine.store %1574, %arg1[%arg3 * 8 + 6, %arg4 * 15 + 14] {partition_indices = [6, 14], timing = #hlscpp.t<480 -> 481, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
      } {timing = #hlscpp.t<385 -> 482, 97, 0>}
      affine.if affine_set<(d0) : (d0 * 8 - 1912 == 0)>(%arg3) {
        affine.if affine_set<(d0) : (d0 * 15 == 0)>(%arg4) {
          %1800 = affine.load %arg0[%arg3 * 8 + 7, %arg4 * 15 + 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<402 -> 404, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
          %1801 = affine.load %arg2[1, 0] {partition_indices = [1, 0], timing = #hlscpp.t<432 -> 434, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1802 = arith.mulf %1800, %1801 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
          %1803 = affine.load %arg0[%arg3 * 8 + 6, %arg4 * 15 + 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<403 -> 405, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
          %1804 = affine.load %arg2[0, 0] {partition_indices = [0, 0], timing = #hlscpp.t<432 -> 434, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1805 = arith.mulf %1803, %1804 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
          %1806 = arith.addf %1802, %1805 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
          %1807 = affine.load %arg2[2, 0] {partition_indices = [2, 0], timing = #hlscpp.t<437 -> 439, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1808 = arith.mulf %1803, %1807 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
          %1809 = arith.addf %1806, %1808 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
          %1810 = affine.load %arg0[%arg3 * 8 + 7, %arg4 * 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<443 -> 445, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
          %1811 = affine.load %arg2[1, 1] {partition_indices = [1, 1], timing = #hlscpp.t<442 -> 444, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1812 = arith.mulf %1810, %1811 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
          %1813 = arith.addf %1809, %1812 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
          %1814 = affine.load %arg0[%arg3 * 8 + 6, %arg4 * 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<448 -> 450, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
          %1815 = affine.load %arg2[0, 1] {partition_indices = [0, 1], timing = #hlscpp.t<447 -> 449, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1816 = arith.mulf %1814, %1815 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
          %1817 = arith.addf %1813, %1816 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
          %1818 = affine.load %arg2[2, 1] {partition_indices = [2, 1], timing = #hlscpp.t<452 -> 454, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1819 = arith.mulf %1814, %1818 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
          %1820 = arith.addf %1817, %1819 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
          %1821 = affine.load %arg2[1, 2] {partition_indices = [1, 2], timing = #hlscpp.t<457 -> 459, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1822 = arith.mulf %1800, %1821 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
          %1823 = arith.addf %1820, %1822 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
          %1824 = affine.load %arg2[0, 2] {partition_indices = [0, 2], timing = #hlscpp.t<462 -> 464, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1825 = arith.mulf %1803, %1824 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
          %1826 = arith.addf %1823, %1825 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
          %1827 = affine.load %arg2[2, 2] {partition_indices = [2, 2], timing = #hlscpp.t<467 -> 469, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1828 = arith.mulf %1803, %1827 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
          %1829 = arith.addf %1826, %1828 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
          affine.store %1829, %arg1[%arg3 * 8 + 7, %arg4 * 15] {partition_indices = [7, 0], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
        } else {
          %1800 = affine.load %arg0[%arg3 * 8 + 7, %arg4 * 15 - 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<400 -> 402, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
          %1801 = affine.load %arg2[1, 0] {partition_indices = [1, 0], timing = #hlscpp.t<431 -> 433, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1802 = arith.mulf %1800, %1801 {timing = #hlscpp.t<436 -> 440, 4, 1>} : f32
          %1803 = affine.load %arg0[%arg3 * 8 + 6, %arg4 * 15 - 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<401 -> 403, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
          %1804 = affine.load %arg2[0, 0] {partition_indices = [0, 0], timing = #hlscpp.t<431 -> 433, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1805 = arith.mulf %1803, %1804 {timing = #hlscpp.t<436 -> 440, 4, 1>} : f32
          %1806 = arith.addf %1802, %1805 {timing = #hlscpp.t<440 -> 445, 5, 1>} : f32
          %1807 = affine.load %arg2[2, 0] {partition_indices = [2, 0], timing = #hlscpp.t<436 -> 438, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1808 = arith.mulf %1803, %1807 {timing = #hlscpp.t<441 -> 445, 4, 1>} : f32
          %1809 = arith.addf %1806, %1808 {timing = #hlscpp.t<445 -> 450, 5, 1>} : f32
          %1810 = affine.load %arg0[%arg3 * 8 + 7, %arg4 * 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<441 -> 443, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
          %1811 = affine.load %arg2[1, 1] {partition_indices = [1, 1], timing = #hlscpp.t<441 -> 443, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1812 = arith.mulf %1810, %1811 {timing = #hlscpp.t<446 -> 450, 4, 1>} : f32
          %1813 = arith.addf %1809, %1812 {timing = #hlscpp.t<450 -> 455, 5, 1>} : f32
          %1814 = affine.load %arg0[%arg3 * 8 + 6, %arg4 * 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<446 -> 448, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
          %1815 = affine.load %arg2[0, 1] {partition_indices = [0, 1], timing = #hlscpp.t<446 -> 448, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1816 = arith.mulf %1814, %1815 {timing = #hlscpp.t<451 -> 455, 4, 1>} : f32
          %1817 = arith.addf %1813, %1816 {timing = #hlscpp.t<455 -> 460, 5, 1>} : f32
          %1818 = affine.load %arg2[2, 1] {partition_indices = [2, 1], timing = #hlscpp.t<451 -> 453, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1819 = arith.mulf %1814, %1818 {timing = #hlscpp.t<456 -> 460, 4, 1>} : f32
          %1820 = arith.addf %1817, %1819 {timing = #hlscpp.t<460 -> 465, 5, 1>} : f32
          %1821 = affine.load %arg0[%arg3 * 8 + 7, %arg4 * 15 + 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<458 -> 460, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
          %1822 = affine.load %arg2[1, 2] {partition_indices = [1, 2], timing = #hlscpp.t<456 -> 458, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1823 = arith.mulf %1821, %1822 {timing = #hlscpp.t<461 -> 465, 4, 1>} : f32
          %1824 = arith.addf %1820, %1823 {timing = #hlscpp.t<465 -> 470, 5, 1>} : f32
          %1825 = affine.load %arg0[%arg3 * 8 + 6, %arg4 * 15 + 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<463 -> 465, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
          %1826 = affine.load %arg2[0, 2] {partition_indices = [0, 2], timing = #hlscpp.t<461 -> 463, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1827 = arith.mulf %1825, %1826 {timing = #hlscpp.t<466 -> 470, 4, 1>} : f32
          %1828 = arith.addf %1824, %1827 {timing = #hlscpp.t<470 -> 475, 5, 1>} : f32
          %1829 = affine.load %arg2[2, 2] {partition_indices = [2, 2], timing = #hlscpp.t<466 -> 468, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1830 = arith.mulf %1825, %1829 {timing = #hlscpp.t<471 -> 475, 4, 1>} : f32
          %1831 = arith.addf %1828, %1830 {timing = #hlscpp.t<475 -> 480, 5, 1>} : f32
          affine.store %1831, %arg1[%arg3 * 8 + 7, %arg4 * 15] {partition_indices = [7, 0], timing = #hlscpp.t<480 -> 481, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
        } {timing = #hlscpp.t<400 -> 482, 82, 0>}
        %1540 = affine.load %arg0[%arg3 * 8 + 7, %arg4 * 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<404 -> 406, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1541 = affine.load %arg2[1, 0] {partition_indices = [1, 0], timing = #hlscpp.t<433 -> 435, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1542 = arith.mulf %1540, %1541 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
        %1543 = affine.load %arg0[%arg3 * 8 + 6, %arg4 * 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<405 -> 407, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1544 = affine.load %arg2[0, 0] {partition_indices = [0, 0], timing = #hlscpp.t<433 -> 435, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1545 = arith.mulf %1543, %1544 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
        %1546 = arith.addf %1542, %1545 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
        %1547 = affine.load %arg2[2, 0] {partition_indices = [2, 0], timing = #hlscpp.t<438 -> 440, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1548 = arith.mulf %1543, %1547 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
        %1549 = arith.addf %1546, %1548 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
        %1550 = affine.load %arg0[%arg3 * 8 + 7, %arg4 * 15 + 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<406 -> 408, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1551 = affine.load %arg2[1, 1] {partition_indices = [1, 1], timing = #hlscpp.t<443 -> 445, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1552 = arith.mulf %1550, %1551 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
        %1553 = arith.addf %1549, %1552 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
        %1554 = affine.load %arg0[%arg3 * 8 + 6, %arg4 * 15 + 1] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<407 -> 409, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1555 = affine.load %arg2[0, 1] {partition_indices = [0, 1], timing = #hlscpp.t<448 -> 450, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1556 = arith.mulf %1554, %1555 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
        %1557 = arith.addf %1553, %1556 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
        %1558 = affine.load %arg2[2, 1] {partition_indices = [2, 1], timing = #hlscpp.t<453 -> 455, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1559 = arith.mulf %1554, %1558 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
        %1560 = arith.addf %1557, %1559 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
        %1561 = affine.load %arg0[%arg3 * 8 + 7, %arg4 * 15 + 2] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<408 -> 410, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1562 = affine.load %arg2[1, 2] {partition_indices = [1, 2], timing = #hlscpp.t<458 -> 460, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1563 = arith.mulf %1561, %1562 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
        %1564 = arith.addf %1560, %1563 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
        %1565 = affine.load %arg0[%arg3 * 8 + 6, %arg4 * 15 + 2] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<409 -> 411, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1566 = affine.load %arg2[0, 2] {partition_indices = [0, 2], timing = #hlscpp.t<463 -> 465, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1567 = arith.mulf %1565, %1566 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
        %1568 = arith.addf %1564, %1567 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
        %1569 = affine.load %arg2[2, 2] {partition_indices = [2, 2], timing = #hlscpp.t<468 -> 470, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
        %1570 = arith.mulf %1565, %1569 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
        %1571 = arith.addf %1568, %1570 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
        affine.store %1571, %arg1[%arg3 * 8 + 7, %arg4 * 15 + 1] {partition_indices = [7, 1], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
        %1572 = arith.mulf %1550, %1541 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
        %1573 = arith.mulf %1554, %1544 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
        %1574 = arith.addf %1572, %1573 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
        %1575 = arith.mulf %1554, %1547 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
        %1576 = arith.addf %1574, %1575 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
        %1577 = arith.mulf %1561, %1551 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
        %1578 = arith.addf %1576, %1577 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
        %1579 = arith.mulf %1565, %1555 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
        %1580 = arith.addf %1578, %1579 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
        %1581 = arith.mulf %1565, %1558 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
        %1582 = arith.addf %1580, %1581 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
        %1583 = affine.load %arg0[%arg3 * 8 + 7, %arg4 * 15 + 3] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<410 -> 412, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1584 = arith.mulf %1583, %1562 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
        %1585 = arith.addf %1582, %1584 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
        %1586 = affine.load %arg0[%arg3 * 8 + 6, %arg4 * 15 + 3] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<411 -> 413, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1587 = arith.mulf %1586, %1566 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
        %1588 = arith.addf %1585, %1587 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
        %1589 = arith.mulf %1586, %1569 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
        %1590 = arith.addf %1588, %1589 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
        affine.store %1590, %arg1[%arg3 * 8 + 7, %arg4 * 15 + 2] {partition_indices = [7, 2], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
        %1591 = arith.mulf %1561, %1541 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
        %1592 = arith.mulf %1565, %1544 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
        %1593 = arith.addf %1591, %1592 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
        %1594 = arith.mulf %1565, %1547 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
        %1595 = arith.addf %1593, %1594 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
        %1596 = arith.mulf %1583, %1551 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
        %1597 = arith.addf %1595, %1596 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
        %1598 = arith.mulf %1586, %1555 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
        %1599 = arith.addf %1597, %1598 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
        %1600 = arith.mulf %1586, %1558 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
        %1601 = arith.addf %1599, %1600 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
        %1602 = affine.load %arg0[%arg3 * 8 + 7, %arg4 * 15 + 4] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<412 -> 414, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1603 = arith.mulf %1602, %1562 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
        %1604 = arith.addf %1601, %1603 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
        %1605 = affine.load %arg0[%arg3 * 8 + 6, %arg4 * 15 + 4] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<413 -> 415, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1606 = arith.mulf %1605, %1566 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
        %1607 = arith.addf %1604, %1606 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
        %1608 = arith.mulf %1605, %1569 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
        %1609 = arith.addf %1607, %1608 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
        affine.store %1609, %arg1[%arg3 * 8 + 7, %arg4 * 15 + 3] {partition_indices = [7, 3], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
        %1610 = arith.mulf %1583, %1541 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
        %1611 = arith.mulf %1586, %1544 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
        %1612 = arith.addf %1610, %1611 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
        %1613 = arith.mulf %1586, %1547 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
        %1614 = arith.addf %1612, %1613 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
        %1615 = arith.mulf %1602, %1551 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
        %1616 = arith.addf %1614, %1615 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
        %1617 = arith.mulf %1605, %1555 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
        %1618 = arith.addf %1616, %1617 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
        %1619 = arith.mulf %1605, %1558 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
        %1620 = arith.addf %1618, %1619 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
        %1621 = affine.load %arg0[%arg3 * 8 + 7, %arg4 * 15 + 5] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<414 -> 416, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1622 = arith.mulf %1621, %1562 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
        %1623 = arith.addf %1620, %1622 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
        %1624 = affine.load %arg0[%arg3 * 8 + 6, %arg4 * 15 + 5] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<415 -> 417, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1625 = arith.mulf %1624, %1566 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
        %1626 = arith.addf %1623, %1625 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
        %1627 = arith.mulf %1624, %1569 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
        %1628 = arith.addf %1626, %1627 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
        affine.store %1628, %arg1[%arg3 * 8 + 7, %arg4 * 15 + 4] {partition_indices = [7, 4], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
        %1629 = arith.mulf %1602, %1541 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
        %1630 = arith.mulf %1605, %1544 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
        %1631 = arith.addf %1629, %1630 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
        %1632 = arith.mulf %1605, %1547 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
        %1633 = arith.addf %1631, %1632 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
        %1634 = arith.mulf %1621, %1551 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
        %1635 = arith.addf %1633, %1634 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
        %1636 = arith.mulf %1624, %1555 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
        %1637 = arith.addf %1635, %1636 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
        %1638 = arith.mulf %1624, %1558 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
        %1639 = arith.addf %1637, %1638 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
        %1640 = affine.load %arg0[%arg3 * 8 + 7, %arg4 * 15 + 6] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<416 -> 418, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1641 = arith.mulf %1640, %1562 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
        %1642 = arith.addf %1639, %1641 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
        %1643 = affine.load %arg0[%arg3 * 8 + 6, %arg4 * 15 + 6] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<417 -> 419, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1644 = arith.mulf %1643, %1566 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
        %1645 = arith.addf %1642, %1644 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
        %1646 = arith.mulf %1643, %1569 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
        %1647 = arith.addf %1645, %1646 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
        affine.store %1647, %arg1[%arg3 * 8 + 7, %arg4 * 15 + 5] {partition_indices = [7, 5], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
        %1648 = arith.mulf %1621, %1541 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
        %1649 = arith.mulf %1624, %1544 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
        %1650 = arith.addf %1648, %1649 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
        %1651 = arith.mulf %1624, %1547 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
        %1652 = arith.addf %1650, %1651 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
        %1653 = arith.mulf %1640, %1551 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
        %1654 = arith.addf %1652, %1653 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
        %1655 = arith.mulf %1643, %1555 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
        %1656 = arith.addf %1654, %1655 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
        %1657 = arith.mulf %1643, %1558 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
        %1658 = arith.addf %1656, %1657 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
        %1659 = affine.load %arg0[%arg3 * 8 + 7, %arg4 * 15 + 7] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<418 -> 420, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1660 = arith.mulf %1659, %1562 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
        %1661 = arith.addf %1658, %1660 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
        %1662 = affine.load %arg0[%arg3 * 8 + 6, %arg4 * 15 + 7] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<419 -> 421, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1663 = arith.mulf %1662, %1566 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
        %1664 = arith.addf %1661, %1663 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
        %1665 = arith.mulf %1662, %1569 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
        %1666 = arith.addf %1664, %1665 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
        affine.store %1666, %arg1[%arg3 * 8 + 7, %arg4 * 15 + 6] {partition_indices = [7, 6], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
        %1667 = arith.mulf %1640, %1541 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
        %1668 = arith.mulf %1643, %1544 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
        %1669 = arith.addf %1667, %1668 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
        %1670 = arith.mulf %1643, %1547 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
        %1671 = arith.addf %1669, %1670 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
        %1672 = arith.mulf %1659, %1551 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
        %1673 = arith.addf %1671, %1672 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
        %1674 = arith.mulf %1662, %1555 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
        %1675 = arith.addf %1673, %1674 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
        %1676 = arith.mulf %1662, %1558 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
        %1677 = arith.addf %1675, %1676 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
        %1678 = affine.load %arg0[%arg3 * 8 + 7, %arg4 * 15 + 8] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<420 -> 422, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1679 = arith.mulf %1678, %1562 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
        %1680 = arith.addf %1677, %1679 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
        %1681 = affine.load %arg0[%arg3 * 8 + 6, %arg4 * 15 + 8] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<421 -> 423, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1682 = arith.mulf %1681, %1566 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
        %1683 = arith.addf %1680, %1682 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
        %1684 = arith.mulf %1681, %1569 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
        %1685 = arith.addf %1683, %1684 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
        affine.store %1685, %arg1[%arg3 * 8 + 7, %arg4 * 15 + 7] {partition_indices = [7, 7], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
        %1686 = arith.mulf %1659, %1541 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
        %1687 = arith.mulf %1662, %1544 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
        %1688 = arith.addf %1686, %1687 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
        %1689 = arith.mulf %1662, %1547 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
        %1690 = arith.addf %1688, %1689 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
        %1691 = arith.mulf %1678, %1551 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
        %1692 = arith.addf %1690, %1691 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
        %1693 = arith.mulf %1681, %1555 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
        %1694 = arith.addf %1692, %1693 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
        %1695 = arith.mulf %1681, %1558 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
        %1696 = arith.addf %1694, %1695 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
        %1697 = affine.load %arg0[%arg3 * 8 + 7, %arg4 * 15 + 9] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<422 -> 424, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1698 = arith.mulf %1697, %1562 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
        %1699 = arith.addf %1696, %1698 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
        %1700 = affine.load %arg0[%arg3 * 8 + 6, %arg4 * 15 + 9] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<423 -> 425, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1701 = arith.mulf %1700, %1566 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
        %1702 = arith.addf %1699, %1701 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
        %1703 = arith.mulf %1700, %1569 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
        %1704 = arith.addf %1702, %1703 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
        affine.store %1704, %arg1[%arg3 * 8 + 7, %arg4 * 15 + 8] {partition_indices = [7, 8], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
        %1705 = arith.mulf %1678, %1541 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
        %1706 = arith.mulf %1681, %1544 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
        %1707 = arith.addf %1705, %1706 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
        %1708 = arith.mulf %1681, %1547 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
        %1709 = arith.addf %1707, %1708 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
        %1710 = arith.mulf %1697, %1551 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
        %1711 = arith.addf %1709, %1710 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
        %1712 = arith.mulf %1700, %1555 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
        %1713 = arith.addf %1711, %1712 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
        %1714 = arith.mulf %1700, %1558 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
        %1715 = arith.addf %1713, %1714 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
        %1716 = affine.load %arg0[%arg3 * 8 + 7, %arg4 * 15 + 10] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<424 -> 426, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1717 = arith.mulf %1716, %1562 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
        %1718 = arith.addf %1715, %1717 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
        %1719 = affine.load %arg0[%arg3 * 8 + 6, %arg4 * 15 + 10] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<425 -> 427, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1720 = arith.mulf %1719, %1566 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
        %1721 = arith.addf %1718, %1720 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
        %1722 = arith.mulf %1719, %1569 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
        %1723 = arith.addf %1721, %1722 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
        affine.store %1723, %arg1[%arg3 * 8 + 7, %arg4 * 15 + 9] {partition_indices = [7, 9], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
        %1724 = arith.mulf %1697, %1541 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
        %1725 = arith.mulf %1700, %1544 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
        %1726 = arith.addf %1724, %1725 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
        %1727 = arith.mulf %1700, %1547 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
        %1728 = arith.addf %1726, %1727 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
        %1729 = arith.mulf %1716, %1551 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
        %1730 = arith.addf %1728, %1729 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
        %1731 = arith.mulf %1719, %1555 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
        %1732 = arith.addf %1730, %1731 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
        %1733 = arith.mulf %1719, %1558 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
        %1734 = arith.addf %1732, %1733 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
        %1735 = affine.load %arg0[%arg3 * 8 + 7, %arg4 * 15 + 11] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<426 -> 428, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1736 = arith.mulf %1735, %1562 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
        %1737 = arith.addf %1734, %1736 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
        %1738 = affine.load %arg0[%arg3 * 8 + 6, %arg4 * 15 + 11] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<427 -> 429, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1739 = arith.mulf %1738, %1566 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
        %1740 = arith.addf %1737, %1739 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
        %1741 = arith.mulf %1738, %1569 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
        %1742 = arith.addf %1740, %1741 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
        affine.store %1742, %arg1[%arg3 * 8 + 7, %arg4 * 15 + 10] {partition_indices = [7, 10], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
        %1743 = arith.mulf %1716, %1541 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
        %1744 = arith.mulf %1719, %1544 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
        %1745 = arith.addf %1743, %1744 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
        %1746 = arith.mulf %1719, %1547 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
        %1747 = arith.addf %1745, %1746 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
        %1748 = arith.mulf %1735, %1551 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
        %1749 = arith.addf %1747, %1748 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
        %1750 = arith.mulf %1738, %1555 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
        %1751 = arith.addf %1749, %1750 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
        %1752 = arith.mulf %1738, %1558 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
        %1753 = arith.addf %1751, %1752 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
        %1754 = affine.load %arg0[%arg3 * 8 + 7, %arg4 * 15 + 12] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<428 -> 430, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1755 = arith.mulf %1754, %1562 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
        %1756 = arith.addf %1753, %1755 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
        %1757 = affine.load %arg0[%arg3 * 8 + 6, %arg4 * 15 + 12] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<429 -> 431, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1758 = arith.mulf %1757, %1566 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
        %1759 = arith.addf %1756, %1758 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
        %1760 = arith.mulf %1757, %1569 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
        %1761 = arith.addf %1759, %1760 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
        affine.store %1761, %arg1[%arg3 * 8 + 7, %arg4 * 15 + 11] {partition_indices = [7, 11], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
        %1762 = arith.mulf %1735, %1541 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
        %1763 = arith.mulf %1738, %1544 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
        %1764 = arith.addf %1762, %1763 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
        %1765 = arith.mulf %1738, %1547 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
        %1766 = arith.addf %1764, %1765 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
        %1767 = arith.mulf %1754, %1551 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
        %1768 = arith.addf %1766, %1767 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
        %1769 = arith.mulf %1757, %1555 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
        %1770 = arith.addf %1768, %1769 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
        %1771 = arith.mulf %1757, %1558 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
        %1772 = arith.addf %1770, %1771 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
        %1773 = affine.load %arg0[%arg3 * 8 + 7, %arg4 * 15 + 13] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<430 -> 432, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1774 = arith.mulf %1773, %1562 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
        %1775 = arith.addf %1772, %1774 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
        %1776 = affine.load %arg0[%arg3 * 8 + 6, %arg4 * 15 + 13] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<431 -> 433, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1777 = arith.mulf %1776, %1566 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
        %1778 = arith.addf %1775, %1777 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
        %1779 = arith.mulf %1776, %1569 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
        %1780 = arith.addf %1778, %1779 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
        affine.store %1780, %arg1[%arg3 * 8 + 7, %arg4 * 15 + 12] {partition_indices = [7, 12], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
        %1781 = arith.mulf %1754, %1541 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
        %1782 = arith.mulf %1757, %1544 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
        %1783 = arith.addf %1781, %1782 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
        %1784 = arith.mulf %1757, %1547 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
        %1785 = arith.addf %1783, %1784 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
        %1786 = arith.mulf %1773, %1551 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
        %1787 = arith.addf %1785, %1786 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
        %1788 = arith.mulf %1776, %1555 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
        %1789 = arith.addf %1787, %1788 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
        %1790 = arith.mulf %1776, %1558 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
        %1791 = arith.addf %1789, %1790 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
        %1792 = affine.load %arg0[%arg3 * 8 + 7, %arg4 * 15 + 14] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<442 -> 444, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1793 = arith.mulf %1792, %1562 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
        %1794 = arith.addf %1791, %1793 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
        %1795 = affine.load %arg0[%arg3 * 8 + 6, %arg4 * 15 + 14] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<447 -> 449, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
        %1796 = arith.mulf %1795, %1566 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
        %1797 = arith.addf %1794, %1796 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
        %1798 = arith.mulf %1795, %1569 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
        %1799 = arith.addf %1797, %1798 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
        affine.store %1799, %arg1[%arg3 * 8 + 7, %arg4 * 15 + 13] {partition_indices = [7, 13], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
        affine.if affine_set<(d0) : (d0 * 15 - 1065 == 0)>(%arg4) {
          %1800 = affine.load %arg0[%arg3 * 8 + 7, %arg4 * 15 + 13] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<434 -> 436, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
          %1801 = affine.load %arg2[1, 0] {partition_indices = [1, 0], timing = #hlscpp.t<435 -> 437, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1802 = arith.mulf %1800, %1801 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
          %1803 = affine.load %arg0[%arg3 * 8 + 6, %arg4 * 15 + 13] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<435 -> 437, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
          %1804 = affine.load %arg2[0, 0] {partition_indices = [0, 0], timing = #hlscpp.t<435 -> 437, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1805 = arith.mulf %1803, %1804 {timing = #hlscpp.t<437 -> 441, 4, 1>} : f32
          %1806 = arith.addf %1802, %1805 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f32
          %1807 = affine.load %arg2[2, 0] {partition_indices = [2, 0], timing = #hlscpp.t<440 -> 442, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1808 = arith.mulf %1803, %1807 {timing = #hlscpp.t<442 -> 446, 4, 1>} : f32
          %1809 = arith.addf %1806, %1808 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f32
          %1810 = affine.load %arg0[%arg3 * 8 + 7, %arg4 * 15 + 14] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<445 -> 447, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
          %1811 = affine.load %arg2[1, 1] {partition_indices = [1, 1], timing = #hlscpp.t<445 -> 447, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1812 = arith.mulf %1810, %1811 {timing = #hlscpp.t<447 -> 451, 4, 1>} : f32
          %1813 = arith.addf %1809, %1812 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f32
          %1814 = affine.load %arg0[%arg3 * 8 + 6, %arg4 * 15 + 14] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<450 -> 452, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
          %1815 = affine.load %arg2[0, 1] {partition_indices = [0, 1], timing = #hlscpp.t<450 -> 452, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1816 = arith.mulf %1814, %1815 {timing = #hlscpp.t<452 -> 456, 4, 1>} : f32
          %1817 = arith.addf %1813, %1816 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f32
          %1818 = affine.load %arg2[2, 1] {partition_indices = [2, 1], timing = #hlscpp.t<455 -> 457, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1819 = arith.mulf %1814, %1818 {timing = #hlscpp.t<457 -> 461, 4, 1>} : f32
          %1820 = arith.addf %1817, %1819 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f32
          %1821 = affine.load %arg2[1, 2] {partition_indices = [1, 2], timing = #hlscpp.t<460 -> 462, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1822 = arith.mulf %1800, %1821 {timing = #hlscpp.t<462 -> 466, 4, 1>} : f32
          %1823 = arith.addf %1820, %1822 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f32
          %1824 = affine.load %arg2[0, 2] {partition_indices = [0, 2], timing = #hlscpp.t<465 -> 467, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1825 = arith.mulf %1803, %1824 {timing = #hlscpp.t<467 -> 471, 4, 1>} : f32
          %1826 = arith.addf %1823, %1825 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f32
          %1827 = affine.load %arg2[2, 2] {partition_indices = [2, 2], timing = #hlscpp.t<470 -> 472, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1828 = arith.mulf %1803, %1827 {timing = #hlscpp.t<472 -> 476, 4, 1>} : f32
          %1829 = arith.addf %1826, %1828 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f32
          affine.store %1829, %arg1[%arg3 * 8 + 7, %arg4 * 15 + 14] {partition_indices = [7, 14], timing = #hlscpp.t<481 -> 482, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
        } else {
          %1800 = affine.load %arg0[%arg3 * 8 + 7, %arg4 * 15 + 13] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<432 -> 434, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
          %1801 = affine.load %arg2[1, 0] {partition_indices = [1, 0], timing = #hlscpp.t<434 -> 436, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1802 = arith.mulf %1800, %1801 {timing = #hlscpp.t<436 -> 440, 4, 1>} : f32
          %1803 = affine.load %arg0[%arg3 * 8 + 6, %arg4 * 15 + 13] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<433 -> 435, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
          %1804 = affine.load %arg2[0, 0] {partition_indices = [0, 0], timing = #hlscpp.t<434 -> 436, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1805 = arith.mulf %1803, %1804 {timing = #hlscpp.t<436 -> 440, 4, 1>} : f32
          %1806 = arith.addf %1802, %1805 {timing = #hlscpp.t<440 -> 445, 5, 1>} : f32
          %1807 = affine.load %arg2[2, 0] {partition_indices = [2, 0], timing = #hlscpp.t<439 -> 441, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1808 = arith.mulf %1803, %1807 {timing = #hlscpp.t<441 -> 445, 4, 1>} : f32
          %1809 = arith.addf %1806, %1808 {timing = #hlscpp.t<445 -> 450, 5, 1>} : f32
          %1810 = affine.load %arg0[%arg3 * 8 + 7, %arg4 * 15 + 14] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<444 -> 446, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
          %1811 = affine.load %arg2[1, 1] {partition_indices = [1, 1], timing = #hlscpp.t<444 -> 446, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1812 = arith.mulf %1810, %1811 {timing = #hlscpp.t<446 -> 450, 4, 1>} : f32
          %1813 = arith.addf %1809, %1812 {timing = #hlscpp.t<450 -> 455, 5, 1>} : f32
          %1814 = affine.load %arg0[%arg3 * 8 + 6, %arg4 * 15 + 14] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<449 -> 451, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
          %1815 = affine.load %arg2[0, 1] {partition_indices = [0, 1], timing = #hlscpp.t<449 -> 451, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1816 = arith.mulf %1814, %1815 {timing = #hlscpp.t<451 -> 455, 4, 1>} : f32
          %1817 = arith.addf %1813, %1816 {timing = #hlscpp.t<455 -> 460, 5, 1>} : f32
          %1818 = affine.load %arg2[2, 1] {partition_indices = [2, 1], timing = #hlscpp.t<454 -> 456, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1819 = arith.mulf %1814, %1818 {timing = #hlscpp.t<456 -> 460, 4, 1>} : f32
          %1820 = arith.addf %1817, %1819 {timing = #hlscpp.t<460 -> 465, 5, 1>} : f32
          %1821 = affine.load %arg0[%arg3 * 8 + 7, %arg4 * 15 + 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<459 -> 461, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
          %1822 = affine.load %arg2[1, 2] {partition_indices = [1, 2], timing = #hlscpp.t<459 -> 461, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1823 = arith.mulf %1821, %1822 {timing = #hlscpp.t<461 -> 465, 4, 1>} : f32
          %1824 = arith.addf %1820, %1823 {timing = #hlscpp.t<465 -> 470, 5, 1>} : f32
          %1825 = affine.load %arg0[%arg3 * 8 + 6, %arg4 * 15 + 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<464 -> 466, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
          %1826 = affine.load %arg2[0, 2] {partition_indices = [0, 2], timing = #hlscpp.t<464 -> 466, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1827 = arith.mulf %1825, %1826 {timing = #hlscpp.t<466 -> 470, 4, 1>} : f32
          %1828 = arith.addf %1824, %1827 {timing = #hlscpp.t<470 -> 475, 5, 1>} : f32
          %1829 = affine.load %arg2[2, 2] {partition_indices = [2, 2], timing = #hlscpp.t<469 -> 471, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1830 = arith.mulf %1825, %1829 {timing = #hlscpp.t<471 -> 475, 4, 1>} : f32
          %1831 = arith.addf %1828, %1830 {timing = #hlscpp.t<475 -> 480, 5, 1>} : f32
          affine.store %1831, %arg1[%arg3 * 8 + 7, %arg4 * 15 + 14] {partition_indices = [7, 14], timing = #hlscpp.t<480 -> 481, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
        } {timing = #hlscpp.t<432 -> 482, 50, 0>}
      } else {
        affine.if affine_set<(d0) : (d0 * 15 - 1065 == 0)>(%arg4) {
          %1540 = affine.load %arg0[%arg3 * 8 + 7, %arg4 * 15 + 13] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<398 -> 400, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
          %1541 = affine.load %arg2[1, 0] {partition_indices = [1, 0], timing = #hlscpp.t<430 -> 432, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1542 = arith.mulf %1540, %1541 {timing = #hlscpp.t<435 -> 439, 4, 1>} : f32
          %1543 = affine.load %arg0[%arg3 * 8 + 6, %arg4 * 15 + 13] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<399 -> 401, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
          %1544 = affine.load %arg2[0, 0] {partition_indices = [0, 0], timing = #hlscpp.t<430 -> 432, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1545 = arith.mulf %1543, %1544 {timing = #hlscpp.t<435 -> 439, 4, 1>} : f32
          %1546 = arith.addf %1542, %1545 {timing = #hlscpp.t<439 -> 444, 5, 1>} : f32
          %1547 = affine.load %arg0[%arg3 * 8 + 8, %arg4 * 15 + 13] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<438 -> 440, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
          %1548 = affine.load %arg2[2, 0] {partition_indices = [2, 0], timing = #hlscpp.t<435 -> 437, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1549 = arith.mulf %1547, %1548 {timing = #hlscpp.t<440 -> 444, 4, 1>} : f32
          %1550 = arith.addf %1546, %1549 {timing = #hlscpp.t<444 -> 449, 5, 1>} : f32
          %1551 = affine.load %arg0[%arg3 * 8 + 7, %arg4 * 15 + 14] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<439 -> 441, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
          %1552 = affine.load %arg2[1, 1] {partition_indices = [1, 1], timing = #hlscpp.t<440 -> 442, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1553 = arith.mulf %1551, %1552 {timing = #hlscpp.t<445 -> 449, 4, 1>} : f32
          %1554 = arith.addf %1550, %1553 {timing = #hlscpp.t<449 -> 454, 5, 1>} : f32
          %1555 = affine.load %arg0[%arg3 * 8 + 6, %arg4 * 15 + 14] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<440 -> 442, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
          %1556 = affine.load %arg2[0, 1] {partition_indices = [0, 1], timing = #hlscpp.t<445 -> 447, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1557 = arith.mulf %1555, %1556 {timing = #hlscpp.t<450 -> 454, 4, 1>} : f32
          %1558 = arith.addf %1554, %1557 {timing = #hlscpp.t<454 -> 459, 5, 1>} : f32
          %1559 = affine.load %arg0[%arg3 * 8 + 8, %arg4 * 15 + 14] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<453 -> 455, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
          %1560 = affine.load %arg2[2, 1] {partition_indices = [2, 1], timing = #hlscpp.t<450 -> 452, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1561 = arith.mulf %1559, %1560 {timing = #hlscpp.t<455 -> 459, 4, 1>} : f32
          %1562 = arith.addf %1558, %1561 {timing = #hlscpp.t<459 -> 464, 5, 1>} : f32
          %1563 = affine.load %arg2[1, 2] {partition_indices = [1, 2], timing = #hlscpp.t<455 -> 457, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1564 = arith.mulf %1540, %1563 {timing = #hlscpp.t<460 -> 464, 4, 1>} : f32
          %1565 = arith.addf %1562, %1564 {timing = #hlscpp.t<464 -> 469, 5, 1>} : f32
          %1566 = affine.load %arg2[0, 2] {partition_indices = [0, 2], timing = #hlscpp.t<460 -> 462, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1567 = arith.mulf %1543, %1566 {timing = #hlscpp.t<465 -> 469, 4, 1>} : f32
          %1568 = arith.addf %1565, %1567 {timing = #hlscpp.t<469 -> 474, 5, 1>} : f32
          %1569 = affine.load %arg2[2, 2] {partition_indices = [2, 2], timing = #hlscpp.t<465 -> 467, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1570 = arith.mulf %1547, %1569 {timing = #hlscpp.t<470 -> 474, 4, 1>} : f32
          %1571 = arith.addf %1568, %1570 {timing = #hlscpp.t<474 -> 479, 5, 1>} : f32
          affine.store %1571, %arg1[%arg3 * 8 + 7, %arg4 * 15 + 14] {partition_indices = [7, 14], timing = #hlscpp.t<479 -> 480, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
        } else {
          %1540 = affine.load %arg0[%arg3 * 8 + 7, %arg4 * 15 + 13] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<395 -> 397, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
          %1541 = affine.load %arg2[1, 0] {partition_indices = [1, 0], timing = #hlscpp.t<429 -> 431, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1542 = arith.mulf %1540, %1541 {timing = #hlscpp.t<434 -> 438, 4, 1>} : f32
          %1543 = affine.load %arg0[%arg3 * 8 + 6, %arg4 * 15 + 13] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<396 -> 398, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
          %1544 = affine.load %arg2[0, 0] {partition_indices = [0, 0], timing = #hlscpp.t<429 -> 431, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1545 = arith.mulf %1543, %1544 {timing = #hlscpp.t<434 -> 438, 4, 1>} : f32
          %1546 = arith.addf %1542, %1545 {timing = #hlscpp.t<438 -> 443, 5, 1>} : f32
          %1547 = affine.load %arg0[%arg3 * 8 + 8, %arg4 * 15 + 13] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<397 -> 399, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
          %1548 = affine.load %arg2[2, 0] {partition_indices = [2, 0], timing = #hlscpp.t<434 -> 436, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1549 = arith.mulf %1547, %1548 {timing = #hlscpp.t<439 -> 443, 4, 1>} : f32
          %1550 = arith.addf %1546, %1549 {timing = #hlscpp.t<443 -> 448, 5, 1>} : f32
          %1551 = affine.load %arg0[%arg3 * 8 + 7, %arg4 * 15 + 14] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<436 -> 438, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
          %1552 = affine.load %arg2[1, 1] {partition_indices = [1, 1], timing = #hlscpp.t<439 -> 441, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1553 = arith.mulf %1551, %1552 {timing = #hlscpp.t<444 -> 448, 4, 1>} : f32
          %1554 = arith.addf %1550, %1553 {timing = #hlscpp.t<448 -> 453, 5, 1>} : f32
          %1555 = affine.load %arg0[%arg3 * 8 + 6, %arg4 * 15 + 14] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<437 -> 439, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
          %1556 = affine.load %arg2[0, 1] {partition_indices = [0, 1], timing = #hlscpp.t<444 -> 446, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1557 = arith.mulf %1555, %1556 {timing = #hlscpp.t<449 -> 453, 4, 1>} : f32
          %1558 = arith.addf %1554, %1557 {timing = #hlscpp.t<453 -> 458, 5, 1>} : f32
          %1559 = affine.load %arg0[%arg3 * 8 + 8, %arg4 * 15 + 14] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<452 -> 454, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
          %1560 = affine.load %arg2[2, 1] {partition_indices = [2, 1], timing = #hlscpp.t<449 -> 451, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1561 = arith.mulf %1559, %1560 {timing = #hlscpp.t<454 -> 458, 4, 1>} : f32
          %1562 = arith.addf %1558, %1561 {timing = #hlscpp.t<458 -> 463, 5, 1>} : f32
          %1563 = affine.load %arg0[%arg3 * 8 + 7, %arg4 * 15 + 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<457 -> 459, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
          %1564 = affine.load %arg2[1, 2] {partition_indices = [1, 2], timing = #hlscpp.t<454 -> 456, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1565 = arith.mulf %1563, %1564 {timing = #hlscpp.t<459 -> 463, 4, 1>} : f32
          %1566 = arith.addf %1562, %1565 {timing = #hlscpp.t<463 -> 468, 5, 1>} : f32
          %1567 = affine.load %arg0[%arg3 * 8 + 6, %arg4 * 15 + 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<462 -> 464, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
          %1568 = affine.load %arg2[0, 2] {partition_indices = [0, 2], timing = #hlscpp.t<459 -> 461, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1569 = arith.mulf %1567, %1568 {timing = #hlscpp.t<464 -> 468, 4, 1>} : f32
          %1570 = arith.addf %1566, %1569 {timing = #hlscpp.t<468 -> 473, 5, 1>} : f32
          %1571 = affine.load %arg0[%arg3 * 8 + 8, %arg4 * 15 + 15] {max_mux_size = 17 : i64, partition_indices = [-1, -1], timing = #hlscpp.t<467 -> 469, 2, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 17, d0 floordiv 10, d1 floordiv 17)>, 1>
          %1572 = affine.load %arg2[2, 2] {partition_indices = [2, 2], timing = #hlscpp.t<464 -> 466, 2, 1>} : memref<3x3xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 3, d0 floordiv 3, d1 floordiv 3)>, 1>
          %1573 = arith.mulf %1571, %1572 {timing = #hlscpp.t<469 -> 473, 4, 1>} : f32
          %1574 = arith.addf %1570, %1573 {timing = #hlscpp.t<473 -> 478, 5, 1>} : f32
          affine.store %1574, %arg1[%arg3 * 8 + 7, %arg4 * 15 + 14] {partition_indices = [7, 14], timing = #hlscpp.t<478 -> 479, 1, 1>} : memref<1920x1080xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 15, d0 floordiv 8, d1 floordiv 15)>, 1>
        } {timing = #hlscpp.t<395 -> 482, 87, 0>}
      } {timing = #hlscpp.t<395 -> 482, 87, 0>}
    } {loop_directive = #hlscpp.ld<pipeline=true, targetII=470, dataflow=false, flatten=false, parallel=true>, loop_info = #hlscpp.l<flattenTripCount=72, iterLatency=482, minII=470>, timing = #hlscpp.t<0 -> 33854, 33854, 33854>}
  } {loop_directive = #hlscpp.ld<pipeline=false, targetII=1, dataflow=false, flatten=true, parallel=true>, loop_info = #hlscpp.l<flattenTripCount=17280, iterLatency=482, minII=470>, timing = #hlscpp.t<0 -> 8121614, 8121614, 8121614>}
  return {timing = #hlscpp.t<8121614 -> 8121614, 0, 0>}
}
