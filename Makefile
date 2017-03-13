CC ?= gcc
CFLAGS_common ?= -Wall -std=gnu11 -g -DDEBUG -O0
CFLAGS_overload  = -Wall -std=c++11 -g -DDEBUG -O0
ifeq ($(strip $(PROFILE)),1)
CFLAGS_common += -Dcorrect
endif
ifeq ($(strip $(CTZ)),1)
CFLAGS_common += -DCTZ
endif
ifeq ($(strip $(MP)),1)
CFLAGS_common += -fopenmp -DMP
endif
EXEC = clz_iteration clz_binary clz_byte clz_recursive clz_harley

GIT_HOOKS := .git/hooks/pre-commit
.PHONY: all
all: $(GIT_HOOKS) $(EXEC)

$(GIT_HOOKS):
	@scripts/install-git-hooks
	@echo

SRCS_common = main.c

clz_%: %_method.o %.c
	$(CC) $(CFLAGS_common) $? -o $@

%_method.o: $(SRCS_common)
	$(CC) -c $(CFLAGS_common) $< -D$(shell echo $(subst _method.o,,$@)) -o $@

run: $(EXEC)
	taskset -c 1 ./clz_iteration 67100000 67116384
	taskset -c 1 ./clz_binary 67100000 67116384
	taskset -c 1 ./clz_byte 67100000 67116384
	taskset -c 1 ./clz_recursive 67100000 67116384
	taskset -c 1 ./clz_harley 67100000 67116384

plot: iteration.txt recursive.txt binary.txt byte.txt harley.txt
	gnuplot scripts/runtime.gp

.PHONY: clean
clean:
	$(RM) $(EXEC) *.o *.txt *.png
