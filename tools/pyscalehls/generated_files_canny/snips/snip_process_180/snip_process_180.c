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



void process_180(float A[1920][1080]) {
    Loop6: for (int i = 0; i < 1920; i += 1) {
        Loop7: for (int j = 0; j < 1080; j += 1) {
            float temp = A[i][j];
            if (temp < 0) {
                A[i][j] += 180;
            }
        }
    }
}




