#define BATCH_SIZE 1024
#define BUF_SIZE 256
#define DIM 200

#define FLT_MAX 3.40282347e+38

#define NPOINTS (819200/2)
#define NFEATURES 34
#define NCLUSTERS 5
#define TILE_SIZE 4096


#define NUM_FEATURE 2
#define NUM_PT_IN_SEARCHSPACE 1024*1024
#define NUM_PT_IN_BUFFER 512
#define NUM_TILES NUM_PT_IN_SEARCHSPACE / NUM_PT_IN_BUFFER
#define UNROLL_FACTOR 2

// void compute(int num, int k, float* coord, float* weight, float* target, float* cost, int * assign, 
// 		int* center_table, char* switch_membership, float* cost_of_opening_x, float* work_mem, float* x_cost){

// void compute(int num, int k, float coord[BUF_SIZE * DIM], float weight[BUF_SIZE], float target[DIM], float cost[BUF_SIZE], int assign[BUF_SIZE], 
// 		float center_table[BATCH_SIZE], float switch_membership[BATCH_SIZE], float cost_of_opening_x[1], float work_mem[BATCH_SIZE], float x_cost[BUF_SIZE]){			

void compute(float local_inputQuery[NUM_FEATURE], float local_searchSpace[NUM_PT_IN_BUFFER*NUM_FEATURE], float local_distance[NUM_PT_IN_BUFFER])
{
    float sum;
	float feature_delta;
	COMPUTE_TILE: for (int i = 0; i < NUM_PT_IN_BUFFER; ++i) {
        sum = 0.0;
		for (int j = 0; j < NUM_FEATURE; ++j){
			feature_delta = local_searchSpace[i+j] - local_inputQuery[j];
			sum += feature_delta*feature_delta;
		}
        local_distance[i] = sum;
	}	
}