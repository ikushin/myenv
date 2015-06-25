//! make -k && make run

#include <cutter.h>

extern int c_check (char * , char );


void test_c_check (void)
{
        cut_assert_equal_int( EXIT_FAILURE, c_check("aa@\"a", '"') );
        cut_assert_equal_int( EXIT_SUCCESS, c_check("aa@a", '"') );
}
