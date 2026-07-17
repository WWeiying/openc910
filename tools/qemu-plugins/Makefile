QEMU_ROOT ?= /work/toolchains/Xuantie-qemu-x86_64-Ubuntu-20.04-V5.2.8-B20250721-0303
PLUGIN_CFLAGS := -fPIC -shared -O2 -Wall -Wextra -fvisibility=hidden
GLIB_CFLAGS := $(shell pkg-config --cflags glib-2.0)
GLIB_LIBS := $(shell pkg-config --libs glib-2.0)

.PHONY: all check-fork clean

all: simple_bbv.so simpoint_probe.so restore_replay.so kernel_trace.so

check-fork: simple_bbv.so
	./test_simple_bbv_fork.sh

simple_bbv.so: simple_bbv.c
	@tmp="$@.tmp.$$$$"; trap 'rm -f "$$tmp"' EXIT; \
	  $(CC) $(PLUGIN_CFLAGS) -I$(QEMU_ROOT)/include $(GLIB_CFLAGS) $< -o "$$tmp" $(GLIB_LIBS) && \
	  mv -f "$$tmp" "$@"

simpoint_probe.so: simpoint_probe.c
	$(CC) $(PLUGIN_CFLAGS) -I$(QEMU_ROOT)/include $(GLIB_CFLAGS) $< -o $@ $(GLIB_LIBS)

restore_replay.so: restore_replay.c
	$(CC) $(PLUGIN_CFLAGS) -I$(QEMU_ROOT)/include $(GLIB_CFLAGS) $< -o $@ $(GLIB_LIBS)

kernel_trace.so: kernel_trace.c
	@tmp="$@.tmp.$$$$"; trap 'rm -f "$$tmp"' EXIT; \
	  $(CC) $(PLUGIN_CFLAGS) -I$(QEMU_ROOT)/include $(GLIB_CFLAGS) $< -o "$$tmp" $(GLIB_LIBS) && \
	  mv -f "$$tmp" "$@"

clean:
	rm -f simple_bbv.so simpoint_probe.so restore_replay.so kernel_trace.so
