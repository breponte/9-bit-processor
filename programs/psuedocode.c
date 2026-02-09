#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

/**
 * difficult to expand because hardware has a carry bit
 * hardware add will store overflow for next addition operation, therefore:
 *  1. flip LSB
 *  2. add 1 to LSB
 *  3. flip MSB
 *  4. add 0 to LSB, adding the overflow if there was one
 * 
 * requires 0 extra registers, ***done in place***
 */
#define NEGATE_8(val)   ((val ^ 0b11111111) + 1) 
#define NEGATE_16(val)  ((val ^ 0b1111111111111111) + 1) 

/**
 * C pseudocode for arithmetic distance of test cases
 * @param data (uint8_t *) pointer to loaded test data array
 * @param result (uint8_t *) pointer to result array to store min/max distances
 * @returns 0 on success, 1 on fail
 */
int arithmeticDistance(uint8_t * data, uint8_t * result) {
    // DEBUGGING, will not be included in assembly
    int iMax; int jMax; int iMin; int jMin;

    // Iterate over data, unique pairs                      // load from dat_mem
    for (int i = 0; i < 64; i+=2) {                         // +0 registers
        for (int j = i+2; j < 64; j+=2) {                   // +0 registers                             
            // dist bytes
            uint8_t distMSB = data[i];                      // 1 total registers
            uint8_t distLSB = data[i+1];                    // 2 total registers

            // jVal bytes
            uint8_t jValMSB = data[j];                      // 3 total registers
            uint8_t jValLSB = data[j+1];                    // 4 total registers
            
            // load values
            uint16_t dist = distMSB << 8 | distLSB;
            uint16_t jVal = jValMSB << 8 | jValLSB;       

            // Case 1: Two Positives or Two Negatives (i.e. Signs Match)
            if (((distMSB ^ jValMSB) & 0b10000000) == 0b00000000) {
                // negate smaller positive
                if (distMSB < jValMSB) {
                    dist = NEGATE_16(dist);                 // +0 registers
                } else if ((distMSB ^ jValMSB) == 0b00000000) {
                    if (distLSB < jValLSB) {
                        dist = NEGATE_16(dist);             // +0 registers
                    } else {
                        jVal = NEGATE_16(jVal);             // +0 registers
                    }
                } else {
                    jVal = NEGATE_16(jVal);                 // +0 registers
                }
            }
            // Case 3: Positive and Negative
            else {
                // negate negative
                if ((distMSB & 0b10000000) != 0b10000000) {
                    jVal = NEGATE_16(jVal);                 // +0 registers
                } else {
                    dist = NEGATE_16(dist);                 // +0 registers
                }
            }

            // and Add
            // addition of LSB, then addition of MSB which uses LSB's carry bit
            dist += jVal;                                   // +0 registers

            distMSB = dist >> 8;
            distLSB = dist & 0b0000000011111111;

            // at this point, jVal is no longer needed
            // jVal is obsolete                             // 2 total registers

            // new min, new max respectively
            // loaded from dat_mem into jVal's obsolete registers
            uint8_t minMSB = result[0];                     // 3 total registers
            uint8_t minLSB = result[1];                     // 4 total registers
            if (distMSB < minMSB ||
                (distMSB == minMSB && distLSB < minLSB)) {

                // store results
                result[0] = dist >> 8;
                result[1] = dist & 0b0000000011111111;

                // DEBUGGING check indices
                iMin = i;
                jMin = j;
            }

            // at this point, minMSB/LSB is no longer needed
            // minMSB/LSB is obsolete                       // 2 total registers

            // loaded from dat_mem into minMSB/LSB's obsolete registers
            uint8_t maxMSB = result[2];                     // 3 total registers
            uint8_t maxLSB = result[3];                     // 4 total registers
            if (distMSB > maxMSB ||
                (distMSB == maxMSB && distLSB > maxLSB)) {
                // store results
                result[2] = dist >> 8;
                result[3] = dist & 0b0000000011111111;

                // DEBUGGING check indices
                iMax = i;
                jMax = j;
            }
        }
    }

    // DEBUGGING check results
    printf("Min pair = %d, %d \t Max pair = %d, %d\n",
        jMin/2, iMin/2, jMax/2, iMax/2);
    
    return 0;
}

/**
 * Read test data from file and store in given data array
 * @param testNum (int) test file number to read from
 * @param data (uint_t *) pointer to data array
 * @returns (int) 0 on success, 1 on fail
 */
int readTestData(int testNum, uint8_t * data) {
    char testPath[] = "tests/test_.txt";
    if (testNum < 0 || testNum > 9) return -1;
    testPath[10] = '0' + testNum;

    FILE * fptr;
    fptr = fopen(testPath, "r");

    char buffer[10];
    int i = 0;
    while (fgets(buffer, 10, fptr)) {
        uint8_t byte = 0;
        for (int j = 0; j < 8; j++) {
            byte = byte << 1;
            if (buffer[j] == '1') {
                byte += 1;
            }
        }
        data[i] = byte;
        i++;
    }

    fclose(fptr);
    return 0;
}

int main() {
    // result[0:2] = min, result[2:4] = max
    uint8_t result[] = {255, 255, 0, 0};
    
    uint8_t data[64];
    for (int i = 0; i < 10; i++) {
        if (readTestData(i, data) == -1) return 1;
        arithmeticDistance(data, result);
        // reset distances
        result[0] = 255;
        result[1] = 255;
        result[2] = 0;
        result[3] = 0;
    }

    return 0;
}

/**
 * NOTES:
 * - SV arithmetic is unsigned
 * - SV overflow wraps around, not truncated
 * - C overflow wraps around, not truncated; SAME AS SV
 */

/** 
 * overflow wraps around
 * uint8_t overflow =  0b11111111;
 * overflow++;
 * printf("%u\n", overflow);
 */

// Verify data
// for (int i = 0; i < 64; i++) printf("%hhu\n", data[i]);

// Check results
// for (int i = 0; i < 4; i+=2) {
//     unsigned int dist = result[i] << 8 | result[i+1];
//     printf("%u\n", dist);
// }