#ifdef __linux__ 
#include "server.h"

int create_and_bind(char* host, char* port) {
  struct addrinfo hints;
  struct addrinfo *info, *rp;
  int ret, fd;

  memset(&hints, 0, sizeof(struct addrinfo));
  hints.ai_family = AF_UNSPEC;
  hints.ai_socktype = SOCK_STREAM;
  hints.ai_flags = AI_PASSIVE;

  ret = getaddrinfo(host, port, &hints, &info);
  if (ret != 0) {
    fprintf(stderr, "getaddrinfo: %s\n", gai_strerror(ret));
    return -1;
  }

  for (rp = info; rp != NULL; rp = rp->ai_next) {
    fd = socket(rp->ai_family, rp->ai_socktype, rp->ai_protocol);
    if (fd == -1) {
      continue;
    }

    ret = bind(fd, rp->ai_addr, rp->ai_addrlen);
    if (ret == 0) {
      break;
    }
    close(fd);
  }

  if (rp == NULL) {
    perror("bind");
    return -1;
  }

  freeaddrinfo(info);
  return fd;
}

int set_non_block(int fd) {
  int flags, ret;

  flags = fcntl(fd, F_GETFL, 0);
  if (flags == -1) {
    perror("fcntl");
    return -1;
  }

  flags |= O_NONBLOCK;
  ret = fcntl(fd, F_SETFL, flags);
  if (ret == -1) {
    perror("fcntl");
    return -1;
  }

  return 0;
}
#else
#endif