
#ifdef __linux__ 
#include <errno.h>
#include <fcntl.h>
#include <netdb.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/epoll.h>
#include <unistd.h>

// used to listen to socket
int create_and_bind(char* host, char* port);
// sets a give file descriptor to non blocking state
int set_non_block(int fd);
#else

#endif
