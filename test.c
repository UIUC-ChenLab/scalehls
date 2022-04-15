# define HIGH_THRESHOLD 0.15
# define LOW_THRESHOLD 0.05
# define WEAK_PIXEL 75
# define STRONG_PIXEL 255
# define WEAK_PIXEL_CAST_TO_INTEGER 75
# define STRONG_PIXEL_CAST_TO_INTEGER 255

void sobel_kernel_3_by_3(float image_smoothed[1920][1080], float output[1920][1080], float temp[1920][1080], float Kx[3][3], float Ky[3][3]) {

    float max = (float)0.0;
    for (int idx_row = 0; idx_row < 1920; idx_row += 1) {
        for (int idx_col = 0; idx_col < 1080; idx_col += 1) {
            float theta = 2.1;
            output[idx_row][idx_col] = (float)(output[idx_row][idx_col] * output[idx_row][idx_col]) + (temp[idx_row][idx_col] * temp[idx_row][idx_col]);
            temp[idx_row][idx_col] = theta;
            if (max < output[idx_row][idx_col]) {
                max = output[idx_row][idx_col];
            }
        }
    }

    for (int idx_row = 0; idx_row < 1920; idx_row += 1) {
        for (int idx_col = 0; idx_col < 1080; idx_col += 1) {
            output[idx_row][idx_col] = (output[idx_row][idx_col] / max) * (float)255.0;
        }
    }
}