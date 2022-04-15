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

void compute_conv(float input[1920][1080], float output[1920][1080], float kernel[3][3]) {
    Loop0: for (int idx_row = 0; idx_row < 1920; idx_row += 1) {
        Loop1: for (int idx_col = 0; idx_col < 1080; idx_col += 1) {
            if (idx_row == 0) {
                if (idx_col == 0) {
                    output[idx_row][idx_col] = ((((((((input[idx_row][idx_col - 1] * kernel[1][0]) + (input[idx_row + 1][idx_col - 1] * kernel[0][0])) + (input[idx_row + 1][idx_col - 1] * kernel[2][0])) + (input[idx_row][idx_col] * kernel[1][1])) + (input[idx_row + 1][idx_col] * kernel[0][1])) + (input[idx_row + 1][idx_col] * kernel[2][1])) + (input[idx_row][idx_col - 1] * kernel[1][2])) + (input[idx_row + 1][idx_col - 1] * kernel[0][2])) + (input[idx_row + 1][idx_col - 1] * kernel[2][2]);
                } else {
                    if (idx_col == (N - 1)) {
                        output[idx_row][idx_col] = ((((((((input[idx_row][idx_col + 1] * kernel[1][0]) + (input[idx_row + 1][idx_col + 1] * kernel[0][0])) + (input[idx_row + 1][idx_col + 1] * kernel[2][0])) + (input[idx_row][idx_col] * kernel[1][1])) + (input[idx_row + 1][idx_col] * kernel[0][1])) + (input[idx_row + 1][idx_col] * kernel[2][1])) + (input[idx_row][idx_col + 1] * kernel[1][2])) + (input[idx_row + 1][idx_col + 1] * kernel[0][2])) + (input[idx_row + 1][idx_col + 1] * kernel[2][2]);
                    } else {
                        output[idx_row][idx_col] = ((((((((input[idx_row][idx_col - 1] * kernel[1][0]) + (input[idx_row + 1][idx_col - 1] * kernel[0][0])) + (input[idx_row + 1][idx_col - 1] * kernel[2][0])) + (input[idx_row][idx_col] * kernel[1][1])) + (input[idx_row + 1][idx_col] * kernel[0][1])) + (input[idx_row + 1][idx_col] * kernel[2][1])) + (input[idx_row][idx_col + 1] * kernel[1][2])) + (input[idx_row + 1][idx_col + 1] * kernel[0][2])) + (input[idx_row + 1][idx_col + 1] * kernel[2][2]);
                    }
                }

            } else {
                if (idx_row == (M - 1)) {
                    if (idx_col == 0) {
                        output[idx_row][idx_col] = ((((((((input[idx_row][idx_col + 1] * kernel[1][0]) + (input[idx_row - 1][idx_col + 1] * kernel[0][0])) + (input[idx_row - 1][idx_col + 1] * kernel[2][0])) + (input[idx_row][idx_col] * kernel[1][1])) + (input[idx_row - 1][idx_col] * kernel[0][1])) + (input[idx_row - 1][idx_col] * kernel[2][1])) + (input[idx_row][idx_col + 1] * kernel[1][2])) + (input[idx_row - 1][idx_col + 1] * kernel[0][2])) + (input[idx_row - 1][idx_col + 1] * kernel[2][2]);
                    } else {
                        if (idx_col == (N - 1)) {
                            output[idx_row][idx_col] = ((((((((input[idx_row][idx_col - 1] * kernel[1][0]) + (input[idx_row - 1][idx_col - 1] * kernel[0][0])) + (input[idx_row - 1][idx_col - 1] * kernel[2][0])) + (input[idx_row][idx_col] * kernel[1][1])) + (input[idx_row - 1][idx_col] * kernel[0][1])) + (input[idx_row - 1][idx_col] * kernel[2][1])) + (input[idx_row][idx_col - 1] * kernel[1][2])) + (input[idx_row - 1][idx_col - 1] * kernel[0][2])) + (input[idx_row - 1][idx_col - 1] * kernel[2][2]);
                        } else {
                            output[idx_row][idx_col] = ((((((((input[idx_row][idx_col - 1] * kernel[1][0]) + (input[idx_row - 1][idx_col - 1] * kernel[0][0])) + (input[idx_row - 1][idx_col - 1] * kernel[2][0])) + (input[idx_row][idx_col] * kernel[1][1])) + (input[idx_row - 1][idx_col] * kernel[0][1])) + (input[idx_row - 1][idx_col] * kernel[2][1])) + (input[idx_row][idx_col + 1] * kernel[1][2])) + (input[idx_row - 1][idx_col + 1] * kernel[0][2])) + (input[idx_row - 1][idx_col + 1] * kernel[2][2]);
                        }
                    }

                } else {
                    if (idx_col == 0) {
                        output[idx_row][idx_col] = ((((((((input[idx_row][idx_col + 1] * kernel[1][0]) + (input[idx_row - 1][idx_col + 1] * kernel[0][0])) + (input[idx_row + 1][idx_col + 1] * kernel[2][0])) + (input[idx_row][idx_col] * kernel[1][1])) + (input[idx_row - 1][idx_col] * kernel[0][1])) + (input[idx_row + 1][idx_col] * kernel[2][1])) + (input[idx_row][idx_col + 1] * kernel[1][2])) + (input[idx_row - 1][idx_col + 1] * kernel[0][2])) + (input[idx_row + 1][idx_col + 1] * kernel[2][2]);
                    } else {
                        if (idx_col == (N - 1)) {
                            output[idx_row][idx_col] = ((((((((input[idx_row][idx_col - 1] * kernel[1][0]) + (input[idx_row - 1][idx_col - 1] * kernel[0][0])) + (input[idx_row + 1][idx_col - 1] * kernel[2][0])) + (input[idx_row][idx_col] * kernel[1][1])) + (input[idx_row - 1][idx_col] * kernel[0][1])) + (input[idx_row + 1][idx_col] * kernel[2][1])) + (input[idx_row][idx_col - 1] * kernel[1][2])) + (input[idx_row - 1][idx_col - 1] * kernel[0][2])) + (input[idx_row + 1][idx_col - 1] * kernel[2][2]);
                        } else {
                            output[idx_row][idx_col] = ((((((((input[idx_row][idx_col - 1] * kernel[1][0]) + (input[idx_row - 1][idx_col - 1] * kernel[0][0])) + (input[idx_row + 1][idx_col - 1] * kernel[2][0])) + (input[idx_row][idx_col] * kernel[1][1])) + (input[idx_row - 1][idx_col] * kernel[0][1])) + (input[idx_row + 1][idx_col] * kernel[2][1])) + (input[idx_row][idx_col + 1] * kernel[1][2])) + (input[idx_row - 1][idx_col + 1] * kernel[0][2])) + (input[idx_row + 1][idx_col + 1] * kernel[2][2]);
                        }
                    }
                }
            }
        }
    }
}






