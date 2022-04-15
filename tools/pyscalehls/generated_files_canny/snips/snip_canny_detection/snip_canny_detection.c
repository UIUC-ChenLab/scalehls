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







void canny_detection(float image[1920][1080], float image_smoothed[1920][1080], float gauss_kernel[3][3], float output[1920][1080], float tmp[1920][1080], float result[1920][1080], float Kx[3][3], float Ky[3][3], float output_nm[1920][1080]) {

    compute_conv(image, output, gauss_kernel);
    sobel_kernel_3_by_3(image_smoothed, output, tmp, Kx, Ky);
    
    Loop16: for (int i_chaining_0 = 0; i_chaining_0 < 1920; i_chaining_0 += 1) {
        Loop17: for (int i_chaining_1 = 0; i_chaining_1 < 1080; i_chaining_1 += 1) {
            tmp[i_chaining_0][i_chaining_1] = (tmp[i_chaining_0][i_chaining_1] * 180.0) / 3.141592653589793;
        }
    }

    process_180(tmp);
    non_max_suppression(output, tmp, output_nm);
    threshold(output_nm, result);
    hysteresis(result);
}
