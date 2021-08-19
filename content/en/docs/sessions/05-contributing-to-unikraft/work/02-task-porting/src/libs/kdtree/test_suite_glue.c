#include <stdio.h>

#include <uk/config.h>
#include <test_suite_glue.h>

int libkdtree_test_main() {

    int argc = 1;
    char **argv = NULL;
    
    int testCounter = 0;
    int errorCounter = 0;
    int rc;

#if CONFIG_ALL_TEST_CASES || CONFIG_TEST1
    testCounter++;
    printf("Running test 1 ....................\n");
    rc = test1_main(argc, argv);
    if(rc == 0)
        printf("PASS\n");
    else {
        printf("FAIL\n");
        errorCounter++;
    }
#endif

#if CONFIG_ALL_TEST_CASES || CONFIG_TEST2
    testCounter++;
    printf("Running test 2 ....................\n");
    rc = test2_main(argc, argv);
    if(rc == 0)
        printf("PASS\n");
    else {
        printf("FAIL\n");
        errorCounter++;
    }
#endif

    printf ("Total tests : %d\n", testCounter);
    printf ("Total errors: %d\n", errorCounter);

return errorCounter;
}
