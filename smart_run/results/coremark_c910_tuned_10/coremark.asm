
coremark.elf:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <__start>:
       0:	004001b7          	lui	gp,0x400
       4:	7c01a073          	csrs	mxstatus,gp
       8:	6199                	lui	gp,0x6
       a:	3001a073          	csrs	mstatus,gp
       e:	008001b7          	lui	gp,0x800
      12:	3001a073          	csrs	mstatus,gp
      16:	61a1                	lui	gp,0x8
      18:	7c01a073          	csrs	mxstatus,gp
      1c:	006381b7          	lui	gp,0x638
      20:	7c01a073          	csrs	mxstatus,gp
      24:	7f30e073          	csrsi	msmpr,1
      28:	4081                	li	ra,0
      2a:	4101                	li	sp,0
      2c:	4181                	li	gp,0
      2e:	4201                	li	tp,0
      30:	4281                	li	t0,0
      32:	4301                	li	t1,0
      34:	4381                	li	t2,0
      36:	4401                	li	s0,0
      38:	4481                	li	s1,0
      3a:	4501                	li	a0,0
      3c:	4581                	li	a1,0
      3e:	4601                	li	a2,0
      40:	4681                	li	a3,0
      42:	4701                	li	a4,0
      44:	4781                	li	a5,0
      46:	4801                	li	a6,0
      48:	4881                	li	a7,0
      4a:	4901                	li	s2,0
      4c:	4981                	li	s3,0
      4e:	4a01                	li	s4,0
      50:	4a81                	li	s5,0
      52:	4b01                	li	s6,0
      54:	4b81                	li	s7,0
      56:	4c01                	li	s8,0
      58:	4c81                	li	s9,0
      5a:	4d01                	li	s10,0
      5c:	4d81                	li	s11,0
      5e:	4e01                	li	t3,0
      60:	4e81                	li	t4,0
      62:	4f01                	li	t5,0
      64:	4f81                	li	t6,0
      66:	f14021f3          	csrr	gp,mhartid
      6a:	4205                	li	tp,1

000000000000006c <cpu_0_sp>:
      6c:	000ee117          	auipc	sp,0xee
      70:	f9410113          	addi	sp,sp,-108 # ee000 <__kernel_stack>
      74:	00000197          	auipc	gp,0x0
      78:	08a18193          	addi	gp,gp,138 # fe <__trap_handler>
      7c:	30519073          	csrw	mtvec,gp
      80:	41a1                	li	gp,8
      82:	3001a073          	csrs	mstatus,gp
      86:	000701b7          	lui	gp,0x70
      8a:	21cd                	addiw	gp,gp,19 # 70013 <heap_end.0+0x2ef5b>
      8c:	7c21a073          	csrs	mcor,gp
      90:	6185                	lui	gp,0x1
      92:	1ff1819b          	addiw	gp,gp,511 # 11ff <core_bench_list+0x89f>
      96:	7c11a073          	csrs	mhcr,gp

000000000000009a <after_l2en>:
      9a:	6185                	lui	gp,0x1
      9c:	1ff1819b          	addiw	gp,gp,511 # 11ff <core_bench_list+0x89f>
      a0:	7c11a073          	csrs	mhcr,gp
      a4:	0006e1b7          	lui	gp,0x6e
      a8:	30c1819b          	addiw	gp,gp,780 # 6e30c <heap_end.0+0x2d254>
      ac:	7c51a073          	csrs	mhint,gp
      b0:	0070019b          	addiw	gp,zero,7
      b4:	01f6                	slli	gp,gp,0x1d
      b6:	01a5                	addi	gp,gp,9
      b8:	7c31a073          	csrs	mccr2,gp
      bc:	5a4060ef          	jal	6660 <main>

00000000000000c0 <__exit>:
      c0:	4501                	li	a0,0
      c2:	05a00093          	li	ra,90
      c6:	06b00113          	li	sp,107
      ca:	07c00193          	li	gp,124
      ce:	0180000b          	th.sync
      d2:	004441b7          	lui	gp,0x444
      d6:	3331819b          	addiw	gp,gp,819 # 444333 <__kernel_stack+0x356333>
      da:	01b2                	slli	gp,gp,0xc
      dc:	22218193          	addi	gp,gp,546
      e0:	820e                	mv	tp,gp

00000000000000e2 <__fail>:
      e2:	4501                	li	a0,0
      e4:	02c00093          	li	ra,44
      e8:	03b00113          	li	sp,59
      ec:	0180000b          	th.sync
      f0:	004701b7          	lui	gp,0x470
      f4:	4691819b          	addiw	gp,gp,1129 # 470469 <__kernel_stack+0x382469>
      f8:	01be                	slli	gp,gp,0xf
      fa:	72018193          	addi	gp,gp,1824

00000000000000fe <__trap_handler>:
      fe:	a03d                	j	12c <__synchronous_exception>
     100:	a085                	j	160 <__asychronous_int>
     102:	0001                	nop
     104:	0001                	nop
     106:	0001                	nop
     108:	a8a1                	j	160 <__asychronous_int>
     10a:	0001                	nop
     10c:	a891                	j	160 <__asychronous_int>
     10e:	0001                	nop
     110:	a881                	j	160 <__asychronous_int>
     112:	0001                	nop
     114:	0001                	nop
     116:	0001                	nop
     118:	a0a1                	j	160 <__asychronous_int>
     11a:	0001                	nop
     11c:	a091                	j	160 <__asychronous_int>
     11e:	0001                	nop
     120:	a081                	j	160 <__asychronous_int>
     122:	0001                	nop
     124:	0001                	nop
     126:	0001                	nop
     128:	a825                	j	160 <__asychronous_int>
     12a:	bf65                	j	e2 <__fail>

000000000000012c <__synchronous_exception>:
     12c:	fed12e23          	sw	a3,-4(sp)
     130:	fee12c23          	sw	a4,-8(sp)
     134:	fef12a23          	sw	a5,-12(sp)
     138:	34202773          	csrr	a4,mcause
     13c:	7ff77793          	andi	a5,a4,2047
     140:	936d                	srli	a4,a4,0x3b
     142:	8b41                	andi	a4,a4,16
     144:	973e                	add	a4,a4,a5
     146:	070e                	slli	a4,a4,0x3
     148:	00000797          	auipc	a5,0x0
     14c:	2b878793          	addi	a5,a5,696 # 400 <vector_table>
     150:	97ba                	add	a5,a5,a4
     152:	4398                	lw	a4,0(a5)
     154:	ffc12683          	lw	a3,-4(sp)
     158:	ff412783          	lw	a5,-12(sp)
     15c:	1771                	addi	a4,a4,-4
     15e:	8702                	jr	a4

0000000000000160 <__asychronous_int>:
     160:	fed12e23          	sw	a3,-4(sp)
     164:	fee12c23          	sw	a4,-8(sp)
     168:	fef12a23          	sw	a5,-12(sp)
     16c:	34202773          	csrr	a4,mcause
     170:	7ff77793          	andi	a5,a4,2047
     174:	936d                	srli	a4,a4,0x3b
     176:	8b41                	andi	a4,a4,16
     178:	973e                	add	a4,a4,a5
     17a:	070e                	slli	a4,a4,0x3
     17c:	00000797          	auipc	a5,0x0
     180:	28478793          	addi	a5,a5,644 # 400 <vector_table>
     184:	97ba                	add	a5,a5,a4
     186:	4398                	lw	a4,0(a5)
     188:	ffc12683          	lw	a3,-4(sp)
     18c:	ff412783          	lw	a5,-12(sp)
     190:	1771                	addi	a4,a4,-4
     192:	8702                	jr	a4
     194:	00000013          	nop
     198:	00000013          	nop
     19c:	00000013          	nop
     1a0:	00000013          	nop
     1a4:	00000013          	nop
     1a8:	00000013          	nop
     1ac:	00000013          	nop
     1b0:	00000013          	nop
     1b4:	00000013          	nop
     1b8:	00000013          	nop
     1bc:	00000013          	nop
     1c0:	00000013          	nop
     1c4:	00000013          	nop
     1c8:	00000013          	nop
     1cc:	00000013          	nop
     1d0:	00000013          	nop
     1d4:	00000013          	nop
     1d8:	00000013          	nop
     1dc:	00000013          	nop
     1e0:	00000013          	nop
     1e4:	00000013          	nop
     1e8:	00000013          	nop
     1ec:	00000013          	nop
     1f0:	00000013          	nop
     1f4:	00000013          	nop
     1f8:	00000013          	nop
     1fc:	00000013          	nop
     200:	00000013          	nop
     204:	00000013          	nop
     208:	00000013          	nop
     20c:	00000013          	nop
     210:	00000013          	nop
     214:	00000013          	nop
     218:	00000013          	nop
     21c:	00000013          	nop
     220:	00000013          	nop
     224:	00000013          	nop
     228:	00000013          	nop
     22c:	00000013          	nop
     230:	00000013          	nop
     234:	00000013          	nop
     238:	00000013          	nop
     23c:	00000013          	nop
     240:	00000013          	nop
     244:	00000013          	nop
     248:	00000013          	nop
     24c:	00000013          	nop
     250:	00000013          	nop
     254:	00000013          	nop
     258:	00000013          	nop
     25c:	00000013          	nop
     260:	00000013          	nop
     264:	00000013          	nop
     268:	00000013          	nop
     26c:	00000013          	nop
     270:	00000013          	nop
     274:	00000013          	nop
     278:	00000013          	nop
     27c:	00000013          	nop
     280:	00000013          	nop
     284:	00000013          	nop
     288:	00000013          	nop
     28c:	00000013          	nop
     290:	00000013          	nop
     294:	00000013          	nop
     298:	00000013          	nop
     29c:	00000013          	nop
     2a0:	00000013          	nop
     2a4:	00000013          	nop
     2a8:	00000013          	nop
     2ac:	00000013          	nop
     2b0:	00000013          	nop
     2b4:	00000013          	nop
     2b8:	00000013          	nop
     2bc:	00000013          	nop
     2c0:	00000013          	nop
     2c4:	00000013          	nop
     2c8:	00000013          	nop
     2cc:	00000013          	nop
     2d0:	00000013          	nop
     2d4:	00000013          	nop
     2d8:	00000013          	nop
     2dc:	00000013          	nop
     2e0:	00000013          	nop
     2e4:	00000013          	nop
     2e8:	00000013          	nop
     2ec:	00000013          	nop
     2f0:	00000013          	nop
     2f4:	00000013          	nop
     2f8:	00000013          	nop
     2fc:	00000013          	nop
     300:	00000013          	nop
     304:	00000013          	nop
     308:	00000013          	nop
     30c:	00000013          	nop
     310:	00000013          	nop
     314:	00000013          	nop
     318:	00000013          	nop
     31c:	00000013          	nop
     320:	00000013          	nop
     324:	00000013          	nop
     328:	00000013          	nop
     32c:	00000013          	nop
     330:	00000013          	nop
     334:	00000013          	nop
     338:	00000013          	nop
     33c:	00000013          	nop
     340:	00000013          	nop
     344:	00000013          	nop
     348:	00000013          	nop
     34c:	00000013          	nop
     350:	00000013          	nop
     354:	00000013          	nop
     358:	00000013          	nop
     35c:	00000013          	nop
     360:	00000013          	nop
     364:	00000013          	nop
     368:	00000013          	nop
     36c:	00000013          	nop
     370:	00000013          	nop
     374:	00000013          	nop
     378:	00000013          	nop
     37c:	00000013          	nop
     380:	00000013          	nop
     384:	00000013          	nop
     388:	00000013          	nop
     38c:	00000013          	nop
     390:	00000013          	nop
     394:	00000013          	nop
     398:	00000013          	nop
     39c:	00000013          	nop
     3a0:	00000013          	nop
     3a4:	00000013          	nop
     3a8:	00000013          	nop
     3ac:	00000013          	nop
     3b0:	00000013          	nop
     3b4:	00000013          	nop
     3b8:	00000013          	nop
     3bc:	00000013          	nop
     3c0:	00000013          	nop
     3c4:	00000013          	nop
     3c8:	00000013          	nop
     3cc:	00000013          	nop
     3d0:	00000013          	nop
     3d4:	00000013          	nop
     3d8:	00000013          	nop
     3dc:	00000013          	nop
     3e0:	00000013          	nop
     3e4:	00000013          	nop
     3e8:	00000013          	nop
     3ec:	00000013          	nop
     3f0:	00000013          	nop
     3f4:	00000013          	nop
     3f8:	00000013          	nop
     3fc:	00000013          	nop

0000000000000400 <vector_table>:
     400:	000000e2          	.word	0x000000e2
     404:	000000e2          	.word	0x000000e2
     408:	000000e2          	.word	0x000000e2
     40c:	000000e2          	.word	0x000000e2
     410:	000000e2          	.word	0x000000e2
     414:	000000e2          	.word	0x000000e2
     418:	000000e2          	.word	0x000000e2
     41c:	000000e2          	.word	0x000000e2
     420:	000000e2          	.word	0x000000e2
     424:	000000e2          	.word	0x000000e2
     428:	000000e2          	.word	0x000000e2
     42c:	000000e2          	.word	0x000000e2
     430:	000000e2          	.word	0x000000e2
     434:	000000e2          	.word	0x000000e2
     438:	000000e2          	.word	0x000000e2
     43c:	000000e2          	.word	0x000000e2
     440:	000000e2          	.word	0x000000e2
     444:	000000e2          	.word	0x000000e2
     448:	000000e2          	.word	0x000000e2
     44c:	000000e2          	.word	0x000000e2
     450:	000000e2          	.word	0x000000e2
     454:	000000e2          	.word	0x000000e2
     458:	000000e2          	.word	0x000000e2
     45c:	000000e2          	.word	0x000000e2
     460:	000000e2          	.word	0x000000e2
     464:	000000e2          	.word	0x000000e2
     468:	000000e2          	.word	0x000000e2
     46c:	000000e2          	.word	0x000000e2
     470:	000000e2          	.word	0x000000e2
     474:	000000e2          	.word	0x000000e2
     478:	000000e2          	.word	0x000000e2
     47c:	000000e2          	.word	0x000000e2
     480:	000000e2          	.word	0x000000e2
     484:	000000e2          	.word	0x000000e2
     488:	000000e2          	.word	0x000000e2
     48c:	000000e2          	.word	0x000000e2
     490:	000000e2          	.word	0x000000e2
     494:	000000e2          	.word	0x000000e2
     498:	000000e2          	.word	0x000000e2
     49c:	000000e2          	.word	0x000000e2
     4a0:	000000e2          	.word	0x000000e2
     4a4:	000000e2          	.word	0x000000e2
     4a8:	000000e2          	.word	0x000000e2
     4ac:	000000e2          	.word	0x000000e2
     4b0:	000000e2          	.word	0x000000e2
     4b4:	000000e2          	.word	0x000000e2
     4b8:	000000e2          	.word	0x000000e2
     4bc:	000000e2          	.word	0x000000e2
     4c0:	000000e2          	.word	0x000000e2
     4c4:	000000e2          	.word	0x000000e2
     4c8:	000000e2          	.word	0x000000e2
     4cc:	000000e2          	.word	0x000000e2
     4d0:	000000e2          	.word	0x000000e2
     4d4:	000000e2          	.word	0x000000e2
     4d8:	000000e2          	.word	0x000000e2
     4dc:	000000e2          	.word	0x000000e2
     4e0:	000000e2          	.word	0x000000e2
     4e4:	000000e2          	.word	0x000000e2
     4e8:	000000e2          	.word	0x000000e2
     4ec:	000000e2          	.word	0x000000e2
     4f0:	000000e2          	.word	0x000000e2
     4f4:	000000e2          	.word	0x000000e2
     4f8:	000000e2          	.word	0x000000e2
     4fc:	000000e2          	.word	0x000000e2
     500:	000000e2          	.word	0x000000e2
     504:	000000e2          	.word	0x000000e2
     508:	000000e2          	.word	0x000000e2
     50c:	000000e2          	.word	0x000000e2
     510:	000000e2          	.word	0x000000e2
     514:	000000e2          	.word	0x000000e2
     518:	000000e2          	.word	0x000000e2
     51c:	000000e2          	.word	0x000000e2
     520:	000000e2          	.word	0x000000e2
     524:	000000e2          	.word	0x000000e2
     528:	000000e2          	.word	0x000000e2
     52c:	000000e2          	.word	0x000000e2
     530:	000000e2          	.word	0x000000e2
     534:	000000e2          	.word	0x000000e2
     538:	000000e2          	.word	0x000000e2
     53c:	000000e2          	.word	0x000000e2
     540:	000000e2          	.word	0x000000e2
     544:	000000e2          	.word	0x000000e2
     548:	000000e2          	.word	0x000000e2
     54c:	000000e2          	.word	0x000000e2
     550:	000000e2          	.word	0x000000e2
     554:	000000e2          	.word	0x000000e2
     558:	000000e2          	.word	0x000000e2
     55c:	000000e2          	.word	0x000000e2
     560:	000000e2          	.word	0x000000e2
     564:	000000e2          	.word	0x000000e2
     568:	000000e2          	.word	0x000000e2
     56c:	000000e2          	.word	0x000000e2
     570:	000000e2          	.word	0x000000e2
     574:	000000e2          	.word	0x000000e2
     578:	000000e2          	.word	0x000000e2
     57c:	000000e2          	.word	0x000000e2
     580:	000000e2          	.word	0x000000e2
     584:	000000e2          	.word	0x000000e2
     588:	000000e2          	.word	0x000000e2
     58c:	000000e2          	.word	0x000000e2
     590:	000000e2          	.word	0x000000e2
     594:	000000e2          	.word	0x000000e2
     598:	000000e2          	.word	0x000000e2
     59c:	000000e2          	.word	0x000000e2
     5a0:	000000e2          	.word	0x000000e2
     5a4:	000000e2          	.word	0x000000e2
     5a8:	000000e2          	.word	0x000000e2
     5ac:	000000e2          	.word	0x000000e2
     5b0:	000000e2          	.word	0x000000e2
     5b4:	000000e2          	.word	0x000000e2
     5b8:	000000e2          	.word	0x000000e2
     5bc:	000000e2          	.word	0x000000e2
     5c0:	000000e2          	.word	0x000000e2
     5c4:	000000e2          	.word	0x000000e2
     5c8:	000000e2          	.word	0x000000e2
     5cc:	000000e2          	.word	0x000000e2
     5d0:	000000e2          	.word	0x000000e2
     5d4:	000000e2          	.word	0x000000e2
     5d8:	000000e2          	.word	0x000000e2
     5dc:	000000e2          	.word	0x000000e2
     5e0:	000000e2          	.word	0x000000e2
     5e4:	000000e2          	.word	0x000000e2
     5e8:	000000e2          	.word	0x000000e2
     5ec:	000000e2          	.word	0x000000e2
     5f0:	000000e2          	.word	0x000000e2
     5f4:	000000e2          	.word	0x000000e2
     5f8:	000000e2          	.word	0x000000e2
     5fc:	000000e2          	.word	0x000000e2

0000000000000600 <__dummy>:
	...

0000000000000670 <__thead_vprintfsprintf>:
     670:	4501                	li	a0,0
     672:	8082                	ret
     674:	00000013          	nop
     678:	00000013          	nop
     67c:	00000013          	nop

0000000000000680 <__thead_vprintfprintf>:
     680:	4501                	li	a0,0
     682:	8082                	ret
     684:	00000013          	nop
     688:	00000013          	nop
     68c:	00000013          	nop

0000000000000690 <stdout>:
     690:	4501                	li	a0,0
     692:	8082                	ret
	...

00000000000006a0 <calc_func>:
     6a0:	7179                	addi	sp,sp,-48
     6a2:	fc11540b          	th.sdd	s0,ra,(sp),2,4
     6a6:	00051403          	lh	s0,0(a0)
     6aa:	1c74378b          	th.extu	a5,s0,7,7
     6ae:	c799                	beqz	a5,6bc <calc_func+0x1c>
     6b0:	07f47513          	andi	a0,s0,127
     6b4:	fc11440b          	th.ldd	s0,ra,(sp),2,4
     6b8:	6145                	addi	sp,sp,48
     6ba:	8082                	ret
     6bc:	1834328b          	th.extu	t0,s0,6,3
     6c0:	ec26                	sd	s1,24(sp)
     6c2:	84ae                	mv	s1,a1
     6c4:	0042959b          	slliw	a1,t0,0x4
     6c8:	e44e                	sd	s3,8(sp)
     6ca:	e84a                	sd	s2,16(sp)
     6cc:	005586b3          	add	a3,a1,t0
     6d0:	00747713          	andi	a4,s0,7
     6d4:	892a                	mv	s2,a0
     6d6:	85b6                	mv	a1,a3
     6d8:	cf31                	beqz	a4,734 <calc_func+0x94>
     6da:	4505                	li	a0,1
     6dc:	04a71863          	bne	a4,a0,72c <calc_func+0x8c>
     6e0:	0604d603          	lhu	a2,96(s1)
     6e4:	04048513          	addi	a0,s1,64
     6e8:	2a8020ef          	jal	2990 <core_bench_matrix>
     6ec:	0644d803          	lhu	a6,100(s1)
     6f0:	3c05298b          	th.ext	s3,a0,15,0
     6f4:	00081463          	bnez	a6,6fc <calc_func+0x5c>
     6f8:	06a49223          	sh	a0,100(s1)
     6fc:	0604d583          	lhu	a1,96(s1)
     700:	3e1030ef          	jal	42e0 <crcu16>
     704:	06a49023          	sh	a0,96(s1)
     708:	f0047893          	andi	a7,s0,-256
     70c:	07f9f513          	andi	a0,s3,127
     710:	fc11440b          	th.ldd	s0,ra,(sp),2,4
     714:	01156e33          	or	t3,a0,a7
     718:	080e6e93          	ori	t4,t3,128
     71c:	01d91023          	sh	t4,0(s2)
     720:	64e2                	ld	s1,24(sp)
     722:	69a2                	ld	s3,8(sp)
     724:	6942                	ld	s2,16(sp)
     726:	6145                	addi	sp,sp,48
     728:	8082                	ret
     72a:	0001                	nop
     72c:	3c04350b          	th.extu	a0,s0,15,0
     730:	89a2                	mv	s3,s0
     732:	b7e9                	j	6fc <calc_func+0x5c>
     734:	02100313          	li	t1,33
     738:	00d333b3          	sltu	t2,t1,a3
     73c:	02200713          	li	a4,34
     740:	00049603          	lh	a2,0(s1)
     744:	4276970b          	th.mvnez	a4,a3,t2
     748:	0604d783          	lhu	a5,96(s1)
     74c:	00249683          	lh	a3,2(s1)
     750:	5488                	lw	a0,40(s1)
     752:	708c                	ld	a1,32(s1)
     754:	51d020ef          	jal	3470 <core_bench_state>
     758:	0664d603          	lhu	a2,102(s1)
     75c:	3c05298b          	th.ext	s3,a0,15,0
     760:	fe51                	bnez	a2,6fc <calc_func+0x5c>
     762:	06a49323          	sh	a0,102(s1)
     766:	bf59                	j	6fc <calc_func+0x5c>
     768:	00000013          	nop
     76c:	00000013          	nop

0000000000000770 <cmp_complex>:
     770:	7179                	addi	sp,sp,-48
     772:	fa91590b          	th.sdd	s2,s1,(sp),1,4
     776:	00051483          	lh	s1,0(a0)
     77a:	fc11540b          	th.sdd	s0,ra,(sp),2,4
     77e:	e052                	sd	s4,0(sp)
     780:	1c74b78b          	th.extu	a5,s1,7,7
     784:	892e                	mv	s2,a1
     786:	8432                	mv	s0,a2
     788:	07f4fa13          	andi	s4,s1,127
     78c:	e3bd                	bnez	a5,7f2 <cmp_complex+0x82>
     78e:	1834b28b          	th.extu	t0,s1,6,3
     792:	0042959b          	slliw	a1,t0,0x4
     796:	005586b3          	add	a3,a1,t0
     79a:	e44e                	sd	s3,8(sp)
     79c:	0074f713          	andi	a4,s1,7
     7a0:	85b6                	mv	a1,a3
     7a2:	89aa                	mv	s3,a0
     7a4:	10070a63          	beqz	a4,8b8 <cmp_complex+0x148>
     7a8:	4505                	li	a0,1
     7aa:	0ca71563          	bne	a4,a0,874 <cmp_complex+0x104>
     7ae:	06065603          	lhu	a2,96(a2)
     7b2:	04040513          	addi	a0,s0,64
     7b6:	1da020ef          	jal	2990 <core_bench_matrix>
     7ba:	06445803          	lhu	a6,100(s0)
     7be:	3c052a0b          	th.ext	s4,a0,15,0
     7c2:	00081763          	bnez	a6,7d0 <cmp_complex+0x60>
     7c6:	06a41223          	sh	a0,100(s0)
     7ca:	0001                	nop
     7cc:	00000013          	nop
     7d0:	06045583          	lhu	a1,96(s0)
     7d4:	07fa7a13          	andi	s4,s4,127
     7d8:	309030ef          	jal	42e0 <crcu16>
     7dc:	f004f893          	andi	a7,s1,-256
     7e0:	011a6e33          	or	t3,s4,a7
     7e4:	06a41023          	sh	a0,96(s0)
     7e8:	080e6e93          	ori	t4,t3,128
     7ec:	01d99023          	sh	t4,0(s3)
     7f0:	69a2                	ld	s3,8(sp)
     7f2:	00091483          	lh	s1,0(s2)
     7f6:	1c74bf0b          	th.extu	t5,s1,7,7
     7fa:	07f4f513          	andi	a0,s1,127
     7fe:	060f1263          	bnez	t5,862 <cmp_complex+0xf2>
     802:	1834b78b          	th.extu	a5,s1,6,3
     806:	0047929b          	slliw	t0,a5,0x4
     80a:	00f286b3          	add	a3,t0,a5
     80e:	0074ff93          	andi	t6,s1,7
     812:	e44e                	sd	s3,8(sp)
     814:	85b6                	mv	a1,a3
     816:	060f8763          	beqz	t6,884 <cmp_complex+0x114>
     81a:	4385                	li	t2,1
     81c:	067f9063          	bne	t6,t2,87c <cmp_complex+0x10c>
     820:	06045603          	lhu	a2,96(s0)
     824:	04040513          	addi	a0,s0,64
     828:	168020ef          	jal	2990 <core_bench_matrix>
     82c:	06445603          	lhu	a2,100(s0)
     830:	3c05298b          	th.ext	s3,a0,15,0
     834:	e611                	bnez	a2,840 <cmp_complex+0xd0>
     836:	06a41223          	sh	a0,100(s0)
     83a:	0001                	nop
     83c:	00000013          	nop
     840:	06045583          	lhu	a1,96(s0)
     844:	29d030ef          	jal	42e0 <crcu16>
     848:	06a41023          	sh	a0,96(s0)
     84c:	07f9f513          	andi	a0,s3,127
     850:	f004f413          	andi	s0,s1,-256
     854:	00856833          	or	a6,a0,s0
     858:	69a2                	ld	s3,8(sp)
     85a:	08086893          	ori	a7,a6,128
     85e:	01191023          	sh	a7,0(s2)
     862:	fc11440b          	th.ldd	s0,ra,(sp),2,4
     866:	fa91490b          	th.ldd	s2,s1,(sp),1,4
     86a:	40aa053b          	subw	a0,s4,a0
     86e:	6a02                	ld	s4,0(sp)
     870:	6145                	addi	sp,sp,48
     872:	8082                	ret
     874:	3c04b50b          	th.extu	a0,s1,15,0
     878:	8a26                	mv	s4,s1
     87a:	bf99                	j	7d0 <cmp_complex+0x60>
     87c:	3c04b50b          	th.extu	a0,s1,15,0
     880:	89a6                	mv	s3,s1
     882:	bf7d                	j	840 <cmp_complex+0xd0>
     884:	02100993          	li	s3,33
     888:	00d9b333          	sltu	t1,s3,a3
     88c:	02200713          	li	a4,34
     890:	700c                	ld	a1,32(s0)
     892:	4266970b          	th.mvnez	a4,a3,t1
     896:	06045783          	lhu	a5,96(s0)
     89a:	00241683          	lh	a3,2(s0)
     89e:	00041603          	lh	a2,0(s0)
     8a2:	5408                	lw	a0,40(s0)
     8a4:	3cd020ef          	jal	3470 <core_bench_state>
     8a8:	06645583          	lhu	a1,102(s0)
     8ac:	3c05298b          	th.ext	s3,a0,15,0
     8b0:	f9c1                	bnez	a1,840 <cmp_complex+0xd0>
     8b2:	06a41323          	sh	a0,102(s0)
     8b6:	b769                	j	840 <cmp_complex+0xd0>
     8b8:	02100313          	li	t1,33
     8bc:	00d333b3          	sltu	t2,t1,a3
     8c0:	02200713          	li	a4,34
     8c4:	06065783          	lhu	a5,96(a2)
     8c8:	4276970b          	th.mvnez	a4,a3,t2
     8cc:	5408                	lw	a0,40(s0)
     8ce:	00261683          	lh	a3,2(a2)
     8d2:	700c                	ld	a1,32(s0)
     8d4:	00061603          	lh	a2,0(a2)
     8d8:	399020ef          	jal	3470 <core_bench_state>
     8dc:	06645603          	lhu	a2,102(s0)
     8e0:	3c052a0b          	th.ext	s4,a0,15,0
     8e4:	ee0616e3          	bnez	a2,7d0 <cmp_complex+0x60>
     8e8:	06a41323          	sh	a0,102(s0)
     8ec:	b5d5                	j	7d0 <cmp_complex+0x60>
     8ee:	0001                	nop

00000000000008f0 <cmp_idx>:
     8f0:	ca01                	beqz	a2,900 <cmp_idx+0x10>
     8f2:	00251503          	lh	a0,2(a0)
     8f6:	00259583          	lh	a1,2(a1)
     8fa:	9d0d                	subw	a0,a0,a1
     8fc:	8082                	ret
     8fe:	0001                	nop
     900:	00051783          	lh	a5,0(a0)
     904:	f007f713          	andi	a4,a5,-256
     908:	3c87b28b          	th.extu	t0,a5,15,8
     90c:	00576333          	or	t1,a4,t0
     910:	00651023          	sh	t1,0(a0)
     914:	00059383          	lh	t2,0(a1)
     918:	00251503          	lh	a0,2(a0)
     91c:	f003f613          	andi	a2,t2,-256
     920:	3c83b68b          	th.extu	a3,t2,15,8
     924:	00d66833          	or	a6,a2,a3
     928:	01059023          	sh	a6,0(a1)
     92c:	00259583          	lh	a1,2(a1)
     930:	9d0d                	subw	a0,a0,a1
     932:	8082                	ret
     934:	00000013          	nop
     938:	00000013          	nop
     93c:	00000013          	nop

0000000000000940 <copy_info>:
     940:	00059783          	lh	a5,0(a1)
     944:	00259283          	lh	t0,2(a1)
     948:	00f51023          	sh	a5,0(a0)
     94c:	00551123          	sh	t0,2(a0)
     950:	8082                	ret
     952:	0001                	nop
     954:	00000013          	nop
     958:	00000013          	nop
     95c:	00000013          	nop

0000000000000960 <core_bench_list>:
     960:	00451f83          	lh	t6,4(a0)
     964:	7135                	addi	sp,sp,-160
     966:	e4e6                	sd	s9,72(sp)
     968:	e8e2                	sd	s8,80(sp)
     96a:	fc6e                	sd	s11,56(sp)
     96c:	e0ea                	sd	s10,64(sp)
     96e:	ecde                	sd	s7,88(sp)
     970:	f0da                	sd	s6,96(sp)
     972:	f4d6                	sd	s5,104(sp)
     974:	f8d2                	sd	s4,112(sp)
     976:	fcce                	sd	s3,120(sp)
     978:	e14a                	sd	s2,128(sp)
     97a:	e526                	sd	s1,136(sp)
     97c:	e922                	sd	s0,144(sp)
     97e:	f002                	sd	zero,32(sp)
     980:	ed06                	sd	ra,152(sp)
     982:	03853a03          	ld	s4,56(a0)
     986:	8e2e                	mv	t3,a1
     988:	8caa                	mv	s9,a0
     98a:	23f054e3          	blez	t6,13b2 <core_bench_list+0xa52>
     98e:	2205c6e3          	bltz	a1,13ba <core_bench_list+0xa5a>
     992:	220a0fe3          	beqz	s4,13d0 <core_bench_list+0xa70>
     996:	4501                	li	a0,0
     998:	4e81                	li	t4,0
     99a:	4301                	li	t1,0
     99c:	4881                	li	a7,0
     99e:	ec2e                	sd	a1,24(sp)
     9a0:	87d2                	mv	a5,s4
     9a2:	a021                	j	9aa <core_bench_list+0x4a>
     9a4:	639c                	ld	a5,0(a5)
     9a6:	10078d63          	beqz	a5,ac0 <core_bench_list+0x160>
     9aa:	6798                	ld	a4,8(a5)
     9ac:	66e2                	ld	a3,24(sp)
     9ae:	00271703          	lh	a4,2(a4)
     9b2:	fed719e3          	bne	a4,a3,9a4 <core_bench_list+0x44>
     9b6:	000a3283          	ld	t0,0(s4)
     9ba:	4981                	li	s3,0
     9bc:	013a3023          	sd	s3,0(s4)
     9c0:	85d2                	mv	a1,s4
     9c2:	06028763          	beqz	t0,a30 <core_bench_list+0xd0>
     9c6:	0002b603          	ld	a2,0(t0)
     9ca:	00b2b023          	sd	a1,0(t0)
     9ce:	8a16                	mv	s4,t0
     9d0:	c225                	beqz	a2,a30 <core_bench_list+0xd0>
     9d2:	00063383          	ld	t2,0(a2)
     9d6:	00563023          	sd	t0,0(a2)
     9da:	8a32                	mv	s4,a2
     9dc:	04038a63          	beqz	t2,a30 <core_bench_list+0xd0>
     9e0:	0003b403          	ld	s0,0(t2)
     9e4:	00c3b023          	sd	a2,0(t2)
     9e8:	8a1e                	mv	s4,t2
     9ea:	c039                	beqz	s0,a30 <core_bench_list+0xd0>
     9ec:	6004                	ld	s1,0(s0)
     9ee:	00743023          	sd	t2,0(s0)
     9f2:	8a22                	mv	s4,s0
     9f4:	cc95                	beqz	s1,a30 <core_bench_list+0xd0>
     9f6:	0004b803          	ld	a6,0(s1)
     9fa:	e080                	sd	s0,0(s1)
     9fc:	8a26                	mv	s4,s1
     9fe:	02080963          	beqz	a6,a30 <core_bench_list+0xd0>
     a02:	00083903          	ld	s2,0(a6)
     a06:	00983023          	sd	s1,0(a6)
     a0a:	8a42                	mv	s4,a6
     a0c:	02090263          	beqz	s2,a30 <core_bench_list+0xd0>
     a10:	00093a83          	ld	s5,0(s2)
     a14:	01093023          	sd	a6,0(s2)
     a18:	8a4a                	mv	s4,s2
     a1a:	89ca                	mv	s3,s2
     a1c:	000a8a63          	beqz	s5,a30 <core_bench_list+0xd0>
     a20:	8a56                	mv	s4,s5
     a22:	000a3283          	ld	t0,0(s4)
     a26:	013a3023          	sd	s3,0(s4)
     a2a:	85d2                	mv	a1,s4
     a2c:	f8029de3          	bnez	t0,9c6 <core_bench_list+0x66>
     a30:	cbd1                	beqz	a5,ac4 <core_bench_list+0x164>
     a32:	0087bb03          	ld	s6,8(a5)
     a36:	6394                	ld	a3,0(a5)
     a38:	000b1b83          	lh	s7,0(s6)
     a3c:	249bbd0b          	th.extu	s10,s7,9,9
     a40:	011d0dbb          	addw	s11,s10,a7
     a44:	001bfc13          	andi	s8,s7,1
     a48:	3c0dbf0b          	th.extu	t5,s11,15,0
     a4c:	438f188b          	th.mvnez	a7,t5,s8
     a50:	ca81                	beqz	a3,a60 <core_bench_list+0x100>
     a52:	628c                	ld	a1,0(a3)
     a54:	e38c                	sd	a1,0(a5)
     a56:	000a3783          	ld	a5,0(s4)
     a5a:	e29c                	sd	a5,0(a3)
     a5c:	00da3023          	sd	a3,0(s4)
     a60:	2305                	addiw	t1,t1,1
     a62:	3c03330b          	th.extu	t1,t1,15,0
     a66:	02074763          	bltz	a4,a94 <core_bench_list+0x134>
     a6a:	2705                	addiw	a4,a4,1
     a6c:	0015091b          	addiw	s2,a0,1
     a70:	3c07280b          	th.ext	a6,a4,15,0
     a74:	3c09250b          	th.ext	a0,s2,15,0
     a78:	ec42                	sd	a6,24(sp)
     a7a:	3c09398b          	th.extu	s3,s2,15,0
     a7e:	06af8663          	beq	t6,a0,aea <core_bench_list+0x18a>
     a82:	0ff9f413          	zext.b	s0,s3
     a86:	f022                	sd	s0,32(sp)
     a88:	f0085ce3          	bgez	a6,9a0 <core_bench_list+0x40>
     a8c:	85a2                	mv	a1,s0
     a8e:	87d2                	mv	a5,s4
     a90:	7761                	lui	a4,0xffff8
     a92:	a839                	j	ab0 <core_bench_list+0x150>
     a94:	2505                	addiw	a0,a0,1
     a96:	3c05348b          	th.extu	s1,a0,15,0
     a9a:	3c05250b          	th.ext	a0,a0,15,0
     a9e:	04af8563          	beq	t6,a0,ae8 <core_bench_list+0x188>
     aa2:	0ff4f593          	zext.b	a1,s1
     aa6:	87d2                	mv	a5,s4
     aa8:	a021                	j	ab0 <core_bench_list+0x150>
     aaa:	0001                	nop
     aac:	639c                	ld	a5,0(a5)
     aae:	cb9d                	beqz	a5,ae4 <core_bench_list+0x184>
     ab0:	0087bb83          	ld	s7,8(a5)
     ab4:	000bc483          	lbu	s1,0(s7)
     ab8:	f026                	sd	s1,32(sp)
     aba:	feb499e3          	bne	s1,a1,aac <core_bench_list+0x14c>
     abe:	bde5                	j	9b6 <core_bench_list+0x56>
     ac0:	8736                	mv	a4,a3
     ac2:	bdd5                	j	9b6 <core_bench_list+0x56>
     ac4:	000a3283          	ld	t0,0(s4)
     ac8:	2e85                	addiw	t4,t4,1
     aca:	3c0ebe8b          	th.extu	t4,t4,15,0
     ace:	0082b603          	ld	a2,8(t0)
     ad2:	00061383          	lh	t2,0(a2)
     ad6:	2083b40b          	th.extu	s0,t2,8,8
     ada:	011408bb          	addw	a7,s0,a7
     ade:	3c08b88b          	th.extu	a7,a7,15,0
     ae2:	b751                	j	a66 <core_bench_list+0x106>
     ae4:	f02e                	sd	a1,32(sp)
     ae6:	bdc1                	j	9b6 <core_bench_list+0x56>
     ae8:	ec3a                	sd	a4,24(sp)
     aea:	00231f9b          	slliw	t6,t1,0x2
     aee:	41df8abb          	subw	s5,t6,t4
     af2:	011a8b3b          	addw	s6,s5,a7
     af6:	3c0b3b8b          	th.extu	s7,s6,15,0
     afa:	f45e                	sd	s7,40(sp)
     afc:	4dc04b63          	bgtz	t3,fd2 <core_bench_list+0x672>
     b00:	000a3983          	ld	s3,0(s4)
     b04:	6be2                	ld	s7,24(sp)
     b06:	8452                	mv	s0,s4
     b08:	f859c48b          	th.ldd	s1,t0,(s3),0,4
     b0c:	0084bd03          	ld	s10,8(s1)
     b10:	0004bc83          	ld	s9,0(s1)
     b14:	01a9b423          	sd	s10,8(s3)
     b18:	0054b423          	sd	t0,8(s1)
     b1c:	0199b023          	sd	s9,0(s3)
     b20:	0004b023          	sd	zero,0(s1)
     b24:	320bcd63          	bltz	s7,e5e <core_bench_list+0x4fe>
     b28:	6410                	ld	a2,8(s0)
     b2a:	63e2                	ld	t2,24(sp)
     b2c:	00261883          	lh	a7,2(a2)
     b30:	00788b63          	beq	a7,t2,b46 <core_bench_list+0x1e6>
     b34:	6000                	ld	s0,0(s0)
     b36:	48040963          	beqz	s0,fc8 <core_bench_list+0x668>
     b3a:	6410                	ld	a2,8(s0)
     b3c:	63e2                	ld	t2,24(sp)
     b3e:	00261883          	lh	a7,2(a2)
     b42:	fe7899e3          	bne	a7,t2,b34 <core_bench_list+0x1d4>
     b46:	008a3703          	ld	a4,8(s4)
     b4a:	75a2                	ld	a1,40(sp)
     b4c:	00071503          	lh	a0,0(a4) # ffffffffffff8000 <__kernel_stack+0xfffffffffff0a000>
     b50:	4a1030ef          	jal	47f0 <crc16>
     b54:	6000                	ld	s0,0(s0)
     b56:	f42a                	sd	a0,40(sp)
     b58:	c445                	beqz	s0,c00 <core_bench_list+0x2a0>
     b5a:	008a3803          	ld	a6,8(s4)
     b5e:	85aa                	mv	a1,a0
     b60:	00081503          	lh	a0,0(a6)
     b64:	48d030ef          	jal	47f0 <crc16>
     b68:	00043c03          	ld	s8,0(s0)
     b6c:	f42a                	sd	a0,40(sp)
     b6e:	85aa                	mv	a1,a0
     b70:	080c0863          	beqz	s8,c00 <core_bench_list+0x2a0>
     b74:	008a3f83          	ld	t6,8(s4)
     b78:	000f9503          	lh	a0,0(t6)
     b7c:	475030ef          	jal	47f0 <crc16>
     b80:	000c3b03          	ld	s6,0(s8)
     b84:	f42a                	sd	a0,40(sp)
     b86:	85aa                	mv	a1,a0
     b88:	060b0c63          	beqz	s6,c00 <core_bench_list+0x2a0>
     b8c:	008a3503          	ld	a0,8(s4)
     b90:	00051503          	lh	a0,0(a0)
     b94:	45d030ef          	jal	47f0 <crc16>
     b98:	000b3d83          	ld	s11,0(s6)
     b9c:	f42a                	sd	a0,40(sp)
     b9e:	85aa                	mv	a1,a0
     ba0:	060d8063          	beqz	s11,c00 <core_bench_list+0x2a0>
     ba4:	008a3e03          	ld	t3,8(s4)
     ba8:	000e1503          	lh	a0,0(t3)
     bac:	445030ef          	jal	47f0 <crc16>
     bb0:	000db903          	ld	s2,0(s11)
     bb4:	f42a                	sd	a0,40(sp)
     bb6:	85aa                	mv	a1,a0
     bb8:	04090463          	beqz	s2,c00 <core_bench_list+0x2a0>
     bbc:	008a3f03          	ld	t5,8(s4)
     bc0:	000f1503          	lh	a0,0(t5)
     bc4:	42d030ef          	jal	47f0 <crc16>
     bc8:	00093983          	ld	s3,0(s2)
     bcc:	f42a                	sd	a0,40(sp)
     bce:	85aa                	mv	a1,a0
     bd0:	02098863          	beqz	s3,c00 <core_bench_list+0x2a0>
     bd4:	008a3683          	ld	a3,8(s4)
     bd8:	00069503          	lh	a0,0(a3)
     bdc:	415030ef          	jal	47f0 <crc16>
     be0:	0009bd03          	ld	s10,0(s3)
     be4:	f42a                	sd	a0,40(sp)
     be6:	85aa                	mv	a1,a0
     be8:	000d0c63          	beqz	s10,c00 <core_bench_list+0x2a0>
     bec:	008a3783          	ld	a5,8(s4)
     bf0:	00079503          	lh	a0,0(a5)
     bf4:	3fd030ef          	jal	47f0 <crc16>
     bf8:	000d3403          	ld	s0,0(s10)
     bfc:	f42a                	sd	a0,40(sp)
     bfe:	f421                	bnez	s0,b46 <core_bench_list+0x1e6>
     c00:	0084b283          	ld	t0,8(s1)
     c04:	000a3403          	ld	s0,0(s4)
     c08:	640c                	ld	a1,8(s0)
     c0a:	00043c83          	ld	s9,0(s0)
     c0e:	4e05                	li	t3,1
     c10:	e48c                	sd	a1,8(s1)
     c12:	00543423          	sd	t0,8(s0)
     c16:	0194b023          	sd	s9,0(s1)
     c1a:	e004                	sd	s1,0(s0)
     c1c:	8f72                	mv	t5,t3
     c1e:	220a0a63          	beqz	s4,e52 <core_bench_list+0x4f2>
     c22:	4401                	li	s0,0
     c24:	4a81                	li	s5,0
     c26:	4e81                	li	t4,0
     c28:	2e85                	addiw	t4,t4,1
     c2a:	8bd2                	mv	s7,s4
     c2c:	4781                	li	a5,0
     c2e:	0001                	nop
     c30:	01c7d763          	bge	a5,t3,c3e <core_bench_list+0x2de>
     c34:	000bbb83          	ld	s7,0(s7)
     c38:	2785                	addiw	a5,a5,1
     c3a:	fe0b9be3          	bnez	s7,c30 <core_bench_list+0x2d0>
     c3e:	86d6                	mv	a3,s5
     c40:	85f2                	mv	a1,t3
     c42:	8ad2                	mv	s5,s4
     c44:	8a5e                	mv	s4,s7
     c46:	06f05263          	blez	a5,caa <core_bench_list+0x34a>
     c4a:	0001                	nop
     c4c:	00000013          	nop
     c50:	22058063          	beqz	a1,e70 <core_bench_list+0x510>
     c54:	240a0063          	beqz	s4,e94 <core_bench_list+0x534>
     c58:	008abb03          	ld	s6,8(s5)
     c5c:	008a3d03          	ld	s10,8(s4)
     c60:	000b1503          	lh	a0,0(s6)
     c64:	002b1283          	lh	t0,2(s6)
     c68:	002d1383          	lh	t2,2(s10)
     c6c:	f0057d93          	andi	s11,a0,-256
     c70:	3c85390b          	th.extu	s2,a0,15,8
     c74:	012de9b3          	or	s3,s11,s2
     c78:	013b1023          	sh	s3,0(s6)
     c7c:	000d1c83          	lh	s9,0(s10)
     c80:	f00cfb93          	andi	s7,s9,-256
     c84:	3c8cb30b          	th.extu	t1,s9,15,8
     c88:	006be4b3          	or	s1,s7,t1
     c8c:	009d1023          	sh	s1,0(s10)
     c90:	2053d263          	bge	t2,t0,e94 <core_bench_list+0x534>
     c94:	88d2                	mv	a7,s4
     c96:	35fd                	addiw	a1,a1,-1
     c98:	000a3a03          	ld	s4,0(s4)
     c9c:	20068263          	beqz	a3,ea0 <core_bench_list+0x540>
     ca0:	0116b023          	sd	a7,0(a3)
     ca4:	86c6                	mv	a3,a7
     ca6:	faf045e3          	bgtz	a5,c50 <core_bench_list+0x2f0>
     caa:	30b05963          	blez	a1,fbc <core_bench_list+0x65c>
     cae:	180a0963          	beqz	s4,e40 <core_bench_list+0x4e0>
     cb2:	f3dd                	bnez	a5,c58 <core_bench_list+0x2f8>
     cb4:	fff5831b          	addiw	t1,a1,-1
     cb8:	00737493          	andi	s1,t1,7
     cbc:	c0e9                	beqz	s1,d7e <core_bench_list+0x41e>
     cbe:	000a3383          	ld	t2,0(s4)
     cc2:	35fd                	addiw	a1,a1,-1
     cc4:	1e068f63          	beqz	a3,ec2 <core_bench_list+0x562>
     cc8:	0146b023          	sd	s4,0(a3)
     ccc:	86d2                	mv	a3,s4
     cce:	16038963          	beqz	t2,e40 <core_bench_list+0x4e0>
     cd2:	4605                	li	a2,1
     cd4:	8a1e                	mv	s4,t2
     cd6:	0004889b          	sext.w	a7,s1
     cda:	0ac48263          	beq	s1,a2,d7e <core_bench_list+0x41e>
     cde:	4709                	li	a4,2
     ce0:	08e88463          	beq	a7,a4,d68 <core_bench_list+0x408>
     ce4:	480d                	li	a6,3
     ce6:	07088663          	beq	a7,a6,d52 <core_bench_list+0x3f2>
     cea:	4c11                	li	s8,4
     cec:	05888863          	beq	a7,s8,d3c <core_bench_list+0x3dc>
     cf0:	4f95                	li	t6,5
     cf2:	03f88a63          	beq	a7,t6,d26 <core_bench_list+0x3c6>
     cf6:	4b19                	li	s6,6
     cf8:	01688c63          	beq	a7,s6,d10 <core_bench_list+0x3b0>
     cfc:	0003ba03          	ld	s4,0(t2)
     d00:	35fd                	addiw	a1,a1,-1
     d02:	2c068163          	beqz	a3,fc4 <core_bench_list+0x664>
     d06:	0076b023          	sd	t2,0(a3)
     d0a:	869e                	mv	a3,t2
     d0c:	120a0a63          	beqz	s4,e40 <core_bench_list+0x4e0>
     d10:	000a3503          	ld	a0,0(s4)
     d14:	35fd                	addiw	a1,a1,-1
     d16:	1c068063          	beqz	a3,ed6 <core_bench_list+0x576>
     d1a:	0146b023          	sd	s4,0(a3)
     d1e:	86d2                	mv	a3,s4
     d20:	12050063          	beqz	a0,e40 <core_bench_list+0x4e0>
     d24:	8a2a                	mv	s4,a0
     d26:	000a3d83          	ld	s11,0(s4)
     d2a:	35fd                	addiw	a1,a1,-1
     d2c:	1a068363          	beqz	a3,ed2 <core_bench_list+0x572>
     d30:	0146b023          	sd	s4,0(a3)
     d34:	86d2                	mv	a3,s4
     d36:	100d8563          	beqz	s11,e40 <core_bench_list+0x4e0>
     d3a:	8a6e                	mv	s4,s11
     d3c:	000a3903          	ld	s2,0(s4)
     d40:	35fd                	addiw	a1,a1,-1
     d42:	18068663          	beqz	a3,ece <core_bench_list+0x56e>
     d46:	0146b023          	sd	s4,0(a3)
     d4a:	86d2                	mv	a3,s4
     d4c:	0e090a63          	beqz	s2,e40 <core_bench_list+0x4e0>
     d50:	8a4a                	mv	s4,s2
     d52:	000a3983          	ld	s3,0(s4)
     d56:	35fd                	addiw	a1,a1,-1
     d58:	16068963          	beqz	a3,eca <core_bench_list+0x56a>
     d5c:	0146b023          	sd	s4,0(a3)
     d60:	86d2                	mv	a3,s4
     d62:	0c098f63          	beqz	s3,e40 <core_bench_list+0x4e0>
     d66:	8a4e                	mv	s4,s3
     d68:	000a3d03          	ld	s10,0(s4)
     d6c:	35fd                	addiw	a1,a1,-1
     d6e:	14068c63          	beqz	a3,ec6 <core_bench_list+0x566>
     d72:	0146b023          	sd	s4,0(a3)
     d76:	86d2                	mv	a3,s4
     d78:	0c0d0463          	beqz	s10,e40 <core_bench_list+0x4e0>
     d7c:	8a6a                	mv	s4,s10
     d7e:	000a3783          	ld	a5,0(s4)
     d82:	35fd                	addiw	a1,a1,-1
     d84:	c6d5                	beqz	a3,e30 <core_bench_list+0x4d0>
     d86:	0146b023          	sd	s4,0(a3)
     d8a:	c5cd                	beqz	a1,e34 <core_bench_list+0x4d4>
     d8c:	86d2                	mv	a3,s4
     d8e:	cbcd                	beqz	a5,e40 <core_bench_list+0x4e0>
     d90:	0007bb83          	ld	s7,0(a5)
     d94:	fff58c9b          	addiw	s9,a1,-1
     d98:	100a0763          	beqz	s4,ea6 <core_bench_list+0x546>
     d9c:	00fa3023          	sd	a5,0(s4)
     da0:	86be                	mv	a3,a5
     da2:	080b8f63          	beqz	s7,e40 <core_bench_list+0x4e0>
     da6:	000bb303          	ld	t1,0(s7)
     daa:	fffc8a9b          	addiw	s5,s9,-1
     dae:	0e078e63          	beqz	a5,eaa <core_bench_list+0x54a>
     db2:	0177b023          	sd	s7,0(a5)
     db6:	86de                	mv	a3,s7
     db8:	08030463          	beqz	t1,e40 <core_bench_list+0x4e0>
     dbc:	00033283          	ld	t0,0(t1)
     dc0:	fffa849b          	addiw	s1,s5,-1
     dc4:	0e0b8563          	beqz	s7,eae <core_bench_list+0x54e>
     dc8:	006bb023          	sd	t1,0(s7)
     dcc:	869a                	mv	a3,t1
     dce:	06028963          	beqz	t0,e40 <core_bench_list+0x4e0>
     dd2:	0002b883          	ld	a7,0(t0)
     dd6:	fff4839b          	addiw	t2,s1,-1
     dda:	0c030c63          	beqz	t1,eb2 <core_bench_list+0x552>
     dde:	00533023          	sd	t0,0(t1)
     de2:	8696                	mv	a3,t0
     de4:	04088e63          	beqz	a7,e40 <core_bench_list+0x4e0>
     de8:	0008b603          	ld	a2,0(a7)
     dec:	fff3871b          	addiw	a4,t2,-1
     df0:	0c028363          	beqz	t0,eb6 <core_bench_list+0x556>
     df4:	0112b023          	sd	a7,0(t0)
     df8:	86c6                	mv	a3,a7
     dfa:	c239                	beqz	a2,e40 <core_bench_list+0x4e0>
     dfc:	00063c03          	ld	s8,0(a2)
     e00:	fff7081b          	addiw	a6,a4,-1
     e04:	0a088b63          	beqz	a7,eba <core_bench_list+0x55a>
     e08:	00c8b023          	sd	a2,0(a7)
     e0c:	86b2                	mv	a3,a2
     e0e:	020c0963          	beqz	s8,e40 <core_bench_list+0x4e0>
     e12:	000c3f83          	ld	t6,0(s8)
     e16:	fff8059b          	addiw	a1,a6,-1
     e1a:	c255                	beqz	a2,ebe <core_bench_list+0x55e>
     e1c:	01863023          	sd	s8,0(a2)
     e20:	86e2                	mv	a3,s8
     e22:	000f8f63          	beqz	t6,e40 <core_bench_list+0x4e0>
     e26:	8a7e                	mv	s4,t6
     e28:	000a3783          	ld	a5,0(s4)
     e2c:	35fd                	addiw	a1,a1,-1
     e2e:	fea1                	bnez	a3,d86 <core_bench_list+0x426>
     e30:	8452                	mv	s0,s4
     e32:	fda9                	bnez	a1,d8c <core_bench_list+0x42c>
     e34:	8ad2                	mv	s5,s4
     e36:	8a3e                	mv	s4,a5
     e38:	de0a18e3          	bnez	s4,c28 <core_bench_list+0x2c8>
     e3c:	86d6                	mv	a3,s5
     e3e:	0001                	nop
     e40:	0006b023          	sd	zero,0(a3)
     e44:	09ee8b63          	beq	t4,t5,eda <core_bench_list+0x57a>
     e48:	8a22                	mv	s4,s0
     e4a:	001e1e1b          	slliw	t3,t3,0x1
     e4e:	dc0a1ae3          	bnez	s4,c22 <core_bench_list+0x2c2>
     e52:	00003023          	sd	zero,0(zero) # 0 <__start>
     e56:	9002                	ebreak
     e58:	6000                	ld	s0,0(s0)
     e5a:	16040763          	beqz	s0,fc8 <core_bench_list+0x668>
     e5e:	00843e83          	ld	t4,8(s0)
     e62:	7302                	ld	t1,32(sp)
     e64:	000eca83          	lbu	s5,0(t4)
     e68:	ff5318e3          	bne	t1,s5,e58 <core_bench_list+0x4f8>
     e6c:	b9e9                	j	b46 <core_bench_list+0x1e6>
     e6e:	0001                	nop
     e70:	000ab703          	ld	a4,0(s5)
     e74:	37fd                	addiw	a5,a5,-1
     e76:	ca91                	beqz	a3,e8a <core_bench_list+0x52a>
     e78:	0156b023          	sd	s5,0(a3)
     e7c:	dfd5                	beqz	a5,e38 <core_bench_list+0x4d8>
     e7e:	86d6                	mv	a3,s5
     e80:	8aba                	mv	s5,a4
     e82:	000ab703          	ld	a4,0(s5)
     e86:	37fd                	addiw	a5,a5,-1
     e88:	fae5                	bnez	a3,e78 <core_bench_list+0x518>
     e8a:	8456                	mv	s0,s5
     e8c:	fbed                	bnez	a5,e7e <core_bench_list+0x51e>
     e8e:	d80a1de3          	bnez	s4,c28 <core_bench_list+0x2c8>
     e92:	b76d                	j	e3c <core_bench_list+0x4dc>
     e94:	88d6                	mv	a7,s5
     e96:	37fd                	addiw	a5,a5,-1
     e98:	000aba83          	ld	s5,0(s5)
     e9c:	e00692e3          	bnez	a3,ca0 <core_bench_list+0x340>
     ea0:	8446                	mv	s0,a7
     ea2:	86c6                	mv	a3,a7
     ea4:	b509                	j	ca6 <core_bench_list+0x346>
     ea6:	843e                	mv	s0,a5
     ea8:	bde5                	j	da0 <core_bench_list+0x440>
     eaa:	845e                	mv	s0,s7
     eac:	b729                	j	db6 <core_bench_list+0x456>
     eae:	841a                	mv	s0,t1
     eb0:	bf31                	j	dcc <core_bench_list+0x46c>
     eb2:	8416                	mv	s0,t0
     eb4:	b73d                	j	de2 <core_bench_list+0x482>
     eb6:	8446                	mv	s0,a7
     eb8:	b781                	j	df8 <core_bench_list+0x498>
     eba:	8432                	mv	s0,a2
     ebc:	bf81                	j	e0c <core_bench_list+0x4ac>
     ebe:	8462                	mv	s0,s8
     ec0:	b785                	j	e20 <core_bench_list+0x4c0>
     ec2:	8452                	mv	s0,s4
     ec4:	b521                	j	ccc <core_bench_list+0x36c>
     ec6:	8452                	mv	s0,s4
     ec8:	b57d                	j	d76 <core_bench_list+0x416>
     eca:	8452                	mv	s0,s4
     ecc:	bd51                	j	d60 <core_bench_list+0x400>
     ece:	8452                	mv	s0,s4
     ed0:	bdad                	j	d4a <core_bench_list+0x3ea>
     ed2:	8452                	mv	s0,s4
     ed4:	b585                	j	d34 <core_bench_list+0x3d4>
     ed6:	8452                	mv	s0,s4
     ed8:	b599                	j	d1e <core_bench_list+0x3be>
     eda:	00043c83          	ld	s9,0(s0)
     ede:	0a0c8f63          	beqz	s9,f9c <core_bench_list+0x63c>
     ee2:	00843a03          	ld	s4,8(s0)
     ee6:	75a2                	ld	a1,40(sp)
     ee8:	000a1503          	lh	a0,0(s4)
     eec:	105030ef          	jal	47f0 <crc16>
     ef0:	000cba83          	ld	s5,0(s9)
     ef4:	f42a                	sd	a0,40(sp)
     ef6:	0a0a8363          	beqz	s5,f9c <core_bench_list+0x63c>
     efa:	6410                	ld	a2,8(s0)
     efc:	85aa                	mv	a1,a0
     efe:	00061503          	lh	a0,0(a2)
     f02:	0ef030ef          	jal	47f0 <crc16>
     f06:	000abc03          	ld	s8,0(s5)
     f0a:	f42a                	sd	a0,40(sp)
     f0c:	85aa                	mv	a1,a0
     f0e:	080c0763          	beqz	s8,f9c <core_bench_list+0x63c>
     f12:	00843803          	ld	a6,8(s0)
     f16:	00081503          	lh	a0,0(a6)
     f1a:	0d7030ef          	jal	47f0 <crc16>
     f1e:	000c3b03          	ld	s6,0(s8)
     f22:	f42a                	sd	a0,40(sp)
     f24:	85aa                	mv	a1,a0
     f26:	060b0b63          	beqz	s6,f9c <core_bench_list+0x63c>
     f2a:	00843f83          	ld	t6,8(s0)
     f2e:	000f9503          	lh	a0,0(t6)
     f32:	0bf030ef          	jal	47f0 <crc16>
     f36:	000b3d83          	ld	s11,0(s6)
     f3a:	f42a                	sd	a0,40(sp)
     f3c:	85aa                	mv	a1,a0
     f3e:	040d8f63          	beqz	s11,f9c <core_bench_list+0x63c>
     f42:	6414                	ld	a3,8(s0)
     f44:	00069503          	lh	a0,0(a3)
     f48:	0a9030ef          	jal	47f0 <crc16>
     f4c:	000db903          	ld	s2,0(s11)
     f50:	f42a                	sd	a0,40(sp)
     f52:	85aa                	mv	a1,a0
     f54:	04090463          	beqz	s2,f9c <core_bench_list+0x63c>
     f58:	00843e83          	ld	t4,8(s0)
     f5c:	000e9503          	lh	a0,0(t4)
     f60:	091030ef          	jal	47f0 <crc16>
     f64:	00093983          	ld	s3,0(s2)
     f68:	f42a                	sd	a0,40(sp)
     f6a:	85aa                	mv	a1,a0
     f6c:	02098863          	beqz	s3,f9c <core_bench_list+0x63c>
     f70:	00843f03          	ld	t5,8(s0)
     f74:	000f1503          	lh	a0,0(t5)
     f78:	079030ef          	jal	47f0 <crc16>
     f7c:	0009bd03          	ld	s10,0(s3)
     f80:	f42a                	sd	a0,40(sp)
     f82:	85aa                	mv	a1,a0
     f84:	000d0c63          	beqz	s10,f9c <core_bench_list+0x63c>
     f88:	6408                	ld	a0,8(s0)
     f8a:	00051503          	lh	a0,0(a0)
     f8e:	063030ef          	jal	47f0 <crc16>
     f92:	000d3c83          	ld	s9,0(s10)
     f96:	f42a                	sd	a0,40(sp)
     f98:	f40c95e3          	bnez	s9,ee2 <core_bench_list+0x582>
     f9c:	64aa                	ld	s1,136(sp)
     f9e:	644a                	ld	s0,144(sp)
     fa0:	60ea                	ld	ra,152(sp)
     fa2:	7522                	ld	a0,40(sp)
     fa4:	7de2                	ld	s11,56(sp)
     fa6:	6d06                	ld	s10,64(sp)
     fa8:	6ca6                	ld	s9,72(sp)
     faa:	6c46                	ld	s8,80(sp)
     fac:	6be6                	ld	s7,88(sp)
     fae:	7b06                	ld	s6,96(sp)
     fb0:	7aa6                	ld	s5,104(sp)
     fb2:	7a46                	ld	s4,112(sp)
     fb4:	79e6                	ld	s3,120(sp)
     fb6:	690a                	ld	s2,128(sp)
     fb8:	610d                	addi	sp,sp,160
     fba:	8082                	ret
     fbc:	8ab6                	mv	s5,a3
     fbe:	c60a15e3          	bnez	s4,c28 <core_bench_list+0x2c8>
     fc2:	bdad                	j	e3c <core_bench_list+0x4dc>
     fc4:	841e                	mv	s0,t2
     fc6:	b391                	j	d0a <core_bench_list+0x3aa>
     fc8:	000a3403          	ld	s0,0(s4)
     fcc:	b6041de3          	bnez	s0,b46 <core_bench_list+0x1e6>
     fd0:	b925                	j	c08 <core_bench_list+0x2a8>
     fd2:	4905                	li	s2,1
     fd4:	e60a0fe3          	beqz	s4,e52 <core_bench_list+0x4f2>
     fd8:	4981                	li	s3,0
     fda:	4d81                	li	s11,0
     fdc:	e802                	sd	zero,16(sp)
     fde:	0001                	nop
     fe0:	6e42                	ld	t3,16(sp)
     fe2:	4c01                	li	s8,0
     fe4:	8f52                	mv	t5,s4
     fe6:	001e0d1b          	addiw	s10,t3,1
     fea:	e86a                	sd	s10,16(sp)
     fec:	00000013          	nop
     ff0:	012c5763          	bge	s8,s2,ffe <core_bench_list+0x69e>
     ff4:	000f3f03          	ld	t5,0(t5)
     ff8:	2c05                	addiw	s8,s8,1
     ffa:	fe0f1be3          	bnez	t5,ff0 <core_bench_list+0x690>
     ffe:	040c8693          	addi	a3,s9,64
    1002:	e436                	sd	a3,8(sp)
    1004:	8d6e                	mv	s10,s11
    1006:	8b4a                	mv	s6,s2
    1008:	8dd2                	mv	s11,s4
    100a:	8a7a                	mv	s4,t5
    100c:	0d805963          	blez	s8,10de <core_bench_list+0x77e>
    1010:	240b0c63          	beqz	s6,1268 <core_bench_list+0x908>
    1014:	280a0a63          	beqz	s4,12a8 <core_bench_list+0x948>
    1018:	008dba83          	ld	s5,8(s11)
    101c:	008a3483          	ld	s1,8(s4)
    1020:	000a9403          	lh	s0,0(s5)
    1024:	08047893          	andi	a7,s0,128
    1028:	07f47b93          	andi	s7,s0,127
    102c:	04089363          	bnez	a7,1072 <core_bench_list+0x712>
    1030:	1834380b          	th.extu	a6,s0,6,3
    1034:	0048151b          	slliw	a0,a6,0x4
    1038:	01050fb3          	add	t6,a0,a6
    103c:	00747713          	andi	a4,s0,7
    1040:	85fe                	mv	a1,t6
    1042:	2e070563          	beqz	a4,132c <core_bench_list+0x9cc>
    1046:	4685                	li	a3,1
    1048:	2cd70463          	beq	a4,a3,1310 <core_bench_list+0x9b0>
    104c:	3c04350b          	th.extu	a0,s0,15,0
    1050:	8ba2                	mv	s7,s0
    1052:	060cd583          	lhu	a1,96(s9)
    1056:	07fbfb93          	andi	s7,s7,127
    105a:	286030ef          	jal	42e0 <crcu16>
    105e:	f0047793          	andi	a5,s0,-256
    1062:	00fbe333          	or	t1,s7,a5
    1066:	06ac9023          	sh	a0,96(s9)
    106a:	08036e93          	ori	t4,t1,128
    106e:	01da9023          	sh	t4,0(s5)
    1072:	00049a83          	lh	s5,0(s1)
    1076:	080af293          	andi	t0,s5,128
    107a:	07faff13          	andi	t5,s5,127
    107e:	04029363          	bnez	t0,10c4 <core_bench_list+0x764>
    1082:	183ab60b          	th.extu	a2,s5,6,3
    1086:	0046141b          	slliw	s0,a2,0x4
    108a:	00c408b3          	add	a7,s0,a2
    108e:	007af393          	andi	t2,s5,7
    1092:	85c6                	mv	a1,a7
    1094:	24038263          	beqz	t2,12d8 <core_bench_list+0x978>
    1098:	4505                	li	a0,1
    109a:	22a38163          	beq	t2,a0,12bc <core_bench_list+0x95c>
    109e:	3c0ab50b          	th.extu	a0,s5,15,0
    10a2:	8456                	mv	s0,s5
    10a4:	060cd583          	lhu	a1,96(s9)
    10a8:	238030ef          	jal	42e0 <crcu16>
    10ac:	07f47f13          	andi	t5,s0,127
    10b0:	f00af693          	andi	a3,s5,-256
    10b4:	00df65b3          	or	a1,t5,a3
    10b8:	06ac9023          	sh	a0,96(s9)
    10bc:	0805e793          	ori	a5,a1,128
    10c0:	00f49023          	sh	a5,0(s1)
    10c4:	1f7f5263          	bge	t5,s7,12a8 <core_bench_list+0x948>
    10c8:	84d2                	mv	s1,s4
    10ca:	3b7d                	addiw	s6,s6,-1
    10cc:	000a3a03          	ld	s4,0(s4)
    10d0:	1e0d0263          	beqz	s10,12b4 <core_bench_list+0x954>
    10d4:	009d3023          	sd	s1,0(s10)
    10d8:	8d26                	mv	s10,s1
    10da:	f3804be3          	bgtz	s8,1010 <core_bench_list+0x6b0>
    10de:	2d605363          	blez	s6,13a4 <core_bench_list+0xa44>
    10e2:	1a0a0963          	beqz	s4,1294 <core_bench_list+0x934>
    10e6:	f20c19e3          	bnez	s8,1018 <core_bench_list+0x6b8>
    10ea:	fffb0c1b          	addiw	s8,s6,-1
    10ee:	007c7593          	andi	a1,s8,7
    10f2:	c1e9                	beqz	a1,11b4 <core_bench_list+0x854>
    10f4:	000a3303          	ld	t1,0(s4)
    10f8:	3b7d                	addiw	s6,s6,-1
    10fa:	280d0263          	beqz	s10,137e <core_bench_list+0xa1e>
    10fe:	014d3023          	sd	s4,0(s10)
    1102:	8d52                	mv	s10,s4
    1104:	18030863          	beqz	t1,1294 <core_bench_list+0x934>
    1108:	4285                	li	t0,1
    110a:	8a1a                	mv	s4,t1
    110c:	00058e9b          	sext.w	t4,a1
    1110:	0a558263          	beq	a1,t0,11b4 <core_bench_list+0x854>
    1114:	4609                	li	a2,2
    1116:	08ce8463          	beq	t4,a2,119e <core_bench_list+0x83e>
    111a:	438d                	li	t2,3
    111c:	067e8663          	beq	t4,t2,1188 <core_bench_list+0x828>
    1120:	4411                	li	s0,4
    1122:	048e8863          	beq	t4,s0,1172 <core_bench_list+0x812>
    1126:	4895                	li	a7,5
    1128:	031e8a63          	beq	t4,a7,115c <core_bench_list+0x7fc>
    112c:	4499                	li	s1,6
    112e:	009e8c63          	beq	t4,s1,1146 <core_bench_list+0x7e6>
    1132:	00033a03          	ld	s4,0(t1)
    1136:	3b7d                	addiw	s6,s6,-1
    1138:	260d0463          	beqz	s10,13a0 <core_bench_list+0xa40>
    113c:	006d3023          	sd	t1,0(s10)
    1140:	8d1a                	mv	s10,t1
    1142:	140a0963          	beqz	s4,1294 <core_bench_list+0x934>
    1146:	000a3703          	ld	a4,0(s4)
    114a:	3b7d                	addiw	s6,s6,-1
    114c:	240d0363          	beqz	s10,1392 <core_bench_list+0xa32>
    1150:	014d3023          	sd	s4,0(s10)
    1154:	8d52                	mv	s10,s4
    1156:	12070f63          	beqz	a4,1294 <core_bench_list+0x934>
    115a:	8a3a                	mv	s4,a4
    115c:	000a3803          	ld	a6,0(s4)
    1160:	3b7d                	addiw	s6,s6,-1
    1162:	220d0663          	beqz	s10,138e <core_bench_list+0xa2e>
    1166:	014d3023          	sd	s4,0(s10)
    116a:	8d52                	mv	s10,s4
    116c:	12080463          	beqz	a6,1294 <core_bench_list+0x934>
    1170:	8a42                	mv	s4,a6
    1172:	000a3503          	ld	a0,0(s4)
    1176:	3b7d                	addiw	s6,s6,-1
    1178:	200d0963          	beqz	s10,138a <core_bench_list+0xa2a>
    117c:	014d3023          	sd	s4,0(s10)
    1180:	8d52                	mv	s10,s4
    1182:	10050963          	beqz	a0,1294 <core_bench_list+0x934>
    1186:	8a2a                	mv	s4,a0
    1188:	000a3f83          	ld	t6,0(s4)
    118c:	3b7d                	addiw	s6,s6,-1
    118e:	1e0d0c63          	beqz	s10,1386 <core_bench_list+0xa26>
    1192:	014d3023          	sd	s4,0(s10)
    1196:	8d52                	mv	s10,s4
    1198:	0e0f8e63          	beqz	t6,1294 <core_bench_list+0x934>
    119c:	8a7e                	mv	s4,t6
    119e:	000a3a83          	ld	s5,0(s4)
    11a2:	3b7d                	addiw	s6,s6,-1
    11a4:	1c0d0f63          	beqz	s10,1382 <core_bench_list+0xa22>
    11a8:	014d3023          	sd	s4,0(s10)
    11ac:	8d52                	mv	s10,s4
    11ae:	0e0a8363          	beqz	s5,1294 <core_bench_list+0x934>
    11b2:	8a56                	mv	s4,s5
    11b4:	000a3b83          	ld	s7,0(s4)
    11b8:	3b7d                	addiw	s6,s6,-1
    11ba:	0a0d0563          	beqz	s10,1264 <core_bench_list+0x904>
    11be:	014d3023          	sd	s4,0(s10)
    11c2:	1c0b0a63          	beqz	s6,1396 <core_bench_list+0xa36>
    11c6:	8d52                	mv	s10,s4
    11c8:	0c0b8663          	beqz	s7,1294 <core_bench_list+0x934>
    11cc:	000bbf03          	ld	t5,0(s7)
    11d0:	fffb0e1b          	addiw	t3,s6,-1
    11d4:	180a0763          	beqz	s4,1362 <core_bench_list+0xa02>
    11d8:	017a3023          	sd	s7,0(s4)
    11dc:	8d5e                	mv	s10,s7
    11de:	0a0f0b63          	beqz	t5,1294 <core_bench_list+0x934>
    11e2:	000f3683          	ld	a3,0(t5)
    11e6:	fffe0d9b          	addiw	s11,t3,-1
    11ea:	160b8e63          	beqz	s7,1366 <core_bench_list+0xa06>
    11ee:	01ebb023          	sd	t5,0(s7)
    11f2:	8d7a                	mv	s10,t5
    11f4:	c2c5                	beqz	a3,1294 <core_bench_list+0x934>
    11f6:	628c                	ld	a1,0(a3)
    11f8:	fffd8c1b          	addiw	s8,s11,-1
    11fc:	160f0763          	beqz	t5,136a <core_bench_list+0xa0a>
    1200:	00df3023          	sd	a3,0(t5)
    1204:	8d36                	mv	s10,a3
    1206:	c5d9                	beqz	a1,1294 <core_bench_list+0x934>
    1208:	0005b303          	ld	t1,0(a1)
    120c:	fffc079b          	addiw	a5,s8,-1
    1210:	14068f63          	beqz	a3,136e <core_bench_list+0xa0e>
    1214:	e28c                	sd	a1,0(a3)
    1216:	8d2e                	mv	s10,a1
    1218:	06030e63          	beqz	t1,1294 <core_bench_list+0x934>
    121c:	00033283          	ld	t0,0(t1)
    1220:	fff78e9b          	addiw	t4,a5,-1
    1224:	14058763          	beqz	a1,1372 <core_bench_list+0xa12>
    1228:	0065b023          	sd	t1,0(a1)
    122c:	8d1a                	mv	s10,t1
    122e:	06028363          	beqz	t0,1294 <core_bench_list+0x934>
    1232:	0002b603          	ld	a2,0(t0)
    1236:	fffe839b          	addiw	t2,t4,-1
    123a:	14030063          	beqz	t1,137a <core_bench_list+0xa1a>
    123e:	00533023          	sd	t0,0(t1)
    1242:	8d16                	mv	s10,t0
    1244:	ca21                	beqz	a2,1294 <core_bench_list+0x934>
    1246:	6200                	ld	s0,0(a2)
    1248:	fff38b1b          	addiw	s6,t2,-1
    124c:	12028563          	beqz	t0,1376 <core_bench_list+0xa16>
    1250:	00c2b023          	sd	a2,0(t0)
    1254:	8d32                	mv	s10,a2
    1256:	cc1d                	beqz	s0,1294 <core_bench_list+0x934>
    1258:	8a22                	mv	s4,s0
    125a:	000a3b83          	ld	s7,0(s4)
    125e:	3b7d                	addiw	s6,s6,-1
    1260:	f40d1fe3          	bnez	s10,11be <core_bench_list+0x85e>
    1264:	89d2                	mv	s3,s4
    1266:	bfb1                	j	11c2 <core_bench_list+0x862>
    1268:	000dbb03          	ld	s6,0(s11)
    126c:	3c7d                	addiw	s8,s8,-1
    126e:	000d0d63          	beqz	s10,1288 <core_bench_list+0x928>
    1272:	01bd3023          	sd	s11,0(s10)
    1276:	000c0c63          	beqz	s8,128e <core_bench_list+0x92e>
    127a:	8d6e                	mv	s10,s11
    127c:	8dda                	mv	s11,s6
    127e:	000dbb03          	ld	s6,0(s11)
    1282:	3c7d                	addiw	s8,s8,-1
    1284:	fe0d17e3          	bnez	s10,1272 <core_bench_list+0x912>
    1288:	89ee                	mv	s3,s11
    128a:	fe0c18e3          	bnez	s8,127a <core_bench_list+0x91a>
    128e:	d40a19e3          	bnez	s4,fe0 <core_bench_list+0x680>
    1292:	8d6e                	mv	s10,s11
    1294:	6dc2                	ld	s11,16(sp)
    1296:	4a05                	li	s4,1
    1298:	000d3023          	sd	zero,0(s10)
    129c:	114d8863          	beq	s11,s4,13ac <core_bench_list+0xa4c>
    12a0:	0019191b          	slliw	s2,s2,0x1
    12a4:	8a4e                	mv	s4,s3
    12a6:	b33d                	j	fd4 <core_bench_list+0x674>
    12a8:	84ee                	mv	s1,s11
    12aa:	3c7d                	addiw	s8,s8,-1
    12ac:	000dbd83          	ld	s11,0(s11)
    12b0:	e20d12e3          	bnez	s10,10d4 <core_bench_list+0x774>
    12b4:	89a6                	mv	s3,s1
    12b6:	8d26                	mv	s10,s1
    12b8:	b50d                	j	10da <core_bench_list+0x77a>
    12ba:	0001                	nop
    12bc:	060cd603          	lhu	a2,96(s9)
    12c0:	6522                	ld	a0,8(sp)
    12c2:	6ce010ef          	jal	2990 <core_bench_matrix>
    12c6:	064cde03          	lhu	t3,100(s9)
    12ca:	000e1463          	bnez	t3,12d2 <core_bench_list+0x972>
    12ce:	06ac9223          	sh	a0,100(s9)
    12d2:	3c05240b          	th.ext	s0,a0,15,0
    12d6:	b3f9                	j	10a4 <core_bench_list+0x744>
    12d8:	02100713          	li	a4,33
    12dc:	060cd783          	lhu	a5,96(s9)
    12e0:	002c9683          	lh	a3,2(s9)
    12e4:	000c9603          	lh	a2,0(s9)
    12e8:	028ca503          	lw	a0,40(s9)
    12ec:	020cb583          	ld	a1,32(s9)
    12f0:	01173833          	sltu	a6,a4,a7
    12f4:	02200713          	li	a4,34
    12f8:	4308970b          	th.mvnez	a4,a7,a6
    12fc:	174020ef          	jal	3470 <core_bench_state>
    1300:	066cdf83          	lhu	t6,102(s9)
    1304:	fc0f97e3          	bnez	t6,12d2 <core_bench_list+0x972>
    1308:	06ac9323          	sh	a0,102(s9)
    130c:	b7d9                	j	12d2 <core_bench_list+0x972>
    130e:	0001                	nop
    1310:	060cd603          	lhu	a2,96(s9)
    1314:	6522                	ld	a0,8(sp)
    1316:	67a010ef          	jal	2990 <core_bench_matrix>
    131a:	064cd583          	lhu	a1,100(s9)
    131e:	e199                	bnez	a1,1324 <core_bench_list+0x9c4>
    1320:	06ac9223          	sh	a0,100(s9)
    1324:	3c052b8b          	th.ext	s7,a0,15,0
    1328:	b32d                	j	1052 <core_bench_list+0x6f2>
    132a:	0001                	nop
    132c:	060cd783          	lhu	a5,96(s9)
    1330:	002c9683          	lh	a3,2(s9)
    1334:	000c9603          	lh	a2,0(s9)
    1338:	028ca503          	lw	a0,40(s9)
    133c:	020cb583          	ld	a1,32(s9)
    1340:	02100b93          	li	s7,33
    1344:	01fbbe33          	sltu	t3,s7,t6
    1348:	02200713          	li	a4,34
    134c:	43cf970b          	th.mvnez	a4,t6,t3
    1350:	120020ef          	jal	3470 <core_bench_state>
    1354:	066cdf03          	lhu	t5,102(s9)
    1358:	fc0f16e3          	bnez	t5,1324 <core_bench_list+0x9c4>
    135c:	06ac9323          	sh	a0,102(s9)
    1360:	b7d1                	j	1324 <core_bench_list+0x9c4>
    1362:	89de                	mv	s3,s7
    1364:	bda5                	j	11dc <core_bench_list+0x87c>
    1366:	89fa                	mv	s3,t5
    1368:	b569                	j	11f2 <core_bench_list+0x892>
    136a:	89b6                	mv	s3,a3
    136c:	bd61                	j	1204 <core_bench_list+0x8a4>
    136e:	89ae                	mv	s3,a1
    1370:	b55d                	j	1216 <core_bench_list+0x8b6>
    1372:	899a                	mv	s3,t1
    1374:	bd65                	j	122c <core_bench_list+0x8cc>
    1376:	89b2                	mv	s3,a2
    1378:	bdf1                	j	1254 <core_bench_list+0x8f4>
    137a:	8996                	mv	s3,t0
    137c:	b5d9                	j	1242 <core_bench_list+0x8e2>
    137e:	89d2                	mv	s3,s4
    1380:	b349                	j	1102 <core_bench_list+0x7a2>
    1382:	89d2                	mv	s3,s4
    1384:	b525                	j	11ac <core_bench_list+0x84c>
    1386:	89d2                	mv	s3,s4
    1388:	b539                	j	1196 <core_bench_list+0x836>
    138a:	89d2                	mv	s3,s4
    138c:	bbd5                	j	1180 <core_bench_list+0x820>
    138e:	89d2                	mv	s3,s4
    1390:	bbe9                	j	116a <core_bench_list+0x80a>
    1392:	89d2                	mv	s3,s4
    1394:	b3c1                	j	1154 <core_bench_list+0x7f4>
    1396:	8dd2                	mv	s11,s4
    1398:	8a5e                	mv	s4,s7
    139a:	c40a13e3          	bnez	s4,fe0 <core_bench_list+0x680>
    139e:	bdd5                	j	1292 <core_bench_list+0x932>
    13a0:	899a                	mv	s3,t1
    13a2:	bb79                	j	1140 <core_bench_list+0x7e0>
    13a4:	8dea                	mv	s11,s10
    13a6:	c20a1de3          	bnez	s4,fe0 <core_bench_list+0x680>
    13aa:	b5e5                	j	1292 <core_bench_list+0x932>
    13ac:	8a4e                	mv	s4,s3
    13ae:	f52ff06f          	j	b00 <core_bench_list+0x1a0>
    13b2:	ec2e                	sd	a1,24(sp)
    13b4:	f402                	sd	zero,40(sp)
    13b6:	f46ff06f          	j	afc <core_bench_list+0x19c>
    13ba:	000a0b63          	beqz	s4,13d0 <core_bench_list+0xa70>
    13be:	872e                	mv	a4,a1
    13c0:	87d2                	mv	a5,s4
    13c2:	4501                	li	a0,0
    13c4:	4e81                	li	t4,0
    13c6:	4301                	li	t1,0
    13c8:	4881                	li	a7,0
    13ca:	4581                	li	a1,0
    13cc:	ee4ff06f          	j	ab0 <core_bench_list+0x150>
    13d0:	00003783          	ld	a5,0(zero) # 0 <__start>
    13d4:	9002                	ebreak
    13d6:	00000013          	nop
    13da:	00000013          	nop
    13de:	0001                	nop

00000000000013e0 <core_list_init>:
    13e0:	47d1                	li	a5,20
    13e2:	02f5553b          	divuw	a0,a0,a5
    13e6:	86ae                	mv	a3,a1
    13e8:	6721                	lui	a4,0x8
    13ea:	08070393          	addi	t2,a4,128 # 8080 <_ftoa+0xf40>
    13ee:	8eb2                	mv	t4,a2
    13f0:	01068713          	addi	a4,a3,16
    13f4:	ffe50f9b          	addiw	t6,a0,-2
    13f8:	7c0fbf0b          	th.extu	t5,t6,31,0
    13fc:	004f1293          	slli	t0,t5,0x4
    1400:	00558833          	add	a6,a1,t0
    1404:	0006b023          	sd	zero,0(a3)
    1408:	0106b423          	sd	a6,8(a3)
    140c:	02058593          	addi	a1,a1,32
    1410:	4056d38b          	th.srw	t2,a3,t0,0
    1414:	837e                	mv	t1,t6
    1416:	05e81f0b          	th.addsl	t5,a6,t5,2
    141a:	00480613          	addi	a2,a6,4
    141e:	3505f763          	bgeu	a1,a6,176c <core_list_init+0x38c>
    1422:	00880893          	addi	a7,a6,8
    1426:	35e8f363          	bgeu	a7,t5,176c <core_list_init+0x38c>
    142a:	80000e37          	lui	t3,0x80000
    142e:	fffe0793          	addi	a5,t3,-1 # ffffffff7fffffff <__kernel_stack+0xffffffff7ff11fff>
    1432:	e298                	sd	a4,0(a3)
    1434:	0006b823          	sd	zero,16(a3)
    1438:	ee90                	sd	a2,24(a3)
    143a:	00f82223          	sw	a5,4(a6)
    143e:	8646                	mv	a2,a7
    1440:	87ba                	mv	a5,a4
    1442:	872e                	mv	a4,a1
    1444:	040f8d63          	beqz	t6,149e <core_list_init+0xbe>
    1448:	01070893          	addi	a7,a4,16
    144c:	3c0eb38b          	th.extu	t2,t4,15,0
    1450:	4581                	li	a1,0
    1452:	62a1                	lui	t0,0x8
    1454:	32fd                	addiw	t0,t0,-1 # 7fff <_ftoa+0xebf>
    1456:	0508f463          	bgeu	a7,a6,149e <core_list_init+0xbe>
    145a:	00460e13          	addi	t3,a2,4
    145e:	31ee7963          	bgeu	t3,t5,1770 <core_list_init+0x390>
    1462:	3c05b50b          	th.extu	a0,a1,15,0
    1466:	e31c                	sd	a5,0(a4)
    1468:	00a3c7b3          	xor	a5,t2,a0
    146c:	0037979b          	slliw	a5,a5,0x3
    1470:	891d                	andi	a0,a0,7
    1472:	0787f793          	andi	a5,a5,120
    1476:	8fc9                	or	a5,a5,a0
    1478:	e298                	sd	a4,0(a3)
    147a:	0087951b          	slliw	a0,a5,0x8
    147e:	e710                	sd	a2,8(a4)
    1480:	9fa9                	addw	a5,a5,a0
    1482:	2585                	addiw	a1,a1,1
    1484:	00f61023          	sh	a5,0(a2)
    1488:	00561123          	sh	t0,2(a2)
    148c:	2cbf8c63          	beq	t6,a1,1764 <core_list_init+0x384>
    1490:	87ba                	mv	a5,a4
    1492:	8746                	mv	a4,a7
    1494:	01070893          	addi	a7,a4,16
    1498:	8672                	mv	a2,t3
    149a:	fd08e0e3          	bltu	a7,a6,145a <core_list_init+0x7a>
    149e:	6390                	ld	a2,0(a5)
    14a0:	ca29                	beqz	a2,14f2 <core_list_init+0x112>
    14a2:	4f95                	li	t6,5
    14a4:	03f3533b          	divuw	t1,t1,t6
    14a8:	4f05                	li	t5,1
    14aa:	4509                	li	a0,2
    14ac:	006f7f63          	bgeu	t5,t1,14ca <core_list_init+0xea>
    14b0:	6798                	ld	a4,8(a5)
    14b2:	00063883          	ld	a7,0(a2)
    14b6:	2505                	addiw	a0,a0,1
    14b8:	01e71123          	sh	t5,2(a4)
    14bc:	2f05                	addiw	t5,t5,1
    14be:	02088a63          	beqz	a7,14f2 <core_list_init+0x112>
    14c2:	87b2                	mv	a5,a2
    14c4:	8646                	mv	a2,a7
    14c6:	fe6f65e3          	bltu	t5,t1,14b0 <core_list_init+0xd0>
    14ca:	0085129b          	slliw	t0,a0,0x8
    14ce:	0087b383          	ld	t2,8(a5)
    14d2:	01df4833          	xor	a6,t5,t4
    14d6:	7002f793          	andi	a5,t0,1792
    14da:	0107e5b3          	or	a1,a5,a6
    14de:	00063883          	ld	a7,0(a2)
    14e2:	3405be0b          	th.extu	t3,a1,13,0
    14e6:	01c39123          	sh	t3,2(t2)
    14ea:	2f05                	addiw	t5,t5,1
    14ec:	2505                	addiw	a0,a0,1
    14ee:	fc089ae3          	bnez	a7,14c2 <core_list_init+0xe2>
    14f2:	4e85                	li	t4,1
    14f4:	4501                	li	a0,0
    14f6:	4601                	li	a2,0
    14f8:	4f01                	li	t5,0
    14fa:	8ff6                	mv	t6,t4
    14fc:	00000013          	nop
    1500:	2f05                	addiw	t5,t5,1
    1502:	8736                	mv	a4,a3
    1504:	4781                	li	a5,0
    1506:	0001                	nop
    1508:	01d7d563          	bge	a5,t4,1512 <core_list_init+0x132>
    150c:	6318                	ld	a4,0(a4)
    150e:	2785                	addiw	a5,a5,1
    1510:	ff65                	bnez	a4,1508 <core_list_init+0x128>
    1512:	8876                	mv	a6,t4
    1514:	00f05d63          	blez	a5,152e <core_list_init+0x14e>
    1518:	06080663          	beqz	a6,1584 <core_list_init+0x1a4>
    151c:	ef11                	bnez	a4,1538 <core_list_init+0x158>
    151e:	85b6                	mv	a1,a3
    1520:	37fd                	addiw	a5,a5,-1
    1522:	6294                	ld	a3,0(a3)
    1524:	ce21                	beqz	a2,157c <core_list_init+0x19c>
    1526:	e20c                	sd	a1,0(a2)
    1528:	862e                	mv	a2,a1
    152a:	fef047e3          	bgtz	a5,1518 <core_list_init+0x138>
    152e:	23005d63          	blez	a6,1768 <core_list_init+0x388>
    1532:	1c070763          	beqz	a4,1700 <core_list_init+0x320>
    1536:	cbbd                	beqz	a5,15ac <core_list_init+0x1cc>
    1538:	0086b303          	ld	t1,8(a3)
    153c:	00031583          	lh	a1,0(t1)
    1540:	f005f893          	andi	a7,a1,-256
    1544:	3c85b38b          	th.extu	t2,a1,15,8
    1548:	0078e2b3          	or	t0,a7,t2
    154c:	00873883          	ld	a7,8(a4)
    1550:	00531023          	sh	t0,0(t1)
    1554:	00231303          	lh	t1,2(t1)
    1558:	00089583          	lh	a1,0(a7)
    155c:	f005fe13          	andi	t3,a1,-256
    1560:	3c85b38b          	th.extu	t2,a1,15,8
    1564:	007e62b3          	or	t0,t3,t2
    1568:	00589023          	sh	t0,0(a7)
    156c:	00289883          	lh	a7,2(a7)
    1570:	fa68d7e3          	bge	a7,t1,151e <core_list_init+0x13e>
    1574:	85ba                	mv	a1,a4
    1576:	387d                	addiw	a6,a6,-1
    1578:	6318                	ld	a4,0(a4)
    157a:	f655                	bnez	a2,1526 <core_list_init+0x146>
    157c:	852e                	mv	a0,a1
    157e:	862e                	mv	a2,a1
    1580:	b76d                	j	152a <core_list_init+0x14a>
    1582:	0001                	nop
    1584:	0006b803          	ld	a6,0(a3)
    1588:	37fd                	addiw	a5,a5,-1
    158a:	ca09                	beqz	a2,159c <core_list_init+0x1bc>
    158c:	e214                	sd	a3,0(a2)
    158e:	cb89                	beqz	a5,15a0 <core_list_init+0x1c0>
    1590:	8636                	mv	a2,a3
    1592:	86c2                	mv	a3,a6
    1594:	0006b803          	ld	a6,0(a3)
    1598:	37fd                	addiw	a5,a5,-1
    159a:	fa6d                	bnez	a2,158c <core_list_init+0x1ac>
    159c:	8536                	mv	a0,a3
    159e:	fbed                	bnez	a5,1590 <core_list_init+0x1b0>
    15a0:	8636                	mv	a2,a3
    15a2:	14070f63          	beqz	a4,1700 <core_list_init+0x320>
    15a6:	8636                	mv	a2,a3
    15a8:	86ba                	mv	a3,a4
    15aa:	bf99                	j	1500 <core_list_init+0x120>
    15ac:	fff8031b          	addiw	t1,a6,-1
    15b0:	00737393          	andi	t2,t1,7
    15b4:	0a038463          	beqz	t2,165c <core_list_init+0x27c>
    15b8:	631c                	ld	a5,0(a4)
    15ba:	387d                	addiw	a6,a6,-1
    15bc:	18060263          	beqz	a2,1740 <core_list_init+0x360>
    15c0:	e218                	sd	a4,0(a2)
    15c2:	863a                	mv	a2,a4
    15c4:	12078e63          	beqz	a5,1700 <core_list_init+0x320>
    15c8:	4585                	li	a1,1
    15ca:	873e                	mv	a4,a5
    15cc:	00038e1b          	sext.w	t3,t2
    15d0:	08b38663          	beq	t2,a1,165c <core_list_init+0x27c>
    15d4:	4889                	li	a7,2
    15d6:	071e0a63          	beq	t3,a7,164a <core_list_init+0x26a>
    15da:	468d                	li	a3,3
    15dc:	04de0f63          	beq	t3,a3,163a <core_list_init+0x25a>
    15e0:	4311                	li	t1,4
    15e2:	046e0263          	beq	t3,t1,1626 <core_list_init+0x246>
    15e6:	4395                	li	t2,5
    15e8:	027e0763          	beq	t3,t2,1616 <core_list_init+0x236>
    15ec:	4299                	li	t0,6
    15ee:	005e0c63          	beq	t3,t0,1606 <core_list_init+0x226>
    15f2:	0007be03          	ld	t3,0(a5)
    15f6:	387d                	addiw	a6,a6,-1
    15f8:	16060463          	beqz	a2,1760 <core_list_init+0x380>
    15fc:	e21c                	sd	a5,0(a2)
    15fe:	863e                	mv	a2,a5
    1600:	8772                	mv	a4,t3
    1602:	0e0e0f63          	beqz	t3,1700 <core_list_init+0x320>
    1606:	631c                	ld	a5,0(a4)
    1608:	387d                	addiw	a6,a6,-1
    160a:	14060563          	beqz	a2,1754 <core_list_init+0x374>
    160e:	e218                	sd	a4,0(a2)
    1610:	863a                	mv	a2,a4
    1612:	873e                	mv	a4,a5
    1614:	c7f5                	beqz	a5,1700 <core_list_init+0x320>
    1616:	630c                	ld	a1,0(a4)
    1618:	387d                	addiw	a6,a6,-1
    161a:	12060b63          	beqz	a2,1750 <core_list_init+0x370>
    161e:	e218                	sd	a4,0(a2)
    1620:	863a                	mv	a2,a4
    1622:	872e                	mv	a4,a1
    1624:	cdf1                	beqz	a1,1700 <core_list_init+0x320>
    1626:	00073883          	ld	a7,0(a4)
    162a:	387d                	addiw	a6,a6,-1
    162c:	12060063          	beqz	a2,174c <core_list_init+0x36c>
    1630:	e218                	sd	a4,0(a2)
    1632:	863a                	mv	a2,a4
    1634:	8746                	mv	a4,a7
    1636:	0c088563          	beqz	a7,1700 <core_list_init+0x320>
    163a:	6314                	ld	a3,0(a4)
    163c:	387d                	addiw	a6,a6,-1
    163e:	10060563          	beqz	a2,1748 <core_list_init+0x368>
    1642:	e218                	sd	a4,0(a2)
    1644:	863a                	mv	a2,a4
    1646:	8736                	mv	a4,a3
    1648:	cec5                	beqz	a3,1700 <core_list_init+0x320>
    164a:	00073303          	ld	t1,0(a4)
    164e:	387d                	addiw	a6,a6,-1
    1650:	ca75                	beqz	a2,1744 <core_list_init+0x364>
    1652:	e218                	sd	a4,0(a2)
    1654:	863a                	mv	a2,a4
    1656:	871a                	mv	a4,t1
    1658:	0a030463          	beqz	t1,1700 <core_list_init+0x320>
    165c:	00073383          	ld	t2,0(a4)
    1660:	387d                	addiw	a6,a6,-1
    1662:	ca5d                	beqz	a2,1718 <core_list_init+0x338>
    1664:	e218                	sd	a4,0(a2)
    1666:	0a080c63          	beqz	a6,171e <core_list_init+0x33e>
    166a:	863a                	mv	a2,a4
    166c:	08038a63          	beqz	t2,1700 <core_list_init+0x320>
    1670:	0003be03          	ld	t3,0(t2)
    1674:	fff8029b          	addiw	t0,a6,-1
    1678:	c755                	beqz	a4,1724 <core_list_init+0x344>
    167a:	00773023          	sd	t2,0(a4)
    167e:	861e                	mv	a2,t2
    1680:	080e0063          	beqz	t3,1700 <core_list_init+0x320>
    1684:	000e3703          	ld	a4,0(t3)
    1688:	fff2879b          	addiw	a5,t0,-1
    168c:	08038e63          	beqz	t2,1728 <core_list_init+0x348>
    1690:	01c3b023          	sd	t3,0(t2)
    1694:	8672                	mv	a2,t3
    1696:	c72d                	beqz	a4,1700 <core_list_init+0x320>
    1698:	00073883          	ld	a7,0(a4)
    169c:	fff7859b          	addiw	a1,a5,-1
    16a0:	080e0663          	beqz	t3,172c <core_list_init+0x34c>
    16a4:	00ee3023          	sd	a4,0(t3)
    16a8:	863a                	mv	a2,a4
    16aa:	04088b63          	beqz	a7,1700 <core_list_init+0x320>
    16ae:	0008b683          	ld	a3,0(a7)
    16b2:	fff5831b          	addiw	t1,a1,-1
    16b6:	cf2d                	beqz	a4,1730 <core_list_init+0x350>
    16b8:	01173023          	sd	a7,0(a4)
    16bc:	8646                	mv	a2,a7
    16be:	c2a9                	beqz	a3,1700 <core_list_init+0x320>
    16c0:	0006b383          	ld	t2,0(a3)
    16c4:	fff3081b          	addiw	a6,t1,-1
    16c8:	06088663          	beqz	a7,1734 <core_list_init+0x354>
    16cc:	00d8b023          	sd	a3,0(a7)
    16d0:	8636                	mv	a2,a3
    16d2:	02038763          	beqz	t2,1700 <core_list_init+0x320>
    16d6:	0003be03          	ld	t3,0(t2)
    16da:	fff8029b          	addiw	t0,a6,-1
    16de:	cea9                	beqz	a3,1738 <core_list_init+0x358>
    16e0:	0076b023          	sd	t2,0(a3)
    16e4:	861e                	mv	a2,t2
    16e6:	000e0d63          	beqz	t3,1700 <core_list_init+0x320>
    16ea:	000e3703          	ld	a4,0(t3)
    16ee:	fff2881b          	addiw	a6,t0,-1
    16f2:	04038563          	beqz	t2,173c <core_list_init+0x35c>
    16f6:	01c3b023          	sd	t3,0(t2)
    16fa:	8672                	mv	a2,t3
    16fc:	f325                	bnez	a4,165c <core_list_init+0x27c>
    16fe:	0001                	nop
    1700:	00063023          	sd	zero,0(a2)
    1704:	05ff0d63          	beq	t5,t6,175e <core_list_init+0x37e>
    1708:	001e9e9b          	slliw	t4,t4,0x1
    170c:	c531                	beqz	a0,1758 <core_list_init+0x378>
    170e:	872a                	mv	a4,a0
    1710:	4681                	li	a3,0
    1712:	4501                	li	a0,0
    1714:	4f01                	li	t5,0
    1716:	bd41                	j	15a6 <core_list_init+0x1c6>
    1718:	853a                	mv	a0,a4
    171a:	f40818e3          	bnez	a6,166a <core_list_init+0x28a>
    171e:	86ba                	mv	a3,a4
    1720:	871e                	mv	a4,t2
    1722:	bdbd                	j	15a0 <core_list_init+0x1c0>
    1724:	851e                	mv	a0,t2
    1726:	bfa1                	j	167e <core_list_init+0x29e>
    1728:	8572                	mv	a0,t3
    172a:	b7ad                	j	1694 <core_list_init+0x2b4>
    172c:	853a                	mv	a0,a4
    172e:	bfad                	j	16a8 <core_list_init+0x2c8>
    1730:	8546                	mv	a0,a7
    1732:	b769                	j	16bc <core_list_init+0x2dc>
    1734:	8536                	mv	a0,a3
    1736:	bf69                	j	16d0 <core_list_init+0x2f0>
    1738:	851e                	mv	a0,t2
    173a:	b76d                	j	16e4 <core_list_init+0x304>
    173c:	8572                	mv	a0,t3
    173e:	bf75                	j	16fa <core_list_init+0x31a>
    1740:	853a                	mv	a0,a4
    1742:	b541                	j	15c2 <core_list_init+0x1e2>
    1744:	853a                	mv	a0,a4
    1746:	b739                	j	1654 <core_list_init+0x274>
    1748:	853a                	mv	a0,a4
    174a:	bded                	j	1644 <core_list_init+0x264>
    174c:	853a                	mv	a0,a4
    174e:	b5d5                	j	1632 <core_list_init+0x252>
    1750:	853a                	mv	a0,a4
    1752:	b5f9                	j	1620 <core_list_init+0x240>
    1754:	853a                	mv	a0,a4
    1756:	bd6d                	j	1610 <core_list_init+0x230>
    1758:	00003023          	sd	zero,0(zero) # 0 <__start>
    175c:	9002                	ebreak
    175e:	8082                	ret
    1760:	853e                	mv	a0,a5
    1762:	bd71                	j	15fe <core_list_init+0x21e>
    1764:	87ba                	mv	a5,a4
    1766:	bb25                	j	149e <core_list_init+0xbe>
    1768:	86b2                	mv	a3,a2
    176a:	bd1d                	j	15a0 <core_list_init+0x1c0>
    176c:	4781                	li	a5,0
    176e:	b9d9                	j	1444 <core_list_init+0x64>
    1770:	2585                	addiw	a1,a1,1
    1772:	d2bf86e3          	beq	t6,a1,149e <core_list_init+0xbe>
    1776:	88ba                	mv	a7,a4
    1778:	8e32                	mv	t3,a2
    177a:	873e                	mv	a4,a5
    177c:	bb11                	j	1490 <core_list_init+0xb0>
    177e:	0001                	nop

0000000000001780 <core_list_insert_new>:
    1780:	882a                	mv	a6,a0
    1782:	6208                	ld	a0,0(a2)
    1784:	01050893          	addi	a7,a0,16
    1788:	02e8fe63          	bgeu	a7,a4,17c4 <core_list_insert_new+0x44>
    178c:	6298                	ld	a4,0(a3)
    178e:	00470313          	addi	t1,a4,4
    1792:	02f37963          	bgeu	t1,a5,17c4 <core_list_insert_new+0x44>
    1796:	01163023          	sd	a7,0(a2)
    179a:	00083783          	ld	a5,0(a6)
    179e:	00059283          	lh	t0,0(a1)
    17a2:	00259583          	lh	a1,2(a1)
    17a6:	e11c                	sd	a5,0(a0)
    17a8:	00a83023          	sd	a0,0(a6)
    17ac:	e518                	sd	a4,8(a0)
    17ae:	0006b383          	ld	t2,0(a3)
    17b2:	00438613          	addi	a2,t2,4
    17b6:	e290                	sd	a2,0(a3)
    17b8:	6514                	ld	a3,8(a0)
    17ba:	00569023          	sh	t0,0(a3)
    17be:	00b69123          	sh	a1,2(a3)
    17c2:	8082                	ret
    17c4:	4501                	li	a0,0
    17c6:	8082                	ret
    17c8:	00000013          	nop
    17cc:	00000013          	nop

00000000000017d0 <core_list_remove>:
    17d0:	87aa                	mv	a5,a0
    17d2:	f8e7c50b          	th.ldd	a0,a4,(a5),0,4
    17d6:	6514                	ld	a3,8(a0)
    17d8:	00053283          	ld	t0,0(a0)
    17dc:	e794                	sd	a3,8(a5)
    17de:	e518                	sd	a4,8(a0)
    17e0:	0057b023          	sd	t0,0(a5)
    17e4:	00053023          	sd	zero,0(a0)
    17e8:	8082                	ret
    17ea:	00000013          	nop
    17ee:	0001                	nop

00000000000017f0 <core_list_undo_remove>:
    17f0:	6594                	ld	a3,8(a1)
    17f2:	6518                	ld	a4,8(a0)
    17f4:	0005b283          	ld	t0,0(a1)
    17f8:	e514                	sd	a3,8(a0)
    17fa:	e598                	sd	a4,8(a1)
    17fc:	00553023          	sd	t0,0(a0)
    1800:	e188                	sd	a0,0(a1)
    1802:	8082                	ret
    1804:	00000013          	nop
    1808:	00000013          	nop
    180c:	00000013          	nop

0000000000001810 <core_list_find>:
    1810:	00259603          	lh	a2,2(a1)
    1814:	00064e63          	bltz	a2,1830 <core_list_find+0x20>
    1818:	e501                	bnez	a0,1820 <core_list_find+0x10>
    181a:	8082                	ret
    181c:	6108                	ld	a0,0(a0)
    181e:	c50d                	beqz	a0,1848 <core_list_find+0x38>
    1820:	00853303          	ld	t1,8(a0)
    1824:	00231383          	lh	t2,2(t1)
    1828:	fec39ae3          	bne	t2,a2,181c <core_list_find+0xc>
    182c:	8082                	ret
    182e:	0001                	nop
    1830:	cd01                	beqz	a0,1848 <core_list_find+0x38>
    1832:	00059703          	lh	a4,0(a1)
    1836:	a019                	j	183c <core_list_find+0x2c>
    1838:	6108                	ld	a0,0(a0)
    183a:	c901                	beqz	a0,184a <core_list_find+0x3a>
    183c:	651c                	ld	a5,8(a0)
    183e:	0007c283          	lbu	t0,0(a5)
    1842:	fee29be3          	bne	t0,a4,1838 <core_list_find+0x28>
    1846:	8082                	ret
    1848:	4501                	li	a0,0
    184a:	8082                	ret
    184c:	00000013          	nop

0000000000001850 <core_list_reverse>:
    1850:	c53d                	beqz	a0,18be <core_list_reverse+0x6e>
    1852:	611c                	ld	a5,0(a0)
    1854:	4801                	li	a6,0
    1856:	01053023          	sd	a6,0(a0)
    185a:	86aa                	mv	a3,a0
    185c:	c3ad                	beqz	a5,18be <core_list_reverse+0x6e>
    185e:	6398                	ld	a4,0(a5)
    1860:	e394                	sd	a3,0(a5)
    1862:	853e                	mv	a0,a5
    1864:	cf31                	beqz	a4,18c0 <core_list_reverse+0x70>
    1866:	00073283          	ld	t0,0(a4)
    186a:	e31c                	sd	a5,0(a4)
    186c:	853a                	mv	a0,a4
    186e:	04028863          	beqz	t0,18be <core_list_reverse+0x6e>
    1872:	0002b303          	ld	t1,0(t0)
    1876:	00e2b023          	sd	a4,0(t0)
    187a:	8516                	mv	a0,t0
    187c:	04030163          	beqz	t1,18be <core_list_reverse+0x6e>
    1880:	00033383          	ld	t2,0(t1)
    1884:	00533023          	sd	t0,0(t1)
    1888:	851a                	mv	a0,t1
    188a:	02038a63          	beqz	t2,18be <core_list_reverse+0x6e>
    188e:	0003b583          	ld	a1,0(t2)
    1892:	0063b023          	sd	t1,0(t2)
    1896:	851e                	mv	a0,t2
    1898:	c19d                	beqz	a1,18be <core_list_reverse+0x6e>
    189a:	6190                	ld	a2,0(a1)
    189c:	0075b023          	sd	t2,0(a1)
    18a0:	852e                	mv	a0,a1
    18a2:	ce11                	beqz	a2,18be <core_list_reverse+0x6e>
    18a4:	00063883          	ld	a7,0(a2)
    18a8:	e20c                	sd	a1,0(a2)
    18aa:	8532                	mv	a0,a2
    18ac:	8832                	mv	a6,a2
    18ae:	00088863          	beqz	a7,18be <core_list_reverse+0x6e>
    18b2:	8546                	mv	a0,a7
    18b4:	611c                	ld	a5,0(a0)
    18b6:	01053023          	sd	a6,0(a0)
    18ba:	86aa                	mv	a3,a0
    18bc:	f3cd                	bnez	a5,185e <core_list_reverse+0xe>
    18be:	8082                	ret
    18c0:	8082                	ret
    18c2:	0001                	nop
    18c4:	00000013          	nop
    18c8:	00000013          	nop
    18cc:	00000013          	nop

00000000000018d0 <core_list_mergesort>:
    18d0:	711d                	addi	sp,sp,-96
    18d2:	ff315a0b          	th.sdd	s4,s3,(sp),3,4
    18d6:	fd515b0b          	th.sdd	s6,s5,(sp),2,4
    18da:	fb715c0b          	th.sdd	s8,s7,(sp),1,4
    18de:	f9915d0b          	th.sdd	s10,s9,(sp),0,4
    18e2:	4a05                	li	s4,1
    18e4:	e0ca                	sd	s2,64(sp)
    18e6:	e4a6                	sd	s1,72(sp)
    18e8:	e8a2                	sd	s0,80(sp)
    18ea:	ec86                	sd	ra,88(sp)
    18ec:	89aa                	mv	s3,a0
    18ee:	8bae                	mv	s7,a1
    18f0:	8b32                	mv	s6,a2
    18f2:	8cd2                	mv	s9,s4
    18f4:	0a098763          	beqz	s3,19a2 <core_list_mergesort+0xd2>
    18f8:	4c01                	li	s8,0
    18fa:	4481                	li	s1,0
    18fc:	4a81                	li	s5,0
    18fe:	0001                	nop
    1900:	2c05                	addiw	s8,s8,1
    1902:	87ce                	mv	a5,s3
    1904:	4401                	li	s0,0
    1906:	0001                	nop
    1908:	01445563          	bge	s0,s4,1912 <core_list_mergesort+0x42>
    190c:	639c                	ld	a5,0(a5)
    190e:	2405                	addiw	s0,s0,1
    1910:	ffe5                	bnez	a5,1908 <core_list_mergesort+0x38>
    1912:	8926                	mv	s2,s1
    1914:	8d52                	mv	s10,s4
    1916:	84ce                	mv	s1,s3
    1918:	89be                	mv	s3,a5
    191a:	02805163          	blez	s0,193c <core_list_mergesort+0x6c>
    191e:	0001                	nop
    1920:	040d0463          	beqz	s10,1968 <core_list_mergesort+0x98>
    1924:	02099163          	bnez	s3,1946 <core_list_mergesort+0x76>
    1928:	8e26                	mv	t3,s1
    192a:	347d                	addiw	s0,s0,-1
    192c:	6084                	ld	s1,0(s1)
    192e:	02090963          	beqz	s2,1960 <core_list_mergesort+0x90>
    1932:	01c93023          	sd	t3,0(s2)
    1936:	8972                	mv	s2,t3
    1938:	fe8044e3          	bgtz	s0,1920 <core_list_mergesort+0x50>
    193c:	23a05f63          	blez	s10,1b7a <core_list_mergesort+0x2aa>
    1940:	04098863          	beqz	s3,1990 <core_list_mergesort+0xc0>
    1944:	c035                	beqz	s0,19a8 <core_list_mergesort+0xd8>
    1946:	6488                	ld	a0,8(s1)
    1948:	0089b583          	ld	a1,8(s3)
    194c:	865a                	mv	a2,s6
    194e:	9b82                	jalr	s7
    1950:	fca05ce3          	blez	a0,1928 <core_list_mergesort+0x58>
    1954:	8e4e                	mv	t3,s3
    1956:	3d7d                	addiw	s10,s10,-1
    1958:	0009b983          	ld	s3,0(s3)
    195c:	fc091be3          	bnez	s2,1932 <core_list_mergesort+0x62>
    1960:	8af2                	mv	s5,t3
    1962:	8972                	mv	s2,t3
    1964:	bfd1                	j	1938 <core_list_mergesort+0x68>
    1966:	0001                	nop
    1968:	0004be83          	ld	t4,0(s1)
    196c:	347d                	addiw	s0,s0,-1
    196e:	00090c63          	beqz	s2,1986 <core_list_mergesort+0xb6>
    1972:	00993023          	sd	s1,0(s2)
    1976:	c811                	beqz	s0,198a <core_list_mergesort+0xba>
    1978:	8926                	mv	s2,s1
    197a:	84f6                	mv	s1,t4
    197c:	0004be83          	ld	t4,0(s1)
    1980:	347d                	addiw	s0,s0,-1
    1982:	fe0918e3          	bnez	s2,1972 <core_list_mergesort+0xa2>
    1986:	8aa6                	mv	s5,s1
    1988:	f865                	bnez	s0,1978 <core_list_mergesort+0xa8>
    198a:	f6099be3          	bnez	s3,1900 <core_list_mergesort+0x30>
    198e:	8926                	mv	s2,s1
    1990:	00093023          	sd	zero,0(s2)
    1994:	1d9c0463          	beq	s8,s9,1b5c <core_list_mergesort+0x28c>
    1998:	89d6                	mv	s3,s5
    199a:	001a1a1b          	slliw	s4,s4,0x1
    199e:	f4099de3          	bnez	s3,18f8 <core_list_mergesort+0x28>
    19a2:	00003023          	sd	zero,0(zero) # 0 <__start>
    19a6:	9002                	ebreak
    19a8:	fffd029b          	addiw	t0,s10,-1
    19ac:	0072f693          	andi	a3,t0,7
    19b0:	c2e1                	beqz	a3,1a70 <core_list_mergesort+0x1a0>
    19b2:	0009b383          	ld	t2,0(s3)
    19b6:	3d7d                	addiw	s10,s10,-1
    19b8:	18090663          	beqz	s2,1b44 <core_list_mergesort+0x274>
    19bc:	01393023          	sd	s3,0(s2)
    19c0:	894e                	mv	s2,s3
    19c2:	fc0387e3          	beqz	t2,1990 <core_list_mergesort+0xc0>
    19c6:	4605                	li	a2,1
    19c8:	899e                	mv	s3,t2
    19ca:	0006871b          	sext.w	a4,a3
    19ce:	0ac68163          	beq	a3,a2,1a70 <core_list_mergesort+0x1a0>
    19d2:	4409                	li	s0,2
    19d4:	08870463          	beq	a4,s0,1a5c <core_list_mergesort+0x18c>
    19d8:	450d                	li	a0,3
    19da:	06a70663          	beq	a4,a0,1a46 <core_list_mergesort+0x176>
    19de:	4591                	li	a1,4
    19e0:	04b70863          	beq	a4,a1,1a30 <core_list_mergesort+0x160>
    19e4:	4815                	li	a6,5
    19e6:	03070a63          	beq	a4,a6,1a1a <core_list_mergesort+0x14a>
    19ea:	4899                	li	a7,6
    19ec:	01170c63          	beq	a4,a7,1a04 <core_list_mergesort+0x134>
    19f0:	0003b983          	ld	s3,0(t2)
    19f4:	3d7d                	addiw	s10,s10,-1
    19f6:	18090763          	beqz	s2,1b84 <core_list_mergesort+0x2b4>
    19fa:	00793023          	sd	t2,0(s2)
    19fe:	891e                	mv	s2,t2
    1a00:	f80988e3          	beqz	s3,1990 <core_list_mergesort+0xc0>
    1a04:	0009be03          	ld	t3,0(s3)
    1a08:	3d7d                	addiw	s10,s10,-1
    1a0a:	14090763          	beqz	s2,1b58 <core_list_mergesort+0x288>
    1a0e:	01393023          	sd	s3,0(s2)
    1a12:	894e                	mv	s2,s3
    1a14:	f60e0ee3          	beqz	t3,1990 <core_list_mergesort+0xc0>
    1a18:	89f2                	mv	s3,t3
    1a1a:	0009be83          	ld	t4,0(s3)
    1a1e:	3d7d                	addiw	s10,s10,-1
    1a20:	12090a63          	beqz	s2,1b54 <core_list_mergesort+0x284>
    1a24:	01393023          	sd	s3,0(s2)
    1a28:	894e                	mv	s2,s3
    1a2a:	f60e83e3          	beqz	t4,1990 <core_list_mergesort+0xc0>
    1a2e:	89f6                	mv	s3,t4
    1a30:	0009bf03          	ld	t5,0(s3)
    1a34:	3d7d                	addiw	s10,s10,-1
    1a36:	10090d63          	beqz	s2,1b50 <core_list_mergesort+0x280>
    1a3a:	01393023          	sd	s3,0(s2)
    1a3e:	894e                	mv	s2,s3
    1a40:	f40f08e3          	beqz	t5,1990 <core_list_mergesort+0xc0>
    1a44:	89fa                	mv	s3,t5
    1a46:	0009bf83          	ld	t6,0(s3)
    1a4a:	3d7d                	addiw	s10,s10,-1
    1a4c:	10090063          	beqz	s2,1b4c <core_list_mergesort+0x27c>
    1a50:	01393023          	sd	s3,0(s2)
    1a54:	894e                	mv	s2,s3
    1a56:	f20f8de3          	beqz	t6,1990 <core_list_mergesort+0xc0>
    1a5a:	89fe                	mv	s3,t6
    1a5c:	0009b783          	ld	a5,0(s3)
    1a60:	3d7d                	addiw	s10,s10,-1
    1a62:	0e090363          	beqz	s2,1b48 <core_list_mergesort+0x278>
    1a66:	01393023          	sd	s3,0(s2)
    1a6a:	894e                	mv	s2,s3
    1a6c:	d395                	beqz	a5,1990 <core_list_mergesort+0xc0>
    1a6e:	89be                	mv	s3,a5
    1a70:	0009b283          	ld	t0,0(s3)
    1a74:	3d7d                	addiw	s10,s10,-1
    1a76:	0a090163          	beqz	s2,1b18 <core_list_mergesort+0x248>
    1a7a:	01393023          	sd	s3,0(s2)
    1a7e:	0a0d0063          	beqz	s10,1b1e <core_list_mergesort+0x24e>
    1a82:	894e                	mv	s2,s3
    1a84:	f00286e3          	beqz	t0,1990 <core_list_mergesort+0xc0>
    1a88:	0002b303          	ld	t1,0(t0)
    1a8c:	fffd049b          	addiw	s1,s10,-1
    1a90:	08098c63          	beqz	s3,1b28 <core_list_mergesort+0x258>
    1a94:	0059b023          	sd	t0,0(s3)
    1a98:	8916                	mv	s2,t0
    1a9a:	ee030be3          	beqz	t1,1990 <core_list_mergesort+0xc0>
    1a9e:	00033683          	ld	a3,0(t1)
    1aa2:	fff4899b          	addiw	s3,s1,-1
    1aa6:	08028363          	beqz	t0,1b2c <core_list_mergesort+0x25c>
    1aaa:	0062b023          	sd	t1,0(t0)
    1aae:	891a                	mv	s2,t1
    1ab0:	ee0680e3          	beqz	a3,1990 <core_list_mergesort+0xc0>
    1ab4:	6290                	ld	a2,0(a3)
    1ab6:	fff9839b          	addiw	t2,s3,-1
    1aba:	06030b63          	beqz	t1,1b30 <core_list_mergesort+0x260>
    1abe:	00d33023          	sd	a3,0(t1)
    1ac2:	8936                	mv	s2,a3
    1ac4:	ec0606e3          	beqz	a2,1990 <core_list_mergesort+0xc0>
    1ac8:	6218                	ld	a4,0(a2)
    1aca:	fff3841b          	addiw	s0,t2,-1
    1ace:	c2bd                	beqz	a3,1b34 <core_list_mergesort+0x264>
    1ad0:	e290                	sd	a2,0(a3)
    1ad2:	8932                	mv	s2,a2
    1ad4:	ea070ee3          	beqz	a4,1990 <core_list_mergesort+0xc0>
    1ad8:	630c                	ld	a1,0(a4)
    1ada:	fff4051b          	addiw	a0,s0,-1
    1ade:	ce29                	beqz	a2,1b38 <core_list_mergesort+0x268>
    1ae0:	e218                	sd	a4,0(a2)
    1ae2:	893a                	mv	s2,a4
    1ae4:	ea0586e3          	beqz	a1,1990 <core_list_mergesort+0xc0>
    1ae8:	0005b883          	ld	a7,0(a1)
    1aec:	fff5081b          	addiw	a6,a0,-1
    1af0:	c731                	beqz	a4,1b3c <core_list_mergesort+0x26c>
    1af2:	e30c                	sd	a1,0(a4)
    1af4:	892e                	mv	s2,a1
    1af6:	e8088de3          	beqz	a7,1990 <core_list_mergesort+0xc0>
    1afa:	0008b983          	ld	s3,0(a7)
    1afe:	fff80d1b          	addiw	s10,a6,-1
    1b02:	cd9d                	beqz	a1,1b40 <core_list_mergesort+0x270>
    1b04:	0115b023          	sd	a7,0(a1)
    1b08:	8946                	mv	s2,a7
    1b0a:	e80983e3          	beqz	s3,1990 <core_list_mergesort+0xc0>
    1b0e:	0009b283          	ld	t0,0(s3)
    1b12:	3d7d                	addiw	s10,s10,-1
    1b14:	f60913e3          	bnez	s2,1a7a <core_list_mergesort+0x1aa>
    1b18:	8ace                	mv	s5,s3
    1b1a:	f60d14e3          	bnez	s10,1a82 <core_list_mergesort+0x1b2>
    1b1e:	84ce                	mv	s1,s3
    1b20:	8996                	mv	s3,t0
    1b22:	dc099fe3          	bnez	s3,1900 <core_list_mergesort+0x30>
    1b26:	b5a5                	j	198e <core_list_mergesort+0xbe>
    1b28:	8a96                	mv	s5,t0
    1b2a:	b7bd                	j	1a98 <core_list_mergesort+0x1c8>
    1b2c:	8a9a                	mv	s5,t1
    1b2e:	b741                	j	1aae <core_list_mergesort+0x1de>
    1b30:	8ab6                	mv	s5,a3
    1b32:	bf41                	j	1ac2 <core_list_mergesort+0x1f2>
    1b34:	8ab2                	mv	s5,a2
    1b36:	bf71                	j	1ad2 <core_list_mergesort+0x202>
    1b38:	8aba                	mv	s5,a4
    1b3a:	b765                	j	1ae2 <core_list_mergesort+0x212>
    1b3c:	8aae                	mv	s5,a1
    1b3e:	bf5d                	j	1af4 <core_list_mergesort+0x224>
    1b40:	8ac6                	mv	s5,a7
    1b42:	b7d9                	j	1b08 <core_list_mergesort+0x238>
    1b44:	8ace                	mv	s5,s3
    1b46:	bdad                	j	19c0 <core_list_mergesort+0xf0>
    1b48:	8ace                	mv	s5,s3
    1b4a:	b705                	j	1a6a <core_list_mergesort+0x19a>
    1b4c:	8ace                	mv	s5,s3
    1b4e:	b719                	j	1a54 <core_list_mergesort+0x184>
    1b50:	8ace                	mv	s5,s3
    1b52:	b5f5                	j	1a3e <core_list_mergesort+0x16e>
    1b54:	8ace                	mv	s5,s3
    1b56:	bdc9                	j	1a28 <core_list_mergesort+0x158>
    1b58:	8ace                	mv	s5,s3
    1b5a:	bd65                	j	1a12 <core_list_mergesort+0x142>
    1b5c:	6446                	ld	s0,80(sp)
    1b5e:	60e6                	ld	ra,88(sp)
    1b60:	6906                	ld	s2,64(sp)
    1b62:	64a6                	ld	s1,72(sp)
    1b64:	ff314a0b          	th.ldd	s4,s3,(sp),3,4
    1b68:	fb714c0b          	th.ldd	s8,s7,(sp),1,4
    1b6c:	f9914d0b          	th.ldd	s10,s9,(sp),0,4
    1b70:	8556                	mv	a0,s5
    1b72:	fd514b0b          	th.ldd	s6,s5,(sp),2,4
    1b76:	6125                	addi	sp,sp,96
    1b78:	8082                	ret
    1b7a:	84ca                	mv	s1,s2
    1b7c:	d80992e3          	bnez	s3,1900 <core_list_mergesort+0x30>
    1b80:	b539                	j	198e <core_list_mergesort+0xbe>
    1b82:	0001                	nop
    1b84:	8a9e                	mv	s5,t2
    1b86:	bda5                	j	19fe <core_list_mergesort+0x12e>
	...

0000000000001b90 <matrix_test>:
    1b90:	7139                	addi	sp,sp,-64
    1b92:	e852                	sd	s4,16(sp)
    1b94:	fc06                	sd	ra,56(sp)
    1b96:	7a7d                	lui	s4,0xfffff
    1b98:	01476a33          	or	s4,a4,s4
    1b9c:	5c0502e3          	beqz	a0,2960 <matrix_test+0xdd0>
    1ba0:	882a                	mv	a6,a0
    1ba2:	ec4e                	sd	s3,24(sp)
    1ba4:	f04a                	sd	s2,32(sp)
    1ba6:	f426                	sd	s1,40(sp)
    1ba8:	f822                	sd	s0,48(sp)
    1baa:	e05a                	sd	s6,0(sp)
    1bac:	e456                	sd	s5,8(sp)
    1bae:	892e                	mv	s2,a1
    1bb0:	89b6                	mv	s3,a3
    1bb2:	3c073a8b          	th.extu	s5,a4,15,0
    1bb6:	86ba                	mv	a3,a4
    1bb8:	4501                	li	a0,0
    1bba:	84b2                	mv	s1,a2
    1bbc:	85c2                	mv	a1,a6
    1bbe:	4701                	li	a4,0
    1bc0:	40a58633          	sub	a2,a1,a0
    1bc4:	00767293          	andi	t0,a2,7
    1bc8:	87aa                	mv	a5,a0
    1bca:	08028863          	beqz	t0,1c5a <matrix_test+0xca>
    1bce:	4885                	li	a7,1
    1bd0:	07128c63          	beq	t0,a7,1c48 <matrix_test+0xb8>
    1bd4:	4309                	li	t1,2
    1bd6:	06628263          	beq	t0,t1,1c3a <matrix_test+0xaa>
    1bda:	438d                	li	t2,3
    1bdc:	04728863          	beq	t0,t2,1c2c <matrix_test+0x9c>
    1be0:	4411                	li	s0,4
    1be2:	02828e63          	beq	t0,s0,1c1e <matrix_test+0x8e>
    1be6:	4b15                	li	s6,5
    1be8:	03628463          	beq	t0,s6,1c10 <matrix_test+0x80>
    1bec:	4e19                	li	t3,6
    1bee:	01c28a63          	beq	t0,t3,1c02 <matrix_test+0x72>
    1bf2:	b2a4c78b          	th.lurhu	a5,s1,a0,1
    1bf6:	01578ebb          	addw	t4,a5,s5
    1bfa:	32a4de8b          	th.surh	t4,s1,a0,1
    1bfe:	0015079b          	addiw	a5,a0,1
    1c02:	b2f4cf0b          	th.lurhu	t5,s1,a5,1
    1c06:	015f0fbb          	addw	t6,t5,s5
    1c0a:	32f4df8b          	th.surh	t6,s1,a5,1
    1c0e:	2785                	addiw	a5,a5,1
    1c10:	b2f4c60b          	th.lurhu	a2,s1,a5,1
    1c14:	015602bb          	addw	t0,a2,s5
    1c18:	32f4d28b          	th.surh	t0,s1,a5,1
    1c1c:	2785                	addiw	a5,a5,1
    1c1e:	b2f4c88b          	th.lurhu	a7,s1,a5,1
    1c22:	0158833b          	addw	t1,a7,s5
    1c26:	32f4d30b          	th.surh	t1,s1,a5,1
    1c2a:	2785                	addiw	a5,a5,1
    1c2c:	b2f4c38b          	th.lurhu	t2,s1,a5,1
    1c30:	0153843b          	addw	s0,t2,s5
    1c34:	32f4d40b          	th.surh	s0,s1,a5,1
    1c38:	2785                	addiw	a5,a5,1
    1c3a:	b2f4cb0b          	th.lurhu	s6,s1,a5,1
    1c3e:	015b0e3b          	addw	t3,s6,s5
    1c42:	32f4de0b          	th.surh	t3,s1,a5,1
    1c46:	2785                	addiw	a5,a5,1
    1c48:	b2f4ce8b          	th.lurhu	t4,s1,a5,1
    1c4c:	015e8f3b          	addw	t5,t4,s5
    1c50:	32f4df0b          	th.surh	t5,s1,a5,1
    1c54:	2785                	addiw	a5,a5,1
    1c56:	08f58363          	beq	a1,a5,1cdc <matrix_test+0x14c>
    1c5a:	b2f4c40b          	th.lurhu	s0,s1,a5,1
    1c5e:	0017889b          	addiw	a7,a5,1
    1c62:	0018839b          	addiw	t2,a7,1
    1c66:	01540b3b          	addw	s6,s0,s5
    1c6a:	32f4db0b          	th.surh	s6,s1,a5,1
    1c6e:	b314c30b          	th.lurhu	t1,s1,a7,1
    1c72:	0013879b          	addiw	a5,t2,1
    1c76:	00178f9b          	addiw	t6,a5,1
    1c7a:	01530e3b          	addw	t3,t1,s5
    1c7e:	3314de0b          	th.surh	t3,s1,a7,1
    1c82:	b274cf0b          	th.lurhu	t5,s1,t2,1
    1c86:	001f889b          	addiw	a7,t6,1
    1c8a:	015f063b          	addw	a2,t5,s5
    1c8e:	3274d60b          	th.surh	a2,s1,t2,1
    1c92:	b2f4ce8b          	th.lurhu	t4,s1,a5,1
    1c96:	0018839b          	addiw	t2,a7,1
    1c9a:	015e82bb          	addw	t0,t4,s5
    1c9e:	32f4d28b          	th.surh	t0,s1,a5,1
    1ca2:	b3f4c40b          	th.lurhu	s0,s1,t6,1
    1ca6:	0013879b          	addiw	a5,t2,1
    1caa:	01540b3b          	addw	s6,s0,s5
    1cae:	33f4db0b          	th.surh	s6,s1,t6,1
    1cb2:	b314c30b          	th.lurhu	t1,s1,a7,1
    1cb6:	01530e3b          	addw	t3,t1,s5
    1cba:	3314de0b          	th.surh	t3,s1,a7,1
    1cbe:	b274cf0b          	th.lurhu	t5,s1,t2,1
    1cc2:	015f063b          	addw	a2,t5,s5
    1cc6:	3274d60b          	th.surh	a2,s1,t2,1
    1cca:	b2f4ce8b          	th.lurhu	t4,s1,a5,1
    1cce:	015e8f3b          	addw	t5,t4,s5
    1cd2:	32f4df0b          	th.surh	t5,s1,a5,1
    1cd6:	2785                	addiw	a5,a5,1
    1cd8:	f8f591e3          	bne	a1,a5,1c5a <matrix_test+0xca>
    1cdc:	0017041b          	addiw	s0,a4,1
    1ce0:	8b22                	mv	s6,s0
    1ce2:	00a8053b          	addw	a0,a6,a0
    1ce6:	00b805bb          	addw	a1,a6,a1
    1cea:	00880463          	beq	a6,s0,1cf2 <matrix_test+0x162>
    1cee:	8722                	mv	a4,s0
    1cf0:	bdc1                	j	1bc0 <matrix_test+0x30>
    1cf2:	85a2                	mv	a1,s0
    1cf4:	4501                	li	a0,0
    1cf6:	4801                	li	a6,0
    1cf8:	40a58fb3          	sub	t6,a1,a0
    1cfc:	007ff613          	andi	a2,t6,7
    1d00:	87aa                	mv	a5,a0
    1d02:	c659                	beqz	a2,1d90 <matrix_test+0x200>
    1d04:	4285                	li	t0,1
    1d06:	06560c63          	beq	a2,t0,1d7e <matrix_test+0x1ee>
    1d0a:	4889                	li	a7,2
    1d0c:	07160263          	beq	a2,a7,1d70 <matrix_test+0x1e0>
    1d10:	430d                	li	t1,3
    1d12:	04660863          	beq	a2,t1,1d62 <matrix_test+0x1d2>
    1d16:	4391                	li	t2,4
    1d18:	02760e63          	beq	a2,t2,1d54 <matrix_test+0x1c4>
    1d1c:	4e15                	li	t3,5
    1d1e:	03c60463          	beq	a2,t3,1d46 <matrix_test+0x1b6>
    1d22:	4e99                	li	t4,6
    1d24:	01d60a63          	beq	a2,t4,1d38 <matrix_test+0x1a8>
    1d28:	32a4cf0b          	th.lurh	t5,s1,a0,1
    1d2c:	02df07bb          	mulw	a5,t5,a3
    1d30:	54a9578b          	th.surw	a5,s2,a0,2
    1d34:	0015079b          	addiw	a5,a0,1
    1d38:	32f4cf8b          	th.lurh	t6,s1,a5,1
    1d3c:	02df863b          	mulw	a2,t6,a3
    1d40:	54f9560b          	th.surw	a2,s2,a5,2
    1d44:	2785                	addiw	a5,a5,1
    1d46:	32f4c28b          	th.lurh	t0,s1,a5,1
    1d4a:	02d288bb          	mulw	a7,t0,a3
    1d4e:	54f9588b          	th.surw	a7,s2,a5,2
    1d52:	2785                	addiw	a5,a5,1
    1d54:	32f4c30b          	th.lurh	t1,s1,a5,1
    1d58:	02d303bb          	mulw	t2,t1,a3
    1d5c:	54f9538b          	th.surw	t2,s2,a5,2
    1d60:	2785                	addiw	a5,a5,1
    1d62:	32f4ce0b          	th.lurh	t3,s1,a5,1
    1d66:	02de0ebb          	mulw	t4,t3,a3
    1d6a:	54f95e8b          	th.surw	t4,s2,a5,2
    1d6e:	2785                	addiw	a5,a5,1
    1d70:	32f4cf0b          	th.lurh	t5,s1,a5,1
    1d74:	02df0fbb          	mulw	t6,t5,a3
    1d78:	54f95f8b          	th.surw	t6,s2,a5,2
    1d7c:	2785                	addiw	a5,a5,1
    1d7e:	32f4c60b          	th.lurh	a2,s1,a5,1
    1d82:	02d602bb          	mulw	t0,a2,a3
    1d86:	54f9528b          	th.surw	t0,s2,a5,2
    1d8a:	2785                	addiw	a5,a5,1
    1d8c:	08f58363          	beq	a1,a5,1e12 <matrix_test+0x282>
    1d90:	32f4c88b          	th.lurh	a7,s1,a5,1
    1d94:	00178e1b          	addiw	t3,a5,1
    1d98:	33c4c38b          	th.lurh	t2,s1,t3,1
    1d9c:	02d8833b          	mulw	t1,a7,a3
    1da0:	001e0f1b          	addiw	t5,t3,1
    1da4:	02d3863b          	mulw	a2,t2,a3
    1da8:	001f029b          	addiw	t0,t5,1
    1dac:	54f9530b          	th.surw	t1,s2,a5,2
    1db0:	33e4c78b          	th.lurh	a5,s1,t5,1
    1db4:	3254cf8b          	th.lurh	t6,s1,t0,1
    1db8:	55c9560b          	th.surw	a2,s2,t3,2
    1dbc:	02d78ebb          	mulw	t4,a5,a3
    1dc0:	0012831b          	addiw	t1,t0,1
    1dc4:	3264ce0b          	th.lurh	t3,s1,t1,1
    1dc8:	02df88bb          	mulw	a7,t6,a3
    1dcc:	55e95e8b          	th.surw	t4,s2,t5,2
    1dd0:	00130f1b          	addiw	t5,t1,1
    1dd4:	33e4c60b          	th.lurh	a2,s1,t5,1
    1dd8:	02de03bb          	mulw	t2,t3,a3
    1ddc:	5459588b          	th.surw	a7,s2,t0,2
    1de0:	02d607bb          	mulw	a5,a2,a3
    1de4:	001f0e9b          	addiw	t4,t5,1
    1de8:	5469538b          	th.surw	t2,s2,t1,2
    1dec:	33d4c28b          	th.lurh	t0,s1,t4,1
    1df0:	55e9578b          	th.surw	a5,s2,t5,2
    1df4:	001e879b          	addiw	a5,t4,1
    1df8:	32f4c60b          	th.lurh	a2,s1,a5,1
    1dfc:	02d28fbb          	mulw	t6,t0,a3
    1e00:	02d602bb          	mulw	t0,a2,a3
    1e04:	55d95f8b          	th.surw	t6,s2,t4,2
    1e08:	54f9528b          	th.surw	t0,s2,a5,2
    1e0c:	2785                	addiw	a5,a5,1
    1e0e:	f8f591e3          	bne	a1,a5,1d90 <matrix_test+0x200>
    1e12:	0018089b          	addiw	a7,a6,1
    1e16:	9d21                	addw	a0,a0,s0
    1e18:	9da1                	addw	a1,a1,s0
    1e1a:	00e80463          	beq	a6,a4,1e22 <matrix_test+0x292>
    1e1e:	8846                	mv	a6,a7
    1e20:	bde1                	j	1cf8 <matrix_test+0x168>
    1e22:	8822                	mv	a6,s0
    1e24:	4881                	li	a7,0
    1e26:	4e81                	li	t4,0
    1e28:	4681                	li	a3,0
    1e2a:	4501                	li	a0,0
    1e2c:	4301                	li	t1,0
    1e2e:	0001                	nop
    1e30:	411803b3          	sub	t2,a6,a7
    1e34:	0033fe13          	andi	t3,t2,3
    1e38:	8646                	mv	a2,a7
    1e3a:	060e0563          	beqz	t3,1ea4 <matrix_test+0x314>
    1e3e:	4f05                	li	t5,1
    1e40:	05ee0263          	beq	t3,t5,1e84 <matrix_test+0x2f4>
    1e44:	4f89                	li	t6,2
    1e46:	03fe0163          	beq	t3,t6,1e68 <matrix_test+0x2d8>
    1e4a:	8676                	mv	a2,t4
    1e4c:	55194e8b          	th.lurw	t4,s2,a7,2
    1e50:	00de86bb          	addw	a3,t4,a3
    1e54:	12da4763          	blt	s4,a3,1f82 <matrix_test+0x3f2>
    1e58:	01d622b3          	slt	t0,a2,t4
    1e5c:	00a287bb          	addw	a5,t0,a0
    1e60:	3c07a50b          	th.ext	a0,a5,15,0
    1e64:	0018861b          	addiw	a2,a7,1
    1e68:	85f6                	mv	a1,t4
    1e6a:	54c94e8b          	th.lurw	t4,s2,a2,2
    1e6e:	00de86bb          	addw	a3,t4,a3
    1e72:	10da4263          	blt	s4,a3,1f76 <matrix_test+0x3e6>
    1e76:	01d5a3b3          	slt	t2,a1,t4
    1e7a:	00a3853b          	addw	a0,t2,a0
    1e7e:	3c05250b          	th.ext	a0,a0,15,0
    1e82:	2605                	addiw	a2,a2,1
    1e84:	8f76                	mv	t5,t4
    1e86:	54c94e8b          	th.lurw	t4,s2,a2,2
    1e8a:	00de86bb          	addw	a3,t4,a3
    1e8e:	0cda4e63          	blt	s4,a3,1f6a <matrix_test+0x3da>
    1e92:	01df2fb3          	slt	t6,t5,t4
    1e96:	00af82bb          	addw	t0,t6,a0
    1e9a:	3c02a50b          	th.ext	a0,t0,15,0
    1e9e:	2605                	addiw	a2,a2,1
    1ea0:	06c80963          	beq	a6,a2,1f12 <matrix_test+0x382>
    1ea4:	54c9428b          	th.lurw	t0,s2,a2,2
    1ea8:	00d28fbb          	addw	t6,t0,a3
    1eac:	0bfa5863          	bge	s4,t6,1f5c <matrix_test+0x3cc>
    1eb0:	00a50e1b          	addiw	t3,a0,10
    1eb4:	3c0e2e8b          	th.ext	t4,t3,15,0
    1eb8:	4f81                	li	t6,0
    1eba:	0016039b          	addiw	t2,a2,1
    1ebe:	54794f0b          	th.lurw	t5,s2,t2,2
    1ec2:	01ff0fbb          	addw	t6,t5,t6
    1ec6:	07fa5763          	bge	s4,t6,1f34 <matrix_test+0x3a4>
    1eca:	00ae869b          	addiw	a3,t4,10
    1ece:	00138e9b          	addiw	t4,t2,1
    1ed2:	55d94e0b          	th.lurw	t3,s2,t4,2
    1ed6:	4f81                	li	t6,0
    1ed8:	3c06a28b          	th.ext	t0,a3,15,0
    1edc:	01fe06bb          	addw	a3,t3,t6
    1ee0:	06da4863          	blt	s4,a3,1f50 <matrix_test+0x3c0>
    1ee4:	01cf23b3          	slt	t2,t5,t3
    1ee8:	0053863b          	addw	a2,t2,t0
    1eec:	3c06278b          	th.ext	a5,a2,15,0
    1ef0:	001e861b          	addiw	a2,t4,1
    1ef4:	54c94e8b          	th.lurw	t4,s2,a2,2
    1ef8:	00de86bb          	addw	a3,t4,a3
    1efc:	02da4663          	blt	s4,a3,1f28 <matrix_test+0x398>
    1f00:	01de22b3          	slt	t0,t3,t4
    1f04:	00f28fbb          	addw	t6,t0,a5
    1f08:	2605                	addiw	a2,a2,1
    1f0a:	3c0fa50b          	th.ext	a0,t6,15,0
    1f0e:	f8c81be3          	bne	a6,a2,1ea4 <matrix_test+0x314>
    1f12:	0013059b          	addiw	a1,t1,1
    1f16:	0104083b          	addw	a6,s0,a6
    1f1a:	011408bb          	addw	a7,s0,a7
    1f1e:	06e30863          	beq	t1,a4,1f8e <matrix_test+0x3fe>
    1f22:	832e                	mv	t1,a1
    1f24:	b731                	j	1e30 <matrix_test+0x2a0>
    1f26:	0001                	nop
    1f28:	00a7859b          	addiw	a1,a5,10
    1f2c:	3c05a50b          	th.ext	a0,a1,15,0
    1f30:	4681                	li	a3,0
    1f32:	b7b5                	j	1e9e <matrix_test+0x30e>
    1f34:	01e2a7b3          	slt	a5,t0,t5
    1f38:	01d7853b          	addw	a0,a5,t4
    1f3c:	00138e9b          	addiw	t4,t2,1
    1f40:	55d94e0b          	th.lurw	t3,s2,t4,2
    1f44:	3c05228b          	th.ext	t0,a0,15,0
    1f48:	01fe06bb          	addw	a3,t3,t6
    1f4c:	f8da5ce3          	bge	s4,a3,1ee4 <matrix_test+0x354>
    1f50:	00a28f1b          	addiw	t5,t0,10
    1f54:	3c0f278b          	th.ext	a5,t5,15,0
    1f58:	4681                	li	a3,0
    1f5a:	bf59                	j	1ef0 <matrix_test+0x360>
    1f5c:	005ea5b3          	slt	a1,t4,t0
    1f60:	00a58f3b          	addw	t5,a1,a0
    1f64:	3c0f2e8b          	th.ext	t4,t5,15,0
    1f68:	bf89                	j	1eba <matrix_test+0x32a>
    1f6a:	00a5079b          	addiw	a5,a0,10
    1f6e:	3c07a50b          	th.ext	a0,a5,15,0
    1f72:	4681                	li	a3,0
    1f74:	b72d                	j	1e9e <matrix_test+0x30e>
    1f76:	00a50e1b          	addiw	t3,a0,10
    1f7a:	3c0e250b          	th.ext	a0,t3,15,0
    1f7e:	4681                	li	a3,0
    1f80:	b709                	j	1e82 <matrix_test+0x2f2>
    1f82:	00a5069b          	addiw	a3,a0,10
    1f86:	3c06a50b          	th.ext	a0,a3,15,0
    1f8a:	4681                	li	a3,0
    1f8c:	bde1                	j	1e64 <matrix_test+0x2d4>
    1f8e:	4581                	li	a1,0
    1f90:	061020ef          	jal	47f0 <crc16>
    1f94:	85aa                	mv	a1,a0
    1f96:	7c0b3b0b          	th.extu	s6,s6,31,0
    1f9a:	4601                	li	a2,0
    1f9c:	4501                	li	a0,0
    1f9e:	0001                	nop
    1fa0:	007b7313          	andi	t1,s6,7
    1fa4:	4701                	li	a4,0
    1fa6:	4681                	li	a3,0
    1fa8:	0a030763          	beqz	t1,2056 <matrix_test+0x4c6>
    1fac:	4e85                	li	t4,1
    1fae:	09d30663          	beq	t1,t4,203a <matrix_test+0x4aa>
    1fb2:	4389                	li	t2,2
    1fb4:	06730a63          	beq	t1,t2,2028 <matrix_test+0x498>
    1fb8:	4e0d                	li	t3,3
    1fba:	05c30e63          	beq	t1,t3,2016 <matrix_test+0x486>
    1fbe:	4f11                	li	t5,4
    1fc0:	05e30263          	beq	t1,t5,2004 <matrix_test+0x474>
    1fc4:	4f95                	li	t6,5
    1fc6:	03f30663          	beq	t1,t6,1ff2 <matrix_test+0x462>
    1fca:	4299                	li	t0,6
    1fcc:	00530a63          	beq	t1,t0,1fe0 <matrix_test+0x450>
    1fd0:	b2c4c80b          	th.lurhu	a6,s1,a2,1
    1fd4:	0009d783          	lhu	a5,0(s3)
    1fd8:	86ba                	mv	a3,a4
    1fda:	8776                	mv	a4,t4
    1fdc:	28f8168b          	th.mulah	a3,a6,a5
    1fe0:	00c708bb          	addw	a7,a4,a2
    1fe4:	a2e9ce8b          	th.lrhu	t4,s3,a4,1
    1fe8:	b314c30b          	th.lurhu	t1,s1,a7,1
    1fec:	0705                	addi	a4,a4,1
    1fee:	29d3168b          	th.mulah	a3,t1,t4
    1ff2:	00c703bb          	addw	t2,a4,a2
    1ff6:	a2e9cf0b          	th.lrhu	t5,s3,a4,1
    1ffa:	b274ce0b          	th.lurhu	t3,s1,t2,1
    1ffe:	0705                	addi	a4,a4,1
    2000:	29ee168b          	th.mulah	a3,t3,t5
    2004:	00c70fbb          	addw	t6,a4,a2
    2008:	a2e9c80b          	th.lrhu	a6,s3,a4,1
    200c:	b3f4c28b          	th.lurhu	t0,s1,t6,1
    2010:	0705                	addi	a4,a4,1
    2012:	2902968b          	th.mulah	a3,t0,a6
    2016:	00c707bb          	addw	a5,a4,a2
    201a:	a2e9c30b          	th.lrhu	t1,s3,a4,1
    201e:	b2f4c88b          	th.lurhu	a7,s1,a5,1
    2022:	0705                	addi	a4,a4,1
    2024:	2868968b          	th.mulah	a3,a7,t1
    2028:	00c70ebb          	addw	t4,a4,a2
    202c:	a2e9ce0b          	th.lrhu	t3,s3,a4,1
    2030:	b3d4c38b          	th.lurhu	t2,s1,t4,1
    2034:	0705                	addi	a4,a4,1
    2036:	29c3968b          	th.mulah	a3,t2,t3
    203a:	00c70f3b          	addw	t5,a4,a2
    203e:	a2e9c28b          	th.lrhu	t0,s3,a4,1
    2042:	b3e4cf8b          	th.lurhu	t6,s1,t5,1
    2046:	87b6                	mv	a5,a3
    2048:	883a                	mv	a6,a4
    204a:	285f978b          	th.mulah	a5,t6,t0
    204e:	0705                	addi	a4,a4,1
    2050:	86be                	mv	a3,a5
    2052:	0aeb0563          	beq	s6,a4,20fc <matrix_test+0x56c>
    2056:	00c708bb          	addw	a7,a4,a2
    205a:	b314c30b          	th.lurhu	t1,s1,a7,1
    205e:	a2e9ce8b          	th.lrhu	t4,s3,a4,1
    2062:	00170393          	addi	t2,a4,1
    2066:	87b6                	mv	a5,a3
    2068:	29d3178b          	th.mulah	a5,t1,t4
    206c:	00c38e3b          	addw	t3,t2,a2
    2070:	b3c4cf0b          	th.lurhu	t5,s1,t3,1
    2074:	a279cf8b          	th.lrhu	t6,s3,t2,1
    2078:	00270293          	addi	t0,a4,2
    207c:	00c286bb          	addw	a3,t0,a2
    2080:	29ff178b          	th.mulah	a5,t5,t6
    2084:	b2d4c80b          	th.lurhu	a6,s1,a3,1
    2088:	a259c88b          	th.lrhu	a7,s3,t0,1
    208c:	00370313          	addi	t1,a4,3
    2090:	00c30ebb          	addw	t4,t1,a2
    2094:	2918178b          	th.mulah	a5,a6,a7
    2098:	b3d4c38b          	th.lurhu	t2,s1,t4,1
    209c:	a269ce0b          	th.lrhu	t3,s3,t1,1
    20a0:	00470f13          	addi	t5,a4,4
    20a4:	00cf0fbb          	addw	t6,t5,a2
    20a8:	29c3978b          	th.mulah	a5,t2,t3
    20ac:	b3f4c28b          	th.lurhu	t0,s1,t6,1
    20b0:	a3e9c68b          	th.lrhu	a3,s3,t5,1
    20b4:	00570893          	addi	a7,a4,5
    20b8:	00c8883b          	addw	a6,a7,a2
    20bc:	28d2978b          	th.mulah	a5,t0,a3
    20c0:	b304c30b          	th.lurhu	t1,s1,a6,1
    20c4:	a319ce8b          	th.lrhu	t4,s3,a7,1
    20c8:	00670393          	addi	t2,a4,6
    20cc:	00c38e3b          	addw	t3,t2,a2
    20d0:	29d3178b          	th.mulah	a5,t1,t4
    20d4:	b3c4cf0b          	th.lurhu	t5,s1,t3,1
    20d8:	a279cf8b          	th.lrhu	t6,s3,t2,1
    20dc:	00770813          	addi	a6,a4,7
    20e0:	00c802bb          	addw	t0,a6,a2
    20e4:	29ff178b          	th.mulah	a5,t5,t6
    20e8:	a309c68b          	th.lrhu	a3,s3,a6,1
    20ec:	b254c88b          	th.lurhu	a7,s1,t0,1
    20f0:	0721                	addi	a4,a4,8
    20f2:	28d8978b          	th.mulah	a5,a7,a3
    20f6:	86be                	mv	a3,a5
    20f8:	f4eb1fe3          	bne	s6,a4,2056 <matrix_test+0x4c6>
    20fc:	44a9578b          	th.srw	a5,s2,a0,2
    2100:	9e21                	addw	a2,a2,s0
    2102:	00150793          	addi	a5,a0,1
    2106:	01050463          	beq	a0,a6,210e <matrix_test+0x57e>
    210a:	853e                	mv	a0,a5
    210c:	bd51                	j	1fa0 <matrix_test+0x410>
    210e:	4601                	li	a2,0
    2110:	4881                	li	a7,0
    2112:	4701                	li	a4,0
    2114:	4501                	li	a0,0
    2116:	4801                	li	a6,0
    2118:	8346                	mv	t1,a7
    211a:	54c9488b          	th.lurw	a7,s2,a2,2
    211e:	fff40b13          	addi	s6,s0,-1
    2122:	003b7e93          	andi	t4,s6,3
    2126:	00e8873b          	addw	a4,a7,a4
    212a:	7aea5063          	bge	s4,a4,28ca <matrix_test+0xd3a>
    212e:	00a5071b          	addiw	a4,a0,10
    2132:	3c07250b          	th.ext	a0,a4,15,0
    2136:	4701                	li	a4,0
    2138:	4685                	li	a3,1
    213a:	0e86f963          	bgeu	a3,s0,222c <matrix_test+0x69c>
    213e:	060e8963          	beqz	t4,21b0 <matrix_test+0x620>
    2142:	04de8563          	beq	t4,a3,218c <matrix_test+0x5fc>
    2146:	4e09                	li	t3,2
    2148:	03ce8263          	beq	t4,t3,216c <matrix_test+0x5dc>
    214c:	00160f9b          	addiw	t6,a2,1
    2150:	8f46                	mv	t5,a7
    2152:	55f9488b          	th.lurw	a7,s2,t6,2
    2156:	00e8873b          	addw	a4,a7,a4
    215a:	7eea4c63          	blt	s4,a4,2952 <matrix_test+0xdc2>
    215e:	011f22b3          	slt	t0,t5,a7
    2162:	00a287bb          	addw	a5,t0,a0
    2166:	3c07a50b          	th.ext	a0,a5,15,0
    216a:	2685                	addiw	a3,a3,1
    216c:	8ec6                	mv	t4,a7
    216e:	00c688bb          	addw	a7,a3,a2
    2172:	5519488b          	th.lurw	a7,s2,a7,2
    2176:	00e8873b          	addw	a4,a7,a4
    217a:	7aea4563          	blt	s4,a4,2924 <matrix_test+0xd94>
    217e:	011ea333          	slt	t1,t4,a7
    2182:	00a303bb          	addw	t2,t1,a0
    2186:	3c03a50b          	th.ext	a0,t2,15,0
    218a:	2685                	addiw	a3,a3,1
    218c:	00c68f3b          	addw	t5,a3,a2
    2190:	8e46                	mv	t3,a7
    2192:	55e9488b          	th.lurw	a7,s2,t5,2
    2196:	00e8873b          	addw	a4,a7,a4
    219a:	76ea4363          	blt	s4,a4,2900 <matrix_test+0xd70>
    219e:	011e2fb3          	slt	t6,t3,a7
    21a2:	00af82bb          	addw	t0,t6,a0
    21a6:	3c02a50b          	th.ext	a0,t0,15,0
    21aa:	2685                	addiw	a3,a3,1
    21ac:	0886f063          	bgeu	a3,s0,222c <matrix_test+0x69c>
    21b0:	00c68b3b          	addw	s6,a3,a2
    21b4:	55694f8b          	th.lurw	t6,s2,s6,2
    21b8:	00ef82bb          	addw	t0,t6,a4
    21bc:	705a5063          	bge	s4,t0,28bc <matrix_test+0xd2c>
    21c0:	00a50e1b          	addiw	t3,a0,10
    21c4:	3c0e2e8b          	th.ext	t4,t3,15,0
    21c8:	4281                	li	t0,0
    21ca:	2685                	addiw	a3,a3,1
    21cc:	00c6833b          	addw	t1,a3,a2
    21d0:	5469488b          	th.lurw	a7,s2,t1,2
    21d4:	005882bb          	addw	t0,a7,t0
    21d8:	6c5a5a63          	bge	s4,t0,28ac <matrix_test+0xd1c>
    21dc:	00ae871b          	addiw	a4,t4,10
    21e0:	3c072b0b          	th.ext	s6,a4,15,0
    21e4:	4281                	li	t0,0
    21e6:	00168f9b          	addiw	t6,a3,1
    21ea:	00cf8f3b          	addw	t5,t6,a2
    21ee:	55e9450b          	th.lurw	a0,s2,t5,2
    21f2:	005507bb          	addw	a5,a0,t0
    21f6:	6afa4563          	blt	s4,a5,28a0 <matrix_test+0xd10>
    21fa:	00a8aeb3          	slt	t4,a7,a0
    21fe:	016e8e3b          	addw	t3,t4,s6
    2202:	3c0e230b          	th.ext	t1,t3,15,0
    2206:	001f869b          	addiw	a3,t6,1
    220a:	00c688bb          	addw	a7,a3,a2
    220e:	5519488b          	th.lurw	a7,s2,a7,2
    2212:	00f8873b          	addw	a4,a7,a5
    2216:	66ea4f63          	blt	s4,a4,2894 <matrix_test+0xd04>
    221a:	011523b3          	slt	t2,a0,a7
    221e:	00638b3b          	addw	s6,t2,t1
    2222:	2685                	addiw	a3,a3,1
    2224:	3c0b250b          	th.ext	a0,s6,15,0
    2228:	f886e4e3          	bltu	a3,s0,21b0 <matrix_test+0x620>
    222c:	2805                	addiw	a6,a6,1
    222e:	9e21                	addw	a2,a2,s0
    2230:	ee8864e3          	bltu	a6,s0,2118 <matrix_test+0x588>
    2234:	5bc020ef          	jal	47f0 <crc16>
    2238:	85aa                	mv	a1,a0
    223a:	4601                	li	a2,0
    223c:	4881                	li	a7,0
    223e:	0001                	nop
    2240:	4b01                	li	s6,0
    2242:	0001                	nop
    2244:	00000013          	nop
    2248:	b369c30b          	th.lurhu	t1,s3,s6,1
    224c:	b2c4ce8b          	th.lurhu	t4,s1,a2,1
    2250:	4f81                	li	t6,0
    2252:	fff40793          	addi	a5,s0,-1
    2256:	286e9f8b          	th.mulah	t6,t4,t1
    225a:	4705                	li	a4,1
    225c:	00cb083b          	addw	a6,s6,a2
    2260:	0037f393          	andi	t2,a5,3
    2264:	837e                	mv	t1,t6
    2266:	016406bb          	addw	a3,s0,s6
    226a:	0a877f63          	bgeu	a4,s0,2328 <matrix_test+0x798>
    226e:	04038963          	beqz	t2,22c0 <matrix_test+0x730>
    2272:	02e38963          	beq	t2,a4,22a4 <matrix_test+0x714>
    2276:	4f09                	li	t5,2
    2278:	01e38c63          	beq	t2,t5,2290 <matrix_test+0x700>
    227c:	00160e1b          	addiw	t3,a2,1
    2280:	b2d9c28b          	th.lurhu	t0,s3,a3,1
    2284:	b3c4cf8b          	th.lurhu	t6,s1,t3,1
    2288:	877a                	mv	a4,t5
    228a:	9ea1                	addw	a3,a3,s0
    228c:	285f930b          	th.mulah	t1,t6,t0
    2290:	00c707bb          	addw	a5,a4,a2
    2294:	b2d9ce8b          	th.lurhu	t4,s3,a3,1
    2298:	b2f4c38b          	th.lurhu	t2,s1,a5,1
    229c:	2705                	addiw	a4,a4,1
    229e:	9ea1                	addw	a3,a3,s0
    22a0:	29d3930b          	th.mulah	t1,t2,t4
    22a4:	00c7053b          	addw	a0,a4,a2
    22a8:	b2d9ce0b          	th.lurhu	t3,s3,a3,1
    22ac:	b2a4cf0b          	th.lurhu	t5,s1,a0,1
    22b0:	8f9a                	mv	t6,t1
    22b2:	2705                	addiw	a4,a4,1
    22b4:	29cf1f8b          	th.mulah	t6,t5,t3
    22b8:	9ea1                	addw	a3,a3,s0
    22ba:	837e                	mv	t1,t6
    22bc:	06877663          	bgeu	a4,s0,2328 <matrix_test+0x798>
    22c0:	00c702bb          	addw	t0,a4,a2
    22c4:	b254c78b          	th.lurhu	a5,s1,t0,1
    22c8:	b2d9c38b          	th.lurhu	t2,s3,a3,1
    22cc:	00170e9b          	addiw	t4,a4,1
    22d0:	8f9a                	mv	t6,t1
    22d2:	28779f8b          	th.mulah	t6,a5,t2
    22d6:	00d4053b          	addw	a0,s0,a3
    22da:	00ce8f3b          	addw	t5,t4,a2
    22de:	b3e4ce0b          	th.lurhu	t3,s1,t5,1
    22e2:	b2a9c30b          	th.lurhu	t1,s3,a0,1
    22e6:	001e871b          	addiw	a4,t4,1
    22ea:	008506bb          	addw	a3,a0,s0
    22ee:	286e1f8b          	th.mulah	t6,t3,t1
    22f2:	00c702bb          	addw	t0,a4,a2
    22f6:	b2d9c38b          	th.lurhu	t2,s3,a3,1
    22fa:	b254c78b          	th.lurhu	a5,s1,t0,1
    22fe:	00170e9b          	addiw	t4,a4,1
    2302:	0086853b          	addw	a0,a3,s0
    2306:	28779f8b          	th.mulah	t6,a5,t2
    230a:	00ce8f3b          	addw	t5,t4,a2
    230e:	b2a9c30b          	th.lurhu	t1,s3,a0,1
    2312:	b3e4ce0b          	th.lurhu	t3,s1,t5,1
    2316:	001e871b          	addiw	a4,t4,1
    231a:	008506bb          	addw	a3,a0,s0
    231e:	286e1f8b          	th.mulah	t6,t3,t1
    2322:	837e                	mv	t1,t6
    2324:	f8876ee3          	bltu	a4,s0,22c0 <matrix_test+0x730>
    2328:	55095f8b          	th.surw	t6,s2,a6,2
    232c:	2b05                	addiw	s6,s6,1
    232e:	f08b6de3          	bltu	s6,s0,2248 <matrix_test+0x6b8>
    2332:	2885                	addiw	a7,a7,1
    2334:	9e21                	addw	a2,a2,s0
    2336:	f088e5e3          	bltu	a7,s0,2240 <matrix_test+0x6b0>
    233a:	4b01                	li	s6,0
    233c:	4881                	li	a7,0
    233e:	4601                	li	a2,0
    2340:	4501                	li	a0,0
    2342:	4f81                	li	t6,0
    2344:	00000013          	nop
    2348:	86c6                	mv	a3,a7
    234a:	5569488b          	th.lurw	a7,s2,s6,2
    234e:	fff40813          	addi	a6,s0,-1
    2352:	00387293          	andi	t0,a6,3
    2356:	00c8863b          	addw	a2,a7,a2
    235a:	58ca5663          	bge	s4,a2,28e6 <matrix_test+0xd56>
    235e:	00a5071b          	addiw	a4,a0,10
    2362:	3c07250b          	th.ext	a0,a4,15,0
    2366:	4601                	li	a2,0
    2368:	4685                	li	a3,1
    236a:	0e86fa63          	bgeu	a3,s0,245e <matrix_test+0x8ce>
    236e:	06028963          	beqz	t0,23e0 <matrix_test+0x850>
    2372:	04d28563          	beq	t0,a3,23bc <matrix_test+0x82c>
    2376:	4e89                	li	t4,2
    2378:	03d28263          	beq	t0,t4,239c <matrix_test+0x80c>
    237c:	001b0e1b          	addiw	t3,s6,1
    2380:	8f46                	mv	t5,a7
    2382:	55c9488b          	th.lurw	a7,s2,t3,2
    2386:	00c8863b          	addw	a2,a7,a2
    238a:	5aca4863          	blt	s4,a2,293a <matrix_test+0xdaa>
    238e:	011f2333          	slt	t1,t5,a7
    2392:	00a3053b          	addw	a0,t1,a0
    2396:	3c05250b          	th.ext	a0,a0,15,0
    239a:	2685                	addiw	a3,a3,1
    239c:	8846                	mv	a6,a7
    239e:	016688bb          	addw	a7,a3,s6
    23a2:	5519488b          	th.lurw	a7,s2,a7,2
    23a6:	00c8863b          	addw	a2,a7,a2
    23aa:	58ca4263          	blt	s4,a2,292e <matrix_test+0xd9e>
    23ae:	011822b3          	slt	t0,a6,a7
    23b2:	00a287bb          	addw	a5,t0,a0
    23b6:	3c07a50b          	th.ext	a0,a5,15,0
    23ba:	2685                	addiw	a3,a3,1
    23bc:	01668f3b          	addw	t5,a3,s6
    23c0:	8ec6                	mv	t4,a7
    23c2:	55e9488b          	th.lurw	a7,s2,t5,2
    23c6:	00c8863b          	addw	a2,a7,a2
    23ca:	52ca4563          	blt	s4,a2,28f4 <matrix_test+0xd64>
    23ce:	011eae33          	slt	t3,t4,a7
    23d2:	00ae033b          	addw	t1,t3,a0
    23d6:	3c03250b          	th.ext	a0,t1,15,0
    23da:	2685                	addiw	a3,a3,1
    23dc:	0886f163          	bgeu	a3,s0,245e <matrix_test+0x8ce>
    23e0:	016687bb          	addw	a5,a3,s6
    23e4:	54f9428b          	th.lurw	t0,s2,a5,2
    23e8:	00c283bb          	addw	t2,t0,a2
    23ec:	487a5c63          	bge	s4,t2,2884 <matrix_test+0xcf4>
    23f0:	00a50e9b          	addiw	t4,a0,10
    23f4:	3c0eaf0b          	th.ext	t5,t4,15,0
    23f8:	4381                	li	t2,0
    23fa:	0016881b          	addiw	a6,a3,1
    23fe:	01680e3b          	addw	t3,a6,s6
    2402:	55c9460b          	th.lurw	a2,s2,t3,2
    2406:	007603bb          	addw	t2,a2,t2
    240a:	467a5563          	bge	s4,t2,2874 <matrix_test+0xce4>
    240e:	00af071b          	addiw	a4,t5,10
    2412:	3c07278b          	th.ext	a5,a4,15,0
    2416:	4381                	li	t2,0
    2418:	0018029b          	addiw	t0,a6,1
    241c:	016288bb          	addw	a7,t0,s6
    2420:	5519450b          	th.lurw	a0,s2,a7,2
    2424:	0075033b          	addw	t1,a0,t2
    2428:	446a4063          	blt	s4,t1,2868 <matrix_test+0xcd8>
    242c:	00a62f33          	slt	t5,a2,a0
    2430:	00ff0ebb          	addw	t4,t5,a5
    2434:	3c0eae0b          	th.ext	t3,t4,15,0
    2438:	0012869b          	addiw	a3,t0,1
    243c:	0166863b          	addw	a2,a3,s6
    2440:	54c9488b          	th.lurw	a7,s2,a2,2
    2444:	0068863b          	addw	a2,a7,t1
    2448:	40ca4a63          	blt	s4,a2,285c <matrix_test+0xccc>
    244c:	011527b3          	slt	a5,a0,a7
    2450:	01c783bb          	addw	t2,a5,t3
    2454:	2685                	addiw	a3,a3,1
    2456:	3c03a50b          	th.ext	a0,t2,15,0
    245a:	f886e3e3          	bltu	a3,s0,23e0 <matrix_test+0x850>
    245e:	2f85                	addiw	t6,t6,1
    2460:	01640b3b          	addw	s6,s0,s6
    2464:	ee8fe2e3          	bltu	t6,s0,2348 <matrix_test+0x7b8>
    2468:	388020ef          	jal	47f0 <crc16>
    246c:	85aa                	mv	a1,a0
    246e:	4301                	li	t1,0
    2470:	4501                	li	a0,0
    2472:	0001                	nop
    2474:	00000013          	nop
    2478:	4b01                	li	s6,0
    247a:	0001                	nop
    247c:	00000013          	nop
    2480:	32a4c80b          	th.lurh	a6,s1,a0,1
    2484:	3369c28b          	th.lurh	t0,s3,s6,1
    2488:	fff40f93          	addi	t6,s0,-1
    248c:	00ab08bb          	addw	a7,s6,a0
    2490:	025807bb          	mulw	a5,a6,t0
    2494:	003ff613          	andi	a2,t6,3
    2498:	016406bb          	addw	a3,s0,s6
    249c:	1427b38b          	th.extu	t2,a5,5,2
    24a0:	2c57be8b          	th.extu	t4,a5,11,5
    24a4:	03d3873b          	mulw	a4,t2,t4
    24a8:	4785                	li	a5,1
    24aa:	8e3a                	mv	t3,a4
    24ac:	1087f763          	bgeu	a5,s0,25ba <matrix_test+0xa2a>
    24b0:	ca35                	beqz	a2,2524 <matrix_test+0x994>
    24b2:	04f60563          	beq	a2,a5,24fc <matrix_test+0x96c>
    24b6:	4709                	li	a4,2
    24b8:	02e60263          	beq	a2,a4,24dc <matrix_test+0x94c>
    24bc:	00150f9b          	addiw	t6,a0,1
    24c0:	32d9c60b          	th.lurh	a2,s3,a3,1
    24c4:	33f4c80b          	th.lurh	a6,s1,t6,1
    24c8:	9ea1                	addw	a3,a3,s0
    24ca:	02c802bb          	mulw	t0,a6,a2
    24ce:	2c52b78b          	th.extu	a5,t0,11,5
    24d2:	1422b38b          	th.extu	t2,t0,5,2
    24d6:	24f39e0b          	th.mulaw	t3,t2,a5
    24da:	87ba                	mv	a5,a4
    24dc:	00a78ebb          	addw	t4,a5,a0
    24e0:	32d9c70b          	th.lurh	a4,s3,a3,1
    24e4:	33d4cf0b          	th.lurh	t5,s1,t4,1
    24e8:	2785                	addiw	a5,a5,1
    24ea:	9ea1                	addw	a3,a3,s0
    24ec:	02ef0fbb          	mulw	t6,t5,a4
    24f0:	142fb80b          	th.extu	a6,t6,5,2
    24f4:	2c5fb60b          	th.extu	a2,t6,11,5
    24f8:	24c81e0b          	th.mulaw	t3,a6,a2
    24fc:	00a782bb          	addw	t0,a5,a0
    2500:	32d9ce8b          	th.lurh	t4,s3,a3,1
    2504:	3254c38b          	th.lurh	t2,s1,t0,1
    2508:	8772                	mv	a4,t3
    250a:	2785                	addiw	a5,a5,1
    250c:	03d38f3b          	mulw	t5,t2,t4
    2510:	9ea1                	addw	a3,a3,s0
    2512:	142f3f8b          	th.extu	t6,t5,5,2
    2516:	2c5f380b          	th.extu	a6,t5,11,5
    251a:	250f970b          	th.mulaw	a4,t6,a6
    251e:	8e3a                	mv	t3,a4
    2520:	0887fd63          	bgeu	a5,s0,25ba <matrix_test+0xa2a>
    2524:	00a7863b          	addw	a2,a5,a0
    2528:	32c4c28b          	th.lurh	t0,s1,a2,1
    252c:	32d9c38b          	th.lurh	t2,s3,a3,1
    2530:	0017881b          	addiw	a6,a5,1
    2534:	9ea1                	addw	a3,a3,s0
    2536:	02728f3b          	mulw	t5,t0,t2
    253a:	8772                	mv	a4,t3
    253c:	00a80e3b          	addw	t3,a6,a0
    2540:	33c4c78b          	th.lurh	a5,s1,t3,1
    2544:	32d9c60b          	th.lurh	a2,s3,a3,1
    2548:	142f3e8b          	th.extu	t4,t5,5,2
    254c:	2c5f3f8b          	th.extu	t6,t5,11,5
    2550:	02c782bb          	mulw	t0,a5,a2
    2554:	25fe970b          	th.mulaw	a4,t4,t6
    2558:	00180e9b          	addiw	t4,a6,1
    255c:	00868fbb          	addw	t6,a3,s0
    2560:	00ae883b          	addw	a6,t4,a0
    2564:	3304c68b          	th.lurh	a3,s1,a6,1
    2568:	33f9ce0b          	th.lurh	t3,s3,t6,1
    256c:	1422b38b          	th.extu	t2,t0,5,2
    2570:	2c52bf0b          	th.extu	t5,t0,11,5
    2574:	25e3970b          	th.mulaw	a4,t2,t5
    2578:	001e839b          	addiw	t2,t4,1
    257c:	03c687bb          	mulw	a5,a3,t3
    2580:	008f8f3b          	addw	t5,t6,s0
    2584:	00a38ebb          	addw	t4,t2,a0
    2588:	33d4cf8b          	th.lurh	t6,s1,t4,1
    258c:	33e9c80b          	th.lurh	a6,s3,t5,1
    2590:	1427b28b          	th.extu	t0,a5,5,2
    2594:	2c57b60b          	th.extu	a2,a5,11,5
    2598:	030f86bb          	mulw	a3,t6,a6
    259c:	24c2970b          	th.mulaw	a4,t0,a2
    25a0:	1426be0b          	th.extu	t3,a3,5,2
    25a4:	2c56b78b          	th.extu	a5,a3,11,5
    25a8:	24fe170b          	th.mulaw	a4,t3,a5
    25ac:	0013879b          	addiw	a5,t2,1
    25b0:	008f06bb          	addw	a3,t5,s0
    25b4:	8e3a                	mv	t3,a4
    25b6:	f687e7e3          	bltu	a5,s0,2524 <matrix_test+0x994>
    25ba:	5519570b          	th.surw	a4,s2,a7,2
    25be:	2b05                	addiw	s6,s6,1
    25c0:	ec8b60e3          	bltu	s6,s0,2480 <matrix_test+0x8f0>
    25c4:	2305                	addiw	t1,t1,1
    25c6:	9d21                	addw	a0,a0,s0
    25c8:	ea8368e3          	bltu	t1,s0,2478 <matrix_test+0x8e8>
    25cc:	4b01                	li	s6,0
    25ce:	4301                	li	t1,0
    25d0:	4681                	li	a3,0
    25d2:	4501                	li	a0,0
    25d4:	4881                	li	a7,0
    25d6:	0001                	nop
    25d8:	829a                	mv	t0,t1
    25da:	5569430b          	th.lurw	t1,s2,s6,2
    25de:	fff40713          	addi	a4,s0,-1
    25e2:	00377993          	andi	s3,a4,3
    25e6:	00d306bb          	addw	a3,t1,a3
    25ea:	2eda5763          	bge	s4,a3,28d8 <matrix_test+0xd48>
    25ee:	00a50f1b          	addiw	t5,a0,10
    25f2:	3c0f250b          	th.ext	a0,t5,15,0
    25f6:	4681                	li	a3,0
    25f8:	4785                	li	a5,1
    25fa:	0e87fa63          	bgeu	a5,s0,26ee <matrix_test+0xb5e>
    25fe:	06098963          	beqz	s3,2670 <matrix_test+0xae0>
    2602:	04f98563          	beq	s3,a5,264c <matrix_test+0xabc>
    2606:	4e89                	li	t4,2
    2608:	03d98263          	beq	s3,t4,262c <matrix_test+0xa9c>
    260c:	001b081b          	addiw	a6,s6,1
    2610:	8f9a                	mv	t6,t1
    2612:	5509430b          	th.lurw	t1,s2,a6,2
    2616:	00d306bb          	addw	a3,t1,a3
    261a:	32da4663          	blt	s4,a3,2946 <matrix_test+0xdb6>
    261e:	006fae33          	slt	t3,t6,t1
    2622:	00ae053b          	addw	a0,t3,a0
    2626:	3c05250b          	th.ext	a0,a0,15,0
    262a:	2785                	addiw	a5,a5,1
    262c:	871a                	mv	a4,t1
    262e:	0167833b          	addw	t1,a5,s6
    2632:	5469430b          	th.lurw	t1,s2,t1,2
    2636:	00d306bb          	addw	a3,t1,a3
    263a:	2cda4f63          	blt	s4,a3,2918 <matrix_test+0xd88>
    263e:	006729b3          	slt	s3,a4,t1
    2642:	00a982bb          	addw	t0,s3,a0
    2646:	3c02a50b          	th.ext	a0,t0,15,0
    264a:	2785                	addiw	a5,a5,1
    264c:	01678f3b          	addw	t5,a5,s6
    2650:	839a                	mv	t2,t1
    2652:	55e9430b          	th.lurw	t1,s2,t5,2
    2656:	00d306bb          	addw	a3,t1,a3
    265a:	2ada4963          	blt	s4,a3,290c <matrix_test+0xd7c>
    265e:	0063aeb3          	slt	t4,t2,t1
    2662:	00ae8fbb          	addw	t6,t4,a0
    2666:	3c0fa50b          	th.ext	a0,t6,15,0
    266a:	2785                	addiw	a5,a5,1
    266c:	0887f163          	bgeu	a5,s0,26ee <matrix_test+0xb5e>
    2670:	0167873b          	addw	a4,a5,s6
    2674:	54e9498b          	th.lurw	s3,s2,a4,2
    2678:	00d982bb          	addw	t0,s3,a3
    267c:	1c5a5863          	bge	s4,t0,284c <matrix_test+0xcbc>
    2680:	00a50e9b          	addiw	t4,a0,10
    2684:	3c0eaf0b          	th.ext	t5,t4,15,0
    2688:	4281                	li	t0,0
    268a:	00178f9b          	addiw	t6,a5,1
    268e:	016f883b          	addw	a6,t6,s6
    2692:	55094e0b          	th.lurw	t3,s2,a6,2
    2696:	005e073b          	addw	a4,t3,t0
    269a:	1aea5163          	bge	s4,a4,283c <matrix_test+0xcac>
    269e:	00af069b          	addiw	a3,t5,10
    26a2:	3c06a30b          	th.ext	t1,a3,15,0
    26a6:	4701                	li	a4,0
    26a8:	001f899b          	addiw	s3,t6,1
    26ac:	016982bb          	addw	t0,s3,s6
    26b0:	5459438b          	th.lurw	t2,s2,t0,2
    26b4:	00e3883b          	addw	a6,t2,a4
    26b8:	170a4c63          	blt	s4,a6,2830 <matrix_test+0xca0>
    26bc:	007e2533          	slt	a0,t3,t2
    26c0:	00650f3b          	addw	t5,a0,t1
    26c4:	3c0f2f8b          	th.ext	t6,t5,15,0
    26c8:	0019879b          	addiw	a5,s3,1
    26cc:	01678e3b          	addw	t3,a5,s6
    26d0:	55c9430b          	th.lurw	t1,s2,t3,2
    26d4:	010306bb          	addw	a3,t1,a6
    26d8:	14da4663          	blt	s4,a3,2824 <matrix_test+0xc94>
    26dc:	0063a633          	slt	a2,t2,t1
    26e0:	01f6073b          	addw	a4,a2,t6
    26e4:	2785                	addiw	a5,a5,1
    26e6:	3c07250b          	th.ext	a0,a4,15,0
    26ea:	f887e3e3          	bltu	a5,s0,2670 <matrix_test+0xae0>
    26ee:	2885                	addiw	a7,a7,1
    26f0:	01640b3b          	addw	s6,s0,s6
    26f4:	ee88e2e3          	bltu	a7,s0,25d8 <matrix_test+0xa48>
    26f8:	0f8020ef          	jal	47f0 <crc16>
    26fc:	4681                	li	a3,0
    26fe:	4601                	li	a2,0
    2700:	b2d4ca0b          	th.lurhu	s4,s1,a3,1
    2704:	fff40593          	addi	a1,s0,-1
    2708:	4785                	li	a5,1
    270a:	415a0b3b          	subw	s6,s4,s5
    270e:	32d4db0b          	th.surh	s6,s1,a3,1
    2712:	0075f913          	andi	s2,a1,7
    2716:	0e87f663          	bgeu	a5,s0,2802 <matrix_test+0xc72>
    271a:	0a090663          	beqz	s2,27c6 <matrix_test+0xc36>
    271e:	08f90963          	beq	s2,a5,27b0 <matrix_test+0xc20>
    2722:	4889                	li	a7,2
    2724:	07190d63          	beq	s2,a7,279e <matrix_test+0xc0e>
    2728:	4e0d                	li	t3,3
    272a:	07c90163          	beq	s2,t3,278c <matrix_test+0xbfc>
    272e:	4711                	li	a4,4
    2730:	04e90563          	beq	s2,a4,277a <matrix_test+0xbea>
    2734:	4315                	li	t1,5
    2736:	02690963          	beq	s2,t1,2768 <matrix_test+0xbd8>
    273a:	4999                	li	s3,6
    273c:	01390b63          	beq	s2,s3,2752 <matrix_test+0xbc2>
    2740:	0016829b          	addiw	t0,a3,1
    2744:	b254c38b          	th.lurhu	t2,s1,t0,1
    2748:	87c6                	mv	a5,a7
    274a:	41538f3b          	subw	t5,t2,s5
    274e:	3254df0b          	th.surh	t5,s1,t0,1
    2752:	00d78ebb          	addw	t4,a5,a3
    2756:	b3d4cf8b          	th.lurhu	t6,s1,t4,1
    275a:	2785                	addiw	a5,a5,1
    275c:	415f883b          	subw	a6,t6,s5
    2760:	33d4d80b          	th.surh	a6,s1,t4,1
    2764:	00000013          	nop
    2768:	00d785bb          	addw	a1,a5,a3
    276c:	b2b4c90b          	th.lurhu	s2,s1,a1,1
    2770:	2785                	addiw	a5,a5,1
    2772:	41590a3b          	subw	s4,s2,s5
    2776:	32b4da0b          	th.surh	s4,s1,a1,1
    277a:	00d78b3b          	addw	s6,a5,a3
    277e:	b364c88b          	th.lurhu	a7,s1,s6,1
    2782:	2785                	addiw	a5,a5,1
    2784:	41588e3b          	subw	t3,a7,s5
    2788:	3364de0b          	th.surh	t3,s1,s6,1
    278c:	00d7833b          	addw	t1,a5,a3
    2790:	b264c70b          	th.lurhu	a4,s1,t1,1
    2794:	2785                	addiw	a5,a5,1
    2796:	415709bb          	subw	s3,a4,s5
    279a:	3264d98b          	th.surh	s3,s1,t1,1
    279e:	00d782bb          	addw	t0,a5,a3
    27a2:	b254c38b          	th.lurhu	t2,s1,t0,1
    27a6:	2785                	addiw	a5,a5,1
    27a8:	41538f3b          	subw	t5,t2,s5
    27ac:	3254df0b          	th.surh	t5,s1,t0,1
    27b0:	00d78ebb          	addw	t4,a5,a3
    27b4:	b3d4cf8b          	th.lurhu	t6,s1,t4,1
    27b8:	2785                	addiw	a5,a5,1
    27ba:	415f883b          	subw	a6,t6,s5
    27be:	33d4d80b          	th.surh	a6,s1,t4,1
    27c2:	0487f063          	bgeu	a5,s0,2802 <matrix_test+0xc72>
    27c6:	00d785bb          	addw	a1,a5,a3
    27ca:	b2b4c90b          	th.lurhu	s2,s1,a1,1
    27ce:	00178b1b          	addiw	s6,a5,1
    27d2:	00db08bb          	addw	a7,s6,a3
    27d6:	41590a3b          	subw	s4,s2,s5
    27da:	32b4da0b          	th.surh	s4,s1,a1,1
    27de:	b314ce0b          	th.lurhu	t3,s1,a7,1
    27e2:	001b079b          	addiw	a5,s6,1
    27e6:	00d78ebb          	addw	t4,a5,a3
    27ea:	415e033b          	subw	t1,t3,s5
    27ee:	3314d30b          	th.surh	t1,s1,a7,1
    27f2:	b3d4cf8b          	th.lurhu	t6,s1,t4,1
    27f6:	2785                	addiw	a5,a5,1
    27f8:	415f883b          	subw	a6,t6,s5
    27fc:	33d4d80b          	th.surh	a6,s1,t4,1
    2800:	b7a5                	j	2768 <matrix_test+0xbd8>
    2802:	2605                	addiw	a2,a2,1
    2804:	9ea1                	addw	a3,a3,s0
    2806:	ee866de3          	bltu	a2,s0,2700 <matrix_test+0xb70>
    280a:	74a2                	ld	s1,40(sp)
    280c:	7442                	ld	s0,48(sp)
    280e:	70e2                	ld	ra,56(sp)
    2810:	6b02                	ld	s6,0(sp)
    2812:	6aa2                	ld	s5,8(sp)
    2814:	69e2                	ld	s3,24(sp)
    2816:	7902                	ld	s2,32(sp)
    2818:	6a42                	ld	s4,16(sp)
    281a:	3c05250b          	th.ext	a0,a0,15,0
    281e:	6121                	addi	sp,sp,64
    2820:	8082                	ret
    2822:	0001                	nop
    2824:	00af869b          	addiw	a3,t6,10
    2828:	3c06a50b          	th.ext	a0,a3,15,0
    282c:	4681                	li	a3,0
    282e:	bd35                	j	266a <matrix_test+0xada>
    2830:	00a30e9b          	addiw	t4,t1,10
    2834:	3c0eaf8b          	th.ext	t6,t4,15,0
    2838:	4801                	li	a6,0
    283a:	b579                	j	26c8 <matrix_test+0xb38>
    283c:	01c9a7b3          	slt	a5,s3,t3
    2840:	01e7863b          	addw	a2,a5,t5
    2844:	3c06230b          	th.ext	t1,a2,15,0
    2848:	b585                	j	26a8 <matrix_test+0xb18>
    284a:	0001                	nop
    284c:	013323b3          	slt	t2,t1,s3
    2850:	00a3853b          	addw	a0,t2,a0
    2854:	3c052f0b          	th.ext	t5,a0,15,0
    2858:	bd0d                	j	268a <matrix_test+0xafa>
    285a:	0001                	nop
    285c:	00ae071b          	addiw	a4,t3,10
    2860:	3c07250b          	th.ext	a0,a4,15,0
    2864:	4601                	li	a2,0
    2866:	be95                	j	23da <matrix_test+0x84a>
    2868:	00a7881b          	addiw	a6,a5,10
    286c:	3c082e0b          	th.ext	t3,a6,15,0
    2870:	4301                	li	t1,0
    2872:	b6d9                	j	2438 <matrix_test+0x8a8>
    2874:	00c2a333          	slt	t1,t0,a2
    2878:	01e306bb          	addw	a3,t1,t5
    287c:	3c06a78b          	th.ext	a5,a3,15,0
    2880:	be61                	j	2418 <matrix_test+0x888>
    2882:	0001                	nop
    2884:	0058a8b3          	slt	a7,a7,t0
    2888:	00a8853b          	addw	a0,a7,a0
    288c:	3c052f0b          	th.ext	t5,a0,15,0
    2890:	b6ad                	j	23fa <matrix_test+0x86a>
    2892:	0001                	nop
    2894:	00a3071b          	addiw	a4,t1,10
    2898:	3c07250b          	th.ext	a0,a4,15,0
    289c:	4701                	li	a4,0
    289e:	b231                	j	21aa <matrix_test+0x61a>
    28a0:	00ab069b          	addiw	a3,s6,10
    28a4:	3c06a30b          	th.ext	t1,a3,15,0
    28a8:	4781                	li	a5,0
    28aa:	bab1                	j	2206 <matrix_test+0x676>
    28ac:	011fa7b3          	slt	a5,t6,a7
    28b0:	01d783bb          	addw	t2,a5,t4
    28b4:	3c03ab0b          	th.ext	s6,t2,15,0
    28b8:	b23d                	j	21e6 <matrix_test+0x656>
    28ba:	0001                	nop
    28bc:	01f8af33          	slt	t5,a7,t6
    28c0:	00af053b          	addw	a0,t5,a0
    28c4:	3c052e8b          	th.ext	t4,a0,15,0
    28c8:	b209                	j	21ca <matrix_test+0x63a>
    28ca:	011323b3          	slt	t2,t1,a7
    28ce:	00a3853b          	addw	a0,t2,a0
    28d2:	3c05250b          	th.ext	a0,a0,15,0
    28d6:	b08d                	j	2138 <matrix_test+0x5a8>
    28d8:	0062a633          	slt	a2,t0,t1
    28dc:	00a603bb          	addw	t2,a2,a0
    28e0:	3c03a50b          	th.ext	a0,t2,15,0
    28e4:	bb11                	j	25f8 <matrix_test+0xa68>
    28e6:	0116a7b3          	slt	a5,a3,a7
    28ea:	00a783bb          	addw	t2,a5,a0
    28ee:	3c03a50b          	th.ext	a0,t2,15,0
    28f2:	bc9d                	j	2368 <matrix_test+0x7d8>
    28f4:	00a5071b          	addiw	a4,a0,10
    28f8:	3c07250b          	th.ext	a0,a4,15,0
    28fc:	4601                	li	a2,0
    28fe:	bcf1                	j	23da <matrix_test+0x84a>
    2900:	00a5071b          	addiw	a4,a0,10
    2904:	3c07250b          	th.ext	a0,a4,15,0
    2908:	4701                	li	a4,0
    290a:	b045                	j	21aa <matrix_test+0x61a>
    290c:	00a5081b          	addiw	a6,a0,10
    2910:	3c08250b          	th.ext	a0,a6,15,0
    2914:	4681                	li	a3,0
    2916:	bb91                	j	266a <matrix_test+0xada>
    2918:	00a5061b          	addiw	a2,a0,10
    291c:	3c06250b          	th.ext	a0,a2,15,0
    2920:	4681                	li	a3,0
    2922:	b325                	j	264a <matrix_test+0xaba>
    2924:	2529                	addiw	a0,a0,10
    2926:	3c05250b          	th.ext	a0,a0,15,0
    292a:	4701                	li	a4,0
    292c:	b8b9                	j	218a <matrix_test+0x5fa>
    292e:	00a5039b          	addiw	t2,a0,10
    2932:	3c03a50b          	th.ext	a0,t2,15,0
    2936:	4601                	li	a2,0
    2938:	b449                	j	23ba <matrix_test+0x82a>
    293a:	00a5061b          	addiw	a2,a0,10
    293e:	3c06250b          	th.ext	a0,a2,15,0
    2942:	4601                	li	a2,0
    2944:	bc99                	j	239a <matrix_test+0x80a>
    2946:	00a5069b          	addiw	a3,a0,10
    294a:	3c06a50b          	th.ext	a0,a3,15,0
    294e:	4681                	li	a3,0
    2950:	b9e9                	j	262a <matrix_test+0xa9a>
    2952:	00a50b1b          	addiw	s6,a0,10
    2956:	3c0b250b          	th.ext	a0,s6,15,0
    295a:	4701                	li	a4,0
    295c:	80fff06f          	j	216a <matrix_test+0x5da>
    2960:	4581                	li	a1,0
    2962:	68f010ef          	jal	47f0 <crc16>
    2966:	85aa                	mv	a1,a0
    2968:	4501                	li	a0,0
    296a:	687010ef          	jal	47f0 <crc16>
    296e:	85aa                	mv	a1,a0
    2970:	4501                	li	a0,0
    2972:	67f010ef          	jal	47f0 <crc16>
    2976:	85aa                	mv	a1,a0
    2978:	4501                	li	a0,0
    297a:	677010ef          	jal	47f0 <crc16>
    297e:	70e2                	ld	ra,56(sp)
    2980:	6a42                	ld	s4,16(sp)
    2982:	3c05250b          	th.ext	a0,a0,15,0
    2986:	6121                	addi	sp,sp,64
    2988:	8082                	ret
    298a:	00000013          	nop
    298e:	0001                	nop

0000000000002990 <core_bench_matrix>:
    2990:	1141                	addi	sp,sp,-16
    2992:	f811540b          	th.sdd	s0,ra,(sp),0,4
    2996:	872e                	mv	a4,a1
    2998:	8432                	mv	s0,a2
    299a:	fab5468b          	th.ldd	a3,a1,(a0),1,4
    299e:	6510                	ld	a2,8(a0)
    29a0:	4108                	lw	a0,0(a0)
    29a2:	9eeff0ef          	jal	1b90 <matrix_test>
    29a6:	85a2                	mv	a1,s0
    29a8:	f811440b          	th.ldd	s0,ra,(sp),0,4
    29ac:	0141                	addi	sp,sp,16
    29ae:	6430106f          	j	47f0 <crc16>
    29b2:	0001                	nop
    29b4:	00000013          	nop
    29b8:	00000013          	nop
    29bc:	00000013          	nop

00000000000029c0 <core_init_matrix>:
    29c0:	4785                	li	a5,1
    29c2:	42c6178b          	th.mvnez	a5,a2,a2
    29c6:	882a                	mv	a6,a0
    29c8:	4601                	li	a2,0
    29ca:	1e050763          	beqz	a0,2bb8 <core_init_matrix+0x1f8>
    29ce:	0016031b          	addiw	t1,a2,1
    29d2:	026303bb          	mulw	t2,t1,t1
    29d6:	8532                	mv	a0,a2
    29d8:	0033989b          	slliw	a7,t2,0x3
    29dc:	0908f263          	bgeu	a7,a6,2a60 <core_init_matrix+0xa0>
    29e0:	00130e1b          	addiw	t3,t1,1
    29e4:	03ce0f3b          	mulw	t5,t3,t3
    29e8:	851a                	mv	a0,t1
    29ea:	003f1f9b          	slliw	t6,t5,0x3
    29ee:	070ff963          	bgeu	t6,a6,2a60 <core_init_matrix+0xa0>
    29f2:	001e061b          	addiw	a2,t3,1
    29f6:	02c6033b          	mulw	t1,a2,a2
    29fa:	8572                	mv	a0,t3
    29fc:	0033171b          	slliw	a4,t1,0x3
    2a00:	07077063          	bgeu	a4,a6,2a60 <core_init_matrix+0xa0>
    2a04:	0016039b          	addiw	t2,a2,1
    2a08:	02738e3b          	mulw	t3,t2,t2
    2a0c:	8532                	mv	a0,a2
    2a0e:	003e1e9b          	slliw	t4,t3,0x3
    2a12:	050ef763          	bgeu	t4,a6,2a60 <core_init_matrix+0xa0>
    2a16:	00138f1b          	addiw	t5,t2,1
    2a1a:	03ef063b          	mulw	a2,t5,t5
    2a1e:	851e                	mv	a0,t2
    2a20:	0036129b          	slliw	t0,a2,0x3
    2a24:	0302fe63          	bgeu	t0,a6,2a60 <core_init_matrix+0xa0>
    2a28:	001f031b          	addiw	t1,t5,1
    2a2c:	026303bb          	mulw	t2,t1,t1
    2a30:	857a                	mv	a0,t5
    2a32:	0033989b          	slliw	a7,t2,0x3
    2a36:	0308f563          	bgeu	a7,a6,2a60 <core_init_matrix+0xa0>
    2a3a:	00130e1b          	addiw	t3,t1,1
    2a3e:	03ce0f3b          	mulw	t5,t3,t3
    2a42:	851a                	mv	a0,t1
    2a44:	003f1f9b          	slliw	t6,t5,0x3
    2a48:	010ffc63          	bgeu	t6,a6,2a60 <core_init_matrix+0xa0>
    2a4c:	001e061b          	addiw	a2,t3,1
    2a50:	02c6033b          	mulw	t1,a2,a2
    2a54:	8572                	mv	a0,t3
    2a56:	0033171b          	slliw	a4,t1,0x3
    2a5a:	f7076ae3          	bltu	a4,a6,29ce <core_init_matrix+0xe>
    2a5e:	0001                	nop
    2a60:	02a503bb          	mulw	t2,a0,a0
    2a64:	15fd                	addi	a1,a1,-1
    2a66:	ffc5f813          	andi	a6,a1,-4
    2a6a:	00480593          	addi	a1,a6,4
    2a6e:	7c03b88b          	th.extu	a7,t2,31,0
    2a72:	00189e13          	slli	t3,a7,0x1
    2a76:	01c58633          	add	a2,a1,t3
    2a7a:	14050b63          	beqz	a0,2bd0 <core_init_matrix+0x210>
    2a7e:	8eaa                	mv	t4,a0
    2a80:	0015081b          	addiw	a6,a0,1
    2a84:	4881                	li	a7,0
    2a86:	4705                	li	a4,1
    2a88:	40e80f33          	sub	t5,a6,a4
    2a8c:	003f7293          	andi	t0,t5,3
    2a90:	833a                	mv	t1,a4
    2a92:	00028963          	beqz	t0,2aa4 <core_init_matrix+0xe4>
    2a96:	4f85                	li	t6,1
    2a98:	0bf28d63          	beq	t0,t6,2b52 <core_init_matrix+0x192>
    2a9c:	4389                	li	t2,2
    2a9e:	06728d63          	beq	t0,t2,2b18 <core_init_matrix+0x158>
    2aa2:	a835                	j	2ade <core_init_matrix+0x11e>
    2aa4:	02e783bb          	mulw	t2,a5,a4
    2aa8:	41f3d29b          	sraiw	t0,t2,0x1f
    2aac:	0102df9b          	srliw	t6,t0,0x10
    2ab0:	007f87bb          	addw	a5,t6,t2
    2ab4:	3c07bf0b          	th.extu	t5,a5,15,0
    2ab8:	41ff07bb          	subw	a5,t5,t6
    2abc:	3c07338b          	th.extu	t2,a4,15,0
    2ac0:	007782bb          	addw	t0,a5,t2
    2ac4:	3c02bf0b          	th.extu	t5,t0,15,0
    2ac8:	fff70f9b          	addiw	t6,a4,-1
    2acc:	007f03bb          	addw	t2,t5,t2
    2ad0:	33f65f0b          	th.surh	t5,a2,t6,1
    2ad4:	0ff3f293          	zext.b	t0,t2
    2ad8:	33f5d28b          	th.surh	t0,a1,t6,1
    2adc:	2705                	addiw	a4,a4,1
    2ade:	02e787bb          	mulw	a5,a5,a4
    2ae2:	41f7df1b          	sraiw	t5,a5,0x1f
    2ae6:	010f529b          	srliw	t0,t5,0x10
    2aea:	00f28fbb          	addw	t6,t0,a5
    2aee:	3c0fb38b          	th.extu	t2,t6,15,0
    2af2:	405387bb          	subw	a5,t2,t0
    2af6:	3c07328b          	th.extu	t0,a4,15,0
    2afa:	00578f3b          	addw	t5,a5,t0
    2afe:	3c0f338b          	th.extu	t2,t5,15,0
    2b02:	fff70f9b          	addiw	t6,a4,-1
    2b06:	005382bb          	addw	t0,t2,t0
    2b0a:	33f6538b          	th.surh	t2,a2,t6,1
    2b0e:	0ff2ff13          	zext.b	t5,t0
    2b12:	33f5df0b          	th.surh	t5,a1,t6,1
    2b16:	2705                	addiw	a4,a4,1
    2b18:	02e787bb          	mulw	a5,a5,a4
    2b1c:	41f7d39b          	sraiw	t2,a5,0x1f
    2b20:	0103df9b          	srliw	t6,t2,0x10
    2b24:	00ff82bb          	addw	t0,t6,a5
    2b28:	3c02bf0b          	th.extu	t5,t0,15,0
    2b2c:	3c07338b          	th.extu	t2,a4,15,0
    2b30:	41ff07bb          	subw	a5,t5,t6
    2b34:	00778fbb          	addw	t6,a5,t2
    2b38:	3c0fb28b          	th.extu	t0,t6,15,0
    2b3c:	00728f3b          	addw	t5,t0,t2
    2b40:	fff70f9b          	addiw	t6,a4,-1
    2b44:	33f6528b          	th.surh	t0,a2,t6,1
    2b48:	0fff7393          	zext.b	t2,t5
    2b4c:	33f5d38b          	th.surh	t2,a1,t6,1
    2b50:	2705                	addiw	a4,a4,1
    2b52:	02e787bb          	mulw	a5,a5,a4
    2b56:	41f7d29b          	sraiw	t0,a5,0x1f
    2b5a:	0102df9b          	srliw	t6,t0,0x10
    2b5e:	00ff8f3b          	addw	t5,t6,a5
    2b62:	3c0f338b          	th.extu	t2,t5,15,0
    2b66:	3c07328b          	th.extu	t0,a4,15,0
    2b6a:	41f387bb          	subw	a5,t2,t6
    2b6e:	00578fbb          	addw	t6,a5,t0
    2b72:	3c0fbf0b          	th.extu	t5,t6,15,0
    2b76:	fff7039b          	addiw	t2,a4,-1
    2b7a:	005f02bb          	addw	t0,t5,t0
    2b7e:	32765f0b          	th.surh	t5,a2,t2,1
    2b82:	0ff2ff93          	zext.b	t6,t0
    2b86:	3275df8b          	th.surh	t6,a1,t2,1
    2b8a:	2705                	addiw	a4,a4,1
    2b8c:	f1071ce3          	bne	a4,a6,2aa4 <core_init_matrix+0xe4>
    2b90:	2885                	addiw	a7,a7,1
    2b92:	0065073b          	addw	a4,a0,t1
    2b96:	0105083b          	addw	a6,a0,a6
    2b9a:	eea897e3          	bne	a7,a0,2a88 <core_init_matrix+0xc8>
    2b9e:	9e32                	add	t3,t3,a2
    2ba0:	fffe0313          	addi	t1,t3,-1
    2ba4:	ffc37793          	andi	a5,t1,-4
    2ba8:	00478f13          	addi	t5,a5,4
    2bac:	01d6a023          	sw	t4,0(a3)
    2bb0:	e68c                	sd	a1,8(a3)
    2bb2:	fbe6d60b          	th.sdd	a2,t5,(a3),1,4
    2bb6:	8082                	ret
    2bb8:	fff58613          	addi	a2,a1,-1
    2bbc:	ffc67293          	andi	t0,a2,-4
    2bc0:	5efd                	li	t4,-1
    2bc2:	00428593          	addi	a1,t0,4
    2bc6:	00628613          	addi	a2,t0,6
    2bca:	8576                	mv	a0,t4
    2bcc:	4e09                	li	t3,2
    2bce:	bd4d                	j	2a80 <core_init_matrix+0xc0>
    2bd0:	4e81                	li	t4,0
    2bd2:	4e01                	li	t3,0
    2bd4:	b7e9                	j	2b9e <core_init_matrix+0x1de>
    2bd6:	00000013          	nop
    2bda:	00000013          	nop
    2bde:	0001                	nop

0000000000002be0 <matrix_sum>:
    2be0:	88aa                	mv	a7,a0
    2be2:	18050563          	beqz	a0,2d6c <matrix_sum+0x18c>
    2be6:	882a                	mv	a6,a0
    2be8:	4301                	li	t1,0
    2bea:	4e01                	li	t3,0
    2bec:	4501                	li	a0,0
    2bee:	4f01                	li	t5,0
    2bf0:	4781                	li	a5,0
    2bf2:	0001                	nop
    2bf4:	00000013          	nop
    2bf8:	406806b3          	sub	a3,a6,t1
    2bfc:	0036f293          	andi	t0,a3,3
    2c00:	871a                	mv	a4,t1
    2c02:	0c028e63          	beqz	t0,2cde <matrix_sum+0xfe>
    2c06:	4e85                	li	t4,1
    2c08:	05d28263          	beq	t0,t4,2c4c <matrix_sum+0x6c>
    2c0c:	4389                	li	t2,2
    2c0e:	02728163          	beq	t0,t2,2c30 <matrix_sum+0x50>
    2c12:	877a                	mv	a4,t5
    2c14:	5465cf0b          	th.lurw	t5,a1,t1,2
    2c18:	00ff07bb          	addw	a5,t5,a5
    2c1c:	14f64263          	blt	a2,a5,2d60 <matrix_sum+0x180>
    2c20:	01e72fb3          	slt	t6,a4,t5
    2c24:	00af853b          	addw	a0,t6,a0
    2c28:	3c05250b          	th.ext	a0,a0,15,0
    2c2c:	0013071b          	addiw	a4,t1,1
    2c30:	86fa                	mv	a3,t5
    2c32:	54e5cf0b          	th.lurw	t5,a1,a4,2
    2c36:	00ff07bb          	addw	a5,t5,a5
    2c3a:	10f64d63          	blt	a2,a5,2d54 <matrix_sum+0x174>
    2c3e:	01e6a2b3          	slt	t0,a3,t5
    2c42:	00a28ebb          	addw	t4,t0,a0
    2c46:	3c0ea50b          	th.ext	a0,t4,15,0
    2c4a:	2705                	addiw	a4,a4,1
    2c4c:	8ffa                	mv	t6,t5
    2c4e:	54e5cf0b          	th.lurw	t5,a1,a4,2
    2c52:	00ff07bb          	addw	a5,t5,a5
    2c56:	0ef64963          	blt	a2,a5,2d48 <matrix_sum+0x168>
    2c5a:	01efa6b3          	slt	a3,t6,t5
    2c5e:	9d35                	addw	a0,a0,a3
    2c60:	3c05250b          	th.ext	a0,a0,15,0
    2c64:	2705                	addiw	a4,a4,1
    2c66:	06e81c63          	bne	a6,a4,2cde <matrix_sum+0xfe>
    2c6a:	2e05                	addiw	t3,t3,1
    2c6c:	0108883b          	addw	a6,a7,a6
    2c70:	0068833b          	addw	t1,a7,t1
    2c74:	f9c892e3          	bne	a7,t3,2bf8 <matrix_sum+0x18>
    2c78:	8082                	ret
    2c7a:	0001                	nop
    2c7c:	2705                	addiw	a4,a4,1
    2c7e:	54e5cf0b          	th.lurw	t5,a1,a4,2
    2c82:	00a5069b          	addiw	a3,a0,10
    2c86:	4381                	li	t2,0
    2c88:	3c06af8b          	th.ext	t6,a3,15,0
    2c8c:	007f06bb          	addw	a3,t5,t2
    2c90:	06d65a63          	bge	a2,a3,2d04 <matrix_sum+0x124>
    2c94:	00af879b          	addiw	a5,t6,10
    2c98:	00170f9b          	addiw	t6,a4,1
    2c9c:	55f5ce8b          	th.lurw	t4,a1,t6,2
    2ca0:	4681                	li	a3,0
    2ca2:	3c07a38b          	th.ext	t2,a5,15,0
    2ca6:	00de87bb          	addw	a5,t4,a3
    2caa:	06f64b63          	blt	a2,a5,2d20 <matrix_sum+0x140>
    2cae:	01df2733          	slt	a4,t5,t4
    2cb2:	00770f3b          	addw	t5,a4,t2
    2cb6:	001f839b          	addiw	t2,t6,1
    2cba:	3c0f228b          	th.ext	t0,t5,15,0
    2cbe:	5475cf0b          	th.lurw	t5,a1,t2,2
    2cc2:	00ff07bb          	addw	a5,t5,a5
    2cc6:	06f64a63          	blt	a2,a5,2d3a <matrix_sum+0x15a>
    2cca:	01eea6b3          	slt	a3,t4,t5
    2cce:	00568fbb          	addw	t6,a3,t0
    2cd2:	3c0fa50b          	th.ext	a0,t6,15,0
    2cd6:	0013871b          	addiw	a4,t2,1
    2cda:	f8e808e3          	beq	a6,a4,2c6a <matrix_sum+0x8a>
    2cde:	54e5c28b          	th.lurw	t0,a1,a4,2
    2ce2:	00f283bb          	addw	t2,t0,a5
    2ce6:	f8764be3          	blt	a2,t2,2c7c <matrix_sum+0x9c>
    2cea:	005f2f33          	slt	t5,t5,t0
    2cee:	2705                	addiw	a4,a4,1
    2cf0:	00af0ebb          	addw	t4,t5,a0
    2cf4:	54e5cf0b          	th.lurw	t5,a1,a4,2
    2cf8:	3c0eaf8b          	th.ext	t6,t4,15,0
    2cfc:	007f06bb          	addw	a3,t5,t2
    2d00:	f8d64ae3          	blt	a2,a3,2c94 <matrix_sum+0xb4>
    2d04:	01e2a533          	slt	a0,t0,t5
    2d08:	01f502bb          	addw	t0,a0,t6
    2d0c:	00170f9b          	addiw	t6,a4,1
    2d10:	55f5ce8b          	th.lurw	t4,a1,t6,2
    2d14:	3c02a38b          	th.ext	t2,t0,15,0
    2d18:	00de87bb          	addw	a5,t4,a3
    2d1c:	f8f659e3          	bge	a2,a5,2cae <matrix_sum+0xce>
    2d20:	00a3851b          	addiw	a0,t2,10
    2d24:	001f839b          	addiw	t2,t6,1
    2d28:	5475cf0b          	th.lurw	t5,a1,t2,2
    2d2c:	4781                	li	a5,0
    2d2e:	3c05228b          	th.ext	t0,a0,15,0
    2d32:	00ff07bb          	addw	a5,t5,a5
    2d36:	f8f65ae3          	bge	a2,a5,2cca <matrix_sum+0xea>
    2d3a:	00a28e9b          	addiw	t4,t0,10
    2d3e:	3c0ea50b          	th.ext	a0,t4,15,0
    2d42:	4781                	li	a5,0
    2d44:	bf49                	j	2cd6 <matrix_sum+0xf6>
    2d46:	0001                	nop
    2d48:	00a5079b          	addiw	a5,a0,10
    2d4c:	3c07a50b          	th.ext	a0,a5,15,0
    2d50:	4781                	li	a5,0
    2d52:	bf09                	j	2c64 <matrix_sum+0x84>
    2d54:	00a5039b          	addiw	t2,a0,10
    2d58:	3c03a50b          	th.ext	a0,t2,15,0
    2d5c:	4781                	li	a5,0
    2d5e:	b5f5                	j	2c4a <matrix_sum+0x6a>
    2d60:	00a5079b          	addiw	a5,a0,10
    2d64:	3c07a50b          	th.ext	a0,a5,15,0
    2d68:	4781                	li	a5,0
    2d6a:	b5c9                	j	2c2c <matrix_sum+0x4c>
    2d6c:	4501                	li	a0,0
    2d6e:	8082                	ret

0000000000002d70 <matrix_mul_const>:
    2d70:	12050d63          	beqz	a0,2eaa <matrix_mul_const+0x13a>
    2d74:	882a                	mv	a6,a0
    2d76:	4881                	li	a7,0
    2d78:	4301                	li	t1,0
    2d7a:	0001                	nop
    2d7c:	00000013          	nop
    2d80:	41180733          	sub	a4,a6,a7
    2d84:	00777293          	andi	t0,a4,7
    2d88:	87c6                	mv	a5,a7
    2d8a:	08028863          	beqz	t0,2e1a <matrix_mul_const+0xaa>
    2d8e:	4e05                	li	t3,1
    2d90:	07c28c63          	beq	t0,t3,2e08 <matrix_mul_const+0x98>
    2d94:	4389                	li	t2,2
    2d96:	06728263          	beq	t0,t2,2dfa <matrix_mul_const+0x8a>
    2d9a:	4e8d                	li	t4,3
    2d9c:	05d28863          	beq	t0,t4,2dec <matrix_mul_const+0x7c>
    2da0:	4f11                	li	t5,4
    2da2:	03e28e63          	beq	t0,t5,2dde <matrix_mul_const+0x6e>
    2da6:	4f95                	li	t6,5
    2da8:	03f28463          	beq	t0,t6,2dd0 <matrix_mul_const+0x60>
    2dac:	4719                	li	a4,6
    2dae:	00e28a63          	beq	t0,a4,2dc2 <matrix_mul_const+0x52>
    2db2:	3316478b          	th.lurh	a5,a2,a7,1
    2db6:	02d782bb          	mulw	t0,a5,a3
    2dba:	0018879b          	addiw	a5,a7,1
    2dbe:	5515d28b          	th.surw	t0,a1,a7,2
    2dc2:	32f64e0b          	th.lurh	t3,a2,a5,1
    2dc6:	02de03bb          	mulw	t2,t3,a3
    2dca:	54f5d38b          	th.surw	t2,a1,a5,2
    2dce:	2785                	addiw	a5,a5,1
    2dd0:	32f64e8b          	th.lurh	t4,a2,a5,1
    2dd4:	02de8f3b          	mulw	t5,t4,a3
    2dd8:	54f5df0b          	th.surw	t5,a1,a5,2
    2ddc:	2785                	addiw	a5,a5,1
    2dde:	32f64f8b          	th.lurh	t6,a2,a5,1
    2de2:	02df873b          	mulw	a4,t6,a3
    2de6:	54f5d70b          	th.surw	a4,a1,a5,2
    2dea:	2785                	addiw	a5,a5,1
    2dec:	32f6428b          	th.lurh	t0,a2,a5,1
    2df0:	02d28e3b          	mulw	t3,t0,a3
    2df4:	54f5de0b          	th.surw	t3,a1,a5,2
    2df8:	2785                	addiw	a5,a5,1
    2dfa:	32f6438b          	th.lurh	t2,a2,a5,1
    2dfe:	02d38ebb          	mulw	t4,t2,a3
    2e02:	54f5de8b          	th.surw	t4,a1,a5,2
    2e06:	2785                	addiw	a5,a5,1
    2e08:	32f64f0b          	th.lurh	t5,a2,a5,1
    2e0c:	02df0fbb          	mulw	t6,t5,a3
    2e10:	54f5df8b          	th.surw	t6,a1,a5,2
    2e14:	2785                	addiw	a5,a5,1
    2e16:	08f80363          	beq	a6,a5,2e9c <matrix_mul_const+0x12c>
    2e1a:	32f6470b          	th.lurh	a4,a2,a5,1
    2e1e:	00178e1b          	addiw	t3,a5,1
    2e22:	33c6438b          	th.lurh	t2,a2,t3,1
    2e26:	02d702bb          	mulw	t0,a4,a3
    2e2a:	001e0f1b          	addiw	t5,t3,1
    2e2e:	33e64f8b          	th.lurh	t6,a2,t5,1
    2e32:	02d38ebb          	mulw	t4,t2,a3
    2e36:	54f5d28b          	th.surw	t0,a1,a5,2
    2e3a:	001f029b          	addiw	t0,t5,1
    2e3e:	3256470b          	th.lurh	a4,a2,t0,1
    2e42:	0012839b          	addiw	t2,t0,1
    2e46:	02df87bb          	mulw	a5,t6,a3
    2e4a:	55c5de8b          	th.surw	t4,a1,t3,2
    2e4e:	32764e8b          	th.lurh	t4,a2,t2,1
    2e52:	02d70e3b          	mulw	t3,a4,a3
    2e56:	00138f9b          	addiw	t6,t2,1
    2e5a:	55e5d78b          	th.surw	a5,a1,t5,2
    2e5e:	33f6478b          	th.lurh	a5,a2,t6,1
    2e62:	02de8f3b          	mulw	t5,t4,a3
    2e66:	5455de0b          	th.surw	t3,a1,t0,2
    2e6a:	001f8e1b          	addiw	t3,t6,1
    2e6e:	33c6470b          	th.lurh	a4,a2,t3,1
    2e72:	02d782bb          	mulw	t0,a5,a3
    2e76:	001e079b          	addiw	a5,t3,1
    2e7a:	5475df0b          	th.surw	t5,a1,t2,2
    2e7e:	32f64f0b          	th.lurh	t5,a2,a5,1
    2e82:	02d703bb          	mulw	t2,a4,a3
    2e86:	55f5d28b          	th.surw	t0,a1,t6,2
    2e8a:	02df0fbb          	mulw	t6,t5,a3
    2e8e:	55c5d38b          	th.surw	t2,a1,t3,2
    2e92:	54f5df8b          	th.surw	t6,a1,a5,2
    2e96:	2785                	addiw	a5,a5,1
    2e98:	f8f811e3          	bne	a6,a5,2e1a <matrix_mul_const+0xaa>
    2e9c:	2305                	addiw	t1,t1,1
    2e9e:	011508bb          	addw	a7,a0,a7
    2ea2:	0105083b          	addw	a6,a0,a6
    2ea6:	ec651de3          	bne	a0,t1,2d80 <matrix_mul_const+0x10>
    2eaa:	8082                	ret
    2eac:	00000013          	nop

0000000000002eb0 <matrix_add_const>:
    2eb0:	12050b63          	beqz	a0,2fe6 <matrix_add_const+0x136>
    2eb4:	3c06370b          	th.extu	a4,a2,15,0
    2eb8:	4801                	li	a6,0
    2eba:	862a                	mv	a2,a0
    2ebc:	4881                	li	a7,0
    2ebe:	0001                	nop
    2ec0:	410606b3          	sub	a3,a2,a6
    2ec4:	0076f293          	andi	t0,a3,7
    2ec8:	87c2                	mv	a5,a6
    2eca:	08028863          	beqz	t0,2f5a <matrix_add_const+0xaa>
    2ece:	4305                	li	t1,1
    2ed0:	06628c63          	beq	t0,t1,2f48 <matrix_add_const+0x98>
    2ed4:	4389                	li	t2,2
    2ed6:	06728263          	beq	t0,t2,2f3a <matrix_add_const+0x8a>
    2eda:	4e0d                	li	t3,3
    2edc:	05c28863          	beq	t0,t3,2f2c <matrix_add_const+0x7c>
    2ee0:	4e91                	li	t4,4
    2ee2:	03d28e63          	beq	t0,t4,2f1e <matrix_add_const+0x6e>
    2ee6:	4f15                	li	t5,5
    2ee8:	03e28463          	beq	t0,t5,2f10 <matrix_add_const+0x60>
    2eec:	4f99                	li	t6,6
    2eee:	01f28a63          	beq	t0,t6,2f02 <matrix_add_const+0x52>
    2ef2:	b305c78b          	th.lurhu	a5,a1,a6,1
    2ef6:	00e786bb          	addw	a3,a5,a4
    2efa:	3305d68b          	th.surh	a3,a1,a6,1
    2efe:	0018079b          	addiw	a5,a6,1
    2f02:	b2f5c28b          	th.lurhu	t0,a1,a5,1
    2f06:	00e2833b          	addw	t1,t0,a4
    2f0a:	32f5d30b          	th.surh	t1,a1,a5,1
    2f0e:	2785                	addiw	a5,a5,1
    2f10:	b2f5c38b          	th.lurhu	t2,a1,a5,1
    2f14:	00e38e3b          	addw	t3,t2,a4
    2f18:	32f5de0b          	th.surh	t3,a1,a5,1
    2f1c:	2785                	addiw	a5,a5,1
    2f1e:	b2f5ce8b          	th.lurhu	t4,a1,a5,1
    2f22:	00ee8f3b          	addw	t5,t4,a4
    2f26:	32f5df0b          	th.surh	t5,a1,a5,1
    2f2a:	2785                	addiw	a5,a5,1
    2f2c:	b2f5cf8b          	th.lurhu	t6,a1,a5,1
    2f30:	00ef86bb          	addw	a3,t6,a4
    2f34:	32f5d68b          	th.surh	a3,a1,a5,1
    2f38:	2785                	addiw	a5,a5,1
    2f3a:	b2f5c28b          	th.lurhu	t0,a1,a5,1
    2f3e:	00e2833b          	addw	t1,t0,a4
    2f42:	32f5d30b          	th.surh	t1,a1,a5,1
    2f46:	2785                	addiw	a5,a5,1
    2f48:	b2f5c38b          	th.lurhu	t2,a1,a5,1
    2f4c:	00e38e3b          	addw	t3,t2,a4
    2f50:	32f5de0b          	th.surh	t3,a1,a5,1
    2f54:	2785                	addiw	a5,a5,1
    2f56:	08f60263          	beq	a2,a5,2fda <matrix_add_const+0x12a>
    2f5a:	b2f5ce8b          	th.lurhu	t4,a1,a5,1
    2f5e:	00178f9b          	addiw	t6,a5,1
    2f62:	001f831b          	addiw	t1,t6,1
    2f66:	00ee8f3b          	addw	t5,t4,a4
    2f6a:	32f5df0b          	th.surh	t5,a1,a5,1
    2f6e:	b3f5c68b          	th.lurhu	a3,a1,t6,1
    2f72:	0013079b          	addiw	a5,t1,1
    2f76:	00e682bb          	addw	t0,a3,a4
    2f7a:	33f5d28b          	th.surh	t0,a1,t6,1
    2f7e:	b265c38b          	th.lurhu	t2,a1,t1,1
    2f82:	00178f9b          	addiw	t6,a5,1
    2f86:	00e38e3b          	addw	t3,t2,a4
    2f8a:	3265de0b          	th.surh	t3,a1,t1,1
    2f8e:	b2f5ce8b          	th.lurhu	t4,a1,a5,1
    2f92:	001f831b          	addiw	t1,t6,1
    2f96:	00ee8f3b          	addw	t5,t4,a4
    2f9a:	32f5df0b          	th.surh	t5,a1,a5,1
    2f9e:	b3f5c68b          	th.lurhu	a3,a1,t6,1
    2fa2:	0013079b          	addiw	a5,t1,1
    2fa6:	00e682bb          	addw	t0,a3,a4
    2faa:	33f5d28b          	th.surh	t0,a1,t6,1
    2fae:	b265c38b          	th.lurhu	t2,a1,t1,1
    2fb2:	00e38e3b          	addw	t3,t2,a4
    2fb6:	3265de0b          	th.surh	t3,a1,t1,1
    2fba:	b2f5ce8b          	th.lurhu	t4,a1,a5,1
    2fbe:	00ee8f3b          	addw	t5,t4,a4
    2fc2:	32f5df0b          	th.surh	t5,a1,a5,1
    2fc6:	2785                	addiw	a5,a5,1
    2fc8:	b2f5c38b          	th.lurhu	t2,a1,a5,1
    2fcc:	00e38e3b          	addw	t3,t2,a4
    2fd0:	32f5de0b          	th.surh	t3,a1,a5,1
    2fd4:	2785                	addiw	a5,a5,1
    2fd6:	f8f612e3          	bne	a2,a5,2f5a <matrix_add_const+0xaa>
    2fda:	2885                	addiw	a7,a7,1
    2fdc:	0105083b          	addw	a6,a0,a6
    2fe0:	9e29                	addw	a2,a2,a0
    2fe2:	ed151fe3          	bne	a0,a7,2ec0 <matrix_add_const+0x10>
    2fe6:	8082                	ret
    2fe8:	00000013          	nop
    2fec:	00000013          	nop

0000000000002ff0 <matrix_mul_vect>:
    2ff0:	7c053e8b          	th.extu	t4,a0,31,0
    2ff4:	4881                	li	a7,0
    2ff6:	4e01                	li	t3,0
    2ff8:	16050d63          	beqz	a0,3172 <matrix_mul_vect+0x182>
    2ffc:	00000013          	nop
    3000:	007ef793          	andi	a5,t4,7
    3004:	4701                	li	a4,0
    3006:	4801                	li	a6,0
    3008:	c7d5                	beqz	a5,30b4 <matrix_mul_vect+0xc4>
    300a:	4305                	li	t1,1
    300c:	08678663          	beq	a5,t1,3098 <matrix_mul_vect+0xa8>
    3010:	4f09                	li	t5,2
    3012:	07e78a63          	beq	a5,t5,3086 <matrix_mul_vect+0x96>
    3016:	428d                	li	t0,3
    3018:	04578e63          	beq	a5,t0,3074 <matrix_mul_vect+0x84>
    301c:	4391                	li	t2,4
    301e:	04778263          	beq	a5,t2,3062 <matrix_mul_vect+0x72>
    3022:	4f95                	li	t6,5
    3024:	03f78663          	beq	a5,t6,3050 <matrix_mul_vect+0x60>
    3028:	4f19                	li	t5,6
    302a:	01e78a63          	beq	a5,t5,303e <matrix_mul_vect+0x4e>
    302e:	b316428b          	th.lurhu	t0,a2,a7,1
    3032:	0006d783          	lhu	a5,0(a3)
    3036:	883a                	mv	a6,a4
    3038:	871a                	mv	a4,t1
    303a:	28f2980b          	th.mulah	a6,t0,a5
    303e:	0117033b          	addw	t1,a4,a7
    3042:	a2e6cf8b          	th.lrhu	t6,a3,a4,1
    3046:	b266438b          	th.lurhu	t2,a2,t1,1
    304a:	0705                	addi	a4,a4,1
    304c:	29f3980b          	th.mulah	a6,t2,t6
    3050:	01170f3b          	addw	t5,a4,a7
    3054:	a2e6c78b          	th.lrhu	a5,a3,a4,1
    3058:	b3e6428b          	th.lurhu	t0,a2,t5,1
    305c:	0705                	addi	a4,a4,1
    305e:	28f2980b          	th.mulah	a6,t0,a5
    3062:	0117033b          	addw	t1,a4,a7
    3066:	a2e6cf8b          	th.lrhu	t6,a3,a4,1
    306a:	b266438b          	th.lurhu	t2,a2,t1,1
    306e:	0705                	addi	a4,a4,1
    3070:	29f3980b          	th.mulah	a6,t2,t6
    3074:	01170f3b          	addw	t5,a4,a7
    3078:	a2e6c78b          	th.lrhu	a5,a3,a4,1
    307c:	b3e6428b          	th.lurhu	t0,a2,t5,1
    3080:	0705                	addi	a4,a4,1
    3082:	28f2980b          	th.mulah	a6,t0,a5
    3086:	0117033b          	addw	t1,a4,a7
    308a:	a2e6cf8b          	th.lrhu	t6,a3,a4,1
    308e:	b266438b          	th.lurhu	t2,a2,t1,1
    3092:	0705                	addi	a4,a4,1
    3094:	29f3980b          	th.mulah	a6,t2,t6
    3098:	01170f3b          	addw	t5,a4,a7
    309c:	a2e6c30b          	th.lrhu	t1,a3,a4,1
    30a0:	b3e6428b          	th.lurhu	t0,a2,t5,1
    30a4:	87c2                	mv	a5,a6
    30a6:	83ba                	mv	t2,a4
    30a8:	2862978b          	th.mulah	a5,t0,t1
    30ac:	0705                	addi	a4,a4,1
    30ae:	883e                	mv	a6,a5
    30b0:	0aee8563          	beq	t4,a4,315a <matrix_mul_vect+0x16a>
    30b4:	01170fbb          	addw	t6,a4,a7
    30b8:	b3f64f0b          	th.lurhu	t5,a2,t6,1
    30bc:	a2e6c28b          	th.lrhu	t0,a3,a4,1
    30c0:	87c2                	mv	a5,a6
    30c2:	00170813          	addi	a6,a4,1
    30c6:	285f178b          	th.mulah	a5,t5,t0
    30ca:	0118033b          	addw	t1,a6,a7
    30ce:	b266438b          	th.lurhu	t2,a2,t1,1
    30d2:	a306cf8b          	th.lrhu	t6,a3,a6,1
    30d6:	00270f13          	addi	t5,a4,2
    30da:	011f02bb          	addw	t0,t5,a7
    30de:	29f3978b          	th.mulah	a5,t2,t6
    30e2:	b256430b          	th.lurhu	t1,a2,t0,1
    30e6:	a3e6c80b          	th.lrhu	a6,a3,t5,1
    30ea:	00370393          	addi	t2,a4,3
    30ee:	01138fbb          	addw	t6,t2,a7
    30f2:	2903178b          	th.mulah	a5,t1,a6
    30f6:	b3f64f0b          	th.lurhu	t5,a2,t6,1
    30fa:	a276c28b          	th.lrhu	t0,a3,t2,1
    30fe:	00470813          	addi	a6,a4,4
    3102:	0118033b          	addw	t1,a6,a7
    3106:	285f178b          	th.mulah	a5,t5,t0
    310a:	b266438b          	th.lurhu	t2,a2,t1,1
    310e:	a306cf8b          	th.lrhu	t6,a3,a6,1
    3112:	00570f13          	addi	t5,a4,5
    3116:	011f02bb          	addw	t0,t5,a7
    311a:	29f3978b          	th.mulah	a5,t2,t6
    311e:	b256430b          	th.lurhu	t1,a2,t0,1
    3122:	a3e6c80b          	th.lrhu	a6,a3,t5,1
    3126:	00670393          	addi	t2,a4,6
    312a:	01138fbb          	addw	t6,t2,a7
    312e:	2903178b          	th.mulah	a5,t1,a6
    3132:	b3f64f0b          	th.lurhu	t5,a2,t6,1
    3136:	a276c28b          	th.lrhu	t0,a3,t2,1
    313a:	00770393          	addi	t2,a4,7
    313e:	0113833b          	addw	t1,t2,a7
    3142:	285f178b          	th.mulah	a5,t5,t0
    3146:	a276c80b          	th.lrhu	a6,a3,t2,1
    314a:	b2664f8b          	th.lurhu	t6,a2,t1,1
    314e:	0721                	addi	a4,a4,8
    3150:	290f978b          	th.mulah	a5,t6,a6
    3154:	883e                	mv	a6,a5
    3156:	f4ee9fe3          	bne	t4,a4,30b4 <matrix_mul_vect+0xc4>
    315a:	45c5d78b          	th.srw	a5,a1,t3,2
    315e:	011508bb          	addw	a7,a0,a7
    3162:	001e0793          	addi	a5,t3,1
    3166:	007e0563          	beq	t3,t2,3170 <matrix_mul_vect+0x180>
    316a:	8e3e                	mv	t3,a5
    316c:	bd51                	j	3000 <matrix_mul_vect+0x10>
    316e:	0001                	nop
    3170:	8082                	ret
    3172:	8082                	ret
    3174:	00000013          	nop
    3178:	00000013          	nop
    317c:	00000013          	nop

0000000000003180 <matrix_mul_matrix>:
    3180:	8eae                	mv	t4,a1
    3182:	8832                	mv	a6,a2
    3184:	85b6                	mv	a1,a3
    3186:	832a                	mv	t1,a0
    3188:	4e01                	li	t3,0
    318a:	4f81                	li	t6,0
    318c:	cd69                	beqz	a0,3266 <matrix_mul_matrix+0xe6>
    318e:	0001                	nop
    3190:	4881                	li	a7,0
    3192:	0001                	nop
    3194:	00000013          	nop
    3198:	41c30633          	sub	a2,t1,t3
    319c:	00367393          	andi	t2,a2,3
    31a0:	01c88f3b          	addw	t5,a7,t3
    31a4:	86c6                	mv	a3,a7
    31a6:	87f2                	mv	a5,t3
    31a8:	4701                	li	a4,0
    31aa:	04038663          	beqz	t2,31f6 <matrix_mul_matrix+0x76>
    31ae:	4285                	li	t0,1
    31b0:	02538763          	beq	t2,t0,31de <matrix_mul_matrix+0x5e>
    31b4:	4609                	li	a2,2
    31b6:	00c38c63          	beq	t2,a2,31ce <matrix_mul_matrix+0x4e>
    31ba:	b3c8468b          	th.lurhu	a3,a6,t3,1
    31be:	b315c78b          	th.lurhu	a5,a1,a7,1
    31c2:	28f6970b          	th.mulah	a4,a3,a5
    31c6:	001e079b          	addiw	a5,t3,1
    31ca:	011506bb          	addw	a3,a0,a7
    31ce:	b2f8438b          	th.lurhu	t2,a6,a5,1
    31d2:	b2d5c28b          	th.lurhu	t0,a1,a3,1
    31d6:	2785                	addiw	a5,a5,1
    31d8:	9ea9                	addw	a3,a3,a0
    31da:	2853970b          	th.mulah	a4,t2,t0
    31de:	b2f8438b          	th.lurhu	t2,a6,a5,1
    31e2:	b2d5c28b          	th.lurhu	t0,a1,a3,1
    31e6:	863a                	mv	a2,a4
    31e8:	2785                	addiw	a5,a5,1
    31ea:	2853960b          	th.mulah	a2,t2,t0
    31ee:	9ea9                	addw	a3,a3,a0
    31f0:	8732                	mv	a4,a2
    31f2:	04f30663          	beq	t1,a5,323e <matrix_mul_matrix+0xbe>
    31f6:	b2f8438b          	th.lurhu	t2,a6,a5,1
    31fa:	b2d5c28b          	th.lurhu	t0,a1,a3,1
    31fe:	2785                	addiw	a5,a5,1
    3200:	9ea9                	addw	a3,a3,a0
    3202:	2853970b          	th.mulah	a4,t2,t0
    3206:	b2d5c60b          	th.lurhu	a2,a1,a3,1
    320a:	b2f8438b          	th.lurhu	t2,a6,a5,1
    320e:	9ea9                	addw	a3,a3,a0
    3210:	2785                	addiw	a5,a5,1
    3212:	28c3970b          	th.mulah	a4,t2,a2
    3216:	b2f8428b          	th.lurhu	t0,a6,a5,1
    321a:	b2d5c38b          	th.lurhu	t2,a1,a3,1
    321e:	2785                	addiw	a5,a5,1
    3220:	9ea9                	addw	a3,a3,a0
    3222:	2872970b          	th.mulah	a4,t0,t2
    3226:	b2f8428b          	th.lurhu	t0,a6,a5,1
    322a:	2785                	addiw	a5,a5,1
    322c:	863a                	mv	a2,a4
    322e:	b2d5c70b          	th.lurhu	a4,a1,a3,1
    3232:	9ea9                	addw	a3,a3,a0
    3234:	28e2960b          	th.mulah	a2,t0,a4
    3238:	8732                	mv	a4,a2
    323a:	faf31ee3          	bne	t1,a5,31f6 <matrix_mul_matrix+0x76>
    323e:	55eed60b          	th.surw	a2,t4,t5,2
    3242:	00188f1b          	addiw	t5,a7,1
    3246:	01e50563          	beq	a0,t5,3250 <matrix_mul_matrix+0xd0>
    324a:	88fa                	mv	a7,t5
    324c:	b7b1                	j	3198 <matrix_mul_matrix+0x18>
    324e:	0001                	nop
    3250:	001f861b          	addiw	a2,t6,1
    3254:	01c50e3b          	addw	t3,a0,t3
    3258:	0065033b          	addw	t1,a0,t1
    325c:	011f8463          	beq	t6,a7,3264 <matrix_mul_matrix+0xe4>
    3260:	8fb2                	mv	t6,a2
    3262:	b73d                	j	3190 <matrix_mul_matrix+0x10>
    3264:	8082                	ret
    3266:	8082                	ret
    3268:	00000013          	nop
    326c:	00000013          	nop

0000000000003270 <matrix_mul_matrix_bitextract>:
    3270:	8eae                	mv	t4,a1
    3272:	8832                	mv	a6,a2
    3274:	85b6                	mv	a1,a3
    3276:	832a                	mv	t1,a0
    3278:	4e01                	li	t3,0
    327a:	4f81                	li	t6,0
    327c:	12050763          	beqz	a0,33aa <matrix_mul_matrix_bitextract+0x13a>
    3280:	4881                	li	a7,0
    3282:	0001                	nop
    3284:	00000013          	nop
    3288:	41c30733          	sub	a4,t1,t3
    328c:	00377393          	andi	t2,a4,3
    3290:	01c88f3b          	addw	t5,a7,t3
    3294:	86c6                	mv	a3,a7
    3296:	87f2                	mv	a5,t3
    3298:	4281                	li	t0,0
    329a:	06038863          	beqz	t2,330a <matrix_mul_matrix_bitextract+0x9a>
    329e:	4605                	li	a2,1
    32a0:	04c38363          	beq	t2,a2,32e6 <matrix_mul_matrix_bitextract+0x76>
    32a4:	4709                	li	a4,2
    32a6:	02e38263          	beq	t2,a4,32ca <matrix_mul_matrix_bitextract+0x5a>
    32aa:	33c8478b          	th.lurh	a5,a6,t3,1
    32ae:	3315c28b          	th.lurh	t0,a1,a7,1
    32b2:	025786bb          	mulw	a3,a5,t0
    32b6:	001e079b          	addiw	a5,t3,1
    32ba:	1426b38b          	th.extu	t2,a3,5,2
    32be:	2c56b60b          	th.extu	a2,a3,11,5
    32c2:	02c382bb          	mulw	t0,t2,a2
    32c6:	011506bb          	addw	a3,a0,a7
    32ca:	32d5c38b          	th.lurh	t2,a1,a3,1
    32ce:	32f8470b          	th.lurh	a4,a6,a5,1
    32d2:	9ea9                	addw	a3,a3,a0
    32d4:	2785                	addiw	a5,a5,1
    32d6:	0277073b          	mulw	a4,a4,t2
    32da:	1427360b          	th.extu	a2,a4,5,2
    32de:	2c57338b          	th.extu	t2,a4,11,5
    32e2:	2476128b          	th.mulaw	t0,a2,t2
    32e6:	32d5c60b          	th.lurh	a2,a1,a3,1
    32ea:	32f8470b          	th.lurh	a4,a6,a5,1
    32ee:	2785                	addiw	a5,a5,1
    32f0:	9ea9                	addw	a3,a3,a0
    32f2:	02c7073b          	mulw	a4,a4,a2
    32f6:	1427338b          	th.extu	t2,a4,5,2
    32fa:	2c57360b          	th.extu	a2,a4,11,5
    32fe:	8716                	mv	a4,t0
    3300:	24c3970b          	th.mulaw	a4,t2,a2
    3304:	82ba                	mv	t0,a4
    3306:	06f30e63          	beq	t1,a5,3382 <matrix_mul_matrix_bitextract+0x112>
    330a:	32f8438b          	th.lurh	t2,a6,a5,1
    330e:	32d5c60b          	th.lurh	a2,a1,a3,1
    3312:	2785                	addiw	a5,a5,1
    3314:	9ea9                	addw	a3,a3,a0
    3316:	02c3873b          	mulw	a4,t2,a2
    331a:	1427338b          	th.extu	t2,a4,5,2
    331e:	2c57360b          	th.extu	a2,a4,11,5
    3322:	8716                	mv	a4,t0
    3324:	24c3970b          	th.mulaw	a4,t2,a2
    3328:	32d5c28b          	th.lurh	t0,a1,a3,1
    332c:	32f8438b          	th.lurh	t2,a6,a5,1
    3330:	9ea9                	addw	a3,a3,a0
    3332:	2785                	addiw	a5,a5,1
    3334:	0253863b          	mulw	a2,t2,t0
    3338:	1426338b          	th.extu	t2,a2,5,2
    333c:	2c56328b          	th.extu	t0,a2,11,5
    3340:	2453970b          	th.mulaw	a4,t2,t0
    3344:	32f8460b          	th.lurh	a2,a6,a5,1
    3348:	32d5c38b          	th.lurh	t2,a1,a3,1
    334c:	2785                	addiw	a5,a5,1
    334e:	9ea9                	addw	a3,a3,a0
    3350:	0276063b          	mulw	a2,a2,t2
    3354:	1426328b          	th.extu	t0,a2,5,2
    3358:	2c56338b          	th.extu	t2,a2,11,5
    335c:	2472970b          	th.mulaw	a4,t0,t2
    3360:	32f8460b          	th.lurh	a2,a6,a5,1
    3364:	32d5c28b          	th.lurh	t0,a1,a3,1
    3368:	2785                	addiw	a5,a5,1
    336a:	9ea9                	addw	a3,a3,a0
    336c:	025603bb          	mulw	t2,a2,t0
    3370:	1423b28b          	th.extu	t0,t2,5,2
    3374:	2c53b60b          	th.extu	a2,t2,11,5
    3378:	24c2970b          	th.mulaw	a4,t0,a2
    337c:	82ba                	mv	t0,a4
    337e:	f8f316e3          	bne	t1,a5,330a <matrix_mul_matrix_bitextract+0x9a>
    3382:	55eed70b          	th.surw	a4,t4,t5,2
    3386:	00188f1b          	addiw	t5,a7,1
    338a:	01e50563          	beq	a0,t5,3394 <matrix_mul_matrix_bitextract+0x124>
    338e:	88fa                	mv	a7,t5
    3390:	bde5                	j	3288 <matrix_mul_matrix_bitextract+0x18>
    3392:	0001                	nop
    3394:	001f871b          	addiw	a4,t6,1
    3398:	01c50e3b          	addw	t3,a0,t3
    339c:	0065033b          	addw	t1,a0,t1
    33a0:	011f8463          	beq	t6,a7,33a8 <matrix_mul_matrix_bitextract+0x138>
    33a4:	8fba                	mv	t6,a4
    33a6:	bde9                	j	3280 <matrix_mul_matrix_bitextract+0x10>
    33a8:	8082                	ret
    33aa:	8082                	ret
    33ac:	0000                	unimp
	...

00000000000033b0 <barebones_clock>:
    33b0:	000417b7          	lui	a5,0x41
    33b4:	fb878293          	addi	t0,a5,-72 # 40fb8 <stop_time_val>
    33b8:	0002a503          	lw	a0,0(t0)
    33bc:	0042a303          	lw	t1,4(t0)
    33c0:	4065053b          	subw	a0,a0,t1
    33c4:	8082                	ret
    33c6:	00000013          	nop
    33ca:	00000013          	nop
    33ce:	0001                	nop

00000000000033d0 <start_time>:
    33d0:	000417b7          	lui	a5,0x41
    33d4:	fb878293          	addi	t0,a5,-72 # 40fb8 <stop_time_val>
    33d8:	e0d2c70b          	th.lwd	a4,a3,(t0),0,3
    33dc:	40d7033b          	subw	t1,a4,a3
    33e0:	0062a223          	sw	t1,4(t0)
    33e4:	8082                	ret
    33e6:	00000013          	nop
    33ea:	00000013          	nop
    33ee:	0001                	nop

00000000000033f0 <stop_time>:
    33f0:	000417b7          	lui	a5,0x41
    33f4:	fb878293          	addi	t0,a5,-72 # 40fb8 <stop_time_val>
    33f8:	e0d2c70b          	th.lwd	a4,a3,(t0),0,3
    33fc:	40d7033b          	subw	t1,a4,a3
    3400:	0062a023          	sw	t1,0(t0)
    3404:	8082                	ret
    3406:	00000013          	nop
    340a:	00000013          	nop
    340e:	0001                	nop

0000000000003410 <get_time>:
    3410:	000417b7          	lui	a5,0x41
    3414:	fb878293          	addi	t0,a5,-72 # 40fb8 <stop_time_val>
    3418:	0002a503          	lw	a0,0(t0)
    341c:	0042a303          	lw	t1,4(t0)
    3420:	4065053b          	subw	a0,a0,t1
    3424:	8082                	ret
    3426:	00000013          	nop
    342a:	00000013          	nop
    342e:	0001                	nop

0000000000003430 <time_in_secs>:
    3430:	05f5e7b7          	lui	a5,0x5f5e
    3434:	1007829b          	addiw	t0,a5,256 # 5f5e100 <__kernel_stack+0x5e70100>
    3438:	0255553b          	divuw	a0,a0,t0
    343c:	8082                	ret
    343e:	0001                	nop

0000000000003440 <portable_init>:
    3440:	000417b7          	lui	a5,0x41
    3444:	fb878293          	addi	t0,a5,-72 # 40fb8 <stop_time_val>
    3448:	e0d2c70b          	th.lwd	a4,a3,(t0),0,3
    344c:	4385                	li	t2,1
    344e:	00750023          	sb	t2,0(a0)
    3452:	40d7033b          	subw	t1,a4,a3
    3456:	0062a223          	sw	t1,4(t0)
    345a:	8082                	ret
    345c:	00000013          	nop

0000000000003460 <portable_fini>:
    3460:	00050023          	sb	zero,0(a0)
    3464:	8082                	ret
	...

0000000000003470 <core_bench_state>:
    3470:	7131                	addi	sp,sp,-192
    3472:	8fae                	mv	t6,a1
    3474:	ecee                	sd	s11,88(sp)
    3476:	f0ea                	sd	s10,96(sp)
    3478:	f4e6                	sd	s9,104(sp)
    347a:	f8e2                	sd	s8,112(sp)
    347c:	fcde                	sd	s7,120(sp)
    347e:	e15a                	sd	s6,128(sp)
    3480:	e556                	sd	s5,136(sp)
    3482:	e952                	sd	s4,144(sp)
    3484:	ed4e                	sd	s3,152(sp)
    3486:	f14a                	sd	s2,160(sp)
    3488:	f526                	sd	s1,168(sp)
    348a:	f922                	sd	s0,176(sp)
    348c:	fd06                	sd	ra,184(sp)
    348e:	000fce03          	lbu	t3,0(t6)
    3492:	e802                	sd	zero,16(sp)
    3494:	ec02                	sd	zero,24(sp)
    3496:	f002                	sd	zero,32(sp)
    3498:	f402                	sd	zero,40(sp)
    349a:	f802                	sd	zero,48(sp)
    349c:	fc02                	sd	zero,56(sp)
    349e:	e082                	sd	zero,64(sp)
    34a0:	e482                	sd	zero,72(sp)
    34a2:	e03a                	sd	a4,0(sp)
    34a4:	8eaa                	mv	t4,a0
    34a6:	85be                	mv	a1,a5
    34a8:	8a36                	mv	s4,a3
    34aa:	700e0263          	beqz	t3,3bae <core_bench_state+0x73e>
    34ae:	877e                	mv	a4,t6
    34b0:	87f2                	mv	a5,t3
    34b2:	4881                	li	a7,0
    34b4:	4901                	li	s2,0
    34b6:	4281                	li	t0,0
    34b8:	4401                	li	s0,0
    34ba:	4381                	li	t2,0
    34bc:	4b01                	li	s6,0
    34be:	4c01                	li	s8,0
    34c0:	4c81                	li	s9,0
    34c2:	4981                	li	s3,0
    34c4:	4481                	li	s1,0
    34c6:	4501                	li	a0,0
    34c8:	4a81                	li	s5,0
    34ca:	4d01                	li	s10,0
    34cc:	4b81                	li	s7,0
    34ce:	01010813          	addi	a6,sp,16
    34d2:	02c00313          	li	t1,44
    34d6:	02e00693          	li	a3,46
    34da:	04500d93          	li	s11,69
    34de:	4f25                	li	t5,9
    34e0:	e472                	sd	t3,8(sp)
    34e2:	0001                	nop
    34e4:	00000013          	nop
    34e8:	72678f63          	beq	a5,t1,3c26 <core_bench_state+0x7b6>
    34ec:	30d78e63          	beq	a5,a3,3808 <core_bench_state+0x398>
    34f0:	1af6e863          	bltu	a3,a5,36a0 <core_bench_state+0x230>
    34f4:	fd578e1b          	addiw	t3,a5,-43
    34f8:	0fde7793          	andi	a5,t3,253
    34fc:	2c078263          	beqz	a5,37c0 <core_bench_state+0x350>
    3500:	4505                	li	a0,1
    3502:	2b85                	addiw	s7,s7,1
    3504:	2a85                	addiw	s5,s5,1
    3506:	0705                	addi	a4,a4,1
    3508:	8d2a                	mv	s10,a0
    350a:	87aa                	mv	a5,a0
    350c:	00000013          	nop
    3510:	54f84e0b          	th.lurw	t3,a6,a5,2
    3514:	2e05                	addiw	t3,t3,1
    3516:	54f85e0b          	th.surw	t3,a6,a5,2
    351a:	00074783          	lbu	a5,0(a4)
    351e:	f7e9                	bnez	a5,34e8 <core_bench_state+0x78>
    3520:	6e22                	ld	t3,8(sp)
    3522:	00088363          	beqz	a7,3528 <core_bench_state+0xb8>
    3526:	c4ca                	sw	s2,72(sp)
    3528:	00028363          	beqz	t0,352e <core_bench_state+0xbe>
    352c:	de22                	sw	s0,60(sp)
    352e:	00038363          	beqz	t2,3534 <core_bench_state+0xc4>
    3532:	c2da                	sw	s6,68(sp)
    3534:	000c0363          	beqz	s8,353a <core_bench_state+0xca>
    3538:	c0e6                	sw	s9,64(sp)
    353a:	00098363          	beqz	s3,3540 <core_bench_state+0xd0>
    353e:	dc26                	sw	s1,56(sp)
    3540:	c111                	beqz	a0,3544 <core_bench_state+0xd4>
    3542:	d856                	sw	s5,48(sp)
    3544:	000d0363          	beqz	s10,354a <core_bench_state+0xda>
    3548:	da5e                	sw	s7,52(sp)
    354a:	7c0eba8b          	th.extu	s5,t4,31,0
    354e:	015f8333          	add	t1,t6,s5
    3552:	2e6ff463          	bgeu	t6,t1,383a <core_bench_state+0x3ca>
    3556:	6982                	ld	s3,0(sp)
    3558:	4485                	li	s1,1
    355a:	8dfe                	mv	s11,t6
    355c:	72999c63          	bne	s3,s1,3c94 <core_bench_state+0x824>
    3560:	ffffcf13          	not	t5,t6
    3564:	01e30c33          	add	s8,t1,t5
    3568:	007c7b13          	andi	s6,s8,7
    356c:	02c00e93          	li	t4,44
    3570:	0a0b0063          	beqz	s6,3610 <core_bench_state+0x1a0>
    3574:	01de0663          	beq	t3,t4,3580 <core_bench_state+0x110>
    3578:	00ce4733          	xor	a4,t3,a2
    357c:	00ef8023          	sb	a4,0(t6)
    3580:	001f8d93          	addi	s11,t6,1
    3584:	2a6df763          	bgeu	s11,t1,3832 <core_bench_state+0x3c2>
    3588:	4405                	li	s0,1
    358a:	000dce03          	lbu	t3,0(s11)
    358e:	088b0163          	beq	s6,s0,3610 <core_bench_state+0x1a0>
    3592:	4509                	li	a0,2
    3594:	06ab0663          	beq	s6,a0,3600 <core_bench_state+0x190>
    3598:	490d                	li	s2,3
    359a:	052b0b63          	beq	s6,s2,35f0 <core_bench_state+0x180>
    359e:	4b91                	li	s7,4
    35a0:	057b0063          	beq	s6,s7,35e0 <core_bench_state+0x170>
    35a4:	4d15                	li	s10,5
    35a6:	03ab0563          	beq	s6,s10,35d0 <core_bench_state+0x160>
    35aa:	4899                	li	a7,6
    35ac:	011b0a63          	beq	s6,a7,35c0 <core_bench_state+0x150>
    35b0:	01de0663          	beq	t3,t4,35bc <core_bench_state+0x14c>
    35b4:	00ce42b3          	xor	t0,t3,a2
    35b8:	005d8023          	sb	t0,0(s11)
    35bc:	881dce0b          	th.lbuib	t3,(s11),1,0
    35c0:	01de0663          	beq	t3,t4,35cc <core_bench_state+0x15c>
    35c4:	00ce43b3          	xor	t2,t3,a2
    35c8:	007d8023          	sb	t2,0(s11)
    35cc:	881dce0b          	th.lbuib	t3,(s11),1,0
    35d0:	01de0663          	beq	t3,t4,35dc <core_bench_state+0x16c>
    35d4:	00ce4e33          	xor	t3,t3,a2
    35d8:	01cd8023          	sb	t3,0(s11)
    35dc:	881dce0b          	th.lbuib	t3,(s11),1,0
    35e0:	01de0663          	beq	t3,t4,35ec <core_bench_state+0x17c>
    35e4:	00ce4ab3          	xor	s5,t3,a2
    35e8:	015d8023          	sb	s5,0(s11)
    35ec:	881dce0b          	th.lbuib	t3,(s11),1,0
    35f0:	01de0663          	beq	t3,t4,35fc <core_bench_state+0x18c>
    35f4:	00ce44b3          	xor	s1,t3,a2
    35f8:	009d8023          	sb	s1,0(s11)
    35fc:	881dce0b          	th.lbuib	t3,(s11),1,0
    3600:	01de0663          	beq	t3,t4,360c <core_bench_state+0x19c>
    3604:	00ce49b3          	xor	s3,t3,a2
    3608:	013d8023          	sb	s3,0(s11)
    360c:	881dce0b          	th.lbuib	t3,(s11),1,0
    3610:	01de0663          	beq	t3,t4,361c <core_bench_state+0x1ac>
    3614:	00ce4cb3          	xor	s9,t3,a2
    3618:	019d8023          	sb	s9,0(s11)
    361c:	001d8693          	addi	a3,s11,1
    3620:	2066f963          	bgeu	a3,t1,3832 <core_bench_state+0x3c2>
    3624:	001dc503          	lbu	a0,1(s11)
    3628:	01d50663          	beq	a0,t4,3634 <core_bench_state+0x1c4>
    362c:	00c548b3          	xor	a7,a0,a2
    3630:	011d80a3          	sb	a7,1(s11)
    3634:	0016cd83          	lbu	s11,1(a3)
    3638:	01dd8663          	beq	s11,t4,3644 <core_bench_state+0x1d4>
    363c:	00cdc7b3          	xor	a5,s11,a2
    3640:	00f680a3          	sb	a5,1(a3)
    3644:	0026c983          	lbu	s3,2(a3)
    3648:	01d98663          	beq	s3,t4,3654 <core_bench_state+0x1e4>
    364c:	00c9c433          	xor	s0,s3,a2
    3650:	00868123          	sb	s0,2(a3)
    3654:	0036c903          	lbu	s2,3(a3)
    3658:	01d90663          	beq	s2,t4,3664 <core_bench_state+0x1f4>
    365c:	00c94c33          	xor	s8,s2,a2
    3660:	018681a3          	sb	s8,3(a3)
    3664:	0046ce03          	lbu	t3,4(a3)
    3668:	01de0663          	beq	t3,t4,3674 <core_bench_state+0x204>
    366c:	00ce4d33          	xor	s10,t3,a2
    3670:	01a68223          	sb	s10,4(a3)
    3674:	0056cb83          	lbu	s7,5(a3)
    3678:	01db8663          	beq	s7,t4,3684 <core_bench_state+0x214>
    367c:	00cbcab3          	xor	s5,s7,a2
    3680:	015682a3          	sb	s5,5(a3)
    3684:	0066c703          	lbu	a4,6(a3)
    3688:	01d70663          	beq	a4,t4,3694 <core_bench_state+0x224>
    368c:	00c74f33          	xor	t5,a4,a2
    3690:	01e68323          	sb	t5,6(a3)
    3694:	0076ce03          	lbu	t3,7(a3)
    3698:	00768d93          	addi	s11,a3,7
    369c:	bf95                	j	3610 <core_bench_state+0x1a0>
    369e:	0001                	nop
    36a0:	fd07879b          	addiw	a5,a5,-48
    36a4:	0ff7f513          	zext.b	a0,a5
    36a8:	e4af6ce3          	bltu	t5,a0,3500 <core_bench_state+0x90>
    36ac:	8817478b          	th.lbuib	a5,(a4),1,0
    36b0:	2a85                	addiw	s5,s5,1
    36b2:	cbf5                	beqz	a5,37a6 <core_bench_state+0x336>
    36b4:	58678063          	beq	a5,t1,3c34 <core_bench_state+0x7c4>
    36b8:	00d78e63          	beq	a5,a3,36d4 <core_bench_state+0x264>
    36bc:	fd078e1b          	addiw	t3,a5,-48
    36c0:	0ffe7513          	zext.b	a0,t3
    36c4:	0caf7e63          	bgeu	t5,a0,37a0 <core_bench_state+0x330>
    36c8:	4c05                	li	s8,1
    36ca:	2c85                	addiw	s9,s9,1
    36cc:	0705                	addi	a4,a4,1
    36ce:	8562                	mv	a0,s8
    36d0:	87e2                	mv	a5,s8
    36d2:	bd3d                	j	3510 <core_bench_state+0xa0>
    36d4:	00174503          	lbu	a0,1(a4)
    36d8:	2c85                	addiw	s9,s9,1
    36da:	00170e13          	addi	t3,a4,1
    36de:	60050b63          	beqz	a0,3cf4 <core_bench_state+0x884>
    36e2:	60650f63          	beq	a0,t1,3d00 <core_bench_state+0x890>
    36e6:	4c05                	li	s8,1
    36e8:	0df57713          	andi	a4,a0,223
    36ec:	03b70063          	beq	a4,s11,370c <core_bench_state+0x29c>
    36f0:	fd05051b          	addiw	a0,a0,-48
    36f4:	0ff57793          	zext.b	a5,a0
    36f8:	0aff7a63          	bgeu	t5,a5,37ac <core_bench_state+0x33c>
    36fc:	4385                	li	t2,1
    36fe:	2b05                	addiw	s6,s6,1
    3700:	001e0713          	addi	a4,t3,1
    3704:	851e                	mv	a0,t2
    3706:	879e                	mv	a5,t2
    3708:	b521                	j	3510 <core_bench_state+0xa0>
    370a:	0001                	nop
    370c:	001e4383          	lbu	t2,1(t3)
    3710:	2b05                	addiw	s6,s6,1
    3712:	001e0713          	addi	a4,t3,1
    3716:	56038263          	beqz	t2,3c7a <core_bench_state+0x80a>
    371a:	5a638c63          	beq	t2,t1,3cd2 <core_bench_state+0x862>
    371e:	fd53829b          	addiw	t0,t2,-43
    3722:	0fd2f793          	andi	a5,t0,253
    3726:	2405                	addiw	s0,s0,1
    3728:	002e0713          	addi	a4,t3,2
    372c:	c791                	beqz	a5,3738 <core_bench_state+0x2c8>
    372e:	4285                	li	t0,1
    3730:	8396                	mv	t2,t0
    3732:	8516                	mv	a0,t0
    3734:	8796                	mv	a5,t0
    3736:	bbe9                	j	3510 <core_bench_state+0xa0>
    3738:	002e4503          	lbu	a0,2(t3)
    373c:	54050363          	beqz	a0,3c82 <core_bench_state+0x812>
    3740:	58650363          	beq	a0,t1,3cc6 <core_bench_state+0x856>
    3744:	fd05089b          	addiw	a7,a0,-48
    3748:	0ff8f393          	zext.b	t2,a7
    374c:	2905                	addiw	s2,s2,1
    374e:	003e0713          	addi	a4,t3,3
    3752:	007f7963          	bgeu	t5,t2,3764 <core_bench_state+0x2f4>
    3756:	4885                	li	a7,1
    3758:	82c6                	mv	t0,a7
    375a:	83c6                	mv	t2,a7
    375c:	8546                	mv	a0,a7
    375e:	87c6                	mv	a5,a7
    3760:	bb45                	j	3510 <core_bench_state+0xa0>
    3762:	0001                	nop
    3764:	003e4783          	lbu	a5,3(t3)
    3768:	c78d                	beqz	a5,3792 <core_bench_state+0x322>
    376a:	4a678463          	beq	a5,t1,3c12 <core_bench_state+0x7a2>
    376e:	fd078e1b          	addiw	t3,a5,-48
    3772:	0ffe7293          	zext.b	t0,t3
    3776:	005f7b63          	bgeu	t5,t0,378c <core_bench_state+0x31c>
    377a:	4885                	li	a7,1
    377c:	2b85                	addiw	s7,s7,1
    377e:	0705                	addi	a4,a4,1
    3780:	82c6                	mv	t0,a7
    3782:	83c6                	mv	t2,a7
    3784:	8546                	mv	a0,a7
    3786:	8d46                	mv	s10,a7
    3788:	87c6                	mv	a5,a7
    378a:	b359                	j	3510 <core_bench_state+0xa0>
    378c:	8817478b          	th.lbuib	a5,(a4),1,0
    3790:	ffe9                	bnez	a5,376a <core_bench_state+0x2fa>
    3792:	4885                	li	a7,1
    3794:	82c6                	mv	t0,a7
    3796:	83c6                	mv	t2,a7
    3798:	8546                	mv	a0,a7
    379a:	479d                	li	a5,7
    379c:	bb95                	j	3510 <core_bench_state+0xa0>
    379e:	0001                	nop
    37a0:	8817478b          	th.lbuib	a5,(a4),1,0
    37a4:	fb81                	bnez	a5,36b4 <core_bench_state+0x244>
    37a6:	4505                	li	a0,1
    37a8:	4791                	li	a5,4
    37aa:	b39d                	j	3510 <core_bench_state+0xa0>
    37ac:	881e450b          	th.lbuib	a0,(t3),1,0
    37b0:	c135                	beqz	a0,3814 <core_bench_state+0x3a4>
    37b2:	f2651be3          	bne	a0,t1,36e8 <core_bench_state+0x278>
    37b6:	8772                	mv	a4,t3
    37b8:	4505                	li	a0,1
    37ba:	4795                	li	a5,5
    37bc:	0705                	addi	a4,a4,1
    37be:	bb89                	j	3510 <core_bench_state+0xa0>
    37c0:	00174503          	lbu	a0,1(a4)
    37c4:	2a85                	addiw	s5,s5,1
    37c6:	00170e13          	addi	t3,a4,1
    37ca:	56050763          	beqz	a0,3d38 <core_bench_state+0x8c8>
    37ce:	54650f63          	beq	a0,t1,3d2c <core_bench_state+0x8bc>
    37d2:	fd05099b          	addiw	s3,a0,-48
    37d6:	0ff9f793          	zext.b	a5,s3
    37da:	00ff7b63          	bgeu	t5,a5,37f0 <core_bench_state+0x380>
    37de:	02d50f63          	beq	a0,a3,381c <core_bench_state+0x3ac>
    37e2:	4985                	li	s3,1
    37e4:	2485                	addiw	s1,s1,1
    37e6:	0709                	addi	a4,a4,2
    37e8:	854e                	mv	a0,s3
    37ea:	87ce                	mv	a5,s3
    37ec:	b315                	j	3510 <core_bench_state+0xa0>
    37ee:	0001                	nop
    37f0:	8827478b          	th.lbuib	a5,(a4),2,0
    37f4:	2485                	addiw	s1,s1,1
    37f6:	4985                	li	s3,1
    37f8:	4e078563          	beqz	a5,3ce2 <core_bench_state+0x872>
    37fc:	ea679ee3          	bne	a5,t1,36b8 <core_bench_state+0x248>
    3800:	854e                	mv	a0,s3
    3802:	4791                	li	a5,4
    3804:	0705                	addi	a4,a4,1
    3806:	b329                	j	3510 <core_bench_state+0xa0>
    3808:	00174503          	lbu	a0,1(a4)
    380c:	2a85                	addiw	s5,s5,1
    380e:	00170e13          	addi	t3,a4,1
    3812:	f145                	bnez	a0,37b2 <core_bench_state+0x342>
    3814:	8772                	mv	a4,t3
    3816:	4505                	li	a0,1
    3818:	4795                	li	a5,5
    381a:	b9dd                	j	3510 <core_bench_state+0xa0>
    381c:	00274503          	lbu	a0,2(a4)
    3820:	2485                	addiw	s1,s1,1
    3822:	00270e13          	addi	t3,a4,2
    3826:	52050563          	beqz	a0,3d50 <core_bench_state+0x8e0>
    382a:	50650c63          	beq	a0,t1,3d42 <core_bench_state+0x8d2>
    382e:	4985                	li	s3,1
    3830:	bd65                	j	36e8 <core_bench_state+0x278>
    3832:	000fce03          	lbu	t3,0(t6)
    3836:	400e0363          	beqz	t3,3c3c <core_bench_state+0x7cc>
    383a:	59c2                	lw	s3,48(sp)
    383c:	5b52                	lw	s6,52(sp)
    383e:	5462                	lw	s0,56(sp)
    3840:	56f2                	lw	a3,60(sp)
    3842:	4c06                	lw	s8,64(sp)
    3844:	4a96                	lw	s5,68(sp)
    3846:	44a6                	lw	s1,72(sp)
    3848:	87f2                	mv	a5,t3
    384a:	877e                	mv	a4,t6
    384c:	4601                	li	a2,0
    384e:	4281                	li	t0,0
    3850:	4381                	li	t2,0
    3852:	4b81                	li	s7,0
    3854:	4901                	li	s2,0
    3856:	4f01                	li	t5,0
    3858:	4c81                	li	s9,0
    385a:	02c00893          	li	a7,44
    385e:	02e00513          	li	a0,46
    3862:	04500d13          	li	s10,69
    3866:	4ea5                	li	t4,9
    3868:	3b178c63          	beq	a5,a7,3c20 <core_bench_state+0x7b0>
    386c:	30a78a63          	beq	a5,a0,3b80 <core_bench_state+0x710>
    3870:	1af56263          	bltu	a0,a5,3a14 <core_bench_state+0x5a4>
    3874:	fd578f1b          	addiw	t5,a5,-43
    3878:	0fdf7793          	andi	a5,t5,253
    387c:	2a078e63          	beqz	a5,3b38 <core_bench_state+0x6c8>
    3880:	4f05                	li	t5,1
    3882:	2b05                	addiw	s6,s6,1
    3884:	2985                	addiw	s3,s3,1
    3886:	0705                	addi	a4,a4,1
    3888:	8cfa                	mv	s9,t5
    388a:	87fa                	mv	a5,t5
    388c:	00000013          	nop
    3890:	54f84d8b          	th.lurw	s11,a6,a5,2
    3894:	2d85                	addiw	s11,s11,1
    3896:	54f85d8b          	th.surw	s11,a6,a5,2
    389a:	00074783          	lbu	a5,0(a4)
    389e:	f7e9                	bnez	a5,3868 <core_bench_state+0x3f8>
    38a0:	c211                	beqz	a2,38a4 <core_bench_state+0x434>
    38a2:	c4a6                	sw	s1,72(sp)
    38a4:	00028363          	beqz	t0,38aa <core_bench_state+0x43a>
    38a8:	de36                	sw	a3,60(sp)
    38aa:	00038363          	beqz	t2,38b0 <core_bench_state+0x440>
    38ae:	c2d6                	sw	s5,68(sp)
    38b0:	000b8363          	beqz	s7,38b6 <core_bench_state+0x446>
    38b4:	c0e2                	sw	s8,64(sp)
    38b6:	00090363          	beqz	s2,38bc <core_bench_state+0x44c>
    38ba:	dc22                	sw	s0,56(sp)
    38bc:	000f0363          	beqz	t5,38c2 <core_bench_state+0x452>
    38c0:	d84e                	sw	s3,48(sp)
    38c2:	000c8363          	beqz	s9,38c8 <core_bench_state+0x458>
    38c6:	da5a                	sw	s6,52(sp)
    38c8:	4542                	lw	a0,16(sp)
    38ca:	2e6ffa63          	bgeu	t6,t1,3bbe <core_bench_state+0x74e>
    38ce:	6402                	ld	s0,0(sp)
    38d0:	4985                	li	s3,1
    38d2:	39341063          	bne	s0,s3,3c52 <core_bench_state+0x7e2>
    38d6:	ffffcd13          	not	s10,t6
    38da:	01a30eb3          	add	t4,t1,s10
    38de:	007efb93          	andi	s7,t4,7
    38e2:	02c00893          	li	a7,44
    38e6:	080b8f63          	beqz	s7,3984 <core_bench_state+0x514>
    38ea:	011e0663          	beq	t3,a7,38f6 <core_bench_state+0x486>
    38ee:	014e4ab3          	xor	s5,t3,s4
    38f2:	015f8023          	sb	s5,0(t6)
    38f6:	0f85                	addi	t6,t6,1
    38f8:	2c6ff363          	bgeu	t6,t1,3bbe <core_bench_state+0x74e>
    38fc:	4705                	li	a4,1
    38fe:	000fce03          	lbu	t3,0(t6)
    3902:	08eb8163          	beq	s7,a4,3984 <core_bench_state+0x514>
    3906:	4689                	li	a3,2
    3908:	06db8663          	beq	s7,a3,3974 <core_bench_state+0x504>
    390c:	4f0d                	li	t5,3
    390e:	05eb8b63          	beq	s7,t5,3964 <core_bench_state+0x4f4>
    3912:	4491                	li	s1,4
    3914:	049b8063          	beq	s7,s1,3954 <core_bench_state+0x4e4>
    3918:	4b15                	li	s6,5
    391a:	036b8563          	beq	s7,s6,3944 <core_bench_state+0x4d4>
    391e:	4c99                	li	s9,6
    3920:	019b8a63          	beq	s7,s9,3934 <core_bench_state+0x4c4>
    3924:	011e0663          	beq	t3,a7,3930 <core_bench_state+0x4c0>
    3928:	014e4633          	xor	a2,t3,s4
    392c:	00cf8023          	sb	a2,0(t6)
    3930:	881fce0b          	th.lbuib	t3,(t6),1,0
    3934:	011e0663          	beq	t3,a7,3940 <core_bench_state+0x4d0>
    3938:	014e42b3          	xor	t0,t3,s4
    393c:	005f8023          	sb	t0,0(t6)
    3940:	881fce0b          	th.lbuib	t3,(t6),1,0
    3944:	011e0663          	beq	t3,a7,3950 <core_bench_state+0x4e0>
    3948:	014e43b3          	xor	t2,t3,s4
    394c:	007f8023          	sb	t2,0(t6)
    3950:	881fce0b          	th.lbuib	t3,(t6),1,0
    3954:	011e0663          	beq	t3,a7,3960 <core_bench_state+0x4f0>
    3958:	014e4db3          	xor	s11,t3,s4
    395c:	01bf8023          	sb	s11,0(t6)
    3960:	881fce0b          	th.lbuib	t3,(t6),1,0
    3964:	011e0663          	beq	t3,a7,3970 <core_bench_state+0x500>
    3968:	014e47b3          	xor	a5,t3,s4
    396c:	00ff8023          	sb	a5,0(t6)
    3970:	881fce0b          	th.lbuib	t3,(t6),1,0
    3974:	011e0663          	beq	t3,a7,3980 <core_bench_state+0x510>
    3978:	014e49b3          	xor	s3,t3,s4
    397c:	013f8023          	sb	s3,0(t6)
    3980:	881fce0b          	th.lbuib	t3,(t6),1,0
    3984:	011e0663          	beq	t3,a7,3990 <core_bench_state+0x520>
    3988:	014e4433          	xor	s0,t3,s4
    398c:	008f8023          	sb	s0,0(t6)
    3990:	001f8913          	addi	s2,t6,1
    3994:	22697563          	bgeu	s2,t1,3bbe <core_bench_state+0x74e>
    3998:	001fce03          	lbu	t3,1(t6)
    399c:	011e0663          	beq	t3,a7,39a8 <core_bench_state+0x538>
    39a0:	014e4d33          	xor	s10,t3,s4
    39a4:	01af80a3          	sb	s10,1(t6)
    39a8:	00194e83          	lbu	t4,1(s2)
    39ac:	011e8663          	beq	t4,a7,39b8 <core_bench_state+0x548>
    39b0:	014ecbb3          	xor	s7,t4,s4
    39b4:	017900a3          	sb	s7,1(s2)
    39b8:	00294a83          	lbu	s5,2(s2)
    39bc:	011a8663          	beq	s5,a7,39c8 <core_bench_state+0x558>
    39c0:	014ac733          	xor	a4,s5,s4
    39c4:	00e90123          	sb	a4,2(s2)
    39c8:	00394683          	lbu	a3,3(s2)
    39cc:	01168663          	beq	a3,a7,39d8 <core_bench_state+0x568>
    39d0:	0146cf33          	xor	t5,a3,s4
    39d4:	01e901a3          	sb	t5,3(s2)
    39d8:	00494483          	lbu	s1,4(s2)
    39dc:	01148663          	beq	s1,a7,39e8 <core_bench_state+0x578>
    39e0:	0144cb33          	xor	s6,s1,s4
    39e4:	01690223          	sb	s6,4(s2)
    39e8:	00594c83          	lbu	s9,5(s2)
    39ec:	011c8663          	beq	s9,a7,39f8 <core_bench_state+0x588>
    39f0:	014cc633          	xor	a2,s9,s4
    39f4:	00c902a3          	sb	a2,5(s2)
    39f8:	00694283          	lbu	t0,6(s2)
    39fc:	01128663          	beq	t0,a7,3a08 <core_bench_state+0x598>
    3a00:	0142c3b3          	xor	t2,t0,s4
    3a04:	00790323          	sb	t2,6(s2)
    3a08:	00794e03          	lbu	t3,7(s2)
    3a0c:	00790f93          	addi	t6,s2,7
    3a10:	bf95                	j	3984 <core_bench_state+0x514>
    3a12:	0001                	nop
    3a14:	fd07879b          	addiw	a5,a5,-48
    3a18:	0ff7fd93          	zext.b	s11,a5
    3a1c:	e7bee2e3          	bltu	t4,s11,3880 <core_bench_state+0x410>
    3a20:	8817478b          	th.lbuib	a5,(a4),1,0
    3a24:	2985                	addiw	s3,s3,1
    3a26:	cbf5                	beqz	a5,3b1a <core_bench_state+0x6aa>
    3a28:	21178263          	beq	a5,a7,3c2c <core_bench_state+0x7bc>
    3a2c:	00a78e63          	beq	a5,a0,3a48 <core_bench_state+0x5d8>
    3a30:	fd078d9b          	addiw	s11,a5,-48
    3a34:	0ffdff13          	zext.b	t5,s11
    3a38:	0deefe63          	bgeu	t4,t5,3b14 <core_bench_state+0x6a4>
    3a3c:	4b85                	li	s7,1
    3a3e:	2c05                	addiw	s8,s8,1
    3a40:	0705                	addi	a4,a4,1
    3a42:	8f5e                	mv	t5,s7
    3a44:	87de                	mv	a5,s7
    3a46:	b5a9                	j	3890 <core_bench_state+0x420>
    3a48:	00174f03          	lbu	t5,1(a4)
    3a4c:	2c05                	addiw	s8,s8,1
    3a4e:	00170d93          	addi	s11,a4,1
    3a52:	280f0c63          	beqz	t5,3cea <core_bench_state+0x87a>
    3a56:	2b1f0c63          	beq	t5,a7,3d0e <core_bench_state+0x89e>
    3a5a:	4b85                	li	s7,1
    3a5c:	0dff7713          	andi	a4,t5,223
    3a60:	03a70063          	beq	a4,s10,3a80 <core_bench_state+0x610>
    3a64:	fd0f0f1b          	addiw	t5,t5,-48
    3a68:	0fff7793          	zext.b	a5,t5
    3a6c:	0afefa63          	bgeu	t4,a5,3b20 <core_bench_state+0x6b0>
    3a70:	4385                	li	t2,1
    3a72:	2a85                	addiw	s5,s5,1
    3a74:	001d8713          	addi	a4,s11,1
    3a78:	8f1e                	mv	t5,t2
    3a7a:	879e                	mv	a5,t2
    3a7c:	bd11                	j	3890 <core_bench_state+0x420>
    3a7e:	0001                	nop
    3a80:	001dc383          	lbu	t2,1(s11)
    3a84:	2a85                	addiw	s5,s5,1
    3a86:	001d8713          	addi	a4,s11,1
    3a8a:	20038163          	beqz	t2,3c8c <core_bench_state+0x81c>
    3a8e:	23138763          	beq	t2,a7,3cbc <core_bench_state+0x84c>
    3a92:	fd53829b          	addiw	t0,t2,-43
    3a96:	0fd2f793          	andi	a5,t0,253
    3a9a:	2685                	addiw	a3,a3,1
    3a9c:	002d8713          	addi	a4,s11,2
    3aa0:	c791                	beqz	a5,3aac <core_bench_state+0x63c>
    3aa2:	4285                	li	t0,1
    3aa4:	8396                	mv	t2,t0
    3aa6:	8f16                	mv	t5,t0
    3aa8:	8796                	mv	a5,t0
    3aaa:	b3dd                	j	3890 <core_bench_state+0x420>
    3aac:	002dcf03          	lbu	t5,2(s11)
    3ab0:	1c0f0063          	beqz	t5,3c70 <core_bench_state+0x800>
    3ab4:	1f1f0e63          	beq	t5,a7,3cb0 <core_bench_state+0x840>
    3ab8:	fd0f061b          	addiw	a2,t5,-48
    3abc:	0ff67393          	zext.b	t2,a2
    3ac0:	2485                	addiw	s1,s1,1
    3ac2:	003d8713          	addi	a4,s11,3
    3ac6:	007ef963          	bgeu	t4,t2,3ad8 <core_bench_state+0x668>
    3aca:	4605                	li	a2,1
    3acc:	82b2                	mv	t0,a2
    3ace:	83b2                	mv	t2,a2
    3ad0:	8f32                	mv	t5,a2
    3ad2:	87b2                	mv	a5,a2
    3ad4:	bb75                	j	3890 <core_bench_state+0x420>
    3ad6:	0001                	nop
    3ad8:	003dc783          	lbu	a5,3(s11)
    3adc:	c78d                	beqz	a5,3b06 <core_bench_state+0x696>
    3ade:	13178363          	beq	a5,a7,3c04 <core_bench_state+0x794>
    3ae2:	fd078d9b          	addiw	s11,a5,-48
    3ae6:	0ffdf293          	zext.b	t0,s11
    3aea:	005efb63          	bgeu	t4,t0,3b00 <core_bench_state+0x690>
    3aee:	4605                	li	a2,1
    3af0:	2b05                	addiw	s6,s6,1
    3af2:	0705                	addi	a4,a4,1
    3af4:	82b2                	mv	t0,a2
    3af6:	83b2                	mv	t2,a2
    3af8:	8f32                	mv	t5,a2
    3afa:	8cb2                	mv	s9,a2
    3afc:	87b2                	mv	a5,a2
    3afe:	bb49                	j	3890 <core_bench_state+0x420>
    3b00:	8817478b          	th.lbuib	a5,(a4),1,0
    3b04:	ffe9                	bnez	a5,3ade <core_bench_state+0x66e>
    3b06:	4605                	li	a2,1
    3b08:	82b2                	mv	t0,a2
    3b0a:	83b2                	mv	t2,a2
    3b0c:	8f32                	mv	t5,a2
    3b0e:	479d                	li	a5,7
    3b10:	b341                	j	3890 <core_bench_state+0x420>
    3b12:	0001                	nop
    3b14:	8817478b          	th.lbuib	a5,(a4),1,0
    3b18:	fb81                	bnez	a5,3a28 <core_bench_state+0x5b8>
    3b1a:	4f05                	li	t5,1
    3b1c:	4791                	li	a5,4
    3b1e:	bb8d                	j	3890 <core_bench_state+0x420>
    3b20:	881dcf0b          	th.lbuib	t5,(s11),1,0
    3b24:	060f0563          	beqz	t5,3b8e <core_bench_state+0x71e>
    3b28:	f31f1ae3          	bne	t5,a7,3a5c <core_bench_state+0x5ec>
    3b2c:	876e                	mv	a4,s11
    3b2e:	4f05                	li	t5,1
    3b30:	4795                	li	a5,5
    3b32:	0705                	addi	a4,a4,1
    3b34:	bbb1                	j	3890 <core_bench_state+0x420>
    3b36:	0001                	nop
    3b38:	00174f03          	lbu	t5,1(a4)
    3b3c:	2985                	addiw	s3,s3,1
    3b3e:	00170d93          	addi	s11,a4,1
    3b42:	1c0f0c63          	beqz	t5,3d1a <core_bench_state+0x8aa>
    3b46:	1d1f0e63          	beq	t5,a7,3d22 <core_bench_state+0x8b2>
    3b4a:	fd0f091b          	addiw	s2,t5,-48
    3b4e:	0ff97793          	zext.b	a5,s2
    3b52:	00fefb63          	bgeu	t4,a5,3b68 <core_bench_state+0x6f8>
    3b56:	04af0163          	beq	t5,a0,3b98 <core_bench_state+0x728>
    3b5a:	4905                	li	s2,1
    3b5c:	2405                	addiw	s0,s0,1
    3b5e:	0709                	addi	a4,a4,2
    3b60:	8f4a                	mv	t5,s2
    3b62:	87ca                	mv	a5,s2
    3b64:	b335                	j	3890 <core_bench_state+0x420>
    3b66:	0001                	nop
    3b68:	8827478b          	th.lbuib	a5,(a4),2,0
    3b6c:	2405                	addiw	s0,s0,1
    3b6e:	4905                	li	s2,1
    3b70:	16078663          	beqz	a5,3cdc <core_bench_state+0x86c>
    3b74:	eb179ce3          	bne	a5,a7,3a2c <core_bench_state+0x5bc>
    3b78:	8f4a                	mv	t5,s2
    3b7a:	4791                	li	a5,4
    3b7c:	0705                	addi	a4,a4,1
    3b7e:	bb09                	j	3890 <core_bench_state+0x420>
    3b80:	00174f03          	lbu	t5,1(a4)
    3b84:	2985                	addiw	s3,s3,1
    3b86:	00170d93          	addi	s11,a4,1
    3b8a:	f80f1fe3          	bnez	t5,3b28 <core_bench_state+0x6b8>
    3b8e:	876e                	mv	a4,s11
    3b90:	4f05                	li	t5,1
    3b92:	4795                	li	a5,5
    3b94:	b9f5                	j	3890 <core_bench_state+0x420>
    3b96:	0001                	nop
    3b98:	00274f03          	lbu	t5,2(a4)
    3b9c:	2405                	addiw	s0,s0,1
    3b9e:	00270d93          	addi	s11,a4,2
    3ba2:	1a0f0d63          	beqz	t5,3d5c <core_bench_state+0x8ec>
    3ba6:	1d1f0063          	beq	t5,a7,3d66 <core_bench_state+0x8f6>
    3baa:	4905                	li	s2,1
    3bac:	bd45                	j	3a5c <core_bench_state+0x5ec>
    3bae:	7c05330b          	th.extu	t1,a0,31,0
    3bb2:	937e                	add	t1,t1,t6
    3bb4:	01010813          	addi	a6,sp,16
    3bb8:	4501                	li	a0,0
    3bba:	986feee3          	bltu	t6,t1,3556 <core_bench_state+0xe6>
    3bbe:	03010a13          	addi	s4,sp,48
    3bc2:	8c42                	mv	s8,a6
    3bc4:	a021                	j	3bcc <core_bench_state+0x75c>
    3bc6:	0001                	nop
    3bc8:	000c2503          	lw	a0,0(s8)
    3bcc:	0a5000ef          	jal	4470 <crcu32>
    3bd0:	85aa                	mv	a1,a0
    3bd2:	584a450b          	th.lwia	a0,(s4),4,0
    3bd6:	0c11                	addi	s8,s8,4
    3bd8:	099000ef          	jal	4470 <crcu32>
    3bdc:	05010f93          	addi	t6,sp,80
    3be0:	85aa                	mv	a1,a0
    3be2:	fffa13e3          	bne	s4,t6,3bc8 <core_bench_state+0x758>
    3be6:	74aa                	ld	s1,168(sp)
    3be8:	744a                	ld	s0,176(sp)
    3bea:	70ea                	ld	ra,184(sp)
    3bec:	6de6                	ld	s11,88(sp)
    3bee:	7d06                	ld	s10,96(sp)
    3bf0:	7ca6                	ld	s9,104(sp)
    3bf2:	7c46                	ld	s8,112(sp)
    3bf4:	7be6                	ld	s7,120(sp)
    3bf6:	6b0a                	ld	s6,128(sp)
    3bf8:	6aaa                	ld	s5,136(sp)
    3bfa:	6a4a                	ld	s4,144(sp)
    3bfc:	69ea                	ld	s3,152(sp)
    3bfe:	790a                	ld	s2,160(sp)
    3c00:	6129                	addi	sp,sp,192
    3c02:	8082                	ret
    3c04:	4605                	li	a2,1
    3c06:	82b2                	mv	t0,a2
    3c08:	83b2                	mv	t2,a2
    3c0a:	8f32                	mv	t5,a2
    3c0c:	479d                	li	a5,7
    3c0e:	0705                	addi	a4,a4,1
    3c10:	b141                	j	3890 <core_bench_state+0x420>
    3c12:	4885                	li	a7,1
    3c14:	82c6                	mv	t0,a7
    3c16:	83c6                	mv	t2,a7
    3c18:	8546                	mv	a0,a7
    3c1a:	479d                	li	a5,7
    3c1c:	0705                	addi	a4,a4,1
    3c1e:	b8cd                	j	3510 <core_bench_state+0xa0>
    3c20:	4781                	li	a5,0
    3c22:	0705                	addi	a4,a4,1
    3c24:	b1b5                	j	3890 <core_bench_state+0x420>
    3c26:	4781                	li	a5,0
    3c28:	0705                	addi	a4,a4,1
    3c2a:	b0dd                	j	3510 <core_bench_state+0xa0>
    3c2c:	4f05                	li	t5,1
    3c2e:	4791                	li	a5,4
    3c30:	0705                	addi	a4,a4,1
    3c32:	b9b9                	j	3890 <core_bench_state+0x420>
    3c34:	4505                	li	a0,1
    3c36:	4791                	li	a5,4
    3c38:	0705                	addi	a4,a4,1
    3c3a:	b8d9                	j	3510 <core_bench_state+0xa0>
    3c3c:	4542                	lw	a0,16(sp)
    3c3e:	c86fece3          	bltu	t6,t1,38d6 <core_bench_state+0x466>
    3c42:	bfb5                	j	3bbe <core_bench_state+0x74e>
    3c44:	000fce03          	lbu	t3,0(t6)
    3c48:	be0e19e3          	bnez	t3,383a <core_bench_state+0x3ca>
    3c4c:	4542                	lw	a0,16(sp)
    3c4e:	f66ff8e3          	bgeu	t6,t1,3bbe <core_bench_state+0x74e>
    3c52:	6c02                	ld	s8,0(sp)
    3c54:	02c00913          	li	s2,44
    3c58:	012e0663          	beq	t3,s2,3c64 <core_bench_state+0x7f4>
    3c5c:	014e4e33          	xor	t3,t3,s4
    3c60:	01cf8023          	sb	t3,0(t6)
    3c64:	9fe2                	add	t6,t6,s8
    3c66:	f46ffce3          	bgeu	t6,t1,3bbe <core_bench_state+0x74e>
    3c6a:	000fce03          	lbu	t3,0(t6)
    3c6e:	b7ed                	j	3c58 <core_bench_state+0x7e8>
    3c70:	4285                	li	t0,1
    3c72:	8396                	mv	t2,t0
    3c74:	8f16                	mv	t5,t0
    3c76:	4799                	li	a5,6
    3c78:	b921                	j	3890 <core_bench_state+0x420>
    3c7a:	4385                	li	t2,1
    3c7c:	851e                	mv	a0,t2
    3c7e:	478d                	li	a5,3
    3c80:	b841                	j	3510 <core_bench_state+0xa0>
    3c82:	4285                	li	t0,1
    3c84:	8396                	mv	t2,t0
    3c86:	8516                	mv	a0,t0
    3c88:	4799                	li	a5,6
    3c8a:	b059                	j	3510 <core_bench_state+0xa0>
    3c8c:	4385                	li	t2,1
    3c8e:	8f1e                	mv	t5,t2
    3c90:	478d                	li	a5,3
    3c92:	befd                	j	3890 <core_bench_state+0x420>
    3c94:	02c00c93          	li	s9,44
    3c98:	019e0663          	beq	t3,s9,3ca4 <core_bench_state+0x834>
    3c9c:	00ce46b3          	xor	a3,t3,a2
    3ca0:	00dd8023          	sb	a3,0(s11)
    3ca4:	9dce                	add	s11,s11,s3
    3ca6:	f86dffe3          	bgeu	s11,t1,3c44 <core_bench_state+0x7d4>
    3caa:	000dce03          	lbu	t3,0(s11)
    3cae:	b7ed                	j	3c98 <core_bench_state+0x828>
    3cb0:	4285                	li	t0,1
    3cb2:	8396                	mv	t2,t0
    3cb4:	8f16                	mv	t5,t0
    3cb6:	4799                	li	a5,6
    3cb8:	0705                	addi	a4,a4,1
    3cba:	bed9                	j	3890 <core_bench_state+0x420>
    3cbc:	4385                	li	t2,1
    3cbe:	8f1e                	mv	t5,t2
    3cc0:	478d                	li	a5,3
    3cc2:	0705                	addi	a4,a4,1
    3cc4:	b6f1                	j	3890 <core_bench_state+0x420>
    3cc6:	4285                	li	t0,1
    3cc8:	8396                	mv	t2,t0
    3cca:	8516                	mv	a0,t0
    3ccc:	4799                	li	a5,6
    3cce:	0705                	addi	a4,a4,1
    3cd0:	b081                	j	3510 <core_bench_state+0xa0>
    3cd2:	4385                	li	t2,1
    3cd4:	851e                	mv	a0,t2
    3cd6:	478d                	li	a5,3
    3cd8:	0705                	addi	a4,a4,1
    3cda:	b81d                	j	3510 <core_bench_state+0xa0>
    3cdc:	8f4a                	mv	t5,s2
    3cde:	4791                	li	a5,4
    3ce0:	be45                	j	3890 <core_bench_state+0x420>
    3ce2:	854e                	mv	a0,s3
    3ce4:	4791                	li	a5,4
    3ce6:	82bff06f          	j	3510 <core_bench_state+0xa0>
    3cea:	4b85                	li	s7,1
    3cec:	876e                	mv	a4,s11
    3cee:	8f5e                	mv	t5,s7
    3cf0:	4795                	li	a5,5
    3cf2:	be79                	j	3890 <core_bench_state+0x420>
    3cf4:	4c05                	li	s8,1
    3cf6:	8772                	mv	a4,t3
    3cf8:	8562                	mv	a0,s8
    3cfa:	4795                	li	a5,5
    3cfc:	815ff06f          	j	3510 <core_bench_state+0xa0>
    3d00:	8772                	mv	a4,t3
    3d02:	4c05                	li	s8,1
    3d04:	8562                	mv	a0,s8
    3d06:	4795                	li	a5,5
    3d08:	0705                	addi	a4,a4,1
    3d0a:	807ff06f          	j	3510 <core_bench_state+0xa0>
    3d0e:	876e                	mv	a4,s11
    3d10:	4b85                	li	s7,1
    3d12:	8f5e                	mv	t5,s7
    3d14:	4795                	li	a5,5
    3d16:	0705                	addi	a4,a4,1
    3d18:	bea5                	j	3890 <core_bench_state+0x420>
    3d1a:	876e                	mv	a4,s11
    3d1c:	4f05                	li	t5,1
    3d1e:	4789                	li	a5,2
    3d20:	be85                	j	3890 <core_bench_state+0x420>
    3d22:	876e                	mv	a4,s11
    3d24:	4f05                	li	t5,1
    3d26:	4789                	li	a5,2
    3d28:	0705                	addi	a4,a4,1
    3d2a:	b69d                	j	3890 <core_bench_state+0x420>
    3d2c:	8772                	mv	a4,t3
    3d2e:	4505                	li	a0,1
    3d30:	4789                	li	a5,2
    3d32:	0705                	addi	a4,a4,1
    3d34:	fdcff06f          	j	3510 <core_bench_state+0xa0>
    3d38:	8772                	mv	a4,t3
    3d3a:	4505                	li	a0,1
    3d3c:	4789                	li	a5,2
    3d3e:	fd2ff06f          	j	3510 <core_bench_state+0xa0>
    3d42:	8772                	mv	a4,t3
    3d44:	4985                	li	s3,1
    3d46:	854e                	mv	a0,s3
    3d48:	4795                	li	a5,5
    3d4a:	0705                	addi	a4,a4,1
    3d4c:	fc4ff06f          	j	3510 <core_bench_state+0xa0>
    3d50:	4985                	li	s3,1
    3d52:	8772                	mv	a4,t3
    3d54:	854e                	mv	a0,s3
    3d56:	4795                	li	a5,5
    3d58:	fb8ff06f          	j	3510 <core_bench_state+0xa0>
    3d5c:	4905                	li	s2,1
    3d5e:	876e                	mv	a4,s11
    3d60:	8f4a                	mv	t5,s2
    3d62:	4795                	li	a5,5
    3d64:	b635                	j	3890 <core_bench_state+0x420>
    3d66:	876e                	mv	a4,s11
    3d68:	4905                	li	s2,1
    3d6a:	8f4a                	mv	t5,s2
    3d6c:	4795                	li	a5,5
    3d6e:	0705                	addi	a4,a4,1
    3d70:	b605                	j	3890 <core_bench_state+0x420>
    3d72:	0001                	nop
    3d74:	00000013          	nop
    3d78:	00000013          	nop
    3d7c:	00000013          	nop

0000000000003d80 <core_init_state>:
    3d80:	fff50e9b          	addiw	t4,a0,-1
    3d84:	4f85                	li	t6,1
    3d86:	19dff963          	bgeu	t6,t4,3f18 <core_init_state+0x198>
    3d8a:	2585                	addiw	a1,a1,1
    3d8c:	3c05b68b          	th.extu	a3,a1,15,0
    3d90:	6e45                	lui	t3,0x11
    3d92:	4f1d                	li	t5,7
    3d94:	0076f713          	andi	a4,a3,7
    3d98:	4801                	li	a6,0
    3d9a:	ae8e0e13          	addi	t3,t3,-1304 # 10ae8 <intpat>
    3d9e:	4311                	li	t1,4
    3da0:	02c00293          	li	t0,44
    3da4:	3c06a78b          	th.ext	a5,a3,15,0
    3da8:	09e70763          	beq	a4,t5,3e36 <core_init_state+0xb6>
    3dac:	14e36e63          	bltu	t1,a4,3f08 <core_init_state+0x188>
    3db0:	ffd7059b          	addiw	a1,a4,-3
    3db4:	3c05b88b          	th.extu	a7,a1,15,0
    3db8:	151fe263          	bltu	t6,a7,3efc <core_init_state+0x17c>
    3dbc:	8be1                	andi	a5,a5,24
    3dbe:	00fe03b3          	add	t2,t3,a5
    3dc2:	0203b703          	ld	a4,32(t2)
    3dc6:	48a1                	li	a7,8
    3dc8:	0018059b          	addiw	a1,a6,1
    3dcc:	011585bb          	addw	a1,a1,a7
    3dd0:	07d5ff63          	bgeu	a1,t4,3e4e <core_init_state+0xce>
    3dd4:	00074383          	lbu	t2,0(a4)
    3dd8:	7c08378b          	th.extu	a5,a6,31,0
    3ddc:	97b2                	add	a5,a5,a2
    3dde:	1106538b          	th.surb	t2,a2,a6,0
    3de2:	00174803          	lbu	a6,1(a4)
    3de6:	010780a3          	sb	a6,1(a5)
    3dea:	00274383          	lbu	t2,2(a4)
    3dee:	00778123          	sb	t2,2(a5)
    3df2:	00374803          	lbu	a6,3(a4)
    3df6:	010781a3          	sb	a6,3(a5)
    3dfa:	02688263          	beq	a7,t1,3e1e <core_init_state+0x9e>
    3dfe:	00474383          	lbu	t2,4(a4)
    3e02:	00778223          	sb	t2,4(a5)
    3e06:	00574803          	lbu	a6,5(a4)
    3e0a:	010782a3          	sb	a6,5(a5)
    3e0e:	00674383          	lbu	t2,6(a4)
    3e12:	00778323          	sb	t2,6(a5)
    3e16:	00774703          	lbu	a4,7(a4)
    3e1a:	00e783a3          	sb	a4,7(a5)
    3e1e:	2685                	addiw	a3,a3,1
    3e20:	3c06b68b          	th.extu	a3,a3,15,0
    3e24:	1117d28b          	th.surb	t0,a5,a7,0
    3e28:	0076f713          	andi	a4,a3,7
    3e2c:	882e                	mv	a6,a1
    3e2e:	3c06a78b          	th.ext	a5,a3,15,0
    3e32:	f7e71de3          	bne	a4,t5,3dac <core_init_state+0x2c>
    3e36:	0187f893          	andi	a7,a5,24
    3e3a:	011e05b3          	add	a1,t3,a7
    3e3e:	71b8                	ld	a4,96(a1)
    3e40:	48a1                	li	a7,8
    3e42:	0018059b          	addiw	a1,a6,1
    3e46:	011585bb          	addw	a1,a1,a7
    3e4a:	f9d5e5e3          	bltu	a1,t4,3dd4 <core_init_state+0x54>
    3e4e:	0ca87763          	bgeu	a6,a0,3f1c <core_init_state+0x19c>
    3e52:	7c08328b          	th.extu	t0,a6,31,0
    3e56:	9616                	add	a2,a2,t0
    3e58:	40c8033b          	subw	t1,a6,a2
    3e5c:	87b2                	mv	a5,a2
    3e5e:	fff64693          	not	a3,a2
    3e62:	7c033e8b          	th.extu	t4,t1,31,0
    3e66:	41d68f33          	sub	t5,a3,t4
    3e6a:	1817d00b          	th.sbia	zero,(a5),1,0
    3e6e:	00af0fb3          	add	t6,t5,a0
    3e72:	00678e3b          	addw	t3,a5,t1
    3e76:	007ff813          	andi	a6,t6,7
    3e7a:	0aae7263          	bgeu	t3,a0,3f1e <core_init_state+0x19e>
    3e7e:	04080863          	beqz	a6,3ece <core_init_state+0x14e>
    3e82:	4885                	li	a7,1
    3e84:	03180f63          	beq	a6,a7,3ec2 <core_init_state+0x142>
    3e88:	4709                	li	a4,2
    3e8a:	02e80a63          	beq	a6,a4,3ebe <core_init_state+0x13e>
    3e8e:	438d                	li	t2,3
    3e90:	02780563          	beq	a6,t2,3eba <core_init_state+0x13a>
    3e94:	4591                	li	a1,4
    3e96:	02b80063          	beq	a6,a1,3eb6 <core_init_state+0x136>
    3e9a:	4295                	li	t0,5
    3e9c:	00580b63          	beq	a6,t0,3eb2 <core_init_state+0x132>
    3ea0:	4699                	li	a3,6
    3ea2:	00d80663          	beq	a6,a3,3eae <core_init_state+0x12e>
    3ea6:	00078023          	sb	zero,0(a5)
    3eaa:	00260793          	addi	a5,a2,2
    3eae:	1817d00b          	th.sbia	zero,(a5),1,0
    3eb2:	1817d00b          	th.sbia	zero,(a5),1,0
    3eb6:	1817d00b          	th.sbia	zero,(a5),1,0
    3eba:	1817d00b          	th.sbia	zero,(a5),1,0
    3ebe:	1817d00b          	th.sbia	zero,(a5),1,0
    3ec2:	1817d00b          	th.sbia	zero,(a5),1,0
    3ec6:	0067863b          	addw	a2,a5,t1
    3eca:	04a67663          	bgeu	a2,a0,3f16 <core_init_state+0x196>
    3ece:	00078023          	sb	zero,0(a5)
    3ed2:	000780a3          	sb	zero,1(a5)
    3ed6:	00078123          	sb	zero,2(a5)
    3eda:	000781a3          	sb	zero,3(a5)
    3ede:	00078223          	sb	zero,4(a5)
    3ee2:	000782a3          	sb	zero,5(a5)
    3ee6:	00078323          	sb	zero,6(a5)
    3eea:	000783a3          	sb	zero,7(a5)
    3eee:	07a1                	addi	a5,a5,8
    3ef0:	00678ebb          	addw	t4,a5,t1
    3ef4:	fcaeede3          	bltu	t4,a0,3ece <core_init_state+0x14e>
    3ef8:	8082                	ret
    3efa:	0001                	nop
    3efc:	1037b70b          	th.extu	a4,a5,4,3
    3f00:	66ee470b          	th.lrd	a4,t3,a4,3
    3f04:	4891                	li	a7,4
    3f06:	b5c9                	j	3dc8 <core_init_state+0x48>
    3f08:	8be1                	andi	a5,a5,24
    3f0a:	00fe03b3          	add	t2,t3,a5
    3f0e:	0403b703          	ld	a4,64(t2)
    3f12:	48a1                	li	a7,8
    3f14:	bd55                	j	3dc8 <core_init_state+0x48>
    3f16:	8082                	ret
    3f18:	4801                	li	a6,0
    3f1a:	bf25                	j	3e52 <core_init_state+0xd2>
    3f1c:	8082                	ret
    3f1e:	8082                	ret

0000000000003f20 <core_state_transition>:
    3f20:	6114                	ld	a3,0(a0)
    3f22:	882a                	mv	a6,a0
    3f24:	0006c783          	lbu	a5,0(a3)
    3f28:	24078163          	beqz	a5,416a <core_state_transition+0x24a>
    3f2c:	02c00713          	li	a4,44
    3f30:	4501                	li	a0,0
    3f32:	1ce78b63          	beq	a5,a4,4108 <core_state_transition+0x1e8>
    3f36:	02e00513          	li	a0,46
    3f3a:	1ea78f63          	beq	a5,a0,4138 <core_state_transition+0x218>
    3f3e:	1cf56763          	bltu	a0,a5,410c <core_state_transition+0x1ec>
    3f42:	fd578f1b          	addiw	t5,a5,-43
    3f46:	0fdf7f93          	andi	t6,t5,253
    3f4a:	020f8363          	beqz	t6,3f70 <core_state_transition+0x50>
    3f4e:	0045a883          	lw	a7,4(a1)
    3f52:	0005ae83          	lw	t4,0(a1)
    3f56:	0685                	addi	a3,a3,1
    3f58:	00188e1b          	addiw	t3,a7,1
    3f5c:	001e861b          	addiw	a2,t4,1
    3f60:	4505                	li	a0,1
    3f62:	01c5a223          	sw	t3,4(a1)
    3f66:	c190                	sw	a2,0(a1)
    3f68:	00d83023          	sd	a3,0(a6)
    3f6c:	8082                	ret
    3f6e:	0001                	nop
    3f70:	419c                	lw	a5,0(a1)
    3f72:	00168613          	addi	a2,a3,1
    3f76:	0017829b          	addiw	t0,a5,1
    3f7a:	0055a023          	sw	t0,0(a1)
    3f7e:	0016c303          	lbu	t1,1(a3)
    3f82:	20030963          	beqz	t1,4194 <core_state_transition+0x274>
    3f86:	1ce30e63          	beq	t1,a4,4162 <core_state_transition+0x242>
    3f8a:	fd03071b          	addiw	a4,t1,-48
    3f8e:	0ff77393          	zext.b	t2,a4
    3f92:	48a5                	li	a7,9
    3f94:	0078fe63          	bgeu	a7,t2,3fb0 <core_state_transition+0x90>
    3f98:	1ca30063          	beq	t1,a0,4158 <core_state_transition+0x238>
    3f9c:	4590                	lw	a2,8(a1)
    3f9e:	0689                	addi	a3,a3,2
    3fa0:	4505                	li	a0,1
    3fa2:	00160e1b          	addiw	t3,a2,1
    3fa6:	01c5a423          	sw	t3,8(a1)
    3faa:	00d83023          	sd	a3,0(a6)
    3fae:	8082                	ret
    3fb0:	0085ae83          	lw	t4,8(a1)
    3fb4:	001e8f1b          	addiw	t5,t4,1
    3fb8:	01e5a423          	sw	t5,8(a1)
    3fbc:	88164f8b          	th.lbuib	t6,(a2),1,0
    3fc0:	160f8963          	beqz	t6,4132 <core_state_transition+0x212>
    3fc4:	02c00713          	li	a4,44
    3fc8:	1aef8d63          	beq	t6,a4,4182 <core_state_transition+0x262>
    3fcc:	02e00793          	li	a5,46
    3fd0:	02ff8663          	beq	t6,a5,3ffc <core_state_transition+0xdc>
    3fd4:	fd0f829b          	addiw	t0,t6,-48
    3fd8:	0ff2f313          	zext.b	t1,t0
    3fdc:	4725                	li	a4,9
    3fde:	fc677fe3          	bgeu	a4,t1,3fbc <core_state_transition+0x9c>
    3fe2:	0105a383          	lw	t2,16(a1)
    3fe6:	00160693          	addi	a3,a2,1
    3fea:	4505                	li	a0,1
    3fec:	0013889b          	addiw	a7,t2,1
    3ff0:	0115a823          	sw	a7,16(a1)
    3ff4:	00d83023          	sd	a3,0(a6)
    3ff8:	8082                	ret
    3ffa:	0001                	nop
    3ffc:	0105ae03          	lw	t3,16(a1)
    4000:	001e069b          	addiw	a3,t3,1
    4004:	c994                	sw	a3,16(a1)
    4006:	8816450b          	th.lbuib	a0,(a2),1,0
    400a:	14050363          	beqz	a0,4150 <core_state_transition+0x230>
    400e:	02c00713          	li	a4,44
    4012:	0ee50963          	beq	a0,a4,4104 <core_state_transition+0x1e4>
    4016:	0df57e93          	andi	t4,a0,223
    401a:	04500f13          	li	t5,69
    401e:	03ee8563          	beq	t4,t5,4048 <core_state_transition+0x128>
    4022:	fd050f9b          	addiw	t6,a0,-48
    4026:	0ffff793          	zext.b	a5,t6
    402a:	42a5                	li	t0,9
    402c:	fcf2fde3          	bgeu	t0,a5,4006 <core_state_transition+0xe6>
    4030:	0145a303          	lw	t1,20(a1)
    4034:	00160693          	addi	a3,a2,1
    4038:	4505                	li	a0,1
    403a:	0013039b          	addiw	t2,t1,1
    403e:	0075aa23          	sw	t2,20(a1)
    4042:	00d83023          	sd	a3,0(a6)
    4046:	8082                	ret
    4048:	0145a883          	lw	a7,20(a1)
    404c:	00160693          	addi	a3,a2,1
    4050:	00188e1b          	addiw	t3,a7,1
    4054:	01c5aa23          	sw	t3,20(a1)
    4058:	00164503          	lbu	a0,1(a2)
    405c:	10050b63          	beqz	a0,4172 <core_state_transition+0x252>
    4060:	02c00713          	li	a4,44
    4064:	10e50c63          	beq	a0,a4,417c <core_state_transition+0x25c>
    4068:	fd55069b          	addiw	a3,a0,-43
    406c:	0fd6fe93          	andi	t4,a3,253
    4070:	000e8e63          	beqz	t4,408c <core_state_transition+0x16c>
    4074:	00260693          	addi	a3,a2,2
    4078:	45d0                	lw	a2,12(a1)
    407a:	4505                	li	a0,1
    407c:	00160f1b          	addiw	t5,a2,1
    4080:	01e5a623          	sw	t5,12(a1)
    4084:	00d83023          	sd	a3,0(a6)
    4088:	8082                	ret
    408a:	0001                	nop
    408c:	00c5af83          	lw	t6,12(a1)
    4090:	00260693          	addi	a3,a2,2
    4094:	001f879b          	addiw	a5,t6,1
    4098:	c5dc                	sw	a5,12(a1)
    409a:	00264283          	lbu	t0,2(a2)
    409e:	0c028863          	beqz	t0,416e <core_state_transition+0x24e>
    40a2:	0ce28a63          	beq	t0,a4,4176 <core_state_transition+0x256>
    40a6:	fd02831b          	addiw	t1,t0,-48
    40aa:	0ff37393          	zext.b	t2,t1
    40ae:	4725                	li	a4,9
    40b0:	00777c63          	bgeu	a4,t2,40c8 <core_state_transition+0x1a8>
    40b4:	0185a883          	lw	a7,24(a1)
    40b8:	00360693          	addi	a3,a2,3
    40bc:	4505                	li	a0,1
    40be:	00188e1b          	addiw	t3,a7,1
    40c2:	01c5ac23          	sw	t3,24(a1)
    40c6:	b54d                	j	3f68 <core_state_transition+0x48>
    40c8:	4d88                	lw	a0,24(a1)
    40ca:	00150e9b          	addiw	t4,a0,1
    40ce:	01d5ac23          	sw	t4,24(a1)
    40d2:	8636                	mv	a2,a3
    40d4:	8816cf0b          	th.lbuib	t5,(a3),1,0
    40d8:	0a0f0c63          	beqz	t5,4190 <core_state_transition+0x270>
    40dc:	02c00f93          	li	t6,44
    40e0:	0bff0563          	beq	t5,t6,418a <core_state_transition+0x26a>
    40e4:	fd0f079b          	addiw	a5,t5,-48
    40e8:	0ff7f293          	zext.b	t0,a5
    40ec:	fe5773e3          	bgeu	a4,t0,40d2 <core_state_transition+0x1b2>
    40f0:	0045a303          	lw	t1,4(a1)
    40f4:	00260693          	addi	a3,a2,2
    40f8:	4505                	li	a0,1
    40fa:	0013039b          	addiw	t2,t1,1
    40fe:	0075a223          	sw	t2,4(a1)
    4102:	b59d                	j	3f68 <core_state_transition+0x48>
    4104:	86b2                	mv	a3,a2
    4106:	4515                	li	a0,5
    4108:	0685                	addi	a3,a3,1
    410a:	bdb9                	j	3f68 <core_state_transition+0x48>
    410c:	fd07839b          	addiw	t2,a5,-48
    4110:	0ff3f893          	zext.b	a7,t2
    4114:	4625                	li	a2,9
    4116:	e3166ce3          	bltu	a2,a7,3f4e <core_state_transition+0x2e>
    411a:	0005ae03          	lw	t3,0(a1)
    411e:	00168613          	addi	a2,a3,1
    4122:	001e0e9b          	addiw	t4,t3,1
    4126:	01d5a023          	sw	t4,0(a1)
    412a:	0016cf83          	lbu	t6,1(a3)
    412e:	e80f9de3          	bnez	t6,3fc8 <core_state_transition+0xa8>
    4132:	86b2                	mv	a3,a2
    4134:	4511                	li	a0,4
    4136:	bd0d                	j	3f68 <core_state_transition+0x48>
    4138:	0005a283          	lw	t0,0(a1)
    413c:	00168613          	addi	a2,a3,1
    4140:	0012831b          	addiw	t1,t0,1
    4144:	0065a023          	sw	t1,0(a1)
    4148:	0016c503          	lbu	a0,1(a3)
    414c:	ec0513e3          	bnez	a0,4012 <core_state_transition+0xf2>
    4150:	86b2                	mv	a3,a2
    4152:	4515                	li	a0,5
    4154:	bd11                	j	3f68 <core_state_transition+0x48>
    4156:	0001                	nop
    4158:	4594                	lw	a3,8(a1)
    415a:	0016851b          	addiw	a0,a3,1
    415e:	c588                	sw	a0,8(a1)
    4160:	b55d                	j	4006 <core_state_transition+0xe6>
    4162:	86b2                	mv	a3,a2
    4164:	4509                	li	a0,2
    4166:	0685                	addi	a3,a3,1
    4168:	b501                	j	3f68 <core_state_transition+0x48>
    416a:	4501                	li	a0,0
    416c:	bbf5                	j	3f68 <core_state_transition+0x48>
    416e:	4519                	li	a0,6
    4170:	bbe5                	j	3f68 <core_state_transition+0x48>
    4172:	450d                	li	a0,3
    4174:	bbd5                	j	3f68 <core_state_transition+0x48>
    4176:	4519                	li	a0,6
    4178:	0685                	addi	a3,a3,1
    417a:	b3fd                	j	3f68 <core_state_transition+0x48>
    417c:	450d                	li	a0,3
    417e:	0685                	addi	a3,a3,1
    4180:	b3e5                	j	3f68 <core_state_transition+0x48>
    4182:	86b2                	mv	a3,a2
    4184:	4511                	li	a0,4
    4186:	0685                	addi	a3,a3,1
    4188:	b3c5                	j	3f68 <core_state_transition+0x48>
    418a:	451d                	li	a0,7
    418c:	0685                	addi	a3,a3,1
    418e:	bbe9                	j	3f68 <core_state_transition+0x48>
    4190:	451d                	li	a0,7
    4192:	bbd9                	j	3f68 <core_state_transition+0x48>
    4194:	86b2                	mv	a3,a2
    4196:	4509                	li	a0,2
    4198:	bbc1                	j	3f68 <core_state_transition+0x48>
	...

00000000000041b0 <get_seed_32>:
    41b0:	4795                	li	a5,5
    41b2:	04a7e663          	bltu	a5,a0,41fe <get_seed_32+0x4e>
    41b6:	62c5                	lui	t0,0x11
    41b8:	b6828313          	addi	t1,t0,-1176 # 10b68 <errpat+0x20>
    41bc:	44a3438b          	th.lrw	t2,t1,a0,2
    41c0:	8382                	jr	t2
    41c2:	0001                	nop
    41c4:	00041537          	lui	a0,0x41
    41c8:	fc052503          	lw	a0,-64(a0) # 40fc0 <seed5_volatile>
    41cc:	8082                	ret
    41ce:	0001                	nop
    41d0:	00041737          	lui	a4,0x41
    41d4:	fc872503          	lw	a0,-56(a4) # 40fc8 <seed1_volatile>
    41d8:	8082                	ret
    41da:	0001                	nop
    41dc:	000416b7          	lui	a3,0x41
    41e0:	fc46a503          	lw	a0,-60(a3) # 40fc4 <seed2_volatile>
    41e4:	8082                	ret
    41e6:	0001                	nop
    41e8:	00040637          	lui	a2,0x40
    41ec:	01062503          	lw	a0,16(a2) # 40010 <seed3_volatile>
    41f0:	8082                	ret
    41f2:	0001                	nop
    41f4:	000405b7          	lui	a1,0x40
    41f8:	00c5a503          	lw	a0,12(a1) # 4000c <seed4_volatile>
    41fc:	8082                	ret
    41fe:	4501                	li	a0,0
    4200:	8082                	ret
    4202:	0001                	nop
    4204:	00000013          	nop
    4208:	00000013          	nop
    420c:	00000013          	nop

0000000000004210 <crcu8>:
    4210:	6829                	lui	a6,0xa
    4212:	00180313          	addi	t1,a6,1 # a001 <_vsnprintf+0x1431>
    4216:	00b54733          	xor	a4,a0,a1
    421a:	8185                	srli	a1,a1,0x1
    421c:	00177293          	andi	t0,a4,1
    4220:	0065c7b3          	xor	a5,a1,t1
    4224:	4055978b          	th.mveqz	a5,a1,t0
    4228:	00155613          	srli	a2,a0,0x1
    422c:	00f643b3          	xor	t2,a2,a5
    4230:	0017de13          	srli	t3,a5,0x1
    4234:	0013f893          	andi	a7,t2,1
    4238:	006e4f33          	xor	t5,t3,t1
    423c:	411e1f0b          	th.mveqz	t5,t3,a7
    4240:	00255693          	srli	a3,a0,0x2
    4244:	01e6c633          	xor	a2,a3,t5
    4248:	001f5713          	srli	a4,t5,0x1
    424c:	00167293          	andi	t0,a2,1
    4250:	006745b3          	xor	a1,a4,t1
    4254:	4057158b          	th.mveqz	a1,a4,t0
    4258:	00355f93          	srli	t6,a0,0x3
    425c:	8e9a                	mv	t4,t1
    425e:	0015d793          	srli	a5,a1,0x1
    4262:	00bfc333          	xor	t1,t6,a1
    4266:	00137693          	andi	a3,t1,1
    426a:	01d7c3b3          	xor	t2,a5,t4
    426e:	40d7938b          	th.mveqz	t2,a5,a3
    4272:	00455813          	srli	a6,a0,0x4
    4276:	00784e33          	xor	t3,a6,t2
    427a:	0013df93          	srli	t6,t2,0x1
    427e:	001e7f13          	andi	t5,t3,1
    4282:	01dfc2b3          	xor	t0,t6,t4
    4286:	41ef928b          	th.mveqz	t0,t6,t5
    428a:	00555893          	srli	a7,a0,0x5
    428e:	0058c633          	xor	a2,a7,t0
    4292:	0012d313          	srli	t1,t0,0x1
    4296:	01d34733          	xor	a4,t1,t4
    429a:	00167813          	andi	a6,a2,1
    429e:	4103170b          	th.mveqz	a4,t1,a6
    42a2:	00655593          	srli	a1,a0,0x6
    42a6:	00755793          	srli	a5,a0,0x7
    42aa:	00175393          	srli	t2,a4,0x1
    42ae:	00e5c533          	xor	a0,a1,a4
    42b2:	00157693          	andi	a3,a0,1
    42b6:	01d3c8b3          	xor	a7,t2,t4
    42ba:	40d3988b          	th.mveqz	a7,t2,a3
    42be:	0018d513          	srli	a0,a7,0x1
    42c2:	0117ce33          	xor	t3,a5,a7
    42c6:	001e7f13          	andi	t5,t3,1
    42ca:	01d54eb3          	xor	t4,a0,t4
    42ce:	43ee950b          	th.mvnez	a0,t4,t5
    42d2:	8082                	ret
    42d4:	00000013          	nop
    42d8:	00000013          	nop
    42dc:	00000013          	nop

00000000000042e0 <crcu16>:
    42e0:	0ff57793          	zext.b	a5,a0
    42e4:	6829                	lui	a6,0xa
    42e6:	00180313          	addi	t1,a6,1 # a001 <_vsnprintf+0x1431>
    42ea:	00b7c633          	xor	a2,a5,a1
    42ee:	0015d71b          	srliw	a4,a1,0x1
    42f2:	00167293          	andi	t0,a2,1
    42f6:	006743b3          	xor	t2,a4,t1
    42fa:	8185                	srli	a1,a1,0x1
    42fc:	4055938b          	th.mveqz	t2,a1,t0
    4300:	1c15368b          	th.extu	a3,a0,7,1
    4304:	0076ce33          	xor	t3,a3,t2
    4308:	0013df13          	srli	t5,t2,0x1
    430c:	001e7e93          	andi	t4,t3,1
    4310:	006f4fb3          	xor	t6,t5,t1
    4314:	41df1f8b          	th.mveqz	t6,t5,t4
    4318:	0027d893          	srli	a7,a5,0x2
    431c:	01f8c6b3          	xor	a3,a7,t6
    4320:	001fd593          	srli	a1,t6,0x1
    4324:	0016f613          	andi	a2,a3,1
    4328:	0065c733          	xor	a4,a1,t1
    432c:	40c5970b          	th.mveqz	a4,a1,a2
    4330:	0037d293          	srli	t0,a5,0x3
    4334:	00e2c3b3          	xor	t2,t0,a4
    4338:	00175e13          	srli	t3,a4,0x1
    433c:	0013f893          	andi	a7,t2,1
    4340:	006e4eb3          	xor	t4,t3,t1
    4344:	411e1e8b          	th.mveqz	t4,t3,a7
    4348:	0047d813          	srli	a6,a5,0x4
    434c:	01d84fb3          	xor	t6,a6,t4
    4350:	001ed693          	srli	a3,t4,0x1
    4354:	001ff293          	andi	t0,t6,1
    4358:	0066c733          	xor	a4,a3,t1
    435c:	4056970b          	th.mveqz	a4,a3,t0
    4360:	0057df13          	srli	t5,a5,0x5
    4364:	00ef45b3          	xor	a1,t5,a4
    4368:	00175393          	srli	t2,a4,0x1
    436c:	0015f813          	andi	a6,a1,1
    4370:	0063c8b3          	xor	a7,t2,t1
    4374:	4103988b          	th.mveqz	a7,t2,a6
    4378:	0067d613          	srli	a2,a5,0x6
    437c:	01164e33          	xor	t3,a2,a7
    4380:	0018df13          	srli	t5,a7,0x1
    4384:	001e7e93          	andi	t4,t3,1
    4388:	006f4fb3          	xor	t6,t5,t1
    438c:	41df1f8b          	th.mveqz	t6,t5,t4
    4390:	839d                	srli	a5,a5,0x7
    4392:	01f7c2b3          	xor	t0,a5,t6
    4396:	001fd713          	srli	a4,t6,0x1
    439a:	0012f613          	andi	a2,t0,1
    439e:	006746b3          	xor	a3,a4,t1
    43a2:	00855813          	srli	a6,a0,0x8
    43a6:	42c6970b          	th.mvnez	a4,a3,a2
    43aa:	00e845b3          	xor	a1,a6,a4
    43ae:	0017589b          	srliw	a7,a4,0x1
    43b2:	0068ce33          	xor	t3,a7,t1
    43b6:	0015f393          	andi	t2,a1,1
    43ba:	00175793          	srli	a5,a4,0x1
    43be:	427e178b          	th.mvnez	a5,t3,t2
    43c2:	8125                	srli	a0,a0,0x9
    43c4:	00f54f33          	xor	t5,a0,a5
    43c8:	0017d293          	srli	t0,a5,0x1
    43cc:	001f7f93          	andi	t6,t5,1
    43d0:	0062c633          	xor	a2,t0,t1
    43d4:	43f6128b          	th.mvnez	t0,a2,t6
    43d8:	00285e93          	srli	t4,a6,0x2
    43dc:	005ec733          	xor	a4,t4,t0
    43e0:	0012d893          	srli	a7,t0,0x1
    43e4:	00177393          	andi	t2,a4,1
    43e8:	0068c6b3          	xor	a3,a7,t1
    43ec:	4078968b          	th.mveqz	a3,a7,t2
    43f0:	00385593          	srli	a1,a6,0x3
    43f4:	00d5c7b3          	xor	a5,a1,a3
    43f8:	0016de93          	srli	t4,a3,0x1
    43fc:	0017fe13          	andi	t3,a5,1
    4400:	006ecf33          	xor	t5,t4,t1
    4404:	41ce9f0b          	th.mveqz	t5,t4,t3
    4408:	00485513          	srli	a0,a6,0x4
    440c:	01e542b3          	xor	t0,a0,t5
    4410:	001f5593          	srli	a1,t5,0x1
    4414:	0012f613          	andi	a2,t0,1
    4418:	0065c733          	xor	a4,a1,t1
    441c:	40c5970b          	th.mveqz	a4,a1,a2
    4420:	00585f93          	srli	t6,a6,0x5
    4424:	00efc8b3          	xor	a7,t6,a4
    4428:	00175693          	srli	a3,a4,0x1
    442c:	0018f513          	andi	a0,a7,1
    4430:	0066ce33          	xor	t3,a3,t1
    4434:	40a69e0b          	th.mveqz	t3,a3,a0
    4438:	00685393          	srli	t2,a6,0x6
    443c:	001e5f13          	srli	t5,t3,0x1
    4440:	01c3c7b3          	xor	a5,t2,t3
    4444:	0017fe93          	andi	t4,a5,1
    4448:	006f4fb3          	xor	t6,t5,t1
    444c:	41df1f8b          	th.mveqz	t6,t5,t4
    4450:	00785813          	srli	a6,a6,0x7
    4454:	001fd513          	srli	a0,t6,0x1
    4458:	01f842b3          	xor	t0,a6,t6
    445c:	0012f613          	andi	a2,t0,1
    4460:	006545b3          	xor	a1,a0,t1
    4464:	42c5950b          	th.mvnez	a0,a1,a2
    4468:	8082                	ret
    446a:	00000013          	nop
    446e:	0001                	nop

0000000000004470 <crcu32>:
    4470:	0ff57793          	zext.b	a5,a0
    4474:	6829                	lui	a6,0xa
    4476:	00180313          	addi	t1,a6,1 # a001 <_vsnprintf+0x1431>
    447a:	00b7c633          	xor	a2,a5,a1
    447e:	0015d71b          	srliw	a4,a1,0x1
    4482:	00167293          	andi	t0,a2,1
    4486:	006743b3          	xor	t2,a4,t1
    448a:	8185                	srli	a1,a1,0x1
    448c:	4055938b          	th.mveqz	t2,a1,t0
    4490:	1c15368b          	th.extu	a3,a0,7,1
    4494:	0076ce33          	xor	t3,a3,t2
    4498:	0013df13          	srli	t5,t2,0x1
    449c:	001e7e93          	andi	t4,t3,1
    44a0:	006f4fb3          	xor	t6,t5,t1
    44a4:	41df1f8b          	th.mveqz	t6,t5,t4
    44a8:	0027d893          	srli	a7,a5,0x2
    44ac:	01f8c6b3          	xor	a3,a7,t6
    44b0:	001fd593          	srli	a1,t6,0x1
    44b4:	0016f613          	andi	a2,a3,1
    44b8:	0065c733          	xor	a4,a1,t1
    44bc:	40c5970b          	th.mveqz	a4,a1,a2
    44c0:	0037d293          	srli	t0,a5,0x3
    44c4:	00e2c3b3          	xor	t2,t0,a4
    44c8:	00175e13          	srli	t3,a4,0x1
    44cc:	0013f893          	andi	a7,t2,1
    44d0:	006e4eb3          	xor	t4,t3,t1
    44d4:	411e1e8b          	th.mveqz	t4,t3,a7
    44d8:	0047d813          	srli	a6,a5,0x4
    44dc:	01d84fb3          	xor	t6,a6,t4
    44e0:	001ed693          	srli	a3,t4,0x1
    44e4:	001ff293          	andi	t0,t6,1
    44e8:	0066c733          	xor	a4,a3,t1
    44ec:	4056970b          	th.mveqz	a4,a3,t0
    44f0:	0057df13          	srli	t5,a5,0x5
    44f4:	00ef45b3          	xor	a1,t5,a4
    44f8:	00175393          	srli	t2,a4,0x1
    44fc:	0015f813          	andi	a6,a1,1
    4500:	0063c8b3          	xor	a7,t2,t1
    4504:	4103988b          	th.mveqz	a7,t2,a6
    4508:	0067d613          	srli	a2,a5,0x6
    450c:	0018df13          	srli	t5,a7,0x1
    4510:	0077de13          	srli	t3,a5,0x7
    4514:	011647b3          	xor	a5,a2,a7
    4518:	0017fe93          	andi	t4,a5,1
    451c:	006f4fb3          	xor	t6,t5,t1
    4520:	41df1f8b          	th.mveqz	t6,t5,t4
    4524:	01fe42b3          	xor	t0,t3,t6
    4528:	001fd693          	srli	a3,t6,0x1
    452c:	0012f713          	andi	a4,t0,1
    4530:	0066c333          	xor	t1,a3,t1
    4534:	42e3168b          	th.mvnez	a3,t1,a4
    4538:	7669                	lui	a2,0xffffa
    453a:	00160393          	addi	t2,a2,1 # ffffffffffffa001 <__kernel_stack+0xfffffffffff0c001>
    453e:	3c85388b          	th.extu	a7,a0,15,8
    4542:	0016d79b          	srliw	a5,a3,0x1
    4546:	00d8c5b3          	xor	a1,a7,a3
    454a:	0077cf33          	xor	t5,a5,t2
    454e:	0015fe13          	andi	t3,a1,1
    4552:	3c0f3f8b          	th.extu	t6,t5,15,0
    4556:	4016be8b          	th.extu	t4,a3,16,1
    455a:	43cf9e8b          	th.mvnez	t4,t6,t3
    455e:	001ed693          	srli	a3,t4,0x1
    4562:	3c95380b          	th.extu	a6,a0,15,9
    4566:	01d84733          	xor	a4,a6,t4
    456a:	0076c633          	xor	a2,a3,t2
    456e:	00177313          	andi	t1,a4,1
    4572:	3c063e0b          	th.extu	t3,a2,15,0
    4576:	40669e0b          	th.mveqz	t3,a3,t1
    457a:	001e5e93          	srli	t4,t3,0x1
    457e:	0028d293          	srli	t0,a7,0x2
    4582:	01c2c5b3          	xor	a1,t0,t3
    4586:	007ecf33          	xor	t5,t4,t2
    458a:	0015f793          	andi	a5,a1,1
    458e:	3c0f3f8b          	th.extu	t6,t5,15,0
    4592:	40fe9f8b          	th.mveqz	t6,t4,a5
    4596:	001fd693          	srli	a3,t6,0x1
    459a:	0038d813          	srli	a6,a7,0x3
    459e:	01f84733          	xor	a4,a6,t6
    45a2:	0076c633          	xor	a2,a3,t2
    45a6:	00177313          	andi	t1,a4,1
    45aa:	3c063e0b          	th.extu	t3,a2,15,0
    45ae:	40669e0b          	th.mveqz	t3,a3,t1
    45b2:	001e5e93          	srli	t4,t3,0x1
    45b6:	0048d293          	srli	t0,a7,0x4
    45ba:	01c2c5b3          	xor	a1,t0,t3
    45be:	007ecf33          	xor	t5,t4,t2
    45c2:	0015f793          	andi	a5,a1,1
    45c6:	3c0f3f8b          	th.extu	t6,t5,15,0
    45ca:	40fe9f8b          	th.mveqz	t6,t4,a5
    45ce:	001fd693          	srli	a3,t6,0x1
    45d2:	0058d813          	srli	a6,a7,0x5
    45d6:	01f84733          	xor	a4,a6,t6
    45da:	0076c633          	xor	a2,a3,t2
    45de:	00177313          	andi	t1,a4,1
    45e2:	3c063e0b          	th.extu	t3,a2,15,0
    45e6:	40669e0b          	th.mveqz	t3,a3,t1
    45ea:	001e5793          	srli	a5,t3,0x1
    45ee:	0068d293          	srli	t0,a7,0x6
    45f2:	01c2c833          	xor	a6,t0,t3
    45f6:	0077ceb3          	xor	t4,a5,t2
    45fa:	00187593          	andi	a1,a6,1
    45fe:	3c0ebf0b          	th.extu	t5,t4,15,0
    4602:	40b79f0b          	th.mveqz	t5,a5,a1
    4606:	001f5713          	srli	a4,t5,0x1
    460a:	0078d893          	srli	a7,a7,0x7
    460e:	01e8cfb3          	xor	t6,a7,t5
    4612:	00774333          	xor	t1,a4,t2
    4616:	001ff293          	andi	t0,t6,1
    461a:	3c03368b          	th.extu	a3,t1,15,0
    461e:	4256970b          	th.mvnez	a4,a3,t0
    4622:	5d053e0b          	th.extu	t3,a0,23,16
    4626:	0017559b          	srliw	a1,a4,0x1
    462a:	00ee4633          	xor	a2,t3,a4
    462e:	0075ceb3          	xor	t4,a1,t2
    4632:	00167813          	andi	a6,a2,1
    4636:	3c0ebf0b          	th.extu	t5,t4,15,0
    463a:	00175793          	srli	a5,a4,0x1
    463e:	430f178b          	th.mvnez	a5,t5,a6
    4642:	0017d713          	srli	a4,a5,0x1
    4646:	5d15388b          	th.extu	a7,a0,23,17
    464a:	00f8c2b3          	xor	t0,a7,a5
    464e:	007746b3          	xor	a3,a4,t2
    4652:	0012f313          	andi	t1,t0,1
    4656:	3c06b88b          	th.extu	a7,a3,15,0
    465a:	4067188b          	th.mveqz	a7,a4,t1
    465e:	0018d793          	srli	a5,a7,0x1
    4662:	002e5f93          	srli	t6,t3,0x2
    4666:	011fc633          	xor	a2,t6,a7
    466a:	0077ceb3          	xor	t4,a5,t2
    466e:	00167593          	andi	a1,a2,1
    4672:	3c0ebf0b          	th.extu	t5,t4,15,0
    4676:	40b79f0b          	th.mveqz	t5,a5,a1
    467a:	001f5713          	srli	a4,t5,0x1
    467e:	003e5813          	srli	a6,t3,0x3
    4682:	01e842b3          	xor	t0,a6,t5
    4686:	007746b3          	xor	a3,a4,t2
    468a:	0012f313          	andi	t1,t0,1
    468e:	3c06b88b          	th.extu	a7,a3,15,0
    4692:	4067188b          	th.mveqz	a7,a4,t1
    4696:	0018d793          	srli	a5,a7,0x1
    469a:	004e5f93          	srli	t6,t3,0x4
    469e:	011fc633          	xor	a2,t6,a7
    46a2:	0077ceb3          	xor	t4,a5,t2
    46a6:	00167593          	andi	a1,a2,1
    46aa:	3c0ebf0b          	th.extu	t5,t4,15,0
    46ae:	40b79f0b          	th.mveqz	t5,a5,a1
    46b2:	001f5713          	srli	a4,t5,0x1
    46b6:	005e5813          	srli	a6,t3,0x5
    46ba:	01e842b3          	xor	t0,a6,t5
    46be:	007746b3          	xor	a3,a4,t2
    46c2:	0012f313          	andi	t1,t0,1
    46c6:	3c06b88b          	th.extu	a7,a3,15,0
    46ca:	4067188b          	th.mveqz	a7,a4,t1
    46ce:	0018d613          	srli	a2,a7,0x1
    46d2:	006e5f93          	srli	t6,t3,0x6
    46d6:	011fc833          	xor	a6,t6,a7
    46da:	007647b3          	xor	a5,a2,t2
    46de:	00187593          	andi	a1,a6,1
    46e2:	3c07be8b          	th.extu	t4,a5,15,0
    46e6:	40b61e8b          	th.mveqz	t4,a2,a1
    46ea:	001ed293          	srli	t0,t4,0x1
    46ee:	007e5e13          	srli	t3,t3,0x7
    46f2:	01de4f33          	xor	t5,t3,t4
    46f6:	0072c333          	xor	t1,t0,t2
    46fa:	001f7f93          	andi	t6,t5,1
    46fe:	3c03370b          	th.extu	a4,t1,15,0
    4702:	43f7128b          	th.mvnez	t0,a4,t6
    4706:	0185569b          	srliw	a3,a0,0x18
    470a:	0012d81b          	srliw	a6,t0,0x1
    470e:	0056c8b3          	xor	a7,a3,t0
    4712:	007845b3          	xor	a1,a6,t2
    4716:	0018fe13          	andi	t3,a7,1
    471a:	3c05b60b          	th.extu	a2,a1,15,0
    471e:	0012d793          	srli	a5,t0,0x1
    4722:	43c6178b          	th.mvnez	a5,a2,t3
    4726:	0017d293          	srli	t0,a5,0x1
    472a:	0195551b          	srliw	a0,a0,0x19
    472e:	00f54f33          	xor	t5,a0,a5
    4732:	0072c333          	xor	t1,t0,t2
    4736:	001f7f93          	andi	t6,t5,1
    473a:	3c03370b          	th.extu	a4,t1,15,0
    473e:	41f2970b          	th.mveqz	a4,t0,t6
    4742:	00175813          	srli	a6,a4,0x1
    4746:	0026de93          	srli	t4,a3,0x2
    474a:	00eec8b3          	xor	a7,t4,a4
    474e:	007847b3          	xor	a5,a6,t2
    4752:	0018fe13          	andi	t3,a7,1
    4756:	3c07b60b          	th.extu	a2,a5,15,0
    475a:	41c8160b          	th.mveqz	a2,a6,t3
    475e:	00165f93          	srli	t6,a2,0x1
    4762:	0036d513          	srli	a0,a3,0x3
    4766:	00c54eb3          	xor	t4,a0,a2
    476a:	007fc2b3          	xor	t0,t6,t2
    476e:	001eff13          	andi	t5,t4,1
    4772:	3c02b30b          	th.extu	t1,t0,15,0
    4776:	41ef930b          	th.mveqz	t1,t6,t5
    477a:	00135e13          	srli	t3,t1,0x1
    477e:	0046d593          	srli	a1,a3,0x4
    4782:	0065c733          	xor	a4,a1,t1
    4786:	007e4833          	xor	a6,t3,t2
    478a:	00177893          	andi	a7,a4,1
    478e:	3c08378b          	th.extu	a5,a6,15,0
    4792:	411e178b          	th.mveqz	a5,t3,a7
    4796:	0056d513          	srli	a0,a3,0x5
    479a:	0017df13          	srli	t5,a5,0x1
    479e:	00f54633          	xor	a2,a0,a5
    47a2:	007f4fb3          	xor	t6,t5,t2
    47a6:	00167e93          	andi	t4,a2,1
    47aa:	3c0fb28b          	th.extu	t0,t6,15,0
    47ae:	41df128b          	th.mveqz	t0,t5,t4
    47b2:	0066d593          	srli	a1,a3,0x6
    47b6:	0012d893          	srli	a7,t0,0x1
    47ba:	0055c333          	xor	t1,a1,t0
    47be:	0078c733          	xor	a4,a7,t2
    47c2:	00137513          	andi	a0,t1,1
    47c6:	3c073e0b          	th.extu	t3,a4,15,0
    47ca:	40a89e0b          	th.mveqz	t3,a7,a0
    47ce:	001e5613          	srli	a2,t3,0x1
    47d2:	829d                	srli	a3,a3,0x7
    47d4:	01c6c833          	xor	a6,a3,t3
    47d8:	007643b3          	xor	t2,a2,t2
    47dc:	00187593          	andi	a1,a6,1
    47e0:	3c03b50b          	th.extu	a0,t2,15,0
    47e4:	40b6150b          	th.mveqz	a0,a2,a1
    47e8:	8082                	ret
    47ea:	00000013          	nop
    47ee:	0001                	nop

00000000000047f0 <crc16>:
    47f0:	0ff57793          	zext.b	a5,a0
    47f4:	6829                	lui	a6,0xa
    47f6:	00180313          	addi	t1,a6,1 # a001 <_vsnprintf+0x1431>
    47fa:	00b7c633          	xor	a2,a5,a1
    47fe:	0015d71b          	srliw	a4,a1,0x1
    4802:	00167293          	andi	t0,a2,1
    4806:	006743b3          	xor	t2,a4,t1
    480a:	8185                	srli	a1,a1,0x1
    480c:	4055938b          	th.mveqz	t2,a1,t0
    4810:	1c15368b          	th.extu	a3,a0,7,1
    4814:	0076ce33          	xor	t3,a3,t2
    4818:	0013df13          	srli	t5,t2,0x1
    481c:	001e7e93          	andi	t4,t3,1
    4820:	006f4fb3          	xor	t6,t5,t1
    4824:	41df1f8b          	th.mveqz	t6,t5,t4
    4828:	0027d893          	srli	a7,a5,0x2
    482c:	01f8c6b3          	xor	a3,a7,t6
    4830:	001fd593          	srli	a1,t6,0x1
    4834:	0016f613          	andi	a2,a3,1
    4838:	0065c733          	xor	a4,a1,t1
    483c:	40c5970b          	th.mveqz	a4,a1,a2
    4840:	0037d293          	srli	t0,a5,0x3
    4844:	00e2c3b3          	xor	t2,t0,a4
    4848:	00175e13          	srli	t3,a4,0x1
    484c:	0013f893          	andi	a7,t2,1
    4850:	006e4eb3          	xor	t4,t3,t1
    4854:	411e1e8b          	th.mveqz	t4,t3,a7
    4858:	0047d813          	srli	a6,a5,0x4
    485c:	01d84fb3          	xor	t6,a6,t4
    4860:	001ed693          	srli	a3,t4,0x1
    4864:	001ff293          	andi	t0,t6,1
    4868:	0066c733          	xor	a4,a3,t1
    486c:	4056970b          	th.mveqz	a4,a3,t0
    4870:	0057df13          	srli	t5,a5,0x5
    4874:	00ef45b3          	xor	a1,t5,a4
    4878:	00175393          	srli	t2,a4,0x1
    487c:	0015f813          	andi	a6,a1,1
    4880:	0063c8b3          	xor	a7,t2,t1
    4884:	4103988b          	th.mveqz	a7,t2,a6
    4888:	0067d613          	srli	a2,a5,0x6
    488c:	01164e33          	xor	t3,a2,a7
    4890:	0018df13          	srli	t5,a7,0x1
    4894:	001e7e93          	andi	t4,t3,1
    4898:	006f4fb3          	xor	t6,t5,t1
    489c:	41df1f8b          	th.mveqz	t6,t5,t4
    48a0:	839d                	srli	a5,a5,0x7
    48a2:	01f7c2b3          	xor	t0,a5,t6
    48a6:	001fd713          	srli	a4,t6,0x1
    48aa:	0012f593          	andi	a1,t0,1
    48ae:	00674333          	xor	t1,a4,t1
    48b2:	42b3170b          	th.mvnez	a4,t1,a1
    48b6:	76e9                	lui	a3,0xffffa
    48b8:	00168813          	addi	a6,a3,1 # ffffffffffffa001 <__kernel_stack+0xfffffffffff0c001>
    48bc:	3c85338b          	th.extu	t2,a0,15,8
    48c0:	0017579b          	srliw	a5,a4,0x1
    48c4:	00e3c633          	xor	a2,t2,a4
    48c8:	0107ceb3          	xor	t4,a5,a6
    48cc:	00167893          	andi	a7,a2,1
    48d0:	3c0ebf0b          	th.extu	t5,t4,15,0
    48d4:	40173e0b          	th.extu	t3,a4,16,1
    48d8:	431f1e0b          	th.mvnez	t3,t5,a7
    48dc:	001e5713          	srli	a4,t3,0x1
    48e0:	3c95350b          	th.extu	a0,a0,15,9
    48e4:	01c542b3          	xor	t0,a0,t3
    48e8:	010746b3          	xor	a3,a4,a6
    48ec:	0012f593          	andi	a1,t0,1
    48f0:	3c06b30b          	th.extu	t1,a3,15,0
    48f4:	40b7130b          	th.mveqz	t1,a4,a1
    48f8:	00135793          	srli	a5,t1,0x1
    48fc:	0023df93          	srli	t6,t2,0x2
    4900:	006fc633          	xor	a2,t6,t1
    4904:	0107ce33          	xor	t3,a5,a6
    4908:	00167893          	andi	a7,a2,1
    490c:	3c0e3e8b          	th.extu	t4,t3,15,0
    4910:	41179e8b          	th.mveqz	t4,a5,a7
    4914:	001ed593          	srli	a1,t4,0x1
    4918:	0033d513          	srli	a0,t2,0x3
    491c:	01d54fb3          	xor	t6,a0,t4
    4920:	0105c733          	xor	a4,a1,a6
    4924:	001ff293          	andi	t0,t6,1
    4928:	3c07368b          	th.extu	a3,a4,15,0
    492c:	4055968b          	th.mveqz	a3,a1,t0
    4930:	0016d613          	srli	a2,a3,0x1
    4934:	0043df13          	srli	t5,t2,0x4
    4938:	00df4533          	xor	a0,t5,a3
    493c:	010647b3          	xor	a5,a2,a6
    4940:	00157893          	andi	a7,a0,1
    4944:	3c07be0b          	th.extu	t3,a5,15,0
    4948:	41161e0b          	th.mveqz	t3,a2,a7
    494c:	001e5293          	srli	t0,t3,0x1
    4950:	0053d313          	srli	t1,t2,0x5
    4954:	01c34f33          	xor	t5,t1,t3
    4958:	0102c5b3          	xor	a1,t0,a6
    495c:	001f7f93          	andi	t6,t5,1
    4960:	3c05b70b          	th.extu	a4,a1,15,0
    4964:	41f2970b          	th.mveqz	a4,t0,t6
    4968:	00175513          	srli	a0,a4,0x1
    496c:	0063de93          	srli	t4,t2,0x6
    4970:	010548b3          	xor	a7,a0,a6
    4974:	00eec6b3          	xor	a3,t4,a4
    4978:	0016f313          	andi	t1,a3,1
    497c:	3c08b60b          	th.extu	a2,a7,15,0
    4980:	4065160b          	th.mveqz	a2,a0,t1
    4984:	00165e93          	srli	t4,a2,0x1
    4988:	0073d393          	srli	t2,t2,0x7
    498c:	00c3c7b3          	xor	a5,t2,a2
    4990:	010ec833          	xor	a6,t4,a6
    4994:	0017fe13          	andi	t3,a5,1
    4998:	3c08350b          	th.extu	a0,a6,15,0
    499c:	41ce950b          	th.mveqz	a0,t4,t3
    49a0:	8082                	ret
    49a2:	0001                	nop
    49a4:	00000013          	nop
    49a8:	00000013          	nop
    49ac:	00000013          	nop

00000000000049b0 <check_data_types>:
    49b0:	4501                	li	a0,0
    49b2:	8082                	ret
	...

00000000000049c0 <ecvt>:
    49c0:	7159                	addi	sp,sp,-112
    49c2:	f20007d3          	fmv.d.x	fa5,zero
    49c6:	eca6                	sd	s1,88(sp)
    49c8:	f0a2                	sd	s0,96(sp)
    49ca:	0005041b          	sext.w	s0,a0
    49ce:	04e00793          	li	a5,78
    49d2:	00042693          	slti	a3,s0,0
    49d6:	a2f512d3          	flt.d	t0,fa0,fa5
    49da:	fc56                	sd	s5,56(sp)
    49dc:	e0d2                	sd	s4,64(sp)
    49de:	e4ce                	sd	s3,72(sp)
    49e0:	e8ca                	sd	s2,80(sp)
    49e2:	42d0140b          	th.mvnez	s0,zero,a3
    49e6:	00a7a533          	slt	a0,a5,a0
    49ea:	b422                	fsd	fs0,40(sp)
    49ec:	b026                	fsd	fs1,32(sp)
    49ee:	ac4a                	fsd	fs2,24(sp)
    49f0:	f486                	sd	ra,104(sp)
    49f2:	892e                	mv	s2,a1
    49f4:	42a7940b          	th.mvnez	s0,a5,a0
    49f8:	6c029063          	bnez	t0,50b8 <ecvt+0x6f8>
    49fc:	00062023          	sw	zero,0(a2)
    4a00:	850a                	mv	a0,sp
    4a02:	5550a0ef          	jal	f756 <modf>
    4a06:	2e02                	fld	ft8,0(sp)
    4a08:	f2000953          	fmv.d.x	fs2,zero
    4a0c:	22a50453          	fmv.d	fs0,fa0
    4a10:	a32e23d3          	feq.d	t2,ft8,fs2
    4a14:	5c039663          	bnez	t2,4fe0 <ecvt+0x620>
    4a18:	00041537          	lui	a0,0x41
    4a1c:	62c5                	lui	t0,0x11
    4a1e:	6345                	lui	t1,0x11
    4a20:	a84e                	fsd	fs3,16(sp)
    4a22:	fd050493          	addi	s1,a0,-48 # 40fd0 <CVTBUF>
    4a26:	b802b487          	fld	fs1,-1152(t0) # 10b80 <errpat+0x38>
    4a2a:	b8833987          	fld	fs3,-1144(t1) # 10b88 <errpat+0x40>
    4a2e:	05048993          	addi	s3,s1,80
    4a32:	f85a                	sd	s6,48(sp)
    4a34:	4a81                	li	s5,0
    4a36:	8b4e                	mv	s6,s3
    4a38:	1a9e7553          	fdiv.d	fa0,ft8,fs1
    4a3c:	850a                	mv	a0,sp
    4a3e:	1b7d                	addi	s6,s6,-1
    4a40:	2a85                	addiw	s5,s5,1
    4a42:	8a5a                	mv	s4,s6
    4a44:	5130a0ef          	jal	f756 <modf>
    4a48:	a42a                	fsd	fa0,8(sp)
    4a4a:	03357553          	fadd.d	fa0,fa0,fs3
    4a4e:	2102                	fld	ft2,0(sp)
    4a50:	8356                	mv	t1,s5
    4a52:	129570d3          	fmul.d	ft1,fa0,fs1
    4a56:	a3212753          	feq.d	a4,ft2,fs2
    4a5a:	c20093d3          	fcvt.w.d	t2,ft1,rtz
    4a5e:	0303859b          	addiw	a1,t2,48
    4a62:	0ff5f293          	zext.b	t0,a1
    4a66:	005b0023          	sb	t0,0(s6)
    4a6a:	ef59                	bnez	a4,4b08 <ecvt+0x148>
    4a6c:	1a917553          	fdiv.d	fa0,ft2,fs1
    4a70:	850a                	mv	a0,sp
    4a72:	2a85                	addiw	s5,s5,1
    4a74:	4e30a0ef          	jal	f756 <modf>
    4a78:	033571d3          	fadd.d	ft3,fa0,fs3
    4a7c:	2282                	fld	ft5,0(sp)
    4a7e:	a42a                	fsd	fa0,8(sp)
    4a80:	1291f253          	fmul.d	ft4,ft3,fs1
    4a84:	a322a8d3          	feq.d	a7,ft5,fs2
    4a88:	8356                	mv	t1,s5
    4a8a:	c2021653          	fcvt.w.d	a2,ft4,rtz
    4a8e:	0306081b          	addiw	a6,a2,48
    4a92:	0ff87293          	zext.b	t0,a6
    4a96:	09fb528b          	th.sbib	t0,(s6),-1,0
    4a9a:	06089763          	bnez	a7,4b08 <ecvt+0x148>
    4a9e:	1a92f553          	fdiv.d	fa0,ft5,fs1
    4aa2:	850a                	mv	a0,sp
    4aa4:	2a85                	addiw	s5,s5,1
    4aa6:	ffea0b13          	addi	s6,s4,-2 # ffffffffffffeffe <__kernel_stack+0xfffffffffff10ffe>
    4aaa:	4ad0a0ef          	jal	f756 <modf>
    4aae:	03357353          	fadd.d	ft6,fa0,fs3
    4ab2:	2582                	fld	fa1,0(sp)
    4ab4:	a42a                	fsd	fa0,8(sp)
    4ab6:	129373d3          	fmul.d	ft7,ft6,fs1
    4aba:	a325af53          	feq.d	t5,fa1,fs2
    4abe:	8356                	mv	t1,s5
    4ac0:	c2039e53          	fcvt.w.d	t3,ft7,rtz
    4ac4:	030e0e9b          	addiw	t4,t3,48
    4ac8:	0ffef293          	zext.b	t0,t4
    4acc:	fe5a0f23          	sb	t0,-2(s4)
    4ad0:	020f1c63          	bnez	t5,4b08 <ecvt+0x148>
    4ad4:	1a95f553          	fdiv.d	fa0,fa1,fs1
    4ad8:	850a                	mv	a0,sp
    4ada:	2a85                	addiw	s5,s5,1
    4adc:	ffda0b13          	addi	s6,s4,-3
    4ae0:	4770a0ef          	jal	f756 <modf>
    4ae4:	03357853          	fadd.d	fa6,fa0,fs3
    4ae8:	2e02                	fld	ft8,0(sp)
    4aea:	a42a                	fsd	fa0,8(sp)
    4aec:	129878d3          	fmul.d	fa7,fa6,fs1
    4af0:	a32e26d3          	feq.d	a3,ft8,fs2
    4af4:	8356                	mv	t1,s5
    4af6:	c2089fd3          	fcvt.w.d	t6,fa7,rtz
    4afa:	030f879b          	addiw	a5,t6,48
    4afe:	0ff7f293          	zext.b	t0,a5
    4b02:	fe5a0ea3          	sb	t0,-3(s4)
    4b06:	da8d                	beqz	a3,4a38 <ecvt+0x78>
    4b08:	5d3b7e63          	bgeu	s6,s3,50e4 <ecvt+0x724>
    4b0c:	fffb4a93          	not	s5,s6
    4b10:	01598533          	add	a0,s3,s5
    4b14:	00757a13          	andi	s4,a0,7
    4b18:	875a                	mv	a4,s6
    4b1a:	8ea6                	mv	t4,s1
    4b1c:	0a0a0863          	beqz	s4,4bcc <ecvt+0x20c>
    4b20:	181ed28b          	th.sbia	t0,(t4),1,0
    4b24:	4385                	li	t2,1
    4b26:	8817428b          	th.lbuib	t0,(a4),1,0
    4b2a:	0a7a0163          	beq	s4,t2,4bcc <ecvt+0x20c>
    4b2e:	4589                	li	a1,2
    4b30:	04ba0563          	beq	s4,a1,4b7a <ecvt+0x1ba>
    4b34:	460d                	li	a2,3
    4b36:	02ca0e63          	beq	s4,a2,4b72 <ecvt+0x1b2>
    4b3a:	4811                	li	a6,4
    4b3c:	030a0763          	beq	s4,a6,4b6a <ecvt+0x1aa>
    4b40:	4895                	li	a7,5
    4b42:	031a0063          	beq	s4,a7,4b62 <ecvt+0x1a2>
    4b46:	4e19                	li	t3,6
    4b48:	01ca0963          	beq	s4,t3,4b5a <ecvt+0x19a>
    4b4c:	875a                	mv	a4,s6
    4b4e:	005480a3          	sb	t0,1(s1)
    4b52:	8827428b          	th.lbuib	t0,(a4),2,0
    4b56:	00248e93          	addi	t4,s1,2
    4b5a:	181ed28b          	th.sbia	t0,(t4),1,0
    4b5e:	8817428b          	th.lbuib	t0,(a4),1,0
    4b62:	181ed28b          	th.sbia	t0,(t4),1,0
    4b66:	8817428b          	th.lbuib	t0,(a4),1,0
    4b6a:	181ed28b          	th.sbia	t0,(t4),1,0
    4b6e:	8817428b          	th.lbuib	t0,(a4),1,0
    4b72:	181ed28b          	th.sbia	t0,(t4),1,0
    4b76:	8817428b          	th.lbuib	t0,(a4),1,0
    4b7a:	181ed28b          	th.sbia	t0,(t4),1,0
    4b7e:	8817428b          	th.lbuib	t0,(a4),1,0
    4b82:	00170793          	addi	a5,a4,1
    4b86:	005e8023          	sb	t0,0(t4)
    4b8a:	04f98763          	beq	s3,a5,4bd8 <ecvt+0x218>
    4b8e:	00174883          	lbu	a7,1(a4)
    4b92:	0ea1                	addi	t4,t4,8
    4b94:	ff1e8ca3          	sb	a7,-7(t4)
    4b98:	00274603          	lbu	a2,2(a4)
    4b9c:	fece8d23          	sb	a2,-6(t4)
    4ba0:	00374f83          	lbu	t6,3(a4)
    4ba4:	fffe8da3          	sb	t6,-5(t4)
    4ba8:	00474283          	lbu	t0,4(a4)
    4bac:	fe5e8e23          	sb	t0,-4(t4)
    4bb0:	00574a83          	lbu	s5,5(a4)
    4bb4:	ff5e8ea3          	sb	s5,-3(t4)
    4bb8:	00674a03          	lbu	s4,6(a4)
    4bbc:	ff4e8f23          	sb	s4,-2(t4)
    4bc0:	00774683          	lbu	a3,7(a4)
    4bc4:	fede8fa3          	sb	a3,-1(t4)
    4bc8:	8887428b          	th.lbuib	t0,(a4),8,0
    4bcc:	00170793          	addi	a5,a4,1
    4bd0:	005e8023          	sb	t0,0(t4)
    4bd4:	faf99de3          	bne	s3,a5,4b8e <ecvt+0x1ce>
    4bd8:	9426                	add	s0,s0,s1
    4bda:	00692023          	sw	t1,0(s2)
    4bde:	4e946363          	bltu	s0,s1,50c4 <ecvt+0x704>
    4be2:	01348f33          	add	t5,s1,s3
    4be6:	416f0a33          	sub	s4,t5,s6
    4bea:	29c2                	fld	fs3,16(sp)
    4bec:	7b42                	ld	s6,48(sp)
    4bee:	11446963          	bltu	s0,s4,4d00 <ecvt+0x340>
    4bf2:	414982b3          	sub	t0,s3,s4
    4bf6:	6fc5                	lui	t6,0x11
    4bf8:	0032fa93          	andi	s5,t0,3
    4bfc:	b80fb907          	fld	fs2,-1152(t6) # 10b80 <errpat+0x38>
    4c00:	060a8c63          	beqz	s5,4c78 <ecvt+0x2b8>
    4c04:	0f3a7e63          	bgeu	s4,s3,4d00 <ecvt+0x340>
    4c08:	13247553          	fmul.d	fa0,fs0,fs2
    4c0c:	0028                	addi	a0,sp,8
    4c0e:	3490a0ef          	jal	f756 <modf>
    4c12:	2ea2                	fld	ft9,8(sp)
    4c14:	22a50453          	fmv.d	fs0,fa0
    4c18:	c20e9353          	fcvt.w.d	t1,ft9,rtz
    4c1c:	0303069b          	addiw	a3,t1,48
    4c20:	181a568b          	th.sbia	a3,(s4),1,0
    4c24:	0d446e63          	bltu	s0,s4,4d00 <ecvt+0x340>
    4c28:	4505                	li	a0,1
    4c2a:	04aa8763          	beq	s5,a0,4c78 <ecvt+0x2b8>
    4c2e:	4389                	li	t2,2
    4c30:	027a8263          	beq	s5,t2,4c54 <ecvt+0x294>
    4c34:	13257553          	fmul.d	fa0,fa0,fs2
    4c38:	0028                	addi	a0,sp,8
    4c3a:	31d0a0ef          	jal	f756 <modf>
    4c3e:	2f22                	fld	ft10,8(sp)
    4c40:	22a50453          	fmv.d	fs0,fa0
    4c44:	c20f15d3          	fcvt.w.d	a1,ft10,rtz
    4c48:	0305861b          	addiw	a2,a1,48
    4c4c:	181a560b          	th.sbia	a2,(s4),1,0
    4c50:	0b446863          	bltu	s0,s4,4d00 <ecvt+0x340>
    4c54:	13247553          	fmul.d	fa0,fs0,fs2
    4c58:	0028                	addi	a0,sp,8
    4c5a:	2fd0a0ef          	jal	f756 <modf>
    4c5e:	2fa2                	fld	ft11,8(sp)
    4c60:	22a50453          	fmv.d	fs0,fa0
    4c64:	c20f9853          	fcvt.w.d	a6,ft11,rtz
    4c68:	0308089b          	addiw	a7,a6,48
    4c6c:	181a588b          	th.sbia	a7,(s4),1,0
    4c70:	09446863          	bltu	s0,s4,4d00 <ecvt+0x340>
    4c74:	00000013          	nop
    4c78:	093a7463          	bgeu	s4,s3,4d00 <ecvt+0x340>
    4c7c:	13247553          	fmul.d	fa0,fs0,fs2
    4c80:	0028                	addi	a0,sp,8
    4c82:	2d50a0ef          	jal	f756 <modf>
    4c86:	27a2                	fld	fa5,8(sp)
    4c88:	8e52                	mv	t3,s4
    4c8a:	c2079753          	fcvt.w.d	a4,fa5,rtz
    4c8e:	03070e9b          	addiw	t4,a4,48
    4c92:	181e5e8b          	th.sbia	t4,(t3),1,0
    4c96:	07c46563          	bltu	s0,t3,4d00 <ecvt+0x340>
    4c9a:	13257553          	fmul.d	fa0,fa0,fs2
    4c9e:	0028                	addi	a0,sp,8
    4ca0:	2b70a0ef          	jal	f756 <modf>
    4ca4:	2722                	fld	fa4,8(sp)
    4ca6:	002a0793          	addi	a5,s4,2
    4caa:	c2071f53          	fcvt.w.d	t5,fa4,rtz
    4cae:	030f0f9b          	addiw	t6,t5,48
    4cb2:	01fa00a3          	sb	t6,1(s4)
    4cb6:	04f46563          	bltu	s0,a5,4d00 <ecvt+0x340>
    4cba:	13257553          	fmul.d	fa0,fa0,fs2
    4cbe:	0028                	addi	a0,sp,8
    4cc0:	2970a0ef          	jal	f756 <modf>
    4cc4:	2622                	fld	fa2,8(sp)
    4cc6:	003a0293          	addi	t0,s4,3
    4cca:	c2061ad3          	fcvt.w.d	s5,fa2,rtz
    4cce:	030a831b          	addiw	t1,s5,48
    4cd2:	006a0123          	sb	t1,2(s4)
    4cd6:	02546563          	bltu	s0,t0,4d00 <ecvt+0x340>
    4cda:	13257553          	fmul.d	fa0,fa0,fs2
    4cde:	0028                	addi	a0,sp,8
    4ce0:	0a11                	addi	s4,s4,4
    4ce2:	2750a0ef          	jal	f756 <modf>
    4ce6:	26a2                	fld	fa3,8(sp)
    4ce8:	22a50453          	fmv.d	fs0,fa0
    4cec:	c20696d3          	fcvt.w.d	a3,fa3,rtz
    4cf0:	0306851b          	addiw	a0,a3,48
    4cf4:	feaa0fa3          	sb	a0,-1(s4)
    4cf8:	f94470e3          	bgeu	s0,s4,4c78 <ecvt+0x2b8>
    4cfc:	00000013          	nop
    4d00:	3d347863          	bgeu	s0,s3,50d0 <ecvt+0x710>
    4d04:	00044983          	lbu	s3,0(s0)
    4d08:	03900813          	li	a6,57
    4d0c:	0059839b          	addiw	t2,s3,5
    4d10:	0ff3f593          	zext.b	a1,t2
    4d14:	10b87263          	bgeu	a6,a1,4e18 <ecvt+0x458>
    4d18:	40940e33          	sub	t3,s0,s1
    4d1c:	00b40023          	sb	a1,0(s0)
    4d20:	007e7713          	andi	a4,t3,7
    4d24:	87a2                	mv	a5,s0
    4d26:	03000613          	li	a2,48
    4d2a:	88c2                	mv	a7,a6
    4d2c:	1e070663          	beqz	a4,4f18 <ecvt+0x558>
    4d30:	1084e463          	bltu	s1,s0,4e38 <ecvt+0x478>
    4d34:	03100893          	li	a7,49
    4d38:	01178023          	sb	a7,0(a5)
    4d3c:	00092603          	lw	a2,0(s2)
    4d40:	03900e13          	li	t3,57
    4d44:	0016059b          	addiw	a1,a2,1
    4d48:	00b92023          	sw	a1,0(s2)
    4d4c:	0007c803          	lbu	a6,0(a5)
    4d50:	0d0e7463          	bgeu	t3,a6,4e18 <ecvt+0x458>
    4d54:	01178023          	sb	a7,0(a5)
    4d58:	00092703          	lw	a4,0(s2)
    4d5c:	00170e9b          	addiw	t4,a4,1
    4d60:	01d92023          	sw	t4,0(s2)
    4d64:	0007cf03          	lbu	t5,0(a5)
    4d68:	0bee7863          	bgeu	t3,t5,4e18 <ecvt+0x458>
    4d6c:	01178023          	sb	a7,0(a5)
    4d70:	00092f83          	lw	t6,0(s2)
    4d74:	001f829b          	addiw	t0,t6,1
    4d78:	00592023          	sw	t0,0(s2)
    4d7c:	0007ca83          	lbu	s5,0(a5)
    4d80:	095e7c63          	bgeu	t3,s5,4e18 <ecvt+0x458>
    4d84:	01178023          	sb	a7,0(a5)
    4d88:	00092303          	lw	t1,0(s2)
    4d8c:	00130a1b          	addiw	s4,t1,1
    4d90:	01492023          	sw	s4,0(s2)
    4d94:	0007c683          	lbu	a3,0(a5)
    4d98:	08de7063          	bgeu	t3,a3,4e18 <ecvt+0x458>
    4d9c:	01178023          	sb	a7,0(a5)
    4da0:	00092503          	lw	a0,0(s2)
    4da4:	0015099b          	addiw	s3,a0,1
    4da8:	01392023          	sw	s3,0(s2)
    4dac:	0007c383          	lbu	t2,0(a5)
    4db0:	067e7463          	bgeu	t3,t2,4e18 <ecvt+0x458>
    4db4:	01178023          	sb	a7,0(a5)
    4db8:	00092603          	lw	a2,0(s2)
    4dbc:	0016059b          	addiw	a1,a2,1
    4dc0:	00b92023          	sw	a1,0(s2)
    4dc4:	0007c803          	lbu	a6,0(a5)
    4dc8:	050e7863          	bgeu	t3,a6,4e18 <ecvt+0x458>
    4dcc:	01178023          	sb	a7,0(a5)
    4dd0:	00092703          	lw	a4,0(s2)
    4dd4:	00170e9b          	addiw	t4,a4,1
    4dd8:	01d92023          	sw	t4,0(s2)
    4ddc:	0007cf03          	lbu	t5,0(a5)
    4de0:	03ee7c63          	bgeu	t3,t5,4e18 <ecvt+0x458>
    4de4:	01178023          	sb	a7,0(a5)
    4de8:	00092f83          	lw	t6,0(s2)
    4dec:	001f829b          	addiw	t0,t6,1
    4df0:	00592023          	sw	t0,0(s2)
    4df4:	0007ca83          	lbu	s5,0(a5)
    4df8:	035e7063          	bgeu	t3,s5,4e18 <ecvt+0x458>
    4dfc:	01178023          	sb	a7,0(a5)
    4e00:	00092303          	lw	t1,0(s2)
    4e04:	00130a1b          	addiw	s4,t1,1
    4e08:	01492023          	sw	s4,0(s2)
    4e0c:	0007c683          	lbu	a3,0(a5)
    4e10:	f4de62e3          	bltu	t3,a3,4d54 <ecvt+0x394>
    4e14:	00000013          	nop
    4e18:	00040023          	sb	zero,0(s0)
    4e1c:	70a6                	ld	ra,104(sp)
    4e1e:	8526                	mv	a0,s1
    4e20:	64e6                	ld	s1,88(sp)
    4e22:	7406                	ld	s0,96(sp)
    4e24:	7ae2                	ld	s5,56(sp)
    4e26:	6a06                	ld	s4,64(sp)
    4e28:	69a6                	ld	s3,72(sp)
    4e2a:	6946                	ld	s2,80(sp)
    4e2c:	3422                	fld	fs0,40(sp)
    4e2e:	3482                	fld	fs1,32(sp)
    4e30:	2962                	fld	fs2,24(sp)
    4e32:	6165                	addi	sp,sp,112
    4e34:	8082                	ret
    4e36:	0001                	nop
    4e38:	fff44e83          	lbu	t4,-1(s0)
    4e3c:	00c40023          	sb	a2,0(s0)
    4e40:	001e879b          	addiw	a5,t4,1
    4e44:	0ff7ff13          	zext.b	t5,a5
    4e48:	ffe40fa3          	sb	t5,-1(s0)
    4e4c:	fde876e3          	bgeu	a6,t5,4e18 <ecvt+0x458>
    4e50:	4f85                	li	t6,1
    4e52:	fff40793          	addi	a5,s0,-1
    4e56:	0df70163          	beq	a4,t6,4f18 <ecvt+0x558>
    4e5a:	4289                	li	t0,2
    4e5c:	08570f63          	beq	a4,t0,4efa <ecvt+0x53a>
    4e60:	4a8d                	li	s5,3
    4e62:	07570f63          	beq	a4,s5,4ee0 <ecvt+0x520>
    4e66:	4311                	li	t1,4
    4e68:	04670f63          	beq	a4,t1,4ec6 <ecvt+0x506>
    4e6c:	4a15                	li	s4,5
    4e6e:	03470f63          	beq	a4,s4,4eac <ecvt+0x4ec>
    4e72:	4699                	li	a3,6
    4e74:	00d70f63          	beq	a4,a3,4e92 <ecvt+0x4d2>
    4e78:	fff7c503          	lbu	a0,-1(a5)
    4e7c:	00c78023          	sb	a2,0(a5)
    4e80:	0015099b          	addiw	s3,a0,1
    4e84:	0ff9f393          	zext.b	t2,s3
    4e88:	fe778fa3          	sb	t2,-1(a5)
    4e8c:	f87876e3          	bgeu	a6,t2,4e18 <ecvt+0x458>
    4e90:	17fd                	addi	a5,a5,-1
    4e92:	fff7c583          	lbu	a1,-1(a5)
    4e96:	00c78023          	sb	a2,0(a5)
    4e9a:	0015881b          	addiw	a6,a1,1
    4e9e:	0ff87e13          	zext.b	t3,a6
    4ea2:	ffc78fa3          	sb	t3,-1(a5)
    4ea6:	f7c8f9e3          	bgeu	a7,t3,4e18 <ecvt+0x458>
    4eaa:	17fd                	addi	a5,a5,-1
    4eac:	fff7c703          	lbu	a4,-1(a5)
    4eb0:	00c78023          	sb	a2,0(a5)
    4eb4:	00170e9b          	addiw	t4,a4,1
    4eb8:	0ffeff13          	zext.b	t5,t4
    4ebc:	ffe78fa3          	sb	t5,-1(a5)
    4ec0:	f5e8fce3          	bgeu	a7,t5,4e18 <ecvt+0x458>
    4ec4:	17fd                	addi	a5,a5,-1
    4ec6:	fff7cf83          	lbu	t6,-1(a5)
    4eca:	00c78023          	sb	a2,0(a5)
    4ece:	001f829b          	addiw	t0,t6,1
    4ed2:	0ff2fa93          	zext.b	s5,t0
    4ed6:	ff578fa3          	sb	s5,-1(a5)
    4eda:	f358ffe3          	bgeu	a7,s5,4e18 <ecvt+0x458>
    4ede:	17fd                	addi	a5,a5,-1
    4ee0:	fff7c303          	lbu	t1,-1(a5)
    4ee4:	00c78023          	sb	a2,0(a5)
    4ee8:	00130a1b          	addiw	s4,t1,1
    4eec:	0ffa7693          	zext.b	a3,s4
    4ef0:	fed78fa3          	sb	a3,-1(a5)
    4ef4:	f2d8f2e3          	bgeu	a7,a3,4e18 <ecvt+0x458>
    4ef8:	17fd                	addi	a5,a5,-1
    4efa:	fff7c503          	lbu	a0,-1(a5)
    4efe:	00c78023          	sb	a2,0(a5)
    4f02:	17fd                	addi	a5,a5,-1
    4f04:	0015099b          	addiw	s3,a0,1
    4f08:	0ff9f393          	zext.b	t2,s3
    4f0c:	00778023          	sb	t2,0(a5)
    4f10:	f078f4e3          	bgeu	a7,t2,4e18 <ecvt+0x458>
    4f14:	00000013          	nop
    4f18:	e0f4fee3          	bgeu	s1,a5,4d34 <ecvt+0x374>
    4f1c:	fff7ce03          	lbu	t3,-1(a5)
    4f20:	00c78023          	sb	a2,0(a5)
    4f24:	001e051b          	addiw	a0,t3,1
    4f28:	0ff57993          	zext.b	s3,a0
    4f2c:	ff378fa3          	sb	s3,-1(a5)
    4f30:	ef38f4e3          	bgeu	a7,s3,4e18 <ecvt+0x458>
    4f34:	ffe7c383          	lbu	t2,-2(a5)
    4f38:	fec78fa3          	sb	a2,-1(a5)
    4f3c:	0013859b          	addiw	a1,t2,1
    4f40:	0ff5f813          	zext.b	a6,a1
    4f44:	ff078f23          	sb	a6,-2(a5)
    4f48:	ed08f8e3          	bgeu	a7,a6,4e18 <ecvt+0x458>
    4f4c:	ffd7c703          	lbu	a4,-3(a5)
    4f50:	fec78f23          	sb	a2,-2(a5)
    4f54:	00170e9b          	addiw	t4,a4,1
    4f58:	0ffeff13          	zext.b	t5,t4
    4f5c:	ffe78ea3          	sb	t5,-3(a5)
    4f60:	ebe8fce3          	bgeu	a7,t5,4e18 <ecvt+0x458>
    4f64:	ffc7cf83          	lbu	t6,-4(a5)
    4f68:	fec78ea3          	sb	a2,-3(a5)
    4f6c:	001f829b          	addiw	t0,t6,1
    4f70:	0ff2fa93          	zext.b	s5,t0
    4f74:	ff578e23          	sb	s5,-4(a5)
    4f78:	eb58f0e3          	bgeu	a7,s5,4e18 <ecvt+0x458>
    4f7c:	ffb7c303          	lbu	t1,-5(a5)
    4f80:	fec78e23          	sb	a2,-4(a5)
    4f84:	00130a1b          	addiw	s4,t1,1
    4f88:	0ffa7693          	zext.b	a3,s4
    4f8c:	fed78da3          	sb	a3,-5(a5)
    4f90:	e8d8f4e3          	bgeu	a7,a3,4e18 <ecvt+0x458>
    4f94:	ffa7ce03          	lbu	t3,-6(a5)
    4f98:	fec78da3          	sb	a2,-5(a5)
    4f9c:	001e051b          	addiw	a0,t3,1
    4fa0:	0ff57993          	zext.b	s3,a0
    4fa4:	ff378d23          	sb	s3,-6(a5)
    4fa8:	e738f8e3          	bgeu	a7,s3,4e18 <ecvt+0x458>
    4fac:	ff97c383          	lbu	t2,-7(a5)
    4fb0:	fec78d23          	sb	a2,-6(a5)
    4fb4:	0013859b          	addiw	a1,t2,1
    4fb8:	0ff5f813          	zext.b	a6,a1
    4fbc:	ff078ca3          	sb	a6,-7(a5)
    4fc0:	e508fce3          	bgeu	a7,a6,4e18 <ecvt+0x458>
    4fc4:	ff87c703          	lbu	a4,-8(a5)
    4fc8:	fec78ca3          	sb	a2,-7(a5)
    4fcc:	00170e9b          	addiw	t4,a4,1
    4fd0:	0ffeff13          	zext.b	t5,t4
    4fd4:	ffe78c23          	sb	t5,-8(a5)
    4fd8:	e5e8f0e3          	bgeu	a7,t5,4e18 <ecvt+0x458>
    4fdc:	17e1                	addi	a5,a5,-8
    4fde:	bf2d                	j	4f18 <ecvt+0x558>
    4fe0:	a2a914d3          	flt.d	s1,fs2,fa0
    4fe4:	c8f5                	beqz	s1,50d8 <ecvt+0x718>
    4fe6:	6645                	lui	a2,0x11
    4fe8:	b8063707          	fld	fa4,-1152(a2) # 10b80 <errpat+0x38>
    4fec:	6745                	lui	a4,0x11
    4fee:	b9073607          	fld	fa2,-1136(a4) # 10b90 <errpat+0x48>
    4ff2:	12e57053          	fmul.d	ft0,fa0,fa4
    4ff6:	4a81                	li	s5,0
    4ff8:	22c606d3          	fmv.d	fa3,fa2
    4ffc:	a2c01853          	flt.d	a6,ft0,fa2
    5000:	08080c63          	beqz	a6,5098 <ecvt+0x6d8>
    5004:	22000453          	fmv.d	fs0,ft0
    5008:	3afd                	addiw	s5,s5,-1
    500a:	12e07053          	fmul.d	ft0,ft0,fa4
    500e:	a2d018d3          	flt.d	a7,ft0,fa3
    5012:	08088363          	beqz	a7,5098 <ecvt+0x6d8>
    5016:	22000453          	fmv.d	fs0,ft0
    501a:	3afd                	addiw	s5,s5,-1
    501c:	12e07053          	fmul.d	ft0,ft0,fa4
    5020:	a2d019d3          	flt.d	s3,ft0,fa3
    5024:	06098a63          	beqz	s3,5098 <ecvt+0x6d8>
    5028:	22000453          	fmv.d	fs0,ft0
    502c:	3afd                	addiw	s5,s5,-1
    502e:	12e07053          	fmul.d	ft0,ft0,fa4
    5032:	a2d01a53          	flt.d	s4,ft0,fa3
    5036:	060a0163          	beqz	s4,5098 <ecvt+0x6d8>
    503a:	22000453          	fmv.d	fs0,ft0
    503e:	3afd                	addiw	s5,s5,-1
    5040:	12e07053          	fmul.d	ft0,ft0,fa4
    5044:	a2d01e53          	flt.d	t3,ft0,fa3
    5048:	040e0863          	beqz	t3,5098 <ecvt+0x6d8>
    504c:	22000453          	fmv.d	fs0,ft0
    5050:	3afd                	addiw	s5,s5,-1
    5052:	12e07053          	fmul.d	ft0,ft0,fa4
    5056:	a2d01ed3          	flt.d	t4,ft0,fa3
    505a:	020e8f63          	beqz	t4,5098 <ecvt+0x6d8>
    505e:	22000453          	fmv.d	fs0,ft0
    5062:	3afd                	addiw	s5,s5,-1
    5064:	12e07053          	fmul.d	ft0,ft0,fa4
    5068:	a2d01f53          	flt.d	t5,ft0,fa3
    506c:	020f0663          	beqz	t5,5098 <ecvt+0x6d8>
    5070:	22000453          	fmv.d	fs0,ft0
    5074:	3afd                	addiw	s5,s5,-1
    5076:	12e07053          	fmul.d	ft0,ft0,fa4
    507a:	a2d01fd3          	flt.d	t6,ft0,fa3
    507e:	000f8d63          	beqz	t6,5098 <ecvt+0x6d8>
    5082:	22000453          	fmv.d	fs0,ft0
    5086:	3afd                	addiw	s5,s5,-1
    5088:	12e07053          	fmul.d	ft0,ft0,fa4
    508c:	a2d017d3          	flt.d	a5,ft0,fa3
    5090:	fbb5                	bnez	a5,5004 <ecvt+0x644>
    5092:	0001                	nop
    5094:	00000013          	nop
    5098:	000416b7          	lui	a3,0x41
    509c:	a402                	fsd	ft0,8(sp)
    509e:	fd068493          	addi	s1,a3,-48 # 40fd0 <CVTBUF>
    50a2:	9426                	add	s0,s0,s1
    50a4:	01592023          	sw	s5,0(s2)
    50a8:	02946063          	bltu	s0,s1,50c8 <ecvt+0x708>
    50ac:	000419b7          	lui	s3,0x41
    50b0:	8a26                	mv	s4,s1
    50b2:	02098993          	addi	s3,s3,32 # 41020 <Loop_Num>
    50b6:	be35                	j	4bf2 <ecvt+0x232>
    50b8:	4305                	li	t1,1
    50ba:	22a51553          	fneg.d	fa0,fa0
    50be:	00662023          	sw	t1,0(a2)
    50c2:	ba3d                	j	4a00 <ecvt+0x40>
    50c4:	29c2                	fld	fs3,16(sp)
    50c6:	7b42                	ld	s6,48(sp)
    50c8:	00048023          	sb	zero,0(s1)
    50cc:	bb81                	j	4e1c <ecvt+0x45c>
    50ce:	0001                	nop
    50d0:	040487a3          	sb	zero,79(s1)
    50d4:	b3a1                	j	4e1c <ecvt+0x45c>
    50d6:	0001                	nop
    50d8:	000415b7          	lui	a1,0x41
    50dc:	4a81                	li	s5,0
    50de:	fd058493          	addi	s1,a1,-48 # 40fd0 <CVTBUF>
    50e2:	b7c1                	j	50a2 <ecvt+0x6e2>
    50e4:	29c2                	fld	fs3,16(sp)
    50e6:	7b42                	ld	s6,48(sp)
    50e8:	bf6d                	j	50a2 <ecvt+0x6e2>
    50ea:	00000013          	nop
    50ee:	0001                	nop

00000000000050f0 <ecvtbuf>:
    50f0:	7159                	addi	sp,sp,-112
    50f2:	f0a2                	sd	s0,96(sp)
    50f4:	f486                	sd	ra,104(sp)
    50f6:	0005041b          	sext.w	s0,a0
    50fa:	f20007d3          	fmv.d.x	fa5,zero
    50fe:	04e00793          	li	a5,78
    5102:	e8ca                	sd	s2,80(sp)
    5104:	eca6                	sd	s1,88(sp)
    5106:	a2f512d3          	flt.d	t0,fa0,fa5
    510a:	84b6                	mv	s1,a3
    510c:	00042693          	slti	a3,s0,0
    5110:	e0d2                	sd	s4,64(sp)
    5112:	e4ce                	sd	s3,72(sp)
    5114:	42d0140b          	th.mvnez	s0,zero,a3
    5118:	00a7a533          	slt	a0,a5,a0
    511c:	ff515b0b          	th.sdd	s6,s5,(sp),3,4
    5120:	b422                	fsd	fs0,40(sp)
    5122:	b026                	fsd	fs1,32(sp)
    5124:	ac4a                	fsd	fs2,24(sp)
    5126:	892e                	mv	s2,a1
    5128:	42a7940b          	th.mvnez	s0,a5,a0
    512c:	6c029463          	bnez	t0,57f4 <ecvtbuf+0x704>
    5130:	00062023          	sw	zero,0(a2)
    5134:	850a                	mv	a0,sp
    5136:	6200a0ef          	jal	f756 <modf>
    513a:	2e02                	fld	ft8,0(sp)
    513c:	f2000953          	fmv.d.x	fs2,zero
    5140:	22a50453          	fmv.d	fs0,fa0
    5144:	a32e23d3          	feq.d	t2,ft8,fs2
    5148:	5e039063          	bnez	t2,5728 <ecvtbuf+0x638>
    514c:	67c5                	lui	a5,0x11
    514e:	66c5                	lui	a3,0x11
    5150:	a84e                	fsd	fs3,16(sp)
    5152:	b807b487          	fld	fs1,-1152(a5) # 10b80 <errpat+0x38>
    5156:	b886b987          	fld	fs3,-1144(a3) # 10b88 <errpat+0x40>
    515a:	05048993          	addi	s3,s1,80
    515e:	8ace                	mv	s5,s3
    5160:	4b01                	li	s6,0
    5162:	1a9e7553          	fdiv.d	fa0,ft8,fs1
    5166:	850a                	mv	a0,sp
    5168:	1afd                	addi	s5,s5,-1
    516a:	2b05                	addiw	s6,s6,1
    516c:	8a56                	mv	s4,s5
    516e:	5e80a0ef          	jal	f756 <modf>
    5172:	a42a                	fsd	fa0,8(sp)
    5174:	03357553          	fadd.d	fa0,fa0,fs3
    5178:	2102                	fld	ft2,0(sp)
    517a:	8fda                	mv	t6,s6
    517c:	129570d3          	fmul.d	ft1,fa0,fs1
    5180:	a3212353          	feq.d	t1,ft2,fs2
    5184:	c2009553          	fcvt.w.d	a0,ft1,rtz
    5188:	0305029b          	addiw	t0,a0,48
    518c:	0ff2ff13          	zext.b	t5,t0
    5190:	01ea8023          	sb	t5,0(s5)
    5194:	08031f63          	bnez	t1,5232 <ecvtbuf+0x142>
    5198:	1a917553          	fdiv.d	fa0,ft2,fs1
    519c:	850a                	mv	a0,sp
    519e:	2b05                	addiw	s6,s6,1
    51a0:	5b60a0ef          	jal	f756 <modf>
    51a4:	033571d3          	fadd.d	ft3,fa0,fs3
    51a8:	2282                	fld	ft5,0(sp)
    51aa:	a42a                	fsd	fa0,8(sp)
    51ac:	1291f253          	fmul.d	ft4,ft3,fs1
    51b0:	a322a653          	feq.d	a2,ft5,fs2
    51b4:	8fda                	mv	t6,s6
    51b6:	c20213d3          	fcvt.w.d	t2,ft4,rtz
    51ba:	0303859b          	addiw	a1,t2,48
    51be:	0ff5ff13          	zext.b	t5,a1
    51c2:	09fadf0b          	th.sbib	t5,(s5),-1,0
    51c6:	e635                	bnez	a2,5232 <ecvtbuf+0x142>
    51c8:	1a92f553          	fdiv.d	fa0,ft5,fs1
    51cc:	850a                	mv	a0,sp
    51ce:	2b05                	addiw	s6,s6,1
    51d0:	ffea0a93          	addi	s5,s4,-2
    51d4:	5820a0ef          	jal	f756 <modf>
    51d8:	03357353          	fadd.d	ft6,fa0,fs3
    51dc:	2582                	fld	fa1,0(sp)
    51de:	a42a                	fsd	fa0,8(sp)
    51e0:	129373d3          	fmul.d	ft7,ft6,fs1
    51e4:	a325a8d3          	feq.d	a7,fa1,fs2
    51e8:	8fda                	mv	t6,s6
    51ea:	c2039753          	fcvt.w.d	a4,ft7,rtz
    51ee:	0307081b          	addiw	a6,a4,48
    51f2:	0ff87f13          	zext.b	t5,a6
    51f6:	ffea0f23          	sb	t5,-2(s4)
    51fa:	02089c63          	bnez	a7,5232 <ecvtbuf+0x142>
    51fe:	1a95f553          	fdiv.d	fa0,fa1,fs1
    5202:	850a                	mv	a0,sp
    5204:	2b05                	addiw	s6,s6,1
    5206:	ffda0a93          	addi	s5,s4,-3
    520a:	54c0a0ef          	jal	f756 <modf>
    520e:	03357853          	fadd.d	fa6,fa0,fs3
    5212:	2e02                	fld	ft8,0(sp)
    5214:	a42a                	fsd	fa0,8(sp)
    5216:	129878d3          	fmul.d	fa7,fa6,fs1
    521a:	a32e27d3          	feq.d	a5,ft8,fs2
    521e:	8fda                	mv	t6,s6
    5220:	c2089e53          	fcvt.w.d	t3,fa7,rtz
    5224:	030e0e9b          	addiw	t4,t3,48
    5228:	0ffeff13          	zext.b	t5,t4
    522c:	ffea0ea3          	sb	t5,-3(s4)
    5230:	db8d                	beqz	a5,5162 <ecvtbuf+0x72>
    5232:	5d3afe63          	bgeu	s5,s3,580e <ecvtbuf+0x71e>
    5236:	41548b33          	sub	s6,s1,s5
    523a:	04fb0a13          	addi	s4,s6,79
    523e:	007a7293          	andi	t0,s4,7
    5242:	050b0693          	addi	a3,s6,80
    5246:	4701                	li	a4,0
    5248:	0c028763          	beqz	t0,5316 <ecvtbuf+0x226>
    524c:	01e48023          	sb	t5,0(s1)
    5250:	4705                	li	a4,1
    5252:	80eacf0b          	th.lrbu	t5,s5,a4,0
    5256:	0ce28063          	beq	t0,a4,5316 <ecvtbuf+0x226>
    525a:	4309                	li	t1,2
    525c:	04628763          	beq	t0,t1,52aa <ecvtbuf+0x1ba>
    5260:	450d                	li	a0,3
    5262:	02a28f63          	beq	t0,a0,52a0 <ecvtbuf+0x1b0>
    5266:	4391                	li	t2,4
    5268:	02728763          	beq	t0,t2,5296 <ecvtbuf+0x1a6>
    526c:	4595                	li	a1,5
    526e:	00b28f63          	beq	t0,a1,528c <ecvtbuf+0x19c>
    5272:	4619                	li	a2,6
    5274:	00c28763          	beq	t0,a2,5282 <ecvtbuf+0x192>
    5278:	00e4df0b          	th.srb	t5,s1,a4,0
    527c:	806acf0b          	th.lrbu	t5,s5,t1,0
    5280:	871a                	mv	a4,t1
    5282:	00e4df0b          	th.srb	t5,s1,a4,0
    5286:	0705                	addi	a4,a4,1
    5288:	80eacf0b          	th.lrbu	t5,s5,a4,0
    528c:	00e4df0b          	th.srb	t5,s1,a4,0
    5290:	0705                	addi	a4,a4,1
    5292:	80eacf0b          	th.lrbu	t5,s5,a4,0
    5296:	00e4df0b          	th.srb	t5,s1,a4,0
    529a:	0705                	addi	a4,a4,1
    529c:	80eacf0b          	th.lrbu	t5,s5,a4,0
    52a0:	00e4df0b          	th.srb	t5,s1,a4,0
    52a4:	0705                	addi	a4,a4,1
    52a6:	80eacf0b          	th.lrbu	t5,s5,a4,0
    52aa:	00e4df0b          	th.srb	t5,s1,a4,0
    52ae:	0705                	addi	a4,a4,1
    52b0:	80eacf0b          	th.lrbu	t5,s5,a4,0
    52b4:	00170813          	addi	a6,a4,1
    52b8:	00e4df0b          	th.srb	t5,s1,a4,0
    52bc:	06d80363          	beq	a6,a3,5322 <ecvtbuf+0x232>
    52c0:	810ac28b          	th.lrbu	t0,s5,a6,0
    52c4:	00270313          	addi	t1,a4,2
    52c8:	00370893          	addi	a7,a4,3
    52cc:	0104d28b          	th.srb	t0,s1,a6,0
    52d0:	806ac80b          	th.lrbu	a6,s5,t1,0
    52d4:	00470a13          	addi	s4,a4,4
    52d8:	00570e93          	addi	t4,a4,5
    52dc:	0064d80b          	th.srb	a6,s1,t1,0
    52e0:	811acb0b          	th.lrbu	s6,s5,a7,0
    52e4:	00670513          	addi	a0,a4,6
    52e8:	00770593          	addi	a1,a4,7
    52ec:	0114db0b          	th.srb	s6,s1,a7,0
    52f0:	814ace0b          	th.lrbu	t3,s5,s4,0
    52f4:	0721                	addi	a4,a4,8
    52f6:	0144de0b          	th.srb	t3,s1,s4,0
    52fa:	81dacf0b          	th.lrbu	t5,s5,t4,0
    52fe:	01d4df0b          	th.srb	t5,s1,t4,0
    5302:	80aac38b          	th.lrbu	t2,s5,a0,0
    5306:	00a4d38b          	th.srb	t2,s1,a0,0
    530a:	80bac60b          	th.lrbu	a2,s5,a1,0
    530e:	00b4d60b          	th.srb	a2,s1,a1,0
    5312:	80eacf0b          	th.lrbu	t5,s5,a4,0
    5316:	00e4df0b          	th.srb	t5,s1,a4,0
    531a:	00170813          	addi	a6,a4,1
    531e:	fad811e3          	bne	a6,a3,52c0 <ecvtbuf+0x1d0>
    5322:	9426                	add	s0,s0,s1
    5324:	01f92023          	sw	t6,0(s2)
    5328:	4c946c63          	bltu	s0,s1,5800 <ecvtbuf+0x710>
    532c:	00d48a33          	add	s4,s1,a3
    5330:	29c2                	fld	fs3,16(sp)
    5332:	11446763          	bltu	s0,s4,5440 <ecvtbuf+0x350>
    5336:	41498ab3          	sub	s5,s3,s4
    533a:	68c5                	lui	a7,0x11
    533c:	003afb13          	andi	s6,s5,3
    5340:	b808b907          	fld	fs2,-1152(a7) # 10b80 <errpat+0x38>
    5344:	060b0a63          	beqz	s6,53b8 <ecvtbuf+0x2c8>
    5348:	0f3a7c63          	bgeu	s4,s3,5440 <ecvtbuf+0x350>
    534c:	13247553          	fmul.d	fa0,fs0,fs2
    5350:	0028                	addi	a0,sp,8
    5352:	4040a0ef          	jal	f756 <modf>
    5356:	2ea2                	fld	ft9,8(sp)
    5358:	22a50453          	fmv.d	fs0,fa0
    535c:	c20e9e53          	fcvt.w.d	t3,ft9,rtz
    5360:	030e0e9b          	addiw	t4,t3,48
    5364:	181a5e8b          	th.sbia	t4,(s4),1,0
    5368:	0d446c63          	bltu	s0,s4,5440 <ecvtbuf+0x350>
    536c:	4f05                	li	t5,1
    536e:	05eb0563          	beq	s6,t5,53b8 <ecvtbuf+0x2c8>
    5372:	4f89                	li	t6,2
    5374:	03fb0263          	beq	s6,t6,5398 <ecvtbuf+0x2a8>
    5378:	13257553          	fmul.d	fa0,fa0,fs2
    537c:	0028                	addi	a0,sp,8
    537e:	3d80a0ef          	jal	f756 <modf>
    5382:	2f22                	fld	ft10,8(sp)
    5384:	22a50453          	fmv.d	fs0,fa0
    5388:	c20f17d3          	fcvt.w.d	a5,ft10,rtz
    538c:	0307869b          	addiw	a3,a5,48
    5390:	181a568b          	th.sbia	a3,(s4),1,0
    5394:	0b446663          	bltu	s0,s4,5440 <ecvtbuf+0x350>
    5398:	13247553          	fmul.d	fa0,fs0,fs2
    539c:	0028                	addi	a0,sp,8
    539e:	3b80a0ef          	jal	f756 <modf>
    53a2:	2fa2                	fld	ft11,8(sp)
    53a4:	22a50453          	fmv.d	fs0,fa0
    53a8:	c20f92d3          	fcvt.w.d	t0,ft11,rtz
    53ac:	0302831b          	addiw	t1,t0,48
    53b0:	181a530b          	th.sbia	t1,(s4),1,0
    53b4:	09446663          	bltu	s0,s4,5440 <ecvtbuf+0x350>
    53b8:	093a7463          	bgeu	s4,s3,5440 <ecvtbuf+0x350>
    53bc:	13247553          	fmul.d	fa0,fs0,fs2
    53c0:	0028                	addi	a0,sp,8
    53c2:	3940a0ef          	jal	f756 <modf>
    53c6:	27a2                	fld	fa5,8(sp)
    53c8:	8552                	mv	a0,s4
    53ca:	c20793d3          	fcvt.w.d	t2,fa5,rtz
    53ce:	0303859b          	addiw	a1,t2,48
    53d2:	1815558b          	th.sbia	a1,(a0),1,0
    53d6:	06a46563          	bltu	s0,a0,5440 <ecvtbuf+0x350>
    53da:	13257553          	fmul.d	fa0,fa0,fs2
    53de:	0028                	addi	a0,sp,8
    53e0:	3760a0ef          	jal	f756 <modf>
    53e4:	2722                	fld	fa4,8(sp)
    53e6:	002a0613          	addi	a2,s4,2
    53ea:	c2071753          	fcvt.w.d	a4,fa4,rtz
    53ee:	0307081b          	addiw	a6,a4,48
    53f2:	010a00a3          	sb	a6,1(s4)
    53f6:	04c46563          	bltu	s0,a2,5440 <ecvtbuf+0x350>
    53fa:	13257553          	fmul.d	fa0,fa0,fs2
    53fe:	0028                	addi	a0,sp,8
    5400:	3560a0ef          	jal	f756 <modf>
    5404:	2622                	fld	fa2,8(sp)
    5406:	003a0893          	addi	a7,s4,3
    540a:	c2061ad3          	fcvt.w.d	s5,fa2,rtz
    540e:	030a8b1b          	addiw	s6,s5,48
    5412:	016a0123          	sb	s6,2(s4)
    5416:	03146563          	bltu	s0,a7,5440 <ecvtbuf+0x350>
    541a:	13257553          	fmul.d	fa0,fa0,fs2
    541e:	0028                	addi	a0,sp,8
    5420:	0a11                	addi	s4,s4,4
    5422:	3340a0ef          	jal	f756 <modf>
    5426:	26a2                	fld	fa3,8(sp)
    5428:	22a50453          	fmv.d	fs0,fa0
    542c:	c2069e53          	fcvt.w.d	t3,fa3,rtz
    5430:	030e0e9b          	addiw	t4,t3,48
    5434:	ffda0fa3          	sb	t4,-1(s4)
    5438:	f94470e3          	bgeu	s0,s4,53b8 <ecvtbuf+0x2c8>
    543c:	00000013          	nop
    5440:	3d347463          	bgeu	s0,s3,5808 <ecvtbuf+0x718>
    5444:	00044983          	lbu	s3,0(s0)
    5448:	03900693          	li	a3,57
    544c:	00598f1b          	addiw	t5,s3,5
    5450:	0fff7f93          	zext.b	t6,t5
    5454:	11f6f263          	bgeu	a3,t6,5558 <ecvtbuf+0x468>
    5458:	40940533          	sub	a0,s0,s1
    545c:	01f40023          	sb	t6,0(s0)
    5460:	00757393          	andi	t2,a0,7
    5464:	87a2                	mv	a5,s0
    5466:	03000293          	li	t0,48
    546a:	8336                	mv	t1,a3
    546c:	1e038a63          	beqz	t2,5660 <ecvtbuf+0x570>
    5470:	1084e463          	bltu	s1,s0,5578 <ecvtbuf+0x488>
    5474:	03100293          	li	t0,49
    5478:	00578023          	sb	t0,0(a5)
    547c:	00092303          	lw	t1,0(s2)
    5480:	03900713          	li	a4,57
    5484:	0013059b          	addiw	a1,t1,1
    5488:	00b92023          	sw	a1,0(s2)
    548c:	0007c603          	lbu	a2,0(a5)
    5490:	0cc77463          	bgeu	a4,a2,5558 <ecvtbuf+0x468>
    5494:	00578023          	sb	t0,0(a5)
    5498:	00092803          	lw	a6,0(s2)
    549c:	0018089b          	addiw	a7,a6,1
    54a0:	01192023          	sw	a7,0(s2)
    54a4:	0007ca83          	lbu	s5,0(a5)
    54a8:	0b577863          	bgeu	a4,s5,5558 <ecvtbuf+0x468>
    54ac:	00578023          	sb	t0,0(a5)
    54b0:	00092b03          	lw	s6,0(s2)
    54b4:	001b0a1b          	addiw	s4,s6,1
    54b8:	01492023          	sw	s4,0(s2)
    54bc:	0007ce03          	lbu	t3,0(a5)
    54c0:	09c77c63          	bgeu	a4,t3,5558 <ecvtbuf+0x468>
    54c4:	00578023          	sb	t0,0(a5)
    54c8:	00092e83          	lw	t4,0(s2)
    54cc:	001e899b          	addiw	s3,t4,1
    54d0:	01392023          	sw	s3,0(s2)
    54d4:	0007cf03          	lbu	t5,0(a5)
    54d8:	09e77063          	bgeu	a4,t5,5558 <ecvtbuf+0x468>
    54dc:	00578023          	sb	t0,0(a5)
    54e0:	00092f83          	lw	t6,0(s2)
    54e4:	001f869b          	addiw	a3,t6,1
    54e8:	00d92023          	sw	a3,0(s2)
    54ec:	0007c503          	lbu	a0,0(a5)
    54f0:	06a77463          	bgeu	a4,a0,5558 <ecvtbuf+0x468>
    54f4:	00578023          	sb	t0,0(a5)
    54f8:	00092383          	lw	t2,0(s2)
    54fc:	0013831b          	addiw	t1,t2,1
    5500:	00692023          	sw	t1,0(s2)
    5504:	0007c583          	lbu	a1,0(a5)
    5508:	04b77863          	bgeu	a4,a1,5558 <ecvtbuf+0x468>
    550c:	00578023          	sb	t0,0(a5)
    5510:	00092603          	lw	a2,0(s2)
    5514:	0016081b          	addiw	a6,a2,1
    5518:	01092023          	sw	a6,0(s2)
    551c:	0007c883          	lbu	a7,0(a5)
    5520:	03177c63          	bgeu	a4,a7,5558 <ecvtbuf+0x468>
    5524:	00578023          	sb	t0,0(a5)
    5528:	00092a83          	lw	s5,0(s2)
    552c:	001a8b1b          	addiw	s6,s5,1
    5530:	01692023          	sw	s6,0(s2)
    5534:	0007ca03          	lbu	s4,0(a5)
    5538:	03477063          	bgeu	a4,s4,5558 <ecvtbuf+0x468>
    553c:	00578023          	sb	t0,0(a5)
    5540:	00092e03          	lw	t3,0(s2)
    5544:	001e0e9b          	addiw	t4,t3,1
    5548:	01d92023          	sw	t4,0(s2)
    554c:	0007c983          	lbu	s3,0(a5)
    5550:	f53762e3          	bltu	a4,s3,5494 <ecvtbuf+0x3a4>
    5554:	00000013          	nop
    5558:	00040023          	sb	zero,0(s0)
    555c:	7406                	ld	s0,96(sp)
    555e:	70a6                	ld	ra,104(sp)
    5560:	6a06                	ld	s4,64(sp)
    5562:	69a6                	ld	s3,72(sp)
    5564:	ff514b0b          	th.ldd	s6,s5,(sp),3,4
    5568:	3422                	fld	fs0,40(sp)
    556a:	3482                	fld	fs1,32(sp)
    556c:	2962                	fld	fs2,24(sp)
    556e:	8526                	mv	a0,s1
    5570:	6946                	ld	s2,80(sp)
    5572:	64e6                	ld	s1,88(sp)
    5574:	6165                	addi	sp,sp,112
    5576:	8082                	ret
    5578:	85a2                	mv	a1,s0
    557a:	19f5d28b          	th.sbia	t0,(a1),-1,0
    557e:	fff44783          	lbu	a5,-1(s0)
    5582:	0017861b          	addiw	a2,a5,1
    5586:	0ff67713          	zext.b	a4,a2
    558a:	fee40fa3          	sb	a4,-1(s0)
    558e:	fce6f5e3          	bgeu	a3,a4,5558 <ecvtbuf+0x468>
    5592:	4805                	li	a6,1
    5594:	87ae                	mv	a5,a1
    5596:	0d038563          	beq	t2,a6,5660 <ecvtbuf+0x570>
    559a:	4889                	li	a7,2
    559c:	0b138263          	beq	t2,a7,5640 <ecvtbuf+0x550>
    55a0:	4a8d                	li	s5,3
    55a2:	09538163          	beq	t2,s5,5624 <ecvtbuf+0x534>
    55a6:	4b11                	li	s6,4
    55a8:	07638063          	beq	t2,s6,5608 <ecvtbuf+0x518>
    55ac:	4a15                	li	s4,5
    55ae:	03438f63          	beq	t2,s4,55ec <ecvtbuf+0x4fc>
    55b2:	4e19                	li	t3,6
    55b4:	01c38e63          	beq	t2,t3,55d0 <ecvtbuf+0x4e0>
    55b8:	19f7d28b          	th.sbia	t0,(a5),-1,0
    55bc:	fff5ce83          	lbu	t4,-1(a1)
    55c0:	001e899b          	addiw	s3,t4,1
    55c4:	0ff9ff13          	zext.b	t5,s3
    55c8:	ffe58fa3          	sb	t5,-1(a1)
    55cc:	f9e6f6e3          	bgeu	a3,t5,5558 <ecvtbuf+0x468>
    55d0:	8fbe                	mv	t6,a5
    55d2:	19ffd28b          	th.sbia	t0,(t6),-1,0
    55d6:	fff7c683          	lbu	a3,-1(a5)
    55da:	0016851b          	addiw	a0,a3,1
    55de:	0ff57393          	zext.b	t2,a0
    55e2:	fe778fa3          	sb	t2,-1(a5)
    55e6:	f67379e3          	bgeu	t1,t2,5558 <ecvtbuf+0x468>
    55ea:	87fe                	mv	a5,t6
    55ec:	85be                	mv	a1,a5
    55ee:	19f5d28b          	th.sbia	t0,(a1),-1,0
    55f2:	fff7c603          	lbu	a2,-1(a5)
    55f6:	0016071b          	addiw	a4,a2,1
    55fa:	0ff77813          	zext.b	a6,a4
    55fe:	ff078fa3          	sb	a6,-1(a5)
    5602:	f5037be3          	bgeu	t1,a6,5558 <ecvtbuf+0x468>
    5606:	87ae                	mv	a5,a1
    5608:	88be                	mv	a7,a5
    560a:	19f8d28b          	th.sbia	t0,(a7),-1,0
    560e:	fff7ca83          	lbu	s5,-1(a5)
    5612:	001a8b1b          	addiw	s6,s5,1
    5616:	0ffb7a13          	zext.b	s4,s6
    561a:	ff478fa3          	sb	s4,-1(a5)
    561e:	f3437de3          	bgeu	t1,s4,5558 <ecvtbuf+0x468>
    5622:	87c6                	mv	a5,a7
    5624:	8e3e                	mv	t3,a5
    5626:	19fe528b          	th.sbia	t0,(t3),-1,0
    562a:	fff7ce83          	lbu	t4,-1(a5)
    562e:	001e899b          	addiw	s3,t4,1
    5632:	0ff9ff13          	zext.b	t5,s3
    5636:	ffe78fa3          	sb	t5,-1(a5)
    563a:	f1e37fe3          	bgeu	t1,t5,5558 <ecvtbuf+0x468>
    563e:	87f2                	mv	a5,t3
    5640:	8fbe                	mv	t6,a5
    5642:	19ffd28b          	th.sbia	t0,(t6),-1,0
    5646:	fff7c683          	lbu	a3,-1(a5)
    564a:	0016851b          	addiw	a0,a3,1
    564e:	0ff57393          	zext.b	t2,a0
    5652:	fe778fa3          	sb	t2,-1(a5)
    5656:	87fe                	mv	a5,t6
    5658:	f07370e3          	bgeu	t1,t2,5558 <ecvtbuf+0x468>
    565c:	00000013          	nop
    5660:	e0f4fae3          	bgeu	s1,a5,5474 <ecvtbuf+0x384>
    5664:	fff7c703          	lbu	a4,-1(a5)
    5668:	00578023          	sb	t0,0(a5)
    566c:	00170f1b          	addiw	t5,a4,1
    5670:	0fff7f93          	zext.b	t6,t5
    5674:	fff78fa3          	sb	t6,-1(a5)
    5678:	eff370e3          	bgeu	t1,t6,5558 <ecvtbuf+0x468>
    567c:	ffe7c683          	lbu	a3,-2(a5)
    5680:	fe578fa3          	sb	t0,-1(a5)
    5684:	0016851b          	addiw	a0,a3,1
    5688:	0ff57393          	zext.b	t2,a0
    568c:	fe778f23          	sb	t2,-2(a5)
    5690:	ec7374e3          	bgeu	t1,t2,5558 <ecvtbuf+0x468>
    5694:	ffd7c583          	lbu	a1,-3(a5)
    5698:	fe578f23          	sb	t0,-2(a5)
    569c:	0015861b          	addiw	a2,a1,1
    56a0:	0ff67813          	zext.b	a6,a2
    56a4:	ff078ea3          	sb	a6,-3(a5)
    56a8:	eb0378e3          	bgeu	t1,a6,5558 <ecvtbuf+0x468>
    56ac:	ffc7c883          	lbu	a7,-4(a5)
    56b0:	fe578ea3          	sb	t0,-3(a5)
    56b4:	00188a9b          	addiw	s5,a7,1
    56b8:	0ffafb13          	zext.b	s6,s5
    56bc:	ff678e23          	sb	s6,-4(a5)
    56c0:	e9637ce3          	bgeu	t1,s6,5558 <ecvtbuf+0x468>
    56c4:	ffb7ca03          	lbu	s4,-5(a5)
    56c8:	fe578e23          	sb	t0,-4(a5)
    56cc:	001a0e1b          	addiw	t3,s4,1
    56d0:	0ffe7e93          	zext.b	t4,t3
    56d4:	ffd78da3          	sb	t4,-5(a5)
    56d8:	e9d370e3          	bgeu	t1,t4,5558 <ecvtbuf+0x468>
    56dc:	ffa7c983          	lbu	s3,-6(a5)
    56e0:	fe578da3          	sb	t0,-5(a5)
    56e4:	0019871b          	addiw	a4,s3,1
    56e8:	0ff77f13          	zext.b	t5,a4
    56ec:	ffe78d23          	sb	t5,-6(a5)
    56f0:	e7e374e3          	bgeu	t1,t5,5558 <ecvtbuf+0x468>
    56f4:	ff97cf83          	lbu	t6,-7(a5)
    56f8:	fe578d23          	sb	t0,-6(a5)
    56fc:	001f869b          	addiw	a3,t6,1
    5700:	0ff6f513          	zext.b	a0,a3
    5704:	fea78ca3          	sb	a0,-7(a5)
    5708:	e4a378e3          	bgeu	t1,a0,5558 <ecvtbuf+0x468>
    570c:	ff87c383          	lbu	t2,-8(a5)
    5710:	fe578ca3          	sb	t0,-7(a5)
    5714:	0013859b          	addiw	a1,t2,1
    5718:	0ff5f613          	zext.b	a2,a1
    571c:	fec78c23          	sb	a2,-8(a5)
    5720:	e2c37ce3          	bgeu	t1,a2,5558 <ecvtbuf+0x468>
    5724:	17e1                	addi	a5,a5,-8
    5726:	bf2d                	j	5660 <ecvtbuf+0x570>
    5728:	a2a915d3          	flt.d	a1,fs2,fa0
    572c:	4b01                	li	s6,0
    572e:	c9d5                	beqz	a1,57e2 <ecvtbuf+0x6f2>
    5730:	6645                	lui	a2,0x11
    5732:	b8063707          	fld	fa4,-1152(a2) # 10b80 <errpat+0x38>
    5736:	6745                	lui	a4,0x11
    5738:	b9073607          	fld	fa2,-1136(a4) # 10b90 <errpat+0x48>
    573c:	12e57053          	fmul.d	ft0,fa0,fa4
    5740:	4b01                	li	s6,0
    5742:	22c606d3          	fmv.d	fa3,fa2
    5746:	a2c01853          	flt.d	a6,ft0,fa2
    574a:	08080b63          	beqz	a6,57e0 <ecvtbuf+0x6f0>
    574e:	22000453          	fmv.d	fs0,ft0
    5752:	3b7d                	addiw	s6,s6,-1
    5754:	12e07053          	fmul.d	ft0,ft0,fa4
    5758:	a2d018d3          	flt.d	a7,ft0,fa3
    575c:	08088263          	beqz	a7,57e0 <ecvtbuf+0x6f0>
    5760:	22000453          	fmv.d	fs0,ft0
    5764:	3b7d                	addiw	s6,s6,-1
    5766:	12e07053          	fmul.d	ft0,ft0,fa4
    576a:	a2d019d3          	flt.d	s3,ft0,fa3
    576e:	06098963          	beqz	s3,57e0 <ecvtbuf+0x6f0>
    5772:	22000453          	fmv.d	fs0,ft0
    5776:	3b7d                	addiw	s6,s6,-1
    5778:	12e07053          	fmul.d	ft0,ft0,fa4
    577c:	a2d01a53          	flt.d	s4,ft0,fa3
    5780:	060a0063          	beqz	s4,57e0 <ecvtbuf+0x6f0>
    5784:	22000453          	fmv.d	fs0,ft0
    5788:	3b7d                	addiw	s6,s6,-1
    578a:	12e07053          	fmul.d	ft0,ft0,fa4
    578e:	a2d01ad3          	flt.d	s5,ft0,fa3
    5792:	040a8763          	beqz	s5,57e0 <ecvtbuf+0x6f0>
    5796:	22000453          	fmv.d	fs0,ft0
    579a:	3b7d                	addiw	s6,s6,-1
    579c:	12e07053          	fmul.d	ft0,ft0,fa4
    57a0:	a2d01e53          	flt.d	t3,ft0,fa3
    57a4:	020e0e63          	beqz	t3,57e0 <ecvtbuf+0x6f0>
    57a8:	22000453          	fmv.d	fs0,ft0
    57ac:	3b7d                	addiw	s6,s6,-1
    57ae:	12e07053          	fmul.d	ft0,ft0,fa4
    57b2:	a2d01ed3          	flt.d	t4,ft0,fa3
    57b6:	020e8563          	beqz	t4,57e0 <ecvtbuf+0x6f0>
    57ba:	22000453          	fmv.d	fs0,ft0
    57be:	3b7d                	addiw	s6,s6,-1
    57c0:	12e07053          	fmul.d	ft0,ft0,fa4
    57c4:	a2d01f53          	flt.d	t5,ft0,fa3
    57c8:	000f0c63          	beqz	t5,57e0 <ecvtbuf+0x6f0>
    57cc:	22000453          	fmv.d	fs0,ft0
    57d0:	3b7d                	addiw	s6,s6,-1
    57d2:	12e07053          	fmul.d	ft0,ft0,fa4
    57d6:	a2d01fd3          	flt.d	t6,ft0,fa3
    57da:	f60f9ae3          	bnez	t6,574e <ecvtbuf+0x65e>
    57de:	0001                	nop
    57e0:	a402                	fsd	ft0,8(sp)
    57e2:	9426                	add	s0,s0,s1
    57e4:	01692023          	sw	s6,0(s2)
    57e8:	00946d63          	bltu	s0,s1,5802 <ecvtbuf+0x712>
    57ec:	8a26                	mv	s4,s1
    57ee:	05048993          	addi	s3,s1,80
    57f2:	b691                	j	5336 <ecvtbuf+0x246>
    57f4:	4305                	li	t1,1
    57f6:	22a51553          	fneg.d	fa0,fa0
    57fa:	00662023          	sw	t1,0(a2)
    57fe:	ba1d                	j	5134 <ecvtbuf+0x44>
    5800:	29c2                	fld	fs3,16(sp)
    5802:	00048023          	sb	zero,0(s1)
    5806:	bb99                	j	555c <ecvtbuf+0x46c>
    5808:	040487a3          	sb	zero,79(s1)
    580c:	bb81                	j	555c <ecvtbuf+0x46c>
    580e:	29c2                	fld	fs3,16(sp)
    5810:	bfc9                	j	57e2 <ecvtbuf+0x6f2>
    5812:	0001                	nop
    5814:	00000013          	nop
    5818:	00000013          	nop
    581c:	00000013          	nop

0000000000005820 <fcvt>:
    5820:	7159                	addi	sp,sp,-112
    5822:	f20007d3          	fmv.d.x	fa5,zero
    5826:	e4ce                	sd	s3,72(sp)
    5828:	e8ca                	sd	s2,80(sp)
    582a:	0005091b          	sext.w	s2,a0
    582e:	04e00793          	li	a5,78
    5832:	00092693          	slti	a3,s2,0
    5836:	a2f512d3          	flt.d	t0,fa0,fa5
    583a:	eca6                	sd	s1,88(sp)
    583c:	f0a2                	sd	s0,96(sp)
    583e:	fc56                	sd	s5,56(sp)
    5840:	e0d2                	sd	s4,64(sp)
    5842:	42d0190b          	th.mvnez	s2,zero,a3
    5846:	00a7a533          	slt	a0,a5,a0
    584a:	b422                	fsd	fs0,40(sp)
    584c:	b026                	fsd	fs1,32(sp)
    584e:	ac4a                	fsd	fs2,24(sp)
    5850:	f486                	sd	ra,104(sp)
    5852:	84ae                	mv	s1,a1
    5854:	42a7990b          	th.mvnez	s2,a5,a0
    5858:	4a029263          	bnez	t0,5cfc <fcvt+0x4dc>
    585c:	00062023          	sw	zero,0(a2)
    5860:	850a                	mv	a0,sp
    5862:	6f5090ef          	jal	f756 <modf>
    5866:	2e02                	fld	ft8,0(sp)
    5868:	f2000953          	fmv.d.x	fs2,zero
    586c:	22a50453          	fmv.d	fs0,fa0
    5870:	a32e23d3          	feq.d	t2,ft8,fs2
    5874:	3a039a63          	bnez	t2,5c28 <fcvt+0x408>
    5878:	00041337          	lui	t1,0x41
    587c:	63c5                	lui	t2,0x11
    587e:	65c5                	lui	a1,0x11
    5880:	a84e                	fsd	fs3,16(sp)
    5882:	fd030413          	addi	s0,t1,-48 # 40fd0 <CVTBUF>
    5886:	b803b487          	fld	fs1,-1152(t2) # 10b80 <errpat+0x38>
    588a:	b885b987          	fld	fs3,-1144(a1) # 10b88 <errpat+0x40>
    588e:	05040993          	addi	s3,s0,80
    5892:	f85a                	sd	s6,48(sp)
    5894:	4a81                	li	s5,0
    5896:	8b4e                	mv	s6,s3
    5898:	1a9e7553          	fdiv.d	fa0,ft8,fs1
    589c:	850a                	mv	a0,sp
    589e:	1b7d                	addi	s6,s6,-1
    58a0:	2a85                	addiw	s5,s5,1
    58a2:	8a5a                	mv	s4,s6
    58a4:	6b3090ef          	jal	f756 <modf>
    58a8:	a42a                	fsd	fa0,8(sp)
    58aa:	03357553          	fadd.d	fa0,fa0,fs3
    58ae:	2102                	fld	ft2,0(sp)
    58b0:	8356                	mv	t1,s5
    58b2:	129570d3          	fmul.d	ft1,fa0,fs1
    58b6:	a3212853          	feq.d	a6,ft2,fs2
    58ba:	c2009653          	fcvt.w.d	a2,ft1,rtz
    58be:	0306071b          	addiw	a4,a2,48
    58c2:	0ff77293          	zext.b	t0,a4
    58c6:	005b0023          	sb	t0,0(s6)
    58ca:	0a081063          	bnez	a6,596a <fcvt+0x14a>
    58ce:	1a917553          	fdiv.d	fa0,ft2,fs1
    58d2:	850a                	mv	a0,sp
    58d4:	2a85                	addiw	s5,s5,1
    58d6:	681090ef          	jal	f756 <modf>
    58da:	033571d3          	fadd.d	ft3,fa0,fs3
    58de:	2282                	fld	ft5,0(sp)
    58e0:	a42a                	fsd	fa0,8(sp)
    58e2:	1291f253          	fmul.d	ft4,ft3,fs1
    58e6:	a322aed3          	feq.d	t4,ft5,fs2
    58ea:	8356                	mv	t1,s5
    58ec:	c20218d3          	fcvt.w.d	a7,ft4,rtz
    58f0:	03088e1b          	addiw	t3,a7,48
    58f4:	0ffe7293          	zext.b	t0,t3
    58f8:	09fb528b          	th.sbib	t0,(s6),-1,0
    58fc:	060e9763          	bnez	t4,596a <fcvt+0x14a>
    5900:	1a92f553          	fdiv.d	fa0,ft5,fs1
    5904:	850a                	mv	a0,sp
    5906:	2a85                	addiw	s5,s5,1
    5908:	ffea0b13          	addi	s6,s4,-2
    590c:	64b090ef          	jal	f756 <modf>
    5910:	03357353          	fadd.d	ft6,fa0,fs3
    5914:	2582                	fld	fa1,0(sp)
    5916:	a42a                	fsd	fa0,8(sp)
    5918:	129373d3          	fmul.d	ft7,ft6,fs1
    591c:	a325a6d3          	feq.d	a3,fa1,fs2
    5920:	8356                	mv	t1,s5
    5922:	c2039f53          	fcvt.w.d	t5,ft7,rtz
    5926:	030f0f9b          	addiw	t6,t5,48
    592a:	0ffff293          	zext.b	t0,t6
    592e:	fe5a0f23          	sb	t0,-2(s4)
    5932:	ee85                	bnez	a3,596a <fcvt+0x14a>
    5934:	1a95f553          	fdiv.d	fa0,fa1,fs1
    5938:	850a                	mv	a0,sp
    593a:	2a85                	addiw	s5,s5,1
    593c:	ffda0b13          	addi	s6,s4,-3
    5940:	617090ef          	jal	f756 <modf>
    5944:	03357853          	fadd.d	fa6,fa0,fs3
    5948:	2e02                	fld	ft8,0(sp)
    594a:	a42a                	fsd	fa0,8(sp)
    594c:	129878d3          	fmul.d	fa7,fa6,fs1
    5950:	a32e23d3          	feq.d	t2,ft8,fs2
    5954:	8356                	mv	t1,s5
    5956:	c20897d3          	fcvt.w.d	a5,fa7,rtz
    595a:	0307851b          	addiw	a0,a5,48
    595e:	0ff57293          	zext.b	t0,a0
    5962:	fe5a0ea3          	sb	t0,-3(s4)
    5966:	f20389e3          	beqz	t2,5898 <fcvt+0x78>
    596a:	875a                	mv	a4,s6
    596c:	86a2                	mv	a3,s0
    596e:	3b3b7e63          	bgeu	s6,s3,5d2a <fcvt+0x50a>
    5972:	fffb4593          	not	a1,s6
    5976:	00b98a33          	add	s4,s3,a1
    597a:	007a7613          	andi	a2,s4,7
    597e:	c65d                	beqz	a2,5a2c <fcvt+0x20c>
    5980:	1816d28b          	th.sbia	t0,(a3),1,0
    5984:	4805                	li	a6,1
    5986:	8817428b          	th.lbuib	t0,(a4),1,0
    598a:	0b060163          	beq	a2,a6,5a2c <fcvt+0x20c>
    598e:	4889                	li	a7,2
    5990:	05160563          	beq	a2,a7,59da <fcvt+0x1ba>
    5994:	4e0d                	li	t3,3
    5996:	03c60e63          	beq	a2,t3,59d2 <fcvt+0x1b2>
    599a:	4e91                	li	t4,4
    599c:	03d60763          	beq	a2,t4,59ca <fcvt+0x1aa>
    59a0:	4f15                	li	t5,5
    59a2:	03e60063          	beq	a2,t5,59c2 <fcvt+0x1a2>
    59a6:	4f99                	li	t6,6
    59a8:	01f60963          	beq	a2,t6,59ba <fcvt+0x19a>
    59ac:	875a                	mv	a4,s6
    59ae:	005400a3          	sb	t0,1(s0)
    59b2:	8827428b          	th.lbuib	t0,(a4),2,0
    59b6:	00240693          	addi	a3,s0,2
    59ba:	1816d28b          	th.sbia	t0,(a3),1,0
    59be:	8817428b          	th.lbuib	t0,(a4),1,0
    59c2:	1816d28b          	th.sbia	t0,(a3),1,0
    59c6:	8817428b          	th.lbuib	t0,(a4),1,0
    59ca:	1816d28b          	th.sbia	t0,(a3),1,0
    59ce:	8817428b          	th.lbuib	t0,(a4),1,0
    59d2:	1816d28b          	th.sbia	t0,(a3),1,0
    59d6:	8817428b          	th.lbuib	t0,(a4),1,0
    59da:	1816d28b          	th.sbia	t0,(a3),1,0
    59de:	8817428b          	th.lbuib	t0,(a4),1,0
    59e2:	00170793          	addi	a5,a4,1
    59e6:	00568023          	sb	t0,0(a3)
    59ea:	04f98763          	beq	s3,a5,5a38 <fcvt+0x218>
    59ee:	00174e03          	lbu	t3,1(a4)
    59f2:	06a1                	addi	a3,a3,8
    59f4:	ffc68ca3          	sb	t3,-7(a3)
    59f8:	00274e83          	lbu	t4,2(a4)
    59fc:	ffd68d23          	sb	t4,-6(a3)
    5a00:	00374f03          	lbu	t5,3(a4)
    5a04:	ffe68da3          	sb	t5,-5(a3)
    5a08:	00474f83          	lbu	t6,4(a4)
    5a0c:	fff68e23          	sb	t6,-4(a3)
    5a10:	00574503          	lbu	a0,5(a4)
    5a14:	fea68ea3          	sb	a0,-3(a3)
    5a18:	00674283          	lbu	t0,6(a4)
    5a1c:	fe568f23          	sb	t0,-2(a3)
    5a20:	00774383          	lbu	t2,7(a4)
    5a24:	fe768fa3          	sb	t2,-1(a3)
    5a28:	8887428b          	th.lbuib	t0,(a4),8,0
    5a2c:	00170793          	addi	a5,a4,1
    5a30:	00568023          	sb	t0,0(a3)
    5a34:	faf99de3          	bne	s3,a5,59ee <fcvt+0x1ce>
    5a38:	9aca                	add	s5,s5,s2
    5a3a:	01540933          	add	s2,s0,s5
    5a3e:	0064a023          	sw	t1,0(s1)
    5a42:	2c896363          	bltu	s2,s0,5d08 <fcvt+0x4e8>
    5a46:	01340533          	add	a0,s0,s3
    5a4a:	41650a33          	sub	s4,a0,s6
    5a4e:	29c2                	fld	fs3,16(sp)
    5a50:	7b42                	ld	s6,48(sp)
    5a52:	11496763          	bltu	s2,s4,5b60 <fcvt+0x340>
    5a56:	41498333          	sub	t1,s3,s4
    5a5a:	62c5                	lui	t0,0x11
    5a5c:	00337a93          	andi	s5,t1,3
    5a60:	b802b907          	fld	fs2,-1152(t0) # 10b80 <errpat+0x38>
    5a64:	060a8a63          	beqz	s5,5ad8 <fcvt+0x2b8>
    5a68:	0f3a7c63          	bgeu	s4,s3,5b60 <fcvt+0x340>
    5a6c:	13247553          	fmul.d	fa0,fs0,fs2
    5a70:	0028                	addi	a0,sp,8
    5a72:	4e5090ef          	jal	f756 <modf>
    5a76:	2ea2                	fld	ft9,8(sp)
    5a78:	22a50453          	fmv.d	fs0,fa0
    5a7c:	c20e93d3          	fcvt.w.d	t2,ft9,rtz
    5a80:	0303859b          	addiw	a1,t2,48
    5a84:	181a558b          	th.sbia	a1,(s4),1,0
    5a88:	0d496c63          	bltu	s2,s4,5b60 <fcvt+0x340>
    5a8c:	4605                	li	a2,1
    5a8e:	04ca8563          	beq	s5,a2,5ad8 <fcvt+0x2b8>
    5a92:	4809                	li	a6,2
    5a94:	030a8263          	beq	s5,a6,5ab8 <fcvt+0x298>
    5a98:	13257553          	fmul.d	fa0,fa0,fs2
    5a9c:	0028                	addi	a0,sp,8
    5a9e:	4b9090ef          	jal	f756 <modf>
    5aa2:	2f22                	fld	ft10,8(sp)
    5aa4:	22a50453          	fmv.d	fs0,fa0
    5aa8:	c20f18d3          	fcvt.w.d	a7,ft10,rtz
    5aac:	03088e1b          	addiw	t3,a7,48
    5ab0:	181a5e0b          	th.sbia	t3,(s4),1,0
    5ab4:	0b496663          	bltu	s2,s4,5b60 <fcvt+0x340>
    5ab8:	13247553          	fmul.d	fa0,fs0,fs2
    5abc:	0028                	addi	a0,sp,8
    5abe:	499090ef          	jal	f756 <modf>
    5ac2:	2fa2                	fld	ft11,8(sp)
    5ac4:	22a50453          	fmv.d	fs0,fa0
    5ac8:	c20f9ed3          	fcvt.w.d	t4,ft11,rtz
    5acc:	030e8f1b          	addiw	t5,t4,48
    5ad0:	181a5f0b          	th.sbia	t5,(s4),1,0
    5ad4:	09496663          	bltu	s2,s4,5b60 <fcvt+0x340>
    5ad8:	093a7463          	bgeu	s4,s3,5b60 <fcvt+0x340>
    5adc:	13247553          	fmul.d	fa0,fs0,fs2
    5ae0:	0028                	addi	a0,sp,8
    5ae2:	475090ef          	jal	f756 <modf>
    5ae6:	27a2                	fld	fa5,8(sp)
    5ae8:	8fd2                	mv	t6,s4
    5aea:	c2079753          	fcvt.w.d	a4,fa5,rtz
    5aee:	0307069b          	addiw	a3,a4,48
    5af2:	181fd68b          	th.sbia	a3,(t6),1,0
    5af6:	07f96563          	bltu	s2,t6,5b60 <fcvt+0x340>
    5afa:	13257553          	fmul.d	fa0,fa0,fs2
    5afe:	0028                	addi	a0,sp,8
    5b00:	457090ef          	jal	f756 <modf>
    5b04:	2722                	fld	fa4,8(sp)
    5b06:	002a0793          	addi	a5,s4,2
    5b0a:	c2071553          	fcvt.w.d	a0,fa4,rtz
    5b0e:	0305029b          	addiw	t0,a0,48
    5b12:	005a00a3          	sb	t0,1(s4)
    5b16:	04f96563          	bltu	s2,a5,5b60 <fcvt+0x340>
    5b1a:	13257553          	fmul.d	fa0,fa0,fs2
    5b1e:	0028                	addi	a0,sp,8
    5b20:	437090ef          	jal	f756 <modf>
    5b24:	2622                	fld	fa2,8(sp)
    5b26:	003a0313          	addi	t1,s4,3
    5b2a:	c2061ad3          	fcvt.w.d	s5,fa2,rtz
    5b2e:	030a839b          	addiw	t2,s5,48
    5b32:	007a0123          	sb	t2,2(s4)
    5b36:	02696563          	bltu	s2,t1,5b60 <fcvt+0x340>
    5b3a:	13257553          	fmul.d	fa0,fa0,fs2
    5b3e:	0028                	addi	a0,sp,8
    5b40:	0a11                	addi	s4,s4,4
    5b42:	415090ef          	jal	f756 <modf>
    5b46:	26a2                	fld	fa3,8(sp)
    5b48:	22a50453          	fmv.d	fs0,fa0
    5b4c:	c20695d3          	fcvt.w.d	a1,fa3,rtz
    5b50:	0305861b          	addiw	a2,a1,48
    5b54:	feca0fa3          	sb	a2,-1(s4)
    5b58:	f94970e3          	bgeu	s2,s4,5ad8 <fcvt+0x2b8>
    5b5c:	00000013          	nop
    5b60:	1b397a63          	bgeu	s2,s3,5d14 <fcvt+0x4f4>
    5b64:	00094983          	lbu	s3,0(s2)
    5b68:	03900e13          	li	t3,57
    5b6c:	0059881b          	addiw	a6,s3,5
    5b70:	0ff87893          	zext.b	a7,a6
    5b74:	01190023          	sb	a7,0(s2)
    5b78:	071e7463          	bgeu	t3,a7,5be0 <fcvt+0x3c0>
    5b7c:	03000e93          	li	t4,48
    5b80:	87ca                	mv	a5,s2
    5b82:	8f76                	mv	t5,t4
    5b84:	03100f93          	li	t6,49
    5b88:	06f46c63          	bltu	s0,a5,5c00 <fcvt+0x3e0>
    5b8c:	01f78023          	sb	t6,0(a5)
    5b90:	4098                	lw	a4,0(s1)
    5b92:	0017069b          	addiw	a3,a4,1
    5b96:	c094                	sw	a3,0(s1)
    5b98:	01247463          	bgeu	s0,s2,5ba0 <fcvt+0x380>
    5b9c:	01d90023          	sb	t4,0(s2)
    5ba0:	0007c503          	lbu	a0,0(a5)
    5ba4:	0905                	addi	s2,s2,1
    5ba6:	02ae7d63          	bgeu	t3,a0,5be0 <fcvt+0x3c0>
    5baa:	04f46b63          	bltu	s0,a5,5c00 <fcvt+0x3e0>
    5bae:	03100293          	li	t0,49
    5bb2:	03900313          	li	t1,57
    5bb6:	03000a93          	li	s5,48
    5bba:	00578023          	sb	t0,0(a5)
    5bbe:	0004a383          	lw	t2,0(s1)
    5bc2:	00138a1b          	addiw	s4,t2,1
    5bc6:	0144a023          	sw	s4,0(s1)
    5bca:	05247963          	bgeu	s0,s2,5c1c <fcvt+0x3fc>
    5bce:	18195a8b          	th.sbia	s5,(s2),1,0
    5bd2:	0007c603          	lbu	a2,0(a5)
    5bd6:	fec362e3          	bltu	t1,a2,5bba <fcvt+0x39a>
    5bda:	0001                	nop
    5bdc:	00000013          	nop
    5be0:	00090023          	sb	zero,0(s2)
    5be4:	70a6                	ld	ra,104(sp)
    5be6:	8522                	mv	a0,s0
    5be8:	64e6                	ld	s1,88(sp)
    5bea:	7406                	ld	s0,96(sp)
    5bec:	7ae2                	ld	s5,56(sp)
    5bee:	6a06                	ld	s4,64(sp)
    5bf0:	69a6                	ld	s3,72(sp)
    5bf2:	6946                	ld	s2,80(sp)
    5bf4:	3422                	fld	fs0,40(sp)
    5bf6:	3482                	fld	fs1,32(sp)
    5bf8:	2962                	fld	fs2,24(sp)
    5bfa:	6165                	addi	sp,sp,112
    5bfc:	8082                	ret
    5bfe:	0001                	nop
    5c00:	fff7c983          	lbu	s3,-1(a5)
    5c04:	01e78023          	sb	t5,0(a5)
    5c08:	0019881b          	addiw	a6,s3,1
    5c0c:	0ff87893          	zext.b	a7,a6
    5c10:	ff178fa3          	sb	a7,-1(a5)
    5c14:	fd1e76e3          	bgeu	t3,a7,5be0 <fcvt+0x3c0>
    5c18:	17fd                	addi	a5,a5,-1
    5c1a:	b7bd                	j	5b88 <fcvt+0x368>
    5c1c:	0007c583          	lbu	a1,0(a5)
    5c20:	0905                	addi	s2,s2,1
    5c22:	f8b36ce3          	bltu	t1,a1,5bba <fcvt+0x39a>
    5c26:	bf6d                	j	5be0 <fcvt+0x3c0>
    5c28:	a2a91453          	flt.d	s0,fs2,fa0
    5c2c:	c865                	beqz	s0,5d1c <fcvt+0x4fc>
    5c2e:	6745                	lui	a4,0x11
    5c30:	b8073707          	fld	fa4,-1152(a4) # 10b80 <errpat+0x38>
    5c34:	6845                	lui	a6,0x11
    5c36:	b9083607          	fld	fa2,-1136(a6) # 10b90 <errpat+0x48>
    5c3a:	12e57053          	fmul.d	ft0,fa0,fa4
    5c3e:	4a81                	li	s5,0
    5c40:	22c606d3          	fmv.d	fa3,fa2
    5c44:	a2c018d3          	flt.d	a7,ft0,fa2
    5c48:	0e088563          	beqz	a7,5d32 <fcvt+0x512>
    5c4c:	22000453          	fmv.d	fs0,ft0
    5c50:	3afd                	addiw	s5,s5,-1
    5c52:	12e07053          	fmul.d	ft0,ft0,fa4
    5c56:	a2d01a53          	flt.d	s4,ft0,fa3
    5c5a:	060a0f63          	beqz	s4,5cd8 <fcvt+0x4b8>
    5c5e:	22000453          	fmv.d	fs0,ft0
    5c62:	3afd                	addiw	s5,s5,-1
    5c64:	12e07053          	fmul.d	ft0,ft0,fa4
    5c68:	a2d01e53          	flt.d	t3,ft0,fa3
    5c6c:	060e0663          	beqz	t3,5cd8 <fcvt+0x4b8>
    5c70:	22000453          	fmv.d	fs0,ft0
    5c74:	3afd                	addiw	s5,s5,-1
    5c76:	12e07053          	fmul.d	ft0,ft0,fa4
    5c7a:	a2d01ed3          	flt.d	t4,ft0,fa3
    5c7e:	040e8d63          	beqz	t4,5cd8 <fcvt+0x4b8>
    5c82:	22000453          	fmv.d	fs0,ft0
    5c86:	3afd                	addiw	s5,s5,-1
    5c88:	12e07053          	fmul.d	ft0,ft0,fa4
    5c8c:	a2d01f53          	flt.d	t5,ft0,fa3
    5c90:	040f0463          	beqz	t5,5cd8 <fcvt+0x4b8>
    5c94:	22000453          	fmv.d	fs0,ft0
    5c98:	3afd                	addiw	s5,s5,-1
    5c9a:	12e07053          	fmul.d	ft0,ft0,fa4
    5c9e:	a2d01fd3          	flt.d	t6,ft0,fa3
    5ca2:	020f8b63          	beqz	t6,5cd8 <fcvt+0x4b8>
    5ca6:	22000453          	fmv.d	fs0,ft0
    5caa:	3afd                	addiw	s5,s5,-1
    5cac:	12e07053          	fmul.d	ft0,ft0,fa4
    5cb0:	a2d017d3          	flt.d	a5,ft0,fa3
    5cb4:	c395                	beqz	a5,5cd8 <fcvt+0x4b8>
    5cb6:	22000453          	fmv.d	fs0,ft0
    5cba:	3afd                	addiw	s5,s5,-1
    5cbc:	12e07053          	fmul.d	ft0,ft0,fa4
    5cc0:	a2d016d3          	flt.d	a3,ft0,fa3
    5cc4:	ca91                	beqz	a3,5cd8 <fcvt+0x4b8>
    5cc6:	22000453          	fmv.d	fs0,ft0
    5cca:	3afd                	addiw	s5,s5,-1
    5ccc:	12e07053          	fmul.d	ft0,ft0,fa4
    5cd0:	a2d01553          	flt.d	a0,ft0,fa3
    5cd4:	fd25                	bnez	a0,5c4c <fcvt+0x42c>
    5cd6:	0001                	nop
    5cd8:	000412b7          	lui	t0,0x41
    5cdc:	a402                	fsd	ft0,8(sp)
    5cde:	85d6                	mv	a1,s5
    5ce0:	fd028413          	addi	s0,t0,-48 # 40fd0 <CVTBUF>
    5ce4:	992e                	add	s2,s2,a1
    5ce6:	9922                	add	s2,s2,s0
    5ce8:	0154a023          	sw	s5,0(s1)
    5cec:	02896063          	bltu	s2,s0,5d0c <fcvt+0x4ec>
    5cf0:	000419b7          	lui	s3,0x41
    5cf4:	8a22                	mv	s4,s0
    5cf6:	02098993          	addi	s3,s3,32 # 41020 <Loop_Num>
    5cfa:	bbb1                	j	5a56 <fcvt+0x236>
    5cfc:	4305                	li	t1,1
    5cfe:	22a51553          	fneg.d	fa0,fa0
    5d02:	00662023          	sw	t1,0(a2)
    5d06:	bea9                	j	5860 <fcvt+0x40>
    5d08:	29c2                	fld	fs3,16(sp)
    5d0a:	7b42                	ld	s6,48(sp)
    5d0c:	00040023          	sb	zero,0(s0)
    5d10:	bdd1                	j	5be4 <fcvt+0x3c4>
    5d12:	0001                	nop
    5d14:	040407a3          	sb	zero,79(s0)
    5d18:	b5f1                	j	5be4 <fcvt+0x3c4>
    5d1a:	0001                	nop
    5d1c:	00041637          	lui	a2,0x41
    5d20:	4581                	li	a1,0
    5d22:	4a81                	li	s5,0
    5d24:	fd060413          	addi	s0,a2,-48 # 40fd0 <CVTBUF>
    5d28:	bf75                	j	5ce4 <fcvt+0x4c4>
    5d2a:	29c2                	fld	fs3,16(sp)
    5d2c:	7b42                	ld	s6,48(sp)
    5d2e:	85d6                	mv	a1,s5
    5d30:	bf55                	j	5ce4 <fcvt+0x4c4>
    5d32:	000419b7          	lui	s3,0x41
    5d36:	a402                	fsd	ft0,8(sp)
    5d38:	4581                	li	a1,0
    5d3a:	fd098413          	addi	s0,s3,-48 # 40fd0 <CVTBUF>
    5d3e:	b75d                	j	5ce4 <fcvt+0x4c4>

0000000000005d40 <fcvtbuf>:
    5d40:	7159                	addi	sp,sp,-112
    5d42:	f20007d3          	fmv.d.x	fa5,zero
    5d46:	e4ce                	sd	s3,72(sp)
    5d48:	e8ca                	sd	s2,80(sp)
    5d4a:	0005091b          	sext.w	s2,a0
    5d4e:	04e00793          	li	a5,78
    5d52:	eca6                	sd	s1,88(sp)
    5d54:	f0a2                	sd	s0,96(sp)
    5d56:	a2f512d3          	flt.d	t0,fa0,fa5
    5d5a:	8436                	mv	s0,a3
    5d5c:	00092693          	slti	a3,s2,0
    5d60:	fc56                	sd	s5,56(sp)
    5d62:	e0d2                	sd	s4,64(sp)
    5d64:	42d0190b          	th.mvnez	s2,zero,a3
    5d68:	00a7a533          	slt	a0,a5,a0
    5d6c:	b422                	fsd	fs0,40(sp)
    5d6e:	b026                	fsd	fs1,32(sp)
    5d70:	ac4a                	fsd	fs2,24(sp)
    5d72:	f486                	sd	ra,104(sp)
    5d74:	84ae                	mv	s1,a1
    5d76:	42a7990b          	th.mvnez	s2,a5,a0
    5d7a:	64029763          	bnez	t0,63c8 <fcvtbuf+0x688>
    5d7e:	00062023          	sw	zero,0(a2)
    5d82:	850a                	mv	a0,sp
    5d84:	1d3090ef          	jal	f756 <modf>
    5d88:	2e02                	fld	ft8,0(sp)
    5d8a:	f2000953          	fmv.d.x	fs2,zero
    5d8e:	22a50453          	fmv.d	fs0,fa0
    5d92:	a32e23d3          	feq.d	t2,ft8,fs2
    5d96:	56039363          	bnez	t2,62fc <fcvtbuf+0x5bc>
    5d9a:	6545                	lui	a0,0x11
    5d9c:	62c5                	lui	t0,0x11
    5d9e:	a84e                	fsd	fs3,16(sp)
    5da0:	b8053487          	fld	fs1,-1152(a0) # 10b80 <errpat+0x38>
    5da4:	b882b987          	fld	fs3,-1144(t0) # 10b88 <errpat+0x40>
    5da8:	05040993          	addi	s3,s0,80
    5dac:	f85a                	sd	s6,48(sp)
    5dae:	4a81                	li	s5,0
    5db0:	8b4e                	mv	s6,s3
    5db2:	1a9e7553          	fdiv.d	fa0,ft8,fs1
    5db6:	850a                	mv	a0,sp
    5db8:	1b7d                	addi	s6,s6,-1
    5dba:	2a85                	addiw	s5,s5,1
    5dbc:	8a5a                	mv	s4,s6
    5dbe:	199090ef          	jal	f756 <modf>
    5dc2:	a42a                	fsd	fa0,8(sp)
    5dc4:	03357553          	fadd.d	fa0,fa0,fs3
    5dc8:	2102                	fld	ft2,0(sp)
    5dca:	86d6                	mv	a3,s5
    5dcc:	129570d3          	fmul.d	ft1,fa0,fs1
    5dd0:	a32125d3          	feq.d	a1,ft2,fs2
    5dd4:	c2009353          	fcvt.w.d	t1,ft1,rtz
    5dd8:	0303039b          	addiw	t2,t1,48
    5ddc:	0ff3f793          	zext.b	a5,t2
    5de0:	00fb0023          	sb	a5,0(s6)
    5de4:	edd9                	bnez	a1,5e82 <fcvtbuf+0x142>
    5de6:	1a917553          	fdiv.d	fa0,ft2,fs1
    5dea:	850a                	mv	a0,sp
    5dec:	2a85                	addiw	s5,s5,1
    5dee:	169090ef          	jal	f756 <modf>
    5df2:	033571d3          	fadd.d	ft3,fa0,fs3
    5df6:	2282                	fld	ft5,0(sp)
    5df8:	a42a                	fsd	fa0,8(sp)
    5dfa:	1291f253          	fmul.d	ft4,ft3,fs1
    5dfe:	a322a853          	feq.d	a6,ft5,fs2
    5e02:	86d6                	mv	a3,s5
    5e04:	c2021653          	fcvt.w.d	a2,ft4,rtz
    5e08:	0306071b          	addiw	a4,a2,48
    5e0c:	0ff77793          	zext.b	a5,a4
    5e10:	09fb578b          	th.sbib	a5,(s6),-1,0
    5e14:	06081763          	bnez	a6,5e82 <fcvtbuf+0x142>
    5e18:	1a92f553          	fdiv.d	fa0,ft5,fs1
    5e1c:	850a                	mv	a0,sp
    5e1e:	2a85                	addiw	s5,s5,1
    5e20:	ffea0b13          	addi	s6,s4,-2
    5e24:	133090ef          	jal	f756 <modf>
    5e28:	03357353          	fadd.d	ft6,fa0,fs3
    5e2c:	2582                	fld	fa1,0(sp)
    5e2e:	a42a                	fsd	fa0,8(sp)
    5e30:	129373d3          	fmul.d	ft7,ft6,fs1
    5e34:	a325aed3          	feq.d	t4,fa1,fs2
    5e38:	86d6                	mv	a3,s5
    5e3a:	c20398d3          	fcvt.w.d	a7,ft7,rtz
    5e3e:	03088e1b          	addiw	t3,a7,48
    5e42:	0ffe7793          	zext.b	a5,t3
    5e46:	fefa0f23          	sb	a5,-2(s4)
    5e4a:	020e9c63          	bnez	t4,5e82 <fcvtbuf+0x142>
    5e4e:	1a95f553          	fdiv.d	fa0,fa1,fs1
    5e52:	850a                	mv	a0,sp
    5e54:	2a85                	addiw	s5,s5,1
    5e56:	ffda0b13          	addi	s6,s4,-3
    5e5a:	0fd090ef          	jal	f756 <modf>
    5e5e:	03357853          	fadd.d	fa6,fa0,fs3
    5e62:	2e02                	fld	ft8,0(sp)
    5e64:	a42a                	fsd	fa0,8(sp)
    5e66:	129878d3          	fmul.d	fa7,fa6,fs1
    5e6a:	a32e2553          	feq.d	a0,ft8,fs2
    5e6e:	86d6                	mv	a3,s5
    5e70:	c2089f53          	fcvt.w.d	t5,fa7,rtz
    5e74:	030f0f9b          	addiw	t6,t5,48
    5e78:	0ffff793          	zext.b	a5,t6
    5e7c:	fefa0ea3          	sb	a5,-3(s4)
    5e80:	d90d                	beqz	a0,5db2 <fcvtbuf+0x72>
    5e82:	573b7663          	bgeu	s6,s3,63ee <fcvtbuf+0x6ae>
    5e86:	416402b3          	sub	t0,s0,s6
    5e8a:	04f28313          	addi	t1,t0,79
    5e8e:	00737393          	andi	t2,t1,7
    5e92:	05028a13          	addi	s4,t0,80
    5e96:	4701                	li	a4,0
    5e98:	0c038763          	beqz	t2,5f66 <fcvtbuf+0x226>
    5e9c:	00f40023          	sb	a5,0(s0)
    5ea0:	4705                	li	a4,1
    5ea2:	80eb478b          	th.lrbu	a5,s6,a4,0
    5ea6:	0ce38063          	beq	t2,a4,5f66 <fcvtbuf+0x226>
    5eaa:	4589                	li	a1,2
    5eac:	04b38763          	beq	t2,a1,5efa <fcvtbuf+0x1ba>
    5eb0:	460d                	li	a2,3
    5eb2:	02c38f63          	beq	t2,a2,5ef0 <fcvtbuf+0x1b0>
    5eb6:	4811                	li	a6,4
    5eb8:	03038763          	beq	t2,a6,5ee6 <fcvtbuf+0x1a6>
    5ebc:	4895                	li	a7,5
    5ebe:	01138f63          	beq	t2,a7,5edc <fcvtbuf+0x19c>
    5ec2:	4e19                	li	t3,6
    5ec4:	01c38763          	beq	t2,t3,5ed2 <fcvtbuf+0x192>
    5ec8:	00e4578b          	th.srb	a5,s0,a4,0
    5ecc:	80bb478b          	th.lrbu	a5,s6,a1,0
    5ed0:	872e                	mv	a4,a1
    5ed2:	00e4578b          	th.srb	a5,s0,a4,0
    5ed6:	0705                	addi	a4,a4,1
    5ed8:	80eb478b          	th.lrbu	a5,s6,a4,0
    5edc:	00e4578b          	th.srb	a5,s0,a4,0
    5ee0:	0705                	addi	a4,a4,1
    5ee2:	80eb478b          	th.lrbu	a5,s6,a4,0
    5ee6:	00e4578b          	th.srb	a5,s0,a4,0
    5eea:	0705                	addi	a4,a4,1
    5eec:	80eb478b          	th.lrbu	a5,s6,a4,0
    5ef0:	00e4578b          	th.srb	a5,s0,a4,0
    5ef4:	0705                	addi	a4,a4,1
    5ef6:	80eb478b          	th.lrbu	a5,s6,a4,0
    5efa:	00e4578b          	th.srb	a5,s0,a4,0
    5efe:	0705                	addi	a4,a4,1
    5f00:	80eb478b          	th.lrbu	a5,s6,a4,0
    5f04:	00170e93          	addi	t4,a4,1
    5f08:	00e4578b          	th.srb	a5,s0,a4,0
    5f0c:	074e8363          	beq	t4,s4,5f72 <fcvtbuf+0x232>
    5f10:	81db488b          	th.lrbu	a7,s6,t4,0
    5f14:	00270593          	addi	a1,a4,2
    5f18:	00370293          	addi	t0,a4,3
    5f1c:	01d4588b          	th.srb	a7,s0,t4,0
    5f20:	80bb460b          	th.lrbu	a2,s6,a1,0
    5f24:	00470393          	addi	t2,a4,4
    5f28:	00570e13          	addi	t3,a4,5
    5f2c:	00b4560b          	th.srb	a2,s0,a1,0
    5f30:	805b430b          	th.lrbu	t1,s6,t0,0
    5f34:	00670f13          	addi	t5,a4,6
    5f38:	00770513          	addi	a0,a4,7
    5f3c:	0054530b          	th.srb	t1,s0,t0,0
    5f40:	807b480b          	th.lrbu	a6,s6,t2,0
    5f44:	0721                	addi	a4,a4,8
    5f46:	0074580b          	th.srb	a6,s0,t2,0
    5f4a:	81cb4e8b          	th.lrbu	t4,s6,t3,0
    5f4e:	01c45e8b          	th.srb	t4,s0,t3,0
    5f52:	81eb4f8b          	th.lrbu	t6,s6,t5,0
    5f56:	01e45f8b          	th.srb	t6,s0,t5,0
    5f5a:	80ab478b          	th.lrbu	a5,s6,a0,0
    5f5e:	00a4578b          	th.srb	a5,s0,a0,0
    5f62:	80eb478b          	th.lrbu	a5,s6,a4,0
    5f66:	00e4578b          	th.srb	a5,s0,a4,0
    5f6a:	00170e93          	addi	t4,a4,1
    5f6e:	fb4e91e3          	bne	t4,s4,5f10 <fcvtbuf+0x1d0>
    5f72:	9aca                	add	s5,s5,s2
    5f74:	01540933          	add	s2,s0,s5
    5f78:	c094                	sw	a3,0(s1)
    5f7a:	44896d63          	bltu	s2,s0,63d4 <fcvtbuf+0x694>
    5f7e:	9a22                	add	s4,s4,s0
    5f80:	29c2                	fld	fs3,16(sp)
    5f82:	7b42                	ld	s6,48(sp)
    5f84:	11496a63          	bltu	s2,s4,6098 <fcvtbuf+0x358>
    5f88:	41498fb3          	sub	t6,s3,s4
    5f8c:	6f45                	lui	t5,0x11
    5f8e:	003ffa93          	andi	s5,t6,3
    5f92:	b80f3907          	fld	fs2,-1152(t5) # 10b80 <errpat+0x38>
    5f96:	060a8d63          	beqz	s5,6010 <fcvtbuf+0x2d0>
    5f9a:	0f3a7f63          	bgeu	s4,s3,6098 <fcvtbuf+0x358>
    5f9e:	13247553          	fmul.d	fa0,fs0,fs2
    5fa2:	0028                	addi	a0,sp,8
    5fa4:	7b2090ef          	jal	f756 <modf>
    5fa8:	2ea2                	fld	ft9,8(sp)
    5faa:	22a50453          	fmv.d	fs0,fa0
    5fae:	c20e97d3          	fcvt.w.d	a5,ft9,rtz
    5fb2:	0307869b          	addiw	a3,a5,48
    5fb6:	181a568b          	th.sbia	a3,(s4),1,0
    5fba:	0d496f63          	bltu	s2,s4,6098 <fcvtbuf+0x358>
    5fbe:	4505                	li	a0,1
    5fc0:	04aa8863          	beq	s5,a0,6010 <fcvtbuf+0x2d0>
    5fc4:	4289                	li	t0,2
    5fc6:	025a8263          	beq	s5,t0,5fea <fcvtbuf+0x2aa>
    5fca:	13257553          	fmul.d	fa0,fa0,fs2
    5fce:	0028                	addi	a0,sp,8
    5fd0:	786090ef          	jal	f756 <modf>
    5fd4:	2f22                	fld	ft10,8(sp)
    5fd6:	22a50453          	fmv.d	fs0,fa0
    5fda:	c20f1353          	fcvt.w.d	t1,ft10,rtz
    5fde:	0303039b          	addiw	t2,t1,48
    5fe2:	181a538b          	th.sbia	t2,(s4),1,0
    5fe6:	0b496963          	bltu	s2,s4,6098 <fcvtbuf+0x358>
    5fea:	13247553          	fmul.d	fa0,fs0,fs2
    5fee:	0028                	addi	a0,sp,8
    5ff0:	766090ef          	jal	f756 <modf>
    5ff4:	2fa2                	fld	ft11,8(sp)
    5ff6:	22a50453          	fmv.d	fs0,fa0
    5ffa:	c20f95d3          	fcvt.w.d	a1,ft11,rtz
    5ffe:	0305861b          	addiw	a2,a1,48
    6002:	181a560b          	th.sbia	a2,(s4),1,0
    6006:	09496963          	bltu	s2,s4,6098 <fcvtbuf+0x358>
    600a:	0001                	nop
    600c:	00000013          	nop
    6010:	093a7463          	bgeu	s4,s3,6098 <fcvtbuf+0x358>
    6014:	13247553          	fmul.d	fa0,fs0,fs2
    6018:	0028                	addi	a0,sp,8
    601a:	73c090ef          	jal	f756 <modf>
    601e:	27a2                	fld	fa5,8(sp)
    6020:	8852                	mv	a6,s4
    6022:	c20798d3          	fcvt.w.d	a7,fa5,rtz
    6026:	03088e1b          	addiw	t3,a7,48
    602a:	18185e0b          	th.sbia	t3,(a6),1,0
    602e:	07096563          	bltu	s2,a6,6098 <fcvtbuf+0x358>
    6032:	13257553          	fmul.d	fa0,fa0,fs2
    6036:	0028                	addi	a0,sp,8
    6038:	71e090ef          	jal	f756 <modf>
    603c:	2722                	fld	fa4,8(sp)
    603e:	002a0e93          	addi	t4,s4,2
    6042:	c2071753          	fcvt.w.d	a4,fa4,rtz
    6046:	03070f1b          	addiw	t5,a4,48
    604a:	01ea00a3          	sb	t5,1(s4)
    604e:	05d96563          	bltu	s2,t4,6098 <fcvtbuf+0x358>
    6052:	13257553          	fmul.d	fa0,fa0,fs2
    6056:	0028                	addi	a0,sp,8
    6058:	6fe090ef          	jal	f756 <modf>
    605c:	2622                	fld	fa2,8(sp)
    605e:	003a0f93          	addi	t6,s4,3
    6062:	c2061ad3          	fcvt.w.d	s5,fa2,rtz
    6066:	030a879b          	addiw	a5,s5,48
    606a:	00fa0123          	sb	a5,2(s4)
    606e:	03f96563          	bltu	s2,t6,6098 <fcvtbuf+0x358>
    6072:	13257553          	fmul.d	fa0,fa0,fs2
    6076:	0028                	addi	a0,sp,8
    6078:	0a11                	addi	s4,s4,4
    607a:	6dc090ef          	jal	f756 <modf>
    607e:	26a2                	fld	fa3,8(sp)
    6080:	22a50453          	fmv.d	fs0,fa0
    6084:	c20696d3          	fcvt.w.d	a3,fa3,rtz
    6088:	0306851b          	addiw	a0,a3,48
    608c:	feaa0fa3          	sb	a0,-1(s4)
    6090:	f94970e3          	bgeu	s2,s4,6010 <fcvtbuf+0x2d0>
    6094:	00000013          	nop
    6098:	35397463          	bgeu	s2,s3,63e0 <fcvtbuf+0x6a0>
    609c:	00094983          	lbu	s3,0(s2)
    60a0:	03900393          	li	t2,57
    60a4:	0059829b          	addiw	t0,s3,5
    60a8:	0ff2f313          	zext.b	t1,t0
    60ac:	00690023          	sb	t1,0(s2)
    60b0:	0663f863          	bgeu	t2,t1,6120 <fcvtbuf+0x3e0>
    60b4:	40890833          	sub	a6,s2,s0
    60b8:	03000593          	li	a1,48
    60bc:	00787e13          	andi	t3,a6,7
    60c0:	87ca                	mv	a5,s2
    60c2:	88ae                	mv	a7,a1
    60c4:	861e                	mv	a2,t2
    60c6:	160e0163          	beqz	t3,6228 <fcvtbuf+0x4e8>
    60ca:	07246b63          	bltu	s0,s2,6140 <fcvtbuf+0x400>
    60ce:	03100893          	li	a7,49
    60d2:	01178023          	sb	a7,0(a5)
    60d6:	4090                	lw	a2,0(s1)
    60d8:	00160a1b          	addiw	s4,a2,1
    60dc:	0144a023          	sw	s4,0(s1)
    60e0:	01247463          	bgeu	s0,s2,60e8 <fcvtbuf+0x3a8>
    60e4:	00b90023          	sb	a1,0(s2)
    60e8:	0007c583          	lbu	a1,0(a5)
    60ec:	03900693          	li	a3,57
    60f0:	0905                	addi	s2,s2,1
    60f2:	02b6f763          	bgeu	a3,a1,6120 <fcvtbuf+0x3e0>
    60f6:	03100513          	li	a0,49
    60fa:	03000993          	li	s3,48
    60fe:	00a78023          	sb	a0,0(a5)
    6102:	0004a283          	lw	t0,0(s1)
    6106:	0012831b          	addiw	t1,t0,1
    610a:	0064a023          	sw	t1,0(s1)
    610e:	1f247163          	bgeu	s0,s2,62f0 <fcvtbuf+0x5b0>
    6112:	1819598b          	th.sbia	s3,(s2),1,0
    6116:	0007c803          	lbu	a6,0(a5)
    611a:	ff06e2e3          	bltu	a3,a6,60fe <fcvtbuf+0x3be>
    611e:	0001                	nop
    6120:	00090023          	sb	zero,0(s2)
    6124:	70a6                	ld	ra,104(sp)
    6126:	8522                	mv	a0,s0
    6128:	64e6                	ld	s1,88(sp)
    612a:	7406                	ld	s0,96(sp)
    612c:	7ae2                	ld	s5,56(sp)
    612e:	6a06                	ld	s4,64(sp)
    6130:	69a6                	ld	s3,72(sp)
    6132:	6946                	ld	s2,80(sp)
    6134:	3422                	fld	fs0,40(sp)
    6136:	3482                	fld	fs1,32(sp)
    6138:	2962                	fld	fs2,24(sp)
    613a:	6165                	addi	sp,sp,112
    613c:	8082                	ret
    613e:	0001                	nop
    6140:	8eca                	mv	t4,s2
    6142:	19fed58b          	th.sbia	a1,(t4),-1,0
    6146:	fff94703          	lbu	a4,-1(s2)
    614a:	00170f1b          	addiw	t5,a4,1
    614e:	0fff7f93          	zext.b	t6,t5
    6152:	fff90fa3          	sb	t6,-1(s2)
    6156:	fdf3f5e3          	bgeu	t2,t6,6120 <fcvtbuf+0x3e0>
    615a:	4a85                	li	s5,1
    615c:	87f6                	mv	a5,t4
    615e:	0d5e0563          	beq	t3,s5,6228 <fcvtbuf+0x4e8>
    6162:	4a09                	li	s4,2
    6164:	0b4e0263          	beq	t3,s4,6208 <fcvtbuf+0x4c8>
    6168:	468d                	li	a3,3
    616a:	08de0163          	beq	t3,a3,61ec <fcvtbuf+0x4ac>
    616e:	4511                	li	a0,4
    6170:	06ae0063          	beq	t3,a0,61d0 <fcvtbuf+0x490>
    6174:	4995                	li	s3,5
    6176:	033e0f63          	beq	t3,s3,61b4 <fcvtbuf+0x474>
    617a:	4299                	li	t0,6
    617c:	005e0e63          	beq	t3,t0,6198 <fcvtbuf+0x458>
    6180:	19f7d58b          	th.sbia	a1,(a5),-1,0
    6184:	fffec303          	lbu	t1,-1(t4)
    6188:	0013039b          	addiw	t2,t1,1
    618c:	0ff3f813          	zext.b	a6,t2
    6190:	ff0e8fa3          	sb	a6,-1(t4)
    6194:	f90676e3          	bgeu	a2,a6,6120 <fcvtbuf+0x3e0>
    6198:	8e3e                	mv	t3,a5
    619a:	19fe588b          	th.sbia	a7,(t3),-1,0
    619e:	fff7ce83          	lbu	t4,-1(a5)
    61a2:	001e871b          	addiw	a4,t4,1
    61a6:	0ff77f13          	zext.b	t5,a4
    61aa:	ffe78fa3          	sb	t5,-1(a5)
    61ae:	f7e679e3          	bgeu	a2,t5,6120 <fcvtbuf+0x3e0>
    61b2:	87f2                	mv	a5,t3
    61b4:	8fbe                	mv	t6,a5
    61b6:	19ffd88b          	th.sbia	a7,(t6),-1,0
    61ba:	fff7ca83          	lbu	s5,-1(a5)
    61be:	001a8a1b          	addiw	s4,s5,1
    61c2:	0ffa7693          	zext.b	a3,s4
    61c6:	fed78fa3          	sb	a3,-1(a5)
    61ca:	f4d67be3          	bgeu	a2,a3,6120 <fcvtbuf+0x3e0>
    61ce:	87fe                	mv	a5,t6
    61d0:	853e                	mv	a0,a5
    61d2:	19f5588b          	th.sbia	a7,(a0),-1,0
    61d6:	fff7c983          	lbu	s3,-1(a5)
    61da:	0019829b          	addiw	t0,s3,1
    61de:	0ff2f313          	zext.b	t1,t0
    61e2:	fe678fa3          	sb	t1,-1(a5)
    61e6:	f2667de3          	bgeu	a2,t1,6120 <fcvtbuf+0x3e0>
    61ea:	87aa                	mv	a5,a0
    61ec:	83be                	mv	t2,a5
    61ee:	19f3d88b          	th.sbia	a7,(t2),-1,0
    61f2:	fff7c803          	lbu	a6,-1(a5)
    61f6:	00180e1b          	addiw	t3,a6,1
    61fa:	0ffe7e93          	zext.b	t4,t3
    61fe:	ffd78fa3          	sb	t4,-1(a5)
    6202:	f1d67fe3          	bgeu	a2,t4,6120 <fcvtbuf+0x3e0>
    6206:	879e                	mv	a5,t2
    6208:	8f3e                	mv	t5,a5
    620a:	19ff588b          	th.sbia	a7,(t5),-1,0
    620e:	fff7c703          	lbu	a4,-1(a5)
    6212:	00170f9b          	addiw	t6,a4,1
    6216:	0ffffa93          	zext.b	s5,t6
    621a:	ff578fa3          	sb	s5,-1(a5)
    621e:	87fa                	mv	a5,t5
    6220:	f15670e3          	bgeu	a2,s5,6120 <fcvtbuf+0x3e0>
    6224:	00000013          	nop
    6228:	eaf473e3          	bgeu	s0,a5,60ce <fcvtbuf+0x38e>
    622c:	fff7ce03          	lbu	t3,-1(a5)
    6230:	01178023          	sb	a7,0(a5)
    6234:	001e0e9b          	addiw	t4,t3,1
    6238:	0ffeff13          	zext.b	t5,t4
    623c:	ffe78fa3          	sb	t5,-1(a5)
    6240:	efe670e3          	bgeu	a2,t5,6120 <fcvtbuf+0x3e0>
    6244:	ffe7c703          	lbu	a4,-2(a5)
    6248:	ff178fa3          	sb	a7,-1(a5)
    624c:	00170f9b          	addiw	t6,a4,1
    6250:	0ffffa93          	zext.b	s5,t6
    6254:	ff578f23          	sb	s5,-2(a5)
    6258:	ed5674e3          	bgeu	a2,s5,6120 <fcvtbuf+0x3e0>
    625c:	ffd7ca03          	lbu	s4,-3(a5)
    6260:	ff178f23          	sb	a7,-2(a5)
    6264:	001a069b          	addiw	a3,s4,1
    6268:	0ff6f513          	zext.b	a0,a3
    626c:	fea78ea3          	sb	a0,-3(a5)
    6270:	eaa678e3          	bgeu	a2,a0,6120 <fcvtbuf+0x3e0>
    6274:	ffc7c983          	lbu	s3,-4(a5)
    6278:	ff178ea3          	sb	a7,-3(a5)
    627c:	0019829b          	addiw	t0,s3,1
    6280:	0ff2f313          	zext.b	t1,t0
    6284:	fe678e23          	sb	t1,-4(a5)
    6288:	e8667ce3          	bgeu	a2,t1,6120 <fcvtbuf+0x3e0>
    628c:	ffb7c383          	lbu	t2,-5(a5)
    6290:	ff178e23          	sb	a7,-4(a5)
    6294:	0013881b          	addiw	a6,t2,1
    6298:	0ff87e13          	zext.b	t3,a6
    629c:	ffc78da3          	sb	t3,-5(a5)
    62a0:	e9c670e3          	bgeu	a2,t3,6120 <fcvtbuf+0x3e0>
    62a4:	ffa7ce83          	lbu	t4,-6(a5)
    62a8:	ff178da3          	sb	a7,-5(a5)
    62ac:	001e8f1b          	addiw	t5,t4,1
    62b0:	0fff7713          	zext.b	a4,t5
    62b4:	fee78d23          	sb	a4,-6(a5)
    62b8:	e6e674e3          	bgeu	a2,a4,6120 <fcvtbuf+0x3e0>
    62bc:	ff97cf83          	lbu	t6,-7(a5)
    62c0:	ff178d23          	sb	a7,-6(a5)
    62c4:	001f8a9b          	addiw	s5,t6,1
    62c8:	0ffafa13          	zext.b	s4,s5
    62cc:	ff478ca3          	sb	s4,-7(a5)
    62d0:	e54678e3          	bgeu	a2,s4,6120 <fcvtbuf+0x3e0>
    62d4:	ff87c683          	lbu	a3,-8(a5)
    62d8:	ff178ca3          	sb	a7,-7(a5)
    62dc:	0016851b          	addiw	a0,a3,1
    62e0:	0ff57993          	zext.b	s3,a0
    62e4:	ff378c23          	sb	s3,-8(a5)
    62e8:	e3367ce3          	bgeu	a2,s3,6120 <fcvtbuf+0x3e0>
    62ec:	17e1                	addi	a5,a5,-8
    62ee:	bf2d                	j	6228 <fcvtbuf+0x4e8>
    62f0:	0007c383          	lbu	t2,0(a5)
    62f4:	0905                	addi	s2,s2,1
    62f6:	e076e4e3          	bltu	a3,t2,60fe <fcvtbuf+0x3be>
    62fa:	b51d                	j	6120 <fcvtbuf+0x3e0>
    62fc:	a2a915d3          	flt.d	a1,fs2,fa0
    6300:	c5e5                	beqz	a1,63e8 <fcvtbuf+0x6a8>
    6302:	6745                	lui	a4,0x11
    6304:	b8073707          	fld	fa4,-1152(a4) # 10b80 <errpat+0x38>
    6308:	6845                	lui	a6,0x11
    630a:	b9083607          	fld	fa2,-1136(a6) # 10b90 <errpat+0x48>
    630e:	12e57053          	fmul.d	ft0,fa0,fa4
    6312:	4a81                	li	s5,0
    6314:	22c606d3          	fmv.d	fa3,fa2
    6318:	a2c018d3          	flt.d	a7,ft0,fa2
    631c:	0c088d63          	beqz	a7,63f6 <fcvtbuf+0x6b6>
    6320:	22000453          	fmv.d	fs0,ft0
    6324:	3afd                	addiw	s5,s5,-1
    6326:	12e07053          	fmul.d	ft0,ft0,fa4
    632a:	a2d019d3          	flt.d	s3,ft0,fa3
    632e:	08098163          	beqz	s3,63b0 <fcvtbuf+0x670>
    6332:	22000453          	fmv.d	fs0,ft0
    6336:	3afd                	addiw	s5,s5,-1
    6338:	12e07053          	fmul.d	ft0,ft0,fa4
    633c:	a2d01a53          	flt.d	s4,ft0,fa3
    6340:	060a0863          	beqz	s4,63b0 <fcvtbuf+0x670>
    6344:	22000453          	fmv.d	fs0,ft0
    6348:	3afd                	addiw	s5,s5,-1
    634a:	12e07053          	fmul.d	ft0,ft0,fa4
    634e:	a2d01e53          	flt.d	t3,ft0,fa3
    6352:	040e0f63          	beqz	t3,63b0 <fcvtbuf+0x670>
    6356:	22000453          	fmv.d	fs0,ft0
    635a:	3afd                	addiw	s5,s5,-1
    635c:	12e07053          	fmul.d	ft0,ft0,fa4
    6360:	a2d01ed3          	flt.d	t4,ft0,fa3
    6364:	040e8663          	beqz	t4,63b0 <fcvtbuf+0x670>
    6368:	22000453          	fmv.d	fs0,ft0
    636c:	3afd                	addiw	s5,s5,-1
    636e:	12e07053          	fmul.d	ft0,ft0,fa4
    6372:	a2d01f53          	flt.d	t5,ft0,fa3
    6376:	020f0d63          	beqz	t5,63b0 <fcvtbuf+0x670>
    637a:	22000453          	fmv.d	fs0,ft0
    637e:	3afd                	addiw	s5,s5,-1
    6380:	12e07053          	fmul.d	ft0,ft0,fa4
    6384:	a2d01fd3          	flt.d	t6,ft0,fa3
    6388:	020f8463          	beqz	t6,63b0 <fcvtbuf+0x670>
    638c:	22000453          	fmv.d	fs0,ft0
    6390:	3afd                	addiw	s5,s5,-1
    6392:	12e07053          	fmul.d	ft0,ft0,fa4
    6396:	a2d017d3          	flt.d	a5,ft0,fa3
    639a:	cb99                	beqz	a5,63b0 <fcvtbuf+0x670>
    639c:	22000453          	fmv.d	fs0,ft0
    63a0:	3afd                	addiw	s5,s5,-1
    63a2:	12e07053          	fmul.d	ft0,ft0,fa4
    63a6:	a2d016d3          	flt.d	a3,ft0,fa3
    63aa:	fabd                	bnez	a3,6320 <fcvtbuf+0x5e0>
    63ac:	00000013          	nop
    63b0:	a402                	fsd	ft0,8(sp)
    63b2:	8656                	mv	a2,s5
    63b4:	9932                	add	s2,s2,a2
    63b6:	9922                	add	s2,s2,s0
    63b8:	0154a023          	sw	s5,0(s1)
    63bc:	00896e63          	bltu	s2,s0,63d8 <fcvtbuf+0x698>
    63c0:	8a22                	mv	s4,s0
    63c2:	05040993          	addi	s3,s0,80
    63c6:	b6c9                	j	5f88 <fcvtbuf+0x248>
    63c8:	4305                	li	t1,1
    63ca:	22a51553          	fneg.d	fa0,fa0
    63ce:	00662023          	sw	t1,0(a2)
    63d2:	ba45                	j	5d82 <fcvtbuf+0x42>
    63d4:	29c2                	fld	fs3,16(sp)
    63d6:	7b42                	ld	s6,48(sp)
    63d8:	00040023          	sb	zero,0(s0)
    63dc:	b3a1                	j	6124 <fcvtbuf+0x3e4>
    63de:	0001                	nop
    63e0:	040407a3          	sb	zero,79(s0)
    63e4:	b381                	j	6124 <fcvtbuf+0x3e4>
    63e6:	0001                	nop
    63e8:	4601                	li	a2,0
    63ea:	4a81                	li	s5,0
    63ec:	b7e1                	j	63b4 <fcvtbuf+0x674>
    63ee:	29c2                	fld	fs3,16(sp)
    63f0:	7b42                	ld	s6,48(sp)
    63f2:	8656                	mv	a2,s5
    63f4:	b7c1                	j	63b4 <fcvtbuf+0x674>
    63f6:	a402                	fsd	ft0,8(sp)
    63f8:	4601                	li	a2,0
    63fa:	bf6d                	j	63b4 <fcvtbuf+0x674>
	...

0000000000006410 <fputc>:
    6410:	020007b7          	lui	a5,0x2000
    6414:	fea7a823          	sw	a0,-16(a5) # 1fffff0 <__kernel_stack+0x1f11ff0>
    6418:	8082                	ret
    641a:	00000013          	nop
    641e:	0001                	nop

0000000000006420 <os_critical_enter>:
    6420:	8082                	ret
    6422:	0001                	nop
    6424:	00000013          	nop
    6428:	00000013          	nop
    642c:	00000013          	nop

0000000000006430 <os_critical_exit>:
    6430:	8082                	ret
	...

0000000000006440 <CK_Timer_Interruptservice>:
    6440:	00041337          	lui	t1,0x41
    6444:	02030393          	addi	t2,t1,32 # 41020 <Loop_Num>
    6448:	0003a703          	lw	a4,0(t2)
    644c:	100117b7          	lui	a5,0x10011
    6450:	00c7a283          	lw	t0,12(a5) # 1001100c <__kernel_stack+0xff2300c>
    6454:	1141                	addi	sp,sp,-16
    6456:	0017051b          	addiw	a0,a4,1
    645a:	c616                	sw	t0,12(sp)
    645c:	00a3a023          	sw	a0,0(t2)
    6460:	0141                	addi	sp,sp,16
    6462:	8082                	ret
    6464:	00000013          	nop
    6468:	00000013          	nop
    646c:	00000013          	nop

0000000000006470 <Timer_Interrupt_Init>:
    6470:	8082                	ret
    6472:	0001                	nop
    6474:	00000013          	nop
    6478:	00000013          	nop
    647c:	00000013          	nop

0000000000006480 <iterate>:
    6480:	7179                	addi	sp,sp,-48
    6482:	e44e                	sd	s3,8(sp)
    6484:	e84a                	sd	s2,16(sp)
    6486:	fc11540b          	th.sdd	s0,ra,(sp),2,4
    648a:	02c52983          	lw	s3,44(a0)
    648e:	00041937          	lui	s2,0x41
    6492:	06053023          	sd	zero,96(a0)
    6496:	842a                	mv	s0,a0
    6498:	02090913          	addi	s2,s2,32 # 41020 <Loop_Num>
    649c:	294090ef          	jal	f730 <get_vtimer>
    64a0:	00a92223          	sw	a0,4(s2)
    64a4:	14098b63          	beqz	s3,65fa <iterate+0x17a>
    64a8:	4585                	li	a1,1
    64aa:	8522                	mv	a0,s0
    64ac:	ec26                	sd	s1,24(sp)
    64ae:	cb2fa0ef          	jal	960 <core_bench_list>
    64b2:	06045583          	lhu	a1,96(s0)
    64b6:	4485                	li	s1,1
    64b8:	e29fd0ef          	jal	42e0 <crcu16>
    64bc:	06a41023          	sh	a0,96(s0)
    64c0:	55fd                	li	a1,-1
    64c2:	8522                	mv	a0,s0
    64c4:	c9cfa0ef          	jal	960 <core_bench_list>
    64c8:	06045583          	lhu	a1,96(s0)
    64cc:	e15fd0ef          	jal	42e0 <crcu16>
    64d0:	06a41023          	sh	a0,96(s0)
    64d4:	06a41123          	sh	a0,98(s0)
    64d8:	12998063          	beq	s3,s1,65f8 <iterate+0x178>
    64dc:	409987b3          	sub	a5,s3,s1
    64e0:	0037f293          	andi	t0,a5,3
    64e4:	08028a63          	beqz	t0,6578 <iterate+0xf8>
    64e8:	06928163          	beq	t0,s1,654a <iterate+0xca>
    64ec:	e052                	sd	s4,0(sp)
    64ee:	4a09                	li	s4,2
    64f0:	03428763          	beq	t0,s4,651e <iterate+0x9e>
    64f4:	85a6                	mv	a1,s1
    64f6:	8522                	mv	a0,s0
    64f8:	c68fa0ef          	jal	960 <core_bench_list>
    64fc:	06045583          	lhu	a1,96(s0)
    6500:	84d2                	mv	s1,s4
    6502:	ddffd0ef          	jal	42e0 <crcu16>
    6506:	06a41023          	sh	a0,96(s0)
    650a:	55fd                	li	a1,-1
    650c:	8522                	mv	a0,s0
    650e:	c52fa0ef          	jal	960 <core_bench_list>
    6512:	06045583          	lhu	a1,96(s0)
    6516:	dcbfd0ef          	jal	42e0 <crcu16>
    651a:	06a41023          	sh	a0,96(s0)
    651e:	4585                	li	a1,1
    6520:	8522                	mv	a0,s0
    6522:	c3efa0ef          	jal	960 <core_bench_list>
    6526:	06045583          	lhu	a1,96(s0)
    652a:	2485                	addiw	s1,s1,1
    652c:	db5fd0ef          	jal	42e0 <crcu16>
    6530:	06a41023          	sh	a0,96(s0)
    6534:	55fd                	li	a1,-1
    6536:	8522                	mv	a0,s0
    6538:	c28fa0ef          	jal	960 <core_bench_list>
    653c:	06045583          	lhu	a1,96(s0)
    6540:	da1fd0ef          	jal	42e0 <crcu16>
    6544:	6a02                	ld	s4,0(sp)
    6546:	06a41023          	sh	a0,96(s0)
    654a:	4585                	li	a1,1
    654c:	8522                	mv	a0,s0
    654e:	c12fa0ef          	jal	960 <core_bench_list>
    6552:	06045583          	lhu	a1,96(s0)
    6556:	2485                	addiw	s1,s1,1
    6558:	d89fd0ef          	jal	42e0 <crcu16>
    655c:	06a41023          	sh	a0,96(s0)
    6560:	55fd                	li	a1,-1
    6562:	8522                	mv	a0,s0
    6564:	bfcfa0ef          	jal	960 <core_bench_list>
    6568:	06045583          	lhu	a1,96(s0)
    656c:	d75fd0ef          	jal	42e0 <crcu16>
    6570:	06a41023          	sh	a0,96(s0)
    6574:	08998263          	beq	s3,s1,65f8 <iterate+0x178>
    6578:	4585                	li	a1,1
    657a:	8522                	mv	a0,s0
    657c:	be4fa0ef          	jal	960 <core_bench_list>
    6580:	06045583          	lhu	a1,96(s0)
    6584:	2485                	addiw	s1,s1,1
    6586:	2485                	addiw	s1,s1,1
    6588:	d59fd0ef          	jal	42e0 <crcu16>
    658c:	06a41023          	sh	a0,96(s0)
    6590:	55fd                	li	a1,-1
    6592:	8522                	mv	a0,s0
    6594:	bccfa0ef          	jal	960 <core_bench_list>
    6598:	06045583          	lhu	a1,96(s0)
    659c:	2485                	addiw	s1,s1,1
    659e:	d43fd0ef          	jal	42e0 <crcu16>
    65a2:	06a41023          	sh	a0,96(s0)
    65a6:	4585                	li	a1,1
    65a8:	8522                	mv	a0,s0
    65aa:	bb6fa0ef          	jal	960 <core_bench_list>
    65ae:	06045583          	lhu	a1,96(s0)
    65b2:	d2ffd0ef          	jal	42e0 <crcu16>
    65b6:	06a41023          	sh	a0,96(s0)
    65ba:	55fd                	li	a1,-1
    65bc:	8522                	mv	a0,s0
    65be:	ba2fa0ef          	jal	960 <core_bench_list>
    65c2:	06045583          	lhu	a1,96(s0)
    65c6:	d1bfd0ef          	jal	42e0 <crcu16>
    65ca:	06a41023          	sh	a0,96(s0)
    65ce:	4585                	li	a1,1
    65d0:	8522                	mv	a0,s0
    65d2:	b8efa0ef          	jal	960 <core_bench_list>
    65d6:	06045583          	lhu	a1,96(s0)
    65da:	d07fd0ef          	jal	42e0 <crcu16>
    65de:	06a41023          	sh	a0,96(s0)
    65e2:	55fd                	li	a1,-1
    65e4:	8522                	mv	a0,s0
    65e6:	b7afa0ef          	jal	960 <core_bench_list>
    65ea:	06045583          	lhu	a1,96(s0)
    65ee:	cf3fd0ef          	jal	42e0 <crcu16>
    65f2:	06a41023          	sh	a0,96(s0)
    65f6:	bf91                	j	654a <iterate+0xca>
    65f8:	64e2                	ld	s1,24(sp)
    65fa:	136090ef          	jal	f730 <get_vtimer>
    65fe:	00492303          	lw	t1,4(s2)
    6602:	85ce                	mv	a1,s3
    6604:	4065063b          	subw	a2,a0,t1
    6608:	0336563b          	divuw	a2,a2,s3
    660c:	e2c9550b          	th.swd	a0,a2,(s2),1,3
    6610:	6541                	lui	a0,0x10
    6612:	61850513          	addi	a0,a0,1560 # 10618 <__errno+0xec>
    6616:	2cb080ef          	jal	f0e0 <printf>
    661a:	00c92583          	lw	a1,12(s2)
    661e:	66c5                	lui	a3,0x11
    6620:	c206a787          	flw	fa5,-992(a3) # 10c20 <errpat+0xd8>
    6624:	d005f753          	fcvt.s.w	fa4,a1
    6628:	63c1                	lui	t2,0x10
    662a:	18e7f053          	fdiv.s	ft0,fa5,fa4
    662e:	66038513          	addi	a0,t2,1632 # 10660 <__errno+0x134>
    6632:	420000d3          	fcvt.d.s	ft1,ft0
    6636:	e20085d3          	fmv.x.d	a1,ft1
    663a:	2a7080ef          	jal	f0e0 <printf>
    663e:	102090ef          	jal	f740 <sim_end>
    6642:	fc11440b          	th.ldd	s0,ra,(sp),2,4
    6646:	69a2                	ld	s3,8(sp)
    6648:	6942                	ld	s2,16(sp)
    664a:	4501                	li	a0,0
    664c:	6145                	addi	sp,sp,48
    664e:	8082                	ret
	...

0000000000006660 <main>:
    6660:	716d                	addi	sp,sp,-272
    6662:	e606                	sd	ra,264(sp)
    6664:	f56e                	sd	s11,168(sp)
    6666:	f96a                	sd	s10,176(sp)
    6668:	fd66                	sd	s9,184(sp)
    666a:	e1e2                	sd	s8,192(sp)
    666c:	e5de                	sd	s7,200(sp)
    666e:	e9da                	sd	s6,208(sp)
    6670:	edd6                	sd	s5,216(sp)
    6672:	f1d2                	sd	s4,224(sp)
    6674:	f5ce                	sd	s3,232(sp)
    6676:	f9ca                	sd	s2,240(sp)
    6678:	fda6                	sd	s1,248(sp)
    667a:	e222                	sd	s0,256(sp)
    667c:	ad22                	fsd	fs0,152(sp)
    667e:	81010113          	addi	sp,sp,-2032
    6682:	862e                	mv	a2,a1
    6684:	de2a                	sw	a0,60(sp)
    6686:	186c                	addi	a1,sp,60
    6688:	0aa10513          	addi	a0,sp,170
    668c:	db5fc0ef          	jal	3440 <portable_init>
    6690:	4505                	li	a0,1
    6692:	b1ffd0ef          	jal	41b0 <get_seed_32>
    6696:	04a11023          	sh	a0,64(sp)
    669a:	4509                	li	a0,2
    669c:	b15fd0ef          	jal	41b0 <get_seed_32>
    66a0:	04a11123          	sh	a0,66(sp)
    66a4:	450d                	li	a0,3
    66a6:	b0bfd0ef          	jal	41b0 <get_seed_32>
    66aa:	04a11223          	sh	a0,68(sp)
    66ae:	4511                	li	a0,4
    66b0:	b01fd0ef          	jal	41b0 <get_seed_32>
    66b4:	3c05278b          	th.ext	a5,a0,15,0
    66b8:	4515                	li	a0,5
    66ba:	d6be                	sw	a5,108(sp)
    66bc:	af5fd0ef          	jal	41b0 <get_seed_32>
    66c0:	6706                	ld	a4,64(sp)
    66c2:	429d                	li	t0,7
    66c4:	42a5128b          	th.mvnez	t0,a0,a0
    66c8:	01071693          	slli	a3,a4,0x10
    66cc:	d896                	sw	t0,112(sp)
    66ce:	0100                	addi	s0,sp,128
    66d0:	e699                	bnez	a3,66de <main+0x7e>
    66d2:	06600313          	li	t1,102
    66d6:	fc641223          	sh	t1,-60(s0)
    66da:	fc042023          	sw	zero,-64(s0)
    66de:	fc043483          	ld	s1,-64(s0)
    66e2:	4385                	li	t2,1
    66e4:	bc04b50b          	th.extu	a0,s1,47,0
    66e8:	00751c63          	bne	a0,t2,6700 <main+0xa0>
    66ec:	341535b7          	lui	a1,0x34153
    66f0:	41558613          	addi	a2,a1,1045 # 34153415 <__kernel_stack+0x34065415>
    66f4:	06600813          	li	a6,102
    66f8:	fcc42023          	sw	a2,-64(s0)
    66fc:	fd041223          	sh	a6,-60(s0)
    6700:	0b010893          	addi	a7,sp,176
    6704:	0a011423          	sh	zero,168(sp)
    6708:	0022f993          	andi	s3,t0,2
    670c:	fd143423          	sd	a7,-56(s0)
    6710:	0012ff13          	andi	t5,t0,1
    6714:	0042fa13          	andi	s4,t0,4
    6718:	10099063          	bnez	s3,6818 <perf_monitor_end+0x80>
    671c:	140a0663          	beqz	s4,6868 <perf_monitor_end+0xd0>
    6720:	001f0b1b          	addiw	s6,t5,1
    6724:	7d000b93          	li	s7,2000
    6728:	036bde3b          	divuw	t3,s7,s6
    672c:	4781                	li	a5,0
    672e:	ffc42423          	sw	t3,-24(s0)
    6732:	0c0f13e3          	bnez	t5,6ff8 <perf_monitor_end+0x860>
    6736:	21c7988b          	th.mula	a7,a5,t3
    673a:	ff143023          	sd	a7,-32(s0)
    673e:	ff042683          	lw	a3,-16(s0)
    6742:	0016f293          	andi	t0,a3,1
    6746:	00028e63          	beqz	t0,6762 <main+0x102>
    674a:	fc041603          	lh	a2,-64(s0)
    674e:	fe842503          	lw	a0,-24(s0)
    6752:	fd043583          	ld	a1,-48(s0)
    6756:	c8bfa0ef          	jal	13e0 <core_list_init>
    675a:	ff042683          	lw	a3,-16(s0)
    675e:	fea43c23          	sd	a0,-8(s0)
    6762:	0026f713          	andi	a4,a3,2
    6766:	10071b63          	bnez	a4,687c <perf_monitor_end+0xe4>
    676a:	0046f313          	andi	t1,a3,4
    676e:	00030a63          	beqz	t1,6782 <main+0x122>
    6772:	fc041583          	lh	a1,-64(s0)
    6776:	fe842503          	lw	a0,-24(s0)
    677a:	fe043603          	ld	a2,-32(s0)
    677e:	e02fd0ef          	jal	3d80 <core_init_state>
    6782:	fec42883          	lw	a7,-20(s0)
    6786:	12088663          	beqz	a7,68b2 <perf_monitor_end+0x11a>
    678a:	00041937          	lui	s2,0x41
    678e:	02090c13          	addi	s8,s2,32 # 41020 <Loop_Num>

0000000000006792 <perf_monitor_start>:
    6792:	0088                	addi	a0,sp,64
    6794:	cedff0ef          	jal	6480 <iterate>

0000000000006798 <perf_monitor_end>:
    6798:	000c2603          	lw	a2,0(s8)
    679c:	fc041503          	lh	a0,-64(s0)
    67a0:	4581                	li	a1,0
    67a2:	fff64913          	not	s2,a2
    67a6:	84afe0ef          	jal	47f0 <crc16>
    67aa:	85aa                	mv	a1,a0
    67ac:	fc241503          	lh	a0,-62(s0)
    67b0:	840fe0ef          	jal	47f0 <crc16>
    67b4:	85aa                	mv	a1,a0
    67b6:	fc441503          	lh	a0,-60(s0)
    67ba:	836fe0ef          	jal	47f0 <crc16>
    67be:	85aa                	mv	a1,a0
    67c0:	fe841503          	lh	a0,-24(s0)
    67c4:	82cfe0ef          	jal	47f0 <crc16>
    67c8:	6821                	lui	a6,0x8
    67ca:	0005099b          	sext.w	s3,a0
    67ce:	b0580893          	addi	a7,a6,-1275 # 7b05 <_ftoa+0x9c5>
    67d2:	0f1984e3          	beq	s3,a7,70ba <perf_monitor_end+0x922>
    67d6:	2d38e963          	bltu	a7,s3,6aa8 <perf_monitor_end+0x310>
    67da:	6a09                	lui	s4,0x2
    67dc:	8f2a0c93          	addi	s9,s4,-1806 # 18f2 <core_list_mergesort+0x22>
    67e0:	0b9989e3          	beq	s3,s9,7092 <perf_monitor_end+0x8fa>
    67e4:	6f95                	lui	t6,0x5
    67e6:	eaff8493          	addi	s1,t6,-337 # 4eaf <ecvt+0x4ef>
    67ea:	3e999163          	bne	s3,s1,6bcc <perf_monitor_end+0x434>
    67ee:	67c1                	lui	a5,0x10
    67f0:	6f878513          	addi	a0,a5,1784 # 106f8 <__errno+0x1cc>
    67f4:	03d080ef          	jal	f030 <puts>
    67f8:	62b9                	lui	t0,0xe
    67fa:	6715                	lui	a4,0x5
    67fc:	639d                	lui	t2,0x7
    67fe:	5a428693          	addi	a3,t0,1444 # e5a4 <_vsnprintf+0x59d4>
    6802:	60870313          	addi	t1,a4,1544 # 5608 <ecvtbuf+0x518>
    6806:	a7938513          	addi	a0,t2,-1415 # 6a79 <perf_monitor_end+0x2e1>
    680a:	8b36                	mv	s6,a3
    680c:	ec36                	sd	a3,24(sp)
    680e:	8a9a                	mv	s5,t1
    6810:	e81a                	sd	t1,16(sp)
    6812:	8f2a                	mv	t5,a0
    6814:	e42a                	sd	a0,8(sp)
    6816:	a4f9                	j	6ae4 <perf_monitor_end+0x34c>
    6818:	020a0863          	beqz	s4,6848 <perf_monitor_end+0xb0>
    681c:	002f0d1b          	addiw	s10,t5,2
    6820:	7d000d93          	li	s11,2000
    6824:	03adde3b          	divuw	t3,s11,s10
    6828:	ffc42423          	sw	t3,-24(s0)
    682c:	7c0f1063          	bnez	t5,6fec <perf_monitor_end+0x854>
    6830:	4e81                	li	t4,0
    6832:	4f11                	li	t5,4
    6834:	8fc6                	mv	t6,a7
    6836:	21ce9f8b          	th.mula	t6,t4,t3
    683a:	001e8793          	addi	a5,t4,1
    683e:	fdf43c23          	sd	t6,-40(s0)
    6842:	ee0f0ee3          	beqz	t5,673e <main+0xde>
    6846:	bdc5                	j	6736 <main+0xd6>
    6848:	001f0c1b          	addiw	s8,t5,1
    684c:	7d000c93          	li	s9,2000
    6850:	038cde3b          	divuw	t3,s9,s8
    6854:	4e81                	li	t4,0
    6856:	ffc42423          	sw	t3,-24(s0)
    685a:	fc0f0de3          	beqz	t5,6834 <perf_monitor_end+0x9c>
    685e:	4f01                	li	t5,0
    6860:	4e85                	li	t4,1
    6862:	fd143823          	sd	a7,-48(s0)
    6866:	b7f9                	j	6834 <perf_monitor_end+0x9c>
    6868:	7d000a93          	li	s5,2000
    686c:	ff542423          	sw	s5,-24(s0)
    6870:	ec0f07e3          	beqz	t5,673e <main+0xde>
    6874:	fd143823          	sd	a7,-48(s0)
    6878:	b5d9                	j	673e <main+0xde>
    687a:	0001                	nop
    687c:	fc241383          	lh	t2,-62(s0)
    6880:	fc041503          	lh	a0,-64(s0)
    6884:	86a2                	mv	a3,s0
    6886:	0103949b          	slliw	s1,t2,0x10
    688a:	00a4e5b3          	or	a1,s1,a0
    688e:	0005861b          	sext.w	a2,a1
    6892:	fe842503          	lw	a0,-24(s0)
    6896:	fd843583          	ld	a1,-40(s0)
    689a:	926fc0ef          	jal	29c0 <core_init_matrix>
    689e:	ff042603          	lw	a2,-16(s0)
    68a2:	00467813          	andi	a6,a2,4
    68a6:	ec0816e3          	bnez	a6,6772 <main+0x112>
    68aa:	fec42883          	lw	a7,-20(s0)
    68ae:	ec089ee3          	bnez	a7,678a <main+0x12a>
    68b2:	6dc5                	lui	s11,0x11
    68b4:	c20da407          	flw	fs0,-992(s11) # 10c20 <errpat+0xd8>
    68b8:	4985                	li	s3,1
    68ba:	00041a37          	lui	s4,0x41
    68be:	6ac1                	lui	s5,0x10
    68c0:	6bc1                	lui	s7,0x10
    68c2:	020a0c13          	addi	s8,s4,32 # 41020 <Loop_Num>
    68c6:	04010c93          	addi	s9,sp,64
    68ca:	618a8b13          	addi	s6,s5,1560 # 10618 <__errno+0xec>
    68ce:	660b8d13          	addi	s10,s7,1632 # 10660 <__errno+0x134>
    68d2:	ff342623          	sw	s3,-20(s0)
    68d6:	0001                	nop
    68d8:	fec42e03          	lw	t3,-20(s0)
    68dc:	02043023          	sd	zero,32(s0)
    68e0:	002e1e9b          	slliw	t4,t3,0x2
    68e4:	01ce8f3b          	addw	t5,t4,t3
    68e8:	001f191b          	slliw	s2,t5,0x1
    68ec:	ff242623          	sw	s2,-20(s0)
    68f0:	641080ef          	jal	f730 <get_vtimer>
    68f4:	00ac2223          	sw	a0,4(s8)
    68f8:	14090a63          	beqz	s2,6a4c <perf_monitor_end+0x2b4>
    68fc:	4585                	li	a1,1
    68fe:	8566                	mv	a0,s9
    6900:	860fa0ef          	jal	960 <core_bench_list>
    6904:	02045583          	lhu	a1,32(s0)
    6908:	4489                	li	s1,2
    690a:	9d7fd0ef          	jal	42e0 <crcu16>
    690e:	02a41023          	sh	a0,32(s0)
    6912:	55fd                	li	a1,-1
    6914:	8566                	mv	a0,s9
    6916:	84afa0ef          	jal	960 <core_bench_list>
    691a:	02045583          	lhu	a1,32(s0)
    691e:	9c3fd0ef          	jal	42e0 <crcu16>
    6922:	ffe90f93          	addi	t6,s2,-2
    6926:	02a41023          	sh	a0,32(s0)
    692a:	02a41123          	sh	a0,34(s0)
    692e:	4585                	li	a1,1
    6930:	8566                	mv	a0,s9
    6932:	003ff993          	andi	s3,t6,3
    6936:	82afa0ef          	jal	960 <core_bench_list>
    693a:	02045583          	lhu	a1,32(s0)
    693e:	9a3fd0ef          	jal	42e0 <crcu16>
    6942:	02a41023          	sh	a0,32(s0)
    6946:	55fd                	li	a1,-1
    6948:	8566                	mv	a0,s9
    694a:	816fa0ef          	jal	960 <core_bench_list>
    694e:	02045583          	lhu	a1,32(s0)
    6952:	98ffd0ef          	jal	42e0 <crcu16>
    6956:	02a41023          	sh	a0,32(s0)
    695a:	0f24f963          	bgeu	s1,s2,6a4c <perf_monitor_end+0x2b4>
    695e:	08098963          	beqz	s3,69f0 <perf_monitor_end+0x258>
    6962:	4585                	li	a1,1
    6964:	04b98f63          	beq	s3,a1,69c2 <perf_monitor_end+0x22a>
    6968:	02998863          	beq	s3,s1,6998 <perf_monitor_end+0x200>
    696c:	8566                	mv	a0,s9
    696e:	ff3f90ef          	jal	960 <core_bench_list>
    6972:	02045583          	lhu	a1,32(s0)
    6976:	448d                	li	s1,3
    6978:	969fd0ef          	jal	42e0 <crcu16>
    697c:	02a41023          	sh	a0,32(s0)
    6980:	55fd                	li	a1,-1
    6982:	8566                	mv	a0,s9
    6984:	fddf90ef          	jal	960 <core_bench_list>
    6988:	02045583          	lhu	a1,32(s0)
    698c:	955fd0ef          	jal	42e0 <crcu16>
    6990:	02a41023          	sh	a0,32(s0)
    6994:	00000013          	nop
    6998:	4585                	li	a1,1
    699a:	8566                	mv	a0,s9
    699c:	fc5f90ef          	jal	960 <core_bench_list>
    69a0:	02045583          	lhu	a1,32(s0)
    69a4:	2485                	addiw	s1,s1,1
    69a6:	93bfd0ef          	jal	42e0 <crcu16>
    69aa:	02a41023          	sh	a0,32(s0)
    69ae:	55fd                	li	a1,-1
    69b0:	8566                	mv	a0,s9
    69b2:	faff90ef          	jal	960 <core_bench_list>
    69b6:	02045583          	lhu	a1,32(s0)
    69ba:	927fd0ef          	jal	42e0 <crcu16>
    69be:	02a41023          	sh	a0,32(s0)
    69c2:	4585                	li	a1,1
    69c4:	8566                	mv	a0,s9
    69c6:	f9bf90ef          	jal	960 <core_bench_list>
    69ca:	02045583          	lhu	a1,32(s0)
    69ce:	2485                	addiw	s1,s1,1
    69d0:	911fd0ef          	jal	42e0 <crcu16>
    69d4:	02a41023          	sh	a0,32(s0)
    69d8:	55fd                	li	a1,-1
    69da:	8566                	mv	a0,s9
    69dc:	f85f90ef          	jal	960 <core_bench_list>
    69e0:	02045583          	lhu	a1,32(s0)
    69e4:	8fdfd0ef          	jal	42e0 <crcu16>
    69e8:	02a41023          	sh	a0,32(s0)
    69ec:	0724f063          	bgeu	s1,s2,6a4c <perf_monitor_end+0x2b4>
    69f0:	4585                	li	a1,1
    69f2:	8566                	mv	a0,s9
    69f4:	f6df90ef          	jal	960 <core_bench_list>
    69f8:	02045583          	lhu	a1,32(s0)
    69fc:	00148a1b          	addiw	s4,s1,1
    6a00:	001a049b          	addiw	s1,s4,1
    6a04:	8ddfd0ef          	jal	42e0 <crcu16>
    6a08:	02a41023          	sh	a0,32(s0)
    6a0c:	55fd                	li	a1,-1
    6a0e:	8566                	mv	a0,s9
    6a10:	f51f90ef          	jal	960 <core_bench_list>
    6a14:	02045583          	lhu	a1,32(s0)
    6a18:	8c9fd0ef          	jal	42e0 <crcu16>
    6a1c:	02a41023          	sh	a0,32(s0)
    6a20:	4585                	li	a1,1
    6a22:	8566                	mv	a0,s9
    6a24:	f3df90ef          	jal	960 <core_bench_list>
    6a28:	02045583          	lhu	a1,32(s0)
    6a2c:	8b5fd0ef          	jal	42e0 <crcu16>
    6a30:	02a41023          	sh	a0,32(s0)
    6a34:	55fd                	li	a1,-1
    6a36:	8566                	mv	a0,s9
    6a38:	f29f90ef          	jal	960 <core_bench_list>
    6a3c:	02045583          	lhu	a1,32(s0)
    6a40:	8a1fd0ef          	jal	42e0 <crcu16>
    6a44:	02a41023          	sh	a0,32(s0)
    6a48:	bf81                	j	6998 <perf_monitor_end+0x200>
    6a4a:	0001                	nop
    6a4c:	4e5080ef          	jal	f730 <get_vtimer>
    6a50:	004c2783          	lw	a5,4(s8)
    6a54:	85ca                	mv	a1,s2
    6a56:	40f502bb          	subw	t0,a0,a5
    6a5a:	0322d63b          	divuw	a2,t0,s2
    6a5e:	e2cc550b          	th.swd	a0,a2,(s8),1,3
    6a62:	855a                	mv	a0,s6
    6a64:	67c080ef          	jal	f0e0 <printf>
    6a68:	00cc2683          	lw	a3,12(s8)
    6a6c:	856a                	mv	a0,s10
    6a6e:	d006f7d3          	fcvt.s.w	fa5,a3
    6a72:	18f47053          	fdiv.s	ft0,fs0,fa5
    6a76:	420000d3          	fcvt.d.s	ft1,ft0
    6a7a:	e20085d3          	fmv.x.d	a1,ft1
    6a7e:	662080ef          	jal	f0e0 <printf>
    6a82:	4bf080ef          	jal	f740 <sim_end>
    6a86:	4501                	li	a0,0
    6a88:	9a9fc0ef          	jal	3430 <time_in_secs>
    6a8c:	e40506e3          	beqz	a0,68d8 <perf_monitor_end+0x140>
    6a90:	4729                	li	a4,10
    6a92:	02a7533b          	divuw	t1,a4,a0
    6a96:	fec42503          	lw	a0,-20(s0)
    6a9a:	0013039b          	addiw	t2,t1,1
    6a9e:	02a385bb          	mulw	a1,t2,a0
    6aa2:	feb42623          	sw	a1,-20(s0)
    6aa6:	b1f5                	j	6792 <perf_monitor_start>
    6aa8:	6b25                	lui	s6,0x9
    6aaa:	a02b0e13          	addi	t3,s6,-1534 # 8a02 <_ftoa+0x18c2>
    6aae:	5bc98d63          	beq	s3,t3,7068 <perf_monitor_end+0x8d0>
    6ab2:	673d                	lui	a4,0xf
    6ab4:	9f570313          	addi	t1,a4,-1547 # e9f5 <_vsnprintf+0x5e25>
    6ab8:	10699a63          	bne	s3,t1,6bcc <perf_monitor_end+0x434>
    6abc:	63c1                	lui	t2,0x10
    6abe:	72838513          	addi	a0,t2,1832 # 10728 <__errno+0x1fc>
    6ac2:	56e080ef          	jal	f030 <puts>
    6ac6:	6525                	lui	a0,0x9
    6ac8:	6609                	lui	a2,0x2
    6aca:	68b9                	lui	a7,0xe
    6acc:	e3a50593          	addi	a1,a0,-454 # 8e3a <_vsnprintf+0x26a>
    6ad0:	fd760813          	addi	a6,a2,-41 # 1fd7 <matrix_test+0x447>
    6ad4:	71488c13          	addi	s8,a7,1812 # e714 <_vsnprintf+0x5b44>
    6ad8:	8b2e                	mv	s6,a1
    6ada:	ec2e                	sd	a1,24(sp)
    6adc:	8ac2                	mv	s5,a6
    6ade:	e842                	sd	a6,16(sp)
    6ae0:	8f62                	mv	t5,s8
    6ae2:	e462                	sd	s8,8(sp)
    6ae4:	000404b7          	lui	s1,0x40
    6ae8:	0084a583          	lw	a1,8(s1) # 40008 <default_num_contexts>
    6aec:	5e058c63          	beqz	a1,70e4 <perf_monitor_end+0x94c>
    6af0:	6641                	lui	a2,0x10
    6af2:	68c1                	lui	a7,0x10
    6af4:	6e41                	lui	t3,0x10
    6af6:	78860813          	addi	a6,a2,1928 # 10788 <__errno+0x25c>
    6afa:	7b888b93          	addi	s7,a7,1976 # 107b8 <__errno+0x28c>
    6afe:	7f0e0e93          	addi	t4,t3,2032 # 107f0 <__errno+0x2c4>
    6b02:	4d81                	li	s11,0
    6b04:	4d01                	li	s10,0
    6b06:	4c81                	li	s9,0
    6b08:	000f0a1b          	sext.w	s4,t5
    6b0c:	f042                	sd	a6,32(sp)
    6b0e:	f45e                	sd	s7,40(sp)
    6b10:	f876                	sd	t4,48(sp)
    6b12:	a01d                	j	6b38 <perf_monitor_end+0x3a0>
    6b14:	01c40cb3          	add	s9,s0,t3
    6b18:	028cdf83          	lhu	t6,40(s9)
    6b1c:	0084a783          	lw	a5,8(s1)
    6b20:	2d05                	addiw	s10,s10,1
    6b22:	01fd8dbb          	addw	s11,s11,t6
    6b26:	3c0d3d0b          	th.extu	s10,s10,15,0
    6b2a:	3c0dbc0b          	th.extu	s8,s11,15,0
    6b2e:	8cea                	mv	s9,s10
    6b30:	3c0dad8b          	th.ext	s11,s11,15,0
    6b34:	0afd7263          	bgeu	s10,a5,6bd8 <perf_monitor_end+0x440>
    6b38:	003c9b93          	slli	s7,s9,0x3
    6b3c:	419b8f33          	sub	t5,s7,s9
    6b40:	004f1f93          	slli	t6,t5,0x4
    6b44:	01f40c33          	add	s8,s0,t6
    6b48:	ff0c2803          	lw	a6,-16(s8)
    6b4c:	020c1423          	sh	zero,40(s8)
    6b50:	00187793          	andi	a5,a6,1
    6b54:	c395                	beqz	a5,6b78 <perf_monitor_end+0x3e0>
    6b56:	022c5603          	lhu	a2,34(s8)
    6b5a:	01460f63          	beq	a2,s4,6b78 <perf_monitor_end+0x3e0>
    6b5e:	66a2                	ld	a3,8(sp)
    6b60:	7502                	ld	a0,32(sp)
    6b62:	85e6                	mv	a1,s9
    6b64:	57c080ef          	jal	f0e0 <printf>
    6b68:	028c5283          	lhu	t0,40(s8)
    6b6c:	ff0c2803          	lw	a6,-16(s8)
    6b70:	0012869b          	addiw	a3,t0,1
    6b74:	02dc1423          	sh	a3,40(s8)
    6b78:	00287713          	andi	a4,a6,2
    6b7c:	cb05                	beqz	a4,6bac <perf_monitor_end+0x414>
    6b7e:	419b8333          	sub	t1,s7,s9
    6b82:	00431393          	slli	t2,t1,0x4
    6b86:	00740c33          	add	s8,s0,t2
    6b8a:	024c5603          	lhu	a2,36(s8)
    6b8e:	01560f63          	beq	a2,s5,6bac <perf_monitor_end+0x414>
    6b92:	66c2                	ld	a3,16(sp)
    6b94:	7522                	ld	a0,40(sp)
    6b96:	85e6                	mv	a1,s9
    6b98:	548080ef          	jal	f0e0 <printf>
    6b9c:	028c5503          	lhu	a0,40(s8)
    6ba0:	ff0c2803          	lw	a6,-16(s8)
    6ba4:	0015059b          	addiw	a1,a0,1
    6ba8:	02bc1423          	sh	a1,40(s8)
    6bac:	419b88b3          	sub	a7,s7,s9
    6bb0:	00487613          	andi	a2,a6,4
    6bb4:	00489e13          	slli	t3,a7,0x4
    6bb8:	de31                	beqz	a2,6b14 <perf_monitor_end+0x37c>
    6bba:	01c40bb3          	add	s7,s0,t3
    6bbe:	026bd603          	lhu	a2,38(s7)
    6bc2:	45661163          	bne	a2,s6,7004 <perf_monitor_end+0x86c>
    6bc6:	028bdf83          	lhu	t6,40(s7)
    6bca:	bf89                	j	6b1c <perf_monitor_end+0x384>
    6bcc:	6c41                	lui	s8,0x10
    6bce:	3c7d                	addiw	s8,s8,-1 # ffff <_malloc_trim_r+0x55>
    6bd0:	000404b7          	lui	s1,0x40
    6bd4:	00000013          	nop
    6bd8:	dd9fd0ef          	jal	49b0 <check_data_types>
    6bdc:	fe842583          	lw	a1,-24(s0)
    6be0:	6ac5                	lui	s5,0x11
    6be2:	01850b3b          	addw	s6,a0,s8
    6be6:	820a8513          	addi	a0,s5,-2016 # 10820 <__errno+0x2f4>
    6bea:	4f6080ef          	jal	f0e0 <printf>
    6bee:	62c5                	lui	t0,0x11
    6bf0:	85ca                	mv	a1,s2
    6bf2:	83828513          	addi	a0,t0,-1992 # 10838 <__errno+0x30c>
    6bf6:	4ea080ef          	jal	f0e0 <printf>
    6bfa:	854a                	mv	a0,s2
    6bfc:	835fc0ef          	jal	3430 <time_in_secs>
    6c00:	66c5                	lui	a3,0x11
    6c02:	85aa                	mv	a1,a0
    6c04:	85068513          	addi	a0,a3,-1968 # 10850 <__errno+0x324>
    6c08:	4d8080ef          	jal	f0e0 <printf>
    6c0c:	854a                	mv	a0,s2
    6c0e:	3c0b3a0b          	th.extu	s4,s6,15,0
    6c12:	81ffc0ef          	jal	3430 <time_in_secs>
    6c16:	42051263          	bnez	a0,703a <perf_monitor_end+0x8a2>
    6c1a:	854a                	mv	a0,s2
    6c1c:	815fc0ef          	jal	3430 <time_in_secs>
    6c20:	4925                	li	s2,9
    6c22:	40a97563          	bgeu	s2,a0,702c <perf_monitor_end+0x894>
    6c26:	fec42603          	lw	a2,-20(s0)
    6c2a:	0084a583          	lw	a1,8(s1) # 40008 <default_num_contexts>
    6c2e:	6845                	lui	a6,0x11
    6c30:	8c080513          	addi	a0,a6,-1856 # 108c0 <__errno+0x394>
    6c34:	02c585bb          	mulw	a1,a1,a2
    6c38:	6dc5                	lui	s11,0x11
    6c3a:	3c0a2b8b          	th.ext	s7,s4,15,0
    6c3e:	4a2080ef          	jal	f0e0 <printf>
    6c42:	68c5                	lui	a7,0x11
    6c44:	6e45                	lui	t3,0x11
    6c46:	8d888593          	addi	a1,a7,-1832 # 108d8 <__errno+0x3ac>
    6c4a:	8f0e0513          	addi	a0,t3,-1808 # 108f0 <__errno+0x3c4>
    6c4e:	492080ef          	jal	f0e0 <printf>
    6c52:	6ec5                	lui	t4,0x11
    6c54:	6f45                	lui	t5,0x11
    6c56:	908e8593          	addi	a1,t4,-1784 # 10908 <__errno+0x3dc>
    6c5a:	910f0513          	addi	a0,t5,-1776 # 10910 <__errno+0x3e4>
    6c5e:	482080ef          	jal	f0e0 <printf>
    6c62:	6fc5                	lui	t6,0x11
    6c64:	928f8593          	addi	a1,t6,-1752 # 10928 <__errno+0x3fc>
    6c68:	930d8513          	addi	a0,s11,-1744 # 10930 <__errno+0x404>
    6c6c:	474080ef          	jal	f0e0 <printf>
    6c70:	85ce                	mv	a1,s3
    6c72:	69c5                	lui	s3,0x11
    6c74:	94898513          	addi	a0,s3,-1720 # 10948 <__errno+0x41c>
    6c78:	468080ef          	jal	f0e0 <printf>
    6c7c:	ff042d03          	lw	s10,-16(s0)
    6c80:	001d7793          	andi	a5,s10,1
    6c84:	c3f1                	beqz	a5,6d48 <perf_monitor_end+0x5b0>
    6c86:	0084ac83          	lw	s9,8(s1)
    6c8a:	0a0c8f63          	beqz	s9,6d48 <perf_monitor_end+0x5b0>
    6c8e:	6b45                	lui	s6,0x11
    6c90:	4c01                	li	s8,0
    6c92:	4581                	li	a1,0
    6c94:	968b0a93          	addi	s5,s6,-1688 # 10968 <__errno+0x43c>
    6c98:	00359293          	slli	t0,a1,0x3
    6c9c:	40b286b3          	sub	a3,t0,a1
    6ca0:	00469713          	slli	a4,a3,0x4
    6ca4:	00e40333          	add	t1,s0,a4
    6ca8:	02235603          	lhu	a2,34(t1)
    6cac:	8556                	mv	a0,s5
    6cae:	2c05                	addiw	s8,s8,1
    6cb0:	430080ef          	jal	f0e0 <printf>
    6cb4:	0084a383          	lw	t2,8(s1)
    6cb8:	3c0c390b          	th.extu	s2,s8,15,0
    6cbc:	85ca                	mv	a1,s2
    6cbe:	08797563          	bgeu	s2,t2,6d48 <perf_monitor_end+0x5b0>
    6cc2:	00391513          	slli	a0,s2,0x3
    6cc6:	41250a33          	sub	s4,a0,s2
    6cca:	004a1813          	slli	a6,s4,0x4
    6cce:	01040633          	add	a2,s0,a6
    6cd2:	02265603          	lhu	a2,34(a2)
    6cd6:	8556                	mv	a0,s5
    6cd8:	408080ef          	jal	f0e0 <printf>
    6cdc:	0084a883          	lw	a7,8(s1)
    6ce0:	0019059b          	addiw	a1,s2,1
    6ce4:	3c05bd8b          	th.extu	s11,a1,15,0
    6ce8:	85ee                	mv	a1,s11
    6cea:	051dff63          	bgeu	s11,a7,6d48 <perf_monitor_end+0x5b0>
    6cee:	003d9e13          	slli	t3,s11,0x3
    6cf2:	41be0eb3          	sub	t4,t3,s11
    6cf6:	004e9f13          	slli	t5,t4,0x4
    6cfa:	01e40fb3          	add	t6,s0,t5
    6cfe:	022fd603          	lhu	a2,34(t6)
    6d02:	8556                	mv	a0,s5
    6d04:	001d899b          	addiw	s3,s11,1
    6d08:	3d8080ef          	jal	f0e0 <printf>
    6d0c:	0084a783          	lw	a5,8(s1)
    6d10:	3c09bd0b          	th.extu	s10,s3,15,0
    6d14:	85ea                	mv	a1,s10
    6d16:	02fd7963          	bgeu	s10,a5,6d48 <perf_monitor_end+0x5b0>
    6d1a:	003d1c93          	slli	s9,s10,0x3
    6d1e:	41ac8b33          	sub	s6,s9,s10
    6d22:	004b1293          	slli	t0,s6,0x4
    6d26:	005406b3          	add	a3,s0,t0
    6d2a:	0226d603          	lhu	a2,34(a3)
    6d2e:	8556                	mv	a0,s5
    6d30:	3b0080ef          	jal	f0e0 <printf>
    6d34:	0084a303          	lw	t1,8(s1)
    6d38:	001d071b          	addiw	a4,s10,1
    6d3c:	3c073c0b          	th.extu	s8,a4,15,0
    6d40:	85e2                	mv	a1,s8
    6d42:	f46c6be3          	bltu	s8,t1,6c98 <perf_monitor_end+0x500>
    6d46:	0001                	nop
    6d48:	ff042a83          	lw	s5,-16(s0)
    6d4c:	002af913          	andi	s2,s5,2
    6d50:	0c090463          	beqz	s2,6e18 <perf_monitor_end+0x680>
    6d54:	0084a383          	lw	t2,8(s1)
    6d58:	38038863          	beqz	t2,70e8 <perf_monitor_end+0x950>
    6d5c:	6a45                	lui	s4,0x11
    6d5e:	4981                	li	s3,0
    6d60:	4581                	li	a1,0
    6d62:	988a0d93          	addi	s11,s4,-1656 # 10988 <__errno+0x45c>
    6d66:	00359813          	slli	a6,a1,0x3
    6d6a:	40b80633          	sub	a2,a6,a1
    6d6e:	00461893          	slli	a7,a2,0x4
    6d72:	01140e33          	add	t3,s0,a7
    6d76:	024e5603          	lhu	a2,36(t3)
    6d7a:	856e                	mv	a0,s11
    6d7c:	364080ef          	jal	f0e0 <printf>
    6d80:	0084ae83          	lw	t4,8(s1)
    6d84:	0019859b          	addiw	a1,s3,1
    6d88:	3c05b98b          	th.extu	s3,a1,15,0
    6d8c:	85ce                	mv	a1,s3
    6d8e:	09d9f563          	bgeu	s3,t4,6e18 <perf_monitor_end+0x680>
    6d92:	00399f13          	slli	t5,s3,0x3
    6d96:	413f0fb3          	sub	t6,t5,s3
    6d9a:	004f9d13          	slli	s10,t6,0x4
    6d9e:	01a407b3          	add	a5,s0,s10
    6da2:	0247d603          	lhu	a2,36(a5)
    6da6:	856e                	mv	a0,s11
    6da8:	00198c9b          	addiw	s9,s3,1
    6dac:	334080ef          	jal	f0e0 <printf>
    6db0:	0084a283          	lw	t0,8(s1)
    6db4:	3c0cbb0b          	th.extu	s6,s9,15,0
    6db8:	85da                	mv	a1,s6
    6dba:	045b7f63          	bgeu	s6,t0,6e18 <perf_monitor_end+0x680>
    6dbe:	003b1693          	slli	a3,s6,0x3
    6dc2:	41668733          	sub	a4,a3,s6
    6dc6:	00471c13          	slli	s8,a4,0x4
    6dca:	01840333          	add	t1,s0,s8
    6dce:	02435603          	lhu	a2,36(t1)
    6dd2:	856e                	mv	a0,s11
    6dd4:	001b0a9b          	addiw	s5,s6,1
    6dd8:	308080ef          	jal	f0e0 <printf>
    6ddc:	0084a383          	lw	t2,8(s1)
    6de0:	3c0ab90b          	th.extu	s2,s5,15,0
    6de4:	85ca                	mv	a1,s2
    6de6:	02797963          	bgeu	s2,t2,6e18 <perf_monitor_end+0x680>
    6dea:	00391513          	slli	a0,s2,0x3
    6dee:	41250a33          	sub	s4,a0,s2
    6df2:	004a1813          	slli	a6,s4,0x4
    6df6:	01040633          	add	a2,s0,a6
    6dfa:	02465603          	lhu	a2,36(a2)
    6dfe:	856e                	mv	a0,s11
    6e00:	2e0080ef          	jal	f0e0 <printf>
    6e04:	0084ae03          	lw	t3,8(s1)
    6e08:	0019089b          	addiw	a7,s2,1
    6e0c:	3c08b98b          	th.extu	s3,a7,15,0
    6e10:	85ce                	mv	a1,s3
    6e12:	f5c9eae3          	bltu	s3,t3,6d66 <perf_monitor_end+0x5ce>
    6e16:	0001                	nop
    6e18:	ff042d83          	lw	s11,-16(s0)
    6e1c:	004df593          	andi	a1,s11,4
    6e20:	c5e1                	beqz	a1,6ee8 <perf_monitor_end+0x750>
    6e22:	0084ae83          	lw	t4,8(s1)
    6e26:	180e8163          	beqz	t4,6fa8 <perf_monitor_end+0x810>
    6e2a:	6f45                	lui	t5,0x11
    6e2c:	4c01                	li	s8,0
    6e2e:	4581                	li	a1,0
    6e30:	9a8f0d13          	addi	s10,t5,-1624 # 109a8 <__errno+0x47c>
    6e34:	00359f93          	slli	t6,a1,0x3
    6e38:	40bf87b3          	sub	a5,t6,a1
    6e3c:	00479c93          	slli	s9,a5,0x4
    6e40:	01940b33          	add	s6,s0,s9
    6e44:	026b5603          	lhu	a2,38(s6)
    6e48:	856a                	mv	a0,s10
    6e4a:	296080ef          	jal	f0e0 <printf>
    6e4e:	0084a683          	lw	a3,8(s1)
    6e52:	001c029b          	addiw	t0,s8,1
    6e56:	3c02bc0b          	th.extu	s8,t0,15,0
    6e5a:	85e2                	mv	a1,s8
    6e5c:	08dc7663          	bgeu	s8,a3,6ee8 <perf_monitor_end+0x750>
    6e60:	003c1713          	slli	a4,s8,0x3
    6e64:	41870333          	sub	t1,a4,s8
    6e68:	00431a93          	slli	s5,t1,0x4
    6e6c:	01540933          	add	s2,s0,s5
    6e70:	02695603          	lhu	a2,38(s2)
    6e74:	856a                	mv	a0,s10
    6e76:	26a080ef          	jal	f0e0 <printf>
    6e7a:	0084a503          	lw	a0,8(s1)
    6e7e:	001c039b          	addiw	t2,s8,1
    6e82:	3c03ba0b          	th.extu	s4,t2,15,0
    6e86:	85d2                	mv	a1,s4
    6e88:	06aa7063          	bgeu	s4,a0,6ee8 <perf_monitor_end+0x750>
    6e8c:	003a1813          	slli	a6,s4,0x3
    6e90:	41480633          	sub	a2,a6,s4
    6e94:	00461893          	slli	a7,a2,0x4
    6e98:	011409b3          	add	s3,s0,a7
    6e9c:	0269d603          	lhu	a2,38(s3)
    6ea0:	856a                	mv	a0,s10
    6ea2:	23e080ef          	jal	f0e0 <printf>
    6ea6:	0084ae83          	lw	t4,8(s1)
    6eaa:	001a0e1b          	addiw	t3,s4,1
    6eae:	3c0e3d8b          	th.extu	s11,t3,15,0
    6eb2:	85ee                	mv	a1,s11
    6eb4:	03ddfa63          	bgeu	s11,t4,6ee8 <perf_monitor_end+0x750>
    6eb8:	003d9f13          	slli	t5,s11,0x3
    6ebc:	41bf0fb3          	sub	t6,t5,s11
    6ec0:	004f9793          	slli	a5,t6,0x4
    6ec4:	00f40cb3          	add	s9,s0,a5
    6ec8:	026cd603          	lhu	a2,38(s9)
    6ecc:	856a                	mv	a0,s10
    6ece:	212080ef          	jal	f0e0 <printf>
    6ed2:	0084ab03          	lw	s6,8(s1)
    6ed6:	001d859b          	addiw	a1,s11,1
    6eda:	3c05bc0b          	th.extu	s8,a1,15,0
    6ede:	85e2                	mv	a1,s8
    6ee0:	f56c6ae3          	bltu	s8,s6,6e34 <perf_monitor_end+0x69c>
    6ee4:	00000013          	nop
    6ee8:	0084ad03          	lw	s10,8(s1)
    6eec:	0a0d0e63          	beqz	s10,6fa8 <perf_monitor_end+0x810>
    6ef0:	62c5                	lui	t0,0x11
    6ef2:	4901                	li	s2,0
    6ef4:	4581                	li	a1,0
    6ef6:	9c828a93          	addi	s5,t0,-1592 # 109c8 <__errno+0x49c>
    6efa:	00359693          	slli	a3,a1,0x3
    6efe:	40b68733          	sub	a4,a3,a1
    6f02:	00471313          	slli	t1,a4,0x4
    6f06:	006403b3          	add	t2,s0,t1
    6f0a:	0203d603          	lhu	a2,32(t2)
    6f0e:	8556                	mv	a0,s5
    6f10:	2905                	addiw	s2,s2,1
    6f12:	1ce080ef          	jal	f0e0 <printf>
    6f16:	0084a503          	lw	a0,8(s1)
    6f1a:	3c093a0b          	th.extu	s4,s2,15,0
    6f1e:	85d2                	mv	a1,s4
    6f20:	08aa7463          	bgeu	s4,a0,6fa8 <perf_monitor_end+0x810>
    6f24:	003a1813          	slli	a6,s4,0x3
    6f28:	41480633          	sub	a2,a6,s4
    6f2c:	00461893          	slli	a7,a2,0x4
    6f30:	011409b3          	add	s3,s0,a7
    6f34:	0209d603          	lhu	a2,32(s3)
    6f38:	8556                	mv	a0,s5
    6f3a:	1a6080ef          	jal	f0e0 <printf>
    6f3e:	0084ae83          	lw	t4,8(s1)
    6f42:	001a0e1b          	addiw	t3,s4,1
    6f46:	3c0e3d8b          	th.extu	s11,t3,15,0
    6f4a:	85ee                	mv	a1,s11
    6f4c:	05ddfe63          	bgeu	s11,t4,6fa8 <perf_monitor_end+0x810>
    6f50:	003d9f13          	slli	t5,s11,0x3
    6f54:	41bf0fb3          	sub	t6,t5,s11
    6f58:	004f9793          	slli	a5,t6,0x4
    6f5c:	00f40cb3          	add	s9,s0,a5
    6f60:	020cd603          	lhu	a2,32(s9)
    6f64:	8556                	mv	a0,s5
    6f66:	17a080ef          	jal	f0e0 <printf>
    6f6a:	0084ab03          	lw	s6,8(s1)
    6f6e:	001d859b          	addiw	a1,s11,1
    6f72:	3c05bc0b          	th.extu	s8,a1,15,0
    6f76:	85e2                	mv	a1,s8
    6f78:	036c7863          	bgeu	s8,s6,6fa8 <perf_monitor_end+0x810>
    6f7c:	003c1d13          	slli	s10,s8,0x3
    6f80:	418d02b3          	sub	t0,s10,s8
    6f84:	00429693          	slli	a3,t0,0x4
    6f88:	00d40733          	add	a4,s0,a3
    6f8c:	02075603          	lhu	a2,32(a4)
    6f90:	8556                	mv	a0,s5
    6f92:	14e080ef          	jal	f0e0 <printf>
    6f96:	0084a383          	lw	t2,8(s1)
    6f9a:	001c031b          	addiw	t1,s8,1
    6f9e:	3c03390b          	th.extu	s2,t1,15,0
    6fa2:	85ca                	mv	a1,s2
    6fa4:	f4796be3          	bltu	s2,t2,6efa <perf_monitor_end+0x762>
    6fa8:	060b8c63          	beqz	s7,7020 <perf_monitor_end+0x888>
    6fac:	0b705863          	blez	s7,705c <perf_monitor_end+0x8c4>
    6fb0:	6bc5                	lui	s7,0x11
    6fb2:	a38b8513          	addi	a0,s7,-1480 # 10a38 <__errno+0x50c>
    6fb6:	07a080ef          	jal	f030 <puts>
    6fba:	0aa10513          	addi	a0,sp,170
    6fbe:	ca2fc0ef          	jal	3460 <portable_fini>
    6fc2:	77e080ef          	jal	f740 <sim_end>
    6fc6:	7f010113          	addi	sp,sp,2032
    6fca:	60b2                	ld	ra,264(sp)
    6fcc:	7daa                	ld	s11,168(sp)
    6fce:	7d4a                	ld	s10,176(sp)
    6fd0:	7cea                	ld	s9,184(sp)
    6fd2:	6c0e                	ld	s8,192(sp)
    6fd4:	6bae                	ld	s7,200(sp)
    6fd6:	6b4e                	ld	s6,208(sp)
    6fd8:	6aee                	ld	s5,216(sp)
    6fda:	7a0e                	ld	s4,224(sp)
    6fdc:	79ae                	ld	s3,232(sp)
    6fde:	794e                	ld	s2,240(sp)
    6fe0:	74ee                	ld	s1,248(sp)
    6fe2:	6412                	ld	s0,256(sp)
    6fe4:	246a                	fld	fs0,152(sp)
    6fe6:	4501                	li	a0,0
    6fe8:	6151                	addi	sp,sp,272
    6fea:	8082                	ret
    6fec:	4e85                	li	t4,1
    6fee:	4f11                	li	t5,4
    6ff0:	fd143823          	sd	a7,-48(s0)
    6ff4:	841ff06f          	j	6834 <perf_monitor_end+0x9c>
    6ff8:	4785                	li	a5,1
    6ffa:	fd143823          	sd	a7,-48(s0)
    6ffe:	f38ff06f          	j	6736 <main+0xd6>
    7002:	0001                	nop
    7004:	66e2                	ld	a3,24(sp)
    7006:	7542                	ld	a0,48(sp)
    7008:	85e6                	mv	a1,s9
    700a:	0d6080ef          	jal	f0e0 <printf>
    700e:	028bde83          	lhu	t4,40(s7)
    7012:	001e8f1b          	addiw	t5,t4,1
    7016:	3c0f3f8b          	th.extu	t6,t5,15,0
    701a:	03fb9423          	sh	t6,40(s7)
    701e:	bcfd                	j	6b1c <perf_monitor_end+0x384>
    7020:	6ac5                	lui	s5,0x11
    7022:	9e8a8513          	addi	a0,s5,-1560 # 109e8 <__errno+0x4bc>
    7026:	00a080ef          	jal	f030 <puts>
    702a:	bf41                	j	6fba <perf_monitor_end+0x822>
    702c:	6545                	lui	a0,0x11
    702e:	88050513          	addi	a0,a0,-1920 # 10880 <__errno+0x354>
    7032:	7ff070ef          	jal	f030 <puts>
    7036:	2a05                	addiw	s4,s4,1
    7038:	b6fd                	j	6c26 <perf_monitor_end+0x48e>
    703a:	0084a703          	lw	a4,8(s1)
    703e:	fec42303          	lw	t1,-20(s0)
    7042:	854a                	mv	a0,s2
    7044:	02670c3b          	mulw	s8,a4,t1
    7048:	be8fc0ef          	jal	3430 <time_in_secs>
    704c:	63c5                	lui	t2,0x11
    704e:	02ac55bb          	divuw	a1,s8,a0
    7052:	86838513          	addi	a0,t2,-1944 # 10868 <__errno+0x33c>
    7056:	08a080ef          	jal	f0e0 <printf>
    705a:	b6c1                	j	6c1a <perf_monitor_end+0x482>
    705c:	64c5                	lui	s1,0x11
    705e:	a4848513          	addi	a0,s1,-1464 # 10a48 <__errno+0x51c>
    7062:	7cf070ef          	jal	f030 <puts>
    7066:	bf91                	j	6fba <perf_monitor_end+0x822>
    7068:	6ec1                	lui	t4,0x10
    706a:	698e8513          	addi	a0,t4,1688 # 10698 <__errno+0x16c>
    706e:	7c3070ef          	jal	f030 <puts>
    7072:	6f19                	lui	t5,0x6
    7074:	64b1                	lui	s1,0xc
    7076:	62b5                	lui	t0,0xd
    7078:	e47f0f93          	addi	t6,t5,-441 # 5e47 <fcvtbuf+0x107>
    707c:	e5248793          	addi	a5,s1,-430 # be52 <_vsnprintf+0x3282>
    7080:	4b028693          	addi	a3,t0,1200 # d4b0 <_vsnprintf+0x48e0>
    7084:	8b7e                	mv	s6,t6
    7086:	ec7e                	sd	t6,24(sp)
    7088:	8abe                	mv	s5,a5
    708a:	e83e                	sd	a5,16(sp)
    708c:	8f36                	mv	t5,a3
    708e:	e436                	sd	a3,8(sp)
    7090:	bc91                	j	6ae4 <perf_monitor_end+0x34c>
    7092:	6ac1                	lui	s5,0x10
    7094:	758a8513          	addi	a0,s5,1880 # 10758 <__errno+0x22c>
    7098:	799070ef          	jal	f030 <puts>
    709c:	6ba5                	lui	s7,0x9
    709e:	6e39                	lui	t3,0xe
    70a0:	d84b8d13          	addi	s10,s7,-636 # 8d84 <_vsnprintf+0x1b4>
    70a4:	74700d93          	li	s11,1863
    70a8:	3c1e0e93          	addi	t4,t3,961 # e3c1 <_vsnprintf+0x57f1>
    70ac:	8b6a                	mv	s6,s10
    70ae:	ec6a                	sd	s10,24(sp)
    70b0:	8aee                	mv	s5,s11
    70b2:	e86e                	sd	s11,16(sp)
    70b4:	8f76                	mv	t5,t4
    70b6:	e476                	sd	t4,8(sp)
    70b8:	b435                	j	6ae4 <perf_monitor_end+0x34c>
    70ba:	6a41                	lui	s4,0x10
    70bc:	6a85                	lui	s5,0x1
    70be:	6c8a0513          	addi	a0,s4,1736 # 106c8 <__errno+0x19c>
    70c2:	6c11                	lui	s8,0x4
    70c4:	6d0d                	lui	s10,0x3
    70c6:	76b070ef          	jal	f030 <puts>
    70ca:	9bfc0c93          	addi	s9,s8,-1601 # 39bf <core_bench_state+0x54f>
    70ce:	199a8b93          	addi	s7,s5,409 # 1199 <core_bench_list+0x839>
    70d2:	340d0d93          	addi	s11,s10,832 # 3340 <matrix_mul_matrix_bitextract+0xd0>
    70d6:	8b66                	mv	s6,s9
    70d8:	ec66                	sd	s9,24(sp)
    70da:	8ade                	mv	s5,s7
    70dc:	e85e                	sd	s7,16(sp)
    70de:	8f6e                	mv	t5,s11
    70e0:	e46e                	sd	s11,8(sp)
    70e2:	b409                	j	6ae4 <perf_monitor_end+0x34c>
    70e4:	4c01                	li	s8,0
    70e6:	bccd                	j	6bd8 <perf_monitor_end+0x440>
    70e8:	004af513          	andi	a0,s5,4
    70ec:	de050ee3          	beqz	a0,6ee8 <perf_monitor_end+0x750>
    70f0:	bd65                	j	6fa8 <perf_monitor_end+0x810>
	...

0000000000007100 <_out_buffer>:
    7100:	00d67463          	bgeu	a2,a3,7108 <_out_buffer+0x8>
    7104:	00c5d50b          	th.srb	a0,a1,a2,0
    7108:	8082                	ret
    710a:	00000013          	nop
    710e:	0001                	nop

0000000000007110 <_out_null>:
    7110:	8082                	ret
    7112:	0001                	nop
    7114:	00000013          	nop
    7118:	00000013          	nop
    711c:	00000013          	nop

0000000000007120 <_out_fct>:
    7120:	c501                	beqz	a0,7128 <_out_fct+0x8>
    7122:	619c                	ld	a5,0(a1)
    7124:	658c                	ld	a1,8(a1)
    7126:	8782                	jr	a5
    7128:	8082                	ret
    712a:	00000013          	nop
    712e:	0001                	nop

0000000000007130 <_out_char>:
    7130:	e111                	bnez	a0,7134 <_out_char+0x4>
    7132:	8082                	ret
    7134:	55fd                	li	a1,-1
    7136:	adaff06f          	j	6410 <fputc>
    713a:	00000013          	nop
    713e:	0001                	nop

0000000000007140 <_ftoa>:
    7140:	7135                	addi	sp,sp,-160
    7142:	f4d6                	sd	s5,104(sp)
    7144:	f8d2                	sd	s4,112(sp)
    7146:	8abe                	mv	s5,a5
    7148:	a2a527d3          	feq.d	a5,fa0,fa0
    714c:	fcce                	sd	s3,120(sp)
    714e:	e14a                	sd	s2,128(sp)
    7150:	e526                	sd	s1,136(sp)
    7152:	e922                	sd	s0,144(sp)
    7154:	e4e6                	sd	s9,72(sp)
    7156:	e8e2                	sd	s8,80(sp)
    7158:	ecde                	sd	s7,88(sp)
    715a:	f0da                	sd	s6,96(sp)
    715c:	ed06                	sd	ra,152(sp)
    715e:	842a                	mv	s0,a0
    7160:	84ae                	mv	s1,a1
    7162:	89b2                	mv	s3,a2
    7164:	8936                	mv	s2,a3
    7166:	8a42                	mv	s4,a6
    7168:	4e078c63          	beqz	a5,7660 <_ftoa+0x520>
    716c:	62c5                	lui	t0,0x11
    716e:	b982b787          	fld	fa5,-1128(t0) # 10b98 <errpat+0x50>
    7172:	a2f51353          	flt.d	t1,fa0,fa5
    7176:	520315e3          	bnez	t1,7ea0 <_ftoa+0xd60>
    717a:	63c5                	lui	t2,0x11
    717c:	ba03b007          	fld	ft0,-1120(t2) # 10ba0 <errpat+0x58>
    7180:	a2a01553          	flt.d	a0,ft0,fa0
    7184:	1a051a63          	bnez	a0,7338 <_ftoa+0x1f8>
    7188:	65c5                	lui	a1,0x11
    718a:	ba85b087          	fld	ft1,-1112(a1) # 10ba8 <errpat+0x60>
    718e:	e0ea                	sd	s10,64(sp)
    7190:	a2a09653          	flt.d	a2,ft1,fa0
    7194:	c219                	beqz	a2,719a <_ftoa+0x5a>
    7196:	2220106f          	j	83b8 <_ftoa+0x1278>
    719a:	66c5                	lui	a3,0x11
    719c:	bb06b107          	fld	ft2,-1104(a3) # 10bb0 <errpat+0x68>
    71a0:	a2251853          	flt.d	a6,fa0,ft2
    71a4:	00080463          	beqz	a6,71ac <_ftoa+0x6c>
    71a8:	0e50106f          	j	8a8c <_ftoa+0x194c>
    71ac:	f20001d3          	fmv.d.x	ft3,zero
    71b0:	a23518d3          	flt.d	a7,fa0,ft3
    71b4:	4801                	li	a6,0
    71b6:	4c089fe3          	bnez	a7,7e94 <_ftoa+0xd54>
    71ba:	400a7b13          	andi	s6,s4,1024
    71be:	4b99                	li	s7,6
    71c0:	416b970b          	th.mveqz	a4,s7,s6
    71c4:	4e81                	li	t4,0
    71c6:	fe070c9b          	addiw	s9,a4,-32
    71ca:	4f81                	li	t6,0
    71cc:	01010c13          	addi	s8,sp,16
    71d0:	4d25                	li	s10,9
    71d2:	03000e13          	li	t3,48
    71d6:	060e8063          	beqz	t4,7236 <_ftoa+0xf6>
    71da:	017e8863          	beq	t4,s7,71ea <_ftoa+0xaa>
    71de:	0ced7763          	bgeu	s10,a4,72ac <_ftoa+0x16c>
    71e2:	01cc0023          	sb	t3,0(s8)
    71e6:	377d                	addiw	a4,a4,-1
    71e8:	4f85                	li	t6,1
    71ea:	0ced7163          	bgeu	s10,a4,72ac <_ftoa+0x16c>
    71ee:	01fc5e0b          	th.srb	t3,s8,t6,0
    71f2:	377d                	addiw	a4,a4,-1
    71f4:	0f85                	addi	t6,t6,1
    71f6:	0aed7b63          	bgeu	s10,a4,72ac <_ftoa+0x16c>
    71fa:	01fc5e0b          	th.srb	t3,s8,t6,0
    71fe:	377d                	addiw	a4,a4,-1
    7200:	0f85                	addi	t6,t6,1
    7202:	0aed7563          	bgeu	s10,a4,72ac <_ftoa+0x16c>
    7206:	01fc5e0b          	th.srb	t3,s8,t6,0
    720a:	377d                	addiw	a4,a4,-1
    720c:	0f85                	addi	t6,t6,1
    720e:	08ed7f63          	bgeu	s10,a4,72ac <_ftoa+0x16c>
    7212:	01fc5e0b          	th.srb	t3,s8,t6,0
    7216:	377d                	addiw	a4,a4,-1
    7218:	0f85                	addi	t6,t6,1
    721a:	08ed7963          	bgeu	s10,a4,72ac <_ftoa+0x16c>
    721e:	01fc5e0b          	th.srb	t3,s8,t6,0
    7222:	377d                	addiw	a4,a4,-1
    7224:	0f85                	addi	t6,t6,1
    7226:	08ed7363          	bgeu	s10,a4,72ac <_ftoa+0x16c>
    722a:	01fc5e0b          	th.srb	t3,s8,t6,0
    722e:	377d                	addiw	a4,a4,-1
    7230:	0f85                	addi	t6,t6,1
    7232:	06ec8b63          	beq	s9,a4,72a8 <_ftoa+0x168>
    7236:	06ed7b63          	bgeu	s10,a4,72ac <_ftoa+0x16c>
    723a:	01fc5e0b          	th.srb	t3,s8,t6,0
    723e:	377d                	addiw	a4,a4,-1
    7240:	0f85                	addi	t6,t6,1
    7242:	8f7e                	mv	t5,t6
    7244:	06ed7463          	bgeu	s10,a4,72ac <_ftoa+0x16c>
    7248:	01fc5e0b          	th.srb	t3,s8,t6,0
    724c:	377d                	addiw	a4,a4,-1
    724e:	0f85                	addi	t6,t6,1
    7250:	04ed7e63          	bgeu	s10,a4,72ac <_ftoa+0x16c>
    7254:	01fc5e0b          	th.srb	t3,s8,t6,0
    7258:	377d                	addiw	a4,a4,-1
    725a:	002f0f93          	addi	t6,t5,2
    725e:	04ed7763          	bgeu	s10,a4,72ac <_ftoa+0x16c>
    7262:	01fc5e0b          	th.srb	t3,s8,t6,0
    7266:	377d                	addiw	a4,a4,-1
    7268:	003f0f93          	addi	t6,t5,3
    726c:	04ed7063          	bgeu	s10,a4,72ac <_ftoa+0x16c>
    7270:	01fc5e0b          	th.srb	t3,s8,t6,0
    7274:	377d                	addiw	a4,a4,-1
    7276:	004f0f93          	addi	t6,t5,4
    727a:	02ed7963          	bgeu	s10,a4,72ac <_ftoa+0x16c>
    727e:	01fc5e0b          	th.srb	t3,s8,t6,0
    7282:	377d                	addiw	a4,a4,-1
    7284:	005f0f93          	addi	t6,t5,5
    7288:	02ed7263          	bgeu	s10,a4,72ac <_ftoa+0x16c>
    728c:	01fc5e0b          	th.srb	t3,s8,t6,0
    7290:	377d                	addiw	a4,a4,-1
    7292:	006f0f93          	addi	t6,t5,6
    7296:	00ed7b63          	bgeu	s10,a4,72ac <_ftoa+0x16c>
    729a:	01fc5e0b          	th.srb	t3,s8,t6,0
    729e:	377d                	addiw	a4,a4,-1
    72a0:	007f0f93          	addi	t6,t5,7
    72a4:	f8ec99e3          	bne	s9,a4,7236 <_ftoa+0xf6>
    72a8:	02000f93          	li	t6,32
    72ac:	c20517d3          	fcvt.w.d	a5,fa0,rtz
    72b0:	62c5                	lui	t0,0x11
    72b2:	d2078253          	fcvt.d.w	ft4,a5
    72b6:	dc828313          	addi	t1,t0,-568 # 10dc8 <pow10.0>
    72ba:	76e3668b          	th.flurd	fa3,t1,a4,3
    72be:	0a4572d3          	fsub.d	ft5,fa0,ft4
    72c2:	63c5                	lui	t2,0x11
    72c4:	be03b587          	fld	fa1,-1056(t2) # 10be0 <errpat+0x98>
    72c8:	12d2f353          	fmul.d	ft6,ft5,fa3
    72cc:	0007859b          	sext.w	a1,a5
    72d0:	c23316d3          	fcvt.lu.d	a3,ft6,rtz
    72d4:	d236f753          	fcvt.d.lu	fa4,a3
    72d8:	0ae373d3          	fsub.d	ft7,ft6,fa4
    72dc:	a2759553          	flt.d	a0,fa1,ft7
    72e0:	62050663          	beqz	a0,790c <_ftoa+0x7cc>
    72e4:	0685                	addi	a3,a3,1
    72e6:	d236f653          	fcvt.d.lu	fa2,a3
    72ea:	a2c68b53          	fle.d	s6,fa3,fa2
    72ee:	000b0563          	beqz	s6,72f8 <_ftoa+0x1b8>
    72f2:	0017859b          	addiw	a1,a5,1
    72f6:	4681                	li	a3,0
    72f8:	62070463          	beqz	a4,7920 <_ftoa+0x7e0>
    72fc:	fe070b9b          	addiw	s7,a4,-32
    7300:	01fc0633          	add	a2,s8,t6
    7304:	01fb8d3b          	addw	s10,s7,t6
    7308:	4ca9                	li	s9,10
    730a:	4e25                	li	t3,9
    730c:	00000013          	nop
    7310:	00ed1463          	bne	s10,a4,7318 <_ftoa+0x1d8>
    7314:	09c0106f          	j	83b0 <_ftoa+0x1270>
    7318:	0396ff33          	remu	t5,a3,s9
    731c:	82b2                	mv	t0,a2
    731e:	377d                	addiw	a4,a4,-1
    7320:	8eba                	mv	t4,a4
    7322:	030f0f9b          	addiw	t6,t5,48
    7326:	1812df8b          	th.sbia	t6,(t0),1,0
    732a:	0396d7b3          	divu	a5,a3,s9
    732e:	78de77e3          	bgeu	t3,a3,82bc <_ftoa+0x117c>
    7332:	8616                	mv	a2,t0
    7334:	86be                	mv	a3,a5
    7336:	bfe9                	j	7310 <_ftoa+0x1d0>
    7338:	00487b13          	andi	s6,a6,4
    733c:	340b16e3          	bnez	s6,7e88 <_ftoa+0xd48>
    7340:	68c5                	lui	a7,0x11
    7342:	ad088b93          	addi	s7,a7,-1328 # 10ad0 <__errno+0x5a4>
    7346:	4c0d                	li	s8,3
    7348:	003a7393          	andi	t2,s4,3
    734c:	8b4e                	mv	s6,s3
    734e:	14039d63          	bnez	t2,74a8 <_ftoa+0x368>
    7352:	7c0abc8b          	th.extu	s9,s5,31,0
    7356:	159c7963          	bgeu	s8,s9,74a8 <_ftoa+0x368>
    735a:	fc6e                	sd	s11,56(sp)
    735c:	e0ea                	sd	s10,64(sp)
    735e:	413c0d33          	sub	s10,s8,s3
    7362:	fffd4713          	not	a4,s10
    7366:	01970e33          	add	t3,a4,s9
    736a:	413e0f33          	sub	t5,t3,s3
    736e:	86ca                	mv	a3,s2
    7370:	864e                	mv	a2,s3
    7372:	85a6                	mv	a1,s1
    7374:	02000513          	li	a0,32
    7378:	00198b13          	addi	s6,s3,1
    737c:	007f7d93          	andi	s11,t5,7
    7380:	9402                	jalr	s0
    7382:	016d0333          	add	t1,s10,s6
    7386:	11937b63          	bgeu	t1,s9,749c <_ftoa+0x35c>
    738a:	080d8963          	beqz	s11,741c <_ftoa+0x2dc>
    738e:	4805                	li	a6,1
    7390:	070d8b63          	beq	s11,a6,7406 <_ftoa+0x2c6>
    7394:	4509                	li	a0,2
    7396:	06ad8163          	beq	s11,a0,73f8 <_ftoa+0x2b8>
    739a:	428d                	li	t0,3
    739c:	045d8763          	beq	s11,t0,73ea <_ftoa+0x2aa>
    73a0:	4791                	li	a5,4
    73a2:	02fd8d63          	beq	s11,a5,73dc <_ftoa+0x29c>
    73a6:	4595                	li	a1,5
    73a8:	02bd8363          	beq	s11,a1,73ce <_ftoa+0x28e>
    73ac:	4e99                	li	t4,6
    73ae:	01dd8963          	beq	s11,t4,73c0 <_ftoa+0x280>
    73b2:	865a                	mv	a2,s6
    73b4:	86ca                	mv	a3,s2
    73b6:	85a6                	mv	a1,s1
    73b8:	02000513          	li	a0,32
    73bc:	0b05                	addi	s6,s6,1
    73be:	9402                	jalr	s0
    73c0:	865a                	mv	a2,s6
    73c2:	86ca                	mv	a3,s2
    73c4:	85a6                	mv	a1,s1
    73c6:	02000513          	li	a0,32
    73ca:	0b05                	addi	s6,s6,1
    73cc:	9402                	jalr	s0
    73ce:	865a                	mv	a2,s6
    73d0:	86ca                	mv	a3,s2
    73d2:	85a6                	mv	a1,s1
    73d4:	02000513          	li	a0,32
    73d8:	0b05                	addi	s6,s6,1
    73da:	9402                	jalr	s0
    73dc:	865a                	mv	a2,s6
    73de:	86ca                	mv	a3,s2
    73e0:	85a6                	mv	a1,s1
    73e2:	02000513          	li	a0,32
    73e6:	0b05                	addi	s6,s6,1
    73e8:	9402                	jalr	s0
    73ea:	865a                	mv	a2,s6
    73ec:	86ca                	mv	a3,s2
    73ee:	85a6                	mv	a1,s1
    73f0:	02000513          	li	a0,32
    73f4:	0b05                	addi	s6,s6,1
    73f6:	9402                	jalr	s0
    73f8:	865a                	mv	a2,s6
    73fa:	86ca                	mv	a3,s2
    73fc:	85a6                	mv	a1,s1
    73fe:	02000513          	li	a0,32
    7402:	0b05                	addi	s6,s6,1
    7404:	9402                	jalr	s0
    7406:	865a                	mv	a2,s6
    7408:	86ca                	mv	a3,s2
    740a:	85a6                	mv	a1,s1
    740c:	02000513          	li	a0,32
    7410:	0b05                	addi	s6,s6,1
    7412:	9402                	jalr	s0
    7414:	016d0633          	add	a2,s10,s6
    7418:	09967263          	bgeu	a2,s9,749c <_ftoa+0x35c>
    741c:	865a                	mv	a2,s6
    741e:	86ca                	mv	a3,s2
    7420:	85a6                	mv	a1,s1
    7422:	02000513          	li	a0,32
    7426:	9402                	jalr	s0
    7428:	001b0d93          	addi	s11,s6,1
    742c:	866e                	mv	a2,s11
    742e:	86ca                	mv	a3,s2
    7430:	85a6                	mv	a1,s1
    7432:	02000513          	li	a0,32
    7436:	9402                	jalr	s0
    7438:	002b0613          	addi	a2,s6,2
    743c:	86ca                	mv	a3,s2
    743e:	85a6                	mv	a1,s1
    7440:	02000513          	li	a0,32
    7444:	9402                	jalr	s0
    7446:	003b0d93          	addi	s11,s6,3
    744a:	866e                	mv	a2,s11
    744c:	86ca                	mv	a3,s2
    744e:	85a6                	mv	a1,s1
    7450:	02000513          	li	a0,32
    7454:	9402                	jalr	s0
    7456:	004b0613          	addi	a2,s6,4
    745a:	86ca                	mv	a3,s2
    745c:	85a6                	mv	a1,s1
    745e:	02000513          	li	a0,32
    7462:	9402                	jalr	s0
    7464:	005b0d93          	addi	s11,s6,5
    7468:	866e                	mv	a2,s11
    746a:	86ca                	mv	a3,s2
    746c:	85a6                	mv	a1,s1
    746e:	02000513          	li	a0,32
    7472:	9402                	jalr	s0
    7474:	006b0613          	addi	a2,s6,6
    7478:	86ca                	mv	a3,s2
    747a:	85a6                	mv	a1,s1
    747c:	02000513          	li	a0,32
    7480:	9402                	jalr	s0
    7482:	007b0d93          	addi	s11,s6,7
    7486:	866e                	mv	a2,s11
    7488:	86ca                	mv	a3,s2
    748a:	85a6                	mv	a1,s1
    748c:	02000513          	li	a0,32
    7490:	0b21                	addi	s6,s6,8
    7492:	9402                	jalr	s0
    7494:	016d0633          	add	a2,s10,s6
    7498:	f99662e3          	bltu	a2,s9,741c <_ftoa+0x2dc>
    749c:	7de2                	ld	s11,56(sp)
    749e:	6d06                	ld	s10,64(sp)
    74a0:	019986b3          	add	a3,s3,s9
    74a4:	41868b33          	sub	s6,a3,s8
    74a8:	018b8cb3          	add	s9,s7,s8
    74ac:	fffcc503          	lbu	a0,-1(s9)
    74b0:	86ca                	mv	a3,s2
    74b2:	865a                	mv	a2,s6
    74b4:	85a6                	mv	a1,s1
    74b6:	9402                	jalr	s0
    74b8:	ffecc503          	lbu	a0,-2(s9)
    74bc:	86ca                	mv	a3,s2
    74be:	001b0613          	addi	a2,s6,1
    74c2:	85a6                	mv	a1,s1
    74c4:	9402                	jalr	s0
    74c6:	ffdc0c93          	addi	s9,s8,-3
    74ca:	819bc50b          	th.lrbu	a0,s7,s9,0
    74ce:	86ca                	mv	a3,s2
    74d0:	002b0613          	addi	a2,s6,2
    74d4:	85a6                	mv	a1,s1
    74d6:	9402                	jalr	s0
    74d8:	000c8963          	beqz	s9,74ea <_ftoa+0x3aa>
    74dc:	000bc503          	lbu	a0,0(s7)
    74e0:	86ca                	mv	a3,s2
    74e2:	003b0613          	addi	a2,s6,3
    74e6:	85a6                	mv	a1,s1
    74e8:	9402                	jalr	s0
    74ea:	002a7a13          	andi	s4,s4,2
    74ee:	9b62                	add	s6,s6,s8
    74f0:	140a0963          	beqz	s4,7642 <_ftoa+0x502>
    74f4:	413b09b3          	sub	s3,s6,s3
    74f8:	7c0aba8b          	th.extu	s5,s5,31,0
    74fc:	1559f363          	bgeu	s3,s5,7642 <_ftoa+0x502>
    7500:	fff9c893          	not	a7,s3
    7504:	01588bb3          	add	s7,a7,s5
    7508:	865a                	mv	a2,s6
    750a:	86ca                	mv	a3,s2
    750c:	85a6                	mv	a1,s1
    750e:	02000513          	li	a0,32
    7512:	00198c93          	addi	s9,s3,1
    7516:	007bfc13          	andi	s8,s7,7
    751a:	0b05                	addi	s6,s6,1
    751c:	9402                	jalr	s0
    751e:	135cf263          	bgeu	s9,s5,7642 <_ftoa+0x502>
    7522:	080c0e63          	beqz	s8,75be <_ftoa+0x47e>
    7526:	4f85                	li	t6,1
    7528:	09fc0163          	beq	s8,t6,75aa <_ftoa+0x46a>
    752c:	4389                	li	t2,2
    752e:	067c0663          	beq	s8,t2,759a <_ftoa+0x45a>
    7532:	470d                	li	a4,3
    7534:	04ec0b63          	beq	s8,a4,758a <_ftoa+0x44a>
    7538:	4e11                	li	t3,4
    753a:	05cc0063          	beq	s8,t3,757a <_ftoa+0x43a>
    753e:	4f15                	li	t5,5
    7540:	03ec0563          	beq	s8,t5,756a <_ftoa+0x42a>
    7544:	4319                	li	t1,6
    7546:	006c0a63          	beq	s8,t1,755a <_ftoa+0x41a>
    754a:	865a                	mv	a2,s6
    754c:	86ca                	mv	a3,s2
    754e:	85a6                	mv	a1,s1
    7550:	02000513          	li	a0,32
    7554:	0b05                	addi	s6,s6,1
    7556:	9402                	jalr	s0
    7558:	0c85                	addi	s9,s9,1
    755a:	865a                	mv	a2,s6
    755c:	86ca                	mv	a3,s2
    755e:	85a6                	mv	a1,s1
    7560:	02000513          	li	a0,32
    7564:	0b05                	addi	s6,s6,1
    7566:	9402                	jalr	s0
    7568:	0c85                	addi	s9,s9,1
    756a:	865a                	mv	a2,s6
    756c:	86ca                	mv	a3,s2
    756e:	85a6                	mv	a1,s1
    7570:	02000513          	li	a0,32
    7574:	0b05                	addi	s6,s6,1
    7576:	9402                	jalr	s0
    7578:	0c85                	addi	s9,s9,1
    757a:	865a                	mv	a2,s6
    757c:	86ca                	mv	a3,s2
    757e:	85a6                	mv	a1,s1
    7580:	02000513          	li	a0,32
    7584:	0b05                	addi	s6,s6,1
    7586:	9402                	jalr	s0
    7588:	0c85                	addi	s9,s9,1
    758a:	865a                	mv	a2,s6
    758c:	86ca                	mv	a3,s2
    758e:	85a6                	mv	a1,s1
    7590:	02000513          	li	a0,32
    7594:	0b05                	addi	s6,s6,1
    7596:	9402                	jalr	s0
    7598:	0c85                	addi	s9,s9,1
    759a:	865a                	mv	a2,s6
    759c:	86ca                	mv	a3,s2
    759e:	85a6                	mv	a1,s1
    75a0:	02000513          	li	a0,32
    75a4:	0b05                	addi	s6,s6,1
    75a6:	9402                	jalr	s0
    75a8:	0c85                	addi	s9,s9,1
    75aa:	865a                	mv	a2,s6
    75ac:	86ca                	mv	a3,s2
    75ae:	85a6                	mv	a1,s1
    75b0:	02000513          	li	a0,32
    75b4:	0c85                	addi	s9,s9,1
    75b6:	0b05                	addi	s6,s6,1
    75b8:	9402                	jalr	s0
    75ba:	095cf463          	bgeu	s9,s5,7642 <_ftoa+0x502>
    75be:	865a                	mv	a2,s6
    75c0:	86ca                	mv	a3,s2
    75c2:	85a6                	mv	a1,s1
    75c4:	02000513          	li	a0,32
    75c8:	9402                	jalr	s0
    75ca:	001b0a13          	addi	s4,s6,1
    75ce:	8652                	mv	a2,s4
    75d0:	86ca                	mv	a3,s2
    75d2:	85a6                	mv	a1,s1
    75d4:	02000513          	li	a0,32
    75d8:	9402                	jalr	s0
    75da:	002b0993          	addi	s3,s6,2
    75de:	864e                	mv	a2,s3
    75e0:	86ca                	mv	a3,s2
    75e2:	85a6                	mv	a1,s1
    75e4:	02000513          	li	a0,32
    75e8:	9402                	jalr	s0
    75ea:	003b0c13          	addi	s8,s6,3
    75ee:	8662                	mv	a2,s8
    75f0:	86ca                	mv	a3,s2
    75f2:	85a6                	mv	a1,s1
    75f4:	02000513          	li	a0,32
    75f8:	9402                	jalr	s0
    75fa:	004b0b93          	addi	s7,s6,4
    75fe:	86ca                	mv	a3,s2
    7600:	865e                	mv	a2,s7
    7602:	85a6                	mv	a1,s1
    7604:	02000513          	li	a0,32
    7608:	9402                	jalr	s0
    760a:	005b0a13          	addi	s4,s6,5
    760e:	86ca                	mv	a3,s2
    7610:	8652                	mv	a2,s4
    7612:	85a6                	mv	a1,s1
    7614:	02000513          	li	a0,32
    7618:	9402                	jalr	s0
    761a:	006b0993          	addi	s3,s6,6
    761e:	86ca                	mv	a3,s2
    7620:	864e                	mv	a2,s3
    7622:	85a6                	mv	a1,s1
    7624:	02000513          	li	a0,32
    7628:	9402                	jalr	s0
    762a:	007b0c13          	addi	s8,s6,7
    762e:	86ca                	mv	a3,s2
    7630:	8662                	mv	a2,s8
    7632:	85a6                	mv	a1,s1
    7634:	02000513          	li	a0,32
    7638:	0ca1                	addi	s9,s9,8
    763a:	0b21                	addi	s6,s6,8
    763c:	9402                	jalr	s0
    763e:	f95ce0e3          	bltu	s9,s5,75be <_ftoa+0x47e>
    7642:	64aa                	ld	s1,136(sp)
    7644:	644a                	ld	s0,144(sp)
    7646:	60ea                	ld	ra,152(sp)
    7648:	6ca6                	ld	s9,72(sp)
    764a:	6c46                	ld	s8,80(sp)
    764c:	7aa6                	ld	s5,104(sp)
    764e:	7a46                	ld	s4,112(sp)
    7650:	79e6                	ld	s3,120(sp)
    7652:	690a                	ld	s2,128(sp)
    7654:	855a                	mv	a0,s6
    7656:	6be6                	ld	s7,88(sp)
    7658:	7b06                	ld	s6,96(sp)
    765a:	610d                	addi	sp,sp,160
    765c:	8082                	ret
    765e:	0001                	nop
    7660:	00387893          	andi	a7,a6,3
    7664:	8cb2                	mv	s9,a2
    7666:	12089563          	bnez	a7,7790 <_ftoa+0x650>
    766a:	438d                	li	t2,3
    766c:	7c0abf8b          	th.extu	t6,s5,31,0
    7670:	1353f063          	bgeu	t2,s5,7790 <_ftoa+0x650>
    7674:	ffd60713          	addi	a4,a2,-3
    7678:	01f70cb3          	add	s9,a4,t6
    767c:	40cc8e33          	sub	t3,s9,a2
    7680:	007e7f13          	andi	t5,t3,7
    7684:	8b32                	mv	s6,a2
    7686:	080f0463          	beqz	t5,770e <_ftoa+0x5ce>
    768a:	4305                	li	t1,1
    768c:	066f0863          	beq	t5,t1,76fc <_ftoa+0x5bc>
    7690:	4809                	li	a6,2
    7692:	050f0e63          	beq	t5,a6,76ee <_ftoa+0x5ae>
    7696:	047f0563          	beq	t5,t2,76e0 <_ftoa+0x5a0>
    769a:	4511                	li	a0,4
    769c:	02af0b63          	beq	t5,a0,76d2 <_ftoa+0x592>
    76a0:	4295                	li	t0,5
    76a2:	025f0163          	beq	t5,t0,76c4 <_ftoa+0x584>
    76a6:	4799                	li	a5,6
    76a8:	00ff0763          	beq	t5,a5,76b6 <_ftoa+0x576>
    76ac:	02000513          	li	a0,32
    76b0:	00160b13          	addi	s6,a2,1
    76b4:	9402                	jalr	s0
    76b6:	865a                	mv	a2,s6
    76b8:	86ca                	mv	a3,s2
    76ba:	85a6                	mv	a1,s1
    76bc:	02000513          	li	a0,32
    76c0:	0b05                	addi	s6,s6,1
    76c2:	9402                	jalr	s0
    76c4:	865a                	mv	a2,s6
    76c6:	86ca                	mv	a3,s2
    76c8:	85a6                	mv	a1,s1
    76ca:	02000513          	li	a0,32
    76ce:	0b05                	addi	s6,s6,1
    76d0:	9402                	jalr	s0
    76d2:	865a                	mv	a2,s6
    76d4:	86ca                	mv	a3,s2
    76d6:	85a6                	mv	a1,s1
    76d8:	02000513          	li	a0,32
    76dc:	0b05                	addi	s6,s6,1
    76de:	9402                	jalr	s0
    76e0:	865a                	mv	a2,s6
    76e2:	86ca                	mv	a3,s2
    76e4:	85a6                	mv	a1,s1
    76e6:	02000513          	li	a0,32
    76ea:	0b05                	addi	s6,s6,1
    76ec:	9402                	jalr	s0
    76ee:	865a                	mv	a2,s6
    76f0:	86ca                	mv	a3,s2
    76f2:	85a6                	mv	a1,s1
    76f4:	02000513          	li	a0,32
    76f8:	0b05                	addi	s6,s6,1
    76fa:	9402                	jalr	s0
    76fc:	865a                	mv	a2,s6
    76fe:	86ca                	mv	a3,s2
    7700:	0b05                	addi	s6,s6,1
    7702:	85a6                	mv	a1,s1
    7704:	02000513          	li	a0,32
    7708:	9402                	jalr	s0
    770a:	099b0363          	beq	s6,s9,7790 <_ftoa+0x650>
    770e:	865a                	mv	a2,s6
    7710:	86ca                	mv	a3,s2
    7712:	85a6                	mv	a1,s1
    7714:	02000513          	li	a0,32
    7718:	9402                	jalr	s0
    771a:	001b0b93          	addi	s7,s6,1
    771e:	865e                	mv	a2,s7
    7720:	86ca                	mv	a3,s2
    7722:	85a6                	mv	a1,s1
    7724:	02000513          	li	a0,32
    7728:	9402                	jalr	s0
    772a:	002b0c13          	addi	s8,s6,2
    772e:	8662                	mv	a2,s8
    7730:	86ca                	mv	a3,s2
    7732:	85a6                	mv	a1,s1
    7734:	02000513          	li	a0,32
    7738:	9402                	jalr	s0
    773a:	003b0b93          	addi	s7,s6,3
    773e:	865e                	mv	a2,s7
    7740:	86ca                	mv	a3,s2
    7742:	85a6                	mv	a1,s1
    7744:	02000513          	li	a0,32
    7748:	9402                	jalr	s0
    774a:	004b0c13          	addi	s8,s6,4
    774e:	8662                	mv	a2,s8
    7750:	86ca                	mv	a3,s2
    7752:	85a6                	mv	a1,s1
    7754:	02000513          	li	a0,32
    7758:	9402                	jalr	s0
    775a:	005b0b93          	addi	s7,s6,5
    775e:	865e                	mv	a2,s7
    7760:	86ca                	mv	a3,s2
    7762:	85a6                	mv	a1,s1
    7764:	02000513          	li	a0,32
    7768:	9402                	jalr	s0
    776a:	006b0c13          	addi	s8,s6,6
    776e:	86ca                	mv	a3,s2
    7770:	8662                	mv	a2,s8
    7772:	85a6                	mv	a1,s1
    7774:	02000513          	li	a0,32
    7778:	9402                	jalr	s0
    777a:	007b0b93          	addi	s7,s6,7
    777e:	86ca                	mv	a3,s2
    7780:	0b21                	addi	s6,s6,8
    7782:	865e                	mv	a2,s7
    7784:	85a6                	mv	a1,s1
    7786:	02000513          	li	a0,32
    778a:	9402                	jalr	s0
    778c:	f99b11e3          	bne	s6,s9,770e <_ftoa+0x5ce>
    7790:	4b8d                	li	s7,3
    7792:	65c5                	lui	a1,0x11
    7794:	9cde                	add	s9,s9,s7
    7796:	ad858c13          	addi	s8,a1,-1320 # 10ad8 <__errno+0x5ac>
    779a:	0001                	nop
    779c:	00000013          	nop
    77a0:	417c8633          	sub	a2,s9,s7
    77a4:	1bfd                	addi	s7,s7,-1
    77a6:	817c450b          	th.lrbu	a0,s8,s7,0
    77aa:	86ca                	mv	a3,s2
    77ac:	85a6                	mv	a1,s1
    77ae:	8b66                	mv	s6,s9
    77b0:	9402                	jalr	s0
    77b2:	fe0b97e3          	bnez	s7,77a0 <_ftoa+0x660>
    77b6:	002a7e93          	andi	t4,s4,2
    77ba:	e80e84e3          	beqz	t4,7642 <_ftoa+0x502>
    77be:	7c0aba8b          	th.extu	s5,s5,31,0
    77c2:	413c8633          	sub	a2,s9,s3
    77c6:	e7567ee3          	bgeu	a2,s5,7642 <_ftoa+0x502>
    77ca:	fffcc693          	not	a3,s9
    77ce:	01568a33          	add	s4,a3,s5
    77d2:	013a08b3          	add	a7,s4,s3
    77d6:	86ca                	mv	a3,s2
    77d8:	8666                	mv	a2,s9
    77da:	85a6                	mv	a1,s1
    77dc:	02000513          	li	a0,32
    77e0:	0078fb93          	andi	s7,a7,7
    77e4:	001c8b13          	addi	s6,s9,1
    77e8:	9402                	jalr	s0
    77ea:	413b0fb3          	sub	t6,s6,s3
    77ee:	e55ffae3          	bgeu	t6,s5,7642 <_ftoa+0x502>
    77f2:	080b8963          	beqz	s7,7884 <_ftoa+0x744>
    77f6:	4385                	li	t2,1
    77f8:	067b8b63          	beq	s7,t2,786e <_ftoa+0x72e>
    77fc:	4709                	li	a4,2
    77fe:	06eb8163          	beq	s7,a4,7860 <_ftoa+0x720>
    7802:	4e0d                	li	t3,3
    7804:	05cb8763          	beq	s7,t3,7852 <_ftoa+0x712>
    7808:	4f11                	li	t5,4
    780a:	03eb8d63          	beq	s7,t5,7844 <_ftoa+0x704>
    780e:	4315                	li	t1,5
    7810:	026b8363          	beq	s7,t1,7836 <_ftoa+0x6f6>
    7814:	4819                	li	a6,6
    7816:	010b8963          	beq	s7,a6,7828 <_ftoa+0x6e8>
    781a:	865a                	mv	a2,s6
    781c:	86ca                	mv	a3,s2
    781e:	85a6                	mv	a1,s1
    7820:	02000513          	li	a0,32
    7824:	0b05                	addi	s6,s6,1
    7826:	9402                	jalr	s0
    7828:	865a                	mv	a2,s6
    782a:	86ca                	mv	a3,s2
    782c:	85a6                	mv	a1,s1
    782e:	02000513          	li	a0,32
    7832:	0b05                	addi	s6,s6,1
    7834:	9402                	jalr	s0
    7836:	865a                	mv	a2,s6
    7838:	86ca                	mv	a3,s2
    783a:	85a6                	mv	a1,s1
    783c:	02000513          	li	a0,32
    7840:	0b05                	addi	s6,s6,1
    7842:	9402                	jalr	s0
    7844:	865a                	mv	a2,s6
    7846:	86ca                	mv	a3,s2
    7848:	85a6                	mv	a1,s1
    784a:	02000513          	li	a0,32
    784e:	0b05                	addi	s6,s6,1
    7850:	9402                	jalr	s0
    7852:	865a                	mv	a2,s6
    7854:	86ca                	mv	a3,s2
    7856:	85a6                	mv	a1,s1
    7858:	02000513          	li	a0,32
    785c:	0b05                	addi	s6,s6,1
    785e:	9402                	jalr	s0
    7860:	865a                	mv	a2,s6
    7862:	86ca                	mv	a3,s2
    7864:	85a6                	mv	a1,s1
    7866:	02000513          	li	a0,32
    786a:	0b05                	addi	s6,s6,1
    786c:	9402                	jalr	s0
    786e:	865a                	mv	a2,s6
    7870:	02000513          	li	a0,32
    7874:	86ca                	mv	a3,s2
    7876:	85a6                	mv	a1,s1
    7878:	0b05                	addi	s6,s6,1
    787a:	9402                	jalr	s0
    787c:	413b0533          	sub	a0,s6,s3
    7880:	dd5571e3          	bgeu	a0,s5,7642 <_ftoa+0x502>
    7884:	865a                	mv	a2,s6
    7886:	86ca                	mv	a3,s2
    7888:	85a6                	mv	a1,s1
    788a:	02000513          	li	a0,32
    788e:	9402                	jalr	s0
    7890:	001b0c93          	addi	s9,s6,1
    7894:	8666                	mv	a2,s9
    7896:	86ca                	mv	a3,s2
    7898:	85a6                	mv	a1,s1
    789a:	02000513          	li	a0,32
    789e:	9402                	jalr	s0
    78a0:	002b0c13          	addi	s8,s6,2
    78a4:	8662                	mv	a2,s8
    78a6:	86ca                	mv	a3,s2
    78a8:	85a6                	mv	a1,s1
    78aa:	02000513          	li	a0,32
    78ae:	9402                	jalr	s0
    78b0:	003b0a13          	addi	s4,s6,3
    78b4:	8652                	mv	a2,s4
    78b6:	86ca                	mv	a3,s2
    78b8:	85a6                	mv	a1,s1
    78ba:	02000513          	li	a0,32
    78be:	9402                	jalr	s0
    78c0:	004b0b93          	addi	s7,s6,4
    78c4:	86ca                	mv	a3,s2
    78c6:	865e                	mv	a2,s7
    78c8:	85a6                	mv	a1,s1
    78ca:	02000513          	li	a0,32
    78ce:	9402                	jalr	s0
    78d0:	005b0c93          	addi	s9,s6,5
    78d4:	86ca                	mv	a3,s2
    78d6:	8666                	mv	a2,s9
    78d8:	85a6                	mv	a1,s1
    78da:	02000513          	li	a0,32
    78de:	9402                	jalr	s0
    78e0:	006b0c13          	addi	s8,s6,6
    78e4:	86ca                	mv	a3,s2
    78e6:	8662                	mv	a2,s8
    78e8:	85a6                	mv	a1,s1
    78ea:	02000513          	li	a0,32
    78ee:	9402                	jalr	s0
    78f0:	007b0a13          	addi	s4,s6,7
    78f4:	02000513          	li	a0,32
    78f8:	86ca                	mv	a3,s2
    78fa:	8652                	mv	a2,s4
    78fc:	85a6                	mv	a1,s1
    78fe:	0b21                	addi	s6,s6,8
    7900:	9402                	jalr	s0
    7902:	413b0533          	sub	a0,s6,s3
    7906:	f7556fe3          	bltu	a0,s5,7884 <_ftoa+0x744>
    790a:	bb25                	j	7642 <_ftoa+0x502>
    790c:	a2b39653          	flt.d	a2,ft7,fa1
    7910:	9e0614e3          	bnez	a2,72f8 <_ftoa+0x1b8>
    7914:	c299                	beqz	a3,791a <_ftoa+0x7da>
    7916:	1120106f          	j	8a28 <_ftoa+0x18e8>
    791a:	0685                	addi	a3,a3,1
    791c:	9e0710e3          	bnez	a4,72fc <_ftoa+0x1bc>
    7920:	d2058853          	fcvt.d.w	fa6,a1
    7924:	be03b887          	fld	fa7,-1056(t2)
    7928:	0b057553          	fsub.d	fa0,fa0,fa6
    792c:	0015839b          	addiw	t2,a1,1
    7930:	ffe3fb13          	andi	s6,t2,-2
    7934:	a3151e53          	flt.d	t3,fa0,fa7
    7938:	000b089b          	sext.w	a7,s6
    793c:	41c8958b          	th.mveqz	a1,a7,t3
    7940:	01fc07b3          	add	a5,s8,t6
    7944:	03010f13          	addi	t5,sp,48
    7948:	40ff0633          	sub	a2,t5,a5
    794c:	00767693          	andi	a3,a2,7
    7950:	4ea9                	li	t4,10
    7952:	c6f9                	beqz	a3,7a20 <_ftoa+0x8e0>
    7954:	03d5efbb          	remw	t6,a1,t4
    7958:	873e                	mv	a4,a5
    795a:	03d5c5bb          	divw	a1,a1,t4
    795e:	030f831b          	addiw	t1,t6,48
    7962:	1817530b          	th.sbia	t1,(a4),1,0
    7966:	7e058963          	beqz	a1,8158 <_ftoa+0x1018>
    796a:	4505                	li	a0,1
    796c:	87ba                	mv	a5,a4
    796e:	0aa68963          	beq	a3,a0,7a20 <_ftoa+0x8e0>
    7972:	4b89                	li	s7,2
    7974:	09768a63          	beq	a3,s7,7a08 <_ftoa+0x8c8>
    7978:	4c8d                	li	s9,3
    797a:	07968b63          	beq	a3,s9,79f0 <_ftoa+0x8b0>
    797e:	4d11                	li	s10,4
    7980:	05a68c63          	beq	a3,s10,79d8 <_ftoa+0x898>
    7984:	4295                	li	t0,5
    7986:	02568d63          	beq	a3,t0,79c0 <_ftoa+0x880>
    798a:	4399                	li	t2,6
    798c:	00768e63          	beq	a3,t2,79a8 <_ftoa+0x868>
    7990:	03d5eb3b          	remw	s6,a1,t4
    7994:	8e3a                	mv	t3,a4
    7996:	03d5c5bb          	divw	a1,a1,t4
    799a:	030b089b          	addiw	a7,s6,48
    799e:	181e588b          	th.sbia	a7,(t3),1,0
    79a2:	7a058b63          	beqz	a1,8158 <_ftoa+0x1018>
    79a6:	87f2                	mv	a5,t3
    79a8:	03d5ef3b          	remw	t5,a1,t4
    79ac:	863e                	mv	a2,a5
    79ae:	03d5c5bb          	divw	a1,a1,t4
    79b2:	030f069b          	addiw	a3,t5,48
    79b6:	1816568b          	th.sbia	a3,(a2),1,0
    79ba:	78058f63          	beqz	a1,8158 <_ftoa+0x1018>
    79be:	87b2                	mv	a5,a2
    79c0:	03d5efbb          	remw	t6,a1,t4
    79c4:	873e                	mv	a4,a5
    79c6:	03d5c5bb          	divw	a1,a1,t4
    79ca:	030f831b          	addiw	t1,t6,48
    79ce:	1817530b          	th.sbia	t1,(a4),1,0
    79d2:	78058363          	beqz	a1,8158 <_ftoa+0x1018>
    79d6:	87ba                	mv	a5,a4
    79d8:	03d5e53b          	remw	a0,a1,t4
    79dc:	8cbe                	mv	s9,a5
    79de:	03d5c5bb          	divw	a1,a1,t4
    79e2:	03050b9b          	addiw	s7,a0,48
    79e6:	181cdb8b          	th.sbia	s7,(s9),1,0
    79ea:	76058763          	beqz	a1,8158 <_ftoa+0x1018>
    79ee:	87e6                	mv	a5,s9
    79f0:	03d5ed3b          	remw	s10,a1,t4
    79f4:	83be                	mv	t2,a5
    79f6:	03d5c5bb          	divw	a1,a1,t4
    79fa:	030d029b          	addiw	t0,s10,48
    79fe:	1813d28b          	th.sbia	t0,(t2),1,0
    7a02:	74058b63          	beqz	a1,8158 <_ftoa+0x1018>
    7a06:	879e                	mv	a5,t2
    7a08:	03d5eb3b          	remw	s6,a1,t4
    7a0c:	8e3e                	mv	t3,a5
    7a0e:	03d5c5bb          	divw	a1,a1,t4
    7a12:	030b089b          	addiw	a7,s6,48
    7a16:	181e588b          	th.sbia	a7,(t3),1,0
    7a1a:	72058f63          	beqz	a1,8158 <_ftoa+0x1018>
    7a1e:	87f2                	mv	a5,t3
    7a20:	03010f13          	addi	t5,sp,48
    7a24:	0cff0463          	beq	t5,a5,7aec <_ftoa+0x9ac>
    7a28:	03d5e6bb          	remw	a3,a1,t4
    7a2c:	863e                	mv	a2,a5
    7a2e:	03d5c73b          	divw	a4,a1,t4
    7a32:	0306831b          	addiw	t1,a3,48
    7a36:	1816530b          	th.sbia	t1,(a2),1,0
    7a3a:	70070f63          	beqz	a4,8158 <_ftoa+0x1018>
    7a3e:	03d7653b          	remw	a0,a4,t4
    7a42:	87b2                	mv	a5,a2
    7a44:	03d74cbb          	divw	s9,a4,t4
    7a48:	03050b9b          	addiw	s7,a0,48
    7a4c:	01760023          	sb	s7,0(a2)
    7a50:	700c8463          	beqz	s9,8158 <_ftoa+0x1018>
    7a54:	03dced3b          	remw	s10,s9,t4
    7a58:	03dcc3bb          	divw	t2,s9,t4
    7a5c:	030d029b          	addiw	t0,s10,48
    7a60:	0817d28b          	th.sbib	t0,(a5),1,0
    7a64:	6e038a63          	beqz	t2,8158 <_ftoa+0x1018>
    7a68:	03d3eb3b          	remw	s6,t2,t4
    7a6c:	00260793          	addi	a5,a2,2
    7a70:	03d3ce3b          	divw	t3,t2,t4
    7a74:	030b089b          	addiw	a7,s6,48
    7a78:	01160123          	sb	a7,2(a2)
    7a7c:	6c0e0e63          	beqz	t3,8158 <_ftoa+0x1018>
    7a80:	03de6f3b          	remw	t5,t3,t4
    7a84:	00360793          	addi	a5,a2,3
    7a88:	03de4fbb          	divw	t6,t3,t4
    7a8c:	030f059b          	addiw	a1,t5,48
    7a90:	00b601a3          	sb	a1,3(a2)
    7a94:	6c0f8263          	beqz	t6,8158 <_ftoa+0x1018>
    7a98:	03dfe6bb          	remw	a3,t6,t4
    7a9c:	00460793          	addi	a5,a2,4
    7aa0:	03dfc73b          	divw	a4,t6,t4
    7aa4:	0306831b          	addiw	t1,a3,48
    7aa8:	00660223          	sb	t1,4(a2)
    7aac:	6a070663          	beqz	a4,8158 <_ftoa+0x1018>
    7ab0:	03d7653b          	remw	a0,a4,t4
    7ab4:	00560793          	addi	a5,a2,5
    7ab8:	03d74cbb          	divw	s9,a4,t4
    7abc:	03050b9b          	addiw	s7,a0,48
    7ac0:	017602a3          	sb	s7,5(a2)
    7ac4:	680c8a63          	beqz	s9,8158 <_ftoa+0x1018>
    7ac8:	03dced3b          	remw	s10,s9,t4
    7acc:	00660793          	addi	a5,a2,6
    7ad0:	03dcc5bb          	divw	a1,s9,t4
    7ad4:	030d029b          	addiw	t0,s10,48
    7ad8:	00560323          	sb	t0,6(a2)
    7adc:	66058e63          	beqz	a1,8158 <_ftoa+0x1018>
    7ae0:	00760793          	addi	a5,a2,7
    7ae4:	03010f13          	addi	t5,sp,48
    7ae8:	f4ff10e3          	bne	t5,a5,7a28 <_ftoa+0x8e8>
    7aec:	003a7593          	andi	a1,s4,3
    7af0:	4785                	li	a5,1
    7af2:	78f599e3          	bne	a1,a5,8a84 <_ftoa+0x1944>
    7af6:	6e0a87e3          	beqz	s5,89e4 <_ftoa+0x18a4>
    7afa:	78080fe3          	beqz	a6,8a98 <_ftoa+0x1958>
    7afe:	3afd                	addiw	s5,s5,-1
    7b00:	02000b13          	li	s6,32
    7b04:	7c0abf8b          	th.extu	t6,s5,31,0
    7b08:	115b7363          	bgeu	s6,s5,7c0e <_ftoa+0xace>
    7b0c:	02000293          	li	t0,32
    7b10:	416287b3          	sub	a5,t0,s6
    7b14:	0077fe93          	andi	t4,a5,7
    7b18:	016c0733          	add	a4,s8,s6
    7b1c:	03000593          	li	a1,48
    7b20:	060e8763          	beqz	t4,7b8e <_ftoa+0xa4e>
    7b24:	0b05                	addi	s6,s6,1
    7b26:	1817558b          	th.sbia	a1,(a4),1,0
    7b2a:	0dfb0763          	beq	s6,t6,7bf8 <_ftoa+0xab8>
    7b2e:	4605                	li	a2,1
    7b30:	04ce8f63          	beq	t4,a2,7b8e <_ftoa+0xa4e>
    7b34:	4389                	li	t2,2
    7b36:	047e8763          	beq	t4,t2,7b84 <_ftoa+0xa44>
    7b3a:	488d                	li	a7,3
    7b3c:	031e8f63          	beq	t4,a7,7b7a <_ftoa+0xa3a>
    7b40:	4e11                	li	t3,4
    7b42:	03ce8763          	beq	t4,t3,7b70 <_ftoa+0xa30>
    7b46:	4f15                	li	t5,5
    7b48:	01ee8f63          	beq	t4,t5,7b66 <_ftoa+0xa26>
    7b4c:	4319                	li	t1,6
    7b4e:	006e8763          	beq	t4,t1,7b5c <_ftoa+0xa1c>
    7b52:	0b05                	addi	s6,s6,1
    7b54:	1817558b          	th.sbia	a1,(a4),1,0
    7b58:	0bfb0063          	beq	s6,t6,7bf8 <_ftoa+0xab8>
    7b5c:	0b05                	addi	s6,s6,1
    7b5e:	1817558b          	th.sbia	a1,(a4),1,0
    7b62:	09fb0b63          	beq	s6,t6,7bf8 <_ftoa+0xab8>
    7b66:	0b05                	addi	s6,s6,1
    7b68:	1817558b          	th.sbia	a1,(a4),1,0
    7b6c:	09fb0663          	beq	s6,t6,7bf8 <_ftoa+0xab8>
    7b70:	0b05                	addi	s6,s6,1
    7b72:	1817558b          	th.sbia	a1,(a4),1,0
    7b76:	09fb0163          	beq	s6,t6,7bf8 <_ftoa+0xab8>
    7b7a:	0b05                	addi	s6,s6,1
    7b7c:	1817558b          	th.sbia	a1,(a4),1,0
    7b80:	07fb0c63          	beq	s6,t6,7bf8 <_ftoa+0xab8>
    7b84:	0b05                	addi	s6,s6,1
    7b86:	1817558b          	th.sbia	a1,(a4),1,0
    7b8a:	07fb0763          	beq	s6,t6,7bf8 <_ftoa+0xab8>
    7b8e:	6e5b05e3          	beq	s6,t0,8a78 <_ftoa+0x1938>
    7b92:	0b05                	addi	s6,s6,1
    7b94:	00b70023          	sb	a1,0(a4)
    7b98:	86da                	mv	a3,s6
    7b9a:	05fb0f63          	beq	s6,t6,7bf8 <_ftoa+0xab8>
    7b9e:	0b05                	addi	s6,s6,1
    7ba0:	00b700a3          	sb	a1,1(a4)
    7ba4:	05fb0a63          	beq	s6,t6,7bf8 <_ftoa+0xab8>
    7ba8:	00268b13          	addi	s6,a3,2
    7bac:	00b70123          	sb	a1,2(a4)
    7bb0:	05fb0463          	beq	s6,t6,7bf8 <_ftoa+0xab8>
    7bb4:	00368b13          	addi	s6,a3,3
    7bb8:	00b701a3          	sb	a1,3(a4)
    7bbc:	03fb0e63          	beq	s6,t6,7bf8 <_ftoa+0xab8>
    7bc0:	00468b13          	addi	s6,a3,4
    7bc4:	00b70223          	sb	a1,4(a4)
    7bc8:	03fb0863          	beq	s6,t6,7bf8 <_ftoa+0xab8>
    7bcc:	00568b13          	addi	s6,a3,5
    7bd0:	00b702a3          	sb	a1,5(a4)
    7bd4:	03fb0263          	beq	s6,t6,7bf8 <_ftoa+0xab8>
    7bd8:	00668b13          	addi	s6,a3,6
    7bdc:	00b70323          	sb	a1,6(a4)
    7be0:	01fb0c63          	beq	s6,t6,7bf8 <_ftoa+0xab8>
    7be4:	00b703a3          	sb	a1,7(a4)
    7be8:	00768b13          	addi	s6,a3,7
    7bec:	0721                	addi	a4,a4,8
    7bee:	fbfb10e3          	bne	s6,t6,7b8e <_ftoa+0xa4e>
    7bf2:	0001                	nop
    7bf4:	00000013          	nop
    7bf8:	685b00e3          	beq	s6,t0,8a78 <_ftoa+0x1938>
    7bfc:	6e080fe3          	beqz	a6,8afa <_ftoa+0x19ba>
    7c00:	002f8d33          	add	s10,t6,sp
    7c04:	02d00293          	li	t0,45
    7c08:	0b05                	addi	s6,s6,1
    7c0a:	005d0823          	sb	t0,16(s10)
    7c0e:	8d4e                	mv	s10,s3
    7c10:	9d5a                	add	s10,s10,s6
    7c12:	016c0bb3          	add	s7,s8,s6
    7c16:	007b7b13          	andi	s6,s6,7
    7c1a:	01ac0cb3          	add	s9,s8,s10
    7c1e:	080b0163          	beqz	s6,7ca0 <_ftoa+0xb60>
    7c22:	4585                	li	a1,1
    7c24:	06bb0463          	beq	s6,a1,7c8c <_ftoa+0xb4c>
    7c28:	4789                	li	a5,2
    7c2a:	04fb0a63          	beq	s6,a5,7c7e <_ftoa+0xb3e>
    7c2e:	4e8d                	li	t4,3
    7c30:	05db0063          	beq	s6,t4,7c70 <_ftoa+0xb30>
    7c34:	4611                	li	a2,4
    7c36:	02cb0663          	beq	s6,a2,7c62 <_ftoa+0xb22>
    7c3a:	4395                	li	t2,5
    7c3c:	007b0c63          	beq	s6,t2,7c54 <_ftoa+0xb14>
    7c40:	4899                	li	a7,6
    7c42:	5f1b1de3          	bne	s6,a7,8a3c <_ftoa+0x18fc>
    7c46:	417c8633          	sub	a2,s9,s7
    7c4a:	89fbc50b          	th.lbuib	a0,(s7),-1,0
    7c4e:	86ca                	mv	a3,s2
    7c50:	85a6                	mv	a1,s1
    7c52:	9402                	jalr	s0
    7c54:	417c8633          	sub	a2,s9,s7
    7c58:	89fbc50b          	th.lbuib	a0,(s7),-1,0
    7c5c:	86ca                	mv	a3,s2
    7c5e:	85a6                	mv	a1,s1
    7c60:	9402                	jalr	s0
    7c62:	417c8633          	sub	a2,s9,s7
    7c66:	89fbc50b          	th.lbuib	a0,(s7),-1,0
    7c6a:	86ca                	mv	a3,s2
    7c6c:	85a6                	mv	a1,s1
    7c6e:	9402                	jalr	s0
    7c70:	417c8633          	sub	a2,s9,s7
    7c74:	89fbc50b          	th.lbuib	a0,(s7),-1,0
    7c78:	86ca                	mv	a3,s2
    7c7a:	85a6                	mv	a1,s1
    7c7c:	9402                	jalr	s0
    7c7e:	417c8633          	sub	a2,s9,s7
    7c82:	89fbc50b          	th.lbuib	a0,(s7),-1,0
    7c86:	86ca                	mv	a3,s2
    7c88:	85a6                	mv	a1,s1
    7c8a:	9402                	jalr	s0
    7c8c:	417c8633          	sub	a2,s9,s7
    7c90:	89fbc50b          	th.lbuib	a0,(s7),-1,0
    7c94:	86ca                	mv	a3,s2
    7c96:	85a6                	mv	a1,s1
    7c98:	8b6a                	mv	s6,s10
    7c9a:	9402                	jalr	s0
    7c9c:	097c0663          	beq	s8,s7,7d28 <_ftoa+0xbe8>
    7ca0:	fc6e                	sd	s11,56(sp)
    7ca2:	8dde                	mv	s11,s7
    7ca4:	89fdc50b          	th.lbuib	a0,(s11),-1,0
    7ca8:	417c8633          	sub	a2,s9,s7
    7cac:	86ca                	mv	a3,s2
    7cae:	85a6                	mv	a1,s1
    7cb0:	9402                	jalr	s0
    7cb2:	8b5e                	mv	s6,s7
    7cb4:	89eb450b          	th.lbuib	a0,(s6),-2,0
    7cb8:	41bc8633          	sub	a2,s9,s11
    7cbc:	86ca                	mv	a3,s2
    7cbe:	85a6                	mv	a1,s1
    7cc0:	9402                	jalr	s0
    7cc2:	8dde                	mv	s11,s7
    7cc4:	89ddc50b          	th.lbuib	a0,(s11),-3,0
    7cc8:	416c8633          	sub	a2,s9,s6
    7ccc:	86ca                	mv	a3,s2
    7cce:	85a6                	mv	a1,s1
    7cd0:	9402                	jalr	s0
    7cd2:	8b5e                	mv	s6,s7
    7cd4:	89cb450b          	th.lbuib	a0,(s6),-4,0
    7cd8:	41bc8633          	sub	a2,s9,s11
    7cdc:	86ca                	mv	a3,s2
    7cde:	85a6                	mv	a1,s1
    7ce0:	9402                	jalr	s0
    7ce2:	8dde                	mv	s11,s7
    7ce4:	89bdc50b          	th.lbuib	a0,(s11),-5,0
    7ce8:	416c8633          	sub	a2,s9,s6
    7cec:	86ca                	mv	a3,s2
    7cee:	85a6                	mv	a1,s1
    7cf0:	9402                	jalr	s0
    7cf2:	8b5e                	mv	s6,s7
    7cf4:	89ab450b          	th.lbuib	a0,(s6),-6,0
    7cf8:	41bc8633          	sub	a2,s9,s11
    7cfc:	86ca                	mv	a3,s2
    7cfe:	85a6                	mv	a1,s1
    7d00:	9402                	jalr	s0
    7d02:	8dde                	mv	s11,s7
    7d04:	899dc50b          	th.lbuib	a0,(s11),-7,0
    7d08:	416c8633          	sub	a2,s9,s6
    7d0c:	86ca                	mv	a3,s2
    7d0e:	85a6                	mv	a1,s1
    7d10:	9402                	jalr	s0
    7d12:	898bc50b          	th.lbuib	a0,(s7),-8,0
    7d16:	86ca                	mv	a3,s2
    7d18:	41bc8633          	sub	a2,s9,s11
    7d1c:	85a6                	mv	a1,s1
    7d1e:	8b6a                	mv	s6,s10
    7d20:	9402                	jalr	s0
    7d22:	f97c10e3          	bne	s8,s7,7ca2 <_ftoa+0xb62>
    7d26:	7de2                	ld	s11,56(sp)
    7d28:	002a7a13          	andi	s4,s4,2
    7d2c:	140a0a63          	beqz	s4,7e80 <_ftoa+0xd40>
    7d30:	413d09b3          	sub	s3,s10,s3
    7d34:	7c0aba8b          	th.extu	s5,s5,31,0
    7d38:	1559f463          	bgeu	s3,s5,7e80 <_ftoa+0xd40>
    7d3c:	fff9cc13          	not	s8,s3
    7d40:	015c0e33          	add	t3,s8,s5
    7d44:	866a                	mv	a2,s10
    7d46:	001d0b13          	addi	s6,s10,1
    7d4a:	86ca                	mv	a3,s2
    7d4c:	85a6                	mv	a1,s1
    7d4e:	02000513          	li	a0,32
    7d52:	00198d13          	addi	s10,s3,1
    7d56:	007e7b93          	andi	s7,t3,7
    7d5a:	9402                	jalr	s0
    7d5c:	135d7263          	bgeu	s10,s5,7e80 <_ftoa+0xd40>
    7d60:	080b8e63          	beqz	s7,7dfc <_ftoa+0xcbc>
    7d64:	4f05                	li	t5,1
    7d66:	09eb8163          	beq	s7,t5,7de8 <_ftoa+0xca8>
    7d6a:	4309                	li	t1,2
    7d6c:	066b8663          	beq	s7,t1,7dd8 <_ftoa+0xc98>
    7d70:	468d                	li	a3,3
    7d72:	04db8b63          	beq	s7,a3,7dc8 <_ftoa+0xc88>
    7d76:	4811                	li	a6,4
    7d78:	050b8063          	beq	s7,a6,7db8 <_ftoa+0xc78>
    7d7c:	4715                	li	a4,5
    7d7e:	02eb8563          	beq	s7,a4,7da8 <_ftoa+0xc68>
    7d82:	4519                	li	a0,6
    7d84:	00ab8a63          	beq	s7,a0,7d98 <_ftoa+0xc58>
    7d88:	865a                	mv	a2,s6
    7d8a:	86ca                	mv	a3,s2
    7d8c:	85a6                	mv	a1,s1
    7d8e:	02000513          	li	a0,32
    7d92:	0b05                	addi	s6,s6,1
    7d94:	9402                	jalr	s0
    7d96:	0d05                	addi	s10,s10,1
    7d98:	865a                	mv	a2,s6
    7d9a:	86ca                	mv	a3,s2
    7d9c:	85a6                	mv	a1,s1
    7d9e:	02000513          	li	a0,32
    7da2:	0b05                	addi	s6,s6,1
    7da4:	9402                	jalr	s0
    7da6:	0d05                	addi	s10,s10,1
    7da8:	865a                	mv	a2,s6
    7daa:	86ca                	mv	a3,s2
    7dac:	85a6                	mv	a1,s1
    7dae:	02000513          	li	a0,32
    7db2:	0b05                	addi	s6,s6,1
    7db4:	9402                	jalr	s0
    7db6:	0d05                	addi	s10,s10,1
    7db8:	865a                	mv	a2,s6
    7dba:	86ca                	mv	a3,s2
    7dbc:	85a6                	mv	a1,s1
    7dbe:	02000513          	li	a0,32
    7dc2:	0b05                	addi	s6,s6,1
    7dc4:	9402                	jalr	s0
    7dc6:	0d05                	addi	s10,s10,1
    7dc8:	865a                	mv	a2,s6
    7dca:	86ca                	mv	a3,s2
    7dcc:	85a6                	mv	a1,s1
    7dce:	02000513          	li	a0,32
    7dd2:	0b05                	addi	s6,s6,1
    7dd4:	9402                	jalr	s0
    7dd6:	0d05                	addi	s10,s10,1
    7dd8:	865a                	mv	a2,s6
    7dda:	86ca                	mv	a3,s2
    7ddc:	85a6                	mv	a1,s1
    7dde:	02000513          	li	a0,32
    7de2:	0b05                	addi	s6,s6,1
    7de4:	9402                	jalr	s0
    7de6:	0d05                	addi	s10,s10,1
    7de8:	865a                	mv	a2,s6
    7dea:	86ca                	mv	a3,s2
    7dec:	85a6                	mv	a1,s1
    7dee:	02000513          	li	a0,32
    7df2:	0d05                	addi	s10,s10,1
    7df4:	0b05                	addi	s6,s6,1
    7df6:	9402                	jalr	s0
    7df8:	095d7463          	bgeu	s10,s5,7e80 <_ftoa+0xd40>
    7dfc:	865a                	mv	a2,s6
    7dfe:	86ca                	mv	a3,s2
    7e00:	85a6                	mv	a1,s1
    7e02:	02000513          	li	a0,32
    7e06:	9402                	jalr	s0
    7e08:	001b0c93          	addi	s9,s6,1
    7e0c:	8666                	mv	a2,s9
    7e0e:	86ca                	mv	a3,s2
    7e10:	85a6                	mv	a1,s1
    7e12:	02000513          	li	a0,32
    7e16:	9402                	jalr	s0
    7e18:	002b0993          	addi	s3,s6,2
    7e1c:	864e                	mv	a2,s3
    7e1e:	86ca                	mv	a3,s2
    7e20:	85a6                	mv	a1,s1
    7e22:	02000513          	li	a0,32
    7e26:	9402                	jalr	s0
    7e28:	003b0a13          	addi	s4,s6,3
    7e2c:	86ca                	mv	a3,s2
    7e2e:	8652                	mv	a2,s4
    7e30:	85a6                	mv	a1,s1
    7e32:	02000513          	li	a0,32
    7e36:	9402                	jalr	s0
    7e38:	004b0c13          	addi	s8,s6,4
    7e3c:	86ca                	mv	a3,s2
    7e3e:	8662                	mv	a2,s8
    7e40:	85a6                	mv	a1,s1
    7e42:	02000513          	li	a0,32
    7e46:	9402                	jalr	s0
    7e48:	005b0c93          	addi	s9,s6,5
    7e4c:	86ca                	mv	a3,s2
    7e4e:	8666                	mv	a2,s9
    7e50:	85a6                	mv	a1,s1
    7e52:	02000513          	li	a0,32
    7e56:	9402                	jalr	s0
    7e58:	006b0b93          	addi	s7,s6,6
    7e5c:	86ca                	mv	a3,s2
    7e5e:	865e                	mv	a2,s7
    7e60:	85a6                	mv	a1,s1
    7e62:	02000513          	li	a0,32
    7e66:	9402                	jalr	s0
    7e68:	007b0993          	addi	s3,s6,7
    7e6c:	86ca                	mv	a3,s2
    7e6e:	864e                	mv	a2,s3
    7e70:	85a6                	mv	a1,s1
    7e72:	02000513          	li	a0,32
    7e76:	0d21                	addi	s10,s10,8
    7e78:	0b21                	addi	s6,s6,8
    7e7a:	9402                	jalr	s0
    7e7c:	f95d60e3          	bltu	s10,s5,7dfc <_ftoa+0xcbc>
    7e80:	6d06                	ld	s10,64(sp)
    7e82:	fc0ff06f          	j	7642 <_ftoa+0x502>
    7e86:	0001                	nop
    7e88:	6fc5                	lui	t6,0x11
    7e8a:	ac8f8b93          	addi	s7,t6,-1336 # 10ac8 <__errno+0x59c>
    7e8e:	4c11                	li	s8,4
    7e90:	cb8ff06f          	j	7348 <_ftoa+0x208>
    7e94:	0aa1f553          	fsub.d	fa0,ft3,fa0
    7e98:	4805                	li	a6,1
    7e9a:	b20ff06f          	j	71ba <_ftoa+0x7a>
    7e9e:	0001                	nop
    7ea0:	00387813          	andi	a6,a6,3
    7ea4:	8c32                	mv	s8,a2
    7ea6:	12081963          	bnez	a6,7fd8 <_ftoa+0xe98>
    7eaa:	4291                	li	t0,4
    7eac:	7c0ab50b          	th.extu	a0,s5,31,0
    7eb0:	1352f463          	bgeu	t0,s5,7fd8 <_ftoa+0xe98>
    7eb4:	ffc60793          	addi	a5,a2,-4
    7eb8:	00a78c33          	add	s8,a5,a0
    7ebc:	40cc05b3          	sub	a1,s8,a2
    7ec0:	0075fe93          	andi	t4,a1,7
    7ec4:	8b32                	mv	s6,a2
    7ec6:	080e8763          	beqz	t4,7f54 <_ftoa+0xe14>
    7eca:	4605                	li	a2,1
    7ecc:	06ce8b63          	beq	t4,a2,7f42 <_ftoa+0xe02>
    7ed0:	4689                	li	a3,2
    7ed2:	06de8163          	beq	t4,a3,7f34 <_ftoa+0xdf4>
    7ed6:	488d                	li	a7,3
    7ed8:	051e8763          	beq	t4,a7,7f26 <_ftoa+0xde6>
    7edc:	025e8e63          	beq	t4,t0,7f18 <_ftoa+0xdd8>
    7ee0:	4f95                	li	t6,5
    7ee2:	03fe8463          	beq	t4,t6,7f0a <_ftoa+0xdca>
    7ee6:	4399                	li	t2,6
    7ee8:	007e8a63          	beq	t4,t2,7efc <_ftoa+0xdbc>
    7eec:	86ca                	mv	a3,s2
    7eee:	864e                	mv	a2,s3
    7ef0:	85a6                	mv	a1,s1
    7ef2:	02000513          	li	a0,32
    7ef6:	00198b13          	addi	s6,s3,1
    7efa:	9402                	jalr	s0
    7efc:	865a                	mv	a2,s6
    7efe:	86ca                	mv	a3,s2
    7f00:	85a6                	mv	a1,s1
    7f02:	02000513          	li	a0,32
    7f06:	0b05                	addi	s6,s6,1
    7f08:	9402                	jalr	s0
    7f0a:	865a                	mv	a2,s6
    7f0c:	86ca                	mv	a3,s2
    7f0e:	85a6                	mv	a1,s1
    7f10:	02000513          	li	a0,32
    7f14:	0b05                	addi	s6,s6,1
    7f16:	9402                	jalr	s0
    7f18:	865a                	mv	a2,s6
    7f1a:	86ca                	mv	a3,s2
    7f1c:	85a6                	mv	a1,s1
    7f1e:	02000513          	li	a0,32
    7f22:	0b05                	addi	s6,s6,1
    7f24:	9402                	jalr	s0
    7f26:	865a                	mv	a2,s6
    7f28:	86ca                	mv	a3,s2
    7f2a:	85a6                	mv	a1,s1
    7f2c:	02000513          	li	a0,32
    7f30:	0b05                	addi	s6,s6,1
    7f32:	9402                	jalr	s0
    7f34:	865a                	mv	a2,s6
    7f36:	86ca                	mv	a3,s2
    7f38:	85a6                	mv	a1,s1
    7f3a:	02000513          	li	a0,32
    7f3e:	0b05                	addi	s6,s6,1
    7f40:	9402                	jalr	s0
    7f42:	865a                	mv	a2,s6
    7f44:	86ca                	mv	a3,s2
    7f46:	0b05                	addi	s6,s6,1
    7f48:	85a6                	mv	a1,s1
    7f4a:	02000513          	li	a0,32
    7f4e:	9402                	jalr	s0
    7f50:	098b0463          	beq	s6,s8,7fd8 <_ftoa+0xe98>
    7f54:	865a                	mv	a2,s6
    7f56:	86ca                	mv	a3,s2
    7f58:	85a6                	mv	a1,s1
    7f5a:	02000513          	li	a0,32
    7f5e:	9402                	jalr	s0
    7f60:	001b0b93          	addi	s7,s6,1
    7f64:	865e                	mv	a2,s7
    7f66:	86ca                	mv	a3,s2
    7f68:	85a6                	mv	a1,s1
    7f6a:	02000513          	li	a0,32
    7f6e:	9402                	jalr	s0
    7f70:	002b0c93          	addi	s9,s6,2
    7f74:	8666                	mv	a2,s9
    7f76:	86ca                	mv	a3,s2
    7f78:	85a6                	mv	a1,s1
    7f7a:	02000513          	li	a0,32
    7f7e:	9402                	jalr	s0
    7f80:	003b0b93          	addi	s7,s6,3
    7f84:	865e                	mv	a2,s7
    7f86:	86ca                	mv	a3,s2
    7f88:	85a6                	mv	a1,s1
    7f8a:	02000513          	li	a0,32
    7f8e:	9402                	jalr	s0
    7f90:	004b0c93          	addi	s9,s6,4
    7f94:	8666                	mv	a2,s9
    7f96:	86ca                	mv	a3,s2
    7f98:	85a6                	mv	a1,s1
    7f9a:	02000513          	li	a0,32
    7f9e:	9402                	jalr	s0
    7fa0:	005b0b93          	addi	s7,s6,5
    7fa4:	865e                	mv	a2,s7
    7fa6:	86ca                	mv	a3,s2
    7fa8:	85a6                	mv	a1,s1
    7faa:	02000513          	li	a0,32
    7fae:	9402                	jalr	s0
    7fb0:	006b0c93          	addi	s9,s6,6
    7fb4:	86ca                	mv	a3,s2
    7fb6:	8666                	mv	a2,s9
    7fb8:	85a6                	mv	a1,s1
    7fba:	02000513          	li	a0,32
    7fbe:	9402                	jalr	s0
    7fc0:	007b0b93          	addi	s7,s6,7
    7fc4:	86ca                	mv	a3,s2
    7fc6:	0b21                	addi	s6,s6,8
    7fc8:	865e                	mv	a2,s7
    7fca:	85a6                	mv	a1,s1
    7fcc:	02000513          	li	a0,32
    7fd0:	9402                	jalr	s0
    7fd2:	f98b11e3          	bne	s6,s8,7f54 <_ftoa+0xe14>
    7fd6:	0001                	nop
    7fd8:	6745                	lui	a4,0x11
    7fda:	ae070b13          	addi	s6,a4,-1312 # 10ae0 <__errno+0x5b4>
    7fde:	ffcb0c93          	addi	s9,s6,-4
    7fe2:	018b0bb3          	add	s7,s6,s8
    7fe6:	0001                	nop
    7fe8:	003b4503          	lbu	a0,3(s6)
    7fec:	416b8633          	sub	a2,s7,s6
    7ff0:	86ca                	mv	a3,s2
    7ff2:	85a6                	mv	a1,s1
    7ff4:	1b7d                	addi	s6,s6,-1
    7ff6:	9402                	jalr	s0
    7ff8:	ff6c98e3          	bne	s9,s6,7fe8 <_ftoa+0xea8>
    7ffc:	002a7e13          	andi	t3,s4,2
    8000:	004c0b13          	addi	s6,s8,4
    8004:	e20e0f63          	beqz	t3,7642 <_ftoa+0x502>
    8008:	7c0aba8b          	th.extu	s5,s5,31,0
    800c:	413b0f33          	sub	t5,s6,s3
    8010:	e35f7963          	bgeu	t5,s5,7642 <_ftoa+0x502>
    8014:	fffb4313          	not	t1,s6
    8018:	01530a33          	add	s4,t1,s5
    801c:	013a0833          	add	a6,s4,s3
    8020:	865a                	mv	a2,s6
    8022:	02000513          	li	a0,32
    8026:	86ca                	mv	a3,s2
    8028:	85a6                	mv	a1,s1
    802a:	00787c93          	andi	s9,a6,7
    802e:	005c0b13          	addi	s6,s8,5
    8032:	9402                	jalr	s0
    8034:	413b0533          	sub	a0,s6,s3
    8038:	e1557563          	bgeu	a0,s5,7642 <_ftoa+0x502>
    803c:	080c8963          	beqz	s9,80ce <_ftoa+0xf8e>
    8040:	4285                	li	t0,1
    8042:	065c8b63          	beq	s9,t0,80b8 <_ftoa+0xf78>
    8046:	4789                	li	a5,2
    8048:	06fc8163          	beq	s9,a5,80aa <_ftoa+0xf6a>
    804c:	4c0d                	li	s8,3
    804e:	058c8763          	beq	s9,s8,809c <_ftoa+0xf5c>
    8052:	4591                	li	a1,4
    8054:	02bc8d63          	beq	s9,a1,808e <_ftoa+0xf4e>
    8058:	4e95                	li	t4,5
    805a:	03dc8363          	beq	s9,t4,8080 <_ftoa+0xf40>
    805e:	4619                	li	a2,6
    8060:	00cc8963          	beq	s9,a2,8072 <_ftoa+0xf32>
    8064:	865a                	mv	a2,s6
    8066:	86ca                	mv	a3,s2
    8068:	85a6                	mv	a1,s1
    806a:	02000513          	li	a0,32
    806e:	0b05                	addi	s6,s6,1
    8070:	9402                	jalr	s0
    8072:	865a                	mv	a2,s6
    8074:	86ca                	mv	a3,s2
    8076:	85a6                	mv	a1,s1
    8078:	02000513          	li	a0,32
    807c:	0b05                	addi	s6,s6,1
    807e:	9402                	jalr	s0
    8080:	865a                	mv	a2,s6
    8082:	86ca                	mv	a3,s2
    8084:	85a6                	mv	a1,s1
    8086:	02000513          	li	a0,32
    808a:	0b05                	addi	s6,s6,1
    808c:	9402                	jalr	s0
    808e:	865a                	mv	a2,s6
    8090:	86ca                	mv	a3,s2
    8092:	85a6                	mv	a1,s1
    8094:	02000513          	li	a0,32
    8098:	0b05                	addi	s6,s6,1
    809a:	9402                	jalr	s0
    809c:	865a                	mv	a2,s6
    809e:	86ca                	mv	a3,s2
    80a0:	85a6                	mv	a1,s1
    80a2:	02000513          	li	a0,32
    80a6:	0b05                	addi	s6,s6,1
    80a8:	9402                	jalr	s0
    80aa:	865a                	mv	a2,s6
    80ac:	86ca                	mv	a3,s2
    80ae:	85a6                	mv	a1,s1
    80b0:	02000513          	li	a0,32
    80b4:	0b05                	addi	s6,s6,1
    80b6:	9402                	jalr	s0
    80b8:	865a                	mv	a2,s6
    80ba:	86ca                	mv	a3,s2
    80bc:	85a6                	mv	a1,s1
    80be:	02000513          	li	a0,32
    80c2:	0b05                	addi	s6,s6,1
    80c4:	9402                	jalr	s0
    80c6:	413b06b3          	sub	a3,s6,s3
    80ca:	d756fc63          	bgeu	a3,s5,7642 <_ftoa+0x502>
    80ce:	865a                	mv	a2,s6
    80d0:	86ca                	mv	a3,s2
    80d2:	85a6                	mv	a1,s1
    80d4:	02000513          	li	a0,32
    80d8:	9402                	jalr	s0
    80da:	001b0a13          	addi	s4,s6,1
    80de:	8652                	mv	a2,s4
    80e0:	86ca                	mv	a3,s2
    80e2:	85a6                	mv	a1,s1
    80e4:	02000513          	li	a0,32
    80e8:	9402                	jalr	s0
    80ea:	002b0b93          	addi	s7,s6,2
    80ee:	865e                	mv	a2,s7
    80f0:	86ca                	mv	a3,s2
    80f2:	85a6                	mv	a1,s1
    80f4:	02000513          	li	a0,32
    80f8:	9402                	jalr	s0
    80fa:	003b0c93          	addi	s9,s6,3
    80fe:	8666                	mv	a2,s9
    8100:	86ca                	mv	a3,s2
    8102:	85a6                	mv	a1,s1
    8104:	02000513          	li	a0,32
    8108:	9402                	jalr	s0
    810a:	004b0c13          	addi	s8,s6,4
    810e:	86ca                	mv	a3,s2
    8110:	8662                	mv	a2,s8
    8112:	85a6                	mv	a1,s1
    8114:	02000513          	li	a0,32
    8118:	9402                	jalr	s0
    811a:	005b0a13          	addi	s4,s6,5
    811e:	86ca                	mv	a3,s2
    8120:	8652                	mv	a2,s4
    8122:	85a6                	mv	a1,s1
    8124:	02000513          	li	a0,32
    8128:	9402                	jalr	s0
    812a:	006b0b93          	addi	s7,s6,6
    812e:	86ca                	mv	a3,s2
    8130:	865e                	mv	a2,s7
    8132:	85a6                	mv	a1,s1
    8134:	02000513          	li	a0,32
    8138:	9402                	jalr	s0
    813a:	007b0c93          	addi	s9,s6,7
    813e:	86ca                	mv	a3,s2
    8140:	8666                	mv	a2,s9
    8142:	85a6                	mv	a1,s1
    8144:	02000513          	li	a0,32
    8148:	0b21                	addi	s6,s6,8
    814a:	9402                	jalr	s0
    814c:	413b06b3          	sub	a3,s6,s3
    8150:	f756efe3          	bltu	a3,s5,80ce <_ftoa+0xf8e>
    8154:	ceeff06f          	j	7642 <_ftoa+0x502>
    8158:	4e85                	li	t4,1
    815a:	418e8633          	sub	a2,t4,s8
    815e:	003a7593          	andi	a1,s4,3
    8162:	00f60fb3          	add	t6,a2,a5
    8166:	1dd58fe3          	beq	a1,t4,8b44 <_ftoa+0x1a04>
    816a:	02000393          	li	t2,32
    816e:	107f8be3          	beq	t6,t2,8a84 <_ftoa+0x1944>
    8172:	04080be3          	beqz	a6,89c8 <_ftoa+0x1888>
    8176:	007f8333          	add	t1,t6,t2
    817a:	00230733          	add	a4,t1,sp
    817e:	02d00513          	li	a0,45
    8182:	001f8b13          	addi	s6,t6,1
    8186:	fea70823          	sb	a0,-16(a4)
    818a:	a80592e3          	bnez	a1,7c0e <_ftoa+0xace>
    818e:	7c0ab28b          	th.extu	t0,s5,31,0
    8192:	a65b7ee3          	bgeu	s6,t0,7c0e <_ftoa+0xace>
    8196:	416285b3          	sub	a1,t0,s6
    819a:	0075f793          	andi	a5,a1,7
    819e:	01358d33          	add	s10,a1,s3
    81a2:	8bce                	mv	s7,s3
    81a4:	c7d9                	beqz	a5,8232 <_ftoa+0x10f2>
    81a6:	4e85                	li	t4,1
    81a8:	07d78c63          	beq	a5,t4,8220 <_ftoa+0x10e0>
    81ac:	4609                	li	a2,2
    81ae:	06c78263          	beq	a5,a2,8212 <_ftoa+0x10d2>
    81b2:	438d                	li	t2,3
    81b4:	04778863          	beq	a5,t2,8204 <_ftoa+0x10c4>
    81b8:	4891                	li	a7,4
    81ba:	03178e63          	beq	a5,a7,81f6 <_ftoa+0x10b6>
    81be:	4e15                	li	t3,5
    81c0:	03c78463          	beq	a5,t3,81e8 <_ftoa+0x10a8>
    81c4:	4f19                	li	t5,6
    81c6:	01e78a63          	beq	a5,t5,81da <_ftoa+0x109a>
    81ca:	86ca                	mv	a3,s2
    81cc:	864e                	mv	a2,s3
    81ce:	85a6                	mv	a1,s1
    81d0:	02000513          	li	a0,32
    81d4:	00198b93          	addi	s7,s3,1
    81d8:	9402                	jalr	s0
    81da:	865e                	mv	a2,s7
    81dc:	86ca                	mv	a3,s2
    81de:	85a6                	mv	a1,s1
    81e0:	02000513          	li	a0,32
    81e4:	0b85                	addi	s7,s7,1
    81e6:	9402                	jalr	s0
    81e8:	865e                	mv	a2,s7
    81ea:	86ca                	mv	a3,s2
    81ec:	85a6                	mv	a1,s1
    81ee:	02000513          	li	a0,32
    81f2:	0b85                	addi	s7,s7,1
    81f4:	9402                	jalr	s0
    81f6:	865e                	mv	a2,s7
    81f8:	86ca                	mv	a3,s2
    81fa:	85a6                	mv	a1,s1
    81fc:	02000513          	li	a0,32
    8200:	0b85                	addi	s7,s7,1
    8202:	9402                	jalr	s0
    8204:	865e                	mv	a2,s7
    8206:	86ca                	mv	a3,s2
    8208:	85a6                	mv	a1,s1
    820a:	02000513          	li	a0,32
    820e:	0b85                	addi	s7,s7,1
    8210:	9402                	jalr	s0
    8212:	865e                	mv	a2,s7
    8214:	86ca                	mv	a3,s2
    8216:	85a6                	mv	a1,s1
    8218:	02000513          	li	a0,32
    821c:	0b85                	addi	s7,s7,1
    821e:	9402                	jalr	s0
    8220:	865e                	mv	a2,s7
    8222:	86ca                	mv	a3,s2
    8224:	0b85                	addi	s7,s7,1
    8226:	85a6                	mv	a1,s1
    8228:	02000513          	li	a0,32
    822c:	9402                	jalr	s0
    822e:	9f7d01e3          	beq	s10,s7,7c10 <_ftoa+0xad0>
    8232:	fc6e                	sd	s11,56(sp)
    8234:	865e                	mv	a2,s7
    8236:	86ca                	mv	a3,s2
    8238:	85a6                	mv	a1,s1
    823a:	02000513          	li	a0,32
    823e:	9402                	jalr	s0
    8240:	001b8c93          	addi	s9,s7,1
    8244:	8666                	mv	a2,s9
    8246:	86ca                	mv	a3,s2
    8248:	85a6                	mv	a1,s1
    824a:	02000513          	li	a0,32
    824e:	9402                	jalr	s0
    8250:	002b8d93          	addi	s11,s7,2
    8254:	866e                	mv	a2,s11
    8256:	86ca                	mv	a3,s2
    8258:	85a6                	mv	a1,s1
    825a:	02000513          	li	a0,32
    825e:	9402                	jalr	s0
    8260:	003b8c93          	addi	s9,s7,3
    8264:	8666                	mv	a2,s9
    8266:	86ca                	mv	a3,s2
    8268:	85a6                	mv	a1,s1
    826a:	02000513          	li	a0,32
    826e:	9402                	jalr	s0
    8270:	004b8d93          	addi	s11,s7,4
    8274:	866e                	mv	a2,s11
    8276:	86ca                	mv	a3,s2
    8278:	85a6                	mv	a1,s1
    827a:	02000513          	li	a0,32
    827e:	9402                	jalr	s0
    8280:	005b8c93          	addi	s9,s7,5
    8284:	8666                	mv	a2,s9
    8286:	86ca                	mv	a3,s2
    8288:	85a6                	mv	a1,s1
    828a:	02000513          	li	a0,32
    828e:	9402                	jalr	s0
    8290:	006b8d93          	addi	s11,s7,6
    8294:	86ca                	mv	a3,s2
    8296:	866e                	mv	a2,s11
    8298:	85a6                	mv	a1,s1
    829a:	02000513          	li	a0,32
    829e:	9402                	jalr	s0
    82a0:	007b8c93          	addi	s9,s7,7
    82a4:	86ca                	mv	a3,s2
    82a6:	0ba1                	addi	s7,s7,8
    82a8:	8666                	mv	a2,s9
    82aa:	85a6                	mv	a1,s1
    82ac:	02000513          	li	a0,32
    82b0:	9402                	jalr	s0
    82b2:	f97d11e3          	bne	s10,s7,8234 <_ftoa+0x10f4>
    82b6:	7de2                	ld	s11,56(sp)
    82b8:	baa1                	j	7c10 <_ftoa+0xad0>
    82ba:	0001                	nop
    82bc:	4305                	li	t1,1
    82be:	41830733          	sub	a4,t1,s8
    82c2:	00c702b3          	add	t0,a4,a2
    82c6:	02000393          	li	t2,32
    82ca:	0e728363          	beq	t0,t2,83b0 <_ftoa+0x1270>
    82ce:	7c0eb50b          	th.extu	a0,t4,31,0
    82d2:	00757b93          	andi	s7,a0,7
    82d6:	00550b33          	add	s6,a0,t0
    82da:	03000893          	li	a7,48
    82de:	060b8663          	beqz	s7,834a <_ftoa+0x120a>
    82e2:	005c588b          	th.srb	a7,s8,t0,0
    82e6:	0285                	addi	t0,t0,1
    82e8:	0c728463          	beq	t0,t2,83b0 <_ftoa+0x1270>
    82ec:	046b8f63          	beq	s7,t1,834a <_ftoa+0x120a>
    82f0:	4c89                	li	s9,2
    82f2:	059b8763          	beq	s7,s9,8340 <_ftoa+0x1200>
    82f6:	4d0d                	li	s10,3
    82f8:	03ab8f63          	beq	s7,s10,8336 <_ftoa+0x11f6>
    82fc:	4e11                	li	t3,4
    82fe:	03cb8763          	beq	s7,t3,832c <_ftoa+0x11ec>
    8302:	4e95                	li	t4,5
    8304:	01db8f63          	beq	s7,t4,8322 <_ftoa+0x11e2>
    8308:	4f19                	li	t5,6
    830a:	01eb8763          	beq	s7,t5,8318 <_ftoa+0x11d8>
    830e:	005c588b          	th.srb	a7,s8,t0,0
    8312:	0285                	addi	t0,t0,1
    8314:	08728e63          	beq	t0,t2,83b0 <_ftoa+0x1270>
    8318:	005c588b          	th.srb	a7,s8,t0,0
    831c:	0285                	addi	t0,t0,1
    831e:	08728963          	beq	t0,t2,83b0 <_ftoa+0x1270>
    8322:	005c588b          	th.srb	a7,s8,t0,0
    8326:	0285                	addi	t0,t0,1
    8328:	08728463          	beq	t0,t2,83b0 <_ftoa+0x1270>
    832c:	005c588b          	th.srb	a7,s8,t0,0
    8330:	0285                	addi	t0,t0,1
    8332:	06728f63          	beq	t0,t2,83b0 <_ftoa+0x1270>
    8336:	005c588b          	th.srb	a7,s8,t0,0
    833a:	0285                	addi	t0,t0,1
    833c:	06728a63          	beq	t0,t2,83b0 <_ftoa+0x1270>
    8340:	005c588b          	th.srb	a7,s8,t0,0
    8344:	0285                	addi	t0,t0,1
    8346:	06728563          	beq	t0,t2,83b0 <_ftoa+0x1270>
    834a:	665b0463          	beq	s6,t0,89b2 <_ftoa+0x1872>
    834e:	005c588b          	th.srb	a7,s8,t0,0
    8352:	00128f93          	addi	t6,t0,1
    8356:	047f8d63          	beq	t6,t2,83b0 <_ftoa+0x1270>
    835a:	01fc588b          	th.srb	a7,s8,t6,0
    835e:	00228313          	addi	t1,t0,2
    8362:	04730763          	beq	t1,t2,83b0 <_ftoa+0x1270>
    8366:	006c588b          	th.srb	a7,s8,t1,0
    836a:	00328713          	addi	a4,t0,3
    836e:	04770163          	beq	a4,t2,83b0 <_ftoa+0x1270>
    8372:	00ec588b          	th.srb	a7,s8,a4,0
    8376:	00428513          	addi	a0,t0,4
    837a:	02750b63          	beq	a0,t2,83b0 <_ftoa+0x1270>
    837e:	00ac588b          	th.srb	a7,s8,a0,0
    8382:	00528b93          	addi	s7,t0,5
    8386:	027b8563          	beq	s7,t2,83b0 <_ftoa+0x1270>
    838a:	017c588b          	th.srb	a7,s8,s7,0
    838e:	00628c93          	addi	s9,t0,6
    8392:	007c8f63          	beq	s9,t2,83b0 <_ftoa+0x1270>
    8396:	019c588b          	th.srb	a7,s8,s9,0
    839a:	00728d13          	addi	s10,t0,7
    839e:	007d0963          	beq	s10,t2,83b0 <_ftoa+0x1270>
    83a2:	01ac588b          	th.srb	a7,s8,s10,0
    83a6:	02a1                	addi	t0,t0,8
    83a8:	fa7291e3          	bne	t0,t2,834a <_ftoa+0x120a>
    83ac:	00000013          	nop
    83b0:	02000f93          	li	t6,32
    83b4:	d8cff06f          	j	7940 <_ftoa+0x800>
    83b8:	e20506d3          	fmv.x.d	a3,fa0
    83bc:	fc6e                	sd	s11,56(sp)
    83be:	fb46b58b          	th.extu	a1,a3,62,52
    83c2:	6ec5                	lui	t4,0x11
    83c4:	6645                	lui	a2,0x11
    83c6:	bb8ebf07          	fld	ft10,-1096(t4) # 10bb8 <errpat+0x70>
    83ca:	bc063f87          	fld	ft11,-1088(a2) # 10bc0 <errpat+0x78>
    83ce:	c015879b          	addiw	a5,a1,-1023
    83d2:	d2078ed3          	fcvt.d.w	ft9,a5
    83d6:	3ff00893          	li	a7,1023
    83da:	6e45                	lui	t3,0x11
    83dc:	03489b13          	slli	s6,a7,0x34
    83e0:	bc8e3787          	fld	fa5,-1080(t3) # 10bc8 <errpat+0x80>
    83e4:	cc06b38b          	th.extu	t2,a3,51,0
    83e8:	fbeef043          	fmadd.d	ft0,ft9,ft10,ft11
    83ec:	0163edb3          	or	s11,t2,s6
    83f0:	f20d80d3          	fmv.d.x	ft1,s11
    83f4:	6f45                	lui	t5,0x11
    83f6:	0af0f153          	fsub.d	ft2,ft1,fa5
    83fa:	bd0f3187          	fld	ft3,-1072(t5) # 10bd0 <errpat+0x88>
    83fe:	6845                	lui	a6,0x11
    8400:	6545                	lui	a0,0x11
    8402:	023176c3          	fmadd.d	fa3,ft2,ft3,ft0
    8406:	bd883287          	fld	ft5,-1064(a6) # 10bd8 <errpat+0x90>
    840a:	be053307          	fld	ft6,-1056(a0) # 10be0 <errpat+0x98>
    840e:	6c45                	lui	s8,0x11
    8410:	be8c3587          	fld	fa1,-1048(s8) # 10be8 <errpat+0xa0>
    8414:	c2069353          	fcvt.w.d	t1,fa3,rtz
    8418:	6bc5                	lui	s7,0x11
    841a:	d2030253          	fcvt.d.w	ft4,t1
    841e:	bf0bb807          	fld	fa6,-1040(s7) # 10bf0 <errpat+0xa8>
    8422:	32527743          	fmadd.d	fa4,ft4,ft5,ft6
    8426:	4299                	li	t0,6
    8428:	400a7f93          	andi	t6,s4,1024
    842c:	41f2970b          	th.mveqz	a4,t0,t6
    8430:	62c5                	lui	t0,0x11
    8432:	c2071d53          	fcvt.w.d	s10,fa4,rtz
    8436:	bf82bf07          	fld	ft10,-1032(t0) # 10bf8 <errpat+0xb0>
    843a:	d20d03d3          	fcvt.d.w	ft7,s10
    843e:	65c5                	lui	a1,0x11
    8440:	12b3f653          	fmul.d	fa2,ft7,fa1
    8444:	b805b087          	fld	ft1,-1152(a1) # 10b80 <errpat+0x38>
    8448:	67c5                	lui	a5,0x11
    844a:	c007b107          	fld	ft2,-1024(a5) # 10c00 <errpat+0xb8>
    844e:	630278c7          	fmsub.d	fa7,ft4,fa6,fa2
    8452:	6ec5                	lui	t4,0x11
    8454:	c08eb207          	fld	ft4,-1016(t4) # 10c08 <errpat+0xc0>
    8458:	6645                	lui	a2,0x11
    845a:	b9063707          	fld	fa4,-1136(a2) # 10b90 <errpat+0x48>
    845e:	1318fe53          	fmul.d	ft8,fa7,fa7
    8462:	0b1272d3          	fsub.d	ft5,ft4,fa7
    8466:	0318fed3          	fadd.d	ft9,fa7,fa7
    846a:	3ffd039b          	addiw	t2,s10,1023
    846e:	1bee7fd3          	fdiv.d	ft11,ft8,ft10
    8472:	03439893          	slli	a7,t2,0x34
    8476:	f2088653          	fmv.d.x	fa2,a7
    847a:	f2068853          	fmv.d.x	fa6,a3
    847e:	00030c9b          	sext.w	s9,t1
    8482:	021ff053          	fadd.d	ft0,ft11,ft1
    8486:	1a0e77d3          	fdiv.d	fa5,ft8,ft0
    848a:	0227f1d3          	fadd.d	ft3,fa5,ft2
    848e:	1a3e76d3          	fdiv.d	fa3,ft8,ft3
    8492:	0256f353          	fadd.d	ft6,fa3,ft5
    8496:	1a6ef3d3          	fdiv.d	ft7,ft9,ft6
    849a:	02e3f5d3          	fadd.d	fa1,ft7,fa4
    849e:	12c5f8d3          	fmul.d	fa7,fa1,fa2
    84a2:	a3181b53          	flt.d	s6,fa6,fa7
    84a6:	000b0663          	beqz	s6,84b2 <_ftoa+0x1372>
    84aa:	1a18f8d3          	fdiv.d	fa7,fa7,ft1
    84ae:	fff30c9b          	addiw	s9,t1,-1
    84b2:	6505                	lui	a0,0x1
    84b4:	063c8d9b          	addiw	s11,s9,99
    84b8:	0c600e13          	li	t3,198
    84bc:	80050c13          	addi	s8,a0,-2048 # 800 <cmp_complex+0x90>
    84c0:	01be3f33          	sltu	t5,t3,s11
    84c4:	4b89                	li	s7,2
    84c6:	4d0d                	li	s10,3
    84c8:	4315                	li	t1,5
    84ca:	4811                	li	a6,4
    84cc:	018a77b3          	and	a5,s4,s8
    84d0:	41eb9d0b          	th.mveqz	s10,s7,t5
    84d4:	41e8130b          	th.mveqz	t1,a6,t5
    84d8:	50078c63          	beqz	a5,89f0 <_ftoa+0x18b0>
    84dc:	fff7059b          	addiw	a1,a4,-1
    84e0:	41f7158b          	th.mveqz	a1,a4,t6
    84e4:	406a87bb          	subw	a5,s5,t1
    84e8:	01533eb3          	sltu	t4,t1,s5
    84ec:	002a7613          	andi	a2,s4,2
    84f0:	42e5970b          	th.mvnez	a4,a1,a4
    84f4:	41d0178b          	th.mveqz	a5,zero,t4
    84f8:	50060263          	beqz	a2,89fc <_ftoa+0x18bc>
    84fc:	4781                	li	a5,0
    84fe:	0001                	nop
    8500:	000c8863          	beqz	s9,8510 <_ftoa+0x13d0>
    8504:	f2068e53          	fmv.d.x	ft8,a3
    8508:	1b1e7ed3          	fdiv.d	ft9,ft8,fa7
    850c:	e20e86d3          	fmv.x.d	a3,ft9
    8510:	f2000f53          	fmv.d.x	ft10,zero
    8514:	a3e513d3          	flt.d	t2,fa0,ft10
    8518:	00038863          	beqz	t2,8528 <_ftoa+0x13e8>
    851c:	f2068553          	fmv.d.x	fa0,a3
    8520:	22a51fd3          	fneg.d	ft11,fa0
    8524:	e20f86d3          	fmv.x.d	a3,ft11
    8528:	78fd                	lui	a7,0xfffff
    852a:	7ff88b13          	addi	s6,a7,2047 # fffffffffffff7ff <__kernel_stack+0xfffffffffff117ff>
    852e:	016a7833          	and	a6,s4,s6
    8532:	f2068553          	fmv.d.x	fa0,a3
    8536:	864e                	mv	a2,s3
    8538:	86ca                	mv	a3,s2
    853a:	85a6                	mv	a1,s1
    853c:	8522                	mv	a0,s0
    853e:	c03fe0ef          	jal	7140 <_ftoa>
    8542:	020a7713          	andi	a4,s4,32
    8546:	862a                	mv	a2,a0
    8548:	00150a13          	addi	s4,a0,1
    854c:	06500793          	li	a5,101
    8550:	8daa                	mv	s11,a0
    8552:	04500513          	li	a0,69
    8556:	e452                	sd	s4,8(sp)
    8558:	86ca                	mv	a3,s2
    855a:	40e7950b          	th.mveqz	a0,a5,a4
    855e:	85a6                	mv	a1,s1
    8560:	9402                	jalr	s0
    8562:	41fcde1b          	sraiw	t3,s9,0x1f
    8566:	01cccf33          	xor	t5,s9,t3
    856a:	41cf033b          	subw	t1,t5,t3
    856e:	4c29                	li	s8,10
    8570:	03837833          	remu	a6,t1,s8
    8574:	01010a13          	addi	s4,sp,16
    8578:	4fa5                	li	t6,9
    857a:	86d2                	mv	a3,s4
    857c:	0308051b          	addiw	a0,a6,48
    8580:	00aa0023          	sb	a0,0(s4)
    8584:	038358b3          	divu	a7,t1,s8
    8588:	106ff863          	bgeu	t6,t1,8698 <_ftoa+0x1558>
    858c:	01110693          	addi	a3,sp,17
    8590:	0388f2b3          	remu	t0,a7,s8
    8594:	0302859b          	addiw	a1,t0,48
    8598:	00b68023          	sb	a1,0(a3)
    859c:	0388deb3          	divu	t4,a7,s8
    85a0:	0f1ffc63          	bgeu	t6,a7,8698 <_ftoa+0x1558>
    85a4:	00168393          	addi	t2,a3,1
    85a8:	1810                	addi	a2,sp,48
    85aa:	0e760763          	beq	a2,t2,8698 <_ftoa+0x1558>
    85ae:	869e                	mv	a3,t2
    85b0:	038ef8b3          	remu	a7,t4,s8
    85b4:	03088b1b          	addiw	s6,a7,48
    85b8:	01638023          	sb	s6,0(t2)
    85bc:	038ed733          	divu	a4,t4,s8
    85c0:	0ddffc63          	bgeu	t6,t4,8698 <_ftoa+0x1558>
    85c4:	038777b3          	remu	a5,a4,s8
    85c8:	03078e1b          	addiw	t3,a5,48
    85cc:	0816de0b          	th.sbib	t3,(a3),1,0
    85d0:	03875f33          	divu	t5,a4,s8
    85d4:	0ceff263          	bgeu	t6,a4,8698 <_ftoa+0x1558>
    85d8:	00238693          	addi	a3,t2,2
    85dc:	038f7333          	remu	t1,t5,s8
    85e0:	0303081b          	addiw	a6,t1,48
    85e4:	01038123          	sb	a6,2(t2)
    85e8:	038f5533          	divu	a0,t5,s8
    85ec:	0beff663          	bgeu	t6,t5,8698 <_ftoa+0x1558>
    85f0:	00338693          	addi	a3,t2,3
    85f4:	038572b3          	remu	t0,a0,s8
    85f8:	0302859b          	addiw	a1,t0,48
    85fc:	00b381a3          	sb	a1,3(t2)
    8600:	03855eb3          	divu	t4,a0,s8
    8604:	08affa63          	bgeu	t6,a0,8698 <_ftoa+0x1558>
    8608:	00438693          	addi	a3,t2,4
    860c:	038ef633          	remu	a2,t4,s8
    8610:	0306089b          	addiw	a7,a2,48
    8614:	01138223          	sb	a7,4(t2)
    8618:	038edb33          	divu	s6,t4,s8
    861c:	07dffe63          	bgeu	t6,t4,8698 <_ftoa+0x1558>
    8620:	00538693          	addi	a3,t2,5
    8624:	038b7733          	remu	a4,s6,s8
    8628:	0307079b          	addiw	a5,a4,48
    862c:	00f382a3          	sb	a5,5(t2)
    8630:	038b5e33          	divu	t3,s6,s8
    8634:	076ff263          	bgeu	t6,s6,8698 <_ftoa+0x1558>
    8638:	00638693          	addi	a3,t2,6
    863c:	038e7f33          	remu	t5,t3,s8
    8640:	030f031b          	addiw	t1,t5,48
    8644:	00638323          	sb	t1,6(t2)
    8648:	038e5833          	divu	a6,t3,s8
    864c:	05cff663          	bgeu	t6,t3,8698 <_ftoa+0x1558>
    8650:	00738693          	addi	a3,t2,7
    8654:	03887533          	remu	a0,a6,s8
    8658:	0305029b          	addiw	t0,a0,48
    865c:	005383a3          	sb	t0,7(t2)
    8660:	038855b3          	divu	a1,a6,s8
    8664:	030ffa63          	bgeu	t6,a6,8698 <_ftoa+0x1558>
    8668:	00838693          	addi	a3,t2,8
    866c:	0385feb3          	remu	t4,a1,s8
    8670:	030e861b          	addiw	a2,t4,48
    8674:	00c38423          	sb	a2,8(t2)
    8678:	0385d8b3          	divu	a7,a1,s8
    867c:	00bffe63          	bgeu	t6,a1,8698 <_ftoa+0x1558>
    8680:	00938693          	addi	a3,t2,9
    8684:	0388f2b3          	remu	t0,a7,s8
    8688:	0302859b          	addiw	a1,t0,48
    868c:	00b68023          	sb	a1,0(a3)
    8690:	0388deb3          	divu	t4,a7,s8
    8694:	f11fe8e3          	bltu	t6,a7,85a4 <_ftoa+0x1464>
    8698:	4c05                	li	s8,1
    869a:	414c0fb3          	sub	t6,s8,s4
    869e:	00df8b33          	add	s6,t6,a3
    86a2:	43ab7d63          	bgeu	s6,s10,8adc <_ftoa+0x199c>
    86a6:	016a07b3          	add	a5,s4,s6
    86aa:	01aa03b3          	add	t2,s4,s10
    86ae:	40f386b3          	sub	a3,t2,a5
    86b2:	0076fe13          	andi	t3,a3,7
    86b6:	03000713          	li	a4,48
    86ba:	380e0b63          	beqz	t3,8a50 <_ftoa+0x1910>
    86be:	038e0d63          	beq	t3,s8,86f8 <_ftoa+0x15b8>
    86c2:	4f09                	li	t5,2
    86c4:	03ee0863          	beq	t3,t5,86f4 <_ftoa+0x15b4>
    86c8:	430d                	li	t1,3
    86ca:	026e0363          	beq	t3,t1,86f0 <_ftoa+0x15b0>
    86ce:	4811                	li	a6,4
    86d0:	010e0e63          	beq	t3,a6,86ec <_ftoa+0x15ac>
    86d4:	4515                	li	a0,5
    86d6:	00ae0963          	beq	t3,a0,86e8 <_ftoa+0x15a8>
    86da:	4299                	li	t0,6
    86dc:	005e0463          	beq	t3,t0,86e4 <_ftoa+0x15a4>
    86e0:	1817d70b          	th.sbia	a4,(a5),1,0
    86e4:	1817d70b          	th.sbia	a4,(a5),1,0
    86e8:	1817d70b          	th.sbia	a4,(a5),1,0
    86ec:	1817d70b          	th.sbia	a4,(a5),1,0
    86f0:	1817d70b          	th.sbia	a4,(a5),1,0
    86f4:	1817d70b          	th.sbia	a4,(a5),1,0
    86f8:	1817d70b          	th.sbia	a4,(a5),1,0
    86fc:	34f39a63          	bne	t2,a5,8a50 <_ftoa+0x1910>
    8700:	020d0593          	addi	a1,s10,32
    8704:	01010e93          	addi	t4,sp,16
    8708:	001d0b13          	addi	s6,s10,1
    870c:	01d58633          	add	a2,a1,t4
    8710:	400cdc63          	bgez	s9,8b28 <_ftoa+0x19e8>
    8714:	02d00513          	li	a0,45
    8718:	fea60023          	sb	a0,-32(a2)
    871c:	016a0c33          	add	s8,s4,s6
    8720:	fffa4893          	not	a7,s4
    8724:	001a0c93          	addi	s9,s4,1
    8728:	01888fb3          	add	t6,a7,s8
    872c:	9de6                	add	s11,s11,s9
    872e:	007ffd13          	andi	s10,t6,7
    8732:	016d8cb3          	add	s9,s11,s6
    8736:	100d0663          	beqz	s10,8842 <_ftoa+0x1702>
    873a:	418c8633          	sub	a2,s9,s8
    873e:	86ca                	mv	a3,s2
    8740:	85a6                	mv	a1,s1
    8742:	9402                	jalr	s0
    8744:	4385                	li	t2,1
    8746:	1c7d                	addi	s8,s8,-1
    8748:	fffc4503          	lbu	a0,-1(s8)
    874c:	0e7d0b63          	beq	s10,t2,8842 <_ftoa+0x1702>
    8750:	4709                	li	a4,2
    8752:	06ed0663          	beq	s10,a4,87be <_ftoa+0x167e>
    8756:	468d                	li	a3,3
    8758:	04dd0b63          	beq	s10,a3,87ae <_ftoa+0x166e>
    875c:	4e11                	li	t3,4
    875e:	05cd0063          	beq	s10,t3,879e <_ftoa+0x165e>
    8762:	4f15                	li	t5,5
    8764:	03ed0563          	beq	s10,t5,878e <_ftoa+0x164e>
    8768:	4319                	li	t1,6
    876a:	006d0a63          	beq	s10,t1,877e <_ftoa+0x163e>
    876e:	418c8633          	sub	a2,s9,s8
    8772:	86ca                	mv	a3,s2
    8774:	85a6                	mv	a1,s1
    8776:	9402                	jalr	s0
    8778:	ffec4503          	lbu	a0,-2(s8)
    877c:	1c7d                	addi	s8,s8,-1
    877e:	418c8633          	sub	a2,s9,s8
    8782:	86ca                	mv	a3,s2
    8784:	85a6                	mv	a1,s1
    8786:	9402                	jalr	s0
    8788:	ffec4503          	lbu	a0,-2(s8)
    878c:	1c7d                	addi	s8,s8,-1
    878e:	418c8633          	sub	a2,s9,s8
    8792:	86ca                	mv	a3,s2
    8794:	85a6                	mv	a1,s1
    8796:	9402                	jalr	s0
    8798:	ffec4503          	lbu	a0,-2(s8)
    879c:	1c7d                	addi	s8,s8,-1
    879e:	418c8633          	sub	a2,s9,s8
    87a2:	86ca                	mv	a3,s2
    87a4:	85a6                	mv	a1,s1
    87a6:	9402                	jalr	s0
    87a8:	ffec4503          	lbu	a0,-2(s8)
    87ac:	1c7d                	addi	s8,s8,-1
    87ae:	418c8633          	sub	a2,s9,s8
    87b2:	86ca                	mv	a3,s2
    87b4:	85a6                	mv	a1,s1
    87b6:	9402                	jalr	s0
    87b8:	ffec4503          	lbu	a0,-2(s8)
    87bc:	1c7d                	addi	s8,s8,-1
    87be:	418c8633          	sub	a2,s9,s8
    87c2:	86ca                	mv	a3,s2
    87c4:	85a6                	mv	a1,s1
    87c6:	9402                	jalr	s0
    87c8:	1c7d                	addi	s8,s8,-1
    87ca:	fffc4503          	lbu	a0,-1(s8)
    87ce:	a895                	j	8842 <_ftoa+0x1702>
    87d0:	8de2                	mv	s11,s8
    87d2:	89edc50b          	th.lbuib	a0,(s11),-2,0
    87d6:	410c8633          	sub	a2,s9,a6
    87da:	86ca                	mv	a3,s2
    87dc:	85a6                	mv	a1,s1
    87de:	9402                	jalr	s0
    87e0:	8d62                	mv	s10,s8
    87e2:	89dd450b          	th.lbuib	a0,(s10),-3,0
    87e6:	41bc8633          	sub	a2,s9,s11
    87ea:	86ca                	mv	a3,s2
    87ec:	85a6                	mv	a1,s1
    87ee:	9402                	jalr	s0
    87f0:	8de2                	mv	s11,s8
    87f2:	89cdc50b          	th.lbuib	a0,(s11),-4,0
    87f6:	41ac8633          	sub	a2,s9,s10
    87fa:	86ca                	mv	a3,s2
    87fc:	85a6                	mv	a1,s1
    87fe:	9402                	jalr	s0
    8800:	8d62                	mv	s10,s8
    8802:	89bd450b          	th.lbuib	a0,(s10),-5,0
    8806:	41bc8633          	sub	a2,s9,s11
    880a:	86ca                	mv	a3,s2
    880c:	85a6                	mv	a1,s1
    880e:	9402                	jalr	s0
    8810:	8de2                	mv	s11,s8
    8812:	89adc50b          	th.lbuib	a0,(s11),-6,0
    8816:	41ac8633          	sub	a2,s9,s10
    881a:	86ca                	mv	a3,s2
    881c:	85a6                	mv	a1,s1
    881e:	9402                	jalr	s0
    8820:	8d62                	mv	s10,s8
    8822:	899d450b          	th.lbuib	a0,(s10),-7,0
    8826:	86ca                	mv	a3,s2
    8828:	41bc8633          	sub	a2,s9,s11
    882c:	85a6                	mv	a1,s1
    882e:	9402                	jalr	s0
    8830:	898c450b          	th.lbuib	a0,(s8),-8,0
    8834:	86ca                	mv	a3,s2
    8836:	41ac8633          	sub	a2,s9,s10
    883a:	85a6                	mv	a1,s1
    883c:	9402                	jalr	s0
    883e:	fffc4503          	lbu	a0,-1(s8)
    8842:	86ca                	mv	a3,s2
    8844:	418c8633          	sub	a2,s9,s8
    8848:	85a6                	mv	a1,s1
    884a:	9402                	jalr	s0
    884c:	fffc0813          	addi	a6,s8,-1
    8850:	f90a10e3          	bne	s4,a6,87d0 <_ftoa+0x1690>
    8854:	6a22                	ld	s4,8(sp)
    8856:	9b52                	add	s6,s6,s4
    8858:	140b8963          	beqz	s7,89aa <_ftoa+0x186a>
    885c:	413b09b3          	sub	s3,s6,s3
    8860:	7c0aba8b          	th.extu	s5,s5,31,0
    8864:	1559f363          	bgeu	s3,s5,89aa <_ftoa+0x186a>
    8868:	fff9cb93          	not	s7,s3
    886c:	015b8533          	add	a0,s7,s5
    8870:	865a                	mv	a2,s6
    8872:	00757d93          	andi	s11,a0,7
    8876:	86ca                	mv	a3,s2
    8878:	85a6                	mv	a1,s1
    887a:	02000513          	li	a0,32
    887e:	00198d13          	addi	s10,s3,1
    8882:	0b05                	addi	s6,s6,1
    8884:	9402                	jalr	s0
    8886:	135d7263          	bgeu	s10,s5,89aa <_ftoa+0x186a>
    888a:	080d8e63          	beqz	s11,8926 <_ftoa+0x17e6>
    888e:	4285                	li	t0,1
    8890:	085d8163          	beq	s11,t0,8912 <_ftoa+0x17d2>
    8894:	4789                	li	a5,2
    8896:	06fd8663          	beq	s11,a5,8902 <_ftoa+0x17c2>
    889a:	458d                	li	a1,3
    889c:	04bd8b63          	beq	s11,a1,88f2 <_ftoa+0x17b2>
    88a0:	4e91                	li	t4,4
    88a2:	05dd8063          	beq	s11,t4,88e2 <_ftoa+0x17a2>
    88a6:	4615                	li	a2,5
    88a8:	02cd8563          	beq	s11,a2,88d2 <_ftoa+0x1792>
    88ac:	4c99                	li	s9,6
    88ae:	019d8a63          	beq	s11,s9,88c2 <_ftoa+0x1782>
    88b2:	865a                	mv	a2,s6
    88b4:	86ca                	mv	a3,s2
    88b6:	85a6                	mv	a1,s1
    88b8:	02000513          	li	a0,32
    88bc:	0b05                	addi	s6,s6,1
    88be:	9402                	jalr	s0
    88c0:	0d05                	addi	s10,s10,1
    88c2:	865a                	mv	a2,s6
    88c4:	86ca                	mv	a3,s2
    88c6:	85a6                	mv	a1,s1
    88c8:	02000513          	li	a0,32
    88cc:	0b05                	addi	s6,s6,1
    88ce:	9402                	jalr	s0
    88d0:	0d05                	addi	s10,s10,1
    88d2:	865a                	mv	a2,s6
    88d4:	86ca                	mv	a3,s2
    88d6:	85a6                	mv	a1,s1
    88d8:	02000513          	li	a0,32
    88dc:	0b05                	addi	s6,s6,1
    88de:	9402                	jalr	s0
    88e0:	0d05                	addi	s10,s10,1
    88e2:	865a                	mv	a2,s6
    88e4:	86ca                	mv	a3,s2
    88e6:	85a6                	mv	a1,s1
    88e8:	02000513          	li	a0,32
    88ec:	0b05                	addi	s6,s6,1
    88ee:	9402                	jalr	s0
    88f0:	0d05                	addi	s10,s10,1
    88f2:	865a                	mv	a2,s6
    88f4:	86ca                	mv	a3,s2
    88f6:	85a6                	mv	a1,s1
    88f8:	02000513          	li	a0,32
    88fc:	0b05                	addi	s6,s6,1
    88fe:	9402                	jalr	s0
    8900:	0d05                	addi	s10,s10,1
    8902:	865a                	mv	a2,s6
    8904:	86ca                	mv	a3,s2
    8906:	85a6                	mv	a1,s1
    8908:	02000513          	li	a0,32
    890c:	0b05                	addi	s6,s6,1
    890e:	9402                	jalr	s0
    8910:	0d05                	addi	s10,s10,1
    8912:	865a                	mv	a2,s6
    8914:	86ca                	mv	a3,s2
    8916:	85a6                	mv	a1,s1
    8918:	02000513          	li	a0,32
    891c:	0d05                	addi	s10,s10,1
    891e:	0b05                	addi	s6,s6,1
    8920:	9402                	jalr	s0
    8922:	095d7463          	bgeu	s10,s5,89aa <_ftoa+0x186a>
    8926:	865a                	mv	a2,s6
    8928:	86ca                	mv	a3,s2
    892a:	85a6                	mv	a1,s1
    892c:	02000513          	li	a0,32
    8930:	9402                	jalr	s0
    8932:	001b0c13          	addi	s8,s6,1
    8936:	8662                	mv	a2,s8
    8938:	86ca                	mv	a3,s2
    893a:	85a6                	mv	a1,s1
    893c:	02000513          	li	a0,32
    8940:	9402                	jalr	s0
    8942:	002b0993          	addi	s3,s6,2
    8946:	86ca                	mv	a3,s2
    8948:	864e                	mv	a2,s3
    894a:	85a6                	mv	a1,s1
    894c:	02000513          	li	a0,32
    8950:	9402                	jalr	s0
    8952:	003b0a13          	addi	s4,s6,3
    8956:	86ca                	mv	a3,s2
    8958:	8652                	mv	a2,s4
    895a:	85a6                	mv	a1,s1
    895c:	02000513          	li	a0,32
    8960:	9402                	jalr	s0
    8962:	004b0b93          	addi	s7,s6,4
    8966:	86ca                	mv	a3,s2
    8968:	865e                	mv	a2,s7
    896a:	85a6                	mv	a1,s1
    896c:	02000513          	li	a0,32
    8970:	9402                	jalr	s0
    8972:	005b0d93          	addi	s11,s6,5
    8976:	86ca                	mv	a3,s2
    8978:	866e                	mv	a2,s11
    897a:	85a6                	mv	a1,s1
    897c:	02000513          	li	a0,32
    8980:	9402                	jalr	s0
    8982:	006b0c93          	addi	s9,s6,6
    8986:	86ca                	mv	a3,s2
    8988:	8666                	mv	a2,s9
    898a:	85a6                	mv	a1,s1
    898c:	02000513          	li	a0,32
    8990:	9402                	jalr	s0
    8992:	007b0c13          	addi	s8,s6,7
    8996:	86ca                	mv	a3,s2
    8998:	8662                	mv	a2,s8
    899a:	85a6                	mv	a1,s1
    899c:	02000513          	li	a0,32
    89a0:	0d21                	addi	s10,s10,8
    89a2:	0b21                	addi	s6,s6,8
    89a4:	9402                	jalr	s0
    89a6:	f95d60e3          	bltu	s10,s5,8926 <_ftoa+0x17e6>
    89aa:	7de2                	ld	s11,56(sp)
    89ac:	6d06                	ld	s10,64(sp)
    89ae:	c95fe06f          	j	7642 <_ftoa+0x502>
    89b2:	002b0633          	add	a2,s6,sp
    89b6:	02e00693          	li	a3,46
    89ba:	001b0f93          	addi	t6,s6,1
    89be:	00d60823          	sb	a3,16(a2)
    89c2:	f7ffe06f          	j	7940 <_ftoa+0x800>
    89c6:	0001                	nop
    89c8:	004a7813          	andi	a6,s4,4
    89cc:	02080e63          	beqz	a6,8a08 <_ftoa+0x18c8>
    89d0:	002f8f33          	add	t5,t6,sp
    89d4:	001f8b13          	addi	s6,t6,1
    89d8:	02b00f93          	li	t6,43
    89dc:	01ff0823          	sb	t6,16(t5)
    89e0:	faaff06f          	j	818a <_ftoa+0x104a>
    89e4:	8d4e                	mv	s10,s3
    89e6:	02000b13          	li	s6,32
    89ea:	a26ff06f          	j	7c10 <_ftoa+0xad0>
    89ee:	0001                	nop
    89f0:	0f536d63          	bltu	t1,s5,8aea <_ftoa+0x19aa>
    89f4:	017a7fb3          	and	t6,s4,s7
    89f8:	b00f94e3          	bnez	t6,8500 <_ftoa+0x13c0>
    89fc:	4b81                	li	s7,0
    89fe:	b609                	j	8500 <_ftoa+0x13c0>
    8a00:	4585                	li	a1,1
    8a02:	0001                	nop
    8a04:	00000013          	nop
    8a08:	008a7513          	andi	a0,s4,8
    8a0c:	8b7e                	mv	s6,t6
    8a0e:	f6050e63          	beqz	a0,818a <_ftoa+0x104a>
    8a12:	002f8cb3          	add	s9,t6,sp
    8a16:	02000d13          	li	s10,32
    8a1a:	001f8b13          	addi	s6,t6,1
    8a1e:	01ac8823          	sb	s10,16(s9)
    8a22:	f68ff06f          	j	818a <_ftoa+0x104a>
    8a26:	0001                	nop
    8a28:	0016f893          	andi	a7,a3,1
    8a2c:	00089463          	bnez	a7,8a34 <_ftoa+0x18f4>
    8a30:	8c9fe06f          	j	72f8 <_ftoa+0x1b8>
    8a34:	0685                	addi	a3,a3,1
    8a36:	ee7fe06f          	j	791c <_ftoa+0x7dc>
    8a3a:	0001                	nop
    8a3c:	417c8633          	sub	a2,s9,s7
    8a40:	89fbc50b          	th.lbuib	a0,(s7),-1,0
    8a44:	86ca                	mv	a3,s2
    8a46:	85a6                	mv	a1,s1
    8a48:	9402                	jalr	s0
    8a4a:	9fcff06f          	j	7c46 <_ftoa+0xb06>
    8a4e:	0001                	nop
    8a50:	00e78023          	sb	a4,0(a5)
    8a54:	00e780a3          	sb	a4,1(a5)
    8a58:	00e78123          	sb	a4,2(a5)
    8a5c:	00e781a3          	sb	a4,3(a5)
    8a60:	00e78223          	sb	a4,4(a5)
    8a64:	00e782a3          	sb	a4,5(a5)
    8a68:	00e78323          	sb	a4,6(a5)
    8a6c:	00e783a3          	sb	a4,7(a5)
    8a70:	07a1                	addi	a5,a5,8
    8a72:	fcf39fe3          	bne	t2,a5,8a50 <_ftoa+0x1910>
    8a76:	b169                	j	8700 <_ftoa+0x15c0>
    8a78:	02000b13          	li	s6,32
    8a7c:	8d4e                	mv	s10,s3
    8a7e:	992ff06f          	j	7c10 <_ftoa+0xad0>
    8a82:	0001                	nop
    8a84:	02000b13          	li	s6,32
    8a88:	f02ff06f          	j	818a <_ftoa+0x104a>
    8a8c:	22a51e53          	fneg.d	ft8,fa0
    8a90:	fc6e                	sd	s11,56(sp)
    8a92:	e20e06d3          	fmv.x.d	a3,ft8
    8a96:	b225                	j	83be <_ftoa+0x127e>
    8a98:	02000b13          	li	s6,32
    8a9c:	00ca7e93          	andi	t4,s4,12
    8aa0:	060e8b63          	beqz	t4,8b16 <_ftoa+0x19d6>
    8aa4:	3afd                	addiw	s5,s5,-1
    8aa6:	7c0abf8b          	th.extu	t6,s5,31,0
    8aaa:	87fb6163          	bltu	s6,t6,7b0c <_ftoa+0x9cc>
    8aae:	02000393          	li	t2,32
    8ab2:	947b0e63          	beq	s6,t2,7c0e <_ftoa+0xace>
    8ab6:	004a7813          	andi	a6,s4,4
    8aba:	06080e63          	beqz	a6,8b36 <_ftoa+0x19f6>
    8abe:	020b0e13          	addi	t3,s6,32
    8ac2:	01010f13          	addi	t5,sp,16
    8ac6:	01ee0fb3          	add	t6,t3,t5
    8aca:	02b00313          	li	t1,43
    8ace:	fe6f8023          	sb	t1,-32(t6)
    8ad2:	0b05                	addi	s6,s6,1
    8ad4:	8d4e                	mv	s10,s3
    8ad6:	93aff06f          	j	7c10 <_ftoa+0xad0>
    8ada:	0001                	nop
    8adc:	02000d13          	li	s10,32
    8ae0:	05ab1963          	bne	s6,s10,8b32 <_ftoa+0x19f2>
    8ae4:	02f14503          	lbu	a0,47(sp)
    8ae8:	b915                	j	871c <_ftoa+0x15dc>
    8aea:	002a7293          	andi	t0,s4,2
    8aee:	a00299e3          	bnez	t0,8500 <_ftoa+0x13c0>
    8af2:	406a87bb          	subw	a5,s5,t1
    8af6:	4b81                	li	s7,0
    8af8:	b421                	j	8500 <_ftoa+0x13c0>
    8afa:	004a7813          	andi	a6,s4,4
    8afe:	f00801e3          	beqz	a6,8a00 <_ftoa+0x18c0>
    8b02:	0b05                	addi	s6,s6,1
    8b04:	002f8833          	add	a6,t6,sp
    8b08:	02b00713          	li	a4,43
    8b0c:	00e80823          	sb	a4,16(a6)
    8b10:	8d4e                	mv	s10,s3
    8b12:	8feff06f          	j	7c10 <_ftoa+0xad0>
    8b16:	7c0abf8b          	th.extu	t6,s5,31,0
    8b1a:	01fb7463          	bgeu	s6,t6,8b22 <_ftoa+0x19e2>
    8b1e:	feffe06f          	j	7b0c <_ftoa+0x9cc>
    8b22:	8d4e                	mv	s10,s3
    8b24:	8ecff06f          	j	7c10 <_ftoa+0xad0>
    8b28:	02b00513          	li	a0,43
    8b2c:	fea60023          	sb	a0,-32(a2)
    8b30:	b6f5                	j	871c <_ftoa+0x15dc>
    8b32:	8d5a                	mv	s10,s6
    8b34:	b6f1                	j	8700 <_ftoa+0x15c0>
    8b36:	008a7893          	andi	a7,s4,8
    8b3a:	8c088a63          	beqz	a7,7c0e <_ftoa+0xace>
    8b3e:	8fda                	mv	t6,s6
    8b40:	4585                	li	a1,1
    8b42:	bdc1                	j	8a12 <_ftoa+0x18d2>
    8b44:	000a8d63          	beqz	s5,8b5e <_ftoa+0x1a1e>
    8b48:	06080c63          	beqz	a6,8bc0 <_ftoa+0x1a80>
    8b4c:	3afd                	addiw	s5,s5,-1
    8b4e:	7c0ab68b          	th.extu	a3,s5,31,0
    8b52:	04dff463          	bgeu	t6,a3,8b9a <_ftoa+0x1a5a>
    8b56:	8b7e                	mv	s6,t6
    8b58:	8fb6                	mv	t6,a3
    8b5a:	fb3fe06f          	j	7b0c <_ftoa+0x9cc>
    8b5e:	02000b93          	li	s7,32
    8b62:	037f8863          	beq	t6,s7,8b92 <_ftoa+0x1a52>
    8b66:	00080f63          	beqz	a6,8b84 <_ftoa+0x1a44>
    8b6a:	017f8d33          	add	s10,t6,s7
    8b6e:	002d05b3          	add	a1,s10,sp
    8b72:	02d00793          	li	a5,45
    8b76:	001f8b13          	addi	s6,t6,1
    8b7a:	fef58823          	sb	a5,-16(a1)
    8b7e:	8d4e                	mv	s10,s3
    8b80:	890ff06f          	j	7c10 <_ftoa+0xad0>
    8b84:	004a7c93          	andi	s9,s4,4
    8b88:	001f8b13          	addi	s6,t6,1
    8b8c:	f60c9ce3          	bnez	s9,8b04 <_ftoa+0x19c4>
    8b90:	bda5                	j	8a08 <_ftoa+0x18c8>
    8b92:	8b7e                	mv	s6,t6
    8b94:	8d4e                	mv	s10,s3
    8b96:	87aff06f          	j	7c10 <_ftoa+0xad0>
    8b9a:	02000713          	li	a4,32
    8b9e:	feef8ae3          	beq	t6,a4,8b92 <_ftoa+0x1a52>
    8ba2:	00ef8533          	add	a0,t6,a4
    8ba6:	01010b93          	addi	s7,sp,16
    8baa:	02d00d13          	li	s10,45
    8bae:	01750cb3          	add	s9,a0,s7
    8bb2:	ffac8023          	sb	s10,-32(s9)
    8bb6:	01df8b33          	add	s6,t6,t4
    8bba:	8d4e                	mv	s10,s3
    8bbc:	854ff06f          	j	7c10 <_ftoa+0xad0>
    8bc0:	8b7e                	mv	s6,t6
    8bc2:	bde9                	j	8a9c <_ftoa+0x195c>
    8bc4:	00000013          	nop
    8bc8:	00000013          	nop
    8bcc:	00000013          	nop

0000000000008bd0 <_vsnprintf>:
    8bd0:	7131                	addi	sp,sp,-192
    8bd2:	f526                	sd	s1,168(sp)
    8bd4:	f922                	sd	s0,176(sp)
    8bd6:	641d                	lui	s0,0x7
    8bd8:	ed4e                	sd	s3,152(sp)
    8bda:	f14a                	sd	s2,160(sp)
    8bdc:	fd06                	sd	ra,184(sp)
    8bde:	11040413          	addi	s0,s0,272 # 7110 <_out_null>
    8be2:	42b5140b          	th.mvnez	s0,a0,a1
    8be6:	0006c503          	lbu	a0,0(a3)
    8bea:	4381                	li	t2,0
    8bec:	892e                	mv	s2,a1
    8bee:	84b2                	mv	s1,a2
    8bf0:	e119                	bnez	a0,8bf6 <_vsnprintf+0x26>
    8bf2:	3550106f          	j	a746 <_vsnprintf+0x1b76>
    8bf6:	67c5                	lui	a5,0x11
    8bf8:	c6c78293          	addi	t0,a5,-916 # 10c6c <errpat+0x124>
    8bfc:	e556                	sd	s5,136(sp)
    8bfe:	e952                	sd	s4,144(sp)
    8c00:	6a45                	lui	s4,0x11
    8c02:	ecee                	sd	s11,88(sp)
    8c04:	f0ea                	sd	s10,96(sp)
    8c06:	f4e6                	sd	s9,104(sp)
    8c08:	f8e2                	sd	s8,112(sp)
    8c0a:	fcde                	sd	s7,120(sp)
    8c0c:	e15a                	sd	s6,128(sp)
    8c0e:	49c1                	li	s3,16
    8c10:	e01e                	sd	t2,0(sp)
    8c12:	e816                	sd	t0,16(sp)
    8c14:	8cb6                	mv	s9,a3
    8c16:	8dba                	mv	s11,a4
    8c18:	c28a0a13          	addi	s4,s4,-984 # 10c28 <errpat+0xe0>
    8c1c:	a831                	j	8c38 <_vsnprintf+0x68>
    8c1e:	0001                	nop
    8c20:	6602                	ld	a2,0(sp)
    8c22:	86a6                	mv	a3,s1
    8c24:	85ca                	mv	a1,s2
    8c26:	00160c13          	addi	s8,a2,1
    8c2a:	0c85                	addi	s9,s9,1
    8c2c:	9402                	jalr	s0
    8c2e:	e062                	sd	s8,0(sp)
    8c30:	000cc503          	lbu	a0,0(s9)
    8c34:	1c050263          	beqz	a0,8df8 <_vsnprintf+0x228>
    8c38:	02500313          	li	t1,37
    8c3c:	fe6512e3          	bne	a0,t1,8c20 <_vsnprintf+0x50>
    8c40:	002c8893          	addi	a7,s9,2
    8c44:	4b01                	li	s6,0
    8c46:	0001                	nop
    8c48:	fff8c503          	lbu	a0,-1(a7)
    8c4c:	fe05071b          	addiw	a4,a0,-32
    8c50:	0ff77393          	zext.b	t2,a4
    8c54:	0079e663          	bltu	s3,t2,8c60 <_vsnprintf+0x90>
    8c58:	447a458b          	th.lrw	a1,s4,t2,2
    8c5c:	8582                	jr	a1
    8c5e:	0001                	nop
    8c60:	fff88a93          	addi	s5,a7,-1
    8c64:	fd050c1b          	addiw	s8,a0,-48
    8c68:	4ba5                	li	s7,9
    8c6a:	e456                	sd	s5,8(sp)
    8c6c:	0ffc7c93          	zext.b	s9,s8
    8c70:	0b9bf663          	bgeu	s7,s9,8d1c <_vsnprintf+0x14c>
    8c74:	02a00d13          	li	s10,42
    8c78:	4881                	li	a7,0
    8c7a:	35a50163          	beq	a0,s10,8fbc <_vsnprintf+0x3ec>
    8c7e:	02e00f93          	li	t6,46
    8c82:	4c01                	li	s8,0
    8c84:	15f50363          	beq	a0,t6,8dca <_vsnprintf+0x1fa>
    8c88:	f985081b          	addiw	a6,a0,-104
    8c8c:	0ff87f93          	zext.b	t6,a6
    8c90:	4ac9                	li	s5,18
    8c92:	05faef63          	bltu	s5,t6,8cf0 <_vsnprintf+0x120>
    8c96:	6bc2                	ld	s7,16(sp)
    8c98:	45fbcc8b          	th.lrw	s9,s7,t6,2
    8c9c:	8c82                	jr	s9
    8c9e:	0001                	nop
    8ca0:	001b6b13          	ori	s6,s6,1
    8ca4:	2b01                	sext.w	s6,s6
    8ca6:	0885                	addi	a7,a7,1
    8ca8:	b745                	j	8c48 <_vsnprintf+0x78>
    8caa:	0001                	nop
    8cac:	002b6513          	ori	a0,s6,2
    8cb0:	00050b1b          	sext.w	s6,a0
    8cb4:	0885                	addi	a7,a7,1
    8cb6:	bf49                	j	8c48 <_vsnprintf+0x78>
    8cb8:	004b6613          	ori	a2,s6,4
    8cbc:	00060b1b          	sext.w	s6,a2
    8cc0:	0885                	addi	a7,a7,1
    8cc2:	b759                	j	8c48 <_vsnprintf+0x78>
    8cc4:	010b6693          	ori	a3,s6,16
    8cc8:	00068b1b          	sext.w	s6,a3
    8ccc:	0885                	addi	a7,a7,1
    8cce:	bfad                	j	8c48 <_vsnprintf+0x78>
    8cd0:	008b6813          	ori	a6,s6,8
    8cd4:	00080b1b          	sext.w	s6,a6
    8cd8:	0885                	addi	a7,a7,1
    8cda:	b7bd                	j	8c48 <_vsnprintf+0x78>
    8cdc:	6322                	ld	t1,8(sp)
    8cde:	100b6693          	ori	a3,s6,256
    8ce2:	00068b1b          	sext.w	s6,a3
    8ce6:	00134503          	lbu	a0,1(t1)
    8cea:	00130393          	addi	t2,t1,1
    8cee:	e41e                	sd	t2,8(sp)
    8cf0:	06700a93          	li	s5,103
    8cf4:	14aae063          	bltu	s5,a0,8e34 <_vsnprintf+0x264>
    8cf8:	02400d13          	li	s10,36
    8cfc:	2cad7c63          	bgeu	s10,a0,8fd4 <_vsnprintf+0x404>
    8d00:	fdb50c9b          	addiw	s9,a0,-37
    8d04:	0ffcf693          	zext.b	a3,s9
    8d08:	04200393          	li	t2,66
    8d0c:	2cd3e463          	bltu	t2,a3,8fd4 <_vsnprintf+0x404>
    8d10:	6345                	lui	t1,0x11
    8d12:	cb830813          	addi	a6,t1,-840 # 10cb8 <errpat+0x170>
    8d16:	44d84f8b          	th.lrw	t6,a6,a3,2
    8d1a:	8f82                	jr	t6
    8d1c:	66a2                	ld	a3,8(sp)
    8d1e:	4881                	li	a7,0
    8d20:	8fde                	mv	t6,s7
    8d22:	0028929b          	slliw	t0,a7,0x2
    8d26:	0112833b          	addw	t1,t0,a7
    8d2a:	0685                	addi	a3,a3,1
    8d2c:	0013171b          	slliw	a4,t1,0x1
    8d30:	00a703bb          	addw	t2,a4,a0
    8d34:	0006c503          	lbu	a0,0(a3)
    8d38:	87b6                	mv	a5,a3
    8d3a:	fd03889b          	addiw	a7,t2,-48
    8d3e:	fd05059b          	addiw	a1,a0,-48
    8d42:	0ff5f613          	zext.b	a2,a1
    8d46:	06cfec63          	bltu	t6,a2,8dbe <_vsnprintf+0x1ee>
    8d4a:	0028981b          	slliw	a6,a7,0x2
    8d4e:	011808bb          	addw	a7,a6,a7
    8d52:	00189a9b          	slliw	s5,a7,0x1
    8d56:	00aa853b          	addw	a0,s5,a0
    8d5a:	fd05089b          	addiw	a7,a0,-48
    8d5e:	8816c50b          	th.lbuib	a0,(a3),1,0
    8d62:	fd050b9b          	addiw	s7,a0,-48
    8d66:	0ffbfc13          	zext.b	s8,s7
    8d6a:	058fea63          	bltu	t6,s8,8dbe <_vsnprintf+0x1ee>
    8d6e:	00289c9b          	slliw	s9,a7,0x2
    8d72:	011c8d3b          	addw	s10,s9,a7
    8d76:	001d1e1b          	slliw	t3,s10,0x1
    8d7a:	00ae0ebb          	addw	t4,t3,a0
    8d7e:	0027c503          	lbu	a0,2(a5)
    8d82:	00278693          	addi	a3,a5,2
    8d86:	fd0e889b          	addiw	a7,t4,-48
    8d8a:	fd050f1b          	addiw	t5,a0,-48
    8d8e:	0fff7293          	zext.b	t0,t5
    8d92:	025fe663          	bltu	t6,t0,8dbe <_vsnprintf+0x1ee>
    8d96:	0028931b          	slliw	t1,a7,0x2
    8d9a:	0113073b          	addw	a4,t1,a7
    8d9e:	0017139b          	slliw	t2,a4,0x1
    8da2:	00a385bb          	addw	a1,t2,a0
    8da6:	0037c503          	lbu	a0,3(a5)
    8daa:	00378693          	addi	a3,a5,3
    8dae:	fd05889b          	addiw	a7,a1,-48
    8db2:	fd05079b          	addiw	a5,a0,-48
    8db6:	0ff7f613          	zext.b	a2,a5
    8dba:	f6cff4e3          	bgeu	t6,a2,8d22 <_vsnprintf+0x152>
    8dbe:	e436                	sd	a3,8(sp)
    8dc0:	02e00f93          	li	t6,46
    8dc4:	4c01                	li	s8,0
    8dc6:	edf511e3          	bne	a0,t6,8c88 <_vsnprintf+0xb8>
    8dca:	6aa2                	ld	s5,8(sp)
    8dcc:	400b6b13          	ori	s6,s6,1024
    8dd0:	4825                	li	a6,9
    8dd2:	001ac503          	lbu	a0,1(s5)
    8dd6:	2b01                	sext.w	s6,s6
    8dd8:	001a8713          	addi	a4,s5,1
    8ddc:	fd050b9b          	addiw	s7,a0,-48
    8de0:	0ffbfc93          	zext.b	s9,s7
    8de4:	21987463          	bgeu	a6,s9,8fec <_vsnprintf+0x41c>
    8de8:	02a00d13          	li	s10,42
    8dec:	01a51463          	bne	a0,s10,8df4 <_vsnprintf+0x224>
    8df0:	7c70006f          	j	9db6 <_vsnprintf+0x11e6>
    8df4:	e43a                	sd	a4,8(sp)
    8df6:	bd49                	j	8c88 <_vsnprintf+0xb8>
    8df8:	6382                	ld	t2,0(sp)
    8dfa:	6de6                	ld	s11,88(sp)
    8dfc:	7d06                	ld	s10,96(sp)
    8dfe:	7ca6                	ld	s9,104(sp)
    8e00:	7c46                	ld	s8,112(sp)
    8e02:	7be6                	ld	s7,120(sp)
    8e04:	6b0a                	ld	s6,128(sp)
    8e06:	6aaa                	ld	s5,136(sp)
    8e08:	6a4a                	ld	s4,144(sp)
    8e0a:	0003899b          	sext.w	s3,t2
    8e0e:	0093b7b3          	sltu	a5,t2,s1
    8e12:	fff48613          	addi	a2,s1,-1
    8e16:	86a6                	mv	a3,s1
    8e18:	85ca                	mv	a1,s2
    8e1a:	4501                	li	a0,0
    8e1c:	42f3960b          	th.mvnez	a2,t2,a5
    8e20:	9402                	jalr	s0
    8e22:	70ea                	ld	ra,184(sp)
    8e24:	74aa                	ld	s1,168(sp)
    8e26:	744a                	ld	s0,176(sp)
    8e28:	854e                	mv	a0,s3
    8e2a:	69ea                	ld	s3,152(sp)
    8e2c:	790a                	ld	s2,160(sp)
    8e2e:	6129                	addi	sp,sp,192
    8e30:	8082                	ret
    8e32:	0001                	nop
    8e34:	f9750b9b          	addiw	s7,a0,-105
    8e38:	0ffbfc93          	zext.b	s9,s7
    8e3c:	4d3d                	li	s10,15
    8e3e:	199d6b63          	bltu	s10,s9,8fd4 <_vsnprintf+0x404>
    8e42:	4e05                	li	t3,1
    8e44:	62a5                	lui	t0,0x9
    8e46:	019e1eb3          	sll	t4,t3,s9
    8e4a:	04128693          	addi	a3,t0,65 # 9041 <_vsnprintf+0x471>
    8e4e:	00def7b3          	and	a5,t4,a3
    8e52:	72079de3          	bnez	a5,9d8c <_vsnprintf+0x11bc>
    8e56:	4fa9                	li	t6,10
    8e58:	23fc8a63          	beq	s9,t6,908c <_vsnprintf+0x4bc>
    8e5c:	439d                	li	t2,7
    8e5e:	167c9b63          	bne	s9,t2,8fd4 <_vsnprintf+0x404>
    8e62:	788dc28b          	th.ldia	t0,(s11),8,0
    8e66:	760288e3          	beqz	t0,9dd6 <_vsnprintf+0x1206>
    8e6a:	021b6f13          	ori	t5,s6,33
    8e6e:	000f059b          	sext.w	a1,t5
    8e72:	400b7c93          	andi	s9,s6,1024
    8e76:	010b7b93          	andi	s7,s6,16
    8e7a:	453d                	li	a0,15
    8e7c:	00a2f333          	and	t1,t0,a0
    8e80:	43a5                	li	t2,9
    8e82:	03030d13          	addi	s10,t1,48
    8e86:	03730f13          	addi	t5,t1,55
    8e8a:	0063b633          	sltu	a2,t2,t1
    8e8e:	40cd1f0b          	th.mveqz	t5,s10,a2
    8e92:	03e10823          	sb	t5,48(sp)
    8e96:	03010b13          	addi	s6,sp,48
    8e9a:	02000893          	li	a7,32
    8e9e:	4d05                	li	s10,1
    8ea0:	0042d813          	srli	a6,t0,0x4
    8ea4:	00556463          	bltu	a0,t0,8eac <_vsnprintf+0x2dc>
    8ea8:	6180106f          	j	a4c0 <_vsnprintf+0x18f0>
    8eac:	00f87f93          	andi	t6,a6,15
    8eb0:	030f8a93          	addi	s5,t6,48
    8eb4:	037f8e93          	addi	t4,t6,55
    8eb8:	01f3b2b3          	sltu	t0,t2,t6
    8ebc:	405a9e8b          	th.mveqz	t4,s5,t0
    8ec0:	03d108a3          	sb	t4,49(sp)
    8ec4:	87ea                	mv	a5,s10
    8ec6:	00485313          	srli	t1,a6,0x4
    8eca:	4d09                	li	s10,2
    8ecc:	01056463          	bltu	a0,a6,8ed4 <_vsnprintf+0x304>
    8ed0:	5f00106f          	j	a4c0 <_vsnprintf+0x18f0>
    8ed4:	00f37f13          	andi	t5,t1,15
    8ed8:	030f0813          	addi	a6,t5,48
    8edc:	037f0713          	addi	a4,t5,55
    8ee0:	01e3bfb3          	sltu	t6,t2,t5
    8ee4:	41f8170b          	th.mveqz	a4,a6,t6
    8ee8:	02e10923          	sb	a4,50(sp)
    8eec:	87ea                	mv	a5,s10
    8eee:	00435e13          	srli	t3,t1,0x4
    8ef2:	0d05                	addi	s10,s10,1
    8ef4:	00656463          	bltu	a0,t1,8efc <_vsnprintf+0x32c>
    8ef8:	5c80106f          	j	a4c0 <_vsnprintf+0x18f0>
    8efc:	03310613          	addi	a2,sp,51
    8f00:	87ea                	mv	a5,s10
    8f02:	8772                	mv	a4,t3
    8f04:	00000013          	nop
    8f08:	00f77d13          	andi	s10,a4,15
    8f0c:	030d0e93          	addi	t4,s10,48
    8f10:	037d0293          	addi	t0,s10,55
    8f14:	01a3b333          	sltu	t1,t2,s10
    8f18:	406e928b          	th.mveqz	t0,t4,t1
    8f1c:	00560023          	sb	t0,0(a2)
    8f20:	00178d13          	addi	s10,a5,1
    8f24:	00475f13          	srli	t5,a4,0x4
    8f28:	00e56463          	bltu	a0,a4,8f30 <_vsnprintf+0x360>
    8f2c:	5940106f          	j	a4c0 <_vsnprintf+0x18f0>
    8f30:	011d1463          	bne	s10,a7,8f38 <_vsnprintf+0x368>
    8f34:	1750106f          	j	a8a8 <_vsnprintf+0x1cd8>
    8f38:	00ff7f93          	andi	t6,t5,15
    8f3c:	886a                	mv	a6,s10
    8f3e:	87ea                	mv	a5,s10
    8f40:	030f8e13          	addi	t3,t6,48
    8f44:	01f3bd33          	sltu	s10,t2,t6
    8f48:	037f8a93          	addi	s5,t6,55
    8f4c:	41ae1a8b          	th.mveqz	s5,t3,s10
    8f50:	015600a3          	sb	s5,1(a2)
    8f54:	00180d13          	addi	s10,a6,1
    8f58:	00875e93          	srli	t4,a4,0x8
    8f5c:	01e56463          	bltu	a0,t5,8f64 <_vsnprintf+0x394>
    8f60:	5600106f          	j	a4c0 <_vsnprintf+0x18f0>
    8f64:	00fef313          	andi	t1,t4,15
    8f68:	03030293          	addi	t0,t1,48
    8f6c:	03730f93          	addi	t6,t1,55
    8f70:	0063b6b3          	sltu	a3,t2,t1
    8f74:	40d29f8b          	th.mveqz	t6,t0,a3
    8f78:	01f60123          	sb	t6,2(a2)
    8f7c:	87ea                	mv	a5,s10
    8f7e:	00c75e13          	srli	t3,a4,0xc
    8f82:	0d05                	addi	s10,s10,1
    8f84:	01d56463          	bltu	a0,t4,8f8c <_vsnprintf+0x3bc>
    8f88:	5380106f          	j	a4c0 <_vsnprintf+0x18f0>
    8f8c:	00fe7a93          	andi	s5,t3,15
    8f90:	030a8e93          	addi	t4,s5,48
    8f94:	037a8313          	addi	t1,s5,55
    8f98:	0153bf33          	sltu	t5,t2,s5
    8f9c:	41ee930b          	th.mveqz	t1,t4,t5
    8fa0:	006601a3          	sb	t1,3(a2)
    8fa4:	00280793          	addi	a5,a6,2
    8fa8:	00380d13          	addi	s10,a6,3
    8fac:	8341                	srli	a4,a4,0x10
    8fae:	01c56463          	bltu	a0,t3,8fb6 <_vsnprintf+0x3e6>
    8fb2:	50e0106f          	j	a4c0 <_vsnprintf+0x18f0>
    8fb6:	0611                	addi	a2,a2,4
    8fb8:	87ea                	mv	a5,s10
    8fba:	b7b9                	j	8f08 <_vsnprintf+0x338>
    8fbc:	588dc88b          	th.lwia	a7,(s11),8,0
    8fc0:	4e08c463          	bltz	a7,94a8 <_vsnprintf+0x8d8>
    8fc4:	6ea2                	ld	t4,8(sp)
    8fc6:	001e8f13          	addi	t5,t4,1
    8fca:	001ec503          	lbu	a0,1(t4)
    8fce:	e47a                	sd	t5,8(sp)
    8fd0:	b17d                	j	8c7e <_vsnprintf+0xae>
    8fd2:	0001                	nop
    8fd4:	6602                	ld	a2,0(sp)
    8fd6:	86a6                	mv	a3,s1
    8fd8:	85ca                	mv	a1,s2
    8fda:	00160d13          	addi	s10,a2,1
    8fde:	9402                	jalr	s0
    8fe0:	6fa2                	ld	t6,8(sp)
    8fe2:	e06a                	sd	s10,0(sp)
    8fe4:	001f8c93          	addi	s9,t6,1
    8fe8:	b1a1                	j	8c30 <_vsnprintf+0x60>
    8fea:	0001                	nop
    8fec:	002c129b          	slliw	t0,s8,0x2
    8ff0:	018286bb          	addw	a3,t0,s8
    8ff4:	0705                	addi	a4,a4,1
    8ff6:	0016931b          	slliw	t1,a3,0x1
    8ffa:	00a303bb          	addw	t2,t1,a0
    8ffe:	00074503          	lbu	a0,0(a4)
    9002:	8f3a                	mv	t5,a4
    9004:	fd038c1b          	addiw	s8,t2,-48
    9008:	fd05059b          	addiw	a1,a0,-48
    900c:	0ff5f793          	zext.b	a5,a1
    9010:	def862e3          	bltu	a6,a5,8df4 <_vsnprintf+0x224>
    9014:	002c161b          	slliw	a2,s8,0x2
    9018:	01860fbb          	addw	t6,a2,s8
    901c:	001f9a9b          	slliw	s5,t6,0x1
    9020:	00aa8bbb          	addw	s7,s5,a0
    9024:	8817450b          	th.lbuib	a0,(a4),1,0
    9028:	fd0b8c1b          	addiw	s8,s7,-48
    902c:	fd050c9b          	addiw	s9,a0,-48
    9030:	0ffcfd13          	zext.b	s10,s9
    9034:	dda860e3          	bltu	a6,s10,8df4 <_vsnprintf+0x224>
    9038:	002c1e1b          	slliw	t3,s8,0x2
    903c:	018e0c3b          	addw	s8,t3,s8
    9040:	001c1e9b          	slliw	t4,s8,0x1
    9044:	00ae853b          	addw	a0,t4,a0
    9048:	fd050c1b          	addiw	s8,a0,-48
    904c:	002f4503          	lbu	a0,2(t5)
    9050:	002f0713          	addi	a4,t5,2
    9054:	fd05029b          	addiw	t0,a0,-48
    9058:	0ff2f693          	zext.b	a3,t0
    905c:	d8d86ce3          	bltu	a6,a3,8df4 <_vsnprintf+0x224>
    9060:	002c131b          	slliw	t1,s8,0x2
    9064:	018303bb          	addw	t2,t1,s8
    9068:	0013959b          	slliw	a1,t2,0x1
    906c:	00a587bb          	addw	a5,a1,a0
    9070:	003f4503          	lbu	a0,3(t5)
    9074:	003f0713          	addi	a4,t5,3
    9078:	fd078c1b          	addiw	s8,a5,-48
    907c:	fd050f1b          	addiw	t5,a0,-48
    9080:	0fff7613          	zext.b	a2,t5
    9084:	f6c874e3          	bgeu	a6,a2,8fec <_vsnprintf+0x41c>
    9088:	e43a                	sd	a4,8(sp)
    908a:	befd                	j	8c88 <_vsnprintf+0xb8>
    908c:	788dcd0b          	th.ldia	s10,(s11),8,0
    9090:	7c0c3a8b          	th.extu	s5,s8,31,0
    9094:	5bfd                	li	s7,-1
    9096:	000d4503          	lbu	a0,0(s10)
    909a:	418b9a8b          	th.mveqz	s5,s7,s8
    909e:	015d0cb3          	add	s9,s10,s5
    90a2:	87ea                	mv	a5,s10
    90a4:	e119                	bnez	a0,90aa <_vsnprintf+0x4da>
    90a6:	2650206f          	j	bb0a <_vsnprintf+0x2f3a>
    90aa:	41ac8eb3          	sub	t4,s9,s10
    90ae:	007ef293          	andi	t0,t4,7
    90b2:	04028e63          	beqz	t0,910e <_vsnprintf+0x53e>
    90b6:	001d4683          	lbu	a3,1(s10)
    90ba:	001d0793          	addi	a5,s10,1
    90be:	c6d5                	beqz	a3,916a <_vsnprintf+0x59a>
    90c0:	05c28763          	beq	t0,t3,910e <_vsnprintf+0x53e>
    90c4:	4309                	li	t1,2
    90c6:	04628063          	beq	t0,t1,9106 <_vsnprintf+0x536>
    90ca:	438d                	li	t2,3
    90cc:	02728963          	beq	t0,t2,90fe <_vsnprintf+0x52e>
    90d0:	4f11                	li	t5,4
    90d2:	03e28263          	beq	t0,t5,90f6 <_vsnprintf+0x526>
    90d6:	4595                	li	a1,5
    90d8:	00b28b63          	beq	t0,a1,90ee <_vsnprintf+0x51e>
    90dc:	4619                	li	a2,6
    90de:	00c28463          	beq	t0,a2,90e6 <_vsnprintf+0x516>
    90e2:	7a90106f          	j	b08a <_vsnprintf+0x24ba>
    90e6:	8817c80b          	th.lbuib	a6,(a5),1,0
    90ea:	08080063          	beqz	a6,916a <_vsnprintf+0x59a>
    90ee:	8817cf8b          	th.lbuib	t6,(a5),1,0
    90f2:	060f8c63          	beqz	t6,916a <_vsnprintf+0x59a>
    90f6:	8817ca8b          	th.lbuib	s5,(a5),1,0
    90fa:	060a8863          	beqz	s5,916a <_vsnprintf+0x59a>
    90fe:	8817cb8b          	th.lbuib	s7,(a5),1,0
    9102:	060b8463          	beqz	s7,916a <_vsnprintf+0x59a>
    9106:	8817ce0b          	th.lbuib	t3,(a5),1,0
    910a:	060e0063          	beqz	t3,916a <_vsnprintf+0x59a>
    910e:	00fc9463          	bne	s9,a5,9116 <_vsnprintf+0x546>
    9112:	5480106f          	j	a65a <_vsnprintf+0x1a8a>
    9116:	0017c283          	lbu	t0,1(a5)
    911a:	0785                	addi	a5,a5,1
    911c:	8ebe                	mv	t4,a5
    911e:	04028663          	beqz	t0,916a <_vsnprintf+0x59a>
    9122:	8817c68b          	th.lbuib	a3,(a5),1,0
    9126:	c2b1                	beqz	a3,916a <_vsnprintf+0x59a>
    9128:	002ec303          	lbu	t1,2(t4)
    912c:	002e8793          	addi	a5,t4,2
    9130:	02030d63          	beqz	t1,916a <_vsnprintf+0x59a>
    9134:	003ec383          	lbu	t2,3(t4)
    9138:	003e8793          	addi	a5,t4,3
    913c:	02038763          	beqz	t2,916a <_vsnprintf+0x59a>
    9140:	004ecf03          	lbu	t5,4(t4)
    9144:	004e8793          	addi	a5,t4,4
    9148:	020f0163          	beqz	t5,916a <_vsnprintf+0x59a>
    914c:	005ec583          	lbu	a1,5(t4)
    9150:	005e8793          	addi	a5,t4,5
    9154:	c999                	beqz	a1,916a <_vsnprintf+0x59a>
    9156:	006ec603          	lbu	a2,6(t4)
    915a:	006e8793          	addi	a5,t4,6
    915e:	c611                	beqz	a2,916a <_vsnprintf+0x59a>
    9160:	007ec703          	lbu	a4,7(t4)
    9164:	007e8793          	addi	a5,t4,7
    9168:	f35d                	bnez	a4,910e <_vsnprintf+0x53e>
    916a:	400b7c93          	andi	s9,s6,1024
    916e:	41a78bbb          	subw	s7,a5,s10
    9172:	000c9463          	bnez	s9,917a <_vsnprintf+0x5aa>
    9176:	4f20106f          	j	a668 <_vsnprintf+0x1a98>
    917a:	018bb833          	sltu	a6,s7,s8
    917e:	002b7f93          	andi	t6,s6,2
    9182:	410c1b8b          	th.mveqz	s7,s8,a6
    9186:	000f9463          	bnez	t6,918e <_vsnprintf+0x5be>
    918a:	7e00206f          	j	b96a <_vsnprintf+0x2d9a>
    918e:	6c82                	ld	s9,0(sp)
    9190:	4a89                	li	s5,2
    9192:	7c0c360b          	th.extu	a2,s8,31,0
    9196:	01960733          	add	a4,a2,s9
    919a:	41970833          	sub	a6,a4,s9
    919e:	00787f93          	andi	t6,a6,7
    91a2:	e03a                	sd	a4,0(sp)
    91a4:	8c66                	mv	s8,s9
    91a6:	419d0b33          	sub	s6,s10,s9
    91aa:	0e0f8163          	beqz	t6,928c <_vsnprintf+0x6bc>
    91ae:	ec46                	sd	a7,24(sp)
    91b0:	f07e                	sd	t6,32(sp)
    91b2:	86a6                	mv	a3,s1
    91b4:	8666                	mv	a2,s9
    91b6:	85ca                	mv	a1,s2
    91b8:	9402                	jalr	s0
    91ba:	001c8d13          	addi	s10,s9,1
    91be:	81ab450b          	th.lrbu	a0,s6,s10,0
    91c2:	68e2                	ld	a7,24(sp)
    91c4:	e119                	bnez	a0,91ca <_vsnprintf+0x5fa>
    91c6:	2f00106f          	j	a4b6 <_vsnprintf+0x18e6>
    91ca:	7e82                	ld	t4,32(sp)
    91cc:	4e05                	li	t3,1
    91ce:	8c6a                	mv	s8,s10
    91d0:	0bce8e63          	beq	t4,t3,928c <_vsnprintf+0x6bc>
    91d4:	4289                	li	t0,2
    91d6:	085e8e63          	beq	t4,t0,9272 <_vsnprintf+0x6a2>
    91da:	468d                	li	a3,3
    91dc:	06de8e63          	beq	t4,a3,9258 <_vsnprintf+0x688>
    91e0:	4311                	li	t1,4
    91e2:	046e8e63          	beq	t4,t1,923e <_vsnprintf+0x66e>
    91e6:	4395                	li	t2,5
    91e8:	027e8e63          	beq	t4,t2,9224 <_vsnprintf+0x654>
    91ec:	4f19                	li	t5,6
    91ee:	01ee8e63          	beq	t4,t5,920a <_vsnprintf+0x63a>
    91f2:	8662                	mv	a2,s8
    91f4:	86a6                	mv	a3,s1
    91f6:	85ca                	mv	a1,s2
    91f8:	0d05                	addi	s10,s10,1
    91fa:	9402                	jalr	s0
    91fc:	81ab450b          	th.lrbu	a0,s6,s10,0
    9200:	68e2                	ld	a7,24(sp)
    9202:	8c6a                	mv	s8,s10
    9204:	e119                	bnez	a0,920a <_vsnprintf+0x63a>
    9206:	2b00106f          	j	a4b6 <_vsnprintf+0x18e6>
    920a:	8662                	mv	a2,s8
    920c:	ec46                	sd	a7,24(sp)
    920e:	86a6                	mv	a3,s1
    9210:	85ca                	mv	a1,s2
    9212:	0d05                	addi	s10,s10,1
    9214:	9402                	jalr	s0
    9216:	81ab450b          	th.lrbu	a0,s6,s10,0
    921a:	68e2                	ld	a7,24(sp)
    921c:	8c6a                	mv	s8,s10
    921e:	e119                	bnez	a0,9224 <_vsnprintf+0x654>
    9220:	2960106f          	j	a4b6 <_vsnprintf+0x18e6>
    9224:	8662                	mv	a2,s8
    9226:	ec46                	sd	a7,24(sp)
    9228:	86a6                	mv	a3,s1
    922a:	85ca                	mv	a1,s2
    922c:	0d05                	addi	s10,s10,1
    922e:	9402                	jalr	s0
    9230:	81ab450b          	th.lrbu	a0,s6,s10,0
    9234:	68e2                	ld	a7,24(sp)
    9236:	8c6a                	mv	s8,s10
    9238:	e119                	bnez	a0,923e <_vsnprintf+0x66e>
    923a:	27c0106f          	j	a4b6 <_vsnprintf+0x18e6>
    923e:	8662                	mv	a2,s8
    9240:	ec46                	sd	a7,24(sp)
    9242:	86a6                	mv	a3,s1
    9244:	85ca                	mv	a1,s2
    9246:	0d05                	addi	s10,s10,1
    9248:	9402                	jalr	s0
    924a:	81ab450b          	th.lrbu	a0,s6,s10,0
    924e:	68e2                	ld	a7,24(sp)
    9250:	8c6a                	mv	s8,s10
    9252:	e119                	bnez	a0,9258 <_vsnprintf+0x688>
    9254:	2620106f          	j	a4b6 <_vsnprintf+0x18e6>
    9258:	8662                	mv	a2,s8
    925a:	ec46                	sd	a7,24(sp)
    925c:	86a6                	mv	a3,s1
    925e:	85ca                	mv	a1,s2
    9260:	0d05                	addi	s10,s10,1
    9262:	9402                	jalr	s0
    9264:	81ab450b          	th.lrbu	a0,s6,s10,0
    9268:	68e2                	ld	a7,24(sp)
    926a:	8c6a                	mv	s8,s10
    926c:	e119                	bnez	a0,9272 <_vsnprintf+0x6a2>
    926e:	2480106f          	j	a4b6 <_vsnprintf+0x18e6>
    9272:	8662                	mv	a2,s8
    9274:	ec46                	sd	a7,24(sp)
    9276:	86a6                	mv	a3,s1
    9278:	85ca                	mv	a1,s2
    927a:	0d05                	addi	s10,s10,1
    927c:	9402                	jalr	s0
    927e:	81ab450b          	th.lrbu	a0,s6,s10,0
    9282:	68e2                	ld	a7,24(sp)
    9284:	8c6a                	mv	s8,s10
    9286:	e119                	bnez	a0,928c <_vsnprintf+0x6bc>
    9288:	22e0106f          	j	a4b6 <_vsnprintf+0x18e6>
    928c:	8d46                	mv	s10,a7
    928e:	6882                	ld	a7,0(sp)
    9290:	0d888463          	beq	a7,s8,9358 <_vsnprintf+0x788>
    9294:	86a6                	mv	a3,s1
    9296:	8662                	mv	a2,s8
    9298:	85ca                	mv	a1,s2
    929a:	001c0c93          	addi	s9,s8,1
    929e:	9402                	jalr	s0
    92a0:	819b450b          	th.lrbu	a0,s6,s9,0
    92a4:	e119                	bnez	a0,92aa <_vsnprintf+0x6da>
    92a6:	20c0106f          	j	a4b2 <_vsnprintf+0x18e2>
    92aa:	8666                	mv	a2,s9
    92ac:	86a6                	mv	a3,s1
    92ae:	85ca                	mv	a1,s2
    92b0:	002c0c93          	addi	s9,s8,2
    92b4:	9402                	jalr	s0
    92b6:	819b450b          	th.lrbu	a0,s6,s9,0
    92ba:	e119                	bnez	a0,92c0 <_vsnprintf+0x6f0>
    92bc:	1f60106f          	j	a4b2 <_vsnprintf+0x18e2>
    92c0:	86a6                	mv	a3,s1
    92c2:	002c0613          	addi	a2,s8,2
    92c6:	85ca                	mv	a1,s2
    92c8:	003c0c93          	addi	s9,s8,3
    92cc:	9402                	jalr	s0
    92ce:	819b450b          	th.lrbu	a0,s6,s9,0
    92d2:	e119                	bnez	a0,92d8 <_vsnprintf+0x708>
    92d4:	1de0106f          	j	a4b2 <_vsnprintf+0x18e2>
    92d8:	86a6                	mv	a3,s1
    92da:	003c0613          	addi	a2,s8,3
    92de:	85ca                	mv	a1,s2
    92e0:	004c0c93          	addi	s9,s8,4
    92e4:	9402                	jalr	s0
    92e6:	819b450b          	th.lrbu	a0,s6,s9,0
    92ea:	e119                	bnez	a0,92f0 <_vsnprintf+0x720>
    92ec:	1c60106f          	j	a4b2 <_vsnprintf+0x18e2>
    92f0:	86a6                	mv	a3,s1
    92f2:	004c0613          	addi	a2,s8,4
    92f6:	85ca                	mv	a1,s2
    92f8:	005c0c93          	addi	s9,s8,5
    92fc:	9402                	jalr	s0
    92fe:	819b450b          	th.lrbu	a0,s6,s9,0
    9302:	e119                	bnez	a0,9308 <_vsnprintf+0x738>
    9304:	1ae0106f          	j	a4b2 <_vsnprintf+0x18e2>
    9308:	86a6                	mv	a3,s1
    930a:	005c0613          	addi	a2,s8,5
    930e:	85ca                	mv	a1,s2
    9310:	006c0c93          	addi	s9,s8,6
    9314:	9402                	jalr	s0
    9316:	819b450b          	th.lrbu	a0,s6,s9,0
    931a:	e119                	bnez	a0,9320 <_vsnprintf+0x750>
    931c:	1960106f          	j	a4b2 <_vsnprintf+0x18e2>
    9320:	86a6                	mv	a3,s1
    9322:	006c0613          	addi	a2,s8,6
    9326:	85ca                	mv	a1,s2
    9328:	007c0c93          	addi	s9,s8,7
    932c:	9402                	jalr	s0
    932e:	819b450b          	th.lrbu	a0,s6,s9,0
    9332:	e119                	bnez	a0,9338 <_vsnprintf+0x768>
    9334:	17e0106f          	j	a4b2 <_vsnprintf+0x18e2>
    9338:	86a6                	mv	a3,s1
    933a:	007c0613          	addi	a2,s8,7
    933e:	85ca                	mv	a1,s2
    9340:	008c0c93          	addi	s9,s8,8
    9344:	9402                	jalr	s0
    9346:	819b450b          	th.lrbu	a0,s6,s9,0
    934a:	e119                	bnez	a0,9350 <_vsnprintf+0x780>
    934c:	1660106f          	j	a4b2 <_vsnprintf+0x18e2>
    9350:	6882                	ld	a7,0(sp)
    9352:	8c66                	mv	s8,s9
    9354:	f58890e3          	bne	a7,s8,9294 <_vsnprintf+0x6c4>
    9358:	88ea                	mv	a7,s10
    935a:	000a9463          	bnez	s5,9362 <_vsnprintf+0x792>
    935e:	14a0106f          	j	a4a8 <_vsnprintf+0x18d8>
    9362:	6b02                	ld	s6,0(sp)
    9364:	011be463          	bltu	s7,a7,936c <_vsnprintf+0x79c>
    9368:	1400106f          	j	a4a8 <_vsnprintf+0x18d8>
    936c:	6a82                	ld	s5,0(sp)
    936e:	fff8851b          	addiw	a0,a7,-1
    9372:	417505bb          	subw	a1,a0,s7
    9376:	7c05b78b          	th.extu	a5,a1,31,0
    937a:	001a8b93          	addi	s7,s5,1
    937e:	01778c33          	add	s8,a5,s7
    9382:	416c0633          	sub	a2,s8,s6
    9386:	e062                	sd	s8,0(sp)
    9388:	00767813          	andi	a6,a2,7
    938c:	08080a63          	beqz	a6,9420 <_vsnprintf+0x850>
    9390:	4705                	li	a4,1
    9392:	06e80b63          	beq	a6,a4,9408 <_vsnprintf+0x838>
    9396:	4f89                	li	t6,2
    9398:	07f80163          	beq	a6,t6,93fa <_vsnprintf+0x82a>
    939c:	4e0d                	li	t3,3
    939e:	05c80763          	beq	a6,t3,93ec <_vsnprintf+0x81c>
    93a2:	4e91                	li	t4,4
    93a4:	03d80d63          	beq	a6,t4,93de <_vsnprintf+0x80e>
    93a8:	4295                	li	t0,5
    93aa:	02580363          	beq	a6,t0,93d0 <_vsnprintf+0x800>
    93ae:	4699                	li	a3,6
    93b0:	00d80963          	beq	a6,a3,93c2 <_vsnprintf+0x7f2>
    93b4:	865a                	mv	a2,s6
    93b6:	86a6                	mv	a3,s1
    93b8:	85ca                	mv	a1,s2
    93ba:	02000513          	li	a0,32
    93be:	0b05                	addi	s6,s6,1
    93c0:	9402                	jalr	s0
    93c2:	865a                	mv	a2,s6
    93c4:	86a6                	mv	a3,s1
    93c6:	85ca                	mv	a1,s2
    93c8:	02000513          	li	a0,32
    93cc:	0b05                	addi	s6,s6,1
    93ce:	9402                	jalr	s0
    93d0:	865a                	mv	a2,s6
    93d2:	86a6                	mv	a3,s1
    93d4:	85ca                	mv	a1,s2
    93d6:	02000513          	li	a0,32
    93da:	0b05                	addi	s6,s6,1
    93dc:	9402                	jalr	s0
    93de:	865a                	mv	a2,s6
    93e0:	86a6                	mv	a3,s1
    93e2:	85ca                	mv	a1,s2
    93e4:	02000513          	li	a0,32
    93e8:	0b05                	addi	s6,s6,1
    93ea:	9402                	jalr	s0
    93ec:	865a                	mv	a2,s6
    93ee:	86a6                	mv	a3,s1
    93f0:	85ca                	mv	a1,s2
    93f2:	02000513          	li	a0,32
    93f6:	0b05                	addi	s6,s6,1
    93f8:	9402                	jalr	s0
    93fa:	865a                	mv	a2,s6
    93fc:	86a6                	mv	a3,s1
    93fe:	85ca                	mv	a1,s2
    9400:	02000513          	li	a0,32
    9404:	0b05                	addi	s6,s6,1
    9406:	9402                	jalr	s0
    9408:	865a                	mv	a2,s6
    940a:	86a6                	mv	a3,s1
    940c:	85ca                	mv	a1,s2
    940e:	02000513          	li	a0,32
    9412:	9402                	jalr	s0
    9414:	6302                	ld	t1,0(sp)
    9416:	0b05                	addi	s6,s6,1
    9418:	006b1463          	bne	s6,t1,9420 <_vsnprintf+0x850>
    941c:	08c0106f          	j	a4a8 <_vsnprintf+0x18d8>
    9420:	865a                	mv	a2,s6
    9422:	86a6                	mv	a3,s1
    9424:	85ca                	mv	a1,s2
    9426:	02000513          	li	a0,32
    942a:	9402                	jalr	s0
    942c:	001b0d13          	addi	s10,s6,1
    9430:	866a                	mv	a2,s10
    9432:	86a6                	mv	a3,s1
    9434:	85ca                	mv	a1,s2
    9436:	02000513          	li	a0,32
    943a:	9402                	jalr	s0
    943c:	002b0c93          	addi	s9,s6,2
    9440:	8666                	mv	a2,s9
    9442:	86a6                	mv	a3,s1
    9444:	85ca                	mv	a1,s2
    9446:	02000513          	li	a0,32
    944a:	9402                	jalr	s0
    944c:	003b0a93          	addi	s5,s6,3
    9450:	86a6                	mv	a3,s1
    9452:	8656                	mv	a2,s5
    9454:	85ca                	mv	a1,s2
    9456:	02000513          	li	a0,32
    945a:	9402                	jalr	s0
    945c:	004b0b93          	addi	s7,s6,4
    9460:	86a6                	mv	a3,s1
    9462:	865e                	mv	a2,s7
    9464:	85ca                	mv	a1,s2
    9466:	02000513          	li	a0,32
    946a:	9402                	jalr	s0
    946c:	005b0c13          	addi	s8,s6,5
    9470:	86a6                	mv	a3,s1
    9472:	8662                	mv	a2,s8
    9474:	85ca                	mv	a1,s2
    9476:	02000513          	li	a0,32
    947a:	9402                	jalr	s0
    947c:	006b0d13          	addi	s10,s6,6
    9480:	86a6                	mv	a3,s1
    9482:	866a                	mv	a2,s10
    9484:	85ca                	mv	a1,s2
    9486:	02000513          	li	a0,32
    948a:	9402                	jalr	s0
    948c:	007b0c93          	addi	s9,s6,7
    9490:	86a6                	mv	a3,s1
    9492:	8666                	mv	a2,s9
    9494:	85ca                	mv	a1,s2
    9496:	02000513          	li	a0,32
    949a:	9402                	jalr	s0
    949c:	6302                	ld	t1,0(sp)
    949e:	0b21                	addi	s6,s6,8
    94a0:	f86b10e3          	bne	s6,t1,9420 <_vsnprintf+0x850>
    94a4:	0040106f          	j	a4a8 <_vsnprintf+0x18d8>
    94a8:	6ea2                	ld	t4,8(sp)
    94aa:	002b6e13          	ori	t3,s6,2
    94ae:	000e0b1b          	sext.w	s6,t3
    94b2:	001e8f13          	addi	t5,t4,1
    94b6:	001ec503          	lbu	a0,1(t4)
    94ba:	411008bb          	negw	a7,a7
    94be:	e47a                	sd	t5,8(sp)
    94c0:	fbeff06f          	j	8c7e <_vsnprintf+0xae>
    94c4:	6e22                	ld	t3,8(sp)
    94c6:	06c00d13          	li	s10,108
    94ca:	001e4503          	lbu	a0,1(t3)
    94ce:	01a51463          	bne	a0,s10,94d6 <_vsnprintf+0x906>
    94d2:	25e0106f          	j	a730 <_vsnprintf+0x1b60>
    94d6:	100b6b13          	ori	s6,s6,256
    94da:	001e0e93          	addi	t4,t3,1
    94de:	2b01                	sext.w	s6,s6
    94e0:	e476                	sd	t4,8(sp)
    94e2:	b039                	j	8cf0 <_vsnprintf+0x120>
    94e4:	67a2                	ld	a5,8(sp)
    94e6:	06800593          	li	a1,104
    94ea:	0017c503          	lbu	a0,1(a5)
    94ee:	00b51463          	bne	a0,a1,94f6 <_vsnprintf+0x926>
    94f2:	2280106f          	j	a71a <_vsnprintf+0x1b4a>
    94f6:	080b6f13          	ori	t5,s6,128
    94fa:	00178613          	addi	a2,a5,1
    94fe:	000f0b1b          	sext.w	s6,t5
    9502:	e432                	sd	a2,8(sp)
    9504:	fecff06f          	j	8cf0 <_vsnprintf+0x120>
    9508:	06700693          	li	a3,103
    950c:	0ed503e3          	beq	a0,a3,9df2 <_vsnprintf+0x1222>
    9510:	04700f13          	li	t5,71
    9514:	01e51463          	bne	a0,t5,951c <_vsnprintf+0x94c>
    9518:	1280106f          	j	a640 <_vsnprintf+0x1a70>
    951c:	04500713          	li	a4,69
    9520:	00e51463          	bne	a0,a4,9528 <_vsnprintf+0x958>
    9524:	12a0106f          	j	a64e <_vsnprintf+0x1a7e>
    9528:	000db507          	fld	fa0,0(s11)
    952c:	008d8b93          	addi	s7,s11,8
    9530:	a2a52dd3          	feq.d	s11,fa0,fa0
    9534:	000d9463          	bnez	s11,953c <_vsnprintf+0x96c>
    9538:	0e80106f          	j	a620 <_vsnprintf+0x1a50>
    953c:	6d45                	lui	s10,0x11
    953e:	ba0d3787          	fld	fa5,-1120(s10) # 10ba0 <errpat+0x58>
    9542:	a2a793d3          	flt.d	t2,fa5,fa0
    9546:	00038463          	beqz	t2,954e <_vsnprintf+0x97e>
    954a:	0d60106f          	j	a620 <_vsnprintf+0x1a50>
    954e:	6ac5                	lui	s5,0x11
    9550:	b98ab007          	fld	ft0,-1128(s5) # 10b98 <errpat+0x50>
    9554:	a20517d3          	flt.d	a5,fa0,ft0
    9558:	c399                	beqz	a5,955e <_vsnprintf+0x98e>
    955a:	0c60106f          	j	a620 <_vsnprintf+0x1a50>
    955e:	f20000d3          	fmv.d.x	ft1,zero
    9562:	a2151ed3          	flt.d	t4,fa0,ft1
    9566:	e20506d3          	fmv.x.d	a3,fa0
    956a:	000e8663          	beqz	t4,9576 <_vsnprintf+0x9a6>
    956e:	22a51153          	fneg.d	ft2,fa0
    9572:	e20106d3          	fmv.x.d	a3,ft2
    9576:	400b7f93          	andi	t6,s6,1024
    957a:	4719                	li	a4,6
    957c:	6f45                	lui	t5,0x11
    957e:	6545                	lui	a0,0x11
    9580:	43fc170b          	th.mvnez	a4,s8,t6
    9584:	fb46bc0b          	th.extu	s8,a3,62,52
    9588:	bb8f3687          	fld	fa3,-1096(t5) # 10bb8 <errpat+0x70>
    958c:	bc053707          	fld	fa4,-1088(a0) # 10bc0 <errpat+0x78>
    9590:	c01c059b          	addiw	a1,s8,-1023
    9594:	d20581d3          	fcvt.d.w	ft3,a1
    9598:	3ff00293          	li	t0,1023
    959c:	6645                	lui	a2,0x11
    959e:	bc863287          	fld	ft5,-1080(a2) # 10bc8 <errpat+0x80>
    95a2:	03429313          	slli	t1,t0,0x34
    95a6:	cc06b80b          	th.extu	a6,a3,51,0
    95aa:	72d1f243          	fmadd.d	ft4,ft3,fa3,fa4
    95ae:	00686e33          	or	t3,a6,t1
    95b2:	f20e0353          	fmv.d.x	ft6,t3
    95b6:	6cc5                	lui	s9,0x11
    95b8:	0a5373d3          	fsub.d	ft7,ft6,ft5
    95bc:	bd0cb587          	fld	fa1,-1072(s9) # 10bd0 <errpat+0x88>
    95c0:	63c5                	lui	t2,0x11
    95c2:	6ac5                	lui	s5,0x11
    95c4:	22b3f643          	fmadd.d	fa2,ft7,fa1,ft4
    95c8:	bd83b887          	fld	fa7,-1064(t2) # 10bd8 <errpat+0x90>
    95cc:	be0abe07          	fld	ft8,-1056(s5) # 10be0 <errpat+0x98>
    95d0:	6ec5                	lui	t4,0x11
    95d2:	be8ebf87          	fld	ft11,-1048(t4) # 10be8 <errpat+0xa0>
    95d6:	c2061d53          	fcvt.w.d	s10,fa2,rtz
    95da:	6c45                	lui	s8,0x11
    95dc:	d20d0853          	fcvt.d.w	fa6,s10
    95e0:	bf0c3007          	fld	ft0,-1040(s8) # 10bf0 <errpat+0xa8>
    95e4:	e3187ec3          	fmadd.d	ft9,fa6,fa7,ft8
    95e8:	65c5                	lui	a1,0x11
    95ea:	bf85b687          	fld	fa3,-1032(a1) # 10bf8 <errpat+0xb0>
    95ee:	6f45                	lui	t5,0x11
    95f0:	b80f3207          	fld	ft4,-1152(t5) # 10b80 <errpat+0x38>
    95f4:	c20e97d3          	fcvt.w.d	a5,ft9,rtz
    95f8:	6545                	lui	a0,0x11
    95fa:	d2078f53          	fcvt.d.w	ft10,a5
    95fe:	c0053387          	fld	ft7,-1024(a0) # 10c00 <errpat+0xb8>
    9602:	13ff77d3          	fmul.d	fa5,ft10,ft11
    9606:	6845                	lui	a6,0x11
    9608:	62c5                	lui	t0,0x11
    960a:	b902bf07          	fld	ft10,-1136(t0) # 10b90 <errpat+0x48>
    960e:	7a0870c7          	fmsub.d	ft1,fa6,ft0,fa5
    9612:	c0883807          	fld	fa6,-1016(a6) # 10c08 <errpat+0xc0>
    9616:	3ff7831b          	addiw	t1,a5,1023
    961a:	03431e13          	slli	t3,t1,0x34
    961e:	f20e07d3          	fmv.d.x	fa5,t3
    9622:	1210f153          	fmul.d	ft2,ft1,ft1
    9626:	0a1878d3          	fsub.d	fa7,fa6,ft1
    962a:	0210f1d3          	fadd.d	ft3,ft1,ft1
    962e:	f2068053          	fmv.d.x	ft0,a3
    9632:	1ad17753          	fdiv.d	fa4,ft2,fa3
    9636:	000d0d9b          	sext.w	s11,s10
    963a:	024772d3          	fadd.d	ft5,fa4,ft4
    963e:	1a517353          	fdiv.d	ft6,ft2,ft5
    9642:	027375d3          	fadd.d	fa1,ft6,ft7
    9646:	1ab17653          	fdiv.d	fa2,ft2,fa1
    964a:	03167e53          	fadd.d	ft8,fa2,fa7
    964e:	1bc1fed3          	fdiv.d	ft9,ft3,ft8
    9652:	03eeffd3          	fadd.d	ft11,ft9,ft10
    9656:	12fff0d3          	fmul.d	ft1,ft11,fa5
    965a:	a2101653          	flt.d	a2,ft0,ft1
    965e:	c609                	beqz	a2,9668 <_vsnprintf+0xa98>
    9660:	1a40f0d3          	fdiv.d	ft1,ft1,ft4
    9664:	fffd0d9b          	addiw	s11,s10,-1
    9668:	0c600d13          	li	s10,198
    966c:	063d8c9b          	addiw	s9,s11,99
    9670:	73ad0793          	addi	a5,s10,1850
    9674:	019d33b3          	sltu	t2,s10,s9
    9678:	00fb77b3          	and	a5,s6,a5
    967c:	00438e13          	addi	t3,t2,4
    9680:	8ada                	mv	s5,s6
    9682:	e399                	bnez	a5,9688 <_vsnprintf+0xab8>
    9684:	0990106f          	j	af1c <_vsnprintf+0x234c>
    9688:	6c45                	lui	s8,0x11
    968a:	c10c3107          	fld	ft2,-1008(s8) # 10c10 <errpat+0xc8>
    968e:	f20681d3          	fmv.d.x	ft3,a3
    9692:	a23105d3          	fle.d	a1,ft2,ft3
    9696:	e199                	bnez	a1,969c <_vsnprintf+0xacc>
    9698:	4a00206f          	j	bb38 <_vsnprintf+0x2f68>
    969c:	6f45                	lui	t5,0x11
    969e:	c18f3707          	fld	fa4,-1000(t5) # 10c18 <errpat+0xd0>
    96a2:	a2e19553          	flt.d	a0,ft3,fa4
    96a6:	e119                	bnez	a0,96ac <_vsnprintf+0xadc>
    96a8:	4900206f          	j	bb38 <_vsnprintf+0x2f68>
    96ac:	41b70e3b          	subw	t3,a4,s11
    96b0:	fffe061b          	addiw	a2,t3,-1
    96b4:	00eda733          	slt	a4,s11,a4
    96b8:	40e0160b          	th.mveqz	a2,zero,a4
    96bc:	400b6c93          	ori	s9,s6,1024
    96c0:	8732                	mv	a4,a2
    96c2:	8db2                	mv	s11,a2
    96c4:	000c8d1b          	sext.w	s10,s9
    96c8:	002b7a93          	andi	s5,s6,2
    96cc:	00089463          	bnez	a7,96d4 <_vsnprintf+0xb04>
    96d0:	4d20406f          	j	dba2 <_vsnprintf+0x4fd2>
    96d4:	000a9463          	bnez	s5,96dc <_vsnprintf+0xb0c>
    96d8:	4ca0406f          	j	dba2 <_vsnprintf+0x4fd2>
    96dc:	87c6                	mv	a5,a7
    96de:	8b6a                	mv	s6,s10
    96e0:	4d81                	li	s11,0
    96e2:	4a89                	li	s5,2
    96e4:	4e01                	li	t3,0
    96e6:	f20003d3          	fmv.d.x	ft7,zero
    96ea:	a2751c53          	flt.d	s8,fa0,ft7
    96ee:	000c0463          	beqz	s8,96f6 <_vsnprintf+0xb26>
    96f2:	5e10106f          	j	b4d2 <_vsnprintf+0x2902>
    96f6:	75fd                	lui	a1,0xfffff
    96f8:	7ff58f13          	addi	t5,a1,2047 # fffffffffffff7ff <__kernel_stack+0xfffffffffff117ff>
    96fc:	6602                	ld	a2,0(sp)
    96fe:	01eb7533          	and	a0,s6,t5
    9702:	0005081b          	sext.w	a6,a0
    9706:	f2068553          	fmv.d.x	fa0,a3
    970a:	85ca                	mv	a1,s2
    970c:	86a6                	mv	a3,s1
    970e:	8522                	mv	a0,s0
    9710:	ec72                	sd	t3,24(sp)
    9712:	f046                	sd	a7,32(sp)
    9714:	a2dfd0ef          	jal	7140 <_ftoa>
    9718:	68e2                	ld	a7,24(sp)
    971a:	862a                	mv	a2,a0
    971c:	00089463          	bnez	a7,9724 <_vsnprintf+0xb54>
    9720:	4ff0106f          	j	b41e <_vsnprintf+0x284e>
    9724:	020b7813          	andi	a6,s6,32
    9728:	06500293          	li	t0,101
    972c:	00150c93          	addi	s9,a0,1
    9730:	04500513          	li	a0,69
    9734:	86a6                	mv	a3,s1
    9736:	4102950b          	th.mveqz	a0,t0,a6
    973a:	f432                	sd	a2,40(sp)
    973c:	85ca                	mv	a1,s2
    973e:	9402                	jalr	s0
    9740:	41fdd31b          	sraiw	t1,s11,0x1f
    9744:	006dc633          	xor	a2,s11,t1
    9748:	4066073b          	subw	a4,a2,t1
    974c:	43a9                	li	t2,10
    974e:	02777fb3          	remu	t6,a4,t2
    9752:	03010d13          	addi	s10,sp,48
    9756:	47a5                	li	a5,9
    9758:	6e62                	ld	t3,24(sp)
    975a:	fdd1488b          	th.ldd	a7,t4,(sp),2,4
    975e:	86ea                	mv	a3,s10
    9760:	030f8b1b          	addiw	s6,t6,48
    9764:	03610823          	sb	s6,48(sp)
    9768:	02775533          	divu	a0,a4,t2
    976c:	10e7fa63          	bgeu	a5,a4,9880 <_vsnprintf+0xcb0>
    9770:	03110693          	addi	a3,sp,49
    9774:	02757c33          	remu	s8,a0,t2
    9778:	030c059b          	addiw	a1,s8,48
    977c:	00b68023          	sb	a1,0(a3)
    9780:	02755f33          	divu	t5,a0,t2
    9784:	0ea7fe63          	bgeu	a5,a0,9880 <_vsnprintf+0xcb0>
    9788:	00168293          	addi	t0,a3,1
    978c:	0888                	addi	a0,sp,80
    978e:	0e550963          	beq	a0,t0,9880 <_vsnprintf+0xcb0>
    9792:	8696                	mv	a3,t0
    9794:	027f7833          	remu	a6,t5,t2
    9798:	0308031b          	addiw	t1,a6,48
    979c:	00628023          	sb	t1,0(t0)
    97a0:	027f5633          	divu	a2,t5,t2
    97a4:	0de7fe63          	bgeu	a5,t5,9880 <_vsnprintf+0xcb0>
    97a8:	02767733          	remu	a4,a2,t2
    97ac:	03070f9b          	addiw	t6,a4,48
    97b0:	0816df8b          	th.sbib	t6,(a3),1,0
    97b4:	02765b33          	divu	s6,a2,t2
    97b8:	0cc7f463          	bgeu	a5,a2,9880 <_vsnprintf+0xcb0>
    97bc:	00228693          	addi	a3,t0,2
    97c0:	027b7c33          	remu	s8,s6,t2
    97c4:	030c059b          	addiw	a1,s8,48
    97c8:	00b28123          	sb	a1,2(t0)
    97cc:	027b5f33          	divu	t5,s6,t2
    97d0:	0b67f863          	bgeu	a5,s6,9880 <_vsnprintf+0xcb0>
    97d4:	00328693          	addi	a3,t0,3
    97d8:	027f7533          	remu	a0,t5,t2
    97dc:	0305081b          	addiw	a6,a0,48
    97e0:	010281a3          	sb	a6,3(t0)
    97e4:	027f5333          	divu	t1,t5,t2
    97e8:	09e7fc63          	bgeu	a5,t5,9880 <_vsnprintf+0xcb0>
    97ec:	00428693          	addi	a3,t0,4
    97f0:	02737633          	remu	a2,t1,t2
    97f4:	0306071b          	addiw	a4,a2,48
    97f8:	00e28223          	sb	a4,4(t0)
    97fc:	02735fb3          	divu	t6,t1,t2
    9800:	0867f063          	bgeu	a5,t1,9880 <_vsnprintf+0xcb0>
    9804:	00528693          	addi	a3,t0,5
    9808:	027ffb33          	remu	s6,t6,t2
    980c:	030b0c1b          	addiw	s8,s6,48
    9810:	018282a3          	sb	s8,5(t0)
    9814:	027fd5b3          	divu	a1,t6,t2
    9818:	07f7f463          	bgeu	a5,t6,9880 <_vsnprintf+0xcb0>
    981c:	00628693          	addi	a3,t0,6
    9820:	0275ff33          	remu	t5,a1,t2
    9824:	030f051b          	addiw	a0,t5,48
    9828:	00a28323          	sb	a0,6(t0)
    982c:	0275d333          	divu	t1,a1,t2
    9830:	04b7f863          	bgeu	a5,a1,9880 <_vsnprintf+0xcb0>
    9834:	00728693          	addi	a3,t0,7
    9838:	02737833          	remu	a6,t1,t2
    983c:	0308061b          	addiw	a2,a6,48
    9840:	00c283a3          	sb	a2,7(t0)
    9844:	02735733          	divu	a4,t1,t2
    9848:	0267fc63          	bgeu	a5,t1,9880 <_vsnprintf+0xcb0>
    984c:	00828693          	addi	a3,t0,8
    9850:	02777fb3          	remu	t6,a4,t2
    9854:	030f8b1b          	addiw	s6,t6,48
    9858:	01628423          	sb	s6,8(t0)
    985c:	02775533          	divu	a0,a4,t2
    9860:	02e7f063          	bgeu	a5,a4,9880 <_vsnprintf+0xcb0>
    9864:	00928693          	addi	a3,t0,9
    9868:	02757c33          	remu	s8,a0,t2
    986c:	030c059b          	addiw	a1,s8,48
    9870:	00b68023          	sb	a1,0(a3)
    9874:	02755f33          	divu	t5,a0,t2
    9878:	f0a7e8e3          	bltu	a5,a0,9788 <_vsnprintf+0xbb8>
    987c:	00000013          	nop
    9880:	4385                	li	t2,1
    9882:	41a387b3          	sub	a5,t2,s10
    9886:	00d78c33          	add	s8,a5,a3
    988a:	ffee069b          	addiw	a3,t3,-2
    988e:	7c06b28b          	th.extu	t0,a3,31,0
    9892:	005c6463          	bltu	s8,t0,989a <_vsnprintf+0xcca>
    9896:	0640306f          	j	c8fa <_vsnprintf+0x3d2a>
    989a:	018d07b3          	add	a5,s10,s8
    989e:	005d0f33          	add	t5,s10,t0
    98a2:	40ff05b3          	sub	a1,t5,a5
    98a6:	0075f613          	andi	a2,a1,7
    98aa:	03000313          	li	t1,48
    98ae:	e219                	bnez	a2,98b4 <_vsnprintf+0xce4>
    98b0:	3330106f          	j	b3e2 <_vsnprintf+0x2812>
    98b4:	02760e63          	beq	a2,t2,98f0 <_vsnprintf+0xd20>
    98b8:	4809                	li	a6,2
    98ba:	03060963          	beq	a2,a6,98ec <_vsnprintf+0xd1c>
    98be:	470d                	li	a4,3
    98c0:	02e60463          	beq	a2,a4,98e8 <_vsnprintf+0xd18>
    98c4:	4f91                	li	t6,4
    98c6:	01f60f63          	beq	a2,t6,98e4 <_vsnprintf+0xd14>
    98ca:	4b15                	li	s6,5
    98cc:	01660a63          	beq	a2,s6,98e0 <_vsnprintf+0xd10>
    98d0:	4519                	li	a0,6
    98d2:	00a60563          	beq	a2,a0,98dc <_vsnprintf+0xd0c>
    98d6:	018d530b          	th.srb	t1,s10,s8,0
    98da:	0785                	addi	a5,a5,1
    98dc:	1817d30b          	th.sbia	t1,(a5),1,0
    98e0:	1817d30b          	th.sbia	t1,(a5),1,0
    98e4:	1817d30b          	th.sbia	t1,(a5),1,0
    98e8:	1817d30b          	th.sbia	t1,(a5),1,0
    98ec:	1817d30b          	th.sbia	t1,(a5),1,0
    98f0:	1817d30b          	th.sbia	t1,(a5),1,0
    98f4:	01e78463          	beq	a5,t5,98fc <_vsnprintf+0xd2c>
    98f8:	2eb0106f          	j	b3e2 <_vsnprintf+0x2812>
    98fc:	02028393          	addi	t2,t0,32
    9900:	1814                	addi	a3,sp,48
    9902:	00128c13          	addi	s8,t0,1
    9906:	00d38e33          	add	t3,t2,a3
    990a:	000dc463          	bltz	s11,9912 <_vsnprintf+0xd42>
    990e:	5a70306f          	j	d6b4 <_vsnprintf+0x4ae4>
    9912:	02d00513          	li	a0,45
    9916:	feae0023          	sb	a0,-32(t3)
    991a:	018d0db3          	add	s11,s10,s8
    991e:	fffd4f13          	not	t5,s10
    9922:	001d0293          	addi	t0,s10,1
    9926:	01bf0333          	add	t1,t5,s11
    992a:	9e96                	add	t4,t4,t0
    992c:	00737813          	andi	a6,t1,7
    9930:	018e8b33          	add	s6,t4,s8
    9934:	00081463          	bnez	a6,993c <_vsnprintf+0xd6c>
    9938:	5e10306f          	j	d718 <_vsnprintf+0x4b48>
    993c:	41bb0633          	sub	a2,s6,s11
    9940:	ec46                	sd	a7,24(sp)
    9942:	f042                	sd	a6,32(sp)
    9944:	85ca                	mv	a1,s2
    9946:	86a6                	mv	a3,s1
    9948:	9402                	jalr	s0
    994a:	68e2                	ld	a7,24(sp)
    994c:	7602                	ld	a2,32(sp)
    994e:	4585                	li	a1,1
    9950:	1dfd                	addi	s11,s11,-1
    9952:	fffdc503          	lbu	a0,-1(s11)
    9956:	00b61463          	bne	a2,a1,995e <_vsnprintf+0xd8e>
    995a:	5bf0306f          	j	d718 <_vsnprintf+0x4b48>
    995e:	4709                	li	a4,2
    9960:	06e60f63          	beq	a2,a4,99de <_vsnprintf+0xe0e>
    9964:	4f8d                	li	t6,3
    9966:	07f60263          	beq	a2,t6,99ca <_vsnprintf+0xdfa>
    996a:	4791                	li	a5,4
    996c:	04f60563          	beq	a2,a5,99b6 <_vsnprintf+0xde6>
    9970:	4395                	li	t2,5
    9972:	02760863          	beq	a2,t2,99a2 <_vsnprintf+0xdd2>
    9976:	4699                	li	a3,6
    9978:	00d60b63          	beq	a2,a3,998e <_vsnprintf+0xdbe>
    997c:	41bb0633          	sub	a2,s6,s11
    9980:	86a6                	mv	a3,s1
    9982:	85ca                	mv	a1,s2
    9984:	9402                	jalr	s0
    9986:	68e2                	ld	a7,24(sp)
    9988:	ffedc503          	lbu	a0,-2(s11)
    998c:	1dfd                	addi	s11,s11,-1
    998e:	41bb0633          	sub	a2,s6,s11
    9992:	ec46                	sd	a7,24(sp)
    9994:	86a6                	mv	a3,s1
    9996:	85ca                	mv	a1,s2
    9998:	9402                	jalr	s0
    999a:	68e2                	ld	a7,24(sp)
    999c:	ffedc503          	lbu	a0,-2(s11)
    99a0:	1dfd                	addi	s11,s11,-1
    99a2:	41bb0633          	sub	a2,s6,s11
    99a6:	ec46                	sd	a7,24(sp)
    99a8:	86a6                	mv	a3,s1
    99aa:	85ca                	mv	a1,s2
    99ac:	9402                	jalr	s0
    99ae:	68e2                	ld	a7,24(sp)
    99b0:	ffedc503          	lbu	a0,-2(s11)
    99b4:	1dfd                	addi	s11,s11,-1
    99b6:	41bb0633          	sub	a2,s6,s11
    99ba:	ec46                	sd	a7,24(sp)
    99bc:	86a6                	mv	a3,s1
    99be:	85ca                	mv	a1,s2
    99c0:	9402                	jalr	s0
    99c2:	68e2                	ld	a7,24(sp)
    99c4:	ffedc503          	lbu	a0,-2(s11)
    99c8:	1dfd                	addi	s11,s11,-1
    99ca:	41bb0633          	sub	a2,s6,s11
    99ce:	ec46                	sd	a7,24(sp)
    99d0:	86a6                	mv	a3,s1
    99d2:	85ca                	mv	a1,s2
    99d4:	9402                	jalr	s0
    99d6:	68e2                	ld	a7,24(sp)
    99d8:	ffedc503          	lbu	a0,-2(s11)
    99dc:	1dfd                	addi	s11,s11,-1
    99de:	41bb0633          	sub	a2,s6,s11
    99e2:	86a6                	mv	a3,s1
    99e4:	85ca                	mv	a1,s2
    99e6:	ec46                	sd	a7,24(sp)
    99e8:	9402                	jalr	s0
    99ea:	1dfd                	addi	s11,s11,-1
    99ec:	fd515b8b          	th.sdd	s7,s5,(sp),2,4
    99f0:	fffdc503          	lbu	a0,-1(s11)
    99f4:	a895                	j	9a68 <_vsnprintf+0xe98>
    99f6:	8bee                	mv	s7,s11
    99f8:	89ebc50b          	th.lbuib	a0,(s7),-2,0
    99fc:	415b0633          	sub	a2,s6,s5
    9a00:	86a6                	mv	a3,s1
    9a02:	85ca                	mv	a1,s2
    9a04:	9402                	jalr	s0
    9a06:	8aee                	mv	s5,s11
    9a08:	89dac50b          	th.lbuib	a0,(s5),-3,0
    9a0c:	417b0633          	sub	a2,s6,s7
    9a10:	86a6                	mv	a3,s1
    9a12:	85ca                	mv	a1,s2
    9a14:	9402                	jalr	s0
    9a16:	8bee                	mv	s7,s11
    9a18:	89cbc50b          	th.lbuib	a0,(s7),-4,0
    9a1c:	415b0633          	sub	a2,s6,s5
    9a20:	86a6                	mv	a3,s1
    9a22:	85ca                	mv	a1,s2
    9a24:	9402                	jalr	s0
    9a26:	8aee                	mv	s5,s11
    9a28:	89bac50b          	th.lbuib	a0,(s5),-5,0
    9a2c:	417b0633          	sub	a2,s6,s7
    9a30:	86a6                	mv	a3,s1
    9a32:	85ca                	mv	a1,s2
    9a34:	9402                	jalr	s0
    9a36:	8bee                	mv	s7,s11
    9a38:	89abc50b          	th.lbuib	a0,(s7),-6,0
    9a3c:	415b0633          	sub	a2,s6,s5
    9a40:	86a6                	mv	a3,s1
    9a42:	85ca                	mv	a1,s2
    9a44:	9402                	jalr	s0
    9a46:	8aee                	mv	s5,s11
    9a48:	899ac50b          	th.lbuib	a0,(s5),-7,0
    9a4c:	86a6                	mv	a3,s1
    9a4e:	417b0633          	sub	a2,s6,s7
    9a52:	85ca                	mv	a1,s2
    9a54:	9402                	jalr	s0
    9a56:	898dc50b          	th.lbuib	a0,(s11),-8,0
    9a5a:	86a6                	mv	a3,s1
    9a5c:	415b0633          	sub	a2,s6,s5
    9a60:	85ca                	mv	a1,s2
    9a62:	9402                	jalr	s0
    9a64:	fffdc503          	lbu	a0,-1(s11)
    9a68:	86a6                	mv	a3,s1
    9a6a:	41bb0633          	sub	a2,s6,s11
    9a6e:	85ca                	mv	a1,s2
    9a70:	fffd8a93          	addi	s5,s11,-1
    9a74:	9402                	jalr	s0
    9a76:	f95d10e3          	bne	s10,s5,99f6 <_vsnprintf+0xe26>
    9a7a:	fda14b8b          	th.ldd	s7,s10,(sp),2,4
    9a7e:	018c8633          	add	a2,s9,s8
    9a82:	6ce2                	ld	s9,24(sp)
    9a84:	000d1463          	bnez	s10,9a8c <_vsnprintf+0xebc>
    9a88:	1970106f          	j	b41e <_vsnprintf+0x284e>
    9a8c:	6502                	ld	a0,0(sp)
    9a8e:	7c0cbd8b          	th.extu	s11,s9,31,0
    9a92:	40a60ab3          	sub	s5,a2,a0
    9a96:	01bae463          	bltu	s5,s11,9a9e <_vsnprintf+0xece>
    9a9a:	1850106f          	j	b41e <_vsnprintf+0x284e>
    9a9e:	fffacc13          	not	s8,s5
    9aa2:	01bc0e33          	add	t3,s8,s11
    9aa6:	86a6                	mv	a3,s1
    9aa8:	85ca                	mv	a1,s2
    9aaa:	02000513          	li	a0,32
    9aae:	001a8d13          	addi	s10,s5,1
    9ab2:	007e7c93          	andi	s9,t3,7
    9ab6:	00160b13          	addi	s6,a2,1
    9aba:	9402                	jalr	s0
    9abc:	13bd7263          	bgeu	s10,s11,9be0 <_vsnprintf+0x1010>
    9ac0:	080c8e63          	beqz	s9,9b5c <_vsnprintf+0xf8c>
    9ac4:	4285                	li	t0,1
    9ac6:	085c8163          	beq	s9,t0,9b48 <_vsnprintf+0xf78>
    9aca:	4e89                	li	t4,2
    9acc:	07dc8663          	beq	s9,t4,9b38 <_vsnprintf+0xf68>
    9ad0:	4f0d                	li	t5,3
    9ad2:	05ec8b63          	beq	s9,t5,9b28 <_vsnprintf+0xf58>
    9ad6:	4311                	li	t1,4
    9ad8:	046c8063          	beq	s9,t1,9b18 <_vsnprintf+0xf48>
    9adc:	4815                	li	a6,5
    9ade:	030c8563          	beq	s9,a6,9b08 <_vsnprintf+0xf38>
    9ae2:	4599                	li	a1,6
    9ae4:	00bc8a63          	beq	s9,a1,9af8 <_vsnprintf+0xf28>
    9ae8:	865a                	mv	a2,s6
    9aea:	86a6                	mv	a3,s1
    9aec:	85ca                	mv	a1,s2
    9aee:	02000513          	li	a0,32
    9af2:	0b05                	addi	s6,s6,1
    9af4:	9402                	jalr	s0
    9af6:	0d05                	addi	s10,s10,1
    9af8:	865a                	mv	a2,s6
    9afa:	86a6                	mv	a3,s1
    9afc:	85ca                	mv	a1,s2
    9afe:	02000513          	li	a0,32
    9b02:	0b05                	addi	s6,s6,1
    9b04:	9402                	jalr	s0
    9b06:	0d05                	addi	s10,s10,1
    9b08:	865a                	mv	a2,s6
    9b0a:	86a6                	mv	a3,s1
    9b0c:	85ca                	mv	a1,s2
    9b0e:	02000513          	li	a0,32
    9b12:	0b05                	addi	s6,s6,1
    9b14:	9402                	jalr	s0
    9b16:	0d05                	addi	s10,s10,1
    9b18:	865a                	mv	a2,s6
    9b1a:	86a6                	mv	a3,s1
    9b1c:	85ca                	mv	a1,s2
    9b1e:	02000513          	li	a0,32
    9b22:	0b05                	addi	s6,s6,1
    9b24:	9402                	jalr	s0
    9b26:	0d05                	addi	s10,s10,1
    9b28:	865a                	mv	a2,s6
    9b2a:	86a6                	mv	a3,s1
    9b2c:	85ca                	mv	a1,s2
    9b2e:	02000513          	li	a0,32
    9b32:	0b05                	addi	s6,s6,1
    9b34:	9402                	jalr	s0
    9b36:	0d05                	addi	s10,s10,1
    9b38:	865a                	mv	a2,s6
    9b3a:	86a6                	mv	a3,s1
    9b3c:	85ca                	mv	a1,s2
    9b3e:	02000513          	li	a0,32
    9b42:	0b05                	addi	s6,s6,1
    9b44:	9402                	jalr	s0
    9b46:	0d05                	addi	s10,s10,1
    9b48:	865a                	mv	a2,s6
    9b4a:	86a6                	mv	a3,s1
    9b4c:	85ca                	mv	a1,s2
    9b4e:	02000513          	li	a0,32
    9b52:	0d05                	addi	s10,s10,1
    9b54:	0b05                	addi	s6,s6,1
    9b56:	9402                	jalr	s0
    9b58:	09bd7463          	bgeu	s10,s11,9be0 <_vsnprintf+0x1010>
    9b5c:	865a                	mv	a2,s6
    9b5e:	86a6                	mv	a3,s1
    9b60:	85ca                	mv	a1,s2
    9b62:	02000513          	li	a0,32
    9b66:	9402                	jalr	s0
    9b68:	001b0a93          	addi	s5,s6,1
    9b6c:	8656                	mv	a2,s5
    9b6e:	86a6                	mv	a3,s1
    9b70:	85ca                	mv	a1,s2
    9b72:	02000513          	li	a0,32
    9b76:	9402                	jalr	s0
    9b78:	002b0c13          	addi	s8,s6,2
    9b7c:	8662                	mv	a2,s8
    9b7e:	86a6                	mv	a3,s1
    9b80:	85ca                	mv	a1,s2
    9b82:	02000513          	li	a0,32
    9b86:	9402                	jalr	s0
    9b88:	003b0c93          	addi	s9,s6,3
    9b8c:	8666                	mv	a2,s9
    9b8e:	86a6                	mv	a3,s1
    9b90:	85ca                	mv	a1,s2
    9b92:	02000513          	li	a0,32
    9b96:	9402                	jalr	s0
    9b98:	004b0c13          	addi	s8,s6,4
    9b9c:	8662                	mv	a2,s8
    9b9e:	86a6                	mv	a3,s1
    9ba0:	85ca                	mv	a1,s2
    9ba2:	02000513          	li	a0,32
    9ba6:	9402                	jalr	s0
    9ba8:	005b0a93          	addi	s5,s6,5
    9bac:	86a6                	mv	a3,s1
    9bae:	8656                	mv	a2,s5
    9bb0:	85ca                	mv	a1,s2
    9bb2:	02000513          	li	a0,32
    9bb6:	9402                	jalr	s0
    9bb8:	006b0c93          	addi	s9,s6,6
    9bbc:	86a6                	mv	a3,s1
    9bbe:	8666                	mv	a2,s9
    9bc0:	85ca                	mv	a1,s2
    9bc2:	02000513          	li	a0,32
    9bc6:	9402                	jalr	s0
    9bc8:	007b0c13          	addi	s8,s6,7
    9bcc:	86a6                	mv	a3,s1
    9bce:	8662                	mv	a2,s8
    9bd0:	85ca                	mv	a1,s2
    9bd2:	02000513          	li	a0,32
    9bd6:	0d21                	addi	s10,s10,8
    9bd8:	0b21                	addi	s6,s6,8
    9bda:	9402                	jalr	s0
    9bdc:	f9bd60e3          	bltu	s10,s11,9b5c <_vsnprintf+0xf8c>
    9be0:	e05a                	sd	s6,0(sp)
    9be2:	2530006f          	j	a634 <_vsnprintf+0x1a64>
    9be6:	0001                	nop
    9be8:	000db507          	fld	fa0,0(s11)
    9bec:	020b6793          	ori	a5,s6,32
    9bf0:	6602                	ld	a2,0(sp)
    9bf2:	fba50e93          	addi	t4,a0,-70
    9bf6:	0007881b          	sext.w	a6,a5
    9bfa:	008d8f93          	addi	t6,s11,8
    9bfe:	85ca                	mv	a1,s2
    9c00:	43db180b          	th.mvnez	a6,s6,t4
    9c04:	87c6                	mv	a5,a7
    9c06:	8762                	mv	a4,s8
    9c08:	86a6                	mv	a3,s1
    9c0a:	8522                	mv	a0,s0
    9c0c:	8dfe                	mv	s11,t6
    9c0e:	d32fd0ef          	jal	7140 <_ftoa>
    9c12:	65a2                	ld	a1,8(sp)
    9c14:	e02a                	sd	a0,0(sp)
    9c16:	00158c93          	addi	s9,a1,1
    9c1a:	816ff06f          	j	8c30 <_vsnprintf+0x60>
    9c1e:	002b7b13          	andi	s6,s6,2
    9c22:	320b0de3          	beqz	s6,a75c <_vsnprintf+0x1b8c>
    9c26:	6602                	ld	a2,0(sp)
    9c28:	988dc50b          	th.lbuia	a0,(s11),8,0
    9c2c:	86a6                	mv	a3,s1
    9c2e:	85ca                	mv	a1,s2
    9c30:	ec46                	sd	a7,24(sp)
    9c32:	00160b13          	addi	s6,a2,1
    9c36:	9402                	jalr	s0
    9c38:	6c62                	ld	s8,24(sp)
    9c3a:	4285                	li	t0,1
    9c3c:	0782f2e3          	bgeu	t0,s8,a4a0 <_vsnprintf+0x18d0>
    9c40:	6b82                	ld	s7,0(sp)
    9c42:	ffec051b          	addiw	a0,s8,-2
    9c46:	7c053e8b          	th.extu	t4,a0,31,0
    9c4a:	002b8a93          	addi	s5,s7,2
    9c4e:	015e8e33          	add	t3,t4,s5
    9c52:	416e0f33          	sub	t5,t3,s6
    9c56:	e072                	sd	t3,0(sp)
    9c58:	007f7593          	andi	a1,t5,7
    9c5c:	c5d1                	beqz	a1,9ce8 <_vsnprintf+0x1118>
    9c5e:	06558b63          	beq	a1,t0,9cd4 <_vsnprintf+0x1104>
    9c62:	4889                	li	a7,2
    9c64:	07158163          	beq	a1,a7,9cc6 <_vsnprintf+0x10f6>
    9c68:	470d                	li	a4,3
    9c6a:	04e58763          	beq	a1,a4,9cb8 <_vsnprintf+0x10e8>
    9c6e:	4611                	li	a2,4
    9c70:	02c58d63          	beq	a1,a2,9caa <_vsnprintf+0x10da>
    9c74:	4795                	li	a5,5
    9c76:	02f58363          	beq	a1,a5,9c9c <_vsnprintf+0x10cc>
    9c7a:	4d19                	li	s10,6
    9c7c:	01a58963          	beq	a1,s10,9c8e <_vsnprintf+0x10be>
    9c80:	865a                	mv	a2,s6
    9c82:	86a6                	mv	a3,s1
    9c84:	85ca                	mv	a1,s2
    9c86:	02000513          	li	a0,32
    9c8a:	0b05                	addi	s6,s6,1
    9c8c:	9402                	jalr	s0
    9c8e:	865a                	mv	a2,s6
    9c90:	86a6                	mv	a3,s1
    9c92:	85ca                	mv	a1,s2
    9c94:	02000513          	li	a0,32
    9c98:	0b05                	addi	s6,s6,1
    9c9a:	9402                	jalr	s0
    9c9c:	865a                	mv	a2,s6
    9c9e:	86a6                	mv	a3,s1
    9ca0:	85ca                	mv	a1,s2
    9ca2:	02000513          	li	a0,32
    9ca6:	0b05                	addi	s6,s6,1
    9ca8:	9402                	jalr	s0
    9caa:	865a                	mv	a2,s6
    9cac:	86a6                	mv	a3,s1
    9cae:	85ca                	mv	a1,s2
    9cb0:	02000513          	li	a0,32
    9cb4:	0b05                	addi	s6,s6,1
    9cb6:	9402                	jalr	s0
    9cb8:	865a                	mv	a2,s6
    9cba:	86a6                	mv	a3,s1
    9cbc:	85ca                	mv	a1,s2
    9cbe:	02000513          	li	a0,32
    9cc2:	0b05                	addi	s6,s6,1
    9cc4:	9402                	jalr	s0
    9cc6:	865a                	mv	a2,s6
    9cc8:	86a6                	mv	a3,s1
    9cca:	85ca                	mv	a1,s2
    9ccc:	02000513          	li	a0,32
    9cd0:	0b05                	addi	s6,s6,1
    9cd2:	9402                	jalr	s0
    9cd4:	865a                	mv	a2,s6
    9cd6:	86a6                	mv	a3,s1
    9cd8:	85ca                	mv	a1,s2
    9cda:	02000513          	li	a0,32
    9cde:	9402                	jalr	s0
    9ce0:	6c82                	ld	s9,0(sp)
    9ce2:	0b05                	addi	s6,s6,1
    9ce4:	7d9b0263          	beq	s6,s9,a4a8 <_vsnprintf+0x18d8>
    9ce8:	865a                	mv	a2,s6
    9cea:	86a6                	mv	a3,s1
    9cec:	85ca                	mv	a1,s2
    9cee:	02000513          	li	a0,32
    9cf2:	9402                	jalr	s0
    9cf4:	001b0c13          	addi	s8,s6,1
    9cf8:	8662                	mv	a2,s8
    9cfa:	86a6                	mv	a3,s1
    9cfc:	85ca                	mv	a1,s2
    9cfe:	02000513          	li	a0,32
    9d02:	9402                	jalr	s0
    9d04:	002b0b93          	addi	s7,s6,2
    9d08:	865e                	mv	a2,s7
    9d0a:	86a6                	mv	a3,s1
    9d0c:	85ca                	mv	a1,s2
    9d0e:	02000513          	li	a0,32
    9d12:	9402                	jalr	s0
    9d14:	003b0a93          	addi	s5,s6,3
    9d18:	86a6                	mv	a3,s1
    9d1a:	8656                	mv	a2,s5
    9d1c:	85ca                	mv	a1,s2
    9d1e:	02000513          	li	a0,32
    9d22:	9402                	jalr	s0
    9d24:	004b0d13          	addi	s10,s6,4
    9d28:	86a6                	mv	a3,s1
    9d2a:	866a                	mv	a2,s10
    9d2c:	85ca                	mv	a1,s2
    9d2e:	02000513          	li	a0,32
    9d32:	9402                	jalr	s0
    9d34:	005b0c93          	addi	s9,s6,5
    9d38:	8666                	mv	a2,s9
    9d3a:	86a6                	mv	a3,s1
    9d3c:	85ca                	mv	a1,s2
    9d3e:	02000513          	li	a0,32
    9d42:	9402                	jalr	s0
    9d44:	006b0c13          	addi	s8,s6,6
    9d48:	86a6                	mv	a3,s1
    9d4a:	8662                	mv	a2,s8
    9d4c:	85ca                	mv	a1,s2
    9d4e:	02000513          	li	a0,32
    9d52:	9402                	jalr	s0
    9d54:	007b0b93          	addi	s7,s6,7
    9d58:	86a6                	mv	a3,s1
    9d5a:	865e                	mv	a2,s7
    9d5c:	85ca                	mv	a1,s2
    9d5e:	02000513          	li	a0,32
    9d62:	9402                	jalr	s0
    9d64:	6c82                	ld	s9,0(sp)
    9d66:	0b21                	addi	s6,s6,8
    9d68:	f99b10e3          	bne	s6,s9,9ce8 <_vsnprintf+0x1118>
    9d6c:	af35                	j	a4a8 <_vsnprintf+0x18d8>
    9d6e:	0001                	nop
    9d70:	6602                	ld	a2,0(sp)
    9d72:	86a6                	mv	a3,s1
    9d74:	85ca                	mv	a1,s2
    9d76:	02500513          	li	a0,37
    9d7a:	00160b13          	addi	s6,a2,1
    9d7e:	9402                	jalr	s0
    9d80:	6722                	ld	a4,8(sp)
    9d82:	e05a                	sd	s6,0(sp)
    9d84:	00170c93          	addi	s9,a4,1
    9d88:	ea9fe06f          	j	8c30 <_vsnprintf+0x60>
    9d8c:	06f00313          	li	t1,111
    9d90:	06650a63          	beq	a0,t1,9e04 <_vsnprintf+0x1234>
    9d94:	00a36463          	bltu	t1,a0,9d9c <_vsnprintf+0x11cc>
    9d98:	5c90106f          	j	bb60 <_vsnprintf+0x2f90>
    9d9c:	07800393          	li	t2,120
    9da0:	00751463          	bne	a0,t2,9da8 <_vsnprintf+0x11d8>
    9da4:	2a80106f          	j	b04c <_vsnprintf+0x247c>
    9da8:	fefb7513          	andi	a0,s6,-17
    9dac:	47a9                	li	a5,10
    9dae:	00050b1b          	sext.w	s6,a0
    9db2:	86be                	mv	a3,a5
    9db4:	a891                	j	9e08 <_vsnprintf+0x1238>
    9db6:	588dc50b          	th.lwia	a0,(s11),8,0
    9dba:	6e22                	ld	t3,8(sp)
    9dbc:	00052c13          	slti	s8,a0,0
    9dc0:	4380150b          	th.mvnez	a0,zero,s8
    9dc4:	002e0e93          	addi	t4,t3,2
    9dc8:	00050c1b          	sext.w	s8,a0
    9dcc:	e476                	sd	t4,8(sp)
    9dce:	002e4503          	lbu	a0,2(t3)
    9dd2:	eb7fe06f          	j	8c88 <_vsnprintf+0xb8>
    9dd6:	fefb7893          	andi	a7,s6,-17
    9dda:	0218e593          	ori	a1,a7,33
    9dde:	400b7c93          	andi	s9,s6,1024
    9de2:	855a                	mv	a0,s6
    9de4:	2581                	sext.w	a1,a1
    9de6:	480c93e3          	bnez	s9,aa6c <_vsnprintf+0x1e9c>
    9dea:	4b81                	li	s7,0
    9dec:	4281                	li	t0,0
    9dee:	88cff06f          	j	8e7a <_vsnprintf+0x2aa>
    9df2:	6e05                	lui	t3,0x1
    9df4:	800e0613          	addi	a2,t3,-2048 # 800 <cmp_complex+0x90>
    9df8:	00cb6cb3          	or	s9,s6,a2
    9dfc:	000c8b1b          	sext.w	s6,s9
    9e00:	f28ff06f          	j	9528 <_vsnprintf+0x958>
    9e04:	47a1                	li	a5,8
    9e06:	86be                	mv	a3,a5
    9e08:	ff2b7813          	andi	a6,s6,-14
    9e0c:	400b7b93          	andi	s7,s6,1024
    9e10:	ff3b7b13          	andi	s6,s6,-13
    9e14:	00080c9b          	sext.w	s9,a6
    9e18:	000b061b          	sext.w	a2,s6
    9e1c:	437c960b          	th.mvnez	a2,s9,s7
    9e20:	20067813          	andi	a6,a2,512
    9e24:	8fb2                	mv	t6,a2
    9e26:	00080463          	beqz	a6,9e2e <_vsnprintf+0x125e>
    9e2a:	6b80106f          	j	b4e2 <_vsnprintf+0x2912>
    9e2e:	10067d13          	andi	s10,a2,256
    9e32:	000d0463          	beqz	s10,9e3a <_vsnprintf+0x126a>
    9e36:	15b0206f          	j	c790 <_vsnprintf+0x3bc0>
    9e3a:	04067293          	andi	t0,a2,64
    9e3e:	00029463          	bnez	t0,9e46 <_vsnprintf+0x1276>
    9e42:	2560106f          	j	b098 <_vsnprintf+0x24c8>
    9e46:	988dce8b          	th.lbuia	t4,(s11),8,0
    9e4a:	7c0eb70b          	th.extu	a4,t4,31,0
    9e4e:	e319                	bnez	a4,9e54 <_vsnprintf+0x1284>
    9e50:	1310206f          	j	c780 <_vsnprintf+0x3bb0>
    9e54:	01067e93          	andi	t4,a2,16
    9e58:	8e32                	mv	t3,a2
    9e5a:	02f75333          	divu	t1,a4,a5
    9e5e:	853a                	mv	a0,a4
    9e60:	145e358b          	th.extu	a1,t3,5,5
    9e64:	fff58a93          	addi	s5,a1,-1
    9e68:	020af393          	andi	t2,s5,32
    9e6c:	03738b1b          	addiw	s6,t2,55
    9e70:	4ca5                	li	s9,9
    9e72:	03010813          	addi	a6,sp,48
    9e76:	8642                	mv	a2,a6
    9e78:	22f3150b          	th.muls	a0,t1,a5
    9e7c:	0ff57f93          	zext.b	t6,a0
    9e80:	030f829b          	addiw	t0,t6,48
    9e84:	01fb05bb          	addw	a1,s6,t6
    9e88:	0ff2ff13          	zext.b	t5,t0
    9e8c:	0ff5fa93          	zext.b	s5,a1
    9e90:	00acb3b3          	sltu	t2,s9,a0
    9e94:	407f1a8b          	th.mveqz	s5,t5,t2
    9e98:	03510823          	sb	s5,48(sp)
    9e9c:	00f77463          	bgeu	a4,a5,9ea4 <_vsnprintf+0x12d4>
    9ea0:	7ac0106f          	j	b64c <_vsnprintf+0x2a7c>
    9ea4:	03110613          	addi	a2,sp,49
    9ea8:	829a                	mv	t0,t1
    9eaa:	0001                	nop
    9eac:	00000013          	nop
    9eb0:	02f2d333          	divu	t1,t0,a5
    9eb4:	8516                	mv	a0,t0
    9eb6:	22f3150b          	th.muls	a0,t1,a5
    9eba:	0ff57713          	zext.b	a4,a0
    9ebe:	03070f9b          	addiw	t6,a4,48
    9ec2:	00eb0f3b          	addw	t5,s6,a4
    9ec6:	0ffff593          	zext.b	a1,t6
    9eca:	0fff7a93          	zext.b	s5,t5
    9ece:	00acb3b3          	sltu	t2,s9,a0
    9ed2:	40759a8b          	th.mveqz	s5,a1,t2
    9ed6:	01560023          	sb	s5,0(a2)
    9eda:	00f2f463          	bgeu	t0,a5,9ee2 <_vsnprintf+0x1312>
    9ede:	76e0106f          	j	b64c <_vsnprintf+0x2a7c>
    9ee2:	00160513          	addi	a0,a2,1
    9ee6:	05010293          	addi	t0,sp,80
    9eea:	00a29463          	bne	t0,a0,9ef2 <_vsnprintf+0x1322>
    9eee:	75e0106f          	j	b64c <_vsnprintf+0x2a7c>
    9ef2:	02f35fb3          	divu	t6,t1,a5
    9ef6:	859a                	mv	a1,t1
    9ef8:	862a                	mv	a2,a0
    9efa:	22ff958b          	th.muls	a1,t6,a5
    9efe:	0ff5f713          	zext.b	a4,a1
    9f02:	03070f1b          	addiw	t5,a4,48
    9f06:	00eb03bb          	addw	t2,s6,a4
    9f0a:	0fff7a93          	zext.b	s5,t5
    9f0e:	0ff3f713          	zext.b	a4,t2
    9f12:	00bcb2b3          	sltu	t0,s9,a1
    9f16:	405a970b          	th.mveqz	a4,s5,t0
    9f1a:	00e50023          	sb	a4,0(a0)
    9f1e:	00f37463          	bgeu	t1,a5,9f26 <_vsnprintf+0x1356>
    9f22:	72a0106f          	j	b64c <_vsnprintf+0x2a7c>
    9f26:	02ffd333          	divu	t1,t6,a5
    9f2a:	85fe                	mv	a1,t6
    9f2c:	22f3158b          	th.muls	a1,t1,a5
    9f30:	0ff5ff13          	zext.b	t5,a1
    9f34:	030f0a9b          	addiw	s5,t5,48
    9f38:	01eb073b          	addw	a4,s6,t5
    9f3c:	0ffaf393          	zext.b	t2,s5
    9f40:	0ff77f13          	zext.b	t5,a4
    9f44:	00bcb2b3          	sltu	t0,s9,a1
    9f48:	40539f0b          	th.mveqz	t5,t2,t0
    9f4c:	08165f0b          	th.sbib	t5,(a2),1,0
    9f50:	00fff463          	bgeu	t6,a5,9f58 <_vsnprintf+0x1388>
    9f54:	6f80106f          	j	b64c <_vsnprintf+0x2a7c>
    9f58:	02f35fb3          	divu	t6,t1,a5
    9f5c:	859a                	mv	a1,t1
    9f5e:	00250613          	addi	a2,a0,2
    9f62:	22ff958b          	th.muls	a1,t6,a5
    9f66:	0ff5fa93          	zext.b	s5,a1
    9f6a:	030a839b          	addiw	t2,s5,48
    9f6e:	015b073b          	addw	a4,s6,s5
    9f72:	0ff3ff13          	zext.b	t5,t2
    9f76:	0ff77a93          	zext.b	s5,a4
    9f7a:	00bcb2b3          	sltu	t0,s9,a1
    9f7e:	405f1a8b          	th.mveqz	s5,t5,t0
    9f82:	01550123          	sb	s5,2(a0)
    9f86:	00f37463          	bgeu	t1,a5,9f8e <_vsnprintf+0x13be>
    9f8a:	6c20106f          	j	b64c <_vsnprintf+0x2a7c>
    9f8e:	02ffd2b3          	divu	t0,t6,a5
    9f92:	837e                	mv	t1,t6
    9f94:	00350613          	addi	a2,a0,3
    9f98:	22f2930b          	th.muls	t1,t0,a5
    9f9c:	0ff37593          	zext.b	a1,t1
    9fa0:	0305839b          	addiw	t2,a1,48
    9fa4:	00bb073b          	addw	a4,s6,a1
    9fa8:	0ff3ff13          	zext.b	t5,t2
    9fac:	0ff77a93          	zext.b	s5,a4
    9fb0:	006cb333          	sltu	t1,s9,t1
    9fb4:	406f1a8b          	th.mveqz	s5,t5,t1
    9fb8:	015501a3          	sb	s5,3(a0)
    9fbc:	00fff463          	bgeu	t6,a5,9fc4 <_vsnprintf+0x13f4>
    9fc0:	68c0106f          	j	b64c <_vsnprintf+0x2a7c>
    9fc4:	00450613          	addi	a2,a0,4
    9fc8:	b5e5                	j	9eb0 <_vsnprintf+0x12e0>
    9fca:	05800613          	li	a2,88
    9fce:	76c50f63          	beq	a0,a2,a74c <_vsnprintf+0x1b7c>
    9fd2:	4789                	li	a5,2
    9fd4:	06200313          	li	t1,98
    9fd8:	86be                	mv	a3,a5
    9fda:	e26507e3          	beq	a0,t1,9e08 <_vsnprintf+0x1238>
    9fde:	400b7693          	andi	a3,s6,1024
    9fe2:	2a069ee3          	bnez	a3,aa9e <_vsnprintf+0x1ece>
    9fe6:	fefb7793          	andi	a5,s6,-17
    9fea:	200b7393          	andi	t2,s6,512
    9fee:	0007859b          	sext.w	a1,a5
    9ff2:	00038463          	beqz	t2,9ffa <_vsnprintf+0x142a>
    9ff6:	0fe0206f          	j	c0f4 <_vsnprintf+0x3524>
    9ffa:	100b7e93          	andi	t4,s6,256
    9ffe:	2c0e81e3          	beqz	t4,aac0 <_vsnprintf+0x1ef0>
    a002:	886e                	mv	a6,s11
    a004:	78884e0b          	th.ldia	t3,(a6),8,0
    a008:	4501                	li	a0,0
    a00a:	000e0863          	beqz	t3,a01a <_vsnprintf+0x144a>
    a00e:	43fe5d93          	srai	s11,t3,0x3f
    a012:	01cdc6b3          	xor	a3,s11,t3
    a016:	41b68533          	sub	a0,a3,s11
    a01a:	42a9                	li	t0,10
    a01c:	025573b3          	remu	t2,a0,t0
    a020:	03010313          	addi	t1,sp,48
    a024:	4ca5                	li	s9,9
    a026:	879a                	mv	a5,t1
    a028:	03038f1b          	addiw	t5,t2,48
    a02c:	03e10823          	sb	t5,48(sp)
    a030:	02555733          	divu	a4,a0,t0
    a034:	10acf963          	bgeu	s9,a0,a146 <_vsnprintf+0x1576>
    a038:	03110793          	addi	a5,sp,49
    a03c:	02577fb3          	remu	t6,a4,t0
    a040:	030f8e9b          	addiw	t4,t6,48
    a044:	01d78023          	sb	t4,0(a5)
    a048:	02575d33          	divu	s10,a4,t0
    a04c:	0eecfd63          	bgeu	s9,a4,a146 <_vsnprintf+0x1576>
    a050:	00178b93          	addi	s7,a5,1
    a054:	05010b13          	addi	s6,sp,80
    a058:	0f7b0763          	beq	s6,s7,a146 <_vsnprintf+0x1576>
    a05c:	87de                	mv	a5,s7
    a05e:	025d7ab3          	remu	s5,s10,t0
    a062:	030a861b          	addiw	a2,s5,48
    a066:	00cb8023          	sb	a2,0(s7)
    a06a:	025d5733          	divu	a4,s10,t0
    a06e:	0dacfc63          	bgeu	s9,s10,a146 <_vsnprintf+0x1576>
    a072:	02577fb3          	remu	t6,a4,t0
    a076:	030f8d9b          	addiw	s11,t6,48
    a07a:	0817dd8b          	th.sbib	s11,(a5),1,0
    a07e:	025756b3          	divu	a3,a4,t0
    a082:	0cecf263          	bgeu	s9,a4,a146 <_vsnprintf+0x1576>
    a086:	002b8793          	addi	a5,s7,2
    a08a:	0256f533          	remu	a0,a3,t0
    a08e:	0305039b          	addiw	t2,a0,48
    a092:	007b8123          	sb	t2,2(s7)
    a096:	0256df33          	divu	t5,a3,t0
    a09a:	0adcf663          	bgeu	s9,a3,a146 <_vsnprintf+0x1576>
    a09e:	003b8793          	addi	a5,s7,3
    a0a2:	025f7eb3          	remu	t4,t5,t0
    a0a6:	030e8d1b          	addiw	s10,t4,48
    a0aa:	01ab81a3          	sb	s10,3(s7)
    a0ae:	025f5b33          	divu	s6,t5,t0
    a0b2:	09ecfa63          	bgeu	s9,t5,a146 <_vsnprintf+0x1576>
    a0b6:	004b8793          	addi	a5,s7,4
    a0ba:	025b7ab3          	remu	s5,s6,t0
    a0be:	030a861b          	addiw	a2,s5,48
    a0c2:	00cb8223          	sb	a2,4(s7)
    a0c6:	025b5733          	divu	a4,s6,t0
    a0ca:	076cfe63          	bgeu	s9,s6,a146 <_vsnprintf+0x1576>
    a0ce:	005b8793          	addi	a5,s7,5
    a0d2:	02577fb3          	remu	t6,a4,t0
    a0d6:	030f8d9b          	addiw	s11,t6,48
    a0da:	01bb82a3          	sb	s11,5(s7)
    a0de:	025756b3          	divu	a3,a4,t0
    a0e2:	06ecf263          	bgeu	s9,a4,a146 <_vsnprintf+0x1576>
    a0e6:	006b8793          	addi	a5,s7,6
    a0ea:	0256f533          	remu	a0,a3,t0
    a0ee:	0305039b          	addiw	t2,a0,48
    a0f2:	007b8323          	sb	t2,6(s7)
    a0f6:	0256deb3          	divu	t4,a3,t0
    a0fa:	04dcf663          	bgeu	s9,a3,a146 <_vsnprintf+0x1576>
    a0fe:	007b8793          	addi	a5,s7,7
    a102:	025eff33          	remu	t5,t4,t0
    a106:	030f0d1b          	addiw	s10,t5,48
    a10a:	01ab83a3          	sb	s10,7(s7)
    a10e:	025edb33          	divu	s6,t4,t0
    a112:	03dcfa63          	bgeu	s9,t4,a146 <_vsnprintf+0x1576>
    a116:	008b8793          	addi	a5,s7,8
    a11a:	025b7ab3          	remu	s5,s6,t0
    a11e:	030a861b          	addiw	a2,s5,48
    a122:	00cb8423          	sb	a2,8(s7)
    a126:	025b5733          	divu	a4,s6,t0
    a12a:	016cfe63          	bgeu	s9,s6,a146 <_vsnprintf+0x1576>
    a12e:	009b8793          	addi	a5,s7,9
    a132:	02577fb3          	remu	t6,a4,t0
    a136:	030f8e9b          	addiw	t4,t6,48
    a13a:	01d78023          	sb	t4,0(a5)
    a13e:	02575d33          	divu	s10,a4,t0
    a142:	f0ece7e3          	bltu	s9,a4,a050 <_vsnprintf+0x1480>
    a146:	406787b3          	sub	a5,a5,t1
    a14a:	0025fb13          	andi	s6,a1,2
    a14e:	0785                	addi	a5,a5,1
    a150:	82ae                	mv	t0,a1
    a152:	000b1463          	bnez	s6,a15a <_vsnprintf+0x158a>
    a156:	4200306f          	j	d576 <_vsnprintf+0x49a6>
    a15a:	02000c13          	li	s8,32
    a15e:	4b09                	li	s6,2
    a160:	01878463          	beq	a5,s8,a168 <_vsnprintf+0x1598>
    a164:	6190306f          	j	df7c <_vsnprintf+0x53ac>
    a168:	04f14503          	lbu	a0,79(sp)
    a16c:	6382                	ld	t2,0(sp)
    a16e:	8dc2                	mv	s11,a6
    a170:	02000d13          	li	s10,32
    a174:	01a30c33          	add	s8,t1,s10
    a178:	fff34813          	not	a6,t1
    a17c:	018802b3          	add	t0,a6,s8
    a180:	01a38cb3          	add	s9,t2,s10
    a184:	0072fd13          	andi	s10,t0,7
    a188:	01930bb3          	add	s7,t1,s9
    a18c:	000d1463          	bnez	s10,a194 <_vsnprintf+0x15c4>
    a190:	5910306f          	j	df20 <_vsnprintf+0x5350>
    a194:	418b8633          	sub	a2,s7,s8
    a198:	ec46                	sd	a7,24(sp)
    a19a:	f01a                	sd	t1,32(sp)
    a19c:	86a6                	mv	a3,s1
    a19e:	85ca                	mv	a1,s2
    a1a0:	9402                	jalr	s0
    a1a2:	4f85                	li	t6,1
    a1a4:	68e2                	ld	a7,24(sp)
    a1a6:	7302                	ld	t1,32(sp)
    a1a8:	1c7d                	addi	s8,s8,-1
    a1aa:	fffc4503          	lbu	a0,-1(s8)
    a1ae:	01fd1463          	bne	s10,t6,a1b6 <_vsnprintf+0x15e6>
    a1b2:	56f0306f          	j	df20 <_vsnprintf+0x5350>
    a1b6:	4389                	li	t2,2
    a1b8:	087d0863          	beq	s10,t2,a248 <_vsnprintf+0x1678>
    a1bc:	470d                	li	a4,3
    a1be:	06ed0963          	beq	s10,a4,a230 <_vsnprintf+0x1660>
    a1c2:	4a91                	li	s5,4
    a1c4:	055d0a63          	beq	s10,s5,a218 <_vsnprintf+0x1648>
    a1c8:	4e95                	li	t4,5
    a1ca:	03dd0b63          	beq	s10,t4,a200 <_vsnprintf+0x1630>
    a1ce:	4f19                	li	t5,6
    a1d0:	01ed0c63          	beq	s10,t5,a1e8 <_vsnprintf+0x1618>
    a1d4:	418b8633          	sub	a2,s7,s8
    a1d8:	86a6                	mv	a3,s1
    a1da:	85ca                	mv	a1,s2
    a1dc:	9402                	jalr	s0
    a1de:	68e2                	ld	a7,24(sp)
    a1e0:	7302                	ld	t1,32(sp)
    a1e2:	ffec4503          	lbu	a0,-2(s8)
    a1e6:	1c7d                	addi	s8,s8,-1
    a1e8:	ec46                	sd	a7,24(sp)
    a1ea:	f01a                	sd	t1,32(sp)
    a1ec:	418b8633          	sub	a2,s7,s8
    a1f0:	86a6                	mv	a3,s1
    a1f2:	85ca                	mv	a1,s2
    a1f4:	9402                	jalr	s0
    a1f6:	68e2                	ld	a7,24(sp)
    a1f8:	7302                	ld	t1,32(sp)
    a1fa:	ffec4503          	lbu	a0,-2(s8)
    a1fe:	1c7d                	addi	s8,s8,-1
    a200:	ec46                	sd	a7,24(sp)
    a202:	f01a                	sd	t1,32(sp)
    a204:	418b8633          	sub	a2,s7,s8
    a208:	86a6                	mv	a3,s1
    a20a:	85ca                	mv	a1,s2
    a20c:	9402                	jalr	s0
    a20e:	68e2                	ld	a7,24(sp)
    a210:	7302                	ld	t1,32(sp)
    a212:	ffec4503          	lbu	a0,-2(s8)
    a216:	1c7d                	addi	s8,s8,-1
    a218:	ec46                	sd	a7,24(sp)
    a21a:	f01a                	sd	t1,32(sp)
    a21c:	418b8633          	sub	a2,s7,s8
    a220:	86a6                	mv	a3,s1
    a222:	85ca                	mv	a1,s2
    a224:	9402                	jalr	s0
    a226:	68e2                	ld	a7,24(sp)
    a228:	7302                	ld	t1,32(sp)
    a22a:	ffec4503          	lbu	a0,-2(s8)
    a22e:	1c7d                	addi	s8,s8,-1
    a230:	ec46                	sd	a7,24(sp)
    a232:	f01a                	sd	t1,32(sp)
    a234:	418b8633          	sub	a2,s7,s8
    a238:	86a6                	mv	a3,s1
    a23a:	85ca                	mv	a1,s2
    a23c:	9402                	jalr	s0
    a23e:	68e2                	ld	a7,24(sp)
    a240:	7302                	ld	t1,32(sp)
    a242:	ffec4503          	lbu	a0,-2(s8)
    a246:	1c7d                	addi	s8,s8,-1
    a248:	418b8633          	sub	a2,s7,s8
    a24c:	ec46                	sd	a7,24(sp)
    a24e:	f01a                	sd	t1,32(sp)
    a250:	86a6                	mv	a3,s1
    a252:	85ca                	mv	a1,s2
    a254:	9402                	jalr	s0
    a256:	1c7d                	addi	s8,s8,-1
    a258:	6d62                	ld	s10,24(sp)
    a25a:	7a82                	ld	s5,32(sp)
    a25c:	fffc4503          	lbu	a0,-1(s8)
    a260:	a071                	j	a2ec <_vsnprintf+0x171c>
    a262:	87e2                	mv	a5,s8
    a264:	40ab8633          	sub	a2,s7,a0
    a268:	89e7c50b          	th.lbuib	a0,(a5),-2,0
    a26c:	86a6                	mv	a3,s1
    a26e:	85ca                	mv	a1,s2
    a270:	ec3e                	sd	a5,24(sp)
    a272:	9402                	jalr	s0
    a274:	8e62                	mv	t3,s8
    a276:	89de450b          	th.lbuib	a0,(t3),-3,0
    a27a:	6662                	ld	a2,24(sp)
    a27c:	86a6                	mv	a3,s1
    a27e:	ec72                	sd	t3,24(sp)
    a280:	85ca                	mv	a1,s2
    a282:	40cb8633          	sub	a2,s7,a2
    a286:	9402                	jalr	s0
    a288:	8862                	mv	a6,s8
    a28a:	89c8450b          	th.lbuib	a0,(a6),-4,0
    a28e:	62e2                	ld	t0,24(sp)
    a290:	86a6                	mv	a3,s1
    a292:	ec42                	sd	a6,24(sp)
    a294:	405b8633          	sub	a2,s7,t0
    a298:	85ca                	mv	a1,s2
    a29a:	9402                	jalr	s0
    a29c:	8fe2                	mv	t6,s8
    a29e:	89bfc50b          	th.lbuib	a0,(t6),-5,0
    a2a2:	63e2                	ld	t2,24(sp)
    a2a4:	86a6                	mv	a3,s1
    a2a6:	ec7e                	sd	t6,24(sp)
    a2a8:	407b8633          	sub	a2,s7,t2
    a2ac:	85ca                	mv	a1,s2
    a2ae:	9402                	jalr	s0
    a2b0:	8762                	mv	a4,s8
    a2b2:	89a7450b          	th.lbuib	a0,(a4),-6,0
    a2b6:	6ee2                	ld	t4,24(sp)
    a2b8:	86a6                	mv	a3,s1
    a2ba:	ec3a                	sd	a4,24(sp)
    a2bc:	41db8633          	sub	a2,s7,t4
    a2c0:	85ca                	mv	a1,s2
    a2c2:	9402                	jalr	s0
    a2c4:	8f62                	mv	t5,s8
    a2c6:	899f450b          	th.lbuib	a0,(t5),-7,0
    a2ca:	6362                	ld	t1,24(sp)
    a2cc:	86a6                	mv	a3,s1
    a2ce:	85ca                	mv	a1,s2
    a2d0:	406b8633          	sub	a2,s7,t1
    a2d4:	ec7a                	sd	t5,24(sp)
    a2d6:	9402                	jalr	s0
    a2d8:	68e2                	ld	a7,24(sp)
    a2da:	898c450b          	th.lbuib	a0,(s8),-8,0
    a2de:	86a6                	mv	a3,s1
    a2e0:	85ca                	mv	a1,s2
    a2e2:	411b8633          	sub	a2,s7,a7
    a2e6:	9402                	jalr	s0
    a2e8:	fffc4503          	lbu	a0,-1(s8)
    a2ec:	86a6                	mv	a3,s1
    a2ee:	418b8633          	sub	a2,s7,s8
    a2f2:	85ca                	mv	a1,s2
    a2f4:	ec66                	sd	s9,24(sp)
    a2f6:	9402                	jalr	s0
    a2f8:	fffc0513          	addi	a0,s8,-1
    a2fc:	6e62                	ld	t3,24(sp)
    a2fe:	f6aa92e3          	bne	s5,a0,a262 <_vsnprintf+0x1692>
    a302:	88ea                	mv	a7,s10
    a304:	180b0463          	beqz	s6,a48c <_vsnprintf+0x18bc>
    a308:	6b02                	ld	s6,0(sp)
    a30a:	7c08bb8b          	th.extu	s7,a7,31,0
    a30e:	416e0cb3          	sub	s9,t3,s6
    a312:	177cfd63          	bgeu	s9,s7,a48c <_vsnprintf+0x18bc>
    a316:	fffcc793          	not	a5,s9
    a31a:	01778633          	add	a2,a5,s7
    a31e:	00767d13          	andi	s10,a2,7
    a322:	8672                	mv	a2,t3
    a324:	0e05                	addi	t3,t3,1
    a326:	e072                	sd	t3,0(sp)
    a328:	86a6                	mv	a3,s1
    a32a:	85ca                	mv	a1,s2
    a32c:	02000513          	li	a0,32
    a330:	9402                	jalr	s0
    a332:	001c8c13          	addi	s8,s9,1
    a336:	6e02                	ld	t3,0(sp)
    a338:	157c7a63          	bgeu	s8,s7,a48c <_vsnprintf+0x18bc>
    a33c:	0c0d0463          	beqz	s10,a404 <_vsnprintf+0x1834>
    a340:	4585                	li	a1,1
    a342:	0abd0463          	beq	s10,a1,a3ea <_vsnprintf+0x181a>
    a346:	4689                	li	a3,2
    a348:	08dd0663          	beq	s10,a3,a3d4 <_vsnprintf+0x1804>
    a34c:	480d                	li	a6,3
    a34e:	070d0863          	beq	s10,a6,a3be <_vsnprintf+0x17ee>
    a352:	4291                	li	t0,4
    a354:	045d0a63          	beq	s10,t0,a3a8 <_vsnprintf+0x17d8>
    a358:	4f95                	li	t6,5
    a35a:	03fd0c63          	beq	s10,t6,a392 <_vsnprintf+0x17c2>
    a35e:	4399                	li	t2,6
    a360:	007d0e63          	beq	s10,t2,a37c <_vsnprintf+0x17ac>
    a364:	001e0713          	addi	a4,t3,1
    a368:	8672                	mv	a2,t3
    a36a:	86a6                	mv	a3,s1
    a36c:	85ca                	mv	a1,s2
    a36e:	02000513          	li	a0,32
    a372:	e03a                	sd	a4,0(sp)
    a374:	9402                	jalr	s0
    a376:	6e02                	ld	t3,0(sp)
    a378:	002c8c13          	addi	s8,s9,2
    a37c:	001e0e93          	addi	t4,t3,1
    a380:	8672                	mv	a2,t3
    a382:	86a6                	mv	a3,s1
    a384:	85ca                	mv	a1,s2
    a386:	02000513          	li	a0,32
    a38a:	e076                	sd	t4,0(sp)
    a38c:	9402                	jalr	s0
    a38e:	6e02                	ld	t3,0(sp)
    a390:	0c05                	addi	s8,s8,1
    a392:	001e0f13          	addi	t5,t3,1
    a396:	8672                	mv	a2,t3
    a398:	86a6                	mv	a3,s1
    a39a:	85ca                	mv	a1,s2
    a39c:	02000513          	li	a0,32
    a3a0:	e07a                	sd	t5,0(sp)
    a3a2:	9402                	jalr	s0
    a3a4:	6e02                	ld	t3,0(sp)
    a3a6:	0c05                	addi	s8,s8,1
    a3a8:	001e0313          	addi	t1,t3,1
    a3ac:	8672                	mv	a2,t3
    a3ae:	86a6                	mv	a3,s1
    a3b0:	85ca                	mv	a1,s2
    a3b2:	02000513          	li	a0,32
    a3b6:	e01a                	sd	t1,0(sp)
    a3b8:	9402                	jalr	s0
    a3ba:	6e02                	ld	t3,0(sp)
    a3bc:	0c05                	addi	s8,s8,1
    a3be:	001e0a93          	addi	s5,t3,1
    a3c2:	8672                	mv	a2,t3
    a3c4:	86a6                	mv	a3,s1
    a3c6:	85ca                	mv	a1,s2
    a3c8:	02000513          	li	a0,32
    a3cc:	e056                	sd	s5,0(sp)
    a3ce:	9402                	jalr	s0
    a3d0:	6e02                	ld	t3,0(sp)
    a3d2:	0c05                	addi	s8,s8,1
    a3d4:	001e0893          	addi	a7,t3,1
    a3d8:	8672                	mv	a2,t3
    a3da:	86a6                	mv	a3,s1
    a3dc:	85ca                	mv	a1,s2
    a3de:	02000513          	li	a0,32
    a3e2:	e046                	sd	a7,0(sp)
    a3e4:	9402                	jalr	s0
    a3e6:	6e02                	ld	t3,0(sp)
    a3e8:	0c05                	addi	s8,s8,1
    a3ea:	001e0b13          	addi	s6,t3,1
    a3ee:	8672                	mv	a2,t3
    a3f0:	86a6                	mv	a3,s1
    a3f2:	85ca                	mv	a1,s2
    a3f4:	02000513          	li	a0,32
    a3f8:	e05a                	sd	s6,0(sp)
    a3fa:	9402                	jalr	s0
    a3fc:	0c05                	addi	s8,s8,1
    a3fe:	6e02                	ld	t3,0(sp)
    a400:	097c7663          	bgeu	s8,s7,a48c <_vsnprintf+0x18bc>
    a404:	8af2                	mv	s5,t3
    a406:	8656                	mv	a2,s5
    a408:	86a6                	mv	a3,s1
    a40a:	85ca                	mv	a1,s2
    a40c:	02000513          	li	a0,32
    a410:	9402                	jalr	s0
    a412:	001a8d13          	addi	s10,s5,1
    a416:	866a                	mv	a2,s10
    a418:	86a6                	mv	a3,s1
    a41a:	85ca                	mv	a1,s2
    a41c:	02000513          	li	a0,32
    a420:	9402                	jalr	s0
    a422:	002a8c93          	addi	s9,s5,2
    a426:	8666                	mv	a2,s9
    a428:	86a6                	mv	a3,s1
    a42a:	85ca                	mv	a1,s2
    a42c:	02000513          	li	a0,32
    a430:	9402                	jalr	s0
    a432:	003a8b13          	addi	s6,s5,3
    a436:	865a                	mv	a2,s6
    a438:	86a6                	mv	a3,s1
    a43a:	85ca                	mv	a1,s2
    a43c:	02000513          	li	a0,32
    a440:	9402                	jalr	s0
    a442:	004a8d13          	addi	s10,s5,4
    a446:	866a                	mv	a2,s10
    a448:	86a6                	mv	a3,s1
    a44a:	85ca                	mv	a1,s2
    a44c:	02000513          	li	a0,32
    a450:	9402                	jalr	s0
    a452:	005a8b13          	addi	s6,s5,5
    a456:	86a6                	mv	a3,s1
    a458:	865a                	mv	a2,s6
    a45a:	85ca                	mv	a1,s2
    a45c:	02000513          	li	a0,32
    a460:	9402                	jalr	s0
    a462:	006a8c93          	addi	s9,s5,6
    a466:	86a6                	mv	a3,s1
    a468:	8666                	mv	a2,s9
    a46a:	85ca                	mv	a1,s2
    a46c:	02000513          	li	a0,32
    a470:	9402                	jalr	s0
    a472:	007a8d13          	addi	s10,s5,7
    a476:	86a6                	mv	a3,s1
    a478:	866a                	mv	a2,s10
    a47a:	85ca                	mv	a1,s2
    a47c:	02000513          	li	a0,32
    a480:	0c21                	addi	s8,s8,8
    a482:	0aa1                	addi	s5,s5,8
    a484:	9402                	jalr	s0
    a486:	f97c60e3          	bltu	s8,s7,a406 <_vsnprintf+0x1836>
    a48a:	8e56                	mv	t3,s5
    a48c:	e072                	sd	t3,0(sp)
    a48e:	a829                	j	a4a8 <_vsnprintf+0x18d8>
    a490:	6602                	ld	a2,0(sp)
    a492:	988dc50b          	th.lbuia	a0,(s11),8,0
    a496:	86a6                	mv	a3,s1
    a498:	85ca                	mv	a1,s2
    a49a:	00160b13          	addi	s6,a2,1
    a49e:	9402                	jalr	s0
    a4a0:	e05a                	sd	s6,0(sp)
    a4a2:	0001                	nop
    a4a4:	00000013          	nop
    a4a8:	63a2                	ld	t2,8(sp)
    a4aa:	00138c93          	addi	s9,t2,1
    a4ae:	f82fe06f          	j	8c30 <_vsnprintf+0x60>
    a4b2:	88ea                	mv	a7,s10
    a4b4:	8d66                	mv	s10,s9
    a4b6:	e06a                	sd	s10,0(sp)
    a4b8:	fe0a88e3          	beqz	s5,a4a8 <_vsnprintf+0x18d8>
    a4bc:	ea7fe06f          	j	9362 <_vsnprintf+0x792>
    a4c0:	0025f893          	andi	a7,a1,2
    a4c4:	852e                	mv	a0,a1
    a4c6:	56089d63          	bnez	a7,aa40 <_vsnprintf+0x1e70>
    a4ca:	00c5fe13          	andi	t3,a1,12
    a4ce:	3a0e1ae3          	bnez	t3,b082 <_vsnprintf+0x24b2>
    a4d2:	47c1                	li	a5,16
    a4d4:	8abe                	mv	s5,a5
    a4d6:	7c0c3f8b          	th.extu	t6,s8,31,0
    a4da:	29fd62e3          	bltu	s10,t6,af5e <_vsnprintf+0x238e>
    a4de:	00fd6463          	bltu	s10,a5,a4e6 <_vsnprintf+0x1916>
    a4e2:	3730206f          	j	d054 <_vsnprintf+0x4484>
    a4e6:	03000c13          	li	s8,48
    a4ea:	018103b3          	add	t2,sp,s8
    a4ee:	007d0833          	add	a6,s10,t2
    a4f2:	001d0e13          	addi	t3,s10,1
    a4f6:	01880023          	sb	s8,0(a6)
    a4fa:	00fe6463          	bltu	t3,a5,a502 <_vsnprintf+0x1932>
    a4fe:	52d0306f          	j	e22a <_vsnprintf+0x565a>
    a502:	9e0a                	add	t3,t3,sp
    a504:	03000313          	li	t1,48
    a508:	002d0e93          	addi	t4,s10,2
    a50c:	026e0823          	sb	t1,48(t3)
    a510:	70fefae3          	bgeu	t4,a5,b424 <_vsnprintf+0x2854>
    a514:	00610533          	add	a0,sp,t1
    a518:	00ad0c33          	add	s8,s10,a0
    a51c:	003d0f13          	addi	t5,s10,3
    a520:	006c0123          	sb	t1,2(s8)
    a524:	70ff70e3          	bgeu	t5,a5,b424 <_vsnprintf+0x2854>
    a528:	00ad0833          	add	a6,s10,a0
    a52c:	004d0613          	addi	a2,s10,4
    a530:	006801a3          	sb	t1,3(a6)
    a534:	6ef678e3          	bgeu	a2,a5,b424 <_vsnprintf+0x2854>
    a538:	00ad0733          	add	a4,s10,a0
    a53c:	005d0293          	addi	t0,s10,5
    a540:	00670223          	sb	t1,4(a4)
    a544:	6ef2f0e3          	bgeu	t0,a5,b424 <_vsnprintf+0x2854>
    a548:	00ad0f33          	add	t5,s10,a0
    a54c:	006d0e13          	addi	t3,s10,6
    a550:	006f02a3          	sb	t1,5(t5)
    a554:	6cfe78e3          	bgeu	t3,a5,b424 <_vsnprintf+0x2854>
    a558:	00ad0633          	add	a2,s10,a0
    a55c:	007d0893          	addi	a7,s10,7
    a560:	00660323          	sb	t1,6(a2)
    a564:	6cf8f0e3          	bgeu	a7,a5,b424 <_vsnprintf+0x2854>
    a568:	00ad02b3          	add	t0,s10,a0
    a56c:	008d0393          	addi	t2,s10,8
    a570:	006283a3          	sb	t1,7(t0)
    a574:	6af3f8e3          	bgeu	t2,a5,b424 <_vsnprintf+0x2854>
    a578:	00ad0e33          	add	t3,s10,a0
    a57c:	009d0e93          	addi	t4,s10,9
    a580:	006e0423          	sb	t1,8(t3)
    a584:	6afef0e3          	bgeu	t4,a5,b424 <_vsnprintf+0x2854>
    a588:	00ad08b3          	add	a7,s10,a0
    a58c:	00ad0f13          	addi	t5,s10,10
    a590:	006884a3          	sb	t1,9(a7)
    a594:	68ff78e3          	bgeu	t5,a5,b424 <_vsnprintf+0x2854>
    a598:	00ad03b3          	add	t2,s10,a0
    a59c:	00bd0c13          	addi	s8,s10,11
    a5a0:	00638523          	sb	t1,10(t2)
    a5a4:	68fc70e3          	bgeu	s8,a5,b424 <_vsnprintf+0x2854>
    a5a8:	00ad0eb3          	add	t4,s10,a0
    a5ac:	03000713          	li	a4,48
    a5b0:	00cd0313          	addi	t1,s10,12
    a5b4:	00ee85a3          	sb	a4,11(t4)
    a5b8:	66f376e3          	bgeu	t1,a5,b424 <_vsnprintf+0x2854>
    a5bc:	00ad06b3          	add	a3,s10,a0
    a5c0:	00dd0e13          	addi	t3,s10,13
    a5c4:	00e68623          	sb	a4,12(a3)
    a5c8:	64fe7ee3          	bgeu	t3,a5,b424 <_vsnprintf+0x2854>
    a5cc:	00ad0633          	add	a2,s10,a0
    a5d0:	00ed0893          	addi	a7,s10,14
    a5d4:	00e606a3          	sb	a4,13(a2)
    a5d8:	64f8f6e3          	bgeu	a7,a5,b424 <_vsnprintf+0x2854>
    a5dc:	00ad0333          	add	t1,s10,a0
    a5e0:	01a03d33          	snez	s10,s10
    a5e4:	00e30723          	sb	a4,14(t1)
    a5e8:	00fd0813          	addi	a6,s10,15
    a5ec:	62f87ce3          	bgeu	a6,a5,b424 <_vsnprintf+0x2854>
    a5f0:	02e10fa3          	sb	a4,63(sp)
    a5f4:	000b8463          	beqz	s7,a5fc <_vsnprintf+0x1a2c>
    a5f8:	3620106f          	j	b95a <_vsnprintf+0x2d8a>
    a5fc:	0045fe13          	andi	t3,a1,4
    a600:	000e0463          	beqz	t3,a608 <_vsnprintf+0x1a38>
    a604:	10e0306f          	j	d712 <_vsnprintf+0x4b42>
    a608:	0085fb93          	andi	s7,a1,8
    a60c:	000b8463          	beqz	s7,a614 <_vsnprintf+0x1a44>
    a610:	1650306f          	j	df74 <_vsnprintf+0x53a4>
    a614:	4d41                	li	s10,16
    a616:	06010f93          	addi	t6,sp,96
    a61a:	fdffc503          	lbu	a0,-33(t6)
    a61e:	a47d                	j	a8cc <_vsnprintf+0x1cfc>
    a620:	885a                	mv	a6,s6
    a622:	87c6                	mv	a5,a7
    a624:	8762                	mv	a4,s8
    a626:	6602                	ld	a2,0(sp)
    a628:	86a6                	mv	a3,s1
    a62a:	85ca                	mv	a1,s2
    a62c:	8522                	mv	a0,s0
    a62e:	b13fc0ef          	jal	7140 <_ftoa>
    a632:	e02a                	sd	a0,0(sp)
    a634:	6622                	ld	a2,8(sp)
    a636:	8dde                	mv	s11,s7
    a638:	00160c93          	addi	s9,a2,1
    a63c:	df4fe06f          	j	8c30 <_vsnprintf+0x60>
    a640:	6505                	lui	a0,0x1
    a642:	80050813          	addi	a6,a0,-2048 # 800 <cmp_complex+0x90>
    a646:	010b62b3          	or	t0,s6,a6
    a64a:	00028b1b          	sext.w	s6,t0
    a64e:	020b6313          	ori	t1,s6,32
    a652:	00030b1b          	sext.w	s6,t1
    a656:	ed3fe06f          	j	9528 <_vsnprintf+0x958>
    a65a:	400b7793          	andi	a5,s6,1024
    a65e:	41ac8bbb          	subw	s7,s9,s10
    a662:	c399                	beqz	a5,a668 <_vsnprintf+0x1a98>
    a664:	b17fe06f          	j	917a <_vsnprintf+0x5aa>
    a668:	002b7b13          	andi	s6,s6,2
    a66c:	000b1463          	bnez	s6,a674 <_vsnprintf+0x1aa4>
    a670:	4b20106f          	j	bb22 <_vsnprintf+0x2f52>
    a674:	6c82                	ld	s9,0(sp)
    a676:	4a89                	li	s5,2
    a678:	8b66                	mv	s6,s9
    a67a:	419d0d33          	sub	s10,s10,s9
    a67e:	8cc6                	mv	s9,a7
    a680:	865a                	mv	a2,s6
    a682:	86a6                	mv	a3,s1
    a684:	85ca                	mv	a1,s2
    a686:	0b05                	addi	s6,s6,1
    a688:	9402                	jalr	s0
    a68a:	816d450b          	th.lrbu	a0,s10,s6,0
    a68e:	8c5a                	mv	s8,s6
    a690:	cd3d                	beqz	a0,a70e <_vsnprintf+0x1b3e>
    a692:	86a6                	mv	a3,s1
    a694:	8662                	mv	a2,s8
    a696:	85ca                	mv	a1,s2
    a698:	0b05                	addi	s6,s6,1
    a69a:	9402                	jalr	s0
    a69c:	816d450b          	th.lrbu	a0,s10,s6,0
    a6a0:	c53d                	beqz	a0,a70e <_vsnprintf+0x1b3e>
    a6a2:	865a                	mv	a2,s6
    a6a4:	86a6                	mv	a3,s1
    a6a6:	85ca                	mv	a1,s2
    a6a8:	002c0b13          	addi	s6,s8,2
    a6ac:	9402                	jalr	s0
    a6ae:	816d450b          	th.lrbu	a0,s10,s6,0
    a6b2:	cd31                	beqz	a0,a70e <_vsnprintf+0x1b3e>
    a6b4:	865a                	mv	a2,s6
    a6b6:	86a6                	mv	a3,s1
    a6b8:	85ca                	mv	a1,s2
    a6ba:	003c0b13          	addi	s6,s8,3
    a6be:	9402                	jalr	s0
    a6c0:	816d450b          	th.lrbu	a0,s10,s6,0
    a6c4:	c529                	beqz	a0,a70e <_vsnprintf+0x1b3e>
    a6c6:	865a                	mv	a2,s6
    a6c8:	86a6                	mv	a3,s1
    a6ca:	85ca                	mv	a1,s2
    a6cc:	004c0b13          	addi	s6,s8,4
    a6d0:	9402                	jalr	s0
    a6d2:	816d450b          	th.lrbu	a0,s10,s6,0
    a6d6:	cd05                	beqz	a0,a70e <_vsnprintf+0x1b3e>
    a6d8:	865a                	mv	a2,s6
    a6da:	86a6                	mv	a3,s1
    a6dc:	85ca                	mv	a1,s2
    a6de:	005c0b13          	addi	s6,s8,5
    a6e2:	9402                	jalr	s0
    a6e4:	816d450b          	th.lrbu	a0,s10,s6,0
    a6e8:	c11d                	beqz	a0,a70e <_vsnprintf+0x1b3e>
    a6ea:	865a                	mv	a2,s6
    a6ec:	86a6                	mv	a3,s1
    a6ee:	85ca                	mv	a1,s2
    a6f0:	006c0b13          	addi	s6,s8,6
    a6f4:	9402                	jalr	s0
    a6f6:	816d450b          	th.lrbu	a0,s10,s6,0
    a6fa:	c911                	beqz	a0,a70e <_vsnprintf+0x1b3e>
    a6fc:	865a                	mv	a2,s6
    a6fe:	86a6                	mv	a3,s1
    a700:	85ca                	mv	a1,s2
    a702:	007c0b13          	addi	s6,s8,7
    a706:	9402                	jalr	s0
    a708:	816d450b          	th.lrbu	a0,s10,s6,0
    a70c:	f935                	bnez	a0,a680 <_vsnprintf+0x1ab0>
    a70e:	e05a                	sd	s6,0(sp)
    a710:	88e6                	mv	a7,s9
    a712:	d80a8be3          	beqz	s5,a4a8 <_vsnprintf+0x18d8>
    a716:	c4dfe06f          	j	9362 <_vsnprintf+0x792>
    a71a:	0c0b6813          	ori	a6,s6,192
    a71e:	00278f93          	addi	t6,a5,2
    a722:	0027c503          	lbu	a0,2(a5)
    a726:	00080b1b          	sext.w	s6,a6
    a72a:	e47e                	sd	t6,8(sp)
    a72c:	dc4fe06f          	j	8cf0 <_vsnprintf+0x120>
    a730:	300b6513          	ori	a0,s6,768
    a734:	002e0293          	addi	t0,t3,2
    a738:	00050b1b          	sext.w	s6,a0
    a73c:	e416                	sd	t0,8(sp)
    a73e:	002e4503          	lbu	a0,2(t3)
    a742:	daefe06f          	j	8cf0 <_vsnprintf+0x120>
    a746:	4981                	li	s3,0
    a748:	ec6fe06f          	j	8e0e <_vsnprintf+0x23e>
    a74c:	020b6393          	ori	t2,s6,32
    a750:	47c1                	li	a5,16
    a752:	00038b1b          	sext.w	s6,t2
    a756:	86be                	mv	a3,a5
    a758:	eb0ff06f          	j	9e08 <_vsnprintf+0x1238>
    a75c:	4385                	li	t2,1
    a75e:	d313f9e3          	bgeu	t2,a7,a490 <_vsnprintf+0x18c0>
    a762:	6302                	ld	t1,0(sp)
    a764:	ffe8869b          	addiw	a3,a7,-2
    a768:	7c06bb0b          	th.extu	s6,a3,31,0
    a76c:	00730833          	add	a6,t1,t2
    a770:	01680cb3          	add	s9,a6,s6
    a774:	406c8fb3          	sub	t6,s9,t1
    a778:	007ff293          	andi	t0,t6,7
    a77c:	8d1a                	mv	s10,t1
    a77e:	08028663          	beqz	t0,a80a <_vsnprintf+0x1c3a>
    a782:	06728b63          	beq	t0,t2,a7f8 <_vsnprintf+0x1c28>
    a786:	4509                	li	a0,2
    a788:	06a28163          	beq	t0,a0,a7ea <_vsnprintf+0x1c1a>
    a78c:	4e8d                	li	t4,3
    a78e:	05d28763          	beq	t0,t4,a7dc <_vsnprintf+0x1c0c>
    a792:	4e11                	li	t3,4
    a794:	03c28d63          	beq	t0,t3,a7ce <_vsnprintf+0x1bfe>
    a798:	4f15                	li	t5,5
    a79a:	03e28363          	beq	t0,t5,a7c0 <_vsnprintf+0x1bf0>
    a79e:	4599                	li	a1,6
    a7a0:	00b28963          	beq	t0,a1,a7b2 <_vsnprintf+0x1be2>
    a7a4:	6602                	ld	a2,0(sp)
    a7a6:	86a6                	mv	a3,s1
    a7a8:	85ca                	mv	a1,s2
    a7aa:	02000513          	li	a0,32
    a7ae:	8d42                	mv	s10,a6
    a7b0:	9402                	jalr	s0
    a7b2:	866a                	mv	a2,s10
    a7b4:	86a6                	mv	a3,s1
    a7b6:	85ca                	mv	a1,s2
    a7b8:	02000513          	li	a0,32
    a7bc:	0d05                	addi	s10,s10,1
    a7be:	9402                	jalr	s0
    a7c0:	866a                	mv	a2,s10
    a7c2:	86a6                	mv	a3,s1
    a7c4:	85ca                	mv	a1,s2
    a7c6:	02000513          	li	a0,32
    a7ca:	0d05                	addi	s10,s10,1
    a7cc:	9402                	jalr	s0
    a7ce:	866a                	mv	a2,s10
    a7d0:	86a6                	mv	a3,s1
    a7d2:	85ca                	mv	a1,s2
    a7d4:	02000513          	li	a0,32
    a7d8:	0d05                	addi	s10,s10,1
    a7da:	9402                	jalr	s0
    a7dc:	866a                	mv	a2,s10
    a7de:	86a6                	mv	a3,s1
    a7e0:	85ca                	mv	a1,s2
    a7e2:	02000513          	li	a0,32
    a7e6:	0d05                	addi	s10,s10,1
    a7e8:	9402                	jalr	s0
    a7ea:	866a                	mv	a2,s10
    a7ec:	86a6                	mv	a3,s1
    a7ee:	85ca                	mv	a1,s2
    a7f0:	02000513          	li	a0,32
    a7f4:	0d05                	addi	s10,s10,1
    a7f6:	9402                	jalr	s0
    a7f8:	866a                	mv	a2,s10
    a7fa:	86a6                	mv	a3,s1
    a7fc:	0d05                	addi	s10,s10,1
    a7fe:	85ca                	mv	a1,s2
    a800:	02000513          	li	a0,32
    a804:	9402                	jalr	s0
    a806:	099d0363          	beq	s10,s9,a88c <_vsnprintf+0x1cbc>
    a80a:	866a                	mv	a2,s10
    a80c:	86a6                	mv	a3,s1
    a80e:	85ca                	mv	a1,s2
    a810:	02000513          	li	a0,32
    a814:	9402                	jalr	s0
    a816:	001d0a93          	addi	s5,s10,1
    a81a:	8656                	mv	a2,s5
    a81c:	86a6                	mv	a3,s1
    a81e:	85ca                	mv	a1,s2
    a820:	02000513          	li	a0,32
    a824:	9402                	jalr	s0
    a826:	002d0c13          	addi	s8,s10,2
    a82a:	8662                	mv	a2,s8
    a82c:	86a6                	mv	a3,s1
    a82e:	85ca                	mv	a1,s2
    a830:	02000513          	li	a0,32
    a834:	9402                	jalr	s0
    a836:	003d0b93          	addi	s7,s10,3
    a83a:	865e                	mv	a2,s7
    a83c:	86a6                	mv	a3,s1
    a83e:	85ca                	mv	a1,s2
    a840:	02000513          	li	a0,32
    a844:	9402                	jalr	s0
    a846:	004d0c13          	addi	s8,s10,4
    a84a:	8662                	mv	a2,s8
    a84c:	86a6                	mv	a3,s1
    a84e:	85ca                	mv	a1,s2
    a850:	02000513          	li	a0,32
    a854:	9402                	jalr	s0
    a856:	005d0a93          	addi	s5,s10,5
    a85a:	86a6                	mv	a3,s1
    a85c:	8656                	mv	a2,s5
    a85e:	85ca                	mv	a1,s2
    a860:	02000513          	li	a0,32
    a864:	9402                	jalr	s0
    a866:	006d0b93          	addi	s7,s10,6
    a86a:	86a6                	mv	a3,s1
    a86c:	865e                	mv	a2,s7
    a86e:	85ca                	mv	a1,s2
    a870:	02000513          	li	a0,32
    a874:	9402                	jalr	s0
    a876:	007d0c13          	addi	s8,s10,7
    a87a:	86a6                	mv	a3,s1
    a87c:	0d21                	addi	s10,s10,8
    a87e:	8662                	mv	a2,s8
    a880:	85ca                	mv	a1,s2
    a882:	02000513          	li	a0,32
    a886:	9402                	jalr	s0
    a888:	f99d11e3          	bne	s10,s9,a80a <_vsnprintf+0x1c3a>
    a88c:	6882                	ld	a7,0(sp)
    a88e:	988dc50b          	th.lbuia	a0,(s11),8,0
    a892:	86a6                	mv	a3,s1
    a894:	011b0733          	add	a4,s6,a7
    a898:	00270793          	addi	a5,a4,2
    a89c:	85ca                	mv	a1,s2
    a89e:	00170613          	addi	a2,a4,1
    a8a2:	e03e                	sd	a5,0(sp)
    a8a4:	9402                	jalr	s0
    a8a6:	b109                	j	a4a8 <_vsnprintf+0x18d8>
    a8a8:	0025f793          	andi	a5,a1,2
    a8ac:	68078b63          	beqz	a5,af42 <_vsnprintf+0x2372>
    a8b0:	000b83e3          	beqz	s7,b0b6 <_vsnprintf+0x24e6>
    a8b4:	000c9663          	bnez	s9,a8c0 <_vsnprintf+0x1cf0>
    a8b8:	011c1463          	bne	s8,a7,a8c0 <_vsnprintf+0x1cf0>
    a8bc:	6420406f          	j	eefe <_vsnprintf+0x632e>
    a8c0:	4b89                	li	s7,2
    a8c2:	4ac1                	li	s5,16
    a8c4:	04f14503          	lbu	a0,79(sp)
    a8c8:	02000d13          	li	s10,32
    a8cc:	6682                	ld	a3,0(sp)
    a8ce:	01ab0c33          	add	s8,s6,s10
    a8d2:	03110c93          	addi	s9,sp,49
    a8d6:	419c07b3          	sub	a5,s8,s9
    a8da:	9b36                	add	s6,s6,a3
    a8dc:	0077f893          	andi	a7,a5,7
    a8e0:	9b6a                	add	s6,s6,s10
    a8e2:	12088163          	beqz	a7,aa04 <_vsnprintf+0x1e34>
    a8e6:	418b0633          	sub	a2,s6,s8
    a8ea:	86a6                	mv	a3,s1
    a8ec:	85ca                	mv	a1,s2
    a8ee:	ec46                	sd	a7,24(sp)
    a8f0:	9402                	jalr	s0
    a8f2:	6762                	ld	a4,24(sp)
    a8f4:	4605                	li	a2,1
    a8f6:	ffec4503          	lbu	a0,-2(s8)
    a8fa:	1c7d                	addi	s8,s8,-1
    a8fc:	10c70463          	beq	a4,a2,aa04 <_vsnprintf+0x1e34>
    a900:	4389                	li	t2,2
    a902:	06770663          	beq	a4,t2,a96e <_vsnprintf+0x1d9e>
    a906:	430d                	li	t1,3
    a908:	04670b63          	beq	a4,t1,a95e <_vsnprintf+0x1d8e>
    a90c:	4811                	li	a6,4
    a90e:	05070063          	beq	a4,a6,a94e <_vsnprintf+0x1d7e>
    a912:	4f95                	li	t6,5
    a914:	03f70563          	beq	a4,t6,a93e <_vsnprintf+0x1d6e>
    a918:	4299                	li	t0,6
    a91a:	00570a63          	beq	a4,t0,a92e <_vsnprintf+0x1d5e>
    a91e:	418b0633          	sub	a2,s6,s8
    a922:	86a6                	mv	a3,s1
    a924:	85ca                	mv	a1,s2
    a926:	9402                	jalr	s0
    a928:	ffec4503          	lbu	a0,-2(s8)
    a92c:	1c7d                	addi	s8,s8,-1
    a92e:	418b0633          	sub	a2,s6,s8
    a932:	86a6                	mv	a3,s1
    a934:	85ca                	mv	a1,s2
    a936:	9402                	jalr	s0
    a938:	ffec4503          	lbu	a0,-2(s8)
    a93c:	1c7d                	addi	s8,s8,-1
    a93e:	418b0633          	sub	a2,s6,s8
    a942:	86a6                	mv	a3,s1
    a944:	85ca                	mv	a1,s2
    a946:	9402                	jalr	s0
    a948:	ffec4503          	lbu	a0,-2(s8)
    a94c:	1c7d                	addi	s8,s8,-1
    a94e:	418b0633          	sub	a2,s6,s8
    a952:	86a6                	mv	a3,s1
    a954:	85ca                	mv	a1,s2
    a956:	9402                	jalr	s0
    a958:	ffec4503          	lbu	a0,-2(s8)
    a95c:	1c7d                	addi	s8,s8,-1
    a95e:	418b0633          	sub	a2,s6,s8
    a962:	86a6                	mv	a3,s1
    a964:	85ca                	mv	a1,s2
    a966:	9402                	jalr	s0
    a968:	ffec4503          	lbu	a0,-2(s8)
    a96c:	1c7d                	addi	s8,s8,-1
    a96e:	418b0633          	sub	a2,s6,s8
    a972:	86a6                	mv	a3,s1
    a974:	85ca                	mv	a1,s2
    a976:	9402                	jalr	s0
    a978:	ffec4503          	lbu	a0,-2(s8)
    a97c:	1c7d                	addi	s8,s8,-1
    a97e:	a059                	j	aa04 <_vsnprintf+0x1e34>
    a980:	ffec4503          	lbu	a0,-2(s8)
    a984:	fffc0e13          	addi	t3,s8,-1
    a988:	41cb0633          	sub	a2,s6,t3
    a98c:	86a6                	mv	a3,s1
    a98e:	85ca                	mv	a1,s2
    a990:	9402                	jalr	s0
    a992:	ffdc4503          	lbu	a0,-3(s8)
    a996:	ffec0f13          	addi	t5,s8,-2
    a99a:	41eb0633          	sub	a2,s6,t5
    a99e:	86a6                	mv	a3,s1
    a9a0:	85ca                	mv	a1,s2
    a9a2:	9402                	jalr	s0
    a9a4:	ffcc4503          	lbu	a0,-4(s8)
    a9a8:	ffdc0593          	addi	a1,s8,-3
    a9ac:	40bb0633          	sub	a2,s6,a1
    a9b0:	86a6                	mv	a3,s1
    a9b2:	85ca                	mv	a1,s2
    a9b4:	9402                	jalr	s0
    a9b6:	ffbc4503          	lbu	a0,-5(s8)
    a9ba:	ffcc0793          	addi	a5,s8,-4
    a9be:	40fb0633          	sub	a2,s6,a5
    a9c2:	86a6                	mv	a3,s1
    a9c4:	85ca                	mv	a1,s2
    a9c6:	9402                	jalr	s0
    a9c8:	ffac4503          	lbu	a0,-6(s8)
    a9cc:	ffbc0893          	addi	a7,s8,-5
    a9d0:	411b0633          	sub	a2,s6,a7
    a9d4:	86a6                	mv	a3,s1
    a9d6:	85ca                	mv	a1,s2
    a9d8:	9402                	jalr	s0
    a9da:	ff9c4503          	lbu	a0,-7(s8)
    a9de:	ffac0613          	addi	a2,s8,-6
    a9e2:	86a6                	mv	a3,s1
    a9e4:	40cb0633          	sub	a2,s6,a2
    a9e8:	85ca                	mv	a1,s2
    a9ea:	9402                	jalr	s0
    a9ec:	ff8c4503          	lbu	a0,-8(s8)
    a9f0:	ff9c0713          	addi	a4,s8,-7
    a9f4:	86a6                	mv	a3,s1
    a9f6:	40eb0633          	sub	a2,s6,a4
    a9fa:	85ca                	mv	a1,s2
    a9fc:	9402                	jalr	s0
    a9fe:	ff7c4503          	lbu	a0,-9(s8)
    aa02:	1c61                	addi	s8,s8,-8
    aa04:	86a6                	mv	a3,s1
    aa06:	418b0633          	sub	a2,s6,s8
    aa0a:	85ca                	mv	a1,s2
    aa0c:	9402                	jalr	s0
    aa0e:	f78c99e3          	bne	s9,s8,a980 <_vsnprintf+0x1db0>
    aa12:	6502                	ld	a0,0(sp)
    aa14:	01a50eb3          	add	t4,a0,s10
    aa18:	e076                	sd	t4,0(sp)
    aa1a:	a80b87e3          	beqz	s7,a4a8 <_vsnprintf+0x18d8>
    aa1e:	7c0abb8b          	th.extu	s7,s5,31,0
    aa22:	a95d73e3          	bgeu	s10,s5,a4a8 <_vsnprintf+0x18d8>
    aa26:	8af6                	mv	s5,t4
    aa28:	8656                	mv	a2,s5
    aa2a:	86a6                	mv	a3,s1
    aa2c:	85ca                	mv	a1,s2
    aa2e:	02000513          	li	a0,32
    aa32:	0d05                	addi	s10,s10,1
    aa34:	0a85                	addi	s5,s5,1
    aa36:	9402                	jalr	s0
    aa38:	ff7d68e3          	bltu	s10,s7,aa28 <_vsnprintf+0x1e58>
    aa3c:	e056                	sd	s5,0(sp)
    aa3e:	b4ad                	j	a4a8 <_vsnprintf+0x18d8>
    aa40:	660b8563          	beqz	s7,b0aa <_vsnprintf+0x24da>
    aa44:	000c8463          	beqz	s9,aa4c <_vsnprintf+0x1e7c>
    aa48:	6c70106f          	j	c90e <_vsnprintf+0x3d3e>
    aa4c:	7c0c338b          	th.extu	t2,s8,31,0
    aa50:	007d1463          	bne	s10,t2,aa58 <_vsnprintf+0x1e88>
    aa54:	1140306f          	j	db68 <_vsnprintf+0x4f98>
    aa58:	47c1                	li	a5,16
    aa5a:	8abe                	mv	s5,a5
    aa5c:	4b89                	li	s7,2
    aa5e:	01a78463          	beq	a5,s10,aa66 <_vsnprintf+0x1e96>
    aa62:	6b10106f          	j	c912 <_vsnprintf+0x3d42>
    aa66:	1f40306f          	j	dc5a <_vsnprintf+0x508a>
    aa6a:	0001                	nop
    aa6c:	002b7613          	andi	a2,s6,2
    aa70:	5e061663          	bnez	a2,b05c <_vsnprintf+0x248c>
    aa74:	00c57b93          	andi	s7,a0,12
    aa78:	7c0c3f8b          	th.extu	t6,s8,31,0
    aa7c:	000b9463          	bnez	s7,aa84 <_vsnprintf+0x1eb4>
    aa80:	6000206f          	j	d080 <_vsnprintf+0x44b0>
    aa84:	000f9463          	bnez	t6,aa8c <_vsnprintf+0x1ebc>
    aa88:	3740406f          	j	edfc <_vsnprintf+0x622c>
    aa8c:	47bd                	li	a5,15
    aa8e:	4b81                	li	s7,0
    aa90:	4d01                	li	s10,0
    aa92:	40000c93          	li	s9,1024
    aa96:	8abe                	mv	s5,a5
    aa98:	03010b13          	addi	s6,sp,48
    aa9c:	a1c9                	j	af5e <_vsnprintf+0x238e>
    aa9e:	feeb7b13          	andi	s6,s6,-18
    aaa2:	000b059b          	sext.w	a1,s6
    aaa6:	2005f313          	andi	t1,a1,512
    aaaa:	8aae                	mv	s5,a1
    aaac:	00030463          	beqz	t1,aab4 <_vsnprintf+0x1ee4>
    aab0:	3f80106f          	j	bea8 <_vsnprintf+0x32d8>
    aab4:	1005f813          	andi	a6,a1,256
    aab8:	40000e93          	li	t4,1024
    aabc:	60081563          	bnez	a6,b0c6 <_vsnprintf+0x24f6>
    aac0:	0405fe13          	andi	t3,a1,64
    aac4:	580e1863          	bnez	t3,b054 <_vsnprintf+0x2484>
    aac8:	0805f293          	andi	t0,a1,128
    aacc:	00029463          	bnez	t0,aad4 <_vsnprintf+0x1f04>
    aad0:	5ca0206f          	j	d09a <_vsnprintf+0x44ca>
    aad4:	388dce0b          	th.lhia	t3,(s11),8,0
    aad8:	40fe571b          	sraiw	a4,t3,0xf
    aadc:	00ee4fb3          	xor	t6,t3,a4
    aae0:	40ef8cbb          	subw	s9,t6,a4
    aae4:	3c0cb38b          	th.extu	t2,s9,15,0
    aae8:	000e1763          	bnez	t3,aaf6 <_vsnprintf+0x1f26>
    aaec:	000e8463          	beqz	t4,aaf4 <_vsnprintf+0x1f24>
    aaf0:	5e00206f          	j	d0d0 <_vsnprintf+0x4500>
    aaf4:	4381                	li	t2,0
    aaf6:	47a9                	li	a5,10
    aaf8:	02f3fb33          	remu	s6,t2,a5
    aafc:	03010b93          	addi	s7,sp,48
    ab00:	4aa5                	li	s5,9
    ab02:	875e                	mv	a4,s7
    ab04:	030b031b          	addiw	t1,s6,48
    ab08:	02610823          	sb	t1,48(sp)
    ab0c:	02f3dfb3          	divu	t6,t2,a5
    ab10:	107afc63          	bgeu	s5,t2,ac28 <_vsnprintf+0x2058>
    ab14:	03110713          	addi	a4,sp,49
    ab18:	02fff633          	remu	a2,t6,a5
    ab1c:	0306081b          	addiw	a6,a2,48
    ab20:	01070023          	sb	a6,0(a4)
    ab24:	02ffdeb3          	divu	t4,t6,a5
    ab28:	11faf063          	bgeu	s5,t6,ac28 <_vsnprintf+0x2058>
    ab2c:	00000013          	nop
    ab30:	00170293          	addi	t0,a4,1
    ab34:	0888                	addi	a0,sp,80
    ab36:	0e550963          	beq	a0,t0,ac28 <_vsnprintf+0x2058>
    ab3a:	8716                	mv	a4,t0
    ab3c:	02fef633          	remu	a2,t4,a5
    ab40:	03060f9b          	addiw	t6,a2,48
    ab44:	01f28023          	sb	t6,0(t0)
    ab48:	02fedcb3          	divu	s9,t4,a5
    ab4c:	0ddafe63          	bgeu	s5,t4,ac28 <_vsnprintf+0x2058>
    ab50:	02fcfd33          	remu	s10,s9,a5
    ab54:	030d0f1b          	addiw	t5,s10,48
    ab58:	08175f0b          	th.sbib	t5,(a4),1,0
    ab5c:	02fcd6b3          	divu	a3,s9,a5
    ab60:	0d9af463          	bgeu	s5,s9,ac28 <_vsnprintf+0x2058>
    ab64:	00228713          	addi	a4,t0,2
    ab68:	02f6f3b3          	remu	t2,a3,a5
    ab6c:	03038b1b          	addiw	s6,t2,48
    ab70:	01628123          	sb	s6,2(t0)
    ab74:	02f6d333          	divu	t1,a3,a5
    ab78:	0adaf863          	bgeu	s5,a3,ac28 <_vsnprintf+0x2058>
    ab7c:	00328713          	addi	a4,t0,3
    ab80:	02f37833          	remu	a6,t1,a5
    ab84:	03080e9b          	addiw	t4,a6,48
    ab88:	01d281a3          	sb	t4,3(t0)
    ab8c:	02f35533          	divu	a0,t1,a5
    ab90:	086afc63          	bgeu	s5,t1,ac28 <_vsnprintf+0x2058>
    ab94:	00428713          	addi	a4,t0,4
    ab98:	02f57633          	remu	a2,a0,a5
    ab9c:	03060f9b          	addiw	t6,a2,48
    aba0:	01f28223          	sb	t6,4(t0)
    aba4:	02f55cb3          	divu	s9,a0,a5
    aba8:	08aaf063          	bgeu	s5,a0,ac28 <_vsnprintf+0x2058>
    abac:	00528713          	addi	a4,t0,5
    abb0:	02fcfd33          	remu	s10,s9,a5
    abb4:	030d0f1b          	addiw	t5,s10,48
    abb8:	01e282a3          	sb	t5,5(t0)
    abbc:	02fcd6b3          	divu	a3,s9,a5
    abc0:	079af463          	bgeu	s5,s9,ac28 <_vsnprintf+0x2058>
    abc4:	00628713          	addi	a4,t0,6
    abc8:	02f6f3b3          	remu	t2,a3,a5
    abcc:	03038b1b          	addiw	s6,t2,48
    abd0:	01628323          	sb	s6,6(t0)
    abd4:	02f6d833          	divu	a6,a3,a5
    abd8:	04daf863          	bgeu	s5,a3,ac28 <_vsnprintf+0x2058>
    abdc:	00728713          	addi	a4,t0,7
    abe0:	02f87333          	remu	t1,a6,a5
    abe4:	03030e9b          	addiw	t4,t1,48
    abe8:	01d283a3          	sb	t4,7(t0)
    abec:	02f85533          	divu	a0,a6,a5
    abf0:	030afc63          	bgeu	s5,a6,ac28 <_vsnprintf+0x2058>
    abf4:	00828713          	addi	a4,t0,8
    abf8:	02f57633          	remu	a2,a0,a5
    abfc:	03060f9b          	addiw	t6,a2,48
    ac00:	01f28423          	sb	t6,8(t0)
    ac04:	02f55cb3          	divu	s9,a0,a5
    ac08:	02aaf063          	bgeu	s5,a0,ac28 <_vsnprintf+0x2058>
    ac0c:	00928713          	addi	a4,t0,9
    ac10:	8fe6                	mv	t6,s9
    ac12:	02fcf633          	remu	a2,s9,a5
    ac16:	0306081b          	addiw	a6,a2,48
    ac1a:	01070023          	sb	a6,0(a4)
    ac1e:	02ffdeb3          	divu	t4,t6,a5
    ac22:	f1fae7e3          	bltu	s5,t6,ab30 <_vsnprintf+0x1f60>
    ac26:	0001                	nop
    ac28:	41770733          	sub	a4,a4,s7
    ac2c:	0025fb13          	andi	s6,a1,2
    ac30:	00170793          	addi	a5,a4,1
    ac34:	8aae                	mv	s5,a1
    ac36:	000b1463          	bnez	s6,ac3e <_vsnprintf+0x206e>
    ac3a:	1070106f          	j	c540 <_vsnprintf+0x3970>
    ac3e:	02000c13          	li	s8,32
    ac42:	4b09                	li	s6,2
    ac44:	01878463          	beq	a5,s8,ac4c <_vsnprintf+0x207c>
    ac48:	2db0206f          	j	d722 <_vsnprintf+0x4b52>
    ac4c:	04f14503          	lbu	a0,79(sp)
    ac50:	6302                	ld	t1,0(sp)
    ac52:	02000c13          	li	s8,32
    ac56:	018b8d33          	add	s10,s7,s8
    ac5a:	fffbcf13          	not	t5,s7
    ac5e:	006c0cb3          	add	s9,s8,t1
    ac62:	01af0333          	add	t1,t5,s10
    ac66:	00737813          	andi	a6,t1,7
    ac6a:	019b8c33          	add	s8,s7,s9
    ac6e:	00081463          	bnez	a6,ac76 <_vsnprintf+0x20a6>
    ac72:	6860206f          	j	d2f8 <_vsnprintf+0x4728>
    ac76:	41ac0633          	sub	a2,s8,s10
    ac7a:	ec46                	sd	a7,24(sp)
    ac7c:	f042                	sd	a6,32(sp)
    ac7e:	86a6                	mv	a3,s1
    ac80:	85ca                	mv	a1,s2
    ac82:	9402                	jalr	s0
    ac84:	68e2                	ld	a7,24(sp)
    ac86:	7a82                	ld	s5,32(sp)
    ac88:	4e85                	li	t4,1
    ac8a:	1d7d                	addi	s10,s10,-1
    ac8c:	fffd4503          	lbu	a0,-1(s10)
    ac90:	01da9463          	bne	s5,t4,ac98 <_vsnprintf+0x20c8>
    ac94:	6640206f          	j	d2f8 <_vsnprintf+0x4728>
    ac98:	4e09                	li	t3,2
    ac9a:	07ca8f63          	beq	s5,t3,ad18 <_vsnprintf+0x2148>
    ac9e:	460d                	li	a2,3
    aca0:	06ca8263          	beq	s5,a2,ad04 <_vsnprintf+0x2134>
    aca4:	4f91                	li	t6,4
    aca6:	05fa8563          	beq	s5,t6,acf0 <_vsnprintf+0x2120>
    acaa:	4715                	li	a4,5
    acac:	02ea8863          	beq	s5,a4,acdc <_vsnprintf+0x210c>
    acb0:	4699                	li	a3,6
    acb2:	00da8b63          	beq	s5,a3,acc8 <_vsnprintf+0x20f8>
    acb6:	41ac0633          	sub	a2,s8,s10
    acba:	86a6                	mv	a3,s1
    acbc:	85ca                	mv	a1,s2
    acbe:	9402                	jalr	s0
    acc0:	68e2                	ld	a7,24(sp)
    acc2:	ffed4503          	lbu	a0,-2(s10)
    acc6:	1d7d                	addi	s10,s10,-1
    acc8:	41ac0633          	sub	a2,s8,s10
    accc:	ec46                	sd	a7,24(sp)
    acce:	86a6                	mv	a3,s1
    acd0:	85ca                	mv	a1,s2
    acd2:	9402                	jalr	s0
    acd4:	68e2                	ld	a7,24(sp)
    acd6:	ffed4503          	lbu	a0,-2(s10)
    acda:	1d7d                	addi	s10,s10,-1
    acdc:	41ac0633          	sub	a2,s8,s10
    ace0:	ec46                	sd	a7,24(sp)
    ace2:	86a6                	mv	a3,s1
    ace4:	85ca                	mv	a1,s2
    ace6:	9402                	jalr	s0
    ace8:	68e2                	ld	a7,24(sp)
    acea:	ffed4503          	lbu	a0,-2(s10)
    acee:	1d7d                	addi	s10,s10,-1
    acf0:	41ac0633          	sub	a2,s8,s10
    acf4:	ec46                	sd	a7,24(sp)
    acf6:	86a6                	mv	a3,s1
    acf8:	85ca                	mv	a1,s2
    acfa:	9402                	jalr	s0
    acfc:	68e2                	ld	a7,24(sp)
    acfe:	ffed4503          	lbu	a0,-2(s10)
    ad02:	1d7d                	addi	s10,s10,-1
    ad04:	41ac0633          	sub	a2,s8,s10
    ad08:	ec46                	sd	a7,24(sp)
    ad0a:	86a6                	mv	a3,s1
    ad0c:	85ca                	mv	a1,s2
    ad0e:	9402                	jalr	s0
    ad10:	68e2                	ld	a7,24(sp)
    ad12:	ffed4503          	lbu	a0,-2(s10)
    ad16:	1d7d                	addi	s10,s10,-1
    ad18:	41ac0633          	sub	a2,s8,s10
    ad1c:	86a6                	mv	a3,s1
    ad1e:	85ca                	mv	a1,s2
    ad20:	ec46                	sd	a7,24(sp)
    ad22:	9402                	jalr	s0
    ad24:	1d7d                	addi	s10,s10,-1
    ad26:	f05a                	sd	s6,32(sp)
    ad28:	fffd4503          	lbu	a0,-1(s10)
    ad2c:	a895                	j	ada0 <_vsnprintf+0x21d0>
    ad2e:	8b6a                	mv	s6,s10
    ad30:	89eb450b          	th.lbuib	a0,(s6),-2,0
    ad34:	411c0633          	sub	a2,s8,a7
    ad38:	86a6                	mv	a3,s1
    ad3a:	85ca                	mv	a1,s2
    ad3c:	9402                	jalr	s0
    ad3e:	8aea                	mv	s5,s10
    ad40:	89dac50b          	th.lbuib	a0,(s5),-3,0
    ad44:	416c0633          	sub	a2,s8,s6
    ad48:	86a6                	mv	a3,s1
    ad4a:	85ca                	mv	a1,s2
    ad4c:	9402                	jalr	s0
    ad4e:	8b6a                	mv	s6,s10
    ad50:	89cb450b          	th.lbuib	a0,(s6),-4,0
    ad54:	415c0633          	sub	a2,s8,s5
    ad58:	86a6                	mv	a3,s1
    ad5a:	85ca                	mv	a1,s2
    ad5c:	9402                	jalr	s0
    ad5e:	8aea                	mv	s5,s10
    ad60:	89bac50b          	th.lbuib	a0,(s5),-5,0
    ad64:	416c0633          	sub	a2,s8,s6
    ad68:	86a6                	mv	a3,s1
    ad6a:	85ca                	mv	a1,s2
    ad6c:	9402                	jalr	s0
    ad6e:	8b6a                	mv	s6,s10
    ad70:	89ab450b          	th.lbuib	a0,(s6),-6,0
    ad74:	415c0633          	sub	a2,s8,s5
    ad78:	86a6                	mv	a3,s1
    ad7a:	85ca                	mv	a1,s2
    ad7c:	9402                	jalr	s0
    ad7e:	8aea                	mv	s5,s10
    ad80:	899ac50b          	th.lbuib	a0,(s5),-7,0
    ad84:	86a6                	mv	a3,s1
    ad86:	416c0633          	sub	a2,s8,s6
    ad8a:	85ca                	mv	a1,s2
    ad8c:	9402                	jalr	s0
    ad8e:	898d450b          	th.lbuib	a0,(s10),-8,0
    ad92:	86a6                	mv	a3,s1
    ad94:	415c0633          	sub	a2,s8,s5
    ad98:	85ca                	mv	a1,s2
    ad9a:	9402                	jalr	s0
    ad9c:	fffd4503          	lbu	a0,-1(s10)
    ada0:	86a6                	mv	a3,s1
    ada2:	41ac0633          	sub	a2,s8,s10
    ada6:	85ca                	mv	a1,s2
    ada8:	9402                	jalr	s0
    adaa:	fffd0893          	addi	a7,s10,-1
    adae:	f91b90e3          	bne	s7,a7,ad2e <_vsnprintf+0x215e>
    adb2:	68e2                	ld	a7,24(sp)
    adb4:	7b02                	ld	s6,32(sp)
    adb6:	8ae6                	mv	s5,s9
    adb8:	380b0ee3          	beqz	s6,b954 <_vsnprintf+0x2d84>
    adbc:	6b82                	ld	s7,0(sp)
    adbe:	7c08bc0b          	th.extu	s8,a7,31,0
    adc2:	417a8d33          	sub	s10,s5,s7
    adc6:	398d77e3          	bgeu	s10,s8,b954 <_vsnprintf+0x2d84>
    adca:	fffd4513          	not	a0,s10
    adce:	018507b3          	add	a5,a0,s8
    add2:	86a6                	mv	a3,s1
    add4:	8656                	mv	a2,s5
    add6:	85ca                	mv	a1,s2
    add8:	02000513          	li	a0,32
    addc:	e056                	sd	s5,0(sp)
    adde:	0077fb93          	andi	s7,a5,7
    ade2:	001d0c93          	addi	s9,s10,1
    ade6:	9402                	jalr	s0
    ade8:	6282                	ld	t0,0(sp)
    adea:	001a8b13          	addi	s6,s5,1
    adee:	eb8cf963          	bgeu	s9,s8,a4a0 <_vsnprintf+0x18d0>
    adf2:	0a0b8063          	beqz	s7,ae92 <_vsnprintf+0x22c2>
    adf6:	4585                	li	a1,1
    adf8:	08bb8363          	beq	s7,a1,ae7e <_vsnprintf+0x22ae>
    adfc:	4389                	li	t2,2
    adfe:	067b8863          	beq	s7,t2,ae6e <_vsnprintf+0x229e>
    ae02:	4f0d                	li	t5,3
    ae04:	05eb8d63          	beq	s7,t5,ae5e <_vsnprintf+0x228e>
    ae08:	4311                	li	t1,4
    ae0a:	046b8263          	beq	s7,t1,ae4e <_vsnprintf+0x227e>
    ae0e:	4815                	li	a6,5
    ae10:	030b8763          	beq	s7,a6,ae3e <_vsnprintf+0x226e>
    ae14:	4e99                	li	t4,6
    ae16:	01db8c63          	beq	s7,t4,ae2e <_vsnprintf+0x225e>
    ae1a:	865a                	mv	a2,s6
    ae1c:	86a6                	mv	a3,s1
    ae1e:	85ca                	mv	a1,s2
    ae20:	02000513          	li	a0,32
    ae24:	00228b13          	addi	s6,t0,2
    ae28:	002d0c93          	addi	s9,s10,2
    ae2c:	9402                	jalr	s0
    ae2e:	865a                	mv	a2,s6
    ae30:	86a6                	mv	a3,s1
    ae32:	85ca                	mv	a1,s2
    ae34:	02000513          	li	a0,32
    ae38:	0b05                	addi	s6,s6,1
    ae3a:	9402                	jalr	s0
    ae3c:	0c85                	addi	s9,s9,1
    ae3e:	865a                	mv	a2,s6
    ae40:	86a6                	mv	a3,s1
    ae42:	85ca                	mv	a1,s2
    ae44:	02000513          	li	a0,32
    ae48:	0b05                	addi	s6,s6,1
    ae4a:	9402                	jalr	s0
    ae4c:	0c85                	addi	s9,s9,1
    ae4e:	865a                	mv	a2,s6
    ae50:	86a6                	mv	a3,s1
    ae52:	85ca                	mv	a1,s2
    ae54:	02000513          	li	a0,32
    ae58:	0b05                	addi	s6,s6,1
    ae5a:	9402                	jalr	s0
    ae5c:	0c85                	addi	s9,s9,1
    ae5e:	865a                	mv	a2,s6
    ae60:	86a6                	mv	a3,s1
    ae62:	85ca                	mv	a1,s2
    ae64:	02000513          	li	a0,32
    ae68:	0b05                	addi	s6,s6,1
    ae6a:	9402                	jalr	s0
    ae6c:	0c85                	addi	s9,s9,1
    ae6e:	865a                	mv	a2,s6
    ae70:	86a6                	mv	a3,s1
    ae72:	85ca                	mv	a1,s2
    ae74:	02000513          	li	a0,32
    ae78:	0b05                	addi	s6,s6,1
    ae7a:	9402                	jalr	s0
    ae7c:	0c85                	addi	s9,s9,1
    ae7e:	865a                	mv	a2,s6
    ae80:	86a6                	mv	a3,s1
    ae82:	85ca                	mv	a1,s2
    ae84:	02000513          	li	a0,32
    ae88:	0c85                	addi	s9,s9,1
    ae8a:	0b05                	addi	s6,s6,1
    ae8c:	9402                	jalr	s0
    ae8e:	e18cf963          	bgeu	s9,s8,a4a0 <_vsnprintf+0x18d0>
    ae92:	865a                	mv	a2,s6
    ae94:	86a6                	mv	a3,s1
    ae96:	85ca                	mv	a1,s2
    ae98:	02000513          	li	a0,32
    ae9c:	9402                	jalr	s0
    ae9e:	001b0a93          	addi	s5,s6,1
    aea2:	8656                	mv	a2,s5
    aea4:	86a6                	mv	a3,s1
    aea6:	85ca                	mv	a1,s2
    aea8:	02000513          	li	a0,32
    aeac:	9402                	jalr	s0
    aeae:	002b0d13          	addi	s10,s6,2
    aeb2:	866a                	mv	a2,s10
    aeb4:	86a6                	mv	a3,s1
    aeb6:	85ca                	mv	a1,s2
    aeb8:	02000513          	li	a0,32
    aebc:	9402                	jalr	s0
    aebe:	003b0a93          	addi	s5,s6,3
    aec2:	8656                	mv	a2,s5
    aec4:	86a6                	mv	a3,s1
    aec6:	85ca                	mv	a1,s2
    aec8:	02000513          	li	a0,32
    aecc:	9402                	jalr	s0
    aece:	004b0b93          	addi	s7,s6,4
    aed2:	865e                	mv	a2,s7
    aed4:	86a6                	mv	a3,s1
    aed6:	85ca                	mv	a1,s2
    aed8:	02000513          	li	a0,32
    aedc:	9402                	jalr	s0
    aede:	005b0d13          	addi	s10,s6,5
    aee2:	86a6                	mv	a3,s1
    aee4:	866a                	mv	a2,s10
    aee6:	85ca                	mv	a1,s2
    aee8:	02000513          	li	a0,32
    aeec:	9402                	jalr	s0
    aeee:	006b0b93          	addi	s7,s6,6
    aef2:	86a6                	mv	a3,s1
    aef4:	865e                	mv	a2,s7
    aef6:	85ca                	mv	a1,s2
    aef8:	02000513          	li	a0,32
    aefc:	9402                	jalr	s0
    aefe:	007b0a93          	addi	s5,s6,7
    af02:	86a6                	mv	a3,s1
    af04:	8656                	mv	a2,s5
    af06:	85ca                	mv	a1,s2
    af08:	02000513          	li	a0,32
    af0c:	0ca1                	addi	s9,s9,8
    af0e:	0b21                	addi	s6,s6,8
    af10:	9402                	jalr	s0
    af12:	f98ce0e3          	bltu	s9,s8,ae92 <_vsnprintf+0x22c2>
    af16:	d8aff06f          	j	a4a0 <_vsnprintf+0x18d0>
    af1a:	0001                	nop
    af1c:	4f1e6863          	bltu	t3,a7,b40c <_vsnprintf+0x283c>
    af20:	002b7f93          	andi	t6,s6,2
    af24:	4a89                	li	s5,2
    af26:	4e0f8a63          	beqz	t6,b41a <_vsnprintf+0x284a>
    af2a:	000d9463          	bnez	s11,af32 <_vsnprintf+0x2362>
    af2e:	fb8fe06f          	j	96e6 <_vsnprintf+0xb16>
    af32:	f2068253          	fmv.d.x	ft4,a3
    af36:	1a1272d3          	fdiv.d	ft5,ft4,ft1
    af3a:	e20286d3          	fmv.x.d	a3,ft5
    af3e:	fa8fe06f          	j	96e6 <_vsnprintf+0xb16>
    af42:	00c5f393          	andi	t2,a1,12
    af46:	7c0c3f8b          	th.extu	t6,s8,31,0
    af4a:	00039463          	bnez	t2,af52 <_vsnprintf+0x2382>
    af4e:	0fa0206f          	j	d048 <_vsnprintf+0x4478>
    af52:	47bd                	li	a5,15
    af54:	8abe                	mv	s5,a5
    af56:	01f8e463          	bltu	a7,t6,af5e <_vsnprintf+0x238e>
    af5a:	0fa0206f          	j	d054 <_vsnprintf+0x4484>
    af5e:	02000e93          	li	t4,32
    af62:	41ae8f33          	sub	t5,t4,s10
    af66:	007f7893          	andi	a7,t5,7
    af6a:	01ab0733          	add	a4,s6,s10
    af6e:	03000313          	li	t1,48
    af72:	06088763          	beqz	a7,afe0 <_vsnprintf+0x2410>
    af76:	0d05                	addi	s10,s10,1
    af78:	1817530b          	th.sbia	t1,(a4),1,0
    af7c:	d7fd0163          	beq	s10,t6,a4de <_vsnprintf+0x190e>
    af80:	4505                	li	a0,1
    af82:	04a88f63          	beq	a7,a0,afe0 <_vsnprintf+0x2410>
    af86:	4c09                	li	s8,2
    af88:	05888763          	beq	a7,s8,afd6 <_vsnprintf+0x2406>
    af8c:	460d                	li	a2,3
    af8e:	02c88f63          	beq	a7,a2,afcc <_vsnprintf+0x23fc>
    af92:	4391                	li	t2,4
    af94:	02788763          	beq	a7,t2,afc2 <_vsnprintf+0x23f2>
    af98:	4815                	li	a6,5
    af9a:	01088f63          	beq	a7,a6,afb8 <_vsnprintf+0x23e8>
    af9e:	4299                	li	t0,6
    afa0:	00588763          	beq	a7,t0,afae <_vsnprintf+0x23de>
    afa4:	0d05                	addi	s10,s10,1
    afa6:	1817530b          	th.sbia	t1,(a4),1,0
    afaa:	d3fd0a63          	beq	s10,t6,a4de <_vsnprintf+0x190e>
    afae:	0d05                	addi	s10,s10,1
    afb0:	1817530b          	th.sbia	t1,(a4),1,0
    afb4:	d3fd0563          	beq	s10,t6,a4de <_vsnprintf+0x190e>
    afb8:	0d05                	addi	s10,s10,1
    afba:	1817530b          	th.sbia	t1,(a4),1,0
    afbe:	d3fd0063          	beq	s10,t6,a4de <_vsnprintf+0x190e>
    afc2:	0d05                	addi	s10,s10,1
    afc4:	1817530b          	th.sbia	t1,(a4),1,0
    afc8:	d1fd0b63          	beq	s10,t6,a4de <_vsnprintf+0x190e>
    afcc:	0d05                	addi	s10,s10,1
    afce:	1817530b          	th.sbia	t1,(a4),1,0
    afd2:	d1fd0663          	beq	s10,t6,a4de <_vsnprintf+0x190e>
    afd6:	0d05                	addi	s10,s10,1
    afd8:	1817530b          	th.sbia	t1,(a4),1,0
    afdc:	d1fd0163          	beq	s10,t6,a4de <_vsnprintf+0x190e>
    afe0:	01dd1463          	bne	s10,t4,afe8 <_vsnprintf+0x2418>
    afe4:	4520306f          	j	e436 <_vsnprintf+0x5866>
    afe8:	0d05                	addi	s10,s10,1
    afea:	00670023          	sb	t1,0(a4)
    afee:	86ea                	mv	a3,s10
    aff0:	cffd0763          	beq	s10,t6,a4de <_vsnprintf+0x190e>
    aff4:	0d05                	addi	s10,s10,1
    aff6:	006700a3          	sb	t1,1(a4)
    affa:	cffd0263          	beq	s10,t6,a4de <_vsnprintf+0x190e>
    affe:	00268d13          	addi	s10,a3,2
    b002:	00670123          	sb	t1,2(a4)
    b006:	cdfd0c63          	beq	s10,t6,a4de <_vsnprintf+0x190e>
    b00a:	00368d13          	addi	s10,a3,3
    b00e:	006701a3          	sb	t1,3(a4)
    b012:	cdfd0663          	beq	s10,t6,a4de <_vsnprintf+0x190e>
    b016:	00468d13          	addi	s10,a3,4
    b01a:	00670223          	sb	t1,4(a4)
    b01e:	cdfd0063          	beq	s10,t6,a4de <_vsnprintf+0x190e>
    b022:	00568d13          	addi	s10,a3,5
    b026:	006702a3          	sb	t1,5(a4)
    b02a:	cbfd0a63          	beq	s10,t6,a4de <_vsnprintf+0x190e>
    b02e:	00668d13          	addi	s10,a3,6
    b032:	00670323          	sb	t1,6(a4)
    b036:	cbfd0463          	beq	s10,t6,a4de <_vsnprintf+0x190e>
    b03a:	006703a3          	sb	t1,7(a4)
    b03e:	00768d13          	addi	s10,a3,7
    b042:	0721                	addi	a4,a4,8
    b044:	f9fd1ee3          	bne	s10,t6,afe0 <_vsnprintf+0x2410>
    b048:	c96ff06f          	j	a4de <_vsnprintf+0x190e>
    b04c:	47c1                	li	a5,16
    b04e:	86be                	mv	a3,a5
    b050:	db9fe06f          	j	9e08 <_vsnprintf+0x1238>
    b054:	988dce0b          	th.lbuia	t3,(s11),8,0
    b058:	83f2                	mv	t2,t3
    b05a:	b479                	j	aae8 <_vsnprintf+0x1f18>
    b05c:	00457813          	andi	a6,a0,4
    b060:	00081463          	bnez	a6,b068 <_vsnprintf+0x2498>
    b064:	04a0206f          	j	d0ae <_vsnprintf+0x44de>
    b068:	4b89                	li	s7,2
    b06a:	4ac1                	li	s5,16
    b06c:	03010b13          	addi	s6,sp,48
    b070:	00278c33          	add	s8,a5,sp
    b074:	02b00513          	li	a0,43
    b078:	00178d13          	addi	s10,a5,1
    b07c:	02ac0823          	sb	a0,48(s8)
    b080:	b0b1                	j	a8cc <_vsnprintf+0x1cfc>
    b082:	47bd                	li	a5,15
    b084:	8abe                	mv	s5,a5
    b086:	c50ff06f          	j	a4d6 <_vsnprintf+0x1906>
    b08a:	8817c70b          	th.lbuib	a4,(a5),1,0
    b08e:	c319                	beqz	a4,b094 <_vsnprintf+0x24c4>
    b090:	856fe06f          	j	90e6 <_vsnprintf+0x516>
    b094:	8d6fe06f          	j	916a <_vsnprintf+0x59a>
    b098:	080ff513          	andi	a0,t6,128
    b09c:	e119                	bnez	a0,b0a2 <_vsnprintf+0x24d2>
    b09e:	4920206f          	j	d530 <_vsnprintf+0x4960>
    b0a2:	b88dce8b          	th.lhuia	t4,(s11),8,0
    b0a6:	da5fe06f          	j	9e4a <_vsnprintf+0x127a>
    b0aa:	02000c13          	li	s8,32
    b0ae:	018d0463          	beq	s10,s8,b0b6 <_vsnprintf+0x24e6>
    b0b2:	6290306f          	j	eeda <_vsnprintf+0x630a>
    b0b6:	04f14503          	lbu	a0,79(sp)
    b0ba:	4b89                	li	s7,2
    b0bc:	4ac1                	li	s5,16
    b0be:	02000d13          	li	s10,32
    b0c2:	80bff06f          	j	a8cc <_vsnprintf+0x1cfc>
    b0c6:	886e                	mv	a6,s11
    b0c8:	78884e0b          	th.ldia	t3,(a6),8,0
    b0cc:	000e0463          	beqz	t3,b0d4 <_vsnprintf+0x2504>
    b0d0:	f3ffe06f          	j	a00e <_vsnprintf+0x143e>
    b0d4:	002afd93          	andi	s11,s5,2
    b0d8:	000d8463          	beqz	s11,b0e0 <_vsnprintf+0x2510>
    b0dc:	6500306f          	j	e72c <_vsnprintf+0x5b5c>
    b0e0:	7c0c3d0b          	th.extu	s10,s8,31,0
    b0e4:	4781                	li	a5,0
    b0e6:	03010313          	addi	t1,sp,48
    b0ea:	00089463          	bnez	a7,b0f2 <_vsnprintf+0x2522>
    b0ee:	6600306f          	j	e74e <_vsnprintf+0x5b7e>
    b0f2:	000d1463          	bnez	s10,b0fa <_vsnprintf+0x252a>
    b0f6:	6790306f          	j	ef6e <_vsnprintf+0x639e>
    b0fa:	02000513          	li	a0,32
    b0fe:	40f50f33          	sub	t5,a0,a5
    b102:	007f7a93          	andi	s5,t5,7
    b106:	00f30733          	add	a4,t1,a5
    b10a:	03000e93          	li	t4,48
    b10e:	060a8763          	beqz	s5,b17c <_vsnprintf+0x25ac>
    b112:	0785                	addi	a5,a5,1
    b114:	18175e8b          	th.sbia	t4,(a4),1,0
    b118:	0da7f663          	bgeu	a5,s10,b1e4 <_vsnprintf+0x2614>
    b11c:	4605                	li	a2,1
    b11e:	04ca8f63          	beq	s5,a2,b17c <_vsnprintf+0x25ac>
    b122:	4289                	li	t0,2
    b124:	045a8763          	beq	s5,t0,b172 <_vsnprintf+0x25a2>
    b128:	4c8d                	li	s9,3
    b12a:	039a8f63          	beq	s5,s9,b168 <_vsnprintf+0x2598>
    b12e:	4c11                	li	s8,4
    b130:	038a8763          	beq	s5,s8,b15e <_vsnprintf+0x258e>
    b134:	4b95                	li	s7,5
    b136:	017a8f63          	beq	s5,s7,b154 <_vsnprintf+0x2584>
    b13a:	4f99                	li	t6,6
    b13c:	01fa8763          	beq	s5,t6,b14a <_vsnprintf+0x257a>
    b140:	0785                	addi	a5,a5,1
    b142:	18175e8b          	th.sbia	t4,(a4),1,0
    b146:	09a7ff63          	bgeu	a5,s10,b1e4 <_vsnprintf+0x2614>
    b14a:	0785                	addi	a5,a5,1
    b14c:	18175e8b          	th.sbia	t4,(a4),1,0
    b150:	09a7fa63          	bgeu	a5,s10,b1e4 <_vsnprintf+0x2614>
    b154:	0785                	addi	a5,a5,1
    b156:	18175e8b          	th.sbia	t4,(a4),1,0
    b15a:	09a7f563          	bgeu	a5,s10,b1e4 <_vsnprintf+0x2614>
    b15e:	0785                	addi	a5,a5,1
    b160:	18175e8b          	th.sbia	t4,(a4),1,0
    b164:	09a7f063          	bgeu	a5,s10,b1e4 <_vsnprintf+0x2614>
    b168:	0785                	addi	a5,a5,1
    b16a:	18175e8b          	th.sbia	t4,(a4),1,0
    b16e:	07a7fb63          	bgeu	a5,s10,b1e4 <_vsnprintf+0x2614>
    b172:	0785                	addi	a5,a5,1
    b174:	18175e8b          	th.sbia	t4,(a4),1,0
    b178:	07a7f663          	bgeu	a5,s10,b1e4 <_vsnprintf+0x2614>
    b17c:	00a79463          	bne	a5,a0,b184 <_vsnprintf+0x25b4>
    b180:	3130206f          	j	dc92 <_vsnprintf+0x50c2>
    b184:	0785                	addi	a5,a5,1
    b186:	01d70023          	sb	t4,0(a4)
    b18a:	83be                	mv	t2,a5
    b18c:	05a7fc63          	bgeu	a5,s10,b1e4 <_vsnprintf+0x2614>
    b190:	0785                	addi	a5,a5,1
    b192:	01d700a3          	sb	t4,1(a4)
    b196:	05a7f763          	bgeu	a5,s10,b1e4 <_vsnprintf+0x2614>
    b19a:	00238793          	addi	a5,t2,2
    b19e:	01d70123          	sb	t4,2(a4)
    b1a2:	05a7f163          	bgeu	a5,s10,b1e4 <_vsnprintf+0x2614>
    b1a6:	00338793          	addi	a5,t2,3
    b1aa:	01d701a3          	sb	t4,3(a4)
    b1ae:	03a7fb63          	bgeu	a5,s10,b1e4 <_vsnprintf+0x2614>
    b1b2:	00438793          	addi	a5,t2,4
    b1b6:	01d70223          	sb	t4,4(a4)
    b1ba:	03a7f563          	bgeu	a5,s10,b1e4 <_vsnprintf+0x2614>
    b1be:	00538793          	addi	a5,t2,5
    b1c2:	01d702a3          	sb	t4,5(a4)
    b1c6:	01a7ff63          	bgeu	a5,s10,b1e4 <_vsnprintf+0x2614>
    b1ca:	00638793          	addi	a5,t2,6
    b1ce:	01d70323          	sb	t4,6(a4)
    b1d2:	01a7f963          	bgeu	a5,s10,b1e4 <_vsnprintf+0x2614>
    b1d6:	01d703a3          	sb	t4,7(a4)
    b1da:	00738793          	addi	a5,t2,7
    b1de:	0721                	addi	a4,a4,8
    b1e0:	f9a7eee3          	bltu	a5,s10,b17c <_vsnprintf+0x25ac>
    b1e4:	000d9463          	bnez	s11,b1ec <_vsnprintf+0x261c>
    b1e8:	6c60306f          	j	e8ae <_vsnprintf+0x5cde>
    b1ec:	7c08b68b          	th.extu	a3,a7,31,0
    b1f0:	00d7f463          	bgeu	a5,a3,b1f8 <_vsnprintf+0x2628>
    b1f4:	3b00206f          	j	d5a4 <_vsnprintf+0x49d4>
    b1f8:	86be                	mv	a3,a5
    b1fa:	00a79463          	bne	a5,a0,b202 <_vsnprintf+0x2632>
    b1fe:	2a10206f          	j	dc9e <_vsnprintf+0x50ce>
    b202:	000e4463          	bltz	t3,b20a <_vsnprintf+0x263a>
    b206:	5630306f          	j	ef68 <_vsnprintf+0x6398>
    b20a:	00268f33          	add	t5,a3,sp
    b20e:	02d00613          	li	a2,45
    b212:	02cf0823          	sb	a2,48(t5)
    b216:	0035f793          	andi	a5,a1,3
    b21a:	00168d13          	addi	s10,a3,1
    b21e:	c399                	beqz	a5,b224 <_vsnprintf+0x2654>
    b220:	53b0306f          	j	ef5a <_vsnprintf+0x638a>
    b224:	7c08bb8b          	th.extu	s7,a7,31,0
    b228:	8dc2                	mv	s11,a6
    b22a:	4b01                	li	s6,0
    b22c:	017d6463          	bltu	s10,s7,b234 <_vsnprintf+0x2664>
    b230:	5210306f          	j	ef50 <_vsnprintf+0x6380>
    b234:	6602                	ld	a2,0(sp)
    b236:	85ca                	mv	a1,s2
    b238:	ec46                	sd	a7,24(sp)
    b23a:	40cd0cb3          	sub	s9,s10,a2
    b23e:	fffcc313          	not	t1,s9
    b242:	40c30e33          	sub	t3,t1,a2
    b246:	86a6                	mv	a3,s1
    b248:	02000513          	li	a0,32
    b24c:	017e0ab3          	add	s5,t3,s7
    b250:	00160c13          	addi	s8,a2,1
    b254:	9402                	jalr	s0
    b256:	018c85b3          	add	a1,s9,s8
    b25a:	68e2                	ld	a7,24(sp)
    b25c:	007afa93          	andi	s5,s5,7
    b260:	1575f563          	bgeu	a1,s7,b3aa <_vsnprintf+0x27da>
    b264:	0a0a8863          	beqz	s5,b314 <_vsnprintf+0x2744>
    b268:	4685                	li	a3,1
    b26a:	08da8863          	beq	s5,a3,b2fa <_vsnprintf+0x272a>
    b26e:	4809                	li	a6,2
    b270:	070a8c63          	beq	s5,a6,b2e8 <_vsnprintf+0x2718>
    b274:	428d                	li	t0,3
    b276:	065a8063          	beq	s5,t0,b2d6 <_vsnprintf+0x2706>
    b27a:	4f91                	li	t6,4
    b27c:	05fa8463          	beq	s5,t6,b2c4 <_vsnprintf+0x26f4>
    b280:	4395                	li	t2,5
    b282:	027a8863          	beq	s5,t2,b2b2 <_vsnprintf+0x26e2>
    b286:	4719                	li	a4,6
    b288:	00ea8c63          	beq	s5,a4,b2a0 <_vsnprintf+0x26d0>
    b28c:	8662                	mv	a2,s8
    b28e:	ec46                	sd	a7,24(sp)
    b290:	86a6                	mv	a3,s1
    b292:	85ca                	mv	a1,s2
    b294:	02000513          	li	a0,32
    b298:	6c02                	ld	s8,0(sp)
    b29a:	9402                	jalr	s0
    b29c:	68e2                	ld	a7,24(sp)
    b29e:	0c09                	addi	s8,s8,2
    b2a0:	8662                	mv	a2,s8
    b2a2:	ec46                	sd	a7,24(sp)
    b2a4:	86a6                	mv	a3,s1
    b2a6:	85ca                	mv	a1,s2
    b2a8:	02000513          	li	a0,32
    b2ac:	9402                	jalr	s0
    b2ae:	68e2                	ld	a7,24(sp)
    b2b0:	0c05                	addi	s8,s8,1
    b2b2:	8662                	mv	a2,s8
    b2b4:	ec46                	sd	a7,24(sp)
    b2b6:	86a6                	mv	a3,s1
    b2b8:	85ca                	mv	a1,s2
    b2ba:	02000513          	li	a0,32
    b2be:	9402                	jalr	s0
    b2c0:	68e2                	ld	a7,24(sp)
    b2c2:	0c05                	addi	s8,s8,1
    b2c4:	8662                	mv	a2,s8
    b2c6:	ec46                	sd	a7,24(sp)
    b2c8:	86a6                	mv	a3,s1
    b2ca:	85ca                	mv	a1,s2
    b2cc:	02000513          	li	a0,32
    b2d0:	9402                	jalr	s0
    b2d2:	68e2                	ld	a7,24(sp)
    b2d4:	0c05                	addi	s8,s8,1
    b2d6:	8662                	mv	a2,s8
    b2d8:	ec46                	sd	a7,24(sp)
    b2da:	86a6                	mv	a3,s1
    b2dc:	85ca                	mv	a1,s2
    b2de:	02000513          	li	a0,32
    b2e2:	9402                	jalr	s0
    b2e4:	68e2                	ld	a7,24(sp)
    b2e6:	0c05                	addi	s8,s8,1
    b2e8:	8662                	mv	a2,s8
    b2ea:	ec46                	sd	a7,24(sp)
    b2ec:	86a6                	mv	a3,s1
    b2ee:	85ca                	mv	a1,s2
    b2f0:	02000513          	li	a0,32
    b2f4:	9402                	jalr	s0
    b2f6:	68e2                	ld	a7,24(sp)
    b2f8:	0c05                	addi	s8,s8,1
    b2fa:	8662                	mv	a2,s8
    b2fc:	02000513          	li	a0,32
    b300:	ec46                	sd	a7,24(sp)
    b302:	86a6                	mv	a3,s1
    b304:	85ca                	mv	a1,s2
    b306:	9402                	jalr	s0
    b308:	0c05                	addi	s8,s8,1
    b30a:	018c8533          	add	a0,s9,s8
    b30e:	68e2                	ld	a7,24(sp)
    b310:	09757d63          	bgeu	a0,s7,b3aa <_vsnprintf+0x27da>
    b314:	ec5a                	sd	s6,24(sp)
    b316:	f06e                	sd	s11,32(sp)
    b318:	8dea                	mv	s11,s10
    b31a:	8d46                	mv	s10,a7
    b31c:	8662                	mv	a2,s8
    b31e:	86a6                	mv	a3,s1
    b320:	85ca                	mv	a1,s2
    b322:	02000513          	li	a0,32
    b326:	9402                	jalr	s0
    b328:	001c0a93          	addi	s5,s8,1
    b32c:	8656                	mv	a2,s5
    b32e:	86a6                	mv	a3,s1
    b330:	85ca                	mv	a1,s2
    b332:	02000513          	li	a0,32
    b336:	9402                	jalr	s0
    b338:	002c0b13          	addi	s6,s8,2
    b33c:	865a                	mv	a2,s6
    b33e:	86a6                	mv	a3,s1
    b340:	85ca                	mv	a1,s2
    b342:	02000513          	li	a0,32
    b346:	9402                	jalr	s0
    b348:	003c0a93          	addi	s5,s8,3
    b34c:	8656                	mv	a2,s5
    b34e:	86a6                	mv	a3,s1
    b350:	85ca                	mv	a1,s2
    b352:	02000513          	li	a0,32
    b356:	9402                	jalr	s0
    b358:	004c0b13          	addi	s6,s8,4
    b35c:	865a                	mv	a2,s6
    b35e:	86a6                	mv	a3,s1
    b360:	85ca                	mv	a1,s2
    b362:	02000513          	li	a0,32
    b366:	9402                	jalr	s0
    b368:	005c0a93          	addi	s5,s8,5
    b36c:	8656                	mv	a2,s5
    b36e:	86a6                	mv	a3,s1
    b370:	85ca                	mv	a1,s2
    b372:	02000513          	li	a0,32
    b376:	9402                	jalr	s0
    b378:	006c0b13          	addi	s6,s8,6
    b37c:	86a6                	mv	a3,s1
    b37e:	865a                	mv	a2,s6
    b380:	85ca                	mv	a1,s2
    b382:	02000513          	li	a0,32
    b386:	9402                	jalr	s0
    b388:	007c0a93          	addi	s5,s8,7
    b38c:	86a6                	mv	a3,s1
    b38e:	8656                	mv	a2,s5
    b390:	85ca                	mv	a1,s2
    b392:	02000513          	li	a0,32
    b396:	0c21                	addi	s8,s8,8
    b398:	9402                	jalr	s0
    b39a:	018c88b3          	add	a7,s9,s8
    b39e:	f778efe3          	bltu	a7,s7,b31c <_vsnprintf+0x274c>
    b3a2:	88ea                	mv	a7,s10
    b3a4:	8d6e                	mv	s10,s11
    b3a6:	6b62                	ld	s6,24(sp)
    b3a8:	7d82                	ld	s11,32(sp)
    b3aa:	6302                	ld	t1,0(sp)
    b3ac:	fffb8e93          	addi	t4,s7,-1
    b3b0:	001d0793          	addi	a5,s10,1
    b3b4:	41ae8f33          	sub	t5,t4,s10
    b3b8:	00fbb633          	sltu	a2,s7,a5
    b3bc:	42c01f0b          	th.mvnez	t5,zero,a2
    b3c0:	00130e13          	addi	t3,t1,1
    b3c4:	01cf03b3          	add	t2,t5,t3
    b3c8:	8e1e                	mv	t3,t2
    b3ca:	000d1463          	bnez	s10,b3d2 <_vsnprintf+0x2802>
    b3ce:	f37fe06f          	j	a304 <_vsnprintf+0x1734>
    b3d2:	03010313          	addi	t1,sp,48
    b3d6:	006d06b3          	add	a3,s10,t1
    b3da:	fff6c503          	lbu	a0,-1(a3)
    b3de:	d97fe06f          	j	a174 <_vsnprintf+0x15a4>
    b3e2:	00678023          	sb	t1,0(a5)
    b3e6:	006780a3          	sb	t1,1(a5)
    b3ea:	00678123          	sb	t1,2(a5)
    b3ee:	006781a3          	sb	t1,3(a5)
    b3f2:	00678223          	sb	t1,4(a5)
    b3f6:	006782a3          	sb	t1,5(a5)
    b3fa:	00678323          	sb	t1,6(a5)
    b3fe:	006783a3          	sb	t1,7(a5)
    b402:	07a1                	addi	a5,a5,8
    b404:	fde79fe3          	bne	a5,t5,b3e2 <_vsnprintf+0x2812>
    b408:	cf4fe06f          	j	98fc <_vsnprintf+0xd2c>
    b40c:	002afe93          	andi	t4,s5,2
    b410:	4a89                	li	s5,2
    b412:	b00e9ce3          	bnez	t4,af2a <_vsnprintf+0x235a>
    b416:	41c887bb          	subw	a5,a7,t3
    b41a:	4a81                	li	s5,0
    b41c:	b639                	j	af2a <_vsnprintf+0x235a>
    b41e:	e032                	sd	a2,0(sp)
    b420:	a14ff06f          	j	a634 <_vsnprintf+0x1a64>
    b424:	060b8263          	beqz	s7,b488 <_vsnprintf+0x28b8>
    b428:	000c8463          	beqz	s9,b430 <_vsnprintf+0x2860>
    b42c:	10c0206f          	j	d538 <_vsnprintf+0x4968>
    b430:	fff78893          	addi	a7,a5,-1
    b434:	8d3e                	mv	s10,a5
    b436:	01fd1463          	bne	s10,t6,b43e <_vsnprintf+0x286e>
    b43a:	4f20306f          	j	e92c <_vsnprintf+0x5d5c>
    b43e:	00fd1463          	bne	s10,a5,b446 <_vsnprintf+0x2876>
    b442:	0170206f          	j	dc58 <_vsnprintf+0x5088>
    b446:	002d0633          	add	a2,s10,sp
    b44a:	05800393          	li	t2,88
    b44e:	001d0793          	addi	a5,s10,1
    b452:	02760823          	sb	t2,48(a2)
    b456:	4b81                	li	s7,0
    b458:	00178d13          	addi	s10,a5,1
    b45c:	00278833          	add	a6,a5,sp
    b460:	03000c93          	li	s9,48
    b464:	03980823          	sb	s9,48(a6)
    b468:	02000f93          	li	t6,32
    b46c:	c5fd0c63          	beq	s10,t6,a8c4 <_vsnprintf+0x1cf4>
    b470:	0045f513          	andi	a0,a1,4
    b474:	c119                	beqz	a0,b47a <_vsnprintf+0x28aa>
    b476:	0090206f          	j	dc7e <_vsnprintf+0x50ae>
    b47a:	0085f313          	andi	t1,a1,8
    b47e:	02030c63          	beqz	t1,b4b6 <_vsnprintf+0x28e6>
    b482:	87ea                	mv	a5,s10
    b484:	a829                	j	b49e <_vsnprintf+0x28ce>
    b486:	0001                	nop
    b488:	0045fb93          	andi	s7,a1,4
    b48c:	000b8463          	beqz	s7,b494 <_vsnprintf+0x28c4>
    b490:	27c0206f          	j	d70c <_vsnprintf+0x4b3c>
    b494:	0085fc93          	andi	s9,a1,8
    b498:	000c8d63          	beqz	s9,b4b2 <_vsnprintf+0x28e2>
    b49c:	4b81                	li	s7,0
    b49e:	00278e33          	add	t3,a5,sp
    b4a2:	02000513          	li	a0,32
    b4a6:	00178d13          	addi	s10,a5,1
    b4aa:	02ae0823          	sb	a0,48(t3)
    b4ae:	c1eff06f          	j	a8cc <_vsnprintf+0x1cfc>
    b4b2:	8d3e                	mv	s10,a5
    b4b4:	4b81                	li	s7,0
    b4b6:	020d0813          	addi	a6,s10,32
    b4ba:	03010c93          	addi	s9,sp,48
    b4be:	01980fb3          	add	t6,a6,s9
    b4c2:	fdffc503          	lbu	a0,-33(t6)
    b4c6:	c06ff06f          	j	a8cc <_vsnprintf+0x1cfc>
    b4ca:	87c6                	mv	a5,a7
    b4cc:	8b6a                	mv	s6,s10
    b4ce:	4d81                	li	s11,0
    b4d0:	4e01                	li	t3,0
    b4d2:	f2068553          	fmv.d.x	fa0,a3
    b4d6:	22a515d3          	fneg.d	fa1,fa0
    b4da:	e20586d3          	fmv.x.d	a3,fa1
    b4de:	a18fe06f          	j	96f6 <_vsnprintf+0xb26>
    b4e2:	8aee                	mv	s5,s11
    b4e4:	788acd8b          	th.ldia	s11,(s5),8,0
    b4e8:	010ffd13          	andi	s10,t6,16
    b4ec:	000d9963          	bnez	s11,b4fe <_vsnprintf+0x292e>
    b4f0:	fefffe13          	andi	t3,t6,-17
    b4f4:	000e061b          	sext.w	a2,t3
    b4f8:	040b92e3          	bnez	s7,bd3c <_vsnprintf+0x316c>
    b4fc:	4d01                	li	s10,0
    b4fe:	1456328b          	th.extu	t0,a2,5,5
    b502:	fff28f93          	addi	t6,t0,-1
    b506:	020fff13          	andi	t5,t6,32
    b50a:	037f051b          	addiw	a0,t5,55
    b50e:	02fddf33          	divu	t5,s11,a5
    b512:	876e                	mv	a4,s11
    b514:	43a5                	li	t2,9
    b516:	03010813          	addi	a6,sp,48
    b51a:	85c2                	mv	a1,a6
    b51c:	22ff170b          	th.muls	a4,t5,a5
    b520:	0ff77e93          	zext.b	t4,a4
    b524:	030e831b          	addiw	t1,t4,48
    b528:	01d50cbb          	addw	s9,a0,t4
    b52c:	0ff37b13          	zext.b	s6,t1
    b530:	0ffcfe13          	zext.b	t3,s9
    b534:	00e3b2b3          	sltu	t0,t2,a4
    b538:	405b1e0b          	th.mveqz	t3,s6,t0
    b53c:	03c10823          	sb	t3,48(sp)
    b540:	64fdeb63          	bltu	s11,a5,bb96 <_vsnprintf+0x2fc6>
    b544:	03110593          	addi	a1,sp,49
    b548:	02ff5db3          	divu	s11,t5,a5
    b54c:	8efa                	mv	t4,t5
    b54e:	22fd9e8b          	th.muls	t4,s11,a5
    b552:	0ffef713          	zext.b	a4,t4
    b556:	03070f9b          	addiw	t6,a4,48
    b55a:	00e5033b          	addw	t1,a0,a4
    b55e:	0ffffb13          	zext.b	s6,t6
    b562:	0ff37c93          	zext.b	s9,t1
    b566:	01d3be33          	sltu	t3,t2,t4
    b56a:	41cb1c8b          	th.mveqz	s9,s6,t3
    b56e:	01958023          	sb	s9,0(a1)
    b572:	62ff6263          	bltu	t5,a5,bb96 <_vsnprintf+0x2fc6>
    b576:	00158b13          	addi	s6,a1,1
    b57a:	05010f13          	addi	t5,sp,80
    b57e:	616f0c63          	beq	t5,s6,bb96 <_vsnprintf+0x2fc6>
    b582:	02fdd333          	divu	t1,s11,a5
    b586:	8eee                	mv	t4,s11
    b588:	85da                	mv	a1,s6
    b58a:	22f31e8b          	th.muls	t4,t1,a5
    b58e:	0ffef713          	zext.b	a4,t4
    b592:	0307029b          	addiw	t0,a4,48
    b596:	00e50fbb          	addw	t6,a0,a4
    b59a:	0ff2fc93          	zext.b	s9,t0
    b59e:	0ffffe13          	zext.b	t3,t6
    b5a2:	01d3bf33          	sltu	t5,t2,t4
    b5a6:	41ec9e0b          	th.mveqz	t3,s9,t5
    b5aa:	01cb0023          	sb	t3,0(s6)
    b5ae:	5efde463          	bltu	s11,a5,bb96 <_vsnprintf+0x2fc6>
    b5b2:	02f35db3          	divu	s11,t1,a5
    b5b6:	8e9a                	mv	t4,t1
    b5b8:	22fd9e8b          	th.muls	t4,s11,a5
    b5bc:	0ffef713          	zext.b	a4,t4
    b5c0:	0307029b          	addiw	t0,a4,48
    b5c4:	00e50fbb          	addw	t6,a0,a4
    b5c8:	0ff2fc93          	zext.b	s9,t0
    b5cc:	0ffffe13          	zext.b	t3,t6
    b5d0:	01d3bf33          	sltu	t5,t2,t4
    b5d4:	41ec9e0b          	th.mveqz	t3,s9,t5
    b5d8:	0815de0b          	th.sbib	t3,(a1),1,0
    b5dc:	5af36d63          	bltu	t1,a5,bb96 <_vsnprintf+0x2fc6>
    b5e0:	02fdd333          	divu	t1,s11,a5
    b5e4:	8eee                	mv	t4,s11
    b5e6:	002b0593          	addi	a1,s6,2
    b5ea:	22f31e8b          	th.muls	t4,t1,a5
    b5ee:	0ffef713          	zext.b	a4,t4
    b5f2:	0307029b          	addiw	t0,a4,48
    b5f6:	00e50fbb          	addw	t6,a0,a4
    b5fa:	0ff2fc93          	zext.b	s9,t0
    b5fe:	0ffffe13          	zext.b	t3,t6
    b602:	01d3bf33          	sltu	t5,t2,t4
    b606:	41ec9e0b          	th.mveqz	t3,s9,t5
    b60a:	01cb0123          	sb	t3,2(s6)
    b60e:	58fde463          	bltu	s11,a5,bb96 <_vsnprintf+0x2fc6>
    b612:	02f35db3          	divu	s11,t1,a5
    b616:	8e9a                	mv	t4,t1
    b618:	003b0593          	addi	a1,s6,3
    b61c:	22fd9e8b          	th.muls	t4,s11,a5
    b620:	0ffef713          	zext.b	a4,t4
    b624:	0307029b          	addiw	t0,a4,48
    b628:	00e50fbb          	addw	t6,a0,a4
    b62c:	0ff2fc93          	zext.b	s9,t0
    b630:	0ffffe13          	zext.b	t3,t6
    b634:	01d3bf33          	sltu	t5,t2,t4
    b638:	41ec9e0b          	th.mveqz	t3,s9,t5
    b63c:	01cb01a3          	sb	t3,3(s6)
    b640:	54f36b63          	bltu	t1,a5,bb96 <_vsnprintf+0x2fc6>
    b644:	004b0593          	addi	a1,s6,4
    b648:	8f6e                	mv	t5,s11
    b64a:	bdfd                	j	b548 <_vsnprintf+0x2978>
    b64c:	410607b3          	sub	a5,a2,a6
    b650:	002e7c93          	andi	s9,t3,2
    b654:	00178713          	addi	a4,a5,1
    b658:	8672                	mv	a2,t3
    b65a:	000c9463          	bnez	s9,b662 <_vsnprintf+0x2a92>
    b65e:	7d20106f          	j	ce30 <_vsnprintf+0x4260>
    b662:	000e8463          	beqz	t4,b66a <_vsnprintf+0x2a9a>
    b666:	30e0206f          	j	d974 <_vsnprintf+0x4da4>
    b66a:	02000e13          	li	t3,32
    b66e:	4d09                	li	s10,2
    b670:	01c70463          	beq	a4,t3,b678 <_vsnprintf+0x2aa8>
    b674:	7510206f          	j	e5c4 <_vsnprintf+0x59f4>
    b678:	6e02                	ld	t3,0(sp)
    b67a:	02000713          	li	a4,32
    b67e:	01c70bb3          	add	s7,a4,t3
    b682:	00e80c33          	add	s8,a6,a4
    b686:	8b1d                	andi	a4,a4,7
    b688:	01780b33          	add	s6,a6,s7
    b68c:	c761                	beqz	a4,b754 <_vsnprintf+0x2b84>
    b68e:	4505                	li	a0,1
    b690:	0aa70363          	beq	a4,a0,b736 <_vsnprintf+0x2b66>
    b694:	4309                	li	t1,2
    b696:	08670563          	beq	a4,t1,b720 <_vsnprintf+0x2b50>
    b69a:	428d                	li	t0,3
    b69c:	06570763          	beq	a4,t0,b70a <_vsnprintf+0x2b3a>
    b6a0:	4391                	li	t2,4
    b6a2:	04770963          	beq	a4,t2,b6f4 <_vsnprintf+0x2b24>
    b6a6:	4f15                	li	t5,5
    b6a8:	03e70b63          	beq	a4,t5,b6de <_vsnprintf+0x2b0e>
    b6ac:	4699                	li	a3,6
    b6ae:	00d70d63          	beq	a4,a3,b6c8 <_vsnprintf+0x2af8>
    b6b2:	418b0633          	sub	a2,s6,s8
    b6b6:	89fc450b          	th.lbuib	a0,(s8),-1,0
    b6ba:	ec46                	sd	a7,24(sp)
    b6bc:	f042                	sd	a6,32(sp)
    b6be:	86a6                	mv	a3,s1
    b6c0:	85ca                	mv	a1,s2
    b6c2:	9402                	jalr	s0
    b6c4:	68e2                	ld	a7,24(sp)
    b6c6:	7802                	ld	a6,32(sp)
    b6c8:	418b0633          	sub	a2,s6,s8
    b6cc:	89fc450b          	th.lbuib	a0,(s8),-1,0
    b6d0:	ec46                	sd	a7,24(sp)
    b6d2:	f042                	sd	a6,32(sp)
    b6d4:	86a6                	mv	a3,s1
    b6d6:	85ca                	mv	a1,s2
    b6d8:	9402                	jalr	s0
    b6da:	68e2                	ld	a7,24(sp)
    b6dc:	7802                	ld	a6,32(sp)
    b6de:	418b0633          	sub	a2,s6,s8
    b6e2:	89fc450b          	th.lbuib	a0,(s8),-1,0
    b6e6:	ec46                	sd	a7,24(sp)
    b6e8:	f042                	sd	a6,32(sp)
    b6ea:	86a6                	mv	a3,s1
    b6ec:	85ca                	mv	a1,s2
    b6ee:	9402                	jalr	s0
    b6f0:	68e2                	ld	a7,24(sp)
    b6f2:	7802                	ld	a6,32(sp)
    b6f4:	418b0633          	sub	a2,s6,s8
    b6f8:	89fc450b          	th.lbuib	a0,(s8),-1,0
    b6fc:	ec46                	sd	a7,24(sp)
    b6fe:	f042                	sd	a6,32(sp)
    b700:	86a6                	mv	a3,s1
    b702:	85ca                	mv	a1,s2
    b704:	9402                	jalr	s0
    b706:	68e2                	ld	a7,24(sp)
    b708:	7802                	ld	a6,32(sp)
    b70a:	418b0633          	sub	a2,s6,s8
    b70e:	89fc450b          	th.lbuib	a0,(s8),-1,0
    b712:	ec46                	sd	a7,24(sp)
    b714:	f042                	sd	a6,32(sp)
    b716:	86a6                	mv	a3,s1
    b718:	85ca                	mv	a1,s2
    b71a:	9402                	jalr	s0
    b71c:	68e2                	ld	a7,24(sp)
    b71e:	7802                	ld	a6,32(sp)
    b720:	418b0633          	sub	a2,s6,s8
    b724:	89fc450b          	th.lbuib	a0,(s8),-1,0
    b728:	ec46                	sd	a7,24(sp)
    b72a:	f042                	sd	a6,32(sp)
    b72c:	86a6                	mv	a3,s1
    b72e:	85ca                	mv	a1,s2
    b730:	9402                	jalr	s0
    b732:	68e2                	ld	a7,24(sp)
    b734:	7802                	ld	a6,32(sp)
    b736:	418b0633          	sub	a2,s6,s8
    b73a:	89fc450b          	th.lbuib	a0,(s8),-1,0
    b73e:	fd01588b          	th.sdd	a7,a6,(sp),2,4
    b742:	86a6                	mv	a3,s1
    b744:	85ca                	mv	a1,s2
    b746:	ec5e                	sd	s7,24(sp)
    b748:	9402                	jalr	s0
    b74a:	fd01488b          	th.ldd	a7,a6,(sp),2,4
    b74e:	6e62                	ld	t3,24(sp)
    b750:	09880963          	beq	a6,s8,b7e2 <_vsnprintf+0x2c12>
    b754:	ec6a                	sd	s10,24(sp)
    b756:	f046                	sd	a7,32(sp)
    b758:	8d42                	mv	s10,a6
    b75a:	8ae2                	mv	s5,s8
    b75c:	89fac50b          	th.lbuib	a0,(s5),-1,0
    b760:	418b0633          	sub	a2,s6,s8
    b764:	86a6                	mv	a3,s1
    b766:	85ca                	mv	a1,s2
    b768:	9402                	jalr	s0
    b76a:	8ce2                	mv	s9,s8
    b76c:	89ecc50b          	th.lbuib	a0,(s9),-2,0
    b770:	415b0633          	sub	a2,s6,s5
    b774:	86a6                	mv	a3,s1
    b776:	85ca                	mv	a1,s2
    b778:	9402                	jalr	s0
    b77a:	8ae2                	mv	s5,s8
    b77c:	89dac50b          	th.lbuib	a0,(s5),-3,0
    b780:	419b0633          	sub	a2,s6,s9
    b784:	86a6                	mv	a3,s1
    b786:	85ca                	mv	a1,s2
    b788:	9402                	jalr	s0
    b78a:	8ce2                	mv	s9,s8
    b78c:	89ccc50b          	th.lbuib	a0,(s9),-4,0
    b790:	415b0633          	sub	a2,s6,s5
    b794:	86a6                	mv	a3,s1
    b796:	85ca                	mv	a1,s2
    b798:	9402                	jalr	s0
    b79a:	8ae2                	mv	s5,s8
    b79c:	89bac50b          	th.lbuib	a0,(s5),-5,0
    b7a0:	419b0633          	sub	a2,s6,s9
    b7a4:	86a6                	mv	a3,s1
    b7a6:	85ca                	mv	a1,s2
    b7a8:	9402                	jalr	s0
    b7aa:	8ce2                	mv	s9,s8
    b7ac:	89acc50b          	th.lbuib	a0,(s9),-6,0
    b7b0:	415b0633          	sub	a2,s6,s5
    b7b4:	86a6                	mv	a3,s1
    b7b6:	85ca                	mv	a1,s2
    b7b8:	9402                	jalr	s0
    b7ba:	8ae2                	mv	s5,s8
    b7bc:	899ac50b          	th.lbuib	a0,(s5),-7,0
    b7c0:	86a6                	mv	a3,s1
    b7c2:	419b0633          	sub	a2,s6,s9
    b7c6:	85ca                	mv	a1,s2
    b7c8:	9402                	jalr	s0
    b7ca:	898c450b          	th.lbuib	a0,(s8),-8,0
    b7ce:	86a6                	mv	a3,s1
    b7d0:	415b0633          	sub	a2,s6,s5
    b7d4:	85ca                	mv	a1,s2
    b7d6:	9402                	jalr	s0
    b7d8:	f98d11e3          	bne	s10,s8,b75a <_vsnprintf+0x2b8a>
    b7dc:	6d62                	ld	s10,24(sp)
    b7de:	7882                	ld	a7,32(sp)
    b7e0:	8e5e                	mv	t3,s7
    b7e2:	000d1463          	bnez	s10,b7ea <_vsnprintf+0x2c1a>
    b7e6:	ca7fe06f          	j	a48c <_vsnprintf+0x18bc>
    b7ea:	7c08bc0b          	th.extu	s8,a7,31,0
    b7ee:	6882                	ld	a7,0(sp)
    b7f0:	411e0ab3          	sub	s5,t3,a7
    b7f4:	018ae463          	bltu	s5,s8,b7fc <_vsnprintf+0x2c2c>
    b7f8:	c95fe06f          	j	a48c <_vsnprintf+0x18bc>
    b7fc:	fffac593          	not	a1,s5
    b800:	01858633          	add	a2,a1,s8
    b804:	00767b93          	andi	s7,a2,7
    b808:	86a6                	mv	a3,s1
    b80a:	8672                	mv	a2,t3
    b80c:	85ca                	mv	a1,s2
    b80e:	02000513          	li	a0,32
    b812:	e072                	sd	t3,0(sp)
    b814:	001e0b13          	addi	s6,t3,1
    b818:	001a8d13          	addi	s10,s5,1
    b81c:	9402                	jalr	s0
    b81e:	6782                	ld	a5,0(sp)
    b820:	018d6463          	bltu	s10,s8,b828 <_vsnprintf+0x2c58>
    b824:	c7dfe06f          	j	a4a0 <_vsnprintf+0x18d0>
    b828:	0a0b8263          	beqz	s7,b8cc <_vsnprintf+0x2cfc>
    b82c:	4e85                	li	t4,1
    b82e:	09db8363          	beq	s7,t4,b8b4 <_vsnprintf+0x2ce4>
    b832:	4709                	li	a4,2
    b834:	06eb8863          	beq	s7,a4,b8a4 <_vsnprintf+0x2cd4>
    b838:	450d                	li	a0,3
    b83a:	04ab8d63          	beq	s7,a0,b894 <_vsnprintf+0x2cc4>
    b83e:	4311                	li	t1,4
    b840:	046b8263          	beq	s7,t1,b884 <_vsnprintf+0x2cb4>
    b844:	4295                	li	t0,5
    b846:	025b8763          	beq	s7,t0,b874 <_vsnprintf+0x2ca4>
    b84a:	4399                	li	t2,6
    b84c:	007b8c63          	beq	s7,t2,b864 <_vsnprintf+0x2c94>
    b850:	865a                	mv	a2,s6
    b852:	86a6                	mv	a3,s1
    b854:	85ca                	mv	a1,s2
    b856:	02000513          	li	a0,32
    b85a:	00278b13          	addi	s6,a5,2
    b85e:	002a8d13          	addi	s10,s5,2
    b862:	9402                	jalr	s0
    b864:	865a                	mv	a2,s6
    b866:	86a6                	mv	a3,s1
    b868:	85ca                	mv	a1,s2
    b86a:	02000513          	li	a0,32
    b86e:	0b05                	addi	s6,s6,1
    b870:	9402                	jalr	s0
    b872:	0d05                	addi	s10,s10,1
    b874:	865a                	mv	a2,s6
    b876:	86a6                	mv	a3,s1
    b878:	85ca                	mv	a1,s2
    b87a:	02000513          	li	a0,32
    b87e:	0b05                	addi	s6,s6,1
    b880:	9402                	jalr	s0
    b882:	0d05                	addi	s10,s10,1
    b884:	865a                	mv	a2,s6
    b886:	86a6                	mv	a3,s1
    b888:	85ca                	mv	a1,s2
    b88a:	02000513          	li	a0,32
    b88e:	0b05                	addi	s6,s6,1
    b890:	9402                	jalr	s0
    b892:	0d05                	addi	s10,s10,1
    b894:	865a                	mv	a2,s6
    b896:	86a6                	mv	a3,s1
    b898:	85ca                	mv	a1,s2
    b89a:	02000513          	li	a0,32
    b89e:	0b05                	addi	s6,s6,1
    b8a0:	9402                	jalr	s0
    b8a2:	0d05                	addi	s10,s10,1
    b8a4:	865a                	mv	a2,s6
    b8a6:	86a6                	mv	a3,s1
    b8a8:	85ca                	mv	a1,s2
    b8aa:	02000513          	li	a0,32
    b8ae:	0b05                	addi	s6,s6,1
    b8b0:	9402                	jalr	s0
    b8b2:	0d05                	addi	s10,s10,1
    b8b4:	865a                	mv	a2,s6
    b8b6:	86a6                	mv	a3,s1
    b8b8:	85ca                	mv	a1,s2
    b8ba:	02000513          	li	a0,32
    b8be:	0d05                	addi	s10,s10,1
    b8c0:	0b05                	addi	s6,s6,1
    b8c2:	9402                	jalr	s0
    b8c4:	018d6463          	bltu	s10,s8,b8cc <_vsnprintf+0x2cfc>
    b8c8:	bd9fe06f          	j	a4a0 <_vsnprintf+0x18d0>
    b8cc:	865a                	mv	a2,s6
    b8ce:	86a6                	mv	a3,s1
    b8d0:	85ca                	mv	a1,s2
    b8d2:	02000513          	li	a0,32
    b8d6:	9402                	jalr	s0
    b8d8:	001b0c93          	addi	s9,s6,1
    b8dc:	8666                	mv	a2,s9
    b8de:	86a6                	mv	a3,s1
    b8e0:	85ca                	mv	a1,s2
    b8e2:	02000513          	li	a0,32
    b8e6:	9402                	jalr	s0
    b8e8:	002b0b93          	addi	s7,s6,2
    b8ec:	865e                	mv	a2,s7
    b8ee:	86a6                	mv	a3,s1
    b8f0:	85ca                	mv	a1,s2
    b8f2:	02000513          	li	a0,32
    b8f6:	9402                	jalr	s0
    b8f8:	003b0a93          	addi	s5,s6,3
    b8fc:	8656                	mv	a2,s5
    b8fe:	86a6                	mv	a3,s1
    b900:	85ca                	mv	a1,s2
    b902:	02000513          	li	a0,32
    b906:	9402                	jalr	s0
    b908:	004b0c93          	addi	s9,s6,4
    b90c:	8666                	mv	a2,s9
    b90e:	86a6                	mv	a3,s1
    b910:	85ca                	mv	a1,s2
    b912:	02000513          	li	a0,32
    b916:	9402                	jalr	s0
    b918:	005b0a93          	addi	s5,s6,5
    b91c:	86a6                	mv	a3,s1
    b91e:	8656                	mv	a2,s5
    b920:	85ca                	mv	a1,s2
    b922:	02000513          	li	a0,32
    b926:	9402                	jalr	s0
    b928:	006b0b93          	addi	s7,s6,6
    b92c:	86a6                	mv	a3,s1
    b92e:	865e                	mv	a2,s7
    b930:	85ca                	mv	a1,s2
    b932:	02000513          	li	a0,32
    b936:	9402                	jalr	s0
    b938:	007b0c93          	addi	s9,s6,7
    b93c:	86a6                	mv	a3,s1
    b93e:	8666                	mv	a2,s9
    b940:	85ca                	mv	a1,s2
    b942:	02000513          	li	a0,32
    b946:	0d21                	addi	s10,s10,8
    b948:	0b21                	addi	s6,s6,8
    b94a:	9402                	jalr	s0
    b94c:	f98d60e3          	bltu	s10,s8,b8cc <_vsnprintf+0x2cfc>
    b950:	b51fe06f          	j	a4a0 <_vsnprintf+0x18d0>
    b954:	e056                	sd	s5,0(sp)
    b956:	b53fe06f          	j	a4a8 <_vsnprintf+0x18d8>
    b95a:	000c8463          	beqz	s9,b962 <_vsnprintf+0x2d92>
    b95e:	7620106f          	j	d0c0 <_vsnprintf+0x44f0>
    b962:	47c1                	li	a5,16
    b964:	48bd                	li	a7,15
    b966:	8d3e                	mv	s10,a5
    b968:	b4f9                	j	b436 <_vsnprintf+0x2866>
    b96a:	40000a93          	li	s5,1024
    b96e:	011be463          	bltu	s7,a7,b976 <_vsnprintf+0x2da6>
    b972:	0950206f          	j	e206 <_vsnprintf+0x5636>
    b976:	6e82                	ld	t4,0(sp)
    b978:	fff8851b          	addiw	a0,a7,-1
    b97c:	41750bbb          	subw	s7,a0,s7
    b980:	7c0bbe0b          	th.extu	t3,s7,31,0
    b984:	001e8b13          	addi	s6,t4,1
    b988:	007e7c93          	andi	s9,t3,7
    b98c:	016e07b3          	add	a5,t3,s6
    b990:	000c9463          	bnez	s9,b998 <_vsnprintf+0x2dc8>
    b994:	6e00106f          	j	d074 <_vsnprintf+0x44a4>
    b998:	6602                	ld	a2,0(sp)
    b99a:	ec46                	sd	a7,24(sp)
    b99c:	f03e                	sd	a5,32(sp)
    b99e:	e05a                	sd	s6,0(sp)
    b9a0:	86a6                	mv	a3,s1
    b9a2:	85ca                	mv	a1,s2
    b9a4:	02000513          	li	a0,32
    b9a8:	9402                	jalr	s0
    b9aa:	4285                	li	t0,1
    b9ac:	68e2                	ld	a7,24(sp)
    b9ae:	7782                	ld	a5,32(sp)
    b9b0:	865a                	mv	a2,s6
    b9b2:	0b05                	addi	s6,s6,1
    b9b4:	005c9463          	bne	s9,t0,b9bc <_vsnprintf+0x2dec>
    b9b8:	6bc0106f          	j	d074 <_vsnprintf+0x44a4>
    b9bc:	4689                	li	a3,2
    b9be:	08dc8763          	beq	s9,a3,ba4c <_vsnprintf+0x2e7c>
    b9c2:	430d                	li	t1,3
    b9c4:	066c8863          	beq	s9,t1,ba34 <_vsnprintf+0x2e64>
    b9c8:	4391                	li	t2,4
    b9ca:	047c8963          	beq	s9,t2,ba1c <_vsnprintf+0x2e4c>
    b9ce:	4f15                	li	t5,5
    b9d0:	03ec8a63          	beq	s9,t5,ba04 <_vsnprintf+0x2e34>
    b9d4:	4599                	li	a1,6
    b9d6:	00bc8b63          	beq	s9,a1,b9ec <_vsnprintf+0x2e1c>
    b9da:	e05a                	sd	s6,0(sp)
    b9dc:	86a6                	mv	a3,s1
    b9de:	85ca                	mv	a1,s2
    b9e0:	02000513          	li	a0,32
    b9e4:	9402                	jalr	s0
    b9e6:	68e2                	ld	a7,24(sp)
    b9e8:	7782                	ld	a5,32(sp)
    b9ea:	0b05                	addi	s6,s6,1
    b9ec:	6602                	ld	a2,0(sp)
    b9ee:	ec46                	sd	a7,24(sp)
    b9f0:	f03e                	sd	a5,32(sp)
    b9f2:	e05a                	sd	s6,0(sp)
    b9f4:	86a6                	mv	a3,s1
    b9f6:	85ca                	mv	a1,s2
    b9f8:	02000513          	li	a0,32
    b9fc:	9402                	jalr	s0
    b9fe:	68e2                	ld	a7,24(sp)
    ba00:	7782                	ld	a5,32(sp)
    ba02:	0b05                	addi	s6,s6,1
    ba04:	6602                	ld	a2,0(sp)
    ba06:	ec46                	sd	a7,24(sp)
    ba08:	f03e                	sd	a5,32(sp)
    ba0a:	e05a                	sd	s6,0(sp)
    ba0c:	86a6                	mv	a3,s1
    ba0e:	85ca                	mv	a1,s2
    ba10:	02000513          	li	a0,32
    ba14:	9402                	jalr	s0
    ba16:	68e2                	ld	a7,24(sp)
    ba18:	7782                	ld	a5,32(sp)
    ba1a:	0b05                	addi	s6,s6,1
    ba1c:	6602                	ld	a2,0(sp)
    ba1e:	ec46                	sd	a7,24(sp)
    ba20:	f03e                	sd	a5,32(sp)
    ba22:	e05a                	sd	s6,0(sp)
    ba24:	86a6                	mv	a3,s1
    ba26:	85ca                	mv	a1,s2
    ba28:	02000513          	li	a0,32
    ba2c:	9402                	jalr	s0
    ba2e:	68e2                	ld	a7,24(sp)
    ba30:	7782                	ld	a5,32(sp)
    ba32:	0b05                	addi	s6,s6,1
    ba34:	6602                	ld	a2,0(sp)
    ba36:	ec46                	sd	a7,24(sp)
    ba38:	f03e                	sd	a5,32(sp)
    ba3a:	e05a                	sd	s6,0(sp)
    ba3c:	86a6                	mv	a3,s1
    ba3e:	85ca                	mv	a1,s2
    ba40:	02000513          	li	a0,32
    ba44:	9402                	jalr	s0
    ba46:	68e2                	ld	a7,24(sp)
    ba48:	7782                	ld	a5,32(sp)
    ba4a:	0b05                	addi	s6,s6,1
    ba4c:	6602                	ld	a2,0(sp)
    ba4e:	ec46                	sd	a7,24(sp)
    ba50:	f03e                	sd	a5,32(sp)
    ba52:	86a6                	mv	a3,s1
    ba54:	85ca                	mv	a1,s2
    ba56:	02000513          	li	a0,32
    ba5a:	9402                	jalr	s0
    ba5c:	8bda                	mv	s7,s6
    ba5e:	7c82                	ld	s9,32(sp)
    ba60:	0b05                	addi	s6,s6,1
    ba62:	f056                	sd	s5,32(sp)
    ba64:	a895                	j	bad8 <_vsnprintf+0x2f08>
    ba66:	865a                	mv	a2,s6
    ba68:	86a6                	mv	a3,s1
    ba6a:	85ca                	mv	a1,s2
    ba6c:	02000513          	li	a0,32
    ba70:	9402                	jalr	s0
    ba72:	001b0b93          	addi	s7,s6,1
    ba76:	865e                	mv	a2,s7
    ba78:	86a6                	mv	a3,s1
    ba7a:	85ca                	mv	a1,s2
    ba7c:	02000513          	li	a0,32
    ba80:	9402                	jalr	s0
    ba82:	002b0a93          	addi	s5,s6,2
    ba86:	8656                	mv	a2,s5
    ba88:	86a6                	mv	a3,s1
    ba8a:	85ca                	mv	a1,s2
    ba8c:	02000513          	li	a0,32
    ba90:	9402                	jalr	s0
    ba92:	003b0b93          	addi	s7,s6,3
    ba96:	865e                	mv	a2,s7
    ba98:	86a6                	mv	a3,s1
    ba9a:	85ca                	mv	a1,s2
    ba9c:	02000513          	li	a0,32
    baa0:	9402                	jalr	s0
    baa2:	004b0a93          	addi	s5,s6,4
    baa6:	8656                	mv	a2,s5
    baa8:	86a6                	mv	a3,s1
    baaa:	85ca                	mv	a1,s2
    baac:	02000513          	li	a0,32
    bab0:	9402                	jalr	s0
    bab2:	005b0b93          	addi	s7,s6,5
    bab6:	865e                	mv	a2,s7
    bab8:	86a6                	mv	a3,s1
    baba:	85ca                	mv	a1,s2
    babc:	02000513          	li	a0,32
    bac0:	9402                	jalr	s0
    bac2:	006b0a93          	addi	s5,s6,6
    bac6:	86a6                	mv	a3,s1
    bac8:	8656                	mv	a2,s5
    baca:	85ca                	mv	a1,s2
    bacc:	02000513          	li	a0,32
    bad0:	007b0b93          	addi	s7,s6,7
    bad4:	9402                	jalr	s0
    bad6:	0b21                	addi	s6,s6,8
    bad8:	865e                	mv	a2,s7
    bada:	86a6                	mv	a3,s1
    badc:	85ca                	mv	a1,s2
    bade:	02000513          	li	a0,32
    bae2:	9402                	jalr	s0
    bae4:	f99b11e3          	bne	s6,s9,ba66 <_vsnprintf+0x2e96>
    bae8:	68e2                	ld	a7,24(sp)
    baea:	7a82                	ld	s5,32(sp)
    baec:	000d4503          	lbu	a0,0(s10)
    baf0:	e05a                	sd	s6,0(sp)
    baf2:	00188b9b          	addiw	s7,a7,1
    baf6:	e119                	bnez	a0,bafc <_vsnprintf+0x2f2c>
    baf8:	9b1fe06f          	j	a4a8 <_vsnprintf+0x18d8>
    bafc:	000a9463          	bnez	s5,bb04 <_vsnprintf+0x2f34>
    bb00:	b79fe06f          	j	a678 <_vsnprintf+0x1aa8>
    bb04:	4a81                	li	s5,0
    bb06:	e8cfd06f          	j	9192 <_vsnprintf+0x5c2>
    bb0a:	400b7b93          	andi	s7,s6,1024
    bb0e:	000b8463          	beqz	s7,bb16 <_vsnprintf+0x2f46>
    bb12:	1aa0206f          	j	dcbc <_vsnprintf+0x50ec>
    bb16:	002b7e13          	andi	t3,s6,2
    bb1a:	000e0463          	beqz	t3,bb22 <_vsnprintf+0x2f52>
    bb1e:	845fd06f          	j	9362 <_vsnprintf+0x792>
    bb22:	4a81                	li	s5,0
    bb24:	e51be9e3          	bltu	s7,a7,b976 <_vsnprintf+0x2da6>
    bb28:	6c82                	ld	s9,0(sp)
    bb2a:	2b85                	addiw	s7,s7,1
    bb2c:	c119                	beqz	a0,bb32 <_vsnprintf+0x2f62>
    bb2e:	b4bfe06f          	j	a678 <_vsnprintf+0x1aa8>
    bb32:	977fe06f          	j	a4a8 <_vsnprintf+0x18d8>
    bb36:	0001                	nop
    bb38:	fff7081b          	addiw	a6,a4,-1
    bb3c:	41f7180b          	th.mveqz	a6,a4,t6
    bb40:	41c887bb          	subw	a5,a7,t3
    bb44:	011e32b3          	sltu	t0,t3,a7
    bb48:	002b7313          	andi	t1,s6,2
    bb4c:	42e8170b          	th.mvnez	a4,a6,a4
    bb50:	4050178b          	th.mveqz	a5,zero,t0
    bb54:	8c0303e3          	beqz	t1,b41a <_vsnprintf+0x284a>
    bb58:	4a89                	li	s5,2
    bb5a:	4781                	li	a5,0
    bb5c:	bceff06f          	j	af2a <_vsnprintf+0x235a>
    bb60:	fefb7593          	andi	a1,s6,-17
    bb64:	06900613          	li	a2,105
    bb68:	8f5a                	mv	t5,s6
    bb6a:	2581                	sext.w	a1,a1
    bb6c:	00c50463          	beq	a0,a2,bb74 <_vsnprintf+0x2fa4>
    bb70:	1f50106f          	j	d564 <_vsnprintf+0x4994>
    bb74:	400b7713          	andi	a4,s6,1024
    bb78:	c319                	beqz	a4,bb7e <_vsnprintf+0x2fae>
    bb7a:	f25fe06f          	j	aa9e <_vsnprintf+0x1ece>
    bb7e:	200f7813          	andi	a6,t5,512
    bb82:	56081963          	bnez	a6,c0f4 <_vsnprintf+0x3524>
    bb86:	100f7e93          	andi	t4,t5,256
    bb8a:	000e9463          	bnez	t4,bb92 <_vsnprintf+0x2fc2>
    bb8e:	f33fe06f          	j	aac0 <_vsnprintf+0x1ef0>
    bb92:	c70fe06f          	j	a002 <_vsnprintf+0x1432>
    bb96:	410587b3          	sub	a5,a1,a6
    bb9a:	00267393          	andi	t2,a2,2
    bb9e:	00178d93          	addi	s11,a5,1
    bba2:	85b2                	mv	a1,a2
    bba4:	00039463          	bnez	t2,bbac <_vsnprintf+0x2fdc>
    bba8:	7840106f          	j	d32c <_vsnprintf+0x475c>
    bbac:	000d0463          	beqz	s10,bbb4 <_vsnprintf+0x2fe4>
    bbb0:	1840206f          	j	dd34 <_vsnprintf+0x5164>
    bbb4:	02000c13          	li	s8,32
    bbb8:	4d09                	li	s10,2
    bbba:	018d8463          	beq	s11,s8,bbc2 <_vsnprintf+0x2ff2>
    bbbe:	1990206f          	j	e556 <_vsnprintf+0x5986>
    bbc2:	6682                	ld	a3,0(sp)
    bbc4:	02000d93          	li	s11,32
    bbc8:	00dd8bb3          	add	s7,s11,a3
    bbcc:	007df713          	andi	a4,s11,7
    bbd0:	01b80c33          	add	s8,a6,s11
    bbd4:	01780b33          	add	s6,a6,s7
    bbd8:	c379                	beqz	a4,bc9e <_vsnprintf+0x30ce>
    bbda:	4f85                	li	t6,1
    bbdc:	0bf70363          	beq	a4,t6,bc82 <_vsnprintf+0x30b2>
    bbe0:	4689                	li	a3,2
    bbe2:	08d70563          	beq	a4,a3,bc6c <_vsnprintf+0x309c>
    bbe6:	4f0d                	li	t5,3
    bbe8:	07e70763          	beq	a4,t5,bc56 <_vsnprintf+0x3086>
    bbec:	4791                	li	a5,4
    bbee:	04f70963          	beq	a4,a5,bc40 <_vsnprintf+0x3070>
    bbf2:	4395                	li	t2,5
    bbf4:	02770b63          	beq	a4,t2,bc2a <_vsnprintf+0x305a>
    bbf8:	4319                	li	t1,6
    bbfa:	00670d63          	beq	a4,t1,bc14 <_vsnprintf+0x3044>
    bbfe:	418b0633          	sub	a2,s6,s8
    bc02:	89fc450b          	th.lbuib	a0,(s8),-1,0
    bc06:	ec46                	sd	a7,24(sp)
    bc08:	f042                	sd	a6,32(sp)
    bc0a:	86a6                	mv	a3,s1
    bc0c:	85ca                	mv	a1,s2
    bc0e:	9402                	jalr	s0
    bc10:	68e2                	ld	a7,24(sp)
    bc12:	7802                	ld	a6,32(sp)
    bc14:	418b0633          	sub	a2,s6,s8
    bc18:	89fc450b          	th.lbuib	a0,(s8),-1,0
    bc1c:	ec46                	sd	a7,24(sp)
    bc1e:	f042                	sd	a6,32(sp)
    bc20:	86a6                	mv	a3,s1
    bc22:	85ca                	mv	a1,s2
    bc24:	9402                	jalr	s0
    bc26:	68e2                	ld	a7,24(sp)
    bc28:	7802                	ld	a6,32(sp)
    bc2a:	418b0633          	sub	a2,s6,s8
    bc2e:	89fc450b          	th.lbuib	a0,(s8),-1,0
    bc32:	ec46                	sd	a7,24(sp)
    bc34:	f042                	sd	a6,32(sp)
    bc36:	86a6                	mv	a3,s1
    bc38:	85ca                	mv	a1,s2
    bc3a:	9402                	jalr	s0
    bc3c:	68e2                	ld	a7,24(sp)
    bc3e:	7802                	ld	a6,32(sp)
    bc40:	418b0633          	sub	a2,s6,s8
    bc44:	89fc450b          	th.lbuib	a0,(s8),-1,0
    bc48:	ec46                	sd	a7,24(sp)
    bc4a:	f042                	sd	a6,32(sp)
    bc4c:	86a6                	mv	a3,s1
    bc4e:	85ca                	mv	a1,s2
    bc50:	9402                	jalr	s0
    bc52:	68e2                	ld	a7,24(sp)
    bc54:	7802                	ld	a6,32(sp)
    bc56:	418b0633          	sub	a2,s6,s8
    bc5a:	89fc450b          	th.lbuib	a0,(s8),-1,0
    bc5e:	ec46                	sd	a7,24(sp)
    bc60:	f042                	sd	a6,32(sp)
    bc62:	86a6                	mv	a3,s1
    bc64:	85ca                	mv	a1,s2
    bc66:	9402                	jalr	s0
    bc68:	68e2                	ld	a7,24(sp)
    bc6a:	7802                	ld	a6,32(sp)
    bc6c:	418b0633          	sub	a2,s6,s8
    bc70:	89fc450b          	th.lbuib	a0,(s8),-1,0
    bc74:	ec46                	sd	a7,24(sp)
    bc76:	f042                	sd	a6,32(sp)
    bc78:	86a6                	mv	a3,s1
    bc7a:	85ca                	mv	a1,s2
    bc7c:	9402                	jalr	s0
    bc7e:	68e2                	ld	a7,24(sp)
    bc80:	7802                	ld	a6,32(sp)
    bc82:	418b0633          	sub	a2,s6,s8
    bc86:	89fc450b          	th.lbuib	a0,(s8),-1,0
    bc8a:	ec46                	sd	a7,24(sp)
    bc8c:	f042                	sd	a6,32(sp)
    bc8e:	86a6                	mv	a3,s1
    bc90:	85ca                	mv	a1,s2
    bc92:	9402                	jalr	s0
    bc94:	68e2                	ld	a7,24(sp)
    bc96:	7802                	ld	a6,32(sp)
    bc98:	8dde                	mv	s11,s7
    bc9a:	09880b63          	beq	a6,s8,bd30 <_vsnprintf+0x3160>
    bc9e:	ec56                	sd	s5,24(sp)
    bca0:	f06a                	sd	s10,32(sp)
    bca2:	8ac2                	mv	s5,a6
    bca4:	8d46                	mv	s10,a7
    bca6:	8ce2                	mv	s9,s8
    bca8:	89fcc50b          	th.lbuib	a0,(s9),-1,0
    bcac:	418b0633          	sub	a2,s6,s8
    bcb0:	86a6                	mv	a3,s1
    bcb2:	85ca                	mv	a1,s2
    bcb4:	9402                	jalr	s0
    bcb6:	8de2                	mv	s11,s8
    bcb8:	89edc50b          	th.lbuib	a0,(s11),-2,0
    bcbc:	419b0633          	sub	a2,s6,s9
    bcc0:	86a6                	mv	a3,s1
    bcc2:	85ca                	mv	a1,s2
    bcc4:	9402                	jalr	s0
    bcc6:	8ce2                	mv	s9,s8
    bcc8:	89dcc50b          	th.lbuib	a0,(s9),-3,0
    bccc:	41bb0633          	sub	a2,s6,s11
    bcd0:	86a6                	mv	a3,s1
    bcd2:	85ca                	mv	a1,s2
    bcd4:	9402                	jalr	s0
    bcd6:	8de2                	mv	s11,s8
    bcd8:	89cdc50b          	th.lbuib	a0,(s11),-4,0
    bcdc:	419b0633          	sub	a2,s6,s9
    bce0:	86a6                	mv	a3,s1
    bce2:	85ca                	mv	a1,s2
    bce4:	9402                	jalr	s0
    bce6:	8ce2                	mv	s9,s8
    bce8:	89bcc50b          	th.lbuib	a0,(s9),-5,0
    bcec:	41bb0633          	sub	a2,s6,s11
    bcf0:	86a6                	mv	a3,s1
    bcf2:	85ca                	mv	a1,s2
    bcf4:	9402                	jalr	s0
    bcf6:	8de2                	mv	s11,s8
    bcf8:	89adc50b          	th.lbuib	a0,(s11),-6,0
    bcfc:	419b0633          	sub	a2,s6,s9
    bd00:	86a6                	mv	a3,s1
    bd02:	85ca                	mv	a1,s2
    bd04:	9402                	jalr	s0
    bd06:	8ce2                	mv	s9,s8
    bd08:	899cc50b          	th.lbuib	a0,(s9),-7,0
    bd0c:	41bb0633          	sub	a2,s6,s11
    bd10:	86a6                	mv	a3,s1
    bd12:	85ca                	mv	a1,s2
    bd14:	9402                	jalr	s0
    bd16:	898c450b          	th.lbuib	a0,(s8),-8,0
    bd1a:	86a6                	mv	a3,s1
    bd1c:	419b0633          	sub	a2,s6,s9
    bd20:	85ca                	mv	a1,s2
    bd22:	8dde                	mv	s11,s7
    bd24:	9402                	jalr	s0
    bd26:	f98a90e3          	bne	s5,s8,bca6 <_vsnprintf+0x30d6>
    bd2a:	88ea                	mv	a7,s10
    bd2c:	6ae2                	ld	s5,24(sp)
    bd2e:	7d02                	ld	s10,32(sp)
    bd30:	000d1d63          	bnez	s10,bd4a <_vsnprintf+0x317a>
    bd34:	e06e                	sd	s11,0(sp)
    bd36:	8dd6                	mv	s11,s5
    bd38:	f70fe06f          	j	a4a8 <_vsnprintf+0x18d8>
    bd3c:	002ffd13          	andi	s10,t6,2
    bd40:	000d1463          	bnez	s10,bd48 <_vsnprintf+0x3178>
    bd44:	72c0206f          	j	e470 <_vsnprintf+0x58a0>
    bd48:	6d82                	ld	s11,0(sp)
    bd4a:	6e82                	ld	t4,0(sp)
    bd4c:	7c08bc0b          	th.extu	s8,a7,31,0
    bd50:	41dd8d33          	sub	s10,s11,t4
    bd54:	ff8d70e3          	bgeu	s10,s8,bd34 <_vsnprintf+0x3164>
    bd58:	fffd4893          	not	a7,s10
    bd5c:	01888e33          	add	t3,a7,s8
    bd60:	86a6                	mv	a3,s1
    bd62:	866e                	mv	a2,s11
    bd64:	85ca                	mv	a1,s2
    bd66:	02000513          	li	a0,32
    bd6a:	001d0c93          	addi	s9,s10,1
    bd6e:	007e7b93          	andi	s7,t3,7
    bd72:	001d8b13          	addi	s6,s11,1
    bd76:	9402                	jalr	s0
    bd78:	138cf463          	bgeu	s9,s8,bea0 <_vsnprintf+0x32d0>
    bd7c:	0a0b8063          	beqz	s7,be1c <_vsnprintf+0x324c>
    bd80:	4285                	li	t0,1
    bd82:	085b8363          	beq	s7,t0,be08 <_vsnprintf+0x3238>
    bd86:	4589                	li	a1,2
    bd88:	06bb8863          	beq	s7,a1,bdf8 <_vsnprintf+0x3228>
    bd8c:	460d                	li	a2,3
    bd8e:	04cb8d63          	beq	s7,a2,bde8 <_vsnprintf+0x3218>
    bd92:	4511                	li	a0,4
    bd94:	04ab8263          	beq	s7,a0,bdd8 <_vsnprintf+0x3208>
    bd98:	4715                	li	a4,5
    bd9a:	02eb8763          	beq	s7,a4,bdc8 <_vsnprintf+0x31f8>
    bd9e:	4f99                	li	t6,6
    bda0:	01fb8c63          	beq	s7,t6,bdb8 <_vsnprintf+0x31e8>
    bda4:	865a                	mv	a2,s6
    bda6:	86a6                	mv	a3,s1
    bda8:	85ca                	mv	a1,s2
    bdaa:	02000513          	li	a0,32
    bdae:	002d8b13          	addi	s6,s11,2
    bdb2:	9402                	jalr	s0
    bdb4:	002d0c93          	addi	s9,s10,2
    bdb8:	865a                	mv	a2,s6
    bdba:	86a6                	mv	a3,s1
    bdbc:	85ca                	mv	a1,s2
    bdbe:	02000513          	li	a0,32
    bdc2:	0b05                	addi	s6,s6,1
    bdc4:	9402                	jalr	s0
    bdc6:	0c85                	addi	s9,s9,1
    bdc8:	865a                	mv	a2,s6
    bdca:	86a6                	mv	a3,s1
    bdcc:	85ca                	mv	a1,s2
    bdce:	02000513          	li	a0,32
    bdd2:	0b05                	addi	s6,s6,1
    bdd4:	9402                	jalr	s0
    bdd6:	0c85                	addi	s9,s9,1
    bdd8:	865a                	mv	a2,s6
    bdda:	86a6                	mv	a3,s1
    bddc:	85ca                	mv	a1,s2
    bdde:	02000513          	li	a0,32
    bde2:	0b05                	addi	s6,s6,1
    bde4:	9402                	jalr	s0
    bde6:	0c85                	addi	s9,s9,1
    bde8:	865a                	mv	a2,s6
    bdea:	86a6                	mv	a3,s1
    bdec:	85ca                	mv	a1,s2
    bdee:	02000513          	li	a0,32
    bdf2:	0b05                	addi	s6,s6,1
    bdf4:	9402                	jalr	s0
    bdf6:	0c85                	addi	s9,s9,1
    bdf8:	865a                	mv	a2,s6
    bdfa:	86a6                	mv	a3,s1
    bdfc:	85ca                	mv	a1,s2
    bdfe:	02000513          	li	a0,32
    be02:	0b05                	addi	s6,s6,1
    be04:	9402                	jalr	s0
    be06:	0c85                	addi	s9,s9,1
    be08:	865a                	mv	a2,s6
    be0a:	86a6                	mv	a3,s1
    be0c:	85ca                	mv	a1,s2
    be0e:	02000513          	li	a0,32
    be12:	0c85                	addi	s9,s9,1
    be14:	0b05                	addi	s6,s6,1
    be16:	9402                	jalr	s0
    be18:	098cf463          	bgeu	s9,s8,bea0 <_vsnprintf+0x32d0>
    be1c:	865a                	mv	a2,s6
    be1e:	86a6                	mv	a3,s1
    be20:	85ca                	mv	a1,s2
    be22:	02000513          	li	a0,32
    be26:	9402                	jalr	s0
    be28:	001b0d93          	addi	s11,s6,1
    be2c:	866e                	mv	a2,s11
    be2e:	86a6                	mv	a3,s1
    be30:	85ca                	mv	a1,s2
    be32:	02000513          	li	a0,32
    be36:	9402                	jalr	s0
    be38:	002b0d13          	addi	s10,s6,2
    be3c:	866a                	mv	a2,s10
    be3e:	86a6                	mv	a3,s1
    be40:	85ca                	mv	a1,s2
    be42:	02000513          	li	a0,32
    be46:	9402                	jalr	s0
    be48:	003b0b93          	addi	s7,s6,3
    be4c:	865e                	mv	a2,s7
    be4e:	86a6                	mv	a3,s1
    be50:	85ca                	mv	a1,s2
    be52:	02000513          	li	a0,32
    be56:	9402                	jalr	s0
    be58:	004b0d93          	addi	s11,s6,4
    be5c:	866e                	mv	a2,s11
    be5e:	86a6                	mv	a3,s1
    be60:	85ca                	mv	a1,s2
    be62:	02000513          	li	a0,32
    be66:	9402                	jalr	s0
    be68:	005b0b93          	addi	s7,s6,5
    be6c:	86a6                	mv	a3,s1
    be6e:	865e                	mv	a2,s7
    be70:	85ca                	mv	a1,s2
    be72:	02000513          	li	a0,32
    be76:	9402                	jalr	s0
    be78:	006b0d13          	addi	s10,s6,6
    be7c:	86a6                	mv	a3,s1
    be7e:	866a                	mv	a2,s10
    be80:	85ca                	mv	a1,s2
    be82:	02000513          	li	a0,32
    be86:	9402                	jalr	s0
    be88:	007b0d93          	addi	s11,s6,7
    be8c:	86a6                	mv	a3,s1
    be8e:	866e                	mv	a2,s11
    be90:	85ca                	mv	a1,s2
    be92:	02000513          	li	a0,32
    be96:	0ca1                	addi	s9,s9,8
    be98:	0b21                	addi	s6,s6,8
    be9a:	9402                	jalr	s0
    be9c:	f98ce0e3          	bltu	s9,s8,be1c <_vsnprintf+0x324c>
    bea0:	e05a                	sd	s6,0(sp)
    bea2:	8dd6                	mv	s11,s5
    bea4:	e04fe06f          	j	a4a8 <_vsnprintf+0x18d8>
    bea8:	886e                	mv	a6,s11
    beaa:	78884e8b          	th.ldia	t4,(a6),8,0
    beae:	240e9963          	bnez	t4,c100 <_vsnprintf+0x3530>
    beb2:	002afd93          	andi	s11,s5,2
    beb6:	000d8463          	beqz	s11,bebe <_vsnprintf+0x32ee>
    beba:	2ae0206f          	j	e168 <_vsnprintf+0x5598>
    bebe:	7c0c3c0b          	th.extu	s8,s8,31,0
    bec2:	4781                	li	a5,0
    bec4:	03010c93          	addi	s9,sp,48
    bec8:	00089463          	bnez	a7,bed0 <_vsnprintf+0x3300>
    becc:	5c80206f          	j	e494 <_vsnprintf+0x58c4>
    bed0:	000c1463          	bnez	s8,bed8 <_vsnprintf+0x3308>
    bed4:	7050206f          	j	edd8 <_vsnprintf+0x6208>
    bed8:	02000a93          	li	s5,32
    bedc:	40fa8633          	sub	a2,s5,a5
    bee0:	00767393          	andi	t2,a2,7
    bee4:	00fc8bb3          	add	s7,s9,a5
    bee8:	03000e13          	li	t3,48
    beec:	06038763          	beqz	t2,bf5a <_vsnprintf+0x338a>
    bef0:	0785                	addi	a5,a5,1
    bef2:	181bde0b          	th.sbia	t3,(s7),1,0
    bef6:	0d87f663          	bgeu	a5,s8,bfc2 <_vsnprintf+0x33f2>
    befa:	4f85                	li	t6,1
    befc:	05f38f63          	beq	t2,t6,bf5a <_vsnprintf+0x338a>
    bf00:	4709                	li	a4,2
    bf02:	04e38763          	beq	t2,a4,bf50 <_vsnprintf+0x3380>
    bf06:	4f0d                	li	t5,3
    bf08:	03e38f63          	beq	t2,t5,bf46 <_vsnprintf+0x3376>
    bf0c:	4d11                	li	s10,4
    bf0e:	03a38763          	beq	t2,s10,bf3c <_vsnprintf+0x336c>
    bf12:	4295                	li	t0,5
    bf14:	00538f63          	beq	t2,t0,bf32 <_vsnprintf+0x3362>
    bf18:	4319                	li	t1,6
    bf1a:	00638763          	beq	t2,t1,bf28 <_vsnprintf+0x3358>
    bf1e:	0785                	addi	a5,a5,1
    bf20:	181bde0b          	th.sbia	t3,(s7),1,0
    bf24:	0987ff63          	bgeu	a5,s8,bfc2 <_vsnprintf+0x33f2>
    bf28:	0785                	addi	a5,a5,1
    bf2a:	181bde0b          	th.sbia	t3,(s7),1,0
    bf2e:	0987fa63          	bgeu	a5,s8,bfc2 <_vsnprintf+0x33f2>
    bf32:	0785                	addi	a5,a5,1
    bf34:	181bde0b          	th.sbia	t3,(s7),1,0
    bf38:	0987f563          	bgeu	a5,s8,bfc2 <_vsnprintf+0x33f2>
    bf3c:	0785                	addi	a5,a5,1
    bf3e:	181bde0b          	th.sbia	t3,(s7),1,0
    bf42:	0987f063          	bgeu	a5,s8,bfc2 <_vsnprintf+0x33f2>
    bf46:	0785                	addi	a5,a5,1
    bf48:	181bde0b          	th.sbia	t3,(s7),1,0
    bf4c:	0787fb63          	bgeu	a5,s8,bfc2 <_vsnprintf+0x33f2>
    bf50:	0785                	addi	a5,a5,1
    bf52:	181bde0b          	th.sbia	t3,(s7),1,0
    bf56:	0787f663          	bgeu	a5,s8,bfc2 <_vsnprintf+0x33f2>
    bf5a:	01579463          	bne	a5,s5,bf62 <_vsnprintf+0x3392>
    bf5e:	7800106f          	j	d6de <_vsnprintf+0x4b0e>
    bf62:	0785                	addi	a5,a5,1
    bf64:	01cb8023          	sb	t3,0(s7)
    bf68:	853e                	mv	a0,a5
    bf6a:	0587fc63          	bgeu	a5,s8,bfc2 <_vsnprintf+0x33f2>
    bf6e:	0785                	addi	a5,a5,1
    bf70:	01cb80a3          	sb	t3,1(s7)
    bf74:	0587f763          	bgeu	a5,s8,bfc2 <_vsnprintf+0x33f2>
    bf78:	00250793          	addi	a5,a0,2
    bf7c:	01cb8123          	sb	t3,2(s7)
    bf80:	0587f163          	bgeu	a5,s8,bfc2 <_vsnprintf+0x33f2>
    bf84:	00350793          	addi	a5,a0,3
    bf88:	01cb81a3          	sb	t3,3(s7)
    bf8c:	0387fb63          	bgeu	a5,s8,bfc2 <_vsnprintf+0x33f2>
    bf90:	00450793          	addi	a5,a0,4
    bf94:	01cb8223          	sb	t3,4(s7)
    bf98:	0387f563          	bgeu	a5,s8,bfc2 <_vsnprintf+0x33f2>
    bf9c:	00550793          	addi	a5,a0,5
    bfa0:	01cb82a3          	sb	t3,5(s7)
    bfa4:	0187ff63          	bgeu	a5,s8,bfc2 <_vsnprintf+0x33f2>
    bfa8:	00650793          	addi	a5,a0,6
    bfac:	01cb8323          	sb	t3,6(s7)
    bfb0:	0187f963          	bgeu	a5,s8,bfc2 <_vsnprintf+0x33f2>
    bfb4:	01cb83a3          	sb	t3,7(s7)
    bfb8:	00750793          	addi	a5,a0,7
    bfbc:	0ba1                	addi	s7,s7,8
    bfbe:	f987eee3          	bltu	a5,s8,bf5a <_vsnprintf+0x338a>
    bfc2:	000d9463          	bnez	s11,bfca <_vsnprintf+0x33fa>
    bfc6:	23a0206f          	j	e200 <_vsnprintf+0x5630>
    bfca:	7c08b68b          	th.extu	a3,a7,31,0
    bfce:	00d7e463          	bltu	a5,a3,bfd6 <_vsnprintf+0x3406>
    bfd2:	2b70206f          	j	ea88 <_vsnprintf+0x5eb8>
    bfd6:	02000d93          	li	s11,32
    bfda:	40fd8ab3          	sub	s5,s11,a5
    bfde:	007afe13          	andi	t3,s5,7
    bfe2:	00fc8633          	add	a2,s9,a5
    bfe6:	03000b13          	li	s6,48
    bfea:	060e0763          	beqz	t3,c058 <_vsnprintf+0x3488>
    bfee:	0785                	addi	a5,a5,1
    bff0:	18165b0b          	th.sbia	s6,(a2),1,0
    bff4:	0cd78663          	beq	a5,a3,c0c0 <_vsnprintf+0x34f0>
    bff8:	4385                	li	t2,1
    bffa:	047e0f63          	beq	t3,t2,c058 <_vsnprintf+0x3488>
    bffe:	4f89                	li	t6,2
    c000:	05fe0763          	beq	t3,t6,c04e <_vsnprintf+0x347e>
    c004:	470d                	li	a4,3
    c006:	02ee0f63          	beq	t3,a4,c044 <_vsnprintf+0x3474>
    c00a:	4f11                	li	t5,4
    c00c:	03ee0763          	beq	t3,t5,c03a <_vsnprintf+0x346a>
    c010:	4d15                	li	s10,5
    c012:	01ae0f63          	beq	t3,s10,c030 <_vsnprintf+0x3460>
    c016:	4299                	li	t0,6
    c018:	005e0763          	beq	t3,t0,c026 <_vsnprintf+0x3456>
    c01c:	0785                	addi	a5,a5,1
    c01e:	18165b0b          	th.sbia	s6,(a2),1,0
    c022:	08d78f63          	beq	a5,a3,c0c0 <_vsnprintf+0x34f0>
    c026:	0785                	addi	a5,a5,1
    c028:	18165b0b          	th.sbia	s6,(a2),1,0
    c02c:	08d78a63          	beq	a5,a3,c0c0 <_vsnprintf+0x34f0>
    c030:	0785                	addi	a5,a5,1
    c032:	18165b0b          	th.sbia	s6,(a2),1,0
    c036:	08d78563          	beq	a5,a3,c0c0 <_vsnprintf+0x34f0>
    c03a:	0785                	addi	a5,a5,1
    c03c:	18165b0b          	th.sbia	s6,(a2),1,0
    c040:	08d78063          	beq	a5,a3,c0c0 <_vsnprintf+0x34f0>
    c044:	0785                	addi	a5,a5,1
    c046:	18165b0b          	th.sbia	s6,(a2),1,0
    c04a:	06d78b63          	beq	a5,a3,c0c0 <_vsnprintf+0x34f0>
    c04e:	0785                	addi	a5,a5,1
    c050:	18165b0b          	th.sbia	s6,(a2),1,0
    c054:	06d78663          	beq	a5,a3,c0c0 <_vsnprintf+0x34f0>
    c058:	01b79463          	bne	a5,s11,c060 <_vsnprintf+0x3490>
    c05c:	6640106f          	j	d6c0 <_vsnprintf+0x4af0>
    c060:	00178313          	addi	t1,a5,1
    c064:	01660023          	sb	s6,0(a2)
    c068:	04d30c63          	beq	t1,a3,c0c0 <_vsnprintf+0x34f0>
    c06c:	00278513          	addi	a0,a5,2
    c070:	016600a3          	sb	s6,1(a2)
    c074:	04d50663          	beq	a0,a3,c0c0 <_vsnprintf+0x34f0>
    c078:	00378b93          	addi	s7,a5,3
    c07c:	01660123          	sb	s6,2(a2)
    c080:	04db8063          	beq	s7,a3,c0c0 <_vsnprintf+0x34f0>
    c084:	00478c13          	addi	s8,a5,4
    c088:	016601a3          	sb	s6,3(a2)
    c08c:	02dc0a63          	beq	s8,a3,c0c0 <_vsnprintf+0x34f0>
    c090:	00578a93          	addi	s5,a5,5
    c094:	01660223          	sb	s6,4(a2)
    c098:	02da8463          	beq	s5,a3,c0c0 <_vsnprintf+0x34f0>
    c09c:	00678e13          	addi	t3,a5,6
    c0a0:	016602a3          	sb	s6,5(a2)
    c0a4:	00de0e63          	beq	t3,a3,c0c0 <_vsnprintf+0x34f0>
    c0a8:	00778393          	addi	t2,a5,7
    c0ac:	01660323          	sb	s6,6(a2)
    c0b0:	00d38863          	beq	t2,a3,c0c0 <_vsnprintf+0x34f0>
    c0b4:	016603a3          	sb	s6,7(a2)
    c0b8:	07a1                	addi	a5,a5,8
    c0ba:	0621                	addi	a2,a2,8
    c0bc:	f8d79ee3          	bne	a5,a3,c058 <_vsnprintf+0x3488>
    c0c0:	02000793          	li	a5,32
    c0c4:	00f69463          	bne	a3,a5,c0cc <_vsnprintf+0x34fc>
    c0c8:	5f80106f          	j	d6c0 <_vsnprintf+0x4af0>
    c0cc:	000ec463          	bltz	t4,c0d4 <_vsnprintf+0x3504>
    c0d0:	07b0206f          	j	e94a <_vsnprintf+0x5d7a>
    c0d4:	00268ab3          	add	s5,a3,sp
    c0d8:	02d00513          	li	a0,45
    c0dc:	02aa8823          	sb	a0,48(s5)
    c0e0:	0035fe13          	andi	t3,a1,3
    c0e4:	00168c13          	addi	s8,a3,1
    c0e8:	380e06e3          	beqz	t3,cc74 <_vsnprintf+0x40a4>
    c0ec:	8dc2                	mv	s11,a6
    c0ee:	4b01                	li	s6,0
    c0f0:	6802                	ld	a6,0(sp)
    c0f2:	aaa5                	j	c26a <_vsnprintf+0x369a>
    c0f4:	886e                	mv	a6,s11
    c0f6:	78884e8b          	th.ldia	t4,(a6),8,0
    c0fa:	4b81                	li	s7,0
    c0fc:	000e8863          	beqz	t4,c10c <_vsnprintf+0x353c>
    c100:	43fedd93          	srai	s11,t4,0x3f
    c104:	01ddc533          	xor	a0,s11,t4
    c108:	41b50bb3          	sub	s7,a0,s11
    c10c:	46a9                	li	a3,10
    c10e:	02dbfb33          	remu	s6,s7,a3
    c112:	03010c93          	addi	s9,sp,48
    c116:	4d25                	li	s10,9
    c118:	87e6                	mv	a5,s9
    c11a:	030b0a9b          	addiw	s5,s6,48
    c11e:	03510823          	sb	s5,48(sp)
    c122:	02dbd533          	divu	a0,s7,a3
    c126:	117d7d63          	bgeu	s10,s7,c240 <_vsnprintf+0x3670>
    c12a:	03110793          	addi	a5,sp,49
    c12e:	02d57333          	remu	t1,a0,a3
    c132:	03030e1b          	addiw	t3,t1,48
    c136:	01c78023          	sb	t3,0(a5)
    c13a:	02d55633          	divu	a2,a0,a3
    c13e:	10ad7163          	bgeu	s10,a0,c240 <_vsnprintf+0x3670>
    c142:	0001                	nop
    c144:	00000013          	nop
    c148:	00178293          	addi	t0,a5,1
    c14c:	05010f93          	addi	t6,sp,80
    c150:	0e5f8863          	beq	t6,t0,c240 <_vsnprintf+0x3670>
    c154:	8796                	mv	a5,t0
    c156:	02d673b3          	remu	t2,a2,a3
    c15a:	0303871b          	addiw	a4,t2,48
    c15e:	00e28023          	sb	a4,0(t0)
    c162:	02d65f33          	divu	t5,a2,a3
    c166:	0ccd7d63          	bgeu	s10,a2,c240 <_vsnprintf+0x3670>
    c16a:	02df7333          	remu	t1,t5,a3
    c16e:	03030d9b          	addiw	s11,t1,48
    c172:	0817dd8b          	th.sbib	s11,(a5),1,0
    c176:	02df5533          	divu	a0,t5,a3
    c17a:	0ded7363          	bgeu	s10,t5,c240 <_vsnprintf+0x3670>
    c17e:	00228793          	addi	a5,t0,2
    c182:	02d57bb3          	remu	s7,a0,a3
    c186:	030b8b1b          	addiw	s6,s7,48
    c18a:	01628123          	sb	s6,2(t0)
    c18e:	02d55ab3          	divu	s5,a0,a3
    c192:	0aad7763          	bgeu	s10,a0,c240 <_vsnprintf+0x3670>
    c196:	00328793          	addi	a5,t0,3
    c19a:	02dafe33          	remu	t3,s5,a3
    c19e:	030e061b          	addiw	a2,t3,48
    c1a2:	00c281a3          	sb	a2,3(t0)
    c1a6:	02dadfb3          	divu	t6,s5,a3
    c1aa:	095d7b63          	bgeu	s10,s5,c240 <_vsnprintf+0x3670>
    c1ae:	00428793          	addi	a5,t0,4
    c1b2:	02dff3b3          	remu	t2,t6,a3
    c1b6:	0303871b          	addiw	a4,t2,48
    c1ba:	00e28223          	sb	a4,4(t0)
    c1be:	02dfdf33          	divu	t5,t6,a3
    c1c2:	07fd7f63          	bgeu	s10,t6,c240 <_vsnprintf+0x3670>
    c1c6:	00528793          	addi	a5,t0,5
    c1ca:	02df7333          	remu	t1,t5,a3
    c1ce:	03030d9b          	addiw	s11,t1,48
    c1d2:	01b282a3          	sb	s11,5(t0)
    c1d6:	02df5533          	divu	a0,t5,a3
    c1da:	07ed7363          	bgeu	s10,t5,c240 <_vsnprintf+0x3670>
    c1de:	00628793          	addi	a5,t0,6
    c1e2:	02d57bb3          	remu	s7,a0,a3
    c1e6:	030b8b1b          	addiw	s6,s7,48
    c1ea:	01628323          	sb	s6,6(t0)
    c1ee:	02d55ab3          	divu	s5,a0,a3
    c1f2:	04ad7763          	bgeu	s10,a0,c240 <_vsnprintf+0x3670>
    c1f6:	00728793          	addi	a5,t0,7
    c1fa:	02dafe33          	remu	t3,s5,a3
    c1fe:	030e061b          	addiw	a2,t3,48
    c202:	00c283a3          	sb	a2,7(t0)
    c206:	02dadfb3          	divu	t6,s5,a3
    c20a:	035d7b63          	bgeu	s10,s5,c240 <_vsnprintf+0x3670>
    c20e:	00828793          	addi	a5,t0,8
    c212:	02dff3b3          	remu	t2,t6,a3
    c216:	0303871b          	addiw	a4,t2,48
    c21a:	00e28423          	sb	a4,8(t0)
    c21e:	02dfdf33          	divu	t5,t6,a3
    c222:	01fd7f63          	bgeu	s10,t6,c240 <_vsnprintf+0x3670>
    c226:	00928793          	addi	a5,t0,9
    c22a:	857a                	mv	a0,t5
    c22c:	02df7333          	remu	t1,t5,a3
    c230:	03030e1b          	addiw	t3,t1,48
    c234:	01c78023          	sb	t3,0(a5)
    c238:	02d55633          	divu	a2,a0,a3
    c23c:	f0ad66e3          	bltu	s10,a0,c148 <_vsnprintf+0x3578>
    c240:	419787b3          	sub	a5,a5,s9
    c244:	0025fb13          	andi	s6,a1,2
    c248:	0785                	addi	a5,a5,1
    c24a:	86ae                	mv	a3,a1
    c24c:	1e0b04e3          	beqz	s6,cc34 <_vsnprintf+0x4064>
    c250:	02000c13          	li	s8,32
    c254:	4b09                	li	s6,2
    c256:	01878463          	beq	a5,s8,c25e <_vsnprintf+0x368e>
    c25a:	1b50106f          	j	dc0e <_vsnprintf+0x503e>
    c25e:	8dc2                	mv	s11,a6
    c260:	04f14503          	lbu	a0,79(sp)
    c264:	6802                	ld	a6,0(sp)
    c266:	02000c13          	li	s8,32
    c26a:	018c8d33          	add	s10,s9,s8
    c26e:	01880bb3          	add	s7,a6,s8
    c272:	fffcc813          	not	a6,s9
    c276:	01a802b3          	add	t0,a6,s10
    c27a:	0072f313          	andi	t1,t0,7
    c27e:	017c8c33          	add	s8,s9,s7
    c282:	00031463          	bnez	t1,c28a <_vsnprintf+0x36ba>
    c286:	2e80106f          	j	d56e <_vsnprintf+0x499e>
    c28a:	41ac0633          	sub	a2,s8,s10
    c28e:	ec46                	sd	a7,24(sp)
    c290:	f01a                	sd	t1,32(sp)
    c292:	86a6                	mv	a3,s1
    c294:	85ca                	mv	a1,s2
    c296:	9402                	jalr	s0
    c298:	68e2                	ld	a7,24(sp)
    c29a:	7e02                	ld	t3,32(sp)
    c29c:	4a85                	li	s5,1
    c29e:	1d7d                	addi	s10,s10,-1
    c2a0:	fffd4503          	lbu	a0,-1(s10)
    c2a4:	015e1463          	bne	t3,s5,c2ac <_vsnprintf+0x36dc>
    c2a8:	2c60106f          	j	d56e <_vsnprintf+0x499e>
    c2ac:	4609                	li	a2,2
    c2ae:	06ce0f63          	beq	t3,a2,c32c <_vsnprintf+0x375c>
    c2b2:	438d                	li	t2,3
    c2b4:	067e0263          	beq	t3,t2,c318 <_vsnprintf+0x3748>
    c2b8:	4791                	li	a5,4
    c2ba:	04fe0563          	beq	t3,a5,c304 <_vsnprintf+0x3734>
    c2be:	4e95                	li	t4,5
    c2c0:	03de0863          	beq	t3,t4,c2f0 <_vsnprintf+0x3720>
    c2c4:	4599                	li	a1,6
    c2c6:	00be0b63          	beq	t3,a1,c2dc <_vsnprintf+0x370c>
    c2ca:	41ac0633          	sub	a2,s8,s10
    c2ce:	86a6                	mv	a3,s1
    c2d0:	85ca                	mv	a1,s2
    c2d2:	9402                	jalr	s0
    c2d4:	68e2                	ld	a7,24(sp)
    c2d6:	ffed4503          	lbu	a0,-2(s10)
    c2da:	1d7d                	addi	s10,s10,-1
    c2dc:	41ac0633          	sub	a2,s8,s10
    c2e0:	ec46                	sd	a7,24(sp)
    c2e2:	86a6                	mv	a3,s1
    c2e4:	85ca                	mv	a1,s2
    c2e6:	9402                	jalr	s0
    c2e8:	68e2                	ld	a7,24(sp)
    c2ea:	ffed4503          	lbu	a0,-2(s10)
    c2ee:	1d7d                	addi	s10,s10,-1
    c2f0:	41ac0633          	sub	a2,s8,s10
    c2f4:	ec46                	sd	a7,24(sp)
    c2f6:	86a6                	mv	a3,s1
    c2f8:	85ca                	mv	a1,s2
    c2fa:	9402                	jalr	s0
    c2fc:	68e2                	ld	a7,24(sp)
    c2fe:	ffed4503          	lbu	a0,-2(s10)
    c302:	1d7d                	addi	s10,s10,-1
    c304:	41ac0633          	sub	a2,s8,s10
    c308:	ec46                	sd	a7,24(sp)
    c30a:	86a6                	mv	a3,s1
    c30c:	85ca                	mv	a1,s2
    c30e:	9402                	jalr	s0
    c310:	68e2                	ld	a7,24(sp)
    c312:	ffed4503          	lbu	a0,-2(s10)
    c316:	1d7d                	addi	s10,s10,-1
    c318:	41ac0633          	sub	a2,s8,s10
    c31c:	ec46                	sd	a7,24(sp)
    c31e:	86a6                	mv	a3,s1
    c320:	85ca                	mv	a1,s2
    c322:	9402                	jalr	s0
    c324:	68e2                	ld	a7,24(sp)
    c326:	ffed4503          	lbu	a0,-2(s10)
    c32a:	1d7d                	addi	s10,s10,-1
    c32c:	41ac0633          	sub	a2,s8,s10
    c330:	86a6                	mv	a3,s1
    c332:	85ca                	mv	a1,s2
    c334:	ec46                	sd	a7,24(sp)
    c336:	9402                	jalr	s0
    c338:	1d7d                	addi	s10,s10,-1
    c33a:	f05a                	sd	s6,32(sp)
    c33c:	fffd4503          	lbu	a0,-1(s10)
    c340:	a895                	j	c3b4 <_vsnprintf+0x37e4>
    c342:	8b6a                	mv	s6,s10
    c344:	40ac0633          	sub	a2,s8,a0
    c348:	89eb450b          	th.lbuib	a0,(s6),-2,0
    c34c:	86a6                	mv	a3,s1
    c34e:	85ca                	mv	a1,s2
    c350:	9402                	jalr	s0
    c352:	8aea                	mv	s5,s10
    c354:	89dac50b          	th.lbuib	a0,(s5),-3,0
    c358:	416c0633          	sub	a2,s8,s6
    c35c:	86a6                	mv	a3,s1
    c35e:	85ca                	mv	a1,s2
    c360:	9402                	jalr	s0
    c362:	8b6a                	mv	s6,s10
    c364:	89cb450b          	th.lbuib	a0,(s6),-4,0
    c368:	415c0633          	sub	a2,s8,s5
    c36c:	86a6                	mv	a3,s1
    c36e:	85ca                	mv	a1,s2
    c370:	9402                	jalr	s0
    c372:	8aea                	mv	s5,s10
    c374:	89bac50b          	th.lbuib	a0,(s5),-5,0
    c378:	416c0633          	sub	a2,s8,s6
    c37c:	86a6                	mv	a3,s1
    c37e:	85ca                	mv	a1,s2
    c380:	9402                	jalr	s0
    c382:	8b6a                	mv	s6,s10
    c384:	89ab450b          	th.lbuib	a0,(s6),-6,0
    c388:	415c0633          	sub	a2,s8,s5
    c38c:	86a6                	mv	a3,s1
    c38e:	85ca                	mv	a1,s2
    c390:	9402                	jalr	s0
    c392:	8aea                	mv	s5,s10
    c394:	899ac50b          	th.lbuib	a0,(s5),-7,0
    c398:	86a6                	mv	a3,s1
    c39a:	416c0633          	sub	a2,s8,s6
    c39e:	85ca                	mv	a1,s2
    c3a0:	9402                	jalr	s0
    c3a2:	898d450b          	th.lbuib	a0,(s10),-8,0
    c3a6:	86a6                	mv	a3,s1
    c3a8:	415c0633          	sub	a2,s8,s5
    c3ac:	85ca                	mv	a1,s2
    c3ae:	9402                	jalr	s0
    c3b0:	fffd4503          	lbu	a0,-1(s10)
    c3b4:	86a6                	mv	a3,s1
    c3b6:	41ac0633          	sub	a2,s8,s10
    c3ba:	85ca                	mv	a1,s2
    c3bc:	9402                	jalr	s0
    c3be:	fffd0513          	addi	a0,s10,-1
    c3c2:	f8ac90e3          	bne	s9,a0,c342 <_vsnprintf+0x3772>
    c3c6:	68e2                	ld	a7,24(sp)
    c3c8:	7b02                	ld	s6,32(sp)
    c3ca:	8e5e                	mv	t3,s7
    c3cc:	000b1463          	bnez	s6,c3d4 <_vsnprintf+0x3804>
    c3d0:	8bcfe06f          	j	a48c <_vsnprintf+0x18bc>
    c3d4:	7c08bc0b          	th.extu	s8,a7,31,0
    c3d8:	6882                	ld	a7,0(sp)
    c3da:	411e0ab3          	sub	s5,t3,a7
    c3de:	018ae463          	bltu	s5,s8,c3e6 <_vsnprintf+0x3816>
    c3e2:	8aafe06f          	j	a48c <_vsnprintf+0x18bc>
    c3e6:	fffac693          	not	a3,s5
    c3ea:	01868fb3          	add	t6,a3,s8
    c3ee:	8672                	mv	a2,t3
    c3f0:	86a6                	mv	a3,s1
    c3f2:	85ca                	mv	a1,s2
    c3f4:	02000513          	li	a0,32
    c3f8:	e072                	sd	t3,0(sp)
    c3fa:	007ffb93          	andi	s7,t6,7
    c3fe:	001e0b13          	addi	s6,t3,1
    c402:	001a8c93          	addi	s9,s5,1
    c406:	9402                	jalr	s0
    c408:	6f02                	ld	t5,0(sp)
    c40a:	018ce463          	bltu	s9,s8,c412 <_vsnprintf+0x3842>
    c40e:	892fe06f          	j	a4a0 <_vsnprintf+0x18d0>
    c412:	0a0b8263          	beqz	s7,c4b6 <_vsnprintf+0x38e6>
    c416:	4705                	li	a4,1
    c418:	08eb8363          	beq	s7,a4,c49e <_vsnprintf+0x38ce>
    c41c:	4809                	li	a6,2
    c41e:	070b8863          	beq	s7,a6,c48e <_vsnprintf+0x38be>
    c422:	428d                	li	t0,3
    c424:	045b8d63          	beq	s7,t0,c47e <_vsnprintf+0x38ae>
    c428:	4311                	li	t1,4
    c42a:	046b8263          	beq	s7,t1,c46e <_vsnprintf+0x389e>
    c42e:	4e15                	li	t3,5
    c430:	03cb8763          	beq	s7,t3,c45e <_vsnprintf+0x388e>
    c434:	4619                	li	a2,6
    c436:	00cb8c63          	beq	s7,a2,c44e <_vsnprintf+0x387e>
    c43a:	865a                	mv	a2,s6
    c43c:	86a6                	mv	a3,s1
    c43e:	85ca                	mv	a1,s2
    c440:	02000513          	li	a0,32
    c444:	002f0b13          	addi	s6,t5,2
    c448:	002a8c93          	addi	s9,s5,2
    c44c:	9402                	jalr	s0
    c44e:	865a                	mv	a2,s6
    c450:	86a6                	mv	a3,s1
    c452:	85ca                	mv	a1,s2
    c454:	02000513          	li	a0,32
    c458:	0b05                	addi	s6,s6,1
    c45a:	9402                	jalr	s0
    c45c:	0c85                	addi	s9,s9,1
    c45e:	865a                	mv	a2,s6
    c460:	86a6                	mv	a3,s1
    c462:	85ca                	mv	a1,s2
    c464:	02000513          	li	a0,32
    c468:	0b05                	addi	s6,s6,1
    c46a:	9402                	jalr	s0
    c46c:	0c85                	addi	s9,s9,1
    c46e:	865a                	mv	a2,s6
    c470:	86a6                	mv	a3,s1
    c472:	85ca                	mv	a1,s2
    c474:	02000513          	li	a0,32
    c478:	0b05                	addi	s6,s6,1
    c47a:	9402                	jalr	s0
    c47c:	0c85                	addi	s9,s9,1
    c47e:	865a                	mv	a2,s6
    c480:	86a6                	mv	a3,s1
    c482:	85ca                	mv	a1,s2
    c484:	02000513          	li	a0,32
    c488:	0b05                	addi	s6,s6,1
    c48a:	9402                	jalr	s0
    c48c:	0c85                	addi	s9,s9,1
    c48e:	865a                	mv	a2,s6
    c490:	86a6                	mv	a3,s1
    c492:	85ca                	mv	a1,s2
    c494:	02000513          	li	a0,32
    c498:	0b05                	addi	s6,s6,1
    c49a:	9402                	jalr	s0
    c49c:	0c85                	addi	s9,s9,1
    c49e:	865a                	mv	a2,s6
    c4a0:	86a6                	mv	a3,s1
    c4a2:	85ca                	mv	a1,s2
    c4a4:	02000513          	li	a0,32
    c4a8:	0c85                	addi	s9,s9,1
    c4aa:	0b05                	addi	s6,s6,1
    c4ac:	9402                	jalr	s0
    c4ae:	018ce463          	bltu	s9,s8,c4b6 <_vsnprintf+0x38e6>
    c4b2:	feffd06f          	j	a4a0 <_vsnprintf+0x18d0>
    c4b6:	865a                	mv	a2,s6
    c4b8:	86a6                	mv	a3,s1
    c4ba:	85ca                	mv	a1,s2
    c4bc:	02000513          	li	a0,32
    c4c0:	9402                	jalr	s0
    c4c2:	001b0d13          	addi	s10,s6,1
    c4c6:	866a                	mv	a2,s10
    c4c8:	86a6                	mv	a3,s1
    c4ca:	85ca                	mv	a1,s2
    c4cc:	02000513          	li	a0,32
    c4d0:	9402                	jalr	s0
    c4d2:	002b0b93          	addi	s7,s6,2
    c4d6:	865e                	mv	a2,s7
    c4d8:	86a6                	mv	a3,s1
    c4da:	85ca                	mv	a1,s2
    c4dc:	02000513          	li	a0,32
    c4e0:	9402                	jalr	s0
    c4e2:	003b0a93          	addi	s5,s6,3
    c4e6:	8656                	mv	a2,s5
    c4e8:	86a6                	mv	a3,s1
    c4ea:	85ca                	mv	a1,s2
    c4ec:	02000513          	li	a0,32
    c4f0:	9402                	jalr	s0
    c4f2:	004b0d13          	addi	s10,s6,4
    c4f6:	866a                	mv	a2,s10
    c4f8:	86a6                	mv	a3,s1
    c4fa:	85ca                	mv	a1,s2
    c4fc:	02000513          	li	a0,32
    c500:	9402                	jalr	s0
    c502:	005b0a93          	addi	s5,s6,5
    c506:	86a6                	mv	a3,s1
    c508:	8656                	mv	a2,s5
    c50a:	85ca                	mv	a1,s2
    c50c:	02000513          	li	a0,32
    c510:	9402                	jalr	s0
    c512:	006b0b93          	addi	s7,s6,6
    c516:	86a6                	mv	a3,s1
    c518:	865e                	mv	a2,s7
    c51a:	85ca                	mv	a1,s2
    c51c:	02000513          	li	a0,32
    c520:	9402                	jalr	s0
    c522:	007b0d13          	addi	s10,s6,7
    c526:	86a6                	mv	a3,s1
    c528:	866a                	mv	a2,s10
    c52a:	85ca                	mv	a1,s2
    c52c:	02000513          	li	a0,32
    c530:	0ca1                	addi	s9,s9,8
    c532:	0b21                	addi	s6,s6,8
    c534:	9402                	jalr	s0
    c536:	f98ce0e3          	bltu	s9,s8,c4b6 <_vsnprintf+0x38e6>
    c53a:	f67fd06f          	j	a4a0 <_vsnprintf+0x18d0>
    c53e:	0001                	nop
    c540:	5c088be3          	beqz	a7,d316 <_vsnprintf+0x4746>
    c544:	001aff93          	andi	t6,s5,1
    c548:	000f9463          	bnez	t6,c550 <_vsnprintf+0x3980>
    c54c:	3d10106f          	j	e11c <_vsnprintf+0x554c>
    c550:	000e4463          	bltz	t3,c558 <_vsnprintf+0x3988>
    c554:	07a0206f          	j	e5ce <_vsnprintf+0x59fe>
    c558:	7c0c3c0b          	th.extu	s8,s8,31,0
    c55c:	38fd                	addiw	a7,a7,-1
    c55e:	0187e463          	bltu	a5,s8,c566 <_vsnprintf+0x3996>
    c562:	0d70206f          	j	ee38 <_vsnprintf+0x6268>
    c566:	02000393          	li	t2,32
    c56a:	40f38f33          	sub	t5,t2,a5
    c56e:	007f7313          	andi	t1,t5,7
    c572:	00fb86b3          	add	a3,s7,a5
    c576:	03000b13          	li	s6,48
    c57a:	06030763          	beqz	t1,c5e8 <_vsnprintf+0x3a18>
    c57e:	0785                	addi	a5,a5,1
    c580:	1816db0b          	th.sbia	s6,(a3),1,0
    c584:	0d87f463          	bgeu	a5,s8,c64c <_vsnprintf+0x3a7c>
    c588:	4805                	li	a6,1
    c58a:	05030f63          	beq	t1,a6,c5e8 <_vsnprintf+0x3a18>
    c58e:	4e89                	li	t4,2
    c590:	05d30763          	beq	t1,t4,c5de <_vsnprintf+0x3a0e>
    c594:	450d                	li	a0,3
    c596:	02a30f63          	beq	t1,a0,c5d4 <_vsnprintf+0x3a04>
    c59a:	4611                	li	a2,4
    c59c:	02c30763          	beq	t1,a2,c5ca <_vsnprintf+0x39fa>
    c5a0:	4c95                	li	s9,5
    c5a2:	01930f63          	beq	t1,s9,c5c0 <_vsnprintf+0x39f0>
    c5a6:	4719                	li	a4,6
    c5a8:	00e30763          	beq	t1,a4,c5b6 <_vsnprintf+0x39e6>
    c5ac:	0785                	addi	a5,a5,1
    c5ae:	1816db0b          	th.sbia	s6,(a3),1,0
    c5b2:	0987fd63          	bgeu	a5,s8,c64c <_vsnprintf+0x3a7c>
    c5b6:	0785                	addi	a5,a5,1
    c5b8:	1816db0b          	th.sbia	s6,(a3),1,0
    c5bc:	0987f863          	bgeu	a5,s8,c64c <_vsnprintf+0x3a7c>
    c5c0:	0785                	addi	a5,a5,1
    c5c2:	1816db0b          	th.sbia	s6,(a3),1,0
    c5c6:	0987f363          	bgeu	a5,s8,c64c <_vsnprintf+0x3a7c>
    c5ca:	0785                	addi	a5,a5,1
    c5cc:	1816db0b          	th.sbia	s6,(a3),1,0
    c5d0:	0787fe63          	bgeu	a5,s8,c64c <_vsnprintf+0x3a7c>
    c5d4:	0785                	addi	a5,a5,1
    c5d6:	1816db0b          	th.sbia	s6,(a3),1,0
    c5da:	0787f963          	bgeu	a5,s8,c64c <_vsnprintf+0x3a7c>
    c5de:	0785                	addi	a5,a5,1
    c5e0:	1816db0b          	th.sbia	s6,(a3),1,0
    c5e4:	0787f463          	bgeu	a5,s8,c64c <_vsnprintf+0x3a7c>
    c5e8:	50778ce3          	beq	a5,t2,d300 <_vsnprintf+0x4730>
    c5ec:	0785                	addi	a5,a5,1
    c5ee:	01668023          	sb	s6,0(a3)
    c5f2:	8abe                	mv	s5,a5
    c5f4:	0587fc63          	bgeu	a5,s8,c64c <_vsnprintf+0x3a7c>
    c5f8:	0785                	addi	a5,a5,1
    c5fa:	016680a3          	sb	s6,1(a3)
    c5fe:	0587f763          	bgeu	a5,s8,c64c <_vsnprintf+0x3a7c>
    c602:	002a8793          	addi	a5,s5,2
    c606:	01668123          	sb	s6,2(a3)
    c60a:	0587f163          	bgeu	a5,s8,c64c <_vsnprintf+0x3a7c>
    c60e:	003a8793          	addi	a5,s5,3
    c612:	016681a3          	sb	s6,3(a3)
    c616:	0387fb63          	bgeu	a5,s8,c64c <_vsnprintf+0x3a7c>
    c61a:	004a8793          	addi	a5,s5,4
    c61e:	01668223          	sb	s6,4(a3)
    c622:	0387f563          	bgeu	a5,s8,c64c <_vsnprintf+0x3a7c>
    c626:	005a8793          	addi	a5,s5,5
    c62a:	016682a3          	sb	s6,5(a3)
    c62e:	0187ff63          	bgeu	a5,s8,c64c <_vsnprintf+0x3a7c>
    c632:	006a8793          	addi	a5,s5,6
    c636:	01668323          	sb	s6,6(a3)
    c63a:	0187f963          	bgeu	a5,s8,c64c <_vsnprintf+0x3a7c>
    c63e:	016683a3          	sb	s6,7(a3)
    c642:	007a8793          	addi	a5,s5,7
    c646:	06a1                	addi	a3,a3,8
    c648:	fb87e0e3          	bltu	a5,s8,c5e8 <_vsnprintf+0x3a18>
    c64c:	0e0f8b63          	beqz	t6,c742 <_vsnprintf+0x3b72>
    c650:	7c08bf8b          	th.extu	t6,a7,31,0
    c654:	01f7e463          	bltu	a5,t6,c65c <_vsnprintf+0x3a8c>
    c658:	12d0206f          	j	ef84 <_vsnprintf+0x63b4>
    c65c:	02000293          	li	t0,32
    c660:	40f28d33          	sub	s10,t0,a5
    c664:	007d7393          	andi	t2,s10,7
    c668:	00fb8cb3          	add	s9,s7,a5
    c66c:	03000c13          	li	s8,48
    c670:	06038763          	beqz	t2,c6de <_vsnprintf+0x3b0e>
    c674:	0785                	addi	a5,a5,1
    c676:	181cdc0b          	th.sbia	s8,(s9),1,0
    c67a:	0df78463          	beq	a5,t6,c742 <_vsnprintf+0x3b72>
    c67e:	4b05                	li	s6,1
    c680:	05638f63          	beq	t2,s6,c6de <_vsnprintf+0x3b0e>
    c684:	4f09                	li	t5,2
    c686:	05e38763          	beq	t2,t5,c6d4 <_vsnprintf+0x3b04>
    c68a:	430d                	li	t1,3
    c68c:	02638f63          	beq	t2,t1,c6ca <_vsnprintf+0x3afa>
    c690:	4811                	li	a6,4
    c692:	03038763          	beq	t2,a6,c6c0 <_vsnprintf+0x3af0>
    c696:	4e95                	li	t4,5
    c698:	01d38f63          	beq	t2,t4,c6b6 <_vsnprintf+0x3ae6>
    c69c:	4519                	li	a0,6
    c69e:	00a38763          	beq	t2,a0,c6ac <_vsnprintf+0x3adc>
    c6a2:	0785                	addi	a5,a5,1
    c6a4:	181cdc0b          	th.sbia	s8,(s9),1,0
    c6a8:	09f78d63          	beq	a5,t6,c742 <_vsnprintf+0x3b72>
    c6ac:	0785                	addi	a5,a5,1
    c6ae:	181cdc0b          	th.sbia	s8,(s9),1,0
    c6b2:	09f78863          	beq	a5,t6,c742 <_vsnprintf+0x3b72>
    c6b6:	0785                	addi	a5,a5,1
    c6b8:	181cdc0b          	th.sbia	s8,(s9),1,0
    c6bc:	09f78363          	beq	a5,t6,c742 <_vsnprintf+0x3b72>
    c6c0:	0785                	addi	a5,a5,1
    c6c2:	181cdc0b          	th.sbia	s8,(s9),1,0
    c6c6:	07f78e63          	beq	a5,t6,c742 <_vsnprintf+0x3b72>
    c6ca:	0785                	addi	a5,a5,1
    c6cc:	181cdc0b          	th.sbia	s8,(s9),1,0
    c6d0:	07f78963          	beq	a5,t6,c742 <_vsnprintf+0x3b72>
    c6d4:	0785                	addi	a5,a5,1
    c6d6:	181cdc0b          	th.sbia	s8,(s9),1,0
    c6da:	07f78463          	beq	a5,t6,c742 <_vsnprintf+0x3b72>
    c6de:	3e578ae3          	beq	a5,t0,d2d2 <_vsnprintf+0x4702>
    c6e2:	0785                	addi	a5,a5,1
    c6e4:	018c8023          	sb	s8,0(s9)
    c6e8:	863e                	mv	a2,a5
    c6ea:	05f78c63          	beq	a5,t6,c742 <_vsnprintf+0x3b72>
    c6ee:	0785                	addi	a5,a5,1
    c6f0:	018c80a3          	sb	s8,1(s9)
    c6f4:	05f78763          	beq	a5,t6,c742 <_vsnprintf+0x3b72>
    c6f8:	00260793          	addi	a5,a2,2
    c6fc:	018c8123          	sb	s8,2(s9)
    c700:	05f78163          	beq	a5,t6,c742 <_vsnprintf+0x3b72>
    c704:	00360793          	addi	a5,a2,3
    c708:	018c81a3          	sb	s8,3(s9)
    c70c:	03f78b63          	beq	a5,t6,c742 <_vsnprintf+0x3b72>
    c710:	00460793          	addi	a5,a2,4
    c714:	018c8223          	sb	s8,4(s9)
    c718:	03f78563          	beq	a5,t6,c742 <_vsnprintf+0x3b72>
    c71c:	00560793          	addi	a5,a2,5
    c720:	018c82a3          	sb	s8,5(s9)
    c724:	01f78f63          	beq	a5,t6,c742 <_vsnprintf+0x3b72>
    c728:	00660793          	addi	a5,a2,6
    c72c:	018c8323          	sb	s8,6(s9)
    c730:	01f78963          	beq	a5,t6,c742 <_vsnprintf+0x3b72>
    c734:	018c83a3          	sb	s8,7(s9)
    c738:	00760793          	addi	a5,a2,7
    c73c:	0ca1                	addi	s9,s9,8
    c73e:	fbf790e3          	bne	a5,t6,c6de <_vsnprintf+0x3b0e>
    c742:	02000713          	li	a4,32
    c746:	38e786e3          	beq	a5,a4,d2d2 <_vsnprintf+0x4702>
    c74a:	000e4463          	bltz	t3,c752 <_vsnprintf+0x3b82>
    c74e:	2530106f          	j	e1a0 <_vsnprintf+0x55d0>
    c752:	00278e33          	add	t3,a5,sp
    c756:	02d00513          	li	a0,45
    c75a:	02ae0823          	sb	a0,48(t3)
    c75e:	0035f613          	andi	a2,a1,3
    c762:	00178c13          	addi	s8,a5,1
    c766:	c219                	beqz	a2,c76c <_vsnprintf+0x3b9c>
    c768:	57e0206f          	j	ece6 <_vsnprintf+0x6116>
    c76c:	7c08bd0b          	th.extu	s10,a7,31,0
    c770:	4b01                	li	s6,0
    c772:	1bac67e3          	bltu	s8,s10,d120 <_vsnprintf+0x4550>
    c776:	6302                	ld	t1,0(sp)
    c778:	02d00513          	li	a0,45
    c77c:	cdafe06f          	j	ac56 <_vsnprintf+0x2086>
    c780:	8f32                	mv	t5,a2
    c782:	fe367e13          	andi	t3,a2,-29
    c786:	5c0b98e3          	bnez	s7,d556 <_vsnprintf+0x4986>
    c78a:	4e81                	li	t4,0
    c78c:	ecefd06f          	j	9e5a <_vsnprintf+0x128a>
    c790:	8aee                	mv	s5,s11
    c792:	788acd0b          	th.ldia	s10,(s5),8,0
    c796:	010ffe93          	andi	t4,t6,16
    c79a:	000d1963          	bnez	s10,c7ac <_vsnprintf+0x3bdc>
    c79e:	fefffd93          	andi	s11,t6,-17
    c7a2:	000d861b          	sext.w	a2,s11
    c7a6:	320b9063          	bnez	s7,cac6 <_vsnprintf+0x3ef6>
    c7aa:	4e81                	li	t4,0
    c7ac:	02fd5333          	divu	t1,s10,a5
    c7b0:	83ea                	mv	t2,s10
    c7b2:	14563f0b          	th.extu	t5,a2,5,5
    c7b6:	ffff0f93          	addi	t6,t5,-1
    c7ba:	020ff713          	andi	a4,t6,32
    c7be:	0377051b          	addiw	a0,a4,55
    c7c2:	4e25                	li	t3,9
    c7c4:	03010b13          	addi	s6,sp,48
    c7c8:	85da                	mv	a1,s6
    c7ca:	22f3138b          	th.muls	t2,t1,a5
    c7ce:	0ff3fc93          	zext.b	s9,t2
    c7d2:	030c829b          	addiw	t0,s9,48
    c7d6:	01950f3b          	addw	t5,a0,s9
    c7da:	0ff2fd93          	zext.b	s11,t0
    c7de:	0fff7713          	zext.b	a4,t5
    c7e2:	007e3fb3          	sltu	t6,t3,t2
    c7e6:	41fd970b          	th.mveqz	a4,s11,t6
    c7ea:	02e10823          	sb	a4,48(sp)
    c7ee:	14fd6763          	bltu	s10,a5,c93c <_vsnprintf+0x3d6c>
    c7f2:	03110593          	addi	a1,sp,49
    c7f6:	829a                	mv	t0,t1
    c7f8:	02f2dd33          	divu	s10,t0,a5
    c7fc:	8316                	mv	t1,t0
    c7fe:	22fd130b          	th.muls	t1,s10,a5
    c802:	0ff37393          	zext.b	t2,t1
    c806:	03038c9b          	addiw	s9,t2,48
    c80a:	00750f3b          	addw	t5,a0,t2
    c80e:	0ffcfd93          	zext.b	s11,s9
    c812:	0fff7713          	zext.b	a4,t5
    c816:	006e3fb3          	sltu	t6,t3,t1
    c81a:	41fd970b          	th.mveqz	a4,s11,t6
    c81e:	00e58023          	sb	a4,0(a1)
    c822:	10f2ed63          	bltu	t0,a5,c93c <_vsnprintf+0x3d6c>
    c826:	00158c93          	addi	s9,a1,1
    c82a:	05010293          	addi	t0,sp,80
    c82e:	11928763          	beq	t0,s9,c93c <_vsnprintf+0x3d6c>
    c832:	02fd5db3          	divu	s11,s10,a5
    c836:	836a                	mv	t1,s10
    c838:	85e6                	mv	a1,s9
    c83a:	22fd930b          	th.muls	t1,s11,a5
    c83e:	0ff37f13          	zext.b	t5,t1
    c842:	030f039b          	addiw	t2,t5,48
    c846:	01e5073b          	addw	a4,a0,t5
    c84a:	0ff3ff93          	zext.b	t6,t2
    c84e:	0ff77f13          	zext.b	t5,a4
    c852:	006e32b3          	sltu	t0,t3,t1
    c856:	405f9f0b          	th.mveqz	t5,t6,t0
    c85a:	01ec8023          	sb	t5,0(s9)
    c85e:	0cfd6f63          	bltu	s10,a5,c93c <_vsnprintf+0x3d6c>
    c862:	02fddd33          	divu	s10,s11,a5
    c866:	836e                	mv	t1,s11
    c868:	22fd130b          	th.muls	t1,s10,a5
    c86c:	0ff37f93          	zext.b	t6,t1
    c870:	030f839b          	addiw	t2,t6,48
    c874:	01f5073b          	addw	a4,a0,t6
    c878:	0ff3ff13          	zext.b	t5,t2
    c87c:	0ff77f93          	zext.b	t6,a4
    c880:	006e32b3          	sltu	t0,t3,t1
    c884:	405f1f8b          	th.mveqz	t6,t5,t0
    c888:	0815df8b          	th.sbib	t6,(a1),1,0
    c88c:	0afde863          	bltu	s11,a5,c93c <_vsnprintf+0x3d6c>
    c890:	02fd5db3          	divu	s11,s10,a5
    c894:	836a                	mv	t1,s10
    c896:	002c8593          	addi	a1,s9,2
    c89a:	22fd930b          	th.muls	t1,s11,a5
    c89e:	0ff37f13          	zext.b	t5,t1
    c8a2:	030f039b          	addiw	t2,t5,48
    c8a6:	01e5073b          	addw	a4,a0,t5
    c8aa:	0ff3ff93          	zext.b	t6,t2
    c8ae:	0ff77f13          	zext.b	t5,a4
    c8b2:	006e32b3          	sltu	t0,t3,t1
    c8b6:	405f9f0b          	th.mveqz	t5,t6,t0
    c8ba:	01ec8123          	sb	t5,2(s9)
    c8be:	06fd6f63          	bltu	s10,a5,c93c <_vsnprintf+0x3d6c>
    c8c2:	02fdd2b3          	divu	t0,s11,a5
    c8c6:	8d6e                	mv	s10,s11
    c8c8:	003c8593          	addi	a1,s9,3
    c8cc:	22f29d0b          	th.muls	s10,t0,a5
    c8d0:	0ffd7313          	zext.b	t1,s10
    c8d4:	0303039b          	addiw	t2,t1,48
    c8d8:	0065073b          	addw	a4,a0,t1
    c8dc:	0ff3ff93          	zext.b	t6,t2
    c8e0:	0ff77f13          	zext.b	t5,a4
    c8e4:	01ae3d33          	sltu	s10,t3,s10
    c8e8:	41af9f0b          	th.mveqz	t5,t6,s10
    c8ec:	01ec81a3          	sb	t5,3(s9)
    c8f0:	04fde663          	bltu	s11,a5,c93c <_vsnprintf+0x3d6c>
    c8f4:	004c8593          	addi	a1,s9,4
    c8f8:	b701                	j	c7f8 <_vsnprintf+0x3c28>
    c8fa:	02000e13          	li	t3,32
    c8fe:	01cc0463          	beq	s8,t3,c906 <_vsnprintf+0x3d36>
    c902:	04c0206f          	j	e94e <_vsnprintf+0x5d7e>
    c906:	04f14503          	lbu	a0,79(sp)
    c90a:	810fd06f          	j	991a <_vsnprintf+0xd4a>
    c90e:	4b89                	li	s7,2
    c910:	4ac1                	li	s5,16
    c912:	02000c93          	li	s9,32
    c916:	019d1463          	bne	s10,s9,c91e <_vsnprintf+0x3d4e>
    c91a:	fabfd06f          	j	a8c4 <_vsnprintf+0x1cf4>
    c91e:	001d0793          	addi	a5,s10,1
    c922:	9d66                	add	s10,s10,s9
    c924:	002d0e33          	add	t3,s10,sp
    c928:	05800e93          	li	t4,88
    c92c:	01de0823          	sb	t4,16(t3)
    c930:	01979463          	bne	a5,s9,c938 <_vsnprintf+0x3d68>
    c934:	f91fd06f          	j	a8c4 <_vsnprintf+0x1cf4>
    c938:	b21fe06f          	j	b458 <_vsnprintf+0x2888>
    c93c:	416585b3          	sub	a1,a1,s6
    c940:	00267793          	andi	a5,a2,2
    c944:	00158d13          	addi	s10,a1,1
    c948:	8e32                	mv	t3,a2
    c94a:	60078be3          	beqz	a5,d760 <_vsnprintf+0x4b90>
    c94e:	000e8463          	beqz	t4,c956 <_vsnprintf+0x3d86>
    c952:	4b70106f          	j	e608 <_vsnprintf+0x5a38>
    c956:	02000693          	li	a3,32
    c95a:	4809                	li	a6,2
    c95c:	00dd0463          	beq	s10,a3,c964 <_vsnprintf+0x3d94>
    c960:	7550106f          	j	e8b4 <_vsnprintf+0x5ce4>
    c964:	6382                	ld	t2,0(sp)
    c966:	8bc2                	mv	s7,a6
    c968:	02000d13          	li	s10,32
    c96c:	007d0cb3          	add	s9,s10,t2
    c970:	01ab0c33          	add	s8,s6,s10
    c974:	007d7d13          	andi	s10,s10,7
    c978:	019b0db3          	add	s11,s6,s9
    c97c:	0a0d0763          	beqz	s10,ca2a <_vsnprintf+0x3e5a>
    c980:	4805                	li	a6,1
    c982:	090d0763          	beq	s10,a6,ca10 <_vsnprintf+0x3e40>
    c986:	4309                	li	t1,2
    c988:	066d0b63          	beq	s10,t1,c9fe <_vsnprintf+0x3e2e>
    c98c:	468d                	li	a3,3
    c98e:	04dd0f63          	beq	s10,a3,c9ec <_vsnprintf+0x3e1c>
    c992:	4e11                	li	t3,4
    c994:	05cd0363          	beq	s10,t3,c9da <_vsnprintf+0x3e0a>
    c998:	4295                	li	t0,5
    c99a:	025d0763          	beq	s10,t0,c9c8 <_vsnprintf+0x3df8>
    c99e:	4f99                	li	t6,6
    c9a0:	01fd0b63          	beq	s10,t6,c9b6 <_vsnprintf+0x3de6>
    c9a4:	418d8633          	sub	a2,s11,s8
    c9a8:	89fc450b          	th.lbuib	a0,(s8),-1,0
    c9ac:	ec46                	sd	a7,24(sp)
    c9ae:	86a6                	mv	a3,s1
    c9b0:	85ca                	mv	a1,s2
    c9b2:	9402                	jalr	s0
    c9b4:	68e2                	ld	a7,24(sp)
    c9b6:	418d8633          	sub	a2,s11,s8
    c9ba:	89fc450b          	th.lbuib	a0,(s8),-1,0
    c9be:	ec46                	sd	a7,24(sp)
    c9c0:	86a6                	mv	a3,s1
    c9c2:	85ca                	mv	a1,s2
    c9c4:	9402                	jalr	s0
    c9c6:	68e2                	ld	a7,24(sp)
    c9c8:	418d8633          	sub	a2,s11,s8
    c9cc:	89fc450b          	th.lbuib	a0,(s8),-1,0
    c9d0:	ec46                	sd	a7,24(sp)
    c9d2:	86a6                	mv	a3,s1
    c9d4:	85ca                	mv	a1,s2
    c9d6:	9402                	jalr	s0
    c9d8:	68e2                	ld	a7,24(sp)
    c9da:	418d8633          	sub	a2,s11,s8
    c9de:	89fc450b          	th.lbuib	a0,(s8),-1,0
    c9e2:	ec46                	sd	a7,24(sp)
    c9e4:	86a6                	mv	a3,s1
    c9e6:	85ca                	mv	a1,s2
    c9e8:	9402                	jalr	s0
    c9ea:	68e2                	ld	a7,24(sp)
    c9ec:	418d8633          	sub	a2,s11,s8
    c9f0:	89fc450b          	th.lbuib	a0,(s8),-1,0
    c9f4:	ec46                	sd	a7,24(sp)
    c9f6:	86a6                	mv	a3,s1
    c9f8:	85ca                	mv	a1,s2
    c9fa:	9402                	jalr	s0
    c9fc:	68e2                	ld	a7,24(sp)
    c9fe:	418d8633          	sub	a2,s11,s8
    ca02:	89fc450b          	th.lbuib	a0,(s8),-1,0
    ca06:	ec46                	sd	a7,24(sp)
    ca08:	86a6                	mv	a3,s1
    ca0a:	85ca                	mv	a1,s2
    ca0c:	9402                	jalr	s0
    ca0e:	68e2                	ld	a7,24(sp)
    ca10:	418d8633          	sub	a2,s11,s8
    ca14:	89fc450b          	th.lbuib	a0,(s8),-1,0
    ca18:	ec66                	sd	s9,24(sp)
    ca1a:	f046                	sd	a7,32(sp)
    ca1c:	86a6                	mv	a3,s1
    ca1e:	85ca                	mv	a1,s2
    ca20:	9402                	jalr	s0
    ca22:	63e2                	ld	t2,24(sp)
    ca24:	7882                	ld	a7,32(sp)
    ca26:	098b0a63          	beq	s6,s8,caba <_vsnprintf+0x3eea>
    ca2a:	ec56                	sd	s5,24(sp)
    ca2c:	f05e                	sd	s7,32(sp)
    ca2e:	8bc6                	mv	s7,a7
    ca30:	8d62                	mv	s10,s8
    ca32:	89fd450b          	th.lbuib	a0,(s10),-1,0
    ca36:	418d8633          	sub	a2,s11,s8
    ca3a:	86a6                	mv	a3,s1
    ca3c:	85ca                	mv	a1,s2
    ca3e:	9402                	jalr	s0
    ca40:	8ae2                	mv	s5,s8
    ca42:	89eac50b          	th.lbuib	a0,(s5),-2,0
    ca46:	41ad8633          	sub	a2,s11,s10
    ca4a:	86a6                	mv	a3,s1
    ca4c:	85ca                	mv	a1,s2
    ca4e:	9402                	jalr	s0
    ca50:	8d62                	mv	s10,s8
    ca52:	89dd450b          	th.lbuib	a0,(s10),-3,0
    ca56:	415d8633          	sub	a2,s11,s5
    ca5a:	86a6                	mv	a3,s1
    ca5c:	85ca                	mv	a1,s2
    ca5e:	9402                	jalr	s0
    ca60:	8ae2                	mv	s5,s8
    ca62:	89cac50b          	th.lbuib	a0,(s5),-4,0
    ca66:	41ad8633          	sub	a2,s11,s10
    ca6a:	86a6                	mv	a3,s1
    ca6c:	85ca                	mv	a1,s2
    ca6e:	9402                	jalr	s0
    ca70:	8d62                	mv	s10,s8
    ca72:	89bd450b          	th.lbuib	a0,(s10),-5,0
    ca76:	415d8633          	sub	a2,s11,s5
    ca7a:	86a6                	mv	a3,s1
    ca7c:	85ca                	mv	a1,s2
    ca7e:	9402                	jalr	s0
    ca80:	8ae2                	mv	s5,s8
    ca82:	89aac50b          	th.lbuib	a0,(s5),-6,0
    ca86:	41ad8633          	sub	a2,s11,s10
    ca8a:	86a6                	mv	a3,s1
    ca8c:	85ca                	mv	a1,s2
    ca8e:	9402                	jalr	s0
    ca90:	8d62                	mv	s10,s8
    ca92:	899d450b          	th.lbuib	a0,(s10),-7,0
    ca96:	86a6                	mv	a3,s1
    ca98:	415d8633          	sub	a2,s11,s5
    ca9c:	85ca                	mv	a1,s2
    ca9e:	9402                	jalr	s0
    caa0:	898c450b          	th.lbuib	a0,(s8),-8,0
    caa4:	86a6                	mv	a3,s1
    caa6:	41ad8633          	sub	a2,s11,s10
    caaa:	85ca                	mv	a1,s2
    caac:	9402                	jalr	s0
    caae:	f98b11e3          	bne	s6,s8,ca30 <_vsnprintf+0x3e60>
    cab2:	88de                	mv	a7,s7
    cab4:	6ae2                	ld	s5,24(sp)
    cab6:	7b82                	ld	s7,32(sp)
    cab8:	83e6                	mv	t2,s9
    caba:	000b9d63          	bnez	s7,cad4 <_vsnprintf+0x3f04>
    cabe:	e01e                	sd	t2,0(sp)
    cac0:	8dd6                	mv	s11,s5
    cac2:	9e7fd06f          	j	a4a8 <_vsnprintf+0x18d8>
    cac6:	002ffe93          	andi	t4,t6,2
    caca:	000e9463          	bnez	t4,cad2 <_vsnprintf+0x3f02>
    cace:	37b0106f          	j	e648 <_vsnprintf+0x5a78>
    cad2:	6382                	ld	t2,0(sp)
    cad4:	6b02                	ld	s6,0(sp)
    cad6:	7c08bc0b          	th.extu	s8,a7,31,0
    cada:	41638db3          	sub	s11,t2,s6
    cade:	ff8df0e3          	bgeu	s11,s8,cabe <_vsnprintf+0x3eee>
    cae2:	fffdc513          	not	a0,s11
    cae6:	018508b3          	add	a7,a0,s8
    caea:	85ca                	mv	a1,s2
    caec:	86a6                	mv	a3,s1
    caee:	861e                	mv	a2,t2
    caf0:	02000513          	li	a0,32
    caf4:	e01e                	sd	t2,0(sp)
    caf6:	0078fb93          	andi	s7,a7,7
    cafa:	00138b13          	addi	s6,t2,1
    cafe:	001d8c93          	addi	s9,s11,1
    cb02:	9402                	jalr	s0
    cb04:	6582                	ld	a1,0(sp)
    cb06:	b98cfd63          	bgeu	s9,s8,bea0 <_vsnprintf+0x32d0>
    cb0a:	0a0b8063          	beqz	s7,cbaa <_vsnprintf+0x3fda>
    cb0e:	4705                	li	a4,1
    cb10:	08eb8363          	beq	s7,a4,cb96 <_vsnprintf+0x3fc6>
    cb14:	4789                	li	a5,2
    cb16:	06fb8863          	beq	s7,a5,cb86 <_vsnprintf+0x3fb6>
    cb1a:	460d                	li	a2,3
    cb1c:	04cb8d63          	beq	s7,a2,cb76 <_vsnprintf+0x3fa6>
    cb20:	4e91                	li	t4,4
    cb22:	05db8263          	beq	s7,t4,cb66 <_vsnprintf+0x3f96>
    cb26:	4815                	li	a6,5
    cb28:	030b8763          	beq	s7,a6,cb56 <_vsnprintf+0x3f86>
    cb2c:	4319                	li	t1,6
    cb2e:	006b8c63          	beq	s7,t1,cb46 <_vsnprintf+0x3f76>
    cb32:	865a                	mv	a2,s6
    cb34:	86a6                	mv	a3,s1
    cb36:	00258b13          	addi	s6,a1,2
    cb3a:	02000513          	li	a0,32
    cb3e:	85ca                	mv	a1,s2
    cb40:	9402                	jalr	s0
    cb42:	002d8c93          	addi	s9,s11,2
    cb46:	865a                	mv	a2,s6
    cb48:	86a6                	mv	a3,s1
    cb4a:	85ca                	mv	a1,s2
    cb4c:	02000513          	li	a0,32
    cb50:	0b05                	addi	s6,s6,1
    cb52:	9402                	jalr	s0
    cb54:	0c85                	addi	s9,s9,1
    cb56:	865a                	mv	a2,s6
    cb58:	86a6                	mv	a3,s1
    cb5a:	85ca                	mv	a1,s2
    cb5c:	02000513          	li	a0,32
    cb60:	0b05                	addi	s6,s6,1
    cb62:	9402                	jalr	s0
    cb64:	0c85                	addi	s9,s9,1
    cb66:	865a                	mv	a2,s6
    cb68:	86a6                	mv	a3,s1
    cb6a:	85ca                	mv	a1,s2
    cb6c:	02000513          	li	a0,32
    cb70:	0b05                	addi	s6,s6,1
    cb72:	9402                	jalr	s0
    cb74:	0c85                	addi	s9,s9,1
    cb76:	865a                	mv	a2,s6
    cb78:	86a6                	mv	a3,s1
    cb7a:	85ca                	mv	a1,s2
    cb7c:	02000513          	li	a0,32
    cb80:	0b05                	addi	s6,s6,1
    cb82:	9402                	jalr	s0
    cb84:	0c85                	addi	s9,s9,1
    cb86:	865a                	mv	a2,s6
    cb88:	86a6                	mv	a3,s1
    cb8a:	85ca                	mv	a1,s2
    cb8c:	02000513          	li	a0,32
    cb90:	0b05                	addi	s6,s6,1
    cb92:	9402                	jalr	s0
    cb94:	0c85                	addi	s9,s9,1
    cb96:	865a                	mv	a2,s6
    cb98:	86a6                	mv	a3,s1
    cb9a:	85ca                	mv	a1,s2
    cb9c:	02000513          	li	a0,32
    cba0:	0c85                	addi	s9,s9,1
    cba2:	0b05                	addi	s6,s6,1
    cba4:	9402                	jalr	s0
    cba6:	af8cfd63          	bgeu	s9,s8,bea0 <_vsnprintf+0x32d0>
    cbaa:	865a                	mv	a2,s6
    cbac:	86a6                	mv	a3,s1
    cbae:	85ca                	mv	a1,s2
    cbb0:	02000513          	li	a0,32
    cbb4:	9402                	jalr	s0
    cbb6:	001b0d93          	addi	s11,s6,1
    cbba:	866e                	mv	a2,s11
    cbbc:	86a6                	mv	a3,s1
    cbbe:	85ca                	mv	a1,s2
    cbc0:	02000513          	li	a0,32
    cbc4:	9402                	jalr	s0
    cbc6:	002b0d13          	addi	s10,s6,2
    cbca:	866a                	mv	a2,s10
    cbcc:	86a6                	mv	a3,s1
    cbce:	85ca                	mv	a1,s2
    cbd0:	02000513          	li	a0,32
    cbd4:	9402                	jalr	s0
    cbd6:	003b0b93          	addi	s7,s6,3
    cbda:	865e                	mv	a2,s7
    cbdc:	86a6                	mv	a3,s1
    cbde:	85ca                	mv	a1,s2
    cbe0:	02000513          	li	a0,32
    cbe4:	9402                	jalr	s0
    cbe6:	004b0d93          	addi	s11,s6,4
    cbea:	866e                	mv	a2,s11
    cbec:	86a6                	mv	a3,s1
    cbee:	85ca                	mv	a1,s2
    cbf0:	02000513          	li	a0,32
    cbf4:	9402                	jalr	s0
    cbf6:	005b0b93          	addi	s7,s6,5
    cbfa:	86a6                	mv	a3,s1
    cbfc:	865e                	mv	a2,s7
    cbfe:	85ca                	mv	a1,s2
    cc00:	02000513          	li	a0,32
    cc04:	9402                	jalr	s0
    cc06:	006b0d13          	addi	s10,s6,6
    cc0a:	86a6                	mv	a3,s1
    cc0c:	866a                	mv	a2,s10
    cc0e:	85ca                	mv	a1,s2
    cc10:	02000513          	li	a0,32
    cc14:	9402                	jalr	s0
    cc16:	007b0d93          	addi	s11,s6,7
    cc1a:	86a6                	mv	a3,s1
    cc1c:	866e                	mv	a2,s11
    cc1e:	85ca                	mv	a1,s2
    cc20:	02000513          	li	a0,32
    cc24:	0ca1                	addi	s9,s9,8
    cc26:	0b21                	addi	s6,s6,8
    cc28:	9402                	jalr	s0
    cc2a:	f98ce0e3          	bltu	s9,s8,cbaa <_vsnprintf+0x3fda>
    cc2e:	e05a                	sd	s6,0(sp)
    cc30:	a72ff06f          	j	bea2 <_vsnprintf+0x32d2>
    cc34:	30088be3          	beqz	a7,d74a <_vsnprintf+0x4b7a>
    cc38:	0016fd93          	andi	s11,a3,1
    cc3c:	000d8463          	beqz	s11,cc44 <_vsnprintf+0x4074>
    cc40:	4580106f          	j	e098 <_vsnprintf+0x54c8>
    cc44:	7c0c3c0b          	th.extu	s8,s8,31,0
    cc48:	a987e863          	bltu	a5,s8,bed8 <_vsnprintf+0x3308>
    cc4c:	02000e13          	li	t3,32
    cc50:	27c78ce3          	beq	a5,t3,d6c8 <_vsnprintf+0x4af8>
    cc54:	000ec463          	bltz	t4,cc5c <_vsnprintf+0x408c>
    cc58:	0410106f          	j	e498 <_vsnprintf+0x58c8>
    cc5c:	01c78633          	add	a2,a5,t3
    cc60:	03010f93          	addi	t6,sp,48
    cc64:	01f603b3          	add	t2,a2,t6
    cc68:	02d00713          	li	a4,45
    cc6c:	00178c13          	addi	s8,a5,1
    cc70:	fee38023          	sb	a4,-32(t2)
    cc74:	7c08bb8b          	th.extu	s7,a7,31,0
    cc78:	8dc2                	mv	s11,a6
    cc7a:	4b01                	li	s6,0
    cc7c:	017c6463          	bltu	s8,s7,cc84 <_vsnprintf+0x40b4>
    cc80:	6b30106f          	j	eb32 <_vsnprintf+0x5f62>
    cc84:	6602                	ld	a2,0(sp)
    cc86:	85ca                	mv	a1,s2
    cc88:	86a6                	mv	a3,s1
    cc8a:	40cc0cb3          	sub	s9,s8,a2
    cc8e:	fffcc393          	not	t2,s9
    cc92:	40c387b3          	sub	a5,t2,a2
    cc96:	01778eb3          	add	t4,a5,s7
    cc9a:	ec66                	sd	s9,24(sp)
    cc9c:	f046                	sd	a7,32(sp)
    cc9e:	02000513          	li	a0,32
    cca2:	00160d13          	addi	s10,a2,1
    cca6:	007efa93          	andi	s5,t4,7
    ccaa:	9402                	jalr	s0
    ccac:	01ac85b3          	add	a1,s9,s10
    ccb0:	7882                	ld	a7,32(sp)
    ccb2:	1575f563          	bgeu	a1,s7,cdfc <_vsnprintf+0x422c>
    ccb6:	0a0a8963          	beqz	s5,cd68 <_vsnprintf+0x4198>
    ccba:	4685                	li	a3,1
    ccbc:	08da8863          	beq	s5,a3,cd4c <_vsnprintf+0x417c>
    ccc0:	4f89                	li	t6,2
    ccc2:	07fa8c63          	beq	s5,t6,cd3a <_vsnprintf+0x416a>
    ccc6:	480d                	li	a6,3
    ccc8:	070a8063          	beq	s5,a6,cd28 <_vsnprintf+0x4158>
    cccc:	4711                	li	a4,4
    ccce:	04ea8463          	beq	s5,a4,cd16 <_vsnprintf+0x4146>
    ccd2:	4f15                	li	t5,5
    ccd4:	03ea8863          	beq	s5,t5,cd04 <_vsnprintf+0x4134>
    ccd8:	4299                	li	t0,6
    ccda:	005a8c63          	beq	s5,t0,ccf2 <_vsnprintf+0x4122>
    ccde:	866a                	mv	a2,s10
    cce0:	f046                	sd	a7,32(sp)
    cce2:	86a6                	mv	a3,s1
    cce4:	85ca                	mv	a1,s2
    cce6:	02000513          	li	a0,32
    ccea:	6d02                	ld	s10,0(sp)
    ccec:	9402                	jalr	s0
    ccee:	7882                	ld	a7,32(sp)
    ccf0:	0d09                	addi	s10,s10,2
    ccf2:	866a                	mv	a2,s10
    ccf4:	f046                	sd	a7,32(sp)
    ccf6:	86a6                	mv	a3,s1
    ccf8:	85ca                	mv	a1,s2
    ccfa:	02000513          	li	a0,32
    ccfe:	9402                	jalr	s0
    cd00:	7882                	ld	a7,32(sp)
    cd02:	0d05                	addi	s10,s10,1
    cd04:	866a                	mv	a2,s10
    cd06:	f046                	sd	a7,32(sp)
    cd08:	86a6                	mv	a3,s1
    cd0a:	85ca                	mv	a1,s2
    cd0c:	02000513          	li	a0,32
    cd10:	9402                	jalr	s0
    cd12:	7882                	ld	a7,32(sp)
    cd14:	0d05                	addi	s10,s10,1
    cd16:	866a                	mv	a2,s10
    cd18:	f046                	sd	a7,32(sp)
    cd1a:	86a6                	mv	a3,s1
    cd1c:	85ca                	mv	a1,s2
    cd1e:	02000513          	li	a0,32
    cd22:	9402                	jalr	s0
    cd24:	7882                	ld	a7,32(sp)
    cd26:	0d05                	addi	s10,s10,1
    cd28:	866a                	mv	a2,s10
    cd2a:	f046                	sd	a7,32(sp)
    cd2c:	86a6                	mv	a3,s1
    cd2e:	85ca                	mv	a1,s2
    cd30:	02000513          	li	a0,32
    cd34:	9402                	jalr	s0
    cd36:	7882                	ld	a7,32(sp)
    cd38:	0d05                	addi	s10,s10,1
    cd3a:	866a                	mv	a2,s10
    cd3c:	f046                	sd	a7,32(sp)
    cd3e:	86a6                	mv	a3,s1
    cd40:	85ca                	mv	a1,s2
    cd42:	02000513          	li	a0,32
    cd46:	9402                	jalr	s0
    cd48:	7882                	ld	a7,32(sp)
    cd4a:	0d05                	addi	s10,s10,1
    cd4c:	866a                	mv	a2,s10
    cd4e:	02000513          	li	a0,32
    cd52:	f046                	sd	a7,32(sp)
    cd54:	86a6                	mv	a3,s1
    cd56:	85ca                	mv	a1,s2
    cd58:	9402                	jalr	s0
    cd5a:	6362                	ld	t1,24(sp)
    cd5c:	7882                	ld	a7,32(sp)
    cd5e:	0d05                	addi	s10,s10,1
    cd60:	01a30533          	add	a0,t1,s10
    cd64:	09757c63          	bgeu	a0,s7,cdfc <_vsnprintf+0x422c>
    cd68:	f06e                	sd	s11,32(sp)
    cd6a:	8dda                	mv	s11,s6
    cd6c:	8b46                	mv	s6,a7
    cd6e:	866a                	mv	a2,s10
    cd70:	86a6                	mv	a3,s1
    cd72:	85ca                	mv	a1,s2
    cd74:	02000513          	li	a0,32
    cd78:	9402                	jalr	s0
    cd7a:	001d0a93          	addi	s5,s10,1
    cd7e:	8656                	mv	a2,s5
    cd80:	86a6                	mv	a3,s1
    cd82:	85ca                	mv	a1,s2
    cd84:	02000513          	li	a0,32
    cd88:	9402                	jalr	s0
    cd8a:	002d0c93          	addi	s9,s10,2
    cd8e:	8666                	mv	a2,s9
    cd90:	86a6                	mv	a3,s1
    cd92:	85ca                	mv	a1,s2
    cd94:	02000513          	li	a0,32
    cd98:	9402                	jalr	s0
    cd9a:	003d0a93          	addi	s5,s10,3
    cd9e:	8656                	mv	a2,s5
    cda0:	86a6                	mv	a3,s1
    cda2:	85ca                	mv	a1,s2
    cda4:	02000513          	li	a0,32
    cda8:	9402                	jalr	s0
    cdaa:	004d0c93          	addi	s9,s10,4
    cdae:	8666                	mv	a2,s9
    cdb0:	86a6                	mv	a3,s1
    cdb2:	85ca                	mv	a1,s2
    cdb4:	02000513          	li	a0,32
    cdb8:	9402                	jalr	s0
    cdba:	005d0a93          	addi	s5,s10,5
    cdbe:	8656                	mv	a2,s5
    cdc0:	86a6                	mv	a3,s1
    cdc2:	85ca                	mv	a1,s2
    cdc4:	02000513          	li	a0,32
    cdc8:	9402                	jalr	s0
    cdca:	006d0c93          	addi	s9,s10,6
    cdce:	86a6                	mv	a3,s1
    cdd0:	8666                	mv	a2,s9
    cdd2:	85ca                	mv	a1,s2
    cdd4:	02000513          	li	a0,32
    cdd8:	9402                	jalr	s0
    cdda:	007d0a93          	addi	s5,s10,7
    cdde:	86a6                	mv	a3,s1
    cde0:	8656                	mv	a2,s5
    cde2:	85ca                	mv	a1,s2
    cde4:	02000513          	li	a0,32
    cde8:	9402                	jalr	s0
    cdea:	68e2                	ld	a7,24(sp)
    cdec:	0d21                	addi	s10,s10,8
    cdee:	01a88e33          	add	t3,a7,s10
    cdf2:	f77e6ee3          	bltu	t3,s7,cd6e <_vsnprintf+0x419e>
    cdf6:	88da                	mv	a7,s6
    cdf8:	8b6e                	mv	s6,s11
    cdfa:	7d82                	ld	s11,32(sp)
    cdfc:	6682                	ld	a3,0(sp)
    cdfe:	fffb8613          	addi	a2,s7,-1
    ce02:	001c0793          	addi	a5,s8,1
    ce06:	418603b3          	sub	t2,a2,s8
    ce0a:	00fbbeb3          	sltu	t4,s7,a5
    ce0e:	43d0138b          	th.mvnez	t2,zero,t4
    ce12:	00168f93          	addi	t6,a3,1
    ce16:	01f38833          	add	a6,t2,t6
    ce1a:	8e42                	mv	t3,a6
    ce1c:	da0c0863          	beqz	s8,c3cc <_vsnprintf+0x37fc>
    ce20:	03010c93          	addi	s9,sp,48
    ce24:	019c0733          	add	a4,s8,s9
    ce28:	fff74503          	lbu	a0,-1(a4)
    ce2c:	c3eff06f          	j	c26a <_vsnprintf+0x369a>
    ce30:	54088fe3          	beqz	a7,db8e <_vsnprintf+0x4fbe>
    ce34:	00167b13          	andi	s6,a2,1
    ce38:	7c0c350b          	th.extu	a0,s8,31,0
    ce3c:	000b1463          	bnez	s6,ce44 <_vsnprintf+0x4274>
    ce40:	0e80106f          	j	df28 <_vsnprintf+0x5358>
    ce44:	0ea77763          	bgeu	a4,a0,cf32 <_vsnprintf+0x4362>
    ce48:	02000593          	li	a1,32
    ce4c:	40e582b3          	sub	t0,a1,a4
    ce50:	0072f393          	andi	t2,t0,7
    ce54:	00e80f33          	add	t5,a6,a4
    ce58:	03000f93          	li	t6,48
    ce5c:	06038763          	beqz	t2,ceca <_vsnprintf+0x42fa>
    ce60:	0705                	addi	a4,a4,1
    ce62:	181f5f8b          	th.sbia	t6,(t5),1,0
    ce66:	0ca77463          	bgeu	a4,a0,cf2e <_vsnprintf+0x435e>
    ce6a:	4a85                	li	s5,1
    ce6c:	05538f63          	beq	t2,s5,ceca <_vsnprintf+0x42fa>
    ce70:	4309                	li	t1,2
    ce72:	04638763          	beq	t2,t1,cec0 <_vsnprintf+0x42f0>
    ce76:	478d                	li	a5,3
    ce78:	02f38f63          	beq	t2,a5,ceb6 <_vsnprintf+0x42e6>
    ce7c:	4611                	li	a2,4
    ce7e:	02c38763          	beq	t2,a2,ceac <_vsnprintf+0x42dc>
    ce82:	4c95                	li	s9,5
    ce84:	01938f63          	beq	t2,s9,cea2 <_vsnprintf+0x42d2>
    ce88:	4299                	li	t0,6
    ce8a:	00538763          	beq	t2,t0,ce98 <_vsnprintf+0x42c8>
    ce8e:	0705                	addi	a4,a4,1
    ce90:	181f5f8b          	th.sbia	t6,(t5),1,0
    ce94:	08a77d63          	bgeu	a4,a0,cf2e <_vsnprintf+0x435e>
    ce98:	0705                	addi	a4,a4,1
    ce9a:	181f5f8b          	th.sbia	t6,(t5),1,0
    ce9e:	08a77863          	bgeu	a4,a0,cf2e <_vsnprintf+0x435e>
    cea2:	0705                	addi	a4,a4,1
    cea4:	181f5f8b          	th.sbia	t6,(t5),1,0
    cea8:	08a77363          	bgeu	a4,a0,cf2e <_vsnprintf+0x435e>
    ceac:	0705                	addi	a4,a4,1
    ceae:	181f5f8b          	th.sbia	t6,(t5),1,0
    ceb2:	06a77e63          	bgeu	a4,a0,cf2e <_vsnprintf+0x435e>
    ceb6:	0705                	addi	a4,a4,1
    ceb8:	181f5f8b          	th.sbia	t6,(t5),1,0
    cebc:	06a77963          	bgeu	a4,a0,cf2e <_vsnprintf+0x435e>
    cec0:	0705                	addi	a4,a4,1
    cec2:	181f5f8b          	th.sbia	t6,(t5),1,0
    cec6:	06a77463          	bgeu	a4,a0,cf2e <_vsnprintf+0x435e>
    ceca:	06b70263          	beq	a4,a1,cf2e <_vsnprintf+0x435e>
    cece:	0705                	addi	a4,a4,1
    ced0:	01ff0023          	sb	t6,0(t5)
    ced4:	83ba                	mv	t2,a4
    ced6:	04a77c63          	bgeu	a4,a0,cf2e <_vsnprintf+0x435e>
    ceda:	0705                	addi	a4,a4,1
    cedc:	01ff00a3          	sb	t6,1(t5)
    cee0:	04a77763          	bgeu	a4,a0,cf2e <_vsnprintf+0x435e>
    cee4:	00238713          	addi	a4,t2,2
    cee8:	01ff0123          	sb	t6,2(t5)
    ceec:	04a77163          	bgeu	a4,a0,cf2e <_vsnprintf+0x435e>
    cef0:	00338713          	addi	a4,t2,3
    cef4:	01ff01a3          	sb	t6,3(t5)
    cef8:	02a77b63          	bgeu	a4,a0,cf2e <_vsnprintf+0x435e>
    cefc:	00438713          	addi	a4,t2,4
    cf00:	01ff0223          	sb	t6,4(t5)
    cf04:	02a77563          	bgeu	a4,a0,cf2e <_vsnprintf+0x435e>
    cf08:	00538713          	addi	a4,t2,5
    cf0c:	01ff02a3          	sb	t6,5(t5)
    cf10:	00a77f63          	bgeu	a4,a0,cf2e <_vsnprintf+0x435e>
    cf14:	00638713          	addi	a4,t2,6
    cf18:	01ff0323          	sb	t6,6(t5)
    cf1c:	00a77963          	bgeu	a4,a0,cf2e <_vsnprintf+0x435e>
    cf20:	01ff03a3          	sb	t6,7(t5)
    cf24:	00738713          	addi	a4,t2,7
    cf28:	0f21                	addi	t5,t5,8
    cf2a:	faa760e3          	bltu	a4,a0,ceca <_vsnprintf+0x42fa>
    cf2e:	5a0b07e3          	beqz	s6,dcdc <_vsnprintf+0x510c>
    cf32:	7c08b78b          	th.extu	a5,a7,31,0
    cf36:	00f76463          	bltu	a4,a5,cf3e <_vsnprintf+0x436e>
    cf3a:	6e70106f          	j	ee20 <_vsnprintf+0x6250>
    cf3e:	02000b13          	li	s6,32
    cf42:	40eb0fb3          	sub	t6,s6,a4
    cf46:	007ffa93          	andi	s5,t6,7
    cf4a:	00e805b3          	add	a1,a6,a4
    cf4e:	03000513          	li	a0,48
    cf52:	060a8763          	beqz	s5,cfc0 <_vsnprintf+0x43f0>
    cf56:	0705                	addi	a4,a4,1
    cf58:	1815d50b          	th.sbia	a0,(a1),1,0
    cf5c:	0ce78463          	beq	a5,a4,d024 <_vsnprintf+0x4454>
    cf60:	4305                	li	t1,1
    cf62:	046a8f63          	beq	s5,t1,cfc0 <_vsnprintf+0x43f0>
    cf66:	4609                	li	a2,2
    cf68:	04ca8763          	beq	s5,a2,cfb6 <_vsnprintf+0x43e6>
    cf6c:	4c8d                	li	s9,3
    cf6e:	039a8f63          	beq	s5,s9,cfac <_vsnprintf+0x43dc>
    cf72:	4291                	li	t0,4
    cf74:	025a8763          	beq	s5,t0,cfa2 <_vsnprintf+0x43d2>
    cf78:	4395                	li	t2,5
    cf7a:	007a8f63          	beq	s5,t2,cf98 <_vsnprintf+0x43c8>
    cf7e:	4f19                	li	t5,6
    cf80:	01ea8763          	beq	s5,t5,cf8e <_vsnprintf+0x43be>
    cf84:	0705                	addi	a4,a4,1
    cf86:	1815d50b          	th.sbia	a0,(a1),1,0
    cf8a:	08e78d63          	beq	a5,a4,d024 <_vsnprintf+0x4454>
    cf8e:	0705                	addi	a4,a4,1
    cf90:	1815d50b          	th.sbia	a0,(a1),1,0
    cf94:	08e78863          	beq	a5,a4,d024 <_vsnprintf+0x4454>
    cf98:	0705                	addi	a4,a4,1
    cf9a:	1815d50b          	th.sbia	a0,(a1),1,0
    cf9e:	08e78363          	beq	a5,a4,d024 <_vsnprintf+0x4454>
    cfa2:	0705                	addi	a4,a4,1
    cfa4:	1815d50b          	th.sbia	a0,(a1),1,0
    cfa8:	06e78e63          	beq	a5,a4,d024 <_vsnprintf+0x4454>
    cfac:	0705                	addi	a4,a4,1
    cfae:	1815d50b          	th.sbia	a0,(a1),1,0
    cfb2:	06e78963          	beq	a5,a4,d024 <_vsnprintf+0x4454>
    cfb6:	0705                	addi	a4,a4,1
    cfb8:	1815d50b          	th.sbia	a0,(a1),1,0
    cfbc:	06e78463          	beq	a5,a4,d024 <_vsnprintf+0x4454>
    cfc0:	47670ae3          	beq	a4,s6,dc34 <_vsnprintf+0x5064>
    cfc4:	0705                	addi	a4,a4,1
    cfc6:	00a58023          	sb	a0,0(a1)
    cfca:	8fba                	mv	t6,a4
    cfcc:	04e78c63          	beq	a5,a4,d024 <_vsnprintf+0x4454>
    cfd0:	0705                	addi	a4,a4,1
    cfd2:	00a580a3          	sb	a0,1(a1)
    cfd6:	04e78763          	beq	a5,a4,d024 <_vsnprintf+0x4454>
    cfda:	002f8713          	addi	a4,t6,2
    cfde:	00a58123          	sb	a0,2(a1)
    cfe2:	04e78163          	beq	a5,a4,d024 <_vsnprintf+0x4454>
    cfe6:	003f8713          	addi	a4,t6,3
    cfea:	00a581a3          	sb	a0,3(a1)
    cfee:	02e78b63          	beq	a5,a4,d024 <_vsnprintf+0x4454>
    cff2:	004f8713          	addi	a4,t6,4
    cff6:	00a58223          	sb	a0,4(a1)
    cffa:	02e78563          	beq	a5,a4,d024 <_vsnprintf+0x4454>
    cffe:	005f8713          	addi	a4,t6,5
    d002:	00a582a3          	sb	a0,5(a1)
    d006:	00e78f63          	beq	a5,a4,d024 <_vsnprintf+0x4454>
    d00a:	006f8713          	addi	a4,t6,6
    d00e:	00a58323          	sb	a0,6(a1)
    d012:	00e78963          	beq	a5,a4,d024 <_vsnprintf+0x4454>
    d016:	00a583a3          	sb	a0,7(a1)
    d01a:	007f8713          	addi	a4,t6,7
    d01e:	05a1                	addi	a1,a1,8
    d020:	fae790e3          	bne	a5,a4,cfc0 <_vsnprintf+0x43f0>
    d024:	140e99e3          	bnez	t4,d976 <_vsnprintf+0x4da6>
    d028:	01671463          	bne	a4,s6,d030 <_vsnprintf+0x4460>
    d02c:	e4cfe06f          	j	b678 <_vsnprintf+0x2aa8>
    d030:	003e7d13          	andi	s10,t3,3
    d034:	000d0463          	beqz	s10,d03c <_vsnprintf+0x446c>
    d038:	7a10106f          	j	efd8 <_vsnprintf+0x6408>
    d03c:	8c3e                	mv	s8,a5
    d03e:	16f765e3          	bltu	a4,a5,d9a8 <_vsnprintf+0x4dd8>
    d042:	6e02                	ld	t3,0(sp)
    d044:	e3afe06f          	j	b67e <_vsnprintf+0x2aae>
    d048:	47c1                	li	a5,16
    d04a:	8abe                	mv	s5,a5
    d04c:	01f8f463          	bgeu	a7,t6,d054 <_vsnprintf+0x4484>
    d050:	f0ffd06f          	j	af5e <_vsnprintf+0x238e>
    d054:	000b9463          	bnez	s7,d05c <_vsnprintf+0x448c>
    d058:	c10fe06f          	j	b468 <_vsnprintf+0x2898>
    d05c:	4b81                	li	s7,0
    d05e:	8a0c9ae3          	bnez	s9,c912 <_vsnprintf+0x3d42>
    d062:	01fd1463          	bne	s10,t6,d06a <_vsnprintf+0x449a>
    d066:	3ec0106f          	j	e452 <_vsnprintf+0x5882>
    d06a:	8ba794e3          	bne	a5,s10,c912 <_vsnprintf+0x3d42>
    d06e:	3ed0006f          	j	dc5a <_vsnprintf+0x508a>
    d072:	0001                	nop
    d074:	ec46                	sd	a7,24(sp)
    d076:	f056                	sd	s5,32(sp)
    d078:	6b82                	ld	s7,0(sp)
    d07a:	8cbe                	mv	s9,a5
    d07c:	a5dfe06f          	j	bad8 <_vsnprintf+0x2f08>
    d080:	000f9463          	bnez	t6,d088 <_vsnprintf+0x44b8>
    d084:	77d0106f          	j	f000 <_vsnprintf+0x6430>
    d088:	47c1                	li	a5,16
    d08a:	4d01                	li	s10,0
    d08c:	40000c93          	li	s9,1024
    d090:	8abe                	mv	s5,a5
    d092:	03010b13          	addi	s6,sp,48
    d096:	ec9fd06f          	j	af5e <_vsnprintf+0x238e>
    d09a:	588dce0b          	th.lwia	t3,(s11),8,0
    d09e:	41fe551b          	sraiw	a0,t3,0x1f
    d0a2:	00ae4633          	xor	a2,t3,a0
    d0a6:	40a603bb          	subw	t2,a2,a0
    d0aa:	a3ffd06f          	j	aae8 <_vsnprintf+0x1f18>
    d0ae:	00857713          	andi	a4,a0,8
    d0b2:	40071fe3          	bnez	a4,dcd0 <_vsnprintf+0x5100>
    d0b6:	6a82                	ld	s5,0(sp)
    d0b8:	4d01                	li	s10,0
    d0ba:	4bc1                	li	s7,16
    d0bc:	96dfd06f          	j	aa28 <_vsnprintf+0x1e58>
    d0c0:	05800f13          	li	t5,88
    d0c4:	05e10023          	sb	t5,64(sp)
    d0c8:	4b81                	li	s7,0
    d0ca:	47c5                	li	a5,17
    d0cc:	b8cfe06f          	j	b458 <_vsnprintf+0x2888>
    d0d0:	0025fb93          	andi	s7,a1,2
    d0d4:	8d2e                	mv	s10,a1
    d0d6:	300b97e3          	bnez	s7,dbe4 <_vsnprintf+0x5014>
    d0da:	00089463          	bnez	a7,d0e2 <_vsnprintf+0x4512>
    d0de:	0b40106f          	j	e192 <_vsnprintf+0x55c2>
    d0e2:	001d7f93          	andi	t6,s10,1
    d0e6:	000f8463          	beqz	t6,d0ee <_vsnprintf+0x451e>
    d0ea:	4e20106f          	j	e5cc <_vsnprintf+0x59fc>
    d0ee:	7c0c3c0b          	th.extu	s8,s8,31,0
    d0f2:	4781                	li	a5,0
    d0f4:	03010b93          	addi	s7,sp,48
    d0f8:	c60c1763          	bnez	s8,c566 <_vsnprintf+0x3996>
    d0fc:	004d7b13          	andi	s6,s10,4
    d100:	000b1463          	bnez	s6,d108 <_vsnprintf+0x4538>
    d104:	6cb0106f          	j	efce <_vsnprintf+0x63fe>
    d108:	02b00693          	li	a3,43
    d10c:	02d10823          	sb	a3,48(sp)
    d110:	4c05                	li	s8,1
    d112:	7c08bd0b          	th.extu	s10,a7,31,0
    d116:	4b01                	li	s6,0
    d118:	01ac6463          	bltu	s8,s10,d120 <_vsnprintf+0x4550>
    d11c:	6a50106f          	j	efc0 <_vsnprintf+0x63f0>
    d120:	6602                	ld	a2,0(sp)
    d122:	02000513          	li	a0,32
    d126:	86a6                	mv	a3,s1
    d128:	40cc0cb3          	sub	s9,s8,a2
    d12c:	fffcc713          	not	a4,s9
    d130:	40c70fb3          	sub	t6,a4,a2
    d134:	01af8bb3          	add	s7,t6,s10
    d138:	ec66                	sd	s9,24(sp)
    d13a:	f046                	sd	a7,32(sp)
    d13c:	85ca                	mv	a1,s2
    d13e:	007bfa93          	andi	s5,s7,7
    d142:	00160b93          	addi	s7,a2,1
    d146:	9402                	jalr	s0
    d148:	017c8533          	add	a0,s9,s7
    d14c:	7882                	ld	a7,32(sp)
    d14e:	15a57663          	bgeu	a0,s10,d29a <_vsnprintf+0x46ca>
    d152:	0a0a8a63          	beqz	s5,d206 <_vsnprintf+0x4636>
    d156:	4685                	li	a3,1
    d158:	08da8963          	beq	s5,a3,d1ea <_vsnprintf+0x461a>
    d15c:	4789                	li	a5,2
    d15e:	06fa8d63          	beq	s5,a5,d1d8 <_vsnprintf+0x4608>
    d162:	428d                	li	t0,3
    d164:	065a8163          	beq	s5,t0,d1c6 <_vsnprintf+0x45f6>
    d168:	4591                	li	a1,4
    d16a:	04ba8563          	beq	s5,a1,d1b4 <_vsnprintf+0x45e4>
    d16e:	4395                	li	t2,5
    d170:	027a8963          	beq	s5,t2,d1a2 <_vsnprintf+0x45d2>
    d174:	4f19                	li	t5,6
    d176:	01ea8d63          	beq	s5,t5,d190 <_vsnprintf+0x45c0>
    d17a:	6302                	ld	t1,0(sp)
    d17c:	865e                	mv	a2,s7
    d17e:	f046                	sd	a7,32(sp)
    d180:	86a6                	mv	a3,s1
    d182:	85ca                	mv	a1,s2
    d184:	02000513          	li	a0,32
    d188:	00230b93          	addi	s7,t1,2
    d18c:	9402                	jalr	s0
    d18e:	7882                	ld	a7,32(sp)
    d190:	865e                	mv	a2,s7
    d192:	f046                	sd	a7,32(sp)
    d194:	86a6                	mv	a3,s1
    d196:	85ca                	mv	a1,s2
    d198:	02000513          	li	a0,32
    d19c:	9402                	jalr	s0
    d19e:	7882                	ld	a7,32(sp)
    d1a0:	0b85                	addi	s7,s7,1
    d1a2:	865e                	mv	a2,s7
    d1a4:	f046                	sd	a7,32(sp)
    d1a6:	86a6                	mv	a3,s1
    d1a8:	85ca                	mv	a1,s2
    d1aa:	02000513          	li	a0,32
    d1ae:	9402                	jalr	s0
    d1b0:	7882                	ld	a7,32(sp)
    d1b2:	0b85                	addi	s7,s7,1
    d1b4:	865e                	mv	a2,s7
    d1b6:	f046                	sd	a7,32(sp)
    d1b8:	86a6                	mv	a3,s1
    d1ba:	85ca                	mv	a1,s2
    d1bc:	02000513          	li	a0,32
    d1c0:	9402                	jalr	s0
    d1c2:	7882                	ld	a7,32(sp)
    d1c4:	0b85                	addi	s7,s7,1
    d1c6:	865e                	mv	a2,s7
    d1c8:	f046                	sd	a7,32(sp)
    d1ca:	86a6                	mv	a3,s1
    d1cc:	85ca                	mv	a1,s2
    d1ce:	02000513          	li	a0,32
    d1d2:	9402                	jalr	s0
    d1d4:	7882                	ld	a7,32(sp)
    d1d6:	0b85                	addi	s7,s7,1
    d1d8:	865e                	mv	a2,s7
    d1da:	f046                	sd	a7,32(sp)
    d1dc:	86a6                	mv	a3,s1
    d1de:	85ca                	mv	a1,s2
    d1e0:	02000513          	li	a0,32
    d1e4:	9402                	jalr	s0
    d1e6:	7882                	ld	a7,32(sp)
    d1e8:	0b85                	addi	s7,s7,1
    d1ea:	865e                	mv	a2,s7
    d1ec:	f046                	sd	a7,32(sp)
    d1ee:	86a6                	mv	a3,s1
    d1f0:	85ca                	mv	a1,s2
    d1f2:	02000513          	li	a0,32
    d1f6:	9402                	jalr	s0
    d1f8:	6862                	ld	a6,24(sp)
    d1fa:	7882                	ld	a7,32(sp)
    d1fc:	0b85                	addi	s7,s7,1
    d1fe:	01780eb3          	add	t4,a6,s7
    d202:	09aefc63          	bgeu	t4,s10,d29a <_vsnprintf+0x46ca>
    d206:	f06e                	sd	s11,32(sp)
    d208:	8dda                	mv	s11,s6
    d20a:	8b46                	mv	s6,a7
    d20c:	865e                	mv	a2,s7
    d20e:	86a6                	mv	a3,s1
    d210:	85ca                	mv	a1,s2
    d212:	02000513          	li	a0,32
    d216:	9402                	jalr	s0
    d218:	001b8a93          	addi	s5,s7,1
    d21c:	8656                	mv	a2,s5
    d21e:	86a6                	mv	a3,s1
    d220:	85ca                	mv	a1,s2
    d222:	02000513          	li	a0,32
    d226:	9402                	jalr	s0
    d228:	002b8c93          	addi	s9,s7,2
    d22c:	8666                	mv	a2,s9
    d22e:	86a6                	mv	a3,s1
    d230:	85ca                	mv	a1,s2
    d232:	02000513          	li	a0,32
    d236:	9402                	jalr	s0
    d238:	003b8a93          	addi	s5,s7,3
    d23c:	8656                	mv	a2,s5
    d23e:	86a6                	mv	a3,s1
    d240:	85ca                	mv	a1,s2
    d242:	02000513          	li	a0,32
    d246:	9402                	jalr	s0
    d248:	004b8c93          	addi	s9,s7,4
    d24c:	8666                	mv	a2,s9
    d24e:	86a6                	mv	a3,s1
    d250:	85ca                	mv	a1,s2
    d252:	02000513          	li	a0,32
    d256:	9402                	jalr	s0
    d258:	005b8a93          	addi	s5,s7,5
    d25c:	8656                	mv	a2,s5
    d25e:	86a6                	mv	a3,s1
    d260:	85ca                	mv	a1,s2
    d262:	02000513          	li	a0,32
    d266:	9402                	jalr	s0
    d268:	006b8c93          	addi	s9,s7,6
    d26c:	86a6                	mv	a3,s1
    d26e:	8666                	mv	a2,s9
    d270:	85ca                	mv	a1,s2
    d272:	02000513          	li	a0,32
    d276:	9402                	jalr	s0
    d278:	007b8a93          	addi	s5,s7,7
    d27c:	86a6                	mv	a3,s1
    d27e:	8656                	mv	a2,s5
    d280:	85ca                	mv	a1,s2
    d282:	02000513          	li	a0,32
    d286:	9402                	jalr	s0
    d288:	68e2                	ld	a7,24(sp)
    d28a:	0ba1                	addi	s7,s7,8
    d28c:	01788e33          	add	t3,a7,s7
    d290:	f7ae6ee3          	bltu	t3,s10,d20c <_vsnprintf+0x463c>
    d294:	88da                	mv	a7,s6
    d296:	8b6e                	mv	s6,s11
    d298:	7d82                	ld	s11,32(sp)
    d29a:	6682                	ld	a3,0(sp)
    d29c:	fffd0613          	addi	a2,s10,-1
    d2a0:	001c0713          	addi	a4,s8,1
    d2a4:	41860fb3          	sub	t6,a2,s8
    d2a8:	00ed3533          	sltu	a0,s10,a4
    d2ac:	42a01f8b          	th.mvnez	t6,zero,a0
    d2b0:	00168793          	addi	a5,a3,1
    d2b4:	00ff8333          	add	t1,t6,a5
    d2b8:	8a9a                	mv	s5,t1
    d2ba:	000c1463          	bnez	s8,d2c2 <_vsnprintf+0x46f2>
    d2be:	afbfd06f          	j	adb8 <_vsnprintf+0x21e8>
    d2c2:	002c03b3          	add	t2,s8,sp
    d2c6:	02f3c503          	lbu	a0,47(t2)
    d2ca:	03010b93          	addi	s7,sp,48
    d2ce:	989fd06f          	j	ac56 <_vsnprintf+0x2086>
    d2d2:	0035ff93          	andi	t6,a1,3
    d2d6:	020f9d63          	bnez	t6,d310 <_vsnprintf+0x4740>
    d2da:	02000c13          	li	s8,32
    d2de:	7c08bd0b          	th.extu	s10,a7,31,0
    d2e2:	4b01                	li	s6,0
    d2e4:	e31c6ee3          	bltu	s8,a7,d120 <_vsnprintf+0x4550>
    d2e8:	04f14503          	lbu	a0,79(sp)
    d2ec:	6302                	ld	t1,0(sp)
    d2ee:	02000c13          	li	s8,32
    d2f2:	4b01                	li	s6,0
    d2f4:	963fd06f          	j	ac56 <_vsnprintf+0x2086>
    d2f8:	ec46                	sd	a7,24(sp)
    d2fa:	f05a                	sd	s6,32(sp)
    d2fc:	aa5fd06f          	j	ada0 <_vsnprintf+0x21d0>
    d300:	fc0f89e3          	beqz	t6,d2d2 <_vsnprintf+0x4702>
    d304:	7c08bf8b          	th.extu	t6,a7,31,0
    d308:	b5f7ea63          	bltu	a5,t6,c65c <_vsnprintf+0x3a8c>
    d30c:	898d                	andi	a1,a1,3
    d30e:	dde9                	beqz	a1,d2e8 <_vsnprintf+0x4718>
    d310:	4b01                	li	s6,0
    d312:	93bfd06f          	j	ac4c <_vsnprintf+0x207c>
    d316:	7c0c3c0b          	th.extu	s8,s8,31,0
    d31a:	0187e463          	bltu	a5,s8,d322 <_vsnprintf+0x4752>
    d31e:	4170106f          	j	ef34 <_vsnprintf+0x6364>
    d322:	0015ff93          	andi	t6,a1,1
    d326:	4881                	li	a7,0
    d328:	a3eff06f          	j	c566 <_vsnprintf+0x3996>
    d32c:	0a0882e3          	beqz	a7,dbd0 <_vsnprintf+0x5000>
    d330:	0015fb13          	andi	s6,a1,1
    d334:	7c0c350b          	th.extu	a0,s8,31,0
    d338:	000b1463          	bnez	s6,d340 <_vsnprintf+0x4770>
    d33c:	32c0106f          	j	e668 <_vsnprintf+0x5a98>
    d340:	0eadf763          	bgeu	s11,a0,d42e <_vsnprintf+0x485e>
    d344:	02000713          	li	a4,32
    d348:	41b70cb3          	sub	s9,a4,s11
    d34c:	007cff13          	andi	t5,s9,7
    d350:	01b80e33          	add	t3,a6,s11
    d354:	03000293          	li	t0,48
    d358:	060f0763          	beqz	t5,d3c6 <_vsnprintf+0x47f6>
    d35c:	0d85                	addi	s11,s11,1
    d35e:	181e528b          	th.sbia	t0,(t3),1,0
    d362:	0cadf463          	bgeu	s11,a0,d42a <_vsnprintf+0x485a>
    d366:	4f85                	li	t6,1
    d368:	05ff0f63          	beq	t5,t6,d3c6 <_vsnprintf+0x47f6>
    d36c:	4789                	li	a5,2
    d36e:	04ff0763          	beq	t5,a5,d3bc <_vsnprintf+0x47ec>
    d372:	458d                	li	a1,3
    d374:	02bf0f63          	beq	t5,a1,d3b2 <_vsnprintf+0x47e2>
    d378:	4391                	li	t2,4
    d37a:	027f0763          	beq	t5,t2,d3a8 <_vsnprintf+0x47d8>
    d37e:	4315                	li	t1,5
    d380:	006f0f63          	beq	t5,t1,d39e <_vsnprintf+0x47ce>
    d384:	4e99                	li	t4,6
    d386:	01df0763          	beq	t5,t4,d394 <_vsnprintf+0x47c4>
    d38a:	0d85                	addi	s11,s11,1
    d38c:	181e528b          	th.sbia	t0,(t3),1,0
    d390:	08adfd63          	bgeu	s11,a0,d42a <_vsnprintf+0x485a>
    d394:	0d85                	addi	s11,s11,1
    d396:	181e528b          	th.sbia	t0,(t3),1,0
    d39a:	08adf863          	bgeu	s11,a0,d42a <_vsnprintf+0x485a>
    d39e:	0d85                	addi	s11,s11,1
    d3a0:	181e528b          	th.sbia	t0,(t3),1,0
    d3a4:	08adf363          	bgeu	s11,a0,d42a <_vsnprintf+0x485a>
    d3a8:	0d85                	addi	s11,s11,1
    d3aa:	181e528b          	th.sbia	t0,(t3),1,0
    d3ae:	06adfe63          	bgeu	s11,a0,d42a <_vsnprintf+0x485a>
    d3b2:	0d85                	addi	s11,s11,1
    d3b4:	181e528b          	th.sbia	t0,(t3),1,0
    d3b8:	06adf963          	bgeu	s11,a0,d42a <_vsnprintf+0x485a>
    d3bc:	0d85                	addi	s11,s11,1
    d3be:	181e528b          	th.sbia	t0,(t3),1,0
    d3c2:	06adf463          	bgeu	s11,a0,d42a <_vsnprintf+0x485a>
    d3c6:	06ed8263          	beq	s11,a4,d42a <_vsnprintf+0x485a>
    d3ca:	0d85                	addi	s11,s11,1
    d3cc:	005e0023          	sb	t0,0(t3)
    d3d0:	8cee                	mv	s9,s11
    d3d2:	04adfc63          	bgeu	s11,a0,d42a <_vsnprintf+0x485a>
    d3d6:	0d85                	addi	s11,s11,1
    d3d8:	005e00a3          	sb	t0,1(t3)
    d3dc:	04adf763          	bgeu	s11,a0,d42a <_vsnprintf+0x485a>
    d3e0:	002c8d93          	addi	s11,s9,2
    d3e4:	005e0123          	sb	t0,2(t3)
    d3e8:	04adf163          	bgeu	s11,a0,d42a <_vsnprintf+0x485a>
    d3ec:	003c8d93          	addi	s11,s9,3
    d3f0:	005e01a3          	sb	t0,3(t3)
    d3f4:	02adfb63          	bgeu	s11,a0,d42a <_vsnprintf+0x485a>
    d3f8:	004c8d93          	addi	s11,s9,4
    d3fc:	005e0223          	sb	t0,4(t3)
    d400:	02adf563          	bgeu	s11,a0,d42a <_vsnprintf+0x485a>
    d404:	005c8d93          	addi	s11,s9,5
    d408:	005e02a3          	sb	t0,5(t3)
    d40c:	00adff63          	bgeu	s11,a0,d42a <_vsnprintf+0x485a>
    d410:	006c8d93          	addi	s11,s9,6
    d414:	005e0323          	sb	t0,6(t3)
    d418:	00adf963          	bgeu	s11,a0,d42a <_vsnprintf+0x485a>
    d41c:	005e03a3          	sb	t0,7(t3)
    d420:	007c8d93          	addi	s11,s9,7
    d424:	0e21                	addi	t3,t3,8
    d426:	faade0e3          	bltu	s11,a0,d3c6 <_vsnprintf+0x47f6>
    d42a:	3e0b09e3          	beqz	s6,e01c <_vsnprintf+0x544c>
    d42e:	7c08b50b          	th.extu	a0,a7,31,0
    d432:	4aadf4e3          	bgeu	s11,a0,e0da <_vsnprintf+0x550a>
    d436:	02000b13          	li	s6,32
    d43a:	41bb02b3          	sub	t0,s6,s11
    d43e:	0072ff93          	andi	t6,t0,7
    d442:	01b805b3          	add	a1,a6,s11
    d446:	03000713          	li	a4,48
    d44a:	060f8763          	beqz	t6,d4b8 <_vsnprintf+0x48e8>
    d44e:	0d85                	addi	s11,s11,1
    d450:	1815d70b          	th.sbia	a4,(a1),1,0
    d454:	0db50463          	beq	a0,s11,d51c <_vsnprintf+0x494c>
    d458:	4f05                	li	t5,1
    d45a:	05ef8f63          	beq	t6,t5,d4b8 <_vsnprintf+0x48e8>
    d45e:	4789                	li	a5,2
    d460:	04ff8763          	beq	t6,a5,d4ae <_vsnprintf+0x48de>
    d464:	438d                	li	t2,3
    d466:	027f8f63          	beq	t6,t2,d4a4 <_vsnprintf+0x48d4>
    d46a:	4311                	li	t1,4
    d46c:	026f8763          	beq	t6,t1,d49a <_vsnprintf+0x48ca>
    d470:	4e95                	li	t4,5
    d472:	01df8f63          	beq	t6,t4,d490 <_vsnprintf+0x48c0>
    d476:	4c99                	li	s9,6
    d478:	019f8763          	beq	t6,s9,d486 <_vsnprintf+0x48b6>
    d47c:	0d85                	addi	s11,s11,1
    d47e:	1815d70b          	th.sbia	a4,(a1),1,0
    d482:	09b50d63          	beq	a0,s11,d51c <_vsnprintf+0x494c>
    d486:	0d85                	addi	s11,s11,1
    d488:	1815d70b          	th.sbia	a4,(a1),1,0
    d48c:	09b50863          	beq	a0,s11,d51c <_vsnprintf+0x494c>
    d490:	0d85                	addi	s11,s11,1
    d492:	1815d70b          	th.sbia	a4,(a1),1,0
    d496:	09b50363          	beq	a0,s11,d51c <_vsnprintf+0x494c>
    d49a:	0d85                	addi	s11,s11,1
    d49c:	1815d70b          	th.sbia	a4,(a1),1,0
    d4a0:	07b50e63          	beq	a0,s11,d51c <_vsnprintf+0x494c>
    d4a4:	0d85                	addi	s11,s11,1
    d4a6:	1815d70b          	th.sbia	a4,(a1),1,0
    d4aa:	07b50963          	beq	a0,s11,d51c <_vsnprintf+0x494c>
    d4ae:	0d85                	addi	s11,s11,1
    d4b0:	1815d70b          	th.sbia	a4,(a1),1,0
    d4b4:	07b50463          	beq	a0,s11,d51c <_vsnprintf+0x494c>
    d4b8:	2f6d8ae3          	beq	s11,s6,dfac <_vsnprintf+0x53dc>
    d4bc:	0d85                	addi	s11,s11,1
    d4be:	00e58023          	sb	a4,0(a1)
    d4c2:	82ee                	mv	t0,s11
    d4c4:	05b50c63          	beq	a0,s11,d51c <_vsnprintf+0x494c>
    d4c8:	0d85                	addi	s11,s11,1
    d4ca:	00e580a3          	sb	a4,1(a1)
    d4ce:	05b50763          	beq	a0,s11,d51c <_vsnprintf+0x494c>
    d4d2:	00228d93          	addi	s11,t0,2
    d4d6:	00e58123          	sb	a4,2(a1)
    d4da:	05b50163          	beq	a0,s11,d51c <_vsnprintf+0x494c>
    d4de:	00328d93          	addi	s11,t0,3
    d4e2:	00e581a3          	sb	a4,3(a1)
    d4e6:	03b50b63          	beq	a0,s11,d51c <_vsnprintf+0x494c>
    d4ea:	00428d93          	addi	s11,t0,4
    d4ee:	00e58223          	sb	a4,4(a1)
    d4f2:	03b50563          	beq	a0,s11,d51c <_vsnprintf+0x494c>
    d4f6:	00528d93          	addi	s11,t0,5
    d4fa:	00e582a3          	sb	a4,5(a1)
    d4fe:	01b50f63          	beq	a0,s11,d51c <_vsnprintf+0x494c>
    d502:	00628d93          	addi	s11,t0,6
    d506:	00e58323          	sb	a4,6(a1)
    d50a:	01b50963          	beq	a0,s11,d51c <_vsnprintf+0x494c>
    d50e:	00e583a3          	sb	a4,7(a1)
    d512:	00728d93          	addi	s11,t0,7
    d516:	05a1                	addi	a1,a1,8
    d518:	fbb510e3          	bne	a0,s11,d4b8 <_vsnprintf+0x48e8>
    d51c:	000d0463          	beqz	s10,d524 <_vsnprintf+0x4954>
    d520:	1220106f          	j	e642 <_vsnprintf+0x5a72>
    d524:	3d6d91e3          	bne	s11,s6,e0e6 <_vsnprintf+0x5516>
    d528:	4d01                	li	s10,0
    d52a:	e98fe06f          	j	bbc2 <_vsnprintf+0x2ff2>
    d52e:	0001                	nop
    d530:	588dce8b          	th.lwia	t4,(s11),8,0
    d534:	917fc06f          	j	9e4a <_vsnprintf+0x127a>
    d538:	00278eb3          	add	t4,a5,sp
    d53c:	05800713          	li	a4,88
    d540:	00278d13          	addi	s10,a5,2
    d544:	03000793          	li	a5,48
    d548:	02ee8823          	sb	a4,48(t4)
    d54c:	02fe88a3          	sb	a5,49(t4)
    d550:	4b81                	li	s7,0
    d552:	f1ffd06f          	j	b470 <_vsnprintf+0x28a0>
    d556:	00267e93          	andi	t4,a2,2
    d55a:	380e8fe3          	beqz	t4,e0f8 <_vsnprintf+0x5528>
    d55e:	6e02                	ld	t3,0(sp)
    d560:	a8afe06f          	j	b7ea <_vsnprintf+0x2c1a>
    d564:	47a9                	li	a5,10
    d566:	8b2e                	mv	s6,a1
    d568:	86be                	mv	a3,a5
    d56a:	89ffc06f          	j	9e08 <_vsnprintf+0x1238>
    d56e:	ec46                	sd	a7,24(sp)
    d570:	f05a                	sd	s6,32(sp)
    d572:	e43fe06f          	j	c3b4 <_vsnprintf+0x37e4>
    d576:	340889e3          	beqz	a7,e0c8 <_vsnprintf+0x54f8>
    d57a:	0012fd93          	andi	s11,t0,1
    d57e:	7e0d80e3          	beqz	s11,e55e <_vsnprintf+0x598e>
    d582:	000e4463          	bltz	t3,d58a <_vsnprintf+0x49ba>
    d586:	3ec0106f          	j	e972 <_vsnprintf+0x5da2>
    d58a:	7c0c3d0b          	th.extu	s10,s8,31,0
    d58e:	38fd                	addiw	a7,a7,-1
    d590:	01a7f463          	bgeu	a5,s10,d598 <_vsnprintf+0x49c8>
    d594:	b67fd06f          	j	b0fa <_vsnprintf+0x252a>
    d598:	7c08b68b          	th.extu	a3,a7,31,0
    d59c:	00d7e463          	bltu	a5,a3,d5a4 <_vsnprintf+0x49d4>
    d5a0:	4d60106f          	j	ea76 <_vsnprintf+0x5ea6>
    d5a4:	02000d93          	li	s11,32
    d5a8:	40fd8533          	sub	a0,s11,a5
    d5ac:	00757e93          	andi	t4,a0,7
    d5b0:	00f30633          	add	a2,t1,a5
    d5b4:	03000b13          	li	s6,48
    d5b8:	060e8763          	beqz	t4,d626 <_vsnprintf+0x4a56>
    d5bc:	0785                	addi	a5,a5,1
    d5be:	18165b0b          	th.sbia	s6,(a2),1,0
    d5c2:	0cd78463          	beq	a5,a3,d68a <_vsnprintf+0x4aba>
    d5c6:	4f05                	li	t5,1
    d5c8:	05ee8f63          	beq	t4,t5,d626 <_vsnprintf+0x4a56>
    d5cc:	4a89                	li	s5,2
    d5ce:	055e8763          	beq	t4,s5,d61c <_vsnprintf+0x4a4c>
    d5d2:	428d                	li	t0,3
    d5d4:	025e8f63          	beq	t4,t0,d612 <_vsnprintf+0x4a42>
    d5d8:	4c91                	li	s9,4
    d5da:	039e8763          	beq	t4,s9,d608 <_vsnprintf+0x4a38>
    d5de:	4c15                	li	s8,5
    d5e0:	018e8f63          	beq	t4,s8,d5fe <_vsnprintf+0x4a2e>
    d5e4:	4b99                	li	s7,6
    d5e6:	017e8763          	beq	t4,s7,d5f4 <_vsnprintf+0x4a24>
    d5ea:	0785                	addi	a5,a5,1
    d5ec:	18165b0b          	th.sbia	s6,(a2),1,0
    d5f0:	08d78d63          	beq	a5,a3,d68a <_vsnprintf+0x4aba>
    d5f4:	0785                	addi	a5,a5,1
    d5f6:	18165b0b          	th.sbia	s6,(a2),1,0
    d5fa:	08d78863          	beq	a5,a3,d68a <_vsnprintf+0x4aba>
    d5fe:	0785                	addi	a5,a5,1
    d600:	18165b0b          	th.sbia	s6,(a2),1,0
    d604:	08d78363          	beq	a5,a3,d68a <_vsnprintf+0x4aba>
    d608:	0785                	addi	a5,a5,1
    d60a:	18165b0b          	th.sbia	s6,(a2),1,0
    d60e:	06d78e63          	beq	a5,a3,d68a <_vsnprintf+0x4aba>
    d612:	0785                	addi	a5,a5,1
    d614:	18165b0b          	th.sbia	s6,(a2),1,0
    d618:	06d78963          	beq	a5,a3,d68a <_vsnprintf+0x4aba>
    d61c:	0785                	addi	a5,a5,1
    d61e:	18165b0b          	th.sbia	s6,(a2),1,0
    d622:	06d78463          	beq	a5,a3,d68a <_vsnprintf+0x4aba>
    d626:	07b78863          	beq	a5,s11,d696 <_vsnprintf+0x4ac6>
    d62a:	00178f93          	addi	t6,a5,1
    d62e:	01660023          	sb	s6,0(a2)
    d632:	04df8c63          	beq	t6,a3,d68a <_vsnprintf+0x4aba>
    d636:	00278393          	addi	t2,a5,2
    d63a:	016600a3          	sb	s6,1(a2)
    d63e:	04d38663          	beq	t2,a3,d68a <_vsnprintf+0x4aba>
    d642:	00378713          	addi	a4,a5,3
    d646:	01660123          	sb	s6,2(a2)
    d64a:	04d70063          	beq	a4,a3,d68a <_vsnprintf+0x4aba>
    d64e:	00478d13          	addi	s10,a5,4
    d652:	016601a3          	sb	s6,3(a2)
    d656:	02dd0a63          	beq	s10,a3,d68a <_vsnprintf+0x4aba>
    d65a:	00578513          	addi	a0,a5,5
    d65e:	01660223          	sb	s6,4(a2)
    d662:	02d50463          	beq	a0,a3,d68a <_vsnprintf+0x4aba>
    d666:	00678e93          	addi	t4,a5,6
    d66a:	016602a3          	sb	s6,5(a2)
    d66e:	00de8e63          	beq	t4,a3,d68a <_vsnprintf+0x4aba>
    d672:	00778f13          	addi	t5,a5,7
    d676:	01660323          	sb	s6,6(a2)
    d67a:	00df0863          	beq	t5,a3,d68a <_vsnprintf+0x4aba>
    d67e:	016603a3          	sb	s6,7(a2)
    d682:	07a1                	addi	a5,a5,8
    d684:	0621                	addi	a2,a2,8
    d686:	fad790e3          	bne	a5,a3,d626 <_vsnprintf+0x4a56>
    d68a:	02000793          	li	a5,32
    d68e:	00f68463          	beq	a3,a5,d696 <_vsnprintf+0x4ac6>
    d692:	b71fd06f          	j	b202 <_vsnprintf+0x2632>
    d696:	898d                	andi	a1,a1,3
    d698:	c199                	beqz	a1,d69e <_vsnprintf+0x4ace>
    d69a:	1170106f          	j	efb0 <_vsnprintf+0x63e0>
    d69e:	02000693          	li	a3,32
    d6a2:	6116f463          	bgeu	a3,a7,dcaa <_vsnprintf+0x50da>
    d6a6:	7c08bb8b          	th.extu	s7,a7,31,0
    d6aa:	8dc2                	mv	s11,a6
    d6ac:	8d36                	mv	s10,a3
    d6ae:	4b01                	li	s6,0
    d6b0:	b85fd06f          	j	b234 <_vsnprintf+0x2664>
    d6b4:	02b00513          	li	a0,43
    d6b8:	feae0023          	sb	a0,-32(t3)
    d6bc:	a5efc06f          	j	991a <_vsnprintf+0xd4a>
    d6c0:	898d                	andi	a1,a1,3
    d6c2:	c199                	beqz	a1,d6c8 <_vsnprintf+0x4af8>
    d6c4:	2620106f          	j	e926 <_vsnprintf+0x5d56>
    d6c8:	02000693          	li	a3,32
    d6cc:	0316f763          	bgeu	a3,a7,d6fa <_vsnprintf+0x4b2a>
    d6d0:	7c08bb8b          	th.extu	s7,a7,31,0
    d6d4:	8dc2                	mv	s11,a6
    d6d6:	8c36                	mv	s8,a3
    d6d8:	4b01                	li	s6,0
    d6da:	daaff06f          	j	cc84 <_vsnprintf+0x40b4>
    d6de:	fe0d81e3          	beqz	s11,d6c0 <_vsnprintf+0x4af0>
    d6e2:	7c08b68b          	th.extu	a3,a7,31,0
    d6e6:	00d7f463          	bgeu	a5,a3,d6ee <_vsnprintf+0x4b1e>
    d6ea:	8edfe06f          	j	bfd6 <_vsnprintf+0x3406>
    d6ee:	0035fc13          	andi	s8,a1,3
    d6f2:	000c0463          	beqz	s8,d6fa <_vsnprintf+0x4b2a>
    d6f6:	2300106f          	j	e926 <_vsnprintf+0x5d56>
    d6fa:	8dc2                	mv	s11,a6
    d6fc:	04f14503          	lbu	a0,79(sp)
    d700:	6802                	ld	a6,0(sp)
    d702:	02000c13          	li	s8,32
    d706:	4b01                	li	s6,0
    d708:	b63fe06f          	j	c26a <_vsnprintf+0x369a>
    d70c:	4b81                	li	s7,0
    d70e:	963fd06f          	j	b070 <_vsnprintf+0x24a0>
    d712:	47c1                	li	a5,16
    d714:	95dfd06f          	j	b070 <_vsnprintf+0x24a0>
    d718:	ec46                	sd	a7,24(sp)
    d71a:	fd515b8b          	th.sdd	s7,s5,(sp),2,4
    d71e:	b4afc06f          	j	9a68 <_vsnprintf+0xe98>
    d722:	220e47e3          	bltz	t3,e150 <_vsnprintf+0x5580>
    d726:	004afe13          	andi	t3,s5,4
    d72a:	000e1463          	bnez	t3,d732 <_vsnprintf+0x4b62>
    d72e:	2920106f          	j	e9c0 <_vsnprintf+0x5df0>
    d732:	00278d33          	add	s10,a5,sp
    d736:	02b00513          	li	a0,43
    d73a:	02ad0823          	sb	a0,48(s10)
    d73e:	6302                	ld	t1,0(sp)
    d740:	00178c13          	addi	s8,a5,1
    d744:	4b09                	li	s6,2
    d746:	d10fd06f          	j	ac56 <_vsnprintf+0x2086>
    d74a:	7c0c3c0b          	th.extu	s8,s8,31,0
    d74e:	0187e463          	bltu	a5,s8,d756 <_vsnprintf+0x4b86>
    d752:	7020106f          	j	ee54 <_vsnprintf+0x6284>
    d756:	0015fd93          	andi	s11,a1,1
    d75a:	4881                	li	a7,0
    d75c:	f7cfe06f          	j	bed8 <_vsnprintf+0x3308>
    d760:	7a088ee3          	beqz	a7,e71c <_vsnprintf+0x5b4c>
    d764:	001e7c93          	andi	s9,t3,1
    d768:	7c0c370b          	th.extu	a4,s8,31,0
    d76c:	000c9463          	bnez	s9,d774 <_vsnprintf+0x4ba4>
    d770:	0d80106f          	j	e848 <_vsnprintf+0x5c78>
    d774:	0eed7763          	bgeu	s10,a4,d862 <_vsnprintf+0x4c92>
    d778:	02000313          	li	t1,32
    d77c:	41a30fb3          	sub	t6,t1,s10
    d780:	007fff13          	andi	t5,t6,7
    d784:	01ab0533          	add	a0,s6,s10
    d788:	03000393          	li	t2,48
    d78c:	060f0763          	beqz	t5,d7fa <_vsnprintf+0x4c2a>
    d790:	0d05                	addi	s10,s10,1
    d792:	1815538b          	th.sbia	t2,(a0),1,0
    d796:	0ced7463          	bgeu	s10,a4,d85e <_vsnprintf+0x4c8e>
    d79a:	4585                	li	a1,1
    d79c:	04bf0f63          	beq	t5,a1,d7fa <_vsnprintf+0x4c2a>
    d7a0:	4e09                	li	t3,2
    d7a2:	05cf0763          	beq	t5,t3,d7f0 <_vsnprintf+0x4c20>
    d7a6:	478d                	li	a5,3
    d7a8:	02ff0f63          	beq	t5,a5,d7e6 <_vsnprintf+0x4c16>
    d7ac:	4d91                	li	s11,4
    d7ae:	03bf0763          	beq	t5,s11,d7dc <_vsnprintf+0x4c0c>
    d7b2:	4295                	li	t0,5
    d7b4:	005f0f63          	beq	t5,t0,d7d2 <_vsnprintf+0x4c02>
    d7b8:	4f99                	li	t6,6
    d7ba:	01ff0763          	beq	t5,t6,d7c8 <_vsnprintf+0x4bf8>
    d7be:	0d05                	addi	s10,s10,1
    d7c0:	1815538b          	th.sbia	t2,(a0),1,0
    d7c4:	08ed7d63          	bgeu	s10,a4,d85e <_vsnprintf+0x4c8e>
    d7c8:	0d05                	addi	s10,s10,1
    d7ca:	1815538b          	th.sbia	t2,(a0),1,0
    d7ce:	08ed7863          	bgeu	s10,a4,d85e <_vsnprintf+0x4c8e>
    d7d2:	0d05                	addi	s10,s10,1
    d7d4:	1815538b          	th.sbia	t2,(a0),1,0
    d7d8:	08ed7363          	bgeu	s10,a4,d85e <_vsnprintf+0x4c8e>
    d7dc:	0d05                	addi	s10,s10,1
    d7de:	1815538b          	th.sbia	t2,(a0),1,0
    d7e2:	06ed7e63          	bgeu	s10,a4,d85e <_vsnprintf+0x4c8e>
    d7e6:	0d05                	addi	s10,s10,1
    d7e8:	1815538b          	th.sbia	t2,(a0),1,0
    d7ec:	06ed7963          	bgeu	s10,a4,d85e <_vsnprintf+0x4c8e>
    d7f0:	0d05                	addi	s10,s10,1
    d7f2:	1815538b          	th.sbia	t2,(a0),1,0
    d7f6:	06ed7463          	bgeu	s10,a4,d85e <_vsnprintf+0x4c8e>
    d7fa:	066d0263          	beq	s10,t1,d85e <_vsnprintf+0x4c8e>
    d7fe:	0d05                	addi	s10,s10,1
    d800:	00750023          	sb	t2,0(a0)
    d804:	8f6a                	mv	t5,s10
    d806:	04ed7c63          	bgeu	s10,a4,d85e <_vsnprintf+0x4c8e>
    d80a:	0d05                	addi	s10,s10,1
    d80c:	007500a3          	sb	t2,1(a0)
    d810:	04ed7763          	bgeu	s10,a4,d85e <_vsnprintf+0x4c8e>
    d814:	002f0d13          	addi	s10,t5,2
    d818:	00750123          	sb	t2,2(a0)
    d81c:	04ed7163          	bgeu	s10,a4,d85e <_vsnprintf+0x4c8e>
    d820:	003f0d13          	addi	s10,t5,3
    d824:	007501a3          	sb	t2,3(a0)
    d828:	02ed7b63          	bgeu	s10,a4,d85e <_vsnprintf+0x4c8e>
    d82c:	004f0d13          	addi	s10,t5,4
    d830:	00750223          	sb	t2,4(a0)
    d834:	02ed7563          	bgeu	s10,a4,d85e <_vsnprintf+0x4c8e>
    d838:	005f0d13          	addi	s10,t5,5
    d83c:	007502a3          	sb	t2,5(a0)
    d840:	00ed7f63          	bgeu	s10,a4,d85e <_vsnprintf+0x4c8e>
    d844:	006f0d13          	addi	s10,t5,6
    d848:	00750323          	sb	t2,6(a0)
    d84c:	00ed7963          	bgeu	s10,a4,d85e <_vsnprintf+0x4c8e>
    d850:	007503a3          	sb	t2,7(a0)
    d854:	007f0d13          	addi	s10,t5,7
    d858:	0521                	addi	a0,a0,8
    d85a:	faed60e3          	bltu	s10,a4,d7fa <_vsnprintf+0x4c2a>
    d85e:	620c84e3          	beqz	s9,e686 <_vsnprintf+0x5ab6>
    d862:	7c08b78b          	th.extu	a5,a7,31,0
    d866:	00fd6463          	bltu	s10,a5,d86e <_vsnprintf+0x4c9e>
    d86a:	6020106f          	j	ee6c <_vsnprintf+0x629c>
    d86e:	02000c93          	li	s9,32
    d872:	41ac83b3          	sub	t2,s9,s10
    d876:	0073fe13          	andi	t3,t2,7
    d87a:	01ab05b3          	add	a1,s6,s10
    d87e:	03000313          	li	t1,48
    d882:	060e0763          	beqz	t3,d8f0 <_vsnprintf+0x4d20>
    d886:	0d05                	addi	s10,s10,1
    d888:	1815d30b          	th.sbia	t1,(a1),1,0
    d88c:	0da78463          	beq	a5,s10,d954 <_vsnprintf+0x4d84>
    d890:	4d85                	li	s11,1
    d892:	05be0f63          	beq	t3,s11,d8f0 <_vsnprintf+0x4d20>
    d896:	4289                	li	t0,2
    d898:	045e0763          	beq	t3,t0,d8e6 <_vsnprintf+0x4d16>
    d89c:	4f8d                	li	t6,3
    d89e:	03fe0f63          	beq	t3,t6,d8dc <_vsnprintf+0x4d0c>
    d8a2:	4f11                	li	t5,4
    d8a4:	03ee0763          	beq	t3,t5,d8d2 <_vsnprintf+0x4d02>
    d8a8:	4515                	li	a0,5
    d8aa:	00ae0f63          	beq	t3,a0,d8c8 <_vsnprintf+0x4cf8>
    d8ae:	4719                	li	a4,6
    d8b0:	00ee0763          	beq	t3,a4,d8be <_vsnprintf+0x4cee>
    d8b4:	0d05                	addi	s10,s10,1
    d8b6:	1815d30b          	th.sbia	t1,(a1),1,0
    d8ba:	09a78d63          	beq	a5,s10,d954 <_vsnprintf+0x4d84>
    d8be:	0d05                	addi	s10,s10,1
    d8c0:	1815d30b          	th.sbia	t1,(a1),1,0
    d8c4:	09a78863          	beq	a5,s10,d954 <_vsnprintf+0x4d84>
    d8c8:	0d05                	addi	s10,s10,1
    d8ca:	1815d30b          	th.sbia	t1,(a1),1,0
    d8ce:	09a78363          	beq	a5,s10,d954 <_vsnprintf+0x4d84>
    d8d2:	0d05                	addi	s10,s10,1
    d8d4:	1815d30b          	th.sbia	t1,(a1),1,0
    d8d8:	07a78e63          	beq	a5,s10,d954 <_vsnprintf+0x4d84>
    d8dc:	0d05                	addi	s10,s10,1
    d8de:	1815d30b          	th.sbia	t1,(a1),1,0
    d8e2:	07a78963          	beq	a5,s10,d954 <_vsnprintf+0x4d84>
    d8e6:	0d05                	addi	s10,s10,1
    d8e8:	1815d30b          	th.sbia	t1,(a1),1,0
    d8ec:	07a78463          	beq	a5,s10,d954 <_vsnprintf+0x4d84>
    d8f0:	179d07e3          	beq	s10,s9,e25e <_vsnprintf+0x568e>
    d8f4:	0d05                	addi	s10,s10,1
    d8f6:	00658023          	sb	t1,0(a1)
    d8fa:	83ea                	mv	t2,s10
    d8fc:	05a78c63          	beq	a5,s10,d954 <_vsnprintf+0x4d84>
    d900:	0d05                	addi	s10,s10,1
    d902:	006580a3          	sb	t1,1(a1)
    d906:	05a78763          	beq	a5,s10,d954 <_vsnprintf+0x4d84>
    d90a:	00238d13          	addi	s10,t2,2
    d90e:	00658123          	sb	t1,2(a1)
    d912:	05a78163          	beq	a5,s10,d954 <_vsnprintf+0x4d84>
    d916:	00338d13          	addi	s10,t2,3
    d91a:	006581a3          	sb	t1,3(a1)
    d91e:	03a78b63          	beq	a5,s10,d954 <_vsnprintf+0x4d84>
    d922:	00438d13          	addi	s10,t2,4
    d926:	00658223          	sb	t1,4(a1)
    d92a:	03a78563          	beq	a5,s10,d954 <_vsnprintf+0x4d84>
    d92e:	00538d13          	addi	s10,t2,5
    d932:	006582a3          	sb	t1,5(a1)
    d936:	01a78f63          	beq	a5,s10,d954 <_vsnprintf+0x4d84>
    d93a:	00638d13          	addi	s10,t2,6
    d93e:	00658323          	sb	t1,6(a1)
    d942:	01a78963          	beq	a5,s10,d954 <_vsnprintf+0x4d84>
    d946:	006583a3          	sb	t1,7(a1)
    d94a:	00738d13          	addi	s10,t2,7
    d94e:	05a1                	addi	a1,a1,8
    d950:	fba790e3          	bne	a5,s10,d8f0 <_vsnprintf+0x4d20>
    d954:	4a0e9be3          	bnez	t4,e60a <_vsnprintf+0x5a3a>
    d958:	819d0663          	beq	s10,s9,c964 <_vsnprintf+0x3d94>
    d95c:	00367b93          	andi	s7,a2,3
    d960:	000b8463          	beqz	s7,d968 <_vsnprintf+0x4d98>
    d964:	3160106f          	j	ec7a <_vsnprintf+0x60aa>
    d968:	8c3e                	mv	s8,a5
    d96a:	10fd67e3          	bltu	s10,a5,e278 <_vsnprintf+0x56a8>
    d96e:	6382                	ld	t2,0(sp)
    d970:	ffdfe06f          	j	c96c <_vsnprintf+0x3d9c>
    d974:	4d09                	li	s10,2
    d976:	500b83e3          	beqz	s7,e67c <_vsnprintf+0x5aac>
    d97a:	4b41                	li	s6,16
    d97c:	57668be3          	beq	a3,s6,e6f2 <_vsnprintf+0x5b22>
    d980:	4a89                	li	s5,2
    d982:	555688e3          	beq	a3,s5,e6d2 <_vsnprintf+0x5b02>
    d986:	02000593          	li	a1,32
    d98a:	5cb71663          	bne	a4,a1,df56 <_vsnprintf+0x5386>
    d98e:	003e7513          	andi	a0,t3,3
    d992:	c119                	beqz	a0,d998 <_vsnprintf+0x4dc8>
    d994:	ce5fd06f          	j	b678 <_vsnprintf+0x2aa8>
    d998:	02000713          	li	a4,32
    d99c:	01176463          	bltu	a4,a7,d9a4 <_vsnprintf+0x4dd4>
    d9a0:	cd9fd06f          	j	b678 <_vsnprintf+0x2aa8>
    d9a4:	7c08bc0b          	th.extu	s8,a7,31,0
    d9a8:	6602                	ld	a2,0(sp)
    d9aa:	ec3a                	sd	a4,24(sp)
    d9ac:	f046                	sd	a7,32(sp)
    d9ae:	40c70cb3          	sub	s9,a4,a2
    d9b2:	fffcc813          	not	a6,s9
    d9b6:	40c80eb3          	sub	t4,a6,a2
    d9ba:	018e8b33          	add	s6,t4,s8
    d9be:	02000513          	li	a0,32
    d9c2:	86a6                	mv	a3,s1
    d9c4:	85ca                	mv	a1,s2
    d9c6:	007b7a93          	andi	s5,s6,7
    d9ca:	00160b13          	addi	s6,a2,1
    d9ce:	9402                	jalr	s0
    d9d0:	016c8533          	add	a0,s9,s6
    d9d4:	6762                	ld	a4,24(sp)
    d9d6:	7882                	ld	a7,32(sp)
    d9d8:	17857263          	bgeu	a0,s8,db3c <_vsnprintf+0x4f6c>
    d9dc:	0c0a8763          	beqz	s5,daaa <_vsnprintf+0x4eda>
    d9e0:	4305                	li	t1,1
    d9e2:	0a6a8563          	beq	s5,t1,da8c <_vsnprintf+0x4ebc>
    d9e6:	4289                	li	t0,2
    d9e8:	085a8763          	beq	s5,t0,da76 <_vsnprintf+0x4ea6>
    d9ec:	438d                	li	t2,3
    d9ee:	067a8963          	beq	s5,t2,da60 <_vsnprintf+0x4e90>
    d9f2:	4f11                	li	t5,4
    d9f4:	05ea8b63          	beq	s5,t5,da4a <_vsnprintf+0x4e7a>
    d9f8:	4695                	li	a3,5
    d9fa:	02da8d63          	beq	s5,a3,da34 <_vsnprintf+0x4e64>
    d9fe:	4799                	li	a5,6
    da00:	00fa8f63          	beq	s5,a5,da1e <_vsnprintf+0x4e4e>
    da04:	ec46                	sd	a7,24(sp)
    da06:	f03a                	sd	a4,32(sp)
    da08:	865a                	mv	a2,s6
    da0a:	86a6                	mv	a3,s1
    da0c:	85ca                	mv	a1,s2
    da0e:	02000513          	li	a0,32
    da12:	6b82                	ld	s7,0(sp)
    da14:	9402                	jalr	s0
    da16:	68e2                	ld	a7,24(sp)
    da18:	7702                	ld	a4,32(sp)
    da1a:	002b8b13          	addi	s6,s7,2
    da1e:	ec46                	sd	a7,24(sp)
    da20:	f03a                	sd	a4,32(sp)
    da22:	865a                	mv	a2,s6
    da24:	86a6                	mv	a3,s1
    da26:	85ca                	mv	a1,s2
    da28:	02000513          	li	a0,32
    da2c:	9402                	jalr	s0
    da2e:	68e2                	ld	a7,24(sp)
    da30:	7702                	ld	a4,32(sp)
    da32:	0b05                	addi	s6,s6,1
    da34:	ec46                	sd	a7,24(sp)
    da36:	f03a                	sd	a4,32(sp)
    da38:	865a                	mv	a2,s6
    da3a:	86a6                	mv	a3,s1
    da3c:	85ca                	mv	a1,s2
    da3e:	02000513          	li	a0,32
    da42:	9402                	jalr	s0
    da44:	68e2                	ld	a7,24(sp)
    da46:	7702                	ld	a4,32(sp)
    da48:	0b05                	addi	s6,s6,1
    da4a:	ec46                	sd	a7,24(sp)
    da4c:	f03a                	sd	a4,32(sp)
    da4e:	865a                	mv	a2,s6
    da50:	86a6                	mv	a3,s1
    da52:	85ca                	mv	a1,s2
    da54:	02000513          	li	a0,32
    da58:	9402                	jalr	s0
    da5a:	68e2                	ld	a7,24(sp)
    da5c:	7702                	ld	a4,32(sp)
    da5e:	0b05                	addi	s6,s6,1
    da60:	ec46                	sd	a7,24(sp)
    da62:	f03a                	sd	a4,32(sp)
    da64:	865a                	mv	a2,s6
    da66:	86a6                	mv	a3,s1
    da68:	85ca                	mv	a1,s2
    da6a:	02000513          	li	a0,32
    da6e:	9402                	jalr	s0
    da70:	68e2                	ld	a7,24(sp)
    da72:	7702                	ld	a4,32(sp)
    da74:	0b05                	addi	s6,s6,1
    da76:	ec46                	sd	a7,24(sp)
    da78:	f03a                	sd	a4,32(sp)
    da7a:	865a                	mv	a2,s6
    da7c:	86a6                	mv	a3,s1
    da7e:	85ca                	mv	a1,s2
    da80:	02000513          	li	a0,32
    da84:	9402                	jalr	s0
    da86:	68e2                	ld	a7,24(sp)
    da88:	7702                	ld	a4,32(sp)
    da8a:	0b05                	addi	s6,s6,1
    da8c:	ec46                	sd	a7,24(sp)
    da8e:	f03a                	sd	a4,32(sp)
    da90:	865a                	mv	a2,s6
    da92:	86a6                	mv	a3,s1
    da94:	85ca                	mv	a1,s2
    da96:	02000513          	li	a0,32
    da9a:	9402                	jalr	s0
    da9c:	0b05                	addi	s6,s6,1
    da9e:	016c8fb3          	add	t6,s9,s6
    daa2:	68e2                	ld	a7,24(sp)
    daa4:	7702                	ld	a4,32(sp)
    daa6:	098ffb63          	bgeu	t6,s8,db3c <_vsnprintf+0x4f6c>
    daaa:	ec6e                	sd	s11,24(sp)
    daac:	8dc6                	mv	s11,a7
    daae:	f03a                	sd	a4,32(sp)
    dab0:	865a                	mv	a2,s6
    dab2:	86a6                	mv	a3,s1
    dab4:	85ca                	mv	a1,s2
    dab6:	02000513          	li	a0,32
    daba:	9402                	jalr	s0
    dabc:	001b0a93          	addi	s5,s6,1
    dac0:	8656                	mv	a2,s5
    dac2:	86a6                	mv	a3,s1
    dac4:	85ca                	mv	a1,s2
    dac6:	02000513          	li	a0,32
    daca:	9402                	jalr	s0
    dacc:	002b0b93          	addi	s7,s6,2
    dad0:	865e                	mv	a2,s7
    dad2:	86a6                	mv	a3,s1
    dad4:	85ca                	mv	a1,s2
    dad6:	02000513          	li	a0,32
    dada:	9402                	jalr	s0
    dadc:	003b0a93          	addi	s5,s6,3
    dae0:	8656                	mv	a2,s5
    dae2:	86a6                	mv	a3,s1
    dae4:	85ca                	mv	a1,s2
    dae6:	02000513          	li	a0,32
    daea:	9402                	jalr	s0
    daec:	004b0b93          	addi	s7,s6,4
    daf0:	865e                	mv	a2,s7
    daf2:	86a6                	mv	a3,s1
    daf4:	85ca                	mv	a1,s2
    daf6:	02000513          	li	a0,32
    dafa:	9402                	jalr	s0
    dafc:	005b0a93          	addi	s5,s6,5
    db00:	8656                	mv	a2,s5
    db02:	86a6                	mv	a3,s1
    db04:	85ca                	mv	a1,s2
    db06:	02000513          	li	a0,32
    db0a:	9402                	jalr	s0
    db0c:	006b0b93          	addi	s7,s6,6
    db10:	86a6                	mv	a3,s1
    db12:	865e                	mv	a2,s7
    db14:	85ca                	mv	a1,s2
    db16:	02000513          	li	a0,32
    db1a:	9402                	jalr	s0
    db1c:	007b0a93          	addi	s5,s6,7
    db20:	86a6                	mv	a3,s1
    db22:	8656                	mv	a2,s5
    db24:	85ca                	mv	a1,s2
    db26:	02000513          	li	a0,32
    db2a:	9402                	jalr	s0
    db2c:	0b21                	addi	s6,s6,8
    db2e:	016c88b3          	add	a7,s9,s6
    db32:	7702                	ld	a4,32(sp)
    db34:	f788ede3          	bltu	a7,s8,daae <_vsnprintf+0x4ede>
    db38:	88ee                	mv	a7,s11
    db3a:	6de2                	ld	s11,24(sp)
    db3c:	6c82                	ld	s9,0(sp)
    db3e:	fffc0e13          	addi	t3,s8,-1
    db42:	00170593          	addi	a1,a4,1
    db46:	40ee07b3          	sub	a5,t3,a4
    db4a:	00bc3633          	sltu	a2,s8,a1
    db4e:	42c0178b          	th.mvnez	a5,zero,a2
    db52:	001c8e93          	addi	t4,s9,1
    db56:	03010813          	addi	a6,sp,48
    db5a:	01d78e33          	add	t3,a5,t4
    db5e:	c319                	beqz	a4,db64 <_vsnprintf+0x4f94>
    db60:	b1ffd06f          	j	b67e <_vsnprintf+0x2aae>
    db64:	c7ffd06f          	j	b7e2 <_vsnprintf+0x2c12>
    db68:	4805                	li	a6,1
    db6a:	010d0463          	beq	s10,a6,db72 <_vsnprintf+0x4fa2>
    db6e:	1040106f          	j	ec72 <_vsnprintf+0x60a2>
    db72:	678d                	lui	a5,0x3
    db74:	05878293          	addi	t0,a5,88 # 3058 <matrix_mul_vect+0x68>
    db78:	02511823          	sh	t0,48(sp)
    db7c:	00457f93          	andi	t6,a0,4
    db80:	1a0f8ee3          	beqz	t6,e53c <_vsnprintf+0x596c>
    db84:	4b89                	li	s7,2
    db86:	87de                	mv	a5,s7
    db88:	4ac1                	li	s5,16
    db8a:	ce6fd06f          	j	b070 <_vsnprintf+0x24a0>
    db8e:	7c0c350b          	th.extu	a0,s8,31,0
    db92:	00a76463          	bltu	a4,a0,db9a <_vsnprintf+0x4fca>
    db96:	2f00106f          	j	ee86 <_vsnprintf+0x62b6>
    db9a:	001e7b13          	andi	s6,t3,1
    db9e:	aaaff06f          	j	ce48 <_vsnprintf+0x4278>
    dba2:	f2000353          	fmv.d.x	ft6,zero
    dba6:	a26513d3          	flt.d	t2,fa0,ft6
    dbaa:	00038463          	beqz	t2,dbb2 <_vsnprintf+0x4fe2>
    dbae:	91dfd06f          	j	b4ca <_vsnprintf+0x28fa>
    dbb2:	77fd                	lui	a5,0xfffff
    dbb4:	7ff78f93          	addi	t6,a5,2047 # fffffffffffff7ff <__kernel_stack+0xfffffffffff117ff>
    dbb8:	01fb7b33          	and	s6,s6,t6
    dbbc:	400b6e93          	ori	t4,s6,1024
    dbc0:	000e881b          	sext.w	a6,t4
    dbc4:	87c6                	mv	a5,a7
    dbc6:	876e                	mv	a4,s11
    dbc8:	f2068553          	fmv.d.x	fa0,a3
    dbcc:	a5bfc06f          	j	a626 <_vsnprintf+0x1a56>
    dbd0:	7c0c350b          	th.extu	a0,s8,31,0
    dbd4:	00ade463          	bltu	s11,a0,dbdc <_vsnprintf+0x500c>
    dbd8:	2c80106f          	j	eea0 <_vsnprintf+0x62d0>
    dbdc:	00167b13          	andi	s6,a2,1
    dbe0:	f64ff06f          	j	d344 <_vsnprintf+0x4774>
    dbe4:	0045fc13          	andi	s8,a1,4
    dbe8:	02b00513          	li	a0,43
    dbec:	000c1863          	bnez	s8,dbfc <_vsnprintf+0x502c>
    dbf0:	008d7593          	andi	a1,s10,8
    dbf4:	500587e3          	beqz	a1,e902 <_vsnprintf+0x5d32>
    dbf8:	02000513          	li	a0,32
    dbfc:	6302                	ld	t1,0(sp)
    dbfe:	02a10823          	sb	a0,48(sp)
    dc02:	4c05                	li	s8,1
    dc04:	4b09                	li	s6,2
    dc06:	03010b93          	addi	s7,sp,48
    dc0a:	84cfd06f          	j	ac56 <_vsnprintf+0x2086>
    dc0e:	0e0ec9e3          	bltz	t4,e500 <_vsnprintf+0x5930>
    dc12:	0046fe93          	andi	t4,a3,4
    dc16:	3e0e87e3          	beqz	t4,e804 <_vsnprintf+0x5c34>
    dc1a:	002782b3          	add	t0,a5,sp
    dc1e:	02b00513          	li	a0,43
    dc22:	02a28823          	sb	a0,48(t0)
    dc26:	8dc2                	mv	s11,a6
    dc28:	00178c13          	addi	s8,a5,1
    dc2c:	6802                	ld	a6,0(sp)
    dc2e:	4b09                	li	s6,2
    dc30:	e3afe06f          	j	c26a <_vsnprintf+0x369a>
    dc34:	5e0e9163          	bnez	t4,e216 <_vsnprintf+0x5646>
    dc38:	4d01                	li	s10,0
    dc3a:	003e7e13          	andi	t3,t3,3
    dc3e:	000e0463          	beqz	t3,dc46 <_vsnprintf+0x5076>
    dc42:	a37fd06f          	j	b678 <_vsnprintf+0x2aa8>
    dc46:	02000713          	li	a4,32
    dc4a:	7c08bc0b          	th.extu	s8,a7,31,0
    dc4e:	d5176de3          	bltu	a4,a7,d9a8 <_vsnprintf+0x4dd8>
    dc52:	a27fd06f          	j	b678 <_vsnprintf+0x2aa8>
    dc56:	0001                	nop
    dc58:	4b81                	li	s7,0
    dc5a:	020d0293          	addi	t0,s10,32
    dc5e:	03010e93          	addi	t4,sp,48
    dc62:	01d28fb3          	add	t6,t0,t4
    dc66:	05800713          	li	a4,88
    dc6a:	03000e13          	li	t3,48
    dc6e:	fcef8f23          	sb	a4,-34(t6)
    dc72:	fdcf8fa3          	sb	t3,-33(t6)
    dc76:	0045ff13          	andi	t5,a1,4
    dc7a:	000f0563          	beqz	t5,dc84 <_vsnprintf+0x50b4>
    dc7e:	87ea                	mv	a5,s10
    dc80:	bf0fd06f          	j	b070 <_vsnprintf+0x24a0>
    dc84:	89a1                	andi	a1,a1,8
    dc86:	e199                	bnez	a1,dc8c <_vsnprintf+0x50bc>
    dc88:	993fc06f          	j	a61a <_vsnprintf+0x1a4a>
    dc8c:	87ea                	mv	a5,s10
    dc8e:	811fd06f          	j	b49e <_vsnprintf+0x28ce>
    dc92:	a00d82e3          	beqz	s11,d696 <_vsnprintf+0x4ac6>
    dc96:	7c08b68b          	th.extu	a3,a7,31,0
    dc9a:	90d7e5e3          	bltu	a5,a3,d5a4 <_vsnprintf+0x49d4>
    dc9e:	0035fd13          	andi	s10,a1,3
    dca2:	000d0463          	beqz	s10,dcaa <_vsnprintf+0x50da>
    dca6:	30a0106f          	j	efb0 <_vsnprintf+0x63e0>
    dcaa:	04f14503          	lbu	a0,79(sp)
    dcae:	6382                	ld	t2,0(sp)
    dcb0:	8dc2                	mv	s11,a6
    dcb2:	02000d13          	li	s10,32
    dcb6:	4b01                	li	s6,0
    dcb8:	cbcfc06f          	j	a174 <_vsnprintf+0x15a4>
    dcbc:	002b7b93          	andi	s7,s6,2
    dcc0:	000b9463          	bnez	s7,dcc8 <_vsnprintf+0x50f8>
    dcc4:	ca7fd06f          	j	b96a <_vsnprintf+0x2d9a>
    dcc8:	6b02                	ld	s6,0(sp)
    dcca:	4b81                	li	s7,0
    dccc:	e98fb06f          	j	9364 <_vsnprintf+0x794>
    dcd0:	4b89                	li	s7,2
    dcd2:	4ac1                	li	s5,16
    dcd4:	03010b13          	addi	s6,sp,48
    dcd8:	fc6fd06f          	j	b49e <_vsnprintf+0x28ce>
    dcdc:	020e8fe3          	beqz	t4,e51a <_vsnprintf+0x594a>
    dce0:	040b9863          	bnez	s7,dd30 <_vsnprintf+0x5160>
    dce4:	00e50763          	beq	a0,a4,dcf2 <_vsnprintf+0x5122>
    dce8:	7c08be8b          	th.extu	t4,a7,31,0
    dcec:	8d5e                	mv	s10,s7
    dcee:	c8ee96e3          	bne	t4,a4,d97a <_vsnprintf+0x4daa>
    dcf2:	fff70793          	addi	a5,a4,-1
    dcf6:	40079ae3          	bnez	a5,e90a <_vsnprintf+0x5d3a>
    dcfa:	4741                	li	a4,16
    dcfc:	58e68de3          	beq	a3,a4,ea96 <_vsnprintf+0x5ec6>
    dd00:	4d09                	li	s10,2
    dd02:	01a69463          	bne	a3,s10,dd0a <_vsnprintf+0x513a>
    dd06:	2f00106f          	j	eff6 <_vsnprintf+0x6426>
    dd0a:	03000e93          	li	t4,48
    dd0e:	03d10823          	sb	t4,48(sp)
    dd12:	003e7e13          	andi	t3,t3,3
    dd16:	000e1463          	bnez	t3,dd1e <_vsnprintf+0x514e>
    dd1a:	2c60106f          	j	efe0 <_vsnprintf+0x6410>
    dd1e:	6e02                	ld	t3,0(sp)
    dd20:	8d5e                	mv	s10,s7
    dd22:	4705                	li	a4,1
    dd24:	95bfd06f          	j	b67e <_vsnprintf+0x2aae>
    dd28:	3eec00e3          	beq	s8,a4,e908 <_vsnprintf+0x5d38>
    dd2c:	3ce88ee3          	beq	a7,a4,e908 <_vsnprintf+0x5d38>
    dd30:	4d01                	li	s10,0
    dd32:	b1a1                	j	d97a <_vsnprintf+0x4daa>
    dd34:	4d09                	li	s10,2
    dd36:	7c0c350b          	th.extu	a0,s8,31,0
    dd3a:	2e0b8663          	beqz	s7,e026 <_vsnprintf+0x5456>
    dd3e:	4f41                	li	t5,16
    dd40:	49e68d63          	beq	a3,t5,e1da <_vsnprintf+0x560a>
    dd44:	4789                	li	a5,2
    dd46:	40f687e3          	beq	a3,a5,e954 <_vsnprintf+0x5d84>
    dd4a:	02000f13          	li	t5,32
    dd4e:	29ed9d63          	bne	s11,t5,dfe8 <_vsnprintf+0x5418>
    dd52:	00367d93          	andi	s11,a2,3
    dd56:	000d8463          	beqz	s11,dd5e <_vsnprintf+0x518e>
    dd5a:	e69fd06f          	j	bbc2 <_vsnprintf+0x2ff2>
    dd5e:	02000613          	li	a2,32
    dd62:	01166463          	bltu	a2,a7,dd6a <_vsnprintf+0x519a>
    dd66:	e5dfd06f          	j	bbc2 <_vsnprintf+0x2ff2>
    dd6a:	7c08bc0b          	th.extu	s8,a7,31,0
    dd6e:	8db2                	mv	s11,a2
    dd70:	6602                	ld	a2,0(sp)
    dd72:	02000513          	li	a0,32
    dd76:	ec46                	sd	a7,24(sp)
    dd78:	40cd8cb3          	sub	s9,s11,a2
    dd7c:	fffcc813          	not	a6,s9
    dd80:	01880bb3          	add	s7,a6,s8
    dd84:	40cb8b33          	sub	s6,s7,a2
    dd88:	86a6                	mv	a3,s1
    dd8a:	85ca                	mv	a1,s2
    dd8c:	007b7b93          	andi	s7,s6,7
    dd90:	00160b13          	addi	s6,a2,1
    dd94:	9402                	jalr	s0
    dd96:	016c8533          	add	a0,s9,s6
    dd9a:	68e2                	ld	a7,24(sp)
    dd9c:	15857663          	bgeu	a0,s8,dee8 <_vsnprintf+0x5318>
    dda0:	0a0b8963          	beqz	s7,de52 <_vsnprintf+0x5282>
    dda4:	4705                	li	a4,1
    dda6:	08eb8963          	beq	s7,a4,de38 <_vsnprintf+0x5268>
    ddaa:	4f89                	li	t6,2
    ddac:	07fb8d63          	beq	s7,t6,de26 <_vsnprintf+0x5256>
    ddb0:	468d                	li	a3,3
    ddb2:	06db8163          	beq	s7,a3,de14 <_vsnprintf+0x5244>
    ddb6:	4f11                	li	t5,4
    ddb8:	05eb8563          	beq	s7,t5,de02 <_vsnprintf+0x5232>
    ddbc:	4795                	li	a5,5
    ddbe:	02fb8963          	beq	s7,a5,ddf0 <_vsnprintf+0x5220>
    ddc2:	4399                	li	t2,6
    ddc4:	007b8d63          	beq	s7,t2,ddde <_vsnprintf+0x520e>
    ddc8:	6302                	ld	t1,0(sp)
    ddca:	865a                	mv	a2,s6
    ddcc:	ec46                	sd	a7,24(sp)
    ddce:	86a6                	mv	a3,s1
    ddd0:	85ca                	mv	a1,s2
    ddd2:	02000513          	li	a0,32
    ddd6:	00230b13          	addi	s6,t1,2
    ddda:	9402                	jalr	s0
    dddc:	68e2                	ld	a7,24(sp)
    ddde:	865a                	mv	a2,s6
    dde0:	ec46                	sd	a7,24(sp)
    dde2:	86a6                	mv	a3,s1
    dde4:	85ca                	mv	a1,s2
    dde6:	02000513          	li	a0,32
    ddea:	9402                	jalr	s0
    ddec:	68e2                	ld	a7,24(sp)
    ddee:	0b05                	addi	s6,s6,1
    ddf0:	865a                	mv	a2,s6
    ddf2:	ec46                	sd	a7,24(sp)
    ddf4:	86a6                	mv	a3,s1
    ddf6:	85ca                	mv	a1,s2
    ddf8:	02000513          	li	a0,32
    ddfc:	9402                	jalr	s0
    ddfe:	68e2                	ld	a7,24(sp)
    de00:	0b05                	addi	s6,s6,1
    de02:	865a                	mv	a2,s6
    de04:	ec46                	sd	a7,24(sp)
    de06:	86a6                	mv	a3,s1
    de08:	85ca                	mv	a1,s2
    de0a:	02000513          	li	a0,32
    de0e:	9402                	jalr	s0
    de10:	68e2                	ld	a7,24(sp)
    de12:	0b05                	addi	s6,s6,1
    de14:	865a                	mv	a2,s6
    de16:	ec46                	sd	a7,24(sp)
    de18:	86a6                	mv	a3,s1
    de1a:	85ca                	mv	a1,s2
    de1c:	02000513          	li	a0,32
    de20:	9402                	jalr	s0
    de22:	68e2                	ld	a7,24(sp)
    de24:	0b05                	addi	s6,s6,1
    de26:	865a                	mv	a2,s6
    de28:	ec46                	sd	a7,24(sp)
    de2a:	86a6                	mv	a3,s1
    de2c:	85ca                	mv	a1,s2
    de2e:	02000513          	li	a0,32
    de32:	9402                	jalr	s0
    de34:	68e2                	ld	a7,24(sp)
    de36:	0b05                	addi	s6,s6,1
    de38:	865a                	mv	a2,s6
    de3a:	ec46                	sd	a7,24(sp)
    de3c:	86a6                	mv	a3,s1
    de3e:	85ca                	mv	a1,s2
    de40:	02000513          	li	a0,32
    de44:	9402                	jalr	s0
    de46:	0b05                	addi	s6,s6,1
    de48:	016c8eb3          	add	t4,s9,s6
    de4c:	68e2                	ld	a7,24(sp)
    de4e:	098efd63          	bgeu	t4,s8,dee8 <_vsnprintf+0x5318>
    de52:	ec6e                	sd	s11,24(sp)
    de54:	f06a                	sd	s10,32(sp)
    de56:	8dd6                	mv	s11,s5
    de58:	8d46                	mv	s10,a7
    de5a:	865a                	mv	a2,s6
    de5c:	86a6                	mv	a3,s1
    de5e:	85ca                	mv	a1,s2
    de60:	02000513          	li	a0,32
    de64:	9402                	jalr	s0
    de66:	001b0b93          	addi	s7,s6,1
    de6a:	865e                	mv	a2,s7
    de6c:	86a6                	mv	a3,s1
    de6e:	85ca                	mv	a1,s2
    de70:	02000513          	li	a0,32
    de74:	9402                	jalr	s0
    de76:	002b0a93          	addi	s5,s6,2
    de7a:	8656                	mv	a2,s5
    de7c:	86a6                	mv	a3,s1
    de7e:	85ca                	mv	a1,s2
    de80:	02000513          	li	a0,32
    de84:	9402                	jalr	s0
    de86:	003b0b93          	addi	s7,s6,3
    de8a:	865e                	mv	a2,s7
    de8c:	86a6                	mv	a3,s1
    de8e:	85ca                	mv	a1,s2
    de90:	02000513          	li	a0,32
    de94:	9402                	jalr	s0
    de96:	004b0a93          	addi	s5,s6,4
    de9a:	8656                	mv	a2,s5
    de9c:	86a6                	mv	a3,s1
    de9e:	85ca                	mv	a1,s2
    dea0:	02000513          	li	a0,32
    dea4:	9402                	jalr	s0
    dea6:	005b0b93          	addi	s7,s6,5
    deaa:	865e                	mv	a2,s7
    deac:	86a6                	mv	a3,s1
    deae:	85ca                	mv	a1,s2
    deb0:	02000513          	li	a0,32
    deb4:	9402                	jalr	s0
    deb6:	006b0a93          	addi	s5,s6,6
    deba:	86a6                	mv	a3,s1
    debc:	8656                	mv	a2,s5
    debe:	85ca                	mv	a1,s2
    dec0:	02000513          	li	a0,32
    dec4:	9402                	jalr	s0
    dec6:	007b0b93          	addi	s7,s6,7
    deca:	86a6                	mv	a3,s1
    decc:	865e                	mv	a2,s7
    dece:	85ca                	mv	a1,s2
    ded0:	02000513          	li	a0,32
    ded4:	0b21                	addi	s6,s6,8
    ded6:	9402                	jalr	s0
    ded8:	016c88b3          	add	a7,s9,s6
    dedc:	f788efe3          	bltu	a7,s8,de5a <_vsnprintf+0x528a>
    dee0:	88ea                	mv	a7,s10
    dee2:	8aee                	mv	s5,s11
    dee4:	6de2                	ld	s11,24(sp)
    dee6:	7d02                	ld	s10,32(sp)
    dee8:	6c82                	ld	s9,0(sp)
    deea:	fffc0e13          	addi	t3,s8,-1
    deee:	001d8593          	addi	a1,s11,1
    def2:	41be02b3          	sub	t0,t3,s11
    def6:	00bc3633          	sltu	a2,s8,a1
    defa:	42c0128b          	th.mvnez	t0,zero,a2
    defe:	001c8513          	addi	a0,s9,1
    df02:	03010813          	addi	a6,sp,48
    df06:	00a286b3          	add	a3,t0,a0
    df0a:	000d8463          	beqz	s11,df12 <_vsnprintf+0x5342>
    df0e:	cbbfd06f          	j	bbc8 <_vsnprintf+0x2ff8>
    df12:	8db6                	mv	s11,a3
    df14:	000d1463          	bnez	s10,df1c <_vsnprintf+0x534c>
    df18:	e1dfd06f          	j	bd34 <_vsnprintf+0x3164>
    df1c:	e2ffd06f          	j	bd4a <_vsnprintf+0x317a>
    df20:	8d46                	mv	s10,a7
    df22:	8a9a                	mv	s5,t1
    df24:	bc8fc06f          	j	a2ec <_vsnprintf+0x171c>
    df28:	00a77463          	bgeu	a4,a0,df30 <_vsnprintf+0x5360>
    df2c:	f1dfe06f          	j	ce48 <_vsnprintf+0x4278>
    df30:	000e9463          	bnez	t4,df38 <_vsnprintf+0x5368>
    df34:	05c0106f          	j	ef90 <_vsnprintf+0x63c0>
    df38:	da0b86e3          	beqz	s7,dce4 <_vsnprintf+0x5114>
    df3c:	4d41                	li	s10,16
    df3e:	7ba68963          	beq	a3,s10,e6f0 <_vsnprintf+0x5b20>
    df42:	4e89                	li	t4,2
    df44:	01d69463          	bne	a3,t4,df4c <_vsnprintf+0x537c>
    df48:	0560106f          	j	ef9e <_vsnprintf+0x63ce>
    df4c:	02000693          	li	a3,32
    df50:	4d01                	li	s10,0
    df52:	a4d703e3          	beq	a4,a3,d998 <_vsnprintf+0x4dc8>
    df56:	002707b3          	add	a5,a4,sp
    df5a:	03000b93          	li	s7,48
    df5e:	00170f13          	addi	t5,a4,1
    df62:	03778823          	sb	s7,48(a5)
    df66:	02000f93          	li	t6,32
    df6a:	cdff08e3          	beq	t5,t6,dc3a <_vsnprintf+0x506a>
    df6e:	877a                	mv	a4,t5
    df70:	ab55                	j	e524 <_vsnprintf+0x5954>
    df72:	0001                	nop
    df74:	4b81                	li	s7,0
    df76:	47c1                	li	a5,16
    df78:	d26fd06f          	j	b49e <_vsnprintf+0x28ce>
    df7c:	4a0e4263          	bltz	t3,e420 <_vsnprintf+0x5850>
    df80:	0042fe13          	andi	t3,t0,4
    df84:	660e05e3          	beqz	t3,edee <_vsnprintf+0x621e>
    df88:	02078593          	addi	a1,a5,32
    df8c:	03010c93          	addi	s9,sp,48
    df90:	00178d13          	addi	s10,a5,1
    df94:	01958db3          	add	s11,a1,s9
    df98:	02b00693          	li	a3,43
    df9c:	fedd8023          	sb	a3,-32(s11)
    dfa0:	6382                	ld	t2,0(sp)
    dfa2:	8dc2                	mv	s11,a6
    dfa4:	8536                	mv	a0,a3
    dfa6:	4b09                	li	s6,2
    dfa8:	9ccfc06f          	j	a174 <_vsnprintf+0x15a4>
    dfac:	040d0b63          	beqz	s10,e002 <_vsnprintf+0x5432>
    dfb0:	3c0b85e3          	beqz	s7,eb7a <_vsnprintf+0x5faa>
    dfb4:	4bc1                	li	s7,16
    dfb6:	3b768fe3          	beq	a3,s7,eb74 <_vsnprintf+0x5fa4>
    dfba:	4509                	li	a0,2
    dfbc:	4d01                	li	s10,0
    dfbe:	d8a696e3          	bne	a3,a0,dd4a <_vsnprintf+0x517a>
    dfc2:	bb41                	j	dd52 <_vsnprintf+0x5182>
    dfc4:	ffed8313          	addi	t1,s11,-2
    dfc8:	02030c93          	addi	s9,t1,32
    dfcc:	03010e13          	addi	t3,sp,48
    dfd0:	02067e93          	andi	t4,a2,32
    dfd4:	1dfd                	addi	s11,s11,-1
    dfd6:	01cc82b3          	add	t0,s9,t3
    dfda:	4c0e96e3          	bnez	t4,eca6 <_vsnprintf+0x60d6>
    dfde:	07800d13          	li	s10,120
    dfe2:	ffa28023          	sb	s10,-32(t0)
    dfe6:	8d5e                	mv	s10,s7
    dfe8:	002d8eb3          	add	t4,s11,sp
    dfec:	03000c93          	li	s9,48
    dff0:	001d8793          	addi	a5,s11,1
    dff4:	039e8823          	sb	s9,48(t4)
    dff8:	02000e13          	li	t3,32
    dffc:	8dbe                	mv	s11,a5
    dffe:	09c79263          	bne	a5,t3,e082 <_vsnprintf+0x54b2>
    e002:	00367593          	andi	a1,a2,3
    e006:	c199                	beqz	a1,e00c <_vsnprintf+0x543c>
    e008:	bbbfd06f          	j	bbc2 <_vsnprintf+0x2ff2>
    e00c:	02000d93          	li	s11,32
    e010:	7c08bc0b          	th.extu	s8,a7,31,0
    e014:	d51deee3          	bltu	s11,a7,dd70 <_vsnprintf+0x51a0>
    e018:	babfd06f          	j	bbc2 <_vsnprintf+0x2ff2>
    e01c:	040d0f63          	beqz	s10,e07a <_vsnprintf+0x54aa>
    e020:	4d01                	li	s10,0
    e022:	d00b9ee3          	bnez	s7,dd3e <_vsnprintf+0x516e>
    e026:	00ad8663          	beq	s11,a0,e032 <_vsnprintf+0x5462>
    e02a:	7c08bc0b          	th.extu	s8,a7,31,0
    e02e:	d18d98e3          	bne	s11,s8,dd3e <_vsnprintf+0x516e>
    e032:	fffd8e13          	addi	t3,s11,-1
    e036:	8bea                	mv	s7,s10
    e038:	020e1463          	bnez	t3,e060 <_vsnprintf+0x5490>
    e03c:	4dc1                	li	s11,16
    e03e:	3fb685e3          	beq	a3,s11,ec28 <_vsnprintf+0x6058>
    e042:	4b89                	li	s7,2
    e044:	597685e3          	beq	a3,s7,edce <_vsnprintf+0x61fe>
    e048:	03000513          	li	a0,48
    e04c:	02a10823          	sb	a0,48(sp)
    e050:	8a0d                	andi	a2,a2,3
    e052:	560604e3          	beqz	a2,edba <_vsnprintf+0x61ea>
    e056:	6682                	ld	a3,0(sp)
    e058:	4d85                	li	s11,1
    e05a:	b6ffd06f          	j	bbc8 <_vsnprintf+0x2ff8>
    e05e:	4e7d                	li	t3,31
    e060:	4b41                	li	s6,16
    e062:	f76681e3          	beq	a3,s6,dfc4 <_vsnprintf+0x53f4>
    e066:	4709                	li	a4,2
    e068:	40e68de3          	beq	a3,a4,ec82 <_vsnprintf+0x60b2>
    e06c:	002e0f33          	add	t5,t3,sp
    e070:	03000793          	li	a5,48
    e074:	02ff0823          	sb	a5,48(t5)
    e078:	8d5e                	mv	s10,s7
    e07a:	02000393          	li	t2,32
    e07e:	f87d82e3          	beq	s11,t2,e002 <_vsnprintf+0x5432>
    e082:	00367293          	andi	t0,a2,3
    e086:	00029663          	bnez	t0,e092 <_vsnprintf+0x54c2>
    e08a:	7c08bc0b          	th.extu	s8,a7,31,0
    e08e:	cf8de1e3          	bltu	s11,s8,dd70 <_vsnprintf+0x51a0>
    e092:	6682                	ld	a3,0(sp)
    e094:	b35fd06f          	j	bbc8 <_vsnprintf+0x2ff8>
    e098:	4e0edc63          	bgez	t4,e590 <_vsnprintf+0x59c0>
    e09c:	7c0c3c0b          	th.extu	s8,s8,31,0
    e0a0:	38fd                	addiw	a7,a7,-1
    e0a2:	0187f463          	bgeu	a5,s8,e0aa <_vsnprintf+0x54da>
    e0a6:	e33fd06f          	j	bed8 <_vsnprintf+0x3308>
    e0aa:	7c08b68b          	th.extu	a3,a7,31,0
    e0ae:	00d7f463          	bgeu	a5,a3,e0b6 <_vsnprintf+0x54e6>
    e0b2:	f25fd06f          	j	bfd6 <_vsnprintf+0x3406>
    e0b6:	02000293          	li	t0,32
    e0ba:	00579463          	bne	a5,t0,e0c2 <_vsnprintf+0x54f2>
    e0be:	9a0fe06f          	j	c25e <_vsnprintf+0x368e>
    e0c2:	86be                	mv	a3,a5
    e0c4:	810fe06f          	j	c0d4 <_vsnprintf+0x3504>
    e0c8:	7c0c3d0b          	th.extu	s10,s8,31,0
    e0cc:	65a7f8e3          	bgeu	a5,s10,ef1c <_vsnprintf+0x634c>
    e0d0:	0015fd93          	andi	s11,a1,1
    e0d4:	4881                	li	a7,0
    e0d6:	824fd06f          	j	b0fa <_vsnprintf+0x252a>
    e0da:	560d1463          	bnez	s10,e642 <_vsnprintf+0x5a72>
    e0de:	02000c13          	li	s8,32
    e0e2:	c58d8363          	beq	s11,s8,d528 <_vsnprintf+0x4958>
    e0e6:	8a0d                	andi	a2,a2,3
    e0e8:	f64d                	bnez	a2,e092 <_vsnprintf+0x54c2>
    e0ea:	8c2a                	mv	s8,a0
    e0ec:	c8ade2e3          	bltu	s11,a0,dd70 <_vsnprintf+0x51a0>
    e0f0:	6682                	ld	a3,0(sp)
    e0f2:	ad7fd06f          	j	bbc8 <_vsnprintf+0x2ff8>
    e0f6:	0001                	nop
    e0f8:	3e088463          	beqz	a7,e4e0 <_vsnprintf+0x5910>
    e0fc:	001f7b13          	andi	s6,t5,1
    e100:	7c0c350b          	th.extu	a0,s8,31,0
    e104:	03010813          	addi	a6,sp,48
    e108:	6a0b0063          	beqz	s6,e7a8 <_vsnprintf+0x5bd8>
    e10c:	7c08b78b          	th.extu	a5,a7,31,0
    e110:	c119                	beqz	a0,e116 <_vsnprintf+0x5546>
    e112:	d37fe06f          	j	ce48 <_vsnprintf+0x4278>
    e116:	e29fe06f          	j	cf3e <_vsnprintf+0x436e>
    e11a:	0001                	nop
    e11c:	7c0c3c0b          	th.extu	s8,s8,31,0
    e120:	0187f463          	bgeu	a5,s8,e128 <_vsnprintf+0x5558>
    e124:	c42fe06f          	j	c566 <_vsnprintf+0x3996>
    e128:	02000513          	li	a0,32
    e12c:	9aa78763          	beq	a5,a0,d2da <_vsnprintf+0x470a>
    e130:	060e5863          	bgez	t3,e1a0 <_vsnprintf+0x55d0>
    e134:	00a78633          	add	a2,a5,a0
    e138:	03010c93          	addi	s9,sp,48
    e13c:	01960733          	add	a4,a2,s9
    e140:	02d00a93          	li	s5,45
    e144:	00178c13          	addi	s8,a5,1
    e148:	ff570023          	sb	s5,-32(a4)
    e14c:	e20fe06f          	j	c76c <_vsnprintf+0x3b9c>
    e150:	002783b3          	add	t2,a5,sp
    e154:	02d00513          	li	a0,45
    e158:	02a38823          	sb	a0,48(t2)
    e15c:	6302                	ld	t1,0(sp)
    e15e:	00178c13          	addi	s8,a5,1
    e162:	4b09                	li	s6,2
    e164:	af3fc06f          	j	ac56 <_vsnprintf+0x2086>
    e168:	004af593          	andi	a1,s5,4
    e16c:	02b00513          	li	a0,43
    e170:	e599                	bnez	a1,e17e <_vsnprintf+0x55ae>
    e172:	008afc93          	andi	s9,s5,8
    e176:	780c8263          	beqz	s9,e8fa <_vsnprintf+0x5d2a>
    e17a:	02000513          	li	a0,32
    e17e:	8dc2                	mv	s11,a6
    e180:	02a10823          	sb	a0,48(sp)
    e184:	6802                	ld	a6,0(sp)
    e186:	4c05                	li	s8,1
    e188:	4b09                	li	s6,2
    e18a:	03010c93          	addi	s9,sp,48
    e18e:	8dcfe06f          	j	c26a <_vsnprintf+0x369a>
    e192:	7c0c3c0b          	th.extu	s8,s8,31,0
    e196:	4781                	li	a5,0
    e198:	03010b93          	addi	s7,sp,48
    e19c:	980c1363          	bnez	s8,d322 <_vsnprintf+0x4752>
    e1a0:	0045fb13          	andi	s6,a1,4
    e1a4:	8bae                	mv	s7,a1
    e1a6:	100b07e3          	beqz	s6,eab4 <_vsnprintf+0x5ee4>
    e1aa:	02078393          	addi	t2,a5,32
    e1ae:	03010f13          	addi	t5,sp,48
    e1b2:	01e38b33          	add	s6,t2,t5
    e1b6:	02b00513          	li	a0,43
    e1ba:	feab0023          	sb	a0,-32(s6)
    e1be:	0035f313          	andi	t1,a1,3
    e1c2:	00178c13          	addi	s8,a5,1
    e1c6:	00031463          	bnez	t1,e1ce <_vsnprintf+0x55fe>
    e1ca:	f49fe06f          	j	d112 <_vsnprintf+0x4542>
    e1ce:	6302                	ld	t1,0(sp)
    e1d0:	4b01                	li	s6,0
    e1d2:	8bfa                	mv	s7,t5
    e1d4:	a83fc06f          	j	ac56 <_vsnprintf+0x2086>
    e1d8:	4d01                	li	s10,0
    e1da:	02067c93          	andi	s9,a2,32
    e1de:	7c0c8163          	beqz	s9,e9a0 <_vsnprintf+0x5dd0>
    e1e2:	02000e13          	li	t3,32
    e1e6:	b7cd86e3          	beq	s11,t3,dd52 <_vsnprintf+0x5182>
    e1ea:	020d8293          	addi	t0,s11,32
    e1ee:	180c                	addi	a1,sp,48
    e1f0:	00b28bb3          	add	s7,t0,a1
    e1f4:	05800513          	li	a0,88
    e1f8:	feab8023          	sb	a0,-32(s7)
    e1fc:	0d85                	addi	s11,s11,1
    e1fe:	b6b1                	j	dd4a <_vsnprintf+0x517a>
    e200:	86be                	mv	a3,a5
    e202:	ebffd06f          	j	c0c0 <_vsnprintf+0x34f0>
    e206:	e119                	bnez	a0,e20c <_vsnprintf+0x563c>
    e208:	aa0fc06f          	j	a4a8 <_vsnprintf+0x18d8>
    e20c:	6c82                	ld	s9,0(sp)
    e20e:	2b85                	addiw	s7,s7,1
    e210:	4a81                	li	s5,0
    e212:	f81fa06f          	j	9192 <_vsnprintf+0x5c2>
    e216:	b00b89e3          	beqz	s7,dd28 <_vsnprintf+0x5158>
    e21a:	4c41                	li	s8,16
    e21c:	f7868963          	beq	a3,s8,d98e <_vsnprintf+0x4dbe>
    e220:	4589                	li	a1,2
    e222:	f6b69263          	bne	a3,a1,d986 <_vsnprintf+0x4db6>
    e226:	f68ff06f          	j	d98e <_vsnprintf+0x4dbe>
    e22a:	000b8463          	beqz	s7,e232 <_vsnprintf+0x5662>
    e22e:	9fafd06f          	j	b428 <_vsnprintf+0x2858>
    e232:	0045f293          	andi	t0,a1,4
    e236:	00028463          	beqz	t0,e23e <_vsnprintf+0x566e>
    e23a:	e37fc06f          	j	b070 <_vsnprintf+0x24a0>
    e23e:	0085fb93          	andi	s7,a1,8
    e242:	000b8463          	beqz	s7,e24a <_vsnprintf+0x567a>
    e246:	a56fd06f          	j	b49c <_vsnprintf+0x28cc>
    e24a:	8d3e                	mv	s10,a5
    e24c:	180c                	addi	a1,sp,48
    e24e:	02078793          	addi	a5,a5,32
    e252:	00b78fb3          	add	t6,a5,a1
    e256:	fdffc503          	lbu	a0,-33(t6)
    e25a:	e72fc06f          	j	a8cc <_vsnprintf+0x1cfc>
    e25e:	680e9563          	bnez	t4,e8e8 <_vsnprintf+0x5d18>
    e262:	4b81                	li	s7,0
    e264:	00367713          	andi	a4,a2,3
    e268:	5a071e63          	bnez	a4,e824 <_vsnprintf+0x5c54>
    e26c:	02000d13          	li	s10,32
    e270:	7c08bc0b          	th.extu	s8,a7,31,0
    e274:	5b1d7863          	bgeu	s10,a7,e824 <_vsnprintf+0x5c54>
    e278:	6602                	ld	a2,0(sp)
    e27a:	ec46                	sd	a7,24(sp)
    e27c:	86a6                	mv	a3,s1
    e27e:	40cd0b33          	sub	s6,s10,a2
    e282:	fffb4e93          	not	t4,s6
    e286:	018e8833          	add	a6,t4,s8
    e28a:	85ca                	mv	a1,s2
    e28c:	02000513          	li	a0,32
    e290:	40c80cb3          	sub	s9,a6,a2
    e294:	00160d93          	addi	s11,a2,1
    e298:	9402                	jalr	s0
    e29a:	01bb0333          	add	t1,s6,s11
    e29e:	68e2                	ld	a7,24(sp)
    e2a0:	007cfc93          	andi	s9,s9,7
    e2a4:	15837363          	bgeu	t1,s8,e3ea <_vsnprintf+0x581a>
    e2a8:	0a0c8863          	beqz	s9,e358 <_vsnprintf+0x5788>
    e2ac:	4685                	li	a3,1
    e2ae:	08dc8863          	beq	s9,a3,e33e <_vsnprintf+0x576e>
    e2b2:	4e09                	li	t3,2
    e2b4:	07cc8c63          	beq	s9,t3,e32c <_vsnprintf+0x575c>
    e2b8:	428d                	li	t0,3
    e2ba:	065c8063          	beq	s9,t0,e31a <_vsnprintf+0x574a>
    e2be:	4f91                	li	t6,4
    e2c0:	05fc8463          	beq	s9,t6,e308 <_vsnprintf+0x5738>
    e2c4:	4f15                	li	t5,5
    e2c6:	03ec8863          	beq	s9,t5,e2f6 <_vsnprintf+0x5726>
    e2ca:	4519                	li	a0,6
    e2cc:	00ac8c63          	beq	s9,a0,e2e4 <_vsnprintf+0x5714>
    e2d0:	866e                	mv	a2,s11
    e2d2:	ec46                	sd	a7,24(sp)
    e2d4:	86a6                	mv	a3,s1
    e2d6:	85ca                	mv	a1,s2
    e2d8:	02000513          	li	a0,32
    e2dc:	6d82                	ld	s11,0(sp)
    e2de:	9402                	jalr	s0
    e2e0:	68e2                	ld	a7,24(sp)
    e2e2:	0d89                	addi	s11,s11,2
    e2e4:	866e                	mv	a2,s11
    e2e6:	ec46                	sd	a7,24(sp)
    e2e8:	86a6                	mv	a3,s1
    e2ea:	85ca                	mv	a1,s2
    e2ec:	02000513          	li	a0,32
    e2f0:	9402                	jalr	s0
    e2f2:	68e2                	ld	a7,24(sp)
    e2f4:	0d85                	addi	s11,s11,1
    e2f6:	866e                	mv	a2,s11
    e2f8:	ec46                	sd	a7,24(sp)
    e2fa:	86a6                	mv	a3,s1
    e2fc:	85ca                	mv	a1,s2
    e2fe:	02000513          	li	a0,32
    e302:	9402                	jalr	s0
    e304:	68e2                	ld	a7,24(sp)
    e306:	0d85                	addi	s11,s11,1
    e308:	866e                	mv	a2,s11
    e30a:	ec46                	sd	a7,24(sp)
    e30c:	86a6                	mv	a3,s1
    e30e:	85ca                	mv	a1,s2
    e310:	02000513          	li	a0,32
    e314:	9402                	jalr	s0
    e316:	68e2                	ld	a7,24(sp)
    e318:	0d85                	addi	s11,s11,1
    e31a:	866e                	mv	a2,s11
    e31c:	ec46                	sd	a7,24(sp)
    e31e:	86a6                	mv	a3,s1
    e320:	85ca                	mv	a1,s2
    e322:	02000513          	li	a0,32
    e326:	9402                	jalr	s0
    e328:	68e2                	ld	a7,24(sp)
    e32a:	0d85                	addi	s11,s11,1
    e32c:	866e                	mv	a2,s11
    e32e:	ec46                	sd	a7,24(sp)
    e330:	86a6                	mv	a3,s1
    e332:	85ca                	mv	a1,s2
    e334:	02000513          	li	a0,32
    e338:	9402                	jalr	s0
    e33a:	68e2                	ld	a7,24(sp)
    e33c:	0d85                	addi	s11,s11,1
    e33e:	866e                	mv	a2,s11
    e340:	ec46                	sd	a7,24(sp)
    e342:	86a6                	mv	a3,s1
    e344:	85ca                	mv	a1,s2
    e346:	02000513          	li	a0,32
    e34a:	9402                	jalr	s0
    e34c:	0d85                	addi	s11,s11,1
    e34e:	01bb07b3          	add	a5,s6,s11
    e352:	68e2                	ld	a7,24(sp)
    e354:	0987fb63          	bgeu	a5,s8,e3ea <_vsnprintf+0x581a>
    e358:	ec56                	sd	s5,24(sp)
    e35a:	f05e                	sd	s7,32(sp)
    e35c:	8bc6                	mv	s7,a7
    e35e:	866e                	mv	a2,s11
    e360:	86a6                	mv	a3,s1
    e362:	85ca                	mv	a1,s2
    e364:	02000513          	li	a0,32
    e368:	9402                	jalr	s0
    e36a:	001d8c93          	addi	s9,s11,1
    e36e:	8666                	mv	a2,s9
    e370:	86a6                	mv	a3,s1
    e372:	85ca                	mv	a1,s2
    e374:	02000513          	li	a0,32
    e378:	9402                	jalr	s0
    e37a:	002d8a93          	addi	s5,s11,2
    e37e:	8656                	mv	a2,s5
    e380:	86a6                	mv	a3,s1
    e382:	85ca                	mv	a1,s2
    e384:	02000513          	li	a0,32
    e388:	9402                	jalr	s0
    e38a:	003d8c93          	addi	s9,s11,3
    e38e:	8666                	mv	a2,s9
    e390:	86a6                	mv	a3,s1
    e392:	85ca                	mv	a1,s2
    e394:	02000513          	li	a0,32
    e398:	9402                	jalr	s0
    e39a:	004d8a93          	addi	s5,s11,4
    e39e:	8656                	mv	a2,s5
    e3a0:	86a6                	mv	a3,s1
    e3a2:	85ca                	mv	a1,s2
    e3a4:	02000513          	li	a0,32
    e3a8:	9402                	jalr	s0
    e3aa:	005d8c93          	addi	s9,s11,5
    e3ae:	8666                	mv	a2,s9
    e3b0:	86a6                	mv	a3,s1
    e3b2:	85ca                	mv	a1,s2
    e3b4:	02000513          	li	a0,32
    e3b8:	9402                	jalr	s0
    e3ba:	006d8a93          	addi	s5,s11,6
    e3be:	86a6                	mv	a3,s1
    e3c0:	8656                	mv	a2,s5
    e3c2:	85ca                	mv	a1,s2
    e3c4:	02000513          	li	a0,32
    e3c8:	9402                	jalr	s0
    e3ca:	007d8c93          	addi	s9,s11,7
    e3ce:	86a6                	mv	a3,s1
    e3d0:	8666                	mv	a2,s9
    e3d2:	85ca                	mv	a1,s2
    e3d4:	02000513          	li	a0,32
    e3d8:	0da1                	addi	s11,s11,8
    e3da:	9402                	jalr	s0
    e3dc:	01bb08b3          	add	a7,s6,s11
    e3e0:	f788efe3          	bltu	a7,s8,e35e <_vsnprintf+0x578e>
    e3e4:	88de                	mv	a7,s7
    e3e6:	6ae2                	ld	s5,24(sp)
    e3e8:	7b82                	ld	s7,32(sp)
    e3ea:	6602                	ld	a2,0(sp)
    e3ec:	fffc0393          	addi	t2,s8,-1
    e3f0:	001d0593          	addi	a1,s10,1
    e3f4:	41a387b3          	sub	a5,t2,s10
    e3f8:	00bc3733          	sltu	a4,s8,a1
    e3fc:	42e0178b          	th.mvnez	a5,zero,a4
    e400:	00160e93          	addi	t4,a2,1
    e404:	03010b13          	addi	s6,sp,48
    e408:	01d783b3          	add	t2,a5,t4
    e40c:	000d0463          	beqz	s10,e414 <_vsnprintf+0x5844>
    e410:	d5cfe06f          	j	c96c <_vsnprintf+0x3d9c>
    e414:	000b9463          	bnez	s7,e41c <_vsnprintf+0x584c>
    e418:	ea6fe06f          	j	cabe <_vsnprintf+0x3eee>
    e41c:	eb8fe06f          	j	cad4 <_vsnprintf+0x3f04>
    e420:	02078b93          	addi	s7,a5,32
    e424:	03010f93          	addi	t6,sp,48
    e428:	00178d13          	addi	s10,a5,1
    e42c:	01fb8db3          	add	s11,s7,t6
    e430:	02d00693          	li	a3,45
    e434:	b6a5                	j	df9c <_vsnprintf+0x53cc>
    e436:	000b9463          	bnez	s7,e43e <_vsnprintf+0x586e>
    e43a:	c8afc06f          	j	a8c4 <_vsnprintf+0x1cf4>
    e43e:	4b81                	li	s7,0
    e440:	000c8463          	beqz	s9,e448 <_vsnprintf+0x5878>
    e444:	c80fc06f          	j	a8c4 <_vsnprintf+0x1cf4>
    e448:	4b81                	li	s7,0
    e44a:	01af8463          	beq	t6,s10,e452 <_vsnprintf+0x5882>
    e44e:	cc4fe06f          	j	c912 <_vsnprintf+0x3d42>
    e452:	fffd0793          	addi	a5,s10,-1
    e456:	4b81                	li	s7,0
    e458:	020d0f13          	addi	t5,s10,32
    e45c:	03010893          	addi	a7,sp,48
    e460:	05800313          	li	t1,88
    e464:	011f0533          	add	a0,t5,a7
    e468:	fc650f23          	sb	t1,-34(a0)
    e46c:	ff1fc06f          	j	b45c <_vsnprintf+0x288c>
    e470:	36088a63          	beqz	a7,e7e4 <_vsnprintf+0x5c14>
    e474:	001ffb13          	andi	s6,t6,1
    e478:	7c0c350b          	th.extu	a0,s8,31,0
    e47c:	03010813          	addi	a6,sp,48
    e480:	340b0263          	beqz	s6,e7c4 <_vsnprintf+0x5bf4>
    e484:	c119                	beqz	a0,e48a <_vsnprintf+0x58ba>
    e486:	ebffe06f          	j	d344 <_vsnprintf+0x4774>
    e48a:	7c08b50b          	th.extu	a0,a7,31,0
    e48e:	fa9fe06f          	j	d436 <_vsnprintf+0x4866>
    e492:	0001                	nop
    e494:	ac0c1163          	bnez	s8,d756 <_vsnprintf+0x4b86>
    e498:	0045fb13          	andi	s6,a1,4
    e49c:	8cae                	mv	s9,a1
    e49e:	020b01e3          	beqz	s6,ecc0 <_vsnprintf+0x60f0>
    e4a2:	02078d93          	addi	s11,a5,32
    e4a6:	03010293          	addi	t0,sp,48
    e4aa:	005d8b33          	add	s6,s11,t0
    e4ae:	02b00513          	li	a0,43
    e4b2:	feab0023          	sb	a0,-32(s6)
    e4b6:	0035f313          	andi	t1,a1,3
    e4ba:	00178c13          	addi	s8,a5,1
    e4be:	7e031b63          	bnez	t1,ecb4 <_vsnprintf+0x60e4>
    e4c2:	7c08bb8b          	th.extu	s7,a7,31,0
    e4c6:	8dc2                	mv	s11,a6
    e4c8:	4b01                	li	s6,0
    e4ca:	017c7463          	bgeu	s8,s7,e4d2 <_vsnprintf+0x5902>
    e4ce:	fb6fe06f          	j	cc84 <_vsnprintf+0x40b4>
    e4d2:	6802                	ld	a6,0(sp)
    e4d4:	02b00513          	li	a0,43
    e4d8:	03010c93          	addi	s9,sp,48
    e4dc:	d8ffd06f          	j	c26a <_vsnprintf+0x369a>
    e4e0:	7c0c350b          	th.extu	a0,s8,31,0
    e4e4:	03010813          	addi	a6,sp,48
    e4e8:	ea051963          	bnez	a0,db9a <_vsnprintf+0x4fca>
    e4ec:	003f7693          	andi	a3,t5,3
    e4f0:	6e02                	ld	t3,0(sp)
    e4f2:	e299                	bnez	a3,e4f8 <_vsnprintf+0x5928>
    e4f4:	f99fb06f          	j	a48c <_vsnprintf+0x18bc>
    e4f8:	6e02                	ld	t3,0(sp)
    e4fa:	e072                	sd	t3,0(sp)
    e4fc:	fadfb06f          	j	a4a8 <_vsnprintf+0x18d8>
    e500:	00278bb3          	add	s7,a5,sp
    e504:	02d00513          	li	a0,45
    e508:	02ab8823          	sb	a0,48(s7)
    e50c:	8dc2                	mv	s11,a6
    e50e:	00178c13          	addi	s8,a5,1
    e512:	6802                	ld	a6,0(sp)
    e514:	4b09                	li	s6,2
    e516:	d55fd06f          	j	c26a <_vsnprintf+0x369a>
    e51a:	4d01                	li	s10,0
    e51c:	02000b93          	li	s7,32
    e520:	f1770d63          	beq	a4,s7,dc3a <_vsnprintf+0x506a>
    e524:	003e7593          	andi	a1,t3,3
    e528:	c199                	beqz	a1,e52e <_vsnprintf+0x595e>
    e52a:	b19fe06f          	j	d042 <_vsnprintf+0x4472>
    e52e:	7c08bc0b          	th.extu	s8,a7,31,0
    e532:	c7876b63          	bltu	a4,s8,d9a8 <_vsnprintf+0x4dd8>
    e536:	6e02                	ld	t3,0(sp)
    e538:	946fd06f          	j	b67e <_vsnprintf+0x2aae>
    e53c:	00857693          	andi	a3,a0,8
    e540:	4b89                	li	s7,2
    e542:	38069f63          	bnez	a3,e8e0 <_vsnprintf+0x5d10>
    e546:	05210f93          	addi	t6,sp,82
    e54a:	8d5e                	mv	s10,s7
    e54c:	4ac1                	li	s5,16
    e54e:	fdffc503          	lbu	a0,-33(t6)
    e552:	b7afc06f          	j	a8cc <_vsnprintf+0x1cfc>
    e556:	6682                	ld	a3,0(sp)
    e558:	4d09                	li	s10,2
    e55a:	e6efd06f          	j	bbc8 <_vsnprintf+0x2ff8>
    e55e:	7c0c3d0b          	th.extu	s10,s8,31,0
    e562:	01a7f463          	bgeu	a5,s10,e56a <_vsnprintf+0x599a>
    e566:	b95fc06f          	j	b0fa <_vsnprintf+0x252a>
    e56a:	02000f13          	li	t5,32
    e56e:	93e78863          	beq	a5,t5,d69e <_vsnprintf+0x4ace>
    e572:	1e0e5063          	bgez	t3,e752 <_vsnprintf+0x5b82>
    e576:	01e78ab3          	add	s5,a5,t5
    e57a:	1810                	addi	a2,sp,48
    e57c:	00178d13          	addi	s10,a5,1
    e580:	02d00713          	li	a4,45
    e584:	00ca87b3          	add	a5,s5,a2
    e588:	fee78023          	sb	a4,-32(a5)
    e58c:	c99fc06f          	j	b224 <_vsnprintf+0x2654>
    e590:	00c6ff13          	andi	t5,a3,12
    e594:	7c0c3c0b          	th.extu	s8,s8,31,0
    e598:	fff8869b          	addiw	a3,a7,-1
    e59c:	43e6988b          	th.mvnez	a7,a3,t5
    e5a0:	0187f463          	bgeu	a5,s8,e5a8 <_vsnprintf+0x59d8>
    e5a4:	935fd06f          	j	bed8 <_vsnprintf+0x3308>
    e5a8:	7c08b68b          	th.extu	a3,a7,31,0
    e5ac:	00d7f463          	bgeu	a5,a3,e5b4 <_vsnprintf+0x59e4>
    e5b0:	a27fd06f          	j	bfd6 <_vsnprintf+0x3406>
    e5b4:	02000e93          	li	t4,32
    e5b8:	01d79463          	bne	a5,t4,e5c0 <_vsnprintf+0x59f0>
    e5bc:	ca3fd06f          	j	c25e <_vsnprintf+0x368e>
    e5c0:	bde1                	j	e498 <_vsnprintf+0x58c8>
    e5c2:	0001                	nop
    e5c4:	6e02                	ld	t3,0(sp)
    e5c6:	4d09                	li	s10,2
    e5c8:	8b6fd06f          	j	b67e <_vsnprintf+0x2aae>
    e5cc:	4781                	li	a5,0
    e5ce:	00c5fb93          	andi	s7,a1,12
    e5d2:	fff8829b          	addiw	t0,a7,-1
    e5d6:	7c0c3c0b          	th.extu	s8,s8,31,0
    e5da:	4372988b          	th.mvnez	a7,t0,s7
    e5de:	4f85                	li	t6,1
    e5e0:	03010b93          	addi	s7,sp,48
    e5e4:	0187f463          	bgeu	a5,s8,e5ec <_vsnprintf+0x5a1c>
    e5e8:	f7ffd06f          	j	c566 <_vsnprintf+0x3996>
    e5ec:	7c08bf8b          	th.extu	t6,a7,31,0
    e5f0:	01f7f463          	bgeu	a5,t6,e5f8 <_vsnprintf+0x5a28>
    e5f4:	868fe06f          	j	c65c <_vsnprintf+0x3a8c>
    e5f8:	02000c13          	li	s8,32
    e5fc:	01879463          	bne	a5,s8,e604 <_vsnprintf+0x5a34>
    e600:	d0dfe06f          	j	d30c <_vsnprintf+0x473c>
    e604:	be71                	j	e1a0 <_vsnprintf+0x55d0>
    e606:	0001                	nop
    e608:	4809                	li	a6,2
    e60a:	400b8763          	beqz	s7,ea18 <_vsnprintf+0x5e48>
    e60e:	4cc1                	li	s9,16
    e610:	3d968363          	beq	a3,s9,e9d6 <_vsnprintf+0x5e06>
    e614:	4309                	li	t1,2
    e616:	3e668563          	beq	a3,t1,ea00 <_vsnprintf+0x5e30>
    e61a:	02000e93          	li	t4,32
    e61e:	25dd1863          	bne	s10,t4,e86e <_vsnprintf+0x5c9e>
    e622:	00367d13          	andi	s10,a2,3
    e626:	000d0463          	beqz	s10,e62e <_vsnprintf+0x5a5e>
    e62a:	b3afe06f          	j	c964 <_vsnprintf+0x3d94>
    e62e:	02000d13          	li	s10,32
    e632:	011d6463          	bltu	s10,a7,e63a <_vsnprintf+0x5a6a>
    e636:	b2efe06f          	j	c964 <_vsnprintf+0x3d94>
    e63a:	7c08bc0b          	th.extu	s8,a7,31,0
    e63e:	8bc2                	mv	s7,a6
    e640:	b925                	j	e278 <_vsnprintf+0x56a8>
    e642:	4d01                	li	s10,0
    e644:	ef2ff06f          	j	dd36 <_vsnprintf+0x5166>
    e648:	26088a63          	beqz	a7,e8bc <_vsnprintf+0x5cec>
    e64c:	001ffc93          	andi	s9,t6,1
    e650:	7c0c370b          	th.extu	a4,s8,31,0
    e654:	03010b13          	addi	s6,sp,48
    e658:	4a0c8e63          	beqz	s9,eb14 <_vsnprintf+0x5f44>
    e65c:	7c08b78b          	th.extu	a5,a7,31,0
    e660:	90071c63          	bnez	a4,d778 <_vsnprintf+0x4ba8>
    e664:	a0aff06f          	j	d86e <_vsnprintf+0x4c9e>
    e668:	00adf463          	bgeu	s11,a0,e670 <_vsnprintf+0x5aa0>
    e66c:	cd9fe06f          	j	d344 <_vsnprintf+0x4774>
    e670:	560d0b63          	beqz	s10,ebe6 <_vsnprintf+0x6016>
    e674:	540b9c63          	bnez	s7,ebcc <_vsnprintf+0x5ffc>
    e678:	4d01                	li	s10,0
    e67a:	b275                	j	e026 <_vsnprintf+0x5456>
    e67c:	8bea                	mv	s7,s10
    e67e:	7c0c350b          	th.extu	a0,s8,31,0
    e682:	e62ff06f          	j	dce4 <_vsnprintf+0x5114>
    e686:	1a0e8263          	beqz	t4,e82a <_vsnprintf+0x5c5a>
    e68a:	040b9263          	bnez	s7,e6ce <_vsnprintf+0x5afe>
    e68e:	01a70763          	beq	a4,s10,e69c <_vsnprintf+0x5acc>
    e692:	7c08be8b          	th.extu	t4,a7,31,0
    e696:	885e                	mv	a6,s7
    e698:	f7ae9be3          	bne	t4,s10,e60e <_vsnprintf+0x5a3e>
    e69c:	fffd0593          	addi	a1,s10,-1
    e6a0:	4a059d63          	bnez	a1,eb5a <_vsnprintf+0x5f8a>
    e6a4:	4841                	li	a6,16
    e6a6:	4f068963          	beq	a3,a6,eb98 <_vsnprintf+0x5fc8>
    e6aa:	4d09                	li	s10,2
    e6ac:	51a68463          	beq	a3,s10,ebb4 <_vsnprintf+0x5fe4>
    e6b0:	03000713          	li	a4,48
    e6b4:	02e10823          	sb	a4,48(sp)
    e6b8:	8a0d                	andi	a2,a2,3
    e6ba:	4c060763          	beqz	a2,eb88 <_vsnprintf+0x5fb8>
    e6be:	6382                	ld	t2,0(sp)
    e6c0:	4d05                	li	s10,1
    e6c2:	aaafe06f          	j	c96c <_vsnprintf+0x3d9c>
    e6c6:	49ac0963          	beq	s8,s10,eb58 <_vsnprintf+0x5f88>
    e6ca:	49a88763          	beq	a7,s10,eb58 <_vsnprintf+0x5f88>
    e6ce:	4801                	li	a6,0
    e6d0:	bf3d                	j	e60e <_vsnprintf+0x5a3e>
    e6d2:	02000313          	li	t1,32
    e6d6:	aa670c63          	beq	a4,t1,d98e <_vsnprintf+0x4dbe>
    e6da:	00e80633          	add	a2,a6,a4
    e6de:	8bea                	mv	s7,s10
    e6e0:	0705                	addi	a4,a4,1
    e6e2:	06200f93          	li	t6,98
    e6e6:	01f60023          	sb	t6,0(a2)
    e6ea:	8d5e                	mv	s10,s7
    e6ec:	a9aff06f          	j	d986 <_vsnprintf+0x4db6>
    e6f0:	4d01                	li	s10,0
    e6f2:	020e7c93          	andi	s9,t3,32
    e6f6:	180c8b63          	beqz	s9,e88c <_vsnprintf+0x5cbc>
    e6fa:	02000293          	li	t0,32
    e6fe:	a8570863          	beq	a4,t0,d98e <_vsnprintf+0x4dbe>
    e702:	02070393          	addi	t2,a4,32
    e706:	03010f13          	addi	t5,sp,48
    e70a:	01e38bb3          	add	s7,t2,t5
    e70e:	05800693          	li	a3,88
    e712:	fedb8023          	sb	a3,-32(s7)
    e716:	0705                	addi	a4,a4,1
    e718:	a6eff06f          	j	d986 <_vsnprintf+0x4db6>
    e71c:	7c0c370b          	th.extu	a4,s8,31,0
    e720:	52ed7363          	bgeu	s10,a4,ec46 <_vsnprintf+0x6076>
    e724:	00167c93          	andi	s9,a2,1
    e728:	850ff06f          	j	d778 <_vsnprintf+0x4ba8>
    e72c:	004af313          	andi	t1,s5,4
    e730:	06030663          	beqz	t1,e79c <_vsnprintf+0x5bcc>
    e734:	02b00693          	li	a3,43
    e738:	6382                	ld	t2,0(sp)
    e73a:	02d10823          	sb	a3,48(sp)
    e73e:	8dc2                	mv	s11,a6
    e740:	8536                	mv	a0,a3
    e742:	4d05                	li	s10,1
    e744:	4b09                	li	s6,2
    e746:	03010313          	addi	t1,sp,48
    e74a:	a2bfb06f          	j	a174 <_vsnprintf+0x15a4>
    e74e:	980d11e3          	bnez	s10,e0d0 <_vsnprintf+0x5500>
    e752:	0045fb13          	andi	s6,a1,4
    e756:	832e                	mv	t1,a1
    e758:	5e0b0763          	beqz	s6,ed46 <_vsnprintf+0x6176>
    e75c:	02078d93          	addi	s11,a5,32
    e760:	03010b13          	addi	s6,sp,48
    e764:	016d8fb3          	add	t6,s11,s6
    e768:	02b00393          	li	t2,43
    e76c:	fe7f8023          	sb	t2,-32(t6)
    e770:	0035f713          	andi	a4,a1,3
    e774:	00178d13          	addi	s10,a5,1
    e778:	5a071f63          	bnez	a4,ed36 <_vsnprintf+0x6166>
    e77c:	7c08bb8b          	th.extu	s7,a7,31,0
    e780:	8dc2                	mv	s11,a6
    e782:	4b01                	li	s6,0
    e784:	017d7463          	bgeu	s10,s7,e78c <_vsnprintf+0x5bbc>
    e788:	aadfc06f          	j	b234 <_vsnprintf+0x2664>
    e78c:	6382                	ld	t2,0(sp)
    e78e:	02b00513          	li	a0,43
    e792:	03010313          	addi	t1,sp,48
    e796:	9dffb06f          	j	a174 <_vsnprintf+0x15a4>
    e79a:	0001                	nop
    e79c:	008af593          	andi	a1,s5,8
    e7a0:	cdb5                	beqz	a1,e81c <_vsnprintf+0x5c4c>
    e7a2:	02000693          	li	a3,32
    e7a6:	bf49                	j	e738 <_vsnprintf+0x5b68>
    e7a8:	c119                	beqz	a0,e7ae <_vsnprintf+0x5bde>
    e7aa:	e9efe06f          	j	ce48 <_vsnprintf+0x4278>
    e7ae:	7c08bc0b          	th.extu	s8,a7,31,0
    e7b2:	9f876b63          	bltu	a4,s8,d9a8 <_vsnprintf+0x4dd8>
    e7b6:	d40701e3          	beqz	a4,e4f8 <_vsnprintf+0x5928>
    e7ba:	6e02                	ld	t3,0(sp)
    e7bc:	03010813          	addi	a6,sp,48
    e7c0:	ebffc06f          	j	b67e <_vsnprintf+0x2aae>
    e7c4:	c119                	beqz	a0,e7ca <_vsnprintf+0x5bfa>
    e7c6:	b7ffe06f          	j	d344 <_vsnprintf+0x4774>
    e7ca:	7c08bc0b          	th.extu	s8,a7,31,0
    e7ce:	4d01                	li	s10,0
    e7d0:	db8de063          	bltu	s11,s8,dd70 <_vsnprintf+0x51a0>
    e7d4:	020d8463          	beqz	s11,e7fc <_vsnprintf+0x5c2c>
    e7d8:	6682                	ld	a3,0(sp)
    e7da:	03010813          	addi	a6,sp,48
    e7de:	beafd06f          	j	bbc8 <_vsnprintf+0x2ff8>
    e7e2:	0001                	nop
    e7e4:	7c0c350b          	th.extu	a0,s8,31,0
    e7e8:	03010813          	addi	a6,sp,48
    e7ec:	be051863          	bnez	a0,dbdc <_vsnprintf+0x500c>
    e7f0:	003ff693          	andi	a3,t6,3
    e7f4:	6d82                	ld	s11,0(sp)
    e7f6:	e299                	bnez	a3,e7fc <_vsnprintf+0x5c2c>
    e7f8:	d3cfd06f          	j	bd34 <_vsnprintf+0x3164>
    e7fc:	6d82                	ld	s11,0(sp)
    e7fe:	e06e                	sd	s11,0(sp)
    e800:	d36fd06f          	j	bd36 <_vsnprintf+0x3166>
    e804:	0086fc93          	andi	s9,a3,8
    e808:	4e0c9363          	bnez	s9,ecee <_vsnprintf+0x611e>
    e80c:	8c3e                	mv	s8,a5
    e80e:	4f89                	li	t6,2
    e810:	8dc2                	mv	s11,a6
    e812:	8b7e                	mv	s6,t6
    e814:	6802                	ld	a6,0(sp)
    e816:	e04fe06f          	j	ce1a <_vsnprintf+0x424a>
    e81a:	0001                	nop
    e81c:	6e02                	ld	t3,0(sp)
    e81e:	8dc2                	mv	s11,a6
    e820:	ae9fb06f          	j	a308 <_vsnprintf+0x1738>
    e824:	885e                	mv	a6,s7
    e826:	93efe06f          	j	c964 <_vsnprintf+0x3d94>
    e82a:	4b81                	li	s7,0
    e82c:	02000793          	li	a5,32
    e830:	a2fd0ae3          	beq	s10,a5,e264 <_vsnprintf+0x5694>
    e834:	8a0d                	andi	a2,a2,3
    e836:	92061c63          	bnez	a2,d96e <_vsnprintf+0x4d9e>
    e83a:	7c08bc0b          	th.extu	s8,a7,31,0
    e83e:	a38d6de3          	bltu	s10,s8,e278 <_vsnprintf+0x56a8>
    e842:	6382                	ld	t2,0(sp)
    e844:	928fe06f          	j	c96c <_vsnprintf+0x3d9c>
    e848:	00ed7463          	bgeu	s10,a4,e850 <_vsnprintf+0x5c80>
    e84c:	f2dfe06f          	j	d778 <_vsnprintf+0x4ba8>
    e850:	420e8c63          	beqz	t4,ec88 <_vsnprintf+0x60b8>
    e854:	e20b8de3          	beqz	s7,e68e <_vsnprintf+0x5abe>
    e858:	4bc1                	li	s7,16
    e85a:	17768d63          	beq	a3,s7,e9d4 <_vsnprintf+0x5e04>
    e85e:	4509                	li	a0,2
    e860:	52a68463          	beq	a3,a0,ed88 <_vsnprintf+0x61b8>
    e864:	02000d93          	li	s11,32
    e868:	4801                	li	a6,0
    e86a:	ddbd02e3          	beq	s10,s11,e62e <_vsnprintf+0x5a5e>
    e86e:	002d0bb3          	add	s7,s10,sp
    e872:	03000393          	li	t2,48
    e876:	001d0513          	addi	a0,s10,1
    e87a:	027b8823          	sb	t2,48(s7)
    e87e:	02000593          	li	a1,32
    e882:	8bc2                	mv	s7,a6
    e884:	8d2a                	mv	s10,a0
    e886:	9cb50fe3          	beq	a0,a1,e264 <_vsnprintf+0x5694>
    e88a:	b76d                	j	e834 <_vsnprintf+0x5c64>
    e88c:	02000c13          	li	s8,32
    e890:	8f870f63          	beq	a4,s8,d98e <_vsnprintf+0x4dbe>
    e894:	018707b3          	add	a5,a4,s8
    e898:	03010f93          	addi	t6,sp,48
    e89c:	01f785b3          	add	a1,a5,t6
    e8a0:	07800513          	li	a0,120
    e8a4:	fea58023          	sb	a0,-32(a1)
    e8a8:	0705                	addi	a4,a4,1
    e8aa:	8dcff06f          	j	d986 <_vsnprintf+0x4db6>
    e8ae:	86be                	mv	a3,a5
    e8b0:	ddbfe06f          	j	d68a <_vsnprintf+0x4aba>
    e8b4:	6382                	ld	t2,0(sp)
    e8b6:	4b89                	li	s7,2
    e8b8:	8b4fe06f          	j	c96c <_vsnprintf+0x3d9c>
    e8bc:	7c0c370b          	th.extu	a4,s8,31,0
    e8c0:	03010b13          	addi	s6,sp,48
    e8c4:	e60710e3          	bnez	a4,e724 <_vsnprintf+0x5b54>
    e8c8:	003ffb13          	andi	s6,t6,3
    e8cc:	6382                	ld	t2,0(sp)
    e8ce:	000b1463          	bnez	s6,e8d6 <_vsnprintf+0x5d06>
    e8d2:	9ecfe06f          	j	cabe <_vsnprintf+0x3eee>
    e8d6:	6382                	ld	t2,0(sp)
    e8d8:	e01e                	sd	t2,0(sp)
    e8da:	9e6fe06f          	j	cac0 <_vsnprintf+0x3ef0>
    e8de:	0001                	nop
    e8e0:	87de                	mv	a5,s7
    e8e2:	4ac1                	li	s5,16
    e8e4:	bbbfc06f          	j	b49e <_vsnprintf+0x28ce>
    e8e8:	dc0b8fe3          	beqz	s7,e6c6 <_vsnprintf+0x5af6>
    e8ec:	4c41                	li	s8,16
    e8ee:	d3868ae3          	beq	a3,s8,e622 <_vsnprintf+0x5a52>
    e8f2:	4b89                	li	s7,2
    e8f4:	d37693e3          	bne	a3,s7,e61a <_vsnprintf+0x5a4a>
    e8f8:	b32d                	j	e622 <_vsnprintf+0x5a52>
    e8fa:	6e02                	ld	t3,0(sp)
    e8fc:	8dc2                	mv	s11,a6
    e8fe:	ad7fd06f          	j	c3d4 <_vsnprintf+0x3804>
    e902:	6a82                	ld	s5,0(sp)
    e904:	cb8fc06f          	j	adbc <_vsnprintf+0x21ec>
    e908:	47fd                	li	a5,31
    e90a:	42c1                	li	t0,16
    e90c:	1e568063          	beq	a3,t0,eaec <_vsnprintf+0x5f1c>
    e910:	4389                	li	t2,2
    e912:	1c768a63          	beq	a3,t2,eae6 <_vsnprintf+0x5f16>
    e916:	00278c33          	add	s8,a5,sp
    e91a:	03000793          	li	a5,48
    e91e:	02fc0823          	sb	a5,48(s8)
    e922:	8d5e                	mv	s10,s7
    e924:	bee5                	j	e51c <_vsnprintf+0x594c>
    e926:	4b01                	li	s6,0
    e928:	937fd06f          	j	c25e <_vsnprintf+0x368e>
    e92c:	05800c13          	li	s8,88
    e930:	002d06b3          	add	a3,s10,sp
    e934:	03868723          	sb	s8,46(a3)
    e938:	00288633          	add	a2,a7,sp
    e93c:	03000393          	li	t2,48
    e940:	02760823          	sb	t2,48(a2)
    e944:	4b81                	li	s7,0
    e946:	b2bfc06f          	j	b470 <_vsnprintf+0x28a0>
    e94a:	87b6                	mv	a5,a3
    e94c:	b6b1                	j	e498 <_vsnprintf+0x58c8>
    e94e:	82e2                	mv	t0,s8
    e950:	fadfa06f          	j	98fc <_vsnprintf+0xd2c>
    e954:	02000393          	li	t2,32
    e958:	be7d8d63          	beq	s11,t2,dd52 <_vsnprintf+0x5182>
    e95c:	01b80333          	add	t1,a6,s11
    e960:	8bea                	mv	s7,s10
    e962:	0d85                	addi	s11,s11,1
    e964:	06200e93          	li	t4,98
    e968:	01d30023          	sb	t4,0(t1)
    e96c:	8d5e                	mv	s10,s7
    e96e:	bdcff06f          	j	dd4a <_vsnprintf+0x517a>
    e972:	00c2f293          	andi	t0,t0,12
    e976:	fff88c9b          	addiw	s9,a7,-1
    e97a:	7c0c3d0b          	th.extu	s10,s8,31,0
    e97e:	425c988b          	th.mvnez	a7,s9,t0
    e982:	01a7f463          	bgeu	a5,s10,e98a <_vsnprintf+0x5dba>
    e986:	f74fc06f          	j	b0fa <_vsnprintf+0x252a>
    e98a:	7c08b68b          	th.extu	a3,a7,31,0
    e98e:	00d7f463          	bgeu	a5,a3,e996 <_vsnprintf+0x5dc6>
    e992:	c13fe06f          	j	d5a4 <_vsnprintf+0x49d4>
    e996:	02000c13          	li	s8,32
    e99a:	b1878263          	beq	a5,s8,dc9e <_vsnprintf+0x50ce>
    e99e:	bb55                	j	e752 <_vsnprintf+0x5b82>
    e9a0:	02000c13          	li	s8,32
    e9a4:	bb8d8763          	beq	s11,s8,dd52 <_vsnprintf+0x5182>
    e9a8:	018d8b33          	add	s6,s11,s8
    e9ac:	1818                	addi	a4,sp,48
    e9ae:	00eb0fb3          	add	t6,s6,a4
    e9b2:	07800693          	li	a3,120
    e9b6:	fedf8023          	sb	a3,-32(t6)
    e9ba:	0d85                	addi	s11,s11,1
    e9bc:	b8eff06f          	j	dd4a <_vsnprintf+0x517a>
    e9c0:	008afb93          	andi	s7,s5,8
    e9c4:	060b9d63          	bnez	s7,ea3e <_vsnprintf+0x5e6e>
    e9c8:	8c3e                	mv	s8,a5
    e9ca:	4689                	li	a3,2
    e9cc:	6302                	ld	t1,0(sp)
    e9ce:	8b36                	mv	s6,a3
    e9d0:	8e9fe06f          	j	d2b8 <_vsnprintf+0x46e8>
    e9d4:	4801                	li	a6,0
    e9d6:	02067e13          	andi	t3,a2,32
    e9da:	040e0363          	beqz	t3,ea20 <_vsnprintf+0x5e50>
    e9de:	02000d93          	li	s11,32
    e9e2:	c5bd00e3          	beq	s10,s11,e622 <_vsnprintf+0x5a52>
    e9e6:	020d0293          	addi	t0,s10,32
    e9ea:	03010f93          	addi	t6,sp,48
    e9ee:	01f28f33          	add	t5,t0,t6
    e9f2:	05800513          	li	a0,88
    e9f6:	feaf0023          	sb	a0,-32(t5)
    e9fa:	0d05                	addi	s10,s10,1
    e9fc:	b939                	j	e61a <_vsnprintf+0x5a4a>
    e9fe:	0001                	nop
    ea00:	02000693          	li	a3,32
    ea04:	c0dd0fe3          	beq	s10,a3,e622 <_vsnprintf+0x5a52>
    ea08:	002d05b3          	add	a1,s10,sp
    ea0c:	06200713          	li	a4,98
    ea10:	02e58823          	sb	a4,48(a1)
    ea14:	0d05                	addi	s10,s10,1
    ea16:	b111                	j	e61a <_vsnprintf+0x5a4a>
    ea18:	8bc2                	mv	s7,a6
    ea1a:	7c0c370b          	th.extu	a4,s8,31,0
    ea1e:	b985                	j	e68e <_vsnprintf+0x5abe>
    ea20:	02000c13          	li	s8,32
    ea24:	bf8d0fe3          	beq	s10,s8,e622 <_vsnprintf+0x5a52>
    ea28:	018d0bb3          	add	s7,s10,s8
    ea2c:	181c                	addi	a5,sp,48
    ea2e:	00fb83b3          	add	t2,s7,a5
    ea32:	07800593          	li	a1,120
    ea36:	feb38023          	sb	a1,-32(t2)
    ea3a:	0d05                	addi	s10,s10,1
    ea3c:	bef9                	j	e61a <_vsnprintf+0x5a4a>
    ea3e:	4b09                	li	s6,2
    ea40:	03010293          	addi	t0,sp,48
    ea44:	00578d33          	add	s10,a5,t0
    ea48:	02000513          	li	a0,32
    ea4c:	00ad0023          	sb	a0,0(s10)
    ea50:	898d                	andi	a1,a1,3
    ea52:	00178c13          	addi	s8,a5,1
    ea56:	e999                	bnez	a1,ea6c <_vsnprintf+0x5e9c>
    ea58:	7c08bd0b          	th.extu	s10,a7,31,0
    ea5c:	01ac7463          	bgeu	s8,s10,ea64 <_vsnprintf+0x5e94>
    ea60:	ec0fe06f          	j	d120 <_vsnprintf+0x4550>
    ea64:	6302                	ld	t1,0(sp)
    ea66:	8b96                	mv	s7,t0
    ea68:	9eefc06f          	j	ac56 <_vsnprintf+0x2086>
    ea6c:	6302                	ld	t1,0(sp)
    ea6e:	03010b93          	addi	s7,sp,48
    ea72:	9e4fc06f          	j	ac56 <_vsnprintf+0x2086>
    ea76:	02000e13          	li	t3,32
    ea7a:	01c79463          	bne	a5,t3,ea82 <_vsnprintf+0x5eb2>
    ea7e:	eeafb06f          	j	a168 <_vsnprintf+0x1598>
    ea82:	86be                	mv	a3,a5
    ea84:	f86fc06f          	j	b20a <_vsnprintf+0x263a>
    ea88:	86be                	mv	a3,a5
    ea8a:	01578463          	beq	a5,s5,ea92 <_vsnprintf+0x5ec2>
    ea8e:	e3efd06f          	j	c0cc <_vsnprintf+0x34fc>
    ea92:	c5dfe06f          	j	d6ee <_vsnprintf+0x4b1e>
    ea96:	020e7a93          	andi	s5,t3,32
    ea9a:	020a9e63          	bnez	s5,ead6 <_vsnprintf+0x5f06>
    ea9e:	07800613          	li	a2,120
    eaa2:	02c10823          	sb	a2,48(sp)
    eaa6:	03000c93          	li	s9,48
    eaaa:	039108a3          	sb	s9,49(sp)
    eaae:	8d5e                	mv	s10,s7
    eab0:	4709                	li	a4,2
    eab2:	bc8d                	j	e524 <_vsnprintf+0x5954>
    eab4:	0085f693          	andi	a3,a1,8
    eab8:	f6c1                	bnez	a3,ea40 <_vsnprintf+0x5e70>
    eaba:	003bfa93          	andi	s5,s7,3
    eabe:	8c3e                	mv	s8,a5
    eac0:	f00a96e3          	bnez	s5,e9cc <_vsnprintf+0x5dfc>
    eac4:	7c08bd0b          	th.extu	s10,a7,31,0
    eac8:	4b01                	li	s6,0
    eaca:	4681                	li	a3,0
    eacc:	01ac7463          	bgeu	s8,s10,ead4 <_vsnprintf+0x5f04>
    ead0:	e50fe06f          	j	d120 <_vsnprintf+0x4550>
    ead4:	bde5                	j	e9cc <_vsnprintf+0x5dfc>
    ead6:	05800313          	li	t1,88
    eada:	02610823          	sb	t1,48(sp)
    eade:	8d5e                	mv	s10,s7
    eae0:	4705                	li	a4,1
    eae2:	c74ff06f          	j	df56 <_vsnprintf+0x5386>
    eae6:	00f80633          	add	a2,a6,a5
    eaea:	bee5                	j	e6e2 <_vsnprintf+0x5b12>
    eaec:	020e7e93          	andi	t4,t3,32
    eaf0:	ffe70d13          	addi	s10,a4,-2
    eaf4:	040e9463          	bnez	t4,eb3c <_vsnprintf+0x5f6c>
    eaf8:	020d0713          	addi	a4,s10,32
    eafc:	03010c93          	addi	s9,sp,48
    eb00:	019702b3          	add	t0,a4,s9
    eb04:	07800393          	li	t2,120
    eb08:	fe728023          	sb	t2,-32(t0)
    eb0c:	8d5e                	mv	s10,s7
    eb0e:	873e                	mv	a4,a5
    eb10:	c46ff06f          	j	df56 <_vsnprintf+0x5386>
    eb14:	c319                	beqz	a4,eb1a <_vsnprintf+0x5f4a>
    eb16:	c63fe06f          	j	d778 <_vsnprintf+0x4ba8>
    eb1a:	7c08bc0b          	th.extu	s8,a7,31,0
    eb1e:	4b81                	li	s7,0
    eb20:	f58d6c63          	bltu	s10,s8,e278 <_vsnprintf+0x56a8>
    eb24:	da0d09e3          	beqz	s10,e8d6 <_vsnprintf+0x5d06>
    eb28:	6382                	ld	t2,0(sp)
    eb2a:	03010b13          	addi	s6,sp,48
    eb2e:	e3ffd06f          	j	c96c <_vsnprintf+0x3d9c>
    eb32:	6802                	ld	a6,0(sp)
    eb34:	02d00513          	li	a0,45
    eb38:	f32fd06f          	j	c26a <_vsnprintf+0x369a>
    eb3c:	020d0b13          	addi	s6,s10,32
    eb40:	03010a93          	addi	s5,sp,48
    eb44:	015b0333          	add	t1,s6,s5
    eb48:	05800613          	li	a2,88
    eb4c:	177d                	addi	a4,a4,-1
    eb4e:	fec30023          	sb	a2,-32(t1)
    eb52:	8d5e                	mv	s10,s7
    eb54:	c02ff06f          	j	df56 <_vsnprintf+0x5386>
    eb58:	45fd                	li	a1,31
    eb5a:	4dc1                	li	s11,16
    eb5c:	0bb68363          	beq	a3,s11,ec02 <_vsnprintf+0x6032>
    eb60:	4289                	li	t0,2
    eb62:	08568d63          	beq	a3,t0,ebfc <_vsnprintf+0x602c>
    eb66:	00258533          	add	a0,a1,sp
    eb6a:	03000c13          	li	s8,48
    eb6e:	03850823          	sb	s8,48(a0)
    eb72:	b96d                	j	e82c <_vsnprintf+0x5c5c>
    eb74:	4d01                	li	s10,0
    eb76:	9dcff06f          	j	dd52 <_vsnprintf+0x5182>
    eb7a:	cfbc0263          	beq	s8,s11,e05e <_vsnprintf+0x548e>
    eb7e:	cfb88063          	beq	a7,s11,e05e <_vsnprintf+0x548e>
    eb82:	4d01                	li	s10,0
    eb84:	9baff06f          	j	dd3e <_vsnprintf+0x516e>
    eb88:	7c08bc0b          	th.extu	s8,a7,31,0
    eb8c:	4d05                	li	s10,1
    eb8e:	ef8d6563          	bltu	s10,s8,e278 <_vsnprintf+0x56a8>
    eb92:	6382                	ld	t2,0(sp)
    eb94:	dd9fd06f          	j	c96c <_vsnprintf+0x3d9c>
    eb98:	02067c93          	andi	s9,a2,32
    eb9c:	020c9163          	bnez	s9,ebbe <_vsnprintf+0x5fee>
    eba0:	07800693          	li	a3,120
    eba4:	02d10823          	sb	a3,48(sp)
    eba8:	03000e13          	li	t3,48
    ebac:	03c108a3          	sb	t3,49(sp)
    ebb0:	4d09                	li	s10,2
    ebb2:	b149                	j	e834 <_vsnprintf+0x5c64>
    ebb4:	06200e93          	li	t4,98
    ebb8:	03d10823          	sb	t4,48(sp)
    ebbc:	b7f5                	j	eba8 <_vsnprintf+0x5fd8>
    ebbe:	05800313          	li	t1,88
    ebc2:	02610823          	sb	t1,48(sp)
    ebc6:	885e                	mv	a6,s7
    ebc8:	4d05                	li	s10,1
    ebca:	b155                	j	e86e <_vsnprintf+0x5c9e>
    ebcc:	4d41                	li	s10,16
    ebce:	e1a68563          	beq	a3,s10,e1d8 <_vsnprintf+0x5608>
    ebd2:	4509                	li	a0,2
    ebd4:	00a68e63          	beq	a3,a0,ebf0 <_vsnprintf+0x6020>
    ebd8:	02000313          	li	t1,32
    ebdc:	4d01                	li	s10,0
    ebde:	986d8063          	beq	s11,t1,dd5e <_vsnprintf+0x518e>
    ebe2:	c06ff06f          	j	dfe8 <_vsnprintf+0x5418>
    ebe6:	02000613          	li	a2,32
    ebea:	c2cd8163          	beq	s11,a2,e00c <_vsnprintf+0x543c>
    ebee:	bef1                	j	e7ca <_vsnprintf+0x5bfa>
    ebf0:	02000e93          	li	t4,32
    ebf4:	4d01                	li	s10,0
    ebf6:	97dd8463          	beq	s11,t4,dd5e <_vsnprintf+0x518e>
    ebfa:	b38d                	j	e95c <_vsnprintf+0x5d8c>
    ebfc:	885e                	mv	a6,s7
    ebfe:	8d2e                	mv	s10,a1
    ec00:	b521                	j	ea08 <_vsnprintf+0x5e38>
    ec02:	ffed0813          	addi	a6,s10,-2
    ec06:	02067c93          	andi	s9,a2,32
    ec0a:	1d7d                	addi	s10,s10,-1
    ec0c:	02080313          	addi	t1,a6,32
    ec10:	080c9263          	bnez	s9,ec94 <_vsnprintf+0x60c4>
    ec14:	03010293          	addi	t0,sp,48
    ec18:	00530fb3          	add	t6,t1,t0
    ec1c:	07800f13          	li	t5,120
    ec20:	ffef8023          	sb	t5,-32(t6)
    ec24:	885e                	mv	a6,s7
    ec26:	b1a1                	j	e86e <_vsnprintf+0x5c9e>
    ec28:	02067b13          	andi	s6,a2,32
    ec2c:	020b1563          	bnez	s6,ec56 <_vsnprintf+0x6086>
    ec30:	07800693          	li	a3,120
    ec34:	02d10823          	sb	a3,48(sp)
    ec38:	03000f93          	li	t6,48
    ec3c:	03f108a3          	sb	t6,49(sp)
    ec40:	4d89                	li	s11,2
    ec42:	c40ff06f          	j	e082 <_vsnprintf+0x54b2>
    ec46:	000e8f63          	beqz	t4,ec64 <_vsnprintf+0x6094>
    ec4a:	4801                	li	a6,0
    ec4c:	9c0b91e3          	bnez	s7,e60e <_vsnprintf+0x5a3e>
    ec50:	9aed1fe3          	bne	s10,a4,e60e <_vsnprintf+0x5a3e>
    ec54:	b4a1                	j	e69c <_vsnprintf+0x5acc>
    ec56:	05800713          	li	a4,88
    ec5a:	02e10823          	sb	a4,48(sp)
    ec5e:	4d85                	li	s11,1
    ec60:	b88ff06f          	j	dfe8 <_vsnprintf+0x5418>
    ec64:	02000c13          	li	s8,32
    ec68:	4b81                	li	s7,0
    ec6a:	bd8d15e3          	bne	s10,s8,e834 <_vsnprintf+0x5c64>
    ec6e:	cf7fd06f          	j	c964 <_vsnprintf+0x3d94>
    ec72:	4ac1                	li	s5,16
    ec74:	4b89                	li	s7,2
    ec76:	fe2ff06f          	j	e458 <_vsnprintf+0x5888>
    ec7a:	6382                	ld	t2,0(sp)
    ec7c:	4b81                	li	s7,0
    ec7e:	ceffd06f          	j	c96c <_vsnprintf+0x3d9c>
    ec82:	01c80333          	add	t1,a6,t3
    ec86:	b9f9                	j	e964 <_vsnprintf+0x5d94>
    ec88:	02000e93          	li	t4,32
    ec8c:	4b81                	li	s7,0
    ec8e:	dddd0f63          	beq	s10,t4,e26c <_vsnprintf+0x569c>
    ec92:	b561                	j	eb1a <_vsnprintf+0x5f4a>
    ec94:	1814                	addi	a3,sp,48
    ec96:	00d30e33          	add	t3,t1,a3
    ec9a:	05800d93          	li	s11,88
    ec9e:	ffbe0023          	sb	s11,-32(t3)
    eca2:	885e                	mv	a6,s7
    eca4:	b6e9                	j	e86e <_vsnprintf+0x5c9e>
    eca6:	05800593          	li	a1,88
    ecaa:	feb28023          	sb	a1,-32(t0)
    ecae:	8d5e                	mv	s10,s7
    ecb0:	b38ff06f          	j	dfe8 <_vsnprintf+0x5418>
    ecb4:	8dc2                	mv	s11,a6
    ecb6:	4b01                	li	s6,0
    ecb8:	6802                	ld	a6,0(sp)
    ecba:	8c96                	mv	s9,t0
    ecbc:	daefd06f          	j	c26a <_vsnprintf+0x369a>
    ecc0:	0085ff93          	andi	t6,a1,8
    ecc4:	060f9263          	bnez	t6,ed28 <_vsnprintf+0x6158>
    ecc8:	003cfe93          	andi	t4,s9,3
    eccc:	8c3e                	mv	s8,a5
    ecce:	b40e91e3          	bnez	t4,e810 <_vsnprintf+0x5c40>
    ecd2:	7c08bb8b          	th.extu	s7,a7,31,0
    ecd6:	8dc2                	mv	s11,a6
    ecd8:	4b01                	li	s6,0
    ecda:	4f81                	li	t6,0
    ecdc:	017c7463          	bgeu	s8,s7,ece4 <_vsnprintf+0x6114>
    ece0:	fa5fd06f          	j	cc84 <_vsnprintf+0x40b4>
    ece4:	b635                	j	e810 <_vsnprintf+0x5c40>
    ece6:	6302                	ld	t1,0(sp)
    ece8:	4b01                	li	s6,0
    ecea:	f6dfb06f          	j	ac56 <_vsnprintf+0x2086>
    ecee:	8dc2                	mv	s11,a6
    ecf0:	4b09                	li	s6,2
    ecf2:	1818                	addi	a4,sp,48
    ecf4:	00e78f33          	add	t5,a5,a4
    ecf8:	02000513          	li	a0,32
    ecfc:	00af0023          	sb	a0,0(t5)
    ed00:	0035fd13          	andi	s10,a1,3
    ed04:	00178c13          	addi	s8,a5,1
    ed08:	020d1263          	bnez	s10,ed2c <_vsnprintf+0x615c>
    ed0c:	7c08bb8b          	th.extu	s7,a7,31,0
    ed10:	017c7463          	bgeu	s8,s7,ed18 <_vsnprintf+0x6148>
    ed14:	f71fd06f          	j	cc84 <_vsnprintf+0x40b4>
    ed18:	6802                	ld	a6,0(sp)
    ed1a:	8cba                	mv	s9,a4
    ed1c:	d4efd06f          	j	c26a <_vsnprintf+0x369a>
    ed20:	008afb93          	andi	s7,s5,8
    ed24:	fa0b87e3          	beqz	s7,ecd2 <_vsnprintf+0x6102>
    ed28:	8dc2                	mv	s11,a6
    ed2a:	b7e1                	j	ecf2 <_vsnprintf+0x6122>
    ed2c:	6802                	ld	a6,0(sp)
    ed2e:	03010c93          	addi	s9,sp,48
    ed32:	d38fd06f          	j	c26a <_vsnprintf+0x369a>
    ed36:	851e                	mv	a0,t2
    ed38:	8dc2                	mv	s11,a6
    ed3a:	6382                	ld	t2,0(sp)
    ed3c:	4b01                	li	s6,0
    ed3e:	03010313          	addi	t1,sp,48
    ed42:	c32fb06f          	j	a174 <_vsnprintf+0x15a4>
    ed46:	0085fa93          	andi	s5,a1,8
    ed4a:	040a8563          	beqz	s5,ed94 <_vsnprintf+0x61c4>
    ed4e:	8dc2                	mv	s11,a6
    ed50:	02078813          	addi	a6,a5,32
    ed54:	03010293          	addi	t0,sp,48
    ed58:	00580cb3          	add	s9,a6,t0
    ed5c:	02000c13          	li	s8,32
    ed60:	ff8c8023          	sb	s8,-32(s9)
    ed64:	0035fb93          	andi	s7,a1,3
    ed68:	00178d13          	addi	s10,a5,1
    ed6c:	000b9863          	bnez	s7,ed7c <_vsnprintf+0x61ac>
    ed70:	7c08bb8b          	th.extu	s7,a7,31,0
    ed74:	017d7463          	bgeu	s10,s7,ed7c <_vsnprintf+0x61ac>
    ed78:	cbcfc06f          	j	b234 <_vsnprintf+0x2664>
    ed7c:	6382                	ld	t2,0(sp)
    ed7e:	8562                	mv	a0,s8
    ed80:	03010313          	addi	t1,sp,48
    ed84:	bf0fb06f          	j	a174 <_vsnprintf+0x15a4>
    ed88:	02000293          	li	t0,32
    ed8c:	4801                	li	a6,0
    ed8e:	8a5d00e3          	beq	s10,t0,e62e <_vsnprintf+0x5a5e>
    ed92:	b99d                	j	ea08 <_vsnprintf+0x5e38>
    ed94:	00337e13          	andi	t3,t1,3
    ed98:	8d3e                	mv	s10,a5
    ed9a:	000e1b63          	bnez	t3,edb0 <_vsnprintf+0x61e0>
    ed9e:	7c08bb8b          	th.extu	s7,a7,31,0
    eda2:	8dc2                	mv	s11,a6
    eda4:	4b01                	li	s6,0
    eda6:	4a81                	li	s5,0
    eda8:	017d7463          	bgeu	s10,s7,edb0 <_vsnprintf+0x61e0>
    edac:	c88fc06f          	j	b234 <_vsnprintf+0x2664>
    edb0:	6382                	ld	t2,0(sp)
    edb2:	8dc2                	mv	s11,a6
    edb4:	8b56                	mv	s6,s5
    edb6:	e12fc06f          	j	b3c8 <_vsnprintf+0x27f8>
    edba:	7c08bc0b          	th.extu	s8,a7,31,0
    edbe:	4d85                	li	s11,1
    edc0:	018df463          	bgeu	s11,s8,edc8 <_vsnprintf+0x61f8>
    edc4:	fadfe06f          	j	dd70 <_vsnprintf+0x51a0>
    edc8:	6682                	ld	a3,0(sp)
    edca:	dfffc06f          	j	bbc8 <_vsnprintf+0x2ff8>
    edce:	06200c13          	li	s8,98
    edd2:	03810823          	sb	s8,48(sp)
    edd6:	b58d                	j	ec38 <_vsnprintf+0x6068>
    edd8:	004afb13          	andi	s6,s5,4
    eddc:	f40b02e3          	beqz	s6,ed20 <_vsnprintf+0x6150>
    ede0:	02b00b13          	li	s6,43
    ede4:	03610823          	sb	s6,48(sp)
    ede8:	4c05                	li	s8,1
    edea:	ed8ff06f          	j	e4c2 <_vsnprintf+0x58f2>
    edee:	0082f313          	andi	t1,t0,8
    edf2:	02031463          	bnez	t1,ee1a <_vsnprintf+0x624a>
    edf6:	8d3e                	mv	s10,a5
    edf8:	4a89                	li	s5,2
    edfa:	bf5d                	j	edb0 <_vsnprintf+0x61e0>
    edfc:	03000e93          	li	t4,48
    ee00:	47bd                	li	a5,15
    ee02:	03d10823          	sb	t4,48(sp)
    ee06:	4b81                	li	s7,0
    ee08:	4d01                	li	s10,0
    ee0a:	40000c93          	li	s9,1024
    ee0e:	4e05                	li	t3,1
    ee10:	8abe                	mv	s5,a5
    ee12:	03010b13          	addi	s6,sp,48
    ee16:	eecfb06f          	j	a502 <_vsnprintf+0x1932>
    ee1a:	8dc2                	mv	s11,a6
    ee1c:	4b09                	li	s6,2
    ee1e:	bf0d                	j	ed50 <_vsnprintf+0x6180>
    ee20:	000e8463          	beqz	t4,ee28 <_vsnprintf+0x6258>
    ee24:	b53fe06f          	j	d976 <_vsnprintf+0x4da6>
    ee28:	02000b93          	li	s7,32
    ee2c:	01771463          	bne	a4,s7,ee34 <_vsnprintf+0x6264>
    ee30:	849fc06f          	j	b678 <_vsnprintf+0x2aa8>
    ee34:	9fcfe06f          	j	d030 <_vsnprintf+0x4460>
    ee38:	7c08bf8b          	th.extu	t6,a7,31,0
    ee3c:	01f7f463          	bgeu	a5,t6,ee44 <_vsnprintf+0x6274>
    ee40:	81dfd06f          	j	c65c <_vsnprintf+0x3a8c>
    ee44:	02000e13          	li	t3,32
    ee48:	01c79463          	bne	a5,t3,ee50 <_vsnprintf+0x6280>
    ee4c:	e01fb06f          	j	ac4c <_vsnprintf+0x207c>
    ee50:	903fd06f          	j	c752 <_vsnprintf+0x3b82>
    ee54:	02000513          	li	a0,32
    ee58:	02a79463          	bne	a5,a0,ee80 <_vsnprintf+0x62b0>
    ee5c:	0036fa93          	andi	s5,a3,3
    ee60:	000a9463          	bnez	s5,ee68 <_vsnprintf+0x6298>
    ee64:	897fe06f          	j	d6fa <_vsnprintf+0x4b2a>
    ee68:	bf6fd06f          	j	c25e <_vsnprintf+0x368e>
    ee6c:	f80e9f63          	bnez	t4,e60a <_vsnprintf+0x5a3a>
    ee70:	02000713          	li	a4,32
    ee74:	00ed1463          	bne	s10,a4,ee7c <_vsnprintf+0x62ac>
    ee78:	aedfd06f          	j	c964 <_vsnprintf+0x3d94>
    ee7c:	ae1fe06f          	j	d95c <_vsnprintf+0x4d8c>
    ee80:	86be                	mv	a3,a5
    ee82:	a4afd06f          	j	c0cc <_vsnprintf+0x34fc>
    ee86:	020e8a63          	beqz	t4,eeba <_vsnprintf+0x62ea>
    ee8a:	4d01                	li	s10,0
    ee8c:	000b8463          	beqz	s7,ee94 <_vsnprintf+0x62c4>
    ee90:	aebfe06f          	j	d97a <_vsnprintf+0x4daa>
    ee94:	00a70463          	beq	a4,a0,ee9c <_vsnprintf+0x62cc>
    ee98:	ae3fe06f          	j	d97a <_vsnprintf+0x4daa>
    ee9c:	e57fe06f          	j	dcf2 <_vsnprintf+0x5122>
    eea0:	020d0663          	beqz	s10,eecc <_vsnprintf+0x62fc>
    eea4:	4d01                	li	s10,0
    eea6:	000b8463          	beqz	s7,eeae <_vsnprintf+0x62de>
    eeaa:	e95fe06f          	j	dd3e <_vsnprintf+0x516e>
    eeae:	00ad8463          	beq	s11,a0,eeb6 <_vsnprintf+0x62e6>
    eeb2:	e8dfe06f          	j	dd3e <_vsnprintf+0x516e>
    eeb6:	97cff06f          	j	e032 <_vsnprintf+0x5462>
    eeba:	02000b93          	li	s7,32
    eebe:	01771463          	bne	a4,s7,eec6 <_vsnprintf+0x62f6>
    eec2:	fb6fc06f          	j	b678 <_vsnprintf+0x2aa8>
    eec6:	4d01                	li	s10,0
    eec8:	e5cff06f          	j	e524 <_vsnprintf+0x5954>
    eecc:	02000b93          	li	s7,32
    eed0:	9b7d9963          	bne	s11,s7,e082 <_vsnprintf+0x54b2>
    eed4:	4d01                	li	s10,0
    eed6:	cedfc06f          	j	bbc2 <_vsnprintf+0x2ff2>
    eeda:	00457b93          	andi	s7,a0,4
    eede:	020b9a63          	bnez	s7,ef12 <_vsnprintf+0x6342>
    eee2:	00857593          	andi	a1,a0,8
    eee6:	e18d                	bnez	a1,ef08 <_vsnprintf+0x6338>
    eee8:	020d0c93          	addi	s9,s10,32
    eeec:	1810                	addi	a2,sp,48
    eeee:	00cc8fb3          	add	t6,s9,a2
    eef2:	fdffc503          	lbu	a0,-33(t6)
    eef6:	4b89                	li	s7,2
    eef8:	4ac1                	li	s5,16
    eefa:	9d3fb06f          	j	a8cc <_vsnprintf+0x1cfc>
    eefe:	47fd                	li	a5,31
    ef00:	4ac1                	li	s5,16
    ef02:	4b89                	li	s7,2
    ef04:	d54ff06f          	j	e458 <_vsnprintf+0x5888>
    ef08:	87ea                	mv	a5,s10
    ef0a:	4b89                	li	s7,2
    ef0c:	4ac1                	li	s5,16
    ef0e:	d90fc06f          	j	b49e <_vsnprintf+0x28ce>
    ef12:	87ea                	mv	a5,s10
    ef14:	4b89                	li	s7,2
    ef16:	4ac1                	li	s5,16
    ef18:	958fc06f          	j	b070 <_vsnprintf+0x24a0>
    ef1c:	02000513          	li	a0,32
    ef20:	0ea79e63          	bne	a5,a0,f01c <_vsnprintf+0x644c>
    ef24:	0032fe93          	andi	t4,t0,3
    ef28:	000e9463          	bnez	t4,ef30 <_vsnprintf+0x6360>
    ef2c:	d7ffe06f          	j	dcaa <_vsnprintf+0x50da>
    ef30:	a38fb06f          	j	a168 <_vsnprintf+0x1598>
    ef34:	02000813          	li	a6,32
    ef38:	01078463          	beq	a5,a6,ef40 <_vsnprintf+0x6370>
    ef3c:	80ffd06f          	j	c74a <_vsnprintf+0x3b7a>
    ef40:	003afe93          	andi	t4,s5,3
    ef44:	000e9463          	bnez	t4,ef4c <_vsnprintf+0x637c>
    ef48:	ba0fe06f          	j	d2e8 <_vsnprintf+0x4718>
    ef4c:	d01fb06f          	j	ac4c <_vsnprintf+0x207c>
    ef50:	6382                	ld	t2,0(sp)
    ef52:	02d00513          	li	a0,45
    ef56:	a1efb06f          	j	a174 <_vsnprintf+0x15a4>
    ef5a:	6382                	ld	t2,0(sp)
    ef5c:	8dc2                	mv	s11,a6
    ef5e:	8532                	mv	a0,a2
    ef60:	4b01                	li	s6,0
    ef62:	a12fb06f          	j	a174 <_vsnprintf+0x15a4>
    ef66:	0001                	nop
    ef68:	87b6                	mv	a5,a3
    ef6a:	fe8ff06f          	j	e752 <_vsnprintf+0x5b82>
    ef6e:	004afb13          	andi	s6,s5,4
    ef72:	040b0263          	beqz	s6,efb6 <_vsnprintf+0x63e6>
    ef76:	02b00b13          	li	s6,43
    ef7a:	03610823          	sb	s6,48(sp)
    ef7e:	4d05                	li	s10,1
    ef80:	ffcff06f          	j	e77c <_vsnprintf+0x5bac>
    ef84:	00778463          	beq	a5,t2,ef8c <_vsnprintf+0x63bc>
    ef88:	fc2fd06f          	j	c74a <_vsnprintf+0x3b7a>
    ef8c:	b80fe06f          	j	d30c <_vsnprintf+0x473c>
    ef90:	02000c13          	li	s8,32
    ef94:	81871de3          	bne	a4,s8,e7ae <_vsnprintf+0x5bde>
    ef98:	4d01                	li	s10,0
    ef9a:	cadfe06f          	j	dc46 <_vsnprintf+0x5076>
    ef9e:	02000513          	li	a0,32
    efa2:	4d01                	li	s10,0
    efa4:	00a71463          	bne	a4,a0,efac <_vsnprintf+0x63dc>
    efa8:	9f1fe06f          	j	d998 <_vsnprintf+0x4dc8>
    efac:	f2eff06f          	j	e6da <_vsnprintf+0x5b0a>
    efb0:	4b01                	li	s6,0
    efb2:	9b6fb06f          	j	a168 <_vsnprintf+0x1598>
    efb6:	008af393          	andi	t2,s5,8
    efba:	d8039ae3          	bnez	t2,ed4e <_vsnprintf+0x617e>
    efbe:	b3c5                	j	ed9e <_vsnprintf+0x61ce>
    efc0:	6302                	ld	t1,0(sp)
    efc2:	02b00513          	li	a0,43
    efc6:	03010b93          	addi	s7,sp,48
    efca:	c8dfb06f          	j	ac56 <_vsnprintf+0x2086>
    efce:	008d7f13          	andi	t5,s10,8
    efd2:	a60f17e3          	bnez	t5,ea40 <_vsnprintf+0x5e70>
    efd6:	b4fd                	j	eac4 <_vsnprintf+0x5ef4>
    efd8:	6e02                	ld	t3,0(sp)
    efda:	4d01                	li	s10,0
    efdc:	ea2fc06f          	j	b67e <_vsnprintf+0x2aae>
    efe0:	7c08bc0b          	th.extu	s8,a7,31,0
    efe4:	4705                	li	a4,1
    efe6:	8d5e                	mv	s10,s7
    efe8:	01877463          	bgeu	a4,s8,eff0 <_vsnprintf+0x6420>
    efec:	9bdfe06f          	j	d9a8 <_vsnprintf+0x4dd8>
    eff0:	6e02                	ld	t3,0(sp)
    eff2:	e8cfc06f          	j	b67e <_vsnprintf+0x2aae>
    eff6:	06200b13          	li	s6,98
    effa:	03610823          	sb	s6,48(sp)
    effe:	b465                	j	eaa6 <_vsnprintf+0x5ed6>
    f000:	03000793          	li	a5,48
    f004:	02f10823          	sb	a5,48(sp)
    f008:	47c1                	li	a5,16
    f00a:	4d01                	li	s10,0
    f00c:	40000c93          	li	s9,1024
    f010:	4e05                	li	t3,1
    f012:	8abe                	mv	s5,a5
    f014:	03010b13          	addi	s6,sp,48
    f018:	ceafb06f          	j	a502 <_vsnprintf+0x1932>
    f01c:	86be                	mv	a3,a5
    f01e:	9e4fc06f          	j	b202 <_vsnprintf+0x2632>
    f022:	0001                	nop
    f024:	00000013          	nop
    f028:	00000013          	nop
    f02c:	00000013          	nop

000000000000f030 <puts>:
    f030:	1141                	addi	sp,sp,-16
    f032:	f811540b          	th.sdd	s0,ra,(sp),0,4
    f036:	842a                	mv	s0,a0
    f038:	00054503          	lbu	a0,0(a0)
    f03c:	c12d                	beqz	a0,f09e <puts+0x6e>
    f03e:	55fd                	li	a1,-1
    f040:	bd0f70ef          	jal	6410 <fputc>
    f044:	00144503          	lbu	a0,1(s0)
    f048:	c939                	beqz	a0,f09e <puts+0x6e>
    f04a:	55fd                	li	a1,-1
    f04c:	bc4f70ef          	jal	6410 <fputc>
    f050:	00244503          	lbu	a0,2(s0)
    f054:	c529                	beqz	a0,f09e <puts+0x6e>
    f056:	55fd                	li	a1,-1
    f058:	bb8f70ef          	jal	6410 <fputc>
    f05c:	00344503          	lbu	a0,3(s0)
    f060:	cd1d                	beqz	a0,f09e <puts+0x6e>
    f062:	55fd                	li	a1,-1
    f064:	bacf70ef          	jal	6410 <fputc>
    f068:	00444503          	lbu	a0,4(s0)
    f06c:	c90d                	beqz	a0,f09e <puts+0x6e>
    f06e:	55fd                	li	a1,-1
    f070:	ba0f70ef          	jal	6410 <fputc>
    f074:	00544503          	lbu	a0,5(s0)
    f078:	c11d                	beqz	a0,f09e <puts+0x6e>
    f07a:	55fd                	li	a1,-1
    f07c:	b94f70ef          	jal	6410 <fputc>
    f080:	00644503          	lbu	a0,6(s0)
    f084:	cd09                	beqz	a0,f09e <puts+0x6e>
    f086:	55fd                	li	a1,-1
    f088:	b88f70ef          	jal	6410 <fputc>
    f08c:	00744503          	lbu	a0,7(s0)
    f090:	c519                	beqz	a0,f09e <puts+0x6e>
    f092:	55fd                	li	a1,-1
    f094:	b7cf70ef          	jal	6410 <fputc>
    f098:	8884450b          	th.lbuib	a0,(s0),8,0
    f09c:	f14d                	bnez	a0,f03e <puts+0xe>
    f09e:	55fd                	li	a1,-1
    f0a0:	4529                	li	a0,10
    f0a2:	b6ef70ef          	jal	6410 <fputc>
    f0a6:	f811440b          	th.ldd	s0,ra,(sp),0,4
    f0aa:	4501                	li	a0,0
    f0ac:	0141                	addi	sp,sp,16
    f0ae:	8082                	ret

000000000000f0b0 <_putchar>:
    f0b0:	55fd                	li	a1,-1
    f0b2:	b5ef706f          	j	6410 <fputc>
    f0b6:	00000013          	nop
    f0ba:	00000013          	nop
    f0be:	0001                	nop

000000000000f0c0 <putchar>:
    f0c0:	1141                	addi	sp,sp,-16
    f0c2:	55fd                	li	a1,-1
    f0c4:	0ff57513          	zext.b	a0,a0
    f0c8:	e406                	sd	ra,8(sp)
    f0ca:	b46f70ef          	jal	6410 <fputc>
    f0ce:	60a2                	ld	ra,8(sp)
    f0d0:	4501                	li	a0,0
    f0d2:	0141                	addi	sp,sp,16
    f0d4:	8082                	ret
    f0d6:	00000013          	nop
    f0da:	00000013          	nop
    f0de:	0001                	nop

000000000000f0e0 <printf>:
    f0e0:	711d                	addi	sp,sp,-96
    f0e2:	fed1560b          	th.sdd	a2,a3,(sp),3,4
    f0e6:	86aa                	mv	a3,a0
    f0e8:	651d                	lui	a0,0x7
    f0ea:	e0ba                	sd	a4,64(sp)
    f0ec:	e4be                	sd	a5,72(sp)
    f0ee:	f42e                	sd	a1,40(sp)
    f0f0:	1038                	addi	a4,sp,40
    f0f2:	858a                	mv	a1,sp
    f0f4:	567d                	li	a2,-1
    f0f6:	13050513          	addi	a0,a0,304 # 7130 <_out_char>
    f0fa:	ec06                	sd	ra,24(sp)
    f0fc:	e8c2                	sd	a6,80(sp)
    f0fe:	ecc6                	sd	a7,88(sp)
    f100:	e43a                	sd	a4,8(sp)
    f102:	acff90ef          	jal	8bd0 <_vsnprintf>
    f106:	60e2                	ld	ra,24(sp)
    f108:	6125                	addi	sp,sp,96
    f10a:	8082                	ret
    f10c:	00000013          	nop

000000000000f110 <sprintf>:
    f110:	715d                	addi	sp,sp,-80
    f112:	fcd1560b          	th.sdd	a2,a3,(sp),2,4
    f116:	86ae                	mv	a3,a1
    f118:	85aa                	mv	a1,a0
    f11a:	651d                	lui	a0,0x7
    f11c:	fef1570b          	th.sdd	a4,a5,(sp),3,4
    f120:	567d                	li	a2,-1
    f122:	1018                	addi	a4,sp,32
    f124:	10050513          	addi	a0,a0,256 # 7100 <_out_buffer>
    f128:	ec06                	sd	ra,24(sp)
    f12a:	e0c2                	sd	a6,64(sp)
    f12c:	e4c6                	sd	a7,72(sp)
    f12e:	e43a                	sd	a4,8(sp)
    f130:	aa1f90ef          	jal	8bd0 <_vsnprintf>
    f134:	60e2                	ld	ra,24(sp)
    f136:	6161                	addi	sp,sp,80
    f138:	8082                	ret
    f13a:	00000013          	nop
    f13e:	0001                	nop

000000000000f140 <snprintf>:
    f140:	715d                	addi	sp,sp,-80
    f142:	f436                	sd	a3,40(sp)
    f144:	86b2                	mv	a3,a2
    f146:	862e                	mv	a2,a1
    f148:	85aa                	mv	a1,a0
    f14a:	651d                	lui	a0,0x7
    f14c:	fef1570b          	th.sdd	a4,a5,(sp),3,4
    f150:	10050513          	addi	a0,a0,256 # 7100 <_out_buffer>
    f154:	1038                	addi	a4,sp,40
    f156:	ec06                	sd	ra,24(sp)
    f158:	e0c2                	sd	a6,64(sp)
    f15a:	e4c6                	sd	a7,72(sp)
    f15c:	e43a                	sd	a4,8(sp)
    f15e:	a73f90ef          	jal	8bd0 <_vsnprintf>
    f162:	60e2                	ld	ra,24(sp)
    f164:	6161                	addi	sp,sp,80
    f166:	8082                	ret
    f168:	00000013          	nop
    f16c:	00000013          	nop

000000000000f170 <vprintf>:
    f170:	1101                	addi	sp,sp,-32
    f172:	86aa                	mv	a3,a0
    f174:	651d                	lui	a0,0x7
    f176:	872e                	mv	a4,a1
    f178:	567d                	li	a2,-1
    f17a:	002c                	addi	a1,sp,8
    f17c:	13050513          	addi	a0,a0,304 # 7130 <_out_char>
    f180:	ec06                	sd	ra,24(sp)
    f182:	a4ff90ef          	jal	8bd0 <_vsnprintf>
    f186:	60e2                	ld	ra,24(sp)
    f188:	6105                	addi	sp,sp,32
    f18a:	8082                	ret
    f18c:	00000013          	nop

000000000000f190 <vsnprintf>:
    f190:	8736                	mv	a4,a3
    f192:	86b2                	mv	a3,a2
    f194:	862e                	mv	a2,a1
    f196:	85aa                	mv	a1,a0
    f198:	651d                	lui	a0,0x7
    f19a:	10050513          	addi	a0,a0,256 # 7100 <_out_buffer>
    f19e:	a33f906f          	j	8bd0 <_vsnprintf>
    f1a2:	0001                	nop
    f1a4:	00000013          	nop
    f1a8:	00000013          	nop
    f1ac:	00000013          	nop

000000000000f1b0 <fctprintf>:
    f1b0:	711d                	addi	sp,sp,-96
    f1b2:	fc36                	sd	a3,56(sp)
    f1b4:	e0ba                	sd	a4,64(sp)
    f1b6:	1838                	addi	a4,sp,56
    f1b8:	e43a                	sd	a4,8(sp)
    f1ba:	e82a                	sd	a0,16(sp)
    f1bc:	651d                	lui	a0,0x7
    f1be:	ec2e                	sd	a1,24(sp)
    f1c0:	86b2                	mv	a3,a2
    f1c2:	080c                	addi	a1,sp,16
    f1c4:	567d                	li	a2,-1
    f1c6:	12050513          	addi	a0,a0,288 # 7120 <_out_fct>
    f1ca:	f406                	sd	ra,40(sp)
    f1cc:	e4be                	sd	a5,72(sp)
    f1ce:	e8c2                	sd	a6,80(sp)
    f1d0:	ecc6                	sd	a7,88(sp)
    f1d2:	9fff90ef          	jal	8bd0 <_vsnprintf>
    f1d6:	70a2                	ld	ra,40(sp)
    f1d8:	6125                	addi	sp,sp,96
    f1da:	8082                	ret
    f1dc:	0000                	unimp
	...

000000000000f1e0 <ck_uart_set_baudrate>:
    f1e0:	05f5e737          	lui	a4,0x5f5e
    f1e4:	1007029b          	addiw	t0,a4,256 # 5f5e100 <__kernel_stack+0x5e70100>
    f1e8:	02b2d33b          	divuw	t1,t0,a1
    f1ec:	651c                	ld	a5,8(a0)
    f1ee:	c90c                	sw	a1,16(a0)
    f1f0:	00c7c683          	lbu	a3,12(a5)
    f1f4:	0806e393          	ori	t2,a3,128
    f1f8:	00778623          	sb	t2,12(a5)
    f1fc:	2c43350b          	th.extu	a0,t1,11,4
    f200:	00a78023          	sb	a0,0(a5)
    f204:	4cc3358b          	th.extu	a1,t1,19,12
    f208:	00b78223          	sb	a1,4(a5)
    f20c:	00c7c603          	lbu	a2,12(a5)
    f210:	07f67813          	andi	a6,a2,127
    f214:	01078623          	sb	a6,12(a5)
    f218:	8082                	ret
    f21a:	00000013          	nop
    f21e:	0001                	nop

000000000000f220 <ck_uart_set_parity>:
    f220:	4785                	li	a5,1
    f222:	c94c                	sw	a1,20(a0)
    f224:	04f58063          	beq	a1,a5,f264 <ck_uart_set_parity+0x44>
    f228:	4609                	li	a2,2
    f22a:	00c58d63          	beq	a1,a2,f244 <ck_uart_set_parity+0x24>
    f22e:	e995                	bnez	a1,f262 <ck_uart_set_parity+0x42>
    f230:	00853f83          	ld	t6,8(a0)
    f234:	00cfc783          	lbu	a5,12(t6)
    f238:	0f77f713          	andi	a4,a5,247
    f23c:	00ef8623          	sb	a4,12(t6)
    f240:	8082                	ret
    f242:	0001                	nop
    f244:	6514                	ld	a3,8(a0)
    f246:	00c6c803          	lbu	a6,12(a3)
    f24a:	00886893          	ori	a7,a6,8
    f24e:	01168623          	sb	a7,12(a3)
    f252:	00853e03          	ld	t3,8(a0)
    f256:	00ce4e83          	lbu	t4,12(t3)
    f25a:	010eef13          	ori	t5,t4,16
    f25e:	01ee0623          	sb	t5,12(t3)
    f262:	8082                	ret
    f264:	6518                	ld	a4,8(a0)
    f266:	00c74283          	lbu	t0,12(a4)
    f26a:	0082e313          	ori	t1,t0,8
    f26e:	00670623          	sb	t1,12(a4)
    f272:	00853383          	ld	t2,8(a0)
    f276:	00c3c503          	lbu	a0,12(t2)
    f27a:	0ef57593          	andi	a1,a0,239
    f27e:	00b38623          	sb	a1,12(t2)
    f282:	8082                	ret
    f284:	00000013          	nop
    f288:	00000013          	nop
    f28c:	00000013          	nop

000000000000f290 <ck_uart_set_wordsize>:
    f290:	4789                	li	a5,2
    f292:	cd4c                	sw	a1,28(a0)
    f294:	04f58263          	beq	a1,a5,f2d8 <ck_uart_set_wordsize+0x48>
    f298:	02b7e463          	bltu	a5,a1,f2c0 <ck_uart_set_wordsize+0x30>
    f29c:	cdb1                	beqz	a1,f2f8 <ck_uart_set_wordsize+0x68>
    f29e:	00853f83          	ld	t6,8(a0)
    f2a2:	00cfc783          	lbu	a5,12(t6)
    f2a6:	0fd7f713          	andi	a4,a5,253
    f2aa:	00ef8623          	sb	a4,12(t6)
    f2ae:	00853283          	ld	t0,8(a0)
    f2b2:	00c2c303          	lbu	t1,12(t0)
    f2b6:	00136393          	ori	t2,t1,1
    f2ba:	00728623          	sb	t2,12(t0)
    f2be:	8082                	ret
    f2c0:	460d                	li	a2,3
    f2c2:	04c59563          	bne	a1,a2,f30c <ck_uart_set_wordsize+0x7c>
    f2c6:	6514                	ld	a3,8(a0)
    f2c8:	00c6c803          	lbu	a6,12(a3)
    f2cc:	00386893          	ori	a7,a6,3
    f2d0:	01168623          	sb	a7,12(a3)
    f2d4:	8082                	ret
    f2d6:	0001                	nop
    f2d8:	6518                	ld	a4,8(a0)
    f2da:	00c74283          	lbu	t0,12(a4)
    f2de:	0fe2f313          	andi	t1,t0,254
    f2e2:	00670623          	sb	t1,12(a4)
    f2e6:	00853383          	ld	t2,8(a0)
    f2ea:	00c3c503          	lbu	a0,12(t2)
    f2ee:	00256593          	ori	a1,a0,2
    f2f2:	00b38623          	sb	a1,12(t2)
    f2f6:	8082                	ret
    f2f8:	00853e03          	ld	t3,8(a0)
    f2fc:	00ce4e83          	lbu	t4,12(t3)
    f300:	0fceff13          	andi	t5,t4,252
    f304:	01ee0623          	sb	t5,12(t3)
    f308:	8082                	ret
    f30a:	0001                	nop
    f30c:	8082                	ret
    f30e:	0001                	nop

000000000000f310 <ck_uart_set_stopbit>:
    f310:	cd0c                	sw	a1,24(a0)
    f312:	cd99                	beqz	a1,f330 <ck_uart_set_stopbit+0x20>
    f314:	4305                	li	t1,1
    f316:	00658363          	beq	a1,t1,f31c <ck_uart_set_stopbit+0xc>
    f31a:	8082                	ret
    f31c:	00853383          	ld	t2,8(a0)
    f320:	00c3c503          	lbu	a0,12(t2)
    f324:	00456593          	ori	a1,a0,4
    f328:	00b38623          	sb	a1,12(t2)
    f32c:	8082                	ret
    f32e:	0001                	nop
    f330:	6518                	ld	a4,8(a0)
    f332:	00c74783          	lbu	a5,12(a4)
    f336:	0fb7f293          	andi	t0,a5,251
    f33a:	00570623          	sb	t0,12(a4)
    f33e:	8082                	ret

000000000000f340 <ck_uart_set_rxmode>:
    f340:	d10c                	sw	a1,32(a0)
    f342:	8082                	ret
    f344:	00000013          	nop
    f348:	00000013          	nop
    f34c:	00000013          	nop

000000000000f350 <ck_uart_set_txmode>:
    f350:	d14c                	sw	a1,36(a0)
    f352:	8082                	ret
    f354:	00000013          	nop
    f358:	00000013          	nop
    f35c:	00000013          	nop

000000000000f360 <ck_uart_open>:
    f360:	e981                	bnez	a1,f370 <ck_uart_open+0x10>
    f362:	100157b7          	lui	a5,0x10015
    f366:	00052023          	sw	zero,0(a0)
    f36a:	e51c                	sd	a5,8(a0)
    f36c:	4501                	li	a0,0
    f36e:	8082                	ret
    f370:	4505                	li	a0,1
    f372:	8082                	ret
    f374:	00000013          	nop
    f378:	00000013          	nop
    f37c:	00000013          	nop

000000000000f380 <ck_uart_init>:
    f380:	4118                	lw	a4,0(a0)
    f382:	67c1                	lui	a5,0x10
    f384:	37fd                	addiw	a5,a5,-1 # ffff <_malloc_trim_r+0x55>
    f386:	0af70963          	beq	a4,a5,f438 <ck_uart_init+0xb8>
    f38a:	4194                	lw	a3,0(a1)
    f38c:	05f5e2b7          	lui	t0,0x5f5e
    f390:	1002831b          	addiw	t1,t0,256 # 5f5e100 <__kernel_stack+0x5e70100>
    f394:	02d353bb          	divuw	t2,t1,a3
    f398:	6510                	ld	a2,8(a0)
    f39a:	c914                	sw	a3,16(a0)
    f39c:	4705                	li	a4,1
    f39e:	00c64803          	lbu	a6,12(a2)
    f3a2:	08086893          	ori	a7,a6,128
    f3a6:	01160623          	sb	a7,12(a2)
    f3aa:	2c43be0b          	th.extu	t3,t2,11,4
    f3ae:	01c60023          	sb	t3,0(a2)
    f3b2:	4cc3be8b          	th.extu	t4,t2,19,12
    f3b6:	01d60223          	sb	t4,4(a2)
    f3ba:	00c64f03          	lbu	t5,12(a2)
    f3be:	07ff7f93          	andi	t6,t5,127
    f3c2:	01f60623          	sb	t6,12(a2)
    f3c6:	459c                	lw	a5,8(a1)
    f3c8:	c95c                	sw	a5,20(a0)
    f3ca:	0ce78b63          	beq	a5,a4,f4a0 <ck_uart_init+0x120>
    f3ce:	4889                	li	a7,2
    f3d0:	11178e63          	beq	a5,a7,f4ec <ck_uart_init+0x16c>
    f3d4:	c7a5                	beqz	a5,f43c <ck_uart_init+0xbc>
    f3d6:	45d0                	lw	a2,12(a1)
    f3d8:	4389                	li	t2,2
    f3da:	cd50                	sw	a2,28(a0)
    f3dc:	06760d63          	beq	a2,t2,f456 <ck_uart_init+0xd6>
    f3e0:	0ec3ea63          	bltu	t2,a2,f4d4 <ck_uart_init+0x154>
    f3e4:	c265                	beqz	a2,f4c4 <ck_uart_init+0x144>
    f3e6:	00853803          	ld	a6,8(a0)
    f3ea:	00c84883          	lbu	a7,12(a6)
    f3ee:	0fd8fe13          	andi	t3,a7,253
    f3f2:	01c80623          	sb	t3,12(a6)
    f3f6:	00853e83          	ld	t4,8(a0)
    f3fa:	00cecf03          	lbu	t5,12(t4)
    f3fe:	001f6f93          	ori	t6,t5,1
    f402:	01fe8623          	sb	t6,12(t4)
    f406:	0045a283          	lw	t0,4(a1)
    f40a:	00552c23          	sw	t0,24(a0)
    f40e:	06028a63          	beqz	t0,f482 <ck_uart_init+0x102>
    f412:	4685                	li	a3,1
    f414:	00d29a63          	bne	t0,a3,f428 <ck_uart_init+0xa8>
    f418:	00853383          	ld	t2,8(a0)
    f41c:	00c3c603          	lbu	a2,12(t2)
    f420:	00466813          	ori	a6,a2,4
    f424:	01038623          	sb	a6,12(t2)
    f428:	0105a883          	lw	a7,16(a1)
    f42c:	49cc                	lw	a1,20(a1)
    f42e:	03152023          	sw	a7,32(a0)
    f432:	d14c                	sw	a1,36(a0)
    f434:	4501                	li	a0,0
    f436:	8082                	ret
    f438:	4505                	li	a0,1
    f43a:	8082                	ret
    f43c:	00853283          	ld	t0,8(a0)
    f440:	4389                	li	t2,2
    f442:	00c2c303          	lbu	t1,12(t0)
    f446:	0f737693          	andi	a3,t1,247
    f44a:	00d28623          	sb	a3,12(t0)
    f44e:	45d0                	lw	a2,12(a1)
    f450:	cd50                	sw	a2,28(a0)
    f452:	f87617e3          	bne	a2,t2,f3e0 <ck_uart_init+0x60>
    f456:	00853803          	ld	a6,8(a0)
    f45a:	00c84883          	lbu	a7,12(a6)
    f45e:	0fe8fe13          	andi	t3,a7,254
    f462:	01c80623          	sb	t3,12(a6)
    f466:	00853e83          	ld	t4,8(a0)
    f46a:	00cecf03          	lbu	t5,12(t4)
    f46e:	002f6f93          	ori	t6,t5,2
    f472:	01fe8623          	sb	t6,12(t4)
    f476:	0045a283          	lw	t0,4(a1)
    f47a:	00552c23          	sw	t0,24(a0)
    f47e:	f8029ae3          	bnez	t0,f412 <ck_uart_init+0x92>
    f482:	6518                	ld	a4,8(a0)
    f484:	00c74783          	lbu	a5,12(a4)
    f488:	0fb7f313          	andi	t1,a5,251
    f48c:	00670623          	sb	t1,12(a4)
    f490:	0105a883          	lw	a7,16(a1)
    f494:	49cc                	lw	a1,20(a1)
    f496:	03152023          	sw	a7,32(a0)
    f49a:	d14c                	sw	a1,36(a0)
    f49c:	4501                	li	a0,0
    f49e:	8082                	ret
    f4a0:	00853283          	ld	t0,8(a0)
    f4a4:	00c2c303          	lbu	t1,12(t0)
    f4a8:	00836693          	ori	a3,t1,8
    f4ac:	00d28623          	sb	a3,12(t0)
    f4b0:	00853383          	ld	t2,8(a0)
    f4b4:	00c3c603          	lbu	a2,12(t2)
    f4b8:	0ef67813          	andi	a6,a2,239
    f4bc:	01038623          	sb	a6,12(t2)
    f4c0:	bf19                	j	f3d6 <ck_uart_init+0x56>
    f4c2:	0001                	nop
    f4c4:	6514                	ld	a3,8(a0)
    f4c6:	00c6c383          	lbu	t2,12(a3)
    f4ca:	0fc3f613          	andi	a2,t2,252
    f4ce:	00c68623          	sb	a2,12(a3)
    f4d2:	bf15                	j	f406 <ck_uart_init+0x86>
    f4d4:	470d                	li	a4,3
    f4d6:	f2e618e3          	bne	a2,a4,f406 <ck_uart_init+0x86>
    f4da:	00853283          	ld	t0,8(a0)
    f4de:	00c2c783          	lbu	a5,12(t0)
    f4e2:	0037e313          	ori	t1,a5,3
    f4e6:	00628623          	sb	t1,12(t0)
    f4ea:	bf31                	j	f406 <ck_uart_init+0x86>
    f4ec:	00853e03          	ld	t3,8(a0)
    f4f0:	00ce4e83          	lbu	t4,12(t3)
    f4f4:	008eef13          	ori	t5,t4,8
    f4f8:	01ee0623          	sb	t5,12(t3)
    f4fc:	00853f83          	ld	t6,8(a0)
    f500:	00cfc703          	lbu	a4,12(t6)
    f504:	01076793          	ori	a5,a4,16
    f508:	00ff8623          	sb	a5,12(t6)
    f50c:	b5e9                	j	f3d6 <ck_uart_init+0x56>
    f50e:	0001                	nop

000000000000f510 <ck_uart_close>:
    f510:	67c1                	lui	a5,0x10
    f512:	37fd                	addiw	a5,a5,-1 # ffff <_malloc_trim_r+0x55>
    f514:	c11c                	sw	a5,0(a0)
    f516:	02053023          	sd	zero,32(a0)
    f51a:	4501                	li	a0,0
    f51c:	8082                	ret
    f51e:	0001                	nop

000000000000f520 <ck_uart_putc>:
    f520:	515c                	lw	a5,36(a0)
    f522:	c7ad                	beqz	a5,f58c <ck_uart_putc+0x6c>
    f524:	00853283          	ld	t0,8(a0)
    f528:	0142c703          	lbu	a4,20(t0)
    f52c:	02077313          	andi	t1,a4,32
    f530:	04031963          	bnez	t1,f582 <ck_uart_putc+0x62>
    f534:	0142c383          	lbu	t2,20(t0)
    f538:	0203f513          	andi	a0,t2,32
    f53c:	e139                	bnez	a0,f582 <ck_uart_putc+0x62>
    f53e:	0142c603          	lbu	a2,20(t0)
    f542:	02067693          	andi	a3,a2,32
    f546:	ee95                	bnez	a3,f582 <ck_uart_putc+0x62>
    f548:	0142c803          	lbu	a6,20(t0)
    f54c:	02087893          	andi	a7,a6,32
    f550:	02089963          	bnez	a7,f582 <ck_uart_putc+0x62>
    f554:	0142ce03          	lbu	t3,20(t0)
    f558:	020e7e93          	andi	t4,t3,32
    f55c:	020e9363          	bnez	t4,f582 <ck_uart_putc+0x62>
    f560:	0142cf03          	lbu	t5,20(t0)
    f564:	020f7f93          	andi	t6,t5,32
    f568:	000f9d63          	bnez	t6,f582 <ck_uart_putc+0x62>
    f56c:	0142c783          	lbu	a5,20(t0)
    f570:	0207f713          	andi	a4,a5,32
    f574:	e719                	bnez	a4,f582 <ck_uart_putc+0x62>
    f576:	0142c303          	lbu	t1,20(t0)
    f57a:	02037393          	andi	t2,t1,32
    f57e:	fa0385e3          	beqz	t2,f528 <ck_uart_putc+0x8>
    f582:	00b28023          	sb	a1,0(t0)
    f586:	4501                	li	a0,0
    f588:	8082                	ret
    f58a:	0001                	nop
    f58c:	4505                	li	a0,1
    f58e:	8082                	ret

000000000000f590 <ck_uart_status>:
    f590:	4505                	li	a0,1
    f592:	8082                	ret
	...

000000000000f5a0 <vasprintf>:
    f5a0:	7139                	addi	sp,sp,-64
    f5a2:	f9515b0b          	th.sdd	s6,s5,(sp),0,4
    f5a6:	8b2a                	mv	s6,a0
    f5a8:	852e                	mv	a0,a1
    f5aa:	fb315a0b          	th.sdd	s4,s3,(sp),1,4
    f5ae:	fc91590b          	th.sdd	s2,s1,(sp),2,4
    f5b2:	fe11540b          	th.sdd	s0,ra,(sp),3,4
    f5b6:	8a2e                	mv	s4,a1
    f5b8:	8ab2                	mv	s5,a2
    f5ba:	157000ef          	jal	ff10 <strlen>
    f5be:	00150993          	addi	s3,a0,1
    f5c2:	f009f293          	andi	t0,s3,-256
    f5c6:	10028913          	addi	s2,t0,256
    f5ca:	20028993          	addi	s3,t0,512
    f5ce:	000b3023          	sd	zero,0(s6)
    f5d2:	0001                	nop
    f5d4:	00000013          	nop
    f5d8:	854a                	mv	a0,s2
    f5da:	228000ef          	jal	f802 <malloc>
    f5de:	84aa                	mv	s1,a0
    f5e0:	c525                	beqz	a0,f648 <vasprintf+0xa8>
    f5e2:	86d6                	mv	a3,s5
    f5e4:	8652                	mv	a2,s4
    f5e6:	85ca                	mv	a1,s2
    f5e8:	ba9ff0ef          	jal	f190 <vsnprintf>
    f5ec:	842a                	mv	s0,a0
    f5ee:	00054f63          	bltz	a0,f60c <vasprintf+0x6c>
    f5f2:	197d                	addi	s2,s2,-1
    f5f4:	03256463          	bltu	a0,s2,f61c <vasprintf+0x7c>
    f5f8:	8526                	mv	a0,s1
    f5fa:	214000ef          	jal	f80e <free>
    f5fe:	01346a63          	bltu	s0,s3,f612 <vasprintf+0x72>
    f602:	0014091b          	addiw	s2,s0,1
    f606:	10098993          	addi	s3,s3,256
    f60a:	b7f9                	j	f5d8 <vasprintf+0x38>
    f60c:	8526                	mv	a0,s1
    f60e:	200000ef          	jal	f80e <free>
    f612:	894e                	mv	s2,s3
    f614:	10098993          	addi	s3,s3,256
    f618:	b7c1                	j	f5d8 <vasprintf+0x38>
    f61a:	0001                	nop
    f61c:	ed01                	bnez	a0,f634 <vasprintf+0x94>
    f61e:	8522                	mv	a0,s0
    f620:	fe11440b          	th.ldd	s0,ra,(sp),3,4
    f624:	fc91490b          	th.ldd	s2,s1,(sp),2,4
    f628:	fb314a0b          	th.ldd	s4,s3,(sp),1,4
    f62c:	f9514b0b          	th.ldd	s6,s5,(sp),0,4
    f630:	6121                	addi	sp,sp,64
    f632:	8082                	ret
    f634:	8526                	mv	a0,s1
    f636:	095000ef          	jal	feca <strdup>
    f63a:	c909                	beqz	a0,f64c <vasprintf+0xac>
    f63c:	00ab3023          	sd	a0,0(s6)
    f640:	8526                	mv	a0,s1
    f642:	1cc000ef          	jal	f80e <free>
    f646:	bfe1                	j	f61e <vasprintf+0x7e>
    f648:	5451                	li	s0,-12
    f64a:	bfd1                	j	f61e <vasprintf+0x7e>
    f64c:	009b3023          	sd	s1,0(s6)
    f650:	b7f9                	j	f61e <vasprintf+0x7e>
    f652:	0001                	nop
    f654:	00000013          	nop
    f658:	00000013          	nop
    f65c:	00000013          	nop

000000000000f660 <asprintf>:
    f660:	7119                	addi	sp,sp,-128
    f662:	fb515b0b          	th.sdd	s6,s5,(sp),1,4
    f666:	8b2a                	mv	s6,a0
    f668:	05010a93          	addi	s5,sp,80
    f66c:	852e                	mv	a0,a1
    f66e:	fd315a0b          	th.sdd	s4,s3,(sp),2,4
    f672:	fe91590b          	th.sdd	s2,s1,(sp),3,4
    f676:	e0a2                	sd	s0,64(sp)
    f678:	e486                	sd	ra,72(sp)
    f67a:	e8b2                	sd	a2,80(sp)
    f67c:	ecb6                	sd	a3,88(sp)
    f67e:	f0ba                	sd	a4,96(sp)
    f680:	f4be                	sd	a5,104(sp)
    f682:	f8c2                	sd	a6,112(sp)
    f684:	fcc6                	sd	a7,120(sp)
    f686:	8a2e                	mv	s4,a1
    f688:	e456                	sd	s5,8(sp)
    f68a:	087000ef          	jal	ff10 <strlen>
    f68e:	00150993          	addi	s3,a0,1
    f692:	f009f293          	andi	t0,s3,-256
    f696:	10028913          	addi	s2,t0,256
    f69a:	20028993          	addi	s3,t0,512
    f69e:	000b3023          	sd	zero,0(s6)
    f6a2:	0001                	nop
    f6a4:	00000013          	nop
    f6a8:	854a                	mv	a0,s2
    f6aa:	158000ef          	jal	f802 <malloc>
    f6ae:	84aa                	mv	s1,a0
    f6b0:	c525                	beqz	a0,f718 <asprintf+0xb8>
    f6b2:	86d6                	mv	a3,s5
    f6b4:	8652                	mv	a2,s4
    f6b6:	85ca                	mv	a1,s2
    f6b8:	ad9ff0ef          	jal	f190 <vsnprintf>
    f6bc:	842a                	mv	s0,a0
    f6be:	00054f63          	bltz	a0,f6dc <asprintf+0x7c>
    f6c2:	197d                	addi	s2,s2,-1
    f6c4:	03256463          	bltu	a0,s2,f6ec <asprintf+0x8c>
    f6c8:	8526                	mv	a0,s1
    f6ca:	144000ef          	jal	f80e <free>
    f6ce:	01346a63          	bltu	s0,s3,f6e2 <asprintf+0x82>
    f6d2:	0014091b          	addiw	s2,s0,1
    f6d6:	10098993          	addi	s3,s3,256
    f6da:	b7f9                	j	f6a8 <asprintf+0x48>
    f6dc:	8526                	mv	a0,s1
    f6de:	130000ef          	jal	f80e <free>
    f6e2:	894e                	mv	s2,s3
    f6e4:	10098993          	addi	s3,s3,256
    f6e8:	b7c1                	j	f6a8 <asprintf+0x48>
    f6ea:	0001                	nop
    f6ec:	ed01                	bnez	a0,f704 <asprintf+0xa4>
    f6ee:	8522                	mv	a0,s0
    f6f0:	6406                	ld	s0,64(sp)
    f6f2:	60a6                	ld	ra,72(sp)
    f6f4:	fe91490b          	th.ldd	s2,s1,(sp),3,4
    f6f8:	fd314a0b          	th.ldd	s4,s3,(sp),2,4
    f6fc:	fb514b0b          	th.ldd	s6,s5,(sp),1,4
    f700:	6109                	addi	sp,sp,128
    f702:	8082                	ret
    f704:	8526                	mv	a0,s1
    f706:	7c4000ef          	jal	feca <strdup>
    f70a:	c909                	beqz	a0,f71c <asprintf+0xbc>
    f70c:	00ab3023          	sd	a0,0(s6)
    f710:	8526                	mv	a0,s1
    f712:	0fc000ef          	jal	f80e <free>
    f716:	bfe1                	j	f6ee <asprintf+0x8e>
    f718:	5451                	li	s0,-12
    f71a:	bfd1                	j	f6ee <asprintf+0x8e>
    f71c:	009b3023          	sd	s1,0(s6)
    f720:	b7f9                	j	f6ee <asprintf+0x8e>
	...

000000000000f730 <get_vtimer>:
    f730:	1141                	addi	sp,sp,-16
    f732:	c01027f3          	rdtime	a5
    f736:	c63e                	sw	a5,12(sp)
    f738:	4532                	lw	a0,12(sp)
    f73a:	0141                	addi	sp,sp,16
    f73c:	8082                	ret
    f73e:	0001                	nop

000000000000f740 <sim_end>:
    f740:	050017b7          	lui	a5,0x5001
    f744:	44333737          	lui	a4,0x44333
    f748:	00579293          	slli	t0,a5,0x5
    f74c:	22270313          	addi	t1,a4,546 # 44333222 <__kernel_stack+0x44245222>
    f750:	f462a423          	sw	t1,-184(t0)
    f754:	8082                	ret

000000000000f756 <modf>:
    f756:	e20507d3          	fmv.x.d	a5,fa0
    f75a:	484d                	li	a6,19
    f75c:	4347d713          	srai	a4,a5,0x34
    f760:	7ff77713          	andi	a4,a4,2047
    f764:	c017061b          	addiw	a2,a4,-1023
    f768:	0007869b          	sext.w	a3,a5
    f76c:	4207d593          	srai	a1,a5,0x20
    f770:	02c84663          	blt	a6,a2,f79c <modf+0x46>
    f774:	06064f63          	bltz	a2,f7f2 <modf+0x9c>
    f778:	00100737          	lui	a4,0x100
    f77c:	377d                	addiw	a4,a4,-1 # fffff <__kernel_stack+0x11fff>
    f77e:	40c7573b          	sraw	a4,a4,a2
    f782:	00e5f633          	and	a2,a1,a4
    f786:	8ed1                	or	a3,a3,a2
    f788:	e6b9                	bnez	a3,f7d6 <modf+0x80>
    f78a:	4705                	li	a4,1
    f78c:	077e                	slli	a4,a4,0x1f
    f78e:	8f6d                	and	a4,a4,a1
    f790:	e11c                	sd	a5,0(a0)
    f792:	02071793          	slli	a5,a4,0x20
    f796:	f2078553          	fmv.d.x	fa0,a5
    f79a:	8082                	ret
    f79c:	03300813          	li	a6,51
    f7a0:	fec845e3          	blt	a6,a2,f78a <modf+0x34>
    f7a4:	567d                	li	a2,-1
    f7a6:	bed7071b          	addiw	a4,a4,-1043
    f7aa:	00e6573b          	srlw	a4,a2,a4
    f7ae:	00d77633          	and	a2,a4,a3
    f7b2:	de61                	beqz	a2,f78a <modf+0x34>
    f7b4:	fff74713          	not	a4,a4
    f7b8:	8ef9                	and	a3,a3,a4
    f7ba:	1682                	slli	a3,a3,0x20
    f7bc:	9281                	srli	a3,a3,0x20
    f7be:	1582                	slli	a1,a1,0x20
    f7c0:	8dd5                	or	a1,a1,a3
    f7c2:	f2058753          	fmv.d.x	fa4,a1
    f7c6:	e10c                	sd	a1,0(a0)
    f7c8:	0ae577d3          	fsub.d	fa5,fa0,fa4
    f7cc:	e20787d3          	fmv.x.d	a5,fa5
    f7d0:	f2078553          	fmv.d.x	fa0,a5
    f7d4:	8082                	ret
    f7d6:	fff74713          	not	a4,a4
    f7da:	8f6d                	and	a4,a4,a1
    f7dc:	1702                	slli	a4,a4,0x20
    f7de:	f2070753          	fmv.d.x	fa4,a4
    f7e2:	e118                	sd	a4,0(a0)
    f7e4:	0ae577d3          	fsub.d	fa5,fa0,fa4
    f7e8:	e20787d3          	fmv.x.d	a5,fa5
    f7ec:	f2078553          	fmv.d.x	fa0,a5
    f7f0:	8082                	ret
    f7f2:	4705                	li	a4,1
    f7f4:	077e                	slli	a4,a4,0x1f
    f7f6:	8f6d                	and	a4,a4,a1
    f7f8:	1702                	slli	a4,a4,0x20
    f7fa:	f2078553          	fmv.d.x	fa0,a5
    f7fe:	e118                	sd	a4,0(a0)
    f800:	8082                	ret

000000000000f802 <malloc>:
    f802:	85aa                	mv	a1,a0
    f804:	00031517          	auipc	a0,0x31
    f808:	7ac53503          	ld	a0,1964(a0) # 40fb0 <_impure_ptr>
    f80c:	a801                	j	f81c <_malloc_r>

000000000000f80e <free>:
    f80e:	85aa                	mv	a1,a0
    f810:	00031517          	auipc	a0,0x31
    f814:	7a053503          	ld	a0,1952(a0) # 40fb0 <_impure_ptr>
    f818:	0710006f          	j	10088 <_free_r>

000000000000f81c <_malloc_r>:
    f81c:	711d                	addi	sp,sp,-96
    f81e:	e4a6                	sd	s1,72(sp)
    f820:	e0ca                	sd	s2,64(sp)
    f822:	ec86                	sd	ra,88(sp)
    f824:	e8a2                	sd	s0,80(sp)
    f826:	fc4e                	sd	s3,56(sp)
    f828:	01758493          	addi	s1,a1,23
    f82c:	02e00793          	li	a5,46
    f830:	892a                	mv	s2,a0
    f832:	0497ec63          	bltu	a5,s1,f88a <_malloc_r+0x6e>
    f836:	02000493          	li	s1,32
    f83a:	18b4eb63          	bltu	s1,a1,f9d0 <_malloc_r+0x1b4>
    f83e:	63c000ef          	jal	fe7a <__malloc_lock>
    f842:	05000793          	li	a5,80
    f846:	4591                	li	a1,4
    f848:	00030997          	auipc	s3,0x30
    f84c:	7e898993          	addi	s3,s3,2024 # 40030 <__malloc_av_>
    f850:	97ce                	add	a5,a5,s3
    f852:	6780                	ld	s0,8(a5)
    f854:	ff078713          	addi	a4,a5,-16 # 5000ff0 <__kernel_stack+0x4f12ff0>
    f858:	34e40b63          	beq	s0,a4,fbae <_malloc_r+0x392>
    f85c:	641c                	ld	a5,8(s0)
    f85e:	6c14                	ld	a3,24(s0)
    f860:	6810                	ld	a2,16(s0)
    f862:	9bf1                	andi	a5,a5,-4
    f864:	97a2                	add	a5,a5,s0
    f866:	6798                	ld	a4,8(a5)
    f868:	ee14                	sd	a3,24(a2)
    f86a:	ea90                	sd	a2,16(a3)
    f86c:	00176713          	ori	a4,a4,1
    f870:	854a                	mv	a0,s2
    f872:	e798                	sd	a4,8(a5)
    f874:	612000ef          	jal	fe86 <__malloc_unlock>
    f878:	60e6                	ld	ra,88(sp)
    f87a:	01040513          	addi	a0,s0,16
    f87e:	6446                	ld	s0,80(sp)
    f880:	64a6                	ld	s1,72(sp)
    f882:	6906                	ld	s2,64(sp)
    f884:	79e2                	ld	s3,56(sp)
    f886:	6125                	addi	sp,sp,96
    f888:	8082                	ret
    f88a:	800007b7          	lui	a5,0x80000
    f88e:	98c1                	andi	s1,s1,-16
    f890:	fff7c793          	not	a5,a5
    f894:	1297ee63          	bltu	a5,s1,f9d0 <_malloc_r+0x1b4>
    f898:	12b4ec63          	bltu	s1,a1,f9d0 <_malloc_r+0x1b4>
    f89c:	5de000ef          	jal	fe7a <__malloc_lock>
    f8a0:	1f700793          	li	a5,503
    f8a4:	4097f063          	bgeu	a5,s1,fca4 <_malloc_r+0x488>
    f8a8:	0094d793          	srli	a5,s1,0x9
    f8ac:	12078d63          	beqz	a5,f9e6 <_malloc_r+0x1ca>
    f8b0:	4711                	li	a4,4
    f8b2:	34f76563          	bltu	a4,a5,fbfc <_malloc_r+0x3e0>
    f8b6:	0064d793          	srli	a5,s1,0x6
    f8ba:	0397859b          	addiw	a1,a5,57 # ffffffff80000039 <__kernel_stack+0xffffffff7ff12039>
    f8be:	0015961b          	slliw	a2,a1,0x1
    f8c2:	0387881b          	addiw	a6,a5,56
    f8c6:	060e                	slli	a2,a2,0x3
    f8c8:	00030997          	auipc	s3,0x30
    f8cc:	76898993          	addi	s3,s3,1896 # 40030 <__malloc_av_>
    f8d0:	964e                	add	a2,a2,s3
    f8d2:	6600                	ld	s0,8(a2)
    f8d4:	1641                	addi	a2,a2,-16
    f8d6:	02860163          	beq	a2,s0,f8f8 <_malloc_r+0xdc>
    f8da:	457d                	li	a0,31
    f8dc:	a039                	j	f8ea <_malloc_r+0xce>
    f8de:	6c14                	ld	a3,24(s0)
    f8e0:	2a075363          	bgez	a4,fb86 <_malloc_r+0x36a>
    f8e4:	00d60a63          	beq	a2,a3,f8f8 <_malloc_r+0xdc>
    f8e8:	8436                	mv	s0,a3
    f8ea:	641c                	ld	a5,8(s0)
    f8ec:	9bf1                	andi	a5,a5,-4
    f8ee:	40978733          	sub	a4,a5,s1
    f8f2:	fee556e3          	bge	a0,a4,f8de <_malloc_r+0xc2>
    f8f6:	85c2                	mv	a1,a6
    f8f8:	0209b403          	ld	s0,32(s3)
    f8fc:	00030897          	auipc	a7,0x30
    f900:	74488893          	addi	a7,a7,1860 # 40040 <__malloc_av_+0x10>
    f904:	27140e63          	beq	s0,a7,fb80 <_malloc_r+0x364>
    f908:	641c                	ld	a5,8(s0)
    f90a:	46fd                	li	a3,31
    f90c:	9bf1                	andi	a5,a5,-4
    f90e:	40978733          	sub	a4,a5,s1
    f912:	36e6c263          	blt	a3,a4,fc76 <_malloc_r+0x45a>
    f916:	0319b423          	sd	a7,40(s3)
    f91a:	0319b023          	sd	a7,32(s3)
    f91e:	34075163          	bgez	a4,fc60 <_malloc_r+0x444>
    f922:	1ff00713          	li	a4,511
    f926:	0089b503          	ld	a0,8(s3)
    f92a:	28f76763          	bltu	a4,a5,fbb8 <_malloc_r+0x39c>
    f92e:	838d                	srli	a5,a5,0x3
    f930:	2781                	sext.w	a5,a5
    f932:	0017871b          	addiw	a4,a5,1
    f936:	0017171b          	slliw	a4,a4,0x1
    f93a:	070e                	slli	a4,a4,0x3
    f93c:	974e                	add	a4,a4,s3
    f93e:	6310                	ld	a2,0(a4)
    f940:	4027d79b          	sraiw	a5,a5,0x2
    f944:	4685                	li	a3,1
    f946:	00f697b3          	sll	a5,a3,a5
    f94a:	8d5d                	or	a0,a0,a5
    f94c:	ff070793          	addi	a5,a4,-16
    f950:	e810                	sd	a2,16(s0)
    f952:	ec1c                	sd	a5,24(s0)
    f954:	00a9b423          	sd	a0,8(s3)
    f958:	e300                	sd	s0,0(a4)
    f95a:	ee00                	sd	s0,24(a2)
    f95c:	4025d79b          	sraiw	a5,a1,0x2
    f960:	4605                	li	a2,1
    f962:	00f61633          	sll	a2,a2,a5
    f966:	08c56763          	bltu	a0,a2,f9f4 <_malloc_r+0x1d8>
    f96a:	00a677b3          	and	a5,a2,a0
    f96e:	ef81                	bnez	a5,f986 <_malloc_r+0x16a>
    f970:	0606                	slli	a2,a2,0x1
    f972:	99f1                	andi	a1,a1,-4
    f974:	00a677b3          	and	a5,a2,a0
    f978:	2591                	addiw	a1,a1,4
    f97a:	e791                	bnez	a5,f986 <_malloc_r+0x16a>
    f97c:	0606                	slli	a2,a2,0x1
    f97e:	00a677b3          	and	a5,a2,a0
    f982:	2591                	addiw	a1,a1,4
    f984:	dfe5                	beqz	a5,f97c <_malloc_r+0x160>
    f986:	487d                	li	a6,31
    f988:	0015831b          	addiw	t1,a1,1
    f98c:	0013131b          	slliw	t1,t1,0x1
    f990:	030e                	slli	t1,t1,0x3
    f992:	1341                	addi	t1,t1,-16
    f994:	934e                	add	t1,t1,s3
    f996:	851a                	mv	a0,t1
    f998:	6d1c                	ld	a5,24(a0)
    f99a:	8e2e                	mv	t3,a1
    f99c:	28f50163          	beq	a0,a5,fc1e <_malloc_r+0x402>
    f9a0:	6798                	ld	a4,8(a5)
    f9a2:	843e                	mv	s0,a5
    f9a4:	6f9c                	ld	a5,24(a5)
    f9a6:	9b71                	andi	a4,a4,-4
    f9a8:	409706b3          	sub	a3,a4,s1
    f9ac:	28d84063          	blt	a6,a3,fc2c <_malloc_r+0x410>
    f9b0:	fe06c6e3          	bltz	a3,f99c <_malloc_r+0x180>
    f9b4:	9722                	add	a4,a4,s0
    f9b6:	6714                	ld	a3,8(a4)
    f9b8:	6810                	ld	a2,16(s0)
    f9ba:	854a                	mv	a0,s2
    f9bc:	0016e693          	ori	a3,a3,1
    f9c0:	e714                	sd	a3,8(a4)
    f9c2:	ee1c                	sd	a5,24(a2)
    f9c4:	eb90                	sd	a2,16(a5)
    f9c6:	4c0000ef          	jal	fe86 <__malloc_unlock>
    f9ca:	01040513          	addi	a0,s0,16
    f9ce:	a029                	j	f9d8 <_malloc_r+0x1bc>
    f9d0:	47b1                	li	a5,12
    f9d2:	00f92023          	sw	a5,0(s2)
    f9d6:	4501                	li	a0,0
    f9d8:	60e6                	ld	ra,88(sp)
    f9da:	6446                	ld	s0,80(sp)
    f9dc:	64a6                	ld	s1,72(sp)
    f9de:	6906                	ld	s2,64(sp)
    f9e0:	79e2                	ld	s3,56(sp)
    f9e2:	6125                	addi	sp,sp,96
    f9e4:	8082                	ret
    f9e6:	40000613          	li	a2,1024
    f9ea:	04000593          	li	a1,64
    f9ee:	03f00813          	li	a6,63
    f9f2:	bdd9                	j	f8c8 <_malloc_r+0xac>
    f9f4:	0109b403          	ld	s0,16(s3)
    f9f8:	f456                	sd	s5,40(sp)
    f9fa:	641c                	ld	a5,8(s0)
    f9fc:	ffc7fa93          	andi	s5,a5,-4
    fa00:	009ae763          	bltu	s5,s1,fa0e <_malloc_r+0x1f2>
    fa04:	409a8733          	sub	a4,s5,s1
    fa08:	47fd                	li	a5,31
    fa0a:	14e7c563          	blt	a5,a4,fb54 <_malloc_r+0x338>
    fa0e:	e862                	sd	s8,16(sp)
    fa10:	00031c17          	auipc	s8,0x31
    fa14:	590c0c13          	addi	s8,s8,1424 # 40fa0 <__malloc_sbrk_base>
    fa18:	f852                	sd	s4,48(sp)
    fa1a:	000c3703          	ld	a4,0(s8)
    fa1e:	00031a17          	auipc	s4,0x31
    fa22:	64aa3a03          	ld	s4,1610(s4) # 41068 <__malloc_top_pad>
    fa26:	ec5e                	sd	s7,24(sp)
    fa28:	f05a                	sd	s6,32(sp)
    fa2a:	57fd                	li	a5,-1
    fa2c:	01540bb3          	add	s7,s0,s5
    fa30:	9a26                	add	s4,s4,s1
    fa32:	2ef70f63          	beq	a4,a5,fd30 <_malloc_r+0x514>
    fa36:	6785                	lui	a5,0x1
    fa38:	07fd                	addi	a5,a5,31 # 101f <core_bench_list+0x6bf>
    fa3a:	9a3e                	add	s4,s4,a5
    fa3c:	77fd                	lui	a5,0xfffff
    fa3e:	00fa7a33          	and	s4,s4,a5
    fa42:	85d2                	mv	a1,s4
    fa44:	854a                	mv	a0,s2
    fa46:	44c000ef          	jal	fe92 <_sbrk_r>
    fa4a:	57fd                	li	a5,-1
    fa4c:	8b2a                	mv	s6,a0
    fa4e:	38f50363          	beq	a0,a5,fdd4 <_malloc_r+0x5b8>
    fa52:	e466                	sd	s9,8(sp)
    fa54:	0d756e63          	bltu	a0,s7,fb30 <_malloc_r+0x314>
    fa58:	00031717          	auipc	a4,0x31
    fa5c:	5d872703          	lw	a4,1496(a4) # 41030 <__malloc_current_mallinfo>
    fa60:	00031c97          	auipc	s9,0x31
    fa64:	5d0c8c93          	addi	s9,s9,1488 # 41030 <__malloc_current_mallinfo>
    fa68:	0147073b          	addw	a4,a4,s4
    fa6c:	00eca023          	sw	a4,0(s9)
    fa70:	86ba                	mv	a3,a4
    fa72:	36ab8563          	beq	s7,a0,fddc <_malloc_r+0x5c0>
    fa76:	000c3703          	ld	a4,0(s8)
    fa7a:	57fd                	li	a5,-1
    fa7c:	36f70d63          	beq	a4,a5,fdf6 <_malloc_r+0x5da>
    fa80:	417b07b3          	sub	a5,s6,s7
    fa84:	9fb5                	addw	a5,a5,a3
    fa86:	00fca023          	sw	a5,0(s9)
    fa8a:	00fb7c13          	andi	s8,s6,15
    fa8e:	2a0c0d63          	beqz	s8,fd48 <_malloc_r+0x52c>
    fa92:	418b0b33          	sub	s6,s6,s8
    fa96:	6685                	lui	a3,0x1
    fa98:	0b41                	addi	s6,s6,16
    fa9a:	06c1                	addi	a3,a3,16 # 1010 <core_bench_list+0x6b0>
    fa9c:	9a5a                	add	s4,s4,s6
    fa9e:	418686b3          	sub	a3,a3,s8
    faa2:	414686b3          	sub	a3,a3,s4
    faa6:	16d2                	slli	a3,a3,0x34
    faa8:	0346db93          	srli	s7,a3,0x34
    faac:	85de                	mv	a1,s7
    faae:	854a                	mv	a0,s2
    fab0:	3e2000ef          	jal	fe92 <_sbrk_r>
    fab4:	57fd                	li	a5,-1
    fab6:	36f50f63          	beq	a0,a5,fe34 <_malloc_r+0x618>
    faba:	41650533          	sub	a0,a0,s6
    fabe:	01750a33          	add	s4,a0,s7
    fac2:	000b869b          	sext.w	a3,s7
    fac6:	00031717          	auipc	a4,0x31
    faca:	56a72703          	lw	a4,1386(a4) # 41030 <__malloc_current_mallinfo>
    face:	0169b823          	sd	s6,16(s3)
    fad2:	001a6793          	ori	a5,s4,1
    fad6:	9f35                	addw	a4,a4,a3
    fad8:	00fb3423          	sd	a5,8(s6)
    fadc:	00eca023          	sw	a4,0(s9)
    fae0:	03340563          	beq	s0,s3,fb0a <_malloc_r+0x2ee>
    fae4:	467d                	li	a2,31
    fae6:	29567163          	bgeu	a2,s5,fd68 <_malloc_r+0x54c>
    faea:	6414                	ld	a3,8(s0)
    faec:	fe8a8793          	addi	a5,s5,-24
    faf0:	9bc1                	andi	a5,a5,-16
    faf2:	8a85                	andi	a3,a3,1
    faf4:	8edd                	or	a3,a3,a5
    faf6:	e414                	sd	a3,8(s0)
    faf8:	45a5                	li	a1,9
    fafa:	00f406b3          	add	a3,s0,a5
    fafe:	e68c                	sd	a1,8(a3)
    fb00:	ea8c                	sd	a1,16(a3)
    fb02:	20f66b63          	bltu	a2,a5,fd18 <_malloc_r+0x4fc>
    fb06:	008b3783          	ld	a5,8(s6)
    fb0a:	00031697          	auipc	a3,0x31
    fb0e:	55668693          	addi	a3,a3,1366 # 41060 <__malloc_max_sbrked_mem>
    fb12:	6290                	ld	a2,0(a3)
    fb14:	00e67363          	bgeu	a2,a4,fb1a <_malloc_r+0x2fe>
    fb18:	e298                	sd	a4,0(a3)
    fb1a:	00031697          	auipc	a3,0x31
    fb1e:	53e68693          	addi	a3,a3,1342 # 41058 <__malloc_max_total_mem>
    fb22:	6290                	ld	a2,0(a3)
    fb24:	00e67363          	bgeu	a2,a4,fb2a <_malloc_r+0x30e>
    fb28:	e298                	sd	a4,0(a3)
    fb2a:	6ca2                	ld	s9,8(sp)
    fb2c:	845a                	mv	s0,s6
    fb2e:	a039                	j	fb3c <_malloc_r+0x320>
    fb30:	29340563          	beq	s0,s3,fdba <_malloc_r+0x59e>
    fb34:	0109b403          	ld	s0,16(s3)
    fb38:	6ca2                	ld	s9,8(sp)
    fb3a:	641c                	ld	a5,8(s0)
    fb3c:	9bf1                	andi	a5,a5,-4
    fb3e:	40978733          	sub	a4,a5,s1
    fb42:	2297e763          	bltu	a5,s1,fd70 <_malloc_r+0x554>
    fb46:	47fd                	li	a5,31
    fb48:	22e7d463          	bge	a5,a4,fd70 <_malloc_r+0x554>
    fb4c:	7a42                	ld	s4,48(sp)
    fb4e:	7b02                	ld	s6,32(sp)
    fb50:	6be2                	ld	s7,24(sp)
    fb52:	6c42                	ld	s8,16(sp)
    fb54:	0014e793          	ori	a5,s1,1
    fb58:	e41c                	sd	a5,8(s0)
    fb5a:	94a2                	add	s1,s1,s0
    fb5c:	0099b823          	sd	s1,16(s3)
    fb60:	00176713          	ori	a4,a4,1
    fb64:	854a                	mv	a0,s2
    fb66:	e498                	sd	a4,8(s1)
    fb68:	31e000ef          	jal	fe86 <__malloc_unlock>
    fb6c:	60e6                	ld	ra,88(sp)
    fb6e:	01040513          	addi	a0,s0,16
    fb72:	6446                	ld	s0,80(sp)
    fb74:	7aa2                	ld	s5,40(sp)
    fb76:	64a6                	ld	s1,72(sp)
    fb78:	6906                	ld	s2,64(sp)
    fb7a:	79e2                	ld	s3,56(sp)
    fb7c:	6125                	addi	sp,sp,96
    fb7e:	8082                	ret
    fb80:	0089b503          	ld	a0,8(s3)
    fb84:	bbe1                	j	f95c <_malloc_r+0x140>
    fb86:	6810                	ld	a2,16(s0)
    fb88:	97a2                	add	a5,a5,s0
    fb8a:	6798                	ld	a4,8(a5)
    fb8c:	ee14                	sd	a3,24(a2)
    fb8e:	ea90                	sd	a2,16(a3)
    fb90:	00176713          	ori	a4,a4,1
    fb94:	854a                	mv	a0,s2
    fb96:	e798                	sd	a4,8(a5)
    fb98:	2ee000ef          	jal	fe86 <__malloc_unlock>
    fb9c:	60e6                	ld	ra,88(sp)
    fb9e:	01040513          	addi	a0,s0,16
    fba2:	6446                	ld	s0,80(sp)
    fba4:	64a6                	ld	s1,72(sp)
    fba6:	6906                	ld	s2,64(sp)
    fba8:	79e2                	ld	s3,56(sp)
    fbaa:	6125                	addi	sp,sp,96
    fbac:	8082                	ret
    fbae:	6f80                	ld	s0,24(a5)
    fbb0:	2589                	addiw	a1,a1,2
    fbb2:	d48783e3          	beq	a5,s0,f8f8 <_malloc_r+0xdc>
    fbb6:	b15d                	j	f85c <_malloc_r+0x40>
    fbb8:	0097d713          	srli	a4,a5,0x9
    fbbc:	4691                	li	a3,4
    fbbe:	0ee6fc63          	bgeu	a3,a4,fcb6 <_malloc_r+0x49a>
    fbc2:	46d1                	li	a3,20
    fbc4:	1ae6ef63          	bltu	a3,a4,fd82 <_malloc_r+0x566>
    fbc8:	05c7061b          	addiw	a2,a4,92
    fbcc:	0016161b          	slliw	a2,a2,0x1
    fbd0:	060e                	slli	a2,a2,0x3
    fbd2:	05b7069b          	addiw	a3,a4,91
    fbd6:	964e                	add	a2,a2,s3
    fbd8:	6218                	ld	a4,0(a2)
    fbda:	1641                	addi	a2,a2,-16
    fbdc:	00e61663          	bne	a2,a4,fbe8 <_malloc_r+0x3cc>
    fbe0:	aa99                	j	fd36 <_malloc_r+0x51a>
    fbe2:	6b18                	ld	a4,16(a4)
    fbe4:	00e60663          	beq	a2,a4,fbf0 <_malloc_r+0x3d4>
    fbe8:	6714                	ld	a3,8(a4)
    fbea:	9af1                	andi	a3,a3,-4
    fbec:	fed7ebe3          	bltu	a5,a3,fbe2 <_malloc_r+0x3c6>
    fbf0:	6f10                	ld	a2,24(a4)
    fbf2:	ec10                	sd	a2,24(s0)
    fbf4:	e818                	sd	a4,16(s0)
    fbf6:	ea00                	sd	s0,16(a2)
    fbf8:	ef00                	sd	s0,24(a4)
    fbfa:	b38d                	j	f95c <_malloc_r+0x140>
    fbfc:	4751                	li	a4,20
    fbfe:	0cf77663          	bgeu	a4,a5,fcca <_malloc_r+0x4ae>
    fc02:	05400713          	li	a4,84
    fc06:	18f76c63          	bltu	a4,a5,fd9e <_malloc_r+0x582>
    fc0a:	00c4d793          	srli	a5,s1,0xc
    fc0e:	06f7859b          	addiw	a1,a5,111 # fffffffffffff06f <__kernel_stack+0xfffffffffff1106f>
    fc12:	0015961b          	slliw	a2,a1,0x1
    fc16:	06e7881b          	addiw	a6,a5,110
    fc1a:	060e                	slli	a2,a2,0x3
    fc1c:	b175                	j	f8c8 <_malloc_r+0xac>
    fc1e:	2e05                	addiw	t3,t3,1
    fc20:	003e7793          	andi	a5,t3,3
    fc24:	0541                	addi	a0,a0,16
    fc26:	cfdd                	beqz	a5,fce4 <_malloc_r+0x4c8>
    fc28:	6d1c                	ld	a5,24(a0)
    fc2a:	bb8d                	j	f99c <_malloc_r+0x180>
    fc2c:	6810                	ld	a2,16(s0)
    fc2e:	0014e593          	ori	a1,s1,1
    fc32:	e40c                	sd	a1,8(s0)
    fc34:	ee1c                	sd	a5,24(a2)
    fc36:	eb90                	sd	a2,16(a5)
    fc38:	94a2                	add	s1,s1,s0
    fc3a:	0299b423          	sd	s1,40(s3)
    fc3e:	0299b023          	sd	s1,32(s3)
    fc42:	0016e793          	ori	a5,a3,1
    fc46:	9722                	add	a4,a4,s0
    fc48:	0114bc23          	sd	a7,24(s1)
    fc4c:	0114b823          	sd	a7,16(s1)
    fc50:	e49c                	sd	a5,8(s1)
    fc52:	854a                	mv	a0,s2
    fc54:	e314                	sd	a3,0(a4)
    fc56:	230000ef          	jal	fe86 <__malloc_unlock>
    fc5a:	01040513          	addi	a0,s0,16
    fc5e:	bbad                	j	f9d8 <_malloc_r+0x1bc>
    fc60:	97a2                	add	a5,a5,s0
    fc62:	6798                	ld	a4,8(a5)
    fc64:	854a                	mv	a0,s2
    fc66:	00176713          	ori	a4,a4,1
    fc6a:	e798                	sd	a4,8(a5)
    fc6c:	21a000ef          	jal	fe86 <__malloc_unlock>
    fc70:	01040513          	addi	a0,s0,16
    fc74:	b395                	j	f9d8 <_malloc_r+0x1bc>
    fc76:	0014e693          	ori	a3,s1,1
    fc7a:	e414                	sd	a3,8(s0)
    fc7c:	94a2                	add	s1,s1,s0
    fc7e:	0299b423          	sd	s1,40(s3)
    fc82:	0299b023          	sd	s1,32(s3)
    fc86:	00176693          	ori	a3,a4,1
    fc8a:	97a2                	add	a5,a5,s0
    fc8c:	0114bc23          	sd	a7,24(s1)
    fc90:	0114b823          	sd	a7,16(s1)
    fc94:	e494                	sd	a3,8(s1)
    fc96:	854a                	mv	a0,s2
    fc98:	e398                	sd	a4,0(a5)
    fc9a:	1ec000ef          	jal	fe86 <__malloc_unlock>
    fc9e:	01040513          	addi	a0,s0,16
    fca2:	bb1d                	j	f9d8 <_malloc_r+0x1bc>
    fca4:	0034d593          	srli	a1,s1,0x3
    fca8:	0015879b          	addiw	a5,a1,1
    fcac:	0017979b          	slliw	a5,a5,0x1
    fcb0:	078e                	slli	a5,a5,0x3
    fcb2:	2581                	sext.w	a1,a1
    fcb4:	be51                	j	f848 <_malloc_r+0x2c>
    fcb6:	0067d713          	srli	a4,a5,0x6
    fcba:	0397061b          	addiw	a2,a4,57
    fcbe:	0016161b          	slliw	a2,a2,0x1
    fcc2:	060e                	slli	a2,a2,0x3
    fcc4:	0387069b          	addiw	a3,a4,56
    fcc8:	b739                	j	fbd6 <_malloc_r+0x3ba>
    fcca:	05c7859b          	addiw	a1,a5,92
    fcce:	0015961b          	slliw	a2,a1,0x1
    fcd2:	05b7881b          	addiw	a6,a5,91
    fcd6:	060e                	slli	a2,a2,0x3
    fcd8:	bec5                	j	f8c8 <_malloc_r+0xac>
    fcda:	01033783          	ld	a5,16(t1)
    fcde:	35fd                	addiw	a1,a1,-1
    fce0:	18679a63          	bne	a5,t1,fe74 <_malloc_r+0x658>
    fce4:	0035f793          	andi	a5,a1,3
    fce8:	1341                	addi	t1,t1,-16
    fcea:	fbe5                	bnez	a5,fcda <_malloc_r+0x4be>
    fcec:	0089b703          	ld	a4,8(s3)
    fcf0:	fff64793          	not	a5,a2
    fcf4:	8ff9                	and	a5,a5,a4
    fcf6:	00f9b423          	sd	a5,8(s3)
    fcfa:	0606                	slli	a2,a2,0x1
    fcfc:	cec7ece3          	bltu	a5,a2,f9f4 <_malloc_r+0x1d8>
    fd00:	ce060ae3          	beqz	a2,f9f4 <_malloc_r+0x1d8>
    fd04:	00f67733          	and	a4,a2,a5
    fd08:	e711                	bnez	a4,fd14 <_malloc_r+0x4f8>
    fd0a:	0606                	slli	a2,a2,0x1
    fd0c:	00f67733          	and	a4,a2,a5
    fd10:	2e11                	addiw	t3,t3,4
    fd12:	df65                	beqz	a4,fd0a <_malloc_r+0x4ee>
    fd14:	85f2                	mv	a1,t3
    fd16:	b98d                	j	f988 <_malloc_r+0x16c>
    fd18:	01040593          	addi	a1,s0,16
    fd1c:	854a                	mv	a0,s2
    fd1e:	36a000ef          	jal	10088 <_free_r>
    fd22:	00031717          	auipc	a4,0x31
    fd26:	30e72703          	lw	a4,782(a4) # 41030 <__malloc_current_mallinfo>
    fd2a:	0109bb03          	ld	s6,16(s3)
    fd2e:	bbe1                	j	fb06 <_malloc_r+0x2ea>
    fd30:	020a0a13          	addi	s4,s4,32
    fd34:	b339                	j	fa42 <_malloc_r+0x226>
    fd36:	4026d69b          	sraiw	a3,a3,0x2
    fd3a:	4785                	li	a5,1
    fd3c:	00d797b3          	sll	a5,a5,a3
    fd40:	8d5d                	or	a0,a0,a5
    fd42:	00a9b423          	sd	a0,8(s3)
    fd46:	b575                	j	fbf2 <_malloc_r+0x3d6>
    fd48:	014b0bb3          	add	s7,s6,s4
    fd4c:	41700bb3          	neg	s7,s7
    fd50:	1bd2                	slli	s7,s7,0x34
    fd52:	034bdb93          	srli	s7,s7,0x34
    fd56:	85de                	mv	a1,s7
    fd58:	854a                	mv	a0,s2
    fd5a:	138000ef          	jal	fe92 <_sbrk_r>
    fd5e:	57fd                	li	a5,-1
    fd60:	4681                	li	a3,0
    fd62:	d4f51ce3          	bne	a0,a5,faba <_malloc_r+0x29e>
    fd66:	b385                	j	fac6 <_malloc_r+0x2aa>
    fd68:	6ca2                	ld	s9,8(sp)
    fd6a:	4785                	li	a5,1
    fd6c:	00fb3423          	sd	a5,8(s6)
    fd70:	854a                	mv	a0,s2
    fd72:	114000ef          	jal	fe86 <__malloc_unlock>
    fd76:	7a42                	ld	s4,48(sp)
    fd78:	7aa2                	ld	s5,40(sp)
    fd7a:	7b02                	ld	s6,32(sp)
    fd7c:	6be2                	ld	s7,24(sp)
    fd7e:	6c42                	ld	s8,16(sp)
    fd80:	b999                	j	f9d6 <_malloc_r+0x1ba>
    fd82:	05400693          	li	a3,84
    fd86:	06e6eb63          	bltu	a3,a4,fdfc <_malloc_r+0x5e0>
    fd8a:	00c7d713          	srli	a4,a5,0xc
    fd8e:	06f7061b          	addiw	a2,a4,111
    fd92:	0016161b          	slliw	a2,a2,0x1
    fd96:	060e                	slli	a2,a2,0x3
    fd98:	06e7069b          	addiw	a3,a4,110
    fd9c:	bd2d                	j	fbd6 <_malloc_r+0x3ba>
    fd9e:	15400713          	li	a4,340
    fda2:	06f76b63          	bltu	a4,a5,fe18 <_malloc_r+0x5fc>
    fda6:	00f4d793          	srli	a5,s1,0xf
    fdaa:	0787859b          	addiw	a1,a5,120
    fdae:	0015961b          	slliw	a2,a1,0x1
    fdb2:	0777881b          	addiw	a6,a5,119
    fdb6:	060e                	slli	a2,a2,0x3
    fdb8:	be01                	j	f8c8 <_malloc_r+0xac>
    fdba:	00031697          	auipc	a3,0x31
    fdbe:	2766a683          	lw	a3,630(a3) # 41030 <__malloc_current_mallinfo>
    fdc2:	00031c97          	auipc	s9,0x31
    fdc6:	26ec8c93          	addi	s9,s9,622 # 41030 <__malloc_current_mallinfo>
    fdca:	014686bb          	addw	a3,a3,s4
    fdce:	00dca023          	sw	a3,0(s9)
    fdd2:	b155                	j	fa76 <_malloc_r+0x25a>
    fdd4:	0109b403          	ld	s0,16(s3)
    fdd8:	641c                	ld	a5,8(s0)
    fdda:	b38d                	j	fb3c <_malloc_r+0x320>
    fddc:	03451793          	slli	a5,a0,0x34
    fde0:	c8079be3          	bnez	a5,fa76 <_malloc_r+0x25a>
    fde4:	0109bb03          	ld	s6,16(s3)
    fde8:	014a87b3          	add	a5,s5,s4
    fdec:	0017e793          	ori	a5,a5,1
    fdf0:	00fb3423          	sd	a5,8(s6)
    fdf4:	bb19                	j	fb0a <_malloc_r+0x2ee>
    fdf6:	016c3023          	sd	s6,0(s8)
    fdfa:	b941                	j	fa8a <_malloc_r+0x26e>
    fdfc:	15400693          	li	a3,340
    fe00:	04e6e063          	bltu	a3,a4,fe40 <_malloc_r+0x624>
    fe04:	00f7d713          	srli	a4,a5,0xf
    fe08:	0787061b          	addiw	a2,a4,120
    fe0c:	0016161b          	slliw	a2,a2,0x1
    fe10:	060e                	slli	a2,a2,0x3
    fe12:	0777069b          	addiw	a3,a4,119
    fe16:	b3c1                	j	fbd6 <_malloc_r+0x3ba>
    fe18:	55400713          	li	a4,1364
    fe1c:	04f76063          	bltu	a4,a5,fe5c <_malloc_r+0x640>
    fe20:	0124d793          	srli	a5,s1,0x12
    fe24:	07d7859b          	addiw	a1,a5,125
    fe28:	0015961b          	slliw	a2,a1,0x1
    fe2c:	07c7881b          	addiw	a6,a5,124
    fe30:	060e                	slli	a2,a2,0x3
    fe32:	bc59                	j	f8c8 <_malloc_r+0xac>
    fe34:	1c41                	addi	s8,s8,-16
    fe36:	9a62                	add	s4,s4,s8
    fe38:	416a0a33          	sub	s4,s4,s6
    fe3c:	4681                	li	a3,0
    fe3e:	b161                	j	fac6 <_malloc_r+0x2aa>
    fe40:	55400693          	li	a3,1364
    fe44:	02e6e363          	bltu	a3,a4,fe6a <_malloc_r+0x64e>
    fe48:	0127d713          	srli	a4,a5,0x12
    fe4c:	07d7061b          	addiw	a2,a4,125
    fe50:	0016161b          	slliw	a2,a2,0x1
    fe54:	060e                	slli	a2,a2,0x3
    fe56:	07c7069b          	addiw	a3,a4,124
    fe5a:	bbb5                	j	fbd6 <_malloc_r+0x3ba>
    fe5c:	7f000613          	li	a2,2032
    fe60:	07f00593          	li	a1,127
    fe64:	07e00813          	li	a6,126
    fe68:	b485                	j	f8c8 <_malloc_r+0xac>
    fe6a:	7f000613          	li	a2,2032
    fe6e:	07e00693          	li	a3,126
    fe72:	b395                	j	fbd6 <_malloc_r+0x3ba>
    fe74:	0089b783          	ld	a5,8(s3)
    fe78:	b549                	j	fcfa <_malloc_r+0x4de>

000000000000fe7a <__malloc_lock>:
    fe7a:	00031517          	auipc	a0,0x31
    fe7e:	21650513          	addi	a0,a0,534 # 41090 <__lock___malloc_recursive_mutex>
    fe82:	45a0006f          	j	102dc <__retarget_lock_acquire_recursive>

000000000000fe86 <__malloc_unlock>:
    fe86:	00031517          	auipc	a0,0x31
    fe8a:	20a50513          	addi	a0,a0,522 # 41090 <__lock___malloc_recursive_mutex>
    fe8e:	45a0006f          	j	102e8 <__retarget_lock_release_recursive>

000000000000fe92 <_sbrk_r>:
    fe92:	1141                	addi	sp,sp,-16
    fe94:	e022                	sd	s0,0(sp)
    fe96:	842a                	mv	s0,a0
    fe98:	852e                	mv	a0,a1
    fe9a:	00031797          	auipc	a5,0x31
    fe9e:	2007ad23          	sw	zero,538(a5) # 410b4 <errno>
    fea2:	e406                	sd	ra,8(sp)
    fea4:	61a000ef          	jal	104be <_sbrk>
    fea8:	57fd                	li	a5,-1
    feaa:	00f50663          	beq	a0,a5,feb6 <_sbrk_r+0x24>
    feae:	60a2                	ld	ra,8(sp)
    feb0:	6402                	ld	s0,0(sp)
    feb2:	0141                	addi	sp,sp,16
    feb4:	8082                	ret
    feb6:	00031797          	auipc	a5,0x31
    feba:	1fe7a783          	lw	a5,510(a5) # 410b4 <errno>
    febe:	dbe5                	beqz	a5,feae <_sbrk_r+0x1c>
    fec0:	60a2                	ld	ra,8(sp)
    fec2:	c01c                	sw	a5,0(s0)
    fec4:	6402                	ld	s0,0(sp)
    fec6:	0141                	addi	sp,sp,16
    fec8:	8082                	ret

000000000000feca <strdup>:
    feca:	85aa                	mv	a1,a0
    fecc:	00031517          	auipc	a0,0x31
    fed0:	0e453503          	ld	a0,228(a0) # 40fb0 <_impure_ptr>
    fed4:	a009                	j	fed6 <_strdup_r>

000000000000fed6 <_strdup_r>:
    fed6:	1101                	addi	sp,sp,-32
    fed8:	e822                	sd	s0,16(sp)
    feda:	842a                	mv	s0,a0
    fedc:	852e                	mv	a0,a1
    fede:	ec06                	sd	ra,24(sp)
    fee0:	e426                	sd	s1,8(sp)
    fee2:	e04a                	sd	s2,0(sp)
    fee4:	84ae                	mv	s1,a1
    fee6:	02a000ef          	jal	ff10 <strlen>
    feea:	00150913          	addi	s2,a0,1
    feee:	85ca                	mv	a1,s2
    fef0:	8522                	mv	a0,s0
    fef2:	92bff0ef          	jal	f81c <_malloc_r>
    fef6:	842a                	mv	s0,a0
    fef8:	c509                	beqz	a0,ff02 <_strdup_r+0x2c>
    fefa:	864a                	mv	a2,s2
    fefc:	85a6                	mv	a1,s1
    fefe:	3ee000ef          	jal	102ec <memcpy>
    ff02:	60e2                	ld	ra,24(sp)
    ff04:	8522                	mv	a0,s0
    ff06:	6442                	ld	s0,16(sp)
    ff08:	64a2                	ld	s1,8(sp)
    ff0a:	6902                	ld	s2,0(sp)
    ff0c:	6105                	addi	sp,sp,32
    ff0e:	8082                	ret

000000000000ff10 <strlen>:
    ff10:	00757793          	andi	a5,a0,7
    ff14:	872a                	mv	a4,a0
    ff16:	efb1                	bnez	a5,ff72 <strlen+0x62>
    ff18:	7f7f87b7          	lui	a5,0x7f7f8
    ff1c:	f7f78793          	addi	a5,a5,-129 # 7f7f7f7f <__kernel_stack+0x7f709f7f>
    ff20:	02079693          	slli	a3,a5,0x20
    ff24:	96be                	add	a3,a3,a5
    ff26:	55fd                	li	a1,-1
    ff28:	6310                	ld	a2,0(a4)
    ff2a:	0721                	addi	a4,a4,8
    ff2c:	00d677b3          	and	a5,a2,a3
    ff30:	97b6                	add	a5,a5,a3
    ff32:	8fd1                	or	a5,a5,a2
    ff34:	8fd5                	or	a5,a5,a3
    ff36:	feb789e3          	beq	a5,a1,ff28 <strlen+0x18>
    ff3a:	ff874683          	lbu	a3,-8(a4)
    ff3e:	40a707b3          	sub	a5,a4,a0
    ff42:	c6a9                	beqz	a3,ff8c <strlen+0x7c>
    ff44:	ff974683          	lbu	a3,-7(a4)
    ff48:	ce9d                	beqz	a3,ff86 <strlen+0x76>
    ff4a:	ffa74683          	lbu	a3,-6(a4)
    ff4e:	c6a9                	beqz	a3,ff98 <strlen+0x88>
    ff50:	ffb74683          	lbu	a3,-5(a4)
    ff54:	ce9d                	beqz	a3,ff92 <strlen+0x82>
    ff56:	ffc74683          	lbu	a3,-4(a4)
    ff5a:	c2b1                	beqz	a3,ff9e <strlen+0x8e>
    ff5c:	ffd74683          	lbu	a3,-3(a4)
    ff60:	c2b1                	beqz	a3,ffa4 <strlen+0x94>
    ff62:	ffe74503          	lbu	a0,-2(a4)
    ff66:	00a03533          	snez	a0,a0
    ff6a:	953e                	add	a0,a0,a5
    ff6c:	1579                	addi	a0,a0,-2
    ff6e:	8082                	ret
    ff70:	d6c5                	beqz	a3,ff18 <strlen+0x8>
    ff72:	00074783          	lbu	a5,0(a4)
    ff76:	0705                	addi	a4,a4,1
    ff78:	00777693          	andi	a3,a4,7
    ff7c:	fbf5                	bnez	a5,ff70 <strlen+0x60>
    ff7e:	8f09                	sub	a4,a4,a0
    ff80:	fff70513          	addi	a0,a4,-1
    ff84:	8082                	ret
    ff86:	ff978513          	addi	a0,a5,-7
    ff8a:	8082                	ret
    ff8c:	ff878513          	addi	a0,a5,-8
    ff90:	8082                	ret
    ff92:	ffb78513          	addi	a0,a5,-5
    ff96:	8082                	ret
    ff98:	ffa78513          	addi	a0,a5,-6
    ff9c:	8082                	ret
    ff9e:	ffc78513          	addi	a0,a5,-4
    ffa2:	8082                	ret
    ffa4:	ffd78513          	addi	a0,a5,-3
    ffa8:	8082                	ret

000000000000ffaa <_malloc_trim_r>:
    ffaa:	7179                	addi	sp,sp,-48
    ffac:	f022                	sd	s0,32(sp)
    ffae:	ec26                	sd	s1,24(sp)
    ffb0:	e84a                	sd	s2,16(sp)
    ffb2:	e44e                	sd	s3,8(sp)
    ffb4:	e052                	sd	s4,0(sp)
    ffb6:	89ae                	mv	s3,a1
    ffb8:	f406                	sd	ra,40(sp)
    ffba:	892a                	mv	s2,a0
    ffbc:	00030a17          	auipc	s4,0x30
    ffc0:	074a0a13          	addi	s4,s4,116 # 40030 <__malloc_av_>
    ffc4:	eb7ff0ef          	jal	fe7a <__malloc_lock>
    ffc8:	010a3783          	ld	a5,16(s4)
    ffcc:	6405                	lui	s0,0x1
    ffce:	fdf40413          	addi	s0,s0,-33 # fdf <core_bench_list+0x67f>
    ffd2:	6784                	ld	s1,8(a5)
    ffd4:	6785                	lui	a5,0x1
    ffd6:	98f1                	andi	s1,s1,-4
    ffd8:	9426                	add	s0,s0,s1
    ffda:	41340433          	sub	s0,s0,s3
    ffde:	8031                	srli	s0,s0,0xc
    ffe0:	147d                	addi	s0,s0,-1
    ffe2:	0432                	slli	s0,s0,0xc
    ffe4:	00f44b63          	blt	s0,a5,fffa <_malloc_trim_r+0x50>
    ffe8:	4581                	li	a1,0
    ffea:	854a                	mv	a0,s2
    ffec:	ea7ff0ef          	jal	fe92 <_sbrk_r>
    fff0:	010a3783          	ld	a5,16(s4)
    fff4:	97a6                	add	a5,a5,s1
    fff6:	00f50e63          	beq	a0,a5,10012 <_malloc_trim_r+0x68>
    fffa:	854a                	mv	a0,s2
    fffc:	e8bff0ef          	jal	fe86 <__malloc_unlock>
   10000:	70a2                	ld	ra,40(sp)
   10002:	7402                	ld	s0,32(sp)
   10004:	64e2                	ld	s1,24(sp)
   10006:	6942                	ld	s2,16(sp)
   10008:	69a2                	ld	s3,8(sp)
   1000a:	6a02                	ld	s4,0(sp)
   1000c:	4501                	li	a0,0
   1000e:	6145                	addi	sp,sp,48
   10010:	8082                	ret
   10012:	408005b3          	neg	a1,s0
   10016:	854a                	mv	a0,s2
   10018:	e7bff0ef          	jal	fe92 <_sbrk_r>
   1001c:	57fd                	li	a5,-1
   1001e:	02f50d63          	beq	a0,a5,10058 <_malloc_trim_r+0xae>
   10022:	010a3703          	ld	a4,16(s4)
   10026:	00031797          	auipc	a5,0x31
   1002a:	00a7a783          	lw	a5,10(a5) # 41030 <__malloc_current_mallinfo>
   1002e:	8c81                	sub	s1,s1,s0
   10030:	0014e493          	ori	s1,s1,1
   10034:	e704                	sd	s1,8(a4)
   10036:	854a                	mv	a0,s2
   10038:	9f81                	subw	a5,a5,s0
   1003a:	00031717          	auipc	a4,0x31
   1003e:	fef72b23          	sw	a5,-10(a4) # 41030 <__malloc_current_mallinfo>
   10042:	e45ff0ef          	jal	fe86 <__malloc_unlock>
   10046:	70a2                	ld	ra,40(sp)
   10048:	7402                	ld	s0,32(sp)
   1004a:	64e2                	ld	s1,24(sp)
   1004c:	6942                	ld	s2,16(sp)
   1004e:	69a2                	ld	s3,8(sp)
   10050:	6a02                	ld	s4,0(sp)
   10052:	4505                	li	a0,1
   10054:	6145                	addi	sp,sp,48
   10056:	8082                	ret
   10058:	4581                	li	a1,0
   1005a:	854a                	mv	a0,s2
   1005c:	e37ff0ef          	jal	fe92 <_sbrk_r>
   10060:	010a3703          	ld	a4,16(s4)
   10064:	46fd                	li	a3,31
   10066:	40e507b3          	sub	a5,a0,a4
   1006a:	f8f6d8e3          	bge	a3,a5,fffa <_malloc_trim_r+0x50>
   1006e:	00031697          	auipc	a3,0x31
   10072:	f326b683          	ld	a3,-206(a3) # 40fa0 <__malloc_sbrk_base>
   10076:	0017e793          	ori	a5,a5,1
   1007a:	e71c                	sd	a5,8(a4)
   1007c:	8d15                	sub	a0,a0,a3
   1007e:	00031797          	auipc	a5,0x31
   10082:	faa7a923          	sw	a0,-78(a5) # 41030 <__malloc_current_mallinfo>
   10086:	bf95                	j	fffa <_malloc_trim_r+0x50>

0000000000010088 <_free_r>:
   10088:	c1fd                	beqz	a1,1016e <_free_r+0xe6>
   1008a:	1101                	addi	sp,sp,-32
   1008c:	e822                	sd	s0,16(sp)
   1008e:	e426                	sd	s1,8(sp)
   10090:	842e                	mv	s0,a1
   10092:	84aa                	mv	s1,a0
   10094:	ec06                	sd	ra,24(sp)
   10096:	de5ff0ef          	jal	fe7a <__malloc_lock>
   1009a:	ff843583          	ld	a1,-8(s0)
   1009e:	ff040713          	addi	a4,s0,-16
   100a2:	00030817          	auipc	a6,0x30
   100a6:	f8e80813          	addi	a6,a6,-114 # 40030 <__malloc_av_>
   100aa:	ffe5f793          	andi	a5,a1,-2
   100ae:	00f70633          	add	a2,a4,a5
   100b2:	6614                	ld	a3,8(a2)
   100b4:	01083503          	ld	a0,16(a6)
   100b8:	0015f893          	andi	a7,a1,1
   100bc:	9af1                	andi	a3,a3,-4
   100be:	12c50563          	beq	a0,a2,101e8 <_free_r+0x160>
   100c2:	e614                	sd	a3,8(a2)
   100c4:	00d60533          	add	a0,a2,a3
   100c8:	6508                	ld	a0,8(a0)
   100ca:	8905                	andi	a0,a0,1
   100cc:	06089e63          	bnez	a7,10148 <_free_r+0xc0>
   100d0:	ff043303          	ld	t1,-16(s0)
   100d4:	00030897          	auipc	a7,0x30
   100d8:	f6c88893          	addi	a7,a7,-148 # 40040 <__malloc_av_+0x10>
   100dc:	40670733          	sub	a4,a4,t1
   100e0:	6b0c                	ld	a1,16(a4)
   100e2:	979a                	add	a5,a5,t1
   100e4:	0f158663          	beq	a1,a7,101d0 <_free_r+0x148>
   100e8:	01873303          	ld	t1,24(a4)
   100ec:	0065bc23          	sd	t1,24(a1)
   100f0:	00b33823          	sd	a1,16(t1)
   100f4:	12050863          	beqz	a0,10224 <_free_r+0x19c>
   100f8:	0017e693          	ori	a3,a5,1
   100fc:	e714                	sd	a3,8(a4)
   100fe:	e21c                	sd	a5,0(a2)
   10100:	1ff00693          	li	a3,511
   10104:	06f6ef63          	bltu	a3,a5,10182 <_free_r+0xfa>
   10108:	838d                	srli	a5,a5,0x3
   1010a:	2781                	sext.w	a5,a5
   1010c:	0017869b          	addiw	a3,a5,1
   10110:	0016969b          	slliw	a3,a3,0x1
   10114:	068e                	slli	a3,a3,0x3
   10116:	00883503          	ld	a0,8(a6)
   1011a:	96c2                	add	a3,a3,a6
   1011c:	628c                	ld	a1,0(a3)
   1011e:	4605                	li	a2,1
   10120:	4027d79b          	sraiw	a5,a5,0x2
   10124:	00f617b3          	sll	a5,a2,a5
   10128:	8fc9                	or	a5,a5,a0
   1012a:	ff068613          	addi	a2,a3,-16
   1012e:	eb0c                	sd	a1,16(a4)
   10130:	ef10                	sd	a2,24(a4)
   10132:	00f83423          	sd	a5,8(a6)
   10136:	e298                	sd	a4,0(a3)
   10138:	ed98                	sd	a4,24(a1)
   1013a:	6442                	ld	s0,16(sp)
   1013c:	60e2                	ld	ra,24(sp)
   1013e:	8526                	mv	a0,s1
   10140:	64a2                	ld	s1,8(sp)
   10142:	6105                	addi	sp,sp,32
   10144:	d43ff06f          	j	fe86 <__malloc_unlock>
   10148:	e505                	bnez	a0,10170 <_free_r+0xe8>
   1014a:	97b6                	add	a5,a5,a3
   1014c:	00030897          	auipc	a7,0x30
   10150:	ef488893          	addi	a7,a7,-268 # 40040 <__malloc_av_+0x10>
   10154:	6a14                	ld	a3,16(a2)
   10156:	0017e513          	ori	a0,a5,1
   1015a:	00f705b3          	add	a1,a4,a5
   1015e:	11168363          	beq	a3,a7,10264 <_free_r+0x1dc>
   10162:	6e10                	ld	a2,24(a2)
   10164:	ee90                	sd	a2,24(a3)
   10166:	ea14                	sd	a3,16(a2)
   10168:	e708                	sd	a0,8(a4)
   1016a:	e19c                	sd	a5,0(a1)
   1016c:	bf51                	j	10100 <_free_r+0x78>
   1016e:	8082                	ret
   10170:	0015e593          	ori	a1,a1,1
   10174:	feb43c23          	sd	a1,-8(s0)
   10178:	e21c                	sd	a5,0(a2)
   1017a:	1ff00693          	li	a3,511
   1017e:	f8f6f5e3          	bgeu	a3,a5,10108 <_free_r+0x80>
   10182:	0097d693          	srli	a3,a5,0x9
   10186:	4611                	li	a2,4
   10188:	0ad66063          	bltu	a2,a3,10228 <_free_r+0x1a0>
   1018c:	0067d693          	srli	a3,a5,0x6
   10190:	0396859b          	addiw	a1,a3,57
   10194:	0015959b          	slliw	a1,a1,0x1
   10198:	058e                	slli	a1,a1,0x3
   1019a:	0386861b          	addiw	a2,a3,56
   1019e:	95c2                	add	a1,a1,a6
   101a0:	6194                	ld	a3,0(a1)
   101a2:	15c1                	addi	a1,a1,-16
   101a4:	00d59663          	bne	a1,a3,101b0 <_free_r+0x128>
   101a8:	a8c9                	j	1027a <_free_r+0x1f2>
   101aa:	6a94                	ld	a3,16(a3)
   101ac:	00d58663          	beq	a1,a3,101b8 <_free_r+0x130>
   101b0:	6690                	ld	a2,8(a3)
   101b2:	9a71                	andi	a2,a2,-4
   101b4:	fec7ebe3          	bltu	a5,a2,101aa <_free_r+0x122>
   101b8:	6e8c                	ld	a1,24(a3)
   101ba:	ef0c                	sd	a1,24(a4)
   101bc:	eb14                	sd	a3,16(a4)
   101be:	6442                	ld	s0,16(sp)
   101c0:	60e2                	ld	ra,24(sp)
   101c2:	e998                	sd	a4,16(a1)
   101c4:	8526                	mv	a0,s1
   101c6:	64a2                	ld	s1,8(sp)
   101c8:	ee98                	sd	a4,24(a3)
   101ca:	6105                	addi	sp,sp,32
   101cc:	cbbff06f          	j	fe86 <__malloc_unlock>
   101d0:	ed2d                	bnez	a0,1024a <_free_r+0x1c2>
   101d2:	6e0c                	ld	a1,24(a2)
   101d4:	6a10                	ld	a2,16(a2)
   101d6:	96be                	add	a3,a3,a5
   101d8:	0016e793          	ori	a5,a3,1
   101dc:	ee0c                	sd	a1,24(a2)
   101de:	e990                	sd	a2,16(a1)
   101e0:	e71c                	sd	a5,8(a4)
   101e2:	9736                	add	a4,a4,a3
   101e4:	e314                	sd	a3,0(a4)
   101e6:	bf91                	j	1013a <_free_r+0xb2>
   101e8:	96be                	add	a3,a3,a5
   101ea:	00089a63          	bnez	a7,101fe <_free_r+0x176>
   101ee:	ff043583          	ld	a1,-16(s0)
   101f2:	8f0d                	sub	a4,a4,a1
   101f4:	6f1c                	ld	a5,24(a4)
   101f6:	6b10                	ld	a2,16(a4)
   101f8:	96ae                	add	a3,a3,a1
   101fa:	ee1c                	sd	a5,24(a2)
   101fc:	eb90                	sd	a2,16(a5)
   101fe:	0016e613          	ori	a2,a3,1
   10202:	00031797          	auipc	a5,0x31
   10206:	da67b783          	ld	a5,-602(a5) # 40fa8 <__malloc_trim_threshold>
   1020a:	e710                	sd	a2,8(a4)
   1020c:	00e83823          	sd	a4,16(a6)
   10210:	f2f6e5e3          	bltu	a3,a5,1013a <_free_r+0xb2>
   10214:	00031597          	auipc	a1,0x31
   10218:	e545b583          	ld	a1,-428(a1) # 41068 <__malloc_top_pad>
   1021c:	8526                	mv	a0,s1
   1021e:	d8dff0ef          	jal	ffaa <_malloc_trim_r>
   10222:	bf21                	j	1013a <_free_r+0xb2>
   10224:	97b6                	add	a5,a5,a3
   10226:	b73d                	j	10154 <_free_r+0xcc>
   10228:	4651                	li	a2,20
   1022a:	02d67563          	bgeu	a2,a3,10254 <_free_r+0x1cc>
   1022e:	05400613          	li	a2,84
   10232:	04d66f63          	bltu	a2,a3,10290 <_free_r+0x208>
   10236:	00c7d693          	srli	a3,a5,0xc
   1023a:	06f6859b          	addiw	a1,a3,111
   1023e:	0015959b          	slliw	a1,a1,0x1
   10242:	058e                	slli	a1,a1,0x3
   10244:	06e6861b          	addiw	a2,a3,110
   10248:	bf99                	j	1019e <_free_r+0x116>
   1024a:	0017e693          	ori	a3,a5,1
   1024e:	e714                	sd	a3,8(a4)
   10250:	e21c                	sd	a5,0(a2)
   10252:	b5e5                	j	1013a <_free_r+0xb2>
   10254:	05c6859b          	addiw	a1,a3,92
   10258:	0015959b          	slliw	a1,a1,0x1
   1025c:	058e                	slli	a1,a1,0x3
   1025e:	05b6861b          	addiw	a2,a3,91
   10262:	bf35                	j	1019e <_free_r+0x116>
   10264:	02e83423          	sd	a4,40(a6)
   10268:	02e83023          	sd	a4,32(a6)
   1026c:	01173c23          	sd	a7,24(a4)
   10270:	01173823          	sd	a7,16(a4)
   10274:	e708                	sd	a0,8(a4)
   10276:	e19c                	sd	a5,0(a1)
   10278:	b5c9                	j	1013a <_free_r+0xb2>
   1027a:	00883503          	ld	a0,8(a6)
   1027e:	4026561b          	sraiw	a2,a2,0x2
   10282:	4785                	li	a5,1
   10284:	00c797b3          	sll	a5,a5,a2
   10288:	8fc9                	or	a5,a5,a0
   1028a:	00f83423          	sd	a5,8(a6)
   1028e:	b735                	j	101ba <_free_r+0x132>
   10290:	15400613          	li	a2,340
   10294:	00d66c63          	bltu	a2,a3,102ac <_free_r+0x224>
   10298:	00f7d693          	srli	a3,a5,0xf
   1029c:	0786859b          	addiw	a1,a3,120
   102a0:	0015959b          	slliw	a1,a1,0x1
   102a4:	058e                	slli	a1,a1,0x3
   102a6:	0776861b          	addiw	a2,a3,119
   102aa:	bdd5                	j	1019e <_free_r+0x116>
   102ac:	55400613          	li	a2,1364
   102b0:	00d66c63          	bltu	a2,a3,102c8 <_free_r+0x240>
   102b4:	0127d693          	srli	a3,a5,0x12
   102b8:	07d6859b          	addiw	a1,a3,125
   102bc:	0015959b          	slliw	a1,a1,0x1
   102c0:	058e                	slli	a1,a1,0x3
   102c2:	07c6861b          	addiw	a2,a3,124
   102c6:	bde1                	j	1019e <_free_r+0x116>
   102c8:	7f000593          	li	a1,2032
   102cc:	07e00613          	li	a2,126
   102d0:	b5f9                	j	1019e <_free_r+0x116>

00000000000102d2 <__retarget_lock_init>:
   102d2:	8082                	ret

00000000000102d4 <__retarget_lock_init_recursive>:
   102d4:	8082                	ret

00000000000102d6 <__retarget_lock_close>:
   102d6:	8082                	ret

00000000000102d8 <__retarget_lock_close_recursive>:
   102d8:	8082                	ret

00000000000102da <__retarget_lock_acquire>:
   102da:	8082                	ret

00000000000102dc <__retarget_lock_acquire_recursive>:
   102dc:	8082                	ret

00000000000102de <__retarget_lock_try_acquire>:
   102de:	4505                	li	a0,1
   102e0:	8082                	ret

00000000000102e2 <__retarget_lock_try_acquire_recursive>:
   102e2:	4505                	li	a0,1
   102e4:	8082                	ret

00000000000102e6 <__retarget_lock_release>:
   102e6:	8082                	ret

00000000000102e8 <__retarget_lock_release_recursive>:
   102e8:	8082                	ret
	...

00000000000102ec <memcpy>:
   102ec:	00863693          	sltiu	a3,a2,8
   102f0:	82aa                	mv	t0,a0
   102f2:	00c50333          	add	t1,a0,a2
   102f6:	eeb5                	bnez	a3,10372 <memcpy+0x86>
   102f8:	00b546b3          	xor	a3,a0,a1
   102fc:	8a9d                	andi	a3,a3,7
   102fe:	eab5                	bnez	a3,10372 <memcpy+0x86>
   10300:	00757693          	andi	a3,a0,7
   10304:	43a1                	li	t2,8
   10306:	e2c9                	bnez	a3,10388 <memcpy+0x9c>
   10308:	ff837393          	andi	t2,t1,-8
   1030c:	fc038313          	addi	t1,t2,-64
   10310:	04a36263          	bltu	t1,a0,10354 <memcpy+0x68>
   10314:	03f67613          	andi	a2,a2,63
   10318:	6198                	ld	a4,0(a1)
   1031a:	e118                	sd	a4,0(a0)
   1031c:	659c                	ld	a5,8(a1)
   1031e:	e51c                	sd	a5,8(a0)
   10320:	0105b803          	ld	a6,16(a1)
   10324:	01053823          	sd	a6,16(a0)
   10328:	0185b883          	ld	a7,24(a1)
   1032c:	01153c23          	sd	a7,24(a0)
   10330:	7198                	ld	a4,32(a1)
   10332:	f118                	sd	a4,32(a0)
   10334:	759c                	ld	a5,40(a1)
   10336:	f51c                	sd	a5,40(a0)
   10338:	0305b803          	ld	a6,48(a1)
   1033c:	03053823          	sd	a6,48(a0)
   10340:	0385b883          	ld	a7,56(a1)
   10344:	04058593          	addi	a1,a1,64
   10348:	03153c23          	sd	a7,56(a0)
   1034c:	04050513          	addi	a0,a0,64
   10350:	fca374e3          	bgeu	t1,a0,10318 <memcpy+0x2c>
   10354:	ff837393          	andi	t2,t1,-8
   10358:	ff838313          	addi	t1,t2,-8
   1035c:	00a36963          	bltu	t1,a0,1036e <memcpy+0x82>
   10360:	8a0d                	andi	a2,a2,3
   10362:	4198                	lw	a4,0(a1)
   10364:	0591                	addi	a1,a1,4
   10366:	c118                	sw	a4,0(a0)
   10368:	0511                	addi	a0,a0,4
   1036a:	fea37ce3          	bgeu	t1,a0,10362 <memcpy+0x76>
   1036e:	00c50333          	add	t1,a0,a2
   10372:	ca09                	beqz	a2,10384 <memcpy+0x98>
   10374:	00058703          	lb	a4,0(a1)
   10378:	0585                	addi	a1,a1,1
   1037a:	00e50023          	sb	a4,0(a0)
   1037e:	0505                	addi	a0,a0,1
   10380:	fe656ae3          	bltu	a0,t1,10374 <memcpy+0x88>
   10384:	8516                	mv	a0,t0
   10386:	8082                	ret
   10388:	40d386b3          	sub	a3,t2,a3
   1038c:	83b6                	mv	t2,a3
   1038e:	00058703          	lb	a4,0(a1)
   10392:	0585                	addi	a1,a1,1
   10394:	16fd                	addi	a3,a3,-1
   10396:	00e50023          	sb	a4,0(a0)
   1039a:	0505                	addi	a0,a0,1
   1039c:	faed                	bnez	a3,1038e <memcpy+0xa2>
   1039e:	40760633          	sub	a2,a2,t2
   103a2:	00263693          	sltiu	a3,a2,2
   103a6:	f6f1                	bnez	a3,10372 <memcpy+0x86>
   103a8:	b785                	j	10308 <memcpy+0x1c>

00000000000103aa <cleanup_glue>:
   103aa:	7179                	addi	sp,sp,-48
   103ac:	e84a                	sd	s2,16(sp)
   103ae:	0005b903          	ld	s2,0(a1)
   103b2:	f022                	sd	s0,32(sp)
   103b4:	ec26                	sd	s1,24(sp)
   103b6:	f406                	sd	ra,40(sp)
   103b8:	842e                	mv	s0,a1
   103ba:	84aa                	mv	s1,a0
   103bc:	02090f63          	beqz	s2,103fa <cleanup_glue+0x50>
   103c0:	e44e                	sd	s3,8(sp)
   103c2:	00093983          	ld	s3,0(s2)
   103c6:	02098563          	beqz	s3,103f0 <cleanup_glue+0x46>
   103ca:	e052                	sd	s4,0(sp)
   103cc:	0009ba03          	ld	s4,0(s3)
   103d0:	000a0b63          	beqz	s4,103e6 <cleanup_glue+0x3c>
   103d4:	000a3583          	ld	a1,0(s4)
   103d8:	c199                	beqz	a1,103de <cleanup_glue+0x34>
   103da:	fd1ff0ef          	jal	103aa <cleanup_glue>
   103de:	85d2                	mv	a1,s4
   103e0:	8526                	mv	a0,s1
   103e2:	ca7ff0ef          	jal	10088 <_free_r>
   103e6:	85ce                	mv	a1,s3
   103e8:	8526                	mv	a0,s1
   103ea:	c9fff0ef          	jal	10088 <_free_r>
   103ee:	6a02                	ld	s4,0(sp)
   103f0:	85ca                	mv	a1,s2
   103f2:	8526                	mv	a0,s1
   103f4:	c95ff0ef          	jal	10088 <_free_r>
   103f8:	69a2                	ld	s3,8(sp)
   103fa:	85a2                	mv	a1,s0
   103fc:	7402                	ld	s0,32(sp)
   103fe:	70a2                	ld	ra,40(sp)
   10400:	6942                	ld	s2,16(sp)
   10402:	8526                	mv	a0,s1
   10404:	64e2                	ld	s1,24(sp)
   10406:	6145                	addi	sp,sp,48
   10408:	c81ff06f          	j	10088 <_free_r>

000000000001040c <_reclaim_reent>:
   1040c:	00031797          	auipc	a5,0x31
   10410:	ba47b783          	ld	a5,-1116(a5) # 40fb0 <_impure_ptr>
   10414:	0aa78463          	beq	a5,a0,104bc <_reclaim_reent+0xb0>
   10418:	7d2c                	ld	a1,120(a0)
   1041a:	7179                	addi	sp,sp,-48
   1041c:	ec26                	sd	s1,24(sp)
   1041e:	f406                	sd	ra,40(sp)
   10420:	f022                	sd	s0,32(sp)
   10422:	e84a                	sd	s2,16(sp)
   10424:	84aa                	mv	s1,a0
   10426:	c59d                	beqz	a1,10454 <_reclaim_reent+0x48>
   10428:	e44e                	sd	s3,8(sp)
   1042a:	4901                	li	s2,0
   1042c:	20000993          	li	s3,512
   10430:	012587b3          	add	a5,a1,s2
   10434:	6380                	ld	s0,0(a5)
   10436:	c801                	beqz	s0,10446 <_reclaim_reent+0x3a>
   10438:	85a2                	mv	a1,s0
   1043a:	6000                	ld	s0,0(s0)
   1043c:	8526                	mv	a0,s1
   1043e:	c4bff0ef          	jal	10088 <_free_r>
   10442:	f87d                	bnez	s0,10438 <_reclaim_reent+0x2c>
   10444:	7cac                	ld	a1,120(s1)
   10446:	0921                	addi	s2,s2,8
   10448:	ff3914e3          	bne	s2,s3,10430 <_reclaim_reent+0x24>
   1044c:	8526                	mv	a0,s1
   1044e:	c3bff0ef          	jal	10088 <_free_r>
   10452:	69a2                	ld	s3,8(sp)
   10454:	70ac                	ld	a1,96(s1)
   10456:	c581                	beqz	a1,1045e <_reclaim_reent+0x52>
   10458:	8526                	mv	a0,s1
   1045a:	c2fff0ef          	jal	10088 <_free_r>
   1045e:	1f84b403          	ld	s0,504(s1)
   10462:	cc01                	beqz	s0,1047a <_reclaim_reent+0x6e>
   10464:	20048913          	addi	s2,s1,512
   10468:	01240963          	beq	s0,s2,1047a <_reclaim_reent+0x6e>
   1046c:	85a2                	mv	a1,s0
   1046e:	6000                	ld	s0,0(s0)
   10470:	8526                	mv	a0,s1
   10472:	c17ff0ef          	jal	10088 <_free_r>
   10476:	fe891be3          	bne	s2,s0,1046c <_reclaim_reent+0x60>
   1047a:	64cc                	ld	a1,136(s1)
   1047c:	c581                	beqz	a1,10484 <_reclaim_reent+0x78>
   1047e:	8526                	mv	a0,s1
   10480:	c09ff0ef          	jal	10088 <_free_r>
   10484:	48bc                	lw	a5,80(s1)
   10486:	c78d                	beqz	a5,104b0 <_reclaim_reent+0xa4>
   10488:	6cbc                	ld	a5,88(s1)
   1048a:	8526                	mv	a0,s1
   1048c:	9782                	jalr	a5
   1048e:	5204b403          	ld	s0,1312(s1)
   10492:	cc19                	beqz	s0,104b0 <_reclaim_reent+0xa4>
   10494:	600c                	ld	a1,0(s0)
   10496:	c581                	beqz	a1,1049e <_reclaim_reent+0x92>
   10498:	8526                	mv	a0,s1
   1049a:	f11ff0ef          	jal	103aa <cleanup_glue>
   1049e:	85a2                	mv	a1,s0
   104a0:	7402                	ld	s0,32(sp)
   104a2:	70a2                	ld	ra,40(sp)
   104a4:	6942                	ld	s2,16(sp)
   104a6:	8526                	mv	a0,s1
   104a8:	64e2                	ld	s1,24(sp)
   104aa:	6145                	addi	sp,sp,48
   104ac:	bddff06f          	j	10088 <_free_r>
   104b0:	70a2                	ld	ra,40(sp)
   104b2:	7402                	ld	s0,32(sp)
   104b4:	64e2                	ld	s1,24(sp)
   104b6:	6942                	ld	s2,16(sp)
   104b8:	6145                	addi	sp,sp,48
   104ba:	8082                	ret
   104bc:	8082                	ret

00000000000104be <_sbrk>:
   104be:	00031317          	auipc	t1,0x31
   104c2:	bfa30313          	addi	t1,t1,-1030 # 410b8 <heap_end.0>
   104c6:	00033783          	ld	a5,0(t1)
   104ca:	1141                	addi	sp,sp,-16
   104cc:	e406                	sd	ra,8(sp)
   104ce:	882a                	mv	a6,a0
   104d0:	e385                	bnez	a5,104f0 <_sbrk+0x32>
   104d2:	4501                	li	a0,0
   104d4:	4581                	li	a1,0
   104d6:	4601                	li	a2,0
   104d8:	4681                	li	a3,0
   104da:	4701                	li	a4,0
   104dc:	0d600893          	li	a7,214
   104e0:	00000073          	ecall
   104e4:	577d                	li	a4,-1
   104e6:	87aa                	mv	a5,a0
   104e8:	02e50a63          	beq	a0,a4,1051c <_sbrk+0x5e>
   104ec:	00a33023          	sd	a0,0(t1)
   104f0:	00f80533          	add	a0,a6,a5
   104f4:	4581                	li	a1,0
   104f6:	4601                	li	a2,0
   104f8:	4681                	li	a3,0
   104fa:	4701                	li	a4,0
   104fc:	4781                	li	a5,0
   104fe:	0d600893          	li	a7,214
   10502:	00000073          	ecall
   10506:	00033783          	ld	a5,0(t1)
   1050a:	983e                	add	a6,a6,a5
   1050c:	01051863          	bne	a0,a6,1051c <_sbrk+0x5e>
   10510:	60a2                	ld	ra,8(sp)
   10512:	00a33023          	sd	a0,0(t1)
   10516:	853e                	mv	a0,a5
   10518:	0141                	addi	sp,sp,16
   1051a:	8082                	ret
   1051c:	010000ef          	jal	1052c <__errno>
   10520:	60a2                	ld	ra,8(sp)
   10522:	47b1                	li	a5,12
   10524:	c11c                	sw	a5,0(a0)
   10526:	557d                	li	a0,-1
   10528:	0141                	addi	sp,sp,16
   1052a:	8082                	ret

000000000001052c <__errno>:
   1052c:	00031517          	auipc	a0,0x31
   10530:	a8453503          	ld	a0,-1404(a0) # 40fb0 <_impure_ptr>
   10534:	8082                	ret
