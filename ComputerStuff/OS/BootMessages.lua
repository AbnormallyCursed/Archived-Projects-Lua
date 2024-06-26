return { Messages = {
	[1] = "[%s] Linux version 5.19.7-1-1.0 (linux@atlaslinux) (gcc (GCC) 12.2.0, GNU ld (GNU Binutils) 2.39.0) #! SMP PREEMPT_DYNAMIC Tue, 06, Sep 2022 08:55:32 +0000",
	[2] = "[%s] x86/fpu: x87 FPU will use FXSAVE",
	[3] = "[%s] signal: max sigframe size: 1440",
	[4] = "[%s] BIOS-provided physical RAM map:",
	[5] = "[%s] BIOS-e820 [mem 0x0000000000000000-0x000000000009fbff] usable",
	[6] = "[%s] BIOS-e820 [mem 0x000000000009fc00-0x000000000009ffff] reserved",
	[7] = "[%s] BIOS-e820 [mem 0x00000000000f0000-0x00000000000fffff] reserved",
	[8] = "[%s] BIOS-e820 [mem 0x0000000000100000-0x000000001ffbffff] usable",
	[9] = "[%s] BIOS-e820 [mem 0x000000001ffc0000-0x000000001fffffff] reserved",
	[10] = "[%s] BIOS-e820 [mem 0x00000000fffc0000-0x00000000ffffffff] reserved",
	[11] = "[%s] Notice: NX (Execute Disable) protection missing in CPU!",
	[12] = "[%s] DMI not present or invalid.",
	[13] = "[%s] hypercall mode: 0x00",
	[14] = "[%s] tsc: Detected 1000.000 MHz processor",
	[15] = "[%s] e820: update [mem 0x00000000-0x00000fff] usable ==> reserved",
	[16] = "[%s] e820: remove [mem 0x000a0000-0x000fffff] usable",
	[17] = "[%s] last_pfn = 0x1ffc0 max_linux_pfn = 0x100000",
	[18] = "[%s] Disabled",
	[19] = "[%s] x86/PAT: MTRRs disabled, skipping PAT initialization too.",
	[20] = "[%s] x86/PAT: Configuration [0-7]: WB WT UC- UC WB WT UC- UC",
	[21] = "[%s] found SMP MP-table at [mem 0x000f8bd0-0x000f8bdf]",
	[22] = "[%s] initial memory mapped: [mem 0x00000000-0x1dbfffff]",
	[23] = "[%s] RAMDISK: [mem 0x04000000-0x054aefff]",
	[24] = "[%s] ACPI: Early table checksum verification disabled",
	[25] = "[%s] ACPI BIOS Error (bug): A valid RSDP was not found (20220331/tbxfroot-210)",
	[26] = "[%s] 0MB HIGHMEM available.",
	[27] = "[%s] 511MB LOWMEM available.",
	[28] = "[%s]   mapped low ram: 0 - 1ffc0000",
	[29] = "[%s]   low ram: 0 - 1ffc0000",
	[30] = "[%s] Zone ranges:",
	[31] = "[%s]   ?DMA      [mem 0x0000000000001000-0x0000000000ffffff] ",
	[32] = "[%s]   ?Normal   [mem 0x0000000001000000-0x000000001ffbffff]",
	[33] = "[%s]   ?HighMem  empty",
	[34] = "[%s] Movable zone start for each node",
	[35] = "[%s] Early memory node ranges",
	[36] = "[%s] node     0: [mem 0x0000000000001000-0x000000000009efff] ",
	[37] = "[%s] node     0: [mem 0x0000000000100000-0x000000001ffbffff]",
	[38] = "[%s] Initmem setup node 0 [mem 0x0000000000001000-0x000000001ffbffff]",
	[39] = "[%s] On node 0, zone DMA: 1 pages in unavailable ranges",
	[40] = "[%s] On node 0, zone DMA: 97 pages in unavailable ranges",
	[41] = "[%s] Using APIC driver default",
	[42] = "[%s] Intel MultiProcessor Specification v1.4",
	[43] = "[%s]     Virtual Wire compatibility mode.",
	[44] = "[%s] MPTABLE: OEM ID: BOCHSCPU",
	[45] = "[%s] MPTABLE: Product ID: 0.1",
	[46] = "[%s] MPTABLE: APIC at: 0xFEE00000",
	[47] = "[%s] I/O APIC 0xfec00000 registers return all ones, skipping!",
	[48] = "[%s] MPTABLE: no processors registered!",
	[49] = "[%s] BIOS bug, MP table errors detected!...",
	[50] = "[%s] ... disabling SMP support. (tell your hw vendor)",
	[51] = '[%s] Local APIC disabled by BIOS -- you can enable it with "lapic"',
	[52] = "[%s] APIC: disable apic facility",
	[53] = "[%s] APIC: switched to apic NOOP",
	[54] = "[%s] smpboot: Allowing 2 CPUs, 1 hotplug CPUs",
	[55] = "[%s] PM: hibernation: Registered nosave memory: [mem 0x00000000-0x00000fff] ",
	[56] = "[%s] PM: hibernation: Registered nosave memory: [mem 0x0009f000-0x0009ffff] ",
	[57] = "[%s] PM: hibernation: Registered nosave memory: [mem 0x000a0000-0x000effff] ",
	[58] = "[%s] PM: hibernation: Registered nosave memory: [mem 0x000f0000-0x000fffff] ",
	[59] = "[%s] [mem 0x20000000-0xfffbffff] available for PCI devices",
	[60] = "[%s] clocksource: refined-jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 6370452778343963 ",
	[61] = "[%s] setup_percpu: NR_CPUS:64 nr_cpumask_bits:64 nr_cpu_ids:2 nr_node_ids:1",
	[62] = "[%s] percpu: Embedded 33 pages/cpu s104724 r0 d30444 u135168",
	[63] = "[%s] pcpu-alloc: s104724 r? d30444 u135168 alloc=33*4096",
	[64] = "[%s] pcpu-alloc: [0] 0 [0] 1",
	[65] = "[%s] Built 1 zonelists, mobility grouping on. Total pages: 129630",
	[66] = "[%s] Kernel command line: ru apm=off uga=0x344 video-vesafb:ypan, vremap:8 root-host9p rootfstype=9p rootflags=trans=virtio,cache-loose mitigations-off audit=0 init_on_free-on tsc-reliable random.trust_cpu-on nowatchdog init=/usr/bin/init-openrc net.ifnames=0 biosdevname=0",
	[67] = "[%s] audit: disabled (until reboot)",
	[68] = '[%s] Unknown kernel command line parameters "vga=0x344 biosdevname=0", will be passed to user space.',
	[69] = "[%s] Dentry cache hash table entries: 65536 (order: 6, 262144 bytes, linear)",
	[70] = "[%s] Inode-cache hash table entries: 32768 (order: 5, 131072 bytes, linear)",
	[71] = "[%s] allocated 528124 bytes of page_ext",
	[72] = "[%s] mem auto-init: stack:off, heap alloc:on, heap free:on",
	[73] = "[%s] mem auto-init: clearing system memory may take some time...",
	[74] = "[%s] Initializing HighMem for node 0 (00000000:00000000)",
	[75] = "[%s] Checking if this processor honours the WP bit even in supervisor mode...Ok.",
	[76] = "[%s] Memory: 469084K/523640K available (11147K kernel code, 1347K rwdata, 9700K rodata, 936K init, 644K bss, 54556K reserved, OK cma-reserved, OK highmem)",
	[77] = "[%s] SLUB: HWalign=32, Order=0-3, MinObjects=0, CPUs=2, Nodes=1 ",
	[78] = "[%s] ftrace: allocating 42035 entries in 83 pages",
	[79] = "[%s] ftrace: allocated 83 pages with 4 groups",
	[80] = "[%s] trace event string verifier disabled",
	[81] = "[%s] Dynamic Preempt: full",
	[82] = "[%s] rcu: Preemptible hierarchical RCU implementation.",
	[83] = "[%s] rcu: RCU restricting CPUs from NR_CPUS=64 to nr_cpu_ids=2. ",
	[84] = "[%s] rcu: RCU priority boosting: priority 1 delay 500 ms. ",
	[85] = "[%s]   Trampoline variant of Tasks RCU enabled.",
	[86] = "[%s]   Rude variant of Tasks RCU enabled.",
	[87] = "[%s]   Tracing variant of Tasks RCU enabled.",
	[88] = "[%s] rcu: RCU calculated value of scheduler-enlistment delay is 30 jiffies.",
	[89] = "[%s] rcu: Adjusting geometry for rcu_fanout_leaf-16, mr_cpu_ids=2",
	[90] = "[%s] NR_IRQS: 4352, nr_irqs: 48, preallocated irqs: 16",
	[91] = "[%s] rcu: srcu_init: Setting srcu_struct sizes based on contention.",
	[92] = "[%s] kfence: initialized - using 2097152 bytes for 255 objects at Ox(ptrual)-0x(ptrual)",
	[93] = "[%s] random crng init done",
	[94] = "[%s] Console: colour VGA+ 80x25",
	[95] = "[%s] printk: console [tty0] enabled",
	[96] = "[%s] APIC: Keep in PIC mode (8259)",
	[97] = "[%s] clocksource: tsc-early: mask: Oxffffffffffffffff max_cycles: 0x1cd42e4dffb, max_idle_ns: 881590591483 ns ",
	[98] = "[%s] Calibrating delay loop (skipped), value calculated using timer frequency.. 2000.33 BogoMIPS (1pj=3333333) ",
	[99] = "[%s] pid_max: default: 32768 minimum: 301",
	[100] = "[%s] LSM: Security Framework initializing",
	[101] = "[%s] landlock Up and running.",
	[102] = "[%s] Yama: becoming mindful.",
	[103] = "[%s] Mount-cache hash table entries: 1024 (order: 0, 4096 bytes, linear)",
	[104] = "[%s] Mountpoint-cache hash table entries: 1024 (order: 0, 4096 bytes, linear)",
	[105] = "[%s] Last level iTLB entries: 4KB 64, 2MB 64, 4MB 64",
	[106] = "[%s] Last level dTLB entries: 4KB 64, 2MB 0, 4MB 64, 1GB O",
	[107] = "[%s] Speculative Store Bypass: Vulnerable",
	[108] = "[%s] L1TF: Kernel not compiled for PAE. No mitigation for L1TF",
	[109] = "[%s] smpboot: weird, boot CPU (#0) not listed by the BIOS",
	[110] = "[%s] smpboot: SMP disabled",
	[111] = "[%s] cblist_init_generic: Setting adjustable number of callback queues.",
	[112] = "[%s] cblist_init_generic: Setting shift to 1 and lim to 1.",
	[113] = "[%s] cblist_init_generic: Setting shift to 1 and lim to 1.",
	[114] = "[%s] cblist_init_generic: Setting shift to 1 and lim to 1.",
	[115] = "[%s] Performance Events: unsupported Netburst CPU model 6 no PMU driver, software events only. ",
	[116] = "[%s] rcu: Hierarchical SRCU implementation.",
	[117] = "[%s] rcu: Max phase no-delay instances is 1000.",
	[118] = "[%s] NMI watchdog: Perf NMI watchdog permanently disabled",
	[119] = "[%s] smp: Bringing up secondary CPUs",
	[120] = "[%s] smp: Brought up 1 node, 1 CPU",
	[121] = "[%s] smpboot: Max logical packages: 2",
	[122] = "[%s] smpboot: Total of 1 processors activated (2000.33 BogoMIPS)",
	[123] = "[%s] devtmpfs: initialized",
	[124] = "[%s] clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 6370867519511994 ns ",
	[125] = "[%s] futex hash table entries: 256 (order: 2, 16384 bytes, linear)",
	[126] = "[%s] pinctrl core: initialized pinctrl subsystem",
	[127] = "[%s] PM: RTC time: 02:50:14, date: 2022-11-07",
	[128] = "[%s] NET: Registered PF_NETLINK/PF_ROUTE protocol family ",
	[129] = "[%s] thermal_sys: Registered thermal governor 'fair_share' ",
	[130] = "[%s] thermal_sys: Registered thermal governor 'bang_bang' ",
	[131] = "[%s] thermal_sys: Registered thermal governor 'step_wise' ",
	[132] = "[%s] thermal_sys: Registered thermal governor 'user_space' ",
	[133] = "[%s] thermal_sys: Registered thermal governor 'power_allocator'",
	[134] = "[%s] cpuidle: using governor ladder",
	[135] = "[%s] cpuidle: using governor menu",
	[136] = "[%s] clocksource: pit: mask: Oxffffffff max_cycles: 0xffffffff, max_idle_ns: 1601818034827 ns",
	[137] = "[%s] PCI PCI BIOS revision 2.10 entry at Oxfdb07, last bus=0",
	[138] = "[%s] PCI: Using configuration type 1 for base access",
	[139] = "[%s] kprobes: kprobe jump-optimization is enabled. All kprobes are optimized if possible. ",
	[140] = "[%s] Huge TLB registered 4.00 MiB page size, pre-allocated ? pages",
	[141] = "[%s] ACPI: Interpreter disabled.",
	[142] = "[%s] iommu: Default domain type: Translated",
	[143] = "[%s] iommu: DMA domain TLB invalidation policy: lazy mode",
	[144] = "[%s] SCSI subsystem initialized",
	[145] = "[%s] libata version 3.00 loaded.",
	[146] = "[%s] usbcore: registered new interface driver usbfs",
	[147] = "[%s] usbcore: registered new interface driver hub",
	[148] = "[%s] usbcore: registered new device driver usb",
	[149] = "[%s] pps_core: LinuxPPS API ver. 1 registered",
	[150] = "[%s] pps_core: Software ver. 5.3.6 Copyright 2005-2007 Rodolfo Giometti <giometti@linux.it> ",
	[151] = "[%s] PTP clock support registered",
	[152] = "[%s] EDAC MC: Ver: 3.0.0",
	[153] = "[%s] NetLabel: Initializing",
	[154] = "[%s] NetLabel:  domain hash size = 128",
	[155] = "[%s] NetLabel:  protocols = UNLABELED CIPSO 4 CALIPSO",
	[156] = "[%s] NetLabel:  unlabeled traffic allowed by default",
	[157] = "[%s] mctp: management component transport protocol core ",
	[158] = "[%s] NET: Registered PF_MCTP protocol family",
	[159] = "[%s] PCI: Probing PCI hardware",
	[160] = "[%s] PCI: root bus 00: using default resources",
	[161] = "[%s] PCI: Probing PCI hardware (bus 00)",
	[162] = "[%s] PCI host bridge to bus 0000:00",
	[163] = "[%s] pci_bus 0000:00: root bus resource [io 0x0000-0xffff]",
	[164] = "[%s] pci_bus 0000:00: root bus resource [mem 0x00000000-0xffffffff]",
	[165] = "[%s] pci_bus 0000:00: No busn resource found for root bus, will use [bus 00-ff]",
	[166] = "[%s] pci 0000:00:00.0: [8086:1237] type 00 class 0x060000 ",
	[167] = "[%s] pci 0000:00:01.0: [8086:7000] type 00 class 0x060100 ",
	[168] = "[%s] pci 0000:00:05.0: [10ec:8029] type 00 class 0x020000 ",
	[169] = "[%s] pci 0000:00:05.0: reg 0x10: [io 0xc140-0xc15f]",
	[170] = "[%s] pci 0000:00:06.0: [1af4:1049] type 00 class 0x000200 ",
	[171] = "[%s] pci 0000:00:06.0: reg 0x10: [io pci 0000:00:06.0: reg 0x14: [io pci 0000:00:06.0: reg 0x18: [io 0xc170-0xc17f]",
	[172] = "[%s] pci 0000:00:06.0: reg 0x1c: [io 0xc100-0xc13f10xc160-0xc16f]",
	[173] = "[%s] pci 0000:00:12.0: [1234:11111] type 00 class 0x030000",
	[174] = "[%s] pci 0000:00:12.0: reg 0x10: [mem 0xe0000000-0xe07fffff pref]",
	[175] = "[%s] pci 0000:00:12.0: reg 0x30: [mem 0xfeb00000-0xfeb0ffff pref]",
	[176] = "[%s] pci 0000:00:12.0: Video device with shadowed ROM at [mem 0x000c0000-0x000dffff] pci_bus 0000:00: busn_res: [bus 00-ff] end is updated to 00 pci 0000:00:01.0: PIIX/ICH IRQ router [8086:70001",
	[177] = "[%s] PCI: pci_cache_line_size set to 32 bytes",
	[178] = "[%s] e820: reserve RAM buffer [mem 0x0009fc00-0x0009ffff] ",
	[179] = "[%s] e820: reserve RAM buffer [mem 0x1ffc0000-0x1fffffffl ",
	[180] = "[%s] pci 0000:00:12.0: ugaarb: setting as boot VGA device",
	[181] = "[%s] pci 0000:00:12.0: ugaarb: bridge control possible",
	[182] = "[%s] pci 0000:00:12.0: ",
	[183] = "[%s] vgaarb: VGA device added: decodes=io+mem,owns=io+mem, locks=none ugaarb: loaded",
	[184] = "[%s] clocksource: Switched to clocksource tsc-early",
	[185] = "[%s] VFS: Disk quotas dquot_6.6.0",
	[186] = "[%s] VFS: Dquot-cache hash table entries: 1024 (order 0, 4096 bytes)",
	[187] = "[%s] pnp: PnP ACPI: disabled",
	[188] = "[%s] NET: Registered PF_INET protocol family",
	[189] = "[%s] IP idents hash table entries: 8192 (order: 4, 65536 bytes, linear)",
	[190] = "[%s] tcp_listen_portaddr_hash hash table entries: 512 (order: 0, 4096 bytes, linear)",
	[191] = "[%s] Table-perturb hash table entries: 65536 (order: 6, 262144 bytes, linear)",
	[192] = "[%s] TCP established hash table entries: 4096 (order: 2, 16384 bytes, linear)",
	[193] = "[%s] TCP bind hash table entries: 4096 (order: 3, 32768 bytes, linear)",
	[194] = "[%s] TCP: Hash tables configured (established 4096 bind 4096)",
	[195] = "[%s] MPTCP token hash table entries: 512 (order: 1, 8192 bytes, linear) ",
	[196] = "[%s] UDP hash table entries: 256 (order: 1, 8192 bytes, linear) ",
	[197] = "[%s] UDP-Lite hash table entries: 256 (order: 1, 8192 bytes, linear) ",
	[198] = "[%s] NET: Registered PF_UNIX/PF_LOCAL protocol family",
	[199] = "[%s] pci_bus 0000:00: resource 4 [io 0x0000-0xffff]",
	[200] = "[%s] pci_bus 0000:00: resource 5 [mem 0x00000000-0xffffffff] pci 0000:00:01.0: PIIX3: Enabling Passive Release",
	[201] = "[%s] pci 0000:00:00.0: Limiting direct PCI/PCI transfers pci 0000:00:01.0: Activating ISA DMA hang workarounds PCI CLS 0 bytes, default 32",
	[202] = "[%s] PCI: CLS 0 bytes, defualt 32",
	[203] = "[%s] Trying to unpack rootfs image as initramfs...",
	[204] = "[%s] clocksource: tsc: mask: 0xffffffffffffffff max_cycles: 0x1cd42e4dffb, max_idle_ns: 881590591483 ns ",
	[205] = "[%s] clocksource: Switched to clocksource tsc",
	[206] = "[%s] platform rtc_cmos: registered platform RTC device (no PNP device found)",
	[207] = "[%s] apm: BIOS version 1.2 Flags 0x03 (Driver version 1.16ac)",
	[208] = "[%s] apm: disabled on user request.",
	[209] = "[%s] Initialise system trusted keyrings",
	[210] = "[%s] Key type blacklist registered",
	[211] = "[%s] workingset: timestamp_bits=14 max_order=17 bucket_order=3 ",
	[212] = "[%s] zbud: loaded",
	[213] = "[%s] integrity: Platform Keyring initialized",
	[214] = "[%s] integrity: Machine keyring initialized",
	[215] = "[%s] Key type asymmetric registered",
	[216] = "[%s] Asymmetric key parser 'x509' registered",
	[217] = "[%s] Freeing initrd memory: 21180K",
	[218] = "[%s] alg: self-tests for CTR-KDF (hmac(sha256)) passed",
	[219] = "[%s] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 245)",
	[220] = "[%s] io scheduler mq-deadline registered",
	[221] = "[%s] io scheduler kyber registered",
	[222] = "[%s] io scheduler bfq registered",
	[223] = "[%s] isapnp: Scanning for PnP cards...",
	[224] = "[%s] isapmp: No Plug & Play device found",
	[225] = "[%s] Serial: 8250/16550 driver, 32 ports, IRQ sharing enabled",
	[226] = "[%s] serial8250: ttyS0 at I/0 0x3f8 (irq",
	[227] = "[%s] Non-volatile memory driver v1.3",
	[228] = "[%s] Linux agpgart interface v0.103=4, base_baud = 115200) is a 16550A",
	[229] = "[%s] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver",
	[230] = "[%s] ehci-pci: EHCI PCI platform driver",
	[231] = "[%s] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver",
	[232] = "[%s] ohci-pci: OHCI PCI platform driver",
	[233] = "[%s] uhci_hcd: USB Universal Host Controller Interface driver",
	[234] = "[%s] usbcore: registered new interface driver usbserial_generic",
	[235] = "[%s] usbserial: USB Serial support registered for generic",
	[236] = "[%s] rtc_cmos rtc_cmos: registered as rtco",
	[237] = "[%s] rtc_cmos rtc_cmos: setting system clock to 2022-11-07T02:50:16 UTC (1667789416) ",
	[238] = "[%s] rtc_cmos rtc_cmos: alarms up to one day, 114 bytes nuram",
	[239] = "[%s] intel_pstate: CPU model not supported",
	[240] = "[%s] ledtrig-cpu: registered to indicate activity on CPUs",
	[241] = "[%s] hid: raw HID events driver (C) Jiri Kosina",
	[242] = "[%s] drop_monitor: Initializing network drop monitor service Initializing XFRM netlink socket",
	[243] = "[%s] NET: Registered PF_INET6 protocol family",
	[244] = "[%s] Segment Routing with IPv6",
	[245] = "[%s] RPL Segment Routing with IPv6 ",
	[246] = "[%s] In-situ OAM (IOAM) with IPv6",
	[247] = "[%s] NET: Registered PF_PACKET protocol family ",
	[248] = "[%s] mce: Unable to init MCE device (rc: -5)",
	[249] = "[%s] IPI shorthand broadcast: enabled",
	[250] = "[%s] sched_clock: Marking stable (4469963192, 19294141)-> (4559900446, -70643113)",
	[251] = "[%s] registered taskstats version 1",
	[252] = "[%s] Loading compiled-in X.509 certificates",
	[253] = "[%s] Loaded X.509 cert 'Build time autogenerated kernel key: Za7c6d92516c7dfc7ad95c72f284e54b23d78787' ",
	[254] = "[%s] zswap: loaded using pool lz4/z3fold",
	[255] = "[%s] Key type ._fscrypt registered",
	[256] = "[%s] Key type .fscrypt registered",
	[257] = "[%s] Key type fscrypt-provisioning registered",
	[258] = "[%s] PM: Magic number: 14:552:813",
	[259] = "[%s] RAS: Correctable Errors collector initialized.",
	[260] = "[%s] Freeing unused kernel image (initmem) memory: 936K",
	[261] = "[%s] Write protecting kernel text and read-only data: 20848k rodata_test: all tests were successful",
	[262] = "[%s] Run init as init process",
	[263] = "[%s]   with arguments: ",
	[264] = "[%s]     /init",
	[265] = "[%s]   with environment:",
	[266] = "[%s]     HOME=/",
	[267] = "[%s]     TERM=1inux ",
	[268] = "[%s]     vga=0x344",
	[269] = "[%s]     biosdevname=0",
	[270] = "[%s] 18042: PNP: No PS/2 controller found.",
	[271] = "[%s] 18042: Probing ports directly.",
	[272] = "[%s] serio: i8042 KBD port at 0x60,0x64 irq 1",
	[273] = "[%s] input: AT Translated Set 2 keyboard as /devices/platform/i8042/serio0/input/input0",
	[274] = "[%s] serio: 18042 AUX port at 0x60,0x64 irq 1",
	[275] = "[%s] psmouse serio1: hgpk: ID: 08 00 00",
	[276] = "[%s] PCI: setting IRQ 10 as level-triggered",
	[277] = "[%s] virtio-pci 0000:00:06.0: found PCI INT � -> IRQ 10",
	[278] = "[%s] 9pnet: Installing 9P2000 support",
	[279] = "[%s] input: ImExPS/2 Generic Explorer Mouse as /devices/platform/i8042/serio1/input/input2 FS-Cache: Loaded",
	[280] = "[%s] 9p: Installing v9fs 9p2000 file system support",
	[281] = "[%s] SA sound/drivers/op13/op13_lib.c:95 OPL3: stat1 = 0xff",
	[282] = "[%s] SA sound/drivers/op13/op13_lib.c:435 OPL2/3 chip not detected at 0x220/0x222",
	[283] = "[%s] SA sound/isa/sb/sb16.c:382 sb16: no OPL device at 0x220-0xZZZ",
	[284] = "[%s] bochs-drm 0000:00:12.0: ugaarb: deactivate uga console",
	[285] = "[%s] Console: switching to colour dummy device 80x25",
	[286] = "[%s] [drm] Found bochs VGA, ID 0xb0c0.",
	[287] = "[%s] [drm] Framebuffer size 8192 kB @ 0xe0000000, ioports @ 0x1ce.",
	[288] = "[%s] [drm] Initialized bochs-drm 1.0.0 20130925 for 0000:00:12.0 on minor 0",
	[289] = "[%s] fbcon: bochs-drmdrmfb (fb0) is primary device",
	[290] = "[%s] Console: switching to colour frame buffer device 128x48",
	[291] = "[%s] bochs-drm 0000:00:12.0: [drm] fb0: bochs-drmdrmfb frame buffer device ",
	[292] = "[%s] bash (1252): drop_caches: 3"
},

Time = {
	[1] = 0,
	[2] = 0,
	[3] = 0,
	[4] = 0,
	[5] = 0,
	[6] = 0,
	[7] = 0,
	[8] = 0,
	[9] = 0,
	[10] = 0,
	[11] = 0,
	[12] = 0,
	[13] = 0,
	[14] = 0,
	[184] = 0.5,
	[223] = 0.5,
	[270] = 2,
	[274] = 2,
	[276] = 0.5,
	[280] = 8,
	[283] = 1.3,
	[284] = 0.1,
	[285] = 0.1,
	[286] = 0.1,
	[282] = 0.1,
	[287] = 0.1,
	[288] = 0.1,
	[289] = 0.1,
	[290] = 0.1,
	[291] = 0.1,
	[292] = 3,
}}