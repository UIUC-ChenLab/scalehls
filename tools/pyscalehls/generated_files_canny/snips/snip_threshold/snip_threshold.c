# include <math.h>

# define M 1920
# define N 1080
# define PI 3.141592653589793

# define HIGH_THRESHOLD 0.15
# define LOW_THRESHOLD 0.05
# define WEAK_PIXEL 75
# define STRONG_PIXEL 255
# define WEAK_PIXEL_CAST_TO_INTEGER 75
# define STRONG_PIXEL_CAST_TO_INTEGER 255





void threshold(float image[1920][1080], float res[1920][1080]) {
    int max = 0;
    Loop10: for (int idx_row = 0; idx_row < 1920; idx_row += 1) {
        Loop11: for (int idx_col = 0; idx_col < 1080; idx_col += 1) {
            if (max < image[idx_row][idx_col]) {
                max = image[idx_row][idx_col];
            }
        }
    }

    float highThreshold = max * HIGH_THRESHOLD;
    float lowThreshold = highThreshold * LOW_THRESHOLD;
    Loop12: for (int idx_row = 0; idx_row < 1920; idx_row += 1) {
        Loop13: for (int idx_col = 0; idx_col < 1080; idx_col += 1) {
            if (image[idx_row][idx_col] >= highThreshold) {
                res[idx_row][idx_col] = STRONG_PIXEL_CAST_TO_INTEGER;
            } else {
                if (image[idx_row][idx_col] < lowThreshold) {
                    res[idx_row][idx_col] = WEAK_PIXEL_CAST_TO_INTEGER;
                } else {
                    res[idx_row][idx_col] = 0;
                }
            }
        }
    }
}


