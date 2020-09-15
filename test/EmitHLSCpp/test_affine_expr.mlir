// RUN: scalehls-translate -emit-hlscpp %s | FileCheck %s

#add = affine_map<(d0)[s0] -> (d0 + s0 + 11)>
#sub = affine_map<(d0)[s0] -> (d0 - s0 - 11)>
#mul = affine_map<(d0)[s0] -> (d0 * s0 * 11)>
#negmul = affine_map<(d0)[s0] -> (d0 * -s0 * -11)>
#ceildiv = affine_map<(d0)[s0] -> (d0 ceildiv s0 ceildiv 11)>
#floordiv = affine_map<(d0)[s0] -> (d0 floordiv s0 floordiv 11)>
#mod = affine_map<(d0)[s0] -> (d0 mod s0 mod 11)>

#two = affine_map<(d0)[s0] -> (d0, d0 + s0)>
#three = affine_map<(d0)[s0] -> (d0 - s0, d0, d0 + s0)>

func @test_affine_expr(%arg0: index, %arg1: index, %arg2: index) {
  // CHECK: int [[VAL_0:.*]] = (([[ARG_0:.*]] + [[ARG_1:.*]]) + 11);
  %0 = affine.apply #add (%arg0)[%arg1]

  // CHECK: int [[VAL_1:.*]] = (([[ARG_0:.*]] - [[ARG_1:.*]]) - 11);
  %1 = affine.apply #sub (%arg0)[%arg1]

  // CHECK: int [[VAL_2:.*]] = (([[ARG_0:.*]] * [[ARG_1:.*]]) * 11);
  %2 = affine.apply #mul (%arg0)[%arg1]

  // CHECK: int [[VAL_3:.*]] = (([[ARG_0:.*]] * (-[[ARG_1:.*]])) * (-11));
  %3 = affine.apply #negmul (%arg0)[%arg1]

  // CHECK: int [[VAL_4:.*]] = (([[ARG_0:.*]] + [[ARG_1:.*]] - 1) / [[ARG_1:.*]]) + 11 - 1) / 11);
  %4 = affine.apply #ceildiv (%arg0)[%arg1]

  // CHECK: int [[VAL_5:.*]] = (([[ARG_0:.*]] / [[ARG_1:.*]]) / 11);
  %5 = affine.apply #floordiv (%arg0)[%arg1]

  // CHECK: int [[VAL_6:.*]] = (([[ARG_0:.*]] % [[ARG_1:.*]]) % 11);
  %6 = affine.apply #mod (%arg0)[%arg1]

  // int [[VAL_7:.*]] = max([[ARG_0:.*]], ([[ARG_0:.*]] + [[ARG_1:.*]]));
  %7 = affine.max #two (%arg0)[%arg1]
  // CHECK: max(
  %9 = affine.min #two (%arg0)[%arg1]

  // int [[VAL_8:.*]] = max(max(([[ARG_0:.*]] - [[ARG_1:.*]]), [[ARG_0:.*]]), ([[ARG_0:.*]] + [[ARG_1:.*]]));
  %8 = affine.max #three (%arg0)[%arg1]
  // CHECK: min(min(
  %10 = affine.min #three (%arg0)[%arg1]
  return
}
