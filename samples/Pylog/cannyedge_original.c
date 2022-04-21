# include <math.h>

int M = 1920;
int N = 1080;
float PI = 3.141592653589793;

float HIGH_THRESHOLD = 0.15;
float LOW_THRESHOLD = 0.05;
int WEAK_PIXEL = 75;
int STRONG_PIXEL = 255;
int WEAK_PIXEL_CAST_TO_INTEGER = 75;
int STRONG_PIXEL_CAST_TO_INTEGER = 255;

void compute_conv(float input[1920][1080], float output[1920][1080], float kernel[3][3]) {
    for (int idx_row = 0; idx_row < 1920; idx_row += 1) {
        for (int idx_col = 0; idx_col < 1080; idx_col += 1) {
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

void sobel_kernel_3_by_3(float image_smoothed[1920][1080], float output[1920][1080], float temp[1920][1080], float Kx[3][3], float Ky[3][3]) {
    compute_conv(image_smoothed, output, Kx);
    compute_conv(image_smoothed, temp, Ky);
    float max = 0.0;
    for (int idx_row = 0; idx_row < 1920; idx_row += 1) {
        for (int idx_col = 0; idx_col < 1080; idx_col += 1) {
            float theta = (2 * temp[idx_row][idx_col]) / (pow((pow(output[idx_row][idx_col], 2) + pow(temp[idx_row][idx_col], 2)), 0.5) + output[idx_row][idx_col]);
            output[idx_row][idx_col] = (output[idx_row][idx_col] * output[idx_row][idx_col]) + (temp[idx_row][idx_col] * temp[idx_row][idx_col]);
            temp[idx_row][idx_col] = theta;
            if (max < output[idx_row][idx_col]) {
                max = output[idx_row][idx_col];
            }
        }
    }

    for (int idx_row = 0; idx_row < 1920; idx_row += 1) {
        for (int idx_col = 0; idx_col < 1080; idx_col += 1) {
            output[idx_row][idx_col] = (output[idx_row][idx_col] / max) * 255.0;
        }
    }
}

void process_180(float A[1920][1080]) {
    for (int i = 0; i < 1920; i += 1) {
        for (int j = 0; j < 1080; j += 1) {
            float temp = A[i][j];
            if (temp < 0) {
                A[i][j] += 180;
            }
        }
    }
}

void non_max_suppression(float img[1920][1080], float angle[1920][1080], float Z[1920][1080]) {
    for (int i = 1; i < (1920 - 2); i += 1) {
        for (int j = 1; j < (1080 - 2); j += 1) {
            int q = 255;
            int r = 255;
            float temp = angle[i][j];
            float temp2 = img[i][j];
            if (((0 <= temp) < 22.5) || ((157.5 <= temp) <= 180)) {
                q = img[i][j + 1];
                r = img[i][j - 1];
            } else {
                if ((22.5 <= temp) < 67.5) {
                    q = img[i + 1][j - 1];
                    r = img[i - 1][j + 1];
                } else {
                    if ((67.5 <= temp) < 112.5) {
                        q = img[i + 1][j];
                        r = img[i - 1][j];
                    } else {
                        if ((112.5 <= temp) < 157.5) {
                            q = img[i - 1][j - 1];
                            r = img[i + 1][j + 1];
                        }
                    }
                }
            }

            if ((temp2 >= q) && (temp2 >= r)) {
                Z[i][j] = temp2;
            } else {
                Z[i][j] = 0;
            }
        }
    }
}

void threshold(float image[1920][1080], float res[1920][1080]) {
    int max = 0;
    for (int idx_row = 0; idx_row < 1920; idx_row += 1) {
        for (int idx_col = 0; idx_col < 1080; idx_col += 1) {
            if (max < image[idx_row][idx_col]) {
                max = image[idx_row][idx_col];
            }
        }
    }

    float highThreshold = max * HIGH_THRESHOLD;
    float lowThreshold = highThreshold * LOW_THRESHOLD;
    for (int idx_row = 0; idx_row < 1920; idx_row += 1) {
        for (int idx_col = 0; idx_col < 1080; idx_col += 1) {
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

void hysteresis(float img[1920][1080]) {
    int weak = 10;
    int strong = 70;
    for (int i = 1; i < (1920 - 2); i += 1) {
        for (int j = 1; j < (1080 - 2); j += 1) {
            if (img[i][j] == weak) {
                if ((((((((img[i + 1][j - 1] == strong) || (img[i + 1][j] == strong)) || (img[i + 1][j + 1] == strong)) || (img[i][j - 1] == strong)) || (img[i][j + 1] == strong)) || (img[i - 1][j - 1] == strong)) || (img[i - 1][j] == strong)) || (img[i - 1][j + 1] == strong)) {
                    img[i][j] = strong;
                } else {
                    img[i][j] = 0;
                }
            }
        }
    }
}

void canny_detection(float image[1920][1080], float image_smoothed[1920][1080], float gauss_kernel[3][3], float output[1920][1080], float tmp[1920][1080], float result[1920][1080], float Kx[3][3], float Ky[3][3], float output_nm[1920][1080]) {

    float HIGH_THRESHOLD = 0.15;
    float LOW_THRESHOLD = 0.05;
    int WEAK_PIXEL = 75;
    int STRONG_PIXEL = 255;
    int WEAK_PIXEL_CAST_TO_INTEGER = 75;
    int STRONG_PIXEL_CAST_TO_INTEGER = 255;
    compute_conv(image, output, gauss_kernel);
    sobel_kernel_3_by_3(image_smoothed, output, tmp, Kx, Ky);
    for (int i_chaining_0 = 0; i_chaining_0 < 1920; i_chaining_0 += 1) {
        for (int i_chaining_1 = 0; i_chaining_1 < 1080; i_chaining_1 += 1) {
            tmp[i_chaining_0][i_chaining_1] = (tmp[i_chaining_0][i_chaining_1] * 180.0) / 3.141592653589793;
        }
    }

    process_180(tmp);
    non_max_suppression(output, tmp, output_nm);
    threshold(output_nm, result);
    hysteresis(result);
}
