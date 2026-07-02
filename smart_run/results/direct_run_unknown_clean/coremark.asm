
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
      92:	1ff1819b          	addiw	gp,gp,511 # 11ff <core_bench_list+0x8cf>
      96:	7c11a073          	csrs	mhcr,gp

000000000000009a <after_l2en>:
      9a:	6185                	lui	gp,0x1
      9c:	1ff1819b          	addiw	gp,gp,511 # 11ff <core_bench_list+0x8cf>
      a0:	7c11a073          	csrs	mhcr,gp
      a4:	0006e1b7          	lui	gp,0x6e
      a8:	30c1819b          	addiw	gp,gp,780 # 6e30c <heap_end.0+0x2d254>
      ac:	7c51a073          	csrs	mhint,gp
      b0:	0070019b          	addiw	gp,zero,7
      b4:	01f6                	slli	gp,gp,0x1d
      b6:	01a5                	addi	gp,gp,9
      b8:	7c31a073          	csrs	mccr2,gp
      bc:	574060ef          	jal	6630 <main>

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

0000000000000670 <calc_func>:
     670:	7179                	addi	sp,sp,-48
     672:	fc11540b          	th.sdd	s0,ra,(sp),2,4
     676:	00051403          	lh	s0,0(a0)
     67a:	1c74378b          	th.extu	a5,s0,7,7
     67e:	c799                	beqz	a5,68c <calc_func+0x1c>
     680:	07f47513          	andi	a0,s0,127
     684:	fc11440b          	th.ldd	s0,ra,(sp),2,4
     688:	6145                	addi	sp,sp,48
     68a:	8082                	ret
     68c:	1834328b          	th.extu	t0,s0,6,3
     690:	ec26                	sd	s1,24(sp)
     692:	84ae                	mv	s1,a1
     694:	0042959b          	slliw	a1,t0,0x4
     698:	e44e                	sd	s3,8(sp)
     69a:	e84a                	sd	s2,16(sp)
     69c:	005586b3          	add	a3,a1,t0
     6a0:	00747713          	andi	a4,s0,7
     6a4:	892a                	mv	s2,a0
     6a6:	85b6                	mv	a1,a3
     6a8:	cf31                	beqz	a4,704 <calc_func+0x94>
     6aa:	4505                	li	a0,1
     6ac:	04a71863          	bne	a4,a0,6fc <calc_func+0x8c>
     6b0:	0604d603          	lhu	a2,96(s1)
     6b4:	04048513          	addi	a0,s1,64
     6b8:	2a8020ef          	jal	2960 <core_bench_matrix>
     6bc:	0644d803          	lhu	a6,100(s1)
     6c0:	3c05298b          	th.ext	s3,a0,15,0
     6c4:	00081463          	bnez	a6,6cc <calc_func+0x5c>
     6c8:	06a49223          	sh	a0,100(s1)
     6cc:	0604d583          	lhu	a1,96(s1)
     6d0:	3e1030ef          	jal	42b0 <crcu16>
     6d4:	06a49023          	sh	a0,96(s1)
     6d8:	f0047893          	andi	a7,s0,-256
     6dc:	07f9f513          	andi	a0,s3,127
     6e0:	fc11440b          	th.ldd	s0,ra,(sp),2,4
     6e4:	01156e33          	or	t3,a0,a7
     6e8:	080e6e93          	ori	t4,t3,128
     6ec:	01d91023          	sh	t4,0(s2)
     6f0:	64e2                	ld	s1,24(sp)
     6f2:	69a2                	ld	s3,8(sp)
     6f4:	6942                	ld	s2,16(sp)
     6f6:	6145                	addi	sp,sp,48
     6f8:	8082                	ret
     6fa:	0001                	nop
     6fc:	3c04350b          	th.extu	a0,s0,15,0
     700:	89a2                	mv	s3,s0
     702:	b7e9                	j	6cc <calc_func+0x5c>
     704:	02100313          	li	t1,33
     708:	00d333b3          	sltu	t2,t1,a3
     70c:	02200713          	li	a4,34
     710:	00049603          	lh	a2,0(s1)
     714:	4276970b          	th.mvnez	a4,a3,t2
     718:	0604d783          	lhu	a5,96(s1)
     71c:	00249683          	lh	a3,2(s1)
     720:	5488                	lw	a0,40(s1)
     722:	708c                	ld	a1,32(s1)
     724:	51d020ef          	jal	3440 <core_bench_state>
     728:	0664d603          	lhu	a2,102(s1)
     72c:	3c05298b          	th.ext	s3,a0,15,0
     730:	fe51                	bnez	a2,6cc <calc_func+0x5c>
     732:	06a49323          	sh	a0,102(s1)
     736:	bf59                	j	6cc <calc_func+0x5c>
     738:	00000013          	nop
     73c:	00000013          	nop

0000000000000740 <cmp_complex>:
     740:	7179                	addi	sp,sp,-48
     742:	fa91590b          	th.sdd	s2,s1,(sp),1,4
     746:	00051483          	lh	s1,0(a0)
     74a:	fc11540b          	th.sdd	s0,ra,(sp),2,4
     74e:	e052                	sd	s4,0(sp)
     750:	1c74b78b          	th.extu	a5,s1,7,7
     754:	892e                	mv	s2,a1
     756:	8432                	mv	s0,a2
     758:	07f4fa13          	andi	s4,s1,127
     75c:	e3bd                	bnez	a5,7c2 <cmp_complex+0x82>
     75e:	1834b28b          	th.extu	t0,s1,6,3
     762:	0042959b          	slliw	a1,t0,0x4
     766:	005586b3          	add	a3,a1,t0
     76a:	e44e                	sd	s3,8(sp)
     76c:	0074f713          	andi	a4,s1,7
     770:	85b6                	mv	a1,a3
     772:	89aa                	mv	s3,a0
     774:	10070a63          	beqz	a4,888 <cmp_complex+0x148>
     778:	4505                	li	a0,1
     77a:	0ca71563          	bne	a4,a0,844 <cmp_complex+0x104>
     77e:	06065603          	lhu	a2,96(a2)
     782:	04040513          	addi	a0,s0,64
     786:	1da020ef          	jal	2960 <core_bench_matrix>
     78a:	06445803          	lhu	a6,100(s0)
     78e:	3c052a0b          	th.ext	s4,a0,15,0
     792:	00081763          	bnez	a6,7a0 <cmp_complex+0x60>
     796:	06a41223          	sh	a0,100(s0)
     79a:	0001                	nop
     79c:	00000013          	nop
     7a0:	06045583          	lhu	a1,96(s0)
     7a4:	07fa7a13          	andi	s4,s4,127
     7a8:	309030ef          	jal	42b0 <crcu16>
     7ac:	f004f893          	andi	a7,s1,-256
     7b0:	011a6e33          	or	t3,s4,a7
     7b4:	06a41023          	sh	a0,96(s0)
     7b8:	080e6e93          	ori	t4,t3,128
     7bc:	01d99023          	sh	t4,0(s3)
     7c0:	69a2                	ld	s3,8(sp)
     7c2:	00091483          	lh	s1,0(s2)
     7c6:	1c74bf0b          	th.extu	t5,s1,7,7
     7ca:	07f4f513          	andi	a0,s1,127
     7ce:	060f1263          	bnez	t5,832 <cmp_complex+0xf2>
     7d2:	1834b78b          	th.extu	a5,s1,6,3
     7d6:	0047929b          	slliw	t0,a5,0x4
     7da:	00f286b3          	add	a3,t0,a5
     7de:	0074ff93          	andi	t6,s1,7
     7e2:	e44e                	sd	s3,8(sp)
     7e4:	85b6                	mv	a1,a3
     7e6:	060f8763          	beqz	t6,854 <cmp_complex+0x114>
     7ea:	4385                	li	t2,1
     7ec:	067f9063          	bne	t6,t2,84c <cmp_complex+0x10c>
     7f0:	06045603          	lhu	a2,96(s0)
     7f4:	04040513          	addi	a0,s0,64
     7f8:	168020ef          	jal	2960 <core_bench_matrix>
     7fc:	06445603          	lhu	a2,100(s0)
     800:	3c05298b          	th.ext	s3,a0,15,0
     804:	e611                	bnez	a2,810 <cmp_complex+0xd0>
     806:	06a41223          	sh	a0,100(s0)
     80a:	0001                	nop
     80c:	00000013          	nop
     810:	06045583          	lhu	a1,96(s0)
     814:	29d030ef          	jal	42b0 <crcu16>
     818:	06a41023          	sh	a0,96(s0)
     81c:	07f9f513          	andi	a0,s3,127
     820:	f004f413          	andi	s0,s1,-256
     824:	00856833          	or	a6,a0,s0
     828:	69a2                	ld	s3,8(sp)
     82a:	08086893          	ori	a7,a6,128
     82e:	01191023          	sh	a7,0(s2)
     832:	fc11440b          	th.ldd	s0,ra,(sp),2,4
     836:	fa91490b          	th.ldd	s2,s1,(sp),1,4
     83a:	40aa053b          	subw	a0,s4,a0
     83e:	6a02                	ld	s4,0(sp)
     840:	6145                	addi	sp,sp,48
     842:	8082                	ret
     844:	3c04b50b          	th.extu	a0,s1,15,0
     848:	8a26                	mv	s4,s1
     84a:	bf99                	j	7a0 <cmp_complex+0x60>
     84c:	3c04b50b          	th.extu	a0,s1,15,0
     850:	89a6                	mv	s3,s1
     852:	bf7d                	j	810 <cmp_complex+0xd0>
     854:	02100993          	li	s3,33
     858:	00d9b333          	sltu	t1,s3,a3
     85c:	02200713          	li	a4,34
     860:	700c                	ld	a1,32(s0)
     862:	4266970b          	th.mvnez	a4,a3,t1
     866:	06045783          	lhu	a5,96(s0)
     86a:	00241683          	lh	a3,2(s0)
     86e:	00041603          	lh	a2,0(s0)
     872:	5408                	lw	a0,40(s0)
     874:	3cd020ef          	jal	3440 <core_bench_state>
     878:	06645583          	lhu	a1,102(s0)
     87c:	3c05298b          	th.ext	s3,a0,15,0
     880:	f9c1                	bnez	a1,810 <cmp_complex+0xd0>
     882:	06a41323          	sh	a0,102(s0)
     886:	b769                	j	810 <cmp_complex+0xd0>
     888:	02100313          	li	t1,33
     88c:	00d333b3          	sltu	t2,t1,a3
     890:	02200713          	li	a4,34
     894:	06065783          	lhu	a5,96(a2)
     898:	4276970b          	th.mvnez	a4,a3,t2
     89c:	5408                	lw	a0,40(s0)
     89e:	00261683          	lh	a3,2(a2)
     8a2:	700c                	ld	a1,32(s0)
     8a4:	00061603          	lh	a2,0(a2)
     8a8:	399020ef          	jal	3440 <core_bench_state>
     8ac:	06645603          	lhu	a2,102(s0)
     8b0:	3c052a0b          	th.ext	s4,a0,15,0
     8b4:	ee0616e3          	bnez	a2,7a0 <cmp_complex+0x60>
     8b8:	06a41323          	sh	a0,102(s0)
     8bc:	b5d5                	j	7a0 <cmp_complex+0x60>
     8be:	0001                	nop

00000000000008c0 <cmp_idx>:
     8c0:	ca01                	beqz	a2,8d0 <cmp_idx+0x10>
     8c2:	00251503          	lh	a0,2(a0)
     8c6:	00259583          	lh	a1,2(a1)
     8ca:	9d0d                	subw	a0,a0,a1
     8cc:	8082                	ret
     8ce:	0001                	nop
     8d0:	00051783          	lh	a5,0(a0)
     8d4:	f007f713          	andi	a4,a5,-256
     8d8:	3c87b28b          	th.extu	t0,a5,15,8
     8dc:	00576333          	or	t1,a4,t0
     8e0:	00651023          	sh	t1,0(a0)
     8e4:	00059383          	lh	t2,0(a1)
     8e8:	00251503          	lh	a0,2(a0)
     8ec:	f003f613          	andi	a2,t2,-256
     8f0:	3c83b68b          	th.extu	a3,t2,15,8
     8f4:	00d66833          	or	a6,a2,a3
     8f8:	01059023          	sh	a6,0(a1)
     8fc:	00259583          	lh	a1,2(a1)
     900:	9d0d                	subw	a0,a0,a1
     902:	8082                	ret
     904:	00000013          	nop
     908:	00000013          	nop
     90c:	00000013          	nop

0000000000000910 <copy_info>:
     910:	00059783          	lh	a5,0(a1)
     914:	00259283          	lh	t0,2(a1)
     918:	00f51023          	sh	a5,0(a0)
     91c:	00551123          	sh	t0,2(a0)
     920:	8082                	ret
     922:	0001                	nop
     924:	00000013          	nop
     928:	00000013          	nop
     92c:	00000013          	nop

0000000000000930 <core_bench_list>:
     930:	00451f83          	lh	t6,4(a0)
     934:	7135                	addi	sp,sp,-160
     936:	e4e6                	sd	s9,72(sp)
     938:	e8e2                	sd	s8,80(sp)
     93a:	fc6e                	sd	s11,56(sp)
     93c:	e0ea                	sd	s10,64(sp)
     93e:	ecde                	sd	s7,88(sp)
     940:	f0da                	sd	s6,96(sp)
     942:	f4d6                	sd	s5,104(sp)
     944:	f8d2                	sd	s4,112(sp)
     946:	fcce                	sd	s3,120(sp)
     948:	e14a                	sd	s2,128(sp)
     94a:	e526                	sd	s1,136(sp)
     94c:	e922                	sd	s0,144(sp)
     94e:	f002                	sd	zero,32(sp)
     950:	ed06                	sd	ra,152(sp)
     952:	03853a03          	ld	s4,56(a0)
     956:	8e2e                	mv	t3,a1
     958:	8caa                	mv	s9,a0
     95a:	23f054e3          	blez	t6,1382 <core_bench_list+0xa52>
     95e:	2205c6e3          	bltz	a1,138a <core_bench_list+0xa5a>
     962:	220a0fe3          	beqz	s4,13a0 <core_bench_list+0xa70>
     966:	4501                	li	a0,0
     968:	4e81                	li	t4,0
     96a:	4301                	li	t1,0
     96c:	4881                	li	a7,0
     96e:	ec2e                	sd	a1,24(sp)
     970:	87d2                	mv	a5,s4
     972:	a021                	j	97a <core_bench_list+0x4a>
     974:	639c                	ld	a5,0(a5)
     976:	10078d63          	beqz	a5,a90 <core_bench_list+0x160>
     97a:	6798                	ld	a4,8(a5)
     97c:	66e2                	ld	a3,24(sp)
     97e:	00271703          	lh	a4,2(a4)
     982:	fed719e3          	bne	a4,a3,974 <core_bench_list+0x44>
     986:	000a3283          	ld	t0,0(s4)
     98a:	4981                	li	s3,0
     98c:	013a3023          	sd	s3,0(s4)
     990:	85d2                	mv	a1,s4
     992:	06028763          	beqz	t0,a00 <core_bench_list+0xd0>
     996:	0002b603          	ld	a2,0(t0)
     99a:	00b2b023          	sd	a1,0(t0)
     99e:	8a16                	mv	s4,t0
     9a0:	c225                	beqz	a2,a00 <core_bench_list+0xd0>
     9a2:	00063383          	ld	t2,0(a2)
     9a6:	00563023          	sd	t0,0(a2)
     9aa:	8a32                	mv	s4,a2
     9ac:	04038a63          	beqz	t2,a00 <core_bench_list+0xd0>
     9b0:	0003b403          	ld	s0,0(t2)
     9b4:	00c3b023          	sd	a2,0(t2)
     9b8:	8a1e                	mv	s4,t2
     9ba:	c039                	beqz	s0,a00 <core_bench_list+0xd0>
     9bc:	6004                	ld	s1,0(s0)
     9be:	00743023          	sd	t2,0(s0)
     9c2:	8a22                	mv	s4,s0
     9c4:	cc95                	beqz	s1,a00 <core_bench_list+0xd0>
     9c6:	0004b803          	ld	a6,0(s1)
     9ca:	e080                	sd	s0,0(s1)
     9cc:	8a26                	mv	s4,s1
     9ce:	02080963          	beqz	a6,a00 <core_bench_list+0xd0>
     9d2:	00083903          	ld	s2,0(a6)
     9d6:	00983023          	sd	s1,0(a6)
     9da:	8a42                	mv	s4,a6
     9dc:	02090263          	beqz	s2,a00 <core_bench_list+0xd0>
     9e0:	00093a83          	ld	s5,0(s2)
     9e4:	01093023          	sd	a6,0(s2)
     9e8:	8a4a                	mv	s4,s2
     9ea:	89ca                	mv	s3,s2
     9ec:	000a8a63          	beqz	s5,a00 <core_bench_list+0xd0>
     9f0:	8a56                	mv	s4,s5
     9f2:	000a3283          	ld	t0,0(s4)
     9f6:	013a3023          	sd	s3,0(s4)
     9fa:	85d2                	mv	a1,s4
     9fc:	f8029de3          	bnez	t0,996 <core_bench_list+0x66>
     a00:	cbd1                	beqz	a5,a94 <core_bench_list+0x164>
     a02:	0087bb03          	ld	s6,8(a5)
     a06:	6394                	ld	a3,0(a5)
     a08:	000b1b83          	lh	s7,0(s6)
     a0c:	249bbd0b          	th.extu	s10,s7,9,9
     a10:	011d0dbb          	addw	s11,s10,a7
     a14:	001bfc13          	andi	s8,s7,1
     a18:	3c0dbf0b          	th.extu	t5,s11,15,0
     a1c:	438f188b          	th.mvnez	a7,t5,s8
     a20:	ca81                	beqz	a3,a30 <core_bench_list+0x100>
     a22:	628c                	ld	a1,0(a3)
     a24:	e38c                	sd	a1,0(a5)
     a26:	000a3783          	ld	a5,0(s4)
     a2a:	e29c                	sd	a5,0(a3)
     a2c:	00da3023          	sd	a3,0(s4)
     a30:	2305                	addiw	t1,t1,1
     a32:	3c03330b          	th.extu	t1,t1,15,0
     a36:	02074763          	bltz	a4,a64 <core_bench_list+0x134>
     a3a:	2705                	addiw	a4,a4,1
     a3c:	0015091b          	addiw	s2,a0,1
     a40:	3c07280b          	th.ext	a6,a4,15,0
     a44:	3c09250b          	th.ext	a0,s2,15,0
     a48:	ec42                	sd	a6,24(sp)
     a4a:	3c09398b          	th.extu	s3,s2,15,0
     a4e:	06af8663          	beq	t6,a0,aba <core_bench_list+0x18a>
     a52:	0ff9f413          	zext.b	s0,s3
     a56:	f022                	sd	s0,32(sp)
     a58:	f0085ce3          	bgez	a6,970 <core_bench_list+0x40>
     a5c:	85a2                	mv	a1,s0
     a5e:	87d2                	mv	a5,s4
     a60:	7761                	lui	a4,0xffff8
     a62:	a839                	j	a80 <core_bench_list+0x150>
     a64:	2505                	addiw	a0,a0,1
     a66:	3c05348b          	th.extu	s1,a0,15,0
     a6a:	3c05250b          	th.ext	a0,a0,15,0
     a6e:	04af8563          	beq	t6,a0,ab8 <core_bench_list+0x188>
     a72:	0ff4f593          	zext.b	a1,s1
     a76:	87d2                	mv	a5,s4
     a78:	a021                	j	a80 <core_bench_list+0x150>
     a7a:	0001                	nop
     a7c:	639c                	ld	a5,0(a5)
     a7e:	cb9d                	beqz	a5,ab4 <core_bench_list+0x184>
     a80:	0087bb83          	ld	s7,8(a5)
     a84:	000bc483          	lbu	s1,0(s7)
     a88:	f026                	sd	s1,32(sp)
     a8a:	feb499e3          	bne	s1,a1,a7c <core_bench_list+0x14c>
     a8e:	bde5                	j	986 <core_bench_list+0x56>
     a90:	8736                	mv	a4,a3
     a92:	bdd5                	j	986 <core_bench_list+0x56>
     a94:	000a3283          	ld	t0,0(s4)
     a98:	2e85                	addiw	t4,t4,1
     a9a:	3c0ebe8b          	th.extu	t4,t4,15,0
     a9e:	0082b603          	ld	a2,8(t0)
     aa2:	00061383          	lh	t2,0(a2)
     aa6:	2083b40b          	th.extu	s0,t2,8,8
     aaa:	011408bb          	addw	a7,s0,a7
     aae:	3c08b88b          	th.extu	a7,a7,15,0
     ab2:	b751                	j	a36 <core_bench_list+0x106>
     ab4:	f02e                	sd	a1,32(sp)
     ab6:	bdc1                	j	986 <core_bench_list+0x56>
     ab8:	ec3a                	sd	a4,24(sp)
     aba:	00231f9b          	slliw	t6,t1,0x2
     abe:	41df8abb          	subw	s5,t6,t4
     ac2:	011a8b3b          	addw	s6,s5,a7
     ac6:	3c0b3b8b          	th.extu	s7,s6,15,0
     aca:	f45e                	sd	s7,40(sp)
     acc:	4dc04b63          	bgtz	t3,fa2 <core_bench_list+0x672>
     ad0:	000a3983          	ld	s3,0(s4)
     ad4:	6be2                	ld	s7,24(sp)
     ad6:	8452                	mv	s0,s4
     ad8:	f859c48b          	th.ldd	s1,t0,(s3),0,4
     adc:	0084bd03          	ld	s10,8(s1)
     ae0:	0004bc83          	ld	s9,0(s1)
     ae4:	01a9b423          	sd	s10,8(s3)
     ae8:	0054b423          	sd	t0,8(s1)
     aec:	0199b023          	sd	s9,0(s3)
     af0:	0004b023          	sd	zero,0(s1)
     af4:	320bcd63          	bltz	s7,e2e <core_bench_list+0x4fe>
     af8:	6410                	ld	a2,8(s0)
     afa:	63e2                	ld	t2,24(sp)
     afc:	00261883          	lh	a7,2(a2)
     b00:	00788b63          	beq	a7,t2,b16 <core_bench_list+0x1e6>
     b04:	6000                	ld	s0,0(s0)
     b06:	48040963          	beqz	s0,f98 <core_bench_list+0x668>
     b0a:	6410                	ld	a2,8(s0)
     b0c:	63e2                	ld	t2,24(sp)
     b0e:	00261883          	lh	a7,2(a2)
     b12:	fe7899e3          	bne	a7,t2,b04 <core_bench_list+0x1d4>
     b16:	008a3703          	ld	a4,8(s4)
     b1a:	75a2                	ld	a1,40(sp)
     b1c:	00071503          	lh	a0,0(a4) # ffffffffffff8000 <__kernel_stack+0xfffffffffff0a000>
     b20:	4a1030ef          	jal	47c0 <crc16>
     b24:	6000                	ld	s0,0(s0)
     b26:	f42a                	sd	a0,40(sp)
     b28:	c445                	beqz	s0,bd0 <core_bench_list+0x2a0>
     b2a:	008a3803          	ld	a6,8(s4)
     b2e:	85aa                	mv	a1,a0
     b30:	00081503          	lh	a0,0(a6)
     b34:	48d030ef          	jal	47c0 <crc16>
     b38:	00043c03          	ld	s8,0(s0)
     b3c:	f42a                	sd	a0,40(sp)
     b3e:	85aa                	mv	a1,a0
     b40:	080c0863          	beqz	s8,bd0 <core_bench_list+0x2a0>
     b44:	008a3f83          	ld	t6,8(s4)
     b48:	000f9503          	lh	a0,0(t6)
     b4c:	475030ef          	jal	47c0 <crc16>
     b50:	000c3b03          	ld	s6,0(s8)
     b54:	f42a                	sd	a0,40(sp)
     b56:	85aa                	mv	a1,a0
     b58:	060b0c63          	beqz	s6,bd0 <core_bench_list+0x2a0>
     b5c:	008a3503          	ld	a0,8(s4)
     b60:	00051503          	lh	a0,0(a0)
     b64:	45d030ef          	jal	47c0 <crc16>
     b68:	000b3d83          	ld	s11,0(s6)
     b6c:	f42a                	sd	a0,40(sp)
     b6e:	85aa                	mv	a1,a0
     b70:	060d8063          	beqz	s11,bd0 <core_bench_list+0x2a0>
     b74:	008a3e03          	ld	t3,8(s4)
     b78:	000e1503          	lh	a0,0(t3)
     b7c:	445030ef          	jal	47c0 <crc16>
     b80:	000db903          	ld	s2,0(s11)
     b84:	f42a                	sd	a0,40(sp)
     b86:	85aa                	mv	a1,a0
     b88:	04090463          	beqz	s2,bd0 <core_bench_list+0x2a0>
     b8c:	008a3f03          	ld	t5,8(s4)
     b90:	000f1503          	lh	a0,0(t5)
     b94:	42d030ef          	jal	47c0 <crc16>
     b98:	00093983          	ld	s3,0(s2)
     b9c:	f42a                	sd	a0,40(sp)
     b9e:	85aa                	mv	a1,a0
     ba0:	02098863          	beqz	s3,bd0 <core_bench_list+0x2a0>
     ba4:	008a3683          	ld	a3,8(s4)
     ba8:	00069503          	lh	a0,0(a3)
     bac:	415030ef          	jal	47c0 <crc16>
     bb0:	0009bd03          	ld	s10,0(s3)
     bb4:	f42a                	sd	a0,40(sp)
     bb6:	85aa                	mv	a1,a0
     bb8:	000d0c63          	beqz	s10,bd0 <core_bench_list+0x2a0>
     bbc:	008a3783          	ld	a5,8(s4)
     bc0:	00079503          	lh	a0,0(a5)
     bc4:	3fd030ef          	jal	47c0 <crc16>
     bc8:	000d3403          	ld	s0,0(s10)
     bcc:	f42a                	sd	a0,40(sp)
     bce:	f421                	bnez	s0,b16 <core_bench_list+0x1e6>
     bd0:	0084b283          	ld	t0,8(s1)
     bd4:	000a3403          	ld	s0,0(s4)
     bd8:	640c                	ld	a1,8(s0)
     bda:	00043c83          	ld	s9,0(s0)
     bde:	4e05                	li	t3,1
     be0:	e48c                	sd	a1,8(s1)
     be2:	00543423          	sd	t0,8(s0)
     be6:	0194b023          	sd	s9,0(s1)
     bea:	e004                	sd	s1,0(s0)
     bec:	8f72                	mv	t5,t3
     bee:	220a0a63          	beqz	s4,e22 <core_bench_list+0x4f2>
     bf2:	4401                	li	s0,0
     bf4:	4a81                	li	s5,0
     bf6:	4e81                	li	t4,0
     bf8:	2e85                	addiw	t4,t4,1
     bfa:	8bd2                	mv	s7,s4
     bfc:	4781                	li	a5,0
     bfe:	0001                	nop
     c00:	01c7d763          	bge	a5,t3,c0e <core_bench_list+0x2de>
     c04:	000bbb83          	ld	s7,0(s7)
     c08:	2785                	addiw	a5,a5,1
     c0a:	fe0b9be3          	bnez	s7,c00 <core_bench_list+0x2d0>
     c0e:	86d6                	mv	a3,s5
     c10:	85f2                	mv	a1,t3
     c12:	8ad2                	mv	s5,s4
     c14:	8a5e                	mv	s4,s7
     c16:	06f05263          	blez	a5,c7a <core_bench_list+0x34a>
     c1a:	0001                	nop
     c1c:	00000013          	nop
     c20:	22058063          	beqz	a1,e40 <core_bench_list+0x510>
     c24:	240a0063          	beqz	s4,e64 <core_bench_list+0x534>
     c28:	008abb03          	ld	s6,8(s5)
     c2c:	008a3d03          	ld	s10,8(s4)
     c30:	000b1503          	lh	a0,0(s6)
     c34:	002b1283          	lh	t0,2(s6)
     c38:	002d1383          	lh	t2,2(s10)
     c3c:	f0057d93          	andi	s11,a0,-256
     c40:	3c85390b          	th.extu	s2,a0,15,8
     c44:	012de9b3          	or	s3,s11,s2
     c48:	013b1023          	sh	s3,0(s6)
     c4c:	000d1c83          	lh	s9,0(s10)
     c50:	f00cfb93          	andi	s7,s9,-256
     c54:	3c8cb30b          	th.extu	t1,s9,15,8
     c58:	006be4b3          	or	s1,s7,t1
     c5c:	009d1023          	sh	s1,0(s10)
     c60:	2053d263          	bge	t2,t0,e64 <core_bench_list+0x534>
     c64:	88d2                	mv	a7,s4
     c66:	35fd                	addiw	a1,a1,-1
     c68:	000a3a03          	ld	s4,0(s4)
     c6c:	20068263          	beqz	a3,e70 <core_bench_list+0x540>
     c70:	0116b023          	sd	a7,0(a3)
     c74:	86c6                	mv	a3,a7
     c76:	faf045e3          	bgtz	a5,c20 <core_bench_list+0x2f0>
     c7a:	30b05963          	blez	a1,f8c <core_bench_list+0x65c>
     c7e:	180a0963          	beqz	s4,e10 <core_bench_list+0x4e0>
     c82:	f3dd                	bnez	a5,c28 <core_bench_list+0x2f8>
     c84:	fff5831b          	addiw	t1,a1,-1
     c88:	00737493          	andi	s1,t1,7
     c8c:	c0e9                	beqz	s1,d4e <core_bench_list+0x41e>
     c8e:	000a3383          	ld	t2,0(s4)
     c92:	35fd                	addiw	a1,a1,-1
     c94:	1e068f63          	beqz	a3,e92 <core_bench_list+0x562>
     c98:	0146b023          	sd	s4,0(a3)
     c9c:	86d2                	mv	a3,s4
     c9e:	16038963          	beqz	t2,e10 <core_bench_list+0x4e0>
     ca2:	4605                	li	a2,1
     ca4:	8a1e                	mv	s4,t2
     ca6:	0004889b          	sext.w	a7,s1
     caa:	0ac48263          	beq	s1,a2,d4e <core_bench_list+0x41e>
     cae:	4709                	li	a4,2
     cb0:	08e88463          	beq	a7,a4,d38 <core_bench_list+0x408>
     cb4:	480d                	li	a6,3
     cb6:	07088663          	beq	a7,a6,d22 <core_bench_list+0x3f2>
     cba:	4c11                	li	s8,4
     cbc:	05888863          	beq	a7,s8,d0c <core_bench_list+0x3dc>
     cc0:	4f95                	li	t6,5
     cc2:	03f88a63          	beq	a7,t6,cf6 <core_bench_list+0x3c6>
     cc6:	4b19                	li	s6,6
     cc8:	01688c63          	beq	a7,s6,ce0 <core_bench_list+0x3b0>
     ccc:	0003ba03          	ld	s4,0(t2)
     cd0:	35fd                	addiw	a1,a1,-1
     cd2:	2c068163          	beqz	a3,f94 <core_bench_list+0x664>
     cd6:	0076b023          	sd	t2,0(a3)
     cda:	869e                	mv	a3,t2
     cdc:	120a0a63          	beqz	s4,e10 <core_bench_list+0x4e0>
     ce0:	000a3503          	ld	a0,0(s4)
     ce4:	35fd                	addiw	a1,a1,-1
     ce6:	1c068063          	beqz	a3,ea6 <core_bench_list+0x576>
     cea:	0146b023          	sd	s4,0(a3)
     cee:	86d2                	mv	a3,s4
     cf0:	12050063          	beqz	a0,e10 <core_bench_list+0x4e0>
     cf4:	8a2a                	mv	s4,a0
     cf6:	000a3d83          	ld	s11,0(s4)
     cfa:	35fd                	addiw	a1,a1,-1
     cfc:	1a068363          	beqz	a3,ea2 <core_bench_list+0x572>
     d00:	0146b023          	sd	s4,0(a3)
     d04:	86d2                	mv	a3,s4
     d06:	100d8563          	beqz	s11,e10 <core_bench_list+0x4e0>
     d0a:	8a6e                	mv	s4,s11
     d0c:	000a3903          	ld	s2,0(s4)
     d10:	35fd                	addiw	a1,a1,-1
     d12:	18068663          	beqz	a3,e9e <core_bench_list+0x56e>
     d16:	0146b023          	sd	s4,0(a3)
     d1a:	86d2                	mv	a3,s4
     d1c:	0e090a63          	beqz	s2,e10 <core_bench_list+0x4e0>
     d20:	8a4a                	mv	s4,s2
     d22:	000a3983          	ld	s3,0(s4)
     d26:	35fd                	addiw	a1,a1,-1
     d28:	16068963          	beqz	a3,e9a <core_bench_list+0x56a>
     d2c:	0146b023          	sd	s4,0(a3)
     d30:	86d2                	mv	a3,s4
     d32:	0c098f63          	beqz	s3,e10 <core_bench_list+0x4e0>
     d36:	8a4e                	mv	s4,s3
     d38:	000a3d03          	ld	s10,0(s4)
     d3c:	35fd                	addiw	a1,a1,-1
     d3e:	14068c63          	beqz	a3,e96 <core_bench_list+0x566>
     d42:	0146b023          	sd	s4,0(a3)
     d46:	86d2                	mv	a3,s4
     d48:	0c0d0463          	beqz	s10,e10 <core_bench_list+0x4e0>
     d4c:	8a6a                	mv	s4,s10
     d4e:	000a3783          	ld	a5,0(s4)
     d52:	35fd                	addiw	a1,a1,-1
     d54:	c6d5                	beqz	a3,e00 <core_bench_list+0x4d0>
     d56:	0146b023          	sd	s4,0(a3)
     d5a:	c5cd                	beqz	a1,e04 <core_bench_list+0x4d4>
     d5c:	86d2                	mv	a3,s4
     d5e:	cbcd                	beqz	a5,e10 <core_bench_list+0x4e0>
     d60:	0007bb83          	ld	s7,0(a5)
     d64:	fff58c9b          	addiw	s9,a1,-1
     d68:	100a0763          	beqz	s4,e76 <core_bench_list+0x546>
     d6c:	00fa3023          	sd	a5,0(s4)
     d70:	86be                	mv	a3,a5
     d72:	080b8f63          	beqz	s7,e10 <core_bench_list+0x4e0>
     d76:	000bb303          	ld	t1,0(s7)
     d7a:	fffc8a9b          	addiw	s5,s9,-1
     d7e:	0e078e63          	beqz	a5,e7a <core_bench_list+0x54a>
     d82:	0177b023          	sd	s7,0(a5)
     d86:	86de                	mv	a3,s7
     d88:	08030463          	beqz	t1,e10 <core_bench_list+0x4e0>
     d8c:	00033283          	ld	t0,0(t1)
     d90:	fffa849b          	addiw	s1,s5,-1
     d94:	0e0b8563          	beqz	s7,e7e <core_bench_list+0x54e>
     d98:	006bb023          	sd	t1,0(s7)
     d9c:	869a                	mv	a3,t1
     d9e:	06028963          	beqz	t0,e10 <core_bench_list+0x4e0>
     da2:	0002b883          	ld	a7,0(t0)
     da6:	fff4839b          	addiw	t2,s1,-1
     daa:	0c030c63          	beqz	t1,e82 <core_bench_list+0x552>
     dae:	00533023          	sd	t0,0(t1)
     db2:	8696                	mv	a3,t0
     db4:	04088e63          	beqz	a7,e10 <core_bench_list+0x4e0>
     db8:	0008b603          	ld	a2,0(a7)
     dbc:	fff3871b          	addiw	a4,t2,-1
     dc0:	0c028363          	beqz	t0,e86 <core_bench_list+0x556>
     dc4:	0112b023          	sd	a7,0(t0)
     dc8:	86c6                	mv	a3,a7
     dca:	c239                	beqz	a2,e10 <core_bench_list+0x4e0>
     dcc:	00063c03          	ld	s8,0(a2)
     dd0:	fff7081b          	addiw	a6,a4,-1
     dd4:	0a088b63          	beqz	a7,e8a <core_bench_list+0x55a>
     dd8:	00c8b023          	sd	a2,0(a7)
     ddc:	86b2                	mv	a3,a2
     dde:	020c0963          	beqz	s8,e10 <core_bench_list+0x4e0>
     de2:	000c3f83          	ld	t6,0(s8)
     de6:	fff8059b          	addiw	a1,a6,-1
     dea:	c255                	beqz	a2,e8e <core_bench_list+0x55e>
     dec:	01863023          	sd	s8,0(a2)
     df0:	86e2                	mv	a3,s8
     df2:	000f8f63          	beqz	t6,e10 <core_bench_list+0x4e0>
     df6:	8a7e                	mv	s4,t6
     df8:	000a3783          	ld	a5,0(s4)
     dfc:	35fd                	addiw	a1,a1,-1
     dfe:	fea1                	bnez	a3,d56 <core_bench_list+0x426>
     e00:	8452                	mv	s0,s4
     e02:	fda9                	bnez	a1,d5c <core_bench_list+0x42c>
     e04:	8ad2                	mv	s5,s4
     e06:	8a3e                	mv	s4,a5
     e08:	de0a18e3          	bnez	s4,bf8 <core_bench_list+0x2c8>
     e0c:	86d6                	mv	a3,s5
     e0e:	0001                	nop
     e10:	0006b023          	sd	zero,0(a3)
     e14:	09ee8b63          	beq	t4,t5,eaa <core_bench_list+0x57a>
     e18:	8a22                	mv	s4,s0
     e1a:	001e1e1b          	slliw	t3,t3,0x1
     e1e:	dc0a1ae3          	bnez	s4,bf2 <core_bench_list+0x2c2>
     e22:	00003023          	sd	zero,0(zero) # 0 <__start>
     e26:	9002                	ebreak
     e28:	6000                	ld	s0,0(s0)
     e2a:	16040763          	beqz	s0,f98 <core_bench_list+0x668>
     e2e:	00843e83          	ld	t4,8(s0)
     e32:	7302                	ld	t1,32(sp)
     e34:	000eca83          	lbu	s5,0(t4)
     e38:	ff5318e3          	bne	t1,s5,e28 <core_bench_list+0x4f8>
     e3c:	b9e9                	j	b16 <core_bench_list+0x1e6>
     e3e:	0001                	nop
     e40:	000ab703          	ld	a4,0(s5)
     e44:	37fd                	addiw	a5,a5,-1
     e46:	ca91                	beqz	a3,e5a <core_bench_list+0x52a>
     e48:	0156b023          	sd	s5,0(a3)
     e4c:	dfd5                	beqz	a5,e08 <core_bench_list+0x4d8>
     e4e:	86d6                	mv	a3,s5
     e50:	8aba                	mv	s5,a4
     e52:	000ab703          	ld	a4,0(s5)
     e56:	37fd                	addiw	a5,a5,-1
     e58:	fae5                	bnez	a3,e48 <core_bench_list+0x518>
     e5a:	8456                	mv	s0,s5
     e5c:	fbed                	bnez	a5,e4e <core_bench_list+0x51e>
     e5e:	d80a1de3          	bnez	s4,bf8 <core_bench_list+0x2c8>
     e62:	b76d                	j	e0c <core_bench_list+0x4dc>
     e64:	88d6                	mv	a7,s5
     e66:	37fd                	addiw	a5,a5,-1
     e68:	000aba83          	ld	s5,0(s5)
     e6c:	e00692e3          	bnez	a3,c70 <core_bench_list+0x340>
     e70:	8446                	mv	s0,a7
     e72:	86c6                	mv	a3,a7
     e74:	b509                	j	c76 <core_bench_list+0x346>
     e76:	843e                	mv	s0,a5
     e78:	bde5                	j	d70 <core_bench_list+0x440>
     e7a:	845e                	mv	s0,s7
     e7c:	b729                	j	d86 <core_bench_list+0x456>
     e7e:	841a                	mv	s0,t1
     e80:	bf31                	j	d9c <core_bench_list+0x46c>
     e82:	8416                	mv	s0,t0
     e84:	b73d                	j	db2 <core_bench_list+0x482>
     e86:	8446                	mv	s0,a7
     e88:	b781                	j	dc8 <core_bench_list+0x498>
     e8a:	8432                	mv	s0,a2
     e8c:	bf81                	j	ddc <core_bench_list+0x4ac>
     e8e:	8462                	mv	s0,s8
     e90:	b785                	j	df0 <core_bench_list+0x4c0>
     e92:	8452                	mv	s0,s4
     e94:	b521                	j	c9c <core_bench_list+0x36c>
     e96:	8452                	mv	s0,s4
     e98:	b57d                	j	d46 <core_bench_list+0x416>
     e9a:	8452                	mv	s0,s4
     e9c:	bd51                	j	d30 <core_bench_list+0x400>
     e9e:	8452                	mv	s0,s4
     ea0:	bdad                	j	d1a <core_bench_list+0x3ea>
     ea2:	8452                	mv	s0,s4
     ea4:	b585                	j	d04 <core_bench_list+0x3d4>
     ea6:	8452                	mv	s0,s4
     ea8:	b599                	j	cee <core_bench_list+0x3be>
     eaa:	00043c83          	ld	s9,0(s0)
     eae:	0a0c8f63          	beqz	s9,f6c <core_bench_list+0x63c>
     eb2:	00843a03          	ld	s4,8(s0)
     eb6:	75a2                	ld	a1,40(sp)
     eb8:	000a1503          	lh	a0,0(s4)
     ebc:	105030ef          	jal	47c0 <crc16>
     ec0:	000cba83          	ld	s5,0(s9)
     ec4:	f42a                	sd	a0,40(sp)
     ec6:	0a0a8363          	beqz	s5,f6c <core_bench_list+0x63c>
     eca:	6410                	ld	a2,8(s0)
     ecc:	85aa                	mv	a1,a0
     ece:	00061503          	lh	a0,0(a2)
     ed2:	0ef030ef          	jal	47c0 <crc16>
     ed6:	000abc03          	ld	s8,0(s5)
     eda:	f42a                	sd	a0,40(sp)
     edc:	85aa                	mv	a1,a0
     ede:	080c0763          	beqz	s8,f6c <core_bench_list+0x63c>
     ee2:	00843803          	ld	a6,8(s0)
     ee6:	00081503          	lh	a0,0(a6)
     eea:	0d7030ef          	jal	47c0 <crc16>
     eee:	000c3b03          	ld	s6,0(s8)
     ef2:	f42a                	sd	a0,40(sp)
     ef4:	85aa                	mv	a1,a0
     ef6:	060b0b63          	beqz	s6,f6c <core_bench_list+0x63c>
     efa:	00843f83          	ld	t6,8(s0)
     efe:	000f9503          	lh	a0,0(t6)
     f02:	0bf030ef          	jal	47c0 <crc16>
     f06:	000b3d83          	ld	s11,0(s6)
     f0a:	f42a                	sd	a0,40(sp)
     f0c:	85aa                	mv	a1,a0
     f0e:	040d8f63          	beqz	s11,f6c <core_bench_list+0x63c>
     f12:	6414                	ld	a3,8(s0)
     f14:	00069503          	lh	a0,0(a3)
     f18:	0a9030ef          	jal	47c0 <crc16>
     f1c:	000db903          	ld	s2,0(s11)
     f20:	f42a                	sd	a0,40(sp)
     f22:	85aa                	mv	a1,a0
     f24:	04090463          	beqz	s2,f6c <core_bench_list+0x63c>
     f28:	00843e83          	ld	t4,8(s0)
     f2c:	000e9503          	lh	a0,0(t4)
     f30:	091030ef          	jal	47c0 <crc16>
     f34:	00093983          	ld	s3,0(s2)
     f38:	f42a                	sd	a0,40(sp)
     f3a:	85aa                	mv	a1,a0
     f3c:	02098863          	beqz	s3,f6c <core_bench_list+0x63c>
     f40:	00843f03          	ld	t5,8(s0)
     f44:	000f1503          	lh	a0,0(t5)
     f48:	079030ef          	jal	47c0 <crc16>
     f4c:	0009bd03          	ld	s10,0(s3)
     f50:	f42a                	sd	a0,40(sp)
     f52:	85aa                	mv	a1,a0
     f54:	000d0c63          	beqz	s10,f6c <core_bench_list+0x63c>
     f58:	6408                	ld	a0,8(s0)
     f5a:	00051503          	lh	a0,0(a0)
     f5e:	063030ef          	jal	47c0 <crc16>
     f62:	000d3c83          	ld	s9,0(s10)
     f66:	f42a                	sd	a0,40(sp)
     f68:	f40c95e3          	bnez	s9,eb2 <core_bench_list+0x582>
     f6c:	64aa                	ld	s1,136(sp)
     f6e:	644a                	ld	s0,144(sp)
     f70:	60ea                	ld	ra,152(sp)
     f72:	7522                	ld	a0,40(sp)
     f74:	7de2                	ld	s11,56(sp)
     f76:	6d06                	ld	s10,64(sp)
     f78:	6ca6                	ld	s9,72(sp)
     f7a:	6c46                	ld	s8,80(sp)
     f7c:	6be6                	ld	s7,88(sp)
     f7e:	7b06                	ld	s6,96(sp)
     f80:	7aa6                	ld	s5,104(sp)
     f82:	7a46                	ld	s4,112(sp)
     f84:	79e6                	ld	s3,120(sp)
     f86:	690a                	ld	s2,128(sp)
     f88:	610d                	addi	sp,sp,160
     f8a:	8082                	ret
     f8c:	8ab6                	mv	s5,a3
     f8e:	c60a15e3          	bnez	s4,bf8 <core_bench_list+0x2c8>
     f92:	bdad                	j	e0c <core_bench_list+0x4dc>
     f94:	841e                	mv	s0,t2
     f96:	b391                	j	cda <core_bench_list+0x3aa>
     f98:	000a3403          	ld	s0,0(s4)
     f9c:	b6041de3          	bnez	s0,b16 <core_bench_list+0x1e6>
     fa0:	b925                	j	bd8 <core_bench_list+0x2a8>
     fa2:	4905                	li	s2,1
     fa4:	e60a0fe3          	beqz	s4,e22 <core_bench_list+0x4f2>
     fa8:	4981                	li	s3,0
     faa:	4d81                	li	s11,0
     fac:	e802                	sd	zero,16(sp)
     fae:	0001                	nop
     fb0:	6e42                	ld	t3,16(sp)
     fb2:	4c01                	li	s8,0
     fb4:	8f52                	mv	t5,s4
     fb6:	001e0d1b          	addiw	s10,t3,1
     fba:	e86a                	sd	s10,16(sp)
     fbc:	00000013          	nop
     fc0:	012c5763          	bge	s8,s2,fce <core_bench_list+0x69e>
     fc4:	000f3f03          	ld	t5,0(t5)
     fc8:	2c05                	addiw	s8,s8,1
     fca:	fe0f1be3          	bnez	t5,fc0 <core_bench_list+0x690>
     fce:	040c8693          	addi	a3,s9,64
     fd2:	e436                	sd	a3,8(sp)
     fd4:	8d6e                	mv	s10,s11
     fd6:	8b4a                	mv	s6,s2
     fd8:	8dd2                	mv	s11,s4
     fda:	8a7a                	mv	s4,t5
     fdc:	0d805963          	blez	s8,10ae <core_bench_list+0x77e>
     fe0:	240b0c63          	beqz	s6,1238 <core_bench_list+0x908>
     fe4:	280a0a63          	beqz	s4,1278 <core_bench_list+0x948>
     fe8:	008dba83          	ld	s5,8(s11)
     fec:	008a3483          	ld	s1,8(s4)
     ff0:	000a9403          	lh	s0,0(s5)
     ff4:	08047893          	andi	a7,s0,128
     ff8:	07f47b93          	andi	s7,s0,127
     ffc:	04089363          	bnez	a7,1042 <core_bench_list+0x712>
    1000:	1834380b          	th.extu	a6,s0,6,3
    1004:	0048151b          	slliw	a0,a6,0x4
    1008:	01050fb3          	add	t6,a0,a6
    100c:	00747713          	andi	a4,s0,7
    1010:	85fe                	mv	a1,t6
    1012:	2e070563          	beqz	a4,12fc <core_bench_list+0x9cc>
    1016:	4685                	li	a3,1
    1018:	2cd70463          	beq	a4,a3,12e0 <core_bench_list+0x9b0>
    101c:	3c04350b          	th.extu	a0,s0,15,0
    1020:	8ba2                	mv	s7,s0
    1022:	060cd583          	lhu	a1,96(s9)
    1026:	07fbfb93          	andi	s7,s7,127
    102a:	286030ef          	jal	42b0 <crcu16>
    102e:	f0047793          	andi	a5,s0,-256
    1032:	00fbe333          	or	t1,s7,a5
    1036:	06ac9023          	sh	a0,96(s9)
    103a:	08036e93          	ori	t4,t1,128
    103e:	01da9023          	sh	t4,0(s5)
    1042:	00049a83          	lh	s5,0(s1)
    1046:	080af293          	andi	t0,s5,128
    104a:	07faff13          	andi	t5,s5,127
    104e:	04029363          	bnez	t0,1094 <core_bench_list+0x764>
    1052:	183ab60b          	th.extu	a2,s5,6,3
    1056:	0046141b          	slliw	s0,a2,0x4
    105a:	00c408b3          	add	a7,s0,a2
    105e:	007af393          	andi	t2,s5,7
    1062:	85c6                	mv	a1,a7
    1064:	24038263          	beqz	t2,12a8 <core_bench_list+0x978>
    1068:	4505                	li	a0,1
    106a:	22a38163          	beq	t2,a0,128c <core_bench_list+0x95c>
    106e:	3c0ab50b          	th.extu	a0,s5,15,0
    1072:	8456                	mv	s0,s5
    1074:	060cd583          	lhu	a1,96(s9)
    1078:	238030ef          	jal	42b0 <crcu16>
    107c:	07f47f13          	andi	t5,s0,127
    1080:	f00af693          	andi	a3,s5,-256
    1084:	00df65b3          	or	a1,t5,a3
    1088:	06ac9023          	sh	a0,96(s9)
    108c:	0805e793          	ori	a5,a1,128
    1090:	00f49023          	sh	a5,0(s1)
    1094:	1f7f5263          	bge	t5,s7,1278 <core_bench_list+0x948>
    1098:	84d2                	mv	s1,s4
    109a:	3b7d                	addiw	s6,s6,-1
    109c:	000a3a03          	ld	s4,0(s4)
    10a0:	1e0d0263          	beqz	s10,1284 <core_bench_list+0x954>
    10a4:	009d3023          	sd	s1,0(s10)
    10a8:	8d26                	mv	s10,s1
    10aa:	f3804be3          	bgtz	s8,fe0 <core_bench_list+0x6b0>
    10ae:	2d605363          	blez	s6,1374 <core_bench_list+0xa44>
    10b2:	1a0a0963          	beqz	s4,1264 <core_bench_list+0x934>
    10b6:	f20c19e3          	bnez	s8,fe8 <core_bench_list+0x6b8>
    10ba:	fffb0c1b          	addiw	s8,s6,-1
    10be:	007c7593          	andi	a1,s8,7
    10c2:	c1e9                	beqz	a1,1184 <core_bench_list+0x854>
    10c4:	000a3303          	ld	t1,0(s4)
    10c8:	3b7d                	addiw	s6,s6,-1
    10ca:	280d0263          	beqz	s10,134e <core_bench_list+0xa1e>
    10ce:	014d3023          	sd	s4,0(s10)
    10d2:	8d52                	mv	s10,s4
    10d4:	18030863          	beqz	t1,1264 <core_bench_list+0x934>
    10d8:	4285                	li	t0,1
    10da:	8a1a                	mv	s4,t1
    10dc:	00058e9b          	sext.w	t4,a1
    10e0:	0a558263          	beq	a1,t0,1184 <core_bench_list+0x854>
    10e4:	4609                	li	a2,2
    10e6:	08ce8463          	beq	t4,a2,116e <core_bench_list+0x83e>
    10ea:	438d                	li	t2,3
    10ec:	067e8663          	beq	t4,t2,1158 <core_bench_list+0x828>
    10f0:	4411                	li	s0,4
    10f2:	048e8863          	beq	t4,s0,1142 <core_bench_list+0x812>
    10f6:	4895                	li	a7,5
    10f8:	031e8a63          	beq	t4,a7,112c <core_bench_list+0x7fc>
    10fc:	4499                	li	s1,6
    10fe:	009e8c63          	beq	t4,s1,1116 <core_bench_list+0x7e6>
    1102:	00033a03          	ld	s4,0(t1)
    1106:	3b7d                	addiw	s6,s6,-1
    1108:	260d0463          	beqz	s10,1370 <core_bench_list+0xa40>
    110c:	006d3023          	sd	t1,0(s10)
    1110:	8d1a                	mv	s10,t1
    1112:	140a0963          	beqz	s4,1264 <core_bench_list+0x934>
    1116:	000a3703          	ld	a4,0(s4)
    111a:	3b7d                	addiw	s6,s6,-1
    111c:	240d0363          	beqz	s10,1362 <core_bench_list+0xa32>
    1120:	014d3023          	sd	s4,0(s10)
    1124:	8d52                	mv	s10,s4
    1126:	12070f63          	beqz	a4,1264 <core_bench_list+0x934>
    112a:	8a3a                	mv	s4,a4
    112c:	000a3803          	ld	a6,0(s4)
    1130:	3b7d                	addiw	s6,s6,-1
    1132:	220d0663          	beqz	s10,135e <core_bench_list+0xa2e>
    1136:	014d3023          	sd	s4,0(s10)
    113a:	8d52                	mv	s10,s4
    113c:	12080463          	beqz	a6,1264 <core_bench_list+0x934>
    1140:	8a42                	mv	s4,a6
    1142:	000a3503          	ld	a0,0(s4)
    1146:	3b7d                	addiw	s6,s6,-1
    1148:	200d0963          	beqz	s10,135a <core_bench_list+0xa2a>
    114c:	014d3023          	sd	s4,0(s10)
    1150:	8d52                	mv	s10,s4
    1152:	10050963          	beqz	a0,1264 <core_bench_list+0x934>
    1156:	8a2a                	mv	s4,a0
    1158:	000a3f83          	ld	t6,0(s4)
    115c:	3b7d                	addiw	s6,s6,-1
    115e:	1e0d0c63          	beqz	s10,1356 <core_bench_list+0xa26>
    1162:	014d3023          	sd	s4,0(s10)
    1166:	8d52                	mv	s10,s4
    1168:	0e0f8e63          	beqz	t6,1264 <core_bench_list+0x934>
    116c:	8a7e                	mv	s4,t6
    116e:	000a3a83          	ld	s5,0(s4)
    1172:	3b7d                	addiw	s6,s6,-1
    1174:	1c0d0f63          	beqz	s10,1352 <core_bench_list+0xa22>
    1178:	014d3023          	sd	s4,0(s10)
    117c:	8d52                	mv	s10,s4
    117e:	0e0a8363          	beqz	s5,1264 <core_bench_list+0x934>
    1182:	8a56                	mv	s4,s5
    1184:	000a3b83          	ld	s7,0(s4)
    1188:	3b7d                	addiw	s6,s6,-1
    118a:	0a0d0563          	beqz	s10,1234 <core_bench_list+0x904>
    118e:	014d3023          	sd	s4,0(s10)
    1192:	1c0b0a63          	beqz	s6,1366 <core_bench_list+0xa36>
    1196:	8d52                	mv	s10,s4
    1198:	0c0b8663          	beqz	s7,1264 <core_bench_list+0x934>
    119c:	000bbf03          	ld	t5,0(s7)
    11a0:	fffb0e1b          	addiw	t3,s6,-1
    11a4:	180a0763          	beqz	s4,1332 <core_bench_list+0xa02>
    11a8:	017a3023          	sd	s7,0(s4)
    11ac:	8d5e                	mv	s10,s7
    11ae:	0a0f0b63          	beqz	t5,1264 <core_bench_list+0x934>
    11b2:	000f3683          	ld	a3,0(t5)
    11b6:	fffe0d9b          	addiw	s11,t3,-1
    11ba:	160b8e63          	beqz	s7,1336 <core_bench_list+0xa06>
    11be:	01ebb023          	sd	t5,0(s7)
    11c2:	8d7a                	mv	s10,t5
    11c4:	c2c5                	beqz	a3,1264 <core_bench_list+0x934>
    11c6:	628c                	ld	a1,0(a3)
    11c8:	fffd8c1b          	addiw	s8,s11,-1
    11cc:	160f0763          	beqz	t5,133a <core_bench_list+0xa0a>
    11d0:	00df3023          	sd	a3,0(t5)
    11d4:	8d36                	mv	s10,a3
    11d6:	c5d9                	beqz	a1,1264 <core_bench_list+0x934>
    11d8:	0005b303          	ld	t1,0(a1)
    11dc:	fffc079b          	addiw	a5,s8,-1
    11e0:	14068f63          	beqz	a3,133e <core_bench_list+0xa0e>
    11e4:	e28c                	sd	a1,0(a3)
    11e6:	8d2e                	mv	s10,a1
    11e8:	06030e63          	beqz	t1,1264 <core_bench_list+0x934>
    11ec:	00033283          	ld	t0,0(t1)
    11f0:	fff78e9b          	addiw	t4,a5,-1
    11f4:	14058763          	beqz	a1,1342 <core_bench_list+0xa12>
    11f8:	0065b023          	sd	t1,0(a1)
    11fc:	8d1a                	mv	s10,t1
    11fe:	06028363          	beqz	t0,1264 <core_bench_list+0x934>
    1202:	0002b603          	ld	a2,0(t0)
    1206:	fffe839b          	addiw	t2,t4,-1
    120a:	14030063          	beqz	t1,134a <core_bench_list+0xa1a>
    120e:	00533023          	sd	t0,0(t1)
    1212:	8d16                	mv	s10,t0
    1214:	ca21                	beqz	a2,1264 <core_bench_list+0x934>
    1216:	6200                	ld	s0,0(a2)
    1218:	fff38b1b          	addiw	s6,t2,-1
    121c:	12028563          	beqz	t0,1346 <core_bench_list+0xa16>
    1220:	00c2b023          	sd	a2,0(t0)
    1224:	8d32                	mv	s10,a2
    1226:	cc1d                	beqz	s0,1264 <core_bench_list+0x934>
    1228:	8a22                	mv	s4,s0
    122a:	000a3b83          	ld	s7,0(s4)
    122e:	3b7d                	addiw	s6,s6,-1
    1230:	f40d1fe3          	bnez	s10,118e <core_bench_list+0x85e>
    1234:	89d2                	mv	s3,s4
    1236:	bfb1                	j	1192 <core_bench_list+0x862>
    1238:	000dbb03          	ld	s6,0(s11)
    123c:	3c7d                	addiw	s8,s8,-1
    123e:	000d0d63          	beqz	s10,1258 <core_bench_list+0x928>
    1242:	01bd3023          	sd	s11,0(s10)
    1246:	000c0c63          	beqz	s8,125e <core_bench_list+0x92e>
    124a:	8d6e                	mv	s10,s11
    124c:	8dda                	mv	s11,s6
    124e:	000dbb03          	ld	s6,0(s11)
    1252:	3c7d                	addiw	s8,s8,-1
    1254:	fe0d17e3          	bnez	s10,1242 <core_bench_list+0x912>
    1258:	89ee                	mv	s3,s11
    125a:	fe0c18e3          	bnez	s8,124a <core_bench_list+0x91a>
    125e:	d40a19e3          	bnez	s4,fb0 <core_bench_list+0x680>
    1262:	8d6e                	mv	s10,s11
    1264:	6dc2                	ld	s11,16(sp)
    1266:	4a05                	li	s4,1
    1268:	000d3023          	sd	zero,0(s10)
    126c:	114d8863          	beq	s11,s4,137c <core_bench_list+0xa4c>
    1270:	0019191b          	slliw	s2,s2,0x1
    1274:	8a4e                	mv	s4,s3
    1276:	b33d                	j	fa4 <core_bench_list+0x674>
    1278:	84ee                	mv	s1,s11
    127a:	3c7d                	addiw	s8,s8,-1
    127c:	000dbd83          	ld	s11,0(s11)
    1280:	e20d12e3          	bnez	s10,10a4 <core_bench_list+0x774>
    1284:	89a6                	mv	s3,s1
    1286:	8d26                	mv	s10,s1
    1288:	b50d                	j	10aa <core_bench_list+0x77a>
    128a:	0001                	nop
    128c:	060cd603          	lhu	a2,96(s9)
    1290:	6522                	ld	a0,8(sp)
    1292:	6ce010ef          	jal	2960 <core_bench_matrix>
    1296:	064cde03          	lhu	t3,100(s9)
    129a:	000e1463          	bnez	t3,12a2 <core_bench_list+0x972>
    129e:	06ac9223          	sh	a0,100(s9)
    12a2:	3c05240b          	th.ext	s0,a0,15,0
    12a6:	b3f9                	j	1074 <core_bench_list+0x744>
    12a8:	02100713          	li	a4,33
    12ac:	060cd783          	lhu	a5,96(s9)
    12b0:	002c9683          	lh	a3,2(s9)
    12b4:	000c9603          	lh	a2,0(s9)
    12b8:	028ca503          	lw	a0,40(s9)
    12bc:	020cb583          	ld	a1,32(s9)
    12c0:	01173833          	sltu	a6,a4,a7
    12c4:	02200713          	li	a4,34
    12c8:	4308970b          	th.mvnez	a4,a7,a6
    12cc:	174020ef          	jal	3440 <core_bench_state>
    12d0:	066cdf83          	lhu	t6,102(s9)
    12d4:	fc0f97e3          	bnez	t6,12a2 <core_bench_list+0x972>
    12d8:	06ac9323          	sh	a0,102(s9)
    12dc:	b7d9                	j	12a2 <core_bench_list+0x972>
    12de:	0001                	nop
    12e0:	060cd603          	lhu	a2,96(s9)
    12e4:	6522                	ld	a0,8(sp)
    12e6:	67a010ef          	jal	2960 <core_bench_matrix>
    12ea:	064cd583          	lhu	a1,100(s9)
    12ee:	e199                	bnez	a1,12f4 <core_bench_list+0x9c4>
    12f0:	06ac9223          	sh	a0,100(s9)
    12f4:	3c052b8b          	th.ext	s7,a0,15,0
    12f8:	b32d                	j	1022 <core_bench_list+0x6f2>
    12fa:	0001                	nop
    12fc:	060cd783          	lhu	a5,96(s9)
    1300:	002c9683          	lh	a3,2(s9)
    1304:	000c9603          	lh	a2,0(s9)
    1308:	028ca503          	lw	a0,40(s9)
    130c:	020cb583          	ld	a1,32(s9)
    1310:	02100b93          	li	s7,33
    1314:	01fbbe33          	sltu	t3,s7,t6
    1318:	02200713          	li	a4,34
    131c:	43cf970b          	th.mvnez	a4,t6,t3
    1320:	120020ef          	jal	3440 <core_bench_state>
    1324:	066cdf03          	lhu	t5,102(s9)
    1328:	fc0f16e3          	bnez	t5,12f4 <core_bench_list+0x9c4>
    132c:	06ac9323          	sh	a0,102(s9)
    1330:	b7d1                	j	12f4 <core_bench_list+0x9c4>
    1332:	89de                	mv	s3,s7
    1334:	bda5                	j	11ac <core_bench_list+0x87c>
    1336:	89fa                	mv	s3,t5
    1338:	b569                	j	11c2 <core_bench_list+0x892>
    133a:	89b6                	mv	s3,a3
    133c:	bd61                	j	11d4 <core_bench_list+0x8a4>
    133e:	89ae                	mv	s3,a1
    1340:	b55d                	j	11e6 <core_bench_list+0x8b6>
    1342:	899a                	mv	s3,t1
    1344:	bd65                	j	11fc <core_bench_list+0x8cc>
    1346:	89b2                	mv	s3,a2
    1348:	bdf1                	j	1224 <core_bench_list+0x8f4>
    134a:	8996                	mv	s3,t0
    134c:	b5d9                	j	1212 <core_bench_list+0x8e2>
    134e:	89d2                	mv	s3,s4
    1350:	b349                	j	10d2 <core_bench_list+0x7a2>
    1352:	89d2                	mv	s3,s4
    1354:	b525                	j	117c <core_bench_list+0x84c>
    1356:	89d2                	mv	s3,s4
    1358:	b539                	j	1166 <core_bench_list+0x836>
    135a:	89d2                	mv	s3,s4
    135c:	bbd5                	j	1150 <core_bench_list+0x820>
    135e:	89d2                	mv	s3,s4
    1360:	bbe9                	j	113a <core_bench_list+0x80a>
    1362:	89d2                	mv	s3,s4
    1364:	b3c1                	j	1124 <core_bench_list+0x7f4>
    1366:	8dd2                	mv	s11,s4
    1368:	8a5e                	mv	s4,s7
    136a:	c40a13e3          	bnez	s4,fb0 <core_bench_list+0x680>
    136e:	bdd5                	j	1262 <core_bench_list+0x932>
    1370:	899a                	mv	s3,t1
    1372:	bb79                	j	1110 <core_bench_list+0x7e0>
    1374:	8dea                	mv	s11,s10
    1376:	c20a1de3          	bnez	s4,fb0 <core_bench_list+0x680>
    137a:	b5e5                	j	1262 <core_bench_list+0x932>
    137c:	8a4e                	mv	s4,s3
    137e:	f52ff06f          	j	ad0 <core_bench_list+0x1a0>
    1382:	ec2e                	sd	a1,24(sp)
    1384:	f402                	sd	zero,40(sp)
    1386:	f46ff06f          	j	acc <core_bench_list+0x19c>
    138a:	000a0b63          	beqz	s4,13a0 <core_bench_list+0xa70>
    138e:	872e                	mv	a4,a1
    1390:	87d2                	mv	a5,s4
    1392:	4501                	li	a0,0
    1394:	4e81                	li	t4,0
    1396:	4301                	li	t1,0
    1398:	4881                	li	a7,0
    139a:	4581                	li	a1,0
    139c:	ee4ff06f          	j	a80 <core_bench_list+0x150>
    13a0:	00003783          	ld	a5,0(zero) # 0 <__start>
    13a4:	9002                	ebreak
    13a6:	00000013          	nop
    13aa:	00000013          	nop
    13ae:	0001                	nop

00000000000013b0 <core_list_init>:
    13b0:	47d1                	li	a5,20
    13b2:	02f5553b          	divuw	a0,a0,a5
    13b6:	86ae                	mv	a3,a1
    13b8:	6721                	lui	a4,0x8
    13ba:	08070393          	addi	t2,a4,128 # 8080 <_ftoa+0xf70>
    13be:	8eb2                	mv	t4,a2
    13c0:	01068713          	addi	a4,a3,16
    13c4:	ffe50f9b          	addiw	t6,a0,-2
    13c8:	7c0fbf0b          	th.extu	t5,t6,31,0
    13cc:	004f1293          	slli	t0,t5,0x4
    13d0:	00558833          	add	a6,a1,t0
    13d4:	0006b023          	sd	zero,0(a3)
    13d8:	0106b423          	sd	a6,8(a3)
    13dc:	02058593          	addi	a1,a1,32
    13e0:	4056d38b          	th.srw	t2,a3,t0,0
    13e4:	837e                	mv	t1,t6
    13e6:	05e81f0b          	th.addsl	t5,a6,t5,2
    13ea:	00480613          	addi	a2,a6,4
    13ee:	3505f763          	bgeu	a1,a6,173c <core_list_init+0x38c>
    13f2:	00880893          	addi	a7,a6,8
    13f6:	35e8f363          	bgeu	a7,t5,173c <core_list_init+0x38c>
    13fa:	80000e37          	lui	t3,0x80000
    13fe:	fffe0793          	addi	a5,t3,-1 # ffffffff7fffffff <__kernel_stack+0xffffffff7ff11fff>
    1402:	e298                	sd	a4,0(a3)
    1404:	0006b823          	sd	zero,16(a3)
    1408:	ee90                	sd	a2,24(a3)
    140a:	00f82223          	sw	a5,4(a6)
    140e:	8646                	mv	a2,a7
    1410:	87ba                	mv	a5,a4
    1412:	872e                	mv	a4,a1
    1414:	040f8d63          	beqz	t6,146e <core_list_init+0xbe>
    1418:	01070893          	addi	a7,a4,16
    141c:	3c0eb38b          	th.extu	t2,t4,15,0
    1420:	4581                	li	a1,0
    1422:	62a1                	lui	t0,0x8
    1424:	32fd                	addiw	t0,t0,-1 # 7fff <_ftoa+0xeef>
    1426:	0508f463          	bgeu	a7,a6,146e <core_list_init+0xbe>
    142a:	00460e13          	addi	t3,a2,4
    142e:	31ee7963          	bgeu	t3,t5,1740 <core_list_init+0x390>
    1432:	3c05b50b          	th.extu	a0,a1,15,0
    1436:	e31c                	sd	a5,0(a4)
    1438:	00a3c7b3          	xor	a5,t2,a0
    143c:	0037979b          	slliw	a5,a5,0x3
    1440:	891d                	andi	a0,a0,7
    1442:	0787f793          	andi	a5,a5,120
    1446:	8fc9                	or	a5,a5,a0
    1448:	e298                	sd	a4,0(a3)
    144a:	0087951b          	slliw	a0,a5,0x8
    144e:	e710                	sd	a2,8(a4)
    1450:	9fa9                	addw	a5,a5,a0
    1452:	2585                	addiw	a1,a1,1
    1454:	00f61023          	sh	a5,0(a2)
    1458:	00561123          	sh	t0,2(a2)
    145c:	2cbf8c63          	beq	t6,a1,1734 <core_list_init+0x384>
    1460:	87ba                	mv	a5,a4
    1462:	8746                	mv	a4,a7
    1464:	01070893          	addi	a7,a4,16
    1468:	8672                	mv	a2,t3
    146a:	fd08e0e3          	bltu	a7,a6,142a <core_list_init+0x7a>
    146e:	6390                	ld	a2,0(a5)
    1470:	ca29                	beqz	a2,14c2 <core_list_init+0x112>
    1472:	4f95                	li	t6,5
    1474:	03f3533b          	divuw	t1,t1,t6
    1478:	4f05                	li	t5,1
    147a:	4509                	li	a0,2
    147c:	006f7f63          	bgeu	t5,t1,149a <core_list_init+0xea>
    1480:	6798                	ld	a4,8(a5)
    1482:	00063883          	ld	a7,0(a2)
    1486:	2505                	addiw	a0,a0,1
    1488:	01e71123          	sh	t5,2(a4)
    148c:	2f05                	addiw	t5,t5,1
    148e:	02088a63          	beqz	a7,14c2 <core_list_init+0x112>
    1492:	87b2                	mv	a5,a2
    1494:	8646                	mv	a2,a7
    1496:	fe6f65e3          	bltu	t5,t1,1480 <core_list_init+0xd0>
    149a:	0085129b          	slliw	t0,a0,0x8
    149e:	0087b383          	ld	t2,8(a5)
    14a2:	01df4833          	xor	a6,t5,t4
    14a6:	7002f793          	andi	a5,t0,1792
    14aa:	0107e5b3          	or	a1,a5,a6
    14ae:	00063883          	ld	a7,0(a2)
    14b2:	3405be0b          	th.extu	t3,a1,13,0
    14b6:	01c39123          	sh	t3,2(t2)
    14ba:	2f05                	addiw	t5,t5,1
    14bc:	2505                	addiw	a0,a0,1
    14be:	fc089ae3          	bnez	a7,1492 <core_list_init+0xe2>
    14c2:	4e85                	li	t4,1
    14c4:	4501                	li	a0,0
    14c6:	4601                	li	a2,0
    14c8:	4f01                	li	t5,0
    14ca:	8ff6                	mv	t6,t4
    14cc:	00000013          	nop
    14d0:	2f05                	addiw	t5,t5,1
    14d2:	8736                	mv	a4,a3
    14d4:	4781                	li	a5,0
    14d6:	0001                	nop
    14d8:	01d7d563          	bge	a5,t4,14e2 <core_list_init+0x132>
    14dc:	6318                	ld	a4,0(a4)
    14de:	2785                	addiw	a5,a5,1
    14e0:	ff65                	bnez	a4,14d8 <core_list_init+0x128>
    14e2:	8876                	mv	a6,t4
    14e4:	00f05d63          	blez	a5,14fe <core_list_init+0x14e>
    14e8:	06080663          	beqz	a6,1554 <core_list_init+0x1a4>
    14ec:	ef11                	bnez	a4,1508 <core_list_init+0x158>
    14ee:	85b6                	mv	a1,a3
    14f0:	37fd                	addiw	a5,a5,-1
    14f2:	6294                	ld	a3,0(a3)
    14f4:	ce21                	beqz	a2,154c <core_list_init+0x19c>
    14f6:	e20c                	sd	a1,0(a2)
    14f8:	862e                	mv	a2,a1
    14fa:	fef047e3          	bgtz	a5,14e8 <core_list_init+0x138>
    14fe:	23005d63          	blez	a6,1738 <core_list_init+0x388>
    1502:	1c070763          	beqz	a4,16d0 <core_list_init+0x320>
    1506:	cbbd                	beqz	a5,157c <core_list_init+0x1cc>
    1508:	0086b303          	ld	t1,8(a3)
    150c:	00031583          	lh	a1,0(t1)
    1510:	f005f893          	andi	a7,a1,-256
    1514:	3c85b38b          	th.extu	t2,a1,15,8
    1518:	0078e2b3          	or	t0,a7,t2
    151c:	00873883          	ld	a7,8(a4)
    1520:	00531023          	sh	t0,0(t1)
    1524:	00231303          	lh	t1,2(t1)
    1528:	00089583          	lh	a1,0(a7)
    152c:	f005fe13          	andi	t3,a1,-256
    1530:	3c85b38b          	th.extu	t2,a1,15,8
    1534:	007e62b3          	or	t0,t3,t2
    1538:	00589023          	sh	t0,0(a7)
    153c:	00289883          	lh	a7,2(a7)
    1540:	fa68d7e3          	bge	a7,t1,14ee <core_list_init+0x13e>
    1544:	85ba                	mv	a1,a4
    1546:	387d                	addiw	a6,a6,-1
    1548:	6318                	ld	a4,0(a4)
    154a:	f655                	bnez	a2,14f6 <core_list_init+0x146>
    154c:	852e                	mv	a0,a1
    154e:	862e                	mv	a2,a1
    1550:	b76d                	j	14fa <core_list_init+0x14a>
    1552:	0001                	nop
    1554:	0006b803          	ld	a6,0(a3)
    1558:	37fd                	addiw	a5,a5,-1
    155a:	ca09                	beqz	a2,156c <core_list_init+0x1bc>
    155c:	e214                	sd	a3,0(a2)
    155e:	cb89                	beqz	a5,1570 <core_list_init+0x1c0>
    1560:	8636                	mv	a2,a3
    1562:	86c2                	mv	a3,a6
    1564:	0006b803          	ld	a6,0(a3)
    1568:	37fd                	addiw	a5,a5,-1
    156a:	fa6d                	bnez	a2,155c <core_list_init+0x1ac>
    156c:	8536                	mv	a0,a3
    156e:	fbed                	bnez	a5,1560 <core_list_init+0x1b0>
    1570:	8636                	mv	a2,a3
    1572:	14070f63          	beqz	a4,16d0 <core_list_init+0x320>
    1576:	8636                	mv	a2,a3
    1578:	86ba                	mv	a3,a4
    157a:	bf99                	j	14d0 <core_list_init+0x120>
    157c:	fff8031b          	addiw	t1,a6,-1
    1580:	00737393          	andi	t2,t1,7
    1584:	0a038463          	beqz	t2,162c <core_list_init+0x27c>
    1588:	631c                	ld	a5,0(a4)
    158a:	387d                	addiw	a6,a6,-1
    158c:	18060263          	beqz	a2,1710 <core_list_init+0x360>
    1590:	e218                	sd	a4,0(a2)
    1592:	863a                	mv	a2,a4
    1594:	12078e63          	beqz	a5,16d0 <core_list_init+0x320>
    1598:	4585                	li	a1,1
    159a:	873e                	mv	a4,a5
    159c:	00038e1b          	sext.w	t3,t2
    15a0:	08b38663          	beq	t2,a1,162c <core_list_init+0x27c>
    15a4:	4889                	li	a7,2
    15a6:	071e0a63          	beq	t3,a7,161a <core_list_init+0x26a>
    15aa:	468d                	li	a3,3
    15ac:	04de0f63          	beq	t3,a3,160a <core_list_init+0x25a>
    15b0:	4311                	li	t1,4
    15b2:	046e0263          	beq	t3,t1,15f6 <core_list_init+0x246>
    15b6:	4395                	li	t2,5
    15b8:	027e0763          	beq	t3,t2,15e6 <core_list_init+0x236>
    15bc:	4299                	li	t0,6
    15be:	005e0c63          	beq	t3,t0,15d6 <core_list_init+0x226>
    15c2:	0007be03          	ld	t3,0(a5)
    15c6:	387d                	addiw	a6,a6,-1
    15c8:	16060463          	beqz	a2,1730 <core_list_init+0x380>
    15cc:	e21c                	sd	a5,0(a2)
    15ce:	863e                	mv	a2,a5
    15d0:	8772                	mv	a4,t3
    15d2:	0e0e0f63          	beqz	t3,16d0 <core_list_init+0x320>
    15d6:	631c                	ld	a5,0(a4)
    15d8:	387d                	addiw	a6,a6,-1
    15da:	14060563          	beqz	a2,1724 <core_list_init+0x374>
    15de:	e218                	sd	a4,0(a2)
    15e0:	863a                	mv	a2,a4
    15e2:	873e                	mv	a4,a5
    15e4:	c7f5                	beqz	a5,16d0 <core_list_init+0x320>
    15e6:	630c                	ld	a1,0(a4)
    15e8:	387d                	addiw	a6,a6,-1
    15ea:	12060b63          	beqz	a2,1720 <core_list_init+0x370>
    15ee:	e218                	sd	a4,0(a2)
    15f0:	863a                	mv	a2,a4
    15f2:	872e                	mv	a4,a1
    15f4:	cdf1                	beqz	a1,16d0 <core_list_init+0x320>
    15f6:	00073883          	ld	a7,0(a4)
    15fa:	387d                	addiw	a6,a6,-1
    15fc:	12060063          	beqz	a2,171c <core_list_init+0x36c>
    1600:	e218                	sd	a4,0(a2)
    1602:	863a                	mv	a2,a4
    1604:	8746                	mv	a4,a7
    1606:	0c088563          	beqz	a7,16d0 <core_list_init+0x320>
    160a:	6314                	ld	a3,0(a4)
    160c:	387d                	addiw	a6,a6,-1
    160e:	10060563          	beqz	a2,1718 <core_list_init+0x368>
    1612:	e218                	sd	a4,0(a2)
    1614:	863a                	mv	a2,a4
    1616:	8736                	mv	a4,a3
    1618:	cec5                	beqz	a3,16d0 <core_list_init+0x320>
    161a:	00073303          	ld	t1,0(a4)
    161e:	387d                	addiw	a6,a6,-1
    1620:	ca75                	beqz	a2,1714 <core_list_init+0x364>
    1622:	e218                	sd	a4,0(a2)
    1624:	863a                	mv	a2,a4
    1626:	871a                	mv	a4,t1
    1628:	0a030463          	beqz	t1,16d0 <core_list_init+0x320>
    162c:	00073383          	ld	t2,0(a4)
    1630:	387d                	addiw	a6,a6,-1
    1632:	ca5d                	beqz	a2,16e8 <core_list_init+0x338>
    1634:	e218                	sd	a4,0(a2)
    1636:	0a080c63          	beqz	a6,16ee <core_list_init+0x33e>
    163a:	863a                	mv	a2,a4
    163c:	08038a63          	beqz	t2,16d0 <core_list_init+0x320>
    1640:	0003be03          	ld	t3,0(t2)
    1644:	fff8029b          	addiw	t0,a6,-1
    1648:	c755                	beqz	a4,16f4 <core_list_init+0x344>
    164a:	00773023          	sd	t2,0(a4)
    164e:	861e                	mv	a2,t2
    1650:	080e0063          	beqz	t3,16d0 <core_list_init+0x320>
    1654:	000e3703          	ld	a4,0(t3)
    1658:	fff2879b          	addiw	a5,t0,-1
    165c:	08038e63          	beqz	t2,16f8 <core_list_init+0x348>
    1660:	01c3b023          	sd	t3,0(t2)
    1664:	8672                	mv	a2,t3
    1666:	c72d                	beqz	a4,16d0 <core_list_init+0x320>
    1668:	00073883          	ld	a7,0(a4)
    166c:	fff7859b          	addiw	a1,a5,-1
    1670:	080e0663          	beqz	t3,16fc <core_list_init+0x34c>
    1674:	00ee3023          	sd	a4,0(t3)
    1678:	863a                	mv	a2,a4
    167a:	04088b63          	beqz	a7,16d0 <core_list_init+0x320>
    167e:	0008b683          	ld	a3,0(a7)
    1682:	fff5831b          	addiw	t1,a1,-1
    1686:	cf2d                	beqz	a4,1700 <core_list_init+0x350>
    1688:	01173023          	sd	a7,0(a4)
    168c:	8646                	mv	a2,a7
    168e:	c2a9                	beqz	a3,16d0 <core_list_init+0x320>
    1690:	0006b383          	ld	t2,0(a3)
    1694:	fff3081b          	addiw	a6,t1,-1
    1698:	06088663          	beqz	a7,1704 <core_list_init+0x354>
    169c:	00d8b023          	sd	a3,0(a7)
    16a0:	8636                	mv	a2,a3
    16a2:	02038763          	beqz	t2,16d0 <core_list_init+0x320>
    16a6:	0003be03          	ld	t3,0(t2)
    16aa:	fff8029b          	addiw	t0,a6,-1
    16ae:	cea9                	beqz	a3,1708 <core_list_init+0x358>
    16b0:	0076b023          	sd	t2,0(a3)
    16b4:	861e                	mv	a2,t2
    16b6:	000e0d63          	beqz	t3,16d0 <core_list_init+0x320>
    16ba:	000e3703          	ld	a4,0(t3)
    16be:	fff2881b          	addiw	a6,t0,-1
    16c2:	04038563          	beqz	t2,170c <core_list_init+0x35c>
    16c6:	01c3b023          	sd	t3,0(t2)
    16ca:	8672                	mv	a2,t3
    16cc:	f325                	bnez	a4,162c <core_list_init+0x27c>
    16ce:	0001                	nop
    16d0:	00063023          	sd	zero,0(a2)
    16d4:	05ff0d63          	beq	t5,t6,172e <core_list_init+0x37e>
    16d8:	001e9e9b          	slliw	t4,t4,0x1
    16dc:	c531                	beqz	a0,1728 <core_list_init+0x378>
    16de:	872a                	mv	a4,a0
    16e0:	4681                	li	a3,0
    16e2:	4501                	li	a0,0
    16e4:	4f01                	li	t5,0
    16e6:	bd41                	j	1576 <core_list_init+0x1c6>
    16e8:	853a                	mv	a0,a4
    16ea:	f40818e3          	bnez	a6,163a <core_list_init+0x28a>
    16ee:	86ba                	mv	a3,a4
    16f0:	871e                	mv	a4,t2
    16f2:	bdbd                	j	1570 <core_list_init+0x1c0>
    16f4:	851e                	mv	a0,t2
    16f6:	bfa1                	j	164e <core_list_init+0x29e>
    16f8:	8572                	mv	a0,t3
    16fa:	b7ad                	j	1664 <core_list_init+0x2b4>
    16fc:	853a                	mv	a0,a4
    16fe:	bfad                	j	1678 <core_list_init+0x2c8>
    1700:	8546                	mv	a0,a7
    1702:	b769                	j	168c <core_list_init+0x2dc>
    1704:	8536                	mv	a0,a3
    1706:	bf69                	j	16a0 <core_list_init+0x2f0>
    1708:	851e                	mv	a0,t2
    170a:	b76d                	j	16b4 <core_list_init+0x304>
    170c:	8572                	mv	a0,t3
    170e:	bf75                	j	16ca <core_list_init+0x31a>
    1710:	853a                	mv	a0,a4
    1712:	b541                	j	1592 <core_list_init+0x1e2>
    1714:	853a                	mv	a0,a4
    1716:	b739                	j	1624 <core_list_init+0x274>
    1718:	853a                	mv	a0,a4
    171a:	bded                	j	1614 <core_list_init+0x264>
    171c:	853a                	mv	a0,a4
    171e:	b5d5                	j	1602 <core_list_init+0x252>
    1720:	853a                	mv	a0,a4
    1722:	b5f9                	j	15f0 <core_list_init+0x240>
    1724:	853a                	mv	a0,a4
    1726:	bd6d                	j	15e0 <core_list_init+0x230>
    1728:	00003023          	sd	zero,0(zero) # 0 <__start>
    172c:	9002                	ebreak
    172e:	8082                	ret
    1730:	853e                	mv	a0,a5
    1732:	bd71                	j	15ce <core_list_init+0x21e>
    1734:	87ba                	mv	a5,a4
    1736:	bb25                	j	146e <core_list_init+0xbe>
    1738:	86b2                	mv	a3,a2
    173a:	bd1d                	j	1570 <core_list_init+0x1c0>
    173c:	4781                	li	a5,0
    173e:	b9d9                	j	1414 <core_list_init+0x64>
    1740:	2585                	addiw	a1,a1,1
    1742:	d2bf86e3          	beq	t6,a1,146e <core_list_init+0xbe>
    1746:	88ba                	mv	a7,a4
    1748:	8e32                	mv	t3,a2
    174a:	873e                	mv	a4,a5
    174c:	bb11                	j	1460 <core_list_init+0xb0>
    174e:	0001                	nop

0000000000001750 <core_list_insert_new>:
    1750:	882a                	mv	a6,a0
    1752:	6208                	ld	a0,0(a2)
    1754:	01050893          	addi	a7,a0,16
    1758:	02e8fe63          	bgeu	a7,a4,1794 <core_list_insert_new+0x44>
    175c:	6298                	ld	a4,0(a3)
    175e:	00470313          	addi	t1,a4,4
    1762:	02f37963          	bgeu	t1,a5,1794 <core_list_insert_new+0x44>
    1766:	01163023          	sd	a7,0(a2)
    176a:	00083783          	ld	a5,0(a6)
    176e:	00059283          	lh	t0,0(a1)
    1772:	00259583          	lh	a1,2(a1)
    1776:	e11c                	sd	a5,0(a0)
    1778:	00a83023          	sd	a0,0(a6)
    177c:	e518                	sd	a4,8(a0)
    177e:	0006b383          	ld	t2,0(a3)
    1782:	00438613          	addi	a2,t2,4
    1786:	e290                	sd	a2,0(a3)
    1788:	6514                	ld	a3,8(a0)
    178a:	00569023          	sh	t0,0(a3)
    178e:	00b69123          	sh	a1,2(a3)
    1792:	8082                	ret
    1794:	4501                	li	a0,0
    1796:	8082                	ret
    1798:	00000013          	nop
    179c:	00000013          	nop

00000000000017a0 <core_list_remove>:
    17a0:	87aa                	mv	a5,a0
    17a2:	f8e7c50b          	th.ldd	a0,a4,(a5),0,4
    17a6:	6514                	ld	a3,8(a0)
    17a8:	00053283          	ld	t0,0(a0)
    17ac:	e794                	sd	a3,8(a5)
    17ae:	e518                	sd	a4,8(a0)
    17b0:	0057b023          	sd	t0,0(a5)
    17b4:	00053023          	sd	zero,0(a0)
    17b8:	8082                	ret
    17ba:	00000013          	nop
    17be:	0001                	nop

00000000000017c0 <core_list_undo_remove>:
    17c0:	6594                	ld	a3,8(a1)
    17c2:	6518                	ld	a4,8(a0)
    17c4:	0005b283          	ld	t0,0(a1)
    17c8:	e514                	sd	a3,8(a0)
    17ca:	e598                	sd	a4,8(a1)
    17cc:	00553023          	sd	t0,0(a0)
    17d0:	e188                	sd	a0,0(a1)
    17d2:	8082                	ret
    17d4:	00000013          	nop
    17d8:	00000013          	nop
    17dc:	00000013          	nop

00000000000017e0 <core_list_find>:
    17e0:	00259603          	lh	a2,2(a1)
    17e4:	00064e63          	bltz	a2,1800 <core_list_find+0x20>
    17e8:	e501                	bnez	a0,17f0 <core_list_find+0x10>
    17ea:	8082                	ret
    17ec:	6108                	ld	a0,0(a0)
    17ee:	c50d                	beqz	a0,1818 <core_list_find+0x38>
    17f0:	00853303          	ld	t1,8(a0)
    17f4:	00231383          	lh	t2,2(t1)
    17f8:	fec39ae3          	bne	t2,a2,17ec <core_list_find+0xc>
    17fc:	8082                	ret
    17fe:	0001                	nop
    1800:	cd01                	beqz	a0,1818 <core_list_find+0x38>
    1802:	00059703          	lh	a4,0(a1)
    1806:	a019                	j	180c <core_list_find+0x2c>
    1808:	6108                	ld	a0,0(a0)
    180a:	c901                	beqz	a0,181a <core_list_find+0x3a>
    180c:	651c                	ld	a5,8(a0)
    180e:	0007c283          	lbu	t0,0(a5)
    1812:	fee29be3          	bne	t0,a4,1808 <core_list_find+0x28>
    1816:	8082                	ret
    1818:	4501                	li	a0,0
    181a:	8082                	ret
    181c:	00000013          	nop

0000000000001820 <core_list_reverse>:
    1820:	c53d                	beqz	a0,188e <core_list_reverse+0x6e>
    1822:	611c                	ld	a5,0(a0)
    1824:	4801                	li	a6,0
    1826:	01053023          	sd	a6,0(a0)
    182a:	86aa                	mv	a3,a0
    182c:	c3ad                	beqz	a5,188e <core_list_reverse+0x6e>
    182e:	6398                	ld	a4,0(a5)
    1830:	e394                	sd	a3,0(a5)
    1832:	853e                	mv	a0,a5
    1834:	cf31                	beqz	a4,1890 <core_list_reverse+0x70>
    1836:	00073283          	ld	t0,0(a4)
    183a:	e31c                	sd	a5,0(a4)
    183c:	853a                	mv	a0,a4
    183e:	04028863          	beqz	t0,188e <core_list_reverse+0x6e>
    1842:	0002b303          	ld	t1,0(t0)
    1846:	00e2b023          	sd	a4,0(t0)
    184a:	8516                	mv	a0,t0
    184c:	04030163          	beqz	t1,188e <core_list_reverse+0x6e>
    1850:	00033383          	ld	t2,0(t1)
    1854:	00533023          	sd	t0,0(t1)
    1858:	851a                	mv	a0,t1
    185a:	02038a63          	beqz	t2,188e <core_list_reverse+0x6e>
    185e:	0003b583          	ld	a1,0(t2)
    1862:	0063b023          	sd	t1,0(t2)
    1866:	851e                	mv	a0,t2
    1868:	c19d                	beqz	a1,188e <core_list_reverse+0x6e>
    186a:	6190                	ld	a2,0(a1)
    186c:	0075b023          	sd	t2,0(a1)
    1870:	852e                	mv	a0,a1
    1872:	ce11                	beqz	a2,188e <core_list_reverse+0x6e>
    1874:	00063883          	ld	a7,0(a2)
    1878:	e20c                	sd	a1,0(a2)
    187a:	8532                	mv	a0,a2
    187c:	8832                	mv	a6,a2
    187e:	00088863          	beqz	a7,188e <core_list_reverse+0x6e>
    1882:	8546                	mv	a0,a7
    1884:	611c                	ld	a5,0(a0)
    1886:	01053023          	sd	a6,0(a0)
    188a:	86aa                	mv	a3,a0
    188c:	f3cd                	bnez	a5,182e <core_list_reverse+0xe>
    188e:	8082                	ret
    1890:	8082                	ret
    1892:	0001                	nop
    1894:	00000013          	nop
    1898:	00000013          	nop
    189c:	00000013          	nop

00000000000018a0 <core_list_mergesort>:
    18a0:	711d                	addi	sp,sp,-96
    18a2:	ff315a0b          	th.sdd	s4,s3,(sp),3,4
    18a6:	fd515b0b          	th.sdd	s6,s5,(sp),2,4
    18aa:	fb715c0b          	th.sdd	s8,s7,(sp),1,4
    18ae:	f9915d0b          	th.sdd	s10,s9,(sp),0,4
    18b2:	4a05                	li	s4,1
    18b4:	e0ca                	sd	s2,64(sp)
    18b6:	e4a6                	sd	s1,72(sp)
    18b8:	e8a2                	sd	s0,80(sp)
    18ba:	ec86                	sd	ra,88(sp)
    18bc:	89aa                	mv	s3,a0
    18be:	8bae                	mv	s7,a1
    18c0:	8b32                	mv	s6,a2
    18c2:	8cd2                	mv	s9,s4
    18c4:	0a098763          	beqz	s3,1972 <core_list_mergesort+0xd2>
    18c8:	4c01                	li	s8,0
    18ca:	4481                	li	s1,0
    18cc:	4a81                	li	s5,0
    18ce:	0001                	nop
    18d0:	2c05                	addiw	s8,s8,1
    18d2:	87ce                	mv	a5,s3
    18d4:	4401                	li	s0,0
    18d6:	0001                	nop
    18d8:	01445563          	bge	s0,s4,18e2 <core_list_mergesort+0x42>
    18dc:	639c                	ld	a5,0(a5)
    18de:	2405                	addiw	s0,s0,1
    18e0:	ffe5                	bnez	a5,18d8 <core_list_mergesort+0x38>
    18e2:	8926                	mv	s2,s1
    18e4:	8d52                	mv	s10,s4
    18e6:	84ce                	mv	s1,s3
    18e8:	89be                	mv	s3,a5
    18ea:	02805163          	blez	s0,190c <core_list_mergesort+0x6c>
    18ee:	0001                	nop
    18f0:	040d0463          	beqz	s10,1938 <core_list_mergesort+0x98>
    18f4:	02099163          	bnez	s3,1916 <core_list_mergesort+0x76>
    18f8:	8e26                	mv	t3,s1
    18fa:	347d                	addiw	s0,s0,-1
    18fc:	6084                	ld	s1,0(s1)
    18fe:	02090963          	beqz	s2,1930 <core_list_mergesort+0x90>
    1902:	01c93023          	sd	t3,0(s2)
    1906:	8972                	mv	s2,t3
    1908:	fe8044e3          	bgtz	s0,18f0 <core_list_mergesort+0x50>
    190c:	23a05f63          	blez	s10,1b4a <core_list_mergesort+0x2aa>
    1910:	04098863          	beqz	s3,1960 <core_list_mergesort+0xc0>
    1914:	c035                	beqz	s0,1978 <core_list_mergesort+0xd8>
    1916:	6488                	ld	a0,8(s1)
    1918:	0089b583          	ld	a1,8(s3)
    191c:	865a                	mv	a2,s6
    191e:	9b82                	jalr	s7
    1920:	fca05ce3          	blez	a0,18f8 <core_list_mergesort+0x58>
    1924:	8e4e                	mv	t3,s3
    1926:	3d7d                	addiw	s10,s10,-1
    1928:	0009b983          	ld	s3,0(s3)
    192c:	fc091be3          	bnez	s2,1902 <core_list_mergesort+0x62>
    1930:	8af2                	mv	s5,t3
    1932:	8972                	mv	s2,t3
    1934:	bfd1                	j	1908 <core_list_mergesort+0x68>
    1936:	0001                	nop
    1938:	0004be83          	ld	t4,0(s1)
    193c:	347d                	addiw	s0,s0,-1
    193e:	00090c63          	beqz	s2,1956 <core_list_mergesort+0xb6>
    1942:	00993023          	sd	s1,0(s2)
    1946:	c811                	beqz	s0,195a <core_list_mergesort+0xba>
    1948:	8926                	mv	s2,s1
    194a:	84f6                	mv	s1,t4
    194c:	0004be83          	ld	t4,0(s1)
    1950:	347d                	addiw	s0,s0,-1
    1952:	fe0918e3          	bnez	s2,1942 <core_list_mergesort+0xa2>
    1956:	8aa6                	mv	s5,s1
    1958:	f865                	bnez	s0,1948 <core_list_mergesort+0xa8>
    195a:	f6099be3          	bnez	s3,18d0 <core_list_mergesort+0x30>
    195e:	8926                	mv	s2,s1
    1960:	00093023          	sd	zero,0(s2)
    1964:	1d9c0463          	beq	s8,s9,1b2c <core_list_mergesort+0x28c>
    1968:	89d6                	mv	s3,s5
    196a:	001a1a1b          	slliw	s4,s4,0x1
    196e:	f4099de3          	bnez	s3,18c8 <core_list_mergesort+0x28>
    1972:	00003023          	sd	zero,0(zero) # 0 <__start>
    1976:	9002                	ebreak
    1978:	fffd029b          	addiw	t0,s10,-1
    197c:	0072f693          	andi	a3,t0,7
    1980:	c2e1                	beqz	a3,1a40 <core_list_mergesort+0x1a0>
    1982:	0009b383          	ld	t2,0(s3)
    1986:	3d7d                	addiw	s10,s10,-1
    1988:	18090663          	beqz	s2,1b14 <core_list_mergesort+0x274>
    198c:	01393023          	sd	s3,0(s2)
    1990:	894e                	mv	s2,s3
    1992:	fc0387e3          	beqz	t2,1960 <core_list_mergesort+0xc0>
    1996:	4605                	li	a2,1
    1998:	899e                	mv	s3,t2
    199a:	0006871b          	sext.w	a4,a3
    199e:	0ac68163          	beq	a3,a2,1a40 <core_list_mergesort+0x1a0>
    19a2:	4409                	li	s0,2
    19a4:	08870463          	beq	a4,s0,1a2c <core_list_mergesort+0x18c>
    19a8:	450d                	li	a0,3
    19aa:	06a70663          	beq	a4,a0,1a16 <core_list_mergesort+0x176>
    19ae:	4591                	li	a1,4
    19b0:	04b70863          	beq	a4,a1,1a00 <core_list_mergesort+0x160>
    19b4:	4815                	li	a6,5
    19b6:	03070a63          	beq	a4,a6,19ea <core_list_mergesort+0x14a>
    19ba:	4899                	li	a7,6
    19bc:	01170c63          	beq	a4,a7,19d4 <core_list_mergesort+0x134>
    19c0:	0003b983          	ld	s3,0(t2)
    19c4:	3d7d                	addiw	s10,s10,-1
    19c6:	18090763          	beqz	s2,1b54 <core_list_mergesort+0x2b4>
    19ca:	00793023          	sd	t2,0(s2)
    19ce:	891e                	mv	s2,t2
    19d0:	f80988e3          	beqz	s3,1960 <core_list_mergesort+0xc0>
    19d4:	0009be03          	ld	t3,0(s3)
    19d8:	3d7d                	addiw	s10,s10,-1
    19da:	14090763          	beqz	s2,1b28 <core_list_mergesort+0x288>
    19de:	01393023          	sd	s3,0(s2)
    19e2:	894e                	mv	s2,s3
    19e4:	f60e0ee3          	beqz	t3,1960 <core_list_mergesort+0xc0>
    19e8:	89f2                	mv	s3,t3
    19ea:	0009be83          	ld	t4,0(s3)
    19ee:	3d7d                	addiw	s10,s10,-1
    19f0:	12090a63          	beqz	s2,1b24 <core_list_mergesort+0x284>
    19f4:	01393023          	sd	s3,0(s2)
    19f8:	894e                	mv	s2,s3
    19fa:	f60e83e3          	beqz	t4,1960 <core_list_mergesort+0xc0>
    19fe:	89f6                	mv	s3,t4
    1a00:	0009bf03          	ld	t5,0(s3)
    1a04:	3d7d                	addiw	s10,s10,-1
    1a06:	10090d63          	beqz	s2,1b20 <core_list_mergesort+0x280>
    1a0a:	01393023          	sd	s3,0(s2)
    1a0e:	894e                	mv	s2,s3
    1a10:	f40f08e3          	beqz	t5,1960 <core_list_mergesort+0xc0>
    1a14:	89fa                	mv	s3,t5
    1a16:	0009bf83          	ld	t6,0(s3)
    1a1a:	3d7d                	addiw	s10,s10,-1
    1a1c:	10090063          	beqz	s2,1b1c <core_list_mergesort+0x27c>
    1a20:	01393023          	sd	s3,0(s2)
    1a24:	894e                	mv	s2,s3
    1a26:	f20f8de3          	beqz	t6,1960 <core_list_mergesort+0xc0>
    1a2a:	89fe                	mv	s3,t6
    1a2c:	0009b783          	ld	a5,0(s3)
    1a30:	3d7d                	addiw	s10,s10,-1
    1a32:	0e090363          	beqz	s2,1b18 <core_list_mergesort+0x278>
    1a36:	01393023          	sd	s3,0(s2)
    1a3a:	894e                	mv	s2,s3
    1a3c:	d395                	beqz	a5,1960 <core_list_mergesort+0xc0>
    1a3e:	89be                	mv	s3,a5
    1a40:	0009b283          	ld	t0,0(s3)
    1a44:	3d7d                	addiw	s10,s10,-1
    1a46:	0a090163          	beqz	s2,1ae8 <core_list_mergesort+0x248>
    1a4a:	01393023          	sd	s3,0(s2)
    1a4e:	0a0d0063          	beqz	s10,1aee <core_list_mergesort+0x24e>
    1a52:	894e                	mv	s2,s3
    1a54:	f00286e3          	beqz	t0,1960 <core_list_mergesort+0xc0>
    1a58:	0002b303          	ld	t1,0(t0)
    1a5c:	fffd049b          	addiw	s1,s10,-1
    1a60:	08098c63          	beqz	s3,1af8 <core_list_mergesort+0x258>
    1a64:	0059b023          	sd	t0,0(s3)
    1a68:	8916                	mv	s2,t0
    1a6a:	ee030be3          	beqz	t1,1960 <core_list_mergesort+0xc0>
    1a6e:	00033683          	ld	a3,0(t1)
    1a72:	fff4899b          	addiw	s3,s1,-1
    1a76:	08028363          	beqz	t0,1afc <core_list_mergesort+0x25c>
    1a7a:	0062b023          	sd	t1,0(t0)
    1a7e:	891a                	mv	s2,t1
    1a80:	ee0680e3          	beqz	a3,1960 <core_list_mergesort+0xc0>
    1a84:	6290                	ld	a2,0(a3)
    1a86:	fff9839b          	addiw	t2,s3,-1
    1a8a:	06030b63          	beqz	t1,1b00 <core_list_mergesort+0x260>
    1a8e:	00d33023          	sd	a3,0(t1)
    1a92:	8936                	mv	s2,a3
    1a94:	ec0606e3          	beqz	a2,1960 <core_list_mergesort+0xc0>
    1a98:	6218                	ld	a4,0(a2)
    1a9a:	fff3841b          	addiw	s0,t2,-1
    1a9e:	c2bd                	beqz	a3,1b04 <core_list_mergesort+0x264>
    1aa0:	e290                	sd	a2,0(a3)
    1aa2:	8932                	mv	s2,a2
    1aa4:	ea070ee3          	beqz	a4,1960 <core_list_mergesort+0xc0>
    1aa8:	630c                	ld	a1,0(a4)
    1aaa:	fff4051b          	addiw	a0,s0,-1
    1aae:	ce29                	beqz	a2,1b08 <core_list_mergesort+0x268>
    1ab0:	e218                	sd	a4,0(a2)
    1ab2:	893a                	mv	s2,a4
    1ab4:	ea0586e3          	beqz	a1,1960 <core_list_mergesort+0xc0>
    1ab8:	0005b883          	ld	a7,0(a1)
    1abc:	fff5081b          	addiw	a6,a0,-1
    1ac0:	c731                	beqz	a4,1b0c <core_list_mergesort+0x26c>
    1ac2:	e30c                	sd	a1,0(a4)
    1ac4:	892e                	mv	s2,a1
    1ac6:	e8088de3          	beqz	a7,1960 <core_list_mergesort+0xc0>
    1aca:	0008b983          	ld	s3,0(a7)
    1ace:	fff80d1b          	addiw	s10,a6,-1
    1ad2:	cd9d                	beqz	a1,1b10 <core_list_mergesort+0x270>
    1ad4:	0115b023          	sd	a7,0(a1)
    1ad8:	8946                	mv	s2,a7
    1ada:	e80983e3          	beqz	s3,1960 <core_list_mergesort+0xc0>
    1ade:	0009b283          	ld	t0,0(s3)
    1ae2:	3d7d                	addiw	s10,s10,-1
    1ae4:	f60913e3          	bnez	s2,1a4a <core_list_mergesort+0x1aa>
    1ae8:	8ace                	mv	s5,s3
    1aea:	f60d14e3          	bnez	s10,1a52 <core_list_mergesort+0x1b2>
    1aee:	84ce                	mv	s1,s3
    1af0:	8996                	mv	s3,t0
    1af2:	dc099fe3          	bnez	s3,18d0 <core_list_mergesort+0x30>
    1af6:	b5a5                	j	195e <core_list_mergesort+0xbe>
    1af8:	8a96                	mv	s5,t0
    1afa:	b7bd                	j	1a68 <core_list_mergesort+0x1c8>
    1afc:	8a9a                	mv	s5,t1
    1afe:	b741                	j	1a7e <core_list_mergesort+0x1de>
    1b00:	8ab6                	mv	s5,a3
    1b02:	bf41                	j	1a92 <core_list_mergesort+0x1f2>
    1b04:	8ab2                	mv	s5,a2
    1b06:	bf71                	j	1aa2 <core_list_mergesort+0x202>
    1b08:	8aba                	mv	s5,a4
    1b0a:	b765                	j	1ab2 <core_list_mergesort+0x212>
    1b0c:	8aae                	mv	s5,a1
    1b0e:	bf5d                	j	1ac4 <core_list_mergesort+0x224>
    1b10:	8ac6                	mv	s5,a7
    1b12:	b7d9                	j	1ad8 <core_list_mergesort+0x238>
    1b14:	8ace                	mv	s5,s3
    1b16:	bdad                	j	1990 <core_list_mergesort+0xf0>
    1b18:	8ace                	mv	s5,s3
    1b1a:	b705                	j	1a3a <core_list_mergesort+0x19a>
    1b1c:	8ace                	mv	s5,s3
    1b1e:	b719                	j	1a24 <core_list_mergesort+0x184>
    1b20:	8ace                	mv	s5,s3
    1b22:	b5f5                	j	1a0e <core_list_mergesort+0x16e>
    1b24:	8ace                	mv	s5,s3
    1b26:	bdc9                	j	19f8 <core_list_mergesort+0x158>
    1b28:	8ace                	mv	s5,s3
    1b2a:	bd65                	j	19e2 <core_list_mergesort+0x142>
    1b2c:	6446                	ld	s0,80(sp)
    1b2e:	60e6                	ld	ra,88(sp)
    1b30:	6906                	ld	s2,64(sp)
    1b32:	64a6                	ld	s1,72(sp)
    1b34:	ff314a0b          	th.ldd	s4,s3,(sp),3,4
    1b38:	fb714c0b          	th.ldd	s8,s7,(sp),1,4
    1b3c:	f9914d0b          	th.ldd	s10,s9,(sp),0,4
    1b40:	8556                	mv	a0,s5
    1b42:	fd514b0b          	th.ldd	s6,s5,(sp),2,4
    1b46:	6125                	addi	sp,sp,96
    1b48:	8082                	ret
    1b4a:	84ca                	mv	s1,s2
    1b4c:	d80992e3          	bnez	s3,18d0 <core_list_mergesort+0x30>
    1b50:	b539                	j	195e <core_list_mergesort+0xbe>
    1b52:	0001                	nop
    1b54:	8a9e                	mv	s5,t2
    1b56:	bda5                	j	19ce <core_list_mergesort+0x12e>
	...

0000000000001b60 <matrix_test>:
    1b60:	7139                	addi	sp,sp,-64
    1b62:	e852                	sd	s4,16(sp)
    1b64:	fc06                	sd	ra,56(sp)
    1b66:	7a7d                	lui	s4,0xfffff
    1b68:	01476a33          	or	s4,a4,s4
    1b6c:	5c0502e3          	beqz	a0,2930 <matrix_test+0xdd0>
    1b70:	882a                	mv	a6,a0
    1b72:	ec4e                	sd	s3,24(sp)
    1b74:	f04a                	sd	s2,32(sp)
    1b76:	f426                	sd	s1,40(sp)
    1b78:	f822                	sd	s0,48(sp)
    1b7a:	e05a                	sd	s6,0(sp)
    1b7c:	e456                	sd	s5,8(sp)
    1b7e:	892e                	mv	s2,a1
    1b80:	89b6                	mv	s3,a3
    1b82:	3c073a8b          	th.extu	s5,a4,15,0
    1b86:	86ba                	mv	a3,a4
    1b88:	4501                	li	a0,0
    1b8a:	84b2                	mv	s1,a2
    1b8c:	85c2                	mv	a1,a6
    1b8e:	4701                	li	a4,0
    1b90:	40a58633          	sub	a2,a1,a0
    1b94:	00767293          	andi	t0,a2,7
    1b98:	87aa                	mv	a5,a0
    1b9a:	08028863          	beqz	t0,1c2a <matrix_test+0xca>
    1b9e:	4885                	li	a7,1
    1ba0:	07128c63          	beq	t0,a7,1c18 <matrix_test+0xb8>
    1ba4:	4309                	li	t1,2
    1ba6:	06628263          	beq	t0,t1,1c0a <matrix_test+0xaa>
    1baa:	438d                	li	t2,3
    1bac:	04728863          	beq	t0,t2,1bfc <matrix_test+0x9c>
    1bb0:	4411                	li	s0,4
    1bb2:	02828e63          	beq	t0,s0,1bee <matrix_test+0x8e>
    1bb6:	4b15                	li	s6,5
    1bb8:	03628463          	beq	t0,s6,1be0 <matrix_test+0x80>
    1bbc:	4e19                	li	t3,6
    1bbe:	01c28a63          	beq	t0,t3,1bd2 <matrix_test+0x72>
    1bc2:	b2a4c78b          	th.lurhu	a5,s1,a0,1
    1bc6:	01578ebb          	addw	t4,a5,s5
    1bca:	32a4de8b          	th.surh	t4,s1,a0,1
    1bce:	0015079b          	addiw	a5,a0,1
    1bd2:	b2f4cf0b          	th.lurhu	t5,s1,a5,1
    1bd6:	015f0fbb          	addw	t6,t5,s5
    1bda:	32f4df8b          	th.surh	t6,s1,a5,1
    1bde:	2785                	addiw	a5,a5,1
    1be0:	b2f4c60b          	th.lurhu	a2,s1,a5,1
    1be4:	015602bb          	addw	t0,a2,s5
    1be8:	32f4d28b          	th.surh	t0,s1,a5,1
    1bec:	2785                	addiw	a5,a5,1
    1bee:	b2f4c88b          	th.lurhu	a7,s1,a5,1
    1bf2:	0158833b          	addw	t1,a7,s5
    1bf6:	32f4d30b          	th.surh	t1,s1,a5,1
    1bfa:	2785                	addiw	a5,a5,1
    1bfc:	b2f4c38b          	th.lurhu	t2,s1,a5,1
    1c00:	0153843b          	addw	s0,t2,s5
    1c04:	32f4d40b          	th.surh	s0,s1,a5,1
    1c08:	2785                	addiw	a5,a5,1
    1c0a:	b2f4cb0b          	th.lurhu	s6,s1,a5,1
    1c0e:	015b0e3b          	addw	t3,s6,s5
    1c12:	32f4de0b          	th.surh	t3,s1,a5,1
    1c16:	2785                	addiw	a5,a5,1
    1c18:	b2f4ce8b          	th.lurhu	t4,s1,a5,1
    1c1c:	015e8f3b          	addw	t5,t4,s5
    1c20:	32f4df0b          	th.surh	t5,s1,a5,1
    1c24:	2785                	addiw	a5,a5,1
    1c26:	08f58363          	beq	a1,a5,1cac <matrix_test+0x14c>
    1c2a:	b2f4c40b          	th.lurhu	s0,s1,a5,1
    1c2e:	0017889b          	addiw	a7,a5,1
    1c32:	0018839b          	addiw	t2,a7,1
    1c36:	01540b3b          	addw	s6,s0,s5
    1c3a:	32f4db0b          	th.surh	s6,s1,a5,1
    1c3e:	b314c30b          	th.lurhu	t1,s1,a7,1
    1c42:	0013879b          	addiw	a5,t2,1
    1c46:	00178f9b          	addiw	t6,a5,1
    1c4a:	01530e3b          	addw	t3,t1,s5
    1c4e:	3314de0b          	th.surh	t3,s1,a7,1
    1c52:	b274cf0b          	th.lurhu	t5,s1,t2,1
    1c56:	001f889b          	addiw	a7,t6,1
    1c5a:	015f063b          	addw	a2,t5,s5
    1c5e:	3274d60b          	th.surh	a2,s1,t2,1
    1c62:	b2f4ce8b          	th.lurhu	t4,s1,a5,1
    1c66:	0018839b          	addiw	t2,a7,1
    1c6a:	015e82bb          	addw	t0,t4,s5
    1c6e:	32f4d28b          	th.surh	t0,s1,a5,1
    1c72:	b3f4c40b          	th.lurhu	s0,s1,t6,1
    1c76:	0013879b          	addiw	a5,t2,1
    1c7a:	01540b3b          	addw	s6,s0,s5
    1c7e:	33f4db0b          	th.surh	s6,s1,t6,1
    1c82:	b314c30b          	th.lurhu	t1,s1,a7,1
    1c86:	01530e3b          	addw	t3,t1,s5
    1c8a:	3314de0b          	th.surh	t3,s1,a7,1
    1c8e:	b274cf0b          	th.lurhu	t5,s1,t2,1
    1c92:	015f063b          	addw	a2,t5,s5
    1c96:	3274d60b          	th.surh	a2,s1,t2,1
    1c9a:	b2f4ce8b          	th.lurhu	t4,s1,a5,1
    1c9e:	015e8f3b          	addw	t5,t4,s5
    1ca2:	32f4df0b          	th.surh	t5,s1,a5,1
    1ca6:	2785                	addiw	a5,a5,1
    1ca8:	f8f591e3          	bne	a1,a5,1c2a <matrix_test+0xca>
    1cac:	0017041b          	addiw	s0,a4,1
    1cb0:	8b22                	mv	s6,s0
    1cb2:	00a8053b          	addw	a0,a6,a0
    1cb6:	00b805bb          	addw	a1,a6,a1
    1cba:	00880463          	beq	a6,s0,1cc2 <matrix_test+0x162>
    1cbe:	8722                	mv	a4,s0
    1cc0:	bdc1                	j	1b90 <matrix_test+0x30>
    1cc2:	85a2                	mv	a1,s0
    1cc4:	4501                	li	a0,0
    1cc6:	4801                	li	a6,0
    1cc8:	40a58fb3          	sub	t6,a1,a0
    1ccc:	007ff613          	andi	a2,t6,7
    1cd0:	87aa                	mv	a5,a0
    1cd2:	c659                	beqz	a2,1d60 <matrix_test+0x200>
    1cd4:	4285                	li	t0,1
    1cd6:	06560c63          	beq	a2,t0,1d4e <matrix_test+0x1ee>
    1cda:	4889                	li	a7,2
    1cdc:	07160263          	beq	a2,a7,1d40 <matrix_test+0x1e0>
    1ce0:	430d                	li	t1,3
    1ce2:	04660863          	beq	a2,t1,1d32 <matrix_test+0x1d2>
    1ce6:	4391                	li	t2,4
    1ce8:	02760e63          	beq	a2,t2,1d24 <matrix_test+0x1c4>
    1cec:	4e15                	li	t3,5
    1cee:	03c60463          	beq	a2,t3,1d16 <matrix_test+0x1b6>
    1cf2:	4e99                	li	t4,6
    1cf4:	01d60a63          	beq	a2,t4,1d08 <matrix_test+0x1a8>
    1cf8:	32a4cf0b          	th.lurh	t5,s1,a0,1
    1cfc:	02df07bb          	mulw	a5,t5,a3
    1d00:	54a9578b          	th.surw	a5,s2,a0,2
    1d04:	0015079b          	addiw	a5,a0,1
    1d08:	32f4cf8b          	th.lurh	t6,s1,a5,1
    1d0c:	02df863b          	mulw	a2,t6,a3
    1d10:	54f9560b          	th.surw	a2,s2,a5,2
    1d14:	2785                	addiw	a5,a5,1
    1d16:	32f4c28b          	th.lurh	t0,s1,a5,1
    1d1a:	02d288bb          	mulw	a7,t0,a3
    1d1e:	54f9588b          	th.surw	a7,s2,a5,2
    1d22:	2785                	addiw	a5,a5,1
    1d24:	32f4c30b          	th.lurh	t1,s1,a5,1
    1d28:	02d303bb          	mulw	t2,t1,a3
    1d2c:	54f9538b          	th.surw	t2,s2,a5,2
    1d30:	2785                	addiw	a5,a5,1
    1d32:	32f4ce0b          	th.lurh	t3,s1,a5,1
    1d36:	02de0ebb          	mulw	t4,t3,a3
    1d3a:	54f95e8b          	th.surw	t4,s2,a5,2
    1d3e:	2785                	addiw	a5,a5,1
    1d40:	32f4cf0b          	th.lurh	t5,s1,a5,1
    1d44:	02df0fbb          	mulw	t6,t5,a3
    1d48:	54f95f8b          	th.surw	t6,s2,a5,2
    1d4c:	2785                	addiw	a5,a5,1
    1d4e:	32f4c60b          	th.lurh	a2,s1,a5,1
    1d52:	02d602bb          	mulw	t0,a2,a3
    1d56:	54f9528b          	th.surw	t0,s2,a5,2
    1d5a:	2785                	addiw	a5,a5,1
    1d5c:	08f58363          	beq	a1,a5,1de2 <matrix_test+0x282>
    1d60:	32f4c88b          	th.lurh	a7,s1,a5,1
    1d64:	00178e1b          	addiw	t3,a5,1
    1d68:	33c4c38b          	th.lurh	t2,s1,t3,1
    1d6c:	02d8833b          	mulw	t1,a7,a3
    1d70:	001e0f1b          	addiw	t5,t3,1
    1d74:	02d3863b          	mulw	a2,t2,a3
    1d78:	001f029b          	addiw	t0,t5,1
    1d7c:	54f9530b          	th.surw	t1,s2,a5,2
    1d80:	33e4c78b          	th.lurh	a5,s1,t5,1
    1d84:	3254cf8b          	th.lurh	t6,s1,t0,1
    1d88:	55c9560b          	th.surw	a2,s2,t3,2
    1d8c:	02d78ebb          	mulw	t4,a5,a3
    1d90:	0012831b          	addiw	t1,t0,1
    1d94:	3264ce0b          	th.lurh	t3,s1,t1,1
    1d98:	02df88bb          	mulw	a7,t6,a3
    1d9c:	55e95e8b          	th.surw	t4,s2,t5,2
    1da0:	00130f1b          	addiw	t5,t1,1
    1da4:	33e4c60b          	th.lurh	a2,s1,t5,1
    1da8:	02de03bb          	mulw	t2,t3,a3
    1dac:	5459588b          	th.surw	a7,s2,t0,2
    1db0:	02d607bb          	mulw	a5,a2,a3
    1db4:	001f0e9b          	addiw	t4,t5,1
    1db8:	5469538b          	th.surw	t2,s2,t1,2
    1dbc:	33d4c28b          	th.lurh	t0,s1,t4,1
    1dc0:	55e9578b          	th.surw	a5,s2,t5,2
    1dc4:	001e879b          	addiw	a5,t4,1
    1dc8:	32f4c60b          	th.lurh	a2,s1,a5,1
    1dcc:	02d28fbb          	mulw	t6,t0,a3
    1dd0:	02d602bb          	mulw	t0,a2,a3
    1dd4:	55d95f8b          	th.surw	t6,s2,t4,2
    1dd8:	54f9528b          	th.surw	t0,s2,a5,2
    1ddc:	2785                	addiw	a5,a5,1
    1dde:	f8f591e3          	bne	a1,a5,1d60 <matrix_test+0x200>
    1de2:	0018089b          	addiw	a7,a6,1
    1de6:	9d21                	addw	a0,a0,s0
    1de8:	9da1                	addw	a1,a1,s0
    1dea:	00e80463          	beq	a6,a4,1df2 <matrix_test+0x292>
    1dee:	8846                	mv	a6,a7
    1df0:	bde1                	j	1cc8 <matrix_test+0x168>
    1df2:	8822                	mv	a6,s0
    1df4:	4881                	li	a7,0
    1df6:	4e81                	li	t4,0
    1df8:	4681                	li	a3,0
    1dfa:	4501                	li	a0,0
    1dfc:	4301                	li	t1,0
    1dfe:	0001                	nop
    1e00:	411803b3          	sub	t2,a6,a7
    1e04:	0033fe13          	andi	t3,t2,3
    1e08:	8646                	mv	a2,a7
    1e0a:	060e0563          	beqz	t3,1e74 <matrix_test+0x314>
    1e0e:	4f05                	li	t5,1
    1e10:	05ee0263          	beq	t3,t5,1e54 <matrix_test+0x2f4>
    1e14:	4f89                	li	t6,2
    1e16:	03fe0163          	beq	t3,t6,1e38 <matrix_test+0x2d8>
    1e1a:	8676                	mv	a2,t4
    1e1c:	55194e8b          	th.lurw	t4,s2,a7,2
    1e20:	00de86bb          	addw	a3,t4,a3
    1e24:	12da4763          	blt	s4,a3,1f52 <matrix_test+0x3f2>
    1e28:	01d622b3          	slt	t0,a2,t4
    1e2c:	00a287bb          	addw	a5,t0,a0
    1e30:	3c07a50b          	th.ext	a0,a5,15,0
    1e34:	0018861b          	addiw	a2,a7,1
    1e38:	85f6                	mv	a1,t4
    1e3a:	54c94e8b          	th.lurw	t4,s2,a2,2
    1e3e:	00de86bb          	addw	a3,t4,a3
    1e42:	10da4263          	blt	s4,a3,1f46 <matrix_test+0x3e6>
    1e46:	01d5a3b3          	slt	t2,a1,t4
    1e4a:	00a3853b          	addw	a0,t2,a0
    1e4e:	3c05250b          	th.ext	a0,a0,15,0
    1e52:	2605                	addiw	a2,a2,1
    1e54:	8f76                	mv	t5,t4
    1e56:	54c94e8b          	th.lurw	t4,s2,a2,2
    1e5a:	00de86bb          	addw	a3,t4,a3
    1e5e:	0cda4e63          	blt	s4,a3,1f3a <matrix_test+0x3da>
    1e62:	01df2fb3          	slt	t6,t5,t4
    1e66:	00af82bb          	addw	t0,t6,a0
    1e6a:	3c02a50b          	th.ext	a0,t0,15,0
    1e6e:	2605                	addiw	a2,a2,1
    1e70:	06c80963          	beq	a6,a2,1ee2 <matrix_test+0x382>
    1e74:	54c9428b          	th.lurw	t0,s2,a2,2
    1e78:	00d28fbb          	addw	t6,t0,a3
    1e7c:	0bfa5863          	bge	s4,t6,1f2c <matrix_test+0x3cc>
    1e80:	00a50e1b          	addiw	t3,a0,10
    1e84:	3c0e2e8b          	th.ext	t4,t3,15,0
    1e88:	4f81                	li	t6,0
    1e8a:	0016039b          	addiw	t2,a2,1
    1e8e:	54794f0b          	th.lurw	t5,s2,t2,2
    1e92:	01ff0fbb          	addw	t6,t5,t6
    1e96:	07fa5763          	bge	s4,t6,1f04 <matrix_test+0x3a4>
    1e9a:	00ae869b          	addiw	a3,t4,10
    1e9e:	00138e9b          	addiw	t4,t2,1
    1ea2:	55d94e0b          	th.lurw	t3,s2,t4,2
    1ea6:	4f81                	li	t6,0
    1ea8:	3c06a28b          	th.ext	t0,a3,15,0
    1eac:	01fe06bb          	addw	a3,t3,t6
    1eb0:	06da4863          	blt	s4,a3,1f20 <matrix_test+0x3c0>
    1eb4:	01cf23b3          	slt	t2,t5,t3
    1eb8:	0053863b          	addw	a2,t2,t0
    1ebc:	3c06278b          	th.ext	a5,a2,15,0
    1ec0:	001e861b          	addiw	a2,t4,1
    1ec4:	54c94e8b          	th.lurw	t4,s2,a2,2
    1ec8:	00de86bb          	addw	a3,t4,a3
    1ecc:	02da4663          	blt	s4,a3,1ef8 <matrix_test+0x398>
    1ed0:	01de22b3          	slt	t0,t3,t4
    1ed4:	00f28fbb          	addw	t6,t0,a5
    1ed8:	2605                	addiw	a2,a2,1
    1eda:	3c0fa50b          	th.ext	a0,t6,15,0
    1ede:	f8c81be3          	bne	a6,a2,1e74 <matrix_test+0x314>
    1ee2:	0013059b          	addiw	a1,t1,1
    1ee6:	0104083b          	addw	a6,s0,a6
    1eea:	011408bb          	addw	a7,s0,a7
    1eee:	06e30863          	beq	t1,a4,1f5e <matrix_test+0x3fe>
    1ef2:	832e                	mv	t1,a1
    1ef4:	b731                	j	1e00 <matrix_test+0x2a0>
    1ef6:	0001                	nop
    1ef8:	00a7859b          	addiw	a1,a5,10
    1efc:	3c05a50b          	th.ext	a0,a1,15,0
    1f00:	4681                	li	a3,0
    1f02:	b7b5                	j	1e6e <matrix_test+0x30e>
    1f04:	01e2a7b3          	slt	a5,t0,t5
    1f08:	01d7853b          	addw	a0,a5,t4
    1f0c:	00138e9b          	addiw	t4,t2,1
    1f10:	55d94e0b          	th.lurw	t3,s2,t4,2
    1f14:	3c05228b          	th.ext	t0,a0,15,0
    1f18:	01fe06bb          	addw	a3,t3,t6
    1f1c:	f8da5ce3          	bge	s4,a3,1eb4 <matrix_test+0x354>
    1f20:	00a28f1b          	addiw	t5,t0,10
    1f24:	3c0f278b          	th.ext	a5,t5,15,0
    1f28:	4681                	li	a3,0
    1f2a:	bf59                	j	1ec0 <matrix_test+0x360>
    1f2c:	005ea5b3          	slt	a1,t4,t0
    1f30:	00a58f3b          	addw	t5,a1,a0
    1f34:	3c0f2e8b          	th.ext	t4,t5,15,0
    1f38:	bf89                	j	1e8a <matrix_test+0x32a>
    1f3a:	00a5079b          	addiw	a5,a0,10
    1f3e:	3c07a50b          	th.ext	a0,a5,15,0
    1f42:	4681                	li	a3,0
    1f44:	b72d                	j	1e6e <matrix_test+0x30e>
    1f46:	00a50e1b          	addiw	t3,a0,10
    1f4a:	3c0e250b          	th.ext	a0,t3,15,0
    1f4e:	4681                	li	a3,0
    1f50:	b709                	j	1e52 <matrix_test+0x2f2>
    1f52:	00a5069b          	addiw	a3,a0,10
    1f56:	3c06a50b          	th.ext	a0,a3,15,0
    1f5a:	4681                	li	a3,0
    1f5c:	bde1                	j	1e34 <matrix_test+0x2d4>
    1f5e:	4581                	li	a1,0
    1f60:	061020ef          	jal	47c0 <crc16>
    1f64:	85aa                	mv	a1,a0
    1f66:	7c0b3b0b          	th.extu	s6,s6,31,0
    1f6a:	4601                	li	a2,0
    1f6c:	4501                	li	a0,0
    1f6e:	0001                	nop
    1f70:	007b7313          	andi	t1,s6,7
    1f74:	4701                	li	a4,0
    1f76:	4681                	li	a3,0
    1f78:	0a030763          	beqz	t1,2026 <matrix_test+0x4c6>
    1f7c:	4e85                	li	t4,1
    1f7e:	09d30663          	beq	t1,t4,200a <matrix_test+0x4aa>
    1f82:	4389                	li	t2,2
    1f84:	06730a63          	beq	t1,t2,1ff8 <matrix_test+0x498>
    1f88:	4e0d                	li	t3,3
    1f8a:	05c30e63          	beq	t1,t3,1fe6 <matrix_test+0x486>
    1f8e:	4f11                	li	t5,4
    1f90:	05e30263          	beq	t1,t5,1fd4 <matrix_test+0x474>
    1f94:	4f95                	li	t6,5
    1f96:	03f30663          	beq	t1,t6,1fc2 <matrix_test+0x462>
    1f9a:	4299                	li	t0,6
    1f9c:	00530a63          	beq	t1,t0,1fb0 <matrix_test+0x450>
    1fa0:	b2c4c80b          	th.lurhu	a6,s1,a2,1
    1fa4:	0009d783          	lhu	a5,0(s3)
    1fa8:	86ba                	mv	a3,a4
    1faa:	8776                	mv	a4,t4
    1fac:	28f8168b          	th.mulah	a3,a6,a5
    1fb0:	00c708bb          	addw	a7,a4,a2
    1fb4:	a2e9ce8b          	th.lrhu	t4,s3,a4,1
    1fb8:	b314c30b          	th.lurhu	t1,s1,a7,1
    1fbc:	0705                	addi	a4,a4,1
    1fbe:	29d3168b          	th.mulah	a3,t1,t4
    1fc2:	00c703bb          	addw	t2,a4,a2
    1fc6:	a2e9cf0b          	th.lrhu	t5,s3,a4,1
    1fca:	b274ce0b          	th.lurhu	t3,s1,t2,1
    1fce:	0705                	addi	a4,a4,1
    1fd0:	29ee168b          	th.mulah	a3,t3,t5
    1fd4:	00c70fbb          	addw	t6,a4,a2
    1fd8:	a2e9c80b          	th.lrhu	a6,s3,a4,1
    1fdc:	b3f4c28b          	th.lurhu	t0,s1,t6,1
    1fe0:	0705                	addi	a4,a4,1
    1fe2:	2902968b          	th.mulah	a3,t0,a6
    1fe6:	00c707bb          	addw	a5,a4,a2
    1fea:	a2e9c30b          	th.lrhu	t1,s3,a4,1
    1fee:	b2f4c88b          	th.lurhu	a7,s1,a5,1
    1ff2:	0705                	addi	a4,a4,1
    1ff4:	2868968b          	th.mulah	a3,a7,t1
    1ff8:	00c70ebb          	addw	t4,a4,a2
    1ffc:	a2e9ce0b          	th.lrhu	t3,s3,a4,1
    2000:	b3d4c38b          	th.lurhu	t2,s1,t4,1
    2004:	0705                	addi	a4,a4,1
    2006:	29c3968b          	th.mulah	a3,t2,t3
    200a:	00c70f3b          	addw	t5,a4,a2
    200e:	a2e9c28b          	th.lrhu	t0,s3,a4,1
    2012:	b3e4cf8b          	th.lurhu	t6,s1,t5,1
    2016:	87b6                	mv	a5,a3
    2018:	883a                	mv	a6,a4
    201a:	285f978b          	th.mulah	a5,t6,t0
    201e:	0705                	addi	a4,a4,1
    2020:	86be                	mv	a3,a5
    2022:	0aeb0563          	beq	s6,a4,20cc <matrix_test+0x56c>
    2026:	00c708bb          	addw	a7,a4,a2
    202a:	b314c30b          	th.lurhu	t1,s1,a7,1
    202e:	a2e9ce8b          	th.lrhu	t4,s3,a4,1
    2032:	00170393          	addi	t2,a4,1
    2036:	87b6                	mv	a5,a3
    2038:	29d3178b          	th.mulah	a5,t1,t4
    203c:	00c38e3b          	addw	t3,t2,a2
    2040:	b3c4cf0b          	th.lurhu	t5,s1,t3,1
    2044:	a279cf8b          	th.lrhu	t6,s3,t2,1
    2048:	00270293          	addi	t0,a4,2
    204c:	00c286bb          	addw	a3,t0,a2
    2050:	29ff178b          	th.mulah	a5,t5,t6
    2054:	b2d4c80b          	th.lurhu	a6,s1,a3,1
    2058:	a259c88b          	th.lrhu	a7,s3,t0,1
    205c:	00370313          	addi	t1,a4,3
    2060:	00c30ebb          	addw	t4,t1,a2
    2064:	2918178b          	th.mulah	a5,a6,a7
    2068:	b3d4c38b          	th.lurhu	t2,s1,t4,1
    206c:	a269ce0b          	th.lrhu	t3,s3,t1,1
    2070:	00470f13          	addi	t5,a4,4
    2074:	00cf0fbb          	addw	t6,t5,a2
    2078:	29c3978b          	th.mulah	a5,t2,t3
    207c:	b3f4c28b          	th.lurhu	t0,s1,t6,1
    2080:	a3e9c68b          	th.lrhu	a3,s3,t5,1
    2084:	00570893          	addi	a7,a4,5
    2088:	00c8883b          	addw	a6,a7,a2
    208c:	28d2978b          	th.mulah	a5,t0,a3
    2090:	b304c30b          	th.lurhu	t1,s1,a6,1
    2094:	a319ce8b          	th.lrhu	t4,s3,a7,1
    2098:	00670393          	addi	t2,a4,6
    209c:	00c38e3b          	addw	t3,t2,a2
    20a0:	29d3178b          	th.mulah	a5,t1,t4
    20a4:	b3c4cf0b          	th.lurhu	t5,s1,t3,1
    20a8:	a279cf8b          	th.lrhu	t6,s3,t2,1
    20ac:	00770813          	addi	a6,a4,7
    20b0:	00c802bb          	addw	t0,a6,a2
    20b4:	29ff178b          	th.mulah	a5,t5,t6
    20b8:	a309c68b          	th.lrhu	a3,s3,a6,1
    20bc:	b254c88b          	th.lurhu	a7,s1,t0,1
    20c0:	0721                	addi	a4,a4,8
    20c2:	28d8978b          	th.mulah	a5,a7,a3
    20c6:	86be                	mv	a3,a5
    20c8:	f4eb1fe3          	bne	s6,a4,2026 <matrix_test+0x4c6>
    20cc:	44a9578b          	th.srw	a5,s2,a0,2
    20d0:	9e21                	addw	a2,a2,s0
    20d2:	00150793          	addi	a5,a0,1
    20d6:	01050463          	beq	a0,a6,20de <matrix_test+0x57e>
    20da:	853e                	mv	a0,a5
    20dc:	bd51                	j	1f70 <matrix_test+0x410>
    20de:	4601                	li	a2,0
    20e0:	4881                	li	a7,0
    20e2:	4701                	li	a4,0
    20e4:	4501                	li	a0,0
    20e6:	4801                	li	a6,0
    20e8:	8346                	mv	t1,a7
    20ea:	54c9488b          	th.lurw	a7,s2,a2,2
    20ee:	fff40b13          	addi	s6,s0,-1
    20f2:	003b7e93          	andi	t4,s6,3
    20f6:	00e8873b          	addw	a4,a7,a4
    20fa:	7aea5063          	bge	s4,a4,289a <matrix_test+0xd3a>
    20fe:	00a5071b          	addiw	a4,a0,10
    2102:	3c07250b          	th.ext	a0,a4,15,0
    2106:	4701                	li	a4,0
    2108:	4685                	li	a3,1
    210a:	0e86f963          	bgeu	a3,s0,21fc <matrix_test+0x69c>
    210e:	060e8963          	beqz	t4,2180 <matrix_test+0x620>
    2112:	04de8563          	beq	t4,a3,215c <matrix_test+0x5fc>
    2116:	4e09                	li	t3,2
    2118:	03ce8263          	beq	t4,t3,213c <matrix_test+0x5dc>
    211c:	00160f9b          	addiw	t6,a2,1
    2120:	8f46                	mv	t5,a7
    2122:	55f9488b          	th.lurw	a7,s2,t6,2
    2126:	00e8873b          	addw	a4,a7,a4
    212a:	7eea4c63          	blt	s4,a4,2922 <matrix_test+0xdc2>
    212e:	011f22b3          	slt	t0,t5,a7
    2132:	00a287bb          	addw	a5,t0,a0
    2136:	3c07a50b          	th.ext	a0,a5,15,0
    213a:	2685                	addiw	a3,a3,1
    213c:	8ec6                	mv	t4,a7
    213e:	00c688bb          	addw	a7,a3,a2
    2142:	5519488b          	th.lurw	a7,s2,a7,2
    2146:	00e8873b          	addw	a4,a7,a4
    214a:	7aea4563          	blt	s4,a4,28f4 <matrix_test+0xd94>
    214e:	011ea333          	slt	t1,t4,a7
    2152:	00a303bb          	addw	t2,t1,a0
    2156:	3c03a50b          	th.ext	a0,t2,15,0
    215a:	2685                	addiw	a3,a3,1
    215c:	00c68f3b          	addw	t5,a3,a2
    2160:	8e46                	mv	t3,a7
    2162:	55e9488b          	th.lurw	a7,s2,t5,2
    2166:	00e8873b          	addw	a4,a7,a4
    216a:	76ea4363          	blt	s4,a4,28d0 <matrix_test+0xd70>
    216e:	011e2fb3          	slt	t6,t3,a7
    2172:	00af82bb          	addw	t0,t6,a0
    2176:	3c02a50b          	th.ext	a0,t0,15,0
    217a:	2685                	addiw	a3,a3,1
    217c:	0886f063          	bgeu	a3,s0,21fc <matrix_test+0x69c>
    2180:	00c68b3b          	addw	s6,a3,a2
    2184:	55694f8b          	th.lurw	t6,s2,s6,2
    2188:	00ef82bb          	addw	t0,t6,a4
    218c:	705a5063          	bge	s4,t0,288c <matrix_test+0xd2c>
    2190:	00a50e1b          	addiw	t3,a0,10
    2194:	3c0e2e8b          	th.ext	t4,t3,15,0
    2198:	4281                	li	t0,0
    219a:	2685                	addiw	a3,a3,1
    219c:	00c6833b          	addw	t1,a3,a2
    21a0:	5469488b          	th.lurw	a7,s2,t1,2
    21a4:	005882bb          	addw	t0,a7,t0
    21a8:	6c5a5a63          	bge	s4,t0,287c <matrix_test+0xd1c>
    21ac:	00ae871b          	addiw	a4,t4,10
    21b0:	3c072b0b          	th.ext	s6,a4,15,0
    21b4:	4281                	li	t0,0
    21b6:	00168f9b          	addiw	t6,a3,1
    21ba:	00cf8f3b          	addw	t5,t6,a2
    21be:	55e9450b          	th.lurw	a0,s2,t5,2
    21c2:	005507bb          	addw	a5,a0,t0
    21c6:	6afa4563          	blt	s4,a5,2870 <matrix_test+0xd10>
    21ca:	00a8aeb3          	slt	t4,a7,a0
    21ce:	016e8e3b          	addw	t3,t4,s6
    21d2:	3c0e230b          	th.ext	t1,t3,15,0
    21d6:	001f869b          	addiw	a3,t6,1
    21da:	00c688bb          	addw	a7,a3,a2
    21de:	5519488b          	th.lurw	a7,s2,a7,2
    21e2:	00f8873b          	addw	a4,a7,a5
    21e6:	66ea4f63          	blt	s4,a4,2864 <matrix_test+0xd04>
    21ea:	011523b3          	slt	t2,a0,a7
    21ee:	00638b3b          	addw	s6,t2,t1
    21f2:	2685                	addiw	a3,a3,1
    21f4:	3c0b250b          	th.ext	a0,s6,15,0
    21f8:	f886e4e3          	bltu	a3,s0,2180 <matrix_test+0x620>
    21fc:	2805                	addiw	a6,a6,1
    21fe:	9e21                	addw	a2,a2,s0
    2200:	ee8864e3          	bltu	a6,s0,20e8 <matrix_test+0x588>
    2204:	5bc020ef          	jal	47c0 <crc16>
    2208:	85aa                	mv	a1,a0
    220a:	4601                	li	a2,0
    220c:	4881                	li	a7,0
    220e:	0001                	nop
    2210:	4b01                	li	s6,0
    2212:	0001                	nop
    2214:	00000013          	nop
    2218:	b369c30b          	th.lurhu	t1,s3,s6,1
    221c:	b2c4ce8b          	th.lurhu	t4,s1,a2,1
    2220:	4f81                	li	t6,0
    2222:	fff40793          	addi	a5,s0,-1
    2226:	286e9f8b          	th.mulah	t6,t4,t1
    222a:	4705                	li	a4,1
    222c:	00cb083b          	addw	a6,s6,a2
    2230:	0037f393          	andi	t2,a5,3
    2234:	837e                	mv	t1,t6
    2236:	016406bb          	addw	a3,s0,s6
    223a:	0a877f63          	bgeu	a4,s0,22f8 <matrix_test+0x798>
    223e:	04038963          	beqz	t2,2290 <matrix_test+0x730>
    2242:	02e38963          	beq	t2,a4,2274 <matrix_test+0x714>
    2246:	4f09                	li	t5,2
    2248:	01e38c63          	beq	t2,t5,2260 <matrix_test+0x700>
    224c:	00160e1b          	addiw	t3,a2,1
    2250:	b2d9c28b          	th.lurhu	t0,s3,a3,1
    2254:	b3c4cf8b          	th.lurhu	t6,s1,t3,1
    2258:	877a                	mv	a4,t5
    225a:	9ea1                	addw	a3,a3,s0
    225c:	285f930b          	th.mulah	t1,t6,t0
    2260:	00c707bb          	addw	a5,a4,a2
    2264:	b2d9ce8b          	th.lurhu	t4,s3,a3,1
    2268:	b2f4c38b          	th.lurhu	t2,s1,a5,1
    226c:	2705                	addiw	a4,a4,1
    226e:	9ea1                	addw	a3,a3,s0
    2270:	29d3930b          	th.mulah	t1,t2,t4
    2274:	00c7053b          	addw	a0,a4,a2
    2278:	b2d9ce0b          	th.lurhu	t3,s3,a3,1
    227c:	b2a4cf0b          	th.lurhu	t5,s1,a0,1
    2280:	8f9a                	mv	t6,t1
    2282:	2705                	addiw	a4,a4,1
    2284:	29cf1f8b          	th.mulah	t6,t5,t3
    2288:	9ea1                	addw	a3,a3,s0
    228a:	837e                	mv	t1,t6
    228c:	06877663          	bgeu	a4,s0,22f8 <matrix_test+0x798>
    2290:	00c702bb          	addw	t0,a4,a2
    2294:	b254c78b          	th.lurhu	a5,s1,t0,1
    2298:	b2d9c38b          	th.lurhu	t2,s3,a3,1
    229c:	00170e9b          	addiw	t4,a4,1
    22a0:	8f9a                	mv	t6,t1
    22a2:	28779f8b          	th.mulah	t6,a5,t2
    22a6:	00d4053b          	addw	a0,s0,a3
    22aa:	00ce8f3b          	addw	t5,t4,a2
    22ae:	b3e4ce0b          	th.lurhu	t3,s1,t5,1
    22b2:	b2a9c30b          	th.lurhu	t1,s3,a0,1
    22b6:	001e871b          	addiw	a4,t4,1
    22ba:	008506bb          	addw	a3,a0,s0
    22be:	286e1f8b          	th.mulah	t6,t3,t1
    22c2:	00c702bb          	addw	t0,a4,a2
    22c6:	b2d9c38b          	th.lurhu	t2,s3,a3,1
    22ca:	b254c78b          	th.lurhu	a5,s1,t0,1
    22ce:	00170e9b          	addiw	t4,a4,1
    22d2:	0086853b          	addw	a0,a3,s0
    22d6:	28779f8b          	th.mulah	t6,a5,t2
    22da:	00ce8f3b          	addw	t5,t4,a2
    22de:	b2a9c30b          	th.lurhu	t1,s3,a0,1
    22e2:	b3e4ce0b          	th.lurhu	t3,s1,t5,1
    22e6:	001e871b          	addiw	a4,t4,1
    22ea:	008506bb          	addw	a3,a0,s0
    22ee:	286e1f8b          	th.mulah	t6,t3,t1
    22f2:	837e                	mv	t1,t6
    22f4:	f8876ee3          	bltu	a4,s0,2290 <matrix_test+0x730>
    22f8:	55095f8b          	th.surw	t6,s2,a6,2
    22fc:	2b05                	addiw	s6,s6,1
    22fe:	f08b6de3          	bltu	s6,s0,2218 <matrix_test+0x6b8>
    2302:	2885                	addiw	a7,a7,1
    2304:	9e21                	addw	a2,a2,s0
    2306:	f088e5e3          	bltu	a7,s0,2210 <matrix_test+0x6b0>
    230a:	4b01                	li	s6,0
    230c:	4881                	li	a7,0
    230e:	4601                	li	a2,0
    2310:	4501                	li	a0,0
    2312:	4f81                	li	t6,0
    2314:	00000013          	nop
    2318:	86c6                	mv	a3,a7
    231a:	5569488b          	th.lurw	a7,s2,s6,2
    231e:	fff40813          	addi	a6,s0,-1
    2322:	00387293          	andi	t0,a6,3
    2326:	00c8863b          	addw	a2,a7,a2
    232a:	58ca5663          	bge	s4,a2,28b6 <matrix_test+0xd56>
    232e:	00a5071b          	addiw	a4,a0,10
    2332:	3c07250b          	th.ext	a0,a4,15,0
    2336:	4601                	li	a2,0
    2338:	4685                	li	a3,1
    233a:	0e86fa63          	bgeu	a3,s0,242e <matrix_test+0x8ce>
    233e:	06028963          	beqz	t0,23b0 <matrix_test+0x850>
    2342:	04d28563          	beq	t0,a3,238c <matrix_test+0x82c>
    2346:	4e89                	li	t4,2
    2348:	03d28263          	beq	t0,t4,236c <matrix_test+0x80c>
    234c:	001b0e1b          	addiw	t3,s6,1
    2350:	8f46                	mv	t5,a7
    2352:	55c9488b          	th.lurw	a7,s2,t3,2
    2356:	00c8863b          	addw	a2,a7,a2
    235a:	5aca4863          	blt	s4,a2,290a <matrix_test+0xdaa>
    235e:	011f2333          	slt	t1,t5,a7
    2362:	00a3053b          	addw	a0,t1,a0
    2366:	3c05250b          	th.ext	a0,a0,15,0
    236a:	2685                	addiw	a3,a3,1
    236c:	8846                	mv	a6,a7
    236e:	016688bb          	addw	a7,a3,s6
    2372:	5519488b          	th.lurw	a7,s2,a7,2
    2376:	00c8863b          	addw	a2,a7,a2
    237a:	58ca4263          	blt	s4,a2,28fe <matrix_test+0xd9e>
    237e:	011822b3          	slt	t0,a6,a7
    2382:	00a287bb          	addw	a5,t0,a0
    2386:	3c07a50b          	th.ext	a0,a5,15,0
    238a:	2685                	addiw	a3,a3,1
    238c:	01668f3b          	addw	t5,a3,s6
    2390:	8ec6                	mv	t4,a7
    2392:	55e9488b          	th.lurw	a7,s2,t5,2
    2396:	00c8863b          	addw	a2,a7,a2
    239a:	52ca4563          	blt	s4,a2,28c4 <matrix_test+0xd64>
    239e:	011eae33          	slt	t3,t4,a7
    23a2:	00ae033b          	addw	t1,t3,a0
    23a6:	3c03250b          	th.ext	a0,t1,15,0
    23aa:	2685                	addiw	a3,a3,1
    23ac:	0886f163          	bgeu	a3,s0,242e <matrix_test+0x8ce>
    23b0:	016687bb          	addw	a5,a3,s6
    23b4:	54f9428b          	th.lurw	t0,s2,a5,2
    23b8:	00c283bb          	addw	t2,t0,a2
    23bc:	487a5c63          	bge	s4,t2,2854 <matrix_test+0xcf4>
    23c0:	00a50e9b          	addiw	t4,a0,10
    23c4:	3c0eaf0b          	th.ext	t5,t4,15,0
    23c8:	4381                	li	t2,0
    23ca:	0016881b          	addiw	a6,a3,1
    23ce:	01680e3b          	addw	t3,a6,s6
    23d2:	55c9460b          	th.lurw	a2,s2,t3,2
    23d6:	007603bb          	addw	t2,a2,t2
    23da:	467a5563          	bge	s4,t2,2844 <matrix_test+0xce4>
    23de:	00af071b          	addiw	a4,t5,10
    23e2:	3c07278b          	th.ext	a5,a4,15,0
    23e6:	4381                	li	t2,0
    23e8:	0018029b          	addiw	t0,a6,1
    23ec:	016288bb          	addw	a7,t0,s6
    23f0:	5519450b          	th.lurw	a0,s2,a7,2
    23f4:	0075033b          	addw	t1,a0,t2
    23f8:	446a4063          	blt	s4,t1,2838 <matrix_test+0xcd8>
    23fc:	00a62f33          	slt	t5,a2,a0
    2400:	00ff0ebb          	addw	t4,t5,a5
    2404:	3c0eae0b          	th.ext	t3,t4,15,0
    2408:	0012869b          	addiw	a3,t0,1
    240c:	0166863b          	addw	a2,a3,s6
    2410:	54c9488b          	th.lurw	a7,s2,a2,2
    2414:	0068863b          	addw	a2,a7,t1
    2418:	40ca4a63          	blt	s4,a2,282c <matrix_test+0xccc>
    241c:	011527b3          	slt	a5,a0,a7
    2420:	01c783bb          	addw	t2,a5,t3
    2424:	2685                	addiw	a3,a3,1
    2426:	3c03a50b          	th.ext	a0,t2,15,0
    242a:	f886e3e3          	bltu	a3,s0,23b0 <matrix_test+0x850>
    242e:	2f85                	addiw	t6,t6,1
    2430:	01640b3b          	addw	s6,s0,s6
    2434:	ee8fe2e3          	bltu	t6,s0,2318 <matrix_test+0x7b8>
    2438:	388020ef          	jal	47c0 <crc16>
    243c:	85aa                	mv	a1,a0
    243e:	4301                	li	t1,0
    2440:	4501                	li	a0,0
    2442:	0001                	nop
    2444:	00000013          	nop
    2448:	4b01                	li	s6,0
    244a:	0001                	nop
    244c:	00000013          	nop
    2450:	32a4c80b          	th.lurh	a6,s1,a0,1
    2454:	3369c28b          	th.lurh	t0,s3,s6,1
    2458:	fff40f93          	addi	t6,s0,-1
    245c:	00ab08bb          	addw	a7,s6,a0
    2460:	025807bb          	mulw	a5,a6,t0
    2464:	003ff613          	andi	a2,t6,3
    2468:	016406bb          	addw	a3,s0,s6
    246c:	1427b38b          	th.extu	t2,a5,5,2
    2470:	2c57be8b          	th.extu	t4,a5,11,5
    2474:	03d3873b          	mulw	a4,t2,t4
    2478:	4785                	li	a5,1
    247a:	8e3a                	mv	t3,a4
    247c:	1087f763          	bgeu	a5,s0,258a <matrix_test+0xa2a>
    2480:	ca35                	beqz	a2,24f4 <matrix_test+0x994>
    2482:	04f60563          	beq	a2,a5,24cc <matrix_test+0x96c>
    2486:	4709                	li	a4,2
    2488:	02e60263          	beq	a2,a4,24ac <matrix_test+0x94c>
    248c:	00150f9b          	addiw	t6,a0,1
    2490:	32d9c60b          	th.lurh	a2,s3,a3,1
    2494:	33f4c80b          	th.lurh	a6,s1,t6,1
    2498:	9ea1                	addw	a3,a3,s0
    249a:	02c802bb          	mulw	t0,a6,a2
    249e:	2c52b78b          	th.extu	a5,t0,11,5
    24a2:	1422b38b          	th.extu	t2,t0,5,2
    24a6:	24f39e0b          	th.mulaw	t3,t2,a5
    24aa:	87ba                	mv	a5,a4
    24ac:	00a78ebb          	addw	t4,a5,a0
    24b0:	32d9c70b          	th.lurh	a4,s3,a3,1
    24b4:	33d4cf0b          	th.lurh	t5,s1,t4,1
    24b8:	2785                	addiw	a5,a5,1
    24ba:	9ea1                	addw	a3,a3,s0
    24bc:	02ef0fbb          	mulw	t6,t5,a4
    24c0:	142fb80b          	th.extu	a6,t6,5,2
    24c4:	2c5fb60b          	th.extu	a2,t6,11,5
    24c8:	24c81e0b          	th.mulaw	t3,a6,a2
    24cc:	00a782bb          	addw	t0,a5,a0
    24d0:	32d9ce8b          	th.lurh	t4,s3,a3,1
    24d4:	3254c38b          	th.lurh	t2,s1,t0,1
    24d8:	8772                	mv	a4,t3
    24da:	2785                	addiw	a5,a5,1
    24dc:	03d38f3b          	mulw	t5,t2,t4
    24e0:	9ea1                	addw	a3,a3,s0
    24e2:	142f3f8b          	th.extu	t6,t5,5,2
    24e6:	2c5f380b          	th.extu	a6,t5,11,5
    24ea:	250f970b          	th.mulaw	a4,t6,a6
    24ee:	8e3a                	mv	t3,a4
    24f0:	0887fd63          	bgeu	a5,s0,258a <matrix_test+0xa2a>
    24f4:	00a7863b          	addw	a2,a5,a0
    24f8:	32c4c28b          	th.lurh	t0,s1,a2,1
    24fc:	32d9c38b          	th.lurh	t2,s3,a3,1
    2500:	0017881b          	addiw	a6,a5,1
    2504:	9ea1                	addw	a3,a3,s0
    2506:	02728f3b          	mulw	t5,t0,t2
    250a:	8772                	mv	a4,t3
    250c:	00a80e3b          	addw	t3,a6,a0
    2510:	33c4c78b          	th.lurh	a5,s1,t3,1
    2514:	32d9c60b          	th.lurh	a2,s3,a3,1
    2518:	142f3e8b          	th.extu	t4,t5,5,2
    251c:	2c5f3f8b          	th.extu	t6,t5,11,5
    2520:	02c782bb          	mulw	t0,a5,a2
    2524:	25fe970b          	th.mulaw	a4,t4,t6
    2528:	00180e9b          	addiw	t4,a6,1
    252c:	00868fbb          	addw	t6,a3,s0
    2530:	00ae883b          	addw	a6,t4,a0
    2534:	3304c68b          	th.lurh	a3,s1,a6,1
    2538:	33f9ce0b          	th.lurh	t3,s3,t6,1
    253c:	1422b38b          	th.extu	t2,t0,5,2
    2540:	2c52bf0b          	th.extu	t5,t0,11,5
    2544:	25e3970b          	th.mulaw	a4,t2,t5
    2548:	001e839b          	addiw	t2,t4,1
    254c:	03c687bb          	mulw	a5,a3,t3
    2550:	008f8f3b          	addw	t5,t6,s0
    2554:	00a38ebb          	addw	t4,t2,a0
    2558:	33d4cf8b          	th.lurh	t6,s1,t4,1
    255c:	33e9c80b          	th.lurh	a6,s3,t5,1
    2560:	1427b28b          	th.extu	t0,a5,5,2
    2564:	2c57b60b          	th.extu	a2,a5,11,5
    2568:	030f86bb          	mulw	a3,t6,a6
    256c:	24c2970b          	th.mulaw	a4,t0,a2
    2570:	1426be0b          	th.extu	t3,a3,5,2
    2574:	2c56b78b          	th.extu	a5,a3,11,5
    2578:	24fe170b          	th.mulaw	a4,t3,a5
    257c:	0013879b          	addiw	a5,t2,1
    2580:	008f06bb          	addw	a3,t5,s0
    2584:	8e3a                	mv	t3,a4
    2586:	f687e7e3          	bltu	a5,s0,24f4 <matrix_test+0x994>
    258a:	5519570b          	th.surw	a4,s2,a7,2
    258e:	2b05                	addiw	s6,s6,1
    2590:	ec8b60e3          	bltu	s6,s0,2450 <matrix_test+0x8f0>
    2594:	2305                	addiw	t1,t1,1
    2596:	9d21                	addw	a0,a0,s0
    2598:	ea8368e3          	bltu	t1,s0,2448 <matrix_test+0x8e8>
    259c:	4b01                	li	s6,0
    259e:	4301                	li	t1,0
    25a0:	4681                	li	a3,0
    25a2:	4501                	li	a0,0
    25a4:	4881                	li	a7,0
    25a6:	0001                	nop
    25a8:	829a                	mv	t0,t1
    25aa:	5569430b          	th.lurw	t1,s2,s6,2
    25ae:	fff40713          	addi	a4,s0,-1
    25b2:	00377993          	andi	s3,a4,3
    25b6:	00d306bb          	addw	a3,t1,a3
    25ba:	2eda5763          	bge	s4,a3,28a8 <matrix_test+0xd48>
    25be:	00a50f1b          	addiw	t5,a0,10
    25c2:	3c0f250b          	th.ext	a0,t5,15,0
    25c6:	4681                	li	a3,0
    25c8:	4785                	li	a5,1
    25ca:	0e87fa63          	bgeu	a5,s0,26be <matrix_test+0xb5e>
    25ce:	06098963          	beqz	s3,2640 <matrix_test+0xae0>
    25d2:	04f98563          	beq	s3,a5,261c <matrix_test+0xabc>
    25d6:	4e89                	li	t4,2
    25d8:	03d98263          	beq	s3,t4,25fc <matrix_test+0xa9c>
    25dc:	001b081b          	addiw	a6,s6,1
    25e0:	8f9a                	mv	t6,t1
    25e2:	5509430b          	th.lurw	t1,s2,a6,2
    25e6:	00d306bb          	addw	a3,t1,a3
    25ea:	32da4663          	blt	s4,a3,2916 <matrix_test+0xdb6>
    25ee:	006fae33          	slt	t3,t6,t1
    25f2:	00ae053b          	addw	a0,t3,a0
    25f6:	3c05250b          	th.ext	a0,a0,15,0
    25fa:	2785                	addiw	a5,a5,1
    25fc:	871a                	mv	a4,t1
    25fe:	0167833b          	addw	t1,a5,s6
    2602:	5469430b          	th.lurw	t1,s2,t1,2
    2606:	00d306bb          	addw	a3,t1,a3
    260a:	2cda4f63          	blt	s4,a3,28e8 <matrix_test+0xd88>
    260e:	006729b3          	slt	s3,a4,t1
    2612:	00a982bb          	addw	t0,s3,a0
    2616:	3c02a50b          	th.ext	a0,t0,15,0
    261a:	2785                	addiw	a5,a5,1
    261c:	01678f3b          	addw	t5,a5,s6
    2620:	839a                	mv	t2,t1
    2622:	55e9430b          	th.lurw	t1,s2,t5,2
    2626:	00d306bb          	addw	a3,t1,a3
    262a:	2ada4963          	blt	s4,a3,28dc <matrix_test+0xd7c>
    262e:	0063aeb3          	slt	t4,t2,t1
    2632:	00ae8fbb          	addw	t6,t4,a0
    2636:	3c0fa50b          	th.ext	a0,t6,15,0
    263a:	2785                	addiw	a5,a5,1
    263c:	0887f163          	bgeu	a5,s0,26be <matrix_test+0xb5e>
    2640:	0167873b          	addw	a4,a5,s6
    2644:	54e9498b          	th.lurw	s3,s2,a4,2
    2648:	00d982bb          	addw	t0,s3,a3
    264c:	1c5a5863          	bge	s4,t0,281c <matrix_test+0xcbc>
    2650:	00a50e9b          	addiw	t4,a0,10
    2654:	3c0eaf0b          	th.ext	t5,t4,15,0
    2658:	4281                	li	t0,0
    265a:	00178f9b          	addiw	t6,a5,1
    265e:	016f883b          	addw	a6,t6,s6
    2662:	55094e0b          	th.lurw	t3,s2,a6,2
    2666:	005e073b          	addw	a4,t3,t0
    266a:	1aea5163          	bge	s4,a4,280c <matrix_test+0xcac>
    266e:	00af069b          	addiw	a3,t5,10
    2672:	3c06a30b          	th.ext	t1,a3,15,0
    2676:	4701                	li	a4,0
    2678:	001f899b          	addiw	s3,t6,1
    267c:	016982bb          	addw	t0,s3,s6
    2680:	5459438b          	th.lurw	t2,s2,t0,2
    2684:	00e3883b          	addw	a6,t2,a4
    2688:	170a4c63          	blt	s4,a6,2800 <matrix_test+0xca0>
    268c:	007e2533          	slt	a0,t3,t2
    2690:	00650f3b          	addw	t5,a0,t1
    2694:	3c0f2f8b          	th.ext	t6,t5,15,0
    2698:	0019879b          	addiw	a5,s3,1
    269c:	01678e3b          	addw	t3,a5,s6
    26a0:	55c9430b          	th.lurw	t1,s2,t3,2
    26a4:	010306bb          	addw	a3,t1,a6
    26a8:	14da4663          	blt	s4,a3,27f4 <matrix_test+0xc94>
    26ac:	0063a633          	slt	a2,t2,t1
    26b0:	01f6073b          	addw	a4,a2,t6
    26b4:	2785                	addiw	a5,a5,1
    26b6:	3c07250b          	th.ext	a0,a4,15,0
    26ba:	f887e3e3          	bltu	a5,s0,2640 <matrix_test+0xae0>
    26be:	2885                	addiw	a7,a7,1
    26c0:	01640b3b          	addw	s6,s0,s6
    26c4:	ee88e2e3          	bltu	a7,s0,25a8 <matrix_test+0xa48>
    26c8:	0f8020ef          	jal	47c0 <crc16>
    26cc:	4681                	li	a3,0
    26ce:	4601                	li	a2,0
    26d0:	b2d4ca0b          	th.lurhu	s4,s1,a3,1
    26d4:	fff40593          	addi	a1,s0,-1
    26d8:	4785                	li	a5,1
    26da:	415a0b3b          	subw	s6,s4,s5
    26de:	32d4db0b          	th.surh	s6,s1,a3,1
    26e2:	0075f913          	andi	s2,a1,7
    26e6:	0e87f663          	bgeu	a5,s0,27d2 <matrix_test+0xc72>
    26ea:	0a090663          	beqz	s2,2796 <matrix_test+0xc36>
    26ee:	08f90963          	beq	s2,a5,2780 <matrix_test+0xc20>
    26f2:	4889                	li	a7,2
    26f4:	07190d63          	beq	s2,a7,276e <matrix_test+0xc0e>
    26f8:	4e0d                	li	t3,3
    26fa:	07c90163          	beq	s2,t3,275c <matrix_test+0xbfc>
    26fe:	4711                	li	a4,4
    2700:	04e90563          	beq	s2,a4,274a <matrix_test+0xbea>
    2704:	4315                	li	t1,5
    2706:	02690963          	beq	s2,t1,2738 <matrix_test+0xbd8>
    270a:	4999                	li	s3,6
    270c:	01390b63          	beq	s2,s3,2722 <matrix_test+0xbc2>
    2710:	0016829b          	addiw	t0,a3,1
    2714:	b254c38b          	th.lurhu	t2,s1,t0,1
    2718:	87c6                	mv	a5,a7
    271a:	41538f3b          	subw	t5,t2,s5
    271e:	3254df0b          	th.surh	t5,s1,t0,1
    2722:	00d78ebb          	addw	t4,a5,a3
    2726:	b3d4cf8b          	th.lurhu	t6,s1,t4,1
    272a:	2785                	addiw	a5,a5,1
    272c:	415f883b          	subw	a6,t6,s5
    2730:	33d4d80b          	th.surh	a6,s1,t4,1
    2734:	00000013          	nop
    2738:	00d785bb          	addw	a1,a5,a3
    273c:	b2b4c90b          	th.lurhu	s2,s1,a1,1
    2740:	2785                	addiw	a5,a5,1
    2742:	41590a3b          	subw	s4,s2,s5
    2746:	32b4da0b          	th.surh	s4,s1,a1,1
    274a:	00d78b3b          	addw	s6,a5,a3
    274e:	b364c88b          	th.lurhu	a7,s1,s6,1
    2752:	2785                	addiw	a5,a5,1
    2754:	41588e3b          	subw	t3,a7,s5
    2758:	3364de0b          	th.surh	t3,s1,s6,1
    275c:	00d7833b          	addw	t1,a5,a3
    2760:	b264c70b          	th.lurhu	a4,s1,t1,1
    2764:	2785                	addiw	a5,a5,1
    2766:	415709bb          	subw	s3,a4,s5
    276a:	3264d98b          	th.surh	s3,s1,t1,1
    276e:	00d782bb          	addw	t0,a5,a3
    2772:	b254c38b          	th.lurhu	t2,s1,t0,1
    2776:	2785                	addiw	a5,a5,1
    2778:	41538f3b          	subw	t5,t2,s5
    277c:	3254df0b          	th.surh	t5,s1,t0,1
    2780:	00d78ebb          	addw	t4,a5,a3
    2784:	b3d4cf8b          	th.lurhu	t6,s1,t4,1
    2788:	2785                	addiw	a5,a5,1
    278a:	415f883b          	subw	a6,t6,s5
    278e:	33d4d80b          	th.surh	a6,s1,t4,1
    2792:	0487f063          	bgeu	a5,s0,27d2 <matrix_test+0xc72>
    2796:	00d785bb          	addw	a1,a5,a3
    279a:	b2b4c90b          	th.lurhu	s2,s1,a1,1
    279e:	00178b1b          	addiw	s6,a5,1
    27a2:	00db08bb          	addw	a7,s6,a3
    27a6:	41590a3b          	subw	s4,s2,s5
    27aa:	32b4da0b          	th.surh	s4,s1,a1,1
    27ae:	b314ce0b          	th.lurhu	t3,s1,a7,1
    27b2:	001b079b          	addiw	a5,s6,1
    27b6:	00d78ebb          	addw	t4,a5,a3
    27ba:	415e033b          	subw	t1,t3,s5
    27be:	3314d30b          	th.surh	t1,s1,a7,1
    27c2:	b3d4cf8b          	th.lurhu	t6,s1,t4,1
    27c6:	2785                	addiw	a5,a5,1
    27c8:	415f883b          	subw	a6,t6,s5
    27cc:	33d4d80b          	th.surh	a6,s1,t4,1
    27d0:	b7a5                	j	2738 <matrix_test+0xbd8>
    27d2:	2605                	addiw	a2,a2,1
    27d4:	9ea1                	addw	a3,a3,s0
    27d6:	ee866de3          	bltu	a2,s0,26d0 <matrix_test+0xb70>
    27da:	74a2                	ld	s1,40(sp)
    27dc:	7442                	ld	s0,48(sp)
    27de:	70e2                	ld	ra,56(sp)
    27e0:	6b02                	ld	s6,0(sp)
    27e2:	6aa2                	ld	s5,8(sp)
    27e4:	69e2                	ld	s3,24(sp)
    27e6:	7902                	ld	s2,32(sp)
    27e8:	6a42                	ld	s4,16(sp)
    27ea:	3c05250b          	th.ext	a0,a0,15,0
    27ee:	6121                	addi	sp,sp,64
    27f0:	8082                	ret
    27f2:	0001                	nop
    27f4:	00af869b          	addiw	a3,t6,10
    27f8:	3c06a50b          	th.ext	a0,a3,15,0
    27fc:	4681                	li	a3,0
    27fe:	bd35                	j	263a <matrix_test+0xada>
    2800:	00a30e9b          	addiw	t4,t1,10
    2804:	3c0eaf8b          	th.ext	t6,t4,15,0
    2808:	4801                	li	a6,0
    280a:	b579                	j	2698 <matrix_test+0xb38>
    280c:	01c9a7b3          	slt	a5,s3,t3
    2810:	01e7863b          	addw	a2,a5,t5
    2814:	3c06230b          	th.ext	t1,a2,15,0
    2818:	b585                	j	2678 <matrix_test+0xb18>
    281a:	0001                	nop
    281c:	013323b3          	slt	t2,t1,s3
    2820:	00a3853b          	addw	a0,t2,a0
    2824:	3c052f0b          	th.ext	t5,a0,15,0
    2828:	bd0d                	j	265a <matrix_test+0xafa>
    282a:	0001                	nop
    282c:	00ae071b          	addiw	a4,t3,10
    2830:	3c07250b          	th.ext	a0,a4,15,0
    2834:	4601                	li	a2,0
    2836:	be95                	j	23aa <matrix_test+0x84a>
    2838:	00a7881b          	addiw	a6,a5,10
    283c:	3c082e0b          	th.ext	t3,a6,15,0
    2840:	4301                	li	t1,0
    2842:	b6d9                	j	2408 <matrix_test+0x8a8>
    2844:	00c2a333          	slt	t1,t0,a2
    2848:	01e306bb          	addw	a3,t1,t5
    284c:	3c06a78b          	th.ext	a5,a3,15,0
    2850:	be61                	j	23e8 <matrix_test+0x888>
    2852:	0001                	nop
    2854:	0058a8b3          	slt	a7,a7,t0
    2858:	00a8853b          	addw	a0,a7,a0
    285c:	3c052f0b          	th.ext	t5,a0,15,0
    2860:	b6ad                	j	23ca <matrix_test+0x86a>
    2862:	0001                	nop
    2864:	00a3071b          	addiw	a4,t1,10
    2868:	3c07250b          	th.ext	a0,a4,15,0
    286c:	4701                	li	a4,0
    286e:	b231                	j	217a <matrix_test+0x61a>
    2870:	00ab069b          	addiw	a3,s6,10
    2874:	3c06a30b          	th.ext	t1,a3,15,0
    2878:	4781                	li	a5,0
    287a:	bab1                	j	21d6 <matrix_test+0x676>
    287c:	011fa7b3          	slt	a5,t6,a7
    2880:	01d783bb          	addw	t2,a5,t4
    2884:	3c03ab0b          	th.ext	s6,t2,15,0
    2888:	b23d                	j	21b6 <matrix_test+0x656>
    288a:	0001                	nop
    288c:	01f8af33          	slt	t5,a7,t6
    2890:	00af053b          	addw	a0,t5,a0
    2894:	3c052e8b          	th.ext	t4,a0,15,0
    2898:	b209                	j	219a <matrix_test+0x63a>
    289a:	011323b3          	slt	t2,t1,a7
    289e:	00a3853b          	addw	a0,t2,a0
    28a2:	3c05250b          	th.ext	a0,a0,15,0
    28a6:	b08d                	j	2108 <matrix_test+0x5a8>
    28a8:	0062a633          	slt	a2,t0,t1
    28ac:	00a603bb          	addw	t2,a2,a0
    28b0:	3c03a50b          	th.ext	a0,t2,15,0
    28b4:	bb11                	j	25c8 <matrix_test+0xa68>
    28b6:	0116a7b3          	slt	a5,a3,a7
    28ba:	00a783bb          	addw	t2,a5,a0
    28be:	3c03a50b          	th.ext	a0,t2,15,0
    28c2:	bc9d                	j	2338 <matrix_test+0x7d8>
    28c4:	00a5071b          	addiw	a4,a0,10
    28c8:	3c07250b          	th.ext	a0,a4,15,0
    28cc:	4601                	li	a2,0
    28ce:	bcf1                	j	23aa <matrix_test+0x84a>
    28d0:	00a5071b          	addiw	a4,a0,10
    28d4:	3c07250b          	th.ext	a0,a4,15,0
    28d8:	4701                	li	a4,0
    28da:	b045                	j	217a <matrix_test+0x61a>
    28dc:	00a5081b          	addiw	a6,a0,10
    28e0:	3c08250b          	th.ext	a0,a6,15,0
    28e4:	4681                	li	a3,0
    28e6:	bb91                	j	263a <matrix_test+0xada>
    28e8:	00a5061b          	addiw	a2,a0,10
    28ec:	3c06250b          	th.ext	a0,a2,15,0
    28f0:	4681                	li	a3,0
    28f2:	b325                	j	261a <matrix_test+0xaba>
    28f4:	2529                	addiw	a0,a0,10
    28f6:	3c05250b          	th.ext	a0,a0,15,0
    28fa:	4701                	li	a4,0
    28fc:	b8b9                	j	215a <matrix_test+0x5fa>
    28fe:	00a5039b          	addiw	t2,a0,10
    2902:	3c03a50b          	th.ext	a0,t2,15,0
    2906:	4601                	li	a2,0
    2908:	b449                	j	238a <matrix_test+0x82a>
    290a:	00a5061b          	addiw	a2,a0,10
    290e:	3c06250b          	th.ext	a0,a2,15,0
    2912:	4601                	li	a2,0
    2914:	bc99                	j	236a <matrix_test+0x80a>
    2916:	00a5069b          	addiw	a3,a0,10
    291a:	3c06a50b          	th.ext	a0,a3,15,0
    291e:	4681                	li	a3,0
    2920:	b9e9                	j	25fa <matrix_test+0xa9a>
    2922:	00a50b1b          	addiw	s6,a0,10
    2926:	3c0b250b          	th.ext	a0,s6,15,0
    292a:	4701                	li	a4,0
    292c:	80fff06f          	j	213a <matrix_test+0x5da>
    2930:	4581                	li	a1,0
    2932:	68f010ef          	jal	47c0 <crc16>
    2936:	85aa                	mv	a1,a0
    2938:	4501                	li	a0,0
    293a:	687010ef          	jal	47c0 <crc16>
    293e:	85aa                	mv	a1,a0
    2940:	4501                	li	a0,0
    2942:	67f010ef          	jal	47c0 <crc16>
    2946:	85aa                	mv	a1,a0
    2948:	4501                	li	a0,0
    294a:	677010ef          	jal	47c0 <crc16>
    294e:	70e2                	ld	ra,56(sp)
    2950:	6a42                	ld	s4,16(sp)
    2952:	3c05250b          	th.ext	a0,a0,15,0
    2956:	6121                	addi	sp,sp,64
    2958:	8082                	ret
    295a:	00000013          	nop
    295e:	0001                	nop

0000000000002960 <core_bench_matrix>:
    2960:	1141                	addi	sp,sp,-16
    2962:	f811540b          	th.sdd	s0,ra,(sp),0,4
    2966:	872e                	mv	a4,a1
    2968:	8432                	mv	s0,a2
    296a:	fab5468b          	th.ldd	a3,a1,(a0),1,4
    296e:	6510                	ld	a2,8(a0)
    2970:	4108                	lw	a0,0(a0)
    2972:	9eeff0ef          	jal	1b60 <matrix_test>
    2976:	85a2                	mv	a1,s0
    2978:	f811440b          	th.ldd	s0,ra,(sp),0,4
    297c:	0141                	addi	sp,sp,16
    297e:	6430106f          	j	47c0 <crc16>
    2982:	0001                	nop
    2984:	00000013          	nop
    2988:	00000013          	nop
    298c:	00000013          	nop

0000000000002990 <core_init_matrix>:
    2990:	4785                	li	a5,1
    2992:	42c6178b          	th.mvnez	a5,a2,a2
    2996:	882a                	mv	a6,a0
    2998:	4601                	li	a2,0
    299a:	1e050763          	beqz	a0,2b88 <core_init_matrix+0x1f8>
    299e:	0016031b          	addiw	t1,a2,1
    29a2:	026303bb          	mulw	t2,t1,t1
    29a6:	8532                	mv	a0,a2
    29a8:	0033989b          	slliw	a7,t2,0x3
    29ac:	0908f263          	bgeu	a7,a6,2a30 <core_init_matrix+0xa0>
    29b0:	00130e1b          	addiw	t3,t1,1
    29b4:	03ce0f3b          	mulw	t5,t3,t3
    29b8:	851a                	mv	a0,t1
    29ba:	003f1f9b          	slliw	t6,t5,0x3
    29be:	070ff963          	bgeu	t6,a6,2a30 <core_init_matrix+0xa0>
    29c2:	001e061b          	addiw	a2,t3,1
    29c6:	02c6033b          	mulw	t1,a2,a2
    29ca:	8572                	mv	a0,t3
    29cc:	0033171b          	slliw	a4,t1,0x3
    29d0:	07077063          	bgeu	a4,a6,2a30 <core_init_matrix+0xa0>
    29d4:	0016039b          	addiw	t2,a2,1
    29d8:	02738e3b          	mulw	t3,t2,t2
    29dc:	8532                	mv	a0,a2
    29de:	003e1e9b          	slliw	t4,t3,0x3
    29e2:	050ef763          	bgeu	t4,a6,2a30 <core_init_matrix+0xa0>
    29e6:	00138f1b          	addiw	t5,t2,1
    29ea:	03ef063b          	mulw	a2,t5,t5
    29ee:	851e                	mv	a0,t2
    29f0:	0036129b          	slliw	t0,a2,0x3
    29f4:	0302fe63          	bgeu	t0,a6,2a30 <core_init_matrix+0xa0>
    29f8:	001f031b          	addiw	t1,t5,1
    29fc:	026303bb          	mulw	t2,t1,t1
    2a00:	857a                	mv	a0,t5
    2a02:	0033989b          	slliw	a7,t2,0x3
    2a06:	0308f563          	bgeu	a7,a6,2a30 <core_init_matrix+0xa0>
    2a0a:	00130e1b          	addiw	t3,t1,1
    2a0e:	03ce0f3b          	mulw	t5,t3,t3
    2a12:	851a                	mv	a0,t1
    2a14:	003f1f9b          	slliw	t6,t5,0x3
    2a18:	010ffc63          	bgeu	t6,a6,2a30 <core_init_matrix+0xa0>
    2a1c:	001e061b          	addiw	a2,t3,1
    2a20:	02c6033b          	mulw	t1,a2,a2
    2a24:	8572                	mv	a0,t3
    2a26:	0033171b          	slliw	a4,t1,0x3
    2a2a:	f7076ae3          	bltu	a4,a6,299e <core_init_matrix+0xe>
    2a2e:	0001                	nop
    2a30:	02a503bb          	mulw	t2,a0,a0
    2a34:	15fd                	addi	a1,a1,-1
    2a36:	ffc5f813          	andi	a6,a1,-4
    2a3a:	00480593          	addi	a1,a6,4
    2a3e:	7c03b88b          	th.extu	a7,t2,31,0
    2a42:	00189e13          	slli	t3,a7,0x1
    2a46:	01c58633          	add	a2,a1,t3
    2a4a:	14050b63          	beqz	a0,2ba0 <core_init_matrix+0x210>
    2a4e:	8eaa                	mv	t4,a0
    2a50:	0015081b          	addiw	a6,a0,1
    2a54:	4881                	li	a7,0
    2a56:	4705                	li	a4,1
    2a58:	40e80f33          	sub	t5,a6,a4
    2a5c:	003f7293          	andi	t0,t5,3
    2a60:	833a                	mv	t1,a4
    2a62:	00028963          	beqz	t0,2a74 <core_init_matrix+0xe4>
    2a66:	4f85                	li	t6,1
    2a68:	0bf28d63          	beq	t0,t6,2b22 <core_init_matrix+0x192>
    2a6c:	4389                	li	t2,2
    2a6e:	06728d63          	beq	t0,t2,2ae8 <core_init_matrix+0x158>
    2a72:	a835                	j	2aae <core_init_matrix+0x11e>
    2a74:	02e783bb          	mulw	t2,a5,a4
    2a78:	41f3d29b          	sraiw	t0,t2,0x1f
    2a7c:	0102df9b          	srliw	t6,t0,0x10
    2a80:	007f87bb          	addw	a5,t6,t2
    2a84:	3c07bf0b          	th.extu	t5,a5,15,0
    2a88:	41ff07bb          	subw	a5,t5,t6
    2a8c:	3c07338b          	th.extu	t2,a4,15,0
    2a90:	007782bb          	addw	t0,a5,t2
    2a94:	3c02bf0b          	th.extu	t5,t0,15,0
    2a98:	fff70f9b          	addiw	t6,a4,-1
    2a9c:	007f03bb          	addw	t2,t5,t2
    2aa0:	33f65f0b          	th.surh	t5,a2,t6,1
    2aa4:	0ff3f293          	zext.b	t0,t2
    2aa8:	33f5d28b          	th.surh	t0,a1,t6,1
    2aac:	2705                	addiw	a4,a4,1
    2aae:	02e787bb          	mulw	a5,a5,a4
    2ab2:	41f7df1b          	sraiw	t5,a5,0x1f
    2ab6:	010f529b          	srliw	t0,t5,0x10
    2aba:	00f28fbb          	addw	t6,t0,a5
    2abe:	3c0fb38b          	th.extu	t2,t6,15,0
    2ac2:	405387bb          	subw	a5,t2,t0
    2ac6:	3c07328b          	th.extu	t0,a4,15,0
    2aca:	00578f3b          	addw	t5,a5,t0
    2ace:	3c0f338b          	th.extu	t2,t5,15,0
    2ad2:	fff70f9b          	addiw	t6,a4,-1
    2ad6:	005382bb          	addw	t0,t2,t0
    2ada:	33f6538b          	th.surh	t2,a2,t6,1
    2ade:	0ff2ff13          	zext.b	t5,t0
    2ae2:	33f5df0b          	th.surh	t5,a1,t6,1
    2ae6:	2705                	addiw	a4,a4,1
    2ae8:	02e787bb          	mulw	a5,a5,a4
    2aec:	41f7d39b          	sraiw	t2,a5,0x1f
    2af0:	0103df9b          	srliw	t6,t2,0x10
    2af4:	00ff82bb          	addw	t0,t6,a5
    2af8:	3c02bf0b          	th.extu	t5,t0,15,0
    2afc:	3c07338b          	th.extu	t2,a4,15,0
    2b00:	41ff07bb          	subw	a5,t5,t6
    2b04:	00778fbb          	addw	t6,a5,t2
    2b08:	3c0fb28b          	th.extu	t0,t6,15,0
    2b0c:	00728f3b          	addw	t5,t0,t2
    2b10:	fff70f9b          	addiw	t6,a4,-1
    2b14:	33f6528b          	th.surh	t0,a2,t6,1
    2b18:	0fff7393          	zext.b	t2,t5
    2b1c:	33f5d38b          	th.surh	t2,a1,t6,1
    2b20:	2705                	addiw	a4,a4,1
    2b22:	02e787bb          	mulw	a5,a5,a4
    2b26:	41f7d29b          	sraiw	t0,a5,0x1f
    2b2a:	0102df9b          	srliw	t6,t0,0x10
    2b2e:	00ff8f3b          	addw	t5,t6,a5
    2b32:	3c0f338b          	th.extu	t2,t5,15,0
    2b36:	3c07328b          	th.extu	t0,a4,15,0
    2b3a:	41f387bb          	subw	a5,t2,t6
    2b3e:	00578fbb          	addw	t6,a5,t0
    2b42:	3c0fbf0b          	th.extu	t5,t6,15,0
    2b46:	fff7039b          	addiw	t2,a4,-1
    2b4a:	005f02bb          	addw	t0,t5,t0
    2b4e:	32765f0b          	th.surh	t5,a2,t2,1
    2b52:	0ff2ff93          	zext.b	t6,t0
    2b56:	3275df8b          	th.surh	t6,a1,t2,1
    2b5a:	2705                	addiw	a4,a4,1
    2b5c:	f1071ce3          	bne	a4,a6,2a74 <core_init_matrix+0xe4>
    2b60:	2885                	addiw	a7,a7,1
    2b62:	0065073b          	addw	a4,a0,t1
    2b66:	0105083b          	addw	a6,a0,a6
    2b6a:	eea897e3          	bne	a7,a0,2a58 <core_init_matrix+0xc8>
    2b6e:	9e32                	add	t3,t3,a2
    2b70:	fffe0313          	addi	t1,t3,-1
    2b74:	ffc37793          	andi	a5,t1,-4
    2b78:	00478f13          	addi	t5,a5,4
    2b7c:	01d6a023          	sw	t4,0(a3)
    2b80:	e68c                	sd	a1,8(a3)
    2b82:	fbe6d60b          	th.sdd	a2,t5,(a3),1,4
    2b86:	8082                	ret
    2b88:	fff58613          	addi	a2,a1,-1
    2b8c:	ffc67293          	andi	t0,a2,-4
    2b90:	5efd                	li	t4,-1
    2b92:	00428593          	addi	a1,t0,4
    2b96:	00628613          	addi	a2,t0,6
    2b9a:	8576                	mv	a0,t4
    2b9c:	4e09                	li	t3,2
    2b9e:	bd4d                	j	2a50 <core_init_matrix+0xc0>
    2ba0:	4e81                	li	t4,0
    2ba2:	4e01                	li	t3,0
    2ba4:	b7e9                	j	2b6e <core_init_matrix+0x1de>
    2ba6:	00000013          	nop
    2baa:	00000013          	nop
    2bae:	0001                	nop

0000000000002bb0 <matrix_sum>:
    2bb0:	88aa                	mv	a7,a0
    2bb2:	18050563          	beqz	a0,2d3c <matrix_sum+0x18c>
    2bb6:	882a                	mv	a6,a0
    2bb8:	4301                	li	t1,0
    2bba:	4e01                	li	t3,0
    2bbc:	4501                	li	a0,0
    2bbe:	4f01                	li	t5,0
    2bc0:	4781                	li	a5,0
    2bc2:	0001                	nop
    2bc4:	00000013          	nop
    2bc8:	406806b3          	sub	a3,a6,t1
    2bcc:	0036f293          	andi	t0,a3,3
    2bd0:	871a                	mv	a4,t1
    2bd2:	0c028e63          	beqz	t0,2cae <matrix_sum+0xfe>
    2bd6:	4e85                	li	t4,1
    2bd8:	05d28263          	beq	t0,t4,2c1c <matrix_sum+0x6c>
    2bdc:	4389                	li	t2,2
    2bde:	02728163          	beq	t0,t2,2c00 <matrix_sum+0x50>
    2be2:	877a                	mv	a4,t5
    2be4:	5465cf0b          	th.lurw	t5,a1,t1,2
    2be8:	00ff07bb          	addw	a5,t5,a5
    2bec:	14f64263          	blt	a2,a5,2d30 <matrix_sum+0x180>
    2bf0:	01e72fb3          	slt	t6,a4,t5
    2bf4:	00af853b          	addw	a0,t6,a0
    2bf8:	3c05250b          	th.ext	a0,a0,15,0
    2bfc:	0013071b          	addiw	a4,t1,1
    2c00:	86fa                	mv	a3,t5
    2c02:	54e5cf0b          	th.lurw	t5,a1,a4,2
    2c06:	00ff07bb          	addw	a5,t5,a5
    2c0a:	10f64d63          	blt	a2,a5,2d24 <matrix_sum+0x174>
    2c0e:	01e6a2b3          	slt	t0,a3,t5
    2c12:	00a28ebb          	addw	t4,t0,a0
    2c16:	3c0ea50b          	th.ext	a0,t4,15,0
    2c1a:	2705                	addiw	a4,a4,1
    2c1c:	8ffa                	mv	t6,t5
    2c1e:	54e5cf0b          	th.lurw	t5,a1,a4,2
    2c22:	00ff07bb          	addw	a5,t5,a5
    2c26:	0ef64963          	blt	a2,a5,2d18 <matrix_sum+0x168>
    2c2a:	01efa6b3          	slt	a3,t6,t5
    2c2e:	9d35                	addw	a0,a0,a3
    2c30:	3c05250b          	th.ext	a0,a0,15,0
    2c34:	2705                	addiw	a4,a4,1
    2c36:	06e81c63          	bne	a6,a4,2cae <matrix_sum+0xfe>
    2c3a:	2e05                	addiw	t3,t3,1
    2c3c:	0108883b          	addw	a6,a7,a6
    2c40:	0068833b          	addw	t1,a7,t1
    2c44:	f9c892e3          	bne	a7,t3,2bc8 <matrix_sum+0x18>
    2c48:	8082                	ret
    2c4a:	0001                	nop
    2c4c:	2705                	addiw	a4,a4,1
    2c4e:	54e5cf0b          	th.lurw	t5,a1,a4,2
    2c52:	00a5069b          	addiw	a3,a0,10
    2c56:	4381                	li	t2,0
    2c58:	3c06af8b          	th.ext	t6,a3,15,0
    2c5c:	007f06bb          	addw	a3,t5,t2
    2c60:	06d65a63          	bge	a2,a3,2cd4 <matrix_sum+0x124>
    2c64:	00af879b          	addiw	a5,t6,10
    2c68:	00170f9b          	addiw	t6,a4,1
    2c6c:	55f5ce8b          	th.lurw	t4,a1,t6,2
    2c70:	4681                	li	a3,0
    2c72:	3c07a38b          	th.ext	t2,a5,15,0
    2c76:	00de87bb          	addw	a5,t4,a3
    2c7a:	06f64b63          	blt	a2,a5,2cf0 <matrix_sum+0x140>
    2c7e:	01df2733          	slt	a4,t5,t4
    2c82:	00770f3b          	addw	t5,a4,t2
    2c86:	001f839b          	addiw	t2,t6,1
    2c8a:	3c0f228b          	th.ext	t0,t5,15,0
    2c8e:	5475cf0b          	th.lurw	t5,a1,t2,2
    2c92:	00ff07bb          	addw	a5,t5,a5
    2c96:	06f64a63          	blt	a2,a5,2d0a <matrix_sum+0x15a>
    2c9a:	01eea6b3          	slt	a3,t4,t5
    2c9e:	00568fbb          	addw	t6,a3,t0
    2ca2:	3c0fa50b          	th.ext	a0,t6,15,0
    2ca6:	0013871b          	addiw	a4,t2,1
    2caa:	f8e808e3          	beq	a6,a4,2c3a <matrix_sum+0x8a>
    2cae:	54e5c28b          	th.lurw	t0,a1,a4,2
    2cb2:	00f283bb          	addw	t2,t0,a5
    2cb6:	f8764be3          	blt	a2,t2,2c4c <matrix_sum+0x9c>
    2cba:	005f2f33          	slt	t5,t5,t0
    2cbe:	2705                	addiw	a4,a4,1
    2cc0:	00af0ebb          	addw	t4,t5,a0
    2cc4:	54e5cf0b          	th.lurw	t5,a1,a4,2
    2cc8:	3c0eaf8b          	th.ext	t6,t4,15,0
    2ccc:	007f06bb          	addw	a3,t5,t2
    2cd0:	f8d64ae3          	blt	a2,a3,2c64 <matrix_sum+0xb4>
    2cd4:	01e2a533          	slt	a0,t0,t5
    2cd8:	01f502bb          	addw	t0,a0,t6
    2cdc:	00170f9b          	addiw	t6,a4,1
    2ce0:	55f5ce8b          	th.lurw	t4,a1,t6,2
    2ce4:	3c02a38b          	th.ext	t2,t0,15,0
    2ce8:	00de87bb          	addw	a5,t4,a3
    2cec:	f8f659e3          	bge	a2,a5,2c7e <matrix_sum+0xce>
    2cf0:	00a3851b          	addiw	a0,t2,10
    2cf4:	001f839b          	addiw	t2,t6,1
    2cf8:	5475cf0b          	th.lurw	t5,a1,t2,2
    2cfc:	4781                	li	a5,0
    2cfe:	3c05228b          	th.ext	t0,a0,15,0
    2d02:	00ff07bb          	addw	a5,t5,a5
    2d06:	f8f65ae3          	bge	a2,a5,2c9a <matrix_sum+0xea>
    2d0a:	00a28e9b          	addiw	t4,t0,10
    2d0e:	3c0ea50b          	th.ext	a0,t4,15,0
    2d12:	4781                	li	a5,0
    2d14:	bf49                	j	2ca6 <matrix_sum+0xf6>
    2d16:	0001                	nop
    2d18:	00a5079b          	addiw	a5,a0,10
    2d1c:	3c07a50b          	th.ext	a0,a5,15,0
    2d20:	4781                	li	a5,0
    2d22:	bf09                	j	2c34 <matrix_sum+0x84>
    2d24:	00a5039b          	addiw	t2,a0,10
    2d28:	3c03a50b          	th.ext	a0,t2,15,0
    2d2c:	4781                	li	a5,0
    2d2e:	b5f5                	j	2c1a <matrix_sum+0x6a>
    2d30:	00a5079b          	addiw	a5,a0,10
    2d34:	3c07a50b          	th.ext	a0,a5,15,0
    2d38:	4781                	li	a5,0
    2d3a:	b5c9                	j	2bfc <matrix_sum+0x4c>
    2d3c:	4501                	li	a0,0
    2d3e:	8082                	ret

0000000000002d40 <matrix_mul_const>:
    2d40:	12050d63          	beqz	a0,2e7a <matrix_mul_const+0x13a>
    2d44:	882a                	mv	a6,a0
    2d46:	4881                	li	a7,0
    2d48:	4301                	li	t1,0
    2d4a:	0001                	nop
    2d4c:	00000013          	nop
    2d50:	41180733          	sub	a4,a6,a7
    2d54:	00777293          	andi	t0,a4,7
    2d58:	87c6                	mv	a5,a7
    2d5a:	08028863          	beqz	t0,2dea <matrix_mul_const+0xaa>
    2d5e:	4e05                	li	t3,1
    2d60:	07c28c63          	beq	t0,t3,2dd8 <matrix_mul_const+0x98>
    2d64:	4389                	li	t2,2
    2d66:	06728263          	beq	t0,t2,2dca <matrix_mul_const+0x8a>
    2d6a:	4e8d                	li	t4,3
    2d6c:	05d28863          	beq	t0,t4,2dbc <matrix_mul_const+0x7c>
    2d70:	4f11                	li	t5,4
    2d72:	03e28e63          	beq	t0,t5,2dae <matrix_mul_const+0x6e>
    2d76:	4f95                	li	t6,5
    2d78:	03f28463          	beq	t0,t6,2da0 <matrix_mul_const+0x60>
    2d7c:	4719                	li	a4,6
    2d7e:	00e28a63          	beq	t0,a4,2d92 <matrix_mul_const+0x52>
    2d82:	3316478b          	th.lurh	a5,a2,a7,1
    2d86:	02d782bb          	mulw	t0,a5,a3
    2d8a:	0018879b          	addiw	a5,a7,1
    2d8e:	5515d28b          	th.surw	t0,a1,a7,2
    2d92:	32f64e0b          	th.lurh	t3,a2,a5,1
    2d96:	02de03bb          	mulw	t2,t3,a3
    2d9a:	54f5d38b          	th.surw	t2,a1,a5,2
    2d9e:	2785                	addiw	a5,a5,1
    2da0:	32f64e8b          	th.lurh	t4,a2,a5,1
    2da4:	02de8f3b          	mulw	t5,t4,a3
    2da8:	54f5df0b          	th.surw	t5,a1,a5,2
    2dac:	2785                	addiw	a5,a5,1
    2dae:	32f64f8b          	th.lurh	t6,a2,a5,1
    2db2:	02df873b          	mulw	a4,t6,a3
    2db6:	54f5d70b          	th.surw	a4,a1,a5,2
    2dba:	2785                	addiw	a5,a5,1
    2dbc:	32f6428b          	th.lurh	t0,a2,a5,1
    2dc0:	02d28e3b          	mulw	t3,t0,a3
    2dc4:	54f5de0b          	th.surw	t3,a1,a5,2
    2dc8:	2785                	addiw	a5,a5,1
    2dca:	32f6438b          	th.lurh	t2,a2,a5,1
    2dce:	02d38ebb          	mulw	t4,t2,a3
    2dd2:	54f5de8b          	th.surw	t4,a1,a5,2
    2dd6:	2785                	addiw	a5,a5,1
    2dd8:	32f64f0b          	th.lurh	t5,a2,a5,1
    2ddc:	02df0fbb          	mulw	t6,t5,a3
    2de0:	54f5df8b          	th.surw	t6,a1,a5,2
    2de4:	2785                	addiw	a5,a5,1
    2de6:	08f80363          	beq	a6,a5,2e6c <matrix_mul_const+0x12c>
    2dea:	32f6470b          	th.lurh	a4,a2,a5,1
    2dee:	00178e1b          	addiw	t3,a5,1
    2df2:	33c6438b          	th.lurh	t2,a2,t3,1
    2df6:	02d702bb          	mulw	t0,a4,a3
    2dfa:	001e0f1b          	addiw	t5,t3,1
    2dfe:	33e64f8b          	th.lurh	t6,a2,t5,1
    2e02:	02d38ebb          	mulw	t4,t2,a3
    2e06:	54f5d28b          	th.surw	t0,a1,a5,2
    2e0a:	001f029b          	addiw	t0,t5,1
    2e0e:	3256470b          	th.lurh	a4,a2,t0,1
    2e12:	0012839b          	addiw	t2,t0,1
    2e16:	02df87bb          	mulw	a5,t6,a3
    2e1a:	55c5de8b          	th.surw	t4,a1,t3,2
    2e1e:	32764e8b          	th.lurh	t4,a2,t2,1
    2e22:	02d70e3b          	mulw	t3,a4,a3
    2e26:	00138f9b          	addiw	t6,t2,1
    2e2a:	55e5d78b          	th.surw	a5,a1,t5,2
    2e2e:	33f6478b          	th.lurh	a5,a2,t6,1
    2e32:	02de8f3b          	mulw	t5,t4,a3
    2e36:	5455de0b          	th.surw	t3,a1,t0,2
    2e3a:	001f8e1b          	addiw	t3,t6,1
    2e3e:	33c6470b          	th.lurh	a4,a2,t3,1
    2e42:	02d782bb          	mulw	t0,a5,a3
    2e46:	001e079b          	addiw	a5,t3,1
    2e4a:	5475df0b          	th.surw	t5,a1,t2,2
    2e4e:	32f64f0b          	th.lurh	t5,a2,a5,1
    2e52:	02d703bb          	mulw	t2,a4,a3
    2e56:	55f5d28b          	th.surw	t0,a1,t6,2
    2e5a:	02df0fbb          	mulw	t6,t5,a3
    2e5e:	55c5d38b          	th.surw	t2,a1,t3,2
    2e62:	54f5df8b          	th.surw	t6,a1,a5,2
    2e66:	2785                	addiw	a5,a5,1
    2e68:	f8f811e3          	bne	a6,a5,2dea <matrix_mul_const+0xaa>
    2e6c:	2305                	addiw	t1,t1,1
    2e6e:	011508bb          	addw	a7,a0,a7
    2e72:	0105083b          	addw	a6,a0,a6
    2e76:	ec651de3          	bne	a0,t1,2d50 <matrix_mul_const+0x10>
    2e7a:	8082                	ret
    2e7c:	00000013          	nop

0000000000002e80 <matrix_add_const>:
    2e80:	12050b63          	beqz	a0,2fb6 <matrix_add_const+0x136>
    2e84:	3c06370b          	th.extu	a4,a2,15,0
    2e88:	4801                	li	a6,0
    2e8a:	862a                	mv	a2,a0
    2e8c:	4881                	li	a7,0
    2e8e:	0001                	nop
    2e90:	410606b3          	sub	a3,a2,a6
    2e94:	0076f293          	andi	t0,a3,7
    2e98:	87c2                	mv	a5,a6
    2e9a:	08028863          	beqz	t0,2f2a <matrix_add_const+0xaa>
    2e9e:	4305                	li	t1,1
    2ea0:	06628c63          	beq	t0,t1,2f18 <matrix_add_const+0x98>
    2ea4:	4389                	li	t2,2
    2ea6:	06728263          	beq	t0,t2,2f0a <matrix_add_const+0x8a>
    2eaa:	4e0d                	li	t3,3
    2eac:	05c28863          	beq	t0,t3,2efc <matrix_add_const+0x7c>
    2eb0:	4e91                	li	t4,4
    2eb2:	03d28e63          	beq	t0,t4,2eee <matrix_add_const+0x6e>
    2eb6:	4f15                	li	t5,5
    2eb8:	03e28463          	beq	t0,t5,2ee0 <matrix_add_const+0x60>
    2ebc:	4f99                	li	t6,6
    2ebe:	01f28a63          	beq	t0,t6,2ed2 <matrix_add_const+0x52>
    2ec2:	b305c78b          	th.lurhu	a5,a1,a6,1
    2ec6:	00e786bb          	addw	a3,a5,a4
    2eca:	3305d68b          	th.surh	a3,a1,a6,1
    2ece:	0018079b          	addiw	a5,a6,1
    2ed2:	b2f5c28b          	th.lurhu	t0,a1,a5,1
    2ed6:	00e2833b          	addw	t1,t0,a4
    2eda:	32f5d30b          	th.surh	t1,a1,a5,1
    2ede:	2785                	addiw	a5,a5,1
    2ee0:	b2f5c38b          	th.lurhu	t2,a1,a5,1
    2ee4:	00e38e3b          	addw	t3,t2,a4
    2ee8:	32f5de0b          	th.surh	t3,a1,a5,1
    2eec:	2785                	addiw	a5,a5,1
    2eee:	b2f5ce8b          	th.lurhu	t4,a1,a5,1
    2ef2:	00ee8f3b          	addw	t5,t4,a4
    2ef6:	32f5df0b          	th.surh	t5,a1,a5,1
    2efa:	2785                	addiw	a5,a5,1
    2efc:	b2f5cf8b          	th.lurhu	t6,a1,a5,1
    2f00:	00ef86bb          	addw	a3,t6,a4
    2f04:	32f5d68b          	th.surh	a3,a1,a5,1
    2f08:	2785                	addiw	a5,a5,1
    2f0a:	b2f5c28b          	th.lurhu	t0,a1,a5,1
    2f0e:	00e2833b          	addw	t1,t0,a4
    2f12:	32f5d30b          	th.surh	t1,a1,a5,1
    2f16:	2785                	addiw	a5,a5,1
    2f18:	b2f5c38b          	th.lurhu	t2,a1,a5,1
    2f1c:	00e38e3b          	addw	t3,t2,a4
    2f20:	32f5de0b          	th.surh	t3,a1,a5,1
    2f24:	2785                	addiw	a5,a5,1
    2f26:	08f60263          	beq	a2,a5,2faa <matrix_add_const+0x12a>
    2f2a:	b2f5ce8b          	th.lurhu	t4,a1,a5,1
    2f2e:	00178f9b          	addiw	t6,a5,1
    2f32:	001f831b          	addiw	t1,t6,1
    2f36:	00ee8f3b          	addw	t5,t4,a4
    2f3a:	32f5df0b          	th.surh	t5,a1,a5,1
    2f3e:	b3f5c68b          	th.lurhu	a3,a1,t6,1
    2f42:	0013079b          	addiw	a5,t1,1
    2f46:	00e682bb          	addw	t0,a3,a4
    2f4a:	33f5d28b          	th.surh	t0,a1,t6,1
    2f4e:	b265c38b          	th.lurhu	t2,a1,t1,1
    2f52:	00178f9b          	addiw	t6,a5,1
    2f56:	00e38e3b          	addw	t3,t2,a4
    2f5a:	3265de0b          	th.surh	t3,a1,t1,1
    2f5e:	b2f5ce8b          	th.lurhu	t4,a1,a5,1
    2f62:	001f831b          	addiw	t1,t6,1
    2f66:	00ee8f3b          	addw	t5,t4,a4
    2f6a:	32f5df0b          	th.surh	t5,a1,a5,1
    2f6e:	b3f5c68b          	th.lurhu	a3,a1,t6,1
    2f72:	0013079b          	addiw	a5,t1,1
    2f76:	00e682bb          	addw	t0,a3,a4
    2f7a:	33f5d28b          	th.surh	t0,a1,t6,1
    2f7e:	b265c38b          	th.lurhu	t2,a1,t1,1
    2f82:	00e38e3b          	addw	t3,t2,a4
    2f86:	3265de0b          	th.surh	t3,a1,t1,1
    2f8a:	b2f5ce8b          	th.lurhu	t4,a1,a5,1
    2f8e:	00ee8f3b          	addw	t5,t4,a4
    2f92:	32f5df0b          	th.surh	t5,a1,a5,1
    2f96:	2785                	addiw	a5,a5,1
    2f98:	b2f5c38b          	th.lurhu	t2,a1,a5,1
    2f9c:	00e38e3b          	addw	t3,t2,a4
    2fa0:	32f5de0b          	th.surh	t3,a1,a5,1
    2fa4:	2785                	addiw	a5,a5,1
    2fa6:	f8f612e3          	bne	a2,a5,2f2a <matrix_add_const+0xaa>
    2faa:	2885                	addiw	a7,a7,1
    2fac:	0105083b          	addw	a6,a0,a6
    2fb0:	9e29                	addw	a2,a2,a0
    2fb2:	ed151fe3          	bne	a0,a7,2e90 <matrix_add_const+0x10>
    2fb6:	8082                	ret
    2fb8:	00000013          	nop
    2fbc:	00000013          	nop

0000000000002fc0 <matrix_mul_vect>:
    2fc0:	7c053e8b          	th.extu	t4,a0,31,0
    2fc4:	4881                	li	a7,0
    2fc6:	4e01                	li	t3,0
    2fc8:	16050d63          	beqz	a0,3142 <matrix_mul_vect+0x182>
    2fcc:	00000013          	nop
    2fd0:	007ef793          	andi	a5,t4,7
    2fd4:	4701                	li	a4,0
    2fd6:	4801                	li	a6,0
    2fd8:	c7d5                	beqz	a5,3084 <matrix_mul_vect+0xc4>
    2fda:	4305                	li	t1,1
    2fdc:	08678663          	beq	a5,t1,3068 <matrix_mul_vect+0xa8>
    2fe0:	4f09                	li	t5,2
    2fe2:	07e78a63          	beq	a5,t5,3056 <matrix_mul_vect+0x96>
    2fe6:	428d                	li	t0,3
    2fe8:	04578e63          	beq	a5,t0,3044 <matrix_mul_vect+0x84>
    2fec:	4391                	li	t2,4
    2fee:	04778263          	beq	a5,t2,3032 <matrix_mul_vect+0x72>
    2ff2:	4f95                	li	t6,5
    2ff4:	03f78663          	beq	a5,t6,3020 <matrix_mul_vect+0x60>
    2ff8:	4f19                	li	t5,6
    2ffa:	01e78a63          	beq	a5,t5,300e <matrix_mul_vect+0x4e>
    2ffe:	b316428b          	th.lurhu	t0,a2,a7,1
    3002:	0006d783          	lhu	a5,0(a3)
    3006:	883a                	mv	a6,a4
    3008:	871a                	mv	a4,t1
    300a:	28f2980b          	th.mulah	a6,t0,a5
    300e:	0117033b          	addw	t1,a4,a7
    3012:	a2e6cf8b          	th.lrhu	t6,a3,a4,1
    3016:	b266438b          	th.lurhu	t2,a2,t1,1
    301a:	0705                	addi	a4,a4,1
    301c:	29f3980b          	th.mulah	a6,t2,t6
    3020:	01170f3b          	addw	t5,a4,a7
    3024:	a2e6c78b          	th.lrhu	a5,a3,a4,1
    3028:	b3e6428b          	th.lurhu	t0,a2,t5,1
    302c:	0705                	addi	a4,a4,1
    302e:	28f2980b          	th.mulah	a6,t0,a5
    3032:	0117033b          	addw	t1,a4,a7
    3036:	a2e6cf8b          	th.lrhu	t6,a3,a4,1
    303a:	b266438b          	th.lurhu	t2,a2,t1,1
    303e:	0705                	addi	a4,a4,1
    3040:	29f3980b          	th.mulah	a6,t2,t6
    3044:	01170f3b          	addw	t5,a4,a7
    3048:	a2e6c78b          	th.lrhu	a5,a3,a4,1
    304c:	b3e6428b          	th.lurhu	t0,a2,t5,1
    3050:	0705                	addi	a4,a4,1
    3052:	28f2980b          	th.mulah	a6,t0,a5
    3056:	0117033b          	addw	t1,a4,a7
    305a:	a2e6cf8b          	th.lrhu	t6,a3,a4,1
    305e:	b266438b          	th.lurhu	t2,a2,t1,1
    3062:	0705                	addi	a4,a4,1
    3064:	29f3980b          	th.mulah	a6,t2,t6
    3068:	01170f3b          	addw	t5,a4,a7
    306c:	a2e6c30b          	th.lrhu	t1,a3,a4,1
    3070:	b3e6428b          	th.lurhu	t0,a2,t5,1
    3074:	87c2                	mv	a5,a6
    3076:	83ba                	mv	t2,a4
    3078:	2862978b          	th.mulah	a5,t0,t1
    307c:	0705                	addi	a4,a4,1
    307e:	883e                	mv	a6,a5
    3080:	0aee8563          	beq	t4,a4,312a <matrix_mul_vect+0x16a>
    3084:	01170fbb          	addw	t6,a4,a7
    3088:	b3f64f0b          	th.lurhu	t5,a2,t6,1
    308c:	a2e6c28b          	th.lrhu	t0,a3,a4,1
    3090:	87c2                	mv	a5,a6
    3092:	00170813          	addi	a6,a4,1
    3096:	285f178b          	th.mulah	a5,t5,t0
    309a:	0118033b          	addw	t1,a6,a7
    309e:	b266438b          	th.lurhu	t2,a2,t1,1
    30a2:	a306cf8b          	th.lrhu	t6,a3,a6,1
    30a6:	00270f13          	addi	t5,a4,2
    30aa:	011f02bb          	addw	t0,t5,a7
    30ae:	29f3978b          	th.mulah	a5,t2,t6
    30b2:	b256430b          	th.lurhu	t1,a2,t0,1
    30b6:	a3e6c80b          	th.lrhu	a6,a3,t5,1
    30ba:	00370393          	addi	t2,a4,3
    30be:	01138fbb          	addw	t6,t2,a7
    30c2:	2903178b          	th.mulah	a5,t1,a6
    30c6:	b3f64f0b          	th.lurhu	t5,a2,t6,1
    30ca:	a276c28b          	th.lrhu	t0,a3,t2,1
    30ce:	00470813          	addi	a6,a4,4
    30d2:	0118033b          	addw	t1,a6,a7
    30d6:	285f178b          	th.mulah	a5,t5,t0
    30da:	b266438b          	th.lurhu	t2,a2,t1,1
    30de:	a306cf8b          	th.lrhu	t6,a3,a6,1
    30e2:	00570f13          	addi	t5,a4,5
    30e6:	011f02bb          	addw	t0,t5,a7
    30ea:	29f3978b          	th.mulah	a5,t2,t6
    30ee:	b256430b          	th.lurhu	t1,a2,t0,1
    30f2:	a3e6c80b          	th.lrhu	a6,a3,t5,1
    30f6:	00670393          	addi	t2,a4,6
    30fa:	01138fbb          	addw	t6,t2,a7
    30fe:	2903178b          	th.mulah	a5,t1,a6
    3102:	b3f64f0b          	th.lurhu	t5,a2,t6,1
    3106:	a276c28b          	th.lrhu	t0,a3,t2,1
    310a:	00770393          	addi	t2,a4,7
    310e:	0113833b          	addw	t1,t2,a7
    3112:	285f178b          	th.mulah	a5,t5,t0
    3116:	a276c80b          	th.lrhu	a6,a3,t2,1
    311a:	b2664f8b          	th.lurhu	t6,a2,t1,1
    311e:	0721                	addi	a4,a4,8
    3120:	290f978b          	th.mulah	a5,t6,a6
    3124:	883e                	mv	a6,a5
    3126:	f4ee9fe3          	bne	t4,a4,3084 <matrix_mul_vect+0xc4>
    312a:	45c5d78b          	th.srw	a5,a1,t3,2
    312e:	011508bb          	addw	a7,a0,a7
    3132:	001e0793          	addi	a5,t3,1
    3136:	007e0563          	beq	t3,t2,3140 <matrix_mul_vect+0x180>
    313a:	8e3e                	mv	t3,a5
    313c:	bd51                	j	2fd0 <matrix_mul_vect+0x10>
    313e:	0001                	nop
    3140:	8082                	ret
    3142:	8082                	ret
    3144:	00000013          	nop
    3148:	00000013          	nop
    314c:	00000013          	nop

0000000000003150 <matrix_mul_matrix>:
    3150:	8eae                	mv	t4,a1
    3152:	8832                	mv	a6,a2
    3154:	85b6                	mv	a1,a3
    3156:	832a                	mv	t1,a0
    3158:	4e01                	li	t3,0
    315a:	4f81                	li	t6,0
    315c:	cd69                	beqz	a0,3236 <matrix_mul_matrix+0xe6>
    315e:	0001                	nop
    3160:	4881                	li	a7,0
    3162:	0001                	nop
    3164:	00000013          	nop
    3168:	41c30633          	sub	a2,t1,t3
    316c:	00367393          	andi	t2,a2,3
    3170:	01c88f3b          	addw	t5,a7,t3
    3174:	86c6                	mv	a3,a7
    3176:	87f2                	mv	a5,t3
    3178:	4701                	li	a4,0
    317a:	04038663          	beqz	t2,31c6 <matrix_mul_matrix+0x76>
    317e:	4285                	li	t0,1
    3180:	02538763          	beq	t2,t0,31ae <matrix_mul_matrix+0x5e>
    3184:	4609                	li	a2,2
    3186:	00c38c63          	beq	t2,a2,319e <matrix_mul_matrix+0x4e>
    318a:	b3c8468b          	th.lurhu	a3,a6,t3,1
    318e:	b315c78b          	th.lurhu	a5,a1,a7,1
    3192:	28f6970b          	th.mulah	a4,a3,a5
    3196:	001e079b          	addiw	a5,t3,1
    319a:	011506bb          	addw	a3,a0,a7
    319e:	b2f8438b          	th.lurhu	t2,a6,a5,1
    31a2:	b2d5c28b          	th.lurhu	t0,a1,a3,1
    31a6:	2785                	addiw	a5,a5,1
    31a8:	9ea9                	addw	a3,a3,a0
    31aa:	2853970b          	th.mulah	a4,t2,t0
    31ae:	b2f8438b          	th.lurhu	t2,a6,a5,1
    31b2:	b2d5c28b          	th.lurhu	t0,a1,a3,1
    31b6:	863a                	mv	a2,a4
    31b8:	2785                	addiw	a5,a5,1
    31ba:	2853960b          	th.mulah	a2,t2,t0
    31be:	9ea9                	addw	a3,a3,a0
    31c0:	8732                	mv	a4,a2
    31c2:	04f30663          	beq	t1,a5,320e <matrix_mul_matrix+0xbe>
    31c6:	b2f8438b          	th.lurhu	t2,a6,a5,1
    31ca:	b2d5c28b          	th.lurhu	t0,a1,a3,1
    31ce:	2785                	addiw	a5,a5,1
    31d0:	9ea9                	addw	a3,a3,a0
    31d2:	2853970b          	th.mulah	a4,t2,t0
    31d6:	b2d5c60b          	th.lurhu	a2,a1,a3,1
    31da:	b2f8438b          	th.lurhu	t2,a6,a5,1
    31de:	9ea9                	addw	a3,a3,a0
    31e0:	2785                	addiw	a5,a5,1
    31e2:	28c3970b          	th.mulah	a4,t2,a2
    31e6:	b2f8428b          	th.lurhu	t0,a6,a5,1
    31ea:	b2d5c38b          	th.lurhu	t2,a1,a3,1
    31ee:	2785                	addiw	a5,a5,1
    31f0:	9ea9                	addw	a3,a3,a0
    31f2:	2872970b          	th.mulah	a4,t0,t2
    31f6:	b2f8428b          	th.lurhu	t0,a6,a5,1
    31fa:	2785                	addiw	a5,a5,1
    31fc:	863a                	mv	a2,a4
    31fe:	b2d5c70b          	th.lurhu	a4,a1,a3,1
    3202:	9ea9                	addw	a3,a3,a0
    3204:	28e2960b          	th.mulah	a2,t0,a4
    3208:	8732                	mv	a4,a2
    320a:	faf31ee3          	bne	t1,a5,31c6 <matrix_mul_matrix+0x76>
    320e:	55eed60b          	th.surw	a2,t4,t5,2
    3212:	00188f1b          	addiw	t5,a7,1
    3216:	01e50563          	beq	a0,t5,3220 <matrix_mul_matrix+0xd0>
    321a:	88fa                	mv	a7,t5
    321c:	b7b1                	j	3168 <matrix_mul_matrix+0x18>
    321e:	0001                	nop
    3220:	001f861b          	addiw	a2,t6,1
    3224:	01c50e3b          	addw	t3,a0,t3
    3228:	0065033b          	addw	t1,a0,t1
    322c:	011f8463          	beq	t6,a7,3234 <matrix_mul_matrix+0xe4>
    3230:	8fb2                	mv	t6,a2
    3232:	b73d                	j	3160 <matrix_mul_matrix+0x10>
    3234:	8082                	ret
    3236:	8082                	ret
    3238:	00000013          	nop
    323c:	00000013          	nop

0000000000003240 <matrix_mul_matrix_bitextract>:
    3240:	8eae                	mv	t4,a1
    3242:	8832                	mv	a6,a2
    3244:	85b6                	mv	a1,a3
    3246:	832a                	mv	t1,a0
    3248:	4e01                	li	t3,0
    324a:	4f81                	li	t6,0
    324c:	12050763          	beqz	a0,337a <matrix_mul_matrix_bitextract+0x13a>
    3250:	4881                	li	a7,0
    3252:	0001                	nop
    3254:	00000013          	nop
    3258:	41c30733          	sub	a4,t1,t3
    325c:	00377393          	andi	t2,a4,3
    3260:	01c88f3b          	addw	t5,a7,t3
    3264:	86c6                	mv	a3,a7
    3266:	87f2                	mv	a5,t3
    3268:	4281                	li	t0,0
    326a:	06038863          	beqz	t2,32da <matrix_mul_matrix_bitextract+0x9a>
    326e:	4605                	li	a2,1
    3270:	04c38363          	beq	t2,a2,32b6 <matrix_mul_matrix_bitextract+0x76>
    3274:	4709                	li	a4,2
    3276:	02e38263          	beq	t2,a4,329a <matrix_mul_matrix_bitextract+0x5a>
    327a:	33c8478b          	th.lurh	a5,a6,t3,1
    327e:	3315c28b          	th.lurh	t0,a1,a7,1
    3282:	025786bb          	mulw	a3,a5,t0
    3286:	001e079b          	addiw	a5,t3,1
    328a:	1426b38b          	th.extu	t2,a3,5,2
    328e:	2c56b60b          	th.extu	a2,a3,11,5
    3292:	02c382bb          	mulw	t0,t2,a2
    3296:	011506bb          	addw	a3,a0,a7
    329a:	32d5c38b          	th.lurh	t2,a1,a3,1
    329e:	32f8470b          	th.lurh	a4,a6,a5,1
    32a2:	9ea9                	addw	a3,a3,a0
    32a4:	2785                	addiw	a5,a5,1
    32a6:	0277073b          	mulw	a4,a4,t2
    32aa:	1427360b          	th.extu	a2,a4,5,2
    32ae:	2c57338b          	th.extu	t2,a4,11,5
    32b2:	2476128b          	th.mulaw	t0,a2,t2
    32b6:	32d5c60b          	th.lurh	a2,a1,a3,1
    32ba:	32f8470b          	th.lurh	a4,a6,a5,1
    32be:	2785                	addiw	a5,a5,1
    32c0:	9ea9                	addw	a3,a3,a0
    32c2:	02c7073b          	mulw	a4,a4,a2
    32c6:	1427338b          	th.extu	t2,a4,5,2
    32ca:	2c57360b          	th.extu	a2,a4,11,5
    32ce:	8716                	mv	a4,t0
    32d0:	24c3970b          	th.mulaw	a4,t2,a2
    32d4:	82ba                	mv	t0,a4
    32d6:	06f30e63          	beq	t1,a5,3352 <matrix_mul_matrix_bitextract+0x112>
    32da:	32f8438b          	th.lurh	t2,a6,a5,1
    32de:	32d5c60b          	th.lurh	a2,a1,a3,1
    32e2:	2785                	addiw	a5,a5,1
    32e4:	9ea9                	addw	a3,a3,a0
    32e6:	02c3873b          	mulw	a4,t2,a2
    32ea:	1427338b          	th.extu	t2,a4,5,2
    32ee:	2c57360b          	th.extu	a2,a4,11,5
    32f2:	8716                	mv	a4,t0
    32f4:	24c3970b          	th.mulaw	a4,t2,a2
    32f8:	32d5c28b          	th.lurh	t0,a1,a3,1
    32fc:	32f8438b          	th.lurh	t2,a6,a5,1
    3300:	9ea9                	addw	a3,a3,a0
    3302:	2785                	addiw	a5,a5,1
    3304:	0253863b          	mulw	a2,t2,t0
    3308:	1426338b          	th.extu	t2,a2,5,2
    330c:	2c56328b          	th.extu	t0,a2,11,5
    3310:	2453970b          	th.mulaw	a4,t2,t0
    3314:	32f8460b          	th.lurh	a2,a6,a5,1
    3318:	32d5c38b          	th.lurh	t2,a1,a3,1
    331c:	2785                	addiw	a5,a5,1
    331e:	9ea9                	addw	a3,a3,a0
    3320:	0276063b          	mulw	a2,a2,t2
    3324:	1426328b          	th.extu	t0,a2,5,2
    3328:	2c56338b          	th.extu	t2,a2,11,5
    332c:	2472970b          	th.mulaw	a4,t0,t2
    3330:	32f8460b          	th.lurh	a2,a6,a5,1
    3334:	32d5c28b          	th.lurh	t0,a1,a3,1
    3338:	2785                	addiw	a5,a5,1
    333a:	9ea9                	addw	a3,a3,a0
    333c:	025603bb          	mulw	t2,a2,t0
    3340:	1423b28b          	th.extu	t0,t2,5,2
    3344:	2c53b60b          	th.extu	a2,t2,11,5
    3348:	24c2970b          	th.mulaw	a4,t0,a2
    334c:	82ba                	mv	t0,a4
    334e:	f8f316e3          	bne	t1,a5,32da <matrix_mul_matrix_bitextract+0x9a>
    3352:	55eed70b          	th.surw	a4,t4,t5,2
    3356:	00188f1b          	addiw	t5,a7,1
    335a:	01e50563          	beq	a0,t5,3364 <matrix_mul_matrix_bitextract+0x124>
    335e:	88fa                	mv	a7,t5
    3360:	bde5                	j	3258 <matrix_mul_matrix_bitextract+0x18>
    3362:	0001                	nop
    3364:	001f871b          	addiw	a4,t6,1
    3368:	01c50e3b          	addw	t3,a0,t3
    336c:	0065033b          	addw	t1,a0,t1
    3370:	011f8463          	beq	t6,a7,3378 <matrix_mul_matrix_bitextract+0x138>
    3374:	8fba                	mv	t6,a4
    3376:	bde9                	j	3250 <matrix_mul_matrix_bitextract+0x10>
    3378:	8082                	ret
    337a:	8082                	ret
    337c:	0000                	unimp
	...

0000000000003380 <barebones_clock>:
    3380:	000417b7          	lui	a5,0x41
    3384:	fb878293          	addi	t0,a5,-72 # 40fb8 <stop_time_val>
    3388:	0002a503          	lw	a0,0(t0)
    338c:	0042a303          	lw	t1,4(t0)
    3390:	4065053b          	subw	a0,a0,t1
    3394:	8082                	ret
    3396:	00000013          	nop
    339a:	00000013          	nop
    339e:	0001                	nop

00000000000033a0 <start_time>:
    33a0:	000417b7          	lui	a5,0x41
    33a4:	fb878293          	addi	t0,a5,-72 # 40fb8 <stop_time_val>
    33a8:	e0d2c70b          	th.lwd	a4,a3,(t0),0,3
    33ac:	40d7033b          	subw	t1,a4,a3
    33b0:	0062a223          	sw	t1,4(t0)
    33b4:	8082                	ret
    33b6:	00000013          	nop
    33ba:	00000013          	nop
    33be:	0001                	nop

00000000000033c0 <stop_time>:
    33c0:	000417b7          	lui	a5,0x41
    33c4:	fb878293          	addi	t0,a5,-72 # 40fb8 <stop_time_val>
    33c8:	e0d2c70b          	th.lwd	a4,a3,(t0),0,3
    33cc:	40d7033b          	subw	t1,a4,a3
    33d0:	0062a023          	sw	t1,0(t0)
    33d4:	8082                	ret
    33d6:	00000013          	nop
    33da:	00000013          	nop
    33de:	0001                	nop

00000000000033e0 <get_time>:
    33e0:	000417b7          	lui	a5,0x41
    33e4:	fb878293          	addi	t0,a5,-72 # 40fb8 <stop_time_val>
    33e8:	0002a503          	lw	a0,0(t0)
    33ec:	0042a303          	lw	t1,4(t0)
    33f0:	4065053b          	subw	a0,a0,t1
    33f4:	8082                	ret
    33f6:	00000013          	nop
    33fa:	00000013          	nop
    33fe:	0001                	nop

0000000000003400 <time_in_secs>:
    3400:	05f5e7b7          	lui	a5,0x5f5e
    3404:	1007829b          	addiw	t0,a5,256 # 5f5e100 <__kernel_stack+0x5e70100>
    3408:	0255553b          	divuw	a0,a0,t0
    340c:	8082                	ret
    340e:	0001                	nop

0000000000003410 <portable_init>:
    3410:	000417b7          	lui	a5,0x41
    3414:	fb878293          	addi	t0,a5,-72 # 40fb8 <stop_time_val>
    3418:	e0d2c70b          	th.lwd	a4,a3,(t0),0,3
    341c:	4385                	li	t2,1
    341e:	00750023          	sb	t2,0(a0)
    3422:	40d7033b          	subw	t1,a4,a3
    3426:	0062a223          	sw	t1,4(t0)
    342a:	8082                	ret
    342c:	00000013          	nop

0000000000003430 <portable_fini>:
    3430:	00050023          	sb	zero,0(a0)
    3434:	8082                	ret
	...

0000000000003440 <core_bench_state>:
    3440:	7131                	addi	sp,sp,-192
    3442:	8fae                	mv	t6,a1
    3444:	ecee                	sd	s11,88(sp)
    3446:	f0ea                	sd	s10,96(sp)
    3448:	f4e6                	sd	s9,104(sp)
    344a:	f8e2                	sd	s8,112(sp)
    344c:	fcde                	sd	s7,120(sp)
    344e:	e15a                	sd	s6,128(sp)
    3450:	e556                	sd	s5,136(sp)
    3452:	e952                	sd	s4,144(sp)
    3454:	ed4e                	sd	s3,152(sp)
    3456:	f14a                	sd	s2,160(sp)
    3458:	f526                	sd	s1,168(sp)
    345a:	f922                	sd	s0,176(sp)
    345c:	fd06                	sd	ra,184(sp)
    345e:	000fce03          	lbu	t3,0(t6)
    3462:	e802                	sd	zero,16(sp)
    3464:	ec02                	sd	zero,24(sp)
    3466:	f002                	sd	zero,32(sp)
    3468:	f402                	sd	zero,40(sp)
    346a:	f802                	sd	zero,48(sp)
    346c:	fc02                	sd	zero,56(sp)
    346e:	e082                	sd	zero,64(sp)
    3470:	e482                	sd	zero,72(sp)
    3472:	e03a                	sd	a4,0(sp)
    3474:	8eaa                	mv	t4,a0
    3476:	85be                	mv	a1,a5
    3478:	8a36                	mv	s4,a3
    347a:	700e0263          	beqz	t3,3b7e <core_bench_state+0x73e>
    347e:	877e                	mv	a4,t6
    3480:	87f2                	mv	a5,t3
    3482:	4881                	li	a7,0
    3484:	4901                	li	s2,0
    3486:	4281                	li	t0,0
    3488:	4401                	li	s0,0
    348a:	4381                	li	t2,0
    348c:	4b01                	li	s6,0
    348e:	4c01                	li	s8,0
    3490:	4c81                	li	s9,0
    3492:	4981                	li	s3,0
    3494:	4481                	li	s1,0
    3496:	4501                	li	a0,0
    3498:	4a81                	li	s5,0
    349a:	4d01                	li	s10,0
    349c:	4b81                	li	s7,0
    349e:	01010813          	addi	a6,sp,16
    34a2:	02c00313          	li	t1,44
    34a6:	02e00693          	li	a3,46
    34aa:	04500d93          	li	s11,69
    34ae:	4f25                	li	t5,9
    34b0:	e472                	sd	t3,8(sp)
    34b2:	0001                	nop
    34b4:	00000013          	nop
    34b8:	72678f63          	beq	a5,t1,3bf6 <core_bench_state+0x7b6>
    34bc:	30d78e63          	beq	a5,a3,37d8 <core_bench_state+0x398>
    34c0:	1af6e863          	bltu	a3,a5,3670 <core_bench_state+0x230>
    34c4:	fd578e1b          	addiw	t3,a5,-43
    34c8:	0fde7793          	andi	a5,t3,253
    34cc:	2c078263          	beqz	a5,3790 <core_bench_state+0x350>
    34d0:	4505                	li	a0,1
    34d2:	2b85                	addiw	s7,s7,1
    34d4:	2a85                	addiw	s5,s5,1
    34d6:	0705                	addi	a4,a4,1
    34d8:	8d2a                	mv	s10,a0
    34da:	87aa                	mv	a5,a0
    34dc:	00000013          	nop
    34e0:	54f84e0b          	th.lurw	t3,a6,a5,2
    34e4:	2e05                	addiw	t3,t3,1
    34e6:	54f85e0b          	th.surw	t3,a6,a5,2
    34ea:	00074783          	lbu	a5,0(a4)
    34ee:	f7e9                	bnez	a5,34b8 <core_bench_state+0x78>
    34f0:	6e22                	ld	t3,8(sp)
    34f2:	00088363          	beqz	a7,34f8 <core_bench_state+0xb8>
    34f6:	c4ca                	sw	s2,72(sp)
    34f8:	00028363          	beqz	t0,34fe <core_bench_state+0xbe>
    34fc:	de22                	sw	s0,60(sp)
    34fe:	00038363          	beqz	t2,3504 <core_bench_state+0xc4>
    3502:	c2da                	sw	s6,68(sp)
    3504:	000c0363          	beqz	s8,350a <core_bench_state+0xca>
    3508:	c0e6                	sw	s9,64(sp)
    350a:	00098363          	beqz	s3,3510 <core_bench_state+0xd0>
    350e:	dc26                	sw	s1,56(sp)
    3510:	c111                	beqz	a0,3514 <core_bench_state+0xd4>
    3512:	d856                	sw	s5,48(sp)
    3514:	000d0363          	beqz	s10,351a <core_bench_state+0xda>
    3518:	da5e                	sw	s7,52(sp)
    351a:	7c0eba8b          	th.extu	s5,t4,31,0
    351e:	015f8333          	add	t1,t6,s5
    3522:	2e6ff463          	bgeu	t6,t1,380a <core_bench_state+0x3ca>
    3526:	6982                	ld	s3,0(sp)
    3528:	4485                	li	s1,1
    352a:	8dfe                	mv	s11,t6
    352c:	72999c63          	bne	s3,s1,3c64 <core_bench_state+0x824>
    3530:	ffffcf13          	not	t5,t6
    3534:	01e30c33          	add	s8,t1,t5
    3538:	007c7b13          	andi	s6,s8,7
    353c:	02c00e93          	li	t4,44
    3540:	0a0b0063          	beqz	s6,35e0 <core_bench_state+0x1a0>
    3544:	01de0663          	beq	t3,t4,3550 <core_bench_state+0x110>
    3548:	00ce4733          	xor	a4,t3,a2
    354c:	00ef8023          	sb	a4,0(t6)
    3550:	001f8d93          	addi	s11,t6,1
    3554:	2a6df763          	bgeu	s11,t1,3802 <core_bench_state+0x3c2>
    3558:	4405                	li	s0,1
    355a:	000dce03          	lbu	t3,0(s11)
    355e:	088b0163          	beq	s6,s0,35e0 <core_bench_state+0x1a0>
    3562:	4509                	li	a0,2
    3564:	06ab0663          	beq	s6,a0,35d0 <core_bench_state+0x190>
    3568:	490d                	li	s2,3
    356a:	052b0b63          	beq	s6,s2,35c0 <core_bench_state+0x180>
    356e:	4b91                	li	s7,4
    3570:	057b0063          	beq	s6,s7,35b0 <core_bench_state+0x170>
    3574:	4d15                	li	s10,5
    3576:	03ab0563          	beq	s6,s10,35a0 <core_bench_state+0x160>
    357a:	4899                	li	a7,6
    357c:	011b0a63          	beq	s6,a7,3590 <core_bench_state+0x150>
    3580:	01de0663          	beq	t3,t4,358c <core_bench_state+0x14c>
    3584:	00ce42b3          	xor	t0,t3,a2
    3588:	005d8023          	sb	t0,0(s11)
    358c:	881dce0b          	th.lbuib	t3,(s11),1,0
    3590:	01de0663          	beq	t3,t4,359c <core_bench_state+0x15c>
    3594:	00ce43b3          	xor	t2,t3,a2
    3598:	007d8023          	sb	t2,0(s11)
    359c:	881dce0b          	th.lbuib	t3,(s11),1,0
    35a0:	01de0663          	beq	t3,t4,35ac <core_bench_state+0x16c>
    35a4:	00ce4e33          	xor	t3,t3,a2
    35a8:	01cd8023          	sb	t3,0(s11)
    35ac:	881dce0b          	th.lbuib	t3,(s11),1,0
    35b0:	01de0663          	beq	t3,t4,35bc <core_bench_state+0x17c>
    35b4:	00ce4ab3          	xor	s5,t3,a2
    35b8:	015d8023          	sb	s5,0(s11)
    35bc:	881dce0b          	th.lbuib	t3,(s11),1,0
    35c0:	01de0663          	beq	t3,t4,35cc <core_bench_state+0x18c>
    35c4:	00ce44b3          	xor	s1,t3,a2
    35c8:	009d8023          	sb	s1,0(s11)
    35cc:	881dce0b          	th.lbuib	t3,(s11),1,0
    35d0:	01de0663          	beq	t3,t4,35dc <core_bench_state+0x19c>
    35d4:	00ce49b3          	xor	s3,t3,a2
    35d8:	013d8023          	sb	s3,0(s11)
    35dc:	881dce0b          	th.lbuib	t3,(s11),1,0
    35e0:	01de0663          	beq	t3,t4,35ec <core_bench_state+0x1ac>
    35e4:	00ce4cb3          	xor	s9,t3,a2
    35e8:	019d8023          	sb	s9,0(s11)
    35ec:	001d8693          	addi	a3,s11,1
    35f0:	2066f963          	bgeu	a3,t1,3802 <core_bench_state+0x3c2>
    35f4:	001dc503          	lbu	a0,1(s11)
    35f8:	01d50663          	beq	a0,t4,3604 <core_bench_state+0x1c4>
    35fc:	00c548b3          	xor	a7,a0,a2
    3600:	011d80a3          	sb	a7,1(s11)
    3604:	0016cd83          	lbu	s11,1(a3)
    3608:	01dd8663          	beq	s11,t4,3614 <core_bench_state+0x1d4>
    360c:	00cdc7b3          	xor	a5,s11,a2
    3610:	00f680a3          	sb	a5,1(a3)
    3614:	0026c983          	lbu	s3,2(a3)
    3618:	01d98663          	beq	s3,t4,3624 <core_bench_state+0x1e4>
    361c:	00c9c433          	xor	s0,s3,a2
    3620:	00868123          	sb	s0,2(a3)
    3624:	0036c903          	lbu	s2,3(a3)
    3628:	01d90663          	beq	s2,t4,3634 <core_bench_state+0x1f4>
    362c:	00c94c33          	xor	s8,s2,a2
    3630:	018681a3          	sb	s8,3(a3)
    3634:	0046ce03          	lbu	t3,4(a3)
    3638:	01de0663          	beq	t3,t4,3644 <core_bench_state+0x204>
    363c:	00ce4d33          	xor	s10,t3,a2
    3640:	01a68223          	sb	s10,4(a3)
    3644:	0056cb83          	lbu	s7,5(a3)
    3648:	01db8663          	beq	s7,t4,3654 <core_bench_state+0x214>
    364c:	00cbcab3          	xor	s5,s7,a2
    3650:	015682a3          	sb	s5,5(a3)
    3654:	0066c703          	lbu	a4,6(a3)
    3658:	01d70663          	beq	a4,t4,3664 <core_bench_state+0x224>
    365c:	00c74f33          	xor	t5,a4,a2
    3660:	01e68323          	sb	t5,6(a3)
    3664:	0076ce03          	lbu	t3,7(a3)
    3668:	00768d93          	addi	s11,a3,7
    366c:	bf95                	j	35e0 <core_bench_state+0x1a0>
    366e:	0001                	nop
    3670:	fd07879b          	addiw	a5,a5,-48
    3674:	0ff7f513          	zext.b	a0,a5
    3678:	e4af6ce3          	bltu	t5,a0,34d0 <core_bench_state+0x90>
    367c:	8817478b          	th.lbuib	a5,(a4),1,0
    3680:	2a85                	addiw	s5,s5,1
    3682:	cbf5                	beqz	a5,3776 <core_bench_state+0x336>
    3684:	58678063          	beq	a5,t1,3c04 <core_bench_state+0x7c4>
    3688:	00d78e63          	beq	a5,a3,36a4 <core_bench_state+0x264>
    368c:	fd078e1b          	addiw	t3,a5,-48
    3690:	0ffe7513          	zext.b	a0,t3
    3694:	0caf7e63          	bgeu	t5,a0,3770 <core_bench_state+0x330>
    3698:	4c05                	li	s8,1
    369a:	2c85                	addiw	s9,s9,1
    369c:	0705                	addi	a4,a4,1
    369e:	8562                	mv	a0,s8
    36a0:	87e2                	mv	a5,s8
    36a2:	bd3d                	j	34e0 <core_bench_state+0xa0>
    36a4:	00174503          	lbu	a0,1(a4)
    36a8:	2c85                	addiw	s9,s9,1
    36aa:	00170e13          	addi	t3,a4,1
    36ae:	60050b63          	beqz	a0,3cc4 <core_bench_state+0x884>
    36b2:	60650f63          	beq	a0,t1,3cd0 <core_bench_state+0x890>
    36b6:	4c05                	li	s8,1
    36b8:	0df57713          	andi	a4,a0,223
    36bc:	03b70063          	beq	a4,s11,36dc <core_bench_state+0x29c>
    36c0:	fd05051b          	addiw	a0,a0,-48
    36c4:	0ff57793          	zext.b	a5,a0
    36c8:	0aff7a63          	bgeu	t5,a5,377c <core_bench_state+0x33c>
    36cc:	4385                	li	t2,1
    36ce:	2b05                	addiw	s6,s6,1
    36d0:	001e0713          	addi	a4,t3,1
    36d4:	851e                	mv	a0,t2
    36d6:	879e                	mv	a5,t2
    36d8:	b521                	j	34e0 <core_bench_state+0xa0>
    36da:	0001                	nop
    36dc:	001e4383          	lbu	t2,1(t3)
    36e0:	2b05                	addiw	s6,s6,1
    36e2:	001e0713          	addi	a4,t3,1
    36e6:	56038263          	beqz	t2,3c4a <core_bench_state+0x80a>
    36ea:	5a638c63          	beq	t2,t1,3ca2 <core_bench_state+0x862>
    36ee:	fd53829b          	addiw	t0,t2,-43
    36f2:	0fd2f793          	andi	a5,t0,253
    36f6:	2405                	addiw	s0,s0,1
    36f8:	002e0713          	addi	a4,t3,2
    36fc:	c791                	beqz	a5,3708 <core_bench_state+0x2c8>
    36fe:	4285                	li	t0,1
    3700:	8396                	mv	t2,t0
    3702:	8516                	mv	a0,t0
    3704:	8796                	mv	a5,t0
    3706:	bbe9                	j	34e0 <core_bench_state+0xa0>
    3708:	002e4503          	lbu	a0,2(t3)
    370c:	54050363          	beqz	a0,3c52 <core_bench_state+0x812>
    3710:	58650363          	beq	a0,t1,3c96 <core_bench_state+0x856>
    3714:	fd05089b          	addiw	a7,a0,-48
    3718:	0ff8f393          	zext.b	t2,a7
    371c:	2905                	addiw	s2,s2,1
    371e:	003e0713          	addi	a4,t3,3
    3722:	007f7963          	bgeu	t5,t2,3734 <core_bench_state+0x2f4>
    3726:	4885                	li	a7,1
    3728:	82c6                	mv	t0,a7
    372a:	83c6                	mv	t2,a7
    372c:	8546                	mv	a0,a7
    372e:	87c6                	mv	a5,a7
    3730:	bb45                	j	34e0 <core_bench_state+0xa0>
    3732:	0001                	nop
    3734:	003e4783          	lbu	a5,3(t3)
    3738:	c78d                	beqz	a5,3762 <core_bench_state+0x322>
    373a:	4a678463          	beq	a5,t1,3be2 <core_bench_state+0x7a2>
    373e:	fd078e1b          	addiw	t3,a5,-48
    3742:	0ffe7293          	zext.b	t0,t3
    3746:	005f7b63          	bgeu	t5,t0,375c <core_bench_state+0x31c>
    374a:	4885                	li	a7,1
    374c:	2b85                	addiw	s7,s7,1
    374e:	0705                	addi	a4,a4,1
    3750:	82c6                	mv	t0,a7
    3752:	83c6                	mv	t2,a7
    3754:	8546                	mv	a0,a7
    3756:	8d46                	mv	s10,a7
    3758:	87c6                	mv	a5,a7
    375a:	b359                	j	34e0 <core_bench_state+0xa0>
    375c:	8817478b          	th.lbuib	a5,(a4),1,0
    3760:	ffe9                	bnez	a5,373a <core_bench_state+0x2fa>
    3762:	4885                	li	a7,1
    3764:	82c6                	mv	t0,a7
    3766:	83c6                	mv	t2,a7
    3768:	8546                	mv	a0,a7
    376a:	479d                	li	a5,7
    376c:	bb95                	j	34e0 <core_bench_state+0xa0>
    376e:	0001                	nop
    3770:	8817478b          	th.lbuib	a5,(a4),1,0
    3774:	fb81                	bnez	a5,3684 <core_bench_state+0x244>
    3776:	4505                	li	a0,1
    3778:	4791                	li	a5,4
    377a:	b39d                	j	34e0 <core_bench_state+0xa0>
    377c:	881e450b          	th.lbuib	a0,(t3),1,0
    3780:	c135                	beqz	a0,37e4 <core_bench_state+0x3a4>
    3782:	f2651be3          	bne	a0,t1,36b8 <core_bench_state+0x278>
    3786:	8772                	mv	a4,t3
    3788:	4505                	li	a0,1
    378a:	4795                	li	a5,5
    378c:	0705                	addi	a4,a4,1
    378e:	bb89                	j	34e0 <core_bench_state+0xa0>
    3790:	00174503          	lbu	a0,1(a4)
    3794:	2a85                	addiw	s5,s5,1
    3796:	00170e13          	addi	t3,a4,1
    379a:	56050763          	beqz	a0,3d08 <core_bench_state+0x8c8>
    379e:	54650f63          	beq	a0,t1,3cfc <core_bench_state+0x8bc>
    37a2:	fd05099b          	addiw	s3,a0,-48
    37a6:	0ff9f793          	zext.b	a5,s3
    37aa:	00ff7b63          	bgeu	t5,a5,37c0 <core_bench_state+0x380>
    37ae:	02d50f63          	beq	a0,a3,37ec <core_bench_state+0x3ac>
    37b2:	4985                	li	s3,1
    37b4:	2485                	addiw	s1,s1,1
    37b6:	0709                	addi	a4,a4,2
    37b8:	854e                	mv	a0,s3
    37ba:	87ce                	mv	a5,s3
    37bc:	b315                	j	34e0 <core_bench_state+0xa0>
    37be:	0001                	nop
    37c0:	8827478b          	th.lbuib	a5,(a4),2,0
    37c4:	2485                	addiw	s1,s1,1
    37c6:	4985                	li	s3,1
    37c8:	4e078563          	beqz	a5,3cb2 <core_bench_state+0x872>
    37cc:	ea679ee3          	bne	a5,t1,3688 <core_bench_state+0x248>
    37d0:	854e                	mv	a0,s3
    37d2:	4791                	li	a5,4
    37d4:	0705                	addi	a4,a4,1
    37d6:	b329                	j	34e0 <core_bench_state+0xa0>
    37d8:	00174503          	lbu	a0,1(a4)
    37dc:	2a85                	addiw	s5,s5,1
    37de:	00170e13          	addi	t3,a4,1
    37e2:	f145                	bnez	a0,3782 <core_bench_state+0x342>
    37e4:	8772                	mv	a4,t3
    37e6:	4505                	li	a0,1
    37e8:	4795                	li	a5,5
    37ea:	b9dd                	j	34e0 <core_bench_state+0xa0>
    37ec:	00274503          	lbu	a0,2(a4)
    37f0:	2485                	addiw	s1,s1,1
    37f2:	00270e13          	addi	t3,a4,2
    37f6:	52050563          	beqz	a0,3d20 <core_bench_state+0x8e0>
    37fa:	50650c63          	beq	a0,t1,3d12 <core_bench_state+0x8d2>
    37fe:	4985                	li	s3,1
    3800:	bd65                	j	36b8 <core_bench_state+0x278>
    3802:	000fce03          	lbu	t3,0(t6)
    3806:	400e0363          	beqz	t3,3c0c <core_bench_state+0x7cc>
    380a:	59c2                	lw	s3,48(sp)
    380c:	5b52                	lw	s6,52(sp)
    380e:	5462                	lw	s0,56(sp)
    3810:	56f2                	lw	a3,60(sp)
    3812:	4c06                	lw	s8,64(sp)
    3814:	4a96                	lw	s5,68(sp)
    3816:	44a6                	lw	s1,72(sp)
    3818:	87f2                	mv	a5,t3
    381a:	877e                	mv	a4,t6
    381c:	4601                	li	a2,0
    381e:	4281                	li	t0,0
    3820:	4381                	li	t2,0
    3822:	4b81                	li	s7,0
    3824:	4901                	li	s2,0
    3826:	4f01                	li	t5,0
    3828:	4c81                	li	s9,0
    382a:	02c00893          	li	a7,44
    382e:	02e00513          	li	a0,46
    3832:	04500d13          	li	s10,69
    3836:	4ea5                	li	t4,9
    3838:	3b178c63          	beq	a5,a7,3bf0 <core_bench_state+0x7b0>
    383c:	30a78a63          	beq	a5,a0,3b50 <core_bench_state+0x710>
    3840:	1af56263          	bltu	a0,a5,39e4 <core_bench_state+0x5a4>
    3844:	fd578f1b          	addiw	t5,a5,-43
    3848:	0fdf7793          	andi	a5,t5,253
    384c:	2a078e63          	beqz	a5,3b08 <core_bench_state+0x6c8>
    3850:	4f05                	li	t5,1
    3852:	2b05                	addiw	s6,s6,1
    3854:	2985                	addiw	s3,s3,1
    3856:	0705                	addi	a4,a4,1
    3858:	8cfa                	mv	s9,t5
    385a:	87fa                	mv	a5,t5
    385c:	00000013          	nop
    3860:	54f84d8b          	th.lurw	s11,a6,a5,2
    3864:	2d85                	addiw	s11,s11,1
    3866:	54f85d8b          	th.surw	s11,a6,a5,2
    386a:	00074783          	lbu	a5,0(a4)
    386e:	f7e9                	bnez	a5,3838 <core_bench_state+0x3f8>
    3870:	c211                	beqz	a2,3874 <core_bench_state+0x434>
    3872:	c4a6                	sw	s1,72(sp)
    3874:	00028363          	beqz	t0,387a <core_bench_state+0x43a>
    3878:	de36                	sw	a3,60(sp)
    387a:	00038363          	beqz	t2,3880 <core_bench_state+0x440>
    387e:	c2d6                	sw	s5,68(sp)
    3880:	000b8363          	beqz	s7,3886 <core_bench_state+0x446>
    3884:	c0e2                	sw	s8,64(sp)
    3886:	00090363          	beqz	s2,388c <core_bench_state+0x44c>
    388a:	dc22                	sw	s0,56(sp)
    388c:	000f0363          	beqz	t5,3892 <core_bench_state+0x452>
    3890:	d84e                	sw	s3,48(sp)
    3892:	000c8363          	beqz	s9,3898 <core_bench_state+0x458>
    3896:	da5a                	sw	s6,52(sp)
    3898:	4542                	lw	a0,16(sp)
    389a:	2e6ffa63          	bgeu	t6,t1,3b8e <core_bench_state+0x74e>
    389e:	6402                	ld	s0,0(sp)
    38a0:	4985                	li	s3,1
    38a2:	39341063          	bne	s0,s3,3c22 <core_bench_state+0x7e2>
    38a6:	ffffcd13          	not	s10,t6
    38aa:	01a30eb3          	add	t4,t1,s10
    38ae:	007efb93          	andi	s7,t4,7
    38b2:	02c00893          	li	a7,44
    38b6:	080b8f63          	beqz	s7,3954 <core_bench_state+0x514>
    38ba:	011e0663          	beq	t3,a7,38c6 <core_bench_state+0x486>
    38be:	014e4ab3          	xor	s5,t3,s4
    38c2:	015f8023          	sb	s5,0(t6)
    38c6:	0f85                	addi	t6,t6,1
    38c8:	2c6ff363          	bgeu	t6,t1,3b8e <core_bench_state+0x74e>
    38cc:	4705                	li	a4,1
    38ce:	000fce03          	lbu	t3,0(t6)
    38d2:	08eb8163          	beq	s7,a4,3954 <core_bench_state+0x514>
    38d6:	4689                	li	a3,2
    38d8:	06db8663          	beq	s7,a3,3944 <core_bench_state+0x504>
    38dc:	4f0d                	li	t5,3
    38de:	05eb8b63          	beq	s7,t5,3934 <core_bench_state+0x4f4>
    38e2:	4491                	li	s1,4
    38e4:	049b8063          	beq	s7,s1,3924 <core_bench_state+0x4e4>
    38e8:	4b15                	li	s6,5
    38ea:	036b8563          	beq	s7,s6,3914 <core_bench_state+0x4d4>
    38ee:	4c99                	li	s9,6
    38f0:	019b8a63          	beq	s7,s9,3904 <core_bench_state+0x4c4>
    38f4:	011e0663          	beq	t3,a7,3900 <core_bench_state+0x4c0>
    38f8:	014e4633          	xor	a2,t3,s4
    38fc:	00cf8023          	sb	a2,0(t6)
    3900:	881fce0b          	th.lbuib	t3,(t6),1,0
    3904:	011e0663          	beq	t3,a7,3910 <core_bench_state+0x4d0>
    3908:	014e42b3          	xor	t0,t3,s4
    390c:	005f8023          	sb	t0,0(t6)
    3910:	881fce0b          	th.lbuib	t3,(t6),1,0
    3914:	011e0663          	beq	t3,a7,3920 <core_bench_state+0x4e0>
    3918:	014e43b3          	xor	t2,t3,s4
    391c:	007f8023          	sb	t2,0(t6)
    3920:	881fce0b          	th.lbuib	t3,(t6),1,0
    3924:	011e0663          	beq	t3,a7,3930 <core_bench_state+0x4f0>
    3928:	014e4db3          	xor	s11,t3,s4
    392c:	01bf8023          	sb	s11,0(t6)
    3930:	881fce0b          	th.lbuib	t3,(t6),1,0
    3934:	011e0663          	beq	t3,a7,3940 <core_bench_state+0x500>
    3938:	014e47b3          	xor	a5,t3,s4
    393c:	00ff8023          	sb	a5,0(t6)
    3940:	881fce0b          	th.lbuib	t3,(t6),1,0
    3944:	011e0663          	beq	t3,a7,3950 <core_bench_state+0x510>
    3948:	014e49b3          	xor	s3,t3,s4
    394c:	013f8023          	sb	s3,0(t6)
    3950:	881fce0b          	th.lbuib	t3,(t6),1,0
    3954:	011e0663          	beq	t3,a7,3960 <core_bench_state+0x520>
    3958:	014e4433          	xor	s0,t3,s4
    395c:	008f8023          	sb	s0,0(t6)
    3960:	001f8913          	addi	s2,t6,1
    3964:	22697563          	bgeu	s2,t1,3b8e <core_bench_state+0x74e>
    3968:	001fce03          	lbu	t3,1(t6)
    396c:	011e0663          	beq	t3,a7,3978 <core_bench_state+0x538>
    3970:	014e4d33          	xor	s10,t3,s4
    3974:	01af80a3          	sb	s10,1(t6)
    3978:	00194e83          	lbu	t4,1(s2)
    397c:	011e8663          	beq	t4,a7,3988 <core_bench_state+0x548>
    3980:	014ecbb3          	xor	s7,t4,s4
    3984:	017900a3          	sb	s7,1(s2)
    3988:	00294a83          	lbu	s5,2(s2)
    398c:	011a8663          	beq	s5,a7,3998 <core_bench_state+0x558>
    3990:	014ac733          	xor	a4,s5,s4
    3994:	00e90123          	sb	a4,2(s2)
    3998:	00394683          	lbu	a3,3(s2)
    399c:	01168663          	beq	a3,a7,39a8 <core_bench_state+0x568>
    39a0:	0146cf33          	xor	t5,a3,s4
    39a4:	01e901a3          	sb	t5,3(s2)
    39a8:	00494483          	lbu	s1,4(s2)
    39ac:	01148663          	beq	s1,a7,39b8 <core_bench_state+0x578>
    39b0:	0144cb33          	xor	s6,s1,s4
    39b4:	01690223          	sb	s6,4(s2)
    39b8:	00594c83          	lbu	s9,5(s2)
    39bc:	011c8663          	beq	s9,a7,39c8 <core_bench_state+0x588>
    39c0:	014cc633          	xor	a2,s9,s4
    39c4:	00c902a3          	sb	a2,5(s2)
    39c8:	00694283          	lbu	t0,6(s2)
    39cc:	01128663          	beq	t0,a7,39d8 <core_bench_state+0x598>
    39d0:	0142c3b3          	xor	t2,t0,s4
    39d4:	00790323          	sb	t2,6(s2)
    39d8:	00794e03          	lbu	t3,7(s2)
    39dc:	00790f93          	addi	t6,s2,7
    39e0:	bf95                	j	3954 <core_bench_state+0x514>
    39e2:	0001                	nop
    39e4:	fd07879b          	addiw	a5,a5,-48
    39e8:	0ff7fd93          	zext.b	s11,a5
    39ec:	e7bee2e3          	bltu	t4,s11,3850 <core_bench_state+0x410>
    39f0:	8817478b          	th.lbuib	a5,(a4),1,0
    39f4:	2985                	addiw	s3,s3,1
    39f6:	cbf5                	beqz	a5,3aea <core_bench_state+0x6aa>
    39f8:	21178263          	beq	a5,a7,3bfc <core_bench_state+0x7bc>
    39fc:	00a78e63          	beq	a5,a0,3a18 <core_bench_state+0x5d8>
    3a00:	fd078d9b          	addiw	s11,a5,-48
    3a04:	0ffdff13          	zext.b	t5,s11
    3a08:	0deefe63          	bgeu	t4,t5,3ae4 <core_bench_state+0x6a4>
    3a0c:	4b85                	li	s7,1
    3a0e:	2c05                	addiw	s8,s8,1
    3a10:	0705                	addi	a4,a4,1
    3a12:	8f5e                	mv	t5,s7
    3a14:	87de                	mv	a5,s7
    3a16:	b5a9                	j	3860 <core_bench_state+0x420>
    3a18:	00174f03          	lbu	t5,1(a4)
    3a1c:	2c05                	addiw	s8,s8,1
    3a1e:	00170d93          	addi	s11,a4,1
    3a22:	280f0c63          	beqz	t5,3cba <core_bench_state+0x87a>
    3a26:	2b1f0c63          	beq	t5,a7,3cde <core_bench_state+0x89e>
    3a2a:	4b85                	li	s7,1
    3a2c:	0dff7713          	andi	a4,t5,223
    3a30:	03a70063          	beq	a4,s10,3a50 <core_bench_state+0x610>
    3a34:	fd0f0f1b          	addiw	t5,t5,-48
    3a38:	0fff7793          	zext.b	a5,t5
    3a3c:	0afefa63          	bgeu	t4,a5,3af0 <core_bench_state+0x6b0>
    3a40:	4385                	li	t2,1
    3a42:	2a85                	addiw	s5,s5,1
    3a44:	001d8713          	addi	a4,s11,1
    3a48:	8f1e                	mv	t5,t2
    3a4a:	879e                	mv	a5,t2
    3a4c:	bd11                	j	3860 <core_bench_state+0x420>
    3a4e:	0001                	nop
    3a50:	001dc383          	lbu	t2,1(s11)
    3a54:	2a85                	addiw	s5,s5,1
    3a56:	001d8713          	addi	a4,s11,1
    3a5a:	20038163          	beqz	t2,3c5c <core_bench_state+0x81c>
    3a5e:	23138763          	beq	t2,a7,3c8c <core_bench_state+0x84c>
    3a62:	fd53829b          	addiw	t0,t2,-43
    3a66:	0fd2f793          	andi	a5,t0,253
    3a6a:	2685                	addiw	a3,a3,1
    3a6c:	002d8713          	addi	a4,s11,2
    3a70:	c791                	beqz	a5,3a7c <core_bench_state+0x63c>
    3a72:	4285                	li	t0,1
    3a74:	8396                	mv	t2,t0
    3a76:	8f16                	mv	t5,t0
    3a78:	8796                	mv	a5,t0
    3a7a:	b3dd                	j	3860 <core_bench_state+0x420>
    3a7c:	002dcf03          	lbu	t5,2(s11)
    3a80:	1c0f0063          	beqz	t5,3c40 <core_bench_state+0x800>
    3a84:	1f1f0e63          	beq	t5,a7,3c80 <core_bench_state+0x840>
    3a88:	fd0f061b          	addiw	a2,t5,-48
    3a8c:	0ff67393          	zext.b	t2,a2
    3a90:	2485                	addiw	s1,s1,1
    3a92:	003d8713          	addi	a4,s11,3
    3a96:	007ef963          	bgeu	t4,t2,3aa8 <core_bench_state+0x668>
    3a9a:	4605                	li	a2,1
    3a9c:	82b2                	mv	t0,a2
    3a9e:	83b2                	mv	t2,a2
    3aa0:	8f32                	mv	t5,a2
    3aa2:	87b2                	mv	a5,a2
    3aa4:	bb75                	j	3860 <core_bench_state+0x420>
    3aa6:	0001                	nop
    3aa8:	003dc783          	lbu	a5,3(s11)
    3aac:	c78d                	beqz	a5,3ad6 <core_bench_state+0x696>
    3aae:	13178363          	beq	a5,a7,3bd4 <core_bench_state+0x794>
    3ab2:	fd078d9b          	addiw	s11,a5,-48
    3ab6:	0ffdf293          	zext.b	t0,s11
    3aba:	005efb63          	bgeu	t4,t0,3ad0 <core_bench_state+0x690>
    3abe:	4605                	li	a2,1
    3ac0:	2b05                	addiw	s6,s6,1
    3ac2:	0705                	addi	a4,a4,1
    3ac4:	82b2                	mv	t0,a2
    3ac6:	83b2                	mv	t2,a2
    3ac8:	8f32                	mv	t5,a2
    3aca:	8cb2                	mv	s9,a2
    3acc:	87b2                	mv	a5,a2
    3ace:	bb49                	j	3860 <core_bench_state+0x420>
    3ad0:	8817478b          	th.lbuib	a5,(a4),1,0
    3ad4:	ffe9                	bnez	a5,3aae <core_bench_state+0x66e>
    3ad6:	4605                	li	a2,1
    3ad8:	82b2                	mv	t0,a2
    3ada:	83b2                	mv	t2,a2
    3adc:	8f32                	mv	t5,a2
    3ade:	479d                	li	a5,7
    3ae0:	b341                	j	3860 <core_bench_state+0x420>
    3ae2:	0001                	nop
    3ae4:	8817478b          	th.lbuib	a5,(a4),1,0
    3ae8:	fb81                	bnez	a5,39f8 <core_bench_state+0x5b8>
    3aea:	4f05                	li	t5,1
    3aec:	4791                	li	a5,4
    3aee:	bb8d                	j	3860 <core_bench_state+0x420>
    3af0:	881dcf0b          	th.lbuib	t5,(s11),1,0
    3af4:	060f0563          	beqz	t5,3b5e <core_bench_state+0x71e>
    3af8:	f31f1ae3          	bne	t5,a7,3a2c <core_bench_state+0x5ec>
    3afc:	876e                	mv	a4,s11
    3afe:	4f05                	li	t5,1
    3b00:	4795                	li	a5,5
    3b02:	0705                	addi	a4,a4,1
    3b04:	bbb1                	j	3860 <core_bench_state+0x420>
    3b06:	0001                	nop
    3b08:	00174f03          	lbu	t5,1(a4)
    3b0c:	2985                	addiw	s3,s3,1
    3b0e:	00170d93          	addi	s11,a4,1
    3b12:	1c0f0c63          	beqz	t5,3cea <core_bench_state+0x8aa>
    3b16:	1d1f0e63          	beq	t5,a7,3cf2 <core_bench_state+0x8b2>
    3b1a:	fd0f091b          	addiw	s2,t5,-48
    3b1e:	0ff97793          	zext.b	a5,s2
    3b22:	00fefb63          	bgeu	t4,a5,3b38 <core_bench_state+0x6f8>
    3b26:	04af0163          	beq	t5,a0,3b68 <core_bench_state+0x728>
    3b2a:	4905                	li	s2,1
    3b2c:	2405                	addiw	s0,s0,1
    3b2e:	0709                	addi	a4,a4,2
    3b30:	8f4a                	mv	t5,s2
    3b32:	87ca                	mv	a5,s2
    3b34:	b335                	j	3860 <core_bench_state+0x420>
    3b36:	0001                	nop
    3b38:	8827478b          	th.lbuib	a5,(a4),2,0
    3b3c:	2405                	addiw	s0,s0,1
    3b3e:	4905                	li	s2,1
    3b40:	16078663          	beqz	a5,3cac <core_bench_state+0x86c>
    3b44:	eb179ce3          	bne	a5,a7,39fc <core_bench_state+0x5bc>
    3b48:	8f4a                	mv	t5,s2
    3b4a:	4791                	li	a5,4
    3b4c:	0705                	addi	a4,a4,1
    3b4e:	bb09                	j	3860 <core_bench_state+0x420>
    3b50:	00174f03          	lbu	t5,1(a4)
    3b54:	2985                	addiw	s3,s3,1
    3b56:	00170d93          	addi	s11,a4,1
    3b5a:	f80f1fe3          	bnez	t5,3af8 <core_bench_state+0x6b8>
    3b5e:	876e                	mv	a4,s11
    3b60:	4f05                	li	t5,1
    3b62:	4795                	li	a5,5
    3b64:	b9f5                	j	3860 <core_bench_state+0x420>
    3b66:	0001                	nop
    3b68:	00274f03          	lbu	t5,2(a4)
    3b6c:	2405                	addiw	s0,s0,1
    3b6e:	00270d93          	addi	s11,a4,2
    3b72:	1a0f0d63          	beqz	t5,3d2c <core_bench_state+0x8ec>
    3b76:	1d1f0063          	beq	t5,a7,3d36 <core_bench_state+0x8f6>
    3b7a:	4905                	li	s2,1
    3b7c:	bd45                	j	3a2c <core_bench_state+0x5ec>
    3b7e:	7c05330b          	th.extu	t1,a0,31,0
    3b82:	937e                	add	t1,t1,t6
    3b84:	01010813          	addi	a6,sp,16
    3b88:	4501                	li	a0,0
    3b8a:	986feee3          	bltu	t6,t1,3526 <core_bench_state+0xe6>
    3b8e:	03010a13          	addi	s4,sp,48
    3b92:	8c42                	mv	s8,a6
    3b94:	a021                	j	3b9c <core_bench_state+0x75c>
    3b96:	0001                	nop
    3b98:	000c2503          	lw	a0,0(s8)
    3b9c:	0a5000ef          	jal	4440 <crcu32>
    3ba0:	85aa                	mv	a1,a0
    3ba2:	584a450b          	th.lwia	a0,(s4),4,0
    3ba6:	0c11                	addi	s8,s8,4
    3ba8:	099000ef          	jal	4440 <crcu32>
    3bac:	05010f93          	addi	t6,sp,80
    3bb0:	85aa                	mv	a1,a0
    3bb2:	fffa13e3          	bne	s4,t6,3b98 <core_bench_state+0x758>
    3bb6:	74aa                	ld	s1,168(sp)
    3bb8:	744a                	ld	s0,176(sp)
    3bba:	70ea                	ld	ra,184(sp)
    3bbc:	6de6                	ld	s11,88(sp)
    3bbe:	7d06                	ld	s10,96(sp)
    3bc0:	7ca6                	ld	s9,104(sp)
    3bc2:	7c46                	ld	s8,112(sp)
    3bc4:	7be6                	ld	s7,120(sp)
    3bc6:	6b0a                	ld	s6,128(sp)
    3bc8:	6aaa                	ld	s5,136(sp)
    3bca:	6a4a                	ld	s4,144(sp)
    3bcc:	69ea                	ld	s3,152(sp)
    3bce:	790a                	ld	s2,160(sp)
    3bd0:	6129                	addi	sp,sp,192
    3bd2:	8082                	ret
    3bd4:	4605                	li	a2,1
    3bd6:	82b2                	mv	t0,a2
    3bd8:	83b2                	mv	t2,a2
    3bda:	8f32                	mv	t5,a2
    3bdc:	479d                	li	a5,7
    3bde:	0705                	addi	a4,a4,1
    3be0:	b141                	j	3860 <core_bench_state+0x420>
    3be2:	4885                	li	a7,1
    3be4:	82c6                	mv	t0,a7
    3be6:	83c6                	mv	t2,a7
    3be8:	8546                	mv	a0,a7
    3bea:	479d                	li	a5,7
    3bec:	0705                	addi	a4,a4,1
    3bee:	b8cd                	j	34e0 <core_bench_state+0xa0>
    3bf0:	4781                	li	a5,0
    3bf2:	0705                	addi	a4,a4,1
    3bf4:	b1b5                	j	3860 <core_bench_state+0x420>
    3bf6:	4781                	li	a5,0
    3bf8:	0705                	addi	a4,a4,1
    3bfa:	b0dd                	j	34e0 <core_bench_state+0xa0>
    3bfc:	4f05                	li	t5,1
    3bfe:	4791                	li	a5,4
    3c00:	0705                	addi	a4,a4,1
    3c02:	b9b9                	j	3860 <core_bench_state+0x420>
    3c04:	4505                	li	a0,1
    3c06:	4791                	li	a5,4
    3c08:	0705                	addi	a4,a4,1
    3c0a:	b8d9                	j	34e0 <core_bench_state+0xa0>
    3c0c:	4542                	lw	a0,16(sp)
    3c0e:	c86fece3          	bltu	t6,t1,38a6 <core_bench_state+0x466>
    3c12:	bfb5                	j	3b8e <core_bench_state+0x74e>
    3c14:	000fce03          	lbu	t3,0(t6)
    3c18:	be0e19e3          	bnez	t3,380a <core_bench_state+0x3ca>
    3c1c:	4542                	lw	a0,16(sp)
    3c1e:	f66ff8e3          	bgeu	t6,t1,3b8e <core_bench_state+0x74e>
    3c22:	6c02                	ld	s8,0(sp)
    3c24:	02c00913          	li	s2,44
    3c28:	012e0663          	beq	t3,s2,3c34 <core_bench_state+0x7f4>
    3c2c:	014e4e33          	xor	t3,t3,s4
    3c30:	01cf8023          	sb	t3,0(t6)
    3c34:	9fe2                	add	t6,t6,s8
    3c36:	f46ffce3          	bgeu	t6,t1,3b8e <core_bench_state+0x74e>
    3c3a:	000fce03          	lbu	t3,0(t6)
    3c3e:	b7ed                	j	3c28 <core_bench_state+0x7e8>
    3c40:	4285                	li	t0,1
    3c42:	8396                	mv	t2,t0
    3c44:	8f16                	mv	t5,t0
    3c46:	4799                	li	a5,6
    3c48:	b921                	j	3860 <core_bench_state+0x420>
    3c4a:	4385                	li	t2,1
    3c4c:	851e                	mv	a0,t2
    3c4e:	478d                	li	a5,3
    3c50:	b841                	j	34e0 <core_bench_state+0xa0>
    3c52:	4285                	li	t0,1
    3c54:	8396                	mv	t2,t0
    3c56:	8516                	mv	a0,t0
    3c58:	4799                	li	a5,6
    3c5a:	b059                	j	34e0 <core_bench_state+0xa0>
    3c5c:	4385                	li	t2,1
    3c5e:	8f1e                	mv	t5,t2
    3c60:	478d                	li	a5,3
    3c62:	befd                	j	3860 <core_bench_state+0x420>
    3c64:	02c00c93          	li	s9,44
    3c68:	019e0663          	beq	t3,s9,3c74 <core_bench_state+0x834>
    3c6c:	00ce46b3          	xor	a3,t3,a2
    3c70:	00dd8023          	sb	a3,0(s11)
    3c74:	9dce                	add	s11,s11,s3
    3c76:	f86dffe3          	bgeu	s11,t1,3c14 <core_bench_state+0x7d4>
    3c7a:	000dce03          	lbu	t3,0(s11)
    3c7e:	b7ed                	j	3c68 <core_bench_state+0x828>
    3c80:	4285                	li	t0,1
    3c82:	8396                	mv	t2,t0
    3c84:	8f16                	mv	t5,t0
    3c86:	4799                	li	a5,6
    3c88:	0705                	addi	a4,a4,1
    3c8a:	bed9                	j	3860 <core_bench_state+0x420>
    3c8c:	4385                	li	t2,1
    3c8e:	8f1e                	mv	t5,t2
    3c90:	478d                	li	a5,3
    3c92:	0705                	addi	a4,a4,1
    3c94:	b6f1                	j	3860 <core_bench_state+0x420>
    3c96:	4285                	li	t0,1
    3c98:	8396                	mv	t2,t0
    3c9a:	8516                	mv	a0,t0
    3c9c:	4799                	li	a5,6
    3c9e:	0705                	addi	a4,a4,1
    3ca0:	b081                	j	34e0 <core_bench_state+0xa0>
    3ca2:	4385                	li	t2,1
    3ca4:	851e                	mv	a0,t2
    3ca6:	478d                	li	a5,3
    3ca8:	0705                	addi	a4,a4,1
    3caa:	b81d                	j	34e0 <core_bench_state+0xa0>
    3cac:	8f4a                	mv	t5,s2
    3cae:	4791                	li	a5,4
    3cb0:	be45                	j	3860 <core_bench_state+0x420>
    3cb2:	854e                	mv	a0,s3
    3cb4:	4791                	li	a5,4
    3cb6:	82bff06f          	j	34e0 <core_bench_state+0xa0>
    3cba:	4b85                	li	s7,1
    3cbc:	876e                	mv	a4,s11
    3cbe:	8f5e                	mv	t5,s7
    3cc0:	4795                	li	a5,5
    3cc2:	be79                	j	3860 <core_bench_state+0x420>
    3cc4:	4c05                	li	s8,1
    3cc6:	8772                	mv	a4,t3
    3cc8:	8562                	mv	a0,s8
    3cca:	4795                	li	a5,5
    3ccc:	815ff06f          	j	34e0 <core_bench_state+0xa0>
    3cd0:	8772                	mv	a4,t3
    3cd2:	4c05                	li	s8,1
    3cd4:	8562                	mv	a0,s8
    3cd6:	4795                	li	a5,5
    3cd8:	0705                	addi	a4,a4,1
    3cda:	807ff06f          	j	34e0 <core_bench_state+0xa0>
    3cde:	876e                	mv	a4,s11
    3ce0:	4b85                	li	s7,1
    3ce2:	8f5e                	mv	t5,s7
    3ce4:	4795                	li	a5,5
    3ce6:	0705                	addi	a4,a4,1
    3ce8:	bea5                	j	3860 <core_bench_state+0x420>
    3cea:	876e                	mv	a4,s11
    3cec:	4f05                	li	t5,1
    3cee:	4789                	li	a5,2
    3cf0:	be85                	j	3860 <core_bench_state+0x420>
    3cf2:	876e                	mv	a4,s11
    3cf4:	4f05                	li	t5,1
    3cf6:	4789                	li	a5,2
    3cf8:	0705                	addi	a4,a4,1
    3cfa:	b69d                	j	3860 <core_bench_state+0x420>
    3cfc:	8772                	mv	a4,t3
    3cfe:	4505                	li	a0,1
    3d00:	4789                	li	a5,2
    3d02:	0705                	addi	a4,a4,1
    3d04:	fdcff06f          	j	34e0 <core_bench_state+0xa0>
    3d08:	8772                	mv	a4,t3
    3d0a:	4505                	li	a0,1
    3d0c:	4789                	li	a5,2
    3d0e:	fd2ff06f          	j	34e0 <core_bench_state+0xa0>
    3d12:	8772                	mv	a4,t3
    3d14:	4985                	li	s3,1
    3d16:	854e                	mv	a0,s3
    3d18:	4795                	li	a5,5
    3d1a:	0705                	addi	a4,a4,1
    3d1c:	fc4ff06f          	j	34e0 <core_bench_state+0xa0>
    3d20:	4985                	li	s3,1
    3d22:	8772                	mv	a4,t3
    3d24:	854e                	mv	a0,s3
    3d26:	4795                	li	a5,5
    3d28:	fb8ff06f          	j	34e0 <core_bench_state+0xa0>
    3d2c:	4905                	li	s2,1
    3d2e:	876e                	mv	a4,s11
    3d30:	8f4a                	mv	t5,s2
    3d32:	4795                	li	a5,5
    3d34:	b635                	j	3860 <core_bench_state+0x420>
    3d36:	876e                	mv	a4,s11
    3d38:	4905                	li	s2,1
    3d3a:	8f4a                	mv	t5,s2
    3d3c:	4795                	li	a5,5
    3d3e:	0705                	addi	a4,a4,1
    3d40:	b605                	j	3860 <core_bench_state+0x420>
    3d42:	0001                	nop
    3d44:	00000013          	nop
    3d48:	00000013          	nop
    3d4c:	00000013          	nop

0000000000003d50 <core_init_state>:
    3d50:	fff50e9b          	addiw	t4,a0,-1
    3d54:	4f85                	li	t6,1
    3d56:	19dff963          	bgeu	t6,t4,3ee8 <core_init_state+0x198>
    3d5a:	2585                	addiw	a1,a1,1
    3d5c:	3c05b68b          	th.extu	a3,a1,15,0
    3d60:	6e45                	lui	t3,0x11
    3d62:	4f1d                	li	t5,7
    3d64:	0076f713          	andi	a4,a3,7
    3d68:	4801                	li	a6,0
    3d6a:	ae8e0e13          	addi	t3,t3,-1304 # 10ae8 <intpat>
    3d6e:	4311                	li	t1,4
    3d70:	02c00293          	li	t0,44
    3d74:	3c06a78b          	th.ext	a5,a3,15,0
    3d78:	09e70763          	beq	a4,t5,3e06 <core_init_state+0xb6>
    3d7c:	14e36e63          	bltu	t1,a4,3ed8 <core_init_state+0x188>
    3d80:	ffd7059b          	addiw	a1,a4,-3
    3d84:	3c05b88b          	th.extu	a7,a1,15,0
    3d88:	151fe263          	bltu	t6,a7,3ecc <core_init_state+0x17c>
    3d8c:	8be1                	andi	a5,a5,24
    3d8e:	00fe03b3          	add	t2,t3,a5
    3d92:	0203b703          	ld	a4,32(t2)
    3d96:	48a1                	li	a7,8
    3d98:	0018059b          	addiw	a1,a6,1
    3d9c:	011585bb          	addw	a1,a1,a7
    3da0:	07d5ff63          	bgeu	a1,t4,3e1e <core_init_state+0xce>
    3da4:	00074383          	lbu	t2,0(a4)
    3da8:	7c08378b          	th.extu	a5,a6,31,0
    3dac:	97b2                	add	a5,a5,a2
    3dae:	1106538b          	th.surb	t2,a2,a6,0
    3db2:	00174803          	lbu	a6,1(a4)
    3db6:	010780a3          	sb	a6,1(a5)
    3dba:	00274383          	lbu	t2,2(a4)
    3dbe:	00778123          	sb	t2,2(a5)
    3dc2:	00374803          	lbu	a6,3(a4)
    3dc6:	010781a3          	sb	a6,3(a5)
    3dca:	02688263          	beq	a7,t1,3dee <core_init_state+0x9e>
    3dce:	00474383          	lbu	t2,4(a4)
    3dd2:	00778223          	sb	t2,4(a5)
    3dd6:	00574803          	lbu	a6,5(a4)
    3dda:	010782a3          	sb	a6,5(a5)
    3dde:	00674383          	lbu	t2,6(a4)
    3de2:	00778323          	sb	t2,6(a5)
    3de6:	00774703          	lbu	a4,7(a4)
    3dea:	00e783a3          	sb	a4,7(a5)
    3dee:	2685                	addiw	a3,a3,1
    3df0:	3c06b68b          	th.extu	a3,a3,15,0
    3df4:	1117d28b          	th.surb	t0,a5,a7,0
    3df8:	0076f713          	andi	a4,a3,7
    3dfc:	882e                	mv	a6,a1
    3dfe:	3c06a78b          	th.ext	a5,a3,15,0
    3e02:	f7e71de3          	bne	a4,t5,3d7c <core_init_state+0x2c>
    3e06:	0187f893          	andi	a7,a5,24
    3e0a:	011e05b3          	add	a1,t3,a7
    3e0e:	71b8                	ld	a4,96(a1)
    3e10:	48a1                	li	a7,8
    3e12:	0018059b          	addiw	a1,a6,1
    3e16:	011585bb          	addw	a1,a1,a7
    3e1a:	f9d5e5e3          	bltu	a1,t4,3da4 <core_init_state+0x54>
    3e1e:	0ca87763          	bgeu	a6,a0,3eec <core_init_state+0x19c>
    3e22:	7c08328b          	th.extu	t0,a6,31,0
    3e26:	9616                	add	a2,a2,t0
    3e28:	40c8033b          	subw	t1,a6,a2
    3e2c:	87b2                	mv	a5,a2
    3e2e:	fff64693          	not	a3,a2
    3e32:	7c033e8b          	th.extu	t4,t1,31,0
    3e36:	41d68f33          	sub	t5,a3,t4
    3e3a:	1817d00b          	th.sbia	zero,(a5),1,0
    3e3e:	00af0fb3          	add	t6,t5,a0
    3e42:	00678e3b          	addw	t3,a5,t1
    3e46:	007ff813          	andi	a6,t6,7
    3e4a:	0aae7263          	bgeu	t3,a0,3eee <core_init_state+0x19e>
    3e4e:	04080863          	beqz	a6,3e9e <core_init_state+0x14e>
    3e52:	4885                	li	a7,1
    3e54:	03180f63          	beq	a6,a7,3e92 <core_init_state+0x142>
    3e58:	4709                	li	a4,2
    3e5a:	02e80a63          	beq	a6,a4,3e8e <core_init_state+0x13e>
    3e5e:	438d                	li	t2,3
    3e60:	02780563          	beq	a6,t2,3e8a <core_init_state+0x13a>
    3e64:	4591                	li	a1,4
    3e66:	02b80063          	beq	a6,a1,3e86 <core_init_state+0x136>
    3e6a:	4295                	li	t0,5
    3e6c:	00580b63          	beq	a6,t0,3e82 <core_init_state+0x132>
    3e70:	4699                	li	a3,6
    3e72:	00d80663          	beq	a6,a3,3e7e <core_init_state+0x12e>
    3e76:	00078023          	sb	zero,0(a5)
    3e7a:	00260793          	addi	a5,a2,2
    3e7e:	1817d00b          	th.sbia	zero,(a5),1,0
    3e82:	1817d00b          	th.sbia	zero,(a5),1,0
    3e86:	1817d00b          	th.sbia	zero,(a5),1,0
    3e8a:	1817d00b          	th.sbia	zero,(a5),1,0
    3e8e:	1817d00b          	th.sbia	zero,(a5),1,0
    3e92:	1817d00b          	th.sbia	zero,(a5),1,0
    3e96:	0067863b          	addw	a2,a5,t1
    3e9a:	04a67663          	bgeu	a2,a0,3ee6 <core_init_state+0x196>
    3e9e:	00078023          	sb	zero,0(a5)
    3ea2:	000780a3          	sb	zero,1(a5)
    3ea6:	00078123          	sb	zero,2(a5)
    3eaa:	000781a3          	sb	zero,3(a5)
    3eae:	00078223          	sb	zero,4(a5)
    3eb2:	000782a3          	sb	zero,5(a5)
    3eb6:	00078323          	sb	zero,6(a5)
    3eba:	000783a3          	sb	zero,7(a5)
    3ebe:	07a1                	addi	a5,a5,8
    3ec0:	00678ebb          	addw	t4,a5,t1
    3ec4:	fcaeede3          	bltu	t4,a0,3e9e <core_init_state+0x14e>
    3ec8:	8082                	ret
    3eca:	0001                	nop
    3ecc:	1037b70b          	th.extu	a4,a5,4,3
    3ed0:	66ee470b          	th.lrd	a4,t3,a4,3
    3ed4:	4891                	li	a7,4
    3ed6:	b5c9                	j	3d98 <core_init_state+0x48>
    3ed8:	8be1                	andi	a5,a5,24
    3eda:	00fe03b3          	add	t2,t3,a5
    3ede:	0403b703          	ld	a4,64(t2)
    3ee2:	48a1                	li	a7,8
    3ee4:	bd55                	j	3d98 <core_init_state+0x48>
    3ee6:	8082                	ret
    3ee8:	4801                	li	a6,0
    3eea:	bf25                	j	3e22 <core_init_state+0xd2>
    3eec:	8082                	ret
    3eee:	8082                	ret

0000000000003ef0 <core_state_transition>:
    3ef0:	6114                	ld	a3,0(a0)
    3ef2:	882a                	mv	a6,a0
    3ef4:	0006c783          	lbu	a5,0(a3)
    3ef8:	24078163          	beqz	a5,413a <core_state_transition+0x24a>
    3efc:	02c00713          	li	a4,44
    3f00:	4501                	li	a0,0
    3f02:	1ce78b63          	beq	a5,a4,40d8 <core_state_transition+0x1e8>
    3f06:	02e00513          	li	a0,46
    3f0a:	1ea78f63          	beq	a5,a0,4108 <core_state_transition+0x218>
    3f0e:	1cf56763          	bltu	a0,a5,40dc <core_state_transition+0x1ec>
    3f12:	fd578f1b          	addiw	t5,a5,-43
    3f16:	0fdf7f93          	andi	t6,t5,253
    3f1a:	020f8363          	beqz	t6,3f40 <core_state_transition+0x50>
    3f1e:	0045a883          	lw	a7,4(a1)
    3f22:	0005ae83          	lw	t4,0(a1)
    3f26:	0685                	addi	a3,a3,1
    3f28:	00188e1b          	addiw	t3,a7,1
    3f2c:	001e861b          	addiw	a2,t4,1
    3f30:	4505                	li	a0,1
    3f32:	01c5a223          	sw	t3,4(a1)
    3f36:	c190                	sw	a2,0(a1)
    3f38:	00d83023          	sd	a3,0(a6)
    3f3c:	8082                	ret
    3f3e:	0001                	nop
    3f40:	419c                	lw	a5,0(a1)
    3f42:	00168613          	addi	a2,a3,1
    3f46:	0017829b          	addiw	t0,a5,1
    3f4a:	0055a023          	sw	t0,0(a1)
    3f4e:	0016c303          	lbu	t1,1(a3)
    3f52:	20030963          	beqz	t1,4164 <core_state_transition+0x274>
    3f56:	1ce30e63          	beq	t1,a4,4132 <core_state_transition+0x242>
    3f5a:	fd03071b          	addiw	a4,t1,-48
    3f5e:	0ff77393          	zext.b	t2,a4
    3f62:	48a5                	li	a7,9
    3f64:	0078fe63          	bgeu	a7,t2,3f80 <core_state_transition+0x90>
    3f68:	1ca30063          	beq	t1,a0,4128 <core_state_transition+0x238>
    3f6c:	4590                	lw	a2,8(a1)
    3f6e:	0689                	addi	a3,a3,2
    3f70:	4505                	li	a0,1
    3f72:	00160e1b          	addiw	t3,a2,1
    3f76:	01c5a423          	sw	t3,8(a1)
    3f7a:	00d83023          	sd	a3,0(a6)
    3f7e:	8082                	ret
    3f80:	0085ae83          	lw	t4,8(a1)
    3f84:	001e8f1b          	addiw	t5,t4,1
    3f88:	01e5a423          	sw	t5,8(a1)
    3f8c:	88164f8b          	th.lbuib	t6,(a2),1,0
    3f90:	160f8963          	beqz	t6,4102 <core_state_transition+0x212>
    3f94:	02c00713          	li	a4,44
    3f98:	1aef8d63          	beq	t6,a4,4152 <core_state_transition+0x262>
    3f9c:	02e00793          	li	a5,46
    3fa0:	02ff8663          	beq	t6,a5,3fcc <core_state_transition+0xdc>
    3fa4:	fd0f829b          	addiw	t0,t6,-48
    3fa8:	0ff2f313          	zext.b	t1,t0
    3fac:	4725                	li	a4,9
    3fae:	fc677fe3          	bgeu	a4,t1,3f8c <core_state_transition+0x9c>
    3fb2:	0105a383          	lw	t2,16(a1)
    3fb6:	00160693          	addi	a3,a2,1
    3fba:	4505                	li	a0,1
    3fbc:	0013889b          	addiw	a7,t2,1
    3fc0:	0115a823          	sw	a7,16(a1)
    3fc4:	00d83023          	sd	a3,0(a6)
    3fc8:	8082                	ret
    3fca:	0001                	nop
    3fcc:	0105ae03          	lw	t3,16(a1)
    3fd0:	001e069b          	addiw	a3,t3,1
    3fd4:	c994                	sw	a3,16(a1)
    3fd6:	8816450b          	th.lbuib	a0,(a2),1,0
    3fda:	14050363          	beqz	a0,4120 <core_state_transition+0x230>
    3fde:	02c00713          	li	a4,44
    3fe2:	0ee50963          	beq	a0,a4,40d4 <core_state_transition+0x1e4>
    3fe6:	0df57e93          	andi	t4,a0,223
    3fea:	04500f13          	li	t5,69
    3fee:	03ee8563          	beq	t4,t5,4018 <core_state_transition+0x128>
    3ff2:	fd050f9b          	addiw	t6,a0,-48
    3ff6:	0ffff793          	zext.b	a5,t6
    3ffa:	42a5                	li	t0,9
    3ffc:	fcf2fde3          	bgeu	t0,a5,3fd6 <core_state_transition+0xe6>
    4000:	0145a303          	lw	t1,20(a1)
    4004:	00160693          	addi	a3,a2,1
    4008:	4505                	li	a0,1
    400a:	0013039b          	addiw	t2,t1,1
    400e:	0075aa23          	sw	t2,20(a1)
    4012:	00d83023          	sd	a3,0(a6)
    4016:	8082                	ret
    4018:	0145a883          	lw	a7,20(a1)
    401c:	00160693          	addi	a3,a2,1
    4020:	00188e1b          	addiw	t3,a7,1
    4024:	01c5aa23          	sw	t3,20(a1)
    4028:	00164503          	lbu	a0,1(a2)
    402c:	10050b63          	beqz	a0,4142 <core_state_transition+0x252>
    4030:	02c00713          	li	a4,44
    4034:	10e50c63          	beq	a0,a4,414c <core_state_transition+0x25c>
    4038:	fd55069b          	addiw	a3,a0,-43
    403c:	0fd6fe93          	andi	t4,a3,253
    4040:	000e8e63          	beqz	t4,405c <core_state_transition+0x16c>
    4044:	00260693          	addi	a3,a2,2
    4048:	45d0                	lw	a2,12(a1)
    404a:	4505                	li	a0,1
    404c:	00160f1b          	addiw	t5,a2,1
    4050:	01e5a623          	sw	t5,12(a1)
    4054:	00d83023          	sd	a3,0(a6)
    4058:	8082                	ret
    405a:	0001                	nop
    405c:	00c5af83          	lw	t6,12(a1)
    4060:	00260693          	addi	a3,a2,2
    4064:	001f879b          	addiw	a5,t6,1
    4068:	c5dc                	sw	a5,12(a1)
    406a:	00264283          	lbu	t0,2(a2)
    406e:	0c028863          	beqz	t0,413e <core_state_transition+0x24e>
    4072:	0ce28a63          	beq	t0,a4,4146 <core_state_transition+0x256>
    4076:	fd02831b          	addiw	t1,t0,-48
    407a:	0ff37393          	zext.b	t2,t1
    407e:	4725                	li	a4,9
    4080:	00777c63          	bgeu	a4,t2,4098 <core_state_transition+0x1a8>
    4084:	0185a883          	lw	a7,24(a1)
    4088:	00360693          	addi	a3,a2,3
    408c:	4505                	li	a0,1
    408e:	00188e1b          	addiw	t3,a7,1
    4092:	01c5ac23          	sw	t3,24(a1)
    4096:	b54d                	j	3f38 <core_state_transition+0x48>
    4098:	4d88                	lw	a0,24(a1)
    409a:	00150e9b          	addiw	t4,a0,1
    409e:	01d5ac23          	sw	t4,24(a1)
    40a2:	8636                	mv	a2,a3
    40a4:	8816cf0b          	th.lbuib	t5,(a3),1,0
    40a8:	0a0f0c63          	beqz	t5,4160 <core_state_transition+0x270>
    40ac:	02c00f93          	li	t6,44
    40b0:	0bff0563          	beq	t5,t6,415a <core_state_transition+0x26a>
    40b4:	fd0f079b          	addiw	a5,t5,-48
    40b8:	0ff7f293          	zext.b	t0,a5
    40bc:	fe5773e3          	bgeu	a4,t0,40a2 <core_state_transition+0x1b2>
    40c0:	0045a303          	lw	t1,4(a1)
    40c4:	00260693          	addi	a3,a2,2
    40c8:	4505                	li	a0,1
    40ca:	0013039b          	addiw	t2,t1,1
    40ce:	0075a223          	sw	t2,4(a1)
    40d2:	b59d                	j	3f38 <core_state_transition+0x48>
    40d4:	86b2                	mv	a3,a2
    40d6:	4515                	li	a0,5
    40d8:	0685                	addi	a3,a3,1
    40da:	bdb9                	j	3f38 <core_state_transition+0x48>
    40dc:	fd07839b          	addiw	t2,a5,-48
    40e0:	0ff3f893          	zext.b	a7,t2
    40e4:	4625                	li	a2,9
    40e6:	e3166ce3          	bltu	a2,a7,3f1e <core_state_transition+0x2e>
    40ea:	0005ae03          	lw	t3,0(a1)
    40ee:	00168613          	addi	a2,a3,1
    40f2:	001e0e9b          	addiw	t4,t3,1
    40f6:	01d5a023          	sw	t4,0(a1)
    40fa:	0016cf83          	lbu	t6,1(a3)
    40fe:	e80f9de3          	bnez	t6,3f98 <core_state_transition+0xa8>
    4102:	86b2                	mv	a3,a2
    4104:	4511                	li	a0,4
    4106:	bd0d                	j	3f38 <core_state_transition+0x48>
    4108:	0005a283          	lw	t0,0(a1)
    410c:	00168613          	addi	a2,a3,1
    4110:	0012831b          	addiw	t1,t0,1
    4114:	0065a023          	sw	t1,0(a1)
    4118:	0016c503          	lbu	a0,1(a3)
    411c:	ec0513e3          	bnez	a0,3fe2 <core_state_transition+0xf2>
    4120:	86b2                	mv	a3,a2
    4122:	4515                	li	a0,5
    4124:	bd11                	j	3f38 <core_state_transition+0x48>
    4126:	0001                	nop
    4128:	4594                	lw	a3,8(a1)
    412a:	0016851b          	addiw	a0,a3,1
    412e:	c588                	sw	a0,8(a1)
    4130:	b55d                	j	3fd6 <core_state_transition+0xe6>
    4132:	86b2                	mv	a3,a2
    4134:	4509                	li	a0,2
    4136:	0685                	addi	a3,a3,1
    4138:	b501                	j	3f38 <core_state_transition+0x48>
    413a:	4501                	li	a0,0
    413c:	bbf5                	j	3f38 <core_state_transition+0x48>
    413e:	4519                	li	a0,6
    4140:	bbe5                	j	3f38 <core_state_transition+0x48>
    4142:	450d                	li	a0,3
    4144:	bbd5                	j	3f38 <core_state_transition+0x48>
    4146:	4519                	li	a0,6
    4148:	0685                	addi	a3,a3,1
    414a:	b3fd                	j	3f38 <core_state_transition+0x48>
    414c:	450d                	li	a0,3
    414e:	0685                	addi	a3,a3,1
    4150:	b3e5                	j	3f38 <core_state_transition+0x48>
    4152:	86b2                	mv	a3,a2
    4154:	4511                	li	a0,4
    4156:	0685                	addi	a3,a3,1
    4158:	b3c5                	j	3f38 <core_state_transition+0x48>
    415a:	451d                	li	a0,7
    415c:	0685                	addi	a3,a3,1
    415e:	bbe9                	j	3f38 <core_state_transition+0x48>
    4160:	451d                	li	a0,7
    4162:	bbd9                	j	3f38 <core_state_transition+0x48>
    4164:	86b2                	mv	a3,a2
    4166:	4509                	li	a0,2
    4168:	bbc1                	j	3f38 <core_state_transition+0x48>
	...

0000000000004180 <get_seed_32>:
    4180:	4795                	li	a5,5
    4182:	04a7e663          	bltu	a5,a0,41ce <get_seed_32+0x4e>
    4186:	62c5                	lui	t0,0x11
    4188:	b6828313          	addi	t1,t0,-1176 # 10b68 <errpat+0x20>
    418c:	44a3438b          	th.lrw	t2,t1,a0,2
    4190:	8382                	jr	t2
    4192:	0001                	nop
    4194:	00041537          	lui	a0,0x41
    4198:	fc052503          	lw	a0,-64(a0) # 40fc0 <seed5_volatile>
    419c:	8082                	ret
    419e:	0001                	nop
    41a0:	00041737          	lui	a4,0x41
    41a4:	fc872503          	lw	a0,-56(a4) # 40fc8 <seed1_volatile>
    41a8:	8082                	ret
    41aa:	0001                	nop
    41ac:	000416b7          	lui	a3,0x41
    41b0:	fc46a503          	lw	a0,-60(a3) # 40fc4 <seed2_volatile>
    41b4:	8082                	ret
    41b6:	0001                	nop
    41b8:	00040637          	lui	a2,0x40
    41bc:	01062503          	lw	a0,16(a2) # 40010 <seed3_volatile>
    41c0:	8082                	ret
    41c2:	0001                	nop
    41c4:	000405b7          	lui	a1,0x40
    41c8:	00c5a503          	lw	a0,12(a1) # 4000c <seed4_volatile>
    41cc:	8082                	ret
    41ce:	4501                	li	a0,0
    41d0:	8082                	ret
    41d2:	0001                	nop
    41d4:	00000013          	nop
    41d8:	00000013          	nop
    41dc:	00000013          	nop

00000000000041e0 <crcu8>:
    41e0:	6829                	lui	a6,0xa
    41e2:	00180313          	addi	t1,a6,1 # a001 <_vsnprintf+0x1461>
    41e6:	00b54733          	xor	a4,a0,a1
    41ea:	8185                	srli	a1,a1,0x1
    41ec:	00177293          	andi	t0,a4,1
    41f0:	0065c7b3          	xor	a5,a1,t1
    41f4:	4055978b          	th.mveqz	a5,a1,t0
    41f8:	00155613          	srli	a2,a0,0x1
    41fc:	00f643b3          	xor	t2,a2,a5
    4200:	0017de13          	srli	t3,a5,0x1
    4204:	0013f893          	andi	a7,t2,1
    4208:	006e4f33          	xor	t5,t3,t1
    420c:	411e1f0b          	th.mveqz	t5,t3,a7
    4210:	00255693          	srli	a3,a0,0x2
    4214:	01e6c633          	xor	a2,a3,t5
    4218:	001f5713          	srli	a4,t5,0x1
    421c:	00167293          	andi	t0,a2,1
    4220:	006745b3          	xor	a1,a4,t1
    4224:	4057158b          	th.mveqz	a1,a4,t0
    4228:	00355f93          	srli	t6,a0,0x3
    422c:	8e9a                	mv	t4,t1
    422e:	0015d793          	srli	a5,a1,0x1
    4232:	00bfc333          	xor	t1,t6,a1
    4236:	00137693          	andi	a3,t1,1
    423a:	01d7c3b3          	xor	t2,a5,t4
    423e:	40d7938b          	th.mveqz	t2,a5,a3
    4242:	00455813          	srli	a6,a0,0x4
    4246:	00784e33          	xor	t3,a6,t2
    424a:	0013df93          	srli	t6,t2,0x1
    424e:	001e7f13          	andi	t5,t3,1
    4252:	01dfc2b3          	xor	t0,t6,t4
    4256:	41ef928b          	th.mveqz	t0,t6,t5
    425a:	00555893          	srli	a7,a0,0x5
    425e:	0058c633          	xor	a2,a7,t0
    4262:	0012d313          	srli	t1,t0,0x1
    4266:	01d34733          	xor	a4,t1,t4
    426a:	00167813          	andi	a6,a2,1
    426e:	4103170b          	th.mveqz	a4,t1,a6
    4272:	00655593          	srli	a1,a0,0x6
    4276:	00755793          	srli	a5,a0,0x7
    427a:	00175393          	srli	t2,a4,0x1
    427e:	00e5c533          	xor	a0,a1,a4
    4282:	00157693          	andi	a3,a0,1
    4286:	01d3c8b3          	xor	a7,t2,t4
    428a:	40d3988b          	th.mveqz	a7,t2,a3
    428e:	0018d513          	srli	a0,a7,0x1
    4292:	0117ce33          	xor	t3,a5,a7
    4296:	001e7f13          	andi	t5,t3,1
    429a:	01d54eb3          	xor	t4,a0,t4
    429e:	43ee950b          	th.mvnez	a0,t4,t5
    42a2:	8082                	ret
    42a4:	00000013          	nop
    42a8:	00000013          	nop
    42ac:	00000013          	nop

00000000000042b0 <crcu16>:
    42b0:	0ff57793          	zext.b	a5,a0
    42b4:	6829                	lui	a6,0xa
    42b6:	00180313          	addi	t1,a6,1 # a001 <_vsnprintf+0x1461>
    42ba:	00b7c633          	xor	a2,a5,a1
    42be:	0015d71b          	srliw	a4,a1,0x1
    42c2:	00167293          	andi	t0,a2,1
    42c6:	006743b3          	xor	t2,a4,t1
    42ca:	8185                	srli	a1,a1,0x1
    42cc:	4055938b          	th.mveqz	t2,a1,t0
    42d0:	1c15368b          	th.extu	a3,a0,7,1
    42d4:	0076ce33          	xor	t3,a3,t2
    42d8:	0013df13          	srli	t5,t2,0x1
    42dc:	001e7e93          	andi	t4,t3,1
    42e0:	006f4fb3          	xor	t6,t5,t1
    42e4:	41df1f8b          	th.mveqz	t6,t5,t4
    42e8:	0027d893          	srli	a7,a5,0x2
    42ec:	01f8c6b3          	xor	a3,a7,t6
    42f0:	001fd593          	srli	a1,t6,0x1
    42f4:	0016f613          	andi	a2,a3,1
    42f8:	0065c733          	xor	a4,a1,t1
    42fc:	40c5970b          	th.mveqz	a4,a1,a2
    4300:	0037d293          	srli	t0,a5,0x3
    4304:	00e2c3b3          	xor	t2,t0,a4
    4308:	00175e13          	srli	t3,a4,0x1
    430c:	0013f893          	andi	a7,t2,1
    4310:	006e4eb3          	xor	t4,t3,t1
    4314:	411e1e8b          	th.mveqz	t4,t3,a7
    4318:	0047d813          	srli	a6,a5,0x4
    431c:	01d84fb3          	xor	t6,a6,t4
    4320:	001ed693          	srli	a3,t4,0x1
    4324:	001ff293          	andi	t0,t6,1
    4328:	0066c733          	xor	a4,a3,t1
    432c:	4056970b          	th.mveqz	a4,a3,t0
    4330:	0057df13          	srli	t5,a5,0x5
    4334:	00ef45b3          	xor	a1,t5,a4
    4338:	00175393          	srli	t2,a4,0x1
    433c:	0015f813          	andi	a6,a1,1
    4340:	0063c8b3          	xor	a7,t2,t1
    4344:	4103988b          	th.mveqz	a7,t2,a6
    4348:	0067d613          	srli	a2,a5,0x6
    434c:	01164e33          	xor	t3,a2,a7
    4350:	0018df13          	srli	t5,a7,0x1
    4354:	001e7e93          	andi	t4,t3,1
    4358:	006f4fb3          	xor	t6,t5,t1
    435c:	41df1f8b          	th.mveqz	t6,t5,t4
    4360:	839d                	srli	a5,a5,0x7
    4362:	01f7c2b3          	xor	t0,a5,t6
    4366:	001fd713          	srli	a4,t6,0x1
    436a:	0012f613          	andi	a2,t0,1
    436e:	006746b3          	xor	a3,a4,t1
    4372:	00855813          	srli	a6,a0,0x8
    4376:	42c6970b          	th.mvnez	a4,a3,a2
    437a:	00e845b3          	xor	a1,a6,a4
    437e:	0017589b          	srliw	a7,a4,0x1
    4382:	0068ce33          	xor	t3,a7,t1
    4386:	0015f393          	andi	t2,a1,1
    438a:	00175793          	srli	a5,a4,0x1
    438e:	427e178b          	th.mvnez	a5,t3,t2
    4392:	8125                	srli	a0,a0,0x9
    4394:	00f54f33          	xor	t5,a0,a5
    4398:	0017d293          	srli	t0,a5,0x1
    439c:	001f7f93          	andi	t6,t5,1
    43a0:	0062c633          	xor	a2,t0,t1
    43a4:	43f6128b          	th.mvnez	t0,a2,t6
    43a8:	00285e93          	srli	t4,a6,0x2
    43ac:	005ec733          	xor	a4,t4,t0
    43b0:	0012d893          	srli	a7,t0,0x1
    43b4:	00177393          	andi	t2,a4,1
    43b8:	0068c6b3          	xor	a3,a7,t1
    43bc:	4078968b          	th.mveqz	a3,a7,t2
    43c0:	00385593          	srli	a1,a6,0x3
    43c4:	00d5c7b3          	xor	a5,a1,a3
    43c8:	0016de93          	srli	t4,a3,0x1
    43cc:	0017fe13          	andi	t3,a5,1
    43d0:	006ecf33          	xor	t5,t4,t1
    43d4:	41ce9f0b          	th.mveqz	t5,t4,t3
    43d8:	00485513          	srli	a0,a6,0x4
    43dc:	01e542b3          	xor	t0,a0,t5
    43e0:	001f5593          	srli	a1,t5,0x1
    43e4:	0012f613          	andi	a2,t0,1
    43e8:	0065c733          	xor	a4,a1,t1
    43ec:	40c5970b          	th.mveqz	a4,a1,a2
    43f0:	00585f93          	srli	t6,a6,0x5
    43f4:	00efc8b3          	xor	a7,t6,a4
    43f8:	00175693          	srli	a3,a4,0x1
    43fc:	0018f513          	andi	a0,a7,1
    4400:	0066ce33          	xor	t3,a3,t1
    4404:	40a69e0b          	th.mveqz	t3,a3,a0
    4408:	00685393          	srli	t2,a6,0x6
    440c:	001e5f13          	srli	t5,t3,0x1
    4410:	01c3c7b3          	xor	a5,t2,t3
    4414:	0017fe93          	andi	t4,a5,1
    4418:	006f4fb3          	xor	t6,t5,t1
    441c:	41df1f8b          	th.mveqz	t6,t5,t4
    4420:	00785813          	srli	a6,a6,0x7
    4424:	001fd513          	srli	a0,t6,0x1
    4428:	01f842b3          	xor	t0,a6,t6
    442c:	0012f613          	andi	a2,t0,1
    4430:	006545b3          	xor	a1,a0,t1
    4434:	42c5950b          	th.mvnez	a0,a1,a2
    4438:	8082                	ret
    443a:	00000013          	nop
    443e:	0001                	nop

0000000000004440 <crcu32>:
    4440:	0ff57793          	zext.b	a5,a0
    4444:	6829                	lui	a6,0xa
    4446:	00180313          	addi	t1,a6,1 # a001 <_vsnprintf+0x1461>
    444a:	00b7c633          	xor	a2,a5,a1
    444e:	0015d71b          	srliw	a4,a1,0x1
    4452:	00167293          	andi	t0,a2,1
    4456:	006743b3          	xor	t2,a4,t1
    445a:	8185                	srli	a1,a1,0x1
    445c:	4055938b          	th.mveqz	t2,a1,t0
    4460:	1c15368b          	th.extu	a3,a0,7,1
    4464:	0076ce33          	xor	t3,a3,t2
    4468:	0013df13          	srli	t5,t2,0x1
    446c:	001e7e93          	andi	t4,t3,1
    4470:	006f4fb3          	xor	t6,t5,t1
    4474:	41df1f8b          	th.mveqz	t6,t5,t4
    4478:	0027d893          	srli	a7,a5,0x2
    447c:	01f8c6b3          	xor	a3,a7,t6
    4480:	001fd593          	srli	a1,t6,0x1
    4484:	0016f613          	andi	a2,a3,1
    4488:	0065c733          	xor	a4,a1,t1
    448c:	40c5970b          	th.mveqz	a4,a1,a2
    4490:	0037d293          	srli	t0,a5,0x3
    4494:	00e2c3b3          	xor	t2,t0,a4
    4498:	00175e13          	srli	t3,a4,0x1
    449c:	0013f893          	andi	a7,t2,1
    44a0:	006e4eb3          	xor	t4,t3,t1
    44a4:	411e1e8b          	th.mveqz	t4,t3,a7
    44a8:	0047d813          	srli	a6,a5,0x4
    44ac:	01d84fb3          	xor	t6,a6,t4
    44b0:	001ed693          	srli	a3,t4,0x1
    44b4:	001ff293          	andi	t0,t6,1
    44b8:	0066c733          	xor	a4,a3,t1
    44bc:	4056970b          	th.mveqz	a4,a3,t0
    44c0:	0057df13          	srli	t5,a5,0x5
    44c4:	00ef45b3          	xor	a1,t5,a4
    44c8:	00175393          	srli	t2,a4,0x1
    44cc:	0015f813          	andi	a6,a1,1
    44d0:	0063c8b3          	xor	a7,t2,t1
    44d4:	4103988b          	th.mveqz	a7,t2,a6
    44d8:	0067d613          	srli	a2,a5,0x6
    44dc:	0018df13          	srli	t5,a7,0x1
    44e0:	0077de13          	srli	t3,a5,0x7
    44e4:	011647b3          	xor	a5,a2,a7
    44e8:	0017fe93          	andi	t4,a5,1
    44ec:	006f4fb3          	xor	t6,t5,t1
    44f0:	41df1f8b          	th.mveqz	t6,t5,t4
    44f4:	01fe42b3          	xor	t0,t3,t6
    44f8:	001fd693          	srli	a3,t6,0x1
    44fc:	0012f713          	andi	a4,t0,1
    4500:	0066c333          	xor	t1,a3,t1
    4504:	42e3168b          	th.mvnez	a3,t1,a4
    4508:	7669                	lui	a2,0xffffa
    450a:	00160393          	addi	t2,a2,1 # ffffffffffffa001 <__kernel_stack+0xfffffffffff0c001>
    450e:	3c85388b          	th.extu	a7,a0,15,8
    4512:	0016d79b          	srliw	a5,a3,0x1
    4516:	00d8c5b3          	xor	a1,a7,a3
    451a:	0077cf33          	xor	t5,a5,t2
    451e:	0015fe13          	andi	t3,a1,1
    4522:	3c0f3f8b          	th.extu	t6,t5,15,0
    4526:	4016be8b          	th.extu	t4,a3,16,1
    452a:	43cf9e8b          	th.mvnez	t4,t6,t3
    452e:	001ed693          	srli	a3,t4,0x1
    4532:	3c95380b          	th.extu	a6,a0,15,9
    4536:	01d84733          	xor	a4,a6,t4
    453a:	0076c633          	xor	a2,a3,t2
    453e:	00177313          	andi	t1,a4,1
    4542:	3c063e0b          	th.extu	t3,a2,15,0
    4546:	40669e0b          	th.mveqz	t3,a3,t1
    454a:	001e5e93          	srli	t4,t3,0x1
    454e:	0028d293          	srli	t0,a7,0x2
    4552:	01c2c5b3          	xor	a1,t0,t3
    4556:	007ecf33          	xor	t5,t4,t2
    455a:	0015f793          	andi	a5,a1,1
    455e:	3c0f3f8b          	th.extu	t6,t5,15,0
    4562:	40fe9f8b          	th.mveqz	t6,t4,a5
    4566:	001fd693          	srli	a3,t6,0x1
    456a:	0038d813          	srli	a6,a7,0x3
    456e:	01f84733          	xor	a4,a6,t6
    4572:	0076c633          	xor	a2,a3,t2
    4576:	00177313          	andi	t1,a4,1
    457a:	3c063e0b          	th.extu	t3,a2,15,0
    457e:	40669e0b          	th.mveqz	t3,a3,t1
    4582:	001e5e93          	srli	t4,t3,0x1
    4586:	0048d293          	srli	t0,a7,0x4
    458a:	01c2c5b3          	xor	a1,t0,t3
    458e:	007ecf33          	xor	t5,t4,t2
    4592:	0015f793          	andi	a5,a1,1
    4596:	3c0f3f8b          	th.extu	t6,t5,15,0
    459a:	40fe9f8b          	th.mveqz	t6,t4,a5
    459e:	001fd693          	srli	a3,t6,0x1
    45a2:	0058d813          	srli	a6,a7,0x5
    45a6:	01f84733          	xor	a4,a6,t6
    45aa:	0076c633          	xor	a2,a3,t2
    45ae:	00177313          	andi	t1,a4,1
    45b2:	3c063e0b          	th.extu	t3,a2,15,0
    45b6:	40669e0b          	th.mveqz	t3,a3,t1
    45ba:	001e5793          	srli	a5,t3,0x1
    45be:	0068d293          	srli	t0,a7,0x6
    45c2:	01c2c833          	xor	a6,t0,t3
    45c6:	0077ceb3          	xor	t4,a5,t2
    45ca:	00187593          	andi	a1,a6,1
    45ce:	3c0ebf0b          	th.extu	t5,t4,15,0
    45d2:	40b79f0b          	th.mveqz	t5,a5,a1
    45d6:	001f5713          	srli	a4,t5,0x1
    45da:	0078d893          	srli	a7,a7,0x7
    45de:	01e8cfb3          	xor	t6,a7,t5
    45e2:	00774333          	xor	t1,a4,t2
    45e6:	001ff293          	andi	t0,t6,1
    45ea:	3c03368b          	th.extu	a3,t1,15,0
    45ee:	4256970b          	th.mvnez	a4,a3,t0
    45f2:	5d053e0b          	th.extu	t3,a0,23,16
    45f6:	0017559b          	srliw	a1,a4,0x1
    45fa:	00ee4633          	xor	a2,t3,a4
    45fe:	0075ceb3          	xor	t4,a1,t2
    4602:	00167813          	andi	a6,a2,1
    4606:	3c0ebf0b          	th.extu	t5,t4,15,0
    460a:	00175793          	srli	a5,a4,0x1
    460e:	430f178b          	th.mvnez	a5,t5,a6
    4612:	0017d713          	srli	a4,a5,0x1
    4616:	5d15388b          	th.extu	a7,a0,23,17
    461a:	00f8c2b3          	xor	t0,a7,a5
    461e:	007746b3          	xor	a3,a4,t2
    4622:	0012f313          	andi	t1,t0,1
    4626:	3c06b88b          	th.extu	a7,a3,15,0
    462a:	4067188b          	th.mveqz	a7,a4,t1
    462e:	0018d793          	srli	a5,a7,0x1
    4632:	002e5f93          	srli	t6,t3,0x2
    4636:	011fc633          	xor	a2,t6,a7
    463a:	0077ceb3          	xor	t4,a5,t2
    463e:	00167593          	andi	a1,a2,1
    4642:	3c0ebf0b          	th.extu	t5,t4,15,0
    4646:	40b79f0b          	th.mveqz	t5,a5,a1
    464a:	001f5713          	srli	a4,t5,0x1
    464e:	003e5813          	srli	a6,t3,0x3
    4652:	01e842b3          	xor	t0,a6,t5
    4656:	007746b3          	xor	a3,a4,t2
    465a:	0012f313          	andi	t1,t0,1
    465e:	3c06b88b          	th.extu	a7,a3,15,0
    4662:	4067188b          	th.mveqz	a7,a4,t1
    4666:	0018d793          	srli	a5,a7,0x1
    466a:	004e5f93          	srli	t6,t3,0x4
    466e:	011fc633          	xor	a2,t6,a7
    4672:	0077ceb3          	xor	t4,a5,t2
    4676:	00167593          	andi	a1,a2,1
    467a:	3c0ebf0b          	th.extu	t5,t4,15,0
    467e:	40b79f0b          	th.mveqz	t5,a5,a1
    4682:	001f5713          	srli	a4,t5,0x1
    4686:	005e5813          	srli	a6,t3,0x5
    468a:	01e842b3          	xor	t0,a6,t5
    468e:	007746b3          	xor	a3,a4,t2
    4692:	0012f313          	andi	t1,t0,1
    4696:	3c06b88b          	th.extu	a7,a3,15,0
    469a:	4067188b          	th.mveqz	a7,a4,t1
    469e:	0018d613          	srli	a2,a7,0x1
    46a2:	006e5f93          	srli	t6,t3,0x6
    46a6:	011fc833          	xor	a6,t6,a7
    46aa:	007647b3          	xor	a5,a2,t2
    46ae:	00187593          	andi	a1,a6,1
    46b2:	3c07be8b          	th.extu	t4,a5,15,0
    46b6:	40b61e8b          	th.mveqz	t4,a2,a1
    46ba:	001ed293          	srli	t0,t4,0x1
    46be:	007e5e13          	srli	t3,t3,0x7
    46c2:	01de4f33          	xor	t5,t3,t4
    46c6:	0072c333          	xor	t1,t0,t2
    46ca:	001f7f93          	andi	t6,t5,1
    46ce:	3c03370b          	th.extu	a4,t1,15,0
    46d2:	43f7128b          	th.mvnez	t0,a4,t6
    46d6:	0185569b          	srliw	a3,a0,0x18
    46da:	0012d81b          	srliw	a6,t0,0x1
    46de:	0056c8b3          	xor	a7,a3,t0
    46e2:	007845b3          	xor	a1,a6,t2
    46e6:	0018fe13          	andi	t3,a7,1
    46ea:	3c05b60b          	th.extu	a2,a1,15,0
    46ee:	0012d793          	srli	a5,t0,0x1
    46f2:	43c6178b          	th.mvnez	a5,a2,t3
    46f6:	0017d293          	srli	t0,a5,0x1
    46fa:	0195551b          	srliw	a0,a0,0x19
    46fe:	00f54f33          	xor	t5,a0,a5
    4702:	0072c333          	xor	t1,t0,t2
    4706:	001f7f93          	andi	t6,t5,1
    470a:	3c03370b          	th.extu	a4,t1,15,0
    470e:	41f2970b          	th.mveqz	a4,t0,t6
    4712:	00175813          	srli	a6,a4,0x1
    4716:	0026de93          	srli	t4,a3,0x2
    471a:	00eec8b3          	xor	a7,t4,a4
    471e:	007847b3          	xor	a5,a6,t2
    4722:	0018fe13          	andi	t3,a7,1
    4726:	3c07b60b          	th.extu	a2,a5,15,0
    472a:	41c8160b          	th.mveqz	a2,a6,t3
    472e:	00165f93          	srli	t6,a2,0x1
    4732:	0036d513          	srli	a0,a3,0x3
    4736:	00c54eb3          	xor	t4,a0,a2
    473a:	007fc2b3          	xor	t0,t6,t2
    473e:	001eff13          	andi	t5,t4,1
    4742:	3c02b30b          	th.extu	t1,t0,15,0
    4746:	41ef930b          	th.mveqz	t1,t6,t5
    474a:	00135e13          	srli	t3,t1,0x1
    474e:	0046d593          	srli	a1,a3,0x4
    4752:	0065c733          	xor	a4,a1,t1
    4756:	007e4833          	xor	a6,t3,t2
    475a:	00177893          	andi	a7,a4,1
    475e:	3c08378b          	th.extu	a5,a6,15,0
    4762:	411e178b          	th.mveqz	a5,t3,a7
    4766:	0056d513          	srli	a0,a3,0x5
    476a:	0017df13          	srli	t5,a5,0x1
    476e:	00f54633          	xor	a2,a0,a5
    4772:	007f4fb3          	xor	t6,t5,t2
    4776:	00167e93          	andi	t4,a2,1
    477a:	3c0fb28b          	th.extu	t0,t6,15,0
    477e:	41df128b          	th.mveqz	t0,t5,t4
    4782:	0066d593          	srli	a1,a3,0x6
    4786:	0012d893          	srli	a7,t0,0x1
    478a:	0055c333          	xor	t1,a1,t0
    478e:	0078c733          	xor	a4,a7,t2
    4792:	00137513          	andi	a0,t1,1
    4796:	3c073e0b          	th.extu	t3,a4,15,0
    479a:	40a89e0b          	th.mveqz	t3,a7,a0
    479e:	001e5613          	srli	a2,t3,0x1
    47a2:	829d                	srli	a3,a3,0x7
    47a4:	01c6c833          	xor	a6,a3,t3
    47a8:	007643b3          	xor	t2,a2,t2
    47ac:	00187593          	andi	a1,a6,1
    47b0:	3c03b50b          	th.extu	a0,t2,15,0
    47b4:	40b6150b          	th.mveqz	a0,a2,a1
    47b8:	8082                	ret
    47ba:	00000013          	nop
    47be:	0001                	nop

00000000000047c0 <crc16>:
    47c0:	0ff57793          	zext.b	a5,a0
    47c4:	6829                	lui	a6,0xa
    47c6:	00180313          	addi	t1,a6,1 # a001 <_vsnprintf+0x1461>
    47ca:	00b7c633          	xor	a2,a5,a1
    47ce:	0015d71b          	srliw	a4,a1,0x1
    47d2:	00167293          	andi	t0,a2,1
    47d6:	006743b3          	xor	t2,a4,t1
    47da:	8185                	srli	a1,a1,0x1
    47dc:	4055938b          	th.mveqz	t2,a1,t0
    47e0:	1c15368b          	th.extu	a3,a0,7,1
    47e4:	0076ce33          	xor	t3,a3,t2
    47e8:	0013df13          	srli	t5,t2,0x1
    47ec:	001e7e93          	andi	t4,t3,1
    47f0:	006f4fb3          	xor	t6,t5,t1
    47f4:	41df1f8b          	th.mveqz	t6,t5,t4
    47f8:	0027d893          	srli	a7,a5,0x2
    47fc:	01f8c6b3          	xor	a3,a7,t6
    4800:	001fd593          	srli	a1,t6,0x1
    4804:	0016f613          	andi	a2,a3,1
    4808:	0065c733          	xor	a4,a1,t1
    480c:	40c5970b          	th.mveqz	a4,a1,a2
    4810:	0037d293          	srli	t0,a5,0x3
    4814:	00e2c3b3          	xor	t2,t0,a4
    4818:	00175e13          	srli	t3,a4,0x1
    481c:	0013f893          	andi	a7,t2,1
    4820:	006e4eb3          	xor	t4,t3,t1
    4824:	411e1e8b          	th.mveqz	t4,t3,a7
    4828:	0047d813          	srli	a6,a5,0x4
    482c:	01d84fb3          	xor	t6,a6,t4
    4830:	001ed693          	srli	a3,t4,0x1
    4834:	001ff293          	andi	t0,t6,1
    4838:	0066c733          	xor	a4,a3,t1
    483c:	4056970b          	th.mveqz	a4,a3,t0
    4840:	0057df13          	srli	t5,a5,0x5
    4844:	00ef45b3          	xor	a1,t5,a4
    4848:	00175393          	srli	t2,a4,0x1
    484c:	0015f813          	andi	a6,a1,1
    4850:	0063c8b3          	xor	a7,t2,t1
    4854:	4103988b          	th.mveqz	a7,t2,a6
    4858:	0067d613          	srli	a2,a5,0x6
    485c:	01164e33          	xor	t3,a2,a7
    4860:	0018df13          	srli	t5,a7,0x1
    4864:	001e7e93          	andi	t4,t3,1
    4868:	006f4fb3          	xor	t6,t5,t1
    486c:	41df1f8b          	th.mveqz	t6,t5,t4
    4870:	839d                	srli	a5,a5,0x7
    4872:	01f7c2b3          	xor	t0,a5,t6
    4876:	001fd713          	srli	a4,t6,0x1
    487a:	0012f593          	andi	a1,t0,1
    487e:	00674333          	xor	t1,a4,t1
    4882:	42b3170b          	th.mvnez	a4,t1,a1
    4886:	76e9                	lui	a3,0xffffa
    4888:	00168813          	addi	a6,a3,1 # ffffffffffffa001 <__kernel_stack+0xfffffffffff0c001>
    488c:	3c85338b          	th.extu	t2,a0,15,8
    4890:	0017579b          	srliw	a5,a4,0x1
    4894:	00e3c633          	xor	a2,t2,a4
    4898:	0107ceb3          	xor	t4,a5,a6
    489c:	00167893          	andi	a7,a2,1
    48a0:	3c0ebf0b          	th.extu	t5,t4,15,0
    48a4:	40173e0b          	th.extu	t3,a4,16,1
    48a8:	431f1e0b          	th.mvnez	t3,t5,a7
    48ac:	001e5713          	srli	a4,t3,0x1
    48b0:	3c95350b          	th.extu	a0,a0,15,9
    48b4:	01c542b3          	xor	t0,a0,t3
    48b8:	010746b3          	xor	a3,a4,a6
    48bc:	0012f593          	andi	a1,t0,1
    48c0:	3c06b30b          	th.extu	t1,a3,15,0
    48c4:	40b7130b          	th.mveqz	t1,a4,a1
    48c8:	00135793          	srli	a5,t1,0x1
    48cc:	0023df93          	srli	t6,t2,0x2
    48d0:	006fc633          	xor	a2,t6,t1
    48d4:	0107ce33          	xor	t3,a5,a6
    48d8:	00167893          	andi	a7,a2,1
    48dc:	3c0e3e8b          	th.extu	t4,t3,15,0
    48e0:	41179e8b          	th.mveqz	t4,a5,a7
    48e4:	001ed593          	srli	a1,t4,0x1
    48e8:	0033d513          	srli	a0,t2,0x3
    48ec:	01d54fb3          	xor	t6,a0,t4
    48f0:	0105c733          	xor	a4,a1,a6
    48f4:	001ff293          	andi	t0,t6,1
    48f8:	3c07368b          	th.extu	a3,a4,15,0
    48fc:	4055968b          	th.mveqz	a3,a1,t0
    4900:	0016d613          	srli	a2,a3,0x1
    4904:	0043df13          	srli	t5,t2,0x4
    4908:	00df4533          	xor	a0,t5,a3
    490c:	010647b3          	xor	a5,a2,a6
    4910:	00157893          	andi	a7,a0,1
    4914:	3c07be0b          	th.extu	t3,a5,15,0
    4918:	41161e0b          	th.mveqz	t3,a2,a7
    491c:	001e5293          	srli	t0,t3,0x1
    4920:	0053d313          	srli	t1,t2,0x5
    4924:	01c34f33          	xor	t5,t1,t3
    4928:	0102c5b3          	xor	a1,t0,a6
    492c:	001f7f93          	andi	t6,t5,1
    4930:	3c05b70b          	th.extu	a4,a1,15,0
    4934:	41f2970b          	th.mveqz	a4,t0,t6
    4938:	00175513          	srli	a0,a4,0x1
    493c:	0063de93          	srli	t4,t2,0x6
    4940:	010548b3          	xor	a7,a0,a6
    4944:	00eec6b3          	xor	a3,t4,a4
    4948:	0016f313          	andi	t1,a3,1
    494c:	3c08b60b          	th.extu	a2,a7,15,0
    4950:	4065160b          	th.mveqz	a2,a0,t1
    4954:	00165e93          	srli	t4,a2,0x1
    4958:	0073d393          	srli	t2,t2,0x7
    495c:	00c3c7b3          	xor	a5,t2,a2
    4960:	010ec833          	xor	a6,t4,a6
    4964:	0017fe13          	andi	t3,a5,1
    4968:	3c08350b          	th.extu	a0,a6,15,0
    496c:	41ce950b          	th.mveqz	a0,t4,t3
    4970:	8082                	ret
    4972:	0001                	nop
    4974:	00000013          	nop
    4978:	00000013          	nop
    497c:	00000013          	nop

0000000000004980 <check_data_types>:
    4980:	4501                	li	a0,0
    4982:	8082                	ret
	...

0000000000004990 <ecvt>:
    4990:	7159                	addi	sp,sp,-112
    4992:	f20007d3          	fmv.d.x	fa5,zero
    4996:	eca6                	sd	s1,88(sp)
    4998:	f0a2                	sd	s0,96(sp)
    499a:	0005041b          	sext.w	s0,a0
    499e:	04e00793          	li	a5,78
    49a2:	00042693          	slti	a3,s0,0
    49a6:	a2f512d3          	flt.d	t0,fa0,fa5
    49aa:	fc56                	sd	s5,56(sp)
    49ac:	e0d2                	sd	s4,64(sp)
    49ae:	e4ce                	sd	s3,72(sp)
    49b0:	e8ca                	sd	s2,80(sp)
    49b2:	42d0140b          	th.mvnez	s0,zero,a3
    49b6:	00a7a533          	slt	a0,a5,a0
    49ba:	b422                	fsd	fs0,40(sp)
    49bc:	b026                	fsd	fs1,32(sp)
    49be:	ac4a                	fsd	fs2,24(sp)
    49c0:	f486                	sd	ra,104(sp)
    49c2:	892e                	mv	s2,a1
    49c4:	42a7940b          	th.mvnez	s0,a5,a0
    49c8:	6c029063          	bnez	t0,5088 <ecvt+0x6f8>
    49cc:	00062023          	sw	zero,0(a2)
    49d0:	850a                	mv	a0,sp
    49d2:	5850a0ef          	jal	f756 <modf>
    49d6:	2e02                	fld	ft8,0(sp)
    49d8:	f2000953          	fmv.d.x	fs2,zero
    49dc:	22a50453          	fmv.d	fs0,fa0
    49e0:	a32e23d3          	feq.d	t2,ft8,fs2
    49e4:	5c039663          	bnez	t2,4fb0 <ecvt+0x620>
    49e8:	00041537          	lui	a0,0x41
    49ec:	62c5                	lui	t0,0x11
    49ee:	6345                	lui	t1,0x11
    49f0:	a84e                	fsd	fs3,16(sp)
    49f2:	fd050493          	addi	s1,a0,-48 # 40fd0 <CVTBUF>
    49f6:	b802b487          	fld	fs1,-1152(t0) # 10b80 <errpat+0x38>
    49fa:	b8833987          	fld	fs3,-1144(t1) # 10b88 <errpat+0x40>
    49fe:	05048993          	addi	s3,s1,80
    4a02:	f85a                	sd	s6,48(sp)
    4a04:	4a81                	li	s5,0
    4a06:	8b4e                	mv	s6,s3
    4a08:	1a9e7553          	fdiv.d	fa0,ft8,fs1
    4a0c:	850a                	mv	a0,sp
    4a0e:	1b7d                	addi	s6,s6,-1
    4a10:	2a85                	addiw	s5,s5,1
    4a12:	8a5a                	mv	s4,s6
    4a14:	5430a0ef          	jal	f756 <modf>
    4a18:	a42a                	fsd	fa0,8(sp)
    4a1a:	03357553          	fadd.d	fa0,fa0,fs3
    4a1e:	2102                	fld	ft2,0(sp)
    4a20:	8356                	mv	t1,s5
    4a22:	129570d3          	fmul.d	ft1,fa0,fs1
    4a26:	a3212753          	feq.d	a4,ft2,fs2
    4a2a:	c20093d3          	fcvt.w.d	t2,ft1,rtz
    4a2e:	0303859b          	addiw	a1,t2,48
    4a32:	0ff5f293          	zext.b	t0,a1
    4a36:	005b0023          	sb	t0,0(s6)
    4a3a:	ef59                	bnez	a4,4ad8 <ecvt+0x148>
    4a3c:	1a917553          	fdiv.d	fa0,ft2,fs1
    4a40:	850a                	mv	a0,sp
    4a42:	2a85                	addiw	s5,s5,1
    4a44:	5130a0ef          	jal	f756 <modf>
    4a48:	033571d3          	fadd.d	ft3,fa0,fs3
    4a4c:	2282                	fld	ft5,0(sp)
    4a4e:	a42a                	fsd	fa0,8(sp)
    4a50:	1291f253          	fmul.d	ft4,ft3,fs1
    4a54:	a322a8d3          	feq.d	a7,ft5,fs2
    4a58:	8356                	mv	t1,s5
    4a5a:	c2021653          	fcvt.w.d	a2,ft4,rtz
    4a5e:	0306081b          	addiw	a6,a2,48
    4a62:	0ff87293          	zext.b	t0,a6
    4a66:	09fb528b          	th.sbib	t0,(s6),-1,0
    4a6a:	06089763          	bnez	a7,4ad8 <ecvt+0x148>
    4a6e:	1a92f553          	fdiv.d	fa0,ft5,fs1
    4a72:	850a                	mv	a0,sp
    4a74:	2a85                	addiw	s5,s5,1
    4a76:	ffea0b13          	addi	s6,s4,-2 # ffffffffffffeffe <__kernel_stack+0xfffffffffff10ffe>
    4a7a:	4dd0a0ef          	jal	f756 <modf>
    4a7e:	03357353          	fadd.d	ft6,fa0,fs3
    4a82:	2582                	fld	fa1,0(sp)
    4a84:	a42a                	fsd	fa0,8(sp)
    4a86:	129373d3          	fmul.d	ft7,ft6,fs1
    4a8a:	a325af53          	feq.d	t5,fa1,fs2
    4a8e:	8356                	mv	t1,s5
    4a90:	c2039e53          	fcvt.w.d	t3,ft7,rtz
    4a94:	030e0e9b          	addiw	t4,t3,48
    4a98:	0ffef293          	zext.b	t0,t4
    4a9c:	fe5a0f23          	sb	t0,-2(s4)
    4aa0:	020f1c63          	bnez	t5,4ad8 <ecvt+0x148>
    4aa4:	1a95f553          	fdiv.d	fa0,fa1,fs1
    4aa8:	850a                	mv	a0,sp
    4aaa:	2a85                	addiw	s5,s5,1
    4aac:	ffda0b13          	addi	s6,s4,-3
    4ab0:	4a70a0ef          	jal	f756 <modf>
    4ab4:	03357853          	fadd.d	fa6,fa0,fs3
    4ab8:	2e02                	fld	ft8,0(sp)
    4aba:	a42a                	fsd	fa0,8(sp)
    4abc:	129878d3          	fmul.d	fa7,fa6,fs1
    4ac0:	a32e26d3          	feq.d	a3,ft8,fs2
    4ac4:	8356                	mv	t1,s5
    4ac6:	c2089fd3          	fcvt.w.d	t6,fa7,rtz
    4aca:	030f879b          	addiw	a5,t6,48
    4ace:	0ff7f293          	zext.b	t0,a5
    4ad2:	fe5a0ea3          	sb	t0,-3(s4)
    4ad6:	da8d                	beqz	a3,4a08 <ecvt+0x78>
    4ad8:	5d3b7e63          	bgeu	s6,s3,50b4 <ecvt+0x724>
    4adc:	fffb4a93          	not	s5,s6
    4ae0:	01598533          	add	a0,s3,s5
    4ae4:	00757a13          	andi	s4,a0,7
    4ae8:	875a                	mv	a4,s6
    4aea:	8ea6                	mv	t4,s1
    4aec:	0a0a0863          	beqz	s4,4b9c <ecvt+0x20c>
    4af0:	181ed28b          	th.sbia	t0,(t4),1,0
    4af4:	4385                	li	t2,1
    4af6:	8817428b          	th.lbuib	t0,(a4),1,0
    4afa:	0a7a0163          	beq	s4,t2,4b9c <ecvt+0x20c>
    4afe:	4589                	li	a1,2
    4b00:	04ba0563          	beq	s4,a1,4b4a <ecvt+0x1ba>
    4b04:	460d                	li	a2,3
    4b06:	02ca0e63          	beq	s4,a2,4b42 <ecvt+0x1b2>
    4b0a:	4811                	li	a6,4
    4b0c:	030a0763          	beq	s4,a6,4b3a <ecvt+0x1aa>
    4b10:	4895                	li	a7,5
    4b12:	031a0063          	beq	s4,a7,4b32 <ecvt+0x1a2>
    4b16:	4e19                	li	t3,6
    4b18:	01ca0963          	beq	s4,t3,4b2a <ecvt+0x19a>
    4b1c:	875a                	mv	a4,s6
    4b1e:	005480a3          	sb	t0,1(s1)
    4b22:	8827428b          	th.lbuib	t0,(a4),2,0
    4b26:	00248e93          	addi	t4,s1,2
    4b2a:	181ed28b          	th.sbia	t0,(t4),1,0
    4b2e:	8817428b          	th.lbuib	t0,(a4),1,0
    4b32:	181ed28b          	th.sbia	t0,(t4),1,0
    4b36:	8817428b          	th.lbuib	t0,(a4),1,0
    4b3a:	181ed28b          	th.sbia	t0,(t4),1,0
    4b3e:	8817428b          	th.lbuib	t0,(a4),1,0
    4b42:	181ed28b          	th.sbia	t0,(t4),1,0
    4b46:	8817428b          	th.lbuib	t0,(a4),1,0
    4b4a:	181ed28b          	th.sbia	t0,(t4),1,0
    4b4e:	8817428b          	th.lbuib	t0,(a4),1,0
    4b52:	00170793          	addi	a5,a4,1
    4b56:	005e8023          	sb	t0,0(t4)
    4b5a:	04f98763          	beq	s3,a5,4ba8 <ecvt+0x218>
    4b5e:	00174883          	lbu	a7,1(a4)
    4b62:	0ea1                	addi	t4,t4,8
    4b64:	ff1e8ca3          	sb	a7,-7(t4)
    4b68:	00274603          	lbu	a2,2(a4)
    4b6c:	fece8d23          	sb	a2,-6(t4)
    4b70:	00374f83          	lbu	t6,3(a4)
    4b74:	fffe8da3          	sb	t6,-5(t4)
    4b78:	00474283          	lbu	t0,4(a4)
    4b7c:	fe5e8e23          	sb	t0,-4(t4)
    4b80:	00574a83          	lbu	s5,5(a4)
    4b84:	ff5e8ea3          	sb	s5,-3(t4)
    4b88:	00674a03          	lbu	s4,6(a4)
    4b8c:	ff4e8f23          	sb	s4,-2(t4)
    4b90:	00774683          	lbu	a3,7(a4)
    4b94:	fede8fa3          	sb	a3,-1(t4)
    4b98:	8887428b          	th.lbuib	t0,(a4),8,0
    4b9c:	00170793          	addi	a5,a4,1
    4ba0:	005e8023          	sb	t0,0(t4)
    4ba4:	faf99de3          	bne	s3,a5,4b5e <ecvt+0x1ce>
    4ba8:	9426                	add	s0,s0,s1
    4baa:	00692023          	sw	t1,0(s2)
    4bae:	4e946363          	bltu	s0,s1,5094 <ecvt+0x704>
    4bb2:	01348f33          	add	t5,s1,s3
    4bb6:	416f0a33          	sub	s4,t5,s6
    4bba:	29c2                	fld	fs3,16(sp)
    4bbc:	7b42                	ld	s6,48(sp)
    4bbe:	11446963          	bltu	s0,s4,4cd0 <ecvt+0x340>
    4bc2:	414982b3          	sub	t0,s3,s4
    4bc6:	6fc5                	lui	t6,0x11
    4bc8:	0032fa93          	andi	s5,t0,3
    4bcc:	b80fb907          	fld	fs2,-1152(t6) # 10b80 <errpat+0x38>
    4bd0:	060a8c63          	beqz	s5,4c48 <ecvt+0x2b8>
    4bd4:	0f3a7e63          	bgeu	s4,s3,4cd0 <ecvt+0x340>
    4bd8:	13247553          	fmul.d	fa0,fs0,fs2
    4bdc:	0028                	addi	a0,sp,8
    4bde:	3790a0ef          	jal	f756 <modf>
    4be2:	2ea2                	fld	ft9,8(sp)
    4be4:	22a50453          	fmv.d	fs0,fa0
    4be8:	c20e9353          	fcvt.w.d	t1,ft9,rtz
    4bec:	0303069b          	addiw	a3,t1,48
    4bf0:	181a568b          	th.sbia	a3,(s4),1,0
    4bf4:	0d446e63          	bltu	s0,s4,4cd0 <ecvt+0x340>
    4bf8:	4505                	li	a0,1
    4bfa:	04aa8763          	beq	s5,a0,4c48 <ecvt+0x2b8>
    4bfe:	4389                	li	t2,2
    4c00:	027a8263          	beq	s5,t2,4c24 <ecvt+0x294>
    4c04:	13257553          	fmul.d	fa0,fa0,fs2
    4c08:	0028                	addi	a0,sp,8
    4c0a:	34d0a0ef          	jal	f756 <modf>
    4c0e:	2f22                	fld	ft10,8(sp)
    4c10:	22a50453          	fmv.d	fs0,fa0
    4c14:	c20f15d3          	fcvt.w.d	a1,ft10,rtz
    4c18:	0305861b          	addiw	a2,a1,48
    4c1c:	181a560b          	th.sbia	a2,(s4),1,0
    4c20:	0b446863          	bltu	s0,s4,4cd0 <ecvt+0x340>
    4c24:	13247553          	fmul.d	fa0,fs0,fs2
    4c28:	0028                	addi	a0,sp,8
    4c2a:	32d0a0ef          	jal	f756 <modf>
    4c2e:	2fa2                	fld	ft11,8(sp)
    4c30:	22a50453          	fmv.d	fs0,fa0
    4c34:	c20f9853          	fcvt.w.d	a6,ft11,rtz
    4c38:	0308089b          	addiw	a7,a6,48
    4c3c:	181a588b          	th.sbia	a7,(s4),1,0
    4c40:	09446863          	bltu	s0,s4,4cd0 <ecvt+0x340>
    4c44:	00000013          	nop
    4c48:	093a7463          	bgeu	s4,s3,4cd0 <ecvt+0x340>
    4c4c:	13247553          	fmul.d	fa0,fs0,fs2
    4c50:	0028                	addi	a0,sp,8
    4c52:	3050a0ef          	jal	f756 <modf>
    4c56:	27a2                	fld	fa5,8(sp)
    4c58:	8e52                	mv	t3,s4
    4c5a:	c2079753          	fcvt.w.d	a4,fa5,rtz
    4c5e:	03070e9b          	addiw	t4,a4,48
    4c62:	181e5e8b          	th.sbia	t4,(t3),1,0
    4c66:	07c46563          	bltu	s0,t3,4cd0 <ecvt+0x340>
    4c6a:	13257553          	fmul.d	fa0,fa0,fs2
    4c6e:	0028                	addi	a0,sp,8
    4c70:	2e70a0ef          	jal	f756 <modf>
    4c74:	2722                	fld	fa4,8(sp)
    4c76:	002a0793          	addi	a5,s4,2
    4c7a:	c2071f53          	fcvt.w.d	t5,fa4,rtz
    4c7e:	030f0f9b          	addiw	t6,t5,48
    4c82:	01fa00a3          	sb	t6,1(s4)
    4c86:	04f46563          	bltu	s0,a5,4cd0 <ecvt+0x340>
    4c8a:	13257553          	fmul.d	fa0,fa0,fs2
    4c8e:	0028                	addi	a0,sp,8
    4c90:	2c70a0ef          	jal	f756 <modf>
    4c94:	2622                	fld	fa2,8(sp)
    4c96:	003a0293          	addi	t0,s4,3
    4c9a:	c2061ad3          	fcvt.w.d	s5,fa2,rtz
    4c9e:	030a831b          	addiw	t1,s5,48
    4ca2:	006a0123          	sb	t1,2(s4)
    4ca6:	02546563          	bltu	s0,t0,4cd0 <ecvt+0x340>
    4caa:	13257553          	fmul.d	fa0,fa0,fs2
    4cae:	0028                	addi	a0,sp,8
    4cb0:	0a11                	addi	s4,s4,4
    4cb2:	2a50a0ef          	jal	f756 <modf>
    4cb6:	26a2                	fld	fa3,8(sp)
    4cb8:	22a50453          	fmv.d	fs0,fa0
    4cbc:	c20696d3          	fcvt.w.d	a3,fa3,rtz
    4cc0:	0306851b          	addiw	a0,a3,48
    4cc4:	feaa0fa3          	sb	a0,-1(s4)
    4cc8:	f94470e3          	bgeu	s0,s4,4c48 <ecvt+0x2b8>
    4ccc:	00000013          	nop
    4cd0:	3d347863          	bgeu	s0,s3,50a0 <ecvt+0x710>
    4cd4:	00044983          	lbu	s3,0(s0)
    4cd8:	03900813          	li	a6,57
    4cdc:	0059839b          	addiw	t2,s3,5
    4ce0:	0ff3f593          	zext.b	a1,t2
    4ce4:	10b87263          	bgeu	a6,a1,4de8 <ecvt+0x458>
    4ce8:	40940e33          	sub	t3,s0,s1
    4cec:	00b40023          	sb	a1,0(s0)
    4cf0:	007e7713          	andi	a4,t3,7
    4cf4:	87a2                	mv	a5,s0
    4cf6:	03000613          	li	a2,48
    4cfa:	88c2                	mv	a7,a6
    4cfc:	1e070663          	beqz	a4,4ee8 <ecvt+0x558>
    4d00:	1084e463          	bltu	s1,s0,4e08 <ecvt+0x478>
    4d04:	03100893          	li	a7,49
    4d08:	01178023          	sb	a7,0(a5)
    4d0c:	00092603          	lw	a2,0(s2)
    4d10:	03900e13          	li	t3,57
    4d14:	0016059b          	addiw	a1,a2,1
    4d18:	00b92023          	sw	a1,0(s2)
    4d1c:	0007c803          	lbu	a6,0(a5)
    4d20:	0d0e7463          	bgeu	t3,a6,4de8 <ecvt+0x458>
    4d24:	01178023          	sb	a7,0(a5)
    4d28:	00092703          	lw	a4,0(s2)
    4d2c:	00170e9b          	addiw	t4,a4,1
    4d30:	01d92023          	sw	t4,0(s2)
    4d34:	0007cf03          	lbu	t5,0(a5)
    4d38:	0bee7863          	bgeu	t3,t5,4de8 <ecvt+0x458>
    4d3c:	01178023          	sb	a7,0(a5)
    4d40:	00092f83          	lw	t6,0(s2)
    4d44:	001f829b          	addiw	t0,t6,1
    4d48:	00592023          	sw	t0,0(s2)
    4d4c:	0007ca83          	lbu	s5,0(a5)
    4d50:	095e7c63          	bgeu	t3,s5,4de8 <ecvt+0x458>
    4d54:	01178023          	sb	a7,0(a5)
    4d58:	00092303          	lw	t1,0(s2)
    4d5c:	00130a1b          	addiw	s4,t1,1
    4d60:	01492023          	sw	s4,0(s2)
    4d64:	0007c683          	lbu	a3,0(a5)
    4d68:	08de7063          	bgeu	t3,a3,4de8 <ecvt+0x458>
    4d6c:	01178023          	sb	a7,0(a5)
    4d70:	00092503          	lw	a0,0(s2)
    4d74:	0015099b          	addiw	s3,a0,1
    4d78:	01392023          	sw	s3,0(s2)
    4d7c:	0007c383          	lbu	t2,0(a5)
    4d80:	067e7463          	bgeu	t3,t2,4de8 <ecvt+0x458>
    4d84:	01178023          	sb	a7,0(a5)
    4d88:	00092603          	lw	a2,0(s2)
    4d8c:	0016059b          	addiw	a1,a2,1
    4d90:	00b92023          	sw	a1,0(s2)
    4d94:	0007c803          	lbu	a6,0(a5)
    4d98:	050e7863          	bgeu	t3,a6,4de8 <ecvt+0x458>
    4d9c:	01178023          	sb	a7,0(a5)
    4da0:	00092703          	lw	a4,0(s2)
    4da4:	00170e9b          	addiw	t4,a4,1
    4da8:	01d92023          	sw	t4,0(s2)
    4dac:	0007cf03          	lbu	t5,0(a5)
    4db0:	03ee7c63          	bgeu	t3,t5,4de8 <ecvt+0x458>
    4db4:	01178023          	sb	a7,0(a5)
    4db8:	00092f83          	lw	t6,0(s2)
    4dbc:	001f829b          	addiw	t0,t6,1
    4dc0:	00592023          	sw	t0,0(s2)
    4dc4:	0007ca83          	lbu	s5,0(a5)
    4dc8:	035e7063          	bgeu	t3,s5,4de8 <ecvt+0x458>
    4dcc:	01178023          	sb	a7,0(a5)
    4dd0:	00092303          	lw	t1,0(s2)
    4dd4:	00130a1b          	addiw	s4,t1,1
    4dd8:	01492023          	sw	s4,0(s2)
    4ddc:	0007c683          	lbu	a3,0(a5)
    4de0:	f4de62e3          	bltu	t3,a3,4d24 <ecvt+0x394>
    4de4:	00000013          	nop
    4de8:	00040023          	sb	zero,0(s0)
    4dec:	70a6                	ld	ra,104(sp)
    4dee:	8526                	mv	a0,s1
    4df0:	64e6                	ld	s1,88(sp)
    4df2:	7406                	ld	s0,96(sp)
    4df4:	7ae2                	ld	s5,56(sp)
    4df6:	6a06                	ld	s4,64(sp)
    4df8:	69a6                	ld	s3,72(sp)
    4dfa:	6946                	ld	s2,80(sp)
    4dfc:	3422                	fld	fs0,40(sp)
    4dfe:	3482                	fld	fs1,32(sp)
    4e00:	2962                	fld	fs2,24(sp)
    4e02:	6165                	addi	sp,sp,112
    4e04:	8082                	ret
    4e06:	0001                	nop
    4e08:	fff44e83          	lbu	t4,-1(s0)
    4e0c:	00c40023          	sb	a2,0(s0)
    4e10:	001e879b          	addiw	a5,t4,1
    4e14:	0ff7ff13          	zext.b	t5,a5
    4e18:	ffe40fa3          	sb	t5,-1(s0)
    4e1c:	fde876e3          	bgeu	a6,t5,4de8 <ecvt+0x458>
    4e20:	4f85                	li	t6,1
    4e22:	fff40793          	addi	a5,s0,-1
    4e26:	0df70163          	beq	a4,t6,4ee8 <ecvt+0x558>
    4e2a:	4289                	li	t0,2
    4e2c:	08570f63          	beq	a4,t0,4eca <ecvt+0x53a>
    4e30:	4a8d                	li	s5,3
    4e32:	07570f63          	beq	a4,s5,4eb0 <ecvt+0x520>
    4e36:	4311                	li	t1,4
    4e38:	04670f63          	beq	a4,t1,4e96 <ecvt+0x506>
    4e3c:	4a15                	li	s4,5
    4e3e:	03470f63          	beq	a4,s4,4e7c <ecvt+0x4ec>
    4e42:	4699                	li	a3,6
    4e44:	00d70f63          	beq	a4,a3,4e62 <ecvt+0x4d2>
    4e48:	fff7c503          	lbu	a0,-1(a5)
    4e4c:	00c78023          	sb	a2,0(a5)
    4e50:	0015099b          	addiw	s3,a0,1
    4e54:	0ff9f393          	zext.b	t2,s3
    4e58:	fe778fa3          	sb	t2,-1(a5)
    4e5c:	f87876e3          	bgeu	a6,t2,4de8 <ecvt+0x458>
    4e60:	17fd                	addi	a5,a5,-1
    4e62:	fff7c583          	lbu	a1,-1(a5)
    4e66:	00c78023          	sb	a2,0(a5)
    4e6a:	0015881b          	addiw	a6,a1,1
    4e6e:	0ff87e13          	zext.b	t3,a6
    4e72:	ffc78fa3          	sb	t3,-1(a5)
    4e76:	f7c8f9e3          	bgeu	a7,t3,4de8 <ecvt+0x458>
    4e7a:	17fd                	addi	a5,a5,-1
    4e7c:	fff7c703          	lbu	a4,-1(a5)
    4e80:	00c78023          	sb	a2,0(a5)
    4e84:	00170e9b          	addiw	t4,a4,1
    4e88:	0ffeff13          	zext.b	t5,t4
    4e8c:	ffe78fa3          	sb	t5,-1(a5)
    4e90:	f5e8fce3          	bgeu	a7,t5,4de8 <ecvt+0x458>
    4e94:	17fd                	addi	a5,a5,-1
    4e96:	fff7cf83          	lbu	t6,-1(a5)
    4e9a:	00c78023          	sb	a2,0(a5)
    4e9e:	001f829b          	addiw	t0,t6,1
    4ea2:	0ff2fa93          	zext.b	s5,t0
    4ea6:	ff578fa3          	sb	s5,-1(a5)
    4eaa:	f358ffe3          	bgeu	a7,s5,4de8 <ecvt+0x458>
    4eae:	17fd                	addi	a5,a5,-1
    4eb0:	fff7c303          	lbu	t1,-1(a5)
    4eb4:	00c78023          	sb	a2,0(a5)
    4eb8:	00130a1b          	addiw	s4,t1,1
    4ebc:	0ffa7693          	zext.b	a3,s4
    4ec0:	fed78fa3          	sb	a3,-1(a5)
    4ec4:	f2d8f2e3          	bgeu	a7,a3,4de8 <ecvt+0x458>
    4ec8:	17fd                	addi	a5,a5,-1
    4eca:	fff7c503          	lbu	a0,-1(a5)
    4ece:	00c78023          	sb	a2,0(a5)
    4ed2:	17fd                	addi	a5,a5,-1
    4ed4:	0015099b          	addiw	s3,a0,1
    4ed8:	0ff9f393          	zext.b	t2,s3
    4edc:	00778023          	sb	t2,0(a5)
    4ee0:	f078f4e3          	bgeu	a7,t2,4de8 <ecvt+0x458>
    4ee4:	00000013          	nop
    4ee8:	e0f4fee3          	bgeu	s1,a5,4d04 <ecvt+0x374>
    4eec:	fff7ce03          	lbu	t3,-1(a5)
    4ef0:	00c78023          	sb	a2,0(a5)
    4ef4:	001e051b          	addiw	a0,t3,1
    4ef8:	0ff57993          	zext.b	s3,a0
    4efc:	ff378fa3          	sb	s3,-1(a5)
    4f00:	ef38f4e3          	bgeu	a7,s3,4de8 <ecvt+0x458>
    4f04:	ffe7c383          	lbu	t2,-2(a5)
    4f08:	fec78fa3          	sb	a2,-1(a5)
    4f0c:	0013859b          	addiw	a1,t2,1
    4f10:	0ff5f813          	zext.b	a6,a1
    4f14:	ff078f23          	sb	a6,-2(a5)
    4f18:	ed08f8e3          	bgeu	a7,a6,4de8 <ecvt+0x458>
    4f1c:	ffd7c703          	lbu	a4,-3(a5)
    4f20:	fec78f23          	sb	a2,-2(a5)
    4f24:	00170e9b          	addiw	t4,a4,1
    4f28:	0ffeff13          	zext.b	t5,t4
    4f2c:	ffe78ea3          	sb	t5,-3(a5)
    4f30:	ebe8fce3          	bgeu	a7,t5,4de8 <ecvt+0x458>
    4f34:	ffc7cf83          	lbu	t6,-4(a5)
    4f38:	fec78ea3          	sb	a2,-3(a5)
    4f3c:	001f829b          	addiw	t0,t6,1
    4f40:	0ff2fa93          	zext.b	s5,t0
    4f44:	ff578e23          	sb	s5,-4(a5)
    4f48:	eb58f0e3          	bgeu	a7,s5,4de8 <ecvt+0x458>
    4f4c:	ffb7c303          	lbu	t1,-5(a5)
    4f50:	fec78e23          	sb	a2,-4(a5)
    4f54:	00130a1b          	addiw	s4,t1,1
    4f58:	0ffa7693          	zext.b	a3,s4
    4f5c:	fed78da3          	sb	a3,-5(a5)
    4f60:	e8d8f4e3          	bgeu	a7,a3,4de8 <ecvt+0x458>
    4f64:	ffa7ce03          	lbu	t3,-6(a5)
    4f68:	fec78da3          	sb	a2,-5(a5)
    4f6c:	001e051b          	addiw	a0,t3,1
    4f70:	0ff57993          	zext.b	s3,a0
    4f74:	ff378d23          	sb	s3,-6(a5)
    4f78:	e738f8e3          	bgeu	a7,s3,4de8 <ecvt+0x458>
    4f7c:	ff97c383          	lbu	t2,-7(a5)
    4f80:	fec78d23          	sb	a2,-6(a5)
    4f84:	0013859b          	addiw	a1,t2,1
    4f88:	0ff5f813          	zext.b	a6,a1
    4f8c:	ff078ca3          	sb	a6,-7(a5)
    4f90:	e508fce3          	bgeu	a7,a6,4de8 <ecvt+0x458>
    4f94:	ff87c703          	lbu	a4,-8(a5)
    4f98:	fec78ca3          	sb	a2,-7(a5)
    4f9c:	00170e9b          	addiw	t4,a4,1
    4fa0:	0ffeff13          	zext.b	t5,t4
    4fa4:	ffe78c23          	sb	t5,-8(a5)
    4fa8:	e5e8f0e3          	bgeu	a7,t5,4de8 <ecvt+0x458>
    4fac:	17e1                	addi	a5,a5,-8
    4fae:	bf2d                	j	4ee8 <ecvt+0x558>
    4fb0:	a2a914d3          	flt.d	s1,fs2,fa0
    4fb4:	c8f5                	beqz	s1,50a8 <ecvt+0x718>
    4fb6:	6645                	lui	a2,0x11
    4fb8:	b8063707          	fld	fa4,-1152(a2) # 10b80 <errpat+0x38>
    4fbc:	6745                	lui	a4,0x11
    4fbe:	b9073607          	fld	fa2,-1136(a4) # 10b90 <errpat+0x48>
    4fc2:	12e57053          	fmul.d	ft0,fa0,fa4
    4fc6:	4a81                	li	s5,0
    4fc8:	22c606d3          	fmv.d	fa3,fa2
    4fcc:	a2c01853          	flt.d	a6,ft0,fa2
    4fd0:	08080c63          	beqz	a6,5068 <ecvt+0x6d8>
    4fd4:	22000453          	fmv.d	fs0,ft0
    4fd8:	3afd                	addiw	s5,s5,-1
    4fda:	12e07053          	fmul.d	ft0,ft0,fa4
    4fde:	a2d018d3          	flt.d	a7,ft0,fa3
    4fe2:	08088363          	beqz	a7,5068 <ecvt+0x6d8>
    4fe6:	22000453          	fmv.d	fs0,ft0
    4fea:	3afd                	addiw	s5,s5,-1
    4fec:	12e07053          	fmul.d	ft0,ft0,fa4
    4ff0:	a2d019d3          	flt.d	s3,ft0,fa3
    4ff4:	06098a63          	beqz	s3,5068 <ecvt+0x6d8>
    4ff8:	22000453          	fmv.d	fs0,ft0
    4ffc:	3afd                	addiw	s5,s5,-1
    4ffe:	12e07053          	fmul.d	ft0,ft0,fa4
    5002:	a2d01a53          	flt.d	s4,ft0,fa3
    5006:	060a0163          	beqz	s4,5068 <ecvt+0x6d8>
    500a:	22000453          	fmv.d	fs0,ft0
    500e:	3afd                	addiw	s5,s5,-1
    5010:	12e07053          	fmul.d	ft0,ft0,fa4
    5014:	a2d01e53          	flt.d	t3,ft0,fa3
    5018:	040e0863          	beqz	t3,5068 <ecvt+0x6d8>
    501c:	22000453          	fmv.d	fs0,ft0
    5020:	3afd                	addiw	s5,s5,-1
    5022:	12e07053          	fmul.d	ft0,ft0,fa4
    5026:	a2d01ed3          	flt.d	t4,ft0,fa3
    502a:	020e8f63          	beqz	t4,5068 <ecvt+0x6d8>
    502e:	22000453          	fmv.d	fs0,ft0
    5032:	3afd                	addiw	s5,s5,-1
    5034:	12e07053          	fmul.d	ft0,ft0,fa4
    5038:	a2d01f53          	flt.d	t5,ft0,fa3
    503c:	020f0663          	beqz	t5,5068 <ecvt+0x6d8>
    5040:	22000453          	fmv.d	fs0,ft0
    5044:	3afd                	addiw	s5,s5,-1
    5046:	12e07053          	fmul.d	ft0,ft0,fa4
    504a:	a2d01fd3          	flt.d	t6,ft0,fa3
    504e:	000f8d63          	beqz	t6,5068 <ecvt+0x6d8>
    5052:	22000453          	fmv.d	fs0,ft0
    5056:	3afd                	addiw	s5,s5,-1
    5058:	12e07053          	fmul.d	ft0,ft0,fa4
    505c:	a2d017d3          	flt.d	a5,ft0,fa3
    5060:	fbb5                	bnez	a5,4fd4 <ecvt+0x644>
    5062:	0001                	nop
    5064:	00000013          	nop
    5068:	000416b7          	lui	a3,0x41
    506c:	a402                	fsd	ft0,8(sp)
    506e:	fd068493          	addi	s1,a3,-48 # 40fd0 <CVTBUF>
    5072:	9426                	add	s0,s0,s1
    5074:	01592023          	sw	s5,0(s2)
    5078:	02946063          	bltu	s0,s1,5098 <ecvt+0x708>
    507c:	000419b7          	lui	s3,0x41
    5080:	8a26                	mv	s4,s1
    5082:	02098993          	addi	s3,s3,32 # 41020 <Loop_Num>
    5086:	be35                	j	4bc2 <ecvt+0x232>
    5088:	4305                	li	t1,1
    508a:	22a51553          	fneg.d	fa0,fa0
    508e:	00662023          	sw	t1,0(a2)
    5092:	ba3d                	j	49d0 <ecvt+0x40>
    5094:	29c2                	fld	fs3,16(sp)
    5096:	7b42                	ld	s6,48(sp)
    5098:	00048023          	sb	zero,0(s1)
    509c:	bb81                	j	4dec <ecvt+0x45c>
    509e:	0001                	nop
    50a0:	040487a3          	sb	zero,79(s1)
    50a4:	b3a1                	j	4dec <ecvt+0x45c>
    50a6:	0001                	nop
    50a8:	000415b7          	lui	a1,0x41
    50ac:	4a81                	li	s5,0
    50ae:	fd058493          	addi	s1,a1,-48 # 40fd0 <CVTBUF>
    50b2:	b7c1                	j	5072 <ecvt+0x6e2>
    50b4:	29c2                	fld	fs3,16(sp)
    50b6:	7b42                	ld	s6,48(sp)
    50b8:	bf6d                	j	5072 <ecvt+0x6e2>
    50ba:	00000013          	nop
    50be:	0001                	nop

00000000000050c0 <ecvtbuf>:
    50c0:	7159                	addi	sp,sp,-112
    50c2:	f0a2                	sd	s0,96(sp)
    50c4:	f486                	sd	ra,104(sp)
    50c6:	0005041b          	sext.w	s0,a0
    50ca:	f20007d3          	fmv.d.x	fa5,zero
    50ce:	04e00793          	li	a5,78
    50d2:	e8ca                	sd	s2,80(sp)
    50d4:	eca6                	sd	s1,88(sp)
    50d6:	a2f512d3          	flt.d	t0,fa0,fa5
    50da:	84b6                	mv	s1,a3
    50dc:	00042693          	slti	a3,s0,0
    50e0:	e0d2                	sd	s4,64(sp)
    50e2:	e4ce                	sd	s3,72(sp)
    50e4:	42d0140b          	th.mvnez	s0,zero,a3
    50e8:	00a7a533          	slt	a0,a5,a0
    50ec:	ff515b0b          	th.sdd	s6,s5,(sp),3,4
    50f0:	b422                	fsd	fs0,40(sp)
    50f2:	b026                	fsd	fs1,32(sp)
    50f4:	ac4a                	fsd	fs2,24(sp)
    50f6:	892e                	mv	s2,a1
    50f8:	42a7940b          	th.mvnez	s0,a5,a0
    50fc:	6c029463          	bnez	t0,57c4 <ecvtbuf+0x704>
    5100:	00062023          	sw	zero,0(a2)
    5104:	850a                	mv	a0,sp
    5106:	6500a0ef          	jal	f756 <modf>
    510a:	2e02                	fld	ft8,0(sp)
    510c:	f2000953          	fmv.d.x	fs2,zero
    5110:	22a50453          	fmv.d	fs0,fa0
    5114:	a32e23d3          	feq.d	t2,ft8,fs2
    5118:	5e039063          	bnez	t2,56f8 <ecvtbuf+0x638>
    511c:	67c5                	lui	a5,0x11
    511e:	66c5                	lui	a3,0x11
    5120:	a84e                	fsd	fs3,16(sp)
    5122:	b807b487          	fld	fs1,-1152(a5) # 10b80 <errpat+0x38>
    5126:	b886b987          	fld	fs3,-1144(a3) # 10b88 <errpat+0x40>
    512a:	05048993          	addi	s3,s1,80
    512e:	8ace                	mv	s5,s3
    5130:	4b01                	li	s6,0
    5132:	1a9e7553          	fdiv.d	fa0,ft8,fs1
    5136:	850a                	mv	a0,sp
    5138:	1afd                	addi	s5,s5,-1
    513a:	2b05                	addiw	s6,s6,1
    513c:	8a56                	mv	s4,s5
    513e:	6180a0ef          	jal	f756 <modf>
    5142:	a42a                	fsd	fa0,8(sp)
    5144:	03357553          	fadd.d	fa0,fa0,fs3
    5148:	2102                	fld	ft2,0(sp)
    514a:	8fda                	mv	t6,s6
    514c:	129570d3          	fmul.d	ft1,fa0,fs1
    5150:	a3212353          	feq.d	t1,ft2,fs2
    5154:	c2009553          	fcvt.w.d	a0,ft1,rtz
    5158:	0305029b          	addiw	t0,a0,48
    515c:	0ff2ff13          	zext.b	t5,t0
    5160:	01ea8023          	sb	t5,0(s5)
    5164:	08031f63          	bnez	t1,5202 <ecvtbuf+0x142>
    5168:	1a917553          	fdiv.d	fa0,ft2,fs1
    516c:	850a                	mv	a0,sp
    516e:	2b05                	addiw	s6,s6,1
    5170:	5e60a0ef          	jal	f756 <modf>
    5174:	033571d3          	fadd.d	ft3,fa0,fs3
    5178:	2282                	fld	ft5,0(sp)
    517a:	a42a                	fsd	fa0,8(sp)
    517c:	1291f253          	fmul.d	ft4,ft3,fs1
    5180:	a322a653          	feq.d	a2,ft5,fs2
    5184:	8fda                	mv	t6,s6
    5186:	c20213d3          	fcvt.w.d	t2,ft4,rtz
    518a:	0303859b          	addiw	a1,t2,48
    518e:	0ff5ff13          	zext.b	t5,a1
    5192:	09fadf0b          	th.sbib	t5,(s5),-1,0
    5196:	e635                	bnez	a2,5202 <ecvtbuf+0x142>
    5198:	1a92f553          	fdiv.d	fa0,ft5,fs1
    519c:	850a                	mv	a0,sp
    519e:	2b05                	addiw	s6,s6,1
    51a0:	ffea0a93          	addi	s5,s4,-2
    51a4:	5b20a0ef          	jal	f756 <modf>
    51a8:	03357353          	fadd.d	ft6,fa0,fs3
    51ac:	2582                	fld	fa1,0(sp)
    51ae:	a42a                	fsd	fa0,8(sp)
    51b0:	129373d3          	fmul.d	ft7,ft6,fs1
    51b4:	a325a8d3          	feq.d	a7,fa1,fs2
    51b8:	8fda                	mv	t6,s6
    51ba:	c2039753          	fcvt.w.d	a4,ft7,rtz
    51be:	0307081b          	addiw	a6,a4,48
    51c2:	0ff87f13          	zext.b	t5,a6
    51c6:	ffea0f23          	sb	t5,-2(s4)
    51ca:	02089c63          	bnez	a7,5202 <ecvtbuf+0x142>
    51ce:	1a95f553          	fdiv.d	fa0,fa1,fs1
    51d2:	850a                	mv	a0,sp
    51d4:	2b05                	addiw	s6,s6,1
    51d6:	ffda0a93          	addi	s5,s4,-3
    51da:	57c0a0ef          	jal	f756 <modf>
    51de:	03357853          	fadd.d	fa6,fa0,fs3
    51e2:	2e02                	fld	ft8,0(sp)
    51e4:	a42a                	fsd	fa0,8(sp)
    51e6:	129878d3          	fmul.d	fa7,fa6,fs1
    51ea:	a32e27d3          	feq.d	a5,ft8,fs2
    51ee:	8fda                	mv	t6,s6
    51f0:	c2089e53          	fcvt.w.d	t3,fa7,rtz
    51f4:	030e0e9b          	addiw	t4,t3,48
    51f8:	0ffeff13          	zext.b	t5,t4
    51fc:	ffea0ea3          	sb	t5,-3(s4)
    5200:	db8d                	beqz	a5,5132 <ecvtbuf+0x72>
    5202:	5d3afe63          	bgeu	s5,s3,57de <ecvtbuf+0x71e>
    5206:	41548b33          	sub	s6,s1,s5
    520a:	04fb0a13          	addi	s4,s6,79
    520e:	007a7293          	andi	t0,s4,7
    5212:	050b0693          	addi	a3,s6,80
    5216:	4701                	li	a4,0
    5218:	0c028763          	beqz	t0,52e6 <ecvtbuf+0x226>
    521c:	01e48023          	sb	t5,0(s1)
    5220:	4705                	li	a4,1
    5222:	80eacf0b          	th.lrbu	t5,s5,a4,0
    5226:	0ce28063          	beq	t0,a4,52e6 <ecvtbuf+0x226>
    522a:	4309                	li	t1,2
    522c:	04628763          	beq	t0,t1,527a <ecvtbuf+0x1ba>
    5230:	450d                	li	a0,3
    5232:	02a28f63          	beq	t0,a0,5270 <ecvtbuf+0x1b0>
    5236:	4391                	li	t2,4
    5238:	02728763          	beq	t0,t2,5266 <ecvtbuf+0x1a6>
    523c:	4595                	li	a1,5
    523e:	00b28f63          	beq	t0,a1,525c <ecvtbuf+0x19c>
    5242:	4619                	li	a2,6
    5244:	00c28763          	beq	t0,a2,5252 <ecvtbuf+0x192>
    5248:	00e4df0b          	th.srb	t5,s1,a4,0
    524c:	806acf0b          	th.lrbu	t5,s5,t1,0
    5250:	871a                	mv	a4,t1
    5252:	00e4df0b          	th.srb	t5,s1,a4,0
    5256:	0705                	addi	a4,a4,1
    5258:	80eacf0b          	th.lrbu	t5,s5,a4,0
    525c:	00e4df0b          	th.srb	t5,s1,a4,0
    5260:	0705                	addi	a4,a4,1
    5262:	80eacf0b          	th.lrbu	t5,s5,a4,0
    5266:	00e4df0b          	th.srb	t5,s1,a4,0
    526a:	0705                	addi	a4,a4,1
    526c:	80eacf0b          	th.lrbu	t5,s5,a4,0
    5270:	00e4df0b          	th.srb	t5,s1,a4,0
    5274:	0705                	addi	a4,a4,1
    5276:	80eacf0b          	th.lrbu	t5,s5,a4,0
    527a:	00e4df0b          	th.srb	t5,s1,a4,0
    527e:	0705                	addi	a4,a4,1
    5280:	80eacf0b          	th.lrbu	t5,s5,a4,0
    5284:	00170813          	addi	a6,a4,1
    5288:	00e4df0b          	th.srb	t5,s1,a4,0
    528c:	06d80363          	beq	a6,a3,52f2 <ecvtbuf+0x232>
    5290:	810ac28b          	th.lrbu	t0,s5,a6,0
    5294:	00270313          	addi	t1,a4,2
    5298:	00370893          	addi	a7,a4,3
    529c:	0104d28b          	th.srb	t0,s1,a6,0
    52a0:	806ac80b          	th.lrbu	a6,s5,t1,0
    52a4:	00470a13          	addi	s4,a4,4
    52a8:	00570e93          	addi	t4,a4,5
    52ac:	0064d80b          	th.srb	a6,s1,t1,0
    52b0:	811acb0b          	th.lrbu	s6,s5,a7,0
    52b4:	00670513          	addi	a0,a4,6
    52b8:	00770593          	addi	a1,a4,7
    52bc:	0114db0b          	th.srb	s6,s1,a7,0
    52c0:	814ace0b          	th.lrbu	t3,s5,s4,0
    52c4:	0721                	addi	a4,a4,8
    52c6:	0144de0b          	th.srb	t3,s1,s4,0
    52ca:	81dacf0b          	th.lrbu	t5,s5,t4,0
    52ce:	01d4df0b          	th.srb	t5,s1,t4,0
    52d2:	80aac38b          	th.lrbu	t2,s5,a0,0
    52d6:	00a4d38b          	th.srb	t2,s1,a0,0
    52da:	80bac60b          	th.lrbu	a2,s5,a1,0
    52de:	00b4d60b          	th.srb	a2,s1,a1,0
    52e2:	80eacf0b          	th.lrbu	t5,s5,a4,0
    52e6:	00e4df0b          	th.srb	t5,s1,a4,0
    52ea:	00170813          	addi	a6,a4,1
    52ee:	fad811e3          	bne	a6,a3,5290 <ecvtbuf+0x1d0>
    52f2:	9426                	add	s0,s0,s1
    52f4:	01f92023          	sw	t6,0(s2)
    52f8:	4c946c63          	bltu	s0,s1,57d0 <ecvtbuf+0x710>
    52fc:	00d48a33          	add	s4,s1,a3
    5300:	29c2                	fld	fs3,16(sp)
    5302:	11446763          	bltu	s0,s4,5410 <ecvtbuf+0x350>
    5306:	41498ab3          	sub	s5,s3,s4
    530a:	68c5                	lui	a7,0x11
    530c:	003afb13          	andi	s6,s5,3
    5310:	b808b907          	fld	fs2,-1152(a7) # 10b80 <errpat+0x38>
    5314:	060b0a63          	beqz	s6,5388 <ecvtbuf+0x2c8>
    5318:	0f3a7c63          	bgeu	s4,s3,5410 <ecvtbuf+0x350>
    531c:	13247553          	fmul.d	fa0,fs0,fs2
    5320:	0028                	addi	a0,sp,8
    5322:	4340a0ef          	jal	f756 <modf>
    5326:	2ea2                	fld	ft9,8(sp)
    5328:	22a50453          	fmv.d	fs0,fa0
    532c:	c20e9e53          	fcvt.w.d	t3,ft9,rtz
    5330:	030e0e9b          	addiw	t4,t3,48
    5334:	181a5e8b          	th.sbia	t4,(s4),1,0
    5338:	0d446c63          	bltu	s0,s4,5410 <ecvtbuf+0x350>
    533c:	4f05                	li	t5,1
    533e:	05eb0563          	beq	s6,t5,5388 <ecvtbuf+0x2c8>
    5342:	4f89                	li	t6,2
    5344:	03fb0263          	beq	s6,t6,5368 <ecvtbuf+0x2a8>
    5348:	13257553          	fmul.d	fa0,fa0,fs2
    534c:	0028                	addi	a0,sp,8
    534e:	4080a0ef          	jal	f756 <modf>
    5352:	2f22                	fld	ft10,8(sp)
    5354:	22a50453          	fmv.d	fs0,fa0
    5358:	c20f17d3          	fcvt.w.d	a5,ft10,rtz
    535c:	0307869b          	addiw	a3,a5,48
    5360:	181a568b          	th.sbia	a3,(s4),1,0
    5364:	0b446663          	bltu	s0,s4,5410 <ecvtbuf+0x350>
    5368:	13247553          	fmul.d	fa0,fs0,fs2
    536c:	0028                	addi	a0,sp,8
    536e:	3e80a0ef          	jal	f756 <modf>
    5372:	2fa2                	fld	ft11,8(sp)
    5374:	22a50453          	fmv.d	fs0,fa0
    5378:	c20f92d3          	fcvt.w.d	t0,ft11,rtz
    537c:	0302831b          	addiw	t1,t0,48
    5380:	181a530b          	th.sbia	t1,(s4),1,0
    5384:	09446663          	bltu	s0,s4,5410 <ecvtbuf+0x350>
    5388:	093a7463          	bgeu	s4,s3,5410 <ecvtbuf+0x350>
    538c:	13247553          	fmul.d	fa0,fs0,fs2
    5390:	0028                	addi	a0,sp,8
    5392:	3c40a0ef          	jal	f756 <modf>
    5396:	27a2                	fld	fa5,8(sp)
    5398:	8552                	mv	a0,s4
    539a:	c20793d3          	fcvt.w.d	t2,fa5,rtz
    539e:	0303859b          	addiw	a1,t2,48
    53a2:	1815558b          	th.sbia	a1,(a0),1,0
    53a6:	06a46563          	bltu	s0,a0,5410 <ecvtbuf+0x350>
    53aa:	13257553          	fmul.d	fa0,fa0,fs2
    53ae:	0028                	addi	a0,sp,8
    53b0:	3a60a0ef          	jal	f756 <modf>
    53b4:	2722                	fld	fa4,8(sp)
    53b6:	002a0613          	addi	a2,s4,2
    53ba:	c2071753          	fcvt.w.d	a4,fa4,rtz
    53be:	0307081b          	addiw	a6,a4,48
    53c2:	010a00a3          	sb	a6,1(s4)
    53c6:	04c46563          	bltu	s0,a2,5410 <ecvtbuf+0x350>
    53ca:	13257553          	fmul.d	fa0,fa0,fs2
    53ce:	0028                	addi	a0,sp,8
    53d0:	3860a0ef          	jal	f756 <modf>
    53d4:	2622                	fld	fa2,8(sp)
    53d6:	003a0893          	addi	a7,s4,3
    53da:	c2061ad3          	fcvt.w.d	s5,fa2,rtz
    53de:	030a8b1b          	addiw	s6,s5,48
    53e2:	016a0123          	sb	s6,2(s4)
    53e6:	03146563          	bltu	s0,a7,5410 <ecvtbuf+0x350>
    53ea:	13257553          	fmul.d	fa0,fa0,fs2
    53ee:	0028                	addi	a0,sp,8
    53f0:	0a11                	addi	s4,s4,4
    53f2:	3640a0ef          	jal	f756 <modf>
    53f6:	26a2                	fld	fa3,8(sp)
    53f8:	22a50453          	fmv.d	fs0,fa0
    53fc:	c2069e53          	fcvt.w.d	t3,fa3,rtz
    5400:	030e0e9b          	addiw	t4,t3,48
    5404:	ffda0fa3          	sb	t4,-1(s4)
    5408:	f94470e3          	bgeu	s0,s4,5388 <ecvtbuf+0x2c8>
    540c:	00000013          	nop
    5410:	3d347463          	bgeu	s0,s3,57d8 <ecvtbuf+0x718>
    5414:	00044983          	lbu	s3,0(s0)
    5418:	03900693          	li	a3,57
    541c:	00598f1b          	addiw	t5,s3,5
    5420:	0fff7f93          	zext.b	t6,t5
    5424:	11f6f263          	bgeu	a3,t6,5528 <ecvtbuf+0x468>
    5428:	40940533          	sub	a0,s0,s1
    542c:	01f40023          	sb	t6,0(s0)
    5430:	00757393          	andi	t2,a0,7
    5434:	87a2                	mv	a5,s0
    5436:	03000293          	li	t0,48
    543a:	8336                	mv	t1,a3
    543c:	1e038a63          	beqz	t2,5630 <ecvtbuf+0x570>
    5440:	1084e463          	bltu	s1,s0,5548 <ecvtbuf+0x488>
    5444:	03100293          	li	t0,49
    5448:	00578023          	sb	t0,0(a5)
    544c:	00092303          	lw	t1,0(s2)
    5450:	03900713          	li	a4,57
    5454:	0013059b          	addiw	a1,t1,1
    5458:	00b92023          	sw	a1,0(s2)
    545c:	0007c603          	lbu	a2,0(a5)
    5460:	0cc77463          	bgeu	a4,a2,5528 <ecvtbuf+0x468>
    5464:	00578023          	sb	t0,0(a5)
    5468:	00092803          	lw	a6,0(s2)
    546c:	0018089b          	addiw	a7,a6,1
    5470:	01192023          	sw	a7,0(s2)
    5474:	0007ca83          	lbu	s5,0(a5)
    5478:	0b577863          	bgeu	a4,s5,5528 <ecvtbuf+0x468>
    547c:	00578023          	sb	t0,0(a5)
    5480:	00092b03          	lw	s6,0(s2)
    5484:	001b0a1b          	addiw	s4,s6,1
    5488:	01492023          	sw	s4,0(s2)
    548c:	0007ce03          	lbu	t3,0(a5)
    5490:	09c77c63          	bgeu	a4,t3,5528 <ecvtbuf+0x468>
    5494:	00578023          	sb	t0,0(a5)
    5498:	00092e83          	lw	t4,0(s2)
    549c:	001e899b          	addiw	s3,t4,1
    54a0:	01392023          	sw	s3,0(s2)
    54a4:	0007cf03          	lbu	t5,0(a5)
    54a8:	09e77063          	bgeu	a4,t5,5528 <ecvtbuf+0x468>
    54ac:	00578023          	sb	t0,0(a5)
    54b0:	00092f83          	lw	t6,0(s2)
    54b4:	001f869b          	addiw	a3,t6,1
    54b8:	00d92023          	sw	a3,0(s2)
    54bc:	0007c503          	lbu	a0,0(a5)
    54c0:	06a77463          	bgeu	a4,a0,5528 <ecvtbuf+0x468>
    54c4:	00578023          	sb	t0,0(a5)
    54c8:	00092383          	lw	t2,0(s2)
    54cc:	0013831b          	addiw	t1,t2,1
    54d0:	00692023          	sw	t1,0(s2)
    54d4:	0007c583          	lbu	a1,0(a5)
    54d8:	04b77863          	bgeu	a4,a1,5528 <ecvtbuf+0x468>
    54dc:	00578023          	sb	t0,0(a5)
    54e0:	00092603          	lw	a2,0(s2)
    54e4:	0016081b          	addiw	a6,a2,1
    54e8:	01092023          	sw	a6,0(s2)
    54ec:	0007c883          	lbu	a7,0(a5)
    54f0:	03177c63          	bgeu	a4,a7,5528 <ecvtbuf+0x468>
    54f4:	00578023          	sb	t0,0(a5)
    54f8:	00092a83          	lw	s5,0(s2)
    54fc:	001a8b1b          	addiw	s6,s5,1
    5500:	01692023          	sw	s6,0(s2)
    5504:	0007ca03          	lbu	s4,0(a5)
    5508:	03477063          	bgeu	a4,s4,5528 <ecvtbuf+0x468>
    550c:	00578023          	sb	t0,0(a5)
    5510:	00092e03          	lw	t3,0(s2)
    5514:	001e0e9b          	addiw	t4,t3,1
    5518:	01d92023          	sw	t4,0(s2)
    551c:	0007c983          	lbu	s3,0(a5)
    5520:	f53762e3          	bltu	a4,s3,5464 <ecvtbuf+0x3a4>
    5524:	00000013          	nop
    5528:	00040023          	sb	zero,0(s0)
    552c:	7406                	ld	s0,96(sp)
    552e:	70a6                	ld	ra,104(sp)
    5530:	6a06                	ld	s4,64(sp)
    5532:	69a6                	ld	s3,72(sp)
    5534:	ff514b0b          	th.ldd	s6,s5,(sp),3,4
    5538:	3422                	fld	fs0,40(sp)
    553a:	3482                	fld	fs1,32(sp)
    553c:	2962                	fld	fs2,24(sp)
    553e:	8526                	mv	a0,s1
    5540:	6946                	ld	s2,80(sp)
    5542:	64e6                	ld	s1,88(sp)
    5544:	6165                	addi	sp,sp,112
    5546:	8082                	ret
    5548:	85a2                	mv	a1,s0
    554a:	19f5d28b          	th.sbia	t0,(a1),-1,0
    554e:	fff44783          	lbu	a5,-1(s0)
    5552:	0017861b          	addiw	a2,a5,1
    5556:	0ff67713          	zext.b	a4,a2
    555a:	fee40fa3          	sb	a4,-1(s0)
    555e:	fce6f5e3          	bgeu	a3,a4,5528 <ecvtbuf+0x468>
    5562:	4805                	li	a6,1
    5564:	87ae                	mv	a5,a1
    5566:	0d038563          	beq	t2,a6,5630 <ecvtbuf+0x570>
    556a:	4889                	li	a7,2
    556c:	0b138263          	beq	t2,a7,5610 <ecvtbuf+0x550>
    5570:	4a8d                	li	s5,3
    5572:	09538163          	beq	t2,s5,55f4 <ecvtbuf+0x534>
    5576:	4b11                	li	s6,4
    5578:	07638063          	beq	t2,s6,55d8 <ecvtbuf+0x518>
    557c:	4a15                	li	s4,5
    557e:	03438f63          	beq	t2,s4,55bc <ecvtbuf+0x4fc>
    5582:	4e19                	li	t3,6
    5584:	01c38e63          	beq	t2,t3,55a0 <ecvtbuf+0x4e0>
    5588:	19f7d28b          	th.sbia	t0,(a5),-1,0
    558c:	fff5ce83          	lbu	t4,-1(a1)
    5590:	001e899b          	addiw	s3,t4,1
    5594:	0ff9ff13          	zext.b	t5,s3
    5598:	ffe58fa3          	sb	t5,-1(a1)
    559c:	f9e6f6e3          	bgeu	a3,t5,5528 <ecvtbuf+0x468>
    55a0:	8fbe                	mv	t6,a5
    55a2:	19ffd28b          	th.sbia	t0,(t6),-1,0
    55a6:	fff7c683          	lbu	a3,-1(a5)
    55aa:	0016851b          	addiw	a0,a3,1
    55ae:	0ff57393          	zext.b	t2,a0
    55b2:	fe778fa3          	sb	t2,-1(a5)
    55b6:	f67379e3          	bgeu	t1,t2,5528 <ecvtbuf+0x468>
    55ba:	87fe                	mv	a5,t6
    55bc:	85be                	mv	a1,a5
    55be:	19f5d28b          	th.sbia	t0,(a1),-1,0
    55c2:	fff7c603          	lbu	a2,-1(a5)
    55c6:	0016071b          	addiw	a4,a2,1
    55ca:	0ff77813          	zext.b	a6,a4
    55ce:	ff078fa3          	sb	a6,-1(a5)
    55d2:	f5037be3          	bgeu	t1,a6,5528 <ecvtbuf+0x468>
    55d6:	87ae                	mv	a5,a1
    55d8:	88be                	mv	a7,a5
    55da:	19f8d28b          	th.sbia	t0,(a7),-1,0
    55de:	fff7ca83          	lbu	s5,-1(a5)
    55e2:	001a8b1b          	addiw	s6,s5,1
    55e6:	0ffb7a13          	zext.b	s4,s6
    55ea:	ff478fa3          	sb	s4,-1(a5)
    55ee:	f3437de3          	bgeu	t1,s4,5528 <ecvtbuf+0x468>
    55f2:	87c6                	mv	a5,a7
    55f4:	8e3e                	mv	t3,a5
    55f6:	19fe528b          	th.sbia	t0,(t3),-1,0
    55fa:	fff7ce83          	lbu	t4,-1(a5)
    55fe:	001e899b          	addiw	s3,t4,1
    5602:	0ff9ff13          	zext.b	t5,s3
    5606:	ffe78fa3          	sb	t5,-1(a5)
    560a:	f1e37fe3          	bgeu	t1,t5,5528 <ecvtbuf+0x468>
    560e:	87f2                	mv	a5,t3
    5610:	8fbe                	mv	t6,a5
    5612:	19ffd28b          	th.sbia	t0,(t6),-1,0
    5616:	fff7c683          	lbu	a3,-1(a5)
    561a:	0016851b          	addiw	a0,a3,1
    561e:	0ff57393          	zext.b	t2,a0
    5622:	fe778fa3          	sb	t2,-1(a5)
    5626:	87fe                	mv	a5,t6
    5628:	f07370e3          	bgeu	t1,t2,5528 <ecvtbuf+0x468>
    562c:	00000013          	nop
    5630:	e0f4fae3          	bgeu	s1,a5,5444 <ecvtbuf+0x384>
    5634:	fff7c703          	lbu	a4,-1(a5)
    5638:	00578023          	sb	t0,0(a5)
    563c:	00170f1b          	addiw	t5,a4,1
    5640:	0fff7f93          	zext.b	t6,t5
    5644:	fff78fa3          	sb	t6,-1(a5)
    5648:	eff370e3          	bgeu	t1,t6,5528 <ecvtbuf+0x468>
    564c:	ffe7c683          	lbu	a3,-2(a5)
    5650:	fe578fa3          	sb	t0,-1(a5)
    5654:	0016851b          	addiw	a0,a3,1
    5658:	0ff57393          	zext.b	t2,a0
    565c:	fe778f23          	sb	t2,-2(a5)
    5660:	ec7374e3          	bgeu	t1,t2,5528 <ecvtbuf+0x468>
    5664:	ffd7c583          	lbu	a1,-3(a5)
    5668:	fe578f23          	sb	t0,-2(a5)
    566c:	0015861b          	addiw	a2,a1,1
    5670:	0ff67813          	zext.b	a6,a2
    5674:	ff078ea3          	sb	a6,-3(a5)
    5678:	eb0378e3          	bgeu	t1,a6,5528 <ecvtbuf+0x468>
    567c:	ffc7c883          	lbu	a7,-4(a5)
    5680:	fe578ea3          	sb	t0,-3(a5)
    5684:	00188a9b          	addiw	s5,a7,1
    5688:	0ffafb13          	zext.b	s6,s5
    568c:	ff678e23          	sb	s6,-4(a5)
    5690:	e9637ce3          	bgeu	t1,s6,5528 <ecvtbuf+0x468>
    5694:	ffb7ca03          	lbu	s4,-5(a5)
    5698:	fe578e23          	sb	t0,-4(a5)
    569c:	001a0e1b          	addiw	t3,s4,1
    56a0:	0ffe7e93          	zext.b	t4,t3
    56a4:	ffd78da3          	sb	t4,-5(a5)
    56a8:	e9d370e3          	bgeu	t1,t4,5528 <ecvtbuf+0x468>
    56ac:	ffa7c983          	lbu	s3,-6(a5)
    56b0:	fe578da3          	sb	t0,-5(a5)
    56b4:	0019871b          	addiw	a4,s3,1
    56b8:	0ff77f13          	zext.b	t5,a4
    56bc:	ffe78d23          	sb	t5,-6(a5)
    56c0:	e7e374e3          	bgeu	t1,t5,5528 <ecvtbuf+0x468>
    56c4:	ff97cf83          	lbu	t6,-7(a5)
    56c8:	fe578d23          	sb	t0,-6(a5)
    56cc:	001f869b          	addiw	a3,t6,1
    56d0:	0ff6f513          	zext.b	a0,a3
    56d4:	fea78ca3          	sb	a0,-7(a5)
    56d8:	e4a378e3          	bgeu	t1,a0,5528 <ecvtbuf+0x468>
    56dc:	ff87c383          	lbu	t2,-8(a5)
    56e0:	fe578ca3          	sb	t0,-7(a5)
    56e4:	0013859b          	addiw	a1,t2,1
    56e8:	0ff5f613          	zext.b	a2,a1
    56ec:	fec78c23          	sb	a2,-8(a5)
    56f0:	e2c37ce3          	bgeu	t1,a2,5528 <ecvtbuf+0x468>
    56f4:	17e1                	addi	a5,a5,-8
    56f6:	bf2d                	j	5630 <ecvtbuf+0x570>
    56f8:	a2a915d3          	flt.d	a1,fs2,fa0
    56fc:	4b01                	li	s6,0
    56fe:	c9d5                	beqz	a1,57b2 <ecvtbuf+0x6f2>
    5700:	6645                	lui	a2,0x11
    5702:	b8063707          	fld	fa4,-1152(a2) # 10b80 <errpat+0x38>
    5706:	6745                	lui	a4,0x11
    5708:	b9073607          	fld	fa2,-1136(a4) # 10b90 <errpat+0x48>
    570c:	12e57053          	fmul.d	ft0,fa0,fa4
    5710:	4b01                	li	s6,0
    5712:	22c606d3          	fmv.d	fa3,fa2
    5716:	a2c01853          	flt.d	a6,ft0,fa2
    571a:	08080b63          	beqz	a6,57b0 <ecvtbuf+0x6f0>
    571e:	22000453          	fmv.d	fs0,ft0
    5722:	3b7d                	addiw	s6,s6,-1
    5724:	12e07053          	fmul.d	ft0,ft0,fa4
    5728:	a2d018d3          	flt.d	a7,ft0,fa3
    572c:	08088263          	beqz	a7,57b0 <ecvtbuf+0x6f0>
    5730:	22000453          	fmv.d	fs0,ft0
    5734:	3b7d                	addiw	s6,s6,-1
    5736:	12e07053          	fmul.d	ft0,ft0,fa4
    573a:	a2d019d3          	flt.d	s3,ft0,fa3
    573e:	06098963          	beqz	s3,57b0 <ecvtbuf+0x6f0>
    5742:	22000453          	fmv.d	fs0,ft0
    5746:	3b7d                	addiw	s6,s6,-1
    5748:	12e07053          	fmul.d	ft0,ft0,fa4
    574c:	a2d01a53          	flt.d	s4,ft0,fa3
    5750:	060a0063          	beqz	s4,57b0 <ecvtbuf+0x6f0>
    5754:	22000453          	fmv.d	fs0,ft0
    5758:	3b7d                	addiw	s6,s6,-1
    575a:	12e07053          	fmul.d	ft0,ft0,fa4
    575e:	a2d01ad3          	flt.d	s5,ft0,fa3
    5762:	040a8763          	beqz	s5,57b0 <ecvtbuf+0x6f0>
    5766:	22000453          	fmv.d	fs0,ft0
    576a:	3b7d                	addiw	s6,s6,-1
    576c:	12e07053          	fmul.d	ft0,ft0,fa4
    5770:	a2d01e53          	flt.d	t3,ft0,fa3
    5774:	020e0e63          	beqz	t3,57b0 <ecvtbuf+0x6f0>
    5778:	22000453          	fmv.d	fs0,ft0
    577c:	3b7d                	addiw	s6,s6,-1
    577e:	12e07053          	fmul.d	ft0,ft0,fa4
    5782:	a2d01ed3          	flt.d	t4,ft0,fa3
    5786:	020e8563          	beqz	t4,57b0 <ecvtbuf+0x6f0>
    578a:	22000453          	fmv.d	fs0,ft0
    578e:	3b7d                	addiw	s6,s6,-1
    5790:	12e07053          	fmul.d	ft0,ft0,fa4
    5794:	a2d01f53          	flt.d	t5,ft0,fa3
    5798:	000f0c63          	beqz	t5,57b0 <ecvtbuf+0x6f0>
    579c:	22000453          	fmv.d	fs0,ft0
    57a0:	3b7d                	addiw	s6,s6,-1
    57a2:	12e07053          	fmul.d	ft0,ft0,fa4
    57a6:	a2d01fd3          	flt.d	t6,ft0,fa3
    57aa:	f60f9ae3          	bnez	t6,571e <ecvtbuf+0x65e>
    57ae:	0001                	nop
    57b0:	a402                	fsd	ft0,8(sp)
    57b2:	9426                	add	s0,s0,s1
    57b4:	01692023          	sw	s6,0(s2)
    57b8:	00946d63          	bltu	s0,s1,57d2 <ecvtbuf+0x712>
    57bc:	8a26                	mv	s4,s1
    57be:	05048993          	addi	s3,s1,80
    57c2:	b691                	j	5306 <ecvtbuf+0x246>
    57c4:	4305                	li	t1,1
    57c6:	22a51553          	fneg.d	fa0,fa0
    57ca:	00662023          	sw	t1,0(a2)
    57ce:	ba1d                	j	5104 <ecvtbuf+0x44>
    57d0:	29c2                	fld	fs3,16(sp)
    57d2:	00048023          	sb	zero,0(s1)
    57d6:	bb99                	j	552c <ecvtbuf+0x46c>
    57d8:	040487a3          	sb	zero,79(s1)
    57dc:	bb81                	j	552c <ecvtbuf+0x46c>
    57de:	29c2                	fld	fs3,16(sp)
    57e0:	bfc9                	j	57b2 <ecvtbuf+0x6f2>
    57e2:	0001                	nop
    57e4:	00000013          	nop
    57e8:	00000013          	nop
    57ec:	00000013          	nop

00000000000057f0 <fcvt>:
    57f0:	7159                	addi	sp,sp,-112
    57f2:	f20007d3          	fmv.d.x	fa5,zero
    57f6:	e4ce                	sd	s3,72(sp)
    57f8:	e8ca                	sd	s2,80(sp)
    57fa:	0005091b          	sext.w	s2,a0
    57fe:	04e00793          	li	a5,78
    5802:	00092693          	slti	a3,s2,0
    5806:	a2f512d3          	flt.d	t0,fa0,fa5
    580a:	eca6                	sd	s1,88(sp)
    580c:	f0a2                	sd	s0,96(sp)
    580e:	fc56                	sd	s5,56(sp)
    5810:	e0d2                	sd	s4,64(sp)
    5812:	42d0190b          	th.mvnez	s2,zero,a3
    5816:	00a7a533          	slt	a0,a5,a0
    581a:	b422                	fsd	fs0,40(sp)
    581c:	b026                	fsd	fs1,32(sp)
    581e:	ac4a                	fsd	fs2,24(sp)
    5820:	f486                	sd	ra,104(sp)
    5822:	84ae                	mv	s1,a1
    5824:	42a7990b          	th.mvnez	s2,a5,a0
    5828:	4a029263          	bnez	t0,5ccc <fcvt+0x4dc>
    582c:	00062023          	sw	zero,0(a2)
    5830:	850a                	mv	a0,sp
    5832:	725090ef          	jal	f756 <modf>
    5836:	2e02                	fld	ft8,0(sp)
    5838:	f2000953          	fmv.d.x	fs2,zero
    583c:	22a50453          	fmv.d	fs0,fa0
    5840:	a32e23d3          	feq.d	t2,ft8,fs2
    5844:	3a039a63          	bnez	t2,5bf8 <fcvt+0x408>
    5848:	00041337          	lui	t1,0x41
    584c:	63c5                	lui	t2,0x11
    584e:	65c5                	lui	a1,0x11
    5850:	a84e                	fsd	fs3,16(sp)
    5852:	fd030413          	addi	s0,t1,-48 # 40fd0 <CVTBUF>
    5856:	b803b487          	fld	fs1,-1152(t2) # 10b80 <errpat+0x38>
    585a:	b885b987          	fld	fs3,-1144(a1) # 10b88 <errpat+0x40>
    585e:	05040993          	addi	s3,s0,80
    5862:	f85a                	sd	s6,48(sp)
    5864:	4a81                	li	s5,0
    5866:	8b4e                	mv	s6,s3
    5868:	1a9e7553          	fdiv.d	fa0,ft8,fs1
    586c:	850a                	mv	a0,sp
    586e:	1b7d                	addi	s6,s6,-1
    5870:	2a85                	addiw	s5,s5,1
    5872:	8a5a                	mv	s4,s6
    5874:	6e3090ef          	jal	f756 <modf>
    5878:	a42a                	fsd	fa0,8(sp)
    587a:	03357553          	fadd.d	fa0,fa0,fs3
    587e:	2102                	fld	ft2,0(sp)
    5880:	8356                	mv	t1,s5
    5882:	129570d3          	fmul.d	ft1,fa0,fs1
    5886:	a3212853          	feq.d	a6,ft2,fs2
    588a:	c2009653          	fcvt.w.d	a2,ft1,rtz
    588e:	0306071b          	addiw	a4,a2,48
    5892:	0ff77293          	zext.b	t0,a4
    5896:	005b0023          	sb	t0,0(s6)
    589a:	0a081063          	bnez	a6,593a <fcvt+0x14a>
    589e:	1a917553          	fdiv.d	fa0,ft2,fs1
    58a2:	850a                	mv	a0,sp
    58a4:	2a85                	addiw	s5,s5,1
    58a6:	6b1090ef          	jal	f756 <modf>
    58aa:	033571d3          	fadd.d	ft3,fa0,fs3
    58ae:	2282                	fld	ft5,0(sp)
    58b0:	a42a                	fsd	fa0,8(sp)
    58b2:	1291f253          	fmul.d	ft4,ft3,fs1
    58b6:	a322aed3          	feq.d	t4,ft5,fs2
    58ba:	8356                	mv	t1,s5
    58bc:	c20218d3          	fcvt.w.d	a7,ft4,rtz
    58c0:	03088e1b          	addiw	t3,a7,48
    58c4:	0ffe7293          	zext.b	t0,t3
    58c8:	09fb528b          	th.sbib	t0,(s6),-1,0
    58cc:	060e9763          	bnez	t4,593a <fcvt+0x14a>
    58d0:	1a92f553          	fdiv.d	fa0,ft5,fs1
    58d4:	850a                	mv	a0,sp
    58d6:	2a85                	addiw	s5,s5,1
    58d8:	ffea0b13          	addi	s6,s4,-2
    58dc:	67b090ef          	jal	f756 <modf>
    58e0:	03357353          	fadd.d	ft6,fa0,fs3
    58e4:	2582                	fld	fa1,0(sp)
    58e6:	a42a                	fsd	fa0,8(sp)
    58e8:	129373d3          	fmul.d	ft7,ft6,fs1
    58ec:	a325a6d3          	feq.d	a3,fa1,fs2
    58f0:	8356                	mv	t1,s5
    58f2:	c2039f53          	fcvt.w.d	t5,ft7,rtz
    58f6:	030f0f9b          	addiw	t6,t5,48
    58fa:	0ffff293          	zext.b	t0,t6
    58fe:	fe5a0f23          	sb	t0,-2(s4)
    5902:	ee85                	bnez	a3,593a <fcvt+0x14a>
    5904:	1a95f553          	fdiv.d	fa0,fa1,fs1
    5908:	850a                	mv	a0,sp
    590a:	2a85                	addiw	s5,s5,1
    590c:	ffda0b13          	addi	s6,s4,-3
    5910:	647090ef          	jal	f756 <modf>
    5914:	03357853          	fadd.d	fa6,fa0,fs3
    5918:	2e02                	fld	ft8,0(sp)
    591a:	a42a                	fsd	fa0,8(sp)
    591c:	129878d3          	fmul.d	fa7,fa6,fs1
    5920:	a32e23d3          	feq.d	t2,ft8,fs2
    5924:	8356                	mv	t1,s5
    5926:	c20897d3          	fcvt.w.d	a5,fa7,rtz
    592a:	0307851b          	addiw	a0,a5,48
    592e:	0ff57293          	zext.b	t0,a0
    5932:	fe5a0ea3          	sb	t0,-3(s4)
    5936:	f20389e3          	beqz	t2,5868 <fcvt+0x78>
    593a:	875a                	mv	a4,s6
    593c:	86a2                	mv	a3,s0
    593e:	3b3b7e63          	bgeu	s6,s3,5cfa <fcvt+0x50a>
    5942:	fffb4593          	not	a1,s6
    5946:	00b98a33          	add	s4,s3,a1
    594a:	007a7613          	andi	a2,s4,7
    594e:	c65d                	beqz	a2,59fc <fcvt+0x20c>
    5950:	1816d28b          	th.sbia	t0,(a3),1,0
    5954:	4805                	li	a6,1
    5956:	8817428b          	th.lbuib	t0,(a4),1,0
    595a:	0b060163          	beq	a2,a6,59fc <fcvt+0x20c>
    595e:	4889                	li	a7,2
    5960:	05160563          	beq	a2,a7,59aa <fcvt+0x1ba>
    5964:	4e0d                	li	t3,3
    5966:	03c60e63          	beq	a2,t3,59a2 <fcvt+0x1b2>
    596a:	4e91                	li	t4,4
    596c:	03d60763          	beq	a2,t4,599a <fcvt+0x1aa>
    5970:	4f15                	li	t5,5
    5972:	03e60063          	beq	a2,t5,5992 <fcvt+0x1a2>
    5976:	4f99                	li	t6,6
    5978:	01f60963          	beq	a2,t6,598a <fcvt+0x19a>
    597c:	875a                	mv	a4,s6
    597e:	005400a3          	sb	t0,1(s0)
    5982:	8827428b          	th.lbuib	t0,(a4),2,0
    5986:	00240693          	addi	a3,s0,2
    598a:	1816d28b          	th.sbia	t0,(a3),1,0
    598e:	8817428b          	th.lbuib	t0,(a4),1,0
    5992:	1816d28b          	th.sbia	t0,(a3),1,0
    5996:	8817428b          	th.lbuib	t0,(a4),1,0
    599a:	1816d28b          	th.sbia	t0,(a3),1,0
    599e:	8817428b          	th.lbuib	t0,(a4),1,0
    59a2:	1816d28b          	th.sbia	t0,(a3),1,0
    59a6:	8817428b          	th.lbuib	t0,(a4),1,0
    59aa:	1816d28b          	th.sbia	t0,(a3),1,0
    59ae:	8817428b          	th.lbuib	t0,(a4),1,0
    59b2:	00170793          	addi	a5,a4,1
    59b6:	00568023          	sb	t0,0(a3)
    59ba:	04f98763          	beq	s3,a5,5a08 <fcvt+0x218>
    59be:	00174e03          	lbu	t3,1(a4)
    59c2:	06a1                	addi	a3,a3,8
    59c4:	ffc68ca3          	sb	t3,-7(a3)
    59c8:	00274e83          	lbu	t4,2(a4)
    59cc:	ffd68d23          	sb	t4,-6(a3)
    59d0:	00374f03          	lbu	t5,3(a4)
    59d4:	ffe68da3          	sb	t5,-5(a3)
    59d8:	00474f83          	lbu	t6,4(a4)
    59dc:	fff68e23          	sb	t6,-4(a3)
    59e0:	00574503          	lbu	a0,5(a4)
    59e4:	fea68ea3          	sb	a0,-3(a3)
    59e8:	00674283          	lbu	t0,6(a4)
    59ec:	fe568f23          	sb	t0,-2(a3)
    59f0:	00774383          	lbu	t2,7(a4)
    59f4:	fe768fa3          	sb	t2,-1(a3)
    59f8:	8887428b          	th.lbuib	t0,(a4),8,0
    59fc:	00170793          	addi	a5,a4,1
    5a00:	00568023          	sb	t0,0(a3)
    5a04:	faf99de3          	bne	s3,a5,59be <fcvt+0x1ce>
    5a08:	9aca                	add	s5,s5,s2
    5a0a:	01540933          	add	s2,s0,s5
    5a0e:	0064a023          	sw	t1,0(s1)
    5a12:	2c896363          	bltu	s2,s0,5cd8 <fcvt+0x4e8>
    5a16:	01340533          	add	a0,s0,s3
    5a1a:	41650a33          	sub	s4,a0,s6
    5a1e:	29c2                	fld	fs3,16(sp)
    5a20:	7b42                	ld	s6,48(sp)
    5a22:	11496763          	bltu	s2,s4,5b30 <fcvt+0x340>
    5a26:	41498333          	sub	t1,s3,s4
    5a2a:	62c5                	lui	t0,0x11
    5a2c:	00337a93          	andi	s5,t1,3
    5a30:	b802b907          	fld	fs2,-1152(t0) # 10b80 <errpat+0x38>
    5a34:	060a8a63          	beqz	s5,5aa8 <fcvt+0x2b8>
    5a38:	0f3a7c63          	bgeu	s4,s3,5b30 <fcvt+0x340>
    5a3c:	13247553          	fmul.d	fa0,fs0,fs2
    5a40:	0028                	addi	a0,sp,8
    5a42:	515090ef          	jal	f756 <modf>
    5a46:	2ea2                	fld	ft9,8(sp)
    5a48:	22a50453          	fmv.d	fs0,fa0
    5a4c:	c20e93d3          	fcvt.w.d	t2,ft9,rtz
    5a50:	0303859b          	addiw	a1,t2,48
    5a54:	181a558b          	th.sbia	a1,(s4),1,0
    5a58:	0d496c63          	bltu	s2,s4,5b30 <fcvt+0x340>
    5a5c:	4605                	li	a2,1
    5a5e:	04ca8563          	beq	s5,a2,5aa8 <fcvt+0x2b8>
    5a62:	4809                	li	a6,2
    5a64:	030a8263          	beq	s5,a6,5a88 <fcvt+0x298>
    5a68:	13257553          	fmul.d	fa0,fa0,fs2
    5a6c:	0028                	addi	a0,sp,8
    5a6e:	4e9090ef          	jal	f756 <modf>
    5a72:	2f22                	fld	ft10,8(sp)
    5a74:	22a50453          	fmv.d	fs0,fa0
    5a78:	c20f18d3          	fcvt.w.d	a7,ft10,rtz
    5a7c:	03088e1b          	addiw	t3,a7,48
    5a80:	181a5e0b          	th.sbia	t3,(s4),1,0
    5a84:	0b496663          	bltu	s2,s4,5b30 <fcvt+0x340>
    5a88:	13247553          	fmul.d	fa0,fs0,fs2
    5a8c:	0028                	addi	a0,sp,8
    5a8e:	4c9090ef          	jal	f756 <modf>
    5a92:	2fa2                	fld	ft11,8(sp)
    5a94:	22a50453          	fmv.d	fs0,fa0
    5a98:	c20f9ed3          	fcvt.w.d	t4,ft11,rtz
    5a9c:	030e8f1b          	addiw	t5,t4,48
    5aa0:	181a5f0b          	th.sbia	t5,(s4),1,0
    5aa4:	09496663          	bltu	s2,s4,5b30 <fcvt+0x340>
    5aa8:	093a7463          	bgeu	s4,s3,5b30 <fcvt+0x340>
    5aac:	13247553          	fmul.d	fa0,fs0,fs2
    5ab0:	0028                	addi	a0,sp,8
    5ab2:	4a5090ef          	jal	f756 <modf>
    5ab6:	27a2                	fld	fa5,8(sp)
    5ab8:	8fd2                	mv	t6,s4
    5aba:	c2079753          	fcvt.w.d	a4,fa5,rtz
    5abe:	0307069b          	addiw	a3,a4,48
    5ac2:	181fd68b          	th.sbia	a3,(t6),1,0
    5ac6:	07f96563          	bltu	s2,t6,5b30 <fcvt+0x340>
    5aca:	13257553          	fmul.d	fa0,fa0,fs2
    5ace:	0028                	addi	a0,sp,8
    5ad0:	487090ef          	jal	f756 <modf>
    5ad4:	2722                	fld	fa4,8(sp)
    5ad6:	002a0793          	addi	a5,s4,2
    5ada:	c2071553          	fcvt.w.d	a0,fa4,rtz
    5ade:	0305029b          	addiw	t0,a0,48
    5ae2:	005a00a3          	sb	t0,1(s4)
    5ae6:	04f96563          	bltu	s2,a5,5b30 <fcvt+0x340>
    5aea:	13257553          	fmul.d	fa0,fa0,fs2
    5aee:	0028                	addi	a0,sp,8
    5af0:	467090ef          	jal	f756 <modf>
    5af4:	2622                	fld	fa2,8(sp)
    5af6:	003a0313          	addi	t1,s4,3
    5afa:	c2061ad3          	fcvt.w.d	s5,fa2,rtz
    5afe:	030a839b          	addiw	t2,s5,48
    5b02:	007a0123          	sb	t2,2(s4)
    5b06:	02696563          	bltu	s2,t1,5b30 <fcvt+0x340>
    5b0a:	13257553          	fmul.d	fa0,fa0,fs2
    5b0e:	0028                	addi	a0,sp,8
    5b10:	0a11                	addi	s4,s4,4
    5b12:	445090ef          	jal	f756 <modf>
    5b16:	26a2                	fld	fa3,8(sp)
    5b18:	22a50453          	fmv.d	fs0,fa0
    5b1c:	c20695d3          	fcvt.w.d	a1,fa3,rtz
    5b20:	0305861b          	addiw	a2,a1,48
    5b24:	feca0fa3          	sb	a2,-1(s4)
    5b28:	f94970e3          	bgeu	s2,s4,5aa8 <fcvt+0x2b8>
    5b2c:	00000013          	nop
    5b30:	1b397a63          	bgeu	s2,s3,5ce4 <fcvt+0x4f4>
    5b34:	00094983          	lbu	s3,0(s2)
    5b38:	03900e13          	li	t3,57
    5b3c:	0059881b          	addiw	a6,s3,5
    5b40:	0ff87893          	zext.b	a7,a6
    5b44:	01190023          	sb	a7,0(s2)
    5b48:	071e7463          	bgeu	t3,a7,5bb0 <fcvt+0x3c0>
    5b4c:	03000e93          	li	t4,48
    5b50:	87ca                	mv	a5,s2
    5b52:	8f76                	mv	t5,t4
    5b54:	03100f93          	li	t6,49
    5b58:	06f46c63          	bltu	s0,a5,5bd0 <fcvt+0x3e0>
    5b5c:	01f78023          	sb	t6,0(a5)
    5b60:	4098                	lw	a4,0(s1)
    5b62:	0017069b          	addiw	a3,a4,1
    5b66:	c094                	sw	a3,0(s1)
    5b68:	01247463          	bgeu	s0,s2,5b70 <fcvt+0x380>
    5b6c:	01d90023          	sb	t4,0(s2)
    5b70:	0007c503          	lbu	a0,0(a5)
    5b74:	0905                	addi	s2,s2,1
    5b76:	02ae7d63          	bgeu	t3,a0,5bb0 <fcvt+0x3c0>
    5b7a:	04f46b63          	bltu	s0,a5,5bd0 <fcvt+0x3e0>
    5b7e:	03100293          	li	t0,49
    5b82:	03900313          	li	t1,57
    5b86:	03000a93          	li	s5,48
    5b8a:	00578023          	sb	t0,0(a5)
    5b8e:	0004a383          	lw	t2,0(s1)
    5b92:	00138a1b          	addiw	s4,t2,1
    5b96:	0144a023          	sw	s4,0(s1)
    5b9a:	05247963          	bgeu	s0,s2,5bec <fcvt+0x3fc>
    5b9e:	18195a8b          	th.sbia	s5,(s2),1,0
    5ba2:	0007c603          	lbu	a2,0(a5)
    5ba6:	fec362e3          	bltu	t1,a2,5b8a <fcvt+0x39a>
    5baa:	0001                	nop
    5bac:	00000013          	nop
    5bb0:	00090023          	sb	zero,0(s2)
    5bb4:	70a6                	ld	ra,104(sp)
    5bb6:	8522                	mv	a0,s0
    5bb8:	64e6                	ld	s1,88(sp)
    5bba:	7406                	ld	s0,96(sp)
    5bbc:	7ae2                	ld	s5,56(sp)
    5bbe:	6a06                	ld	s4,64(sp)
    5bc0:	69a6                	ld	s3,72(sp)
    5bc2:	6946                	ld	s2,80(sp)
    5bc4:	3422                	fld	fs0,40(sp)
    5bc6:	3482                	fld	fs1,32(sp)
    5bc8:	2962                	fld	fs2,24(sp)
    5bca:	6165                	addi	sp,sp,112
    5bcc:	8082                	ret
    5bce:	0001                	nop
    5bd0:	fff7c983          	lbu	s3,-1(a5)
    5bd4:	01e78023          	sb	t5,0(a5)
    5bd8:	0019881b          	addiw	a6,s3,1
    5bdc:	0ff87893          	zext.b	a7,a6
    5be0:	ff178fa3          	sb	a7,-1(a5)
    5be4:	fd1e76e3          	bgeu	t3,a7,5bb0 <fcvt+0x3c0>
    5be8:	17fd                	addi	a5,a5,-1
    5bea:	b7bd                	j	5b58 <fcvt+0x368>
    5bec:	0007c583          	lbu	a1,0(a5)
    5bf0:	0905                	addi	s2,s2,1
    5bf2:	f8b36ce3          	bltu	t1,a1,5b8a <fcvt+0x39a>
    5bf6:	bf6d                	j	5bb0 <fcvt+0x3c0>
    5bf8:	a2a91453          	flt.d	s0,fs2,fa0
    5bfc:	c865                	beqz	s0,5cec <fcvt+0x4fc>
    5bfe:	6745                	lui	a4,0x11
    5c00:	b8073707          	fld	fa4,-1152(a4) # 10b80 <errpat+0x38>
    5c04:	6845                	lui	a6,0x11
    5c06:	b9083607          	fld	fa2,-1136(a6) # 10b90 <errpat+0x48>
    5c0a:	12e57053          	fmul.d	ft0,fa0,fa4
    5c0e:	4a81                	li	s5,0
    5c10:	22c606d3          	fmv.d	fa3,fa2
    5c14:	a2c018d3          	flt.d	a7,ft0,fa2
    5c18:	0e088563          	beqz	a7,5d02 <fcvt+0x512>
    5c1c:	22000453          	fmv.d	fs0,ft0
    5c20:	3afd                	addiw	s5,s5,-1
    5c22:	12e07053          	fmul.d	ft0,ft0,fa4
    5c26:	a2d01a53          	flt.d	s4,ft0,fa3
    5c2a:	060a0f63          	beqz	s4,5ca8 <fcvt+0x4b8>
    5c2e:	22000453          	fmv.d	fs0,ft0
    5c32:	3afd                	addiw	s5,s5,-1
    5c34:	12e07053          	fmul.d	ft0,ft0,fa4
    5c38:	a2d01e53          	flt.d	t3,ft0,fa3
    5c3c:	060e0663          	beqz	t3,5ca8 <fcvt+0x4b8>
    5c40:	22000453          	fmv.d	fs0,ft0
    5c44:	3afd                	addiw	s5,s5,-1
    5c46:	12e07053          	fmul.d	ft0,ft0,fa4
    5c4a:	a2d01ed3          	flt.d	t4,ft0,fa3
    5c4e:	040e8d63          	beqz	t4,5ca8 <fcvt+0x4b8>
    5c52:	22000453          	fmv.d	fs0,ft0
    5c56:	3afd                	addiw	s5,s5,-1
    5c58:	12e07053          	fmul.d	ft0,ft0,fa4
    5c5c:	a2d01f53          	flt.d	t5,ft0,fa3
    5c60:	040f0463          	beqz	t5,5ca8 <fcvt+0x4b8>
    5c64:	22000453          	fmv.d	fs0,ft0
    5c68:	3afd                	addiw	s5,s5,-1
    5c6a:	12e07053          	fmul.d	ft0,ft0,fa4
    5c6e:	a2d01fd3          	flt.d	t6,ft0,fa3
    5c72:	020f8b63          	beqz	t6,5ca8 <fcvt+0x4b8>
    5c76:	22000453          	fmv.d	fs0,ft0
    5c7a:	3afd                	addiw	s5,s5,-1
    5c7c:	12e07053          	fmul.d	ft0,ft0,fa4
    5c80:	a2d017d3          	flt.d	a5,ft0,fa3
    5c84:	c395                	beqz	a5,5ca8 <fcvt+0x4b8>
    5c86:	22000453          	fmv.d	fs0,ft0
    5c8a:	3afd                	addiw	s5,s5,-1
    5c8c:	12e07053          	fmul.d	ft0,ft0,fa4
    5c90:	a2d016d3          	flt.d	a3,ft0,fa3
    5c94:	ca91                	beqz	a3,5ca8 <fcvt+0x4b8>
    5c96:	22000453          	fmv.d	fs0,ft0
    5c9a:	3afd                	addiw	s5,s5,-1
    5c9c:	12e07053          	fmul.d	ft0,ft0,fa4
    5ca0:	a2d01553          	flt.d	a0,ft0,fa3
    5ca4:	fd25                	bnez	a0,5c1c <fcvt+0x42c>
    5ca6:	0001                	nop
    5ca8:	000412b7          	lui	t0,0x41
    5cac:	a402                	fsd	ft0,8(sp)
    5cae:	85d6                	mv	a1,s5
    5cb0:	fd028413          	addi	s0,t0,-48 # 40fd0 <CVTBUF>
    5cb4:	992e                	add	s2,s2,a1
    5cb6:	9922                	add	s2,s2,s0
    5cb8:	0154a023          	sw	s5,0(s1)
    5cbc:	02896063          	bltu	s2,s0,5cdc <fcvt+0x4ec>
    5cc0:	000419b7          	lui	s3,0x41
    5cc4:	8a22                	mv	s4,s0
    5cc6:	02098993          	addi	s3,s3,32 # 41020 <Loop_Num>
    5cca:	bbb1                	j	5a26 <fcvt+0x236>
    5ccc:	4305                	li	t1,1
    5cce:	22a51553          	fneg.d	fa0,fa0
    5cd2:	00662023          	sw	t1,0(a2)
    5cd6:	bea9                	j	5830 <fcvt+0x40>
    5cd8:	29c2                	fld	fs3,16(sp)
    5cda:	7b42                	ld	s6,48(sp)
    5cdc:	00040023          	sb	zero,0(s0)
    5ce0:	bdd1                	j	5bb4 <fcvt+0x3c4>
    5ce2:	0001                	nop
    5ce4:	040407a3          	sb	zero,79(s0)
    5ce8:	b5f1                	j	5bb4 <fcvt+0x3c4>
    5cea:	0001                	nop
    5cec:	00041637          	lui	a2,0x41
    5cf0:	4581                	li	a1,0
    5cf2:	4a81                	li	s5,0
    5cf4:	fd060413          	addi	s0,a2,-48 # 40fd0 <CVTBUF>
    5cf8:	bf75                	j	5cb4 <fcvt+0x4c4>
    5cfa:	29c2                	fld	fs3,16(sp)
    5cfc:	7b42                	ld	s6,48(sp)
    5cfe:	85d6                	mv	a1,s5
    5d00:	bf55                	j	5cb4 <fcvt+0x4c4>
    5d02:	000419b7          	lui	s3,0x41
    5d06:	a402                	fsd	ft0,8(sp)
    5d08:	4581                	li	a1,0
    5d0a:	fd098413          	addi	s0,s3,-48 # 40fd0 <CVTBUF>
    5d0e:	b75d                	j	5cb4 <fcvt+0x4c4>

0000000000005d10 <fcvtbuf>:
    5d10:	7159                	addi	sp,sp,-112
    5d12:	f20007d3          	fmv.d.x	fa5,zero
    5d16:	e4ce                	sd	s3,72(sp)
    5d18:	e8ca                	sd	s2,80(sp)
    5d1a:	0005091b          	sext.w	s2,a0
    5d1e:	04e00793          	li	a5,78
    5d22:	eca6                	sd	s1,88(sp)
    5d24:	f0a2                	sd	s0,96(sp)
    5d26:	a2f512d3          	flt.d	t0,fa0,fa5
    5d2a:	8436                	mv	s0,a3
    5d2c:	00092693          	slti	a3,s2,0
    5d30:	fc56                	sd	s5,56(sp)
    5d32:	e0d2                	sd	s4,64(sp)
    5d34:	42d0190b          	th.mvnez	s2,zero,a3
    5d38:	00a7a533          	slt	a0,a5,a0
    5d3c:	b422                	fsd	fs0,40(sp)
    5d3e:	b026                	fsd	fs1,32(sp)
    5d40:	ac4a                	fsd	fs2,24(sp)
    5d42:	f486                	sd	ra,104(sp)
    5d44:	84ae                	mv	s1,a1
    5d46:	42a7990b          	th.mvnez	s2,a5,a0
    5d4a:	64029763          	bnez	t0,6398 <fcvtbuf+0x688>
    5d4e:	00062023          	sw	zero,0(a2)
    5d52:	850a                	mv	a0,sp
    5d54:	203090ef          	jal	f756 <modf>
    5d58:	2e02                	fld	ft8,0(sp)
    5d5a:	f2000953          	fmv.d.x	fs2,zero
    5d5e:	22a50453          	fmv.d	fs0,fa0
    5d62:	a32e23d3          	feq.d	t2,ft8,fs2
    5d66:	56039363          	bnez	t2,62cc <fcvtbuf+0x5bc>
    5d6a:	6545                	lui	a0,0x11
    5d6c:	62c5                	lui	t0,0x11
    5d6e:	a84e                	fsd	fs3,16(sp)
    5d70:	b8053487          	fld	fs1,-1152(a0) # 10b80 <errpat+0x38>
    5d74:	b882b987          	fld	fs3,-1144(t0) # 10b88 <errpat+0x40>
    5d78:	05040993          	addi	s3,s0,80
    5d7c:	f85a                	sd	s6,48(sp)
    5d7e:	4a81                	li	s5,0
    5d80:	8b4e                	mv	s6,s3
    5d82:	1a9e7553          	fdiv.d	fa0,ft8,fs1
    5d86:	850a                	mv	a0,sp
    5d88:	1b7d                	addi	s6,s6,-1
    5d8a:	2a85                	addiw	s5,s5,1
    5d8c:	8a5a                	mv	s4,s6
    5d8e:	1c9090ef          	jal	f756 <modf>
    5d92:	a42a                	fsd	fa0,8(sp)
    5d94:	03357553          	fadd.d	fa0,fa0,fs3
    5d98:	2102                	fld	ft2,0(sp)
    5d9a:	86d6                	mv	a3,s5
    5d9c:	129570d3          	fmul.d	ft1,fa0,fs1
    5da0:	a32125d3          	feq.d	a1,ft2,fs2
    5da4:	c2009353          	fcvt.w.d	t1,ft1,rtz
    5da8:	0303039b          	addiw	t2,t1,48
    5dac:	0ff3f793          	zext.b	a5,t2
    5db0:	00fb0023          	sb	a5,0(s6)
    5db4:	edd9                	bnez	a1,5e52 <fcvtbuf+0x142>
    5db6:	1a917553          	fdiv.d	fa0,ft2,fs1
    5dba:	850a                	mv	a0,sp
    5dbc:	2a85                	addiw	s5,s5,1
    5dbe:	199090ef          	jal	f756 <modf>
    5dc2:	033571d3          	fadd.d	ft3,fa0,fs3
    5dc6:	2282                	fld	ft5,0(sp)
    5dc8:	a42a                	fsd	fa0,8(sp)
    5dca:	1291f253          	fmul.d	ft4,ft3,fs1
    5dce:	a322a853          	feq.d	a6,ft5,fs2
    5dd2:	86d6                	mv	a3,s5
    5dd4:	c2021653          	fcvt.w.d	a2,ft4,rtz
    5dd8:	0306071b          	addiw	a4,a2,48
    5ddc:	0ff77793          	zext.b	a5,a4
    5de0:	09fb578b          	th.sbib	a5,(s6),-1,0
    5de4:	06081763          	bnez	a6,5e52 <fcvtbuf+0x142>
    5de8:	1a92f553          	fdiv.d	fa0,ft5,fs1
    5dec:	850a                	mv	a0,sp
    5dee:	2a85                	addiw	s5,s5,1
    5df0:	ffea0b13          	addi	s6,s4,-2
    5df4:	163090ef          	jal	f756 <modf>
    5df8:	03357353          	fadd.d	ft6,fa0,fs3
    5dfc:	2582                	fld	fa1,0(sp)
    5dfe:	a42a                	fsd	fa0,8(sp)
    5e00:	129373d3          	fmul.d	ft7,ft6,fs1
    5e04:	a325aed3          	feq.d	t4,fa1,fs2
    5e08:	86d6                	mv	a3,s5
    5e0a:	c20398d3          	fcvt.w.d	a7,ft7,rtz
    5e0e:	03088e1b          	addiw	t3,a7,48
    5e12:	0ffe7793          	zext.b	a5,t3
    5e16:	fefa0f23          	sb	a5,-2(s4)
    5e1a:	020e9c63          	bnez	t4,5e52 <fcvtbuf+0x142>
    5e1e:	1a95f553          	fdiv.d	fa0,fa1,fs1
    5e22:	850a                	mv	a0,sp
    5e24:	2a85                	addiw	s5,s5,1
    5e26:	ffda0b13          	addi	s6,s4,-3
    5e2a:	12d090ef          	jal	f756 <modf>
    5e2e:	03357853          	fadd.d	fa6,fa0,fs3
    5e32:	2e02                	fld	ft8,0(sp)
    5e34:	a42a                	fsd	fa0,8(sp)
    5e36:	129878d3          	fmul.d	fa7,fa6,fs1
    5e3a:	a32e2553          	feq.d	a0,ft8,fs2
    5e3e:	86d6                	mv	a3,s5
    5e40:	c2089f53          	fcvt.w.d	t5,fa7,rtz
    5e44:	030f0f9b          	addiw	t6,t5,48
    5e48:	0ffff793          	zext.b	a5,t6
    5e4c:	fefa0ea3          	sb	a5,-3(s4)
    5e50:	d90d                	beqz	a0,5d82 <fcvtbuf+0x72>
    5e52:	573b7663          	bgeu	s6,s3,63be <fcvtbuf+0x6ae>
    5e56:	416402b3          	sub	t0,s0,s6
    5e5a:	04f28313          	addi	t1,t0,79
    5e5e:	00737393          	andi	t2,t1,7
    5e62:	05028a13          	addi	s4,t0,80
    5e66:	4701                	li	a4,0
    5e68:	0c038763          	beqz	t2,5f36 <fcvtbuf+0x226>
    5e6c:	00f40023          	sb	a5,0(s0)
    5e70:	4705                	li	a4,1
    5e72:	80eb478b          	th.lrbu	a5,s6,a4,0
    5e76:	0ce38063          	beq	t2,a4,5f36 <fcvtbuf+0x226>
    5e7a:	4589                	li	a1,2
    5e7c:	04b38763          	beq	t2,a1,5eca <fcvtbuf+0x1ba>
    5e80:	460d                	li	a2,3
    5e82:	02c38f63          	beq	t2,a2,5ec0 <fcvtbuf+0x1b0>
    5e86:	4811                	li	a6,4
    5e88:	03038763          	beq	t2,a6,5eb6 <fcvtbuf+0x1a6>
    5e8c:	4895                	li	a7,5
    5e8e:	01138f63          	beq	t2,a7,5eac <fcvtbuf+0x19c>
    5e92:	4e19                	li	t3,6
    5e94:	01c38763          	beq	t2,t3,5ea2 <fcvtbuf+0x192>
    5e98:	00e4578b          	th.srb	a5,s0,a4,0
    5e9c:	80bb478b          	th.lrbu	a5,s6,a1,0
    5ea0:	872e                	mv	a4,a1
    5ea2:	00e4578b          	th.srb	a5,s0,a4,0
    5ea6:	0705                	addi	a4,a4,1
    5ea8:	80eb478b          	th.lrbu	a5,s6,a4,0
    5eac:	00e4578b          	th.srb	a5,s0,a4,0
    5eb0:	0705                	addi	a4,a4,1
    5eb2:	80eb478b          	th.lrbu	a5,s6,a4,0
    5eb6:	00e4578b          	th.srb	a5,s0,a4,0
    5eba:	0705                	addi	a4,a4,1
    5ebc:	80eb478b          	th.lrbu	a5,s6,a4,0
    5ec0:	00e4578b          	th.srb	a5,s0,a4,0
    5ec4:	0705                	addi	a4,a4,1
    5ec6:	80eb478b          	th.lrbu	a5,s6,a4,0
    5eca:	00e4578b          	th.srb	a5,s0,a4,0
    5ece:	0705                	addi	a4,a4,1
    5ed0:	80eb478b          	th.lrbu	a5,s6,a4,0
    5ed4:	00170e93          	addi	t4,a4,1
    5ed8:	00e4578b          	th.srb	a5,s0,a4,0
    5edc:	074e8363          	beq	t4,s4,5f42 <fcvtbuf+0x232>
    5ee0:	81db488b          	th.lrbu	a7,s6,t4,0
    5ee4:	00270593          	addi	a1,a4,2
    5ee8:	00370293          	addi	t0,a4,3
    5eec:	01d4588b          	th.srb	a7,s0,t4,0
    5ef0:	80bb460b          	th.lrbu	a2,s6,a1,0
    5ef4:	00470393          	addi	t2,a4,4
    5ef8:	00570e13          	addi	t3,a4,5
    5efc:	00b4560b          	th.srb	a2,s0,a1,0
    5f00:	805b430b          	th.lrbu	t1,s6,t0,0
    5f04:	00670f13          	addi	t5,a4,6
    5f08:	00770513          	addi	a0,a4,7
    5f0c:	0054530b          	th.srb	t1,s0,t0,0
    5f10:	807b480b          	th.lrbu	a6,s6,t2,0
    5f14:	0721                	addi	a4,a4,8
    5f16:	0074580b          	th.srb	a6,s0,t2,0
    5f1a:	81cb4e8b          	th.lrbu	t4,s6,t3,0
    5f1e:	01c45e8b          	th.srb	t4,s0,t3,0
    5f22:	81eb4f8b          	th.lrbu	t6,s6,t5,0
    5f26:	01e45f8b          	th.srb	t6,s0,t5,0
    5f2a:	80ab478b          	th.lrbu	a5,s6,a0,0
    5f2e:	00a4578b          	th.srb	a5,s0,a0,0
    5f32:	80eb478b          	th.lrbu	a5,s6,a4,0
    5f36:	00e4578b          	th.srb	a5,s0,a4,0
    5f3a:	00170e93          	addi	t4,a4,1
    5f3e:	fb4e91e3          	bne	t4,s4,5ee0 <fcvtbuf+0x1d0>
    5f42:	9aca                	add	s5,s5,s2
    5f44:	01540933          	add	s2,s0,s5
    5f48:	c094                	sw	a3,0(s1)
    5f4a:	44896d63          	bltu	s2,s0,63a4 <fcvtbuf+0x694>
    5f4e:	9a22                	add	s4,s4,s0
    5f50:	29c2                	fld	fs3,16(sp)
    5f52:	7b42                	ld	s6,48(sp)
    5f54:	11496a63          	bltu	s2,s4,6068 <fcvtbuf+0x358>
    5f58:	41498fb3          	sub	t6,s3,s4
    5f5c:	6f45                	lui	t5,0x11
    5f5e:	003ffa93          	andi	s5,t6,3
    5f62:	b80f3907          	fld	fs2,-1152(t5) # 10b80 <errpat+0x38>
    5f66:	060a8d63          	beqz	s5,5fe0 <fcvtbuf+0x2d0>
    5f6a:	0f3a7f63          	bgeu	s4,s3,6068 <fcvtbuf+0x358>
    5f6e:	13247553          	fmul.d	fa0,fs0,fs2
    5f72:	0028                	addi	a0,sp,8
    5f74:	7e2090ef          	jal	f756 <modf>
    5f78:	2ea2                	fld	ft9,8(sp)
    5f7a:	22a50453          	fmv.d	fs0,fa0
    5f7e:	c20e97d3          	fcvt.w.d	a5,ft9,rtz
    5f82:	0307869b          	addiw	a3,a5,48
    5f86:	181a568b          	th.sbia	a3,(s4),1,0
    5f8a:	0d496f63          	bltu	s2,s4,6068 <fcvtbuf+0x358>
    5f8e:	4505                	li	a0,1
    5f90:	04aa8863          	beq	s5,a0,5fe0 <fcvtbuf+0x2d0>
    5f94:	4289                	li	t0,2
    5f96:	025a8263          	beq	s5,t0,5fba <fcvtbuf+0x2aa>
    5f9a:	13257553          	fmul.d	fa0,fa0,fs2
    5f9e:	0028                	addi	a0,sp,8
    5fa0:	7b6090ef          	jal	f756 <modf>
    5fa4:	2f22                	fld	ft10,8(sp)
    5fa6:	22a50453          	fmv.d	fs0,fa0
    5faa:	c20f1353          	fcvt.w.d	t1,ft10,rtz
    5fae:	0303039b          	addiw	t2,t1,48
    5fb2:	181a538b          	th.sbia	t2,(s4),1,0
    5fb6:	0b496963          	bltu	s2,s4,6068 <fcvtbuf+0x358>
    5fba:	13247553          	fmul.d	fa0,fs0,fs2
    5fbe:	0028                	addi	a0,sp,8
    5fc0:	796090ef          	jal	f756 <modf>
    5fc4:	2fa2                	fld	ft11,8(sp)
    5fc6:	22a50453          	fmv.d	fs0,fa0
    5fca:	c20f95d3          	fcvt.w.d	a1,ft11,rtz
    5fce:	0305861b          	addiw	a2,a1,48
    5fd2:	181a560b          	th.sbia	a2,(s4),1,0
    5fd6:	09496963          	bltu	s2,s4,6068 <fcvtbuf+0x358>
    5fda:	0001                	nop
    5fdc:	00000013          	nop
    5fe0:	093a7463          	bgeu	s4,s3,6068 <fcvtbuf+0x358>
    5fe4:	13247553          	fmul.d	fa0,fs0,fs2
    5fe8:	0028                	addi	a0,sp,8
    5fea:	76c090ef          	jal	f756 <modf>
    5fee:	27a2                	fld	fa5,8(sp)
    5ff0:	8852                	mv	a6,s4
    5ff2:	c20798d3          	fcvt.w.d	a7,fa5,rtz
    5ff6:	03088e1b          	addiw	t3,a7,48
    5ffa:	18185e0b          	th.sbia	t3,(a6),1,0
    5ffe:	07096563          	bltu	s2,a6,6068 <fcvtbuf+0x358>
    6002:	13257553          	fmul.d	fa0,fa0,fs2
    6006:	0028                	addi	a0,sp,8
    6008:	74e090ef          	jal	f756 <modf>
    600c:	2722                	fld	fa4,8(sp)
    600e:	002a0e93          	addi	t4,s4,2
    6012:	c2071753          	fcvt.w.d	a4,fa4,rtz
    6016:	03070f1b          	addiw	t5,a4,48
    601a:	01ea00a3          	sb	t5,1(s4)
    601e:	05d96563          	bltu	s2,t4,6068 <fcvtbuf+0x358>
    6022:	13257553          	fmul.d	fa0,fa0,fs2
    6026:	0028                	addi	a0,sp,8
    6028:	72e090ef          	jal	f756 <modf>
    602c:	2622                	fld	fa2,8(sp)
    602e:	003a0f93          	addi	t6,s4,3
    6032:	c2061ad3          	fcvt.w.d	s5,fa2,rtz
    6036:	030a879b          	addiw	a5,s5,48
    603a:	00fa0123          	sb	a5,2(s4)
    603e:	03f96563          	bltu	s2,t6,6068 <fcvtbuf+0x358>
    6042:	13257553          	fmul.d	fa0,fa0,fs2
    6046:	0028                	addi	a0,sp,8
    6048:	0a11                	addi	s4,s4,4
    604a:	70c090ef          	jal	f756 <modf>
    604e:	26a2                	fld	fa3,8(sp)
    6050:	22a50453          	fmv.d	fs0,fa0
    6054:	c20696d3          	fcvt.w.d	a3,fa3,rtz
    6058:	0306851b          	addiw	a0,a3,48
    605c:	feaa0fa3          	sb	a0,-1(s4)
    6060:	f94970e3          	bgeu	s2,s4,5fe0 <fcvtbuf+0x2d0>
    6064:	00000013          	nop
    6068:	35397463          	bgeu	s2,s3,63b0 <fcvtbuf+0x6a0>
    606c:	00094983          	lbu	s3,0(s2)
    6070:	03900393          	li	t2,57
    6074:	0059829b          	addiw	t0,s3,5
    6078:	0ff2f313          	zext.b	t1,t0
    607c:	00690023          	sb	t1,0(s2)
    6080:	0663f863          	bgeu	t2,t1,60f0 <fcvtbuf+0x3e0>
    6084:	40890833          	sub	a6,s2,s0
    6088:	03000593          	li	a1,48
    608c:	00787e13          	andi	t3,a6,7
    6090:	87ca                	mv	a5,s2
    6092:	88ae                	mv	a7,a1
    6094:	861e                	mv	a2,t2
    6096:	160e0163          	beqz	t3,61f8 <fcvtbuf+0x4e8>
    609a:	07246b63          	bltu	s0,s2,6110 <fcvtbuf+0x400>
    609e:	03100893          	li	a7,49
    60a2:	01178023          	sb	a7,0(a5)
    60a6:	4090                	lw	a2,0(s1)
    60a8:	00160a1b          	addiw	s4,a2,1
    60ac:	0144a023          	sw	s4,0(s1)
    60b0:	01247463          	bgeu	s0,s2,60b8 <fcvtbuf+0x3a8>
    60b4:	00b90023          	sb	a1,0(s2)
    60b8:	0007c583          	lbu	a1,0(a5)
    60bc:	03900693          	li	a3,57
    60c0:	0905                	addi	s2,s2,1
    60c2:	02b6f763          	bgeu	a3,a1,60f0 <fcvtbuf+0x3e0>
    60c6:	03100513          	li	a0,49
    60ca:	03000993          	li	s3,48
    60ce:	00a78023          	sb	a0,0(a5)
    60d2:	0004a283          	lw	t0,0(s1)
    60d6:	0012831b          	addiw	t1,t0,1
    60da:	0064a023          	sw	t1,0(s1)
    60de:	1f247163          	bgeu	s0,s2,62c0 <fcvtbuf+0x5b0>
    60e2:	1819598b          	th.sbia	s3,(s2),1,0
    60e6:	0007c803          	lbu	a6,0(a5)
    60ea:	ff06e2e3          	bltu	a3,a6,60ce <fcvtbuf+0x3be>
    60ee:	0001                	nop
    60f0:	00090023          	sb	zero,0(s2)
    60f4:	70a6                	ld	ra,104(sp)
    60f6:	8522                	mv	a0,s0
    60f8:	64e6                	ld	s1,88(sp)
    60fa:	7406                	ld	s0,96(sp)
    60fc:	7ae2                	ld	s5,56(sp)
    60fe:	6a06                	ld	s4,64(sp)
    6100:	69a6                	ld	s3,72(sp)
    6102:	6946                	ld	s2,80(sp)
    6104:	3422                	fld	fs0,40(sp)
    6106:	3482                	fld	fs1,32(sp)
    6108:	2962                	fld	fs2,24(sp)
    610a:	6165                	addi	sp,sp,112
    610c:	8082                	ret
    610e:	0001                	nop
    6110:	8eca                	mv	t4,s2
    6112:	19fed58b          	th.sbia	a1,(t4),-1,0
    6116:	fff94703          	lbu	a4,-1(s2)
    611a:	00170f1b          	addiw	t5,a4,1
    611e:	0fff7f93          	zext.b	t6,t5
    6122:	fff90fa3          	sb	t6,-1(s2)
    6126:	fdf3f5e3          	bgeu	t2,t6,60f0 <fcvtbuf+0x3e0>
    612a:	4a85                	li	s5,1
    612c:	87f6                	mv	a5,t4
    612e:	0d5e0563          	beq	t3,s5,61f8 <fcvtbuf+0x4e8>
    6132:	4a09                	li	s4,2
    6134:	0b4e0263          	beq	t3,s4,61d8 <fcvtbuf+0x4c8>
    6138:	468d                	li	a3,3
    613a:	08de0163          	beq	t3,a3,61bc <fcvtbuf+0x4ac>
    613e:	4511                	li	a0,4
    6140:	06ae0063          	beq	t3,a0,61a0 <fcvtbuf+0x490>
    6144:	4995                	li	s3,5
    6146:	033e0f63          	beq	t3,s3,6184 <fcvtbuf+0x474>
    614a:	4299                	li	t0,6
    614c:	005e0e63          	beq	t3,t0,6168 <fcvtbuf+0x458>
    6150:	19f7d58b          	th.sbia	a1,(a5),-1,0
    6154:	fffec303          	lbu	t1,-1(t4)
    6158:	0013039b          	addiw	t2,t1,1
    615c:	0ff3f813          	zext.b	a6,t2
    6160:	ff0e8fa3          	sb	a6,-1(t4)
    6164:	f90676e3          	bgeu	a2,a6,60f0 <fcvtbuf+0x3e0>
    6168:	8e3e                	mv	t3,a5
    616a:	19fe588b          	th.sbia	a7,(t3),-1,0
    616e:	fff7ce83          	lbu	t4,-1(a5)
    6172:	001e871b          	addiw	a4,t4,1
    6176:	0ff77f13          	zext.b	t5,a4
    617a:	ffe78fa3          	sb	t5,-1(a5)
    617e:	f7e679e3          	bgeu	a2,t5,60f0 <fcvtbuf+0x3e0>
    6182:	87f2                	mv	a5,t3
    6184:	8fbe                	mv	t6,a5
    6186:	19ffd88b          	th.sbia	a7,(t6),-1,0
    618a:	fff7ca83          	lbu	s5,-1(a5)
    618e:	001a8a1b          	addiw	s4,s5,1
    6192:	0ffa7693          	zext.b	a3,s4
    6196:	fed78fa3          	sb	a3,-1(a5)
    619a:	f4d67be3          	bgeu	a2,a3,60f0 <fcvtbuf+0x3e0>
    619e:	87fe                	mv	a5,t6
    61a0:	853e                	mv	a0,a5
    61a2:	19f5588b          	th.sbia	a7,(a0),-1,0
    61a6:	fff7c983          	lbu	s3,-1(a5)
    61aa:	0019829b          	addiw	t0,s3,1
    61ae:	0ff2f313          	zext.b	t1,t0
    61b2:	fe678fa3          	sb	t1,-1(a5)
    61b6:	f2667de3          	bgeu	a2,t1,60f0 <fcvtbuf+0x3e0>
    61ba:	87aa                	mv	a5,a0
    61bc:	83be                	mv	t2,a5
    61be:	19f3d88b          	th.sbia	a7,(t2),-1,0
    61c2:	fff7c803          	lbu	a6,-1(a5)
    61c6:	00180e1b          	addiw	t3,a6,1
    61ca:	0ffe7e93          	zext.b	t4,t3
    61ce:	ffd78fa3          	sb	t4,-1(a5)
    61d2:	f1d67fe3          	bgeu	a2,t4,60f0 <fcvtbuf+0x3e0>
    61d6:	879e                	mv	a5,t2
    61d8:	8f3e                	mv	t5,a5
    61da:	19ff588b          	th.sbia	a7,(t5),-1,0
    61de:	fff7c703          	lbu	a4,-1(a5)
    61e2:	00170f9b          	addiw	t6,a4,1
    61e6:	0ffffa93          	zext.b	s5,t6
    61ea:	ff578fa3          	sb	s5,-1(a5)
    61ee:	87fa                	mv	a5,t5
    61f0:	f15670e3          	bgeu	a2,s5,60f0 <fcvtbuf+0x3e0>
    61f4:	00000013          	nop
    61f8:	eaf473e3          	bgeu	s0,a5,609e <fcvtbuf+0x38e>
    61fc:	fff7ce03          	lbu	t3,-1(a5)
    6200:	01178023          	sb	a7,0(a5)
    6204:	001e0e9b          	addiw	t4,t3,1
    6208:	0ffeff13          	zext.b	t5,t4
    620c:	ffe78fa3          	sb	t5,-1(a5)
    6210:	efe670e3          	bgeu	a2,t5,60f0 <fcvtbuf+0x3e0>
    6214:	ffe7c703          	lbu	a4,-2(a5)
    6218:	ff178fa3          	sb	a7,-1(a5)
    621c:	00170f9b          	addiw	t6,a4,1
    6220:	0ffffa93          	zext.b	s5,t6
    6224:	ff578f23          	sb	s5,-2(a5)
    6228:	ed5674e3          	bgeu	a2,s5,60f0 <fcvtbuf+0x3e0>
    622c:	ffd7ca03          	lbu	s4,-3(a5)
    6230:	ff178f23          	sb	a7,-2(a5)
    6234:	001a069b          	addiw	a3,s4,1
    6238:	0ff6f513          	zext.b	a0,a3
    623c:	fea78ea3          	sb	a0,-3(a5)
    6240:	eaa678e3          	bgeu	a2,a0,60f0 <fcvtbuf+0x3e0>
    6244:	ffc7c983          	lbu	s3,-4(a5)
    6248:	ff178ea3          	sb	a7,-3(a5)
    624c:	0019829b          	addiw	t0,s3,1
    6250:	0ff2f313          	zext.b	t1,t0
    6254:	fe678e23          	sb	t1,-4(a5)
    6258:	e8667ce3          	bgeu	a2,t1,60f0 <fcvtbuf+0x3e0>
    625c:	ffb7c383          	lbu	t2,-5(a5)
    6260:	ff178e23          	sb	a7,-4(a5)
    6264:	0013881b          	addiw	a6,t2,1
    6268:	0ff87e13          	zext.b	t3,a6
    626c:	ffc78da3          	sb	t3,-5(a5)
    6270:	e9c670e3          	bgeu	a2,t3,60f0 <fcvtbuf+0x3e0>
    6274:	ffa7ce83          	lbu	t4,-6(a5)
    6278:	ff178da3          	sb	a7,-5(a5)
    627c:	001e8f1b          	addiw	t5,t4,1
    6280:	0fff7713          	zext.b	a4,t5
    6284:	fee78d23          	sb	a4,-6(a5)
    6288:	e6e674e3          	bgeu	a2,a4,60f0 <fcvtbuf+0x3e0>
    628c:	ff97cf83          	lbu	t6,-7(a5)
    6290:	ff178d23          	sb	a7,-6(a5)
    6294:	001f8a9b          	addiw	s5,t6,1
    6298:	0ffafa13          	zext.b	s4,s5
    629c:	ff478ca3          	sb	s4,-7(a5)
    62a0:	e54678e3          	bgeu	a2,s4,60f0 <fcvtbuf+0x3e0>
    62a4:	ff87c683          	lbu	a3,-8(a5)
    62a8:	ff178ca3          	sb	a7,-7(a5)
    62ac:	0016851b          	addiw	a0,a3,1
    62b0:	0ff57993          	zext.b	s3,a0
    62b4:	ff378c23          	sb	s3,-8(a5)
    62b8:	e3367ce3          	bgeu	a2,s3,60f0 <fcvtbuf+0x3e0>
    62bc:	17e1                	addi	a5,a5,-8
    62be:	bf2d                	j	61f8 <fcvtbuf+0x4e8>
    62c0:	0007c383          	lbu	t2,0(a5)
    62c4:	0905                	addi	s2,s2,1
    62c6:	e076e4e3          	bltu	a3,t2,60ce <fcvtbuf+0x3be>
    62ca:	b51d                	j	60f0 <fcvtbuf+0x3e0>
    62cc:	a2a915d3          	flt.d	a1,fs2,fa0
    62d0:	c5e5                	beqz	a1,63b8 <fcvtbuf+0x6a8>
    62d2:	6745                	lui	a4,0x11
    62d4:	b8073707          	fld	fa4,-1152(a4) # 10b80 <errpat+0x38>
    62d8:	6845                	lui	a6,0x11
    62da:	b9083607          	fld	fa2,-1136(a6) # 10b90 <errpat+0x48>
    62de:	12e57053          	fmul.d	ft0,fa0,fa4
    62e2:	4a81                	li	s5,0
    62e4:	22c606d3          	fmv.d	fa3,fa2
    62e8:	a2c018d3          	flt.d	a7,ft0,fa2
    62ec:	0c088d63          	beqz	a7,63c6 <fcvtbuf+0x6b6>
    62f0:	22000453          	fmv.d	fs0,ft0
    62f4:	3afd                	addiw	s5,s5,-1
    62f6:	12e07053          	fmul.d	ft0,ft0,fa4
    62fa:	a2d019d3          	flt.d	s3,ft0,fa3
    62fe:	08098163          	beqz	s3,6380 <fcvtbuf+0x670>
    6302:	22000453          	fmv.d	fs0,ft0
    6306:	3afd                	addiw	s5,s5,-1
    6308:	12e07053          	fmul.d	ft0,ft0,fa4
    630c:	a2d01a53          	flt.d	s4,ft0,fa3
    6310:	060a0863          	beqz	s4,6380 <fcvtbuf+0x670>
    6314:	22000453          	fmv.d	fs0,ft0
    6318:	3afd                	addiw	s5,s5,-1
    631a:	12e07053          	fmul.d	ft0,ft0,fa4
    631e:	a2d01e53          	flt.d	t3,ft0,fa3
    6322:	040e0f63          	beqz	t3,6380 <fcvtbuf+0x670>
    6326:	22000453          	fmv.d	fs0,ft0
    632a:	3afd                	addiw	s5,s5,-1
    632c:	12e07053          	fmul.d	ft0,ft0,fa4
    6330:	a2d01ed3          	flt.d	t4,ft0,fa3
    6334:	040e8663          	beqz	t4,6380 <fcvtbuf+0x670>
    6338:	22000453          	fmv.d	fs0,ft0
    633c:	3afd                	addiw	s5,s5,-1
    633e:	12e07053          	fmul.d	ft0,ft0,fa4
    6342:	a2d01f53          	flt.d	t5,ft0,fa3
    6346:	020f0d63          	beqz	t5,6380 <fcvtbuf+0x670>
    634a:	22000453          	fmv.d	fs0,ft0
    634e:	3afd                	addiw	s5,s5,-1
    6350:	12e07053          	fmul.d	ft0,ft0,fa4
    6354:	a2d01fd3          	flt.d	t6,ft0,fa3
    6358:	020f8463          	beqz	t6,6380 <fcvtbuf+0x670>
    635c:	22000453          	fmv.d	fs0,ft0
    6360:	3afd                	addiw	s5,s5,-1
    6362:	12e07053          	fmul.d	ft0,ft0,fa4
    6366:	a2d017d3          	flt.d	a5,ft0,fa3
    636a:	cb99                	beqz	a5,6380 <fcvtbuf+0x670>
    636c:	22000453          	fmv.d	fs0,ft0
    6370:	3afd                	addiw	s5,s5,-1
    6372:	12e07053          	fmul.d	ft0,ft0,fa4
    6376:	a2d016d3          	flt.d	a3,ft0,fa3
    637a:	fabd                	bnez	a3,62f0 <fcvtbuf+0x5e0>
    637c:	00000013          	nop
    6380:	a402                	fsd	ft0,8(sp)
    6382:	8656                	mv	a2,s5
    6384:	9932                	add	s2,s2,a2
    6386:	9922                	add	s2,s2,s0
    6388:	0154a023          	sw	s5,0(s1)
    638c:	00896e63          	bltu	s2,s0,63a8 <fcvtbuf+0x698>
    6390:	8a22                	mv	s4,s0
    6392:	05040993          	addi	s3,s0,80
    6396:	b6c9                	j	5f58 <fcvtbuf+0x248>
    6398:	4305                	li	t1,1
    639a:	22a51553          	fneg.d	fa0,fa0
    639e:	00662023          	sw	t1,0(a2)
    63a2:	ba45                	j	5d52 <fcvtbuf+0x42>
    63a4:	29c2                	fld	fs3,16(sp)
    63a6:	7b42                	ld	s6,48(sp)
    63a8:	00040023          	sb	zero,0(s0)
    63ac:	b3a1                	j	60f4 <fcvtbuf+0x3e4>
    63ae:	0001                	nop
    63b0:	040407a3          	sb	zero,79(s0)
    63b4:	b381                	j	60f4 <fcvtbuf+0x3e4>
    63b6:	0001                	nop
    63b8:	4601                	li	a2,0
    63ba:	4a81                	li	s5,0
    63bc:	b7e1                	j	6384 <fcvtbuf+0x674>
    63be:	29c2                	fld	fs3,16(sp)
    63c0:	7b42                	ld	s6,48(sp)
    63c2:	8656                	mv	a2,s5
    63c4:	b7c1                	j	6384 <fcvtbuf+0x674>
    63c6:	a402                	fsd	ft0,8(sp)
    63c8:	4601                	li	a2,0
    63ca:	bf6d                	j	6384 <fcvtbuf+0x674>
	...

00000000000063e0 <fputc>:
    63e0:	020007b7          	lui	a5,0x2000
    63e4:	fea7a823          	sw	a0,-16(a5) # 1fffff0 <__kernel_stack+0x1f11ff0>
    63e8:	8082                	ret
    63ea:	00000013          	nop
    63ee:	0001                	nop

00000000000063f0 <os_critical_enter>:
    63f0:	8082                	ret
    63f2:	0001                	nop
    63f4:	00000013          	nop
    63f8:	00000013          	nop
    63fc:	00000013          	nop

0000000000006400 <os_critical_exit>:
    6400:	8082                	ret
	...

0000000000006410 <CK_Timer_Interruptservice>:
    6410:	00041337          	lui	t1,0x41
    6414:	02030393          	addi	t2,t1,32 # 41020 <Loop_Num>
    6418:	0003a703          	lw	a4,0(t2)
    641c:	100117b7          	lui	a5,0x10011
    6420:	00c7a283          	lw	t0,12(a5) # 1001100c <__kernel_stack+0xff2300c>
    6424:	1141                	addi	sp,sp,-16
    6426:	0017051b          	addiw	a0,a4,1
    642a:	c616                	sw	t0,12(sp)
    642c:	00a3a023          	sw	a0,0(t2)
    6430:	0141                	addi	sp,sp,16
    6432:	8082                	ret
    6434:	00000013          	nop
    6438:	00000013          	nop
    643c:	00000013          	nop

0000000000006440 <Timer_Interrupt_Init>:
    6440:	8082                	ret
    6442:	0001                	nop
    6444:	00000013          	nop
    6448:	00000013          	nop
    644c:	00000013          	nop

0000000000006450 <iterate>:
    6450:	7179                	addi	sp,sp,-48
    6452:	e44e                	sd	s3,8(sp)
    6454:	e84a                	sd	s2,16(sp)
    6456:	fc11540b          	th.sdd	s0,ra,(sp),2,4
    645a:	02c52983          	lw	s3,44(a0)
    645e:	00041937          	lui	s2,0x41
    6462:	06053023          	sd	zero,96(a0)
    6466:	842a                	mv	s0,a0
    6468:	02090913          	addi	s2,s2,32 # 41020 <Loop_Num>
    646c:	2c4090ef          	jal	f730 <get_vtimer>
    6470:	00a92223          	sw	a0,4(s2)
    6474:	14098b63          	beqz	s3,65ca <iterate+0x17a>
    6478:	4585                	li	a1,1
    647a:	8522                	mv	a0,s0
    647c:	ec26                	sd	s1,24(sp)
    647e:	cb2fa0ef          	jal	930 <core_bench_list>
    6482:	06045583          	lhu	a1,96(s0)
    6486:	4485                	li	s1,1
    6488:	e29fd0ef          	jal	42b0 <crcu16>
    648c:	06a41023          	sh	a0,96(s0)
    6490:	55fd                	li	a1,-1
    6492:	8522                	mv	a0,s0
    6494:	c9cfa0ef          	jal	930 <core_bench_list>
    6498:	06045583          	lhu	a1,96(s0)
    649c:	e15fd0ef          	jal	42b0 <crcu16>
    64a0:	06a41023          	sh	a0,96(s0)
    64a4:	06a41123          	sh	a0,98(s0)
    64a8:	12998063          	beq	s3,s1,65c8 <iterate+0x178>
    64ac:	409987b3          	sub	a5,s3,s1
    64b0:	0037f293          	andi	t0,a5,3
    64b4:	08028a63          	beqz	t0,6548 <iterate+0xf8>
    64b8:	06928163          	beq	t0,s1,651a <iterate+0xca>
    64bc:	e052                	sd	s4,0(sp)
    64be:	4a09                	li	s4,2
    64c0:	03428763          	beq	t0,s4,64ee <iterate+0x9e>
    64c4:	85a6                	mv	a1,s1
    64c6:	8522                	mv	a0,s0
    64c8:	c68fa0ef          	jal	930 <core_bench_list>
    64cc:	06045583          	lhu	a1,96(s0)
    64d0:	84d2                	mv	s1,s4
    64d2:	ddffd0ef          	jal	42b0 <crcu16>
    64d6:	06a41023          	sh	a0,96(s0)
    64da:	55fd                	li	a1,-1
    64dc:	8522                	mv	a0,s0
    64de:	c52fa0ef          	jal	930 <core_bench_list>
    64e2:	06045583          	lhu	a1,96(s0)
    64e6:	dcbfd0ef          	jal	42b0 <crcu16>
    64ea:	06a41023          	sh	a0,96(s0)
    64ee:	4585                	li	a1,1
    64f0:	8522                	mv	a0,s0
    64f2:	c3efa0ef          	jal	930 <core_bench_list>
    64f6:	06045583          	lhu	a1,96(s0)
    64fa:	2485                	addiw	s1,s1,1
    64fc:	db5fd0ef          	jal	42b0 <crcu16>
    6500:	06a41023          	sh	a0,96(s0)
    6504:	55fd                	li	a1,-1
    6506:	8522                	mv	a0,s0
    6508:	c28fa0ef          	jal	930 <core_bench_list>
    650c:	06045583          	lhu	a1,96(s0)
    6510:	da1fd0ef          	jal	42b0 <crcu16>
    6514:	6a02                	ld	s4,0(sp)
    6516:	06a41023          	sh	a0,96(s0)
    651a:	4585                	li	a1,1
    651c:	8522                	mv	a0,s0
    651e:	c12fa0ef          	jal	930 <core_bench_list>
    6522:	06045583          	lhu	a1,96(s0)
    6526:	2485                	addiw	s1,s1,1
    6528:	d89fd0ef          	jal	42b0 <crcu16>
    652c:	06a41023          	sh	a0,96(s0)
    6530:	55fd                	li	a1,-1
    6532:	8522                	mv	a0,s0
    6534:	bfcfa0ef          	jal	930 <core_bench_list>
    6538:	06045583          	lhu	a1,96(s0)
    653c:	d75fd0ef          	jal	42b0 <crcu16>
    6540:	06a41023          	sh	a0,96(s0)
    6544:	08998263          	beq	s3,s1,65c8 <iterate+0x178>
    6548:	4585                	li	a1,1
    654a:	8522                	mv	a0,s0
    654c:	be4fa0ef          	jal	930 <core_bench_list>
    6550:	06045583          	lhu	a1,96(s0)
    6554:	2485                	addiw	s1,s1,1
    6556:	2485                	addiw	s1,s1,1
    6558:	d59fd0ef          	jal	42b0 <crcu16>
    655c:	06a41023          	sh	a0,96(s0)
    6560:	55fd                	li	a1,-1
    6562:	8522                	mv	a0,s0
    6564:	bccfa0ef          	jal	930 <core_bench_list>
    6568:	06045583          	lhu	a1,96(s0)
    656c:	2485                	addiw	s1,s1,1
    656e:	d43fd0ef          	jal	42b0 <crcu16>
    6572:	06a41023          	sh	a0,96(s0)
    6576:	4585                	li	a1,1
    6578:	8522                	mv	a0,s0
    657a:	bb6fa0ef          	jal	930 <core_bench_list>
    657e:	06045583          	lhu	a1,96(s0)
    6582:	d2ffd0ef          	jal	42b0 <crcu16>
    6586:	06a41023          	sh	a0,96(s0)
    658a:	55fd                	li	a1,-1
    658c:	8522                	mv	a0,s0
    658e:	ba2fa0ef          	jal	930 <core_bench_list>
    6592:	06045583          	lhu	a1,96(s0)
    6596:	d1bfd0ef          	jal	42b0 <crcu16>
    659a:	06a41023          	sh	a0,96(s0)
    659e:	4585                	li	a1,1
    65a0:	8522                	mv	a0,s0
    65a2:	b8efa0ef          	jal	930 <core_bench_list>
    65a6:	06045583          	lhu	a1,96(s0)
    65aa:	d07fd0ef          	jal	42b0 <crcu16>
    65ae:	06a41023          	sh	a0,96(s0)
    65b2:	55fd                	li	a1,-1
    65b4:	8522                	mv	a0,s0
    65b6:	b7afa0ef          	jal	930 <core_bench_list>
    65ba:	06045583          	lhu	a1,96(s0)
    65be:	cf3fd0ef          	jal	42b0 <crcu16>
    65c2:	06a41023          	sh	a0,96(s0)
    65c6:	bf91                	j	651a <iterate+0xca>
    65c8:	64e2                	ld	s1,24(sp)
    65ca:	166090ef          	jal	f730 <get_vtimer>
    65ce:	00492303          	lw	t1,4(s2)
    65d2:	85ce                	mv	a1,s3
    65d4:	4065063b          	subw	a2,a0,t1
    65d8:	0336563b          	divuw	a2,a2,s3
    65dc:	e2c9550b          	th.swd	a0,a2,(s2),1,3
    65e0:	6541                	lui	a0,0x10
    65e2:	61850513          	addi	a0,a0,1560 # 10618 <__errno+0xec>
    65e6:	2cb080ef          	jal	f0b0 <printf>
    65ea:	00c92583          	lw	a1,12(s2)
    65ee:	66c5                	lui	a3,0x11
    65f0:	c206a787          	flw	fa5,-992(a3) # 10c20 <errpat+0xd8>
    65f4:	d005f753          	fcvt.s.w	fa4,a1
    65f8:	63c1                	lui	t2,0x10
    65fa:	18e7f053          	fdiv.s	ft0,fa5,fa4
    65fe:	66038513          	addi	a0,t2,1632 # 10660 <__errno+0x134>
    6602:	420000d3          	fcvt.d.s	ft1,ft0
    6606:	e20085d3          	fmv.x.d	a1,ft1
    660a:	2a7080ef          	jal	f0b0 <printf>
    660e:	132090ef          	jal	f740 <sim_end>
    6612:	fc11440b          	th.ldd	s0,ra,(sp),2,4
    6616:	69a2                	ld	s3,8(sp)
    6618:	6942                	ld	s2,16(sp)
    661a:	4501                	li	a0,0
    661c:	6145                	addi	sp,sp,48
    661e:	8082                	ret
	...

0000000000006630 <main>:
    6630:	716d                	addi	sp,sp,-272
    6632:	e606                	sd	ra,264(sp)
    6634:	f56e                	sd	s11,168(sp)
    6636:	f96a                	sd	s10,176(sp)
    6638:	fd66                	sd	s9,184(sp)
    663a:	e1e2                	sd	s8,192(sp)
    663c:	e5de                	sd	s7,200(sp)
    663e:	e9da                	sd	s6,208(sp)
    6640:	edd6                	sd	s5,216(sp)
    6642:	f1d2                	sd	s4,224(sp)
    6644:	f5ce                	sd	s3,232(sp)
    6646:	f9ca                	sd	s2,240(sp)
    6648:	fda6                	sd	s1,248(sp)
    664a:	e222                	sd	s0,256(sp)
    664c:	ad22                	fsd	fs0,152(sp)
    664e:	81010113          	addi	sp,sp,-2032
    6652:	862e                	mv	a2,a1
    6654:	de2a                	sw	a0,60(sp)
    6656:	186c                	addi	a1,sp,60
    6658:	0aa10513          	addi	a0,sp,170
    665c:	db5fc0ef          	jal	3410 <portable_init>
    6660:	4505                	li	a0,1
    6662:	b1ffd0ef          	jal	4180 <get_seed_32>
    6666:	04a11023          	sh	a0,64(sp)
    666a:	4509                	li	a0,2
    666c:	b15fd0ef          	jal	4180 <get_seed_32>
    6670:	04a11123          	sh	a0,66(sp)
    6674:	450d                	li	a0,3
    6676:	b0bfd0ef          	jal	4180 <get_seed_32>
    667a:	04a11223          	sh	a0,68(sp)
    667e:	4511                	li	a0,4
    6680:	b01fd0ef          	jal	4180 <get_seed_32>
    6684:	3c05278b          	th.ext	a5,a0,15,0
    6688:	4515                	li	a0,5
    668a:	d6be                	sw	a5,108(sp)
    668c:	af5fd0ef          	jal	4180 <get_seed_32>
    6690:	6706                	ld	a4,64(sp)
    6692:	429d                	li	t0,7
    6694:	42a5128b          	th.mvnez	t0,a0,a0
    6698:	01071693          	slli	a3,a4,0x10
    669c:	d896                	sw	t0,112(sp)
    669e:	0100                	addi	s0,sp,128
    66a0:	e699                	bnez	a3,66ae <main+0x7e>
    66a2:	06600313          	li	t1,102
    66a6:	fc641223          	sh	t1,-60(s0)
    66aa:	fc042023          	sw	zero,-64(s0)
    66ae:	fc043483          	ld	s1,-64(s0)
    66b2:	4385                	li	t2,1
    66b4:	bc04b50b          	th.extu	a0,s1,47,0
    66b8:	00751c63          	bne	a0,t2,66d0 <main+0xa0>
    66bc:	341535b7          	lui	a1,0x34153
    66c0:	41558613          	addi	a2,a1,1045 # 34153415 <__kernel_stack+0x34065415>
    66c4:	06600813          	li	a6,102
    66c8:	fcc42023          	sw	a2,-64(s0)
    66cc:	fd041223          	sh	a6,-60(s0)
    66d0:	0b010893          	addi	a7,sp,176
    66d4:	0a011423          	sh	zero,168(sp)
    66d8:	0022f993          	andi	s3,t0,2
    66dc:	fd143423          	sd	a7,-56(s0)
    66e0:	0012ff13          	andi	t5,t0,1
    66e4:	0042fa13          	andi	s4,t0,4
    66e8:	10099063          	bnez	s3,67e8 <perf_monitor_end+0x80>
    66ec:	140a0663          	beqz	s4,6838 <perf_monitor_end+0xd0>
    66f0:	001f0b1b          	addiw	s6,t5,1
    66f4:	7d000b93          	li	s7,2000
    66f8:	036bde3b          	divuw	t3,s7,s6
    66fc:	4781                	li	a5,0
    66fe:	ffc42423          	sw	t3,-24(s0)
    6702:	0c0f13e3          	bnez	t5,6fc8 <perf_monitor_end+0x860>
    6706:	21c7988b          	th.mula	a7,a5,t3
    670a:	ff143023          	sd	a7,-32(s0)
    670e:	ff042683          	lw	a3,-16(s0)
    6712:	0016f293          	andi	t0,a3,1
    6716:	00028e63          	beqz	t0,6732 <main+0x102>
    671a:	fc041603          	lh	a2,-64(s0)
    671e:	fe842503          	lw	a0,-24(s0)
    6722:	fd043583          	ld	a1,-48(s0)
    6726:	c8bfa0ef          	jal	13b0 <core_list_init>
    672a:	ff042683          	lw	a3,-16(s0)
    672e:	fea43c23          	sd	a0,-8(s0)
    6732:	0026f713          	andi	a4,a3,2
    6736:	10071b63          	bnez	a4,684c <perf_monitor_end+0xe4>
    673a:	0046f313          	andi	t1,a3,4
    673e:	00030a63          	beqz	t1,6752 <main+0x122>
    6742:	fc041583          	lh	a1,-64(s0)
    6746:	fe842503          	lw	a0,-24(s0)
    674a:	fe043603          	ld	a2,-32(s0)
    674e:	e02fd0ef          	jal	3d50 <core_init_state>
    6752:	fec42883          	lw	a7,-20(s0)
    6756:	12088663          	beqz	a7,6882 <perf_monitor_end+0x11a>
    675a:	00041937          	lui	s2,0x41
    675e:	02090c13          	addi	s8,s2,32 # 41020 <Loop_Num>

0000000000006762 <perf_monitor_start>:
    6762:	0088                	addi	a0,sp,64
    6764:	cedff0ef          	jal	6450 <iterate>

0000000000006768 <perf_monitor_end>:
    6768:	000c2603          	lw	a2,0(s8)
    676c:	fc041503          	lh	a0,-64(s0)
    6770:	4581                	li	a1,0
    6772:	fff64913          	not	s2,a2
    6776:	84afe0ef          	jal	47c0 <crc16>
    677a:	85aa                	mv	a1,a0
    677c:	fc241503          	lh	a0,-62(s0)
    6780:	840fe0ef          	jal	47c0 <crc16>
    6784:	85aa                	mv	a1,a0
    6786:	fc441503          	lh	a0,-60(s0)
    678a:	836fe0ef          	jal	47c0 <crc16>
    678e:	85aa                	mv	a1,a0
    6790:	fe841503          	lh	a0,-24(s0)
    6794:	82cfe0ef          	jal	47c0 <crc16>
    6798:	6821                	lui	a6,0x8
    679a:	0005099b          	sext.w	s3,a0
    679e:	b0580893          	addi	a7,a6,-1275 # 7b05 <_ftoa+0x9f5>
    67a2:	0f1984e3          	beq	s3,a7,708a <perf_monitor_end+0x922>
    67a6:	2d38e963          	bltu	a7,s3,6a78 <perf_monitor_end+0x310>
    67aa:	6a09                	lui	s4,0x2
    67ac:	8f2a0c93          	addi	s9,s4,-1806 # 18f2 <core_list_mergesort+0x52>
    67b0:	0b9989e3          	beq	s3,s9,7062 <perf_monitor_end+0x8fa>
    67b4:	6f95                	lui	t6,0x5
    67b6:	eaff8493          	addi	s1,t6,-337 # 4eaf <ecvt+0x51f>
    67ba:	3e999163          	bne	s3,s1,6b9c <perf_monitor_end+0x434>
    67be:	67c1                	lui	a5,0x10
    67c0:	6f878513          	addi	a0,a5,1784 # 106f8 <__errno+0x1cc>
    67c4:	03d080ef          	jal	f000 <puts>
    67c8:	62b9                	lui	t0,0xe
    67ca:	6715                	lui	a4,0x5
    67cc:	639d                	lui	t2,0x7
    67ce:	5a428693          	addi	a3,t0,1444 # e5a4 <_vsnprintf+0x5a04>
    67d2:	60870313          	addi	t1,a4,1544 # 5608 <ecvtbuf+0x548>
    67d6:	a7938513          	addi	a0,t2,-1415 # 6a79 <perf_monitor_end+0x311>
    67da:	8b36                	mv	s6,a3
    67dc:	ec36                	sd	a3,24(sp)
    67de:	8a9a                	mv	s5,t1
    67e0:	e81a                	sd	t1,16(sp)
    67e2:	8f2a                	mv	t5,a0
    67e4:	e42a                	sd	a0,8(sp)
    67e6:	a4f9                	j	6ab4 <perf_monitor_end+0x34c>
    67e8:	020a0863          	beqz	s4,6818 <perf_monitor_end+0xb0>
    67ec:	002f0d1b          	addiw	s10,t5,2
    67f0:	7d000d93          	li	s11,2000
    67f4:	03adde3b          	divuw	t3,s11,s10
    67f8:	ffc42423          	sw	t3,-24(s0)
    67fc:	7c0f1063          	bnez	t5,6fbc <perf_monitor_end+0x854>
    6800:	4e81                	li	t4,0
    6802:	4f11                	li	t5,4
    6804:	8fc6                	mv	t6,a7
    6806:	21ce9f8b          	th.mula	t6,t4,t3
    680a:	001e8793          	addi	a5,t4,1
    680e:	fdf43c23          	sd	t6,-40(s0)
    6812:	ee0f0ee3          	beqz	t5,670e <main+0xde>
    6816:	bdc5                	j	6706 <main+0xd6>
    6818:	001f0c1b          	addiw	s8,t5,1
    681c:	7d000c93          	li	s9,2000
    6820:	038cde3b          	divuw	t3,s9,s8
    6824:	4e81                	li	t4,0
    6826:	ffc42423          	sw	t3,-24(s0)
    682a:	fc0f0de3          	beqz	t5,6804 <perf_monitor_end+0x9c>
    682e:	4f01                	li	t5,0
    6830:	4e85                	li	t4,1
    6832:	fd143823          	sd	a7,-48(s0)
    6836:	b7f9                	j	6804 <perf_monitor_end+0x9c>
    6838:	7d000a93          	li	s5,2000
    683c:	ff542423          	sw	s5,-24(s0)
    6840:	ec0f07e3          	beqz	t5,670e <main+0xde>
    6844:	fd143823          	sd	a7,-48(s0)
    6848:	b5d9                	j	670e <main+0xde>
    684a:	0001                	nop
    684c:	fc241383          	lh	t2,-62(s0)
    6850:	fc041503          	lh	a0,-64(s0)
    6854:	86a2                	mv	a3,s0
    6856:	0103949b          	slliw	s1,t2,0x10
    685a:	00a4e5b3          	or	a1,s1,a0
    685e:	0005861b          	sext.w	a2,a1
    6862:	fe842503          	lw	a0,-24(s0)
    6866:	fd843583          	ld	a1,-40(s0)
    686a:	926fc0ef          	jal	2990 <core_init_matrix>
    686e:	ff042603          	lw	a2,-16(s0)
    6872:	00467813          	andi	a6,a2,4
    6876:	ec0816e3          	bnez	a6,6742 <main+0x112>
    687a:	fec42883          	lw	a7,-20(s0)
    687e:	ec089ee3          	bnez	a7,675a <main+0x12a>
    6882:	6dc5                	lui	s11,0x11
    6884:	c20da407          	flw	fs0,-992(s11) # 10c20 <errpat+0xd8>
    6888:	4985                	li	s3,1
    688a:	00041a37          	lui	s4,0x41
    688e:	6ac1                	lui	s5,0x10
    6890:	6bc1                	lui	s7,0x10
    6892:	020a0c13          	addi	s8,s4,32 # 41020 <Loop_Num>
    6896:	04010c93          	addi	s9,sp,64
    689a:	618a8b13          	addi	s6,s5,1560 # 10618 <__errno+0xec>
    689e:	660b8d13          	addi	s10,s7,1632 # 10660 <__errno+0x134>
    68a2:	ff342623          	sw	s3,-20(s0)
    68a6:	0001                	nop
    68a8:	fec42e03          	lw	t3,-20(s0)
    68ac:	02043023          	sd	zero,32(s0)
    68b0:	002e1e9b          	slliw	t4,t3,0x2
    68b4:	01ce8f3b          	addw	t5,t4,t3
    68b8:	001f191b          	slliw	s2,t5,0x1
    68bc:	ff242623          	sw	s2,-20(s0)
    68c0:	671080ef          	jal	f730 <get_vtimer>
    68c4:	00ac2223          	sw	a0,4(s8)
    68c8:	14090a63          	beqz	s2,6a1c <perf_monitor_end+0x2b4>
    68cc:	4585                	li	a1,1
    68ce:	8566                	mv	a0,s9
    68d0:	860fa0ef          	jal	930 <core_bench_list>
    68d4:	02045583          	lhu	a1,32(s0)
    68d8:	4489                	li	s1,2
    68da:	9d7fd0ef          	jal	42b0 <crcu16>
    68de:	02a41023          	sh	a0,32(s0)
    68e2:	55fd                	li	a1,-1
    68e4:	8566                	mv	a0,s9
    68e6:	84afa0ef          	jal	930 <core_bench_list>
    68ea:	02045583          	lhu	a1,32(s0)
    68ee:	9c3fd0ef          	jal	42b0 <crcu16>
    68f2:	ffe90f93          	addi	t6,s2,-2
    68f6:	02a41023          	sh	a0,32(s0)
    68fa:	02a41123          	sh	a0,34(s0)
    68fe:	4585                	li	a1,1
    6900:	8566                	mv	a0,s9
    6902:	003ff993          	andi	s3,t6,3
    6906:	82afa0ef          	jal	930 <core_bench_list>
    690a:	02045583          	lhu	a1,32(s0)
    690e:	9a3fd0ef          	jal	42b0 <crcu16>
    6912:	02a41023          	sh	a0,32(s0)
    6916:	55fd                	li	a1,-1
    6918:	8566                	mv	a0,s9
    691a:	816fa0ef          	jal	930 <core_bench_list>
    691e:	02045583          	lhu	a1,32(s0)
    6922:	98ffd0ef          	jal	42b0 <crcu16>
    6926:	02a41023          	sh	a0,32(s0)
    692a:	0f24f963          	bgeu	s1,s2,6a1c <perf_monitor_end+0x2b4>
    692e:	08098963          	beqz	s3,69c0 <perf_monitor_end+0x258>
    6932:	4585                	li	a1,1
    6934:	04b98f63          	beq	s3,a1,6992 <perf_monitor_end+0x22a>
    6938:	02998863          	beq	s3,s1,6968 <perf_monitor_end+0x200>
    693c:	8566                	mv	a0,s9
    693e:	ff3f90ef          	jal	930 <core_bench_list>
    6942:	02045583          	lhu	a1,32(s0)
    6946:	448d                	li	s1,3
    6948:	969fd0ef          	jal	42b0 <crcu16>
    694c:	02a41023          	sh	a0,32(s0)
    6950:	55fd                	li	a1,-1
    6952:	8566                	mv	a0,s9
    6954:	fddf90ef          	jal	930 <core_bench_list>
    6958:	02045583          	lhu	a1,32(s0)
    695c:	955fd0ef          	jal	42b0 <crcu16>
    6960:	02a41023          	sh	a0,32(s0)
    6964:	00000013          	nop
    6968:	4585                	li	a1,1
    696a:	8566                	mv	a0,s9
    696c:	fc5f90ef          	jal	930 <core_bench_list>
    6970:	02045583          	lhu	a1,32(s0)
    6974:	2485                	addiw	s1,s1,1
    6976:	93bfd0ef          	jal	42b0 <crcu16>
    697a:	02a41023          	sh	a0,32(s0)
    697e:	55fd                	li	a1,-1
    6980:	8566                	mv	a0,s9
    6982:	faff90ef          	jal	930 <core_bench_list>
    6986:	02045583          	lhu	a1,32(s0)
    698a:	927fd0ef          	jal	42b0 <crcu16>
    698e:	02a41023          	sh	a0,32(s0)
    6992:	4585                	li	a1,1
    6994:	8566                	mv	a0,s9
    6996:	f9bf90ef          	jal	930 <core_bench_list>
    699a:	02045583          	lhu	a1,32(s0)
    699e:	2485                	addiw	s1,s1,1
    69a0:	911fd0ef          	jal	42b0 <crcu16>
    69a4:	02a41023          	sh	a0,32(s0)
    69a8:	55fd                	li	a1,-1
    69aa:	8566                	mv	a0,s9
    69ac:	f85f90ef          	jal	930 <core_bench_list>
    69b0:	02045583          	lhu	a1,32(s0)
    69b4:	8fdfd0ef          	jal	42b0 <crcu16>
    69b8:	02a41023          	sh	a0,32(s0)
    69bc:	0724f063          	bgeu	s1,s2,6a1c <perf_monitor_end+0x2b4>
    69c0:	4585                	li	a1,1
    69c2:	8566                	mv	a0,s9
    69c4:	f6df90ef          	jal	930 <core_bench_list>
    69c8:	02045583          	lhu	a1,32(s0)
    69cc:	00148a1b          	addiw	s4,s1,1
    69d0:	001a049b          	addiw	s1,s4,1
    69d4:	8ddfd0ef          	jal	42b0 <crcu16>
    69d8:	02a41023          	sh	a0,32(s0)
    69dc:	55fd                	li	a1,-1
    69de:	8566                	mv	a0,s9
    69e0:	f51f90ef          	jal	930 <core_bench_list>
    69e4:	02045583          	lhu	a1,32(s0)
    69e8:	8c9fd0ef          	jal	42b0 <crcu16>
    69ec:	02a41023          	sh	a0,32(s0)
    69f0:	4585                	li	a1,1
    69f2:	8566                	mv	a0,s9
    69f4:	f3df90ef          	jal	930 <core_bench_list>
    69f8:	02045583          	lhu	a1,32(s0)
    69fc:	8b5fd0ef          	jal	42b0 <crcu16>
    6a00:	02a41023          	sh	a0,32(s0)
    6a04:	55fd                	li	a1,-1
    6a06:	8566                	mv	a0,s9
    6a08:	f29f90ef          	jal	930 <core_bench_list>
    6a0c:	02045583          	lhu	a1,32(s0)
    6a10:	8a1fd0ef          	jal	42b0 <crcu16>
    6a14:	02a41023          	sh	a0,32(s0)
    6a18:	bf81                	j	6968 <perf_monitor_end+0x200>
    6a1a:	0001                	nop
    6a1c:	515080ef          	jal	f730 <get_vtimer>
    6a20:	004c2783          	lw	a5,4(s8)
    6a24:	85ca                	mv	a1,s2
    6a26:	40f502bb          	subw	t0,a0,a5
    6a2a:	0322d63b          	divuw	a2,t0,s2
    6a2e:	e2cc550b          	th.swd	a0,a2,(s8),1,3
    6a32:	855a                	mv	a0,s6
    6a34:	67c080ef          	jal	f0b0 <printf>
    6a38:	00cc2683          	lw	a3,12(s8)
    6a3c:	856a                	mv	a0,s10
    6a3e:	d006f7d3          	fcvt.s.w	fa5,a3
    6a42:	18f47053          	fdiv.s	ft0,fs0,fa5
    6a46:	420000d3          	fcvt.d.s	ft1,ft0
    6a4a:	e20085d3          	fmv.x.d	a1,ft1
    6a4e:	662080ef          	jal	f0b0 <printf>
    6a52:	4ef080ef          	jal	f740 <sim_end>
    6a56:	4501                	li	a0,0
    6a58:	9a9fc0ef          	jal	3400 <time_in_secs>
    6a5c:	e40506e3          	beqz	a0,68a8 <perf_monitor_end+0x140>
    6a60:	4729                	li	a4,10
    6a62:	02a7533b          	divuw	t1,a4,a0
    6a66:	fec42503          	lw	a0,-20(s0)
    6a6a:	0013039b          	addiw	t2,t1,1
    6a6e:	02a385bb          	mulw	a1,t2,a0
    6a72:	feb42623          	sw	a1,-20(s0)
    6a76:	b1f5                	j	6762 <perf_monitor_start>
    6a78:	6b25                	lui	s6,0x9
    6a7a:	a02b0e13          	addi	t3,s6,-1534 # 8a02 <_ftoa+0x18f2>
    6a7e:	5bc98d63          	beq	s3,t3,7038 <perf_monitor_end+0x8d0>
    6a82:	673d                	lui	a4,0xf
    6a84:	9f570313          	addi	t1,a4,-1547 # e9f5 <_vsnprintf+0x5e55>
    6a88:	10699a63          	bne	s3,t1,6b9c <perf_monitor_end+0x434>
    6a8c:	63c1                	lui	t2,0x10
    6a8e:	72838513          	addi	a0,t2,1832 # 10728 <__errno+0x1fc>
    6a92:	56e080ef          	jal	f000 <puts>
    6a96:	6525                	lui	a0,0x9
    6a98:	6609                	lui	a2,0x2
    6a9a:	68b9                	lui	a7,0xe
    6a9c:	e3a50593          	addi	a1,a0,-454 # 8e3a <_vsnprintf+0x29a>
    6aa0:	fd760813          	addi	a6,a2,-41 # 1fd7 <matrix_test+0x477>
    6aa4:	71488c13          	addi	s8,a7,1812 # e714 <_vsnprintf+0x5b74>
    6aa8:	8b2e                	mv	s6,a1
    6aaa:	ec2e                	sd	a1,24(sp)
    6aac:	8ac2                	mv	s5,a6
    6aae:	e842                	sd	a6,16(sp)
    6ab0:	8f62                	mv	t5,s8
    6ab2:	e462                	sd	s8,8(sp)
    6ab4:	000404b7          	lui	s1,0x40
    6ab8:	0084a583          	lw	a1,8(s1) # 40008 <default_num_contexts>
    6abc:	5e058c63          	beqz	a1,70b4 <perf_monitor_end+0x94c>
    6ac0:	6641                	lui	a2,0x10
    6ac2:	68c1                	lui	a7,0x10
    6ac4:	6e41                	lui	t3,0x10
    6ac6:	78860813          	addi	a6,a2,1928 # 10788 <__errno+0x25c>
    6aca:	7b888b93          	addi	s7,a7,1976 # 107b8 <__errno+0x28c>
    6ace:	7f0e0e93          	addi	t4,t3,2032 # 107f0 <__errno+0x2c4>
    6ad2:	4d81                	li	s11,0
    6ad4:	4d01                	li	s10,0
    6ad6:	4c81                	li	s9,0
    6ad8:	000f0a1b          	sext.w	s4,t5
    6adc:	f042                	sd	a6,32(sp)
    6ade:	f45e                	sd	s7,40(sp)
    6ae0:	f876                	sd	t4,48(sp)
    6ae2:	a01d                	j	6b08 <perf_monitor_end+0x3a0>
    6ae4:	01c40cb3          	add	s9,s0,t3
    6ae8:	028cdf83          	lhu	t6,40(s9)
    6aec:	0084a783          	lw	a5,8(s1)
    6af0:	2d05                	addiw	s10,s10,1
    6af2:	01fd8dbb          	addw	s11,s11,t6
    6af6:	3c0d3d0b          	th.extu	s10,s10,15,0
    6afa:	3c0dbc0b          	th.extu	s8,s11,15,0
    6afe:	8cea                	mv	s9,s10
    6b00:	3c0dad8b          	th.ext	s11,s11,15,0
    6b04:	0afd7263          	bgeu	s10,a5,6ba8 <perf_monitor_end+0x440>
    6b08:	003c9b93          	slli	s7,s9,0x3
    6b0c:	419b8f33          	sub	t5,s7,s9
    6b10:	004f1f93          	slli	t6,t5,0x4
    6b14:	01f40c33          	add	s8,s0,t6
    6b18:	ff0c2803          	lw	a6,-16(s8)
    6b1c:	020c1423          	sh	zero,40(s8)
    6b20:	00187793          	andi	a5,a6,1
    6b24:	c395                	beqz	a5,6b48 <perf_monitor_end+0x3e0>
    6b26:	022c5603          	lhu	a2,34(s8)
    6b2a:	01460f63          	beq	a2,s4,6b48 <perf_monitor_end+0x3e0>
    6b2e:	66a2                	ld	a3,8(sp)
    6b30:	7502                	ld	a0,32(sp)
    6b32:	85e6                	mv	a1,s9
    6b34:	57c080ef          	jal	f0b0 <printf>
    6b38:	028c5283          	lhu	t0,40(s8)
    6b3c:	ff0c2803          	lw	a6,-16(s8)
    6b40:	0012869b          	addiw	a3,t0,1
    6b44:	02dc1423          	sh	a3,40(s8)
    6b48:	00287713          	andi	a4,a6,2
    6b4c:	cb05                	beqz	a4,6b7c <perf_monitor_end+0x414>
    6b4e:	419b8333          	sub	t1,s7,s9
    6b52:	00431393          	slli	t2,t1,0x4
    6b56:	00740c33          	add	s8,s0,t2
    6b5a:	024c5603          	lhu	a2,36(s8)
    6b5e:	01560f63          	beq	a2,s5,6b7c <perf_monitor_end+0x414>
    6b62:	66c2                	ld	a3,16(sp)
    6b64:	7522                	ld	a0,40(sp)
    6b66:	85e6                	mv	a1,s9
    6b68:	548080ef          	jal	f0b0 <printf>
    6b6c:	028c5503          	lhu	a0,40(s8)
    6b70:	ff0c2803          	lw	a6,-16(s8)
    6b74:	0015059b          	addiw	a1,a0,1
    6b78:	02bc1423          	sh	a1,40(s8)
    6b7c:	419b88b3          	sub	a7,s7,s9
    6b80:	00487613          	andi	a2,a6,4
    6b84:	00489e13          	slli	t3,a7,0x4
    6b88:	de31                	beqz	a2,6ae4 <perf_monitor_end+0x37c>
    6b8a:	01c40bb3          	add	s7,s0,t3
    6b8e:	026bd603          	lhu	a2,38(s7)
    6b92:	45661163          	bne	a2,s6,6fd4 <perf_monitor_end+0x86c>
    6b96:	028bdf83          	lhu	t6,40(s7)
    6b9a:	bf89                	j	6aec <perf_monitor_end+0x384>
    6b9c:	6c41                	lui	s8,0x10
    6b9e:	3c7d                	addiw	s8,s8,-1 # ffff <_malloc_trim_r+0x55>
    6ba0:	000404b7          	lui	s1,0x40
    6ba4:	00000013          	nop
    6ba8:	dd9fd0ef          	jal	4980 <check_data_types>
    6bac:	fe842583          	lw	a1,-24(s0)
    6bb0:	6ac5                	lui	s5,0x11
    6bb2:	01850b3b          	addw	s6,a0,s8
    6bb6:	820a8513          	addi	a0,s5,-2016 # 10820 <__errno+0x2f4>
    6bba:	4f6080ef          	jal	f0b0 <printf>
    6bbe:	62c5                	lui	t0,0x11
    6bc0:	85ca                	mv	a1,s2
    6bc2:	83828513          	addi	a0,t0,-1992 # 10838 <__errno+0x30c>
    6bc6:	4ea080ef          	jal	f0b0 <printf>
    6bca:	854a                	mv	a0,s2
    6bcc:	835fc0ef          	jal	3400 <time_in_secs>
    6bd0:	66c5                	lui	a3,0x11
    6bd2:	85aa                	mv	a1,a0
    6bd4:	85068513          	addi	a0,a3,-1968 # 10850 <__errno+0x324>
    6bd8:	4d8080ef          	jal	f0b0 <printf>
    6bdc:	854a                	mv	a0,s2
    6bde:	3c0b3a0b          	th.extu	s4,s6,15,0
    6be2:	81ffc0ef          	jal	3400 <time_in_secs>
    6be6:	42051263          	bnez	a0,700a <perf_monitor_end+0x8a2>
    6bea:	854a                	mv	a0,s2
    6bec:	815fc0ef          	jal	3400 <time_in_secs>
    6bf0:	4925                	li	s2,9
    6bf2:	40a97563          	bgeu	s2,a0,6ffc <perf_monitor_end+0x894>
    6bf6:	fec42603          	lw	a2,-20(s0)
    6bfa:	0084a583          	lw	a1,8(s1) # 40008 <default_num_contexts>
    6bfe:	6845                	lui	a6,0x11
    6c00:	8c080513          	addi	a0,a6,-1856 # 108c0 <__errno+0x394>
    6c04:	02c585bb          	mulw	a1,a1,a2
    6c08:	6dc5                	lui	s11,0x11
    6c0a:	3c0a2b8b          	th.ext	s7,s4,15,0
    6c0e:	4a2080ef          	jal	f0b0 <printf>
    6c12:	68c5                	lui	a7,0x11
    6c14:	6e45                	lui	t3,0x11
    6c16:	8d888593          	addi	a1,a7,-1832 # 108d8 <__errno+0x3ac>
    6c1a:	8f0e0513          	addi	a0,t3,-1808 # 108f0 <__errno+0x3c4>
    6c1e:	492080ef          	jal	f0b0 <printf>
    6c22:	6ec5                	lui	t4,0x11
    6c24:	6f45                	lui	t5,0x11
    6c26:	908e8593          	addi	a1,t4,-1784 # 10908 <__errno+0x3dc>
    6c2a:	910f0513          	addi	a0,t5,-1776 # 10910 <__errno+0x3e4>
    6c2e:	482080ef          	jal	f0b0 <printf>
    6c32:	6fc5                	lui	t6,0x11
    6c34:	928f8593          	addi	a1,t6,-1752 # 10928 <__errno+0x3fc>
    6c38:	930d8513          	addi	a0,s11,-1744 # 10930 <__errno+0x404>
    6c3c:	474080ef          	jal	f0b0 <printf>
    6c40:	85ce                	mv	a1,s3
    6c42:	69c5                	lui	s3,0x11
    6c44:	94898513          	addi	a0,s3,-1720 # 10948 <__errno+0x41c>
    6c48:	468080ef          	jal	f0b0 <printf>
    6c4c:	ff042d03          	lw	s10,-16(s0)
    6c50:	001d7793          	andi	a5,s10,1
    6c54:	c3f1                	beqz	a5,6d18 <perf_monitor_end+0x5b0>
    6c56:	0084ac83          	lw	s9,8(s1)
    6c5a:	0a0c8f63          	beqz	s9,6d18 <perf_monitor_end+0x5b0>
    6c5e:	6b45                	lui	s6,0x11
    6c60:	4c01                	li	s8,0
    6c62:	4581                	li	a1,0
    6c64:	968b0a93          	addi	s5,s6,-1688 # 10968 <__errno+0x43c>
    6c68:	00359293          	slli	t0,a1,0x3
    6c6c:	40b286b3          	sub	a3,t0,a1
    6c70:	00469713          	slli	a4,a3,0x4
    6c74:	00e40333          	add	t1,s0,a4
    6c78:	02235603          	lhu	a2,34(t1)
    6c7c:	8556                	mv	a0,s5
    6c7e:	2c05                	addiw	s8,s8,1
    6c80:	430080ef          	jal	f0b0 <printf>
    6c84:	0084a383          	lw	t2,8(s1)
    6c88:	3c0c390b          	th.extu	s2,s8,15,0
    6c8c:	85ca                	mv	a1,s2
    6c8e:	08797563          	bgeu	s2,t2,6d18 <perf_monitor_end+0x5b0>
    6c92:	00391513          	slli	a0,s2,0x3
    6c96:	41250a33          	sub	s4,a0,s2
    6c9a:	004a1813          	slli	a6,s4,0x4
    6c9e:	01040633          	add	a2,s0,a6
    6ca2:	02265603          	lhu	a2,34(a2)
    6ca6:	8556                	mv	a0,s5
    6ca8:	408080ef          	jal	f0b0 <printf>
    6cac:	0084a883          	lw	a7,8(s1)
    6cb0:	0019059b          	addiw	a1,s2,1
    6cb4:	3c05bd8b          	th.extu	s11,a1,15,0
    6cb8:	85ee                	mv	a1,s11
    6cba:	051dff63          	bgeu	s11,a7,6d18 <perf_monitor_end+0x5b0>
    6cbe:	003d9e13          	slli	t3,s11,0x3
    6cc2:	41be0eb3          	sub	t4,t3,s11
    6cc6:	004e9f13          	slli	t5,t4,0x4
    6cca:	01e40fb3          	add	t6,s0,t5
    6cce:	022fd603          	lhu	a2,34(t6)
    6cd2:	8556                	mv	a0,s5
    6cd4:	001d899b          	addiw	s3,s11,1
    6cd8:	3d8080ef          	jal	f0b0 <printf>
    6cdc:	0084a783          	lw	a5,8(s1)
    6ce0:	3c09bd0b          	th.extu	s10,s3,15,0
    6ce4:	85ea                	mv	a1,s10
    6ce6:	02fd7963          	bgeu	s10,a5,6d18 <perf_monitor_end+0x5b0>
    6cea:	003d1c93          	slli	s9,s10,0x3
    6cee:	41ac8b33          	sub	s6,s9,s10
    6cf2:	004b1293          	slli	t0,s6,0x4
    6cf6:	005406b3          	add	a3,s0,t0
    6cfa:	0226d603          	lhu	a2,34(a3)
    6cfe:	8556                	mv	a0,s5
    6d00:	3b0080ef          	jal	f0b0 <printf>
    6d04:	0084a303          	lw	t1,8(s1)
    6d08:	001d071b          	addiw	a4,s10,1
    6d0c:	3c073c0b          	th.extu	s8,a4,15,0
    6d10:	85e2                	mv	a1,s8
    6d12:	f46c6be3          	bltu	s8,t1,6c68 <perf_monitor_end+0x500>
    6d16:	0001                	nop
    6d18:	ff042a83          	lw	s5,-16(s0)
    6d1c:	002af913          	andi	s2,s5,2
    6d20:	0c090463          	beqz	s2,6de8 <perf_monitor_end+0x680>
    6d24:	0084a383          	lw	t2,8(s1)
    6d28:	38038863          	beqz	t2,70b8 <perf_monitor_end+0x950>
    6d2c:	6a45                	lui	s4,0x11
    6d2e:	4981                	li	s3,0
    6d30:	4581                	li	a1,0
    6d32:	988a0d93          	addi	s11,s4,-1656 # 10988 <__errno+0x45c>
    6d36:	00359813          	slli	a6,a1,0x3
    6d3a:	40b80633          	sub	a2,a6,a1
    6d3e:	00461893          	slli	a7,a2,0x4
    6d42:	01140e33          	add	t3,s0,a7
    6d46:	024e5603          	lhu	a2,36(t3)
    6d4a:	856e                	mv	a0,s11
    6d4c:	364080ef          	jal	f0b0 <printf>
    6d50:	0084ae83          	lw	t4,8(s1)
    6d54:	0019859b          	addiw	a1,s3,1
    6d58:	3c05b98b          	th.extu	s3,a1,15,0
    6d5c:	85ce                	mv	a1,s3
    6d5e:	09d9f563          	bgeu	s3,t4,6de8 <perf_monitor_end+0x680>
    6d62:	00399f13          	slli	t5,s3,0x3
    6d66:	413f0fb3          	sub	t6,t5,s3
    6d6a:	004f9d13          	slli	s10,t6,0x4
    6d6e:	01a407b3          	add	a5,s0,s10
    6d72:	0247d603          	lhu	a2,36(a5)
    6d76:	856e                	mv	a0,s11
    6d78:	00198c9b          	addiw	s9,s3,1
    6d7c:	334080ef          	jal	f0b0 <printf>
    6d80:	0084a283          	lw	t0,8(s1)
    6d84:	3c0cbb0b          	th.extu	s6,s9,15,0
    6d88:	85da                	mv	a1,s6
    6d8a:	045b7f63          	bgeu	s6,t0,6de8 <perf_monitor_end+0x680>
    6d8e:	003b1693          	slli	a3,s6,0x3
    6d92:	41668733          	sub	a4,a3,s6
    6d96:	00471c13          	slli	s8,a4,0x4
    6d9a:	01840333          	add	t1,s0,s8
    6d9e:	02435603          	lhu	a2,36(t1)
    6da2:	856e                	mv	a0,s11
    6da4:	001b0a9b          	addiw	s5,s6,1
    6da8:	308080ef          	jal	f0b0 <printf>
    6dac:	0084a383          	lw	t2,8(s1)
    6db0:	3c0ab90b          	th.extu	s2,s5,15,0
    6db4:	85ca                	mv	a1,s2
    6db6:	02797963          	bgeu	s2,t2,6de8 <perf_monitor_end+0x680>
    6dba:	00391513          	slli	a0,s2,0x3
    6dbe:	41250a33          	sub	s4,a0,s2
    6dc2:	004a1813          	slli	a6,s4,0x4
    6dc6:	01040633          	add	a2,s0,a6
    6dca:	02465603          	lhu	a2,36(a2)
    6dce:	856e                	mv	a0,s11
    6dd0:	2e0080ef          	jal	f0b0 <printf>
    6dd4:	0084ae03          	lw	t3,8(s1)
    6dd8:	0019089b          	addiw	a7,s2,1
    6ddc:	3c08b98b          	th.extu	s3,a7,15,0
    6de0:	85ce                	mv	a1,s3
    6de2:	f5c9eae3          	bltu	s3,t3,6d36 <perf_monitor_end+0x5ce>
    6de6:	0001                	nop
    6de8:	ff042d83          	lw	s11,-16(s0)
    6dec:	004df593          	andi	a1,s11,4
    6df0:	c5e1                	beqz	a1,6eb8 <perf_monitor_end+0x750>
    6df2:	0084ae83          	lw	t4,8(s1)
    6df6:	180e8163          	beqz	t4,6f78 <perf_monitor_end+0x810>
    6dfa:	6f45                	lui	t5,0x11
    6dfc:	4c01                	li	s8,0
    6dfe:	4581                	li	a1,0
    6e00:	9a8f0d13          	addi	s10,t5,-1624 # 109a8 <__errno+0x47c>
    6e04:	00359f93          	slli	t6,a1,0x3
    6e08:	40bf87b3          	sub	a5,t6,a1
    6e0c:	00479c93          	slli	s9,a5,0x4
    6e10:	01940b33          	add	s6,s0,s9
    6e14:	026b5603          	lhu	a2,38(s6)
    6e18:	856a                	mv	a0,s10
    6e1a:	296080ef          	jal	f0b0 <printf>
    6e1e:	0084a683          	lw	a3,8(s1)
    6e22:	001c029b          	addiw	t0,s8,1
    6e26:	3c02bc0b          	th.extu	s8,t0,15,0
    6e2a:	85e2                	mv	a1,s8
    6e2c:	08dc7663          	bgeu	s8,a3,6eb8 <perf_monitor_end+0x750>
    6e30:	003c1713          	slli	a4,s8,0x3
    6e34:	41870333          	sub	t1,a4,s8
    6e38:	00431a93          	slli	s5,t1,0x4
    6e3c:	01540933          	add	s2,s0,s5
    6e40:	02695603          	lhu	a2,38(s2)
    6e44:	856a                	mv	a0,s10
    6e46:	26a080ef          	jal	f0b0 <printf>
    6e4a:	0084a503          	lw	a0,8(s1)
    6e4e:	001c039b          	addiw	t2,s8,1
    6e52:	3c03ba0b          	th.extu	s4,t2,15,0
    6e56:	85d2                	mv	a1,s4
    6e58:	06aa7063          	bgeu	s4,a0,6eb8 <perf_monitor_end+0x750>
    6e5c:	003a1813          	slli	a6,s4,0x3
    6e60:	41480633          	sub	a2,a6,s4
    6e64:	00461893          	slli	a7,a2,0x4
    6e68:	011409b3          	add	s3,s0,a7
    6e6c:	0269d603          	lhu	a2,38(s3)
    6e70:	856a                	mv	a0,s10
    6e72:	23e080ef          	jal	f0b0 <printf>
    6e76:	0084ae83          	lw	t4,8(s1)
    6e7a:	001a0e1b          	addiw	t3,s4,1
    6e7e:	3c0e3d8b          	th.extu	s11,t3,15,0
    6e82:	85ee                	mv	a1,s11
    6e84:	03ddfa63          	bgeu	s11,t4,6eb8 <perf_monitor_end+0x750>
    6e88:	003d9f13          	slli	t5,s11,0x3
    6e8c:	41bf0fb3          	sub	t6,t5,s11
    6e90:	004f9793          	slli	a5,t6,0x4
    6e94:	00f40cb3          	add	s9,s0,a5
    6e98:	026cd603          	lhu	a2,38(s9)
    6e9c:	856a                	mv	a0,s10
    6e9e:	212080ef          	jal	f0b0 <printf>
    6ea2:	0084ab03          	lw	s6,8(s1)
    6ea6:	001d859b          	addiw	a1,s11,1
    6eaa:	3c05bc0b          	th.extu	s8,a1,15,0
    6eae:	85e2                	mv	a1,s8
    6eb0:	f56c6ae3          	bltu	s8,s6,6e04 <perf_monitor_end+0x69c>
    6eb4:	00000013          	nop
    6eb8:	0084ad03          	lw	s10,8(s1)
    6ebc:	0a0d0e63          	beqz	s10,6f78 <perf_monitor_end+0x810>
    6ec0:	62c5                	lui	t0,0x11
    6ec2:	4901                	li	s2,0
    6ec4:	4581                	li	a1,0
    6ec6:	9c828a93          	addi	s5,t0,-1592 # 109c8 <__errno+0x49c>
    6eca:	00359693          	slli	a3,a1,0x3
    6ece:	40b68733          	sub	a4,a3,a1
    6ed2:	00471313          	slli	t1,a4,0x4
    6ed6:	006403b3          	add	t2,s0,t1
    6eda:	0203d603          	lhu	a2,32(t2)
    6ede:	8556                	mv	a0,s5
    6ee0:	2905                	addiw	s2,s2,1
    6ee2:	1ce080ef          	jal	f0b0 <printf>
    6ee6:	0084a503          	lw	a0,8(s1)
    6eea:	3c093a0b          	th.extu	s4,s2,15,0
    6eee:	85d2                	mv	a1,s4
    6ef0:	08aa7463          	bgeu	s4,a0,6f78 <perf_monitor_end+0x810>
    6ef4:	003a1813          	slli	a6,s4,0x3
    6ef8:	41480633          	sub	a2,a6,s4
    6efc:	00461893          	slli	a7,a2,0x4
    6f00:	011409b3          	add	s3,s0,a7
    6f04:	0209d603          	lhu	a2,32(s3)
    6f08:	8556                	mv	a0,s5
    6f0a:	1a6080ef          	jal	f0b0 <printf>
    6f0e:	0084ae83          	lw	t4,8(s1)
    6f12:	001a0e1b          	addiw	t3,s4,1
    6f16:	3c0e3d8b          	th.extu	s11,t3,15,0
    6f1a:	85ee                	mv	a1,s11
    6f1c:	05ddfe63          	bgeu	s11,t4,6f78 <perf_monitor_end+0x810>
    6f20:	003d9f13          	slli	t5,s11,0x3
    6f24:	41bf0fb3          	sub	t6,t5,s11
    6f28:	004f9793          	slli	a5,t6,0x4
    6f2c:	00f40cb3          	add	s9,s0,a5
    6f30:	020cd603          	lhu	a2,32(s9)
    6f34:	8556                	mv	a0,s5
    6f36:	17a080ef          	jal	f0b0 <printf>
    6f3a:	0084ab03          	lw	s6,8(s1)
    6f3e:	001d859b          	addiw	a1,s11,1
    6f42:	3c05bc0b          	th.extu	s8,a1,15,0
    6f46:	85e2                	mv	a1,s8
    6f48:	036c7863          	bgeu	s8,s6,6f78 <perf_monitor_end+0x810>
    6f4c:	003c1d13          	slli	s10,s8,0x3
    6f50:	418d02b3          	sub	t0,s10,s8
    6f54:	00429693          	slli	a3,t0,0x4
    6f58:	00d40733          	add	a4,s0,a3
    6f5c:	02075603          	lhu	a2,32(a4)
    6f60:	8556                	mv	a0,s5
    6f62:	14e080ef          	jal	f0b0 <printf>
    6f66:	0084a383          	lw	t2,8(s1)
    6f6a:	001c031b          	addiw	t1,s8,1
    6f6e:	3c03390b          	th.extu	s2,t1,15,0
    6f72:	85ca                	mv	a1,s2
    6f74:	f4796be3          	bltu	s2,t2,6eca <perf_monitor_end+0x762>
    6f78:	060b8c63          	beqz	s7,6ff0 <perf_monitor_end+0x888>
    6f7c:	0b705863          	blez	s7,702c <perf_monitor_end+0x8c4>
    6f80:	6bc5                	lui	s7,0x11
    6f82:	a38b8513          	addi	a0,s7,-1480 # 10a38 <__errno+0x50c>
    6f86:	07a080ef          	jal	f000 <puts>
    6f8a:	0aa10513          	addi	a0,sp,170
    6f8e:	ca2fc0ef          	jal	3430 <portable_fini>
    6f92:	7ae080ef          	jal	f740 <sim_end>
    6f96:	7f010113          	addi	sp,sp,2032
    6f9a:	60b2                	ld	ra,264(sp)
    6f9c:	7daa                	ld	s11,168(sp)
    6f9e:	7d4a                	ld	s10,176(sp)
    6fa0:	7cea                	ld	s9,184(sp)
    6fa2:	6c0e                	ld	s8,192(sp)
    6fa4:	6bae                	ld	s7,200(sp)
    6fa6:	6b4e                	ld	s6,208(sp)
    6fa8:	6aee                	ld	s5,216(sp)
    6faa:	7a0e                	ld	s4,224(sp)
    6fac:	79ae                	ld	s3,232(sp)
    6fae:	794e                	ld	s2,240(sp)
    6fb0:	74ee                	ld	s1,248(sp)
    6fb2:	6412                	ld	s0,256(sp)
    6fb4:	246a                	fld	fs0,152(sp)
    6fb6:	4501                	li	a0,0
    6fb8:	6151                	addi	sp,sp,272
    6fba:	8082                	ret
    6fbc:	4e85                	li	t4,1
    6fbe:	4f11                	li	t5,4
    6fc0:	fd143823          	sd	a7,-48(s0)
    6fc4:	841ff06f          	j	6804 <perf_monitor_end+0x9c>
    6fc8:	4785                	li	a5,1
    6fca:	fd143823          	sd	a7,-48(s0)
    6fce:	f38ff06f          	j	6706 <main+0xd6>
    6fd2:	0001                	nop
    6fd4:	66e2                	ld	a3,24(sp)
    6fd6:	7542                	ld	a0,48(sp)
    6fd8:	85e6                	mv	a1,s9
    6fda:	0d6080ef          	jal	f0b0 <printf>
    6fde:	028bde83          	lhu	t4,40(s7)
    6fe2:	001e8f1b          	addiw	t5,t4,1
    6fe6:	3c0f3f8b          	th.extu	t6,t5,15,0
    6fea:	03fb9423          	sh	t6,40(s7)
    6fee:	bcfd                	j	6aec <perf_monitor_end+0x384>
    6ff0:	6ac5                	lui	s5,0x11
    6ff2:	9e8a8513          	addi	a0,s5,-1560 # 109e8 <__errno+0x4bc>
    6ff6:	00a080ef          	jal	f000 <puts>
    6ffa:	bf41                	j	6f8a <perf_monitor_end+0x822>
    6ffc:	6545                	lui	a0,0x11
    6ffe:	88050513          	addi	a0,a0,-1920 # 10880 <__errno+0x354>
    7002:	7ff070ef          	jal	f000 <puts>
    7006:	2a05                	addiw	s4,s4,1
    7008:	b6fd                	j	6bf6 <perf_monitor_end+0x48e>
    700a:	0084a703          	lw	a4,8(s1)
    700e:	fec42303          	lw	t1,-20(s0)
    7012:	854a                	mv	a0,s2
    7014:	02670c3b          	mulw	s8,a4,t1
    7018:	be8fc0ef          	jal	3400 <time_in_secs>
    701c:	63c5                	lui	t2,0x11
    701e:	02ac55bb          	divuw	a1,s8,a0
    7022:	86838513          	addi	a0,t2,-1944 # 10868 <__errno+0x33c>
    7026:	08a080ef          	jal	f0b0 <printf>
    702a:	b6c1                	j	6bea <perf_monitor_end+0x482>
    702c:	64c5                	lui	s1,0x11
    702e:	a4848513          	addi	a0,s1,-1464 # 10a48 <__errno+0x51c>
    7032:	7cf070ef          	jal	f000 <puts>
    7036:	bf91                	j	6f8a <perf_monitor_end+0x822>
    7038:	6ec1                	lui	t4,0x10
    703a:	698e8513          	addi	a0,t4,1688 # 10698 <__errno+0x16c>
    703e:	7c3070ef          	jal	f000 <puts>
    7042:	6f19                	lui	t5,0x6
    7044:	64b1                	lui	s1,0xc
    7046:	62b5                	lui	t0,0xd
    7048:	e47f0f93          	addi	t6,t5,-441 # 5e47 <fcvtbuf+0x137>
    704c:	e5248793          	addi	a5,s1,-430 # be52 <_vsnprintf+0x32b2>
    7050:	4b028693          	addi	a3,t0,1200 # d4b0 <_vsnprintf+0x4910>
    7054:	8b7e                	mv	s6,t6
    7056:	ec7e                	sd	t6,24(sp)
    7058:	8abe                	mv	s5,a5
    705a:	e83e                	sd	a5,16(sp)
    705c:	8f36                	mv	t5,a3
    705e:	e436                	sd	a3,8(sp)
    7060:	bc91                	j	6ab4 <perf_monitor_end+0x34c>
    7062:	6ac1                	lui	s5,0x10
    7064:	758a8513          	addi	a0,s5,1880 # 10758 <__errno+0x22c>
    7068:	799070ef          	jal	f000 <puts>
    706c:	6ba5                	lui	s7,0x9
    706e:	6e39                	lui	t3,0xe
    7070:	d84b8d13          	addi	s10,s7,-636 # 8d84 <_vsnprintf+0x1e4>
    7074:	74700d93          	li	s11,1863
    7078:	3c1e0e93          	addi	t4,t3,961 # e3c1 <_vsnprintf+0x5821>
    707c:	8b6a                	mv	s6,s10
    707e:	ec6a                	sd	s10,24(sp)
    7080:	8aee                	mv	s5,s11
    7082:	e86e                	sd	s11,16(sp)
    7084:	8f76                	mv	t5,t4
    7086:	e476                	sd	t4,8(sp)
    7088:	b435                	j	6ab4 <perf_monitor_end+0x34c>
    708a:	6a41                	lui	s4,0x10
    708c:	6a85                	lui	s5,0x1
    708e:	6c8a0513          	addi	a0,s4,1736 # 106c8 <__errno+0x19c>
    7092:	6c11                	lui	s8,0x4
    7094:	6d0d                	lui	s10,0x3
    7096:	76b070ef          	jal	f000 <puts>
    709a:	9bfc0c93          	addi	s9,s8,-1601 # 39bf <core_bench_state+0x57f>
    709e:	199a8b93          	addi	s7,s5,409 # 1199 <core_bench_list+0x869>
    70a2:	340d0d93          	addi	s11,s10,832 # 3340 <matrix_mul_matrix_bitextract+0x100>
    70a6:	8b66                	mv	s6,s9
    70a8:	ec66                	sd	s9,24(sp)
    70aa:	8ade                	mv	s5,s7
    70ac:	e85e                	sd	s7,16(sp)
    70ae:	8f6e                	mv	t5,s11
    70b0:	e46e                	sd	s11,8(sp)
    70b2:	b409                	j	6ab4 <perf_monitor_end+0x34c>
    70b4:	4c01                	li	s8,0
    70b6:	bccd                	j	6ba8 <perf_monitor_end+0x440>
    70b8:	004af513          	andi	a0,s5,4
    70bc:	de050ee3          	beqz	a0,6eb8 <perf_monitor_end+0x750>
    70c0:	bd65                	j	6f78 <perf_monitor_end+0x810>
	...

00000000000070d0 <_out_buffer>:
    70d0:	00d67463          	bgeu	a2,a3,70d8 <_out_buffer+0x8>
    70d4:	00c5d50b          	th.srb	a0,a1,a2,0
    70d8:	8082                	ret
    70da:	00000013          	nop
    70de:	0001                	nop

00000000000070e0 <_out_null>:
    70e0:	8082                	ret
    70e2:	0001                	nop
    70e4:	00000013          	nop
    70e8:	00000013          	nop
    70ec:	00000013          	nop

00000000000070f0 <_out_fct>:
    70f0:	c501                	beqz	a0,70f8 <_out_fct+0x8>
    70f2:	619c                	ld	a5,0(a1)
    70f4:	658c                	ld	a1,8(a1)
    70f6:	8782                	jr	a5
    70f8:	8082                	ret
    70fa:	00000013          	nop
    70fe:	0001                	nop

0000000000007100 <_out_char>:
    7100:	e111                	bnez	a0,7104 <_out_char+0x4>
    7102:	8082                	ret
    7104:	55fd                	li	a1,-1
    7106:	adaff06f          	j	63e0 <fputc>
    710a:	00000013          	nop
    710e:	0001                	nop

0000000000007110 <_ftoa>:
    7110:	7135                	addi	sp,sp,-160
    7112:	f4d6                	sd	s5,104(sp)
    7114:	f8d2                	sd	s4,112(sp)
    7116:	8abe                	mv	s5,a5
    7118:	a2a527d3          	feq.d	a5,fa0,fa0
    711c:	fcce                	sd	s3,120(sp)
    711e:	e14a                	sd	s2,128(sp)
    7120:	e526                	sd	s1,136(sp)
    7122:	e922                	sd	s0,144(sp)
    7124:	e4e6                	sd	s9,72(sp)
    7126:	e8e2                	sd	s8,80(sp)
    7128:	ecde                	sd	s7,88(sp)
    712a:	f0da                	sd	s6,96(sp)
    712c:	ed06                	sd	ra,152(sp)
    712e:	842a                	mv	s0,a0
    7130:	84ae                	mv	s1,a1
    7132:	89b2                	mv	s3,a2
    7134:	8936                	mv	s2,a3
    7136:	8a42                	mv	s4,a6
    7138:	4e078c63          	beqz	a5,7630 <_ftoa+0x520>
    713c:	62c5                	lui	t0,0x11
    713e:	b982b787          	fld	fa5,-1128(t0) # 10b98 <errpat+0x50>
    7142:	a2f51353          	flt.d	t1,fa0,fa5
    7146:	520315e3          	bnez	t1,7e70 <_ftoa+0xd60>
    714a:	63c5                	lui	t2,0x11
    714c:	ba03b007          	fld	ft0,-1120(t2) # 10ba0 <errpat+0x58>
    7150:	a2a01553          	flt.d	a0,ft0,fa0
    7154:	1a051a63          	bnez	a0,7308 <_ftoa+0x1f8>
    7158:	65c5                	lui	a1,0x11
    715a:	ba85b087          	fld	ft1,-1112(a1) # 10ba8 <errpat+0x60>
    715e:	e0ea                	sd	s10,64(sp)
    7160:	a2a09653          	flt.d	a2,ft1,fa0
    7164:	c219                	beqz	a2,716a <_ftoa+0x5a>
    7166:	2220106f          	j	8388 <_ftoa+0x1278>
    716a:	66c5                	lui	a3,0x11
    716c:	bb06b107          	fld	ft2,-1104(a3) # 10bb0 <errpat+0x68>
    7170:	a2251853          	flt.d	a6,fa0,ft2
    7174:	00080463          	beqz	a6,717c <_ftoa+0x6c>
    7178:	0e50106f          	j	8a5c <_ftoa+0x194c>
    717c:	f20001d3          	fmv.d.x	ft3,zero
    7180:	a23518d3          	flt.d	a7,fa0,ft3
    7184:	4801                	li	a6,0
    7186:	4c089fe3          	bnez	a7,7e64 <_ftoa+0xd54>
    718a:	400a7b13          	andi	s6,s4,1024
    718e:	4b99                	li	s7,6
    7190:	416b970b          	th.mveqz	a4,s7,s6
    7194:	4e81                	li	t4,0
    7196:	fe070c9b          	addiw	s9,a4,-32
    719a:	4f81                	li	t6,0
    719c:	01010c13          	addi	s8,sp,16
    71a0:	4d25                	li	s10,9
    71a2:	03000e13          	li	t3,48
    71a6:	060e8063          	beqz	t4,7206 <_ftoa+0xf6>
    71aa:	017e8863          	beq	t4,s7,71ba <_ftoa+0xaa>
    71ae:	0ced7763          	bgeu	s10,a4,727c <_ftoa+0x16c>
    71b2:	01cc0023          	sb	t3,0(s8)
    71b6:	377d                	addiw	a4,a4,-1
    71b8:	4f85                	li	t6,1
    71ba:	0ced7163          	bgeu	s10,a4,727c <_ftoa+0x16c>
    71be:	01fc5e0b          	th.srb	t3,s8,t6,0
    71c2:	377d                	addiw	a4,a4,-1
    71c4:	0f85                	addi	t6,t6,1
    71c6:	0aed7b63          	bgeu	s10,a4,727c <_ftoa+0x16c>
    71ca:	01fc5e0b          	th.srb	t3,s8,t6,0
    71ce:	377d                	addiw	a4,a4,-1
    71d0:	0f85                	addi	t6,t6,1
    71d2:	0aed7563          	bgeu	s10,a4,727c <_ftoa+0x16c>
    71d6:	01fc5e0b          	th.srb	t3,s8,t6,0
    71da:	377d                	addiw	a4,a4,-1
    71dc:	0f85                	addi	t6,t6,1
    71de:	08ed7f63          	bgeu	s10,a4,727c <_ftoa+0x16c>
    71e2:	01fc5e0b          	th.srb	t3,s8,t6,0
    71e6:	377d                	addiw	a4,a4,-1
    71e8:	0f85                	addi	t6,t6,1
    71ea:	08ed7963          	bgeu	s10,a4,727c <_ftoa+0x16c>
    71ee:	01fc5e0b          	th.srb	t3,s8,t6,0
    71f2:	377d                	addiw	a4,a4,-1
    71f4:	0f85                	addi	t6,t6,1
    71f6:	08ed7363          	bgeu	s10,a4,727c <_ftoa+0x16c>
    71fa:	01fc5e0b          	th.srb	t3,s8,t6,0
    71fe:	377d                	addiw	a4,a4,-1
    7200:	0f85                	addi	t6,t6,1
    7202:	06ec8b63          	beq	s9,a4,7278 <_ftoa+0x168>
    7206:	06ed7b63          	bgeu	s10,a4,727c <_ftoa+0x16c>
    720a:	01fc5e0b          	th.srb	t3,s8,t6,0
    720e:	377d                	addiw	a4,a4,-1
    7210:	0f85                	addi	t6,t6,1
    7212:	8f7e                	mv	t5,t6
    7214:	06ed7463          	bgeu	s10,a4,727c <_ftoa+0x16c>
    7218:	01fc5e0b          	th.srb	t3,s8,t6,0
    721c:	377d                	addiw	a4,a4,-1
    721e:	0f85                	addi	t6,t6,1
    7220:	04ed7e63          	bgeu	s10,a4,727c <_ftoa+0x16c>
    7224:	01fc5e0b          	th.srb	t3,s8,t6,0
    7228:	377d                	addiw	a4,a4,-1
    722a:	002f0f93          	addi	t6,t5,2
    722e:	04ed7763          	bgeu	s10,a4,727c <_ftoa+0x16c>
    7232:	01fc5e0b          	th.srb	t3,s8,t6,0
    7236:	377d                	addiw	a4,a4,-1
    7238:	003f0f93          	addi	t6,t5,3
    723c:	04ed7063          	bgeu	s10,a4,727c <_ftoa+0x16c>
    7240:	01fc5e0b          	th.srb	t3,s8,t6,0
    7244:	377d                	addiw	a4,a4,-1
    7246:	004f0f93          	addi	t6,t5,4
    724a:	02ed7963          	bgeu	s10,a4,727c <_ftoa+0x16c>
    724e:	01fc5e0b          	th.srb	t3,s8,t6,0
    7252:	377d                	addiw	a4,a4,-1
    7254:	005f0f93          	addi	t6,t5,5
    7258:	02ed7263          	bgeu	s10,a4,727c <_ftoa+0x16c>
    725c:	01fc5e0b          	th.srb	t3,s8,t6,0
    7260:	377d                	addiw	a4,a4,-1
    7262:	006f0f93          	addi	t6,t5,6
    7266:	00ed7b63          	bgeu	s10,a4,727c <_ftoa+0x16c>
    726a:	01fc5e0b          	th.srb	t3,s8,t6,0
    726e:	377d                	addiw	a4,a4,-1
    7270:	007f0f93          	addi	t6,t5,7
    7274:	f8ec99e3          	bne	s9,a4,7206 <_ftoa+0xf6>
    7278:	02000f93          	li	t6,32
    727c:	c20517d3          	fcvt.w.d	a5,fa0,rtz
    7280:	62c5                	lui	t0,0x11
    7282:	d2078253          	fcvt.d.w	ft4,a5
    7286:	dc828313          	addi	t1,t0,-568 # 10dc8 <pow10.0>
    728a:	76e3668b          	th.flurd	fa3,t1,a4,3
    728e:	0a4572d3          	fsub.d	ft5,fa0,ft4
    7292:	63c5                	lui	t2,0x11
    7294:	be03b587          	fld	fa1,-1056(t2) # 10be0 <errpat+0x98>
    7298:	12d2f353          	fmul.d	ft6,ft5,fa3
    729c:	0007859b          	sext.w	a1,a5
    72a0:	c23316d3          	fcvt.lu.d	a3,ft6,rtz
    72a4:	d236f753          	fcvt.d.lu	fa4,a3
    72a8:	0ae373d3          	fsub.d	ft7,ft6,fa4
    72ac:	a2759553          	flt.d	a0,fa1,ft7
    72b0:	62050663          	beqz	a0,78dc <_ftoa+0x7cc>
    72b4:	0685                	addi	a3,a3,1
    72b6:	d236f653          	fcvt.d.lu	fa2,a3
    72ba:	a2c68b53          	fle.d	s6,fa3,fa2
    72be:	000b0563          	beqz	s6,72c8 <_ftoa+0x1b8>
    72c2:	0017859b          	addiw	a1,a5,1
    72c6:	4681                	li	a3,0
    72c8:	62070463          	beqz	a4,78f0 <_ftoa+0x7e0>
    72cc:	fe070b9b          	addiw	s7,a4,-32
    72d0:	01fc0633          	add	a2,s8,t6
    72d4:	01fb8d3b          	addw	s10,s7,t6
    72d8:	4ca9                	li	s9,10
    72da:	4e25                	li	t3,9
    72dc:	00000013          	nop
    72e0:	00ed1463          	bne	s10,a4,72e8 <_ftoa+0x1d8>
    72e4:	09c0106f          	j	8380 <_ftoa+0x1270>
    72e8:	0396ff33          	remu	t5,a3,s9
    72ec:	82b2                	mv	t0,a2
    72ee:	377d                	addiw	a4,a4,-1
    72f0:	8eba                	mv	t4,a4
    72f2:	030f0f9b          	addiw	t6,t5,48
    72f6:	1812df8b          	th.sbia	t6,(t0),1,0
    72fa:	0396d7b3          	divu	a5,a3,s9
    72fe:	78de77e3          	bgeu	t3,a3,828c <_ftoa+0x117c>
    7302:	8616                	mv	a2,t0
    7304:	86be                	mv	a3,a5
    7306:	bfe9                	j	72e0 <_ftoa+0x1d0>
    7308:	00487b13          	andi	s6,a6,4
    730c:	340b16e3          	bnez	s6,7e58 <_ftoa+0xd48>
    7310:	68c5                	lui	a7,0x11
    7312:	ad088b93          	addi	s7,a7,-1328 # 10ad0 <__errno+0x5a4>
    7316:	4c0d                	li	s8,3
    7318:	003a7393          	andi	t2,s4,3
    731c:	8b4e                	mv	s6,s3
    731e:	14039d63          	bnez	t2,7478 <_ftoa+0x368>
    7322:	7c0abc8b          	th.extu	s9,s5,31,0
    7326:	159c7963          	bgeu	s8,s9,7478 <_ftoa+0x368>
    732a:	fc6e                	sd	s11,56(sp)
    732c:	e0ea                	sd	s10,64(sp)
    732e:	413c0d33          	sub	s10,s8,s3
    7332:	fffd4713          	not	a4,s10
    7336:	01970e33          	add	t3,a4,s9
    733a:	413e0f33          	sub	t5,t3,s3
    733e:	86ca                	mv	a3,s2
    7340:	864e                	mv	a2,s3
    7342:	85a6                	mv	a1,s1
    7344:	02000513          	li	a0,32
    7348:	00198b13          	addi	s6,s3,1
    734c:	007f7d93          	andi	s11,t5,7
    7350:	9402                	jalr	s0
    7352:	016d0333          	add	t1,s10,s6
    7356:	11937b63          	bgeu	t1,s9,746c <_ftoa+0x35c>
    735a:	080d8963          	beqz	s11,73ec <_ftoa+0x2dc>
    735e:	4805                	li	a6,1
    7360:	070d8b63          	beq	s11,a6,73d6 <_ftoa+0x2c6>
    7364:	4509                	li	a0,2
    7366:	06ad8163          	beq	s11,a0,73c8 <_ftoa+0x2b8>
    736a:	428d                	li	t0,3
    736c:	045d8763          	beq	s11,t0,73ba <_ftoa+0x2aa>
    7370:	4791                	li	a5,4
    7372:	02fd8d63          	beq	s11,a5,73ac <_ftoa+0x29c>
    7376:	4595                	li	a1,5
    7378:	02bd8363          	beq	s11,a1,739e <_ftoa+0x28e>
    737c:	4e99                	li	t4,6
    737e:	01dd8963          	beq	s11,t4,7390 <_ftoa+0x280>
    7382:	865a                	mv	a2,s6
    7384:	86ca                	mv	a3,s2
    7386:	85a6                	mv	a1,s1
    7388:	02000513          	li	a0,32
    738c:	0b05                	addi	s6,s6,1
    738e:	9402                	jalr	s0
    7390:	865a                	mv	a2,s6
    7392:	86ca                	mv	a3,s2
    7394:	85a6                	mv	a1,s1
    7396:	02000513          	li	a0,32
    739a:	0b05                	addi	s6,s6,1
    739c:	9402                	jalr	s0
    739e:	865a                	mv	a2,s6
    73a0:	86ca                	mv	a3,s2
    73a2:	85a6                	mv	a1,s1
    73a4:	02000513          	li	a0,32
    73a8:	0b05                	addi	s6,s6,1
    73aa:	9402                	jalr	s0
    73ac:	865a                	mv	a2,s6
    73ae:	86ca                	mv	a3,s2
    73b0:	85a6                	mv	a1,s1
    73b2:	02000513          	li	a0,32
    73b6:	0b05                	addi	s6,s6,1
    73b8:	9402                	jalr	s0
    73ba:	865a                	mv	a2,s6
    73bc:	86ca                	mv	a3,s2
    73be:	85a6                	mv	a1,s1
    73c0:	02000513          	li	a0,32
    73c4:	0b05                	addi	s6,s6,1
    73c6:	9402                	jalr	s0
    73c8:	865a                	mv	a2,s6
    73ca:	86ca                	mv	a3,s2
    73cc:	85a6                	mv	a1,s1
    73ce:	02000513          	li	a0,32
    73d2:	0b05                	addi	s6,s6,1
    73d4:	9402                	jalr	s0
    73d6:	865a                	mv	a2,s6
    73d8:	86ca                	mv	a3,s2
    73da:	85a6                	mv	a1,s1
    73dc:	02000513          	li	a0,32
    73e0:	0b05                	addi	s6,s6,1
    73e2:	9402                	jalr	s0
    73e4:	016d0633          	add	a2,s10,s6
    73e8:	09967263          	bgeu	a2,s9,746c <_ftoa+0x35c>
    73ec:	865a                	mv	a2,s6
    73ee:	86ca                	mv	a3,s2
    73f0:	85a6                	mv	a1,s1
    73f2:	02000513          	li	a0,32
    73f6:	9402                	jalr	s0
    73f8:	001b0d93          	addi	s11,s6,1
    73fc:	866e                	mv	a2,s11
    73fe:	86ca                	mv	a3,s2
    7400:	85a6                	mv	a1,s1
    7402:	02000513          	li	a0,32
    7406:	9402                	jalr	s0
    7408:	002b0613          	addi	a2,s6,2
    740c:	86ca                	mv	a3,s2
    740e:	85a6                	mv	a1,s1
    7410:	02000513          	li	a0,32
    7414:	9402                	jalr	s0
    7416:	003b0d93          	addi	s11,s6,3
    741a:	866e                	mv	a2,s11
    741c:	86ca                	mv	a3,s2
    741e:	85a6                	mv	a1,s1
    7420:	02000513          	li	a0,32
    7424:	9402                	jalr	s0
    7426:	004b0613          	addi	a2,s6,4
    742a:	86ca                	mv	a3,s2
    742c:	85a6                	mv	a1,s1
    742e:	02000513          	li	a0,32
    7432:	9402                	jalr	s0
    7434:	005b0d93          	addi	s11,s6,5
    7438:	866e                	mv	a2,s11
    743a:	86ca                	mv	a3,s2
    743c:	85a6                	mv	a1,s1
    743e:	02000513          	li	a0,32
    7442:	9402                	jalr	s0
    7444:	006b0613          	addi	a2,s6,6
    7448:	86ca                	mv	a3,s2
    744a:	85a6                	mv	a1,s1
    744c:	02000513          	li	a0,32
    7450:	9402                	jalr	s0
    7452:	007b0d93          	addi	s11,s6,7
    7456:	866e                	mv	a2,s11
    7458:	86ca                	mv	a3,s2
    745a:	85a6                	mv	a1,s1
    745c:	02000513          	li	a0,32
    7460:	0b21                	addi	s6,s6,8
    7462:	9402                	jalr	s0
    7464:	016d0633          	add	a2,s10,s6
    7468:	f99662e3          	bltu	a2,s9,73ec <_ftoa+0x2dc>
    746c:	7de2                	ld	s11,56(sp)
    746e:	6d06                	ld	s10,64(sp)
    7470:	019986b3          	add	a3,s3,s9
    7474:	41868b33          	sub	s6,a3,s8
    7478:	018b8cb3          	add	s9,s7,s8
    747c:	fffcc503          	lbu	a0,-1(s9)
    7480:	86ca                	mv	a3,s2
    7482:	865a                	mv	a2,s6
    7484:	85a6                	mv	a1,s1
    7486:	9402                	jalr	s0
    7488:	ffecc503          	lbu	a0,-2(s9)
    748c:	86ca                	mv	a3,s2
    748e:	001b0613          	addi	a2,s6,1
    7492:	85a6                	mv	a1,s1
    7494:	9402                	jalr	s0
    7496:	ffdc0c93          	addi	s9,s8,-3
    749a:	819bc50b          	th.lrbu	a0,s7,s9,0
    749e:	86ca                	mv	a3,s2
    74a0:	002b0613          	addi	a2,s6,2
    74a4:	85a6                	mv	a1,s1
    74a6:	9402                	jalr	s0
    74a8:	000c8963          	beqz	s9,74ba <_ftoa+0x3aa>
    74ac:	000bc503          	lbu	a0,0(s7)
    74b0:	86ca                	mv	a3,s2
    74b2:	003b0613          	addi	a2,s6,3
    74b6:	85a6                	mv	a1,s1
    74b8:	9402                	jalr	s0
    74ba:	002a7a13          	andi	s4,s4,2
    74be:	9b62                	add	s6,s6,s8
    74c0:	140a0963          	beqz	s4,7612 <_ftoa+0x502>
    74c4:	413b09b3          	sub	s3,s6,s3
    74c8:	7c0aba8b          	th.extu	s5,s5,31,0
    74cc:	1559f363          	bgeu	s3,s5,7612 <_ftoa+0x502>
    74d0:	fff9c893          	not	a7,s3
    74d4:	01588bb3          	add	s7,a7,s5
    74d8:	865a                	mv	a2,s6
    74da:	86ca                	mv	a3,s2
    74dc:	85a6                	mv	a1,s1
    74de:	02000513          	li	a0,32
    74e2:	00198c93          	addi	s9,s3,1
    74e6:	007bfc13          	andi	s8,s7,7
    74ea:	0b05                	addi	s6,s6,1
    74ec:	9402                	jalr	s0
    74ee:	135cf263          	bgeu	s9,s5,7612 <_ftoa+0x502>
    74f2:	080c0e63          	beqz	s8,758e <_ftoa+0x47e>
    74f6:	4f85                	li	t6,1
    74f8:	09fc0163          	beq	s8,t6,757a <_ftoa+0x46a>
    74fc:	4389                	li	t2,2
    74fe:	067c0663          	beq	s8,t2,756a <_ftoa+0x45a>
    7502:	470d                	li	a4,3
    7504:	04ec0b63          	beq	s8,a4,755a <_ftoa+0x44a>
    7508:	4e11                	li	t3,4
    750a:	05cc0063          	beq	s8,t3,754a <_ftoa+0x43a>
    750e:	4f15                	li	t5,5
    7510:	03ec0563          	beq	s8,t5,753a <_ftoa+0x42a>
    7514:	4319                	li	t1,6
    7516:	006c0a63          	beq	s8,t1,752a <_ftoa+0x41a>
    751a:	865a                	mv	a2,s6
    751c:	86ca                	mv	a3,s2
    751e:	85a6                	mv	a1,s1
    7520:	02000513          	li	a0,32
    7524:	0b05                	addi	s6,s6,1
    7526:	9402                	jalr	s0
    7528:	0c85                	addi	s9,s9,1
    752a:	865a                	mv	a2,s6
    752c:	86ca                	mv	a3,s2
    752e:	85a6                	mv	a1,s1
    7530:	02000513          	li	a0,32
    7534:	0b05                	addi	s6,s6,1
    7536:	9402                	jalr	s0
    7538:	0c85                	addi	s9,s9,1
    753a:	865a                	mv	a2,s6
    753c:	86ca                	mv	a3,s2
    753e:	85a6                	mv	a1,s1
    7540:	02000513          	li	a0,32
    7544:	0b05                	addi	s6,s6,1
    7546:	9402                	jalr	s0
    7548:	0c85                	addi	s9,s9,1
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
    7584:	0c85                	addi	s9,s9,1
    7586:	0b05                	addi	s6,s6,1
    7588:	9402                	jalr	s0
    758a:	095cf463          	bgeu	s9,s5,7612 <_ftoa+0x502>
    758e:	865a                	mv	a2,s6
    7590:	86ca                	mv	a3,s2
    7592:	85a6                	mv	a1,s1
    7594:	02000513          	li	a0,32
    7598:	9402                	jalr	s0
    759a:	001b0a13          	addi	s4,s6,1
    759e:	8652                	mv	a2,s4
    75a0:	86ca                	mv	a3,s2
    75a2:	85a6                	mv	a1,s1
    75a4:	02000513          	li	a0,32
    75a8:	9402                	jalr	s0
    75aa:	002b0993          	addi	s3,s6,2
    75ae:	864e                	mv	a2,s3
    75b0:	86ca                	mv	a3,s2
    75b2:	85a6                	mv	a1,s1
    75b4:	02000513          	li	a0,32
    75b8:	9402                	jalr	s0
    75ba:	003b0c13          	addi	s8,s6,3
    75be:	8662                	mv	a2,s8
    75c0:	86ca                	mv	a3,s2
    75c2:	85a6                	mv	a1,s1
    75c4:	02000513          	li	a0,32
    75c8:	9402                	jalr	s0
    75ca:	004b0b93          	addi	s7,s6,4
    75ce:	86ca                	mv	a3,s2
    75d0:	865e                	mv	a2,s7
    75d2:	85a6                	mv	a1,s1
    75d4:	02000513          	li	a0,32
    75d8:	9402                	jalr	s0
    75da:	005b0a13          	addi	s4,s6,5
    75de:	86ca                	mv	a3,s2
    75e0:	8652                	mv	a2,s4
    75e2:	85a6                	mv	a1,s1
    75e4:	02000513          	li	a0,32
    75e8:	9402                	jalr	s0
    75ea:	006b0993          	addi	s3,s6,6
    75ee:	86ca                	mv	a3,s2
    75f0:	864e                	mv	a2,s3
    75f2:	85a6                	mv	a1,s1
    75f4:	02000513          	li	a0,32
    75f8:	9402                	jalr	s0
    75fa:	007b0c13          	addi	s8,s6,7
    75fe:	86ca                	mv	a3,s2
    7600:	8662                	mv	a2,s8
    7602:	85a6                	mv	a1,s1
    7604:	02000513          	li	a0,32
    7608:	0ca1                	addi	s9,s9,8
    760a:	0b21                	addi	s6,s6,8
    760c:	9402                	jalr	s0
    760e:	f95ce0e3          	bltu	s9,s5,758e <_ftoa+0x47e>
    7612:	64aa                	ld	s1,136(sp)
    7614:	644a                	ld	s0,144(sp)
    7616:	60ea                	ld	ra,152(sp)
    7618:	6ca6                	ld	s9,72(sp)
    761a:	6c46                	ld	s8,80(sp)
    761c:	7aa6                	ld	s5,104(sp)
    761e:	7a46                	ld	s4,112(sp)
    7620:	79e6                	ld	s3,120(sp)
    7622:	690a                	ld	s2,128(sp)
    7624:	855a                	mv	a0,s6
    7626:	6be6                	ld	s7,88(sp)
    7628:	7b06                	ld	s6,96(sp)
    762a:	610d                	addi	sp,sp,160
    762c:	8082                	ret
    762e:	0001                	nop
    7630:	00387893          	andi	a7,a6,3
    7634:	8cb2                	mv	s9,a2
    7636:	12089563          	bnez	a7,7760 <_ftoa+0x650>
    763a:	438d                	li	t2,3
    763c:	7c0abf8b          	th.extu	t6,s5,31,0
    7640:	1353f063          	bgeu	t2,s5,7760 <_ftoa+0x650>
    7644:	ffd60713          	addi	a4,a2,-3
    7648:	01f70cb3          	add	s9,a4,t6
    764c:	40cc8e33          	sub	t3,s9,a2
    7650:	007e7f13          	andi	t5,t3,7
    7654:	8b32                	mv	s6,a2
    7656:	080f0463          	beqz	t5,76de <_ftoa+0x5ce>
    765a:	4305                	li	t1,1
    765c:	066f0863          	beq	t5,t1,76cc <_ftoa+0x5bc>
    7660:	4809                	li	a6,2
    7662:	050f0e63          	beq	t5,a6,76be <_ftoa+0x5ae>
    7666:	047f0563          	beq	t5,t2,76b0 <_ftoa+0x5a0>
    766a:	4511                	li	a0,4
    766c:	02af0b63          	beq	t5,a0,76a2 <_ftoa+0x592>
    7670:	4295                	li	t0,5
    7672:	025f0163          	beq	t5,t0,7694 <_ftoa+0x584>
    7676:	4799                	li	a5,6
    7678:	00ff0763          	beq	t5,a5,7686 <_ftoa+0x576>
    767c:	02000513          	li	a0,32
    7680:	00160b13          	addi	s6,a2,1
    7684:	9402                	jalr	s0
    7686:	865a                	mv	a2,s6
    7688:	86ca                	mv	a3,s2
    768a:	85a6                	mv	a1,s1
    768c:	02000513          	li	a0,32
    7690:	0b05                	addi	s6,s6,1
    7692:	9402                	jalr	s0
    7694:	865a                	mv	a2,s6
    7696:	86ca                	mv	a3,s2
    7698:	85a6                	mv	a1,s1
    769a:	02000513          	li	a0,32
    769e:	0b05                	addi	s6,s6,1
    76a0:	9402                	jalr	s0
    76a2:	865a                	mv	a2,s6
    76a4:	86ca                	mv	a3,s2
    76a6:	85a6                	mv	a1,s1
    76a8:	02000513          	li	a0,32
    76ac:	0b05                	addi	s6,s6,1
    76ae:	9402                	jalr	s0
    76b0:	865a                	mv	a2,s6
    76b2:	86ca                	mv	a3,s2
    76b4:	85a6                	mv	a1,s1
    76b6:	02000513          	li	a0,32
    76ba:	0b05                	addi	s6,s6,1
    76bc:	9402                	jalr	s0
    76be:	865a                	mv	a2,s6
    76c0:	86ca                	mv	a3,s2
    76c2:	85a6                	mv	a1,s1
    76c4:	02000513          	li	a0,32
    76c8:	0b05                	addi	s6,s6,1
    76ca:	9402                	jalr	s0
    76cc:	865a                	mv	a2,s6
    76ce:	86ca                	mv	a3,s2
    76d0:	0b05                	addi	s6,s6,1
    76d2:	85a6                	mv	a1,s1
    76d4:	02000513          	li	a0,32
    76d8:	9402                	jalr	s0
    76da:	099b0363          	beq	s6,s9,7760 <_ftoa+0x650>
    76de:	865a                	mv	a2,s6
    76e0:	86ca                	mv	a3,s2
    76e2:	85a6                	mv	a1,s1
    76e4:	02000513          	li	a0,32
    76e8:	9402                	jalr	s0
    76ea:	001b0b93          	addi	s7,s6,1
    76ee:	865e                	mv	a2,s7
    76f0:	86ca                	mv	a3,s2
    76f2:	85a6                	mv	a1,s1
    76f4:	02000513          	li	a0,32
    76f8:	9402                	jalr	s0
    76fa:	002b0c13          	addi	s8,s6,2
    76fe:	8662                	mv	a2,s8
    7700:	86ca                	mv	a3,s2
    7702:	85a6                	mv	a1,s1
    7704:	02000513          	li	a0,32
    7708:	9402                	jalr	s0
    770a:	003b0b93          	addi	s7,s6,3
    770e:	865e                	mv	a2,s7
    7710:	86ca                	mv	a3,s2
    7712:	85a6                	mv	a1,s1
    7714:	02000513          	li	a0,32
    7718:	9402                	jalr	s0
    771a:	004b0c13          	addi	s8,s6,4
    771e:	8662                	mv	a2,s8
    7720:	86ca                	mv	a3,s2
    7722:	85a6                	mv	a1,s1
    7724:	02000513          	li	a0,32
    7728:	9402                	jalr	s0
    772a:	005b0b93          	addi	s7,s6,5
    772e:	865e                	mv	a2,s7
    7730:	86ca                	mv	a3,s2
    7732:	85a6                	mv	a1,s1
    7734:	02000513          	li	a0,32
    7738:	9402                	jalr	s0
    773a:	006b0c13          	addi	s8,s6,6
    773e:	86ca                	mv	a3,s2
    7740:	8662                	mv	a2,s8
    7742:	85a6                	mv	a1,s1
    7744:	02000513          	li	a0,32
    7748:	9402                	jalr	s0
    774a:	007b0b93          	addi	s7,s6,7
    774e:	86ca                	mv	a3,s2
    7750:	0b21                	addi	s6,s6,8
    7752:	865e                	mv	a2,s7
    7754:	85a6                	mv	a1,s1
    7756:	02000513          	li	a0,32
    775a:	9402                	jalr	s0
    775c:	f99b11e3          	bne	s6,s9,76de <_ftoa+0x5ce>
    7760:	4b8d                	li	s7,3
    7762:	65c5                	lui	a1,0x11
    7764:	9cde                	add	s9,s9,s7
    7766:	ad858c13          	addi	s8,a1,-1320 # 10ad8 <__errno+0x5ac>
    776a:	0001                	nop
    776c:	00000013          	nop
    7770:	417c8633          	sub	a2,s9,s7
    7774:	1bfd                	addi	s7,s7,-1
    7776:	817c450b          	th.lrbu	a0,s8,s7,0
    777a:	86ca                	mv	a3,s2
    777c:	85a6                	mv	a1,s1
    777e:	8b66                	mv	s6,s9
    7780:	9402                	jalr	s0
    7782:	fe0b97e3          	bnez	s7,7770 <_ftoa+0x660>
    7786:	002a7e93          	andi	t4,s4,2
    778a:	e80e84e3          	beqz	t4,7612 <_ftoa+0x502>
    778e:	7c0aba8b          	th.extu	s5,s5,31,0
    7792:	413c8633          	sub	a2,s9,s3
    7796:	e7567ee3          	bgeu	a2,s5,7612 <_ftoa+0x502>
    779a:	fffcc693          	not	a3,s9
    779e:	01568a33          	add	s4,a3,s5
    77a2:	013a08b3          	add	a7,s4,s3
    77a6:	86ca                	mv	a3,s2
    77a8:	8666                	mv	a2,s9
    77aa:	85a6                	mv	a1,s1
    77ac:	02000513          	li	a0,32
    77b0:	0078fb93          	andi	s7,a7,7
    77b4:	001c8b13          	addi	s6,s9,1
    77b8:	9402                	jalr	s0
    77ba:	413b0fb3          	sub	t6,s6,s3
    77be:	e55ffae3          	bgeu	t6,s5,7612 <_ftoa+0x502>
    77c2:	080b8963          	beqz	s7,7854 <_ftoa+0x744>
    77c6:	4385                	li	t2,1
    77c8:	067b8b63          	beq	s7,t2,783e <_ftoa+0x72e>
    77cc:	4709                	li	a4,2
    77ce:	06eb8163          	beq	s7,a4,7830 <_ftoa+0x720>
    77d2:	4e0d                	li	t3,3
    77d4:	05cb8763          	beq	s7,t3,7822 <_ftoa+0x712>
    77d8:	4f11                	li	t5,4
    77da:	03eb8d63          	beq	s7,t5,7814 <_ftoa+0x704>
    77de:	4315                	li	t1,5
    77e0:	026b8363          	beq	s7,t1,7806 <_ftoa+0x6f6>
    77e4:	4819                	li	a6,6
    77e6:	010b8963          	beq	s7,a6,77f8 <_ftoa+0x6e8>
    77ea:	865a                	mv	a2,s6
    77ec:	86ca                	mv	a3,s2
    77ee:	85a6                	mv	a1,s1
    77f0:	02000513          	li	a0,32
    77f4:	0b05                	addi	s6,s6,1
    77f6:	9402                	jalr	s0
    77f8:	865a                	mv	a2,s6
    77fa:	86ca                	mv	a3,s2
    77fc:	85a6                	mv	a1,s1
    77fe:	02000513          	li	a0,32
    7802:	0b05                	addi	s6,s6,1
    7804:	9402                	jalr	s0
    7806:	865a                	mv	a2,s6
    7808:	86ca                	mv	a3,s2
    780a:	85a6                	mv	a1,s1
    780c:	02000513          	li	a0,32
    7810:	0b05                	addi	s6,s6,1
    7812:	9402                	jalr	s0
    7814:	865a                	mv	a2,s6
    7816:	86ca                	mv	a3,s2
    7818:	85a6                	mv	a1,s1
    781a:	02000513          	li	a0,32
    781e:	0b05                	addi	s6,s6,1
    7820:	9402                	jalr	s0
    7822:	865a                	mv	a2,s6
    7824:	86ca                	mv	a3,s2
    7826:	85a6                	mv	a1,s1
    7828:	02000513          	li	a0,32
    782c:	0b05                	addi	s6,s6,1
    782e:	9402                	jalr	s0
    7830:	865a                	mv	a2,s6
    7832:	86ca                	mv	a3,s2
    7834:	85a6                	mv	a1,s1
    7836:	02000513          	li	a0,32
    783a:	0b05                	addi	s6,s6,1
    783c:	9402                	jalr	s0
    783e:	865a                	mv	a2,s6
    7840:	02000513          	li	a0,32
    7844:	86ca                	mv	a3,s2
    7846:	85a6                	mv	a1,s1
    7848:	0b05                	addi	s6,s6,1
    784a:	9402                	jalr	s0
    784c:	413b0533          	sub	a0,s6,s3
    7850:	dd5571e3          	bgeu	a0,s5,7612 <_ftoa+0x502>
    7854:	865a                	mv	a2,s6
    7856:	86ca                	mv	a3,s2
    7858:	85a6                	mv	a1,s1
    785a:	02000513          	li	a0,32
    785e:	9402                	jalr	s0
    7860:	001b0c93          	addi	s9,s6,1
    7864:	8666                	mv	a2,s9
    7866:	86ca                	mv	a3,s2
    7868:	85a6                	mv	a1,s1
    786a:	02000513          	li	a0,32
    786e:	9402                	jalr	s0
    7870:	002b0c13          	addi	s8,s6,2
    7874:	8662                	mv	a2,s8
    7876:	86ca                	mv	a3,s2
    7878:	85a6                	mv	a1,s1
    787a:	02000513          	li	a0,32
    787e:	9402                	jalr	s0
    7880:	003b0a13          	addi	s4,s6,3
    7884:	8652                	mv	a2,s4
    7886:	86ca                	mv	a3,s2
    7888:	85a6                	mv	a1,s1
    788a:	02000513          	li	a0,32
    788e:	9402                	jalr	s0
    7890:	004b0b93          	addi	s7,s6,4
    7894:	86ca                	mv	a3,s2
    7896:	865e                	mv	a2,s7
    7898:	85a6                	mv	a1,s1
    789a:	02000513          	li	a0,32
    789e:	9402                	jalr	s0
    78a0:	005b0c93          	addi	s9,s6,5
    78a4:	86ca                	mv	a3,s2
    78a6:	8666                	mv	a2,s9
    78a8:	85a6                	mv	a1,s1
    78aa:	02000513          	li	a0,32
    78ae:	9402                	jalr	s0
    78b0:	006b0c13          	addi	s8,s6,6
    78b4:	86ca                	mv	a3,s2
    78b6:	8662                	mv	a2,s8
    78b8:	85a6                	mv	a1,s1
    78ba:	02000513          	li	a0,32
    78be:	9402                	jalr	s0
    78c0:	007b0a13          	addi	s4,s6,7
    78c4:	02000513          	li	a0,32
    78c8:	86ca                	mv	a3,s2
    78ca:	8652                	mv	a2,s4
    78cc:	85a6                	mv	a1,s1
    78ce:	0b21                	addi	s6,s6,8
    78d0:	9402                	jalr	s0
    78d2:	413b0533          	sub	a0,s6,s3
    78d6:	f7556fe3          	bltu	a0,s5,7854 <_ftoa+0x744>
    78da:	bb25                	j	7612 <_ftoa+0x502>
    78dc:	a2b39653          	flt.d	a2,ft7,fa1
    78e0:	9e0614e3          	bnez	a2,72c8 <_ftoa+0x1b8>
    78e4:	c299                	beqz	a3,78ea <_ftoa+0x7da>
    78e6:	1120106f          	j	89f8 <_ftoa+0x18e8>
    78ea:	0685                	addi	a3,a3,1
    78ec:	9e0710e3          	bnez	a4,72cc <_ftoa+0x1bc>
    78f0:	d2058853          	fcvt.d.w	fa6,a1
    78f4:	be03b887          	fld	fa7,-1056(t2)
    78f8:	0b057553          	fsub.d	fa0,fa0,fa6
    78fc:	0015839b          	addiw	t2,a1,1
    7900:	ffe3fb13          	andi	s6,t2,-2
    7904:	a3151e53          	flt.d	t3,fa0,fa7
    7908:	000b089b          	sext.w	a7,s6
    790c:	41c8958b          	th.mveqz	a1,a7,t3
    7910:	01fc07b3          	add	a5,s8,t6
    7914:	03010f13          	addi	t5,sp,48
    7918:	40ff0633          	sub	a2,t5,a5
    791c:	00767693          	andi	a3,a2,7
    7920:	4ea9                	li	t4,10
    7922:	c6f9                	beqz	a3,79f0 <_ftoa+0x8e0>
    7924:	03d5efbb          	remw	t6,a1,t4
    7928:	873e                	mv	a4,a5
    792a:	03d5c5bb          	divw	a1,a1,t4
    792e:	030f831b          	addiw	t1,t6,48
    7932:	1817530b          	th.sbia	t1,(a4),1,0
    7936:	7e058963          	beqz	a1,8128 <_ftoa+0x1018>
    793a:	4505                	li	a0,1
    793c:	87ba                	mv	a5,a4
    793e:	0aa68963          	beq	a3,a0,79f0 <_ftoa+0x8e0>
    7942:	4b89                	li	s7,2
    7944:	09768a63          	beq	a3,s7,79d8 <_ftoa+0x8c8>
    7948:	4c8d                	li	s9,3
    794a:	07968b63          	beq	a3,s9,79c0 <_ftoa+0x8b0>
    794e:	4d11                	li	s10,4
    7950:	05a68c63          	beq	a3,s10,79a8 <_ftoa+0x898>
    7954:	4295                	li	t0,5
    7956:	02568d63          	beq	a3,t0,7990 <_ftoa+0x880>
    795a:	4399                	li	t2,6
    795c:	00768e63          	beq	a3,t2,7978 <_ftoa+0x868>
    7960:	03d5eb3b          	remw	s6,a1,t4
    7964:	8e3a                	mv	t3,a4
    7966:	03d5c5bb          	divw	a1,a1,t4
    796a:	030b089b          	addiw	a7,s6,48
    796e:	181e588b          	th.sbia	a7,(t3),1,0
    7972:	7a058b63          	beqz	a1,8128 <_ftoa+0x1018>
    7976:	87f2                	mv	a5,t3
    7978:	03d5ef3b          	remw	t5,a1,t4
    797c:	863e                	mv	a2,a5
    797e:	03d5c5bb          	divw	a1,a1,t4
    7982:	030f069b          	addiw	a3,t5,48
    7986:	1816568b          	th.sbia	a3,(a2),1,0
    798a:	78058f63          	beqz	a1,8128 <_ftoa+0x1018>
    798e:	87b2                	mv	a5,a2
    7990:	03d5efbb          	remw	t6,a1,t4
    7994:	873e                	mv	a4,a5
    7996:	03d5c5bb          	divw	a1,a1,t4
    799a:	030f831b          	addiw	t1,t6,48
    799e:	1817530b          	th.sbia	t1,(a4),1,0
    79a2:	78058363          	beqz	a1,8128 <_ftoa+0x1018>
    79a6:	87ba                	mv	a5,a4
    79a8:	03d5e53b          	remw	a0,a1,t4
    79ac:	8cbe                	mv	s9,a5
    79ae:	03d5c5bb          	divw	a1,a1,t4
    79b2:	03050b9b          	addiw	s7,a0,48
    79b6:	181cdb8b          	th.sbia	s7,(s9),1,0
    79ba:	76058763          	beqz	a1,8128 <_ftoa+0x1018>
    79be:	87e6                	mv	a5,s9
    79c0:	03d5ed3b          	remw	s10,a1,t4
    79c4:	83be                	mv	t2,a5
    79c6:	03d5c5bb          	divw	a1,a1,t4
    79ca:	030d029b          	addiw	t0,s10,48
    79ce:	1813d28b          	th.sbia	t0,(t2),1,0
    79d2:	74058b63          	beqz	a1,8128 <_ftoa+0x1018>
    79d6:	879e                	mv	a5,t2
    79d8:	03d5eb3b          	remw	s6,a1,t4
    79dc:	8e3e                	mv	t3,a5
    79de:	03d5c5bb          	divw	a1,a1,t4
    79e2:	030b089b          	addiw	a7,s6,48
    79e6:	181e588b          	th.sbia	a7,(t3),1,0
    79ea:	72058f63          	beqz	a1,8128 <_ftoa+0x1018>
    79ee:	87f2                	mv	a5,t3
    79f0:	03010f13          	addi	t5,sp,48
    79f4:	0cff0463          	beq	t5,a5,7abc <_ftoa+0x9ac>
    79f8:	03d5e6bb          	remw	a3,a1,t4
    79fc:	863e                	mv	a2,a5
    79fe:	03d5c73b          	divw	a4,a1,t4
    7a02:	0306831b          	addiw	t1,a3,48
    7a06:	1816530b          	th.sbia	t1,(a2),1,0
    7a0a:	70070f63          	beqz	a4,8128 <_ftoa+0x1018>
    7a0e:	03d7653b          	remw	a0,a4,t4
    7a12:	87b2                	mv	a5,a2
    7a14:	03d74cbb          	divw	s9,a4,t4
    7a18:	03050b9b          	addiw	s7,a0,48
    7a1c:	01760023          	sb	s7,0(a2)
    7a20:	700c8463          	beqz	s9,8128 <_ftoa+0x1018>
    7a24:	03dced3b          	remw	s10,s9,t4
    7a28:	03dcc3bb          	divw	t2,s9,t4
    7a2c:	030d029b          	addiw	t0,s10,48
    7a30:	0817d28b          	th.sbib	t0,(a5),1,0
    7a34:	6e038a63          	beqz	t2,8128 <_ftoa+0x1018>
    7a38:	03d3eb3b          	remw	s6,t2,t4
    7a3c:	00260793          	addi	a5,a2,2
    7a40:	03d3ce3b          	divw	t3,t2,t4
    7a44:	030b089b          	addiw	a7,s6,48
    7a48:	01160123          	sb	a7,2(a2)
    7a4c:	6c0e0e63          	beqz	t3,8128 <_ftoa+0x1018>
    7a50:	03de6f3b          	remw	t5,t3,t4
    7a54:	00360793          	addi	a5,a2,3
    7a58:	03de4fbb          	divw	t6,t3,t4
    7a5c:	030f059b          	addiw	a1,t5,48
    7a60:	00b601a3          	sb	a1,3(a2)
    7a64:	6c0f8263          	beqz	t6,8128 <_ftoa+0x1018>
    7a68:	03dfe6bb          	remw	a3,t6,t4
    7a6c:	00460793          	addi	a5,a2,4
    7a70:	03dfc73b          	divw	a4,t6,t4
    7a74:	0306831b          	addiw	t1,a3,48
    7a78:	00660223          	sb	t1,4(a2)
    7a7c:	6a070663          	beqz	a4,8128 <_ftoa+0x1018>
    7a80:	03d7653b          	remw	a0,a4,t4
    7a84:	00560793          	addi	a5,a2,5
    7a88:	03d74cbb          	divw	s9,a4,t4
    7a8c:	03050b9b          	addiw	s7,a0,48
    7a90:	017602a3          	sb	s7,5(a2)
    7a94:	680c8a63          	beqz	s9,8128 <_ftoa+0x1018>
    7a98:	03dced3b          	remw	s10,s9,t4
    7a9c:	00660793          	addi	a5,a2,6
    7aa0:	03dcc5bb          	divw	a1,s9,t4
    7aa4:	030d029b          	addiw	t0,s10,48
    7aa8:	00560323          	sb	t0,6(a2)
    7aac:	66058e63          	beqz	a1,8128 <_ftoa+0x1018>
    7ab0:	00760793          	addi	a5,a2,7
    7ab4:	03010f13          	addi	t5,sp,48
    7ab8:	f4ff10e3          	bne	t5,a5,79f8 <_ftoa+0x8e8>
    7abc:	003a7593          	andi	a1,s4,3
    7ac0:	4785                	li	a5,1
    7ac2:	78f599e3          	bne	a1,a5,8a54 <_ftoa+0x1944>
    7ac6:	6e0a87e3          	beqz	s5,89b4 <_ftoa+0x18a4>
    7aca:	78080fe3          	beqz	a6,8a68 <_ftoa+0x1958>
    7ace:	3afd                	addiw	s5,s5,-1
    7ad0:	02000b13          	li	s6,32
    7ad4:	7c0abf8b          	th.extu	t6,s5,31,0
    7ad8:	115b7363          	bgeu	s6,s5,7bde <_ftoa+0xace>
    7adc:	02000293          	li	t0,32
    7ae0:	416287b3          	sub	a5,t0,s6
    7ae4:	0077fe93          	andi	t4,a5,7
    7ae8:	016c0733          	add	a4,s8,s6
    7aec:	03000593          	li	a1,48
    7af0:	060e8763          	beqz	t4,7b5e <_ftoa+0xa4e>
    7af4:	0b05                	addi	s6,s6,1
    7af6:	1817558b          	th.sbia	a1,(a4),1,0
    7afa:	0dfb0763          	beq	s6,t6,7bc8 <_ftoa+0xab8>
    7afe:	4605                	li	a2,1
    7b00:	04ce8f63          	beq	t4,a2,7b5e <_ftoa+0xa4e>
    7b04:	4389                	li	t2,2
    7b06:	047e8763          	beq	t4,t2,7b54 <_ftoa+0xa44>
    7b0a:	488d                	li	a7,3
    7b0c:	031e8f63          	beq	t4,a7,7b4a <_ftoa+0xa3a>
    7b10:	4e11                	li	t3,4
    7b12:	03ce8763          	beq	t4,t3,7b40 <_ftoa+0xa30>
    7b16:	4f15                	li	t5,5
    7b18:	01ee8f63          	beq	t4,t5,7b36 <_ftoa+0xa26>
    7b1c:	4319                	li	t1,6
    7b1e:	006e8763          	beq	t4,t1,7b2c <_ftoa+0xa1c>
    7b22:	0b05                	addi	s6,s6,1
    7b24:	1817558b          	th.sbia	a1,(a4),1,0
    7b28:	0bfb0063          	beq	s6,t6,7bc8 <_ftoa+0xab8>
    7b2c:	0b05                	addi	s6,s6,1
    7b2e:	1817558b          	th.sbia	a1,(a4),1,0
    7b32:	09fb0b63          	beq	s6,t6,7bc8 <_ftoa+0xab8>
    7b36:	0b05                	addi	s6,s6,1
    7b38:	1817558b          	th.sbia	a1,(a4),1,0
    7b3c:	09fb0663          	beq	s6,t6,7bc8 <_ftoa+0xab8>
    7b40:	0b05                	addi	s6,s6,1
    7b42:	1817558b          	th.sbia	a1,(a4),1,0
    7b46:	09fb0163          	beq	s6,t6,7bc8 <_ftoa+0xab8>
    7b4a:	0b05                	addi	s6,s6,1
    7b4c:	1817558b          	th.sbia	a1,(a4),1,0
    7b50:	07fb0c63          	beq	s6,t6,7bc8 <_ftoa+0xab8>
    7b54:	0b05                	addi	s6,s6,1
    7b56:	1817558b          	th.sbia	a1,(a4),1,0
    7b5a:	07fb0763          	beq	s6,t6,7bc8 <_ftoa+0xab8>
    7b5e:	6e5b05e3          	beq	s6,t0,8a48 <_ftoa+0x1938>
    7b62:	0b05                	addi	s6,s6,1
    7b64:	00b70023          	sb	a1,0(a4)
    7b68:	86da                	mv	a3,s6
    7b6a:	05fb0f63          	beq	s6,t6,7bc8 <_ftoa+0xab8>
    7b6e:	0b05                	addi	s6,s6,1
    7b70:	00b700a3          	sb	a1,1(a4)
    7b74:	05fb0a63          	beq	s6,t6,7bc8 <_ftoa+0xab8>
    7b78:	00268b13          	addi	s6,a3,2
    7b7c:	00b70123          	sb	a1,2(a4)
    7b80:	05fb0463          	beq	s6,t6,7bc8 <_ftoa+0xab8>
    7b84:	00368b13          	addi	s6,a3,3
    7b88:	00b701a3          	sb	a1,3(a4)
    7b8c:	03fb0e63          	beq	s6,t6,7bc8 <_ftoa+0xab8>
    7b90:	00468b13          	addi	s6,a3,4
    7b94:	00b70223          	sb	a1,4(a4)
    7b98:	03fb0863          	beq	s6,t6,7bc8 <_ftoa+0xab8>
    7b9c:	00568b13          	addi	s6,a3,5
    7ba0:	00b702a3          	sb	a1,5(a4)
    7ba4:	03fb0263          	beq	s6,t6,7bc8 <_ftoa+0xab8>
    7ba8:	00668b13          	addi	s6,a3,6
    7bac:	00b70323          	sb	a1,6(a4)
    7bb0:	01fb0c63          	beq	s6,t6,7bc8 <_ftoa+0xab8>
    7bb4:	00b703a3          	sb	a1,7(a4)
    7bb8:	00768b13          	addi	s6,a3,7
    7bbc:	0721                	addi	a4,a4,8
    7bbe:	fbfb10e3          	bne	s6,t6,7b5e <_ftoa+0xa4e>
    7bc2:	0001                	nop
    7bc4:	00000013          	nop
    7bc8:	685b00e3          	beq	s6,t0,8a48 <_ftoa+0x1938>
    7bcc:	6e080fe3          	beqz	a6,8aca <_ftoa+0x19ba>
    7bd0:	002f8d33          	add	s10,t6,sp
    7bd4:	02d00293          	li	t0,45
    7bd8:	0b05                	addi	s6,s6,1
    7bda:	005d0823          	sb	t0,16(s10)
    7bde:	8d4e                	mv	s10,s3
    7be0:	9d5a                	add	s10,s10,s6
    7be2:	016c0bb3          	add	s7,s8,s6
    7be6:	007b7b13          	andi	s6,s6,7
    7bea:	01ac0cb3          	add	s9,s8,s10
    7bee:	080b0163          	beqz	s6,7c70 <_ftoa+0xb60>
    7bf2:	4585                	li	a1,1
    7bf4:	06bb0463          	beq	s6,a1,7c5c <_ftoa+0xb4c>
    7bf8:	4789                	li	a5,2
    7bfa:	04fb0a63          	beq	s6,a5,7c4e <_ftoa+0xb3e>
    7bfe:	4e8d                	li	t4,3
    7c00:	05db0063          	beq	s6,t4,7c40 <_ftoa+0xb30>
    7c04:	4611                	li	a2,4
    7c06:	02cb0663          	beq	s6,a2,7c32 <_ftoa+0xb22>
    7c0a:	4395                	li	t2,5
    7c0c:	007b0c63          	beq	s6,t2,7c24 <_ftoa+0xb14>
    7c10:	4899                	li	a7,6
    7c12:	5f1b1de3          	bne	s6,a7,8a0c <_ftoa+0x18fc>
    7c16:	417c8633          	sub	a2,s9,s7
    7c1a:	89fbc50b          	th.lbuib	a0,(s7),-1,0
    7c1e:	86ca                	mv	a3,s2
    7c20:	85a6                	mv	a1,s1
    7c22:	9402                	jalr	s0
    7c24:	417c8633          	sub	a2,s9,s7
    7c28:	89fbc50b          	th.lbuib	a0,(s7),-1,0
    7c2c:	86ca                	mv	a3,s2
    7c2e:	85a6                	mv	a1,s1
    7c30:	9402                	jalr	s0
    7c32:	417c8633          	sub	a2,s9,s7
    7c36:	89fbc50b          	th.lbuib	a0,(s7),-1,0
    7c3a:	86ca                	mv	a3,s2
    7c3c:	85a6                	mv	a1,s1
    7c3e:	9402                	jalr	s0
    7c40:	417c8633          	sub	a2,s9,s7
    7c44:	89fbc50b          	th.lbuib	a0,(s7),-1,0
    7c48:	86ca                	mv	a3,s2
    7c4a:	85a6                	mv	a1,s1
    7c4c:	9402                	jalr	s0
    7c4e:	417c8633          	sub	a2,s9,s7
    7c52:	89fbc50b          	th.lbuib	a0,(s7),-1,0
    7c56:	86ca                	mv	a3,s2
    7c58:	85a6                	mv	a1,s1
    7c5a:	9402                	jalr	s0
    7c5c:	417c8633          	sub	a2,s9,s7
    7c60:	89fbc50b          	th.lbuib	a0,(s7),-1,0
    7c64:	86ca                	mv	a3,s2
    7c66:	85a6                	mv	a1,s1
    7c68:	8b6a                	mv	s6,s10
    7c6a:	9402                	jalr	s0
    7c6c:	097c0663          	beq	s8,s7,7cf8 <_ftoa+0xbe8>
    7c70:	fc6e                	sd	s11,56(sp)
    7c72:	8dde                	mv	s11,s7
    7c74:	89fdc50b          	th.lbuib	a0,(s11),-1,0
    7c78:	417c8633          	sub	a2,s9,s7
    7c7c:	86ca                	mv	a3,s2
    7c7e:	85a6                	mv	a1,s1
    7c80:	9402                	jalr	s0
    7c82:	8b5e                	mv	s6,s7
    7c84:	89eb450b          	th.lbuib	a0,(s6),-2,0
    7c88:	41bc8633          	sub	a2,s9,s11
    7c8c:	86ca                	mv	a3,s2
    7c8e:	85a6                	mv	a1,s1
    7c90:	9402                	jalr	s0
    7c92:	8dde                	mv	s11,s7
    7c94:	89ddc50b          	th.lbuib	a0,(s11),-3,0
    7c98:	416c8633          	sub	a2,s9,s6
    7c9c:	86ca                	mv	a3,s2
    7c9e:	85a6                	mv	a1,s1
    7ca0:	9402                	jalr	s0
    7ca2:	8b5e                	mv	s6,s7
    7ca4:	89cb450b          	th.lbuib	a0,(s6),-4,0
    7ca8:	41bc8633          	sub	a2,s9,s11
    7cac:	86ca                	mv	a3,s2
    7cae:	85a6                	mv	a1,s1
    7cb0:	9402                	jalr	s0
    7cb2:	8dde                	mv	s11,s7
    7cb4:	89bdc50b          	th.lbuib	a0,(s11),-5,0
    7cb8:	416c8633          	sub	a2,s9,s6
    7cbc:	86ca                	mv	a3,s2
    7cbe:	85a6                	mv	a1,s1
    7cc0:	9402                	jalr	s0
    7cc2:	8b5e                	mv	s6,s7
    7cc4:	89ab450b          	th.lbuib	a0,(s6),-6,0
    7cc8:	41bc8633          	sub	a2,s9,s11
    7ccc:	86ca                	mv	a3,s2
    7cce:	85a6                	mv	a1,s1
    7cd0:	9402                	jalr	s0
    7cd2:	8dde                	mv	s11,s7
    7cd4:	899dc50b          	th.lbuib	a0,(s11),-7,0
    7cd8:	416c8633          	sub	a2,s9,s6
    7cdc:	86ca                	mv	a3,s2
    7cde:	85a6                	mv	a1,s1
    7ce0:	9402                	jalr	s0
    7ce2:	898bc50b          	th.lbuib	a0,(s7),-8,0
    7ce6:	86ca                	mv	a3,s2
    7ce8:	41bc8633          	sub	a2,s9,s11
    7cec:	85a6                	mv	a1,s1
    7cee:	8b6a                	mv	s6,s10
    7cf0:	9402                	jalr	s0
    7cf2:	f97c10e3          	bne	s8,s7,7c72 <_ftoa+0xb62>
    7cf6:	7de2                	ld	s11,56(sp)
    7cf8:	002a7a13          	andi	s4,s4,2
    7cfc:	140a0a63          	beqz	s4,7e50 <_ftoa+0xd40>
    7d00:	413d09b3          	sub	s3,s10,s3
    7d04:	7c0aba8b          	th.extu	s5,s5,31,0
    7d08:	1559f463          	bgeu	s3,s5,7e50 <_ftoa+0xd40>
    7d0c:	fff9cc13          	not	s8,s3
    7d10:	015c0e33          	add	t3,s8,s5
    7d14:	866a                	mv	a2,s10
    7d16:	001d0b13          	addi	s6,s10,1
    7d1a:	86ca                	mv	a3,s2
    7d1c:	85a6                	mv	a1,s1
    7d1e:	02000513          	li	a0,32
    7d22:	00198d13          	addi	s10,s3,1
    7d26:	007e7b93          	andi	s7,t3,7
    7d2a:	9402                	jalr	s0
    7d2c:	135d7263          	bgeu	s10,s5,7e50 <_ftoa+0xd40>
    7d30:	080b8e63          	beqz	s7,7dcc <_ftoa+0xcbc>
    7d34:	4f05                	li	t5,1
    7d36:	09eb8163          	beq	s7,t5,7db8 <_ftoa+0xca8>
    7d3a:	4309                	li	t1,2
    7d3c:	066b8663          	beq	s7,t1,7da8 <_ftoa+0xc98>
    7d40:	468d                	li	a3,3
    7d42:	04db8b63          	beq	s7,a3,7d98 <_ftoa+0xc88>
    7d46:	4811                	li	a6,4
    7d48:	050b8063          	beq	s7,a6,7d88 <_ftoa+0xc78>
    7d4c:	4715                	li	a4,5
    7d4e:	02eb8563          	beq	s7,a4,7d78 <_ftoa+0xc68>
    7d52:	4519                	li	a0,6
    7d54:	00ab8a63          	beq	s7,a0,7d68 <_ftoa+0xc58>
    7d58:	865a                	mv	a2,s6
    7d5a:	86ca                	mv	a3,s2
    7d5c:	85a6                	mv	a1,s1
    7d5e:	02000513          	li	a0,32
    7d62:	0b05                	addi	s6,s6,1
    7d64:	9402                	jalr	s0
    7d66:	0d05                	addi	s10,s10,1
    7d68:	865a                	mv	a2,s6
    7d6a:	86ca                	mv	a3,s2
    7d6c:	85a6                	mv	a1,s1
    7d6e:	02000513          	li	a0,32
    7d72:	0b05                	addi	s6,s6,1
    7d74:	9402                	jalr	s0
    7d76:	0d05                	addi	s10,s10,1
    7d78:	865a                	mv	a2,s6
    7d7a:	86ca                	mv	a3,s2
    7d7c:	85a6                	mv	a1,s1
    7d7e:	02000513          	li	a0,32
    7d82:	0b05                	addi	s6,s6,1
    7d84:	9402                	jalr	s0
    7d86:	0d05                	addi	s10,s10,1
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
    7dc2:	0d05                	addi	s10,s10,1
    7dc4:	0b05                	addi	s6,s6,1
    7dc6:	9402                	jalr	s0
    7dc8:	095d7463          	bgeu	s10,s5,7e50 <_ftoa+0xd40>
    7dcc:	865a                	mv	a2,s6
    7dce:	86ca                	mv	a3,s2
    7dd0:	85a6                	mv	a1,s1
    7dd2:	02000513          	li	a0,32
    7dd6:	9402                	jalr	s0
    7dd8:	001b0c93          	addi	s9,s6,1
    7ddc:	8666                	mv	a2,s9
    7dde:	86ca                	mv	a3,s2
    7de0:	85a6                	mv	a1,s1
    7de2:	02000513          	li	a0,32
    7de6:	9402                	jalr	s0
    7de8:	002b0993          	addi	s3,s6,2
    7dec:	864e                	mv	a2,s3
    7dee:	86ca                	mv	a3,s2
    7df0:	85a6                	mv	a1,s1
    7df2:	02000513          	li	a0,32
    7df6:	9402                	jalr	s0
    7df8:	003b0a13          	addi	s4,s6,3
    7dfc:	86ca                	mv	a3,s2
    7dfe:	8652                	mv	a2,s4
    7e00:	85a6                	mv	a1,s1
    7e02:	02000513          	li	a0,32
    7e06:	9402                	jalr	s0
    7e08:	004b0c13          	addi	s8,s6,4
    7e0c:	86ca                	mv	a3,s2
    7e0e:	8662                	mv	a2,s8
    7e10:	85a6                	mv	a1,s1
    7e12:	02000513          	li	a0,32
    7e16:	9402                	jalr	s0
    7e18:	005b0c93          	addi	s9,s6,5
    7e1c:	86ca                	mv	a3,s2
    7e1e:	8666                	mv	a2,s9
    7e20:	85a6                	mv	a1,s1
    7e22:	02000513          	li	a0,32
    7e26:	9402                	jalr	s0
    7e28:	006b0b93          	addi	s7,s6,6
    7e2c:	86ca                	mv	a3,s2
    7e2e:	865e                	mv	a2,s7
    7e30:	85a6                	mv	a1,s1
    7e32:	02000513          	li	a0,32
    7e36:	9402                	jalr	s0
    7e38:	007b0993          	addi	s3,s6,7
    7e3c:	86ca                	mv	a3,s2
    7e3e:	864e                	mv	a2,s3
    7e40:	85a6                	mv	a1,s1
    7e42:	02000513          	li	a0,32
    7e46:	0d21                	addi	s10,s10,8
    7e48:	0b21                	addi	s6,s6,8
    7e4a:	9402                	jalr	s0
    7e4c:	f95d60e3          	bltu	s10,s5,7dcc <_ftoa+0xcbc>
    7e50:	6d06                	ld	s10,64(sp)
    7e52:	fc0ff06f          	j	7612 <_ftoa+0x502>
    7e56:	0001                	nop
    7e58:	6fc5                	lui	t6,0x11
    7e5a:	ac8f8b93          	addi	s7,t6,-1336 # 10ac8 <__errno+0x59c>
    7e5e:	4c11                	li	s8,4
    7e60:	cb8ff06f          	j	7318 <_ftoa+0x208>
    7e64:	0aa1f553          	fsub.d	fa0,ft3,fa0
    7e68:	4805                	li	a6,1
    7e6a:	b20ff06f          	j	718a <_ftoa+0x7a>
    7e6e:	0001                	nop
    7e70:	00387813          	andi	a6,a6,3
    7e74:	8c32                	mv	s8,a2
    7e76:	12081963          	bnez	a6,7fa8 <_ftoa+0xe98>
    7e7a:	4291                	li	t0,4
    7e7c:	7c0ab50b          	th.extu	a0,s5,31,0
    7e80:	1352f463          	bgeu	t0,s5,7fa8 <_ftoa+0xe98>
    7e84:	ffc60793          	addi	a5,a2,-4
    7e88:	00a78c33          	add	s8,a5,a0
    7e8c:	40cc05b3          	sub	a1,s8,a2
    7e90:	0075fe93          	andi	t4,a1,7
    7e94:	8b32                	mv	s6,a2
    7e96:	080e8763          	beqz	t4,7f24 <_ftoa+0xe14>
    7e9a:	4605                	li	a2,1
    7e9c:	06ce8b63          	beq	t4,a2,7f12 <_ftoa+0xe02>
    7ea0:	4689                	li	a3,2
    7ea2:	06de8163          	beq	t4,a3,7f04 <_ftoa+0xdf4>
    7ea6:	488d                	li	a7,3
    7ea8:	051e8763          	beq	t4,a7,7ef6 <_ftoa+0xde6>
    7eac:	025e8e63          	beq	t4,t0,7ee8 <_ftoa+0xdd8>
    7eb0:	4f95                	li	t6,5
    7eb2:	03fe8463          	beq	t4,t6,7eda <_ftoa+0xdca>
    7eb6:	4399                	li	t2,6
    7eb8:	007e8a63          	beq	t4,t2,7ecc <_ftoa+0xdbc>
    7ebc:	86ca                	mv	a3,s2
    7ebe:	864e                	mv	a2,s3
    7ec0:	85a6                	mv	a1,s1
    7ec2:	02000513          	li	a0,32
    7ec6:	00198b13          	addi	s6,s3,1
    7eca:	9402                	jalr	s0
    7ecc:	865a                	mv	a2,s6
    7ece:	86ca                	mv	a3,s2
    7ed0:	85a6                	mv	a1,s1
    7ed2:	02000513          	li	a0,32
    7ed6:	0b05                	addi	s6,s6,1
    7ed8:	9402                	jalr	s0
    7eda:	865a                	mv	a2,s6
    7edc:	86ca                	mv	a3,s2
    7ede:	85a6                	mv	a1,s1
    7ee0:	02000513          	li	a0,32
    7ee4:	0b05                	addi	s6,s6,1
    7ee6:	9402                	jalr	s0
    7ee8:	865a                	mv	a2,s6
    7eea:	86ca                	mv	a3,s2
    7eec:	85a6                	mv	a1,s1
    7eee:	02000513          	li	a0,32
    7ef2:	0b05                	addi	s6,s6,1
    7ef4:	9402                	jalr	s0
    7ef6:	865a                	mv	a2,s6
    7ef8:	86ca                	mv	a3,s2
    7efa:	85a6                	mv	a1,s1
    7efc:	02000513          	li	a0,32
    7f00:	0b05                	addi	s6,s6,1
    7f02:	9402                	jalr	s0
    7f04:	865a                	mv	a2,s6
    7f06:	86ca                	mv	a3,s2
    7f08:	85a6                	mv	a1,s1
    7f0a:	02000513          	li	a0,32
    7f0e:	0b05                	addi	s6,s6,1
    7f10:	9402                	jalr	s0
    7f12:	865a                	mv	a2,s6
    7f14:	86ca                	mv	a3,s2
    7f16:	0b05                	addi	s6,s6,1
    7f18:	85a6                	mv	a1,s1
    7f1a:	02000513          	li	a0,32
    7f1e:	9402                	jalr	s0
    7f20:	098b0463          	beq	s6,s8,7fa8 <_ftoa+0xe98>
    7f24:	865a                	mv	a2,s6
    7f26:	86ca                	mv	a3,s2
    7f28:	85a6                	mv	a1,s1
    7f2a:	02000513          	li	a0,32
    7f2e:	9402                	jalr	s0
    7f30:	001b0b93          	addi	s7,s6,1
    7f34:	865e                	mv	a2,s7
    7f36:	86ca                	mv	a3,s2
    7f38:	85a6                	mv	a1,s1
    7f3a:	02000513          	li	a0,32
    7f3e:	9402                	jalr	s0
    7f40:	002b0c93          	addi	s9,s6,2
    7f44:	8666                	mv	a2,s9
    7f46:	86ca                	mv	a3,s2
    7f48:	85a6                	mv	a1,s1
    7f4a:	02000513          	li	a0,32
    7f4e:	9402                	jalr	s0
    7f50:	003b0b93          	addi	s7,s6,3
    7f54:	865e                	mv	a2,s7
    7f56:	86ca                	mv	a3,s2
    7f58:	85a6                	mv	a1,s1
    7f5a:	02000513          	li	a0,32
    7f5e:	9402                	jalr	s0
    7f60:	004b0c93          	addi	s9,s6,4
    7f64:	8666                	mv	a2,s9
    7f66:	86ca                	mv	a3,s2
    7f68:	85a6                	mv	a1,s1
    7f6a:	02000513          	li	a0,32
    7f6e:	9402                	jalr	s0
    7f70:	005b0b93          	addi	s7,s6,5
    7f74:	865e                	mv	a2,s7
    7f76:	86ca                	mv	a3,s2
    7f78:	85a6                	mv	a1,s1
    7f7a:	02000513          	li	a0,32
    7f7e:	9402                	jalr	s0
    7f80:	006b0c93          	addi	s9,s6,6
    7f84:	86ca                	mv	a3,s2
    7f86:	8666                	mv	a2,s9
    7f88:	85a6                	mv	a1,s1
    7f8a:	02000513          	li	a0,32
    7f8e:	9402                	jalr	s0
    7f90:	007b0b93          	addi	s7,s6,7
    7f94:	86ca                	mv	a3,s2
    7f96:	0b21                	addi	s6,s6,8
    7f98:	865e                	mv	a2,s7
    7f9a:	85a6                	mv	a1,s1
    7f9c:	02000513          	li	a0,32
    7fa0:	9402                	jalr	s0
    7fa2:	f98b11e3          	bne	s6,s8,7f24 <_ftoa+0xe14>
    7fa6:	0001                	nop
    7fa8:	6745                	lui	a4,0x11
    7faa:	ae070b13          	addi	s6,a4,-1312 # 10ae0 <__errno+0x5b4>
    7fae:	ffcb0c93          	addi	s9,s6,-4
    7fb2:	018b0bb3          	add	s7,s6,s8
    7fb6:	0001                	nop
    7fb8:	003b4503          	lbu	a0,3(s6)
    7fbc:	416b8633          	sub	a2,s7,s6
    7fc0:	86ca                	mv	a3,s2
    7fc2:	85a6                	mv	a1,s1
    7fc4:	1b7d                	addi	s6,s6,-1
    7fc6:	9402                	jalr	s0
    7fc8:	ff6c98e3          	bne	s9,s6,7fb8 <_ftoa+0xea8>
    7fcc:	002a7e13          	andi	t3,s4,2
    7fd0:	004c0b13          	addi	s6,s8,4
    7fd4:	e20e0f63          	beqz	t3,7612 <_ftoa+0x502>
    7fd8:	7c0aba8b          	th.extu	s5,s5,31,0
    7fdc:	413b0f33          	sub	t5,s6,s3
    7fe0:	e35f7963          	bgeu	t5,s5,7612 <_ftoa+0x502>
    7fe4:	fffb4313          	not	t1,s6
    7fe8:	01530a33          	add	s4,t1,s5
    7fec:	013a0833          	add	a6,s4,s3
    7ff0:	865a                	mv	a2,s6
    7ff2:	02000513          	li	a0,32
    7ff6:	86ca                	mv	a3,s2
    7ff8:	85a6                	mv	a1,s1
    7ffa:	00787c93          	andi	s9,a6,7
    7ffe:	005c0b13          	addi	s6,s8,5
    8002:	9402                	jalr	s0
    8004:	413b0533          	sub	a0,s6,s3
    8008:	e1557563          	bgeu	a0,s5,7612 <_ftoa+0x502>
    800c:	080c8963          	beqz	s9,809e <_ftoa+0xf8e>
    8010:	4285                	li	t0,1
    8012:	065c8b63          	beq	s9,t0,8088 <_ftoa+0xf78>
    8016:	4789                	li	a5,2
    8018:	06fc8163          	beq	s9,a5,807a <_ftoa+0xf6a>
    801c:	4c0d                	li	s8,3
    801e:	058c8763          	beq	s9,s8,806c <_ftoa+0xf5c>
    8022:	4591                	li	a1,4
    8024:	02bc8d63          	beq	s9,a1,805e <_ftoa+0xf4e>
    8028:	4e95                	li	t4,5
    802a:	03dc8363          	beq	s9,t4,8050 <_ftoa+0xf40>
    802e:	4619                	li	a2,6
    8030:	00cc8963          	beq	s9,a2,8042 <_ftoa+0xf32>
    8034:	865a                	mv	a2,s6
    8036:	86ca                	mv	a3,s2
    8038:	85a6                	mv	a1,s1
    803a:	02000513          	li	a0,32
    803e:	0b05                	addi	s6,s6,1
    8040:	9402                	jalr	s0
    8042:	865a                	mv	a2,s6
    8044:	86ca                	mv	a3,s2
    8046:	85a6                	mv	a1,s1
    8048:	02000513          	li	a0,32
    804c:	0b05                	addi	s6,s6,1
    804e:	9402                	jalr	s0
    8050:	865a                	mv	a2,s6
    8052:	86ca                	mv	a3,s2
    8054:	85a6                	mv	a1,s1
    8056:	02000513          	li	a0,32
    805a:	0b05                	addi	s6,s6,1
    805c:	9402                	jalr	s0
    805e:	865a                	mv	a2,s6
    8060:	86ca                	mv	a3,s2
    8062:	85a6                	mv	a1,s1
    8064:	02000513          	li	a0,32
    8068:	0b05                	addi	s6,s6,1
    806a:	9402                	jalr	s0
    806c:	865a                	mv	a2,s6
    806e:	86ca                	mv	a3,s2
    8070:	85a6                	mv	a1,s1
    8072:	02000513          	li	a0,32
    8076:	0b05                	addi	s6,s6,1
    8078:	9402                	jalr	s0
    807a:	865a                	mv	a2,s6
    807c:	86ca                	mv	a3,s2
    807e:	85a6                	mv	a1,s1
    8080:	02000513          	li	a0,32
    8084:	0b05                	addi	s6,s6,1
    8086:	9402                	jalr	s0
    8088:	865a                	mv	a2,s6
    808a:	86ca                	mv	a3,s2
    808c:	85a6                	mv	a1,s1
    808e:	02000513          	li	a0,32
    8092:	0b05                	addi	s6,s6,1
    8094:	9402                	jalr	s0
    8096:	413b06b3          	sub	a3,s6,s3
    809a:	d756fc63          	bgeu	a3,s5,7612 <_ftoa+0x502>
    809e:	865a                	mv	a2,s6
    80a0:	86ca                	mv	a3,s2
    80a2:	85a6                	mv	a1,s1
    80a4:	02000513          	li	a0,32
    80a8:	9402                	jalr	s0
    80aa:	001b0a13          	addi	s4,s6,1
    80ae:	8652                	mv	a2,s4
    80b0:	86ca                	mv	a3,s2
    80b2:	85a6                	mv	a1,s1
    80b4:	02000513          	li	a0,32
    80b8:	9402                	jalr	s0
    80ba:	002b0b93          	addi	s7,s6,2
    80be:	865e                	mv	a2,s7
    80c0:	86ca                	mv	a3,s2
    80c2:	85a6                	mv	a1,s1
    80c4:	02000513          	li	a0,32
    80c8:	9402                	jalr	s0
    80ca:	003b0c93          	addi	s9,s6,3
    80ce:	8666                	mv	a2,s9
    80d0:	86ca                	mv	a3,s2
    80d2:	85a6                	mv	a1,s1
    80d4:	02000513          	li	a0,32
    80d8:	9402                	jalr	s0
    80da:	004b0c13          	addi	s8,s6,4
    80de:	86ca                	mv	a3,s2
    80e0:	8662                	mv	a2,s8
    80e2:	85a6                	mv	a1,s1
    80e4:	02000513          	li	a0,32
    80e8:	9402                	jalr	s0
    80ea:	005b0a13          	addi	s4,s6,5
    80ee:	86ca                	mv	a3,s2
    80f0:	8652                	mv	a2,s4
    80f2:	85a6                	mv	a1,s1
    80f4:	02000513          	li	a0,32
    80f8:	9402                	jalr	s0
    80fa:	006b0b93          	addi	s7,s6,6
    80fe:	86ca                	mv	a3,s2
    8100:	865e                	mv	a2,s7
    8102:	85a6                	mv	a1,s1
    8104:	02000513          	li	a0,32
    8108:	9402                	jalr	s0
    810a:	007b0c93          	addi	s9,s6,7
    810e:	86ca                	mv	a3,s2
    8110:	8666                	mv	a2,s9
    8112:	85a6                	mv	a1,s1
    8114:	02000513          	li	a0,32
    8118:	0b21                	addi	s6,s6,8
    811a:	9402                	jalr	s0
    811c:	413b06b3          	sub	a3,s6,s3
    8120:	f756efe3          	bltu	a3,s5,809e <_ftoa+0xf8e>
    8124:	ceeff06f          	j	7612 <_ftoa+0x502>
    8128:	4e85                	li	t4,1
    812a:	418e8633          	sub	a2,t4,s8
    812e:	003a7593          	andi	a1,s4,3
    8132:	00f60fb3          	add	t6,a2,a5
    8136:	1dd58fe3          	beq	a1,t4,8b14 <_ftoa+0x1a04>
    813a:	02000393          	li	t2,32
    813e:	107f8be3          	beq	t6,t2,8a54 <_ftoa+0x1944>
    8142:	04080be3          	beqz	a6,8998 <_ftoa+0x1888>
    8146:	007f8333          	add	t1,t6,t2
    814a:	00230733          	add	a4,t1,sp
    814e:	02d00513          	li	a0,45
    8152:	001f8b13          	addi	s6,t6,1
    8156:	fea70823          	sb	a0,-16(a4)
    815a:	a80592e3          	bnez	a1,7bde <_ftoa+0xace>
    815e:	7c0ab28b          	th.extu	t0,s5,31,0
    8162:	a65b7ee3          	bgeu	s6,t0,7bde <_ftoa+0xace>
    8166:	416285b3          	sub	a1,t0,s6
    816a:	0075f793          	andi	a5,a1,7
    816e:	01358d33          	add	s10,a1,s3
    8172:	8bce                	mv	s7,s3
    8174:	c7d9                	beqz	a5,8202 <_ftoa+0x10f2>
    8176:	4e85                	li	t4,1
    8178:	07d78c63          	beq	a5,t4,81f0 <_ftoa+0x10e0>
    817c:	4609                	li	a2,2
    817e:	06c78263          	beq	a5,a2,81e2 <_ftoa+0x10d2>
    8182:	438d                	li	t2,3
    8184:	04778863          	beq	a5,t2,81d4 <_ftoa+0x10c4>
    8188:	4891                	li	a7,4
    818a:	03178e63          	beq	a5,a7,81c6 <_ftoa+0x10b6>
    818e:	4e15                	li	t3,5
    8190:	03c78463          	beq	a5,t3,81b8 <_ftoa+0x10a8>
    8194:	4f19                	li	t5,6
    8196:	01e78a63          	beq	a5,t5,81aa <_ftoa+0x109a>
    819a:	86ca                	mv	a3,s2
    819c:	864e                	mv	a2,s3
    819e:	85a6                	mv	a1,s1
    81a0:	02000513          	li	a0,32
    81a4:	00198b93          	addi	s7,s3,1
    81a8:	9402                	jalr	s0
    81aa:	865e                	mv	a2,s7
    81ac:	86ca                	mv	a3,s2
    81ae:	85a6                	mv	a1,s1
    81b0:	02000513          	li	a0,32
    81b4:	0b85                	addi	s7,s7,1
    81b6:	9402                	jalr	s0
    81b8:	865e                	mv	a2,s7
    81ba:	86ca                	mv	a3,s2
    81bc:	85a6                	mv	a1,s1
    81be:	02000513          	li	a0,32
    81c2:	0b85                	addi	s7,s7,1
    81c4:	9402                	jalr	s0
    81c6:	865e                	mv	a2,s7
    81c8:	86ca                	mv	a3,s2
    81ca:	85a6                	mv	a1,s1
    81cc:	02000513          	li	a0,32
    81d0:	0b85                	addi	s7,s7,1
    81d2:	9402                	jalr	s0
    81d4:	865e                	mv	a2,s7
    81d6:	86ca                	mv	a3,s2
    81d8:	85a6                	mv	a1,s1
    81da:	02000513          	li	a0,32
    81de:	0b85                	addi	s7,s7,1
    81e0:	9402                	jalr	s0
    81e2:	865e                	mv	a2,s7
    81e4:	86ca                	mv	a3,s2
    81e6:	85a6                	mv	a1,s1
    81e8:	02000513          	li	a0,32
    81ec:	0b85                	addi	s7,s7,1
    81ee:	9402                	jalr	s0
    81f0:	865e                	mv	a2,s7
    81f2:	86ca                	mv	a3,s2
    81f4:	0b85                	addi	s7,s7,1
    81f6:	85a6                	mv	a1,s1
    81f8:	02000513          	li	a0,32
    81fc:	9402                	jalr	s0
    81fe:	9f7d01e3          	beq	s10,s7,7be0 <_ftoa+0xad0>
    8202:	fc6e                	sd	s11,56(sp)
    8204:	865e                	mv	a2,s7
    8206:	86ca                	mv	a3,s2
    8208:	85a6                	mv	a1,s1
    820a:	02000513          	li	a0,32
    820e:	9402                	jalr	s0
    8210:	001b8c93          	addi	s9,s7,1
    8214:	8666                	mv	a2,s9
    8216:	86ca                	mv	a3,s2
    8218:	85a6                	mv	a1,s1
    821a:	02000513          	li	a0,32
    821e:	9402                	jalr	s0
    8220:	002b8d93          	addi	s11,s7,2
    8224:	866e                	mv	a2,s11
    8226:	86ca                	mv	a3,s2
    8228:	85a6                	mv	a1,s1
    822a:	02000513          	li	a0,32
    822e:	9402                	jalr	s0
    8230:	003b8c93          	addi	s9,s7,3
    8234:	8666                	mv	a2,s9
    8236:	86ca                	mv	a3,s2
    8238:	85a6                	mv	a1,s1
    823a:	02000513          	li	a0,32
    823e:	9402                	jalr	s0
    8240:	004b8d93          	addi	s11,s7,4
    8244:	866e                	mv	a2,s11
    8246:	86ca                	mv	a3,s2
    8248:	85a6                	mv	a1,s1
    824a:	02000513          	li	a0,32
    824e:	9402                	jalr	s0
    8250:	005b8c93          	addi	s9,s7,5
    8254:	8666                	mv	a2,s9
    8256:	86ca                	mv	a3,s2
    8258:	85a6                	mv	a1,s1
    825a:	02000513          	li	a0,32
    825e:	9402                	jalr	s0
    8260:	006b8d93          	addi	s11,s7,6
    8264:	86ca                	mv	a3,s2
    8266:	866e                	mv	a2,s11
    8268:	85a6                	mv	a1,s1
    826a:	02000513          	li	a0,32
    826e:	9402                	jalr	s0
    8270:	007b8c93          	addi	s9,s7,7
    8274:	86ca                	mv	a3,s2
    8276:	0ba1                	addi	s7,s7,8
    8278:	8666                	mv	a2,s9
    827a:	85a6                	mv	a1,s1
    827c:	02000513          	li	a0,32
    8280:	9402                	jalr	s0
    8282:	f97d11e3          	bne	s10,s7,8204 <_ftoa+0x10f4>
    8286:	7de2                	ld	s11,56(sp)
    8288:	baa1                	j	7be0 <_ftoa+0xad0>
    828a:	0001                	nop
    828c:	4305                	li	t1,1
    828e:	41830733          	sub	a4,t1,s8
    8292:	00c702b3          	add	t0,a4,a2
    8296:	02000393          	li	t2,32
    829a:	0e728363          	beq	t0,t2,8380 <_ftoa+0x1270>
    829e:	7c0eb50b          	th.extu	a0,t4,31,0
    82a2:	00757b93          	andi	s7,a0,7
    82a6:	00550b33          	add	s6,a0,t0
    82aa:	03000893          	li	a7,48
    82ae:	060b8663          	beqz	s7,831a <_ftoa+0x120a>
    82b2:	005c588b          	th.srb	a7,s8,t0,0
    82b6:	0285                	addi	t0,t0,1
    82b8:	0c728463          	beq	t0,t2,8380 <_ftoa+0x1270>
    82bc:	046b8f63          	beq	s7,t1,831a <_ftoa+0x120a>
    82c0:	4c89                	li	s9,2
    82c2:	059b8763          	beq	s7,s9,8310 <_ftoa+0x1200>
    82c6:	4d0d                	li	s10,3
    82c8:	03ab8f63          	beq	s7,s10,8306 <_ftoa+0x11f6>
    82cc:	4e11                	li	t3,4
    82ce:	03cb8763          	beq	s7,t3,82fc <_ftoa+0x11ec>
    82d2:	4e95                	li	t4,5
    82d4:	01db8f63          	beq	s7,t4,82f2 <_ftoa+0x11e2>
    82d8:	4f19                	li	t5,6
    82da:	01eb8763          	beq	s7,t5,82e8 <_ftoa+0x11d8>
    82de:	005c588b          	th.srb	a7,s8,t0,0
    82e2:	0285                	addi	t0,t0,1
    82e4:	08728e63          	beq	t0,t2,8380 <_ftoa+0x1270>
    82e8:	005c588b          	th.srb	a7,s8,t0,0
    82ec:	0285                	addi	t0,t0,1
    82ee:	08728963          	beq	t0,t2,8380 <_ftoa+0x1270>
    82f2:	005c588b          	th.srb	a7,s8,t0,0
    82f6:	0285                	addi	t0,t0,1
    82f8:	08728463          	beq	t0,t2,8380 <_ftoa+0x1270>
    82fc:	005c588b          	th.srb	a7,s8,t0,0
    8300:	0285                	addi	t0,t0,1
    8302:	06728f63          	beq	t0,t2,8380 <_ftoa+0x1270>
    8306:	005c588b          	th.srb	a7,s8,t0,0
    830a:	0285                	addi	t0,t0,1
    830c:	06728a63          	beq	t0,t2,8380 <_ftoa+0x1270>
    8310:	005c588b          	th.srb	a7,s8,t0,0
    8314:	0285                	addi	t0,t0,1
    8316:	06728563          	beq	t0,t2,8380 <_ftoa+0x1270>
    831a:	665b0463          	beq	s6,t0,8982 <_ftoa+0x1872>
    831e:	005c588b          	th.srb	a7,s8,t0,0
    8322:	00128f93          	addi	t6,t0,1
    8326:	047f8d63          	beq	t6,t2,8380 <_ftoa+0x1270>
    832a:	01fc588b          	th.srb	a7,s8,t6,0
    832e:	00228313          	addi	t1,t0,2
    8332:	04730763          	beq	t1,t2,8380 <_ftoa+0x1270>
    8336:	006c588b          	th.srb	a7,s8,t1,0
    833a:	00328713          	addi	a4,t0,3
    833e:	04770163          	beq	a4,t2,8380 <_ftoa+0x1270>
    8342:	00ec588b          	th.srb	a7,s8,a4,0
    8346:	00428513          	addi	a0,t0,4
    834a:	02750b63          	beq	a0,t2,8380 <_ftoa+0x1270>
    834e:	00ac588b          	th.srb	a7,s8,a0,0
    8352:	00528b93          	addi	s7,t0,5
    8356:	027b8563          	beq	s7,t2,8380 <_ftoa+0x1270>
    835a:	017c588b          	th.srb	a7,s8,s7,0
    835e:	00628c93          	addi	s9,t0,6
    8362:	007c8f63          	beq	s9,t2,8380 <_ftoa+0x1270>
    8366:	019c588b          	th.srb	a7,s8,s9,0
    836a:	00728d13          	addi	s10,t0,7
    836e:	007d0963          	beq	s10,t2,8380 <_ftoa+0x1270>
    8372:	01ac588b          	th.srb	a7,s8,s10,0
    8376:	02a1                	addi	t0,t0,8
    8378:	fa7291e3          	bne	t0,t2,831a <_ftoa+0x120a>
    837c:	00000013          	nop
    8380:	02000f93          	li	t6,32
    8384:	d8cff06f          	j	7910 <_ftoa+0x800>
    8388:	e20506d3          	fmv.x.d	a3,fa0
    838c:	fc6e                	sd	s11,56(sp)
    838e:	fb46b58b          	th.extu	a1,a3,62,52
    8392:	6ec5                	lui	t4,0x11
    8394:	6645                	lui	a2,0x11
    8396:	bb8ebf07          	fld	ft10,-1096(t4) # 10bb8 <errpat+0x70>
    839a:	bc063f87          	fld	ft11,-1088(a2) # 10bc0 <errpat+0x78>
    839e:	c015879b          	addiw	a5,a1,-1023
    83a2:	d2078ed3          	fcvt.d.w	ft9,a5
    83a6:	3ff00893          	li	a7,1023
    83aa:	6e45                	lui	t3,0x11
    83ac:	03489b13          	slli	s6,a7,0x34
    83b0:	bc8e3787          	fld	fa5,-1080(t3) # 10bc8 <errpat+0x80>
    83b4:	cc06b38b          	th.extu	t2,a3,51,0
    83b8:	fbeef043          	fmadd.d	ft0,ft9,ft10,ft11
    83bc:	0163edb3          	or	s11,t2,s6
    83c0:	f20d80d3          	fmv.d.x	ft1,s11
    83c4:	6f45                	lui	t5,0x11
    83c6:	0af0f153          	fsub.d	ft2,ft1,fa5
    83ca:	bd0f3187          	fld	ft3,-1072(t5) # 10bd0 <errpat+0x88>
    83ce:	6845                	lui	a6,0x11
    83d0:	6545                	lui	a0,0x11
    83d2:	023176c3          	fmadd.d	fa3,ft2,ft3,ft0
    83d6:	bd883287          	fld	ft5,-1064(a6) # 10bd8 <errpat+0x90>
    83da:	be053307          	fld	ft6,-1056(a0) # 10be0 <errpat+0x98>
    83de:	6c45                	lui	s8,0x11
    83e0:	be8c3587          	fld	fa1,-1048(s8) # 10be8 <errpat+0xa0>
    83e4:	c2069353          	fcvt.w.d	t1,fa3,rtz
    83e8:	6bc5                	lui	s7,0x11
    83ea:	d2030253          	fcvt.d.w	ft4,t1
    83ee:	bf0bb807          	fld	fa6,-1040(s7) # 10bf0 <errpat+0xa8>
    83f2:	32527743          	fmadd.d	fa4,ft4,ft5,ft6
    83f6:	4299                	li	t0,6
    83f8:	400a7f93          	andi	t6,s4,1024
    83fc:	41f2970b          	th.mveqz	a4,t0,t6
    8400:	62c5                	lui	t0,0x11
    8402:	c2071d53          	fcvt.w.d	s10,fa4,rtz
    8406:	bf82bf07          	fld	ft10,-1032(t0) # 10bf8 <errpat+0xb0>
    840a:	d20d03d3          	fcvt.d.w	ft7,s10
    840e:	65c5                	lui	a1,0x11
    8410:	12b3f653          	fmul.d	fa2,ft7,fa1
    8414:	b805b087          	fld	ft1,-1152(a1) # 10b80 <errpat+0x38>
    8418:	67c5                	lui	a5,0x11
    841a:	c007b107          	fld	ft2,-1024(a5) # 10c00 <errpat+0xb8>
    841e:	630278c7          	fmsub.d	fa7,ft4,fa6,fa2
    8422:	6ec5                	lui	t4,0x11
    8424:	c08eb207          	fld	ft4,-1016(t4) # 10c08 <errpat+0xc0>
    8428:	6645                	lui	a2,0x11
    842a:	b9063707          	fld	fa4,-1136(a2) # 10b90 <errpat+0x48>
    842e:	1318fe53          	fmul.d	ft8,fa7,fa7
    8432:	0b1272d3          	fsub.d	ft5,ft4,fa7
    8436:	0318fed3          	fadd.d	ft9,fa7,fa7
    843a:	3ffd039b          	addiw	t2,s10,1023
    843e:	1bee7fd3          	fdiv.d	ft11,ft8,ft10
    8442:	03439893          	slli	a7,t2,0x34
    8446:	f2088653          	fmv.d.x	fa2,a7
    844a:	f2068853          	fmv.d.x	fa6,a3
    844e:	00030c9b          	sext.w	s9,t1
    8452:	021ff053          	fadd.d	ft0,ft11,ft1
    8456:	1a0e77d3          	fdiv.d	fa5,ft8,ft0
    845a:	0227f1d3          	fadd.d	ft3,fa5,ft2
    845e:	1a3e76d3          	fdiv.d	fa3,ft8,ft3
    8462:	0256f353          	fadd.d	ft6,fa3,ft5
    8466:	1a6ef3d3          	fdiv.d	ft7,ft9,ft6
    846a:	02e3f5d3          	fadd.d	fa1,ft7,fa4
    846e:	12c5f8d3          	fmul.d	fa7,fa1,fa2
    8472:	a3181b53          	flt.d	s6,fa6,fa7
    8476:	000b0663          	beqz	s6,8482 <_ftoa+0x1372>
    847a:	1a18f8d3          	fdiv.d	fa7,fa7,ft1
    847e:	fff30c9b          	addiw	s9,t1,-1
    8482:	6505                	lui	a0,0x1
    8484:	063c8d9b          	addiw	s11,s9,99
    8488:	0c600e13          	li	t3,198
    848c:	80050c13          	addi	s8,a0,-2048 # 800 <cmp_complex+0xc0>
    8490:	01be3f33          	sltu	t5,t3,s11
    8494:	4b89                	li	s7,2
    8496:	4d0d                	li	s10,3
    8498:	4315                	li	t1,5
    849a:	4811                	li	a6,4
    849c:	018a77b3          	and	a5,s4,s8
    84a0:	41eb9d0b          	th.mveqz	s10,s7,t5
    84a4:	41e8130b          	th.mveqz	t1,a6,t5
    84a8:	50078c63          	beqz	a5,89c0 <_ftoa+0x18b0>
    84ac:	fff7059b          	addiw	a1,a4,-1
    84b0:	41f7158b          	th.mveqz	a1,a4,t6
    84b4:	406a87bb          	subw	a5,s5,t1
    84b8:	01533eb3          	sltu	t4,t1,s5
    84bc:	002a7613          	andi	a2,s4,2
    84c0:	42e5970b          	th.mvnez	a4,a1,a4
    84c4:	41d0178b          	th.mveqz	a5,zero,t4
    84c8:	50060263          	beqz	a2,89cc <_ftoa+0x18bc>
    84cc:	4781                	li	a5,0
    84ce:	0001                	nop
    84d0:	000c8863          	beqz	s9,84e0 <_ftoa+0x13d0>
    84d4:	f2068e53          	fmv.d.x	ft8,a3
    84d8:	1b1e7ed3          	fdiv.d	ft9,ft8,fa7
    84dc:	e20e86d3          	fmv.x.d	a3,ft9
    84e0:	f2000f53          	fmv.d.x	ft10,zero
    84e4:	a3e513d3          	flt.d	t2,fa0,ft10
    84e8:	00038863          	beqz	t2,84f8 <_ftoa+0x13e8>
    84ec:	f2068553          	fmv.d.x	fa0,a3
    84f0:	22a51fd3          	fneg.d	ft11,fa0
    84f4:	e20f86d3          	fmv.x.d	a3,ft11
    84f8:	78fd                	lui	a7,0xfffff
    84fa:	7ff88b13          	addi	s6,a7,2047 # fffffffffffff7ff <__kernel_stack+0xfffffffffff117ff>
    84fe:	016a7833          	and	a6,s4,s6
    8502:	f2068553          	fmv.d.x	fa0,a3
    8506:	864e                	mv	a2,s3
    8508:	86ca                	mv	a3,s2
    850a:	85a6                	mv	a1,s1
    850c:	8522                	mv	a0,s0
    850e:	c03fe0ef          	jal	7110 <_ftoa>
    8512:	020a7713          	andi	a4,s4,32
    8516:	862a                	mv	a2,a0
    8518:	00150a13          	addi	s4,a0,1
    851c:	06500793          	li	a5,101
    8520:	8daa                	mv	s11,a0
    8522:	04500513          	li	a0,69
    8526:	e452                	sd	s4,8(sp)
    8528:	86ca                	mv	a3,s2
    852a:	40e7950b          	th.mveqz	a0,a5,a4
    852e:	85a6                	mv	a1,s1
    8530:	9402                	jalr	s0
    8532:	41fcde1b          	sraiw	t3,s9,0x1f
    8536:	01cccf33          	xor	t5,s9,t3
    853a:	41cf033b          	subw	t1,t5,t3
    853e:	4c29                	li	s8,10
    8540:	03837833          	remu	a6,t1,s8
    8544:	01010a13          	addi	s4,sp,16
    8548:	4fa5                	li	t6,9
    854a:	86d2                	mv	a3,s4
    854c:	0308051b          	addiw	a0,a6,48
    8550:	00aa0023          	sb	a0,0(s4)
    8554:	038358b3          	divu	a7,t1,s8
    8558:	106ff863          	bgeu	t6,t1,8668 <_ftoa+0x1558>
    855c:	01110693          	addi	a3,sp,17
    8560:	0388f2b3          	remu	t0,a7,s8
    8564:	0302859b          	addiw	a1,t0,48
    8568:	00b68023          	sb	a1,0(a3)
    856c:	0388deb3          	divu	t4,a7,s8
    8570:	0f1ffc63          	bgeu	t6,a7,8668 <_ftoa+0x1558>
    8574:	00168393          	addi	t2,a3,1
    8578:	1810                	addi	a2,sp,48
    857a:	0e760763          	beq	a2,t2,8668 <_ftoa+0x1558>
    857e:	869e                	mv	a3,t2
    8580:	038ef8b3          	remu	a7,t4,s8
    8584:	03088b1b          	addiw	s6,a7,48
    8588:	01638023          	sb	s6,0(t2)
    858c:	038ed733          	divu	a4,t4,s8
    8590:	0ddffc63          	bgeu	t6,t4,8668 <_ftoa+0x1558>
    8594:	038777b3          	remu	a5,a4,s8
    8598:	03078e1b          	addiw	t3,a5,48
    859c:	0816de0b          	th.sbib	t3,(a3),1,0
    85a0:	03875f33          	divu	t5,a4,s8
    85a4:	0ceff263          	bgeu	t6,a4,8668 <_ftoa+0x1558>
    85a8:	00238693          	addi	a3,t2,2
    85ac:	038f7333          	remu	t1,t5,s8
    85b0:	0303081b          	addiw	a6,t1,48
    85b4:	01038123          	sb	a6,2(t2)
    85b8:	038f5533          	divu	a0,t5,s8
    85bc:	0beff663          	bgeu	t6,t5,8668 <_ftoa+0x1558>
    85c0:	00338693          	addi	a3,t2,3
    85c4:	038572b3          	remu	t0,a0,s8
    85c8:	0302859b          	addiw	a1,t0,48
    85cc:	00b381a3          	sb	a1,3(t2)
    85d0:	03855eb3          	divu	t4,a0,s8
    85d4:	08affa63          	bgeu	t6,a0,8668 <_ftoa+0x1558>
    85d8:	00438693          	addi	a3,t2,4
    85dc:	038ef633          	remu	a2,t4,s8
    85e0:	0306089b          	addiw	a7,a2,48
    85e4:	01138223          	sb	a7,4(t2)
    85e8:	038edb33          	divu	s6,t4,s8
    85ec:	07dffe63          	bgeu	t6,t4,8668 <_ftoa+0x1558>
    85f0:	00538693          	addi	a3,t2,5
    85f4:	038b7733          	remu	a4,s6,s8
    85f8:	0307079b          	addiw	a5,a4,48
    85fc:	00f382a3          	sb	a5,5(t2)
    8600:	038b5e33          	divu	t3,s6,s8
    8604:	076ff263          	bgeu	t6,s6,8668 <_ftoa+0x1558>
    8608:	00638693          	addi	a3,t2,6
    860c:	038e7f33          	remu	t5,t3,s8
    8610:	030f031b          	addiw	t1,t5,48
    8614:	00638323          	sb	t1,6(t2)
    8618:	038e5833          	divu	a6,t3,s8
    861c:	05cff663          	bgeu	t6,t3,8668 <_ftoa+0x1558>
    8620:	00738693          	addi	a3,t2,7
    8624:	03887533          	remu	a0,a6,s8
    8628:	0305029b          	addiw	t0,a0,48
    862c:	005383a3          	sb	t0,7(t2)
    8630:	038855b3          	divu	a1,a6,s8
    8634:	030ffa63          	bgeu	t6,a6,8668 <_ftoa+0x1558>
    8638:	00838693          	addi	a3,t2,8
    863c:	0385feb3          	remu	t4,a1,s8
    8640:	030e861b          	addiw	a2,t4,48
    8644:	00c38423          	sb	a2,8(t2)
    8648:	0385d8b3          	divu	a7,a1,s8
    864c:	00bffe63          	bgeu	t6,a1,8668 <_ftoa+0x1558>
    8650:	00938693          	addi	a3,t2,9
    8654:	0388f2b3          	remu	t0,a7,s8
    8658:	0302859b          	addiw	a1,t0,48
    865c:	00b68023          	sb	a1,0(a3)
    8660:	0388deb3          	divu	t4,a7,s8
    8664:	f11fe8e3          	bltu	t6,a7,8574 <_ftoa+0x1464>
    8668:	4c05                	li	s8,1
    866a:	414c0fb3          	sub	t6,s8,s4
    866e:	00df8b33          	add	s6,t6,a3
    8672:	43ab7d63          	bgeu	s6,s10,8aac <_ftoa+0x199c>
    8676:	016a07b3          	add	a5,s4,s6
    867a:	01aa03b3          	add	t2,s4,s10
    867e:	40f386b3          	sub	a3,t2,a5
    8682:	0076fe13          	andi	t3,a3,7
    8686:	03000713          	li	a4,48
    868a:	380e0b63          	beqz	t3,8a20 <_ftoa+0x1910>
    868e:	038e0d63          	beq	t3,s8,86c8 <_ftoa+0x15b8>
    8692:	4f09                	li	t5,2
    8694:	03ee0863          	beq	t3,t5,86c4 <_ftoa+0x15b4>
    8698:	430d                	li	t1,3
    869a:	026e0363          	beq	t3,t1,86c0 <_ftoa+0x15b0>
    869e:	4811                	li	a6,4
    86a0:	010e0e63          	beq	t3,a6,86bc <_ftoa+0x15ac>
    86a4:	4515                	li	a0,5
    86a6:	00ae0963          	beq	t3,a0,86b8 <_ftoa+0x15a8>
    86aa:	4299                	li	t0,6
    86ac:	005e0463          	beq	t3,t0,86b4 <_ftoa+0x15a4>
    86b0:	1817d70b          	th.sbia	a4,(a5),1,0
    86b4:	1817d70b          	th.sbia	a4,(a5),1,0
    86b8:	1817d70b          	th.sbia	a4,(a5),1,0
    86bc:	1817d70b          	th.sbia	a4,(a5),1,0
    86c0:	1817d70b          	th.sbia	a4,(a5),1,0
    86c4:	1817d70b          	th.sbia	a4,(a5),1,0
    86c8:	1817d70b          	th.sbia	a4,(a5),1,0
    86cc:	34f39a63          	bne	t2,a5,8a20 <_ftoa+0x1910>
    86d0:	020d0593          	addi	a1,s10,32
    86d4:	01010e93          	addi	t4,sp,16
    86d8:	001d0b13          	addi	s6,s10,1
    86dc:	01d58633          	add	a2,a1,t4
    86e0:	400cdc63          	bgez	s9,8af8 <_ftoa+0x19e8>
    86e4:	02d00513          	li	a0,45
    86e8:	fea60023          	sb	a0,-32(a2)
    86ec:	016a0c33          	add	s8,s4,s6
    86f0:	fffa4893          	not	a7,s4
    86f4:	001a0c93          	addi	s9,s4,1
    86f8:	01888fb3          	add	t6,a7,s8
    86fc:	9de6                	add	s11,s11,s9
    86fe:	007ffd13          	andi	s10,t6,7
    8702:	016d8cb3          	add	s9,s11,s6
    8706:	100d0663          	beqz	s10,8812 <_ftoa+0x1702>
    870a:	418c8633          	sub	a2,s9,s8
    870e:	86ca                	mv	a3,s2
    8710:	85a6                	mv	a1,s1
    8712:	9402                	jalr	s0
    8714:	4385                	li	t2,1
    8716:	1c7d                	addi	s8,s8,-1
    8718:	fffc4503          	lbu	a0,-1(s8)
    871c:	0e7d0b63          	beq	s10,t2,8812 <_ftoa+0x1702>
    8720:	4709                	li	a4,2
    8722:	06ed0663          	beq	s10,a4,878e <_ftoa+0x167e>
    8726:	468d                	li	a3,3
    8728:	04dd0b63          	beq	s10,a3,877e <_ftoa+0x166e>
    872c:	4e11                	li	t3,4
    872e:	05cd0063          	beq	s10,t3,876e <_ftoa+0x165e>
    8732:	4f15                	li	t5,5
    8734:	03ed0563          	beq	s10,t5,875e <_ftoa+0x164e>
    8738:	4319                	li	t1,6
    873a:	006d0a63          	beq	s10,t1,874e <_ftoa+0x163e>
    873e:	418c8633          	sub	a2,s9,s8
    8742:	86ca                	mv	a3,s2
    8744:	85a6                	mv	a1,s1
    8746:	9402                	jalr	s0
    8748:	ffec4503          	lbu	a0,-2(s8)
    874c:	1c7d                	addi	s8,s8,-1
    874e:	418c8633          	sub	a2,s9,s8
    8752:	86ca                	mv	a3,s2
    8754:	85a6                	mv	a1,s1
    8756:	9402                	jalr	s0
    8758:	ffec4503          	lbu	a0,-2(s8)
    875c:	1c7d                	addi	s8,s8,-1
    875e:	418c8633          	sub	a2,s9,s8
    8762:	86ca                	mv	a3,s2
    8764:	85a6                	mv	a1,s1
    8766:	9402                	jalr	s0
    8768:	ffec4503          	lbu	a0,-2(s8)
    876c:	1c7d                	addi	s8,s8,-1
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
    8798:	1c7d                	addi	s8,s8,-1
    879a:	fffc4503          	lbu	a0,-1(s8)
    879e:	a895                	j	8812 <_ftoa+0x1702>
    87a0:	8de2                	mv	s11,s8
    87a2:	89edc50b          	th.lbuib	a0,(s11),-2,0
    87a6:	410c8633          	sub	a2,s9,a6
    87aa:	86ca                	mv	a3,s2
    87ac:	85a6                	mv	a1,s1
    87ae:	9402                	jalr	s0
    87b0:	8d62                	mv	s10,s8
    87b2:	89dd450b          	th.lbuib	a0,(s10),-3,0
    87b6:	41bc8633          	sub	a2,s9,s11
    87ba:	86ca                	mv	a3,s2
    87bc:	85a6                	mv	a1,s1
    87be:	9402                	jalr	s0
    87c0:	8de2                	mv	s11,s8
    87c2:	89cdc50b          	th.lbuib	a0,(s11),-4,0
    87c6:	41ac8633          	sub	a2,s9,s10
    87ca:	86ca                	mv	a3,s2
    87cc:	85a6                	mv	a1,s1
    87ce:	9402                	jalr	s0
    87d0:	8d62                	mv	s10,s8
    87d2:	89bd450b          	th.lbuib	a0,(s10),-5,0
    87d6:	41bc8633          	sub	a2,s9,s11
    87da:	86ca                	mv	a3,s2
    87dc:	85a6                	mv	a1,s1
    87de:	9402                	jalr	s0
    87e0:	8de2                	mv	s11,s8
    87e2:	89adc50b          	th.lbuib	a0,(s11),-6,0
    87e6:	41ac8633          	sub	a2,s9,s10
    87ea:	86ca                	mv	a3,s2
    87ec:	85a6                	mv	a1,s1
    87ee:	9402                	jalr	s0
    87f0:	8d62                	mv	s10,s8
    87f2:	899d450b          	th.lbuib	a0,(s10),-7,0
    87f6:	86ca                	mv	a3,s2
    87f8:	41bc8633          	sub	a2,s9,s11
    87fc:	85a6                	mv	a1,s1
    87fe:	9402                	jalr	s0
    8800:	898c450b          	th.lbuib	a0,(s8),-8,0
    8804:	86ca                	mv	a3,s2
    8806:	41ac8633          	sub	a2,s9,s10
    880a:	85a6                	mv	a1,s1
    880c:	9402                	jalr	s0
    880e:	fffc4503          	lbu	a0,-1(s8)
    8812:	86ca                	mv	a3,s2
    8814:	418c8633          	sub	a2,s9,s8
    8818:	85a6                	mv	a1,s1
    881a:	9402                	jalr	s0
    881c:	fffc0813          	addi	a6,s8,-1
    8820:	f90a10e3          	bne	s4,a6,87a0 <_ftoa+0x1690>
    8824:	6a22                	ld	s4,8(sp)
    8826:	9b52                	add	s6,s6,s4
    8828:	140b8963          	beqz	s7,897a <_ftoa+0x186a>
    882c:	413b09b3          	sub	s3,s6,s3
    8830:	7c0aba8b          	th.extu	s5,s5,31,0
    8834:	1559f363          	bgeu	s3,s5,897a <_ftoa+0x186a>
    8838:	fff9cb93          	not	s7,s3
    883c:	015b8533          	add	a0,s7,s5
    8840:	865a                	mv	a2,s6
    8842:	00757d93          	andi	s11,a0,7
    8846:	86ca                	mv	a3,s2
    8848:	85a6                	mv	a1,s1
    884a:	02000513          	li	a0,32
    884e:	00198d13          	addi	s10,s3,1
    8852:	0b05                	addi	s6,s6,1
    8854:	9402                	jalr	s0
    8856:	135d7263          	bgeu	s10,s5,897a <_ftoa+0x186a>
    885a:	080d8e63          	beqz	s11,88f6 <_ftoa+0x17e6>
    885e:	4285                	li	t0,1
    8860:	085d8163          	beq	s11,t0,88e2 <_ftoa+0x17d2>
    8864:	4789                	li	a5,2
    8866:	06fd8663          	beq	s11,a5,88d2 <_ftoa+0x17c2>
    886a:	458d                	li	a1,3
    886c:	04bd8b63          	beq	s11,a1,88c2 <_ftoa+0x17b2>
    8870:	4e91                	li	t4,4
    8872:	05dd8063          	beq	s11,t4,88b2 <_ftoa+0x17a2>
    8876:	4615                	li	a2,5
    8878:	02cd8563          	beq	s11,a2,88a2 <_ftoa+0x1792>
    887c:	4c99                	li	s9,6
    887e:	019d8a63          	beq	s11,s9,8892 <_ftoa+0x1782>
    8882:	865a                	mv	a2,s6
    8884:	86ca                	mv	a3,s2
    8886:	85a6                	mv	a1,s1
    8888:	02000513          	li	a0,32
    888c:	0b05                	addi	s6,s6,1
    888e:	9402                	jalr	s0
    8890:	0d05                	addi	s10,s10,1
    8892:	865a                	mv	a2,s6
    8894:	86ca                	mv	a3,s2
    8896:	85a6                	mv	a1,s1
    8898:	02000513          	li	a0,32
    889c:	0b05                	addi	s6,s6,1
    889e:	9402                	jalr	s0
    88a0:	0d05                	addi	s10,s10,1
    88a2:	865a                	mv	a2,s6
    88a4:	86ca                	mv	a3,s2
    88a6:	85a6                	mv	a1,s1
    88a8:	02000513          	li	a0,32
    88ac:	0b05                	addi	s6,s6,1
    88ae:	9402                	jalr	s0
    88b0:	0d05                	addi	s10,s10,1
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
    88ec:	0d05                	addi	s10,s10,1
    88ee:	0b05                	addi	s6,s6,1
    88f0:	9402                	jalr	s0
    88f2:	095d7463          	bgeu	s10,s5,897a <_ftoa+0x186a>
    88f6:	865a                	mv	a2,s6
    88f8:	86ca                	mv	a3,s2
    88fa:	85a6                	mv	a1,s1
    88fc:	02000513          	li	a0,32
    8900:	9402                	jalr	s0
    8902:	001b0c13          	addi	s8,s6,1
    8906:	8662                	mv	a2,s8
    8908:	86ca                	mv	a3,s2
    890a:	85a6                	mv	a1,s1
    890c:	02000513          	li	a0,32
    8910:	9402                	jalr	s0
    8912:	002b0993          	addi	s3,s6,2
    8916:	86ca                	mv	a3,s2
    8918:	864e                	mv	a2,s3
    891a:	85a6                	mv	a1,s1
    891c:	02000513          	li	a0,32
    8920:	9402                	jalr	s0
    8922:	003b0a13          	addi	s4,s6,3
    8926:	86ca                	mv	a3,s2
    8928:	8652                	mv	a2,s4
    892a:	85a6                	mv	a1,s1
    892c:	02000513          	li	a0,32
    8930:	9402                	jalr	s0
    8932:	004b0b93          	addi	s7,s6,4
    8936:	86ca                	mv	a3,s2
    8938:	865e                	mv	a2,s7
    893a:	85a6                	mv	a1,s1
    893c:	02000513          	li	a0,32
    8940:	9402                	jalr	s0
    8942:	005b0d93          	addi	s11,s6,5
    8946:	86ca                	mv	a3,s2
    8948:	866e                	mv	a2,s11
    894a:	85a6                	mv	a1,s1
    894c:	02000513          	li	a0,32
    8950:	9402                	jalr	s0
    8952:	006b0c93          	addi	s9,s6,6
    8956:	86ca                	mv	a3,s2
    8958:	8666                	mv	a2,s9
    895a:	85a6                	mv	a1,s1
    895c:	02000513          	li	a0,32
    8960:	9402                	jalr	s0
    8962:	007b0c13          	addi	s8,s6,7
    8966:	86ca                	mv	a3,s2
    8968:	8662                	mv	a2,s8
    896a:	85a6                	mv	a1,s1
    896c:	02000513          	li	a0,32
    8970:	0d21                	addi	s10,s10,8
    8972:	0b21                	addi	s6,s6,8
    8974:	9402                	jalr	s0
    8976:	f95d60e3          	bltu	s10,s5,88f6 <_ftoa+0x17e6>
    897a:	7de2                	ld	s11,56(sp)
    897c:	6d06                	ld	s10,64(sp)
    897e:	c95fe06f          	j	7612 <_ftoa+0x502>
    8982:	002b0633          	add	a2,s6,sp
    8986:	02e00693          	li	a3,46
    898a:	001b0f93          	addi	t6,s6,1
    898e:	00d60823          	sb	a3,16(a2)
    8992:	f7ffe06f          	j	7910 <_ftoa+0x800>
    8996:	0001                	nop
    8998:	004a7813          	andi	a6,s4,4
    899c:	02080e63          	beqz	a6,89d8 <_ftoa+0x18c8>
    89a0:	002f8f33          	add	t5,t6,sp
    89a4:	001f8b13          	addi	s6,t6,1
    89a8:	02b00f93          	li	t6,43
    89ac:	01ff0823          	sb	t6,16(t5)
    89b0:	faaff06f          	j	815a <_ftoa+0x104a>
    89b4:	8d4e                	mv	s10,s3
    89b6:	02000b13          	li	s6,32
    89ba:	a26ff06f          	j	7be0 <_ftoa+0xad0>
    89be:	0001                	nop
    89c0:	0f536d63          	bltu	t1,s5,8aba <_ftoa+0x19aa>
    89c4:	017a7fb3          	and	t6,s4,s7
    89c8:	b00f94e3          	bnez	t6,84d0 <_ftoa+0x13c0>
    89cc:	4b81                	li	s7,0
    89ce:	b609                	j	84d0 <_ftoa+0x13c0>
    89d0:	4585                	li	a1,1
    89d2:	0001                	nop
    89d4:	00000013          	nop
    89d8:	008a7513          	andi	a0,s4,8
    89dc:	8b7e                	mv	s6,t6
    89de:	f6050e63          	beqz	a0,815a <_ftoa+0x104a>
    89e2:	002f8cb3          	add	s9,t6,sp
    89e6:	02000d13          	li	s10,32
    89ea:	001f8b13          	addi	s6,t6,1
    89ee:	01ac8823          	sb	s10,16(s9)
    89f2:	f68ff06f          	j	815a <_ftoa+0x104a>
    89f6:	0001                	nop
    89f8:	0016f893          	andi	a7,a3,1
    89fc:	00089463          	bnez	a7,8a04 <_ftoa+0x18f4>
    8a00:	8c9fe06f          	j	72c8 <_ftoa+0x1b8>
    8a04:	0685                	addi	a3,a3,1
    8a06:	ee7fe06f          	j	78ec <_ftoa+0x7dc>
    8a0a:	0001                	nop
    8a0c:	417c8633          	sub	a2,s9,s7
    8a10:	89fbc50b          	th.lbuib	a0,(s7),-1,0
    8a14:	86ca                	mv	a3,s2
    8a16:	85a6                	mv	a1,s1
    8a18:	9402                	jalr	s0
    8a1a:	9fcff06f          	j	7c16 <_ftoa+0xb06>
    8a1e:	0001                	nop
    8a20:	00e78023          	sb	a4,0(a5)
    8a24:	00e780a3          	sb	a4,1(a5)
    8a28:	00e78123          	sb	a4,2(a5)
    8a2c:	00e781a3          	sb	a4,3(a5)
    8a30:	00e78223          	sb	a4,4(a5)
    8a34:	00e782a3          	sb	a4,5(a5)
    8a38:	00e78323          	sb	a4,6(a5)
    8a3c:	00e783a3          	sb	a4,7(a5)
    8a40:	07a1                	addi	a5,a5,8
    8a42:	fcf39fe3          	bne	t2,a5,8a20 <_ftoa+0x1910>
    8a46:	b169                	j	86d0 <_ftoa+0x15c0>
    8a48:	02000b13          	li	s6,32
    8a4c:	8d4e                	mv	s10,s3
    8a4e:	992ff06f          	j	7be0 <_ftoa+0xad0>
    8a52:	0001                	nop
    8a54:	02000b13          	li	s6,32
    8a58:	f02ff06f          	j	815a <_ftoa+0x104a>
    8a5c:	22a51e53          	fneg.d	ft8,fa0
    8a60:	fc6e                	sd	s11,56(sp)
    8a62:	e20e06d3          	fmv.x.d	a3,ft8
    8a66:	b225                	j	838e <_ftoa+0x127e>
    8a68:	02000b13          	li	s6,32
    8a6c:	00ca7e93          	andi	t4,s4,12
    8a70:	060e8b63          	beqz	t4,8ae6 <_ftoa+0x19d6>
    8a74:	3afd                	addiw	s5,s5,-1
    8a76:	7c0abf8b          	th.extu	t6,s5,31,0
    8a7a:	87fb6163          	bltu	s6,t6,7adc <_ftoa+0x9cc>
    8a7e:	02000393          	li	t2,32
    8a82:	947b0e63          	beq	s6,t2,7bde <_ftoa+0xace>
    8a86:	004a7813          	andi	a6,s4,4
    8a8a:	06080e63          	beqz	a6,8b06 <_ftoa+0x19f6>
    8a8e:	020b0e13          	addi	t3,s6,32
    8a92:	01010f13          	addi	t5,sp,16
    8a96:	01ee0fb3          	add	t6,t3,t5
    8a9a:	02b00313          	li	t1,43
    8a9e:	fe6f8023          	sb	t1,-32(t6)
    8aa2:	0b05                	addi	s6,s6,1
    8aa4:	8d4e                	mv	s10,s3
    8aa6:	93aff06f          	j	7be0 <_ftoa+0xad0>
    8aaa:	0001                	nop
    8aac:	02000d13          	li	s10,32
    8ab0:	05ab1963          	bne	s6,s10,8b02 <_ftoa+0x19f2>
    8ab4:	02f14503          	lbu	a0,47(sp)
    8ab8:	b915                	j	86ec <_ftoa+0x15dc>
    8aba:	002a7293          	andi	t0,s4,2
    8abe:	a00299e3          	bnez	t0,84d0 <_ftoa+0x13c0>
    8ac2:	406a87bb          	subw	a5,s5,t1
    8ac6:	4b81                	li	s7,0
    8ac8:	b421                	j	84d0 <_ftoa+0x13c0>
    8aca:	004a7813          	andi	a6,s4,4
    8ace:	f00801e3          	beqz	a6,89d0 <_ftoa+0x18c0>
    8ad2:	0b05                	addi	s6,s6,1
    8ad4:	002f8833          	add	a6,t6,sp
    8ad8:	02b00713          	li	a4,43
    8adc:	00e80823          	sb	a4,16(a6)
    8ae0:	8d4e                	mv	s10,s3
    8ae2:	8feff06f          	j	7be0 <_ftoa+0xad0>
    8ae6:	7c0abf8b          	th.extu	t6,s5,31,0
    8aea:	01fb7463          	bgeu	s6,t6,8af2 <_ftoa+0x19e2>
    8aee:	feffe06f          	j	7adc <_ftoa+0x9cc>
    8af2:	8d4e                	mv	s10,s3
    8af4:	8ecff06f          	j	7be0 <_ftoa+0xad0>
    8af8:	02b00513          	li	a0,43
    8afc:	fea60023          	sb	a0,-32(a2)
    8b00:	b6f5                	j	86ec <_ftoa+0x15dc>
    8b02:	8d5a                	mv	s10,s6
    8b04:	b6f1                	j	86d0 <_ftoa+0x15c0>
    8b06:	008a7893          	andi	a7,s4,8
    8b0a:	8c088a63          	beqz	a7,7bde <_ftoa+0xace>
    8b0e:	8fda                	mv	t6,s6
    8b10:	4585                	li	a1,1
    8b12:	bdc1                	j	89e2 <_ftoa+0x18d2>
    8b14:	000a8d63          	beqz	s5,8b2e <_ftoa+0x1a1e>
    8b18:	06080c63          	beqz	a6,8b90 <_ftoa+0x1a80>
    8b1c:	3afd                	addiw	s5,s5,-1
    8b1e:	7c0ab68b          	th.extu	a3,s5,31,0
    8b22:	04dff463          	bgeu	t6,a3,8b6a <_ftoa+0x1a5a>
    8b26:	8b7e                	mv	s6,t6
    8b28:	8fb6                	mv	t6,a3
    8b2a:	fb3fe06f          	j	7adc <_ftoa+0x9cc>
    8b2e:	02000b93          	li	s7,32
    8b32:	037f8863          	beq	t6,s7,8b62 <_ftoa+0x1a52>
    8b36:	00080f63          	beqz	a6,8b54 <_ftoa+0x1a44>
    8b3a:	017f8d33          	add	s10,t6,s7
    8b3e:	002d05b3          	add	a1,s10,sp
    8b42:	02d00793          	li	a5,45
    8b46:	001f8b13          	addi	s6,t6,1
    8b4a:	fef58823          	sb	a5,-16(a1)
    8b4e:	8d4e                	mv	s10,s3
    8b50:	890ff06f          	j	7be0 <_ftoa+0xad0>
    8b54:	004a7c93          	andi	s9,s4,4
    8b58:	001f8b13          	addi	s6,t6,1
    8b5c:	f60c9ce3          	bnez	s9,8ad4 <_ftoa+0x19c4>
    8b60:	bda5                	j	89d8 <_ftoa+0x18c8>
    8b62:	8b7e                	mv	s6,t6
    8b64:	8d4e                	mv	s10,s3
    8b66:	87aff06f          	j	7be0 <_ftoa+0xad0>
    8b6a:	02000713          	li	a4,32
    8b6e:	feef8ae3          	beq	t6,a4,8b62 <_ftoa+0x1a52>
    8b72:	00ef8533          	add	a0,t6,a4
    8b76:	01010b93          	addi	s7,sp,16
    8b7a:	02d00d13          	li	s10,45
    8b7e:	01750cb3          	add	s9,a0,s7
    8b82:	ffac8023          	sb	s10,-32(s9)
    8b86:	01df8b33          	add	s6,t6,t4
    8b8a:	8d4e                	mv	s10,s3
    8b8c:	854ff06f          	j	7be0 <_ftoa+0xad0>
    8b90:	8b7e                	mv	s6,t6
    8b92:	bde9                	j	8a6c <_ftoa+0x195c>
    8b94:	00000013          	nop
    8b98:	00000013          	nop
    8b9c:	00000013          	nop

0000000000008ba0 <_vsnprintf>:
    8ba0:	7131                	addi	sp,sp,-192
    8ba2:	f526                	sd	s1,168(sp)
    8ba4:	f922                	sd	s0,176(sp)
    8ba6:	641d                	lui	s0,0x7
    8ba8:	ed4e                	sd	s3,152(sp)
    8baa:	f14a                	sd	s2,160(sp)
    8bac:	fd06                	sd	ra,184(sp)
    8bae:	0e040413          	addi	s0,s0,224 # 70e0 <_out_null>
    8bb2:	42b5140b          	th.mvnez	s0,a0,a1
    8bb6:	0006c503          	lbu	a0,0(a3)
    8bba:	4381                	li	t2,0
    8bbc:	892e                	mv	s2,a1
    8bbe:	84b2                	mv	s1,a2
    8bc0:	e119                	bnez	a0,8bc6 <_vsnprintf+0x26>
    8bc2:	3550106f          	j	a716 <_vsnprintf+0x1b76>
    8bc6:	67c5                	lui	a5,0x11
    8bc8:	c6c78293          	addi	t0,a5,-916 # 10c6c <errpat+0x124>
    8bcc:	e556                	sd	s5,136(sp)
    8bce:	e952                	sd	s4,144(sp)
    8bd0:	6a45                	lui	s4,0x11
    8bd2:	ecee                	sd	s11,88(sp)
    8bd4:	f0ea                	sd	s10,96(sp)
    8bd6:	f4e6                	sd	s9,104(sp)
    8bd8:	f8e2                	sd	s8,112(sp)
    8bda:	fcde                	sd	s7,120(sp)
    8bdc:	e15a                	sd	s6,128(sp)
    8bde:	49c1                	li	s3,16
    8be0:	e01e                	sd	t2,0(sp)
    8be2:	e816                	sd	t0,16(sp)
    8be4:	8cb6                	mv	s9,a3
    8be6:	8dba                	mv	s11,a4
    8be8:	c28a0a13          	addi	s4,s4,-984 # 10c28 <errpat+0xe0>
    8bec:	a831                	j	8c08 <_vsnprintf+0x68>
    8bee:	0001                	nop
    8bf0:	6602                	ld	a2,0(sp)
    8bf2:	86a6                	mv	a3,s1
    8bf4:	85ca                	mv	a1,s2
    8bf6:	00160c13          	addi	s8,a2,1
    8bfa:	0c85                	addi	s9,s9,1
    8bfc:	9402                	jalr	s0
    8bfe:	e062                	sd	s8,0(sp)
    8c00:	000cc503          	lbu	a0,0(s9)
    8c04:	1c050263          	beqz	a0,8dc8 <_vsnprintf+0x228>
    8c08:	02500313          	li	t1,37
    8c0c:	fe6512e3          	bne	a0,t1,8bf0 <_vsnprintf+0x50>
    8c10:	002c8893          	addi	a7,s9,2
    8c14:	4b01                	li	s6,0
    8c16:	0001                	nop
    8c18:	fff8c503          	lbu	a0,-1(a7)
    8c1c:	fe05071b          	addiw	a4,a0,-32
    8c20:	0ff77393          	zext.b	t2,a4
    8c24:	0079e663          	bltu	s3,t2,8c30 <_vsnprintf+0x90>
    8c28:	447a458b          	th.lrw	a1,s4,t2,2
    8c2c:	8582                	jr	a1
    8c2e:	0001                	nop
    8c30:	fff88a93          	addi	s5,a7,-1
    8c34:	fd050c1b          	addiw	s8,a0,-48
    8c38:	4ba5                	li	s7,9
    8c3a:	e456                	sd	s5,8(sp)
    8c3c:	0ffc7c93          	zext.b	s9,s8
    8c40:	0b9bf663          	bgeu	s7,s9,8cec <_vsnprintf+0x14c>
    8c44:	02a00d13          	li	s10,42
    8c48:	4881                	li	a7,0
    8c4a:	35a50163          	beq	a0,s10,8f8c <_vsnprintf+0x3ec>
    8c4e:	02e00f93          	li	t6,46
    8c52:	4c01                	li	s8,0
    8c54:	15f50363          	beq	a0,t6,8d9a <_vsnprintf+0x1fa>
    8c58:	f985081b          	addiw	a6,a0,-104
    8c5c:	0ff87f93          	zext.b	t6,a6
    8c60:	4ac9                	li	s5,18
    8c62:	05faef63          	bltu	s5,t6,8cc0 <_vsnprintf+0x120>
    8c66:	6bc2                	ld	s7,16(sp)
    8c68:	45fbcc8b          	th.lrw	s9,s7,t6,2
    8c6c:	8c82                	jr	s9
    8c6e:	0001                	nop
    8c70:	001b6b13          	ori	s6,s6,1
    8c74:	2b01                	sext.w	s6,s6
    8c76:	0885                	addi	a7,a7,1
    8c78:	b745                	j	8c18 <_vsnprintf+0x78>
    8c7a:	0001                	nop
    8c7c:	002b6513          	ori	a0,s6,2
    8c80:	00050b1b          	sext.w	s6,a0
    8c84:	0885                	addi	a7,a7,1
    8c86:	bf49                	j	8c18 <_vsnprintf+0x78>
    8c88:	004b6613          	ori	a2,s6,4
    8c8c:	00060b1b          	sext.w	s6,a2
    8c90:	0885                	addi	a7,a7,1
    8c92:	b759                	j	8c18 <_vsnprintf+0x78>
    8c94:	010b6693          	ori	a3,s6,16
    8c98:	00068b1b          	sext.w	s6,a3
    8c9c:	0885                	addi	a7,a7,1
    8c9e:	bfad                	j	8c18 <_vsnprintf+0x78>
    8ca0:	008b6813          	ori	a6,s6,8
    8ca4:	00080b1b          	sext.w	s6,a6
    8ca8:	0885                	addi	a7,a7,1
    8caa:	b7bd                	j	8c18 <_vsnprintf+0x78>
    8cac:	6322                	ld	t1,8(sp)
    8cae:	100b6693          	ori	a3,s6,256
    8cb2:	00068b1b          	sext.w	s6,a3
    8cb6:	00134503          	lbu	a0,1(t1)
    8cba:	00130393          	addi	t2,t1,1
    8cbe:	e41e                	sd	t2,8(sp)
    8cc0:	06700a93          	li	s5,103
    8cc4:	14aae063          	bltu	s5,a0,8e04 <_vsnprintf+0x264>
    8cc8:	02400d13          	li	s10,36
    8ccc:	2cad7c63          	bgeu	s10,a0,8fa4 <_vsnprintf+0x404>
    8cd0:	fdb50c9b          	addiw	s9,a0,-37
    8cd4:	0ffcf693          	zext.b	a3,s9
    8cd8:	04200393          	li	t2,66
    8cdc:	2cd3e463          	bltu	t2,a3,8fa4 <_vsnprintf+0x404>
    8ce0:	6345                	lui	t1,0x11
    8ce2:	cb830813          	addi	a6,t1,-840 # 10cb8 <errpat+0x170>
    8ce6:	44d84f8b          	th.lrw	t6,a6,a3,2
    8cea:	8f82                	jr	t6
    8cec:	66a2                	ld	a3,8(sp)
    8cee:	4881                	li	a7,0
    8cf0:	8fde                	mv	t6,s7
    8cf2:	0028929b          	slliw	t0,a7,0x2
    8cf6:	0112833b          	addw	t1,t0,a7
    8cfa:	0685                	addi	a3,a3,1
    8cfc:	0013171b          	slliw	a4,t1,0x1
    8d00:	00a703bb          	addw	t2,a4,a0
    8d04:	0006c503          	lbu	a0,0(a3)
    8d08:	87b6                	mv	a5,a3
    8d0a:	fd03889b          	addiw	a7,t2,-48
    8d0e:	fd05059b          	addiw	a1,a0,-48
    8d12:	0ff5f613          	zext.b	a2,a1
    8d16:	06cfec63          	bltu	t6,a2,8d8e <_vsnprintf+0x1ee>
    8d1a:	0028981b          	slliw	a6,a7,0x2
    8d1e:	011808bb          	addw	a7,a6,a7
    8d22:	00189a9b          	slliw	s5,a7,0x1
    8d26:	00aa853b          	addw	a0,s5,a0
    8d2a:	fd05089b          	addiw	a7,a0,-48
    8d2e:	8816c50b          	th.lbuib	a0,(a3),1,0
    8d32:	fd050b9b          	addiw	s7,a0,-48
    8d36:	0ffbfc13          	zext.b	s8,s7
    8d3a:	058fea63          	bltu	t6,s8,8d8e <_vsnprintf+0x1ee>
    8d3e:	00289c9b          	slliw	s9,a7,0x2
    8d42:	011c8d3b          	addw	s10,s9,a7
    8d46:	001d1e1b          	slliw	t3,s10,0x1
    8d4a:	00ae0ebb          	addw	t4,t3,a0
    8d4e:	0027c503          	lbu	a0,2(a5)
    8d52:	00278693          	addi	a3,a5,2
    8d56:	fd0e889b          	addiw	a7,t4,-48
    8d5a:	fd050f1b          	addiw	t5,a0,-48
    8d5e:	0fff7293          	zext.b	t0,t5
    8d62:	025fe663          	bltu	t6,t0,8d8e <_vsnprintf+0x1ee>
    8d66:	0028931b          	slliw	t1,a7,0x2
    8d6a:	0113073b          	addw	a4,t1,a7
    8d6e:	0017139b          	slliw	t2,a4,0x1
    8d72:	00a385bb          	addw	a1,t2,a0
    8d76:	0037c503          	lbu	a0,3(a5)
    8d7a:	00378693          	addi	a3,a5,3
    8d7e:	fd05889b          	addiw	a7,a1,-48
    8d82:	fd05079b          	addiw	a5,a0,-48
    8d86:	0ff7f613          	zext.b	a2,a5
    8d8a:	f6cff4e3          	bgeu	t6,a2,8cf2 <_vsnprintf+0x152>
    8d8e:	e436                	sd	a3,8(sp)
    8d90:	02e00f93          	li	t6,46
    8d94:	4c01                	li	s8,0
    8d96:	edf511e3          	bne	a0,t6,8c58 <_vsnprintf+0xb8>
    8d9a:	6aa2                	ld	s5,8(sp)
    8d9c:	400b6b13          	ori	s6,s6,1024
    8da0:	4825                	li	a6,9
    8da2:	001ac503          	lbu	a0,1(s5)
    8da6:	2b01                	sext.w	s6,s6
    8da8:	001a8713          	addi	a4,s5,1
    8dac:	fd050b9b          	addiw	s7,a0,-48
    8db0:	0ffbfc93          	zext.b	s9,s7
    8db4:	21987463          	bgeu	a6,s9,8fbc <_vsnprintf+0x41c>
    8db8:	02a00d13          	li	s10,42
    8dbc:	01a51463          	bne	a0,s10,8dc4 <_vsnprintf+0x224>
    8dc0:	7c70006f          	j	9d86 <_vsnprintf+0x11e6>
    8dc4:	e43a                	sd	a4,8(sp)
    8dc6:	bd49                	j	8c58 <_vsnprintf+0xb8>
    8dc8:	6382                	ld	t2,0(sp)
    8dca:	6de6                	ld	s11,88(sp)
    8dcc:	7d06                	ld	s10,96(sp)
    8dce:	7ca6                	ld	s9,104(sp)
    8dd0:	7c46                	ld	s8,112(sp)
    8dd2:	7be6                	ld	s7,120(sp)
    8dd4:	6b0a                	ld	s6,128(sp)
    8dd6:	6aaa                	ld	s5,136(sp)
    8dd8:	6a4a                	ld	s4,144(sp)
    8dda:	0003899b          	sext.w	s3,t2
    8dde:	0093b7b3          	sltu	a5,t2,s1
    8de2:	fff48613          	addi	a2,s1,-1
    8de6:	86a6                	mv	a3,s1
    8de8:	85ca                	mv	a1,s2
    8dea:	4501                	li	a0,0
    8dec:	42f3960b          	th.mvnez	a2,t2,a5
    8df0:	9402                	jalr	s0
    8df2:	70ea                	ld	ra,184(sp)
    8df4:	74aa                	ld	s1,168(sp)
    8df6:	744a                	ld	s0,176(sp)
    8df8:	854e                	mv	a0,s3
    8dfa:	69ea                	ld	s3,152(sp)
    8dfc:	790a                	ld	s2,160(sp)
    8dfe:	6129                	addi	sp,sp,192
    8e00:	8082                	ret
    8e02:	0001                	nop
    8e04:	f9750b9b          	addiw	s7,a0,-105
    8e08:	0ffbfc93          	zext.b	s9,s7
    8e0c:	4d3d                	li	s10,15
    8e0e:	199d6b63          	bltu	s10,s9,8fa4 <_vsnprintf+0x404>
    8e12:	4e05                	li	t3,1
    8e14:	62a5                	lui	t0,0x9
    8e16:	019e1eb3          	sll	t4,t3,s9
    8e1a:	04128693          	addi	a3,t0,65 # 9041 <_vsnprintf+0x4a1>
    8e1e:	00def7b3          	and	a5,t4,a3
    8e22:	72079de3          	bnez	a5,9d5c <_vsnprintf+0x11bc>
    8e26:	4fa9                	li	t6,10
    8e28:	23fc8a63          	beq	s9,t6,905c <_vsnprintf+0x4bc>
    8e2c:	439d                	li	t2,7
    8e2e:	167c9b63          	bne	s9,t2,8fa4 <_vsnprintf+0x404>
    8e32:	788dc28b          	th.ldia	t0,(s11),8,0
    8e36:	760288e3          	beqz	t0,9da6 <_vsnprintf+0x1206>
    8e3a:	021b6f13          	ori	t5,s6,33
    8e3e:	000f059b          	sext.w	a1,t5
    8e42:	400b7c93          	andi	s9,s6,1024
    8e46:	010b7b93          	andi	s7,s6,16
    8e4a:	453d                	li	a0,15
    8e4c:	00a2f333          	and	t1,t0,a0
    8e50:	43a5                	li	t2,9
    8e52:	03030d13          	addi	s10,t1,48
    8e56:	03730f13          	addi	t5,t1,55
    8e5a:	0063b633          	sltu	a2,t2,t1
    8e5e:	40cd1f0b          	th.mveqz	t5,s10,a2
    8e62:	03e10823          	sb	t5,48(sp)
    8e66:	03010b13          	addi	s6,sp,48
    8e6a:	02000893          	li	a7,32
    8e6e:	4d05                	li	s10,1
    8e70:	0042d813          	srli	a6,t0,0x4
    8e74:	00556463          	bltu	a0,t0,8e7c <_vsnprintf+0x2dc>
    8e78:	6180106f          	j	a490 <_vsnprintf+0x18f0>
    8e7c:	00f87f93          	andi	t6,a6,15
    8e80:	030f8a93          	addi	s5,t6,48
    8e84:	037f8e93          	addi	t4,t6,55
    8e88:	01f3b2b3          	sltu	t0,t2,t6
    8e8c:	405a9e8b          	th.mveqz	t4,s5,t0
    8e90:	03d108a3          	sb	t4,49(sp)
    8e94:	87ea                	mv	a5,s10
    8e96:	00485313          	srli	t1,a6,0x4
    8e9a:	4d09                	li	s10,2
    8e9c:	01056463          	bltu	a0,a6,8ea4 <_vsnprintf+0x304>
    8ea0:	5f00106f          	j	a490 <_vsnprintf+0x18f0>
    8ea4:	00f37f13          	andi	t5,t1,15
    8ea8:	030f0813          	addi	a6,t5,48
    8eac:	037f0713          	addi	a4,t5,55
    8eb0:	01e3bfb3          	sltu	t6,t2,t5
    8eb4:	41f8170b          	th.mveqz	a4,a6,t6
    8eb8:	02e10923          	sb	a4,50(sp)
    8ebc:	87ea                	mv	a5,s10
    8ebe:	00435e13          	srli	t3,t1,0x4
    8ec2:	0d05                	addi	s10,s10,1
    8ec4:	00656463          	bltu	a0,t1,8ecc <_vsnprintf+0x32c>
    8ec8:	5c80106f          	j	a490 <_vsnprintf+0x18f0>
    8ecc:	03310613          	addi	a2,sp,51
    8ed0:	87ea                	mv	a5,s10
    8ed2:	8772                	mv	a4,t3
    8ed4:	00000013          	nop
    8ed8:	00f77d13          	andi	s10,a4,15
    8edc:	030d0e93          	addi	t4,s10,48
    8ee0:	037d0293          	addi	t0,s10,55
    8ee4:	01a3b333          	sltu	t1,t2,s10
    8ee8:	406e928b          	th.mveqz	t0,t4,t1
    8eec:	00560023          	sb	t0,0(a2)
    8ef0:	00178d13          	addi	s10,a5,1
    8ef4:	00475f13          	srli	t5,a4,0x4
    8ef8:	00e56463          	bltu	a0,a4,8f00 <_vsnprintf+0x360>
    8efc:	5940106f          	j	a490 <_vsnprintf+0x18f0>
    8f00:	011d1463          	bne	s10,a7,8f08 <_vsnprintf+0x368>
    8f04:	1750106f          	j	a878 <_vsnprintf+0x1cd8>
    8f08:	00ff7f93          	andi	t6,t5,15
    8f0c:	886a                	mv	a6,s10
    8f0e:	87ea                	mv	a5,s10
    8f10:	030f8e13          	addi	t3,t6,48
    8f14:	01f3bd33          	sltu	s10,t2,t6
    8f18:	037f8a93          	addi	s5,t6,55
    8f1c:	41ae1a8b          	th.mveqz	s5,t3,s10
    8f20:	015600a3          	sb	s5,1(a2)
    8f24:	00180d13          	addi	s10,a6,1
    8f28:	00875e93          	srli	t4,a4,0x8
    8f2c:	01e56463          	bltu	a0,t5,8f34 <_vsnprintf+0x394>
    8f30:	5600106f          	j	a490 <_vsnprintf+0x18f0>
    8f34:	00fef313          	andi	t1,t4,15
    8f38:	03030293          	addi	t0,t1,48
    8f3c:	03730f93          	addi	t6,t1,55
    8f40:	0063b6b3          	sltu	a3,t2,t1
    8f44:	40d29f8b          	th.mveqz	t6,t0,a3
    8f48:	01f60123          	sb	t6,2(a2)
    8f4c:	87ea                	mv	a5,s10
    8f4e:	00c75e13          	srli	t3,a4,0xc
    8f52:	0d05                	addi	s10,s10,1
    8f54:	01d56463          	bltu	a0,t4,8f5c <_vsnprintf+0x3bc>
    8f58:	5380106f          	j	a490 <_vsnprintf+0x18f0>
    8f5c:	00fe7a93          	andi	s5,t3,15
    8f60:	030a8e93          	addi	t4,s5,48
    8f64:	037a8313          	addi	t1,s5,55
    8f68:	0153bf33          	sltu	t5,t2,s5
    8f6c:	41ee930b          	th.mveqz	t1,t4,t5
    8f70:	006601a3          	sb	t1,3(a2)
    8f74:	00280793          	addi	a5,a6,2
    8f78:	00380d13          	addi	s10,a6,3
    8f7c:	8341                	srli	a4,a4,0x10
    8f7e:	01c56463          	bltu	a0,t3,8f86 <_vsnprintf+0x3e6>
    8f82:	50e0106f          	j	a490 <_vsnprintf+0x18f0>
    8f86:	0611                	addi	a2,a2,4
    8f88:	87ea                	mv	a5,s10
    8f8a:	b7b9                	j	8ed8 <_vsnprintf+0x338>
    8f8c:	588dc88b          	th.lwia	a7,(s11),8,0
    8f90:	4e08c463          	bltz	a7,9478 <_vsnprintf+0x8d8>
    8f94:	6ea2                	ld	t4,8(sp)
    8f96:	001e8f13          	addi	t5,t4,1
    8f9a:	001ec503          	lbu	a0,1(t4)
    8f9e:	e47a                	sd	t5,8(sp)
    8fa0:	b17d                	j	8c4e <_vsnprintf+0xae>
    8fa2:	0001                	nop
    8fa4:	6602                	ld	a2,0(sp)
    8fa6:	86a6                	mv	a3,s1
    8fa8:	85ca                	mv	a1,s2
    8faa:	00160d13          	addi	s10,a2,1
    8fae:	9402                	jalr	s0
    8fb0:	6fa2                	ld	t6,8(sp)
    8fb2:	e06a                	sd	s10,0(sp)
    8fb4:	001f8c93          	addi	s9,t6,1
    8fb8:	b1a1                	j	8c00 <_vsnprintf+0x60>
    8fba:	0001                	nop
    8fbc:	002c129b          	slliw	t0,s8,0x2
    8fc0:	018286bb          	addw	a3,t0,s8
    8fc4:	0705                	addi	a4,a4,1
    8fc6:	0016931b          	slliw	t1,a3,0x1
    8fca:	00a303bb          	addw	t2,t1,a0
    8fce:	00074503          	lbu	a0,0(a4)
    8fd2:	8f3a                	mv	t5,a4
    8fd4:	fd038c1b          	addiw	s8,t2,-48
    8fd8:	fd05059b          	addiw	a1,a0,-48
    8fdc:	0ff5f793          	zext.b	a5,a1
    8fe0:	def862e3          	bltu	a6,a5,8dc4 <_vsnprintf+0x224>
    8fe4:	002c161b          	slliw	a2,s8,0x2
    8fe8:	01860fbb          	addw	t6,a2,s8
    8fec:	001f9a9b          	slliw	s5,t6,0x1
    8ff0:	00aa8bbb          	addw	s7,s5,a0
    8ff4:	8817450b          	th.lbuib	a0,(a4),1,0
    8ff8:	fd0b8c1b          	addiw	s8,s7,-48
    8ffc:	fd050c9b          	addiw	s9,a0,-48
    9000:	0ffcfd13          	zext.b	s10,s9
    9004:	dda860e3          	bltu	a6,s10,8dc4 <_vsnprintf+0x224>
    9008:	002c1e1b          	slliw	t3,s8,0x2
    900c:	018e0c3b          	addw	s8,t3,s8
    9010:	001c1e9b          	slliw	t4,s8,0x1
    9014:	00ae853b          	addw	a0,t4,a0
    9018:	fd050c1b          	addiw	s8,a0,-48
    901c:	002f4503          	lbu	a0,2(t5)
    9020:	002f0713          	addi	a4,t5,2
    9024:	fd05029b          	addiw	t0,a0,-48
    9028:	0ff2f693          	zext.b	a3,t0
    902c:	d8d86ce3          	bltu	a6,a3,8dc4 <_vsnprintf+0x224>
    9030:	002c131b          	slliw	t1,s8,0x2
    9034:	018303bb          	addw	t2,t1,s8
    9038:	0013959b          	slliw	a1,t2,0x1
    903c:	00a587bb          	addw	a5,a1,a0
    9040:	003f4503          	lbu	a0,3(t5)
    9044:	003f0713          	addi	a4,t5,3
    9048:	fd078c1b          	addiw	s8,a5,-48
    904c:	fd050f1b          	addiw	t5,a0,-48
    9050:	0fff7613          	zext.b	a2,t5
    9054:	f6c874e3          	bgeu	a6,a2,8fbc <_vsnprintf+0x41c>
    9058:	e43a                	sd	a4,8(sp)
    905a:	befd                	j	8c58 <_vsnprintf+0xb8>
    905c:	788dcd0b          	th.ldia	s10,(s11),8,0
    9060:	7c0c3a8b          	th.extu	s5,s8,31,0
    9064:	5bfd                	li	s7,-1
    9066:	000d4503          	lbu	a0,0(s10)
    906a:	418b9a8b          	th.mveqz	s5,s7,s8
    906e:	015d0cb3          	add	s9,s10,s5
    9072:	87ea                	mv	a5,s10
    9074:	e119                	bnez	a0,907a <_vsnprintf+0x4da>
    9076:	2650206f          	j	bada <_vsnprintf+0x2f3a>
    907a:	41ac8eb3          	sub	t4,s9,s10
    907e:	007ef293          	andi	t0,t4,7
    9082:	04028e63          	beqz	t0,90de <_vsnprintf+0x53e>
    9086:	001d4683          	lbu	a3,1(s10)
    908a:	001d0793          	addi	a5,s10,1
    908e:	c6d5                	beqz	a3,913a <_vsnprintf+0x59a>
    9090:	05c28763          	beq	t0,t3,90de <_vsnprintf+0x53e>
    9094:	4309                	li	t1,2
    9096:	04628063          	beq	t0,t1,90d6 <_vsnprintf+0x536>
    909a:	438d                	li	t2,3
    909c:	02728963          	beq	t0,t2,90ce <_vsnprintf+0x52e>
    90a0:	4f11                	li	t5,4
    90a2:	03e28263          	beq	t0,t5,90c6 <_vsnprintf+0x526>
    90a6:	4595                	li	a1,5
    90a8:	00b28b63          	beq	t0,a1,90be <_vsnprintf+0x51e>
    90ac:	4619                	li	a2,6
    90ae:	00c28463          	beq	t0,a2,90b6 <_vsnprintf+0x516>
    90b2:	7a90106f          	j	b05a <_vsnprintf+0x24ba>
    90b6:	8817c80b          	th.lbuib	a6,(a5),1,0
    90ba:	08080063          	beqz	a6,913a <_vsnprintf+0x59a>
    90be:	8817cf8b          	th.lbuib	t6,(a5),1,0
    90c2:	060f8c63          	beqz	t6,913a <_vsnprintf+0x59a>
    90c6:	8817ca8b          	th.lbuib	s5,(a5),1,0
    90ca:	060a8863          	beqz	s5,913a <_vsnprintf+0x59a>
    90ce:	8817cb8b          	th.lbuib	s7,(a5),1,0
    90d2:	060b8463          	beqz	s7,913a <_vsnprintf+0x59a>
    90d6:	8817ce0b          	th.lbuib	t3,(a5),1,0
    90da:	060e0063          	beqz	t3,913a <_vsnprintf+0x59a>
    90de:	00fc9463          	bne	s9,a5,90e6 <_vsnprintf+0x546>
    90e2:	5480106f          	j	a62a <_vsnprintf+0x1a8a>
    90e6:	0017c283          	lbu	t0,1(a5)
    90ea:	0785                	addi	a5,a5,1
    90ec:	8ebe                	mv	t4,a5
    90ee:	04028663          	beqz	t0,913a <_vsnprintf+0x59a>
    90f2:	8817c68b          	th.lbuib	a3,(a5),1,0
    90f6:	c2b1                	beqz	a3,913a <_vsnprintf+0x59a>
    90f8:	002ec303          	lbu	t1,2(t4)
    90fc:	002e8793          	addi	a5,t4,2
    9100:	02030d63          	beqz	t1,913a <_vsnprintf+0x59a>
    9104:	003ec383          	lbu	t2,3(t4)
    9108:	003e8793          	addi	a5,t4,3
    910c:	02038763          	beqz	t2,913a <_vsnprintf+0x59a>
    9110:	004ecf03          	lbu	t5,4(t4)
    9114:	004e8793          	addi	a5,t4,4
    9118:	020f0163          	beqz	t5,913a <_vsnprintf+0x59a>
    911c:	005ec583          	lbu	a1,5(t4)
    9120:	005e8793          	addi	a5,t4,5
    9124:	c999                	beqz	a1,913a <_vsnprintf+0x59a>
    9126:	006ec603          	lbu	a2,6(t4)
    912a:	006e8793          	addi	a5,t4,6
    912e:	c611                	beqz	a2,913a <_vsnprintf+0x59a>
    9130:	007ec703          	lbu	a4,7(t4)
    9134:	007e8793          	addi	a5,t4,7
    9138:	f35d                	bnez	a4,90de <_vsnprintf+0x53e>
    913a:	400b7c93          	andi	s9,s6,1024
    913e:	41a78bbb          	subw	s7,a5,s10
    9142:	000c9463          	bnez	s9,914a <_vsnprintf+0x5aa>
    9146:	4f20106f          	j	a638 <_vsnprintf+0x1a98>
    914a:	018bb833          	sltu	a6,s7,s8
    914e:	002b7f93          	andi	t6,s6,2
    9152:	410c1b8b          	th.mveqz	s7,s8,a6
    9156:	000f9463          	bnez	t6,915e <_vsnprintf+0x5be>
    915a:	7e00206f          	j	b93a <_vsnprintf+0x2d9a>
    915e:	6c82                	ld	s9,0(sp)
    9160:	4a89                	li	s5,2
    9162:	7c0c360b          	th.extu	a2,s8,31,0
    9166:	01960733          	add	a4,a2,s9
    916a:	41970833          	sub	a6,a4,s9
    916e:	00787f93          	andi	t6,a6,7
    9172:	e03a                	sd	a4,0(sp)
    9174:	8c66                	mv	s8,s9
    9176:	419d0b33          	sub	s6,s10,s9
    917a:	0e0f8163          	beqz	t6,925c <_vsnprintf+0x6bc>
    917e:	ec46                	sd	a7,24(sp)
    9180:	f07e                	sd	t6,32(sp)
    9182:	86a6                	mv	a3,s1
    9184:	8666                	mv	a2,s9
    9186:	85ca                	mv	a1,s2
    9188:	9402                	jalr	s0
    918a:	001c8d13          	addi	s10,s9,1
    918e:	81ab450b          	th.lrbu	a0,s6,s10,0
    9192:	68e2                	ld	a7,24(sp)
    9194:	e119                	bnez	a0,919a <_vsnprintf+0x5fa>
    9196:	2f00106f          	j	a486 <_vsnprintf+0x18e6>
    919a:	7e82                	ld	t4,32(sp)
    919c:	4e05                	li	t3,1
    919e:	8c6a                	mv	s8,s10
    91a0:	0bce8e63          	beq	t4,t3,925c <_vsnprintf+0x6bc>
    91a4:	4289                	li	t0,2
    91a6:	085e8e63          	beq	t4,t0,9242 <_vsnprintf+0x6a2>
    91aa:	468d                	li	a3,3
    91ac:	06de8e63          	beq	t4,a3,9228 <_vsnprintf+0x688>
    91b0:	4311                	li	t1,4
    91b2:	046e8e63          	beq	t4,t1,920e <_vsnprintf+0x66e>
    91b6:	4395                	li	t2,5
    91b8:	027e8e63          	beq	t4,t2,91f4 <_vsnprintf+0x654>
    91bc:	4f19                	li	t5,6
    91be:	01ee8e63          	beq	t4,t5,91da <_vsnprintf+0x63a>
    91c2:	8662                	mv	a2,s8
    91c4:	86a6                	mv	a3,s1
    91c6:	85ca                	mv	a1,s2
    91c8:	0d05                	addi	s10,s10,1
    91ca:	9402                	jalr	s0
    91cc:	81ab450b          	th.lrbu	a0,s6,s10,0
    91d0:	68e2                	ld	a7,24(sp)
    91d2:	8c6a                	mv	s8,s10
    91d4:	e119                	bnez	a0,91da <_vsnprintf+0x63a>
    91d6:	2b00106f          	j	a486 <_vsnprintf+0x18e6>
    91da:	8662                	mv	a2,s8
    91dc:	ec46                	sd	a7,24(sp)
    91de:	86a6                	mv	a3,s1
    91e0:	85ca                	mv	a1,s2
    91e2:	0d05                	addi	s10,s10,1
    91e4:	9402                	jalr	s0
    91e6:	81ab450b          	th.lrbu	a0,s6,s10,0
    91ea:	68e2                	ld	a7,24(sp)
    91ec:	8c6a                	mv	s8,s10
    91ee:	e119                	bnez	a0,91f4 <_vsnprintf+0x654>
    91f0:	2960106f          	j	a486 <_vsnprintf+0x18e6>
    91f4:	8662                	mv	a2,s8
    91f6:	ec46                	sd	a7,24(sp)
    91f8:	86a6                	mv	a3,s1
    91fa:	85ca                	mv	a1,s2
    91fc:	0d05                	addi	s10,s10,1
    91fe:	9402                	jalr	s0
    9200:	81ab450b          	th.lrbu	a0,s6,s10,0
    9204:	68e2                	ld	a7,24(sp)
    9206:	8c6a                	mv	s8,s10
    9208:	e119                	bnez	a0,920e <_vsnprintf+0x66e>
    920a:	27c0106f          	j	a486 <_vsnprintf+0x18e6>
    920e:	8662                	mv	a2,s8
    9210:	ec46                	sd	a7,24(sp)
    9212:	86a6                	mv	a3,s1
    9214:	85ca                	mv	a1,s2
    9216:	0d05                	addi	s10,s10,1
    9218:	9402                	jalr	s0
    921a:	81ab450b          	th.lrbu	a0,s6,s10,0
    921e:	68e2                	ld	a7,24(sp)
    9220:	8c6a                	mv	s8,s10
    9222:	e119                	bnez	a0,9228 <_vsnprintf+0x688>
    9224:	2620106f          	j	a486 <_vsnprintf+0x18e6>
    9228:	8662                	mv	a2,s8
    922a:	ec46                	sd	a7,24(sp)
    922c:	86a6                	mv	a3,s1
    922e:	85ca                	mv	a1,s2
    9230:	0d05                	addi	s10,s10,1
    9232:	9402                	jalr	s0
    9234:	81ab450b          	th.lrbu	a0,s6,s10,0
    9238:	68e2                	ld	a7,24(sp)
    923a:	8c6a                	mv	s8,s10
    923c:	e119                	bnez	a0,9242 <_vsnprintf+0x6a2>
    923e:	2480106f          	j	a486 <_vsnprintf+0x18e6>
    9242:	8662                	mv	a2,s8
    9244:	ec46                	sd	a7,24(sp)
    9246:	86a6                	mv	a3,s1
    9248:	85ca                	mv	a1,s2
    924a:	0d05                	addi	s10,s10,1
    924c:	9402                	jalr	s0
    924e:	81ab450b          	th.lrbu	a0,s6,s10,0
    9252:	68e2                	ld	a7,24(sp)
    9254:	8c6a                	mv	s8,s10
    9256:	e119                	bnez	a0,925c <_vsnprintf+0x6bc>
    9258:	22e0106f          	j	a486 <_vsnprintf+0x18e6>
    925c:	8d46                	mv	s10,a7
    925e:	6882                	ld	a7,0(sp)
    9260:	0d888463          	beq	a7,s8,9328 <_vsnprintf+0x788>
    9264:	86a6                	mv	a3,s1
    9266:	8662                	mv	a2,s8
    9268:	85ca                	mv	a1,s2
    926a:	001c0c93          	addi	s9,s8,1
    926e:	9402                	jalr	s0
    9270:	819b450b          	th.lrbu	a0,s6,s9,0
    9274:	e119                	bnez	a0,927a <_vsnprintf+0x6da>
    9276:	20c0106f          	j	a482 <_vsnprintf+0x18e2>
    927a:	8666                	mv	a2,s9
    927c:	86a6                	mv	a3,s1
    927e:	85ca                	mv	a1,s2
    9280:	002c0c93          	addi	s9,s8,2
    9284:	9402                	jalr	s0
    9286:	819b450b          	th.lrbu	a0,s6,s9,0
    928a:	e119                	bnez	a0,9290 <_vsnprintf+0x6f0>
    928c:	1f60106f          	j	a482 <_vsnprintf+0x18e2>
    9290:	86a6                	mv	a3,s1
    9292:	002c0613          	addi	a2,s8,2
    9296:	85ca                	mv	a1,s2
    9298:	003c0c93          	addi	s9,s8,3
    929c:	9402                	jalr	s0
    929e:	819b450b          	th.lrbu	a0,s6,s9,0
    92a2:	e119                	bnez	a0,92a8 <_vsnprintf+0x708>
    92a4:	1de0106f          	j	a482 <_vsnprintf+0x18e2>
    92a8:	86a6                	mv	a3,s1
    92aa:	003c0613          	addi	a2,s8,3
    92ae:	85ca                	mv	a1,s2
    92b0:	004c0c93          	addi	s9,s8,4
    92b4:	9402                	jalr	s0
    92b6:	819b450b          	th.lrbu	a0,s6,s9,0
    92ba:	e119                	bnez	a0,92c0 <_vsnprintf+0x720>
    92bc:	1c60106f          	j	a482 <_vsnprintf+0x18e2>
    92c0:	86a6                	mv	a3,s1
    92c2:	004c0613          	addi	a2,s8,4
    92c6:	85ca                	mv	a1,s2
    92c8:	005c0c93          	addi	s9,s8,5
    92cc:	9402                	jalr	s0
    92ce:	819b450b          	th.lrbu	a0,s6,s9,0
    92d2:	e119                	bnez	a0,92d8 <_vsnprintf+0x738>
    92d4:	1ae0106f          	j	a482 <_vsnprintf+0x18e2>
    92d8:	86a6                	mv	a3,s1
    92da:	005c0613          	addi	a2,s8,5
    92de:	85ca                	mv	a1,s2
    92e0:	006c0c93          	addi	s9,s8,6
    92e4:	9402                	jalr	s0
    92e6:	819b450b          	th.lrbu	a0,s6,s9,0
    92ea:	e119                	bnez	a0,92f0 <_vsnprintf+0x750>
    92ec:	1960106f          	j	a482 <_vsnprintf+0x18e2>
    92f0:	86a6                	mv	a3,s1
    92f2:	006c0613          	addi	a2,s8,6
    92f6:	85ca                	mv	a1,s2
    92f8:	007c0c93          	addi	s9,s8,7
    92fc:	9402                	jalr	s0
    92fe:	819b450b          	th.lrbu	a0,s6,s9,0
    9302:	e119                	bnez	a0,9308 <_vsnprintf+0x768>
    9304:	17e0106f          	j	a482 <_vsnprintf+0x18e2>
    9308:	86a6                	mv	a3,s1
    930a:	007c0613          	addi	a2,s8,7
    930e:	85ca                	mv	a1,s2
    9310:	008c0c93          	addi	s9,s8,8
    9314:	9402                	jalr	s0
    9316:	819b450b          	th.lrbu	a0,s6,s9,0
    931a:	e119                	bnez	a0,9320 <_vsnprintf+0x780>
    931c:	1660106f          	j	a482 <_vsnprintf+0x18e2>
    9320:	6882                	ld	a7,0(sp)
    9322:	8c66                	mv	s8,s9
    9324:	f58890e3          	bne	a7,s8,9264 <_vsnprintf+0x6c4>
    9328:	88ea                	mv	a7,s10
    932a:	000a9463          	bnez	s5,9332 <_vsnprintf+0x792>
    932e:	14a0106f          	j	a478 <_vsnprintf+0x18d8>
    9332:	6b02                	ld	s6,0(sp)
    9334:	011be463          	bltu	s7,a7,933c <_vsnprintf+0x79c>
    9338:	1400106f          	j	a478 <_vsnprintf+0x18d8>
    933c:	6a82                	ld	s5,0(sp)
    933e:	fff8851b          	addiw	a0,a7,-1
    9342:	417505bb          	subw	a1,a0,s7
    9346:	7c05b78b          	th.extu	a5,a1,31,0
    934a:	001a8b93          	addi	s7,s5,1
    934e:	01778c33          	add	s8,a5,s7
    9352:	416c0633          	sub	a2,s8,s6
    9356:	e062                	sd	s8,0(sp)
    9358:	00767813          	andi	a6,a2,7
    935c:	08080a63          	beqz	a6,93f0 <_vsnprintf+0x850>
    9360:	4705                	li	a4,1
    9362:	06e80b63          	beq	a6,a4,93d8 <_vsnprintf+0x838>
    9366:	4f89                	li	t6,2
    9368:	07f80163          	beq	a6,t6,93ca <_vsnprintf+0x82a>
    936c:	4e0d                	li	t3,3
    936e:	05c80763          	beq	a6,t3,93bc <_vsnprintf+0x81c>
    9372:	4e91                	li	t4,4
    9374:	03d80d63          	beq	a6,t4,93ae <_vsnprintf+0x80e>
    9378:	4295                	li	t0,5
    937a:	02580363          	beq	a6,t0,93a0 <_vsnprintf+0x800>
    937e:	4699                	li	a3,6
    9380:	00d80963          	beq	a6,a3,9392 <_vsnprintf+0x7f2>
    9384:	865a                	mv	a2,s6
    9386:	86a6                	mv	a3,s1
    9388:	85ca                	mv	a1,s2
    938a:	02000513          	li	a0,32
    938e:	0b05                	addi	s6,s6,1
    9390:	9402                	jalr	s0
    9392:	865a                	mv	a2,s6
    9394:	86a6                	mv	a3,s1
    9396:	85ca                	mv	a1,s2
    9398:	02000513          	li	a0,32
    939c:	0b05                	addi	s6,s6,1
    939e:	9402                	jalr	s0
    93a0:	865a                	mv	a2,s6
    93a2:	86a6                	mv	a3,s1
    93a4:	85ca                	mv	a1,s2
    93a6:	02000513          	li	a0,32
    93aa:	0b05                	addi	s6,s6,1
    93ac:	9402                	jalr	s0
    93ae:	865a                	mv	a2,s6
    93b0:	86a6                	mv	a3,s1
    93b2:	85ca                	mv	a1,s2
    93b4:	02000513          	li	a0,32
    93b8:	0b05                	addi	s6,s6,1
    93ba:	9402                	jalr	s0
    93bc:	865a                	mv	a2,s6
    93be:	86a6                	mv	a3,s1
    93c0:	85ca                	mv	a1,s2
    93c2:	02000513          	li	a0,32
    93c6:	0b05                	addi	s6,s6,1
    93c8:	9402                	jalr	s0
    93ca:	865a                	mv	a2,s6
    93cc:	86a6                	mv	a3,s1
    93ce:	85ca                	mv	a1,s2
    93d0:	02000513          	li	a0,32
    93d4:	0b05                	addi	s6,s6,1
    93d6:	9402                	jalr	s0
    93d8:	865a                	mv	a2,s6
    93da:	86a6                	mv	a3,s1
    93dc:	85ca                	mv	a1,s2
    93de:	02000513          	li	a0,32
    93e2:	9402                	jalr	s0
    93e4:	6302                	ld	t1,0(sp)
    93e6:	0b05                	addi	s6,s6,1
    93e8:	006b1463          	bne	s6,t1,93f0 <_vsnprintf+0x850>
    93ec:	08c0106f          	j	a478 <_vsnprintf+0x18d8>
    93f0:	865a                	mv	a2,s6
    93f2:	86a6                	mv	a3,s1
    93f4:	85ca                	mv	a1,s2
    93f6:	02000513          	li	a0,32
    93fa:	9402                	jalr	s0
    93fc:	001b0d13          	addi	s10,s6,1
    9400:	866a                	mv	a2,s10
    9402:	86a6                	mv	a3,s1
    9404:	85ca                	mv	a1,s2
    9406:	02000513          	li	a0,32
    940a:	9402                	jalr	s0
    940c:	002b0c93          	addi	s9,s6,2
    9410:	8666                	mv	a2,s9
    9412:	86a6                	mv	a3,s1
    9414:	85ca                	mv	a1,s2
    9416:	02000513          	li	a0,32
    941a:	9402                	jalr	s0
    941c:	003b0a93          	addi	s5,s6,3
    9420:	86a6                	mv	a3,s1
    9422:	8656                	mv	a2,s5
    9424:	85ca                	mv	a1,s2
    9426:	02000513          	li	a0,32
    942a:	9402                	jalr	s0
    942c:	004b0b93          	addi	s7,s6,4
    9430:	86a6                	mv	a3,s1
    9432:	865e                	mv	a2,s7
    9434:	85ca                	mv	a1,s2
    9436:	02000513          	li	a0,32
    943a:	9402                	jalr	s0
    943c:	005b0c13          	addi	s8,s6,5
    9440:	86a6                	mv	a3,s1
    9442:	8662                	mv	a2,s8
    9444:	85ca                	mv	a1,s2
    9446:	02000513          	li	a0,32
    944a:	9402                	jalr	s0
    944c:	006b0d13          	addi	s10,s6,6
    9450:	86a6                	mv	a3,s1
    9452:	866a                	mv	a2,s10
    9454:	85ca                	mv	a1,s2
    9456:	02000513          	li	a0,32
    945a:	9402                	jalr	s0
    945c:	007b0c93          	addi	s9,s6,7
    9460:	86a6                	mv	a3,s1
    9462:	8666                	mv	a2,s9
    9464:	85ca                	mv	a1,s2
    9466:	02000513          	li	a0,32
    946a:	9402                	jalr	s0
    946c:	6302                	ld	t1,0(sp)
    946e:	0b21                	addi	s6,s6,8
    9470:	f86b10e3          	bne	s6,t1,93f0 <_vsnprintf+0x850>
    9474:	0040106f          	j	a478 <_vsnprintf+0x18d8>
    9478:	6ea2                	ld	t4,8(sp)
    947a:	002b6e13          	ori	t3,s6,2
    947e:	000e0b1b          	sext.w	s6,t3
    9482:	001e8f13          	addi	t5,t4,1
    9486:	001ec503          	lbu	a0,1(t4)
    948a:	411008bb          	negw	a7,a7
    948e:	e47a                	sd	t5,8(sp)
    9490:	fbeff06f          	j	8c4e <_vsnprintf+0xae>
    9494:	6e22                	ld	t3,8(sp)
    9496:	06c00d13          	li	s10,108
    949a:	001e4503          	lbu	a0,1(t3)
    949e:	01a51463          	bne	a0,s10,94a6 <_vsnprintf+0x906>
    94a2:	25e0106f          	j	a700 <_vsnprintf+0x1b60>
    94a6:	100b6b13          	ori	s6,s6,256
    94aa:	001e0e93          	addi	t4,t3,1
    94ae:	2b01                	sext.w	s6,s6
    94b0:	e476                	sd	t4,8(sp)
    94b2:	b039                	j	8cc0 <_vsnprintf+0x120>
    94b4:	67a2                	ld	a5,8(sp)
    94b6:	06800593          	li	a1,104
    94ba:	0017c503          	lbu	a0,1(a5)
    94be:	00b51463          	bne	a0,a1,94c6 <_vsnprintf+0x926>
    94c2:	2280106f          	j	a6ea <_vsnprintf+0x1b4a>
    94c6:	080b6f13          	ori	t5,s6,128
    94ca:	00178613          	addi	a2,a5,1
    94ce:	000f0b1b          	sext.w	s6,t5
    94d2:	e432                	sd	a2,8(sp)
    94d4:	fecff06f          	j	8cc0 <_vsnprintf+0x120>
    94d8:	06700693          	li	a3,103
    94dc:	0ed503e3          	beq	a0,a3,9dc2 <_vsnprintf+0x1222>
    94e0:	04700f13          	li	t5,71
    94e4:	01e51463          	bne	a0,t5,94ec <_vsnprintf+0x94c>
    94e8:	1280106f          	j	a610 <_vsnprintf+0x1a70>
    94ec:	04500713          	li	a4,69
    94f0:	00e51463          	bne	a0,a4,94f8 <_vsnprintf+0x958>
    94f4:	12a0106f          	j	a61e <_vsnprintf+0x1a7e>
    94f8:	000db507          	fld	fa0,0(s11)
    94fc:	008d8b93          	addi	s7,s11,8
    9500:	a2a52dd3          	feq.d	s11,fa0,fa0
    9504:	000d9463          	bnez	s11,950c <_vsnprintf+0x96c>
    9508:	0e80106f          	j	a5f0 <_vsnprintf+0x1a50>
    950c:	6d45                	lui	s10,0x11
    950e:	ba0d3787          	fld	fa5,-1120(s10) # 10ba0 <errpat+0x58>
    9512:	a2a793d3          	flt.d	t2,fa5,fa0
    9516:	00038463          	beqz	t2,951e <_vsnprintf+0x97e>
    951a:	0d60106f          	j	a5f0 <_vsnprintf+0x1a50>
    951e:	6ac5                	lui	s5,0x11
    9520:	b98ab007          	fld	ft0,-1128(s5) # 10b98 <errpat+0x50>
    9524:	a20517d3          	flt.d	a5,fa0,ft0
    9528:	c399                	beqz	a5,952e <_vsnprintf+0x98e>
    952a:	0c60106f          	j	a5f0 <_vsnprintf+0x1a50>
    952e:	f20000d3          	fmv.d.x	ft1,zero
    9532:	a2151ed3          	flt.d	t4,fa0,ft1
    9536:	e20506d3          	fmv.x.d	a3,fa0
    953a:	000e8663          	beqz	t4,9546 <_vsnprintf+0x9a6>
    953e:	22a51153          	fneg.d	ft2,fa0
    9542:	e20106d3          	fmv.x.d	a3,ft2
    9546:	400b7f93          	andi	t6,s6,1024
    954a:	4719                	li	a4,6
    954c:	6f45                	lui	t5,0x11
    954e:	6545                	lui	a0,0x11
    9550:	43fc170b          	th.mvnez	a4,s8,t6
    9554:	fb46bc0b          	th.extu	s8,a3,62,52
    9558:	bb8f3687          	fld	fa3,-1096(t5) # 10bb8 <errpat+0x70>
    955c:	bc053707          	fld	fa4,-1088(a0) # 10bc0 <errpat+0x78>
    9560:	c01c059b          	addiw	a1,s8,-1023
    9564:	d20581d3          	fcvt.d.w	ft3,a1
    9568:	3ff00293          	li	t0,1023
    956c:	6645                	lui	a2,0x11
    956e:	bc863287          	fld	ft5,-1080(a2) # 10bc8 <errpat+0x80>
    9572:	03429313          	slli	t1,t0,0x34
    9576:	cc06b80b          	th.extu	a6,a3,51,0
    957a:	72d1f243          	fmadd.d	ft4,ft3,fa3,fa4
    957e:	00686e33          	or	t3,a6,t1
    9582:	f20e0353          	fmv.d.x	ft6,t3
    9586:	6cc5                	lui	s9,0x11
    9588:	0a5373d3          	fsub.d	ft7,ft6,ft5
    958c:	bd0cb587          	fld	fa1,-1072(s9) # 10bd0 <errpat+0x88>
    9590:	63c5                	lui	t2,0x11
    9592:	6ac5                	lui	s5,0x11
    9594:	22b3f643          	fmadd.d	fa2,ft7,fa1,ft4
    9598:	bd83b887          	fld	fa7,-1064(t2) # 10bd8 <errpat+0x90>
    959c:	be0abe07          	fld	ft8,-1056(s5) # 10be0 <errpat+0x98>
    95a0:	6ec5                	lui	t4,0x11
    95a2:	be8ebf87          	fld	ft11,-1048(t4) # 10be8 <errpat+0xa0>
    95a6:	c2061d53          	fcvt.w.d	s10,fa2,rtz
    95aa:	6c45                	lui	s8,0x11
    95ac:	d20d0853          	fcvt.d.w	fa6,s10
    95b0:	bf0c3007          	fld	ft0,-1040(s8) # 10bf0 <errpat+0xa8>
    95b4:	e3187ec3          	fmadd.d	ft9,fa6,fa7,ft8
    95b8:	65c5                	lui	a1,0x11
    95ba:	bf85b687          	fld	fa3,-1032(a1) # 10bf8 <errpat+0xb0>
    95be:	6f45                	lui	t5,0x11
    95c0:	b80f3207          	fld	ft4,-1152(t5) # 10b80 <errpat+0x38>
    95c4:	c20e97d3          	fcvt.w.d	a5,ft9,rtz
    95c8:	6545                	lui	a0,0x11
    95ca:	d2078f53          	fcvt.d.w	ft10,a5
    95ce:	c0053387          	fld	ft7,-1024(a0) # 10c00 <errpat+0xb8>
    95d2:	13ff77d3          	fmul.d	fa5,ft10,ft11
    95d6:	6845                	lui	a6,0x11
    95d8:	62c5                	lui	t0,0x11
    95da:	b902bf07          	fld	ft10,-1136(t0) # 10b90 <errpat+0x48>
    95de:	7a0870c7          	fmsub.d	ft1,fa6,ft0,fa5
    95e2:	c0883807          	fld	fa6,-1016(a6) # 10c08 <errpat+0xc0>
    95e6:	3ff7831b          	addiw	t1,a5,1023
    95ea:	03431e13          	slli	t3,t1,0x34
    95ee:	f20e07d3          	fmv.d.x	fa5,t3
    95f2:	1210f153          	fmul.d	ft2,ft1,ft1
    95f6:	0a1878d3          	fsub.d	fa7,fa6,ft1
    95fa:	0210f1d3          	fadd.d	ft3,ft1,ft1
    95fe:	f2068053          	fmv.d.x	ft0,a3
    9602:	1ad17753          	fdiv.d	fa4,ft2,fa3
    9606:	000d0d9b          	sext.w	s11,s10
    960a:	024772d3          	fadd.d	ft5,fa4,ft4
    960e:	1a517353          	fdiv.d	ft6,ft2,ft5
    9612:	027375d3          	fadd.d	fa1,ft6,ft7
    9616:	1ab17653          	fdiv.d	fa2,ft2,fa1
    961a:	03167e53          	fadd.d	ft8,fa2,fa7
    961e:	1bc1fed3          	fdiv.d	ft9,ft3,ft8
    9622:	03eeffd3          	fadd.d	ft11,ft9,ft10
    9626:	12fff0d3          	fmul.d	ft1,ft11,fa5
    962a:	a2101653          	flt.d	a2,ft0,ft1
    962e:	c609                	beqz	a2,9638 <_vsnprintf+0xa98>
    9630:	1a40f0d3          	fdiv.d	ft1,ft1,ft4
    9634:	fffd0d9b          	addiw	s11,s10,-1
    9638:	0c600d13          	li	s10,198
    963c:	063d8c9b          	addiw	s9,s11,99
    9640:	73ad0793          	addi	a5,s10,1850
    9644:	019d33b3          	sltu	t2,s10,s9
    9648:	00fb77b3          	and	a5,s6,a5
    964c:	00438e13          	addi	t3,t2,4
    9650:	8ada                	mv	s5,s6
    9652:	e399                	bnez	a5,9658 <_vsnprintf+0xab8>
    9654:	0990106f          	j	aeec <_vsnprintf+0x234c>
    9658:	6c45                	lui	s8,0x11
    965a:	c10c3107          	fld	ft2,-1008(s8) # 10c10 <errpat+0xc8>
    965e:	f20681d3          	fmv.d.x	ft3,a3
    9662:	a23105d3          	fle.d	a1,ft2,ft3
    9666:	e199                	bnez	a1,966c <_vsnprintf+0xacc>
    9668:	4a00206f          	j	bb08 <_vsnprintf+0x2f68>
    966c:	6f45                	lui	t5,0x11
    966e:	c18f3707          	fld	fa4,-1000(t5) # 10c18 <errpat+0xd0>
    9672:	a2e19553          	flt.d	a0,ft3,fa4
    9676:	e119                	bnez	a0,967c <_vsnprintf+0xadc>
    9678:	4900206f          	j	bb08 <_vsnprintf+0x2f68>
    967c:	41b70e3b          	subw	t3,a4,s11
    9680:	fffe061b          	addiw	a2,t3,-1
    9684:	00eda733          	slt	a4,s11,a4
    9688:	40e0160b          	th.mveqz	a2,zero,a4
    968c:	400b6c93          	ori	s9,s6,1024
    9690:	8732                	mv	a4,a2
    9692:	8db2                	mv	s11,a2
    9694:	000c8d1b          	sext.w	s10,s9
    9698:	002b7a93          	andi	s5,s6,2
    969c:	00089463          	bnez	a7,96a4 <_vsnprintf+0xb04>
    96a0:	4d20406f          	j	db72 <_vsnprintf+0x4fd2>
    96a4:	000a9463          	bnez	s5,96ac <_vsnprintf+0xb0c>
    96a8:	4ca0406f          	j	db72 <_vsnprintf+0x4fd2>
    96ac:	87c6                	mv	a5,a7
    96ae:	8b6a                	mv	s6,s10
    96b0:	4d81                	li	s11,0
    96b2:	4a89                	li	s5,2
    96b4:	4e01                	li	t3,0
    96b6:	f20003d3          	fmv.d.x	ft7,zero
    96ba:	a2751c53          	flt.d	s8,fa0,ft7
    96be:	000c0463          	beqz	s8,96c6 <_vsnprintf+0xb26>
    96c2:	5e10106f          	j	b4a2 <_vsnprintf+0x2902>
    96c6:	75fd                	lui	a1,0xfffff
    96c8:	7ff58f13          	addi	t5,a1,2047 # fffffffffffff7ff <__kernel_stack+0xfffffffffff117ff>
    96cc:	6602                	ld	a2,0(sp)
    96ce:	01eb7533          	and	a0,s6,t5
    96d2:	0005081b          	sext.w	a6,a0
    96d6:	f2068553          	fmv.d.x	fa0,a3
    96da:	85ca                	mv	a1,s2
    96dc:	86a6                	mv	a3,s1
    96de:	8522                	mv	a0,s0
    96e0:	ec72                	sd	t3,24(sp)
    96e2:	f046                	sd	a7,32(sp)
    96e4:	a2dfd0ef          	jal	7110 <_ftoa>
    96e8:	68e2                	ld	a7,24(sp)
    96ea:	862a                	mv	a2,a0
    96ec:	00089463          	bnez	a7,96f4 <_vsnprintf+0xb54>
    96f0:	4ff0106f          	j	b3ee <_vsnprintf+0x284e>
    96f4:	020b7813          	andi	a6,s6,32
    96f8:	06500293          	li	t0,101
    96fc:	00150c93          	addi	s9,a0,1
    9700:	04500513          	li	a0,69
    9704:	86a6                	mv	a3,s1
    9706:	4102950b          	th.mveqz	a0,t0,a6
    970a:	f432                	sd	a2,40(sp)
    970c:	85ca                	mv	a1,s2
    970e:	9402                	jalr	s0
    9710:	41fdd31b          	sraiw	t1,s11,0x1f
    9714:	006dc633          	xor	a2,s11,t1
    9718:	4066073b          	subw	a4,a2,t1
    971c:	43a9                	li	t2,10
    971e:	02777fb3          	remu	t6,a4,t2
    9722:	03010d13          	addi	s10,sp,48
    9726:	47a5                	li	a5,9
    9728:	6e62                	ld	t3,24(sp)
    972a:	fdd1488b          	th.ldd	a7,t4,(sp),2,4
    972e:	86ea                	mv	a3,s10
    9730:	030f8b1b          	addiw	s6,t6,48
    9734:	03610823          	sb	s6,48(sp)
    9738:	02775533          	divu	a0,a4,t2
    973c:	10e7fa63          	bgeu	a5,a4,9850 <_vsnprintf+0xcb0>
    9740:	03110693          	addi	a3,sp,49
    9744:	02757c33          	remu	s8,a0,t2
    9748:	030c059b          	addiw	a1,s8,48
    974c:	00b68023          	sb	a1,0(a3)
    9750:	02755f33          	divu	t5,a0,t2
    9754:	0ea7fe63          	bgeu	a5,a0,9850 <_vsnprintf+0xcb0>
    9758:	00168293          	addi	t0,a3,1
    975c:	0888                	addi	a0,sp,80
    975e:	0e550963          	beq	a0,t0,9850 <_vsnprintf+0xcb0>
    9762:	8696                	mv	a3,t0
    9764:	027f7833          	remu	a6,t5,t2
    9768:	0308031b          	addiw	t1,a6,48
    976c:	00628023          	sb	t1,0(t0)
    9770:	027f5633          	divu	a2,t5,t2
    9774:	0de7fe63          	bgeu	a5,t5,9850 <_vsnprintf+0xcb0>
    9778:	02767733          	remu	a4,a2,t2
    977c:	03070f9b          	addiw	t6,a4,48
    9780:	0816df8b          	th.sbib	t6,(a3),1,0
    9784:	02765b33          	divu	s6,a2,t2
    9788:	0cc7f463          	bgeu	a5,a2,9850 <_vsnprintf+0xcb0>
    978c:	00228693          	addi	a3,t0,2
    9790:	027b7c33          	remu	s8,s6,t2
    9794:	030c059b          	addiw	a1,s8,48
    9798:	00b28123          	sb	a1,2(t0)
    979c:	027b5f33          	divu	t5,s6,t2
    97a0:	0b67f863          	bgeu	a5,s6,9850 <_vsnprintf+0xcb0>
    97a4:	00328693          	addi	a3,t0,3
    97a8:	027f7533          	remu	a0,t5,t2
    97ac:	0305081b          	addiw	a6,a0,48
    97b0:	010281a3          	sb	a6,3(t0)
    97b4:	027f5333          	divu	t1,t5,t2
    97b8:	09e7fc63          	bgeu	a5,t5,9850 <_vsnprintf+0xcb0>
    97bc:	00428693          	addi	a3,t0,4
    97c0:	02737633          	remu	a2,t1,t2
    97c4:	0306071b          	addiw	a4,a2,48
    97c8:	00e28223          	sb	a4,4(t0)
    97cc:	02735fb3          	divu	t6,t1,t2
    97d0:	0867f063          	bgeu	a5,t1,9850 <_vsnprintf+0xcb0>
    97d4:	00528693          	addi	a3,t0,5
    97d8:	027ffb33          	remu	s6,t6,t2
    97dc:	030b0c1b          	addiw	s8,s6,48
    97e0:	018282a3          	sb	s8,5(t0)
    97e4:	027fd5b3          	divu	a1,t6,t2
    97e8:	07f7f463          	bgeu	a5,t6,9850 <_vsnprintf+0xcb0>
    97ec:	00628693          	addi	a3,t0,6
    97f0:	0275ff33          	remu	t5,a1,t2
    97f4:	030f051b          	addiw	a0,t5,48
    97f8:	00a28323          	sb	a0,6(t0)
    97fc:	0275d333          	divu	t1,a1,t2
    9800:	04b7f863          	bgeu	a5,a1,9850 <_vsnprintf+0xcb0>
    9804:	00728693          	addi	a3,t0,7
    9808:	02737833          	remu	a6,t1,t2
    980c:	0308061b          	addiw	a2,a6,48
    9810:	00c283a3          	sb	a2,7(t0)
    9814:	02735733          	divu	a4,t1,t2
    9818:	0267fc63          	bgeu	a5,t1,9850 <_vsnprintf+0xcb0>
    981c:	00828693          	addi	a3,t0,8
    9820:	02777fb3          	remu	t6,a4,t2
    9824:	030f8b1b          	addiw	s6,t6,48
    9828:	01628423          	sb	s6,8(t0)
    982c:	02775533          	divu	a0,a4,t2
    9830:	02e7f063          	bgeu	a5,a4,9850 <_vsnprintf+0xcb0>
    9834:	00928693          	addi	a3,t0,9
    9838:	02757c33          	remu	s8,a0,t2
    983c:	030c059b          	addiw	a1,s8,48
    9840:	00b68023          	sb	a1,0(a3)
    9844:	02755f33          	divu	t5,a0,t2
    9848:	f0a7e8e3          	bltu	a5,a0,9758 <_vsnprintf+0xbb8>
    984c:	00000013          	nop
    9850:	4385                	li	t2,1
    9852:	41a387b3          	sub	a5,t2,s10
    9856:	00d78c33          	add	s8,a5,a3
    985a:	ffee069b          	addiw	a3,t3,-2
    985e:	7c06b28b          	th.extu	t0,a3,31,0
    9862:	005c6463          	bltu	s8,t0,986a <_vsnprintf+0xcca>
    9866:	0640306f          	j	c8ca <_vsnprintf+0x3d2a>
    986a:	018d07b3          	add	a5,s10,s8
    986e:	005d0f33          	add	t5,s10,t0
    9872:	40ff05b3          	sub	a1,t5,a5
    9876:	0075f613          	andi	a2,a1,7
    987a:	03000313          	li	t1,48
    987e:	e219                	bnez	a2,9884 <_vsnprintf+0xce4>
    9880:	3330106f          	j	b3b2 <_vsnprintf+0x2812>
    9884:	02760e63          	beq	a2,t2,98c0 <_vsnprintf+0xd20>
    9888:	4809                	li	a6,2
    988a:	03060963          	beq	a2,a6,98bc <_vsnprintf+0xd1c>
    988e:	470d                	li	a4,3
    9890:	02e60463          	beq	a2,a4,98b8 <_vsnprintf+0xd18>
    9894:	4f91                	li	t6,4
    9896:	01f60f63          	beq	a2,t6,98b4 <_vsnprintf+0xd14>
    989a:	4b15                	li	s6,5
    989c:	01660a63          	beq	a2,s6,98b0 <_vsnprintf+0xd10>
    98a0:	4519                	li	a0,6
    98a2:	00a60563          	beq	a2,a0,98ac <_vsnprintf+0xd0c>
    98a6:	018d530b          	th.srb	t1,s10,s8,0
    98aa:	0785                	addi	a5,a5,1
    98ac:	1817d30b          	th.sbia	t1,(a5),1,0
    98b0:	1817d30b          	th.sbia	t1,(a5),1,0
    98b4:	1817d30b          	th.sbia	t1,(a5),1,0
    98b8:	1817d30b          	th.sbia	t1,(a5),1,0
    98bc:	1817d30b          	th.sbia	t1,(a5),1,0
    98c0:	1817d30b          	th.sbia	t1,(a5),1,0
    98c4:	01e78463          	beq	a5,t5,98cc <_vsnprintf+0xd2c>
    98c8:	2eb0106f          	j	b3b2 <_vsnprintf+0x2812>
    98cc:	02028393          	addi	t2,t0,32
    98d0:	1814                	addi	a3,sp,48
    98d2:	00128c13          	addi	s8,t0,1
    98d6:	00d38e33          	add	t3,t2,a3
    98da:	000dc463          	bltz	s11,98e2 <_vsnprintf+0xd42>
    98de:	5a70306f          	j	d684 <_vsnprintf+0x4ae4>
    98e2:	02d00513          	li	a0,45
    98e6:	feae0023          	sb	a0,-32(t3)
    98ea:	018d0db3          	add	s11,s10,s8
    98ee:	fffd4f13          	not	t5,s10
    98f2:	001d0293          	addi	t0,s10,1
    98f6:	01bf0333          	add	t1,t5,s11
    98fa:	9e96                	add	t4,t4,t0
    98fc:	00737813          	andi	a6,t1,7
    9900:	018e8b33          	add	s6,t4,s8
    9904:	00081463          	bnez	a6,990c <_vsnprintf+0xd6c>
    9908:	5e10306f          	j	d6e8 <_vsnprintf+0x4b48>
    990c:	41bb0633          	sub	a2,s6,s11
    9910:	ec46                	sd	a7,24(sp)
    9912:	f042                	sd	a6,32(sp)
    9914:	85ca                	mv	a1,s2
    9916:	86a6                	mv	a3,s1
    9918:	9402                	jalr	s0
    991a:	68e2                	ld	a7,24(sp)
    991c:	7602                	ld	a2,32(sp)
    991e:	4585                	li	a1,1
    9920:	1dfd                	addi	s11,s11,-1
    9922:	fffdc503          	lbu	a0,-1(s11)
    9926:	00b61463          	bne	a2,a1,992e <_vsnprintf+0xd8e>
    992a:	5bf0306f          	j	d6e8 <_vsnprintf+0x4b48>
    992e:	4709                	li	a4,2
    9930:	06e60f63          	beq	a2,a4,99ae <_vsnprintf+0xe0e>
    9934:	4f8d                	li	t6,3
    9936:	07f60263          	beq	a2,t6,999a <_vsnprintf+0xdfa>
    993a:	4791                	li	a5,4
    993c:	04f60563          	beq	a2,a5,9986 <_vsnprintf+0xde6>
    9940:	4395                	li	t2,5
    9942:	02760863          	beq	a2,t2,9972 <_vsnprintf+0xdd2>
    9946:	4699                	li	a3,6
    9948:	00d60b63          	beq	a2,a3,995e <_vsnprintf+0xdbe>
    994c:	41bb0633          	sub	a2,s6,s11
    9950:	86a6                	mv	a3,s1
    9952:	85ca                	mv	a1,s2
    9954:	9402                	jalr	s0
    9956:	68e2                	ld	a7,24(sp)
    9958:	ffedc503          	lbu	a0,-2(s11)
    995c:	1dfd                	addi	s11,s11,-1
    995e:	41bb0633          	sub	a2,s6,s11
    9962:	ec46                	sd	a7,24(sp)
    9964:	86a6                	mv	a3,s1
    9966:	85ca                	mv	a1,s2
    9968:	9402                	jalr	s0
    996a:	68e2                	ld	a7,24(sp)
    996c:	ffedc503          	lbu	a0,-2(s11)
    9970:	1dfd                	addi	s11,s11,-1
    9972:	41bb0633          	sub	a2,s6,s11
    9976:	ec46                	sd	a7,24(sp)
    9978:	86a6                	mv	a3,s1
    997a:	85ca                	mv	a1,s2
    997c:	9402                	jalr	s0
    997e:	68e2                	ld	a7,24(sp)
    9980:	ffedc503          	lbu	a0,-2(s11)
    9984:	1dfd                	addi	s11,s11,-1
    9986:	41bb0633          	sub	a2,s6,s11
    998a:	ec46                	sd	a7,24(sp)
    998c:	86a6                	mv	a3,s1
    998e:	85ca                	mv	a1,s2
    9990:	9402                	jalr	s0
    9992:	68e2                	ld	a7,24(sp)
    9994:	ffedc503          	lbu	a0,-2(s11)
    9998:	1dfd                	addi	s11,s11,-1
    999a:	41bb0633          	sub	a2,s6,s11
    999e:	ec46                	sd	a7,24(sp)
    99a0:	86a6                	mv	a3,s1
    99a2:	85ca                	mv	a1,s2
    99a4:	9402                	jalr	s0
    99a6:	68e2                	ld	a7,24(sp)
    99a8:	ffedc503          	lbu	a0,-2(s11)
    99ac:	1dfd                	addi	s11,s11,-1
    99ae:	41bb0633          	sub	a2,s6,s11
    99b2:	86a6                	mv	a3,s1
    99b4:	85ca                	mv	a1,s2
    99b6:	ec46                	sd	a7,24(sp)
    99b8:	9402                	jalr	s0
    99ba:	1dfd                	addi	s11,s11,-1
    99bc:	fd515b8b          	th.sdd	s7,s5,(sp),2,4
    99c0:	fffdc503          	lbu	a0,-1(s11)
    99c4:	a895                	j	9a38 <_vsnprintf+0xe98>
    99c6:	8bee                	mv	s7,s11
    99c8:	89ebc50b          	th.lbuib	a0,(s7),-2,0
    99cc:	415b0633          	sub	a2,s6,s5
    99d0:	86a6                	mv	a3,s1
    99d2:	85ca                	mv	a1,s2
    99d4:	9402                	jalr	s0
    99d6:	8aee                	mv	s5,s11
    99d8:	89dac50b          	th.lbuib	a0,(s5),-3,0
    99dc:	417b0633          	sub	a2,s6,s7
    99e0:	86a6                	mv	a3,s1
    99e2:	85ca                	mv	a1,s2
    99e4:	9402                	jalr	s0
    99e6:	8bee                	mv	s7,s11
    99e8:	89cbc50b          	th.lbuib	a0,(s7),-4,0
    99ec:	415b0633          	sub	a2,s6,s5
    99f0:	86a6                	mv	a3,s1
    99f2:	85ca                	mv	a1,s2
    99f4:	9402                	jalr	s0
    99f6:	8aee                	mv	s5,s11
    99f8:	89bac50b          	th.lbuib	a0,(s5),-5,0
    99fc:	417b0633          	sub	a2,s6,s7
    9a00:	86a6                	mv	a3,s1
    9a02:	85ca                	mv	a1,s2
    9a04:	9402                	jalr	s0
    9a06:	8bee                	mv	s7,s11
    9a08:	89abc50b          	th.lbuib	a0,(s7),-6,0
    9a0c:	415b0633          	sub	a2,s6,s5
    9a10:	86a6                	mv	a3,s1
    9a12:	85ca                	mv	a1,s2
    9a14:	9402                	jalr	s0
    9a16:	8aee                	mv	s5,s11
    9a18:	899ac50b          	th.lbuib	a0,(s5),-7,0
    9a1c:	86a6                	mv	a3,s1
    9a1e:	417b0633          	sub	a2,s6,s7
    9a22:	85ca                	mv	a1,s2
    9a24:	9402                	jalr	s0
    9a26:	898dc50b          	th.lbuib	a0,(s11),-8,0
    9a2a:	86a6                	mv	a3,s1
    9a2c:	415b0633          	sub	a2,s6,s5
    9a30:	85ca                	mv	a1,s2
    9a32:	9402                	jalr	s0
    9a34:	fffdc503          	lbu	a0,-1(s11)
    9a38:	86a6                	mv	a3,s1
    9a3a:	41bb0633          	sub	a2,s6,s11
    9a3e:	85ca                	mv	a1,s2
    9a40:	fffd8a93          	addi	s5,s11,-1
    9a44:	9402                	jalr	s0
    9a46:	f95d10e3          	bne	s10,s5,99c6 <_vsnprintf+0xe26>
    9a4a:	fda14b8b          	th.ldd	s7,s10,(sp),2,4
    9a4e:	018c8633          	add	a2,s9,s8
    9a52:	6ce2                	ld	s9,24(sp)
    9a54:	000d1463          	bnez	s10,9a5c <_vsnprintf+0xebc>
    9a58:	1970106f          	j	b3ee <_vsnprintf+0x284e>
    9a5c:	6502                	ld	a0,0(sp)
    9a5e:	7c0cbd8b          	th.extu	s11,s9,31,0
    9a62:	40a60ab3          	sub	s5,a2,a0
    9a66:	01bae463          	bltu	s5,s11,9a6e <_vsnprintf+0xece>
    9a6a:	1850106f          	j	b3ee <_vsnprintf+0x284e>
    9a6e:	fffacc13          	not	s8,s5
    9a72:	01bc0e33          	add	t3,s8,s11
    9a76:	86a6                	mv	a3,s1
    9a78:	85ca                	mv	a1,s2
    9a7a:	02000513          	li	a0,32
    9a7e:	001a8d13          	addi	s10,s5,1
    9a82:	007e7c93          	andi	s9,t3,7
    9a86:	00160b13          	addi	s6,a2,1
    9a8a:	9402                	jalr	s0
    9a8c:	13bd7263          	bgeu	s10,s11,9bb0 <_vsnprintf+0x1010>
    9a90:	080c8e63          	beqz	s9,9b2c <_vsnprintf+0xf8c>
    9a94:	4285                	li	t0,1
    9a96:	085c8163          	beq	s9,t0,9b18 <_vsnprintf+0xf78>
    9a9a:	4e89                	li	t4,2
    9a9c:	07dc8663          	beq	s9,t4,9b08 <_vsnprintf+0xf68>
    9aa0:	4f0d                	li	t5,3
    9aa2:	05ec8b63          	beq	s9,t5,9af8 <_vsnprintf+0xf58>
    9aa6:	4311                	li	t1,4
    9aa8:	046c8063          	beq	s9,t1,9ae8 <_vsnprintf+0xf48>
    9aac:	4815                	li	a6,5
    9aae:	030c8563          	beq	s9,a6,9ad8 <_vsnprintf+0xf38>
    9ab2:	4599                	li	a1,6
    9ab4:	00bc8a63          	beq	s9,a1,9ac8 <_vsnprintf+0xf28>
    9ab8:	865a                	mv	a2,s6
    9aba:	86a6                	mv	a3,s1
    9abc:	85ca                	mv	a1,s2
    9abe:	02000513          	li	a0,32
    9ac2:	0b05                	addi	s6,s6,1
    9ac4:	9402                	jalr	s0
    9ac6:	0d05                	addi	s10,s10,1
    9ac8:	865a                	mv	a2,s6
    9aca:	86a6                	mv	a3,s1
    9acc:	85ca                	mv	a1,s2
    9ace:	02000513          	li	a0,32
    9ad2:	0b05                	addi	s6,s6,1
    9ad4:	9402                	jalr	s0
    9ad6:	0d05                	addi	s10,s10,1
    9ad8:	865a                	mv	a2,s6
    9ada:	86a6                	mv	a3,s1
    9adc:	85ca                	mv	a1,s2
    9ade:	02000513          	li	a0,32
    9ae2:	0b05                	addi	s6,s6,1
    9ae4:	9402                	jalr	s0
    9ae6:	0d05                	addi	s10,s10,1
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
    9b22:	0d05                	addi	s10,s10,1
    9b24:	0b05                	addi	s6,s6,1
    9b26:	9402                	jalr	s0
    9b28:	09bd7463          	bgeu	s10,s11,9bb0 <_vsnprintf+0x1010>
    9b2c:	865a                	mv	a2,s6
    9b2e:	86a6                	mv	a3,s1
    9b30:	85ca                	mv	a1,s2
    9b32:	02000513          	li	a0,32
    9b36:	9402                	jalr	s0
    9b38:	001b0a93          	addi	s5,s6,1
    9b3c:	8656                	mv	a2,s5
    9b3e:	86a6                	mv	a3,s1
    9b40:	85ca                	mv	a1,s2
    9b42:	02000513          	li	a0,32
    9b46:	9402                	jalr	s0
    9b48:	002b0c13          	addi	s8,s6,2
    9b4c:	8662                	mv	a2,s8
    9b4e:	86a6                	mv	a3,s1
    9b50:	85ca                	mv	a1,s2
    9b52:	02000513          	li	a0,32
    9b56:	9402                	jalr	s0
    9b58:	003b0c93          	addi	s9,s6,3
    9b5c:	8666                	mv	a2,s9
    9b5e:	86a6                	mv	a3,s1
    9b60:	85ca                	mv	a1,s2
    9b62:	02000513          	li	a0,32
    9b66:	9402                	jalr	s0
    9b68:	004b0c13          	addi	s8,s6,4
    9b6c:	8662                	mv	a2,s8
    9b6e:	86a6                	mv	a3,s1
    9b70:	85ca                	mv	a1,s2
    9b72:	02000513          	li	a0,32
    9b76:	9402                	jalr	s0
    9b78:	005b0a93          	addi	s5,s6,5
    9b7c:	86a6                	mv	a3,s1
    9b7e:	8656                	mv	a2,s5
    9b80:	85ca                	mv	a1,s2
    9b82:	02000513          	li	a0,32
    9b86:	9402                	jalr	s0
    9b88:	006b0c93          	addi	s9,s6,6
    9b8c:	86a6                	mv	a3,s1
    9b8e:	8666                	mv	a2,s9
    9b90:	85ca                	mv	a1,s2
    9b92:	02000513          	li	a0,32
    9b96:	9402                	jalr	s0
    9b98:	007b0c13          	addi	s8,s6,7
    9b9c:	86a6                	mv	a3,s1
    9b9e:	8662                	mv	a2,s8
    9ba0:	85ca                	mv	a1,s2
    9ba2:	02000513          	li	a0,32
    9ba6:	0d21                	addi	s10,s10,8
    9ba8:	0b21                	addi	s6,s6,8
    9baa:	9402                	jalr	s0
    9bac:	f9bd60e3          	bltu	s10,s11,9b2c <_vsnprintf+0xf8c>
    9bb0:	e05a                	sd	s6,0(sp)
    9bb2:	2530006f          	j	a604 <_vsnprintf+0x1a64>
    9bb6:	0001                	nop
    9bb8:	000db507          	fld	fa0,0(s11)
    9bbc:	020b6793          	ori	a5,s6,32
    9bc0:	6602                	ld	a2,0(sp)
    9bc2:	fba50e93          	addi	t4,a0,-70
    9bc6:	0007881b          	sext.w	a6,a5
    9bca:	008d8f93          	addi	t6,s11,8
    9bce:	85ca                	mv	a1,s2
    9bd0:	43db180b          	th.mvnez	a6,s6,t4
    9bd4:	87c6                	mv	a5,a7
    9bd6:	8762                	mv	a4,s8
    9bd8:	86a6                	mv	a3,s1
    9bda:	8522                	mv	a0,s0
    9bdc:	8dfe                	mv	s11,t6
    9bde:	d32fd0ef          	jal	7110 <_ftoa>
    9be2:	65a2                	ld	a1,8(sp)
    9be4:	e02a                	sd	a0,0(sp)
    9be6:	00158c93          	addi	s9,a1,1
    9bea:	816ff06f          	j	8c00 <_vsnprintf+0x60>
    9bee:	002b7b13          	andi	s6,s6,2
    9bf2:	320b0de3          	beqz	s6,a72c <_vsnprintf+0x1b8c>
    9bf6:	6602                	ld	a2,0(sp)
    9bf8:	988dc50b          	th.lbuia	a0,(s11),8,0
    9bfc:	86a6                	mv	a3,s1
    9bfe:	85ca                	mv	a1,s2
    9c00:	ec46                	sd	a7,24(sp)
    9c02:	00160b13          	addi	s6,a2,1
    9c06:	9402                	jalr	s0
    9c08:	6c62                	ld	s8,24(sp)
    9c0a:	4285                	li	t0,1
    9c0c:	0782f2e3          	bgeu	t0,s8,a470 <_vsnprintf+0x18d0>
    9c10:	6b82                	ld	s7,0(sp)
    9c12:	ffec051b          	addiw	a0,s8,-2
    9c16:	7c053e8b          	th.extu	t4,a0,31,0
    9c1a:	002b8a93          	addi	s5,s7,2
    9c1e:	015e8e33          	add	t3,t4,s5
    9c22:	416e0f33          	sub	t5,t3,s6
    9c26:	e072                	sd	t3,0(sp)
    9c28:	007f7593          	andi	a1,t5,7
    9c2c:	c5d1                	beqz	a1,9cb8 <_vsnprintf+0x1118>
    9c2e:	06558b63          	beq	a1,t0,9ca4 <_vsnprintf+0x1104>
    9c32:	4889                	li	a7,2
    9c34:	07158163          	beq	a1,a7,9c96 <_vsnprintf+0x10f6>
    9c38:	470d                	li	a4,3
    9c3a:	04e58763          	beq	a1,a4,9c88 <_vsnprintf+0x10e8>
    9c3e:	4611                	li	a2,4
    9c40:	02c58d63          	beq	a1,a2,9c7a <_vsnprintf+0x10da>
    9c44:	4795                	li	a5,5
    9c46:	02f58363          	beq	a1,a5,9c6c <_vsnprintf+0x10cc>
    9c4a:	4d19                	li	s10,6
    9c4c:	01a58963          	beq	a1,s10,9c5e <_vsnprintf+0x10be>
    9c50:	865a                	mv	a2,s6
    9c52:	86a6                	mv	a3,s1
    9c54:	85ca                	mv	a1,s2
    9c56:	02000513          	li	a0,32
    9c5a:	0b05                	addi	s6,s6,1
    9c5c:	9402                	jalr	s0
    9c5e:	865a                	mv	a2,s6
    9c60:	86a6                	mv	a3,s1
    9c62:	85ca                	mv	a1,s2
    9c64:	02000513          	li	a0,32
    9c68:	0b05                	addi	s6,s6,1
    9c6a:	9402                	jalr	s0
    9c6c:	865a                	mv	a2,s6
    9c6e:	86a6                	mv	a3,s1
    9c70:	85ca                	mv	a1,s2
    9c72:	02000513          	li	a0,32
    9c76:	0b05                	addi	s6,s6,1
    9c78:	9402                	jalr	s0
    9c7a:	865a                	mv	a2,s6
    9c7c:	86a6                	mv	a3,s1
    9c7e:	85ca                	mv	a1,s2
    9c80:	02000513          	li	a0,32
    9c84:	0b05                	addi	s6,s6,1
    9c86:	9402                	jalr	s0
    9c88:	865a                	mv	a2,s6
    9c8a:	86a6                	mv	a3,s1
    9c8c:	85ca                	mv	a1,s2
    9c8e:	02000513          	li	a0,32
    9c92:	0b05                	addi	s6,s6,1
    9c94:	9402                	jalr	s0
    9c96:	865a                	mv	a2,s6
    9c98:	86a6                	mv	a3,s1
    9c9a:	85ca                	mv	a1,s2
    9c9c:	02000513          	li	a0,32
    9ca0:	0b05                	addi	s6,s6,1
    9ca2:	9402                	jalr	s0
    9ca4:	865a                	mv	a2,s6
    9ca6:	86a6                	mv	a3,s1
    9ca8:	85ca                	mv	a1,s2
    9caa:	02000513          	li	a0,32
    9cae:	9402                	jalr	s0
    9cb0:	6c82                	ld	s9,0(sp)
    9cb2:	0b05                	addi	s6,s6,1
    9cb4:	7d9b0263          	beq	s6,s9,a478 <_vsnprintf+0x18d8>
    9cb8:	865a                	mv	a2,s6
    9cba:	86a6                	mv	a3,s1
    9cbc:	85ca                	mv	a1,s2
    9cbe:	02000513          	li	a0,32
    9cc2:	9402                	jalr	s0
    9cc4:	001b0c13          	addi	s8,s6,1
    9cc8:	8662                	mv	a2,s8
    9cca:	86a6                	mv	a3,s1
    9ccc:	85ca                	mv	a1,s2
    9cce:	02000513          	li	a0,32
    9cd2:	9402                	jalr	s0
    9cd4:	002b0b93          	addi	s7,s6,2
    9cd8:	865e                	mv	a2,s7
    9cda:	86a6                	mv	a3,s1
    9cdc:	85ca                	mv	a1,s2
    9cde:	02000513          	li	a0,32
    9ce2:	9402                	jalr	s0
    9ce4:	003b0a93          	addi	s5,s6,3
    9ce8:	86a6                	mv	a3,s1
    9cea:	8656                	mv	a2,s5
    9cec:	85ca                	mv	a1,s2
    9cee:	02000513          	li	a0,32
    9cf2:	9402                	jalr	s0
    9cf4:	004b0d13          	addi	s10,s6,4
    9cf8:	86a6                	mv	a3,s1
    9cfa:	866a                	mv	a2,s10
    9cfc:	85ca                	mv	a1,s2
    9cfe:	02000513          	li	a0,32
    9d02:	9402                	jalr	s0
    9d04:	005b0c93          	addi	s9,s6,5
    9d08:	8666                	mv	a2,s9
    9d0a:	86a6                	mv	a3,s1
    9d0c:	85ca                	mv	a1,s2
    9d0e:	02000513          	li	a0,32
    9d12:	9402                	jalr	s0
    9d14:	006b0c13          	addi	s8,s6,6
    9d18:	86a6                	mv	a3,s1
    9d1a:	8662                	mv	a2,s8
    9d1c:	85ca                	mv	a1,s2
    9d1e:	02000513          	li	a0,32
    9d22:	9402                	jalr	s0
    9d24:	007b0b93          	addi	s7,s6,7
    9d28:	86a6                	mv	a3,s1
    9d2a:	865e                	mv	a2,s7
    9d2c:	85ca                	mv	a1,s2
    9d2e:	02000513          	li	a0,32
    9d32:	9402                	jalr	s0
    9d34:	6c82                	ld	s9,0(sp)
    9d36:	0b21                	addi	s6,s6,8
    9d38:	f99b10e3          	bne	s6,s9,9cb8 <_vsnprintf+0x1118>
    9d3c:	af35                	j	a478 <_vsnprintf+0x18d8>
    9d3e:	0001                	nop
    9d40:	6602                	ld	a2,0(sp)
    9d42:	86a6                	mv	a3,s1
    9d44:	85ca                	mv	a1,s2
    9d46:	02500513          	li	a0,37
    9d4a:	00160b13          	addi	s6,a2,1
    9d4e:	9402                	jalr	s0
    9d50:	6722                	ld	a4,8(sp)
    9d52:	e05a                	sd	s6,0(sp)
    9d54:	00170c93          	addi	s9,a4,1
    9d58:	ea9fe06f          	j	8c00 <_vsnprintf+0x60>
    9d5c:	06f00313          	li	t1,111
    9d60:	06650a63          	beq	a0,t1,9dd4 <_vsnprintf+0x1234>
    9d64:	00a36463          	bltu	t1,a0,9d6c <_vsnprintf+0x11cc>
    9d68:	5c90106f          	j	bb30 <_vsnprintf+0x2f90>
    9d6c:	07800393          	li	t2,120
    9d70:	00751463          	bne	a0,t2,9d78 <_vsnprintf+0x11d8>
    9d74:	2a80106f          	j	b01c <_vsnprintf+0x247c>
    9d78:	fefb7513          	andi	a0,s6,-17
    9d7c:	47a9                	li	a5,10
    9d7e:	00050b1b          	sext.w	s6,a0
    9d82:	86be                	mv	a3,a5
    9d84:	a891                	j	9dd8 <_vsnprintf+0x1238>
    9d86:	588dc50b          	th.lwia	a0,(s11),8,0
    9d8a:	6e22                	ld	t3,8(sp)
    9d8c:	00052c13          	slti	s8,a0,0
    9d90:	4380150b          	th.mvnez	a0,zero,s8
    9d94:	002e0e93          	addi	t4,t3,2
    9d98:	00050c1b          	sext.w	s8,a0
    9d9c:	e476                	sd	t4,8(sp)
    9d9e:	002e4503          	lbu	a0,2(t3)
    9da2:	eb7fe06f          	j	8c58 <_vsnprintf+0xb8>
    9da6:	fefb7893          	andi	a7,s6,-17
    9daa:	0218e593          	ori	a1,a7,33
    9dae:	400b7c93          	andi	s9,s6,1024
    9db2:	855a                	mv	a0,s6
    9db4:	2581                	sext.w	a1,a1
    9db6:	480c93e3          	bnez	s9,aa3c <_vsnprintf+0x1e9c>
    9dba:	4b81                	li	s7,0
    9dbc:	4281                	li	t0,0
    9dbe:	88cff06f          	j	8e4a <_vsnprintf+0x2aa>
    9dc2:	6e05                	lui	t3,0x1
    9dc4:	800e0613          	addi	a2,t3,-2048 # 800 <cmp_complex+0xc0>
    9dc8:	00cb6cb3          	or	s9,s6,a2
    9dcc:	000c8b1b          	sext.w	s6,s9
    9dd0:	f28ff06f          	j	94f8 <_vsnprintf+0x958>
    9dd4:	47a1                	li	a5,8
    9dd6:	86be                	mv	a3,a5
    9dd8:	ff2b7813          	andi	a6,s6,-14
    9ddc:	400b7b93          	andi	s7,s6,1024
    9de0:	ff3b7b13          	andi	s6,s6,-13
    9de4:	00080c9b          	sext.w	s9,a6
    9de8:	000b061b          	sext.w	a2,s6
    9dec:	437c960b          	th.mvnez	a2,s9,s7
    9df0:	20067813          	andi	a6,a2,512
    9df4:	8fb2                	mv	t6,a2
    9df6:	00080463          	beqz	a6,9dfe <_vsnprintf+0x125e>
    9dfa:	6b80106f          	j	b4b2 <_vsnprintf+0x2912>
    9dfe:	10067d13          	andi	s10,a2,256
    9e02:	000d0463          	beqz	s10,9e0a <_vsnprintf+0x126a>
    9e06:	15b0206f          	j	c760 <_vsnprintf+0x3bc0>
    9e0a:	04067293          	andi	t0,a2,64
    9e0e:	00029463          	bnez	t0,9e16 <_vsnprintf+0x1276>
    9e12:	2560106f          	j	b068 <_vsnprintf+0x24c8>
    9e16:	988dce8b          	th.lbuia	t4,(s11),8,0
    9e1a:	7c0eb70b          	th.extu	a4,t4,31,0
    9e1e:	e319                	bnez	a4,9e24 <_vsnprintf+0x1284>
    9e20:	1310206f          	j	c750 <_vsnprintf+0x3bb0>
    9e24:	01067e93          	andi	t4,a2,16
    9e28:	8e32                	mv	t3,a2
    9e2a:	02f75333          	divu	t1,a4,a5
    9e2e:	853a                	mv	a0,a4
    9e30:	145e358b          	th.extu	a1,t3,5,5
    9e34:	fff58a93          	addi	s5,a1,-1
    9e38:	020af393          	andi	t2,s5,32
    9e3c:	03738b1b          	addiw	s6,t2,55
    9e40:	4ca5                	li	s9,9
    9e42:	03010813          	addi	a6,sp,48
    9e46:	8642                	mv	a2,a6
    9e48:	22f3150b          	th.muls	a0,t1,a5
    9e4c:	0ff57f93          	zext.b	t6,a0
    9e50:	030f829b          	addiw	t0,t6,48
    9e54:	01fb05bb          	addw	a1,s6,t6
    9e58:	0ff2ff13          	zext.b	t5,t0
    9e5c:	0ff5fa93          	zext.b	s5,a1
    9e60:	00acb3b3          	sltu	t2,s9,a0
    9e64:	407f1a8b          	th.mveqz	s5,t5,t2
    9e68:	03510823          	sb	s5,48(sp)
    9e6c:	00f77463          	bgeu	a4,a5,9e74 <_vsnprintf+0x12d4>
    9e70:	7ac0106f          	j	b61c <_vsnprintf+0x2a7c>
    9e74:	03110613          	addi	a2,sp,49
    9e78:	829a                	mv	t0,t1
    9e7a:	0001                	nop
    9e7c:	00000013          	nop
    9e80:	02f2d333          	divu	t1,t0,a5
    9e84:	8516                	mv	a0,t0
    9e86:	22f3150b          	th.muls	a0,t1,a5
    9e8a:	0ff57713          	zext.b	a4,a0
    9e8e:	03070f9b          	addiw	t6,a4,48
    9e92:	00eb0f3b          	addw	t5,s6,a4
    9e96:	0ffff593          	zext.b	a1,t6
    9e9a:	0fff7a93          	zext.b	s5,t5
    9e9e:	00acb3b3          	sltu	t2,s9,a0
    9ea2:	40759a8b          	th.mveqz	s5,a1,t2
    9ea6:	01560023          	sb	s5,0(a2)
    9eaa:	00f2f463          	bgeu	t0,a5,9eb2 <_vsnprintf+0x1312>
    9eae:	76e0106f          	j	b61c <_vsnprintf+0x2a7c>
    9eb2:	00160513          	addi	a0,a2,1
    9eb6:	05010293          	addi	t0,sp,80
    9eba:	00a29463          	bne	t0,a0,9ec2 <_vsnprintf+0x1322>
    9ebe:	75e0106f          	j	b61c <_vsnprintf+0x2a7c>
    9ec2:	02f35fb3          	divu	t6,t1,a5
    9ec6:	859a                	mv	a1,t1
    9ec8:	862a                	mv	a2,a0
    9eca:	22ff958b          	th.muls	a1,t6,a5
    9ece:	0ff5f713          	zext.b	a4,a1
    9ed2:	03070f1b          	addiw	t5,a4,48
    9ed6:	00eb03bb          	addw	t2,s6,a4
    9eda:	0fff7a93          	zext.b	s5,t5
    9ede:	0ff3f713          	zext.b	a4,t2
    9ee2:	00bcb2b3          	sltu	t0,s9,a1
    9ee6:	405a970b          	th.mveqz	a4,s5,t0
    9eea:	00e50023          	sb	a4,0(a0)
    9eee:	00f37463          	bgeu	t1,a5,9ef6 <_vsnprintf+0x1356>
    9ef2:	72a0106f          	j	b61c <_vsnprintf+0x2a7c>
    9ef6:	02ffd333          	divu	t1,t6,a5
    9efa:	85fe                	mv	a1,t6
    9efc:	22f3158b          	th.muls	a1,t1,a5
    9f00:	0ff5ff13          	zext.b	t5,a1
    9f04:	030f0a9b          	addiw	s5,t5,48
    9f08:	01eb073b          	addw	a4,s6,t5
    9f0c:	0ffaf393          	zext.b	t2,s5
    9f10:	0ff77f13          	zext.b	t5,a4
    9f14:	00bcb2b3          	sltu	t0,s9,a1
    9f18:	40539f0b          	th.mveqz	t5,t2,t0
    9f1c:	08165f0b          	th.sbib	t5,(a2),1,0
    9f20:	00fff463          	bgeu	t6,a5,9f28 <_vsnprintf+0x1388>
    9f24:	6f80106f          	j	b61c <_vsnprintf+0x2a7c>
    9f28:	02f35fb3          	divu	t6,t1,a5
    9f2c:	859a                	mv	a1,t1
    9f2e:	00250613          	addi	a2,a0,2
    9f32:	22ff958b          	th.muls	a1,t6,a5
    9f36:	0ff5fa93          	zext.b	s5,a1
    9f3a:	030a839b          	addiw	t2,s5,48
    9f3e:	015b073b          	addw	a4,s6,s5
    9f42:	0ff3ff13          	zext.b	t5,t2
    9f46:	0ff77a93          	zext.b	s5,a4
    9f4a:	00bcb2b3          	sltu	t0,s9,a1
    9f4e:	405f1a8b          	th.mveqz	s5,t5,t0
    9f52:	01550123          	sb	s5,2(a0)
    9f56:	00f37463          	bgeu	t1,a5,9f5e <_vsnprintf+0x13be>
    9f5a:	6c20106f          	j	b61c <_vsnprintf+0x2a7c>
    9f5e:	02ffd2b3          	divu	t0,t6,a5
    9f62:	837e                	mv	t1,t6
    9f64:	00350613          	addi	a2,a0,3
    9f68:	22f2930b          	th.muls	t1,t0,a5
    9f6c:	0ff37593          	zext.b	a1,t1
    9f70:	0305839b          	addiw	t2,a1,48
    9f74:	00bb073b          	addw	a4,s6,a1
    9f78:	0ff3ff13          	zext.b	t5,t2
    9f7c:	0ff77a93          	zext.b	s5,a4
    9f80:	006cb333          	sltu	t1,s9,t1
    9f84:	406f1a8b          	th.mveqz	s5,t5,t1
    9f88:	015501a3          	sb	s5,3(a0)
    9f8c:	00fff463          	bgeu	t6,a5,9f94 <_vsnprintf+0x13f4>
    9f90:	68c0106f          	j	b61c <_vsnprintf+0x2a7c>
    9f94:	00450613          	addi	a2,a0,4
    9f98:	b5e5                	j	9e80 <_vsnprintf+0x12e0>
    9f9a:	05800613          	li	a2,88
    9f9e:	76c50f63          	beq	a0,a2,a71c <_vsnprintf+0x1b7c>
    9fa2:	4789                	li	a5,2
    9fa4:	06200313          	li	t1,98
    9fa8:	86be                	mv	a3,a5
    9faa:	e26507e3          	beq	a0,t1,9dd8 <_vsnprintf+0x1238>
    9fae:	400b7693          	andi	a3,s6,1024
    9fb2:	2a069ee3          	bnez	a3,aa6e <_vsnprintf+0x1ece>
    9fb6:	fefb7793          	andi	a5,s6,-17
    9fba:	200b7393          	andi	t2,s6,512
    9fbe:	0007859b          	sext.w	a1,a5
    9fc2:	00038463          	beqz	t2,9fca <_vsnprintf+0x142a>
    9fc6:	0fe0206f          	j	c0c4 <_vsnprintf+0x3524>
    9fca:	100b7e93          	andi	t4,s6,256
    9fce:	2c0e81e3          	beqz	t4,aa90 <_vsnprintf+0x1ef0>
    9fd2:	886e                	mv	a6,s11
    9fd4:	78884e0b          	th.ldia	t3,(a6),8,0
    9fd8:	4501                	li	a0,0
    9fda:	000e0863          	beqz	t3,9fea <_vsnprintf+0x144a>
    9fde:	43fe5d93          	srai	s11,t3,0x3f
    9fe2:	01cdc6b3          	xor	a3,s11,t3
    9fe6:	41b68533          	sub	a0,a3,s11
    9fea:	42a9                	li	t0,10
    9fec:	025573b3          	remu	t2,a0,t0
    9ff0:	03010313          	addi	t1,sp,48
    9ff4:	4ca5                	li	s9,9
    9ff6:	879a                	mv	a5,t1
    9ff8:	03038f1b          	addiw	t5,t2,48
    9ffc:	03e10823          	sb	t5,48(sp)
    a000:	02555733          	divu	a4,a0,t0
    a004:	10acf963          	bgeu	s9,a0,a116 <_vsnprintf+0x1576>
    a008:	03110793          	addi	a5,sp,49
    a00c:	02577fb3          	remu	t6,a4,t0
    a010:	030f8e9b          	addiw	t4,t6,48
    a014:	01d78023          	sb	t4,0(a5)
    a018:	02575d33          	divu	s10,a4,t0
    a01c:	0eecfd63          	bgeu	s9,a4,a116 <_vsnprintf+0x1576>
    a020:	00178b93          	addi	s7,a5,1
    a024:	05010b13          	addi	s6,sp,80
    a028:	0f7b0763          	beq	s6,s7,a116 <_vsnprintf+0x1576>
    a02c:	87de                	mv	a5,s7
    a02e:	025d7ab3          	remu	s5,s10,t0
    a032:	030a861b          	addiw	a2,s5,48
    a036:	00cb8023          	sb	a2,0(s7)
    a03a:	025d5733          	divu	a4,s10,t0
    a03e:	0dacfc63          	bgeu	s9,s10,a116 <_vsnprintf+0x1576>
    a042:	02577fb3          	remu	t6,a4,t0
    a046:	030f8d9b          	addiw	s11,t6,48
    a04a:	0817dd8b          	th.sbib	s11,(a5),1,0
    a04e:	025756b3          	divu	a3,a4,t0
    a052:	0cecf263          	bgeu	s9,a4,a116 <_vsnprintf+0x1576>
    a056:	002b8793          	addi	a5,s7,2
    a05a:	0256f533          	remu	a0,a3,t0
    a05e:	0305039b          	addiw	t2,a0,48
    a062:	007b8123          	sb	t2,2(s7)
    a066:	0256df33          	divu	t5,a3,t0
    a06a:	0adcf663          	bgeu	s9,a3,a116 <_vsnprintf+0x1576>
    a06e:	003b8793          	addi	a5,s7,3
    a072:	025f7eb3          	remu	t4,t5,t0
    a076:	030e8d1b          	addiw	s10,t4,48
    a07a:	01ab81a3          	sb	s10,3(s7)
    a07e:	025f5b33          	divu	s6,t5,t0
    a082:	09ecfa63          	bgeu	s9,t5,a116 <_vsnprintf+0x1576>
    a086:	004b8793          	addi	a5,s7,4
    a08a:	025b7ab3          	remu	s5,s6,t0
    a08e:	030a861b          	addiw	a2,s5,48
    a092:	00cb8223          	sb	a2,4(s7)
    a096:	025b5733          	divu	a4,s6,t0
    a09a:	076cfe63          	bgeu	s9,s6,a116 <_vsnprintf+0x1576>
    a09e:	005b8793          	addi	a5,s7,5
    a0a2:	02577fb3          	remu	t6,a4,t0
    a0a6:	030f8d9b          	addiw	s11,t6,48
    a0aa:	01bb82a3          	sb	s11,5(s7)
    a0ae:	025756b3          	divu	a3,a4,t0
    a0b2:	06ecf263          	bgeu	s9,a4,a116 <_vsnprintf+0x1576>
    a0b6:	006b8793          	addi	a5,s7,6
    a0ba:	0256f533          	remu	a0,a3,t0
    a0be:	0305039b          	addiw	t2,a0,48
    a0c2:	007b8323          	sb	t2,6(s7)
    a0c6:	0256deb3          	divu	t4,a3,t0
    a0ca:	04dcf663          	bgeu	s9,a3,a116 <_vsnprintf+0x1576>
    a0ce:	007b8793          	addi	a5,s7,7
    a0d2:	025eff33          	remu	t5,t4,t0
    a0d6:	030f0d1b          	addiw	s10,t5,48
    a0da:	01ab83a3          	sb	s10,7(s7)
    a0de:	025edb33          	divu	s6,t4,t0
    a0e2:	03dcfa63          	bgeu	s9,t4,a116 <_vsnprintf+0x1576>
    a0e6:	008b8793          	addi	a5,s7,8
    a0ea:	025b7ab3          	remu	s5,s6,t0
    a0ee:	030a861b          	addiw	a2,s5,48
    a0f2:	00cb8423          	sb	a2,8(s7)
    a0f6:	025b5733          	divu	a4,s6,t0
    a0fa:	016cfe63          	bgeu	s9,s6,a116 <_vsnprintf+0x1576>
    a0fe:	009b8793          	addi	a5,s7,9
    a102:	02577fb3          	remu	t6,a4,t0
    a106:	030f8e9b          	addiw	t4,t6,48
    a10a:	01d78023          	sb	t4,0(a5)
    a10e:	02575d33          	divu	s10,a4,t0
    a112:	f0ece7e3          	bltu	s9,a4,a020 <_vsnprintf+0x1480>
    a116:	406787b3          	sub	a5,a5,t1
    a11a:	0025fb13          	andi	s6,a1,2
    a11e:	0785                	addi	a5,a5,1
    a120:	82ae                	mv	t0,a1
    a122:	000b1463          	bnez	s6,a12a <_vsnprintf+0x158a>
    a126:	4200306f          	j	d546 <_vsnprintf+0x49a6>
    a12a:	02000c13          	li	s8,32
    a12e:	4b09                	li	s6,2
    a130:	01878463          	beq	a5,s8,a138 <_vsnprintf+0x1598>
    a134:	6190306f          	j	df4c <_vsnprintf+0x53ac>
    a138:	04f14503          	lbu	a0,79(sp)
    a13c:	6382                	ld	t2,0(sp)
    a13e:	8dc2                	mv	s11,a6
    a140:	02000d13          	li	s10,32
    a144:	01a30c33          	add	s8,t1,s10
    a148:	fff34813          	not	a6,t1
    a14c:	018802b3          	add	t0,a6,s8
    a150:	01a38cb3          	add	s9,t2,s10
    a154:	0072fd13          	andi	s10,t0,7
    a158:	01930bb3          	add	s7,t1,s9
    a15c:	000d1463          	bnez	s10,a164 <_vsnprintf+0x15c4>
    a160:	5910306f          	j	def0 <_vsnprintf+0x5350>
    a164:	418b8633          	sub	a2,s7,s8
    a168:	ec46                	sd	a7,24(sp)
    a16a:	f01a                	sd	t1,32(sp)
    a16c:	86a6                	mv	a3,s1
    a16e:	85ca                	mv	a1,s2
    a170:	9402                	jalr	s0
    a172:	4f85                	li	t6,1
    a174:	68e2                	ld	a7,24(sp)
    a176:	7302                	ld	t1,32(sp)
    a178:	1c7d                	addi	s8,s8,-1
    a17a:	fffc4503          	lbu	a0,-1(s8)
    a17e:	01fd1463          	bne	s10,t6,a186 <_vsnprintf+0x15e6>
    a182:	56f0306f          	j	def0 <_vsnprintf+0x5350>
    a186:	4389                	li	t2,2
    a188:	087d0863          	beq	s10,t2,a218 <_vsnprintf+0x1678>
    a18c:	470d                	li	a4,3
    a18e:	06ed0963          	beq	s10,a4,a200 <_vsnprintf+0x1660>
    a192:	4a91                	li	s5,4
    a194:	055d0a63          	beq	s10,s5,a1e8 <_vsnprintf+0x1648>
    a198:	4e95                	li	t4,5
    a19a:	03dd0b63          	beq	s10,t4,a1d0 <_vsnprintf+0x1630>
    a19e:	4f19                	li	t5,6
    a1a0:	01ed0c63          	beq	s10,t5,a1b8 <_vsnprintf+0x1618>
    a1a4:	418b8633          	sub	a2,s7,s8
    a1a8:	86a6                	mv	a3,s1
    a1aa:	85ca                	mv	a1,s2
    a1ac:	9402                	jalr	s0
    a1ae:	68e2                	ld	a7,24(sp)
    a1b0:	7302                	ld	t1,32(sp)
    a1b2:	ffec4503          	lbu	a0,-2(s8)
    a1b6:	1c7d                	addi	s8,s8,-1
    a1b8:	ec46                	sd	a7,24(sp)
    a1ba:	f01a                	sd	t1,32(sp)
    a1bc:	418b8633          	sub	a2,s7,s8
    a1c0:	86a6                	mv	a3,s1
    a1c2:	85ca                	mv	a1,s2
    a1c4:	9402                	jalr	s0
    a1c6:	68e2                	ld	a7,24(sp)
    a1c8:	7302                	ld	t1,32(sp)
    a1ca:	ffec4503          	lbu	a0,-2(s8)
    a1ce:	1c7d                	addi	s8,s8,-1
    a1d0:	ec46                	sd	a7,24(sp)
    a1d2:	f01a                	sd	t1,32(sp)
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
    a218:	418b8633          	sub	a2,s7,s8
    a21c:	ec46                	sd	a7,24(sp)
    a21e:	f01a                	sd	t1,32(sp)
    a220:	86a6                	mv	a3,s1
    a222:	85ca                	mv	a1,s2
    a224:	9402                	jalr	s0
    a226:	1c7d                	addi	s8,s8,-1
    a228:	6d62                	ld	s10,24(sp)
    a22a:	7a82                	ld	s5,32(sp)
    a22c:	fffc4503          	lbu	a0,-1(s8)
    a230:	a071                	j	a2bc <_vsnprintf+0x171c>
    a232:	87e2                	mv	a5,s8
    a234:	40ab8633          	sub	a2,s7,a0
    a238:	89e7c50b          	th.lbuib	a0,(a5),-2,0
    a23c:	86a6                	mv	a3,s1
    a23e:	85ca                	mv	a1,s2
    a240:	ec3e                	sd	a5,24(sp)
    a242:	9402                	jalr	s0
    a244:	8e62                	mv	t3,s8
    a246:	89de450b          	th.lbuib	a0,(t3),-3,0
    a24a:	6662                	ld	a2,24(sp)
    a24c:	86a6                	mv	a3,s1
    a24e:	ec72                	sd	t3,24(sp)
    a250:	85ca                	mv	a1,s2
    a252:	40cb8633          	sub	a2,s7,a2
    a256:	9402                	jalr	s0
    a258:	8862                	mv	a6,s8
    a25a:	89c8450b          	th.lbuib	a0,(a6),-4,0
    a25e:	62e2                	ld	t0,24(sp)
    a260:	86a6                	mv	a3,s1
    a262:	ec42                	sd	a6,24(sp)
    a264:	405b8633          	sub	a2,s7,t0
    a268:	85ca                	mv	a1,s2
    a26a:	9402                	jalr	s0
    a26c:	8fe2                	mv	t6,s8
    a26e:	89bfc50b          	th.lbuib	a0,(t6),-5,0
    a272:	63e2                	ld	t2,24(sp)
    a274:	86a6                	mv	a3,s1
    a276:	ec7e                	sd	t6,24(sp)
    a278:	407b8633          	sub	a2,s7,t2
    a27c:	85ca                	mv	a1,s2
    a27e:	9402                	jalr	s0
    a280:	8762                	mv	a4,s8
    a282:	89a7450b          	th.lbuib	a0,(a4),-6,0
    a286:	6ee2                	ld	t4,24(sp)
    a288:	86a6                	mv	a3,s1
    a28a:	ec3a                	sd	a4,24(sp)
    a28c:	41db8633          	sub	a2,s7,t4
    a290:	85ca                	mv	a1,s2
    a292:	9402                	jalr	s0
    a294:	8f62                	mv	t5,s8
    a296:	899f450b          	th.lbuib	a0,(t5),-7,0
    a29a:	6362                	ld	t1,24(sp)
    a29c:	86a6                	mv	a3,s1
    a29e:	85ca                	mv	a1,s2
    a2a0:	406b8633          	sub	a2,s7,t1
    a2a4:	ec7a                	sd	t5,24(sp)
    a2a6:	9402                	jalr	s0
    a2a8:	68e2                	ld	a7,24(sp)
    a2aa:	898c450b          	th.lbuib	a0,(s8),-8,0
    a2ae:	86a6                	mv	a3,s1
    a2b0:	85ca                	mv	a1,s2
    a2b2:	411b8633          	sub	a2,s7,a7
    a2b6:	9402                	jalr	s0
    a2b8:	fffc4503          	lbu	a0,-1(s8)
    a2bc:	86a6                	mv	a3,s1
    a2be:	418b8633          	sub	a2,s7,s8
    a2c2:	85ca                	mv	a1,s2
    a2c4:	ec66                	sd	s9,24(sp)
    a2c6:	9402                	jalr	s0
    a2c8:	fffc0513          	addi	a0,s8,-1
    a2cc:	6e62                	ld	t3,24(sp)
    a2ce:	f6aa92e3          	bne	s5,a0,a232 <_vsnprintf+0x1692>
    a2d2:	88ea                	mv	a7,s10
    a2d4:	180b0463          	beqz	s6,a45c <_vsnprintf+0x18bc>
    a2d8:	6b02                	ld	s6,0(sp)
    a2da:	7c08bb8b          	th.extu	s7,a7,31,0
    a2de:	416e0cb3          	sub	s9,t3,s6
    a2e2:	177cfd63          	bgeu	s9,s7,a45c <_vsnprintf+0x18bc>
    a2e6:	fffcc793          	not	a5,s9
    a2ea:	01778633          	add	a2,a5,s7
    a2ee:	00767d13          	andi	s10,a2,7
    a2f2:	8672                	mv	a2,t3
    a2f4:	0e05                	addi	t3,t3,1
    a2f6:	e072                	sd	t3,0(sp)
    a2f8:	86a6                	mv	a3,s1
    a2fa:	85ca                	mv	a1,s2
    a2fc:	02000513          	li	a0,32
    a300:	9402                	jalr	s0
    a302:	001c8c13          	addi	s8,s9,1
    a306:	6e02                	ld	t3,0(sp)
    a308:	157c7a63          	bgeu	s8,s7,a45c <_vsnprintf+0x18bc>
    a30c:	0c0d0463          	beqz	s10,a3d4 <_vsnprintf+0x1834>
    a310:	4585                	li	a1,1
    a312:	0abd0463          	beq	s10,a1,a3ba <_vsnprintf+0x181a>
    a316:	4689                	li	a3,2
    a318:	08dd0663          	beq	s10,a3,a3a4 <_vsnprintf+0x1804>
    a31c:	480d                	li	a6,3
    a31e:	070d0863          	beq	s10,a6,a38e <_vsnprintf+0x17ee>
    a322:	4291                	li	t0,4
    a324:	045d0a63          	beq	s10,t0,a378 <_vsnprintf+0x17d8>
    a328:	4f95                	li	t6,5
    a32a:	03fd0c63          	beq	s10,t6,a362 <_vsnprintf+0x17c2>
    a32e:	4399                	li	t2,6
    a330:	007d0e63          	beq	s10,t2,a34c <_vsnprintf+0x17ac>
    a334:	001e0713          	addi	a4,t3,1
    a338:	8672                	mv	a2,t3
    a33a:	86a6                	mv	a3,s1
    a33c:	85ca                	mv	a1,s2
    a33e:	02000513          	li	a0,32
    a342:	e03a                	sd	a4,0(sp)
    a344:	9402                	jalr	s0
    a346:	6e02                	ld	t3,0(sp)
    a348:	002c8c13          	addi	s8,s9,2
    a34c:	001e0e93          	addi	t4,t3,1
    a350:	8672                	mv	a2,t3
    a352:	86a6                	mv	a3,s1
    a354:	85ca                	mv	a1,s2
    a356:	02000513          	li	a0,32
    a35a:	e076                	sd	t4,0(sp)
    a35c:	9402                	jalr	s0
    a35e:	6e02                	ld	t3,0(sp)
    a360:	0c05                	addi	s8,s8,1
    a362:	001e0f13          	addi	t5,t3,1
    a366:	8672                	mv	a2,t3
    a368:	86a6                	mv	a3,s1
    a36a:	85ca                	mv	a1,s2
    a36c:	02000513          	li	a0,32
    a370:	e07a                	sd	t5,0(sp)
    a372:	9402                	jalr	s0
    a374:	6e02                	ld	t3,0(sp)
    a376:	0c05                	addi	s8,s8,1
    a378:	001e0313          	addi	t1,t3,1
    a37c:	8672                	mv	a2,t3
    a37e:	86a6                	mv	a3,s1
    a380:	85ca                	mv	a1,s2
    a382:	02000513          	li	a0,32
    a386:	e01a                	sd	t1,0(sp)
    a388:	9402                	jalr	s0
    a38a:	6e02                	ld	t3,0(sp)
    a38c:	0c05                	addi	s8,s8,1
    a38e:	001e0a93          	addi	s5,t3,1
    a392:	8672                	mv	a2,t3
    a394:	86a6                	mv	a3,s1
    a396:	85ca                	mv	a1,s2
    a398:	02000513          	li	a0,32
    a39c:	e056                	sd	s5,0(sp)
    a39e:	9402                	jalr	s0
    a3a0:	6e02                	ld	t3,0(sp)
    a3a2:	0c05                	addi	s8,s8,1
    a3a4:	001e0893          	addi	a7,t3,1
    a3a8:	8672                	mv	a2,t3
    a3aa:	86a6                	mv	a3,s1
    a3ac:	85ca                	mv	a1,s2
    a3ae:	02000513          	li	a0,32
    a3b2:	e046                	sd	a7,0(sp)
    a3b4:	9402                	jalr	s0
    a3b6:	6e02                	ld	t3,0(sp)
    a3b8:	0c05                	addi	s8,s8,1
    a3ba:	001e0b13          	addi	s6,t3,1
    a3be:	8672                	mv	a2,t3
    a3c0:	86a6                	mv	a3,s1
    a3c2:	85ca                	mv	a1,s2
    a3c4:	02000513          	li	a0,32
    a3c8:	e05a                	sd	s6,0(sp)
    a3ca:	9402                	jalr	s0
    a3cc:	0c05                	addi	s8,s8,1
    a3ce:	6e02                	ld	t3,0(sp)
    a3d0:	097c7663          	bgeu	s8,s7,a45c <_vsnprintf+0x18bc>
    a3d4:	8af2                	mv	s5,t3
    a3d6:	8656                	mv	a2,s5
    a3d8:	86a6                	mv	a3,s1
    a3da:	85ca                	mv	a1,s2
    a3dc:	02000513          	li	a0,32
    a3e0:	9402                	jalr	s0
    a3e2:	001a8d13          	addi	s10,s5,1
    a3e6:	866a                	mv	a2,s10
    a3e8:	86a6                	mv	a3,s1
    a3ea:	85ca                	mv	a1,s2
    a3ec:	02000513          	li	a0,32
    a3f0:	9402                	jalr	s0
    a3f2:	002a8c93          	addi	s9,s5,2
    a3f6:	8666                	mv	a2,s9
    a3f8:	86a6                	mv	a3,s1
    a3fa:	85ca                	mv	a1,s2
    a3fc:	02000513          	li	a0,32
    a400:	9402                	jalr	s0
    a402:	003a8b13          	addi	s6,s5,3
    a406:	865a                	mv	a2,s6
    a408:	86a6                	mv	a3,s1
    a40a:	85ca                	mv	a1,s2
    a40c:	02000513          	li	a0,32
    a410:	9402                	jalr	s0
    a412:	004a8d13          	addi	s10,s5,4
    a416:	866a                	mv	a2,s10
    a418:	86a6                	mv	a3,s1
    a41a:	85ca                	mv	a1,s2
    a41c:	02000513          	li	a0,32
    a420:	9402                	jalr	s0
    a422:	005a8b13          	addi	s6,s5,5
    a426:	86a6                	mv	a3,s1
    a428:	865a                	mv	a2,s6
    a42a:	85ca                	mv	a1,s2
    a42c:	02000513          	li	a0,32
    a430:	9402                	jalr	s0
    a432:	006a8c93          	addi	s9,s5,6
    a436:	86a6                	mv	a3,s1
    a438:	8666                	mv	a2,s9
    a43a:	85ca                	mv	a1,s2
    a43c:	02000513          	li	a0,32
    a440:	9402                	jalr	s0
    a442:	007a8d13          	addi	s10,s5,7
    a446:	86a6                	mv	a3,s1
    a448:	866a                	mv	a2,s10
    a44a:	85ca                	mv	a1,s2
    a44c:	02000513          	li	a0,32
    a450:	0c21                	addi	s8,s8,8
    a452:	0aa1                	addi	s5,s5,8
    a454:	9402                	jalr	s0
    a456:	f97c60e3          	bltu	s8,s7,a3d6 <_vsnprintf+0x1836>
    a45a:	8e56                	mv	t3,s5
    a45c:	e072                	sd	t3,0(sp)
    a45e:	a829                	j	a478 <_vsnprintf+0x18d8>
    a460:	6602                	ld	a2,0(sp)
    a462:	988dc50b          	th.lbuia	a0,(s11),8,0
    a466:	86a6                	mv	a3,s1
    a468:	85ca                	mv	a1,s2
    a46a:	00160b13          	addi	s6,a2,1
    a46e:	9402                	jalr	s0
    a470:	e05a                	sd	s6,0(sp)
    a472:	0001                	nop
    a474:	00000013          	nop
    a478:	63a2                	ld	t2,8(sp)
    a47a:	00138c93          	addi	s9,t2,1
    a47e:	f82fe06f          	j	8c00 <_vsnprintf+0x60>
    a482:	88ea                	mv	a7,s10
    a484:	8d66                	mv	s10,s9
    a486:	e06a                	sd	s10,0(sp)
    a488:	fe0a88e3          	beqz	s5,a478 <_vsnprintf+0x18d8>
    a48c:	ea7fe06f          	j	9332 <_vsnprintf+0x792>
    a490:	0025f893          	andi	a7,a1,2
    a494:	852e                	mv	a0,a1
    a496:	56089d63          	bnez	a7,aa10 <_vsnprintf+0x1e70>
    a49a:	00c5fe13          	andi	t3,a1,12
    a49e:	3a0e1ae3          	bnez	t3,b052 <_vsnprintf+0x24b2>
    a4a2:	47c1                	li	a5,16
    a4a4:	8abe                	mv	s5,a5
    a4a6:	7c0c3f8b          	th.extu	t6,s8,31,0
    a4aa:	29fd62e3          	bltu	s10,t6,af2e <_vsnprintf+0x238e>
    a4ae:	00fd6463          	bltu	s10,a5,a4b6 <_vsnprintf+0x1916>
    a4b2:	3730206f          	j	d024 <_vsnprintf+0x4484>
    a4b6:	03000c13          	li	s8,48
    a4ba:	018103b3          	add	t2,sp,s8
    a4be:	007d0833          	add	a6,s10,t2
    a4c2:	001d0e13          	addi	t3,s10,1
    a4c6:	01880023          	sb	s8,0(a6)
    a4ca:	00fe6463          	bltu	t3,a5,a4d2 <_vsnprintf+0x1932>
    a4ce:	52d0306f          	j	e1fa <_vsnprintf+0x565a>
    a4d2:	9e0a                	add	t3,t3,sp
    a4d4:	03000313          	li	t1,48
    a4d8:	002d0e93          	addi	t4,s10,2
    a4dc:	026e0823          	sb	t1,48(t3)
    a4e0:	70fefae3          	bgeu	t4,a5,b3f4 <_vsnprintf+0x2854>
    a4e4:	00610533          	add	a0,sp,t1
    a4e8:	00ad0c33          	add	s8,s10,a0
    a4ec:	003d0f13          	addi	t5,s10,3
    a4f0:	006c0123          	sb	t1,2(s8)
    a4f4:	70ff70e3          	bgeu	t5,a5,b3f4 <_vsnprintf+0x2854>
    a4f8:	00ad0833          	add	a6,s10,a0
    a4fc:	004d0613          	addi	a2,s10,4
    a500:	006801a3          	sb	t1,3(a6)
    a504:	6ef678e3          	bgeu	a2,a5,b3f4 <_vsnprintf+0x2854>
    a508:	00ad0733          	add	a4,s10,a0
    a50c:	005d0293          	addi	t0,s10,5
    a510:	00670223          	sb	t1,4(a4)
    a514:	6ef2f0e3          	bgeu	t0,a5,b3f4 <_vsnprintf+0x2854>
    a518:	00ad0f33          	add	t5,s10,a0
    a51c:	006d0e13          	addi	t3,s10,6
    a520:	006f02a3          	sb	t1,5(t5)
    a524:	6cfe78e3          	bgeu	t3,a5,b3f4 <_vsnprintf+0x2854>
    a528:	00ad0633          	add	a2,s10,a0
    a52c:	007d0893          	addi	a7,s10,7
    a530:	00660323          	sb	t1,6(a2)
    a534:	6cf8f0e3          	bgeu	a7,a5,b3f4 <_vsnprintf+0x2854>
    a538:	00ad02b3          	add	t0,s10,a0
    a53c:	008d0393          	addi	t2,s10,8
    a540:	006283a3          	sb	t1,7(t0)
    a544:	6af3f8e3          	bgeu	t2,a5,b3f4 <_vsnprintf+0x2854>
    a548:	00ad0e33          	add	t3,s10,a0
    a54c:	009d0e93          	addi	t4,s10,9
    a550:	006e0423          	sb	t1,8(t3)
    a554:	6afef0e3          	bgeu	t4,a5,b3f4 <_vsnprintf+0x2854>
    a558:	00ad08b3          	add	a7,s10,a0
    a55c:	00ad0f13          	addi	t5,s10,10
    a560:	006884a3          	sb	t1,9(a7)
    a564:	68ff78e3          	bgeu	t5,a5,b3f4 <_vsnprintf+0x2854>
    a568:	00ad03b3          	add	t2,s10,a0
    a56c:	00bd0c13          	addi	s8,s10,11
    a570:	00638523          	sb	t1,10(t2)
    a574:	68fc70e3          	bgeu	s8,a5,b3f4 <_vsnprintf+0x2854>
    a578:	00ad0eb3          	add	t4,s10,a0
    a57c:	03000713          	li	a4,48
    a580:	00cd0313          	addi	t1,s10,12
    a584:	00ee85a3          	sb	a4,11(t4)
    a588:	66f376e3          	bgeu	t1,a5,b3f4 <_vsnprintf+0x2854>
    a58c:	00ad06b3          	add	a3,s10,a0
    a590:	00dd0e13          	addi	t3,s10,13
    a594:	00e68623          	sb	a4,12(a3)
    a598:	64fe7ee3          	bgeu	t3,a5,b3f4 <_vsnprintf+0x2854>
    a59c:	00ad0633          	add	a2,s10,a0
    a5a0:	00ed0893          	addi	a7,s10,14
    a5a4:	00e606a3          	sb	a4,13(a2)
    a5a8:	64f8f6e3          	bgeu	a7,a5,b3f4 <_vsnprintf+0x2854>
    a5ac:	00ad0333          	add	t1,s10,a0
    a5b0:	01a03d33          	snez	s10,s10
    a5b4:	00e30723          	sb	a4,14(t1)
    a5b8:	00fd0813          	addi	a6,s10,15
    a5bc:	62f87ce3          	bgeu	a6,a5,b3f4 <_vsnprintf+0x2854>
    a5c0:	02e10fa3          	sb	a4,63(sp)
    a5c4:	000b8463          	beqz	s7,a5cc <_vsnprintf+0x1a2c>
    a5c8:	3620106f          	j	b92a <_vsnprintf+0x2d8a>
    a5cc:	0045fe13          	andi	t3,a1,4
    a5d0:	000e0463          	beqz	t3,a5d8 <_vsnprintf+0x1a38>
    a5d4:	10e0306f          	j	d6e2 <_vsnprintf+0x4b42>
    a5d8:	0085fb93          	andi	s7,a1,8
    a5dc:	000b8463          	beqz	s7,a5e4 <_vsnprintf+0x1a44>
    a5e0:	1650306f          	j	df44 <_vsnprintf+0x53a4>
    a5e4:	4d41                	li	s10,16
    a5e6:	06010f93          	addi	t6,sp,96
    a5ea:	fdffc503          	lbu	a0,-33(t6)
    a5ee:	a47d                	j	a89c <_vsnprintf+0x1cfc>
    a5f0:	885a                	mv	a6,s6
    a5f2:	87c6                	mv	a5,a7
    a5f4:	8762                	mv	a4,s8
    a5f6:	6602                	ld	a2,0(sp)
    a5f8:	86a6                	mv	a3,s1
    a5fa:	85ca                	mv	a1,s2
    a5fc:	8522                	mv	a0,s0
    a5fe:	b13fc0ef          	jal	7110 <_ftoa>
    a602:	e02a                	sd	a0,0(sp)
    a604:	6622                	ld	a2,8(sp)
    a606:	8dde                	mv	s11,s7
    a608:	00160c93          	addi	s9,a2,1
    a60c:	df4fe06f          	j	8c00 <_vsnprintf+0x60>
    a610:	6505                	lui	a0,0x1
    a612:	80050813          	addi	a6,a0,-2048 # 800 <cmp_complex+0xc0>
    a616:	010b62b3          	or	t0,s6,a6
    a61a:	00028b1b          	sext.w	s6,t0
    a61e:	020b6313          	ori	t1,s6,32
    a622:	00030b1b          	sext.w	s6,t1
    a626:	ed3fe06f          	j	94f8 <_vsnprintf+0x958>
    a62a:	400b7793          	andi	a5,s6,1024
    a62e:	41ac8bbb          	subw	s7,s9,s10
    a632:	c399                	beqz	a5,a638 <_vsnprintf+0x1a98>
    a634:	b17fe06f          	j	914a <_vsnprintf+0x5aa>
    a638:	002b7b13          	andi	s6,s6,2
    a63c:	000b1463          	bnez	s6,a644 <_vsnprintf+0x1aa4>
    a640:	4b20106f          	j	baf2 <_vsnprintf+0x2f52>
    a644:	6c82                	ld	s9,0(sp)
    a646:	4a89                	li	s5,2
    a648:	8b66                	mv	s6,s9
    a64a:	419d0d33          	sub	s10,s10,s9
    a64e:	8cc6                	mv	s9,a7
    a650:	865a                	mv	a2,s6
    a652:	86a6                	mv	a3,s1
    a654:	85ca                	mv	a1,s2
    a656:	0b05                	addi	s6,s6,1
    a658:	9402                	jalr	s0
    a65a:	816d450b          	th.lrbu	a0,s10,s6,0
    a65e:	8c5a                	mv	s8,s6
    a660:	cd3d                	beqz	a0,a6de <_vsnprintf+0x1b3e>
    a662:	86a6                	mv	a3,s1
    a664:	8662                	mv	a2,s8
    a666:	85ca                	mv	a1,s2
    a668:	0b05                	addi	s6,s6,1
    a66a:	9402                	jalr	s0
    a66c:	816d450b          	th.lrbu	a0,s10,s6,0
    a670:	c53d                	beqz	a0,a6de <_vsnprintf+0x1b3e>
    a672:	865a                	mv	a2,s6
    a674:	86a6                	mv	a3,s1
    a676:	85ca                	mv	a1,s2
    a678:	002c0b13          	addi	s6,s8,2
    a67c:	9402                	jalr	s0
    a67e:	816d450b          	th.lrbu	a0,s10,s6,0
    a682:	cd31                	beqz	a0,a6de <_vsnprintf+0x1b3e>
    a684:	865a                	mv	a2,s6
    a686:	86a6                	mv	a3,s1
    a688:	85ca                	mv	a1,s2
    a68a:	003c0b13          	addi	s6,s8,3
    a68e:	9402                	jalr	s0
    a690:	816d450b          	th.lrbu	a0,s10,s6,0
    a694:	c529                	beqz	a0,a6de <_vsnprintf+0x1b3e>
    a696:	865a                	mv	a2,s6
    a698:	86a6                	mv	a3,s1
    a69a:	85ca                	mv	a1,s2
    a69c:	004c0b13          	addi	s6,s8,4
    a6a0:	9402                	jalr	s0
    a6a2:	816d450b          	th.lrbu	a0,s10,s6,0
    a6a6:	cd05                	beqz	a0,a6de <_vsnprintf+0x1b3e>
    a6a8:	865a                	mv	a2,s6
    a6aa:	86a6                	mv	a3,s1
    a6ac:	85ca                	mv	a1,s2
    a6ae:	005c0b13          	addi	s6,s8,5
    a6b2:	9402                	jalr	s0
    a6b4:	816d450b          	th.lrbu	a0,s10,s6,0
    a6b8:	c11d                	beqz	a0,a6de <_vsnprintf+0x1b3e>
    a6ba:	865a                	mv	a2,s6
    a6bc:	86a6                	mv	a3,s1
    a6be:	85ca                	mv	a1,s2
    a6c0:	006c0b13          	addi	s6,s8,6
    a6c4:	9402                	jalr	s0
    a6c6:	816d450b          	th.lrbu	a0,s10,s6,0
    a6ca:	c911                	beqz	a0,a6de <_vsnprintf+0x1b3e>
    a6cc:	865a                	mv	a2,s6
    a6ce:	86a6                	mv	a3,s1
    a6d0:	85ca                	mv	a1,s2
    a6d2:	007c0b13          	addi	s6,s8,7
    a6d6:	9402                	jalr	s0
    a6d8:	816d450b          	th.lrbu	a0,s10,s6,0
    a6dc:	f935                	bnez	a0,a650 <_vsnprintf+0x1ab0>
    a6de:	e05a                	sd	s6,0(sp)
    a6e0:	88e6                	mv	a7,s9
    a6e2:	d80a8be3          	beqz	s5,a478 <_vsnprintf+0x18d8>
    a6e6:	c4dfe06f          	j	9332 <_vsnprintf+0x792>
    a6ea:	0c0b6813          	ori	a6,s6,192
    a6ee:	00278f93          	addi	t6,a5,2
    a6f2:	0027c503          	lbu	a0,2(a5)
    a6f6:	00080b1b          	sext.w	s6,a6
    a6fa:	e47e                	sd	t6,8(sp)
    a6fc:	dc4fe06f          	j	8cc0 <_vsnprintf+0x120>
    a700:	300b6513          	ori	a0,s6,768
    a704:	002e0293          	addi	t0,t3,2
    a708:	00050b1b          	sext.w	s6,a0
    a70c:	e416                	sd	t0,8(sp)
    a70e:	002e4503          	lbu	a0,2(t3)
    a712:	daefe06f          	j	8cc0 <_vsnprintf+0x120>
    a716:	4981                	li	s3,0
    a718:	ec6fe06f          	j	8dde <_vsnprintf+0x23e>
    a71c:	020b6393          	ori	t2,s6,32
    a720:	47c1                	li	a5,16
    a722:	00038b1b          	sext.w	s6,t2
    a726:	86be                	mv	a3,a5
    a728:	eb0ff06f          	j	9dd8 <_vsnprintf+0x1238>
    a72c:	4385                	li	t2,1
    a72e:	d313f9e3          	bgeu	t2,a7,a460 <_vsnprintf+0x18c0>
    a732:	6302                	ld	t1,0(sp)
    a734:	ffe8869b          	addiw	a3,a7,-2
    a738:	7c06bb0b          	th.extu	s6,a3,31,0
    a73c:	00730833          	add	a6,t1,t2
    a740:	01680cb3          	add	s9,a6,s6
    a744:	406c8fb3          	sub	t6,s9,t1
    a748:	007ff293          	andi	t0,t6,7
    a74c:	8d1a                	mv	s10,t1
    a74e:	08028663          	beqz	t0,a7da <_vsnprintf+0x1c3a>
    a752:	06728b63          	beq	t0,t2,a7c8 <_vsnprintf+0x1c28>
    a756:	4509                	li	a0,2
    a758:	06a28163          	beq	t0,a0,a7ba <_vsnprintf+0x1c1a>
    a75c:	4e8d                	li	t4,3
    a75e:	05d28763          	beq	t0,t4,a7ac <_vsnprintf+0x1c0c>
    a762:	4e11                	li	t3,4
    a764:	03c28d63          	beq	t0,t3,a79e <_vsnprintf+0x1bfe>
    a768:	4f15                	li	t5,5
    a76a:	03e28363          	beq	t0,t5,a790 <_vsnprintf+0x1bf0>
    a76e:	4599                	li	a1,6
    a770:	00b28963          	beq	t0,a1,a782 <_vsnprintf+0x1be2>
    a774:	6602                	ld	a2,0(sp)
    a776:	86a6                	mv	a3,s1
    a778:	85ca                	mv	a1,s2
    a77a:	02000513          	li	a0,32
    a77e:	8d42                	mv	s10,a6
    a780:	9402                	jalr	s0
    a782:	866a                	mv	a2,s10
    a784:	86a6                	mv	a3,s1
    a786:	85ca                	mv	a1,s2
    a788:	02000513          	li	a0,32
    a78c:	0d05                	addi	s10,s10,1
    a78e:	9402                	jalr	s0
    a790:	866a                	mv	a2,s10
    a792:	86a6                	mv	a3,s1
    a794:	85ca                	mv	a1,s2
    a796:	02000513          	li	a0,32
    a79a:	0d05                	addi	s10,s10,1
    a79c:	9402                	jalr	s0
    a79e:	866a                	mv	a2,s10
    a7a0:	86a6                	mv	a3,s1
    a7a2:	85ca                	mv	a1,s2
    a7a4:	02000513          	li	a0,32
    a7a8:	0d05                	addi	s10,s10,1
    a7aa:	9402                	jalr	s0
    a7ac:	866a                	mv	a2,s10
    a7ae:	86a6                	mv	a3,s1
    a7b0:	85ca                	mv	a1,s2
    a7b2:	02000513          	li	a0,32
    a7b6:	0d05                	addi	s10,s10,1
    a7b8:	9402                	jalr	s0
    a7ba:	866a                	mv	a2,s10
    a7bc:	86a6                	mv	a3,s1
    a7be:	85ca                	mv	a1,s2
    a7c0:	02000513          	li	a0,32
    a7c4:	0d05                	addi	s10,s10,1
    a7c6:	9402                	jalr	s0
    a7c8:	866a                	mv	a2,s10
    a7ca:	86a6                	mv	a3,s1
    a7cc:	0d05                	addi	s10,s10,1
    a7ce:	85ca                	mv	a1,s2
    a7d0:	02000513          	li	a0,32
    a7d4:	9402                	jalr	s0
    a7d6:	099d0363          	beq	s10,s9,a85c <_vsnprintf+0x1cbc>
    a7da:	866a                	mv	a2,s10
    a7dc:	86a6                	mv	a3,s1
    a7de:	85ca                	mv	a1,s2
    a7e0:	02000513          	li	a0,32
    a7e4:	9402                	jalr	s0
    a7e6:	001d0a93          	addi	s5,s10,1
    a7ea:	8656                	mv	a2,s5
    a7ec:	86a6                	mv	a3,s1
    a7ee:	85ca                	mv	a1,s2
    a7f0:	02000513          	li	a0,32
    a7f4:	9402                	jalr	s0
    a7f6:	002d0c13          	addi	s8,s10,2
    a7fa:	8662                	mv	a2,s8
    a7fc:	86a6                	mv	a3,s1
    a7fe:	85ca                	mv	a1,s2
    a800:	02000513          	li	a0,32
    a804:	9402                	jalr	s0
    a806:	003d0b93          	addi	s7,s10,3
    a80a:	865e                	mv	a2,s7
    a80c:	86a6                	mv	a3,s1
    a80e:	85ca                	mv	a1,s2
    a810:	02000513          	li	a0,32
    a814:	9402                	jalr	s0
    a816:	004d0c13          	addi	s8,s10,4
    a81a:	8662                	mv	a2,s8
    a81c:	86a6                	mv	a3,s1
    a81e:	85ca                	mv	a1,s2
    a820:	02000513          	li	a0,32
    a824:	9402                	jalr	s0
    a826:	005d0a93          	addi	s5,s10,5
    a82a:	86a6                	mv	a3,s1
    a82c:	8656                	mv	a2,s5
    a82e:	85ca                	mv	a1,s2
    a830:	02000513          	li	a0,32
    a834:	9402                	jalr	s0
    a836:	006d0b93          	addi	s7,s10,6
    a83a:	86a6                	mv	a3,s1
    a83c:	865e                	mv	a2,s7
    a83e:	85ca                	mv	a1,s2
    a840:	02000513          	li	a0,32
    a844:	9402                	jalr	s0
    a846:	007d0c13          	addi	s8,s10,7
    a84a:	86a6                	mv	a3,s1
    a84c:	0d21                	addi	s10,s10,8
    a84e:	8662                	mv	a2,s8
    a850:	85ca                	mv	a1,s2
    a852:	02000513          	li	a0,32
    a856:	9402                	jalr	s0
    a858:	f99d11e3          	bne	s10,s9,a7da <_vsnprintf+0x1c3a>
    a85c:	6882                	ld	a7,0(sp)
    a85e:	988dc50b          	th.lbuia	a0,(s11),8,0
    a862:	86a6                	mv	a3,s1
    a864:	011b0733          	add	a4,s6,a7
    a868:	00270793          	addi	a5,a4,2
    a86c:	85ca                	mv	a1,s2
    a86e:	00170613          	addi	a2,a4,1
    a872:	e03e                	sd	a5,0(sp)
    a874:	9402                	jalr	s0
    a876:	b109                	j	a478 <_vsnprintf+0x18d8>
    a878:	0025f793          	andi	a5,a1,2
    a87c:	68078b63          	beqz	a5,af12 <_vsnprintf+0x2372>
    a880:	000b83e3          	beqz	s7,b086 <_vsnprintf+0x24e6>
    a884:	000c9663          	bnez	s9,a890 <_vsnprintf+0x1cf0>
    a888:	011c1463          	bne	s8,a7,a890 <_vsnprintf+0x1cf0>
    a88c:	6420406f          	j	eece <_vsnprintf+0x632e>
    a890:	4b89                	li	s7,2
    a892:	4ac1                	li	s5,16
    a894:	04f14503          	lbu	a0,79(sp)
    a898:	02000d13          	li	s10,32
    a89c:	6682                	ld	a3,0(sp)
    a89e:	01ab0c33          	add	s8,s6,s10
    a8a2:	03110c93          	addi	s9,sp,49
    a8a6:	419c07b3          	sub	a5,s8,s9
    a8aa:	9b36                	add	s6,s6,a3
    a8ac:	0077f893          	andi	a7,a5,7
    a8b0:	9b6a                	add	s6,s6,s10
    a8b2:	12088163          	beqz	a7,a9d4 <_vsnprintf+0x1e34>
    a8b6:	418b0633          	sub	a2,s6,s8
    a8ba:	86a6                	mv	a3,s1
    a8bc:	85ca                	mv	a1,s2
    a8be:	ec46                	sd	a7,24(sp)
    a8c0:	9402                	jalr	s0
    a8c2:	6762                	ld	a4,24(sp)
    a8c4:	4605                	li	a2,1
    a8c6:	ffec4503          	lbu	a0,-2(s8)
    a8ca:	1c7d                	addi	s8,s8,-1
    a8cc:	10c70463          	beq	a4,a2,a9d4 <_vsnprintf+0x1e34>
    a8d0:	4389                	li	t2,2
    a8d2:	06770663          	beq	a4,t2,a93e <_vsnprintf+0x1d9e>
    a8d6:	430d                	li	t1,3
    a8d8:	04670b63          	beq	a4,t1,a92e <_vsnprintf+0x1d8e>
    a8dc:	4811                	li	a6,4
    a8de:	05070063          	beq	a4,a6,a91e <_vsnprintf+0x1d7e>
    a8e2:	4f95                	li	t6,5
    a8e4:	03f70563          	beq	a4,t6,a90e <_vsnprintf+0x1d6e>
    a8e8:	4299                	li	t0,6
    a8ea:	00570a63          	beq	a4,t0,a8fe <_vsnprintf+0x1d5e>
    a8ee:	418b0633          	sub	a2,s6,s8
    a8f2:	86a6                	mv	a3,s1
    a8f4:	85ca                	mv	a1,s2
    a8f6:	9402                	jalr	s0
    a8f8:	ffec4503          	lbu	a0,-2(s8)
    a8fc:	1c7d                	addi	s8,s8,-1
    a8fe:	418b0633          	sub	a2,s6,s8
    a902:	86a6                	mv	a3,s1
    a904:	85ca                	mv	a1,s2
    a906:	9402                	jalr	s0
    a908:	ffec4503          	lbu	a0,-2(s8)
    a90c:	1c7d                	addi	s8,s8,-1
    a90e:	418b0633          	sub	a2,s6,s8
    a912:	86a6                	mv	a3,s1
    a914:	85ca                	mv	a1,s2
    a916:	9402                	jalr	s0
    a918:	ffec4503          	lbu	a0,-2(s8)
    a91c:	1c7d                	addi	s8,s8,-1
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
    a94e:	a059                	j	a9d4 <_vsnprintf+0x1e34>
    a950:	ffec4503          	lbu	a0,-2(s8)
    a954:	fffc0e13          	addi	t3,s8,-1
    a958:	41cb0633          	sub	a2,s6,t3
    a95c:	86a6                	mv	a3,s1
    a95e:	85ca                	mv	a1,s2
    a960:	9402                	jalr	s0
    a962:	ffdc4503          	lbu	a0,-3(s8)
    a966:	ffec0f13          	addi	t5,s8,-2
    a96a:	41eb0633          	sub	a2,s6,t5
    a96e:	86a6                	mv	a3,s1
    a970:	85ca                	mv	a1,s2
    a972:	9402                	jalr	s0
    a974:	ffcc4503          	lbu	a0,-4(s8)
    a978:	ffdc0593          	addi	a1,s8,-3
    a97c:	40bb0633          	sub	a2,s6,a1
    a980:	86a6                	mv	a3,s1
    a982:	85ca                	mv	a1,s2
    a984:	9402                	jalr	s0
    a986:	ffbc4503          	lbu	a0,-5(s8)
    a98a:	ffcc0793          	addi	a5,s8,-4
    a98e:	40fb0633          	sub	a2,s6,a5
    a992:	86a6                	mv	a3,s1
    a994:	85ca                	mv	a1,s2
    a996:	9402                	jalr	s0
    a998:	ffac4503          	lbu	a0,-6(s8)
    a99c:	ffbc0893          	addi	a7,s8,-5
    a9a0:	411b0633          	sub	a2,s6,a7
    a9a4:	86a6                	mv	a3,s1
    a9a6:	85ca                	mv	a1,s2
    a9a8:	9402                	jalr	s0
    a9aa:	ff9c4503          	lbu	a0,-7(s8)
    a9ae:	ffac0613          	addi	a2,s8,-6
    a9b2:	86a6                	mv	a3,s1
    a9b4:	40cb0633          	sub	a2,s6,a2
    a9b8:	85ca                	mv	a1,s2
    a9ba:	9402                	jalr	s0
    a9bc:	ff8c4503          	lbu	a0,-8(s8)
    a9c0:	ff9c0713          	addi	a4,s8,-7
    a9c4:	86a6                	mv	a3,s1
    a9c6:	40eb0633          	sub	a2,s6,a4
    a9ca:	85ca                	mv	a1,s2
    a9cc:	9402                	jalr	s0
    a9ce:	ff7c4503          	lbu	a0,-9(s8)
    a9d2:	1c61                	addi	s8,s8,-8
    a9d4:	86a6                	mv	a3,s1
    a9d6:	418b0633          	sub	a2,s6,s8
    a9da:	85ca                	mv	a1,s2
    a9dc:	9402                	jalr	s0
    a9de:	f78c99e3          	bne	s9,s8,a950 <_vsnprintf+0x1db0>
    a9e2:	6502                	ld	a0,0(sp)
    a9e4:	01a50eb3          	add	t4,a0,s10
    a9e8:	e076                	sd	t4,0(sp)
    a9ea:	a80b87e3          	beqz	s7,a478 <_vsnprintf+0x18d8>
    a9ee:	7c0abb8b          	th.extu	s7,s5,31,0
    a9f2:	a95d73e3          	bgeu	s10,s5,a478 <_vsnprintf+0x18d8>
    a9f6:	8af6                	mv	s5,t4
    a9f8:	8656                	mv	a2,s5
    a9fa:	86a6                	mv	a3,s1
    a9fc:	85ca                	mv	a1,s2
    a9fe:	02000513          	li	a0,32
    aa02:	0d05                	addi	s10,s10,1
    aa04:	0a85                	addi	s5,s5,1
    aa06:	9402                	jalr	s0
    aa08:	ff7d68e3          	bltu	s10,s7,a9f8 <_vsnprintf+0x1e58>
    aa0c:	e056                	sd	s5,0(sp)
    aa0e:	b4ad                	j	a478 <_vsnprintf+0x18d8>
    aa10:	660b8563          	beqz	s7,b07a <_vsnprintf+0x24da>
    aa14:	000c8463          	beqz	s9,aa1c <_vsnprintf+0x1e7c>
    aa18:	6c70106f          	j	c8de <_vsnprintf+0x3d3e>
    aa1c:	7c0c338b          	th.extu	t2,s8,31,0
    aa20:	007d1463          	bne	s10,t2,aa28 <_vsnprintf+0x1e88>
    aa24:	1140306f          	j	db38 <_vsnprintf+0x4f98>
    aa28:	47c1                	li	a5,16
    aa2a:	8abe                	mv	s5,a5
    aa2c:	4b89                	li	s7,2
    aa2e:	01a78463          	beq	a5,s10,aa36 <_vsnprintf+0x1e96>
    aa32:	6b10106f          	j	c8e2 <_vsnprintf+0x3d42>
    aa36:	1f40306f          	j	dc2a <_vsnprintf+0x508a>
    aa3a:	0001                	nop
    aa3c:	002b7613          	andi	a2,s6,2
    aa40:	5e061663          	bnez	a2,b02c <_vsnprintf+0x248c>
    aa44:	00c57b93          	andi	s7,a0,12
    aa48:	7c0c3f8b          	th.extu	t6,s8,31,0
    aa4c:	000b9463          	bnez	s7,aa54 <_vsnprintf+0x1eb4>
    aa50:	6000206f          	j	d050 <_vsnprintf+0x44b0>
    aa54:	000f9463          	bnez	t6,aa5c <_vsnprintf+0x1ebc>
    aa58:	3740406f          	j	edcc <_vsnprintf+0x622c>
    aa5c:	47bd                	li	a5,15
    aa5e:	4b81                	li	s7,0
    aa60:	4d01                	li	s10,0
    aa62:	40000c93          	li	s9,1024
    aa66:	8abe                	mv	s5,a5
    aa68:	03010b13          	addi	s6,sp,48
    aa6c:	a1c9                	j	af2e <_vsnprintf+0x238e>
    aa6e:	feeb7b13          	andi	s6,s6,-18
    aa72:	000b059b          	sext.w	a1,s6
    aa76:	2005f313          	andi	t1,a1,512
    aa7a:	8aae                	mv	s5,a1
    aa7c:	00030463          	beqz	t1,aa84 <_vsnprintf+0x1ee4>
    aa80:	3f80106f          	j	be78 <_vsnprintf+0x32d8>
    aa84:	1005f813          	andi	a6,a1,256
    aa88:	40000e93          	li	t4,1024
    aa8c:	60081563          	bnez	a6,b096 <_vsnprintf+0x24f6>
    aa90:	0405fe13          	andi	t3,a1,64
    aa94:	580e1863          	bnez	t3,b024 <_vsnprintf+0x2484>
    aa98:	0805f293          	andi	t0,a1,128
    aa9c:	00029463          	bnez	t0,aaa4 <_vsnprintf+0x1f04>
    aaa0:	5ca0206f          	j	d06a <_vsnprintf+0x44ca>
    aaa4:	388dce0b          	th.lhia	t3,(s11),8,0
    aaa8:	40fe571b          	sraiw	a4,t3,0xf
    aaac:	00ee4fb3          	xor	t6,t3,a4
    aab0:	40ef8cbb          	subw	s9,t6,a4
    aab4:	3c0cb38b          	th.extu	t2,s9,15,0
    aab8:	000e1763          	bnez	t3,aac6 <_vsnprintf+0x1f26>
    aabc:	000e8463          	beqz	t4,aac4 <_vsnprintf+0x1f24>
    aac0:	5e00206f          	j	d0a0 <_vsnprintf+0x4500>
    aac4:	4381                	li	t2,0
    aac6:	47a9                	li	a5,10
    aac8:	02f3fb33          	remu	s6,t2,a5
    aacc:	03010b93          	addi	s7,sp,48
    aad0:	4aa5                	li	s5,9
    aad2:	875e                	mv	a4,s7
    aad4:	030b031b          	addiw	t1,s6,48
    aad8:	02610823          	sb	t1,48(sp)
    aadc:	02f3dfb3          	divu	t6,t2,a5
    aae0:	107afc63          	bgeu	s5,t2,abf8 <_vsnprintf+0x2058>
    aae4:	03110713          	addi	a4,sp,49
    aae8:	02fff633          	remu	a2,t6,a5
    aaec:	0306081b          	addiw	a6,a2,48
    aaf0:	01070023          	sb	a6,0(a4)
    aaf4:	02ffdeb3          	divu	t4,t6,a5
    aaf8:	11faf063          	bgeu	s5,t6,abf8 <_vsnprintf+0x2058>
    aafc:	00000013          	nop
    ab00:	00170293          	addi	t0,a4,1
    ab04:	0888                	addi	a0,sp,80
    ab06:	0e550963          	beq	a0,t0,abf8 <_vsnprintf+0x2058>
    ab0a:	8716                	mv	a4,t0
    ab0c:	02fef633          	remu	a2,t4,a5
    ab10:	03060f9b          	addiw	t6,a2,48
    ab14:	01f28023          	sb	t6,0(t0)
    ab18:	02fedcb3          	divu	s9,t4,a5
    ab1c:	0ddafe63          	bgeu	s5,t4,abf8 <_vsnprintf+0x2058>
    ab20:	02fcfd33          	remu	s10,s9,a5
    ab24:	030d0f1b          	addiw	t5,s10,48
    ab28:	08175f0b          	th.sbib	t5,(a4),1,0
    ab2c:	02fcd6b3          	divu	a3,s9,a5
    ab30:	0d9af463          	bgeu	s5,s9,abf8 <_vsnprintf+0x2058>
    ab34:	00228713          	addi	a4,t0,2
    ab38:	02f6f3b3          	remu	t2,a3,a5
    ab3c:	03038b1b          	addiw	s6,t2,48
    ab40:	01628123          	sb	s6,2(t0)
    ab44:	02f6d333          	divu	t1,a3,a5
    ab48:	0adaf863          	bgeu	s5,a3,abf8 <_vsnprintf+0x2058>
    ab4c:	00328713          	addi	a4,t0,3
    ab50:	02f37833          	remu	a6,t1,a5
    ab54:	03080e9b          	addiw	t4,a6,48
    ab58:	01d281a3          	sb	t4,3(t0)
    ab5c:	02f35533          	divu	a0,t1,a5
    ab60:	086afc63          	bgeu	s5,t1,abf8 <_vsnprintf+0x2058>
    ab64:	00428713          	addi	a4,t0,4
    ab68:	02f57633          	remu	a2,a0,a5
    ab6c:	03060f9b          	addiw	t6,a2,48
    ab70:	01f28223          	sb	t6,4(t0)
    ab74:	02f55cb3          	divu	s9,a0,a5
    ab78:	08aaf063          	bgeu	s5,a0,abf8 <_vsnprintf+0x2058>
    ab7c:	00528713          	addi	a4,t0,5
    ab80:	02fcfd33          	remu	s10,s9,a5
    ab84:	030d0f1b          	addiw	t5,s10,48
    ab88:	01e282a3          	sb	t5,5(t0)
    ab8c:	02fcd6b3          	divu	a3,s9,a5
    ab90:	079af463          	bgeu	s5,s9,abf8 <_vsnprintf+0x2058>
    ab94:	00628713          	addi	a4,t0,6
    ab98:	02f6f3b3          	remu	t2,a3,a5
    ab9c:	03038b1b          	addiw	s6,t2,48
    aba0:	01628323          	sb	s6,6(t0)
    aba4:	02f6d833          	divu	a6,a3,a5
    aba8:	04daf863          	bgeu	s5,a3,abf8 <_vsnprintf+0x2058>
    abac:	00728713          	addi	a4,t0,7
    abb0:	02f87333          	remu	t1,a6,a5
    abb4:	03030e9b          	addiw	t4,t1,48
    abb8:	01d283a3          	sb	t4,7(t0)
    abbc:	02f85533          	divu	a0,a6,a5
    abc0:	030afc63          	bgeu	s5,a6,abf8 <_vsnprintf+0x2058>
    abc4:	00828713          	addi	a4,t0,8
    abc8:	02f57633          	remu	a2,a0,a5
    abcc:	03060f9b          	addiw	t6,a2,48
    abd0:	01f28423          	sb	t6,8(t0)
    abd4:	02f55cb3          	divu	s9,a0,a5
    abd8:	02aaf063          	bgeu	s5,a0,abf8 <_vsnprintf+0x2058>
    abdc:	00928713          	addi	a4,t0,9
    abe0:	8fe6                	mv	t6,s9
    abe2:	02fcf633          	remu	a2,s9,a5
    abe6:	0306081b          	addiw	a6,a2,48
    abea:	01070023          	sb	a6,0(a4)
    abee:	02ffdeb3          	divu	t4,t6,a5
    abf2:	f1fae7e3          	bltu	s5,t6,ab00 <_vsnprintf+0x1f60>
    abf6:	0001                	nop
    abf8:	41770733          	sub	a4,a4,s7
    abfc:	0025fb13          	andi	s6,a1,2
    ac00:	00170793          	addi	a5,a4,1
    ac04:	8aae                	mv	s5,a1
    ac06:	000b1463          	bnez	s6,ac0e <_vsnprintf+0x206e>
    ac0a:	1070106f          	j	c510 <_vsnprintf+0x3970>
    ac0e:	02000c13          	li	s8,32
    ac12:	4b09                	li	s6,2
    ac14:	01878463          	beq	a5,s8,ac1c <_vsnprintf+0x207c>
    ac18:	2db0206f          	j	d6f2 <_vsnprintf+0x4b52>
    ac1c:	04f14503          	lbu	a0,79(sp)
    ac20:	6302                	ld	t1,0(sp)
    ac22:	02000c13          	li	s8,32
    ac26:	018b8d33          	add	s10,s7,s8
    ac2a:	fffbcf13          	not	t5,s7
    ac2e:	006c0cb3          	add	s9,s8,t1
    ac32:	01af0333          	add	t1,t5,s10
    ac36:	00737813          	andi	a6,t1,7
    ac3a:	019b8c33          	add	s8,s7,s9
    ac3e:	00081463          	bnez	a6,ac46 <_vsnprintf+0x20a6>
    ac42:	6860206f          	j	d2c8 <_vsnprintf+0x4728>
    ac46:	41ac0633          	sub	a2,s8,s10
    ac4a:	ec46                	sd	a7,24(sp)
    ac4c:	f042                	sd	a6,32(sp)
    ac4e:	86a6                	mv	a3,s1
    ac50:	85ca                	mv	a1,s2
    ac52:	9402                	jalr	s0
    ac54:	68e2                	ld	a7,24(sp)
    ac56:	7a82                	ld	s5,32(sp)
    ac58:	4e85                	li	t4,1
    ac5a:	1d7d                	addi	s10,s10,-1
    ac5c:	fffd4503          	lbu	a0,-1(s10)
    ac60:	01da9463          	bne	s5,t4,ac68 <_vsnprintf+0x20c8>
    ac64:	6640206f          	j	d2c8 <_vsnprintf+0x4728>
    ac68:	4e09                	li	t3,2
    ac6a:	07ca8f63          	beq	s5,t3,ace8 <_vsnprintf+0x2148>
    ac6e:	460d                	li	a2,3
    ac70:	06ca8263          	beq	s5,a2,acd4 <_vsnprintf+0x2134>
    ac74:	4f91                	li	t6,4
    ac76:	05fa8563          	beq	s5,t6,acc0 <_vsnprintf+0x2120>
    ac7a:	4715                	li	a4,5
    ac7c:	02ea8863          	beq	s5,a4,acac <_vsnprintf+0x210c>
    ac80:	4699                	li	a3,6
    ac82:	00da8b63          	beq	s5,a3,ac98 <_vsnprintf+0x20f8>
    ac86:	41ac0633          	sub	a2,s8,s10
    ac8a:	86a6                	mv	a3,s1
    ac8c:	85ca                	mv	a1,s2
    ac8e:	9402                	jalr	s0
    ac90:	68e2                	ld	a7,24(sp)
    ac92:	ffed4503          	lbu	a0,-2(s10)
    ac96:	1d7d                	addi	s10,s10,-1
    ac98:	41ac0633          	sub	a2,s8,s10
    ac9c:	ec46                	sd	a7,24(sp)
    ac9e:	86a6                	mv	a3,s1
    aca0:	85ca                	mv	a1,s2
    aca2:	9402                	jalr	s0
    aca4:	68e2                	ld	a7,24(sp)
    aca6:	ffed4503          	lbu	a0,-2(s10)
    acaa:	1d7d                	addi	s10,s10,-1
    acac:	41ac0633          	sub	a2,s8,s10
    acb0:	ec46                	sd	a7,24(sp)
    acb2:	86a6                	mv	a3,s1
    acb4:	85ca                	mv	a1,s2
    acb6:	9402                	jalr	s0
    acb8:	68e2                	ld	a7,24(sp)
    acba:	ffed4503          	lbu	a0,-2(s10)
    acbe:	1d7d                	addi	s10,s10,-1
    acc0:	41ac0633          	sub	a2,s8,s10
    acc4:	ec46                	sd	a7,24(sp)
    acc6:	86a6                	mv	a3,s1
    acc8:	85ca                	mv	a1,s2
    acca:	9402                	jalr	s0
    accc:	68e2                	ld	a7,24(sp)
    acce:	ffed4503          	lbu	a0,-2(s10)
    acd2:	1d7d                	addi	s10,s10,-1
    acd4:	41ac0633          	sub	a2,s8,s10
    acd8:	ec46                	sd	a7,24(sp)
    acda:	86a6                	mv	a3,s1
    acdc:	85ca                	mv	a1,s2
    acde:	9402                	jalr	s0
    ace0:	68e2                	ld	a7,24(sp)
    ace2:	ffed4503          	lbu	a0,-2(s10)
    ace6:	1d7d                	addi	s10,s10,-1
    ace8:	41ac0633          	sub	a2,s8,s10
    acec:	86a6                	mv	a3,s1
    acee:	85ca                	mv	a1,s2
    acf0:	ec46                	sd	a7,24(sp)
    acf2:	9402                	jalr	s0
    acf4:	1d7d                	addi	s10,s10,-1
    acf6:	f05a                	sd	s6,32(sp)
    acf8:	fffd4503          	lbu	a0,-1(s10)
    acfc:	a895                	j	ad70 <_vsnprintf+0x21d0>
    acfe:	8b6a                	mv	s6,s10
    ad00:	89eb450b          	th.lbuib	a0,(s6),-2,0
    ad04:	411c0633          	sub	a2,s8,a7
    ad08:	86a6                	mv	a3,s1
    ad0a:	85ca                	mv	a1,s2
    ad0c:	9402                	jalr	s0
    ad0e:	8aea                	mv	s5,s10
    ad10:	89dac50b          	th.lbuib	a0,(s5),-3,0
    ad14:	416c0633          	sub	a2,s8,s6
    ad18:	86a6                	mv	a3,s1
    ad1a:	85ca                	mv	a1,s2
    ad1c:	9402                	jalr	s0
    ad1e:	8b6a                	mv	s6,s10
    ad20:	89cb450b          	th.lbuib	a0,(s6),-4,0
    ad24:	415c0633          	sub	a2,s8,s5
    ad28:	86a6                	mv	a3,s1
    ad2a:	85ca                	mv	a1,s2
    ad2c:	9402                	jalr	s0
    ad2e:	8aea                	mv	s5,s10
    ad30:	89bac50b          	th.lbuib	a0,(s5),-5,0
    ad34:	416c0633          	sub	a2,s8,s6
    ad38:	86a6                	mv	a3,s1
    ad3a:	85ca                	mv	a1,s2
    ad3c:	9402                	jalr	s0
    ad3e:	8b6a                	mv	s6,s10
    ad40:	89ab450b          	th.lbuib	a0,(s6),-6,0
    ad44:	415c0633          	sub	a2,s8,s5
    ad48:	86a6                	mv	a3,s1
    ad4a:	85ca                	mv	a1,s2
    ad4c:	9402                	jalr	s0
    ad4e:	8aea                	mv	s5,s10
    ad50:	899ac50b          	th.lbuib	a0,(s5),-7,0
    ad54:	86a6                	mv	a3,s1
    ad56:	416c0633          	sub	a2,s8,s6
    ad5a:	85ca                	mv	a1,s2
    ad5c:	9402                	jalr	s0
    ad5e:	898d450b          	th.lbuib	a0,(s10),-8,0
    ad62:	86a6                	mv	a3,s1
    ad64:	415c0633          	sub	a2,s8,s5
    ad68:	85ca                	mv	a1,s2
    ad6a:	9402                	jalr	s0
    ad6c:	fffd4503          	lbu	a0,-1(s10)
    ad70:	86a6                	mv	a3,s1
    ad72:	41ac0633          	sub	a2,s8,s10
    ad76:	85ca                	mv	a1,s2
    ad78:	9402                	jalr	s0
    ad7a:	fffd0893          	addi	a7,s10,-1
    ad7e:	f91b90e3          	bne	s7,a7,acfe <_vsnprintf+0x215e>
    ad82:	68e2                	ld	a7,24(sp)
    ad84:	7b02                	ld	s6,32(sp)
    ad86:	8ae6                	mv	s5,s9
    ad88:	380b0ee3          	beqz	s6,b924 <_vsnprintf+0x2d84>
    ad8c:	6b82                	ld	s7,0(sp)
    ad8e:	7c08bc0b          	th.extu	s8,a7,31,0
    ad92:	417a8d33          	sub	s10,s5,s7
    ad96:	398d77e3          	bgeu	s10,s8,b924 <_vsnprintf+0x2d84>
    ad9a:	fffd4513          	not	a0,s10
    ad9e:	018507b3          	add	a5,a0,s8
    ada2:	86a6                	mv	a3,s1
    ada4:	8656                	mv	a2,s5
    ada6:	85ca                	mv	a1,s2
    ada8:	02000513          	li	a0,32
    adac:	e056                	sd	s5,0(sp)
    adae:	0077fb93          	andi	s7,a5,7
    adb2:	001d0c93          	addi	s9,s10,1
    adb6:	9402                	jalr	s0
    adb8:	6282                	ld	t0,0(sp)
    adba:	001a8b13          	addi	s6,s5,1
    adbe:	eb8cf963          	bgeu	s9,s8,a470 <_vsnprintf+0x18d0>
    adc2:	0a0b8063          	beqz	s7,ae62 <_vsnprintf+0x22c2>
    adc6:	4585                	li	a1,1
    adc8:	08bb8363          	beq	s7,a1,ae4e <_vsnprintf+0x22ae>
    adcc:	4389                	li	t2,2
    adce:	067b8863          	beq	s7,t2,ae3e <_vsnprintf+0x229e>
    add2:	4f0d                	li	t5,3
    add4:	05eb8d63          	beq	s7,t5,ae2e <_vsnprintf+0x228e>
    add8:	4311                	li	t1,4
    adda:	046b8263          	beq	s7,t1,ae1e <_vsnprintf+0x227e>
    adde:	4815                	li	a6,5
    ade0:	030b8763          	beq	s7,a6,ae0e <_vsnprintf+0x226e>
    ade4:	4e99                	li	t4,6
    ade6:	01db8c63          	beq	s7,t4,adfe <_vsnprintf+0x225e>
    adea:	865a                	mv	a2,s6
    adec:	86a6                	mv	a3,s1
    adee:	85ca                	mv	a1,s2
    adf0:	02000513          	li	a0,32
    adf4:	00228b13          	addi	s6,t0,2
    adf8:	002d0c93          	addi	s9,s10,2
    adfc:	9402                	jalr	s0
    adfe:	865a                	mv	a2,s6
    ae00:	86a6                	mv	a3,s1
    ae02:	85ca                	mv	a1,s2
    ae04:	02000513          	li	a0,32
    ae08:	0b05                	addi	s6,s6,1
    ae0a:	9402                	jalr	s0
    ae0c:	0c85                	addi	s9,s9,1
    ae0e:	865a                	mv	a2,s6
    ae10:	86a6                	mv	a3,s1
    ae12:	85ca                	mv	a1,s2
    ae14:	02000513          	li	a0,32
    ae18:	0b05                	addi	s6,s6,1
    ae1a:	9402                	jalr	s0
    ae1c:	0c85                	addi	s9,s9,1
    ae1e:	865a                	mv	a2,s6
    ae20:	86a6                	mv	a3,s1
    ae22:	85ca                	mv	a1,s2
    ae24:	02000513          	li	a0,32
    ae28:	0b05                	addi	s6,s6,1
    ae2a:	9402                	jalr	s0
    ae2c:	0c85                	addi	s9,s9,1
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
    ae58:	0c85                	addi	s9,s9,1
    ae5a:	0b05                	addi	s6,s6,1
    ae5c:	9402                	jalr	s0
    ae5e:	e18cf963          	bgeu	s9,s8,a470 <_vsnprintf+0x18d0>
    ae62:	865a                	mv	a2,s6
    ae64:	86a6                	mv	a3,s1
    ae66:	85ca                	mv	a1,s2
    ae68:	02000513          	li	a0,32
    ae6c:	9402                	jalr	s0
    ae6e:	001b0a93          	addi	s5,s6,1
    ae72:	8656                	mv	a2,s5
    ae74:	86a6                	mv	a3,s1
    ae76:	85ca                	mv	a1,s2
    ae78:	02000513          	li	a0,32
    ae7c:	9402                	jalr	s0
    ae7e:	002b0d13          	addi	s10,s6,2
    ae82:	866a                	mv	a2,s10
    ae84:	86a6                	mv	a3,s1
    ae86:	85ca                	mv	a1,s2
    ae88:	02000513          	li	a0,32
    ae8c:	9402                	jalr	s0
    ae8e:	003b0a93          	addi	s5,s6,3
    ae92:	8656                	mv	a2,s5
    ae94:	86a6                	mv	a3,s1
    ae96:	85ca                	mv	a1,s2
    ae98:	02000513          	li	a0,32
    ae9c:	9402                	jalr	s0
    ae9e:	004b0b93          	addi	s7,s6,4
    aea2:	865e                	mv	a2,s7
    aea4:	86a6                	mv	a3,s1
    aea6:	85ca                	mv	a1,s2
    aea8:	02000513          	li	a0,32
    aeac:	9402                	jalr	s0
    aeae:	005b0d13          	addi	s10,s6,5
    aeb2:	86a6                	mv	a3,s1
    aeb4:	866a                	mv	a2,s10
    aeb6:	85ca                	mv	a1,s2
    aeb8:	02000513          	li	a0,32
    aebc:	9402                	jalr	s0
    aebe:	006b0b93          	addi	s7,s6,6
    aec2:	86a6                	mv	a3,s1
    aec4:	865e                	mv	a2,s7
    aec6:	85ca                	mv	a1,s2
    aec8:	02000513          	li	a0,32
    aecc:	9402                	jalr	s0
    aece:	007b0a93          	addi	s5,s6,7
    aed2:	86a6                	mv	a3,s1
    aed4:	8656                	mv	a2,s5
    aed6:	85ca                	mv	a1,s2
    aed8:	02000513          	li	a0,32
    aedc:	0ca1                	addi	s9,s9,8
    aede:	0b21                	addi	s6,s6,8
    aee0:	9402                	jalr	s0
    aee2:	f98ce0e3          	bltu	s9,s8,ae62 <_vsnprintf+0x22c2>
    aee6:	d8aff06f          	j	a470 <_vsnprintf+0x18d0>
    aeea:	0001                	nop
    aeec:	4f1e6863          	bltu	t3,a7,b3dc <_vsnprintf+0x283c>
    aef0:	002b7f93          	andi	t6,s6,2
    aef4:	4a89                	li	s5,2
    aef6:	4e0f8a63          	beqz	t6,b3ea <_vsnprintf+0x284a>
    aefa:	000d9463          	bnez	s11,af02 <_vsnprintf+0x2362>
    aefe:	fb8fe06f          	j	96b6 <_vsnprintf+0xb16>
    af02:	f2068253          	fmv.d.x	ft4,a3
    af06:	1a1272d3          	fdiv.d	ft5,ft4,ft1
    af0a:	e20286d3          	fmv.x.d	a3,ft5
    af0e:	fa8fe06f          	j	96b6 <_vsnprintf+0xb16>
    af12:	00c5f393          	andi	t2,a1,12
    af16:	7c0c3f8b          	th.extu	t6,s8,31,0
    af1a:	00039463          	bnez	t2,af22 <_vsnprintf+0x2382>
    af1e:	0fa0206f          	j	d018 <_vsnprintf+0x4478>
    af22:	47bd                	li	a5,15
    af24:	8abe                	mv	s5,a5
    af26:	01f8e463          	bltu	a7,t6,af2e <_vsnprintf+0x238e>
    af2a:	0fa0206f          	j	d024 <_vsnprintf+0x4484>
    af2e:	02000e93          	li	t4,32
    af32:	41ae8f33          	sub	t5,t4,s10
    af36:	007f7893          	andi	a7,t5,7
    af3a:	01ab0733          	add	a4,s6,s10
    af3e:	03000313          	li	t1,48
    af42:	06088763          	beqz	a7,afb0 <_vsnprintf+0x2410>
    af46:	0d05                	addi	s10,s10,1
    af48:	1817530b          	th.sbia	t1,(a4),1,0
    af4c:	d7fd0163          	beq	s10,t6,a4ae <_vsnprintf+0x190e>
    af50:	4505                	li	a0,1
    af52:	04a88f63          	beq	a7,a0,afb0 <_vsnprintf+0x2410>
    af56:	4c09                	li	s8,2
    af58:	05888763          	beq	a7,s8,afa6 <_vsnprintf+0x2406>
    af5c:	460d                	li	a2,3
    af5e:	02c88f63          	beq	a7,a2,af9c <_vsnprintf+0x23fc>
    af62:	4391                	li	t2,4
    af64:	02788763          	beq	a7,t2,af92 <_vsnprintf+0x23f2>
    af68:	4815                	li	a6,5
    af6a:	01088f63          	beq	a7,a6,af88 <_vsnprintf+0x23e8>
    af6e:	4299                	li	t0,6
    af70:	00588763          	beq	a7,t0,af7e <_vsnprintf+0x23de>
    af74:	0d05                	addi	s10,s10,1
    af76:	1817530b          	th.sbia	t1,(a4),1,0
    af7a:	d3fd0a63          	beq	s10,t6,a4ae <_vsnprintf+0x190e>
    af7e:	0d05                	addi	s10,s10,1
    af80:	1817530b          	th.sbia	t1,(a4),1,0
    af84:	d3fd0563          	beq	s10,t6,a4ae <_vsnprintf+0x190e>
    af88:	0d05                	addi	s10,s10,1
    af8a:	1817530b          	th.sbia	t1,(a4),1,0
    af8e:	d3fd0063          	beq	s10,t6,a4ae <_vsnprintf+0x190e>
    af92:	0d05                	addi	s10,s10,1
    af94:	1817530b          	th.sbia	t1,(a4),1,0
    af98:	d1fd0b63          	beq	s10,t6,a4ae <_vsnprintf+0x190e>
    af9c:	0d05                	addi	s10,s10,1
    af9e:	1817530b          	th.sbia	t1,(a4),1,0
    afa2:	d1fd0663          	beq	s10,t6,a4ae <_vsnprintf+0x190e>
    afa6:	0d05                	addi	s10,s10,1
    afa8:	1817530b          	th.sbia	t1,(a4),1,0
    afac:	d1fd0163          	beq	s10,t6,a4ae <_vsnprintf+0x190e>
    afb0:	01dd1463          	bne	s10,t4,afb8 <_vsnprintf+0x2418>
    afb4:	4520306f          	j	e406 <_vsnprintf+0x5866>
    afb8:	0d05                	addi	s10,s10,1
    afba:	00670023          	sb	t1,0(a4)
    afbe:	86ea                	mv	a3,s10
    afc0:	cffd0763          	beq	s10,t6,a4ae <_vsnprintf+0x190e>
    afc4:	0d05                	addi	s10,s10,1
    afc6:	006700a3          	sb	t1,1(a4)
    afca:	cffd0263          	beq	s10,t6,a4ae <_vsnprintf+0x190e>
    afce:	00268d13          	addi	s10,a3,2
    afd2:	00670123          	sb	t1,2(a4)
    afd6:	cdfd0c63          	beq	s10,t6,a4ae <_vsnprintf+0x190e>
    afda:	00368d13          	addi	s10,a3,3
    afde:	006701a3          	sb	t1,3(a4)
    afe2:	cdfd0663          	beq	s10,t6,a4ae <_vsnprintf+0x190e>
    afe6:	00468d13          	addi	s10,a3,4
    afea:	00670223          	sb	t1,4(a4)
    afee:	cdfd0063          	beq	s10,t6,a4ae <_vsnprintf+0x190e>
    aff2:	00568d13          	addi	s10,a3,5
    aff6:	006702a3          	sb	t1,5(a4)
    affa:	cbfd0a63          	beq	s10,t6,a4ae <_vsnprintf+0x190e>
    affe:	00668d13          	addi	s10,a3,6
    b002:	00670323          	sb	t1,6(a4)
    b006:	cbfd0463          	beq	s10,t6,a4ae <_vsnprintf+0x190e>
    b00a:	006703a3          	sb	t1,7(a4)
    b00e:	00768d13          	addi	s10,a3,7
    b012:	0721                	addi	a4,a4,8
    b014:	f9fd1ee3          	bne	s10,t6,afb0 <_vsnprintf+0x2410>
    b018:	c96ff06f          	j	a4ae <_vsnprintf+0x190e>
    b01c:	47c1                	li	a5,16
    b01e:	86be                	mv	a3,a5
    b020:	db9fe06f          	j	9dd8 <_vsnprintf+0x1238>
    b024:	988dce0b          	th.lbuia	t3,(s11),8,0
    b028:	83f2                	mv	t2,t3
    b02a:	b479                	j	aab8 <_vsnprintf+0x1f18>
    b02c:	00457813          	andi	a6,a0,4
    b030:	00081463          	bnez	a6,b038 <_vsnprintf+0x2498>
    b034:	04a0206f          	j	d07e <_vsnprintf+0x44de>
    b038:	4b89                	li	s7,2
    b03a:	4ac1                	li	s5,16
    b03c:	03010b13          	addi	s6,sp,48
    b040:	00278c33          	add	s8,a5,sp
    b044:	02b00513          	li	a0,43
    b048:	00178d13          	addi	s10,a5,1
    b04c:	02ac0823          	sb	a0,48(s8)
    b050:	b0b1                	j	a89c <_vsnprintf+0x1cfc>
    b052:	47bd                	li	a5,15
    b054:	8abe                	mv	s5,a5
    b056:	c50ff06f          	j	a4a6 <_vsnprintf+0x1906>
    b05a:	8817c70b          	th.lbuib	a4,(a5),1,0
    b05e:	c319                	beqz	a4,b064 <_vsnprintf+0x24c4>
    b060:	856fe06f          	j	90b6 <_vsnprintf+0x516>
    b064:	8d6fe06f          	j	913a <_vsnprintf+0x59a>
    b068:	080ff513          	andi	a0,t6,128
    b06c:	e119                	bnez	a0,b072 <_vsnprintf+0x24d2>
    b06e:	4920206f          	j	d500 <_vsnprintf+0x4960>
    b072:	b88dce8b          	th.lhuia	t4,(s11),8,0
    b076:	da5fe06f          	j	9e1a <_vsnprintf+0x127a>
    b07a:	02000c13          	li	s8,32
    b07e:	018d0463          	beq	s10,s8,b086 <_vsnprintf+0x24e6>
    b082:	6290306f          	j	eeaa <_vsnprintf+0x630a>
    b086:	04f14503          	lbu	a0,79(sp)
    b08a:	4b89                	li	s7,2
    b08c:	4ac1                	li	s5,16
    b08e:	02000d13          	li	s10,32
    b092:	80bff06f          	j	a89c <_vsnprintf+0x1cfc>
    b096:	886e                	mv	a6,s11
    b098:	78884e0b          	th.ldia	t3,(a6),8,0
    b09c:	000e0463          	beqz	t3,b0a4 <_vsnprintf+0x2504>
    b0a0:	f3ffe06f          	j	9fde <_vsnprintf+0x143e>
    b0a4:	002afd93          	andi	s11,s5,2
    b0a8:	000d8463          	beqz	s11,b0b0 <_vsnprintf+0x2510>
    b0ac:	6500306f          	j	e6fc <_vsnprintf+0x5b5c>
    b0b0:	7c0c3d0b          	th.extu	s10,s8,31,0
    b0b4:	4781                	li	a5,0
    b0b6:	03010313          	addi	t1,sp,48
    b0ba:	00089463          	bnez	a7,b0c2 <_vsnprintf+0x2522>
    b0be:	6600306f          	j	e71e <_vsnprintf+0x5b7e>
    b0c2:	000d1463          	bnez	s10,b0ca <_vsnprintf+0x252a>
    b0c6:	6790306f          	j	ef3e <_vsnprintf+0x639e>
    b0ca:	02000513          	li	a0,32
    b0ce:	40f50f33          	sub	t5,a0,a5
    b0d2:	007f7a93          	andi	s5,t5,7
    b0d6:	00f30733          	add	a4,t1,a5
    b0da:	03000e93          	li	t4,48
    b0de:	060a8763          	beqz	s5,b14c <_vsnprintf+0x25ac>
    b0e2:	0785                	addi	a5,a5,1
    b0e4:	18175e8b          	th.sbia	t4,(a4),1,0
    b0e8:	0da7f663          	bgeu	a5,s10,b1b4 <_vsnprintf+0x2614>
    b0ec:	4605                	li	a2,1
    b0ee:	04ca8f63          	beq	s5,a2,b14c <_vsnprintf+0x25ac>
    b0f2:	4289                	li	t0,2
    b0f4:	045a8763          	beq	s5,t0,b142 <_vsnprintf+0x25a2>
    b0f8:	4c8d                	li	s9,3
    b0fa:	039a8f63          	beq	s5,s9,b138 <_vsnprintf+0x2598>
    b0fe:	4c11                	li	s8,4
    b100:	038a8763          	beq	s5,s8,b12e <_vsnprintf+0x258e>
    b104:	4b95                	li	s7,5
    b106:	017a8f63          	beq	s5,s7,b124 <_vsnprintf+0x2584>
    b10a:	4f99                	li	t6,6
    b10c:	01fa8763          	beq	s5,t6,b11a <_vsnprintf+0x257a>
    b110:	0785                	addi	a5,a5,1
    b112:	18175e8b          	th.sbia	t4,(a4),1,0
    b116:	09a7ff63          	bgeu	a5,s10,b1b4 <_vsnprintf+0x2614>
    b11a:	0785                	addi	a5,a5,1
    b11c:	18175e8b          	th.sbia	t4,(a4),1,0
    b120:	09a7fa63          	bgeu	a5,s10,b1b4 <_vsnprintf+0x2614>
    b124:	0785                	addi	a5,a5,1
    b126:	18175e8b          	th.sbia	t4,(a4),1,0
    b12a:	09a7f563          	bgeu	a5,s10,b1b4 <_vsnprintf+0x2614>
    b12e:	0785                	addi	a5,a5,1
    b130:	18175e8b          	th.sbia	t4,(a4),1,0
    b134:	09a7f063          	bgeu	a5,s10,b1b4 <_vsnprintf+0x2614>
    b138:	0785                	addi	a5,a5,1
    b13a:	18175e8b          	th.sbia	t4,(a4),1,0
    b13e:	07a7fb63          	bgeu	a5,s10,b1b4 <_vsnprintf+0x2614>
    b142:	0785                	addi	a5,a5,1
    b144:	18175e8b          	th.sbia	t4,(a4),1,0
    b148:	07a7f663          	bgeu	a5,s10,b1b4 <_vsnprintf+0x2614>
    b14c:	00a79463          	bne	a5,a0,b154 <_vsnprintf+0x25b4>
    b150:	3130206f          	j	dc62 <_vsnprintf+0x50c2>
    b154:	0785                	addi	a5,a5,1
    b156:	01d70023          	sb	t4,0(a4)
    b15a:	83be                	mv	t2,a5
    b15c:	05a7fc63          	bgeu	a5,s10,b1b4 <_vsnprintf+0x2614>
    b160:	0785                	addi	a5,a5,1
    b162:	01d700a3          	sb	t4,1(a4)
    b166:	05a7f763          	bgeu	a5,s10,b1b4 <_vsnprintf+0x2614>
    b16a:	00238793          	addi	a5,t2,2
    b16e:	01d70123          	sb	t4,2(a4)
    b172:	05a7f163          	bgeu	a5,s10,b1b4 <_vsnprintf+0x2614>
    b176:	00338793          	addi	a5,t2,3
    b17a:	01d701a3          	sb	t4,3(a4)
    b17e:	03a7fb63          	bgeu	a5,s10,b1b4 <_vsnprintf+0x2614>
    b182:	00438793          	addi	a5,t2,4
    b186:	01d70223          	sb	t4,4(a4)
    b18a:	03a7f563          	bgeu	a5,s10,b1b4 <_vsnprintf+0x2614>
    b18e:	00538793          	addi	a5,t2,5
    b192:	01d702a3          	sb	t4,5(a4)
    b196:	01a7ff63          	bgeu	a5,s10,b1b4 <_vsnprintf+0x2614>
    b19a:	00638793          	addi	a5,t2,6
    b19e:	01d70323          	sb	t4,6(a4)
    b1a2:	01a7f963          	bgeu	a5,s10,b1b4 <_vsnprintf+0x2614>
    b1a6:	01d703a3          	sb	t4,7(a4)
    b1aa:	00738793          	addi	a5,t2,7
    b1ae:	0721                	addi	a4,a4,8
    b1b0:	f9a7eee3          	bltu	a5,s10,b14c <_vsnprintf+0x25ac>
    b1b4:	000d9463          	bnez	s11,b1bc <_vsnprintf+0x261c>
    b1b8:	6c60306f          	j	e87e <_vsnprintf+0x5cde>
    b1bc:	7c08b68b          	th.extu	a3,a7,31,0
    b1c0:	00d7f463          	bgeu	a5,a3,b1c8 <_vsnprintf+0x2628>
    b1c4:	3b00206f          	j	d574 <_vsnprintf+0x49d4>
    b1c8:	86be                	mv	a3,a5
    b1ca:	00a79463          	bne	a5,a0,b1d2 <_vsnprintf+0x2632>
    b1ce:	2a10206f          	j	dc6e <_vsnprintf+0x50ce>
    b1d2:	000e4463          	bltz	t3,b1da <_vsnprintf+0x263a>
    b1d6:	5630306f          	j	ef38 <_vsnprintf+0x6398>
    b1da:	00268f33          	add	t5,a3,sp
    b1de:	02d00613          	li	a2,45
    b1e2:	02cf0823          	sb	a2,48(t5)
    b1e6:	0035f793          	andi	a5,a1,3
    b1ea:	00168d13          	addi	s10,a3,1
    b1ee:	c399                	beqz	a5,b1f4 <_vsnprintf+0x2654>
    b1f0:	53b0306f          	j	ef2a <_vsnprintf+0x638a>
    b1f4:	7c08bb8b          	th.extu	s7,a7,31,0
    b1f8:	8dc2                	mv	s11,a6
    b1fa:	4b01                	li	s6,0
    b1fc:	017d6463          	bltu	s10,s7,b204 <_vsnprintf+0x2664>
    b200:	5210306f          	j	ef20 <_vsnprintf+0x6380>
    b204:	6602                	ld	a2,0(sp)
    b206:	85ca                	mv	a1,s2
    b208:	ec46                	sd	a7,24(sp)
    b20a:	40cd0cb3          	sub	s9,s10,a2
    b20e:	fffcc313          	not	t1,s9
    b212:	40c30e33          	sub	t3,t1,a2
    b216:	86a6                	mv	a3,s1
    b218:	02000513          	li	a0,32
    b21c:	017e0ab3          	add	s5,t3,s7
    b220:	00160c13          	addi	s8,a2,1
    b224:	9402                	jalr	s0
    b226:	018c85b3          	add	a1,s9,s8
    b22a:	68e2                	ld	a7,24(sp)
    b22c:	007afa93          	andi	s5,s5,7
    b230:	1575f563          	bgeu	a1,s7,b37a <_vsnprintf+0x27da>
    b234:	0a0a8863          	beqz	s5,b2e4 <_vsnprintf+0x2744>
    b238:	4685                	li	a3,1
    b23a:	08da8863          	beq	s5,a3,b2ca <_vsnprintf+0x272a>
    b23e:	4809                	li	a6,2
    b240:	070a8c63          	beq	s5,a6,b2b8 <_vsnprintf+0x2718>
    b244:	428d                	li	t0,3
    b246:	065a8063          	beq	s5,t0,b2a6 <_vsnprintf+0x2706>
    b24a:	4f91                	li	t6,4
    b24c:	05fa8463          	beq	s5,t6,b294 <_vsnprintf+0x26f4>
    b250:	4395                	li	t2,5
    b252:	027a8863          	beq	s5,t2,b282 <_vsnprintf+0x26e2>
    b256:	4719                	li	a4,6
    b258:	00ea8c63          	beq	s5,a4,b270 <_vsnprintf+0x26d0>
    b25c:	8662                	mv	a2,s8
    b25e:	ec46                	sd	a7,24(sp)
    b260:	86a6                	mv	a3,s1
    b262:	85ca                	mv	a1,s2
    b264:	02000513          	li	a0,32
    b268:	6c02                	ld	s8,0(sp)
    b26a:	9402                	jalr	s0
    b26c:	68e2                	ld	a7,24(sp)
    b26e:	0c09                	addi	s8,s8,2
    b270:	8662                	mv	a2,s8
    b272:	ec46                	sd	a7,24(sp)
    b274:	86a6                	mv	a3,s1
    b276:	85ca                	mv	a1,s2
    b278:	02000513          	li	a0,32
    b27c:	9402                	jalr	s0
    b27e:	68e2                	ld	a7,24(sp)
    b280:	0c05                	addi	s8,s8,1
    b282:	8662                	mv	a2,s8
    b284:	ec46                	sd	a7,24(sp)
    b286:	86a6                	mv	a3,s1
    b288:	85ca                	mv	a1,s2
    b28a:	02000513          	li	a0,32
    b28e:	9402                	jalr	s0
    b290:	68e2                	ld	a7,24(sp)
    b292:	0c05                	addi	s8,s8,1
    b294:	8662                	mv	a2,s8
    b296:	ec46                	sd	a7,24(sp)
    b298:	86a6                	mv	a3,s1
    b29a:	85ca                	mv	a1,s2
    b29c:	02000513          	li	a0,32
    b2a0:	9402                	jalr	s0
    b2a2:	68e2                	ld	a7,24(sp)
    b2a4:	0c05                	addi	s8,s8,1
    b2a6:	8662                	mv	a2,s8
    b2a8:	ec46                	sd	a7,24(sp)
    b2aa:	86a6                	mv	a3,s1
    b2ac:	85ca                	mv	a1,s2
    b2ae:	02000513          	li	a0,32
    b2b2:	9402                	jalr	s0
    b2b4:	68e2                	ld	a7,24(sp)
    b2b6:	0c05                	addi	s8,s8,1
    b2b8:	8662                	mv	a2,s8
    b2ba:	ec46                	sd	a7,24(sp)
    b2bc:	86a6                	mv	a3,s1
    b2be:	85ca                	mv	a1,s2
    b2c0:	02000513          	li	a0,32
    b2c4:	9402                	jalr	s0
    b2c6:	68e2                	ld	a7,24(sp)
    b2c8:	0c05                	addi	s8,s8,1
    b2ca:	8662                	mv	a2,s8
    b2cc:	02000513          	li	a0,32
    b2d0:	ec46                	sd	a7,24(sp)
    b2d2:	86a6                	mv	a3,s1
    b2d4:	85ca                	mv	a1,s2
    b2d6:	9402                	jalr	s0
    b2d8:	0c05                	addi	s8,s8,1
    b2da:	018c8533          	add	a0,s9,s8
    b2de:	68e2                	ld	a7,24(sp)
    b2e0:	09757d63          	bgeu	a0,s7,b37a <_vsnprintf+0x27da>
    b2e4:	ec5a                	sd	s6,24(sp)
    b2e6:	f06e                	sd	s11,32(sp)
    b2e8:	8dea                	mv	s11,s10
    b2ea:	8d46                	mv	s10,a7
    b2ec:	8662                	mv	a2,s8
    b2ee:	86a6                	mv	a3,s1
    b2f0:	85ca                	mv	a1,s2
    b2f2:	02000513          	li	a0,32
    b2f6:	9402                	jalr	s0
    b2f8:	001c0a93          	addi	s5,s8,1
    b2fc:	8656                	mv	a2,s5
    b2fe:	86a6                	mv	a3,s1
    b300:	85ca                	mv	a1,s2
    b302:	02000513          	li	a0,32
    b306:	9402                	jalr	s0
    b308:	002c0b13          	addi	s6,s8,2
    b30c:	865a                	mv	a2,s6
    b30e:	86a6                	mv	a3,s1
    b310:	85ca                	mv	a1,s2
    b312:	02000513          	li	a0,32
    b316:	9402                	jalr	s0
    b318:	003c0a93          	addi	s5,s8,3
    b31c:	8656                	mv	a2,s5
    b31e:	86a6                	mv	a3,s1
    b320:	85ca                	mv	a1,s2
    b322:	02000513          	li	a0,32
    b326:	9402                	jalr	s0
    b328:	004c0b13          	addi	s6,s8,4
    b32c:	865a                	mv	a2,s6
    b32e:	86a6                	mv	a3,s1
    b330:	85ca                	mv	a1,s2
    b332:	02000513          	li	a0,32
    b336:	9402                	jalr	s0
    b338:	005c0a93          	addi	s5,s8,5
    b33c:	8656                	mv	a2,s5
    b33e:	86a6                	mv	a3,s1
    b340:	85ca                	mv	a1,s2
    b342:	02000513          	li	a0,32
    b346:	9402                	jalr	s0
    b348:	006c0b13          	addi	s6,s8,6
    b34c:	86a6                	mv	a3,s1
    b34e:	865a                	mv	a2,s6
    b350:	85ca                	mv	a1,s2
    b352:	02000513          	li	a0,32
    b356:	9402                	jalr	s0
    b358:	007c0a93          	addi	s5,s8,7
    b35c:	86a6                	mv	a3,s1
    b35e:	8656                	mv	a2,s5
    b360:	85ca                	mv	a1,s2
    b362:	02000513          	li	a0,32
    b366:	0c21                	addi	s8,s8,8
    b368:	9402                	jalr	s0
    b36a:	018c88b3          	add	a7,s9,s8
    b36e:	f778efe3          	bltu	a7,s7,b2ec <_vsnprintf+0x274c>
    b372:	88ea                	mv	a7,s10
    b374:	8d6e                	mv	s10,s11
    b376:	6b62                	ld	s6,24(sp)
    b378:	7d82                	ld	s11,32(sp)
    b37a:	6302                	ld	t1,0(sp)
    b37c:	fffb8e93          	addi	t4,s7,-1
    b380:	001d0793          	addi	a5,s10,1
    b384:	41ae8f33          	sub	t5,t4,s10
    b388:	00fbb633          	sltu	a2,s7,a5
    b38c:	42c01f0b          	th.mvnez	t5,zero,a2
    b390:	00130e13          	addi	t3,t1,1
    b394:	01cf03b3          	add	t2,t5,t3
    b398:	8e1e                	mv	t3,t2
    b39a:	000d1463          	bnez	s10,b3a2 <_vsnprintf+0x2802>
    b39e:	f37fe06f          	j	a2d4 <_vsnprintf+0x1734>
    b3a2:	03010313          	addi	t1,sp,48
    b3a6:	006d06b3          	add	a3,s10,t1
    b3aa:	fff6c503          	lbu	a0,-1(a3)
    b3ae:	d97fe06f          	j	a144 <_vsnprintf+0x15a4>
    b3b2:	00678023          	sb	t1,0(a5)
    b3b6:	006780a3          	sb	t1,1(a5)
    b3ba:	00678123          	sb	t1,2(a5)
    b3be:	006781a3          	sb	t1,3(a5)
    b3c2:	00678223          	sb	t1,4(a5)
    b3c6:	006782a3          	sb	t1,5(a5)
    b3ca:	00678323          	sb	t1,6(a5)
    b3ce:	006783a3          	sb	t1,7(a5)
    b3d2:	07a1                	addi	a5,a5,8
    b3d4:	fde79fe3          	bne	a5,t5,b3b2 <_vsnprintf+0x2812>
    b3d8:	cf4fe06f          	j	98cc <_vsnprintf+0xd2c>
    b3dc:	002afe93          	andi	t4,s5,2
    b3e0:	4a89                	li	s5,2
    b3e2:	b00e9ce3          	bnez	t4,aefa <_vsnprintf+0x235a>
    b3e6:	41c887bb          	subw	a5,a7,t3
    b3ea:	4a81                	li	s5,0
    b3ec:	b639                	j	aefa <_vsnprintf+0x235a>
    b3ee:	e032                	sd	a2,0(sp)
    b3f0:	a14ff06f          	j	a604 <_vsnprintf+0x1a64>
    b3f4:	060b8263          	beqz	s7,b458 <_vsnprintf+0x28b8>
    b3f8:	000c8463          	beqz	s9,b400 <_vsnprintf+0x2860>
    b3fc:	10c0206f          	j	d508 <_vsnprintf+0x4968>
    b400:	fff78893          	addi	a7,a5,-1
    b404:	8d3e                	mv	s10,a5
    b406:	01fd1463          	bne	s10,t6,b40e <_vsnprintf+0x286e>
    b40a:	4f20306f          	j	e8fc <_vsnprintf+0x5d5c>
    b40e:	00fd1463          	bne	s10,a5,b416 <_vsnprintf+0x2876>
    b412:	0170206f          	j	dc28 <_vsnprintf+0x5088>
    b416:	002d0633          	add	a2,s10,sp
    b41a:	05800393          	li	t2,88
    b41e:	001d0793          	addi	a5,s10,1
    b422:	02760823          	sb	t2,48(a2)
    b426:	4b81                	li	s7,0
    b428:	00178d13          	addi	s10,a5,1
    b42c:	00278833          	add	a6,a5,sp
    b430:	03000c93          	li	s9,48
    b434:	03980823          	sb	s9,48(a6)
    b438:	02000f93          	li	t6,32
    b43c:	c5fd0c63          	beq	s10,t6,a894 <_vsnprintf+0x1cf4>
    b440:	0045f513          	andi	a0,a1,4
    b444:	c119                	beqz	a0,b44a <_vsnprintf+0x28aa>
    b446:	0090206f          	j	dc4e <_vsnprintf+0x50ae>
    b44a:	0085f313          	andi	t1,a1,8
    b44e:	02030c63          	beqz	t1,b486 <_vsnprintf+0x28e6>
    b452:	87ea                	mv	a5,s10
    b454:	a829                	j	b46e <_vsnprintf+0x28ce>
    b456:	0001                	nop
    b458:	0045fb93          	andi	s7,a1,4
    b45c:	000b8463          	beqz	s7,b464 <_vsnprintf+0x28c4>
    b460:	27c0206f          	j	d6dc <_vsnprintf+0x4b3c>
    b464:	0085fc93          	andi	s9,a1,8
    b468:	000c8d63          	beqz	s9,b482 <_vsnprintf+0x28e2>
    b46c:	4b81                	li	s7,0
    b46e:	00278e33          	add	t3,a5,sp
    b472:	02000513          	li	a0,32
    b476:	00178d13          	addi	s10,a5,1
    b47a:	02ae0823          	sb	a0,48(t3)
    b47e:	c1eff06f          	j	a89c <_vsnprintf+0x1cfc>
    b482:	8d3e                	mv	s10,a5
    b484:	4b81                	li	s7,0
    b486:	020d0813          	addi	a6,s10,32
    b48a:	03010c93          	addi	s9,sp,48
    b48e:	01980fb3          	add	t6,a6,s9
    b492:	fdffc503          	lbu	a0,-33(t6)
    b496:	c06ff06f          	j	a89c <_vsnprintf+0x1cfc>
    b49a:	87c6                	mv	a5,a7
    b49c:	8b6a                	mv	s6,s10
    b49e:	4d81                	li	s11,0
    b4a0:	4e01                	li	t3,0
    b4a2:	f2068553          	fmv.d.x	fa0,a3
    b4a6:	22a515d3          	fneg.d	fa1,fa0
    b4aa:	e20586d3          	fmv.x.d	a3,fa1
    b4ae:	a18fe06f          	j	96c6 <_vsnprintf+0xb26>
    b4b2:	8aee                	mv	s5,s11
    b4b4:	788acd8b          	th.ldia	s11,(s5),8,0
    b4b8:	010ffd13          	andi	s10,t6,16
    b4bc:	000d9963          	bnez	s11,b4ce <_vsnprintf+0x292e>
    b4c0:	fefffe13          	andi	t3,t6,-17
    b4c4:	000e061b          	sext.w	a2,t3
    b4c8:	040b92e3          	bnez	s7,bd0c <_vsnprintf+0x316c>
    b4cc:	4d01                	li	s10,0
    b4ce:	1456328b          	th.extu	t0,a2,5,5
    b4d2:	fff28f93          	addi	t6,t0,-1
    b4d6:	020fff13          	andi	t5,t6,32
    b4da:	037f051b          	addiw	a0,t5,55
    b4de:	02fddf33          	divu	t5,s11,a5
    b4e2:	876e                	mv	a4,s11
    b4e4:	43a5                	li	t2,9
    b4e6:	03010813          	addi	a6,sp,48
    b4ea:	85c2                	mv	a1,a6
    b4ec:	22ff170b          	th.muls	a4,t5,a5
    b4f0:	0ff77e93          	zext.b	t4,a4
    b4f4:	030e831b          	addiw	t1,t4,48
    b4f8:	01d50cbb          	addw	s9,a0,t4
    b4fc:	0ff37b13          	zext.b	s6,t1
    b500:	0ffcfe13          	zext.b	t3,s9
    b504:	00e3b2b3          	sltu	t0,t2,a4
    b508:	405b1e0b          	th.mveqz	t3,s6,t0
    b50c:	03c10823          	sb	t3,48(sp)
    b510:	64fdeb63          	bltu	s11,a5,bb66 <_vsnprintf+0x2fc6>
    b514:	03110593          	addi	a1,sp,49
    b518:	02ff5db3          	divu	s11,t5,a5
    b51c:	8efa                	mv	t4,t5
    b51e:	22fd9e8b          	th.muls	t4,s11,a5
    b522:	0ffef713          	zext.b	a4,t4
    b526:	03070f9b          	addiw	t6,a4,48
    b52a:	00e5033b          	addw	t1,a0,a4
    b52e:	0ffffb13          	zext.b	s6,t6
    b532:	0ff37c93          	zext.b	s9,t1
    b536:	01d3be33          	sltu	t3,t2,t4
    b53a:	41cb1c8b          	th.mveqz	s9,s6,t3
    b53e:	01958023          	sb	s9,0(a1)
    b542:	62ff6263          	bltu	t5,a5,bb66 <_vsnprintf+0x2fc6>
    b546:	00158b13          	addi	s6,a1,1
    b54a:	05010f13          	addi	t5,sp,80
    b54e:	616f0c63          	beq	t5,s6,bb66 <_vsnprintf+0x2fc6>
    b552:	02fdd333          	divu	t1,s11,a5
    b556:	8eee                	mv	t4,s11
    b558:	85da                	mv	a1,s6
    b55a:	22f31e8b          	th.muls	t4,t1,a5
    b55e:	0ffef713          	zext.b	a4,t4
    b562:	0307029b          	addiw	t0,a4,48
    b566:	00e50fbb          	addw	t6,a0,a4
    b56a:	0ff2fc93          	zext.b	s9,t0
    b56e:	0ffffe13          	zext.b	t3,t6
    b572:	01d3bf33          	sltu	t5,t2,t4
    b576:	41ec9e0b          	th.mveqz	t3,s9,t5
    b57a:	01cb0023          	sb	t3,0(s6)
    b57e:	5efde463          	bltu	s11,a5,bb66 <_vsnprintf+0x2fc6>
    b582:	02f35db3          	divu	s11,t1,a5
    b586:	8e9a                	mv	t4,t1
    b588:	22fd9e8b          	th.muls	t4,s11,a5
    b58c:	0ffef713          	zext.b	a4,t4
    b590:	0307029b          	addiw	t0,a4,48
    b594:	00e50fbb          	addw	t6,a0,a4
    b598:	0ff2fc93          	zext.b	s9,t0
    b59c:	0ffffe13          	zext.b	t3,t6
    b5a0:	01d3bf33          	sltu	t5,t2,t4
    b5a4:	41ec9e0b          	th.mveqz	t3,s9,t5
    b5a8:	0815de0b          	th.sbib	t3,(a1),1,0
    b5ac:	5af36d63          	bltu	t1,a5,bb66 <_vsnprintf+0x2fc6>
    b5b0:	02fdd333          	divu	t1,s11,a5
    b5b4:	8eee                	mv	t4,s11
    b5b6:	002b0593          	addi	a1,s6,2
    b5ba:	22f31e8b          	th.muls	t4,t1,a5
    b5be:	0ffef713          	zext.b	a4,t4
    b5c2:	0307029b          	addiw	t0,a4,48
    b5c6:	00e50fbb          	addw	t6,a0,a4
    b5ca:	0ff2fc93          	zext.b	s9,t0
    b5ce:	0ffffe13          	zext.b	t3,t6
    b5d2:	01d3bf33          	sltu	t5,t2,t4
    b5d6:	41ec9e0b          	th.mveqz	t3,s9,t5
    b5da:	01cb0123          	sb	t3,2(s6)
    b5de:	58fde463          	bltu	s11,a5,bb66 <_vsnprintf+0x2fc6>
    b5e2:	02f35db3          	divu	s11,t1,a5
    b5e6:	8e9a                	mv	t4,t1
    b5e8:	003b0593          	addi	a1,s6,3
    b5ec:	22fd9e8b          	th.muls	t4,s11,a5
    b5f0:	0ffef713          	zext.b	a4,t4
    b5f4:	0307029b          	addiw	t0,a4,48
    b5f8:	00e50fbb          	addw	t6,a0,a4
    b5fc:	0ff2fc93          	zext.b	s9,t0
    b600:	0ffffe13          	zext.b	t3,t6
    b604:	01d3bf33          	sltu	t5,t2,t4
    b608:	41ec9e0b          	th.mveqz	t3,s9,t5
    b60c:	01cb01a3          	sb	t3,3(s6)
    b610:	54f36b63          	bltu	t1,a5,bb66 <_vsnprintf+0x2fc6>
    b614:	004b0593          	addi	a1,s6,4
    b618:	8f6e                	mv	t5,s11
    b61a:	bdfd                	j	b518 <_vsnprintf+0x2978>
    b61c:	410607b3          	sub	a5,a2,a6
    b620:	002e7c93          	andi	s9,t3,2
    b624:	00178713          	addi	a4,a5,1
    b628:	8672                	mv	a2,t3
    b62a:	000c9463          	bnez	s9,b632 <_vsnprintf+0x2a92>
    b62e:	7d20106f          	j	ce00 <_vsnprintf+0x4260>
    b632:	000e8463          	beqz	t4,b63a <_vsnprintf+0x2a9a>
    b636:	30e0206f          	j	d944 <_vsnprintf+0x4da4>
    b63a:	02000e13          	li	t3,32
    b63e:	4d09                	li	s10,2
    b640:	01c70463          	beq	a4,t3,b648 <_vsnprintf+0x2aa8>
    b644:	7510206f          	j	e594 <_vsnprintf+0x59f4>
    b648:	6e02                	ld	t3,0(sp)
    b64a:	02000713          	li	a4,32
    b64e:	01c70bb3          	add	s7,a4,t3
    b652:	00e80c33          	add	s8,a6,a4
    b656:	8b1d                	andi	a4,a4,7
    b658:	01780b33          	add	s6,a6,s7
    b65c:	c761                	beqz	a4,b724 <_vsnprintf+0x2b84>
    b65e:	4505                	li	a0,1
    b660:	0aa70363          	beq	a4,a0,b706 <_vsnprintf+0x2b66>
    b664:	4309                	li	t1,2
    b666:	08670563          	beq	a4,t1,b6f0 <_vsnprintf+0x2b50>
    b66a:	428d                	li	t0,3
    b66c:	06570763          	beq	a4,t0,b6da <_vsnprintf+0x2b3a>
    b670:	4391                	li	t2,4
    b672:	04770963          	beq	a4,t2,b6c4 <_vsnprintf+0x2b24>
    b676:	4f15                	li	t5,5
    b678:	03e70b63          	beq	a4,t5,b6ae <_vsnprintf+0x2b0e>
    b67c:	4699                	li	a3,6
    b67e:	00d70d63          	beq	a4,a3,b698 <_vsnprintf+0x2af8>
    b682:	418b0633          	sub	a2,s6,s8
    b686:	89fc450b          	th.lbuib	a0,(s8),-1,0
    b68a:	ec46                	sd	a7,24(sp)
    b68c:	f042                	sd	a6,32(sp)
    b68e:	86a6                	mv	a3,s1
    b690:	85ca                	mv	a1,s2
    b692:	9402                	jalr	s0
    b694:	68e2                	ld	a7,24(sp)
    b696:	7802                	ld	a6,32(sp)
    b698:	418b0633          	sub	a2,s6,s8
    b69c:	89fc450b          	th.lbuib	a0,(s8),-1,0
    b6a0:	ec46                	sd	a7,24(sp)
    b6a2:	f042                	sd	a6,32(sp)
    b6a4:	86a6                	mv	a3,s1
    b6a6:	85ca                	mv	a1,s2
    b6a8:	9402                	jalr	s0
    b6aa:	68e2                	ld	a7,24(sp)
    b6ac:	7802                	ld	a6,32(sp)
    b6ae:	418b0633          	sub	a2,s6,s8
    b6b2:	89fc450b          	th.lbuib	a0,(s8),-1,0
    b6b6:	ec46                	sd	a7,24(sp)
    b6b8:	f042                	sd	a6,32(sp)
    b6ba:	86a6                	mv	a3,s1
    b6bc:	85ca                	mv	a1,s2
    b6be:	9402                	jalr	s0
    b6c0:	68e2                	ld	a7,24(sp)
    b6c2:	7802                	ld	a6,32(sp)
    b6c4:	418b0633          	sub	a2,s6,s8
    b6c8:	89fc450b          	th.lbuib	a0,(s8),-1,0
    b6cc:	ec46                	sd	a7,24(sp)
    b6ce:	f042                	sd	a6,32(sp)
    b6d0:	86a6                	mv	a3,s1
    b6d2:	85ca                	mv	a1,s2
    b6d4:	9402                	jalr	s0
    b6d6:	68e2                	ld	a7,24(sp)
    b6d8:	7802                	ld	a6,32(sp)
    b6da:	418b0633          	sub	a2,s6,s8
    b6de:	89fc450b          	th.lbuib	a0,(s8),-1,0
    b6e2:	ec46                	sd	a7,24(sp)
    b6e4:	f042                	sd	a6,32(sp)
    b6e6:	86a6                	mv	a3,s1
    b6e8:	85ca                	mv	a1,s2
    b6ea:	9402                	jalr	s0
    b6ec:	68e2                	ld	a7,24(sp)
    b6ee:	7802                	ld	a6,32(sp)
    b6f0:	418b0633          	sub	a2,s6,s8
    b6f4:	89fc450b          	th.lbuib	a0,(s8),-1,0
    b6f8:	ec46                	sd	a7,24(sp)
    b6fa:	f042                	sd	a6,32(sp)
    b6fc:	86a6                	mv	a3,s1
    b6fe:	85ca                	mv	a1,s2
    b700:	9402                	jalr	s0
    b702:	68e2                	ld	a7,24(sp)
    b704:	7802                	ld	a6,32(sp)
    b706:	418b0633          	sub	a2,s6,s8
    b70a:	89fc450b          	th.lbuib	a0,(s8),-1,0
    b70e:	fd01588b          	th.sdd	a7,a6,(sp),2,4
    b712:	86a6                	mv	a3,s1
    b714:	85ca                	mv	a1,s2
    b716:	ec5e                	sd	s7,24(sp)
    b718:	9402                	jalr	s0
    b71a:	fd01488b          	th.ldd	a7,a6,(sp),2,4
    b71e:	6e62                	ld	t3,24(sp)
    b720:	09880963          	beq	a6,s8,b7b2 <_vsnprintf+0x2c12>
    b724:	ec6a                	sd	s10,24(sp)
    b726:	f046                	sd	a7,32(sp)
    b728:	8d42                	mv	s10,a6
    b72a:	8ae2                	mv	s5,s8
    b72c:	89fac50b          	th.lbuib	a0,(s5),-1,0
    b730:	418b0633          	sub	a2,s6,s8
    b734:	86a6                	mv	a3,s1
    b736:	85ca                	mv	a1,s2
    b738:	9402                	jalr	s0
    b73a:	8ce2                	mv	s9,s8
    b73c:	89ecc50b          	th.lbuib	a0,(s9),-2,0
    b740:	415b0633          	sub	a2,s6,s5
    b744:	86a6                	mv	a3,s1
    b746:	85ca                	mv	a1,s2
    b748:	9402                	jalr	s0
    b74a:	8ae2                	mv	s5,s8
    b74c:	89dac50b          	th.lbuib	a0,(s5),-3,0
    b750:	419b0633          	sub	a2,s6,s9
    b754:	86a6                	mv	a3,s1
    b756:	85ca                	mv	a1,s2
    b758:	9402                	jalr	s0
    b75a:	8ce2                	mv	s9,s8
    b75c:	89ccc50b          	th.lbuib	a0,(s9),-4,0
    b760:	415b0633          	sub	a2,s6,s5
    b764:	86a6                	mv	a3,s1
    b766:	85ca                	mv	a1,s2
    b768:	9402                	jalr	s0
    b76a:	8ae2                	mv	s5,s8
    b76c:	89bac50b          	th.lbuib	a0,(s5),-5,0
    b770:	419b0633          	sub	a2,s6,s9
    b774:	86a6                	mv	a3,s1
    b776:	85ca                	mv	a1,s2
    b778:	9402                	jalr	s0
    b77a:	8ce2                	mv	s9,s8
    b77c:	89acc50b          	th.lbuib	a0,(s9),-6,0
    b780:	415b0633          	sub	a2,s6,s5
    b784:	86a6                	mv	a3,s1
    b786:	85ca                	mv	a1,s2
    b788:	9402                	jalr	s0
    b78a:	8ae2                	mv	s5,s8
    b78c:	899ac50b          	th.lbuib	a0,(s5),-7,0
    b790:	86a6                	mv	a3,s1
    b792:	419b0633          	sub	a2,s6,s9
    b796:	85ca                	mv	a1,s2
    b798:	9402                	jalr	s0
    b79a:	898c450b          	th.lbuib	a0,(s8),-8,0
    b79e:	86a6                	mv	a3,s1
    b7a0:	415b0633          	sub	a2,s6,s5
    b7a4:	85ca                	mv	a1,s2
    b7a6:	9402                	jalr	s0
    b7a8:	f98d11e3          	bne	s10,s8,b72a <_vsnprintf+0x2b8a>
    b7ac:	6d62                	ld	s10,24(sp)
    b7ae:	7882                	ld	a7,32(sp)
    b7b0:	8e5e                	mv	t3,s7
    b7b2:	000d1463          	bnez	s10,b7ba <_vsnprintf+0x2c1a>
    b7b6:	ca7fe06f          	j	a45c <_vsnprintf+0x18bc>
    b7ba:	7c08bc0b          	th.extu	s8,a7,31,0
    b7be:	6882                	ld	a7,0(sp)
    b7c0:	411e0ab3          	sub	s5,t3,a7
    b7c4:	018ae463          	bltu	s5,s8,b7cc <_vsnprintf+0x2c2c>
    b7c8:	c95fe06f          	j	a45c <_vsnprintf+0x18bc>
    b7cc:	fffac593          	not	a1,s5
    b7d0:	01858633          	add	a2,a1,s8
    b7d4:	00767b93          	andi	s7,a2,7
    b7d8:	86a6                	mv	a3,s1
    b7da:	8672                	mv	a2,t3
    b7dc:	85ca                	mv	a1,s2
    b7de:	02000513          	li	a0,32
    b7e2:	e072                	sd	t3,0(sp)
    b7e4:	001e0b13          	addi	s6,t3,1
    b7e8:	001a8d13          	addi	s10,s5,1
    b7ec:	9402                	jalr	s0
    b7ee:	6782                	ld	a5,0(sp)
    b7f0:	018d6463          	bltu	s10,s8,b7f8 <_vsnprintf+0x2c58>
    b7f4:	c7dfe06f          	j	a470 <_vsnprintf+0x18d0>
    b7f8:	0a0b8263          	beqz	s7,b89c <_vsnprintf+0x2cfc>
    b7fc:	4e85                	li	t4,1
    b7fe:	09db8363          	beq	s7,t4,b884 <_vsnprintf+0x2ce4>
    b802:	4709                	li	a4,2
    b804:	06eb8863          	beq	s7,a4,b874 <_vsnprintf+0x2cd4>
    b808:	450d                	li	a0,3
    b80a:	04ab8d63          	beq	s7,a0,b864 <_vsnprintf+0x2cc4>
    b80e:	4311                	li	t1,4
    b810:	046b8263          	beq	s7,t1,b854 <_vsnprintf+0x2cb4>
    b814:	4295                	li	t0,5
    b816:	025b8763          	beq	s7,t0,b844 <_vsnprintf+0x2ca4>
    b81a:	4399                	li	t2,6
    b81c:	007b8c63          	beq	s7,t2,b834 <_vsnprintf+0x2c94>
    b820:	865a                	mv	a2,s6
    b822:	86a6                	mv	a3,s1
    b824:	85ca                	mv	a1,s2
    b826:	02000513          	li	a0,32
    b82a:	00278b13          	addi	s6,a5,2
    b82e:	002a8d13          	addi	s10,s5,2
    b832:	9402                	jalr	s0
    b834:	865a                	mv	a2,s6
    b836:	86a6                	mv	a3,s1
    b838:	85ca                	mv	a1,s2
    b83a:	02000513          	li	a0,32
    b83e:	0b05                	addi	s6,s6,1
    b840:	9402                	jalr	s0
    b842:	0d05                	addi	s10,s10,1
    b844:	865a                	mv	a2,s6
    b846:	86a6                	mv	a3,s1
    b848:	85ca                	mv	a1,s2
    b84a:	02000513          	li	a0,32
    b84e:	0b05                	addi	s6,s6,1
    b850:	9402                	jalr	s0
    b852:	0d05                	addi	s10,s10,1
    b854:	865a                	mv	a2,s6
    b856:	86a6                	mv	a3,s1
    b858:	85ca                	mv	a1,s2
    b85a:	02000513          	li	a0,32
    b85e:	0b05                	addi	s6,s6,1
    b860:	9402                	jalr	s0
    b862:	0d05                	addi	s10,s10,1
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
    b88e:	0d05                	addi	s10,s10,1
    b890:	0b05                	addi	s6,s6,1
    b892:	9402                	jalr	s0
    b894:	018d6463          	bltu	s10,s8,b89c <_vsnprintf+0x2cfc>
    b898:	bd9fe06f          	j	a470 <_vsnprintf+0x18d0>
    b89c:	865a                	mv	a2,s6
    b89e:	86a6                	mv	a3,s1
    b8a0:	85ca                	mv	a1,s2
    b8a2:	02000513          	li	a0,32
    b8a6:	9402                	jalr	s0
    b8a8:	001b0c93          	addi	s9,s6,1
    b8ac:	8666                	mv	a2,s9
    b8ae:	86a6                	mv	a3,s1
    b8b0:	85ca                	mv	a1,s2
    b8b2:	02000513          	li	a0,32
    b8b6:	9402                	jalr	s0
    b8b8:	002b0b93          	addi	s7,s6,2
    b8bc:	865e                	mv	a2,s7
    b8be:	86a6                	mv	a3,s1
    b8c0:	85ca                	mv	a1,s2
    b8c2:	02000513          	li	a0,32
    b8c6:	9402                	jalr	s0
    b8c8:	003b0a93          	addi	s5,s6,3
    b8cc:	8656                	mv	a2,s5
    b8ce:	86a6                	mv	a3,s1
    b8d0:	85ca                	mv	a1,s2
    b8d2:	02000513          	li	a0,32
    b8d6:	9402                	jalr	s0
    b8d8:	004b0c93          	addi	s9,s6,4
    b8dc:	8666                	mv	a2,s9
    b8de:	86a6                	mv	a3,s1
    b8e0:	85ca                	mv	a1,s2
    b8e2:	02000513          	li	a0,32
    b8e6:	9402                	jalr	s0
    b8e8:	005b0a93          	addi	s5,s6,5
    b8ec:	86a6                	mv	a3,s1
    b8ee:	8656                	mv	a2,s5
    b8f0:	85ca                	mv	a1,s2
    b8f2:	02000513          	li	a0,32
    b8f6:	9402                	jalr	s0
    b8f8:	006b0b93          	addi	s7,s6,6
    b8fc:	86a6                	mv	a3,s1
    b8fe:	865e                	mv	a2,s7
    b900:	85ca                	mv	a1,s2
    b902:	02000513          	li	a0,32
    b906:	9402                	jalr	s0
    b908:	007b0c93          	addi	s9,s6,7
    b90c:	86a6                	mv	a3,s1
    b90e:	8666                	mv	a2,s9
    b910:	85ca                	mv	a1,s2
    b912:	02000513          	li	a0,32
    b916:	0d21                	addi	s10,s10,8
    b918:	0b21                	addi	s6,s6,8
    b91a:	9402                	jalr	s0
    b91c:	f98d60e3          	bltu	s10,s8,b89c <_vsnprintf+0x2cfc>
    b920:	b51fe06f          	j	a470 <_vsnprintf+0x18d0>
    b924:	e056                	sd	s5,0(sp)
    b926:	b53fe06f          	j	a478 <_vsnprintf+0x18d8>
    b92a:	000c8463          	beqz	s9,b932 <_vsnprintf+0x2d92>
    b92e:	7620106f          	j	d090 <_vsnprintf+0x44f0>
    b932:	47c1                	li	a5,16
    b934:	48bd                	li	a7,15
    b936:	8d3e                	mv	s10,a5
    b938:	b4f9                	j	b406 <_vsnprintf+0x2866>
    b93a:	40000a93          	li	s5,1024
    b93e:	011be463          	bltu	s7,a7,b946 <_vsnprintf+0x2da6>
    b942:	0950206f          	j	e1d6 <_vsnprintf+0x5636>
    b946:	6e82                	ld	t4,0(sp)
    b948:	fff8851b          	addiw	a0,a7,-1
    b94c:	41750bbb          	subw	s7,a0,s7
    b950:	7c0bbe0b          	th.extu	t3,s7,31,0
    b954:	001e8b13          	addi	s6,t4,1
    b958:	007e7c93          	andi	s9,t3,7
    b95c:	016e07b3          	add	a5,t3,s6
    b960:	000c9463          	bnez	s9,b968 <_vsnprintf+0x2dc8>
    b964:	6e00106f          	j	d044 <_vsnprintf+0x44a4>
    b968:	6602                	ld	a2,0(sp)
    b96a:	ec46                	sd	a7,24(sp)
    b96c:	f03e                	sd	a5,32(sp)
    b96e:	e05a                	sd	s6,0(sp)
    b970:	86a6                	mv	a3,s1
    b972:	85ca                	mv	a1,s2
    b974:	02000513          	li	a0,32
    b978:	9402                	jalr	s0
    b97a:	4285                	li	t0,1
    b97c:	68e2                	ld	a7,24(sp)
    b97e:	7782                	ld	a5,32(sp)
    b980:	865a                	mv	a2,s6
    b982:	0b05                	addi	s6,s6,1
    b984:	005c9463          	bne	s9,t0,b98c <_vsnprintf+0x2dec>
    b988:	6bc0106f          	j	d044 <_vsnprintf+0x44a4>
    b98c:	4689                	li	a3,2
    b98e:	08dc8763          	beq	s9,a3,ba1c <_vsnprintf+0x2e7c>
    b992:	430d                	li	t1,3
    b994:	066c8863          	beq	s9,t1,ba04 <_vsnprintf+0x2e64>
    b998:	4391                	li	t2,4
    b99a:	047c8963          	beq	s9,t2,b9ec <_vsnprintf+0x2e4c>
    b99e:	4f15                	li	t5,5
    b9a0:	03ec8a63          	beq	s9,t5,b9d4 <_vsnprintf+0x2e34>
    b9a4:	4599                	li	a1,6
    b9a6:	00bc8b63          	beq	s9,a1,b9bc <_vsnprintf+0x2e1c>
    b9aa:	e05a                	sd	s6,0(sp)
    b9ac:	86a6                	mv	a3,s1
    b9ae:	85ca                	mv	a1,s2
    b9b0:	02000513          	li	a0,32
    b9b4:	9402                	jalr	s0
    b9b6:	68e2                	ld	a7,24(sp)
    b9b8:	7782                	ld	a5,32(sp)
    b9ba:	0b05                	addi	s6,s6,1
    b9bc:	6602                	ld	a2,0(sp)
    b9be:	ec46                	sd	a7,24(sp)
    b9c0:	f03e                	sd	a5,32(sp)
    b9c2:	e05a                	sd	s6,0(sp)
    b9c4:	86a6                	mv	a3,s1
    b9c6:	85ca                	mv	a1,s2
    b9c8:	02000513          	li	a0,32
    b9cc:	9402                	jalr	s0
    b9ce:	68e2                	ld	a7,24(sp)
    b9d0:	7782                	ld	a5,32(sp)
    b9d2:	0b05                	addi	s6,s6,1
    b9d4:	6602                	ld	a2,0(sp)
    b9d6:	ec46                	sd	a7,24(sp)
    b9d8:	f03e                	sd	a5,32(sp)
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
    ba22:	86a6                	mv	a3,s1
    ba24:	85ca                	mv	a1,s2
    ba26:	02000513          	li	a0,32
    ba2a:	9402                	jalr	s0
    ba2c:	8bda                	mv	s7,s6
    ba2e:	7c82                	ld	s9,32(sp)
    ba30:	0b05                	addi	s6,s6,1
    ba32:	f056                	sd	s5,32(sp)
    ba34:	a895                	j	baa8 <_vsnprintf+0x2f08>
    ba36:	865a                	mv	a2,s6
    ba38:	86a6                	mv	a3,s1
    ba3a:	85ca                	mv	a1,s2
    ba3c:	02000513          	li	a0,32
    ba40:	9402                	jalr	s0
    ba42:	001b0b93          	addi	s7,s6,1
    ba46:	865e                	mv	a2,s7
    ba48:	86a6                	mv	a3,s1
    ba4a:	85ca                	mv	a1,s2
    ba4c:	02000513          	li	a0,32
    ba50:	9402                	jalr	s0
    ba52:	002b0a93          	addi	s5,s6,2
    ba56:	8656                	mv	a2,s5
    ba58:	86a6                	mv	a3,s1
    ba5a:	85ca                	mv	a1,s2
    ba5c:	02000513          	li	a0,32
    ba60:	9402                	jalr	s0
    ba62:	003b0b93          	addi	s7,s6,3
    ba66:	865e                	mv	a2,s7
    ba68:	86a6                	mv	a3,s1
    ba6a:	85ca                	mv	a1,s2
    ba6c:	02000513          	li	a0,32
    ba70:	9402                	jalr	s0
    ba72:	004b0a93          	addi	s5,s6,4
    ba76:	8656                	mv	a2,s5
    ba78:	86a6                	mv	a3,s1
    ba7a:	85ca                	mv	a1,s2
    ba7c:	02000513          	li	a0,32
    ba80:	9402                	jalr	s0
    ba82:	005b0b93          	addi	s7,s6,5
    ba86:	865e                	mv	a2,s7
    ba88:	86a6                	mv	a3,s1
    ba8a:	85ca                	mv	a1,s2
    ba8c:	02000513          	li	a0,32
    ba90:	9402                	jalr	s0
    ba92:	006b0a93          	addi	s5,s6,6
    ba96:	86a6                	mv	a3,s1
    ba98:	8656                	mv	a2,s5
    ba9a:	85ca                	mv	a1,s2
    ba9c:	02000513          	li	a0,32
    baa0:	007b0b93          	addi	s7,s6,7
    baa4:	9402                	jalr	s0
    baa6:	0b21                	addi	s6,s6,8
    baa8:	865e                	mv	a2,s7
    baaa:	86a6                	mv	a3,s1
    baac:	85ca                	mv	a1,s2
    baae:	02000513          	li	a0,32
    bab2:	9402                	jalr	s0
    bab4:	f99b11e3          	bne	s6,s9,ba36 <_vsnprintf+0x2e96>
    bab8:	68e2                	ld	a7,24(sp)
    baba:	7a82                	ld	s5,32(sp)
    babc:	000d4503          	lbu	a0,0(s10)
    bac0:	e05a                	sd	s6,0(sp)
    bac2:	00188b9b          	addiw	s7,a7,1
    bac6:	e119                	bnez	a0,bacc <_vsnprintf+0x2f2c>
    bac8:	9b1fe06f          	j	a478 <_vsnprintf+0x18d8>
    bacc:	000a9463          	bnez	s5,bad4 <_vsnprintf+0x2f34>
    bad0:	b79fe06f          	j	a648 <_vsnprintf+0x1aa8>
    bad4:	4a81                	li	s5,0
    bad6:	e8cfd06f          	j	9162 <_vsnprintf+0x5c2>
    bada:	400b7b93          	andi	s7,s6,1024
    bade:	000b8463          	beqz	s7,bae6 <_vsnprintf+0x2f46>
    bae2:	1aa0206f          	j	dc8c <_vsnprintf+0x50ec>
    bae6:	002b7e13          	andi	t3,s6,2
    baea:	000e0463          	beqz	t3,baf2 <_vsnprintf+0x2f52>
    baee:	845fd06f          	j	9332 <_vsnprintf+0x792>
    baf2:	4a81                	li	s5,0
    baf4:	e51be9e3          	bltu	s7,a7,b946 <_vsnprintf+0x2da6>
    baf8:	6c82                	ld	s9,0(sp)
    bafa:	2b85                	addiw	s7,s7,1
    bafc:	c119                	beqz	a0,bb02 <_vsnprintf+0x2f62>
    bafe:	b4bfe06f          	j	a648 <_vsnprintf+0x1aa8>
    bb02:	977fe06f          	j	a478 <_vsnprintf+0x18d8>
    bb06:	0001                	nop
    bb08:	fff7081b          	addiw	a6,a4,-1
    bb0c:	41f7180b          	th.mveqz	a6,a4,t6
    bb10:	41c887bb          	subw	a5,a7,t3
    bb14:	011e32b3          	sltu	t0,t3,a7
    bb18:	002b7313          	andi	t1,s6,2
    bb1c:	42e8170b          	th.mvnez	a4,a6,a4
    bb20:	4050178b          	th.mveqz	a5,zero,t0
    bb24:	8c0303e3          	beqz	t1,b3ea <_vsnprintf+0x284a>
    bb28:	4a89                	li	s5,2
    bb2a:	4781                	li	a5,0
    bb2c:	bceff06f          	j	aefa <_vsnprintf+0x235a>
    bb30:	fefb7593          	andi	a1,s6,-17
    bb34:	06900613          	li	a2,105
    bb38:	8f5a                	mv	t5,s6
    bb3a:	2581                	sext.w	a1,a1
    bb3c:	00c50463          	beq	a0,a2,bb44 <_vsnprintf+0x2fa4>
    bb40:	1f50106f          	j	d534 <_vsnprintf+0x4994>
    bb44:	400b7713          	andi	a4,s6,1024
    bb48:	c319                	beqz	a4,bb4e <_vsnprintf+0x2fae>
    bb4a:	f25fe06f          	j	aa6e <_vsnprintf+0x1ece>
    bb4e:	200f7813          	andi	a6,t5,512
    bb52:	56081963          	bnez	a6,c0c4 <_vsnprintf+0x3524>
    bb56:	100f7e93          	andi	t4,t5,256
    bb5a:	000e9463          	bnez	t4,bb62 <_vsnprintf+0x2fc2>
    bb5e:	f33fe06f          	j	aa90 <_vsnprintf+0x1ef0>
    bb62:	c70fe06f          	j	9fd2 <_vsnprintf+0x1432>
    bb66:	410587b3          	sub	a5,a1,a6
    bb6a:	00267393          	andi	t2,a2,2
    bb6e:	00178d93          	addi	s11,a5,1
    bb72:	85b2                	mv	a1,a2
    bb74:	00039463          	bnez	t2,bb7c <_vsnprintf+0x2fdc>
    bb78:	7840106f          	j	d2fc <_vsnprintf+0x475c>
    bb7c:	000d0463          	beqz	s10,bb84 <_vsnprintf+0x2fe4>
    bb80:	1840206f          	j	dd04 <_vsnprintf+0x5164>
    bb84:	02000c13          	li	s8,32
    bb88:	4d09                	li	s10,2
    bb8a:	018d8463          	beq	s11,s8,bb92 <_vsnprintf+0x2ff2>
    bb8e:	1990206f          	j	e526 <_vsnprintf+0x5986>
    bb92:	6682                	ld	a3,0(sp)
    bb94:	02000d93          	li	s11,32
    bb98:	00dd8bb3          	add	s7,s11,a3
    bb9c:	007df713          	andi	a4,s11,7
    bba0:	01b80c33          	add	s8,a6,s11
    bba4:	01780b33          	add	s6,a6,s7
    bba8:	c379                	beqz	a4,bc6e <_vsnprintf+0x30ce>
    bbaa:	4f85                	li	t6,1
    bbac:	0bf70363          	beq	a4,t6,bc52 <_vsnprintf+0x30b2>
    bbb0:	4689                	li	a3,2
    bbb2:	08d70563          	beq	a4,a3,bc3c <_vsnprintf+0x309c>
    bbb6:	4f0d                	li	t5,3
    bbb8:	07e70763          	beq	a4,t5,bc26 <_vsnprintf+0x3086>
    bbbc:	4791                	li	a5,4
    bbbe:	04f70963          	beq	a4,a5,bc10 <_vsnprintf+0x3070>
    bbc2:	4395                	li	t2,5
    bbc4:	02770b63          	beq	a4,t2,bbfa <_vsnprintf+0x305a>
    bbc8:	4319                	li	t1,6
    bbca:	00670d63          	beq	a4,t1,bbe4 <_vsnprintf+0x3044>
    bbce:	418b0633          	sub	a2,s6,s8
    bbd2:	89fc450b          	th.lbuib	a0,(s8),-1,0
    bbd6:	ec46                	sd	a7,24(sp)
    bbd8:	f042                	sd	a6,32(sp)
    bbda:	86a6                	mv	a3,s1
    bbdc:	85ca                	mv	a1,s2
    bbde:	9402                	jalr	s0
    bbe0:	68e2                	ld	a7,24(sp)
    bbe2:	7802                	ld	a6,32(sp)
    bbe4:	418b0633          	sub	a2,s6,s8
    bbe8:	89fc450b          	th.lbuib	a0,(s8),-1,0
    bbec:	ec46                	sd	a7,24(sp)
    bbee:	f042                	sd	a6,32(sp)
    bbf0:	86a6                	mv	a3,s1
    bbf2:	85ca                	mv	a1,s2
    bbf4:	9402                	jalr	s0
    bbf6:	68e2                	ld	a7,24(sp)
    bbf8:	7802                	ld	a6,32(sp)
    bbfa:	418b0633          	sub	a2,s6,s8
    bbfe:	89fc450b          	th.lbuib	a0,(s8),-1,0
    bc02:	ec46                	sd	a7,24(sp)
    bc04:	f042                	sd	a6,32(sp)
    bc06:	86a6                	mv	a3,s1
    bc08:	85ca                	mv	a1,s2
    bc0a:	9402                	jalr	s0
    bc0c:	68e2                	ld	a7,24(sp)
    bc0e:	7802                	ld	a6,32(sp)
    bc10:	418b0633          	sub	a2,s6,s8
    bc14:	89fc450b          	th.lbuib	a0,(s8),-1,0
    bc18:	ec46                	sd	a7,24(sp)
    bc1a:	f042                	sd	a6,32(sp)
    bc1c:	86a6                	mv	a3,s1
    bc1e:	85ca                	mv	a1,s2
    bc20:	9402                	jalr	s0
    bc22:	68e2                	ld	a7,24(sp)
    bc24:	7802                	ld	a6,32(sp)
    bc26:	418b0633          	sub	a2,s6,s8
    bc2a:	89fc450b          	th.lbuib	a0,(s8),-1,0
    bc2e:	ec46                	sd	a7,24(sp)
    bc30:	f042                	sd	a6,32(sp)
    bc32:	86a6                	mv	a3,s1
    bc34:	85ca                	mv	a1,s2
    bc36:	9402                	jalr	s0
    bc38:	68e2                	ld	a7,24(sp)
    bc3a:	7802                	ld	a6,32(sp)
    bc3c:	418b0633          	sub	a2,s6,s8
    bc40:	89fc450b          	th.lbuib	a0,(s8),-1,0
    bc44:	ec46                	sd	a7,24(sp)
    bc46:	f042                	sd	a6,32(sp)
    bc48:	86a6                	mv	a3,s1
    bc4a:	85ca                	mv	a1,s2
    bc4c:	9402                	jalr	s0
    bc4e:	68e2                	ld	a7,24(sp)
    bc50:	7802                	ld	a6,32(sp)
    bc52:	418b0633          	sub	a2,s6,s8
    bc56:	89fc450b          	th.lbuib	a0,(s8),-1,0
    bc5a:	ec46                	sd	a7,24(sp)
    bc5c:	f042                	sd	a6,32(sp)
    bc5e:	86a6                	mv	a3,s1
    bc60:	85ca                	mv	a1,s2
    bc62:	9402                	jalr	s0
    bc64:	68e2                	ld	a7,24(sp)
    bc66:	7802                	ld	a6,32(sp)
    bc68:	8dde                	mv	s11,s7
    bc6a:	09880b63          	beq	a6,s8,bd00 <_vsnprintf+0x3160>
    bc6e:	ec56                	sd	s5,24(sp)
    bc70:	f06a                	sd	s10,32(sp)
    bc72:	8ac2                	mv	s5,a6
    bc74:	8d46                	mv	s10,a7
    bc76:	8ce2                	mv	s9,s8
    bc78:	89fcc50b          	th.lbuib	a0,(s9),-1,0
    bc7c:	418b0633          	sub	a2,s6,s8
    bc80:	86a6                	mv	a3,s1
    bc82:	85ca                	mv	a1,s2
    bc84:	9402                	jalr	s0
    bc86:	8de2                	mv	s11,s8
    bc88:	89edc50b          	th.lbuib	a0,(s11),-2,0
    bc8c:	419b0633          	sub	a2,s6,s9
    bc90:	86a6                	mv	a3,s1
    bc92:	85ca                	mv	a1,s2
    bc94:	9402                	jalr	s0
    bc96:	8ce2                	mv	s9,s8
    bc98:	89dcc50b          	th.lbuib	a0,(s9),-3,0
    bc9c:	41bb0633          	sub	a2,s6,s11
    bca0:	86a6                	mv	a3,s1
    bca2:	85ca                	mv	a1,s2
    bca4:	9402                	jalr	s0
    bca6:	8de2                	mv	s11,s8
    bca8:	89cdc50b          	th.lbuib	a0,(s11),-4,0
    bcac:	419b0633          	sub	a2,s6,s9
    bcb0:	86a6                	mv	a3,s1
    bcb2:	85ca                	mv	a1,s2
    bcb4:	9402                	jalr	s0
    bcb6:	8ce2                	mv	s9,s8
    bcb8:	89bcc50b          	th.lbuib	a0,(s9),-5,0
    bcbc:	41bb0633          	sub	a2,s6,s11
    bcc0:	86a6                	mv	a3,s1
    bcc2:	85ca                	mv	a1,s2
    bcc4:	9402                	jalr	s0
    bcc6:	8de2                	mv	s11,s8
    bcc8:	89adc50b          	th.lbuib	a0,(s11),-6,0
    bccc:	419b0633          	sub	a2,s6,s9
    bcd0:	86a6                	mv	a3,s1
    bcd2:	85ca                	mv	a1,s2
    bcd4:	9402                	jalr	s0
    bcd6:	8ce2                	mv	s9,s8
    bcd8:	899cc50b          	th.lbuib	a0,(s9),-7,0
    bcdc:	41bb0633          	sub	a2,s6,s11
    bce0:	86a6                	mv	a3,s1
    bce2:	85ca                	mv	a1,s2
    bce4:	9402                	jalr	s0
    bce6:	898c450b          	th.lbuib	a0,(s8),-8,0
    bcea:	86a6                	mv	a3,s1
    bcec:	419b0633          	sub	a2,s6,s9
    bcf0:	85ca                	mv	a1,s2
    bcf2:	8dde                	mv	s11,s7
    bcf4:	9402                	jalr	s0
    bcf6:	f98a90e3          	bne	s5,s8,bc76 <_vsnprintf+0x30d6>
    bcfa:	88ea                	mv	a7,s10
    bcfc:	6ae2                	ld	s5,24(sp)
    bcfe:	7d02                	ld	s10,32(sp)
    bd00:	000d1d63          	bnez	s10,bd1a <_vsnprintf+0x317a>
    bd04:	e06e                	sd	s11,0(sp)
    bd06:	8dd6                	mv	s11,s5
    bd08:	f70fe06f          	j	a478 <_vsnprintf+0x18d8>
    bd0c:	002ffd13          	andi	s10,t6,2
    bd10:	000d1463          	bnez	s10,bd18 <_vsnprintf+0x3178>
    bd14:	72c0206f          	j	e440 <_vsnprintf+0x58a0>
    bd18:	6d82                	ld	s11,0(sp)
    bd1a:	6e82                	ld	t4,0(sp)
    bd1c:	7c08bc0b          	th.extu	s8,a7,31,0
    bd20:	41dd8d33          	sub	s10,s11,t4
    bd24:	ff8d70e3          	bgeu	s10,s8,bd04 <_vsnprintf+0x3164>
    bd28:	fffd4893          	not	a7,s10
    bd2c:	01888e33          	add	t3,a7,s8
    bd30:	86a6                	mv	a3,s1
    bd32:	866e                	mv	a2,s11
    bd34:	85ca                	mv	a1,s2
    bd36:	02000513          	li	a0,32
    bd3a:	001d0c93          	addi	s9,s10,1
    bd3e:	007e7b93          	andi	s7,t3,7
    bd42:	001d8b13          	addi	s6,s11,1
    bd46:	9402                	jalr	s0
    bd48:	138cf463          	bgeu	s9,s8,be70 <_vsnprintf+0x32d0>
    bd4c:	0a0b8063          	beqz	s7,bdec <_vsnprintf+0x324c>
    bd50:	4285                	li	t0,1
    bd52:	085b8363          	beq	s7,t0,bdd8 <_vsnprintf+0x3238>
    bd56:	4589                	li	a1,2
    bd58:	06bb8863          	beq	s7,a1,bdc8 <_vsnprintf+0x3228>
    bd5c:	460d                	li	a2,3
    bd5e:	04cb8d63          	beq	s7,a2,bdb8 <_vsnprintf+0x3218>
    bd62:	4511                	li	a0,4
    bd64:	04ab8263          	beq	s7,a0,bda8 <_vsnprintf+0x3208>
    bd68:	4715                	li	a4,5
    bd6a:	02eb8763          	beq	s7,a4,bd98 <_vsnprintf+0x31f8>
    bd6e:	4f99                	li	t6,6
    bd70:	01fb8c63          	beq	s7,t6,bd88 <_vsnprintf+0x31e8>
    bd74:	865a                	mv	a2,s6
    bd76:	86a6                	mv	a3,s1
    bd78:	85ca                	mv	a1,s2
    bd7a:	02000513          	li	a0,32
    bd7e:	002d8b13          	addi	s6,s11,2
    bd82:	9402                	jalr	s0
    bd84:	002d0c93          	addi	s9,s10,2
    bd88:	865a                	mv	a2,s6
    bd8a:	86a6                	mv	a3,s1
    bd8c:	85ca                	mv	a1,s2
    bd8e:	02000513          	li	a0,32
    bd92:	0b05                	addi	s6,s6,1
    bd94:	9402                	jalr	s0
    bd96:	0c85                	addi	s9,s9,1
    bd98:	865a                	mv	a2,s6
    bd9a:	86a6                	mv	a3,s1
    bd9c:	85ca                	mv	a1,s2
    bd9e:	02000513          	li	a0,32
    bda2:	0b05                	addi	s6,s6,1
    bda4:	9402                	jalr	s0
    bda6:	0c85                	addi	s9,s9,1
    bda8:	865a                	mv	a2,s6
    bdaa:	86a6                	mv	a3,s1
    bdac:	85ca                	mv	a1,s2
    bdae:	02000513          	li	a0,32
    bdb2:	0b05                	addi	s6,s6,1
    bdb4:	9402                	jalr	s0
    bdb6:	0c85                	addi	s9,s9,1
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
    bde2:	0c85                	addi	s9,s9,1
    bde4:	0b05                	addi	s6,s6,1
    bde6:	9402                	jalr	s0
    bde8:	098cf463          	bgeu	s9,s8,be70 <_vsnprintf+0x32d0>
    bdec:	865a                	mv	a2,s6
    bdee:	86a6                	mv	a3,s1
    bdf0:	85ca                	mv	a1,s2
    bdf2:	02000513          	li	a0,32
    bdf6:	9402                	jalr	s0
    bdf8:	001b0d93          	addi	s11,s6,1
    bdfc:	866e                	mv	a2,s11
    bdfe:	86a6                	mv	a3,s1
    be00:	85ca                	mv	a1,s2
    be02:	02000513          	li	a0,32
    be06:	9402                	jalr	s0
    be08:	002b0d13          	addi	s10,s6,2
    be0c:	866a                	mv	a2,s10
    be0e:	86a6                	mv	a3,s1
    be10:	85ca                	mv	a1,s2
    be12:	02000513          	li	a0,32
    be16:	9402                	jalr	s0
    be18:	003b0b93          	addi	s7,s6,3
    be1c:	865e                	mv	a2,s7
    be1e:	86a6                	mv	a3,s1
    be20:	85ca                	mv	a1,s2
    be22:	02000513          	li	a0,32
    be26:	9402                	jalr	s0
    be28:	004b0d93          	addi	s11,s6,4
    be2c:	866e                	mv	a2,s11
    be2e:	86a6                	mv	a3,s1
    be30:	85ca                	mv	a1,s2
    be32:	02000513          	li	a0,32
    be36:	9402                	jalr	s0
    be38:	005b0b93          	addi	s7,s6,5
    be3c:	86a6                	mv	a3,s1
    be3e:	865e                	mv	a2,s7
    be40:	85ca                	mv	a1,s2
    be42:	02000513          	li	a0,32
    be46:	9402                	jalr	s0
    be48:	006b0d13          	addi	s10,s6,6
    be4c:	86a6                	mv	a3,s1
    be4e:	866a                	mv	a2,s10
    be50:	85ca                	mv	a1,s2
    be52:	02000513          	li	a0,32
    be56:	9402                	jalr	s0
    be58:	007b0d93          	addi	s11,s6,7
    be5c:	86a6                	mv	a3,s1
    be5e:	866e                	mv	a2,s11
    be60:	85ca                	mv	a1,s2
    be62:	02000513          	li	a0,32
    be66:	0ca1                	addi	s9,s9,8
    be68:	0b21                	addi	s6,s6,8
    be6a:	9402                	jalr	s0
    be6c:	f98ce0e3          	bltu	s9,s8,bdec <_vsnprintf+0x324c>
    be70:	e05a                	sd	s6,0(sp)
    be72:	8dd6                	mv	s11,s5
    be74:	e04fe06f          	j	a478 <_vsnprintf+0x18d8>
    be78:	886e                	mv	a6,s11
    be7a:	78884e8b          	th.ldia	t4,(a6),8,0
    be7e:	240e9963          	bnez	t4,c0d0 <_vsnprintf+0x3530>
    be82:	002afd93          	andi	s11,s5,2
    be86:	000d8463          	beqz	s11,be8e <_vsnprintf+0x32ee>
    be8a:	2ae0206f          	j	e138 <_vsnprintf+0x5598>
    be8e:	7c0c3c0b          	th.extu	s8,s8,31,0
    be92:	4781                	li	a5,0
    be94:	03010c93          	addi	s9,sp,48
    be98:	00089463          	bnez	a7,bea0 <_vsnprintf+0x3300>
    be9c:	5c80206f          	j	e464 <_vsnprintf+0x58c4>
    bea0:	000c1463          	bnez	s8,bea8 <_vsnprintf+0x3308>
    bea4:	7050206f          	j	eda8 <_vsnprintf+0x6208>
    bea8:	02000a93          	li	s5,32
    beac:	40fa8633          	sub	a2,s5,a5
    beb0:	00767393          	andi	t2,a2,7
    beb4:	00fc8bb3          	add	s7,s9,a5
    beb8:	03000e13          	li	t3,48
    bebc:	06038763          	beqz	t2,bf2a <_vsnprintf+0x338a>
    bec0:	0785                	addi	a5,a5,1
    bec2:	181bde0b          	th.sbia	t3,(s7),1,0
    bec6:	0d87f663          	bgeu	a5,s8,bf92 <_vsnprintf+0x33f2>
    beca:	4f85                	li	t6,1
    becc:	05f38f63          	beq	t2,t6,bf2a <_vsnprintf+0x338a>
    bed0:	4709                	li	a4,2
    bed2:	04e38763          	beq	t2,a4,bf20 <_vsnprintf+0x3380>
    bed6:	4f0d                	li	t5,3
    bed8:	03e38f63          	beq	t2,t5,bf16 <_vsnprintf+0x3376>
    bedc:	4d11                	li	s10,4
    bede:	03a38763          	beq	t2,s10,bf0c <_vsnprintf+0x336c>
    bee2:	4295                	li	t0,5
    bee4:	00538f63          	beq	t2,t0,bf02 <_vsnprintf+0x3362>
    bee8:	4319                	li	t1,6
    beea:	00638763          	beq	t2,t1,bef8 <_vsnprintf+0x3358>
    beee:	0785                	addi	a5,a5,1
    bef0:	181bde0b          	th.sbia	t3,(s7),1,0
    bef4:	0987ff63          	bgeu	a5,s8,bf92 <_vsnprintf+0x33f2>
    bef8:	0785                	addi	a5,a5,1
    befa:	181bde0b          	th.sbia	t3,(s7),1,0
    befe:	0987fa63          	bgeu	a5,s8,bf92 <_vsnprintf+0x33f2>
    bf02:	0785                	addi	a5,a5,1
    bf04:	181bde0b          	th.sbia	t3,(s7),1,0
    bf08:	0987f563          	bgeu	a5,s8,bf92 <_vsnprintf+0x33f2>
    bf0c:	0785                	addi	a5,a5,1
    bf0e:	181bde0b          	th.sbia	t3,(s7),1,0
    bf12:	0987f063          	bgeu	a5,s8,bf92 <_vsnprintf+0x33f2>
    bf16:	0785                	addi	a5,a5,1
    bf18:	181bde0b          	th.sbia	t3,(s7),1,0
    bf1c:	0787fb63          	bgeu	a5,s8,bf92 <_vsnprintf+0x33f2>
    bf20:	0785                	addi	a5,a5,1
    bf22:	181bde0b          	th.sbia	t3,(s7),1,0
    bf26:	0787f663          	bgeu	a5,s8,bf92 <_vsnprintf+0x33f2>
    bf2a:	01579463          	bne	a5,s5,bf32 <_vsnprintf+0x3392>
    bf2e:	7800106f          	j	d6ae <_vsnprintf+0x4b0e>
    bf32:	0785                	addi	a5,a5,1
    bf34:	01cb8023          	sb	t3,0(s7)
    bf38:	853e                	mv	a0,a5
    bf3a:	0587fc63          	bgeu	a5,s8,bf92 <_vsnprintf+0x33f2>
    bf3e:	0785                	addi	a5,a5,1
    bf40:	01cb80a3          	sb	t3,1(s7)
    bf44:	0587f763          	bgeu	a5,s8,bf92 <_vsnprintf+0x33f2>
    bf48:	00250793          	addi	a5,a0,2
    bf4c:	01cb8123          	sb	t3,2(s7)
    bf50:	0587f163          	bgeu	a5,s8,bf92 <_vsnprintf+0x33f2>
    bf54:	00350793          	addi	a5,a0,3
    bf58:	01cb81a3          	sb	t3,3(s7)
    bf5c:	0387fb63          	bgeu	a5,s8,bf92 <_vsnprintf+0x33f2>
    bf60:	00450793          	addi	a5,a0,4
    bf64:	01cb8223          	sb	t3,4(s7)
    bf68:	0387f563          	bgeu	a5,s8,bf92 <_vsnprintf+0x33f2>
    bf6c:	00550793          	addi	a5,a0,5
    bf70:	01cb82a3          	sb	t3,5(s7)
    bf74:	0187ff63          	bgeu	a5,s8,bf92 <_vsnprintf+0x33f2>
    bf78:	00650793          	addi	a5,a0,6
    bf7c:	01cb8323          	sb	t3,6(s7)
    bf80:	0187f963          	bgeu	a5,s8,bf92 <_vsnprintf+0x33f2>
    bf84:	01cb83a3          	sb	t3,7(s7)
    bf88:	00750793          	addi	a5,a0,7
    bf8c:	0ba1                	addi	s7,s7,8
    bf8e:	f987eee3          	bltu	a5,s8,bf2a <_vsnprintf+0x338a>
    bf92:	000d9463          	bnez	s11,bf9a <_vsnprintf+0x33fa>
    bf96:	23a0206f          	j	e1d0 <_vsnprintf+0x5630>
    bf9a:	7c08b68b          	th.extu	a3,a7,31,0
    bf9e:	00d7e463          	bltu	a5,a3,bfa6 <_vsnprintf+0x3406>
    bfa2:	2b70206f          	j	ea58 <_vsnprintf+0x5eb8>
    bfa6:	02000d93          	li	s11,32
    bfaa:	40fd8ab3          	sub	s5,s11,a5
    bfae:	007afe13          	andi	t3,s5,7
    bfb2:	00fc8633          	add	a2,s9,a5
    bfb6:	03000b13          	li	s6,48
    bfba:	060e0763          	beqz	t3,c028 <_vsnprintf+0x3488>
    bfbe:	0785                	addi	a5,a5,1
    bfc0:	18165b0b          	th.sbia	s6,(a2),1,0
    bfc4:	0cd78663          	beq	a5,a3,c090 <_vsnprintf+0x34f0>
    bfc8:	4385                	li	t2,1
    bfca:	047e0f63          	beq	t3,t2,c028 <_vsnprintf+0x3488>
    bfce:	4f89                	li	t6,2
    bfd0:	05fe0763          	beq	t3,t6,c01e <_vsnprintf+0x347e>
    bfd4:	470d                	li	a4,3
    bfd6:	02ee0f63          	beq	t3,a4,c014 <_vsnprintf+0x3474>
    bfda:	4f11                	li	t5,4
    bfdc:	03ee0763          	beq	t3,t5,c00a <_vsnprintf+0x346a>
    bfe0:	4d15                	li	s10,5
    bfe2:	01ae0f63          	beq	t3,s10,c000 <_vsnprintf+0x3460>
    bfe6:	4299                	li	t0,6
    bfe8:	005e0763          	beq	t3,t0,bff6 <_vsnprintf+0x3456>
    bfec:	0785                	addi	a5,a5,1
    bfee:	18165b0b          	th.sbia	s6,(a2),1,0
    bff2:	08d78f63          	beq	a5,a3,c090 <_vsnprintf+0x34f0>
    bff6:	0785                	addi	a5,a5,1
    bff8:	18165b0b          	th.sbia	s6,(a2),1,0
    bffc:	08d78a63          	beq	a5,a3,c090 <_vsnprintf+0x34f0>
    c000:	0785                	addi	a5,a5,1
    c002:	18165b0b          	th.sbia	s6,(a2),1,0
    c006:	08d78563          	beq	a5,a3,c090 <_vsnprintf+0x34f0>
    c00a:	0785                	addi	a5,a5,1
    c00c:	18165b0b          	th.sbia	s6,(a2),1,0
    c010:	08d78063          	beq	a5,a3,c090 <_vsnprintf+0x34f0>
    c014:	0785                	addi	a5,a5,1
    c016:	18165b0b          	th.sbia	s6,(a2),1,0
    c01a:	06d78b63          	beq	a5,a3,c090 <_vsnprintf+0x34f0>
    c01e:	0785                	addi	a5,a5,1
    c020:	18165b0b          	th.sbia	s6,(a2),1,0
    c024:	06d78663          	beq	a5,a3,c090 <_vsnprintf+0x34f0>
    c028:	01b79463          	bne	a5,s11,c030 <_vsnprintf+0x3490>
    c02c:	6640106f          	j	d690 <_vsnprintf+0x4af0>
    c030:	00178313          	addi	t1,a5,1
    c034:	01660023          	sb	s6,0(a2)
    c038:	04d30c63          	beq	t1,a3,c090 <_vsnprintf+0x34f0>
    c03c:	00278513          	addi	a0,a5,2
    c040:	016600a3          	sb	s6,1(a2)
    c044:	04d50663          	beq	a0,a3,c090 <_vsnprintf+0x34f0>
    c048:	00378b93          	addi	s7,a5,3
    c04c:	01660123          	sb	s6,2(a2)
    c050:	04db8063          	beq	s7,a3,c090 <_vsnprintf+0x34f0>
    c054:	00478c13          	addi	s8,a5,4
    c058:	016601a3          	sb	s6,3(a2)
    c05c:	02dc0a63          	beq	s8,a3,c090 <_vsnprintf+0x34f0>
    c060:	00578a93          	addi	s5,a5,5
    c064:	01660223          	sb	s6,4(a2)
    c068:	02da8463          	beq	s5,a3,c090 <_vsnprintf+0x34f0>
    c06c:	00678e13          	addi	t3,a5,6
    c070:	016602a3          	sb	s6,5(a2)
    c074:	00de0e63          	beq	t3,a3,c090 <_vsnprintf+0x34f0>
    c078:	00778393          	addi	t2,a5,7
    c07c:	01660323          	sb	s6,6(a2)
    c080:	00d38863          	beq	t2,a3,c090 <_vsnprintf+0x34f0>
    c084:	016603a3          	sb	s6,7(a2)
    c088:	07a1                	addi	a5,a5,8
    c08a:	0621                	addi	a2,a2,8
    c08c:	f8d79ee3          	bne	a5,a3,c028 <_vsnprintf+0x3488>
    c090:	02000793          	li	a5,32
    c094:	00f69463          	bne	a3,a5,c09c <_vsnprintf+0x34fc>
    c098:	5f80106f          	j	d690 <_vsnprintf+0x4af0>
    c09c:	000ec463          	bltz	t4,c0a4 <_vsnprintf+0x3504>
    c0a0:	07b0206f          	j	e91a <_vsnprintf+0x5d7a>
    c0a4:	00268ab3          	add	s5,a3,sp
    c0a8:	02d00513          	li	a0,45
    c0ac:	02aa8823          	sb	a0,48(s5)
    c0b0:	0035fe13          	andi	t3,a1,3
    c0b4:	00168c13          	addi	s8,a3,1
    c0b8:	380e06e3          	beqz	t3,cc44 <_vsnprintf+0x40a4>
    c0bc:	8dc2                	mv	s11,a6
    c0be:	4b01                	li	s6,0
    c0c0:	6802                	ld	a6,0(sp)
    c0c2:	aaa5                	j	c23a <_vsnprintf+0x369a>
    c0c4:	886e                	mv	a6,s11
    c0c6:	78884e8b          	th.ldia	t4,(a6),8,0
    c0ca:	4b81                	li	s7,0
    c0cc:	000e8863          	beqz	t4,c0dc <_vsnprintf+0x353c>
    c0d0:	43fedd93          	srai	s11,t4,0x3f
    c0d4:	01ddc533          	xor	a0,s11,t4
    c0d8:	41b50bb3          	sub	s7,a0,s11
    c0dc:	46a9                	li	a3,10
    c0de:	02dbfb33          	remu	s6,s7,a3
    c0e2:	03010c93          	addi	s9,sp,48
    c0e6:	4d25                	li	s10,9
    c0e8:	87e6                	mv	a5,s9
    c0ea:	030b0a9b          	addiw	s5,s6,48
    c0ee:	03510823          	sb	s5,48(sp)
    c0f2:	02dbd533          	divu	a0,s7,a3
    c0f6:	117d7d63          	bgeu	s10,s7,c210 <_vsnprintf+0x3670>
    c0fa:	03110793          	addi	a5,sp,49
    c0fe:	02d57333          	remu	t1,a0,a3
    c102:	03030e1b          	addiw	t3,t1,48
    c106:	01c78023          	sb	t3,0(a5)
    c10a:	02d55633          	divu	a2,a0,a3
    c10e:	10ad7163          	bgeu	s10,a0,c210 <_vsnprintf+0x3670>
    c112:	0001                	nop
    c114:	00000013          	nop
    c118:	00178293          	addi	t0,a5,1
    c11c:	05010f93          	addi	t6,sp,80
    c120:	0e5f8863          	beq	t6,t0,c210 <_vsnprintf+0x3670>
    c124:	8796                	mv	a5,t0
    c126:	02d673b3          	remu	t2,a2,a3
    c12a:	0303871b          	addiw	a4,t2,48
    c12e:	00e28023          	sb	a4,0(t0)
    c132:	02d65f33          	divu	t5,a2,a3
    c136:	0ccd7d63          	bgeu	s10,a2,c210 <_vsnprintf+0x3670>
    c13a:	02df7333          	remu	t1,t5,a3
    c13e:	03030d9b          	addiw	s11,t1,48
    c142:	0817dd8b          	th.sbib	s11,(a5),1,0
    c146:	02df5533          	divu	a0,t5,a3
    c14a:	0ded7363          	bgeu	s10,t5,c210 <_vsnprintf+0x3670>
    c14e:	00228793          	addi	a5,t0,2
    c152:	02d57bb3          	remu	s7,a0,a3
    c156:	030b8b1b          	addiw	s6,s7,48
    c15a:	01628123          	sb	s6,2(t0)
    c15e:	02d55ab3          	divu	s5,a0,a3
    c162:	0aad7763          	bgeu	s10,a0,c210 <_vsnprintf+0x3670>
    c166:	00328793          	addi	a5,t0,3
    c16a:	02dafe33          	remu	t3,s5,a3
    c16e:	030e061b          	addiw	a2,t3,48
    c172:	00c281a3          	sb	a2,3(t0)
    c176:	02dadfb3          	divu	t6,s5,a3
    c17a:	095d7b63          	bgeu	s10,s5,c210 <_vsnprintf+0x3670>
    c17e:	00428793          	addi	a5,t0,4
    c182:	02dff3b3          	remu	t2,t6,a3
    c186:	0303871b          	addiw	a4,t2,48
    c18a:	00e28223          	sb	a4,4(t0)
    c18e:	02dfdf33          	divu	t5,t6,a3
    c192:	07fd7f63          	bgeu	s10,t6,c210 <_vsnprintf+0x3670>
    c196:	00528793          	addi	a5,t0,5
    c19a:	02df7333          	remu	t1,t5,a3
    c19e:	03030d9b          	addiw	s11,t1,48
    c1a2:	01b282a3          	sb	s11,5(t0)
    c1a6:	02df5533          	divu	a0,t5,a3
    c1aa:	07ed7363          	bgeu	s10,t5,c210 <_vsnprintf+0x3670>
    c1ae:	00628793          	addi	a5,t0,6
    c1b2:	02d57bb3          	remu	s7,a0,a3
    c1b6:	030b8b1b          	addiw	s6,s7,48
    c1ba:	01628323          	sb	s6,6(t0)
    c1be:	02d55ab3          	divu	s5,a0,a3
    c1c2:	04ad7763          	bgeu	s10,a0,c210 <_vsnprintf+0x3670>
    c1c6:	00728793          	addi	a5,t0,7
    c1ca:	02dafe33          	remu	t3,s5,a3
    c1ce:	030e061b          	addiw	a2,t3,48
    c1d2:	00c283a3          	sb	a2,7(t0)
    c1d6:	02dadfb3          	divu	t6,s5,a3
    c1da:	035d7b63          	bgeu	s10,s5,c210 <_vsnprintf+0x3670>
    c1de:	00828793          	addi	a5,t0,8
    c1e2:	02dff3b3          	remu	t2,t6,a3
    c1e6:	0303871b          	addiw	a4,t2,48
    c1ea:	00e28423          	sb	a4,8(t0)
    c1ee:	02dfdf33          	divu	t5,t6,a3
    c1f2:	01fd7f63          	bgeu	s10,t6,c210 <_vsnprintf+0x3670>
    c1f6:	00928793          	addi	a5,t0,9
    c1fa:	857a                	mv	a0,t5
    c1fc:	02df7333          	remu	t1,t5,a3
    c200:	03030e1b          	addiw	t3,t1,48
    c204:	01c78023          	sb	t3,0(a5)
    c208:	02d55633          	divu	a2,a0,a3
    c20c:	f0ad66e3          	bltu	s10,a0,c118 <_vsnprintf+0x3578>
    c210:	419787b3          	sub	a5,a5,s9
    c214:	0025fb13          	andi	s6,a1,2
    c218:	0785                	addi	a5,a5,1
    c21a:	86ae                	mv	a3,a1
    c21c:	1e0b04e3          	beqz	s6,cc04 <_vsnprintf+0x4064>
    c220:	02000c13          	li	s8,32
    c224:	4b09                	li	s6,2
    c226:	01878463          	beq	a5,s8,c22e <_vsnprintf+0x368e>
    c22a:	1b50106f          	j	dbde <_vsnprintf+0x503e>
    c22e:	8dc2                	mv	s11,a6
    c230:	04f14503          	lbu	a0,79(sp)
    c234:	6802                	ld	a6,0(sp)
    c236:	02000c13          	li	s8,32
    c23a:	018c8d33          	add	s10,s9,s8
    c23e:	01880bb3          	add	s7,a6,s8
    c242:	fffcc813          	not	a6,s9
    c246:	01a802b3          	add	t0,a6,s10
    c24a:	0072f313          	andi	t1,t0,7
    c24e:	017c8c33          	add	s8,s9,s7
    c252:	00031463          	bnez	t1,c25a <_vsnprintf+0x36ba>
    c256:	2e80106f          	j	d53e <_vsnprintf+0x499e>
    c25a:	41ac0633          	sub	a2,s8,s10
    c25e:	ec46                	sd	a7,24(sp)
    c260:	f01a                	sd	t1,32(sp)
    c262:	86a6                	mv	a3,s1
    c264:	85ca                	mv	a1,s2
    c266:	9402                	jalr	s0
    c268:	68e2                	ld	a7,24(sp)
    c26a:	7e02                	ld	t3,32(sp)
    c26c:	4a85                	li	s5,1
    c26e:	1d7d                	addi	s10,s10,-1
    c270:	fffd4503          	lbu	a0,-1(s10)
    c274:	015e1463          	bne	t3,s5,c27c <_vsnprintf+0x36dc>
    c278:	2c60106f          	j	d53e <_vsnprintf+0x499e>
    c27c:	4609                	li	a2,2
    c27e:	06ce0f63          	beq	t3,a2,c2fc <_vsnprintf+0x375c>
    c282:	438d                	li	t2,3
    c284:	067e0263          	beq	t3,t2,c2e8 <_vsnprintf+0x3748>
    c288:	4791                	li	a5,4
    c28a:	04fe0563          	beq	t3,a5,c2d4 <_vsnprintf+0x3734>
    c28e:	4e95                	li	t4,5
    c290:	03de0863          	beq	t3,t4,c2c0 <_vsnprintf+0x3720>
    c294:	4599                	li	a1,6
    c296:	00be0b63          	beq	t3,a1,c2ac <_vsnprintf+0x370c>
    c29a:	41ac0633          	sub	a2,s8,s10
    c29e:	86a6                	mv	a3,s1
    c2a0:	85ca                	mv	a1,s2
    c2a2:	9402                	jalr	s0
    c2a4:	68e2                	ld	a7,24(sp)
    c2a6:	ffed4503          	lbu	a0,-2(s10)
    c2aa:	1d7d                	addi	s10,s10,-1
    c2ac:	41ac0633          	sub	a2,s8,s10
    c2b0:	ec46                	sd	a7,24(sp)
    c2b2:	86a6                	mv	a3,s1
    c2b4:	85ca                	mv	a1,s2
    c2b6:	9402                	jalr	s0
    c2b8:	68e2                	ld	a7,24(sp)
    c2ba:	ffed4503          	lbu	a0,-2(s10)
    c2be:	1d7d                	addi	s10,s10,-1
    c2c0:	41ac0633          	sub	a2,s8,s10
    c2c4:	ec46                	sd	a7,24(sp)
    c2c6:	86a6                	mv	a3,s1
    c2c8:	85ca                	mv	a1,s2
    c2ca:	9402                	jalr	s0
    c2cc:	68e2                	ld	a7,24(sp)
    c2ce:	ffed4503          	lbu	a0,-2(s10)
    c2d2:	1d7d                	addi	s10,s10,-1
    c2d4:	41ac0633          	sub	a2,s8,s10
    c2d8:	ec46                	sd	a7,24(sp)
    c2da:	86a6                	mv	a3,s1
    c2dc:	85ca                	mv	a1,s2
    c2de:	9402                	jalr	s0
    c2e0:	68e2                	ld	a7,24(sp)
    c2e2:	ffed4503          	lbu	a0,-2(s10)
    c2e6:	1d7d                	addi	s10,s10,-1
    c2e8:	41ac0633          	sub	a2,s8,s10
    c2ec:	ec46                	sd	a7,24(sp)
    c2ee:	86a6                	mv	a3,s1
    c2f0:	85ca                	mv	a1,s2
    c2f2:	9402                	jalr	s0
    c2f4:	68e2                	ld	a7,24(sp)
    c2f6:	ffed4503          	lbu	a0,-2(s10)
    c2fa:	1d7d                	addi	s10,s10,-1
    c2fc:	41ac0633          	sub	a2,s8,s10
    c300:	86a6                	mv	a3,s1
    c302:	85ca                	mv	a1,s2
    c304:	ec46                	sd	a7,24(sp)
    c306:	9402                	jalr	s0
    c308:	1d7d                	addi	s10,s10,-1
    c30a:	f05a                	sd	s6,32(sp)
    c30c:	fffd4503          	lbu	a0,-1(s10)
    c310:	a895                	j	c384 <_vsnprintf+0x37e4>
    c312:	8b6a                	mv	s6,s10
    c314:	40ac0633          	sub	a2,s8,a0
    c318:	89eb450b          	th.lbuib	a0,(s6),-2,0
    c31c:	86a6                	mv	a3,s1
    c31e:	85ca                	mv	a1,s2
    c320:	9402                	jalr	s0
    c322:	8aea                	mv	s5,s10
    c324:	89dac50b          	th.lbuib	a0,(s5),-3,0
    c328:	416c0633          	sub	a2,s8,s6
    c32c:	86a6                	mv	a3,s1
    c32e:	85ca                	mv	a1,s2
    c330:	9402                	jalr	s0
    c332:	8b6a                	mv	s6,s10
    c334:	89cb450b          	th.lbuib	a0,(s6),-4,0
    c338:	415c0633          	sub	a2,s8,s5
    c33c:	86a6                	mv	a3,s1
    c33e:	85ca                	mv	a1,s2
    c340:	9402                	jalr	s0
    c342:	8aea                	mv	s5,s10
    c344:	89bac50b          	th.lbuib	a0,(s5),-5,0
    c348:	416c0633          	sub	a2,s8,s6
    c34c:	86a6                	mv	a3,s1
    c34e:	85ca                	mv	a1,s2
    c350:	9402                	jalr	s0
    c352:	8b6a                	mv	s6,s10
    c354:	89ab450b          	th.lbuib	a0,(s6),-6,0
    c358:	415c0633          	sub	a2,s8,s5
    c35c:	86a6                	mv	a3,s1
    c35e:	85ca                	mv	a1,s2
    c360:	9402                	jalr	s0
    c362:	8aea                	mv	s5,s10
    c364:	899ac50b          	th.lbuib	a0,(s5),-7,0
    c368:	86a6                	mv	a3,s1
    c36a:	416c0633          	sub	a2,s8,s6
    c36e:	85ca                	mv	a1,s2
    c370:	9402                	jalr	s0
    c372:	898d450b          	th.lbuib	a0,(s10),-8,0
    c376:	86a6                	mv	a3,s1
    c378:	415c0633          	sub	a2,s8,s5
    c37c:	85ca                	mv	a1,s2
    c37e:	9402                	jalr	s0
    c380:	fffd4503          	lbu	a0,-1(s10)
    c384:	86a6                	mv	a3,s1
    c386:	41ac0633          	sub	a2,s8,s10
    c38a:	85ca                	mv	a1,s2
    c38c:	9402                	jalr	s0
    c38e:	fffd0513          	addi	a0,s10,-1
    c392:	f8ac90e3          	bne	s9,a0,c312 <_vsnprintf+0x3772>
    c396:	68e2                	ld	a7,24(sp)
    c398:	7b02                	ld	s6,32(sp)
    c39a:	8e5e                	mv	t3,s7
    c39c:	000b1463          	bnez	s6,c3a4 <_vsnprintf+0x3804>
    c3a0:	8bcfe06f          	j	a45c <_vsnprintf+0x18bc>
    c3a4:	7c08bc0b          	th.extu	s8,a7,31,0
    c3a8:	6882                	ld	a7,0(sp)
    c3aa:	411e0ab3          	sub	s5,t3,a7
    c3ae:	018ae463          	bltu	s5,s8,c3b6 <_vsnprintf+0x3816>
    c3b2:	8aafe06f          	j	a45c <_vsnprintf+0x18bc>
    c3b6:	fffac693          	not	a3,s5
    c3ba:	01868fb3          	add	t6,a3,s8
    c3be:	8672                	mv	a2,t3
    c3c0:	86a6                	mv	a3,s1
    c3c2:	85ca                	mv	a1,s2
    c3c4:	02000513          	li	a0,32
    c3c8:	e072                	sd	t3,0(sp)
    c3ca:	007ffb93          	andi	s7,t6,7
    c3ce:	001e0b13          	addi	s6,t3,1
    c3d2:	001a8c93          	addi	s9,s5,1
    c3d6:	9402                	jalr	s0
    c3d8:	6f02                	ld	t5,0(sp)
    c3da:	018ce463          	bltu	s9,s8,c3e2 <_vsnprintf+0x3842>
    c3de:	892fe06f          	j	a470 <_vsnprintf+0x18d0>
    c3e2:	0a0b8263          	beqz	s7,c486 <_vsnprintf+0x38e6>
    c3e6:	4705                	li	a4,1
    c3e8:	08eb8363          	beq	s7,a4,c46e <_vsnprintf+0x38ce>
    c3ec:	4809                	li	a6,2
    c3ee:	070b8863          	beq	s7,a6,c45e <_vsnprintf+0x38be>
    c3f2:	428d                	li	t0,3
    c3f4:	045b8d63          	beq	s7,t0,c44e <_vsnprintf+0x38ae>
    c3f8:	4311                	li	t1,4
    c3fa:	046b8263          	beq	s7,t1,c43e <_vsnprintf+0x389e>
    c3fe:	4e15                	li	t3,5
    c400:	03cb8763          	beq	s7,t3,c42e <_vsnprintf+0x388e>
    c404:	4619                	li	a2,6
    c406:	00cb8c63          	beq	s7,a2,c41e <_vsnprintf+0x387e>
    c40a:	865a                	mv	a2,s6
    c40c:	86a6                	mv	a3,s1
    c40e:	85ca                	mv	a1,s2
    c410:	02000513          	li	a0,32
    c414:	002f0b13          	addi	s6,t5,2
    c418:	002a8c93          	addi	s9,s5,2
    c41c:	9402                	jalr	s0
    c41e:	865a                	mv	a2,s6
    c420:	86a6                	mv	a3,s1
    c422:	85ca                	mv	a1,s2
    c424:	02000513          	li	a0,32
    c428:	0b05                	addi	s6,s6,1
    c42a:	9402                	jalr	s0
    c42c:	0c85                	addi	s9,s9,1
    c42e:	865a                	mv	a2,s6
    c430:	86a6                	mv	a3,s1
    c432:	85ca                	mv	a1,s2
    c434:	02000513          	li	a0,32
    c438:	0b05                	addi	s6,s6,1
    c43a:	9402                	jalr	s0
    c43c:	0c85                	addi	s9,s9,1
    c43e:	865a                	mv	a2,s6
    c440:	86a6                	mv	a3,s1
    c442:	85ca                	mv	a1,s2
    c444:	02000513          	li	a0,32
    c448:	0b05                	addi	s6,s6,1
    c44a:	9402                	jalr	s0
    c44c:	0c85                	addi	s9,s9,1
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
    c478:	0c85                	addi	s9,s9,1
    c47a:	0b05                	addi	s6,s6,1
    c47c:	9402                	jalr	s0
    c47e:	018ce463          	bltu	s9,s8,c486 <_vsnprintf+0x38e6>
    c482:	feffd06f          	j	a470 <_vsnprintf+0x18d0>
    c486:	865a                	mv	a2,s6
    c488:	86a6                	mv	a3,s1
    c48a:	85ca                	mv	a1,s2
    c48c:	02000513          	li	a0,32
    c490:	9402                	jalr	s0
    c492:	001b0d13          	addi	s10,s6,1
    c496:	866a                	mv	a2,s10
    c498:	86a6                	mv	a3,s1
    c49a:	85ca                	mv	a1,s2
    c49c:	02000513          	li	a0,32
    c4a0:	9402                	jalr	s0
    c4a2:	002b0b93          	addi	s7,s6,2
    c4a6:	865e                	mv	a2,s7
    c4a8:	86a6                	mv	a3,s1
    c4aa:	85ca                	mv	a1,s2
    c4ac:	02000513          	li	a0,32
    c4b0:	9402                	jalr	s0
    c4b2:	003b0a93          	addi	s5,s6,3
    c4b6:	8656                	mv	a2,s5
    c4b8:	86a6                	mv	a3,s1
    c4ba:	85ca                	mv	a1,s2
    c4bc:	02000513          	li	a0,32
    c4c0:	9402                	jalr	s0
    c4c2:	004b0d13          	addi	s10,s6,4
    c4c6:	866a                	mv	a2,s10
    c4c8:	86a6                	mv	a3,s1
    c4ca:	85ca                	mv	a1,s2
    c4cc:	02000513          	li	a0,32
    c4d0:	9402                	jalr	s0
    c4d2:	005b0a93          	addi	s5,s6,5
    c4d6:	86a6                	mv	a3,s1
    c4d8:	8656                	mv	a2,s5
    c4da:	85ca                	mv	a1,s2
    c4dc:	02000513          	li	a0,32
    c4e0:	9402                	jalr	s0
    c4e2:	006b0b93          	addi	s7,s6,6
    c4e6:	86a6                	mv	a3,s1
    c4e8:	865e                	mv	a2,s7
    c4ea:	85ca                	mv	a1,s2
    c4ec:	02000513          	li	a0,32
    c4f0:	9402                	jalr	s0
    c4f2:	007b0d13          	addi	s10,s6,7
    c4f6:	86a6                	mv	a3,s1
    c4f8:	866a                	mv	a2,s10
    c4fa:	85ca                	mv	a1,s2
    c4fc:	02000513          	li	a0,32
    c500:	0ca1                	addi	s9,s9,8
    c502:	0b21                	addi	s6,s6,8
    c504:	9402                	jalr	s0
    c506:	f98ce0e3          	bltu	s9,s8,c486 <_vsnprintf+0x38e6>
    c50a:	f67fd06f          	j	a470 <_vsnprintf+0x18d0>
    c50e:	0001                	nop
    c510:	5c088be3          	beqz	a7,d2e6 <_vsnprintf+0x4746>
    c514:	001aff93          	andi	t6,s5,1
    c518:	000f9463          	bnez	t6,c520 <_vsnprintf+0x3980>
    c51c:	3d10106f          	j	e0ec <_vsnprintf+0x554c>
    c520:	000e4463          	bltz	t3,c528 <_vsnprintf+0x3988>
    c524:	07a0206f          	j	e59e <_vsnprintf+0x59fe>
    c528:	7c0c3c0b          	th.extu	s8,s8,31,0
    c52c:	38fd                	addiw	a7,a7,-1
    c52e:	0187e463          	bltu	a5,s8,c536 <_vsnprintf+0x3996>
    c532:	0d70206f          	j	ee08 <_vsnprintf+0x6268>
    c536:	02000393          	li	t2,32
    c53a:	40f38f33          	sub	t5,t2,a5
    c53e:	007f7313          	andi	t1,t5,7
    c542:	00fb86b3          	add	a3,s7,a5
    c546:	03000b13          	li	s6,48
    c54a:	06030763          	beqz	t1,c5b8 <_vsnprintf+0x3a18>
    c54e:	0785                	addi	a5,a5,1
    c550:	1816db0b          	th.sbia	s6,(a3),1,0
    c554:	0d87f463          	bgeu	a5,s8,c61c <_vsnprintf+0x3a7c>
    c558:	4805                	li	a6,1
    c55a:	05030f63          	beq	t1,a6,c5b8 <_vsnprintf+0x3a18>
    c55e:	4e89                	li	t4,2
    c560:	05d30763          	beq	t1,t4,c5ae <_vsnprintf+0x3a0e>
    c564:	450d                	li	a0,3
    c566:	02a30f63          	beq	t1,a0,c5a4 <_vsnprintf+0x3a04>
    c56a:	4611                	li	a2,4
    c56c:	02c30763          	beq	t1,a2,c59a <_vsnprintf+0x39fa>
    c570:	4c95                	li	s9,5
    c572:	01930f63          	beq	t1,s9,c590 <_vsnprintf+0x39f0>
    c576:	4719                	li	a4,6
    c578:	00e30763          	beq	t1,a4,c586 <_vsnprintf+0x39e6>
    c57c:	0785                	addi	a5,a5,1
    c57e:	1816db0b          	th.sbia	s6,(a3),1,0
    c582:	0987fd63          	bgeu	a5,s8,c61c <_vsnprintf+0x3a7c>
    c586:	0785                	addi	a5,a5,1
    c588:	1816db0b          	th.sbia	s6,(a3),1,0
    c58c:	0987f863          	bgeu	a5,s8,c61c <_vsnprintf+0x3a7c>
    c590:	0785                	addi	a5,a5,1
    c592:	1816db0b          	th.sbia	s6,(a3),1,0
    c596:	0987f363          	bgeu	a5,s8,c61c <_vsnprintf+0x3a7c>
    c59a:	0785                	addi	a5,a5,1
    c59c:	1816db0b          	th.sbia	s6,(a3),1,0
    c5a0:	0787fe63          	bgeu	a5,s8,c61c <_vsnprintf+0x3a7c>
    c5a4:	0785                	addi	a5,a5,1
    c5a6:	1816db0b          	th.sbia	s6,(a3),1,0
    c5aa:	0787f963          	bgeu	a5,s8,c61c <_vsnprintf+0x3a7c>
    c5ae:	0785                	addi	a5,a5,1
    c5b0:	1816db0b          	th.sbia	s6,(a3),1,0
    c5b4:	0787f463          	bgeu	a5,s8,c61c <_vsnprintf+0x3a7c>
    c5b8:	50778ce3          	beq	a5,t2,d2d0 <_vsnprintf+0x4730>
    c5bc:	0785                	addi	a5,a5,1
    c5be:	01668023          	sb	s6,0(a3)
    c5c2:	8abe                	mv	s5,a5
    c5c4:	0587fc63          	bgeu	a5,s8,c61c <_vsnprintf+0x3a7c>
    c5c8:	0785                	addi	a5,a5,1
    c5ca:	016680a3          	sb	s6,1(a3)
    c5ce:	0587f763          	bgeu	a5,s8,c61c <_vsnprintf+0x3a7c>
    c5d2:	002a8793          	addi	a5,s5,2
    c5d6:	01668123          	sb	s6,2(a3)
    c5da:	0587f163          	bgeu	a5,s8,c61c <_vsnprintf+0x3a7c>
    c5de:	003a8793          	addi	a5,s5,3
    c5e2:	016681a3          	sb	s6,3(a3)
    c5e6:	0387fb63          	bgeu	a5,s8,c61c <_vsnprintf+0x3a7c>
    c5ea:	004a8793          	addi	a5,s5,4
    c5ee:	01668223          	sb	s6,4(a3)
    c5f2:	0387f563          	bgeu	a5,s8,c61c <_vsnprintf+0x3a7c>
    c5f6:	005a8793          	addi	a5,s5,5
    c5fa:	016682a3          	sb	s6,5(a3)
    c5fe:	0187ff63          	bgeu	a5,s8,c61c <_vsnprintf+0x3a7c>
    c602:	006a8793          	addi	a5,s5,6
    c606:	01668323          	sb	s6,6(a3)
    c60a:	0187f963          	bgeu	a5,s8,c61c <_vsnprintf+0x3a7c>
    c60e:	016683a3          	sb	s6,7(a3)
    c612:	007a8793          	addi	a5,s5,7
    c616:	06a1                	addi	a3,a3,8
    c618:	fb87e0e3          	bltu	a5,s8,c5b8 <_vsnprintf+0x3a18>
    c61c:	0e0f8b63          	beqz	t6,c712 <_vsnprintf+0x3b72>
    c620:	7c08bf8b          	th.extu	t6,a7,31,0
    c624:	01f7e463          	bltu	a5,t6,c62c <_vsnprintf+0x3a8c>
    c628:	12d0206f          	j	ef54 <_vsnprintf+0x63b4>
    c62c:	02000293          	li	t0,32
    c630:	40f28d33          	sub	s10,t0,a5
    c634:	007d7393          	andi	t2,s10,7
    c638:	00fb8cb3          	add	s9,s7,a5
    c63c:	03000c13          	li	s8,48
    c640:	06038763          	beqz	t2,c6ae <_vsnprintf+0x3b0e>
    c644:	0785                	addi	a5,a5,1
    c646:	181cdc0b          	th.sbia	s8,(s9),1,0
    c64a:	0df78463          	beq	a5,t6,c712 <_vsnprintf+0x3b72>
    c64e:	4b05                	li	s6,1
    c650:	05638f63          	beq	t2,s6,c6ae <_vsnprintf+0x3b0e>
    c654:	4f09                	li	t5,2
    c656:	05e38763          	beq	t2,t5,c6a4 <_vsnprintf+0x3b04>
    c65a:	430d                	li	t1,3
    c65c:	02638f63          	beq	t2,t1,c69a <_vsnprintf+0x3afa>
    c660:	4811                	li	a6,4
    c662:	03038763          	beq	t2,a6,c690 <_vsnprintf+0x3af0>
    c666:	4e95                	li	t4,5
    c668:	01d38f63          	beq	t2,t4,c686 <_vsnprintf+0x3ae6>
    c66c:	4519                	li	a0,6
    c66e:	00a38763          	beq	t2,a0,c67c <_vsnprintf+0x3adc>
    c672:	0785                	addi	a5,a5,1
    c674:	181cdc0b          	th.sbia	s8,(s9),1,0
    c678:	09f78d63          	beq	a5,t6,c712 <_vsnprintf+0x3b72>
    c67c:	0785                	addi	a5,a5,1
    c67e:	181cdc0b          	th.sbia	s8,(s9),1,0
    c682:	09f78863          	beq	a5,t6,c712 <_vsnprintf+0x3b72>
    c686:	0785                	addi	a5,a5,1
    c688:	181cdc0b          	th.sbia	s8,(s9),1,0
    c68c:	09f78363          	beq	a5,t6,c712 <_vsnprintf+0x3b72>
    c690:	0785                	addi	a5,a5,1
    c692:	181cdc0b          	th.sbia	s8,(s9),1,0
    c696:	07f78e63          	beq	a5,t6,c712 <_vsnprintf+0x3b72>
    c69a:	0785                	addi	a5,a5,1
    c69c:	181cdc0b          	th.sbia	s8,(s9),1,0
    c6a0:	07f78963          	beq	a5,t6,c712 <_vsnprintf+0x3b72>
    c6a4:	0785                	addi	a5,a5,1
    c6a6:	181cdc0b          	th.sbia	s8,(s9),1,0
    c6aa:	07f78463          	beq	a5,t6,c712 <_vsnprintf+0x3b72>
    c6ae:	3e578ae3          	beq	a5,t0,d2a2 <_vsnprintf+0x4702>
    c6b2:	0785                	addi	a5,a5,1
    c6b4:	018c8023          	sb	s8,0(s9)
    c6b8:	863e                	mv	a2,a5
    c6ba:	05f78c63          	beq	a5,t6,c712 <_vsnprintf+0x3b72>
    c6be:	0785                	addi	a5,a5,1
    c6c0:	018c80a3          	sb	s8,1(s9)
    c6c4:	05f78763          	beq	a5,t6,c712 <_vsnprintf+0x3b72>
    c6c8:	00260793          	addi	a5,a2,2
    c6cc:	018c8123          	sb	s8,2(s9)
    c6d0:	05f78163          	beq	a5,t6,c712 <_vsnprintf+0x3b72>
    c6d4:	00360793          	addi	a5,a2,3
    c6d8:	018c81a3          	sb	s8,3(s9)
    c6dc:	03f78b63          	beq	a5,t6,c712 <_vsnprintf+0x3b72>
    c6e0:	00460793          	addi	a5,a2,4
    c6e4:	018c8223          	sb	s8,4(s9)
    c6e8:	03f78563          	beq	a5,t6,c712 <_vsnprintf+0x3b72>
    c6ec:	00560793          	addi	a5,a2,5
    c6f0:	018c82a3          	sb	s8,5(s9)
    c6f4:	01f78f63          	beq	a5,t6,c712 <_vsnprintf+0x3b72>
    c6f8:	00660793          	addi	a5,a2,6
    c6fc:	018c8323          	sb	s8,6(s9)
    c700:	01f78963          	beq	a5,t6,c712 <_vsnprintf+0x3b72>
    c704:	018c83a3          	sb	s8,7(s9)
    c708:	00760793          	addi	a5,a2,7
    c70c:	0ca1                	addi	s9,s9,8
    c70e:	fbf790e3          	bne	a5,t6,c6ae <_vsnprintf+0x3b0e>
    c712:	02000713          	li	a4,32
    c716:	38e786e3          	beq	a5,a4,d2a2 <_vsnprintf+0x4702>
    c71a:	000e4463          	bltz	t3,c722 <_vsnprintf+0x3b82>
    c71e:	2530106f          	j	e170 <_vsnprintf+0x55d0>
    c722:	00278e33          	add	t3,a5,sp
    c726:	02d00513          	li	a0,45
    c72a:	02ae0823          	sb	a0,48(t3)
    c72e:	0035f613          	andi	a2,a1,3
    c732:	00178c13          	addi	s8,a5,1
    c736:	c219                	beqz	a2,c73c <_vsnprintf+0x3b9c>
    c738:	57e0206f          	j	ecb6 <_vsnprintf+0x6116>
    c73c:	7c08bd0b          	th.extu	s10,a7,31,0
    c740:	4b01                	li	s6,0
    c742:	1bac67e3          	bltu	s8,s10,d0f0 <_vsnprintf+0x4550>
    c746:	6302                	ld	t1,0(sp)
    c748:	02d00513          	li	a0,45
    c74c:	cdafe06f          	j	ac26 <_vsnprintf+0x2086>
    c750:	8f32                	mv	t5,a2
    c752:	fe367e13          	andi	t3,a2,-29
    c756:	5c0b98e3          	bnez	s7,d526 <_vsnprintf+0x4986>
    c75a:	4e81                	li	t4,0
    c75c:	ecefd06f          	j	9e2a <_vsnprintf+0x128a>
    c760:	8aee                	mv	s5,s11
    c762:	788acd0b          	th.ldia	s10,(s5),8,0
    c766:	010ffe93          	andi	t4,t6,16
    c76a:	000d1963          	bnez	s10,c77c <_vsnprintf+0x3bdc>
    c76e:	fefffd93          	andi	s11,t6,-17
    c772:	000d861b          	sext.w	a2,s11
    c776:	320b9063          	bnez	s7,ca96 <_vsnprintf+0x3ef6>
    c77a:	4e81                	li	t4,0
    c77c:	02fd5333          	divu	t1,s10,a5
    c780:	83ea                	mv	t2,s10
    c782:	14563f0b          	th.extu	t5,a2,5,5
    c786:	ffff0f93          	addi	t6,t5,-1
    c78a:	020ff713          	andi	a4,t6,32
    c78e:	0377051b          	addiw	a0,a4,55
    c792:	4e25                	li	t3,9
    c794:	03010b13          	addi	s6,sp,48
    c798:	85da                	mv	a1,s6
    c79a:	22f3138b          	th.muls	t2,t1,a5
    c79e:	0ff3fc93          	zext.b	s9,t2
    c7a2:	030c829b          	addiw	t0,s9,48
    c7a6:	01950f3b          	addw	t5,a0,s9
    c7aa:	0ff2fd93          	zext.b	s11,t0
    c7ae:	0fff7713          	zext.b	a4,t5
    c7b2:	007e3fb3          	sltu	t6,t3,t2
    c7b6:	41fd970b          	th.mveqz	a4,s11,t6
    c7ba:	02e10823          	sb	a4,48(sp)
    c7be:	14fd6763          	bltu	s10,a5,c90c <_vsnprintf+0x3d6c>
    c7c2:	03110593          	addi	a1,sp,49
    c7c6:	829a                	mv	t0,t1
    c7c8:	02f2dd33          	divu	s10,t0,a5
    c7cc:	8316                	mv	t1,t0
    c7ce:	22fd130b          	th.muls	t1,s10,a5
    c7d2:	0ff37393          	zext.b	t2,t1
    c7d6:	03038c9b          	addiw	s9,t2,48
    c7da:	00750f3b          	addw	t5,a0,t2
    c7de:	0ffcfd93          	zext.b	s11,s9
    c7e2:	0fff7713          	zext.b	a4,t5
    c7e6:	006e3fb3          	sltu	t6,t3,t1
    c7ea:	41fd970b          	th.mveqz	a4,s11,t6
    c7ee:	00e58023          	sb	a4,0(a1)
    c7f2:	10f2ed63          	bltu	t0,a5,c90c <_vsnprintf+0x3d6c>
    c7f6:	00158c93          	addi	s9,a1,1
    c7fa:	05010293          	addi	t0,sp,80
    c7fe:	11928763          	beq	t0,s9,c90c <_vsnprintf+0x3d6c>
    c802:	02fd5db3          	divu	s11,s10,a5
    c806:	836a                	mv	t1,s10
    c808:	85e6                	mv	a1,s9
    c80a:	22fd930b          	th.muls	t1,s11,a5
    c80e:	0ff37f13          	zext.b	t5,t1
    c812:	030f039b          	addiw	t2,t5,48
    c816:	01e5073b          	addw	a4,a0,t5
    c81a:	0ff3ff93          	zext.b	t6,t2
    c81e:	0ff77f13          	zext.b	t5,a4
    c822:	006e32b3          	sltu	t0,t3,t1
    c826:	405f9f0b          	th.mveqz	t5,t6,t0
    c82a:	01ec8023          	sb	t5,0(s9)
    c82e:	0cfd6f63          	bltu	s10,a5,c90c <_vsnprintf+0x3d6c>
    c832:	02fddd33          	divu	s10,s11,a5
    c836:	836e                	mv	t1,s11
    c838:	22fd130b          	th.muls	t1,s10,a5
    c83c:	0ff37f93          	zext.b	t6,t1
    c840:	030f839b          	addiw	t2,t6,48
    c844:	01f5073b          	addw	a4,a0,t6
    c848:	0ff3ff13          	zext.b	t5,t2
    c84c:	0ff77f93          	zext.b	t6,a4
    c850:	006e32b3          	sltu	t0,t3,t1
    c854:	405f1f8b          	th.mveqz	t6,t5,t0
    c858:	0815df8b          	th.sbib	t6,(a1),1,0
    c85c:	0afde863          	bltu	s11,a5,c90c <_vsnprintf+0x3d6c>
    c860:	02fd5db3          	divu	s11,s10,a5
    c864:	836a                	mv	t1,s10
    c866:	002c8593          	addi	a1,s9,2
    c86a:	22fd930b          	th.muls	t1,s11,a5
    c86e:	0ff37f13          	zext.b	t5,t1
    c872:	030f039b          	addiw	t2,t5,48
    c876:	01e5073b          	addw	a4,a0,t5
    c87a:	0ff3ff93          	zext.b	t6,t2
    c87e:	0ff77f13          	zext.b	t5,a4
    c882:	006e32b3          	sltu	t0,t3,t1
    c886:	405f9f0b          	th.mveqz	t5,t6,t0
    c88a:	01ec8123          	sb	t5,2(s9)
    c88e:	06fd6f63          	bltu	s10,a5,c90c <_vsnprintf+0x3d6c>
    c892:	02fdd2b3          	divu	t0,s11,a5
    c896:	8d6e                	mv	s10,s11
    c898:	003c8593          	addi	a1,s9,3
    c89c:	22f29d0b          	th.muls	s10,t0,a5
    c8a0:	0ffd7313          	zext.b	t1,s10
    c8a4:	0303039b          	addiw	t2,t1,48
    c8a8:	0065073b          	addw	a4,a0,t1
    c8ac:	0ff3ff93          	zext.b	t6,t2
    c8b0:	0ff77f13          	zext.b	t5,a4
    c8b4:	01ae3d33          	sltu	s10,t3,s10
    c8b8:	41af9f0b          	th.mveqz	t5,t6,s10
    c8bc:	01ec81a3          	sb	t5,3(s9)
    c8c0:	04fde663          	bltu	s11,a5,c90c <_vsnprintf+0x3d6c>
    c8c4:	004c8593          	addi	a1,s9,4
    c8c8:	b701                	j	c7c8 <_vsnprintf+0x3c28>
    c8ca:	02000e13          	li	t3,32
    c8ce:	01cc0463          	beq	s8,t3,c8d6 <_vsnprintf+0x3d36>
    c8d2:	04c0206f          	j	e91e <_vsnprintf+0x5d7e>
    c8d6:	04f14503          	lbu	a0,79(sp)
    c8da:	810fd06f          	j	98ea <_vsnprintf+0xd4a>
    c8de:	4b89                	li	s7,2
    c8e0:	4ac1                	li	s5,16
    c8e2:	02000c93          	li	s9,32
    c8e6:	019d1463          	bne	s10,s9,c8ee <_vsnprintf+0x3d4e>
    c8ea:	fabfd06f          	j	a894 <_vsnprintf+0x1cf4>
    c8ee:	001d0793          	addi	a5,s10,1
    c8f2:	9d66                	add	s10,s10,s9
    c8f4:	002d0e33          	add	t3,s10,sp
    c8f8:	05800e93          	li	t4,88
    c8fc:	01de0823          	sb	t4,16(t3)
    c900:	01979463          	bne	a5,s9,c908 <_vsnprintf+0x3d68>
    c904:	f91fd06f          	j	a894 <_vsnprintf+0x1cf4>
    c908:	b21fe06f          	j	b428 <_vsnprintf+0x2888>
    c90c:	416585b3          	sub	a1,a1,s6
    c910:	00267793          	andi	a5,a2,2
    c914:	00158d13          	addi	s10,a1,1
    c918:	8e32                	mv	t3,a2
    c91a:	60078be3          	beqz	a5,d730 <_vsnprintf+0x4b90>
    c91e:	000e8463          	beqz	t4,c926 <_vsnprintf+0x3d86>
    c922:	4b70106f          	j	e5d8 <_vsnprintf+0x5a38>
    c926:	02000693          	li	a3,32
    c92a:	4809                	li	a6,2
    c92c:	00dd0463          	beq	s10,a3,c934 <_vsnprintf+0x3d94>
    c930:	7550106f          	j	e884 <_vsnprintf+0x5ce4>
    c934:	6382                	ld	t2,0(sp)
    c936:	8bc2                	mv	s7,a6
    c938:	02000d13          	li	s10,32
    c93c:	007d0cb3          	add	s9,s10,t2
    c940:	01ab0c33          	add	s8,s6,s10
    c944:	007d7d13          	andi	s10,s10,7
    c948:	019b0db3          	add	s11,s6,s9
    c94c:	0a0d0763          	beqz	s10,c9fa <_vsnprintf+0x3e5a>
    c950:	4805                	li	a6,1
    c952:	090d0763          	beq	s10,a6,c9e0 <_vsnprintf+0x3e40>
    c956:	4309                	li	t1,2
    c958:	066d0b63          	beq	s10,t1,c9ce <_vsnprintf+0x3e2e>
    c95c:	468d                	li	a3,3
    c95e:	04dd0f63          	beq	s10,a3,c9bc <_vsnprintf+0x3e1c>
    c962:	4e11                	li	t3,4
    c964:	05cd0363          	beq	s10,t3,c9aa <_vsnprintf+0x3e0a>
    c968:	4295                	li	t0,5
    c96a:	025d0763          	beq	s10,t0,c998 <_vsnprintf+0x3df8>
    c96e:	4f99                	li	t6,6
    c970:	01fd0b63          	beq	s10,t6,c986 <_vsnprintf+0x3de6>
    c974:	418d8633          	sub	a2,s11,s8
    c978:	89fc450b          	th.lbuib	a0,(s8),-1,0
    c97c:	ec46                	sd	a7,24(sp)
    c97e:	86a6                	mv	a3,s1
    c980:	85ca                	mv	a1,s2
    c982:	9402                	jalr	s0
    c984:	68e2                	ld	a7,24(sp)
    c986:	418d8633          	sub	a2,s11,s8
    c98a:	89fc450b          	th.lbuib	a0,(s8),-1,0
    c98e:	ec46                	sd	a7,24(sp)
    c990:	86a6                	mv	a3,s1
    c992:	85ca                	mv	a1,s2
    c994:	9402                	jalr	s0
    c996:	68e2                	ld	a7,24(sp)
    c998:	418d8633          	sub	a2,s11,s8
    c99c:	89fc450b          	th.lbuib	a0,(s8),-1,0
    c9a0:	ec46                	sd	a7,24(sp)
    c9a2:	86a6                	mv	a3,s1
    c9a4:	85ca                	mv	a1,s2
    c9a6:	9402                	jalr	s0
    c9a8:	68e2                	ld	a7,24(sp)
    c9aa:	418d8633          	sub	a2,s11,s8
    c9ae:	89fc450b          	th.lbuib	a0,(s8),-1,0
    c9b2:	ec46                	sd	a7,24(sp)
    c9b4:	86a6                	mv	a3,s1
    c9b6:	85ca                	mv	a1,s2
    c9b8:	9402                	jalr	s0
    c9ba:	68e2                	ld	a7,24(sp)
    c9bc:	418d8633          	sub	a2,s11,s8
    c9c0:	89fc450b          	th.lbuib	a0,(s8),-1,0
    c9c4:	ec46                	sd	a7,24(sp)
    c9c6:	86a6                	mv	a3,s1
    c9c8:	85ca                	mv	a1,s2
    c9ca:	9402                	jalr	s0
    c9cc:	68e2                	ld	a7,24(sp)
    c9ce:	418d8633          	sub	a2,s11,s8
    c9d2:	89fc450b          	th.lbuib	a0,(s8),-1,0
    c9d6:	ec46                	sd	a7,24(sp)
    c9d8:	86a6                	mv	a3,s1
    c9da:	85ca                	mv	a1,s2
    c9dc:	9402                	jalr	s0
    c9de:	68e2                	ld	a7,24(sp)
    c9e0:	418d8633          	sub	a2,s11,s8
    c9e4:	89fc450b          	th.lbuib	a0,(s8),-1,0
    c9e8:	ec66                	sd	s9,24(sp)
    c9ea:	f046                	sd	a7,32(sp)
    c9ec:	86a6                	mv	a3,s1
    c9ee:	85ca                	mv	a1,s2
    c9f0:	9402                	jalr	s0
    c9f2:	63e2                	ld	t2,24(sp)
    c9f4:	7882                	ld	a7,32(sp)
    c9f6:	098b0a63          	beq	s6,s8,ca8a <_vsnprintf+0x3eea>
    c9fa:	ec56                	sd	s5,24(sp)
    c9fc:	f05e                	sd	s7,32(sp)
    c9fe:	8bc6                	mv	s7,a7
    ca00:	8d62                	mv	s10,s8
    ca02:	89fd450b          	th.lbuib	a0,(s10),-1,0
    ca06:	418d8633          	sub	a2,s11,s8
    ca0a:	86a6                	mv	a3,s1
    ca0c:	85ca                	mv	a1,s2
    ca0e:	9402                	jalr	s0
    ca10:	8ae2                	mv	s5,s8
    ca12:	89eac50b          	th.lbuib	a0,(s5),-2,0
    ca16:	41ad8633          	sub	a2,s11,s10
    ca1a:	86a6                	mv	a3,s1
    ca1c:	85ca                	mv	a1,s2
    ca1e:	9402                	jalr	s0
    ca20:	8d62                	mv	s10,s8
    ca22:	89dd450b          	th.lbuib	a0,(s10),-3,0
    ca26:	415d8633          	sub	a2,s11,s5
    ca2a:	86a6                	mv	a3,s1
    ca2c:	85ca                	mv	a1,s2
    ca2e:	9402                	jalr	s0
    ca30:	8ae2                	mv	s5,s8
    ca32:	89cac50b          	th.lbuib	a0,(s5),-4,0
    ca36:	41ad8633          	sub	a2,s11,s10
    ca3a:	86a6                	mv	a3,s1
    ca3c:	85ca                	mv	a1,s2
    ca3e:	9402                	jalr	s0
    ca40:	8d62                	mv	s10,s8
    ca42:	89bd450b          	th.lbuib	a0,(s10),-5,0
    ca46:	415d8633          	sub	a2,s11,s5
    ca4a:	86a6                	mv	a3,s1
    ca4c:	85ca                	mv	a1,s2
    ca4e:	9402                	jalr	s0
    ca50:	8ae2                	mv	s5,s8
    ca52:	89aac50b          	th.lbuib	a0,(s5),-6,0
    ca56:	41ad8633          	sub	a2,s11,s10
    ca5a:	86a6                	mv	a3,s1
    ca5c:	85ca                	mv	a1,s2
    ca5e:	9402                	jalr	s0
    ca60:	8d62                	mv	s10,s8
    ca62:	899d450b          	th.lbuib	a0,(s10),-7,0
    ca66:	86a6                	mv	a3,s1
    ca68:	415d8633          	sub	a2,s11,s5
    ca6c:	85ca                	mv	a1,s2
    ca6e:	9402                	jalr	s0
    ca70:	898c450b          	th.lbuib	a0,(s8),-8,0
    ca74:	86a6                	mv	a3,s1
    ca76:	41ad8633          	sub	a2,s11,s10
    ca7a:	85ca                	mv	a1,s2
    ca7c:	9402                	jalr	s0
    ca7e:	f98b11e3          	bne	s6,s8,ca00 <_vsnprintf+0x3e60>
    ca82:	88de                	mv	a7,s7
    ca84:	6ae2                	ld	s5,24(sp)
    ca86:	7b82                	ld	s7,32(sp)
    ca88:	83e6                	mv	t2,s9
    ca8a:	000b9d63          	bnez	s7,caa4 <_vsnprintf+0x3f04>
    ca8e:	e01e                	sd	t2,0(sp)
    ca90:	8dd6                	mv	s11,s5
    ca92:	9e7fd06f          	j	a478 <_vsnprintf+0x18d8>
    ca96:	002ffe93          	andi	t4,t6,2
    ca9a:	000e9463          	bnez	t4,caa2 <_vsnprintf+0x3f02>
    ca9e:	37b0106f          	j	e618 <_vsnprintf+0x5a78>
    caa2:	6382                	ld	t2,0(sp)
    caa4:	6b02                	ld	s6,0(sp)
    caa6:	7c08bc0b          	th.extu	s8,a7,31,0
    caaa:	41638db3          	sub	s11,t2,s6
    caae:	ff8df0e3          	bgeu	s11,s8,ca8e <_vsnprintf+0x3eee>
    cab2:	fffdc513          	not	a0,s11
    cab6:	018508b3          	add	a7,a0,s8
    caba:	85ca                	mv	a1,s2
    cabc:	86a6                	mv	a3,s1
    cabe:	861e                	mv	a2,t2
    cac0:	02000513          	li	a0,32
    cac4:	e01e                	sd	t2,0(sp)
    cac6:	0078fb93          	andi	s7,a7,7
    caca:	00138b13          	addi	s6,t2,1
    cace:	001d8c93          	addi	s9,s11,1
    cad2:	9402                	jalr	s0
    cad4:	6582                	ld	a1,0(sp)
    cad6:	b98cfd63          	bgeu	s9,s8,be70 <_vsnprintf+0x32d0>
    cada:	0a0b8063          	beqz	s7,cb7a <_vsnprintf+0x3fda>
    cade:	4705                	li	a4,1
    cae0:	08eb8363          	beq	s7,a4,cb66 <_vsnprintf+0x3fc6>
    cae4:	4789                	li	a5,2
    cae6:	06fb8863          	beq	s7,a5,cb56 <_vsnprintf+0x3fb6>
    caea:	460d                	li	a2,3
    caec:	04cb8d63          	beq	s7,a2,cb46 <_vsnprintf+0x3fa6>
    caf0:	4e91                	li	t4,4
    caf2:	05db8263          	beq	s7,t4,cb36 <_vsnprintf+0x3f96>
    caf6:	4815                	li	a6,5
    caf8:	030b8763          	beq	s7,a6,cb26 <_vsnprintf+0x3f86>
    cafc:	4319                	li	t1,6
    cafe:	006b8c63          	beq	s7,t1,cb16 <_vsnprintf+0x3f76>
    cb02:	865a                	mv	a2,s6
    cb04:	86a6                	mv	a3,s1
    cb06:	00258b13          	addi	s6,a1,2
    cb0a:	02000513          	li	a0,32
    cb0e:	85ca                	mv	a1,s2
    cb10:	9402                	jalr	s0
    cb12:	002d8c93          	addi	s9,s11,2
    cb16:	865a                	mv	a2,s6
    cb18:	86a6                	mv	a3,s1
    cb1a:	85ca                	mv	a1,s2
    cb1c:	02000513          	li	a0,32
    cb20:	0b05                	addi	s6,s6,1
    cb22:	9402                	jalr	s0
    cb24:	0c85                	addi	s9,s9,1
    cb26:	865a                	mv	a2,s6
    cb28:	86a6                	mv	a3,s1
    cb2a:	85ca                	mv	a1,s2
    cb2c:	02000513          	li	a0,32
    cb30:	0b05                	addi	s6,s6,1
    cb32:	9402                	jalr	s0
    cb34:	0c85                	addi	s9,s9,1
    cb36:	865a                	mv	a2,s6
    cb38:	86a6                	mv	a3,s1
    cb3a:	85ca                	mv	a1,s2
    cb3c:	02000513          	li	a0,32
    cb40:	0b05                	addi	s6,s6,1
    cb42:	9402                	jalr	s0
    cb44:	0c85                	addi	s9,s9,1
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
    cb70:	0c85                	addi	s9,s9,1
    cb72:	0b05                	addi	s6,s6,1
    cb74:	9402                	jalr	s0
    cb76:	af8cfd63          	bgeu	s9,s8,be70 <_vsnprintf+0x32d0>
    cb7a:	865a                	mv	a2,s6
    cb7c:	86a6                	mv	a3,s1
    cb7e:	85ca                	mv	a1,s2
    cb80:	02000513          	li	a0,32
    cb84:	9402                	jalr	s0
    cb86:	001b0d93          	addi	s11,s6,1
    cb8a:	866e                	mv	a2,s11
    cb8c:	86a6                	mv	a3,s1
    cb8e:	85ca                	mv	a1,s2
    cb90:	02000513          	li	a0,32
    cb94:	9402                	jalr	s0
    cb96:	002b0d13          	addi	s10,s6,2
    cb9a:	866a                	mv	a2,s10
    cb9c:	86a6                	mv	a3,s1
    cb9e:	85ca                	mv	a1,s2
    cba0:	02000513          	li	a0,32
    cba4:	9402                	jalr	s0
    cba6:	003b0b93          	addi	s7,s6,3
    cbaa:	865e                	mv	a2,s7
    cbac:	86a6                	mv	a3,s1
    cbae:	85ca                	mv	a1,s2
    cbb0:	02000513          	li	a0,32
    cbb4:	9402                	jalr	s0
    cbb6:	004b0d93          	addi	s11,s6,4
    cbba:	866e                	mv	a2,s11
    cbbc:	86a6                	mv	a3,s1
    cbbe:	85ca                	mv	a1,s2
    cbc0:	02000513          	li	a0,32
    cbc4:	9402                	jalr	s0
    cbc6:	005b0b93          	addi	s7,s6,5
    cbca:	86a6                	mv	a3,s1
    cbcc:	865e                	mv	a2,s7
    cbce:	85ca                	mv	a1,s2
    cbd0:	02000513          	li	a0,32
    cbd4:	9402                	jalr	s0
    cbd6:	006b0d13          	addi	s10,s6,6
    cbda:	86a6                	mv	a3,s1
    cbdc:	866a                	mv	a2,s10
    cbde:	85ca                	mv	a1,s2
    cbe0:	02000513          	li	a0,32
    cbe4:	9402                	jalr	s0
    cbe6:	007b0d93          	addi	s11,s6,7
    cbea:	86a6                	mv	a3,s1
    cbec:	866e                	mv	a2,s11
    cbee:	85ca                	mv	a1,s2
    cbf0:	02000513          	li	a0,32
    cbf4:	0ca1                	addi	s9,s9,8
    cbf6:	0b21                	addi	s6,s6,8
    cbf8:	9402                	jalr	s0
    cbfa:	f98ce0e3          	bltu	s9,s8,cb7a <_vsnprintf+0x3fda>
    cbfe:	e05a                	sd	s6,0(sp)
    cc00:	a72ff06f          	j	be72 <_vsnprintf+0x32d2>
    cc04:	30088be3          	beqz	a7,d71a <_vsnprintf+0x4b7a>
    cc08:	0016fd93          	andi	s11,a3,1
    cc0c:	000d8463          	beqz	s11,cc14 <_vsnprintf+0x4074>
    cc10:	4580106f          	j	e068 <_vsnprintf+0x54c8>
    cc14:	7c0c3c0b          	th.extu	s8,s8,31,0
    cc18:	a987e863          	bltu	a5,s8,bea8 <_vsnprintf+0x3308>
    cc1c:	02000e13          	li	t3,32
    cc20:	27c78ce3          	beq	a5,t3,d698 <_vsnprintf+0x4af8>
    cc24:	000ec463          	bltz	t4,cc2c <_vsnprintf+0x408c>
    cc28:	0410106f          	j	e468 <_vsnprintf+0x58c8>
    cc2c:	01c78633          	add	a2,a5,t3
    cc30:	03010f93          	addi	t6,sp,48
    cc34:	01f603b3          	add	t2,a2,t6
    cc38:	02d00713          	li	a4,45
    cc3c:	00178c13          	addi	s8,a5,1
    cc40:	fee38023          	sb	a4,-32(t2)
    cc44:	7c08bb8b          	th.extu	s7,a7,31,0
    cc48:	8dc2                	mv	s11,a6
    cc4a:	4b01                	li	s6,0
    cc4c:	017c6463          	bltu	s8,s7,cc54 <_vsnprintf+0x40b4>
    cc50:	6b30106f          	j	eb02 <_vsnprintf+0x5f62>
    cc54:	6602                	ld	a2,0(sp)
    cc56:	85ca                	mv	a1,s2
    cc58:	86a6                	mv	a3,s1
    cc5a:	40cc0cb3          	sub	s9,s8,a2
    cc5e:	fffcc393          	not	t2,s9
    cc62:	40c387b3          	sub	a5,t2,a2
    cc66:	01778eb3          	add	t4,a5,s7
    cc6a:	ec66                	sd	s9,24(sp)
    cc6c:	f046                	sd	a7,32(sp)
    cc6e:	02000513          	li	a0,32
    cc72:	00160d13          	addi	s10,a2,1
    cc76:	007efa93          	andi	s5,t4,7
    cc7a:	9402                	jalr	s0
    cc7c:	01ac85b3          	add	a1,s9,s10
    cc80:	7882                	ld	a7,32(sp)
    cc82:	1575f563          	bgeu	a1,s7,cdcc <_vsnprintf+0x422c>
    cc86:	0a0a8963          	beqz	s5,cd38 <_vsnprintf+0x4198>
    cc8a:	4685                	li	a3,1
    cc8c:	08da8863          	beq	s5,a3,cd1c <_vsnprintf+0x417c>
    cc90:	4f89                	li	t6,2
    cc92:	07fa8c63          	beq	s5,t6,cd0a <_vsnprintf+0x416a>
    cc96:	480d                	li	a6,3
    cc98:	070a8063          	beq	s5,a6,ccf8 <_vsnprintf+0x4158>
    cc9c:	4711                	li	a4,4
    cc9e:	04ea8463          	beq	s5,a4,cce6 <_vsnprintf+0x4146>
    cca2:	4f15                	li	t5,5
    cca4:	03ea8863          	beq	s5,t5,ccd4 <_vsnprintf+0x4134>
    cca8:	4299                	li	t0,6
    ccaa:	005a8c63          	beq	s5,t0,ccc2 <_vsnprintf+0x4122>
    ccae:	866a                	mv	a2,s10
    ccb0:	f046                	sd	a7,32(sp)
    ccb2:	86a6                	mv	a3,s1
    ccb4:	85ca                	mv	a1,s2
    ccb6:	02000513          	li	a0,32
    ccba:	6d02                	ld	s10,0(sp)
    ccbc:	9402                	jalr	s0
    ccbe:	7882                	ld	a7,32(sp)
    ccc0:	0d09                	addi	s10,s10,2
    ccc2:	866a                	mv	a2,s10
    ccc4:	f046                	sd	a7,32(sp)
    ccc6:	86a6                	mv	a3,s1
    ccc8:	85ca                	mv	a1,s2
    ccca:	02000513          	li	a0,32
    ccce:	9402                	jalr	s0
    ccd0:	7882                	ld	a7,32(sp)
    ccd2:	0d05                	addi	s10,s10,1
    ccd4:	866a                	mv	a2,s10
    ccd6:	f046                	sd	a7,32(sp)
    ccd8:	86a6                	mv	a3,s1
    ccda:	85ca                	mv	a1,s2
    ccdc:	02000513          	li	a0,32
    cce0:	9402                	jalr	s0
    cce2:	7882                	ld	a7,32(sp)
    cce4:	0d05                	addi	s10,s10,1
    cce6:	866a                	mv	a2,s10
    cce8:	f046                	sd	a7,32(sp)
    ccea:	86a6                	mv	a3,s1
    ccec:	85ca                	mv	a1,s2
    ccee:	02000513          	li	a0,32
    ccf2:	9402                	jalr	s0
    ccf4:	7882                	ld	a7,32(sp)
    ccf6:	0d05                	addi	s10,s10,1
    ccf8:	866a                	mv	a2,s10
    ccfa:	f046                	sd	a7,32(sp)
    ccfc:	86a6                	mv	a3,s1
    ccfe:	85ca                	mv	a1,s2
    cd00:	02000513          	li	a0,32
    cd04:	9402                	jalr	s0
    cd06:	7882                	ld	a7,32(sp)
    cd08:	0d05                	addi	s10,s10,1
    cd0a:	866a                	mv	a2,s10
    cd0c:	f046                	sd	a7,32(sp)
    cd0e:	86a6                	mv	a3,s1
    cd10:	85ca                	mv	a1,s2
    cd12:	02000513          	li	a0,32
    cd16:	9402                	jalr	s0
    cd18:	7882                	ld	a7,32(sp)
    cd1a:	0d05                	addi	s10,s10,1
    cd1c:	866a                	mv	a2,s10
    cd1e:	02000513          	li	a0,32
    cd22:	f046                	sd	a7,32(sp)
    cd24:	86a6                	mv	a3,s1
    cd26:	85ca                	mv	a1,s2
    cd28:	9402                	jalr	s0
    cd2a:	6362                	ld	t1,24(sp)
    cd2c:	7882                	ld	a7,32(sp)
    cd2e:	0d05                	addi	s10,s10,1
    cd30:	01a30533          	add	a0,t1,s10
    cd34:	09757c63          	bgeu	a0,s7,cdcc <_vsnprintf+0x422c>
    cd38:	f06e                	sd	s11,32(sp)
    cd3a:	8dda                	mv	s11,s6
    cd3c:	8b46                	mv	s6,a7
    cd3e:	866a                	mv	a2,s10
    cd40:	86a6                	mv	a3,s1
    cd42:	85ca                	mv	a1,s2
    cd44:	02000513          	li	a0,32
    cd48:	9402                	jalr	s0
    cd4a:	001d0a93          	addi	s5,s10,1
    cd4e:	8656                	mv	a2,s5
    cd50:	86a6                	mv	a3,s1
    cd52:	85ca                	mv	a1,s2
    cd54:	02000513          	li	a0,32
    cd58:	9402                	jalr	s0
    cd5a:	002d0c93          	addi	s9,s10,2
    cd5e:	8666                	mv	a2,s9
    cd60:	86a6                	mv	a3,s1
    cd62:	85ca                	mv	a1,s2
    cd64:	02000513          	li	a0,32
    cd68:	9402                	jalr	s0
    cd6a:	003d0a93          	addi	s5,s10,3
    cd6e:	8656                	mv	a2,s5
    cd70:	86a6                	mv	a3,s1
    cd72:	85ca                	mv	a1,s2
    cd74:	02000513          	li	a0,32
    cd78:	9402                	jalr	s0
    cd7a:	004d0c93          	addi	s9,s10,4
    cd7e:	8666                	mv	a2,s9
    cd80:	86a6                	mv	a3,s1
    cd82:	85ca                	mv	a1,s2
    cd84:	02000513          	li	a0,32
    cd88:	9402                	jalr	s0
    cd8a:	005d0a93          	addi	s5,s10,5
    cd8e:	8656                	mv	a2,s5
    cd90:	86a6                	mv	a3,s1
    cd92:	85ca                	mv	a1,s2
    cd94:	02000513          	li	a0,32
    cd98:	9402                	jalr	s0
    cd9a:	006d0c93          	addi	s9,s10,6
    cd9e:	86a6                	mv	a3,s1
    cda0:	8666                	mv	a2,s9
    cda2:	85ca                	mv	a1,s2
    cda4:	02000513          	li	a0,32
    cda8:	9402                	jalr	s0
    cdaa:	007d0a93          	addi	s5,s10,7
    cdae:	86a6                	mv	a3,s1
    cdb0:	8656                	mv	a2,s5
    cdb2:	85ca                	mv	a1,s2
    cdb4:	02000513          	li	a0,32
    cdb8:	9402                	jalr	s0
    cdba:	68e2                	ld	a7,24(sp)
    cdbc:	0d21                	addi	s10,s10,8
    cdbe:	01a88e33          	add	t3,a7,s10
    cdc2:	f77e6ee3          	bltu	t3,s7,cd3e <_vsnprintf+0x419e>
    cdc6:	88da                	mv	a7,s6
    cdc8:	8b6e                	mv	s6,s11
    cdca:	7d82                	ld	s11,32(sp)
    cdcc:	6682                	ld	a3,0(sp)
    cdce:	fffb8613          	addi	a2,s7,-1
    cdd2:	001c0793          	addi	a5,s8,1
    cdd6:	418603b3          	sub	t2,a2,s8
    cdda:	00fbbeb3          	sltu	t4,s7,a5
    cdde:	43d0138b          	th.mvnez	t2,zero,t4
    cde2:	00168f93          	addi	t6,a3,1
    cde6:	01f38833          	add	a6,t2,t6
    cdea:	8e42                	mv	t3,a6
    cdec:	da0c0863          	beqz	s8,c39c <_vsnprintf+0x37fc>
    cdf0:	03010c93          	addi	s9,sp,48
    cdf4:	019c0733          	add	a4,s8,s9
    cdf8:	fff74503          	lbu	a0,-1(a4)
    cdfc:	c3eff06f          	j	c23a <_vsnprintf+0x369a>
    ce00:	54088fe3          	beqz	a7,db5e <_vsnprintf+0x4fbe>
    ce04:	00167b13          	andi	s6,a2,1
    ce08:	7c0c350b          	th.extu	a0,s8,31,0
    ce0c:	000b1463          	bnez	s6,ce14 <_vsnprintf+0x4274>
    ce10:	0e80106f          	j	def8 <_vsnprintf+0x5358>
    ce14:	0ea77763          	bgeu	a4,a0,cf02 <_vsnprintf+0x4362>
    ce18:	02000593          	li	a1,32
    ce1c:	40e582b3          	sub	t0,a1,a4
    ce20:	0072f393          	andi	t2,t0,7
    ce24:	00e80f33          	add	t5,a6,a4
    ce28:	03000f93          	li	t6,48
    ce2c:	06038763          	beqz	t2,ce9a <_vsnprintf+0x42fa>
    ce30:	0705                	addi	a4,a4,1
    ce32:	181f5f8b          	th.sbia	t6,(t5),1,0
    ce36:	0ca77463          	bgeu	a4,a0,cefe <_vsnprintf+0x435e>
    ce3a:	4a85                	li	s5,1
    ce3c:	05538f63          	beq	t2,s5,ce9a <_vsnprintf+0x42fa>
    ce40:	4309                	li	t1,2
    ce42:	04638763          	beq	t2,t1,ce90 <_vsnprintf+0x42f0>
    ce46:	478d                	li	a5,3
    ce48:	02f38f63          	beq	t2,a5,ce86 <_vsnprintf+0x42e6>
    ce4c:	4611                	li	a2,4
    ce4e:	02c38763          	beq	t2,a2,ce7c <_vsnprintf+0x42dc>
    ce52:	4c95                	li	s9,5
    ce54:	01938f63          	beq	t2,s9,ce72 <_vsnprintf+0x42d2>
    ce58:	4299                	li	t0,6
    ce5a:	00538763          	beq	t2,t0,ce68 <_vsnprintf+0x42c8>
    ce5e:	0705                	addi	a4,a4,1
    ce60:	181f5f8b          	th.sbia	t6,(t5),1,0
    ce64:	08a77d63          	bgeu	a4,a0,cefe <_vsnprintf+0x435e>
    ce68:	0705                	addi	a4,a4,1
    ce6a:	181f5f8b          	th.sbia	t6,(t5),1,0
    ce6e:	08a77863          	bgeu	a4,a0,cefe <_vsnprintf+0x435e>
    ce72:	0705                	addi	a4,a4,1
    ce74:	181f5f8b          	th.sbia	t6,(t5),1,0
    ce78:	08a77363          	bgeu	a4,a0,cefe <_vsnprintf+0x435e>
    ce7c:	0705                	addi	a4,a4,1
    ce7e:	181f5f8b          	th.sbia	t6,(t5),1,0
    ce82:	06a77e63          	bgeu	a4,a0,cefe <_vsnprintf+0x435e>
    ce86:	0705                	addi	a4,a4,1
    ce88:	181f5f8b          	th.sbia	t6,(t5),1,0
    ce8c:	06a77963          	bgeu	a4,a0,cefe <_vsnprintf+0x435e>
    ce90:	0705                	addi	a4,a4,1
    ce92:	181f5f8b          	th.sbia	t6,(t5),1,0
    ce96:	06a77463          	bgeu	a4,a0,cefe <_vsnprintf+0x435e>
    ce9a:	06b70263          	beq	a4,a1,cefe <_vsnprintf+0x435e>
    ce9e:	0705                	addi	a4,a4,1
    cea0:	01ff0023          	sb	t6,0(t5)
    cea4:	83ba                	mv	t2,a4
    cea6:	04a77c63          	bgeu	a4,a0,cefe <_vsnprintf+0x435e>
    ceaa:	0705                	addi	a4,a4,1
    ceac:	01ff00a3          	sb	t6,1(t5)
    ceb0:	04a77763          	bgeu	a4,a0,cefe <_vsnprintf+0x435e>
    ceb4:	00238713          	addi	a4,t2,2
    ceb8:	01ff0123          	sb	t6,2(t5)
    cebc:	04a77163          	bgeu	a4,a0,cefe <_vsnprintf+0x435e>
    cec0:	00338713          	addi	a4,t2,3
    cec4:	01ff01a3          	sb	t6,3(t5)
    cec8:	02a77b63          	bgeu	a4,a0,cefe <_vsnprintf+0x435e>
    cecc:	00438713          	addi	a4,t2,4
    ced0:	01ff0223          	sb	t6,4(t5)
    ced4:	02a77563          	bgeu	a4,a0,cefe <_vsnprintf+0x435e>
    ced8:	00538713          	addi	a4,t2,5
    cedc:	01ff02a3          	sb	t6,5(t5)
    cee0:	00a77f63          	bgeu	a4,a0,cefe <_vsnprintf+0x435e>
    cee4:	00638713          	addi	a4,t2,6
    cee8:	01ff0323          	sb	t6,6(t5)
    ceec:	00a77963          	bgeu	a4,a0,cefe <_vsnprintf+0x435e>
    cef0:	01ff03a3          	sb	t6,7(t5)
    cef4:	00738713          	addi	a4,t2,7
    cef8:	0f21                	addi	t5,t5,8
    cefa:	faa760e3          	bltu	a4,a0,ce9a <_vsnprintf+0x42fa>
    cefe:	5a0b07e3          	beqz	s6,dcac <_vsnprintf+0x510c>
    cf02:	7c08b78b          	th.extu	a5,a7,31,0
    cf06:	00f76463          	bltu	a4,a5,cf0e <_vsnprintf+0x436e>
    cf0a:	6e70106f          	j	edf0 <_vsnprintf+0x6250>
    cf0e:	02000b13          	li	s6,32
    cf12:	40eb0fb3          	sub	t6,s6,a4
    cf16:	007ffa93          	andi	s5,t6,7
    cf1a:	00e805b3          	add	a1,a6,a4
    cf1e:	03000513          	li	a0,48
    cf22:	060a8763          	beqz	s5,cf90 <_vsnprintf+0x43f0>
    cf26:	0705                	addi	a4,a4,1
    cf28:	1815d50b          	th.sbia	a0,(a1),1,0
    cf2c:	0ce78463          	beq	a5,a4,cff4 <_vsnprintf+0x4454>
    cf30:	4305                	li	t1,1
    cf32:	046a8f63          	beq	s5,t1,cf90 <_vsnprintf+0x43f0>
    cf36:	4609                	li	a2,2
    cf38:	04ca8763          	beq	s5,a2,cf86 <_vsnprintf+0x43e6>
    cf3c:	4c8d                	li	s9,3
    cf3e:	039a8f63          	beq	s5,s9,cf7c <_vsnprintf+0x43dc>
    cf42:	4291                	li	t0,4
    cf44:	025a8763          	beq	s5,t0,cf72 <_vsnprintf+0x43d2>
    cf48:	4395                	li	t2,5
    cf4a:	007a8f63          	beq	s5,t2,cf68 <_vsnprintf+0x43c8>
    cf4e:	4f19                	li	t5,6
    cf50:	01ea8763          	beq	s5,t5,cf5e <_vsnprintf+0x43be>
    cf54:	0705                	addi	a4,a4,1
    cf56:	1815d50b          	th.sbia	a0,(a1),1,0
    cf5a:	08e78d63          	beq	a5,a4,cff4 <_vsnprintf+0x4454>
    cf5e:	0705                	addi	a4,a4,1
    cf60:	1815d50b          	th.sbia	a0,(a1),1,0
    cf64:	08e78863          	beq	a5,a4,cff4 <_vsnprintf+0x4454>
    cf68:	0705                	addi	a4,a4,1
    cf6a:	1815d50b          	th.sbia	a0,(a1),1,0
    cf6e:	08e78363          	beq	a5,a4,cff4 <_vsnprintf+0x4454>
    cf72:	0705                	addi	a4,a4,1
    cf74:	1815d50b          	th.sbia	a0,(a1),1,0
    cf78:	06e78e63          	beq	a5,a4,cff4 <_vsnprintf+0x4454>
    cf7c:	0705                	addi	a4,a4,1
    cf7e:	1815d50b          	th.sbia	a0,(a1),1,0
    cf82:	06e78963          	beq	a5,a4,cff4 <_vsnprintf+0x4454>
    cf86:	0705                	addi	a4,a4,1
    cf88:	1815d50b          	th.sbia	a0,(a1),1,0
    cf8c:	06e78463          	beq	a5,a4,cff4 <_vsnprintf+0x4454>
    cf90:	47670ae3          	beq	a4,s6,dc04 <_vsnprintf+0x5064>
    cf94:	0705                	addi	a4,a4,1
    cf96:	00a58023          	sb	a0,0(a1)
    cf9a:	8fba                	mv	t6,a4
    cf9c:	04e78c63          	beq	a5,a4,cff4 <_vsnprintf+0x4454>
    cfa0:	0705                	addi	a4,a4,1
    cfa2:	00a580a3          	sb	a0,1(a1)
    cfa6:	04e78763          	beq	a5,a4,cff4 <_vsnprintf+0x4454>
    cfaa:	002f8713          	addi	a4,t6,2
    cfae:	00a58123          	sb	a0,2(a1)
    cfb2:	04e78163          	beq	a5,a4,cff4 <_vsnprintf+0x4454>
    cfb6:	003f8713          	addi	a4,t6,3
    cfba:	00a581a3          	sb	a0,3(a1)
    cfbe:	02e78b63          	beq	a5,a4,cff4 <_vsnprintf+0x4454>
    cfc2:	004f8713          	addi	a4,t6,4
    cfc6:	00a58223          	sb	a0,4(a1)
    cfca:	02e78563          	beq	a5,a4,cff4 <_vsnprintf+0x4454>
    cfce:	005f8713          	addi	a4,t6,5
    cfd2:	00a582a3          	sb	a0,5(a1)
    cfd6:	00e78f63          	beq	a5,a4,cff4 <_vsnprintf+0x4454>
    cfda:	006f8713          	addi	a4,t6,6
    cfde:	00a58323          	sb	a0,6(a1)
    cfe2:	00e78963          	beq	a5,a4,cff4 <_vsnprintf+0x4454>
    cfe6:	00a583a3          	sb	a0,7(a1)
    cfea:	007f8713          	addi	a4,t6,7
    cfee:	05a1                	addi	a1,a1,8
    cff0:	fae790e3          	bne	a5,a4,cf90 <_vsnprintf+0x43f0>
    cff4:	140e99e3          	bnez	t4,d946 <_vsnprintf+0x4da6>
    cff8:	01671463          	bne	a4,s6,d000 <_vsnprintf+0x4460>
    cffc:	e4cfe06f          	j	b648 <_vsnprintf+0x2aa8>
    d000:	003e7d13          	andi	s10,t3,3
    d004:	000d0463          	beqz	s10,d00c <_vsnprintf+0x446c>
    d008:	7a10106f          	j	efa8 <_vsnprintf+0x6408>
    d00c:	8c3e                	mv	s8,a5
    d00e:	16f765e3          	bltu	a4,a5,d978 <_vsnprintf+0x4dd8>
    d012:	6e02                	ld	t3,0(sp)
    d014:	e3afe06f          	j	b64e <_vsnprintf+0x2aae>
    d018:	47c1                	li	a5,16
    d01a:	8abe                	mv	s5,a5
    d01c:	01f8f463          	bgeu	a7,t6,d024 <_vsnprintf+0x4484>
    d020:	f0ffd06f          	j	af2e <_vsnprintf+0x238e>
    d024:	000b9463          	bnez	s7,d02c <_vsnprintf+0x448c>
    d028:	c10fe06f          	j	b438 <_vsnprintf+0x2898>
    d02c:	4b81                	li	s7,0
    d02e:	8a0c9ae3          	bnez	s9,c8e2 <_vsnprintf+0x3d42>
    d032:	01fd1463          	bne	s10,t6,d03a <_vsnprintf+0x449a>
    d036:	3ec0106f          	j	e422 <_vsnprintf+0x5882>
    d03a:	8ba794e3          	bne	a5,s10,c8e2 <_vsnprintf+0x3d42>
    d03e:	3ed0006f          	j	dc2a <_vsnprintf+0x508a>
    d042:	0001                	nop
    d044:	ec46                	sd	a7,24(sp)
    d046:	f056                	sd	s5,32(sp)
    d048:	6b82                	ld	s7,0(sp)
    d04a:	8cbe                	mv	s9,a5
    d04c:	a5dfe06f          	j	baa8 <_vsnprintf+0x2f08>
    d050:	000f9463          	bnez	t6,d058 <_vsnprintf+0x44b8>
    d054:	77d0106f          	j	efd0 <_vsnprintf+0x6430>
    d058:	47c1                	li	a5,16
    d05a:	4d01                	li	s10,0
    d05c:	40000c93          	li	s9,1024
    d060:	8abe                	mv	s5,a5
    d062:	03010b13          	addi	s6,sp,48
    d066:	ec9fd06f          	j	af2e <_vsnprintf+0x238e>
    d06a:	588dce0b          	th.lwia	t3,(s11),8,0
    d06e:	41fe551b          	sraiw	a0,t3,0x1f
    d072:	00ae4633          	xor	a2,t3,a0
    d076:	40a603bb          	subw	t2,a2,a0
    d07a:	a3ffd06f          	j	aab8 <_vsnprintf+0x1f18>
    d07e:	00857713          	andi	a4,a0,8
    d082:	40071fe3          	bnez	a4,dca0 <_vsnprintf+0x5100>
    d086:	6a82                	ld	s5,0(sp)
    d088:	4d01                	li	s10,0
    d08a:	4bc1                	li	s7,16
    d08c:	96dfd06f          	j	a9f8 <_vsnprintf+0x1e58>
    d090:	05800f13          	li	t5,88
    d094:	05e10023          	sb	t5,64(sp)
    d098:	4b81                	li	s7,0
    d09a:	47c5                	li	a5,17
    d09c:	b8cfe06f          	j	b428 <_vsnprintf+0x2888>
    d0a0:	0025fb93          	andi	s7,a1,2
    d0a4:	8d2e                	mv	s10,a1
    d0a6:	300b97e3          	bnez	s7,dbb4 <_vsnprintf+0x5014>
    d0aa:	00089463          	bnez	a7,d0b2 <_vsnprintf+0x4512>
    d0ae:	0b40106f          	j	e162 <_vsnprintf+0x55c2>
    d0b2:	001d7f93          	andi	t6,s10,1
    d0b6:	000f8463          	beqz	t6,d0be <_vsnprintf+0x451e>
    d0ba:	4e20106f          	j	e59c <_vsnprintf+0x59fc>
    d0be:	7c0c3c0b          	th.extu	s8,s8,31,0
    d0c2:	4781                	li	a5,0
    d0c4:	03010b93          	addi	s7,sp,48
    d0c8:	c60c1763          	bnez	s8,c536 <_vsnprintf+0x3996>
    d0cc:	004d7b13          	andi	s6,s10,4
    d0d0:	000b1463          	bnez	s6,d0d8 <_vsnprintf+0x4538>
    d0d4:	6cb0106f          	j	ef9e <_vsnprintf+0x63fe>
    d0d8:	02b00693          	li	a3,43
    d0dc:	02d10823          	sb	a3,48(sp)
    d0e0:	4c05                	li	s8,1
    d0e2:	7c08bd0b          	th.extu	s10,a7,31,0
    d0e6:	4b01                	li	s6,0
    d0e8:	01ac6463          	bltu	s8,s10,d0f0 <_vsnprintf+0x4550>
    d0ec:	6a50106f          	j	ef90 <_vsnprintf+0x63f0>
    d0f0:	6602                	ld	a2,0(sp)
    d0f2:	02000513          	li	a0,32
    d0f6:	86a6                	mv	a3,s1
    d0f8:	40cc0cb3          	sub	s9,s8,a2
    d0fc:	fffcc713          	not	a4,s9
    d100:	40c70fb3          	sub	t6,a4,a2
    d104:	01af8bb3          	add	s7,t6,s10
    d108:	ec66                	sd	s9,24(sp)
    d10a:	f046                	sd	a7,32(sp)
    d10c:	85ca                	mv	a1,s2
    d10e:	007bfa93          	andi	s5,s7,7
    d112:	00160b93          	addi	s7,a2,1
    d116:	9402                	jalr	s0
    d118:	017c8533          	add	a0,s9,s7
    d11c:	7882                	ld	a7,32(sp)
    d11e:	15a57663          	bgeu	a0,s10,d26a <_vsnprintf+0x46ca>
    d122:	0a0a8a63          	beqz	s5,d1d6 <_vsnprintf+0x4636>
    d126:	4685                	li	a3,1
    d128:	08da8963          	beq	s5,a3,d1ba <_vsnprintf+0x461a>
    d12c:	4789                	li	a5,2
    d12e:	06fa8d63          	beq	s5,a5,d1a8 <_vsnprintf+0x4608>
    d132:	428d                	li	t0,3
    d134:	065a8163          	beq	s5,t0,d196 <_vsnprintf+0x45f6>
    d138:	4591                	li	a1,4
    d13a:	04ba8563          	beq	s5,a1,d184 <_vsnprintf+0x45e4>
    d13e:	4395                	li	t2,5
    d140:	027a8963          	beq	s5,t2,d172 <_vsnprintf+0x45d2>
    d144:	4f19                	li	t5,6
    d146:	01ea8d63          	beq	s5,t5,d160 <_vsnprintf+0x45c0>
    d14a:	6302                	ld	t1,0(sp)
    d14c:	865e                	mv	a2,s7
    d14e:	f046                	sd	a7,32(sp)
    d150:	86a6                	mv	a3,s1
    d152:	85ca                	mv	a1,s2
    d154:	02000513          	li	a0,32
    d158:	00230b93          	addi	s7,t1,2
    d15c:	9402                	jalr	s0
    d15e:	7882                	ld	a7,32(sp)
    d160:	865e                	mv	a2,s7
    d162:	f046                	sd	a7,32(sp)
    d164:	86a6                	mv	a3,s1
    d166:	85ca                	mv	a1,s2
    d168:	02000513          	li	a0,32
    d16c:	9402                	jalr	s0
    d16e:	7882                	ld	a7,32(sp)
    d170:	0b85                	addi	s7,s7,1
    d172:	865e                	mv	a2,s7
    d174:	f046                	sd	a7,32(sp)
    d176:	86a6                	mv	a3,s1
    d178:	85ca                	mv	a1,s2
    d17a:	02000513          	li	a0,32
    d17e:	9402                	jalr	s0
    d180:	7882                	ld	a7,32(sp)
    d182:	0b85                	addi	s7,s7,1
    d184:	865e                	mv	a2,s7
    d186:	f046                	sd	a7,32(sp)
    d188:	86a6                	mv	a3,s1
    d18a:	85ca                	mv	a1,s2
    d18c:	02000513          	li	a0,32
    d190:	9402                	jalr	s0
    d192:	7882                	ld	a7,32(sp)
    d194:	0b85                	addi	s7,s7,1
    d196:	865e                	mv	a2,s7
    d198:	f046                	sd	a7,32(sp)
    d19a:	86a6                	mv	a3,s1
    d19c:	85ca                	mv	a1,s2
    d19e:	02000513          	li	a0,32
    d1a2:	9402                	jalr	s0
    d1a4:	7882                	ld	a7,32(sp)
    d1a6:	0b85                	addi	s7,s7,1
    d1a8:	865e                	mv	a2,s7
    d1aa:	f046                	sd	a7,32(sp)
    d1ac:	86a6                	mv	a3,s1
    d1ae:	85ca                	mv	a1,s2
    d1b0:	02000513          	li	a0,32
    d1b4:	9402                	jalr	s0
    d1b6:	7882                	ld	a7,32(sp)
    d1b8:	0b85                	addi	s7,s7,1
    d1ba:	865e                	mv	a2,s7
    d1bc:	f046                	sd	a7,32(sp)
    d1be:	86a6                	mv	a3,s1
    d1c0:	85ca                	mv	a1,s2
    d1c2:	02000513          	li	a0,32
    d1c6:	9402                	jalr	s0
    d1c8:	6862                	ld	a6,24(sp)
    d1ca:	7882                	ld	a7,32(sp)
    d1cc:	0b85                	addi	s7,s7,1
    d1ce:	01780eb3          	add	t4,a6,s7
    d1d2:	09aefc63          	bgeu	t4,s10,d26a <_vsnprintf+0x46ca>
    d1d6:	f06e                	sd	s11,32(sp)
    d1d8:	8dda                	mv	s11,s6
    d1da:	8b46                	mv	s6,a7
    d1dc:	865e                	mv	a2,s7
    d1de:	86a6                	mv	a3,s1
    d1e0:	85ca                	mv	a1,s2
    d1e2:	02000513          	li	a0,32
    d1e6:	9402                	jalr	s0
    d1e8:	001b8a93          	addi	s5,s7,1
    d1ec:	8656                	mv	a2,s5
    d1ee:	86a6                	mv	a3,s1
    d1f0:	85ca                	mv	a1,s2
    d1f2:	02000513          	li	a0,32
    d1f6:	9402                	jalr	s0
    d1f8:	002b8c93          	addi	s9,s7,2
    d1fc:	8666                	mv	a2,s9
    d1fe:	86a6                	mv	a3,s1
    d200:	85ca                	mv	a1,s2
    d202:	02000513          	li	a0,32
    d206:	9402                	jalr	s0
    d208:	003b8a93          	addi	s5,s7,3
    d20c:	8656                	mv	a2,s5
    d20e:	86a6                	mv	a3,s1
    d210:	85ca                	mv	a1,s2
    d212:	02000513          	li	a0,32
    d216:	9402                	jalr	s0
    d218:	004b8c93          	addi	s9,s7,4
    d21c:	8666                	mv	a2,s9
    d21e:	86a6                	mv	a3,s1
    d220:	85ca                	mv	a1,s2
    d222:	02000513          	li	a0,32
    d226:	9402                	jalr	s0
    d228:	005b8a93          	addi	s5,s7,5
    d22c:	8656                	mv	a2,s5
    d22e:	86a6                	mv	a3,s1
    d230:	85ca                	mv	a1,s2
    d232:	02000513          	li	a0,32
    d236:	9402                	jalr	s0
    d238:	006b8c93          	addi	s9,s7,6
    d23c:	86a6                	mv	a3,s1
    d23e:	8666                	mv	a2,s9
    d240:	85ca                	mv	a1,s2
    d242:	02000513          	li	a0,32
    d246:	9402                	jalr	s0
    d248:	007b8a93          	addi	s5,s7,7
    d24c:	86a6                	mv	a3,s1
    d24e:	8656                	mv	a2,s5
    d250:	85ca                	mv	a1,s2
    d252:	02000513          	li	a0,32
    d256:	9402                	jalr	s0
    d258:	68e2                	ld	a7,24(sp)
    d25a:	0ba1                	addi	s7,s7,8
    d25c:	01788e33          	add	t3,a7,s7
    d260:	f7ae6ee3          	bltu	t3,s10,d1dc <_vsnprintf+0x463c>
    d264:	88da                	mv	a7,s6
    d266:	8b6e                	mv	s6,s11
    d268:	7d82                	ld	s11,32(sp)
    d26a:	6682                	ld	a3,0(sp)
    d26c:	fffd0613          	addi	a2,s10,-1
    d270:	001c0713          	addi	a4,s8,1
    d274:	41860fb3          	sub	t6,a2,s8
    d278:	00ed3533          	sltu	a0,s10,a4
    d27c:	42a01f8b          	th.mvnez	t6,zero,a0
    d280:	00168793          	addi	a5,a3,1
    d284:	00ff8333          	add	t1,t6,a5
    d288:	8a9a                	mv	s5,t1
    d28a:	000c1463          	bnez	s8,d292 <_vsnprintf+0x46f2>
    d28e:	afbfd06f          	j	ad88 <_vsnprintf+0x21e8>
    d292:	002c03b3          	add	t2,s8,sp
    d296:	02f3c503          	lbu	a0,47(t2)
    d29a:	03010b93          	addi	s7,sp,48
    d29e:	989fd06f          	j	ac26 <_vsnprintf+0x2086>
    d2a2:	0035ff93          	andi	t6,a1,3
    d2a6:	020f9d63          	bnez	t6,d2e0 <_vsnprintf+0x4740>
    d2aa:	02000c13          	li	s8,32
    d2ae:	7c08bd0b          	th.extu	s10,a7,31,0
    d2b2:	4b01                	li	s6,0
    d2b4:	e31c6ee3          	bltu	s8,a7,d0f0 <_vsnprintf+0x4550>
    d2b8:	04f14503          	lbu	a0,79(sp)
    d2bc:	6302                	ld	t1,0(sp)
    d2be:	02000c13          	li	s8,32
    d2c2:	4b01                	li	s6,0
    d2c4:	963fd06f          	j	ac26 <_vsnprintf+0x2086>
    d2c8:	ec46                	sd	a7,24(sp)
    d2ca:	f05a                	sd	s6,32(sp)
    d2cc:	aa5fd06f          	j	ad70 <_vsnprintf+0x21d0>
    d2d0:	fc0f89e3          	beqz	t6,d2a2 <_vsnprintf+0x4702>
    d2d4:	7c08bf8b          	th.extu	t6,a7,31,0
    d2d8:	b5f7ea63          	bltu	a5,t6,c62c <_vsnprintf+0x3a8c>
    d2dc:	898d                	andi	a1,a1,3
    d2de:	dde9                	beqz	a1,d2b8 <_vsnprintf+0x4718>
    d2e0:	4b01                	li	s6,0
    d2e2:	93bfd06f          	j	ac1c <_vsnprintf+0x207c>
    d2e6:	7c0c3c0b          	th.extu	s8,s8,31,0
    d2ea:	0187e463          	bltu	a5,s8,d2f2 <_vsnprintf+0x4752>
    d2ee:	4170106f          	j	ef04 <_vsnprintf+0x6364>
    d2f2:	0015ff93          	andi	t6,a1,1
    d2f6:	4881                	li	a7,0
    d2f8:	a3eff06f          	j	c536 <_vsnprintf+0x3996>
    d2fc:	0a0882e3          	beqz	a7,dba0 <_vsnprintf+0x5000>
    d300:	0015fb13          	andi	s6,a1,1
    d304:	7c0c350b          	th.extu	a0,s8,31,0
    d308:	000b1463          	bnez	s6,d310 <_vsnprintf+0x4770>
    d30c:	32c0106f          	j	e638 <_vsnprintf+0x5a98>
    d310:	0eadf763          	bgeu	s11,a0,d3fe <_vsnprintf+0x485e>
    d314:	02000713          	li	a4,32
    d318:	41b70cb3          	sub	s9,a4,s11
    d31c:	007cff13          	andi	t5,s9,7
    d320:	01b80e33          	add	t3,a6,s11
    d324:	03000293          	li	t0,48
    d328:	060f0763          	beqz	t5,d396 <_vsnprintf+0x47f6>
    d32c:	0d85                	addi	s11,s11,1
    d32e:	181e528b          	th.sbia	t0,(t3),1,0
    d332:	0cadf463          	bgeu	s11,a0,d3fa <_vsnprintf+0x485a>
    d336:	4f85                	li	t6,1
    d338:	05ff0f63          	beq	t5,t6,d396 <_vsnprintf+0x47f6>
    d33c:	4789                	li	a5,2
    d33e:	04ff0763          	beq	t5,a5,d38c <_vsnprintf+0x47ec>
    d342:	458d                	li	a1,3
    d344:	02bf0f63          	beq	t5,a1,d382 <_vsnprintf+0x47e2>
    d348:	4391                	li	t2,4
    d34a:	027f0763          	beq	t5,t2,d378 <_vsnprintf+0x47d8>
    d34e:	4315                	li	t1,5
    d350:	006f0f63          	beq	t5,t1,d36e <_vsnprintf+0x47ce>
    d354:	4e99                	li	t4,6
    d356:	01df0763          	beq	t5,t4,d364 <_vsnprintf+0x47c4>
    d35a:	0d85                	addi	s11,s11,1
    d35c:	181e528b          	th.sbia	t0,(t3),1,0
    d360:	08adfd63          	bgeu	s11,a0,d3fa <_vsnprintf+0x485a>
    d364:	0d85                	addi	s11,s11,1
    d366:	181e528b          	th.sbia	t0,(t3),1,0
    d36a:	08adf863          	bgeu	s11,a0,d3fa <_vsnprintf+0x485a>
    d36e:	0d85                	addi	s11,s11,1
    d370:	181e528b          	th.sbia	t0,(t3),1,0
    d374:	08adf363          	bgeu	s11,a0,d3fa <_vsnprintf+0x485a>
    d378:	0d85                	addi	s11,s11,1
    d37a:	181e528b          	th.sbia	t0,(t3),1,0
    d37e:	06adfe63          	bgeu	s11,a0,d3fa <_vsnprintf+0x485a>
    d382:	0d85                	addi	s11,s11,1
    d384:	181e528b          	th.sbia	t0,(t3),1,0
    d388:	06adf963          	bgeu	s11,a0,d3fa <_vsnprintf+0x485a>
    d38c:	0d85                	addi	s11,s11,1
    d38e:	181e528b          	th.sbia	t0,(t3),1,0
    d392:	06adf463          	bgeu	s11,a0,d3fa <_vsnprintf+0x485a>
    d396:	06ed8263          	beq	s11,a4,d3fa <_vsnprintf+0x485a>
    d39a:	0d85                	addi	s11,s11,1
    d39c:	005e0023          	sb	t0,0(t3)
    d3a0:	8cee                	mv	s9,s11
    d3a2:	04adfc63          	bgeu	s11,a0,d3fa <_vsnprintf+0x485a>
    d3a6:	0d85                	addi	s11,s11,1
    d3a8:	005e00a3          	sb	t0,1(t3)
    d3ac:	04adf763          	bgeu	s11,a0,d3fa <_vsnprintf+0x485a>
    d3b0:	002c8d93          	addi	s11,s9,2
    d3b4:	005e0123          	sb	t0,2(t3)
    d3b8:	04adf163          	bgeu	s11,a0,d3fa <_vsnprintf+0x485a>
    d3bc:	003c8d93          	addi	s11,s9,3
    d3c0:	005e01a3          	sb	t0,3(t3)
    d3c4:	02adfb63          	bgeu	s11,a0,d3fa <_vsnprintf+0x485a>
    d3c8:	004c8d93          	addi	s11,s9,4
    d3cc:	005e0223          	sb	t0,4(t3)
    d3d0:	02adf563          	bgeu	s11,a0,d3fa <_vsnprintf+0x485a>
    d3d4:	005c8d93          	addi	s11,s9,5
    d3d8:	005e02a3          	sb	t0,5(t3)
    d3dc:	00adff63          	bgeu	s11,a0,d3fa <_vsnprintf+0x485a>
    d3e0:	006c8d93          	addi	s11,s9,6
    d3e4:	005e0323          	sb	t0,6(t3)
    d3e8:	00adf963          	bgeu	s11,a0,d3fa <_vsnprintf+0x485a>
    d3ec:	005e03a3          	sb	t0,7(t3)
    d3f0:	007c8d93          	addi	s11,s9,7
    d3f4:	0e21                	addi	t3,t3,8
    d3f6:	faade0e3          	bltu	s11,a0,d396 <_vsnprintf+0x47f6>
    d3fa:	3e0b09e3          	beqz	s6,dfec <_vsnprintf+0x544c>
    d3fe:	7c08b50b          	th.extu	a0,a7,31,0
    d402:	4aadf4e3          	bgeu	s11,a0,e0aa <_vsnprintf+0x550a>
    d406:	02000b13          	li	s6,32
    d40a:	41bb02b3          	sub	t0,s6,s11
    d40e:	0072ff93          	andi	t6,t0,7
    d412:	01b805b3          	add	a1,a6,s11
    d416:	03000713          	li	a4,48
    d41a:	060f8763          	beqz	t6,d488 <_vsnprintf+0x48e8>
    d41e:	0d85                	addi	s11,s11,1
    d420:	1815d70b          	th.sbia	a4,(a1),1,0
    d424:	0db50463          	beq	a0,s11,d4ec <_vsnprintf+0x494c>
    d428:	4f05                	li	t5,1
    d42a:	05ef8f63          	beq	t6,t5,d488 <_vsnprintf+0x48e8>
    d42e:	4789                	li	a5,2
    d430:	04ff8763          	beq	t6,a5,d47e <_vsnprintf+0x48de>
    d434:	438d                	li	t2,3
    d436:	027f8f63          	beq	t6,t2,d474 <_vsnprintf+0x48d4>
    d43a:	4311                	li	t1,4
    d43c:	026f8763          	beq	t6,t1,d46a <_vsnprintf+0x48ca>
    d440:	4e95                	li	t4,5
    d442:	01df8f63          	beq	t6,t4,d460 <_vsnprintf+0x48c0>
    d446:	4c99                	li	s9,6
    d448:	019f8763          	beq	t6,s9,d456 <_vsnprintf+0x48b6>
    d44c:	0d85                	addi	s11,s11,1
    d44e:	1815d70b          	th.sbia	a4,(a1),1,0
    d452:	09b50d63          	beq	a0,s11,d4ec <_vsnprintf+0x494c>
    d456:	0d85                	addi	s11,s11,1
    d458:	1815d70b          	th.sbia	a4,(a1),1,0
    d45c:	09b50863          	beq	a0,s11,d4ec <_vsnprintf+0x494c>
    d460:	0d85                	addi	s11,s11,1
    d462:	1815d70b          	th.sbia	a4,(a1),1,0
    d466:	09b50363          	beq	a0,s11,d4ec <_vsnprintf+0x494c>
    d46a:	0d85                	addi	s11,s11,1
    d46c:	1815d70b          	th.sbia	a4,(a1),1,0
    d470:	07b50e63          	beq	a0,s11,d4ec <_vsnprintf+0x494c>
    d474:	0d85                	addi	s11,s11,1
    d476:	1815d70b          	th.sbia	a4,(a1),1,0
    d47a:	07b50963          	beq	a0,s11,d4ec <_vsnprintf+0x494c>
    d47e:	0d85                	addi	s11,s11,1
    d480:	1815d70b          	th.sbia	a4,(a1),1,0
    d484:	07b50463          	beq	a0,s11,d4ec <_vsnprintf+0x494c>
    d488:	2f6d8ae3          	beq	s11,s6,df7c <_vsnprintf+0x53dc>
    d48c:	0d85                	addi	s11,s11,1
    d48e:	00e58023          	sb	a4,0(a1)
    d492:	82ee                	mv	t0,s11
    d494:	05b50c63          	beq	a0,s11,d4ec <_vsnprintf+0x494c>
    d498:	0d85                	addi	s11,s11,1
    d49a:	00e580a3          	sb	a4,1(a1)
    d49e:	05b50763          	beq	a0,s11,d4ec <_vsnprintf+0x494c>
    d4a2:	00228d93          	addi	s11,t0,2
    d4a6:	00e58123          	sb	a4,2(a1)
    d4aa:	05b50163          	beq	a0,s11,d4ec <_vsnprintf+0x494c>
    d4ae:	00328d93          	addi	s11,t0,3
    d4b2:	00e581a3          	sb	a4,3(a1)
    d4b6:	03b50b63          	beq	a0,s11,d4ec <_vsnprintf+0x494c>
    d4ba:	00428d93          	addi	s11,t0,4
    d4be:	00e58223          	sb	a4,4(a1)
    d4c2:	03b50563          	beq	a0,s11,d4ec <_vsnprintf+0x494c>
    d4c6:	00528d93          	addi	s11,t0,5
    d4ca:	00e582a3          	sb	a4,5(a1)
    d4ce:	01b50f63          	beq	a0,s11,d4ec <_vsnprintf+0x494c>
    d4d2:	00628d93          	addi	s11,t0,6
    d4d6:	00e58323          	sb	a4,6(a1)
    d4da:	01b50963          	beq	a0,s11,d4ec <_vsnprintf+0x494c>
    d4de:	00e583a3          	sb	a4,7(a1)
    d4e2:	00728d93          	addi	s11,t0,7
    d4e6:	05a1                	addi	a1,a1,8
    d4e8:	fbb510e3          	bne	a0,s11,d488 <_vsnprintf+0x48e8>
    d4ec:	000d0463          	beqz	s10,d4f4 <_vsnprintf+0x4954>
    d4f0:	1220106f          	j	e612 <_vsnprintf+0x5a72>
    d4f4:	3d6d91e3          	bne	s11,s6,e0b6 <_vsnprintf+0x5516>
    d4f8:	4d01                	li	s10,0
    d4fa:	e98fe06f          	j	bb92 <_vsnprintf+0x2ff2>
    d4fe:	0001                	nop
    d500:	588dce8b          	th.lwia	t4,(s11),8,0
    d504:	917fc06f          	j	9e1a <_vsnprintf+0x127a>
    d508:	00278eb3          	add	t4,a5,sp
    d50c:	05800713          	li	a4,88
    d510:	00278d13          	addi	s10,a5,2
    d514:	03000793          	li	a5,48
    d518:	02ee8823          	sb	a4,48(t4)
    d51c:	02fe88a3          	sb	a5,49(t4)
    d520:	4b81                	li	s7,0
    d522:	f1ffd06f          	j	b440 <_vsnprintf+0x28a0>
    d526:	00267e93          	andi	t4,a2,2
    d52a:	380e8fe3          	beqz	t4,e0c8 <_vsnprintf+0x5528>
    d52e:	6e02                	ld	t3,0(sp)
    d530:	a8afe06f          	j	b7ba <_vsnprintf+0x2c1a>
    d534:	47a9                	li	a5,10
    d536:	8b2e                	mv	s6,a1
    d538:	86be                	mv	a3,a5
    d53a:	89ffc06f          	j	9dd8 <_vsnprintf+0x1238>
    d53e:	ec46                	sd	a7,24(sp)
    d540:	f05a                	sd	s6,32(sp)
    d542:	e43fe06f          	j	c384 <_vsnprintf+0x37e4>
    d546:	340889e3          	beqz	a7,e098 <_vsnprintf+0x54f8>
    d54a:	0012fd93          	andi	s11,t0,1
    d54e:	7e0d80e3          	beqz	s11,e52e <_vsnprintf+0x598e>
    d552:	000e4463          	bltz	t3,d55a <_vsnprintf+0x49ba>
    d556:	3ec0106f          	j	e942 <_vsnprintf+0x5da2>
    d55a:	7c0c3d0b          	th.extu	s10,s8,31,0
    d55e:	38fd                	addiw	a7,a7,-1
    d560:	01a7f463          	bgeu	a5,s10,d568 <_vsnprintf+0x49c8>
    d564:	b67fd06f          	j	b0ca <_vsnprintf+0x252a>
    d568:	7c08b68b          	th.extu	a3,a7,31,0
    d56c:	00d7e463          	bltu	a5,a3,d574 <_vsnprintf+0x49d4>
    d570:	4d60106f          	j	ea46 <_vsnprintf+0x5ea6>
    d574:	02000d93          	li	s11,32
    d578:	40fd8533          	sub	a0,s11,a5
    d57c:	00757e93          	andi	t4,a0,7
    d580:	00f30633          	add	a2,t1,a5
    d584:	03000b13          	li	s6,48
    d588:	060e8763          	beqz	t4,d5f6 <_vsnprintf+0x4a56>
    d58c:	0785                	addi	a5,a5,1
    d58e:	18165b0b          	th.sbia	s6,(a2),1,0
    d592:	0cd78463          	beq	a5,a3,d65a <_vsnprintf+0x4aba>
    d596:	4f05                	li	t5,1
    d598:	05ee8f63          	beq	t4,t5,d5f6 <_vsnprintf+0x4a56>
    d59c:	4a89                	li	s5,2
    d59e:	055e8763          	beq	t4,s5,d5ec <_vsnprintf+0x4a4c>
    d5a2:	428d                	li	t0,3
    d5a4:	025e8f63          	beq	t4,t0,d5e2 <_vsnprintf+0x4a42>
    d5a8:	4c91                	li	s9,4
    d5aa:	039e8763          	beq	t4,s9,d5d8 <_vsnprintf+0x4a38>
    d5ae:	4c15                	li	s8,5
    d5b0:	018e8f63          	beq	t4,s8,d5ce <_vsnprintf+0x4a2e>
    d5b4:	4b99                	li	s7,6
    d5b6:	017e8763          	beq	t4,s7,d5c4 <_vsnprintf+0x4a24>
    d5ba:	0785                	addi	a5,a5,1
    d5bc:	18165b0b          	th.sbia	s6,(a2),1,0
    d5c0:	08d78d63          	beq	a5,a3,d65a <_vsnprintf+0x4aba>
    d5c4:	0785                	addi	a5,a5,1
    d5c6:	18165b0b          	th.sbia	s6,(a2),1,0
    d5ca:	08d78863          	beq	a5,a3,d65a <_vsnprintf+0x4aba>
    d5ce:	0785                	addi	a5,a5,1
    d5d0:	18165b0b          	th.sbia	s6,(a2),1,0
    d5d4:	08d78363          	beq	a5,a3,d65a <_vsnprintf+0x4aba>
    d5d8:	0785                	addi	a5,a5,1
    d5da:	18165b0b          	th.sbia	s6,(a2),1,0
    d5de:	06d78e63          	beq	a5,a3,d65a <_vsnprintf+0x4aba>
    d5e2:	0785                	addi	a5,a5,1
    d5e4:	18165b0b          	th.sbia	s6,(a2),1,0
    d5e8:	06d78963          	beq	a5,a3,d65a <_vsnprintf+0x4aba>
    d5ec:	0785                	addi	a5,a5,1
    d5ee:	18165b0b          	th.sbia	s6,(a2),1,0
    d5f2:	06d78463          	beq	a5,a3,d65a <_vsnprintf+0x4aba>
    d5f6:	07b78863          	beq	a5,s11,d666 <_vsnprintf+0x4ac6>
    d5fa:	00178f93          	addi	t6,a5,1
    d5fe:	01660023          	sb	s6,0(a2)
    d602:	04df8c63          	beq	t6,a3,d65a <_vsnprintf+0x4aba>
    d606:	00278393          	addi	t2,a5,2
    d60a:	016600a3          	sb	s6,1(a2)
    d60e:	04d38663          	beq	t2,a3,d65a <_vsnprintf+0x4aba>
    d612:	00378713          	addi	a4,a5,3
    d616:	01660123          	sb	s6,2(a2)
    d61a:	04d70063          	beq	a4,a3,d65a <_vsnprintf+0x4aba>
    d61e:	00478d13          	addi	s10,a5,4
    d622:	016601a3          	sb	s6,3(a2)
    d626:	02dd0a63          	beq	s10,a3,d65a <_vsnprintf+0x4aba>
    d62a:	00578513          	addi	a0,a5,5
    d62e:	01660223          	sb	s6,4(a2)
    d632:	02d50463          	beq	a0,a3,d65a <_vsnprintf+0x4aba>
    d636:	00678e93          	addi	t4,a5,6
    d63a:	016602a3          	sb	s6,5(a2)
    d63e:	00de8e63          	beq	t4,a3,d65a <_vsnprintf+0x4aba>
    d642:	00778f13          	addi	t5,a5,7
    d646:	01660323          	sb	s6,6(a2)
    d64a:	00df0863          	beq	t5,a3,d65a <_vsnprintf+0x4aba>
    d64e:	016603a3          	sb	s6,7(a2)
    d652:	07a1                	addi	a5,a5,8
    d654:	0621                	addi	a2,a2,8
    d656:	fad790e3          	bne	a5,a3,d5f6 <_vsnprintf+0x4a56>
    d65a:	02000793          	li	a5,32
    d65e:	00f68463          	beq	a3,a5,d666 <_vsnprintf+0x4ac6>
    d662:	b71fd06f          	j	b1d2 <_vsnprintf+0x2632>
    d666:	898d                	andi	a1,a1,3
    d668:	c199                	beqz	a1,d66e <_vsnprintf+0x4ace>
    d66a:	1170106f          	j	ef80 <_vsnprintf+0x63e0>
    d66e:	02000693          	li	a3,32
    d672:	6116f463          	bgeu	a3,a7,dc7a <_vsnprintf+0x50da>
    d676:	7c08bb8b          	th.extu	s7,a7,31,0
    d67a:	8dc2                	mv	s11,a6
    d67c:	8d36                	mv	s10,a3
    d67e:	4b01                	li	s6,0
    d680:	b85fd06f          	j	b204 <_vsnprintf+0x2664>
    d684:	02b00513          	li	a0,43
    d688:	feae0023          	sb	a0,-32(t3)
    d68c:	a5efc06f          	j	98ea <_vsnprintf+0xd4a>
    d690:	898d                	andi	a1,a1,3
    d692:	c199                	beqz	a1,d698 <_vsnprintf+0x4af8>
    d694:	2620106f          	j	e8f6 <_vsnprintf+0x5d56>
    d698:	02000693          	li	a3,32
    d69c:	0316f763          	bgeu	a3,a7,d6ca <_vsnprintf+0x4b2a>
    d6a0:	7c08bb8b          	th.extu	s7,a7,31,0
    d6a4:	8dc2                	mv	s11,a6
    d6a6:	8c36                	mv	s8,a3
    d6a8:	4b01                	li	s6,0
    d6aa:	daaff06f          	j	cc54 <_vsnprintf+0x40b4>
    d6ae:	fe0d81e3          	beqz	s11,d690 <_vsnprintf+0x4af0>
    d6b2:	7c08b68b          	th.extu	a3,a7,31,0
    d6b6:	00d7f463          	bgeu	a5,a3,d6be <_vsnprintf+0x4b1e>
    d6ba:	8edfe06f          	j	bfa6 <_vsnprintf+0x3406>
    d6be:	0035fc13          	andi	s8,a1,3
    d6c2:	000c0463          	beqz	s8,d6ca <_vsnprintf+0x4b2a>
    d6c6:	2300106f          	j	e8f6 <_vsnprintf+0x5d56>
    d6ca:	8dc2                	mv	s11,a6
    d6cc:	04f14503          	lbu	a0,79(sp)
    d6d0:	6802                	ld	a6,0(sp)
    d6d2:	02000c13          	li	s8,32
    d6d6:	4b01                	li	s6,0
    d6d8:	b63fe06f          	j	c23a <_vsnprintf+0x369a>
    d6dc:	4b81                	li	s7,0
    d6de:	963fd06f          	j	b040 <_vsnprintf+0x24a0>
    d6e2:	47c1                	li	a5,16
    d6e4:	95dfd06f          	j	b040 <_vsnprintf+0x24a0>
    d6e8:	ec46                	sd	a7,24(sp)
    d6ea:	fd515b8b          	th.sdd	s7,s5,(sp),2,4
    d6ee:	b4afc06f          	j	9a38 <_vsnprintf+0xe98>
    d6f2:	220e47e3          	bltz	t3,e120 <_vsnprintf+0x5580>
    d6f6:	004afe13          	andi	t3,s5,4
    d6fa:	000e1463          	bnez	t3,d702 <_vsnprintf+0x4b62>
    d6fe:	2920106f          	j	e990 <_vsnprintf+0x5df0>
    d702:	00278d33          	add	s10,a5,sp
    d706:	02b00513          	li	a0,43
    d70a:	02ad0823          	sb	a0,48(s10)
    d70e:	6302                	ld	t1,0(sp)
    d710:	00178c13          	addi	s8,a5,1
    d714:	4b09                	li	s6,2
    d716:	d10fd06f          	j	ac26 <_vsnprintf+0x2086>
    d71a:	7c0c3c0b          	th.extu	s8,s8,31,0
    d71e:	0187e463          	bltu	a5,s8,d726 <_vsnprintf+0x4b86>
    d722:	7020106f          	j	ee24 <_vsnprintf+0x6284>
    d726:	0015fd93          	andi	s11,a1,1
    d72a:	4881                	li	a7,0
    d72c:	f7cfe06f          	j	bea8 <_vsnprintf+0x3308>
    d730:	7a088ee3          	beqz	a7,e6ec <_vsnprintf+0x5b4c>
    d734:	001e7c93          	andi	s9,t3,1
    d738:	7c0c370b          	th.extu	a4,s8,31,0
    d73c:	000c9463          	bnez	s9,d744 <_vsnprintf+0x4ba4>
    d740:	0d80106f          	j	e818 <_vsnprintf+0x5c78>
    d744:	0eed7763          	bgeu	s10,a4,d832 <_vsnprintf+0x4c92>
    d748:	02000313          	li	t1,32
    d74c:	41a30fb3          	sub	t6,t1,s10
    d750:	007fff13          	andi	t5,t6,7
    d754:	01ab0533          	add	a0,s6,s10
    d758:	03000393          	li	t2,48
    d75c:	060f0763          	beqz	t5,d7ca <_vsnprintf+0x4c2a>
    d760:	0d05                	addi	s10,s10,1
    d762:	1815538b          	th.sbia	t2,(a0),1,0
    d766:	0ced7463          	bgeu	s10,a4,d82e <_vsnprintf+0x4c8e>
    d76a:	4585                	li	a1,1
    d76c:	04bf0f63          	beq	t5,a1,d7ca <_vsnprintf+0x4c2a>
    d770:	4e09                	li	t3,2
    d772:	05cf0763          	beq	t5,t3,d7c0 <_vsnprintf+0x4c20>
    d776:	478d                	li	a5,3
    d778:	02ff0f63          	beq	t5,a5,d7b6 <_vsnprintf+0x4c16>
    d77c:	4d91                	li	s11,4
    d77e:	03bf0763          	beq	t5,s11,d7ac <_vsnprintf+0x4c0c>
    d782:	4295                	li	t0,5
    d784:	005f0f63          	beq	t5,t0,d7a2 <_vsnprintf+0x4c02>
    d788:	4f99                	li	t6,6
    d78a:	01ff0763          	beq	t5,t6,d798 <_vsnprintf+0x4bf8>
    d78e:	0d05                	addi	s10,s10,1
    d790:	1815538b          	th.sbia	t2,(a0),1,0
    d794:	08ed7d63          	bgeu	s10,a4,d82e <_vsnprintf+0x4c8e>
    d798:	0d05                	addi	s10,s10,1
    d79a:	1815538b          	th.sbia	t2,(a0),1,0
    d79e:	08ed7863          	bgeu	s10,a4,d82e <_vsnprintf+0x4c8e>
    d7a2:	0d05                	addi	s10,s10,1
    d7a4:	1815538b          	th.sbia	t2,(a0),1,0
    d7a8:	08ed7363          	bgeu	s10,a4,d82e <_vsnprintf+0x4c8e>
    d7ac:	0d05                	addi	s10,s10,1
    d7ae:	1815538b          	th.sbia	t2,(a0),1,0
    d7b2:	06ed7e63          	bgeu	s10,a4,d82e <_vsnprintf+0x4c8e>
    d7b6:	0d05                	addi	s10,s10,1
    d7b8:	1815538b          	th.sbia	t2,(a0),1,0
    d7bc:	06ed7963          	bgeu	s10,a4,d82e <_vsnprintf+0x4c8e>
    d7c0:	0d05                	addi	s10,s10,1
    d7c2:	1815538b          	th.sbia	t2,(a0),1,0
    d7c6:	06ed7463          	bgeu	s10,a4,d82e <_vsnprintf+0x4c8e>
    d7ca:	066d0263          	beq	s10,t1,d82e <_vsnprintf+0x4c8e>
    d7ce:	0d05                	addi	s10,s10,1
    d7d0:	00750023          	sb	t2,0(a0)
    d7d4:	8f6a                	mv	t5,s10
    d7d6:	04ed7c63          	bgeu	s10,a4,d82e <_vsnprintf+0x4c8e>
    d7da:	0d05                	addi	s10,s10,1
    d7dc:	007500a3          	sb	t2,1(a0)
    d7e0:	04ed7763          	bgeu	s10,a4,d82e <_vsnprintf+0x4c8e>
    d7e4:	002f0d13          	addi	s10,t5,2
    d7e8:	00750123          	sb	t2,2(a0)
    d7ec:	04ed7163          	bgeu	s10,a4,d82e <_vsnprintf+0x4c8e>
    d7f0:	003f0d13          	addi	s10,t5,3
    d7f4:	007501a3          	sb	t2,3(a0)
    d7f8:	02ed7b63          	bgeu	s10,a4,d82e <_vsnprintf+0x4c8e>
    d7fc:	004f0d13          	addi	s10,t5,4
    d800:	00750223          	sb	t2,4(a0)
    d804:	02ed7563          	bgeu	s10,a4,d82e <_vsnprintf+0x4c8e>
    d808:	005f0d13          	addi	s10,t5,5
    d80c:	007502a3          	sb	t2,5(a0)
    d810:	00ed7f63          	bgeu	s10,a4,d82e <_vsnprintf+0x4c8e>
    d814:	006f0d13          	addi	s10,t5,6
    d818:	00750323          	sb	t2,6(a0)
    d81c:	00ed7963          	bgeu	s10,a4,d82e <_vsnprintf+0x4c8e>
    d820:	007503a3          	sb	t2,7(a0)
    d824:	007f0d13          	addi	s10,t5,7
    d828:	0521                	addi	a0,a0,8
    d82a:	faed60e3          	bltu	s10,a4,d7ca <_vsnprintf+0x4c2a>
    d82e:	620c84e3          	beqz	s9,e656 <_vsnprintf+0x5ab6>
    d832:	7c08b78b          	th.extu	a5,a7,31,0
    d836:	00fd6463          	bltu	s10,a5,d83e <_vsnprintf+0x4c9e>
    d83a:	6020106f          	j	ee3c <_vsnprintf+0x629c>
    d83e:	02000c93          	li	s9,32
    d842:	41ac83b3          	sub	t2,s9,s10
    d846:	0073fe13          	andi	t3,t2,7
    d84a:	01ab05b3          	add	a1,s6,s10
    d84e:	03000313          	li	t1,48
    d852:	060e0763          	beqz	t3,d8c0 <_vsnprintf+0x4d20>
    d856:	0d05                	addi	s10,s10,1
    d858:	1815d30b          	th.sbia	t1,(a1),1,0
    d85c:	0da78463          	beq	a5,s10,d924 <_vsnprintf+0x4d84>
    d860:	4d85                	li	s11,1
    d862:	05be0f63          	beq	t3,s11,d8c0 <_vsnprintf+0x4d20>
    d866:	4289                	li	t0,2
    d868:	045e0763          	beq	t3,t0,d8b6 <_vsnprintf+0x4d16>
    d86c:	4f8d                	li	t6,3
    d86e:	03fe0f63          	beq	t3,t6,d8ac <_vsnprintf+0x4d0c>
    d872:	4f11                	li	t5,4
    d874:	03ee0763          	beq	t3,t5,d8a2 <_vsnprintf+0x4d02>
    d878:	4515                	li	a0,5
    d87a:	00ae0f63          	beq	t3,a0,d898 <_vsnprintf+0x4cf8>
    d87e:	4719                	li	a4,6
    d880:	00ee0763          	beq	t3,a4,d88e <_vsnprintf+0x4cee>
    d884:	0d05                	addi	s10,s10,1
    d886:	1815d30b          	th.sbia	t1,(a1),1,0
    d88a:	09a78d63          	beq	a5,s10,d924 <_vsnprintf+0x4d84>
    d88e:	0d05                	addi	s10,s10,1
    d890:	1815d30b          	th.sbia	t1,(a1),1,0
    d894:	09a78863          	beq	a5,s10,d924 <_vsnprintf+0x4d84>
    d898:	0d05                	addi	s10,s10,1
    d89a:	1815d30b          	th.sbia	t1,(a1),1,0
    d89e:	09a78363          	beq	a5,s10,d924 <_vsnprintf+0x4d84>
    d8a2:	0d05                	addi	s10,s10,1
    d8a4:	1815d30b          	th.sbia	t1,(a1),1,0
    d8a8:	07a78e63          	beq	a5,s10,d924 <_vsnprintf+0x4d84>
    d8ac:	0d05                	addi	s10,s10,1
    d8ae:	1815d30b          	th.sbia	t1,(a1),1,0
    d8b2:	07a78963          	beq	a5,s10,d924 <_vsnprintf+0x4d84>
    d8b6:	0d05                	addi	s10,s10,1
    d8b8:	1815d30b          	th.sbia	t1,(a1),1,0
    d8bc:	07a78463          	beq	a5,s10,d924 <_vsnprintf+0x4d84>
    d8c0:	179d07e3          	beq	s10,s9,e22e <_vsnprintf+0x568e>
    d8c4:	0d05                	addi	s10,s10,1
    d8c6:	00658023          	sb	t1,0(a1)
    d8ca:	83ea                	mv	t2,s10
    d8cc:	05a78c63          	beq	a5,s10,d924 <_vsnprintf+0x4d84>
    d8d0:	0d05                	addi	s10,s10,1
    d8d2:	006580a3          	sb	t1,1(a1)
    d8d6:	05a78763          	beq	a5,s10,d924 <_vsnprintf+0x4d84>
    d8da:	00238d13          	addi	s10,t2,2
    d8de:	00658123          	sb	t1,2(a1)
    d8e2:	05a78163          	beq	a5,s10,d924 <_vsnprintf+0x4d84>
    d8e6:	00338d13          	addi	s10,t2,3
    d8ea:	006581a3          	sb	t1,3(a1)
    d8ee:	03a78b63          	beq	a5,s10,d924 <_vsnprintf+0x4d84>
    d8f2:	00438d13          	addi	s10,t2,4
    d8f6:	00658223          	sb	t1,4(a1)
    d8fa:	03a78563          	beq	a5,s10,d924 <_vsnprintf+0x4d84>
    d8fe:	00538d13          	addi	s10,t2,5
    d902:	006582a3          	sb	t1,5(a1)
    d906:	01a78f63          	beq	a5,s10,d924 <_vsnprintf+0x4d84>
    d90a:	00638d13          	addi	s10,t2,6
    d90e:	00658323          	sb	t1,6(a1)
    d912:	01a78963          	beq	a5,s10,d924 <_vsnprintf+0x4d84>
    d916:	006583a3          	sb	t1,7(a1)
    d91a:	00738d13          	addi	s10,t2,7
    d91e:	05a1                	addi	a1,a1,8
    d920:	fba790e3          	bne	a5,s10,d8c0 <_vsnprintf+0x4d20>
    d924:	4a0e9be3          	bnez	t4,e5da <_vsnprintf+0x5a3a>
    d928:	819d0663          	beq	s10,s9,c934 <_vsnprintf+0x3d94>
    d92c:	00367b93          	andi	s7,a2,3
    d930:	000b8463          	beqz	s7,d938 <_vsnprintf+0x4d98>
    d934:	3160106f          	j	ec4a <_vsnprintf+0x60aa>
    d938:	8c3e                	mv	s8,a5
    d93a:	10fd67e3          	bltu	s10,a5,e248 <_vsnprintf+0x56a8>
    d93e:	6382                	ld	t2,0(sp)
    d940:	ffdfe06f          	j	c93c <_vsnprintf+0x3d9c>
    d944:	4d09                	li	s10,2
    d946:	500b83e3          	beqz	s7,e64c <_vsnprintf+0x5aac>
    d94a:	4b41                	li	s6,16
    d94c:	57668be3          	beq	a3,s6,e6c2 <_vsnprintf+0x5b22>
    d950:	4a89                	li	s5,2
    d952:	555688e3          	beq	a3,s5,e6a2 <_vsnprintf+0x5b02>
    d956:	02000593          	li	a1,32
    d95a:	5cb71663          	bne	a4,a1,df26 <_vsnprintf+0x5386>
    d95e:	003e7513          	andi	a0,t3,3
    d962:	c119                	beqz	a0,d968 <_vsnprintf+0x4dc8>
    d964:	ce5fd06f          	j	b648 <_vsnprintf+0x2aa8>
    d968:	02000713          	li	a4,32
    d96c:	01176463          	bltu	a4,a7,d974 <_vsnprintf+0x4dd4>
    d970:	cd9fd06f          	j	b648 <_vsnprintf+0x2aa8>
    d974:	7c08bc0b          	th.extu	s8,a7,31,0
    d978:	6602                	ld	a2,0(sp)
    d97a:	ec3a                	sd	a4,24(sp)
    d97c:	f046                	sd	a7,32(sp)
    d97e:	40c70cb3          	sub	s9,a4,a2
    d982:	fffcc813          	not	a6,s9
    d986:	40c80eb3          	sub	t4,a6,a2
    d98a:	018e8b33          	add	s6,t4,s8
    d98e:	02000513          	li	a0,32
    d992:	86a6                	mv	a3,s1
    d994:	85ca                	mv	a1,s2
    d996:	007b7a93          	andi	s5,s6,7
    d99a:	00160b13          	addi	s6,a2,1
    d99e:	9402                	jalr	s0
    d9a0:	016c8533          	add	a0,s9,s6
    d9a4:	6762                	ld	a4,24(sp)
    d9a6:	7882                	ld	a7,32(sp)
    d9a8:	17857263          	bgeu	a0,s8,db0c <_vsnprintf+0x4f6c>
    d9ac:	0c0a8763          	beqz	s5,da7a <_vsnprintf+0x4eda>
    d9b0:	4305                	li	t1,1
    d9b2:	0a6a8563          	beq	s5,t1,da5c <_vsnprintf+0x4ebc>
    d9b6:	4289                	li	t0,2
    d9b8:	085a8763          	beq	s5,t0,da46 <_vsnprintf+0x4ea6>
    d9bc:	438d                	li	t2,3
    d9be:	067a8963          	beq	s5,t2,da30 <_vsnprintf+0x4e90>
    d9c2:	4f11                	li	t5,4
    d9c4:	05ea8b63          	beq	s5,t5,da1a <_vsnprintf+0x4e7a>
    d9c8:	4695                	li	a3,5
    d9ca:	02da8d63          	beq	s5,a3,da04 <_vsnprintf+0x4e64>
    d9ce:	4799                	li	a5,6
    d9d0:	00fa8f63          	beq	s5,a5,d9ee <_vsnprintf+0x4e4e>
    d9d4:	ec46                	sd	a7,24(sp)
    d9d6:	f03a                	sd	a4,32(sp)
    d9d8:	865a                	mv	a2,s6
    d9da:	86a6                	mv	a3,s1
    d9dc:	85ca                	mv	a1,s2
    d9de:	02000513          	li	a0,32
    d9e2:	6b82                	ld	s7,0(sp)
    d9e4:	9402                	jalr	s0
    d9e6:	68e2                	ld	a7,24(sp)
    d9e8:	7702                	ld	a4,32(sp)
    d9ea:	002b8b13          	addi	s6,s7,2
    d9ee:	ec46                	sd	a7,24(sp)
    d9f0:	f03a                	sd	a4,32(sp)
    d9f2:	865a                	mv	a2,s6
    d9f4:	86a6                	mv	a3,s1
    d9f6:	85ca                	mv	a1,s2
    d9f8:	02000513          	li	a0,32
    d9fc:	9402                	jalr	s0
    d9fe:	68e2                	ld	a7,24(sp)
    da00:	7702                	ld	a4,32(sp)
    da02:	0b05                	addi	s6,s6,1
    da04:	ec46                	sd	a7,24(sp)
    da06:	f03a                	sd	a4,32(sp)
    da08:	865a                	mv	a2,s6
    da0a:	86a6                	mv	a3,s1
    da0c:	85ca                	mv	a1,s2
    da0e:	02000513          	li	a0,32
    da12:	9402                	jalr	s0
    da14:	68e2                	ld	a7,24(sp)
    da16:	7702                	ld	a4,32(sp)
    da18:	0b05                	addi	s6,s6,1
    da1a:	ec46                	sd	a7,24(sp)
    da1c:	f03a                	sd	a4,32(sp)
    da1e:	865a                	mv	a2,s6
    da20:	86a6                	mv	a3,s1
    da22:	85ca                	mv	a1,s2
    da24:	02000513          	li	a0,32
    da28:	9402                	jalr	s0
    da2a:	68e2                	ld	a7,24(sp)
    da2c:	7702                	ld	a4,32(sp)
    da2e:	0b05                	addi	s6,s6,1
    da30:	ec46                	sd	a7,24(sp)
    da32:	f03a                	sd	a4,32(sp)
    da34:	865a                	mv	a2,s6
    da36:	86a6                	mv	a3,s1
    da38:	85ca                	mv	a1,s2
    da3a:	02000513          	li	a0,32
    da3e:	9402                	jalr	s0
    da40:	68e2                	ld	a7,24(sp)
    da42:	7702                	ld	a4,32(sp)
    da44:	0b05                	addi	s6,s6,1
    da46:	ec46                	sd	a7,24(sp)
    da48:	f03a                	sd	a4,32(sp)
    da4a:	865a                	mv	a2,s6
    da4c:	86a6                	mv	a3,s1
    da4e:	85ca                	mv	a1,s2
    da50:	02000513          	li	a0,32
    da54:	9402                	jalr	s0
    da56:	68e2                	ld	a7,24(sp)
    da58:	7702                	ld	a4,32(sp)
    da5a:	0b05                	addi	s6,s6,1
    da5c:	ec46                	sd	a7,24(sp)
    da5e:	f03a                	sd	a4,32(sp)
    da60:	865a                	mv	a2,s6
    da62:	86a6                	mv	a3,s1
    da64:	85ca                	mv	a1,s2
    da66:	02000513          	li	a0,32
    da6a:	9402                	jalr	s0
    da6c:	0b05                	addi	s6,s6,1
    da6e:	016c8fb3          	add	t6,s9,s6
    da72:	68e2                	ld	a7,24(sp)
    da74:	7702                	ld	a4,32(sp)
    da76:	098ffb63          	bgeu	t6,s8,db0c <_vsnprintf+0x4f6c>
    da7a:	ec6e                	sd	s11,24(sp)
    da7c:	8dc6                	mv	s11,a7
    da7e:	f03a                	sd	a4,32(sp)
    da80:	865a                	mv	a2,s6
    da82:	86a6                	mv	a3,s1
    da84:	85ca                	mv	a1,s2
    da86:	02000513          	li	a0,32
    da8a:	9402                	jalr	s0
    da8c:	001b0a93          	addi	s5,s6,1
    da90:	8656                	mv	a2,s5
    da92:	86a6                	mv	a3,s1
    da94:	85ca                	mv	a1,s2
    da96:	02000513          	li	a0,32
    da9a:	9402                	jalr	s0
    da9c:	002b0b93          	addi	s7,s6,2
    daa0:	865e                	mv	a2,s7
    daa2:	86a6                	mv	a3,s1
    daa4:	85ca                	mv	a1,s2
    daa6:	02000513          	li	a0,32
    daaa:	9402                	jalr	s0
    daac:	003b0a93          	addi	s5,s6,3
    dab0:	8656                	mv	a2,s5
    dab2:	86a6                	mv	a3,s1
    dab4:	85ca                	mv	a1,s2
    dab6:	02000513          	li	a0,32
    daba:	9402                	jalr	s0
    dabc:	004b0b93          	addi	s7,s6,4
    dac0:	865e                	mv	a2,s7
    dac2:	86a6                	mv	a3,s1
    dac4:	85ca                	mv	a1,s2
    dac6:	02000513          	li	a0,32
    daca:	9402                	jalr	s0
    dacc:	005b0a93          	addi	s5,s6,5
    dad0:	8656                	mv	a2,s5
    dad2:	86a6                	mv	a3,s1
    dad4:	85ca                	mv	a1,s2
    dad6:	02000513          	li	a0,32
    dada:	9402                	jalr	s0
    dadc:	006b0b93          	addi	s7,s6,6
    dae0:	86a6                	mv	a3,s1
    dae2:	865e                	mv	a2,s7
    dae4:	85ca                	mv	a1,s2
    dae6:	02000513          	li	a0,32
    daea:	9402                	jalr	s0
    daec:	007b0a93          	addi	s5,s6,7
    daf0:	86a6                	mv	a3,s1
    daf2:	8656                	mv	a2,s5
    daf4:	85ca                	mv	a1,s2
    daf6:	02000513          	li	a0,32
    dafa:	9402                	jalr	s0
    dafc:	0b21                	addi	s6,s6,8
    dafe:	016c88b3          	add	a7,s9,s6
    db02:	7702                	ld	a4,32(sp)
    db04:	f788ede3          	bltu	a7,s8,da7e <_vsnprintf+0x4ede>
    db08:	88ee                	mv	a7,s11
    db0a:	6de2                	ld	s11,24(sp)
    db0c:	6c82                	ld	s9,0(sp)
    db0e:	fffc0e13          	addi	t3,s8,-1
    db12:	00170593          	addi	a1,a4,1
    db16:	40ee07b3          	sub	a5,t3,a4
    db1a:	00bc3633          	sltu	a2,s8,a1
    db1e:	42c0178b          	th.mvnez	a5,zero,a2
    db22:	001c8e93          	addi	t4,s9,1
    db26:	03010813          	addi	a6,sp,48
    db2a:	01d78e33          	add	t3,a5,t4
    db2e:	c319                	beqz	a4,db34 <_vsnprintf+0x4f94>
    db30:	b1ffd06f          	j	b64e <_vsnprintf+0x2aae>
    db34:	c7ffd06f          	j	b7b2 <_vsnprintf+0x2c12>
    db38:	4805                	li	a6,1
    db3a:	010d0463          	beq	s10,a6,db42 <_vsnprintf+0x4fa2>
    db3e:	1040106f          	j	ec42 <_vsnprintf+0x60a2>
    db42:	678d                	lui	a5,0x3
    db44:	05878293          	addi	t0,a5,88 # 3058 <matrix_mul_vect+0x98>
    db48:	02511823          	sh	t0,48(sp)
    db4c:	00457f93          	andi	t6,a0,4
    db50:	1a0f8ee3          	beqz	t6,e50c <_vsnprintf+0x596c>
    db54:	4b89                	li	s7,2
    db56:	87de                	mv	a5,s7
    db58:	4ac1                	li	s5,16
    db5a:	ce6fd06f          	j	b040 <_vsnprintf+0x24a0>
    db5e:	7c0c350b          	th.extu	a0,s8,31,0
    db62:	00a76463          	bltu	a4,a0,db6a <_vsnprintf+0x4fca>
    db66:	2f00106f          	j	ee56 <_vsnprintf+0x62b6>
    db6a:	001e7b13          	andi	s6,t3,1
    db6e:	aaaff06f          	j	ce18 <_vsnprintf+0x4278>
    db72:	f2000353          	fmv.d.x	ft6,zero
    db76:	a26513d3          	flt.d	t2,fa0,ft6
    db7a:	00038463          	beqz	t2,db82 <_vsnprintf+0x4fe2>
    db7e:	91dfd06f          	j	b49a <_vsnprintf+0x28fa>
    db82:	77fd                	lui	a5,0xfffff
    db84:	7ff78f93          	addi	t6,a5,2047 # fffffffffffff7ff <__kernel_stack+0xfffffffffff117ff>
    db88:	01fb7b33          	and	s6,s6,t6
    db8c:	400b6e93          	ori	t4,s6,1024
    db90:	000e881b          	sext.w	a6,t4
    db94:	87c6                	mv	a5,a7
    db96:	876e                	mv	a4,s11
    db98:	f2068553          	fmv.d.x	fa0,a3
    db9c:	a5bfc06f          	j	a5f6 <_vsnprintf+0x1a56>
    dba0:	7c0c350b          	th.extu	a0,s8,31,0
    dba4:	00ade463          	bltu	s11,a0,dbac <_vsnprintf+0x500c>
    dba8:	2c80106f          	j	ee70 <_vsnprintf+0x62d0>
    dbac:	00167b13          	andi	s6,a2,1
    dbb0:	f64ff06f          	j	d314 <_vsnprintf+0x4774>
    dbb4:	0045fc13          	andi	s8,a1,4
    dbb8:	02b00513          	li	a0,43
    dbbc:	000c1863          	bnez	s8,dbcc <_vsnprintf+0x502c>
    dbc0:	008d7593          	andi	a1,s10,8
    dbc4:	500587e3          	beqz	a1,e8d2 <_vsnprintf+0x5d32>
    dbc8:	02000513          	li	a0,32
    dbcc:	6302                	ld	t1,0(sp)
    dbce:	02a10823          	sb	a0,48(sp)
    dbd2:	4c05                	li	s8,1
    dbd4:	4b09                	li	s6,2
    dbd6:	03010b93          	addi	s7,sp,48
    dbda:	84cfd06f          	j	ac26 <_vsnprintf+0x2086>
    dbde:	0e0ec9e3          	bltz	t4,e4d0 <_vsnprintf+0x5930>
    dbe2:	0046fe93          	andi	t4,a3,4
    dbe6:	3e0e87e3          	beqz	t4,e7d4 <_vsnprintf+0x5c34>
    dbea:	002782b3          	add	t0,a5,sp
    dbee:	02b00513          	li	a0,43
    dbf2:	02a28823          	sb	a0,48(t0)
    dbf6:	8dc2                	mv	s11,a6
    dbf8:	00178c13          	addi	s8,a5,1
    dbfc:	6802                	ld	a6,0(sp)
    dbfe:	4b09                	li	s6,2
    dc00:	e3afe06f          	j	c23a <_vsnprintf+0x369a>
    dc04:	5e0e9163          	bnez	t4,e1e6 <_vsnprintf+0x5646>
    dc08:	4d01                	li	s10,0
    dc0a:	003e7e13          	andi	t3,t3,3
    dc0e:	000e0463          	beqz	t3,dc16 <_vsnprintf+0x5076>
    dc12:	a37fd06f          	j	b648 <_vsnprintf+0x2aa8>
    dc16:	02000713          	li	a4,32
    dc1a:	7c08bc0b          	th.extu	s8,a7,31,0
    dc1e:	d5176de3          	bltu	a4,a7,d978 <_vsnprintf+0x4dd8>
    dc22:	a27fd06f          	j	b648 <_vsnprintf+0x2aa8>
    dc26:	0001                	nop
    dc28:	4b81                	li	s7,0
    dc2a:	020d0293          	addi	t0,s10,32
    dc2e:	03010e93          	addi	t4,sp,48
    dc32:	01d28fb3          	add	t6,t0,t4
    dc36:	05800713          	li	a4,88
    dc3a:	03000e13          	li	t3,48
    dc3e:	fcef8f23          	sb	a4,-34(t6)
    dc42:	fdcf8fa3          	sb	t3,-33(t6)
    dc46:	0045ff13          	andi	t5,a1,4
    dc4a:	000f0563          	beqz	t5,dc54 <_vsnprintf+0x50b4>
    dc4e:	87ea                	mv	a5,s10
    dc50:	bf0fd06f          	j	b040 <_vsnprintf+0x24a0>
    dc54:	89a1                	andi	a1,a1,8
    dc56:	e199                	bnez	a1,dc5c <_vsnprintf+0x50bc>
    dc58:	993fc06f          	j	a5ea <_vsnprintf+0x1a4a>
    dc5c:	87ea                	mv	a5,s10
    dc5e:	811fd06f          	j	b46e <_vsnprintf+0x28ce>
    dc62:	a00d82e3          	beqz	s11,d666 <_vsnprintf+0x4ac6>
    dc66:	7c08b68b          	th.extu	a3,a7,31,0
    dc6a:	90d7e5e3          	bltu	a5,a3,d574 <_vsnprintf+0x49d4>
    dc6e:	0035fd13          	andi	s10,a1,3
    dc72:	000d0463          	beqz	s10,dc7a <_vsnprintf+0x50da>
    dc76:	30a0106f          	j	ef80 <_vsnprintf+0x63e0>
    dc7a:	04f14503          	lbu	a0,79(sp)
    dc7e:	6382                	ld	t2,0(sp)
    dc80:	8dc2                	mv	s11,a6
    dc82:	02000d13          	li	s10,32
    dc86:	4b01                	li	s6,0
    dc88:	cbcfc06f          	j	a144 <_vsnprintf+0x15a4>
    dc8c:	002b7b93          	andi	s7,s6,2
    dc90:	000b9463          	bnez	s7,dc98 <_vsnprintf+0x50f8>
    dc94:	ca7fd06f          	j	b93a <_vsnprintf+0x2d9a>
    dc98:	6b02                	ld	s6,0(sp)
    dc9a:	4b81                	li	s7,0
    dc9c:	e98fb06f          	j	9334 <_vsnprintf+0x794>
    dca0:	4b89                	li	s7,2
    dca2:	4ac1                	li	s5,16
    dca4:	03010b13          	addi	s6,sp,48
    dca8:	fc6fd06f          	j	b46e <_vsnprintf+0x28ce>
    dcac:	020e8fe3          	beqz	t4,e4ea <_vsnprintf+0x594a>
    dcb0:	040b9863          	bnez	s7,dd00 <_vsnprintf+0x5160>
    dcb4:	00e50763          	beq	a0,a4,dcc2 <_vsnprintf+0x5122>
    dcb8:	7c08be8b          	th.extu	t4,a7,31,0
    dcbc:	8d5e                	mv	s10,s7
    dcbe:	c8ee96e3          	bne	t4,a4,d94a <_vsnprintf+0x4daa>
    dcc2:	fff70793          	addi	a5,a4,-1
    dcc6:	40079ae3          	bnez	a5,e8da <_vsnprintf+0x5d3a>
    dcca:	4741                	li	a4,16
    dccc:	58e68de3          	beq	a3,a4,ea66 <_vsnprintf+0x5ec6>
    dcd0:	4d09                	li	s10,2
    dcd2:	01a69463          	bne	a3,s10,dcda <_vsnprintf+0x513a>
    dcd6:	2f00106f          	j	efc6 <_vsnprintf+0x6426>
    dcda:	03000e93          	li	t4,48
    dcde:	03d10823          	sb	t4,48(sp)
    dce2:	003e7e13          	andi	t3,t3,3
    dce6:	000e1463          	bnez	t3,dcee <_vsnprintf+0x514e>
    dcea:	2c60106f          	j	efb0 <_vsnprintf+0x6410>
    dcee:	6e02                	ld	t3,0(sp)
    dcf0:	8d5e                	mv	s10,s7
    dcf2:	4705                	li	a4,1
    dcf4:	95bfd06f          	j	b64e <_vsnprintf+0x2aae>
    dcf8:	3eec00e3          	beq	s8,a4,e8d8 <_vsnprintf+0x5d38>
    dcfc:	3ce88ee3          	beq	a7,a4,e8d8 <_vsnprintf+0x5d38>
    dd00:	4d01                	li	s10,0
    dd02:	b1a1                	j	d94a <_vsnprintf+0x4daa>
    dd04:	4d09                	li	s10,2
    dd06:	7c0c350b          	th.extu	a0,s8,31,0
    dd0a:	2e0b8663          	beqz	s7,dff6 <_vsnprintf+0x5456>
    dd0e:	4f41                	li	t5,16
    dd10:	49e68d63          	beq	a3,t5,e1aa <_vsnprintf+0x560a>
    dd14:	4789                	li	a5,2
    dd16:	40f687e3          	beq	a3,a5,e924 <_vsnprintf+0x5d84>
    dd1a:	02000f13          	li	t5,32
    dd1e:	29ed9d63          	bne	s11,t5,dfb8 <_vsnprintf+0x5418>
    dd22:	00367d93          	andi	s11,a2,3
    dd26:	000d8463          	beqz	s11,dd2e <_vsnprintf+0x518e>
    dd2a:	e69fd06f          	j	bb92 <_vsnprintf+0x2ff2>
    dd2e:	02000613          	li	a2,32
    dd32:	01166463          	bltu	a2,a7,dd3a <_vsnprintf+0x519a>
    dd36:	e5dfd06f          	j	bb92 <_vsnprintf+0x2ff2>
    dd3a:	7c08bc0b          	th.extu	s8,a7,31,0
    dd3e:	8db2                	mv	s11,a2
    dd40:	6602                	ld	a2,0(sp)
    dd42:	02000513          	li	a0,32
    dd46:	ec46                	sd	a7,24(sp)
    dd48:	40cd8cb3          	sub	s9,s11,a2
    dd4c:	fffcc813          	not	a6,s9
    dd50:	01880bb3          	add	s7,a6,s8
    dd54:	40cb8b33          	sub	s6,s7,a2
    dd58:	86a6                	mv	a3,s1
    dd5a:	85ca                	mv	a1,s2
    dd5c:	007b7b93          	andi	s7,s6,7
    dd60:	00160b13          	addi	s6,a2,1
    dd64:	9402                	jalr	s0
    dd66:	016c8533          	add	a0,s9,s6
    dd6a:	68e2                	ld	a7,24(sp)
    dd6c:	15857663          	bgeu	a0,s8,deb8 <_vsnprintf+0x5318>
    dd70:	0a0b8963          	beqz	s7,de22 <_vsnprintf+0x5282>
    dd74:	4705                	li	a4,1
    dd76:	08eb8963          	beq	s7,a4,de08 <_vsnprintf+0x5268>
    dd7a:	4f89                	li	t6,2
    dd7c:	07fb8d63          	beq	s7,t6,ddf6 <_vsnprintf+0x5256>
    dd80:	468d                	li	a3,3
    dd82:	06db8163          	beq	s7,a3,dde4 <_vsnprintf+0x5244>
    dd86:	4f11                	li	t5,4
    dd88:	05eb8563          	beq	s7,t5,ddd2 <_vsnprintf+0x5232>
    dd8c:	4795                	li	a5,5
    dd8e:	02fb8963          	beq	s7,a5,ddc0 <_vsnprintf+0x5220>
    dd92:	4399                	li	t2,6
    dd94:	007b8d63          	beq	s7,t2,ddae <_vsnprintf+0x520e>
    dd98:	6302                	ld	t1,0(sp)
    dd9a:	865a                	mv	a2,s6
    dd9c:	ec46                	sd	a7,24(sp)
    dd9e:	86a6                	mv	a3,s1
    dda0:	85ca                	mv	a1,s2
    dda2:	02000513          	li	a0,32
    dda6:	00230b13          	addi	s6,t1,2
    ddaa:	9402                	jalr	s0
    ddac:	68e2                	ld	a7,24(sp)
    ddae:	865a                	mv	a2,s6
    ddb0:	ec46                	sd	a7,24(sp)
    ddb2:	86a6                	mv	a3,s1
    ddb4:	85ca                	mv	a1,s2
    ddb6:	02000513          	li	a0,32
    ddba:	9402                	jalr	s0
    ddbc:	68e2                	ld	a7,24(sp)
    ddbe:	0b05                	addi	s6,s6,1
    ddc0:	865a                	mv	a2,s6
    ddc2:	ec46                	sd	a7,24(sp)
    ddc4:	86a6                	mv	a3,s1
    ddc6:	85ca                	mv	a1,s2
    ddc8:	02000513          	li	a0,32
    ddcc:	9402                	jalr	s0
    ddce:	68e2                	ld	a7,24(sp)
    ddd0:	0b05                	addi	s6,s6,1
    ddd2:	865a                	mv	a2,s6
    ddd4:	ec46                	sd	a7,24(sp)
    ddd6:	86a6                	mv	a3,s1
    ddd8:	85ca                	mv	a1,s2
    ddda:	02000513          	li	a0,32
    ddde:	9402                	jalr	s0
    dde0:	68e2                	ld	a7,24(sp)
    dde2:	0b05                	addi	s6,s6,1
    dde4:	865a                	mv	a2,s6
    dde6:	ec46                	sd	a7,24(sp)
    dde8:	86a6                	mv	a3,s1
    ddea:	85ca                	mv	a1,s2
    ddec:	02000513          	li	a0,32
    ddf0:	9402                	jalr	s0
    ddf2:	68e2                	ld	a7,24(sp)
    ddf4:	0b05                	addi	s6,s6,1
    ddf6:	865a                	mv	a2,s6
    ddf8:	ec46                	sd	a7,24(sp)
    ddfa:	86a6                	mv	a3,s1
    ddfc:	85ca                	mv	a1,s2
    ddfe:	02000513          	li	a0,32
    de02:	9402                	jalr	s0
    de04:	68e2                	ld	a7,24(sp)
    de06:	0b05                	addi	s6,s6,1
    de08:	865a                	mv	a2,s6
    de0a:	ec46                	sd	a7,24(sp)
    de0c:	86a6                	mv	a3,s1
    de0e:	85ca                	mv	a1,s2
    de10:	02000513          	li	a0,32
    de14:	9402                	jalr	s0
    de16:	0b05                	addi	s6,s6,1
    de18:	016c8eb3          	add	t4,s9,s6
    de1c:	68e2                	ld	a7,24(sp)
    de1e:	098efd63          	bgeu	t4,s8,deb8 <_vsnprintf+0x5318>
    de22:	ec6e                	sd	s11,24(sp)
    de24:	f06a                	sd	s10,32(sp)
    de26:	8dd6                	mv	s11,s5
    de28:	8d46                	mv	s10,a7
    de2a:	865a                	mv	a2,s6
    de2c:	86a6                	mv	a3,s1
    de2e:	85ca                	mv	a1,s2
    de30:	02000513          	li	a0,32
    de34:	9402                	jalr	s0
    de36:	001b0b93          	addi	s7,s6,1
    de3a:	865e                	mv	a2,s7
    de3c:	86a6                	mv	a3,s1
    de3e:	85ca                	mv	a1,s2
    de40:	02000513          	li	a0,32
    de44:	9402                	jalr	s0
    de46:	002b0a93          	addi	s5,s6,2
    de4a:	8656                	mv	a2,s5
    de4c:	86a6                	mv	a3,s1
    de4e:	85ca                	mv	a1,s2
    de50:	02000513          	li	a0,32
    de54:	9402                	jalr	s0
    de56:	003b0b93          	addi	s7,s6,3
    de5a:	865e                	mv	a2,s7
    de5c:	86a6                	mv	a3,s1
    de5e:	85ca                	mv	a1,s2
    de60:	02000513          	li	a0,32
    de64:	9402                	jalr	s0
    de66:	004b0a93          	addi	s5,s6,4
    de6a:	8656                	mv	a2,s5
    de6c:	86a6                	mv	a3,s1
    de6e:	85ca                	mv	a1,s2
    de70:	02000513          	li	a0,32
    de74:	9402                	jalr	s0
    de76:	005b0b93          	addi	s7,s6,5
    de7a:	865e                	mv	a2,s7
    de7c:	86a6                	mv	a3,s1
    de7e:	85ca                	mv	a1,s2
    de80:	02000513          	li	a0,32
    de84:	9402                	jalr	s0
    de86:	006b0a93          	addi	s5,s6,6
    de8a:	86a6                	mv	a3,s1
    de8c:	8656                	mv	a2,s5
    de8e:	85ca                	mv	a1,s2
    de90:	02000513          	li	a0,32
    de94:	9402                	jalr	s0
    de96:	007b0b93          	addi	s7,s6,7
    de9a:	86a6                	mv	a3,s1
    de9c:	865e                	mv	a2,s7
    de9e:	85ca                	mv	a1,s2
    dea0:	02000513          	li	a0,32
    dea4:	0b21                	addi	s6,s6,8
    dea6:	9402                	jalr	s0
    dea8:	016c88b3          	add	a7,s9,s6
    deac:	f788efe3          	bltu	a7,s8,de2a <_vsnprintf+0x528a>
    deb0:	88ea                	mv	a7,s10
    deb2:	8aee                	mv	s5,s11
    deb4:	6de2                	ld	s11,24(sp)
    deb6:	7d02                	ld	s10,32(sp)
    deb8:	6c82                	ld	s9,0(sp)
    deba:	fffc0e13          	addi	t3,s8,-1
    debe:	001d8593          	addi	a1,s11,1
    dec2:	41be02b3          	sub	t0,t3,s11
    dec6:	00bc3633          	sltu	a2,s8,a1
    deca:	42c0128b          	th.mvnez	t0,zero,a2
    dece:	001c8513          	addi	a0,s9,1
    ded2:	03010813          	addi	a6,sp,48
    ded6:	00a286b3          	add	a3,t0,a0
    deda:	000d8463          	beqz	s11,dee2 <_vsnprintf+0x5342>
    dede:	cbbfd06f          	j	bb98 <_vsnprintf+0x2ff8>
    dee2:	8db6                	mv	s11,a3
    dee4:	000d1463          	bnez	s10,deec <_vsnprintf+0x534c>
    dee8:	e1dfd06f          	j	bd04 <_vsnprintf+0x3164>
    deec:	e2ffd06f          	j	bd1a <_vsnprintf+0x317a>
    def0:	8d46                	mv	s10,a7
    def2:	8a9a                	mv	s5,t1
    def4:	bc8fc06f          	j	a2bc <_vsnprintf+0x171c>
    def8:	00a77463          	bgeu	a4,a0,df00 <_vsnprintf+0x5360>
    defc:	f1dfe06f          	j	ce18 <_vsnprintf+0x4278>
    df00:	000e9463          	bnez	t4,df08 <_vsnprintf+0x5368>
    df04:	05c0106f          	j	ef60 <_vsnprintf+0x63c0>
    df08:	da0b86e3          	beqz	s7,dcb4 <_vsnprintf+0x5114>
    df0c:	4d41                	li	s10,16
    df0e:	7ba68963          	beq	a3,s10,e6c0 <_vsnprintf+0x5b20>
    df12:	4e89                	li	t4,2
    df14:	01d69463          	bne	a3,t4,df1c <_vsnprintf+0x537c>
    df18:	0560106f          	j	ef6e <_vsnprintf+0x63ce>
    df1c:	02000693          	li	a3,32
    df20:	4d01                	li	s10,0
    df22:	a4d703e3          	beq	a4,a3,d968 <_vsnprintf+0x4dc8>
    df26:	002707b3          	add	a5,a4,sp
    df2a:	03000b93          	li	s7,48
    df2e:	00170f13          	addi	t5,a4,1
    df32:	03778823          	sb	s7,48(a5)
    df36:	02000f93          	li	t6,32
    df3a:	cdff08e3          	beq	t5,t6,dc0a <_vsnprintf+0x506a>
    df3e:	877a                	mv	a4,t5
    df40:	ab55                	j	e4f4 <_vsnprintf+0x5954>
    df42:	0001                	nop
    df44:	4b81                	li	s7,0
    df46:	47c1                	li	a5,16
    df48:	d26fd06f          	j	b46e <_vsnprintf+0x28ce>
    df4c:	4a0e4263          	bltz	t3,e3f0 <_vsnprintf+0x5850>
    df50:	0042fe13          	andi	t3,t0,4
    df54:	660e05e3          	beqz	t3,edbe <_vsnprintf+0x621e>
    df58:	02078593          	addi	a1,a5,32
    df5c:	03010c93          	addi	s9,sp,48
    df60:	00178d13          	addi	s10,a5,1
    df64:	01958db3          	add	s11,a1,s9
    df68:	02b00693          	li	a3,43
    df6c:	fedd8023          	sb	a3,-32(s11)
    df70:	6382                	ld	t2,0(sp)
    df72:	8dc2                	mv	s11,a6
    df74:	8536                	mv	a0,a3
    df76:	4b09                	li	s6,2
    df78:	9ccfc06f          	j	a144 <_vsnprintf+0x15a4>
    df7c:	040d0b63          	beqz	s10,dfd2 <_vsnprintf+0x5432>
    df80:	3c0b85e3          	beqz	s7,eb4a <_vsnprintf+0x5faa>
    df84:	4bc1                	li	s7,16
    df86:	3b768fe3          	beq	a3,s7,eb44 <_vsnprintf+0x5fa4>
    df8a:	4509                	li	a0,2
    df8c:	4d01                	li	s10,0
    df8e:	d8a696e3          	bne	a3,a0,dd1a <_vsnprintf+0x517a>
    df92:	bb41                	j	dd22 <_vsnprintf+0x5182>
    df94:	ffed8313          	addi	t1,s11,-2
    df98:	02030c93          	addi	s9,t1,32
    df9c:	03010e13          	addi	t3,sp,48
    dfa0:	02067e93          	andi	t4,a2,32
    dfa4:	1dfd                	addi	s11,s11,-1
    dfa6:	01cc82b3          	add	t0,s9,t3
    dfaa:	4c0e96e3          	bnez	t4,ec76 <_vsnprintf+0x60d6>
    dfae:	07800d13          	li	s10,120
    dfb2:	ffa28023          	sb	s10,-32(t0)
    dfb6:	8d5e                	mv	s10,s7
    dfb8:	002d8eb3          	add	t4,s11,sp
    dfbc:	03000c93          	li	s9,48
    dfc0:	001d8793          	addi	a5,s11,1
    dfc4:	039e8823          	sb	s9,48(t4)
    dfc8:	02000e13          	li	t3,32
    dfcc:	8dbe                	mv	s11,a5
    dfce:	09c79263          	bne	a5,t3,e052 <_vsnprintf+0x54b2>
    dfd2:	00367593          	andi	a1,a2,3
    dfd6:	c199                	beqz	a1,dfdc <_vsnprintf+0x543c>
    dfd8:	bbbfd06f          	j	bb92 <_vsnprintf+0x2ff2>
    dfdc:	02000d93          	li	s11,32
    dfe0:	7c08bc0b          	th.extu	s8,a7,31,0
    dfe4:	d51deee3          	bltu	s11,a7,dd40 <_vsnprintf+0x51a0>
    dfe8:	babfd06f          	j	bb92 <_vsnprintf+0x2ff2>
    dfec:	040d0f63          	beqz	s10,e04a <_vsnprintf+0x54aa>
    dff0:	4d01                	li	s10,0
    dff2:	d00b9ee3          	bnez	s7,dd0e <_vsnprintf+0x516e>
    dff6:	00ad8663          	beq	s11,a0,e002 <_vsnprintf+0x5462>
    dffa:	7c08bc0b          	th.extu	s8,a7,31,0
    dffe:	d18d98e3          	bne	s11,s8,dd0e <_vsnprintf+0x516e>
    e002:	fffd8e13          	addi	t3,s11,-1
    e006:	8bea                	mv	s7,s10
    e008:	020e1463          	bnez	t3,e030 <_vsnprintf+0x5490>
    e00c:	4dc1                	li	s11,16
    e00e:	3fb685e3          	beq	a3,s11,ebf8 <_vsnprintf+0x6058>
    e012:	4b89                	li	s7,2
    e014:	597685e3          	beq	a3,s7,ed9e <_vsnprintf+0x61fe>
    e018:	03000513          	li	a0,48
    e01c:	02a10823          	sb	a0,48(sp)
    e020:	8a0d                	andi	a2,a2,3
    e022:	560604e3          	beqz	a2,ed8a <_vsnprintf+0x61ea>
    e026:	6682                	ld	a3,0(sp)
    e028:	4d85                	li	s11,1
    e02a:	b6ffd06f          	j	bb98 <_vsnprintf+0x2ff8>
    e02e:	4e7d                	li	t3,31
    e030:	4b41                	li	s6,16
    e032:	f76681e3          	beq	a3,s6,df94 <_vsnprintf+0x53f4>
    e036:	4709                	li	a4,2
    e038:	40e68de3          	beq	a3,a4,ec52 <_vsnprintf+0x60b2>
    e03c:	002e0f33          	add	t5,t3,sp
    e040:	03000793          	li	a5,48
    e044:	02ff0823          	sb	a5,48(t5)
    e048:	8d5e                	mv	s10,s7
    e04a:	02000393          	li	t2,32
    e04e:	f87d82e3          	beq	s11,t2,dfd2 <_vsnprintf+0x5432>
    e052:	00367293          	andi	t0,a2,3
    e056:	00029663          	bnez	t0,e062 <_vsnprintf+0x54c2>
    e05a:	7c08bc0b          	th.extu	s8,a7,31,0
    e05e:	cf8de1e3          	bltu	s11,s8,dd40 <_vsnprintf+0x51a0>
    e062:	6682                	ld	a3,0(sp)
    e064:	b35fd06f          	j	bb98 <_vsnprintf+0x2ff8>
    e068:	4e0edc63          	bgez	t4,e560 <_vsnprintf+0x59c0>
    e06c:	7c0c3c0b          	th.extu	s8,s8,31,0
    e070:	38fd                	addiw	a7,a7,-1
    e072:	0187f463          	bgeu	a5,s8,e07a <_vsnprintf+0x54da>
    e076:	e33fd06f          	j	bea8 <_vsnprintf+0x3308>
    e07a:	7c08b68b          	th.extu	a3,a7,31,0
    e07e:	00d7f463          	bgeu	a5,a3,e086 <_vsnprintf+0x54e6>
    e082:	f25fd06f          	j	bfa6 <_vsnprintf+0x3406>
    e086:	02000293          	li	t0,32
    e08a:	00579463          	bne	a5,t0,e092 <_vsnprintf+0x54f2>
    e08e:	9a0fe06f          	j	c22e <_vsnprintf+0x368e>
    e092:	86be                	mv	a3,a5
    e094:	810fe06f          	j	c0a4 <_vsnprintf+0x3504>
    e098:	7c0c3d0b          	th.extu	s10,s8,31,0
    e09c:	65a7f8e3          	bgeu	a5,s10,eeec <_vsnprintf+0x634c>
    e0a0:	0015fd93          	andi	s11,a1,1
    e0a4:	4881                	li	a7,0
    e0a6:	824fd06f          	j	b0ca <_vsnprintf+0x252a>
    e0aa:	560d1463          	bnez	s10,e612 <_vsnprintf+0x5a72>
    e0ae:	02000c13          	li	s8,32
    e0b2:	c58d8363          	beq	s11,s8,d4f8 <_vsnprintf+0x4958>
    e0b6:	8a0d                	andi	a2,a2,3
    e0b8:	f64d                	bnez	a2,e062 <_vsnprintf+0x54c2>
    e0ba:	8c2a                	mv	s8,a0
    e0bc:	c8ade2e3          	bltu	s11,a0,dd40 <_vsnprintf+0x51a0>
    e0c0:	6682                	ld	a3,0(sp)
    e0c2:	ad7fd06f          	j	bb98 <_vsnprintf+0x2ff8>
    e0c6:	0001                	nop
    e0c8:	3e088463          	beqz	a7,e4b0 <_vsnprintf+0x5910>
    e0cc:	001f7b13          	andi	s6,t5,1
    e0d0:	7c0c350b          	th.extu	a0,s8,31,0
    e0d4:	03010813          	addi	a6,sp,48
    e0d8:	6a0b0063          	beqz	s6,e778 <_vsnprintf+0x5bd8>
    e0dc:	7c08b78b          	th.extu	a5,a7,31,0
    e0e0:	c119                	beqz	a0,e0e6 <_vsnprintf+0x5546>
    e0e2:	d37fe06f          	j	ce18 <_vsnprintf+0x4278>
    e0e6:	e29fe06f          	j	cf0e <_vsnprintf+0x436e>
    e0ea:	0001                	nop
    e0ec:	7c0c3c0b          	th.extu	s8,s8,31,0
    e0f0:	0187f463          	bgeu	a5,s8,e0f8 <_vsnprintf+0x5558>
    e0f4:	c42fe06f          	j	c536 <_vsnprintf+0x3996>
    e0f8:	02000513          	li	a0,32
    e0fc:	9aa78763          	beq	a5,a0,d2aa <_vsnprintf+0x470a>
    e100:	060e5863          	bgez	t3,e170 <_vsnprintf+0x55d0>
    e104:	00a78633          	add	a2,a5,a0
    e108:	03010c93          	addi	s9,sp,48
    e10c:	01960733          	add	a4,a2,s9
    e110:	02d00a93          	li	s5,45
    e114:	00178c13          	addi	s8,a5,1
    e118:	ff570023          	sb	s5,-32(a4)
    e11c:	e20fe06f          	j	c73c <_vsnprintf+0x3b9c>
    e120:	002783b3          	add	t2,a5,sp
    e124:	02d00513          	li	a0,45
    e128:	02a38823          	sb	a0,48(t2)
    e12c:	6302                	ld	t1,0(sp)
    e12e:	00178c13          	addi	s8,a5,1
    e132:	4b09                	li	s6,2
    e134:	af3fc06f          	j	ac26 <_vsnprintf+0x2086>
    e138:	004af593          	andi	a1,s5,4
    e13c:	02b00513          	li	a0,43
    e140:	e599                	bnez	a1,e14e <_vsnprintf+0x55ae>
    e142:	008afc93          	andi	s9,s5,8
    e146:	780c8263          	beqz	s9,e8ca <_vsnprintf+0x5d2a>
    e14a:	02000513          	li	a0,32
    e14e:	8dc2                	mv	s11,a6
    e150:	02a10823          	sb	a0,48(sp)
    e154:	6802                	ld	a6,0(sp)
    e156:	4c05                	li	s8,1
    e158:	4b09                	li	s6,2
    e15a:	03010c93          	addi	s9,sp,48
    e15e:	8dcfe06f          	j	c23a <_vsnprintf+0x369a>
    e162:	7c0c3c0b          	th.extu	s8,s8,31,0
    e166:	4781                	li	a5,0
    e168:	03010b93          	addi	s7,sp,48
    e16c:	980c1363          	bnez	s8,d2f2 <_vsnprintf+0x4752>
    e170:	0045fb13          	andi	s6,a1,4
    e174:	8bae                	mv	s7,a1
    e176:	100b07e3          	beqz	s6,ea84 <_vsnprintf+0x5ee4>
    e17a:	02078393          	addi	t2,a5,32
    e17e:	03010f13          	addi	t5,sp,48
    e182:	01e38b33          	add	s6,t2,t5
    e186:	02b00513          	li	a0,43
    e18a:	feab0023          	sb	a0,-32(s6)
    e18e:	0035f313          	andi	t1,a1,3
    e192:	00178c13          	addi	s8,a5,1
    e196:	00031463          	bnez	t1,e19e <_vsnprintf+0x55fe>
    e19a:	f49fe06f          	j	d0e2 <_vsnprintf+0x4542>
    e19e:	6302                	ld	t1,0(sp)
    e1a0:	4b01                	li	s6,0
    e1a2:	8bfa                	mv	s7,t5
    e1a4:	a83fc06f          	j	ac26 <_vsnprintf+0x2086>
    e1a8:	4d01                	li	s10,0
    e1aa:	02067c93          	andi	s9,a2,32
    e1ae:	7c0c8163          	beqz	s9,e970 <_vsnprintf+0x5dd0>
    e1b2:	02000e13          	li	t3,32
    e1b6:	b7cd86e3          	beq	s11,t3,dd22 <_vsnprintf+0x5182>
    e1ba:	020d8293          	addi	t0,s11,32
    e1be:	180c                	addi	a1,sp,48
    e1c0:	00b28bb3          	add	s7,t0,a1
    e1c4:	05800513          	li	a0,88
    e1c8:	feab8023          	sb	a0,-32(s7)
    e1cc:	0d85                	addi	s11,s11,1
    e1ce:	b6b1                	j	dd1a <_vsnprintf+0x517a>
    e1d0:	86be                	mv	a3,a5
    e1d2:	ebffd06f          	j	c090 <_vsnprintf+0x34f0>
    e1d6:	e119                	bnez	a0,e1dc <_vsnprintf+0x563c>
    e1d8:	aa0fc06f          	j	a478 <_vsnprintf+0x18d8>
    e1dc:	6c82                	ld	s9,0(sp)
    e1de:	2b85                	addiw	s7,s7,1
    e1e0:	4a81                	li	s5,0
    e1e2:	f81fa06f          	j	9162 <_vsnprintf+0x5c2>
    e1e6:	b00b89e3          	beqz	s7,dcf8 <_vsnprintf+0x5158>
    e1ea:	4c41                	li	s8,16
    e1ec:	f7868963          	beq	a3,s8,d95e <_vsnprintf+0x4dbe>
    e1f0:	4589                	li	a1,2
    e1f2:	f6b69263          	bne	a3,a1,d956 <_vsnprintf+0x4db6>
    e1f6:	f68ff06f          	j	d95e <_vsnprintf+0x4dbe>
    e1fa:	000b8463          	beqz	s7,e202 <_vsnprintf+0x5662>
    e1fe:	9fafd06f          	j	b3f8 <_vsnprintf+0x2858>
    e202:	0045f293          	andi	t0,a1,4
    e206:	00028463          	beqz	t0,e20e <_vsnprintf+0x566e>
    e20a:	e37fc06f          	j	b040 <_vsnprintf+0x24a0>
    e20e:	0085fb93          	andi	s7,a1,8
    e212:	000b8463          	beqz	s7,e21a <_vsnprintf+0x567a>
    e216:	a56fd06f          	j	b46c <_vsnprintf+0x28cc>
    e21a:	8d3e                	mv	s10,a5
    e21c:	180c                	addi	a1,sp,48
    e21e:	02078793          	addi	a5,a5,32
    e222:	00b78fb3          	add	t6,a5,a1
    e226:	fdffc503          	lbu	a0,-33(t6)
    e22a:	e72fc06f          	j	a89c <_vsnprintf+0x1cfc>
    e22e:	680e9563          	bnez	t4,e8b8 <_vsnprintf+0x5d18>
    e232:	4b81                	li	s7,0
    e234:	00367713          	andi	a4,a2,3
    e238:	5a071e63          	bnez	a4,e7f4 <_vsnprintf+0x5c54>
    e23c:	02000d13          	li	s10,32
    e240:	7c08bc0b          	th.extu	s8,a7,31,0
    e244:	5b1d7863          	bgeu	s10,a7,e7f4 <_vsnprintf+0x5c54>
    e248:	6602                	ld	a2,0(sp)
    e24a:	ec46                	sd	a7,24(sp)
    e24c:	86a6                	mv	a3,s1
    e24e:	40cd0b33          	sub	s6,s10,a2
    e252:	fffb4e93          	not	t4,s6
    e256:	018e8833          	add	a6,t4,s8
    e25a:	85ca                	mv	a1,s2
    e25c:	02000513          	li	a0,32
    e260:	40c80cb3          	sub	s9,a6,a2
    e264:	00160d93          	addi	s11,a2,1
    e268:	9402                	jalr	s0
    e26a:	01bb0333          	add	t1,s6,s11
    e26e:	68e2                	ld	a7,24(sp)
    e270:	007cfc93          	andi	s9,s9,7
    e274:	15837363          	bgeu	t1,s8,e3ba <_vsnprintf+0x581a>
    e278:	0a0c8863          	beqz	s9,e328 <_vsnprintf+0x5788>
    e27c:	4685                	li	a3,1
    e27e:	08dc8863          	beq	s9,a3,e30e <_vsnprintf+0x576e>
    e282:	4e09                	li	t3,2
    e284:	07cc8c63          	beq	s9,t3,e2fc <_vsnprintf+0x575c>
    e288:	428d                	li	t0,3
    e28a:	065c8063          	beq	s9,t0,e2ea <_vsnprintf+0x574a>
    e28e:	4f91                	li	t6,4
    e290:	05fc8463          	beq	s9,t6,e2d8 <_vsnprintf+0x5738>
    e294:	4f15                	li	t5,5
    e296:	03ec8863          	beq	s9,t5,e2c6 <_vsnprintf+0x5726>
    e29a:	4519                	li	a0,6
    e29c:	00ac8c63          	beq	s9,a0,e2b4 <_vsnprintf+0x5714>
    e2a0:	866e                	mv	a2,s11
    e2a2:	ec46                	sd	a7,24(sp)
    e2a4:	86a6                	mv	a3,s1
    e2a6:	85ca                	mv	a1,s2
    e2a8:	02000513          	li	a0,32
    e2ac:	6d82                	ld	s11,0(sp)
    e2ae:	9402                	jalr	s0
    e2b0:	68e2                	ld	a7,24(sp)
    e2b2:	0d89                	addi	s11,s11,2
    e2b4:	866e                	mv	a2,s11
    e2b6:	ec46                	sd	a7,24(sp)
    e2b8:	86a6                	mv	a3,s1
    e2ba:	85ca                	mv	a1,s2
    e2bc:	02000513          	li	a0,32
    e2c0:	9402                	jalr	s0
    e2c2:	68e2                	ld	a7,24(sp)
    e2c4:	0d85                	addi	s11,s11,1
    e2c6:	866e                	mv	a2,s11
    e2c8:	ec46                	sd	a7,24(sp)
    e2ca:	86a6                	mv	a3,s1
    e2cc:	85ca                	mv	a1,s2
    e2ce:	02000513          	li	a0,32
    e2d2:	9402                	jalr	s0
    e2d4:	68e2                	ld	a7,24(sp)
    e2d6:	0d85                	addi	s11,s11,1
    e2d8:	866e                	mv	a2,s11
    e2da:	ec46                	sd	a7,24(sp)
    e2dc:	86a6                	mv	a3,s1
    e2de:	85ca                	mv	a1,s2
    e2e0:	02000513          	li	a0,32
    e2e4:	9402                	jalr	s0
    e2e6:	68e2                	ld	a7,24(sp)
    e2e8:	0d85                	addi	s11,s11,1
    e2ea:	866e                	mv	a2,s11
    e2ec:	ec46                	sd	a7,24(sp)
    e2ee:	86a6                	mv	a3,s1
    e2f0:	85ca                	mv	a1,s2
    e2f2:	02000513          	li	a0,32
    e2f6:	9402                	jalr	s0
    e2f8:	68e2                	ld	a7,24(sp)
    e2fa:	0d85                	addi	s11,s11,1
    e2fc:	866e                	mv	a2,s11
    e2fe:	ec46                	sd	a7,24(sp)
    e300:	86a6                	mv	a3,s1
    e302:	85ca                	mv	a1,s2
    e304:	02000513          	li	a0,32
    e308:	9402                	jalr	s0
    e30a:	68e2                	ld	a7,24(sp)
    e30c:	0d85                	addi	s11,s11,1
    e30e:	866e                	mv	a2,s11
    e310:	ec46                	sd	a7,24(sp)
    e312:	86a6                	mv	a3,s1
    e314:	85ca                	mv	a1,s2
    e316:	02000513          	li	a0,32
    e31a:	9402                	jalr	s0
    e31c:	0d85                	addi	s11,s11,1
    e31e:	01bb07b3          	add	a5,s6,s11
    e322:	68e2                	ld	a7,24(sp)
    e324:	0987fb63          	bgeu	a5,s8,e3ba <_vsnprintf+0x581a>
    e328:	ec56                	sd	s5,24(sp)
    e32a:	f05e                	sd	s7,32(sp)
    e32c:	8bc6                	mv	s7,a7
    e32e:	866e                	mv	a2,s11
    e330:	86a6                	mv	a3,s1
    e332:	85ca                	mv	a1,s2
    e334:	02000513          	li	a0,32
    e338:	9402                	jalr	s0
    e33a:	001d8c93          	addi	s9,s11,1
    e33e:	8666                	mv	a2,s9
    e340:	86a6                	mv	a3,s1
    e342:	85ca                	mv	a1,s2
    e344:	02000513          	li	a0,32
    e348:	9402                	jalr	s0
    e34a:	002d8a93          	addi	s5,s11,2
    e34e:	8656                	mv	a2,s5
    e350:	86a6                	mv	a3,s1
    e352:	85ca                	mv	a1,s2
    e354:	02000513          	li	a0,32
    e358:	9402                	jalr	s0
    e35a:	003d8c93          	addi	s9,s11,3
    e35e:	8666                	mv	a2,s9
    e360:	86a6                	mv	a3,s1
    e362:	85ca                	mv	a1,s2
    e364:	02000513          	li	a0,32
    e368:	9402                	jalr	s0
    e36a:	004d8a93          	addi	s5,s11,4
    e36e:	8656                	mv	a2,s5
    e370:	86a6                	mv	a3,s1
    e372:	85ca                	mv	a1,s2
    e374:	02000513          	li	a0,32
    e378:	9402                	jalr	s0
    e37a:	005d8c93          	addi	s9,s11,5
    e37e:	8666                	mv	a2,s9
    e380:	86a6                	mv	a3,s1
    e382:	85ca                	mv	a1,s2
    e384:	02000513          	li	a0,32
    e388:	9402                	jalr	s0
    e38a:	006d8a93          	addi	s5,s11,6
    e38e:	86a6                	mv	a3,s1
    e390:	8656                	mv	a2,s5
    e392:	85ca                	mv	a1,s2
    e394:	02000513          	li	a0,32
    e398:	9402                	jalr	s0
    e39a:	007d8c93          	addi	s9,s11,7
    e39e:	86a6                	mv	a3,s1
    e3a0:	8666                	mv	a2,s9
    e3a2:	85ca                	mv	a1,s2
    e3a4:	02000513          	li	a0,32
    e3a8:	0da1                	addi	s11,s11,8
    e3aa:	9402                	jalr	s0
    e3ac:	01bb08b3          	add	a7,s6,s11
    e3b0:	f788efe3          	bltu	a7,s8,e32e <_vsnprintf+0x578e>
    e3b4:	88de                	mv	a7,s7
    e3b6:	6ae2                	ld	s5,24(sp)
    e3b8:	7b82                	ld	s7,32(sp)
    e3ba:	6602                	ld	a2,0(sp)
    e3bc:	fffc0393          	addi	t2,s8,-1
    e3c0:	001d0593          	addi	a1,s10,1
    e3c4:	41a387b3          	sub	a5,t2,s10
    e3c8:	00bc3733          	sltu	a4,s8,a1
    e3cc:	42e0178b          	th.mvnez	a5,zero,a4
    e3d0:	00160e93          	addi	t4,a2,1
    e3d4:	03010b13          	addi	s6,sp,48
    e3d8:	01d783b3          	add	t2,a5,t4
    e3dc:	000d0463          	beqz	s10,e3e4 <_vsnprintf+0x5844>
    e3e0:	d5cfe06f          	j	c93c <_vsnprintf+0x3d9c>
    e3e4:	000b9463          	bnez	s7,e3ec <_vsnprintf+0x584c>
    e3e8:	ea6fe06f          	j	ca8e <_vsnprintf+0x3eee>
    e3ec:	eb8fe06f          	j	caa4 <_vsnprintf+0x3f04>
    e3f0:	02078b93          	addi	s7,a5,32
    e3f4:	03010f93          	addi	t6,sp,48
    e3f8:	00178d13          	addi	s10,a5,1
    e3fc:	01fb8db3          	add	s11,s7,t6
    e400:	02d00693          	li	a3,45
    e404:	b6a5                	j	df6c <_vsnprintf+0x53cc>
    e406:	000b9463          	bnez	s7,e40e <_vsnprintf+0x586e>
    e40a:	c8afc06f          	j	a894 <_vsnprintf+0x1cf4>
    e40e:	4b81                	li	s7,0
    e410:	000c8463          	beqz	s9,e418 <_vsnprintf+0x5878>
    e414:	c80fc06f          	j	a894 <_vsnprintf+0x1cf4>
    e418:	4b81                	li	s7,0
    e41a:	01af8463          	beq	t6,s10,e422 <_vsnprintf+0x5882>
    e41e:	cc4fe06f          	j	c8e2 <_vsnprintf+0x3d42>
    e422:	fffd0793          	addi	a5,s10,-1
    e426:	4b81                	li	s7,0
    e428:	020d0f13          	addi	t5,s10,32
    e42c:	03010893          	addi	a7,sp,48
    e430:	05800313          	li	t1,88
    e434:	011f0533          	add	a0,t5,a7
    e438:	fc650f23          	sb	t1,-34(a0)
    e43c:	ff1fc06f          	j	b42c <_vsnprintf+0x288c>
    e440:	36088a63          	beqz	a7,e7b4 <_vsnprintf+0x5c14>
    e444:	001ffb13          	andi	s6,t6,1
    e448:	7c0c350b          	th.extu	a0,s8,31,0
    e44c:	03010813          	addi	a6,sp,48
    e450:	340b0263          	beqz	s6,e794 <_vsnprintf+0x5bf4>
    e454:	c119                	beqz	a0,e45a <_vsnprintf+0x58ba>
    e456:	ebffe06f          	j	d314 <_vsnprintf+0x4774>
    e45a:	7c08b50b          	th.extu	a0,a7,31,0
    e45e:	fa9fe06f          	j	d406 <_vsnprintf+0x4866>
    e462:	0001                	nop
    e464:	ac0c1163          	bnez	s8,d726 <_vsnprintf+0x4b86>
    e468:	0045fb13          	andi	s6,a1,4
    e46c:	8cae                	mv	s9,a1
    e46e:	020b01e3          	beqz	s6,ec90 <_vsnprintf+0x60f0>
    e472:	02078d93          	addi	s11,a5,32
    e476:	03010293          	addi	t0,sp,48
    e47a:	005d8b33          	add	s6,s11,t0
    e47e:	02b00513          	li	a0,43
    e482:	feab0023          	sb	a0,-32(s6)
    e486:	0035f313          	andi	t1,a1,3
    e48a:	00178c13          	addi	s8,a5,1
    e48e:	7e031b63          	bnez	t1,ec84 <_vsnprintf+0x60e4>
    e492:	7c08bb8b          	th.extu	s7,a7,31,0
    e496:	8dc2                	mv	s11,a6
    e498:	4b01                	li	s6,0
    e49a:	017c7463          	bgeu	s8,s7,e4a2 <_vsnprintf+0x5902>
    e49e:	fb6fe06f          	j	cc54 <_vsnprintf+0x40b4>
    e4a2:	6802                	ld	a6,0(sp)
    e4a4:	02b00513          	li	a0,43
    e4a8:	03010c93          	addi	s9,sp,48
    e4ac:	d8ffd06f          	j	c23a <_vsnprintf+0x369a>
    e4b0:	7c0c350b          	th.extu	a0,s8,31,0
    e4b4:	03010813          	addi	a6,sp,48
    e4b8:	ea051963          	bnez	a0,db6a <_vsnprintf+0x4fca>
    e4bc:	003f7693          	andi	a3,t5,3
    e4c0:	6e02                	ld	t3,0(sp)
    e4c2:	e299                	bnez	a3,e4c8 <_vsnprintf+0x5928>
    e4c4:	f99fb06f          	j	a45c <_vsnprintf+0x18bc>
    e4c8:	6e02                	ld	t3,0(sp)
    e4ca:	e072                	sd	t3,0(sp)
    e4cc:	fadfb06f          	j	a478 <_vsnprintf+0x18d8>
    e4d0:	00278bb3          	add	s7,a5,sp
    e4d4:	02d00513          	li	a0,45
    e4d8:	02ab8823          	sb	a0,48(s7)
    e4dc:	8dc2                	mv	s11,a6
    e4de:	00178c13          	addi	s8,a5,1
    e4e2:	6802                	ld	a6,0(sp)
    e4e4:	4b09                	li	s6,2
    e4e6:	d55fd06f          	j	c23a <_vsnprintf+0x369a>
    e4ea:	4d01                	li	s10,0
    e4ec:	02000b93          	li	s7,32
    e4f0:	f1770d63          	beq	a4,s7,dc0a <_vsnprintf+0x506a>
    e4f4:	003e7593          	andi	a1,t3,3
    e4f8:	c199                	beqz	a1,e4fe <_vsnprintf+0x595e>
    e4fa:	b19fe06f          	j	d012 <_vsnprintf+0x4472>
    e4fe:	7c08bc0b          	th.extu	s8,a7,31,0
    e502:	c7876b63          	bltu	a4,s8,d978 <_vsnprintf+0x4dd8>
    e506:	6e02                	ld	t3,0(sp)
    e508:	946fd06f          	j	b64e <_vsnprintf+0x2aae>
    e50c:	00857693          	andi	a3,a0,8
    e510:	4b89                	li	s7,2
    e512:	38069f63          	bnez	a3,e8b0 <_vsnprintf+0x5d10>
    e516:	05210f93          	addi	t6,sp,82
    e51a:	8d5e                	mv	s10,s7
    e51c:	4ac1                	li	s5,16
    e51e:	fdffc503          	lbu	a0,-33(t6)
    e522:	b7afc06f          	j	a89c <_vsnprintf+0x1cfc>
    e526:	6682                	ld	a3,0(sp)
    e528:	4d09                	li	s10,2
    e52a:	e6efd06f          	j	bb98 <_vsnprintf+0x2ff8>
    e52e:	7c0c3d0b          	th.extu	s10,s8,31,0
    e532:	01a7f463          	bgeu	a5,s10,e53a <_vsnprintf+0x599a>
    e536:	b95fc06f          	j	b0ca <_vsnprintf+0x252a>
    e53a:	02000f13          	li	t5,32
    e53e:	93e78863          	beq	a5,t5,d66e <_vsnprintf+0x4ace>
    e542:	1e0e5063          	bgez	t3,e722 <_vsnprintf+0x5b82>
    e546:	01e78ab3          	add	s5,a5,t5
    e54a:	1810                	addi	a2,sp,48
    e54c:	00178d13          	addi	s10,a5,1
    e550:	02d00713          	li	a4,45
    e554:	00ca87b3          	add	a5,s5,a2
    e558:	fee78023          	sb	a4,-32(a5)
    e55c:	c99fc06f          	j	b1f4 <_vsnprintf+0x2654>
    e560:	00c6ff13          	andi	t5,a3,12
    e564:	7c0c3c0b          	th.extu	s8,s8,31,0
    e568:	fff8869b          	addiw	a3,a7,-1
    e56c:	43e6988b          	th.mvnez	a7,a3,t5
    e570:	0187f463          	bgeu	a5,s8,e578 <_vsnprintf+0x59d8>
    e574:	935fd06f          	j	bea8 <_vsnprintf+0x3308>
    e578:	7c08b68b          	th.extu	a3,a7,31,0
    e57c:	00d7f463          	bgeu	a5,a3,e584 <_vsnprintf+0x59e4>
    e580:	a27fd06f          	j	bfa6 <_vsnprintf+0x3406>
    e584:	02000e93          	li	t4,32
    e588:	01d79463          	bne	a5,t4,e590 <_vsnprintf+0x59f0>
    e58c:	ca3fd06f          	j	c22e <_vsnprintf+0x368e>
    e590:	bde1                	j	e468 <_vsnprintf+0x58c8>
    e592:	0001                	nop
    e594:	6e02                	ld	t3,0(sp)
    e596:	4d09                	li	s10,2
    e598:	8b6fd06f          	j	b64e <_vsnprintf+0x2aae>
    e59c:	4781                	li	a5,0
    e59e:	00c5fb93          	andi	s7,a1,12
    e5a2:	fff8829b          	addiw	t0,a7,-1
    e5a6:	7c0c3c0b          	th.extu	s8,s8,31,0
    e5aa:	4372988b          	th.mvnez	a7,t0,s7
    e5ae:	4f85                	li	t6,1
    e5b0:	03010b93          	addi	s7,sp,48
    e5b4:	0187f463          	bgeu	a5,s8,e5bc <_vsnprintf+0x5a1c>
    e5b8:	f7ffd06f          	j	c536 <_vsnprintf+0x3996>
    e5bc:	7c08bf8b          	th.extu	t6,a7,31,0
    e5c0:	01f7f463          	bgeu	a5,t6,e5c8 <_vsnprintf+0x5a28>
    e5c4:	868fe06f          	j	c62c <_vsnprintf+0x3a8c>
    e5c8:	02000c13          	li	s8,32
    e5cc:	01879463          	bne	a5,s8,e5d4 <_vsnprintf+0x5a34>
    e5d0:	d0dfe06f          	j	d2dc <_vsnprintf+0x473c>
    e5d4:	be71                	j	e170 <_vsnprintf+0x55d0>
    e5d6:	0001                	nop
    e5d8:	4809                	li	a6,2
    e5da:	400b8763          	beqz	s7,e9e8 <_vsnprintf+0x5e48>
    e5de:	4cc1                	li	s9,16
    e5e0:	3d968363          	beq	a3,s9,e9a6 <_vsnprintf+0x5e06>
    e5e4:	4309                	li	t1,2
    e5e6:	3e668563          	beq	a3,t1,e9d0 <_vsnprintf+0x5e30>
    e5ea:	02000e93          	li	t4,32
    e5ee:	25dd1863          	bne	s10,t4,e83e <_vsnprintf+0x5c9e>
    e5f2:	00367d13          	andi	s10,a2,3
    e5f6:	000d0463          	beqz	s10,e5fe <_vsnprintf+0x5a5e>
    e5fa:	b3afe06f          	j	c934 <_vsnprintf+0x3d94>
    e5fe:	02000d13          	li	s10,32
    e602:	011d6463          	bltu	s10,a7,e60a <_vsnprintf+0x5a6a>
    e606:	b2efe06f          	j	c934 <_vsnprintf+0x3d94>
    e60a:	7c08bc0b          	th.extu	s8,a7,31,0
    e60e:	8bc2                	mv	s7,a6
    e610:	b925                	j	e248 <_vsnprintf+0x56a8>
    e612:	4d01                	li	s10,0
    e614:	ef2ff06f          	j	dd06 <_vsnprintf+0x5166>
    e618:	26088a63          	beqz	a7,e88c <_vsnprintf+0x5cec>
    e61c:	001ffc93          	andi	s9,t6,1
    e620:	7c0c370b          	th.extu	a4,s8,31,0
    e624:	03010b13          	addi	s6,sp,48
    e628:	4a0c8e63          	beqz	s9,eae4 <_vsnprintf+0x5f44>
    e62c:	7c08b78b          	th.extu	a5,a7,31,0
    e630:	90071c63          	bnez	a4,d748 <_vsnprintf+0x4ba8>
    e634:	a0aff06f          	j	d83e <_vsnprintf+0x4c9e>
    e638:	00adf463          	bgeu	s11,a0,e640 <_vsnprintf+0x5aa0>
    e63c:	cd9fe06f          	j	d314 <_vsnprintf+0x4774>
    e640:	560d0b63          	beqz	s10,ebb6 <_vsnprintf+0x6016>
    e644:	540b9c63          	bnez	s7,eb9c <_vsnprintf+0x5ffc>
    e648:	4d01                	li	s10,0
    e64a:	b275                	j	dff6 <_vsnprintf+0x5456>
    e64c:	8bea                	mv	s7,s10
    e64e:	7c0c350b          	th.extu	a0,s8,31,0
    e652:	e62ff06f          	j	dcb4 <_vsnprintf+0x5114>
    e656:	1a0e8263          	beqz	t4,e7fa <_vsnprintf+0x5c5a>
    e65a:	040b9263          	bnez	s7,e69e <_vsnprintf+0x5afe>
    e65e:	01a70763          	beq	a4,s10,e66c <_vsnprintf+0x5acc>
    e662:	7c08be8b          	th.extu	t4,a7,31,0
    e666:	885e                	mv	a6,s7
    e668:	f7ae9be3          	bne	t4,s10,e5de <_vsnprintf+0x5a3e>
    e66c:	fffd0593          	addi	a1,s10,-1
    e670:	4a059d63          	bnez	a1,eb2a <_vsnprintf+0x5f8a>
    e674:	4841                	li	a6,16
    e676:	4f068963          	beq	a3,a6,eb68 <_vsnprintf+0x5fc8>
    e67a:	4d09                	li	s10,2
    e67c:	51a68463          	beq	a3,s10,eb84 <_vsnprintf+0x5fe4>
    e680:	03000713          	li	a4,48
    e684:	02e10823          	sb	a4,48(sp)
    e688:	8a0d                	andi	a2,a2,3
    e68a:	4c060763          	beqz	a2,eb58 <_vsnprintf+0x5fb8>
    e68e:	6382                	ld	t2,0(sp)
    e690:	4d05                	li	s10,1
    e692:	aaafe06f          	j	c93c <_vsnprintf+0x3d9c>
    e696:	49ac0963          	beq	s8,s10,eb28 <_vsnprintf+0x5f88>
    e69a:	49a88763          	beq	a7,s10,eb28 <_vsnprintf+0x5f88>
    e69e:	4801                	li	a6,0
    e6a0:	bf3d                	j	e5de <_vsnprintf+0x5a3e>
    e6a2:	02000313          	li	t1,32
    e6a6:	aa670c63          	beq	a4,t1,d95e <_vsnprintf+0x4dbe>
    e6aa:	00e80633          	add	a2,a6,a4
    e6ae:	8bea                	mv	s7,s10
    e6b0:	0705                	addi	a4,a4,1
    e6b2:	06200f93          	li	t6,98
    e6b6:	01f60023          	sb	t6,0(a2)
    e6ba:	8d5e                	mv	s10,s7
    e6bc:	a9aff06f          	j	d956 <_vsnprintf+0x4db6>
    e6c0:	4d01                	li	s10,0
    e6c2:	020e7c93          	andi	s9,t3,32
    e6c6:	180c8b63          	beqz	s9,e85c <_vsnprintf+0x5cbc>
    e6ca:	02000293          	li	t0,32
    e6ce:	a8570863          	beq	a4,t0,d95e <_vsnprintf+0x4dbe>
    e6d2:	02070393          	addi	t2,a4,32
    e6d6:	03010f13          	addi	t5,sp,48
    e6da:	01e38bb3          	add	s7,t2,t5
    e6de:	05800693          	li	a3,88
    e6e2:	fedb8023          	sb	a3,-32(s7)
    e6e6:	0705                	addi	a4,a4,1
    e6e8:	a6eff06f          	j	d956 <_vsnprintf+0x4db6>
    e6ec:	7c0c370b          	th.extu	a4,s8,31,0
    e6f0:	52ed7363          	bgeu	s10,a4,ec16 <_vsnprintf+0x6076>
    e6f4:	00167c93          	andi	s9,a2,1
    e6f8:	850ff06f          	j	d748 <_vsnprintf+0x4ba8>
    e6fc:	004af313          	andi	t1,s5,4
    e700:	06030663          	beqz	t1,e76c <_vsnprintf+0x5bcc>
    e704:	02b00693          	li	a3,43
    e708:	6382                	ld	t2,0(sp)
    e70a:	02d10823          	sb	a3,48(sp)
    e70e:	8dc2                	mv	s11,a6
    e710:	8536                	mv	a0,a3
    e712:	4d05                	li	s10,1
    e714:	4b09                	li	s6,2
    e716:	03010313          	addi	t1,sp,48
    e71a:	a2bfb06f          	j	a144 <_vsnprintf+0x15a4>
    e71e:	980d11e3          	bnez	s10,e0a0 <_vsnprintf+0x5500>
    e722:	0045fb13          	andi	s6,a1,4
    e726:	832e                	mv	t1,a1
    e728:	5e0b0763          	beqz	s6,ed16 <_vsnprintf+0x6176>
    e72c:	02078d93          	addi	s11,a5,32
    e730:	03010b13          	addi	s6,sp,48
    e734:	016d8fb3          	add	t6,s11,s6
    e738:	02b00393          	li	t2,43
    e73c:	fe7f8023          	sb	t2,-32(t6)
    e740:	0035f713          	andi	a4,a1,3
    e744:	00178d13          	addi	s10,a5,1
    e748:	5a071f63          	bnez	a4,ed06 <_vsnprintf+0x6166>
    e74c:	7c08bb8b          	th.extu	s7,a7,31,0
    e750:	8dc2                	mv	s11,a6
    e752:	4b01                	li	s6,0
    e754:	017d7463          	bgeu	s10,s7,e75c <_vsnprintf+0x5bbc>
    e758:	aadfc06f          	j	b204 <_vsnprintf+0x2664>
    e75c:	6382                	ld	t2,0(sp)
    e75e:	02b00513          	li	a0,43
    e762:	03010313          	addi	t1,sp,48
    e766:	9dffb06f          	j	a144 <_vsnprintf+0x15a4>
    e76a:	0001                	nop
    e76c:	008af593          	andi	a1,s5,8
    e770:	cdb5                	beqz	a1,e7ec <_vsnprintf+0x5c4c>
    e772:	02000693          	li	a3,32
    e776:	bf49                	j	e708 <_vsnprintf+0x5b68>
    e778:	c119                	beqz	a0,e77e <_vsnprintf+0x5bde>
    e77a:	e9efe06f          	j	ce18 <_vsnprintf+0x4278>
    e77e:	7c08bc0b          	th.extu	s8,a7,31,0
    e782:	9f876b63          	bltu	a4,s8,d978 <_vsnprintf+0x4dd8>
    e786:	d40701e3          	beqz	a4,e4c8 <_vsnprintf+0x5928>
    e78a:	6e02                	ld	t3,0(sp)
    e78c:	03010813          	addi	a6,sp,48
    e790:	ebffc06f          	j	b64e <_vsnprintf+0x2aae>
    e794:	c119                	beqz	a0,e79a <_vsnprintf+0x5bfa>
    e796:	b7ffe06f          	j	d314 <_vsnprintf+0x4774>
    e79a:	7c08bc0b          	th.extu	s8,a7,31,0
    e79e:	4d01                	li	s10,0
    e7a0:	db8de063          	bltu	s11,s8,dd40 <_vsnprintf+0x51a0>
    e7a4:	020d8463          	beqz	s11,e7cc <_vsnprintf+0x5c2c>
    e7a8:	6682                	ld	a3,0(sp)
    e7aa:	03010813          	addi	a6,sp,48
    e7ae:	beafd06f          	j	bb98 <_vsnprintf+0x2ff8>
    e7b2:	0001                	nop
    e7b4:	7c0c350b          	th.extu	a0,s8,31,0
    e7b8:	03010813          	addi	a6,sp,48
    e7bc:	be051863          	bnez	a0,dbac <_vsnprintf+0x500c>
    e7c0:	003ff693          	andi	a3,t6,3
    e7c4:	6d82                	ld	s11,0(sp)
    e7c6:	e299                	bnez	a3,e7cc <_vsnprintf+0x5c2c>
    e7c8:	d3cfd06f          	j	bd04 <_vsnprintf+0x3164>
    e7cc:	6d82                	ld	s11,0(sp)
    e7ce:	e06e                	sd	s11,0(sp)
    e7d0:	d36fd06f          	j	bd06 <_vsnprintf+0x3166>
    e7d4:	0086fc93          	andi	s9,a3,8
    e7d8:	4e0c9363          	bnez	s9,ecbe <_vsnprintf+0x611e>
    e7dc:	8c3e                	mv	s8,a5
    e7de:	4f89                	li	t6,2
    e7e0:	8dc2                	mv	s11,a6
    e7e2:	8b7e                	mv	s6,t6
    e7e4:	6802                	ld	a6,0(sp)
    e7e6:	e04fe06f          	j	cdea <_vsnprintf+0x424a>
    e7ea:	0001                	nop
    e7ec:	6e02                	ld	t3,0(sp)
    e7ee:	8dc2                	mv	s11,a6
    e7f0:	ae9fb06f          	j	a2d8 <_vsnprintf+0x1738>
    e7f4:	885e                	mv	a6,s7
    e7f6:	93efe06f          	j	c934 <_vsnprintf+0x3d94>
    e7fa:	4b81                	li	s7,0
    e7fc:	02000793          	li	a5,32
    e800:	a2fd0ae3          	beq	s10,a5,e234 <_vsnprintf+0x5694>
    e804:	8a0d                	andi	a2,a2,3
    e806:	92061c63          	bnez	a2,d93e <_vsnprintf+0x4d9e>
    e80a:	7c08bc0b          	th.extu	s8,a7,31,0
    e80e:	a38d6de3          	bltu	s10,s8,e248 <_vsnprintf+0x56a8>
    e812:	6382                	ld	t2,0(sp)
    e814:	928fe06f          	j	c93c <_vsnprintf+0x3d9c>
    e818:	00ed7463          	bgeu	s10,a4,e820 <_vsnprintf+0x5c80>
    e81c:	f2dfe06f          	j	d748 <_vsnprintf+0x4ba8>
    e820:	420e8c63          	beqz	t4,ec58 <_vsnprintf+0x60b8>
    e824:	e20b8de3          	beqz	s7,e65e <_vsnprintf+0x5abe>
    e828:	4bc1                	li	s7,16
    e82a:	17768d63          	beq	a3,s7,e9a4 <_vsnprintf+0x5e04>
    e82e:	4509                	li	a0,2
    e830:	52a68463          	beq	a3,a0,ed58 <_vsnprintf+0x61b8>
    e834:	02000d93          	li	s11,32
    e838:	4801                	li	a6,0
    e83a:	ddbd02e3          	beq	s10,s11,e5fe <_vsnprintf+0x5a5e>
    e83e:	002d0bb3          	add	s7,s10,sp
    e842:	03000393          	li	t2,48
    e846:	001d0513          	addi	a0,s10,1
    e84a:	027b8823          	sb	t2,48(s7)
    e84e:	02000593          	li	a1,32
    e852:	8bc2                	mv	s7,a6
    e854:	8d2a                	mv	s10,a0
    e856:	9cb50fe3          	beq	a0,a1,e234 <_vsnprintf+0x5694>
    e85a:	b76d                	j	e804 <_vsnprintf+0x5c64>
    e85c:	02000c13          	li	s8,32
    e860:	8f870f63          	beq	a4,s8,d95e <_vsnprintf+0x4dbe>
    e864:	018707b3          	add	a5,a4,s8
    e868:	03010f93          	addi	t6,sp,48
    e86c:	01f785b3          	add	a1,a5,t6
    e870:	07800513          	li	a0,120
    e874:	fea58023          	sb	a0,-32(a1)
    e878:	0705                	addi	a4,a4,1
    e87a:	8dcff06f          	j	d956 <_vsnprintf+0x4db6>
    e87e:	86be                	mv	a3,a5
    e880:	ddbfe06f          	j	d65a <_vsnprintf+0x4aba>
    e884:	6382                	ld	t2,0(sp)
    e886:	4b89                	li	s7,2
    e888:	8b4fe06f          	j	c93c <_vsnprintf+0x3d9c>
    e88c:	7c0c370b          	th.extu	a4,s8,31,0
    e890:	03010b13          	addi	s6,sp,48
    e894:	e60710e3          	bnez	a4,e6f4 <_vsnprintf+0x5b54>
    e898:	003ffb13          	andi	s6,t6,3
    e89c:	6382                	ld	t2,0(sp)
    e89e:	000b1463          	bnez	s6,e8a6 <_vsnprintf+0x5d06>
    e8a2:	9ecfe06f          	j	ca8e <_vsnprintf+0x3eee>
    e8a6:	6382                	ld	t2,0(sp)
    e8a8:	e01e                	sd	t2,0(sp)
    e8aa:	9e6fe06f          	j	ca90 <_vsnprintf+0x3ef0>
    e8ae:	0001                	nop
    e8b0:	87de                	mv	a5,s7
    e8b2:	4ac1                	li	s5,16
    e8b4:	bbbfc06f          	j	b46e <_vsnprintf+0x28ce>
    e8b8:	dc0b8fe3          	beqz	s7,e696 <_vsnprintf+0x5af6>
    e8bc:	4c41                	li	s8,16
    e8be:	d3868ae3          	beq	a3,s8,e5f2 <_vsnprintf+0x5a52>
    e8c2:	4b89                	li	s7,2
    e8c4:	d37693e3          	bne	a3,s7,e5ea <_vsnprintf+0x5a4a>
    e8c8:	b32d                	j	e5f2 <_vsnprintf+0x5a52>
    e8ca:	6e02                	ld	t3,0(sp)
    e8cc:	8dc2                	mv	s11,a6
    e8ce:	ad7fd06f          	j	c3a4 <_vsnprintf+0x3804>
    e8d2:	6a82                	ld	s5,0(sp)
    e8d4:	cb8fc06f          	j	ad8c <_vsnprintf+0x21ec>
    e8d8:	47fd                	li	a5,31
    e8da:	42c1                	li	t0,16
    e8dc:	1e568063          	beq	a3,t0,eabc <_vsnprintf+0x5f1c>
    e8e0:	4389                	li	t2,2
    e8e2:	1c768a63          	beq	a3,t2,eab6 <_vsnprintf+0x5f16>
    e8e6:	00278c33          	add	s8,a5,sp
    e8ea:	03000793          	li	a5,48
    e8ee:	02fc0823          	sb	a5,48(s8)
    e8f2:	8d5e                	mv	s10,s7
    e8f4:	bee5                	j	e4ec <_vsnprintf+0x594c>
    e8f6:	4b01                	li	s6,0
    e8f8:	937fd06f          	j	c22e <_vsnprintf+0x368e>
    e8fc:	05800c13          	li	s8,88
    e900:	002d06b3          	add	a3,s10,sp
    e904:	03868723          	sb	s8,46(a3)
    e908:	00288633          	add	a2,a7,sp
    e90c:	03000393          	li	t2,48
    e910:	02760823          	sb	t2,48(a2)
    e914:	4b81                	li	s7,0
    e916:	b2bfc06f          	j	b440 <_vsnprintf+0x28a0>
    e91a:	87b6                	mv	a5,a3
    e91c:	b6b1                	j	e468 <_vsnprintf+0x58c8>
    e91e:	82e2                	mv	t0,s8
    e920:	fadfa06f          	j	98cc <_vsnprintf+0xd2c>
    e924:	02000393          	li	t2,32
    e928:	be7d8d63          	beq	s11,t2,dd22 <_vsnprintf+0x5182>
    e92c:	01b80333          	add	t1,a6,s11
    e930:	8bea                	mv	s7,s10
    e932:	0d85                	addi	s11,s11,1
    e934:	06200e93          	li	t4,98
    e938:	01d30023          	sb	t4,0(t1)
    e93c:	8d5e                	mv	s10,s7
    e93e:	bdcff06f          	j	dd1a <_vsnprintf+0x517a>
    e942:	00c2f293          	andi	t0,t0,12
    e946:	fff88c9b          	addiw	s9,a7,-1
    e94a:	7c0c3d0b          	th.extu	s10,s8,31,0
    e94e:	425c988b          	th.mvnez	a7,s9,t0
    e952:	01a7f463          	bgeu	a5,s10,e95a <_vsnprintf+0x5dba>
    e956:	f74fc06f          	j	b0ca <_vsnprintf+0x252a>
    e95a:	7c08b68b          	th.extu	a3,a7,31,0
    e95e:	00d7f463          	bgeu	a5,a3,e966 <_vsnprintf+0x5dc6>
    e962:	c13fe06f          	j	d574 <_vsnprintf+0x49d4>
    e966:	02000c13          	li	s8,32
    e96a:	b1878263          	beq	a5,s8,dc6e <_vsnprintf+0x50ce>
    e96e:	bb55                	j	e722 <_vsnprintf+0x5b82>
    e970:	02000c13          	li	s8,32
    e974:	bb8d8763          	beq	s11,s8,dd22 <_vsnprintf+0x5182>
    e978:	018d8b33          	add	s6,s11,s8
    e97c:	1818                	addi	a4,sp,48
    e97e:	00eb0fb3          	add	t6,s6,a4
    e982:	07800693          	li	a3,120
    e986:	fedf8023          	sb	a3,-32(t6)
    e98a:	0d85                	addi	s11,s11,1
    e98c:	b8eff06f          	j	dd1a <_vsnprintf+0x517a>
    e990:	008afb93          	andi	s7,s5,8
    e994:	060b9d63          	bnez	s7,ea0e <_vsnprintf+0x5e6e>
    e998:	8c3e                	mv	s8,a5
    e99a:	4689                	li	a3,2
    e99c:	6302                	ld	t1,0(sp)
    e99e:	8b36                	mv	s6,a3
    e9a0:	8e9fe06f          	j	d288 <_vsnprintf+0x46e8>
    e9a4:	4801                	li	a6,0
    e9a6:	02067e13          	andi	t3,a2,32
    e9aa:	040e0363          	beqz	t3,e9f0 <_vsnprintf+0x5e50>
    e9ae:	02000d93          	li	s11,32
    e9b2:	c5bd00e3          	beq	s10,s11,e5f2 <_vsnprintf+0x5a52>
    e9b6:	020d0293          	addi	t0,s10,32
    e9ba:	03010f93          	addi	t6,sp,48
    e9be:	01f28f33          	add	t5,t0,t6
    e9c2:	05800513          	li	a0,88
    e9c6:	feaf0023          	sb	a0,-32(t5)
    e9ca:	0d05                	addi	s10,s10,1
    e9cc:	b939                	j	e5ea <_vsnprintf+0x5a4a>
    e9ce:	0001                	nop
    e9d0:	02000693          	li	a3,32
    e9d4:	c0dd0fe3          	beq	s10,a3,e5f2 <_vsnprintf+0x5a52>
    e9d8:	002d05b3          	add	a1,s10,sp
    e9dc:	06200713          	li	a4,98
    e9e0:	02e58823          	sb	a4,48(a1)
    e9e4:	0d05                	addi	s10,s10,1
    e9e6:	b111                	j	e5ea <_vsnprintf+0x5a4a>
    e9e8:	8bc2                	mv	s7,a6
    e9ea:	7c0c370b          	th.extu	a4,s8,31,0
    e9ee:	b985                	j	e65e <_vsnprintf+0x5abe>
    e9f0:	02000c13          	li	s8,32
    e9f4:	bf8d0fe3          	beq	s10,s8,e5f2 <_vsnprintf+0x5a52>
    e9f8:	018d0bb3          	add	s7,s10,s8
    e9fc:	181c                	addi	a5,sp,48
    e9fe:	00fb83b3          	add	t2,s7,a5
    ea02:	07800593          	li	a1,120
    ea06:	feb38023          	sb	a1,-32(t2)
    ea0a:	0d05                	addi	s10,s10,1
    ea0c:	bef9                	j	e5ea <_vsnprintf+0x5a4a>
    ea0e:	4b09                	li	s6,2
    ea10:	03010293          	addi	t0,sp,48
    ea14:	00578d33          	add	s10,a5,t0
    ea18:	02000513          	li	a0,32
    ea1c:	00ad0023          	sb	a0,0(s10)
    ea20:	898d                	andi	a1,a1,3
    ea22:	00178c13          	addi	s8,a5,1
    ea26:	e999                	bnez	a1,ea3c <_vsnprintf+0x5e9c>
    ea28:	7c08bd0b          	th.extu	s10,a7,31,0
    ea2c:	01ac7463          	bgeu	s8,s10,ea34 <_vsnprintf+0x5e94>
    ea30:	ec0fe06f          	j	d0f0 <_vsnprintf+0x4550>
    ea34:	6302                	ld	t1,0(sp)
    ea36:	8b96                	mv	s7,t0
    ea38:	9eefc06f          	j	ac26 <_vsnprintf+0x2086>
    ea3c:	6302                	ld	t1,0(sp)
    ea3e:	03010b93          	addi	s7,sp,48
    ea42:	9e4fc06f          	j	ac26 <_vsnprintf+0x2086>
    ea46:	02000e13          	li	t3,32
    ea4a:	01c79463          	bne	a5,t3,ea52 <_vsnprintf+0x5eb2>
    ea4e:	eeafb06f          	j	a138 <_vsnprintf+0x1598>
    ea52:	86be                	mv	a3,a5
    ea54:	f86fc06f          	j	b1da <_vsnprintf+0x263a>
    ea58:	86be                	mv	a3,a5
    ea5a:	01578463          	beq	a5,s5,ea62 <_vsnprintf+0x5ec2>
    ea5e:	e3efd06f          	j	c09c <_vsnprintf+0x34fc>
    ea62:	c5dfe06f          	j	d6be <_vsnprintf+0x4b1e>
    ea66:	020e7a93          	andi	s5,t3,32
    ea6a:	020a9e63          	bnez	s5,eaa6 <_vsnprintf+0x5f06>
    ea6e:	07800613          	li	a2,120
    ea72:	02c10823          	sb	a2,48(sp)
    ea76:	03000c93          	li	s9,48
    ea7a:	039108a3          	sb	s9,49(sp)
    ea7e:	8d5e                	mv	s10,s7
    ea80:	4709                	li	a4,2
    ea82:	bc8d                	j	e4f4 <_vsnprintf+0x5954>
    ea84:	0085f693          	andi	a3,a1,8
    ea88:	f6c1                	bnez	a3,ea10 <_vsnprintf+0x5e70>
    ea8a:	003bfa93          	andi	s5,s7,3
    ea8e:	8c3e                	mv	s8,a5
    ea90:	f00a96e3          	bnez	s5,e99c <_vsnprintf+0x5dfc>
    ea94:	7c08bd0b          	th.extu	s10,a7,31,0
    ea98:	4b01                	li	s6,0
    ea9a:	4681                	li	a3,0
    ea9c:	01ac7463          	bgeu	s8,s10,eaa4 <_vsnprintf+0x5f04>
    eaa0:	e50fe06f          	j	d0f0 <_vsnprintf+0x4550>
    eaa4:	bde5                	j	e99c <_vsnprintf+0x5dfc>
    eaa6:	05800313          	li	t1,88
    eaaa:	02610823          	sb	t1,48(sp)
    eaae:	8d5e                	mv	s10,s7
    eab0:	4705                	li	a4,1
    eab2:	c74ff06f          	j	df26 <_vsnprintf+0x5386>
    eab6:	00f80633          	add	a2,a6,a5
    eaba:	bee5                	j	e6b2 <_vsnprintf+0x5b12>
    eabc:	020e7e93          	andi	t4,t3,32
    eac0:	ffe70d13          	addi	s10,a4,-2
    eac4:	040e9463          	bnez	t4,eb0c <_vsnprintf+0x5f6c>
    eac8:	020d0713          	addi	a4,s10,32
    eacc:	03010c93          	addi	s9,sp,48
    ead0:	019702b3          	add	t0,a4,s9
    ead4:	07800393          	li	t2,120
    ead8:	fe728023          	sb	t2,-32(t0)
    eadc:	8d5e                	mv	s10,s7
    eade:	873e                	mv	a4,a5
    eae0:	c46ff06f          	j	df26 <_vsnprintf+0x5386>
    eae4:	c319                	beqz	a4,eaea <_vsnprintf+0x5f4a>
    eae6:	c63fe06f          	j	d748 <_vsnprintf+0x4ba8>
    eaea:	7c08bc0b          	th.extu	s8,a7,31,0
    eaee:	4b81                	li	s7,0
    eaf0:	f58d6c63          	bltu	s10,s8,e248 <_vsnprintf+0x56a8>
    eaf4:	da0d09e3          	beqz	s10,e8a6 <_vsnprintf+0x5d06>
    eaf8:	6382                	ld	t2,0(sp)
    eafa:	03010b13          	addi	s6,sp,48
    eafe:	e3ffd06f          	j	c93c <_vsnprintf+0x3d9c>
    eb02:	6802                	ld	a6,0(sp)
    eb04:	02d00513          	li	a0,45
    eb08:	f32fd06f          	j	c23a <_vsnprintf+0x369a>
    eb0c:	020d0b13          	addi	s6,s10,32
    eb10:	03010a93          	addi	s5,sp,48
    eb14:	015b0333          	add	t1,s6,s5
    eb18:	05800613          	li	a2,88
    eb1c:	177d                	addi	a4,a4,-1
    eb1e:	fec30023          	sb	a2,-32(t1)
    eb22:	8d5e                	mv	s10,s7
    eb24:	c02ff06f          	j	df26 <_vsnprintf+0x5386>
    eb28:	45fd                	li	a1,31
    eb2a:	4dc1                	li	s11,16
    eb2c:	0bb68363          	beq	a3,s11,ebd2 <_vsnprintf+0x6032>
    eb30:	4289                	li	t0,2
    eb32:	08568d63          	beq	a3,t0,ebcc <_vsnprintf+0x602c>
    eb36:	00258533          	add	a0,a1,sp
    eb3a:	03000c13          	li	s8,48
    eb3e:	03850823          	sb	s8,48(a0)
    eb42:	b96d                	j	e7fc <_vsnprintf+0x5c5c>
    eb44:	4d01                	li	s10,0
    eb46:	9dcff06f          	j	dd22 <_vsnprintf+0x5182>
    eb4a:	cfbc0263          	beq	s8,s11,e02e <_vsnprintf+0x548e>
    eb4e:	cfb88063          	beq	a7,s11,e02e <_vsnprintf+0x548e>
    eb52:	4d01                	li	s10,0
    eb54:	9baff06f          	j	dd0e <_vsnprintf+0x516e>
    eb58:	7c08bc0b          	th.extu	s8,a7,31,0
    eb5c:	4d05                	li	s10,1
    eb5e:	ef8d6563          	bltu	s10,s8,e248 <_vsnprintf+0x56a8>
    eb62:	6382                	ld	t2,0(sp)
    eb64:	dd9fd06f          	j	c93c <_vsnprintf+0x3d9c>
    eb68:	02067c93          	andi	s9,a2,32
    eb6c:	020c9163          	bnez	s9,eb8e <_vsnprintf+0x5fee>
    eb70:	07800693          	li	a3,120
    eb74:	02d10823          	sb	a3,48(sp)
    eb78:	03000e13          	li	t3,48
    eb7c:	03c108a3          	sb	t3,49(sp)
    eb80:	4d09                	li	s10,2
    eb82:	b149                	j	e804 <_vsnprintf+0x5c64>
    eb84:	06200e93          	li	t4,98
    eb88:	03d10823          	sb	t4,48(sp)
    eb8c:	b7f5                	j	eb78 <_vsnprintf+0x5fd8>
    eb8e:	05800313          	li	t1,88
    eb92:	02610823          	sb	t1,48(sp)
    eb96:	885e                	mv	a6,s7
    eb98:	4d05                	li	s10,1
    eb9a:	b155                	j	e83e <_vsnprintf+0x5c9e>
    eb9c:	4d41                	li	s10,16
    eb9e:	e1a68563          	beq	a3,s10,e1a8 <_vsnprintf+0x5608>
    eba2:	4509                	li	a0,2
    eba4:	00a68e63          	beq	a3,a0,ebc0 <_vsnprintf+0x6020>
    eba8:	02000313          	li	t1,32
    ebac:	4d01                	li	s10,0
    ebae:	986d8063          	beq	s11,t1,dd2e <_vsnprintf+0x518e>
    ebb2:	c06ff06f          	j	dfb8 <_vsnprintf+0x5418>
    ebb6:	02000613          	li	a2,32
    ebba:	c2cd8163          	beq	s11,a2,dfdc <_vsnprintf+0x543c>
    ebbe:	bef1                	j	e79a <_vsnprintf+0x5bfa>
    ebc0:	02000e93          	li	t4,32
    ebc4:	4d01                	li	s10,0
    ebc6:	97dd8463          	beq	s11,t4,dd2e <_vsnprintf+0x518e>
    ebca:	b38d                	j	e92c <_vsnprintf+0x5d8c>
    ebcc:	885e                	mv	a6,s7
    ebce:	8d2e                	mv	s10,a1
    ebd0:	b521                	j	e9d8 <_vsnprintf+0x5e38>
    ebd2:	ffed0813          	addi	a6,s10,-2
    ebd6:	02067c93          	andi	s9,a2,32
    ebda:	1d7d                	addi	s10,s10,-1
    ebdc:	02080313          	addi	t1,a6,32
    ebe0:	080c9263          	bnez	s9,ec64 <_vsnprintf+0x60c4>
    ebe4:	03010293          	addi	t0,sp,48
    ebe8:	00530fb3          	add	t6,t1,t0
    ebec:	07800f13          	li	t5,120
    ebf0:	ffef8023          	sb	t5,-32(t6)
    ebf4:	885e                	mv	a6,s7
    ebf6:	b1a1                	j	e83e <_vsnprintf+0x5c9e>
    ebf8:	02067b13          	andi	s6,a2,32
    ebfc:	020b1563          	bnez	s6,ec26 <_vsnprintf+0x6086>
    ec00:	07800693          	li	a3,120
    ec04:	02d10823          	sb	a3,48(sp)
    ec08:	03000f93          	li	t6,48
    ec0c:	03f108a3          	sb	t6,49(sp)
    ec10:	4d89                	li	s11,2
    ec12:	c40ff06f          	j	e052 <_vsnprintf+0x54b2>
    ec16:	000e8f63          	beqz	t4,ec34 <_vsnprintf+0x6094>
    ec1a:	4801                	li	a6,0
    ec1c:	9c0b91e3          	bnez	s7,e5de <_vsnprintf+0x5a3e>
    ec20:	9aed1fe3          	bne	s10,a4,e5de <_vsnprintf+0x5a3e>
    ec24:	b4a1                	j	e66c <_vsnprintf+0x5acc>
    ec26:	05800713          	li	a4,88
    ec2a:	02e10823          	sb	a4,48(sp)
    ec2e:	4d85                	li	s11,1
    ec30:	b88ff06f          	j	dfb8 <_vsnprintf+0x5418>
    ec34:	02000c13          	li	s8,32
    ec38:	4b81                	li	s7,0
    ec3a:	bd8d15e3          	bne	s10,s8,e804 <_vsnprintf+0x5c64>
    ec3e:	cf7fd06f          	j	c934 <_vsnprintf+0x3d94>
    ec42:	4ac1                	li	s5,16
    ec44:	4b89                	li	s7,2
    ec46:	fe2ff06f          	j	e428 <_vsnprintf+0x5888>
    ec4a:	6382                	ld	t2,0(sp)
    ec4c:	4b81                	li	s7,0
    ec4e:	ceffd06f          	j	c93c <_vsnprintf+0x3d9c>
    ec52:	01c80333          	add	t1,a6,t3
    ec56:	b9f9                	j	e934 <_vsnprintf+0x5d94>
    ec58:	02000e93          	li	t4,32
    ec5c:	4b81                	li	s7,0
    ec5e:	dddd0f63          	beq	s10,t4,e23c <_vsnprintf+0x569c>
    ec62:	b561                	j	eaea <_vsnprintf+0x5f4a>
    ec64:	1814                	addi	a3,sp,48
    ec66:	00d30e33          	add	t3,t1,a3
    ec6a:	05800d93          	li	s11,88
    ec6e:	ffbe0023          	sb	s11,-32(t3)
    ec72:	885e                	mv	a6,s7
    ec74:	b6e9                	j	e83e <_vsnprintf+0x5c9e>
    ec76:	05800593          	li	a1,88
    ec7a:	feb28023          	sb	a1,-32(t0)
    ec7e:	8d5e                	mv	s10,s7
    ec80:	b38ff06f          	j	dfb8 <_vsnprintf+0x5418>
    ec84:	8dc2                	mv	s11,a6
    ec86:	4b01                	li	s6,0
    ec88:	6802                	ld	a6,0(sp)
    ec8a:	8c96                	mv	s9,t0
    ec8c:	daefd06f          	j	c23a <_vsnprintf+0x369a>
    ec90:	0085ff93          	andi	t6,a1,8
    ec94:	060f9263          	bnez	t6,ecf8 <_vsnprintf+0x6158>
    ec98:	003cfe93          	andi	t4,s9,3
    ec9c:	8c3e                	mv	s8,a5
    ec9e:	b40e91e3          	bnez	t4,e7e0 <_vsnprintf+0x5c40>
    eca2:	7c08bb8b          	th.extu	s7,a7,31,0
    eca6:	8dc2                	mv	s11,a6
    eca8:	4b01                	li	s6,0
    ecaa:	4f81                	li	t6,0
    ecac:	017c7463          	bgeu	s8,s7,ecb4 <_vsnprintf+0x6114>
    ecb0:	fa5fd06f          	j	cc54 <_vsnprintf+0x40b4>
    ecb4:	b635                	j	e7e0 <_vsnprintf+0x5c40>
    ecb6:	6302                	ld	t1,0(sp)
    ecb8:	4b01                	li	s6,0
    ecba:	f6dfb06f          	j	ac26 <_vsnprintf+0x2086>
    ecbe:	8dc2                	mv	s11,a6
    ecc0:	4b09                	li	s6,2
    ecc2:	1818                	addi	a4,sp,48
    ecc4:	00e78f33          	add	t5,a5,a4
    ecc8:	02000513          	li	a0,32
    eccc:	00af0023          	sb	a0,0(t5)
    ecd0:	0035fd13          	andi	s10,a1,3
    ecd4:	00178c13          	addi	s8,a5,1
    ecd8:	020d1263          	bnez	s10,ecfc <_vsnprintf+0x615c>
    ecdc:	7c08bb8b          	th.extu	s7,a7,31,0
    ece0:	017c7463          	bgeu	s8,s7,ece8 <_vsnprintf+0x6148>
    ece4:	f71fd06f          	j	cc54 <_vsnprintf+0x40b4>
    ece8:	6802                	ld	a6,0(sp)
    ecea:	8cba                	mv	s9,a4
    ecec:	d4efd06f          	j	c23a <_vsnprintf+0x369a>
    ecf0:	008afb93          	andi	s7,s5,8
    ecf4:	fa0b87e3          	beqz	s7,eca2 <_vsnprintf+0x6102>
    ecf8:	8dc2                	mv	s11,a6
    ecfa:	b7e1                	j	ecc2 <_vsnprintf+0x6122>
    ecfc:	6802                	ld	a6,0(sp)
    ecfe:	03010c93          	addi	s9,sp,48
    ed02:	d38fd06f          	j	c23a <_vsnprintf+0x369a>
    ed06:	851e                	mv	a0,t2
    ed08:	8dc2                	mv	s11,a6
    ed0a:	6382                	ld	t2,0(sp)
    ed0c:	4b01                	li	s6,0
    ed0e:	03010313          	addi	t1,sp,48
    ed12:	c32fb06f          	j	a144 <_vsnprintf+0x15a4>
    ed16:	0085fa93          	andi	s5,a1,8
    ed1a:	040a8563          	beqz	s5,ed64 <_vsnprintf+0x61c4>
    ed1e:	8dc2                	mv	s11,a6
    ed20:	02078813          	addi	a6,a5,32
    ed24:	03010293          	addi	t0,sp,48
    ed28:	00580cb3          	add	s9,a6,t0
    ed2c:	02000c13          	li	s8,32
    ed30:	ff8c8023          	sb	s8,-32(s9)
    ed34:	0035fb93          	andi	s7,a1,3
    ed38:	00178d13          	addi	s10,a5,1
    ed3c:	000b9863          	bnez	s7,ed4c <_vsnprintf+0x61ac>
    ed40:	7c08bb8b          	th.extu	s7,a7,31,0
    ed44:	017d7463          	bgeu	s10,s7,ed4c <_vsnprintf+0x61ac>
    ed48:	cbcfc06f          	j	b204 <_vsnprintf+0x2664>
    ed4c:	6382                	ld	t2,0(sp)
    ed4e:	8562                	mv	a0,s8
    ed50:	03010313          	addi	t1,sp,48
    ed54:	bf0fb06f          	j	a144 <_vsnprintf+0x15a4>
    ed58:	02000293          	li	t0,32
    ed5c:	4801                	li	a6,0
    ed5e:	8a5d00e3          	beq	s10,t0,e5fe <_vsnprintf+0x5a5e>
    ed62:	b99d                	j	e9d8 <_vsnprintf+0x5e38>
    ed64:	00337e13          	andi	t3,t1,3
    ed68:	8d3e                	mv	s10,a5
    ed6a:	000e1b63          	bnez	t3,ed80 <_vsnprintf+0x61e0>
    ed6e:	7c08bb8b          	th.extu	s7,a7,31,0
    ed72:	8dc2                	mv	s11,a6
    ed74:	4b01                	li	s6,0
    ed76:	4a81                	li	s5,0
    ed78:	017d7463          	bgeu	s10,s7,ed80 <_vsnprintf+0x61e0>
    ed7c:	c88fc06f          	j	b204 <_vsnprintf+0x2664>
    ed80:	6382                	ld	t2,0(sp)
    ed82:	8dc2                	mv	s11,a6
    ed84:	8b56                	mv	s6,s5
    ed86:	e12fc06f          	j	b398 <_vsnprintf+0x27f8>
    ed8a:	7c08bc0b          	th.extu	s8,a7,31,0
    ed8e:	4d85                	li	s11,1
    ed90:	018df463          	bgeu	s11,s8,ed98 <_vsnprintf+0x61f8>
    ed94:	fadfe06f          	j	dd40 <_vsnprintf+0x51a0>
    ed98:	6682                	ld	a3,0(sp)
    ed9a:	dfffc06f          	j	bb98 <_vsnprintf+0x2ff8>
    ed9e:	06200c13          	li	s8,98
    eda2:	03810823          	sb	s8,48(sp)
    eda6:	b58d                	j	ec08 <_vsnprintf+0x6068>
    eda8:	004afb13          	andi	s6,s5,4
    edac:	f40b02e3          	beqz	s6,ecf0 <_vsnprintf+0x6150>
    edb0:	02b00b13          	li	s6,43
    edb4:	03610823          	sb	s6,48(sp)
    edb8:	4c05                	li	s8,1
    edba:	ed8ff06f          	j	e492 <_vsnprintf+0x58f2>
    edbe:	0082f313          	andi	t1,t0,8
    edc2:	02031463          	bnez	t1,edea <_vsnprintf+0x624a>
    edc6:	8d3e                	mv	s10,a5
    edc8:	4a89                	li	s5,2
    edca:	bf5d                	j	ed80 <_vsnprintf+0x61e0>
    edcc:	03000e93          	li	t4,48
    edd0:	47bd                	li	a5,15
    edd2:	03d10823          	sb	t4,48(sp)
    edd6:	4b81                	li	s7,0
    edd8:	4d01                	li	s10,0
    edda:	40000c93          	li	s9,1024
    edde:	4e05                	li	t3,1
    ede0:	8abe                	mv	s5,a5
    ede2:	03010b13          	addi	s6,sp,48
    ede6:	eecfb06f          	j	a4d2 <_vsnprintf+0x1932>
    edea:	8dc2                	mv	s11,a6
    edec:	4b09                	li	s6,2
    edee:	bf0d                	j	ed20 <_vsnprintf+0x6180>
    edf0:	000e8463          	beqz	t4,edf8 <_vsnprintf+0x6258>
    edf4:	b53fe06f          	j	d946 <_vsnprintf+0x4da6>
    edf8:	02000b93          	li	s7,32
    edfc:	01771463          	bne	a4,s7,ee04 <_vsnprintf+0x6264>
    ee00:	849fc06f          	j	b648 <_vsnprintf+0x2aa8>
    ee04:	9fcfe06f          	j	d000 <_vsnprintf+0x4460>
    ee08:	7c08bf8b          	th.extu	t6,a7,31,0
    ee0c:	01f7f463          	bgeu	a5,t6,ee14 <_vsnprintf+0x6274>
    ee10:	81dfd06f          	j	c62c <_vsnprintf+0x3a8c>
    ee14:	02000e13          	li	t3,32
    ee18:	01c79463          	bne	a5,t3,ee20 <_vsnprintf+0x6280>
    ee1c:	e01fb06f          	j	ac1c <_vsnprintf+0x207c>
    ee20:	903fd06f          	j	c722 <_vsnprintf+0x3b82>
    ee24:	02000513          	li	a0,32
    ee28:	02a79463          	bne	a5,a0,ee50 <_vsnprintf+0x62b0>
    ee2c:	0036fa93          	andi	s5,a3,3
    ee30:	000a9463          	bnez	s5,ee38 <_vsnprintf+0x6298>
    ee34:	897fe06f          	j	d6ca <_vsnprintf+0x4b2a>
    ee38:	bf6fd06f          	j	c22e <_vsnprintf+0x368e>
    ee3c:	f80e9f63          	bnez	t4,e5da <_vsnprintf+0x5a3a>
    ee40:	02000713          	li	a4,32
    ee44:	00ed1463          	bne	s10,a4,ee4c <_vsnprintf+0x62ac>
    ee48:	aedfd06f          	j	c934 <_vsnprintf+0x3d94>
    ee4c:	ae1fe06f          	j	d92c <_vsnprintf+0x4d8c>
    ee50:	86be                	mv	a3,a5
    ee52:	a4afd06f          	j	c09c <_vsnprintf+0x34fc>
    ee56:	020e8a63          	beqz	t4,ee8a <_vsnprintf+0x62ea>
    ee5a:	4d01                	li	s10,0
    ee5c:	000b8463          	beqz	s7,ee64 <_vsnprintf+0x62c4>
    ee60:	aebfe06f          	j	d94a <_vsnprintf+0x4daa>
    ee64:	00a70463          	beq	a4,a0,ee6c <_vsnprintf+0x62cc>
    ee68:	ae3fe06f          	j	d94a <_vsnprintf+0x4daa>
    ee6c:	e57fe06f          	j	dcc2 <_vsnprintf+0x5122>
    ee70:	020d0663          	beqz	s10,ee9c <_vsnprintf+0x62fc>
    ee74:	4d01                	li	s10,0
    ee76:	000b8463          	beqz	s7,ee7e <_vsnprintf+0x62de>
    ee7a:	e95fe06f          	j	dd0e <_vsnprintf+0x516e>
    ee7e:	00ad8463          	beq	s11,a0,ee86 <_vsnprintf+0x62e6>
    ee82:	e8dfe06f          	j	dd0e <_vsnprintf+0x516e>
    ee86:	97cff06f          	j	e002 <_vsnprintf+0x5462>
    ee8a:	02000b93          	li	s7,32
    ee8e:	01771463          	bne	a4,s7,ee96 <_vsnprintf+0x62f6>
    ee92:	fb6fc06f          	j	b648 <_vsnprintf+0x2aa8>
    ee96:	4d01                	li	s10,0
    ee98:	e5cff06f          	j	e4f4 <_vsnprintf+0x5954>
    ee9c:	02000b93          	li	s7,32
    eea0:	9b7d9963          	bne	s11,s7,e052 <_vsnprintf+0x54b2>
    eea4:	4d01                	li	s10,0
    eea6:	cedfc06f          	j	bb92 <_vsnprintf+0x2ff2>
    eeaa:	00457b93          	andi	s7,a0,4
    eeae:	020b9a63          	bnez	s7,eee2 <_vsnprintf+0x6342>
    eeb2:	00857593          	andi	a1,a0,8
    eeb6:	e18d                	bnez	a1,eed8 <_vsnprintf+0x6338>
    eeb8:	020d0c93          	addi	s9,s10,32
    eebc:	1810                	addi	a2,sp,48
    eebe:	00cc8fb3          	add	t6,s9,a2
    eec2:	fdffc503          	lbu	a0,-33(t6)
    eec6:	4b89                	li	s7,2
    eec8:	4ac1                	li	s5,16
    eeca:	9d3fb06f          	j	a89c <_vsnprintf+0x1cfc>
    eece:	47fd                	li	a5,31
    eed0:	4ac1                	li	s5,16
    eed2:	4b89                	li	s7,2
    eed4:	d54ff06f          	j	e428 <_vsnprintf+0x5888>
    eed8:	87ea                	mv	a5,s10
    eeda:	4b89                	li	s7,2
    eedc:	4ac1                	li	s5,16
    eede:	d90fc06f          	j	b46e <_vsnprintf+0x28ce>
    eee2:	87ea                	mv	a5,s10
    eee4:	4b89                	li	s7,2
    eee6:	4ac1                	li	s5,16
    eee8:	958fc06f          	j	b040 <_vsnprintf+0x24a0>
    eeec:	02000513          	li	a0,32
    eef0:	0ea79e63          	bne	a5,a0,efec <_vsnprintf+0x644c>
    eef4:	0032fe93          	andi	t4,t0,3
    eef8:	000e9463          	bnez	t4,ef00 <_vsnprintf+0x6360>
    eefc:	d7ffe06f          	j	dc7a <_vsnprintf+0x50da>
    ef00:	a38fb06f          	j	a138 <_vsnprintf+0x1598>
    ef04:	02000813          	li	a6,32
    ef08:	01078463          	beq	a5,a6,ef10 <_vsnprintf+0x6370>
    ef0c:	80ffd06f          	j	c71a <_vsnprintf+0x3b7a>
    ef10:	003afe93          	andi	t4,s5,3
    ef14:	000e9463          	bnez	t4,ef1c <_vsnprintf+0x637c>
    ef18:	ba0fe06f          	j	d2b8 <_vsnprintf+0x4718>
    ef1c:	d01fb06f          	j	ac1c <_vsnprintf+0x207c>
    ef20:	6382                	ld	t2,0(sp)
    ef22:	02d00513          	li	a0,45
    ef26:	a1efb06f          	j	a144 <_vsnprintf+0x15a4>
    ef2a:	6382                	ld	t2,0(sp)
    ef2c:	8dc2                	mv	s11,a6
    ef2e:	8532                	mv	a0,a2
    ef30:	4b01                	li	s6,0
    ef32:	a12fb06f          	j	a144 <_vsnprintf+0x15a4>
    ef36:	0001                	nop
    ef38:	87b6                	mv	a5,a3
    ef3a:	fe8ff06f          	j	e722 <_vsnprintf+0x5b82>
    ef3e:	004afb13          	andi	s6,s5,4
    ef42:	040b0263          	beqz	s6,ef86 <_vsnprintf+0x63e6>
    ef46:	02b00b13          	li	s6,43
    ef4a:	03610823          	sb	s6,48(sp)
    ef4e:	4d05                	li	s10,1
    ef50:	ffcff06f          	j	e74c <_vsnprintf+0x5bac>
    ef54:	00778463          	beq	a5,t2,ef5c <_vsnprintf+0x63bc>
    ef58:	fc2fd06f          	j	c71a <_vsnprintf+0x3b7a>
    ef5c:	b80fe06f          	j	d2dc <_vsnprintf+0x473c>
    ef60:	02000c13          	li	s8,32
    ef64:	81871de3          	bne	a4,s8,e77e <_vsnprintf+0x5bde>
    ef68:	4d01                	li	s10,0
    ef6a:	cadfe06f          	j	dc16 <_vsnprintf+0x5076>
    ef6e:	02000513          	li	a0,32
    ef72:	4d01                	li	s10,0
    ef74:	00a71463          	bne	a4,a0,ef7c <_vsnprintf+0x63dc>
    ef78:	9f1fe06f          	j	d968 <_vsnprintf+0x4dc8>
    ef7c:	f2eff06f          	j	e6aa <_vsnprintf+0x5b0a>
    ef80:	4b01                	li	s6,0
    ef82:	9b6fb06f          	j	a138 <_vsnprintf+0x1598>
    ef86:	008af393          	andi	t2,s5,8
    ef8a:	d8039ae3          	bnez	t2,ed1e <_vsnprintf+0x617e>
    ef8e:	b3c5                	j	ed6e <_vsnprintf+0x61ce>
    ef90:	6302                	ld	t1,0(sp)
    ef92:	02b00513          	li	a0,43
    ef96:	03010b93          	addi	s7,sp,48
    ef9a:	c8dfb06f          	j	ac26 <_vsnprintf+0x2086>
    ef9e:	008d7f13          	andi	t5,s10,8
    efa2:	a60f17e3          	bnez	t5,ea10 <_vsnprintf+0x5e70>
    efa6:	b4fd                	j	ea94 <_vsnprintf+0x5ef4>
    efa8:	6e02                	ld	t3,0(sp)
    efaa:	4d01                	li	s10,0
    efac:	ea2fc06f          	j	b64e <_vsnprintf+0x2aae>
    efb0:	7c08bc0b          	th.extu	s8,a7,31,0
    efb4:	4705                	li	a4,1
    efb6:	8d5e                	mv	s10,s7
    efb8:	01877463          	bgeu	a4,s8,efc0 <_vsnprintf+0x6420>
    efbc:	9bdfe06f          	j	d978 <_vsnprintf+0x4dd8>
    efc0:	6e02                	ld	t3,0(sp)
    efc2:	e8cfc06f          	j	b64e <_vsnprintf+0x2aae>
    efc6:	06200b13          	li	s6,98
    efca:	03610823          	sb	s6,48(sp)
    efce:	b465                	j	ea76 <_vsnprintf+0x5ed6>
    efd0:	03000793          	li	a5,48
    efd4:	02f10823          	sb	a5,48(sp)
    efd8:	47c1                	li	a5,16
    efda:	4d01                	li	s10,0
    efdc:	40000c93          	li	s9,1024
    efe0:	4e05                	li	t3,1
    efe2:	8abe                	mv	s5,a5
    efe4:	03010b13          	addi	s6,sp,48
    efe8:	ceafb06f          	j	a4d2 <_vsnprintf+0x1932>
    efec:	86be                	mv	a3,a5
    efee:	9e4fc06f          	j	b1d2 <_vsnprintf+0x2632>
    eff2:	0001                	nop
    eff4:	00000013          	nop
    eff8:	00000013          	nop
    effc:	00000013          	nop

000000000000f000 <puts>:
    f000:	1141                	addi	sp,sp,-16
    f002:	f811540b          	th.sdd	s0,ra,(sp),0,4
    f006:	842a                	mv	s0,a0
    f008:	00054503          	lbu	a0,0(a0)
    f00c:	c12d                	beqz	a0,f06e <puts+0x6e>
    f00e:	55fd                	li	a1,-1
    f010:	bd0f70ef          	jal	63e0 <fputc>
    f014:	00144503          	lbu	a0,1(s0)
    f018:	c939                	beqz	a0,f06e <puts+0x6e>
    f01a:	55fd                	li	a1,-1
    f01c:	bc4f70ef          	jal	63e0 <fputc>
    f020:	00244503          	lbu	a0,2(s0)
    f024:	c529                	beqz	a0,f06e <puts+0x6e>
    f026:	55fd                	li	a1,-1
    f028:	bb8f70ef          	jal	63e0 <fputc>
    f02c:	00344503          	lbu	a0,3(s0)
    f030:	cd1d                	beqz	a0,f06e <puts+0x6e>
    f032:	55fd                	li	a1,-1
    f034:	bacf70ef          	jal	63e0 <fputc>
    f038:	00444503          	lbu	a0,4(s0)
    f03c:	c90d                	beqz	a0,f06e <puts+0x6e>
    f03e:	55fd                	li	a1,-1
    f040:	ba0f70ef          	jal	63e0 <fputc>
    f044:	00544503          	lbu	a0,5(s0)
    f048:	c11d                	beqz	a0,f06e <puts+0x6e>
    f04a:	55fd                	li	a1,-1
    f04c:	b94f70ef          	jal	63e0 <fputc>
    f050:	00644503          	lbu	a0,6(s0)
    f054:	cd09                	beqz	a0,f06e <puts+0x6e>
    f056:	55fd                	li	a1,-1
    f058:	b88f70ef          	jal	63e0 <fputc>
    f05c:	00744503          	lbu	a0,7(s0)
    f060:	c519                	beqz	a0,f06e <puts+0x6e>
    f062:	55fd                	li	a1,-1
    f064:	b7cf70ef          	jal	63e0 <fputc>
    f068:	8884450b          	th.lbuib	a0,(s0),8,0
    f06c:	f14d                	bnez	a0,f00e <puts+0xe>
    f06e:	55fd                	li	a1,-1
    f070:	4529                	li	a0,10
    f072:	b6ef70ef          	jal	63e0 <fputc>
    f076:	f811440b          	th.ldd	s0,ra,(sp),0,4
    f07a:	4501                	li	a0,0
    f07c:	0141                	addi	sp,sp,16
    f07e:	8082                	ret

000000000000f080 <_putchar>:
    f080:	55fd                	li	a1,-1
    f082:	b5ef706f          	j	63e0 <fputc>
    f086:	00000013          	nop
    f08a:	00000013          	nop
    f08e:	0001                	nop

000000000000f090 <putchar>:
    f090:	1141                	addi	sp,sp,-16
    f092:	55fd                	li	a1,-1
    f094:	0ff57513          	zext.b	a0,a0
    f098:	e406                	sd	ra,8(sp)
    f09a:	b46f70ef          	jal	63e0 <fputc>
    f09e:	60a2                	ld	ra,8(sp)
    f0a0:	4501                	li	a0,0
    f0a2:	0141                	addi	sp,sp,16
    f0a4:	8082                	ret
    f0a6:	00000013          	nop
    f0aa:	00000013          	nop
    f0ae:	0001                	nop

000000000000f0b0 <printf>:
    f0b0:	711d                	addi	sp,sp,-96
    f0b2:	fed1560b          	th.sdd	a2,a3,(sp),3,4
    f0b6:	86aa                	mv	a3,a0
    f0b8:	651d                	lui	a0,0x7
    f0ba:	e0ba                	sd	a4,64(sp)
    f0bc:	e4be                	sd	a5,72(sp)
    f0be:	f42e                	sd	a1,40(sp)
    f0c0:	1038                	addi	a4,sp,40
    f0c2:	858a                	mv	a1,sp
    f0c4:	567d                	li	a2,-1
    f0c6:	10050513          	addi	a0,a0,256 # 7100 <_out_char>
    f0ca:	ec06                	sd	ra,24(sp)
    f0cc:	e8c2                	sd	a6,80(sp)
    f0ce:	ecc6                	sd	a7,88(sp)
    f0d0:	e43a                	sd	a4,8(sp)
    f0d2:	acff90ef          	jal	8ba0 <_vsnprintf>
    f0d6:	60e2                	ld	ra,24(sp)
    f0d8:	6125                	addi	sp,sp,96
    f0da:	8082                	ret
    f0dc:	00000013          	nop

000000000000f0e0 <sprintf>:
    f0e0:	715d                	addi	sp,sp,-80
    f0e2:	fcd1560b          	th.sdd	a2,a3,(sp),2,4
    f0e6:	86ae                	mv	a3,a1
    f0e8:	85aa                	mv	a1,a0
    f0ea:	651d                	lui	a0,0x7
    f0ec:	fef1570b          	th.sdd	a4,a5,(sp),3,4
    f0f0:	567d                	li	a2,-1
    f0f2:	1018                	addi	a4,sp,32
    f0f4:	0d050513          	addi	a0,a0,208 # 70d0 <_out_buffer>
    f0f8:	ec06                	sd	ra,24(sp)
    f0fa:	e0c2                	sd	a6,64(sp)
    f0fc:	e4c6                	sd	a7,72(sp)
    f0fe:	e43a                	sd	a4,8(sp)
    f100:	aa1f90ef          	jal	8ba0 <_vsnprintf>
    f104:	60e2                	ld	ra,24(sp)
    f106:	6161                	addi	sp,sp,80
    f108:	8082                	ret
    f10a:	00000013          	nop
    f10e:	0001                	nop

000000000000f110 <snprintf>:
    f110:	715d                	addi	sp,sp,-80
    f112:	f436                	sd	a3,40(sp)
    f114:	86b2                	mv	a3,a2
    f116:	862e                	mv	a2,a1
    f118:	85aa                	mv	a1,a0
    f11a:	651d                	lui	a0,0x7
    f11c:	fef1570b          	th.sdd	a4,a5,(sp),3,4
    f120:	0d050513          	addi	a0,a0,208 # 70d0 <_out_buffer>
    f124:	1038                	addi	a4,sp,40
    f126:	ec06                	sd	ra,24(sp)
    f128:	e0c2                	sd	a6,64(sp)
    f12a:	e4c6                	sd	a7,72(sp)
    f12c:	e43a                	sd	a4,8(sp)
    f12e:	a73f90ef          	jal	8ba0 <_vsnprintf>
    f132:	60e2                	ld	ra,24(sp)
    f134:	6161                	addi	sp,sp,80
    f136:	8082                	ret
    f138:	00000013          	nop
    f13c:	00000013          	nop

000000000000f140 <vprintf>:
    f140:	1101                	addi	sp,sp,-32
    f142:	86aa                	mv	a3,a0
    f144:	651d                	lui	a0,0x7
    f146:	872e                	mv	a4,a1
    f148:	567d                	li	a2,-1
    f14a:	002c                	addi	a1,sp,8
    f14c:	10050513          	addi	a0,a0,256 # 7100 <_out_char>
    f150:	ec06                	sd	ra,24(sp)
    f152:	a4ff90ef          	jal	8ba0 <_vsnprintf>
    f156:	60e2                	ld	ra,24(sp)
    f158:	6105                	addi	sp,sp,32
    f15a:	8082                	ret
    f15c:	00000013          	nop

000000000000f160 <vsnprintf>:
    f160:	8736                	mv	a4,a3
    f162:	86b2                	mv	a3,a2
    f164:	862e                	mv	a2,a1
    f166:	85aa                	mv	a1,a0
    f168:	651d                	lui	a0,0x7
    f16a:	0d050513          	addi	a0,a0,208 # 70d0 <_out_buffer>
    f16e:	a33f906f          	j	8ba0 <_vsnprintf>
    f172:	0001                	nop
    f174:	00000013          	nop
    f178:	00000013          	nop
    f17c:	00000013          	nop

000000000000f180 <fctprintf>:
    f180:	711d                	addi	sp,sp,-96
    f182:	fc36                	sd	a3,56(sp)
    f184:	e0ba                	sd	a4,64(sp)
    f186:	1838                	addi	a4,sp,56
    f188:	e43a                	sd	a4,8(sp)
    f18a:	e82a                	sd	a0,16(sp)
    f18c:	651d                	lui	a0,0x7
    f18e:	ec2e                	sd	a1,24(sp)
    f190:	86b2                	mv	a3,a2
    f192:	080c                	addi	a1,sp,16
    f194:	567d                	li	a2,-1
    f196:	0f050513          	addi	a0,a0,240 # 70f0 <_out_fct>
    f19a:	f406                	sd	ra,40(sp)
    f19c:	e4be                	sd	a5,72(sp)
    f19e:	e8c2                	sd	a6,80(sp)
    f1a0:	ecc6                	sd	a7,88(sp)
    f1a2:	9fff90ef          	jal	8ba0 <_vsnprintf>
    f1a6:	70a2                	ld	ra,40(sp)
    f1a8:	6125                	addi	sp,sp,96
    f1aa:	8082                	ret
    f1ac:	0000                	unimp
	...

000000000000f1b0 <__thead_vprintfsprintf>:
    f1b0:	4501                	li	a0,0
    f1b2:	8082                	ret
    f1b4:	00000013          	nop
    f1b8:	00000013          	nop
    f1bc:	00000013          	nop

000000000000f1c0 <__thead_vprintfprintf>:
    f1c0:	4501                	li	a0,0
    f1c2:	8082                	ret
    f1c4:	00000013          	nop
    f1c8:	00000013          	nop
    f1cc:	00000013          	nop

000000000000f1d0 <stdout>:
    f1d0:	4501                	li	a0,0
    f1d2:	8082                	ret
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
    f5e8:	b79ff0ef          	jal	f160 <vsnprintf>
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
    f6b8:	aa9ff0ef          	jal	f160 <vsnprintf>
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
    fa38:	07fd                	addi	a5,a5,31 # 101f <core_bench_list+0x6ef>
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
    fa9a:	06c1                	addi	a3,a3,16 # 1010 <core_bench_list+0x6e0>
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
    ffce:	fdf40413          	addi	s0,s0,-33 # fdf <core_bench_list+0x6af>
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
