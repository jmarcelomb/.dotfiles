#!/usr/bin/env python3
"""CPU/RAM sampler daemon for sketchybar.

Reads the kernel counters directly every TICK seconds and updates the cpu and
ram items in ONE batched sketchybar call per tick. No process spawns per tick,
far below 1% CPU.

CPU comes from host_statistics(HOST_CPU_LOAD_INFO) aggregate ticks (the
per-core host_processor_info variant is killed under some sandboxed contexts).
RAM comes from host_statistics64.

Launched by sketchybarrc (guarded by pgrep). Exits after a minute of failed
sketchybar calls (bar gone) so it never lingers uselessly.
"""

import ctypes
import ctypes.util
import os
import sys
import time

TICK = 2.0
MAX_CONSECUTIVE_FAILURES = 30

lib = ctypes.CDLL(ctypes.util.find_library("c"))
kr = lib

MACH_PORT_NULL = 0
HOST_CPU_LOAD_INFO = 3
HOST_VM_INFO64 = 4

c_u32 = ctypes.c_uint32
c_int = ctypes.c_int


class host_cpu_load_info(ctypes.Structure):
    _fields_ = [("load", c_u32 * 4)]  # user, system, idle, nice


class vm_statistics64(ctypes.Structure):
    _fields_ = [
        ("free_count", c_u32),
        ("active_count", c_u32),
        ("inactive_count", c_u32),
        ("wire_count", c_u32),
        ("zero_fill_count", ctypes.c_uint64),
        ("reactivations", ctypes.c_uint64),
        ("pageins", ctypes.c_uint64),
        ("pageouts", ctypes.c_uint64),
        ("faults", ctypes.c_uint64),
        ("cow_faults", ctypes.c_uint64),
        ("lookups", ctypes.c_uint64),
        ("hits", ctypes.c_uint64),
        ("purges", ctypes.c_uint64),
        ("purgeable_count", c_u32),
        ("speculative_count", c_u32),
        ("decompressions", ctypes.c_uint64),
        ("compressions", ctypes.c_uint64),
        ("swapins", ctypes.c_uint64),
        ("swapouts", ctypes.c_uint64),
        ("compressor_page_count", c_u32),
        ("throttled_count", c_u32),
        ("external_page_count", c_u32),
        ("internal_page_count", c_u32),
        ("total_uncompressed_pages", ctypes.c_uint64),
    ]


kr.mach_host_self.restype = c_u32
kr.host_statistics.restype = c_int
kr.host_statistics.argtypes = [c_u32, c_int,
                               ctypes.POINTER(host_cpu_load_info),
                               ctypes.POINTER(c_u32)]
kr.host_statistics64.restype = c_int
kr.host_statistics64.argtypes = [c_u32, c_int, ctypes.POINTER(vm_statistics64),
                                 ctypes.POINTER(c_u32)]
kr.sysctlbyname.restype = c_int
kr.sysctlbyname.argtypes = [ctypes.c_char_p, ctypes.c_void_p,
                            ctypes.POINTER(ctypes.c_size_t),
                            ctypes.c_void_p, ctypes.c_size_t]

HOST = kr.mach_host_self()


def read_cpu(prev):
    """Return ((busy, total) ticks, cpu%). pct is None on the first call."""
    s = host_cpu_load_info()
    cnt = c_u32(4)
    if kr.host_statistics(HOST, HOST_CPU_LOAD_INFO, ctypes.byref(s),
                          ctypes.byref(cnt)) != 0:
        return prev, None
    user, system, idle, nice = s.load[0], s.load[1], s.load[2], s.load[3]
    busy = user + system + nice
    total = user + system + idle + nice
    pct = None
    if prev is not None:
        dt = total - prev[1]
        if dt > 0:
            pct = 100.0 * (busy - prev[0]) / dt
    return (busy, total), pct


def read_ram():
    total = ctypes.c_uint64(0)
    size = ctypes.c_size_t(8)
    kr.sysctlbyname(b"hw.memsize", ctypes.byref(total), ctypes.byref(size),
                    None, 0)
    vm = vm_statistics64()
    vm_count = c_u32(ctypes.sizeof(vm) // ctypes.sizeof(c_u32))
    if kr.host_statistics64(HOST, HOST_VM_INFO64, ctypes.byref(vm),
                            ctypes.byref(vm_count)) != 0:
        return None
    pagesize = 16384  # Apple Silicon host page size
    usable = (vm.free_count + vm.inactive_count + vm.purgeable_count) * pagesize
    return 100.0 * max(total.value - usable, 0) / total.value


def push(cpu_pct, ram_pct):
    import subprocess
    cmd = ["sketchybar", "--set", "cpu", "label=%.0f%%" % cpu_pct,
           "--set", "ram", "label=%.0f%%" % ram_pct]
    return subprocess.call(cmd, stdout=subprocess.DEVNULL,
                           stderr=subprocess.DEVNULL)


def main():
    with open("/tmp/sketchybar_stats.pid", "w") as f:
        f.write(str(os.getpid()))
    prev, cpu_pct = read_cpu(None)
    failures = 0
    while True:
        time.sleep(TICK)
        prev, cpu_pct = read_cpu(prev)
        ram_pct = read_ram()
        if cpu_pct is None or ram_pct is None:
            continue
        if push(cpu_pct, ram_pct) == 0:
            failures = 0
        else:
            failures += 1
            if failures >= MAX_CONSECUTIVE_FAILURES:
                sys.exit(0)


if __name__ == "__main__":
    main()
