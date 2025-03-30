
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
      bc:	4c5010ef          	jal	1d80 <main>

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
     6b8:	759020ef          	jal	3610 <core_bench_matrix>
     6bc:	0644d803          	lhu	a6,100(s1)
     6c0:	3c05298b          	th.ext	s3,a0,15,0
     6c4:	00081463          	bnez	a6,6cc <calc_func+0x5c>
     6c8:	06a49223          	sh	a0,100(s1)
     6cc:	0604d583          	lhu	a1,96(s1)
     6d0:	091040ef          	jal	4f60 <crcu16>
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
     724:	1cd030ef          	jal	40f0 <core_bench_state>
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
     786:	68b020ef          	jal	3610 <core_bench_matrix>
     78a:	06445803          	lhu	a6,100(s0)
     78e:	3c052a0b          	th.ext	s4,a0,15,0
     792:	00081763          	bnez	a6,7a0 <cmp_complex+0x60>
     796:	06a41223          	sh	a0,100(s0)
     79a:	0001                	nop
     79c:	00000013          	nop
     7a0:	06045583          	lhu	a1,96(s0)
     7a4:	07fa7a13          	andi	s4,s4,127
     7a8:	7b8040ef          	jal	4f60 <crcu16>
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
     7f8:	619020ef          	jal	3610 <core_bench_matrix>
     7fc:	06445603          	lhu	a2,100(s0)
     800:	3c05298b          	th.ext	s3,a0,15,0
     804:	e611                	bnez	a2,810 <cmp_complex+0xd0>
     806:	06a41223          	sh	a0,100(s0)
     80a:	0001                	nop
     80c:	00000013          	nop
     810:	06045583          	lhu	a1,96(s0)
     814:	74c040ef          	jal	4f60 <crcu16>
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
     874:	07d030ef          	jal	40f0 <core_bench_state>
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
     8a8:	049030ef          	jal	40f0 <core_bench_state>
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
     b20:	151040ef          	jal	5470 <crc16>
     b24:	6000                	ld	s0,0(s0)
     b26:	f42a                	sd	a0,40(sp)
     b28:	c445                	beqz	s0,bd0 <core_bench_list+0x2a0>
     b2a:	008a3803          	ld	a6,8(s4)
     b2e:	85aa                	mv	a1,a0
     b30:	00081503          	lh	a0,0(a6)
     b34:	13d040ef          	jal	5470 <crc16>
     b38:	00043c03          	ld	s8,0(s0)
     b3c:	f42a                	sd	a0,40(sp)
     b3e:	85aa                	mv	a1,a0
     b40:	080c0863          	beqz	s8,bd0 <core_bench_list+0x2a0>
     b44:	008a3f83          	ld	t6,8(s4)
     b48:	000f9503          	lh	a0,0(t6)
     b4c:	125040ef          	jal	5470 <crc16>
     b50:	000c3b03          	ld	s6,0(s8)
     b54:	f42a                	sd	a0,40(sp)
     b56:	85aa                	mv	a1,a0
     b58:	060b0c63          	beqz	s6,bd0 <core_bench_list+0x2a0>
     b5c:	008a3503          	ld	a0,8(s4)
     b60:	00051503          	lh	a0,0(a0)
     b64:	10d040ef          	jal	5470 <crc16>
     b68:	000b3d83          	ld	s11,0(s6)
     b6c:	f42a                	sd	a0,40(sp)
     b6e:	85aa                	mv	a1,a0
     b70:	060d8063          	beqz	s11,bd0 <core_bench_list+0x2a0>
     b74:	008a3e03          	ld	t3,8(s4)
     b78:	000e1503          	lh	a0,0(t3)
     b7c:	0f5040ef          	jal	5470 <crc16>
     b80:	000db903          	ld	s2,0(s11)
     b84:	f42a                	sd	a0,40(sp)
     b86:	85aa                	mv	a1,a0
     b88:	04090463          	beqz	s2,bd0 <core_bench_list+0x2a0>
     b8c:	008a3f03          	ld	t5,8(s4)
     b90:	000f1503          	lh	a0,0(t5)
     b94:	0dd040ef          	jal	5470 <crc16>
     b98:	00093983          	ld	s3,0(s2)
     b9c:	f42a                	sd	a0,40(sp)
     b9e:	85aa                	mv	a1,a0
     ba0:	02098863          	beqz	s3,bd0 <core_bench_list+0x2a0>
     ba4:	008a3683          	ld	a3,8(s4)
     ba8:	00069503          	lh	a0,0(a3)
     bac:	0c5040ef          	jal	5470 <crc16>
     bb0:	0009bd03          	ld	s10,0(s3)
     bb4:	f42a                	sd	a0,40(sp)
     bb6:	85aa                	mv	a1,a0
     bb8:	000d0c63          	beqz	s10,bd0 <core_bench_list+0x2a0>
     bbc:	008a3783          	ld	a5,8(s4)
     bc0:	00079503          	lh	a0,0(a5)
     bc4:	0ad040ef          	jal	5470 <crc16>
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
     ebc:	5b4040ef          	jal	5470 <crc16>
     ec0:	000cba83          	ld	s5,0(s9)
     ec4:	f42a                	sd	a0,40(sp)
     ec6:	0a0a8363          	beqz	s5,f6c <core_bench_list+0x63c>
     eca:	6410                	ld	a2,8(s0)
     ecc:	85aa                	mv	a1,a0
     ece:	00061503          	lh	a0,0(a2)
     ed2:	59e040ef          	jal	5470 <crc16>
     ed6:	000abc03          	ld	s8,0(s5)
     eda:	f42a                	sd	a0,40(sp)
     edc:	85aa                	mv	a1,a0
     ede:	080c0763          	beqz	s8,f6c <core_bench_list+0x63c>
     ee2:	00843803          	ld	a6,8(s0)
     ee6:	00081503          	lh	a0,0(a6)
     eea:	586040ef          	jal	5470 <crc16>
     eee:	000c3b03          	ld	s6,0(s8)
     ef2:	f42a                	sd	a0,40(sp)
     ef4:	85aa                	mv	a1,a0
     ef6:	060b0b63          	beqz	s6,f6c <core_bench_list+0x63c>
     efa:	00843f83          	ld	t6,8(s0)
     efe:	000f9503          	lh	a0,0(t6)
     f02:	56e040ef          	jal	5470 <crc16>
     f06:	000b3d83          	ld	s11,0(s6)
     f0a:	f42a                	sd	a0,40(sp)
     f0c:	85aa                	mv	a1,a0
     f0e:	040d8f63          	beqz	s11,f6c <core_bench_list+0x63c>
     f12:	6414                	ld	a3,8(s0)
     f14:	00069503          	lh	a0,0(a3)
     f18:	558040ef          	jal	5470 <crc16>
     f1c:	000db903          	ld	s2,0(s11)
     f20:	f42a                	sd	a0,40(sp)
     f22:	85aa                	mv	a1,a0
     f24:	04090463          	beqz	s2,f6c <core_bench_list+0x63c>
     f28:	00843e83          	ld	t4,8(s0)
     f2c:	000e9503          	lh	a0,0(t4)
     f30:	540040ef          	jal	5470 <crc16>
     f34:	00093983          	ld	s3,0(s2)
     f38:	f42a                	sd	a0,40(sp)
     f3a:	85aa                	mv	a1,a0
     f3c:	02098863          	beqz	s3,f6c <core_bench_list+0x63c>
     f40:	00843f03          	ld	t5,8(s0)
     f44:	000f1503          	lh	a0,0(t5)
     f48:	528040ef          	jal	5470 <crc16>
     f4c:	0009bd03          	ld	s10,0(s3)
     f50:	f42a                	sd	a0,40(sp)
     f52:	85aa                	mv	a1,a0
     f54:	000d0c63          	beqz	s10,f6c <core_bench_list+0x63c>
     f58:	6408                	ld	a0,8(s0)
     f5a:	00051503          	lh	a0,0(a0)
     f5e:	512040ef          	jal	5470 <crc16>
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
    102a:	737030ef          	jal	4f60 <crcu16>
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
    1078:	6e9030ef          	jal	4f60 <crcu16>
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
    1292:	37e020ef          	jal	3610 <core_bench_matrix>
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
    12cc:	625020ef          	jal	40f0 <core_bench_state>
    12d0:	066cdf83          	lhu	t6,102(s9)
    12d4:	fc0f97e3          	bnez	t6,12a2 <core_bench_list+0x972>
    12d8:	06ac9323          	sh	a0,102(s9)
    12dc:	b7d9                	j	12a2 <core_bench_list+0x972>
    12de:	0001                	nop
    12e0:	060cd603          	lhu	a2,96(s9)
    12e4:	6522                	ld	a0,8(sp)
    12e6:	32a020ef          	jal	3610 <core_bench_matrix>
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
    1320:	5d1020ef          	jal	40f0 <core_bench_state>
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
    13ba:	08070393          	addi	t2,a4,128 # 8080 <_ftoa+0xf50>
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
    1424:	32fd                	addiw	t0,t0,-1 # 7fff <_ftoa+0xecf>
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

0000000000001b60 <CK_Timer_Interruptservice>:
    1b60:	00041337          	lui	t1,0x41
    1b64:	fb830393          	addi	t2,t1,-72 # 40fb8 <Loop_Num>
    1b68:	0003a703          	lw	a4,0(t2)
    1b6c:	100117b7          	lui	a5,0x10011
    1b70:	00c7a283          	lw	t0,12(a5) # 1001100c <__kernel_stack+0xff2300c>
    1b74:	1141                	addi	sp,sp,-16
    1b76:	0017051b          	addiw	a0,a4,1
    1b7a:	c616                	sw	t0,12(sp)
    1b7c:	00a3a023          	sw	a0,0(t2)
    1b80:	0141                	addi	sp,sp,16
    1b82:	8082                	ret
    1b84:	00000013          	nop
    1b88:	00000013          	nop
    1b8c:	00000013          	nop

0000000000001b90 <Timer_Interrupt_Init>:
    1b90:	8082                	ret
    1b92:	0001                	nop
    1b94:	00000013          	nop
    1b98:	00000013          	nop
    1b9c:	00000013          	nop

0000000000001ba0 <iterate>:
    1ba0:	7179                	addi	sp,sp,-48
    1ba2:	e44e                	sd	s3,8(sp)
    1ba4:	e84a                	sd	s2,16(sp)
    1ba6:	fc11540b          	th.sdd	s0,ra,(sp),2,4
    1baa:	02c52983          	lw	s3,44(a0)
    1bae:	00041937          	lui	s2,0x41
    1bb2:	06053023          	sd	zero,96(a0)
    1bb6:	842a                	mv	s0,a0
    1bb8:	fb890913          	addi	s2,s2,-72 # 40fb8 <Loop_Num>
    1bbc:	3950d0ef          	jal	f750 <get_vtimer>
    1bc0:	00a92223          	sw	a0,4(s2)
    1bc4:	14098b63          	beqz	s3,1d1a <iterate+0x17a>
    1bc8:	4585                	li	a1,1
    1bca:	8522                	mv	a0,s0
    1bcc:	ec26                	sd	s1,24(sp)
    1bce:	d63fe0ef          	jal	930 <core_bench_list>
    1bd2:	06045583          	lhu	a1,96(s0)
    1bd6:	4485                	li	s1,1
    1bd8:	388030ef          	jal	4f60 <crcu16>
    1bdc:	06a41023          	sh	a0,96(s0)
    1be0:	55fd                	li	a1,-1
    1be2:	8522                	mv	a0,s0
    1be4:	d4dfe0ef          	jal	930 <core_bench_list>
    1be8:	06045583          	lhu	a1,96(s0)
    1bec:	374030ef          	jal	4f60 <crcu16>
    1bf0:	06a41023          	sh	a0,96(s0)
    1bf4:	06a41123          	sh	a0,98(s0)
    1bf8:	12998063          	beq	s3,s1,1d18 <iterate+0x178>
    1bfc:	409987b3          	sub	a5,s3,s1
    1c00:	0037f293          	andi	t0,a5,3
    1c04:	08028a63          	beqz	t0,1c98 <iterate+0xf8>
    1c08:	06928163          	beq	t0,s1,1c6a <iterate+0xca>
    1c0c:	e052                	sd	s4,0(sp)
    1c0e:	4a09                	li	s4,2
    1c10:	03428763          	beq	t0,s4,1c3e <iterate+0x9e>
    1c14:	85a6                	mv	a1,s1
    1c16:	8522                	mv	a0,s0
    1c18:	d19fe0ef          	jal	930 <core_bench_list>
    1c1c:	06045583          	lhu	a1,96(s0)
    1c20:	84d2                	mv	s1,s4
    1c22:	33e030ef          	jal	4f60 <crcu16>
    1c26:	06a41023          	sh	a0,96(s0)
    1c2a:	55fd                	li	a1,-1
    1c2c:	8522                	mv	a0,s0
    1c2e:	d03fe0ef          	jal	930 <core_bench_list>
    1c32:	06045583          	lhu	a1,96(s0)
    1c36:	32a030ef          	jal	4f60 <crcu16>
    1c3a:	06a41023          	sh	a0,96(s0)
    1c3e:	4585                	li	a1,1
    1c40:	8522                	mv	a0,s0
    1c42:	ceffe0ef          	jal	930 <core_bench_list>
    1c46:	06045583          	lhu	a1,96(s0)
    1c4a:	2485                	addiw	s1,s1,1
    1c4c:	314030ef          	jal	4f60 <crcu16>
    1c50:	06a41023          	sh	a0,96(s0)
    1c54:	55fd                	li	a1,-1
    1c56:	8522                	mv	a0,s0
    1c58:	cd9fe0ef          	jal	930 <core_bench_list>
    1c5c:	06045583          	lhu	a1,96(s0)
    1c60:	300030ef          	jal	4f60 <crcu16>
    1c64:	6a02                	ld	s4,0(sp)
    1c66:	06a41023          	sh	a0,96(s0)
    1c6a:	4585                	li	a1,1
    1c6c:	8522                	mv	a0,s0
    1c6e:	cc3fe0ef          	jal	930 <core_bench_list>
    1c72:	06045583          	lhu	a1,96(s0)
    1c76:	2485                	addiw	s1,s1,1
    1c78:	2e8030ef          	jal	4f60 <crcu16>
    1c7c:	06a41023          	sh	a0,96(s0)
    1c80:	55fd                	li	a1,-1
    1c82:	8522                	mv	a0,s0
    1c84:	cadfe0ef          	jal	930 <core_bench_list>
    1c88:	06045583          	lhu	a1,96(s0)
    1c8c:	2d4030ef          	jal	4f60 <crcu16>
    1c90:	06a41023          	sh	a0,96(s0)
    1c94:	08998263          	beq	s3,s1,1d18 <iterate+0x178>
    1c98:	4585                	li	a1,1
    1c9a:	8522                	mv	a0,s0
    1c9c:	c95fe0ef          	jal	930 <core_bench_list>
    1ca0:	06045583          	lhu	a1,96(s0)
    1ca4:	2485                	addiw	s1,s1,1
    1ca6:	2485                	addiw	s1,s1,1
    1ca8:	2b8030ef          	jal	4f60 <crcu16>
    1cac:	06a41023          	sh	a0,96(s0)
    1cb0:	55fd                	li	a1,-1
    1cb2:	8522                	mv	a0,s0
    1cb4:	c7dfe0ef          	jal	930 <core_bench_list>
    1cb8:	06045583          	lhu	a1,96(s0)
    1cbc:	2485                	addiw	s1,s1,1
    1cbe:	2a2030ef          	jal	4f60 <crcu16>
    1cc2:	06a41023          	sh	a0,96(s0)
    1cc6:	4585                	li	a1,1
    1cc8:	8522                	mv	a0,s0
    1cca:	c67fe0ef          	jal	930 <core_bench_list>
    1cce:	06045583          	lhu	a1,96(s0)
    1cd2:	28e030ef          	jal	4f60 <crcu16>
    1cd6:	06a41023          	sh	a0,96(s0)
    1cda:	55fd                	li	a1,-1
    1cdc:	8522                	mv	a0,s0
    1cde:	c53fe0ef          	jal	930 <core_bench_list>
    1ce2:	06045583          	lhu	a1,96(s0)
    1ce6:	27a030ef          	jal	4f60 <crcu16>
    1cea:	06a41023          	sh	a0,96(s0)
    1cee:	4585                	li	a1,1
    1cf0:	8522                	mv	a0,s0
    1cf2:	c3ffe0ef          	jal	930 <core_bench_list>
    1cf6:	06045583          	lhu	a1,96(s0)
    1cfa:	266030ef          	jal	4f60 <crcu16>
    1cfe:	06a41023          	sh	a0,96(s0)
    1d02:	55fd                	li	a1,-1
    1d04:	8522                	mv	a0,s0
    1d06:	c2bfe0ef          	jal	930 <core_bench_list>
    1d0a:	06045583          	lhu	a1,96(s0)
    1d0e:	252030ef          	jal	4f60 <crcu16>
    1d12:	06a41023          	sh	a0,96(s0)
    1d16:	bf91                	j	1c6a <iterate+0xca>
    1d18:	64e2                	ld	s1,24(sp)
    1d1a:	2370d0ef          	jal	f750 <get_vtimer>
    1d1e:	00492303          	lw	t1,4(s2)
    1d22:	85ce                	mv	a1,s3
    1d24:	4065063b          	subw	a2,a0,t1
    1d28:	0336563b          	divuw	a2,a2,s3
    1d2c:	e2c9550b          	th.swd	a0,a2,(s2),1,3
    1d30:	6541                	lui	a0,0x10
    1d32:	55850513          	addi	a0,a0,1368 # 10558 <__errno+0xc>
    1d36:	39a0d0ef          	jal	f0d0 <printf>
    1d3a:	00c92583          	lw	a1,12(s2)
    1d3e:	66c5                	lui	a3,0x11
    1d40:	b086a787          	flw	fa5,-1272(a3) # 10b08 <__errno+0x5bc>
    1d44:	d005f753          	fcvt.s.w	fa4,a1
    1d48:	63c1                	lui	t2,0x10
    1d4a:	18e7f053          	fdiv.s	ft0,fa5,fa4
    1d4e:	5a038513          	addi	a0,t2,1440 # 105a0 <__errno+0x54>
    1d52:	420000d3          	fcvt.d.s	ft1,ft0
    1d56:	e20085d3          	fmv.x.d	a1,ft1
    1d5a:	3760d0ef          	jal	f0d0 <printf>
    1d5e:	2030d0ef          	jal	f760 <sim_end>
    1d62:	fc11440b          	th.ldd	s0,ra,(sp),2,4
    1d66:	69a2                	ld	s3,8(sp)
    1d68:	6942                	ld	s2,16(sp)
    1d6a:	4501                	li	a0,0
    1d6c:	6145                	addi	sp,sp,48
    1d6e:	8082                	ret
	...

0000000000001d80 <main>:
    1d80:	716d                	addi	sp,sp,-272
    1d82:	e606                	sd	ra,264(sp)
    1d84:	f56e                	sd	s11,168(sp)
    1d86:	f96a                	sd	s10,176(sp)
    1d88:	fd66                	sd	s9,184(sp)
    1d8a:	e1e2                	sd	s8,192(sp)
    1d8c:	e5de                	sd	s7,200(sp)
    1d8e:	e9da                	sd	s6,208(sp)
    1d90:	edd6                	sd	s5,216(sp)
    1d92:	f1d2                	sd	s4,224(sp)
    1d94:	f5ce                	sd	s3,232(sp)
    1d96:	f9ca                	sd	s2,240(sp)
    1d98:	fda6                	sd	s1,248(sp)
    1d9a:	e222                	sd	s0,256(sp)
    1d9c:	ad22                	fsd	fs0,152(sp)
    1d9e:	81010113          	addi	sp,sp,-2032
    1da2:	862e                	mv	a2,a1
    1da4:	de2a                	sw	a0,60(sp)
    1da6:	186c                	addi	a1,sp,60
    1da8:	0aa10513          	addi	a0,sp,170
    1dac:	314020ef          	jal	40c0 <portable_init>
    1db0:	4505                	li	a0,1
    1db2:	07e030ef          	jal	4e30 <get_seed_32>
    1db6:	04a11023          	sh	a0,64(sp)
    1dba:	4509                	li	a0,2
    1dbc:	074030ef          	jal	4e30 <get_seed_32>
    1dc0:	04a11123          	sh	a0,66(sp)
    1dc4:	450d                	li	a0,3
    1dc6:	06a030ef          	jal	4e30 <get_seed_32>
    1dca:	4789                	li	a5,2
    1dcc:	04a11223          	sh	a0,68(sp)
    1dd0:	4515                	li	a0,5
    1dd2:	d6be                	sw	a5,108(sp)
    1dd4:	05c030ef          	jal	4e30 <get_seed_32>
    1dd8:	6706                	ld	a4,64(sp)
    1dda:	429d                	li	t0,7
    1ddc:	42a5128b          	th.mvnez	t0,a0,a0
    1de0:	01071693          	slli	a3,a4,0x10
    1de4:	d896                	sw	t0,112(sp)
    1de6:	0100                	addi	s0,sp,128
    1de8:	e699                	bnez	a3,1df6 <main+0x76>
    1dea:	06600313          	li	t1,102
    1dee:	fc641223          	sh	t1,-60(s0)
    1df2:	fc042023          	sw	zero,-64(s0)
    1df6:	fc043483          	ld	s1,-64(s0)
    1dfa:	4385                	li	t2,1
    1dfc:	bc04b50b          	th.extu	a0,s1,47,0
    1e00:	00751c63          	bne	a0,t2,1e18 <main+0x98>
    1e04:	341535b7          	lui	a1,0x34153
    1e08:	41558613          	addi	a2,a1,1045 # 34153415 <__kernel_stack+0x34065415>
    1e0c:	06600813          	li	a6,102
    1e10:	fcc42023          	sw	a2,-64(s0)
    1e14:	fd041223          	sh	a6,-60(s0)
    1e18:	0b010893          	addi	a7,sp,176
    1e1c:	0a011423          	sh	zero,168(sp)
    1e20:	0022f993          	andi	s3,t0,2
    1e24:	fd143423          	sd	a7,-56(s0)
    1e28:	0012ff13          	andi	t5,t0,1
    1e2c:	0042fa13          	andi	s4,t0,4
    1e30:	10099063          	bnez	s3,1f30 <main+0x1b0>
    1e34:	140a0663          	beqz	s4,1f80 <main+0x200>
    1e38:	001f0b1b          	addiw	s6,t5,1
    1e3c:	7d000b93          	li	s7,2000
    1e40:	036bde3b          	divuw	t3,s7,s6
    1e44:	4781                	li	a5,0
    1e46:	ffc42423          	sw	t3,-24(s0)
    1e4a:	0c0f13e3          	bnez	t5,2710 <main+0x990>
    1e4e:	21c7988b          	th.mula	a7,a5,t3
    1e52:	ff143023          	sd	a7,-32(s0)
    1e56:	ff042683          	lw	a3,-16(s0)
    1e5a:	0016f293          	andi	t0,a3,1
    1e5e:	00028e63          	beqz	t0,1e7a <main+0xfa>
    1e62:	fc041603          	lh	a2,-64(s0)
    1e66:	fe842503          	lw	a0,-24(s0)
    1e6a:	fd043583          	ld	a1,-48(s0)
    1e6e:	d42ff0ef          	jal	13b0 <core_list_init>
    1e72:	ff042683          	lw	a3,-16(s0)
    1e76:	fea43c23          	sd	a0,-8(s0)
    1e7a:	0026f713          	andi	a4,a3,2
    1e7e:	10071b63          	bnez	a4,1f94 <main+0x214>
    1e82:	0046f313          	andi	t1,a3,4
    1e86:	00030a63          	beqz	t1,1e9a <main+0x11a>
    1e8a:	fc041583          	lh	a1,-64(s0)
    1e8e:	fe842503          	lw	a0,-24(s0)
    1e92:	fe043603          	ld	a2,-32(s0)
    1e96:	36b020ef          	jal	4a00 <core_init_state>
    1e9a:	fec42883          	lw	a7,-20(s0)
    1e9e:	12088663          	beqz	a7,1fca <main+0x24a>
    1ea2:	00041937          	lui	s2,0x41
    1ea6:	fb890c13          	addi	s8,s2,-72 # 40fb8 <Loop_Num>
    1eaa:	0088                	addi	a0,sp,64
    1eac:	cf5ff0ef          	jal	1ba0 <iterate>
    1eb0:	000c2603          	lw	a2,0(s8)
    1eb4:	fc041503          	lh	a0,-64(s0)
    1eb8:	4581                	li	a1,0
    1eba:	fff64913          	not	s2,a2
    1ebe:	5b2030ef          	jal	5470 <crc16>
    1ec2:	85aa                	mv	a1,a0
    1ec4:	fc241503          	lh	a0,-62(s0)
    1ec8:	5a8030ef          	jal	5470 <crc16>
    1ecc:	85aa                	mv	a1,a0
    1ece:	fc441503          	lh	a0,-60(s0)
    1ed2:	59e030ef          	jal	5470 <crc16>
    1ed6:	85aa                	mv	a1,a0
    1ed8:	fe841503          	lh	a0,-24(s0)
    1edc:	594030ef          	jal	5470 <crc16>
    1ee0:	6821                	lui	a6,0x8
    1ee2:	0005099b          	sext.w	s3,a0
    1ee6:	b0580893          	addi	a7,a6,-1275 # 7b05 <_ftoa+0x9d5>
    1eea:	0f1984e3          	beq	s3,a7,27d2 <main+0xa52>
    1eee:	2d38e963          	bltu	a7,s3,21c0 <main+0x440>
    1ef2:	6a09                	lui	s4,0x2
    1ef4:	8f2a0c93          	addi	s9,s4,-1806 # 18f2 <core_list_mergesort+0x52>
    1ef8:	0b9989e3          	beq	s3,s9,27aa <main+0xa2a>
    1efc:	6f95                	lui	t6,0x5
    1efe:	eaff8493          	addi	s1,t6,-337 # 4eaf <crcu8+0x1f>
    1f02:	3e999163          	bne	s3,s1,22e4 <main+0x564>
    1f06:	67c1                	lui	a5,0x10
    1f08:	63878513          	addi	a0,a5,1592 # 10638 <__errno+0xec>
    1f0c:	1140d0ef          	jal	f020 <puts>
    1f10:	62b9                	lui	t0,0xe
    1f12:	6715                	lui	a4,0x5
    1f14:	639d                	lui	t2,0x7
    1f16:	5a428693          	addi	a3,t0,1444 # e5a4 <_vsnprintf+0x59e4>
    1f1a:	60870313          	addi	t1,a4,1544 # 5608 <crc16+0x198>
    1f1e:	a7938513          	addi	a0,t2,-1415 # 6a79 <fcvtbuf+0xb9>
    1f22:	8b36                	mv	s6,a3
    1f24:	ec36                	sd	a3,24(sp)
    1f26:	8a9a                	mv	s5,t1
    1f28:	e81a                	sd	t1,16(sp)
    1f2a:	8f2a                	mv	t5,a0
    1f2c:	e42a                	sd	a0,8(sp)
    1f2e:	a4f9                	j	21fc <main+0x47c>
    1f30:	020a0863          	beqz	s4,1f60 <main+0x1e0>
    1f34:	002f0d1b          	addiw	s10,t5,2
    1f38:	7d000d93          	li	s11,2000
    1f3c:	03adde3b          	divuw	t3,s11,s10
    1f40:	ffc42423          	sw	t3,-24(s0)
    1f44:	7c0f1063          	bnez	t5,2704 <main+0x984>
    1f48:	4e81                	li	t4,0
    1f4a:	4f11                	li	t5,4
    1f4c:	8fc6                	mv	t6,a7
    1f4e:	21ce9f8b          	th.mula	t6,t4,t3
    1f52:	001e8793          	addi	a5,t4,1
    1f56:	fdf43c23          	sd	t6,-40(s0)
    1f5a:	ee0f0ee3          	beqz	t5,1e56 <main+0xd6>
    1f5e:	bdc5                	j	1e4e <main+0xce>
    1f60:	001f0c1b          	addiw	s8,t5,1
    1f64:	7d000c93          	li	s9,2000
    1f68:	038cde3b          	divuw	t3,s9,s8
    1f6c:	4e81                	li	t4,0
    1f6e:	ffc42423          	sw	t3,-24(s0)
    1f72:	fc0f0de3          	beqz	t5,1f4c <main+0x1cc>
    1f76:	4f01                	li	t5,0
    1f78:	4e85                	li	t4,1
    1f7a:	fd143823          	sd	a7,-48(s0)
    1f7e:	b7f9                	j	1f4c <main+0x1cc>
    1f80:	7d000a93          	li	s5,2000
    1f84:	ff542423          	sw	s5,-24(s0)
    1f88:	ec0f07e3          	beqz	t5,1e56 <main+0xd6>
    1f8c:	fd143823          	sd	a7,-48(s0)
    1f90:	b5d9                	j	1e56 <main+0xd6>
    1f92:	0001                	nop
    1f94:	fc241383          	lh	t2,-62(s0)
    1f98:	fc041503          	lh	a0,-64(s0)
    1f9c:	86a2                	mv	a3,s0
    1f9e:	0103949b          	slliw	s1,t2,0x10
    1fa2:	00a4e5b3          	or	a1,s1,a0
    1fa6:	0005861b          	sext.w	a2,a1
    1faa:	fe842503          	lw	a0,-24(s0)
    1fae:	fd843583          	ld	a1,-40(s0)
    1fb2:	68e010ef          	jal	3640 <core_init_matrix>
    1fb6:	ff042603          	lw	a2,-16(s0)
    1fba:	00467813          	andi	a6,a2,4
    1fbe:	ec0816e3          	bnez	a6,1e8a <main+0x10a>
    1fc2:	fec42883          	lw	a7,-20(s0)
    1fc6:	ec089ee3          	bnez	a7,1ea2 <main+0x122>
    1fca:	6dc5                	lui	s11,0x11
    1fcc:	b08da407          	flw	fs0,-1272(s11) # 10b08 <__errno+0x5bc>
    1fd0:	4985                	li	s3,1
    1fd2:	00041a37          	lui	s4,0x41
    1fd6:	6ac1                	lui	s5,0x10
    1fd8:	6bc1                	lui	s7,0x10
    1fda:	fb8a0c13          	addi	s8,s4,-72 # 40fb8 <Loop_Num>
    1fde:	04010c93          	addi	s9,sp,64
    1fe2:	558a8b13          	addi	s6,s5,1368 # 10558 <__errno+0xc>
    1fe6:	5a0b8d13          	addi	s10,s7,1440 # 105a0 <__errno+0x54>
    1fea:	ff342623          	sw	s3,-20(s0)
    1fee:	0001                	nop
    1ff0:	fec42e03          	lw	t3,-20(s0)
    1ff4:	02043023          	sd	zero,32(s0)
    1ff8:	002e1e9b          	slliw	t4,t3,0x2
    1ffc:	01ce8f3b          	addw	t5,t4,t3
    2000:	001f191b          	slliw	s2,t5,0x1
    2004:	ff242623          	sw	s2,-20(s0)
    2008:	7480d0ef          	jal	f750 <get_vtimer>
    200c:	00ac2223          	sw	a0,4(s8)
    2010:	14090a63          	beqz	s2,2164 <main+0x3e4>
    2014:	4585                	li	a1,1
    2016:	8566                	mv	a0,s9
    2018:	919fe0ef          	jal	930 <core_bench_list>
    201c:	02045583          	lhu	a1,32(s0)
    2020:	4489                	li	s1,2
    2022:	73f020ef          	jal	4f60 <crcu16>
    2026:	02a41023          	sh	a0,32(s0)
    202a:	55fd                	li	a1,-1
    202c:	8566                	mv	a0,s9
    202e:	903fe0ef          	jal	930 <core_bench_list>
    2032:	02045583          	lhu	a1,32(s0)
    2036:	72b020ef          	jal	4f60 <crcu16>
    203a:	ffe90f93          	addi	t6,s2,-2
    203e:	02a41023          	sh	a0,32(s0)
    2042:	02a41123          	sh	a0,34(s0)
    2046:	4585                	li	a1,1
    2048:	8566                	mv	a0,s9
    204a:	003ff993          	andi	s3,t6,3
    204e:	8e3fe0ef          	jal	930 <core_bench_list>
    2052:	02045583          	lhu	a1,32(s0)
    2056:	70b020ef          	jal	4f60 <crcu16>
    205a:	02a41023          	sh	a0,32(s0)
    205e:	55fd                	li	a1,-1
    2060:	8566                	mv	a0,s9
    2062:	8cffe0ef          	jal	930 <core_bench_list>
    2066:	02045583          	lhu	a1,32(s0)
    206a:	6f7020ef          	jal	4f60 <crcu16>
    206e:	02a41023          	sh	a0,32(s0)
    2072:	0f24f963          	bgeu	s1,s2,2164 <main+0x3e4>
    2076:	08098963          	beqz	s3,2108 <main+0x388>
    207a:	4585                	li	a1,1
    207c:	04b98f63          	beq	s3,a1,20da <main+0x35a>
    2080:	02998863          	beq	s3,s1,20b0 <main+0x330>
    2084:	8566                	mv	a0,s9
    2086:	8abfe0ef          	jal	930 <core_bench_list>
    208a:	02045583          	lhu	a1,32(s0)
    208e:	448d                	li	s1,3
    2090:	6d1020ef          	jal	4f60 <crcu16>
    2094:	02a41023          	sh	a0,32(s0)
    2098:	55fd                	li	a1,-1
    209a:	8566                	mv	a0,s9
    209c:	895fe0ef          	jal	930 <core_bench_list>
    20a0:	02045583          	lhu	a1,32(s0)
    20a4:	6bd020ef          	jal	4f60 <crcu16>
    20a8:	02a41023          	sh	a0,32(s0)
    20ac:	00000013          	nop
    20b0:	4585                	li	a1,1
    20b2:	8566                	mv	a0,s9
    20b4:	87dfe0ef          	jal	930 <core_bench_list>
    20b8:	02045583          	lhu	a1,32(s0)
    20bc:	2485                	addiw	s1,s1,1
    20be:	6a3020ef          	jal	4f60 <crcu16>
    20c2:	02a41023          	sh	a0,32(s0)
    20c6:	55fd                	li	a1,-1
    20c8:	8566                	mv	a0,s9
    20ca:	867fe0ef          	jal	930 <core_bench_list>
    20ce:	02045583          	lhu	a1,32(s0)
    20d2:	68f020ef          	jal	4f60 <crcu16>
    20d6:	02a41023          	sh	a0,32(s0)
    20da:	4585                	li	a1,1
    20dc:	8566                	mv	a0,s9
    20de:	853fe0ef          	jal	930 <core_bench_list>
    20e2:	02045583          	lhu	a1,32(s0)
    20e6:	2485                	addiw	s1,s1,1
    20e8:	679020ef          	jal	4f60 <crcu16>
    20ec:	02a41023          	sh	a0,32(s0)
    20f0:	55fd                	li	a1,-1
    20f2:	8566                	mv	a0,s9
    20f4:	83dfe0ef          	jal	930 <core_bench_list>
    20f8:	02045583          	lhu	a1,32(s0)
    20fc:	665020ef          	jal	4f60 <crcu16>
    2100:	02a41023          	sh	a0,32(s0)
    2104:	0724f063          	bgeu	s1,s2,2164 <main+0x3e4>
    2108:	4585                	li	a1,1
    210a:	8566                	mv	a0,s9
    210c:	825fe0ef          	jal	930 <core_bench_list>
    2110:	02045583          	lhu	a1,32(s0)
    2114:	00148a1b          	addiw	s4,s1,1
    2118:	001a049b          	addiw	s1,s4,1
    211c:	645020ef          	jal	4f60 <crcu16>
    2120:	02a41023          	sh	a0,32(s0)
    2124:	55fd                	li	a1,-1
    2126:	8566                	mv	a0,s9
    2128:	809fe0ef          	jal	930 <core_bench_list>
    212c:	02045583          	lhu	a1,32(s0)
    2130:	631020ef          	jal	4f60 <crcu16>
    2134:	02a41023          	sh	a0,32(s0)
    2138:	4585                	li	a1,1
    213a:	8566                	mv	a0,s9
    213c:	ff4fe0ef          	jal	930 <core_bench_list>
    2140:	02045583          	lhu	a1,32(s0)
    2144:	61d020ef          	jal	4f60 <crcu16>
    2148:	02a41023          	sh	a0,32(s0)
    214c:	55fd                	li	a1,-1
    214e:	8566                	mv	a0,s9
    2150:	fe0fe0ef          	jal	930 <core_bench_list>
    2154:	02045583          	lhu	a1,32(s0)
    2158:	609020ef          	jal	4f60 <crcu16>
    215c:	02a41023          	sh	a0,32(s0)
    2160:	bf81                	j	20b0 <main+0x330>
    2162:	0001                	nop
    2164:	5ec0d0ef          	jal	f750 <get_vtimer>
    2168:	004c2783          	lw	a5,4(s8)
    216c:	85ca                	mv	a1,s2
    216e:	40f502bb          	subw	t0,a0,a5
    2172:	0322d63b          	divuw	a2,t0,s2
    2176:	e2cc550b          	th.swd	a0,a2,(s8),1,3
    217a:	855a                	mv	a0,s6
    217c:	7550c0ef          	jal	f0d0 <printf>
    2180:	00cc2683          	lw	a3,12(s8)
    2184:	856a                	mv	a0,s10
    2186:	d006f7d3          	fcvt.s.w	fa5,a3
    218a:	18f47053          	fdiv.s	ft0,fs0,fa5
    218e:	420000d3          	fcvt.d.s	ft1,ft0
    2192:	e20085d3          	fmv.x.d	a1,ft1
    2196:	73b0c0ef          	jal	f0d0 <printf>
    219a:	5c60d0ef          	jal	f760 <sim_end>
    219e:	4501                	li	a0,0
    21a0:	711010ef          	jal	40b0 <time_in_secs>
    21a4:	e40506e3          	beqz	a0,1ff0 <main+0x270>
    21a8:	4729                	li	a4,10
    21aa:	02a7533b          	divuw	t1,a4,a0
    21ae:	fec42503          	lw	a0,-20(s0)
    21b2:	0013039b          	addiw	t2,t1,1
    21b6:	02a385bb          	mulw	a1,t2,a0
    21ba:	feb42623          	sw	a1,-20(s0)
    21be:	b1f5                	j	1eaa <main+0x12a>
    21c0:	6b25                	lui	s6,0x9
    21c2:	a02b0e13          	addi	t3,s6,-1534 # 8a02 <_ftoa+0x18d2>
    21c6:	5bc98d63          	beq	s3,t3,2780 <main+0xa00>
    21ca:	673d                	lui	a4,0xf
    21cc:	9f570313          	addi	t1,a4,-1547 # e9f5 <_vsnprintf+0x5e35>
    21d0:	10699a63          	bne	s3,t1,22e4 <main+0x564>
    21d4:	63c1                	lui	t2,0x10
    21d6:	66838513          	addi	a0,t2,1640 # 10668 <__errno+0x11c>
    21da:	6470c0ef          	jal	f020 <puts>
    21de:	6525                	lui	a0,0x9
    21e0:	6609                	lui	a2,0x2
    21e2:	68b9                	lui	a7,0xe
    21e4:	e3a50593          	addi	a1,a0,-454 # 8e3a <_vsnprintf+0x27a>
    21e8:	fd760813          	addi	a6,a2,-41 # 1fd7 <main+0x257>
    21ec:	71488c13          	addi	s8,a7,1812 # e714 <_vsnprintf+0x5b54>
    21f0:	8b2e                	mv	s6,a1
    21f2:	ec2e                	sd	a1,24(sp)
    21f4:	8ac2                	mv	s5,a6
    21f6:	e842                	sd	a6,16(sp)
    21f8:	8f62                	mv	t5,s8
    21fa:	e462                	sd	s8,8(sp)
    21fc:	000404b7          	lui	s1,0x40
    2200:	0204a583          	lw	a1,32(s1) # 40020 <default_num_contexts>
    2204:	5e058c63          	beqz	a1,27fc <main+0xa7c>
    2208:	6641                	lui	a2,0x10
    220a:	68c1                	lui	a7,0x10
    220c:	6e41                	lui	t3,0x10
    220e:	6c860813          	addi	a6,a2,1736 # 106c8 <__errno+0x17c>
    2212:	6f888b93          	addi	s7,a7,1784 # 106f8 <__errno+0x1ac>
    2216:	730e0e93          	addi	t4,t3,1840 # 10730 <__errno+0x1e4>
    221a:	4d81                	li	s11,0
    221c:	4d01                	li	s10,0
    221e:	4c81                	li	s9,0
    2220:	000f0a1b          	sext.w	s4,t5
    2224:	f042                	sd	a6,32(sp)
    2226:	f45e                	sd	s7,40(sp)
    2228:	f876                	sd	t4,48(sp)
    222a:	a01d                	j	2250 <main+0x4d0>
    222c:	01c40cb3          	add	s9,s0,t3
    2230:	028cdf83          	lhu	t6,40(s9)
    2234:	0204a783          	lw	a5,32(s1)
    2238:	2d05                	addiw	s10,s10,1
    223a:	01fd8dbb          	addw	s11,s11,t6
    223e:	3c0d3d0b          	th.extu	s10,s10,15,0
    2242:	3c0dbc0b          	th.extu	s8,s11,15,0
    2246:	8cea                	mv	s9,s10
    2248:	3c0dad8b          	th.ext	s11,s11,15,0
    224c:	0afd7263          	bgeu	s10,a5,22f0 <main+0x570>
    2250:	003c9b93          	slli	s7,s9,0x3
    2254:	419b8f33          	sub	t5,s7,s9
    2258:	004f1f93          	slli	t6,t5,0x4
    225c:	01f40c33          	add	s8,s0,t6
    2260:	ff0c2803          	lw	a6,-16(s8)
    2264:	020c1423          	sh	zero,40(s8)
    2268:	00187793          	andi	a5,a6,1
    226c:	c395                	beqz	a5,2290 <main+0x510>
    226e:	022c5603          	lhu	a2,34(s8)
    2272:	01460f63          	beq	a2,s4,2290 <main+0x510>
    2276:	66a2                	ld	a3,8(sp)
    2278:	7502                	ld	a0,32(sp)
    227a:	85e6                	mv	a1,s9
    227c:	6550c0ef          	jal	f0d0 <printf>
    2280:	028c5283          	lhu	t0,40(s8)
    2284:	ff0c2803          	lw	a6,-16(s8)
    2288:	0012869b          	addiw	a3,t0,1
    228c:	02dc1423          	sh	a3,40(s8)
    2290:	00287713          	andi	a4,a6,2
    2294:	cb05                	beqz	a4,22c4 <main+0x544>
    2296:	419b8333          	sub	t1,s7,s9
    229a:	00431393          	slli	t2,t1,0x4
    229e:	00740c33          	add	s8,s0,t2
    22a2:	024c5603          	lhu	a2,36(s8)
    22a6:	01560f63          	beq	a2,s5,22c4 <main+0x544>
    22aa:	66c2                	ld	a3,16(sp)
    22ac:	7522                	ld	a0,40(sp)
    22ae:	85e6                	mv	a1,s9
    22b0:	6210c0ef          	jal	f0d0 <printf>
    22b4:	028c5503          	lhu	a0,40(s8)
    22b8:	ff0c2803          	lw	a6,-16(s8)
    22bc:	0015059b          	addiw	a1,a0,1
    22c0:	02bc1423          	sh	a1,40(s8)
    22c4:	419b88b3          	sub	a7,s7,s9
    22c8:	00487613          	andi	a2,a6,4
    22cc:	00489e13          	slli	t3,a7,0x4
    22d0:	de31                	beqz	a2,222c <main+0x4ac>
    22d2:	01c40bb3          	add	s7,s0,t3
    22d6:	026bd603          	lhu	a2,38(s7)
    22da:	45661163          	bne	a2,s6,271c <main+0x99c>
    22de:	028bdf83          	lhu	t6,40(s7)
    22e2:	bf89                	j	2234 <main+0x4b4>
    22e4:	6c41                	lui	s8,0x10
    22e6:	3c7d                	addiw	s8,s8,-1 # ffff <_malloc_trim_r+0x35>
    22e8:	000404b7          	lui	s1,0x40
    22ec:	00000013          	nop
    22f0:	340030ef          	jal	5630 <check_data_types>
    22f4:	fe842583          	lw	a1,-24(s0)
    22f8:	6ac1                	lui	s5,0x10
    22fa:	01850b3b          	addw	s6,a0,s8
    22fe:	760a8513          	addi	a0,s5,1888 # 10760 <__errno+0x214>
    2302:	5cf0c0ef          	jal	f0d0 <printf>
    2306:	62c1                	lui	t0,0x10
    2308:	85ca                	mv	a1,s2
    230a:	77828513          	addi	a0,t0,1912 # 10778 <__errno+0x22c>
    230e:	5c30c0ef          	jal	f0d0 <printf>
    2312:	854a                	mv	a0,s2
    2314:	59d010ef          	jal	40b0 <time_in_secs>
    2318:	66c1                	lui	a3,0x10
    231a:	85aa                	mv	a1,a0
    231c:	79068513          	addi	a0,a3,1936 # 10790 <__errno+0x244>
    2320:	5b10c0ef          	jal	f0d0 <printf>
    2324:	854a                	mv	a0,s2
    2326:	3c0b3a0b          	th.extu	s4,s6,15,0
    232a:	587010ef          	jal	40b0 <time_in_secs>
    232e:	42051263          	bnez	a0,2752 <main+0x9d2>
    2332:	854a                	mv	a0,s2
    2334:	57d010ef          	jal	40b0 <time_in_secs>
    2338:	4925                	li	s2,9
    233a:	40a97563          	bgeu	s2,a0,2744 <main+0x9c4>
    233e:	fec42603          	lw	a2,-20(s0)
    2342:	0204a583          	lw	a1,32(s1) # 40020 <default_num_contexts>
    2346:	6845                	lui	a6,0x11
    2348:	80080513          	addi	a0,a6,-2048 # 10800 <__errno+0x2b4>
    234c:	02c585bb          	mulw	a1,a1,a2
    2350:	6dc5                	lui	s11,0x11
    2352:	3c0a2b8b          	th.ext	s7,s4,15,0
    2356:	57b0c0ef          	jal	f0d0 <printf>
    235a:	68c5                	lui	a7,0x11
    235c:	6e45                	lui	t3,0x11
    235e:	81888593          	addi	a1,a7,-2024 # 10818 <__errno+0x2cc>
    2362:	830e0513          	addi	a0,t3,-2000 # 10830 <__errno+0x2e4>
    2366:	56b0c0ef          	jal	f0d0 <printf>
    236a:	6ec5                	lui	t4,0x11
    236c:	6f45                	lui	t5,0x11
    236e:	848e8593          	addi	a1,t4,-1976 # 10848 <__errno+0x2fc>
    2372:	850f0513          	addi	a0,t5,-1968 # 10850 <__errno+0x304>
    2376:	55b0c0ef          	jal	f0d0 <printf>
    237a:	6fc5                	lui	t6,0x11
    237c:	868f8593          	addi	a1,t6,-1944 # 10868 <__errno+0x31c>
    2380:	870d8513          	addi	a0,s11,-1936 # 10870 <__errno+0x324>
    2384:	54d0c0ef          	jal	f0d0 <printf>
    2388:	85ce                	mv	a1,s3
    238a:	69c5                	lui	s3,0x11
    238c:	88898513          	addi	a0,s3,-1912 # 10888 <__errno+0x33c>
    2390:	5410c0ef          	jal	f0d0 <printf>
    2394:	ff042d03          	lw	s10,-16(s0)
    2398:	001d7793          	andi	a5,s10,1
    239c:	c3f1                	beqz	a5,2460 <main+0x6e0>
    239e:	0204ac83          	lw	s9,32(s1)
    23a2:	0a0c8f63          	beqz	s9,2460 <main+0x6e0>
    23a6:	6b45                	lui	s6,0x11
    23a8:	4c01                	li	s8,0
    23aa:	4581                	li	a1,0
    23ac:	8a8b0a93          	addi	s5,s6,-1880 # 108a8 <__errno+0x35c>
    23b0:	00359293          	slli	t0,a1,0x3
    23b4:	40b286b3          	sub	a3,t0,a1
    23b8:	00469713          	slli	a4,a3,0x4
    23bc:	00e40333          	add	t1,s0,a4
    23c0:	02235603          	lhu	a2,34(t1)
    23c4:	8556                	mv	a0,s5
    23c6:	2c05                	addiw	s8,s8,1
    23c8:	5090c0ef          	jal	f0d0 <printf>
    23cc:	0204a383          	lw	t2,32(s1)
    23d0:	3c0c390b          	th.extu	s2,s8,15,0
    23d4:	85ca                	mv	a1,s2
    23d6:	08797563          	bgeu	s2,t2,2460 <main+0x6e0>
    23da:	00391513          	slli	a0,s2,0x3
    23de:	41250a33          	sub	s4,a0,s2
    23e2:	004a1813          	slli	a6,s4,0x4
    23e6:	01040633          	add	a2,s0,a6
    23ea:	02265603          	lhu	a2,34(a2)
    23ee:	8556                	mv	a0,s5
    23f0:	4e10c0ef          	jal	f0d0 <printf>
    23f4:	0204a883          	lw	a7,32(s1)
    23f8:	0019059b          	addiw	a1,s2,1
    23fc:	3c05bd8b          	th.extu	s11,a1,15,0
    2400:	85ee                	mv	a1,s11
    2402:	051dff63          	bgeu	s11,a7,2460 <main+0x6e0>
    2406:	003d9e13          	slli	t3,s11,0x3
    240a:	41be0eb3          	sub	t4,t3,s11
    240e:	004e9f13          	slli	t5,t4,0x4
    2412:	01e40fb3          	add	t6,s0,t5
    2416:	022fd603          	lhu	a2,34(t6)
    241a:	8556                	mv	a0,s5
    241c:	001d899b          	addiw	s3,s11,1
    2420:	4b10c0ef          	jal	f0d0 <printf>
    2424:	0204a783          	lw	a5,32(s1)
    2428:	3c09bd0b          	th.extu	s10,s3,15,0
    242c:	85ea                	mv	a1,s10
    242e:	02fd7963          	bgeu	s10,a5,2460 <main+0x6e0>
    2432:	003d1c93          	slli	s9,s10,0x3
    2436:	41ac8b33          	sub	s6,s9,s10
    243a:	004b1293          	slli	t0,s6,0x4
    243e:	005406b3          	add	a3,s0,t0
    2442:	0226d603          	lhu	a2,34(a3)
    2446:	8556                	mv	a0,s5
    2448:	4890c0ef          	jal	f0d0 <printf>
    244c:	0204a303          	lw	t1,32(s1)
    2450:	001d071b          	addiw	a4,s10,1
    2454:	3c073c0b          	th.extu	s8,a4,15,0
    2458:	85e2                	mv	a1,s8
    245a:	f46c6be3          	bltu	s8,t1,23b0 <main+0x630>
    245e:	0001                	nop
    2460:	ff042a83          	lw	s5,-16(s0)
    2464:	002af913          	andi	s2,s5,2
    2468:	0c090463          	beqz	s2,2530 <main+0x7b0>
    246c:	0204a383          	lw	t2,32(s1)
    2470:	38038863          	beqz	t2,2800 <main+0xa80>
    2474:	6a45                	lui	s4,0x11
    2476:	4981                	li	s3,0
    2478:	4581                	li	a1,0
    247a:	8c8a0d93          	addi	s11,s4,-1848 # 108c8 <__errno+0x37c>
    247e:	00359813          	slli	a6,a1,0x3
    2482:	40b80633          	sub	a2,a6,a1
    2486:	00461893          	slli	a7,a2,0x4
    248a:	01140e33          	add	t3,s0,a7
    248e:	024e5603          	lhu	a2,36(t3)
    2492:	856e                	mv	a0,s11
    2494:	43d0c0ef          	jal	f0d0 <printf>
    2498:	0204ae83          	lw	t4,32(s1)
    249c:	0019859b          	addiw	a1,s3,1
    24a0:	3c05b98b          	th.extu	s3,a1,15,0
    24a4:	85ce                	mv	a1,s3
    24a6:	09d9f563          	bgeu	s3,t4,2530 <main+0x7b0>
    24aa:	00399f13          	slli	t5,s3,0x3
    24ae:	413f0fb3          	sub	t6,t5,s3
    24b2:	004f9d13          	slli	s10,t6,0x4
    24b6:	01a407b3          	add	a5,s0,s10
    24ba:	0247d603          	lhu	a2,36(a5)
    24be:	856e                	mv	a0,s11
    24c0:	00198c9b          	addiw	s9,s3,1
    24c4:	40d0c0ef          	jal	f0d0 <printf>
    24c8:	0204a283          	lw	t0,32(s1)
    24cc:	3c0cbb0b          	th.extu	s6,s9,15,0
    24d0:	85da                	mv	a1,s6
    24d2:	045b7f63          	bgeu	s6,t0,2530 <main+0x7b0>
    24d6:	003b1693          	slli	a3,s6,0x3
    24da:	41668733          	sub	a4,a3,s6
    24de:	00471c13          	slli	s8,a4,0x4
    24e2:	01840333          	add	t1,s0,s8
    24e6:	02435603          	lhu	a2,36(t1)
    24ea:	856e                	mv	a0,s11
    24ec:	001b0a9b          	addiw	s5,s6,1
    24f0:	3e10c0ef          	jal	f0d0 <printf>
    24f4:	0204a383          	lw	t2,32(s1)
    24f8:	3c0ab90b          	th.extu	s2,s5,15,0
    24fc:	85ca                	mv	a1,s2
    24fe:	02797963          	bgeu	s2,t2,2530 <main+0x7b0>
    2502:	00391513          	slli	a0,s2,0x3
    2506:	41250a33          	sub	s4,a0,s2
    250a:	004a1813          	slli	a6,s4,0x4
    250e:	01040633          	add	a2,s0,a6
    2512:	02465603          	lhu	a2,36(a2)
    2516:	856e                	mv	a0,s11
    2518:	3b90c0ef          	jal	f0d0 <printf>
    251c:	0204ae03          	lw	t3,32(s1)
    2520:	0019089b          	addiw	a7,s2,1
    2524:	3c08b98b          	th.extu	s3,a7,15,0
    2528:	85ce                	mv	a1,s3
    252a:	f5c9eae3          	bltu	s3,t3,247e <main+0x6fe>
    252e:	0001                	nop
    2530:	ff042d83          	lw	s11,-16(s0)
    2534:	004df593          	andi	a1,s11,4
    2538:	c5e1                	beqz	a1,2600 <main+0x880>
    253a:	0204ae83          	lw	t4,32(s1)
    253e:	180e8163          	beqz	t4,26c0 <main+0x940>
    2542:	6f45                	lui	t5,0x11
    2544:	4c01                	li	s8,0
    2546:	4581                	li	a1,0
    2548:	8e8f0d13          	addi	s10,t5,-1816 # 108e8 <__errno+0x39c>
    254c:	00359f93          	slli	t6,a1,0x3
    2550:	40bf87b3          	sub	a5,t6,a1
    2554:	00479c93          	slli	s9,a5,0x4
    2558:	01940b33          	add	s6,s0,s9
    255c:	026b5603          	lhu	a2,38(s6)
    2560:	856a                	mv	a0,s10
    2562:	36f0c0ef          	jal	f0d0 <printf>
    2566:	0204a683          	lw	a3,32(s1)
    256a:	001c029b          	addiw	t0,s8,1
    256e:	3c02bc0b          	th.extu	s8,t0,15,0
    2572:	85e2                	mv	a1,s8
    2574:	08dc7663          	bgeu	s8,a3,2600 <main+0x880>
    2578:	003c1713          	slli	a4,s8,0x3
    257c:	41870333          	sub	t1,a4,s8
    2580:	00431a93          	slli	s5,t1,0x4
    2584:	01540933          	add	s2,s0,s5
    2588:	02695603          	lhu	a2,38(s2)
    258c:	856a                	mv	a0,s10
    258e:	3430c0ef          	jal	f0d0 <printf>
    2592:	0204a503          	lw	a0,32(s1)
    2596:	001c039b          	addiw	t2,s8,1
    259a:	3c03ba0b          	th.extu	s4,t2,15,0
    259e:	85d2                	mv	a1,s4
    25a0:	06aa7063          	bgeu	s4,a0,2600 <main+0x880>
    25a4:	003a1813          	slli	a6,s4,0x3
    25a8:	41480633          	sub	a2,a6,s4
    25ac:	00461893          	slli	a7,a2,0x4
    25b0:	011409b3          	add	s3,s0,a7
    25b4:	0269d603          	lhu	a2,38(s3)
    25b8:	856a                	mv	a0,s10
    25ba:	3170c0ef          	jal	f0d0 <printf>
    25be:	0204ae83          	lw	t4,32(s1)
    25c2:	001a0e1b          	addiw	t3,s4,1
    25c6:	3c0e3d8b          	th.extu	s11,t3,15,0
    25ca:	85ee                	mv	a1,s11
    25cc:	03ddfa63          	bgeu	s11,t4,2600 <main+0x880>
    25d0:	003d9f13          	slli	t5,s11,0x3
    25d4:	41bf0fb3          	sub	t6,t5,s11
    25d8:	004f9793          	slli	a5,t6,0x4
    25dc:	00f40cb3          	add	s9,s0,a5
    25e0:	026cd603          	lhu	a2,38(s9)
    25e4:	856a                	mv	a0,s10
    25e6:	2eb0c0ef          	jal	f0d0 <printf>
    25ea:	0204ab03          	lw	s6,32(s1)
    25ee:	001d859b          	addiw	a1,s11,1
    25f2:	3c05bc0b          	th.extu	s8,a1,15,0
    25f6:	85e2                	mv	a1,s8
    25f8:	f56c6ae3          	bltu	s8,s6,254c <main+0x7cc>
    25fc:	00000013          	nop
    2600:	0204ad03          	lw	s10,32(s1)
    2604:	0a0d0e63          	beqz	s10,26c0 <main+0x940>
    2608:	62c5                	lui	t0,0x11
    260a:	4901                	li	s2,0
    260c:	4581                	li	a1,0
    260e:	90828a93          	addi	s5,t0,-1784 # 10908 <__errno+0x3bc>
    2612:	00359693          	slli	a3,a1,0x3
    2616:	40b68733          	sub	a4,a3,a1
    261a:	00471313          	slli	t1,a4,0x4
    261e:	006403b3          	add	t2,s0,t1
    2622:	0203d603          	lhu	a2,32(t2)
    2626:	8556                	mv	a0,s5
    2628:	2905                	addiw	s2,s2,1
    262a:	2a70c0ef          	jal	f0d0 <printf>
    262e:	0204a503          	lw	a0,32(s1)
    2632:	3c093a0b          	th.extu	s4,s2,15,0
    2636:	85d2                	mv	a1,s4
    2638:	08aa7463          	bgeu	s4,a0,26c0 <main+0x940>
    263c:	003a1813          	slli	a6,s4,0x3
    2640:	41480633          	sub	a2,a6,s4
    2644:	00461893          	slli	a7,a2,0x4
    2648:	011409b3          	add	s3,s0,a7
    264c:	0209d603          	lhu	a2,32(s3)
    2650:	8556                	mv	a0,s5
    2652:	27f0c0ef          	jal	f0d0 <printf>
    2656:	0204ae83          	lw	t4,32(s1)
    265a:	001a0e1b          	addiw	t3,s4,1
    265e:	3c0e3d8b          	th.extu	s11,t3,15,0
    2662:	85ee                	mv	a1,s11
    2664:	05ddfe63          	bgeu	s11,t4,26c0 <main+0x940>
    2668:	003d9f13          	slli	t5,s11,0x3
    266c:	41bf0fb3          	sub	t6,t5,s11
    2670:	004f9793          	slli	a5,t6,0x4
    2674:	00f40cb3          	add	s9,s0,a5
    2678:	020cd603          	lhu	a2,32(s9)
    267c:	8556                	mv	a0,s5
    267e:	2530c0ef          	jal	f0d0 <printf>
    2682:	0204ab03          	lw	s6,32(s1)
    2686:	001d859b          	addiw	a1,s11,1
    268a:	3c05bc0b          	th.extu	s8,a1,15,0
    268e:	85e2                	mv	a1,s8
    2690:	036c7863          	bgeu	s8,s6,26c0 <main+0x940>
    2694:	003c1d13          	slli	s10,s8,0x3
    2698:	418d02b3          	sub	t0,s10,s8
    269c:	00429693          	slli	a3,t0,0x4
    26a0:	00d40733          	add	a4,s0,a3
    26a4:	02075603          	lhu	a2,32(a4)
    26a8:	8556                	mv	a0,s5
    26aa:	2270c0ef          	jal	f0d0 <printf>
    26ae:	0204a383          	lw	t2,32(s1)
    26b2:	001c031b          	addiw	t1,s8,1
    26b6:	3c03390b          	th.extu	s2,t1,15,0
    26ba:	85ca                	mv	a1,s2
    26bc:	f4796be3          	bltu	s2,t2,2612 <main+0x892>
    26c0:	060b8c63          	beqz	s7,2738 <main+0x9b8>
    26c4:	0b705863          	blez	s7,2774 <main+0x9f4>
    26c8:	6bc5                	lui	s7,0x11
    26ca:	978b8513          	addi	a0,s7,-1672 # 10978 <__errno+0x42c>
    26ce:	1530c0ef          	jal	f020 <puts>
    26d2:	0aa10513          	addi	a0,sp,170
    26d6:	20b010ef          	jal	40e0 <portable_fini>
    26da:	0860d0ef          	jal	f760 <sim_end>
    26de:	7f010113          	addi	sp,sp,2032
    26e2:	60b2                	ld	ra,264(sp)
    26e4:	7daa                	ld	s11,168(sp)
    26e6:	7d4a                	ld	s10,176(sp)
    26e8:	7cea                	ld	s9,184(sp)
    26ea:	6c0e                	ld	s8,192(sp)
    26ec:	6bae                	ld	s7,200(sp)
    26ee:	6b4e                	ld	s6,208(sp)
    26f0:	6aee                	ld	s5,216(sp)
    26f2:	7a0e                	ld	s4,224(sp)
    26f4:	79ae                	ld	s3,232(sp)
    26f6:	794e                	ld	s2,240(sp)
    26f8:	74ee                	ld	s1,248(sp)
    26fa:	6412                	ld	s0,256(sp)
    26fc:	246a                	fld	fs0,152(sp)
    26fe:	4501                	li	a0,0
    2700:	6151                	addi	sp,sp,272
    2702:	8082                	ret
    2704:	4e85                	li	t4,1
    2706:	4f11                	li	t5,4
    2708:	fd143823          	sd	a7,-48(s0)
    270c:	841ff06f          	j	1f4c <main+0x1cc>
    2710:	4785                	li	a5,1
    2712:	fd143823          	sd	a7,-48(s0)
    2716:	f38ff06f          	j	1e4e <main+0xce>
    271a:	0001                	nop
    271c:	66e2                	ld	a3,24(sp)
    271e:	7542                	ld	a0,48(sp)
    2720:	85e6                	mv	a1,s9
    2722:	1af0c0ef          	jal	f0d0 <printf>
    2726:	028bde83          	lhu	t4,40(s7)
    272a:	001e8f1b          	addiw	t5,t4,1
    272e:	3c0f3f8b          	th.extu	t6,t5,15,0
    2732:	03fb9423          	sh	t6,40(s7)
    2736:	bcfd                	j	2234 <main+0x4b4>
    2738:	6ac5                	lui	s5,0x11
    273a:	928a8513          	addi	a0,s5,-1752 # 10928 <__errno+0x3dc>
    273e:	0e30c0ef          	jal	f020 <puts>
    2742:	bf41                	j	26d2 <main+0x952>
    2744:	6541                	lui	a0,0x10
    2746:	7c050513          	addi	a0,a0,1984 # 107c0 <__errno+0x274>
    274a:	0d70c0ef          	jal	f020 <puts>
    274e:	2a05                	addiw	s4,s4,1
    2750:	b6fd                	j	233e <main+0x5be>
    2752:	0204a703          	lw	a4,32(s1)
    2756:	fec42303          	lw	t1,-20(s0)
    275a:	854a                	mv	a0,s2
    275c:	02670c3b          	mulw	s8,a4,t1
    2760:	151010ef          	jal	40b0 <time_in_secs>
    2764:	63c1                	lui	t2,0x10
    2766:	02ac55bb          	divuw	a1,s8,a0
    276a:	7a838513          	addi	a0,t2,1960 # 107a8 <__errno+0x25c>
    276e:	1630c0ef          	jal	f0d0 <printf>
    2772:	b6c1                	j	2332 <main+0x5b2>
    2774:	64c5                	lui	s1,0x11
    2776:	98848513          	addi	a0,s1,-1656 # 10988 <__errno+0x43c>
    277a:	0a70c0ef          	jal	f020 <puts>
    277e:	bf91                	j	26d2 <main+0x952>
    2780:	6ec1                	lui	t4,0x10
    2782:	5d8e8513          	addi	a0,t4,1496 # 105d8 <__errno+0x8c>
    2786:	09b0c0ef          	jal	f020 <puts>
    278a:	6f19                	lui	t5,0x6
    278c:	64b1                	lui	s1,0xc
    278e:	62b5                	lui	t0,0xd
    2790:	e47f0f93          	addi	t6,t5,-441 # 5e47 <ecvtbuf+0xd7>
    2794:	e5248793          	addi	a5,s1,-430 # be52 <_vsnprintf+0x3292>
    2798:	4b028693          	addi	a3,t0,1200 # d4b0 <_vsnprintf+0x48f0>
    279c:	8b7e                	mv	s6,t6
    279e:	ec7e                	sd	t6,24(sp)
    27a0:	8abe                	mv	s5,a5
    27a2:	e83e                	sd	a5,16(sp)
    27a4:	8f36                	mv	t5,a3
    27a6:	e436                	sd	a3,8(sp)
    27a8:	bc91                	j	21fc <main+0x47c>
    27aa:	6ac1                	lui	s5,0x10
    27ac:	698a8513          	addi	a0,s5,1688 # 10698 <__errno+0x14c>
    27b0:	0710c0ef          	jal	f020 <puts>
    27b4:	6ba5                	lui	s7,0x9
    27b6:	6e39                	lui	t3,0xe
    27b8:	d84b8d13          	addi	s10,s7,-636 # 8d84 <_vsnprintf+0x1c4>
    27bc:	74700d93          	li	s11,1863
    27c0:	3c1e0e93          	addi	t4,t3,961 # e3c1 <_vsnprintf+0x5801>
    27c4:	8b6a                	mv	s6,s10
    27c6:	ec6a                	sd	s10,24(sp)
    27c8:	8aee                	mv	s5,s11
    27ca:	e86e                	sd	s11,16(sp)
    27cc:	8f76                	mv	t5,t4
    27ce:	e476                	sd	t4,8(sp)
    27d0:	b435                	j	21fc <main+0x47c>
    27d2:	6a41                	lui	s4,0x10
    27d4:	6a85                	lui	s5,0x1
    27d6:	608a0513          	addi	a0,s4,1544 # 10608 <__errno+0xbc>
    27da:	6c11                	lui	s8,0x4
    27dc:	6d0d                	lui	s10,0x3
    27de:	0430c0ef          	jal	f020 <puts>
    27e2:	9bfc0c93          	addi	s9,s8,-1601 # 39bf <matrix_sum+0x15f>
    27e6:	199a8b93          	addi	s7,s5,409 # 1199 <core_bench_list+0x869>
    27ea:	340d0d93          	addi	s11,s10,832 # 3340 <matrix_test+0xb30>
    27ee:	8b66                	mv	s6,s9
    27f0:	ec66                	sd	s9,24(sp)
    27f2:	8ade                	mv	s5,s7
    27f4:	e85e                	sd	s7,16(sp)
    27f6:	8f6e                	mv	t5,s11
    27f8:	e46e                	sd	s11,8(sp)
    27fa:	b409                	j	21fc <main+0x47c>
    27fc:	4c01                	li	s8,0
    27fe:	bccd                	j	22f0 <main+0x570>
    2800:	004af513          	andi	a0,s5,4
    2804:	de050ee3          	beqz	a0,2600 <main+0x880>
    2808:	bd65                	j	26c0 <main+0x940>
    280a:	0000                	unimp
    280c:	0000                	unimp
	...

0000000000002810 <matrix_test>:
    2810:	7139                	addi	sp,sp,-64
    2812:	e852                	sd	s4,16(sp)
    2814:	fc06                	sd	ra,56(sp)
    2816:	7a7d                	lui	s4,0xfffff
    2818:	01476a33          	or	s4,a4,s4
    281c:	5c0502e3          	beqz	a0,35e0 <matrix_test+0xdd0>
    2820:	882a                	mv	a6,a0
    2822:	ec4e                	sd	s3,24(sp)
    2824:	f04a                	sd	s2,32(sp)
    2826:	f426                	sd	s1,40(sp)
    2828:	f822                	sd	s0,48(sp)
    282a:	e05a                	sd	s6,0(sp)
    282c:	e456                	sd	s5,8(sp)
    282e:	892e                	mv	s2,a1
    2830:	89b6                	mv	s3,a3
    2832:	3c073a8b          	th.extu	s5,a4,15,0
    2836:	86ba                	mv	a3,a4
    2838:	4501                	li	a0,0
    283a:	84b2                	mv	s1,a2
    283c:	85c2                	mv	a1,a6
    283e:	4701                	li	a4,0
    2840:	40a58633          	sub	a2,a1,a0
    2844:	00767293          	andi	t0,a2,7
    2848:	87aa                	mv	a5,a0
    284a:	08028863          	beqz	t0,28da <matrix_test+0xca>
    284e:	4885                	li	a7,1
    2850:	07128c63          	beq	t0,a7,28c8 <matrix_test+0xb8>
    2854:	4309                	li	t1,2
    2856:	06628263          	beq	t0,t1,28ba <matrix_test+0xaa>
    285a:	438d                	li	t2,3
    285c:	04728863          	beq	t0,t2,28ac <matrix_test+0x9c>
    2860:	4411                	li	s0,4
    2862:	02828e63          	beq	t0,s0,289e <matrix_test+0x8e>
    2866:	4b15                	li	s6,5
    2868:	03628463          	beq	t0,s6,2890 <matrix_test+0x80>
    286c:	4e19                	li	t3,6
    286e:	01c28a63          	beq	t0,t3,2882 <matrix_test+0x72>
    2872:	b2a4c78b          	th.lurhu	a5,s1,a0,1
    2876:	01578ebb          	addw	t4,a5,s5
    287a:	32a4de8b          	th.surh	t4,s1,a0,1
    287e:	0015079b          	addiw	a5,a0,1
    2882:	b2f4cf0b          	th.lurhu	t5,s1,a5,1
    2886:	015f0fbb          	addw	t6,t5,s5
    288a:	32f4df8b          	th.surh	t6,s1,a5,1
    288e:	2785                	addiw	a5,a5,1
    2890:	b2f4c60b          	th.lurhu	a2,s1,a5,1
    2894:	015602bb          	addw	t0,a2,s5
    2898:	32f4d28b          	th.surh	t0,s1,a5,1
    289c:	2785                	addiw	a5,a5,1
    289e:	b2f4c88b          	th.lurhu	a7,s1,a5,1
    28a2:	0158833b          	addw	t1,a7,s5
    28a6:	32f4d30b          	th.surh	t1,s1,a5,1
    28aa:	2785                	addiw	a5,a5,1
    28ac:	b2f4c38b          	th.lurhu	t2,s1,a5,1
    28b0:	0153843b          	addw	s0,t2,s5
    28b4:	32f4d40b          	th.surh	s0,s1,a5,1
    28b8:	2785                	addiw	a5,a5,1
    28ba:	b2f4cb0b          	th.lurhu	s6,s1,a5,1
    28be:	015b0e3b          	addw	t3,s6,s5
    28c2:	32f4de0b          	th.surh	t3,s1,a5,1
    28c6:	2785                	addiw	a5,a5,1
    28c8:	b2f4ce8b          	th.lurhu	t4,s1,a5,1
    28cc:	015e8f3b          	addw	t5,t4,s5
    28d0:	32f4df0b          	th.surh	t5,s1,a5,1
    28d4:	2785                	addiw	a5,a5,1
    28d6:	08f58363          	beq	a1,a5,295c <matrix_test+0x14c>
    28da:	b2f4c40b          	th.lurhu	s0,s1,a5,1
    28de:	0017889b          	addiw	a7,a5,1
    28e2:	0018839b          	addiw	t2,a7,1
    28e6:	01540b3b          	addw	s6,s0,s5
    28ea:	32f4db0b          	th.surh	s6,s1,a5,1
    28ee:	b314c30b          	th.lurhu	t1,s1,a7,1
    28f2:	0013879b          	addiw	a5,t2,1
    28f6:	00178f9b          	addiw	t6,a5,1
    28fa:	01530e3b          	addw	t3,t1,s5
    28fe:	3314de0b          	th.surh	t3,s1,a7,1
    2902:	b274cf0b          	th.lurhu	t5,s1,t2,1
    2906:	001f889b          	addiw	a7,t6,1
    290a:	015f063b          	addw	a2,t5,s5
    290e:	3274d60b          	th.surh	a2,s1,t2,1
    2912:	b2f4ce8b          	th.lurhu	t4,s1,a5,1
    2916:	0018839b          	addiw	t2,a7,1
    291a:	015e82bb          	addw	t0,t4,s5
    291e:	32f4d28b          	th.surh	t0,s1,a5,1
    2922:	b3f4c40b          	th.lurhu	s0,s1,t6,1
    2926:	0013879b          	addiw	a5,t2,1
    292a:	01540b3b          	addw	s6,s0,s5
    292e:	33f4db0b          	th.surh	s6,s1,t6,1
    2932:	b314c30b          	th.lurhu	t1,s1,a7,1
    2936:	01530e3b          	addw	t3,t1,s5
    293a:	3314de0b          	th.surh	t3,s1,a7,1
    293e:	b274cf0b          	th.lurhu	t5,s1,t2,1
    2942:	015f063b          	addw	a2,t5,s5
    2946:	3274d60b          	th.surh	a2,s1,t2,1
    294a:	b2f4ce8b          	th.lurhu	t4,s1,a5,1
    294e:	015e8f3b          	addw	t5,t4,s5
    2952:	32f4df0b          	th.surh	t5,s1,a5,1
    2956:	2785                	addiw	a5,a5,1
    2958:	f8f591e3          	bne	a1,a5,28da <matrix_test+0xca>
    295c:	0017041b          	addiw	s0,a4,1
    2960:	8b22                	mv	s6,s0
    2962:	00a8053b          	addw	a0,a6,a0
    2966:	00b805bb          	addw	a1,a6,a1
    296a:	00880463          	beq	a6,s0,2972 <matrix_test+0x162>
    296e:	8722                	mv	a4,s0
    2970:	bdc1                	j	2840 <matrix_test+0x30>
    2972:	85a2                	mv	a1,s0
    2974:	4501                	li	a0,0
    2976:	4801                	li	a6,0
    2978:	40a58fb3          	sub	t6,a1,a0
    297c:	007ff613          	andi	a2,t6,7
    2980:	87aa                	mv	a5,a0
    2982:	c659                	beqz	a2,2a10 <matrix_test+0x200>
    2984:	4285                	li	t0,1
    2986:	06560c63          	beq	a2,t0,29fe <matrix_test+0x1ee>
    298a:	4889                	li	a7,2
    298c:	07160263          	beq	a2,a7,29f0 <matrix_test+0x1e0>
    2990:	430d                	li	t1,3
    2992:	04660863          	beq	a2,t1,29e2 <matrix_test+0x1d2>
    2996:	4391                	li	t2,4
    2998:	02760e63          	beq	a2,t2,29d4 <matrix_test+0x1c4>
    299c:	4e15                	li	t3,5
    299e:	03c60463          	beq	a2,t3,29c6 <matrix_test+0x1b6>
    29a2:	4e99                	li	t4,6
    29a4:	01d60a63          	beq	a2,t4,29b8 <matrix_test+0x1a8>
    29a8:	32a4cf0b          	th.lurh	t5,s1,a0,1
    29ac:	02df07bb          	mulw	a5,t5,a3
    29b0:	54a9578b          	th.surw	a5,s2,a0,2
    29b4:	0015079b          	addiw	a5,a0,1
    29b8:	32f4cf8b          	th.lurh	t6,s1,a5,1
    29bc:	02df863b          	mulw	a2,t6,a3
    29c0:	54f9560b          	th.surw	a2,s2,a5,2
    29c4:	2785                	addiw	a5,a5,1
    29c6:	32f4c28b          	th.lurh	t0,s1,a5,1
    29ca:	02d288bb          	mulw	a7,t0,a3
    29ce:	54f9588b          	th.surw	a7,s2,a5,2
    29d2:	2785                	addiw	a5,a5,1
    29d4:	32f4c30b          	th.lurh	t1,s1,a5,1
    29d8:	02d303bb          	mulw	t2,t1,a3
    29dc:	54f9538b          	th.surw	t2,s2,a5,2
    29e0:	2785                	addiw	a5,a5,1
    29e2:	32f4ce0b          	th.lurh	t3,s1,a5,1
    29e6:	02de0ebb          	mulw	t4,t3,a3
    29ea:	54f95e8b          	th.surw	t4,s2,a5,2
    29ee:	2785                	addiw	a5,a5,1
    29f0:	32f4cf0b          	th.lurh	t5,s1,a5,1
    29f4:	02df0fbb          	mulw	t6,t5,a3
    29f8:	54f95f8b          	th.surw	t6,s2,a5,2
    29fc:	2785                	addiw	a5,a5,1
    29fe:	32f4c60b          	th.lurh	a2,s1,a5,1
    2a02:	02d602bb          	mulw	t0,a2,a3
    2a06:	54f9528b          	th.surw	t0,s2,a5,2
    2a0a:	2785                	addiw	a5,a5,1
    2a0c:	08f58363          	beq	a1,a5,2a92 <matrix_test+0x282>
    2a10:	32f4c88b          	th.lurh	a7,s1,a5,1
    2a14:	00178e1b          	addiw	t3,a5,1
    2a18:	33c4c38b          	th.lurh	t2,s1,t3,1
    2a1c:	02d8833b          	mulw	t1,a7,a3
    2a20:	001e0f1b          	addiw	t5,t3,1
    2a24:	02d3863b          	mulw	a2,t2,a3
    2a28:	001f029b          	addiw	t0,t5,1
    2a2c:	54f9530b          	th.surw	t1,s2,a5,2
    2a30:	33e4c78b          	th.lurh	a5,s1,t5,1
    2a34:	3254cf8b          	th.lurh	t6,s1,t0,1
    2a38:	55c9560b          	th.surw	a2,s2,t3,2
    2a3c:	02d78ebb          	mulw	t4,a5,a3
    2a40:	0012831b          	addiw	t1,t0,1
    2a44:	3264ce0b          	th.lurh	t3,s1,t1,1
    2a48:	02df88bb          	mulw	a7,t6,a3
    2a4c:	55e95e8b          	th.surw	t4,s2,t5,2
    2a50:	00130f1b          	addiw	t5,t1,1
    2a54:	33e4c60b          	th.lurh	a2,s1,t5,1
    2a58:	02de03bb          	mulw	t2,t3,a3
    2a5c:	5459588b          	th.surw	a7,s2,t0,2
    2a60:	02d607bb          	mulw	a5,a2,a3
    2a64:	001f0e9b          	addiw	t4,t5,1
    2a68:	5469538b          	th.surw	t2,s2,t1,2
    2a6c:	33d4c28b          	th.lurh	t0,s1,t4,1
    2a70:	55e9578b          	th.surw	a5,s2,t5,2
    2a74:	001e879b          	addiw	a5,t4,1
    2a78:	32f4c60b          	th.lurh	a2,s1,a5,1
    2a7c:	02d28fbb          	mulw	t6,t0,a3
    2a80:	02d602bb          	mulw	t0,a2,a3
    2a84:	55d95f8b          	th.surw	t6,s2,t4,2
    2a88:	54f9528b          	th.surw	t0,s2,a5,2
    2a8c:	2785                	addiw	a5,a5,1
    2a8e:	f8f591e3          	bne	a1,a5,2a10 <matrix_test+0x200>
    2a92:	0018089b          	addiw	a7,a6,1
    2a96:	9d21                	addw	a0,a0,s0
    2a98:	9da1                	addw	a1,a1,s0
    2a9a:	00e80463          	beq	a6,a4,2aa2 <matrix_test+0x292>
    2a9e:	8846                	mv	a6,a7
    2aa0:	bde1                	j	2978 <matrix_test+0x168>
    2aa2:	8822                	mv	a6,s0
    2aa4:	4881                	li	a7,0
    2aa6:	4e81                	li	t4,0
    2aa8:	4681                	li	a3,0
    2aaa:	4501                	li	a0,0
    2aac:	4301                	li	t1,0
    2aae:	0001                	nop
    2ab0:	411803b3          	sub	t2,a6,a7
    2ab4:	0033fe13          	andi	t3,t2,3
    2ab8:	8646                	mv	a2,a7
    2aba:	060e0563          	beqz	t3,2b24 <matrix_test+0x314>
    2abe:	4f05                	li	t5,1
    2ac0:	05ee0263          	beq	t3,t5,2b04 <matrix_test+0x2f4>
    2ac4:	4f89                	li	t6,2
    2ac6:	03fe0163          	beq	t3,t6,2ae8 <matrix_test+0x2d8>
    2aca:	8676                	mv	a2,t4
    2acc:	55194e8b          	th.lurw	t4,s2,a7,2
    2ad0:	00de86bb          	addw	a3,t4,a3
    2ad4:	12da4763          	blt	s4,a3,2c02 <matrix_test+0x3f2>
    2ad8:	01d622b3          	slt	t0,a2,t4
    2adc:	00a287bb          	addw	a5,t0,a0
    2ae0:	3c07a50b          	th.ext	a0,a5,15,0
    2ae4:	0018861b          	addiw	a2,a7,1
    2ae8:	85f6                	mv	a1,t4
    2aea:	54c94e8b          	th.lurw	t4,s2,a2,2
    2aee:	00de86bb          	addw	a3,t4,a3
    2af2:	10da4263          	blt	s4,a3,2bf6 <matrix_test+0x3e6>
    2af6:	01d5a3b3          	slt	t2,a1,t4
    2afa:	00a3853b          	addw	a0,t2,a0
    2afe:	3c05250b          	th.ext	a0,a0,15,0
    2b02:	2605                	addiw	a2,a2,1
    2b04:	8f76                	mv	t5,t4
    2b06:	54c94e8b          	th.lurw	t4,s2,a2,2
    2b0a:	00de86bb          	addw	a3,t4,a3
    2b0e:	0cda4e63          	blt	s4,a3,2bea <matrix_test+0x3da>
    2b12:	01df2fb3          	slt	t6,t5,t4
    2b16:	00af82bb          	addw	t0,t6,a0
    2b1a:	3c02a50b          	th.ext	a0,t0,15,0
    2b1e:	2605                	addiw	a2,a2,1
    2b20:	06c80963          	beq	a6,a2,2b92 <matrix_test+0x382>
    2b24:	54c9428b          	th.lurw	t0,s2,a2,2
    2b28:	00d28fbb          	addw	t6,t0,a3
    2b2c:	0bfa5863          	bge	s4,t6,2bdc <matrix_test+0x3cc>
    2b30:	00a50e1b          	addiw	t3,a0,10
    2b34:	3c0e2e8b          	th.ext	t4,t3,15,0
    2b38:	4f81                	li	t6,0
    2b3a:	0016039b          	addiw	t2,a2,1
    2b3e:	54794f0b          	th.lurw	t5,s2,t2,2
    2b42:	01ff0fbb          	addw	t6,t5,t6
    2b46:	07fa5763          	bge	s4,t6,2bb4 <matrix_test+0x3a4>
    2b4a:	00ae869b          	addiw	a3,t4,10
    2b4e:	00138e9b          	addiw	t4,t2,1
    2b52:	55d94e0b          	th.lurw	t3,s2,t4,2
    2b56:	4f81                	li	t6,0
    2b58:	3c06a28b          	th.ext	t0,a3,15,0
    2b5c:	01fe06bb          	addw	a3,t3,t6
    2b60:	06da4863          	blt	s4,a3,2bd0 <matrix_test+0x3c0>
    2b64:	01cf23b3          	slt	t2,t5,t3
    2b68:	0053863b          	addw	a2,t2,t0
    2b6c:	3c06278b          	th.ext	a5,a2,15,0
    2b70:	001e861b          	addiw	a2,t4,1
    2b74:	54c94e8b          	th.lurw	t4,s2,a2,2
    2b78:	00de86bb          	addw	a3,t4,a3
    2b7c:	02da4663          	blt	s4,a3,2ba8 <matrix_test+0x398>
    2b80:	01de22b3          	slt	t0,t3,t4
    2b84:	00f28fbb          	addw	t6,t0,a5
    2b88:	2605                	addiw	a2,a2,1
    2b8a:	3c0fa50b          	th.ext	a0,t6,15,0
    2b8e:	f8c81be3          	bne	a6,a2,2b24 <matrix_test+0x314>
    2b92:	0013059b          	addiw	a1,t1,1
    2b96:	0104083b          	addw	a6,s0,a6
    2b9a:	011408bb          	addw	a7,s0,a7
    2b9e:	06e30863          	beq	t1,a4,2c0e <matrix_test+0x3fe>
    2ba2:	832e                	mv	t1,a1
    2ba4:	b731                	j	2ab0 <matrix_test+0x2a0>
    2ba6:	0001                	nop
    2ba8:	00a7859b          	addiw	a1,a5,10
    2bac:	3c05a50b          	th.ext	a0,a1,15,0
    2bb0:	4681                	li	a3,0
    2bb2:	b7b5                	j	2b1e <matrix_test+0x30e>
    2bb4:	01e2a7b3          	slt	a5,t0,t5
    2bb8:	01d7853b          	addw	a0,a5,t4
    2bbc:	00138e9b          	addiw	t4,t2,1
    2bc0:	55d94e0b          	th.lurw	t3,s2,t4,2
    2bc4:	3c05228b          	th.ext	t0,a0,15,0
    2bc8:	01fe06bb          	addw	a3,t3,t6
    2bcc:	f8da5ce3          	bge	s4,a3,2b64 <matrix_test+0x354>
    2bd0:	00a28f1b          	addiw	t5,t0,10
    2bd4:	3c0f278b          	th.ext	a5,t5,15,0
    2bd8:	4681                	li	a3,0
    2bda:	bf59                	j	2b70 <matrix_test+0x360>
    2bdc:	005ea5b3          	slt	a1,t4,t0
    2be0:	00a58f3b          	addw	t5,a1,a0
    2be4:	3c0f2e8b          	th.ext	t4,t5,15,0
    2be8:	bf89                	j	2b3a <matrix_test+0x32a>
    2bea:	00a5079b          	addiw	a5,a0,10
    2bee:	3c07a50b          	th.ext	a0,a5,15,0
    2bf2:	4681                	li	a3,0
    2bf4:	b72d                	j	2b1e <matrix_test+0x30e>
    2bf6:	00a50e1b          	addiw	t3,a0,10
    2bfa:	3c0e250b          	th.ext	a0,t3,15,0
    2bfe:	4681                	li	a3,0
    2c00:	b709                	j	2b02 <matrix_test+0x2f2>
    2c02:	00a5069b          	addiw	a3,a0,10
    2c06:	3c06a50b          	th.ext	a0,a3,15,0
    2c0a:	4681                	li	a3,0
    2c0c:	bde1                	j	2ae4 <matrix_test+0x2d4>
    2c0e:	4581                	li	a1,0
    2c10:	061020ef          	jal	5470 <crc16>
    2c14:	85aa                	mv	a1,a0
    2c16:	7c0b3b0b          	th.extu	s6,s6,31,0
    2c1a:	4601                	li	a2,0
    2c1c:	4501                	li	a0,0
    2c1e:	0001                	nop
    2c20:	007b7313          	andi	t1,s6,7
    2c24:	4701                	li	a4,0
    2c26:	4681                	li	a3,0
    2c28:	0a030763          	beqz	t1,2cd6 <matrix_test+0x4c6>
    2c2c:	4e85                	li	t4,1
    2c2e:	09d30663          	beq	t1,t4,2cba <matrix_test+0x4aa>
    2c32:	4389                	li	t2,2
    2c34:	06730a63          	beq	t1,t2,2ca8 <matrix_test+0x498>
    2c38:	4e0d                	li	t3,3
    2c3a:	05c30e63          	beq	t1,t3,2c96 <matrix_test+0x486>
    2c3e:	4f11                	li	t5,4
    2c40:	05e30263          	beq	t1,t5,2c84 <matrix_test+0x474>
    2c44:	4f95                	li	t6,5
    2c46:	03f30663          	beq	t1,t6,2c72 <matrix_test+0x462>
    2c4a:	4299                	li	t0,6
    2c4c:	00530a63          	beq	t1,t0,2c60 <matrix_test+0x450>
    2c50:	b2c4c80b          	th.lurhu	a6,s1,a2,1
    2c54:	0009d783          	lhu	a5,0(s3)
    2c58:	86ba                	mv	a3,a4
    2c5a:	8776                	mv	a4,t4
    2c5c:	28f8168b          	th.mulah	a3,a6,a5
    2c60:	00c708bb          	addw	a7,a4,a2
    2c64:	a2e9ce8b          	th.lrhu	t4,s3,a4,1
    2c68:	b314c30b          	th.lurhu	t1,s1,a7,1
    2c6c:	0705                	addi	a4,a4,1
    2c6e:	29d3168b          	th.mulah	a3,t1,t4
    2c72:	00c703bb          	addw	t2,a4,a2
    2c76:	a2e9cf0b          	th.lrhu	t5,s3,a4,1
    2c7a:	b274ce0b          	th.lurhu	t3,s1,t2,1
    2c7e:	0705                	addi	a4,a4,1
    2c80:	29ee168b          	th.mulah	a3,t3,t5
    2c84:	00c70fbb          	addw	t6,a4,a2
    2c88:	a2e9c80b          	th.lrhu	a6,s3,a4,1
    2c8c:	b3f4c28b          	th.lurhu	t0,s1,t6,1
    2c90:	0705                	addi	a4,a4,1
    2c92:	2902968b          	th.mulah	a3,t0,a6
    2c96:	00c707bb          	addw	a5,a4,a2
    2c9a:	a2e9c30b          	th.lrhu	t1,s3,a4,1
    2c9e:	b2f4c88b          	th.lurhu	a7,s1,a5,1
    2ca2:	0705                	addi	a4,a4,1
    2ca4:	2868968b          	th.mulah	a3,a7,t1
    2ca8:	00c70ebb          	addw	t4,a4,a2
    2cac:	a2e9ce0b          	th.lrhu	t3,s3,a4,1
    2cb0:	b3d4c38b          	th.lurhu	t2,s1,t4,1
    2cb4:	0705                	addi	a4,a4,1
    2cb6:	29c3968b          	th.mulah	a3,t2,t3
    2cba:	00c70f3b          	addw	t5,a4,a2
    2cbe:	a2e9c28b          	th.lrhu	t0,s3,a4,1
    2cc2:	b3e4cf8b          	th.lurhu	t6,s1,t5,1
    2cc6:	87b6                	mv	a5,a3
    2cc8:	883a                	mv	a6,a4
    2cca:	285f978b          	th.mulah	a5,t6,t0
    2cce:	0705                	addi	a4,a4,1
    2cd0:	86be                	mv	a3,a5
    2cd2:	0aeb0563          	beq	s6,a4,2d7c <matrix_test+0x56c>
    2cd6:	00c708bb          	addw	a7,a4,a2
    2cda:	b314c30b          	th.lurhu	t1,s1,a7,1
    2cde:	a2e9ce8b          	th.lrhu	t4,s3,a4,1
    2ce2:	00170393          	addi	t2,a4,1
    2ce6:	87b6                	mv	a5,a3
    2ce8:	29d3178b          	th.mulah	a5,t1,t4
    2cec:	00c38e3b          	addw	t3,t2,a2
    2cf0:	b3c4cf0b          	th.lurhu	t5,s1,t3,1
    2cf4:	a279cf8b          	th.lrhu	t6,s3,t2,1
    2cf8:	00270293          	addi	t0,a4,2
    2cfc:	00c286bb          	addw	a3,t0,a2
    2d00:	29ff178b          	th.mulah	a5,t5,t6
    2d04:	b2d4c80b          	th.lurhu	a6,s1,a3,1
    2d08:	a259c88b          	th.lrhu	a7,s3,t0,1
    2d0c:	00370313          	addi	t1,a4,3
    2d10:	00c30ebb          	addw	t4,t1,a2
    2d14:	2918178b          	th.mulah	a5,a6,a7
    2d18:	b3d4c38b          	th.lurhu	t2,s1,t4,1
    2d1c:	a269ce0b          	th.lrhu	t3,s3,t1,1
    2d20:	00470f13          	addi	t5,a4,4
    2d24:	00cf0fbb          	addw	t6,t5,a2
    2d28:	29c3978b          	th.mulah	a5,t2,t3
    2d2c:	b3f4c28b          	th.lurhu	t0,s1,t6,1
    2d30:	a3e9c68b          	th.lrhu	a3,s3,t5,1
    2d34:	00570893          	addi	a7,a4,5
    2d38:	00c8883b          	addw	a6,a7,a2
    2d3c:	28d2978b          	th.mulah	a5,t0,a3
    2d40:	b304c30b          	th.lurhu	t1,s1,a6,1
    2d44:	a319ce8b          	th.lrhu	t4,s3,a7,1
    2d48:	00670393          	addi	t2,a4,6
    2d4c:	00c38e3b          	addw	t3,t2,a2
    2d50:	29d3178b          	th.mulah	a5,t1,t4
    2d54:	b3c4cf0b          	th.lurhu	t5,s1,t3,1
    2d58:	a279cf8b          	th.lrhu	t6,s3,t2,1
    2d5c:	00770813          	addi	a6,a4,7
    2d60:	00c802bb          	addw	t0,a6,a2
    2d64:	29ff178b          	th.mulah	a5,t5,t6
    2d68:	a309c68b          	th.lrhu	a3,s3,a6,1
    2d6c:	b254c88b          	th.lurhu	a7,s1,t0,1
    2d70:	0721                	addi	a4,a4,8
    2d72:	28d8978b          	th.mulah	a5,a7,a3
    2d76:	86be                	mv	a3,a5
    2d78:	f4eb1fe3          	bne	s6,a4,2cd6 <matrix_test+0x4c6>
    2d7c:	44a9578b          	th.srw	a5,s2,a0,2
    2d80:	9e21                	addw	a2,a2,s0
    2d82:	00150793          	addi	a5,a0,1
    2d86:	01050463          	beq	a0,a6,2d8e <matrix_test+0x57e>
    2d8a:	853e                	mv	a0,a5
    2d8c:	bd51                	j	2c20 <matrix_test+0x410>
    2d8e:	4601                	li	a2,0
    2d90:	4881                	li	a7,0
    2d92:	4701                	li	a4,0
    2d94:	4501                	li	a0,0
    2d96:	4801                	li	a6,0
    2d98:	8346                	mv	t1,a7
    2d9a:	54c9488b          	th.lurw	a7,s2,a2,2
    2d9e:	fff40b13          	addi	s6,s0,-1
    2da2:	003b7e93          	andi	t4,s6,3
    2da6:	00e8873b          	addw	a4,a7,a4
    2daa:	7aea5063          	bge	s4,a4,354a <matrix_test+0xd3a>
    2dae:	00a5071b          	addiw	a4,a0,10
    2db2:	3c07250b          	th.ext	a0,a4,15,0
    2db6:	4701                	li	a4,0
    2db8:	4685                	li	a3,1
    2dba:	0e86f963          	bgeu	a3,s0,2eac <matrix_test+0x69c>
    2dbe:	060e8963          	beqz	t4,2e30 <matrix_test+0x620>
    2dc2:	04de8563          	beq	t4,a3,2e0c <matrix_test+0x5fc>
    2dc6:	4e09                	li	t3,2
    2dc8:	03ce8263          	beq	t4,t3,2dec <matrix_test+0x5dc>
    2dcc:	00160f9b          	addiw	t6,a2,1
    2dd0:	8f46                	mv	t5,a7
    2dd2:	55f9488b          	th.lurw	a7,s2,t6,2
    2dd6:	00e8873b          	addw	a4,a7,a4
    2dda:	7eea4c63          	blt	s4,a4,35d2 <matrix_test+0xdc2>
    2dde:	011f22b3          	slt	t0,t5,a7
    2de2:	00a287bb          	addw	a5,t0,a0
    2de6:	3c07a50b          	th.ext	a0,a5,15,0
    2dea:	2685                	addiw	a3,a3,1
    2dec:	8ec6                	mv	t4,a7
    2dee:	00c688bb          	addw	a7,a3,a2
    2df2:	5519488b          	th.lurw	a7,s2,a7,2
    2df6:	00e8873b          	addw	a4,a7,a4
    2dfa:	7aea4563          	blt	s4,a4,35a4 <matrix_test+0xd94>
    2dfe:	011ea333          	slt	t1,t4,a7
    2e02:	00a303bb          	addw	t2,t1,a0
    2e06:	3c03a50b          	th.ext	a0,t2,15,0
    2e0a:	2685                	addiw	a3,a3,1
    2e0c:	00c68f3b          	addw	t5,a3,a2
    2e10:	8e46                	mv	t3,a7
    2e12:	55e9488b          	th.lurw	a7,s2,t5,2
    2e16:	00e8873b          	addw	a4,a7,a4
    2e1a:	76ea4363          	blt	s4,a4,3580 <matrix_test+0xd70>
    2e1e:	011e2fb3          	slt	t6,t3,a7
    2e22:	00af82bb          	addw	t0,t6,a0
    2e26:	3c02a50b          	th.ext	a0,t0,15,0
    2e2a:	2685                	addiw	a3,a3,1
    2e2c:	0886f063          	bgeu	a3,s0,2eac <matrix_test+0x69c>
    2e30:	00c68b3b          	addw	s6,a3,a2
    2e34:	55694f8b          	th.lurw	t6,s2,s6,2
    2e38:	00ef82bb          	addw	t0,t6,a4
    2e3c:	705a5063          	bge	s4,t0,353c <matrix_test+0xd2c>
    2e40:	00a50e1b          	addiw	t3,a0,10
    2e44:	3c0e2e8b          	th.ext	t4,t3,15,0
    2e48:	4281                	li	t0,0
    2e4a:	2685                	addiw	a3,a3,1
    2e4c:	00c6833b          	addw	t1,a3,a2
    2e50:	5469488b          	th.lurw	a7,s2,t1,2
    2e54:	005882bb          	addw	t0,a7,t0
    2e58:	6c5a5a63          	bge	s4,t0,352c <matrix_test+0xd1c>
    2e5c:	00ae871b          	addiw	a4,t4,10
    2e60:	3c072b0b          	th.ext	s6,a4,15,0
    2e64:	4281                	li	t0,0
    2e66:	00168f9b          	addiw	t6,a3,1
    2e6a:	00cf8f3b          	addw	t5,t6,a2
    2e6e:	55e9450b          	th.lurw	a0,s2,t5,2
    2e72:	005507bb          	addw	a5,a0,t0
    2e76:	6afa4563          	blt	s4,a5,3520 <matrix_test+0xd10>
    2e7a:	00a8aeb3          	slt	t4,a7,a0
    2e7e:	016e8e3b          	addw	t3,t4,s6
    2e82:	3c0e230b          	th.ext	t1,t3,15,0
    2e86:	001f869b          	addiw	a3,t6,1
    2e8a:	00c688bb          	addw	a7,a3,a2
    2e8e:	5519488b          	th.lurw	a7,s2,a7,2
    2e92:	00f8873b          	addw	a4,a7,a5
    2e96:	66ea4f63          	blt	s4,a4,3514 <matrix_test+0xd04>
    2e9a:	011523b3          	slt	t2,a0,a7
    2e9e:	00638b3b          	addw	s6,t2,t1
    2ea2:	2685                	addiw	a3,a3,1
    2ea4:	3c0b250b          	th.ext	a0,s6,15,0
    2ea8:	f886e4e3          	bltu	a3,s0,2e30 <matrix_test+0x620>
    2eac:	2805                	addiw	a6,a6,1
    2eae:	9e21                	addw	a2,a2,s0
    2eb0:	ee8864e3          	bltu	a6,s0,2d98 <matrix_test+0x588>
    2eb4:	5bc020ef          	jal	5470 <crc16>
    2eb8:	85aa                	mv	a1,a0
    2eba:	4601                	li	a2,0
    2ebc:	4881                	li	a7,0
    2ebe:	0001                	nop
    2ec0:	4b01                	li	s6,0
    2ec2:	0001                	nop
    2ec4:	00000013          	nop
    2ec8:	b369c30b          	th.lurhu	t1,s3,s6,1
    2ecc:	b2c4ce8b          	th.lurhu	t4,s1,a2,1
    2ed0:	4f81                	li	t6,0
    2ed2:	fff40793          	addi	a5,s0,-1
    2ed6:	286e9f8b          	th.mulah	t6,t4,t1
    2eda:	4705                	li	a4,1
    2edc:	00cb083b          	addw	a6,s6,a2
    2ee0:	0037f393          	andi	t2,a5,3
    2ee4:	837e                	mv	t1,t6
    2ee6:	016406bb          	addw	a3,s0,s6
    2eea:	0a877f63          	bgeu	a4,s0,2fa8 <matrix_test+0x798>
    2eee:	04038963          	beqz	t2,2f40 <matrix_test+0x730>
    2ef2:	02e38963          	beq	t2,a4,2f24 <matrix_test+0x714>
    2ef6:	4f09                	li	t5,2
    2ef8:	01e38c63          	beq	t2,t5,2f10 <matrix_test+0x700>
    2efc:	00160e1b          	addiw	t3,a2,1
    2f00:	b2d9c28b          	th.lurhu	t0,s3,a3,1
    2f04:	b3c4cf8b          	th.lurhu	t6,s1,t3,1
    2f08:	877a                	mv	a4,t5
    2f0a:	9ea1                	addw	a3,a3,s0
    2f0c:	285f930b          	th.mulah	t1,t6,t0
    2f10:	00c707bb          	addw	a5,a4,a2
    2f14:	b2d9ce8b          	th.lurhu	t4,s3,a3,1
    2f18:	b2f4c38b          	th.lurhu	t2,s1,a5,1
    2f1c:	2705                	addiw	a4,a4,1
    2f1e:	9ea1                	addw	a3,a3,s0
    2f20:	29d3930b          	th.mulah	t1,t2,t4
    2f24:	00c7053b          	addw	a0,a4,a2
    2f28:	b2d9ce0b          	th.lurhu	t3,s3,a3,1
    2f2c:	b2a4cf0b          	th.lurhu	t5,s1,a0,1
    2f30:	8f9a                	mv	t6,t1
    2f32:	2705                	addiw	a4,a4,1
    2f34:	29cf1f8b          	th.mulah	t6,t5,t3
    2f38:	9ea1                	addw	a3,a3,s0
    2f3a:	837e                	mv	t1,t6
    2f3c:	06877663          	bgeu	a4,s0,2fa8 <matrix_test+0x798>
    2f40:	00c702bb          	addw	t0,a4,a2
    2f44:	b254c78b          	th.lurhu	a5,s1,t0,1
    2f48:	b2d9c38b          	th.lurhu	t2,s3,a3,1
    2f4c:	00170e9b          	addiw	t4,a4,1
    2f50:	8f9a                	mv	t6,t1
    2f52:	28779f8b          	th.mulah	t6,a5,t2
    2f56:	00d4053b          	addw	a0,s0,a3
    2f5a:	00ce8f3b          	addw	t5,t4,a2
    2f5e:	b3e4ce0b          	th.lurhu	t3,s1,t5,1
    2f62:	b2a9c30b          	th.lurhu	t1,s3,a0,1
    2f66:	001e871b          	addiw	a4,t4,1
    2f6a:	008506bb          	addw	a3,a0,s0
    2f6e:	286e1f8b          	th.mulah	t6,t3,t1
    2f72:	00c702bb          	addw	t0,a4,a2
    2f76:	b2d9c38b          	th.lurhu	t2,s3,a3,1
    2f7a:	b254c78b          	th.lurhu	a5,s1,t0,1
    2f7e:	00170e9b          	addiw	t4,a4,1
    2f82:	0086853b          	addw	a0,a3,s0
    2f86:	28779f8b          	th.mulah	t6,a5,t2
    2f8a:	00ce8f3b          	addw	t5,t4,a2
    2f8e:	b2a9c30b          	th.lurhu	t1,s3,a0,1
    2f92:	b3e4ce0b          	th.lurhu	t3,s1,t5,1
    2f96:	001e871b          	addiw	a4,t4,1
    2f9a:	008506bb          	addw	a3,a0,s0
    2f9e:	286e1f8b          	th.mulah	t6,t3,t1
    2fa2:	837e                	mv	t1,t6
    2fa4:	f8876ee3          	bltu	a4,s0,2f40 <matrix_test+0x730>
    2fa8:	55095f8b          	th.surw	t6,s2,a6,2
    2fac:	2b05                	addiw	s6,s6,1
    2fae:	f08b6de3          	bltu	s6,s0,2ec8 <matrix_test+0x6b8>
    2fb2:	2885                	addiw	a7,a7,1
    2fb4:	9e21                	addw	a2,a2,s0
    2fb6:	f088e5e3          	bltu	a7,s0,2ec0 <matrix_test+0x6b0>
    2fba:	4b01                	li	s6,0
    2fbc:	4881                	li	a7,0
    2fbe:	4601                	li	a2,0
    2fc0:	4501                	li	a0,0
    2fc2:	4f81                	li	t6,0
    2fc4:	00000013          	nop
    2fc8:	86c6                	mv	a3,a7
    2fca:	5569488b          	th.lurw	a7,s2,s6,2
    2fce:	fff40813          	addi	a6,s0,-1
    2fd2:	00387293          	andi	t0,a6,3
    2fd6:	00c8863b          	addw	a2,a7,a2
    2fda:	58ca5663          	bge	s4,a2,3566 <matrix_test+0xd56>
    2fde:	00a5071b          	addiw	a4,a0,10
    2fe2:	3c07250b          	th.ext	a0,a4,15,0
    2fe6:	4601                	li	a2,0
    2fe8:	4685                	li	a3,1
    2fea:	0e86fa63          	bgeu	a3,s0,30de <matrix_test+0x8ce>
    2fee:	06028963          	beqz	t0,3060 <matrix_test+0x850>
    2ff2:	04d28563          	beq	t0,a3,303c <matrix_test+0x82c>
    2ff6:	4e89                	li	t4,2
    2ff8:	03d28263          	beq	t0,t4,301c <matrix_test+0x80c>
    2ffc:	001b0e1b          	addiw	t3,s6,1
    3000:	8f46                	mv	t5,a7
    3002:	55c9488b          	th.lurw	a7,s2,t3,2
    3006:	00c8863b          	addw	a2,a7,a2
    300a:	5aca4863          	blt	s4,a2,35ba <matrix_test+0xdaa>
    300e:	011f2333          	slt	t1,t5,a7
    3012:	00a3053b          	addw	a0,t1,a0
    3016:	3c05250b          	th.ext	a0,a0,15,0
    301a:	2685                	addiw	a3,a3,1
    301c:	8846                	mv	a6,a7
    301e:	016688bb          	addw	a7,a3,s6
    3022:	5519488b          	th.lurw	a7,s2,a7,2
    3026:	00c8863b          	addw	a2,a7,a2
    302a:	58ca4263          	blt	s4,a2,35ae <matrix_test+0xd9e>
    302e:	011822b3          	slt	t0,a6,a7
    3032:	00a287bb          	addw	a5,t0,a0
    3036:	3c07a50b          	th.ext	a0,a5,15,0
    303a:	2685                	addiw	a3,a3,1
    303c:	01668f3b          	addw	t5,a3,s6
    3040:	8ec6                	mv	t4,a7
    3042:	55e9488b          	th.lurw	a7,s2,t5,2
    3046:	00c8863b          	addw	a2,a7,a2
    304a:	52ca4563          	blt	s4,a2,3574 <matrix_test+0xd64>
    304e:	011eae33          	slt	t3,t4,a7
    3052:	00ae033b          	addw	t1,t3,a0
    3056:	3c03250b          	th.ext	a0,t1,15,0
    305a:	2685                	addiw	a3,a3,1
    305c:	0886f163          	bgeu	a3,s0,30de <matrix_test+0x8ce>
    3060:	016687bb          	addw	a5,a3,s6
    3064:	54f9428b          	th.lurw	t0,s2,a5,2
    3068:	00c283bb          	addw	t2,t0,a2
    306c:	487a5c63          	bge	s4,t2,3504 <matrix_test+0xcf4>
    3070:	00a50e9b          	addiw	t4,a0,10
    3074:	3c0eaf0b          	th.ext	t5,t4,15,0
    3078:	4381                	li	t2,0
    307a:	0016881b          	addiw	a6,a3,1
    307e:	01680e3b          	addw	t3,a6,s6
    3082:	55c9460b          	th.lurw	a2,s2,t3,2
    3086:	007603bb          	addw	t2,a2,t2
    308a:	467a5563          	bge	s4,t2,34f4 <matrix_test+0xce4>
    308e:	00af071b          	addiw	a4,t5,10
    3092:	3c07278b          	th.ext	a5,a4,15,0
    3096:	4381                	li	t2,0
    3098:	0018029b          	addiw	t0,a6,1
    309c:	016288bb          	addw	a7,t0,s6
    30a0:	5519450b          	th.lurw	a0,s2,a7,2
    30a4:	0075033b          	addw	t1,a0,t2
    30a8:	446a4063          	blt	s4,t1,34e8 <matrix_test+0xcd8>
    30ac:	00a62f33          	slt	t5,a2,a0
    30b0:	00ff0ebb          	addw	t4,t5,a5
    30b4:	3c0eae0b          	th.ext	t3,t4,15,0
    30b8:	0012869b          	addiw	a3,t0,1
    30bc:	0166863b          	addw	a2,a3,s6
    30c0:	54c9488b          	th.lurw	a7,s2,a2,2
    30c4:	0068863b          	addw	a2,a7,t1
    30c8:	40ca4a63          	blt	s4,a2,34dc <matrix_test+0xccc>
    30cc:	011527b3          	slt	a5,a0,a7
    30d0:	01c783bb          	addw	t2,a5,t3
    30d4:	2685                	addiw	a3,a3,1
    30d6:	3c03a50b          	th.ext	a0,t2,15,0
    30da:	f886e3e3          	bltu	a3,s0,3060 <matrix_test+0x850>
    30de:	2f85                	addiw	t6,t6,1
    30e0:	01640b3b          	addw	s6,s0,s6
    30e4:	ee8fe2e3          	bltu	t6,s0,2fc8 <matrix_test+0x7b8>
    30e8:	388020ef          	jal	5470 <crc16>
    30ec:	85aa                	mv	a1,a0
    30ee:	4301                	li	t1,0
    30f0:	4501                	li	a0,0
    30f2:	0001                	nop
    30f4:	00000013          	nop
    30f8:	4b01                	li	s6,0
    30fa:	0001                	nop
    30fc:	00000013          	nop
    3100:	32a4c80b          	th.lurh	a6,s1,a0,1
    3104:	3369c28b          	th.lurh	t0,s3,s6,1
    3108:	fff40f93          	addi	t6,s0,-1
    310c:	00ab08bb          	addw	a7,s6,a0
    3110:	025807bb          	mulw	a5,a6,t0
    3114:	003ff613          	andi	a2,t6,3
    3118:	016406bb          	addw	a3,s0,s6
    311c:	1427b38b          	th.extu	t2,a5,5,2
    3120:	2c57be8b          	th.extu	t4,a5,11,5
    3124:	03d3873b          	mulw	a4,t2,t4
    3128:	4785                	li	a5,1
    312a:	8e3a                	mv	t3,a4
    312c:	1087f763          	bgeu	a5,s0,323a <matrix_test+0xa2a>
    3130:	ca35                	beqz	a2,31a4 <matrix_test+0x994>
    3132:	04f60563          	beq	a2,a5,317c <matrix_test+0x96c>
    3136:	4709                	li	a4,2
    3138:	02e60263          	beq	a2,a4,315c <matrix_test+0x94c>
    313c:	00150f9b          	addiw	t6,a0,1
    3140:	32d9c60b          	th.lurh	a2,s3,a3,1
    3144:	33f4c80b          	th.lurh	a6,s1,t6,1
    3148:	9ea1                	addw	a3,a3,s0
    314a:	02c802bb          	mulw	t0,a6,a2
    314e:	2c52b78b          	th.extu	a5,t0,11,5
    3152:	1422b38b          	th.extu	t2,t0,5,2
    3156:	24f39e0b          	th.mulaw	t3,t2,a5
    315a:	87ba                	mv	a5,a4
    315c:	00a78ebb          	addw	t4,a5,a0
    3160:	32d9c70b          	th.lurh	a4,s3,a3,1
    3164:	33d4cf0b          	th.lurh	t5,s1,t4,1
    3168:	2785                	addiw	a5,a5,1
    316a:	9ea1                	addw	a3,a3,s0
    316c:	02ef0fbb          	mulw	t6,t5,a4
    3170:	142fb80b          	th.extu	a6,t6,5,2
    3174:	2c5fb60b          	th.extu	a2,t6,11,5
    3178:	24c81e0b          	th.mulaw	t3,a6,a2
    317c:	00a782bb          	addw	t0,a5,a0
    3180:	32d9ce8b          	th.lurh	t4,s3,a3,1
    3184:	3254c38b          	th.lurh	t2,s1,t0,1
    3188:	8772                	mv	a4,t3
    318a:	2785                	addiw	a5,a5,1
    318c:	03d38f3b          	mulw	t5,t2,t4
    3190:	9ea1                	addw	a3,a3,s0
    3192:	142f3f8b          	th.extu	t6,t5,5,2
    3196:	2c5f380b          	th.extu	a6,t5,11,5
    319a:	250f970b          	th.mulaw	a4,t6,a6
    319e:	8e3a                	mv	t3,a4
    31a0:	0887fd63          	bgeu	a5,s0,323a <matrix_test+0xa2a>
    31a4:	00a7863b          	addw	a2,a5,a0
    31a8:	32c4c28b          	th.lurh	t0,s1,a2,1
    31ac:	32d9c38b          	th.lurh	t2,s3,a3,1
    31b0:	0017881b          	addiw	a6,a5,1
    31b4:	9ea1                	addw	a3,a3,s0
    31b6:	02728f3b          	mulw	t5,t0,t2
    31ba:	8772                	mv	a4,t3
    31bc:	00a80e3b          	addw	t3,a6,a0
    31c0:	33c4c78b          	th.lurh	a5,s1,t3,1
    31c4:	32d9c60b          	th.lurh	a2,s3,a3,1
    31c8:	142f3e8b          	th.extu	t4,t5,5,2
    31cc:	2c5f3f8b          	th.extu	t6,t5,11,5
    31d0:	02c782bb          	mulw	t0,a5,a2
    31d4:	25fe970b          	th.mulaw	a4,t4,t6
    31d8:	00180e9b          	addiw	t4,a6,1
    31dc:	00868fbb          	addw	t6,a3,s0
    31e0:	00ae883b          	addw	a6,t4,a0
    31e4:	3304c68b          	th.lurh	a3,s1,a6,1
    31e8:	33f9ce0b          	th.lurh	t3,s3,t6,1
    31ec:	1422b38b          	th.extu	t2,t0,5,2
    31f0:	2c52bf0b          	th.extu	t5,t0,11,5
    31f4:	25e3970b          	th.mulaw	a4,t2,t5
    31f8:	001e839b          	addiw	t2,t4,1
    31fc:	03c687bb          	mulw	a5,a3,t3
    3200:	008f8f3b          	addw	t5,t6,s0
    3204:	00a38ebb          	addw	t4,t2,a0
    3208:	33d4cf8b          	th.lurh	t6,s1,t4,1
    320c:	33e9c80b          	th.lurh	a6,s3,t5,1
    3210:	1427b28b          	th.extu	t0,a5,5,2
    3214:	2c57b60b          	th.extu	a2,a5,11,5
    3218:	030f86bb          	mulw	a3,t6,a6
    321c:	24c2970b          	th.mulaw	a4,t0,a2
    3220:	1426be0b          	th.extu	t3,a3,5,2
    3224:	2c56b78b          	th.extu	a5,a3,11,5
    3228:	24fe170b          	th.mulaw	a4,t3,a5
    322c:	0013879b          	addiw	a5,t2,1
    3230:	008f06bb          	addw	a3,t5,s0
    3234:	8e3a                	mv	t3,a4
    3236:	f687e7e3          	bltu	a5,s0,31a4 <matrix_test+0x994>
    323a:	5519570b          	th.surw	a4,s2,a7,2
    323e:	2b05                	addiw	s6,s6,1
    3240:	ec8b60e3          	bltu	s6,s0,3100 <matrix_test+0x8f0>
    3244:	2305                	addiw	t1,t1,1
    3246:	9d21                	addw	a0,a0,s0
    3248:	ea8368e3          	bltu	t1,s0,30f8 <matrix_test+0x8e8>
    324c:	4b01                	li	s6,0
    324e:	4301                	li	t1,0
    3250:	4681                	li	a3,0
    3252:	4501                	li	a0,0
    3254:	4881                	li	a7,0
    3256:	0001                	nop
    3258:	829a                	mv	t0,t1
    325a:	5569430b          	th.lurw	t1,s2,s6,2
    325e:	fff40713          	addi	a4,s0,-1
    3262:	00377993          	andi	s3,a4,3
    3266:	00d306bb          	addw	a3,t1,a3
    326a:	2eda5763          	bge	s4,a3,3558 <matrix_test+0xd48>
    326e:	00a50f1b          	addiw	t5,a0,10
    3272:	3c0f250b          	th.ext	a0,t5,15,0
    3276:	4681                	li	a3,0
    3278:	4785                	li	a5,1
    327a:	0e87fa63          	bgeu	a5,s0,336e <matrix_test+0xb5e>
    327e:	06098963          	beqz	s3,32f0 <matrix_test+0xae0>
    3282:	04f98563          	beq	s3,a5,32cc <matrix_test+0xabc>
    3286:	4e89                	li	t4,2
    3288:	03d98263          	beq	s3,t4,32ac <matrix_test+0xa9c>
    328c:	001b081b          	addiw	a6,s6,1
    3290:	8f9a                	mv	t6,t1
    3292:	5509430b          	th.lurw	t1,s2,a6,2
    3296:	00d306bb          	addw	a3,t1,a3
    329a:	32da4663          	blt	s4,a3,35c6 <matrix_test+0xdb6>
    329e:	006fae33          	slt	t3,t6,t1
    32a2:	00ae053b          	addw	a0,t3,a0
    32a6:	3c05250b          	th.ext	a0,a0,15,0
    32aa:	2785                	addiw	a5,a5,1
    32ac:	871a                	mv	a4,t1
    32ae:	0167833b          	addw	t1,a5,s6
    32b2:	5469430b          	th.lurw	t1,s2,t1,2
    32b6:	00d306bb          	addw	a3,t1,a3
    32ba:	2cda4f63          	blt	s4,a3,3598 <matrix_test+0xd88>
    32be:	006729b3          	slt	s3,a4,t1
    32c2:	00a982bb          	addw	t0,s3,a0
    32c6:	3c02a50b          	th.ext	a0,t0,15,0
    32ca:	2785                	addiw	a5,a5,1
    32cc:	01678f3b          	addw	t5,a5,s6
    32d0:	839a                	mv	t2,t1
    32d2:	55e9430b          	th.lurw	t1,s2,t5,2
    32d6:	00d306bb          	addw	a3,t1,a3
    32da:	2ada4963          	blt	s4,a3,358c <matrix_test+0xd7c>
    32de:	0063aeb3          	slt	t4,t2,t1
    32e2:	00ae8fbb          	addw	t6,t4,a0
    32e6:	3c0fa50b          	th.ext	a0,t6,15,0
    32ea:	2785                	addiw	a5,a5,1
    32ec:	0887f163          	bgeu	a5,s0,336e <matrix_test+0xb5e>
    32f0:	0167873b          	addw	a4,a5,s6
    32f4:	54e9498b          	th.lurw	s3,s2,a4,2
    32f8:	00d982bb          	addw	t0,s3,a3
    32fc:	1c5a5863          	bge	s4,t0,34cc <matrix_test+0xcbc>
    3300:	00a50e9b          	addiw	t4,a0,10
    3304:	3c0eaf0b          	th.ext	t5,t4,15,0
    3308:	4281                	li	t0,0
    330a:	00178f9b          	addiw	t6,a5,1
    330e:	016f883b          	addw	a6,t6,s6
    3312:	55094e0b          	th.lurw	t3,s2,a6,2
    3316:	005e073b          	addw	a4,t3,t0
    331a:	1aea5163          	bge	s4,a4,34bc <matrix_test+0xcac>
    331e:	00af069b          	addiw	a3,t5,10
    3322:	3c06a30b          	th.ext	t1,a3,15,0
    3326:	4701                	li	a4,0
    3328:	001f899b          	addiw	s3,t6,1
    332c:	016982bb          	addw	t0,s3,s6
    3330:	5459438b          	th.lurw	t2,s2,t0,2
    3334:	00e3883b          	addw	a6,t2,a4
    3338:	170a4c63          	blt	s4,a6,34b0 <matrix_test+0xca0>
    333c:	007e2533          	slt	a0,t3,t2
    3340:	00650f3b          	addw	t5,a0,t1
    3344:	3c0f2f8b          	th.ext	t6,t5,15,0
    3348:	0019879b          	addiw	a5,s3,1
    334c:	01678e3b          	addw	t3,a5,s6
    3350:	55c9430b          	th.lurw	t1,s2,t3,2
    3354:	010306bb          	addw	a3,t1,a6
    3358:	14da4663          	blt	s4,a3,34a4 <matrix_test+0xc94>
    335c:	0063a633          	slt	a2,t2,t1
    3360:	01f6073b          	addw	a4,a2,t6
    3364:	2785                	addiw	a5,a5,1
    3366:	3c07250b          	th.ext	a0,a4,15,0
    336a:	f887e3e3          	bltu	a5,s0,32f0 <matrix_test+0xae0>
    336e:	2885                	addiw	a7,a7,1
    3370:	01640b3b          	addw	s6,s0,s6
    3374:	ee88e2e3          	bltu	a7,s0,3258 <matrix_test+0xa48>
    3378:	0f8020ef          	jal	5470 <crc16>
    337c:	4681                	li	a3,0
    337e:	4601                	li	a2,0
    3380:	b2d4ca0b          	th.lurhu	s4,s1,a3,1
    3384:	fff40593          	addi	a1,s0,-1
    3388:	4785                	li	a5,1
    338a:	415a0b3b          	subw	s6,s4,s5
    338e:	32d4db0b          	th.surh	s6,s1,a3,1
    3392:	0075f913          	andi	s2,a1,7
    3396:	0e87f663          	bgeu	a5,s0,3482 <matrix_test+0xc72>
    339a:	0a090663          	beqz	s2,3446 <matrix_test+0xc36>
    339e:	08f90963          	beq	s2,a5,3430 <matrix_test+0xc20>
    33a2:	4889                	li	a7,2
    33a4:	07190d63          	beq	s2,a7,341e <matrix_test+0xc0e>
    33a8:	4e0d                	li	t3,3
    33aa:	07c90163          	beq	s2,t3,340c <matrix_test+0xbfc>
    33ae:	4711                	li	a4,4
    33b0:	04e90563          	beq	s2,a4,33fa <matrix_test+0xbea>
    33b4:	4315                	li	t1,5
    33b6:	02690963          	beq	s2,t1,33e8 <matrix_test+0xbd8>
    33ba:	4999                	li	s3,6
    33bc:	01390b63          	beq	s2,s3,33d2 <matrix_test+0xbc2>
    33c0:	0016829b          	addiw	t0,a3,1
    33c4:	b254c38b          	th.lurhu	t2,s1,t0,1
    33c8:	87c6                	mv	a5,a7
    33ca:	41538f3b          	subw	t5,t2,s5
    33ce:	3254df0b          	th.surh	t5,s1,t0,1
    33d2:	00d78ebb          	addw	t4,a5,a3
    33d6:	b3d4cf8b          	th.lurhu	t6,s1,t4,1
    33da:	2785                	addiw	a5,a5,1
    33dc:	415f883b          	subw	a6,t6,s5
    33e0:	33d4d80b          	th.surh	a6,s1,t4,1
    33e4:	00000013          	nop
    33e8:	00d785bb          	addw	a1,a5,a3
    33ec:	b2b4c90b          	th.lurhu	s2,s1,a1,1
    33f0:	2785                	addiw	a5,a5,1
    33f2:	41590a3b          	subw	s4,s2,s5
    33f6:	32b4da0b          	th.surh	s4,s1,a1,1
    33fa:	00d78b3b          	addw	s6,a5,a3
    33fe:	b364c88b          	th.lurhu	a7,s1,s6,1
    3402:	2785                	addiw	a5,a5,1
    3404:	41588e3b          	subw	t3,a7,s5
    3408:	3364de0b          	th.surh	t3,s1,s6,1
    340c:	00d7833b          	addw	t1,a5,a3
    3410:	b264c70b          	th.lurhu	a4,s1,t1,1
    3414:	2785                	addiw	a5,a5,1
    3416:	415709bb          	subw	s3,a4,s5
    341a:	3264d98b          	th.surh	s3,s1,t1,1
    341e:	00d782bb          	addw	t0,a5,a3
    3422:	b254c38b          	th.lurhu	t2,s1,t0,1
    3426:	2785                	addiw	a5,a5,1
    3428:	41538f3b          	subw	t5,t2,s5
    342c:	3254df0b          	th.surh	t5,s1,t0,1
    3430:	00d78ebb          	addw	t4,a5,a3
    3434:	b3d4cf8b          	th.lurhu	t6,s1,t4,1
    3438:	2785                	addiw	a5,a5,1
    343a:	415f883b          	subw	a6,t6,s5
    343e:	33d4d80b          	th.surh	a6,s1,t4,1
    3442:	0487f063          	bgeu	a5,s0,3482 <matrix_test+0xc72>
    3446:	00d785bb          	addw	a1,a5,a3
    344a:	b2b4c90b          	th.lurhu	s2,s1,a1,1
    344e:	00178b1b          	addiw	s6,a5,1
    3452:	00db08bb          	addw	a7,s6,a3
    3456:	41590a3b          	subw	s4,s2,s5
    345a:	32b4da0b          	th.surh	s4,s1,a1,1
    345e:	b314ce0b          	th.lurhu	t3,s1,a7,1
    3462:	001b079b          	addiw	a5,s6,1
    3466:	00d78ebb          	addw	t4,a5,a3
    346a:	415e033b          	subw	t1,t3,s5
    346e:	3314d30b          	th.surh	t1,s1,a7,1
    3472:	b3d4cf8b          	th.lurhu	t6,s1,t4,1
    3476:	2785                	addiw	a5,a5,1
    3478:	415f883b          	subw	a6,t6,s5
    347c:	33d4d80b          	th.surh	a6,s1,t4,1
    3480:	b7a5                	j	33e8 <matrix_test+0xbd8>
    3482:	2605                	addiw	a2,a2,1
    3484:	9ea1                	addw	a3,a3,s0
    3486:	ee866de3          	bltu	a2,s0,3380 <matrix_test+0xb70>
    348a:	74a2                	ld	s1,40(sp)
    348c:	7442                	ld	s0,48(sp)
    348e:	70e2                	ld	ra,56(sp)
    3490:	6b02                	ld	s6,0(sp)
    3492:	6aa2                	ld	s5,8(sp)
    3494:	69e2                	ld	s3,24(sp)
    3496:	7902                	ld	s2,32(sp)
    3498:	6a42                	ld	s4,16(sp)
    349a:	3c05250b          	th.ext	a0,a0,15,0
    349e:	6121                	addi	sp,sp,64
    34a0:	8082                	ret
    34a2:	0001                	nop
    34a4:	00af869b          	addiw	a3,t6,10
    34a8:	3c06a50b          	th.ext	a0,a3,15,0
    34ac:	4681                	li	a3,0
    34ae:	bd35                	j	32ea <matrix_test+0xada>
    34b0:	00a30e9b          	addiw	t4,t1,10
    34b4:	3c0eaf8b          	th.ext	t6,t4,15,0
    34b8:	4801                	li	a6,0
    34ba:	b579                	j	3348 <matrix_test+0xb38>
    34bc:	01c9a7b3          	slt	a5,s3,t3
    34c0:	01e7863b          	addw	a2,a5,t5
    34c4:	3c06230b          	th.ext	t1,a2,15,0
    34c8:	b585                	j	3328 <matrix_test+0xb18>
    34ca:	0001                	nop
    34cc:	013323b3          	slt	t2,t1,s3
    34d0:	00a3853b          	addw	a0,t2,a0
    34d4:	3c052f0b          	th.ext	t5,a0,15,0
    34d8:	bd0d                	j	330a <matrix_test+0xafa>
    34da:	0001                	nop
    34dc:	00ae071b          	addiw	a4,t3,10
    34e0:	3c07250b          	th.ext	a0,a4,15,0
    34e4:	4601                	li	a2,0
    34e6:	be95                	j	305a <matrix_test+0x84a>
    34e8:	00a7881b          	addiw	a6,a5,10
    34ec:	3c082e0b          	th.ext	t3,a6,15,0
    34f0:	4301                	li	t1,0
    34f2:	b6d9                	j	30b8 <matrix_test+0x8a8>
    34f4:	00c2a333          	slt	t1,t0,a2
    34f8:	01e306bb          	addw	a3,t1,t5
    34fc:	3c06a78b          	th.ext	a5,a3,15,0
    3500:	be61                	j	3098 <matrix_test+0x888>
    3502:	0001                	nop
    3504:	0058a8b3          	slt	a7,a7,t0
    3508:	00a8853b          	addw	a0,a7,a0
    350c:	3c052f0b          	th.ext	t5,a0,15,0
    3510:	b6ad                	j	307a <matrix_test+0x86a>
    3512:	0001                	nop
    3514:	00a3071b          	addiw	a4,t1,10
    3518:	3c07250b          	th.ext	a0,a4,15,0
    351c:	4701                	li	a4,0
    351e:	b231                	j	2e2a <matrix_test+0x61a>
    3520:	00ab069b          	addiw	a3,s6,10
    3524:	3c06a30b          	th.ext	t1,a3,15,0
    3528:	4781                	li	a5,0
    352a:	bab1                	j	2e86 <matrix_test+0x676>
    352c:	011fa7b3          	slt	a5,t6,a7
    3530:	01d783bb          	addw	t2,a5,t4
    3534:	3c03ab0b          	th.ext	s6,t2,15,0
    3538:	b23d                	j	2e66 <matrix_test+0x656>
    353a:	0001                	nop
    353c:	01f8af33          	slt	t5,a7,t6
    3540:	00af053b          	addw	a0,t5,a0
    3544:	3c052e8b          	th.ext	t4,a0,15,0
    3548:	b209                	j	2e4a <matrix_test+0x63a>
    354a:	011323b3          	slt	t2,t1,a7
    354e:	00a3853b          	addw	a0,t2,a0
    3552:	3c05250b          	th.ext	a0,a0,15,0
    3556:	b08d                	j	2db8 <matrix_test+0x5a8>
    3558:	0062a633          	slt	a2,t0,t1
    355c:	00a603bb          	addw	t2,a2,a0
    3560:	3c03a50b          	th.ext	a0,t2,15,0
    3564:	bb11                	j	3278 <matrix_test+0xa68>
    3566:	0116a7b3          	slt	a5,a3,a7
    356a:	00a783bb          	addw	t2,a5,a0
    356e:	3c03a50b          	th.ext	a0,t2,15,0
    3572:	bc9d                	j	2fe8 <matrix_test+0x7d8>
    3574:	00a5071b          	addiw	a4,a0,10
    3578:	3c07250b          	th.ext	a0,a4,15,0
    357c:	4601                	li	a2,0
    357e:	bcf1                	j	305a <matrix_test+0x84a>
    3580:	00a5071b          	addiw	a4,a0,10
    3584:	3c07250b          	th.ext	a0,a4,15,0
    3588:	4701                	li	a4,0
    358a:	b045                	j	2e2a <matrix_test+0x61a>
    358c:	00a5081b          	addiw	a6,a0,10
    3590:	3c08250b          	th.ext	a0,a6,15,0
    3594:	4681                	li	a3,0
    3596:	bb91                	j	32ea <matrix_test+0xada>
    3598:	00a5061b          	addiw	a2,a0,10
    359c:	3c06250b          	th.ext	a0,a2,15,0
    35a0:	4681                	li	a3,0
    35a2:	b325                	j	32ca <matrix_test+0xaba>
    35a4:	2529                	addiw	a0,a0,10
    35a6:	3c05250b          	th.ext	a0,a0,15,0
    35aa:	4701                	li	a4,0
    35ac:	b8b9                	j	2e0a <matrix_test+0x5fa>
    35ae:	00a5039b          	addiw	t2,a0,10
    35b2:	3c03a50b          	th.ext	a0,t2,15,0
    35b6:	4601                	li	a2,0
    35b8:	b449                	j	303a <matrix_test+0x82a>
    35ba:	00a5061b          	addiw	a2,a0,10
    35be:	3c06250b          	th.ext	a0,a2,15,0
    35c2:	4601                	li	a2,0
    35c4:	bc99                	j	301a <matrix_test+0x80a>
    35c6:	00a5069b          	addiw	a3,a0,10
    35ca:	3c06a50b          	th.ext	a0,a3,15,0
    35ce:	4681                	li	a3,0
    35d0:	b9e9                	j	32aa <matrix_test+0xa9a>
    35d2:	00a50b1b          	addiw	s6,a0,10
    35d6:	3c0b250b          	th.ext	a0,s6,15,0
    35da:	4701                	li	a4,0
    35dc:	80fff06f          	j	2dea <matrix_test+0x5da>
    35e0:	4581                	li	a1,0
    35e2:	68f010ef          	jal	5470 <crc16>
    35e6:	85aa                	mv	a1,a0
    35e8:	4501                	li	a0,0
    35ea:	687010ef          	jal	5470 <crc16>
    35ee:	85aa                	mv	a1,a0
    35f0:	4501                	li	a0,0
    35f2:	67f010ef          	jal	5470 <crc16>
    35f6:	85aa                	mv	a1,a0
    35f8:	4501                	li	a0,0
    35fa:	677010ef          	jal	5470 <crc16>
    35fe:	70e2                	ld	ra,56(sp)
    3600:	6a42                	ld	s4,16(sp)
    3602:	3c05250b          	th.ext	a0,a0,15,0
    3606:	6121                	addi	sp,sp,64
    3608:	8082                	ret
    360a:	00000013          	nop
    360e:	0001                	nop

0000000000003610 <core_bench_matrix>:
    3610:	1141                	addi	sp,sp,-16
    3612:	f811540b          	th.sdd	s0,ra,(sp),0,4
    3616:	872e                	mv	a4,a1
    3618:	8432                	mv	s0,a2
    361a:	fab5468b          	th.ldd	a3,a1,(a0),1,4
    361e:	6510                	ld	a2,8(a0)
    3620:	4108                	lw	a0,0(a0)
    3622:	9eeff0ef          	jal	2810 <matrix_test>
    3626:	85a2                	mv	a1,s0
    3628:	f811440b          	th.ldd	s0,ra,(sp),0,4
    362c:	0141                	addi	sp,sp,16
    362e:	6430106f          	j	5470 <crc16>
    3632:	0001                	nop
    3634:	00000013          	nop
    3638:	00000013          	nop
    363c:	00000013          	nop

0000000000003640 <core_init_matrix>:
    3640:	4785                	li	a5,1
    3642:	42c6178b          	th.mvnez	a5,a2,a2
    3646:	882a                	mv	a6,a0
    3648:	4601                	li	a2,0
    364a:	1e050763          	beqz	a0,3838 <core_init_matrix+0x1f8>
    364e:	0016031b          	addiw	t1,a2,1
    3652:	026303bb          	mulw	t2,t1,t1
    3656:	8532                	mv	a0,a2
    3658:	0033989b          	slliw	a7,t2,0x3
    365c:	0908f263          	bgeu	a7,a6,36e0 <core_init_matrix+0xa0>
    3660:	00130e1b          	addiw	t3,t1,1
    3664:	03ce0f3b          	mulw	t5,t3,t3
    3668:	851a                	mv	a0,t1
    366a:	003f1f9b          	slliw	t6,t5,0x3
    366e:	070ff963          	bgeu	t6,a6,36e0 <core_init_matrix+0xa0>
    3672:	001e061b          	addiw	a2,t3,1
    3676:	02c6033b          	mulw	t1,a2,a2
    367a:	8572                	mv	a0,t3
    367c:	0033171b          	slliw	a4,t1,0x3
    3680:	07077063          	bgeu	a4,a6,36e0 <core_init_matrix+0xa0>
    3684:	0016039b          	addiw	t2,a2,1
    3688:	02738e3b          	mulw	t3,t2,t2
    368c:	8532                	mv	a0,a2
    368e:	003e1e9b          	slliw	t4,t3,0x3
    3692:	050ef763          	bgeu	t4,a6,36e0 <core_init_matrix+0xa0>
    3696:	00138f1b          	addiw	t5,t2,1
    369a:	03ef063b          	mulw	a2,t5,t5
    369e:	851e                	mv	a0,t2
    36a0:	0036129b          	slliw	t0,a2,0x3
    36a4:	0302fe63          	bgeu	t0,a6,36e0 <core_init_matrix+0xa0>
    36a8:	001f031b          	addiw	t1,t5,1
    36ac:	026303bb          	mulw	t2,t1,t1
    36b0:	857a                	mv	a0,t5
    36b2:	0033989b          	slliw	a7,t2,0x3
    36b6:	0308f563          	bgeu	a7,a6,36e0 <core_init_matrix+0xa0>
    36ba:	00130e1b          	addiw	t3,t1,1
    36be:	03ce0f3b          	mulw	t5,t3,t3
    36c2:	851a                	mv	a0,t1
    36c4:	003f1f9b          	slliw	t6,t5,0x3
    36c8:	010ffc63          	bgeu	t6,a6,36e0 <core_init_matrix+0xa0>
    36cc:	001e061b          	addiw	a2,t3,1
    36d0:	02c6033b          	mulw	t1,a2,a2
    36d4:	8572                	mv	a0,t3
    36d6:	0033171b          	slliw	a4,t1,0x3
    36da:	f7076ae3          	bltu	a4,a6,364e <core_init_matrix+0xe>
    36de:	0001                	nop
    36e0:	02a503bb          	mulw	t2,a0,a0
    36e4:	15fd                	addi	a1,a1,-1
    36e6:	ffc5f813          	andi	a6,a1,-4
    36ea:	00480593          	addi	a1,a6,4
    36ee:	7c03b88b          	th.extu	a7,t2,31,0
    36f2:	00189e13          	slli	t3,a7,0x1
    36f6:	01c58633          	add	a2,a1,t3
    36fa:	14050b63          	beqz	a0,3850 <core_init_matrix+0x210>
    36fe:	8eaa                	mv	t4,a0
    3700:	0015081b          	addiw	a6,a0,1
    3704:	4881                	li	a7,0
    3706:	4705                	li	a4,1
    3708:	40e80f33          	sub	t5,a6,a4
    370c:	003f7293          	andi	t0,t5,3
    3710:	833a                	mv	t1,a4
    3712:	00028963          	beqz	t0,3724 <core_init_matrix+0xe4>
    3716:	4f85                	li	t6,1
    3718:	0bf28d63          	beq	t0,t6,37d2 <core_init_matrix+0x192>
    371c:	4389                	li	t2,2
    371e:	06728d63          	beq	t0,t2,3798 <core_init_matrix+0x158>
    3722:	a835                	j	375e <core_init_matrix+0x11e>
    3724:	02e783bb          	mulw	t2,a5,a4
    3728:	41f3d29b          	sraiw	t0,t2,0x1f
    372c:	0102df9b          	srliw	t6,t0,0x10
    3730:	007f87bb          	addw	a5,t6,t2
    3734:	3c07bf0b          	th.extu	t5,a5,15,0
    3738:	41ff07bb          	subw	a5,t5,t6
    373c:	3c07338b          	th.extu	t2,a4,15,0
    3740:	007782bb          	addw	t0,a5,t2
    3744:	3c02bf0b          	th.extu	t5,t0,15,0
    3748:	fff70f9b          	addiw	t6,a4,-1
    374c:	007f03bb          	addw	t2,t5,t2
    3750:	33f65f0b          	th.surh	t5,a2,t6,1
    3754:	0ff3f293          	zext.b	t0,t2
    3758:	33f5d28b          	th.surh	t0,a1,t6,1
    375c:	2705                	addiw	a4,a4,1
    375e:	02e787bb          	mulw	a5,a5,a4
    3762:	41f7df1b          	sraiw	t5,a5,0x1f
    3766:	010f529b          	srliw	t0,t5,0x10
    376a:	00f28fbb          	addw	t6,t0,a5
    376e:	3c0fb38b          	th.extu	t2,t6,15,0
    3772:	405387bb          	subw	a5,t2,t0
    3776:	3c07328b          	th.extu	t0,a4,15,0
    377a:	00578f3b          	addw	t5,a5,t0
    377e:	3c0f338b          	th.extu	t2,t5,15,0
    3782:	fff70f9b          	addiw	t6,a4,-1
    3786:	005382bb          	addw	t0,t2,t0
    378a:	33f6538b          	th.surh	t2,a2,t6,1
    378e:	0ff2ff13          	zext.b	t5,t0
    3792:	33f5df0b          	th.surh	t5,a1,t6,1
    3796:	2705                	addiw	a4,a4,1
    3798:	02e787bb          	mulw	a5,a5,a4
    379c:	41f7d39b          	sraiw	t2,a5,0x1f
    37a0:	0103df9b          	srliw	t6,t2,0x10
    37a4:	00ff82bb          	addw	t0,t6,a5
    37a8:	3c02bf0b          	th.extu	t5,t0,15,0
    37ac:	3c07338b          	th.extu	t2,a4,15,0
    37b0:	41ff07bb          	subw	a5,t5,t6
    37b4:	00778fbb          	addw	t6,a5,t2
    37b8:	3c0fb28b          	th.extu	t0,t6,15,0
    37bc:	00728f3b          	addw	t5,t0,t2
    37c0:	fff70f9b          	addiw	t6,a4,-1
    37c4:	33f6528b          	th.surh	t0,a2,t6,1
    37c8:	0fff7393          	zext.b	t2,t5
    37cc:	33f5d38b          	th.surh	t2,a1,t6,1
    37d0:	2705                	addiw	a4,a4,1
    37d2:	02e787bb          	mulw	a5,a5,a4
    37d6:	41f7d29b          	sraiw	t0,a5,0x1f
    37da:	0102df9b          	srliw	t6,t0,0x10
    37de:	00ff8f3b          	addw	t5,t6,a5
    37e2:	3c0f338b          	th.extu	t2,t5,15,0
    37e6:	3c07328b          	th.extu	t0,a4,15,0
    37ea:	41f387bb          	subw	a5,t2,t6
    37ee:	00578fbb          	addw	t6,a5,t0
    37f2:	3c0fbf0b          	th.extu	t5,t6,15,0
    37f6:	fff7039b          	addiw	t2,a4,-1
    37fa:	005f02bb          	addw	t0,t5,t0
    37fe:	32765f0b          	th.surh	t5,a2,t2,1
    3802:	0ff2ff93          	zext.b	t6,t0
    3806:	3275df8b          	th.surh	t6,a1,t2,1
    380a:	2705                	addiw	a4,a4,1
    380c:	f1071ce3          	bne	a4,a6,3724 <core_init_matrix+0xe4>
    3810:	2885                	addiw	a7,a7,1
    3812:	0065073b          	addw	a4,a0,t1
    3816:	0105083b          	addw	a6,a0,a6
    381a:	eea897e3          	bne	a7,a0,3708 <core_init_matrix+0xc8>
    381e:	9e32                	add	t3,t3,a2
    3820:	fffe0313          	addi	t1,t3,-1
    3824:	ffc37793          	andi	a5,t1,-4
    3828:	00478f13          	addi	t5,a5,4
    382c:	01d6a023          	sw	t4,0(a3)
    3830:	e68c                	sd	a1,8(a3)
    3832:	fbe6d60b          	th.sdd	a2,t5,(a3),1,4
    3836:	8082                	ret
    3838:	fff58613          	addi	a2,a1,-1
    383c:	ffc67293          	andi	t0,a2,-4
    3840:	5efd                	li	t4,-1
    3842:	00428593          	addi	a1,t0,4
    3846:	00628613          	addi	a2,t0,6
    384a:	8576                	mv	a0,t4
    384c:	4e09                	li	t3,2
    384e:	bd4d                	j	3700 <core_init_matrix+0xc0>
    3850:	4e81                	li	t4,0
    3852:	4e01                	li	t3,0
    3854:	b7e9                	j	381e <core_init_matrix+0x1de>
    3856:	00000013          	nop
    385a:	00000013          	nop
    385e:	0001                	nop

0000000000003860 <matrix_sum>:
    3860:	88aa                	mv	a7,a0
    3862:	18050563          	beqz	a0,39ec <matrix_sum+0x18c>
    3866:	882a                	mv	a6,a0
    3868:	4301                	li	t1,0
    386a:	4e01                	li	t3,0
    386c:	4501                	li	a0,0
    386e:	4f01                	li	t5,0
    3870:	4781                	li	a5,0
    3872:	0001                	nop
    3874:	00000013          	nop
    3878:	406806b3          	sub	a3,a6,t1
    387c:	0036f293          	andi	t0,a3,3
    3880:	871a                	mv	a4,t1
    3882:	0c028e63          	beqz	t0,395e <matrix_sum+0xfe>
    3886:	4e85                	li	t4,1
    3888:	05d28263          	beq	t0,t4,38cc <matrix_sum+0x6c>
    388c:	4389                	li	t2,2
    388e:	02728163          	beq	t0,t2,38b0 <matrix_sum+0x50>
    3892:	877a                	mv	a4,t5
    3894:	5465cf0b          	th.lurw	t5,a1,t1,2
    3898:	00ff07bb          	addw	a5,t5,a5
    389c:	14f64263          	blt	a2,a5,39e0 <matrix_sum+0x180>
    38a0:	01e72fb3          	slt	t6,a4,t5
    38a4:	00af853b          	addw	a0,t6,a0
    38a8:	3c05250b          	th.ext	a0,a0,15,0
    38ac:	0013071b          	addiw	a4,t1,1
    38b0:	86fa                	mv	a3,t5
    38b2:	54e5cf0b          	th.lurw	t5,a1,a4,2
    38b6:	00ff07bb          	addw	a5,t5,a5
    38ba:	10f64d63          	blt	a2,a5,39d4 <matrix_sum+0x174>
    38be:	01e6a2b3          	slt	t0,a3,t5
    38c2:	00a28ebb          	addw	t4,t0,a0
    38c6:	3c0ea50b          	th.ext	a0,t4,15,0
    38ca:	2705                	addiw	a4,a4,1
    38cc:	8ffa                	mv	t6,t5
    38ce:	54e5cf0b          	th.lurw	t5,a1,a4,2
    38d2:	00ff07bb          	addw	a5,t5,a5
    38d6:	0ef64963          	blt	a2,a5,39c8 <matrix_sum+0x168>
    38da:	01efa6b3          	slt	a3,t6,t5
    38de:	9d35                	addw	a0,a0,a3
    38e0:	3c05250b          	th.ext	a0,a0,15,0
    38e4:	2705                	addiw	a4,a4,1
    38e6:	06e81c63          	bne	a6,a4,395e <matrix_sum+0xfe>
    38ea:	2e05                	addiw	t3,t3,1
    38ec:	0108883b          	addw	a6,a7,a6
    38f0:	0068833b          	addw	t1,a7,t1
    38f4:	f9c892e3          	bne	a7,t3,3878 <matrix_sum+0x18>
    38f8:	8082                	ret
    38fa:	0001                	nop
    38fc:	2705                	addiw	a4,a4,1
    38fe:	54e5cf0b          	th.lurw	t5,a1,a4,2
    3902:	00a5069b          	addiw	a3,a0,10
    3906:	4381                	li	t2,0
    3908:	3c06af8b          	th.ext	t6,a3,15,0
    390c:	007f06bb          	addw	a3,t5,t2
    3910:	06d65a63          	bge	a2,a3,3984 <matrix_sum+0x124>
    3914:	00af879b          	addiw	a5,t6,10
    3918:	00170f9b          	addiw	t6,a4,1
    391c:	55f5ce8b          	th.lurw	t4,a1,t6,2
    3920:	4681                	li	a3,0
    3922:	3c07a38b          	th.ext	t2,a5,15,0
    3926:	00de87bb          	addw	a5,t4,a3
    392a:	06f64b63          	blt	a2,a5,39a0 <matrix_sum+0x140>
    392e:	01df2733          	slt	a4,t5,t4
    3932:	00770f3b          	addw	t5,a4,t2
    3936:	001f839b          	addiw	t2,t6,1
    393a:	3c0f228b          	th.ext	t0,t5,15,0
    393e:	5475cf0b          	th.lurw	t5,a1,t2,2
    3942:	00ff07bb          	addw	a5,t5,a5
    3946:	06f64a63          	blt	a2,a5,39ba <matrix_sum+0x15a>
    394a:	01eea6b3          	slt	a3,t4,t5
    394e:	00568fbb          	addw	t6,a3,t0
    3952:	3c0fa50b          	th.ext	a0,t6,15,0
    3956:	0013871b          	addiw	a4,t2,1
    395a:	f8e808e3          	beq	a6,a4,38ea <matrix_sum+0x8a>
    395e:	54e5c28b          	th.lurw	t0,a1,a4,2
    3962:	00f283bb          	addw	t2,t0,a5
    3966:	f8764be3          	blt	a2,t2,38fc <matrix_sum+0x9c>
    396a:	005f2f33          	slt	t5,t5,t0
    396e:	2705                	addiw	a4,a4,1
    3970:	00af0ebb          	addw	t4,t5,a0
    3974:	54e5cf0b          	th.lurw	t5,a1,a4,2
    3978:	3c0eaf8b          	th.ext	t6,t4,15,0
    397c:	007f06bb          	addw	a3,t5,t2
    3980:	f8d64ae3          	blt	a2,a3,3914 <matrix_sum+0xb4>
    3984:	01e2a533          	slt	a0,t0,t5
    3988:	01f502bb          	addw	t0,a0,t6
    398c:	00170f9b          	addiw	t6,a4,1
    3990:	55f5ce8b          	th.lurw	t4,a1,t6,2
    3994:	3c02a38b          	th.ext	t2,t0,15,0
    3998:	00de87bb          	addw	a5,t4,a3
    399c:	f8f659e3          	bge	a2,a5,392e <matrix_sum+0xce>
    39a0:	00a3851b          	addiw	a0,t2,10
    39a4:	001f839b          	addiw	t2,t6,1
    39a8:	5475cf0b          	th.lurw	t5,a1,t2,2
    39ac:	4781                	li	a5,0
    39ae:	3c05228b          	th.ext	t0,a0,15,0
    39b2:	00ff07bb          	addw	a5,t5,a5
    39b6:	f8f65ae3          	bge	a2,a5,394a <matrix_sum+0xea>
    39ba:	00a28e9b          	addiw	t4,t0,10
    39be:	3c0ea50b          	th.ext	a0,t4,15,0
    39c2:	4781                	li	a5,0
    39c4:	bf49                	j	3956 <matrix_sum+0xf6>
    39c6:	0001                	nop
    39c8:	00a5079b          	addiw	a5,a0,10
    39cc:	3c07a50b          	th.ext	a0,a5,15,0
    39d0:	4781                	li	a5,0
    39d2:	bf09                	j	38e4 <matrix_sum+0x84>
    39d4:	00a5039b          	addiw	t2,a0,10
    39d8:	3c03a50b          	th.ext	a0,t2,15,0
    39dc:	4781                	li	a5,0
    39de:	b5f5                	j	38ca <matrix_sum+0x6a>
    39e0:	00a5079b          	addiw	a5,a0,10
    39e4:	3c07a50b          	th.ext	a0,a5,15,0
    39e8:	4781                	li	a5,0
    39ea:	b5c9                	j	38ac <matrix_sum+0x4c>
    39ec:	4501                	li	a0,0
    39ee:	8082                	ret

00000000000039f0 <matrix_mul_const>:
    39f0:	12050d63          	beqz	a0,3b2a <matrix_mul_const+0x13a>
    39f4:	882a                	mv	a6,a0
    39f6:	4881                	li	a7,0
    39f8:	4301                	li	t1,0
    39fa:	0001                	nop
    39fc:	00000013          	nop
    3a00:	41180733          	sub	a4,a6,a7
    3a04:	00777293          	andi	t0,a4,7
    3a08:	87c6                	mv	a5,a7
    3a0a:	08028863          	beqz	t0,3a9a <matrix_mul_const+0xaa>
    3a0e:	4e05                	li	t3,1
    3a10:	07c28c63          	beq	t0,t3,3a88 <matrix_mul_const+0x98>
    3a14:	4389                	li	t2,2
    3a16:	06728263          	beq	t0,t2,3a7a <matrix_mul_const+0x8a>
    3a1a:	4e8d                	li	t4,3
    3a1c:	05d28863          	beq	t0,t4,3a6c <matrix_mul_const+0x7c>
    3a20:	4f11                	li	t5,4
    3a22:	03e28e63          	beq	t0,t5,3a5e <matrix_mul_const+0x6e>
    3a26:	4f95                	li	t6,5
    3a28:	03f28463          	beq	t0,t6,3a50 <matrix_mul_const+0x60>
    3a2c:	4719                	li	a4,6
    3a2e:	00e28a63          	beq	t0,a4,3a42 <matrix_mul_const+0x52>
    3a32:	3316478b          	th.lurh	a5,a2,a7,1
    3a36:	02d782bb          	mulw	t0,a5,a3
    3a3a:	0018879b          	addiw	a5,a7,1
    3a3e:	5515d28b          	th.surw	t0,a1,a7,2
    3a42:	32f64e0b          	th.lurh	t3,a2,a5,1
    3a46:	02de03bb          	mulw	t2,t3,a3
    3a4a:	54f5d38b          	th.surw	t2,a1,a5,2
    3a4e:	2785                	addiw	a5,a5,1
    3a50:	32f64e8b          	th.lurh	t4,a2,a5,1
    3a54:	02de8f3b          	mulw	t5,t4,a3
    3a58:	54f5df0b          	th.surw	t5,a1,a5,2
    3a5c:	2785                	addiw	a5,a5,1
    3a5e:	32f64f8b          	th.lurh	t6,a2,a5,1
    3a62:	02df873b          	mulw	a4,t6,a3
    3a66:	54f5d70b          	th.surw	a4,a1,a5,2
    3a6a:	2785                	addiw	a5,a5,1
    3a6c:	32f6428b          	th.lurh	t0,a2,a5,1
    3a70:	02d28e3b          	mulw	t3,t0,a3
    3a74:	54f5de0b          	th.surw	t3,a1,a5,2
    3a78:	2785                	addiw	a5,a5,1
    3a7a:	32f6438b          	th.lurh	t2,a2,a5,1
    3a7e:	02d38ebb          	mulw	t4,t2,a3
    3a82:	54f5de8b          	th.surw	t4,a1,a5,2
    3a86:	2785                	addiw	a5,a5,1
    3a88:	32f64f0b          	th.lurh	t5,a2,a5,1
    3a8c:	02df0fbb          	mulw	t6,t5,a3
    3a90:	54f5df8b          	th.surw	t6,a1,a5,2
    3a94:	2785                	addiw	a5,a5,1
    3a96:	08f80363          	beq	a6,a5,3b1c <matrix_mul_const+0x12c>
    3a9a:	32f6470b          	th.lurh	a4,a2,a5,1
    3a9e:	00178e1b          	addiw	t3,a5,1
    3aa2:	33c6438b          	th.lurh	t2,a2,t3,1
    3aa6:	02d702bb          	mulw	t0,a4,a3
    3aaa:	001e0f1b          	addiw	t5,t3,1
    3aae:	33e64f8b          	th.lurh	t6,a2,t5,1
    3ab2:	02d38ebb          	mulw	t4,t2,a3
    3ab6:	54f5d28b          	th.surw	t0,a1,a5,2
    3aba:	001f029b          	addiw	t0,t5,1
    3abe:	3256470b          	th.lurh	a4,a2,t0,1
    3ac2:	0012839b          	addiw	t2,t0,1
    3ac6:	02df87bb          	mulw	a5,t6,a3
    3aca:	55c5de8b          	th.surw	t4,a1,t3,2
    3ace:	32764e8b          	th.lurh	t4,a2,t2,1
    3ad2:	02d70e3b          	mulw	t3,a4,a3
    3ad6:	00138f9b          	addiw	t6,t2,1
    3ada:	55e5d78b          	th.surw	a5,a1,t5,2
    3ade:	33f6478b          	th.lurh	a5,a2,t6,1
    3ae2:	02de8f3b          	mulw	t5,t4,a3
    3ae6:	5455de0b          	th.surw	t3,a1,t0,2
    3aea:	001f8e1b          	addiw	t3,t6,1
    3aee:	33c6470b          	th.lurh	a4,a2,t3,1
    3af2:	02d782bb          	mulw	t0,a5,a3
    3af6:	001e079b          	addiw	a5,t3,1
    3afa:	5475df0b          	th.surw	t5,a1,t2,2
    3afe:	32f64f0b          	th.lurh	t5,a2,a5,1
    3b02:	02d703bb          	mulw	t2,a4,a3
    3b06:	55f5d28b          	th.surw	t0,a1,t6,2
    3b0a:	02df0fbb          	mulw	t6,t5,a3
    3b0e:	55c5d38b          	th.surw	t2,a1,t3,2
    3b12:	54f5df8b          	th.surw	t6,a1,a5,2
    3b16:	2785                	addiw	a5,a5,1
    3b18:	f8f811e3          	bne	a6,a5,3a9a <matrix_mul_const+0xaa>
    3b1c:	2305                	addiw	t1,t1,1
    3b1e:	011508bb          	addw	a7,a0,a7
    3b22:	0105083b          	addw	a6,a0,a6
    3b26:	ec651de3          	bne	a0,t1,3a00 <matrix_mul_const+0x10>
    3b2a:	8082                	ret
    3b2c:	00000013          	nop

0000000000003b30 <matrix_add_const>:
    3b30:	12050b63          	beqz	a0,3c66 <matrix_add_const+0x136>
    3b34:	3c06370b          	th.extu	a4,a2,15,0
    3b38:	4801                	li	a6,0
    3b3a:	862a                	mv	a2,a0
    3b3c:	4881                	li	a7,0
    3b3e:	0001                	nop
    3b40:	410606b3          	sub	a3,a2,a6
    3b44:	0076f293          	andi	t0,a3,7
    3b48:	87c2                	mv	a5,a6
    3b4a:	08028863          	beqz	t0,3bda <matrix_add_const+0xaa>
    3b4e:	4305                	li	t1,1
    3b50:	06628c63          	beq	t0,t1,3bc8 <matrix_add_const+0x98>
    3b54:	4389                	li	t2,2
    3b56:	06728263          	beq	t0,t2,3bba <matrix_add_const+0x8a>
    3b5a:	4e0d                	li	t3,3
    3b5c:	05c28863          	beq	t0,t3,3bac <matrix_add_const+0x7c>
    3b60:	4e91                	li	t4,4
    3b62:	03d28e63          	beq	t0,t4,3b9e <matrix_add_const+0x6e>
    3b66:	4f15                	li	t5,5
    3b68:	03e28463          	beq	t0,t5,3b90 <matrix_add_const+0x60>
    3b6c:	4f99                	li	t6,6
    3b6e:	01f28a63          	beq	t0,t6,3b82 <matrix_add_const+0x52>
    3b72:	b305c78b          	th.lurhu	a5,a1,a6,1
    3b76:	00e786bb          	addw	a3,a5,a4
    3b7a:	3305d68b          	th.surh	a3,a1,a6,1
    3b7e:	0018079b          	addiw	a5,a6,1
    3b82:	b2f5c28b          	th.lurhu	t0,a1,a5,1
    3b86:	00e2833b          	addw	t1,t0,a4
    3b8a:	32f5d30b          	th.surh	t1,a1,a5,1
    3b8e:	2785                	addiw	a5,a5,1
    3b90:	b2f5c38b          	th.lurhu	t2,a1,a5,1
    3b94:	00e38e3b          	addw	t3,t2,a4
    3b98:	32f5de0b          	th.surh	t3,a1,a5,1
    3b9c:	2785                	addiw	a5,a5,1
    3b9e:	b2f5ce8b          	th.lurhu	t4,a1,a5,1
    3ba2:	00ee8f3b          	addw	t5,t4,a4
    3ba6:	32f5df0b          	th.surh	t5,a1,a5,1
    3baa:	2785                	addiw	a5,a5,1
    3bac:	b2f5cf8b          	th.lurhu	t6,a1,a5,1
    3bb0:	00ef86bb          	addw	a3,t6,a4
    3bb4:	32f5d68b          	th.surh	a3,a1,a5,1
    3bb8:	2785                	addiw	a5,a5,1
    3bba:	b2f5c28b          	th.lurhu	t0,a1,a5,1
    3bbe:	00e2833b          	addw	t1,t0,a4
    3bc2:	32f5d30b          	th.surh	t1,a1,a5,1
    3bc6:	2785                	addiw	a5,a5,1
    3bc8:	b2f5c38b          	th.lurhu	t2,a1,a5,1
    3bcc:	00e38e3b          	addw	t3,t2,a4
    3bd0:	32f5de0b          	th.surh	t3,a1,a5,1
    3bd4:	2785                	addiw	a5,a5,1
    3bd6:	08f60263          	beq	a2,a5,3c5a <matrix_add_const+0x12a>
    3bda:	b2f5ce8b          	th.lurhu	t4,a1,a5,1
    3bde:	00178f9b          	addiw	t6,a5,1
    3be2:	001f831b          	addiw	t1,t6,1
    3be6:	00ee8f3b          	addw	t5,t4,a4
    3bea:	32f5df0b          	th.surh	t5,a1,a5,1
    3bee:	b3f5c68b          	th.lurhu	a3,a1,t6,1
    3bf2:	0013079b          	addiw	a5,t1,1
    3bf6:	00e682bb          	addw	t0,a3,a4
    3bfa:	33f5d28b          	th.surh	t0,a1,t6,1
    3bfe:	b265c38b          	th.lurhu	t2,a1,t1,1
    3c02:	00178f9b          	addiw	t6,a5,1
    3c06:	00e38e3b          	addw	t3,t2,a4
    3c0a:	3265de0b          	th.surh	t3,a1,t1,1
    3c0e:	b2f5ce8b          	th.lurhu	t4,a1,a5,1
    3c12:	001f831b          	addiw	t1,t6,1
    3c16:	00ee8f3b          	addw	t5,t4,a4
    3c1a:	32f5df0b          	th.surh	t5,a1,a5,1
    3c1e:	b3f5c68b          	th.lurhu	a3,a1,t6,1
    3c22:	0013079b          	addiw	a5,t1,1
    3c26:	00e682bb          	addw	t0,a3,a4
    3c2a:	33f5d28b          	th.surh	t0,a1,t6,1
    3c2e:	b265c38b          	th.lurhu	t2,a1,t1,1
    3c32:	00e38e3b          	addw	t3,t2,a4
    3c36:	3265de0b          	th.surh	t3,a1,t1,1
    3c3a:	b2f5ce8b          	th.lurhu	t4,a1,a5,1
    3c3e:	00ee8f3b          	addw	t5,t4,a4
    3c42:	32f5df0b          	th.surh	t5,a1,a5,1
    3c46:	2785                	addiw	a5,a5,1
    3c48:	b2f5c38b          	th.lurhu	t2,a1,a5,1
    3c4c:	00e38e3b          	addw	t3,t2,a4
    3c50:	32f5de0b          	th.surh	t3,a1,a5,1
    3c54:	2785                	addiw	a5,a5,1
    3c56:	f8f612e3          	bne	a2,a5,3bda <matrix_add_const+0xaa>
    3c5a:	2885                	addiw	a7,a7,1
    3c5c:	0105083b          	addw	a6,a0,a6
    3c60:	9e29                	addw	a2,a2,a0
    3c62:	ed151fe3          	bne	a0,a7,3b40 <matrix_add_const+0x10>
    3c66:	8082                	ret
    3c68:	00000013          	nop
    3c6c:	00000013          	nop

0000000000003c70 <matrix_mul_vect>:
    3c70:	7c053e8b          	th.extu	t4,a0,31,0
    3c74:	4881                	li	a7,0
    3c76:	4e01                	li	t3,0
    3c78:	16050d63          	beqz	a0,3df2 <matrix_mul_vect+0x182>
    3c7c:	00000013          	nop
    3c80:	007ef793          	andi	a5,t4,7
    3c84:	4701                	li	a4,0
    3c86:	4801                	li	a6,0
    3c88:	c7d5                	beqz	a5,3d34 <matrix_mul_vect+0xc4>
    3c8a:	4305                	li	t1,1
    3c8c:	08678663          	beq	a5,t1,3d18 <matrix_mul_vect+0xa8>
    3c90:	4f09                	li	t5,2
    3c92:	07e78a63          	beq	a5,t5,3d06 <matrix_mul_vect+0x96>
    3c96:	428d                	li	t0,3
    3c98:	04578e63          	beq	a5,t0,3cf4 <matrix_mul_vect+0x84>
    3c9c:	4391                	li	t2,4
    3c9e:	04778263          	beq	a5,t2,3ce2 <matrix_mul_vect+0x72>
    3ca2:	4f95                	li	t6,5
    3ca4:	03f78663          	beq	a5,t6,3cd0 <matrix_mul_vect+0x60>
    3ca8:	4f19                	li	t5,6
    3caa:	01e78a63          	beq	a5,t5,3cbe <matrix_mul_vect+0x4e>
    3cae:	b316428b          	th.lurhu	t0,a2,a7,1
    3cb2:	0006d783          	lhu	a5,0(a3)
    3cb6:	883a                	mv	a6,a4
    3cb8:	871a                	mv	a4,t1
    3cba:	28f2980b          	th.mulah	a6,t0,a5
    3cbe:	0117033b          	addw	t1,a4,a7
    3cc2:	a2e6cf8b          	th.lrhu	t6,a3,a4,1
    3cc6:	b266438b          	th.lurhu	t2,a2,t1,1
    3cca:	0705                	addi	a4,a4,1
    3ccc:	29f3980b          	th.mulah	a6,t2,t6
    3cd0:	01170f3b          	addw	t5,a4,a7
    3cd4:	a2e6c78b          	th.lrhu	a5,a3,a4,1
    3cd8:	b3e6428b          	th.lurhu	t0,a2,t5,1
    3cdc:	0705                	addi	a4,a4,1
    3cde:	28f2980b          	th.mulah	a6,t0,a5
    3ce2:	0117033b          	addw	t1,a4,a7
    3ce6:	a2e6cf8b          	th.lrhu	t6,a3,a4,1
    3cea:	b266438b          	th.lurhu	t2,a2,t1,1
    3cee:	0705                	addi	a4,a4,1
    3cf0:	29f3980b          	th.mulah	a6,t2,t6
    3cf4:	01170f3b          	addw	t5,a4,a7
    3cf8:	a2e6c78b          	th.lrhu	a5,a3,a4,1
    3cfc:	b3e6428b          	th.lurhu	t0,a2,t5,1
    3d00:	0705                	addi	a4,a4,1
    3d02:	28f2980b          	th.mulah	a6,t0,a5
    3d06:	0117033b          	addw	t1,a4,a7
    3d0a:	a2e6cf8b          	th.lrhu	t6,a3,a4,1
    3d0e:	b266438b          	th.lurhu	t2,a2,t1,1
    3d12:	0705                	addi	a4,a4,1
    3d14:	29f3980b          	th.mulah	a6,t2,t6
    3d18:	01170f3b          	addw	t5,a4,a7
    3d1c:	a2e6c30b          	th.lrhu	t1,a3,a4,1
    3d20:	b3e6428b          	th.lurhu	t0,a2,t5,1
    3d24:	87c2                	mv	a5,a6
    3d26:	83ba                	mv	t2,a4
    3d28:	2862978b          	th.mulah	a5,t0,t1
    3d2c:	0705                	addi	a4,a4,1
    3d2e:	883e                	mv	a6,a5
    3d30:	0aee8563          	beq	t4,a4,3dda <matrix_mul_vect+0x16a>
    3d34:	01170fbb          	addw	t6,a4,a7
    3d38:	b3f64f0b          	th.lurhu	t5,a2,t6,1
    3d3c:	a2e6c28b          	th.lrhu	t0,a3,a4,1
    3d40:	87c2                	mv	a5,a6
    3d42:	00170813          	addi	a6,a4,1
    3d46:	285f178b          	th.mulah	a5,t5,t0
    3d4a:	0118033b          	addw	t1,a6,a7
    3d4e:	b266438b          	th.lurhu	t2,a2,t1,1
    3d52:	a306cf8b          	th.lrhu	t6,a3,a6,1
    3d56:	00270f13          	addi	t5,a4,2
    3d5a:	011f02bb          	addw	t0,t5,a7
    3d5e:	29f3978b          	th.mulah	a5,t2,t6
    3d62:	b256430b          	th.lurhu	t1,a2,t0,1
    3d66:	a3e6c80b          	th.lrhu	a6,a3,t5,1
    3d6a:	00370393          	addi	t2,a4,3
    3d6e:	01138fbb          	addw	t6,t2,a7
    3d72:	2903178b          	th.mulah	a5,t1,a6
    3d76:	b3f64f0b          	th.lurhu	t5,a2,t6,1
    3d7a:	a276c28b          	th.lrhu	t0,a3,t2,1
    3d7e:	00470813          	addi	a6,a4,4
    3d82:	0118033b          	addw	t1,a6,a7
    3d86:	285f178b          	th.mulah	a5,t5,t0
    3d8a:	b266438b          	th.lurhu	t2,a2,t1,1
    3d8e:	a306cf8b          	th.lrhu	t6,a3,a6,1
    3d92:	00570f13          	addi	t5,a4,5
    3d96:	011f02bb          	addw	t0,t5,a7
    3d9a:	29f3978b          	th.mulah	a5,t2,t6
    3d9e:	b256430b          	th.lurhu	t1,a2,t0,1
    3da2:	a3e6c80b          	th.lrhu	a6,a3,t5,1
    3da6:	00670393          	addi	t2,a4,6
    3daa:	01138fbb          	addw	t6,t2,a7
    3dae:	2903178b          	th.mulah	a5,t1,a6
    3db2:	b3f64f0b          	th.lurhu	t5,a2,t6,1
    3db6:	a276c28b          	th.lrhu	t0,a3,t2,1
    3dba:	00770393          	addi	t2,a4,7
    3dbe:	0113833b          	addw	t1,t2,a7
    3dc2:	285f178b          	th.mulah	a5,t5,t0
    3dc6:	a276c80b          	th.lrhu	a6,a3,t2,1
    3dca:	b2664f8b          	th.lurhu	t6,a2,t1,1
    3dce:	0721                	addi	a4,a4,8
    3dd0:	290f978b          	th.mulah	a5,t6,a6
    3dd4:	883e                	mv	a6,a5
    3dd6:	f4ee9fe3          	bne	t4,a4,3d34 <matrix_mul_vect+0xc4>
    3dda:	45c5d78b          	th.srw	a5,a1,t3,2
    3dde:	011508bb          	addw	a7,a0,a7
    3de2:	001e0793          	addi	a5,t3,1
    3de6:	007e0563          	beq	t3,t2,3df0 <matrix_mul_vect+0x180>
    3dea:	8e3e                	mv	t3,a5
    3dec:	bd51                	j	3c80 <matrix_mul_vect+0x10>
    3dee:	0001                	nop
    3df0:	8082                	ret
    3df2:	8082                	ret
    3df4:	00000013          	nop
    3df8:	00000013          	nop
    3dfc:	00000013          	nop

0000000000003e00 <matrix_mul_matrix>:
    3e00:	8eae                	mv	t4,a1
    3e02:	8832                	mv	a6,a2
    3e04:	85b6                	mv	a1,a3
    3e06:	832a                	mv	t1,a0
    3e08:	4e01                	li	t3,0
    3e0a:	4f81                	li	t6,0
    3e0c:	cd69                	beqz	a0,3ee6 <matrix_mul_matrix+0xe6>
    3e0e:	0001                	nop
    3e10:	4881                	li	a7,0
    3e12:	0001                	nop
    3e14:	00000013          	nop
    3e18:	41c30633          	sub	a2,t1,t3
    3e1c:	00367393          	andi	t2,a2,3
    3e20:	01c88f3b          	addw	t5,a7,t3
    3e24:	86c6                	mv	a3,a7
    3e26:	87f2                	mv	a5,t3
    3e28:	4701                	li	a4,0
    3e2a:	04038663          	beqz	t2,3e76 <matrix_mul_matrix+0x76>
    3e2e:	4285                	li	t0,1
    3e30:	02538763          	beq	t2,t0,3e5e <matrix_mul_matrix+0x5e>
    3e34:	4609                	li	a2,2
    3e36:	00c38c63          	beq	t2,a2,3e4e <matrix_mul_matrix+0x4e>
    3e3a:	b3c8468b          	th.lurhu	a3,a6,t3,1
    3e3e:	b315c78b          	th.lurhu	a5,a1,a7,1
    3e42:	28f6970b          	th.mulah	a4,a3,a5
    3e46:	001e079b          	addiw	a5,t3,1
    3e4a:	011506bb          	addw	a3,a0,a7
    3e4e:	b2f8438b          	th.lurhu	t2,a6,a5,1
    3e52:	b2d5c28b          	th.lurhu	t0,a1,a3,1
    3e56:	2785                	addiw	a5,a5,1
    3e58:	9ea9                	addw	a3,a3,a0
    3e5a:	2853970b          	th.mulah	a4,t2,t0
    3e5e:	b2f8438b          	th.lurhu	t2,a6,a5,1
    3e62:	b2d5c28b          	th.lurhu	t0,a1,a3,1
    3e66:	863a                	mv	a2,a4
    3e68:	2785                	addiw	a5,a5,1
    3e6a:	2853960b          	th.mulah	a2,t2,t0
    3e6e:	9ea9                	addw	a3,a3,a0
    3e70:	8732                	mv	a4,a2
    3e72:	04f30663          	beq	t1,a5,3ebe <matrix_mul_matrix+0xbe>
    3e76:	b2f8438b          	th.lurhu	t2,a6,a5,1
    3e7a:	b2d5c28b          	th.lurhu	t0,a1,a3,1
    3e7e:	2785                	addiw	a5,a5,1
    3e80:	9ea9                	addw	a3,a3,a0
    3e82:	2853970b          	th.mulah	a4,t2,t0
    3e86:	b2d5c60b          	th.lurhu	a2,a1,a3,1
    3e8a:	b2f8438b          	th.lurhu	t2,a6,a5,1
    3e8e:	9ea9                	addw	a3,a3,a0
    3e90:	2785                	addiw	a5,a5,1
    3e92:	28c3970b          	th.mulah	a4,t2,a2
    3e96:	b2f8428b          	th.lurhu	t0,a6,a5,1
    3e9a:	b2d5c38b          	th.lurhu	t2,a1,a3,1
    3e9e:	2785                	addiw	a5,a5,1
    3ea0:	9ea9                	addw	a3,a3,a0
    3ea2:	2872970b          	th.mulah	a4,t0,t2
    3ea6:	b2f8428b          	th.lurhu	t0,a6,a5,1
    3eaa:	2785                	addiw	a5,a5,1
    3eac:	863a                	mv	a2,a4
    3eae:	b2d5c70b          	th.lurhu	a4,a1,a3,1
    3eb2:	9ea9                	addw	a3,a3,a0
    3eb4:	28e2960b          	th.mulah	a2,t0,a4
    3eb8:	8732                	mv	a4,a2
    3eba:	faf31ee3          	bne	t1,a5,3e76 <matrix_mul_matrix+0x76>
    3ebe:	55eed60b          	th.surw	a2,t4,t5,2
    3ec2:	00188f1b          	addiw	t5,a7,1
    3ec6:	01e50563          	beq	a0,t5,3ed0 <matrix_mul_matrix+0xd0>
    3eca:	88fa                	mv	a7,t5
    3ecc:	b7b1                	j	3e18 <matrix_mul_matrix+0x18>
    3ece:	0001                	nop
    3ed0:	001f861b          	addiw	a2,t6,1
    3ed4:	01c50e3b          	addw	t3,a0,t3
    3ed8:	0065033b          	addw	t1,a0,t1
    3edc:	011f8463          	beq	t6,a7,3ee4 <matrix_mul_matrix+0xe4>
    3ee0:	8fb2                	mv	t6,a2
    3ee2:	b73d                	j	3e10 <matrix_mul_matrix+0x10>
    3ee4:	8082                	ret
    3ee6:	8082                	ret
    3ee8:	00000013          	nop
    3eec:	00000013          	nop

0000000000003ef0 <matrix_mul_matrix_bitextract>:
    3ef0:	8eae                	mv	t4,a1
    3ef2:	8832                	mv	a6,a2
    3ef4:	85b6                	mv	a1,a3
    3ef6:	832a                	mv	t1,a0
    3ef8:	4e01                	li	t3,0
    3efa:	4f81                	li	t6,0
    3efc:	12050763          	beqz	a0,402a <matrix_mul_matrix_bitextract+0x13a>
    3f00:	4881                	li	a7,0
    3f02:	0001                	nop
    3f04:	00000013          	nop
    3f08:	41c30733          	sub	a4,t1,t3
    3f0c:	00377393          	andi	t2,a4,3
    3f10:	01c88f3b          	addw	t5,a7,t3
    3f14:	86c6                	mv	a3,a7
    3f16:	87f2                	mv	a5,t3
    3f18:	4281                	li	t0,0
    3f1a:	06038863          	beqz	t2,3f8a <matrix_mul_matrix_bitextract+0x9a>
    3f1e:	4605                	li	a2,1
    3f20:	04c38363          	beq	t2,a2,3f66 <matrix_mul_matrix_bitextract+0x76>
    3f24:	4709                	li	a4,2
    3f26:	02e38263          	beq	t2,a4,3f4a <matrix_mul_matrix_bitextract+0x5a>
    3f2a:	33c8478b          	th.lurh	a5,a6,t3,1
    3f2e:	3315c28b          	th.lurh	t0,a1,a7,1
    3f32:	025786bb          	mulw	a3,a5,t0
    3f36:	001e079b          	addiw	a5,t3,1
    3f3a:	1426b38b          	th.extu	t2,a3,5,2
    3f3e:	2c56b60b          	th.extu	a2,a3,11,5
    3f42:	02c382bb          	mulw	t0,t2,a2
    3f46:	011506bb          	addw	a3,a0,a7
    3f4a:	32d5c38b          	th.lurh	t2,a1,a3,1
    3f4e:	32f8470b          	th.lurh	a4,a6,a5,1
    3f52:	9ea9                	addw	a3,a3,a0
    3f54:	2785                	addiw	a5,a5,1
    3f56:	0277073b          	mulw	a4,a4,t2
    3f5a:	1427360b          	th.extu	a2,a4,5,2
    3f5e:	2c57338b          	th.extu	t2,a4,11,5
    3f62:	2476128b          	th.mulaw	t0,a2,t2
    3f66:	32d5c60b          	th.lurh	a2,a1,a3,1
    3f6a:	32f8470b          	th.lurh	a4,a6,a5,1
    3f6e:	2785                	addiw	a5,a5,1
    3f70:	9ea9                	addw	a3,a3,a0
    3f72:	02c7073b          	mulw	a4,a4,a2
    3f76:	1427338b          	th.extu	t2,a4,5,2
    3f7a:	2c57360b          	th.extu	a2,a4,11,5
    3f7e:	8716                	mv	a4,t0
    3f80:	24c3970b          	th.mulaw	a4,t2,a2
    3f84:	82ba                	mv	t0,a4
    3f86:	06f30e63          	beq	t1,a5,4002 <matrix_mul_matrix_bitextract+0x112>
    3f8a:	32f8438b          	th.lurh	t2,a6,a5,1
    3f8e:	32d5c60b          	th.lurh	a2,a1,a3,1
    3f92:	2785                	addiw	a5,a5,1
    3f94:	9ea9                	addw	a3,a3,a0
    3f96:	02c3873b          	mulw	a4,t2,a2
    3f9a:	1427338b          	th.extu	t2,a4,5,2
    3f9e:	2c57360b          	th.extu	a2,a4,11,5
    3fa2:	8716                	mv	a4,t0
    3fa4:	24c3970b          	th.mulaw	a4,t2,a2
    3fa8:	32d5c28b          	th.lurh	t0,a1,a3,1
    3fac:	32f8438b          	th.lurh	t2,a6,a5,1
    3fb0:	9ea9                	addw	a3,a3,a0
    3fb2:	2785                	addiw	a5,a5,1
    3fb4:	0253863b          	mulw	a2,t2,t0
    3fb8:	1426338b          	th.extu	t2,a2,5,2
    3fbc:	2c56328b          	th.extu	t0,a2,11,5
    3fc0:	2453970b          	th.mulaw	a4,t2,t0
    3fc4:	32f8460b          	th.lurh	a2,a6,a5,1
    3fc8:	32d5c38b          	th.lurh	t2,a1,a3,1
    3fcc:	2785                	addiw	a5,a5,1
    3fce:	9ea9                	addw	a3,a3,a0
    3fd0:	0276063b          	mulw	a2,a2,t2
    3fd4:	1426328b          	th.extu	t0,a2,5,2
    3fd8:	2c56338b          	th.extu	t2,a2,11,5
    3fdc:	2472970b          	th.mulaw	a4,t0,t2
    3fe0:	32f8460b          	th.lurh	a2,a6,a5,1
    3fe4:	32d5c28b          	th.lurh	t0,a1,a3,1
    3fe8:	2785                	addiw	a5,a5,1
    3fea:	9ea9                	addw	a3,a3,a0
    3fec:	025603bb          	mulw	t2,a2,t0
    3ff0:	1423b28b          	th.extu	t0,t2,5,2
    3ff4:	2c53b60b          	th.extu	a2,t2,11,5
    3ff8:	24c2970b          	th.mulaw	a4,t0,a2
    3ffc:	82ba                	mv	t0,a4
    3ffe:	f8f316e3          	bne	t1,a5,3f8a <matrix_mul_matrix_bitextract+0x9a>
    4002:	55eed70b          	th.surw	a4,t4,t5,2
    4006:	00188f1b          	addiw	t5,a7,1
    400a:	01e50563          	beq	a0,t5,4014 <matrix_mul_matrix_bitextract+0x124>
    400e:	88fa                	mv	a7,t5
    4010:	bde5                	j	3f08 <matrix_mul_matrix_bitextract+0x18>
    4012:	0001                	nop
    4014:	001f871b          	addiw	a4,t6,1
    4018:	01c50e3b          	addw	t3,a0,t3
    401c:	0065033b          	addw	t1,a0,t1
    4020:	011f8463          	beq	t6,a7,4028 <matrix_mul_matrix_bitextract+0x138>
    4024:	8fba                	mv	t6,a4
    4026:	bde9                	j	3f00 <matrix_mul_matrix_bitextract+0x10>
    4028:	8082                	ret
    402a:	8082                	ret
    402c:	0000                	unimp
	...

0000000000004030 <barebones_clock>:
    4030:	000417b7          	lui	a5,0x41
    4034:	fc878293          	addi	t0,a5,-56 # 40fc8 <stop_time_val>
    4038:	0002a503          	lw	a0,0(t0)
    403c:	0042a303          	lw	t1,4(t0)
    4040:	4065053b          	subw	a0,a0,t1
    4044:	8082                	ret
    4046:	00000013          	nop
    404a:	00000013          	nop
    404e:	0001                	nop

0000000000004050 <start_time>:
    4050:	000417b7          	lui	a5,0x41
    4054:	fc878293          	addi	t0,a5,-56 # 40fc8 <stop_time_val>
    4058:	e0d2c70b          	th.lwd	a4,a3,(t0),0,3
    405c:	40d7033b          	subw	t1,a4,a3
    4060:	0062a223          	sw	t1,4(t0)
    4064:	8082                	ret
    4066:	00000013          	nop
    406a:	00000013          	nop
    406e:	0001                	nop

0000000000004070 <stop_time>:
    4070:	000417b7          	lui	a5,0x41
    4074:	fc878293          	addi	t0,a5,-56 # 40fc8 <stop_time_val>
    4078:	e0d2c70b          	th.lwd	a4,a3,(t0),0,3
    407c:	40d7033b          	subw	t1,a4,a3
    4080:	0062a023          	sw	t1,0(t0)
    4084:	8082                	ret
    4086:	00000013          	nop
    408a:	00000013          	nop
    408e:	0001                	nop

0000000000004090 <get_time>:
    4090:	000417b7          	lui	a5,0x41
    4094:	fc878293          	addi	t0,a5,-56 # 40fc8 <stop_time_val>
    4098:	0002a503          	lw	a0,0(t0)
    409c:	0042a303          	lw	t1,4(t0)
    40a0:	4065053b          	subw	a0,a0,t1
    40a4:	8082                	ret
    40a6:	00000013          	nop
    40aa:	00000013          	nop
    40ae:	0001                	nop

00000000000040b0 <time_in_secs>:
    40b0:	05f5e7b7          	lui	a5,0x5f5e
    40b4:	1007829b          	addiw	t0,a5,256 # 5f5e100 <__kernel_stack+0x5e70100>
    40b8:	0255553b          	divuw	a0,a0,t0
    40bc:	8082                	ret
    40be:	0001                	nop

00000000000040c0 <portable_init>:
    40c0:	000417b7          	lui	a5,0x41
    40c4:	fc878293          	addi	t0,a5,-56 # 40fc8 <stop_time_val>
    40c8:	e0d2c70b          	th.lwd	a4,a3,(t0),0,3
    40cc:	4385                	li	t2,1
    40ce:	00750023          	sb	t2,0(a0)
    40d2:	40d7033b          	subw	t1,a4,a3
    40d6:	0062a223          	sw	t1,4(t0)
    40da:	8082                	ret
    40dc:	00000013          	nop

00000000000040e0 <portable_fini>:
    40e0:	00050023          	sb	zero,0(a0)
    40e4:	8082                	ret
	...

00000000000040f0 <core_bench_state>:
    40f0:	7131                	addi	sp,sp,-192
    40f2:	8fae                	mv	t6,a1
    40f4:	ecee                	sd	s11,88(sp)
    40f6:	f0ea                	sd	s10,96(sp)
    40f8:	f4e6                	sd	s9,104(sp)
    40fa:	f8e2                	sd	s8,112(sp)
    40fc:	fcde                	sd	s7,120(sp)
    40fe:	e15a                	sd	s6,128(sp)
    4100:	e556                	sd	s5,136(sp)
    4102:	e952                	sd	s4,144(sp)
    4104:	ed4e                	sd	s3,152(sp)
    4106:	f14a                	sd	s2,160(sp)
    4108:	f526                	sd	s1,168(sp)
    410a:	f922                	sd	s0,176(sp)
    410c:	fd06                	sd	ra,184(sp)
    410e:	000fce03          	lbu	t3,0(t6)
    4112:	e802                	sd	zero,16(sp)
    4114:	ec02                	sd	zero,24(sp)
    4116:	f002                	sd	zero,32(sp)
    4118:	f402                	sd	zero,40(sp)
    411a:	f802                	sd	zero,48(sp)
    411c:	fc02                	sd	zero,56(sp)
    411e:	e082                	sd	zero,64(sp)
    4120:	e482                	sd	zero,72(sp)
    4122:	e03a                	sd	a4,0(sp)
    4124:	8eaa                	mv	t4,a0
    4126:	85be                	mv	a1,a5
    4128:	8a36                	mv	s4,a3
    412a:	700e0263          	beqz	t3,482e <core_bench_state+0x73e>
    412e:	877e                	mv	a4,t6
    4130:	87f2                	mv	a5,t3
    4132:	4881                	li	a7,0
    4134:	4901                	li	s2,0
    4136:	4281                	li	t0,0
    4138:	4401                	li	s0,0
    413a:	4381                	li	t2,0
    413c:	4b01                	li	s6,0
    413e:	4c01                	li	s8,0
    4140:	4c81                	li	s9,0
    4142:	4981                	li	s3,0
    4144:	4481                	li	s1,0
    4146:	4501                	li	a0,0
    4148:	4a81                	li	s5,0
    414a:	4d01                	li	s10,0
    414c:	4b81                	li	s7,0
    414e:	01010813          	addi	a6,sp,16
    4152:	02c00313          	li	t1,44
    4156:	02e00693          	li	a3,46
    415a:	04500d93          	li	s11,69
    415e:	4f25                	li	t5,9
    4160:	e472                	sd	t3,8(sp)
    4162:	0001                	nop
    4164:	00000013          	nop
    4168:	72678f63          	beq	a5,t1,48a6 <core_bench_state+0x7b6>
    416c:	30d78e63          	beq	a5,a3,4488 <core_bench_state+0x398>
    4170:	1af6e863          	bltu	a3,a5,4320 <core_bench_state+0x230>
    4174:	fd578e1b          	addiw	t3,a5,-43
    4178:	0fde7793          	andi	a5,t3,253
    417c:	2c078263          	beqz	a5,4440 <core_bench_state+0x350>
    4180:	4505                	li	a0,1
    4182:	2b85                	addiw	s7,s7,1
    4184:	2a85                	addiw	s5,s5,1
    4186:	0705                	addi	a4,a4,1
    4188:	8d2a                	mv	s10,a0
    418a:	87aa                	mv	a5,a0
    418c:	00000013          	nop
    4190:	54f84e0b          	th.lurw	t3,a6,a5,2
    4194:	2e05                	addiw	t3,t3,1
    4196:	54f85e0b          	th.surw	t3,a6,a5,2
    419a:	00074783          	lbu	a5,0(a4)
    419e:	f7e9                	bnez	a5,4168 <core_bench_state+0x78>
    41a0:	6e22                	ld	t3,8(sp)
    41a2:	00088363          	beqz	a7,41a8 <core_bench_state+0xb8>
    41a6:	c4ca                	sw	s2,72(sp)
    41a8:	00028363          	beqz	t0,41ae <core_bench_state+0xbe>
    41ac:	de22                	sw	s0,60(sp)
    41ae:	00038363          	beqz	t2,41b4 <core_bench_state+0xc4>
    41b2:	c2da                	sw	s6,68(sp)
    41b4:	000c0363          	beqz	s8,41ba <core_bench_state+0xca>
    41b8:	c0e6                	sw	s9,64(sp)
    41ba:	00098363          	beqz	s3,41c0 <core_bench_state+0xd0>
    41be:	dc26                	sw	s1,56(sp)
    41c0:	c111                	beqz	a0,41c4 <core_bench_state+0xd4>
    41c2:	d856                	sw	s5,48(sp)
    41c4:	000d0363          	beqz	s10,41ca <core_bench_state+0xda>
    41c8:	da5e                	sw	s7,52(sp)
    41ca:	7c0eba8b          	th.extu	s5,t4,31,0
    41ce:	015f8333          	add	t1,t6,s5
    41d2:	2e6ff463          	bgeu	t6,t1,44ba <core_bench_state+0x3ca>
    41d6:	6982                	ld	s3,0(sp)
    41d8:	4485                	li	s1,1
    41da:	8dfe                	mv	s11,t6
    41dc:	72999c63          	bne	s3,s1,4914 <core_bench_state+0x824>
    41e0:	ffffcf13          	not	t5,t6
    41e4:	01e30c33          	add	s8,t1,t5
    41e8:	007c7b13          	andi	s6,s8,7
    41ec:	02c00e93          	li	t4,44
    41f0:	0a0b0063          	beqz	s6,4290 <core_bench_state+0x1a0>
    41f4:	01de0663          	beq	t3,t4,4200 <core_bench_state+0x110>
    41f8:	00ce4733          	xor	a4,t3,a2
    41fc:	00ef8023          	sb	a4,0(t6)
    4200:	001f8d93          	addi	s11,t6,1
    4204:	2a6df763          	bgeu	s11,t1,44b2 <core_bench_state+0x3c2>
    4208:	4405                	li	s0,1
    420a:	000dce03          	lbu	t3,0(s11)
    420e:	088b0163          	beq	s6,s0,4290 <core_bench_state+0x1a0>
    4212:	4509                	li	a0,2
    4214:	06ab0663          	beq	s6,a0,4280 <core_bench_state+0x190>
    4218:	490d                	li	s2,3
    421a:	052b0b63          	beq	s6,s2,4270 <core_bench_state+0x180>
    421e:	4b91                	li	s7,4
    4220:	057b0063          	beq	s6,s7,4260 <core_bench_state+0x170>
    4224:	4d15                	li	s10,5
    4226:	03ab0563          	beq	s6,s10,4250 <core_bench_state+0x160>
    422a:	4899                	li	a7,6
    422c:	011b0a63          	beq	s6,a7,4240 <core_bench_state+0x150>
    4230:	01de0663          	beq	t3,t4,423c <core_bench_state+0x14c>
    4234:	00ce42b3          	xor	t0,t3,a2
    4238:	005d8023          	sb	t0,0(s11)
    423c:	881dce0b          	th.lbuib	t3,(s11),1,0
    4240:	01de0663          	beq	t3,t4,424c <core_bench_state+0x15c>
    4244:	00ce43b3          	xor	t2,t3,a2
    4248:	007d8023          	sb	t2,0(s11)
    424c:	881dce0b          	th.lbuib	t3,(s11),1,0
    4250:	01de0663          	beq	t3,t4,425c <core_bench_state+0x16c>
    4254:	00ce4e33          	xor	t3,t3,a2
    4258:	01cd8023          	sb	t3,0(s11)
    425c:	881dce0b          	th.lbuib	t3,(s11),1,0
    4260:	01de0663          	beq	t3,t4,426c <core_bench_state+0x17c>
    4264:	00ce4ab3          	xor	s5,t3,a2
    4268:	015d8023          	sb	s5,0(s11)
    426c:	881dce0b          	th.lbuib	t3,(s11),1,0
    4270:	01de0663          	beq	t3,t4,427c <core_bench_state+0x18c>
    4274:	00ce44b3          	xor	s1,t3,a2
    4278:	009d8023          	sb	s1,0(s11)
    427c:	881dce0b          	th.lbuib	t3,(s11),1,0
    4280:	01de0663          	beq	t3,t4,428c <core_bench_state+0x19c>
    4284:	00ce49b3          	xor	s3,t3,a2
    4288:	013d8023          	sb	s3,0(s11)
    428c:	881dce0b          	th.lbuib	t3,(s11),1,0
    4290:	01de0663          	beq	t3,t4,429c <core_bench_state+0x1ac>
    4294:	00ce4cb3          	xor	s9,t3,a2
    4298:	019d8023          	sb	s9,0(s11)
    429c:	001d8693          	addi	a3,s11,1
    42a0:	2066f963          	bgeu	a3,t1,44b2 <core_bench_state+0x3c2>
    42a4:	001dc503          	lbu	a0,1(s11)
    42a8:	01d50663          	beq	a0,t4,42b4 <core_bench_state+0x1c4>
    42ac:	00c548b3          	xor	a7,a0,a2
    42b0:	011d80a3          	sb	a7,1(s11)
    42b4:	0016cd83          	lbu	s11,1(a3)
    42b8:	01dd8663          	beq	s11,t4,42c4 <core_bench_state+0x1d4>
    42bc:	00cdc7b3          	xor	a5,s11,a2
    42c0:	00f680a3          	sb	a5,1(a3)
    42c4:	0026c983          	lbu	s3,2(a3)
    42c8:	01d98663          	beq	s3,t4,42d4 <core_bench_state+0x1e4>
    42cc:	00c9c433          	xor	s0,s3,a2
    42d0:	00868123          	sb	s0,2(a3)
    42d4:	0036c903          	lbu	s2,3(a3)
    42d8:	01d90663          	beq	s2,t4,42e4 <core_bench_state+0x1f4>
    42dc:	00c94c33          	xor	s8,s2,a2
    42e0:	018681a3          	sb	s8,3(a3)
    42e4:	0046ce03          	lbu	t3,4(a3)
    42e8:	01de0663          	beq	t3,t4,42f4 <core_bench_state+0x204>
    42ec:	00ce4d33          	xor	s10,t3,a2
    42f0:	01a68223          	sb	s10,4(a3)
    42f4:	0056cb83          	lbu	s7,5(a3)
    42f8:	01db8663          	beq	s7,t4,4304 <core_bench_state+0x214>
    42fc:	00cbcab3          	xor	s5,s7,a2
    4300:	015682a3          	sb	s5,5(a3)
    4304:	0066c703          	lbu	a4,6(a3)
    4308:	01d70663          	beq	a4,t4,4314 <core_bench_state+0x224>
    430c:	00c74f33          	xor	t5,a4,a2
    4310:	01e68323          	sb	t5,6(a3)
    4314:	0076ce03          	lbu	t3,7(a3)
    4318:	00768d93          	addi	s11,a3,7
    431c:	bf95                	j	4290 <core_bench_state+0x1a0>
    431e:	0001                	nop
    4320:	fd07879b          	addiw	a5,a5,-48
    4324:	0ff7f513          	zext.b	a0,a5
    4328:	e4af6ce3          	bltu	t5,a0,4180 <core_bench_state+0x90>
    432c:	8817478b          	th.lbuib	a5,(a4),1,0
    4330:	2a85                	addiw	s5,s5,1
    4332:	cbf5                	beqz	a5,4426 <core_bench_state+0x336>
    4334:	58678063          	beq	a5,t1,48b4 <core_bench_state+0x7c4>
    4338:	00d78e63          	beq	a5,a3,4354 <core_bench_state+0x264>
    433c:	fd078e1b          	addiw	t3,a5,-48
    4340:	0ffe7513          	zext.b	a0,t3
    4344:	0caf7e63          	bgeu	t5,a0,4420 <core_bench_state+0x330>
    4348:	4c05                	li	s8,1
    434a:	2c85                	addiw	s9,s9,1
    434c:	0705                	addi	a4,a4,1
    434e:	8562                	mv	a0,s8
    4350:	87e2                	mv	a5,s8
    4352:	bd3d                	j	4190 <core_bench_state+0xa0>
    4354:	00174503          	lbu	a0,1(a4)
    4358:	2c85                	addiw	s9,s9,1
    435a:	00170e13          	addi	t3,a4,1
    435e:	60050b63          	beqz	a0,4974 <core_bench_state+0x884>
    4362:	60650f63          	beq	a0,t1,4980 <core_bench_state+0x890>
    4366:	4c05                	li	s8,1
    4368:	0df57713          	andi	a4,a0,223
    436c:	03b70063          	beq	a4,s11,438c <core_bench_state+0x29c>
    4370:	fd05051b          	addiw	a0,a0,-48
    4374:	0ff57793          	zext.b	a5,a0
    4378:	0aff7a63          	bgeu	t5,a5,442c <core_bench_state+0x33c>
    437c:	4385                	li	t2,1
    437e:	2b05                	addiw	s6,s6,1
    4380:	001e0713          	addi	a4,t3,1
    4384:	851e                	mv	a0,t2
    4386:	879e                	mv	a5,t2
    4388:	b521                	j	4190 <core_bench_state+0xa0>
    438a:	0001                	nop
    438c:	001e4383          	lbu	t2,1(t3)
    4390:	2b05                	addiw	s6,s6,1
    4392:	001e0713          	addi	a4,t3,1
    4396:	56038263          	beqz	t2,48fa <core_bench_state+0x80a>
    439a:	5a638c63          	beq	t2,t1,4952 <core_bench_state+0x862>
    439e:	fd53829b          	addiw	t0,t2,-43
    43a2:	0fd2f793          	andi	a5,t0,253
    43a6:	2405                	addiw	s0,s0,1
    43a8:	002e0713          	addi	a4,t3,2
    43ac:	c791                	beqz	a5,43b8 <core_bench_state+0x2c8>
    43ae:	4285                	li	t0,1
    43b0:	8396                	mv	t2,t0
    43b2:	8516                	mv	a0,t0
    43b4:	8796                	mv	a5,t0
    43b6:	bbe9                	j	4190 <core_bench_state+0xa0>
    43b8:	002e4503          	lbu	a0,2(t3)
    43bc:	54050363          	beqz	a0,4902 <core_bench_state+0x812>
    43c0:	58650363          	beq	a0,t1,4946 <core_bench_state+0x856>
    43c4:	fd05089b          	addiw	a7,a0,-48
    43c8:	0ff8f393          	zext.b	t2,a7
    43cc:	2905                	addiw	s2,s2,1
    43ce:	003e0713          	addi	a4,t3,3
    43d2:	007f7963          	bgeu	t5,t2,43e4 <core_bench_state+0x2f4>
    43d6:	4885                	li	a7,1
    43d8:	82c6                	mv	t0,a7
    43da:	83c6                	mv	t2,a7
    43dc:	8546                	mv	a0,a7
    43de:	87c6                	mv	a5,a7
    43e0:	bb45                	j	4190 <core_bench_state+0xa0>
    43e2:	0001                	nop
    43e4:	003e4783          	lbu	a5,3(t3)
    43e8:	c78d                	beqz	a5,4412 <core_bench_state+0x322>
    43ea:	4a678463          	beq	a5,t1,4892 <core_bench_state+0x7a2>
    43ee:	fd078e1b          	addiw	t3,a5,-48
    43f2:	0ffe7293          	zext.b	t0,t3
    43f6:	005f7b63          	bgeu	t5,t0,440c <core_bench_state+0x31c>
    43fa:	4885                	li	a7,1
    43fc:	2b85                	addiw	s7,s7,1
    43fe:	0705                	addi	a4,a4,1
    4400:	82c6                	mv	t0,a7
    4402:	83c6                	mv	t2,a7
    4404:	8546                	mv	a0,a7
    4406:	8d46                	mv	s10,a7
    4408:	87c6                	mv	a5,a7
    440a:	b359                	j	4190 <core_bench_state+0xa0>
    440c:	8817478b          	th.lbuib	a5,(a4),1,0
    4410:	ffe9                	bnez	a5,43ea <core_bench_state+0x2fa>
    4412:	4885                	li	a7,1
    4414:	82c6                	mv	t0,a7
    4416:	83c6                	mv	t2,a7
    4418:	8546                	mv	a0,a7
    441a:	479d                	li	a5,7
    441c:	bb95                	j	4190 <core_bench_state+0xa0>
    441e:	0001                	nop
    4420:	8817478b          	th.lbuib	a5,(a4),1,0
    4424:	fb81                	bnez	a5,4334 <core_bench_state+0x244>
    4426:	4505                	li	a0,1
    4428:	4791                	li	a5,4
    442a:	b39d                	j	4190 <core_bench_state+0xa0>
    442c:	881e450b          	th.lbuib	a0,(t3),1,0
    4430:	c135                	beqz	a0,4494 <core_bench_state+0x3a4>
    4432:	f2651be3          	bne	a0,t1,4368 <core_bench_state+0x278>
    4436:	8772                	mv	a4,t3
    4438:	4505                	li	a0,1
    443a:	4795                	li	a5,5
    443c:	0705                	addi	a4,a4,1
    443e:	bb89                	j	4190 <core_bench_state+0xa0>
    4440:	00174503          	lbu	a0,1(a4)
    4444:	2a85                	addiw	s5,s5,1
    4446:	00170e13          	addi	t3,a4,1
    444a:	56050763          	beqz	a0,49b8 <core_bench_state+0x8c8>
    444e:	54650f63          	beq	a0,t1,49ac <core_bench_state+0x8bc>
    4452:	fd05099b          	addiw	s3,a0,-48
    4456:	0ff9f793          	zext.b	a5,s3
    445a:	00ff7b63          	bgeu	t5,a5,4470 <core_bench_state+0x380>
    445e:	02d50f63          	beq	a0,a3,449c <core_bench_state+0x3ac>
    4462:	4985                	li	s3,1
    4464:	2485                	addiw	s1,s1,1
    4466:	0709                	addi	a4,a4,2
    4468:	854e                	mv	a0,s3
    446a:	87ce                	mv	a5,s3
    446c:	b315                	j	4190 <core_bench_state+0xa0>
    446e:	0001                	nop
    4470:	8827478b          	th.lbuib	a5,(a4),2,0
    4474:	2485                	addiw	s1,s1,1
    4476:	4985                	li	s3,1
    4478:	4e078563          	beqz	a5,4962 <core_bench_state+0x872>
    447c:	ea679ee3          	bne	a5,t1,4338 <core_bench_state+0x248>
    4480:	854e                	mv	a0,s3
    4482:	4791                	li	a5,4
    4484:	0705                	addi	a4,a4,1
    4486:	b329                	j	4190 <core_bench_state+0xa0>
    4488:	00174503          	lbu	a0,1(a4)
    448c:	2a85                	addiw	s5,s5,1
    448e:	00170e13          	addi	t3,a4,1
    4492:	f145                	bnez	a0,4432 <core_bench_state+0x342>
    4494:	8772                	mv	a4,t3
    4496:	4505                	li	a0,1
    4498:	4795                	li	a5,5
    449a:	b9dd                	j	4190 <core_bench_state+0xa0>
    449c:	00274503          	lbu	a0,2(a4)
    44a0:	2485                	addiw	s1,s1,1
    44a2:	00270e13          	addi	t3,a4,2
    44a6:	52050563          	beqz	a0,49d0 <core_bench_state+0x8e0>
    44aa:	50650c63          	beq	a0,t1,49c2 <core_bench_state+0x8d2>
    44ae:	4985                	li	s3,1
    44b0:	bd65                	j	4368 <core_bench_state+0x278>
    44b2:	000fce03          	lbu	t3,0(t6)
    44b6:	400e0363          	beqz	t3,48bc <core_bench_state+0x7cc>
    44ba:	59c2                	lw	s3,48(sp)
    44bc:	5b52                	lw	s6,52(sp)
    44be:	5462                	lw	s0,56(sp)
    44c0:	56f2                	lw	a3,60(sp)
    44c2:	4c06                	lw	s8,64(sp)
    44c4:	4a96                	lw	s5,68(sp)
    44c6:	44a6                	lw	s1,72(sp)
    44c8:	87f2                	mv	a5,t3
    44ca:	877e                	mv	a4,t6
    44cc:	4601                	li	a2,0
    44ce:	4281                	li	t0,0
    44d0:	4381                	li	t2,0
    44d2:	4b81                	li	s7,0
    44d4:	4901                	li	s2,0
    44d6:	4f01                	li	t5,0
    44d8:	4c81                	li	s9,0
    44da:	02c00893          	li	a7,44
    44de:	02e00513          	li	a0,46
    44e2:	04500d13          	li	s10,69
    44e6:	4ea5                	li	t4,9
    44e8:	3b178c63          	beq	a5,a7,48a0 <core_bench_state+0x7b0>
    44ec:	30a78a63          	beq	a5,a0,4800 <core_bench_state+0x710>
    44f0:	1af56263          	bltu	a0,a5,4694 <core_bench_state+0x5a4>
    44f4:	fd578f1b          	addiw	t5,a5,-43
    44f8:	0fdf7793          	andi	a5,t5,253
    44fc:	2a078e63          	beqz	a5,47b8 <core_bench_state+0x6c8>
    4500:	4f05                	li	t5,1
    4502:	2b05                	addiw	s6,s6,1
    4504:	2985                	addiw	s3,s3,1
    4506:	0705                	addi	a4,a4,1
    4508:	8cfa                	mv	s9,t5
    450a:	87fa                	mv	a5,t5
    450c:	00000013          	nop
    4510:	54f84d8b          	th.lurw	s11,a6,a5,2
    4514:	2d85                	addiw	s11,s11,1
    4516:	54f85d8b          	th.surw	s11,a6,a5,2
    451a:	00074783          	lbu	a5,0(a4)
    451e:	f7e9                	bnez	a5,44e8 <core_bench_state+0x3f8>
    4520:	c211                	beqz	a2,4524 <core_bench_state+0x434>
    4522:	c4a6                	sw	s1,72(sp)
    4524:	00028363          	beqz	t0,452a <core_bench_state+0x43a>
    4528:	de36                	sw	a3,60(sp)
    452a:	00038363          	beqz	t2,4530 <core_bench_state+0x440>
    452e:	c2d6                	sw	s5,68(sp)
    4530:	000b8363          	beqz	s7,4536 <core_bench_state+0x446>
    4534:	c0e2                	sw	s8,64(sp)
    4536:	00090363          	beqz	s2,453c <core_bench_state+0x44c>
    453a:	dc22                	sw	s0,56(sp)
    453c:	000f0363          	beqz	t5,4542 <core_bench_state+0x452>
    4540:	d84e                	sw	s3,48(sp)
    4542:	000c8363          	beqz	s9,4548 <core_bench_state+0x458>
    4546:	da5a                	sw	s6,52(sp)
    4548:	4542                	lw	a0,16(sp)
    454a:	2e6ffa63          	bgeu	t6,t1,483e <core_bench_state+0x74e>
    454e:	6402                	ld	s0,0(sp)
    4550:	4985                	li	s3,1
    4552:	39341063          	bne	s0,s3,48d2 <core_bench_state+0x7e2>
    4556:	ffffcd13          	not	s10,t6
    455a:	01a30eb3          	add	t4,t1,s10
    455e:	007efb93          	andi	s7,t4,7
    4562:	02c00893          	li	a7,44
    4566:	080b8f63          	beqz	s7,4604 <core_bench_state+0x514>
    456a:	011e0663          	beq	t3,a7,4576 <core_bench_state+0x486>
    456e:	014e4ab3          	xor	s5,t3,s4
    4572:	015f8023          	sb	s5,0(t6)
    4576:	0f85                	addi	t6,t6,1
    4578:	2c6ff363          	bgeu	t6,t1,483e <core_bench_state+0x74e>
    457c:	4705                	li	a4,1
    457e:	000fce03          	lbu	t3,0(t6)
    4582:	08eb8163          	beq	s7,a4,4604 <core_bench_state+0x514>
    4586:	4689                	li	a3,2
    4588:	06db8663          	beq	s7,a3,45f4 <core_bench_state+0x504>
    458c:	4f0d                	li	t5,3
    458e:	05eb8b63          	beq	s7,t5,45e4 <core_bench_state+0x4f4>
    4592:	4491                	li	s1,4
    4594:	049b8063          	beq	s7,s1,45d4 <core_bench_state+0x4e4>
    4598:	4b15                	li	s6,5
    459a:	036b8563          	beq	s7,s6,45c4 <core_bench_state+0x4d4>
    459e:	4c99                	li	s9,6
    45a0:	019b8a63          	beq	s7,s9,45b4 <core_bench_state+0x4c4>
    45a4:	011e0663          	beq	t3,a7,45b0 <core_bench_state+0x4c0>
    45a8:	014e4633          	xor	a2,t3,s4
    45ac:	00cf8023          	sb	a2,0(t6)
    45b0:	881fce0b          	th.lbuib	t3,(t6),1,0
    45b4:	011e0663          	beq	t3,a7,45c0 <core_bench_state+0x4d0>
    45b8:	014e42b3          	xor	t0,t3,s4
    45bc:	005f8023          	sb	t0,0(t6)
    45c0:	881fce0b          	th.lbuib	t3,(t6),1,0
    45c4:	011e0663          	beq	t3,a7,45d0 <core_bench_state+0x4e0>
    45c8:	014e43b3          	xor	t2,t3,s4
    45cc:	007f8023          	sb	t2,0(t6)
    45d0:	881fce0b          	th.lbuib	t3,(t6),1,0
    45d4:	011e0663          	beq	t3,a7,45e0 <core_bench_state+0x4f0>
    45d8:	014e4db3          	xor	s11,t3,s4
    45dc:	01bf8023          	sb	s11,0(t6)
    45e0:	881fce0b          	th.lbuib	t3,(t6),1,0
    45e4:	011e0663          	beq	t3,a7,45f0 <core_bench_state+0x500>
    45e8:	014e47b3          	xor	a5,t3,s4
    45ec:	00ff8023          	sb	a5,0(t6)
    45f0:	881fce0b          	th.lbuib	t3,(t6),1,0
    45f4:	011e0663          	beq	t3,a7,4600 <core_bench_state+0x510>
    45f8:	014e49b3          	xor	s3,t3,s4
    45fc:	013f8023          	sb	s3,0(t6)
    4600:	881fce0b          	th.lbuib	t3,(t6),1,0
    4604:	011e0663          	beq	t3,a7,4610 <core_bench_state+0x520>
    4608:	014e4433          	xor	s0,t3,s4
    460c:	008f8023          	sb	s0,0(t6)
    4610:	001f8913          	addi	s2,t6,1
    4614:	22697563          	bgeu	s2,t1,483e <core_bench_state+0x74e>
    4618:	001fce03          	lbu	t3,1(t6)
    461c:	011e0663          	beq	t3,a7,4628 <core_bench_state+0x538>
    4620:	014e4d33          	xor	s10,t3,s4
    4624:	01af80a3          	sb	s10,1(t6)
    4628:	00194e83          	lbu	t4,1(s2)
    462c:	011e8663          	beq	t4,a7,4638 <core_bench_state+0x548>
    4630:	014ecbb3          	xor	s7,t4,s4
    4634:	017900a3          	sb	s7,1(s2)
    4638:	00294a83          	lbu	s5,2(s2)
    463c:	011a8663          	beq	s5,a7,4648 <core_bench_state+0x558>
    4640:	014ac733          	xor	a4,s5,s4
    4644:	00e90123          	sb	a4,2(s2)
    4648:	00394683          	lbu	a3,3(s2)
    464c:	01168663          	beq	a3,a7,4658 <core_bench_state+0x568>
    4650:	0146cf33          	xor	t5,a3,s4
    4654:	01e901a3          	sb	t5,3(s2)
    4658:	00494483          	lbu	s1,4(s2)
    465c:	01148663          	beq	s1,a7,4668 <core_bench_state+0x578>
    4660:	0144cb33          	xor	s6,s1,s4
    4664:	01690223          	sb	s6,4(s2)
    4668:	00594c83          	lbu	s9,5(s2)
    466c:	011c8663          	beq	s9,a7,4678 <core_bench_state+0x588>
    4670:	014cc633          	xor	a2,s9,s4
    4674:	00c902a3          	sb	a2,5(s2)
    4678:	00694283          	lbu	t0,6(s2)
    467c:	01128663          	beq	t0,a7,4688 <core_bench_state+0x598>
    4680:	0142c3b3          	xor	t2,t0,s4
    4684:	00790323          	sb	t2,6(s2)
    4688:	00794e03          	lbu	t3,7(s2)
    468c:	00790f93          	addi	t6,s2,7
    4690:	bf95                	j	4604 <core_bench_state+0x514>
    4692:	0001                	nop
    4694:	fd07879b          	addiw	a5,a5,-48
    4698:	0ff7fd93          	zext.b	s11,a5
    469c:	e7bee2e3          	bltu	t4,s11,4500 <core_bench_state+0x410>
    46a0:	8817478b          	th.lbuib	a5,(a4),1,0
    46a4:	2985                	addiw	s3,s3,1
    46a6:	cbf5                	beqz	a5,479a <core_bench_state+0x6aa>
    46a8:	21178263          	beq	a5,a7,48ac <core_bench_state+0x7bc>
    46ac:	00a78e63          	beq	a5,a0,46c8 <core_bench_state+0x5d8>
    46b0:	fd078d9b          	addiw	s11,a5,-48
    46b4:	0ffdff13          	zext.b	t5,s11
    46b8:	0deefe63          	bgeu	t4,t5,4794 <core_bench_state+0x6a4>
    46bc:	4b85                	li	s7,1
    46be:	2c05                	addiw	s8,s8,1
    46c0:	0705                	addi	a4,a4,1
    46c2:	8f5e                	mv	t5,s7
    46c4:	87de                	mv	a5,s7
    46c6:	b5a9                	j	4510 <core_bench_state+0x420>
    46c8:	00174f03          	lbu	t5,1(a4)
    46cc:	2c05                	addiw	s8,s8,1
    46ce:	00170d93          	addi	s11,a4,1
    46d2:	280f0c63          	beqz	t5,496a <core_bench_state+0x87a>
    46d6:	2b1f0c63          	beq	t5,a7,498e <core_bench_state+0x89e>
    46da:	4b85                	li	s7,1
    46dc:	0dff7713          	andi	a4,t5,223
    46e0:	03a70063          	beq	a4,s10,4700 <core_bench_state+0x610>
    46e4:	fd0f0f1b          	addiw	t5,t5,-48
    46e8:	0fff7793          	zext.b	a5,t5
    46ec:	0afefa63          	bgeu	t4,a5,47a0 <core_bench_state+0x6b0>
    46f0:	4385                	li	t2,1
    46f2:	2a85                	addiw	s5,s5,1
    46f4:	001d8713          	addi	a4,s11,1
    46f8:	8f1e                	mv	t5,t2
    46fa:	879e                	mv	a5,t2
    46fc:	bd11                	j	4510 <core_bench_state+0x420>
    46fe:	0001                	nop
    4700:	001dc383          	lbu	t2,1(s11)
    4704:	2a85                	addiw	s5,s5,1
    4706:	001d8713          	addi	a4,s11,1
    470a:	20038163          	beqz	t2,490c <core_bench_state+0x81c>
    470e:	23138763          	beq	t2,a7,493c <core_bench_state+0x84c>
    4712:	fd53829b          	addiw	t0,t2,-43
    4716:	0fd2f793          	andi	a5,t0,253
    471a:	2685                	addiw	a3,a3,1
    471c:	002d8713          	addi	a4,s11,2
    4720:	c791                	beqz	a5,472c <core_bench_state+0x63c>
    4722:	4285                	li	t0,1
    4724:	8396                	mv	t2,t0
    4726:	8f16                	mv	t5,t0
    4728:	8796                	mv	a5,t0
    472a:	b3dd                	j	4510 <core_bench_state+0x420>
    472c:	002dcf03          	lbu	t5,2(s11)
    4730:	1c0f0063          	beqz	t5,48f0 <core_bench_state+0x800>
    4734:	1f1f0e63          	beq	t5,a7,4930 <core_bench_state+0x840>
    4738:	fd0f061b          	addiw	a2,t5,-48
    473c:	0ff67393          	zext.b	t2,a2
    4740:	2485                	addiw	s1,s1,1
    4742:	003d8713          	addi	a4,s11,3
    4746:	007ef963          	bgeu	t4,t2,4758 <core_bench_state+0x668>
    474a:	4605                	li	a2,1
    474c:	82b2                	mv	t0,a2
    474e:	83b2                	mv	t2,a2
    4750:	8f32                	mv	t5,a2
    4752:	87b2                	mv	a5,a2
    4754:	bb75                	j	4510 <core_bench_state+0x420>
    4756:	0001                	nop
    4758:	003dc783          	lbu	a5,3(s11)
    475c:	c78d                	beqz	a5,4786 <core_bench_state+0x696>
    475e:	13178363          	beq	a5,a7,4884 <core_bench_state+0x794>
    4762:	fd078d9b          	addiw	s11,a5,-48
    4766:	0ffdf293          	zext.b	t0,s11
    476a:	005efb63          	bgeu	t4,t0,4780 <core_bench_state+0x690>
    476e:	4605                	li	a2,1
    4770:	2b05                	addiw	s6,s6,1
    4772:	0705                	addi	a4,a4,1
    4774:	82b2                	mv	t0,a2
    4776:	83b2                	mv	t2,a2
    4778:	8f32                	mv	t5,a2
    477a:	8cb2                	mv	s9,a2
    477c:	87b2                	mv	a5,a2
    477e:	bb49                	j	4510 <core_bench_state+0x420>
    4780:	8817478b          	th.lbuib	a5,(a4),1,0
    4784:	ffe9                	bnez	a5,475e <core_bench_state+0x66e>
    4786:	4605                	li	a2,1
    4788:	82b2                	mv	t0,a2
    478a:	83b2                	mv	t2,a2
    478c:	8f32                	mv	t5,a2
    478e:	479d                	li	a5,7
    4790:	b341                	j	4510 <core_bench_state+0x420>
    4792:	0001                	nop
    4794:	8817478b          	th.lbuib	a5,(a4),1,0
    4798:	fb81                	bnez	a5,46a8 <core_bench_state+0x5b8>
    479a:	4f05                	li	t5,1
    479c:	4791                	li	a5,4
    479e:	bb8d                	j	4510 <core_bench_state+0x420>
    47a0:	881dcf0b          	th.lbuib	t5,(s11),1,0
    47a4:	060f0563          	beqz	t5,480e <core_bench_state+0x71e>
    47a8:	f31f1ae3          	bne	t5,a7,46dc <core_bench_state+0x5ec>
    47ac:	876e                	mv	a4,s11
    47ae:	4f05                	li	t5,1
    47b0:	4795                	li	a5,5
    47b2:	0705                	addi	a4,a4,1
    47b4:	bbb1                	j	4510 <core_bench_state+0x420>
    47b6:	0001                	nop
    47b8:	00174f03          	lbu	t5,1(a4)
    47bc:	2985                	addiw	s3,s3,1
    47be:	00170d93          	addi	s11,a4,1
    47c2:	1c0f0c63          	beqz	t5,499a <core_bench_state+0x8aa>
    47c6:	1d1f0e63          	beq	t5,a7,49a2 <core_bench_state+0x8b2>
    47ca:	fd0f091b          	addiw	s2,t5,-48
    47ce:	0ff97793          	zext.b	a5,s2
    47d2:	00fefb63          	bgeu	t4,a5,47e8 <core_bench_state+0x6f8>
    47d6:	04af0163          	beq	t5,a0,4818 <core_bench_state+0x728>
    47da:	4905                	li	s2,1
    47dc:	2405                	addiw	s0,s0,1
    47de:	0709                	addi	a4,a4,2
    47e0:	8f4a                	mv	t5,s2
    47e2:	87ca                	mv	a5,s2
    47e4:	b335                	j	4510 <core_bench_state+0x420>
    47e6:	0001                	nop
    47e8:	8827478b          	th.lbuib	a5,(a4),2,0
    47ec:	2405                	addiw	s0,s0,1
    47ee:	4905                	li	s2,1
    47f0:	16078663          	beqz	a5,495c <core_bench_state+0x86c>
    47f4:	eb179ce3          	bne	a5,a7,46ac <core_bench_state+0x5bc>
    47f8:	8f4a                	mv	t5,s2
    47fa:	4791                	li	a5,4
    47fc:	0705                	addi	a4,a4,1
    47fe:	bb09                	j	4510 <core_bench_state+0x420>
    4800:	00174f03          	lbu	t5,1(a4)
    4804:	2985                	addiw	s3,s3,1
    4806:	00170d93          	addi	s11,a4,1
    480a:	f80f1fe3          	bnez	t5,47a8 <core_bench_state+0x6b8>
    480e:	876e                	mv	a4,s11
    4810:	4f05                	li	t5,1
    4812:	4795                	li	a5,5
    4814:	b9f5                	j	4510 <core_bench_state+0x420>
    4816:	0001                	nop
    4818:	00274f03          	lbu	t5,2(a4)
    481c:	2405                	addiw	s0,s0,1
    481e:	00270d93          	addi	s11,a4,2
    4822:	1a0f0d63          	beqz	t5,49dc <core_bench_state+0x8ec>
    4826:	1d1f0063          	beq	t5,a7,49e6 <core_bench_state+0x8f6>
    482a:	4905                	li	s2,1
    482c:	bd45                	j	46dc <core_bench_state+0x5ec>
    482e:	7c05330b          	th.extu	t1,a0,31,0
    4832:	937e                	add	t1,t1,t6
    4834:	01010813          	addi	a6,sp,16
    4838:	4501                	li	a0,0
    483a:	986feee3          	bltu	t6,t1,41d6 <core_bench_state+0xe6>
    483e:	03010a13          	addi	s4,sp,48
    4842:	8c42                	mv	s8,a6
    4844:	a021                	j	484c <core_bench_state+0x75c>
    4846:	0001                	nop
    4848:	000c2503          	lw	a0,0(s8)
    484c:	0a5000ef          	jal	50f0 <crcu32>
    4850:	85aa                	mv	a1,a0
    4852:	584a450b          	th.lwia	a0,(s4),4,0
    4856:	0c11                	addi	s8,s8,4
    4858:	099000ef          	jal	50f0 <crcu32>
    485c:	05010f93          	addi	t6,sp,80
    4860:	85aa                	mv	a1,a0
    4862:	fffa13e3          	bne	s4,t6,4848 <core_bench_state+0x758>
    4866:	74aa                	ld	s1,168(sp)
    4868:	744a                	ld	s0,176(sp)
    486a:	70ea                	ld	ra,184(sp)
    486c:	6de6                	ld	s11,88(sp)
    486e:	7d06                	ld	s10,96(sp)
    4870:	7ca6                	ld	s9,104(sp)
    4872:	7c46                	ld	s8,112(sp)
    4874:	7be6                	ld	s7,120(sp)
    4876:	6b0a                	ld	s6,128(sp)
    4878:	6aaa                	ld	s5,136(sp)
    487a:	6a4a                	ld	s4,144(sp)
    487c:	69ea                	ld	s3,152(sp)
    487e:	790a                	ld	s2,160(sp)
    4880:	6129                	addi	sp,sp,192
    4882:	8082                	ret
    4884:	4605                	li	a2,1
    4886:	82b2                	mv	t0,a2
    4888:	83b2                	mv	t2,a2
    488a:	8f32                	mv	t5,a2
    488c:	479d                	li	a5,7
    488e:	0705                	addi	a4,a4,1
    4890:	b141                	j	4510 <core_bench_state+0x420>
    4892:	4885                	li	a7,1
    4894:	82c6                	mv	t0,a7
    4896:	83c6                	mv	t2,a7
    4898:	8546                	mv	a0,a7
    489a:	479d                	li	a5,7
    489c:	0705                	addi	a4,a4,1
    489e:	b8cd                	j	4190 <core_bench_state+0xa0>
    48a0:	4781                	li	a5,0
    48a2:	0705                	addi	a4,a4,1
    48a4:	b1b5                	j	4510 <core_bench_state+0x420>
    48a6:	4781                	li	a5,0
    48a8:	0705                	addi	a4,a4,1
    48aa:	b0dd                	j	4190 <core_bench_state+0xa0>
    48ac:	4f05                	li	t5,1
    48ae:	4791                	li	a5,4
    48b0:	0705                	addi	a4,a4,1
    48b2:	b9b9                	j	4510 <core_bench_state+0x420>
    48b4:	4505                	li	a0,1
    48b6:	4791                	li	a5,4
    48b8:	0705                	addi	a4,a4,1
    48ba:	b8d9                	j	4190 <core_bench_state+0xa0>
    48bc:	4542                	lw	a0,16(sp)
    48be:	c86fece3          	bltu	t6,t1,4556 <core_bench_state+0x466>
    48c2:	bfb5                	j	483e <core_bench_state+0x74e>
    48c4:	000fce03          	lbu	t3,0(t6)
    48c8:	be0e19e3          	bnez	t3,44ba <core_bench_state+0x3ca>
    48cc:	4542                	lw	a0,16(sp)
    48ce:	f66ff8e3          	bgeu	t6,t1,483e <core_bench_state+0x74e>
    48d2:	6c02                	ld	s8,0(sp)
    48d4:	02c00913          	li	s2,44
    48d8:	012e0663          	beq	t3,s2,48e4 <core_bench_state+0x7f4>
    48dc:	014e4e33          	xor	t3,t3,s4
    48e0:	01cf8023          	sb	t3,0(t6)
    48e4:	9fe2                	add	t6,t6,s8
    48e6:	f46ffce3          	bgeu	t6,t1,483e <core_bench_state+0x74e>
    48ea:	000fce03          	lbu	t3,0(t6)
    48ee:	b7ed                	j	48d8 <core_bench_state+0x7e8>
    48f0:	4285                	li	t0,1
    48f2:	8396                	mv	t2,t0
    48f4:	8f16                	mv	t5,t0
    48f6:	4799                	li	a5,6
    48f8:	b921                	j	4510 <core_bench_state+0x420>
    48fa:	4385                	li	t2,1
    48fc:	851e                	mv	a0,t2
    48fe:	478d                	li	a5,3
    4900:	b841                	j	4190 <core_bench_state+0xa0>
    4902:	4285                	li	t0,1
    4904:	8396                	mv	t2,t0
    4906:	8516                	mv	a0,t0
    4908:	4799                	li	a5,6
    490a:	b059                	j	4190 <core_bench_state+0xa0>
    490c:	4385                	li	t2,1
    490e:	8f1e                	mv	t5,t2
    4910:	478d                	li	a5,3
    4912:	befd                	j	4510 <core_bench_state+0x420>
    4914:	02c00c93          	li	s9,44
    4918:	019e0663          	beq	t3,s9,4924 <core_bench_state+0x834>
    491c:	00ce46b3          	xor	a3,t3,a2
    4920:	00dd8023          	sb	a3,0(s11)
    4924:	9dce                	add	s11,s11,s3
    4926:	f86dffe3          	bgeu	s11,t1,48c4 <core_bench_state+0x7d4>
    492a:	000dce03          	lbu	t3,0(s11)
    492e:	b7ed                	j	4918 <core_bench_state+0x828>
    4930:	4285                	li	t0,1
    4932:	8396                	mv	t2,t0
    4934:	8f16                	mv	t5,t0
    4936:	4799                	li	a5,6
    4938:	0705                	addi	a4,a4,1
    493a:	bed9                	j	4510 <core_bench_state+0x420>
    493c:	4385                	li	t2,1
    493e:	8f1e                	mv	t5,t2
    4940:	478d                	li	a5,3
    4942:	0705                	addi	a4,a4,1
    4944:	b6f1                	j	4510 <core_bench_state+0x420>
    4946:	4285                	li	t0,1
    4948:	8396                	mv	t2,t0
    494a:	8516                	mv	a0,t0
    494c:	4799                	li	a5,6
    494e:	0705                	addi	a4,a4,1
    4950:	b081                	j	4190 <core_bench_state+0xa0>
    4952:	4385                	li	t2,1
    4954:	851e                	mv	a0,t2
    4956:	478d                	li	a5,3
    4958:	0705                	addi	a4,a4,1
    495a:	b81d                	j	4190 <core_bench_state+0xa0>
    495c:	8f4a                	mv	t5,s2
    495e:	4791                	li	a5,4
    4960:	be45                	j	4510 <core_bench_state+0x420>
    4962:	854e                	mv	a0,s3
    4964:	4791                	li	a5,4
    4966:	82bff06f          	j	4190 <core_bench_state+0xa0>
    496a:	4b85                	li	s7,1
    496c:	876e                	mv	a4,s11
    496e:	8f5e                	mv	t5,s7
    4970:	4795                	li	a5,5
    4972:	be79                	j	4510 <core_bench_state+0x420>
    4974:	4c05                	li	s8,1
    4976:	8772                	mv	a4,t3
    4978:	8562                	mv	a0,s8
    497a:	4795                	li	a5,5
    497c:	815ff06f          	j	4190 <core_bench_state+0xa0>
    4980:	8772                	mv	a4,t3
    4982:	4c05                	li	s8,1
    4984:	8562                	mv	a0,s8
    4986:	4795                	li	a5,5
    4988:	0705                	addi	a4,a4,1
    498a:	807ff06f          	j	4190 <core_bench_state+0xa0>
    498e:	876e                	mv	a4,s11
    4990:	4b85                	li	s7,1
    4992:	8f5e                	mv	t5,s7
    4994:	4795                	li	a5,5
    4996:	0705                	addi	a4,a4,1
    4998:	bea5                	j	4510 <core_bench_state+0x420>
    499a:	876e                	mv	a4,s11
    499c:	4f05                	li	t5,1
    499e:	4789                	li	a5,2
    49a0:	be85                	j	4510 <core_bench_state+0x420>
    49a2:	876e                	mv	a4,s11
    49a4:	4f05                	li	t5,1
    49a6:	4789                	li	a5,2
    49a8:	0705                	addi	a4,a4,1
    49aa:	b69d                	j	4510 <core_bench_state+0x420>
    49ac:	8772                	mv	a4,t3
    49ae:	4505                	li	a0,1
    49b0:	4789                	li	a5,2
    49b2:	0705                	addi	a4,a4,1
    49b4:	fdcff06f          	j	4190 <core_bench_state+0xa0>
    49b8:	8772                	mv	a4,t3
    49ba:	4505                	li	a0,1
    49bc:	4789                	li	a5,2
    49be:	fd2ff06f          	j	4190 <core_bench_state+0xa0>
    49c2:	8772                	mv	a4,t3
    49c4:	4985                	li	s3,1
    49c6:	854e                	mv	a0,s3
    49c8:	4795                	li	a5,5
    49ca:	0705                	addi	a4,a4,1
    49cc:	fc4ff06f          	j	4190 <core_bench_state+0xa0>
    49d0:	4985                	li	s3,1
    49d2:	8772                	mv	a4,t3
    49d4:	854e                	mv	a0,s3
    49d6:	4795                	li	a5,5
    49d8:	fb8ff06f          	j	4190 <core_bench_state+0xa0>
    49dc:	4905                	li	s2,1
    49de:	876e                	mv	a4,s11
    49e0:	8f4a                	mv	t5,s2
    49e2:	4795                	li	a5,5
    49e4:	b635                	j	4510 <core_bench_state+0x420>
    49e6:	876e                	mv	a4,s11
    49e8:	4905                	li	s2,1
    49ea:	8f4a                	mv	t5,s2
    49ec:	4795                	li	a5,5
    49ee:	0705                	addi	a4,a4,1
    49f0:	b605                	j	4510 <core_bench_state+0x420>
    49f2:	0001                	nop
    49f4:	00000013          	nop
    49f8:	00000013          	nop
    49fc:	00000013          	nop

0000000000004a00 <core_init_state>:
    4a00:	fff50e9b          	addiw	t4,a0,-1
    4a04:	4f85                	li	t6,1
    4a06:	19dff963          	bgeu	t6,t4,4b98 <core_init_state+0x198>
    4a0a:	2585                	addiw	a1,a1,1
    4a0c:	3c05b68b          	th.extu	a3,a1,15,0
    4a10:	6e45                	lui	t3,0x11
    4a12:	4f1d                	li	t5,7
    4a14:	0076f713          	andi	a4,a3,7
    4a18:	4801                	li	a6,0
    4a1a:	b10e0e13          	addi	t3,t3,-1264 # 10b10 <intpat>
    4a1e:	4311                	li	t1,4
    4a20:	02c00293          	li	t0,44
    4a24:	3c06a78b          	th.ext	a5,a3,15,0
    4a28:	09e70763          	beq	a4,t5,4ab6 <core_init_state+0xb6>
    4a2c:	14e36e63          	bltu	t1,a4,4b88 <core_init_state+0x188>
    4a30:	ffd7059b          	addiw	a1,a4,-3
    4a34:	3c05b88b          	th.extu	a7,a1,15,0
    4a38:	151fe263          	bltu	t6,a7,4b7c <core_init_state+0x17c>
    4a3c:	8be1                	andi	a5,a5,24
    4a3e:	00fe03b3          	add	t2,t3,a5
    4a42:	0203b703          	ld	a4,32(t2)
    4a46:	48a1                	li	a7,8
    4a48:	0018059b          	addiw	a1,a6,1
    4a4c:	011585bb          	addw	a1,a1,a7
    4a50:	07d5ff63          	bgeu	a1,t4,4ace <core_init_state+0xce>
    4a54:	00074383          	lbu	t2,0(a4)
    4a58:	7c08378b          	th.extu	a5,a6,31,0
    4a5c:	97b2                	add	a5,a5,a2
    4a5e:	1106538b          	th.surb	t2,a2,a6,0
    4a62:	00174803          	lbu	a6,1(a4)
    4a66:	010780a3          	sb	a6,1(a5)
    4a6a:	00274383          	lbu	t2,2(a4)
    4a6e:	00778123          	sb	t2,2(a5)
    4a72:	00374803          	lbu	a6,3(a4)
    4a76:	010781a3          	sb	a6,3(a5)
    4a7a:	02688263          	beq	a7,t1,4a9e <core_init_state+0x9e>
    4a7e:	00474383          	lbu	t2,4(a4)
    4a82:	00778223          	sb	t2,4(a5)
    4a86:	00574803          	lbu	a6,5(a4)
    4a8a:	010782a3          	sb	a6,5(a5)
    4a8e:	00674383          	lbu	t2,6(a4)
    4a92:	00778323          	sb	t2,6(a5)
    4a96:	00774703          	lbu	a4,7(a4)
    4a9a:	00e783a3          	sb	a4,7(a5)
    4a9e:	2685                	addiw	a3,a3,1
    4aa0:	3c06b68b          	th.extu	a3,a3,15,0
    4aa4:	1117d28b          	th.surb	t0,a5,a7,0
    4aa8:	0076f713          	andi	a4,a3,7
    4aac:	882e                	mv	a6,a1
    4aae:	3c06a78b          	th.ext	a5,a3,15,0
    4ab2:	f7e71de3          	bne	a4,t5,4a2c <core_init_state+0x2c>
    4ab6:	0187f893          	andi	a7,a5,24
    4aba:	011e05b3          	add	a1,t3,a7
    4abe:	71b8                	ld	a4,96(a1)
    4ac0:	48a1                	li	a7,8
    4ac2:	0018059b          	addiw	a1,a6,1
    4ac6:	011585bb          	addw	a1,a1,a7
    4aca:	f9d5e5e3          	bltu	a1,t4,4a54 <core_init_state+0x54>
    4ace:	0ca87763          	bgeu	a6,a0,4b9c <core_init_state+0x19c>
    4ad2:	7c08328b          	th.extu	t0,a6,31,0
    4ad6:	9616                	add	a2,a2,t0
    4ad8:	40c8033b          	subw	t1,a6,a2
    4adc:	87b2                	mv	a5,a2
    4ade:	fff64693          	not	a3,a2
    4ae2:	7c033e8b          	th.extu	t4,t1,31,0
    4ae6:	41d68f33          	sub	t5,a3,t4
    4aea:	1817d00b          	th.sbia	zero,(a5),1,0
    4aee:	00af0fb3          	add	t6,t5,a0
    4af2:	00678e3b          	addw	t3,a5,t1
    4af6:	007ff813          	andi	a6,t6,7
    4afa:	0aae7263          	bgeu	t3,a0,4b9e <core_init_state+0x19e>
    4afe:	04080863          	beqz	a6,4b4e <core_init_state+0x14e>
    4b02:	4885                	li	a7,1
    4b04:	03180f63          	beq	a6,a7,4b42 <core_init_state+0x142>
    4b08:	4709                	li	a4,2
    4b0a:	02e80a63          	beq	a6,a4,4b3e <core_init_state+0x13e>
    4b0e:	438d                	li	t2,3
    4b10:	02780563          	beq	a6,t2,4b3a <core_init_state+0x13a>
    4b14:	4591                	li	a1,4
    4b16:	02b80063          	beq	a6,a1,4b36 <core_init_state+0x136>
    4b1a:	4295                	li	t0,5
    4b1c:	00580b63          	beq	a6,t0,4b32 <core_init_state+0x132>
    4b20:	4699                	li	a3,6
    4b22:	00d80663          	beq	a6,a3,4b2e <core_init_state+0x12e>
    4b26:	00078023          	sb	zero,0(a5)
    4b2a:	00260793          	addi	a5,a2,2
    4b2e:	1817d00b          	th.sbia	zero,(a5),1,0
    4b32:	1817d00b          	th.sbia	zero,(a5),1,0
    4b36:	1817d00b          	th.sbia	zero,(a5),1,0
    4b3a:	1817d00b          	th.sbia	zero,(a5),1,0
    4b3e:	1817d00b          	th.sbia	zero,(a5),1,0
    4b42:	1817d00b          	th.sbia	zero,(a5),1,0
    4b46:	0067863b          	addw	a2,a5,t1
    4b4a:	04a67663          	bgeu	a2,a0,4b96 <core_init_state+0x196>
    4b4e:	00078023          	sb	zero,0(a5)
    4b52:	000780a3          	sb	zero,1(a5)
    4b56:	00078123          	sb	zero,2(a5)
    4b5a:	000781a3          	sb	zero,3(a5)
    4b5e:	00078223          	sb	zero,4(a5)
    4b62:	000782a3          	sb	zero,5(a5)
    4b66:	00078323          	sb	zero,6(a5)
    4b6a:	000783a3          	sb	zero,7(a5)
    4b6e:	07a1                	addi	a5,a5,8
    4b70:	00678ebb          	addw	t4,a5,t1
    4b74:	fcaeede3          	bltu	t4,a0,4b4e <core_init_state+0x14e>
    4b78:	8082                	ret
    4b7a:	0001                	nop
    4b7c:	1037b70b          	th.extu	a4,a5,4,3
    4b80:	66ee470b          	th.lrd	a4,t3,a4,3
    4b84:	4891                	li	a7,4
    4b86:	b5c9                	j	4a48 <core_init_state+0x48>
    4b88:	8be1                	andi	a5,a5,24
    4b8a:	00fe03b3          	add	t2,t3,a5
    4b8e:	0403b703          	ld	a4,64(t2)
    4b92:	48a1                	li	a7,8
    4b94:	bd55                	j	4a48 <core_init_state+0x48>
    4b96:	8082                	ret
    4b98:	4801                	li	a6,0
    4b9a:	bf25                	j	4ad2 <core_init_state+0xd2>
    4b9c:	8082                	ret
    4b9e:	8082                	ret

0000000000004ba0 <core_state_transition>:
    4ba0:	6114                	ld	a3,0(a0)
    4ba2:	882a                	mv	a6,a0
    4ba4:	0006c783          	lbu	a5,0(a3)
    4ba8:	24078163          	beqz	a5,4dea <core_state_transition+0x24a>
    4bac:	02c00713          	li	a4,44
    4bb0:	4501                	li	a0,0
    4bb2:	1ce78b63          	beq	a5,a4,4d88 <core_state_transition+0x1e8>
    4bb6:	02e00513          	li	a0,46
    4bba:	1ea78f63          	beq	a5,a0,4db8 <core_state_transition+0x218>
    4bbe:	1cf56763          	bltu	a0,a5,4d8c <core_state_transition+0x1ec>
    4bc2:	fd578f1b          	addiw	t5,a5,-43
    4bc6:	0fdf7f93          	andi	t6,t5,253
    4bca:	020f8363          	beqz	t6,4bf0 <core_state_transition+0x50>
    4bce:	0045a883          	lw	a7,4(a1)
    4bd2:	0005ae83          	lw	t4,0(a1)
    4bd6:	0685                	addi	a3,a3,1
    4bd8:	00188e1b          	addiw	t3,a7,1
    4bdc:	001e861b          	addiw	a2,t4,1
    4be0:	4505                	li	a0,1
    4be2:	01c5a223          	sw	t3,4(a1)
    4be6:	c190                	sw	a2,0(a1)
    4be8:	00d83023          	sd	a3,0(a6)
    4bec:	8082                	ret
    4bee:	0001                	nop
    4bf0:	419c                	lw	a5,0(a1)
    4bf2:	00168613          	addi	a2,a3,1
    4bf6:	0017829b          	addiw	t0,a5,1
    4bfa:	0055a023          	sw	t0,0(a1)
    4bfe:	0016c303          	lbu	t1,1(a3)
    4c02:	20030963          	beqz	t1,4e14 <core_state_transition+0x274>
    4c06:	1ce30e63          	beq	t1,a4,4de2 <core_state_transition+0x242>
    4c0a:	fd03071b          	addiw	a4,t1,-48
    4c0e:	0ff77393          	zext.b	t2,a4
    4c12:	48a5                	li	a7,9
    4c14:	0078fe63          	bgeu	a7,t2,4c30 <core_state_transition+0x90>
    4c18:	1ca30063          	beq	t1,a0,4dd8 <core_state_transition+0x238>
    4c1c:	4590                	lw	a2,8(a1)
    4c1e:	0689                	addi	a3,a3,2
    4c20:	4505                	li	a0,1
    4c22:	00160e1b          	addiw	t3,a2,1
    4c26:	01c5a423          	sw	t3,8(a1)
    4c2a:	00d83023          	sd	a3,0(a6)
    4c2e:	8082                	ret
    4c30:	0085ae83          	lw	t4,8(a1)
    4c34:	001e8f1b          	addiw	t5,t4,1
    4c38:	01e5a423          	sw	t5,8(a1)
    4c3c:	88164f8b          	th.lbuib	t6,(a2),1,0
    4c40:	160f8963          	beqz	t6,4db2 <core_state_transition+0x212>
    4c44:	02c00713          	li	a4,44
    4c48:	1aef8d63          	beq	t6,a4,4e02 <core_state_transition+0x262>
    4c4c:	02e00793          	li	a5,46
    4c50:	02ff8663          	beq	t6,a5,4c7c <core_state_transition+0xdc>
    4c54:	fd0f829b          	addiw	t0,t6,-48
    4c58:	0ff2f313          	zext.b	t1,t0
    4c5c:	4725                	li	a4,9
    4c5e:	fc677fe3          	bgeu	a4,t1,4c3c <core_state_transition+0x9c>
    4c62:	0105a383          	lw	t2,16(a1)
    4c66:	00160693          	addi	a3,a2,1
    4c6a:	4505                	li	a0,1
    4c6c:	0013889b          	addiw	a7,t2,1
    4c70:	0115a823          	sw	a7,16(a1)
    4c74:	00d83023          	sd	a3,0(a6)
    4c78:	8082                	ret
    4c7a:	0001                	nop
    4c7c:	0105ae03          	lw	t3,16(a1)
    4c80:	001e069b          	addiw	a3,t3,1
    4c84:	c994                	sw	a3,16(a1)
    4c86:	8816450b          	th.lbuib	a0,(a2),1,0
    4c8a:	14050363          	beqz	a0,4dd0 <core_state_transition+0x230>
    4c8e:	02c00713          	li	a4,44
    4c92:	0ee50963          	beq	a0,a4,4d84 <core_state_transition+0x1e4>
    4c96:	0df57e93          	andi	t4,a0,223
    4c9a:	04500f13          	li	t5,69
    4c9e:	03ee8563          	beq	t4,t5,4cc8 <core_state_transition+0x128>
    4ca2:	fd050f9b          	addiw	t6,a0,-48
    4ca6:	0ffff793          	zext.b	a5,t6
    4caa:	42a5                	li	t0,9
    4cac:	fcf2fde3          	bgeu	t0,a5,4c86 <core_state_transition+0xe6>
    4cb0:	0145a303          	lw	t1,20(a1)
    4cb4:	00160693          	addi	a3,a2,1
    4cb8:	4505                	li	a0,1
    4cba:	0013039b          	addiw	t2,t1,1
    4cbe:	0075aa23          	sw	t2,20(a1)
    4cc2:	00d83023          	sd	a3,0(a6)
    4cc6:	8082                	ret
    4cc8:	0145a883          	lw	a7,20(a1)
    4ccc:	00160693          	addi	a3,a2,1
    4cd0:	00188e1b          	addiw	t3,a7,1
    4cd4:	01c5aa23          	sw	t3,20(a1)
    4cd8:	00164503          	lbu	a0,1(a2)
    4cdc:	10050b63          	beqz	a0,4df2 <core_state_transition+0x252>
    4ce0:	02c00713          	li	a4,44
    4ce4:	10e50c63          	beq	a0,a4,4dfc <core_state_transition+0x25c>
    4ce8:	fd55069b          	addiw	a3,a0,-43
    4cec:	0fd6fe93          	andi	t4,a3,253
    4cf0:	000e8e63          	beqz	t4,4d0c <core_state_transition+0x16c>
    4cf4:	00260693          	addi	a3,a2,2
    4cf8:	45d0                	lw	a2,12(a1)
    4cfa:	4505                	li	a0,1
    4cfc:	00160f1b          	addiw	t5,a2,1
    4d00:	01e5a623          	sw	t5,12(a1)
    4d04:	00d83023          	sd	a3,0(a6)
    4d08:	8082                	ret
    4d0a:	0001                	nop
    4d0c:	00c5af83          	lw	t6,12(a1)
    4d10:	00260693          	addi	a3,a2,2
    4d14:	001f879b          	addiw	a5,t6,1
    4d18:	c5dc                	sw	a5,12(a1)
    4d1a:	00264283          	lbu	t0,2(a2)
    4d1e:	0c028863          	beqz	t0,4dee <core_state_transition+0x24e>
    4d22:	0ce28a63          	beq	t0,a4,4df6 <core_state_transition+0x256>
    4d26:	fd02831b          	addiw	t1,t0,-48
    4d2a:	0ff37393          	zext.b	t2,t1
    4d2e:	4725                	li	a4,9
    4d30:	00777c63          	bgeu	a4,t2,4d48 <core_state_transition+0x1a8>
    4d34:	0185a883          	lw	a7,24(a1)
    4d38:	00360693          	addi	a3,a2,3
    4d3c:	4505                	li	a0,1
    4d3e:	00188e1b          	addiw	t3,a7,1
    4d42:	01c5ac23          	sw	t3,24(a1)
    4d46:	b54d                	j	4be8 <core_state_transition+0x48>
    4d48:	4d88                	lw	a0,24(a1)
    4d4a:	00150e9b          	addiw	t4,a0,1
    4d4e:	01d5ac23          	sw	t4,24(a1)
    4d52:	8636                	mv	a2,a3
    4d54:	8816cf0b          	th.lbuib	t5,(a3),1,0
    4d58:	0a0f0c63          	beqz	t5,4e10 <core_state_transition+0x270>
    4d5c:	02c00f93          	li	t6,44
    4d60:	0bff0563          	beq	t5,t6,4e0a <core_state_transition+0x26a>
    4d64:	fd0f079b          	addiw	a5,t5,-48
    4d68:	0ff7f293          	zext.b	t0,a5
    4d6c:	fe5773e3          	bgeu	a4,t0,4d52 <core_state_transition+0x1b2>
    4d70:	0045a303          	lw	t1,4(a1)
    4d74:	00260693          	addi	a3,a2,2
    4d78:	4505                	li	a0,1
    4d7a:	0013039b          	addiw	t2,t1,1
    4d7e:	0075a223          	sw	t2,4(a1)
    4d82:	b59d                	j	4be8 <core_state_transition+0x48>
    4d84:	86b2                	mv	a3,a2
    4d86:	4515                	li	a0,5
    4d88:	0685                	addi	a3,a3,1
    4d8a:	bdb9                	j	4be8 <core_state_transition+0x48>
    4d8c:	fd07839b          	addiw	t2,a5,-48
    4d90:	0ff3f893          	zext.b	a7,t2
    4d94:	4625                	li	a2,9
    4d96:	e3166ce3          	bltu	a2,a7,4bce <core_state_transition+0x2e>
    4d9a:	0005ae03          	lw	t3,0(a1)
    4d9e:	00168613          	addi	a2,a3,1
    4da2:	001e0e9b          	addiw	t4,t3,1
    4da6:	01d5a023          	sw	t4,0(a1)
    4daa:	0016cf83          	lbu	t6,1(a3)
    4dae:	e80f9de3          	bnez	t6,4c48 <core_state_transition+0xa8>
    4db2:	86b2                	mv	a3,a2
    4db4:	4511                	li	a0,4
    4db6:	bd0d                	j	4be8 <core_state_transition+0x48>
    4db8:	0005a283          	lw	t0,0(a1)
    4dbc:	00168613          	addi	a2,a3,1
    4dc0:	0012831b          	addiw	t1,t0,1
    4dc4:	0065a023          	sw	t1,0(a1)
    4dc8:	0016c503          	lbu	a0,1(a3)
    4dcc:	ec0513e3          	bnez	a0,4c92 <core_state_transition+0xf2>
    4dd0:	86b2                	mv	a3,a2
    4dd2:	4515                	li	a0,5
    4dd4:	bd11                	j	4be8 <core_state_transition+0x48>
    4dd6:	0001                	nop
    4dd8:	4594                	lw	a3,8(a1)
    4dda:	0016851b          	addiw	a0,a3,1
    4dde:	c588                	sw	a0,8(a1)
    4de0:	b55d                	j	4c86 <core_state_transition+0xe6>
    4de2:	86b2                	mv	a3,a2
    4de4:	4509                	li	a0,2
    4de6:	0685                	addi	a3,a3,1
    4de8:	b501                	j	4be8 <core_state_transition+0x48>
    4dea:	4501                	li	a0,0
    4dec:	bbf5                	j	4be8 <core_state_transition+0x48>
    4dee:	4519                	li	a0,6
    4df0:	bbe5                	j	4be8 <core_state_transition+0x48>
    4df2:	450d                	li	a0,3
    4df4:	bbd5                	j	4be8 <core_state_transition+0x48>
    4df6:	4519                	li	a0,6
    4df8:	0685                	addi	a3,a3,1
    4dfa:	b3fd                	j	4be8 <core_state_transition+0x48>
    4dfc:	450d                	li	a0,3
    4dfe:	0685                	addi	a3,a3,1
    4e00:	b3e5                	j	4be8 <core_state_transition+0x48>
    4e02:	86b2                	mv	a3,a2
    4e04:	4511                	li	a0,4
    4e06:	0685                	addi	a3,a3,1
    4e08:	b3c5                	j	4be8 <core_state_transition+0x48>
    4e0a:	451d                	li	a0,7
    4e0c:	0685                	addi	a3,a3,1
    4e0e:	bbe9                	j	4be8 <core_state_transition+0x48>
    4e10:	451d                	li	a0,7
    4e12:	bbd9                	j	4be8 <core_state_transition+0x48>
    4e14:	86b2                	mv	a3,a2
    4e16:	4509                	li	a0,2
    4e18:	bbc1                	j	4be8 <core_state_transition+0x48>
	...

0000000000004e30 <get_seed_32>:
    4e30:	4795                	li	a5,5
    4e32:	04a7e663          	bltu	a5,a0,4e7e <get_seed_32+0x4e>
    4e36:	62c5                	lui	t0,0x11
    4e38:	b9028313          	addi	t1,t0,-1136 # 10b90 <errpat+0x20>
    4e3c:	44a3438b          	th.lrw	t2,t1,a0,2
    4e40:	8382                	jr	t2
    4e42:	0001                	nop
    4e44:	00041537          	lui	a0,0x41
    4e48:	fd052503          	lw	a0,-48(a0) # 40fd0 <seed5_volatile>
    4e4c:	8082                	ret
    4e4e:	0001                	nop
    4e50:	00041737          	lui	a4,0x41
    4e54:	fd872503          	lw	a0,-40(a4) # 40fd8 <seed1_volatile>
    4e58:	8082                	ret
    4e5a:	0001                	nop
    4e5c:	000416b7          	lui	a3,0x41
    4e60:	fd46a503          	lw	a0,-44(a3) # 40fd4 <seed2_volatile>
    4e64:	8082                	ret
    4e66:	0001                	nop
    4e68:	00040637          	lui	a2,0x40
    4e6c:	02862503          	lw	a0,40(a2) # 40028 <seed3_volatile>
    4e70:	8082                	ret
    4e72:	0001                	nop
    4e74:	000405b7          	lui	a1,0x40
    4e78:	0245a503          	lw	a0,36(a1) # 40024 <seed4_volatile>
    4e7c:	8082                	ret
    4e7e:	4501                	li	a0,0
    4e80:	8082                	ret
    4e82:	0001                	nop
    4e84:	00000013          	nop
    4e88:	00000013          	nop
    4e8c:	00000013          	nop

0000000000004e90 <crcu8>:
    4e90:	6829                	lui	a6,0xa
    4e92:	00180313          	addi	t1,a6,1 # a001 <_vsnprintf+0x1441>
    4e96:	00b54733          	xor	a4,a0,a1
    4e9a:	8185                	srli	a1,a1,0x1
    4e9c:	00177293          	andi	t0,a4,1
    4ea0:	0065c7b3          	xor	a5,a1,t1
    4ea4:	4055978b          	th.mveqz	a5,a1,t0
    4ea8:	00155613          	srli	a2,a0,0x1
    4eac:	00f643b3          	xor	t2,a2,a5
    4eb0:	0017de13          	srli	t3,a5,0x1
    4eb4:	0013f893          	andi	a7,t2,1
    4eb8:	006e4f33          	xor	t5,t3,t1
    4ebc:	411e1f0b          	th.mveqz	t5,t3,a7
    4ec0:	00255693          	srli	a3,a0,0x2
    4ec4:	01e6c633          	xor	a2,a3,t5
    4ec8:	001f5713          	srli	a4,t5,0x1
    4ecc:	00167293          	andi	t0,a2,1
    4ed0:	006745b3          	xor	a1,a4,t1
    4ed4:	4057158b          	th.mveqz	a1,a4,t0
    4ed8:	00355f93          	srli	t6,a0,0x3
    4edc:	8e9a                	mv	t4,t1
    4ede:	0015d793          	srli	a5,a1,0x1
    4ee2:	00bfc333          	xor	t1,t6,a1
    4ee6:	00137693          	andi	a3,t1,1
    4eea:	01d7c3b3          	xor	t2,a5,t4
    4eee:	40d7938b          	th.mveqz	t2,a5,a3
    4ef2:	00455813          	srli	a6,a0,0x4
    4ef6:	00784e33          	xor	t3,a6,t2
    4efa:	0013df93          	srli	t6,t2,0x1
    4efe:	001e7f13          	andi	t5,t3,1
    4f02:	01dfc2b3          	xor	t0,t6,t4
    4f06:	41ef928b          	th.mveqz	t0,t6,t5
    4f0a:	00555893          	srli	a7,a0,0x5
    4f0e:	0058c633          	xor	a2,a7,t0
    4f12:	0012d313          	srli	t1,t0,0x1
    4f16:	01d34733          	xor	a4,t1,t4
    4f1a:	00167813          	andi	a6,a2,1
    4f1e:	4103170b          	th.mveqz	a4,t1,a6
    4f22:	00655593          	srli	a1,a0,0x6
    4f26:	00755793          	srli	a5,a0,0x7
    4f2a:	00175393          	srli	t2,a4,0x1
    4f2e:	00e5c533          	xor	a0,a1,a4
    4f32:	00157693          	andi	a3,a0,1
    4f36:	01d3c8b3          	xor	a7,t2,t4
    4f3a:	40d3988b          	th.mveqz	a7,t2,a3
    4f3e:	0018d513          	srli	a0,a7,0x1
    4f42:	0117ce33          	xor	t3,a5,a7
    4f46:	001e7f13          	andi	t5,t3,1
    4f4a:	01d54eb3          	xor	t4,a0,t4
    4f4e:	43ee950b          	th.mvnez	a0,t4,t5
    4f52:	8082                	ret
    4f54:	00000013          	nop
    4f58:	00000013          	nop
    4f5c:	00000013          	nop

0000000000004f60 <crcu16>:
    4f60:	0ff57793          	zext.b	a5,a0
    4f64:	6829                	lui	a6,0xa
    4f66:	00180313          	addi	t1,a6,1 # a001 <_vsnprintf+0x1441>
    4f6a:	00b7c633          	xor	a2,a5,a1
    4f6e:	0015d71b          	srliw	a4,a1,0x1
    4f72:	00167293          	andi	t0,a2,1
    4f76:	006743b3          	xor	t2,a4,t1
    4f7a:	8185                	srli	a1,a1,0x1
    4f7c:	4055938b          	th.mveqz	t2,a1,t0
    4f80:	1c15368b          	th.extu	a3,a0,7,1
    4f84:	0076ce33          	xor	t3,a3,t2
    4f88:	0013df13          	srli	t5,t2,0x1
    4f8c:	001e7e93          	andi	t4,t3,1
    4f90:	006f4fb3          	xor	t6,t5,t1
    4f94:	41df1f8b          	th.mveqz	t6,t5,t4
    4f98:	0027d893          	srli	a7,a5,0x2
    4f9c:	01f8c6b3          	xor	a3,a7,t6
    4fa0:	001fd593          	srli	a1,t6,0x1
    4fa4:	0016f613          	andi	a2,a3,1
    4fa8:	0065c733          	xor	a4,a1,t1
    4fac:	40c5970b          	th.mveqz	a4,a1,a2
    4fb0:	0037d293          	srli	t0,a5,0x3
    4fb4:	00e2c3b3          	xor	t2,t0,a4
    4fb8:	00175e13          	srli	t3,a4,0x1
    4fbc:	0013f893          	andi	a7,t2,1
    4fc0:	006e4eb3          	xor	t4,t3,t1
    4fc4:	411e1e8b          	th.mveqz	t4,t3,a7
    4fc8:	0047d813          	srli	a6,a5,0x4
    4fcc:	01d84fb3          	xor	t6,a6,t4
    4fd0:	001ed693          	srli	a3,t4,0x1
    4fd4:	001ff293          	andi	t0,t6,1
    4fd8:	0066c733          	xor	a4,a3,t1
    4fdc:	4056970b          	th.mveqz	a4,a3,t0
    4fe0:	0057df13          	srli	t5,a5,0x5
    4fe4:	00ef45b3          	xor	a1,t5,a4
    4fe8:	00175393          	srli	t2,a4,0x1
    4fec:	0015f813          	andi	a6,a1,1
    4ff0:	0063c8b3          	xor	a7,t2,t1
    4ff4:	4103988b          	th.mveqz	a7,t2,a6
    4ff8:	0067d613          	srli	a2,a5,0x6
    4ffc:	01164e33          	xor	t3,a2,a7
    5000:	0018df13          	srli	t5,a7,0x1
    5004:	001e7e93          	andi	t4,t3,1
    5008:	006f4fb3          	xor	t6,t5,t1
    500c:	41df1f8b          	th.mveqz	t6,t5,t4
    5010:	839d                	srli	a5,a5,0x7
    5012:	01f7c2b3          	xor	t0,a5,t6
    5016:	001fd713          	srli	a4,t6,0x1
    501a:	0012f613          	andi	a2,t0,1
    501e:	006746b3          	xor	a3,a4,t1
    5022:	00855813          	srli	a6,a0,0x8
    5026:	42c6970b          	th.mvnez	a4,a3,a2
    502a:	00e845b3          	xor	a1,a6,a4
    502e:	0017589b          	srliw	a7,a4,0x1
    5032:	0068ce33          	xor	t3,a7,t1
    5036:	0015f393          	andi	t2,a1,1
    503a:	00175793          	srli	a5,a4,0x1
    503e:	427e178b          	th.mvnez	a5,t3,t2
    5042:	8125                	srli	a0,a0,0x9
    5044:	00f54f33          	xor	t5,a0,a5
    5048:	0017d293          	srli	t0,a5,0x1
    504c:	001f7f93          	andi	t6,t5,1
    5050:	0062c633          	xor	a2,t0,t1
    5054:	43f6128b          	th.mvnez	t0,a2,t6
    5058:	00285e93          	srli	t4,a6,0x2
    505c:	005ec733          	xor	a4,t4,t0
    5060:	0012d893          	srli	a7,t0,0x1
    5064:	00177393          	andi	t2,a4,1
    5068:	0068c6b3          	xor	a3,a7,t1
    506c:	4078968b          	th.mveqz	a3,a7,t2
    5070:	00385593          	srli	a1,a6,0x3
    5074:	00d5c7b3          	xor	a5,a1,a3
    5078:	0016de93          	srli	t4,a3,0x1
    507c:	0017fe13          	andi	t3,a5,1
    5080:	006ecf33          	xor	t5,t4,t1
    5084:	41ce9f0b          	th.mveqz	t5,t4,t3
    5088:	00485513          	srli	a0,a6,0x4
    508c:	01e542b3          	xor	t0,a0,t5
    5090:	001f5593          	srli	a1,t5,0x1
    5094:	0012f613          	andi	a2,t0,1
    5098:	0065c733          	xor	a4,a1,t1
    509c:	40c5970b          	th.mveqz	a4,a1,a2
    50a0:	00585f93          	srli	t6,a6,0x5
    50a4:	00efc8b3          	xor	a7,t6,a4
    50a8:	00175693          	srli	a3,a4,0x1
    50ac:	0018f513          	andi	a0,a7,1
    50b0:	0066ce33          	xor	t3,a3,t1
    50b4:	40a69e0b          	th.mveqz	t3,a3,a0
    50b8:	00685393          	srli	t2,a6,0x6
    50bc:	001e5f13          	srli	t5,t3,0x1
    50c0:	01c3c7b3          	xor	a5,t2,t3
    50c4:	0017fe93          	andi	t4,a5,1
    50c8:	006f4fb3          	xor	t6,t5,t1
    50cc:	41df1f8b          	th.mveqz	t6,t5,t4
    50d0:	00785813          	srli	a6,a6,0x7
    50d4:	001fd513          	srli	a0,t6,0x1
    50d8:	01f842b3          	xor	t0,a6,t6
    50dc:	0012f613          	andi	a2,t0,1
    50e0:	006545b3          	xor	a1,a0,t1
    50e4:	42c5950b          	th.mvnez	a0,a1,a2
    50e8:	8082                	ret
    50ea:	00000013          	nop
    50ee:	0001                	nop

00000000000050f0 <crcu32>:
    50f0:	0ff57793          	zext.b	a5,a0
    50f4:	6829                	lui	a6,0xa
    50f6:	00180313          	addi	t1,a6,1 # a001 <_vsnprintf+0x1441>
    50fa:	00b7c633          	xor	a2,a5,a1
    50fe:	0015d71b          	srliw	a4,a1,0x1
    5102:	00167293          	andi	t0,a2,1
    5106:	006743b3          	xor	t2,a4,t1
    510a:	8185                	srli	a1,a1,0x1
    510c:	4055938b          	th.mveqz	t2,a1,t0
    5110:	1c15368b          	th.extu	a3,a0,7,1
    5114:	0076ce33          	xor	t3,a3,t2
    5118:	0013df13          	srli	t5,t2,0x1
    511c:	001e7e93          	andi	t4,t3,1
    5120:	006f4fb3          	xor	t6,t5,t1
    5124:	41df1f8b          	th.mveqz	t6,t5,t4
    5128:	0027d893          	srli	a7,a5,0x2
    512c:	01f8c6b3          	xor	a3,a7,t6
    5130:	001fd593          	srli	a1,t6,0x1
    5134:	0016f613          	andi	a2,a3,1
    5138:	0065c733          	xor	a4,a1,t1
    513c:	40c5970b          	th.mveqz	a4,a1,a2
    5140:	0037d293          	srli	t0,a5,0x3
    5144:	00e2c3b3          	xor	t2,t0,a4
    5148:	00175e13          	srli	t3,a4,0x1
    514c:	0013f893          	andi	a7,t2,1
    5150:	006e4eb3          	xor	t4,t3,t1
    5154:	411e1e8b          	th.mveqz	t4,t3,a7
    5158:	0047d813          	srli	a6,a5,0x4
    515c:	01d84fb3          	xor	t6,a6,t4
    5160:	001ed693          	srli	a3,t4,0x1
    5164:	001ff293          	andi	t0,t6,1
    5168:	0066c733          	xor	a4,a3,t1
    516c:	4056970b          	th.mveqz	a4,a3,t0
    5170:	0057df13          	srli	t5,a5,0x5
    5174:	00ef45b3          	xor	a1,t5,a4
    5178:	00175393          	srli	t2,a4,0x1
    517c:	0015f813          	andi	a6,a1,1
    5180:	0063c8b3          	xor	a7,t2,t1
    5184:	4103988b          	th.mveqz	a7,t2,a6
    5188:	0067d613          	srli	a2,a5,0x6
    518c:	0018df13          	srli	t5,a7,0x1
    5190:	0077de13          	srli	t3,a5,0x7
    5194:	011647b3          	xor	a5,a2,a7
    5198:	0017fe93          	andi	t4,a5,1
    519c:	006f4fb3          	xor	t6,t5,t1
    51a0:	41df1f8b          	th.mveqz	t6,t5,t4
    51a4:	01fe42b3          	xor	t0,t3,t6
    51a8:	001fd693          	srli	a3,t6,0x1
    51ac:	0012f713          	andi	a4,t0,1
    51b0:	0066c333          	xor	t1,a3,t1
    51b4:	42e3168b          	th.mvnez	a3,t1,a4
    51b8:	7669                	lui	a2,0xffffa
    51ba:	00160393          	addi	t2,a2,1 # ffffffffffffa001 <__kernel_stack+0xfffffffffff0c001>
    51be:	3c85388b          	th.extu	a7,a0,15,8
    51c2:	0016d79b          	srliw	a5,a3,0x1
    51c6:	00d8c5b3          	xor	a1,a7,a3
    51ca:	0077cf33          	xor	t5,a5,t2
    51ce:	0015fe13          	andi	t3,a1,1
    51d2:	3c0f3f8b          	th.extu	t6,t5,15,0
    51d6:	4016be8b          	th.extu	t4,a3,16,1
    51da:	43cf9e8b          	th.mvnez	t4,t6,t3
    51de:	001ed693          	srli	a3,t4,0x1
    51e2:	3c95380b          	th.extu	a6,a0,15,9
    51e6:	01d84733          	xor	a4,a6,t4
    51ea:	0076c633          	xor	a2,a3,t2
    51ee:	00177313          	andi	t1,a4,1
    51f2:	3c063e0b          	th.extu	t3,a2,15,0
    51f6:	40669e0b          	th.mveqz	t3,a3,t1
    51fa:	001e5e93          	srli	t4,t3,0x1
    51fe:	0028d293          	srli	t0,a7,0x2
    5202:	01c2c5b3          	xor	a1,t0,t3
    5206:	007ecf33          	xor	t5,t4,t2
    520a:	0015f793          	andi	a5,a1,1
    520e:	3c0f3f8b          	th.extu	t6,t5,15,0
    5212:	40fe9f8b          	th.mveqz	t6,t4,a5
    5216:	001fd693          	srli	a3,t6,0x1
    521a:	0038d813          	srli	a6,a7,0x3
    521e:	01f84733          	xor	a4,a6,t6
    5222:	0076c633          	xor	a2,a3,t2
    5226:	00177313          	andi	t1,a4,1
    522a:	3c063e0b          	th.extu	t3,a2,15,0
    522e:	40669e0b          	th.mveqz	t3,a3,t1
    5232:	001e5e93          	srli	t4,t3,0x1
    5236:	0048d293          	srli	t0,a7,0x4
    523a:	01c2c5b3          	xor	a1,t0,t3
    523e:	007ecf33          	xor	t5,t4,t2
    5242:	0015f793          	andi	a5,a1,1
    5246:	3c0f3f8b          	th.extu	t6,t5,15,0
    524a:	40fe9f8b          	th.mveqz	t6,t4,a5
    524e:	001fd693          	srli	a3,t6,0x1
    5252:	0058d813          	srli	a6,a7,0x5
    5256:	01f84733          	xor	a4,a6,t6
    525a:	0076c633          	xor	a2,a3,t2
    525e:	00177313          	andi	t1,a4,1
    5262:	3c063e0b          	th.extu	t3,a2,15,0
    5266:	40669e0b          	th.mveqz	t3,a3,t1
    526a:	001e5793          	srli	a5,t3,0x1
    526e:	0068d293          	srli	t0,a7,0x6
    5272:	01c2c833          	xor	a6,t0,t3
    5276:	0077ceb3          	xor	t4,a5,t2
    527a:	00187593          	andi	a1,a6,1
    527e:	3c0ebf0b          	th.extu	t5,t4,15,0
    5282:	40b79f0b          	th.mveqz	t5,a5,a1
    5286:	001f5713          	srli	a4,t5,0x1
    528a:	0078d893          	srli	a7,a7,0x7
    528e:	01e8cfb3          	xor	t6,a7,t5
    5292:	00774333          	xor	t1,a4,t2
    5296:	001ff293          	andi	t0,t6,1
    529a:	3c03368b          	th.extu	a3,t1,15,0
    529e:	4256970b          	th.mvnez	a4,a3,t0
    52a2:	5d053e0b          	th.extu	t3,a0,23,16
    52a6:	0017559b          	srliw	a1,a4,0x1
    52aa:	00ee4633          	xor	a2,t3,a4
    52ae:	0075ceb3          	xor	t4,a1,t2
    52b2:	00167813          	andi	a6,a2,1
    52b6:	3c0ebf0b          	th.extu	t5,t4,15,0
    52ba:	00175793          	srli	a5,a4,0x1
    52be:	430f178b          	th.mvnez	a5,t5,a6
    52c2:	0017d713          	srli	a4,a5,0x1
    52c6:	5d15388b          	th.extu	a7,a0,23,17
    52ca:	00f8c2b3          	xor	t0,a7,a5
    52ce:	007746b3          	xor	a3,a4,t2
    52d2:	0012f313          	andi	t1,t0,1
    52d6:	3c06b88b          	th.extu	a7,a3,15,0
    52da:	4067188b          	th.mveqz	a7,a4,t1
    52de:	0018d793          	srli	a5,a7,0x1
    52e2:	002e5f93          	srli	t6,t3,0x2
    52e6:	011fc633          	xor	a2,t6,a7
    52ea:	0077ceb3          	xor	t4,a5,t2
    52ee:	00167593          	andi	a1,a2,1
    52f2:	3c0ebf0b          	th.extu	t5,t4,15,0
    52f6:	40b79f0b          	th.mveqz	t5,a5,a1
    52fa:	001f5713          	srli	a4,t5,0x1
    52fe:	003e5813          	srli	a6,t3,0x3
    5302:	01e842b3          	xor	t0,a6,t5
    5306:	007746b3          	xor	a3,a4,t2
    530a:	0012f313          	andi	t1,t0,1
    530e:	3c06b88b          	th.extu	a7,a3,15,0
    5312:	4067188b          	th.mveqz	a7,a4,t1
    5316:	0018d793          	srli	a5,a7,0x1
    531a:	004e5f93          	srli	t6,t3,0x4
    531e:	011fc633          	xor	a2,t6,a7
    5322:	0077ceb3          	xor	t4,a5,t2
    5326:	00167593          	andi	a1,a2,1
    532a:	3c0ebf0b          	th.extu	t5,t4,15,0
    532e:	40b79f0b          	th.mveqz	t5,a5,a1
    5332:	001f5713          	srli	a4,t5,0x1
    5336:	005e5813          	srli	a6,t3,0x5
    533a:	01e842b3          	xor	t0,a6,t5
    533e:	007746b3          	xor	a3,a4,t2
    5342:	0012f313          	andi	t1,t0,1
    5346:	3c06b88b          	th.extu	a7,a3,15,0
    534a:	4067188b          	th.mveqz	a7,a4,t1
    534e:	0018d613          	srli	a2,a7,0x1
    5352:	006e5f93          	srli	t6,t3,0x6
    5356:	011fc833          	xor	a6,t6,a7
    535a:	007647b3          	xor	a5,a2,t2
    535e:	00187593          	andi	a1,a6,1
    5362:	3c07be8b          	th.extu	t4,a5,15,0
    5366:	40b61e8b          	th.mveqz	t4,a2,a1
    536a:	001ed293          	srli	t0,t4,0x1
    536e:	007e5e13          	srli	t3,t3,0x7
    5372:	01de4f33          	xor	t5,t3,t4
    5376:	0072c333          	xor	t1,t0,t2
    537a:	001f7f93          	andi	t6,t5,1
    537e:	3c03370b          	th.extu	a4,t1,15,0
    5382:	43f7128b          	th.mvnez	t0,a4,t6
    5386:	0185569b          	srliw	a3,a0,0x18
    538a:	0012d81b          	srliw	a6,t0,0x1
    538e:	0056c8b3          	xor	a7,a3,t0
    5392:	007845b3          	xor	a1,a6,t2
    5396:	0018fe13          	andi	t3,a7,1
    539a:	3c05b60b          	th.extu	a2,a1,15,0
    539e:	0012d793          	srli	a5,t0,0x1
    53a2:	43c6178b          	th.mvnez	a5,a2,t3
    53a6:	0017d293          	srli	t0,a5,0x1
    53aa:	0195551b          	srliw	a0,a0,0x19
    53ae:	00f54f33          	xor	t5,a0,a5
    53b2:	0072c333          	xor	t1,t0,t2
    53b6:	001f7f93          	andi	t6,t5,1
    53ba:	3c03370b          	th.extu	a4,t1,15,0
    53be:	41f2970b          	th.mveqz	a4,t0,t6
    53c2:	00175813          	srli	a6,a4,0x1
    53c6:	0026de93          	srli	t4,a3,0x2
    53ca:	00eec8b3          	xor	a7,t4,a4
    53ce:	007847b3          	xor	a5,a6,t2
    53d2:	0018fe13          	andi	t3,a7,1
    53d6:	3c07b60b          	th.extu	a2,a5,15,0
    53da:	41c8160b          	th.mveqz	a2,a6,t3
    53de:	00165f93          	srli	t6,a2,0x1
    53e2:	0036d513          	srli	a0,a3,0x3
    53e6:	00c54eb3          	xor	t4,a0,a2
    53ea:	007fc2b3          	xor	t0,t6,t2
    53ee:	001eff13          	andi	t5,t4,1
    53f2:	3c02b30b          	th.extu	t1,t0,15,0
    53f6:	41ef930b          	th.mveqz	t1,t6,t5
    53fa:	00135e13          	srli	t3,t1,0x1
    53fe:	0046d593          	srli	a1,a3,0x4
    5402:	0065c733          	xor	a4,a1,t1
    5406:	007e4833          	xor	a6,t3,t2
    540a:	00177893          	andi	a7,a4,1
    540e:	3c08378b          	th.extu	a5,a6,15,0
    5412:	411e178b          	th.mveqz	a5,t3,a7
    5416:	0056d513          	srli	a0,a3,0x5
    541a:	0017df13          	srli	t5,a5,0x1
    541e:	00f54633          	xor	a2,a0,a5
    5422:	007f4fb3          	xor	t6,t5,t2
    5426:	00167e93          	andi	t4,a2,1
    542a:	3c0fb28b          	th.extu	t0,t6,15,0
    542e:	41df128b          	th.mveqz	t0,t5,t4
    5432:	0066d593          	srli	a1,a3,0x6
    5436:	0012d893          	srli	a7,t0,0x1
    543a:	0055c333          	xor	t1,a1,t0
    543e:	0078c733          	xor	a4,a7,t2
    5442:	00137513          	andi	a0,t1,1
    5446:	3c073e0b          	th.extu	t3,a4,15,0
    544a:	40a89e0b          	th.mveqz	t3,a7,a0
    544e:	001e5613          	srli	a2,t3,0x1
    5452:	829d                	srli	a3,a3,0x7
    5454:	01c6c833          	xor	a6,a3,t3
    5458:	007643b3          	xor	t2,a2,t2
    545c:	00187593          	andi	a1,a6,1
    5460:	3c03b50b          	th.extu	a0,t2,15,0
    5464:	40b6150b          	th.mveqz	a0,a2,a1
    5468:	8082                	ret
    546a:	00000013          	nop
    546e:	0001                	nop

0000000000005470 <crc16>:
    5470:	0ff57793          	zext.b	a5,a0
    5474:	6829                	lui	a6,0xa
    5476:	00180313          	addi	t1,a6,1 # a001 <_vsnprintf+0x1441>
    547a:	00b7c633          	xor	a2,a5,a1
    547e:	0015d71b          	srliw	a4,a1,0x1
    5482:	00167293          	andi	t0,a2,1
    5486:	006743b3          	xor	t2,a4,t1
    548a:	8185                	srli	a1,a1,0x1
    548c:	4055938b          	th.mveqz	t2,a1,t0
    5490:	1c15368b          	th.extu	a3,a0,7,1
    5494:	0076ce33          	xor	t3,a3,t2
    5498:	0013df13          	srli	t5,t2,0x1
    549c:	001e7e93          	andi	t4,t3,1
    54a0:	006f4fb3          	xor	t6,t5,t1
    54a4:	41df1f8b          	th.mveqz	t6,t5,t4
    54a8:	0027d893          	srli	a7,a5,0x2
    54ac:	01f8c6b3          	xor	a3,a7,t6
    54b0:	001fd593          	srli	a1,t6,0x1
    54b4:	0016f613          	andi	a2,a3,1
    54b8:	0065c733          	xor	a4,a1,t1
    54bc:	40c5970b          	th.mveqz	a4,a1,a2
    54c0:	0037d293          	srli	t0,a5,0x3
    54c4:	00e2c3b3          	xor	t2,t0,a4
    54c8:	00175e13          	srli	t3,a4,0x1
    54cc:	0013f893          	andi	a7,t2,1
    54d0:	006e4eb3          	xor	t4,t3,t1
    54d4:	411e1e8b          	th.mveqz	t4,t3,a7
    54d8:	0047d813          	srli	a6,a5,0x4
    54dc:	01d84fb3          	xor	t6,a6,t4
    54e0:	001ed693          	srli	a3,t4,0x1
    54e4:	001ff293          	andi	t0,t6,1
    54e8:	0066c733          	xor	a4,a3,t1
    54ec:	4056970b          	th.mveqz	a4,a3,t0
    54f0:	0057df13          	srli	t5,a5,0x5
    54f4:	00ef45b3          	xor	a1,t5,a4
    54f8:	00175393          	srli	t2,a4,0x1
    54fc:	0015f813          	andi	a6,a1,1
    5500:	0063c8b3          	xor	a7,t2,t1
    5504:	4103988b          	th.mveqz	a7,t2,a6
    5508:	0067d613          	srli	a2,a5,0x6
    550c:	01164e33          	xor	t3,a2,a7
    5510:	0018df13          	srli	t5,a7,0x1
    5514:	001e7e93          	andi	t4,t3,1
    5518:	006f4fb3          	xor	t6,t5,t1
    551c:	41df1f8b          	th.mveqz	t6,t5,t4
    5520:	839d                	srli	a5,a5,0x7
    5522:	01f7c2b3          	xor	t0,a5,t6
    5526:	001fd713          	srli	a4,t6,0x1
    552a:	0012f593          	andi	a1,t0,1
    552e:	00674333          	xor	t1,a4,t1
    5532:	42b3170b          	th.mvnez	a4,t1,a1
    5536:	76e9                	lui	a3,0xffffa
    5538:	00168813          	addi	a6,a3,1 # ffffffffffffa001 <__kernel_stack+0xfffffffffff0c001>
    553c:	3c85338b          	th.extu	t2,a0,15,8
    5540:	0017579b          	srliw	a5,a4,0x1
    5544:	00e3c633          	xor	a2,t2,a4
    5548:	0107ceb3          	xor	t4,a5,a6
    554c:	00167893          	andi	a7,a2,1
    5550:	3c0ebf0b          	th.extu	t5,t4,15,0
    5554:	40173e0b          	th.extu	t3,a4,16,1
    5558:	431f1e0b          	th.mvnez	t3,t5,a7
    555c:	001e5713          	srli	a4,t3,0x1
    5560:	3c95350b          	th.extu	a0,a0,15,9
    5564:	01c542b3          	xor	t0,a0,t3
    5568:	010746b3          	xor	a3,a4,a6
    556c:	0012f593          	andi	a1,t0,1
    5570:	3c06b30b          	th.extu	t1,a3,15,0
    5574:	40b7130b          	th.mveqz	t1,a4,a1
    5578:	00135793          	srli	a5,t1,0x1
    557c:	0023df93          	srli	t6,t2,0x2
    5580:	006fc633          	xor	a2,t6,t1
    5584:	0107ce33          	xor	t3,a5,a6
    5588:	00167893          	andi	a7,a2,1
    558c:	3c0e3e8b          	th.extu	t4,t3,15,0
    5590:	41179e8b          	th.mveqz	t4,a5,a7
    5594:	001ed593          	srli	a1,t4,0x1
    5598:	0033d513          	srli	a0,t2,0x3
    559c:	01d54fb3          	xor	t6,a0,t4
    55a0:	0105c733          	xor	a4,a1,a6
    55a4:	001ff293          	andi	t0,t6,1
    55a8:	3c07368b          	th.extu	a3,a4,15,0
    55ac:	4055968b          	th.mveqz	a3,a1,t0
    55b0:	0016d613          	srli	a2,a3,0x1
    55b4:	0043df13          	srli	t5,t2,0x4
    55b8:	00df4533          	xor	a0,t5,a3
    55bc:	010647b3          	xor	a5,a2,a6
    55c0:	00157893          	andi	a7,a0,1
    55c4:	3c07be0b          	th.extu	t3,a5,15,0
    55c8:	41161e0b          	th.mveqz	t3,a2,a7
    55cc:	001e5293          	srli	t0,t3,0x1
    55d0:	0053d313          	srli	t1,t2,0x5
    55d4:	01c34f33          	xor	t5,t1,t3
    55d8:	0102c5b3          	xor	a1,t0,a6
    55dc:	001f7f93          	andi	t6,t5,1
    55e0:	3c05b70b          	th.extu	a4,a1,15,0
    55e4:	41f2970b          	th.mveqz	a4,t0,t6
    55e8:	00175513          	srli	a0,a4,0x1
    55ec:	0063de93          	srli	t4,t2,0x6
    55f0:	010548b3          	xor	a7,a0,a6
    55f4:	00eec6b3          	xor	a3,t4,a4
    55f8:	0016f313          	andi	t1,a3,1
    55fc:	3c08b60b          	th.extu	a2,a7,15,0
    5600:	4065160b          	th.mveqz	a2,a0,t1
    5604:	00165e93          	srli	t4,a2,0x1
    5608:	0073d393          	srli	t2,t2,0x7
    560c:	00c3c7b3          	xor	a5,t2,a2
    5610:	010ec833          	xor	a6,t4,a6
    5614:	0017fe13          	andi	t3,a5,1
    5618:	3c08350b          	th.extu	a0,a6,15,0
    561c:	41ce950b          	th.mveqz	a0,t4,t3
    5620:	8082                	ret
    5622:	0001                	nop
    5624:	00000013          	nop
    5628:	00000013          	nop
    562c:	00000013          	nop

0000000000005630 <check_data_types>:
    5630:	4501                	li	a0,0
    5632:	8082                	ret
	...

0000000000005640 <ecvt>:
    5640:	7159                	addi	sp,sp,-112
    5642:	f20007d3          	fmv.d.x	fa5,zero
    5646:	eca6                	sd	s1,88(sp)
    5648:	f0a2                	sd	s0,96(sp)
    564a:	0005041b          	sext.w	s0,a0
    564e:	04e00793          	li	a5,78
    5652:	00042693          	slti	a3,s0,0
    5656:	a2f512d3          	flt.d	t0,fa0,fa5
    565a:	fc56                	sd	s5,56(sp)
    565c:	e0d2                	sd	s4,64(sp)
    565e:	e4ce                	sd	s3,72(sp)
    5660:	e8ca                	sd	s2,80(sp)
    5662:	42d0140b          	th.mvnez	s0,zero,a3
    5666:	00a7a533          	slt	a0,a5,a0
    566a:	b422                	fsd	fs0,40(sp)
    566c:	b026                	fsd	fs1,32(sp)
    566e:	ac4a                	fsd	fs2,24(sp)
    5670:	f486                	sd	ra,104(sp)
    5672:	892e                	mv	s2,a1
    5674:	42a7940b          	th.mvnez	s0,a5,a0
    5678:	6c029063          	bnez	t0,5d38 <ecvt+0x6f8>
    567c:	00062023          	sw	zero,0(a2)
    5680:	850a                	mv	a0,sp
    5682:	0f40a0ef          	jal	f776 <modf>
    5686:	2e02                	fld	ft8,0(sp)
    5688:	f2000953          	fmv.d.x	fs2,zero
    568c:	22a50453          	fmv.d	fs0,fa0
    5690:	a32e23d3          	feq.d	t2,ft8,fs2
    5694:	5c039663          	bnez	t2,5c60 <ecvt+0x620>
    5698:	00041537          	lui	a0,0x41
    569c:	62c5                	lui	t0,0x11
    569e:	6345                	lui	t1,0x11
    56a0:	a84e                	fsd	fs3,16(sp)
    56a2:	fe050493          	addi	s1,a0,-32 # 40fe0 <CVTBUF>
    56a6:	ba82b487          	fld	fs1,-1112(t0) # 10ba8 <errpat+0x38>
    56aa:	bb033987          	fld	fs3,-1104(t1) # 10bb0 <errpat+0x40>
    56ae:	05048993          	addi	s3,s1,80
    56b2:	f85a                	sd	s6,48(sp)
    56b4:	4a81                	li	s5,0
    56b6:	8b4e                	mv	s6,s3
    56b8:	1a9e7553          	fdiv.d	fa0,ft8,fs1
    56bc:	850a                	mv	a0,sp
    56be:	1b7d                	addi	s6,s6,-1
    56c0:	2a85                	addiw	s5,s5,1
    56c2:	8a5a                	mv	s4,s6
    56c4:	0b20a0ef          	jal	f776 <modf>
    56c8:	a42a                	fsd	fa0,8(sp)
    56ca:	03357553          	fadd.d	fa0,fa0,fs3
    56ce:	2102                	fld	ft2,0(sp)
    56d0:	8356                	mv	t1,s5
    56d2:	129570d3          	fmul.d	ft1,fa0,fs1
    56d6:	a3212753          	feq.d	a4,ft2,fs2
    56da:	c20093d3          	fcvt.w.d	t2,ft1,rtz
    56de:	0303859b          	addiw	a1,t2,48
    56e2:	0ff5f293          	zext.b	t0,a1
    56e6:	005b0023          	sb	t0,0(s6)
    56ea:	ef59                	bnez	a4,5788 <ecvt+0x148>
    56ec:	1a917553          	fdiv.d	fa0,ft2,fs1
    56f0:	850a                	mv	a0,sp
    56f2:	2a85                	addiw	s5,s5,1
    56f4:	0820a0ef          	jal	f776 <modf>
    56f8:	033571d3          	fadd.d	ft3,fa0,fs3
    56fc:	2282                	fld	ft5,0(sp)
    56fe:	a42a                	fsd	fa0,8(sp)
    5700:	1291f253          	fmul.d	ft4,ft3,fs1
    5704:	a322a8d3          	feq.d	a7,ft5,fs2
    5708:	8356                	mv	t1,s5
    570a:	c2021653          	fcvt.w.d	a2,ft4,rtz
    570e:	0306081b          	addiw	a6,a2,48
    5712:	0ff87293          	zext.b	t0,a6
    5716:	09fb528b          	th.sbib	t0,(s6),-1,0
    571a:	06089763          	bnez	a7,5788 <ecvt+0x148>
    571e:	1a92f553          	fdiv.d	fa0,ft5,fs1
    5722:	850a                	mv	a0,sp
    5724:	2a85                	addiw	s5,s5,1
    5726:	ffea0b13          	addi	s6,s4,-2 # ffffffffffffeffe <__kernel_stack+0xfffffffffff10ffe>
    572a:	04c0a0ef          	jal	f776 <modf>
    572e:	03357353          	fadd.d	ft6,fa0,fs3
    5732:	2582                	fld	fa1,0(sp)
    5734:	a42a                	fsd	fa0,8(sp)
    5736:	129373d3          	fmul.d	ft7,ft6,fs1
    573a:	a325af53          	feq.d	t5,fa1,fs2
    573e:	8356                	mv	t1,s5
    5740:	c2039e53          	fcvt.w.d	t3,ft7,rtz
    5744:	030e0e9b          	addiw	t4,t3,48
    5748:	0ffef293          	zext.b	t0,t4
    574c:	fe5a0f23          	sb	t0,-2(s4)
    5750:	020f1c63          	bnez	t5,5788 <ecvt+0x148>
    5754:	1a95f553          	fdiv.d	fa0,fa1,fs1
    5758:	850a                	mv	a0,sp
    575a:	2a85                	addiw	s5,s5,1
    575c:	ffda0b13          	addi	s6,s4,-3
    5760:	0160a0ef          	jal	f776 <modf>
    5764:	03357853          	fadd.d	fa6,fa0,fs3
    5768:	2e02                	fld	ft8,0(sp)
    576a:	a42a                	fsd	fa0,8(sp)
    576c:	129878d3          	fmul.d	fa7,fa6,fs1
    5770:	a32e26d3          	feq.d	a3,ft8,fs2
    5774:	8356                	mv	t1,s5
    5776:	c2089fd3          	fcvt.w.d	t6,fa7,rtz
    577a:	030f879b          	addiw	a5,t6,48
    577e:	0ff7f293          	zext.b	t0,a5
    5782:	fe5a0ea3          	sb	t0,-3(s4)
    5786:	da8d                	beqz	a3,56b8 <ecvt+0x78>
    5788:	5d3b7e63          	bgeu	s6,s3,5d64 <ecvt+0x724>
    578c:	fffb4a93          	not	s5,s6
    5790:	01598533          	add	a0,s3,s5
    5794:	00757a13          	andi	s4,a0,7
    5798:	875a                	mv	a4,s6
    579a:	8ea6                	mv	t4,s1
    579c:	0a0a0863          	beqz	s4,584c <ecvt+0x20c>
    57a0:	181ed28b          	th.sbia	t0,(t4),1,0
    57a4:	4385                	li	t2,1
    57a6:	8817428b          	th.lbuib	t0,(a4),1,0
    57aa:	0a7a0163          	beq	s4,t2,584c <ecvt+0x20c>
    57ae:	4589                	li	a1,2
    57b0:	04ba0563          	beq	s4,a1,57fa <ecvt+0x1ba>
    57b4:	460d                	li	a2,3
    57b6:	02ca0e63          	beq	s4,a2,57f2 <ecvt+0x1b2>
    57ba:	4811                	li	a6,4
    57bc:	030a0763          	beq	s4,a6,57ea <ecvt+0x1aa>
    57c0:	4895                	li	a7,5
    57c2:	031a0063          	beq	s4,a7,57e2 <ecvt+0x1a2>
    57c6:	4e19                	li	t3,6
    57c8:	01ca0963          	beq	s4,t3,57da <ecvt+0x19a>
    57cc:	875a                	mv	a4,s6
    57ce:	005480a3          	sb	t0,1(s1)
    57d2:	8827428b          	th.lbuib	t0,(a4),2,0
    57d6:	00248e93          	addi	t4,s1,2
    57da:	181ed28b          	th.sbia	t0,(t4),1,0
    57de:	8817428b          	th.lbuib	t0,(a4),1,0
    57e2:	181ed28b          	th.sbia	t0,(t4),1,0
    57e6:	8817428b          	th.lbuib	t0,(a4),1,0
    57ea:	181ed28b          	th.sbia	t0,(t4),1,0
    57ee:	8817428b          	th.lbuib	t0,(a4),1,0
    57f2:	181ed28b          	th.sbia	t0,(t4),1,0
    57f6:	8817428b          	th.lbuib	t0,(a4),1,0
    57fa:	181ed28b          	th.sbia	t0,(t4),1,0
    57fe:	8817428b          	th.lbuib	t0,(a4),1,0
    5802:	00170793          	addi	a5,a4,1
    5806:	005e8023          	sb	t0,0(t4)
    580a:	04f98763          	beq	s3,a5,5858 <ecvt+0x218>
    580e:	00174883          	lbu	a7,1(a4)
    5812:	0ea1                	addi	t4,t4,8
    5814:	ff1e8ca3          	sb	a7,-7(t4)
    5818:	00274603          	lbu	a2,2(a4)
    581c:	fece8d23          	sb	a2,-6(t4)
    5820:	00374f83          	lbu	t6,3(a4)
    5824:	fffe8da3          	sb	t6,-5(t4)
    5828:	00474283          	lbu	t0,4(a4)
    582c:	fe5e8e23          	sb	t0,-4(t4)
    5830:	00574a83          	lbu	s5,5(a4)
    5834:	ff5e8ea3          	sb	s5,-3(t4)
    5838:	00674a03          	lbu	s4,6(a4)
    583c:	ff4e8f23          	sb	s4,-2(t4)
    5840:	00774683          	lbu	a3,7(a4)
    5844:	fede8fa3          	sb	a3,-1(t4)
    5848:	8887428b          	th.lbuib	t0,(a4),8,0
    584c:	00170793          	addi	a5,a4,1
    5850:	005e8023          	sb	t0,0(t4)
    5854:	faf99de3          	bne	s3,a5,580e <ecvt+0x1ce>
    5858:	9426                	add	s0,s0,s1
    585a:	00692023          	sw	t1,0(s2)
    585e:	4e946363          	bltu	s0,s1,5d44 <ecvt+0x704>
    5862:	01348f33          	add	t5,s1,s3
    5866:	416f0a33          	sub	s4,t5,s6
    586a:	29c2                	fld	fs3,16(sp)
    586c:	7b42                	ld	s6,48(sp)
    586e:	11446963          	bltu	s0,s4,5980 <ecvt+0x340>
    5872:	414982b3          	sub	t0,s3,s4
    5876:	6fc5                	lui	t6,0x11
    5878:	0032fa93          	andi	s5,t0,3
    587c:	ba8fb907          	fld	fs2,-1112(t6) # 10ba8 <errpat+0x38>
    5880:	060a8c63          	beqz	s5,58f8 <ecvt+0x2b8>
    5884:	0f3a7e63          	bgeu	s4,s3,5980 <ecvt+0x340>
    5888:	13247553          	fmul.d	fa0,fs0,fs2
    588c:	0028                	addi	a0,sp,8
    588e:	6e9090ef          	jal	f776 <modf>
    5892:	2ea2                	fld	ft9,8(sp)
    5894:	22a50453          	fmv.d	fs0,fa0
    5898:	c20e9353          	fcvt.w.d	t1,ft9,rtz
    589c:	0303069b          	addiw	a3,t1,48
    58a0:	181a568b          	th.sbia	a3,(s4),1,0
    58a4:	0d446e63          	bltu	s0,s4,5980 <ecvt+0x340>
    58a8:	4505                	li	a0,1
    58aa:	04aa8763          	beq	s5,a0,58f8 <ecvt+0x2b8>
    58ae:	4389                	li	t2,2
    58b0:	027a8263          	beq	s5,t2,58d4 <ecvt+0x294>
    58b4:	13257553          	fmul.d	fa0,fa0,fs2
    58b8:	0028                	addi	a0,sp,8
    58ba:	6bd090ef          	jal	f776 <modf>
    58be:	2f22                	fld	ft10,8(sp)
    58c0:	22a50453          	fmv.d	fs0,fa0
    58c4:	c20f15d3          	fcvt.w.d	a1,ft10,rtz
    58c8:	0305861b          	addiw	a2,a1,48
    58cc:	181a560b          	th.sbia	a2,(s4),1,0
    58d0:	0b446863          	bltu	s0,s4,5980 <ecvt+0x340>
    58d4:	13247553          	fmul.d	fa0,fs0,fs2
    58d8:	0028                	addi	a0,sp,8
    58da:	69d090ef          	jal	f776 <modf>
    58de:	2fa2                	fld	ft11,8(sp)
    58e0:	22a50453          	fmv.d	fs0,fa0
    58e4:	c20f9853          	fcvt.w.d	a6,ft11,rtz
    58e8:	0308089b          	addiw	a7,a6,48
    58ec:	181a588b          	th.sbia	a7,(s4),1,0
    58f0:	09446863          	bltu	s0,s4,5980 <ecvt+0x340>
    58f4:	00000013          	nop
    58f8:	093a7463          	bgeu	s4,s3,5980 <ecvt+0x340>
    58fc:	13247553          	fmul.d	fa0,fs0,fs2
    5900:	0028                	addi	a0,sp,8
    5902:	675090ef          	jal	f776 <modf>
    5906:	27a2                	fld	fa5,8(sp)
    5908:	8e52                	mv	t3,s4
    590a:	c2079753          	fcvt.w.d	a4,fa5,rtz
    590e:	03070e9b          	addiw	t4,a4,48
    5912:	181e5e8b          	th.sbia	t4,(t3),1,0
    5916:	07c46563          	bltu	s0,t3,5980 <ecvt+0x340>
    591a:	13257553          	fmul.d	fa0,fa0,fs2
    591e:	0028                	addi	a0,sp,8
    5920:	657090ef          	jal	f776 <modf>
    5924:	2722                	fld	fa4,8(sp)
    5926:	002a0793          	addi	a5,s4,2
    592a:	c2071f53          	fcvt.w.d	t5,fa4,rtz
    592e:	030f0f9b          	addiw	t6,t5,48
    5932:	01fa00a3          	sb	t6,1(s4)
    5936:	04f46563          	bltu	s0,a5,5980 <ecvt+0x340>
    593a:	13257553          	fmul.d	fa0,fa0,fs2
    593e:	0028                	addi	a0,sp,8
    5940:	637090ef          	jal	f776 <modf>
    5944:	2622                	fld	fa2,8(sp)
    5946:	003a0293          	addi	t0,s4,3
    594a:	c2061ad3          	fcvt.w.d	s5,fa2,rtz
    594e:	030a831b          	addiw	t1,s5,48
    5952:	006a0123          	sb	t1,2(s4)
    5956:	02546563          	bltu	s0,t0,5980 <ecvt+0x340>
    595a:	13257553          	fmul.d	fa0,fa0,fs2
    595e:	0028                	addi	a0,sp,8
    5960:	0a11                	addi	s4,s4,4
    5962:	615090ef          	jal	f776 <modf>
    5966:	26a2                	fld	fa3,8(sp)
    5968:	22a50453          	fmv.d	fs0,fa0
    596c:	c20696d3          	fcvt.w.d	a3,fa3,rtz
    5970:	0306851b          	addiw	a0,a3,48
    5974:	feaa0fa3          	sb	a0,-1(s4)
    5978:	f94470e3          	bgeu	s0,s4,58f8 <ecvt+0x2b8>
    597c:	00000013          	nop
    5980:	3d347863          	bgeu	s0,s3,5d50 <ecvt+0x710>
    5984:	00044983          	lbu	s3,0(s0)
    5988:	03900813          	li	a6,57
    598c:	0059839b          	addiw	t2,s3,5
    5990:	0ff3f593          	zext.b	a1,t2
    5994:	10b87263          	bgeu	a6,a1,5a98 <ecvt+0x458>
    5998:	40940e33          	sub	t3,s0,s1
    599c:	00b40023          	sb	a1,0(s0)
    59a0:	007e7713          	andi	a4,t3,7
    59a4:	87a2                	mv	a5,s0
    59a6:	03000613          	li	a2,48
    59aa:	88c2                	mv	a7,a6
    59ac:	1e070663          	beqz	a4,5b98 <ecvt+0x558>
    59b0:	1084e463          	bltu	s1,s0,5ab8 <ecvt+0x478>
    59b4:	03100893          	li	a7,49
    59b8:	01178023          	sb	a7,0(a5)
    59bc:	00092603          	lw	a2,0(s2)
    59c0:	03900e13          	li	t3,57
    59c4:	0016059b          	addiw	a1,a2,1
    59c8:	00b92023          	sw	a1,0(s2)
    59cc:	0007c803          	lbu	a6,0(a5)
    59d0:	0d0e7463          	bgeu	t3,a6,5a98 <ecvt+0x458>
    59d4:	01178023          	sb	a7,0(a5)
    59d8:	00092703          	lw	a4,0(s2)
    59dc:	00170e9b          	addiw	t4,a4,1
    59e0:	01d92023          	sw	t4,0(s2)
    59e4:	0007cf03          	lbu	t5,0(a5)
    59e8:	0bee7863          	bgeu	t3,t5,5a98 <ecvt+0x458>
    59ec:	01178023          	sb	a7,0(a5)
    59f0:	00092f83          	lw	t6,0(s2)
    59f4:	001f829b          	addiw	t0,t6,1
    59f8:	00592023          	sw	t0,0(s2)
    59fc:	0007ca83          	lbu	s5,0(a5)
    5a00:	095e7c63          	bgeu	t3,s5,5a98 <ecvt+0x458>
    5a04:	01178023          	sb	a7,0(a5)
    5a08:	00092303          	lw	t1,0(s2)
    5a0c:	00130a1b          	addiw	s4,t1,1
    5a10:	01492023          	sw	s4,0(s2)
    5a14:	0007c683          	lbu	a3,0(a5)
    5a18:	08de7063          	bgeu	t3,a3,5a98 <ecvt+0x458>
    5a1c:	01178023          	sb	a7,0(a5)
    5a20:	00092503          	lw	a0,0(s2)
    5a24:	0015099b          	addiw	s3,a0,1
    5a28:	01392023          	sw	s3,0(s2)
    5a2c:	0007c383          	lbu	t2,0(a5)
    5a30:	067e7463          	bgeu	t3,t2,5a98 <ecvt+0x458>
    5a34:	01178023          	sb	a7,0(a5)
    5a38:	00092603          	lw	a2,0(s2)
    5a3c:	0016059b          	addiw	a1,a2,1
    5a40:	00b92023          	sw	a1,0(s2)
    5a44:	0007c803          	lbu	a6,0(a5)
    5a48:	050e7863          	bgeu	t3,a6,5a98 <ecvt+0x458>
    5a4c:	01178023          	sb	a7,0(a5)
    5a50:	00092703          	lw	a4,0(s2)
    5a54:	00170e9b          	addiw	t4,a4,1
    5a58:	01d92023          	sw	t4,0(s2)
    5a5c:	0007cf03          	lbu	t5,0(a5)
    5a60:	03ee7c63          	bgeu	t3,t5,5a98 <ecvt+0x458>
    5a64:	01178023          	sb	a7,0(a5)
    5a68:	00092f83          	lw	t6,0(s2)
    5a6c:	001f829b          	addiw	t0,t6,1
    5a70:	00592023          	sw	t0,0(s2)
    5a74:	0007ca83          	lbu	s5,0(a5)
    5a78:	035e7063          	bgeu	t3,s5,5a98 <ecvt+0x458>
    5a7c:	01178023          	sb	a7,0(a5)
    5a80:	00092303          	lw	t1,0(s2)
    5a84:	00130a1b          	addiw	s4,t1,1
    5a88:	01492023          	sw	s4,0(s2)
    5a8c:	0007c683          	lbu	a3,0(a5)
    5a90:	f4de62e3          	bltu	t3,a3,59d4 <ecvt+0x394>
    5a94:	00000013          	nop
    5a98:	00040023          	sb	zero,0(s0)
    5a9c:	70a6                	ld	ra,104(sp)
    5a9e:	8526                	mv	a0,s1
    5aa0:	64e6                	ld	s1,88(sp)
    5aa2:	7406                	ld	s0,96(sp)
    5aa4:	7ae2                	ld	s5,56(sp)
    5aa6:	6a06                	ld	s4,64(sp)
    5aa8:	69a6                	ld	s3,72(sp)
    5aaa:	6946                	ld	s2,80(sp)
    5aac:	3422                	fld	fs0,40(sp)
    5aae:	3482                	fld	fs1,32(sp)
    5ab0:	2962                	fld	fs2,24(sp)
    5ab2:	6165                	addi	sp,sp,112
    5ab4:	8082                	ret
    5ab6:	0001                	nop
    5ab8:	fff44e83          	lbu	t4,-1(s0)
    5abc:	00c40023          	sb	a2,0(s0)
    5ac0:	001e879b          	addiw	a5,t4,1
    5ac4:	0ff7ff13          	zext.b	t5,a5
    5ac8:	ffe40fa3          	sb	t5,-1(s0)
    5acc:	fde876e3          	bgeu	a6,t5,5a98 <ecvt+0x458>
    5ad0:	4f85                	li	t6,1
    5ad2:	fff40793          	addi	a5,s0,-1
    5ad6:	0df70163          	beq	a4,t6,5b98 <ecvt+0x558>
    5ada:	4289                	li	t0,2
    5adc:	08570f63          	beq	a4,t0,5b7a <ecvt+0x53a>
    5ae0:	4a8d                	li	s5,3
    5ae2:	07570f63          	beq	a4,s5,5b60 <ecvt+0x520>
    5ae6:	4311                	li	t1,4
    5ae8:	04670f63          	beq	a4,t1,5b46 <ecvt+0x506>
    5aec:	4a15                	li	s4,5
    5aee:	03470f63          	beq	a4,s4,5b2c <ecvt+0x4ec>
    5af2:	4699                	li	a3,6
    5af4:	00d70f63          	beq	a4,a3,5b12 <ecvt+0x4d2>
    5af8:	fff7c503          	lbu	a0,-1(a5)
    5afc:	00c78023          	sb	a2,0(a5)
    5b00:	0015099b          	addiw	s3,a0,1
    5b04:	0ff9f393          	zext.b	t2,s3
    5b08:	fe778fa3          	sb	t2,-1(a5)
    5b0c:	f87876e3          	bgeu	a6,t2,5a98 <ecvt+0x458>
    5b10:	17fd                	addi	a5,a5,-1
    5b12:	fff7c583          	lbu	a1,-1(a5)
    5b16:	00c78023          	sb	a2,0(a5)
    5b1a:	0015881b          	addiw	a6,a1,1
    5b1e:	0ff87e13          	zext.b	t3,a6
    5b22:	ffc78fa3          	sb	t3,-1(a5)
    5b26:	f7c8f9e3          	bgeu	a7,t3,5a98 <ecvt+0x458>
    5b2a:	17fd                	addi	a5,a5,-1
    5b2c:	fff7c703          	lbu	a4,-1(a5)
    5b30:	00c78023          	sb	a2,0(a5)
    5b34:	00170e9b          	addiw	t4,a4,1
    5b38:	0ffeff13          	zext.b	t5,t4
    5b3c:	ffe78fa3          	sb	t5,-1(a5)
    5b40:	f5e8fce3          	bgeu	a7,t5,5a98 <ecvt+0x458>
    5b44:	17fd                	addi	a5,a5,-1
    5b46:	fff7cf83          	lbu	t6,-1(a5)
    5b4a:	00c78023          	sb	a2,0(a5)
    5b4e:	001f829b          	addiw	t0,t6,1
    5b52:	0ff2fa93          	zext.b	s5,t0
    5b56:	ff578fa3          	sb	s5,-1(a5)
    5b5a:	f358ffe3          	bgeu	a7,s5,5a98 <ecvt+0x458>
    5b5e:	17fd                	addi	a5,a5,-1
    5b60:	fff7c303          	lbu	t1,-1(a5)
    5b64:	00c78023          	sb	a2,0(a5)
    5b68:	00130a1b          	addiw	s4,t1,1
    5b6c:	0ffa7693          	zext.b	a3,s4
    5b70:	fed78fa3          	sb	a3,-1(a5)
    5b74:	f2d8f2e3          	bgeu	a7,a3,5a98 <ecvt+0x458>
    5b78:	17fd                	addi	a5,a5,-1
    5b7a:	fff7c503          	lbu	a0,-1(a5)
    5b7e:	00c78023          	sb	a2,0(a5)
    5b82:	17fd                	addi	a5,a5,-1
    5b84:	0015099b          	addiw	s3,a0,1
    5b88:	0ff9f393          	zext.b	t2,s3
    5b8c:	00778023          	sb	t2,0(a5)
    5b90:	f078f4e3          	bgeu	a7,t2,5a98 <ecvt+0x458>
    5b94:	00000013          	nop
    5b98:	e0f4fee3          	bgeu	s1,a5,59b4 <ecvt+0x374>
    5b9c:	fff7ce03          	lbu	t3,-1(a5)
    5ba0:	00c78023          	sb	a2,0(a5)
    5ba4:	001e051b          	addiw	a0,t3,1
    5ba8:	0ff57993          	zext.b	s3,a0
    5bac:	ff378fa3          	sb	s3,-1(a5)
    5bb0:	ef38f4e3          	bgeu	a7,s3,5a98 <ecvt+0x458>
    5bb4:	ffe7c383          	lbu	t2,-2(a5)
    5bb8:	fec78fa3          	sb	a2,-1(a5)
    5bbc:	0013859b          	addiw	a1,t2,1
    5bc0:	0ff5f813          	zext.b	a6,a1
    5bc4:	ff078f23          	sb	a6,-2(a5)
    5bc8:	ed08f8e3          	bgeu	a7,a6,5a98 <ecvt+0x458>
    5bcc:	ffd7c703          	lbu	a4,-3(a5)
    5bd0:	fec78f23          	sb	a2,-2(a5)
    5bd4:	00170e9b          	addiw	t4,a4,1
    5bd8:	0ffeff13          	zext.b	t5,t4
    5bdc:	ffe78ea3          	sb	t5,-3(a5)
    5be0:	ebe8fce3          	bgeu	a7,t5,5a98 <ecvt+0x458>
    5be4:	ffc7cf83          	lbu	t6,-4(a5)
    5be8:	fec78ea3          	sb	a2,-3(a5)
    5bec:	001f829b          	addiw	t0,t6,1
    5bf0:	0ff2fa93          	zext.b	s5,t0
    5bf4:	ff578e23          	sb	s5,-4(a5)
    5bf8:	eb58f0e3          	bgeu	a7,s5,5a98 <ecvt+0x458>
    5bfc:	ffb7c303          	lbu	t1,-5(a5)
    5c00:	fec78e23          	sb	a2,-4(a5)
    5c04:	00130a1b          	addiw	s4,t1,1
    5c08:	0ffa7693          	zext.b	a3,s4
    5c0c:	fed78da3          	sb	a3,-5(a5)
    5c10:	e8d8f4e3          	bgeu	a7,a3,5a98 <ecvt+0x458>
    5c14:	ffa7ce03          	lbu	t3,-6(a5)
    5c18:	fec78da3          	sb	a2,-5(a5)
    5c1c:	001e051b          	addiw	a0,t3,1
    5c20:	0ff57993          	zext.b	s3,a0
    5c24:	ff378d23          	sb	s3,-6(a5)
    5c28:	e738f8e3          	bgeu	a7,s3,5a98 <ecvt+0x458>
    5c2c:	ff97c383          	lbu	t2,-7(a5)
    5c30:	fec78d23          	sb	a2,-6(a5)
    5c34:	0013859b          	addiw	a1,t2,1
    5c38:	0ff5f813          	zext.b	a6,a1
    5c3c:	ff078ca3          	sb	a6,-7(a5)
    5c40:	e508fce3          	bgeu	a7,a6,5a98 <ecvt+0x458>
    5c44:	ff87c703          	lbu	a4,-8(a5)
    5c48:	fec78ca3          	sb	a2,-7(a5)
    5c4c:	00170e9b          	addiw	t4,a4,1
    5c50:	0ffeff13          	zext.b	t5,t4
    5c54:	ffe78c23          	sb	t5,-8(a5)
    5c58:	e5e8f0e3          	bgeu	a7,t5,5a98 <ecvt+0x458>
    5c5c:	17e1                	addi	a5,a5,-8
    5c5e:	bf2d                	j	5b98 <ecvt+0x558>
    5c60:	a2a914d3          	flt.d	s1,fs2,fa0
    5c64:	c8f5                	beqz	s1,5d58 <ecvt+0x718>
    5c66:	6645                	lui	a2,0x11
    5c68:	ba863707          	fld	fa4,-1112(a2) # 10ba8 <errpat+0x38>
    5c6c:	6745                	lui	a4,0x11
    5c6e:	bb873607          	fld	fa2,-1096(a4) # 10bb8 <errpat+0x48>
    5c72:	12e57053          	fmul.d	ft0,fa0,fa4
    5c76:	4a81                	li	s5,0
    5c78:	22c606d3          	fmv.d	fa3,fa2
    5c7c:	a2c01853          	flt.d	a6,ft0,fa2
    5c80:	08080c63          	beqz	a6,5d18 <ecvt+0x6d8>
    5c84:	22000453          	fmv.d	fs0,ft0
    5c88:	3afd                	addiw	s5,s5,-1
    5c8a:	12e07053          	fmul.d	ft0,ft0,fa4
    5c8e:	a2d018d3          	flt.d	a7,ft0,fa3
    5c92:	08088363          	beqz	a7,5d18 <ecvt+0x6d8>
    5c96:	22000453          	fmv.d	fs0,ft0
    5c9a:	3afd                	addiw	s5,s5,-1
    5c9c:	12e07053          	fmul.d	ft0,ft0,fa4
    5ca0:	a2d019d3          	flt.d	s3,ft0,fa3
    5ca4:	06098a63          	beqz	s3,5d18 <ecvt+0x6d8>
    5ca8:	22000453          	fmv.d	fs0,ft0
    5cac:	3afd                	addiw	s5,s5,-1
    5cae:	12e07053          	fmul.d	ft0,ft0,fa4
    5cb2:	a2d01a53          	flt.d	s4,ft0,fa3
    5cb6:	060a0163          	beqz	s4,5d18 <ecvt+0x6d8>
    5cba:	22000453          	fmv.d	fs0,ft0
    5cbe:	3afd                	addiw	s5,s5,-1
    5cc0:	12e07053          	fmul.d	ft0,ft0,fa4
    5cc4:	a2d01e53          	flt.d	t3,ft0,fa3
    5cc8:	040e0863          	beqz	t3,5d18 <ecvt+0x6d8>
    5ccc:	22000453          	fmv.d	fs0,ft0
    5cd0:	3afd                	addiw	s5,s5,-1
    5cd2:	12e07053          	fmul.d	ft0,ft0,fa4
    5cd6:	a2d01ed3          	flt.d	t4,ft0,fa3
    5cda:	020e8f63          	beqz	t4,5d18 <ecvt+0x6d8>
    5cde:	22000453          	fmv.d	fs0,ft0
    5ce2:	3afd                	addiw	s5,s5,-1
    5ce4:	12e07053          	fmul.d	ft0,ft0,fa4
    5ce8:	a2d01f53          	flt.d	t5,ft0,fa3
    5cec:	020f0663          	beqz	t5,5d18 <ecvt+0x6d8>
    5cf0:	22000453          	fmv.d	fs0,ft0
    5cf4:	3afd                	addiw	s5,s5,-1
    5cf6:	12e07053          	fmul.d	ft0,ft0,fa4
    5cfa:	a2d01fd3          	flt.d	t6,ft0,fa3
    5cfe:	000f8d63          	beqz	t6,5d18 <ecvt+0x6d8>
    5d02:	22000453          	fmv.d	fs0,ft0
    5d06:	3afd                	addiw	s5,s5,-1
    5d08:	12e07053          	fmul.d	ft0,ft0,fa4
    5d0c:	a2d017d3          	flt.d	a5,ft0,fa3
    5d10:	fbb5                	bnez	a5,5c84 <ecvt+0x644>
    5d12:	0001                	nop
    5d14:	00000013          	nop
    5d18:	000416b7          	lui	a3,0x41
    5d1c:	a402                	fsd	ft0,8(sp)
    5d1e:	fe068493          	addi	s1,a3,-32 # 40fe0 <CVTBUF>
    5d22:	9426                	add	s0,s0,s1
    5d24:	01592023          	sw	s5,0(s2)
    5d28:	02946063          	bltu	s0,s1,5d48 <ecvt+0x708>
    5d2c:	000419b7          	lui	s3,0x41
    5d30:	8a26                	mv	s4,s1
    5d32:	03098993          	addi	s3,s3,48 # 41030 <__malloc_current_mallinfo>
    5d36:	be35                	j	5872 <ecvt+0x232>
    5d38:	4305                	li	t1,1
    5d3a:	22a51553          	fneg.d	fa0,fa0
    5d3e:	00662023          	sw	t1,0(a2)
    5d42:	ba3d                	j	5680 <ecvt+0x40>
    5d44:	29c2                	fld	fs3,16(sp)
    5d46:	7b42                	ld	s6,48(sp)
    5d48:	00048023          	sb	zero,0(s1)
    5d4c:	bb81                	j	5a9c <ecvt+0x45c>
    5d4e:	0001                	nop
    5d50:	040487a3          	sb	zero,79(s1)
    5d54:	b3a1                	j	5a9c <ecvt+0x45c>
    5d56:	0001                	nop
    5d58:	000415b7          	lui	a1,0x41
    5d5c:	4a81                	li	s5,0
    5d5e:	fe058493          	addi	s1,a1,-32 # 40fe0 <CVTBUF>
    5d62:	b7c1                	j	5d22 <ecvt+0x6e2>
    5d64:	29c2                	fld	fs3,16(sp)
    5d66:	7b42                	ld	s6,48(sp)
    5d68:	bf6d                	j	5d22 <ecvt+0x6e2>
    5d6a:	00000013          	nop
    5d6e:	0001                	nop

0000000000005d70 <ecvtbuf>:
    5d70:	7159                	addi	sp,sp,-112
    5d72:	f0a2                	sd	s0,96(sp)
    5d74:	f486                	sd	ra,104(sp)
    5d76:	0005041b          	sext.w	s0,a0
    5d7a:	f20007d3          	fmv.d.x	fa5,zero
    5d7e:	04e00793          	li	a5,78
    5d82:	e8ca                	sd	s2,80(sp)
    5d84:	eca6                	sd	s1,88(sp)
    5d86:	a2f512d3          	flt.d	t0,fa0,fa5
    5d8a:	84b6                	mv	s1,a3
    5d8c:	00042693          	slti	a3,s0,0
    5d90:	e0d2                	sd	s4,64(sp)
    5d92:	e4ce                	sd	s3,72(sp)
    5d94:	42d0140b          	th.mvnez	s0,zero,a3
    5d98:	00a7a533          	slt	a0,a5,a0
    5d9c:	ff515b0b          	th.sdd	s6,s5,(sp),3,4
    5da0:	b422                	fsd	fs0,40(sp)
    5da2:	b026                	fsd	fs1,32(sp)
    5da4:	ac4a                	fsd	fs2,24(sp)
    5da6:	892e                	mv	s2,a1
    5da8:	42a7940b          	th.mvnez	s0,a5,a0
    5dac:	6c029463          	bnez	t0,6474 <ecvtbuf+0x704>
    5db0:	00062023          	sw	zero,0(a2)
    5db4:	850a                	mv	a0,sp
    5db6:	1c1090ef          	jal	f776 <modf>
    5dba:	2e02                	fld	ft8,0(sp)
    5dbc:	f2000953          	fmv.d.x	fs2,zero
    5dc0:	22a50453          	fmv.d	fs0,fa0
    5dc4:	a32e23d3          	feq.d	t2,ft8,fs2
    5dc8:	5e039063          	bnez	t2,63a8 <ecvtbuf+0x638>
    5dcc:	67c5                	lui	a5,0x11
    5dce:	66c5                	lui	a3,0x11
    5dd0:	a84e                	fsd	fs3,16(sp)
    5dd2:	ba87b487          	fld	fs1,-1112(a5) # 10ba8 <errpat+0x38>
    5dd6:	bb06b987          	fld	fs3,-1104(a3) # 10bb0 <errpat+0x40>
    5dda:	05048993          	addi	s3,s1,80
    5dde:	8ace                	mv	s5,s3
    5de0:	4b01                	li	s6,0
    5de2:	1a9e7553          	fdiv.d	fa0,ft8,fs1
    5de6:	850a                	mv	a0,sp
    5de8:	1afd                	addi	s5,s5,-1
    5dea:	2b05                	addiw	s6,s6,1
    5dec:	8a56                	mv	s4,s5
    5dee:	189090ef          	jal	f776 <modf>
    5df2:	a42a                	fsd	fa0,8(sp)
    5df4:	03357553          	fadd.d	fa0,fa0,fs3
    5df8:	2102                	fld	ft2,0(sp)
    5dfa:	8fda                	mv	t6,s6
    5dfc:	129570d3          	fmul.d	ft1,fa0,fs1
    5e00:	a3212353          	feq.d	t1,ft2,fs2
    5e04:	c2009553          	fcvt.w.d	a0,ft1,rtz
    5e08:	0305029b          	addiw	t0,a0,48
    5e0c:	0ff2ff13          	zext.b	t5,t0
    5e10:	01ea8023          	sb	t5,0(s5)
    5e14:	08031f63          	bnez	t1,5eb2 <ecvtbuf+0x142>
    5e18:	1a917553          	fdiv.d	fa0,ft2,fs1
    5e1c:	850a                	mv	a0,sp
    5e1e:	2b05                	addiw	s6,s6,1
    5e20:	157090ef          	jal	f776 <modf>
    5e24:	033571d3          	fadd.d	ft3,fa0,fs3
    5e28:	2282                	fld	ft5,0(sp)
    5e2a:	a42a                	fsd	fa0,8(sp)
    5e2c:	1291f253          	fmul.d	ft4,ft3,fs1
    5e30:	a322a653          	feq.d	a2,ft5,fs2
    5e34:	8fda                	mv	t6,s6
    5e36:	c20213d3          	fcvt.w.d	t2,ft4,rtz
    5e3a:	0303859b          	addiw	a1,t2,48
    5e3e:	0ff5ff13          	zext.b	t5,a1
    5e42:	09fadf0b          	th.sbib	t5,(s5),-1,0
    5e46:	e635                	bnez	a2,5eb2 <ecvtbuf+0x142>
    5e48:	1a92f553          	fdiv.d	fa0,ft5,fs1
    5e4c:	850a                	mv	a0,sp
    5e4e:	2b05                	addiw	s6,s6,1
    5e50:	ffea0a93          	addi	s5,s4,-2
    5e54:	123090ef          	jal	f776 <modf>
    5e58:	03357353          	fadd.d	ft6,fa0,fs3
    5e5c:	2582                	fld	fa1,0(sp)
    5e5e:	a42a                	fsd	fa0,8(sp)
    5e60:	129373d3          	fmul.d	ft7,ft6,fs1
    5e64:	a325a8d3          	feq.d	a7,fa1,fs2
    5e68:	8fda                	mv	t6,s6
    5e6a:	c2039753          	fcvt.w.d	a4,ft7,rtz
    5e6e:	0307081b          	addiw	a6,a4,48
    5e72:	0ff87f13          	zext.b	t5,a6
    5e76:	ffea0f23          	sb	t5,-2(s4)
    5e7a:	02089c63          	bnez	a7,5eb2 <ecvtbuf+0x142>
    5e7e:	1a95f553          	fdiv.d	fa0,fa1,fs1
    5e82:	850a                	mv	a0,sp
    5e84:	2b05                	addiw	s6,s6,1
    5e86:	ffda0a93          	addi	s5,s4,-3
    5e8a:	0ed090ef          	jal	f776 <modf>
    5e8e:	03357853          	fadd.d	fa6,fa0,fs3
    5e92:	2e02                	fld	ft8,0(sp)
    5e94:	a42a                	fsd	fa0,8(sp)
    5e96:	129878d3          	fmul.d	fa7,fa6,fs1
    5e9a:	a32e27d3          	feq.d	a5,ft8,fs2
    5e9e:	8fda                	mv	t6,s6
    5ea0:	c2089e53          	fcvt.w.d	t3,fa7,rtz
    5ea4:	030e0e9b          	addiw	t4,t3,48
    5ea8:	0ffeff13          	zext.b	t5,t4
    5eac:	ffea0ea3          	sb	t5,-3(s4)
    5eb0:	db8d                	beqz	a5,5de2 <ecvtbuf+0x72>
    5eb2:	5d3afe63          	bgeu	s5,s3,648e <ecvtbuf+0x71e>
    5eb6:	41548b33          	sub	s6,s1,s5
    5eba:	04fb0a13          	addi	s4,s6,79
    5ebe:	007a7293          	andi	t0,s4,7
    5ec2:	050b0693          	addi	a3,s6,80
    5ec6:	4701                	li	a4,0
    5ec8:	0c028763          	beqz	t0,5f96 <ecvtbuf+0x226>
    5ecc:	01e48023          	sb	t5,0(s1)
    5ed0:	4705                	li	a4,1
    5ed2:	80eacf0b          	th.lrbu	t5,s5,a4,0
    5ed6:	0ce28063          	beq	t0,a4,5f96 <ecvtbuf+0x226>
    5eda:	4309                	li	t1,2
    5edc:	04628763          	beq	t0,t1,5f2a <ecvtbuf+0x1ba>
    5ee0:	450d                	li	a0,3
    5ee2:	02a28f63          	beq	t0,a0,5f20 <ecvtbuf+0x1b0>
    5ee6:	4391                	li	t2,4
    5ee8:	02728763          	beq	t0,t2,5f16 <ecvtbuf+0x1a6>
    5eec:	4595                	li	a1,5
    5eee:	00b28f63          	beq	t0,a1,5f0c <ecvtbuf+0x19c>
    5ef2:	4619                	li	a2,6
    5ef4:	00c28763          	beq	t0,a2,5f02 <ecvtbuf+0x192>
    5ef8:	00e4df0b          	th.srb	t5,s1,a4,0
    5efc:	806acf0b          	th.lrbu	t5,s5,t1,0
    5f00:	871a                	mv	a4,t1
    5f02:	00e4df0b          	th.srb	t5,s1,a4,0
    5f06:	0705                	addi	a4,a4,1
    5f08:	80eacf0b          	th.lrbu	t5,s5,a4,0
    5f0c:	00e4df0b          	th.srb	t5,s1,a4,0
    5f10:	0705                	addi	a4,a4,1
    5f12:	80eacf0b          	th.lrbu	t5,s5,a4,0
    5f16:	00e4df0b          	th.srb	t5,s1,a4,0
    5f1a:	0705                	addi	a4,a4,1
    5f1c:	80eacf0b          	th.lrbu	t5,s5,a4,0
    5f20:	00e4df0b          	th.srb	t5,s1,a4,0
    5f24:	0705                	addi	a4,a4,1
    5f26:	80eacf0b          	th.lrbu	t5,s5,a4,0
    5f2a:	00e4df0b          	th.srb	t5,s1,a4,0
    5f2e:	0705                	addi	a4,a4,1
    5f30:	80eacf0b          	th.lrbu	t5,s5,a4,0
    5f34:	00170813          	addi	a6,a4,1
    5f38:	00e4df0b          	th.srb	t5,s1,a4,0
    5f3c:	06d80363          	beq	a6,a3,5fa2 <ecvtbuf+0x232>
    5f40:	810ac28b          	th.lrbu	t0,s5,a6,0
    5f44:	00270313          	addi	t1,a4,2
    5f48:	00370893          	addi	a7,a4,3
    5f4c:	0104d28b          	th.srb	t0,s1,a6,0
    5f50:	806ac80b          	th.lrbu	a6,s5,t1,0
    5f54:	00470a13          	addi	s4,a4,4
    5f58:	00570e93          	addi	t4,a4,5
    5f5c:	0064d80b          	th.srb	a6,s1,t1,0
    5f60:	811acb0b          	th.lrbu	s6,s5,a7,0
    5f64:	00670513          	addi	a0,a4,6
    5f68:	00770593          	addi	a1,a4,7
    5f6c:	0114db0b          	th.srb	s6,s1,a7,0
    5f70:	814ace0b          	th.lrbu	t3,s5,s4,0
    5f74:	0721                	addi	a4,a4,8
    5f76:	0144de0b          	th.srb	t3,s1,s4,0
    5f7a:	81dacf0b          	th.lrbu	t5,s5,t4,0
    5f7e:	01d4df0b          	th.srb	t5,s1,t4,0
    5f82:	80aac38b          	th.lrbu	t2,s5,a0,0
    5f86:	00a4d38b          	th.srb	t2,s1,a0,0
    5f8a:	80bac60b          	th.lrbu	a2,s5,a1,0
    5f8e:	00b4d60b          	th.srb	a2,s1,a1,0
    5f92:	80eacf0b          	th.lrbu	t5,s5,a4,0
    5f96:	00e4df0b          	th.srb	t5,s1,a4,0
    5f9a:	00170813          	addi	a6,a4,1
    5f9e:	fad811e3          	bne	a6,a3,5f40 <ecvtbuf+0x1d0>
    5fa2:	9426                	add	s0,s0,s1
    5fa4:	01f92023          	sw	t6,0(s2)
    5fa8:	4c946c63          	bltu	s0,s1,6480 <ecvtbuf+0x710>
    5fac:	00d48a33          	add	s4,s1,a3
    5fb0:	29c2                	fld	fs3,16(sp)
    5fb2:	11446763          	bltu	s0,s4,60c0 <ecvtbuf+0x350>
    5fb6:	41498ab3          	sub	s5,s3,s4
    5fba:	68c5                	lui	a7,0x11
    5fbc:	003afb13          	andi	s6,s5,3
    5fc0:	ba88b907          	fld	fs2,-1112(a7) # 10ba8 <errpat+0x38>
    5fc4:	060b0a63          	beqz	s6,6038 <ecvtbuf+0x2c8>
    5fc8:	0f3a7c63          	bgeu	s4,s3,60c0 <ecvtbuf+0x350>
    5fcc:	13247553          	fmul.d	fa0,fs0,fs2
    5fd0:	0028                	addi	a0,sp,8
    5fd2:	7a4090ef          	jal	f776 <modf>
    5fd6:	2ea2                	fld	ft9,8(sp)
    5fd8:	22a50453          	fmv.d	fs0,fa0
    5fdc:	c20e9e53          	fcvt.w.d	t3,ft9,rtz
    5fe0:	030e0e9b          	addiw	t4,t3,48
    5fe4:	181a5e8b          	th.sbia	t4,(s4),1,0
    5fe8:	0d446c63          	bltu	s0,s4,60c0 <ecvtbuf+0x350>
    5fec:	4f05                	li	t5,1
    5fee:	05eb0563          	beq	s6,t5,6038 <ecvtbuf+0x2c8>
    5ff2:	4f89                	li	t6,2
    5ff4:	03fb0263          	beq	s6,t6,6018 <ecvtbuf+0x2a8>
    5ff8:	13257553          	fmul.d	fa0,fa0,fs2
    5ffc:	0028                	addi	a0,sp,8
    5ffe:	778090ef          	jal	f776 <modf>
    6002:	2f22                	fld	ft10,8(sp)
    6004:	22a50453          	fmv.d	fs0,fa0
    6008:	c20f17d3          	fcvt.w.d	a5,ft10,rtz
    600c:	0307869b          	addiw	a3,a5,48
    6010:	181a568b          	th.sbia	a3,(s4),1,0
    6014:	0b446663          	bltu	s0,s4,60c0 <ecvtbuf+0x350>
    6018:	13247553          	fmul.d	fa0,fs0,fs2
    601c:	0028                	addi	a0,sp,8
    601e:	758090ef          	jal	f776 <modf>
    6022:	2fa2                	fld	ft11,8(sp)
    6024:	22a50453          	fmv.d	fs0,fa0
    6028:	c20f92d3          	fcvt.w.d	t0,ft11,rtz
    602c:	0302831b          	addiw	t1,t0,48
    6030:	181a530b          	th.sbia	t1,(s4),1,0
    6034:	09446663          	bltu	s0,s4,60c0 <ecvtbuf+0x350>
    6038:	093a7463          	bgeu	s4,s3,60c0 <ecvtbuf+0x350>
    603c:	13247553          	fmul.d	fa0,fs0,fs2
    6040:	0028                	addi	a0,sp,8
    6042:	734090ef          	jal	f776 <modf>
    6046:	27a2                	fld	fa5,8(sp)
    6048:	8552                	mv	a0,s4
    604a:	c20793d3          	fcvt.w.d	t2,fa5,rtz
    604e:	0303859b          	addiw	a1,t2,48
    6052:	1815558b          	th.sbia	a1,(a0),1,0
    6056:	06a46563          	bltu	s0,a0,60c0 <ecvtbuf+0x350>
    605a:	13257553          	fmul.d	fa0,fa0,fs2
    605e:	0028                	addi	a0,sp,8
    6060:	716090ef          	jal	f776 <modf>
    6064:	2722                	fld	fa4,8(sp)
    6066:	002a0613          	addi	a2,s4,2
    606a:	c2071753          	fcvt.w.d	a4,fa4,rtz
    606e:	0307081b          	addiw	a6,a4,48
    6072:	010a00a3          	sb	a6,1(s4)
    6076:	04c46563          	bltu	s0,a2,60c0 <ecvtbuf+0x350>
    607a:	13257553          	fmul.d	fa0,fa0,fs2
    607e:	0028                	addi	a0,sp,8
    6080:	6f6090ef          	jal	f776 <modf>
    6084:	2622                	fld	fa2,8(sp)
    6086:	003a0893          	addi	a7,s4,3
    608a:	c2061ad3          	fcvt.w.d	s5,fa2,rtz
    608e:	030a8b1b          	addiw	s6,s5,48
    6092:	016a0123          	sb	s6,2(s4)
    6096:	03146563          	bltu	s0,a7,60c0 <ecvtbuf+0x350>
    609a:	13257553          	fmul.d	fa0,fa0,fs2
    609e:	0028                	addi	a0,sp,8
    60a0:	0a11                	addi	s4,s4,4
    60a2:	6d4090ef          	jal	f776 <modf>
    60a6:	26a2                	fld	fa3,8(sp)
    60a8:	22a50453          	fmv.d	fs0,fa0
    60ac:	c2069e53          	fcvt.w.d	t3,fa3,rtz
    60b0:	030e0e9b          	addiw	t4,t3,48
    60b4:	ffda0fa3          	sb	t4,-1(s4)
    60b8:	f94470e3          	bgeu	s0,s4,6038 <ecvtbuf+0x2c8>
    60bc:	00000013          	nop
    60c0:	3d347463          	bgeu	s0,s3,6488 <ecvtbuf+0x718>
    60c4:	00044983          	lbu	s3,0(s0)
    60c8:	03900693          	li	a3,57
    60cc:	00598f1b          	addiw	t5,s3,5
    60d0:	0fff7f93          	zext.b	t6,t5
    60d4:	11f6f263          	bgeu	a3,t6,61d8 <ecvtbuf+0x468>
    60d8:	40940533          	sub	a0,s0,s1
    60dc:	01f40023          	sb	t6,0(s0)
    60e0:	00757393          	andi	t2,a0,7
    60e4:	87a2                	mv	a5,s0
    60e6:	03000293          	li	t0,48
    60ea:	8336                	mv	t1,a3
    60ec:	1e038a63          	beqz	t2,62e0 <ecvtbuf+0x570>
    60f0:	1084e463          	bltu	s1,s0,61f8 <ecvtbuf+0x488>
    60f4:	03100293          	li	t0,49
    60f8:	00578023          	sb	t0,0(a5)
    60fc:	00092303          	lw	t1,0(s2)
    6100:	03900713          	li	a4,57
    6104:	0013059b          	addiw	a1,t1,1
    6108:	00b92023          	sw	a1,0(s2)
    610c:	0007c603          	lbu	a2,0(a5)
    6110:	0cc77463          	bgeu	a4,a2,61d8 <ecvtbuf+0x468>
    6114:	00578023          	sb	t0,0(a5)
    6118:	00092803          	lw	a6,0(s2)
    611c:	0018089b          	addiw	a7,a6,1
    6120:	01192023          	sw	a7,0(s2)
    6124:	0007ca83          	lbu	s5,0(a5)
    6128:	0b577863          	bgeu	a4,s5,61d8 <ecvtbuf+0x468>
    612c:	00578023          	sb	t0,0(a5)
    6130:	00092b03          	lw	s6,0(s2)
    6134:	001b0a1b          	addiw	s4,s6,1
    6138:	01492023          	sw	s4,0(s2)
    613c:	0007ce03          	lbu	t3,0(a5)
    6140:	09c77c63          	bgeu	a4,t3,61d8 <ecvtbuf+0x468>
    6144:	00578023          	sb	t0,0(a5)
    6148:	00092e83          	lw	t4,0(s2)
    614c:	001e899b          	addiw	s3,t4,1
    6150:	01392023          	sw	s3,0(s2)
    6154:	0007cf03          	lbu	t5,0(a5)
    6158:	09e77063          	bgeu	a4,t5,61d8 <ecvtbuf+0x468>
    615c:	00578023          	sb	t0,0(a5)
    6160:	00092f83          	lw	t6,0(s2)
    6164:	001f869b          	addiw	a3,t6,1
    6168:	00d92023          	sw	a3,0(s2)
    616c:	0007c503          	lbu	a0,0(a5)
    6170:	06a77463          	bgeu	a4,a0,61d8 <ecvtbuf+0x468>
    6174:	00578023          	sb	t0,0(a5)
    6178:	00092383          	lw	t2,0(s2)
    617c:	0013831b          	addiw	t1,t2,1
    6180:	00692023          	sw	t1,0(s2)
    6184:	0007c583          	lbu	a1,0(a5)
    6188:	04b77863          	bgeu	a4,a1,61d8 <ecvtbuf+0x468>
    618c:	00578023          	sb	t0,0(a5)
    6190:	00092603          	lw	a2,0(s2)
    6194:	0016081b          	addiw	a6,a2,1
    6198:	01092023          	sw	a6,0(s2)
    619c:	0007c883          	lbu	a7,0(a5)
    61a0:	03177c63          	bgeu	a4,a7,61d8 <ecvtbuf+0x468>
    61a4:	00578023          	sb	t0,0(a5)
    61a8:	00092a83          	lw	s5,0(s2)
    61ac:	001a8b1b          	addiw	s6,s5,1
    61b0:	01692023          	sw	s6,0(s2)
    61b4:	0007ca03          	lbu	s4,0(a5)
    61b8:	03477063          	bgeu	a4,s4,61d8 <ecvtbuf+0x468>
    61bc:	00578023          	sb	t0,0(a5)
    61c0:	00092e03          	lw	t3,0(s2)
    61c4:	001e0e9b          	addiw	t4,t3,1
    61c8:	01d92023          	sw	t4,0(s2)
    61cc:	0007c983          	lbu	s3,0(a5)
    61d0:	f53762e3          	bltu	a4,s3,6114 <ecvtbuf+0x3a4>
    61d4:	00000013          	nop
    61d8:	00040023          	sb	zero,0(s0)
    61dc:	7406                	ld	s0,96(sp)
    61de:	70a6                	ld	ra,104(sp)
    61e0:	6a06                	ld	s4,64(sp)
    61e2:	69a6                	ld	s3,72(sp)
    61e4:	ff514b0b          	th.ldd	s6,s5,(sp),3,4
    61e8:	3422                	fld	fs0,40(sp)
    61ea:	3482                	fld	fs1,32(sp)
    61ec:	2962                	fld	fs2,24(sp)
    61ee:	8526                	mv	a0,s1
    61f0:	6946                	ld	s2,80(sp)
    61f2:	64e6                	ld	s1,88(sp)
    61f4:	6165                	addi	sp,sp,112
    61f6:	8082                	ret
    61f8:	85a2                	mv	a1,s0
    61fa:	19f5d28b          	th.sbia	t0,(a1),-1,0
    61fe:	fff44783          	lbu	a5,-1(s0)
    6202:	0017861b          	addiw	a2,a5,1
    6206:	0ff67713          	zext.b	a4,a2
    620a:	fee40fa3          	sb	a4,-1(s0)
    620e:	fce6f5e3          	bgeu	a3,a4,61d8 <ecvtbuf+0x468>
    6212:	4805                	li	a6,1
    6214:	87ae                	mv	a5,a1
    6216:	0d038563          	beq	t2,a6,62e0 <ecvtbuf+0x570>
    621a:	4889                	li	a7,2
    621c:	0b138263          	beq	t2,a7,62c0 <ecvtbuf+0x550>
    6220:	4a8d                	li	s5,3
    6222:	09538163          	beq	t2,s5,62a4 <ecvtbuf+0x534>
    6226:	4b11                	li	s6,4
    6228:	07638063          	beq	t2,s6,6288 <ecvtbuf+0x518>
    622c:	4a15                	li	s4,5
    622e:	03438f63          	beq	t2,s4,626c <ecvtbuf+0x4fc>
    6232:	4e19                	li	t3,6
    6234:	01c38e63          	beq	t2,t3,6250 <ecvtbuf+0x4e0>
    6238:	19f7d28b          	th.sbia	t0,(a5),-1,0
    623c:	fff5ce83          	lbu	t4,-1(a1)
    6240:	001e899b          	addiw	s3,t4,1
    6244:	0ff9ff13          	zext.b	t5,s3
    6248:	ffe58fa3          	sb	t5,-1(a1)
    624c:	f9e6f6e3          	bgeu	a3,t5,61d8 <ecvtbuf+0x468>
    6250:	8fbe                	mv	t6,a5
    6252:	19ffd28b          	th.sbia	t0,(t6),-1,0
    6256:	fff7c683          	lbu	a3,-1(a5)
    625a:	0016851b          	addiw	a0,a3,1
    625e:	0ff57393          	zext.b	t2,a0
    6262:	fe778fa3          	sb	t2,-1(a5)
    6266:	f67379e3          	bgeu	t1,t2,61d8 <ecvtbuf+0x468>
    626a:	87fe                	mv	a5,t6
    626c:	85be                	mv	a1,a5
    626e:	19f5d28b          	th.sbia	t0,(a1),-1,0
    6272:	fff7c603          	lbu	a2,-1(a5)
    6276:	0016071b          	addiw	a4,a2,1
    627a:	0ff77813          	zext.b	a6,a4
    627e:	ff078fa3          	sb	a6,-1(a5)
    6282:	f5037be3          	bgeu	t1,a6,61d8 <ecvtbuf+0x468>
    6286:	87ae                	mv	a5,a1
    6288:	88be                	mv	a7,a5
    628a:	19f8d28b          	th.sbia	t0,(a7),-1,0
    628e:	fff7ca83          	lbu	s5,-1(a5)
    6292:	001a8b1b          	addiw	s6,s5,1
    6296:	0ffb7a13          	zext.b	s4,s6
    629a:	ff478fa3          	sb	s4,-1(a5)
    629e:	f3437de3          	bgeu	t1,s4,61d8 <ecvtbuf+0x468>
    62a2:	87c6                	mv	a5,a7
    62a4:	8e3e                	mv	t3,a5
    62a6:	19fe528b          	th.sbia	t0,(t3),-1,0
    62aa:	fff7ce83          	lbu	t4,-1(a5)
    62ae:	001e899b          	addiw	s3,t4,1
    62b2:	0ff9ff13          	zext.b	t5,s3
    62b6:	ffe78fa3          	sb	t5,-1(a5)
    62ba:	f1e37fe3          	bgeu	t1,t5,61d8 <ecvtbuf+0x468>
    62be:	87f2                	mv	a5,t3
    62c0:	8fbe                	mv	t6,a5
    62c2:	19ffd28b          	th.sbia	t0,(t6),-1,0
    62c6:	fff7c683          	lbu	a3,-1(a5)
    62ca:	0016851b          	addiw	a0,a3,1
    62ce:	0ff57393          	zext.b	t2,a0
    62d2:	fe778fa3          	sb	t2,-1(a5)
    62d6:	87fe                	mv	a5,t6
    62d8:	f07370e3          	bgeu	t1,t2,61d8 <ecvtbuf+0x468>
    62dc:	00000013          	nop
    62e0:	e0f4fae3          	bgeu	s1,a5,60f4 <ecvtbuf+0x384>
    62e4:	fff7c703          	lbu	a4,-1(a5)
    62e8:	00578023          	sb	t0,0(a5)
    62ec:	00170f1b          	addiw	t5,a4,1
    62f0:	0fff7f93          	zext.b	t6,t5
    62f4:	fff78fa3          	sb	t6,-1(a5)
    62f8:	eff370e3          	bgeu	t1,t6,61d8 <ecvtbuf+0x468>
    62fc:	ffe7c683          	lbu	a3,-2(a5)
    6300:	fe578fa3          	sb	t0,-1(a5)
    6304:	0016851b          	addiw	a0,a3,1
    6308:	0ff57393          	zext.b	t2,a0
    630c:	fe778f23          	sb	t2,-2(a5)
    6310:	ec7374e3          	bgeu	t1,t2,61d8 <ecvtbuf+0x468>
    6314:	ffd7c583          	lbu	a1,-3(a5)
    6318:	fe578f23          	sb	t0,-2(a5)
    631c:	0015861b          	addiw	a2,a1,1
    6320:	0ff67813          	zext.b	a6,a2
    6324:	ff078ea3          	sb	a6,-3(a5)
    6328:	eb0378e3          	bgeu	t1,a6,61d8 <ecvtbuf+0x468>
    632c:	ffc7c883          	lbu	a7,-4(a5)
    6330:	fe578ea3          	sb	t0,-3(a5)
    6334:	00188a9b          	addiw	s5,a7,1
    6338:	0ffafb13          	zext.b	s6,s5
    633c:	ff678e23          	sb	s6,-4(a5)
    6340:	e9637ce3          	bgeu	t1,s6,61d8 <ecvtbuf+0x468>
    6344:	ffb7ca03          	lbu	s4,-5(a5)
    6348:	fe578e23          	sb	t0,-4(a5)
    634c:	001a0e1b          	addiw	t3,s4,1
    6350:	0ffe7e93          	zext.b	t4,t3
    6354:	ffd78da3          	sb	t4,-5(a5)
    6358:	e9d370e3          	bgeu	t1,t4,61d8 <ecvtbuf+0x468>
    635c:	ffa7c983          	lbu	s3,-6(a5)
    6360:	fe578da3          	sb	t0,-5(a5)
    6364:	0019871b          	addiw	a4,s3,1
    6368:	0ff77f13          	zext.b	t5,a4
    636c:	ffe78d23          	sb	t5,-6(a5)
    6370:	e7e374e3          	bgeu	t1,t5,61d8 <ecvtbuf+0x468>
    6374:	ff97cf83          	lbu	t6,-7(a5)
    6378:	fe578d23          	sb	t0,-6(a5)
    637c:	001f869b          	addiw	a3,t6,1
    6380:	0ff6f513          	zext.b	a0,a3
    6384:	fea78ca3          	sb	a0,-7(a5)
    6388:	e4a378e3          	bgeu	t1,a0,61d8 <ecvtbuf+0x468>
    638c:	ff87c383          	lbu	t2,-8(a5)
    6390:	fe578ca3          	sb	t0,-7(a5)
    6394:	0013859b          	addiw	a1,t2,1
    6398:	0ff5f613          	zext.b	a2,a1
    639c:	fec78c23          	sb	a2,-8(a5)
    63a0:	e2c37ce3          	bgeu	t1,a2,61d8 <ecvtbuf+0x468>
    63a4:	17e1                	addi	a5,a5,-8
    63a6:	bf2d                	j	62e0 <ecvtbuf+0x570>
    63a8:	a2a915d3          	flt.d	a1,fs2,fa0
    63ac:	4b01                	li	s6,0
    63ae:	c9d5                	beqz	a1,6462 <ecvtbuf+0x6f2>
    63b0:	6645                	lui	a2,0x11
    63b2:	ba863707          	fld	fa4,-1112(a2) # 10ba8 <errpat+0x38>
    63b6:	6745                	lui	a4,0x11
    63b8:	bb873607          	fld	fa2,-1096(a4) # 10bb8 <errpat+0x48>
    63bc:	12e57053          	fmul.d	ft0,fa0,fa4
    63c0:	4b01                	li	s6,0
    63c2:	22c606d3          	fmv.d	fa3,fa2
    63c6:	a2c01853          	flt.d	a6,ft0,fa2
    63ca:	08080b63          	beqz	a6,6460 <ecvtbuf+0x6f0>
    63ce:	22000453          	fmv.d	fs0,ft0
    63d2:	3b7d                	addiw	s6,s6,-1
    63d4:	12e07053          	fmul.d	ft0,ft0,fa4
    63d8:	a2d018d3          	flt.d	a7,ft0,fa3
    63dc:	08088263          	beqz	a7,6460 <ecvtbuf+0x6f0>
    63e0:	22000453          	fmv.d	fs0,ft0
    63e4:	3b7d                	addiw	s6,s6,-1
    63e6:	12e07053          	fmul.d	ft0,ft0,fa4
    63ea:	a2d019d3          	flt.d	s3,ft0,fa3
    63ee:	06098963          	beqz	s3,6460 <ecvtbuf+0x6f0>
    63f2:	22000453          	fmv.d	fs0,ft0
    63f6:	3b7d                	addiw	s6,s6,-1
    63f8:	12e07053          	fmul.d	ft0,ft0,fa4
    63fc:	a2d01a53          	flt.d	s4,ft0,fa3
    6400:	060a0063          	beqz	s4,6460 <ecvtbuf+0x6f0>
    6404:	22000453          	fmv.d	fs0,ft0
    6408:	3b7d                	addiw	s6,s6,-1
    640a:	12e07053          	fmul.d	ft0,ft0,fa4
    640e:	a2d01ad3          	flt.d	s5,ft0,fa3
    6412:	040a8763          	beqz	s5,6460 <ecvtbuf+0x6f0>
    6416:	22000453          	fmv.d	fs0,ft0
    641a:	3b7d                	addiw	s6,s6,-1
    641c:	12e07053          	fmul.d	ft0,ft0,fa4
    6420:	a2d01e53          	flt.d	t3,ft0,fa3
    6424:	020e0e63          	beqz	t3,6460 <ecvtbuf+0x6f0>
    6428:	22000453          	fmv.d	fs0,ft0
    642c:	3b7d                	addiw	s6,s6,-1
    642e:	12e07053          	fmul.d	ft0,ft0,fa4
    6432:	a2d01ed3          	flt.d	t4,ft0,fa3
    6436:	020e8563          	beqz	t4,6460 <ecvtbuf+0x6f0>
    643a:	22000453          	fmv.d	fs0,ft0
    643e:	3b7d                	addiw	s6,s6,-1
    6440:	12e07053          	fmul.d	ft0,ft0,fa4
    6444:	a2d01f53          	flt.d	t5,ft0,fa3
    6448:	000f0c63          	beqz	t5,6460 <ecvtbuf+0x6f0>
    644c:	22000453          	fmv.d	fs0,ft0
    6450:	3b7d                	addiw	s6,s6,-1
    6452:	12e07053          	fmul.d	ft0,ft0,fa4
    6456:	a2d01fd3          	flt.d	t6,ft0,fa3
    645a:	f60f9ae3          	bnez	t6,63ce <ecvtbuf+0x65e>
    645e:	0001                	nop
    6460:	a402                	fsd	ft0,8(sp)
    6462:	9426                	add	s0,s0,s1
    6464:	01692023          	sw	s6,0(s2)
    6468:	00946d63          	bltu	s0,s1,6482 <ecvtbuf+0x712>
    646c:	8a26                	mv	s4,s1
    646e:	05048993          	addi	s3,s1,80
    6472:	b691                	j	5fb6 <ecvtbuf+0x246>
    6474:	4305                	li	t1,1
    6476:	22a51553          	fneg.d	fa0,fa0
    647a:	00662023          	sw	t1,0(a2)
    647e:	ba1d                	j	5db4 <ecvtbuf+0x44>
    6480:	29c2                	fld	fs3,16(sp)
    6482:	00048023          	sb	zero,0(s1)
    6486:	bb99                	j	61dc <ecvtbuf+0x46c>
    6488:	040487a3          	sb	zero,79(s1)
    648c:	bb81                	j	61dc <ecvtbuf+0x46c>
    648e:	29c2                	fld	fs3,16(sp)
    6490:	bfc9                	j	6462 <ecvtbuf+0x6f2>
    6492:	0001                	nop
    6494:	00000013          	nop
    6498:	00000013          	nop
    649c:	00000013          	nop

00000000000064a0 <fcvt>:
    64a0:	7159                	addi	sp,sp,-112
    64a2:	f20007d3          	fmv.d.x	fa5,zero
    64a6:	e4ce                	sd	s3,72(sp)
    64a8:	e8ca                	sd	s2,80(sp)
    64aa:	0005091b          	sext.w	s2,a0
    64ae:	04e00793          	li	a5,78
    64b2:	00092693          	slti	a3,s2,0
    64b6:	a2f512d3          	flt.d	t0,fa0,fa5
    64ba:	eca6                	sd	s1,88(sp)
    64bc:	f0a2                	sd	s0,96(sp)
    64be:	fc56                	sd	s5,56(sp)
    64c0:	e0d2                	sd	s4,64(sp)
    64c2:	42d0190b          	th.mvnez	s2,zero,a3
    64c6:	00a7a533          	slt	a0,a5,a0
    64ca:	b422                	fsd	fs0,40(sp)
    64cc:	b026                	fsd	fs1,32(sp)
    64ce:	ac4a                	fsd	fs2,24(sp)
    64d0:	f486                	sd	ra,104(sp)
    64d2:	84ae                	mv	s1,a1
    64d4:	42a7990b          	th.mvnez	s2,a5,a0
    64d8:	4a029263          	bnez	t0,697c <fcvt+0x4dc>
    64dc:	00062023          	sw	zero,0(a2)
    64e0:	850a                	mv	a0,sp
    64e2:	294090ef          	jal	f776 <modf>
    64e6:	2e02                	fld	ft8,0(sp)
    64e8:	f2000953          	fmv.d.x	fs2,zero
    64ec:	22a50453          	fmv.d	fs0,fa0
    64f0:	a32e23d3          	feq.d	t2,ft8,fs2
    64f4:	3a039a63          	bnez	t2,68a8 <fcvt+0x408>
    64f8:	00041337          	lui	t1,0x41
    64fc:	63c5                	lui	t2,0x11
    64fe:	65c5                	lui	a1,0x11
    6500:	a84e                	fsd	fs3,16(sp)
    6502:	fe030413          	addi	s0,t1,-32 # 40fe0 <CVTBUF>
    6506:	ba83b487          	fld	fs1,-1112(t2) # 10ba8 <errpat+0x38>
    650a:	bb05b987          	fld	fs3,-1104(a1) # 10bb0 <errpat+0x40>
    650e:	05040993          	addi	s3,s0,80
    6512:	f85a                	sd	s6,48(sp)
    6514:	4a81                	li	s5,0
    6516:	8b4e                	mv	s6,s3
    6518:	1a9e7553          	fdiv.d	fa0,ft8,fs1
    651c:	850a                	mv	a0,sp
    651e:	1b7d                	addi	s6,s6,-1
    6520:	2a85                	addiw	s5,s5,1
    6522:	8a5a                	mv	s4,s6
    6524:	252090ef          	jal	f776 <modf>
    6528:	a42a                	fsd	fa0,8(sp)
    652a:	03357553          	fadd.d	fa0,fa0,fs3
    652e:	2102                	fld	ft2,0(sp)
    6530:	8356                	mv	t1,s5
    6532:	129570d3          	fmul.d	ft1,fa0,fs1
    6536:	a3212853          	feq.d	a6,ft2,fs2
    653a:	c2009653          	fcvt.w.d	a2,ft1,rtz
    653e:	0306071b          	addiw	a4,a2,48
    6542:	0ff77293          	zext.b	t0,a4
    6546:	005b0023          	sb	t0,0(s6)
    654a:	0a081063          	bnez	a6,65ea <fcvt+0x14a>
    654e:	1a917553          	fdiv.d	fa0,ft2,fs1
    6552:	850a                	mv	a0,sp
    6554:	2a85                	addiw	s5,s5,1
    6556:	220090ef          	jal	f776 <modf>
    655a:	033571d3          	fadd.d	ft3,fa0,fs3
    655e:	2282                	fld	ft5,0(sp)
    6560:	a42a                	fsd	fa0,8(sp)
    6562:	1291f253          	fmul.d	ft4,ft3,fs1
    6566:	a322aed3          	feq.d	t4,ft5,fs2
    656a:	8356                	mv	t1,s5
    656c:	c20218d3          	fcvt.w.d	a7,ft4,rtz
    6570:	03088e1b          	addiw	t3,a7,48
    6574:	0ffe7293          	zext.b	t0,t3
    6578:	09fb528b          	th.sbib	t0,(s6),-1,0
    657c:	060e9763          	bnez	t4,65ea <fcvt+0x14a>
    6580:	1a92f553          	fdiv.d	fa0,ft5,fs1
    6584:	850a                	mv	a0,sp
    6586:	2a85                	addiw	s5,s5,1
    6588:	ffea0b13          	addi	s6,s4,-2
    658c:	1ea090ef          	jal	f776 <modf>
    6590:	03357353          	fadd.d	ft6,fa0,fs3
    6594:	2582                	fld	fa1,0(sp)
    6596:	a42a                	fsd	fa0,8(sp)
    6598:	129373d3          	fmul.d	ft7,ft6,fs1
    659c:	a325a6d3          	feq.d	a3,fa1,fs2
    65a0:	8356                	mv	t1,s5
    65a2:	c2039f53          	fcvt.w.d	t5,ft7,rtz
    65a6:	030f0f9b          	addiw	t6,t5,48
    65aa:	0ffff293          	zext.b	t0,t6
    65ae:	fe5a0f23          	sb	t0,-2(s4)
    65b2:	ee85                	bnez	a3,65ea <fcvt+0x14a>
    65b4:	1a95f553          	fdiv.d	fa0,fa1,fs1
    65b8:	850a                	mv	a0,sp
    65ba:	2a85                	addiw	s5,s5,1
    65bc:	ffda0b13          	addi	s6,s4,-3
    65c0:	1b6090ef          	jal	f776 <modf>
    65c4:	03357853          	fadd.d	fa6,fa0,fs3
    65c8:	2e02                	fld	ft8,0(sp)
    65ca:	a42a                	fsd	fa0,8(sp)
    65cc:	129878d3          	fmul.d	fa7,fa6,fs1
    65d0:	a32e23d3          	feq.d	t2,ft8,fs2
    65d4:	8356                	mv	t1,s5
    65d6:	c20897d3          	fcvt.w.d	a5,fa7,rtz
    65da:	0307851b          	addiw	a0,a5,48
    65de:	0ff57293          	zext.b	t0,a0
    65e2:	fe5a0ea3          	sb	t0,-3(s4)
    65e6:	f20389e3          	beqz	t2,6518 <fcvt+0x78>
    65ea:	875a                	mv	a4,s6
    65ec:	86a2                	mv	a3,s0
    65ee:	3b3b7e63          	bgeu	s6,s3,69aa <fcvt+0x50a>
    65f2:	fffb4593          	not	a1,s6
    65f6:	00b98a33          	add	s4,s3,a1
    65fa:	007a7613          	andi	a2,s4,7
    65fe:	c65d                	beqz	a2,66ac <fcvt+0x20c>
    6600:	1816d28b          	th.sbia	t0,(a3),1,0
    6604:	4805                	li	a6,1
    6606:	8817428b          	th.lbuib	t0,(a4),1,0
    660a:	0b060163          	beq	a2,a6,66ac <fcvt+0x20c>
    660e:	4889                	li	a7,2
    6610:	05160563          	beq	a2,a7,665a <fcvt+0x1ba>
    6614:	4e0d                	li	t3,3
    6616:	03c60e63          	beq	a2,t3,6652 <fcvt+0x1b2>
    661a:	4e91                	li	t4,4
    661c:	03d60763          	beq	a2,t4,664a <fcvt+0x1aa>
    6620:	4f15                	li	t5,5
    6622:	03e60063          	beq	a2,t5,6642 <fcvt+0x1a2>
    6626:	4f99                	li	t6,6
    6628:	01f60963          	beq	a2,t6,663a <fcvt+0x19a>
    662c:	875a                	mv	a4,s6
    662e:	005400a3          	sb	t0,1(s0)
    6632:	8827428b          	th.lbuib	t0,(a4),2,0
    6636:	00240693          	addi	a3,s0,2
    663a:	1816d28b          	th.sbia	t0,(a3),1,0
    663e:	8817428b          	th.lbuib	t0,(a4),1,0
    6642:	1816d28b          	th.sbia	t0,(a3),1,0
    6646:	8817428b          	th.lbuib	t0,(a4),1,0
    664a:	1816d28b          	th.sbia	t0,(a3),1,0
    664e:	8817428b          	th.lbuib	t0,(a4),1,0
    6652:	1816d28b          	th.sbia	t0,(a3),1,0
    6656:	8817428b          	th.lbuib	t0,(a4),1,0
    665a:	1816d28b          	th.sbia	t0,(a3),1,0
    665e:	8817428b          	th.lbuib	t0,(a4),1,0
    6662:	00170793          	addi	a5,a4,1
    6666:	00568023          	sb	t0,0(a3)
    666a:	04f98763          	beq	s3,a5,66b8 <fcvt+0x218>
    666e:	00174e03          	lbu	t3,1(a4)
    6672:	06a1                	addi	a3,a3,8
    6674:	ffc68ca3          	sb	t3,-7(a3)
    6678:	00274e83          	lbu	t4,2(a4)
    667c:	ffd68d23          	sb	t4,-6(a3)
    6680:	00374f03          	lbu	t5,3(a4)
    6684:	ffe68da3          	sb	t5,-5(a3)
    6688:	00474f83          	lbu	t6,4(a4)
    668c:	fff68e23          	sb	t6,-4(a3)
    6690:	00574503          	lbu	a0,5(a4)
    6694:	fea68ea3          	sb	a0,-3(a3)
    6698:	00674283          	lbu	t0,6(a4)
    669c:	fe568f23          	sb	t0,-2(a3)
    66a0:	00774383          	lbu	t2,7(a4)
    66a4:	fe768fa3          	sb	t2,-1(a3)
    66a8:	8887428b          	th.lbuib	t0,(a4),8,0
    66ac:	00170793          	addi	a5,a4,1
    66b0:	00568023          	sb	t0,0(a3)
    66b4:	faf99de3          	bne	s3,a5,666e <fcvt+0x1ce>
    66b8:	9aca                	add	s5,s5,s2
    66ba:	01540933          	add	s2,s0,s5
    66be:	0064a023          	sw	t1,0(s1)
    66c2:	2c896363          	bltu	s2,s0,6988 <fcvt+0x4e8>
    66c6:	01340533          	add	a0,s0,s3
    66ca:	41650a33          	sub	s4,a0,s6
    66ce:	29c2                	fld	fs3,16(sp)
    66d0:	7b42                	ld	s6,48(sp)
    66d2:	11496763          	bltu	s2,s4,67e0 <fcvt+0x340>
    66d6:	41498333          	sub	t1,s3,s4
    66da:	62c5                	lui	t0,0x11
    66dc:	00337a93          	andi	s5,t1,3
    66e0:	ba82b907          	fld	fs2,-1112(t0) # 10ba8 <errpat+0x38>
    66e4:	060a8a63          	beqz	s5,6758 <fcvt+0x2b8>
    66e8:	0f3a7c63          	bgeu	s4,s3,67e0 <fcvt+0x340>
    66ec:	13247553          	fmul.d	fa0,fs0,fs2
    66f0:	0028                	addi	a0,sp,8
    66f2:	084090ef          	jal	f776 <modf>
    66f6:	2ea2                	fld	ft9,8(sp)
    66f8:	22a50453          	fmv.d	fs0,fa0
    66fc:	c20e93d3          	fcvt.w.d	t2,ft9,rtz
    6700:	0303859b          	addiw	a1,t2,48
    6704:	181a558b          	th.sbia	a1,(s4),1,0
    6708:	0d496c63          	bltu	s2,s4,67e0 <fcvt+0x340>
    670c:	4605                	li	a2,1
    670e:	04ca8563          	beq	s5,a2,6758 <fcvt+0x2b8>
    6712:	4809                	li	a6,2
    6714:	030a8263          	beq	s5,a6,6738 <fcvt+0x298>
    6718:	13257553          	fmul.d	fa0,fa0,fs2
    671c:	0028                	addi	a0,sp,8
    671e:	058090ef          	jal	f776 <modf>
    6722:	2f22                	fld	ft10,8(sp)
    6724:	22a50453          	fmv.d	fs0,fa0
    6728:	c20f18d3          	fcvt.w.d	a7,ft10,rtz
    672c:	03088e1b          	addiw	t3,a7,48
    6730:	181a5e0b          	th.sbia	t3,(s4),1,0
    6734:	0b496663          	bltu	s2,s4,67e0 <fcvt+0x340>
    6738:	13247553          	fmul.d	fa0,fs0,fs2
    673c:	0028                	addi	a0,sp,8
    673e:	038090ef          	jal	f776 <modf>
    6742:	2fa2                	fld	ft11,8(sp)
    6744:	22a50453          	fmv.d	fs0,fa0
    6748:	c20f9ed3          	fcvt.w.d	t4,ft11,rtz
    674c:	030e8f1b          	addiw	t5,t4,48
    6750:	181a5f0b          	th.sbia	t5,(s4),1,0
    6754:	09496663          	bltu	s2,s4,67e0 <fcvt+0x340>
    6758:	093a7463          	bgeu	s4,s3,67e0 <fcvt+0x340>
    675c:	13247553          	fmul.d	fa0,fs0,fs2
    6760:	0028                	addi	a0,sp,8
    6762:	014090ef          	jal	f776 <modf>
    6766:	27a2                	fld	fa5,8(sp)
    6768:	8fd2                	mv	t6,s4
    676a:	c2079753          	fcvt.w.d	a4,fa5,rtz
    676e:	0307069b          	addiw	a3,a4,48
    6772:	181fd68b          	th.sbia	a3,(t6),1,0
    6776:	07f96563          	bltu	s2,t6,67e0 <fcvt+0x340>
    677a:	13257553          	fmul.d	fa0,fa0,fs2
    677e:	0028                	addi	a0,sp,8
    6780:	7f7080ef          	jal	f776 <modf>
    6784:	2722                	fld	fa4,8(sp)
    6786:	002a0793          	addi	a5,s4,2
    678a:	c2071553          	fcvt.w.d	a0,fa4,rtz
    678e:	0305029b          	addiw	t0,a0,48
    6792:	005a00a3          	sb	t0,1(s4)
    6796:	04f96563          	bltu	s2,a5,67e0 <fcvt+0x340>
    679a:	13257553          	fmul.d	fa0,fa0,fs2
    679e:	0028                	addi	a0,sp,8
    67a0:	7d7080ef          	jal	f776 <modf>
    67a4:	2622                	fld	fa2,8(sp)
    67a6:	003a0313          	addi	t1,s4,3
    67aa:	c2061ad3          	fcvt.w.d	s5,fa2,rtz
    67ae:	030a839b          	addiw	t2,s5,48
    67b2:	007a0123          	sb	t2,2(s4)
    67b6:	02696563          	bltu	s2,t1,67e0 <fcvt+0x340>
    67ba:	13257553          	fmul.d	fa0,fa0,fs2
    67be:	0028                	addi	a0,sp,8
    67c0:	0a11                	addi	s4,s4,4
    67c2:	7b5080ef          	jal	f776 <modf>
    67c6:	26a2                	fld	fa3,8(sp)
    67c8:	22a50453          	fmv.d	fs0,fa0
    67cc:	c20695d3          	fcvt.w.d	a1,fa3,rtz
    67d0:	0305861b          	addiw	a2,a1,48
    67d4:	feca0fa3          	sb	a2,-1(s4)
    67d8:	f94970e3          	bgeu	s2,s4,6758 <fcvt+0x2b8>
    67dc:	00000013          	nop
    67e0:	1b397a63          	bgeu	s2,s3,6994 <fcvt+0x4f4>
    67e4:	00094983          	lbu	s3,0(s2)
    67e8:	03900e13          	li	t3,57
    67ec:	0059881b          	addiw	a6,s3,5
    67f0:	0ff87893          	zext.b	a7,a6
    67f4:	01190023          	sb	a7,0(s2)
    67f8:	071e7463          	bgeu	t3,a7,6860 <fcvt+0x3c0>
    67fc:	03000e93          	li	t4,48
    6800:	87ca                	mv	a5,s2
    6802:	8f76                	mv	t5,t4
    6804:	03100f93          	li	t6,49
    6808:	06f46c63          	bltu	s0,a5,6880 <fcvt+0x3e0>
    680c:	01f78023          	sb	t6,0(a5)
    6810:	4098                	lw	a4,0(s1)
    6812:	0017069b          	addiw	a3,a4,1
    6816:	c094                	sw	a3,0(s1)
    6818:	01247463          	bgeu	s0,s2,6820 <fcvt+0x380>
    681c:	01d90023          	sb	t4,0(s2)
    6820:	0007c503          	lbu	a0,0(a5)
    6824:	0905                	addi	s2,s2,1
    6826:	02ae7d63          	bgeu	t3,a0,6860 <fcvt+0x3c0>
    682a:	04f46b63          	bltu	s0,a5,6880 <fcvt+0x3e0>
    682e:	03100293          	li	t0,49
    6832:	03900313          	li	t1,57
    6836:	03000a93          	li	s5,48
    683a:	00578023          	sb	t0,0(a5)
    683e:	0004a383          	lw	t2,0(s1)
    6842:	00138a1b          	addiw	s4,t2,1
    6846:	0144a023          	sw	s4,0(s1)
    684a:	05247963          	bgeu	s0,s2,689c <fcvt+0x3fc>
    684e:	18195a8b          	th.sbia	s5,(s2),1,0
    6852:	0007c603          	lbu	a2,0(a5)
    6856:	fec362e3          	bltu	t1,a2,683a <fcvt+0x39a>
    685a:	0001                	nop
    685c:	00000013          	nop
    6860:	00090023          	sb	zero,0(s2)
    6864:	70a6                	ld	ra,104(sp)
    6866:	8522                	mv	a0,s0
    6868:	64e6                	ld	s1,88(sp)
    686a:	7406                	ld	s0,96(sp)
    686c:	7ae2                	ld	s5,56(sp)
    686e:	6a06                	ld	s4,64(sp)
    6870:	69a6                	ld	s3,72(sp)
    6872:	6946                	ld	s2,80(sp)
    6874:	3422                	fld	fs0,40(sp)
    6876:	3482                	fld	fs1,32(sp)
    6878:	2962                	fld	fs2,24(sp)
    687a:	6165                	addi	sp,sp,112
    687c:	8082                	ret
    687e:	0001                	nop
    6880:	fff7c983          	lbu	s3,-1(a5)
    6884:	01e78023          	sb	t5,0(a5)
    6888:	0019881b          	addiw	a6,s3,1
    688c:	0ff87893          	zext.b	a7,a6
    6890:	ff178fa3          	sb	a7,-1(a5)
    6894:	fd1e76e3          	bgeu	t3,a7,6860 <fcvt+0x3c0>
    6898:	17fd                	addi	a5,a5,-1
    689a:	b7bd                	j	6808 <fcvt+0x368>
    689c:	0007c583          	lbu	a1,0(a5)
    68a0:	0905                	addi	s2,s2,1
    68a2:	f8b36ce3          	bltu	t1,a1,683a <fcvt+0x39a>
    68a6:	bf6d                	j	6860 <fcvt+0x3c0>
    68a8:	a2a91453          	flt.d	s0,fs2,fa0
    68ac:	c865                	beqz	s0,699c <fcvt+0x4fc>
    68ae:	6745                	lui	a4,0x11
    68b0:	ba873707          	fld	fa4,-1112(a4) # 10ba8 <errpat+0x38>
    68b4:	6845                	lui	a6,0x11
    68b6:	bb883607          	fld	fa2,-1096(a6) # 10bb8 <errpat+0x48>
    68ba:	12e57053          	fmul.d	ft0,fa0,fa4
    68be:	4a81                	li	s5,0
    68c0:	22c606d3          	fmv.d	fa3,fa2
    68c4:	a2c018d3          	flt.d	a7,ft0,fa2
    68c8:	0e088563          	beqz	a7,69b2 <fcvt+0x512>
    68cc:	22000453          	fmv.d	fs0,ft0
    68d0:	3afd                	addiw	s5,s5,-1
    68d2:	12e07053          	fmul.d	ft0,ft0,fa4
    68d6:	a2d01a53          	flt.d	s4,ft0,fa3
    68da:	060a0f63          	beqz	s4,6958 <fcvt+0x4b8>
    68de:	22000453          	fmv.d	fs0,ft0
    68e2:	3afd                	addiw	s5,s5,-1
    68e4:	12e07053          	fmul.d	ft0,ft0,fa4
    68e8:	a2d01e53          	flt.d	t3,ft0,fa3
    68ec:	060e0663          	beqz	t3,6958 <fcvt+0x4b8>
    68f0:	22000453          	fmv.d	fs0,ft0
    68f4:	3afd                	addiw	s5,s5,-1
    68f6:	12e07053          	fmul.d	ft0,ft0,fa4
    68fa:	a2d01ed3          	flt.d	t4,ft0,fa3
    68fe:	040e8d63          	beqz	t4,6958 <fcvt+0x4b8>
    6902:	22000453          	fmv.d	fs0,ft0
    6906:	3afd                	addiw	s5,s5,-1
    6908:	12e07053          	fmul.d	ft0,ft0,fa4
    690c:	a2d01f53          	flt.d	t5,ft0,fa3
    6910:	040f0463          	beqz	t5,6958 <fcvt+0x4b8>
    6914:	22000453          	fmv.d	fs0,ft0
    6918:	3afd                	addiw	s5,s5,-1
    691a:	12e07053          	fmul.d	ft0,ft0,fa4
    691e:	a2d01fd3          	flt.d	t6,ft0,fa3
    6922:	020f8b63          	beqz	t6,6958 <fcvt+0x4b8>
    6926:	22000453          	fmv.d	fs0,ft0
    692a:	3afd                	addiw	s5,s5,-1
    692c:	12e07053          	fmul.d	ft0,ft0,fa4
    6930:	a2d017d3          	flt.d	a5,ft0,fa3
    6934:	c395                	beqz	a5,6958 <fcvt+0x4b8>
    6936:	22000453          	fmv.d	fs0,ft0
    693a:	3afd                	addiw	s5,s5,-1
    693c:	12e07053          	fmul.d	ft0,ft0,fa4
    6940:	a2d016d3          	flt.d	a3,ft0,fa3
    6944:	ca91                	beqz	a3,6958 <fcvt+0x4b8>
    6946:	22000453          	fmv.d	fs0,ft0
    694a:	3afd                	addiw	s5,s5,-1
    694c:	12e07053          	fmul.d	ft0,ft0,fa4
    6950:	a2d01553          	flt.d	a0,ft0,fa3
    6954:	fd25                	bnez	a0,68cc <fcvt+0x42c>
    6956:	0001                	nop
    6958:	000412b7          	lui	t0,0x41
    695c:	a402                	fsd	ft0,8(sp)
    695e:	85d6                	mv	a1,s5
    6960:	fe028413          	addi	s0,t0,-32 # 40fe0 <CVTBUF>
    6964:	992e                	add	s2,s2,a1
    6966:	9922                	add	s2,s2,s0
    6968:	0154a023          	sw	s5,0(s1)
    696c:	02896063          	bltu	s2,s0,698c <fcvt+0x4ec>
    6970:	000419b7          	lui	s3,0x41
    6974:	8a22                	mv	s4,s0
    6976:	03098993          	addi	s3,s3,48 # 41030 <__malloc_current_mallinfo>
    697a:	bbb1                	j	66d6 <fcvt+0x236>
    697c:	4305                	li	t1,1
    697e:	22a51553          	fneg.d	fa0,fa0
    6982:	00662023          	sw	t1,0(a2)
    6986:	bea9                	j	64e0 <fcvt+0x40>
    6988:	29c2                	fld	fs3,16(sp)
    698a:	7b42                	ld	s6,48(sp)
    698c:	00040023          	sb	zero,0(s0)
    6990:	bdd1                	j	6864 <fcvt+0x3c4>
    6992:	0001                	nop
    6994:	040407a3          	sb	zero,79(s0)
    6998:	b5f1                	j	6864 <fcvt+0x3c4>
    699a:	0001                	nop
    699c:	00041637          	lui	a2,0x41
    69a0:	4581                	li	a1,0
    69a2:	4a81                	li	s5,0
    69a4:	fe060413          	addi	s0,a2,-32 # 40fe0 <CVTBUF>
    69a8:	bf75                	j	6964 <fcvt+0x4c4>
    69aa:	29c2                	fld	fs3,16(sp)
    69ac:	7b42                	ld	s6,48(sp)
    69ae:	85d6                	mv	a1,s5
    69b0:	bf55                	j	6964 <fcvt+0x4c4>
    69b2:	000419b7          	lui	s3,0x41
    69b6:	a402                	fsd	ft0,8(sp)
    69b8:	4581                	li	a1,0
    69ba:	fe098413          	addi	s0,s3,-32 # 40fe0 <CVTBUF>
    69be:	b75d                	j	6964 <fcvt+0x4c4>

00000000000069c0 <fcvtbuf>:
    69c0:	7159                	addi	sp,sp,-112
    69c2:	f20007d3          	fmv.d.x	fa5,zero
    69c6:	e4ce                	sd	s3,72(sp)
    69c8:	e8ca                	sd	s2,80(sp)
    69ca:	0005091b          	sext.w	s2,a0
    69ce:	04e00793          	li	a5,78
    69d2:	eca6                	sd	s1,88(sp)
    69d4:	f0a2                	sd	s0,96(sp)
    69d6:	a2f512d3          	flt.d	t0,fa0,fa5
    69da:	8436                	mv	s0,a3
    69dc:	00092693          	slti	a3,s2,0
    69e0:	fc56                	sd	s5,56(sp)
    69e2:	e0d2                	sd	s4,64(sp)
    69e4:	42d0190b          	th.mvnez	s2,zero,a3
    69e8:	00a7a533          	slt	a0,a5,a0
    69ec:	b422                	fsd	fs0,40(sp)
    69ee:	b026                	fsd	fs1,32(sp)
    69f0:	ac4a                	fsd	fs2,24(sp)
    69f2:	f486                	sd	ra,104(sp)
    69f4:	84ae                	mv	s1,a1
    69f6:	42a7990b          	th.mvnez	s2,a5,a0
    69fa:	64029763          	bnez	t0,7048 <fcvtbuf+0x688>
    69fe:	00062023          	sw	zero,0(a2)
    6a02:	850a                	mv	a0,sp
    6a04:	573080ef          	jal	f776 <modf>
    6a08:	2e02                	fld	ft8,0(sp)
    6a0a:	f2000953          	fmv.d.x	fs2,zero
    6a0e:	22a50453          	fmv.d	fs0,fa0
    6a12:	a32e23d3          	feq.d	t2,ft8,fs2
    6a16:	56039363          	bnez	t2,6f7c <fcvtbuf+0x5bc>
    6a1a:	6545                	lui	a0,0x11
    6a1c:	62c5                	lui	t0,0x11
    6a1e:	a84e                	fsd	fs3,16(sp)
    6a20:	ba853487          	fld	fs1,-1112(a0) # 10ba8 <errpat+0x38>
    6a24:	bb02b987          	fld	fs3,-1104(t0) # 10bb0 <errpat+0x40>
    6a28:	05040993          	addi	s3,s0,80
    6a2c:	f85a                	sd	s6,48(sp)
    6a2e:	4a81                	li	s5,0
    6a30:	8b4e                	mv	s6,s3
    6a32:	1a9e7553          	fdiv.d	fa0,ft8,fs1
    6a36:	850a                	mv	a0,sp
    6a38:	1b7d                	addi	s6,s6,-1
    6a3a:	2a85                	addiw	s5,s5,1
    6a3c:	8a5a                	mv	s4,s6
    6a3e:	539080ef          	jal	f776 <modf>
    6a42:	a42a                	fsd	fa0,8(sp)
    6a44:	03357553          	fadd.d	fa0,fa0,fs3
    6a48:	2102                	fld	ft2,0(sp)
    6a4a:	86d6                	mv	a3,s5
    6a4c:	129570d3          	fmul.d	ft1,fa0,fs1
    6a50:	a32125d3          	feq.d	a1,ft2,fs2
    6a54:	c2009353          	fcvt.w.d	t1,ft1,rtz
    6a58:	0303039b          	addiw	t2,t1,48
    6a5c:	0ff3f793          	zext.b	a5,t2
    6a60:	00fb0023          	sb	a5,0(s6)
    6a64:	edd9                	bnez	a1,6b02 <fcvtbuf+0x142>
    6a66:	1a917553          	fdiv.d	fa0,ft2,fs1
    6a6a:	850a                	mv	a0,sp
    6a6c:	2a85                	addiw	s5,s5,1
    6a6e:	509080ef          	jal	f776 <modf>
    6a72:	033571d3          	fadd.d	ft3,fa0,fs3
    6a76:	2282                	fld	ft5,0(sp)
    6a78:	a42a                	fsd	fa0,8(sp)
    6a7a:	1291f253          	fmul.d	ft4,ft3,fs1
    6a7e:	a322a853          	feq.d	a6,ft5,fs2
    6a82:	86d6                	mv	a3,s5
    6a84:	c2021653          	fcvt.w.d	a2,ft4,rtz
    6a88:	0306071b          	addiw	a4,a2,48
    6a8c:	0ff77793          	zext.b	a5,a4
    6a90:	09fb578b          	th.sbib	a5,(s6),-1,0
    6a94:	06081763          	bnez	a6,6b02 <fcvtbuf+0x142>
    6a98:	1a92f553          	fdiv.d	fa0,ft5,fs1
    6a9c:	850a                	mv	a0,sp
    6a9e:	2a85                	addiw	s5,s5,1
    6aa0:	ffea0b13          	addi	s6,s4,-2
    6aa4:	4d3080ef          	jal	f776 <modf>
    6aa8:	03357353          	fadd.d	ft6,fa0,fs3
    6aac:	2582                	fld	fa1,0(sp)
    6aae:	a42a                	fsd	fa0,8(sp)
    6ab0:	129373d3          	fmul.d	ft7,ft6,fs1
    6ab4:	a325aed3          	feq.d	t4,fa1,fs2
    6ab8:	86d6                	mv	a3,s5
    6aba:	c20398d3          	fcvt.w.d	a7,ft7,rtz
    6abe:	03088e1b          	addiw	t3,a7,48
    6ac2:	0ffe7793          	zext.b	a5,t3
    6ac6:	fefa0f23          	sb	a5,-2(s4)
    6aca:	020e9c63          	bnez	t4,6b02 <fcvtbuf+0x142>
    6ace:	1a95f553          	fdiv.d	fa0,fa1,fs1
    6ad2:	850a                	mv	a0,sp
    6ad4:	2a85                	addiw	s5,s5,1
    6ad6:	ffda0b13          	addi	s6,s4,-3
    6ada:	49d080ef          	jal	f776 <modf>
    6ade:	03357853          	fadd.d	fa6,fa0,fs3
    6ae2:	2e02                	fld	ft8,0(sp)
    6ae4:	a42a                	fsd	fa0,8(sp)
    6ae6:	129878d3          	fmul.d	fa7,fa6,fs1
    6aea:	a32e2553          	feq.d	a0,ft8,fs2
    6aee:	86d6                	mv	a3,s5
    6af0:	c2089f53          	fcvt.w.d	t5,fa7,rtz
    6af4:	030f0f9b          	addiw	t6,t5,48
    6af8:	0ffff793          	zext.b	a5,t6
    6afc:	fefa0ea3          	sb	a5,-3(s4)
    6b00:	d90d                	beqz	a0,6a32 <fcvtbuf+0x72>
    6b02:	573b7663          	bgeu	s6,s3,706e <fcvtbuf+0x6ae>
    6b06:	416402b3          	sub	t0,s0,s6
    6b0a:	04f28313          	addi	t1,t0,79
    6b0e:	00737393          	andi	t2,t1,7
    6b12:	05028a13          	addi	s4,t0,80
    6b16:	4701                	li	a4,0
    6b18:	0c038763          	beqz	t2,6be6 <fcvtbuf+0x226>
    6b1c:	00f40023          	sb	a5,0(s0)
    6b20:	4705                	li	a4,1
    6b22:	80eb478b          	th.lrbu	a5,s6,a4,0
    6b26:	0ce38063          	beq	t2,a4,6be6 <fcvtbuf+0x226>
    6b2a:	4589                	li	a1,2
    6b2c:	04b38763          	beq	t2,a1,6b7a <fcvtbuf+0x1ba>
    6b30:	460d                	li	a2,3
    6b32:	02c38f63          	beq	t2,a2,6b70 <fcvtbuf+0x1b0>
    6b36:	4811                	li	a6,4
    6b38:	03038763          	beq	t2,a6,6b66 <fcvtbuf+0x1a6>
    6b3c:	4895                	li	a7,5
    6b3e:	01138f63          	beq	t2,a7,6b5c <fcvtbuf+0x19c>
    6b42:	4e19                	li	t3,6
    6b44:	01c38763          	beq	t2,t3,6b52 <fcvtbuf+0x192>
    6b48:	00e4578b          	th.srb	a5,s0,a4,0
    6b4c:	80bb478b          	th.lrbu	a5,s6,a1,0
    6b50:	872e                	mv	a4,a1
    6b52:	00e4578b          	th.srb	a5,s0,a4,0
    6b56:	0705                	addi	a4,a4,1
    6b58:	80eb478b          	th.lrbu	a5,s6,a4,0
    6b5c:	00e4578b          	th.srb	a5,s0,a4,0
    6b60:	0705                	addi	a4,a4,1
    6b62:	80eb478b          	th.lrbu	a5,s6,a4,0
    6b66:	00e4578b          	th.srb	a5,s0,a4,0
    6b6a:	0705                	addi	a4,a4,1
    6b6c:	80eb478b          	th.lrbu	a5,s6,a4,0
    6b70:	00e4578b          	th.srb	a5,s0,a4,0
    6b74:	0705                	addi	a4,a4,1
    6b76:	80eb478b          	th.lrbu	a5,s6,a4,0
    6b7a:	00e4578b          	th.srb	a5,s0,a4,0
    6b7e:	0705                	addi	a4,a4,1
    6b80:	80eb478b          	th.lrbu	a5,s6,a4,0
    6b84:	00170e93          	addi	t4,a4,1
    6b88:	00e4578b          	th.srb	a5,s0,a4,0
    6b8c:	074e8363          	beq	t4,s4,6bf2 <fcvtbuf+0x232>
    6b90:	81db488b          	th.lrbu	a7,s6,t4,0
    6b94:	00270593          	addi	a1,a4,2
    6b98:	00370293          	addi	t0,a4,3
    6b9c:	01d4588b          	th.srb	a7,s0,t4,0
    6ba0:	80bb460b          	th.lrbu	a2,s6,a1,0
    6ba4:	00470393          	addi	t2,a4,4
    6ba8:	00570e13          	addi	t3,a4,5
    6bac:	00b4560b          	th.srb	a2,s0,a1,0
    6bb0:	805b430b          	th.lrbu	t1,s6,t0,0
    6bb4:	00670f13          	addi	t5,a4,6
    6bb8:	00770513          	addi	a0,a4,7
    6bbc:	0054530b          	th.srb	t1,s0,t0,0
    6bc0:	807b480b          	th.lrbu	a6,s6,t2,0
    6bc4:	0721                	addi	a4,a4,8
    6bc6:	0074580b          	th.srb	a6,s0,t2,0
    6bca:	81cb4e8b          	th.lrbu	t4,s6,t3,0
    6bce:	01c45e8b          	th.srb	t4,s0,t3,0
    6bd2:	81eb4f8b          	th.lrbu	t6,s6,t5,0
    6bd6:	01e45f8b          	th.srb	t6,s0,t5,0
    6bda:	80ab478b          	th.lrbu	a5,s6,a0,0
    6bde:	00a4578b          	th.srb	a5,s0,a0,0
    6be2:	80eb478b          	th.lrbu	a5,s6,a4,0
    6be6:	00e4578b          	th.srb	a5,s0,a4,0
    6bea:	00170e93          	addi	t4,a4,1
    6bee:	fb4e91e3          	bne	t4,s4,6b90 <fcvtbuf+0x1d0>
    6bf2:	9aca                	add	s5,s5,s2
    6bf4:	01540933          	add	s2,s0,s5
    6bf8:	c094                	sw	a3,0(s1)
    6bfa:	44896d63          	bltu	s2,s0,7054 <fcvtbuf+0x694>
    6bfe:	9a22                	add	s4,s4,s0
    6c00:	29c2                	fld	fs3,16(sp)
    6c02:	7b42                	ld	s6,48(sp)
    6c04:	11496a63          	bltu	s2,s4,6d18 <fcvtbuf+0x358>
    6c08:	41498fb3          	sub	t6,s3,s4
    6c0c:	6f45                	lui	t5,0x11
    6c0e:	003ffa93          	andi	s5,t6,3
    6c12:	ba8f3907          	fld	fs2,-1112(t5) # 10ba8 <errpat+0x38>
    6c16:	060a8d63          	beqz	s5,6c90 <fcvtbuf+0x2d0>
    6c1a:	0f3a7f63          	bgeu	s4,s3,6d18 <fcvtbuf+0x358>
    6c1e:	13247553          	fmul.d	fa0,fs0,fs2
    6c22:	0028                	addi	a0,sp,8
    6c24:	353080ef          	jal	f776 <modf>
    6c28:	2ea2                	fld	ft9,8(sp)
    6c2a:	22a50453          	fmv.d	fs0,fa0
    6c2e:	c20e97d3          	fcvt.w.d	a5,ft9,rtz
    6c32:	0307869b          	addiw	a3,a5,48
    6c36:	181a568b          	th.sbia	a3,(s4),1,0
    6c3a:	0d496f63          	bltu	s2,s4,6d18 <fcvtbuf+0x358>
    6c3e:	4505                	li	a0,1
    6c40:	04aa8863          	beq	s5,a0,6c90 <fcvtbuf+0x2d0>
    6c44:	4289                	li	t0,2
    6c46:	025a8263          	beq	s5,t0,6c6a <fcvtbuf+0x2aa>
    6c4a:	13257553          	fmul.d	fa0,fa0,fs2
    6c4e:	0028                	addi	a0,sp,8
    6c50:	327080ef          	jal	f776 <modf>
    6c54:	2f22                	fld	ft10,8(sp)
    6c56:	22a50453          	fmv.d	fs0,fa0
    6c5a:	c20f1353          	fcvt.w.d	t1,ft10,rtz
    6c5e:	0303039b          	addiw	t2,t1,48
    6c62:	181a538b          	th.sbia	t2,(s4),1,0
    6c66:	0b496963          	bltu	s2,s4,6d18 <fcvtbuf+0x358>
    6c6a:	13247553          	fmul.d	fa0,fs0,fs2
    6c6e:	0028                	addi	a0,sp,8
    6c70:	307080ef          	jal	f776 <modf>
    6c74:	2fa2                	fld	ft11,8(sp)
    6c76:	22a50453          	fmv.d	fs0,fa0
    6c7a:	c20f95d3          	fcvt.w.d	a1,ft11,rtz
    6c7e:	0305861b          	addiw	a2,a1,48
    6c82:	181a560b          	th.sbia	a2,(s4),1,0
    6c86:	09496963          	bltu	s2,s4,6d18 <fcvtbuf+0x358>
    6c8a:	0001                	nop
    6c8c:	00000013          	nop
    6c90:	093a7463          	bgeu	s4,s3,6d18 <fcvtbuf+0x358>
    6c94:	13247553          	fmul.d	fa0,fs0,fs2
    6c98:	0028                	addi	a0,sp,8
    6c9a:	2dd080ef          	jal	f776 <modf>
    6c9e:	27a2                	fld	fa5,8(sp)
    6ca0:	8852                	mv	a6,s4
    6ca2:	c20798d3          	fcvt.w.d	a7,fa5,rtz
    6ca6:	03088e1b          	addiw	t3,a7,48
    6caa:	18185e0b          	th.sbia	t3,(a6),1,0
    6cae:	07096563          	bltu	s2,a6,6d18 <fcvtbuf+0x358>
    6cb2:	13257553          	fmul.d	fa0,fa0,fs2
    6cb6:	0028                	addi	a0,sp,8
    6cb8:	2bf080ef          	jal	f776 <modf>
    6cbc:	2722                	fld	fa4,8(sp)
    6cbe:	002a0e93          	addi	t4,s4,2
    6cc2:	c2071753          	fcvt.w.d	a4,fa4,rtz
    6cc6:	03070f1b          	addiw	t5,a4,48
    6cca:	01ea00a3          	sb	t5,1(s4)
    6cce:	05d96563          	bltu	s2,t4,6d18 <fcvtbuf+0x358>
    6cd2:	13257553          	fmul.d	fa0,fa0,fs2
    6cd6:	0028                	addi	a0,sp,8
    6cd8:	29f080ef          	jal	f776 <modf>
    6cdc:	2622                	fld	fa2,8(sp)
    6cde:	003a0f93          	addi	t6,s4,3
    6ce2:	c2061ad3          	fcvt.w.d	s5,fa2,rtz
    6ce6:	030a879b          	addiw	a5,s5,48
    6cea:	00fa0123          	sb	a5,2(s4)
    6cee:	03f96563          	bltu	s2,t6,6d18 <fcvtbuf+0x358>
    6cf2:	13257553          	fmul.d	fa0,fa0,fs2
    6cf6:	0028                	addi	a0,sp,8
    6cf8:	0a11                	addi	s4,s4,4
    6cfa:	27d080ef          	jal	f776 <modf>
    6cfe:	26a2                	fld	fa3,8(sp)
    6d00:	22a50453          	fmv.d	fs0,fa0
    6d04:	c20696d3          	fcvt.w.d	a3,fa3,rtz
    6d08:	0306851b          	addiw	a0,a3,48
    6d0c:	feaa0fa3          	sb	a0,-1(s4)
    6d10:	f94970e3          	bgeu	s2,s4,6c90 <fcvtbuf+0x2d0>
    6d14:	00000013          	nop
    6d18:	35397463          	bgeu	s2,s3,7060 <fcvtbuf+0x6a0>
    6d1c:	00094983          	lbu	s3,0(s2)
    6d20:	03900393          	li	t2,57
    6d24:	0059829b          	addiw	t0,s3,5
    6d28:	0ff2f313          	zext.b	t1,t0
    6d2c:	00690023          	sb	t1,0(s2)
    6d30:	0663f863          	bgeu	t2,t1,6da0 <fcvtbuf+0x3e0>
    6d34:	40890833          	sub	a6,s2,s0
    6d38:	03000593          	li	a1,48
    6d3c:	00787e13          	andi	t3,a6,7
    6d40:	87ca                	mv	a5,s2
    6d42:	88ae                	mv	a7,a1
    6d44:	861e                	mv	a2,t2
    6d46:	160e0163          	beqz	t3,6ea8 <fcvtbuf+0x4e8>
    6d4a:	07246b63          	bltu	s0,s2,6dc0 <fcvtbuf+0x400>
    6d4e:	03100893          	li	a7,49
    6d52:	01178023          	sb	a7,0(a5)
    6d56:	4090                	lw	a2,0(s1)
    6d58:	00160a1b          	addiw	s4,a2,1
    6d5c:	0144a023          	sw	s4,0(s1)
    6d60:	01247463          	bgeu	s0,s2,6d68 <fcvtbuf+0x3a8>
    6d64:	00b90023          	sb	a1,0(s2)
    6d68:	0007c583          	lbu	a1,0(a5)
    6d6c:	03900693          	li	a3,57
    6d70:	0905                	addi	s2,s2,1
    6d72:	02b6f763          	bgeu	a3,a1,6da0 <fcvtbuf+0x3e0>
    6d76:	03100513          	li	a0,49
    6d7a:	03000993          	li	s3,48
    6d7e:	00a78023          	sb	a0,0(a5)
    6d82:	0004a283          	lw	t0,0(s1)
    6d86:	0012831b          	addiw	t1,t0,1
    6d8a:	0064a023          	sw	t1,0(s1)
    6d8e:	1f247163          	bgeu	s0,s2,6f70 <fcvtbuf+0x5b0>
    6d92:	1819598b          	th.sbia	s3,(s2),1,0
    6d96:	0007c803          	lbu	a6,0(a5)
    6d9a:	ff06e2e3          	bltu	a3,a6,6d7e <fcvtbuf+0x3be>
    6d9e:	0001                	nop
    6da0:	00090023          	sb	zero,0(s2)
    6da4:	70a6                	ld	ra,104(sp)
    6da6:	8522                	mv	a0,s0
    6da8:	64e6                	ld	s1,88(sp)
    6daa:	7406                	ld	s0,96(sp)
    6dac:	7ae2                	ld	s5,56(sp)
    6dae:	6a06                	ld	s4,64(sp)
    6db0:	69a6                	ld	s3,72(sp)
    6db2:	6946                	ld	s2,80(sp)
    6db4:	3422                	fld	fs0,40(sp)
    6db6:	3482                	fld	fs1,32(sp)
    6db8:	2962                	fld	fs2,24(sp)
    6dba:	6165                	addi	sp,sp,112
    6dbc:	8082                	ret
    6dbe:	0001                	nop
    6dc0:	8eca                	mv	t4,s2
    6dc2:	19fed58b          	th.sbia	a1,(t4),-1,0
    6dc6:	fff94703          	lbu	a4,-1(s2)
    6dca:	00170f1b          	addiw	t5,a4,1
    6dce:	0fff7f93          	zext.b	t6,t5
    6dd2:	fff90fa3          	sb	t6,-1(s2)
    6dd6:	fdf3f5e3          	bgeu	t2,t6,6da0 <fcvtbuf+0x3e0>
    6dda:	4a85                	li	s5,1
    6ddc:	87f6                	mv	a5,t4
    6dde:	0d5e0563          	beq	t3,s5,6ea8 <fcvtbuf+0x4e8>
    6de2:	4a09                	li	s4,2
    6de4:	0b4e0263          	beq	t3,s4,6e88 <fcvtbuf+0x4c8>
    6de8:	468d                	li	a3,3
    6dea:	08de0163          	beq	t3,a3,6e6c <fcvtbuf+0x4ac>
    6dee:	4511                	li	a0,4
    6df0:	06ae0063          	beq	t3,a0,6e50 <fcvtbuf+0x490>
    6df4:	4995                	li	s3,5
    6df6:	033e0f63          	beq	t3,s3,6e34 <fcvtbuf+0x474>
    6dfa:	4299                	li	t0,6
    6dfc:	005e0e63          	beq	t3,t0,6e18 <fcvtbuf+0x458>
    6e00:	19f7d58b          	th.sbia	a1,(a5),-1,0
    6e04:	fffec303          	lbu	t1,-1(t4)
    6e08:	0013039b          	addiw	t2,t1,1
    6e0c:	0ff3f813          	zext.b	a6,t2
    6e10:	ff0e8fa3          	sb	a6,-1(t4)
    6e14:	f90676e3          	bgeu	a2,a6,6da0 <fcvtbuf+0x3e0>
    6e18:	8e3e                	mv	t3,a5
    6e1a:	19fe588b          	th.sbia	a7,(t3),-1,0
    6e1e:	fff7ce83          	lbu	t4,-1(a5)
    6e22:	001e871b          	addiw	a4,t4,1
    6e26:	0ff77f13          	zext.b	t5,a4
    6e2a:	ffe78fa3          	sb	t5,-1(a5)
    6e2e:	f7e679e3          	bgeu	a2,t5,6da0 <fcvtbuf+0x3e0>
    6e32:	87f2                	mv	a5,t3
    6e34:	8fbe                	mv	t6,a5
    6e36:	19ffd88b          	th.sbia	a7,(t6),-1,0
    6e3a:	fff7ca83          	lbu	s5,-1(a5)
    6e3e:	001a8a1b          	addiw	s4,s5,1
    6e42:	0ffa7693          	zext.b	a3,s4
    6e46:	fed78fa3          	sb	a3,-1(a5)
    6e4a:	f4d67be3          	bgeu	a2,a3,6da0 <fcvtbuf+0x3e0>
    6e4e:	87fe                	mv	a5,t6
    6e50:	853e                	mv	a0,a5
    6e52:	19f5588b          	th.sbia	a7,(a0),-1,0
    6e56:	fff7c983          	lbu	s3,-1(a5)
    6e5a:	0019829b          	addiw	t0,s3,1
    6e5e:	0ff2f313          	zext.b	t1,t0
    6e62:	fe678fa3          	sb	t1,-1(a5)
    6e66:	f2667de3          	bgeu	a2,t1,6da0 <fcvtbuf+0x3e0>
    6e6a:	87aa                	mv	a5,a0
    6e6c:	83be                	mv	t2,a5
    6e6e:	19f3d88b          	th.sbia	a7,(t2),-1,0
    6e72:	fff7c803          	lbu	a6,-1(a5)
    6e76:	00180e1b          	addiw	t3,a6,1
    6e7a:	0ffe7e93          	zext.b	t4,t3
    6e7e:	ffd78fa3          	sb	t4,-1(a5)
    6e82:	f1d67fe3          	bgeu	a2,t4,6da0 <fcvtbuf+0x3e0>
    6e86:	879e                	mv	a5,t2
    6e88:	8f3e                	mv	t5,a5
    6e8a:	19ff588b          	th.sbia	a7,(t5),-1,0
    6e8e:	fff7c703          	lbu	a4,-1(a5)
    6e92:	00170f9b          	addiw	t6,a4,1
    6e96:	0ffffa93          	zext.b	s5,t6
    6e9a:	ff578fa3          	sb	s5,-1(a5)
    6e9e:	87fa                	mv	a5,t5
    6ea0:	f15670e3          	bgeu	a2,s5,6da0 <fcvtbuf+0x3e0>
    6ea4:	00000013          	nop
    6ea8:	eaf473e3          	bgeu	s0,a5,6d4e <fcvtbuf+0x38e>
    6eac:	fff7ce03          	lbu	t3,-1(a5)
    6eb0:	01178023          	sb	a7,0(a5)
    6eb4:	001e0e9b          	addiw	t4,t3,1
    6eb8:	0ffeff13          	zext.b	t5,t4
    6ebc:	ffe78fa3          	sb	t5,-1(a5)
    6ec0:	efe670e3          	bgeu	a2,t5,6da0 <fcvtbuf+0x3e0>
    6ec4:	ffe7c703          	lbu	a4,-2(a5)
    6ec8:	ff178fa3          	sb	a7,-1(a5)
    6ecc:	00170f9b          	addiw	t6,a4,1
    6ed0:	0ffffa93          	zext.b	s5,t6
    6ed4:	ff578f23          	sb	s5,-2(a5)
    6ed8:	ed5674e3          	bgeu	a2,s5,6da0 <fcvtbuf+0x3e0>
    6edc:	ffd7ca03          	lbu	s4,-3(a5)
    6ee0:	ff178f23          	sb	a7,-2(a5)
    6ee4:	001a069b          	addiw	a3,s4,1
    6ee8:	0ff6f513          	zext.b	a0,a3
    6eec:	fea78ea3          	sb	a0,-3(a5)
    6ef0:	eaa678e3          	bgeu	a2,a0,6da0 <fcvtbuf+0x3e0>
    6ef4:	ffc7c983          	lbu	s3,-4(a5)
    6ef8:	ff178ea3          	sb	a7,-3(a5)
    6efc:	0019829b          	addiw	t0,s3,1
    6f00:	0ff2f313          	zext.b	t1,t0
    6f04:	fe678e23          	sb	t1,-4(a5)
    6f08:	e8667ce3          	bgeu	a2,t1,6da0 <fcvtbuf+0x3e0>
    6f0c:	ffb7c383          	lbu	t2,-5(a5)
    6f10:	ff178e23          	sb	a7,-4(a5)
    6f14:	0013881b          	addiw	a6,t2,1
    6f18:	0ff87e13          	zext.b	t3,a6
    6f1c:	ffc78da3          	sb	t3,-5(a5)
    6f20:	e9c670e3          	bgeu	a2,t3,6da0 <fcvtbuf+0x3e0>
    6f24:	ffa7ce83          	lbu	t4,-6(a5)
    6f28:	ff178da3          	sb	a7,-5(a5)
    6f2c:	001e8f1b          	addiw	t5,t4,1
    6f30:	0fff7713          	zext.b	a4,t5
    6f34:	fee78d23          	sb	a4,-6(a5)
    6f38:	e6e674e3          	bgeu	a2,a4,6da0 <fcvtbuf+0x3e0>
    6f3c:	ff97cf83          	lbu	t6,-7(a5)
    6f40:	ff178d23          	sb	a7,-6(a5)
    6f44:	001f8a9b          	addiw	s5,t6,1
    6f48:	0ffafa13          	zext.b	s4,s5
    6f4c:	ff478ca3          	sb	s4,-7(a5)
    6f50:	e54678e3          	bgeu	a2,s4,6da0 <fcvtbuf+0x3e0>
    6f54:	ff87c683          	lbu	a3,-8(a5)
    6f58:	ff178ca3          	sb	a7,-7(a5)
    6f5c:	0016851b          	addiw	a0,a3,1
    6f60:	0ff57993          	zext.b	s3,a0
    6f64:	ff378c23          	sb	s3,-8(a5)
    6f68:	e3367ce3          	bgeu	a2,s3,6da0 <fcvtbuf+0x3e0>
    6f6c:	17e1                	addi	a5,a5,-8
    6f6e:	bf2d                	j	6ea8 <fcvtbuf+0x4e8>
    6f70:	0007c383          	lbu	t2,0(a5)
    6f74:	0905                	addi	s2,s2,1
    6f76:	e076e4e3          	bltu	a3,t2,6d7e <fcvtbuf+0x3be>
    6f7a:	b51d                	j	6da0 <fcvtbuf+0x3e0>
    6f7c:	a2a915d3          	flt.d	a1,fs2,fa0
    6f80:	c5e5                	beqz	a1,7068 <fcvtbuf+0x6a8>
    6f82:	6745                	lui	a4,0x11
    6f84:	ba873707          	fld	fa4,-1112(a4) # 10ba8 <errpat+0x38>
    6f88:	6845                	lui	a6,0x11
    6f8a:	bb883607          	fld	fa2,-1096(a6) # 10bb8 <errpat+0x48>
    6f8e:	12e57053          	fmul.d	ft0,fa0,fa4
    6f92:	4a81                	li	s5,0
    6f94:	22c606d3          	fmv.d	fa3,fa2
    6f98:	a2c018d3          	flt.d	a7,ft0,fa2
    6f9c:	0c088d63          	beqz	a7,7076 <fcvtbuf+0x6b6>
    6fa0:	22000453          	fmv.d	fs0,ft0
    6fa4:	3afd                	addiw	s5,s5,-1
    6fa6:	12e07053          	fmul.d	ft0,ft0,fa4
    6faa:	a2d019d3          	flt.d	s3,ft0,fa3
    6fae:	08098163          	beqz	s3,7030 <fcvtbuf+0x670>
    6fb2:	22000453          	fmv.d	fs0,ft0
    6fb6:	3afd                	addiw	s5,s5,-1
    6fb8:	12e07053          	fmul.d	ft0,ft0,fa4
    6fbc:	a2d01a53          	flt.d	s4,ft0,fa3
    6fc0:	060a0863          	beqz	s4,7030 <fcvtbuf+0x670>
    6fc4:	22000453          	fmv.d	fs0,ft0
    6fc8:	3afd                	addiw	s5,s5,-1
    6fca:	12e07053          	fmul.d	ft0,ft0,fa4
    6fce:	a2d01e53          	flt.d	t3,ft0,fa3
    6fd2:	040e0f63          	beqz	t3,7030 <fcvtbuf+0x670>
    6fd6:	22000453          	fmv.d	fs0,ft0
    6fda:	3afd                	addiw	s5,s5,-1
    6fdc:	12e07053          	fmul.d	ft0,ft0,fa4
    6fe0:	a2d01ed3          	flt.d	t4,ft0,fa3
    6fe4:	040e8663          	beqz	t4,7030 <fcvtbuf+0x670>
    6fe8:	22000453          	fmv.d	fs0,ft0
    6fec:	3afd                	addiw	s5,s5,-1
    6fee:	12e07053          	fmul.d	ft0,ft0,fa4
    6ff2:	a2d01f53          	flt.d	t5,ft0,fa3
    6ff6:	020f0d63          	beqz	t5,7030 <fcvtbuf+0x670>
    6ffa:	22000453          	fmv.d	fs0,ft0
    6ffe:	3afd                	addiw	s5,s5,-1
    7000:	12e07053          	fmul.d	ft0,ft0,fa4
    7004:	a2d01fd3          	flt.d	t6,ft0,fa3
    7008:	020f8463          	beqz	t6,7030 <fcvtbuf+0x670>
    700c:	22000453          	fmv.d	fs0,ft0
    7010:	3afd                	addiw	s5,s5,-1
    7012:	12e07053          	fmul.d	ft0,ft0,fa4
    7016:	a2d017d3          	flt.d	a5,ft0,fa3
    701a:	cb99                	beqz	a5,7030 <fcvtbuf+0x670>
    701c:	22000453          	fmv.d	fs0,ft0
    7020:	3afd                	addiw	s5,s5,-1
    7022:	12e07053          	fmul.d	ft0,ft0,fa4
    7026:	a2d016d3          	flt.d	a3,ft0,fa3
    702a:	fabd                	bnez	a3,6fa0 <fcvtbuf+0x5e0>
    702c:	00000013          	nop
    7030:	a402                	fsd	ft0,8(sp)
    7032:	8656                	mv	a2,s5
    7034:	9932                	add	s2,s2,a2
    7036:	9922                	add	s2,s2,s0
    7038:	0154a023          	sw	s5,0(s1)
    703c:	00896e63          	bltu	s2,s0,7058 <fcvtbuf+0x698>
    7040:	8a22                	mv	s4,s0
    7042:	05040993          	addi	s3,s0,80
    7046:	b6c9                	j	6c08 <fcvtbuf+0x248>
    7048:	4305                	li	t1,1
    704a:	22a51553          	fneg.d	fa0,fa0
    704e:	00662023          	sw	t1,0(a2)
    7052:	ba45                	j	6a02 <fcvtbuf+0x42>
    7054:	29c2                	fld	fs3,16(sp)
    7056:	7b42                	ld	s6,48(sp)
    7058:	00040023          	sb	zero,0(s0)
    705c:	b3a1                	j	6da4 <fcvtbuf+0x3e4>
    705e:	0001                	nop
    7060:	040407a3          	sb	zero,79(s0)
    7064:	b381                	j	6da4 <fcvtbuf+0x3e4>
    7066:	0001                	nop
    7068:	4601                	li	a2,0
    706a:	4a81                	li	s5,0
    706c:	b7e1                	j	7034 <fcvtbuf+0x674>
    706e:	29c2                	fld	fs3,16(sp)
    7070:	7b42                	ld	s6,48(sp)
    7072:	8656                	mv	a2,s5
    7074:	b7c1                	j	7034 <fcvtbuf+0x674>
    7076:	a402                	fsd	ft0,8(sp)
    7078:	4601                	li	a2,0
    707a:	bf6d                	j	7034 <fcvtbuf+0x674>
	...

0000000000007090 <fputc>:
    7090:	020007b7          	lui	a5,0x2000
    7094:	fea7a823          	sw	a0,-16(a5) # 1fffff0 <__kernel_stack+0x1f11ff0>
    7098:	8082                	ret
    709a:	00000013          	nop
    709e:	0001                	nop

00000000000070a0 <os_critical_enter>:
    70a0:	8082                	ret
    70a2:	0001                	nop
    70a4:	00000013          	nop
    70a8:	00000013          	nop
    70ac:	00000013          	nop

00000000000070b0 <os_critical_exit>:
    70b0:	8082                	ret
	...

00000000000070c0 <ck_intc_init>:
    70c0:	100007b7          	lui	a5,0x10000
    70c4:	03f00713          	li	a4,63
    70c8:	0007a023          	sw	zero,0(a5) # 10000000 <__kernel_stack+0xff12000>
    70cc:	100102b7          	lui	t0,0x10010
    70d0:	04e2a023          	sw	a4,64(t0) # 10010040 <__kernel_stack+0xff22040>
    70d4:	8082                	ret
	...

00000000000070f0 <_out_buffer>:
    70f0:	00d67463          	bgeu	a2,a3,70f8 <_out_buffer+0x8>
    70f4:	00c5d50b          	th.srb	a0,a1,a2,0
    70f8:	8082                	ret
    70fa:	00000013          	nop
    70fe:	0001                	nop

0000000000007100 <_out_null>:
    7100:	8082                	ret
    7102:	0001                	nop
    7104:	00000013          	nop
    7108:	00000013          	nop
    710c:	00000013          	nop

0000000000007110 <_out_fct>:
    7110:	c501                	beqz	a0,7118 <_out_fct+0x8>
    7112:	619c                	ld	a5,0(a1)
    7114:	658c                	ld	a1,8(a1)
    7116:	8782                	jr	a5
    7118:	8082                	ret
    711a:	00000013          	nop
    711e:	0001                	nop

0000000000007120 <_out_char>:
    7120:	e111                	bnez	a0,7124 <_out_char+0x4>
    7122:	8082                	ret
    7124:	55fd                	li	a1,-1
    7126:	f6bff06f          	j	7090 <fputc>
    712a:	00000013          	nop
    712e:	0001                	nop

0000000000007130 <_ftoa>:
    7130:	7135                	addi	sp,sp,-160
    7132:	f4d6                	sd	s5,104(sp)
    7134:	f8d2                	sd	s4,112(sp)
    7136:	8abe                	mv	s5,a5
    7138:	a2a527d3          	feq.d	a5,fa0,fa0
    713c:	fcce                	sd	s3,120(sp)
    713e:	e14a                	sd	s2,128(sp)
    7140:	e526                	sd	s1,136(sp)
    7142:	e922                	sd	s0,144(sp)
    7144:	e4e6                	sd	s9,72(sp)
    7146:	e8e2                	sd	s8,80(sp)
    7148:	ecde                	sd	s7,88(sp)
    714a:	f0da                	sd	s6,96(sp)
    714c:	ed06                	sd	ra,152(sp)
    714e:	842a                	mv	s0,a0
    7150:	84ae                	mv	s1,a1
    7152:	89b2                	mv	s3,a2
    7154:	8936                	mv	s2,a3
    7156:	8a42                	mv	s4,a6
    7158:	4e078c63          	beqz	a5,7650 <_ftoa+0x520>
    715c:	62c5                	lui	t0,0x11
    715e:	bc02b787          	fld	fa5,-1088(t0) # 10bc0 <errpat+0x50>
    7162:	a2f51353          	flt.d	t1,fa0,fa5
    7166:	520315e3          	bnez	t1,7e90 <_ftoa+0xd60>
    716a:	63c5                	lui	t2,0x11
    716c:	bc83b007          	fld	ft0,-1080(t2) # 10bc8 <errpat+0x58>
    7170:	a2a01553          	flt.d	a0,ft0,fa0
    7174:	1a051a63          	bnez	a0,7328 <_ftoa+0x1f8>
    7178:	65c5                	lui	a1,0x11
    717a:	bd05b087          	fld	ft1,-1072(a1) # 10bd0 <errpat+0x60>
    717e:	e0ea                	sd	s10,64(sp)
    7180:	a2a09653          	flt.d	a2,ft1,fa0
    7184:	c219                	beqz	a2,718a <_ftoa+0x5a>
    7186:	2220106f          	j	83a8 <_ftoa+0x1278>
    718a:	66c5                	lui	a3,0x11
    718c:	bd86b107          	fld	ft2,-1064(a3) # 10bd8 <errpat+0x68>
    7190:	a2251853          	flt.d	a6,fa0,ft2
    7194:	00080463          	beqz	a6,719c <_ftoa+0x6c>
    7198:	0e50106f          	j	8a7c <_ftoa+0x194c>
    719c:	f20001d3          	fmv.d.x	ft3,zero
    71a0:	a23518d3          	flt.d	a7,fa0,ft3
    71a4:	4801                	li	a6,0
    71a6:	4c089fe3          	bnez	a7,7e84 <_ftoa+0xd54>
    71aa:	400a7b13          	andi	s6,s4,1024
    71ae:	4b99                	li	s7,6
    71b0:	416b970b          	th.mveqz	a4,s7,s6
    71b4:	4e81                	li	t4,0
    71b6:	fe070c9b          	addiw	s9,a4,-32
    71ba:	4f81                	li	t6,0
    71bc:	01010c13          	addi	s8,sp,16
    71c0:	4d25                	li	s10,9
    71c2:	03000e13          	li	t3,48
    71c6:	060e8063          	beqz	t4,7226 <_ftoa+0xf6>
    71ca:	017e8863          	beq	t4,s7,71da <_ftoa+0xaa>
    71ce:	0ced7763          	bgeu	s10,a4,729c <_ftoa+0x16c>
    71d2:	01cc0023          	sb	t3,0(s8)
    71d6:	377d                	addiw	a4,a4,-1
    71d8:	4f85                	li	t6,1
    71da:	0ced7163          	bgeu	s10,a4,729c <_ftoa+0x16c>
    71de:	01fc5e0b          	th.srb	t3,s8,t6,0
    71e2:	377d                	addiw	a4,a4,-1
    71e4:	0f85                	addi	t6,t6,1
    71e6:	0aed7b63          	bgeu	s10,a4,729c <_ftoa+0x16c>
    71ea:	01fc5e0b          	th.srb	t3,s8,t6,0
    71ee:	377d                	addiw	a4,a4,-1
    71f0:	0f85                	addi	t6,t6,1
    71f2:	0aed7563          	bgeu	s10,a4,729c <_ftoa+0x16c>
    71f6:	01fc5e0b          	th.srb	t3,s8,t6,0
    71fa:	377d                	addiw	a4,a4,-1
    71fc:	0f85                	addi	t6,t6,1
    71fe:	08ed7f63          	bgeu	s10,a4,729c <_ftoa+0x16c>
    7202:	01fc5e0b          	th.srb	t3,s8,t6,0
    7206:	377d                	addiw	a4,a4,-1
    7208:	0f85                	addi	t6,t6,1
    720a:	08ed7963          	bgeu	s10,a4,729c <_ftoa+0x16c>
    720e:	01fc5e0b          	th.srb	t3,s8,t6,0
    7212:	377d                	addiw	a4,a4,-1
    7214:	0f85                	addi	t6,t6,1
    7216:	08ed7363          	bgeu	s10,a4,729c <_ftoa+0x16c>
    721a:	01fc5e0b          	th.srb	t3,s8,t6,0
    721e:	377d                	addiw	a4,a4,-1
    7220:	0f85                	addi	t6,t6,1
    7222:	06ec8b63          	beq	s9,a4,7298 <_ftoa+0x168>
    7226:	06ed7b63          	bgeu	s10,a4,729c <_ftoa+0x16c>
    722a:	01fc5e0b          	th.srb	t3,s8,t6,0
    722e:	377d                	addiw	a4,a4,-1
    7230:	0f85                	addi	t6,t6,1
    7232:	8f7e                	mv	t5,t6
    7234:	06ed7463          	bgeu	s10,a4,729c <_ftoa+0x16c>
    7238:	01fc5e0b          	th.srb	t3,s8,t6,0
    723c:	377d                	addiw	a4,a4,-1
    723e:	0f85                	addi	t6,t6,1
    7240:	04ed7e63          	bgeu	s10,a4,729c <_ftoa+0x16c>
    7244:	01fc5e0b          	th.srb	t3,s8,t6,0
    7248:	377d                	addiw	a4,a4,-1
    724a:	002f0f93          	addi	t6,t5,2
    724e:	04ed7763          	bgeu	s10,a4,729c <_ftoa+0x16c>
    7252:	01fc5e0b          	th.srb	t3,s8,t6,0
    7256:	377d                	addiw	a4,a4,-1
    7258:	003f0f93          	addi	t6,t5,3
    725c:	04ed7063          	bgeu	s10,a4,729c <_ftoa+0x16c>
    7260:	01fc5e0b          	th.srb	t3,s8,t6,0
    7264:	377d                	addiw	a4,a4,-1
    7266:	004f0f93          	addi	t6,t5,4
    726a:	02ed7963          	bgeu	s10,a4,729c <_ftoa+0x16c>
    726e:	01fc5e0b          	th.srb	t3,s8,t6,0
    7272:	377d                	addiw	a4,a4,-1
    7274:	005f0f93          	addi	t6,t5,5
    7278:	02ed7263          	bgeu	s10,a4,729c <_ftoa+0x16c>
    727c:	01fc5e0b          	th.srb	t3,s8,t6,0
    7280:	377d                	addiw	a4,a4,-1
    7282:	006f0f93          	addi	t6,t5,6
    7286:	00ed7b63          	bgeu	s10,a4,729c <_ftoa+0x16c>
    728a:	01fc5e0b          	th.srb	t3,s8,t6,0
    728e:	377d                	addiw	a4,a4,-1
    7290:	007f0f93          	addi	t6,t5,7
    7294:	f8ec99e3          	bne	s9,a4,7226 <_ftoa+0xf6>
    7298:	02000f93          	li	t6,32
    729c:	c20517d3          	fcvt.w.d	a5,fa0,rtz
    72a0:	62c5                	lui	t0,0x11
    72a2:	d2078253          	fcvt.d.w	ft4,a5
    72a6:	de828313          	addi	t1,t0,-536 # 10de8 <pow10.0>
    72aa:	76e3668b          	th.flurd	fa3,t1,a4,3
    72ae:	0a4572d3          	fsub.d	ft5,fa0,ft4
    72b2:	63c5                	lui	t2,0x11
    72b4:	c083b587          	fld	fa1,-1016(t2) # 10c08 <errpat+0x98>
    72b8:	12d2f353          	fmul.d	ft6,ft5,fa3
    72bc:	0007859b          	sext.w	a1,a5
    72c0:	c23316d3          	fcvt.lu.d	a3,ft6,rtz
    72c4:	d236f753          	fcvt.d.lu	fa4,a3
    72c8:	0ae373d3          	fsub.d	ft7,ft6,fa4
    72cc:	a2759553          	flt.d	a0,fa1,ft7
    72d0:	62050663          	beqz	a0,78fc <_ftoa+0x7cc>
    72d4:	0685                	addi	a3,a3,1
    72d6:	d236f653          	fcvt.d.lu	fa2,a3
    72da:	a2c68b53          	fle.d	s6,fa3,fa2
    72de:	000b0563          	beqz	s6,72e8 <_ftoa+0x1b8>
    72e2:	0017859b          	addiw	a1,a5,1
    72e6:	4681                	li	a3,0
    72e8:	62070463          	beqz	a4,7910 <_ftoa+0x7e0>
    72ec:	fe070b9b          	addiw	s7,a4,-32
    72f0:	01fc0633          	add	a2,s8,t6
    72f4:	01fb8d3b          	addw	s10,s7,t6
    72f8:	4ca9                	li	s9,10
    72fa:	4e25                	li	t3,9
    72fc:	00000013          	nop
    7300:	00ed1463          	bne	s10,a4,7308 <_ftoa+0x1d8>
    7304:	09c0106f          	j	83a0 <_ftoa+0x1270>
    7308:	0396ff33          	remu	t5,a3,s9
    730c:	82b2                	mv	t0,a2
    730e:	377d                	addiw	a4,a4,-1
    7310:	8eba                	mv	t4,a4
    7312:	030f0f9b          	addiw	t6,t5,48
    7316:	1812df8b          	th.sbia	t6,(t0),1,0
    731a:	0396d7b3          	divu	a5,a3,s9
    731e:	78de77e3          	bgeu	t3,a3,82ac <_ftoa+0x117c>
    7322:	8616                	mv	a2,t0
    7324:	86be                	mv	a3,a5
    7326:	bfe9                	j	7300 <_ftoa+0x1d0>
    7328:	00487b13          	andi	s6,a6,4
    732c:	340b16e3          	bnez	s6,7e78 <_ftoa+0xd48>
    7330:	68c5                	lui	a7,0x11
    7332:	af088b93          	addi	s7,a7,-1296 # 10af0 <__errno+0x5a4>
    7336:	4c0d                	li	s8,3
    7338:	003a7393          	andi	t2,s4,3
    733c:	8b4e                	mv	s6,s3
    733e:	14039d63          	bnez	t2,7498 <_ftoa+0x368>
    7342:	7c0abc8b          	th.extu	s9,s5,31,0
    7346:	159c7963          	bgeu	s8,s9,7498 <_ftoa+0x368>
    734a:	fc6e                	sd	s11,56(sp)
    734c:	e0ea                	sd	s10,64(sp)
    734e:	413c0d33          	sub	s10,s8,s3
    7352:	fffd4713          	not	a4,s10
    7356:	01970e33          	add	t3,a4,s9
    735a:	413e0f33          	sub	t5,t3,s3
    735e:	86ca                	mv	a3,s2
    7360:	864e                	mv	a2,s3
    7362:	85a6                	mv	a1,s1
    7364:	02000513          	li	a0,32
    7368:	00198b13          	addi	s6,s3,1
    736c:	007f7d93          	andi	s11,t5,7
    7370:	9402                	jalr	s0
    7372:	016d0333          	add	t1,s10,s6
    7376:	11937b63          	bgeu	t1,s9,748c <_ftoa+0x35c>
    737a:	080d8963          	beqz	s11,740c <_ftoa+0x2dc>
    737e:	4805                	li	a6,1
    7380:	070d8b63          	beq	s11,a6,73f6 <_ftoa+0x2c6>
    7384:	4509                	li	a0,2
    7386:	06ad8163          	beq	s11,a0,73e8 <_ftoa+0x2b8>
    738a:	428d                	li	t0,3
    738c:	045d8763          	beq	s11,t0,73da <_ftoa+0x2aa>
    7390:	4791                	li	a5,4
    7392:	02fd8d63          	beq	s11,a5,73cc <_ftoa+0x29c>
    7396:	4595                	li	a1,5
    7398:	02bd8363          	beq	s11,a1,73be <_ftoa+0x28e>
    739c:	4e99                	li	t4,6
    739e:	01dd8963          	beq	s11,t4,73b0 <_ftoa+0x280>
    73a2:	865a                	mv	a2,s6
    73a4:	86ca                	mv	a3,s2
    73a6:	85a6                	mv	a1,s1
    73a8:	02000513          	li	a0,32
    73ac:	0b05                	addi	s6,s6,1
    73ae:	9402                	jalr	s0
    73b0:	865a                	mv	a2,s6
    73b2:	86ca                	mv	a3,s2
    73b4:	85a6                	mv	a1,s1
    73b6:	02000513          	li	a0,32
    73ba:	0b05                	addi	s6,s6,1
    73bc:	9402                	jalr	s0
    73be:	865a                	mv	a2,s6
    73c0:	86ca                	mv	a3,s2
    73c2:	85a6                	mv	a1,s1
    73c4:	02000513          	li	a0,32
    73c8:	0b05                	addi	s6,s6,1
    73ca:	9402                	jalr	s0
    73cc:	865a                	mv	a2,s6
    73ce:	86ca                	mv	a3,s2
    73d0:	85a6                	mv	a1,s1
    73d2:	02000513          	li	a0,32
    73d6:	0b05                	addi	s6,s6,1
    73d8:	9402                	jalr	s0
    73da:	865a                	mv	a2,s6
    73dc:	86ca                	mv	a3,s2
    73de:	85a6                	mv	a1,s1
    73e0:	02000513          	li	a0,32
    73e4:	0b05                	addi	s6,s6,1
    73e6:	9402                	jalr	s0
    73e8:	865a                	mv	a2,s6
    73ea:	86ca                	mv	a3,s2
    73ec:	85a6                	mv	a1,s1
    73ee:	02000513          	li	a0,32
    73f2:	0b05                	addi	s6,s6,1
    73f4:	9402                	jalr	s0
    73f6:	865a                	mv	a2,s6
    73f8:	86ca                	mv	a3,s2
    73fa:	85a6                	mv	a1,s1
    73fc:	02000513          	li	a0,32
    7400:	0b05                	addi	s6,s6,1
    7402:	9402                	jalr	s0
    7404:	016d0633          	add	a2,s10,s6
    7408:	09967263          	bgeu	a2,s9,748c <_ftoa+0x35c>
    740c:	865a                	mv	a2,s6
    740e:	86ca                	mv	a3,s2
    7410:	85a6                	mv	a1,s1
    7412:	02000513          	li	a0,32
    7416:	9402                	jalr	s0
    7418:	001b0d93          	addi	s11,s6,1
    741c:	866e                	mv	a2,s11
    741e:	86ca                	mv	a3,s2
    7420:	85a6                	mv	a1,s1
    7422:	02000513          	li	a0,32
    7426:	9402                	jalr	s0
    7428:	002b0613          	addi	a2,s6,2
    742c:	86ca                	mv	a3,s2
    742e:	85a6                	mv	a1,s1
    7430:	02000513          	li	a0,32
    7434:	9402                	jalr	s0
    7436:	003b0d93          	addi	s11,s6,3
    743a:	866e                	mv	a2,s11
    743c:	86ca                	mv	a3,s2
    743e:	85a6                	mv	a1,s1
    7440:	02000513          	li	a0,32
    7444:	9402                	jalr	s0
    7446:	004b0613          	addi	a2,s6,4
    744a:	86ca                	mv	a3,s2
    744c:	85a6                	mv	a1,s1
    744e:	02000513          	li	a0,32
    7452:	9402                	jalr	s0
    7454:	005b0d93          	addi	s11,s6,5
    7458:	866e                	mv	a2,s11
    745a:	86ca                	mv	a3,s2
    745c:	85a6                	mv	a1,s1
    745e:	02000513          	li	a0,32
    7462:	9402                	jalr	s0
    7464:	006b0613          	addi	a2,s6,6
    7468:	86ca                	mv	a3,s2
    746a:	85a6                	mv	a1,s1
    746c:	02000513          	li	a0,32
    7470:	9402                	jalr	s0
    7472:	007b0d93          	addi	s11,s6,7
    7476:	866e                	mv	a2,s11
    7478:	86ca                	mv	a3,s2
    747a:	85a6                	mv	a1,s1
    747c:	02000513          	li	a0,32
    7480:	0b21                	addi	s6,s6,8
    7482:	9402                	jalr	s0
    7484:	016d0633          	add	a2,s10,s6
    7488:	f99662e3          	bltu	a2,s9,740c <_ftoa+0x2dc>
    748c:	7de2                	ld	s11,56(sp)
    748e:	6d06                	ld	s10,64(sp)
    7490:	019986b3          	add	a3,s3,s9
    7494:	41868b33          	sub	s6,a3,s8
    7498:	018b8cb3          	add	s9,s7,s8
    749c:	fffcc503          	lbu	a0,-1(s9)
    74a0:	86ca                	mv	a3,s2
    74a2:	865a                	mv	a2,s6
    74a4:	85a6                	mv	a1,s1
    74a6:	9402                	jalr	s0
    74a8:	ffecc503          	lbu	a0,-2(s9)
    74ac:	86ca                	mv	a3,s2
    74ae:	001b0613          	addi	a2,s6,1
    74b2:	85a6                	mv	a1,s1
    74b4:	9402                	jalr	s0
    74b6:	ffdc0c93          	addi	s9,s8,-3
    74ba:	819bc50b          	th.lrbu	a0,s7,s9,0
    74be:	86ca                	mv	a3,s2
    74c0:	002b0613          	addi	a2,s6,2
    74c4:	85a6                	mv	a1,s1
    74c6:	9402                	jalr	s0
    74c8:	000c8963          	beqz	s9,74da <_ftoa+0x3aa>
    74cc:	000bc503          	lbu	a0,0(s7)
    74d0:	86ca                	mv	a3,s2
    74d2:	003b0613          	addi	a2,s6,3
    74d6:	85a6                	mv	a1,s1
    74d8:	9402                	jalr	s0
    74da:	002a7a13          	andi	s4,s4,2
    74de:	9b62                	add	s6,s6,s8
    74e0:	140a0963          	beqz	s4,7632 <_ftoa+0x502>
    74e4:	413b09b3          	sub	s3,s6,s3
    74e8:	7c0aba8b          	th.extu	s5,s5,31,0
    74ec:	1559f363          	bgeu	s3,s5,7632 <_ftoa+0x502>
    74f0:	fff9c893          	not	a7,s3
    74f4:	01588bb3          	add	s7,a7,s5
    74f8:	865a                	mv	a2,s6
    74fa:	86ca                	mv	a3,s2
    74fc:	85a6                	mv	a1,s1
    74fe:	02000513          	li	a0,32
    7502:	00198c93          	addi	s9,s3,1
    7506:	007bfc13          	andi	s8,s7,7
    750a:	0b05                	addi	s6,s6,1
    750c:	9402                	jalr	s0
    750e:	135cf263          	bgeu	s9,s5,7632 <_ftoa+0x502>
    7512:	080c0e63          	beqz	s8,75ae <_ftoa+0x47e>
    7516:	4f85                	li	t6,1
    7518:	09fc0163          	beq	s8,t6,759a <_ftoa+0x46a>
    751c:	4389                	li	t2,2
    751e:	067c0663          	beq	s8,t2,758a <_ftoa+0x45a>
    7522:	470d                	li	a4,3
    7524:	04ec0b63          	beq	s8,a4,757a <_ftoa+0x44a>
    7528:	4e11                	li	t3,4
    752a:	05cc0063          	beq	s8,t3,756a <_ftoa+0x43a>
    752e:	4f15                	li	t5,5
    7530:	03ec0563          	beq	s8,t5,755a <_ftoa+0x42a>
    7534:	4319                	li	t1,6
    7536:	006c0a63          	beq	s8,t1,754a <_ftoa+0x41a>
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
    75a4:	0c85                	addi	s9,s9,1
    75a6:	0b05                	addi	s6,s6,1
    75a8:	9402                	jalr	s0
    75aa:	095cf463          	bgeu	s9,s5,7632 <_ftoa+0x502>
    75ae:	865a                	mv	a2,s6
    75b0:	86ca                	mv	a3,s2
    75b2:	85a6                	mv	a1,s1
    75b4:	02000513          	li	a0,32
    75b8:	9402                	jalr	s0
    75ba:	001b0a13          	addi	s4,s6,1
    75be:	8652                	mv	a2,s4
    75c0:	86ca                	mv	a3,s2
    75c2:	85a6                	mv	a1,s1
    75c4:	02000513          	li	a0,32
    75c8:	9402                	jalr	s0
    75ca:	002b0993          	addi	s3,s6,2
    75ce:	864e                	mv	a2,s3
    75d0:	86ca                	mv	a3,s2
    75d2:	85a6                	mv	a1,s1
    75d4:	02000513          	li	a0,32
    75d8:	9402                	jalr	s0
    75da:	003b0c13          	addi	s8,s6,3
    75de:	8662                	mv	a2,s8
    75e0:	86ca                	mv	a3,s2
    75e2:	85a6                	mv	a1,s1
    75e4:	02000513          	li	a0,32
    75e8:	9402                	jalr	s0
    75ea:	004b0b93          	addi	s7,s6,4
    75ee:	86ca                	mv	a3,s2
    75f0:	865e                	mv	a2,s7
    75f2:	85a6                	mv	a1,s1
    75f4:	02000513          	li	a0,32
    75f8:	9402                	jalr	s0
    75fa:	005b0a13          	addi	s4,s6,5
    75fe:	86ca                	mv	a3,s2
    7600:	8652                	mv	a2,s4
    7602:	85a6                	mv	a1,s1
    7604:	02000513          	li	a0,32
    7608:	9402                	jalr	s0
    760a:	006b0993          	addi	s3,s6,6
    760e:	86ca                	mv	a3,s2
    7610:	864e                	mv	a2,s3
    7612:	85a6                	mv	a1,s1
    7614:	02000513          	li	a0,32
    7618:	9402                	jalr	s0
    761a:	007b0c13          	addi	s8,s6,7
    761e:	86ca                	mv	a3,s2
    7620:	8662                	mv	a2,s8
    7622:	85a6                	mv	a1,s1
    7624:	02000513          	li	a0,32
    7628:	0ca1                	addi	s9,s9,8
    762a:	0b21                	addi	s6,s6,8
    762c:	9402                	jalr	s0
    762e:	f95ce0e3          	bltu	s9,s5,75ae <_ftoa+0x47e>
    7632:	64aa                	ld	s1,136(sp)
    7634:	644a                	ld	s0,144(sp)
    7636:	60ea                	ld	ra,152(sp)
    7638:	6ca6                	ld	s9,72(sp)
    763a:	6c46                	ld	s8,80(sp)
    763c:	7aa6                	ld	s5,104(sp)
    763e:	7a46                	ld	s4,112(sp)
    7640:	79e6                	ld	s3,120(sp)
    7642:	690a                	ld	s2,128(sp)
    7644:	855a                	mv	a0,s6
    7646:	6be6                	ld	s7,88(sp)
    7648:	7b06                	ld	s6,96(sp)
    764a:	610d                	addi	sp,sp,160
    764c:	8082                	ret
    764e:	0001                	nop
    7650:	00387893          	andi	a7,a6,3
    7654:	8cb2                	mv	s9,a2
    7656:	12089563          	bnez	a7,7780 <_ftoa+0x650>
    765a:	438d                	li	t2,3
    765c:	7c0abf8b          	th.extu	t6,s5,31,0
    7660:	1353f063          	bgeu	t2,s5,7780 <_ftoa+0x650>
    7664:	ffd60713          	addi	a4,a2,-3
    7668:	01f70cb3          	add	s9,a4,t6
    766c:	40cc8e33          	sub	t3,s9,a2
    7670:	007e7f13          	andi	t5,t3,7
    7674:	8b32                	mv	s6,a2
    7676:	080f0463          	beqz	t5,76fe <_ftoa+0x5ce>
    767a:	4305                	li	t1,1
    767c:	066f0863          	beq	t5,t1,76ec <_ftoa+0x5bc>
    7680:	4809                	li	a6,2
    7682:	050f0e63          	beq	t5,a6,76de <_ftoa+0x5ae>
    7686:	047f0563          	beq	t5,t2,76d0 <_ftoa+0x5a0>
    768a:	4511                	li	a0,4
    768c:	02af0b63          	beq	t5,a0,76c2 <_ftoa+0x592>
    7690:	4295                	li	t0,5
    7692:	025f0163          	beq	t5,t0,76b4 <_ftoa+0x584>
    7696:	4799                	li	a5,6
    7698:	00ff0763          	beq	t5,a5,76a6 <_ftoa+0x576>
    769c:	02000513          	li	a0,32
    76a0:	00160b13          	addi	s6,a2,1
    76a4:	9402                	jalr	s0
    76a6:	865a                	mv	a2,s6
    76a8:	86ca                	mv	a3,s2
    76aa:	85a6                	mv	a1,s1
    76ac:	02000513          	li	a0,32
    76b0:	0b05                	addi	s6,s6,1
    76b2:	9402                	jalr	s0
    76b4:	865a                	mv	a2,s6
    76b6:	86ca                	mv	a3,s2
    76b8:	85a6                	mv	a1,s1
    76ba:	02000513          	li	a0,32
    76be:	0b05                	addi	s6,s6,1
    76c0:	9402                	jalr	s0
    76c2:	865a                	mv	a2,s6
    76c4:	86ca                	mv	a3,s2
    76c6:	85a6                	mv	a1,s1
    76c8:	02000513          	li	a0,32
    76cc:	0b05                	addi	s6,s6,1
    76ce:	9402                	jalr	s0
    76d0:	865a                	mv	a2,s6
    76d2:	86ca                	mv	a3,s2
    76d4:	85a6                	mv	a1,s1
    76d6:	02000513          	li	a0,32
    76da:	0b05                	addi	s6,s6,1
    76dc:	9402                	jalr	s0
    76de:	865a                	mv	a2,s6
    76e0:	86ca                	mv	a3,s2
    76e2:	85a6                	mv	a1,s1
    76e4:	02000513          	li	a0,32
    76e8:	0b05                	addi	s6,s6,1
    76ea:	9402                	jalr	s0
    76ec:	865a                	mv	a2,s6
    76ee:	86ca                	mv	a3,s2
    76f0:	0b05                	addi	s6,s6,1
    76f2:	85a6                	mv	a1,s1
    76f4:	02000513          	li	a0,32
    76f8:	9402                	jalr	s0
    76fa:	099b0363          	beq	s6,s9,7780 <_ftoa+0x650>
    76fe:	865a                	mv	a2,s6
    7700:	86ca                	mv	a3,s2
    7702:	85a6                	mv	a1,s1
    7704:	02000513          	li	a0,32
    7708:	9402                	jalr	s0
    770a:	001b0b93          	addi	s7,s6,1
    770e:	865e                	mv	a2,s7
    7710:	86ca                	mv	a3,s2
    7712:	85a6                	mv	a1,s1
    7714:	02000513          	li	a0,32
    7718:	9402                	jalr	s0
    771a:	002b0c13          	addi	s8,s6,2
    771e:	8662                	mv	a2,s8
    7720:	86ca                	mv	a3,s2
    7722:	85a6                	mv	a1,s1
    7724:	02000513          	li	a0,32
    7728:	9402                	jalr	s0
    772a:	003b0b93          	addi	s7,s6,3
    772e:	865e                	mv	a2,s7
    7730:	86ca                	mv	a3,s2
    7732:	85a6                	mv	a1,s1
    7734:	02000513          	li	a0,32
    7738:	9402                	jalr	s0
    773a:	004b0c13          	addi	s8,s6,4
    773e:	8662                	mv	a2,s8
    7740:	86ca                	mv	a3,s2
    7742:	85a6                	mv	a1,s1
    7744:	02000513          	li	a0,32
    7748:	9402                	jalr	s0
    774a:	005b0b93          	addi	s7,s6,5
    774e:	865e                	mv	a2,s7
    7750:	86ca                	mv	a3,s2
    7752:	85a6                	mv	a1,s1
    7754:	02000513          	li	a0,32
    7758:	9402                	jalr	s0
    775a:	006b0c13          	addi	s8,s6,6
    775e:	86ca                	mv	a3,s2
    7760:	8662                	mv	a2,s8
    7762:	85a6                	mv	a1,s1
    7764:	02000513          	li	a0,32
    7768:	9402                	jalr	s0
    776a:	007b0b93          	addi	s7,s6,7
    776e:	86ca                	mv	a3,s2
    7770:	0b21                	addi	s6,s6,8
    7772:	865e                	mv	a2,s7
    7774:	85a6                	mv	a1,s1
    7776:	02000513          	li	a0,32
    777a:	9402                	jalr	s0
    777c:	f99b11e3          	bne	s6,s9,76fe <_ftoa+0x5ce>
    7780:	4b8d                	li	s7,3
    7782:	65c5                	lui	a1,0x11
    7784:	9cde                	add	s9,s9,s7
    7786:	af858c13          	addi	s8,a1,-1288 # 10af8 <__errno+0x5ac>
    778a:	0001                	nop
    778c:	00000013          	nop
    7790:	417c8633          	sub	a2,s9,s7
    7794:	1bfd                	addi	s7,s7,-1
    7796:	817c450b          	th.lrbu	a0,s8,s7,0
    779a:	86ca                	mv	a3,s2
    779c:	85a6                	mv	a1,s1
    779e:	8b66                	mv	s6,s9
    77a0:	9402                	jalr	s0
    77a2:	fe0b97e3          	bnez	s7,7790 <_ftoa+0x660>
    77a6:	002a7e93          	andi	t4,s4,2
    77aa:	e80e84e3          	beqz	t4,7632 <_ftoa+0x502>
    77ae:	7c0aba8b          	th.extu	s5,s5,31,0
    77b2:	413c8633          	sub	a2,s9,s3
    77b6:	e7567ee3          	bgeu	a2,s5,7632 <_ftoa+0x502>
    77ba:	fffcc693          	not	a3,s9
    77be:	01568a33          	add	s4,a3,s5
    77c2:	013a08b3          	add	a7,s4,s3
    77c6:	86ca                	mv	a3,s2
    77c8:	8666                	mv	a2,s9
    77ca:	85a6                	mv	a1,s1
    77cc:	02000513          	li	a0,32
    77d0:	0078fb93          	andi	s7,a7,7
    77d4:	001c8b13          	addi	s6,s9,1
    77d8:	9402                	jalr	s0
    77da:	413b0fb3          	sub	t6,s6,s3
    77de:	e55ffae3          	bgeu	t6,s5,7632 <_ftoa+0x502>
    77e2:	080b8963          	beqz	s7,7874 <_ftoa+0x744>
    77e6:	4385                	li	t2,1
    77e8:	067b8b63          	beq	s7,t2,785e <_ftoa+0x72e>
    77ec:	4709                	li	a4,2
    77ee:	06eb8163          	beq	s7,a4,7850 <_ftoa+0x720>
    77f2:	4e0d                	li	t3,3
    77f4:	05cb8763          	beq	s7,t3,7842 <_ftoa+0x712>
    77f8:	4f11                	li	t5,4
    77fa:	03eb8d63          	beq	s7,t5,7834 <_ftoa+0x704>
    77fe:	4315                	li	t1,5
    7800:	026b8363          	beq	s7,t1,7826 <_ftoa+0x6f6>
    7804:	4819                	li	a6,6
    7806:	010b8963          	beq	s7,a6,7818 <_ftoa+0x6e8>
    780a:	865a                	mv	a2,s6
    780c:	86ca                	mv	a3,s2
    780e:	85a6                	mv	a1,s1
    7810:	02000513          	li	a0,32
    7814:	0b05                	addi	s6,s6,1
    7816:	9402                	jalr	s0
    7818:	865a                	mv	a2,s6
    781a:	86ca                	mv	a3,s2
    781c:	85a6                	mv	a1,s1
    781e:	02000513          	li	a0,32
    7822:	0b05                	addi	s6,s6,1
    7824:	9402                	jalr	s0
    7826:	865a                	mv	a2,s6
    7828:	86ca                	mv	a3,s2
    782a:	85a6                	mv	a1,s1
    782c:	02000513          	li	a0,32
    7830:	0b05                	addi	s6,s6,1
    7832:	9402                	jalr	s0
    7834:	865a                	mv	a2,s6
    7836:	86ca                	mv	a3,s2
    7838:	85a6                	mv	a1,s1
    783a:	02000513          	li	a0,32
    783e:	0b05                	addi	s6,s6,1
    7840:	9402                	jalr	s0
    7842:	865a                	mv	a2,s6
    7844:	86ca                	mv	a3,s2
    7846:	85a6                	mv	a1,s1
    7848:	02000513          	li	a0,32
    784c:	0b05                	addi	s6,s6,1
    784e:	9402                	jalr	s0
    7850:	865a                	mv	a2,s6
    7852:	86ca                	mv	a3,s2
    7854:	85a6                	mv	a1,s1
    7856:	02000513          	li	a0,32
    785a:	0b05                	addi	s6,s6,1
    785c:	9402                	jalr	s0
    785e:	865a                	mv	a2,s6
    7860:	02000513          	li	a0,32
    7864:	86ca                	mv	a3,s2
    7866:	85a6                	mv	a1,s1
    7868:	0b05                	addi	s6,s6,1
    786a:	9402                	jalr	s0
    786c:	413b0533          	sub	a0,s6,s3
    7870:	dd5571e3          	bgeu	a0,s5,7632 <_ftoa+0x502>
    7874:	865a                	mv	a2,s6
    7876:	86ca                	mv	a3,s2
    7878:	85a6                	mv	a1,s1
    787a:	02000513          	li	a0,32
    787e:	9402                	jalr	s0
    7880:	001b0c93          	addi	s9,s6,1
    7884:	8666                	mv	a2,s9
    7886:	86ca                	mv	a3,s2
    7888:	85a6                	mv	a1,s1
    788a:	02000513          	li	a0,32
    788e:	9402                	jalr	s0
    7890:	002b0c13          	addi	s8,s6,2
    7894:	8662                	mv	a2,s8
    7896:	86ca                	mv	a3,s2
    7898:	85a6                	mv	a1,s1
    789a:	02000513          	li	a0,32
    789e:	9402                	jalr	s0
    78a0:	003b0a13          	addi	s4,s6,3
    78a4:	8652                	mv	a2,s4
    78a6:	86ca                	mv	a3,s2
    78a8:	85a6                	mv	a1,s1
    78aa:	02000513          	li	a0,32
    78ae:	9402                	jalr	s0
    78b0:	004b0b93          	addi	s7,s6,4
    78b4:	86ca                	mv	a3,s2
    78b6:	865e                	mv	a2,s7
    78b8:	85a6                	mv	a1,s1
    78ba:	02000513          	li	a0,32
    78be:	9402                	jalr	s0
    78c0:	005b0c93          	addi	s9,s6,5
    78c4:	86ca                	mv	a3,s2
    78c6:	8666                	mv	a2,s9
    78c8:	85a6                	mv	a1,s1
    78ca:	02000513          	li	a0,32
    78ce:	9402                	jalr	s0
    78d0:	006b0c13          	addi	s8,s6,6
    78d4:	86ca                	mv	a3,s2
    78d6:	8662                	mv	a2,s8
    78d8:	85a6                	mv	a1,s1
    78da:	02000513          	li	a0,32
    78de:	9402                	jalr	s0
    78e0:	007b0a13          	addi	s4,s6,7
    78e4:	02000513          	li	a0,32
    78e8:	86ca                	mv	a3,s2
    78ea:	8652                	mv	a2,s4
    78ec:	85a6                	mv	a1,s1
    78ee:	0b21                	addi	s6,s6,8
    78f0:	9402                	jalr	s0
    78f2:	413b0533          	sub	a0,s6,s3
    78f6:	f7556fe3          	bltu	a0,s5,7874 <_ftoa+0x744>
    78fa:	bb25                	j	7632 <_ftoa+0x502>
    78fc:	a2b39653          	flt.d	a2,ft7,fa1
    7900:	9e0614e3          	bnez	a2,72e8 <_ftoa+0x1b8>
    7904:	c299                	beqz	a3,790a <_ftoa+0x7da>
    7906:	1120106f          	j	8a18 <_ftoa+0x18e8>
    790a:	0685                	addi	a3,a3,1
    790c:	9e0710e3          	bnez	a4,72ec <_ftoa+0x1bc>
    7910:	d2058853          	fcvt.d.w	fa6,a1
    7914:	c083b887          	fld	fa7,-1016(t2)
    7918:	0b057553          	fsub.d	fa0,fa0,fa6
    791c:	0015839b          	addiw	t2,a1,1
    7920:	ffe3fb13          	andi	s6,t2,-2
    7924:	a3151e53          	flt.d	t3,fa0,fa7
    7928:	000b089b          	sext.w	a7,s6
    792c:	41c8958b          	th.mveqz	a1,a7,t3
    7930:	01fc07b3          	add	a5,s8,t6
    7934:	03010f13          	addi	t5,sp,48
    7938:	40ff0633          	sub	a2,t5,a5
    793c:	00767693          	andi	a3,a2,7
    7940:	4ea9                	li	t4,10
    7942:	c6f9                	beqz	a3,7a10 <_ftoa+0x8e0>
    7944:	03d5efbb          	remw	t6,a1,t4
    7948:	873e                	mv	a4,a5
    794a:	03d5c5bb          	divw	a1,a1,t4
    794e:	030f831b          	addiw	t1,t6,48
    7952:	1817530b          	th.sbia	t1,(a4),1,0
    7956:	7e058963          	beqz	a1,8148 <_ftoa+0x1018>
    795a:	4505                	li	a0,1
    795c:	87ba                	mv	a5,a4
    795e:	0aa68963          	beq	a3,a0,7a10 <_ftoa+0x8e0>
    7962:	4b89                	li	s7,2
    7964:	09768a63          	beq	a3,s7,79f8 <_ftoa+0x8c8>
    7968:	4c8d                	li	s9,3
    796a:	07968b63          	beq	a3,s9,79e0 <_ftoa+0x8b0>
    796e:	4d11                	li	s10,4
    7970:	05a68c63          	beq	a3,s10,79c8 <_ftoa+0x898>
    7974:	4295                	li	t0,5
    7976:	02568d63          	beq	a3,t0,79b0 <_ftoa+0x880>
    797a:	4399                	li	t2,6
    797c:	00768e63          	beq	a3,t2,7998 <_ftoa+0x868>
    7980:	03d5eb3b          	remw	s6,a1,t4
    7984:	8e3a                	mv	t3,a4
    7986:	03d5c5bb          	divw	a1,a1,t4
    798a:	030b089b          	addiw	a7,s6,48
    798e:	181e588b          	th.sbia	a7,(t3),1,0
    7992:	7a058b63          	beqz	a1,8148 <_ftoa+0x1018>
    7996:	87f2                	mv	a5,t3
    7998:	03d5ef3b          	remw	t5,a1,t4
    799c:	863e                	mv	a2,a5
    799e:	03d5c5bb          	divw	a1,a1,t4
    79a2:	030f069b          	addiw	a3,t5,48
    79a6:	1816568b          	th.sbia	a3,(a2),1,0
    79aa:	78058f63          	beqz	a1,8148 <_ftoa+0x1018>
    79ae:	87b2                	mv	a5,a2
    79b0:	03d5efbb          	remw	t6,a1,t4
    79b4:	873e                	mv	a4,a5
    79b6:	03d5c5bb          	divw	a1,a1,t4
    79ba:	030f831b          	addiw	t1,t6,48
    79be:	1817530b          	th.sbia	t1,(a4),1,0
    79c2:	78058363          	beqz	a1,8148 <_ftoa+0x1018>
    79c6:	87ba                	mv	a5,a4
    79c8:	03d5e53b          	remw	a0,a1,t4
    79cc:	8cbe                	mv	s9,a5
    79ce:	03d5c5bb          	divw	a1,a1,t4
    79d2:	03050b9b          	addiw	s7,a0,48
    79d6:	181cdb8b          	th.sbia	s7,(s9),1,0
    79da:	76058763          	beqz	a1,8148 <_ftoa+0x1018>
    79de:	87e6                	mv	a5,s9
    79e0:	03d5ed3b          	remw	s10,a1,t4
    79e4:	83be                	mv	t2,a5
    79e6:	03d5c5bb          	divw	a1,a1,t4
    79ea:	030d029b          	addiw	t0,s10,48
    79ee:	1813d28b          	th.sbia	t0,(t2),1,0
    79f2:	74058b63          	beqz	a1,8148 <_ftoa+0x1018>
    79f6:	879e                	mv	a5,t2
    79f8:	03d5eb3b          	remw	s6,a1,t4
    79fc:	8e3e                	mv	t3,a5
    79fe:	03d5c5bb          	divw	a1,a1,t4
    7a02:	030b089b          	addiw	a7,s6,48
    7a06:	181e588b          	th.sbia	a7,(t3),1,0
    7a0a:	72058f63          	beqz	a1,8148 <_ftoa+0x1018>
    7a0e:	87f2                	mv	a5,t3
    7a10:	03010f13          	addi	t5,sp,48
    7a14:	0cff0463          	beq	t5,a5,7adc <_ftoa+0x9ac>
    7a18:	03d5e6bb          	remw	a3,a1,t4
    7a1c:	863e                	mv	a2,a5
    7a1e:	03d5c73b          	divw	a4,a1,t4
    7a22:	0306831b          	addiw	t1,a3,48
    7a26:	1816530b          	th.sbia	t1,(a2),1,0
    7a2a:	70070f63          	beqz	a4,8148 <_ftoa+0x1018>
    7a2e:	03d7653b          	remw	a0,a4,t4
    7a32:	87b2                	mv	a5,a2
    7a34:	03d74cbb          	divw	s9,a4,t4
    7a38:	03050b9b          	addiw	s7,a0,48
    7a3c:	01760023          	sb	s7,0(a2)
    7a40:	700c8463          	beqz	s9,8148 <_ftoa+0x1018>
    7a44:	03dced3b          	remw	s10,s9,t4
    7a48:	03dcc3bb          	divw	t2,s9,t4
    7a4c:	030d029b          	addiw	t0,s10,48
    7a50:	0817d28b          	th.sbib	t0,(a5),1,0
    7a54:	6e038a63          	beqz	t2,8148 <_ftoa+0x1018>
    7a58:	03d3eb3b          	remw	s6,t2,t4
    7a5c:	00260793          	addi	a5,a2,2
    7a60:	03d3ce3b          	divw	t3,t2,t4
    7a64:	030b089b          	addiw	a7,s6,48
    7a68:	01160123          	sb	a7,2(a2)
    7a6c:	6c0e0e63          	beqz	t3,8148 <_ftoa+0x1018>
    7a70:	03de6f3b          	remw	t5,t3,t4
    7a74:	00360793          	addi	a5,a2,3
    7a78:	03de4fbb          	divw	t6,t3,t4
    7a7c:	030f059b          	addiw	a1,t5,48
    7a80:	00b601a3          	sb	a1,3(a2)
    7a84:	6c0f8263          	beqz	t6,8148 <_ftoa+0x1018>
    7a88:	03dfe6bb          	remw	a3,t6,t4
    7a8c:	00460793          	addi	a5,a2,4
    7a90:	03dfc73b          	divw	a4,t6,t4
    7a94:	0306831b          	addiw	t1,a3,48
    7a98:	00660223          	sb	t1,4(a2)
    7a9c:	6a070663          	beqz	a4,8148 <_ftoa+0x1018>
    7aa0:	03d7653b          	remw	a0,a4,t4
    7aa4:	00560793          	addi	a5,a2,5
    7aa8:	03d74cbb          	divw	s9,a4,t4
    7aac:	03050b9b          	addiw	s7,a0,48
    7ab0:	017602a3          	sb	s7,5(a2)
    7ab4:	680c8a63          	beqz	s9,8148 <_ftoa+0x1018>
    7ab8:	03dced3b          	remw	s10,s9,t4
    7abc:	00660793          	addi	a5,a2,6
    7ac0:	03dcc5bb          	divw	a1,s9,t4
    7ac4:	030d029b          	addiw	t0,s10,48
    7ac8:	00560323          	sb	t0,6(a2)
    7acc:	66058e63          	beqz	a1,8148 <_ftoa+0x1018>
    7ad0:	00760793          	addi	a5,a2,7
    7ad4:	03010f13          	addi	t5,sp,48
    7ad8:	f4ff10e3          	bne	t5,a5,7a18 <_ftoa+0x8e8>
    7adc:	003a7593          	andi	a1,s4,3
    7ae0:	4785                	li	a5,1
    7ae2:	78f599e3          	bne	a1,a5,8a74 <_ftoa+0x1944>
    7ae6:	6e0a87e3          	beqz	s5,89d4 <_ftoa+0x18a4>
    7aea:	78080fe3          	beqz	a6,8a88 <_ftoa+0x1958>
    7aee:	3afd                	addiw	s5,s5,-1
    7af0:	02000b13          	li	s6,32
    7af4:	7c0abf8b          	th.extu	t6,s5,31,0
    7af8:	115b7363          	bgeu	s6,s5,7bfe <_ftoa+0xace>
    7afc:	02000293          	li	t0,32
    7b00:	416287b3          	sub	a5,t0,s6
    7b04:	0077fe93          	andi	t4,a5,7
    7b08:	016c0733          	add	a4,s8,s6
    7b0c:	03000593          	li	a1,48
    7b10:	060e8763          	beqz	t4,7b7e <_ftoa+0xa4e>
    7b14:	0b05                	addi	s6,s6,1
    7b16:	1817558b          	th.sbia	a1,(a4),1,0
    7b1a:	0dfb0763          	beq	s6,t6,7be8 <_ftoa+0xab8>
    7b1e:	4605                	li	a2,1
    7b20:	04ce8f63          	beq	t4,a2,7b7e <_ftoa+0xa4e>
    7b24:	4389                	li	t2,2
    7b26:	047e8763          	beq	t4,t2,7b74 <_ftoa+0xa44>
    7b2a:	488d                	li	a7,3
    7b2c:	031e8f63          	beq	t4,a7,7b6a <_ftoa+0xa3a>
    7b30:	4e11                	li	t3,4
    7b32:	03ce8763          	beq	t4,t3,7b60 <_ftoa+0xa30>
    7b36:	4f15                	li	t5,5
    7b38:	01ee8f63          	beq	t4,t5,7b56 <_ftoa+0xa26>
    7b3c:	4319                	li	t1,6
    7b3e:	006e8763          	beq	t4,t1,7b4c <_ftoa+0xa1c>
    7b42:	0b05                	addi	s6,s6,1
    7b44:	1817558b          	th.sbia	a1,(a4),1,0
    7b48:	0bfb0063          	beq	s6,t6,7be8 <_ftoa+0xab8>
    7b4c:	0b05                	addi	s6,s6,1
    7b4e:	1817558b          	th.sbia	a1,(a4),1,0
    7b52:	09fb0b63          	beq	s6,t6,7be8 <_ftoa+0xab8>
    7b56:	0b05                	addi	s6,s6,1
    7b58:	1817558b          	th.sbia	a1,(a4),1,0
    7b5c:	09fb0663          	beq	s6,t6,7be8 <_ftoa+0xab8>
    7b60:	0b05                	addi	s6,s6,1
    7b62:	1817558b          	th.sbia	a1,(a4),1,0
    7b66:	09fb0163          	beq	s6,t6,7be8 <_ftoa+0xab8>
    7b6a:	0b05                	addi	s6,s6,1
    7b6c:	1817558b          	th.sbia	a1,(a4),1,0
    7b70:	07fb0c63          	beq	s6,t6,7be8 <_ftoa+0xab8>
    7b74:	0b05                	addi	s6,s6,1
    7b76:	1817558b          	th.sbia	a1,(a4),1,0
    7b7a:	07fb0763          	beq	s6,t6,7be8 <_ftoa+0xab8>
    7b7e:	6e5b05e3          	beq	s6,t0,8a68 <_ftoa+0x1938>
    7b82:	0b05                	addi	s6,s6,1
    7b84:	00b70023          	sb	a1,0(a4)
    7b88:	86da                	mv	a3,s6
    7b8a:	05fb0f63          	beq	s6,t6,7be8 <_ftoa+0xab8>
    7b8e:	0b05                	addi	s6,s6,1
    7b90:	00b700a3          	sb	a1,1(a4)
    7b94:	05fb0a63          	beq	s6,t6,7be8 <_ftoa+0xab8>
    7b98:	00268b13          	addi	s6,a3,2
    7b9c:	00b70123          	sb	a1,2(a4)
    7ba0:	05fb0463          	beq	s6,t6,7be8 <_ftoa+0xab8>
    7ba4:	00368b13          	addi	s6,a3,3
    7ba8:	00b701a3          	sb	a1,3(a4)
    7bac:	03fb0e63          	beq	s6,t6,7be8 <_ftoa+0xab8>
    7bb0:	00468b13          	addi	s6,a3,4
    7bb4:	00b70223          	sb	a1,4(a4)
    7bb8:	03fb0863          	beq	s6,t6,7be8 <_ftoa+0xab8>
    7bbc:	00568b13          	addi	s6,a3,5
    7bc0:	00b702a3          	sb	a1,5(a4)
    7bc4:	03fb0263          	beq	s6,t6,7be8 <_ftoa+0xab8>
    7bc8:	00668b13          	addi	s6,a3,6
    7bcc:	00b70323          	sb	a1,6(a4)
    7bd0:	01fb0c63          	beq	s6,t6,7be8 <_ftoa+0xab8>
    7bd4:	00b703a3          	sb	a1,7(a4)
    7bd8:	00768b13          	addi	s6,a3,7
    7bdc:	0721                	addi	a4,a4,8
    7bde:	fbfb10e3          	bne	s6,t6,7b7e <_ftoa+0xa4e>
    7be2:	0001                	nop
    7be4:	00000013          	nop
    7be8:	685b00e3          	beq	s6,t0,8a68 <_ftoa+0x1938>
    7bec:	6e080fe3          	beqz	a6,8aea <_ftoa+0x19ba>
    7bf0:	002f8d33          	add	s10,t6,sp
    7bf4:	02d00293          	li	t0,45
    7bf8:	0b05                	addi	s6,s6,1
    7bfa:	005d0823          	sb	t0,16(s10)
    7bfe:	8d4e                	mv	s10,s3
    7c00:	9d5a                	add	s10,s10,s6
    7c02:	016c0bb3          	add	s7,s8,s6
    7c06:	007b7b13          	andi	s6,s6,7
    7c0a:	01ac0cb3          	add	s9,s8,s10
    7c0e:	080b0163          	beqz	s6,7c90 <_ftoa+0xb60>
    7c12:	4585                	li	a1,1
    7c14:	06bb0463          	beq	s6,a1,7c7c <_ftoa+0xb4c>
    7c18:	4789                	li	a5,2
    7c1a:	04fb0a63          	beq	s6,a5,7c6e <_ftoa+0xb3e>
    7c1e:	4e8d                	li	t4,3
    7c20:	05db0063          	beq	s6,t4,7c60 <_ftoa+0xb30>
    7c24:	4611                	li	a2,4
    7c26:	02cb0663          	beq	s6,a2,7c52 <_ftoa+0xb22>
    7c2a:	4395                	li	t2,5
    7c2c:	007b0c63          	beq	s6,t2,7c44 <_ftoa+0xb14>
    7c30:	4899                	li	a7,6
    7c32:	5f1b1de3          	bne	s6,a7,8a2c <_ftoa+0x18fc>
    7c36:	417c8633          	sub	a2,s9,s7
    7c3a:	89fbc50b          	th.lbuib	a0,(s7),-1,0
    7c3e:	86ca                	mv	a3,s2
    7c40:	85a6                	mv	a1,s1
    7c42:	9402                	jalr	s0
    7c44:	417c8633          	sub	a2,s9,s7
    7c48:	89fbc50b          	th.lbuib	a0,(s7),-1,0
    7c4c:	86ca                	mv	a3,s2
    7c4e:	85a6                	mv	a1,s1
    7c50:	9402                	jalr	s0
    7c52:	417c8633          	sub	a2,s9,s7
    7c56:	89fbc50b          	th.lbuib	a0,(s7),-1,0
    7c5a:	86ca                	mv	a3,s2
    7c5c:	85a6                	mv	a1,s1
    7c5e:	9402                	jalr	s0
    7c60:	417c8633          	sub	a2,s9,s7
    7c64:	89fbc50b          	th.lbuib	a0,(s7),-1,0
    7c68:	86ca                	mv	a3,s2
    7c6a:	85a6                	mv	a1,s1
    7c6c:	9402                	jalr	s0
    7c6e:	417c8633          	sub	a2,s9,s7
    7c72:	89fbc50b          	th.lbuib	a0,(s7),-1,0
    7c76:	86ca                	mv	a3,s2
    7c78:	85a6                	mv	a1,s1
    7c7a:	9402                	jalr	s0
    7c7c:	417c8633          	sub	a2,s9,s7
    7c80:	89fbc50b          	th.lbuib	a0,(s7),-1,0
    7c84:	86ca                	mv	a3,s2
    7c86:	85a6                	mv	a1,s1
    7c88:	8b6a                	mv	s6,s10
    7c8a:	9402                	jalr	s0
    7c8c:	097c0663          	beq	s8,s7,7d18 <_ftoa+0xbe8>
    7c90:	fc6e                	sd	s11,56(sp)
    7c92:	8dde                	mv	s11,s7
    7c94:	89fdc50b          	th.lbuib	a0,(s11),-1,0
    7c98:	417c8633          	sub	a2,s9,s7
    7c9c:	86ca                	mv	a3,s2
    7c9e:	85a6                	mv	a1,s1
    7ca0:	9402                	jalr	s0
    7ca2:	8b5e                	mv	s6,s7
    7ca4:	89eb450b          	th.lbuib	a0,(s6),-2,0
    7ca8:	41bc8633          	sub	a2,s9,s11
    7cac:	86ca                	mv	a3,s2
    7cae:	85a6                	mv	a1,s1
    7cb0:	9402                	jalr	s0
    7cb2:	8dde                	mv	s11,s7
    7cb4:	89ddc50b          	th.lbuib	a0,(s11),-3,0
    7cb8:	416c8633          	sub	a2,s9,s6
    7cbc:	86ca                	mv	a3,s2
    7cbe:	85a6                	mv	a1,s1
    7cc0:	9402                	jalr	s0
    7cc2:	8b5e                	mv	s6,s7
    7cc4:	89cb450b          	th.lbuib	a0,(s6),-4,0
    7cc8:	41bc8633          	sub	a2,s9,s11
    7ccc:	86ca                	mv	a3,s2
    7cce:	85a6                	mv	a1,s1
    7cd0:	9402                	jalr	s0
    7cd2:	8dde                	mv	s11,s7
    7cd4:	89bdc50b          	th.lbuib	a0,(s11),-5,0
    7cd8:	416c8633          	sub	a2,s9,s6
    7cdc:	86ca                	mv	a3,s2
    7cde:	85a6                	mv	a1,s1
    7ce0:	9402                	jalr	s0
    7ce2:	8b5e                	mv	s6,s7
    7ce4:	89ab450b          	th.lbuib	a0,(s6),-6,0
    7ce8:	41bc8633          	sub	a2,s9,s11
    7cec:	86ca                	mv	a3,s2
    7cee:	85a6                	mv	a1,s1
    7cf0:	9402                	jalr	s0
    7cf2:	8dde                	mv	s11,s7
    7cf4:	899dc50b          	th.lbuib	a0,(s11),-7,0
    7cf8:	416c8633          	sub	a2,s9,s6
    7cfc:	86ca                	mv	a3,s2
    7cfe:	85a6                	mv	a1,s1
    7d00:	9402                	jalr	s0
    7d02:	898bc50b          	th.lbuib	a0,(s7),-8,0
    7d06:	86ca                	mv	a3,s2
    7d08:	41bc8633          	sub	a2,s9,s11
    7d0c:	85a6                	mv	a1,s1
    7d0e:	8b6a                	mv	s6,s10
    7d10:	9402                	jalr	s0
    7d12:	f97c10e3          	bne	s8,s7,7c92 <_ftoa+0xb62>
    7d16:	7de2                	ld	s11,56(sp)
    7d18:	002a7a13          	andi	s4,s4,2
    7d1c:	140a0a63          	beqz	s4,7e70 <_ftoa+0xd40>
    7d20:	413d09b3          	sub	s3,s10,s3
    7d24:	7c0aba8b          	th.extu	s5,s5,31,0
    7d28:	1559f463          	bgeu	s3,s5,7e70 <_ftoa+0xd40>
    7d2c:	fff9cc13          	not	s8,s3
    7d30:	015c0e33          	add	t3,s8,s5
    7d34:	866a                	mv	a2,s10
    7d36:	001d0b13          	addi	s6,s10,1
    7d3a:	86ca                	mv	a3,s2
    7d3c:	85a6                	mv	a1,s1
    7d3e:	02000513          	li	a0,32
    7d42:	00198d13          	addi	s10,s3,1
    7d46:	007e7b93          	andi	s7,t3,7
    7d4a:	9402                	jalr	s0
    7d4c:	135d7263          	bgeu	s10,s5,7e70 <_ftoa+0xd40>
    7d50:	080b8e63          	beqz	s7,7dec <_ftoa+0xcbc>
    7d54:	4f05                	li	t5,1
    7d56:	09eb8163          	beq	s7,t5,7dd8 <_ftoa+0xca8>
    7d5a:	4309                	li	t1,2
    7d5c:	066b8663          	beq	s7,t1,7dc8 <_ftoa+0xc98>
    7d60:	468d                	li	a3,3
    7d62:	04db8b63          	beq	s7,a3,7db8 <_ftoa+0xc88>
    7d66:	4811                	li	a6,4
    7d68:	050b8063          	beq	s7,a6,7da8 <_ftoa+0xc78>
    7d6c:	4715                	li	a4,5
    7d6e:	02eb8563          	beq	s7,a4,7d98 <_ftoa+0xc68>
    7d72:	4519                	li	a0,6
    7d74:	00ab8a63          	beq	s7,a0,7d88 <_ftoa+0xc58>
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
    7de2:	0d05                	addi	s10,s10,1
    7de4:	0b05                	addi	s6,s6,1
    7de6:	9402                	jalr	s0
    7de8:	095d7463          	bgeu	s10,s5,7e70 <_ftoa+0xd40>
    7dec:	865a                	mv	a2,s6
    7dee:	86ca                	mv	a3,s2
    7df0:	85a6                	mv	a1,s1
    7df2:	02000513          	li	a0,32
    7df6:	9402                	jalr	s0
    7df8:	001b0c93          	addi	s9,s6,1
    7dfc:	8666                	mv	a2,s9
    7dfe:	86ca                	mv	a3,s2
    7e00:	85a6                	mv	a1,s1
    7e02:	02000513          	li	a0,32
    7e06:	9402                	jalr	s0
    7e08:	002b0993          	addi	s3,s6,2
    7e0c:	864e                	mv	a2,s3
    7e0e:	86ca                	mv	a3,s2
    7e10:	85a6                	mv	a1,s1
    7e12:	02000513          	li	a0,32
    7e16:	9402                	jalr	s0
    7e18:	003b0a13          	addi	s4,s6,3
    7e1c:	86ca                	mv	a3,s2
    7e1e:	8652                	mv	a2,s4
    7e20:	85a6                	mv	a1,s1
    7e22:	02000513          	li	a0,32
    7e26:	9402                	jalr	s0
    7e28:	004b0c13          	addi	s8,s6,4
    7e2c:	86ca                	mv	a3,s2
    7e2e:	8662                	mv	a2,s8
    7e30:	85a6                	mv	a1,s1
    7e32:	02000513          	li	a0,32
    7e36:	9402                	jalr	s0
    7e38:	005b0c93          	addi	s9,s6,5
    7e3c:	86ca                	mv	a3,s2
    7e3e:	8666                	mv	a2,s9
    7e40:	85a6                	mv	a1,s1
    7e42:	02000513          	li	a0,32
    7e46:	9402                	jalr	s0
    7e48:	006b0b93          	addi	s7,s6,6
    7e4c:	86ca                	mv	a3,s2
    7e4e:	865e                	mv	a2,s7
    7e50:	85a6                	mv	a1,s1
    7e52:	02000513          	li	a0,32
    7e56:	9402                	jalr	s0
    7e58:	007b0993          	addi	s3,s6,7
    7e5c:	86ca                	mv	a3,s2
    7e5e:	864e                	mv	a2,s3
    7e60:	85a6                	mv	a1,s1
    7e62:	02000513          	li	a0,32
    7e66:	0d21                	addi	s10,s10,8
    7e68:	0b21                	addi	s6,s6,8
    7e6a:	9402                	jalr	s0
    7e6c:	f95d60e3          	bltu	s10,s5,7dec <_ftoa+0xcbc>
    7e70:	6d06                	ld	s10,64(sp)
    7e72:	fc0ff06f          	j	7632 <_ftoa+0x502>
    7e76:	0001                	nop
    7e78:	6fc5                	lui	t6,0x11
    7e7a:	ae8f8b93          	addi	s7,t6,-1304 # 10ae8 <__errno+0x59c>
    7e7e:	4c11                	li	s8,4
    7e80:	cb8ff06f          	j	7338 <_ftoa+0x208>
    7e84:	0aa1f553          	fsub.d	fa0,ft3,fa0
    7e88:	4805                	li	a6,1
    7e8a:	b20ff06f          	j	71aa <_ftoa+0x7a>
    7e8e:	0001                	nop
    7e90:	00387813          	andi	a6,a6,3
    7e94:	8c32                	mv	s8,a2
    7e96:	12081963          	bnez	a6,7fc8 <_ftoa+0xe98>
    7e9a:	4291                	li	t0,4
    7e9c:	7c0ab50b          	th.extu	a0,s5,31,0
    7ea0:	1352f463          	bgeu	t0,s5,7fc8 <_ftoa+0xe98>
    7ea4:	ffc60793          	addi	a5,a2,-4
    7ea8:	00a78c33          	add	s8,a5,a0
    7eac:	40cc05b3          	sub	a1,s8,a2
    7eb0:	0075fe93          	andi	t4,a1,7
    7eb4:	8b32                	mv	s6,a2
    7eb6:	080e8763          	beqz	t4,7f44 <_ftoa+0xe14>
    7eba:	4605                	li	a2,1
    7ebc:	06ce8b63          	beq	t4,a2,7f32 <_ftoa+0xe02>
    7ec0:	4689                	li	a3,2
    7ec2:	06de8163          	beq	t4,a3,7f24 <_ftoa+0xdf4>
    7ec6:	488d                	li	a7,3
    7ec8:	051e8763          	beq	t4,a7,7f16 <_ftoa+0xde6>
    7ecc:	025e8e63          	beq	t4,t0,7f08 <_ftoa+0xdd8>
    7ed0:	4f95                	li	t6,5
    7ed2:	03fe8463          	beq	t4,t6,7efa <_ftoa+0xdca>
    7ed6:	4399                	li	t2,6
    7ed8:	007e8a63          	beq	t4,t2,7eec <_ftoa+0xdbc>
    7edc:	86ca                	mv	a3,s2
    7ede:	864e                	mv	a2,s3
    7ee0:	85a6                	mv	a1,s1
    7ee2:	02000513          	li	a0,32
    7ee6:	00198b13          	addi	s6,s3,1
    7eea:	9402                	jalr	s0
    7eec:	865a                	mv	a2,s6
    7eee:	86ca                	mv	a3,s2
    7ef0:	85a6                	mv	a1,s1
    7ef2:	02000513          	li	a0,32
    7ef6:	0b05                	addi	s6,s6,1
    7ef8:	9402                	jalr	s0
    7efa:	865a                	mv	a2,s6
    7efc:	86ca                	mv	a3,s2
    7efe:	85a6                	mv	a1,s1
    7f00:	02000513          	li	a0,32
    7f04:	0b05                	addi	s6,s6,1
    7f06:	9402                	jalr	s0
    7f08:	865a                	mv	a2,s6
    7f0a:	86ca                	mv	a3,s2
    7f0c:	85a6                	mv	a1,s1
    7f0e:	02000513          	li	a0,32
    7f12:	0b05                	addi	s6,s6,1
    7f14:	9402                	jalr	s0
    7f16:	865a                	mv	a2,s6
    7f18:	86ca                	mv	a3,s2
    7f1a:	85a6                	mv	a1,s1
    7f1c:	02000513          	li	a0,32
    7f20:	0b05                	addi	s6,s6,1
    7f22:	9402                	jalr	s0
    7f24:	865a                	mv	a2,s6
    7f26:	86ca                	mv	a3,s2
    7f28:	85a6                	mv	a1,s1
    7f2a:	02000513          	li	a0,32
    7f2e:	0b05                	addi	s6,s6,1
    7f30:	9402                	jalr	s0
    7f32:	865a                	mv	a2,s6
    7f34:	86ca                	mv	a3,s2
    7f36:	0b05                	addi	s6,s6,1
    7f38:	85a6                	mv	a1,s1
    7f3a:	02000513          	li	a0,32
    7f3e:	9402                	jalr	s0
    7f40:	098b0463          	beq	s6,s8,7fc8 <_ftoa+0xe98>
    7f44:	865a                	mv	a2,s6
    7f46:	86ca                	mv	a3,s2
    7f48:	85a6                	mv	a1,s1
    7f4a:	02000513          	li	a0,32
    7f4e:	9402                	jalr	s0
    7f50:	001b0b93          	addi	s7,s6,1
    7f54:	865e                	mv	a2,s7
    7f56:	86ca                	mv	a3,s2
    7f58:	85a6                	mv	a1,s1
    7f5a:	02000513          	li	a0,32
    7f5e:	9402                	jalr	s0
    7f60:	002b0c93          	addi	s9,s6,2
    7f64:	8666                	mv	a2,s9
    7f66:	86ca                	mv	a3,s2
    7f68:	85a6                	mv	a1,s1
    7f6a:	02000513          	li	a0,32
    7f6e:	9402                	jalr	s0
    7f70:	003b0b93          	addi	s7,s6,3
    7f74:	865e                	mv	a2,s7
    7f76:	86ca                	mv	a3,s2
    7f78:	85a6                	mv	a1,s1
    7f7a:	02000513          	li	a0,32
    7f7e:	9402                	jalr	s0
    7f80:	004b0c93          	addi	s9,s6,4
    7f84:	8666                	mv	a2,s9
    7f86:	86ca                	mv	a3,s2
    7f88:	85a6                	mv	a1,s1
    7f8a:	02000513          	li	a0,32
    7f8e:	9402                	jalr	s0
    7f90:	005b0b93          	addi	s7,s6,5
    7f94:	865e                	mv	a2,s7
    7f96:	86ca                	mv	a3,s2
    7f98:	85a6                	mv	a1,s1
    7f9a:	02000513          	li	a0,32
    7f9e:	9402                	jalr	s0
    7fa0:	006b0c93          	addi	s9,s6,6
    7fa4:	86ca                	mv	a3,s2
    7fa6:	8666                	mv	a2,s9
    7fa8:	85a6                	mv	a1,s1
    7faa:	02000513          	li	a0,32
    7fae:	9402                	jalr	s0
    7fb0:	007b0b93          	addi	s7,s6,7
    7fb4:	86ca                	mv	a3,s2
    7fb6:	0b21                	addi	s6,s6,8
    7fb8:	865e                	mv	a2,s7
    7fba:	85a6                	mv	a1,s1
    7fbc:	02000513          	li	a0,32
    7fc0:	9402                	jalr	s0
    7fc2:	f98b11e3          	bne	s6,s8,7f44 <_ftoa+0xe14>
    7fc6:	0001                	nop
    7fc8:	6745                	lui	a4,0x11
    7fca:	b0070b13          	addi	s6,a4,-1280 # 10b00 <__errno+0x5b4>
    7fce:	ffcb0c93          	addi	s9,s6,-4
    7fd2:	018b0bb3          	add	s7,s6,s8
    7fd6:	0001                	nop
    7fd8:	003b4503          	lbu	a0,3(s6)
    7fdc:	416b8633          	sub	a2,s7,s6
    7fe0:	86ca                	mv	a3,s2
    7fe2:	85a6                	mv	a1,s1
    7fe4:	1b7d                	addi	s6,s6,-1
    7fe6:	9402                	jalr	s0
    7fe8:	ff6c98e3          	bne	s9,s6,7fd8 <_ftoa+0xea8>
    7fec:	002a7e13          	andi	t3,s4,2
    7ff0:	004c0b13          	addi	s6,s8,4
    7ff4:	e20e0f63          	beqz	t3,7632 <_ftoa+0x502>
    7ff8:	7c0aba8b          	th.extu	s5,s5,31,0
    7ffc:	413b0f33          	sub	t5,s6,s3
    8000:	e35f7963          	bgeu	t5,s5,7632 <_ftoa+0x502>
    8004:	fffb4313          	not	t1,s6
    8008:	01530a33          	add	s4,t1,s5
    800c:	013a0833          	add	a6,s4,s3
    8010:	865a                	mv	a2,s6
    8012:	02000513          	li	a0,32
    8016:	86ca                	mv	a3,s2
    8018:	85a6                	mv	a1,s1
    801a:	00787c93          	andi	s9,a6,7
    801e:	005c0b13          	addi	s6,s8,5
    8022:	9402                	jalr	s0
    8024:	413b0533          	sub	a0,s6,s3
    8028:	e1557563          	bgeu	a0,s5,7632 <_ftoa+0x502>
    802c:	080c8963          	beqz	s9,80be <_ftoa+0xf8e>
    8030:	4285                	li	t0,1
    8032:	065c8b63          	beq	s9,t0,80a8 <_ftoa+0xf78>
    8036:	4789                	li	a5,2
    8038:	06fc8163          	beq	s9,a5,809a <_ftoa+0xf6a>
    803c:	4c0d                	li	s8,3
    803e:	058c8763          	beq	s9,s8,808c <_ftoa+0xf5c>
    8042:	4591                	li	a1,4
    8044:	02bc8d63          	beq	s9,a1,807e <_ftoa+0xf4e>
    8048:	4e95                	li	t4,5
    804a:	03dc8363          	beq	s9,t4,8070 <_ftoa+0xf40>
    804e:	4619                	li	a2,6
    8050:	00cc8963          	beq	s9,a2,8062 <_ftoa+0xf32>
    8054:	865a                	mv	a2,s6
    8056:	86ca                	mv	a3,s2
    8058:	85a6                	mv	a1,s1
    805a:	02000513          	li	a0,32
    805e:	0b05                	addi	s6,s6,1
    8060:	9402                	jalr	s0
    8062:	865a                	mv	a2,s6
    8064:	86ca                	mv	a3,s2
    8066:	85a6                	mv	a1,s1
    8068:	02000513          	li	a0,32
    806c:	0b05                	addi	s6,s6,1
    806e:	9402                	jalr	s0
    8070:	865a                	mv	a2,s6
    8072:	86ca                	mv	a3,s2
    8074:	85a6                	mv	a1,s1
    8076:	02000513          	li	a0,32
    807a:	0b05                	addi	s6,s6,1
    807c:	9402                	jalr	s0
    807e:	865a                	mv	a2,s6
    8080:	86ca                	mv	a3,s2
    8082:	85a6                	mv	a1,s1
    8084:	02000513          	li	a0,32
    8088:	0b05                	addi	s6,s6,1
    808a:	9402                	jalr	s0
    808c:	865a                	mv	a2,s6
    808e:	86ca                	mv	a3,s2
    8090:	85a6                	mv	a1,s1
    8092:	02000513          	li	a0,32
    8096:	0b05                	addi	s6,s6,1
    8098:	9402                	jalr	s0
    809a:	865a                	mv	a2,s6
    809c:	86ca                	mv	a3,s2
    809e:	85a6                	mv	a1,s1
    80a0:	02000513          	li	a0,32
    80a4:	0b05                	addi	s6,s6,1
    80a6:	9402                	jalr	s0
    80a8:	865a                	mv	a2,s6
    80aa:	86ca                	mv	a3,s2
    80ac:	85a6                	mv	a1,s1
    80ae:	02000513          	li	a0,32
    80b2:	0b05                	addi	s6,s6,1
    80b4:	9402                	jalr	s0
    80b6:	413b06b3          	sub	a3,s6,s3
    80ba:	d756fc63          	bgeu	a3,s5,7632 <_ftoa+0x502>
    80be:	865a                	mv	a2,s6
    80c0:	86ca                	mv	a3,s2
    80c2:	85a6                	mv	a1,s1
    80c4:	02000513          	li	a0,32
    80c8:	9402                	jalr	s0
    80ca:	001b0a13          	addi	s4,s6,1
    80ce:	8652                	mv	a2,s4
    80d0:	86ca                	mv	a3,s2
    80d2:	85a6                	mv	a1,s1
    80d4:	02000513          	li	a0,32
    80d8:	9402                	jalr	s0
    80da:	002b0b93          	addi	s7,s6,2
    80de:	865e                	mv	a2,s7
    80e0:	86ca                	mv	a3,s2
    80e2:	85a6                	mv	a1,s1
    80e4:	02000513          	li	a0,32
    80e8:	9402                	jalr	s0
    80ea:	003b0c93          	addi	s9,s6,3
    80ee:	8666                	mv	a2,s9
    80f0:	86ca                	mv	a3,s2
    80f2:	85a6                	mv	a1,s1
    80f4:	02000513          	li	a0,32
    80f8:	9402                	jalr	s0
    80fa:	004b0c13          	addi	s8,s6,4
    80fe:	86ca                	mv	a3,s2
    8100:	8662                	mv	a2,s8
    8102:	85a6                	mv	a1,s1
    8104:	02000513          	li	a0,32
    8108:	9402                	jalr	s0
    810a:	005b0a13          	addi	s4,s6,5
    810e:	86ca                	mv	a3,s2
    8110:	8652                	mv	a2,s4
    8112:	85a6                	mv	a1,s1
    8114:	02000513          	li	a0,32
    8118:	9402                	jalr	s0
    811a:	006b0b93          	addi	s7,s6,6
    811e:	86ca                	mv	a3,s2
    8120:	865e                	mv	a2,s7
    8122:	85a6                	mv	a1,s1
    8124:	02000513          	li	a0,32
    8128:	9402                	jalr	s0
    812a:	007b0c93          	addi	s9,s6,7
    812e:	86ca                	mv	a3,s2
    8130:	8666                	mv	a2,s9
    8132:	85a6                	mv	a1,s1
    8134:	02000513          	li	a0,32
    8138:	0b21                	addi	s6,s6,8
    813a:	9402                	jalr	s0
    813c:	413b06b3          	sub	a3,s6,s3
    8140:	f756efe3          	bltu	a3,s5,80be <_ftoa+0xf8e>
    8144:	ceeff06f          	j	7632 <_ftoa+0x502>
    8148:	4e85                	li	t4,1
    814a:	418e8633          	sub	a2,t4,s8
    814e:	003a7593          	andi	a1,s4,3
    8152:	00f60fb3          	add	t6,a2,a5
    8156:	1dd58fe3          	beq	a1,t4,8b34 <_ftoa+0x1a04>
    815a:	02000393          	li	t2,32
    815e:	107f8be3          	beq	t6,t2,8a74 <_ftoa+0x1944>
    8162:	04080be3          	beqz	a6,89b8 <_ftoa+0x1888>
    8166:	007f8333          	add	t1,t6,t2
    816a:	00230733          	add	a4,t1,sp
    816e:	02d00513          	li	a0,45
    8172:	001f8b13          	addi	s6,t6,1
    8176:	fea70823          	sb	a0,-16(a4)
    817a:	a80592e3          	bnez	a1,7bfe <_ftoa+0xace>
    817e:	7c0ab28b          	th.extu	t0,s5,31,0
    8182:	a65b7ee3          	bgeu	s6,t0,7bfe <_ftoa+0xace>
    8186:	416285b3          	sub	a1,t0,s6
    818a:	0075f793          	andi	a5,a1,7
    818e:	01358d33          	add	s10,a1,s3
    8192:	8bce                	mv	s7,s3
    8194:	c7d9                	beqz	a5,8222 <_ftoa+0x10f2>
    8196:	4e85                	li	t4,1
    8198:	07d78c63          	beq	a5,t4,8210 <_ftoa+0x10e0>
    819c:	4609                	li	a2,2
    819e:	06c78263          	beq	a5,a2,8202 <_ftoa+0x10d2>
    81a2:	438d                	li	t2,3
    81a4:	04778863          	beq	a5,t2,81f4 <_ftoa+0x10c4>
    81a8:	4891                	li	a7,4
    81aa:	03178e63          	beq	a5,a7,81e6 <_ftoa+0x10b6>
    81ae:	4e15                	li	t3,5
    81b0:	03c78463          	beq	a5,t3,81d8 <_ftoa+0x10a8>
    81b4:	4f19                	li	t5,6
    81b6:	01e78a63          	beq	a5,t5,81ca <_ftoa+0x109a>
    81ba:	86ca                	mv	a3,s2
    81bc:	864e                	mv	a2,s3
    81be:	85a6                	mv	a1,s1
    81c0:	02000513          	li	a0,32
    81c4:	00198b93          	addi	s7,s3,1
    81c8:	9402                	jalr	s0
    81ca:	865e                	mv	a2,s7
    81cc:	86ca                	mv	a3,s2
    81ce:	85a6                	mv	a1,s1
    81d0:	02000513          	li	a0,32
    81d4:	0b85                	addi	s7,s7,1
    81d6:	9402                	jalr	s0
    81d8:	865e                	mv	a2,s7
    81da:	86ca                	mv	a3,s2
    81dc:	85a6                	mv	a1,s1
    81de:	02000513          	li	a0,32
    81e2:	0b85                	addi	s7,s7,1
    81e4:	9402                	jalr	s0
    81e6:	865e                	mv	a2,s7
    81e8:	86ca                	mv	a3,s2
    81ea:	85a6                	mv	a1,s1
    81ec:	02000513          	li	a0,32
    81f0:	0b85                	addi	s7,s7,1
    81f2:	9402                	jalr	s0
    81f4:	865e                	mv	a2,s7
    81f6:	86ca                	mv	a3,s2
    81f8:	85a6                	mv	a1,s1
    81fa:	02000513          	li	a0,32
    81fe:	0b85                	addi	s7,s7,1
    8200:	9402                	jalr	s0
    8202:	865e                	mv	a2,s7
    8204:	86ca                	mv	a3,s2
    8206:	85a6                	mv	a1,s1
    8208:	02000513          	li	a0,32
    820c:	0b85                	addi	s7,s7,1
    820e:	9402                	jalr	s0
    8210:	865e                	mv	a2,s7
    8212:	86ca                	mv	a3,s2
    8214:	0b85                	addi	s7,s7,1
    8216:	85a6                	mv	a1,s1
    8218:	02000513          	li	a0,32
    821c:	9402                	jalr	s0
    821e:	9f7d01e3          	beq	s10,s7,7c00 <_ftoa+0xad0>
    8222:	fc6e                	sd	s11,56(sp)
    8224:	865e                	mv	a2,s7
    8226:	86ca                	mv	a3,s2
    8228:	85a6                	mv	a1,s1
    822a:	02000513          	li	a0,32
    822e:	9402                	jalr	s0
    8230:	001b8c93          	addi	s9,s7,1
    8234:	8666                	mv	a2,s9
    8236:	86ca                	mv	a3,s2
    8238:	85a6                	mv	a1,s1
    823a:	02000513          	li	a0,32
    823e:	9402                	jalr	s0
    8240:	002b8d93          	addi	s11,s7,2
    8244:	866e                	mv	a2,s11
    8246:	86ca                	mv	a3,s2
    8248:	85a6                	mv	a1,s1
    824a:	02000513          	li	a0,32
    824e:	9402                	jalr	s0
    8250:	003b8c93          	addi	s9,s7,3
    8254:	8666                	mv	a2,s9
    8256:	86ca                	mv	a3,s2
    8258:	85a6                	mv	a1,s1
    825a:	02000513          	li	a0,32
    825e:	9402                	jalr	s0
    8260:	004b8d93          	addi	s11,s7,4
    8264:	866e                	mv	a2,s11
    8266:	86ca                	mv	a3,s2
    8268:	85a6                	mv	a1,s1
    826a:	02000513          	li	a0,32
    826e:	9402                	jalr	s0
    8270:	005b8c93          	addi	s9,s7,5
    8274:	8666                	mv	a2,s9
    8276:	86ca                	mv	a3,s2
    8278:	85a6                	mv	a1,s1
    827a:	02000513          	li	a0,32
    827e:	9402                	jalr	s0
    8280:	006b8d93          	addi	s11,s7,6
    8284:	86ca                	mv	a3,s2
    8286:	866e                	mv	a2,s11
    8288:	85a6                	mv	a1,s1
    828a:	02000513          	li	a0,32
    828e:	9402                	jalr	s0
    8290:	007b8c93          	addi	s9,s7,7
    8294:	86ca                	mv	a3,s2
    8296:	0ba1                	addi	s7,s7,8
    8298:	8666                	mv	a2,s9
    829a:	85a6                	mv	a1,s1
    829c:	02000513          	li	a0,32
    82a0:	9402                	jalr	s0
    82a2:	f97d11e3          	bne	s10,s7,8224 <_ftoa+0x10f4>
    82a6:	7de2                	ld	s11,56(sp)
    82a8:	baa1                	j	7c00 <_ftoa+0xad0>
    82aa:	0001                	nop
    82ac:	4305                	li	t1,1
    82ae:	41830733          	sub	a4,t1,s8
    82b2:	00c702b3          	add	t0,a4,a2
    82b6:	02000393          	li	t2,32
    82ba:	0e728363          	beq	t0,t2,83a0 <_ftoa+0x1270>
    82be:	7c0eb50b          	th.extu	a0,t4,31,0
    82c2:	00757b93          	andi	s7,a0,7
    82c6:	00550b33          	add	s6,a0,t0
    82ca:	03000893          	li	a7,48
    82ce:	060b8663          	beqz	s7,833a <_ftoa+0x120a>
    82d2:	005c588b          	th.srb	a7,s8,t0,0
    82d6:	0285                	addi	t0,t0,1
    82d8:	0c728463          	beq	t0,t2,83a0 <_ftoa+0x1270>
    82dc:	046b8f63          	beq	s7,t1,833a <_ftoa+0x120a>
    82e0:	4c89                	li	s9,2
    82e2:	059b8763          	beq	s7,s9,8330 <_ftoa+0x1200>
    82e6:	4d0d                	li	s10,3
    82e8:	03ab8f63          	beq	s7,s10,8326 <_ftoa+0x11f6>
    82ec:	4e11                	li	t3,4
    82ee:	03cb8763          	beq	s7,t3,831c <_ftoa+0x11ec>
    82f2:	4e95                	li	t4,5
    82f4:	01db8f63          	beq	s7,t4,8312 <_ftoa+0x11e2>
    82f8:	4f19                	li	t5,6
    82fa:	01eb8763          	beq	s7,t5,8308 <_ftoa+0x11d8>
    82fe:	005c588b          	th.srb	a7,s8,t0,0
    8302:	0285                	addi	t0,t0,1
    8304:	08728e63          	beq	t0,t2,83a0 <_ftoa+0x1270>
    8308:	005c588b          	th.srb	a7,s8,t0,0
    830c:	0285                	addi	t0,t0,1
    830e:	08728963          	beq	t0,t2,83a0 <_ftoa+0x1270>
    8312:	005c588b          	th.srb	a7,s8,t0,0
    8316:	0285                	addi	t0,t0,1
    8318:	08728463          	beq	t0,t2,83a0 <_ftoa+0x1270>
    831c:	005c588b          	th.srb	a7,s8,t0,0
    8320:	0285                	addi	t0,t0,1
    8322:	06728f63          	beq	t0,t2,83a0 <_ftoa+0x1270>
    8326:	005c588b          	th.srb	a7,s8,t0,0
    832a:	0285                	addi	t0,t0,1
    832c:	06728a63          	beq	t0,t2,83a0 <_ftoa+0x1270>
    8330:	005c588b          	th.srb	a7,s8,t0,0
    8334:	0285                	addi	t0,t0,1
    8336:	06728563          	beq	t0,t2,83a0 <_ftoa+0x1270>
    833a:	665b0463          	beq	s6,t0,89a2 <_ftoa+0x1872>
    833e:	005c588b          	th.srb	a7,s8,t0,0
    8342:	00128f93          	addi	t6,t0,1
    8346:	047f8d63          	beq	t6,t2,83a0 <_ftoa+0x1270>
    834a:	01fc588b          	th.srb	a7,s8,t6,0
    834e:	00228313          	addi	t1,t0,2
    8352:	04730763          	beq	t1,t2,83a0 <_ftoa+0x1270>
    8356:	006c588b          	th.srb	a7,s8,t1,0
    835a:	00328713          	addi	a4,t0,3
    835e:	04770163          	beq	a4,t2,83a0 <_ftoa+0x1270>
    8362:	00ec588b          	th.srb	a7,s8,a4,0
    8366:	00428513          	addi	a0,t0,4
    836a:	02750b63          	beq	a0,t2,83a0 <_ftoa+0x1270>
    836e:	00ac588b          	th.srb	a7,s8,a0,0
    8372:	00528b93          	addi	s7,t0,5
    8376:	027b8563          	beq	s7,t2,83a0 <_ftoa+0x1270>
    837a:	017c588b          	th.srb	a7,s8,s7,0
    837e:	00628c93          	addi	s9,t0,6
    8382:	007c8f63          	beq	s9,t2,83a0 <_ftoa+0x1270>
    8386:	019c588b          	th.srb	a7,s8,s9,0
    838a:	00728d13          	addi	s10,t0,7
    838e:	007d0963          	beq	s10,t2,83a0 <_ftoa+0x1270>
    8392:	01ac588b          	th.srb	a7,s8,s10,0
    8396:	02a1                	addi	t0,t0,8
    8398:	fa7291e3          	bne	t0,t2,833a <_ftoa+0x120a>
    839c:	00000013          	nop
    83a0:	02000f93          	li	t6,32
    83a4:	d8cff06f          	j	7930 <_ftoa+0x800>
    83a8:	e20506d3          	fmv.x.d	a3,fa0
    83ac:	fc6e                	sd	s11,56(sp)
    83ae:	fb46b58b          	th.extu	a1,a3,62,52
    83b2:	6ec5                	lui	t4,0x11
    83b4:	6645                	lui	a2,0x11
    83b6:	be0ebf07          	fld	ft10,-1056(t4) # 10be0 <errpat+0x70>
    83ba:	be863f87          	fld	ft11,-1048(a2) # 10be8 <errpat+0x78>
    83be:	c015879b          	addiw	a5,a1,-1023
    83c2:	d2078ed3          	fcvt.d.w	ft9,a5
    83c6:	3ff00893          	li	a7,1023
    83ca:	6e45                	lui	t3,0x11
    83cc:	03489b13          	slli	s6,a7,0x34
    83d0:	bf0e3787          	fld	fa5,-1040(t3) # 10bf0 <errpat+0x80>
    83d4:	cc06b38b          	th.extu	t2,a3,51,0
    83d8:	fbeef043          	fmadd.d	ft0,ft9,ft10,ft11
    83dc:	0163edb3          	or	s11,t2,s6
    83e0:	f20d80d3          	fmv.d.x	ft1,s11
    83e4:	6f45                	lui	t5,0x11
    83e6:	0af0f153          	fsub.d	ft2,ft1,fa5
    83ea:	bf8f3187          	fld	ft3,-1032(t5) # 10bf8 <errpat+0x88>
    83ee:	6845                	lui	a6,0x11
    83f0:	6545                	lui	a0,0x11
    83f2:	023176c3          	fmadd.d	fa3,ft2,ft3,ft0
    83f6:	c0083287          	fld	ft5,-1024(a6) # 10c00 <errpat+0x90>
    83fa:	c0853307          	fld	ft6,-1016(a0) # 10c08 <errpat+0x98>
    83fe:	6c45                	lui	s8,0x11
    8400:	c10c3587          	fld	fa1,-1008(s8) # 10c10 <errpat+0xa0>
    8404:	c2069353          	fcvt.w.d	t1,fa3,rtz
    8408:	6bc5                	lui	s7,0x11
    840a:	d2030253          	fcvt.d.w	ft4,t1
    840e:	c18bb807          	fld	fa6,-1000(s7) # 10c18 <errpat+0xa8>
    8412:	32527743          	fmadd.d	fa4,ft4,ft5,ft6
    8416:	4299                	li	t0,6
    8418:	400a7f93          	andi	t6,s4,1024
    841c:	41f2970b          	th.mveqz	a4,t0,t6
    8420:	62c5                	lui	t0,0x11
    8422:	c2071d53          	fcvt.w.d	s10,fa4,rtz
    8426:	c202bf07          	fld	ft10,-992(t0) # 10c20 <errpat+0xb0>
    842a:	d20d03d3          	fcvt.d.w	ft7,s10
    842e:	65c5                	lui	a1,0x11
    8430:	12b3f653          	fmul.d	fa2,ft7,fa1
    8434:	ba85b087          	fld	ft1,-1112(a1) # 10ba8 <errpat+0x38>
    8438:	67c5                	lui	a5,0x11
    843a:	c287b107          	fld	ft2,-984(a5) # 10c28 <errpat+0xb8>
    843e:	630278c7          	fmsub.d	fa7,ft4,fa6,fa2
    8442:	6ec5                	lui	t4,0x11
    8444:	c30eb207          	fld	ft4,-976(t4) # 10c30 <errpat+0xc0>
    8448:	6645                	lui	a2,0x11
    844a:	bb863707          	fld	fa4,-1096(a2) # 10bb8 <errpat+0x48>
    844e:	1318fe53          	fmul.d	ft8,fa7,fa7
    8452:	0b1272d3          	fsub.d	ft5,ft4,fa7
    8456:	0318fed3          	fadd.d	ft9,fa7,fa7
    845a:	3ffd039b          	addiw	t2,s10,1023
    845e:	1bee7fd3          	fdiv.d	ft11,ft8,ft10
    8462:	03439893          	slli	a7,t2,0x34
    8466:	f2088653          	fmv.d.x	fa2,a7
    846a:	f2068853          	fmv.d.x	fa6,a3
    846e:	00030c9b          	sext.w	s9,t1
    8472:	021ff053          	fadd.d	ft0,ft11,ft1
    8476:	1a0e77d3          	fdiv.d	fa5,ft8,ft0
    847a:	0227f1d3          	fadd.d	ft3,fa5,ft2
    847e:	1a3e76d3          	fdiv.d	fa3,ft8,ft3
    8482:	0256f353          	fadd.d	ft6,fa3,ft5
    8486:	1a6ef3d3          	fdiv.d	ft7,ft9,ft6
    848a:	02e3f5d3          	fadd.d	fa1,ft7,fa4
    848e:	12c5f8d3          	fmul.d	fa7,fa1,fa2
    8492:	a3181b53          	flt.d	s6,fa6,fa7
    8496:	000b0663          	beqz	s6,84a2 <_ftoa+0x1372>
    849a:	1a18f8d3          	fdiv.d	fa7,fa7,ft1
    849e:	fff30c9b          	addiw	s9,t1,-1
    84a2:	6505                	lui	a0,0x1
    84a4:	063c8d9b          	addiw	s11,s9,99
    84a8:	0c600e13          	li	t3,198
    84ac:	80050c13          	addi	s8,a0,-2048 # 800 <cmp_complex+0xc0>
    84b0:	01be3f33          	sltu	t5,t3,s11
    84b4:	4b89                	li	s7,2
    84b6:	4d0d                	li	s10,3
    84b8:	4315                	li	t1,5
    84ba:	4811                	li	a6,4
    84bc:	018a77b3          	and	a5,s4,s8
    84c0:	41eb9d0b          	th.mveqz	s10,s7,t5
    84c4:	41e8130b          	th.mveqz	t1,a6,t5
    84c8:	50078c63          	beqz	a5,89e0 <_ftoa+0x18b0>
    84cc:	fff7059b          	addiw	a1,a4,-1
    84d0:	41f7158b          	th.mveqz	a1,a4,t6
    84d4:	406a87bb          	subw	a5,s5,t1
    84d8:	01533eb3          	sltu	t4,t1,s5
    84dc:	002a7613          	andi	a2,s4,2
    84e0:	42e5970b          	th.mvnez	a4,a1,a4
    84e4:	41d0178b          	th.mveqz	a5,zero,t4
    84e8:	50060263          	beqz	a2,89ec <_ftoa+0x18bc>
    84ec:	4781                	li	a5,0
    84ee:	0001                	nop
    84f0:	000c8863          	beqz	s9,8500 <_ftoa+0x13d0>
    84f4:	f2068e53          	fmv.d.x	ft8,a3
    84f8:	1b1e7ed3          	fdiv.d	ft9,ft8,fa7
    84fc:	e20e86d3          	fmv.x.d	a3,ft9
    8500:	f2000f53          	fmv.d.x	ft10,zero
    8504:	a3e513d3          	flt.d	t2,fa0,ft10
    8508:	00038863          	beqz	t2,8518 <_ftoa+0x13e8>
    850c:	f2068553          	fmv.d.x	fa0,a3
    8510:	22a51fd3          	fneg.d	ft11,fa0
    8514:	e20f86d3          	fmv.x.d	a3,ft11
    8518:	78fd                	lui	a7,0xfffff
    851a:	7ff88b13          	addi	s6,a7,2047 # fffffffffffff7ff <__kernel_stack+0xfffffffffff117ff>
    851e:	016a7833          	and	a6,s4,s6
    8522:	f2068553          	fmv.d.x	fa0,a3
    8526:	864e                	mv	a2,s3
    8528:	86ca                	mv	a3,s2
    852a:	85a6                	mv	a1,s1
    852c:	8522                	mv	a0,s0
    852e:	c03fe0ef          	jal	7130 <_ftoa>
    8532:	020a7713          	andi	a4,s4,32
    8536:	862a                	mv	a2,a0
    8538:	00150a13          	addi	s4,a0,1
    853c:	06500793          	li	a5,101
    8540:	8daa                	mv	s11,a0
    8542:	04500513          	li	a0,69
    8546:	e452                	sd	s4,8(sp)
    8548:	86ca                	mv	a3,s2
    854a:	40e7950b          	th.mveqz	a0,a5,a4
    854e:	85a6                	mv	a1,s1
    8550:	9402                	jalr	s0
    8552:	41fcde1b          	sraiw	t3,s9,0x1f
    8556:	01cccf33          	xor	t5,s9,t3
    855a:	41cf033b          	subw	t1,t5,t3
    855e:	4c29                	li	s8,10
    8560:	03837833          	remu	a6,t1,s8
    8564:	01010a13          	addi	s4,sp,16
    8568:	4fa5                	li	t6,9
    856a:	86d2                	mv	a3,s4
    856c:	0308051b          	addiw	a0,a6,48
    8570:	00aa0023          	sb	a0,0(s4)
    8574:	038358b3          	divu	a7,t1,s8
    8578:	106ff863          	bgeu	t6,t1,8688 <_ftoa+0x1558>
    857c:	01110693          	addi	a3,sp,17
    8580:	0388f2b3          	remu	t0,a7,s8
    8584:	0302859b          	addiw	a1,t0,48
    8588:	00b68023          	sb	a1,0(a3)
    858c:	0388deb3          	divu	t4,a7,s8
    8590:	0f1ffc63          	bgeu	t6,a7,8688 <_ftoa+0x1558>
    8594:	00168393          	addi	t2,a3,1
    8598:	1810                	addi	a2,sp,48
    859a:	0e760763          	beq	a2,t2,8688 <_ftoa+0x1558>
    859e:	869e                	mv	a3,t2
    85a0:	038ef8b3          	remu	a7,t4,s8
    85a4:	03088b1b          	addiw	s6,a7,48
    85a8:	01638023          	sb	s6,0(t2)
    85ac:	038ed733          	divu	a4,t4,s8
    85b0:	0ddffc63          	bgeu	t6,t4,8688 <_ftoa+0x1558>
    85b4:	038777b3          	remu	a5,a4,s8
    85b8:	03078e1b          	addiw	t3,a5,48
    85bc:	0816de0b          	th.sbib	t3,(a3),1,0
    85c0:	03875f33          	divu	t5,a4,s8
    85c4:	0ceff263          	bgeu	t6,a4,8688 <_ftoa+0x1558>
    85c8:	00238693          	addi	a3,t2,2
    85cc:	038f7333          	remu	t1,t5,s8
    85d0:	0303081b          	addiw	a6,t1,48
    85d4:	01038123          	sb	a6,2(t2)
    85d8:	038f5533          	divu	a0,t5,s8
    85dc:	0beff663          	bgeu	t6,t5,8688 <_ftoa+0x1558>
    85e0:	00338693          	addi	a3,t2,3
    85e4:	038572b3          	remu	t0,a0,s8
    85e8:	0302859b          	addiw	a1,t0,48
    85ec:	00b381a3          	sb	a1,3(t2)
    85f0:	03855eb3          	divu	t4,a0,s8
    85f4:	08affa63          	bgeu	t6,a0,8688 <_ftoa+0x1558>
    85f8:	00438693          	addi	a3,t2,4
    85fc:	038ef633          	remu	a2,t4,s8
    8600:	0306089b          	addiw	a7,a2,48
    8604:	01138223          	sb	a7,4(t2)
    8608:	038edb33          	divu	s6,t4,s8
    860c:	07dffe63          	bgeu	t6,t4,8688 <_ftoa+0x1558>
    8610:	00538693          	addi	a3,t2,5
    8614:	038b7733          	remu	a4,s6,s8
    8618:	0307079b          	addiw	a5,a4,48
    861c:	00f382a3          	sb	a5,5(t2)
    8620:	038b5e33          	divu	t3,s6,s8
    8624:	076ff263          	bgeu	t6,s6,8688 <_ftoa+0x1558>
    8628:	00638693          	addi	a3,t2,6
    862c:	038e7f33          	remu	t5,t3,s8
    8630:	030f031b          	addiw	t1,t5,48
    8634:	00638323          	sb	t1,6(t2)
    8638:	038e5833          	divu	a6,t3,s8
    863c:	05cff663          	bgeu	t6,t3,8688 <_ftoa+0x1558>
    8640:	00738693          	addi	a3,t2,7
    8644:	03887533          	remu	a0,a6,s8
    8648:	0305029b          	addiw	t0,a0,48
    864c:	005383a3          	sb	t0,7(t2)
    8650:	038855b3          	divu	a1,a6,s8
    8654:	030ffa63          	bgeu	t6,a6,8688 <_ftoa+0x1558>
    8658:	00838693          	addi	a3,t2,8
    865c:	0385feb3          	remu	t4,a1,s8
    8660:	030e861b          	addiw	a2,t4,48
    8664:	00c38423          	sb	a2,8(t2)
    8668:	0385d8b3          	divu	a7,a1,s8
    866c:	00bffe63          	bgeu	t6,a1,8688 <_ftoa+0x1558>
    8670:	00938693          	addi	a3,t2,9
    8674:	0388f2b3          	remu	t0,a7,s8
    8678:	0302859b          	addiw	a1,t0,48
    867c:	00b68023          	sb	a1,0(a3)
    8680:	0388deb3          	divu	t4,a7,s8
    8684:	f11fe8e3          	bltu	t6,a7,8594 <_ftoa+0x1464>
    8688:	4c05                	li	s8,1
    868a:	414c0fb3          	sub	t6,s8,s4
    868e:	00df8b33          	add	s6,t6,a3
    8692:	43ab7d63          	bgeu	s6,s10,8acc <_ftoa+0x199c>
    8696:	016a07b3          	add	a5,s4,s6
    869a:	01aa03b3          	add	t2,s4,s10
    869e:	40f386b3          	sub	a3,t2,a5
    86a2:	0076fe13          	andi	t3,a3,7
    86a6:	03000713          	li	a4,48
    86aa:	380e0b63          	beqz	t3,8a40 <_ftoa+0x1910>
    86ae:	038e0d63          	beq	t3,s8,86e8 <_ftoa+0x15b8>
    86b2:	4f09                	li	t5,2
    86b4:	03ee0863          	beq	t3,t5,86e4 <_ftoa+0x15b4>
    86b8:	430d                	li	t1,3
    86ba:	026e0363          	beq	t3,t1,86e0 <_ftoa+0x15b0>
    86be:	4811                	li	a6,4
    86c0:	010e0e63          	beq	t3,a6,86dc <_ftoa+0x15ac>
    86c4:	4515                	li	a0,5
    86c6:	00ae0963          	beq	t3,a0,86d8 <_ftoa+0x15a8>
    86ca:	4299                	li	t0,6
    86cc:	005e0463          	beq	t3,t0,86d4 <_ftoa+0x15a4>
    86d0:	1817d70b          	th.sbia	a4,(a5),1,0
    86d4:	1817d70b          	th.sbia	a4,(a5),1,0
    86d8:	1817d70b          	th.sbia	a4,(a5),1,0
    86dc:	1817d70b          	th.sbia	a4,(a5),1,0
    86e0:	1817d70b          	th.sbia	a4,(a5),1,0
    86e4:	1817d70b          	th.sbia	a4,(a5),1,0
    86e8:	1817d70b          	th.sbia	a4,(a5),1,0
    86ec:	34f39a63          	bne	t2,a5,8a40 <_ftoa+0x1910>
    86f0:	020d0593          	addi	a1,s10,32
    86f4:	01010e93          	addi	t4,sp,16
    86f8:	001d0b13          	addi	s6,s10,1
    86fc:	01d58633          	add	a2,a1,t4
    8700:	400cdc63          	bgez	s9,8b18 <_ftoa+0x19e8>
    8704:	02d00513          	li	a0,45
    8708:	fea60023          	sb	a0,-32(a2)
    870c:	016a0c33          	add	s8,s4,s6
    8710:	fffa4893          	not	a7,s4
    8714:	001a0c93          	addi	s9,s4,1
    8718:	01888fb3          	add	t6,a7,s8
    871c:	9de6                	add	s11,s11,s9
    871e:	007ffd13          	andi	s10,t6,7
    8722:	016d8cb3          	add	s9,s11,s6
    8726:	100d0663          	beqz	s10,8832 <_ftoa+0x1702>
    872a:	418c8633          	sub	a2,s9,s8
    872e:	86ca                	mv	a3,s2
    8730:	85a6                	mv	a1,s1
    8732:	9402                	jalr	s0
    8734:	4385                	li	t2,1
    8736:	1c7d                	addi	s8,s8,-1
    8738:	fffc4503          	lbu	a0,-1(s8)
    873c:	0e7d0b63          	beq	s10,t2,8832 <_ftoa+0x1702>
    8740:	4709                	li	a4,2
    8742:	06ed0663          	beq	s10,a4,87ae <_ftoa+0x167e>
    8746:	468d                	li	a3,3
    8748:	04dd0b63          	beq	s10,a3,879e <_ftoa+0x166e>
    874c:	4e11                	li	t3,4
    874e:	05cd0063          	beq	s10,t3,878e <_ftoa+0x165e>
    8752:	4f15                	li	t5,5
    8754:	03ed0563          	beq	s10,t5,877e <_ftoa+0x164e>
    8758:	4319                	li	t1,6
    875a:	006d0a63          	beq	s10,t1,876e <_ftoa+0x163e>
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
    87b8:	1c7d                	addi	s8,s8,-1
    87ba:	fffc4503          	lbu	a0,-1(s8)
    87be:	a895                	j	8832 <_ftoa+0x1702>
    87c0:	8de2                	mv	s11,s8
    87c2:	89edc50b          	th.lbuib	a0,(s11),-2,0
    87c6:	410c8633          	sub	a2,s9,a6
    87ca:	86ca                	mv	a3,s2
    87cc:	85a6                	mv	a1,s1
    87ce:	9402                	jalr	s0
    87d0:	8d62                	mv	s10,s8
    87d2:	89dd450b          	th.lbuib	a0,(s10),-3,0
    87d6:	41bc8633          	sub	a2,s9,s11
    87da:	86ca                	mv	a3,s2
    87dc:	85a6                	mv	a1,s1
    87de:	9402                	jalr	s0
    87e0:	8de2                	mv	s11,s8
    87e2:	89cdc50b          	th.lbuib	a0,(s11),-4,0
    87e6:	41ac8633          	sub	a2,s9,s10
    87ea:	86ca                	mv	a3,s2
    87ec:	85a6                	mv	a1,s1
    87ee:	9402                	jalr	s0
    87f0:	8d62                	mv	s10,s8
    87f2:	89bd450b          	th.lbuib	a0,(s10),-5,0
    87f6:	41bc8633          	sub	a2,s9,s11
    87fa:	86ca                	mv	a3,s2
    87fc:	85a6                	mv	a1,s1
    87fe:	9402                	jalr	s0
    8800:	8de2                	mv	s11,s8
    8802:	89adc50b          	th.lbuib	a0,(s11),-6,0
    8806:	41ac8633          	sub	a2,s9,s10
    880a:	86ca                	mv	a3,s2
    880c:	85a6                	mv	a1,s1
    880e:	9402                	jalr	s0
    8810:	8d62                	mv	s10,s8
    8812:	899d450b          	th.lbuib	a0,(s10),-7,0
    8816:	86ca                	mv	a3,s2
    8818:	41bc8633          	sub	a2,s9,s11
    881c:	85a6                	mv	a1,s1
    881e:	9402                	jalr	s0
    8820:	898c450b          	th.lbuib	a0,(s8),-8,0
    8824:	86ca                	mv	a3,s2
    8826:	41ac8633          	sub	a2,s9,s10
    882a:	85a6                	mv	a1,s1
    882c:	9402                	jalr	s0
    882e:	fffc4503          	lbu	a0,-1(s8)
    8832:	86ca                	mv	a3,s2
    8834:	418c8633          	sub	a2,s9,s8
    8838:	85a6                	mv	a1,s1
    883a:	9402                	jalr	s0
    883c:	fffc0813          	addi	a6,s8,-1
    8840:	f90a10e3          	bne	s4,a6,87c0 <_ftoa+0x1690>
    8844:	6a22                	ld	s4,8(sp)
    8846:	9b52                	add	s6,s6,s4
    8848:	140b8963          	beqz	s7,899a <_ftoa+0x186a>
    884c:	413b09b3          	sub	s3,s6,s3
    8850:	7c0aba8b          	th.extu	s5,s5,31,0
    8854:	1559f363          	bgeu	s3,s5,899a <_ftoa+0x186a>
    8858:	fff9cb93          	not	s7,s3
    885c:	015b8533          	add	a0,s7,s5
    8860:	865a                	mv	a2,s6
    8862:	00757d93          	andi	s11,a0,7
    8866:	86ca                	mv	a3,s2
    8868:	85a6                	mv	a1,s1
    886a:	02000513          	li	a0,32
    886e:	00198d13          	addi	s10,s3,1
    8872:	0b05                	addi	s6,s6,1
    8874:	9402                	jalr	s0
    8876:	135d7263          	bgeu	s10,s5,899a <_ftoa+0x186a>
    887a:	080d8e63          	beqz	s11,8916 <_ftoa+0x17e6>
    887e:	4285                	li	t0,1
    8880:	085d8163          	beq	s11,t0,8902 <_ftoa+0x17d2>
    8884:	4789                	li	a5,2
    8886:	06fd8663          	beq	s11,a5,88f2 <_ftoa+0x17c2>
    888a:	458d                	li	a1,3
    888c:	04bd8b63          	beq	s11,a1,88e2 <_ftoa+0x17b2>
    8890:	4e91                	li	t4,4
    8892:	05dd8063          	beq	s11,t4,88d2 <_ftoa+0x17a2>
    8896:	4615                	li	a2,5
    8898:	02cd8563          	beq	s11,a2,88c2 <_ftoa+0x1792>
    889c:	4c99                	li	s9,6
    889e:	019d8a63          	beq	s11,s9,88b2 <_ftoa+0x1782>
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
    890c:	0d05                	addi	s10,s10,1
    890e:	0b05                	addi	s6,s6,1
    8910:	9402                	jalr	s0
    8912:	095d7463          	bgeu	s10,s5,899a <_ftoa+0x186a>
    8916:	865a                	mv	a2,s6
    8918:	86ca                	mv	a3,s2
    891a:	85a6                	mv	a1,s1
    891c:	02000513          	li	a0,32
    8920:	9402                	jalr	s0
    8922:	001b0c13          	addi	s8,s6,1
    8926:	8662                	mv	a2,s8
    8928:	86ca                	mv	a3,s2
    892a:	85a6                	mv	a1,s1
    892c:	02000513          	li	a0,32
    8930:	9402                	jalr	s0
    8932:	002b0993          	addi	s3,s6,2
    8936:	86ca                	mv	a3,s2
    8938:	864e                	mv	a2,s3
    893a:	85a6                	mv	a1,s1
    893c:	02000513          	li	a0,32
    8940:	9402                	jalr	s0
    8942:	003b0a13          	addi	s4,s6,3
    8946:	86ca                	mv	a3,s2
    8948:	8652                	mv	a2,s4
    894a:	85a6                	mv	a1,s1
    894c:	02000513          	li	a0,32
    8950:	9402                	jalr	s0
    8952:	004b0b93          	addi	s7,s6,4
    8956:	86ca                	mv	a3,s2
    8958:	865e                	mv	a2,s7
    895a:	85a6                	mv	a1,s1
    895c:	02000513          	li	a0,32
    8960:	9402                	jalr	s0
    8962:	005b0d93          	addi	s11,s6,5
    8966:	86ca                	mv	a3,s2
    8968:	866e                	mv	a2,s11
    896a:	85a6                	mv	a1,s1
    896c:	02000513          	li	a0,32
    8970:	9402                	jalr	s0
    8972:	006b0c93          	addi	s9,s6,6
    8976:	86ca                	mv	a3,s2
    8978:	8666                	mv	a2,s9
    897a:	85a6                	mv	a1,s1
    897c:	02000513          	li	a0,32
    8980:	9402                	jalr	s0
    8982:	007b0c13          	addi	s8,s6,7
    8986:	86ca                	mv	a3,s2
    8988:	8662                	mv	a2,s8
    898a:	85a6                	mv	a1,s1
    898c:	02000513          	li	a0,32
    8990:	0d21                	addi	s10,s10,8
    8992:	0b21                	addi	s6,s6,8
    8994:	9402                	jalr	s0
    8996:	f95d60e3          	bltu	s10,s5,8916 <_ftoa+0x17e6>
    899a:	7de2                	ld	s11,56(sp)
    899c:	6d06                	ld	s10,64(sp)
    899e:	c95fe06f          	j	7632 <_ftoa+0x502>
    89a2:	002b0633          	add	a2,s6,sp
    89a6:	02e00693          	li	a3,46
    89aa:	001b0f93          	addi	t6,s6,1
    89ae:	00d60823          	sb	a3,16(a2)
    89b2:	f7ffe06f          	j	7930 <_ftoa+0x800>
    89b6:	0001                	nop
    89b8:	004a7813          	andi	a6,s4,4
    89bc:	02080e63          	beqz	a6,89f8 <_ftoa+0x18c8>
    89c0:	002f8f33          	add	t5,t6,sp
    89c4:	001f8b13          	addi	s6,t6,1
    89c8:	02b00f93          	li	t6,43
    89cc:	01ff0823          	sb	t6,16(t5)
    89d0:	faaff06f          	j	817a <_ftoa+0x104a>
    89d4:	8d4e                	mv	s10,s3
    89d6:	02000b13          	li	s6,32
    89da:	a26ff06f          	j	7c00 <_ftoa+0xad0>
    89de:	0001                	nop
    89e0:	0f536d63          	bltu	t1,s5,8ada <_ftoa+0x19aa>
    89e4:	017a7fb3          	and	t6,s4,s7
    89e8:	b00f94e3          	bnez	t6,84f0 <_ftoa+0x13c0>
    89ec:	4b81                	li	s7,0
    89ee:	b609                	j	84f0 <_ftoa+0x13c0>
    89f0:	4585                	li	a1,1
    89f2:	0001                	nop
    89f4:	00000013          	nop
    89f8:	008a7513          	andi	a0,s4,8
    89fc:	8b7e                	mv	s6,t6
    89fe:	f6050e63          	beqz	a0,817a <_ftoa+0x104a>
    8a02:	002f8cb3          	add	s9,t6,sp
    8a06:	02000d13          	li	s10,32
    8a0a:	001f8b13          	addi	s6,t6,1
    8a0e:	01ac8823          	sb	s10,16(s9)
    8a12:	f68ff06f          	j	817a <_ftoa+0x104a>
    8a16:	0001                	nop
    8a18:	0016f893          	andi	a7,a3,1
    8a1c:	00089463          	bnez	a7,8a24 <_ftoa+0x18f4>
    8a20:	8c9fe06f          	j	72e8 <_ftoa+0x1b8>
    8a24:	0685                	addi	a3,a3,1
    8a26:	ee7fe06f          	j	790c <_ftoa+0x7dc>
    8a2a:	0001                	nop
    8a2c:	417c8633          	sub	a2,s9,s7
    8a30:	89fbc50b          	th.lbuib	a0,(s7),-1,0
    8a34:	86ca                	mv	a3,s2
    8a36:	85a6                	mv	a1,s1
    8a38:	9402                	jalr	s0
    8a3a:	9fcff06f          	j	7c36 <_ftoa+0xb06>
    8a3e:	0001                	nop
    8a40:	00e78023          	sb	a4,0(a5)
    8a44:	00e780a3          	sb	a4,1(a5)
    8a48:	00e78123          	sb	a4,2(a5)
    8a4c:	00e781a3          	sb	a4,3(a5)
    8a50:	00e78223          	sb	a4,4(a5)
    8a54:	00e782a3          	sb	a4,5(a5)
    8a58:	00e78323          	sb	a4,6(a5)
    8a5c:	00e783a3          	sb	a4,7(a5)
    8a60:	07a1                	addi	a5,a5,8
    8a62:	fcf39fe3          	bne	t2,a5,8a40 <_ftoa+0x1910>
    8a66:	b169                	j	86f0 <_ftoa+0x15c0>
    8a68:	02000b13          	li	s6,32
    8a6c:	8d4e                	mv	s10,s3
    8a6e:	992ff06f          	j	7c00 <_ftoa+0xad0>
    8a72:	0001                	nop
    8a74:	02000b13          	li	s6,32
    8a78:	f02ff06f          	j	817a <_ftoa+0x104a>
    8a7c:	22a51e53          	fneg.d	ft8,fa0
    8a80:	fc6e                	sd	s11,56(sp)
    8a82:	e20e06d3          	fmv.x.d	a3,ft8
    8a86:	b225                	j	83ae <_ftoa+0x127e>
    8a88:	02000b13          	li	s6,32
    8a8c:	00ca7e93          	andi	t4,s4,12
    8a90:	060e8b63          	beqz	t4,8b06 <_ftoa+0x19d6>
    8a94:	3afd                	addiw	s5,s5,-1
    8a96:	7c0abf8b          	th.extu	t6,s5,31,0
    8a9a:	87fb6163          	bltu	s6,t6,7afc <_ftoa+0x9cc>
    8a9e:	02000393          	li	t2,32
    8aa2:	947b0e63          	beq	s6,t2,7bfe <_ftoa+0xace>
    8aa6:	004a7813          	andi	a6,s4,4
    8aaa:	06080e63          	beqz	a6,8b26 <_ftoa+0x19f6>
    8aae:	020b0e13          	addi	t3,s6,32
    8ab2:	01010f13          	addi	t5,sp,16
    8ab6:	01ee0fb3          	add	t6,t3,t5
    8aba:	02b00313          	li	t1,43
    8abe:	fe6f8023          	sb	t1,-32(t6)
    8ac2:	0b05                	addi	s6,s6,1
    8ac4:	8d4e                	mv	s10,s3
    8ac6:	93aff06f          	j	7c00 <_ftoa+0xad0>
    8aca:	0001                	nop
    8acc:	02000d13          	li	s10,32
    8ad0:	05ab1963          	bne	s6,s10,8b22 <_ftoa+0x19f2>
    8ad4:	02f14503          	lbu	a0,47(sp)
    8ad8:	b915                	j	870c <_ftoa+0x15dc>
    8ada:	002a7293          	andi	t0,s4,2
    8ade:	a00299e3          	bnez	t0,84f0 <_ftoa+0x13c0>
    8ae2:	406a87bb          	subw	a5,s5,t1
    8ae6:	4b81                	li	s7,0
    8ae8:	b421                	j	84f0 <_ftoa+0x13c0>
    8aea:	004a7813          	andi	a6,s4,4
    8aee:	f00801e3          	beqz	a6,89f0 <_ftoa+0x18c0>
    8af2:	0b05                	addi	s6,s6,1
    8af4:	002f8833          	add	a6,t6,sp
    8af8:	02b00713          	li	a4,43
    8afc:	00e80823          	sb	a4,16(a6)
    8b00:	8d4e                	mv	s10,s3
    8b02:	8feff06f          	j	7c00 <_ftoa+0xad0>
    8b06:	7c0abf8b          	th.extu	t6,s5,31,0
    8b0a:	01fb7463          	bgeu	s6,t6,8b12 <_ftoa+0x19e2>
    8b0e:	feffe06f          	j	7afc <_ftoa+0x9cc>
    8b12:	8d4e                	mv	s10,s3
    8b14:	8ecff06f          	j	7c00 <_ftoa+0xad0>
    8b18:	02b00513          	li	a0,43
    8b1c:	fea60023          	sb	a0,-32(a2)
    8b20:	b6f5                	j	870c <_ftoa+0x15dc>
    8b22:	8d5a                	mv	s10,s6
    8b24:	b6f1                	j	86f0 <_ftoa+0x15c0>
    8b26:	008a7893          	andi	a7,s4,8
    8b2a:	8c088a63          	beqz	a7,7bfe <_ftoa+0xace>
    8b2e:	8fda                	mv	t6,s6
    8b30:	4585                	li	a1,1
    8b32:	bdc1                	j	8a02 <_ftoa+0x18d2>
    8b34:	000a8d63          	beqz	s5,8b4e <_ftoa+0x1a1e>
    8b38:	06080c63          	beqz	a6,8bb0 <_ftoa+0x1a80>
    8b3c:	3afd                	addiw	s5,s5,-1
    8b3e:	7c0ab68b          	th.extu	a3,s5,31,0
    8b42:	04dff463          	bgeu	t6,a3,8b8a <_ftoa+0x1a5a>
    8b46:	8b7e                	mv	s6,t6
    8b48:	8fb6                	mv	t6,a3
    8b4a:	fb3fe06f          	j	7afc <_ftoa+0x9cc>
    8b4e:	02000b93          	li	s7,32
    8b52:	037f8863          	beq	t6,s7,8b82 <_ftoa+0x1a52>
    8b56:	00080f63          	beqz	a6,8b74 <_ftoa+0x1a44>
    8b5a:	017f8d33          	add	s10,t6,s7
    8b5e:	002d05b3          	add	a1,s10,sp
    8b62:	02d00793          	li	a5,45
    8b66:	001f8b13          	addi	s6,t6,1
    8b6a:	fef58823          	sb	a5,-16(a1)
    8b6e:	8d4e                	mv	s10,s3
    8b70:	890ff06f          	j	7c00 <_ftoa+0xad0>
    8b74:	004a7c93          	andi	s9,s4,4
    8b78:	001f8b13          	addi	s6,t6,1
    8b7c:	f60c9ce3          	bnez	s9,8af4 <_ftoa+0x19c4>
    8b80:	bda5                	j	89f8 <_ftoa+0x18c8>
    8b82:	8b7e                	mv	s6,t6
    8b84:	8d4e                	mv	s10,s3
    8b86:	87aff06f          	j	7c00 <_ftoa+0xad0>
    8b8a:	02000713          	li	a4,32
    8b8e:	feef8ae3          	beq	t6,a4,8b82 <_ftoa+0x1a52>
    8b92:	00ef8533          	add	a0,t6,a4
    8b96:	01010b93          	addi	s7,sp,16
    8b9a:	02d00d13          	li	s10,45
    8b9e:	01750cb3          	add	s9,a0,s7
    8ba2:	ffac8023          	sb	s10,-32(s9)
    8ba6:	01df8b33          	add	s6,t6,t4
    8baa:	8d4e                	mv	s10,s3
    8bac:	854ff06f          	j	7c00 <_ftoa+0xad0>
    8bb0:	8b7e                	mv	s6,t6
    8bb2:	bde9                	j	8a8c <_ftoa+0x195c>
    8bb4:	00000013          	nop
    8bb8:	00000013          	nop
    8bbc:	00000013          	nop

0000000000008bc0 <_vsnprintf>:
    8bc0:	7131                	addi	sp,sp,-192
    8bc2:	f526                	sd	s1,168(sp)
    8bc4:	f922                	sd	s0,176(sp)
    8bc6:	641d                	lui	s0,0x7
    8bc8:	ed4e                	sd	s3,152(sp)
    8bca:	f14a                	sd	s2,160(sp)
    8bcc:	fd06                	sd	ra,184(sp)
    8bce:	10040413          	addi	s0,s0,256 # 7100 <_out_null>
    8bd2:	42b5140b          	th.mvnez	s0,a0,a1
    8bd6:	0006c503          	lbu	a0,0(a3)
    8bda:	4381                	li	t2,0
    8bdc:	892e                	mv	s2,a1
    8bde:	84b2                	mv	s1,a2
    8be0:	e119                	bnez	a0,8be6 <_vsnprintf+0x26>
    8be2:	3550106f          	j	a736 <_vsnprintf+0x1b76>
    8be6:	67c5                	lui	a5,0x11
    8be8:	c8c78293          	addi	t0,a5,-884 # 10c8c <errpat+0x11c>
    8bec:	e556                	sd	s5,136(sp)
    8bee:	e952                	sd	s4,144(sp)
    8bf0:	6a45                	lui	s4,0x11
    8bf2:	ecee                	sd	s11,88(sp)
    8bf4:	f0ea                	sd	s10,96(sp)
    8bf6:	f4e6                	sd	s9,104(sp)
    8bf8:	f8e2                	sd	s8,112(sp)
    8bfa:	fcde                	sd	s7,120(sp)
    8bfc:	e15a                	sd	s6,128(sp)
    8bfe:	49c1                	li	s3,16
    8c00:	e01e                	sd	t2,0(sp)
    8c02:	e816                	sd	t0,16(sp)
    8c04:	8cb6                	mv	s9,a3
    8c06:	8dba                	mv	s11,a4
    8c08:	c48a0a13          	addi	s4,s4,-952 # 10c48 <errpat+0xd8>
    8c0c:	a831                	j	8c28 <_vsnprintf+0x68>
    8c0e:	0001                	nop
    8c10:	6602                	ld	a2,0(sp)
    8c12:	86a6                	mv	a3,s1
    8c14:	85ca                	mv	a1,s2
    8c16:	00160c13          	addi	s8,a2,1
    8c1a:	0c85                	addi	s9,s9,1
    8c1c:	9402                	jalr	s0
    8c1e:	e062                	sd	s8,0(sp)
    8c20:	000cc503          	lbu	a0,0(s9)
    8c24:	1c050263          	beqz	a0,8de8 <_vsnprintf+0x228>
    8c28:	02500313          	li	t1,37
    8c2c:	fe6512e3          	bne	a0,t1,8c10 <_vsnprintf+0x50>
    8c30:	002c8893          	addi	a7,s9,2
    8c34:	4b01                	li	s6,0
    8c36:	0001                	nop
    8c38:	fff8c503          	lbu	a0,-1(a7)
    8c3c:	fe05071b          	addiw	a4,a0,-32
    8c40:	0ff77393          	zext.b	t2,a4
    8c44:	0079e663          	bltu	s3,t2,8c50 <_vsnprintf+0x90>
    8c48:	447a458b          	th.lrw	a1,s4,t2,2
    8c4c:	8582                	jr	a1
    8c4e:	0001                	nop
    8c50:	fff88a93          	addi	s5,a7,-1
    8c54:	fd050c1b          	addiw	s8,a0,-48
    8c58:	4ba5                	li	s7,9
    8c5a:	e456                	sd	s5,8(sp)
    8c5c:	0ffc7c93          	zext.b	s9,s8
    8c60:	0b9bf663          	bgeu	s7,s9,8d0c <_vsnprintf+0x14c>
    8c64:	02a00d13          	li	s10,42
    8c68:	4881                	li	a7,0
    8c6a:	35a50163          	beq	a0,s10,8fac <_vsnprintf+0x3ec>
    8c6e:	02e00f93          	li	t6,46
    8c72:	4c01                	li	s8,0
    8c74:	15f50363          	beq	a0,t6,8dba <_vsnprintf+0x1fa>
    8c78:	f985081b          	addiw	a6,a0,-104
    8c7c:	0ff87f93          	zext.b	t6,a6
    8c80:	4ac9                	li	s5,18
    8c82:	05faef63          	bltu	s5,t6,8ce0 <_vsnprintf+0x120>
    8c86:	6bc2                	ld	s7,16(sp)
    8c88:	45fbcc8b          	th.lrw	s9,s7,t6,2
    8c8c:	8c82                	jr	s9
    8c8e:	0001                	nop
    8c90:	001b6b13          	ori	s6,s6,1
    8c94:	2b01                	sext.w	s6,s6
    8c96:	0885                	addi	a7,a7,1
    8c98:	b745                	j	8c38 <_vsnprintf+0x78>
    8c9a:	0001                	nop
    8c9c:	002b6513          	ori	a0,s6,2
    8ca0:	00050b1b          	sext.w	s6,a0
    8ca4:	0885                	addi	a7,a7,1
    8ca6:	bf49                	j	8c38 <_vsnprintf+0x78>
    8ca8:	004b6613          	ori	a2,s6,4
    8cac:	00060b1b          	sext.w	s6,a2
    8cb0:	0885                	addi	a7,a7,1
    8cb2:	b759                	j	8c38 <_vsnprintf+0x78>
    8cb4:	010b6693          	ori	a3,s6,16
    8cb8:	00068b1b          	sext.w	s6,a3
    8cbc:	0885                	addi	a7,a7,1
    8cbe:	bfad                	j	8c38 <_vsnprintf+0x78>
    8cc0:	008b6813          	ori	a6,s6,8
    8cc4:	00080b1b          	sext.w	s6,a6
    8cc8:	0885                	addi	a7,a7,1
    8cca:	b7bd                	j	8c38 <_vsnprintf+0x78>
    8ccc:	6322                	ld	t1,8(sp)
    8cce:	100b6693          	ori	a3,s6,256
    8cd2:	00068b1b          	sext.w	s6,a3
    8cd6:	00134503          	lbu	a0,1(t1)
    8cda:	00130393          	addi	t2,t1,1
    8cde:	e41e                	sd	t2,8(sp)
    8ce0:	06700a93          	li	s5,103
    8ce4:	14aae063          	bltu	s5,a0,8e24 <_vsnprintf+0x264>
    8ce8:	02400d13          	li	s10,36
    8cec:	2cad7c63          	bgeu	s10,a0,8fc4 <_vsnprintf+0x404>
    8cf0:	fdb50c9b          	addiw	s9,a0,-37
    8cf4:	0ffcf693          	zext.b	a3,s9
    8cf8:	04200393          	li	t2,66
    8cfc:	2cd3e463          	bltu	t2,a3,8fc4 <_vsnprintf+0x404>
    8d00:	6345                	lui	t1,0x11
    8d02:	cd830813          	addi	a6,t1,-808 # 10cd8 <errpat+0x168>
    8d06:	44d84f8b          	th.lrw	t6,a6,a3,2
    8d0a:	8f82                	jr	t6
    8d0c:	66a2                	ld	a3,8(sp)
    8d0e:	4881                	li	a7,0
    8d10:	8fde                	mv	t6,s7
    8d12:	0028929b          	slliw	t0,a7,0x2
    8d16:	0112833b          	addw	t1,t0,a7
    8d1a:	0685                	addi	a3,a3,1
    8d1c:	0013171b          	slliw	a4,t1,0x1
    8d20:	00a703bb          	addw	t2,a4,a0
    8d24:	0006c503          	lbu	a0,0(a3)
    8d28:	87b6                	mv	a5,a3
    8d2a:	fd03889b          	addiw	a7,t2,-48
    8d2e:	fd05059b          	addiw	a1,a0,-48
    8d32:	0ff5f613          	zext.b	a2,a1
    8d36:	06cfec63          	bltu	t6,a2,8dae <_vsnprintf+0x1ee>
    8d3a:	0028981b          	slliw	a6,a7,0x2
    8d3e:	011808bb          	addw	a7,a6,a7
    8d42:	00189a9b          	slliw	s5,a7,0x1
    8d46:	00aa853b          	addw	a0,s5,a0
    8d4a:	fd05089b          	addiw	a7,a0,-48
    8d4e:	8816c50b          	th.lbuib	a0,(a3),1,0
    8d52:	fd050b9b          	addiw	s7,a0,-48
    8d56:	0ffbfc13          	zext.b	s8,s7
    8d5a:	058fea63          	bltu	t6,s8,8dae <_vsnprintf+0x1ee>
    8d5e:	00289c9b          	slliw	s9,a7,0x2
    8d62:	011c8d3b          	addw	s10,s9,a7
    8d66:	001d1e1b          	slliw	t3,s10,0x1
    8d6a:	00ae0ebb          	addw	t4,t3,a0
    8d6e:	0027c503          	lbu	a0,2(a5)
    8d72:	00278693          	addi	a3,a5,2
    8d76:	fd0e889b          	addiw	a7,t4,-48
    8d7a:	fd050f1b          	addiw	t5,a0,-48
    8d7e:	0fff7293          	zext.b	t0,t5
    8d82:	025fe663          	bltu	t6,t0,8dae <_vsnprintf+0x1ee>
    8d86:	0028931b          	slliw	t1,a7,0x2
    8d8a:	0113073b          	addw	a4,t1,a7
    8d8e:	0017139b          	slliw	t2,a4,0x1
    8d92:	00a385bb          	addw	a1,t2,a0
    8d96:	0037c503          	lbu	a0,3(a5)
    8d9a:	00378693          	addi	a3,a5,3
    8d9e:	fd05889b          	addiw	a7,a1,-48
    8da2:	fd05079b          	addiw	a5,a0,-48
    8da6:	0ff7f613          	zext.b	a2,a5
    8daa:	f6cff4e3          	bgeu	t6,a2,8d12 <_vsnprintf+0x152>
    8dae:	e436                	sd	a3,8(sp)
    8db0:	02e00f93          	li	t6,46
    8db4:	4c01                	li	s8,0
    8db6:	edf511e3          	bne	a0,t6,8c78 <_vsnprintf+0xb8>
    8dba:	6aa2                	ld	s5,8(sp)
    8dbc:	400b6b13          	ori	s6,s6,1024
    8dc0:	4825                	li	a6,9
    8dc2:	001ac503          	lbu	a0,1(s5)
    8dc6:	2b01                	sext.w	s6,s6
    8dc8:	001a8713          	addi	a4,s5,1
    8dcc:	fd050b9b          	addiw	s7,a0,-48
    8dd0:	0ffbfc93          	zext.b	s9,s7
    8dd4:	21987463          	bgeu	a6,s9,8fdc <_vsnprintf+0x41c>
    8dd8:	02a00d13          	li	s10,42
    8ddc:	01a51463          	bne	a0,s10,8de4 <_vsnprintf+0x224>
    8de0:	7c70006f          	j	9da6 <_vsnprintf+0x11e6>
    8de4:	e43a                	sd	a4,8(sp)
    8de6:	bd49                	j	8c78 <_vsnprintf+0xb8>
    8de8:	6382                	ld	t2,0(sp)
    8dea:	6de6                	ld	s11,88(sp)
    8dec:	7d06                	ld	s10,96(sp)
    8dee:	7ca6                	ld	s9,104(sp)
    8df0:	7c46                	ld	s8,112(sp)
    8df2:	7be6                	ld	s7,120(sp)
    8df4:	6b0a                	ld	s6,128(sp)
    8df6:	6aaa                	ld	s5,136(sp)
    8df8:	6a4a                	ld	s4,144(sp)
    8dfa:	0003899b          	sext.w	s3,t2
    8dfe:	0093b7b3          	sltu	a5,t2,s1
    8e02:	fff48613          	addi	a2,s1,-1
    8e06:	86a6                	mv	a3,s1
    8e08:	85ca                	mv	a1,s2
    8e0a:	4501                	li	a0,0
    8e0c:	42f3960b          	th.mvnez	a2,t2,a5
    8e10:	9402                	jalr	s0
    8e12:	70ea                	ld	ra,184(sp)
    8e14:	74aa                	ld	s1,168(sp)
    8e16:	744a                	ld	s0,176(sp)
    8e18:	854e                	mv	a0,s3
    8e1a:	69ea                	ld	s3,152(sp)
    8e1c:	790a                	ld	s2,160(sp)
    8e1e:	6129                	addi	sp,sp,192
    8e20:	8082                	ret
    8e22:	0001                	nop
    8e24:	f9750b9b          	addiw	s7,a0,-105
    8e28:	0ffbfc93          	zext.b	s9,s7
    8e2c:	4d3d                	li	s10,15
    8e2e:	199d6b63          	bltu	s10,s9,8fc4 <_vsnprintf+0x404>
    8e32:	4e05                	li	t3,1
    8e34:	62a5                	lui	t0,0x9
    8e36:	019e1eb3          	sll	t4,t3,s9
    8e3a:	04128693          	addi	a3,t0,65 # 9041 <_vsnprintf+0x481>
    8e3e:	00def7b3          	and	a5,t4,a3
    8e42:	72079de3          	bnez	a5,9d7c <_vsnprintf+0x11bc>
    8e46:	4fa9                	li	t6,10
    8e48:	23fc8a63          	beq	s9,t6,907c <_vsnprintf+0x4bc>
    8e4c:	439d                	li	t2,7
    8e4e:	167c9b63          	bne	s9,t2,8fc4 <_vsnprintf+0x404>
    8e52:	788dc28b          	th.ldia	t0,(s11),8,0
    8e56:	760288e3          	beqz	t0,9dc6 <_vsnprintf+0x1206>
    8e5a:	021b6f13          	ori	t5,s6,33
    8e5e:	000f059b          	sext.w	a1,t5
    8e62:	400b7c93          	andi	s9,s6,1024
    8e66:	010b7b93          	andi	s7,s6,16
    8e6a:	453d                	li	a0,15
    8e6c:	00a2f333          	and	t1,t0,a0
    8e70:	43a5                	li	t2,9
    8e72:	03030d13          	addi	s10,t1,48
    8e76:	03730f13          	addi	t5,t1,55
    8e7a:	0063b633          	sltu	a2,t2,t1
    8e7e:	40cd1f0b          	th.mveqz	t5,s10,a2
    8e82:	03e10823          	sb	t5,48(sp)
    8e86:	03010b13          	addi	s6,sp,48
    8e8a:	02000893          	li	a7,32
    8e8e:	4d05                	li	s10,1
    8e90:	0042d813          	srli	a6,t0,0x4
    8e94:	00556463          	bltu	a0,t0,8e9c <_vsnprintf+0x2dc>
    8e98:	6180106f          	j	a4b0 <_vsnprintf+0x18f0>
    8e9c:	00f87f93          	andi	t6,a6,15
    8ea0:	030f8a93          	addi	s5,t6,48
    8ea4:	037f8e93          	addi	t4,t6,55
    8ea8:	01f3b2b3          	sltu	t0,t2,t6
    8eac:	405a9e8b          	th.mveqz	t4,s5,t0
    8eb0:	03d108a3          	sb	t4,49(sp)
    8eb4:	87ea                	mv	a5,s10
    8eb6:	00485313          	srli	t1,a6,0x4
    8eba:	4d09                	li	s10,2
    8ebc:	01056463          	bltu	a0,a6,8ec4 <_vsnprintf+0x304>
    8ec0:	5f00106f          	j	a4b0 <_vsnprintf+0x18f0>
    8ec4:	00f37f13          	andi	t5,t1,15
    8ec8:	030f0813          	addi	a6,t5,48
    8ecc:	037f0713          	addi	a4,t5,55
    8ed0:	01e3bfb3          	sltu	t6,t2,t5
    8ed4:	41f8170b          	th.mveqz	a4,a6,t6
    8ed8:	02e10923          	sb	a4,50(sp)
    8edc:	87ea                	mv	a5,s10
    8ede:	00435e13          	srli	t3,t1,0x4
    8ee2:	0d05                	addi	s10,s10,1
    8ee4:	00656463          	bltu	a0,t1,8eec <_vsnprintf+0x32c>
    8ee8:	5c80106f          	j	a4b0 <_vsnprintf+0x18f0>
    8eec:	03310613          	addi	a2,sp,51
    8ef0:	87ea                	mv	a5,s10
    8ef2:	8772                	mv	a4,t3
    8ef4:	00000013          	nop
    8ef8:	00f77d13          	andi	s10,a4,15
    8efc:	030d0e93          	addi	t4,s10,48
    8f00:	037d0293          	addi	t0,s10,55
    8f04:	01a3b333          	sltu	t1,t2,s10
    8f08:	406e928b          	th.mveqz	t0,t4,t1
    8f0c:	00560023          	sb	t0,0(a2)
    8f10:	00178d13          	addi	s10,a5,1
    8f14:	00475f13          	srli	t5,a4,0x4
    8f18:	00e56463          	bltu	a0,a4,8f20 <_vsnprintf+0x360>
    8f1c:	5940106f          	j	a4b0 <_vsnprintf+0x18f0>
    8f20:	011d1463          	bne	s10,a7,8f28 <_vsnprintf+0x368>
    8f24:	1750106f          	j	a898 <_vsnprintf+0x1cd8>
    8f28:	00ff7f93          	andi	t6,t5,15
    8f2c:	886a                	mv	a6,s10
    8f2e:	87ea                	mv	a5,s10
    8f30:	030f8e13          	addi	t3,t6,48
    8f34:	01f3bd33          	sltu	s10,t2,t6
    8f38:	037f8a93          	addi	s5,t6,55
    8f3c:	41ae1a8b          	th.mveqz	s5,t3,s10
    8f40:	015600a3          	sb	s5,1(a2)
    8f44:	00180d13          	addi	s10,a6,1
    8f48:	00875e93          	srli	t4,a4,0x8
    8f4c:	01e56463          	bltu	a0,t5,8f54 <_vsnprintf+0x394>
    8f50:	5600106f          	j	a4b0 <_vsnprintf+0x18f0>
    8f54:	00fef313          	andi	t1,t4,15
    8f58:	03030293          	addi	t0,t1,48
    8f5c:	03730f93          	addi	t6,t1,55
    8f60:	0063b6b3          	sltu	a3,t2,t1
    8f64:	40d29f8b          	th.mveqz	t6,t0,a3
    8f68:	01f60123          	sb	t6,2(a2)
    8f6c:	87ea                	mv	a5,s10
    8f6e:	00c75e13          	srli	t3,a4,0xc
    8f72:	0d05                	addi	s10,s10,1
    8f74:	01d56463          	bltu	a0,t4,8f7c <_vsnprintf+0x3bc>
    8f78:	5380106f          	j	a4b0 <_vsnprintf+0x18f0>
    8f7c:	00fe7a93          	andi	s5,t3,15
    8f80:	030a8e93          	addi	t4,s5,48
    8f84:	037a8313          	addi	t1,s5,55
    8f88:	0153bf33          	sltu	t5,t2,s5
    8f8c:	41ee930b          	th.mveqz	t1,t4,t5
    8f90:	006601a3          	sb	t1,3(a2)
    8f94:	00280793          	addi	a5,a6,2
    8f98:	00380d13          	addi	s10,a6,3
    8f9c:	8341                	srli	a4,a4,0x10
    8f9e:	01c56463          	bltu	a0,t3,8fa6 <_vsnprintf+0x3e6>
    8fa2:	50e0106f          	j	a4b0 <_vsnprintf+0x18f0>
    8fa6:	0611                	addi	a2,a2,4
    8fa8:	87ea                	mv	a5,s10
    8faa:	b7b9                	j	8ef8 <_vsnprintf+0x338>
    8fac:	588dc88b          	th.lwia	a7,(s11),8,0
    8fb0:	4e08c463          	bltz	a7,9498 <_vsnprintf+0x8d8>
    8fb4:	6ea2                	ld	t4,8(sp)
    8fb6:	001e8f13          	addi	t5,t4,1
    8fba:	001ec503          	lbu	a0,1(t4)
    8fbe:	e47a                	sd	t5,8(sp)
    8fc0:	b17d                	j	8c6e <_vsnprintf+0xae>
    8fc2:	0001                	nop
    8fc4:	6602                	ld	a2,0(sp)
    8fc6:	86a6                	mv	a3,s1
    8fc8:	85ca                	mv	a1,s2
    8fca:	00160d13          	addi	s10,a2,1
    8fce:	9402                	jalr	s0
    8fd0:	6fa2                	ld	t6,8(sp)
    8fd2:	e06a                	sd	s10,0(sp)
    8fd4:	001f8c93          	addi	s9,t6,1
    8fd8:	b1a1                	j	8c20 <_vsnprintf+0x60>
    8fda:	0001                	nop
    8fdc:	002c129b          	slliw	t0,s8,0x2
    8fe0:	018286bb          	addw	a3,t0,s8
    8fe4:	0705                	addi	a4,a4,1
    8fe6:	0016931b          	slliw	t1,a3,0x1
    8fea:	00a303bb          	addw	t2,t1,a0
    8fee:	00074503          	lbu	a0,0(a4)
    8ff2:	8f3a                	mv	t5,a4
    8ff4:	fd038c1b          	addiw	s8,t2,-48
    8ff8:	fd05059b          	addiw	a1,a0,-48
    8ffc:	0ff5f793          	zext.b	a5,a1
    9000:	def862e3          	bltu	a6,a5,8de4 <_vsnprintf+0x224>
    9004:	002c161b          	slliw	a2,s8,0x2
    9008:	01860fbb          	addw	t6,a2,s8
    900c:	001f9a9b          	slliw	s5,t6,0x1
    9010:	00aa8bbb          	addw	s7,s5,a0
    9014:	8817450b          	th.lbuib	a0,(a4),1,0
    9018:	fd0b8c1b          	addiw	s8,s7,-48
    901c:	fd050c9b          	addiw	s9,a0,-48
    9020:	0ffcfd13          	zext.b	s10,s9
    9024:	dda860e3          	bltu	a6,s10,8de4 <_vsnprintf+0x224>
    9028:	002c1e1b          	slliw	t3,s8,0x2
    902c:	018e0c3b          	addw	s8,t3,s8
    9030:	001c1e9b          	slliw	t4,s8,0x1
    9034:	00ae853b          	addw	a0,t4,a0
    9038:	fd050c1b          	addiw	s8,a0,-48
    903c:	002f4503          	lbu	a0,2(t5)
    9040:	002f0713          	addi	a4,t5,2
    9044:	fd05029b          	addiw	t0,a0,-48
    9048:	0ff2f693          	zext.b	a3,t0
    904c:	d8d86ce3          	bltu	a6,a3,8de4 <_vsnprintf+0x224>
    9050:	002c131b          	slliw	t1,s8,0x2
    9054:	018303bb          	addw	t2,t1,s8
    9058:	0013959b          	slliw	a1,t2,0x1
    905c:	00a587bb          	addw	a5,a1,a0
    9060:	003f4503          	lbu	a0,3(t5)
    9064:	003f0713          	addi	a4,t5,3
    9068:	fd078c1b          	addiw	s8,a5,-48
    906c:	fd050f1b          	addiw	t5,a0,-48
    9070:	0fff7613          	zext.b	a2,t5
    9074:	f6c874e3          	bgeu	a6,a2,8fdc <_vsnprintf+0x41c>
    9078:	e43a                	sd	a4,8(sp)
    907a:	befd                	j	8c78 <_vsnprintf+0xb8>
    907c:	788dcd0b          	th.ldia	s10,(s11),8,0
    9080:	7c0c3a8b          	th.extu	s5,s8,31,0
    9084:	5bfd                	li	s7,-1
    9086:	000d4503          	lbu	a0,0(s10)
    908a:	418b9a8b          	th.mveqz	s5,s7,s8
    908e:	015d0cb3          	add	s9,s10,s5
    9092:	87ea                	mv	a5,s10
    9094:	e119                	bnez	a0,909a <_vsnprintf+0x4da>
    9096:	2650206f          	j	bafa <_vsnprintf+0x2f3a>
    909a:	41ac8eb3          	sub	t4,s9,s10
    909e:	007ef293          	andi	t0,t4,7
    90a2:	04028e63          	beqz	t0,90fe <_vsnprintf+0x53e>
    90a6:	001d4683          	lbu	a3,1(s10)
    90aa:	001d0793          	addi	a5,s10,1
    90ae:	c6d5                	beqz	a3,915a <_vsnprintf+0x59a>
    90b0:	05c28763          	beq	t0,t3,90fe <_vsnprintf+0x53e>
    90b4:	4309                	li	t1,2
    90b6:	04628063          	beq	t0,t1,90f6 <_vsnprintf+0x536>
    90ba:	438d                	li	t2,3
    90bc:	02728963          	beq	t0,t2,90ee <_vsnprintf+0x52e>
    90c0:	4f11                	li	t5,4
    90c2:	03e28263          	beq	t0,t5,90e6 <_vsnprintf+0x526>
    90c6:	4595                	li	a1,5
    90c8:	00b28b63          	beq	t0,a1,90de <_vsnprintf+0x51e>
    90cc:	4619                	li	a2,6
    90ce:	00c28463          	beq	t0,a2,90d6 <_vsnprintf+0x516>
    90d2:	7a90106f          	j	b07a <_vsnprintf+0x24ba>
    90d6:	8817c80b          	th.lbuib	a6,(a5),1,0
    90da:	08080063          	beqz	a6,915a <_vsnprintf+0x59a>
    90de:	8817cf8b          	th.lbuib	t6,(a5),1,0
    90e2:	060f8c63          	beqz	t6,915a <_vsnprintf+0x59a>
    90e6:	8817ca8b          	th.lbuib	s5,(a5),1,0
    90ea:	060a8863          	beqz	s5,915a <_vsnprintf+0x59a>
    90ee:	8817cb8b          	th.lbuib	s7,(a5),1,0
    90f2:	060b8463          	beqz	s7,915a <_vsnprintf+0x59a>
    90f6:	8817ce0b          	th.lbuib	t3,(a5),1,0
    90fa:	060e0063          	beqz	t3,915a <_vsnprintf+0x59a>
    90fe:	00fc9463          	bne	s9,a5,9106 <_vsnprintf+0x546>
    9102:	5480106f          	j	a64a <_vsnprintf+0x1a8a>
    9106:	0017c283          	lbu	t0,1(a5)
    910a:	0785                	addi	a5,a5,1
    910c:	8ebe                	mv	t4,a5
    910e:	04028663          	beqz	t0,915a <_vsnprintf+0x59a>
    9112:	8817c68b          	th.lbuib	a3,(a5),1,0
    9116:	c2b1                	beqz	a3,915a <_vsnprintf+0x59a>
    9118:	002ec303          	lbu	t1,2(t4)
    911c:	002e8793          	addi	a5,t4,2
    9120:	02030d63          	beqz	t1,915a <_vsnprintf+0x59a>
    9124:	003ec383          	lbu	t2,3(t4)
    9128:	003e8793          	addi	a5,t4,3
    912c:	02038763          	beqz	t2,915a <_vsnprintf+0x59a>
    9130:	004ecf03          	lbu	t5,4(t4)
    9134:	004e8793          	addi	a5,t4,4
    9138:	020f0163          	beqz	t5,915a <_vsnprintf+0x59a>
    913c:	005ec583          	lbu	a1,5(t4)
    9140:	005e8793          	addi	a5,t4,5
    9144:	c999                	beqz	a1,915a <_vsnprintf+0x59a>
    9146:	006ec603          	lbu	a2,6(t4)
    914a:	006e8793          	addi	a5,t4,6
    914e:	c611                	beqz	a2,915a <_vsnprintf+0x59a>
    9150:	007ec703          	lbu	a4,7(t4)
    9154:	007e8793          	addi	a5,t4,7
    9158:	f35d                	bnez	a4,90fe <_vsnprintf+0x53e>
    915a:	400b7c93          	andi	s9,s6,1024
    915e:	41a78bbb          	subw	s7,a5,s10
    9162:	000c9463          	bnez	s9,916a <_vsnprintf+0x5aa>
    9166:	4f20106f          	j	a658 <_vsnprintf+0x1a98>
    916a:	018bb833          	sltu	a6,s7,s8
    916e:	002b7f93          	andi	t6,s6,2
    9172:	410c1b8b          	th.mveqz	s7,s8,a6
    9176:	000f9463          	bnez	t6,917e <_vsnprintf+0x5be>
    917a:	7e00206f          	j	b95a <_vsnprintf+0x2d9a>
    917e:	6c82                	ld	s9,0(sp)
    9180:	4a89                	li	s5,2
    9182:	7c0c360b          	th.extu	a2,s8,31,0
    9186:	01960733          	add	a4,a2,s9
    918a:	41970833          	sub	a6,a4,s9
    918e:	00787f93          	andi	t6,a6,7
    9192:	e03a                	sd	a4,0(sp)
    9194:	8c66                	mv	s8,s9
    9196:	419d0b33          	sub	s6,s10,s9
    919a:	0e0f8163          	beqz	t6,927c <_vsnprintf+0x6bc>
    919e:	ec46                	sd	a7,24(sp)
    91a0:	f07e                	sd	t6,32(sp)
    91a2:	86a6                	mv	a3,s1
    91a4:	8666                	mv	a2,s9
    91a6:	85ca                	mv	a1,s2
    91a8:	9402                	jalr	s0
    91aa:	001c8d13          	addi	s10,s9,1
    91ae:	81ab450b          	th.lrbu	a0,s6,s10,0
    91b2:	68e2                	ld	a7,24(sp)
    91b4:	e119                	bnez	a0,91ba <_vsnprintf+0x5fa>
    91b6:	2f00106f          	j	a4a6 <_vsnprintf+0x18e6>
    91ba:	7e82                	ld	t4,32(sp)
    91bc:	4e05                	li	t3,1
    91be:	8c6a                	mv	s8,s10
    91c0:	0bce8e63          	beq	t4,t3,927c <_vsnprintf+0x6bc>
    91c4:	4289                	li	t0,2
    91c6:	085e8e63          	beq	t4,t0,9262 <_vsnprintf+0x6a2>
    91ca:	468d                	li	a3,3
    91cc:	06de8e63          	beq	t4,a3,9248 <_vsnprintf+0x688>
    91d0:	4311                	li	t1,4
    91d2:	046e8e63          	beq	t4,t1,922e <_vsnprintf+0x66e>
    91d6:	4395                	li	t2,5
    91d8:	027e8e63          	beq	t4,t2,9214 <_vsnprintf+0x654>
    91dc:	4f19                	li	t5,6
    91de:	01ee8e63          	beq	t4,t5,91fa <_vsnprintf+0x63a>
    91e2:	8662                	mv	a2,s8
    91e4:	86a6                	mv	a3,s1
    91e6:	85ca                	mv	a1,s2
    91e8:	0d05                	addi	s10,s10,1
    91ea:	9402                	jalr	s0
    91ec:	81ab450b          	th.lrbu	a0,s6,s10,0
    91f0:	68e2                	ld	a7,24(sp)
    91f2:	8c6a                	mv	s8,s10
    91f4:	e119                	bnez	a0,91fa <_vsnprintf+0x63a>
    91f6:	2b00106f          	j	a4a6 <_vsnprintf+0x18e6>
    91fa:	8662                	mv	a2,s8
    91fc:	ec46                	sd	a7,24(sp)
    91fe:	86a6                	mv	a3,s1
    9200:	85ca                	mv	a1,s2
    9202:	0d05                	addi	s10,s10,1
    9204:	9402                	jalr	s0
    9206:	81ab450b          	th.lrbu	a0,s6,s10,0
    920a:	68e2                	ld	a7,24(sp)
    920c:	8c6a                	mv	s8,s10
    920e:	e119                	bnez	a0,9214 <_vsnprintf+0x654>
    9210:	2960106f          	j	a4a6 <_vsnprintf+0x18e6>
    9214:	8662                	mv	a2,s8
    9216:	ec46                	sd	a7,24(sp)
    9218:	86a6                	mv	a3,s1
    921a:	85ca                	mv	a1,s2
    921c:	0d05                	addi	s10,s10,1
    921e:	9402                	jalr	s0
    9220:	81ab450b          	th.lrbu	a0,s6,s10,0
    9224:	68e2                	ld	a7,24(sp)
    9226:	8c6a                	mv	s8,s10
    9228:	e119                	bnez	a0,922e <_vsnprintf+0x66e>
    922a:	27c0106f          	j	a4a6 <_vsnprintf+0x18e6>
    922e:	8662                	mv	a2,s8
    9230:	ec46                	sd	a7,24(sp)
    9232:	86a6                	mv	a3,s1
    9234:	85ca                	mv	a1,s2
    9236:	0d05                	addi	s10,s10,1
    9238:	9402                	jalr	s0
    923a:	81ab450b          	th.lrbu	a0,s6,s10,0
    923e:	68e2                	ld	a7,24(sp)
    9240:	8c6a                	mv	s8,s10
    9242:	e119                	bnez	a0,9248 <_vsnprintf+0x688>
    9244:	2620106f          	j	a4a6 <_vsnprintf+0x18e6>
    9248:	8662                	mv	a2,s8
    924a:	ec46                	sd	a7,24(sp)
    924c:	86a6                	mv	a3,s1
    924e:	85ca                	mv	a1,s2
    9250:	0d05                	addi	s10,s10,1
    9252:	9402                	jalr	s0
    9254:	81ab450b          	th.lrbu	a0,s6,s10,0
    9258:	68e2                	ld	a7,24(sp)
    925a:	8c6a                	mv	s8,s10
    925c:	e119                	bnez	a0,9262 <_vsnprintf+0x6a2>
    925e:	2480106f          	j	a4a6 <_vsnprintf+0x18e6>
    9262:	8662                	mv	a2,s8
    9264:	ec46                	sd	a7,24(sp)
    9266:	86a6                	mv	a3,s1
    9268:	85ca                	mv	a1,s2
    926a:	0d05                	addi	s10,s10,1
    926c:	9402                	jalr	s0
    926e:	81ab450b          	th.lrbu	a0,s6,s10,0
    9272:	68e2                	ld	a7,24(sp)
    9274:	8c6a                	mv	s8,s10
    9276:	e119                	bnez	a0,927c <_vsnprintf+0x6bc>
    9278:	22e0106f          	j	a4a6 <_vsnprintf+0x18e6>
    927c:	8d46                	mv	s10,a7
    927e:	6882                	ld	a7,0(sp)
    9280:	0d888463          	beq	a7,s8,9348 <_vsnprintf+0x788>
    9284:	86a6                	mv	a3,s1
    9286:	8662                	mv	a2,s8
    9288:	85ca                	mv	a1,s2
    928a:	001c0c93          	addi	s9,s8,1
    928e:	9402                	jalr	s0
    9290:	819b450b          	th.lrbu	a0,s6,s9,0
    9294:	e119                	bnez	a0,929a <_vsnprintf+0x6da>
    9296:	20c0106f          	j	a4a2 <_vsnprintf+0x18e2>
    929a:	8666                	mv	a2,s9
    929c:	86a6                	mv	a3,s1
    929e:	85ca                	mv	a1,s2
    92a0:	002c0c93          	addi	s9,s8,2
    92a4:	9402                	jalr	s0
    92a6:	819b450b          	th.lrbu	a0,s6,s9,0
    92aa:	e119                	bnez	a0,92b0 <_vsnprintf+0x6f0>
    92ac:	1f60106f          	j	a4a2 <_vsnprintf+0x18e2>
    92b0:	86a6                	mv	a3,s1
    92b2:	002c0613          	addi	a2,s8,2
    92b6:	85ca                	mv	a1,s2
    92b8:	003c0c93          	addi	s9,s8,3
    92bc:	9402                	jalr	s0
    92be:	819b450b          	th.lrbu	a0,s6,s9,0
    92c2:	e119                	bnez	a0,92c8 <_vsnprintf+0x708>
    92c4:	1de0106f          	j	a4a2 <_vsnprintf+0x18e2>
    92c8:	86a6                	mv	a3,s1
    92ca:	003c0613          	addi	a2,s8,3
    92ce:	85ca                	mv	a1,s2
    92d0:	004c0c93          	addi	s9,s8,4
    92d4:	9402                	jalr	s0
    92d6:	819b450b          	th.lrbu	a0,s6,s9,0
    92da:	e119                	bnez	a0,92e0 <_vsnprintf+0x720>
    92dc:	1c60106f          	j	a4a2 <_vsnprintf+0x18e2>
    92e0:	86a6                	mv	a3,s1
    92e2:	004c0613          	addi	a2,s8,4
    92e6:	85ca                	mv	a1,s2
    92e8:	005c0c93          	addi	s9,s8,5
    92ec:	9402                	jalr	s0
    92ee:	819b450b          	th.lrbu	a0,s6,s9,0
    92f2:	e119                	bnez	a0,92f8 <_vsnprintf+0x738>
    92f4:	1ae0106f          	j	a4a2 <_vsnprintf+0x18e2>
    92f8:	86a6                	mv	a3,s1
    92fa:	005c0613          	addi	a2,s8,5
    92fe:	85ca                	mv	a1,s2
    9300:	006c0c93          	addi	s9,s8,6
    9304:	9402                	jalr	s0
    9306:	819b450b          	th.lrbu	a0,s6,s9,0
    930a:	e119                	bnez	a0,9310 <_vsnprintf+0x750>
    930c:	1960106f          	j	a4a2 <_vsnprintf+0x18e2>
    9310:	86a6                	mv	a3,s1
    9312:	006c0613          	addi	a2,s8,6
    9316:	85ca                	mv	a1,s2
    9318:	007c0c93          	addi	s9,s8,7
    931c:	9402                	jalr	s0
    931e:	819b450b          	th.lrbu	a0,s6,s9,0
    9322:	e119                	bnez	a0,9328 <_vsnprintf+0x768>
    9324:	17e0106f          	j	a4a2 <_vsnprintf+0x18e2>
    9328:	86a6                	mv	a3,s1
    932a:	007c0613          	addi	a2,s8,7
    932e:	85ca                	mv	a1,s2
    9330:	008c0c93          	addi	s9,s8,8
    9334:	9402                	jalr	s0
    9336:	819b450b          	th.lrbu	a0,s6,s9,0
    933a:	e119                	bnez	a0,9340 <_vsnprintf+0x780>
    933c:	1660106f          	j	a4a2 <_vsnprintf+0x18e2>
    9340:	6882                	ld	a7,0(sp)
    9342:	8c66                	mv	s8,s9
    9344:	f58890e3          	bne	a7,s8,9284 <_vsnprintf+0x6c4>
    9348:	88ea                	mv	a7,s10
    934a:	000a9463          	bnez	s5,9352 <_vsnprintf+0x792>
    934e:	14a0106f          	j	a498 <_vsnprintf+0x18d8>
    9352:	6b02                	ld	s6,0(sp)
    9354:	011be463          	bltu	s7,a7,935c <_vsnprintf+0x79c>
    9358:	1400106f          	j	a498 <_vsnprintf+0x18d8>
    935c:	6a82                	ld	s5,0(sp)
    935e:	fff8851b          	addiw	a0,a7,-1
    9362:	417505bb          	subw	a1,a0,s7
    9366:	7c05b78b          	th.extu	a5,a1,31,0
    936a:	001a8b93          	addi	s7,s5,1
    936e:	01778c33          	add	s8,a5,s7
    9372:	416c0633          	sub	a2,s8,s6
    9376:	e062                	sd	s8,0(sp)
    9378:	00767813          	andi	a6,a2,7
    937c:	08080a63          	beqz	a6,9410 <_vsnprintf+0x850>
    9380:	4705                	li	a4,1
    9382:	06e80b63          	beq	a6,a4,93f8 <_vsnprintf+0x838>
    9386:	4f89                	li	t6,2
    9388:	07f80163          	beq	a6,t6,93ea <_vsnprintf+0x82a>
    938c:	4e0d                	li	t3,3
    938e:	05c80763          	beq	a6,t3,93dc <_vsnprintf+0x81c>
    9392:	4e91                	li	t4,4
    9394:	03d80d63          	beq	a6,t4,93ce <_vsnprintf+0x80e>
    9398:	4295                	li	t0,5
    939a:	02580363          	beq	a6,t0,93c0 <_vsnprintf+0x800>
    939e:	4699                	li	a3,6
    93a0:	00d80963          	beq	a6,a3,93b2 <_vsnprintf+0x7f2>
    93a4:	865a                	mv	a2,s6
    93a6:	86a6                	mv	a3,s1
    93a8:	85ca                	mv	a1,s2
    93aa:	02000513          	li	a0,32
    93ae:	0b05                	addi	s6,s6,1
    93b0:	9402                	jalr	s0
    93b2:	865a                	mv	a2,s6
    93b4:	86a6                	mv	a3,s1
    93b6:	85ca                	mv	a1,s2
    93b8:	02000513          	li	a0,32
    93bc:	0b05                	addi	s6,s6,1
    93be:	9402                	jalr	s0
    93c0:	865a                	mv	a2,s6
    93c2:	86a6                	mv	a3,s1
    93c4:	85ca                	mv	a1,s2
    93c6:	02000513          	li	a0,32
    93ca:	0b05                	addi	s6,s6,1
    93cc:	9402                	jalr	s0
    93ce:	865a                	mv	a2,s6
    93d0:	86a6                	mv	a3,s1
    93d2:	85ca                	mv	a1,s2
    93d4:	02000513          	li	a0,32
    93d8:	0b05                	addi	s6,s6,1
    93da:	9402                	jalr	s0
    93dc:	865a                	mv	a2,s6
    93de:	86a6                	mv	a3,s1
    93e0:	85ca                	mv	a1,s2
    93e2:	02000513          	li	a0,32
    93e6:	0b05                	addi	s6,s6,1
    93e8:	9402                	jalr	s0
    93ea:	865a                	mv	a2,s6
    93ec:	86a6                	mv	a3,s1
    93ee:	85ca                	mv	a1,s2
    93f0:	02000513          	li	a0,32
    93f4:	0b05                	addi	s6,s6,1
    93f6:	9402                	jalr	s0
    93f8:	865a                	mv	a2,s6
    93fa:	86a6                	mv	a3,s1
    93fc:	85ca                	mv	a1,s2
    93fe:	02000513          	li	a0,32
    9402:	9402                	jalr	s0
    9404:	6302                	ld	t1,0(sp)
    9406:	0b05                	addi	s6,s6,1
    9408:	006b1463          	bne	s6,t1,9410 <_vsnprintf+0x850>
    940c:	08c0106f          	j	a498 <_vsnprintf+0x18d8>
    9410:	865a                	mv	a2,s6
    9412:	86a6                	mv	a3,s1
    9414:	85ca                	mv	a1,s2
    9416:	02000513          	li	a0,32
    941a:	9402                	jalr	s0
    941c:	001b0d13          	addi	s10,s6,1
    9420:	866a                	mv	a2,s10
    9422:	86a6                	mv	a3,s1
    9424:	85ca                	mv	a1,s2
    9426:	02000513          	li	a0,32
    942a:	9402                	jalr	s0
    942c:	002b0c93          	addi	s9,s6,2
    9430:	8666                	mv	a2,s9
    9432:	86a6                	mv	a3,s1
    9434:	85ca                	mv	a1,s2
    9436:	02000513          	li	a0,32
    943a:	9402                	jalr	s0
    943c:	003b0a93          	addi	s5,s6,3
    9440:	86a6                	mv	a3,s1
    9442:	8656                	mv	a2,s5
    9444:	85ca                	mv	a1,s2
    9446:	02000513          	li	a0,32
    944a:	9402                	jalr	s0
    944c:	004b0b93          	addi	s7,s6,4
    9450:	86a6                	mv	a3,s1
    9452:	865e                	mv	a2,s7
    9454:	85ca                	mv	a1,s2
    9456:	02000513          	li	a0,32
    945a:	9402                	jalr	s0
    945c:	005b0c13          	addi	s8,s6,5
    9460:	86a6                	mv	a3,s1
    9462:	8662                	mv	a2,s8
    9464:	85ca                	mv	a1,s2
    9466:	02000513          	li	a0,32
    946a:	9402                	jalr	s0
    946c:	006b0d13          	addi	s10,s6,6
    9470:	86a6                	mv	a3,s1
    9472:	866a                	mv	a2,s10
    9474:	85ca                	mv	a1,s2
    9476:	02000513          	li	a0,32
    947a:	9402                	jalr	s0
    947c:	007b0c93          	addi	s9,s6,7
    9480:	86a6                	mv	a3,s1
    9482:	8666                	mv	a2,s9
    9484:	85ca                	mv	a1,s2
    9486:	02000513          	li	a0,32
    948a:	9402                	jalr	s0
    948c:	6302                	ld	t1,0(sp)
    948e:	0b21                	addi	s6,s6,8
    9490:	f86b10e3          	bne	s6,t1,9410 <_vsnprintf+0x850>
    9494:	0040106f          	j	a498 <_vsnprintf+0x18d8>
    9498:	6ea2                	ld	t4,8(sp)
    949a:	002b6e13          	ori	t3,s6,2
    949e:	000e0b1b          	sext.w	s6,t3
    94a2:	001e8f13          	addi	t5,t4,1
    94a6:	001ec503          	lbu	a0,1(t4)
    94aa:	411008bb          	negw	a7,a7
    94ae:	e47a                	sd	t5,8(sp)
    94b0:	fbeff06f          	j	8c6e <_vsnprintf+0xae>
    94b4:	6e22                	ld	t3,8(sp)
    94b6:	06c00d13          	li	s10,108
    94ba:	001e4503          	lbu	a0,1(t3)
    94be:	01a51463          	bne	a0,s10,94c6 <_vsnprintf+0x906>
    94c2:	25e0106f          	j	a720 <_vsnprintf+0x1b60>
    94c6:	100b6b13          	ori	s6,s6,256
    94ca:	001e0e93          	addi	t4,t3,1
    94ce:	2b01                	sext.w	s6,s6
    94d0:	e476                	sd	t4,8(sp)
    94d2:	b039                	j	8ce0 <_vsnprintf+0x120>
    94d4:	67a2                	ld	a5,8(sp)
    94d6:	06800593          	li	a1,104
    94da:	0017c503          	lbu	a0,1(a5)
    94de:	00b51463          	bne	a0,a1,94e6 <_vsnprintf+0x926>
    94e2:	2280106f          	j	a70a <_vsnprintf+0x1b4a>
    94e6:	080b6f13          	ori	t5,s6,128
    94ea:	00178613          	addi	a2,a5,1
    94ee:	000f0b1b          	sext.w	s6,t5
    94f2:	e432                	sd	a2,8(sp)
    94f4:	fecff06f          	j	8ce0 <_vsnprintf+0x120>
    94f8:	06700693          	li	a3,103
    94fc:	0ed503e3          	beq	a0,a3,9de2 <_vsnprintf+0x1222>
    9500:	04700f13          	li	t5,71
    9504:	01e51463          	bne	a0,t5,950c <_vsnprintf+0x94c>
    9508:	1280106f          	j	a630 <_vsnprintf+0x1a70>
    950c:	04500713          	li	a4,69
    9510:	00e51463          	bne	a0,a4,9518 <_vsnprintf+0x958>
    9514:	12a0106f          	j	a63e <_vsnprintf+0x1a7e>
    9518:	000db507          	fld	fa0,0(s11)
    951c:	008d8b93          	addi	s7,s11,8
    9520:	a2a52dd3          	feq.d	s11,fa0,fa0
    9524:	000d9463          	bnez	s11,952c <_vsnprintf+0x96c>
    9528:	0e80106f          	j	a610 <_vsnprintf+0x1a50>
    952c:	6d45                	lui	s10,0x11
    952e:	bc8d3787          	fld	fa5,-1080(s10) # 10bc8 <errpat+0x58>
    9532:	a2a793d3          	flt.d	t2,fa5,fa0
    9536:	00038463          	beqz	t2,953e <_vsnprintf+0x97e>
    953a:	0d60106f          	j	a610 <_vsnprintf+0x1a50>
    953e:	6ac5                	lui	s5,0x11
    9540:	bc0ab007          	fld	ft0,-1088(s5) # 10bc0 <errpat+0x50>
    9544:	a20517d3          	flt.d	a5,fa0,ft0
    9548:	c399                	beqz	a5,954e <_vsnprintf+0x98e>
    954a:	0c60106f          	j	a610 <_vsnprintf+0x1a50>
    954e:	f20000d3          	fmv.d.x	ft1,zero
    9552:	a2151ed3          	flt.d	t4,fa0,ft1
    9556:	e20506d3          	fmv.x.d	a3,fa0
    955a:	000e8663          	beqz	t4,9566 <_vsnprintf+0x9a6>
    955e:	22a51153          	fneg.d	ft2,fa0
    9562:	e20106d3          	fmv.x.d	a3,ft2
    9566:	400b7f93          	andi	t6,s6,1024
    956a:	4719                	li	a4,6
    956c:	6f45                	lui	t5,0x11
    956e:	6545                	lui	a0,0x11
    9570:	43fc170b          	th.mvnez	a4,s8,t6
    9574:	fb46bc0b          	th.extu	s8,a3,62,52
    9578:	be0f3687          	fld	fa3,-1056(t5) # 10be0 <errpat+0x70>
    957c:	be853707          	fld	fa4,-1048(a0) # 10be8 <errpat+0x78>
    9580:	c01c059b          	addiw	a1,s8,-1023
    9584:	d20581d3          	fcvt.d.w	ft3,a1
    9588:	3ff00293          	li	t0,1023
    958c:	6645                	lui	a2,0x11
    958e:	bf063287          	fld	ft5,-1040(a2) # 10bf0 <errpat+0x80>
    9592:	03429313          	slli	t1,t0,0x34
    9596:	cc06b80b          	th.extu	a6,a3,51,0
    959a:	72d1f243          	fmadd.d	ft4,ft3,fa3,fa4
    959e:	00686e33          	or	t3,a6,t1
    95a2:	f20e0353          	fmv.d.x	ft6,t3
    95a6:	6cc5                	lui	s9,0x11
    95a8:	0a5373d3          	fsub.d	ft7,ft6,ft5
    95ac:	bf8cb587          	fld	fa1,-1032(s9) # 10bf8 <errpat+0x88>
    95b0:	63c5                	lui	t2,0x11
    95b2:	6ac5                	lui	s5,0x11
    95b4:	22b3f643          	fmadd.d	fa2,ft7,fa1,ft4
    95b8:	c003b887          	fld	fa7,-1024(t2) # 10c00 <errpat+0x90>
    95bc:	c08abe07          	fld	ft8,-1016(s5) # 10c08 <errpat+0x98>
    95c0:	6ec5                	lui	t4,0x11
    95c2:	c10ebf87          	fld	ft11,-1008(t4) # 10c10 <errpat+0xa0>
    95c6:	c2061d53          	fcvt.w.d	s10,fa2,rtz
    95ca:	6c45                	lui	s8,0x11
    95cc:	d20d0853          	fcvt.d.w	fa6,s10
    95d0:	c18c3007          	fld	ft0,-1000(s8) # 10c18 <errpat+0xa8>
    95d4:	e3187ec3          	fmadd.d	ft9,fa6,fa7,ft8
    95d8:	65c5                	lui	a1,0x11
    95da:	c205b687          	fld	fa3,-992(a1) # 10c20 <errpat+0xb0>
    95de:	6f45                	lui	t5,0x11
    95e0:	ba8f3207          	fld	ft4,-1112(t5) # 10ba8 <errpat+0x38>
    95e4:	c20e97d3          	fcvt.w.d	a5,ft9,rtz
    95e8:	6545                	lui	a0,0x11
    95ea:	d2078f53          	fcvt.d.w	ft10,a5
    95ee:	c2853387          	fld	ft7,-984(a0) # 10c28 <errpat+0xb8>
    95f2:	13ff77d3          	fmul.d	fa5,ft10,ft11
    95f6:	6845                	lui	a6,0x11
    95f8:	62c5                	lui	t0,0x11
    95fa:	bb82bf07          	fld	ft10,-1096(t0) # 10bb8 <errpat+0x48>
    95fe:	7a0870c7          	fmsub.d	ft1,fa6,ft0,fa5
    9602:	c3083807          	fld	fa6,-976(a6) # 10c30 <errpat+0xc0>
    9606:	3ff7831b          	addiw	t1,a5,1023
    960a:	03431e13          	slli	t3,t1,0x34
    960e:	f20e07d3          	fmv.d.x	fa5,t3
    9612:	1210f153          	fmul.d	ft2,ft1,ft1
    9616:	0a1878d3          	fsub.d	fa7,fa6,ft1
    961a:	0210f1d3          	fadd.d	ft3,ft1,ft1
    961e:	f2068053          	fmv.d.x	ft0,a3
    9622:	1ad17753          	fdiv.d	fa4,ft2,fa3
    9626:	000d0d9b          	sext.w	s11,s10
    962a:	024772d3          	fadd.d	ft5,fa4,ft4
    962e:	1a517353          	fdiv.d	ft6,ft2,ft5
    9632:	027375d3          	fadd.d	fa1,ft6,ft7
    9636:	1ab17653          	fdiv.d	fa2,ft2,fa1
    963a:	03167e53          	fadd.d	ft8,fa2,fa7
    963e:	1bc1fed3          	fdiv.d	ft9,ft3,ft8
    9642:	03eeffd3          	fadd.d	ft11,ft9,ft10
    9646:	12fff0d3          	fmul.d	ft1,ft11,fa5
    964a:	a2101653          	flt.d	a2,ft0,ft1
    964e:	c609                	beqz	a2,9658 <_vsnprintf+0xa98>
    9650:	1a40f0d3          	fdiv.d	ft1,ft1,ft4
    9654:	fffd0d9b          	addiw	s11,s10,-1
    9658:	0c600d13          	li	s10,198
    965c:	063d8c9b          	addiw	s9,s11,99
    9660:	73ad0793          	addi	a5,s10,1850
    9664:	019d33b3          	sltu	t2,s10,s9
    9668:	00fb77b3          	and	a5,s6,a5
    966c:	00438e13          	addi	t3,t2,4
    9670:	8ada                	mv	s5,s6
    9672:	e399                	bnez	a5,9678 <_vsnprintf+0xab8>
    9674:	0990106f          	j	af0c <_vsnprintf+0x234c>
    9678:	6c45                	lui	s8,0x11
    967a:	c38c3107          	fld	ft2,-968(s8) # 10c38 <errpat+0xc8>
    967e:	f20681d3          	fmv.d.x	ft3,a3
    9682:	a23105d3          	fle.d	a1,ft2,ft3
    9686:	e199                	bnez	a1,968c <_vsnprintf+0xacc>
    9688:	4a00206f          	j	bb28 <_vsnprintf+0x2f68>
    968c:	6f45                	lui	t5,0x11
    968e:	c40f3707          	fld	fa4,-960(t5) # 10c40 <errpat+0xd0>
    9692:	a2e19553          	flt.d	a0,ft3,fa4
    9696:	e119                	bnez	a0,969c <_vsnprintf+0xadc>
    9698:	4900206f          	j	bb28 <_vsnprintf+0x2f68>
    969c:	41b70e3b          	subw	t3,a4,s11
    96a0:	fffe061b          	addiw	a2,t3,-1
    96a4:	00eda733          	slt	a4,s11,a4
    96a8:	40e0160b          	th.mveqz	a2,zero,a4
    96ac:	400b6c93          	ori	s9,s6,1024
    96b0:	8732                	mv	a4,a2
    96b2:	8db2                	mv	s11,a2
    96b4:	000c8d1b          	sext.w	s10,s9
    96b8:	002b7a93          	andi	s5,s6,2
    96bc:	00089463          	bnez	a7,96c4 <_vsnprintf+0xb04>
    96c0:	4d20406f          	j	db92 <_vsnprintf+0x4fd2>
    96c4:	000a9463          	bnez	s5,96cc <_vsnprintf+0xb0c>
    96c8:	4ca0406f          	j	db92 <_vsnprintf+0x4fd2>
    96cc:	87c6                	mv	a5,a7
    96ce:	8b6a                	mv	s6,s10
    96d0:	4d81                	li	s11,0
    96d2:	4a89                	li	s5,2
    96d4:	4e01                	li	t3,0
    96d6:	f20003d3          	fmv.d.x	ft7,zero
    96da:	a2751c53          	flt.d	s8,fa0,ft7
    96de:	000c0463          	beqz	s8,96e6 <_vsnprintf+0xb26>
    96e2:	5e10106f          	j	b4c2 <_vsnprintf+0x2902>
    96e6:	75fd                	lui	a1,0xfffff
    96e8:	7ff58f13          	addi	t5,a1,2047 # fffffffffffff7ff <__kernel_stack+0xfffffffffff117ff>
    96ec:	6602                	ld	a2,0(sp)
    96ee:	01eb7533          	and	a0,s6,t5
    96f2:	0005081b          	sext.w	a6,a0
    96f6:	f2068553          	fmv.d.x	fa0,a3
    96fa:	85ca                	mv	a1,s2
    96fc:	86a6                	mv	a3,s1
    96fe:	8522                	mv	a0,s0
    9700:	ec72                	sd	t3,24(sp)
    9702:	f046                	sd	a7,32(sp)
    9704:	a2dfd0ef          	jal	7130 <_ftoa>
    9708:	68e2                	ld	a7,24(sp)
    970a:	862a                	mv	a2,a0
    970c:	00089463          	bnez	a7,9714 <_vsnprintf+0xb54>
    9710:	4ff0106f          	j	b40e <_vsnprintf+0x284e>
    9714:	020b7813          	andi	a6,s6,32
    9718:	06500293          	li	t0,101
    971c:	00150c93          	addi	s9,a0,1
    9720:	04500513          	li	a0,69
    9724:	86a6                	mv	a3,s1
    9726:	4102950b          	th.mveqz	a0,t0,a6
    972a:	f432                	sd	a2,40(sp)
    972c:	85ca                	mv	a1,s2
    972e:	9402                	jalr	s0
    9730:	41fdd31b          	sraiw	t1,s11,0x1f
    9734:	006dc633          	xor	a2,s11,t1
    9738:	4066073b          	subw	a4,a2,t1
    973c:	43a9                	li	t2,10
    973e:	02777fb3          	remu	t6,a4,t2
    9742:	03010d13          	addi	s10,sp,48
    9746:	47a5                	li	a5,9
    9748:	6e62                	ld	t3,24(sp)
    974a:	fdd1488b          	th.ldd	a7,t4,(sp),2,4
    974e:	86ea                	mv	a3,s10
    9750:	030f8b1b          	addiw	s6,t6,48
    9754:	03610823          	sb	s6,48(sp)
    9758:	02775533          	divu	a0,a4,t2
    975c:	10e7fa63          	bgeu	a5,a4,9870 <_vsnprintf+0xcb0>
    9760:	03110693          	addi	a3,sp,49
    9764:	02757c33          	remu	s8,a0,t2
    9768:	030c059b          	addiw	a1,s8,48
    976c:	00b68023          	sb	a1,0(a3)
    9770:	02755f33          	divu	t5,a0,t2
    9774:	0ea7fe63          	bgeu	a5,a0,9870 <_vsnprintf+0xcb0>
    9778:	00168293          	addi	t0,a3,1
    977c:	0888                	addi	a0,sp,80
    977e:	0e550963          	beq	a0,t0,9870 <_vsnprintf+0xcb0>
    9782:	8696                	mv	a3,t0
    9784:	027f7833          	remu	a6,t5,t2
    9788:	0308031b          	addiw	t1,a6,48
    978c:	00628023          	sb	t1,0(t0)
    9790:	027f5633          	divu	a2,t5,t2
    9794:	0de7fe63          	bgeu	a5,t5,9870 <_vsnprintf+0xcb0>
    9798:	02767733          	remu	a4,a2,t2
    979c:	03070f9b          	addiw	t6,a4,48
    97a0:	0816df8b          	th.sbib	t6,(a3),1,0
    97a4:	02765b33          	divu	s6,a2,t2
    97a8:	0cc7f463          	bgeu	a5,a2,9870 <_vsnprintf+0xcb0>
    97ac:	00228693          	addi	a3,t0,2
    97b0:	027b7c33          	remu	s8,s6,t2
    97b4:	030c059b          	addiw	a1,s8,48
    97b8:	00b28123          	sb	a1,2(t0)
    97bc:	027b5f33          	divu	t5,s6,t2
    97c0:	0b67f863          	bgeu	a5,s6,9870 <_vsnprintf+0xcb0>
    97c4:	00328693          	addi	a3,t0,3
    97c8:	027f7533          	remu	a0,t5,t2
    97cc:	0305081b          	addiw	a6,a0,48
    97d0:	010281a3          	sb	a6,3(t0)
    97d4:	027f5333          	divu	t1,t5,t2
    97d8:	09e7fc63          	bgeu	a5,t5,9870 <_vsnprintf+0xcb0>
    97dc:	00428693          	addi	a3,t0,4
    97e0:	02737633          	remu	a2,t1,t2
    97e4:	0306071b          	addiw	a4,a2,48
    97e8:	00e28223          	sb	a4,4(t0)
    97ec:	02735fb3          	divu	t6,t1,t2
    97f0:	0867f063          	bgeu	a5,t1,9870 <_vsnprintf+0xcb0>
    97f4:	00528693          	addi	a3,t0,5
    97f8:	027ffb33          	remu	s6,t6,t2
    97fc:	030b0c1b          	addiw	s8,s6,48
    9800:	018282a3          	sb	s8,5(t0)
    9804:	027fd5b3          	divu	a1,t6,t2
    9808:	07f7f463          	bgeu	a5,t6,9870 <_vsnprintf+0xcb0>
    980c:	00628693          	addi	a3,t0,6
    9810:	0275ff33          	remu	t5,a1,t2
    9814:	030f051b          	addiw	a0,t5,48
    9818:	00a28323          	sb	a0,6(t0)
    981c:	0275d333          	divu	t1,a1,t2
    9820:	04b7f863          	bgeu	a5,a1,9870 <_vsnprintf+0xcb0>
    9824:	00728693          	addi	a3,t0,7
    9828:	02737833          	remu	a6,t1,t2
    982c:	0308061b          	addiw	a2,a6,48
    9830:	00c283a3          	sb	a2,7(t0)
    9834:	02735733          	divu	a4,t1,t2
    9838:	0267fc63          	bgeu	a5,t1,9870 <_vsnprintf+0xcb0>
    983c:	00828693          	addi	a3,t0,8
    9840:	02777fb3          	remu	t6,a4,t2
    9844:	030f8b1b          	addiw	s6,t6,48
    9848:	01628423          	sb	s6,8(t0)
    984c:	02775533          	divu	a0,a4,t2
    9850:	02e7f063          	bgeu	a5,a4,9870 <_vsnprintf+0xcb0>
    9854:	00928693          	addi	a3,t0,9
    9858:	02757c33          	remu	s8,a0,t2
    985c:	030c059b          	addiw	a1,s8,48
    9860:	00b68023          	sb	a1,0(a3)
    9864:	02755f33          	divu	t5,a0,t2
    9868:	f0a7e8e3          	bltu	a5,a0,9778 <_vsnprintf+0xbb8>
    986c:	00000013          	nop
    9870:	4385                	li	t2,1
    9872:	41a387b3          	sub	a5,t2,s10
    9876:	00d78c33          	add	s8,a5,a3
    987a:	ffee069b          	addiw	a3,t3,-2
    987e:	7c06b28b          	th.extu	t0,a3,31,0
    9882:	005c6463          	bltu	s8,t0,988a <_vsnprintf+0xcca>
    9886:	0640306f          	j	c8ea <_vsnprintf+0x3d2a>
    988a:	018d07b3          	add	a5,s10,s8
    988e:	005d0f33          	add	t5,s10,t0
    9892:	40ff05b3          	sub	a1,t5,a5
    9896:	0075f613          	andi	a2,a1,7
    989a:	03000313          	li	t1,48
    989e:	e219                	bnez	a2,98a4 <_vsnprintf+0xce4>
    98a0:	3330106f          	j	b3d2 <_vsnprintf+0x2812>
    98a4:	02760e63          	beq	a2,t2,98e0 <_vsnprintf+0xd20>
    98a8:	4809                	li	a6,2
    98aa:	03060963          	beq	a2,a6,98dc <_vsnprintf+0xd1c>
    98ae:	470d                	li	a4,3
    98b0:	02e60463          	beq	a2,a4,98d8 <_vsnprintf+0xd18>
    98b4:	4f91                	li	t6,4
    98b6:	01f60f63          	beq	a2,t6,98d4 <_vsnprintf+0xd14>
    98ba:	4b15                	li	s6,5
    98bc:	01660a63          	beq	a2,s6,98d0 <_vsnprintf+0xd10>
    98c0:	4519                	li	a0,6
    98c2:	00a60563          	beq	a2,a0,98cc <_vsnprintf+0xd0c>
    98c6:	018d530b          	th.srb	t1,s10,s8,0
    98ca:	0785                	addi	a5,a5,1
    98cc:	1817d30b          	th.sbia	t1,(a5),1,0
    98d0:	1817d30b          	th.sbia	t1,(a5),1,0
    98d4:	1817d30b          	th.sbia	t1,(a5),1,0
    98d8:	1817d30b          	th.sbia	t1,(a5),1,0
    98dc:	1817d30b          	th.sbia	t1,(a5),1,0
    98e0:	1817d30b          	th.sbia	t1,(a5),1,0
    98e4:	01e78463          	beq	a5,t5,98ec <_vsnprintf+0xd2c>
    98e8:	2eb0106f          	j	b3d2 <_vsnprintf+0x2812>
    98ec:	02028393          	addi	t2,t0,32
    98f0:	1814                	addi	a3,sp,48
    98f2:	00128c13          	addi	s8,t0,1
    98f6:	00d38e33          	add	t3,t2,a3
    98fa:	000dc463          	bltz	s11,9902 <_vsnprintf+0xd42>
    98fe:	5a70306f          	j	d6a4 <_vsnprintf+0x4ae4>
    9902:	02d00513          	li	a0,45
    9906:	feae0023          	sb	a0,-32(t3)
    990a:	018d0db3          	add	s11,s10,s8
    990e:	fffd4f13          	not	t5,s10
    9912:	001d0293          	addi	t0,s10,1
    9916:	01bf0333          	add	t1,t5,s11
    991a:	9e96                	add	t4,t4,t0
    991c:	00737813          	andi	a6,t1,7
    9920:	018e8b33          	add	s6,t4,s8
    9924:	00081463          	bnez	a6,992c <_vsnprintf+0xd6c>
    9928:	5e10306f          	j	d708 <_vsnprintf+0x4b48>
    992c:	41bb0633          	sub	a2,s6,s11
    9930:	ec46                	sd	a7,24(sp)
    9932:	f042                	sd	a6,32(sp)
    9934:	85ca                	mv	a1,s2
    9936:	86a6                	mv	a3,s1
    9938:	9402                	jalr	s0
    993a:	68e2                	ld	a7,24(sp)
    993c:	7602                	ld	a2,32(sp)
    993e:	4585                	li	a1,1
    9940:	1dfd                	addi	s11,s11,-1
    9942:	fffdc503          	lbu	a0,-1(s11)
    9946:	00b61463          	bne	a2,a1,994e <_vsnprintf+0xd8e>
    994a:	5bf0306f          	j	d708 <_vsnprintf+0x4b48>
    994e:	4709                	li	a4,2
    9950:	06e60f63          	beq	a2,a4,99ce <_vsnprintf+0xe0e>
    9954:	4f8d                	li	t6,3
    9956:	07f60263          	beq	a2,t6,99ba <_vsnprintf+0xdfa>
    995a:	4791                	li	a5,4
    995c:	04f60563          	beq	a2,a5,99a6 <_vsnprintf+0xde6>
    9960:	4395                	li	t2,5
    9962:	02760863          	beq	a2,t2,9992 <_vsnprintf+0xdd2>
    9966:	4699                	li	a3,6
    9968:	00d60b63          	beq	a2,a3,997e <_vsnprintf+0xdbe>
    996c:	41bb0633          	sub	a2,s6,s11
    9970:	86a6                	mv	a3,s1
    9972:	85ca                	mv	a1,s2
    9974:	9402                	jalr	s0
    9976:	68e2                	ld	a7,24(sp)
    9978:	ffedc503          	lbu	a0,-2(s11)
    997c:	1dfd                	addi	s11,s11,-1
    997e:	41bb0633          	sub	a2,s6,s11
    9982:	ec46                	sd	a7,24(sp)
    9984:	86a6                	mv	a3,s1
    9986:	85ca                	mv	a1,s2
    9988:	9402                	jalr	s0
    998a:	68e2                	ld	a7,24(sp)
    998c:	ffedc503          	lbu	a0,-2(s11)
    9990:	1dfd                	addi	s11,s11,-1
    9992:	41bb0633          	sub	a2,s6,s11
    9996:	ec46                	sd	a7,24(sp)
    9998:	86a6                	mv	a3,s1
    999a:	85ca                	mv	a1,s2
    999c:	9402                	jalr	s0
    999e:	68e2                	ld	a7,24(sp)
    99a0:	ffedc503          	lbu	a0,-2(s11)
    99a4:	1dfd                	addi	s11,s11,-1
    99a6:	41bb0633          	sub	a2,s6,s11
    99aa:	ec46                	sd	a7,24(sp)
    99ac:	86a6                	mv	a3,s1
    99ae:	85ca                	mv	a1,s2
    99b0:	9402                	jalr	s0
    99b2:	68e2                	ld	a7,24(sp)
    99b4:	ffedc503          	lbu	a0,-2(s11)
    99b8:	1dfd                	addi	s11,s11,-1
    99ba:	41bb0633          	sub	a2,s6,s11
    99be:	ec46                	sd	a7,24(sp)
    99c0:	86a6                	mv	a3,s1
    99c2:	85ca                	mv	a1,s2
    99c4:	9402                	jalr	s0
    99c6:	68e2                	ld	a7,24(sp)
    99c8:	ffedc503          	lbu	a0,-2(s11)
    99cc:	1dfd                	addi	s11,s11,-1
    99ce:	41bb0633          	sub	a2,s6,s11
    99d2:	86a6                	mv	a3,s1
    99d4:	85ca                	mv	a1,s2
    99d6:	ec46                	sd	a7,24(sp)
    99d8:	9402                	jalr	s0
    99da:	1dfd                	addi	s11,s11,-1
    99dc:	fd515b8b          	th.sdd	s7,s5,(sp),2,4
    99e0:	fffdc503          	lbu	a0,-1(s11)
    99e4:	a895                	j	9a58 <_vsnprintf+0xe98>
    99e6:	8bee                	mv	s7,s11
    99e8:	89ebc50b          	th.lbuib	a0,(s7),-2,0
    99ec:	415b0633          	sub	a2,s6,s5
    99f0:	86a6                	mv	a3,s1
    99f2:	85ca                	mv	a1,s2
    99f4:	9402                	jalr	s0
    99f6:	8aee                	mv	s5,s11
    99f8:	89dac50b          	th.lbuib	a0,(s5),-3,0
    99fc:	417b0633          	sub	a2,s6,s7
    9a00:	86a6                	mv	a3,s1
    9a02:	85ca                	mv	a1,s2
    9a04:	9402                	jalr	s0
    9a06:	8bee                	mv	s7,s11
    9a08:	89cbc50b          	th.lbuib	a0,(s7),-4,0
    9a0c:	415b0633          	sub	a2,s6,s5
    9a10:	86a6                	mv	a3,s1
    9a12:	85ca                	mv	a1,s2
    9a14:	9402                	jalr	s0
    9a16:	8aee                	mv	s5,s11
    9a18:	89bac50b          	th.lbuib	a0,(s5),-5,0
    9a1c:	417b0633          	sub	a2,s6,s7
    9a20:	86a6                	mv	a3,s1
    9a22:	85ca                	mv	a1,s2
    9a24:	9402                	jalr	s0
    9a26:	8bee                	mv	s7,s11
    9a28:	89abc50b          	th.lbuib	a0,(s7),-6,0
    9a2c:	415b0633          	sub	a2,s6,s5
    9a30:	86a6                	mv	a3,s1
    9a32:	85ca                	mv	a1,s2
    9a34:	9402                	jalr	s0
    9a36:	8aee                	mv	s5,s11
    9a38:	899ac50b          	th.lbuib	a0,(s5),-7,0
    9a3c:	86a6                	mv	a3,s1
    9a3e:	417b0633          	sub	a2,s6,s7
    9a42:	85ca                	mv	a1,s2
    9a44:	9402                	jalr	s0
    9a46:	898dc50b          	th.lbuib	a0,(s11),-8,0
    9a4a:	86a6                	mv	a3,s1
    9a4c:	415b0633          	sub	a2,s6,s5
    9a50:	85ca                	mv	a1,s2
    9a52:	9402                	jalr	s0
    9a54:	fffdc503          	lbu	a0,-1(s11)
    9a58:	86a6                	mv	a3,s1
    9a5a:	41bb0633          	sub	a2,s6,s11
    9a5e:	85ca                	mv	a1,s2
    9a60:	fffd8a93          	addi	s5,s11,-1
    9a64:	9402                	jalr	s0
    9a66:	f95d10e3          	bne	s10,s5,99e6 <_vsnprintf+0xe26>
    9a6a:	fda14b8b          	th.ldd	s7,s10,(sp),2,4
    9a6e:	018c8633          	add	a2,s9,s8
    9a72:	6ce2                	ld	s9,24(sp)
    9a74:	000d1463          	bnez	s10,9a7c <_vsnprintf+0xebc>
    9a78:	1970106f          	j	b40e <_vsnprintf+0x284e>
    9a7c:	6502                	ld	a0,0(sp)
    9a7e:	7c0cbd8b          	th.extu	s11,s9,31,0
    9a82:	40a60ab3          	sub	s5,a2,a0
    9a86:	01bae463          	bltu	s5,s11,9a8e <_vsnprintf+0xece>
    9a8a:	1850106f          	j	b40e <_vsnprintf+0x284e>
    9a8e:	fffacc13          	not	s8,s5
    9a92:	01bc0e33          	add	t3,s8,s11
    9a96:	86a6                	mv	a3,s1
    9a98:	85ca                	mv	a1,s2
    9a9a:	02000513          	li	a0,32
    9a9e:	001a8d13          	addi	s10,s5,1
    9aa2:	007e7c93          	andi	s9,t3,7
    9aa6:	00160b13          	addi	s6,a2,1
    9aaa:	9402                	jalr	s0
    9aac:	13bd7263          	bgeu	s10,s11,9bd0 <_vsnprintf+0x1010>
    9ab0:	080c8e63          	beqz	s9,9b4c <_vsnprintf+0xf8c>
    9ab4:	4285                	li	t0,1
    9ab6:	085c8163          	beq	s9,t0,9b38 <_vsnprintf+0xf78>
    9aba:	4e89                	li	t4,2
    9abc:	07dc8663          	beq	s9,t4,9b28 <_vsnprintf+0xf68>
    9ac0:	4f0d                	li	t5,3
    9ac2:	05ec8b63          	beq	s9,t5,9b18 <_vsnprintf+0xf58>
    9ac6:	4311                	li	t1,4
    9ac8:	046c8063          	beq	s9,t1,9b08 <_vsnprintf+0xf48>
    9acc:	4815                	li	a6,5
    9ace:	030c8563          	beq	s9,a6,9af8 <_vsnprintf+0xf38>
    9ad2:	4599                	li	a1,6
    9ad4:	00bc8a63          	beq	s9,a1,9ae8 <_vsnprintf+0xf28>
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
    9b42:	0d05                	addi	s10,s10,1
    9b44:	0b05                	addi	s6,s6,1
    9b46:	9402                	jalr	s0
    9b48:	09bd7463          	bgeu	s10,s11,9bd0 <_vsnprintf+0x1010>
    9b4c:	865a                	mv	a2,s6
    9b4e:	86a6                	mv	a3,s1
    9b50:	85ca                	mv	a1,s2
    9b52:	02000513          	li	a0,32
    9b56:	9402                	jalr	s0
    9b58:	001b0a93          	addi	s5,s6,1
    9b5c:	8656                	mv	a2,s5
    9b5e:	86a6                	mv	a3,s1
    9b60:	85ca                	mv	a1,s2
    9b62:	02000513          	li	a0,32
    9b66:	9402                	jalr	s0
    9b68:	002b0c13          	addi	s8,s6,2
    9b6c:	8662                	mv	a2,s8
    9b6e:	86a6                	mv	a3,s1
    9b70:	85ca                	mv	a1,s2
    9b72:	02000513          	li	a0,32
    9b76:	9402                	jalr	s0
    9b78:	003b0c93          	addi	s9,s6,3
    9b7c:	8666                	mv	a2,s9
    9b7e:	86a6                	mv	a3,s1
    9b80:	85ca                	mv	a1,s2
    9b82:	02000513          	li	a0,32
    9b86:	9402                	jalr	s0
    9b88:	004b0c13          	addi	s8,s6,4
    9b8c:	8662                	mv	a2,s8
    9b8e:	86a6                	mv	a3,s1
    9b90:	85ca                	mv	a1,s2
    9b92:	02000513          	li	a0,32
    9b96:	9402                	jalr	s0
    9b98:	005b0a93          	addi	s5,s6,5
    9b9c:	86a6                	mv	a3,s1
    9b9e:	8656                	mv	a2,s5
    9ba0:	85ca                	mv	a1,s2
    9ba2:	02000513          	li	a0,32
    9ba6:	9402                	jalr	s0
    9ba8:	006b0c93          	addi	s9,s6,6
    9bac:	86a6                	mv	a3,s1
    9bae:	8666                	mv	a2,s9
    9bb0:	85ca                	mv	a1,s2
    9bb2:	02000513          	li	a0,32
    9bb6:	9402                	jalr	s0
    9bb8:	007b0c13          	addi	s8,s6,7
    9bbc:	86a6                	mv	a3,s1
    9bbe:	8662                	mv	a2,s8
    9bc0:	85ca                	mv	a1,s2
    9bc2:	02000513          	li	a0,32
    9bc6:	0d21                	addi	s10,s10,8
    9bc8:	0b21                	addi	s6,s6,8
    9bca:	9402                	jalr	s0
    9bcc:	f9bd60e3          	bltu	s10,s11,9b4c <_vsnprintf+0xf8c>
    9bd0:	e05a                	sd	s6,0(sp)
    9bd2:	2530006f          	j	a624 <_vsnprintf+0x1a64>
    9bd6:	0001                	nop
    9bd8:	000db507          	fld	fa0,0(s11)
    9bdc:	020b6793          	ori	a5,s6,32
    9be0:	6602                	ld	a2,0(sp)
    9be2:	fba50e93          	addi	t4,a0,-70
    9be6:	0007881b          	sext.w	a6,a5
    9bea:	008d8f93          	addi	t6,s11,8
    9bee:	85ca                	mv	a1,s2
    9bf0:	43db180b          	th.mvnez	a6,s6,t4
    9bf4:	87c6                	mv	a5,a7
    9bf6:	8762                	mv	a4,s8
    9bf8:	86a6                	mv	a3,s1
    9bfa:	8522                	mv	a0,s0
    9bfc:	8dfe                	mv	s11,t6
    9bfe:	d32fd0ef          	jal	7130 <_ftoa>
    9c02:	65a2                	ld	a1,8(sp)
    9c04:	e02a                	sd	a0,0(sp)
    9c06:	00158c93          	addi	s9,a1,1
    9c0a:	816ff06f          	j	8c20 <_vsnprintf+0x60>
    9c0e:	002b7b13          	andi	s6,s6,2
    9c12:	320b0de3          	beqz	s6,a74c <_vsnprintf+0x1b8c>
    9c16:	6602                	ld	a2,0(sp)
    9c18:	988dc50b          	th.lbuia	a0,(s11),8,0
    9c1c:	86a6                	mv	a3,s1
    9c1e:	85ca                	mv	a1,s2
    9c20:	ec46                	sd	a7,24(sp)
    9c22:	00160b13          	addi	s6,a2,1
    9c26:	9402                	jalr	s0
    9c28:	6c62                	ld	s8,24(sp)
    9c2a:	4285                	li	t0,1
    9c2c:	0782f2e3          	bgeu	t0,s8,a490 <_vsnprintf+0x18d0>
    9c30:	6b82                	ld	s7,0(sp)
    9c32:	ffec051b          	addiw	a0,s8,-2
    9c36:	7c053e8b          	th.extu	t4,a0,31,0
    9c3a:	002b8a93          	addi	s5,s7,2
    9c3e:	015e8e33          	add	t3,t4,s5
    9c42:	416e0f33          	sub	t5,t3,s6
    9c46:	e072                	sd	t3,0(sp)
    9c48:	007f7593          	andi	a1,t5,7
    9c4c:	c5d1                	beqz	a1,9cd8 <_vsnprintf+0x1118>
    9c4e:	06558b63          	beq	a1,t0,9cc4 <_vsnprintf+0x1104>
    9c52:	4889                	li	a7,2
    9c54:	07158163          	beq	a1,a7,9cb6 <_vsnprintf+0x10f6>
    9c58:	470d                	li	a4,3
    9c5a:	04e58763          	beq	a1,a4,9ca8 <_vsnprintf+0x10e8>
    9c5e:	4611                	li	a2,4
    9c60:	02c58d63          	beq	a1,a2,9c9a <_vsnprintf+0x10da>
    9c64:	4795                	li	a5,5
    9c66:	02f58363          	beq	a1,a5,9c8c <_vsnprintf+0x10cc>
    9c6a:	4d19                	li	s10,6
    9c6c:	01a58963          	beq	a1,s10,9c7e <_vsnprintf+0x10be>
    9c70:	865a                	mv	a2,s6
    9c72:	86a6                	mv	a3,s1
    9c74:	85ca                	mv	a1,s2
    9c76:	02000513          	li	a0,32
    9c7a:	0b05                	addi	s6,s6,1
    9c7c:	9402                	jalr	s0
    9c7e:	865a                	mv	a2,s6
    9c80:	86a6                	mv	a3,s1
    9c82:	85ca                	mv	a1,s2
    9c84:	02000513          	li	a0,32
    9c88:	0b05                	addi	s6,s6,1
    9c8a:	9402                	jalr	s0
    9c8c:	865a                	mv	a2,s6
    9c8e:	86a6                	mv	a3,s1
    9c90:	85ca                	mv	a1,s2
    9c92:	02000513          	li	a0,32
    9c96:	0b05                	addi	s6,s6,1
    9c98:	9402                	jalr	s0
    9c9a:	865a                	mv	a2,s6
    9c9c:	86a6                	mv	a3,s1
    9c9e:	85ca                	mv	a1,s2
    9ca0:	02000513          	li	a0,32
    9ca4:	0b05                	addi	s6,s6,1
    9ca6:	9402                	jalr	s0
    9ca8:	865a                	mv	a2,s6
    9caa:	86a6                	mv	a3,s1
    9cac:	85ca                	mv	a1,s2
    9cae:	02000513          	li	a0,32
    9cb2:	0b05                	addi	s6,s6,1
    9cb4:	9402                	jalr	s0
    9cb6:	865a                	mv	a2,s6
    9cb8:	86a6                	mv	a3,s1
    9cba:	85ca                	mv	a1,s2
    9cbc:	02000513          	li	a0,32
    9cc0:	0b05                	addi	s6,s6,1
    9cc2:	9402                	jalr	s0
    9cc4:	865a                	mv	a2,s6
    9cc6:	86a6                	mv	a3,s1
    9cc8:	85ca                	mv	a1,s2
    9cca:	02000513          	li	a0,32
    9cce:	9402                	jalr	s0
    9cd0:	6c82                	ld	s9,0(sp)
    9cd2:	0b05                	addi	s6,s6,1
    9cd4:	7d9b0263          	beq	s6,s9,a498 <_vsnprintf+0x18d8>
    9cd8:	865a                	mv	a2,s6
    9cda:	86a6                	mv	a3,s1
    9cdc:	85ca                	mv	a1,s2
    9cde:	02000513          	li	a0,32
    9ce2:	9402                	jalr	s0
    9ce4:	001b0c13          	addi	s8,s6,1
    9ce8:	8662                	mv	a2,s8
    9cea:	86a6                	mv	a3,s1
    9cec:	85ca                	mv	a1,s2
    9cee:	02000513          	li	a0,32
    9cf2:	9402                	jalr	s0
    9cf4:	002b0b93          	addi	s7,s6,2
    9cf8:	865e                	mv	a2,s7
    9cfa:	86a6                	mv	a3,s1
    9cfc:	85ca                	mv	a1,s2
    9cfe:	02000513          	li	a0,32
    9d02:	9402                	jalr	s0
    9d04:	003b0a93          	addi	s5,s6,3
    9d08:	86a6                	mv	a3,s1
    9d0a:	8656                	mv	a2,s5
    9d0c:	85ca                	mv	a1,s2
    9d0e:	02000513          	li	a0,32
    9d12:	9402                	jalr	s0
    9d14:	004b0d13          	addi	s10,s6,4
    9d18:	86a6                	mv	a3,s1
    9d1a:	866a                	mv	a2,s10
    9d1c:	85ca                	mv	a1,s2
    9d1e:	02000513          	li	a0,32
    9d22:	9402                	jalr	s0
    9d24:	005b0c93          	addi	s9,s6,5
    9d28:	8666                	mv	a2,s9
    9d2a:	86a6                	mv	a3,s1
    9d2c:	85ca                	mv	a1,s2
    9d2e:	02000513          	li	a0,32
    9d32:	9402                	jalr	s0
    9d34:	006b0c13          	addi	s8,s6,6
    9d38:	86a6                	mv	a3,s1
    9d3a:	8662                	mv	a2,s8
    9d3c:	85ca                	mv	a1,s2
    9d3e:	02000513          	li	a0,32
    9d42:	9402                	jalr	s0
    9d44:	007b0b93          	addi	s7,s6,7
    9d48:	86a6                	mv	a3,s1
    9d4a:	865e                	mv	a2,s7
    9d4c:	85ca                	mv	a1,s2
    9d4e:	02000513          	li	a0,32
    9d52:	9402                	jalr	s0
    9d54:	6c82                	ld	s9,0(sp)
    9d56:	0b21                	addi	s6,s6,8
    9d58:	f99b10e3          	bne	s6,s9,9cd8 <_vsnprintf+0x1118>
    9d5c:	af35                	j	a498 <_vsnprintf+0x18d8>
    9d5e:	0001                	nop
    9d60:	6602                	ld	a2,0(sp)
    9d62:	86a6                	mv	a3,s1
    9d64:	85ca                	mv	a1,s2
    9d66:	02500513          	li	a0,37
    9d6a:	00160b13          	addi	s6,a2,1
    9d6e:	9402                	jalr	s0
    9d70:	6722                	ld	a4,8(sp)
    9d72:	e05a                	sd	s6,0(sp)
    9d74:	00170c93          	addi	s9,a4,1
    9d78:	ea9fe06f          	j	8c20 <_vsnprintf+0x60>
    9d7c:	06f00313          	li	t1,111
    9d80:	06650a63          	beq	a0,t1,9df4 <_vsnprintf+0x1234>
    9d84:	00a36463          	bltu	t1,a0,9d8c <_vsnprintf+0x11cc>
    9d88:	5c90106f          	j	bb50 <_vsnprintf+0x2f90>
    9d8c:	07800393          	li	t2,120
    9d90:	00751463          	bne	a0,t2,9d98 <_vsnprintf+0x11d8>
    9d94:	2a80106f          	j	b03c <_vsnprintf+0x247c>
    9d98:	fefb7513          	andi	a0,s6,-17
    9d9c:	47a9                	li	a5,10
    9d9e:	00050b1b          	sext.w	s6,a0
    9da2:	86be                	mv	a3,a5
    9da4:	a891                	j	9df8 <_vsnprintf+0x1238>
    9da6:	588dc50b          	th.lwia	a0,(s11),8,0
    9daa:	6e22                	ld	t3,8(sp)
    9dac:	00052c13          	slti	s8,a0,0
    9db0:	4380150b          	th.mvnez	a0,zero,s8
    9db4:	002e0e93          	addi	t4,t3,2
    9db8:	00050c1b          	sext.w	s8,a0
    9dbc:	e476                	sd	t4,8(sp)
    9dbe:	002e4503          	lbu	a0,2(t3)
    9dc2:	eb7fe06f          	j	8c78 <_vsnprintf+0xb8>
    9dc6:	fefb7893          	andi	a7,s6,-17
    9dca:	0218e593          	ori	a1,a7,33
    9dce:	400b7c93          	andi	s9,s6,1024
    9dd2:	855a                	mv	a0,s6
    9dd4:	2581                	sext.w	a1,a1
    9dd6:	480c93e3          	bnez	s9,aa5c <_vsnprintf+0x1e9c>
    9dda:	4b81                	li	s7,0
    9ddc:	4281                	li	t0,0
    9dde:	88cff06f          	j	8e6a <_vsnprintf+0x2aa>
    9de2:	6e05                	lui	t3,0x1
    9de4:	800e0613          	addi	a2,t3,-2048 # 800 <cmp_complex+0xc0>
    9de8:	00cb6cb3          	or	s9,s6,a2
    9dec:	000c8b1b          	sext.w	s6,s9
    9df0:	f28ff06f          	j	9518 <_vsnprintf+0x958>
    9df4:	47a1                	li	a5,8
    9df6:	86be                	mv	a3,a5
    9df8:	ff2b7813          	andi	a6,s6,-14
    9dfc:	400b7b93          	andi	s7,s6,1024
    9e00:	ff3b7b13          	andi	s6,s6,-13
    9e04:	00080c9b          	sext.w	s9,a6
    9e08:	000b061b          	sext.w	a2,s6
    9e0c:	437c960b          	th.mvnez	a2,s9,s7
    9e10:	20067813          	andi	a6,a2,512
    9e14:	8fb2                	mv	t6,a2
    9e16:	00080463          	beqz	a6,9e1e <_vsnprintf+0x125e>
    9e1a:	6b80106f          	j	b4d2 <_vsnprintf+0x2912>
    9e1e:	10067d13          	andi	s10,a2,256
    9e22:	000d0463          	beqz	s10,9e2a <_vsnprintf+0x126a>
    9e26:	15b0206f          	j	c780 <_vsnprintf+0x3bc0>
    9e2a:	04067293          	andi	t0,a2,64
    9e2e:	00029463          	bnez	t0,9e36 <_vsnprintf+0x1276>
    9e32:	2560106f          	j	b088 <_vsnprintf+0x24c8>
    9e36:	988dce8b          	th.lbuia	t4,(s11),8,0
    9e3a:	7c0eb70b          	th.extu	a4,t4,31,0
    9e3e:	e319                	bnez	a4,9e44 <_vsnprintf+0x1284>
    9e40:	1310206f          	j	c770 <_vsnprintf+0x3bb0>
    9e44:	01067e93          	andi	t4,a2,16
    9e48:	8e32                	mv	t3,a2
    9e4a:	02f75333          	divu	t1,a4,a5
    9e4e:	853a                	mv	a0,a4
    9e50:	145e358b          	th.extu	a1,t3,5,5
    9e54:	fff58a93          	addi	s5,a1,-1
    9e58:	020af393          	andi	t2,s5,32
    9e5c:	03738b1b          	addiw	s6,t2,55
    9e60:	4ca5                	li	s9,9
    9e62:	03010813          	addi	a6,sp,48
    9e66:	8642                	mv	a2,a6
    9e68:	22f3150b          	th.muls	a0,t1,a5
    9e6c:	0ff57f93          	zext.b	t6,a0
    9e70:	030f829b          	addiw	t0,t6,48
    9e74:	01fb05bb          	addw	a1,s6,t6
    9e78:	0ff2ff13          	zext.b	t5,t0
    9e7c:	0ff5fa93          	zext.b	s5,a1
    9e80:	00acb3b3          	sltu	t2,s9,a0
    9e84:	407f1a8b          	th.mveqz	s5,t5,t2
    9e88:	03510823          	sb	s5,48(sp)
    9e8c:	00f77463          	bgeu	a4,a5,9e94 <_vsnprintf+0x12d4>
    9e90:	7ac0106f          	j	b63c <_vsnprintf+0x2a7c>
    9e94:	03110613          	addi	a2,sp,49
    9e98:	829a                	mv	t0,t1
    9e9a:	0001                	nop
    9e9c:	00000013          	nop
    9ea0:	02f2d333          	divu	t1,t0,a5
    9ea4:	8516                	mv	a0,t0
    9ea6:	22f3150b          	th.muls	a0,t1,a5
    9eaa:	0ff57713          	zext.b	a4,a0
    9eae:	03070f9b          	addiw	t6,a4,48
    9eb2:	00eb0f3b          	addw	t5,s6,a4
    9eb6:	0ffff593          	zext.b	a1,t6
    9eba:	0fff7a93          	zext.b	s5,t5
    9ebe:	00acb3b3          	sltu	t2,s9,a0
    9ec2:	40759a8b          	th.mveqz	s5,a1,t2
    9ec6:	01560023          	sb	s5,0(a2)
    9eca:	00f2f463          	bgeu	t0,a5,9ed2 <_vsnprintf+0x1312>
    9ece:	76e0106f          	j	b63c <_vsnprintf+0x2a7c>
    9ed2:	00160513          	addi	a0,a2,1
    9ed6:	05010293          	addi	t0,sp,80
    9eda:	00a29463          	bne	t0,a0,9ee2 <_vsnprintf+0x1322>
    9ede:	75e0106f          	j	b63c <_vsnprintf+0x2a7c>
    9ee2:	02f35fb3          	divu	t6,t1,a5
    9ee6:	859a                	mv	a1,t1
    9ee8:	862a                	mv	a2,a0
    9eea:	22ff958b          	th.muls	a1,t6,a5
    9eee:	0ff5f713          	zext.b	a4,a1
    9ef2:	03070f1b          	addiw	t5,a4,48
    9ef6:	00eb03bb          	addw	t2,s6,a4
    9efa:	0fff7a93          	zext.b	s5,t5
    9efe:	0ff3f713          	zext.b	a4,t2
    9f02:	00bcb2b3          	sltu	t0,s9,a1
    9f06:	405a970b          	th.mveqz	a4,s5,t0
    9f0a:	00e50023          	sb	a4,0(a0)
    9f0e:	00f37463          	bgeu	t1,a5,9f16 <_vsnprintf+0x1356>
    9f12:	72a0106f          	j	b63c <_vsnprintf+0x2a7c>
    9f16:	02ffd333          	divu	t1,t6,a5
    9f1a:	85fe                	mv	a1,t6
    9f1c:	22f3158b          	th.muls	a1,t1,a5
    9f20:	0ff5ff13          	zext.b	t5,a1
    9f24:	030f0a9b          	addiw	s5,t5,48
    9f28:	01eb073b          	addw	a4,s6,t5
    9f2c:	0ffaf393          	zext.b	t2,s5
    9f30:	0ff77f13          	zext.b	t5,a4
    9f34:	00bcb2b3          	sltu	t0,s9,a1
    9f38:	40539f0b          	th.mveqz	t5,t2,t0
    9f3c:	08165f0b          	th.sbib	t5,(a2),1,0
    9f40:	00fff463          	bgeu	t6,a5,9f48 <_vsnprintf+0x1388>
    9f44:	6f80106f          	j	b63c <_vsnprintf+0x2a7c>
    9f48:	02f35fb3          	divu	t6,t1,a5
    9f4c:	859a                	mv	a1,t1
    9f4e:	00250613          	addi	a2,a0,2
    9f52:	22ff958b          	th.muls	a1,t6,a5
    9f56:	0ff5fa93          	zext.b	s5,a1
    9f5a:	030a839b          	addiw	t2,s5,48
    9f5e:	015b073b          	addw	a4,s6,s5
    9f62:	0ff3ff13          	zext.b	t5,t2
    9f66:	0ff77a93          	zext.b	s5,a4
    9f6a:	00bcb2b3          	sltu	t0,s9,a1
    9f6e:	405f1a8b          	th.mveqz	s5,t5,t0
    9f72:	01550123          	sb	s5,2(a0)
    9f76:	00f37463          	bgeu	t1,a5,9f7e <_vsnprintf+0x13be>
    9f7a:	6c20106f          	j	b63c <_vsnprintf+0x2a7c>
    9f7e:	02ffd2b3          	divu	t0,t6,a5
    9f82:	837e                	mv	t1,t6
    9f84:	00350613          	addi	a2,a0,3
    9f88:	22f2930b          	th.muls	t1,t0,a5
    9f8c:	0ff37593          	zext.b	a1,t1
    9f90:	0305839b          	addiw	t2,a1,48
    9f94:	00bb073b          	addw	a4,s6,a1
    9f98:	0ff3ff13          	zext.b	t5,t2
    9f9c:	0ff77a93          	zext.b	s5,a4
    9fa0:	006cb333          	sltu	t1,s9,t1
    9fa4:	406f1a8b          	th.mveqz	s5,t5,t1
    9fa8:	015501a3          	sb	s5,3(a0)
    9fac:	00fff463          	bgeu	t6,a5,9fb4 <_vsnprintf+0x13f4>
    9fb0:	68c0106f          	j	b63c <_vsnprintf+0x2a7c>
    9fb4:	00450613          	addi	a2,a0,4
    9fb8:	b5e5                	j	9ea0 <_vsnprintf+0x12e0>
    9fba:	05800613          	li	a2,88
    9fbe:	76c50f63          	beq	a0,a2,a73c <_vsnprintf+0x1b7c>
    9fc2:	4789                	li	a5,2
    9fc4:	06200313          	li	t1,98
    9fc8:	86be                	mv	a3,a5
    9fca:	e26507e3          	beq	a0,t1,9df8 <_vsnprintf+0x1238>
    9fce:	400b7693          	andi	a3,s6,1024
    9fd2:	2a069ee3          	bnez	a3,aa8e <_vsnprintf+0x1ece>
    9fd6:	fefb7793          	andi	a5,s6,-17
    9fda:	200b7393          	andi	t2,s6,512
    9fde:	0007859b          	sext.w	a1,a5
    9fe2:	00038463          	beqz	t2,9fea <_vsnprintf+0x142a>
    9fe6:	0fe0206f          	j	c0e4 <_vsnprintf+0x3524>
    9fea:	100b7e93          	andi	t4,s6,256
    9fee:	2c0e81e3          	beqz	t4,aab0 <_vsnprintf+0x1ef0>
    9ff2:	886e                	mv	a6,s11
    9ff4:	78884e0b          	th.ldia	t3,(a6),8,0
    9ff8:	4501                	li	a0,0
    9ffa:	000e0863          	beqz	t3,a00a <_vsnprintf+0x144a>
    9ffe:	43fe5d93          	srai	s11,t3,0x3f
    a002:	01cdc6b3          	xor	a3,s11,t3
    a006:	41b68533          	sub	a0,a3,s11
    a00a:	42a9                	li	t0,10
    a00c:	025573b3          	remu	t2,a0,t0
    a010:	03010313          	addi	t1,sp,48
    a014:	4ca5                	li	s9,9
    a016:	879a                	mv	a5,t1
    a018:	03038f1b          	addiw	t5,t2,48
    a01c:	03e10823          	sb	t5,48(sp)
    a020:	02555733          	divu	a4,a0,t0
    a024:	10acf963          	bgeu	s9,a0,a136 <_vsnprintf+0x1576>
    a028:	03110793          	addi	a5,sp,49
    a02c:	02577fb3          	remu	t6,a4,t0
    a030:	030f8e9b          	addiw	t4,t6,48
    a034:	01d78023          	sb	t4,0(a5)
    a038:	02575d33          	divu	s10,a4,t0
    a03c:	0eecfd63          	bgeu	s9,a4,a136 <_vsnprintf+0x1576>
    a040:	00178b93          	addi	s7,a5,1
    a044:	05010b13          	addi	s6,sp,80
    a048:	0f7b0763          	beq	s6,s7,a136 <_vsnprintf+0x1576>
    a04c:	87de                	mv	a5,s7
    a04e:	025d7ab3          	remu	s5,s10,t0
    a052:	030a861b          	addiw	a2,s5,48
    a056:	00cb8023          	sb	a2,0(s7)
    a05a:	025d5733          	divu	a4,s10,t0
    a05e:	0dacfc63          	bgeu	s9,s10,a136 <_vsnprintf+0x1576>
    a062:	02577fb3          	remu	t6,a4,t0
    a066:	030f8d9b          	addiw	s11,t6,48
    a06a:	0817dd8b          	th.sbib	s11,(a5),1,0
    a06e:	025756b3          	divu	a3,a4,t0
    a072:	0cecf263          	bgeu	s9,a4,a136 <_vsnprintf+0x1576>
    a076:	002b8793          	addi	a5,s7,2
    a07a:	0256f533          	remu	a0,a3,t0
    a07e:	0305039b          	addiw	t2,a0,48
    a082:	007b8123          	sb	t2,2(s7)
    a086:	0256df33          	divu	t5,a3,t0
    a08a:	0adcf663          	bgeu	s9,a3,a136 <_vsnprintf+0x1576>
    a08e:	003b8793          	addi	a5,s7,3
    a092:	025f7eb3          	remu	t4,t5,t0
    a096:	030e8d1b          	addiw	s10,t4,48
    a09a:	01ab81a3          	sb	s10,3(s7)
    a09e:	025f5b33          	divu	s6,t5,t0
    a0a2:	09ecfa63          	bgeu	s9,t5,a136 <_vsnprintf+0x1576>
    a0a6:	004b8793          	addi	a5,s7,4
    a0aa:	025b7ab3          	remu	s5,s6,t0
    a0ae:	030a861b          	addiw	a2,s5,48
    a0b2:	00cb8223          	sb	a2,4(s7)
    a0b6:	025b5733          	divu	a4,s6,t0
    a0ba:	076cfe63          	bgeu	s9,s6,a136 <_vsnprintf+0x1576>
    a0be:	005b8793          	addi	a5,s7,5
    a0c2:	02577fb3          	remu	t6,a4,t0
    a0c6:	030f8d9b          	addiw	s11,t6,48
    a0ca:	01bb82a3          	sb	s11,5(s7)
    a0ce:	025756b3          	divu	a3,a4,t0
    a0d2:	06ecf263          	bgeu	s9,a4,a136 <_vsnprintf+0x1576>
    a0d6:	006b8793          	addi	a5,s7,6
    a0da:	0256f533          	remu	a0,a3,t0
    a0de:	0305039b          	addiw	t2,a0,48
    a0e2:	007b8323          	sb	t2,6(s7)
    a0e6:	0256deb3          	divu	t4,a3,t0
    a0ea:	04dcf663          	bgeu	s9,a3,a136 <_vsnprintf+0x1576>
    a0ee:	007b8793          	addi	a5,s7,7
    a0f2:	025eff33          	remu	t5,t4,t0
    a0f6:	030f0d1b          	addiw	s10,t5,48
    a0fa:	01ab83a3          	sb	s10,7(s7)
    a0fe:	025edb33          	divu	s6,t4,t0
    a102:	03dcfa63          	bgeu	s9,t4,a136 <_vsnprintf+0x1576>
    a106:	008b8793          	addi	a5,s7,8
    a10a:	025b7ab3          	remu	s5,s6,t0
    a10e:	030a861b          	addiw	a2,s5,48
    a112:	00cb8423          	sb	a2,8(s7)
    a116:	025b5733          	divu	a4,s6,t0
    a11a:	016cfe63          	bgeu	s9,s6,a136 <_vsnprintf+0x1576>
    a11e:	009b8793          	addi	a5,s7,9
    a122:	02577fb3          	remu	t6,a4,t0
    a126:	030f8e9b          	addiw	t4,t6,48
    a12a:	01d78023          	sb	t4,0(a5)
    a12e:	02575d33          	divu	s10,a4,t0
    a132:	f0ece7e3          	bltu	s9,a4,a040 <_vsnprintf+0x1480>
    a136:	406787b3          	sub	a5,a5,t1
    a13a:	0025fb13          	andi	s6,a1,2
    a13e:	0785                	addi	a5,a5,1
    a140:	82ae                	mv	t0,a1
    a142:	000b1463          	bnez	s6,a14a <_vsnprintf+0x158a>
    a146:	4200306f          	j	d566 <_vsnprintf+0x49a6>
    a14a:	02000c13          	li	s8,32
    a14e:	4b09                	li	s6,2
    a150:	01878463          	beq	a5,s8,a158 <_vsnprintf+0x1598>
    a154:	6190306f          	j	df6c <_vsnprintf+0x53ac>
    a158:	04f14503          	lbu	a0,79(sp)
    a15c:	6382                	ld	t2,0(sp)
    a15e:	8dc2                	mv	s11,a6
    a160:	02000d13          	li	s10,32
    a164:	01a30c33          	add	s8,t1,s10
    a168:	fff34813          	not	a6,t1
    a16c:	018802b3          	add	t0,a6,s8
    a170:	01a38cb3          	add	s9,t2,s10
    a174:	0072fd13          	andi	s10,t0,7
    a178:	01930bb3          	add	s7,t1,s9
    a17c:	000d1463          	bnez	s10,a184 <_vsnprintf+0x15c4>
    a180:	5910306f          	j	df10 <_vsnprintf+0x5350>
    a184:	418b8633          	sub	a2,s7,s8
    a188:	ec46                	sd	a7,24(sp)
    a18a:	f01a                	sd	t1,32(sp)
    a18c:	86a6                	mv	a3,s1
    a18e:	85ca                	mv	a1,s2
    a190:	9402                	jalr	s0
    a192:	4f85                	li	t6,1
    a194:	68e2                	ld	a7,24(sp)
    a196:	7302                	ld	t1,32(sp)
    a198:	1c7d                	addi	s8,s8,-1
    a19a:	fffc4503          	lbu	a0,-1(s8)
    a19e:	01fd1463          	bne	s10,t6,a1a6 <_vsnprintf+0x15e6>
    a1a2:	56f0306f          	j	df10 <_vsnprintf+0x5350>
    a1a6:	4389                	li	t2,2
    a1a8:	087d0863          	beq	s10,t2,a238 <_vsnprintf+0x1678>
    a1ac:	470d                	li	a4,3
    a1ae:	06ed0963          	beq	s10,a4,a220 <_vsnprintf+0x1660>
    a1b2:	4a91                	li	s5,4
    a1b4:	055d0a63          	beq	s10,s5,a208 <_vsnprintf+0x1648>
    a1b8:	4e95                	li	t4,5
    a1ba:	03dd0b63          	beq	s10,t4,a1f0 <_vsnprintf+0x1630>
    a1be:	4f19                	li	t5,6
    a1c0:	01ed0c63          	beq	s10,t5,a1d8 <_vsnprintf+0x1618>
    a1c4:	418b8633          	sub	a2,s7,s8
    a1c8:	86a6                	mv	a3,s1
    a1ca:	85ca                	mv	a1,s2
    a1cc:	9402                	jalr	s0
    a1ce:	68e2                	ld	a7,24(sp)
    a1d0:	7302                	ld	t1,32(sp)
    a1d2:	ffec4503          	lbu	a0,-2(s8)
    a1d6:	1c7d                	addi	s8,s8,-1
    a1d8:	ec46                	sd	a7,24(sp)
    a1da:	f01a                	sd	t1,32(sp)
    a1dc:	418b8633          	sub	a2,s7,s8
    a1e0:	86a6                	mv	a3,s1
    a1e2:	85ca                	mv	a1,s2
    a1e4:	9402                	jalr	s0
    a1e6:	68e2                	ld	a7,24(sp)
    a1e8:	7302                	ld	t1,32(sp)
    a1ea:	ffec4503          	lbu	a0,-2(s8)
    a1ee:	1c7d                	addi	s8,s8,-1
    a1f0:	ec46                	sd	a7,24(sp)
    a1f2:	f01a                	sd	t1,32(sp)
    a1f4:	418b8633          	sub	a2,s7,s8
    a1f8:	86a6                	mv	a3,s1
    a1fa:	85ca                	mv	a1,s2
    a1fc:	9402                	jalr	s0
    a1fe:	68e2                	ld	a7,24(sp)
    a200:	7302                	ld	t1,32(sp)
    a202:	ffec4503          	lbu	a0,-2(s8)
    a206:	1c7d                	addi	s8,s8,-1
    a208:	ec46                	sd	a7,24(sp)
    a20a:	f01a                	sd	t1,32(sp)
    a20c:	418b8633          	sub	a2,s7,s8
    a210:	86a6                	mv	a3,s1
    a212:	85ca                	mv	a1,s2
    a214:	9402                	jalr	s0
    a216:	68e2                	ld	a7,24(sp)
    a218:	7302                	ld	t1,32(sp)
    a21a:	ffec4503          	lbu	a0,-2(s8)
    a21e:	1c7d                	addi	s8,s8,-1
    a220:	ec46                	sd	a7,24(sp)
    a222:	f01a                	sd	t1,32(sp)
    a224:	418b8633          	sub	a2,s7,s8
    a228:	86a6                	mv	a3,s1
    a22a:	85ca                	mv	a1,s2
    a22c:	9402                	jalr	s0
    a22e:	68e2                	ld	a7,24(sp)
    a230:	7302                	ld	t1,32(sp)
    a232:	ffec4503          	lbu	a0,-2(s8)
    a236:	1c7d                	addi	s8,s8,-1
    a238:	418b8633          	sub	a2,s7,s8
    a23c:	ec46                	sd	a7,24(sp)
    a23e:	f01a                	sd	t1,32(sp)
    a240:	86a6                	mv	a3,s1
    a242:	85ca                	mv	a1,s2
    a244:	9402                	jalr	s0
    a246:	1c7d                	addi	s8,s8,-1
    a248:	6d62                	ld	s10,24(sp)
    a24a:	7a82                	ld	s5,32(sp)
    a24c:	fffc4503          	lbu	a0,-1(s8)
    a250:	a071                	j	a2dc <_vsnprintf+0x171c>
    a252:	87e2                	mv	a5,s8
    a254:	40ab8633          	sub	a2,s7,a0
    a258:	89e7c50b          	th.lbuib	a0,(a5),-2,0
    a25c:	86a6                	mv	a3,s1
    a25e:	85ca                	mv	a1,s2
    a260:	ec3e                	sd	a5,24(sp)
    a262:	9402                	jalr	s0
    a264:	8e62                	mv	t3,s8
    a266:	89de450b          	th.lbuib	a0,(t3),-3,0
    a26a:	6662                	ld	a2,24(sp)
    a26c:	86a6                	mv	a3,s1
    a26e:	ec72                	sd	t3,24(sp)
    a270:	85ca                	mv	a1,s2
    a272:	40cb8633          	sub	a2,s7,a2
    a276:	9402                	jalr	s0
    a278:	8862                	mv	a6,s8
    a27a:	89c8450b          	th.lbuib	a0,(a6),-4,0
    a27e:	62e2                	ld	t0,24(sp)
    a280:	86a6                	mv	a3,s1
    a282:	ec42                	sd	a6,24(sp)
    a284:	405b8633          	sub	a2,s7,t0
    a288:	85ca                	mv	a1,s2
    a28a:	9402                	jalr	s0
    a28c:	8fe2                	mv	t6,s8
    a28e:	89bfc50b          	th.lbuib	a0,(t6),-5,0
    a292:	63e2                	ld	t2,24(sp)
    a294:	86a6                	mv	a3,s1
    a296:	ec7e                	sd	t6,24(sp)
    a298:	407b8633          	sub	a2,s7,t2
    a29c:	85ca                	mv	a1,s2
    a29e:	9402                	jalr	s0
    a2a0:	8762                	mv	a4,s8
    a2a2:	89a7450b          	th.lbuib	a0,(a4),-6,0
    a2a6:	6ee2                	ld	t4,24(sp)
    a2a8:	86a6                	mv	a3,s1
    a2aa:	ec3a                	sd	a4,24(sp)
    a2ac:	41db8633          	sub	a2,s7,t4
    a2b0:	85ca                	mv	a1,s2
    a2b2:	9402                	jalr	s0
    a2b4:	8f62                	mv	t5,s8
    a2b6:	899f450b          	th.lbuib	a0,(t5),-7,0
    a2ba:	6362                	ld	t1,24(sp)
    a2bc:	86a6                	mv	a3,s1
    a2be:	85ca                	mv	a1,s2
    a2c0:	406b8633          	sub	a2,s7,t1
    a2c4:	ec7a                	sd	t5,24(sp)
    a2c6:	9402                	jalr	s0
    a2c8:	68e2                	ld	a7,24(sp)
    a2ca:	898c450b          	th.lbuib	a0,(s8),-8,0
    a2ce:	86a6                	mv	a3,s1
    a2d0:	85ca                	mv	a1,s2
    a2d2:	411b8633          	sub	a2,s7,a7
    a2d6:	9402                	jalr	s0
    a2d8:	fffc4503          	lbu	a0,-1(s8)
    a2dc:	86a6                	mv	a3,s1
    a2de:	418b8633          	sub	a2,s7,s8
    a2e2:	85ca                	mv	a1,s2
    a2e4:	ec66                	sd	s9,24(sp)
    a2e6:	9402                	jalr	s0
    a2e8:	fffc0513          	addi	a0,s8,-1
    a2ec:	6e62                	ld	t3,24(sp)
    a2ee:	f6aa92e3          	bne	s5,a0,a252 <_vsnprintf+0x1692>
    a2f2:	88ea                	mv	a7,s10
    a2f4:	180b0463          	beqz	s6,a47c <_vsnprintf+0x18bc>
    a2f8:	6b02                	ld	s6,0(sp)
    a2fa:	7c08bb8b          	th.extu	s7,a7,31,0
    a2fe:	416e0cb3          	sub	s9,t3,s6
    a302:	177cfd63          	bgeu	s9,s7,a47c <_vsnprintf+0x18bc>
    a306:	fffcc793          	not	a5,s9
    a30a:	01778633          	add	a2,a5,s7
    a30e:	00767d13          	andi	s10,a2,7
    a312:	8672                	mv	a2,t3
    a314:	0e05                	addi	t3,t3,1
    a316:	e072                	sd	t3,0(sp)
    a318:	86a6                	mv	a3,s1
    a31a:	85ca                	mv	a1,s2
    a31c:	02000513          	li	a0,32
    a320:	9402                	jalr	s0
    a322:	001c8c13          	addi	s8,s9,1
    a326:	6e02                	ld	t3,0(sp)
    a328:	157c7a63          	bgeu	s8,s7,a47c <_vsnprintf+0x18bc>
    a32c:	0c0d0463          	beqz	s10,a3f4 <_vsnprintf+0x1834>
    a330:	4585                	li	a1,1
    a332:	0abd0463          	beq	s10,a1,a3da <_vsnprintf+0x181a>
    a336:	4689                	li	a3,2
    a338:	08dd0663          	beq	s10,a3,a3c4 <_vsnprintf+0x1804>
    a33c:	480d                	li	a6,3
    a33e:	070d0863          	beq	s10,a6,a3ae <_vsnprintf+0x17ee>
    a342:	4291                	li	t0,4
    a344:	045d0a63          	beq	s10,t0,a398 <_vsnprintf+0x17d8>
    a348:	4f95                	li	t6,5
    a34a:	03fd0c63          	beq	s10,t6,a382 <_vsnprintf+0x17c2>
    a34e:	4399                	li	t2,6
    a350:	007d0e63          	beq	s10,t2,a36c <_vsnprintf+0x17ac>
    a354:	001e0713          	addi	a4,t3,1
    a358:	8672                	mv	a2,t3
    a35a:	86a6                	mv	a3,s1
    a35c:	85ca                	mv	a1,s2
    a35e:	02000513          	li	a0,32
    a362:	e03a                	sd	a4,0(sp)
    a364:	9402                	jalr	s0
    a366:	6e02                	ld	t3,0(sp)
    a368:	002c8c13          	addi	s8,s9,2
    a36c:	001e0e93          	addi	t4,t3,1
    a370:	8672                	mv	a2,t3
    a372:	86a6                	mv	a3,s1
    a374:	85ca                	mv	a1,s2
    a376:	02000513          	li	a0,32
    a37a:	e076                	sd	t4,0(sp)
    a37c:	9402                	jalr	s0
    a37e:	6e02                	ld	t3,0(sp)
    a380:	0c05                	addi	s8,s8,1
    a382:	001e0f13          	addi	t5,t3,1
    a386:	8672                	mv	a2,t3
    a388:	86a6                	mv	a3,s1
    a38a:	85ca                	mv	a1,s2
    a38c:	02000513          	li	a0,32
    a390:	e07a                	sd	t5,0(sp)
    a392:	9402                	jalr	s0
    a394:	6e02                	ld	t3,0(sp)
    a396:	0c05                	addi	s8,s8,1
    a398:	001e0313          	addi	t1,t3,1
    a39c:	8672                	mv	a2,t3
    a39e:	86a6                	mv	a3,s1
    a3a0:	85ca                	mv	a1,s2
    a3a2:	02000513          	li	a0,32
    a3a6:	e01a                	sd	t1,0(sp)
    a3a8:	9402                	jalr	s0
    a3aa:	6e02                	ld	t3,0(sp)
    a3ac:	0c05                	addi	s8,s8,1
    a3ae:	001e0a93          	addi	s5,t3,1
    a3b2:	8672                	mv	a2,t3
    a3b4:	86a6                	mv	a3,s1
    a3b6:	85ca                	mv	a1,s2
    a3b8:	02000513          	li	a0,32
    a3bc:	e056                	sd	s5,0(sp)
    a3be:	9402                	jalr	s0
    a3c0:	6e02                	ld	t3,0(sp)
    a3c2:	0c05                	addi	s8,s8,1
    a3c4:	001e0893          	addi	a7,t3,1
    a3c8:	8672                	mv	a2,t3
    a3ca:	86a6                	mv	a3,s1
    a3cc:	85ca                	mv	a1,s2
    a3ce:	02000513          	li	a0,32
    a3d2:	e046                	sd	a7,0(sp)
    a3d4:	9402                	jalr	s0
    a3d6:	6e02                	ld	t3,0(sp)
    a3d8:	0c05                	addi	s8,s8,1
    a3da:	001e0b13          	addi	s6,t3,1
    a3de:	8672                	mv	a2,t3
    a3e0:	86a6                	mv	a3,s1
    a3e2:	85ca                	mv	a1,s2
    a3e4:	02000513          	li	a0,32
    a3e8:	e05a                	sd	s6,0(sp)
    a3ea:	9402                	jalr	s0
    a3ec:	0c05                	addi	s8,s8,1
    a3ee:	6e02                	ld	t3,0(sp)
    a3f0:	097c7663          	bgeu	s8,s7,a47c <_vsnprintf+0x18bc>
    a3f4:	8af2                	mv	s5,t3
    a3f6:	8656                	mv	a2,s5
    a3f8:	86a6                	mv	a3,s1
    a3fa:	85ca                	mv	a1,s2
    a3fc:	02000513          	li	a0,32
    a400:	9402                	jalr	s0
    a402:	001a8d13          	addi	s10,s5,1
    a406:	866a                	mv	a2,s10
    a408:	86a6                	mv	a3,s1
    a40a:	85ca                	mv	a1,s2
    a40c:	02000513          	li	a0,32
    a410:	9402                	jalr	s0
    a412:	002a8c93          	addi	s9,s5,2
    a416:	8666                	mv	a2,s9
    a418:	86a6                	mv	a3,s1
    a41a:	85ca                	mv	a1,s2
    a41c:	02000513          	li	a0,32
    a420:	9402                	jalr	s0
    a422:	003a8b13          	addi	s6,s5,3
    a426:	865a                	mv	a2,s6
    a428:	86a6                	mv	a3,s1
    a42a:	85ca                	mv	a1,s2
    a42c:	02000513          	li	a0,32
    a430:	9402                	jalr	s0
    a432:	004a8d13          	addi	s10,s5,4
    a436:	866a                	mv	a2,s10
    a438:	86a6                	mv	a3,s1
    a43a:	85ca                	mv	a1,s2
    a43c:	02000513          	li	a0,32
    a440:	9402                	jalr	s0
    a442:	005a8b13          	addi	s6,s5,5
    a446:	86a6                	mv	a3,s1
    a448:	865a                	mv	a2,s6
    a44a:	85ca                	mv	a1,s2
    a44c:	02000513          	li	a0,32
    a450:	9402                	jalr	s0
    a452:	006a8c93          	addi	s9,s5,6
    a456:	86a6                	mv	a3,s1
    a458:	8666                	mv	a2,s9
    a45a:	85ca                	mv	a1,s2
    a45c:	02000513          	li	a0,32
    a460:	9402                	jalr	s0
    a462:	007a8d13          	addi	s10,s5,7
    a466:	86a6                	mv	a3,s1
    a468:	866a                	mv	a2,s10
    a46a:	85ca                	mv	a1,s2
    a46c:	02000513          	li	a0,32
    a470:	0c21                	addi	s8,s8,8
    a472:	0aa1                	addi	s5,s5,8
    a474:	9402                	jalr	s0
    a476:	f97c60e3          	bltu	s8,s7,a3f6 <_vsnprintf+0x1836>
    a47a:	8e56                	mv	t3,s5
    a47c:	e072                	sd	t3,0(sp)
    a47e:	a829                	j	a498 <_vsnprintf+0x18d8>
    a480:	6602                	ld	a2,0(sp)
    a482:	988dc50b          	th.lbuia	a0,(s11),8,0
    a486:	86a6                	mv	a3,s1
    a488:	85ca                	mv	a1,s2
    a48a:	00160b13          	addi	s6,a2,1
    a48e:	9402                	jalr	s0
    a490:	e05a                	sd	s6,0(sp)
    a492:	0001                	nop
    a494:	00000013          	nop
    a498:	63a2                	ld	t2,8(sp)
    a49a:	00138c93          	addi	s9,t2,1
    a49e:	f82fe06f          	j	8c20 <_vsnprintf+0x60>
    a4a2:	88ea                	mv	a7,s10
    a4a4:	8d66                	mv	s10,s9
    a4a6:	e06a                	sd	s10,0(sp)
    a4a8:	fe0a88e3          	beqz	s5,a498 <_vsnprintf+0x18d8>
    a4ac:	ea7fe06f          	j	9352 <_vsnprintf+0x792>
    a4b0:	0025f893          	andi	a7,a1,2
    a4b4:	852e                	mv	a0,a1
    a4b6:	56089d63          	bnez	a7,aa30 <_vsnprintf+0x1e70>
    a4ba:	00c5fe13          	andi	t3,a1,12
    a4be:	3a0e1ae3          	bnez	t3,b072 <_vsnprintf+0x24b2>
    a4c2:	47c1                	li	a5,16
    a4c4:	8abe                	mv	s5,a5
    a4c6:	7c0c3f8b          	th.extu	t6,s8,31,0
    a4ca:	29fd62e3          	bltu	s10,t6,af4e <_vsnprintf+0x238e>
    a4ce:	00fd6463          	bltu	s10,a5,a4d6 <_vsnprintf+0x1916>
    a4d2:	3730206f          	j	d044 <_vsnprintf+0x4484>
    a4d6:	03000c13          	li	s8,48
    a4da:	018103b3          	add	t2,sp,s8
    a4de:	007d0833          	add	a6,s10,t2
    a4e2:	001d0e13          	addi	t3,s10,1
    a4e6:	01880023          	sb	s8,0(a6)
    a4ea:	00fe6463          	bltu	t3,a5,a4f2 <_vsnprintf+0x1932>
    a4ee:	52d0306f          	j	e21a <_vsnprintf+0x565a>
    a4f2:	9e0a                	add	t3,t3,sp
    a4f4:	03000313          	li	t1,48
    a4f8:	002d0e93          	addi	t4,s10,2
    a4fc:	026e0823          	sb	t1,48(t3)
    a500:	70fefae3          	bgeu	t4,a5,b414 <_vsnprintf+0x2854>
    a504:	00610533          	add	a0,sp,t1
    a508:	00ad0c33          	add	s8,s10,a0
    a50c:	003d0f13          	addi	t5,s10,3
    a510:	006c0123          	sb	t1,2(s8)
    a514:	70ff70e3          	bgeu	t5,a5,b414 <_vsnprintf+0x2854>
    a518:	00ad0833          	add	a6,s10,a0
    a51c:	004d0613          	addi	a2,s10,4
    a520:	006801a3          	sb	t1,3(a6)
    a524:	6ef678e3          	bgeu	a2,a5,b414 <_vsnprintf+0x2854>
    a528:	00ad0733          	add	a4,s10,a0
    a52c:	005d0293          	addi	t0,s10,5
    a530:	00670223          	sb	t1,4(a4)
    a534:	6ef2f0e3          	bgeu	t0,a5,b414 <_vsnprintf+0x2854>
    a538:	00ad0f33          	add	t5,s10,a0
    a53c:	006d0e13          	addi	t3,s10,6
    a540:	006f02a3          	sb	t1,5(t5)
    a544:	6cfe78e3          	bgeu	t3,a5,b414 <_vsnprintf+0x2854>
    a548:	00ad0633          	add	a2,s10,a0
    a54c:	007d0893          	addi	a7,s10,7
    a550:	00660323          	sb	t1,6(a2)
    a554:	6cf8f0e3          	bgeu	a7,a5,b414 <_vsnprintf+0x2854>
    a558:	00ad02b3          	add	t0,s10,a0
    a55c:	008d0393          	addi	t2,s10,8
    a560:	006283a3          	sb	t1,7(t0)
    a564:	6af3f8e3          	bgeu	t2,a5,b414 <_vsnprintf+0x2854>
    a568:	00ad0e33          	add	t3,s10,a0
    a56c:	009d0e93          	addi	t4,s10,9
    a570:	006e0423          	sb	t1,8(t3)
    a574:	6afef0e3          	bgeu	t4,a5,b414 <_vsnprintf+0x2854>
    a578:	00ad08b3          	add	a7,s10,a0
    a57c:	00ad0f13          	addi	t5,s10,10
    a580:	006884a3          	sb	t1,9(a7)
    a584:	68ff78e3          	bgeu	t5,a5,b414 <_vsnprintf+0x2854>
    a588:	00ad03b3          	add	t2,s10,a0
    a58c:	00bd0c13          	addi	s8,s10,11
    a590:	00638523          	sb	t1,10(t2)
    a594:	68fc70e3          	bgeu	s8,a5,b414 <_vsnprintf+0x2854>
    a598:	00ad0eb3          	add	t4,s10,a0
    a59c:	03000713          	li	a4,48
    a5a0:	00cd0313          	addi	t1,s10,12
    a5a4:	00ee85a3          	sb	a4,11(t4)
    a5a8:	66f376e3          	bgeu	t1,a5,b414 <_vsnprintf+0x2854>
    a5ac:	00ad06b3          	add	a3,s10,a0
    a5b0:	00dd0e13          	addi	t3,s10,13
    a5b4:	00e68623          	sb	a4,12(a3)
    a5b8:	64fe7ee3          	bgeu	t3,a5,b414 <_vsnprintf+0x2854>
    a5bc:	00ad0633          	add	a2,s10,a0
    a5c0:	00ed0893          	addi	a7,s10,14
    a5c4:	00e606a3          	sb	a4,13(a2)
    a5c8:	64f8f6e3          	bgeu	a7,a5,b414 <_vsnprintf+0x2854>
    a5cc:	00ad0333          	add	t1,s10,a0
    a5d0:	01a03d33          	snez	s10,s10
    a5d4:	00e30723          	sb	a4,14(t1)
    a5d8:	00fd0813          	addi	a6,s10,15
    a5dc:	62f87ce3          	bgeu	a6,a5,b414 <_vsnprintf+0x2854>
    a5e0:	02e10fa3          	sb	a4,63(sp)
    a5e4:	000b8463          	beqz	s7,a5ec <_vsnprintf+0x1a2c>
    a5e8:	3620106f          	j	b94a <_vsnprintf+0x2d8a>
    a5ec:	0045fe13          	andi	t3,a1,4
    a5f0:	000e0463          	beqz	t3,a5f8 <_vsnprintf+0x1a38>
    a5f4:	10e0306f          	j	d702 <_vsnprintf+0x4b42>
    a5f8:	0085fb93          	andi	s7,a1,8
    a5fc:	000b8463          	beqz	s7,a604 <_vsnprintf+0x1a44>
    a600:	1650306f          	j	df64 <_vsnprintf+0x53a4>
    a604:	4d41                	li	s10,16
    a606:	06010f93          	addi	t6,sp,96
    a60a:	fdffc503          	lbu	a0,-33(t6)
    a60e:	a47d                	j	a8bc <_vsnprintf+0x1cfc>
    a610:	885a                	mv	a6,s6
    a612:	87c6                	mv	a5,a7
    a614:	8762                	mv	a4,s8
    a616:	6602                	ld	a2,0(sp)
    a618:	86a6                	mv	a3,s1
    a61a:	85ca                	mv	a1,s2
    a61c:	8522                	mv	a0,s0
    a61e:	b13fc0ef          	jal	7130 <_ftoa>
    a622:	e02a                	sd	a0,0(sp)
    a624:	6622                	ld	a2,8(sp)
    a626:	8dde                	mv	s11,s7
    a628:	00160c93          	addi	s9,a2,1
    a62c:	df4fe06f          	j	8c20 <_vsnprintf+0x60>
    a630:	6505                	lui	a0,0x1
    a632:	80050813          	addi	a6,a0,-2048 # 800 <cmp_complex+0xc0>
    a636:	010b62b3          	or	t0,s6,a6
    a63a:	00028b1b          	sext.w	s6,t0
    a63e:	020b6313          	ori	t1,s6,32
    a642:	00030b1b          	sext.w	s6,t1
    a646:	ed3fe06f          	j	9518 <_vsnprintf+0x958>
    a64a:	400b7793          	andi	a5,s6,1024
    a64e:	41ac8bbb          	subw	s7,s9,s10
    a652:	c399                	beqz	a5,a658 <_vsnprintf+0x1a98>
    a654:	b17fe06f          	j	916a <_vsnprintf+0x5aa>
    a658:	002b7b13          	andi	s6,s6,2
    a65c:	000b1463          	bnez	s6,a664 <_vsnprintf+0x1aa4>
    a660:	4b20106f          	j	bb12 <_vsnprintf+0x2f52>
    a664:	6c82                	ld	s9,0(sp)
    a666:	4a89                	li	s5,2
    a668:	8b66                	mv	s6,s9
    a66a:	419d0d33          	sub	s10,s10,s9
    a66e:	8cc6                	mv	s9,a7
    a670:	865a                	mv	a2,s6
    a672:	86a6                	mv	a3,s1
    a674:	85ca                	mv	a1,s2
    a676:	0b05                	addi	s6,s6,1
    a678:	9402                	jalr	s0
    a67a:	816d450b          	th.lrbu	a0,s10,s6,0
    a67e:	8c5a                	mv	s8,s6
    a680:	cd3d                	beqz	a0,a6fe <_vsnprintf+0x1b3e>
    a682:	86a6                	mv	a3,s1
    a684:	8662                	mv	a2,s8
    a686:	85ca                	mv	a1,s2
    a688:	0b05                	addi	s6,s6,1
    a68a:	9402                	jalr	s0
    a68c:	816d450b          	th.lrbu	a0,s10,s6,0
    a690:	c53d                	beqz	a0,a6fe <_vsnprintf+0x1b3e>
    a692:	865a                	mv	a2,s6
    a694:	86a6                	mv	a3,s1
    a696:	85ca                	mv	a1,s2
    a698:	002c0b13          	addi	s6,s8,2
    a69c:	9402                	jalr	s0
    a69e:	816d450b          	th.lrbu	a0,s10,s6,0
    a6a2:	cd31                	beqz	a0,a6fe <_vsnprintf+0x1b3e>
    a6a4:	865a                	mv	a2,s6
    a6a6:	86a6                	mv	a3,s1
    a6a8:	85ca                	mv	a1,s2
    a6aa:	003c0b13          	addi	s6,s8,3
    a6ae:	9402                	jalr	s0
    a6b0:	816d450b          	th.lrbu	a0,s10,s6,0
    a6b4:	c529                	beqz	a0,a6fe <_vsnprintf+0x1b3e>
    a6b6:	865a                	mv	a2,s6
    a6b8:	86a6                	mv	a3,s1
    a6ba:	85ca                	mv	a1,s2
    a6bc:	004c0b13          	addi	s6,s8,4
    a6c0:	9402                	jalr	s0
    a6c2:	816d450b          	th.lrbu	a0,s10,s6,0
    a6c6:	cd05                	beqz	a0,a6fe <_vsnprintf+0x1b3e>
    a6c8:	865a                	mv	a2,s6
    a6ca:	86a6                	mv	a3,s1
    a6cc:	85ca                	mv	a1,s2
    a6ce:	005c0b13          	addi	s6,s8,5
    a6d2:	9402                	jalr	s0
    a6d4:	816d450b          	th.lrbu	a0,s10,s6,0
    a6d8:	c11d                	beqz	a0,a6fe <_vsnprintf+0x1b3e>
    a6da:	865a                	mv	a2,s6
    a6dc:	86a6                	mv	a3,s1
    a6de:	85ca                	mv	a1,s2
    a6e0:	006c0b13          	addi	s6,s8,6
    a6e4:	9402                	jalr	s0
    a6e6:	816d450b          	th.lrbu	a0,s10,s6,0
    a6ea:	c911                	beqz	a0,a6fe <_vsnprintf+0x1b3e>
    a6ec:	865a                	mv	a2,s6
    a6ee:	86a6                	mv	a3,s1
    a6f0:	85ca                	mv	a1,s2
    a6f2:	007c0b13          	addi	s6,s8,7
    a6f6:	9402                	jalr	s0
    a6f8:	816d450b          	th.lrbu	a0,s10,s6,0
    a6fc:	f935                	bnez	a0,a670 <_vsnprintf+0x1ab0>
    a6fe:	e05a                	sd	s6,0(sp)
    a700:	88e6                	mv	a7,s9
    a702:	d80a8be3          	beqz	s5,a498 <_vsnprintf+0x18d8>
    a706:	c4dfe06f          	j	9352 <_vsnprintf+0x792>
    a70a:	0c0b6813          	ori	a6,s6,192
    a70e:	00278f93          	addi	t6,a5,2
    a712:	0027c503          	lbu	a0,2(a5)
    a716:	00080b1b          	sext.w	s6,a6
    a71a:	e47e                	sd	t6,8(sp)
    a71c:	dc4fe06f          	j	8ce0 <_vsnprintf+0x120>
    a720:	300b6513          	ori	a0,s6,768
    a724:	002e0293          	addi	t0,t3,2
    a728:	00050b1b          	sext.w	s6,a0
    a72c:	e416                	sd	t0,8(sp)
    a72e:	002e4503          	lbu	a0,2(t3)
    a732:	daefe06f          	j	8ce0 <_vsnprintf+0x120>
    a736:	4981                	li	s3,0
    a738:	ec6fe06f          	j	8dfe <_vsnprintf+0x23e>
    a73c:	020b6393          	ori	t2,s6,32
    a740:	47c1                	li	a5,16
    a742:	00038b1b          	sext.w	s6,t2
    a746:	86be                	mv	a3,a5
    a748:	eb0ff06f          	j	9df8 <_vsnprintf+0x1238>
    a74c:	4385                	li	t2,1
    a74e:	d313f9e3          	bgeu	t2,a7,a480 <_vsnprintf+0x18c0>
    a752:	6302                	ld	t1,0(sp)
    a754:	ffe8869b          	addiw	a3,a7,-2
    a758:	7c06bb0b          	th.extu	s6,a3,31,0
    a75c:	00730833          	add	a6,t1,t2
    a760:	01680cb3          	add	s9,a6,s6
    a764:	406c8fb3          	sub	t6,s9,t1
    a768:	007ff293          	andi	t0,t6,7
    a76c:	8d1a                	mv	s10,t1
    a76e:	08028663          	beqz	t0,a7fa <_vsnprintf+0x1c3a>
    a772:	06728b63          	beq	t0,t2,a7e8 <_vsnprintf+0x1c28>
    a776:	4509                	li	a0,2
    a778:	06a28163          	beq	t0,a0,a7da <_vsnprintf+0x1c1a>
    a77c:	4e8d                	li	t4,3
    a77e:	05d28763          	beq	t0,t4,a7cc <_vsnprintf+0x1c0c>
    a782:	4e11                	li	t3,4
    a784:	03c28d63          	beq	t0,t3,a7be <_vsnprintf+0x1bfe>
    a788:	4f15                	li	t5,5
    a78a:	03e28363          	beq	t0,t5,a7b0 <_vsnprintf+0x1bf0>
    a78e:	4599                	li	a1,6
    a790:	00b28963          	beq	t0,a1,a7a2 <_vsnprintf+0x1be2>
    a794:	6602                	ld	a2,0(sp)
    a796:	86a6                	mv	a3,s1
    a798:	85ca                	mv	a1,s2
    a79a:	02000513          	li	a0,32
    a79e:	8d42                	mv	s10,a6
    a7a0:	9402                	jalr	s0
    a7a2:	866a                	mv	a2,s10
    a7a4:	86a6                	mv	a3,s1
    a7a6:	85ca                	mv	a1,s2
    a7a8:	02000513          	li	a0,32
    a7ac:	0d05                	addi	s10,s10,1
    a7ae:	9402                	jalr	s0
    a7b0:	866a                	mv	a2,s10
    a7b2:	86a6                	mv	a3,s1
    a7b4:	85ca                	mv	a1,s2
    a7b6:	02000513          	li	a0,32
    a7ba:	0d05                	addi	s10,s10,1
    a7bc:	9402                	jalr	s0
    a7be:	866a                	mv	a2,s10
    a7c0:	86a6                	mv	a3,s1
    a7c2:	85ca                	mv	a1,s2
    a7c4:	02000513          	li	a0,32
    a7c8:	0d05                	addi	s10,s10,1
    a7ca:	9402                	jalr	s0
    a7cc:	866a                	mv	a2,s10
    a7ce:	86a6                	mv	a3,s1
    a7d0:	85ca                	mv	a1,s2
    a7d2:	02000513          	li	a0,32
    a7d6:	0d05                	addi	s10,s10,1
    a7d8:	9402                	jalr	s0
    a7da:	866a                	mv	a2,s10
    a7dc:	86a6                	mv	a3,s1
    a7de:	85ca                	mv	a1,s2
    a7e0:	02000513          	li	a0,32
    a7e4:	0d05                	addi	s10,s10,1
    a7e6:	9402                	jalr	s0
    a7e8:	866a                	mv	a2,s10
    a7ea:	86a6                	mv	a3,s1
    a7ec:	0d05                	addi	s10,s10,1
    a7ee:	85ca                	mv	a1,s2
    a7f0:	02000513          	li	a0,32
    a7f4:	9402                	jalr	s0
    a7f6:	099d0363          	beq	s10,s9,a87c <_vsnprintf+0x1cbc>
    a7fa:	866a                	mv	a2,s10
    a7fc:	86a6                	mv	a3,s1
    a7fe:	85ca                	mv	a1,s2
    a800:	02000513          	li	a0,32
    a804:	9402                	jalr	s0
    a806:	001d0a93          	addi	s5,s10,1
    a80a:	8656                	mv	a2,s5
    a80c:	86a6                	mv	a3,s1
    a80e:	85ca                	mv	a1,s2
    a810:	02000513          	li	a0,32
    a814:	9402                	jalr	s0
    a816:	002d0c13          	addi	s8,s10,2
    a81a:	8662                	mv	a2,s8
    a81c:	86a6                	mv	a3,s1
    a81e:	85ca                	mv	a1,s2
    a820:	02000513          	li	a0,32
    a824:	9402                	jalr	s0
    a826:	003d0b93          	addi	s7,s10,3
    a82a:	865e                	mv	a2,s7
    a82c:	86a6                	mv	a3,s1
    a82e:	85ca                	mv	a1,s2
    a830:	02000513          	li	a0,32
    a834:	9402                	jalr	s0
    a836:	004d0c13          	addi	s8,s10,4
    a83a:	8662                	mv	a2,s8
    a83c:	86a6                	mv	a3,s1
    a83e:	85ca                	mv	a1,s2
    a840:	02000513          	li	a0,32
    a844:	9402                	jalr	s0
    a846:	005d0a93          	addi	s5,s10,5
    a84a:	86a6                	mv	a3,s1
    a84c:	8656                	mv	a2,s5
    a84e:	85ca                	mv	a1,s2
    a850:	02000513          	li	a0,32
    a854:	9402                	jalr	s0
    a856:	006d0b93          	addi	s7,s10,6
    a85a:	86a6                	mv	a3,s1
    a85c:	865e                	mv	a2,s7
    a85e:	85ca                	mv	a1,s2
    a860:	02000513          	li	a0,32
    a864:	9402                	jalr	s0
    a866:	007d0c13          	addi	s8,s10,7
    a86a:	86a6                	mv	a3,s1
    a86c:	0d21                	addi	s10,s10,8
    a86e:	8662                	mv	a2,s8
    a870:	85ca                	mv	a1,s2
    a872:	02000513          	li	a0,32
    a876:	9402                	jalr	s0
    a878:	f99d11e3          	bne	s10,s9,a7fa <_vsnprintf+0x1c3a>
    a87c:	6882                	ld	a7,0(sp)
    a87e:	988dc50b          	th.lbuia	a0,(s11),8,0
    a882:	86a6                	mv	a3,s1
    a884:	011b0733          	add	a4,s6,a7
    a888:	00270793          	addi	a5,a4,2
    a88c:	85ca                	mv	a1,s2
    a88e:	00170613          	addi	a2,a4,1
    a892:	e03e                	sd	a5,0(sp)
    a894:	9402                	jalr	s0
    a896:	b109                	j	a498 <_vsnprintf+0x18d8>
    a898:	0025f793          	andi	a5,a1,2
    a89c:	68078b63          	beqz	a5,af32 <_vsnprintf+0x2372>
    a8a0:	000b83e3          	beqz	s7,b0a6 <_vsnprintf+0x24e6>
    a8a4:	000c9663          	bnez	s9,a8b0 <_vsnprintf+0x1cf0>
    a8a8:	011c1463          	bne	s8,a7,a8b0 <_vsnprintf+0x1cf0>
    a8ac:	6420406f          	j	eeee <_vsnprintf+0x632e>
    a8b0:	4b89                	li	s7,2
    a8b2:	4ac1                	li	s5,16
    a8b4:	04f14503          	lbu	a0,79(sp)
    a8b8:	02000d13          	li	s10,32
    a8bc:	6682                	ld	a3,0(sp)
    a8be:	01ab0c33          	add	s8,s6,s10
    a8c2:	03110c93          	addi	s9,sp,49
    a8c6:	419c07b3          	sub	a5,s8,s9
    a8ca:	9b36                	add	s6,s6,a3
    a8cc:	0077f893          	andi	a7,a5,7
    a8d0:	9b6a                	add	s6,s6,s10
    a8d2:	12088163          	beqz	a7,a9f4 <_vsnprintf+0x1e34>
    a8d6:	418b0633          	sub	a2,s6,s8
    a8da:	86a6                	mv	a3,s1
    a8dc:	85ca                	mv	a1,s2
    a8de:	ec46                	sd	a7,24(sp)
    a8e0:	9402                	jalr	s0
    a8e2:	6762                	ld	a4,24(sp)
    a8e4:	4605                	li	a2,1
    a8e6:	ffec4503          	lbu	a0,-2(s8)
    a8ea:	1c7d                	addi	s8,s8,-1
    a8ec:	10c70463          	beq	a4,a2,a9f4 <_vsnprintf+0x1e34>
    a8f0:	4389                	li	t2,2
    a8f2:	06770663          	beq	a4,t2,a95e <_vsnprintf+0x1d9e>
    a8f6:	430d                	li	t1,3
    a8f8:	04670b63          	beq	a4,t1,a94e <_vsnprintf+0x1d8e>
    a8fc:	4811                	li	a6,4
    a8fe:	05070063          	beq	a4,a6,a93e <_vsnprintf+0x1d7e>
    a902:	4f95                	li	t6,5
    a904:	03f70563          	beq	a4,t6,a92e <_vsnprintf+0x1d6e>
    a908:	4299                	li	t0,6
    a90a:	00570a63          	beq	a4,t0,a91e <_vsnprintf+0x1d5e>
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
    a96e:	a059                	j	a9f4 <_vsnprintf+0x1e34>
    a970:	ffec4503          	lbu	a0,-2(s8)
    a974:	fffc0e13          	addi	t3,s8,-1
    a978:	41cb0633          	sub	a2,s6,t3
    a97c:	86a6                	mv	a3,s1
    a97e:	85ca                	mv	a1,s2
    a980:	9402                	jalr	s0
    a982:	ffdc4503          	lbu	a0,-3(s8)
    a986:	ffec0f13          	addi	t5,s8,-2
    a98a:	41eb0633          	sub	a2,s6,t5
    a98e:	86a6                	mv	a3,s1
    a990:	85ca                	mv	a1,s2
    a992:	9402                	jalr	s0
    a994:	ffcc4503          	lbu	a0,-4(s8)
    a998:	ffdc0593          	addi	a1,s8,-3
    a99c:	40bb0633          	sub	a2,s6,a1
    a9a0:	86a6                	mv	a3,s1
    a9a2:	85ca                	mv	a1,s2
    a9a4:	9402                	jalr	s0
    a9a6:	ffbc4503          	lbu	a0,-5(s8)
    a9aa:	ffcc0793          	addi	a5,s8,-4
    a9ae:	40fb0633          	sub	a2,s6,a5
    a9b2:	86a6                	mv	a3,s1
    a9b4:	85ca                	mv	a1,s2
    a9b6:	9402                	jalr	s0
    a9b8:	ffac4503          	lbu	a0,-6(s8)
    a9bc:	ffbc0893          	addi	a7,s8,-5
    a9c0:	411b0633          	sub	a2,s6,a7
    a9c4:	86a6                	mv	a3,s1
    a9c6:	85ca                	mv	a1,s2
    a9c8:	9402                	jalr	s0
    a9ca:	ff9c4503          	lbu	a0,-7(s8)
    a9ce:	ffac0613          	addi	a2,s8,-6
    a9d2:	86a6                	mv	a3,s1
    a9d4:	40cb0633          	sub	a2,s6,a2
    a9d8:	85ca                	mv	a1,s2
    a9da:	9402                	jalr	s0
    a9dc:	ff8c4503          	lbu	a0,-8(s8)
    a9e0:	ff9c0713          	addi	a4,s8,-7
    a9e4:	86a6                	mv	a3,s1
    a9e6:	40eb0633          	sub	a2,s6,a4
    a9ea:	85ca                	mv	a1,s2
    a9ec:	9402                	jalr	s0
    a9ee:	ff7c4503          	lbu	a0,-9(s8)
    a9f2:	1c61                	addi	s8,s8,-8
    a9f4:	86a6                	mv	a3,s1
    a9f6:	418b0633          	sub	a2,s6,s8
    a9fa:	85ca                	mv	a1,s2
    a9fc:	9402                	jalr	s0
    a9fe:	f78c99e3          	bne	s9,s8,a970 <_vsnprintf+0x1db0>
    aa02:	6502                	ld	a0,0(sp)
    aa04:	01a50eb3          	add	t4,a0,s10
    aa08:	e076                	sd	t4,0(sp)
    aa0a:	a80b87e3          	beqz	s7,a498 <_vsnprintf+0x18d8>
    aa0e:	7c0abb8b          	th.extu	s7,s5,31,0
    aa12:	a95d73e3          	bgeu	s10,s5,a498 <_vsnprintf+0x18d8>
    aa16:	8af6                	mv	s5,t4
    aa18:	8656                	mv	a2,s5
    aa1a:	86a6                	mv	a3,s1
    aa1c:	85ca                	mv	a1,s2
    aa1e:	02000513          	li	a0,32
    aa22:	0d05                	addi	s10,s10,1
    aa24:	0a85                	addi	s5,s5,1
    aa26:	9402                	jalr	s0
    aa28:	ff7d68e3          	bltu	s10,s7,aa18 <_vsnprintf+0x1e58>
    aa2c:	e056                	sd	s5,0(sp)
    aa2e:	b4ad                	j	a498 <_vsnprintf+0x18d8>
    aa30:	660b8563          	beqz	s7,b09a <_vsnprintf+0x24da>
    aa34:	000c8463          	beqz	s9,aa3c <_vsnprintf+0x1e7c>
    aa38:	6c70106f          	j	c8fe <_vsnprintf+0x3d3e>
    aa3c:	7c0c338b          	th.extu	t2,s8,31,0
    aa40:	007d1463          	bne	s10,t2,aa48 <_vsnprintf+0x1e88>
    aa44:	1140306f          	j	db58 <_vsnprintf+0x4f98>
    aa48:	47c1                	li	a5,16
    aa4a:	8abe                	mv	s5,a5
    aa4c:	4b89                	li	s7,2
    aa4e:	01a78463          	beq	a5,s10,aa56 <_vsnprintf+0x1e96>
    aa52:	6b10106f          	j	c902 <_vsnprintf+0x3d42>
    aa56:	1f40306f          	j	dc4a <_vsnprintf+0x508a>
    aa5a:	0001                	nop
    aa5c:	002b7613          	andi	a2,s6,2
    aa60:	5e061663          	bnez	a2,b04c <_vsnprintf+0x248c>
    aa64:	00c57b93          	andi	s7,a0,12
    aa68:	7c0c3f8b          	th.extu	t6,s8,31,0
    aa6c:	000b9463          	bnez	s7,aa74 <_vsnprintf+0x1eb4>
    aa70:	6000206f          	j	d070 <_vsnprintf+0x44b0>
    aa74:	000f9463          	bnez	t6,aa7c <_vsnprintf+0x1ebc>
    aa78:	3740406f          	j	edec <_vsnprintf+0x622c>
    aa7c:	47bd                	li	a5,15
    aa7e:	4b81                	li	s7,0
    aa80:	4d01                	li	s10,0
    aa82:	40000c93          	li	s9,1024
    aa86:	8abe                	mv	s5,a5
    aa88:	03010b13          	addi	s6,sp,48
    aa8c:	a1c9                	j	af4e <_vsnprintf+0x238e>
    aa8e:	feeb7b13          	andi	s6,s6,-18
    aa92:	000b059b          	sext.w	a1,s6
    aa96:	2005f313          	andi	t1,a1,512
    aa9a:	8aae                	mv	s5,a1
    aa9c:	00030463          	beqz	t1,aaa4 <_vsnprintf+0x1ee4>
    aaa0:	3f80106f          	j	be98 <_vsnprintf+0x32d8>
    aaa4:	1005f813          	andi	a6,a1,256
    aaa8:	40000e93          	li	t4,1024
    aaac:	60081563          	bnez	a6,b0b6 <_vsnprintf+0x24f6>
    aab0:	0405fe13          	andi	t3,a1,64
    aab4:	580e1863          	bnez	t3,b044 <_vsnprintf+0x2484>
    aab8:	0805f293          	andi	t0,a1,128
    aabc:	00029463          	bnez	t0,aac4 <_vsnprintf+0x1f04>
    aac0:	5ca0206f          	j	d08a <_vsnprintf+0x44ca>
    aac4:	388dce0b          	th.lhia	t3,(s11),8,0
    aac8:	40fe571b          	sraiw	a4,t3,0xf
    aacc:	00ee4fb3          	xor	t6,t3,a4
    aad0:	40ef8cbb          	subw	s9,t6,a4
    aad4:	3c0cb38b          	th.extu	t2,s9,15,0
    aad8:	000e1763          	bnez	t3,aae6 <_vsnprintf+0x1f26>
    aadc:	000e8463          	beqz	t4,aae4 <_vsnprintf+0x1f24>
    aae0:	5e00206f          	j	d0c0 <_vsnprintf+0x4500>
    aae4:	4381                	li	t2,0
    aae6:	47a9                	li	a5,10
    aae8:	02f3fb33          	remu	s6,t2,a5
    aaec:	03010b93          	addi	s7,sp,48
    aaf0:	4aa5                	li	s5,9
    aaf2:	875e                	mv	a4,s7
    aaf4:	030b031b          	addiw	t1,s6,48
    aaf8:	02610823          	sb	t1,48(sp)
    aafc:	02f3dfb3          	divu	t6,t2,a5
    ab00:	107afc63          	bgeu	s5,t2,ac18 <_vsnprintf+0x2058>
    ab04:	03110713          	addi	a4,sp,49
    ab08:	02fff633          	remu	a2,t6,a5
    ab0c:	0306081b          	addiw	a6,a2,48
    ab10:	01070023          	sb	a6,0(a4)
    ab14:	02ffdeb3          	divu	t4,t6,a5
    ab18:	11faf063          	bgeu	s5,t6,ac18 <_vsnprintf+0x2058>
    ab1c:	00000013          	nop
    ab20:	00170293          	addi	t0,a4,1
    ab24:	0888                	addi	a0,sp,80
    ab26:	0e550963          	beq	a0,t0,ac18 <_vsnprintf+0x2058>
    ab2a:	8716                	mv	a4,t0
    ab2c:	02fef633          	remu	a2,t4,a5
    ab30:	03060f9b          	addiw	t6,a2,48
    ab34:	01f28023          	sb	t6,0(t0)
    ab38:	02fedcb3          	divu	s9,t4,a5
    ab3c:	0ddafe63          	bgeu	s5,t4,ac18 <_vsnprintf+0x2058>
    ab40:	02fcfd33          	remu	s10,s9,a5
    ab44:	030d0f1b          	addiw	t5,s10,48
    ab48:	08175f0b          	th.sbib	t5,(a4),1,0
    ab4c:	02fcd6b3          	divu	a3,s9,a5
    ab50:	0d9af463          	bgeu	s5,s9,ac18 <_vsnprintf+0x2058>
    ab54:	00228713          	addi	a4,t0,2
    ab58:	02f6f3b3          	remu	t2,a3,a5
    ab5c:	03038b1b          	addiw	s6,t2,48
    ab60:	01628123          	sb	s6,2(t0)
    ab64:	02f6d333          	divu	t1,a3,a5
    ab68:	0adaf863          	bgeu	s5,a3,ac18 <_vsnprintf+0x2058>
    ab6c:	00328713          	addi	a4,t0,3
    ab70:	02f37833          	remu	a6,t1,a5
    ab74:	03080e9b          	addiw	t4,a6,48
    ab78:	01d281a3          	sb	t4,3(t0)
    ab7c:	02f35533          	divu	a0,t1,a5
    ab80:	086afc63          	bgeu	s5,t1,ac18 <_vsnprintf+0x2058>
    ab84:	00428713          	addi	a4,t0,4
    ab88:	02f57633          	remu	a2,a0,a5
    ab8c:	03060f9b          	addiw	t6,a2,48
    ab90:	01f28223          	sb	t6,4(t0)
    ab94:	02f55cb3          	divu	s9,a0,a5
    ab98:	08aaf063          	bgeu	s5,a0,ac18 <_vsnprintf+0x2058>
    ab9c:	00528713          	addi	a4,t0,5
    aba0:	02fcfd33          	remu	s10,s9,a5
    aba4:	030d0f1b          	addiw	t5,s10,48
    aba8:	01e282a3          	sb	t5,5(t0)
    abac:	02fcd6b3          	divu	a3,s9,a5
    abb0:	079af463          	bgeu	s5,s9,ac18 <_vsnprintf+0x2058>
    abb4:	00628713          	addi	a4,t0,6
    abb8:	02f6f3b3          	remu	t2,a3,a5
    abbc:	03038b1b          	addiw	s6,t2,48
    abc0:	01628323          	sb	s6,6(t0)
    abc4:	02f6d833          	divu	a6,a3,a5
    abc8:	04daf863          	bgeu	s5,a3,ac18 <_vsnprintf+0x2058>
    abcc:	00728713          	addi	a4,t0,7
    abd0:	02f87333          	remu	t1,a6,a5
    abd4:	03030e9b          	addiw	t4,t1,48
    abd8:	01d283a3          	sb	t4,7(t0)
    abdc:	02f85533          	divu	a0,a6,a5
    abe0:	030afc63          	bgeu	s5,a6,ac18 <_vsnprintf+0x2058>
    abe4:	00828713          	addi	a4,t0,8
    abe8:	02f57633          	remu	a2,a0,a5
    abec:	03060f9b          	addiw	t6,a2,48
    abf0:	01f28423          	sb	t6,8(t0)
    abf4:	02f55cb3          	divu	s9,a0,a5
    abf8:	02aaf063          	bgeu	s5,a0,ac18 <_vsnprintf+0x2058>
    abfc:	00928713          	addi	a4,t0,9
    ac00:	8fe6                	mv	t6,s9
    ac02:	02fcf633          	remu	a2,s9,a5
    ac06:	0306081b          	addiw	a6,a2,48
    ac0a:	01070023          	sb	a6,0(a4)
    ac0e:	02ffdeb3          	divu	t4,t6,a5
    ac12:	f1fae7e3          	bltu	s5,t6,ab20 <_vsnprintf+0x1f60>
    ac16:	0001                	nop
    ac18:	41770733          	sub	a4,a4,s7
    ac1c:	0025fb13          	andi	s6,a1,2
    ac20:	00170793          	addi	a5,a4,1
    ac24:	8aae                	mv	s5,a1
    ac26:	000b1463          	bnez	s6,ac2e <_vsnprintf+0x206e>
    ac2a:	1070106f          	j	c530 <_vsnprintf+0x3970>
    ac2e:	02000c13          	li	s8,32
    ac32:	4b09                	li	s6,2
    ac34:	01878463          	beq	a5,s8,ac3c <_vsnprintf+0x207c>
    ac38:	2db0206f          	j	d712 <_vsnprintf+0x4b52>
    ac3c:	04f14503          	lbu	a0,79(sp)
    ac40:	6302                	ld	t1,0(sp)
    ac42:	02000c13          	li	s8,32
    ac46:	018b8d33          	add	s10,s7,s8
    ac4a:	fffbcf13          	not	t5,s7
    ac4e:	006c0cb3          	add	s9,s8,t1
    ac52:	01af0333          	add	t1,t5,s10
    ac56:	00737813          	andi	a6,t1,7
    ac5a:	019b8c33          	add	s8,s7,s9
    ac5e:	00081463          	bnez	a6,ac66 <_vsnprintf+0x20a6>
    ac62:	6860206f          	j	d2e8 <_vsnprintf+0x4728>
    ac66:	41ac0633          	sub	a2,s8,s10
    ac6a:	ec46                	sd	a7,24(sp)
    ac6c:	f042                	sd	a6,32(sp)
    ac6e:	86a6                	mv	a3,s1
    ac70:	85ca                	mv	a1,s2
    ac72:	9402                	jalr	s0
    ac74:	68e2                	ld	a7,24(sp)
    ac76:	7a82                	ld	s5,32(sp)
    ac78:	4e85                	li	t4,1
    ac7a:	1d7d                	addi	s10,s10,-1
    ac7c:	fffd4503          	lbu	a0,-1(s10)
    ac80:	01da9463          	bne	s5,t4,ac88 <_vsnprintf+0x20c8>
    ac84:	6640206f          	j	d2e8 <_vsnprintf+0x4728>
    ac88:	4e09                	li	t3,2
    ac8a:	07ca8f63          	beq	s5,t3,ad08 <_vsnprintf+0x2148>
    ac8e:	460d                	li	a2,3
    ac90:	06ca8263          	beq	s5,a2,acf4 <_vsnprintf+0x2134>
    ac94:	4f91                	li	t6,4
    ac96:	05fa8563          	beq	s5,t6,ace0 <_vsnprintf+0x2120>
    ac9a:	4715                	li	a4,5
    ac9c:	02ea8863          	beq	s5,a4,accc <_vsnprintf+0x210c>
    aca0:	4699                	li	a3,6
    aca2:	00da8b63          	beq	s5,a3,acb8 <_vsnprintf+0x20f8>
    aca6:	41ac0633          	sub	a2,s8,s10
    acaa:	86a6                	mv	a3,s1
    acac:	85ca                	mv	a1,s2
    acae:	9402                	jalr	s0
    acb0:	68e2                	ld	a7,24(sp)
    acb2:	ffed4503          	lbu	a0,-2(s10)
    acb6:	1d7d                	addi	s10,s10,-1
    acb8:	41ac0633          	sub	a2,s8,s10
    acbc:	ec46                	sd	a7,24(sp)
    acbe:	86a6                	mv	a3,s1
    acc0:	85ca                	mv	a1,s2
    acc2:	9402                	jalr	s0
    acc4:	68e2                	ld	a7,24(sp)
    acc6:	ffed4503          	lbu	a0,-2(s10)
    acca:	1d7d                	addi	s10,s10,-1
    accc:	41ac0633          	sub	a2,s8,s10
    acd0:	ec46                	sd	a7,24(sp)
    acd2:	86a6                	mv	a3,s1
    acd4:	85ca                	mv	a1,s2
    acd6:	9402                	jalr	s0
    acd8:	68e2                	ld	a7,24(sp)
    acda:	ffed4503          	lbu	a0,-2(s10)
    acde:	1d7d                	addi	s10,s10,-1
    ace0:	41ac0633          	sub	a2,s8,s10
    ace4:	ec46                	sd	a7,24(sp)
    ace6:	86a6                	mv	a3,s1
    ace8:	85ca                	mv	a1,s2
    acea:	9402                	jalr	s0
    acec:	68e2                	ld	a7,24(sp)
    acee:	ffed4503          	lbu	a0,-2(s10)
    acf2:	1d7d                	addi	s10,s10,-1
    acf4:	41ac0633          	sub	a2,s8,s10
    acf8:	ec46                	sd	a7,24(sp)
    acfa:	86a6                	mv	a3,s1
    acfc:	85ca                	mv	a1,s2
    acfe:	9402                	jalr	s0
    ad00:	68e2                	ld	a7,24(sp)
    ad02:	ffed4503          	lbu	a0,-2(s10)
    ad06:	1d7d                	addi	s10,s10,-1
    ad08:	41ac0633          	sub	a2,s8,s10
    ad0c:	86a6                	mv	a3,s1
    ad0e:	85ca                	mv	a1,s2
    ad10:	ec46                	sd	a7,24(sp)
    ad12:	9402                	jalr	s0
    ad14:	1d7d                	addi	s10,s10,-1
    ad16:	f05a                	sd	s6,32(sp)
    ad18:	fffd4503          	lbu	a0,-1(s10)
    ad1c:	a895                	j	ad90 <_vsnprintf+0x21d0>
    ad1e:	8b6a                	mv	s6,s10
    ad20:	89eb450b          	th.lbuib	a0,(s6),-2,0
    ad24:	411c0633          	sub	a2,s8,a7
    ad28:	86a6                	mv	a3,s1
    ad2a:	85ca                	mv	a1,s2
    ad2c:	9402                	jalr	s0
    ad2e:	8aea                	mv	s5,s10
    ad30:	89dac50b          	th.lbuib	a0,(s5),-3,0
    ad34:	416c0633          	sub	a2,s8,s6
    ad38:	86a6                	mv	a3,s1
    ad3a:	85ca                	mv	a1,s2
    ad3c:	9402                	jalr	s0
    ad3e:	8b6a                	mv	s6,s10
    ad40:	89cb450b          	th.lbuib	a0,(s6),-4,0
    ad44:	415c0633          	sub	a2,s8,s5
    ad48:	86a6                	mv	a3,s1
    ad4a:	85ca                	mv	a1,s2
    ad4c:	9402                	jalr	s0
    ad4e:	8aea                	mv	s5,s10
    ad50:	89bac50b          	th.lbuib	a0,(s5),-5,0
    ad54:	416c0633          	sub	a2,s8,s6
    ad58:	86a6                	mv	a3,s1
    ad5a:	85ca                	mv	a1,s2
    ad5c:	9402                	jalr	s0
    ad5e:	8b6a                	mv	s6,s10
    ad60:	89ab450b          	th.lbuib	a0,(s6),-6,0
    ad64:	415c0633          	sub	a2,s8,s5
    ad68:	86a6                	mv	a3,s1
    ad6a:	85ca                	mv	a1,s2
    ad6c:	9402                	jalr	s0
    ad6e:	8aea                	mv	s5,s10
    ad70:	899ac50b          	th.lbuib	a0,(s5),-7,0
    ad74:	86a6                	mv	a3,s1
    ad76:	416c0633          	sub	a2,s8,s6
    ad7a:	85ca                	mv	a1,s2
    ad7c:	9402                	jalr	s0
    ad7e:	898d450b          	th.lbuib	a0,(s10),-8,0
    ad82:	86a6                	mv	a3,s1
    ad84:	415c0633          	sub	a2,s8,s5
    ad88:	85ca                	mv	a1,s2
    ad8a:	9402                	jalr	s0
    ad8c:	fffd4503          	lbu	a0,-1(s10)
    ad90:	86a6                	mv	a3,s1
    ad92:	41ac0633          	sub	a2,s8,s10
    ad96:	85ca                	mv	a1,s2
    ad98:	9402                	jalr	s0
    ad9a:	fffd0893          	addi	a7,s10,-1
    ad9e:	f91b90e3          	bne	s7,a7,ad1e <_vsnprintf+0x215e>
    ada2:	68e2                	ld	a7,24(sp)
    ada4:	7b02                	ld	s6,32(sp)
    ada6:	8ae6                	mv	s5,s9
    ada8:	380b0ee3          	beqz	s6,b944 <_vsnprintf+0x2d84>
    adac:	6b82                	ld	s7,0(sp)
    adae:	7c08bc0b          	th.extu	s8,a7,31,0
    adb2:	417a8d33          	sub	s10,s5,s7
    adb6:	398d77e3          	bgeu	s10,s8,b944 <_vsnprintf+0x2d84>
    adba:	fffd4513          	not	a0,s10
    adbe:	018507b3          	add	a5,a0,s8
    adc2:	86a6                	mv	a3,s1
    adc4:	8656                	mv	a2,s5
    adc6:	85ca                	mv	a1,s2
    adc8:	02000513          	li	a0,32
    adcc:	e056                	sd	s5,0(sp)
    adce:	0077fb93          	andi	s7,a5,7
    add2:	001d0c93          	addi	s9,s10,1
    add6:	9402                	jalr	s0
    add8:	6282                	ld	t0,0(sp)
    adda:	001a8b13          	addi	s6,s5,1
    adde:	eb8cf963          	bgeu	s9,s8,a490 <_vsnprintf+0x18d0>
    ade2:	0a0b8063          	beqz	s7,ae82 <_vsnprintf+0x22c2>
    ade6:	4585                	li	a1,1
    ade8:	08bb8363          	beq	s7,a1,ae6e <_vsnprintf+0x22ae>
    adec:	4389                	li	t2,2
    adee:	067b8863          	beq	s7,t2,ae5e <_vsnprintf+0x229e>
    adf2:	4f0d                	li	t5,3
    adf4:	05eb8d63          	beq	s7,t5,ae4e <_vsnprintf+0x228e>
    adf8:	4311                	li	t1,4
    adfa:	046b8263          	beq	s7,t1,ae3e <_vsnprintf+0x227e>
    adfe:	4815                	li	a6,5
    ae00:	030b8763          	beq	s7,a6,ae2e <_vsnprintf+0x226e>
    ae04:	4e99                	li	t4,6
    ae06:	01db8c63          	beq	s7,t4,ae1e <_vsnprintf+0x225e>
    ae0a:	865a                	mv	a2,s6
    ae0c:	86a6                	mv	a3,s1
    ae0e:	85ca                	mv	a1,s2
    ae10:	02000513          	li	a0,32
    ae14:	00228b13          	addi	s6,t0,2
    ae18:	002d0c93          	addi	s9,s10,2
    ae1c:	9402                	jalr	s0
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
    ae78:	0c85                	addi	s9,s9,1
    ae7a:	0b05                	addi	s6,s6,1
    ae7c:	9402                	jalr	s0
    ae7e:	e18cf963          	bgeu	s9,s8,a490 <_vsnprintf+0x18d0>
    ae82:	865a                	mv	a2,s6
    ae84:	86a6                	mv	a3,s1
    ae86:	85ca                	mv	a1,s2
    ae88:	02000513          	li	a0,32
    ae8c:	9402                	jalr	s0
    ae8e:	001b0a93          	addi	s5,s6,1
    ae92:	8656                	mv	a2,s5
    ae94:	86a6                	mv	a3,s1
    ae96:	85ca                	mv	a1,s2
    ae98:	02000513          	li	a0,32
    ae9c:	9402                	jalr	s0
    ae9e:	002b0d13          	addi	s10,s6,2
    aea2:	866a                	mv	a2,s10
    aea4:	86a6                	mv	a3,s1
    aea6:	85ca                	mv	a1,s2
    aea8:	02000513          	li	a0,32
    aeac:	9402                	jalr	s0
    aeae:	003b0a93          	addi	s5,s6,3
    aeb2:	8656                	mv	a2,s5
    aeb4:	86a6                	mv	a3,s1
    aeb6:	85ca                	mv	a1,s2
    aeb8:	02000513          	li	a0,32
    aebc:	9402                	jalr	s0
    aebe:	004b0b93          	addi	s7,s6,4
    aec2:	865e                	mv	a2,s7
    aec4:	86a6                	mv	a3,s1
    aec6:	85ca                	mv	a1,s2
    aec8:	02000513          	li	a0,32
    aecc:	9402                	jalr	s0
    aece:	005b0d13          	addi	s10,s6,5
    aed2:	86a6                	mv	a3,s1
    aed4:	866a                	mv	a2,s10
    aed6:	85ca                	mv	a1,s2
    aed8:	02000513          	li	a0,32
    aedc:	9402                	jalr	s0
    aede:	006b0b93          	addi	s7,s6,6
    aee2:	86a6                	mv	a3,s1
    aee4:	865e                	mv	a2,s7
    aee6:	85ca                	mv	a1,s2
    aee8:	02000513          	li	a0,32
    aeec:	9402                	jalr	s0
    aeee:	007b0a93          	addi	s5,s6,7
    aef2:	86a6                	mv	a3,s1
    aef4:	8656                	mv	a2,s5
    aef6:	85ca                	mv	a1,s2
    aef8:	02000513          	li	a0,32
    aefc:	0ca1                	addi	s9,s9,8
    aefe:	0b21                	addi	s6,s6,8
    af00:	9402                	jalr	s0
    af02:	f98ce0e3          	bltu	s9,s8,ae82 <_vsnprintf+0x22c2>
    af06:	d8aff06f          	j	a490 <_vsnprintf+0x18d0>
    af0a:	0001                	nop
    af0c:	4f1e6863          	bltu	t3,a7,b3fc <_vsnprintf+0x283c>
    af10:	002b7f93          	andi	t6,s6,2
    af14:	4a89                	li	s5,2
    af16:	4e0f8a63          	beqz	t6,b40a <_vsnprintf+0x284a>
    af1a:	000d9463          	bnez	s11,af22 <_vsnprintf+0x2362>
    af1e:	fb8fe06f          	j	96d6 <_vsnprintf+0xb16>
    af22:	f2068253          	fmv.d.x	ft4,a3
    af26:	1a1272d3          	fdiv.d	ft5,ft4,ft1
    af2a:	e20286d3          	fmv.x.d	a3,ft5
    af2e:	fa8fe06f          	j	96d6 <_vsnprintf+0xb16>
    af32:	00c5f393          	andi	t2,a1,12
    af36:	7c0c3f8b          	th.extu	t6,s8,31,0
    af3a:	00039463          	bnez	t2,af42 <_vsnprintf+0x2382>
    af3e:	0fa0206f          	j	d038 <_vsnprintf+0x4478>
    af42:	47bd                	li	a5,15
    af44:	8abe                	mv	s5,a5
    af46:	01f8e463          	bltu	a7,t6,af4e <_vsnprintf+0x238e>
    af4a:	0fa0206f          	j	d044 <_vsnprintf+0x4484>
    af4e:	02000e93          	li	t4,32
    af52:	41ae8f33          	sub	t5,t4,s10
    af56:	007f7893          	andi	a7,t5,7
    af5a:	01ab0733          	add	a4,s6,s10
    af5e:	03000313          	li	t1,48
    af62:	06088763          	beqz	a7,afd0 <_vsnprintf+0x2410>
    af66:	0d05                	addi	s10,s10,1
    af68:	1817530b          	th.sbia	t1,(a4),1,0
    af6c:	d7fd0163          	beq	s10,t6,a4ce <_vsnprintf+0x190e>
    af70:	4505                	li	a0,1
    af72:	04a88f63          	beq	a7,a0,afd0 <_vsnprintf+0x2410>
    af76:	4c09                	li	s8,2
    af78:	05888763          	beq	a7,s8,afc6 <_vsnprintf+0x2406>
    af7c:	460d                	li	a2,3
    af7e:	02c88f63          	beq	a7,a2,afbc <_vsnprintf+0x23fc>
    af82:	4391                	li	t2,4
    af84:	02788763          	beq	a7,t2,afb2 <_vsnprintf+0x23f2>
    af88:	4815                	li	a6,5
    af8a:	01088f63          	beq	a7,a6,afa8 <_vsnprintf+0x23e8>
    af8e:	4299                	li	t0,6
    af90:	00588763          	beq	a7,t0,af9e <_vsnprintf+0x23de>
    af94:	0d05                	addi	s10,s10,1
    af96:	1817530b          	th.sbia	t1,(a4),1,0
    af9a:	d3fd0a63          	beq	s10,t6,a4ce <_vsnprintf+0x190e>
    af9e:	0d05                	addi	s10,s10,1
    afa0:	1817530b          	th.sbia	t1,(a4),1,0
    afa4:	d3fd0563          	beq	s10,t6,a4ce <_vsnprintf+0x190e>
    afa8:	0d05                	addi	s10,s10,1
    afaa:	1817530b          	th.sbia	t1,(a4),1,0
    afae:	d3fd0063          	beq	s10,t6,a4ce <_vsnprintf+0x190e>
    afb2:	0d05                	addi	s10,s10,1
    afb4:	1817530b          	th.sbia	t1,(a4),1,0
    afb8:	d1fd0b63          	beq	s10,t6,a4ce <_vsnprintf+0x190e>
    afbc:	0d05                	addi	s10,s10,1
    afbe:	1817530b          	th.sbia	t1,(a4),1,0
    afc2:	d1fd0663          	beq	s10,t6,a4ce <_vsnprintf+0x190e>
    afc6:	0d05                	addi	s10,s10,1
    afc8:	1817530b          	th.sbia	t1,(a4),1,0
    afcc:	d1fd0163          	beq	s10,t6,a4ce <_vsnprintf+0x190e>
    afd0:	01dd1463          	bne	s10,t4,afd8 <_vsnprintf+0x2418>
    afd4:	4520306f          	j	e426 <_vsnprintf+0x5866>
    afd8:	0d05                	addi	s10,s10,1
    afda:	00670023          	sb	t1,0(a4)
    afde:	86ea                	mv	a3,s10
    afe0:	cffd0763          	beq	s10,t6,a4ce <_vsnprintf+0x190e>
    afe4:	0d05                	addi	s10,s10,1
    afe6:	006700a3          	sb	t1,1(a4)
    afea:	cffd0263          	beq	s10,t6,a4ce <_vsnprintf+0x190e>
    afee:	00268d13          	addi	s10,a3,2
    aff2:	00670123          	sb	t1,2(a4)
    aff6:	cdfd0c63          	beq	s10,t6,a4ce <_vsnprintf+0x190e>
    affa:	00368d13          	addi	s10,a3,3
    affe:	006701a3          	sb	t1,3(a4)
    b002:	cdfd0663          	beq	s10,t6,a4ce <_vsnprintf+0x190e>
    b006:	00468d13          	addi	s10,a3,4
    b00a:	00670223          	sb	t1,4(a4)
    b00e:	cdfd0063          	beq	s10,t6,a4ce <_vsnprintf+0x190e>
    b012:	00568d13          	addi	s10,a3,5
    b016:	006702a3          	sb	t1,5(a4)
    b01a:	cbfd0a63          	beq	s10,t6,a4ce <_vsnprintf+0x190e>
    b01e:	00668d13          	addi	s10,a3,6
    b022:	00670323          	sb	t1,6(a4)
    b026:	cbfd0463          	beq	s10,t6,a4ce <_vsnprintf+0x190e>
    b02a:	006703a3          	sb	t1,7(a4)
    b02e:	00768d13          	addi	s10,a3,7
    b032:	0721                	addi	a4,a4,8
    b034:	f9fd1ee3          	bne	s10,t6,afd0 <_vsnprintf+0x2410>
    b038:	c96ff06f          	j	a4ce <_vsnprintf+0x190e>
    b03c:	47c1                	li	a5,16
    b03e:	86be                	mv	a3,a5
    b040:	db9fe06f          	j	9df8 <_vsnprintf+0x1238>
    b044:	988dce0b          	th.lbuia	t3,(s11),8,0
    b048:	83f2                	mv	t2,t3
    b04a:	b479                	j	aad8 <_vsnprintf+0x1f18>
    b04c:	00457813          	andi	a6,a0,4
    b050:	00081463          	bnez	a6,b058 <_vsnprintf+0x2498>
    b054:	04a0206f          	j	d09e <_vsnprintf+0x44de>
    b058:	4b89                	li	s7,2
    b05a:	4ac1                	li	s5,16
    b05c:	03010b13          	addi	s6,sp,48
    b060:	00278c33          	add	s8,a5,sp
    b064:	02b00513          	li	a0,43
    b068:	00178d13          	addi	s10,a5,1
    b06c:	02ac0823          	sb	a0,48(s8)
    b070:	b0b1                	j	a8bc <_vsnprintf+0x1cfc>
    b072:	47bd                	li	a5,15
    b074:	8abe                	mv	s5,a5
    b076:	c50ff06f          	j	a4c6 <_vsnprintf+0x1906>
    b07a:	8817c70b          	th.lbuib	a4,(a5),1,0
    b07e:	c319                	beqz	a4,b084 <_vsnprintf+0x24c4>
    b080:	856fe06f          	j	90d6 <_vsnprintf+0x516>
    b084:	8d6fe06f          	j	915a <_vsnprintf+0x59a>
    b088:	080ff513          	andi	a0,t6,128
    b08c:	e119                	bnez	a0,b092 <_vsnprintf+0x24d2>
    b08e:	4920206f          	j	d520 <_vsnprintf+0x4960>
    b092:	b88dce8b          	th.lhuia	t4,(s11),8,0
    b096:	da5fe06f          	j	9e3a <_vsnprintf+0x127a>
    b09a:	02000c13          	li	s8,32
    b09e:	018d0463          	beq	s10,s8,b0a6 <_vsnprintf+0x24e6>
    b0a2:	6290306f          	j	eeca <_vsnprintf+0x630a>
    b0a6:	04f14503          	lbu	a0,79(sp)
    b0aa:	4b89                	li	s7,2
    b0ac:	4ac1                	li	s5,16
    b0ae:	02000d13          	li	s10,32
    b0b2:	80bff06f          	j	a8bc <_vsnprintf+0x1cfc>
    b0b6:	886e                	mv	a6,s11
    b0b8:	78884e0b          	th.ldia	t3,(a6),8,0
    b0bc:	000e0463          	beqz	t3,b0c4 <_vsnprintf+0x2504>
    b0c0:	f3ffe06f          	j	9ffe <_vsnprintf+0x143e>
    b0c4:	002afd93          	andi	s11,s5,2
    b0c8:	000d8463          	beqz	s11,b0d0 <_vsnprintf+0x2510>
    b0cc:	6500306f          	j	e71c <_vsnprintf+0x5b5c>
    b0d0:	7c0c3d0b          	th.extu	s10,s8,31,0
    b0d4:	4781                	li	a5,0
    b0d6:	03010313          	addi	t1,sp,48
    b0da:	00089463          	bnez	a7,b0e2 <_vsnprintf+0x2522>
    b0de:	6600306f          	j	e73e <_vsnprintf+0x5b7e>
    b0e2:	000d1463          	bnez	s10,b0ea <_vsnprintf+0x252a>
    b0e6:	6790306f          	j	ef5e <_vsnprintf+0x639e>
    b0ea:	02000513          	li	a0,32
    b0ee:	40f50f33          	sub	t5,a0,a5
    b0f2:	007f7a93          	andi	s5,t5,7
    b0f6:	00f30733          	add	a4,t1,a5
    b0fa:	03000e93          	li	t4,48
    b0fe:	060a8763          	beqz	s5,b16c <_vsnprintf+0x25ac>
    b102:	0785                	addi	a5,a5,1
    b104:	18175e8b          	th.sbia	t4,(a4),1,0
    b108:	0da7f663          	bgeu	a5,s10,b1d4 <_vsnprintf+0x2614>
    b10c:	4605                	li	a2,1
    b10e:	04ca8f63          	beq	s5,a2,b16c <_vsnprintf+0x25ac>
    b112:	4289                	li	t0,2
    b114:	045a8763          	beq	s5,t0,b162 <_vsnprintf+0x25a2>
    b118:	4c8d                	li	s9,3
    b11a:	039a8f63          	beq	s5,s9,b158 <_vsnprintf+0x2598>
    b11e:	4c11                	li	s8,4
    b120:	038a8763          	beq	s5,s8,b14e <_vsnprintf+0x258e>
    b124:	4b95                	li	s7,5
    b126:	017a8f63          	beq	s5,s7,b144 <_vsnprintf+0x2584>
    b12a:	4f99                	li	t6,6
    b12c:	01fa8763          	beq	s5,t6,b13a <_vsnprintf+0x257a>
    b130:	0785                	addi	a5,a5,1
    b132:	18175e8b          	th.sbia	t4,(a4),1,0
    b136:	09a7ff63          	bgeu	a5,s10,b1d4 <_vsnprintf+0x2614>
    b13a:	0785                	addi	a5,a5,1
    b13c:	18175e8b          	th.sbia	t4,(a4),1,0
    b140:	09a7fa63          	bgeu	a5,s10,b1d4 <_vsnprintf+0x2614>
    b144:	0785                	addi	a5,a5,1
    b146:	18175e8b          	th.sbia	t4,(a4),1,0
    b14a:	09a7f563          	bgeu	a5,s10,b1d4 <_vsnprintf+0x2614>
    b14e:	0785                	addi	a5,a5,1
    b150:	18175e8b          	th.sbia	t4,(a4),1,0
    b154:	09a7f063          	bgeu	a5,s10,b1d4 <_vsnprintf+0x2614>
    b158:	0785                	addi	a5,a5,1
    b15a:	18175e8b          	th.sbia	t4,(a4),1,0
    b15e:	07a7fb63          	bgeu	a5,s10,b1d4 <_vsnprintf+0x2614>
    b162:	0785                	addi	a5,a5,1
    b164:	18175e8b          	th.sbia	t4,(a4),1,0
    b168:	07a7f663          	bgeu	a5,s10,b1d4 <_vsnprintf+0x2614>
    b16c:	00a79463          	bne	a5,a0,b174 <_vsnprintf+0x25b4>
    b170:	3130206f          	j	dc82 <_vsnprintf+0x50c2>
    b174:	0785                	addi	a5,a5,1
    b176:	01d70023          	sb	t4,0(a4)
    b17a:	83be                	mv	t2,a5
    b17c:	05a7fc63          	bgeu	a5,s10,b1d4 <_vsnprintf+0x2614>
    b180:	0785                	addi	a5,a5,1
    b182:	01d700a3          	sb	t4,1(a4)
    b186:	05a7f763          	bgeu	a5,s10,b1d4 <_vsnprintf+0x2614>
    b18a:	00238793          	addi	a5,t2,2
    b18e:	01d70123          	sb	t4,2(a4)
    b192:	05a7f163          	bgeu	a5,s10,b1d4 <_vsnprintf+0x2614>
    b196:	00338793          	addi	a5,t2,3
    b19a:	01d701a3          	sb	t4,3(a4)
    b19e:	03a7fb63          	bgeu	a5,s10,b1d4 <_vsnprintf+0x2614>
    b1a2:	00438793          	addi	a5,t2,4
    b1a6:	01d70223          	sb	t4,4(a4)
    b1aa:	03a7f563          	bgeu	a5,s10,b1d4 <_vsnprintf+0x2614>
    b1ae:	00538793          	addi	a5,t2,5
    b1b2:	01d702a3          	sb	t4,5(a4)
    b1b6:	01a7ff63          	bgeu	a5,s10,b1d4 <_vsnprintf+0x2614>
    b1ba:	00638793          	addi	a5,t2,6
    b1be:	01d70323          	sb	t4,6(a4)
    b1c2:	01a7f963          	bgeu	a5,s10,b1d4 <_vsnprintf+0x2614>
    b1c6:	01d703a3          	sb	t4,7(a4)
    b1ca:	00738793          	addi	a5,t2,7
    b1ce:	0721                	addi	a4,a4,8
    b1d0:	f9a7eee3          	bltu	a5,s10,b16c <_vsnprintf+0x25ac>
    b1d4:	000d9463          	bnez	s11,b1dc <_vsnprintf+0x261c>
    b1d8:	6c60306f          	j	e89e <_vsnprintf+0x5cde>
    b1dc:	7c08b68b          	th.extu	a3,a7,31,0
    b1e0:	00d7f463          	bgeu	a5,a3,b1e8 <_vsnprintf+0x2628>
    b1e4:	3b00206f          	j	d594 <_vsnprintf+0x49d4>
    b1e8:	86be                	mv	a3,a5
    b1ea:	00a79463          	bne	a5,a0,b1f2 <_vsnprintf+0x2632>
    b1ee:	2a10206f          	j	dc8e <_vsnprintf+0x50ce>
    b1f2:	000e4463          	bltz	t3,b1fa <_vsnprintf+0x263a>
    b1f6:	5630306f          	j	ef58 <_vsnprintf+0x6398>
    b1fa:	00268f33          	add	t5,a3,sp
    b1fe:	02d00613          	li	a2,45
    b202:	02cf0823          	sb	a2,48(t5)
    b206:	0035f793          	andi	a5,a1,3
    b20a:	00168d13          	addi	s10,a3,1
    b20e:	c399                	beqz	a5,b214 <_vsnprintf+0x2654>
    b210:	53b0306f          	j	ef4a <_vsnprintf+0x638a>
    b214:	7c08bb8b          	th.extu	s7,a7,31,0
    b218:	8dc2                	mv	s11,a6
    b21a:	4b01                	li	s6,0
    b21c:	017d6463          	bltu	s10,s7,b224 <_vsnprintf+0x2664>
    b220:	5210306f          	j	ef40 <_vsnprintf+0x6380>
    b224:	6602                	ld	a2,0(sp)
    b226:	85ca                	mv	a1,s2
    b228:	ec46                	sd	a7,24(sp)
    b22a:	40cd0cb3          	sub	s9,s10,a2
    b22e:	fffcc313          	not	t1,s9
    b232:	40c30e33          	sub	t3,t1,a2
    b236:	86a6                	mv	a3,s1
    b238:	02000513          	li	a0,32
    b23c:	017e0ab3          	add	s5,t3,s7
    b240:	00160c13          	addi	s8,a2,1
    b244:	9402                	jalr	s0
    b246:	018c85b3          	add	a1,s9,s8
    b24a:	68e2                	ld	a7,24(sp)
    b24c:	007afa93          	andi	s5,s5,7
    b250:	1575f563          	bgeu	a1,s7,b39a <_vsnprintf+0x27da>
    b254:	0a0a8863          	beqz	s5,b304 <_vsnprintf+0x2744>
    b258:	4685                	li	a3,1
    b25a:	08da8863          	beq	s5,a3,b2ea <_vsnprintf+0x272a>
    b25e:	4809                	li	a6,2
    b260:	070a8c63          	beq	s5,a6,b2d8 <_vsnprintf+0x2718>
    b264:	428d                	li	t0,3
    b266:	065a8063          	beq	s5,t0,b2c6 <_vsnprintf+0x2706>
    b26a:	4f91                	li	t6,4
    b26c:	05fa8463          	beq	s5,t6,b2b4 <_vsnprintf+0x26f4>
    b270:	4395                	li	t2,5
    b272:	027a8863          	beq	s5,t2,b2a2 <_vsnprintf+0x26e2>
    b276:	4719                	li	a4,6
    b278:	00ea8c63          	beq	s5,a4,b290 <_vsnprintf+0x26d0>
    b27c:	8662                	mv	a2,s8
    b27e:	ec46                	sd	a7,24(sp)
    b280:	86a6                	mv	a3,s1
    b282:	85ca                	mv	a1,s2
    b284:	02000513          	li	a0,32
    b288:	6c02                	ld	s8,0(sp)
    b28a:	9402                	jalr	s0
    b28c:	68e2                	ld	a7,24(sp)
    b28e:	0c09                	addi	s8,s8,2
    b290:	8662                	mv	a2,s8
    b292:	ec46                	sd	a7,24(sp)
    b294:	86a6                	mv	a3,s1
    b296:	85ca                	mv	a1,s2
    b298:	02000513          	li	a0,32
    b29c:	9402                	jalr	s0
    b29e:	68e2                	ld	a7,24(sp)
    b2a0:	0c05                	addi	s8,s8,1
    b2a2:	8662                	mv	a2,s8
    b2a4:	ec46                	sd	a7,24(sp)
    b2a6:	86a6                	mv	a3,s1
    b2a8:	85ca                	mv	a1,s2
    b2aa:	02000513          	li	a0,32
    b2ae:	9402                	jalr	s0
    b2b0:	68e2                	ld	a7,24(sp)
    b2b2:	0c05                	addi	s8,s8,1
    b2b4:	8662                	mv	a2,s8
    b2b6:	ec46                	sd	a7,24(sp)
    b2b8:	86a6                	mv	a3,s1
    b2ba:	85ca                	mv	a1,s2
    b2bc:	02000513          	li	a0,32
    b2c0:	9402                	jalr	s0
    b2c2:	68e2                	ld	a7,24(sp)
    b2c4:	0c05                	addi	s8,s8,1
    b2c6:	8662                	mv	a2,s8
    b2c8:	ec46                	sd	a7,24(sp)
    b2ca:	86a6                	mv	a3,s1
    b2cc:	85ca                	mv	a1,s2
    b2ce:	02000513          	li	a0,32
    b2d2:	9402                	jalr	s0
    b2d4:	68e2                	ld	a7,24(sp)
    b2d6:	0c05                	addi	s8,s8,1
    b2d8:	8662                	mv	a2,s8
    b2da:	ec46                	sd	a7,24(sp)
    b2dc:	86a6                	mv	a3,s1
    b2de:	85ca                	mv	a1,s2
    b2e0:	02000513          	li	a0,32
    b2e4:	9402                	jalr	s0
    b2e6:	68e2                	ld	a7,24(sp)
    b2e8:	0c05                	addi	s8,s8,1
    b2ea:	8662                	mv	a2,s8
    b2ec:	02000513          	li	a0,32
    b2f0:	ec46                	sd	a7,24(sp)
    b2f2:	86a6                	mv	a3,s1
    b2f4:	85ca                	mv	a1,s2
    b2f6:	9402                	jalr	s0
    b2f8:	0c05                	addi	s8,s8,1
    b2fa:	018c8533          	add	a0,s9,s8
    b2fe:	68e2                	ld	a7,24(sp)
    b300:	09757d63          	bgeu	a0,s7,b39a <_vsnprintf+0x27da>
    b304:	ec5a                	sd	s6,24(sp)
    b306:	f06e                	sd	s11,32(sp)
    b308:	8dea                	mv	s11,s10
    b30a:	8d46                	mv	s10,a7
    b30c:	8662                	mv	a2,s8
    b30e:	86a6                	mv	a3,s1
    b310:	85ca                	mv	a1,s2
    b312:	02000513          	li	a0,32
    b316:	9402                	jalr	s0
    b318:	001c0a93          	addi	s5,s8,1
    b31c:	8656                	mv	a2,s5
    b31e:	86a6                	mv	a3,s1
    b320:	85ca                	mv	a1,s2
    b322:	02000513          	li	a0,32
    b326:	9402                	jalr	s0
    b328:	002c0b13          	addi	s6,s8,2
    b32c:	865a                	mv	a2,s6
    b32e:	86a6                	mv	a3,s1
    b330:	85ca                	mv	a1,s2
    b332:	02000513          	li	a0,32
    b336:	9402                	jalr	s0
    b338:	003c0a93          	addi	s5,s8,3
    b33c:	8656                	mv	a2,s5
    b33e:	86a6                	mv	a3,s1
    b340:	85ca                	mv	a1,s2
    b342:	02000513          	li	a0,32
    b346:	9402                	jalr	s0
    b348:	004c0b13          	addi	s6,s8,4
    b34c:	865a                	mv	a2,s6
    b34e:	86a6                	mv	a3,s1
    b350:	85ca                	mv	a1,s2
    b352:	02000513          	li	a0,32
    b356:	9402                	jalr	s0
    b358:	005c0a93          	addi	s5,s8,5
    b35c:	8656                	mv	a2,s5
    b35e:	86a6                	mv	a3,s1
    b360:	85ca                	mv	a1,s2
    b362:	02000513          	li	a0,32
    b366:	9402                	jalr	s0
    b368:	006c0b13          	addi	s6,s8,6
    b36c:	86a6                	mv	a3,s1
    b36e:	865a                	mv	a2,s6
    b370:	85ca                	mv	a1,s2
    b372:	02000513          	li	a0,32
    b376:	9402                	jalr	s0
    b378:	007c0a93          	addi	s5,s8,7
    b37c:	86a6                	mv	a3,s1
    b37e:	8656                	mv	a2,s5
    b380:	85ca                	mv	a1,s2
    b382:	02000513          	li	a0,32
    b386:	0c21                	addi	s8,s8,8
    b388:	9402                	jalr	s0
    b38a:	018c88b3          	add	a7,s9,s8
    b38e:	f778efe3          	bltu	a7,s7,b30c <_vsnprintf+0x274c>
    b392:	88ea                	mv	a7,s10
    b394:	8d6e                	mv	s10,s11
    b396:	6b62                	ld	s6,24(sp)
    b398:	7d82                	ld	s11,32(sp)
    b39a:	6302                	ld	t1,0(sp)
    b39c:	fffb8e93          	addi	t4,s7,-1
    b3a0:	001d0793          	addi	a5,s10,1
    b3a4:	41ae8f33          	sub	t5,t4,s10
    b3a8:	00fbb633          	sltu	a2,s7,a5
    b3ac:	42c01f0b          	th.mvnez	t5,zero,a2
    b3b0:	00130e13          	addi	t3,t1,1
    b3b4:	01cf03b3          	add	t2,t5,t3
    b3b8:	8e1e                	mv	t3,t2
    b3ba:	000d1463          	bnez	s10,b3c2 <_vsnprintf+0x2802>
    b3be:	f37fe06f          	j	a2f4 <_vsnprintf+0x1734>
    b3c2:	03010313          	addi	t1,sp,48
    b3c6:	006d06b3          	add	a3,s10,t1
    b3ca:	fff6c503          	lbu	a0,-1(a3)
    b3ce:	d97fe06f          	j	a164 <_vsnprintf+0x15a4>
    b3d2:	00678023          	sb	t1,0(a5)
    b3d6:	006780a3          	sb	t1,1(a5)
    b3da:	00678123          	sb	t1,2(a5)
    b3de:	006781a3          	sb	t1,3(a5)
    b3e2:	00678223          	sb	t1,4(a5)
    b3e6:	006782a3          	sb	t1,5(a5)
    b3ea:	00678323          	sb	t1,6(a5)
    b3ee:	006783a3          	sb	t1,7(a5)
    b3f2:	07a1                	addi	a5,a5,8
    b3f4:	fde79fe3          	bne	a5,t5,b3d2 <_vsnprintf+0x2812>
    b3f8:	cf4fe06f          	j	98ec <_vsnprintf+0xd2c>
    b3fc:	002afe93          	andi	t4,s5,2
    b400:	4a89                	li	s5,2
    b402:	b00e9ce3          	bnez	t4,af1a <_vsnprintf+0x235a>
    b406:	41c887bb          	subw	a5,a7,t3
    b40a:	4a81                	li	s5,0
    b40c:	b639                	j	af1a <_vsnprintf+0x235a>
    b40e:	e032                	sd	a2,0(sp)
    b410:	a14ff06f          	j	a624 <_vsnprintf+0x1a64>
    b414:	060b8263          	beqz	s7,b478 <_vsnprintf+0x28b8>
    b418:	000c8463          	beqz	s9,b420 <_vsnprintf+0x2860>
    b41c:	10c0206f          	j	d528 <_vsnprintf+0x4968>
    b420:	fff78893          	addi	a7,a5,-1
    b424:	8d3e                	mv	s10,a5
    b426:	01fd1463          	bne	s10,t6,b42e <_vsnprintf+0x286e>
    b42a:	4f20306f          	j	e91c <_vsnprintf+0x5d5c>
    b42e:	00fd1463          	bne	s10,a5,b436 <_vsnprintf+0x2876>
    b432:	0170206f          	j	dc48 <_vsnprintf+0x5088>
    b436:	002d0633          	add	a2,s10,sp
    b43a:	05800393          	li	t2,88
    b43e:	001d0793          	addi	a5,s10,1
    b442:	02760823          	sb	t2,48(a2)
    b446:	4b81                	li	s7,0
    b448:	00178d13          	addi	s10,a5,1
    b44c:	00278833          	add	a6,a5,sp
    b450:	03000c93          	li	s9,48
    b454:	03980823          	sb	s9,48(a6)
    b458:	02000f93          	li	t6,32
    b45c:	c5fd0c63          	beq	s10,t6,a8b4 <_vsnprintf+0x1cf4>
    b460:	0045f513          	andi	a0,a1,4
    b464:	c119                	beqz	a0,b46a <_vsnprintf+0x28aa>
    b466:	0090206f          	j	dc6e <_vsnprintf+0x50ae>
    b46a:	0085f313          	andi	t1,a1,8
    b46e:	02030c63          	beqz	t1,b4a6 <_vsnprintf+0x28e6>
    b472:	87ea                	mv	a5,s10
    b474:	a829                	j	b48e <_vsnprintf+0x28ce>
    b476:	0001                	nop
    b478:	0045fb93          	andi	s7,a1,4
    b47c:	000b8463          	beqz	s7,b484 <_vsnprintf+0x28c4>
    b480:	27c0206f          	j	d6fc <_vsnprintf+0x4b3c>
    b484:	0085fc93          	andi	s9,a1,8
    b488:	000c8d63          	beqz	s9,b4a2 <_vsnprintf+0x28e2>
    b48c:	4b81                	li	s7,0
    b48e:	00278e33          	add	t3,a5,sp
    b492:	02000513          	li	a0,32
    b496:	00178d13          	addi	s10,a5,1
    b49a:	02ae0823          	sb	a0,48(t3)
    b49e:	c1eff06f          	j	a8bc <_vsnprintf+0x1cfc>
    b4a2:	8d3e                	mv	s10,a5
    b4a4:	4b81                	li	s7,0
    b4a6:	020d0813          	addi	a6,s10,32
    b4aa:	03010c93          	addi	s9,sp,48
    b4ae:	01980fb3          	add	t6,a6,s9
    b4b2:	fdffc503          	lbu	a0,-33(t6)
    b4b6:	c06ff06f          	j	a8bc <_vsnprintf+0x1cfc>
    b4ba:	87c6                	mv	a5,a7
    b4bc:	8b6a                	mv	s6,s10
    b4be:	4d81                	li	s11,0
    b4c0:	4e01                	li	t3,0
    b4c2:	f2068553          	fmv.d.x	fa0,a3
    b4c6:	22a515d3          	fneg.d	fa1,fa0
    b4ca:	e20586d3          	fmv.x.d	a3,fa1
    b4ce:	a18fe06f          	j	96e6 <_vsnprintf+0xb26>
    b4d2:	8aee                	mv	s5,s11
    b4d4:	788acd8b          	th.ldia	s11,(s5),8,0
    b4d8:	010ffd13          	andi	s10,t6,16
    b4dc:	000d9963          	bnez	s11,b4ee <_vsnprintf+0x292e>
    b4e0:	fefffe13          	andi	t3,t6,-17
    b4e4:	000e061b          	sext.w	a2,t3
    b4e8:	040b92e3          	bnez	s7,bd2c <_vsnprintf+0x316c>
    b4ec:	4d01                	li	s10,0
    b4ee:	1456328b          	th.extu	t0,a2,5,5
    b4f2:	fff28f93          	addi	t6,t0,-1
    b4f6:	020fff13          	andi	t5,t6,32
    b4fa:	037f051b          	addiw	a0,t5,55
    b4fe:	02fddf33          	divu	t5,s11,a5
    b502:	876e                	mv	a4,s11
    b504:	43a5                	li	t2,9
    b506:	03010813          	addi	a6,sp,48
    b50a:	85c2                	mv	a1,a6
    b50c:	22ff170b          	th.muls	a4,t5,a5
    b510:	0ff77e93          	zext.b	t4,a4
    b514:	030e831b          	addiw	t1,t4,48
    b518:	01d50cbb          	addw	s9,a0,t4
    b51c:	0ff37b13          	zext.b	s6,t1
    b520:	0ffcfe13          	zext.b	t3,s9
    b524:	00e3b2b3          	sltu	t0,t2,a4
    b528:	405b1e0b          	th.mveqz	t3,s6,t0
    b52c:	03c10823          	sb	t3,48(sp)
    b530:	64fdeb63          	bltu	s11,a5,bb86 <_vsnprintf+0x2fc6>
    b534:	03110593          	addi	a1,sp,49
    b538:	02ff5db3          	divu	s11,t5,a5
    b53c:	8efa                	mv	t4,t5
    b53e:	22fd9e8b          	th.muls	t4,s11,a5
    b542:	0ffef713          	zext.b	a4,t4
    b546:	03070f9b          	addiw	t6,a4,48
    b54a:	00e5033b          	addw	t1,a0,a4
    b54e:	0ffffb13          	zext.b	s6,t6
    b552:	0ff37c93          	zext.b	s9,t1
    b556:	01d3be33          	sltu	t3,t2,t4
    b55a:	41cb1c8b          	th.mveqz	s9,s6,t3
    b55e:	01958023          	sb	s9,0(a1)
    b562:	62ff6263          	bltu	t5,a5,bb86 <_vsnprintf+0x2fc6>
    b566:	00158b13          	addi	s6,a1,1
    b56a:	05010f13          	addi	t5,sp,80
    b56e:	616f0c63          	beq	t5,s6,bb86 <_vsnprintf+0x2fc6>
    b572:	02fdd333          	divu	t1,s11,a5
    b576:	8eee                	mv	t4,s11
    b578:	85da                	mv	a1,s6
    b57a:	22f31e8b          	th.muls	t4,t1,a5
    b57e:	0ffef713          	zext.b	a4,t4
    b582:	0307029b          	addiw	t0,a4,48
    b586:	00e50fbb          	addw	t6,a0,a4
    b58a:	0ff2fc93          	zext.b	s9,t0
    b58e:	0ffffe13          	zext.b	t3,t6
    b592:	01d3bf33          	sltu	t5,t2,t4
    b596:	41ec9e0b          	th.mveqz	t3,s9,t5
    b59a:	01cb0023          	sb	t3,0(s6)
    b59e:	5efde463          	bltu	s11,a5,bb86 <_vsnprintf+0x2fc6>
    b5a2:	02f35db3          	divu	s11,t1,a5
    b5a6:	8e9a                	mv	t4,t1
    b5a8:	22fd9e8b          	th.muls	t4,s11,a5
    b5ac:	0ffef713          	zext.b	a4,t4
    b5b0:	0307029b          	addiw	t0,a4,48
    b5b4:	00e50fbb          	addw	t6,a0,a4
    b5b8:	0ff2fc93          	zext.b	s9,t0
    b5bc:	0ffffe13          	zext.b	t3,t6
    b5c0:	01d3bf33          	sltu	t5,t2,t4
    b5c4:	41ec9e0b          	th.mveqz	t3,s9,t5
    b5c8:	0815de0b          	th.sbib	t3,(a1),1,0
    b5cc:	5af36d63          	bltu	t1,a5,bb86 <_vsnprintf+0x2fc6>
    b5d0:	02fdd333          	divu	t1,s11,a5
    b5d4:	8eee                	mv	t4,s11
    b5d6:	002b0593          	addi	a1,s6,2
    b5da:	22f31e8b          	th.muls	t4,t1,a5
    b5de:	0ffef713          	zext.b	a4,t4
    b5e2:	0307029b          	addiw	t0,a4,48
    b5e6:	00e50fbb          	addw	t6,a0,a4
    b5ea:	0ff2fc93          	zext.b	s9,t0
    b5ee:	0ffffe13          	zext.b	t3,t6
    b5f2:	01d3bf33          	sltu	t5,t2,t4
    b5f6:	41ec9e0b          	th.mveqz	t3,s9,t5
    b5fa:	01cb0123          	sb	t3,2(s6)
    b5fe:	58fde463          	bltu	s11,a5,bb86 <_vsnprintf+0x2fc6>
    b602:	02f35db3          	divu	s11,t1,a5
    b606:	8e9a                	mv	t4,t1
    b608:	003b0593          	addi	a1,s6,3
    b60c:	22fd9e8b          	th.muls	t4,s11,a5
    b610:	0ffef713          	zext.b	a4,t4
    b614:	0307029b          	addiw	t0,a4,48
    b618:	00e50fbb          	addw	t6,a0,a4
    b61c:	0ff2fc93          	zext.b	s9,t0
    b620:	0ffffe13          	zext.b	t3,t6
    b624:	01d3bf33          	sltu	t5,t2,t4
    b628:	41ec9e0b          	th.mveqz	t3,s9,t5
    b62c:	01cb01a3          	sb	t3,3(s6)
    b630:	54f36b63          	bltu	t1,a5,bb86 <_vsnprintf+0x2fc6>
    b634:	004b0593          	addi	a1,s6,4
    b638:	8f6e                	mv	t5,s11
    b63a:	bdfd                	j	b538 <_vsnprintf+0x2978>
    b63c:	410607b3          	sub	a5,a2,a6
    b640:	002e7c93          	andi	s9,t3,2
    b644:	00178713          	addi	a4,a5,1
    b648:	8672                	mv	a2,t3
    b64a:	000c9463          	bnez	s9,b652 <_vsnprintf+0x2a92>
    b64e:	7d20106f          	j	ce20 <_vsnprintf+0x4260>
    b652:	000e8463          	beqz	t4,b65a <_vsnprintf+0x2a9a>
    b656:	30e0206f          	j	d964 <_vsnprintf+0x4da4>
    b65a:	02000e13          	li	t3,32
    b65e:	4d09                	li	s10,2
    b660:	01c70463          	beq	a4,t3,b668 <_vsnprintf+0x2aa8>
    b664:	7510206f          	j	e5b4 <_vsnprintf+0x59f4>
    b668:	6e02                	ld	t3,0(sp)
    b66a:	02000713          	li	a4,32
    b66e:	01c70bb3          	add	s7,a4,t3
    b672:	00e80c33          	add	s8,a6,a4
    b676:	8b1d                	andi	a4,a4,7
    b678:	01780b33          	add	s6,a6,s7
    b67c:	c761                	beqz	a4,b744 <_vsnprintf+0x2b84>
    b67e:	4505                	li	a0,1
    b680:	0aa70363          	beq	a4,a0,b726 <_vsnprintf+0x2b66>
    b684:	4309                	li	t1,2
    b686:	08670563          	beq	a4,t1,b710 <_vsnprintf+0x2b50>
    b68a:	428d                	li	t0,3
    b68c:	06570763          	beq	a4,t0,b6fa <_vsnprintf+0x2b3a>
    b690:	4391                	li	t2,4
    b692:	04770963          	beq	a4,t2,b6e4 <_vsnprintf+0x2b24>
    b696:	4f15                	li	t5,5
    b698:	03e70b63          	beq	a4,t5,b6ce <_vsnprintf+0x2b0e>
    b69c:	4699                	li	a3,6
    b69e:	00d70d63          	beq	a4,a3,b6b8 <_vsnprintf+0x2af8>
    b6a2:	418b0633          	sub	a2,s6,s8
    b6a6:	89fc450b          	th.lbuib	a0,(s8),-1,0
    b6aa:	ec46                	sd	a7,24(sp)
    b6ac:	f042                	sd	a6,32(sp)
    b6ae:	86a6                	mv	a3,s1
    b6b0:	85ca                	mv	a1,s2
    b6b2:	9402                	jalr	s0
    b6b4:	68e2                	ld	a7,24(sp)
    b6b6:	7802                	ld	a6,32(sp)
    b6b8:	418b0633          	sub	a2,s6,s8
    b6bc:	89fc450b          	th.lbuib	a0,(s8),-1,0
    b6c0:	ec46                	sd	a7,24(sp)
    b6c2:	f042                	sd	a6,32(sp)
    b6c4:	86a6                	mv	a3,s1
    b6c6:	85ca                	mv	a1,s2
    b6c8:	9402                	jalr	s0
    b6ca:	68e2                	ld	a7,24(sp)
    b6cc:	7802                	ld	a6,32(sp)
    b6ce:	418b0633          	sub	a2,s6,s8
    b6d2:	89fc450b          	th.lbuib	a0,(s8),-1,0
    b6d6:	ec46                	sd	a7,24(sp)
    b6d8:	f042                	sd	a6,32(sp)
    b6da:	86a6                	mv	a3,s1
    b6dc:	85ca                	mv	a1,s2
    b6de:	9402                	jalr	s0
    b6e0:	68e2                	ld	a7,24(sp)
    b6e2:	7802                	ld	a6,32(sp)
    b6e4:	418b0633          	sub	a2,s6,s8
    b6e8:	89fc450b          	th.lbuib	a0,(s8),-1,0
    b6ec:	ec46                	sd	a7,24(sp)
    b6ee:	f042                	sd	a6,32(sp)
    b6f0:	86a6                	mv	a3,s1
    b6f2:	85ca                	mv	a1,s2
    b6f4:	9402                	jalr	s0
    b6f6:	68e2                	ld	a7,24(sp)
    b6f8:	7802                	ld	a6,32(sp)
    b6fa:	418b0633          	sub	a2,s6,s8
    b6fe:	89fc450b          	th.lbuib	a0,(s8),-1,0
    b702:	ec46                	sd	a7,24(sp)
    b704:	f042                	sd	a6,32(sp)
    b706:	86a6                	mv	a3,s1
    b708:	85ca                	mv	a1,s2
    b70a:	9402                	jalr	s0
    b70c:	68e2                	ld	a7,24(sp)
    b70e:	7802                	ld	a6,32(sp)
    b710:	418b0633          	sub	a2,s6,s8
    b714:	89fc450b          	th.lbuib	a0,(s8),-1,0
    b718:	ec46                	sd	a7,24(sp)
    b71a:	f042                	sd	a6,32(sp)
    b71c:	86a6                	mv	a3,s1
    b71e:	85ca                	mv	a1,s2
    b720:	9402                	jalr	s0
    b722:	68e2                	ld	a7,24(sp)
    b724:	7802                	ld	a6,32(sp)
    b726:	418b0633          	sub	a2,s6,s8
    b72a:	89fc450b          	th.lbuib	a0,(s8),-1,0
    b72e:	fd01588b          	th.sdd	a7,a6,(sp),2,4
    b732:	86a6                	mv	a3,s1
    b734:	85ca                	mv	a1,s2
    b736:	ec5e                	sd	s7,24(sp)
    b738:	9402                	jalr	s0
    b73a:	fd01488b          	th.ldd	a7,a6,(sp),2,4
    b73e:	6e62                	ld	t3,24(sp)
    b740:	09880963          	beq	a6,s8,b7d2 <_vsnprintf+0x2c12>
    b744:	ec6a                	sd	s10,24(sp)
    b746:	f046                	sd	a7,32(sp)
    b748:	8d42                	mv	s10,a6
    b74a:	8ae2                	mv	s5,s8
    b74c:	89fac50b          	th.lbuib	a0,(s5),-1,0
    b750:	418b0633          	sub	a2,s6,s8
    b754:	86a6                	mv	a3,s1
    b756:	85ca                	mv	a1,s2
    b758:	9402                	jalr	s0
    b75a:	8ce2                	mv	s9,s8
    b75c:	89ecc50b          	th.lbuib	a0,(s9),-2,0
    b760:	415b0633          	sub	a2,s6,s5
    b764:	86a6                	mv	a3,s1
    b766:	85ca                	mv	a1,s2
    b768:	9402                	jalr	s0
    b76a:	8ae2                	mv	s5,s8
    b76c:	89dac50b          	th.lbuib	a0,(s5),-3,0
    b770:	419b0633          	sub	a2,s6,s9
    b774:	86a6                	mv	a3,s1
    b776:	85ca                	mv	a1,s2
    b778:	9402                	jalr	s0
    b77a:	8ce2                	mv	s9,s8
    b77c:	89ccc50b          	th.lbuib	a0,(s9),-4,0
    b780:	415b0633          	sub	a2,s6,s5
    b784:	86a6                	mv	a3,s1
    b786:	85ca                	mv	a1,s2
    b788:	9402                	jalr	s0
    b78a:	8ae2                	mv	s5,s8
    b78c:	89bac50b          	th.lbuib	a0,(s5),-5,0
    b790:	419b0633          	sub	a2,s6,s9
    b794:	86a6                	mv	a3,s1
    b796:	85ca                	mv	a1,s2
    b798:	9402                	jalr	s0
    b79a:	8ce2                	mv	s9,s8
    b79c:	89acc50b          	th.lbuib	a0,(s9),-6,0
    b7a0:	415b0633          	sub	a2,s6,s5
    b7a4:	86a6                	mv	a3,s1
    b7a6:	85ca                	mv	a1,s2
    b7a8:	9402                	jalr	s0
    b7aa:	8ae2                	mv	s5,s8
    b7ac:	899ac50b          	th.lbuib	a0,(s5),-7,0
    b7b0:	86a6                	mv	a3,s1
    b7b2:	419b0633          	sub	a2,s6,s9
    b7b6:	85ca                	mv	a1,s2
    b7b8:	9402                	jalr	s0
    b7ba:	898c450b          	th.lbuib	a0,(s8),-8,0
    b7be:	86a6                	mv	a3,s1
    b7c0:	415b0633          	sub	a2,s6,s5
    b7c4:	85ca                	mv	a1,s2
    b7c6:	9402                	jalr	s0
    b7c8:	f98d11e3          	bne	s10,s8,b74a <_vsnprintf+0x2b8a>
    b7cc:	6d62                	ld	s10,24(sp)
    b7ce:	7882                	ld	a7,32(sp)
    b7d0:	8e5e                	mv	t3,s7
    b7d2:	000d1463          	bnez	s10,b7da <_vsnprintf+0x2c1a>
    b7d6:	ca7fe06f          	j	a47c <_vsnprintf+0x18bc>
    b7da:	7c08bc0b          	th.extu	s8,a7,31,0
    b7de:	6882                	ld	a7,0(sp)
    b7e0:	411e0ab3          	sub	s5,t3,a7
    b7e4:	018ae463          	bltu	s5,s8,b7ec <_vsnprintf+0x2c2c>
    b7e8:	c95fe06f          	j	a47c <_vsnprintf+0x18bc>
    b7ec:	fffac593          	not	a1,s5
    b7f0:	01858633          	add	a2,a1,s8
    b7f4:	00767b93          	andi	s7,a2,7
    b7f8:	86a6                	mv	a3,s1
    b7fa:	8672                	mv	a2,t3
    b7fc:	85ca                	mv	a1,s2
    b7fe:	02000513          	li	a0,32
    b802:	e072                	sd	t3,0(sp)
    b804:	001e0b13          	addi	s6,t3,1
    b808:	001a8d13          	addi	s10,s5,1
    b80c:	9402                	jalr	s0
    b80e:	6782                	ld	a5,0(sp)
    b810:	018d6463          	bltu	s10,s8,b818 <_vsnprintf+0x2c58>
    b814:	c7dfe06f          	j	a490 <_vsnprintf+0x18d0>
    b818:	0a0b8263          	beqz	s7,b8bc <_vsnprintf+0x2cfc>
    b81c:	4e85                	li	t4,1
    b81e:	09db8363          	beq	s7,t4,b8a4 <_vsnprintf+0x2ce4>
    b822:	4709                	li	a4,2
    b824:	06eb8863          	beq	s7,a4,b894 <_vsnprintf+0x2cd4>
    b828:	450d                	li	a0,3
    b82a:	04ab8d63          	beq	s7,a0,b884 <_vsnprintf+0x2cc4>
    b82e:	4311                	li	t1,4
    b830:	046b8263          	beq	s7,t1,b874 <_vsnprintf+0x2cb4>
    b834:	4295                	li	t0,5
    b836:	025b8763          	beq	s7,t0,b864 <_vsnprintf+0x2ca4>
    b83a:	4399                	li	t2,6
    b83c:	007b8c63          	beq	s7,t2,b854 <_vsnprintf+0x2c94>
    b840:	865a                	mv	a2,s6
    b842:	86a6                	mv	a3,s1
    b844:	85ca                	mv	a1,s2
    b846:	02000513          	li	a0,32
    b84a:	00278b13          	addi	s6,a5,2
    b84e:	002a8d13          	addi	s10,s5,2
    b852:	9402                	jalr	s0
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
    b8ae:	0d05                	addi	s10,s10,1
    b8b0:	0b05                	addi	s6,s6,1
    b8b2:	9402                	jalr	s0
    b8b4:	018d6463          	bltu	s10,s8,b8bc <_vsnprintf+0x2cfc>
    b8b8:	bd9fe06f          	j	a490 <_vsnprintf+0x18d0>
    b8bc:	865a                	mv	a2,s6
    b8be:	86a6                	mv	a3,s1
    b8c0:	85ca                	mv	a1,s2
    b8c2:	02000513          	li	a0,32
    b8c6:	9402                	jalr	s0
    b8c8:	001b0c93          	addi	s9,s6,1
    b8cc:	8666                	mv	a2,s9
    b8ce:	86a6                	mv	a3,s1
    b8d0:	85ca                	mv	a1,s2
    b8d2:	02000513          	li	a0,32
    b8d6:	9402                	jalr	s0
    b8d8:	002b0b93          	addi	s7,s6,2
    b8dc:	865e                	mv	a2,s7
    b8de:	86a6                	mv	a3,s1
    b8e0:	85ca                	mv	a1,s2
    b8e2:	02000513          	li	a0,32
    b8e6:	9402                	jalr	s0
    b8e8:	003b0a93          	addi	s5,s6,3
    b8ec:	8656                	mv	a2,s5
    b8ee:	86a6                	mv	a3,s1
    b8f0:	85ca                	mv	a1,s2
    b8f2:	02000513          	li	a0,32
    b8f6:	9402                	jalr	s0
    b8f8:	004b0c93          	addi	s9,s6,4
    b8fc:	8666                	mv	a2,s9
    b8fe:	86a6                	mv	a3,s1
    b900:	85ca                	mv	a1,s2
    b902:	02000513          	li	a0,32
    b906:	9402                	jalr	s0
    b908:	005b0a93          	addi	s5,s6,5
    b90c:	86a6                	mv	a3,s1
    b90e:	8656                	mv	a2,s5
    b910:	85ca                	mv	a1,s2
    b912:	02000513          	li	a0,32
    b916:	9402                	jalr	s0
    b918:	006b0b93          	addi	s7,s6,6
    b91c:	86a6                	mv	a3,s1
    b91e:	865e                	mv	a2,s7
    b920:	85ca                	mv	a1,s2
    b922:	02000513          	li	a0,32
    b926:	9402                	jalr	s0
    b928:	007b0c93          	addi	s9,s6,7
    b92c:	86a6                	mv	a3,s1
    b92e:	8666                	mv	a2,s9
    b930:	85ca                	mv	a1,s2
    b932:	02000513          	li	a0,32
    b936:	0d21                	addi	s10,s10,8
    b938:	0b21                	addi	s6,s6,8
    b93a:	9402                	jalr	s0
    b93c:	f98d60e3          	bltu	s10,s8,b8bc <_vsnprintf+0x2cfc>
    b940:	b51fe06f          	j	a490 <_vsnprintf+0x18d0>
    b944:	e056                	sd	s5,0(sp)
    b946:	b53fe06f          	j	a498 <_vsnprintf+0x18d8>
    b94a:	000c8463          	beqz	s9,b952 <_vsnprintf+0x2d92>
    b94e:	7620106f          	j	d0b0 <_vsnprintf+0x44f0>
    b952:	47c1                	li	a5,16
    b954:	48bd                	li	a7,15
    b956:	8d3e                	mv	s10,a5
    b958:	b4f9                	j	b426 <_vsnprintf+0x2866>
    b95a:	40000a93          	li	s5,1024
    b95e:	011be463          	bltu	s7,a7,b966 <_vsnprintf+0x2da6>
    b962:	0950206f          	j	e1f6 <_vsnprintf+0x5636>
    b966:	6e82                	ld	t4,0(sp)
    b968:	fff8851b          	addiw	a0,a7,-1
    b96c:	41750bbb          	subw	s7,a0,s7
    b970:	7c0bbe0b          	th.extu	t3,s7,31,0
    b974:	001e8b13          	addi	s6,t4,1
    b978:	007e7c93          	andi	s9,t3,7
    b97c:	016e07b3          	add	a5,t3,s6
    b980:	000c9463          	bnez	s9,b988 <_vsnprintf+0x2dc8>
    b984:	6e00106f          	j	d064 <_vsnprintf+0x44a4>
    b988:	6602                	ld	a2,0(sp)
    b98a:	ec46                	sd	a7,24(sp)
    b98c:	f03e                	sd	a5,32(sp)
    b98e:	e05a                	sd	s6,0(sp)
    b990:	86a6                	mv	a3,s1
    b992:	85ca                	mv	a1,s2
    b994:	02000513          	li	a0,32
    b998:	9402                	jalr	s0
    b99a:	4285                	li	t0,1
    b99c:	68e2                	ld	a7,24(sp)
    b99e:	7782                	ld	a5,32(sp)
    b9a0:	865a                	mv	a2,s6
    b9a2:	0b05                	addi	s6,s6,1
    b9a4:	005c9463          	bne	s9,t0,b9ac <_vsnprintf+0x2dec>
    b9a8:	6bc0106f          	j	d064 <_vsnprintf+0x44a4>
    b9ac:	4689                	li	a3,2
    b9ae:	08dc8763          	beq	s9,a3,ba3c <_vsnprintf+0x2e7c>
    b9b2:	430d                	li	t1,3
    b9b4:	066c8863          	beq	s9,t1,ba24 <_vsnprintf+0x2e64>
    b9b8:	4391                	li	t2,4
    b9ba:	047c8963          	beq	s9,t2,ba0c <_vsnprintf+0x2e4c>
    b9be:	4f15                	li	t5,5
    b9c0:	03ec8a63          	beq	s9,t5,b9f4 <_vsnprintf+0x2e34>
    b9c4:	4599                	li	a1,6
    b9c6:	00bc8b63          	beq	s9,a1,b9dc <_vsnprintf+0x2e1c>
    b9ca:	e05a                	sd	s6,0(sp)
    b9cc:	86a6                	mv	a3,s1
    b9ce:	85ca                	mv	a1,s2
    b9d0:	02000513          	li	a0,32
    b9d4:	9402                	jalr	s0
    b9d6:	68e2                	ld	a7,24(sp)
    b9d8:	7782                	ld	a5,32(sp)
    b9da:	0b05                	addi	s6,s6,1
    b9dc:	6602                	ld	a2,0(sp)
    b9de:	ec46                	sd	a7,24(sp)
    b9e0:	f03e                	sd	a5,32(sp)
    b9e2:	e05a                	sd	s6,0(sp)
    b9e4:	86a6                	mv	a3,s1
    b9e6:	85ca                	mv	a1,s2
    b9e8:	02000513          	li	a0,32
    b9ec:	9402                	jalr	s0
    b9ee:	68e2                	ld	a7,24(sp)
    b9f0:	7782                	ld	a5,32(sp)
    b9f2:	0b05                	addi	s6,s6,1
    b9f4:	6602                	ld	a2,0(sp)
    b9f6:	ec46                	sd	a7,24(sp)
    b9f8:	f03e                	sd	a5,32(sp)
    b9fa:	e05a                	sd	s6,0(sp)
    b9fc:	86a6                	mv	a3,s1
    b9fe:	85ca                	mv	a1,s2
    ba00:	02000513          	li	a0,32
    ba04:	9402                	jalr	s0
    ba06:	68e2                	ld	a7,24(sp)
    ba08:	7782                	ld	a5,32(sp)
    ba0a:	0b05                	addi	s6,s6,1
    ba0c:	6602                	ld	a2,0(sp)
    ba0e:	ec46                	sd	a7,24(sp)
    ba10:	f03e                	sd	a5,32(sp)
    ba12:	e05a                	sd	s6,0(sp)
    ba14:	86a6                	mv	a3,s1
    ba16:	85ca                	mv	a1,s2
    ba18:	02000513          	li	a0,32
    ba1c:	9402                	jalr	s0
    ba1e:	68e2                	ld	a7,24(sp)
    ba20:	7782                	ld	a5,32(sp)
    ba22:	0b05                	addi	s6,s6,1
    ba24:	6602                	ld	a2,0(sp)
    ba26:	ec46                	sd	a7,24(sp)
    ba28:	f03e                	sd	a5,32(sp)
    ba2a:	e05a                	sd	s6,0(sp)
    ba2c:	86a6                	mv	a3,s1
    ba2e:	85ca                	mv	a1,s2
    ba30:	02000513          	li	a0,32
    ba34:	9402                	jalr	s0
    ba36:	68e2                	ld	a7,24(sp)
    ba38:	7782                	ld	a5,32(sp)
    ba3a:	0b05                	addi	s6,s6,1
    ba3c:	6602                	ld	a2,0(sp)
    ba3e:	ec46                	sd	a7,24(sp)
    ba40:	f03e                	sd	a5,32(sp)
    ba42:	86a6                	mv	a3,s1
    ba44:	85ca                	mv	a1,s2
    ba46:	02000513          	li	a0,32
    ba4a:	9402                	jalr	s0
    ba4c:	8bda                	mv	s7,s6
    ba4e:	7c82                	ld	s9,32(sp)
    ba50:	0b05                	addi	s6,s6,1
    ba52:	f056                	sd	s5,32(sp)
    ba54:	a895                	j	bac8 <_vsnprintf+0x2f08>
    ba56:	865a                	mv	a2,s6
    ba58:	86a6                	mv	a3,s1
    ba5a:	85ca                	mv	a1,s2
    ba5c:	02000513          	li	a0,32
    ba60:	9402                	jalr	s0
    ba62:	001b0b93          	addi	s7,s6,1
    ba66:	865e                	mv	a2,s7
    ba68:	86a6                	mv	a3,s1
    ba6a:	85ca                	mv	a1,s2
    ba6c:	02000513          	li	a0,32
    ba70:	9402                	jalr	s0
    ba72:	002b0a93          	addi	s5,s6,2
    ba76:	8656                	mv	a2,s5
    ba78:	86a6                	mv	a3,s1
    ba7a:	85ca                	mv	a1,s2
    ba7c:	02000513          	li	a0,32
    ba80:	9402                	jalr	s0
    ba82:	003b0b93          	addi	s7,s6,3
    ba86:	865e                	mv	a2,s7
    ba88:	86a6                	mv	a3,s1
    ba8a:	85ca                	mv	a1,s2
    ba8c:	02000513          	li	a0,32
    ba90:	9402                	jalr	s0
    ba92:	004b0a93          	addi	s5,s6,4
    ba96:	8656                	mv	a2,s5
    ba98:	86a6                	mv	a3,s1
    ba9a:	85ca                	mv	a1,s2
    ba9c:	02000513          	li	a0,32
    baa0:	9402                	jalr	s0
    baa2:	005b0b93          	addi	s7,s6,5
    baa6:	865e                	mv	a2,s7
    baa8:	86a6                	mv	a3,s1
    baaa:	85ca                	mv	a1,s2
    baac:	02000513          	li	a0,32
    bab0:	9402                	jalr	s0
    bab2:	006b0a93          	addi	s5,s6,6
    bab6:	86a6                	mv	a3,s1
    bab8:	8656                	mv	a2,s5
    baba:	85ca                	mv	a1,s2
    babc:	02000513          	li	a0,32
    bac0:	007b0b93          	addi	s7,s6,7
    bac4:	9402                	jalr	s0
    bac6:	0b21                	addi	s6,s6,8
    bac8:	865e                	mv	a2,s7
    baca:	86a6                	mv	a3,s1
    bacc:	85ca                	mv	a1,s2
    bace:	02000513          	li	a0,32
    bad2:	9402                	jalr	s0
    bad4:	f99b11e3          	bne	s6,s9,ba56 <_vsnprintf+0x2e96>
    bad8:	68e2                	ld	a7,24(sp)
    bada:	7a82                	ld	s5,32(sp)
    badc:	000d4503          	lbu	a0,0(s10)
    bae0:	e05a                	sd	s6,0(sp)
    bae2:	00188b9b          	addiw	s7,a7,1
    bae6:	e119                	bnez	a0,baec <_vsnprintf+0x2f2c>
    bae8:	9b1fe06f          	j	a498 <_vsnprintf+0x18d8>
    baec:	000a9463          	bnez	s5,baf4 <_vsnprintf+0x2f34>
    baf0:	b79fe06f          	j	a668 <_vsnprintf+0x1aa8>
    baf4:	4a81                	li	s5,0
    baf6:	e8cfd06f          	j	9182 <_vsnprintf+0x5c2>
    bafa:	400b7b93          	andi	s7,s6,1024
    bafe:	000b8463          	beqz	s7,bb06 <_vsnprintf+0x2f46>
    bb02:	1aa0206f          	j	dcac <_vsnprintf+0x50ec>
    bb06:	002b7e13          	andi	t3,s6,2
    bb0a:	000e0463          	beqz	t3,bb12 <_vsnprintf+0x2f52>
    bb0e:	845fd06f          	j	9352 <_vsnprintf+0x792>
    bb12:	4a81                	li	s5,0
    bb14:	e51be9e3          	bltu	s7,a7,b966 <_vsnprintf+0x2da6>
    bb18:	6c82                	ld	s9,0(sp)
    bb1a:	2b85                	addiw	s7,s7,1
    bb1c:	c119                	beqz	a0,bb22 <_vsnprintf+0x2f62>
    bb1e:	b4bfe06f          	j	a668 <_vsnprintf+0x1aa8>
    bb22:	977fe06f          	j	a498 <_vsnprintf+0x18d8>
    bb26:	0001                	nop
    bb28:	fff7081b          	addiw	a6,a4,-1
    bb2c:	41f7180b          	th.mveqz	a6,a4,t6
    bb30:	41c887bb          	subw	a5,a7,t3
    bb34:	011e32b3          	sltu	t0,t3,a7
    bb38:	002b7313          	andi	t1,s6,2
    bb3c:	42e8170b          	th.mvnez	a4,a6,a4
    bb40:	4050178b          	th.mveqz	a5,zero,t0
    bb44:	8c0303e3          	beqz	t1,b40a <_vsnprintf+0x284a>
    bb48:	4a89                	li	s5,2
    bb4a:	4781                	li	a5,0
    bb4c:	bceff06f          	j	af1a <_vsnprintf+0x235a>
    bb50:	fefb7593          	andi	a1,s6,-17
    bb54:	06900613          	li	a2,105
    bb58:	8f5a                	mv	t5,s6
    bb5a:	2581                	sext.w	a1,a1
    bb5c:	00c50463          	beq	a0,a2,bb64 <_vsnprintf+0x2fa4>
    bb60:	1f50106f          	j	d554 <_vsnprintf+0x4994>
    bb64:	400b7713          	andi	a4,s6,1024
    bb68:	c319                	beqz	a4,bb6e <_vsnprintf+0x2fae>
    bb6a:	f25fe06f          	j	aa8e <_vsnprintf+0x1ece>
    bb6e:	200f7813          	andi	a6,t5,512
    bb72:	56081963          	bnez	a6,c0e4 <_vsnprintf+0x3524>
    bb76:	100f7e93          	andi	t4,t5,256
    bb7a:	000e9463          	bnez	t4,bb82 <_vsnprintf+0x2fc2>
    bb7e:	f33fe06f          	j	aab0 <_vsnprintf+0x1ef0>
    bb82:	c70fe06f          	j	9ff2 <_vsnprintf+0x1432>
    bb86:	410587b3          	sub	a5,a1,a6
    bb8a:	00267393          	andi	t2,a2,2
    bb8e:	00178d93          	addi	s11,a5,1
    bb92:	85b2                	mv	a1,a2
    bb94:	00039463          	bnez	t2,bb9c <_vsnprintf+0x2fdc>
    bb98:	7840106f          	j	d31c <_vsnprintf+0x475c>
    bb9c:	000d0463          	beqz	s10,bba4 <_vsnprintf+0x2fe4>
    bba0:	1840206f          	j	dd24 <_vsnprintf+0x5164>
    bba4:	02000c13          	li	s8,32
    bba8:	4d09                	li	s10,2
    bbaa:	018d8463          	beq	s11,s8,bbb2 <_vsnprintf+0x2ff2>
    bbae:	1990206f          	j	e546 <_vsnprintf+0x5986>
    bbb2:	6682                	ld	a3,0(sp)
    bbb4:	02000d93          	li	s11,32
    bbb8:	00dd8bb3          	add	s7,s11,a3
    bbbc:	007df713          	andi	a4,s11,7
    bbc0:	01b80c33          	add	s8,a6,s11
    bbc4:	01780b33          	add	s6,a6,s7
    bbc8:	c379                	beqz	a4,bc8e <_vsnprintf+0x30ce>
    bbca:	4f85                	li	t6,1
    bbcc:	0bf70363          	beq	a4,t6,bc72 <_vsnprintf+0x30b2>
    bbd0:	4689                	li	a3,2
    bbd2:	08d70563          	beq	a4,a3,bc5c <_vsnprintf+0x309c>
    bbd6:	4f0d                	li	t5,3
    bbd8:	07e70763          	beq	a4,t5,bc46 <_vsnprintf+0x3086>
    bbdc:	4791                	li	a5,4
    bbde:	04f70963          	beq	a4,a5,bc30 <_vsnprintf+0x3070>
    bbe2:	4395                	li	t2,5
    bbe4:	02770b63          	beq	a4,t2,bc1a <_vsnprintf+0x305a>
    bbe8:	4319                	li	t1,6
    bbea:	00670d63          	beq	a4,t1,bc04 <_vsnprintf+0x3044>
    bbee:	418b0633          	sub	a2,s6,s8
    bbf2:	89fc450b          	th.lbuib	a0,(s8),-1,0
    bbf6:	ec46                	sd	a7,24(sp)
    bbf8:	f042                	sd	a6,32(sp)
    bbfa:	86a6                	mv	a3,s1
    bbfc:	85ca                	mv	a1,s2
    bbfe:	9402                	jalr	s0
    bc00:	68e2                	ld	a7,24(sp)
    bc02:	7802                	ld	a6,32(sp)
    bc04:	418b0633          	sub	a2,s6,s8
    bc08:	89fc450b          	th.lbuib	a0,(s8),-1,0
    bc0c:	ec46                	sd	a7,24(sp)
    bc0e:	f042                	sd	a6,32(sp)
    bc10:	86a6                	mv	a3,s1
    bc12:	85ca                	mv	a1,s2
    bc14:	9402                	jalr	s0
    bc16:	68e2                	ld	a7,24(sp)
    bc18:	7802                	ld	a6,32(sp)
    bc1a:	418b0633          	sub	a2,s6,s8
    bc1e:	89fc450b          	th.lbuib	a0,(s8),-1,0
    bc22:	ec46                	sd	a7,24(sp)
    bc24:	f042                	sd	a6,32(sp)
    bc26:	86a6                	mv	a3,s1
    bc28:	85ca                	mv	a1,s2
    bc2a:	9402                	jalr	s0
    bc2c:	68e2                	ld	a7,24(sp)
    bc2e:	7802                	ld	a6,32(sp)
    bc30:	418b0633          	sub	a2,s6,s8
    bc34:	89fc450b          	th.lbuib	a0,(s8),-1,0
    bc38:	ec46                	sd	a7,24(sp)
    bc3a:	f042                	sd	a6,32(sp)
    bc3c:	86a6                	mv	a3,s1
    bc3e:	85ca                	mv	a1,s2
    bc40:	9402                	jalr	s0
    bc42:	68e2                	ld	a7,24(sp)
    bc44:	7802                	ld	a6,32(sp)
    bc46:	418b0633          	sub	a2,s6,s8
    bc4a:	89fc450b          	th.lbuib	a0,(s8),-1,0
    bc4e:	ec46                	sd	a7,24(sp)
    bc50:	f042                	sd	a6,32(sp)
    bc52:	86a6                	mv	a3,s1
    bc54:	85ca                	mv	a1,s2
    bc56:	9402                	jalr	s0
    bc58:	68e2                	ld	a7,24(sp)
    bc5a:	7802                	ld	a6,32(sp)
    bc5c:	418b0633          	sub	a2,s6,s8
    bc60:	89fc450b          	th.lbuib	a0,(s8),-1,0
    bc64:	ec46                	sd	a7,24(sp)
    bc66:	f042                	sd	a6,32(sp)
    bc68:	86a6                	mv	a3,s1
    bc6a:	85ca                	mv	a1,s2
    bc6c:	9402                	jalr	s0
    bc6e:	68e2                	ld	a7,24(sp)
    bc70:	7802                	ld	a6,32(sp)
    bc72:	418b0633          	sub	a2,s6,s8
    bc76:	89fc450b          	th.lbuib	a0,(s8),-1,0
    bc7a:	ec46                	sd	a7,24(sp)
    bc7c:	f042                	sd	a6,32(sp)
    bc7e:	86a6                	mv	a3,s1
    bc80:	85ca                	mv	a1,s2
    bc82:	9402                	jalr	s0
    bc84:	68e2                	ld	a7,24(sp)
    bc86:	7802                	ld	a6,32(sp)
    bc88:	8dde                	mv	s11,s7
    bc8a:	09880b63          	beq	a6,s8,bd20 <_vsnprintf+0x3160>
    bc8e:	ec56                	sd	s5,24(sp)
    bc90:	f06a                	sd	s10,32(sp)
    bc92:	8ac2                	mv	s5,a6
    bc94:	8d46                	mv	s10,a7
    bc96:	8ce2                	mv	s9,s8
    bc98:	89fcc50b          	th.lbuib	a0,(s9),-1,0
    bc9c:	418b0633          	sub	a2,s6,s8
    bca0:	86a6                	mv	a3,s1
    bca2:	85ca                	mv	a1,s2
    bca4:	9402                	jalr	s0
    bca6:	8de2                	mv	s11,s8
    bca8:	89edc50b          	th.lbuib	a0,(s11),-2,0
    bcac:	419b0633          	sub	a2,s6,s9
    bcb0:	86a6                	mv	a3,s1
    bcb2:	85ca                	mv	a1,s2
    bcb4:	9402                	jalr	s0
    bcb6:	8ce2                	mv	s9,s8
    bcb8:	89dcc50b          	th.lbuib	a0,(s9),-3,0
    bcbc:	41bb0633          	sub	a2,s6,s11
    bcc0:	86a6                	mv	a3,s1
    bcc2:	85ca                	mv	a1,s2
    bcc4:	9402                	jalr	s0
    bcc6:	8de2                	mv	s11,s8
    bcc8:	89cdc50b          	th.lbuib	a0,(s11),-4,0
    bccc:	419b0633          	sub	a2,s6,s9
    bcd0:	86a6                	mv	a3,s1
    bcd2:	85ca                	mv	a1,s2
    bcd4:	9402                	jalr	s0
    bcd6:	8ce2                	mv	s9,s8
    bcd8:	89bcc50b          	th.lbuib	a0,(s9),-5,0
    bcdc:	41bb0633          	sub	a2,s6,s11
    bce0:	86a6                	mv	a3,s1
    bce2:	85ca                	mv	a1,s2
    bce4:	9402                	jalr	s0
    bce6:	8de2                	mv	s11,s8
    bce8:	89adc50b          	th.lbuib	a0,(s11),-6,0
    bcec:	419b0633          	sub	a2,s6,s9
    bcf0:	86a6                	mv	a3,s1
    bcf2:	85ca                	mv	a1,s2
    bcf4:	9402                	jalr	s0
    bcf6:	8ce2                	mv	s9,s8
    bcf8:	899cc50b          	th.lbuib	a0,(s9),-7,0
    bcfc:	41bb0633          	sub	a2,s6,s11
    bd00:	86a6                	mv	a3,s1
    bd02:	85ca                	mv	a1,s2
    bd04:	9402                	jalr	s0
    bd06:	898c450b          	th.lbuib	a0,(s8),-8,0
    bd0a:	86a6                	mv	a3,s1
    bd0c:	419b0633          	sub	a2,s6,s9
    bd10:	85ca                	mv	a1,s2
    bd12:	8dde                	mv	s11,s7
    bd14:	9402                	jalr	s0
    bd16:	f98a90e3          	bne	s5,s8,bc96 <_vsnprintf+0x30d6>
    bd1a:	88ea                	mv	a7,s10
    bd1c:	6ae2                	ld	s5,24(sp)
    bd1e:	7d02                	ld	s10,32(sp)
    bd20:	000d1d63          	bnez	s10,bd3a <_vsnprintf+0x317a>
    bd24:	e06e                	sd	s11,0(sp)
    bd26:	8dd6                	mv	s11,s5
    bd28:	f70fe06f          	j	a498 <_vsnprintf+0x18d8>
    bd2c:	002ffd13          	andi	s10,t6,2
    bd30:	000d1463          	bnez	s10,bd38 <_vsnprintf+0x3178>
    bd34:	72c0206f          	j	e460 <_vsnprintf+0x58a0>
    bd38:	6d82                	ld	s11,0(sp)
    bd3a:	6e82                	ld	t4,0(sp)
    bd3c:	7c08bc0b          	th.extu	s8,a7,31,0
    bd40:	41dd8d33          	sub	s10,s11,t4
    bd44:	ff8d70e3          	bgeu	s10,s8,bd24 <_vsnprintf+0x3164>
    bd48:	fffd4893          	not	a7,s10
    bd4c:	01888e33          	add	t3,a7,s8
    bd50:	86a6                	mv	a3,s1
    bd52:	866e                	mv	a2,s11
    bd54:	85ca                	mv	a1,s2
    bd56:	02000513          	li	a0,32
    bd5a:	001d0c93          	addi	s9,s10,1
    bd5e:	007e7b93          	andi	s7,t3,7
    bd62:	001d8b13          	addi	s6,s11,1
    bd66:	9402                	jalr	s0
    bd68:	138cf463          	bgeu	s9,s8,be90 <_vsnprintf+0x32d0>
    bd6c:	0a0b8063          	beqz	s7,be0c <_vsnprintf+0x324c>
    bd70:	4285                	li	t0,1
    bd72:	085b8363          	beq	s7,t0,bdf8 <_vsnprintf+0x3238>
    bd76:	4589                	li	a1,2
    bd78:	06bb8863          	beq	s7,a1,bde8 <_vsnprintf+0x3228>
    bd7c:	460d                	li	a2,3
    bd7e:	04cb8d63          	beq	s7,a2,bdd8 <_vsnprintf+0x3218>
    bd82:	4511                	li	a0,4
    bd84:	04ab8263          	beq	s7,a0,bdc8 <_vsnprintf+0x3208>
    bd88:	4715                	li	a4,5
    bd8a:	02eb8763          	beq	s7,a4,bdb8 <_vsnprintf+0x31f8>
    bd8e:	4f99                	li	t6,6
    bd90:	01fb8c63          	beq	s7,t6,bda8 <_vsnprintf+0x31e8>
    bd94:	865a                	mv	a2,s6
    bd96:	86a6                	mv	a3,s1
    bd98:	85ca                	mv	a1,s2
    bd9a:	02000513          	li	a0,32
    bd9e:	002d8b13          	addi	s6,s11,2
    bda2:	9402                	jalr	s0
    bda4:	002d0c93          	addi	s9,s10,2
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
    be02:	0c85                	addi	s9,s9,1
    be04:	0b05                	addi	s6,s6,1
    be06:	9402                	jalr	s0
    be08:	098cf463          	bgeu	s9,s8,be90 <_vsnprintf+0x32d0>
    be0c:	865a                	mv	a2,s6
    be0e:	86a6                	mv	a3,s1
    be10:	85ca                	mv	a1,s2
    be12:	02000513          	li	a0,32
    be16:	9402                	jalr	s0
    be18:	001b0d93          	addi	s11,s6,1
    be1c:	866e                	mv	a2,s11
    be1e:	86a6                	mv	a3,s1
    be20:	85ca                	mv	a1,s2
    be22:	02000513          	li	a0,32
    be26:	9402                	jalr	s0
    be28:	002b0d13          	addi	s10,s6,2
    be2c:	866a                	mv	a2,s10
    be2e:	86a6                	mv	a3,s1
    be30:	85ca                	mv	a1,s2
    be32:	02000513          	li	a0,32
    be36:	9402                	jalr	s0
    be38:	003b0b93          	addi	s7,s6,3
    be3c:	865e                	mv	a2,s7
    be3e:	86a6                	mv	a3,s1
    be40:	85ca                	mv	a1,s2
    be42:	02000513          	li	a0,32
    be46:	9402                	jalr	s0
    be48:	004b0d93          	addi	s11,s6,4
    be4c:	866e                	mv	a2,s11
    be4e:	86a6                	mv	a3,s1
    be50:	85ca                	mv	a1,s2
    be52:	02000513          	li	a0,32
    be56:	9402                	jalr	s0
    be58:	005b0b93          	addi	s7,s6,5
    be5c:	86a6                	mv	a3,s1
    be5e:	865e                	mv	a2,s7
    be60:	85ca                	mv	a1,s2
    be62:	02000513          	li	a0,32
    be66:	9402                	jalr	s0
    be68:	006b0d13          	addi	s10,s6,6
    be6c:	86a6                	mv	a3,s1
    be6e:	866a                	mv	a2,s10
    be70:	85ca                	mv	a1,s2
    be72:	02000513          	li	a0,32
    be76:	9402                	jalr	s0
    be78:	007b0d93          	addi	s11,s6,7
    be7c:	86a6                	mv	a3,s1
    be7e:	866e                	mv	a2,s11
    be80:	85ca                	mv	a1,s2
    be82:	02000513          	li	a0,32
    be86:	0ca1                	addi	s9,s9,8
    be88:	0b21                	addi	s6,s6,8
    be8a:	9402                	jalr	s0
    be8c:	f98ce0e3          	bltu	s9,s8,be0c <_vsnprintf+0x324c>
    be90:	e05a                	sd	s6,0(sp)
    be92:	8dd6                	mv	s11,s5
    be94:	e04fe06f          	j	a498 <_vsnprintf+0x18d8>
    be98:	886e                	mv	a6,s11
    be9a:	78884e8b          	th.ldia	t4,(a6),8,0
    be9e:	240e9963          	bnez	t4,c0f0 <_vsnprintf+0x3530>
    bea2:	002afd93          	andi	s11,s5,2
    bea6:	000d8463          	beqz	s11,beae <_vsnprintf+0x32ee>
    beaa:	2ae0206f          	j	e158 <_vsnprintf+0x5598>
    beae:	7c0c3c0b          	th.extu	s8,s8,31,0
    beb2:	4781                	li	a5,0
    beb4:	03010c93          	addi	s9,sp,48
    beb8:	00089463          	bnez	a7,bec0 <_vsnprintf+0x3300>
    bebc:	5c80206f          	j	e484 <_vsnprintf+0x58c4>
    bec0:	000c1463          	bnez	s8,bec8 <_vsnprintf+0x3308>
    bec4:	7050206f          	j	edc8 <_vsnprintf+0x6208>
    bec8:	02000a93          	li	s5,32
    becc:	40fa8633          	sub	a2,s5,a5
    bed0:	00767393          	andi	t2,a2,7
    bed4:	00fc8bb3          	add	s7,s9,a5
    bed8:	03000e13          	li	t3,48
    bedc:	06038763          	beqz	t2,bf4a <_vsnprintf+0x338a>
    bee0:	0785                	addi	a5,a5,1
    bee2:	181bde0b          	th.sbia	t3,(s7),1,0
    bee6:	0d87f663          	bgeu	a5,s8,bfb2 <_vsnprintf+0x33f2>
    beea:	4f85                	li	t6,1
    beec:	05f38f63          	beq	t2,t6,bf4a <_vsnprintf+0x338a>
    bef0:	4709                	li	a4,2
    bef2:	04e38763          	beq	t2,a4,bf40 <_vsnprintf+0x3380>
    bef6:	4f0d                	li	t5,3
    bef8:	03e38f63          	beq	t2,t5,bf36 <_vsnprintf+0x3376>
    befc:	4d11                	li	s10,4
    befe:	03a38763          	beq	t2,s10,bf2c <_vsnprintf+0x336c>
    bf02:	4295                	li	t0,5
    bf04:	00538f63          	beq	t2,t0,bf22 <_vsnprintf+0x3362>
    bf08:	4319                	li	t1,6
    bf0a:	00638763          	beq	t2,t1,bf18 <_vsnprintf+0x3358>
    bf0e:	0785                	addi	a5,a5,1
    bf10:	181bde0b          	th.sbia	t3,(s7),1,0
    bf14:	0987ff63          	bgeu	a5,s8,bfb2 <_vsnprintf+0x33f2>
    bf18:	0785                	addi	a5,a5,1
    bf1a:	181bde0b          	th.sbia	t3,(s7),1,0
    bf1e:	0987fa63          	bgeu	a5,s8,bfb2 <_vsnprintf+0x33f2>
    bf22:	0785                	addi	a5,a5,1
    bf24:	181bde0b          	th.sbia	t3,(s7),1,0
    bf28:	0987f563          	bgeu	a5,s8,bfb2 <_vsnprintf+0x33f2>
    bf2c:	0785                	addi	a5,a5,1
    bf2e:	181bde0b          	th.sbia	t3,(s7),1,0
    bf32:	0987f063          	bgeu	a5,s8,bfb2 <_vsnprintf+0x33f2>
    bf36:	0785                	addi	a5,a5,1
    bf38:	181bde0b          	th.sbia	t3,(s7),1,0
    bf3c:	0787fb63          	bgeu	a5,s8,bfb2 <_vsnprintf+0x33f2>
    bf40:	0785                	addi	a5,a5,1
    bf42:	181bde0b          	th.sbia	t3,(s7),1,0
    bf46:	0787f663          	bgeu	a5,s8,bfb2 <_vsnprintf+0x33f2>
    bf4a:	01579463          	bne	a5,s5,bf52 <_vsnprintf+0x3392>
    bf4e:	7800106f          	j	d6ce <_vsnprintf+0x4b0e>
    bf52:	0785                	addi	a5,a5,1
    bf54:	01cb8023          	sb	t3,0(s7)
    bf58:	853e                	mv	a0,a5
    bf5a:	0587fc63          	bgeu	a5,s8,bfb2 <_vsnprintf+0x33f2>
    bf5e:	0785                	addi	a5,a5,1
    bf60:	01cb80a3          	sb	t3,1(s7)
    bf64:	0587f763          	bgeu	a5,s8,bfb2 <_vsnprintf+0x33f2>
    bf68:	00250793          	addi	a5,a0,2
    bf6c:	01cb8123          	sb	t3,2(s7)
    bf70:	0587f163          	bgeu	a5,s8,bfb2 <_vsnprintf+0x33f2>
    bf74:	00350793          	addi	a5,a0,3
    bf78:	01cb81a3          	sb	t3,3(s7)
    bf7c:	0387fb63          	bgeu	a5,s8,bfb2 <_vsnprintf+0x33f2>
    bf80:	00450793          	addi	a5,a0,4
    bf84:	01cb8223          	sb	t3,4(s7)
    bf88:	0387f563          	bgeu	a5,s8,bfb2 <_vsnprintf+0x33f2>
    bf8c:	00550793          	addi	a5,a0,5
    bf90:	01cb82a3          	sb	t3,5(s7)
    bf94:	0187ff63          	bgeu	a5,s8,bfb2 <_vsnprintf+0x33f2>
    bf98:	00650793          	addi	a5,a0,6
    bf9c:	01cb8323          	sb	t3,6(s7)
    bfa0:	0187f963          	bgeu	a5,s8,bfb2 <_vsnprintf+0x33f2>
    bfa4:	01cb83a3          	sb	t3,7(s7)
    bfa8:	00750793          	addi	a5,a0,7
    bfac:	0ba1                	addi	s7,s7,8
    bfae:	f987eee3          	bltu	a5,s8,bf4a <_vsnprintf+0x338a>
    bfb2:	000d9463          	bnez	s11,bfba <_vsnprintf+0x33fa>
    bfb6:	23a0206f          	j	e1f0 <_vsnprintf+0x5630>
    bfba:	7c08b68b          	th.extu	a3,a7,31,0
    bfbe:	00d7e463          	bltu	a5,a3,bfc6 <_vsnprintf+0x3406>
    bfc2:	2b70206f          	j	ea78 <_vsnprintf+0x5eb8>
    bfc6:	02000d93          	li	s11,32
    bfca:	40fd8ab3          	sub	s5,s11,a5
    bfce:	007afe13          	andi	t3,s5,7
    bfd2:	00fc8633          	add	a2,s9,a5
    bfd6:	03000b13          	li	s6,48
    bfda:	060e0763          	beqz	t3,c048 <_vsnprintf+0x3488>
    bfde:	0785                	addi	a5,a5,1
    bfe0:	18165b0b          	th.sbia	s6,(a2),1,0
    bfe4:	0cd78663          	beq	a5,a3,c0b0 <_vsnprintf+0x34f0>
    bfe8:	4385                	li	t2,1
    bfea:	047e0f63          	beq	t3,t2,c048 <_vsnprintf+0x3488>
    bfee:	4f89                	li	t6,2
    bff0:	05fe0763          	beq	t3,t6,c03e <_vsnprintf+0x347e>
    bff4:	470d                	li	a4,3
    bff6:	02ee0f63          	beq	t3,a4,c034 <_vsnprintf+0x3474>
    bffa:	4f11                	li	t5,4
    bffc:	03ee0763          	beq	t3,t5,c02a <_vsnprintf+0x346a>
    c000:	4d15                	li	s10,5
    c002:	01ae0f63          	beq	t3,s10,c020 <_vsnprintf+0x3460>
    c006:	4299                	li	t0,6
    c008:	005e0763          	beq	t3,t0,c016 <_vsnprintf+0x3456>
    c00c:	0785                	addi	a5,a5,1
    c00e:	18165b0b          	th.sbia	s6,(a2),1,0
    c012:	08d78f63          	beq	a5,a3,c0b0 <_vsnprintf+0x34f0>
    c016:	0785                	addi	a5,a5,1
    c018:	18165b0b          	th.sbia	s6,(a2),1,0
    c01c:	08d78a63          	beq	a5,a3,c0b0 <_vsnprintf+0x34f0>
    c020:	0785                	addi	a5,a5,1
    c022:	18165b0b          	th.sbia	s6,(a2),1,0
    c026:	08d78563          	beq	a5,a3,c0b0 <_vsnprintf+0x34f0>
    c02a:	0785                	addi	a5,a5,1
    c02c:	18165b0b          	th.sbia	s6,(a2),1,0
    c030:	08d78063          	beq	a5,a3,c0b0 <_vsnprintf+0x34f0>
    c034:	0785                	addi	a5,a5,1
    c036:	18165b0b          	th.sbia	s6,(a2),1,0
    c03a:	06d78b63          	beq	a5,a3,c0b0 <_vsnprintf+0x34f0>
    c03e:	0785                	addi	a5,a5,1
    c040:	18165b0b          	th.sbia	s6,(a2),1,0
    c044:	06d78663          	beq	a5,a3,c0b0 <_vsnprintf+0x34f0>
    c048:	01b79463          	bne	a5,s11,c050 <_vsnprintf+0x3490>
    c04c:	6640106f          	j	d6b0 <_vsnprintf+0x4af0>
    c050:	00178313          	addi	t1,a5,1
    c054:	01660023          	sb	s6,0(a2)
    c058:	04d30c63          	beq	t1,a3,c0b0 <_vsnprintf+0x34f0>
    c05c:	00278513          	addi	a0,a5,2
    c060:	016600a3          	sb	s6,1(a2)
    c064:	04d50663          	beq	a0,a3,c0b0 <_vsnprintf+0x34f0>
    c068:	00378b93          	addi	s7,a5,3
    c06c:	01660123          	sb	s6,2(a2)
    c070:	04db8063          	beq	s7,a3,c0b0 <_vsnprintf+0x34f0>
    c074:	00478c13          	addi	s8,a5,4
    c078:	016601a3          	sb	s6,3(a2)
    c07c:	02dc0a63          	beq	s8,a3,c0b0 <_vsnprintf+0x34f0>
    c080:	00578a93          	addi	s5,a5,5
    c084:	01660223          	sb	s6,4(a2)
    c088:	02da8463          	beq	s5,a3,c0b0 <_vsnprintf+0x34f0>
    c08c:	00678e13          	addi	t3,a5,6
    c090:	016602a3          	sb	s6,5(a2)
    c094:	00de0e63          	beq	t3,a3,c0b0 <_vsnprintf+0x34f0>
    c098:	00778393          	addi	t2,a5,7
    c09c:	01660323          	sb	s6,6(a2)
    c0a0:	00d38863          	beq	t2,a3,c0b0 <_vsnprintf+0x34f0>
    c0a4:	016603a3          	sb	s6,7(a2)
    c0a8:	07a1                	addi	a5,a5,8
    c0aa:	0621                	addi	a2,a2,8
    c0ac:	f8d79ee3          	bne	a5,a3,c048 <_vsnprintf+0x3488>
    c0b0:	02000793          	li	a5,32
    c0b4:	00f69463          	bne	a3,a5,c0bc <_vsnprintf+0x34fc>
    c0b8:	5f80106f          	j	d6b0 <_vsnprintf+0x4af0>
    c0bc:	000ec463          	bltz	t4,c0c4 <_vsnprintf+0x3504>
    c0c0:	07b0206f          	j	e93a <_vsnprintf+0x5d7a>
    c0c4:	00268ab3          	add	s5,a3,sp
    c0c8:	02d00513          	li	a0,45
    c0cc:	02aa8823          	sb	a0,48(s5)
    c0d0:	0035fe13          	andi	t3,a1,3
    c0d4:	00168c13          	addi	s8,a3,1
    c0d8:	380e06e3          	beqz	t3,cc64 <_vsnprintf+0x40a4>
    c0dc:	8dc2                	mv	s11,a6
    c0de:	4b01                	li	s6,0
    c0e0:	6802                	ld	a6,0(sp)
    c0e2:	aaa5                	j	c25a <_vsnprintf+0x369a>
    c0e4:	886e                	mv	a6,s11
    c0e6:	78884e8b          	th.ldia	t4,(a6),8,0
    c0ea:	4b81                	li	s7,0
    c0ec:	000e8863          	beqz	t4,c0fc <_vsnprintf+0x353c>
    c0f0:	43fedd93          	srai	s11,t4,0x3f
    c0f4:	01ddc533          	xor	a0,s11,t4
    c0f8:	41b50bb3          	sub	s7,a0,s11
    c0fc:	46a9                	li	a3,10
    c0fe:	02dbfb33          	remu	s6,s7,a3
    c102:	03010c93          	addi	s9,sp,48
    c106:	4d25                	li	s10,9
    c108:	87e6                	mv	a5,s9
    c10a:	030b0a9b          	addiw	s5,s6,48
    c10e:	03510823          	sb	s5,48(sp)
    c112:	02dbd533          	divu	a0,s7,a3
    c116:	117d7d63          	bgeu	s10,s7,c230 <_vsnprintf+0x3670>
    c11a:	03110793          	addi	a5,sp,49
    c11e:	02d57333          	remu	t1,a0,a3
    c122:	03030e1b          	addiw	t3,t1,48
    c126:	01c78023          	sb	t3,0(a5)
    c12a:	02d55633          	divu	a2,a0,a3
    c12e:	10ad7163          	bgeu	s10,a0,c230 <_vsnprintf+0x3670>
    c132:	0001                	nop
    c134:	00000013          	nop
    c138:	00178293          	addi	t0,a5,1
    c13c:	05010f93          	addi	t6,sp,80
    c140:	0e5f8863          	beq	t6,t0,c230 <_vsnprintf+0x3670>
    c144:	8796                	mv	a5,t0
    c146:	02d673b3          	remu	t2,a2,a3
    c14a:	0303871b          	addiw	a4,t2,48
    c14e:	00e28023          	sb	a4,0(t0)
    c152:	02d65f33          	divu	t5,a2,a3
    c156:	0ccd7d63          	bgeu	s10,a2,c230 <_vsnprintf+0x3670>
    c15a:	02df7333          	remu	t1,t5,a3
    c15e:	03030d9b          	addiw	s11,t1,48
    c162:	0817dd8b          	th.sbib	s11,(a5),1,0
    c166:	02df5533          	divu	a0,t5,a3
    c16a:	0ded7363          	bgeu	s10,t5,c230 <_vsnprintf+0x3670>
    c16e:	00228793          	addi	a5,t0,2
    c172:	02d57bb3          	remu	s7,a0,a3
    c176:	030b8b1b          	addiw	s6,s7,48
    c17a:	01628123          	sb	s6,2(t0)
    c17e:	02d55ab3          	divu	s5,a0,a3
    c182:	0aad7763          	bgeu	s10,a0,c230 <_vsnprintf+0x3670>
    c186:	00328793          	addi	a5,t0,3
    c18a:	02dafe33          	remu	t3,s5,a3
    c18e:	030e061b          	addiw	a2,t3,48
    c192:	00c281a3          	sb	a2,3(t0)
    c196:	02dadfb3          	divu	t6,s5,a3
    c19a:	095d7b63          	bgeu	s10,s5,c230 <_vsnprintf+0x3670>
    c19e:	00428793          	addi	a5,t0,4
    c1a2:	02dff3b3          	remu	t2,t6,a3
    c1a6:	0303871b          	addiw	a4,t2,48
    c1aa:	00e28223          	sb	a4,4(t0)
    c1ae:	02dfdf33          	divu	t5,t6,a3
    c1b2:	07fd7f63          	bgeu	s10,t6,c230 <_vsnprintf+0x3670>
    c1b6:	00528793          	addi	a5,t0,5
    c1ba:	02df7333          	remu	t1,t5,a3
    c1be:	03030d9b          	addiw	s11,t1,48
    c1c2:	01b282a3          	sb	s11,5(t0)
    c1c6:	02df5533          	divu	a0,t5,a3
    c1ca:	07ed7363          	bgeu	s10,t5,c230 <_vsnprintf+0x3670>
    c1ce:	00628793          	addi	a5,t0,6
    c1d2:	02d57bb3          	remu	s7,a0,a3
    c1d6:	030b8b1b          	addiw	s6,s7,48
    c1da:	01628323          	sb	s6,6(t0)
    c1de:	02d55ab3          	divu	s5,a0,a3
    c1e2:	04ad7763          	bgeu	s10,a0,c230 <_vsnprintf+0x3670>
    c1e6:	00728793          	addi	a5,t0,7
    c1ea:	02dafe33          	remu	t3,s5,a3
    c1ee:	030e061b          	addiw	a2,t3,48
    c1f2:	00c283a3          	sb	a2,7(t0)
    c1f6:	02dadfb3          	divu	t6,s5,a3
    c1fa:	035d7b63          	bgeu	s10,s5,c230 <_vsnprintf+0x3670>
    c1fe:	00828793          	addi	a5,t0,8
    c202:	02dff3b3          	remu	t2,t6,a3
    c206:	0303871b          	addiw	a4,t2,48
    c20a:	00e28423          	sb	a4,8(t0)
    c20e:	02dfdf33          	divu	t5,t6,a3
    c212:	01fd7f63          	bgeu	s10,t6,c230 <_vsnprintf+0x3670>
    c216:	00928793          	addi	a5,t0,9
    c21a:	857a                	mv	a0,t5
    c21c:	02df7333          	remu	t1,t5,a3
    c220:	03030e1b          	addiw	t3,t1,48
    c224:	01c78023          	sb	t3,0(a5)
    c228:	02d55633          	divu	a2,a0,a3
    c22c:	f0ad66e3          	bltu	s10,a0,c138 <_vsnprintf+0x3578>
    c230:	419787b3          	sub	a5,a5,s9
    c234:	0025fb13          	andi	s6,a1,2
    c238:	0785                	addi	a5,a5,1
    c23a:	86ae                	mv	a3,a1
    c23c:	1e0b04e3          	beqz	s6,cc24 <_vsnprintf+0x4064>
    c240:	02000c13          	li	s8,32
    c244:	4b09                	li	s6,2
    c246:	01878463          	beq	a5,s8,c24e <_vsnprintf+0x368e>
    c24a:	1b50106f          	j	dbfe <_vsnprintf+0x503e>
    c24e:	8dc2                	mv	s11,a6
    c250:	04f14503          	lbu	a0,79(sp)
    c254:	6802                	ld	a6,0(sp)
    c256:	02000c13          	li	s8,32
    c25a:	018c8d33          	add	s10,s9,s8
    c25e:	01880bb3          	add	s7,a6,s8
    c262:	fffcc813          	not	a6,s9
    c266:	01a802b3          	add	t0,a6,s10
    c26a:	0072f313          	andi	t1,t0,7
    c26e:	017c8c33          	add	s8,s9,s7
    c272:	00031463          	bnez	t1,c27a <_vsnprintf+0x36ba>
    c276:	2e80106f          	j	d55e <_vsnprintf+0x499e>
    c27a:	41ac0633          	sub	a2,s8,s10
    c27e:	ec46                	sd	a7,24(sp)
    c280:	f01a                	sd	t1,32(sp)
    c282:	86a6                	mv	a3,s1
    c284:	85ca                	mv	a1,s2
    c286:	9402                	jalr	s0
    c288:	68e2                	ld	a7,24(sp)
    c28a:	7e02                	ld	t3,32(sp)
    c28c:	4a85                	li	s5,1
    c28e:	1d7d                	addi	s10,s10,-1
    c290:	fffd4503          	lbu	a0,-1(s10)
    c294:	015e1463          	bne	t3,s5,c29c <_vsnprintf+0x36dc>
    c298:	2c60106f          	j	d55e <_vsnprintf+0x499e>
    c29c:	4609                	li	a2,2
    c29e:	06ce0f63          	beq	t3,a2,c31c <_vsnprintf+0x375c>
    c2a2:	438d                	li	t2,3
    c2a4:	067e0263          	beq	t3,t2,c308 <_vsnprintf+0x3748>
    c2a8:	4791                	li	a5,4
    c2aa:	04fe0563          	beq	t3,a5,c2f4 <_vsnprintf+0x3734>
    c2ae:	4e95                	li	t4,5
    c2b0:	03de0863          	beq	t3,t4,c2e0 <_vsnprintf+0x3720>
    c2b4:	4599                	li	a1,6
    c2b6:	00be0b63          	beq	t3,a1,c2cc <_vsnprintf+0x370c>
    c2ba:	41ac0633          	sub	a2,s8,s10
    c2be:	86a6                	mv	a3,s1
    c2c0:	85ca                	mv	a1,s2
    c2c2:	9402                	jalr	s0
    c2c4:	68e2                	ld	a7,24(sp)
    c2c6:	ffed4503          	lbu	a0,-2(s10)
    c2ca:	1d7d                	addi	s10,s10,-1
    c2cc:	41ac0633          	sub	a2,s8,s10
    c2d0:	ec46                	sd	a7,24(sp)
    c2d2:	86a6                	mv	a3,s1
    c2d4:	85ca                	mv	a1,s2
    c2d6:	9402                	jalr	s0
    c2d8:	68e2                	ld	a7,24(sp)
    c2da:	ffed4503          	lbu	a0,-2(s10)
    c2de:	1d7d                	addi	s10,s10,-1
    c2e0:	41ac0633          	sub	a2,s8,s10
    c2e4:	ec46                	sd	a7,24(sp)
    c2e6:	86a6                	mv	a3,s1
    c2e8:	85ca                	mv	a1,s2
    c2ea:	9402                	jalr	s0
    c2ec:	68e2                	ld	a7,24(sp)
    c2ee:	ffed4503          	lbu	a0,-2(s10)
    c2f2:	1d7d                	addi	s10,s10,-1
    c2f4:	41ac0633          	sub	a2,s8,s10
    c2f8:	ec46                	sd	a7,24(sp)
    c2fa:	86a6                	mv	a3,s1
    c2fc:	85ca                	mv	a1,s2
    c2fe:	9402                	jalr	s0
    c300:	68e2                	ld	a7,24(sp)
    c302:	ffed4503          	lbu	a0,-2(s10)
    c306:	1d7d                	addi	s10,s10,-1
    c308:	41ac0633          	sub	a2,s8,s10
    c30c:	ec46                	sd	a7,24(sp)
    c30e:	86a6                	mv	a3,s1
    c310:	85ca                	mv	a1,s2
    c312:	9402                	jalr	s0
    c314:	68e2                	ld	a7,24(sp)
    c316:	ffed4503          	lbu	a0,-2(s10)
    c31a:	1d7d                	addi	s10,s10,-1
    c31c:	41ac0633          	sub	a2,s8,s10
    c320:	86a6                	mv	a3,s1
    c322:	85ca                	mv	a1,s2
    c324:	ec46                	sd	a7,24(sp)
    c326:	9402                	jalr	s0
    c328:	1d7d                	addi	s10,s10,-1
    c32a:	f05a                	sd	s6,32(sp)
    c32c:	fffd4503          	lbu	a0,-1(s10)
    c330:	a895                	j	c3a4 <_vsnprintf+0x37e4>
    c332:	8b6a                	mv	s6,s10
    c334:	40ac0633          	sub	a2,s8,a0
    c338:	89eb450b          	th.lbuib	a0,(s6),-2,0
    c33c:	86a6                	mv	a3,s1
    c33e:	85ca                	mv	a1,s2
    c340:	9402                	jalr	s0
    c342:	8aea                	mv	s5,s10
    c344:	89dac50b          	th.lbuib	a0,(s5),-3,0
    c348:	416c0633          	sub	a2,s8,s6
    c34c:	86a6                	mv	a3,s1
    c34e:	85ca                	mv	a1,s2
    c350:	9402                	jalr	s0
    c352:	8b6a                	mv	s6,s10
    c354:	89cb450b          	th.lbuib	a0,(s6),-4,0
    c358:	415c0633          	sub	a2,s8,s5
    c35c:	86a6                	mv	a3,s1
    c35e:	85ca                	mv	a1,s2
    c360:	9402                	jalr	s0
    c362:	8aea                	mv	s5,s10
    c364:	89bac50b          	th.lbuib	a0,(s5),-5,0
    c368:	416c0633          	sub	a2,s8,s6
    c36c:	86a6                	mv	a3,s1
    c36e:	85ca                	mv	a1,s2
    c370:	9402                	jalr	s0
    c372:	8b6a                	mv	s6,s10
    c374:	89ab450b          	th.lbuib	a0,(s6),-6,0
    c378:	415c0633          	sub	a2,s8,s5
    c37c:	86a6                	mv	a3,s1
    c37e:	85ca                	mv	a1,s2
    c380:	9402                	jalr	s0
    c382:	8aea                	mv	s5,s10
    c384:	899ac50b          	th.lbuib	a0,(s5),-7,0
    c388:	86a6                	mv	a3,s1
    c38a:	416c0633          	sub	a2,s8,s6
    c38e:	85ca                	mv	a1,s2
    c390:	9402                	jalr	s0
    c392:	898d450b          	th.lbuib	a0,(s10),-8,0
    c396:	86a6                	mv	a3,s1
    c398:	415c0633          	sub	a2,s8,s5
    c39c:	85ca                	mv	a1,s2
    c39e:	9402                	jalr	s0
    c3a0:	fffd4503          	lbu	a0,-1(s10)
    c3a4:	86a6                	mv	a3,s1
    c3a6:	41ac0633          	sub	a2,s8,s10
    c3aa:	85ca                	mv	a1,s2
    c3ac:	9402                	jalr	s0
    c3ae:	fffd0513          	addi	a0,s10,-1
    c3b2:	f8ac90e3          	bne	s9,a0,c332 <_vsnprintf+0x3772>
    c3b6:	68e2                	ld	a7,24(sp)
    c3b8:	7b02                	ld	s6,32(sp)
    c3ba:	8e5e                	mv	t3,s7
    c3bc:	000b1463          	bnez	s6,c3c4 <_vsnprintf+0x3804>
    c3c0:	8bcfe06f          	j	a47c <_vsnprintf+0x18bc>
    c3c4:	7c08bc0b          	th.extu	s8,a7,31,0
    c3c8:	6882                	ld	a7,0(sp)
    c3ca:	411e0ab3          	sub	s5,t3,a7
    c3ce:	018ae463          	bltu	s5,s8,c3d6 <_vsnprintf+0x3816>
    c3d2:	8aafe06f          	j	a47c <_vsnprintf+0x18bc>
    c3d6:	fffac693          	not	a3,s5
    c3da:	01868fb3          	add	t6,a3,s8
    c3de:	8672                	mv	a2,t3
    c3e0:	86a6                	mv	a3,s1
    c3e2:	85ca                	mv	a1,s2
    c3e4:	02000513          	li	a0,32
    c3e8:	e072                	sd	t3,0(sp)
    c3ea:	007ffb93          	andi	s7,t6,7
    c3ee:	001e0b13          	addi	s6,t3,1
    c3f2:	001a8c93          	addi	s9,s5,1
    c3f6:	9402                	jalr	s0
    c3f8:	6f02                	ld	t5,0(sp)
    c3fa:	018ce463          	bltu	s9,s8,c402 <_vsnprintf+0x3842>
    c3fe:	892fe06f          	j	a490 <_vsnprintf+0x18d0>
    c402:	0a0b8263          	beqz	s7,c4a6 <_vsnprintf+0x38e6>
    c406:	4705                	li	a4,1
    c408:	08eb8363          	beq	s7,a4,c48e <_vsnprintf+0x38ce>
    c40c:	4809                	li	a6,2
    c40e:	070b8863          	beq	s7,a6,c47e <_vsnprintf+0x38be>
    c412:	428d                	li	t0,3
    c414:	045b8d63          	beq	s7,t0,c46e <_vsnprintf+0x38ae>
    c418:	4311                	li	t1,4
    c41a:	046b8263          	beq	s7,t1,c45e <_vsnprintf+0x389e>
    c41e:	4e15                	li	t3,5
    c420:	03cb8763          	beq	s7,t3,c44e <_vsnprintf+0x388e>
    c424:	4619                	li	a2,6
    c426:	00cb8c63          	beq	s7,a2,c43e <_vsnprintf+0x387e>
    c42a:	865a                	mv	a2,s6
    c42c:	86a6                	mv	a3,s1
    c42e:	85ca                	mv	a1,s2
    c430:	02000513          	li	a0,32
    c434:	002f0b13          	addi	s6,t5,2
    c438:	002a8c93          	addi	s9,s5,2
    c43c:	9402                	jalr	s0
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
    c498:	0c85                	addi	s9,s9,1
    c49a:	0b05                	addi	s6,s6,1
    c49c:	9402                	jalr	s0
    c49e:	018ce463          	bltu	s9,s8,c4a6 <_vsnprintf+0x38e6>
    c4a2:	feffd06f          	j	a490 <_vsnprintf+0x18d0>
    c4a6:	865a                	mv	a2,s6
    c4a8:	86a6                	mv	a3,s1
    c4aa:	85ca                	mv	a1,s2
    c4ac:	02000513          	li	a0,32
    c4b0:	9402                	jalr	s0
    c4b2:	001b0d13          	addi	s10,s6,1
    c4b6:	866a                	mv	a2,s10
    c4b8:	86a6                	mv	a3,s1
    c4ba:	85ca                	mv	a1,s2
    c4bc:	02000513          	li	a0,32
    c4c0:	9402                	jalr	s0
    c4c2:	002b0b93          	addi	s7,s6,2
    c4c6:	865e                	mv	a2,s7
    c4c8:	86a6                	mv	a3,s1
    c4ca:	85ca                	mv	a1,s2
    c4cc:	02000513          	li	a0,32
    c4d0:	9402                	jalr	s0
    c4d2:	003b0a93          	addi	s5,s6,3
    c4d6:	8656                	mv	a2,s5
    c4d8:	86a6                	mv	a3,s1
    c4da:	85ca                	mv	a1,s2
    c4dc:	02000513          	li	a0,32
    c4e0:	9402                	jalr	s0
    c4e2:	004b0d13          	addi	s10,s6,4
    c4e6:	866a                	mv	a2,s10
    c4e8:	86a6                	mv	a3,s1
    c4ea:	85ca                	mv	a1,s2
    c4ec:	02000513          	li	a0,32
    c4f0:	9402                	jalr	s0
    c4f2:	005b0a93          	addi	s5,s6,5
    c4f6:	86a6                	mv	a3,s1
    c4f8:	8656                	mv	a2,s5
    c4fa:	85ca                	mv	a1,s2
    c4fc:	02000513          	li	a0,32
    c500:	9402                	jalr	s0
    c502:	006b0b93          	addi	s7,s6,6
    c506:	86a6                	mv	a3,s1
    c508:	865e                	mv	a2,s7
    c50a:	85ca                	mv	a1,s2
    c50c:	02000513          	li	a0,32
    c510:	9402                	jalr	s0
    c512:	007b0d13          	addi	s10,s6,7
    c516:	86a6                	mv	a3,s1
    c518:	866a                	mv	a2,s10
    c51a:	85ca                	mv	a1,s2
    c51c:	02000513          	li	a0,32
    c520:	0ca1                	addi	s9,s9,8
    c522:	0b21                	addi	s6,s6,8
    c524:	9402                	jalr	s0
    c526:	f98ce0e3          	bltu	s9,s8,c4a6 <_vsnprintf+0x38e6>
    c52a:	f67fd06f          	j	a490 <_vsnprintf+0x18d0>
    c52e:	0001                	nop
    c530:	5c088be3          	beqz	a7,d306 <_vsnprintf+0x4746>
    c534:	001aff93          	andi	t6,s5,1
    c538:	000f9463          	bnez	t6,c540 <_vsnprintf+0x3980>
    c53c:	3d10106f          	j	e10c <_vsnprintf+0x554c>
    c540:	000e4463          	bltz	t3,c548 <_vsnprintf+0x3988>
    c544:	07a0206f          	j	e5be <_vsnprintf+0x59fe>
    c548:	7c0c3c0b          	th.extu	s8,s8,31,0
    c54c:	38fd                	addiw	a7,a7,-1
    c54e:	0187e463          	bltu	a5,s8,c556 <_vsnprintf+0x3996>
    c552:	0d70206f          	j	ee28 <_vsnprintf+0x6268>
    c556:	02000393          	li	t2,32
    c55a:	40f38f33          	sub	t5,t2,a5
    c55e:	007f7313          	andi	t1,t5,7
    c562:	00fb86b3          	add	a3,s7,a5
    c566:	03000b13          	li	s6,48
    c56a:	06030763          	beqz	t1,c5d8 <_vsnprintf+0x3a18>
    c56e:	0785                	addi	a5,a5,1
    c570:	1816db0b          	th.sbia	s6,(a3),1,0
    c574:	0d87f463          	bgeu	a5,s8,c63c <_vsnprintf+0x3a7c>
    c578:	4805                	li	a6,1
    c57a:	05030f63          	beq	t1,a6,c5d8 <_vsnprintf+0x3a18>
    c57e:	4e89                	li	t4,2
    c580:	05d30763          	beq	t1,t4,c5ce <_vsnprintf+0x3a0e>
    c584:	450d                	li	a0,3
    c586:	02a30f63          	beq	t1,a0,c5c4 <_vsnprintf+0x3a04>
    c58a:	4611                	li	a2,4
    c58c:	02c30763          	beq	t1,a2,c5ba <_vsnprintf+0x39fa>
    c590:	4c95                	li	s9,5
    c592:	01930f63          	beq	t1,s9,c5b0 <_vsnprintf+0x39f0>
    c596:	4719                	li	a4,6
    c598:	00e30763          	beq	t1,a4,c5a6 <_vsnprintf+0x39e6>
    c59c:	0785                	addi	a5,a5,1
    c59e:	1816db0b          	th.sbia	s6,(a3),1,0
    c5a2:	0987fd63          	bgeu	a5,s8,c63c <_vsnprintf+0x3a7c>
    c5a6:	0785                	addi	a5,a5,1
    c5a8:	1816db0b          	th.sbia	s6,(a3),1,0
    c5ac:	0987f863          	bgeu	a5,s8,c63c <_vsnprintf+0x3a7c>
    c5b0:	0785                	addi	a5,a5,1
    c5b2:	1816db0b          	th.sbia	s6,(a3),1,0
    c5b6:	0987f363          	bgeu	a5,s8,c63c <_vsnprintf+0x3a7c>
    c5ba:	0785                	addi	a5,a5,1
    c5bc:	1816db0b          	th.sbia	s6,(a3),1,0
    c5c0:	0787fe63          	bgeu	a5,s8,c63c <_vsnprintf+0x3a7c>
    c5c4:	0785                	addi	a5,a5,1
    c5c6:	1816db0b          	th.sbia	s6,(a3),1,0
    c5ca:	0787f963          	bgeu	a5,s8,c63c <_vsnprintf+0x3a7c>
    c5ce:	0785                	addi	a5,a5,1
    c5d0:	1816db0b          	th.sbia	s6,(a3),1,0
    c5d4:	0787f463          	bgeu	a5,s8,c63c <_vsnprintf+0x3a7c>
    c5d8:	50778ce3          	beq	a5,t2,d2f0 <_vsnprintf+0x4730>
    c5dc:	0785                	addi	a5,a5,1
    c5de:	01668023          	sb	s6,0(a3)
    c5e2:	8abe                	mv	s5,a5
    c5e4:	0587fc63          	bgeu	a5,s8,c63c <_vsnprintf+0x3a7c>
    c5e8:	0785                	addi	a5,a5,1
    c5ea:	016680a3          	sb	s6,1(a3)
    c5ee:	0587f763          	bgeu	a5,s8,c63c <_vsnprintf+0x3a7c>
    c5f2:	002a8793          	addi	a5,s5,2
    c5f6:	01668123          	sb	s6,2(a3)
    c5fa:	0587f163          	bgeu	a5,s8,c63c <_vsnprintf+0x3a7c>
    c5fe:	003a8793          	addi	a5,s5,3
    c602:	016681a3          	sb	s6,3(a3)
    c606:	0387fb63          	bgeu	a5,s8,c63c <_vsnprintf+0x3a7c>
    c60a:	004a8793          	addi	a5,s5,4
    c60e:	01668223          	sb	s6,4(a3)
    c612:	0387f563          	bgeu	a5,s8,c63c <_vsnprintf+0x3a7c>
    c616:	005a8793          	addi	a5,s5,5
    c61a:	016682a3          	sb	s6,5(a3)
    c61e:	0187ff63          	bgeu	a5,s8,c63c <_vsnprintf+0x3a7c>
    c622:	006a8793          	addi	a5,s5,6
    c626:	01668323          	sb	s6,6(a3)
    c62a:	0187f963          	bgeu	a5,s8,c63c <_vsnprintf+0x3a7c>
    c62e:	016683a3          	sb	s6,7(a3)
    c632:	007a8793          	addi	a5,s5,7
    c636:	06a1                	addi	a3,a3,8
    c638:	fb87e0e3          	bltu	a5,s8,c5d8 <_vsnprintf+0x3a18>
    c63c:	0e0f8b63          	beqz	t6,c732 <_vsnprintf+0x3b72>
    c640:	7c08bf8b          	th.extu	t6,a7,31,0
    c644:	01f7e463          	bltu	a5,t6,c64c <_vsnprintf+0x3a8c>
    c648:	12d0206f          	j	ef74 <_vsnprintf+0x63b4>
    c64c:	02000293          	li	t0,32
    c650:	40f28d33          	sub	s10,t0,a5
    c654:	007d7393          	andi	t2,s10,7
    c658:	00fb8cb3          	add	s9,s7,a5
    c65c:	03000c13          	li	s8,48
    c660:	06038763          	beqz	t2,c6ce <_vsnprintf+0x3b0e>
    c664:	0785                	addi	a5,a5,1
    c666:	181cdc0b          	th.sbia	s8,(s9),1,0
    c66a:	0df78463          	beq	a5,t6,c732 <_vsnprintf+0x3b72>
    c66e:	4b05                	li	s6,1
    c670:	05638f63          	beq	t2,s6,c6ce <_vsnprintf+0x3b0e>
    c674:	4f09                	li	t5,2
    c676:	05e38763          	beq	t2,t5,c6c4 <_vsnprintf+0x3b04>
    c67a:	430d                	li	t1,3
    c67c:	02638f63          	beq	t2,t1,c6ba <_vsnprintf+0x3afa>
    c680:	4811                	li	a6,4
    c682:	03038763          	beq	t2,a6,c6b0 <_vsnprintf+0x3af0>
    c686:	4e95                	li	t4,5
    c688:	01d38f63          	beq	t2,t4,c6a6 <_vsnprintf+0x3ae6>
    c68c:	4519                	li	a0,6
    c68e:	00a38763          	beq	t2,a0,c69c <_vsnprintf+0x3adc>
    c692:	0785                	addi	a5,a5,1
    c694:	181cdc0b          	th.sbia	s8,(s9),1,0
    c698:	09f78d63          	beq	a5,t6,c732 <_vsnprintf+0x3b72>
    c69c:	0785                	addi	a5,a5,1
    c69e:	181cdc0b          	th.sbia	s8,(s9),1,0
    c6a2:	09f78863          	beq	a5,t6,c732 <_vsnprintf+0x3b72>
    c6a6:	0785                	addi	a5,a5,1
    c6a8:	181cdc0b          	th.sbia	s8,(s9),1,0
    c6ac:	09f78363          	beq	a5,t6,c732 <_vsnprintf+0x3b72>
    c6b0:	0785                	addi	a5,a5,1
    c6b2:	181cdc0b          	th.sbia	s8,(s9),1,0
    c6b6:	07f78e63          	beq	a5,t6,c732 <_vsnprintf+0x3b72>
    c6ba:	0785                	addi	a5,a5,1
    c6bc:	181cdc0b          	th.sbia	s8,(s9),1,0
    c6c0:	07f78963          	beq	a5,t6,c732 <_vsnprintf+0x3b72>
    c6c4:	0785                	addi	a5,a5,1
    c6c6:	181cdc0b          	th.sbia	s8,(s9),1,0
    c6ca:	07f78463          	beq	a5,t6,c732 <_vsnprintf+0x3b72>
    c6ce:	3e578ae3          	beq	a5,t0,d2c2 <_vsnprintf+0x4702>
    c6d2:	0785                	addi	a5,a5,1
    c6d4:	018c8023          	sb	s8,0(s9)
    c6d8:	863e                	mv	a2,a5
    c6da:	05f78c63          	beq	a5,t6,c732 <_vsnprintf+0x3b72>
    c6de:	0785                	addi	a5,a5,1
    c6e0:	018c80a3          	sb	s8,1(s9)
    c6e4:	05f78763          	beq	a5,t6,c732 <_vsnprintf+0x3b72>
    c6e8:	00260793          	addi	a5,a2,2
    c6ec:	018c8123          	sb	s8,2(s9)
    c6f0:	05f78163          	beq	a5,t6,c732 <_vsnprintf+0x3b72>
    c6f4:	00360793          	addi	a5,a2,3
    c6f8:	018c81a3          	sb	s8,3(s9)
    c6fc:	03f78b63          	beq	a5,t6,c732 <_vsnprintf+0x3b72>
    c700:	00460793          	addi	a5,a2,4
    c704:	018c8223          	sb	s8,4(s9)
    c708:	03f78563          	beq	a5,t6,c732 <_vsnprintf+0x3b72>
    c70c:	00560793          	addi	a5,a2,5
    c710:	018c82a3          	sb	s8,5(s9)
    c714:	01f78f63          	beq	a5,t6,c732 <_vsnprintf+0x3b72>
    c718:	00660793          	addi	a5,a2,6
    c71c:	018c8323          	sb	s8,6(s9)
    c720:	01f78963          	beq	a5,t6,c732 <_vsnprintf+0x3b72>
    c724:	018c83a3          	sb	s8,7(s9)
    c728:	00760793          	addi	a5,a2,7
    c72c:	0ca1                	addi	s9,s9,8
    c72e:	fbf790e3          	bne	a5,t6,c6ce <_vsnprintf+0x3b0e>
    c732:	02000713          	li	a4,32
    c736:	38e786e3          	beq	a5,a4,d2c2 <_vsnprintf+0x4702>
    c73a:	000e4463          	bltz	t3,c742 <_vsnprintf+0x3b82>
    c73e:	2530106f          	j	e190 <_vsnprintf+0x55d0>
    c742:	00278e33          	add	t3,a5,sp
    c746:	02d00513          	li	a0,45
    c74a:	02ae0823          	sb	a0,48(t3)
    c74e:	0035f613          	andi	a2,a1,3
    c752:	00178c13          	addi	s8,a5,1
    c756:	c219                	beqz	a2,c75c <_vsnprintf+0x3b9c>
    c758:	57e0206f          	j	ecd6 <_vsnprintf+0x6116>
    c75c:	7c08bd0b          	th.extu	s10,a7,31,0
    c760:	4b01                	li	s6,0
    c762:	1bac67e3          	bltu	s8,s10,d110 <_vsnprintf+0x4550>
    c766:	6302                	ld	t1,0(sp)
    c768:	02d00513          	li	a0,45
    c76c:	cdafe06f          	j	ac46 <_vsnprintf+0x2086>
    c770:	8f32                	mv	t5,a2
    c772:	fe367e13          	andi	t3,a2,-29
    c776:	5c0b98e3          	bnez	s7,d546 <_vsnprintf+0x4986>
    c77a:	4e81                	li	t4,0
    c77c:	ecefd06f          	j	9e4a <_vsnprintf+0x128a>
    c780:	8aee                	mv	s5,s11
    c782:	788acd0b          	th.ldia	s10,(s5),8,0
    c786:	010ffe93          	andi	t4,t6,16
    c78a:	000d1963          	bnez	s10,c79c <_vsnprintf+0x3bdc>
    c78e:	fefffd93          	andi	s11,t6,-17
    c792:	000d861b          	sext.w	a2,s11
    c796:	320b9063          	bnez	s7,cab6 <_vsnprintf+0x3ef6>
    c79a:	4e81                	li	t4,0
    c79c:	02fd5333          	divu	t1,s10,a5
    c7a0:	83ea                	mv	t2,s10
    c7a2:	14563f0b          	th.extu	t5,a2,5,5
    c7a6:	ffff0f93          	addi	t6,t5,-1
    c7aa:	020ff713          	andi	a4,t6,32
    c7ae:	0377051b          	addiw	a0,a4,55
    c7b2:	4e25                	li	t3,9
    c7b4:	03010b13          	addi	s6,sp,48
    c7b8:	85da                	mv	a1,s6
    c7ba:	22f3138b          	th.muls	t2,t1,a5
    c7be:	0ff3fc93          	zext.b	s9,t2
    c7c2:	030c829b          	addiw	t0,s9,48
    c7c6:	01950f3b          	addw	t5,a0,s9
    c7ca:	0ff2fd93          	zext.b	s11,t0
    c7ce:	0fff7713          	zext.b	a4,t5
    c7d2:	007e3fb3          	sltu	t6,t3,t2
    c7d6:	41fd970b          	th.mveqz	a4,s11,t6
    c7da:	02e10823          	sb	a4,48(sp)
    c7de:	14fd6763          	bltu	s10,a5,c92c <_vsnprintf+0x3d6c>
    c7e2:	03110593          	addi	a1,sp,49
    c7e6:	829a                	mv	t0,t1
    c7e8:	02f2dd33          	divu	s10,t0,a5
    c7ec:	8316                	mv	t1,t0
    c7ee:	22fd130b          	th.muls	t1,s10,a5
    c7f2:	0ff37393          	zext.b	t2,t1
    c7f6:	03038c9b          	addiw	s9,t2,48
    c7fa:	00750f3b          	addw	t5,a0,t2
    c7fe:	0ffcfd93          	zext.b	s11,s9
    c802:	0fff7713          	zext.b	a4,t5
    c806:	006e3fb3          	sltu	t6,t3,t1
    c80a:	41fd970b          	th.mveqz	a4,s11,t6
    c80e:	00e58023          	sb	a4,0(a1)
    c812:	10f2ed63          	bltu	t0,a5,c92c <_vsnprintf+0x3d6c>
    c816:	00158c93          	addi	s9,a1,1
    c81a:	05010293          	addi	t0,sp,80
    c81e:	11928763          	beq	t0,s9,c92c <_vsnprintf+0x3d6c>
    c822:	02fd5db3          	divu	s11,s10,a5
    c826:	836a                	mv	t1,s10
    c828:	85e6                	mv	a1,s9
    c82a:	22fd930b          	th.muls	t1,s11,a5
    c82e:	0ff37f13          	zext.b	t5,t1
    c832:	030f039b          	addiw	t2,t5,48
    c836:	01e5073b          	addw	a4,a0,t5
    c83a:	0ff3ff93          	zext.b	t6,t2
    c83e:	0ff77f13          	zext.b	t5,a4
    c842:	006e32b3          	sltu	t0,t3,t1
    c846:	405f9f0b          	th.mveqz	t5,t6,t0
    c84a:	01ec8023          	sb	t5,0(s9)
    c84e:	0cfd6f63          	bltu	s10,a5,c92c <_vsnprintf+0x3d6c>
    c852:	02fddd33          	divu	s10,s11,a5
    c856:	836e                	mv	t1,s11
    c858:	22fd130b          	th.muls	t1,s10,a5
    c85c:	0ff37f93          	zext.b	t6,t1
    c860:	030f839b          	addiw	t2,t6,48
    c864:	01f5073b          	addw	a4,a0,t6
    c868:	0ff3ff13          	zext.b	t5,t2
    c86c:	0ff77f93          	zext.b	t6,a4
    c870:	006e32b3          	sltu	t0,t3,t1
    c874:	405f1f8b          	th.mveqz	t6,t5,t0
    c878:	0815df8b          	th.sbib	t6,(a1),1,0
    c87c:	0afde863          	bltu	s11,a5,c92c <_vsnprintf+0x3d6c>
    c880:	02fd5db3          	divu	s11,s10,a5
    c884:	836a                	mv	t1,s10
    c886:	002c8593          	addi	a1,s9,2
    c88a:	22fd930b          	th.muls	t1,s11,a5
    c88e:	0ff37f13          	zext.b	t5,t1
    c892:	030f039b          	addiw	t2,t5,48
    c896:	01e5073b          	addw	a4,a0,t5
    c89a:	0ff3ff93          	zext.b	t6,t2
    c89e:	0ff77f13          	zext.b	t5,a4
    c8a2:	006e32b3          	sltu	t0,t3,t1
    c8a6:	405f9f0b          	th.mveqz	t5,t6,t0
    c8aa:	01ec8123          	sb	t5,2(s9)
    c8ae:	06fd6f63          	bltu	s10,a5,c92c <_vsnprintf+0x3d6c>
    c8b2:	02fdd2b3          	divu	t0,s11,a5
    c8b6:	8d6e                	mv	s10,s11
    c8b8:	003c8593          	addi	a1,s9,3
    c8bc:	22f29d0b          	th.muls	s10,t0,a5
    c8c0:	0ffd7313          	zext.b	t1,s10
    c8c4:	0303039b          	addiw	t2,t1,48
    c8c8:	0065073b          	addw	a4,a0,t1
    c8cc:	0ff3ff93          	zext.b	t6,t2
    c8d0:	0ff77f13          	zext.b	t5,a4
    c8d4:	01ae3d33          	sltu	s10,t3,s10
    c8d8:	41af9f0b          	th.mveqz	t5,t6,s10
    c8dc:	01ec81a3          	sb	t5,3(s9)
    c8e0:	04fde663          	bltu	s11,a5,c92c <_vsnprintf+0x3d6c>
    c8e4:	004c8593          	addi	a1,s9,4
    c8e8:	b701                	j	c7e8 <_vsnprintf+0x3c28>
    c8ea:	02000e13          	li	t3,32
    c8ee:	01cc0463          	beq	s8,t3,c8f6 <_vsnprintf+0x3d36>
    c8f2:	04c0206f          	j	e93e <_vsnprintf+0x5d7e>
    c8f6:	04f14503          	lbu	a0,79(sp)
    c8fa:	810fd06f          	j	990a <_vsnprintf+0xd4a>
    c8fe:	4b89                	li	s7,2
    c900:	4ac1                	li	s5,16
    c902:	02000c93          	li	s9,32
    c906:	019d1463          	bne	s10,s9,c90e <_vsnprintf+0x3d4e>
    c90a:	fabfd06f          	j	a8b4 <_vsnprintf+0x1cf4>
    c90e:	001d0793          	addi	a5,s10,1
    c912:	9d66                	add	s10,s10,s9
    c914:	002d0e33          	add	t3,s10,sp
    c918:	05800e93          	li	t4,88
    c91c:	01de0823          	sb	t4,16(t3)
    c920:	01979463          	bne	a5,s9,c928 <_vsnprintf+0x3d68>
    c924:	f91fd06f          	j	a8b4 <_vsnprintf+0x1cf4>
    c928:	b21fe06f          	j	b448 <_vsnprintf+0x2888>
    c92c:	416585b3          	sub	a1,a1,s6
    c930:	00267793          	andi	a5,a2,2
    c934:	00158d13          	addi	s10,a1,1
    c938:	8e32                	mv	t3,a2
    c93a:	60078be3          	beqz	a5,d750 <_vsnprintf+0x4b90>
    c93e:	000e8463          	beqz	t4,c946 <_vsnprintf+0x3d86>
    c942:	4b70106f          	j	e5f8 <_vsnprintf+0x5a38>
    c946:	02000693          	li	a3,32
    c94a:	4809                	li	a6,2
    c94c:	00dd0463          	beq	s10,a3,c954 <_vsnprintf+0x3d94>
    c950:	7550106f          	j	e8a4 <_vsnprintf+0x5ce4>
    c954:	6382                	ld	t2,0(sp)
    c956:	8bc2                	mv	s7,a6
    c958:	02000d13          	li	s10,32
    c95c:	007d0cb3          	add	s9,s10,t2
    c960:	01ab0c33          	add	s8,s6,s10
    c964:	007d7d13          	andi	s10,s10,7
    c968:	019b0db3          	add	s11,s6,s9
    c96c:	0a0d0763          	beqz	s10,ca1a <_vsnprintf+0x3e5a>
    c970:	4805                	li	a6,1
    c972:	090d0763          	beq	s10,a6,ca00 <_vsnprintf+0x3e40>
    c976:	4309                	li	t1,2
    c978:	066d0b63          	beq	s10,t1,c9ee <_vsnprintf+0x3e2e>
    c97c:	468d                	li	a3,3
    c97e:	04dd0f63          	beq	s10,a3,c9dc <_vsnprintf+0x3e1c>
    c982:	4e11                	li	t3,4
    c984:	05cd0363          	beq	s10,t3,c9ca <_vsnprintf+0x3e0a>
    c988:	4295                	li	t0,5
    c98a:	025d0763          	beq	s10,t0,c9b8 <_vsnprintf+0x3df8>
    c98e:	4f99                	li	t6,6
    c990:	01fd0b63          	beq	s10,t6,c9a6 <_vsnprintf+0x3de6>
    c994:	418d8633          	sub	a2,s11,s8
    c998:	89fc450b          	th.lbuib	a0,(s8),-1,0
    c99c:	ec46                	sd	a7,24(sp)
    c99e:	86a6                	mv	a3,s1
    c9a0:	85ca                	mv	a1,s2
    c9a2:	9402                	jalr	s0
    c9a4:	68e2                	ld	a7,24(sp)
    c9a6:	418d8633          	sub	a2,s11,s8
    c9aa:	89fc450b          	th.lbuib	a0,(s8),-1,0
    c9ae:	ec46                	sd	a7,24(sp)
    c9b0:	86a6                	mv	a3,s1
    c9b2:	85ca                	mv	a1,s2
    c9b4:	9402                	jalr	s0
    c9b6:	68e2                	ld	a7,24(sp)
    c9b8:	418d8633          	sub	a2,s11,s8
    c9bc:	89fc450b          	th.lbuib	a0,(s8),-1,0
    c9c0:	ec46                	sd	a7,24(sp)
    c9c2:	86a6                	mv	a3,s1
    c9c4:	85ca                	mv	a1,s2
    c9c6:	9402                	jalr	s0
    c9c8:	68e2                	ld	a7,24(sp)
    c9ca:	418d8633          	sub	a2,s11,s8
    c9ce:	89fc450b          	th.lbuib	a0,(s8),-1,0
    c9d2:	ec46                	sd	a7,24(sp)
    c9d4:	86a6                	mv	a3,s1
    c9d6:	85ca                	mv	a1,s2
    c9d8:	9402                	jalr	s0
    c9da:	68e2                	ld	a7,24(sp)
    c9dc:	418d8633          	sub	a2,s11,s8
    c9e0:	89fc450b          	th.lbuib	a0,(s8),-1,0
    c9e4:	ec46                	sd	a7,24(sp)
    c9e6:	86a6                	mv	a3,s1
    c9e8:	85ca                	mv	a1,s2
    c9ea:	9402                	jalr	s0
    c9ec:	68e2                	ld	a7,24(sp)
    c9ee:	418d8633          	sub	a2,s11,s8
    c9f2:	89fc450b          	th.lbuib	a0,(s8),-1,0
    c9f6:	ec46                	sd	a7,24(sp)
    c9f8:	86a6                	mv	a3,s1
    c9fa:	85ca                	mv	a1,s2
    c9fc:	9402                	jalr	s0
    c9fe:	68e2                	ld	a7,24(sp)
    ca00:	418d8633          	sub	a2,s11,s8
    ca04:	89fc450b          	th.lbuib	a0,(s8),-1,0
    ca08:	ec66                	sd	s9,24(sp)
    ca0a:	f046                	sd	a7,32(sp)
    ca0c:	86a6                	mv	a3,s1
    ca0e:	85ca                	mv	a1,s2
    ca10:	9402                	jalr	s0
    ca12:	63e2                	ld	t2,24(sp)
    ca14:	7882                	ld	a7,32(sp)
    ca16:	098b0a63          	beq	s6,s8,caaa <_vsnprintf+0x3eea>
    ca1a:	ec56                	sd	s5,24(sp)
    ca1c:	f05e                	sd	s7,32(sp)
    ca1e:	8bc6                	mv	s7,a7
    ca20:	8d62                	mv	s10,s8
    ca22:	89fd450b          	th.lbuib	a0,(s10),-1,0
    ca26:	418d8633          	sub	a2,s11,s8
    ca2a:	86a6                	mv	a3,s1
    ca2c:	85ca                	mv	a1,s2
    ca2e:	9402                	jalr	s0
    ca30:	8ae2                	mv	s5,s8
    ca32:	89eac50b          	th.lbuib	a0,(s5),-2,0
    ca36:	41ad8633          	sub	a2,s11,s10
    ca3a:	86a6                	mv	a3,s1
    ca3c:	85ca                	mv	a1,s2
    ca3e:	9402                	jalr	s0
    ca40:	8d62                	mv	s10,s8
    ca42:	89dd450b          	th.lbuib	a0,(s10),-3,0
    ca46:	415d8633          	sub	a2,s11,s5
    ca4a:	86a6                	mv	a3,s1
    ca4c:	85ca                	mv	a1,s2
    ca4e:	9402                	jalr	s0
    ca50:	8ae2                	mv	s5,s8
    ca52:	89cac50b          	th.lbuib	a0,(s5),-4,0
    ca56:	41ad8633          	sub	a2,s11,s10
    ca5a:	86a6                	mv	a3,s1
    ca5c:	85ca                	mv	a1,s2
    ca5e:	9402                	jalr	s0
    ca60:	8d62                	mv	s10,s8
    ca62:	89bd450b          	th.lbuib	a0,(s10),-5,0
    ca66:	415d8633          	sub	a2,s11,s5
    ca6a:	86a6                	mv	a3,s1
    ca6c:	85ca                	mv	a1,s2
    ca6e:	9402                	jalr	s0
    ca70:	8ae2                	mv	s5,s8
    ca72:	89aac50b          	th.lbuib	a0,(s5),-6,0
    ca76:	41ad8633          	sub	a2,s11,s10
    ca7a:	86a6                	mv	a3,s1
    ca7c:	85ca                	mv	a1,s2
    ca7e:	9402                	jalr	s0
    ca80:	8d62                	mv	s10,s8
    ca82:	899d450b          	th.lbuib	a0,(s10),-7,0
    ca86:	86a6                	mv	a3,s1
    ca88:	415d8633          	sub	a2,s11,s5
    ca8c:	85ca                	mv	a1,s2
    ca8e:	9402                	jalr	s0
    ca90:	898c450b          	th.lbuib	a0,(s8),-8,0
    ca94:	86a6                	mv	a3,s1
    ca96:	41ad8633          	sub	a2,s11,s10
    ca9a:	85ca                	mv	a1,s2
    ca9c:	9402                	jalr	s0
    ca9e:	f98b11e3          	bne	s6,s8,ca20 <_vsnprintf+0x3e60>
    caa2:	88de                	mv	a7,s7
    caa4:	6ae2                	ld	s5,24(sp)
    caa6:	7b82                	ld	s7,32(sp)
    caa8:	83e6                	mv	t2,s9
    caaa:	000b9d63          	bnez	s7,cac4 <_vsnprintf+0x3f04>
    caae:	e01e                	sd	t2,0(sp)
    cab0:	8dd6                	mv	s11,s5
    cab2:	9e7fd06f          	j	a498 <_vsnprintf+0x18d8>
    cab6:	002ffe93          	andi	t4,t6,2
    caba:	000e9463          	bnez	t4,cac2 <_vsnprintf+0x3f02>
    cabe:	37b0106f          	j	e638 <_vsnprintf+0x5a78>
    cac2:	6382                	ld	t2,0(sp)
    cac4:	6b02                	ld	s6,0(sp)
    cac6:	7c08bc0b          	th.extu	s8,a7,31,0
    caca:	41638db3          	sub	s11,t2,s6
    cace:	ff8df0e3          	bgeu	s11,s8,caae <_vsnprintf+0x3eee>
    cad2:	fffdc513          	not	a0,s11
    cad6:	018508b3          	add	a7,a0,s8
    cada:	85ca                	mv	a1,s2
    cadc:	86a6                	mv	a3,s1
    cade:	861e                	mv	a2,t2
    cae0:	02000513          	li	a0,32
    cae4:	e01e                	sd	t2,0(sp)
    cae6:	0078fb93          	andi	s7,a7,7
    caea:	00138b13          	addi	s6,t2,1
    caee:	001d8c93          	addi	s9,s11,1
    caf2:	9402                	jalr	s0
    caf4:	6582                	ld	a1,0(sp)
    caf6:	b98cfd63          	bgeu	s9,s8,be90 <_vsnprintf+0x32d0>
    cafa:	0a0b8063          	beqz	s7,cb9a <_vsnprintf+0x3fda>
    cafe:	4705                	li	a4,1
    cb00:	08eb8363          	beq	s7,a4,cb86 <_vsnprintf+0x3fc6>
    cb04:	4789                	li	a5,2
    cb06:	06fb8863          	beq	s7,a5,cb76 <_vsnprintf+0x3fb6>
    cb0a:	460d                	li	a2,3
    cb0c:	04cb8d63          	beq	s7,a2,cb66 <_vsnprintf+0x3fa6>
    cb10:	4e91                	li	t4,4
    cb12:	05db8263          	beq	s7,t4,cb56 <_vsnprintf+0x3f96>
    cb16:	4815                	li	a6,5
    cb18:	030b8763          	beq	s7,a6,cb46 <_vsnprintf+0x3f86>
    cb1c:	4319                	li	t1,6
    cb1e:	006b8c63          	beq	s7,t1,cb36 <_vsnprintf+0x3f76>
    cb22:	865a                	mv	a2,s6
    cb24:	86a6                	mv	a3,s1
    cb26:	00258b13          	addi	s6,a1,2
    cb2a:	02000513          	li	a0,32
    cb2e:	85ca                	mv	a1,s2
    cb30:	9402                	jalr	s0
    cb32:	002d8c93          	addi	s9,s11,2
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
    cb90:	0c85                	addi	s9,s9,1
    cb92:	0b05                	addi	s6,s6,1
    cb94:	9402                	jalr	s0
    cb96:	af8cfd63          	bgeu	s9,s8,be90 <_vsnprintf+0x32d0>
    cb9a:	865a                	mv	a2,s6
    cb9c:	86a6                	mv	a3,s1
    cb9e:	85ca                	mv	a1,s2
    cba0:	02000513          	li	a0,32
    cba4:	9402                	jalr	s0
    cba6:	001b0d93          	addi	s11,s6,1
    cbaa:	866e                	mv	a2,s11
    cbac:	86a6                	mv	a3,s1
    cbae:	85ca                	mv	a1,s2
    cbb0:	02000513          	li	a0,32
    cbb4:	9402                	jalr	s0
    cbb6:	002b0d13          	addi	s10,s6,2
    cbba:	866a                	mv	a2,s10
    cbbc:	86a6                	mv	a3,s1
    cbbe:	85ca                	mv	a1,s2
    cbc0:	02000513          	li	a0,32
    cbc4:	9402                	jalr	s0
    cbc6:	003b0b93          	addi	s7,s6,3
    cbca:	865e                	mv	a2,s7
    cbcc:	86a6                	mv	a3,s1
    cbce:	85ca                	mv	a1,s2
    cbd0:	02000513          	li	a0,32
    cbd4:	9402                	jalr	s0
    cbd6:	004b0d93          	addi	s11,s6,4
    cbda:	866e                	mv	a2,s11
    cbdc:	86a6                	mv	a3,s1
    cbde:	85ca                	mv	a1,s2
    cbe0:	02000513          	li	a0,32
    cbe4:	9402                	jalr	s0
    cbe6:	005b0b93          	addi	s7,s6,5
    cbea:	86a6                	mv	a3,s1
    cbec:	865e                	mv	a2,s7
    cbee:	85ca                	mv	a1,s2
    cbf0:	02000513          	li	a0,32
    cbf4:	9402                	jalr	s0
    cbf6:	006b0d13          	addi	s10,s6,6
    cbfa:	86a6                	mv	a3,s1
    cbfc:	866a                	mv	a2,s10
    cbfe:	85ca                	mv	a1,s2
    cc00:	02000513          	li	a0,32
    cc04:	9402                	jalr	s0
    cc06:	007b0d93          	addi	s11,s6,7
    cc0a:	86a6                	mv	a3,s1
    cc0c:	866e                	mv	a2,s11
    cc0e:	85ca                	mv	a1,s2
    cc10:	02000513          	li	a0,32
    cc14:	0ca1                	addi	s9,s9,8
    cc16:	0b21                	addi	s6,s6,8
    cc18:	9402                	jalr	s0
    cc1a:	f98ce0e3          	bltu	s9,s8,cb9a <_vsnprintf+0x3fda>
    cc1e:	e05a                	sd	s6,0(sp)
    cc20:	a72ff06f          	j	be92 <_vsnprintf+0x32d2>
    cc24:	30088be3          	beqz	a7,d73a <_vsnprintf+0x4b7a>
    cc28:	0016fd93          	andi	s11,a3,1
    cc2c:	000d8463          	beqz	s11,cc34 <_vsnprintf+0x4074>
    cc30:	4580106f          	j	e088 <_vsnprintf+0x54c8>
    cc34:	7c0c3c0b          	th.extu	s8,s8,31,0
    cc38:	a987e863          	bltu	a5,s8,bec8 <_vsnprintf+0x3308>
    cc3c:	02000e13          	li	t3,32
    cc40:	27c78ce3          	beq	a5,t3,d6b8 <_vsnprintf+0x4af8>
    cc44:	000ec463          	bltz	t4,cc4c <_vsnprintf+0x408c>
    cc48:	0410106f          	j	e488 <_vsnprintf+0x58c8>
    cc4c:	01c78633          	add	a2,a5,t3
    cc50:	03010f93          	addi	t6,sp,48
    cc54:	01f603b3          	add	t2,a2,t6
    cc58:	02d00713          	li	a4,45
    cc5c:	00178c13          	addi	s8,a5,1
    cc60:	fee38023          	sb	a4,-32(t2)
    cc64:	7c08bb8b          	th.extu	s7,a7,31,0
    cc68:	8dc2                	mv	s11,a6
    cc6a:	4b01                	li	s6,0
    cc6c:	017c6463          	bltu	s8,s7,cc74 <_vsnprintf+0x40b4>
    cc70:	6b30106f          	j	eb22 <_vsnprintf+0x5f62>
    cc74:	6602                	ld	a2,0(sp)
    cc76:	85ca                	mv	a1,s2
    cc78:	86a6                	mv	a3,s1
    cc7a:	40cc0cb3          	sub	s9,s8,a2
    cc7e:	fffcc393          	not	t2,s9
    cc82:	40c387b3          	sub	a5,t2,a2
    cc86:	01778eb3          	add	t4,a5,s7
    cc8a:	ec66                	sd	s9,24(sp)
    cc8c:	f046                	sd	a7,32(sp)
    cc8e:	02000513          	li	a0,32
    cc92:	00160d13          	addi	s10,a2,1
    cc96:	007efa93          	andi	s5,t4,7
    cc9a:	9402                	jalr	s0
    cc9c:	01ac85b3          	add	a1,s9,s10
    cca0:	7882                	ld	a7,32(sp)
    cca2:	1575f563          	bgeu	a1,s7,cdec <_vsnprintf+0x422c>
    cca6:	0a0a8963          	beqz	s5,cd58 <_vsnprintf+0x4198>
    ccaa:	4685                	li	a3,1
    ccac:	08da8863          	beq	s5,a3,cd3c <_vsnprintf+0x417c>
    ccb0:	4f89                	li	t6,2
    ccb2:	07fa8c63          	beq	s5,t6,cd2a <_vsnprintf+0x416a>
    ccb6:	480d                	li	a6,3
    ccb8:	070a8063          	beq	s5,a6,cd18 <_vsnprintf+0x4158>
    ccbc:	4711                	li	a4,4
    ccbe:	04ea8463          	beq	s5,a4,cd06 <_vsnprintf+0x4146>
    ccc2:	4f15                	li	t5,5
    ccc4:	03ea8863          	beq	s5,t5,ccf4 <_vsnprintf+0x4134>
    ccc8:	4299                	li	t0,6
    ccca:	005a8c63          	beq	s5,t0,cce2 <_vsnprintf+0x4122>
    ccce:	866a                	mv	a2,s10
    ccd0:	f046                	sd	a7,32(sp)
    ccd2:	86a6                	mv	a3,s1
    ccd4:	85ca                	mv	a1,s2
    ccd6:	02000513          	li	a0,32
    ccda:	6d02                	ld	s10,0(sp)
    ccdc:	9402                	jalr	s0
    ccde:	7882                	ld	a7,32(sp)
    cce0:	0d09                	addi	s10,s10,2
    cce2:	866a                	mv	a2,s10
    cce4:	f046                	sd	a7,32(sp)
    cce6:	86a6                	mv	a3,s1
    cce8:	85ca                	mv	a1,s2
    ccea:	02000513          	li	a0,32
    ccee:	9402                	jalr	s0
    ccf0:	7882                	ld	a7,32(sp)
    ccf2:	0d05                	addi	s10,s10,1
    ccf4:	866a                	mv	a2,s10
    ccf6:	f046                	sd	a7,32(sp)
    ccf8:	86a6                	mv	a3,s1
    ccfa:	85ca                	mv	a1,s2
    ccfc:	02000513          	li	a0,32
    cd00:	9402                	jalr	s0
    cd02:	7882                	ld	a7,32(sp)
    cd04:	0d05                	addi	s10,s10,1
    cd06:	866a                	mv	a2,s10
    cd08:	f046                	sd	a7,32(sp)
    cd0a:	86a6                	mv	a3,s1
    cd0c:	85ca                	mv	a1,s2
    cd0e:	02000513          	li	a0,32
    cd12:	9402                	jalr	s0
    cd14:	7882                	ld	a7,32(sp)
    cd16:	0d05                	addi	s10,s10,1
    cd18:	866a                	mv	a2,s10
    cd1a:	f046                	sd	a7,32(sp)
    cd1c:	86a6                	mv	a3,s1
    cd1e:	85ca                	mv	a1,s2
    cd20:	02000513          	li	a0,32
    cd24:	9402                	jalr	s0
    cd26:	7882                	ld	a7,32(sp)
    cd28:	0d05                	addi	s10,s10,1
    cd2a:	866a                	mv	a2,s10
    cd2c:	f046                	sd	a7,32(sp)
    cd2e:	86a6                	mv	a3,s1
    cd30:	85ca                	mv	a1,s2
    cd32:	02000513          	li	a0,32
    cd36:	9402                	jalr	s0
    cd38:	7882                	ld	a7,32(sp)
    cd3a:	0d05                	addi	s10,s10,1
    cd3c:	866a                	mv	a2,s10
    cd3e:	02000513          	li	a0,32
    cd42:	f046                	sd	a7,32(sp)
    cd44:	86a6                	mv	a3,s1
    cd46:	85ca                	mv	a1,s2
    cd48:	9402                	jalr	s0
    cd4a:	6362                	ld	t1,24(sp)
    cd4c:	7882                	ld	a7,32(sp)
    cd4e:	0d05                	addi	s10,s10,1
    cd50:	01a30533          	add	a0,t1,s10
    cd54:	09757c63          	bgeu	a0,s7,cdec <_vsnprintf+0x422c>
    cd58:	f06e                	sd	s11,32(sp)
    cd5a:	8dda                	mv	s11,s6
    cd5c:	8b46                	mv	s6,a7
    cd5e:	866a                	mv	a2,s10
    cd60:	86a6                	mv	a3,s1
    cd62:	85ca                	mv	a1,s2
    cd64:	02000513          	li	a0,32
    cd68:	9402                	jalr	s0
    cd6a:	001d0a93          	addi	s5,s10,1
    cd6e:	8656                	mv	a2,s5
    cd70:	86a6                	mv	a3,s1
    cd72:	85ca                	mv	a1,s2
    cd74:	02000513          	li	a0,32
    cd78:	9402                	jalr	s0
    cd7a:	002d0c93          	addi	s9,s10,2
    cd7e:	8666                	mv	a2,s9
    cd80:	86a6                	mv	a3,s1
    cd82:	85ca                	mv	a1,s2
    cd84:	02000513          	li	a0,32
    cd88:	9402                	jalr	s0
    cd8a:	003d0a93          	addi	s5,s10,3
    cd8e:	8656                	mv	a2,s5
    cd90:	86a6                	mv	a3,s1
    cd92:	85ca                	mv	a1,s2
    cd94:	02000513          	li	a0,32
    cd98:	9402                	jalr	s0
    cd9a:	004d0c93          	addi	s9,s10,4
    cd9e:	8666                	mv	a2,s9
    cda0:	86a6                	mv	a3,s1
    cda2:	85ca                	mv	a1,s2
    cda4:	02000513          	li	a0,32
    cda8:	9402                	jalr	s0
    cdaa:	005d0a93          	addi	s5,s10,5
    cdae:	8656                	mv	a2,s5
    cdb0:	86a6                	mv	a3,s1
    cdb2:	85ca                	mv	a1,s2
    cdb4:	02000513          	li	a0,32
    cdb8:	9402                	jalr	s0
    cdba:	006d0c93          	addi	s9,s10,6
    cdbe:	86a6                	mv	a3,s1
    cdc0:	8666                	mv	a2,s9
    cdc2:	85ca                	mv	a1,s2
    cdc4:	02000513          	li	a0,32
    cdc8:	9402                	jalr	s0
    cdca:	007d0a93          	addi	s5,s10,7
    cdce:	86a6                	mv	a3,s1
    cdd0:	8656                	mv	a2,s5
    cdd2:	85ca                	mv	a1,s2
    cdd4:	02000513          	li	a0,32
    cdd8:	9402                	jalr	s0
    cdda:	68e2                	ld	a7,24(sp)
    cddc:	0d21                	addi	s10,s10,8
    cdde:	01a88e33          	add	t3,a7,s10
    cde2:	f77e6ee3          	bltu	t3,s7,cd5e <_vsnprintf+0x419e>
    cde6:	88da                	mv	a7,s6
    cde8:	8b6e                	mv	s6,s11
    cdea:	7d82                	ld	s11,32(sp)
    cdec:	6682                	ld	a3,0(sp)
    cdee:	fffb8613          	addi	a2,s7,-1
    cdf2:	001c0793          	addi	a5,s8,1
    cdf6:	418603b3          	sub	t2,a2,s8
    cdfa:	00fbbeb3          	sltu	t4,s7,a5
    cdfe:	43d0138b          	th.mvnez	t2,zero,t4
    ce02:	00168f93          	addi	t6,a3,1
    ce06:	01f38833          	add	a6,t2,t6
    ce0a:	8e42                	mv	t3,a6
    ce0c:	da0c0863          	beqz	s8,c3bc <_vsnprintf+0x37fc>
    ce10:	03010c93          	addi	s9,sp,48
    ce14:	019c0733          	add	a4,s8,s9
    ce18:	fff74503          	lbu	a0,-1(a4)
    ce1c:	c3eff06f          	j	c25a <_vsnprintf+0x369a>
    ce20:	54088fe3          	beqz	a7,db7e <_vsnprintf+0x4fbe>
    ce24:	00167b13          	andi	s6,a2,1
    ce28:	7c0c350b          	th.extu	a0,s8,31,0
    ce2c:	000b1463          	bnez	s6,ce34 <_vsnprintf+0x4274>
    ce30:	0e80106f          	j	df18 <_vsnprintf+0x5358>
    ce34:	0ea77763          	bgeu	a4,a0,cf22 <_vsnprintf+0x4362>
    ce38:	02000593          	li	a1,32
    ce3c:	40e582b3          	sub	t0,a1,a4
    ce40:	0072f393          	andi	t2,t0,7
    ce44:	00e80f33          	add	t5,a6,a4
    ce48:	03000f93          	li	t6,48
    ce4c:	06038763          	beqz	t2,ceba <_vsnprintf+0x42fa>
    ce50:	0705                	addi	a4,a4,1
    ce52:	181f5f8b          	th.sbia	t6,(t5),1,0
    ce56:	0ca77463          	bgeu	a4,a0,cf1e <_vsnprintf+0x435e>
    ce5a:	4a85                	li	s5,1
    ce5c:	05538f63          	beq	t2,s5,ceba <_vsnprintf+0x42fa>
    ce60:	4309                	li	t1,2
    ce62:	04638763          	beq	t2,t1,ceb0 <_vsnprintf+0x42f0>
    ce66:	478d                	li	a5,3
    ce68:	02f38f63          	beq	t2,a5,cea6 <_vsnprintf+0x42e6>
    ce6c:	4611                	li	a2,4
    ce6e:	02c38763          	beq	t2,a2,ce9c <_vsnprintf+0x42dc>
    ce72:	4c95                	li	s9,5
    ce74:	01938f63          	beq	t2,s9,ce92 <_vsnprintf+0x42d2>
    ce78:	4299                	li	t0,6
    ce7a:	00538763          	beq	t2,t0,ce88 <_vsnprintf+0x42c8>
    ce7e:	0705                	addi	a4,a4,1
    ce80:	181f5f8b          	th.sbia	t6,(t5),1,0
    ce84:	08a77d63          	bgeu	a4,a0,cf1e <_vsnprintf+0x435e>
    ce88:	0705                	addi	a4,a4,1
    ce8a:	181f5f8b          	th.sbia	t6,(t5),1,0
    ce8e:	08a77863          	bgeu	a4,a0,cf1e <_vsnprintf+0x435e>
    ce92:	0705                	addi	a4,a4,1
    ce94:	181f5f8b          	th.sbia	t6,(t5),1,0
    ce98:	08a77363          	bgeu	a4,a0,cf1e <_vsnprintf+0x435e>
    ce9c:	0705                	addi	a4,a4,1
    ce9e:	181f5f8b          	th.sbia	t6,(t5),1,0
    cea2:	06a77e63          	bgeu	a4,a0,cf1e <_vsnprintf+0x435e>
    cea6:	0705                	addi	a4,a4,1
    cea8:	181f5f8b          	th.sbia	t6,(t5),1,0
    ceac:	06a77963          	bgeu	a4,a0,cf1e <_vsnprintf+0x435e>
    ceb0:	0705                	addi	a4,a4,1
    ceb2:	181f5f8b          	th.sbia	t6,(t5),1,0
    ceb6:	06a77463          	bgeu	a4,a0,cf1e <_vsnprintf+0x435e>
    ceba:	06b70263          	beq	a4,a1,cf1e <_vsnprintf+0x435e>
    cebe:	0705                	addi	a4,a4,1
    cec0:	01ff0023          	sb	t6,0(t5)
    cec4:	83ba                	mv	t2,a4
    cec6:	04a77c63          	bgeu	a4,a0,cf1e <_vsnprintf+0x435e>
    ceca:	0705                	addi	a4,a4,1
    cecc:	01ff00a3          	sb	t6,1(t5)
    ced0:	04a77763          	bgeu	a4,a0,cf1e <_vsnprintf+0x435e>
    ced4:	00238713          	addi	a4,t2,2
    ced8:	01ff0123          	sb	t6,2(t5)
    cedc:	04a77163          	bgeu	a4,a0,cf1e <_vsnprintf+0x435e>
    cee0:	00338713          	addi	a4,t2,3
    cee4:	01ff01a3          	sb	t6,3(t5)
    cee8:	02a77b63          	bgeu	a4,a0,cf1e <_vsnprintf+0x435e>
    ceec:	00438713          	addi	a4,t2,4
    cef0:	01ff0223          	sb	t6,4(t5)
    cef4:	02a77563          	bgeu	a4,a0,cf1e <_vsnprintf+0x435e>
    cef8:	00538713          	addi	a4,t2,5
    cefc:	01ff02a3          	sb	t6,5(t5)
    cf00:	00a77f63          	bgeu	a4,a0,cf1e <_vsnprintf+0x435e>
    cf04:	00638713          	addi	a4,t2,6
    cf08:	01ff0323          	sb	t6,6(t5)
    cf0c:	00a77963          	bgeu	a4,a0,cf1e <_vsnprintf+0x435e>
    cf10:	01ff03a3          	sb	t6,7(t5)
    cf14:	00738713          	addi	a4,t2,7
    cf18:	0f21                	addi	t5,t5,8
    cf1a:	faa760e3          	bltu	a4,a0,ceba <_vsnprintf+0x42fa>
    cf1e:	5a0b07e3          	beqz	s6,dccc <_vsnprintf+0x510c>
    cf22:	7c08b78b          	th.extu	a5,a7,31,0
    cf26:	00f76463          	bltu	a4,a5,cf2e <_vsnprintf+0x436e>
    cf2a:	6e70106f          	j	ee10 <_vsnprintf+0x6250>
    cf2e:	02000b13          	li	s6,32
    cf32:	40eb0fb3          	sub	t6,s6,a4
    cf36:	007ffa93          	andi	s5,t6,7
    cf3a:	00e805b3          	add	a1,a6,a4
    cf3e:	03000513          	li	a0,48
    cf42:	060a8763          	beqz	s5,cfb0 <_vsnprintf+0x43f0>
    cf46:	0705                	addi	a4,a4,1
    cf48:	1815d50b          	th.sbia	a0,(a1),1,0
    cf4c:	0ce78463          	beq	a5,a4,d014 <_vsnprintf+0x4454>
    cf50:	4305                	li	t1,1
    cf52:	046a8f63          	beq	s5,t1,cfb0 <_vsnprintf+0x43f0>
    cf56:	4609                	li	a2,2
    cf58:	04ca8763          	beq	s5,a2,cfa6 <_vsnprintf+0x43e6>
    cf5c:	4c8d                	li	s9,3
    cf5e:	039a8f63          	beq	s5,s9,cf9c <_vsnprintf+0x43dc>
    cf62:	4291                	li	t0,4
    cf64:	025a8763          	beq	s5,t0,cf92 <_vsnprintf+0x43d2>
    cf68:	4395                	li	t2,5
    cf6a:	007a8f63          	beq	s5,t2,cf88 <_vsnprintf+0x43c8>
    cf6e:	4f19                	li	t5,6
    cf70:	01ea8763          	beq	s5,t5,cf7e <_vsnprintf+0x43be>
    cf74:	0705                	addi	a4,a4,1
    cf76:	1815d50b          	th.sbia	a0,(a1),1,0
    cf7a:	08e78d63          	beq	a5,a4,d014 <_vsnprintf+0x4454>
    cf7e:	0705                	addi	a4,a4,1
    cf80:	1815d50b          	th.sbia	a0,(a1),1,0
    cf84:	08e78863          	beq	a5,a4,d014 <_vsnprintf+0x4454>
    cf88:	0705                	addi	a4,a4,1
    cf8a:	1815d50b          	th.sbia	a0,(a1),1,0
    cf8e:	08e78363          	beq	a5,a4,d014 <_vsnprintf+0x4454>
    cf92:	0705                	addi	a4,a4,1
    cf94:	1815d50b          	th.sbia	a0,(a1),1,0
    cf98:	06e78e63          	beq	a5,a4,d014 <_vsnprintf+0x4454>
    cf9c:	0705                	addi	a4,a4,1
    cf9e:	1815d50b          	th.sbia	a0,(a1),1,0
    cfa2:	06e78963          	beq	a5,a4,d014 <_vsnprintf+0x4454>
    cfa6:	0705                	addi	a4,a4,1
    cfa8:	1815d50b          	th.sbia	a0,(a1),1,0
    cfac:	06e78463          	beq	a5,a4,d014 <_vsnprintf+0x4454>
    cfb0:	47670ae3          	beq	a4,s6,dc24 <_vsnprintf+0x5064>
    cfb4:	0705                	addi	a4,a4,1
    cfb6:	00a58023          	sb	a0,0(a1)
    cfba:	8fba                	mv	t6,a4
    cfbc:	04e78c63          	beq	a5,a4,d014 <_vsnprintf+0x4454>
    cfc0:	0705                	addi	a4,a4,1
    cfc2:	00a580a3          	sb	a0,1(a1)
    cfc6:	04e78763          	beq	a5,a4,d014 <_vsnprintf+0x4454>
    cfca:	002f8713          	addi	a4,t6,2
    cfce:	00a58123          	sb	a0,2(a1)
    cfd2:	04e78163          	beq	a5,a4,d014 <_vsnprintf+0x4454>
    cfd6:	003f8713          	addi	a4,t6,3
    cfda:	00a581a3          	sb	a0,3(a1)
    cfde:	02e78b63          	beq	a5,a4,d014 <_vsnprintf+0x4454>
    cfe2:	004f8713          	addi	a4,t6,4
    cfe6:	00a58223          	sb	a0,4(a1)
    cfea:	02e78563          	beq	a5,a4,d014 <_vsnprintf+0x4454>
    cfee:	005f8713          	addi	a4,t6,5
    cff2:	00a582a3          	sb	a0,5(a1)
    cff6:	00e78f63          	beq	a5,a4,d014 <_vsnprintf+0x4454>
    cffa:	006f8713          	addi	a4,t6,6
    cffe:	00a58323          	sb	a0,6(a1)
    d002:	00e78963          	beq	a5,a4,d014 <_vsnprintf+0x4454>
    d006:	00a583a3          	sb	a0,7(a1)
    d00a:	007f8713          	addi	a4,t6,7
    d00e:	05a1                	addi	a1,a1,8
    d010:	fae790e3          	bne	a5,a4,cfb0 <_vsnprintf+0x43f0>
    d014:	140e99e3          	bnez	t4,d966 <_vsnprintf+0x4da6>
    d018:	01671463          	bne	a4,s6,d020 <_vsnprintf+0x4460>
    d01c:	e4cfe06f          	j	b668 <_vsnprintf+0x2aa8>
    d020:	003e7d13          	andi	s10,t3,3
    d024:	000d0463          	beqz	s10,d02c <_vsnprintf+0x446c>
    d028:	7a10106f          	j	efc8 <_vsnprintf+0x6408>
    d02c:	8c3e                	mv	s8,a5
    d02e:	16f765e3          	bltu	a4,a5,d998 <_vsnprintf+0x4dd8>
    d032:	6e02                	ld	t3,0(sp)
    d034:	e3afe06f          	j	b66e <_vsnprintf+0x2aae>
    d038:	47c1                	li	a5,16
    d03a:	8abe                	mv	s5,a5
    d03c:	01f8f463          	bgeu	a7,t6,d044 <_vsnprintf+0x4484>
    d040:	f0ffd06f          	j	af4e <_vsnprintf+0x238e>
    d044:	000b9463          	bnez	s7,d04c <_vsnprintf+0x448c>
    d048:	c10fe06f          	j	b458 <_vsnprintf+0x2898>
    d04c:	4b81                	li	s7,0
    d04e:	8a0c9ae3          	bnez	s9,c902 <_vsnprintf+0x3d42>
    d052:	01fd1463          	bne	s10,t6,d05a <_vsnprintf+0x449a>
    d056:	3ec0106f          	j	e442 <_vsnprintf+0x5882>
    d05a:	8ba794e3          	bne	a5,s10,c902 <_vsnprintf+0x3d42>
    d05e:	3ed0006f          	j	dc4a <_vsnprintf+0x508a>
    d062:	0001                	nop
    d064:	ec46                	sd	a7,24(sp)
    d066:	f056                	sd	s5,32(sp)
    d068:	6b82                	ld	s7,0(sp)
    d06a:	8cbe                	mv	s9,a5
    d06c:	a5dfe06f          	j	bac8 <_vsnprintf+0x2f08>
    d070:	000f9463          	bnez	t6,d078 <_vsnprintf+0x44b8>
    d074:	77d0106f          	j	eff0 <_vsnprintf+0x6430>
    d078:	47c1                	li	a5,16
    d07a:	4d01                	li	s10,0
    d07c:	40000c93          	li	s9,1024
    d080:	8abe                	mv	s5,a5
    d082:	03010b13          	addi	s6,sp,48
    d086:	ec9fd06f          	j	af4e <_vsnprintf+0x238e>
    d08a:	588dce0b          	th.lwia	t3,(s11),8,0
    d08e:	41fe551b          	sraiw	a0,t3,0x1f
    d092:	00ae4633          	xor	a2,t3,a0
    d096:	40a603bb          	subw	t2,a2,a0
    d09a:	a3ffd06f          	j	aad8 <_vsnprintf+0x1f18>
    d09e:	00857713          	andi	a4,a0,8
    d0a2:	40071fe3          	bnez	a4,dcc0 <_vsnprintf+0x5100>
    d0a6:	6a82                	ld	s5,0(sp)
    d0a8:	4d01                	li	s10,0
    d0aa:	4bc1                	li	s7,16
    d0ac:	96dfd06f          	j	aa18 <_vsnprintf+0x1e58>
    d0b0:	05800f13          	li	t5,88
    d0b4:	05e10023          	sb	t5,64(sp)
    d0b8:	4b81                	li	s7,0
    d0ba:	47c5                	li	a5,17
    d0bc:	b8cfe06f          	j	b448 <_vsnprintf+0x2888>
    d0c0:	0025fb93          	andi	s7,a1,2
    d0c4:	8d2e                	mv	s10,a1
    d0c6:	300b97e3          	bnez	s7,dbd4 <_vsnprintf+0x5014>
    d0ca:	00089463          	bnez	a7,d0d2 <_vsnprintf+0x4512>
    d0ce:	0b40106f          	j	e182 <_vsnprintf+0x55c2>
    d0d2:	001d7f93          	andi	t6,s10,1
    d0d6:	000f8463          	beqz	t6,d0de <_vsnprintf+0x451e>
    d0da:	4e20106f          	j	e5bc <_vsnprintf+0x59fc>
    d0de:	7c0c3c0b          	th.extu	s8,s8,31,0
    d0e2:	4781                	li	a5,0
    d0e4:	03010b93          	addi	s7,sp,48
    d0e8:	c60c1763          	bnez	s8,c556 <_vsnprintf+0x3996>
    d0ec:	004d7b13          	andi	s6,s10,4
    d0f0:	000b1463          	bnez	s6,d0f8 <_vsnprintf+0x4538>
    d0f4:	6cb0106f          	j	efbe <_vsnprintf+0x63fe>
    d0f8:	02b00693          	li	a3,43
    d0fc:	02d10823          	sb	a3,48(sp)
    d100:	4c05                	li	s8,1
    d102:	7c08bd0b          	th.extu	s10,a7,31,0
    d106:	4b01                	li	s6,0
    d108:	01ac6463          	bltu	s8,s10,d110 <_vsnprintf+0x4550>
    d10c:	6a50106f          	j	efb0 <_vsnprintf+0x63f0>
    d110:	6602                	ld	a2,0(sp)
    d112:	02000513          	li	a0,32
    d116:	86a6                	mv	a3,s1
    d118:	40cc0cb3          	sub	s9,s8,a2
    d11c:	fffcc713          	not	a4,s9
    d120:	40c70fb3          	sub	t6,a4,a2
    d124:	01af8bb3          	add	s7,t6,s10
    d128:	ec66                	sd	s9,24(sp)
    d12a:	f046                	sd	a7,32(sp)
    d12c:	85ca                	mv	a1,s2
    d12e:	007bfa93          	andi	s5,s7,7
    d132:	00160b93          	addi	s7,a2,1
    d136:	9402                	jalr	s0
    d138:	017c8533          	add	a0,s9,s7
    d13c:	7882                	ld	a7,32(sp)
    d13e:	15a57663          	bgeu	a0,s10,d28a <_vsnprintf+0x46ca>
    d142:	0a0a8a63          	beqz	s5,d1f6 <_vsnprintf+0x4636>
    d146:	4685                	li	a3,1
    d148:	08da8963          	beq	s5,a3,d1da <_vsnprintf+0x461a>
    d14c:	4789                	li	a5,2
    d14e:	06fa8d63          	beq	s5,a5,d1c8 <_vsnprintf+0x4608>
    d152:	428d                	li	t0,3
    d154:	065a8163          	beq	s5,t0,d1b6 <_vsnprintf+0x45f6>
    d158:	4591                	li	a1,4
    d15a:	04ba8563          	beq	s5,a1,d1a4 <_vsnprintf+0x45e4>
    d15e:	4395                	li	t2,5
    d160:	027a8963          	beq	s5,t2,d192 <_vsnprintf+0x45d2>
    d164:	4f19                	li	t5,6
    d166:	01ea8d63          	beq	s5,t5,d180 <_vsnprintf+0x45c0>
    d16a:	6302                	ld	t1,0(sp)
    d16c:	865e                	mv	a2,s7
    d16e:	f046                	sd	a7,32(sp)
    d170:	86a6                	mv	a3,s1
    d172:	85ca                	mv	a1,s2
    d174:	02000513          	li	a0,32
    d178:	00230b93          	addi	s7,t1,2
    d17c:	9402                	jalr	s0
    d17e:	7882                	ld	a7,32(sp)
    d180:	865e                	mv	a2,s7
    d182:	f046                	sd	a7,32(sp)
    d184:	86a6                	mv	a3,s1
    d186:	85ca                	mv	a1,s2
    d188:	02000513          	li	a0,32
    d18c:	9402                	jalr	s0
    d18e:	7882                	ld	a7,32(sp)
    d190:	0b85                	addi	s7,s7,1
    d192:	865e                	mv	a2,s7
    d194:	f046                	sd	a7,32(sp)
    d196:	86a6                	mv	a3,s1
    d198:	85ca                	mv	a1,s2
    d19a:	02000513          	li	a0,32
    d19e:	9402                	jalr	s0
    d1a0:	7882                	ld	a7,32(sp)
    d1a2:	0b85                	addi	s7,s7,1
    d1a4:	865e                	mv	a2,s7
    d1a6:	f046                	sd	a7,32(sp)
    d1a8:	86a6                	mv	a3,s1
    d1aa:	85ca                	mv	a1,s2
    d1ac:	02000513          	li	a0,32
    d1b0:	9402                	jalr	s0
    d1b2:	7882                	ld	a7,32(sp)
    d1b4:	0b85                	addi	s7,s7,1
    d1b6:	865e                	mv	a2,s7
    d1b8:	f046                	sd	a7,32(sp)
    d1ba:	86a6                	mv	a3,s1
    d1bc:	85ca                	mv	a1,s2
    d1be:	02000513          	li	a0,32
    d1c2:	9402                	jalr	s0
    d1c4:	7882                	ld	a7,32(sp)
    d1c6:	0b85                	addi	s7,s7,1
    d1c8:	865e                	mv	a2,s7
    d1ca:	f046                	sd	a7,32(sp)
    d1cc:	86a6                	mv	a3,s1
    d1ce:	85ca                	mv	a1,s2
    d1d0:	02000513          	li	a0,32
    d1d4:	9402                	jalr	s0
    d1d6:	7882                	ld	a7,32(sp)
    d1d8:	0b85                	addi	s7,s7,1
    d1da:	865e                	mv	a2,s7
    d1dc:	f046                	sd	a7,32(sp)
    d1de:	86a6                	mv	a3,s1
    d1e0:	85ca                	mv	a1,s2
    d1e2:	02000513          	li	a0,32
    d1e6:	9402                	jalr	s0
    d1e8:	6862                	ld	a6,24(sp)
    d1ea:	7882                	ld	a7,32(sp)
    d1ec:	0b85                	addi	s7,s7,1
    d1ee:	01780eb3          	add	t4,a6,s7
    d1f2:	09aefc63          	bgeu	t4,s10,d28a <_vsnprintf+0x46ca>
    d1f6:	f06e                	sd	s11,32(sp)
    d1f8:	8dda                	mv	s11,s6
    d1fa:	8b46                	mv	s6,a7
    d1fc:	865e                	mv	a2,s7
    d1fe:	86a6                	mv	a3,s1
    d200:	85ca                	mv	a1,s2
    d202:	02000513          	li	a0,32
    d206:	9402                	jalr	s0
    d208:	001b8a93          	addi	s5,s7,1
    d20c:	8656                	mv	a2,s5
    d20e:	86a6                	mv	a3,s1
    d210:	85ca                	mv	a1,s2
    d212:	02000513          	li	a0,32
    d216:	9402                	jalr	s0
    d218:	002b8c93          	addi	s9,s7,2
    d21c:	8666                	mv	a2,s9
    d21e:	86a6                	mv	a3,s1
    d220:	85ca                	mv	a1,s2
    d222:	02000513          	li	a0,32
    d226:	9402                	jalr	s0
    d228:	003b8a93          	addi	s5,s7,3
    d22c:	8656                	mv	a2,s5
    d22e:	86a6                	mv	a3,s1
    d230:	85ca                	mv	a1,s2
    d232:	02000513          	li	a0,32
    d236:	9402                	jalr	s0
    d238:	004b8c93          	addi	s9,s7,4
    d23c:	8666                	mv	a2,s9
    d23e:	86a6                	mv	a3,s1
    d240:	85ca                	mv	a1,s2
    d242:	02000513          	li	a0,32
    d246:	9402                	jalr	s0
    d248:	005b8a93          	addi	s5,s7,5
    d24c:	8656                	mv	a2,s5
    d24e:	86a6                	mv	a3,s1
    d250:	85ca                	mv	a1,s2
    d252:	02000513          	li	a0,32
    d256:	9402                	jalr	s0
    d258:	006b8c93          	addi	s9,s7,6
    d25c:	86a6                	mv	a3,s1
    d25e:	8666                	mv	a2,s9
    d260:	85ca                	mv	a1,s2
    d262:	02000513          	li	a0,32
    d266:	9402                	jalr	s0
    d268:	007b8a93          	addi	s5,s7,7
    d26c:	86a6                	mv	a3,s1
    d26e:	8656                	mv	a2,s5
    d270:	85ca                	mv	a1,s2
    d272:	02000513          	li	a0,32
    d276:	9402                	jalr	s0
    d278:	68e2                	ld	a7,24(sp)
    d27a:	0ba1                	addi	s7,s7,8
    d27c:	01788e33          	add	t3,a7,s7
    d280:	f7ae6ee3          	bltu	t3,s10,d1fc <_vsnprintf+0x463c>
    d284:	88da                	mv	a7,s6
    d286:	8b6e                	mv	s6,s11
    d288:	7d82                	ld	s11,32(sp)
    d28a:	6682                	ld	a3,0(sp)
    d28c:	fffd0613          	addi	a2,s10,-1
    d290:	001c0713          	addi	a4,s8,1
    d294:	41860fb3          	sub	t6,a2,s8
    d298:	00ed3533          	sltu	a0,s10,a4
    d29c:	42a01f8b          	th.mvnez	t6,zero,a0
    d2a0:	00168793          	addi	a5,a3,1
    d2a4:	00ff8333          	add	t1,t6,a5
    d2a8:	8a9a                	mv	s5,t1
    d2aa:	000c1463          	bnez	s8,d2b2 <_vsnprintf+0x46f2>
    d2ae:	afbfd06f          	j	ada8 <_vsnprintf+0x21e8>
    d2b2:	002c03b3          	add	t2,s8,sp
    d2b6:	02f3c503          	lbu	a0,47(t2)
    d2ba:	03010b93          	addi	s7,sp,48
    d2be:	989fd06f          	j	ac46 <_vsnprintf+0x2086>
    d2c2:	0035ff93          	andi	t6,a1,3
    d2c6:	020f9d63          	bnez	t6,d300 <_vsnprintf+0x4740>
    d2ca:	02000c13          	li	s8,32
    d2ce:	7c08bd0b          	th.extu	s10,a7,31,0
    d2d2:	4b01                	li	s6,0
    d2d4:	e31c6ee3          	bltu	s8,a7,d110 <_vsnprintf+0x4550>
    d2d8:	04f14503          	lbu	a0,79(sp)
    d2dc:	6302                	ld	t1,0(sp)
    d2de:	02000c13          	li	s8,32
    d2e2:	4b01                	li	s6,0
    d2e4:	963fd06f          	j	ac46 <_vsnprintf+0x2086>
    d2e8:	ec46                	sd	a7,24(sp)
    d2ea:	f05a                	sd	s6,32(sp)
    d2ec:	aa5fd06f          	j	ad90 <_vsnprintf+0x21d0>
    d2f0:	fc0f89e3          	beqz	t6,d2c2 <_vsnprintf+0x4702>
    d2f4:	7c08bf8b          	th.extu	t6,a7,31,0
    d2f8:	b5f7ea63          	bltu	a5,t6,c64c <_vsnprintf+0x3a8c>
    d2fc:	898d                	andi	a1,a1,3
    d2fe:	dde9                	beqz	a1,d2d8 <_vsnprintf+0x4718>
    d300:	4b01                	li	s6,0
    d302:	93bfd06f          	j	ac3c <_vsnprintf+0x207c>
    d306:	7c0c3c0b          	th.extu	s8,s8,31,0
    d30a:	0187e463          	bltu	a5,s8,d312 <_vsnprintf+0x4752>
    d30e:	4170106f          	j	ef24 <_vsnprintf+0x6364>
    d312:	0015ff93          	andi	t6,a1,1
    d316:	4881                	li	a7,0
    d318:	a3eff06f          	j	c556 <_vsnprintf+0x3996>
    d31c:	0a0882e3          	beqz	a7,dbc0 <_vsnprintf+0x5000>
    d320:	0015fb13          	andi	s6,a1,1
    d324:	7c0c350b          	th.extu	a0,s8,31,0
    d328:	000b1463          	bnez	s6,d330 <_vsnprintf+0x4770>
    d32c:	32c0106f          	j	e658 <_vsnprintf+0x5a98>
    d330:	0eadf763          	bgeu	s11,a0,d41e <_vsnprintf+0x485e>
    d334:	02000713          	li	a4,32
    d338:	41b70cb3          	sub	s9,a4,s11
    d33c:	007cff13          	andi	t5,s9,7
    d340:	01b80e33          	add	t3,a6,s11
    d344:	03000293          	li	t0,48
    d348:	060f0763          	beqz	t5,d3b6 <_vsnprintf+0x47f6>
    d34c:	0d85                	addi	s11,s11,1
    d34e:	181e528b          	th.sbia	t0,(t3),1,0
    d352:	0cadf463          	bgeu	s11,a0,d41a <_vsnprintf+0x485a>
    d356:	4f85                	li	t6,1
    d358:	05ff0f63          	beq	t5,t6,d3b6 <_vsnprintf+0x47f6>
    d35c:	4789                	li	a5,2
    d35e:	04ff0763          	beq	t5,a5,d3ac <_vsnprintf+0x47ec>
    d362:	458d                	li	a1,3
    d364:	02bf0f63          	beq	t5,a1,d3a2 <_vsnprintf+0x47e2>
    d368:	4391                	li	t2,4
    d36a:	027f0763          	beq	t5,t2,d398 <_vsnprintf+0x47d8>
    d36e:	4315                	li	t1,5
    d370:	006f0f63          	beq	t5,t1,d38e <_vsnprintf+0x47ce>
    d374:	4e99                	li	t4,6
    d376:	01df0763          	beq	t5,t4,d384 <_vsnprintf+0x47c4>
    d37a:	0d85                	addi	s11,s11,1
    d37c:	181e528b          	th.sbia	t0,(t3),1,0
    d380:	08adfd63          	bgeu	s11,a0,d41a <_vsnprintf+0x485a>
    d384:	0d85                	addi	s11,s11,1
    d386:	181e528b          	th.sbia	t0,(t3),1,0
    d38a:	08adf863          	bgeu	s11,a0,d41a <_vsnprintf+0x485a>
    d38e:	0d85                	addi	s11,s11,1
    d390:	181e528b          	th.sbia	t0,(t3),1,0
    d394:	08adf363          	bgeu	s11,a0,d41a <_vsnprintf+0x485a>
    d398:	0d85                	addi	s11,s11,1
    d39a:	181e528b          	th.sbia	t0,(t3),1,0
    d39e:	06adfe63          	bgeu	s11,a0,d41a <_vsnprintf+0x485a>
    d3a2:	0d85                	addi	s11,s11,1
    d3a4:	181e528b          	th.sbia	t0,(t3),1,0
    d3a8:	06adf963          	bgeu	s11,a0,d41a <_vsnprintf+0x485a>
    d3ac:	0d85                	addi	s11,s11,1
    d3ae:	181e528b          	th.sbia	t0,(t3),1,0
    d3b2:	06adf463          	bgeu	s11,a0,d41a <_vsnprintf+0x485a>
    d3b6:	06ed8263          	beq	s11,a4,d41a <_vsnprintf+0x485a>
    d3ba:	0d85                	addi	s11,s11,1
    d3bc:	005e0023          	sb	t0,0(t3)
    d3c0:	8cee                	mv	s9,s11
    d3c2:	04adfc63          	bgeu	s11,a0,d41a <_vsnprintf+0x485a>
    d3c6:	0d85                	addi	s11,s11,1
    d3c8:	005e00a3          	sb	t0,1(t3)
    d3cc:	04adf763          	bgeu	s11,a0,d41a <_vsnprintf+0x485a>
    d3d0:	002c8d93          	addi	s11,s9,2
    d3d4:	005e0123          	sb	t0,2(t3)
    d3d8:	04adf163          	bgeu	s11,a0,d41a <_vsnprintf+0x485a>
    d3dc:	003c8d93          	addi	s11,s9,3
    d3e0:	005e01a3          	sb	t0,3(t3)
    d3e4:	02adfb63          	bgeu	s11,a0,d41a <_vsnprintf+0x485a>
    d3e8:	004c8d93          	addi	s11,s9,4
    d3ec:	005e0223          	sb	t0,4(t3)
    d3f0:	02adf563          	bgeu	s11,a0,d41a <_vsnprintf+0x485a>
    d3f4:	005c8d93          	addi	s11,s9,5
    d3f8:	005e02a3          	sb	t0,5(t3)
    d3fc:	00adff63          	bgeu	s11,a0,d41a <_vsnprintf+0x485a>
    d400:	006c8d93          	addi	s11,s9,6
    d404:	005e0323          	sb	t0,6(t3)
    d408:	00adf963          	bgeu	s11,a0,d41a <_vsnprintf+0x485a>
    d40c:	005e03a3          	sb	t0,7(t3)
    d410:	007c8d93          	addi	s11,s9,7
    d414:	0e21                	addi	t3,t3,8
    d416:	faade0e3          	bltu	s11,a0,d3b6 <_vsnprintf+0x47f6>
    d41a:	3e0b09e3          	beqz	s6,e00c <_vsnprintf+0x544c>
    d41e:	7c08b50b          	th.extu	a0,a7,31,0
    d422:	4aadf4e3          	bgeu	s11,a0,e0ca <_vsnprintf+0x550a>
    d426:	02000b13          	li	s6,32
    d42a:	41bb02b3          	sub	t0,s6,s11
    d42e:	0072ff93          	andi	t6,t0,7
    d432:	01b805b3          	add	a1,a6,s11
    d436:	03000713          	li	a4,48
    d43a:	060f8763          	beqz	t6,d4a8 <_vsnprintf+0x48e8>
    d43e:	0d85                	addi	s11,s11,1
    d440:	1815d70b          	th.sbia	a4,(a1),1,0
    d444:	0db50463          	beq	a0,s11,d50c <_vsnprintf+0x494c>
    d448:	4f05                	li	t5,1
    d44a:	05ef8f63          	beq	t6,t5,d4a8 <_vsnprintf+0x48e8>
    d44e:	4789                	li	a5,2
    d450:	04ff8763          	beq	t6,a5,d49e <_vsnprintf+0x48de>
    d454:	438d                	li	t2,3
    d456:	027f8f63          	beq	t6,t2,d494 <_vsnprintf+0x48d4>
    d45a:	4311                	li	t1,4
    d45c:	026f8763          	beq	t6,t1,d48a <_vsnprintf+0x48ca>
    d460:	4e95                	li	t4,5
    d462:	01df8f63          	beq	t6,t4,d480 <_vsnprintf+0x48c0>
    d466:	4c99                	li	s9,6
    d468:	019f8763          	beq	t6,s9,d476 <_vsnprintf+0x48b6>
    d46c:	0d85                	addi	s11,s11,1
    d46e:	1815d70b          	th.sbia	a4,(a1),1,0
    d472:	09b50d63          	beq	a0,s11,d50c <_vsnprintf+0x494c>
    d476:	0d85                	addi	s11,s11,1
    d478:	1815d70b          	th.sbia	a4,(a1),1,0
    d47c:	09b50863          	beq	a0,s11,d50c <_vsnprintf+0x494c>
    d480:	0d85                	addi	s11,s11,1
    d482:	1815d70b          	th.sbia	a4,(a1),1,0
    d486:	09b50363          	beq	a0,s11,d50c <_vsnprintf+0x494c>
    d48a:	0d85                	addi	s11,s11,1
    d48c:	1815d70b          	th.sbia	a4,(a1),1,0
    d490:	07b50e63          	beq	a0,s11,d50c <_vsnprintf+0x494c>
    d494:	0d85                	addi	s11,s11,1
    d496:	1815d70b          	th.sbia	a4,(a1),1,0
    d49a:	07b50963          	beq	a0,s11,d50c <_vsnprintf+0x494c>
    d49e:	0d85                	addi	s11,s11,1
    d4a0:	1815d70b          	th.sbia	a4,(a1),1,0
    d4a4:	07b50463          	beq	a0,s11,d50c <_vsnprintf+0x494c>
    d4a8:	2f6d8ae3          	beq	s11,s6,df9c <_vsnprintf+0x53dc>
    d4ac:	0d85                	addi	s11,s11,1
    d4ae:	00e58023          	sb	a4,0(a1)
    d4b2:	82ee                	mv	t0,s11
    d4b4:	05b50c63          	beq	a0,s11,d50c <_vsnprintf+0x494c>
    d4b8:	0d85                	addi	s11,s11,1
    d4ba:	00e580a3          	sb	a4,1(a1)
    d4be:	05b50763          	beq	a0,s11,d50c <_vsnprintf+0x494c>
    d4c2:	00228d93          	addi	s11,t0,2
    d4c6:	00e58123          	sb	a4,2(a1)
    d4ca:	05b50163          	beq	a0,s11,d50c <_vsnprintf+0x494c>
    d4ce:	00328d93          	addi	s11,t0,3
    d4d2:	00e581a3          	sb	a4,3(a1)
    d4d6:	03b50b63          	beq	a0,s11,d50c <_vsnprintf+0x494c>
    d4da:	00428d93          	addi	s11,t0,4
    d4de:	00e58223          	sb	a4,4(a1)
    d4e2:	03b50563          	beq	a0,s11,d50c <_vsnprintf+0x494c>
    d4e6:	00528d93          	addi	s11,t0,5
    d4ea:	00e582a3          	sb	a4,5(a1)
    d4ee:	01b50f63          	beq	a0,s11,d50c <_vsnprintf+0x494c>
    d4f2:	00628d93          	addi	s11,t0,6
    d4f6:	00e58323          	sb	a4,6(a1)
    d4fa:	01b50963          	beq	a0,s11,d50c <_vsnprintf+0x494c>
    d4fe:	00e583a3          	sb	a4,7(a1)
    d502:	00728d93          	addi	s11,t0,7
    d506:	05a1                	addi	a1,a1,8
    d508:	fbb510e3          	bne	a0,s11,d4a8 <_vsnprintf+0x48e8>
    d50c:	000d0463          	beqz	s10,d514 <_vsnprintf+0x4954>
    d510:	1220106f          	j	e632 <_vsnprintf+0x5a72>
    d514:	3d6d91e3          	bne	s11,s6,e0d6 <_vsnprintf+0x5516>
    d518:	4d01                	li	s10,0
    d51a:	e98fe06f          	j	bbb2 <_vsnprintf+0x2ff2>
    d51e:	0001                	nop
    d520:	588dce8b          	th.lwia	t4,(s11),8,0
    d524:	917fc06f          	j	9e3a <_vsnprintf+0x127a>
    d528:	00278eb3          	add	t4,a5,sp
    d52c:	05800713          	li	a4,88
    d530:	00278d13          	addi	s10,a5,2
    d534:	03000793          	li	a5,48
    d538:	02ee8823          	sb	a4,48(t4)
    d53c:	02fe88a3          	sb	a5,49(t4)
    d540:	4b81                	li	s7,0
    d542:	f1ffd06f          	j	b460 <_vsnprintf+0x28a0>
    d546:	00267e93          	andi	t4,a2,2
    d54a:	380e8fe3          	beqz	t4,e0e8 <_vsnprintf+0x5528>
    d54e:	6e02                	ld	t3,0(sp)
    d550:	a8afe06f          	j	b7da <_vsnprintf+0x2c1a>
    d554:	47a9                	li	a5,10
    d556:	8b2e                	mv	s6,a1
    d558:	86be                	mv	a3,a5
    d55a:	89ffc06f          	j	9df8 <_vsnprintf+0x1238>
    d55e:	ec46                	sd	a7,24(sp)
    d560:	f05a                	sd	s6,32(sp)
    d562:	e43fe06f          	j	c3a4 <_vsnprintf+0x37e4>
    d566:	340889e3          	beqz	a7,e0b8 <_vsnprintf+0x54f8>
    d56a:	0012fd93          	andi	s11,t0,1
    d56e:	7e0d80e3          	beqz	s11,e54e <_vsnprintf+0x598e>
    d572:	000e4463          	bltz	t3,d57a <_vsnprintf+0x49ba>
    d576:	3ec0106f          	j	e962 <_vsnprintf+0x5da2>
    d57a:	7c0c3d0b          	th.extu	s10,s8,31,0
    d57e:	38fd                	addiw	a7,a7,-1
    d580:	01a7f463          	bgeu	a5,s10,d588 <_vsnprintf+0x49c8>
    d584:	b67fd06f          	j	b0ea <_vsnprintf+0x252a>
    d588:	7c08b68b          	th.extu	a3,a7,31,0
    d58c:	00d7e463          	bltu	a5,a3,d594 <_vsnprintf+0x49d4>
    d590:	4d60106f          	j	ea66 <_vsnprintf+0x5ea6>
    d594:	02000d93          	li	s11,32
    d598:	40fd8533          	sub	a0,s11,a5
    d59c:	00757e93          	andi	t4,a0,7
    d5a0:	00f30633          	add	a2,t1,a5
    d5a4:	03000b13          	li	s6,48
    d5a8:	060e8763          	beqz	t4,d616 <_vsnprintf+0x4a56>
    d5ac:	0785                	addi	a5,a5,1
    d5ae:	18165b0b          	th.sbia	s6,(a2),1,0
    d5b2:	0cd78463          	beq	a5,a3,d67a <_vsnprintf+0x4aba>
    d5b6:	4f05                	li	t5,1
    d5b8:	05ee8f63          	beq	t4,t5,d616 <_vsnprintf+0x4a56>
    d5bc:	4a89                	li	s5,2
    d5be:	055e8763          	beq	t4,s5,d60c <_vsnprintf+0x4a4c>
    d5c2:	428d                	li	t0,3
    d5c4:	025e8f63          	beq	t4,t0,d602 <_vsnprintf+0x4a42>
    d5c8:	4c91                	li	s9,4
    d5ca:	039e8763          	beq	t4,s9,d5f8 <_vsnprintf+0x4a38>
    d5ce:	4c15                	li	s8,5
    d5d0:	018e8f63          	beq	t4,s8,d5ee <_vsnprintf+0x4a2e>
    d5d4:	4b99                	li	s7,6
    d5d6:	017e8763          	beq	t4,s7,d5e4 <_vsnprintf+0x4a24>
    d5da:	0785                	addi	a5,a5,1
    d5dc:	18165b0b          	th.sbia	s6,(a2),1,0
    d5e0:	08d78d63          	beq	a5,a3,d67a <_vsnprintf+0x4aba>
    d5e4:	0785                	addi	a5,a5,1
    d5e6:	18165b0b          	th.sbia	s6,(a2),1,0
    d5ea:	08d78863          	beq	a5,a3,d67a <_vsnprintf+0x4aba>
    d5ee:	0785                	addi	a5,a5,1
    d5f0:	18165b0b          	th.sbia	s6,(a2),1,0
    d5f4:	08d78363          	beq	a5,a3,d67a <_vsnprintf+0x4aba>
    d5f8:	0785                	addi	a5,a5,1
    d5fa:	18165b0b          	th.sbia	s6,(a2),1,0
    d5fe:	06d78e63          	beq	a5,a3,d67a <_vsnprintf+0x4aba>
    d602:	0785                	addi	a5,a5,1
    d604:	18165b0b          	th.sbia	s6,(a2),1,0
    d608:	06d78963          	beq	a5,a3,d67a <_vsnprintf+0x4aba>
    d60c:	0785                	addi	a5,a5,1
    d60e:	18165b0b          	th.sbia	s6,(a2),1,0
    d612:	06d78463          	beq	a5,a3,d67a <_vsnprintf+0x4aba>
    d616:	07b78863          	beq	a5,s11,d686 <_vsnprintf+0x4ac6>
    d61a:	00178f93          	addi	t6,a5,1
    d61e:	01660023          	sb	s6,0(a2)
    d622:	04df8c63          	beq	t6,a3,d67a <_vsnprintf+0x4aba>
    d626:	00278393          	addi	t2,a5,2
    d62a:	016600a3          	sb	s6,1(a2)
    d62e:	04d38663          	beq	t2,a3,d67a <_vsnprintf+0x4aba>
    d632:	00378713          	addi	a4,a5,3
    d636:	01660123          	sb	s6,2(a2)
    d63a:	04d70063          	beq	a4,a3,d67a <_vsnprintf+0x4aba>
    d63e:	00478d13          	addi	s10,a5,4
    d642:	016601a3          	sb	s6,3(a2)
    d646:	02dd0a63          	beq	s10,a3,d67a <_vsnprintf+0x4aba>
    d64a:	00578513          	addi	a0,a5,5
    d64e:	01660223          	sb	s6,4(a2)
    d652:	02d50463          	beq	a0,a3,d67a <_vsnprintf+0x4aba>
    d656:	00678e93          	addi	t4,a5,6
    d65a:	016602a3          	sb	s6,5(a2)
    d65e:	00de8e63          	beq	t4,a3,d67a <_vsnprintf+0x4aba>
    d662:	00778f13          	addi	t5,a5,7
    d666:	01660323          	sb	s6,6(a2)
    d66a:	00df0863          	beq	t5,a3,d67a <_vsnprintf+0x4aba>
    d66e:	016603a3          	sb	s6,7(a2)
    d672:	07a1                	addi	a5,a5,8
    d674:	0621                	addi	a2,a2,8
    d676:	fad790e3          	bne	a5,a3,d616 <_vsnprintf+0x4a56>
    d67a:	02000793          	li	a5,32
    d67e:	00f68463          	beq	a3,a5,d686 <_vsnprintf+0x4ac6>
    d682:	b71fd06f          	j	b1f2 <_vsnprintf+0x2632>
    d686:	898d                	andi	a1,a1,3
    d688:	c199                	beqz	a1,d68e <_vsnprintf+0x4ace>
    d68a:	1170106f          	j	efa0 <_vsnprintf+0x63e0>
    d68e:	02000693          	li	a3,32
    d692:	6116f463          	bgeu	a3,a7,dc9a <_vsnprintf+0x50da>
    d696:	7c08bb8b          	th.extu	s7,a7,31,0
    d69a:	8dc2                	mv	s11,a6
    d69c:	8d36                	mv	s10,a3
    d69e:	4b01                	li	s6,0
    d6a0:	b85fd06f          	j	b224 <_vsnprintf+0x2664>
    d6a4:	02b00513          	li	a0,43
    d6a8:	feae0023          	sb	a0,-32(t3)
    d6ac:	a5efc06f          	j	990a <_vsnprintf+0xd4a>
    d6b0:	898d                	andi	a1,a1,3
    d6b2:	c199                	beqz	a1,d6b8 <_vsnprintf+0x4af8>
    d6b4:	2620106f          	j	e916 <_vsnprintf+0x5d56>
    d6b8:	02000693          	li	a3,32
    d6bc:	0316f763          	bgeu	a3,a7,d6ea <_vsnprintf+0x4b2a>
    d6c0:	7c08bb8b          	th.extu	s7,a7,31,0
    d6c4:	8dc2                	mv	s11,a6
    d6c6:	8c36                	mv	s8,a3
    d6c8:	4b01                	li	s6,0
    d6ca:	daaff06f          	j	cc74 <_vsnprintf+0x40b4>
    d6ce:	fe0d81e3          	beqz	s11,d6b0 <_vsnprintf+0x4af0>
    d6d2:	7c08b68b          	th.extu	a3,a7,31,0
    d6d6:	00d7f463          	bgeu	a5,a3,d6de <_vsnprintf+0x4b1e>
    d6da:	8edfe06f          	j	bfc6 <_vsnprintf+0x3406>
    d6de:	0035fc13          	andi	s8,a1,3
    d6e2:	000c0463          	beqz	s8,d6ea <_vsnprintf+0x4b2a>
    d6e6:	2300106f          	j	e916 <_vsnprintf+0x5d56>
    d6ea:	8dc2                	mv	s11,a6
    d6ec:	04f14503          	lbu	a0,79(sp)
    d6f0:	6802                	ld	a6,0(sp)
    d6f2:	02000c13          	li	s8,32
    d6f6:	4b01                	li	s6,0
    d6f8:	b63fe06f          	j	c25a <_vsnprintf+0x369a>
    d6fc:	4b81                	li	s7,0
    d6fe:	963fd06f          	j	b060 <_vsnprintf+0x24a0>
    d702:	47c1                	li	a5,16
    d704:	95dfd06f          	j	b060 <_vsnprintf+0x24a0>
    d708:	ec46                	sd	a7,24(sp)
    d70a:	fd515b8b          	th.sdd	s7,s5,(sp),2,4
    d70e:	b4afc06f          	j	9a58 <_vsnprintf+0xe98>
    d712:	220e47e3          	bltz	t3,e140 <_vsnprintf+0x5580>
    d716:	004afe13          	andi	t3,s5,4
    d71a:	000e1463          	bnez	t3,d722 <_vsnprintf+0x4b62>
    d71e:	2920106f          	j	e9b0 <_vsnprintf+0x5df0>
    d722:	00278d33          	add	s10,a5,sp
    d726:	02b00513          	li	a0,43
    d72a:	02ad0823          	sb	a0,48(s10)
    d72e:	6302                	ld	t1,0(sp)
    d730:	00178c13          	addi	s8,a5,1
    d734:	4b09                	li	s6,2
    d736:	d10fd06f          	j	ac46 <_vsnprintf+0x2086>
    d73a:	7c0c3c0b          	th.extu	s8,s8,31,0
    d73e:	0187e463          	bltu	a5,s8,d746 <_vsnprintf+0x4b86>
    d742:	7020106f          	j	ee44 <_vsnprintf+0x6284>
    d746:	0015fd93          	andi	s11,a1,1
    d74a:	4881                	li	a7,0
    d74c:	f7cfe06f          	j	bec8 <_vsnprintf+0x3308>
    d750:	7a088ee3          	beqz	a7,e70c <_vsnprintf+0x5b4c>
    d754:	001e7c93          	andi	s9,t3,1
    d758:	7c0c370b          	th.extu	a4,s8,31,0
    d75c:	000c9463          	bnez	s9,d764 <_vsnprintf+0x4ba4>
    d760:	0d80106f          	j	e838 <_vsnprintf+0x5c78>
    d764:	0eed7763          	bgeu	s10,a4,d852 <_vsnprintf+0x4c92>
    d768:	02000313          	li	t1,32
    d76c:	41a30fb3          	sub	t6,t1,s10
    d770:	007fff13          	andi	t5,t6,7
    d774:	01ab0533          	add	a0,s6,s10
    d778:	03000393          	li	t2,48
    d77c:	060f0763          	beqz	t5,d7ea <_vsnprintf+0x4c2a>
    d780:	0d05                	addi	s10,s10,1
    d782:	1815538b          	th.sbia	t2,(a0),1,0
    d786:	0ced7463          	bgeu	s10,a4,d84e <_vsnprintf+0x4c8e>
    d78a:	4585                	li	a1,1
    d78c:	04bf0f63          	beq	t5,a1,d7ea <_vsnprintf+0x4c2a>
    d790:	4e09                	li	t3,2
    d792:	05cf0763          	beq	t5,t3,d7e0 <_vsnprintf+0x4c20>
    d796:	478d                	li	a5,3
    d798:	02ff0f63          	beq	t5,a5,d7d6 <_vsnprintf+0x4c16>
    d79c:	4d91                	li	s11,4
    d79e:	03bf0763          	beq	t5,s11,d7cc <_vsnprintf+0x4c0c>
    d7a2:	4295                	li	t0,5
    d7a4:	005f0f63          	beq	t5,t0,d7c2 <_vsnprintf+0x4c02>
    d7a8:	4f99                	li	t6,6
    d7aa:	01ff0763          	beq	t5,t6,d7b8 <_vsnprintf+0x4bf8>
    d7ae:	0d05                	addi	s10,s10,1
    d7b0:	1815538b          	th.sbia	t2,(a0),1,0
    d7b4:	08ed7d63          	bgeu	s10,a4,d84e <_vsnprintf+0x4c8e>
    d7b8:	0d05                	addi	s10,s10,1
    d7ba:	1815538b          	th.sbia	t2,(a0),1,0
    d7be:	08ed7863          	bgeu	s10,a4,d84e <_vsnprintf+0x4c8e>
    d7c2:	0d05                	addi	s10,s10,1
    d7c4:	1815538b          	th.sbia	t2,(a0),1,0
    d7c8:	08ed7363          	bgeu	s10,a4,d84e <_vsnprintf+0x4c8e>
    d7cc:	0d05                	addi	s10,s10,1
    d7ce:	1815538b          	th.sbia	t2,(a0),1,0
    d7d2:	06ed7e63          	bgeu	s10,a4,d84e <_vsnprintf+0x4c8e>
    d7d6:	0d05                	addi	s10,s10,1
    d7d8:	1815538b          	th.sbia	t2,(a0),1,0
    d7dc:	06ed7963          	bgeu	s10,a4,d84e <_vsnprintf+0x4c8e>
    d7e0:	0d05                	addi	s10,s10,1
    d7e2:	1815538b          	th.sbia	t2,(a0),1,0
    d7e6:	06ed7463          	bgeu	s10,a4,d84e <_vsnprintf+0x4c8e>
    d7ea:	066d0263          	beq	s10,t1,d84e <_vsnprintf+0x4c8e>
    d7ee:	0d05                	addi	s10,s10,1
    d7f0:	00750023          	sb	t2,0(a0)
    d7f4:	8f6a                	mv	t5,s10
    d7f6:	04ed7c63          	bgeu	s10,a4,d84e <_vsnprintf+0x4c8e>
    d7fa:	0d05                	addi	s10,s10,1
    d7fc:	007500a3          	sb	t2,1(a0)
    d800:	04ed7763          	bgeu	s10,a4,d84e <_vsnprintf+0x4c8e>
    d804:	002f0d13          	addi	s10,t5,2
    d808:	00750123          	sb	t2,2(a0)
    d80c:	04ed7163          	bgeu	s10,a4,d84e <_vsnprintf+0x4c8e>
    d810:	003f0d13          	addi	s10,t5,3
    d814:	007501a3          	sb	t2,3(a0)
    d818:	02ed7b63          	bgeu	s10,a4,d84e <_vsnprintf+0x4c8e>
    d81c:	004f0d13          	addi	s10,t5,4
    d820:	00750223          	sb	t2,4(a0)
    d824:	02ed7563          	bgeu	s10,a4,d84e <_vsnprintf+0x4c8e>
    d828:	005f0d13          	addi	s10,t5,5
    d82c:	007502a3          	sb	t2,5(a0)
    d830:	00ed7f63          	bgeu	s10,a4,d84e <_vsnprintf+0x4c8e>
    d834:	006f0d13          	addi	s10,t5,6
    d838:	00750323          	sb	t2,6(a0)
    d83c:	00ed7963          	bgeu	s10,a4,d84e <_vsnprintf+0x4c8e>
    d840:	007503a3          	sb	t2,7(a0)
    d844:	007f0d13          	addi	s10,t5,7
    d848:	0521                	addi	a0,a0,8
    d84a:	faed60e3          	bltu	s10,a4,d7ea <_vsnprintf+0x4c2a>
    d84e:	620c84e3          	beqz	s9,e676 <_vsnprintf+0x5ab6>
    d852:	7c08b78b          	th.extu	a5,a7,31,0
    d856:	00fd6463          	bltu	s10,a5,d85e <_vsnprintf+0x4c9e>
    d85a:	6020106f          	j	ee5c <_vsnprintf+0x629c>
    d85e:	02000c93          	li	s9,32
    d862:	41ac83b3          	sub	t2,s9,s10
    d866:	0073fe13          	andi	t3,t2,7
    d86a:	01ab05b3          	add	a1,s6,s10
    d86e:	03000313          	li	t1,48
    d872:	060e0763          	beqz	t3,d8e0 <_vsnprintf+0x4d20>
    d876:	0d05                	addi	s10,s10,1
    d878:	1815d30b          	th.sbia	t1,(a1),1,0
    d87c:	0da78463          	beq	a5,s10,d944 <_vsnprintf+0x4d84>
    d880:	4d85                	li	s11,1
    d882:	05be0f63          	beq	t3,s11,d8e0 <_vsnprintf+0x4d20>
    d886:	4289                	li	t0,2
    d888:	045e0763          	beq	t3,t0,d8d6 <_vsnprintf+0x4d16>
    d88c:	4f8d                	li	t6,3
    d88e:	03fe0f63          	beq	t3,t6,d8cc <_vsnprintf+0x4d0c>
    d892:	4f11                	li	t5,4
    d894:	03ee0763          	beq	t3,t5,d8c2 <_vsnprintf+0x4d02>
    d898:	4515                	li	a0,5
    d89a:	00ae0f63          	beq	t3,a0,d8b8 <_vsnprintf+0x4cf8>
    d89e:	4719                	li	a4,6
    d8a0:	00ee0763          	beq	t3,a4,d8ae <_vsnprintf+0x4cee>
    d8a4:	0d05                	addi	s10,s10,1
    d8a6:	1815d30b          	th.sbia	t1,(a1),1,0
    d8aa:	09a78d63          	beq	a5,s10,d944 <_vsnprintf+0x4d84>
    d8ae:	0d05                	addi	s10,s10,1
    d8b0:	1815d30b          	th.sbia	t1,(a1),1,0
    d8b4:	09a78863          	beq	a5,s10,d944 <_vsnprintf+0x4d84>
    d8b8:	0d05                	addi	s10,s10,1
    d8ba:	1815d30b          	th.sbia	t1,(a1),1,0
    d8be:	09a78363          	beq	a5,s10,d944 <_vsnprintf+0x4d84>
    d8c2:	0d05                	addi	s10,s10,1
    d8c4:	1815d30b          	th.sbia	t1,(a1),1,0
    d8c8:	07a78e63          	beq	a5,s10,d944 <_vsnprintf+0x4d84>
    d8cc:	0d05                	addi	s10,s10,1
    d8ce:	1815d30b          	th.sbia	t1,(a1),1,0
    d8d2:	07a78963          	beq	a5,s10,d944 <_vsnprintf+0x4d84>
    d8d6:	0d05                	addi	s10,s10,1
    d8d8:	1815d30b          	th.sbia	t1,(a1),1,0
    d8dc:	07a78463          	beq	a5,s10,d944 <_vsnprintf+0x4d84>
    d8e0:	179d07e3          	beq	s10,s9,e24e <_vsnprintf+0x568e>
    d8e4:	0d05                	addi	s10,s10,1
    d8e6:	00658023          	sb	t1,0(a1)
    d8ea:	83ea                	mv	t2,s10
    d8ec:	05a78c63          	beq	a5,s10,d944 <_vsnprintf+0x4d84>
    d8f0:	0d05                	addi	s10,s10,1
    d8f2:	006580a3          	sb	t1,1(a1)
    d8f6:	05a78763          	beq	a5,s10,d944 <_vsnprintf+0x4d84>
    d8fa:	00238d13          	addi	s10,t2,2
    d8fe:	00658123          	sb	t1,2(a1)
    d902:	05a78163          	beq	a5,s10,d944 <_vsnprintf+0x4d84>
    d906:	00338d13          	addi	s10,t2,3
    d90a:	006581a3          	sb	t1,3(a1)
    d90e:	03a78b63          	beq	a5,s10,d944 <_vsnprintf+0x4d84>
    d912:	00438d13          	addi	s10,t2,4
    d916:	00658223          	sb	t1,4(a1)
    d91a:	03a78563          	beq	a5,s10,d944 <_vsnprintf+0x4d84>
    d91e:	00538d13          	addi	s10,t2,5
    d922:	006582a3          	sb	t1,5(a1)
    d926:	01a78f63          	beq	a5,s10,d944 <_vsnprintf+0x4d84>
    d92a:	00638d13          	addi	s10,t2,6
    d92e:	00658323          	sb	t1,6(a1)
    d932:	01a78963          	beq	a5,s10,d944 <_vsnprintf+0x4d84>
    d936:	006583a3          	sb	t1,7(a1)
    d93a:	00738d13          	addi	s10,t2,7
    d93e:	05a1                	addi	a1,a1,8
    d940:	fba790e3          	bne	a5,s10,d8e0 <_vsnprintf+0x4d20>
    d944:	4a0e9be3          	bnez	t4,e5fa <_vsnprintf+0x5a3a>
    d948:	819d0663          	beq	s10,s9,c954 <_vsnprintf+0x3d94>
    d94c:	00367b93          	andi	s7,a2,3
    d950:	000b8463          	beqz	s7,d958 <_vsnprintf+0x4d98>
    d954:	3160106f          	j	ec6a <_vsnprintf+0x60aa>
    d958:	8c3e                	mv	s8,a5
    d95a:	10fd67e3          	bltu	s10,a5,e268 <_vsnprintf+0x56a8>
    d95e:	6382                	ld	t2,0(sp)
    d960:	ffdfe06f          	j	c95c <_vsnprintf+0x3d9c>
    d964:	4d09                	li	s10,2
    d966:	500b83e3          	beqz	s7,e66c <_vsnprintf+0x5aac>
    d96a:	4b41                	li	s6,16
    d96c:	57668be3          	beq	a3,s6,e6e2 <_vsnprintf+0x5b22>
    d970:	4a89                	li	s5,2
    d972:	555688e3          	beq	a3,s5,e6c2 <_vsnprintf+0x5b02>
    d976:	02000593          	li	a1,32
    d97a:	5cb71663          	bne	a4,a1,df46 <_vsnprintf+0x5386>
    d97e:	003e7513          	andi	a0,t3,3
    d982:	c119                	beqz	a0,d988 <_vsnprintf+0x4dc8>
    d984:	ce5fd06f          	j	b668 <_vsnprintf+0x2aa8>
    d988:	02000713          	li	a4,32
    d98c:	01176463          	bltu	a4,a7,d994 <_vsnprintf+0x4dd4>
    d990:	cd9fd06f          	j	b668 <_vsnprintf+0x2aa8>
    d994:	7c08bc0b          	th.extu	s8,a7,31,0
    d998:	6602                	ld	a2,0(sp)
    d99a:	ec3a                	sd	a4,24(sp)
    d99c:	f046                	sd	a7,32(sp)
    d99e:	40c70cb3          	sub	s9,a4,a2
    d9a2:	fffcc813          	not	a6,s9
    d9a6:	40c80eb3          	sub	t4,a6,a2
    d9aa:	018e8b33          	add	s6,t4,s8
    d9ae:	02000513          	li	a0,32
    d9b2:	86a6                	mv	a3,s1
    d9b4:	85ca                	mv	a1,s2
    d9b6:	007b7a93          	andi	s5,s6,7
    d9ba:	00160b13          	addi	s6,a2,1
    d9be:	9402                	jalr	s0
    d9c0:	016c8533          	add	a0,s9,s6
    d9c4:	6762                	ld	a4,24(sp)
    d9c6:	7882                	ld	a7,32(sp)
    d9c8:	17857263          	bgeu	a0,s8,db2c <_vsnprintf+0x4f6c>
    d9cc:	0c0a8763          	beqz	s5,da9a <_vsnprintf+0x4eda>
    d9d0:	4305                	li	t1,1
    d9d2:	0a6a8563          	beq	s5,t1,da7c <_vsnprintf+0x4ebc>
    d9d6:	4289                	li	t0,2
    d9d8:	085a8763          	beq	s5,t0,da66 <_vsnprintf+0x4ea6>
    d9dc:	438d                	li	t2,3
    d9de:	067a8963          	beq	s5,t2,da50 <_vsnprintf+0x4e90>
    d9e2:	4f11                	li	t5,4
    d9e4:	05ea8b63          	beq	s5,t5,da3a <_vsnprintf+0x4e7a>
    d9e8:	4695                	li	a3,5
    d9ea:	02da8d63          	beq	s5,a3,da24 <_vsnprintf+0x4e64>
    d9ee:	4799                	li	a5,6
    d9f0:	00fa8f63          	beq	s5,a5,da0e <_vsnprintf+0x4e4e>
    d9f4:	ec46                	sd	a7,24(sp)
    d9f6:	f03a                	sd	a4,32(sp)
    d9f8:	865a                	mv	a2,s6
    d9fa:	86a6                	mv	a3,s1
    d9fc:	85ca                	mv	a1,s2
    d9fe:	02000513          	li	a0,32
    da02:	6b82                	ld	s7,0(sp)
    da04:	9402                	jalr	s0
    da06:	68e2                	ld	a7,24(sp)
    da08:	7702                	ld	a4,32(sp)
    da0a:	002b8b13          	addi	s6,s7,2
    da0e:	ec46                	sd	a7,24(sp)
    da10:	f03a                	sd	a4,32(sp)
    da12:	865a                	mv	a2,s6
    da14:	86a6                	mv	a3,s1
    da16:	85ca                	mv	a1,s2
    da18:	02000513          	li	a0,32
    da1c:	9402                	jalr	s0
    da1e:	68e2                	ld	a7,24(sp)
    da20:	7702                	ld	a4,32(sp)
    da22:	0b05                	addi	s6,s6,1
    da24:	ec46                	sd	a7,24(sp)
    da26:	f03a                	sd	a4,32(sp)
    da28:	865a                	mv	a2,s6
    da2a:	86a6                	mv	a3,s1
    da2c:	85ca                	mv	a1,s2
    da2e:	02000513          	li	a0,32
    da32:	9402                	jalr	s0
    da34:	68e2                	ld	a7,24(sp)
    da36:	7702                	ld	a4,32(sp)
    da38:	0b05                	addi	s6,s6,1
    da3a:	ec46                	sd	a7,24(sp)
    da3c:	f03a                	sd	a4,32(sp)
    da3e:	865a                	mv	a2,s6
    da40:	86a6                	mv	a3,s1
    da42:	85ca                	mv	a1,s2
    da44:	02000513          	li	a0,32
    da48:	9402                	jalr	s0
    da4a:	68e2                	ld	a7,24(sp)
    da4c:	7702                	ld	a4,32(sp)
    da4e:	0b05                	addi	s6,s6,1
    da50:	ec46                	sd	a7,24(sp)
    da52:	f03a                	sd	a4,32(sp)
    da54:	865a                	mv	a2,s6
    da56:	86a6                	mv	a3,s1
    da58:	85ca                	mv	a1,s2
    da5a:	02000513          	li	a0,32
    da5e:	9402                	jalr	s0
    da60:	68e2                	ld	a7,24(sp)
    da62:	7702                	ld	a4,32(sp)
    da64:	0b05                	addi	s6,s6,1
    da66:	ec46                	sd	a7,24(sp)
    da68:	f03a                	sd	a4,32(sp)
    da6a:	865a                	mv	a2,s6
    da6c:	86a6                	mv	a3,s1
    da6e:	85ca                	mv	a1,s2
    da70:	02000513          	li	a0,32
    da74:	9402                	jalr	s0
    da76:	68e2                	ld	a7,24(sp)
    da78:	7702                	ld	a4,32(sp)
    da7a:	0b05                	addi	s6,s6,1
    da7c:	ec46                	sd	a7,24(sp)
    da7e:	f03a                	sd	a4,32(sp)
    da80:	865a                	mv	a2,s6
    da82:	86a6                	mv	a3,s1
    da84:	85ca                	mv	a1,s2
    da86:	02000513          	li	a0,32
    da8a:	9402                	jalr	s0
    da8c:	0b05                	addi	s6,s6,1
    da8e:	016c8fb3          	add	t6,s9,s6
    da92:	68e2                	ld	a7,24(sp)
    da94:	7702                	ld	a4,32(sp)
    da96:	098ffb63          	bgeu	t6,s8,db2c <_vsnprintf+0x4f6c>
    da9a:	ec6e                	sd	s11,24(sp)
    da9c:	8dc6                	mv	s11,a7
    da9e:	f03a                	sd	a4,32(sp)
    daa0:	865a                	mv	a2,s6
    daa2:	86a6                	mv	a3,s1
    daa4:	85ca                	mv	a1,s2
    daa6:	02000513          	li	a0,32
    daaa:	9402                	jalr	s0
    daac:	001b0a93          	addi	s5,s6,1
    dab0:	8656                	mv	a2,s5
    dab2:	86a6                	mv	a3,s1
    dab4:	85ca                	mv	a1,s2
    dab6:	02000513          	li	a0,32
    daba:	9402                	jalr	s0
    dabc:	002b0b93          	addi	s7,s6,2
    dac0:	865e                	mv	a2,s7
    dac2:	86a6                	mv	a3,s1
    dac4:	85ca                	mv	a1,s2
    dac6:	02000513          	li	a0,32
    daca:	9402                	jalr	s0
    dacc:	003b0a93          	addi	s5,s6,3
    dad0:	8656                	mv	a2,s5
    dad2:	86a6                	mv	a3,s1
    dad4:	85ca                	mv	a1,s2
    dad6:	02000513          	li	a0,32
    dada:	9402                	jalr	s0
    dadc:	004b0b93          	addi	s7,s6,4
    dae0:	865e                	mv	a2,s7
    dae2:	86a6                	mv	a3,s1
    dae4:	85ca                	mv	a1,s2
    dae6:	02000513          	li	a0,32
    daea:	9402                	jalr	s0
    daec:	005b0a93          	addi	s5,s6,5
    daf0:	8656                	mv	a2,s5
    daf2:	86a6                	mv	a3,s1
    daf4:	85ca                	mv	a1,s2
    daf6:	02000513          	li	a0,32
    dafa:	9402                	jalr	s0
    dafc:	006b0b93          	addi	s7,s6,6
    db00:	86a6                	mv	a3,s1
    db02:	865e                	mv	a2,s7
    db04:	85ca                	mv	a1,s2
    db06:	02000513          	li	a0,32
    db0a:	9402                	jalr	s0
    db0c:	007b0a93          	addi	s5,s6,7
    db10:	86a6                	mv	a3,s1
    db12:	8656                	mv	a2,s5
    db14:	85ca                	mv	a1,s2
    db16:	02000513          	li	a0,32
    db1a:	9402                	jalr	s0
    db1c:	0b21                	addi	s6,s6,8
    db1e:	016c88b3          	add	a7,s9,s6
    db22:	7702                	ld	a4,32(sp)
    db24:	f788ede3          	bltu	a7,s8,da9e <_vsnprintf+0x4ede>
    db28:	88ee                	mv	a7,s11
    db2a:	6de2                	ld	s11,24(sp)
    db2c:	6c82                	ld	s9,0(sp)
    db2e:	fffc0e13          	addi	t3,s8,-1
    db32:	00170593          	addi	a1,a4,1
    db36:	40ee07b3          	sub	a5,t3,a4
    db3a:	00bc3633          	sltu	a2,s8,a1
    db3e:	42c0178b          	th.mvnez	a5,zero,a2
    db42:	001c8e93          	addi	t4,s9,1
    db46:	03010813          	addi	a6,sp,48
    db4a:	01d78e33          	add	t3,a5,t4
    db4e:	c319                	beqz	a4,db54 <_vsnprintf+0x4f94>
    db50:	b1ffd06f          	j	b66e <_vsnprintf+0x2aae>
    db54:	c7ffd06f          	j	b7d2 <_vsnprintf+0x2c12>
    db58:	4805                	li	a6,1
    db5a:	010d0463          	beq	s10,a6,db62 <_vsnprintf+0x4fa2>
    db5e:	1040106f          	j	ec62 <_vsnprintf+0x60a2>
    db62:	678d                	lui	a5,0x3
    db64:	05878293          	addi	t0,a5,88 # 3058 <matrix_test+0x848>
    db68:	02511823          	sh	t0,48(sp)
    db6c:	00457f93          	andi	t6,a0,4
    db70:	1a0f8ee3          	beqz	t6,e52c <_vsnprintf+0x596c>
    db74:	4b89                	li	s7,2
    db76:	87de                	mv	a5,s7
    db78:	4ac1                	li	s5,16
    db7a:	ce6fd06f          	j	b060 <_vsnprintf+0x24a0>
    db7e:	7c0c350b          	th.extu	a0,s8,31,0
    db82:	00a76463          	bltu	a4,a0,db8a <_vsnprintf+0x4fca>
    db86:	2f00106f          	j	ee76 <_vsnprintf+0x62b6>
    db8a:	001e7b13          	andi	s6,t3,1
    db8e:	aaaff06f          	j	ce38 <_vsnprintf+0x4278>
    db92:	f2000353          	fmv.d.x	ft6,zero
    db96:	a26513d3          	flt.d	t2,fa0,ft6
    db9a:	00038463          	beqz	t2,dba2 <_vsnprintf+0x4fe2>
    db9e:	91dfd06f          	j	b4ba <_vsnprintf+0x28fa>
    dba2:	77fd                	lui	a5,0xfffff
    dba4:	7ff78f93          	addi	t6,a5,2047 # fffffffffffff7ff <__kernel_stack+0xfffffffffff117ff>
    dba8:	01fb7b33          	and	s6,s6,t6
    dbac:	400b6e93          	ori	t4,s6,1024
    dbb0:	000e881b          	sext.w	a6,t4
    dbb4:	87c6                	mv	a5,a7
    dbb6:	876e                	mv	a4,s11
    dbb8:	f2068553          	fmv.d.x	fa0,a3
    dbbc:	a5bfc06f          	j	a616 <_vsnprintf+0x1a56>
    dbc0:	7c0c350b          	th.extu	a0,s8,31,0
    dbc4:	00ade463          	bltu	s11,a0,dbcc <_vsnprintf+0x500c>
    dbc8:	2c80106f          	j	ee90 <_vsnprintf+0x62d0>
    dbcc:	00167b13          	andi	s6,a2,1
    dbd0:	f64ff06f          	j	d334 <_vsnprintf+0x4774>
    dbd4:	0045fc13          	andi	s8,a1,4
    dbd8:	02b00513          	li	a0,43
    dbdc:	000c1863          	bnez	s8,dbec <_vsnprintf+0x502c>
    dbe0:	008d7593          	andi	a1,s10,8
    dbe4:	500587e3          	beqz	a1,e8f2 <_vsnprintf+0x5d32>
    dbe8:	02000513          	li	a0,32
    dbec:	6302                	ld	t1,0(sp)
    dbee:	02a10823          	sb	a0,48(sp)
    dbf2:	4c05                	li	s8,1
    dbf4:	4b09                	li	s6,2
    dbf6:	03010b93          	addi	s7,sp,48
    dbfa:	84cfd06f          	j	ac46 <_vsnprintf+0x2086>
    dbfe:	0e0ec9e3          	bltz	t4,e4f0 <_vsnprintf+0x5930>
    dc02:	0046fe93          	andi	t4,a3,4
    dc06:	3e0e87e3          	beqz	t4,e7f4 <_vsnprintf+0x5c34>
    dc0a:	002782b3          	add	t0,a5,sp
    dc0e:	02b00513          	li	a0,43
    dc12:	02a28823          	sb	a0,48(t0)
    dc16:	8dc2                	mv	s11,a6
    dc18:	00178c13          	addi	s8,a5,1
    dc1c:	6802                	ld	a6,0(sp)
    dc1e:	4b09                	li	s6,2
    dc20:	e3afe06f          	j	c25a <_vsnprintf+0x369a>
    dc24:	5e0e9163          	bnez	t4,e206 <_vsnprintf+0x5646>
    dc28:	4d01                	li	s10,0
    dc2a:	003e7e13          	andi	t3,t3,3
    dc2e:	000e0463          	beqz	t3,dc36 <_vsnprintf+0x5076>
    dc32:	a37fd06f          	j	b668 <_vsnprintf+0x2aa8>
    dc36:	02000713          	li	a4,32
    dc3a:	7c08bc0b          	th.extu	s8,a7,31,0
    dc3e:	d5176de3          	bltu	a4,a7,d998 <_vsnprintf+0x4dd8>
    dc42:	a27fd06f          	j	b668 <_vsnprintf+0x2aa8>
    dc46:	0001                	nop
    dc48:	4b81                	li	s7,0
    dc4a:	020d0293          	addi	t0,s10,32
    dc4e:	03010e93          	addi	t4,sp,48
    dc52:	01d28fb3          	add	t6,t0,t4
    dc56:	05800713          	li	a4,88
    dc5a:	03000e13          	li	t3,48
    dc5e:	fcef8f23          	sb	a4,-34(t6)
    dc62:	fdcf8fa3          	sb	t3,-33(t6)
    dc66:	0045ff13          	andi	t5,a1,4
    dc6a:	000f0563          	beqz	t5,dc74 <_vsnprintf+0x50b4>
    dc6e:	87ea                	mv	a5,s10
    dc70:	bf0fd06f          	j	b060 <_vsnprintf+0x24a0>
    dc74:	89a1                	andi	a1,a1,8
    dc76:	e199                	bnez	a1,dc7c <_vsnprintf+0x50bc>
    dc78:	993fc06f          	j	a60a <_vsnprintf+0x1a4a>
    dc7c:	87ea                	mv	a5,s10
    dc7e:	811fd06f          	j	b48e <_vsnprintf+0x28ce>
    dc82:	a00d82e3          	beqz	s11,d686 <_vsnprintf+0x4ac6>
    dc86:	7c08b68b          	th.extu	a3,a7,31,0
    dc8a:	90d7e5e3          	bltu	a5,a3,d594 <_vsnprintf+0x49d4>
    dc8e:	0035fd13          	andi	s10,a1,3
    dc92:	000d0463          	beqz	s10,dc9a <_vsnprintf+0x50da>
    dc96:	30a0106f          	j	efa0 <_vsnprintf+0x63e0>
    dc9a:	04f14503          	lbu	a0,79(sp)
    dc9e:	6382                	ld	t2,0(sp)
    dca0:	8dc2                	mv	s11,a6
    dca2:	02000d13          	li	s10,32
    dca6:	4b01                	li	s6,0
    dca8:	cbcfc06f          	j	a164 <_vsnprintf+0x15a4>
    dcac:	002b7b93          	andi	s7,s6,2
    dcb0:	000b9463          	bnez	s7,dcb8 <_vsnprintf+0x50f8>
    dcb4:	ca7fd06f          	j	b95a <_vsnprintf+0x2d9a>
    dcb8:	6b02                	ld	s6,0(sp)
    dcba:	4b81                	li	s7,0
    dcbc:	e98fb06f          	j	9354 <_vsnprintf+0x794>
    dcc0:	4b89                	li	s7,2
    dcc2:	4ac1                	li	s5,16
    dcc4:	03010b13          	addi	s6,sp,48
    dcc8:	fc6fd06f          	j	b48e <_vsnprintf+0x28ce>
    dccc:	020e8fe3          	beqz	t4,e50a <_vsnprintf+0x594a>
    dcd0:	040b9863          	bnez	s7,dd20 <_vsnprintf+0x5160>
    dcd4:	00e50763          	beq	a0,a4,dce2 <_vsnprintf+0x5122>
    dcd8:	7c08be8b          	th.extu	t4,a7,31,0
    dcdc:	8d5e                	mv	s10,s7
    dcde:	c8ee96e3          	bne	t4,a4,d96a <_vsnprintf+0x4daa>
    dce2:	fff70793          	addi	a5,a4,-1
    dce6:	40079ae3          	bnez	a5,e8fa <_vsnprintf+0x5d3a>
    dcea:	4741                	li	a4,16
    dcec:	58e68de3          	beq	a3,a4,ea86 <_vsnprintf+0x5ec6>
    dcf0:	4d09                	li	s10,2
    dcf2:	01a69463          	bne	a3,s10,dcfa <_vsnprintf+0x513a>
    dcf6:	2f00106f          	j	efe6 <_vsnprintf+0x6426>
    dcfa:	03000e93          	li	t4,48
    dcfe:	03d10823          	sb	t4,48(sp)
    dd02:	003e7e13          	andi	t3,t3,3
    dd06:	000e1463          	bnez	t3,dd0e <_vsnprintf+0x514e>
    dd0a:	2c60106f          	j	efd0 <_vsnprintf+0x6410>
    dd0e:	6e02                	ld	t3,0(sp)
    dd10:	8d5e                	mv	s10,s7
    dd12:	4705                	li	a4,1
    dd14:	95bfd06f          	j	b66e <_vsnprintf+0x2aae>
    dd18:	3eec00e3          	beq	s8,a4,e8f8 <_vsnprintf+0x5d38>
    dd1c:	3ce88ee3          	beq	a7,a4,e8f8 <_vsnprintf+0x5d38>
    dd20:	4d01                	li	s10,0
    dd22:	b1a1                	j	d96a <_vsnprintf+0x4daa>
    dd24:	4d09                	li	s10,2
    dd26:	7c0c350b          	th.extu	a0,s8,31,0
    dd2a:	2e0b8663          	beqz	s7,e016 <_vsnprintf+0x5456>
    dd2e:	4f41                	li	t5,16
    dd30:	49e68d63          	beq	a3,t5,e1ca <_vsnprintf+0x560a>
    dd34:	4789                	li	a5,2
    dd36:	40f687e3          	beq	a3,a5,e944 <_vsnprintf+0x5d84>
    dd3a:	02000f13          	li	t5,32
    dd3e:	29ed9d63          	bne	s11,t5,dfd8 <_vsnprintf+0x5418>
    dd42:	00367d93          	andi	s11,a2,3
    dd46:	000d8463          	beqz	s11,dd4e <_vsnprintf+0x518e>
    dd4a:	e69fd06f          	j	bbb2 <_vsnprintf+0x2ff2>
    dd4e:	02000613          	li	a2,32
    dd52:	01166463          	bltu	a2,a7,dd5a <_vsnprintf+0x519a>
    dd56:	e5dfd06f          	j	bbb2 <_vsnprintf+0x2ff2>
    dd5a:	7c08bc0b          	th.extu	s8,a7,31,0
    dd5e:	8db2                	mv	s11,a2
    dd60:	6602                	ld	a2,0(sp)
    dd62:	02000513          	li	a0,32
    dd66:	ec46                	sd	a7,24(sp)
    dd68:	40cd8cb3          	sub	s9,s11,a2
    dd6c:	fffcc813          	not	a6,s9
    dd70:	01880bb3          	add	s7,a6,s8
    dd74:	40cb8b33          	sub	s6,s7,a2
    dd78:	86a6                	mv	a3,s1
    dd7a:	85ca                	mv	a1,s2
    dd7c:	007b7b93          	andi	s7,s6,7
    dd80:	00160b13          	addi	s6,a2,1
    dd84:	9402                	jalr	s0
    dd86:	016c8533          	add	a0,s9,s6
    dd8a:	68e2                	ld	a7,24(sp)
    dd8c:	15857663          	bgeu	a0,s8,ded8 <_vsnprintf+0x5318>
    dd90:	0a0b8963          	beqz	s7,de42 <_vsnprintf+0x5282>
    dd94:	4705                	li	a4,1
    dd96:	08eb8963          	beq	s7,a4,de28 <_vsnprintf+0x5268>
    dd9a:	4f89                	li	t6,2
    dd9c:	07fb8d63          	beq	s7,t6,de16 <_vsnprintf+0x5256>
    dda0:	468d                	li	a3,3
    dda2:	06db8163          	beq	s7,a3,de04 <_vsnprintf+0x5244>
    dda6:	4f11                	li	t5,4
    dda8:	05eb8563          	beq	s7,t5,ddf2 <_vsnprintf+0x5232>
    ddac:	4795                	li	a5,5
    ddae:	02fb8963          	beq	s7,a5,dde0 <_vsnprintf+0x5220>
    ddb2:	4399                	li	t2,6
    ddb4:	007b8d63          	beq	s7,t2,ddce <_vsnprintf+0x520e>
    ddb8:	6302                	ld	t1,0(sp)
    ddba:	865a                	mv	a2,s6
    ddbc:	ec46                	sd	a7,24(sp)
    ddbe:	86a6                	mv	a3,s1
    ddc0:	85ca                	mv	a1,s2
    ddc2:	02000513          	li	a0,32
    ddc6:	00230b13          	addi	s6,t1,2
    ddca:	9402                	jalr	s0
    ddcc:	68e2                	ld	a7,24(sp)
    ddce:	865a                	mv	a2,s6
    ddd0:	ec46                	sd	a7,24(sp)
    ddd2:	86a6                	mv	a3,s1
    ddd4:	85ca                	mv	a1,s2
    ddd6:	02000513          	li	a0,32
    ddda:	9402                	jalr	s0
    dddc:	68e2                	ld	a7,24(sp)
    ddde:	0b05                	addi	s6,s6,1
    dde0:	865a                	mv	a2,s6
    dde2:	ec46                	sd	a7,24(sp)
    dde4:	86a6                	mv	a3,s1
    dde6:	85ca                	mv	a1,s2
    dde8:	02000513          	li	a0,32
    ddec:	9402                	jalr	s0
    ddee:	68e2                	ld	a7,24(sp)
    ddf0:	0b05                	addi	s6,s6,1
    ddf2:	865a                	mv	a2,s6
    ddf4:	ec46                	sd	a7,24(sp)
    ddf6:	86a6                	mv	a3,s1
    ddf8:	85ca                	mv	a1,s2
    ddfa:	02000513          	li	a0,32
    ddfe:	9402                	jalr	s0
    de00:	68e2                	ld	a7,24(sp)
    de02:	0b05                	addi	s6,s6,1
    de04:	865a                	mv	a2,s6
    de06:	ec46                	sd	a7,24(sp)
    de08:	86a6                	mv	a3,s1
    de0a:	85ca                	mv	a1,s2
    de0c:	02000513          	li	a0,32
    de10:	9402                	jalr	s0
    de12:	68e2                	ld	a7,24(sp)
    de14:	0b05                	addi	s6,s6,1
    de16:	865a                	mv	a2,s6
    de18:	ec46                	sd	a7,24(sp)
    de1a:	86a6                	mv	a3,s1
    de1c:	85ca                	mv	a1,s2
    de1e:	02000513          	li	a0,32
    de22:	9402                	jalr	s0
    de24:	68e2                	ld	a7,24(sp)
    de26:	0b05                	addi	s6,s6,1
    de28:	865a                	mv	a2,s6
    de2a:	ec46                	sd	a7,24(sp)
    de2c:	86a6                	mv	a3,s1
    de2e:	85ca                	mv	a1,s2
    de30:	02000513          	li	a0,32
    de34:	9402                	jalr	s0
    de36:	0b05                	addi	s6,s6,1
    de38:	016c8eb3          	add	t4,s9,s6
    de3c:	68e2                	ld	a7,24(sp)
    de3e:	098efd63          	bgeu	t4,s8,ded8 <_vsnprintf+0x5318>
    de42:	ec6e                	sd	s11,24(sp)
    de44:	f06a                	sd	s10,32(sp)
    de46:	8dd6                	mv	s11,s5
    de48:	8d46                	mv	s10,a7
    de4a:	865a                	mv	a2,s6
    de4c:	86a6                	mv	a3,s1
    de4e:	85ca                	mv	a1,s2
    de50:	02000513          	li	a0,32
    de54:	9402                	jalr	s0
    de56:	001b0b93          	addi	s7,s6,1
    de5a:	865e                	mv	a2,s7
    de5c:	86a6                	mv	a3,s1
    de5e:	85ca                	mv	a1,s2
    de60:	02000513          	li	a0,32
    de64:	9402                	jalr	s0
    de66:	002b0a93          	addi	s5,s6,2
    de6a:	8656                	mv	a2,s5
    de6c:	86a6                	mv	a3,s1
    de6e:	85ca                	mv	a1,s2
    de70:	02000513          	li	a0,32
    de74:	9402                	jalr	s0
    de76:	003b0b93          	addi	s7,s6,3
    de7a:	865e                	mv	a2,s7
    de7c:	86a6                	mv	a3,s1
    de7e:	85ca                	mv	a1,s2
    de80:	02000513          	li	a0,32
    de84:	9402                	jalr	s0
    de86:	004b0a93          	addi	s5,s6,4
    de8a:	8656                	mv	a2,s5
    de8c:	86a6                	mv	a3,s1
    de8e:	85ca                	mv	a1,s2
    de90:	02000513          	li	a0,32
    de94:	9402                	jalr	s0
    de96:	005b0b93          	addi	s7,s6,5
    de9a:	865e                	mv	a2,s7
    de9c:	86a6                	mv	a3,s1
    de9e:	85ca                	mv	a1,s2
    dea0:	02000513          	li	a0,32
    dea4:	9402                	jalr	s0
    dea6:	006b0a93          	addi	s5,s6,6
    deaa:	86a6                	mv	a3,s1
    deac:	8656                	mv	a2,s5
    deae:	85ca                	mv	a1,s2
    deb0:	02000513          	li	a0,32
    deb4:	9402                	jalr	s0
    deb6:	007b0b93          	addi	s7,s6,7
    deba:	86a6                	mv	a3,s1
    debc:	865e                	mv	a2,s7
    debe:	85ca                	mv	a1,s2
    dec0:	02000513          	li	a0,32
    dec4:	0b21                	addi	s6,s6,8
    dec6:	9402                	jalr	s0
    dec8:	016c88b3          	add	a7,s9,s6
    decc:	f788efe3          	bltu	a7,s8,de4a <_vsnprintf+0x528a>
    ded0:	88ea                	mv	a7,s10
    ded2:	8aee                	mv	s5,s11
    ded4:	6de2                	ld	s11,24(sp)
    ded6:	7d02                	ld	s10,32(sp)
    ded8:	6c82                	ld	s9,0(sp)
    deda:	fffc0e13          	addi	t3,s8,-1
    dede:	001d8593          	addi	a1,s11,1
    dee2:	41be02b3          	sub	t0,t3,s11
    dee6:	00bc3633          	sltu	a2,s8,a1
    deea:	42c0128b          	th.mvnez	t0,zero,a2
    deee:	001c8513          	addi	a0,s9,1
    def2:	03010813          	addi	a6,sp,48
    def6:	00a286b3          	add	a3,t0,a0
    defa:	000d8463          	beqz	s11,df02 <_vsnprintf+0x5342>
    defe:	cbbfd06f          	j	bbb8 <_vsnprintf+0x2ff8>
    df02:	8db6                	mv	s11,a3
    df04:	000d1463          	bnez	s10,df0c <_vsnprintf+0x534c>
    df08:	e1dfd06f          	j	bd24 <_vsnprintf+0x3164>
    df0c:	e2ffd06f          	j	bd3a <_vsnprintf+0x317a>
    df10:	8d46                	mv	s10,a7
    df12:	8a9a                	mv	s5,t1
    df14:	bc8fc06f          	j	a2dc <_vsnprintf+0x171c>
    df18:	00a77463          	bgeu	a4,a0,df20 <_vsnprintf+0x5360>
    df1c:	f1dfe06f          	j	ce38 <_vsnprintf+0x4278>
    df20:	000e9463          	bnez	t4,df28 <_vsnprintf+0x5368>
    df24:	05c0106f          	j	ef80 <_vsnprintf+0x63c0>
    df28:	da0b86e3          	beqz	s7,dcd4 <_vsnprintf+0x5114>
    df2c:	4d41                	li	s10,16
    df2e:	7ba68963          	beq	a3,s10,e6e0 <_vsnprintf+0x5b20>
    df32:	4e89                	li	t4,2
    df34:	01d69463          	bne	a3,t4,df3c <_vsnprintf+0x537c>
    df38:	0560106f          	j	ef8e <_vsnprintf+0x63ce>
    df3c:	02000693          	li	a3,32
    df40:	4d01                	li	s10,0
    df42:	a4d703e3          	beq	a4,a3,d988 <_vsnprintf+0x4dc8>
    df46:	002707b3          	add	a5,a4,sp
    df4a:	03000b93          	li	s7,48
    df4e:	00170f13          	addi	t5,a4,1
    df52:	03778823          	sb	s7,48(a5)
    df56:	02000f93          	li	t6,32
    df5a:	cdff08e3          	beq	t5,t6,dc2a <_vsnprintf+0x506a>
    df5e:	877a                	mv	a4,t5
    df60:	ab55                	j	e514 <_vsnprintf+0x5954>
    df62:	0001                	nop
    df64:	4b81                	li	s7,0
    df66:	47c1                	li	a5,16
    df68:	d26fd06f          	j	b48e <_vsnprintf+0x28ce>
    df6c:	4a0e4263          	bltz	t3,e410 <_vsnprintf+0x5850>
    df70:	0042fe13          	andi	t3,t0,4
    df74:	660e05e3          	beqz	t3,edde <_vsnprintf+0x621e>
    df78:	02078593          	addi	a1,a5,32
    df7c:	03010c93          	addi	s9,sp,48
    df80:	00178d13          	addi	s10,a5,1
    df84:	01958db3          	add	s11,a1,s9
    df88:	02b00693          	li	a3,43
    df8c:	fedd8023          	sb	a3,-32(s11)
    df90:	6382                	ld	t2,0(sp)
    df92:	8dc2                	mv	s11,a6
    df94:	8536                	mv	a0,a3
    df96:	4b09                	li	s6,2
    df98:	9ccfc06f          	j	a164 <_vsnprintf+0x15a4>
    df9c:	040d0b63          	beqz	s10,dff2 <_vsnprintf+0x5432>
    dfa0:	3c0b85e3          	beqz	s7,eb6a <_vsnprintf+0x5faa>
    dfa4:	4bc1                	li	s7,16
    dfa6:	3b768fe3          	beq	a3,s7,eb64 <_vsnprintf+0x5fa4>
    dfaa:	4509                	li	a0,2
    dfac:	4d01                	li	s10,0
    dfae:	d8a696e3          	bne	a3,a0,dd3a <_vsnprintf+0x517a>
    dfb2:	bb41                	j	dd42 <_vsnprintf+0x5182>
    dfb4:	ffed8313          	addi	t1,s11,-2
    dfb8:	02030c93          	addi	s9,t1,32
    dfbc:	03010e13          	addi	t3,sp,48
    dfc0:	02067e93          	andi	t4,a2,32
    dfc4:	1dfd                	addi	s11,s11,-1
    dfc6:	01cc82b3          	add	t0,s9,t3
    dfca:	4c0e96e3          	bnez	t4,ec96 <_vsnprintf+0x60d6>
    dfce:	07800d13          	li	s10,120
    dfd2:	ffa28023          	sb	s10,-32(t0)
    dfd6:	8d5e                	mv	s10,s7
    dfd8:	002d8eb3          	add	t4,s11,sp
    dfdc:	03000c93          	li	s9,48
    dfe0:	001d8793          	addi	a5,s11,1
    dfe4:	039e8823          	sb	s9,48(t4)
    dfe8:	02000e13          	li	t3,32
    dfec:	8dbe                	mv	s11,a5
    dfee:	09c79263          	bne	a5,t3,e072 <_vsnprintf+0x54b2>
    dff2:	00367593          	andi	a1,a2,3
    dff6:	c199                	beqz	a1,dffc <_vsnprintf+0x543c>
    dff8:	bbbfd06f          	j	bbb2 <_vsnprintf+0x2ff2>
    dffc:	02000d93          	li	s11,32
    e000:	7c08bc0b          	th.extu	s8,a7,31,0
    e004:	d51deee3          	bltu	s11,a7,dd60 <_vsnprintf+0x51a0>
    e008:	babfd06f          	j	bbb2 <_vsnprintf+0x2ff2>
    e00c:	040d0f63          	beqz	s10,e06a <_vsnprintf+0x54aa>
    e010:	4d01                	li	s10,0
    e012:	d00b9ee3          	bnez	s7,dd2e <_vsnprintf+0x516e>
    e016:	00ad8663          	beq	s11,a0,e022 <_vsnprintf+0x5462>
    e01a:	7c08bc0b          	th.extu	s8,a7,31,0
    e01e:	d18d98e3          	bne	s11,s8,dd2e <_vsnprintf+0x516e>
    e022:	fffd8e13          	addi	t3,s11,-1
    e026:	8bea                	mv	s7,s10
    e028:	020e1463          	bnez	t3,e050 <_vsnprintf+0x5490>
    e02c:	4dc1                	li	s11,16
    e02e:	3fb685e3          	beq	a3,s11,ec18 <_vsnprintf+0x6058>
    e032:	4b89                	li	s7,2
    e034:	597685e3          	beq	a3,s7,edbe <_vsnprintf+0x61fe>
    e038:	03000513          	li	a0,48
    e03c:	02a10823          	sb	a0,48(sp)
    e040:	8a0d                	andi	a2,a2,3
    e042:	560604e3          	beqz	a2,edaa <_vsnprintf+0x61ea>
    e046:	6682                	ld	a3,0(sp)
    e048:	4d85                	li	s11,1
    e04a:	b6ffd06f          	j	bbb8 <_vsnprintf+0x2ff8>
    e04e:	4e7d                	li	t3,31
    e050:	4b41                	li	s6,16
    e052:	f76681e3          	beq	a3,s6,dfb4 <_vsnprintf+0x53f4>
    e056:	4709                	li	a4,2
    e058:	40e68de3          	beq	a3,a4,ec72 <_vsnprintf+0x60b2>
    e05c:	002e0f33          	add	t5,t3,sp
    e060:	03000793          	li	a5,48
    e064:	02ff0823          	sb	a5,48(t5)
    e068:	8d5e                	mv	s10,s7
    e06a:	02000393          	li	t2,32
    e06e:	f87d82e3          	beq	s11,t2,dff2 <_vsnprintf+0x5432>
    e072:	00367293          	andi	t0,a2,3
    e076:	00029663          	bnez	t0,e082 <_vsnprintf+0x54c2>
    e07a:	7c08bc0b          	th.extu	s8,a7,31,0
    e07e:	cf8de1e3          	bltu	s11,s8,dd60 <_vsnprintf+0x51a0>
    e082:	6682                	ld	a3,0(sp)
    e084:	b35fd06f          	j	bbb8 <_vsnprintf+0x2ff8>
    e088:	4e0edc63          	bgez	t4,e580 <_vsnprintf+0x59c0>
    e08c:	7c0c3c0b          	th.extu	s8,s8,31,0
    e090:	38fd                	addiw	a7,a7,-1
    e092:	0187f463          	bgeu	a5,s8,e09a <_vsnprintf+0x54da>
    e096:	e33fd06f          	j	bec8 <_vsnprintf+0x3308>
    e09a:	7c08b68b          	th.extu	a3,a7,31,0
    e09e:	00d7f463          	bgeu	a5,a3,e0a6 <_vsnprintf+0x54e6>
    e0a2:	f25fd06f          	j	bfc6 <_vsnprintf+0x3406>
    e0a6:	02000293          	li	t0,32
    e0aa:	00579463          	bne	a5,t0,e0b2 <_vsnprintf+0x54f2>
    e0ae:	9a0fe06f          	j	c24e <_vsnprintf+0x368e>
    e0b2:	86be                	mv	a3,a5
    e0b4:	810fe06f          	j	c0c4 <_vsnprintf+0x3504>
    e0b8:	7c0c3d0b          	th.extu	s10,s8,31,0
    e0bc:	65a7f8e3          	bgeu	a5,s10,ef0c <_vsnprintf+0x634c>
    e0c0:	0015fd93          	andi	s11,a1,1
    e0c4:	4881                	li	a7,0
    e0c6:	824fd06f          	j	b0ea <_vsnprintf+0x252a>
    e0ca:	560d1463          	bnez	s10,e632 <_vsnprintf+0x5a72>
    e0ce:	02000c13          	li	s8,32
    e0d2:	c58d8363          	beq	s11,s8,d518 <_vsnprintf+0x4958>
    e0d6:	8a0d                	andi	a2,a2,3
    e0d8:	f64d                	bnez	a2,e082 <_vsnprintf+0x54c2>
    e0da:	8c2a                	mv	s8,a0
    e0dc:	c8ade2e3          	bltu	s11,a0,dd60 <_vsnprintf+0x51a0>
    e0e0:	6682                	ld	a3,0(sp)
    e0e2:	ad7fd06f          	j	bbb8 <_vsnprintf+0x2ff8>
    e0e6:	0001                	nop
    e0e8:	3e088463          	beqz	a7,e4d0 <_vsnprintf+0x5910>
    e0ec:	001f7b13          	andi	s6,t5,1
    e0f0:	7c0c350b          	th.extu	a0,s8,31,0
    e0f4:	03010813          	addi	a6,sp,48
    e0f8:	6a0b0063          	beqz	s6,e798 <_vsnprintf+0x5bd8>
    e0fc:	7c08b78b          	th.extu	a5,a7,31,0
    e100:	c119                	beqz	a0,e106 <_vsnprintf+0x5546>
    e102:	d37fe06f          	j	ce38 <_vsnprintf+0x4278>
    e106:	e29fe06f          	j	cf2e <_vsnprintf+0x436e>
    e10a:	0001                	nop
    e10c:	7c0c3c0b          	th.extu	s8,s8,31,0
    e110:	0187f463          	bgeu	a5,s8,e118 <_vsnprintf+0x5558>
    e114:	c42fe06f          	j	c556 <_vsnprintf+0x3996>
    e118:	02000513          	li	a0,32
    e11c:	9aa78763          	beq	a5,a0,d2ca <_vsnprintf+0x470a>
    e120:	060e5863          	bgez	t3,e190 <_vsnprintf+0x55d0>
    e124:	00a78633          	add	a2,a5,a0
    e128:	03010c93          	addi	s9,sp,48
    e12c:	01960733          	add	a4,a2,s9
    e130:	02d00a93          	li	s5,45
    e134:	00178c13          	addi	s8,a5,1
    e138:	ff570023          	sb	s5,-32(a4)
    e13c:	e20fe06f          	j	c75c <_vsnprintf+0x3b9c>
    e140:	002783b3          	add	t2,a5,sp
    e144:	02d00513          	li	a0,45
    e148:	02a38823          	sb	a0,48(t2)
    e14c:	6302                	ld	t1,0(sp)
    e14e:	00178c13          	addi	s8,a5,1
    e152:	4b09                	li	s6,2
    e154:	af3fc06f          	j	ac46 <_vsnprintf+0x2086>
    e158:	004af593          	andi	a1,s5,4
    e15c:	02b00513          	li	a0,43
    e160:	e599                	bnez	a1,e16e <_vsnprintf+0x55ae>
    e162:	008afc93          	andi	s9,s5,8
    e166:	780c8263          	beqz	s9,e8ea <_vsnprintf+0x5d2a>
    e16a:	02000513          	li	a0,32
    e16e:	8dc2                	mv	s11,a6
    e170:	02a10823          	sb	a0,48(sp)
    e174:	6802                	ld	a6,0(sp)
    e176:	4c05                	li	s8,1
    e178:	4b09                	li	s6,2
    e17a:	03010c93          	addi	s9,sp,48
    e17e:	8dcfe06f          	j	c25a <_vsnprintf+0x369a>
    e182:	7c0c3c0b          	th.extu	s8,s8,31,0
    e186:	4781                	li	a5,0
    e188:	03010b93          	addi	s7,sp,48
    e18c:	980c1363          	bnez	s8,d312 <_vsnprintf+0x4752>
    e190:	0045fb13          	andi	s6,a1,4
    e194:	8bae                	mv	s7,a1
    e196:	100b07e3          	beqz	s6,eaa4 <_vsnprintf+0x5ee4>
    e19a:	02078393          	addi	t2,a5,32
    e19e:	03010f13          	addi	t5,sp,48
    e1a2:	01e38b33          	add	s6,t2,t5
    e1a6:	02b00513          	li	a0,43
    e1aa:	feab0023          	sb	a0,-32(s6)
    e1ae:	0035f313          	andi	t1,a1,3
    e1b2:	00178c13          	addi	s8,a5,1
    e1b6:	00031463          	bnez	t1,e1be <_vsnprintf+0x55fe>
    e1ba:	f49fe06f          	j	d102 <_vsnprintf+0x4542>
    e1be:	6302                	ld	t1,0(sp)
    e1c0:	4b01                	li	s6,0
    e1c2:	8bfa                	mv	s7,t5
    e1c4:	a83fc06f          	j	ac46 <_vsnprintf+0x2086>
    e1c8:	4d01                	li	s10,0
    e1ca:	02067c93          	andi	s9,a2,32
    e1ce:	7c0c8163          	beqz	s9,e990 <_vsnprintf+0x5dd0>
    e1d2:	02000e13          	li	t3,32
    e1d6:	b7cd86e3          	beq	s11,t3,dd42 <_vsnprintf+0x5182>
    e1da:	020d8293          	addi	t0,s11,32
    e1de:	180c                	addi	a1,sp,48
    e1e0:	00b28bb3          	add	s7,t0,a1
    e1e4:	05800513          	li	a0,88
    e1e8:	feab8023          	sb	a0,-32(s7)
    e1ec:	0d85                	addi	s11,s11,1
    e1ee:	b6b1                	j	dd3a <_vsnprintf+0x517a>
    e1f0:	86be                	mv	a3,a5
    e1f2:	ebffd06f          	j	c0b0 <_vsnprintf+0x34f0>
    e1f6:	e119                	bnez	a0,e1fc <_vsnprintf+0x563c>
    e1f8:	aa0fc06f          	j	a498 <_vsnprintf+0x18d8>
    e1fc:	6c82                	ld	s9,0(sp)
    e1fe:	2b85                	addiw	s7,s7,1
    e200:	4a81                	li	s5,0
    e202:	f81fa06f          	j	9182 <_vsnprintf+0x5c2>
    e206:	b00b89e3          	beqz	s7,dd18 <_vsnprintf+0x5158>
    e20a:	4c41                	li	s8,16
    e20c:	f7868963          	beq	a3,s8,d97e <_vsnprintf+0x4dbe>
    e210:	4589                	li	a1,2
    e212:	f6b69263          	bne	a3,a1,d976 <_vsnprintf+0x4db6>
    e216:	f68ff06f          	j	d97e <_vsnprintf+0x4dbe>
    e21a:	000b8463          	beqz	s7,e222 <_vsnprintf+0x5662>
    e21e:	9fafd06f          	j	b418 <_vsnprintf+0x2858>
    e222:	0045f293          	andi	t0,a1,4
    e226:	00028463          	beqz	t0,e22e <_vsnprintf+0x566e>
    e22a:	e37fc06f          	j	b060 <_vsnprintf+0x24a0>
    e22e:	0085fb93          	andi	s7,a1,8
    e232:	000b8463          	beqz	s7,e23a <_vsnprintf+0x567a>
    e236:	a56fd06f          	j	b48c <_vsnprintf+0x28cc>
    e23a:	8d3e                	mv	s10,a5
    e23c:	180c                	addi	a1,sp,48
    e23e:	02078793          	addi	a5,a5,32
    e242:	00b78fb3          	add	t6,a5,a1
    e246:	fdffc503          	lbu	a0,-33(t6)
    e24a:	e72fc06f          	j	a8bc <_vsnprintf+0x1cfc>
    e24e:	680e9563          	bnez	t4,e8d8 <_vsnprintf+0x5d18>
    e252:	4b81                	li	s7,0
    e254:	00367713          	andi	a4,a2,3
    e258:	5a071e63          	bnez	a4,e814 <_vsnprintf+0x5c54>
    e25c:	02000d13          	li	s10,32
    e260:	7c08bc0b          	th.extu	s8,a7,31,0
    e264:	5b1d7863          	bgeu	s10,a7,e814 <_vsnprintf+0x5c54>
    e268:	6602                	ld	a2,0(sp)
    e26a:	ec46                	sd	a7,24(sp)
    e26c:	86a6                	mv	a3,s1
    e26e:	40cd0b33          	sub	s6,s10,a2
    e272:	fffb4e93          	not	t4,s6
    e276:	018e8833          	add	a6,t4,s8
    e27a:	85ca                	mv	a1,s2
    e27c:	02000513          	li	a0,32
    e280:	40c80cb3          	sub	s9,a6,a2
    e284:	00160d93          	addi	s11,a2,1
    e288:	9402                	jalr	s0
    e28a:	01bb0333          	add	t1,s6,s11
    e28e:	68e2                	ld	a7,24(sp)
    e290:	007cfc93          	andi	s9,s9,7
    e294:	15837363          	bgeu	t1,s8,e3da <_vsnprintf+0x581a>
    e298:	0a0c8863          	beqz	s9,e348 <_vsnprintf+0x5788>
    e29c:	4685                	li	a3,1
    e29e:	08dc8863          	beq	s9,a3,e32e <_vsnprintf+0x576e>
    e2a2:	4e09                	li	t3,2
    e2a4:	07cc8c63          	beq	s9,t3,e31c <_vsnprintf+0x575c>
    e2a8:	428d                	li	t0,3
    e2aa:	065c8063          	beq	s9,t0,e30a <_vsnprintf+0x574a>
    e2ae:	4f91                	li	t6,4
    e2b0:	05fc8463          	beq	s9,t6,e2f8 <_vsnprintf+0x5738>
    e2b4:	4f15                	li	t5,5
    e2b6:	03ec8863          	beq	s9,t5,e2e6 <_vsnprintf+0x5726>
    e2ba:	4519                	li	a0,6
    e2bc:	00ac8c63          	beq	s9,a0,e2d4 <_vsnprintf+0x5714>
    e2c0:	866e                	mv	a2,s11
    e2c2:	ec46                	sd	a7,24(sp)
    e2c4:	86a6                	mv	a3,s1
    e2c6:	85ca                	mv	a1,s2
    e2c8:	02000513          	li	a0,32
    e2cc:	6d82                	ld	s11,0(sp)
    e2ce:	9402                	jalr	s0
    e2d0:	68e2                	ld	a7,24(sp)
    e2d2:	0d89                	addi	s11,s11,2
    e2d4:	866e                	mv	a2,s11
    e2d6:	ec46                	sd	a7,24(sp)
    e2d8:	86a6                	mv	a3,s1
    e2da:	85ca                	mv	a1,s2
    e2dc:	02000513          	li	a0,32
    e2e0:	9402                	jalr	s0
    e2e2:	68e2                	ld	a7,24(sp)
    e2e4:	0d85                	addi	s11,s11,1
    e2e6:	866e                	mv	a2,s11
    e2e8:	ec46                	sd	a7,24(sp)
    e2ea:	86a6                	mv	a3,s1
    e2ec:	85ca                	mv	a1,s2
    e2ee:	02000513          	li	a0,32
    e2f2:	9402                	jalr	s0
    e2f4:	68e2                	ld	a7,24(sp)
    e2f6:	0d85                	addi	s11,s11,1
    e2f8:	866e                	mv	a2,s11
    e2fa:	ec46                	sd	a7,24(sp)
    e2fc:	86a6                	mv	a3,s1
    e2fe:	85ca                	mv	a1,s2
    e300:	02000513          	li	a0,32
    e304:	9402                	jalr	s0
    e306:	68e2                	ld	a7,24(sp)
    e308:	0d85                	addi	s11,s11,1
    e30a:	866e                	mv	a2,s11
    e30c:	ec46                	sd	a7,24(sp)
    e30e:	86a6                	mv	a3,s1
    e310:	85ca                	mv	a1,s2
    e312:	02000513          	li	a0,32
    e316:	9402                	jalr	s0
    e318:	68e2                	ld	a7,24(sp)
    e31a:	0d85                	addi	s11,s11,1
    e31c:	866e                	mv	a2,s11
    e31e:	ec46                	sd	a7,24(sp)
    e320:	86a6                	mv	a3,s1
    e322:	85ca                	mv	a1,s2
    e324:	02000513          	li	a0,32
    e328:	9402                	jalr	s0
    e32a:	68e2                	ld	a7,24(sp)
    e32c:	0d85                	addi	s11,s11,1
    e32e:	866e                	mv	a2,s11
    e330:	ec46                	sd	a7,24(sp)
    e332:	86a6                	mv	a3,s1
    e334:	85ca                	mv	a1,s2
    e336:	02000513          	li	a0,32
    e33a:	9402                	jalr	s0
    e33c:	0d85                	addi	s11,s11,1
    e33e:	01bb07b3          	add	a5,s6,s11
    e342:	68e2                	ld	a7,24(sp)
    e344:	0987fb63          	bgeu	a5,s8,e3da <_vsnprintf+0x581a>
    e348:	ec56                	sd	s5,24(sp)
    e34a:	f05e                	sd	s7,32(sp)
    e34c:	8bc6                	mv	s7,a7
    e34e:	866e                	mv	a2,s11
    e350:	86a6                	mv	a3,s1
    e352:	85ca                	mv	a1,s2
    e354:	02000513          	li	a0,32
    e358:	9402                	jalr	s0
    e35a:	001d8c93          	addi	s9,s11,1
    e35e:	8666                	mv	a2,s9
    e360:	86a6                	mv	a3,s1
    e362:	85ca                	mv	a1,s2
    e364:	02000513          	li	a0,32
    e368:	9402                	jalr	s0
    e36a:	002d8a93          	addi	s5,s11,2
    e36e:	8656                	mv	a2,s5
    e370:	86a6                	mv	a3,s1
    e372:	85ca                	mv	a1,s2
    e374:	02000513          	li	a0,32
    e378:	9402                	jalr	s0
    e37a:	003d8c93          	addi	s9,s11,3
    e37e:	8666                	mv	a2,s9
    e380:	86a6                	mv	a3,s1
    e382:	85ca                	mv	a1,s2
    e384:	02000513          	li	a0,32
    e388:	9402                	jalr	s0
    e38a:	004d8a93          	addi	s5,s11,4
    e38e:	8656                	mv	a2,s5
    e390:	86a6                	mv	a3,s1
    e392:	85ca                	mv	a1,s2
    e394:	02000513          	li	a0,32
    e398:	9402                	jalr	s0
    e39a:	005d8c93          	addi	s9,s11,5
    e39e:	8666                	mv	a2,s9
    e3a0:	86a6                	mv	a3,s1
    e3a2:	85ca                	mv	a1,s2
    e3a4:	02000513          	li	a0,32
    e3a8:	9402                	jalr	s0
    e3aa:	006d8a93          	addi	s5,s11,6
    e3ae:	86a6                	mv	a3,s1
    e3b0:	8656                	mv	a2,s5
    e3b2:	85ca                	mv	a1,s2
    e3b4:	02000513          	li	a0,32
    e3b8:	9402                	jalr	s0
    e3ba:	007d8c93          	addi	s9,s11,7
    e3be:	86a6                	mv	a3,s1
    e3c0:	8666                	mv	a2,s9
    e3c2:	85ca                	mv	a1,s2
    e3c4:	02000513          	li	a0,32
    e3c8:	0da1                	addi	s11,s11,8
    e3ca:	9402                	jalr	s0
    e3cc:	01bb08b3          	add	a7,s6,s11
    e3d0:	f788efe3          	bltu	a7,s8,e34e <_vsnprintf+0x578e>
    e3d4:	88de                	mv	a7,s7
    e3d6:	6ae2                	ld	s5,24(sp)
    e3d8:	7b82                	ld	s7,32(sp)
    e3da:	6602                	ld	a2,0(sp)
    e3dc:	fffc0393          	addi	t2,s8,-1
    e3e0:	001d0593          	addi	a1,s10,1
    e3e4:	41a387b3          	sub	a5,t2,s10
    e3e8:	00bc3733          	sltu	a4,s8,a1
    e3ec:	42e0178b          	th.mvnez	a5,zero,a4
    e3f0:	00160e93          	addi	t4,a2,1
    e3f4:	03010b13          	addi	s6,sp,48
    e3f8:	01d783b3          	add	t2,a5,t4
    e3fc:	000d0463          	beqz	s10,e404 <_vsnprintf+0x5844>
    e400:	d5cfe06f          	j	c95c <_vsnprintf+0x3d9c>
    e404:	000b9463          	bnez	s7,e40c <_vsnprintf+0x584c>
    e408:	ea6fe06f          	j	caae <_vsnprintf+0x3eee>
    e40c:	eb8fe06f          	j	cac4 <_vsnprintf+0x3f04>
    e410:	02078b93          	addi	s7,a5,32
    e414:	03010f93          	addi	t6,sp,48
    e418:	00178d13          	addi	s10,a5,1
    e41c:	01fb8db3          	add	s11,s7,t6
    e420:	02d00693          	li	a3,45
    e424:	b6a5                	j	df8c <_vsnprintf+0x53cc>
    e426:	000b9463          	bnez	s7,e42e <_vsnprintf+0x586e>
    e42a:	c8afc06f          	j	a8b4 <_vsnprintf+0x1cf4>
    e42e:	4b81                	li	s7,0
    e430:	000c8463          	beqz	s9,e438 <_vsnprintf+0x5878>
    e434:	c80fc06f          	j	a8b4 <_vsnprintf+0x1cf4>
    e438:	4b81                	li	s7,0
    e43a:	01af8463          	beq	t6,s10,e442 <_vsnprintf+0x5882>
    e43e:	cc4fe06f          	j	c902 <_vsnprintf+0x3d42>
    e442:	fffd0793          	addi	a5,s10,-1
    e446:	4b81                	li	s7,0
    e448:	020d0f13          	addi	t5,s10,32
    e44c:	03010893          	addi	a7,sp,48
    e450:	05800313          	li	t1,88
    e454:	011f0533          	add	a0,t5,a7
    e458:	fc650f23          	sb	t1,-34(a0)
    e45c:	ff1fc06f          	j	b44c <_vsnprintf+0x288c>
    e460:	36088a63          	beqz	a7,e7d4 <_vsnprintf+0x5c14>
    e464:	001ffb13          	andi	s6,t6,1
    e468:	7c0c350b          	th.extu	a0,s8,31,0
    e46c:	03010813          	addi	a6,sp,48
    e470:	340b0263          	beqz	s6,e7b4 <_vsnprintf+0x5bf4>
    e474:	c119                	beqz	a0,e47a <_vsnprintf+0x58ba>
    e476:	ebffe06f          	j	d334 <_vsnprintf+0x4774>
    e47a:	7c08b50b          	th.extu	a0,a7,31,0
    e47e:	fa9fe06f          	j	d426 <_vsnprintf+0x4866>
    e482:	0001                	nop
    e484:	ac0c1163          	bnez	s8,d746 <_vsnprintf+0x4b86>
    e488:	0045fb13          	andi	s6,a1,4
    e48c:	8cae                	mv	s9,a1
    e48e:	020b01e3          	beqz	s6,ecb0 <_vsnprintf+0x60f0>
    e492:	02078d93          	addi	s11,a5,32
    e496:	03010293          	addi	t0,sp,48
    e49a:	005d8b33          	add	s6,s11,t0
    e49e:	02b00513          	li	a0,43
    e4a2:	feab0023          	sb	a0,-32(s6)
    e4a6:	0035f313          	andi	t1,a1,3
    e4aa:	00178c13          	addi	s8,a5,1
    e4ae:	7e031b63          	bnez	t1,eca4 <_vsnprintf+0x60e4>
    e4b2:	7c08bb8b          	th.extu	s7,a7,31,0
    e4b6:	8dc2                	mv	s11,a6
    e4b8:	4b01                	li	s6,0
    e4ba:	017c7463          	bgeu	s8,s7,e4c2 <_vsnprintf+0x5902>
    e4be:	fb6fe06f          	j	cc74 <_vsnprintf+0x40b4>
    e4c2:	6802                	ld	a6,0(sp)
    e4c4:	02b00513          	li	a0,43
    e4c8:	03010c93          	addi	s9,sp,48
    e4cc:	d8ffd06f          	j	c25a <_vsnprintf+0x369a>
    e4d0:	7c0c350b          	th.extu	a0,s8,31,0
    e4d4:	03010813          	addi	a6,sp,48
    e4d8:	ea051963          	bnez	a0,db8a <_vsnprintf+0x4fca>
    e4dc:	003f7693          	andi	a3,t5,3
    e4e0:	6e02                	ld	t3,0(sp)
    e4e2:	e299                	bnez	a3,e4e8 <_vsnprintf+0x5928>
    e4e4:	f99fb06f          	j	a47c <_vsnprintf+0x18bc>
    e4e8:	6e02                	ld	t3,0(sp)
    e4ea:	e072                	sd	t3,0(sp)
    e4ec:	fadfb06f          	j	a498 <_vsnprintf+0x18d8>
    e4f0:	00278bb3          	add	s7,a5,sp
    e4f4:	02d00513          	li	a0,45
    e4f8:	02ab8823          	sb	a0,48(s7)
    e4fc:	8dc2                	mv	s11,a6
    e4fe:	00178c13          	addi	s8,a5,1
    e502:	6802                	ld	a6,0(sp)
    e504:	4b09                	li	s6,2
    e506:	d55fd06f          	j	c25a <_vsnprintf+0x369a>
    e50a:	4d01                	li	s10,0
    e50c:	02000b93          	li	s7,32
    e510:	f1770d63          	beq	a4,s7,dc2a <_vsnprintf+0x506a>
    e514:	003e7593          	andi	a1,t3,3
    e518:	c199                	beqz	a1,e51e <_vsnprintf+0x595e>
    e51a:	b19fe06f          	j	d032 <_vsnprintf+0x4472>
    e51e:	7c08bc0b          	th.extu	s8,a7,31,0
    e522:	c7876b63          	bltu	a4,s8,d998 <_vsnprintf+0x4dd8>
    e526:	6e02                	ld	t3,0(sp)
    e528:	946fd06f          	j	b66e <_vsnprintf+0x2aae>
    e52c:	00857693          	andi	a3,a0,8
    e530:	4b89                	li	s7,2
    e532:	38069f63          	bnez	a3,e8d0 <_vsnprintf+0x5d10>
    e536:	05210f93          	addi	t6,sp,82
    e53a:	8d5e                	mv	s10,s7
    e53c:	4ac1                	li	s5,16
    e53e:	fdffc503          	lbu	a0,-33(t6)
    e542:	b7afc06f          	j	a8bc <_vsnprintf+0x1cfc>
    e546:	6682                	ld	a3,0(sp)
    e548:	4d09                	li	s10,2
    e54a:	e6efd06f          	j	bbb8 <_vsnprintf+0x2ff8>
    e54e:	7c0c3d0b          	th.extu	s10,s8,31,0
    e552:	01a7f463          	bgeu	a5,s10,e55a <_vsnprintf+0x599a>
    e556:	b95fc06f          	j	b0ea <_vsnprintf+0x252a>
    e55a:	02000f13          	li	t5,32
    e55e:	93e78863          	beq	a5,t5,d68e <_vsnprintf+0x4ace>
    e562:	1e0e5063          	bgez	t3,e742 <_vsnprintf+0x5b82>
    e566:	01e78ab3          	add	s5,a5,t5
    e56a:	1810                	addi	a2,sp,48
    e56c:	00178d13          	addi	s10,a5,1
    e570:	02d00713          	li	a4,45
    e574:	00ca87b3          	add	a5,s5,a2
    e578:	fee78023          	sb	a4,-32(a5)
    e57c:	c99fc06f          	j	b214 <_vsnprintf+0x2654>
    e580:	00c6ff13          	andi	t5,a3,12
    e584:	7c0c3c0b          	th.extu	s8,s8,31,0
    e588:	fff8869b          	addiw	a3,a7,-1
    e58c:	43e6988b          	th.mvnez	a7,a3,t5
    e590:	0187f463          	bgeu	a5,s8,e598 <_vsnprintf+0x59d8>
    e594:	935fd06f          	j	bec8 <_vsnprintf+0x3308>
    e598:	7c08b68b          	th.extu	a3,a7,31,0
    e59c:	00d7f463          	bgeu	a5,a3,e5a4 <_vsnprintf+0x59e4>
    e5a0:	a27fd06f          	j	bfc6 <_vsnprintf+0x3406>
    e5a4:	02000e93          	li	t4,32
    e5a8:	01d79463          	bne	a5,t4,e5b0 <_vsnprintf+0x59f0>
    e5ac:	ca3fd06f          	j	c24e <_vsnprintf+0x368e>
    e5b0:	bde1                	j	e488 <_vsnprintf+0x58c8>
    e5b2:	0001                	nop
    e5b4:	6e02                	ld	t3,0(sp)
    e5b6:	4d09                	li	s10,2
    e5b8:	8b6fd06f          	j	b66e <_vsnprintf+0x2aae>
    e5bc:	4781                	li	a5,0
    e5be:	00c5fb93          	andi	s7,a1,12
    e5c2:	fff8829b          	addiw	t0,a7,-1
    e5c6:	7c0c3c0b          	th.extu	s8,s8,31,0
    e5ca:	4372988b          	th.mvnez	a7,t0,s7
    e5ce:	4f85                	li	t6,1
    e5d0:	03010b93          	addi	s7,sp,48
    e5d4:	0187f463          	bgeu	a5,s8,e5dc <_vsnprintf+0x5a1c>
    e5d8:	f7ffd06f          	j	c556 <_vsnprintf+0x3996>
    e5dc:	7c08bf8b          	th.extu	t6,a7,31,0
    e5e0:	01f7f463          	bgeu	a5,t6,e5e8 <_vsnprintf+0x5a28>
    e5e4:	868fe06f          	j	c64c <_vsnprintf+0x3a8c>
    e5e8:	02000c13          	li	s8,32
    e5ec:	01879463          	bne	a5,s8,e5f4 <_vsnprintf+0x5a34>
    e5f0:	d0dfe06f          	j	d2fc <_vsnprintf+0x473c>
    e5f4:	be71                	j	e190 <_vsnprintf+0x55d0>
    e5f6:	0001                	nop
    e5f8:	4809                	li	a6,2
    e5fa:	400b8763          	beqz	s7,ea08 <_vsnprintf+0x5e48>
    e5fe:	4cc1                	li	s9,16
    e600:	3d968363          	beq	a3,s9,e9c6 <_vsnprintf+0x5e06>
    e604:	4309                	li	t1,2
    e606:	3e668563          	beq	a3,t1,e9f0 <_vsnprintf+0x5e30>
    e60a:	02000e93          	li	t4,32
    e60e:	25dd1863          	bne	s10,t4,e85e <_vsnprintf+0x5c9e>
    e612:	00367d13          	andi	s10,a2,3
    e616:	000d0463          	beqz	s10,e61e <_vsnprintf+0x5a5e>
    e61a:	b3afe06f          	j	c954 <_vsnprintf+0x3d94>
    e61e:	02000d13          	li	s10,32
    e622:	011d6463          	bltu	s10,a7,e62a <_vsnprintf+0x5a6a>
    e626:	b2efe06f          	j	c954 <_vsnprintf+0x3d94>
    e62a:	7c08bc0b          	th.extu	s8,a7,31,0
    e62e:	8bc2                	mv	s7,a6
    e630:	b925                	j	e268 <_vsnprintf+0x56a8>
    e632:	4d01                	li	s10,0
    e634:	ef2ff06f          	j	dd26 <_vsnprintf+0x5166>
    e638:	26088a63          	beqz	a7,e8ac <_vsnprintf+0x5cec>
    e63c:	001ffc93          	andi	s9,t6,1
    e640:	7c0c370b          	th.extu	a4,s8,31,0
    e644:	03010b13          	addi	s6,sp,48
    e648:	4a0c8e63          	beqz	s9,eb04 <_vsnprintf+0x5f44>
    e64c:	7c08b78b          	th.extu	a5,a7,31,0
    e650:	90071c63          	bnez	a4,d768 <_vsnprintf+0x4ba8>
    e654:	a0aff06f          	j	d85e <_vsnprintf+0x4c9e>
    e658:	00adf463          	bgeu	s11,a0,e660 <_vsnprintf+0x5aa0>
    e65c:	cd9fe06f          	j	d334 <_vsnprintf+0x4774>
    e660:	560d0b63          	beqz	s10,ebd6 <_vsnprintf+0x6016>
    e664:	540b9c63          	bnez	s7,ebbc <_vsnprintf+0x5ffc>
    e668:	4d01                	li	s10,0
    e66a:	b275                	j	e016 <_vsnprintf+0x5456>
    e66c:	8bea                	mv	s7,s10
    e66e:	7c0c350b          	th.extu	a0,s8,31,0
    e672:	e62ff06f          	j	dcd4 <_vsnprintf+0x5114>
    e676:	1a0e8263          	beqz	t4,e81a <_vsnprintf+0x5c5a>
    e67a:	040b9263          	bnez	s7,e6be <_vsnprintf+0x5afe>
    e67e:	01a70763          	beq	a4,s10,e68c <_vsnprintf+0x5acc>
    e682:	7c08be8b          	th.extu	t4,a7,31,0
    e686:	885e                	mv	a6,s7
    e688:	f7ae9be3          	bne	t4,s10,e5fe <_vsnprintf+0x5a3e>
    e68c:	fffd0593          	addi	a1,s10,-1
    e690:	4a059d63          	bnez	a1,eb4a <_vsnprintf+0x5f8a>
    e694:	4841                	li	a6,16
    e696:	4f068963          	beq	a3,a6,eb88 <_vsnprintf+0x5fc8>
    e69a:	4d09                	li	s10,2
    e69c:	51a68463          	beq	a3,s10,eba4 <_vsnprintf+0x5fe4>
    e6a0:	03000713          	li	a4,48
    e6a4:	02e10823          	sb	a4,48(sp)
    e6a8:	8a0d                	andi	a2,a2,3
    e6aa:	4c060763          	beqz	a2,eb78 <_vsnprintf+0x5fb8>
    e6ae:	6382                	ld	t2,0(sp)
    e6b0:	4d05                	li	s10,1
    e6b2:	aaafe06f          	j	c95c <_vsnprintf+0x3d9c>
    e6b6:	49ac0963          	beq	s8,s10,eb48 <_vsnprintf+0x5f88>
    e6ba:	49a88763          	beq	a7,s10,eb48 <_vsnprintf+0x5f88>
    e6be:	4801                	li	a6,0
    e6c0:	bf3d                	j	e5fe <_vsnprintf+0x5a3e>
    e6c2:	02000313          	li	t1,32
    e6c6:	aa670c63          	beq	a4,t1,d97e <_vsnprintf+0x4dbe>
    e6ca:	00e80633          	add	a2,a6,a4
    e6ce:	8bea                	mv	s7,s10
    e6d0:	0705                	addi	a4,a4,1
    e6d2:	06200f93          	li	t6,98
    e6d6:	01f60023          	sb	t6,0(a2)
    e6da:	8d5e                	mv	s10,s7
    e6dc:	a9aff06f          	j	d976 <_vsnprintf+0x4db6>
    e6e0:	4d01                	li	s10,0
    e6e2:	020e7c93          	andi	s9,t3,32
    e6e6:	180c8b63          	beqz	s9,e87c <_vsnprintf+0x5cbc>
    e6ea:	02000293          	li	t0,32
    e6ee:	a8570863          	beq	a4,t0,d97e <_vsnprintf+0x4dbe>
    e6f2:	02070393          	addi	t2,a4,32
    e6f6:	03010f13          	addi	t5,sp,48
    e6fa:	01e38bb3          	add	s7,t2,t5
    e6fe:	05800693          	li	a3,88
    e702:	fedb8023          	sb	a3,-32(s7)
    e706:	0705                	addi	a4,a4,1
    e708:	a6eff06f          	j	d976 <_vsnprintf+0x4db6>
    e70c:	7c0c370b          	th.extu	a4,s8,31,0
    e710:	52ed7363          	bgeu	s10,a4,ec36 <_vsnprintf+0x6076>
    e714:	00167c93          	andi	s9,a2,1
    e718:	850ff06f          	j	d768 <_vsnprintf+0x4ba8>
    e71c:	004af313          	andi	t1,s5,4
    e720:	06030663          	beqz	t1,e78c <_vsnprintf+0x5bcc>
    e724:	02b00693          	li	a3,43
    e728:	6382                	ld	t2,0(sp)
    e72a:	02d10823          	sb	a3,48(sp)
    e72e:	8dc2                	mv	s11,a6
    e730:	8536                	mv	a0,a3
    e732:	4d05                	li	s10,1
    e734:	4b09                	li	s6,2
    e736:	03010313          	addi	t1,sp,48
    e73a:	a2bfb06f          	j	a164 <_vsnprintf+0x15a4>
    e73e:	980d11e3          	bnez	s10,e0c0 <_vsnprintf+0x5500>
    e742:	0045fb13          	andi	s6,a1,4
    e746:	832e                	mv	t1,a1
    e748:	5e0b0763          	beqz	s6,ed36 <_vsnprintf+0x6176>
    e74c:	02078d93          	addi	s11,a5,32
    e750:	03010b13          	addi	s6,sp,48
    e754:	016d8fb3          	add	t6,s11,s6
    e758:	02b00393          	li	t2,43
    e75c:	fe7f8023          	sb	t2,-32(t6)
    e760:	0035f713          	andi	a4,a1,3
    e764:	00178d13          	addi	s10,a5,1
    e768:	5a071f63          	bnez	a4,ed26 <_vsnprintf+0x6166>
    e76c:	7c08bb8b          	th.extu	s7,a7,31,0
    e770:	8dc2                	mv	s11,a6
    e772:	4b01                	li	s6,0
    e774:	017d7463          	bgeu	s10,s7,e77c <_vsnprintf+0x5bbc>
    e778:	aadfc06f          	j	b224 <_vsnprintf+0x2664>
    e77c:	6382                	ld	t2,0(sp)
    e77e:	02b00513          	li	a0,43
    e782:	03010313          	addi	t1,sp,48
    e786:	9dffb06f          	j	a164 <_vsnprintf+0x15a4>
    e78a:	0001                	nop
    e78c:	008af593          	andi	a1,s5,8
    e790:	cdb5                	beqz	a1,e80c <_vsnprintf+0x5c4c>
    e792:	02000693          	li	a3,32
    e796:	bf49                	j	e728 <_vsnprintf+0x5b68>
    e798:	c119                	beqz	a0,e79e <_vsnprintf+0x5bde>
    e79a:	e9efe06f          	j	ce38 <_vsnprintf+0x4278>
    e79e:	7c08bc0b          	th.extu	s8,a7,31,0
    e7a2:	9f876b63          	bltu	a4,s8,d998 <_vsnprintf+0x4dd8>
    e7a6:	d40701e3          	beqz	a4,e4e8 <_vsnprintf+0x5928>
    e7aa:	6e02                	ld	t3,0(sp)
    e7ac:	03010813          	addi	a6,sp,48
    e7b0:	ebffc06f          	j	b66e <_vsnprintf+0x2aae>
    e7b4:	c119                	beqz	a0,e7ba <_vsnprintf+0x5bfa>
    e7b6:	b7ffe06f          	j	d334 <_vsnprintf+0x4774>
    e7ba:	7c08bc0b          	th.extu	s8,a7,31,0
    e7be:	4d01                	li	s10,0
    e7c0:	db8de063          	bltu	s11,s8,dd60 <_vsnprintf+0x51a0>
    e7c4:	020d8463          	beqz	s11,e7ec <_vsnprintf+0x5c2c>
    e7c8:	6682                	ld	a3,0(sp)
    e7ca:	03010813          	addi	a6,sp,48
    e7ce:	beafd06f          	j	bbb8 <_vsnprintf+0x2ff8>
    e7d2:	0001                	nop
    e7d4:	7c0c350b          	th.extu	a0,s8,31,0
    e7d8:	03010813          	addi	a6,sp,48
    e7dc:	be051863          	bnez	a0,dbcc <_vsnprintf+0x500c>
    e7e0:	003ff693          	andi	a3,t6,3
    e7e4:	6d82                	ld	s11,0(sp)
    e7e6:	e299                	bnez	a3,e7ec <_vsnprintf+0x5c2c>
    e7e8:	d3cfd06f          	j	bd24 <_vsnprintf+0x3164>
    e7ec:	6d82                	ld	s11,0(sp)
    e7ee:	e06e                	sd	s11,0(sp)
    e7f0:	d36fd06f          	j	bd26 <_vsnprintf+0x3166>
    e7f4:	0086fc93          	andi	s9,a3,8
    e7f8:	4e0c9363          	bnez	s9,ecde <_vsnprintf+0x611e>
    e7fc:	8c3e                	mv	s8,a5
    e7fe:	4f89                	li	t6,2
    e800:	8dc2                	mv	s11,a6
    e802:	8b7e                	mv	s6,t6
    e804:	6802                	ld	a6,0(sp)
    e806:	e04fe06f          	j	ce0a <_vsnprintf+0x424a>
    e80a:	0001                	nop
    e80c:	6e02                	ld	t3,0(sp)
    e80e:	8dc2                	mv	s11,a6
    e810:	ae9fb06f          	j	a2f8 <_vsnprintf+0x1738>
    e814:	885e                	mv	a6,s7
    e816:	93efe06f          	j	c954 <_vsnprintf+0x3d94>
    e81a:	4b81                	li	s7,0
    e81c:	02000793          	li	a5,32
    e820:	a2fd0ae3          	beq	s10,a5,e254 <_vsnprintf+0x5694>
    e824:	8a0d                	andi	a2,a2,3
    e826:	92061c63          	bnez	a2,d95e <_vsnprintf+0x4d9e>
    e82a:	7c08bc0b          	th.extu	s8,a7,31,0
    e82e:	a38d6de3          	bltu	s10,s8,e268 <_vsnprintf+0x56a8>
    e832:	6382                	ld	t2,0(sp)
    e834:	928fe06f          	j	c95c <_vsnprintf+0x3d9c>
    e838:	00ed7463          	bgeu	s10,a4,e840 <_vsnprintf+0x5c80>
    e83c:	f2dfe06f          	j	d768 <_vsnprintf+0x4ba8>
    e840:	420e8c63          	beqz	t4,ec78 <_vsnprintf+0x60b8>
    e844:	e20b8de3          	beqz	s7,e67e <_vsnprintf+0x5abe>
    e848:	4bc1                	li	s7,16
    e84a:	17768d63          	beq	a3,s7,e9c4 <_vsnprintf+0x5e04>
    e84e:	4509                	li	a0,2
    e850:	52a68463          	beq	a3,a0,ed78 <_vsnprintf+0x61b8>
    e854:	02000d93          	li	s11,32
    e858:	4801                	li	a6,0
    e85a:	ddbd02e3          	beq	s10,s11,e61e <_vsnprintf+0x5a5e>
    e85e:	002d0bb3          	add	s7,s10,sp
    e862:	03000393          	li	t2,48
    e866:	001d0513          	addi	a0,s10,1
    e86a:	027b8823          	sb	t2,48(s7)
    e86e:	02000593          	li	a1,32
    e872:	8bc2                	mv	s7,a6
    e874:	8d2a                	mv	s10,a0
    e876:	9cb50fe3          	beq	a0,a1,e254 <_vsnprintf+0x5694>
    e87a:	b76d                	j	e824 <_vsnprintf+0x5c64>
    e87c:	02000c13          	li	s8,32
    e880:	8f870f63          	beq	a4,s8,d97e <_vsnprintf+0x4dbe>
    e884:	018707b3          	add	a5,a4,s8
    e888:	03010f93          	addi	t6,sp,48
    e88c:	01f785b3          	add	a1,a5,t6
    e890:	07800513          	li	a0,120
    e894:	fea58023          	sb	a0,-32(a1)
    e898:	0705                	addi	a4,a4,1
    e89a:	8dcff06f          	j	d976 <_vsnprintf+0x4db6>
    e89e:	86be                	mv	a3,a5
    e8a0:	ddbfe06f          	j	d67a <_vsnprintf+0x4aba>
    e8a4:	6382                	ld	t2,0(sp)
    e8a6:	4b89                	li	s7,2
    e8a8:	8b4fe06f          	j	c95c <_vsnprintf+0x3d9c>
    e8ac:	7c0c370b          	th.extu	a4,s8,31,0
    e8b0:	03010b13          	addi	s6,sp,48
    e8b4:	e60710e3          	bnez	a4,e714 <_vsnprintf+0x5b54>
    e8b8:	003ffb13          	andi	s6,t6,3
    e8bc:	6382                	ld	t2,0(sp)
    e8be:	000b1463          	bnez	s6,e8c6 <_vsnprintf+0x5d06>
    e8c2:	9ecfe06f          	j	caae <_vsnprintf+0x3eee>
    e8c6:	6382                	ld	t2,0(sp)
    e8c8:	e01e                	sd	t2,0(sp)
    e8ca:	9e6fe06f          	j	cab0 <_vsnprintf+0x3ef0>
    e8ce:	0001                	nop
    e8d0:	87de                	mv	a5,s7
    e8d2:	4ac1                	li	s5,16
    e8d4:	bbbfc06f          	j	b48e <_vsnprintf+0x28ce>
    e8d8:	dc0b8fe3          	beqz	s7,e6b6 <_vsnprintf+0x5af6>
    e8dc:	4c41                	li	s8,16
    e8de:	d3868ae3          	beq	a3,s8,e612 <_vsnprintf+0x5a52>
    e8e2:	4b89                	li	s7,2
    e8e4:	d37693e3          	bne	a3,s7,e60a <_vsnprintf+0x5a4a>
    e8e8:	b32d                	j	e612 <_vsnprintf+0x5a52>
    e8ea:	6e02                	ld	t3,0(sp)
    e8ec:	8dc2                	mv	s11,a6
    e8ee:	ad7fd06f          	j	c3c4 <_vsnprintf+0x3804>
    e8f2:	6a82                	ld	s5,0(sp)
    e8f4:	cb8fc06f          	j	adac <_vsnprintf+0x21ec>
    e8f8:	47fd                	li	a5,31
    e8fa:	42c1                	li	t0,16
    e8fc:	1e568063          	beq	a3,t0,eadc <_vsnprintf+0x5f1c>
    e900:	4389                	li	t2,2
    e902:	1c768a63          	beq	a3,t2,ead6 <_vsnprintf+0x5f16>
    e906:	00278c33          	add	s8,a5,sp
    e90a:	03000793          	li	a5,48
    e90e:	02fc0823          	sb	a5,48(s8)
    e912:	8d5e                	mv	s10,s7
    e914:	bee5                	j	e50c <_vsnprintf+0x594c>
    e916:	4b01                	li	s6,0
    e918:	937fd06f          	j	c24e <_vsnprintf+0x368e>
    e91c:	05800c13          	li	s8,88
    e920:	002d06b3          	add	a3,s10,sp
    e924:	03868723          	sb	s8,46(a3)
    e928:	00288633          	add	a2,a7,sp
    e92c:	03000393          	li	t2,48
    e930:	02760823          	sb	t2,48(a2)
    e934:	4b81                	li	s7,0
    e936:	b2bfc06f          	j	b460 <_vsnprintf+0x28a0>
    e93a:	87b6                	mv	a5,a3
    e93c:	b6b1                	j	e488 <_vsnprintf+0x58c8>
    e93e:	82e2                	mv	t0,s8
    e940:	fadfa06f          	j	98ec <_vsnprintf+0xd2c>
    e944:	02000393          	li	t2,32
    e948:	be7d8d63          	beq	s11,t2,dd42 <_vsnprintf+0x5182>
    e94c:	01b80333          	add	t1,a6,s11
    e950:	8bea                	mv	s7,s10
    e952:	0d85                	addi	s11,s11,1
    e954:	06200e93          	li	t4,98
    e958:	01d30023          	sb	t4,0(t1)
    e95c:	8d5e                	mv	s10,s7
    e95e:	bdcff06f          	j	dd3a <_vsnprintf+0x517a>
    e962:	00c2f293          	andi	t0,t0,12
    e966:	fff88c9b          	addiw	s9,a7,-1
    e96a:	7c0c3d0b          	th.extu	s10,s8,31,0
    e96e:	425c988b          	th.mvnez	a7,s9,t0
    e972:	01a7f463          	bgeu	a5,s10,e97a <_vsnprintf+0x5dba>
    e976:	f74fc06f          	j	b0ea <_vsnprintf+0x252a>
    e97a:	7c08b68b          	th.extu	a3,a7,31,0
    e97e:	00d7f463          	bgeu	a5,a3,e986 <_vsnprintf+0x5dc6>
    e982:	c13fe06f          	j	d594 <_vsnprintf+0x49d4>
    e986:	02000c13          	li	s8,32
    e98a:	b1878263          	beq	a5,s8,dc8e <_vsnprintf+0x50ce>
    e98e:	bb55                	j	e742 <_vsnprintf+0x5b82>
    e990:	02000c13          	li	s8,32
    e994:	bb8d8763          	beq	s11,s8,dd42 <_vsnprintf+0x5182>
    e998:	018d8b33          	add	s6,s11,s8
    e99c:	1818                	addi	a4,sp,48
    e99e:	00eb0fb3          	add	t6,s6,a4
    e9a2:	07800693          	li	a3,120
    e9a6:	fedf8023          	sb	a3,-32(t6)
    e9aa:	0d85                	addi	s11,s11,1
    e9ac:	b8eff06f          	j	dd3a <_vsnprintf+0x517a>
    e9b0:	008afb93          	andi	s7,s5,8
    e9b4:	060b9d63          	bnez	s7,ea2e <_vsnprintf+0x5e6e>
    e9b8:	8c3e                	mv	s8,a5
    e9ba:	4689                	li	a3,2
    e9bc:	6302                	ld	t1,0(sp)
    e9be:	8b36                	mv	s6,a3
    e9c0:	8e9fe06f          	j	d2a8 <_vsnprintf+0x46e8>
    e9c4:	4801                	li	a6,0
    e9c6:	02067e13          	andi	t3,a2,32
    e9ca:	040e0363          	beqz	t3,ea10 <_vsnprintf+0x5e50>
    e9ce:	02000d93          	li	s11,32
    e9d2:	c5bd00e3          	beq	s10,s11,e612 <_vsnprintf+0x5a52>
    e9d6:	020d0293          	addi	t0,s10,32
    e9da:	03010f93          	addi	t6,sp,48
    e9de:	01f28f33          	add	t5,t0,t6
    e9e2:	05800513          	li	a0,88
    e9e6:	feaf0023          	sb	a0,-32(t5)
    e9ea:	0d05                	addi	s10,s10,1
    e9ec:	b939                	j	e60a <_vsnprintf+0x5a4a>
    e9ee:	0001                	nop
    e9f0:	02000693          	li	a3,32
    e9f4:	c0dd0fe3          	beq	s10,a3,e612 <_vsnprintf+0x5a52>
    e9f8:	002d05b3          	add	a1,s10,sp
    e9fc:	06200713          	li	a4,98
    ea00:	02e58823          	sb	a4,48(a1)
    ea04:	0d05                	addi	s10,s10,1
    ea06:	b111                	j	e60a <_vsnprintf+0x5a4a>
    ea08:	8bc2                	mv	s7,a6
    ea0a:	7c0c370b          	th.extu	a4,s8,31,0
    ea0e:	b985                	j	e67e <_vsnprintf+0x5abe>
    ea10:	02000c13          	li	s8,32
    ea14:	bf8d0fe3          	beq	s10,s8,e612 <_vsnprintf+0x5a52>
    ea18:	018d0bb3          	add	s7,s10,s8
    ea1c:	181c                	addi	a5,sp,48
    ea1e:	00fb83b3          	add	t2,s7,a5
    ea22:	07800593          	li	a1,120
    ea26:	feb38023          	sb	a1,-32(t2)
    ea2a:	0d05                	addi	s10,s10,1
    ea2c:	bef9                	j	e60a <_vsnprintf+0x5a4a>
    ea2e:	4b09                	li	s6,2
    ea30:	03010293          	addi	t0,sp,48
    ea34:	00578d33          	add	s10,a5,t0
    ea38:	02000513          	li	a0,32
    ea3c:	00ad0023          	sb	a0,0(s10)
    ea40:	898d                	andi	a1,a1,3
    ea42:	00178c13          	addi	s8,a5,1
    ea46:	e999                	bnez	a1,ea5c <_vsnprintf+0x5e9c>
    ea48:	7c08bd0b          	th.extu	s10,a7,31,0
    ea4c:	01ac7463          	bgeu	s8,s10,ea54 <_vsnprintf+0x5e94>
    ea50:	ec0fe06f          	j	d110 <_vsnprintf+0x4550>
    ea54:	6302                	ld	t1,0(sp)
    ea56:	8b96                	mv	s7,t0
    ea58:	9eefc06f          	j	ac46 <_vsnprintf+0x2086>
    ea5c:	6302                	ld	t1,0(sp)
    ea5e:	03010b93          	addi	s7,sp,48
    ea62:	9e4fc06f          	j	ac46 <_vsnprintf+0x2086>
    ea66:	02000e13          	li	t3,32
    ea6a:	01c79463          	bne	a5,t3,ea72 <_vsnprintf+0x5eb2>
    ea6e:	eeafb06f          	j	a158 <_vsnprintf+0x1598>
    ea72:	86be                	mv	a3,a5
    ea74:	f86fc06f          	j	b1fa <_vsnprintf+0x263a>
    ea78:	86be                	mv	a3,a5
    ea7a:	01578463          	beq	a5,s5,ea82 <_vsnprintf+0x5ec2>
    ea7e:	e3efd06f          	j	c0bc <_vsnprintf+0x34fc>
    ea82:	c5dfe06f          	j	d6de <_vsnprintf+0x4b1e>
    ea86:	020e7a93          	andi	s5,t3,32
    ea8a:	020a9e63          	bnez	s5,eac6 <_vsnprintf+0x5f06>
    ea8e:	07800613          	li	a2,120
    ea92:	02c10823          	sb	a2,48(sp)
    ea96:	03000c93          	li	s9,48
    ea9a:	039108a3          	sb	s9,49(sp)
    ea9e:	8d5e                	mv	s10,s7
    eaa0:	4709                	li	a4,2
    eaa2:	bc8d                	j	e514 <_vsnprintf+0x5954>
    eaa4:	0085f693          	andi	a3,a1,8
    eaa8:	f6c1                	bnez	a3,ea30 <_vsnprintf+0x5e70>
    eaaa:	003bfa93          	andi	s5,s7,3
    eaae:	8c3e                	mv	s8,a5
    eab0:	f00a96e3          	bnez	s5,e9bc <_vsnprintf+0x5dfc>
    eab4:	7c08bd0b          	th.extu	s10,a7,31,0
    eab8:	4b01                	li	s6,0
    eaba:	4681                	li	a3,0
    eabc:	01ac7463          	bgeu	s8,s10,eac4 <_vsnprintf+0x5f04>
    eac0:	e50fe06f          	j	d110 <_vsnprintf+0x4550>
    eac4:	bde5                	j	e9bc <_vsnprintf+0x5dfc>
    eac6:	05800313          	li	t1,88
    eaca:	02610823          	sb	t1,48(sp)
    eace:	8d5e                	mv	s10,s7
    ead0:	4705                	li	a4,1
    ead2:	c74ff06f          	j	df46 <_vsnprintf+0x5386>
    ead6:	00f80633          	add	a2,a6,a5
    eada:	bee5                	j	e6d2 <_vsnprintf+0x5b12>
    eadc:	020e7e93          	andi	t4,t3,32
    eae0:	ffe70d13          	addi	s10,a4,-2
    eae4:	040e9463          	bnez	t4,eb2c <_vsnprintf+0x5f6c>
    eae8:	020d0713          	addi	a4,s10,32
    eaec:	03010c93          	addi	s9,sp,48
    eaf0:	019702b3          	add	t0,a4,s9
    eaf4:	07800393          	li	t2,120
    eaf8:	fe728023          	sb	t2,-32(t0)
    eafc:	8d5e                	mv	s10,s7
    eafe:	873e                	mv	a4,a5
    eb00:	c46ff06f          	j	df46 <_vsnprintf+0x5386>
    eb04:	c319                	beqz	a4,eb0a <_vsnprintf+0x5f4a>
    eb06:	c63fe06f          	j	d768 <_vsnprintf+0x4ba8>
    eb0a:	7c08bc0b          	th.extu	s8,a7,31,0
    eb0e:	4b81                	li	s7,0
    eb10:	f58d6c63          	bltu	s10,s8,e268 <_vsnprintf+0x56a8>
    eb14:	da0d09e3          	beqz	s10,e8c6 <_vsnprintf+0x5d06>
    eb18:	6382                	ld	t2,0(sp)
    eb1a:	03010b13          	addi	s6,sp,48
    eb1e:	e3ffd06f          	j	c95c <_vsnprintf+0x3d9c>
    eb22:	6802                	ld	a6,0(sp)
    eb24:	02d00513          	li	a0,45
    eb28:	f32fd06f          	j	c25a <_vsnprintf+0x369a>
    eb2c:	020d0b13          	addi	s6,s10,32
    eb30:	03010a93          	addi	s5,sp,48
    eb34:	015b0333          	add	t1,s6,s5
    eb38:	05800613          	li	a2,88
    eb3c:	177d                	addi	a4,a4,-1
    eb3e:	fec30023          	sb	a2,-32(t1)
    eb42:	8d5e                	mv	s10,s7
    eb44:	c02ff06f          	j	df46 <_vsnprintf+0x5386>
    eb48:	45fd                	li	a1,31
    eb4a:	4dc1                	li	s11,16
    eb4c:	0bb68363          	beq	a3,s11,ebf2 <_vsnprintf+0x6032>
    eb50:	4289                	li	t0,2
    eb52:	08568d63          	beq	a3,t0,ebec <_vsnprintf+0x602c>
    eb56:	00258533          	add	a0,a1,sp
    eb5a:	03000c13          	li	s8,48
    eb5e:	03850823          	sb	s8,48(a0)
    eb62:	b96d                	j	e81c <_vsnprintf+0x5c5c>
    eb64:	4d01                	li	s10,0
    eb66:	9dcff06f          	j	dd42 <_vsnprintf+0x5182>
    eb6a:	cfbc0263          	beq	s8,s11,e04e <_vsnprintf+0x548e>
    eb6e:	cfb88063          	beq	a7,s11,e04e <_vsnprintf+0x548e>
    eb72:	4d01                	li	s10,0
    eb74:	9baff06f          	j	dd2e <_vsnprintf+0x516e>
    eb78:	7c08bc0b          	th.extu	s8,a7,31,0
    eb7c:	4d05                	li	s10,1
    eb7e:	ef8d6563          	bltu	s10,s8,e268 <_vsnprintf+0x56a8>
    eb82:	6382                	ld	t2,0(sp)
    eb84:	dd9fd06f          	j	c95c <_vsnprintf+0x3d9c>
    eb88:	02067c93          	andi	s9,a2,32
    eb8c:	020c9163          	bnez	s9,ebae <_vsnprintf+0x5fee>
    eb90:	07800693          	li	a3,120
    eb94:	02d10823          	sb	a3,48(sp)
    eb98:	03000e13          	li	t3,48
    eb9c:	03c108a3          	sb	t3,49(sp)
    eba0:	4d09                	li	s10,2
    eba2:	b149                	j	e824 <_vsnprintf+0x5c64>
    eba4:	06200e93          	li	t4,98
    eba8:	03d10823          	sb	t4,48(sp)
    ebac:	b7f5                	j	eb98 <_vsnprintf+0x5fd8>
    ebae:	05800313          	li	t1,88
    ebb2:	02610823          	sb	t1,48(sp)
    ebb6:	885e                	mv	a6,s7
    ebb8:	4d05                	li	s10,1
    ebba:	b155                	j	e85e <_vsnprintf+0x5c9e>
    ebbc:	4d41                	li	s10,16
    ebbe:	e1a68563          	beq	a3,s10,e1c8 <_vsnprintf+0x5608>
    ebc2:	4509                	li	a0,2
    ebc4:	00a68e63          	beq	a3,a0,ebe0 <_vsnprintf+0x6020>
    ebc8:	02000313          	li	t1,32
    ebcc:	4d01                	li	s10,0
    ebce:	986d8063          	beq	s11,t1,dd4e <_vsnprintf+0x518e>
    ebd2:	c06ff06f          	j	dfd8 <_vsnprintf+0x5418>
    ebd6:	02000613          	li	a2,32
    ebda:	c2cd8163          	beq	s11,a2,dffc <_vsnprintf+0x543c>
    ebde:	bef1                	j	e7ba <_vsnprintf+0x5bfa>
    ebe0:	02000e93          	li	t4,32
    ebe4:	4d01                	li	s10,0
    ebe6:	97dd8463          	beq	s11,t4,dd4e <_vsnprintf+0x518e>
    ebea:	b38d                	j	e94c <_vsnprintf+0x5d8c>
    ebec:	885e                	mv	a6,s7
    ebee:	8d2e                	mv	s10,a1
    ebf0:	b521                	j	e9f8 <_vsnprintf+0x5e38>
    ebf2:	ffed0813          	addi	a6,s10,-2
    ebf6:	02067c93          	andi	s9,a2,32
    ebfa:	1d7d                	addi	s10,s10,-1
    ebfc:	02080313          	addi	t1,a6,32
    ec00:	080c9263          	bnez	s9,ec84 <_vsnprintf+0x60c4>
    ec04:	03010293          	addi	t0,sp,48
    ec08:	00530fb3          	add	t6,t1,t0
    ec0c:	07800f13          	li	t5,120
    ec10:	ffef8023          	sb	t5,-32(t6)
    ec14:	885e                	mv	a6,s7
    ec16:	b1a1                	j	e85e <_vsnprintf+0x5c9e>
    ec18:	02067b13          	andi	s6,a2,32
    ec1c:	020b1563          	bnez	s6,ec46 <_vsnprintf+0x6086>
    ec20:	07800693          	li	a3,120
    ec24:	02d10823          	sb	a3,48(sp)
    ec28:	03000f93          	li	t6,48
    ec2c:	03f108a3          	sb	t6,49(sp)
    ec30:	4d89                	li	s11,2
    ec32:	c40ff06f          	j	e072 <_vsnprintf+0x54b2>
    ec36:	000e8f63          	beqz	t4,ec54 <_vsnprintf+0x6094>
    ec3a:	4801                	li	a6,0
    ec3c:	9c0b91e3          	bnez	s7,e5fe <_vsnprintf+0x5a3e>
    ec40:	9aed1fe3          	bne	s10,a4,e5fe <_vsnprintf+0x5a3e>
    ec44:	b4a1                	j	e68c <_vsnprintf+0x5acc>
    ec46:	05800713          	li	a4,88
    ec4a:	02e10823          	sb	a4,48(sp)
    ec4e:	4d85                	li	s11,1
    ec50:	b88ff06f          	j	dfd8 <_vsnprintf+0x5418>
    ec54:	02000c13          	li	s8,32
    ec58:	4b81                	li	s7,0
    ec5a:	bd8d15e3          	bne	s10,s8,e824 <_vsnprintf+0x5c64>
    ec5e:	cf7fd06f          	j	c954 <_vsnprintf+0x3d94>
    ec62:	4ac1                	li	s5,16
    ec64:	4b89                	li	s7,2
    ec66:	fe2ff06f          	j	e448 <_vsnprintf+0x5888>
    ec6a:	6382                	ld	t2,0(sp)
    ec6c:	4b81                	li	s7,0
    ec6e:	ceffd06f          	j	c95c <_vsnprintf+0x3d9c>
    ec72:	01c80333          	add	t1,a6,t3
    ec76:	b9f9                	j	e954 <_vsnprintf+0x5d94>
    ec78:	02000e93          	li	t4,32
    ec7c:	4b81                	li	s7,0
    ec7e:	dddd0f63          	beq	s10,t4,e25c <_vsnprintf+0x569c>
    ec82:	b561                	j	eb0a <_vsnprintf+0x5f4a>
    ec84:	1814                	addi	a3,sp,48
    ec86:	00d30e33          	add	t3,t1,a3
    ec8a:	05800d93          	li	s11,88
    ec8e:	ffbe0023          	sb	s11,-32(t3)
    ec92:	885e                	mv	a6,s7
    ec94:	b6e9                	j	e85e <_vsnprintf+0x5c9e>
    ec96:	05800593          	li	a1,88
    ec9a:	feb28023          	sb	a1,-32(t0)
    ec9e:	8d5e                	mv	s10,s7
    eca0:	b38ff06f          	j	dfd8 <_vsnprintf+0x5418>
    eca4:	8dc2                	mv	s11,a6
    eca6:	4b01                	li	s6,0
    eca8:	6802                	ld	a6,0(sp)
    ecaa:	8c96                	mv	s9,t0
    ecac:	daefd06f          	j	c25a <_vsnprintf+0x369a>
    ecb0:	0085ff93          	andi	t6,a1,8
    ecb4:	060f9263          	bnez	t6,ed18 <_vsnprintf+0x6158>
    ecb8:	003cfe93          	andi	t4,s9,3
    ecbc:	8c3e                	mv	s8,a5
    ecbe:	b40e91e3          	bnez	t4,e800 <_vsnprintf+0x5c40>
    ecc2:	7c08bb8b          	th.extu	s7,a7,31,0
    ecc6:	8dc2                	mv	s11,a6
    ecc8:	4b01                	li	s6,0
    ecca:	4f81                	li	t6,0
    eccc:	017c7463          	bgeu	s8,s7,ecd4 <_vsnprintf+0x6114>
    ecd0:	fa5fd06f          	j	cc74 <_vsnprintf+0x40b4>
    ecd4:	b635                	j	e800 <_vsnprintf+0x5c40>
    ecd6:	6302                	ld	t1,0(sp)
    ecd8:	4b01                	li	s6,0
    ecda:	f6dfb06f          	j	ac46 <_vsnprintf+0x2086>
    ecde:	8dc2                	mv	s11,a6
    ece0:	4b09                	li	s6,2
    ece2:	1818                	addi	a4,sp,48
    ece4:	00e78f33          	add	t5,a5,a4
    ece8:	02000513          	li	a0,32
    ecec:	00af0023          	sb	a0,0(t5)
    ecf0:	0035fd13          	andi	s10,a1,3
    ecf4:	00178c13          	addi	s8,a5,1
    ecf8:	020d1263          	bnez	s10,ed1c <_vsnprintf+0x615c>
    ecfc:	7c08bb8b          	th.extu	s7,a7,31,0
    ed00:	017c7463          	bgeu	s8,s7,ed08 <_vsnprintf+0x6148>
    ed04:	f71fd06f          	j	cc74 <_vsnprintf+0x40b4>
    ed08:	6802                	ld	a6,0(sp)
    ed0a:	8cba                	mv	s9,a4
    ed0c:	d4efd06f          	j	c25a <_vsnprintf+0x369a>
    ed10:	008afb93          	andi	s7,s5,8
    ed14:	fa0b87e3          	beqz	s7,ecc2 <_vsnprintf+0x6102>
    ed18:	8dc2                	mv	s11,a6
    ed1a:	b7e1                	j	ece2 <_vsnprintf+0x6122>
    ed1c:	6802                	ld	a6,0(sp)
    ed1e:	03010c93          	addi	s9,sp,48
    ed22:	d38fd06f          	j	c25a <_vsnprintf+0x369a>
    ed26:	851e                	mv	a0,t2
    ed28:	8dc2                	mv	s11,a6
    ed2a:	6382                	ld	t2,0(sp)
    ed2c:	4b01                	li	s6,0
    ed2e:	03010313          	addi	t1,sp,48
    ed32:	c32fb06f          	j	a164 <_vsnprintf+0x15a4>
    ed36:	0085fa93          	andi	s5,a1,8
    ed3a:	040a8563          	beqz	s5,ed84 <_vsnprintf+0x61c4>
    ed3e:	8dc2                	mv	s11,a6
    ed40:	02078813          	addi	a6,a5,32
    ed44:	03010293          	addi	t0,sp,48
    ed48:	00580cb3          	add	s9,a6,t0
    ed4c:	02000c13          	li	s8,32
    ed50:	ff8c8023          	sb	s8,-32(s9)
    ed54:	0035fb93          	andi	s7,a1,3
    ed58:	00178d13          	addi	s10,a5,1
    ed5c:	000b9863          	bnez	s7,ed6c <_vsnprintf+0x61ac>
    ed60:	7c08bb8b          	th.extu	s7,a7,31,0
    ed64:	017d7463          	bgeu	s10,s7,ed6c <_vsnprintf+0x61ac>
    ed68:	cbcfc06f          	j	b224 <_vsnprintf+0x2664>
    ed6c:	6382                	ld	t2,0(sp)
    ed6e:	8562                	mv	a0,s8
    ed70:	03010313          	addi	t1,sp,48
    ed74:	bf0fb06f          	j	a164 <_vsnprintf+0x15a4>
    ed78:	02000293          	li	t0,32
    ed7c:	4801                	li	a6,0
    ed7e:	8a5d00e3          	beq	s10,t0,e61e <_vsnprintf+0x5a5e>
    ed82:	b99d                	j	e9f8 <_vsnprintf+0x5e38>
    ed84:	00337e13          	andi	t3,t1,3
    ed88:	8d3e                	mv	s10,a5
    ed8a:	000e1b63          	bnez	t3,eda0 <_vsnprintf+0x61e0>
    ed8e:	7c08bb8b          	th.extu	s7,a7,31,0
    ed92:	8dc2                	mv	s11,a6
    ed94:	4b01                	li	s6,0
    ed96:	4a81                	li	s5,0
    ed98:	017d7463          	bgeu	s10,s7,eda0 <_vsnprintf+0x61e0>
    ed9c:	c88fc06f          	j	b224 <_vsnprintf+0x2664>
    eda0:	6382                	ld	t2,0(sp)
    eda2:	8dc2                	mv	s11,a6
    eda4:	8b56                	mv	s6,s5
    eda6:	e12fc06f          	j	b3b8 <_vsnprintf+0x27f8>
    edaa:	7c08bc0b          	th.extu	s8,a7,31,0
    edae:	4d85                	li	s11,1
    edb0:	018df463          	bgeu	s11,s8,edb8 <_vsnprintf+0x61f8>
    edb4:	fadfe06f          	j	dd60 <_vsnprintf+0x51a0>
    edb8:	6682                	ld	a3,0(sp)
    edba:	dfffc06f          	j	bbb8 <_vsnprintf+0x2ff8>
    edbe:	06200c13          	li	s8,98
    edc2:	03810823          	sb	s8,48(sp)
    edc6:	b58d                	j	ec28 <_vsnprintf+0x6068>
    edc8:	004afb13          	andi	s6,s5,4
    edcc:	f40b02e3          	beqz	s6,ed10 <_vsnprintf+0x6150>
    edd0:	02b00b13          	li	s6,43
    edd4:	03610823          	sb	s6,48(sp)
    edd8:	4c05                	li	s8,1
    edda:	ed8ff06f          	j	e4b2 <_vsnprintf+0x58f2>
    edde:	0082f313          	andi	t1,t0,8
    ede2:	02031463          	bnez	t1,ee0a <_vsnprintf+0x624a>
    ede6:	8d3e                	mv	s10,a5
    ede8:	4a89                	li	s5,2
    edea:	bf5d                	j	eda0 <_vsnprintf+0x61e0>
    edec:	03000e93          	li	t4,48
    edf0:	47bd                	li	a5,15
    edf2:	03d10823          	sb	t4,48(sp)
    edf6:	4b81                	li	s7,0
    edf8:	4d01                	li	s10,0
    edfa:	40000c93          	li	s9,1024
    edfe:	4e05                	li	t3,1
    ee00:	8abe                	mv	s5,a5
    ee02:	03010b13          	addi	s6,sp,48
    ee06:	eecfb06f          	j	a4f2 <_vsnprintf+0x1932>
    ee0a:	8dc2                	mv	s11,a6
    ee0c:	4b09                	li	s6,2
    ee0e:	bf0d                	j	ed40 <_vsnprintf+0x6180>
    ee10:	000e8463          	beqz	t4,ee18 <_vsnprintf+0x6258>
    ee14:	b53fe06f          	j	d966 <_vsnprintf+0x4da6>
    ee18:	02000b93          	li	s7,32
    ee1c:	01771463          	bne	a4,s7,ee24 <_vsnprintf+0x6264>
    ee20:	849fc06f          	j	b668 <_vsnprintf+0x2aa8>
    ee24:	9fcfe06f          	j	d020 <_vsnprintf+0x4460>
    ee28:	7c08bf8b          	th.extu	t6,a7,31,0
    ee2c:	01f7f463          	bgeu	a5,t6,ee34 <_vsnprintf+0x6274>
    ee30:	81dfd06f          	j	c64c <_vsnprintf+0x3a8c>
    ee34:	02000e13          	li	t3,32
    ee38:	01c79463          	bne	a5,t3,ee40 <_vsnprintf+0x6280>
    ee3c:	e01fb06f          	j	ac3c <_vsnprintf+0x207c>
    ee40:	903fd06f          	j	c742 <_vsnprintf+0x3b82>
    ee44:	02000513          	li	a0,32
    ee48:	02a79463          	bne	a5,a0,ee70 <_vsnprintf+0x62b0>
    ee4c:	0036fa93          	andi	s5,a3,3
    ee50:	000a9463          	bnez	s5,ee58 <_vsnprintf+0x6298>
    ee54:	897fe06f          	j	d6ea <_vsnprintf+0x4b2a>
    ee58:	bf6fd06f          	j	c24e <_vsnprintf+0x368e>
    ee5c:	f80e9f63          	bnez	t4,e5fa <_vsnprintf+0x5a3a>
    ee60:	02000713          	li	a4,32
    ee64:	00ed1463          	bne	s10,a4,ee6c <_vsnprintf+0x62ac>
    ee68:	aedfd06f          	j	c954 <_vsnprintf+0x3d94>
    ee6c:	ae1fe06f          	j	d94c <_vsnprintf+0x4d8c>
    ee70:	86be                	mv	a3,a5
    ee72:	a4afd06f          	j	c0bc <_vsnprintf+0x34fc>
    ee76:	020e8a63          	beqz	t4,eeaa <_vsnprintf+0x62ea>
    ee7a:	4d01                	li	s10,0
    ee7c:	000b8463          	beqz	s7,ee84 <_vsnprintf+0x62c4>
    ee80:	aebfe06f          	j	d96a <_vsnprintf+0x4daa>
    ee84:	00a70463          	beq	a4,a0,ee8c <_vsnprintf+0x62cc>
    ee88:	ae3fe06f          	j	d96a <_vsnprintf+0x4daa>
    ee8c:	e57fe06f          	j	dce2 <_vsnprintf+0x5122>
    ee90:	020d0663          	beqz	s10,eebc <_vsnprintf+0x62fc>
    ee94:	4d01                	li	s10,0
    ee96:	000b8463          	beqz	s7,ee9e <_vsnprintf+0x62de>
    ee9a:	e95fe06f          	j	dd2e <_vsnprintf+0x516e>
    ee9e:	00ad8463          	beq	s11,a0,eea6 <_vsnprintf+0x62e6>
    eea2:	e8dfe06f          	j	dd2e <_vsnprintf+0x516e>
    eea6:	97cff06f          	j	e022 <_vsnprintf+0x5462>
    eeaa:	02000b93          	li	s7,32
    eeae:	01771463          	bne	a4,s7,eeb6 <_vsnprintf+0x62f6>
    eeb2:	fb6fc06f          	j	b668 <_vsnprintf+0x2aa8>
    eeb6:	4d01                	li	s10,0
    eeb8:	e5cff06f          	j	e514 <_vsnprintf+0x5954>
    eebc:	02000b93          	li	s7,32
    eec0:	9b7d9963          	bne	s11,s7,e072 <_vsnprintf+0x54b2>
    eec4:	4d01                	li	s10,0
    eec6:	cedfc06f          	j	bbb2 <_vsnprintf+0x2ff2>
    eeca:	00457b93          	andi	s7,a0,4
    eece:	020b9a63          	bnez	s7,ef02 <_vsnprintf+0x6342>
    eed2:	00857593          	andi	a1,a0,8
    eed6:	e18d                	bnez	a1,eef8 <_vsnprintf+0x6338>
    eed8:	020d0c93          	addi	s9,s10,32
    eedc:	1810                	addi	a2,sp,48
    eede:	00cc8fb3          	add	t6,s9,a2
    eee2:	fdffc503          	lbu	a0,-33(t6)
    eee6:	4b89                	li	s7,2
    eee8:	4ac1                	li	s5,16
    eeea:	9d3fb06f          	j	a8bc <_vsnprintf+0x1cfc>
    eeee:	47fd                	li	a5,31
    eef0:	4ac1                	li	s5,16
    eef2:	4b89                	li	s7,2
    eef4:	d54ff06f          	j	e448 <_vsnprintf+0x5888>
    eef8:	87ea                	mv	a5,s10
    eefa:	4b89                	li	s7,2
    eefc:	4ac1                	li	s5,16
    eefe:	d90fc06f          	j	b48e <_vsnprintf+0x28ce>
    ef02:	87ea                	mv	a5,s10
    ef04:	4b89                	li	s7,2
    ef06:	4ac1                	li	s5,16
    ef08:	958fc06f          	j	b060 <_vsnprintf+0x24a0>
    ef0c:	02000513          	li	a0,32
    ef10:	0ea79e63          	bne	a5,a0,f00c <_vsnprintf+0x644c>
    ef14:	0032fe93          	andi	t4,t0,3
    ef18:	000e9463          	bnez	t4,ef20 <_vsnprintf+0x6360>
    ef1c:	d7ffe06f          	j	dc9a <_vsnprintf+0x50da>
    ef20:	a38fb06f          	j	a158 <_vsnprintf+0x1598>
    ef24:	02000813          	li	a6,32
    ef28:	01078463          	beq	a5,a6,ef30 <_vsnprintf+0x6370>
    ef2c:	80ffd06f          	j	c73a <_vsnprintf+0x3b7a>
    ef30:	003afe93          	andi	t4,s5,3
    ef34:	000e9463          	bnez	t4,ef3c <_vsnprintf+0x637c>
    ef38:	ba0fe06f          	j	d2d8 <_vsnprintf+0x4718>
    ef3c:	d01fb06f          	j	ac3c <_vsnprintf+0x207c>
    ef40:	6382                	ld	t2,0(sp)
    ef42:	02d00513          	li	a0,45
    ef46:	a1efb06f          	j	a164 <_vsnprintf+0x15a4>
    ef4a:	6382                	ld	t2,0(sp)
    ef4c:	8dc2                	mv	s11,a6
    ef4e:	8532                	mv	a0,a2
    ef50:	4b01                	li	s6,0
    ef52:	a12fb06f          	j	a164 <_vsnprintf+0x15a4>
    ef56:	0001                	nop
    ef58:	87b6                	mv	a5,a3
    ef5a:	fe8ff06f          	j	e742 <_vsnprintf+0x5b82>
    ef5e:	004afb13          	andi	s6,s5,4
    ef62:	040b0263          	beqz	s6,efa6 <_vsnprintf+0x63e6>
    ef66:	02b00b13          	li	s6,43
    ef6a:	03610823          	sb	s6,48(sp)
    ef6e:	4d05                	li	s10,1
    ef70:	ffcff06f          	j	e76c <_vsnprintf+0x5bac>
    ef74:	00778463          	beq	a5,t2,ef7c <_vsnprintf+0x63bc>
    ef78:	fc2fd06f          	j	c73a <_vsnprintf+0x3b7a>
    ef7c:	b80fe06f          	j	d2fc <_vsnprintf+0x473c>
    ef80:	02000c13          	li	s8,32
    ef84:	81871de3          	bne	a4,s8,e79e <_vsnprintf+0x5bde>
    ef88:	4d01                	li	s10,0
    ef8a:	cadfe06f          	j	dc36 <_vsnprintf+0x5076>
    ef8e:	02000513          	li	a0,32
    ef92:	4d01                	li	s10,0
    ef94:	00a71463          	bne	a4,a0,ef9c <_vsnprintf+0x63dc>
    ef98:	9f1fe06f          	j	d988 <_vsnprintf+0x4dc8>
    ef9c:	f2eff06f          	j	e6ca <_vsnprintf+0x5b0a>
    efa0:	4b01                	li	s6,0
    efa2:	9b6fb06f          	j	a158 <_vsnprintf+0x1598>
    efa6:	008af393          	andi	t2,s5,8
    efaa:	d8039ae3          	bnez	t2,ed3e <_vsnprintf+0x617e>
    efae:	b3c5                	j	ed8e <_vsnprintf+0x61ce>
    efb0:	6302                	ld	t1,0(sp)
    efb2:	02b00513          	li	a0,43
    efb6:	03010b93          	addi	s7,sp,48
    efba:	c8dfb06f          	j	ac46 <_vsnprintf+0x2086>
    efbe:	008d7f13          	andi	t5,s10,8
    efc2:	a60f17e3          	bnez	t5,ea30 <_vsnprintf+0x5e70>
    efc6:	b4fd                	j	eab4 <_vsnprintf+0x5ef4>
    efc8:	6e02                	ld	t3,0(sp)
    efca:	4d01                	li	s10,0
    efcc:	ea2fc06f          	j	b66e <_vsnprintf+0x2aae>
    efd0:	7c08bc0b          	th.extu	s8,a7,31,0
    efd4:	4705                	li	a4,1
    efd6:	8d5e                	mv	s10,s7
    efd8:	01877463          	bgeu	a4,s8,efe0 <_vsnprintf+0x6420>
    efdc:	9bdfe06f          	j	d998 <_vsnprintf+0x4dd8>
    efe0:	6e02                	ld	t3,0(sp)
    efe2:	e8cfc06f          	j	b66e <_vsnprintf+0x2aae>
    efe6:	06200b13          	li	s6,98
    efea:	03610823          	sb	s6,48(sp)
    efee:	b465                	j	ea96 <_vsnprintf+0x5ed6>
    eff0:	03000793          	li	a5,48
    eff4:	02f10823          	sb	a5,48(sp)
    eff8:	47c1                	li	a5,16
    effa:	4d01                	li	s10,0
    effc:	40000c93          	li	s9,1024
    f000:	4e05                	li	t3,1
    f002:	8abe                	mv	s5,a5
    f004:	03010b13          	addi	s6,sp,48
    f008:	ceafb06f          	j	a4f2 <_vsnprintf+0x1932>
    f00c:	86be                	mv	a3,a5
    f00e:	9e4fc06f          	j	b1f2 <_vsnprintf+0x2632>
    f012:	0001                	nop
    f014:	00000013          	nop
    f018:	00000013          	nop
    f01c:	00000013          	nop

000000000000f020 <puts>:
    f020:	1141                	addi	sp,sp,-16
    f022:	f811540b          	th.sdd	s0,ra,(sp),0,4
    f026:	842a                	mv	s0,a0
    f028:	00054503          	lbu	a0,0(a0)
    f02c:	c12d                	beqz	a0,f08e <puts+0x6e>
    f02e:	55fd                	li	a1,-1
    f030:	860f80ef          	jal	7090 <fputc>
    f034:	00144503          	lbu	a0,1(s0)
    f038:	c939                	beqz	a0,f08e <puts+0x6e>
    f03a:	55fd                	li	a1,-1
    f03c:	854f80ef          	jal	7090 <fputc>
    f040:	00244503          	lbu	a0,2(s0)
    f044:	c529                	beqz	a0,f08e <puts+0x6e>
    f046:	55fd                	li	a1,-1
    f048:	848f80ef          	jal	7090 <fputc>
    f04c:	00344503          	lbu	a0,3(s0)
    f050:	cd1d                	beqz	a0,f08e <puts+0x6e>
    f052:	55fd                	li	a1,-1
    f054:	83cf80ef          	jal	7090 <fputc>
    f058:	00444503          	lbu	a0,4(s0)
    f05c:	c90d                	beqz	a0,f08e <puts+0x6e>
    f05e:	55fd                	li	a1,-1
    f060:	830f80ef          	jal	7090 <fputc>
    f064:	00544503          	lbu	a0,5(s0)
    f068:	c11d                	beqz	a0,f08e <puts+0x6e>
    f06a:	55fd                	li	a1,-1
    f06c:	824f80ef          	jal	7090 <fputc>
    f070:	00644503          	lbu	a0,6(s0)
    f074:	cd09                	beqz	a0,f08e <puts+0x6e>
    f076:	55fd                	li	a1,-1
    f078:	818f80ef          	jal	7090 <fputc>
    f07c:	00744503          	lbu	a0,7(s0)
    f080:	c519                	beqz	a0,f08e <puts+0x6e>
    f082:	55fd                	li	a1,-1
    f084:	80cf80ef          	jal	7090 <fputc>
    f088:	8884450b          	th.lbuib	a0,(s0),8,0
    f08c:	f14d                	bnez	a0,f02e <puts+0xe>
    f08e:	55fd                	li	a1,-1
    f090:	4529                	li	a0,10
    f092:	ffff70ef          	jal	7090 <fputc>
    f096:	f811440b          	th.ldd	s0,ra,(sp),0,4
    f09a:	4501                	li	a0,0
    f09c:	0141                	addi	sp,sp,16
    f09e:	8082                	ret

000000000000f0a0 <_putchar>:
    f0a0:	55fd                	li	a1,-1
    f0a2:	feff706f          	j	7090 <fputc>
    f0a6:	00000013          	nop
    f0aa:	00000013          	nop
    f0ae:	0001                	nop

000000000000f0b0 <putchar>:
    f0b0:	1141                	addi	sp,sp,-16
    f0b2:	55fd                	li	a1,-1
    f0b4:	0ff57513          	zext.b	a0,a0
    f0b8:	e406                	sd	ra,8(sp)
    f0ba:	fd7f70ef          	jal	7090 <fputc>
    f0be:	60a2                	ld	ra,8(sp)
    f0c0:	4501                	li	a0,0
    f0c2:	0141                	addi	sp,sp,16
    f0c4:	8082                	ret
    f0c6:	00000013          	nop
    f0ca:	00000013          	nop
    f0ce:	0001                	nop

000000000000f0d0 <printf>:
    f0d0:	711d                	addi	sp,sp,-96
    f0d2:	fed1560b          	th.sdd	a2,a3,(sp),3,4
    f0d6:	86aa                	mv	a3,a0
    f0d8:	651d                	lui	a0,0x7
    f0da:	e0ba                	sd	a4,64(sp)
    f0dc:	e4be                	sd	a5,72(sp)
    f0de:	f42e                	sd	a1,40(sp)
    f0e0:	1038                	addi	a4,sp,40
    f0e2:	858a                	mv	a1,sp
    f0e4:	567d                	li	a2,-1
    f0e6:	12050513          	addi	a0,a0,288 # 7120 <_out_char>
    f0ea:	ec06                	sd	ra,24(sp)
    f0ec:	e8c2                	sd	a6,80(sp)
    f0ee:	ecc6                	sd	a7,88(sp)
    f0f0:	e43a                	sd	a4,8(sp)
    f0f2:	acff90ef          	jal	8bc0 <_vsnprintf>
    f0f6:	60e2                	ld	ra,24(sp)
    f0f8:	6125                	addi	sp,sp,96
    f0fa:	8082                	ret
    f0fc:	00000013          	nop

000000000000f100 <sprintf>:
    f100:	715d                	addi	sp,sp,-80
    f102:	fcd1560b          	th.sdd	a2,a3,(sp),2,4
    f106:	86ae                	mv	a3,a1
    f108:	85aa                	mv	a1,a0
    f10a:	651d                	lui	a0,0x7
    f10c:	fef1570b          	th.sdd	a4,a5,(sp),3,4
    f110:	567d                	li	a2,-1
    f112:	1018                	addi	a4,sp,32
    f114:	0f050513          	addi	a0,a0,240 # 70f0 <_out_buffer>
    f118:	ec06                	sd	ra,24(sp)
    f11a:	e0c2                	sd	a6,64(sp)
    f11c:	e4c6                	sd	a7,72(sp)
    f11e:	e43a                	sd	a4,8(sp)
    f120:	aa1f90ef          	jal	8bc0 <_vsnprintf>
    f124:	60e2                	ld	ra,24(sp)
    f126:	6161                	addi	sp,sp,80
    f128:	8082                	ret
    f12a:	00000013          	nop
    f12e:	0001                	nop

000000000000f130 <snprintf>:
    f130:	715d                	addi	sp,sp,-80
    f132:	f436                	sd	a3,40(sp)
    f134:	86b2                	mv	a3,a2
    f136:	862e                	mv	a2,a1
    f138:	85aa                	mv	a1,a0
    f13a:	651d                	lui	a0,0x7
    f13c:	fef1570b          	th.sdd	a4,a5,(sp),3,4
    f140:	0f050513          	addi	a0,a0,240 # 70f0 <_out_buffer>
    f144:	1038                	addi	a4,sp,40
    f146:	ec06                	sd	ra,24(sp)
    f148:	e0c2                	sd	a6,64(sp)
    f14a:	e4c6                	sd	a7,72(sp)
    f14c:	e43a                	sd	a4,8(sp)
    f14e:	a73f90ef          	jal	8bc0 <_vsnprintf>
    f152:	60e2                	ld	ra,24(sp)
    f154:	6161                	addi	sp,sp,80
    f156:	8082                	ret
    f158:	00000013          	nop
    f15c:	00000013          	nop

000000000000f160 <vprintf>:
    f160:	1101                	addi	sp,sp,-32
    f162:	86aa                	mv	a3,a0
    f164:	651d                	lui	a0,0x7
    f166:	872e                	mv	a4,a1
    f168:	567d                	li	a2,-1
    f16a:	002c                	addi	a1,sp,8
    f16c:	12050513          	addi	a0,a0,288 # 7120 <_out_char>
    f170:	ec06                	sd	ra,24(sp)
    f172:	a4ff90ef          	jal	8bc0 <_vsnprintf>
    f176:	60e2                	ld	ra,24(sp)
    f178:	6105                	addi	sp,sp,32
    f17a:	8082                	ret
    f17c:	00000013          	nop

000000000000f180 <vsnprintf>:
    f180:	8736                	mv	a4,a3
    f182:	86b2                	mv	a3,a2
    f184:	862e                	mv	a2,a1
    f186:	85aa                	mv	a1,a0
    f188:	651d                	lui	a0,0x7
    f18a:	0f050513          	addi	a0,a0,240 # 70f0 <_out_buffer>
    f18e:	a33f906f          	j	8bc0 <_vsnprintf>
    f192:	0001                	nop
    f194:	00000013          	nop
    f198:	00000013          	nop
    f19c:	00000013          	nop

000000000000f1a0 <fctprintf>:
    f1a0:	711d                	addi	sp,sp,-96
    f1a2:	fc36                	sd	a3,56(sp)
    f1a4:	e0ba                	sd	a4,64(sp)
    f1a6:	1838                	addi	a4,sp,56
    f1a8:	e43a                	sd	a4,8(sp)
    f1aa:	e82a                	sd	a0,16(sp)
    f1ac:	651d                	lui	a0,0x7
    f1ae:	ec2e                	sd	a1,24(sp)
    f1b0:	86b2                	mv	a3,a2
    f1b2:	080c                	addi	a1,sp,16
    f1b4:	567d                	li	a2,-1
    f1b6:	11050513          	addi	a0,a0,272 # 7110 <_out_fct>
    f1ba:	f406                	sd	ra,40(sp)
    f1bc:	e4be                	sd	a5,72(sp)
    f1be:	e8c2                	sd	a6,80(sp)
    f1c0:	ecc6                	sd	a7,88(sp)
    f1c2:	9fff90ef          	jal	8bc0 <_vsnprintf>
    f1c6:	70a2                	ld	ra,40(sp)
    f1c8:	6125                	addi	sp,sp,96
    f1ca:	8082                	ret
    f1cc:	0000                	unimp
	...

000000000000f1d0 <__thead_vprintfsprintf>:
    f1d0:	4501                	li	a0,0
    f1d2:	8082                	ret
    f1d4:	00000013          	nop
    f1d8:	00000013          	nop
    f1dc:	00000013          	nop

000000000000f1e0 <__thead_vprintfprintf>:
    f1e0:	4501                	li	a0,0
    f1e2:	8082                	ret
    f1e4:	00000013          	nop
    f1e8:	00000013          	nop
    f1ec:	00000013          	nop

000000000000f1f0 <stdout>:
    f1f0:	4501                	li	a0,0
    f1f2:	8082                	ret
	...

000000000000f200 <ck_uart_set_baudrate>:
    f200:	05f5e737          	lui	a4,0x5f5e
    f204:	1007029b          	addiw	t0,a4,256 # 5f5e100 <__kernel_stack+0x5e70100>
    f208:	02b2d33b          	divuw	t1,t0,a1
    f20c:	651c                	ld	a5,8(a0)
    f20e:	c90c                	sw	a1,16(a0)
    f210:	00c7c683          	lbu	a3,12(a5)
    f214:	0806e393          	ori	t2,a3,128
    f218:	00778623          	sb	t2,12(a5)
    f21c:	2c43350b          	th.extu	a0,t1,11,4
    f220:	00a78023          	sb	a0,0(a5)
    f224:	4cc3358b          	th.extu	a1,t1,19,12
    f228:	00b78223          	sb	a1,4(a5)
    f22c:	00c7c603          	lbu	a2,12(a5)
    f230:	07f67813          	andi	a6,a2,127
    f234:	01078623          	sb	a6,12(a5)
    f238:	8082                	ret
    f23a:	00000013          	nop
    f23e:	0001                	nop

000000000000f240 <ck_uart_set_parity>:
    f240:	4785                	li	a5,1
    f242:	c94c                	sw	a1,20(a0)
    f244:	04f58063          	beq	a1,a5,f284 <ck_uart_set_parity+0x44>
    f248:	4609                	li	a2,2
    f24a:	00c58d63          	beq	a1,a2,f264 <ck_uart_set_parity+0x24>
    f24e:	e995                	bnez	a1,f282 <ck_uart_set_parity+0x42>
    f250:	00853f83          	ld	t6,8(a0)
    f254:	00cfc783          	lbu	a5,12(t6)
    f258:	0f77f713          	andi	a4,a5,247
    f25c:	00ef8623          	sb	a4,12(t6)
    f260:	8082                	ret
    f262:	0001                	nop
    f264:	6514                	ld	a3,8(a0)
    f266:	00c6c803          	lbu	a6,12(a3)
    f26a:	00886893          	ori	a7,a6,8
    f26e:	01168623          	sb	a7,12(a3)
    f272:	00853e03          	ld	t3,8(a0)
    f276:	00ce4e83          	lbu	t4,12(t3)
    f27a:	010eef13          	ori	t5,t4,16
    f27e:	01ee0623          	sb	t5,12(t3)
    f282:	8082                	ret
    f284:	6518                	ld	a4,8(a0)
    f286:	00c74283          	lbu	t0,12(a4)
    f28a:	0082e313          	ori	t1,t0,8
    f28e:	00670623          	sb	t1,12(a4)
    f292:	00853383          	ld	t2,8(a0)
    f296:	00c3c503          	lbu	a0,12(t2)
    f29a:	0ef57593          	andi	a1,a0,239
    f29e:	00b38623          	sb	a1,12(t2)
    f2a2:	8082                	ret
    f2a4:	00000013          	nop
    f2a8:	00000013          	nop
    f2ac:	00000013          	nop

000000000000f2b0 <ck_uart_set_wordsize>:
    f2b0:	4789                	li	a5,2
    f2b2:	cd4c                	sw	a1,28(a0)
    f2b4:	04f58263          	beq	a1,a5,f2f8 <ck_uart_set_wordsize+0x48>
    f2b8:	02b7e463          	bltu	a5,a1,f2e0 <ck_uart_set_wordsize+0x30>
    f2bc:	cdb1                	beqz	a1,f318 <ck_uart_set_wordsize+0x68>
    f2be:	00853f83          	ld	t6,8(a0)
    f2c2:	00cfc783          	lbu	a5,12(t6)
    f2c6:	0fd7f713          	andi	a4,a5,253
    f2ca:	00ef8623          	sb	a4,12(t6)
    f2ce:	00853283          	ld	t0,8(a0)
    f2d2:	00c2c303          	lbu	t1,12(t0)
    f2d6:	00136393          	ori	t2,t1,1
    f2da:	00728623          	sb	t2,12(t0)
    f2de:	8082                	ret
    f2e0:	460d                	li	a2,3
    f2e2:	04c59563          	bne	a1,a2,f32c <ck_uart_set_wordsize+0x7c>
    f2e6:	6514                	ld	a3,8(a0)
    f2e8:	00c6c803          	lbu	a6,12(a3)
    f2ec:	00386893          	ori	a7,a6,3
    f2f0:	01168623          	sb	a7,12(a3)
    f2f4:	8082                	ret
    f2f6:	0001                	nop
    f2f8:	6518                	ld	a4,8(a0)
    f2fa:	00c74283          	lbu	t0,12(a4)
    f2fe:	0fe2f313          	andi	t1,t0,254
    f302:	00670623          	sb	t1,12(a4)
    f306:	00853383          	ld	t2,8(a0)
    f30a:	00c3c503          	lbu	a0,12(t2)
    f30e:	00256593          	ori	a1,a0,2
    f312:	00b38623          	sb	a1,12(t2)
    f316:	8082                	ret
    f318:	00853e03          	ld	t3,8(a0)
    f31c:	00ce4e83          	lbu	t4,12(t3)
    f320:	0fceff13          	andi	t5,t4,252
    f324:	01ee0623          	sb	t5,12(t3)
    f328:	8082                	ret
    f32a:	0001                	nop
    f32c:	8082                	ret
    f32e:	0001                	nop

000000000000f330 <ck_uart_set_stopbit>:
    f330:	cd0c                	sw	a1,24(a0)
    f332:	cd99                	beqz	a1,f350 <ck_uart_set_stopbit+0x20>
    f334:	4305                	li	t1,1
    f336:	00658363          	beq	a1,t1,f33c <ck_uart_set_stopbit+0xc>
    f33a:	8082                	ret
    f33c:	00853383          	ld	t2,8(a0)
    f340:	00c3c503          	lbu	a0,12(t2)
    f344:	00456593          	ori	a1,a0,4
    f348:	00b38623          	sb	a1,12(t2)
    f34c:	8082                	ret
    f34e:	0001                	nop
    f350:	6518                	ld	a4,8(a0)
    f352:	00c74783          	lbu	a5,12(a4)
    f356:	0fb7f293          	andi	t0,a5,251
    f35a:	00570623          	sb	t0,12(a4)
    f35e:	8082                	ret

000000000000f360 <ck_uart_set_rxmode>:
    f360:	d10c                	sw	a1,32(a0)
    f362:	8082                	ret
    f364:	00000013          	nop
    f368:	00000013          	nop
    f36c:	00000013          	nop

000000000000f370 <ck_uart_set_txmode>:
    f370:	d14c                	sw	a1,36(a0)
    f372:	8082                	ret
    f374:	00000013          	nop
    f378:	00000013          	nop
    f37c:	00000013          	nop

000000000000f380 <ck_uart_open>:
    f380:	e981                	bnez	a1,f390 <ck_uart_open+0x10>
    f382:	100157b7          	lui	a5,0x10015
    f386:	00052023          	sw	zero,0(a0)
    f38a:	e51c                	sd	a5,8(a0)
    f38c:	4501                	li	a0,0
    f38e:	8082                	ret
    f390:	4505                	li	a0,1
    f392:	8082                	ret
    f394:	00000013          	nop
    f398:	00000013          	nop
    f39c:	00000013          	nop

000000000000f3a0 <ck_uart_init>:
    f3a0:	4118                	lw	a4,0(a0)
    f3a2:	67c1                	lui	a5,0x10
    f3a4:	37fd                	addiw	a5,a5,-1 # ffff <_malloc_trim_r+0x35>
    f3a6:	0af70963          	beq	a4,a5,f458 <ck_uart_init+0xb8>
    f3aa:	4194                	lw	a3,0(a1)
    f3ac:	05f5e2b7          	lui	t0,0x5f5e
    f3b0:	1002831b          	addiw	t1,t0,256 # 5f5e100 <__kernel_stack+0x5e70100>
    f3b4:	02d353bb          	divuw	t2,t1,a3
    f3b8:	6510                	ld	a2,8(a0)
    f3ba:	c914                	sw	a3,16(a0)
    f3bc:	4705                	li	a4,1
    f3be:	00c64803          	lbu	a6,12(a2)
    f3c2:	08086893          	ori	a7,a6,128
    f3c6:	01160623          	sb	a7,12(a2)
    f3ca:	2c43be0b          	th.extu	t3,t2,11,4
    f3ce:	01c60023          	sb	t3,0(a2)
    f3d2:	4cc3be8b          	th.extu	t4,t2,19,12
    f3d6:	01d60223          	sb	t4,4(a2)
    f3da:	00c64f03          	lbu	t5,12(a2)
    f3de:	07ff7f93          	andi	t6,t5,127
    f3e2:	01f60623          	sb	t6,12(a2)
    f3e6:	459c                	lw	a5,8(a1)
    f3e8:	c95c                	sw	a5,20(a0)
    f3ea:	0ce78b63          	beq	a5,a4,f4c0 <ck_uart_init+0x120>
    f3ee:	4889                	li	a7,2
    f3f0:	11178e63          	beq	a5,a7,f50c <ck_uart_init+0x16c>
    f3f4:	c7a5                	beqz	a5,f45c <ck_uart_init+0xbc>
    f3f6:	45d0                	lw	a2,12(a1)
    f3f8:	4389                	li	t2,2
    f3fa:	cd50                	sw	a2,28(a0)
    f3fc:	06760d63          	beq	a2,t2,f476 <ck_uart_init+0xd6>
    f400:	0ec3ea63          	bltu	t2,a2,f4f4 <ck_uart_init+0x154>
    f404:	c265                	beqz	a2,f4e4 <ck_uart_init+0x144>
    f406:	00853803          	ld	a6,8(a0)
    f40a:	00c84883          	lbu	a7,12(a6)
    f40e:	0fd8fe13          	andi	t3,a7,253
    f412:	01c80623          	sb	t3,12(a6)
    f416:	00853e83          	ld	t4,8(a0)
    f41a:	00cecf03          	lbu	t5,12(t4)
    f41e:	001f6f93          	ori	t6,t5,1
    f422:	01fe8623          	sb	t6,12(t4)
    f426:	0045a283          	lw	t0,4(a1)
    f42a:	00552c23          	sw	t0,24(a0)
    f42e:	06028a63          	beqz	t0,f4a2 <ck_uart_init+0x102>
    f432:	4685                	li	a3,1
    f434:	00d29a63          	bne	t0,a3,f448 <ck_uart_init+0xa8>
    f438:	00853383          	ld	t2,8(a0)
    f43c:	00c3c603          	lbu	a2,12(t2)
    f440:	00466813          	ori	a6,a2,4
    f444:	01038623          	sb	a6,12(t2)
    f448:	0105a883          	lw	a7,16(a1)
    f44c:	49cc                	lw	a1,20(a1)
    f44e:	03152023          	sw	a7,32(a0)
    f452:	d14c                	sw	a1,36(a0)
    f454:	4501                	li	a0,0
    f456:	8082                	ret
    f458:	4505                	li	a0,1
    f45a:	8082                	ret
    f45c:	00853283          	ld	t0,8(a0)
    f460:	4389                	li	t2,2
    f462:	00c2c303          	lbu	t1,12(t0)
    f466:	0f737693          	andi	a3,t1,247
    f46a:	00d28623          	sb	a3,12(t0)
    f46e:	45d0                	lw	a2,12(a1)
    f470:	cd50                	sw	a2,28(a0)
    f472:	f87617e3          	bne	a2,t2,f400 <ck_uart_init+0x60>
    f476:	00853803          	ld	a6,8(a0)
    f47a:	00c84883          	lbu	a7,12(a6)
    f47e:	0fe8fe13          	andi	t3,a7,254
    f482:	01c80623          	sb	t3,12(a6)
    f486:	00853e83          	ld	t4,8(a0)
    f48a:	00cecf03          	lbu	t5,12(t4)
    f48e:	002f6f93          	ori	t6,t5,2
    f492:	01fe8623          	sb	t6,12(t4)
    f496:	0045a283          	lw	t0,4(a1)
    f49a:	00552c23          	sw	t0,24(a0)
    f49e:	f8029ae3          	bnez	t0,f432 <ck_uart_init+0x92>
    f4a2:	6518                	ld	a4,8(a0)
    f4a4:	00c74783          	lbu	a5,12(a4)
    f4a8:	0fb7f313          	andi	t1,a5,251
    f4ac:	00670623          	sb	t1,12(a4)
    f4b0:	0105a883          	lw	a7,16(a1)
    f4b4:	49cc                	lw	a1,20(a1)
    f4b6:	03152023          	sw	a7,32(a0)
    f4ba:	d14c                	sw	a1,36(a0)
    f4bc:	4501                	li	a0,0
    f4be:	8082                	ret
    f4c0:	00853283          	ld	t0,8(a0)
    f4c4:	00c2c303          	lbu	t1,12(t0)
    f4c8:	00836693          	ori	a3,t1,8
    f4cc:	00d28623          	sb	a3,12(t0)
    f4d0:	00853383          	ld	t2,8(a0)
    f4d4:	00c3c603          	lbu	a2,12(t2)
    f4d8:	0ef67813          	andi	a6,a2,239
    f4dc:	01038623          	sb	a6,12(t2)
    f4e0:	bf19                	j	f3f6 <ck_uart_init+0x56>
    f4e2:	0001                	nop
    f4e4:	6514                	ld	a3,8(a0)
    f4e6:	00c6c383          	lbu	t2,12(a3)
    f4ea:	0fc3f613          	andi	a2,t2,252
    f4ee:	00c68623          	sb	a2,12(a3)
    f4f2:	bf15                	j	f426 <ck_uart_init+0x86>
    f4f4:	470d                	li	a4,3
    f4f6:	f2e618e3          	bne	a2,a4,f426 <ck_uart_init+0x86>
    f4fa:	00853283          	ld	t0,8(a0)
    f4fe:	00c2c783          	lbu	a5,12(t0)
    f502:	0037e313          	ori	t1,a5,3
    f506:	00628623          	sb	t1,12(t0)
    f50a:	bf31                	j	f426 <ck_uart_init+0x86>
    f50c:	00853e03          	ld	t3,8(a0)
    f510:	00ce4e83          	lbu	t4,12(t3)
    f514:	008eef13          	ori	t5,t4,8
    f518:	01ee0623          	sb	t5,12(t3)
    f51c:	00853f83          	ld	t6,8(a0)
    f520:	00cfc703          	lbu	a4,12(t6)
    f524:	01076793          	ori	a5,a4,16
    f528:	00ff8623          	sb	a5,12(t6)
    f52c:	b5e9                	j	f3f6 <ck_uart_init+0x56>
    f52e:	0001                	nop

000000000000f530 <ck_uart_close>:
    f530:	67c1                	lui	a5,0x10
    f532:	37fd                	addiw	a5,a5,-1 # ffff <_malloc_trim_r+0x35>
    f534:	c11c                	sw	a5,0(a0)
    f536:	02053023          	sd	zero,32(a0)
    f53a:	4501                	li	a0,0
    f53c:	8082                	ret
    f53e:	0001                	nop

000000000000f540 <ck_uart_putc>:
    f540:	515c                	lw	a5,36(a0)
    f542:	c7ad                	beqz	a5,f5ac <ck_uart_putc+0x6c>
    f544:	00853283          	ld	t0,8(a0)
    f548:	0142c703          	lbu	a4,20(t0)
    f54c:	02077313          	andi	t1,a4,32
    f550:	04031963          	bnez	t1,f5a2 <ck_uart_putc+0x62>
    f554:	0142c383          	lbu	t2,20(t0)
    f558:	0203f513          	andi	a0,t2,32
    f55c:	e139                	bnez	a0,f5a2 <ck_uart_putc+0x62>
    f55e:	0142c603          	lbu	a2,20(t0)
    f562:	02067693          	andi	a3,a2,32
    f566:	ee95                	bnez	a3,f5a2 <ck_uart_putc+0x62>
    f568:	0142c803          	lbu	a6,20(t0)
    f56c:	02087893          	andi	a7,a6,32
    f570:	02089963          	bnez	a7,f5a2 <ck_uart_putc+0x62>
    f574:	0142ce03          	lbu	t3,20(t0)
    f578:	020e7e93          	andi	t4,t3,32
    f57c:	020e9363          	bnez	t4,f5a2 <ck_uart_putc+0x62>
    f580:	0142cf03          	lbu	t5,20(t0)
    f584:	020f7f93          	andi	t6,t5,32
    f588:	000f9d63          	bnez	t6,f5a2 <ck_uart_putc+0x62>
    f58c:	0142c783          	lbu	a5,20(t0)
    f590:	0207f713          	andi	a4,a5,32
    f594:	e719                	bnez	a4,f5a2 <ck_uart_putc+0x62>
    f596:	0142c303          	lbu	t1,20(t0)
    f59a:	02037393          	andi	t2,t1,32
    f59e:	fa0385e3          	beqz	t2,f548 <ck_uart_putc+0x8>
    f5a2:	00b28023          	sb	a1,0(t0)
    f5a6:	4501                	li	a0,0
    f5a8:	8082                	ret
    f5aa:	0001                	nop
    f5ac:	4505                	li	a0,1
    f5ae:	8082                	ret

000000000000f5b0 <ck_uart_status>:
    f5b0:	4505                	li	a0,1
    f5b2:	8082                	ret
	...

000000000000f5c0 <vasprintf>:
    f5c0:	7139                	addi	sp,sp,-64
    f5c2:	f9515b0b          	th.sdd	s6,s5,(sp),0,4
    f5c6:	8b2a                	mv	s6,a0
    f5c8:	852e                	mv	a0,a1
    f5ca:	fb315a0b          	th.sdd	s4,s3,(sp),1,4
    f5ce:	fc91590b          	th.sdd	s2,s1,(sp),2,4
    f5d2:	fe11540b          	th.sdd	s0,ra,(sp),3,4
    f5d6:	8a2e                	mv	s4,a1
    f5d8:	8ab2                	mv	s5,a2
    f5da:	157000ef          	jal	ff30 <strlen>
    f5de:	00150993          	addi	s3,a0,1
    f5e2:	f009f293          	andi	t0,s3,-256
    f5e6:	10028913          	addi	s2,t0,256
    f5ea:	20028993          	addi	s3,t0,512
    f5ee:	000b3023          	sd	zero,0(s6)
    f5f2:	0001                	nop
    f5f4:	00000013          	nop
    f5f8:	854a                	mv	a0,s2
    f5fa:	228000ef          	jal	f822 <malloc>
    f5fe:	84aa                	mv	s1,a0
    f600:	c525                	beqz	a0,f668 <vasprintf+0xa8>
    f602:	86d6                	mv	a3,s5
    f604:	8652                	mv	a2,s4
    f606:	85ca                	mv	a1,s2
    f608:	b79ff0ef          	jal	f180 <vsnprintf>
    f60c:	842a                	mv	s0,a0
    f60e:	00054f63          	bltz	a0,f62c <vasprintf+0x6c>
    f612:	197d                	addi	s2,s2,-1
    f614:	03256463          	bltu	a0,s2,f63c <vasprintf+0x7c>
    f618:	8526                	mv	a0,s1
    f61a:	214000ef          	jal	f82e <free>
    f61e:	01346a63          	bltu	s0,s3,f632 <vasprintf+0x72>
    f622:	0014091b          	addiw	s2,s0,1
    f626:	10098993          	addi	s3,s3,256
    f62a:	b7f9                	j	f5f8 <vasprintf+0x38>
    f62c:	8526                	mv	a0,s1
    f62e:	200000ef          	jal	f82e <free>
    f632:	894e                	mv	s2,s3
    f634:	10098993          	addi	s3,s3,256
    f638:	b7c1                	j	f5f8 <vasprintf+0x38>
    f63a:	0001                	nop
    f63c:	ed01                	bnez	a0,f654 <vasprintf+0x94>
    f63e:	8522                	mv	a0,s0
    f640:	fe11440b          	th.ldd	s0,ra,(sp),3,4
    f644:	fc91490b          	th.ldd	s2,s1,(sp),2,4
    f648:	fb314a0b          	th.ldd	s4,s3,(sp),1,4
    f64c:	f9514b0b          	th.ldd	s6,s5,(sp),0,4
    f650:	6121                	addi	sp,sp,64
    f652:	8082                	ret
    f654:	8526                	mv	a0,s1
    f656:	095000ef          	jal	feea <strdup>
    f65a:	c909                	beqz	a0,f66c <vasprintf+0xac>
    f65c:	00ab3023          	sd	a0,0(s6)
    f660:	8526                	mv	a0,s1
    f662:	1cc000ef          	jal	f82e <free>
    f666:	bfe1                	j	f63e <vasprintf+0x7e>
    f668:	5451                	li	s0,-12
    f66a:	bfd1                	j	f63e <vasprintf+0x7e>
    f66c:	009b3023          	sd	s1,0(s6)
    f670:	b7f9                	j	f63e <vasprintf+0x7e>
    f672:	0001                	nop
    f674:	00000013          	nop
    f678:	00000013          	nop
    f67c:	00000013          	nop

000000000000f680 <asprintf>:
    f680:	7119                	addi	sp,sp,-128
    f682:	fb515b0b          	th.sdd	s6,s5,(sp),1,4
    f686:	8b2a                	mv	s6,a0
    f688:	05010a93          	addi	s5,sp,80
    f68c:	852e                	mv	a0,a1
    f68e:	fd315a0b          	th.sdd	s4,s3,(sp),2,4
    f692:	fe91590b          	th.sdd	s2,s1,(sp),3,4
    f696:	e0a2                	sd	s0,64(sp)
    f698:	e486                	sd	ra,72(sp)
    f69a:	e8b2                	sd	a2,80(sp)
    f69c:	ecb6                	sd	a3,88(sp)
    f69e:	f0ba                	sd	a4,96(sp)
    f6a0:	f4be                	sd	a5,104(sp)
    f6a2:	f8c2                	sd	a6,112(sp)
    f6a4:	fcc6                	sd	a7,120(sp)
    f6a6:	8a2e                	mv	s4,a1
    f6a8:	e456                	sd	s5,8(sp)
    f6aa:	087000ef          	jal	ff30 <strlen>
    f6ae:	00150993          	addi	s3,a0,1
    f6b2:	f009f293          	andi	t0,s3,-256
    f6b6:	10028913          	addi	s2,t0,256
    f6ba:	20028993          	addi	s3,t0,512
    f6be:	000b3023          	sd	zero,0(s6)
    f6c2:	0001                	nop
    f6c4:	00000013          	nop
    f6c8:	854a                	mv	a0,s2
    f6ca:	158000ef          	jal	f822 <malloc>
    f6ce:	84aa                	mv	s1,a0
    f6d0:	c525                	beqz	a0,f738 <asprintf+0xb8>
    f6d2:	86d6                	mv	a3,s5
    f6d4:	8652                	mv	a2,s4
    f6d6:	85ca                	mv	a1,s2
    f6d8:	aa9ff0ef          	jal	f180 <vsnprintf>
    f6dc:	842a                	mv	s0,a0
    f6de:	00054f63          	bltz	a0,f6fc <asprintf+0x7c>
    f6e2:	197d                	addi	s2,s2,-1
    f6e4:	03256463          	bltu	a0,s2,f70c <asprintf+0x8c>
    f6e8:	8526                	mv	a0,s1
    f6ea:	144000ef          	jal	f82e <free>
    f6ee:	01346a63          	bltu	s0,s3,f702 <asprintf+0x82>
    f6f2:	0014091b          	addiw	s2,s0,1
    f6f6:	10098993          	addi	s3,s3,256
    f6fa:	b7f9                	j	f6c8 <asprintf+0x48>
    f6fc:	8526                	mv	a0,s1
    f6fe:	130000ef          	jal	f82e <free>
    f702:	894e                	mv	s2,s3
    f704:	10098993          	addi	s3,s3,256
    f708:	b7c1                	j	f6c8 <asprintf+0x48>
    f70a:	0001                	nop
    f70c:	ed01                	bnez	a0,f724 <asprintf+0xa4>
    f70e:	8522                	mv	a0,s0
    f710:	6406                	ld	s0,64(sp)
    f712:	60a6                	ld	ra,72(sp)
    f714:	fe91490b          	th.ldd	s2,s1,(sp),3,4
    f718:	fd314a0b          	th.ldd	s4,s3,(sp),2,4
    f71c:	fb514b0b          	th.ldd	s6,s5,(sp),1,4
    f720:	6109                	addi	sp,sp,128
    f722:	8082                	ret
    f724:	8526                	mv	a0,s1
    f726:	7c4000ef          	jal	feea <strdup>
    f72a:	c909                	beqz	a0,f73c <asprintf+0xbc>
    f72c:	00ab3023          	sd	a0,0(s6)
    f730:	8526                	mv	a0,s1
    f732:	0fc000ef          	jal	f82e <free>
    f736:	bfe1                	j	f70e <asprintf+0x8e>
    f738:	5451                	li	s0,-12
    f73a:	bfd1                	j	f70e <asprintf+0x8e>
    f73c:	009b3023          	sd	s1,0(s6)
    f740:	b7f9                	j	f70e <asprintf+0x8e>
	...

000000000000f750 <get_vtimer>:
    f750:	1141                	addi	sp,sp,-16
    f752:	c01027f3          	rdtime	a5
    f756:	c63e                	sw	a5,12(sp)
    f758:	4532                	lw	a0,12(sp)
    f75a:	0141                	addi	sp,sp,16
    f75c:	8082                	ret
    f75e:	0001                	nop

000000000000f760 <sim_end>:
    f760:	050017b7          	lui	a5,0x5001
    f764:	44333737          	lui	a4,0x44333
    f768:	00579293          	slli	t0,a5,0x5
    f76c:	22270313          	addi	t1,a4,546 # 44333222 <__kernel_stack+0x44245222>
    f770:	f462a423          	sw	t1,-184(t0)
    f774:	8082                	ret

000000000000f776 <modf>:
    f776:	e20507d3          	fmv.x.d	a5,fa0
    f77a:	484d                	li	a6,19
    f77c:	4347d713          	srai	a4,a5,0x34
    f780:	7ff77713          	andi	a4,a4,2047
    f784:	c017061b          	addiw	a2,a4,-1023
    f788:	0007869b          	sext.w	a3,a5
    f78c:	4207d593          	srai	a1,a5,0x20
    f790:	02c84663          	blt	a6,a2,f7bc <modf+0x46>
    f794:	06064f63          	bltz	a2,f812 <modf+0x9c>
    f798:	00100737          	lui	a4,0x100
    f79c:	377d                	addiw	a4,a4,-1 # fffff <__kernel_stack+0x11fff>
    f79e:	40c7573b          	sraw	a4,a4,a2
    f7a2:	00e5f633          	and	a2,a1,a4
    f7a6:	8ed1                	or	a3,a3,a2
    f7a8:	e6b9                	bnez	a3,f7f6 <modf+0x80>
    f7aa:	4705                	li	a4,1
    f7ac:	077e                	slli	a4,a4,0x1f
    f7ae:	8f6d                	and	a4,a4,a1
    f7b0:	e11c                	sd	a5,0(a0)
    f7b2:	02071793          	slli	a5,a4,0x20
    f7b6:	f2078553          	fmv.d.x	fa0,a5
    f7ba:	8082                	ret
    f7bc:	03300813          	li	a6,51
    f7c0:	fec845e3          	blt	a6,a2,f7aa <modf+0x34>
    f7c4:	567d                	li	a2,-1
    f7c6:	bed7071b          	addiw	a4,a4,-1043
    f7ca:	00e6573b          	srlw	a4,a2,a4
    f7ce:	00d77633          	and	a2,a4,a3
    f7d2:	de61                	beqz	a2,f7aa <modf+0x34>
    f7d4:	fff74713          	not	a4,a4
    f7d8:	8ef9                	and	a3,a3,a4
    f7da:	1682                	slli	a3,a3,0x20
    f7dc:	9281                	srli	a3,a3,0x20
    f7de:	1582                	slli	a1,a1,0x20
    f7e0:	8dd5                	or	a1,a1,a3
    f7e2:	f2058753          	fmv.d.x	fa4,a1
    f7e6:	e10c                	sd	a1,0(a0)
    f7e8:	0ae577d3          	fsub.d	fa5,fa0,fa4
    f7ec:	e20787d3          	fmv.x.d	a5,fa5
    f7f0:	f2078553          	fmv.d.x	fa0,a5
    f7f4:	8082                	ret
    f7f6:	fff74713          	not	a4,a4
    f7fa:	8f6d                	and	a4,a4,a1
    f7fc:	1702                	slli	a4,a4,0x20
    f7fe:	f2070753          	fmv.d.x	fa4,a4
    f802:	e118                	sd	a4,0(a0)
    f804:	0ae577d3          	fsub.d	fa5,fa0,fa4
    f808:	e20787d3          	fmv.x.d	a5,fa5
    f80c:	f2078553          	fmv.d.x	fa0,a5
    f810:	8082                	ret
    f812:	4705                	li	a4,1
    f814:	077e                	slli	a4,a4,0x1f
    f816:	8f6d                	and	a4,a4,a1
    f818:	1702                	slli	a4,a4,0x20
    f81a:	f2078553          	fmv.d.x	fa0,a5
    f81e:	e118                	sd	a4,0(a0)
    f820:	8082                	ret

000000000000f822 <malloc>:
    f822:	85aa                	mv	a1,a0
    f824:	00031517          	auipc	a0,0x31
    f828:	78c53503          	ld	a0,1932(a0) # 40fb0 <_impure_ptr>
    f82c:	a801                	j	f83c <_malloc_r>

000000000000f82e <free>:
    f82e:	85aa                	mv	a1,a0
    f830:	00031517          	auipc	a0,0x31
    f834:	78053503          	ld	a0,1920(a0) # 40fb0 <_impure_ptr>
    f838:	0710006f          	j	100a8 <_free_r>

000000000000f83c <_malloc_r>:
    f83c:	711d                	addi	sp,sp,-96
    f83e:	e4a6                	sd	s1,72(sp)
    f840:	e0ca                	sd	s2,64(sp)
    f842:	ec86                	sd	ra,88(sp)
    f844:	e8a2                	sd	s0,80(sp)
    f846:	fc4e                	sd	s3,56(sp)
    f848:	01758493          	addi	s1,a1,23
    f84c:	02e00793          	li	a5,46
    f850:	892a                	mv	s2,a0
    f852:	0497ec63          	bltu	a5,s1,f8aa <_malloc_r+0x6e>
    f856:	02000493          	li	s1,32
    f85a:	18b4eb63          	bltu	s1,a1,f9f0 <_malloc_r+0x1b4>
    f85e:	63c000ef          	jal	fe9a <__malloc_lock>
    f862:	05000793          	li	a5,80
    f866:	4591                	li	a1,4
    f868:	00030997          	auipc	s3,0x30
    f86c:	7c898993          	addi	s3,s3,1992 # 40030 <__malloc_av_>
    f870:	97ce                	add	a5,a5,s3
    f872:	6780                	ld	s0,8(a5)
    f874:	ff078713          	addi	a4,a5,-16 # 5000ff0 <__kernel_stack+0x4f12ff0>
    f878:	34e40b63          	beq	s0,a4,fbce <_malloc_r+0x392>
    f87c:	641c                	ld	a5,8(s0)
    f87e:	6c14                	ld	a3,24(s0)
    f880:	6810                	ld	a2,16(s0)
    f882:	9bf1                	andi	a5,a5,-4
    f884:	97a2                	add	a5,a5,s0
    f886:	6798                	ld	a4,8(a5)
    f888:	ee14                	sd	a3,24(a2)
    f88a:	ea90                	sd	a2,16(a3)
    f88c:	00176713          	ori	a4,a4,1
    f890:	854a                	mv	a0,s2
    f892:	e798                	sd	a4,8(a5)
    f894:	612000ef          	jal	fea6 <__malloc_unlock>
    f898:	60e6                	ld	ra,88(sp)
    f89a:	01040513          	addi	a0,s0,16
    f89e:	6446                	ld	s0,80(sp)
    f8a0:	64a6                	ld	s1,72(sp)
    f8a2:	6906                	ld	s2,64(sp)
    f8a4:	79e2                	ld	s3,56(sp)
    f8a6:	6125                	addi	sp,sp,96
    f8a8:	8082                	ret
    f8aa:	800007b7          	lui	a5,0x80000
    f8ae:	98c1                	andi	s1,s1,-16
    f8b0:	fff7c793          	not	a5,a5
    f8b4:	1297ee63          	bltu	a5,s1,f9f0 <_malloc_r+0x1b4>
    f8b8:	12b4ec63          	bltu	s1,a1,f9f0 <_malloc_r+0x1b4>
    f8bc:	5de000ef          	jal	fe9a <__malloc_lock>
    f8c0:	1f700793          	li	a5,503
    f8c4:	4097f063          	bgeu	a5,s1,fcc4 <_malloc_r+0x488>
    f8c8:	0094d793          	srli	a5,s1,0x9
    f8cc:	12078d63          	beqz	a5,fa06 <_malloc_r+0x1ca>
    f8d0:	4711                	li	a4,4
    f8d2:	34f76563          	bltu	a4,a5,fc1c <_malloc_r+0x3e0>
    f8d6:	0064d793          	srli	a5,s1,0x6
    f8da:	0397859b          	addiw	a1,a5,57 # ffffffff80000039 <__kernel_stack+0xffffffff7ff12039>
    f8de:	0015961b          	slliw	a2,a1,0x1
    f8e2:	0387881b          	addiw	a6,a5,56
    f8e6:	060e                	slli	a2,a2,0x3
    f8e8:	00030997          	auipc	s3,0x30
    f8ec:	74898993          	addi	s3,s3,1864 # 40030 <__malloc_av_>
    f8f0:	964e                	add	a2,a2,s3
    f8f2:	6600                	ld	s0,8(a2)
    f8f4:	1641                	addi	a2,a2,-16
    f8f6:	02860163          	beq	a2,s0,f918 <_malloc_r+0xdc>
    f8fa:	457d                	li	a0,31
    f8fc:	a039                	j	f90a <_malloc_r+0xce>
    f8fe:	6c14                	ld	a3,24(s0)
    f900:	2a075363          	bgez	a4,fba6 <_malloc_r+0x36a>
    f904:	00d60a63          	beq	a2,a3,f918 <_malloc_r+0xdc>
    f908:	8436                	mv	s0,a3
    f90a:	641c                	ld	a5,8(s0)
    f90c:	9bf1                	andi	a5,a5,-4
    f90e:	40978733          	sub	a4,a5,s1
    f912:	fee556e3          	bge	a0,a4,f8fe <_malloc_r+0xc2>
    f916:	85c2                	mv	a1,a6
    f918:	0209b403          	ld	s0,32(s3)
    f91c:	00030897          	auipc	a7,0x30
    f920:	72488893          	addi	a7,a7,1828 # 40040 <__malloc_av_+0x10>
    f924:	27140e63          	beq	s0,a7,fba0 <_malloc_r+0x364>
    f928:	641c                	ld	a5,8(s0)
    f92a:	46fd                	li	a3,31
    f92c:	9bf1                	andi	a5,a5,-4
    f92e:	40978733          	sub	a4,a5,s1
    f932:	36e6c263          	blt	a3,a4,fc96 <_malloc_r+0x45a>
    f936:	0319b423          	sd	a7,40(s3)
    f93a:	0319b023          	sd	a7,32(s3)
    f93e:	34075163          	bgez	a4,fc80 <_malloc_r+0x444>
    f942:	1ff00713          	li	a4,511
    f946:	0089b503          	ld	a0,8(s3)
    f94a:	28f76763          	bltu	a4,a5,fbd8 <_malloc_r+0x39c>
    f94e:	838d                	srli	a5,a5,0x3
    f950:	2781                	sext.w	a5,a5
    f952:	0017871b          	addiw	a4,a5,1
    f956:	0017171b          	slliw	a4,a4,0x1
    f95a:	070e                	slli	a4,a4,0x3
    f95c:	974e                	add	a4,a4,s3
    f95e:	6310                	ld	a2,0(a4)
    f960:	4027d79b          	sraiw	a5,a5,0x2
    f964:	4685                	li	a3,1
    f966:	00f697b3          	sll	a5,a3,a5
    f96a:	8d5d                	or	a0,a0,a5
    f96c:	ff070793          	addi	a5,a4,-16
    f970:	e810                	sd	a2,16(s0)
    f972:	ec1c                	sd	a5,24(s0)
    f974:	00a9b423          	sd	a0,8(s3)
    f978:	e300                	sd	s0,0(a4)
    f97a:	ee00                	sd	s0,24(a2)
    f97c:	4025d79b          	sraiw	a5,a1,0x2
    f980:	4605                	li	a2,1
    f982:	00f61633          	sll	a2,a2,a5
    f986:	08c56763          	bltu	a0,a2,fa14 <_malloc_r+0x1d8>
    f98a:	00a677b3          	and	a5,a2,a0
    f98e:	ef81                	bnez	a5,f9a6 <_malloc_r+0x16a>
    f990:	0606                	slli	a2,a2,0x1
    f992:	99f1                	andi	a1,a1,-4
    f994:	00a677b3          	and	a5,a2,a0
    f998:	2591                	addiw	a1,a1,4
    f99a:	e791                	bnez	a5,f9a6 <_malloc_r+0x16a>
    f99c:	0606                	slli	a2,a2,0x1
    f99e:	00a677b3          	and	a5,a2,a0
    f9a2:	2591                	addiw	a1,a1,4
    f9a4:	dfe5                	beqz	a5,f99c <_malloc_r+0x160>
    f9a6:	487d                	li	a6,31
    f9a8:	0015831b          	addiw	t1,a1,1
    f9ac:	0013131b          	slliw	t1,t1,0x1
    f9b0:	030e                	slli	t1,t1,0x3
    f9b2:	1341                	addi	t1,t1,-16
    f9b4:	934e                	add	t1,t1,s3
    f9b6:	851a                	mv	a0,t1
    f9b8:	6d1c                	ld	a5,24(a0)
    f9ba:	8e2e                	mv	t3,a1
    f9bc:	28f50163          	beq	a0,a5,fc3e <_malloc_r+0x402>
    f9c0:	6798                	ld	a4,8(a5)
    f9c2:	843e                	mv	s0,a5
    f9c4:	6f9c                	ld	a5,24(a5)
    f9c6:	9b71                	andi	a4,a4,-4
    f9c8:	409706b3          	sub	a3,a4,s1
    f9cc:	28d84063          	blt	a6,a3,fc4c <_malloc_r+0x410>
    f9d0:	fe06c6e3          	bltz	a3,f9bc <_malloc_r+0x180>
    f9d4:	9722                	add	a4,a4,s0
    f9d6:	6714                	ld	a3,8(a4)
    f9d8:	6810                	ld	a2,16(s0)
    f9da:	854a                	mv	a0,s2
    f9dc:	0016e693          	ori	a3,a3,1
    f9e0:	e714                	sd	a3,8(a4)
    f9e2:	ee1c                	sd	a5,24(a2)
    f9e4:	eb90                	sd	a2,16(a5)
    f9e6:	4c0000ef          	jal	fea6 <__malloc_unlock>
    f9ea:	01040513          	addi	a0,s0,16
    f9ee:	a029                	j	f9f8 <_malloc_r+0x1bc>
    f9f0:	47b1                	li	a5,12
    f9f2:	00f92023          	sw	a5,0(s2)
    f9f6:	4501                	li	a0,0
    f9f8:	60e6                	ld	ra,88(sp)
    f9fa:	6446                	ld	s0,80(sp)
    f9fc:	64a6                	ld	s1,72(sp)
    f9fe:	6906                	ld	s2,64(sp)
    fa00:	79e2                	ld	s3,56(sp)
    fa02:	6125                	addi	sp,sp,96
    fa04:	8082                	ret
    fa06:	40000613          	li	a2,1024
    fa0a:	04000593          	li	a1,64
    fa0e:	03f00813          	li	a6,63
    fa12:	bdd9                	j	f8e8 <_malloc_r+0xac>
    fa14:	0109b403          	ld	s0,16(s3)
    fa18:	f456                	sd	s5,40(sp)
    fa1a:	641c                	ld	a5,8(s0)
    fa1c:	ffc7fa93          	andi	s5,a5,-4
    fa20:	009ae763          	bltu	s5,s1,fa2e <_malloc_r+0x1f2>
    fa24:	409a8733          	sub	a4,s5,s1
    fa28:	47fd                	li	a5,31
    fa2a:	14e7c563          	blt	a5,a4,fb74 <_malloc_r+0x338>
    fa2e:	e862                	sd	s8,16(sp)
    fa30:	00031c17          	auipc	s8,0x31
    fa34:	570c0c13          	addi	s8,s8,1392 # 40fa0 <__malloc_sbrk_base>
    fa38:	f852                	sd	s4,48(sp)
    fa3a:	000c3703          	ld	a4,0(s8)
    fa3e:	00031a17          	auipc	s4,0x31
    fa42:	62aa3a03          	ld	s4,1578(s4) # 41068 <__malloc_top_pad>
    fa46:	ec5e                	sd	s7,24(sp)
    fa48:	f05a                	sd	s6,32(sp)
    fa4a:	57fd                	li	a5,-1
    fa4c:	01540bb3          	add	s7,s0,s5
    fa50:	9a26                	add	s4,s4,s1
    fa52:	2ef70f63          	beq	a4,a5,fd50 <_malloc_r+0x514>
    fa56:	6785                	lui	a5,0x1
    fa58:	07fd                	addi	a5,a5,31 # 101f <core_bench_list+0x6ef>
    fa5a:	9a3e                	add	s4,s4,a5
    fa5c:	77fd                	lui	a5,0xfffff
    fa5e:	00fa7a33          	and	s4,s4,a5
    fa62:	85d2                	mv	a1,s4
    fa64:	854a                	mv	a0,s2
    fa66:	44c000ef          	jal	feb2 <_sbrk_r>
    fa6a:	57fd                	li	a5,-1
    fa6c:	8b2a                	mv	s6,a0
    fa6e:	38f50363          	beq	a0,a5,fdf4 <_malloc_r+0x5b8>
    fa72:	e466                	sd	s9,8(sp)
    fa74:	0d756e63          	bltu	a0,s7,fb50 <_malloc_r+0x314>
    fa78:	00031717          	auipc	a4,0x31
    fa7c:	5b872703          	lw	a4,1464(a4) # 41030 <__malloc_current_mallinfo>
    fa80:	00031c97          	auipc	s9,0x31
    fa84:	5b0c8c93          	addi	s9,s9,1456 # 41030 <__malloc_current_mallinfo>
    fa88:	0147073b          	addw	a4,a4,s4
    fa8c:	00eca023          	sw	a4,0(s9)
    fa90:	86ba                	mv	a3,a4
    fa92:	36ab8563          	beq	s7,a0,fdfc <_malloc_r+0x5c0>
    fa96:	000c3703          	ld	a4,0(s8)
    fa9a:	57fd                	li	a5,-1
    fa9c:	36f70d63          	beq	a4,a5,fe16 <_malloc_r+0x5da>
    faa0:	417b07b3          	sub	a5,s6,s7
    faa4:	9fb5                	addw	a5,a5,a3
    faa6:	00fca023          	sw	a5,0(s9)
    faaa:	00fb7c13          	andi	s8,s6,15
    faae:	2a0c0d63          	beqz	s8,fd68 <_malloc_r+0x52c>
    fab2:	418b0b33          	sub	s6,s6,s8
    fab6:	6685                	lui	a3,0x1
    fab8:	0b41                	addi	s6,s6,16
    faba:	06c1                	addi	a3,a3,16 # 1010 <core_bench_list+0x6e0>
    fabc:	9a5a                	add	s4,s4,s6
    fabe:	418686b3          	sub	a3,a3,s8
    fac2:	414686b3          	sub	a3,a3,s4
    fac6:	16d2                	slli	a3,a3,0x34
    fac8:	0346db93          	srli	s7,a3,0x34
    facc:	85de                	mv	a1,s7
    face:	854a                	mv	a0,s2
    fad0:	3e2000ef          	jal	feb2 <_sbrk_r>
    fad4:	57fd                	li	a5,-1
    fad6:	36f50f63          	beq	a0,a5,fe54 <_malloc_r+0x618>
    fada:	41650533          	sub	a0,a0,s6
    fade:	01750a33          	add	s4,a0,s7
    fae2:	000b869b          	sext.w	a3,s7
    fae6:	00031717          	auipc	a4,0x31
    faea:	54a72703          	lw	a4,1354(a4) # 41030 <__malloc_current_mallinfo>
    faee:	0169b823          	sd	s6,16(s3)
    faf2:	001a6793          	ori	a5,s4,1
    faf6:	9f35                	addw	a4,a4,a3
    faf8:	00fb3423          	sd	a5,8(s6)
    fafc:	00eca023          	sw	a4,0(s9)
    fb00:	03340563          	beq	s0,s3,fb2a <_malloc_r+0x2ee>
    fb04:	467d                	li	a2,31
    fb06:	29567163          	bgeu	a2,s5,fd88 <_malloc_r+0x54c>
    fb0a:	6414                	ld	a3,8(s0)
    fb0c:	fe8a8793          	addi	a5,s5,-24
    fb10:	9bc1                	andi	a5,a5,-16
    fb12:	8a85                	andi	a3,a3,1
    fb14:	8edd                	or	a3,a3,a5
    fb16:	e414                	sd	a3,8(s0)
    fb18:	45a5                	li	a1,9
    fb1a:	00f406b3          	add	a3,s0,a5
    fb1e:	e68c                	sd	a1,8(a3)
    fb20:	ea8c                	sd	a1,16(a3)
    fb22:	20f66b63          	bltu	a2,a5,fd38 <_malloc_r+0x4fc>
    fb26:	008b3783          	ld	a5,8(s6)
    fb2a:	00031697          	auipc	a3,0x31
    fb2e:	53668693          	addi	a3,a3,1334 # 41060 <__malloc_max_sbrked_mem>
    fb32:	6290                	ld	a2,0(a3)
    fb34:	00e67363          	bgeu	a2,a4,fb3a <_malloc_r+0x2fe>
    fb38:	e298                	sd	a4,0(a3)
    fb3a:	00031697          	auipc	a3,0x31
    fb3e:	51e68693          	addi	a3,a3,1310 # 41058 <__malloc_max_total_mem>
    fb42:	6290                	ld	a2,0(a3)
    fb44:	00e67363          	bgeu	a2,a4,fb4a <_malloc_r+0x30e>
    fb48:	e298                	sd	a4,0(a3)
    fb4a:	6ca2                	ld	s9,8(sp)
    fb4c:	845a                	mv	s0,s6
    fb4e:	a039                	j	fb5c <_malloc_r+0x320>
    fb50:	29340563          	beq	s0,s3,fdda <_malloc_r+0x59e>
    fb54:	0109b403          	ld	s0,16(s3)
    fb58:	6ca2                	ld	s9,8(sp)
    fb5a:	641c                	ld	a5,8(s0)
    fb5c:	9bf1                	andi	a5,a5,-4
    fb5e:	40978733          	sub	a4,a5,s1
    fb62:	2297e763          	bltu	a5,s1,fd90 <_malloc_r+0x554>
    fb66:	47fd                	li	a5,31
    fb68:	22e7d463          	bge	a5,a4,fd90 <_malloc_r+0x554>
    fb6c:	7a42                	ld	s4,48(sp)
    fb6e:	7b02                	ld	s6,32(sp)
    fb70:	6be2                	ld	s7,24(sp)
    fb72:	6c42                	ld	s8,16(sp)
    fb74:	0014e793          	ori	a5,s1,1
    fb78:	e41c                	sd	a5,8(s0)
    fb7a:	94a2                	add	s1,s1,s0
    fb7c:	0099b823          	sd	s1,16(s3)
    fb80:	00176713          	ori	a4,a4,1
    fb84:	854a                	mv	a0,s2
    fb86:	e498                	sd	a4,8(s1)
    fb88:	31e000ef          	jal	fea6 <__malloc_unlock>
    fb8c:	60e6                	ld	ra,88(sp)
    fb8e:	01040513          	addi	a0,s0,16
    fb92:	6446                	ld	s0,80(sp)
    fb94:	7aa2                	ld	s5,40(sp)
    fb96:	64a6                	ld	s1,72(sp)
    fb98:	6906                	ld	s2,64(sp)
    fb9a:	79e2                	ld	s3,56(sp)
    fb9c:	6125                	addi	sp,sp,96
    fb9e:	8082                	ret
    fba0:	0089b503          	ld	a0,8(s3)
    fba4:	bbe1                	j	f97c <_malloc_r+0x140>
    fba6:	6810                	ld	a2,16(s0)
    fba8:	97a2                	add	a5,a5,s0
    fbaa:	6798                	ld	a4,8(a5)
    fbac:	ee14                	sd	a3,24(a2)
    fbae:	ea90                	sd	a2,16(a3)
    fbb0:	00176713          	ori	a4,a4,1
    fbb4:	854a                	mv	a0,s2
    fbb6:	e798                	sd	a4,8(a5)
    fbb8:	2ee000ef          	jal	fea6 <__malloc_unlock>
    fbbc:	60e6                	ld	ra,88(sp)
    fbbe:	01040513          	addi	a0,s0,16
    fbc2:	6446                	ld	s0,80(sp)
    fbc4:	64a6                	ld	s1,72(sp)
    fbc6:	6906                	ld	s2,64(sp)
    fbc8:	79e2                	ld	s3,56(sp)
    fbca:	6125                	addi	sp,sp,96
    fbcc:	8082                	ret
    fbce:	6f80                	ld	s0,24(a5)
    fbd0:	2589                	addiw	a1,a1,2
    fbd2:	d48783e3          	beq	a5,s0,f918 <_malloc_r+0xdc>
    fbd6:	b15d                	j	f87c <_malloc_r+0x40>
    fbd8:	0097d713          	srli	a4,a5,0x9
    fbdc:	4691                	li	a3,4
    fbde:	0ee6fc63          	bgeu	a3,a4,fcd6 <_malloc_r+0x49a>
    fbe2:	46d1                	li	a3,20
    fbe4:	1ae6ef63          	bltu	a3,a4,fda2 <_malloc_r+0x566>
    fbe8:	05c7061b          	addiw	a2,a4,92
    fbec:	0016161b          	slliw	a2,a2,0x1
    fbf0:	060e                	slli	a2,a2,0x3
    fbf2:	05b7069b          	addiw	a3,a4,91
    fbf6:	964e                	add	a2,a2,s3
    fbf8:	6218                	ld	a4,0(a2)
    fbfa:	1641                	addi	a2,a2,-16
    fbfc:	00e61663          	bne	a2,a4,fc08 <_malloc_r+0x3cc>
    fc00:	aa99                	j	fd56 <_malloc_r+0x51a>
    fc02:	6b18                	ld	a4,16(a4)
    fc04:	00e60663          	beq	a2,a4,fc10 <_malloc_r+0x3d4>
    fc08:	6714                	ld	a3,8(a4)
    fc0a:	9af1                	andi	a3,a3,-4
    fc0c:	fed7ebe3          	bltu	a5,a3,fc02 <_malloc_r+0x3c6>
    fc10:	6f10                	ld	a2,24(a4)
    fc12:	ec10                	sd	a2,24(s0)
    fc14:	e818                	sd	a4,16(s0)
    fc16:	ea00                	sd	s0,16(a2)
    fc18:	ef00                	sd	s0,24(a4)
    fc1a:	b38d                	j	f97c <_malloc_r+0x140>
    fc1c:	4751                	li	a4,20
    fc1e:	0cf77663          	bgeu	a4,a5,fcea <_malloc_r+0x4ae>
    fc22:	05400713          	li	a4,84
    fc26:	18f76c63          	bltu	a4,a5,fdbe <_malloc_r+0x582>
    fc2a:	00c4d793          	srli	a5,s1,0xc
    fc2e:	06f7859b          	addiw	a1,a5,111 # fffffffffffff06f <__kernel_stack+0xfffffffffff1106f>
    fc32:	0015961b          	slliw	a2,a1,0x1
    fc36:	06e7881b          	addiw	a6,a5,110
    fc3a:	060e                	slli	a2,a2,0x3
    fc3c:	b175                	j	f8e8 <_malloc_r+0xac>
    fc3e:	2e05                	addiw	t3,t3,1
    fc40:	003e7793          	andi	a5,t3,3
    fc44:	0541                	addi	a0,a0,16
    fc46:	cfdd                	beqz	a5,fd04 <_malloc_r+0x4c8>
    fc48:	6d1c                	ld	a5,24(a0)
    fc4a:	bb8d                	j	f9bc <_malloc_r+0x180>
    fc4c:	6810                	ld	a2,16(s0)
    fc4e:	0014e593          	ori	a1,s1,1
    fc52:	e40c                	sd	a1,8(s0)
    fc54:	ee1c                	sd	a5,24(a2)
    fc56:	eb90                	sd	a2,16(a5)
    fc58:	94a2                	add	s1,s1,s0
    fc5a:	0299b423          	sd	s1,40(s3)
    fc5e:	0299b023          	sd	s1,32(s3)
    fc62:	0016e793          	ori	a5,a3,1
    fc66:	9722                	add	a4,a4,s0
    fc68:	0114bc23          	sd	a7,24(s1)
    fc6c:	0114b823          	sd	a7,16(s1)
    fc70:	e49c                	sd	a5,8(s1)
    fc72:	854a                	mv	a0,s2
    fc74:	e314                	sd	a3,0(a4)
    fc76:	230000ef          	jal	fea6 <__malloc_unlock>
    fc7a:	01040513          	addi	a0,s0,16
    fc7e:	bbad                	j	f9f8 <_malloc_r+0x1bc>
    fc80:	97a2                	add	a5,a5,s0
    fc82:	6798                	ld	a4,8(a5)
    fc84:	854a                	mv	a0,s2
    fc86:	00176713          	ori	a4,a4,1
    fc8a:	e798                	sd	a4,8(a5)
    fc8c:	21a000ef          	jal	fea6 <__malloc_unlock>
    fc90:	01040513          	addi	a0,s0,16
    fc94:	b395                	j	f9f8 <_malloc_r+0x1bc>
    fc96:	0014e693          	ori	a3,s1,1
    fc9a:	e414                	sd	a3,8(s0)
    fc9c:	94a2                	add	s1,s1,s0
    fc9e:	0299b423          	sd	s1,40(s3)
    fca2:	0299b023          	sd	s1,32(s3)
    fca6:	00176693          	ori	a3,a4,1
    fcaa:	97a2                	add	a5,a5,s0
    fcac:	0114bc23          	sd	a7,24(s1)
    fcb0:	0114b823          	sd	a7,16(s1)
    fcb4:	e494                	sd	a3,8(s1)
    fcb6:	854a                	mv	a0,s2
    fcb8:	e398                	sd	a4,0(a5)
    fcba:	1ec000ef          	jal	fea6 <__malloc_unlock>
    fcbe:	01040513          	addi	a0,s0,16
    fcc2:	bb1d                	j	f9f8 <_malloc_r+0x1bc>
    fcc4:	0034d593          	srli	a1,s1,0x3
    fcc8:	0015879b          	addiw	a5,a1,1
    fccc:	0017979b          	slliw	a5,a5,0x1
    fcd0:	078e                	slli	a5,a5,0x3
    fcd2:	2581                	sext.w	a1,a1
    fcd4:	be51                	j	f868 <_malloc_r+0x2c>
    fcd6:	0067d713          	srli	a4,a5,0x6
    fcda:	0397061b          	addiw	a2,a4,57
    fcde:	0016161b          	slliw	a2,a2,0x1
    fce2:	060e                	slli	a2,a2,0x3
    fce4:	0387069b          	addiw	a3,a4,56
    fce8:	b739                	j	fbf6 <_malloc_r+0x3ba>
    fcea:	05c7859b          	addiw	a1,a5,92
    fcee:	0015961b          	slliw	a2,a1,0x1
    fcf2:	05b7881b          	addiw	a6,a5,91
    fcf6:	060e                	slli	a2,a2,0x3
    fcf8:	bec5                	j	f8e8 <_malloc_r+0xac>
    fcfa:	01033783          	ld	a5,16(t1)
    fcfe:	35fd                	addiw	a1,a1,-1
    fd00:	18679a63          	bne	a5,t1,fe94 <_malloc_r+0x658>
    fd04:	0035f793          	andi	a5,a1,3
    fd08:	1341                	addi	t1,t1,-16
    fd0a:	fbe5                	bnez	a5,fcfa <_malloc_r+0x4be>
    fd0c:	0089b703          	ld	a4,8(s3)
    fd10:	fff64793          	not	a5,a2
    fd14:	8ff9                	and	a5,a5,a4
    fd16:	00f9b423          	sd	a5,8(s3)
    fd1a:	0606                	slli	a2,a2,0x1
    fd1c:	cec7ece3          	bltu	a5,a2,fa14 <_malloc_r+0x1d8>
    fd20:	ce060ae3          	beqz	a2,fa14 <_malloc_r+0x1d8>
    fd24:	00f67733          	and	a4,a2,a5
    fd28:	e711                	bnez	a4,fd34 <_malloc_r+0x4f8>
    fd2a:	0606                	slli	a2,a2,0x1
    fd2c:	00f67733          	and	a4,a2,a5
    fd30:	2e11                	addiw	t3,t3,4
    fd32:	df65                	beqz	a4,fd2a <_malloc_r+0x4ee>
    fd34:	85f2                	mv	a1,t3
    fd36:	b98d                	j	f9a8 <_malloc_r+0x16c>
    fd38:	01040593          	addi	a1,s0,16
    fd3c:	854a                	mv	a0,s2
    fd3e:	36a000ef          	jal	100a8 <_free_r>
    fd42:	00031717          	auipc	a4,0x31
    fd46:	2ee72703          	lw	a4,750(a4) # 41030 <__malloc_current_mallinfo>
    fd4a:	0109bb03          	ld	s6,16(s3)
    fd4e:	bbe1                	j	fb26 <_malloc_r+0x2ea>
    fd50:	020a0a13          	addi	s4,s4,32
    fd54:	b339                	j	fa62 <_malloc_r+0x226>
    fd56:	4026d69b          	sraiw	a3,a3,0x2
    fd5a:	4785                	li	a5,1
    fd5c:	00d797b3          	sll	a5,a5,a3
    fd60:	8d5d                	or	a0,a0,a5
    fd62:	00a9b423          	sd	a0,8(s3)
    fd66:	b575                	j	fc12 <_malloc_r+0x3d6>
    fd68:	014b0bb3          	add	s7,s6,s4
    fd6c:	41700bb3          	neg	s7,s7
    fd70:	1bd2                	slli	s7,s7,0x34
    fd72:	034bdb93          	srli	s7,s7,0x34
    fd76:	85de                	mv	a1,s7
    fd78:	854a                	mv	a0,s2
    fd7a:	138000ef          	jal	feb2 <_sbrk_r>
    fd7e:	57fd                	li	a5,-1
    fd80:	4681                	li	a3,0
    fd82:	d4f51ce3          	bne	a0,a5,fada <_malloc_r+0x29e>
    fd86:	b385                	j	fae6 <_malloc_r+0x2aa>
    fd88:	6ca2                	ld	s9,8(sp)
    fd8a:	4785                	li	a5,1
    fd8c:	00fb3423          	sd	a5,8(s6)
    fd90:	854a                	mv	a0,s2
    fd92:	114000ef          	jal	fea6 <__malloc_unlock>
    fd96:	7a42                	ld	s4,48(sp)
    fd98:	7aa2                	ld	s5,40(sp)
    fd9a:	7b02                	ld	s6,32(sp)
    fd9c:	6be2                	ld	s7,24(sp)
    fd9e:	6c42                	ld	s8,16(sp)
    fda0:	b999                	j	f9f6 <_malloc_r+0x1ba>
    fda2:	05400693          	li	a3,84
    fda6:	06e6eb63          	bltu	a3,a4,fe1c <_malloc_r+0x5e0>
    fdaa:	00c7d713          	srli	a4,a5,0xc
    fdae:	06f7061b          	addiw	a2,a4,111
    fdb2:	0016161b          	slliw	a2,a2,0x1
    fdb6:	060e                	slli	a2,a2,0x3
    fdb8:	06e7069b          	addiw	a3,a4,110
    fdbc:	bd2d                	j	fbf6 <_malloc_r+0x3ba>
    fdbe:	15400713          	li	a4,340
    fdc2:	06f76b63          	bltu	a4,a5,fe38 <_malloc_r+0x5fc>
    fdc6:	00f4d793          	srli	a5,s1,0xf
    fdca:	0787859b          	addiw	a1,a5,120
    fdce:	0015961b          	slliw	a2,a1,0x1
    fdd2:	0777881b          	addiw	a6,a5,119
    fdd6:	060e                	slli	a2,a2,0x3
    fdd8:	be01                	j	f8e8 <_malloc_r+0xac>
    fdda:	00031697          	auipc	a3,0x31
    fdde:	2566a683          	lw	a3,598(a3) # 41030 <__malloc_current_mallinfo>
    fde2:	00031c97          	auipc	s9,0x31
    fde6:	24ec8c93          	addi	s9,s9,590 # 41030 <__malloc_current_mallinfo>
    fdea:	014686bb          	addw	a3,a3,s4
    fdee:	00dca023          	sw	a3,0(s9)
    fdf2:	b155                	j	fa96 <_malloc_r+0x25a>
    fdf4:	0109b403          	ld	s0,16(s3)
    fdf8:	641c                	ld	a5,8(s0)
    fdfa:	b38d                	j	fb5c <_malloc_r+0x320>
    fdfc:	03451793          	slli	a5,a0,0x34
    fe00:	c8079be3          	bnez	a5,fa96 <_malloc_r+0x25a>
    fe04:	0109bb03          	ld	s6,16(s3)
    fe08:	014a87b3          	add	a5,s5,s4
    fe0c:	0017e793          	ori	a5,a5,1
    fe10:	00fb3423          	sd	a5,8(s6)
    fe14:	bb19                	j	fb2a <_malloc_r+0x2ee>
    fe16:	016c3023          	sd	s6,0(s8)
    fe1a:	b941                	j	faaa <_malloc_r+0x26e>
    fe1c:	15400693          	li	a3,340
    fe20:	04e6e063          	bltu	a3,a4,fe60 <_malloc_r+0x624>
    fe24:	00f7d713          	srli	a4,a5,0xf
    fe28:	0787061b          	addiw	a2,a4,120
    fe2c:	0016161b          	slliw	a2,a2,0x1
    fe30:	060e                	slli	a2,a2,0x3
    fe32:	0777069b          	addiw	a3,a4,119
    fe36:	b3c1                	j	fbf6 <_malloc_r+0x3ba>
    fe38:	55400713          	li	a4,1364
    fe3c:	04f76063          	bltu	a4,a5,fe7c <_malloc_r+0x640>
    fe40:	0124d793          	srli	a5,s1,0x12
    fe44:	07d7859b          	addiw	a1,a5,125
    fe48:	0015961b          	slliw	a2,a1,0x1
    fe4c:	07c7881b          	addiw	a6,a5,124
    fe50:	060e                	slli	a2,a2,0x3
    fe52:	bc59                	j	f8e8 <_malloc_r+0xac>
    fe54:	1c41                	addi	s8,s8,-16
    fe56:	9a62                	add	s4,s4,s8
    fe58:	416a0a33          	sub	s4,s4,s6
    fe5c:	4681                	li	a3,0
    fe5e:	b161                	j	fae6 <_malloc_r+0x2aa>
    fe60:	55400693          	li	a3,1364
    fe64:	02e6e363          	bltu	a3,a4,fe8a <_malloc_r+0x64e>
    fe68:	0127d713          	srli	a4,a5,0x12
    fe6c:	07d7061b          	addiw	a2,a4,125
    fe70:	0016161b          	slliw	a2,a2,0x1
    fe74:	060e                	slli	a2,a2,0x3
    fe76:	07c7069b          	addiw	a3,a4,124
    fe7a:	bbb5                	j	fbf6 <_malloc_r+0x3ba>
    fe7c:	7f000613          	li	a2,2032
    fe80:	07f00593          	li	a1,127
    fe84:	07e00813          	li	a6,126
    fe88:	b485                	j	f8e8 <_malloc_r+0xac>
    fe8a:	7f000613          	li	a2,2032
    fe8e:	07e00693          	li	a3,126
    fe92:	b395                	j	fbf6 <_malloc_r+0x3ba>
    fe94:	0089b783          	ld	a5,8(s3)
    fe98:	b549                	j	fd1a <_malloc_r+0x4de>

000000000000fe9a <__malloc_lock>:
    fe9a:	00031517          	auipc	a0,0x31
    fe9e:	1f650513          	addi	a0,a0,502 # 41090 <__lock___malloc_recursive_mutex>
    fea2:	45a0006f          	j	102fc <__retarget_lock_acquire_recursive>

000000000000fea6 <__malloc_unlock>:
    fea6:	00031517          	auipc	a0,0x31
    feaa:	1ea50513          	addi	a0,a0,490 # 41090 <__lock___malloc_recursive_mutex>
    feae:	45a0006f          	j	10308 <__retarget_lock_release_recursive>

000000000000feb2 <_sbrk_r>:
    feb2:	1141                	addi	sp,sp,-16
    feb4:	e022                	sd	s0,0(sp)
    feb6:	842a                	mv	s0,a0
    feb8:	852e                	mv	a0,a1
    feba:	00031797          	auipc	a5,0x31
    febe:	1e07ad23          	sw	zero,506(a5) # 410b4 <errno>
    fec2:	e406                	sd	ra,8(sp)
    fec4:	61a000ef          	jal	104de <_sbrk>
    fec8:	57fd                	li	a5,-1
    feca:	00f50663          	beq	a0,a5,fed6 <_sbrk_r+0x24>
    fece:	60a2                	ld	ra,8(sp)
    fed0:	6402                	ld	s0,0(sp)
    fed2:	0141                	addi	sp,sp,16
    fed4:	8082                	ret
    fed6:	00031797          	auipc	a5,0x31
    feda:	1de7a783          	lw	a5,478(a5) # 410b4 <errno>
    fede:	dbe5                	beqz	a5,fece <_sbrk_r+0x1c>
    fee0:	60a2                	ld	ra,8(sp)
    fee2:	c01c                	sw	a5,0(s0)
    fee4:	6402                	ld	s0,0(sp)
    fee6:	0141                	addi	sp,sp,16
    fee8:	8082                	ret

000000000000feea <strdup>:
    feea:	85aa                	mv	a1,a0
    feec:	00031517          	auipc	a0,0x31
    fef0:	0c453503          	ld	a0,196(a0) # 40fb0 <_impure_ptr>
    fef4:	a009                	j	fef6 <_strdup_r>

000000000000fef6 <_strdup_r>:
    fef6:	1101                	addi	sp,sp,-32
    fef8:	e822                	sd	s0,16(sp)
    fefa:	842a                	mv	s0,a0
    fefc:	852e                	mv	a0,a1
    fefe:	ec06                	sd	ra,24(sp)
    ff00:	e426                	sd	s1,8(sp)
    ff02:	e04a                	sd	s2,0(sp)
    ff04:	84ae                	mv	s1,a1
    ff06:	02a000ef          	jal	ff30 <strlen>
    ff0a:	00150913          	addi	s2,a0,1
    ff0e:	85ca                	mv	a1,s2
    ff10:	8522                	mv	a0,s0
    ff12:	92bff0ef          	jal	f83c <_malloc_r>
    ff16:	842a                	mv	s0,a0
    ff18:	c509                	beqz	a0,ff22 <_strdup_r+0x2c>
    ff1a:	864a                	mv	a2,s2
    ff1c:	85a6                	mv	a1,s1
    ff1e:	3ee000ef          	jal	1030c <memcpy>
    ff22:	60e2                	ld	ra,24(sp)
    ff24:	8522                	mv	a0,s0
    ff26:	6442                	ld	s0,16(sp)
    ff28:	64a2                	ld	s1,8(sp)
    ff2a:	6902                	ld	s2,0(sp)
    ff2c:	6105                	addi	sp,sp,32
    ff2e:	8082                	ret

000000000000ff30 <strlen>:
    ff30:	00757793          	andi	a5,a0,7
    ff34:	872a                	mv	a4,a0
    ff36:	efb1                	bnez	a5,ff92 <strlen+0x62>
    ff38:	7f7f87b7          	lui	a5,0x7f7f8
    ff3c:	f7f78793          	addi	a5,a5,-129 # 7f7f7f7f <__kernel_stack+0x7f709f7f>
    ff40:	02079693          	slli	a3,a5,0x20
    ff44:	96be                	add	a3,a3,a5
    ff46:	55fd                	li	a1,-1
    ff48:	6310                	ld	a2,0(a4)
    ff4a:	0721                	addi	a4,a4,8
    ff4c:	00d677b3          	and	a5,a2,a3
    ff50:	97b6                	add	a5,a5,a3
    ff52:	8fd1                	or	a5,a5,a2
    ff54:	8fd5                	or	a5,a5,a3
    ff56:	feb789e3          	beq	a5,a1,ff48 <strlen+0x18>
    ff5a:	ff874683          	lbu	a3,-8(a4)
    ff5e:	40a707b3          	sub	a5,a4,a0
    ff62:	c6a9                	beqz	a3,ffac <strlen+0x7c>
    ff64:	ff974683          	lbu	a3,-7(a4)
    ff68:	ce9d                	beqz	a3,ffa6 <strlen+0x76>
    ff6a:	ffa74683          	lbu	a3,-6(a4)
    ff6e:	c6a9                	beqz	a3,ffb8 <strlen+0x88>
    ff70:	ffb74683          	lbu	a3,-5(a4)
    ff74:	ce9d                	beqz	a3,ffb2 <strlen+0x82>
    ff76:	ffc74683          	lbu	a3,-4(a4)
    ff7a:	c2b1                	beqz	a3,ffbe <strlen+0x8e>
    ff7c:	ffd74683          	lbu	a3,-3(a4)
    ff80:	c2b1                	beqz	a3,ffc4 <strlen+0x94>
    ff82:	ffe74503          	lbu	a0,-2(a4)
    ff86:	00a03533          	snez	a0,a0
    ff8a:	953e                	add	a0,a0,a5
    ff8c:	1579                	addi	a0,a0,-2
    ff8e:	8082                	ret
    ff90:	d6c5                	beqz	a3,ff38 <strlen+0x8>
    ff92:	00074783          	lbu	a5,0(a4)
    ff96:	0705                	addi	a4,a4,1
    ff98:	00777693          	andi	a3,a4,7
    ff9c:	fbf5                	bnez	a5,ff90 <strlen+0x60>
    ff9e:	8f09                	sub	a4,a4,a0
    ffa0:	fff70513          	addi	a0,a4,-1
    ffa4:	8082                	ret
    ffa6:	ff978513          	addi	a0,a5,-7
    ffaa:	8082                	ret
    ffac:	ff878513          	addi	a0,a5,-8
    ffb0:	8082                	ret
    ffb2:	ffb78513          	addi	a0,a5,-5
    ffb6:	8082                	ret
    ffb8:	ffa78513          	addi	a0,a5,-6
    ffbc:	8082                	ret
    ffbe:	ffc78513          	addi	a0,a5,-4
    ffc2:	8082                	ret
    ffc4:	ffd78513          	addi	a0,a5,-3
    ffc8:	8082                	ret

000000000000ffca <_malloc_trim_r>:
    ffca:	7179                	addi	sp,sp,-48
    ffcc:	f022                	sd	s0,32(sp)
    ffce:	ec26                	sd	s1,24(sp)
    ffd0:	e84a                	sd	s2,16(sp)
    ffd2:	e44e                	sd	s3,8(sp)
    ffd4:	e052                	sd	s4,0(sp)
    ffd6:	89ae                	mv	s3,a1
    ffd8:	f406                	sd	ra,40(sp)
    ffda:	892a                	mv	s2,a0
    ffdc:	00030a17          	auipc	s4,0x30
    ffe0:	054a0a13          	addi	s4,s4,84 # 40030 <__malloc_av_>
    ffe4:	eb7ff0ef          	jal	fe9a <__malloc_lock>
    ffe8:	010a3783          	ld	a5,16(s4)
    ffec:	6405                	lui	s0,0x1
    ffee:	fdf40413          	addi	s0,s0,-33 # fdf <core_bench_list+0x6af>
    fff2:	6784                	ld	s1,8(a5)
    fff4:	6785                	lui	a5,0x1
    fff6:	98f1                	andi	s1,s1,-4
    fff8:	9426                	add	s0,s0,s1
    fffa:	41340433          	sub	s0,s0,s3
    fffe:	8031                	srli	s0,s0,0xc
   10000:	147d                	addi	s0,s0,-1
   10002:	0432                	slli	s0,s0,0xc
   10004:	00f44b63          	blt	s0,a5,1001a <_malloc_trim_r+0x50>
   10008:	4581                	li	a1,0
   1000a:	854a                	mv	a0,s2
   1000c:	ea7ff0ef          	jal	feb2 <_sbrk_r>
   10010:	010a3783          	ld	a5,16(s4)
   10014:	97a6                	add	a5,a5,s1
   10016:	00f50e63          	beq	a0,a5,10032 <_malloc_trim_r+0x68>
   1001a:	854a                	mv	a0,s2
   1001c:	e8bff0ef          	jal	fea6 <__malloc_unlock>
   10020:	70a2                	ld	ra,40(sp)
   10022:	7402                	ld	s0,32(sp)
   10024:	64e2                	ld	s1,24(sp)
   10026:	6942                	ld	s2,16(sp)
   10028:	69a2                	ld	s3,8(sp)
   1002a:	6a02                	ld	s4,0(sp)
   1002c:	4501                	li	a0,0
   1002e:	6145                	addi	sp,sp,48
   10030:	8082                	ret
   10032:	408005b3          	neg	a1,s0
   10036:	854a                	mv	a0,s2
   10038:	e7bff0ef          	jal	feb2 <_sbrk_r>
   1003c:	57fd                	li	a5,-1
   1003e:	02f50d63          	beq	a0,a5,10078 <_malloc_trim_r+0xae>
   10042:	010a3703          	ld	a4,16(s4)
   10046:	00031797          	auipc	a5,0x31
   1004a:	fea7a783          	lw	a5,-22(a5) # 41030 <__malloc_current_mallinfo>
   1004e:	8c81                	sub	s1,s1,s0
   10050:	0014e493          	ori	s1,s1,1
   10054:	e704                	sd	s1,8(a4)
   10056:	854a                	mv	a0,s2
   10058:	9f81                	subw	a5,a5,s0
   1005a:	00031717          	auipc	a4,0x31
   1005e:	fcf72b23          	sw	a5,-42(a4) # 41030 <__malloc_current_mallinfo>
   10062:	e45ff0ef          	jal	fea6 <__malloc_unlock>
   10066:	70a2                	ld	ra,40(sp)
   10068:	7402                	ld	s0,32(sp)
   1006a:	64e2                	ld	s1,24(sp)
   1006c:	6942                	ld	s2,16(sp)
   1006e:	69a2                	ld	s3,8(sp)
   10070:	6a02                	ld	s4,0(sp)
   10072:	4505                	li	a0,1
   10074:	6145                	addi	sp,sp,48
   10076:	8082                	ret
   10078:	4581                	li	a1,0
   1007a:	854a                	mv	a0,s2
   1007c:	e37ff0ef          	jal	feb2 <_sbrk_r>
   10080:	010a3703          	ld	a4,16(s4)
   10084:	46fd                	li	a3,31
   10086:	40e507b3          	sub	a5,a0,a4
   1008a:	f8f6d8e3          	bge	a3,a5,1001a <_malloc_trim_r+0x50>
   1008e:	00031697          	auipc	a3,0x31
   10092:	f126b683          	ld	a3,-238(a3) # 40fa0 <__malloc_sbrk_base>
   10096:	0017e793          	ori	a5,a5,1
   1009a:	e71c                	sd	a5,8(a4)
   1009c:	8d15                	sub	a0,a0,a3
   1009e:	00031797          	auipc	a5,0x31
   100a2:	f8a7a923          	sw	a0,-110(a5) # 41030 <__malloc_current_mallinfo>
   100a6:	bf95                	j	1001a <_malloc_trim_r+0x50>

00000000000100a8 <_free_r>:
   100a8:	c1fd                	beqz	a1,1018e <_free_r+0xe6>
   100aa:	1101                	addi	sp,sp,-32
   100ac:	e822                	sd	s0,16(sp)
   100ae:	e426                	sd	s1,8(sp)
   100b0:	842e                	mv	s0,a1
   100b2:	84aa                	mv	s1,a0
   100b4:	ec06                	sd	ra,24(sp)
   100b6:	de5ff0ef          	jal	fe9a <__malloc_lock>
   100ba:	ff843583          	ld	a1,-8(s0)
   100be:	ff040713          	addi	a4,s0,-16
   100c2:	00030817          	auipc	a6,0x30
   100c6:	f6e80813          	addi	a6,a6,-146 # 40030 <__malloc_av_>
   100ca:	ffe5f793          	andi	a5,a1,-2
   100ce:	00f70633          	add	a2,a4,a5
   100d2:	6614                	ld	a3,8(a2)
   100d4:	01083503          	ld	a0,16(a6)
   100d8:	0015f893          	andi	a7,a1,1
   100dc:	9af1                	andi	a3,a3,-4
   100de:	12c50563          	beq	a0,a2,10208 <_free_r+0x160>
   100e2:	e614                	sd	a3,8(a2)
   100e4:	00d60533          	add	a0,a2,a3
   100e8:	6508                	ld	a0,8(a0)
   100ea:	8905                	andi	a0,a0,1
   100ec:	06089e63          	bnez	a7,10168 <_free_r+0xc0>
   100f0:	ff043303          	ld	t1,-16(s0)
   100f4:	00030897          	auipc	a7,0x30
   100f8:	f4c88893          	addi	a7,a7,-180 # 40040 <__malloc_av_+0x10>
   100fc:	40670733          	sub	a4,a4,t1
   10100:	6b0c                	ld	a1,16(a4)
   10102:	979a                	add	a5,a5,t1
   10104:	0f158663          	beq	a1,a7,101f0 <_free_r+0x148>
   10108:	01873303          	ld	t1,24(a4)
   1010c:	0065bc23          	sd	t1,24(a1)
   10110:	00b33823          	sd	a1,16(t1)
   10114:	12050863          	beqz	a0,10244 <_free_r+0x19c>
   10118:	0017e693          	ori	a3,a5,1
   1011c:	e714                	sd	a3,8(a4)
   1011e:	e21c                	sd	a5,0(a2)
   10120:	1ff00693          	li	a3,511
   10124:	06f6ef63          	bltu	a3,a5,101a2 <_free_r+0xfa>
   10128:	838d                	srli	a5,a5,0x3
   1012a:	2781                	sext.w	a5,a5
   1012c:	0017869b          	addiw	a3,a5,1
   10130:	0016969b          	slliw	a3,a3,0x1
   10134:	068e                	slli	a3,a3,0x3
   10136:	00883503          	ld	a0,8(a6)
   1013a:	96c2                	add	a3,a3,a6
   1013c:	628c                	ld	a1,0(a3)
   1013e:	4605                	li	a2,1
   10140:	4027d79b          	sraiw	a5,a5,0x2
   10144:	00f617b3          	sll	a5,a2,a5
   10148:	8fc9                	or	a5,a5,a0
   1014a:	ff068613          	addi	a2,a3,-16
   1014e:	eb0c                	sd	a1,16(a4)
   10150:	ef10                	sd	a2,24(a4)
   10152:	00f83423          	sd	a5,8(a6)
   10156:	e298                	sd	a4,0(a3)
   10158:	ed98                	sd	a4,24(a1)
   1015a:	6442                	ld	s0,16(sp)
   1015c:	60e2                	ld	ra,24(sp)
   1015e:	8526                	mv	a0,s1
   10160:	64a2                	ld	s1,8(sp)
   10162:	6105                	addi	sp,sp,32
   10164:	d43ff06f          	j	fea6 <__malloc_unlock>
   10168:	e505                	bnez	a0,10190 <_free_r+0xe8>
   1016a:	97b6                	add	a5,a5,a3
   1016c:	00030897          	auipc	a7,0x30
   10170:	ed488893          	addi	a7,a7,-300 # 40040 <__malloc_av_+0x10>
   10174:	6a14                	ld	a3,16(a2)
   10176:	0017e513          	ori	a0,a5,1
   1017a:	00f705b3          	add	a1,a4,a5
   1017e:	11168363          	beq	a3,a7,10284 <_free_r+0x1dc>
   10182:	6e10                	ld	a2,24(a2)
   10184:	ee90                	sd	a2,24(a3)
   10186:	ea14                	sd	a3,16(a2)
   10188:	e708                	sd	a0,8(a4)
   1018a:	e19c                	sd	a5,0(a1)
   1018c:	bf51                	j	10120 <_free_r+0x78>
   1018e:	8082                	ret
   10190:	0015e593          	ori	a1,a1,1
   10194:	feb43c23          	sd	a1,-8(s0)
   10198:	e21c                	sd	a5,0(a2)
   1019a:	1ff00693          	li	a3,511
   1019e:	f8f6f5e3          	bgeu	a3,a5,10128 <_free_r+0x80>
   101a2:	0097d693          	srli	a3,a5,0x9
   101a6:	4611                	li	a2,4
   101a8:	0ad66063          	bltu	a2,a3,10248 <_free_r+0x1a0>
   101ac:	0067d693          	srli	a3,a5,0x6
   101b0:	0396859b          	addiw	a1,a3,57
   101b4:	0015959b          	slliw	a1,a1,0x1
   101b8:	058e                	slli	a1,a1,0x3
   101ba:	0386861b          	addiw	a2,a3,56
   101be:	95c2                	add	a1,a1,a6
   101c0:	6194                	ld	a3,0(a1)
   101c2:	15c1                	addi	a1,a1,-16
   101c4:	00d59663          	bne	a1,a3,101d0 <_free_r+0x128>
   101c8:	a8c9                	j	1029a <_free_r+0x1f2>
   101ca:	6a94                	ld	a3,16(a3)
   101cc:	00d58663          	beq	a1,a3,101d8 <_free_r+0x130>
   101d0:	6690                	ld	a2,8(a3)
   101d2:	9a71                	andi	a2,a2,-4
   101d4:	fec7ebe3          	bltu	a5,a2,101ca <_free_r+0x122>
   101d8:	6e8c                	ld	a1,24(a3)
   101da:	ef0c                	sd	a1,24(a4)
   101dc:	eb14                	sd	a3,16(a4)
   101de:	6442                	ld	s0,16(sp)
   101e0:	60e2                	ld	ra,24(sp)
   101e2:	e998                	sd	a4,16(a1)
   101e4:	8526                	mv	a0,s1
   101e6:	64a2                	ld	s1,8(sp)
   101e8:	ee98                	sd	a4,24(a3)
   101ea:	6105                	addi	sp,sp,32
   101ec:	cbbff06f          	j	fea6 <__malloc_unlock>
   101f0:	ed2d                	bnez	a0,1026a <_free_r+0x1c2>
   101f2:	6e0c                	ld	a1,24(a2)
   101f4:	6a10                	ld	a2,16(a2)
   101f6:	96be                	add	a3,a3,a5
   101f8:	0016e793          	ori	a5,a3,1
   101fc:	ee0c                	sd	a1,24(a2)
   101fe:	e990                	sd	a2,16(a1)
   10200:	e71c                	sd	a5,8(a4)
   10202:	9736                	add	a4,a4,a3
   10204:	e314                	sd	a3,0(a4)
   10206:	bf91                	j	1015a <_free_r+0xb2>
   10208:	96be                	add	a3,a3,a5
   1020a:	00089a63          	bnez	a7,1021e <_free_r+0x176>
   1020e:	ff043583          	ld	a1,-16(s0)
   10212:	8f0d                	sub	a4,a4,a1
   10214:	6f1c                	ld	a5,24(a4)
   10216:	6b10                	ld	a2,16(a4)
   10218:	96ae                	add	a3,a3,a1
   1021a:	ee1c                	sd	a5,24(a2)
   1021c:	eb90                	sd	a2,16(a5)
   1021e:	0016e613          	ori	a2,a3,1
   10222:	00031797          	auipc	a5,0x31
   10226:	d867b783          	ld	a5,-634(a5) # 40fa8 <__malloc_trim_threshold>
   1022a:	e710                	sd	a2,8(a4)
   1022c:	00e83823          	sd	a4,16(a6)
   10230:	f2f6e5e3          	bltu	a3,a5,1015a <_free_r+0xb2>
   10234:	00031597          	auipc	a1,0x31
   10238:	e345b583          	ld	a1,-460(a1) # 41068 <__malloc_top_pad>
   1023c:	8526                	mv	a0,s1
   1023e:	d8dff0ef          	jal	ffca <_malloc_trim_r>
   10242:	bf21                	j	1015a <_free_r+0xb2>
   10244:	97b6                	add	a5,a5,a3
   10246:	b73d                	j	10174 <_free_r+0xcc>
   10248:	4651                	li	a2,20
   1024a:	02d67563          	bgeu	a2,a3,10274 <_free_r+0x1cc>
   1024e:	05400613          	li	a2,84
   10252:	04d66f63          	bltu	a2,a3,102b0 <_free_r+0x208>
   10256:	00c7d693          	srli	a3,a5,0xc
   1025a:	06f6859b          	addiw	a1,a3,111
   1025e:	0015959b          	slliw	a1,a1,0x1
   10262:	058e                	slli	a1,a1,0x3
   10264:	06e6861b          	addiw	a2,a3,110
   10268:	bf99                	j	101be <_free_r+0x116>
   1026a:	0017e693          	ori	a3,a5,1
   1026e:	e714                	sd	a3,8(a4)
   10270:	e21c                	sd	a5,0(a2)
   10272:	b5e5                	j	1015a <_free_r+0xb2>
   10274:	05c6859b          	addiw	a1,a3,92
   10278:	0015959b          	slliw	a1,a1,0x1
   1027c:	058e                	slli	a1,a1,0x3
   1027e:	05b6861b          	addiw	a2,a3,91
   10282:	bf35                	j	101be <_free_r+0x116>
   10284:	02e83423          	sd	a4,40(a6)
   10288:	02e83023          	sd	a4,32(a6)
   1028c:	01173c23          	sd	a7,24(a4)
   10290:	01173823          	sd	a7,16(a4)
   10294:	e708                	sd	a0,8(a4)
   10296:	e19c                	sd	a5,0(a1)
   10298:	b5c9                	j	1015a <_free_r+0xb2>
   1029a:	00883503          	ld	a0,8(a6)
   1029e:	4026561b          	sraiw	a2,a2,0x2
   102a2:	4785                	li	a5,1
   102a4:	00c797b3          	sll	a5,a5,a2
   102a8:	8fc9                	or	a5,a5,a0
   102aa:	00f83423          	sd	a5,8(a6)
   102ae:	b735                	j	101da <_free_r+0x132>
   102b0:	15400613          	li	a2,340
   102b4:	00d66c63          	bltu	a2,a3,102cc <_free_r+0x224>
   102b8:	00f7d693          	srli	a3,a5,0xf
   102bc:	0786859b          	addiw	a1,a3,120
   102c0:	0015959b          	slliw	a1,a1,0x1
   102c4:	058e                	slli	a1,a1,0x3
   102c6:	0776861b          	addiw	a2,a3,119
   102ca:	bdd5                	j	101be <_free_r+0x116>
   102cc:	55400613          	li	a2,1364
   102d0:	00d66c63          	bltu	a2,a3,102e8 <_free_r+0x240>
   102d4:	0127d693          	srli	a3,a5,0x12
   102d8:	07d6859b          	addiw	a1,a3,125
   102dc:	0015959b          	slliw	a1,a1,0x1
   102e0:	058e                	slli	a1,a1,0x3
   102e2:	07c6861b          	addiw	a2,a3,124
   102e6:	bde1                	j	101be <_free_r+0x116>
   102e8:	7f000593          	li	a1,2032
   102ec:	07e00613          	li	a2,126
   102f0:	b5f9                	j	101be <_free_r+0x116>

00000000000102f2 <__retarget_lock_init>:
   102f2:	8082                	ret

00000000000102f4 <__retarget_lock_init_recursive>:
   102f4:	8082                	ret

00000000000102f6 <__retarget_lock_close>:
   102f6:	8082                	ret

00000000000102f8 <__retarget_lock_close_recursive>:
   102f8:	8082                	ret

00000000000102fa <__retarget_lock_acquire>:
   102fa:	8082                	ret

00000000000102fc <__retarget_lock_acquire_recursive>:
   102fc:	8082                	ret

00000000000102fe <__retarget_lock_try_acquire>:
   102fe:	4505                	li	a0,1
   10300:	8082                	ret

0000000000010302 <__retarget_lock_try_acquire_recursive>:
   10302:	4505                	li	a0,1
   10304:	8082                	ret

0000000000010306 <__retarget_lock_release>:
   10306:	8082                	ret

0000000000010308 <__retarget_lock_release_recursive>:
   10308:	8082                	ret
	...

000000000001030c <memcpy>:
   1030c:	00863693          	sltiu	a3,a2,8
   10310:	82aa                	mv	t0,a0
   10312:	00c50333          	add	t1,a0,a2
   10316:	eeb5                	bnez	a3,10392 <memcpy+0x86>
   10318:	00b546b3          	xor	a3,a0,a1
   1031c:	8a9d                	andi	a3,a3,7
   1031e:	eab5                	bnez	a3,10392 <memcpy+0x86>
   10320:	00757693          	andi	a3,a0,7
   10324:	43a1                	li	t2,8
   10326:	e2c9                	bnez	a3,103a8 <memcpy+0x9c>
   10328:	ff837393          	andi	t2,t1,-8
   1032c:	fc038313          	addi	t1,t2,-64
   10330:	04a36263          	bltu	t1,a0,10374 <memcpy+0x68>
   10334:	03f67613          	andi	a2,a2,63
   10338:	6198                	ld	a4,0(a1)
   1033a:	e118                	sd	a4,0(a0)
   1033c:	659c                	ld	a5,8(a1)
   1033e:	e51c                	sd	a5,8(a0)
   10340:	0105b803          	ld	a6,16(a1)
   10344:	01053823          	sd	a6,16(a0)
   10348:	0185b883          	ld	a7,24(a1)
   1034c:	01153c23          	sd	a7,24(a0)
   10350:	7198                	ld	a4,32(a1)
   10352:	f118                	sd	a4,32(a0)
   10354:	759c                	ld	a5,40(a1)
   10356:	f51c                	sd	a5,40(a0)
   10358:	0305b803          	ld	a6,48(a1)
   1035c:	03053823          	sd	a6,48(a0)
   10360:	0385b883          	ld	a7,56(a1)
   10364:	04058593          	addi	a1,a1,64
   10368:	03153c23          	sd	a7,56(a0)
   1036c:	04050513          	addi	a0,a0,64
   10370:	fca374e3          	bgeu	t1,a0,10338 <memcpy+0x2c>
   10374:	ff837393          	andi	t2,t1,-8
   10378:	ff838313          	addi	t1,t2,-8
   1037c:	00a36963          	bltu	t1,a0,1038e <memcpy+0x82>
   10380:	8a0d                	andi	a2,a2,3
   10382:	4198                	lw	a4,0(a1)
   10384:	0591                	addi	a1,a1,4
   10386:	c118                	sw	a4,0(a0)
   10388:	0511                	addi	a0,a0,4
   1038a:	fea37ce3          	bgeu	t1,a0,10382 <memcpy+0x76>
   1038e:	00c50333          	add	t1,a0,a2
   10392:	ca09                	beqz	a2,103a4 <memcpy+0x98>
   10394:	00058703          	lb	a4,0(a1)
   10398:	0585                	addi	a1,a1,1
   1039a:	00e50023          	sb	a4,0(a0)
   1039e:	0505                	addi	a0,a0,1
   103a0:	fe656ae3          	bltu	a0,t1,10394 <memcpy+0x88>
   103a4:	8516                	mv	a0,t0
   103a6:	8082                	ret
   103a8:	40d386b3          	sub	a3,t2,a3
   103ac:	83b6                	mv	t2,a3
   103ae:	00058703          	lb	a4,0(a1)
   103b2:	0585                	addi	a1,a1,1
   103b4:	16fd                	addi	a3,a3,-1
   103b6:	00e50023          	sb	a4,0(a0)
   103ba:	0505                	addi	a0,a0,1
   103bc:	faed                	bnez	a3,103ae <memcpy+0xa2>
   103be:	40760633          	sub	a2,a2,t2
   103c2:	00263693          	sltiu	a3,a2,2
   103c6:	f6f1                	bnez	a3,10392 <memcpy+0x86>
   103c8:	b785                	j	10328 <memcpy+0x1c>

00000000000103ca <cleanup_glue>:
   103ca:	7179                	addi	sp,sp,-48
   103cc:	e84a                	sd	s2,16(sp)
   103ce:	0005b903          	ld	s2,0(a1)
   103d2:	f022                	sd	s0,32(sp)
   103d4:	ec26                	sd	s1,24(sp)
   103d6:	f406                	sd	ra,40(sp)
   103d8:	842e                	mv	s0,a1
   103da:	84aa                	mv	s1,a0
   103dc:	02090f63          	beqz	s2,1041a <cleanup_glue+0x50>
   103e0:	e44e                	sd	s3,8(sp)
   103e2:	00093983          	ld	s3,0(s2)
   103e6:	02098563          	beqz	s3,10410 <cleanup_glue+0x46>
   103ea:	e052                	sd	s4,0(sp)
   103ec:	0009ba03          	ld	s4,0(s3)
   103f0:	000a0b63          	beqz	s4,10406 <cleanup_glue+0x3c>
   103f4:	000a3583          	ld	a1,0(s4)
   103f8:	c199                	beqz	a1,103fe <cleanup_glue+0x34>
   103fa:	fd1ff0ef          	jal	103ca <cleanup_glue>
   103fe:	85d2                	mv	a1,s4
   10400:	8526                	mv	a0,s1
   10402:	ca7ff0ef          	jal	100a8 <_free_r>
   10406:	85ce                	mv	a1,s3
   10408:	8526                	mv	a0,s1
   1040a:	c9fff0ef          	jal	100a8 <_free_r>
   1040e:	6a02                	ld	s4,0(sp)
   10410:	85ca                	mv	a1,s2
   10412:	8526                	mv	a0,s1
   10414:	c95ff0ef          	jal	100a8 <_free_r>
   10418:	69a2                	ld	s3,8(sp)
   1041a:	85a2                	mv	a1,s0
   1041c:	7402                	ld	s0,32(sp)
   1041e:	70a2                	ld	ra,40(sp)
   10420:	6942                	ld	s2,16(sp)
   10422:	8526                	mv	a0,s1
   10424:	64e2                	ld	s1,24(sp)
   10426:	6145                	addi	sp,sp,48
   10428:	c81ff06f          	j	100a8 <_free_r>

000000000001042c <_reclaim_reent>:
   1042c:	00031797          	auipc	a5,0x31
   10430:	b847b783          	ld	a5,-1148(a5) # 40fb0 <_impure_ptr>
   10434:	0aa78463          	beq	a5,a0,104dc <_reclaim_reent+0xb0>
   10438:	7d2c                	ld	a1,120(a0)
   1043a:	7179                	addi	sp,sp,-48
   1043c:	ec26                	sd	s1,24(sp)
   1043e:	f406                	sd	ra,40(sp)
   10440:	f022                	sd	s0,32(sp)
   10442:	e84a                	sd	s2,16(sp)
   10444:	84aa                	mv	s1,a0
   10446:	c59d                	beqz	a1,10474 <_reclaim_reent+0x48>
   10448:	e44e                	sd	s3,8(sp)
   1044a:	4901                	li	s2,0
   1044c:	20000993          	li	s3,512
   10450:	012587b3          	add	a5,a1,s2
   10454:	6380                	ld	s0,0(a5)
   10456:	c801                	beqz	s0,10466 <_reclaim_reent+0x3a>
   10458:	85a2                	mv	a1,s0
   1045a:	6000                	ld	s0,0(s0)
   1045c:	8526                	mv	a0,s1
   1045e:	c4bff0ef          	jal	100a8 <_free_r>
   10462:	f87d                	bnez	s0,10458 <_reclaim_reent+0x2c>
   10464:	7cac                	ld	a1,120(s1)
   10466:	0921                	addi	s2,s2,8
   10468:	ff3914e3          	bne	s2,s3,10450 <_reclaim_reent+0x24>
   1046c:	8526                	mv	a0,s1
   1046e:	c3bff0ef          	jal	100a8 <_free_r>
   10472:	69a2                	ld	s3,8(sp)
   10474:	70ac                	ld	a1,96(s1)
   10476:	c581                	beqz	a1,1047e <_reclaim_reent+0x52>
   10478:	8526                	mv	a0,s1
   1047a:	c2fff0ef          	jal	100a8 <_free_r>
   1047e:	1f84b403          	ld	s0,504(s1)
   10482:	cc01                	beqz	s0,1049a <_reclaim_reent+0x6e>
   10484:	20048913          	addi	s2,s1,512
   10488:	01240963          	beq	s0,s2,1049a <_reclaim_reent+0x6e>
   1048c:	85a2                	mv	a1,s0
   1048e:	6000                	ld	s0,0(s0)
   10490:	8526                	mv	a0,s1
   10492:	c17ff0ef          	jal	100a8 <_free_r>
   10496:	fe891be3          	bne	s2,s0,1048c <_reclaim_reent+0x60>
   1049a:	64cc                	ld	a1,136(s1)
   1049c:	c581                	beqz	a1,104a4 <_reclaim_reent+0x78>
   1049e:	8526                	mv	a0,s1
   104a0:	c09ff0ef          	jal	100a8 <_free_r>
   104a4:	48bc                	lw	a5,80(s1)
   104a6:	c78d                	beqz	a5,104d0 <_reclaim_reent+0xa4>
   104a8:	6cbc                	ld	a5,88(s1)
   104aa:	8526                	mv	a0,s1
   104ac:	9782                	jalr	a5
   104ae:	5204b403          	ld	s0,1312(s1)
   104b2:	cc19                	beqz	s0,104d0 <_reclaim_reent+0xa4>
   104b4:	600c                	ld	a1,0(s0)
   104b6:	c581                	beqz	a1,104be <_reclaim_reent+0x92>
   104b8:	8526                	mv	a0,s1
   104ba:	f11ff0ef          	jal	103ca <cleanup_glue>
   104be:	85a2                	mv	a1,s0
   104c0:	7402                	ld	s0,32(sp)
   104c2:	70a2                	ld	ra,40(sp)
   104c4:	6942                	ld	s2,16(sp)
   104c6:	8526                	mv	a0,s1
   104c8:	64e2                	ld	s1,24(sp)
   104ca:	6145                	addi	sp,sp,48
   104cc:	bddff06f          	j	100a8 <_free_r>
   104d0:	70a2                	ld	ra,40(sp)
   104d2:	7402                	ld	s0,32(sp)
   104d4:	64e2                	ld	s1,24(sp)
   104d6:	6942                	ld	s2,16(sp)
   104d8:	6145                	addi	sp,sp,48
   104da:	8082                	ret
   104dc:	8082                	ret

00000000000104de <_sbrk>:
   104de:	00031317          	auipc	t1,0x31
   104e2:	bda30313          	addi	t1,t1,-1062 # 410b8 <heap_end.0>
   104e6:	00033783          	ld	a5,0(t1)
   104ea:	1141                	addi	sp,sp,-16
   104ec:	e406                	sd	ra,8(sp)
   104ee:	882a                	mv	a6,a0
   104f0:	e385                	bnez	a5,10510 <_sbrk+0x32>
   104f2:	4501                	li	a0,0
   104f4:	4581                	li	a1,0
   104f6:	4601                	li	a2,0
   104f8:	4681                	li	a3,0
   104fa:	4701                	li	a4,0
   104fc:	0d600893          	li	a7,214
   10500:	00000073          	ecall
   10504:	577d                	li	a4,-1
   10506:	87aa                	mv	a5,a0
   10508:	02e50a63          	beq	a0,a4,1053c <_sbrk+0x5e>
   1050c:	00a33023          	sd	a0,0(t1)
   10510:	00f80533          	add	a0,a6,a5
   10514:	4581                	li	a1,0
   10516:	4601                	li	a2,0
   10518:	4681                	li	a3,0
   1051a:	4701                	li	a4,0
   1051c:	4781                	li	a5,0
   1051e:	0d600893          	li	a7,214
   10522:	00000073          	ecall
   10526:	00033783          	ld	a5,0(t1)
   1052a:	983e                	add	a6,a6,a5
   1052c:	01051863          	bne	a0,a6,1053c <_sbrk+0x5e>
   10530:	60a2                	ld	ra,8(sp)
   10532:	00a33023          	sd	a0,0(t1)
   10536:	853e                	mv	a0,a5
   10538:	0141                	addi	sp,sp,16
   1053a:	8082                	ret
   1053c:	010000ef          	jal	1054c <__errno>
   10540:	60a2                	ld	ra,8(sp)
   10542:	47b1                	li	a5,12
   10544:	c11c                	sw	a5,0(a0)
   10546:	557d                	li	a0,-1
   10548:	0141                	addi	sp,sp,16
   1054a:	8082                	ret

000000000001054c <__errno>:
   1054c:	00031517          	auipc	a0,0x31
   10550:	a6453503          	ld	a0,-1436(a0) # 40fb0 <_impure_ptr>
   10554:	8082                	ret
