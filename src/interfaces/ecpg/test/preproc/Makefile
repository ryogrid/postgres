subdir = src/interfaces/ecpg/test/preproc
top_builddir = ../../../../..
include $(top_builddir)/src/Makefile.global
include $(top_srcdir)/$(subdir)/../Makefile.regress


TESTS = array_of_struct array_of_struct.c \
	autoprep autoprep.c \
	comment comment.c \
	cursor cursor.c \
	define define.c \
	init init.c \
	strings strings.c \
	outofscope outofscope.c \
	type type.c \
	variable variable.c \
	whenever whenever.c \
	whenever_do_continue whenever_do_continue.c \
	pointer_to_struct pointer_to_struct.c

all: $(TESTS) cmd_out cmd_out_informix

array_of_struct.c: array_of_struct.pgc $(ECPG_TEST_DEPENDENCIES)
	$(ECPG) -c -o $@ $<

pointer_to_struct.c: pointer_to_struct.pgc $(ECPG_TEST_DEPENDENCIES)
	$(ECPG) -c -o $@ $<

autoprep.c: autoprep.pgc $(ECPG_TEST_DEPENDENCIES)
	$(ECPG) -r prepare -o $@ $<

strings.c: strings.pgc strings.h $(ECPG_TEST_DEPENDENCIES)
	$(ECPG) -i -o $@ $<

##########################################################################
#
# for testing syntax error detection of ecpg command

cmd_out_util.o: cmd_out_util.c
	$(CC) -D'BINARY_PATH="../preproc/ecpg"' -c $<

# cmd_out.c is not generated material
cmd_out.o: cmd_out.c
	$(CC) -D'PGC_FILE_NAME="preproc/notice.pgc"' -c $<
	rm -f ../expected/preproc-cmd_out.c
	cp cmd_out.c ../expected/preproc-cmd_out.c

# cmd_out_informix.c is not generated material
cmd_out_informix.o: cmd_out_informix.c
	$(CC) -D'PGC_FILE_NAME="preproc/notice_informix.pgc"' -c $<
	rm -f ../expected/preproc-cmd_out_informix.c
	cp cmd_out_informix.c ../expected/preproc-cmd_out_informix.c

cmd_out: cmd_out.o cmd_out_util.o
	$(CC) -o $@ $^

cmd_out_informix: cmd_out_informix.o cmd_out_util.o
	$(CC) -o $@ $^
