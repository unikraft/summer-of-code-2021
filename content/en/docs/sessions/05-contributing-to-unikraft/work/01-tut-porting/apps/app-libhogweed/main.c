#include <stdio.h>

/* Import user configuration: */
#include <uk/config.h>


int main()
{
	int verbose = 1;
	run_all_libhogweed_tests(verbose);
}
