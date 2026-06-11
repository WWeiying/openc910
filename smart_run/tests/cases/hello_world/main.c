/* CoreMark matrix kernel, extracted from EEMBC CoreMark.
 * Standalone version: no external dependencies.
 */

typedef   signed short  ee_s16;
typedef unsigned short  ee_u16;
typedef   signed int    ee_s32;
typedef unsigned int    ee_u32;
typedef   signed short  MATDAT;
typedef   signed int    MATRES;

#define N 8

#define matrix_clip(x,y) ((y) ? (x) & 0x0ff : (x) & 0x0ffff)
#define matrix_big(x)    (0xf000 | (x))
#define bit_extract(x,from,to) (((x)>>(from)) & (~(0xffffffff << (to))))

static MATDAT A[N*N];
static MATDAT B[N*N];
static MATRES C[N*N];

/* ---- CRC helper ---- */
static ee_u16 crc16(ee_s16 newval, ee_u16 crc) {
    ee_u16 i;
    ee_u16 v = (ee_u16)newval;
    for (i = 0; i < 8; i++, v >>= 1)
        if ((v ^ crc) & 1) crc = (crc >> 1) ^ 0xA001;
        else               crc >>= 1;
    return crc;
}

/* ---- matrix ops ---- */
static ee_s16 matrix_sum(ee_u32 n, MATRES *c, MATDAT clipval) {
    MATRES tmp = 0, prev = 0, cur;
    ee_s16 ret = 0;
    ee_u32 i, j;
    for (i = 0; i < n; i++)
        for (j = 0; j < n; j++) {
            cur = c[i*n+j];
            tmp += cur;
            if (tmp > clipval) { ret += 10; tmp = 0; }
            else ret += (cur > prev) ? 1 : 0;
            prev = cur;
        }
    return ret;
}

static void matrix_add_const(ee_u32 n, MATDAT *a, MATDAT val) {
    ee_u32 i, j;
    for (i = 0; i < n; i++)
        for (j = 0; j < n; j++)
            a[i*n+j] += val;
}

static void matrix_mul_const(ee_u32 n, MATRES *c, MATDAT *a, MATDAT val) {
    ee_u32 i, j;
    for (i = 0; i < n; i++)
        for (j = 0; j < n; j++)
            c[i*n+j] = (MATRES)a[i*n+j] * (MATRES)val;
}

static void matrix_mul_vect(ee_u32 n, MATRES *c, MATDAT *a, MATDAT *b) {
    ee_u32 i, j;
    for (i = 0; i < n; i++) {
        c[i] = 0;
        for (j = 0; j < n; j++)
            c[i] += (MATRES)a[i*n+j] * (MATRES)b[j];
    }
}

static void matrix_mul_matrix(ee_u32 n, MATRES *c, MATDAT *a, MATDAT *b) {
    ee_u32 i, j, k;
    for (i = 0; i < n; i++)
        for (j = 0; j < n; j++) {
            c[i*n+j] = 0;
            for (k = 0; k < n; k++)
                c[i*n+j] += (MATRES)a[i*n+k] * (MATRES)b[k*n+j];
        }
}

static void matrix_mul_matrix_bitextract(ee_u32 n, MATRES *c, MATDAT *a, MATDAT *b) {
    ee_u32 i, j, k;
    for (i = 0; i < n; i++)
        for (j = 0; j < n; j++) {
            c[i*n+j] = 0;
            for (k = 0; k < n; k++) {
                MATRES tmp = (MATRES)a[i*n+k] * (MATRES)b[k*n+j];
                c[i*n+j] += bit_extract(tmp,2,4) * bit_extract(tmp,5,7);
            }
        }
}

/* init matrices with runtime-derived values (seed not compile-time const) */
static void init_matrices(ee_s32 seed) {
    ee_u32 i, j, order = 1;
    MATDAT val;
    if (seed == 0) seed = 1;
    for (i = 0; i < N; i++)
        for (j = 0; j < N; j++) {
            seed  = (order * seed) % 65536;
            val   = (MATDAT)matrix_clip(seed + order, 0);
            B[i*N+j] = val;
            val   = (MATDAT)matrix_clip(val + order, 1);
            A[i*N+j] = val;
            order++;
        }
}

/* one benchmark iteration (mirrors coremark matrix_test) */
static ee_s16 matrix_test(MATDAT val) {
    ee_u16 crc = 0;
    MATDAT clipval = (MATDAT)matrix_big(val);

    matrix_add_const(N, A, val);
    matrix_mul_const(N, C, A, val);
    crc = crc16(matrix_sum(N, C, clipval), crc);
    matrix_mul_vect(N, C, A, B);
    crc = crc16(matrix_sum(N, C, clipval), crc);
    matrix_mul_matrix(N, C, A, B);
    crc = crc16(matrix_sum(N, C, clipval), crc);
    matrix_mul_matrix_bitextract(N, C, A, B);
    crc = crc16(matrix_sum(N, C, clipval), crc);
    matrix_add_const(N, A, -val);
    return (ee_s16)crc;
}

int main(void) {
    int i;
    volatile ee_s16 result = 0;

    init_matrices(0x3415);

    asm volatile (
        ".global perf_monitor_start\n\t"
        "perf_monitor_start:"
    );

    for (i = 0; i < 1; i++)
        result = matrix_test((MATDAT)(i + 1));

    asm volatile (
        ".global perf_monitor_end\n\t"
        "perf_monitor_end:"
    );

    (void)result;
    return 0;
}
