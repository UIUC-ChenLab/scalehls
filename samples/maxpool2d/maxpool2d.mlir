#map0 = affine_map<()[s0, s1, s2, s3] -> (s0, s1, s2, s3)>
#map1 = affine_map<()[s0] -> (0, s0 * 2)>
#map2 = affine_map<() -> (0)>
#map3 = affine_map<(d0) -> (227, d0 * -2 + 227, d0 * 2 + 2, 2)>
#map4 = affine_map<() -> (113)>
#map5 = affine_map<() -> (3)>
#map6 = affine_map<() -> (1)>


module {
  func @main_graph(%arg0: memref<1x3x227x227xf32>) -> memref<1x3x113x113xf32> {
    %cst = constant 0.000000e+00 : f32
    %1 = alloc() : memref<1x3x113x113xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 3 {
        affine.for %arg3 = 0 to 113 {
          affine.for %arg4 = 0 to 113 {
            affine.store %cst, %1[symbol(%arg1), symbol(%arg2), symbol(%arg3), symbol(%arg4)] : memref<1x3x113x113xf32>
            %2 = affine.max #map1()[%arg3]
            %3 = affine.max #map1()[%arg4]
            affine.for %arg5 = 0 to min #map3(%arg3) {
              affine.for %arg6 = 0 to min #map3(%arg4) {
                %4 = addi %arg5, %2 : index
                %5 = addi %arg6, %3 : index
                %6 = load %arg0[%arg1, %arg2, %4, %5] : memref<1x3x227x227xf32>
                %7 = affine.load %1[symbol(%arg1), symbol(%arg2), symbol(%arg3), symbol(%arg4)] : memref<1x3x113x113xf32>
                %8 = cmpf "ogt", %7, %6 : f32
                %9 = select %8, %7, %6 : f32
                affine.store %9, %1[symbol(%arg1), symbol(%arg2), symbol(%arg3), symbol(%arg4)] : memref<1x3x113x113xf32>
              }
            }
          }
        }
      }
    }
    return %1 : memref<1x3x113x113xf32>
  }
}