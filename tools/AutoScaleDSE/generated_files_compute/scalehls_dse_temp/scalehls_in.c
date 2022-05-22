#define BUF_SIZE 256
#define DIM 200

void compute(int num, int k, float* coord, float* weight, float* target, float* cost, int * assign, 
		int* center_table, char* switch_membership, float* cost_of_opening_x, float* work_mem, float* x_cost){
	//#pragma HLS INLINE off
	// pre:for(int i = 0; i < BUF_SIZE; i++){
	// 	float sum = 0;
	// 	for(int j = 0; j < DIM; j++){
	// 		float a = coord[i * DIM + j] - target[j];
	// 		sum += a * a;
	// 	}
	// 	x_cost[i] = sum * weight[i];
	// }

	after:for(int i = 0; i < BUF_SIZE; i++){
		float current_cost = x_cost[i] - cost[i];
		int local_center_index = center_table[assign[i]];

		if(current_cost < 0){
			switch_membership[k + i] = 1; 
			cost_of_opening_x[0] += current_cost;
		} else{
			work_mem[local_center_index] -= current_cost;
		}
	}
}