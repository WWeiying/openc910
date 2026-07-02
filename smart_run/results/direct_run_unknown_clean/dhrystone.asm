
dhrystone.elf:     file format elf64-littleriscv


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
      8a:	21cd                	addiw	gp,gp,19 # 70013 <heap_end.0+0x2c763>
      8c:	7c21a073          	csrs	mcor,gp
      90:	6185                	lui	gp,0x1
      92:	1ff1819b          	addiw	gp,gp,511 # 11ff <_ftoa+0x41f>
      96:	7c11a073          	csrs	mhcr,gp

000000000000009a <after_l2en>:
      9a:	6185                	lui	gp,0x1
      9c:	1ff1819b          	addiw	gp,gp,511 # 11ff <_ftoa+0x41f>
      a0:	7c11a073          	csrs	mhcr,gp
      a4:	0006e1b7          	lui	gp,0x6e
      a8:	30c1819b          	addiw	gp,gp,780 # 6e30c <heap_end.0+0x2aa5c>
      ac:	7c51a073          	csrs	mhint,gp
      b0:	0070019b          	addiw	gp,zero,7
      b4:	01f6                	slli	gp,gp,0x1d
      b6:	01a5                	addi	gp,gp,9
      b8:	7c31a073          	csrs	mccr2,gp
      bc:	704000ef          	jal	7c0 <main>

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

0000000000000670 <Proc_1>:
     670:	1101                	addi	sp,sp,-32
     672:	f891590b          	th.sdd	s2,s1,(sp),0,4
     676:	00041937          	lui	s2,0x41
     67a:	f9090913          	addi	s2,s2,-112 # 40f90 <Next_Ptr_Glob>
     67e:	04093783          	ld	a5,64(s2)
     682:	fa11540b          	th.sdd	s0,ra,(sp),1,4
     686:	6100                	ld	s0,0(a0)
     688:	f8d7c88b          	th.ldd	a7,a3,(a5),0,4
     68c:	fcc7c58b          	th.ldd	a1,a2,(a5),2,4
     690:	7b98                	ld	a4,48(a5)
     692:	84aa                	mv	s1,a0
     694:	faa7c80b          	th.ldd	a6,a0,(a5),1,4
     698:	f8d4588b          	th.sdd	a7,a3,(s0),0,4
     69c:	6094                	ld	a3,0(s1)
     69e:	faa4580b          	th.sdd	a6,a0,(s0),1,4
     6a2:	fcc4558b          	th.sdd	a1,a2,(s0),2,4
     6a6:	f818                	sd	a4,48(s0)
     6a8:	4715                	li	a4,5
     6aa:	c898                	sw	a4,16(s1)
     6ac:	e014                	sd	a3,0(s0)
     6ae:	639c                	ld	a5,0(a5)
     6b0:	16892583          	lw	a1,360(s2)
     6b4:	4529                	li	a0,10
     6b6:	e01c                	sd	a5,0(s0)
     6b8:	04093603          	ld	a2,64(s2)
     6bc:	c818                	sw	a4,16(s0)
     6be:	0641                	addi	a2,a2,16
     6c0:	5f0000ef          	jal	cb0 <Proc_7>
     6c4:	441c                	lw	a5,8(s0)
     6c6:	c79d                	beqz	a5,6f4 <Proc_1+0x84>
     6c8:	609c                	ld	a5,0(s1)
     6ca:	fa11440b          	th.ldd	s0,ra,(sp),1,4
     6ce:	f8a7c80b          	th.ldd	a6,a0,(a5),0,4
     6d2:	fac7c58b          	th.ldd	a1,a2,(a5),1,4
     6d6:	fce7c68b          	th.ldd	a3,a4,(a5),2,4
     6da:	7b9c                	ld	a5,48(a5)
     6dc:	f8a4d80b          	th.sdd	a6,a0,(s1),0,4
     6e0:	fac4d58b          	th.sdd	a1,a2,(s1),1,4
     6e4:	fce4d68b          	th.sdd	a3,a4,(s1),2,4
     6e8:	f89c                	sd	a5,48(s1)
     6ea:	f891490b          	th.ldd	s2,s1,(sp),0,4
     6ee:	6105                	addi	sp,sp,32
     6f0:	8082                	ret
     6f2:	0001                	nop
     6f4:	44c8                	lw	a0,12(s1)
     6f6:	4799                	li	a5,6
     6f8:	00c40593          	addi	a1,s0,12
     6fc:	c81c                	sw	a5,16(s0)
     6fe:	572000ef          	jal	c70 <Proc_6>
     702:	04093783          	ld	a5,64(s2)
     706:	8622                	mv	a2,s0
     708:	fa11440b          	th.ldd	s0,ra,(sp),1,4
     70c:	639c                	ld	a5,0(a5)
     70e:	f891490b          	th.ldd	s2,s1,(sp),0,4
     712:	4a08                	lw	a0,16(a2)
     714:	7a86578b          	th.sdia	a5,(a2),8,1
     718:	45a9                	li	a1,10
     71a:	6105                	addi	sp,sp,32
     71c:	5940006f          	j	cb0 <Proc_7>

0000000000000720 <Proc_2>:
     720:	000417b7          	lui	a5,0x41
     724:	f9078793          	addi	a5,a5,-112 # 40f90 <Next_Ptr_Glob>
     728:	0907c683          	lbu	a3,144(a5)
     72c:	04100713          	li	a4,65
     730:	00e68463          	beq	a3,a4,738 <Proc_2+0x18>
     734:	8082                	ret
     736:	0001                	nop
     738:	4118                	lw	a4,0(a0)
     73a:	1687a683          	lw	a3,360(a5)
     73e:	0097079b          	addiw	a5,a4,9
     742:	9f95                	subw	a5,a5,a3
     744:	c11c                	sw	a5,0(a0)
     746:	8082                	ret
     748:	00000013          	nop
     74c:	00000013          	nop

0000000000000750 <Proc_3>:
     750:	000417b7          	lui	a5,0x41
     754:	f9078793          	addi	a5,a5,-112 # 40f90 <Next_Ptr_Glob>
     758:	63b0                	ld	a2,64(a5)
     75a:	c601                	beqz	a2,762 <Proc_3+0x12>
     75c:	6218                	ld	a4,0(a2)
     75e:	e118                	sd	a4,0(a0)
     760:	63b0                	ld	a2,64(a5)
     762:	1687a583          	lw	a1,360(a5)
     766:	0641                	addi	a2,a2,16
     768:	4529                	li	a0,10
     76a:	5460006f          	j	cb0 <Proc_7>
     76e:	0001                	nop

0000000000000770 <Proc_4>:
     770:	000417b7          	lui	a5,0x41
     774:	f9078793          	addi	a5,a5,-112 # 40f90 <Next_Ptr_Glob>
     778:	0907c703          	lbu	a4,144(a5)
     77c:	0947a683          	lw	a3,148(a5)
     780:	04200613          	li	a2,66
     784:	fbf70713          	addi	a4,a4,-65
     788:	00173713          	seqz	a4,a4
     78c:	8f55                	or	a4,a4,a3
     78e:	08c78c23          	sb	a2,152(a5)
     792:	08e7aa23          	sw	a4,148(a5)
     796:	8082                	ret
     798:	00000013          	nop
     79c:	00000013          	nop

00000000000007a0 <Proc_5>:
     7a0:	000417b7          	lui	a5,0x41
     7a4:	f9078793          	addi	a5,a5,-112 # 40f90 <Next_Ptr_Glob>
     7a8:	04100713          	li	a4,65
     7ac:	08e78823          	sb	a4,144(a5)
     7b0:	0807aa23          	sw	zero,148(a5)
     7b4:	8082                	ret
	...

00000000000007c0 <main>:
     7c0:	6795                	lui	a5,0x5
     7c2:	54078713          	addi	a4,a5,1344 # 5540 <__errno+0x1a4>
     7c6:	6795                	lui	a5,0x5
     7c8:	7155                	addi	sp,sp,-208
     7ca:	52078793          	addi	a5,a5,1312 # 5520 <__errno+0x184>
     7ce:	e1f7c68b          	th.lwd	a3,t6,(a5),0,3
     7d2:	e3e7c60b          	th.lwd	a2,t5,(a5),1,3
     7d6:	e5c7ce8b          	th.lwd	t4,t3,(a5),2,3
     7da:	01c7d883          	lhu	a7,28(a5)
     7de:	01e7c803          	lbu	a6,30(a5)
     7e2:	0187a303          	lw	t1,24(a5)
     7e6:	f8b7428b          	th.ldd	t0,a1,(a4),0,4
     7ea:	fd26                	sd	s1,184(sp)
     7ec:	e1a2                	sd	s0,192(sp)
     7ee:	4785                	li	a5,1
     7f0:	00041437          	lui	s0,0x41
     7f4:	f9040413          	addi	s0,s0,-112 # 40f90 <Next_Ptr_Glob>
     7f8:	e586                	sd	ra,200(sp)
     7fa:	e55e                	sd	s7,136(sp)
     7fc:	e95a                	sd	s6,144(sp)
     7fe:	f4ee                	sd	s11,104(sp)
     800:	f8ea                	sd	s10,112(sp)
     802:	fce6                	sd	s9,120(sp)
     804:	e162                	sd	s8,128(sp)
     806:	ed56                	sd	s5,152(sp)
     808:	f152                	sd	s4,160(sp)
     80a:	f54e                	sd	s3,168(sp)
     80c:	f94a                	sd	s2,176(sp)
     80e:	1786                	slli	a5,a5,0x21
     810:	e83c                	sd	a5,80(s0)
     812:	02800793          	li	a5,40
     816:	fcb1528b          	th.sdd	t0,a1,(sp),2,4
     81a:	cc3c                	sw	a5,88(s0)
     81c:	cc74                	sw	a3,92(s0)
     81e:	87a2                	mv	a5,s0
     820:	00840693          	addi	a3,s0,8
     824:	6b08                	ld	a0,16(a4)
     826:	4f0c                	lw	a1,24(a4)
     828:	07f42023          	sw	t6,96(s0)
     82c:	d070                	sw	a2,100(s0)
     82e:	7e97d68b          	th.sdia	a3,(a5),9,3
     832:	e03c                	sd	a5,64(s0)
     834:	e434                	sd	a3,72(s0)
     836:	01e74783          	lbu	a5,30(a4)
     83a:	01c75603          	lhu	a2,28(a4)
     83e:	44a9                	li	s1,10
     840:	00041bb7          	lui	s7,0x41
     844:	f82a                	sd	a0,48(sp)
     846:	02f10f23          	sb	a5,62(sp)
     84a:	8526                	mv	a0,s1
     84c:	118b8793          	addi	a5,s7,280 # 41118 <Arr_2_Glob>
     850:	07e42423          	sw	t5,104(s0)
     854:	07d42623          	sw	t4,108(s0)
     858:	07c42823          	sw	t3,112(s0)
     85c:	06642a23          	sw	t1,116(s0)
     860:	6497ae23          	sw	s1,1628(a5)
     864:	07141c23          	sh	a7,120(s0)
     868:	07040d23          	sb	a6,122(s0)
     86c:	02c11e23          	sh	a2,60(sp)
     870:	dc2e                	sw	a1,56(sp)
     872:	6ae030ef          	jal	3f20 <putchar>
     876:	6515                	lui	a0,0x5
     878:	3a850513          	addi	a0,a0,936 # 53a8 <__errno+0xc>
     87c:	664030ef          	jal	3ee0 <puts>
     880:	8526                	mv	a0,s1
     882:	69e030ef          	jal	3f20 <putchar>
     886:	08042783          	lw	a5,128(s0)
     88a:	2e078a63          	beqz	a5,b7e <perf_monitor_end+0x16e>
     88e:	6515                	lui	a0,0x5
     890:	3e050513          	addi	a0,a0,992 # 53e0 <__errno+0x44>
     894:	64c030ef          	jal	3ee0 <puts>
     898:	8526                	mv	a0,s1
     89a:	686030ef          	jal	3f20 <putchar>
     89e:	4529                	li	a0,10
     8a0:	680030ef          	jal	3f20 <putchar>
     8a4:	6515                	lui	a0,0x5
     8a6:	3e800593          	li	a1,1000
     8aa:	44050513          	addi	a0,a0,1088 # 5440 <__errno+0xa4>
     8ae:	692030ef          	jal	3f40 <printf>
     8b2:	4af030ef          	jal	4560 <get_vtimer>
     8b6:	7c05378b          	th.extu	a5,a0,31,0
     8ba:	e45c                	sd	a5,136(s0)

00000000000008bc <perf_monitor_start>:
     8bc:	6795                	lui	a5,0x5
     8be:	56078a13          	addi	s4,a5,1376 # 5560 <__errno+0x1c4>
     8c2:	f99a4d0b          	th.ldd	s10,s9,(s4),0,4
     8c6:	010a3c03          	ld	s8,16(s4)
     8ca:	00041b37          	lui	s6,0x41
     8ce:	6495                	lui	s1,0x5
     8d0:	030b0b13          	addi	s6,s6,48 # 41030 <Arr_1_Glob>
     8d4:	5a048493          	addi	s1,s1,1440 # 55a0 <__errno+0x204>
     8d8:	4905                	li	s2,1
     8da:	04100a93          	li	s5,65
     8de:	0001                	nop
     8e0:	018a2683          	lw	a3,24(s4)
     8e4:	01ca5703          	lhu	a4,28(s4)
     8e8:	01ea4783          	lbu	a5,30(s4)
     8ec:	04200813          	li	a6,66
     8f0:	4605                	li	a2,1
     8f2:	008c                	addi	a1,sp,64
     8f4:	1008                	addi	a0,sp,32
     8f6:	09040c23          	sb	a6,152(s0)
     8fa:	ccb6                	sw	a3,88(sp)
     8fc:	04e11e23          	sh	a4,92(sp)
     900:	04f10f23          	sb	a5,94(sp)
     904:	ce32                	sw	a2,28(sp)
     906:	e0ea                	sd	s10,64(sp)
     908:	e4e6                	sd	s9,72(sp)
     90a:	08c42a23          	sw	a2,148(s0)
     90e:	09540823          	sb	s5,144(s0)
     912:	e8e2                	sd	s8,80(sp)
     914:	41c000ef          	jal	d30 <Func_2>
     918:	00153793          	seqz	a5,a0
     91c:	471d                	li	a4,7
     91e:	0830                	addi	a2,sp,24
     920:	458d                	li	a1,3
     922:	4509                	li	a0,2
     924:	cc3a                	sw	a4,24(sp)
     926:	08f42a23          	sw	a5,148(s0)
     92a:	386000ef          	jal	cb0 <Proc_7>
     92e:	46e2                	lw	a3,24(sp)
     930:	118b8593          	addi	a1,s7,280
     934:	460d                	li	a2,3
     936:	855a                	mv	a0,s6
     938:	388000ef          	jal	cc0 <Proc_8>
     93c:	04043983          	ld	s3,64(s0)
     940:	4715                	li	a4,5
     942:	16842583          	lw	a1,360(s0)
     946:	f8c9cd8b          	th.ldd	s11,a2,(s3),0,4
     94a:	fa69c68b          	th.ldd	a3,t1,(s3),1,4
     94e:	0309b503          	ld	a0,48(s3)
     952:	fd09c88b          	th.ldd	a7,a6,(s3),2,4
     956:	f8cddd8b          	th.sdd	s11,a2,(s11),0,4
     95a:	864e                	mv	a2,s3
     95c:	00ddb823          	sd	a3,16(s11)
     960:	7a86468b          	th.ldia	a3,(a2),8,1
     964:	02adb823          	sd	a0,48(s11)
     968:	006dbc23          	sd	t1,24(s11)
     96c:	fd0dd88b          	th.sdd	a7,a6,(s11),2,4
     970:	00e9a823          	sw	a4,16(s3)
     974:	00eda823          	sw	a4,16(s11)
     978:	4529                	li	a0,10
     97a:	00ddb023          	sd	a3,0(s11)
     97e:	332000ef          	jal	cb0 <Proc_7>
     982:	008da703          	lw	a4,8(s11)
     986:	1c070163          	beqz	a4,b48 <perf_monitor_end+0x138>
     98a:	0009b783          	ld	a5,0(s3)
     98e:	fce7c68b          	th.ldd	a3,a4,(a5),2,4
     992:	f8a7c80b          	th.ldd	a6,a0,(a5),0,4
     996:	fac7c58b          	th.ldd	a1,a2,(a5),1,4
     99a:	7b9c                	ld	a5,48(a5)
     99c:	fce9d68b          	th.sdd	a3,a4,(s3),2,4
     9a0:	09844703          	lbu	a4,152(s0)
     9a4:	02f9b823          	sd	a5,48(s3)
     9a8:	f8a9d80b          	th.sdd	a6,a0,(s3),0,4
     9ac:	fac9d58b          	th.sdd	a1,a2,(s3),1,4
     9b0:	04000793          	li	a5,64
     9b4:	1ce7f363          	bgeu	a5,a4,b7a <perf_monitor_end+0x16a>
     9b8:	04100d93          	li	s11,65
     9bc:	498d                	li	s3,3
     9be:	0001                	nop
     9c0:	04300593          	li	a1,67
     9c4:	856e                	mv	a0,s11
     9c6:	34a000ef          	jal	d10 <Func_1>
     9ca:	4772                	lw	a4,28(sp)
     9cc:	12a70e63          	beq	a4,a0,b08 <perf_monitor_end+0xf8>
     9d0:	09844703          	lbu	a4,152(s0)
     9d4:	001d879b          	addiw	a5,s11,1
     9d8:	0ff7fd93          	zext.b	s11,a5
     9dc:	ffb772e3          	bgeu	a4,s11,9c0 <perf_monitor_start+0x104>
     9e0:	0019979b          	slliw	a5,s3,0x1
     9e4:	013789bb          	addw	s3,a5,s3
     9e8:	4662                	lw	a2,24(sp)
     9ea:	09044703          	lbu	a4,144(s0)
     9ee:	02c9cdbb          	divw	s11,s3,a2
     9f2:	87ee                	mv	a5,s11
     9f4:	01571763          	bne	a4,s5,a02 <perf_monitor_start+0x146>
     9f8:	16842703          	lw	a4,360(s0)
     9fc:	009d879b          	addiw	a5,s11,9
     a00:	9f99                	subw	a5,a5,a4
     a02:	2905                	addiw	s2,s2,1
     a04:	3e900713          	li	a4,1001
     a08:	ece91ce3          	bne	s2,a4,8e0 <perf_monitor_start+0x24>
     a0c:	f8f1560b          	th.sdd	a2,a5,(sp),0,4

0000000000000a10 <perf_monitor_end>:
     a10:	351030ef          	jal	4560 <get_vtimer>
     a14:	872a                	mv	a4,a0
     a16:	6515                	lui	a0,0x5
     a18:	7c07370b          	th.extu	a4,a4,31,0
     a1c:	47050513          	addi	a0,a0,1136 # 5470 <__errno+0xd4>
     a20:	16e43823          	sd	a4,368(s0)
     a24:	4bc030ef          	jal	3ee0 <puts>
     a28:	08843803          	ld	a6,136(s0)
     a2c:	17043703          	ld	a4,368(s0)
     a30:	6595                	lui	a1,0x5
     a32:	6515                	lui	a0,0x5
     a34:	41070733          	sub	a4,a4,a6
     a38:	5e052707          	flw	fa4,1504(a0) # 55e0 <__errno+0x244>
     a3c:	5e45a787          	flw	fa5,1508(a1) # 55e4 <__errno+0x248>
     a40:	d02776d3          	fcvt.s.l	fa3,a4
     a44:	6515                	lui	a0,0x5
     a46:	18e6f753          	fdiv.s	fa4,fa3,fa4
     a4a:	48050513          	addi	a0,a0,1152 # 5480 <__errno+0xe4>
     a4e:	16e43c23          	sd	a4,376(s0)
     a52:	6495                	lui	s1,0x5
     a54:	18d7f7d3          	fdiv.s	fa5,fa5,fa3
     a58:	18e42027          	fsw	fa4,384(s0)
     a5c:	18f42227          	fsw	fa5,388(s0)
     a60:	4e0030ef          	jal	3f40 <printf>
     a64:	18042787          	flw	fa5,384(s0)
     a68:	4b048513          	addi	a0,s1,1200 # 54b0 <__errno+0x114>
     a6c:	420787d3          	fcvt.d.s	fa5,fa5
     a70:	e20785d3          	fmv.x.d	a1,fa5
     a74:	4cc030ef          	jal	3f40 <printf>
     a78:	6515                	lui	a0,0x5
     a7a:	4b850513          	addi	a0,a0,1208 # 54b8 <__errno+0x11c>
     a7e:	4c2030ef          	jal	3f40 <printf>
     a82:	18442787          	flw	fa5,388(s0)
     a86:	4b048513          	addi	a0,s1,1200
     a8a:	420787d3          	fcvt.d.s	fa5,fa5
     a8e:	e20785d3          	fmv.x.d	a1,fa5
     a92:	4ae030ef          	jal	3f40 <printf>
     a96:	6515                	lui	a0,0x5
     a98:	4e850513          	addi	a0,a0,1256 # 54e8 <__errno+0x14c>
     a9c:	4a4030ef          	jal	3f40 <printf>
     aa0:	6715                	lui	a4,0x5
     aa2:	5e872707          	flw	fa4,1512(a4) # 55e8 <__errno+0x24c>
     aa6:	18442787          	flw	fa5,388(s0)
     aaa:	6515                	lui	a0,0x5
     aac:	51850513          	addi	a0,a0,1304 # 5518 <__errno+0x17c>
     ab0:	18e7f7d3          	fdiv.s	fa5,fa5,fa4
     ab4:	420787d3          	fcvt.d.s	fa5,fa5
     ab8:	e20785d3          	fmv.x.d	a1,fa5
     abc:	484030ef          	jal	3f40 <printf>
     ac0:	4529                	li	a0,10
     ac2:	45e030ef          	jal	3f20 <putchar>
     ac6:	16842583          	lw	a1,360(s0)
     aca:	4715                	li	a4,5
     acc:	00e59763          	bne	a1,a4,ada <perf_monitor_end+0xca>
     ad0:	09442703          	lw	a4,148(s0)
     ad4:	4585                	li	a1,1
     ad6:	0ab70d63          	beq	a4,a1,b90 <perf_monitor_end+0x180>
     ada:	6515                	lui	a0,0x5
     adc:	59050513          	addi	a0,a0,1424 # 5590 <__errno+0x1f4>
     ae0:	400030ef          	jal	3ee0 <puts>
     ae4:	28d030ef          	jal	4570 <sim_end>
     ae8:	60ae                	ld	ra,200(sp)
     aea:	74ea                	ld	s1,184(sp)
     aec:	640e                	ld	s0,192(sp)
     aee:	7da6                	ld	s11,104(sp)
     af0:	7d46                	ld	s10,112(sp)
     af2:	7ce6                	ld	s9,120(sp)
     af4:	6c0a                	ld	s8,128(sp)
     af6:	6baa                	ld	s7,136(sp)
     af8:	6b4a                	ld	s6,144(sp)
     afa:	6aea                	ld	s5,152(sp)
     afc:	7a0a                	ld	s4,160(sp)
     afe:	79aa                	ld	s3,168(sp)
     b00:	794a                	ld	s2,176(sp)
     b02:	4501                	li	a0,0
     b04:	6169                	addi	sp,sp,208
     b06:	8082                	ret
     b08:	086c                	addi	a1,sp,28
     b0a:	4501                	li	a0,0
     b0c:	164000ef          	jal	c70 <Proc_6>
     b10:	01c4d683          	lhu	a3,28(s1)
     b14:	01e4c703          	lbu	a4,30(s1)
     b18:	4c90                	lw	a2,24(s1)
     b1a:	f904c88b          	th.ldd	a7,a6,(s1),0,4
     b1e:	6888                	ld	a0,16(s1)
     b20:	09844583          	lbu	a1,152(s0)
     b24:	001d879b          	addiw	a5,s11,1
     b28:	e0c6                	sd	a7,64(sp)
     b2a:	e4c2                	sd	a6,72(sp)
     b2c:	0ff7fd93          	zext.b	s11,a5
     b30:	04d11e23          	sh	a3,92(sp)
     b34:	04e10f23          	sb	a4,94(sp)
     b38:	e8aa                	sd	a0,80(sp)
     b3a:	ccb2                	sw	a2,88(sp)
     b3c:	17242423          	sw	s2,360(s0)
     b40:	89ca                	mv	s3,s2
     b42:	e7b5ffe3          	bgeu	a1,s11,9c0 <perf_monitor_start+0x104>
     b46:	bd69                	j	9e0 <perf_monitor_start+0x124>
     b48:	00c9a503          	lw	a0,12(s3)
     b4c:	4719                	li	a4,6
     b4e:	00cd8593          	addi	a1,s11,12
     b52:	00eda823          	sw	a4,16(s11)
     b56:	11a000ef          	jal	c70 <Proc_6>
     b5a:	6038                	ld	a4,64(s0)
     b5c:	010da503          	lw	a0,16(s11)
     b60:	866e                	mv	a2,s11
     b62:	631c                	ld	a5,0(a4)
     b64:	45a9                	li	a1,10
     b66:	7a86578b          	th.sdia	a5,(a2),8,1
     b6a:	146000ef          	jal	cb0 <Proc_7>
     b6e:	09844703          	lbu	a4,152(s0)
     b72:	04000793          	li	a5,64
     b76:	e4e7e1e3          	bltu	a5,a4,9b8 <perf_monitor_start+0xfc>
     b7a:	49a5                	li	s3,9
     b7c:	b5b5                	j	9e8 <perf_monitor_start+0x12c>
     b7e:	6515                	lui	a0,0x5
     b80:	41050513          	addi	a0,a0,1040 # 5410 <__errno+0x74>
     b84:	35c030ef          	jal	3ee0 <puts>
     b88:	8526                	mv	a0,s1
     b8a:	396030ef          	jal	3f20 <putchar>
     b8e:	bb01                	j	89e <main+0xde>
     b90:	09044503          	lbu	a0,144(s0)
     b94:	04100593          	li	a1,65
     b98:	f4b511e3          	bne	a0,a1,ada <perf_monitor_end+0xca>
     b9c:	09844503          	lbu	a0,152(s0)
     ba0:	04200593          	li	a1,66
     ba4:	f2b51be3          	bne	a0,a1,ada <perf_monitor_end+0xca>
     ba8:	0c042503          	lw	a0,192(s0)
     bac:	459d                	li	a1,7
     bae:	f2b516e3          	bne	a0,a1,ada <perf_monitor_end+0xca>
     bb2:	000416b7          	lui	a3,0x41
     bb6:	11868693          	addi	a3,a3,280 # 41118 <Arr_2_Glob>
     bba:	65c6a503          	lw	a0,1628(a3)
     bbe:	3f200593          	li	a1,1010
     bc2:	f0b51ce3          	bne	a0,a1,ada <perf_monitor_end+0xca>
     bc6:	6028                	ld	a0,64(s0)
     bc8:	1706                	slli	a4,a4,0x21
     bca:	650c                	ld	a1,8(a0)
     bcc:	f0e597e3          	bne	a1,a4,ada <perf_monitor_end+0xca>
     bd0:	490c                	lw	a1,16(a0)
     bd2:	4745                	li	a4,17
     bd4:	f0e593e3          	bne	a1,a4,ada <perf_monitor_end+0xca>
     bd8:	6795                	lui	a5,0x5
     bda:	0551                	addi	a0,a0,20
     bdc:	52078593          	addi	a1,a5,1312 # 5520 <__errno+0x184>
     be0:	070040ef          	jal	4c50 <strcmp>
     be4:	ee051be3          	bnez	a0,ada <perf_monitor_end+0xca>
     be8:	6008                	ld	a0,0(s0)
     bea:	4705                	li	a4,1
     bec:	1702                	slli	a4,a4,0x20
     bee:	650c                	ld	a1,8(a0)
     bf0:	4405                	li	s0,1
     bf2:	eee594e3          	bne	a1,a4,ada <perf_monitor_end+0xca>
     bf6:	490c                	lw	a1,16(a0)
     bf8:	4749                	li	a4,18
     bfa:	eee590e3          	bne	a1,a4,ada <perf_monitor_end+0xca>
     bfe:	6795                	lui	a5,0x5
     c00:	52078593          	addi	a1,a5,1312 # 5520 <__errno+0x184>
     c04:	0551                	addi	a0,a0,20
     c06:	04a040ef          	jal	4c50 <strcmp>
     c0a:	ec0518e3          	bnez	a0,ada <perf_monitor_end+0xca>
     c0e:	f8f1460b          	th.ldd	a2,a5,(sp),0,4
     c12:	4715                	li	a4,5
     c14:	ece793e3          	bne	a5,a4,ada <perf_monitor_end+0xca>
     c18:	40c989bb          	subw	s3,s3,a2
     c1c:	479d                	li	a5,7
     c1e:	033787bb          	mulw	a5,a5,s3
     c22:	4735                	li	a4,13
     c24:	41b787bb          	subw	a5,a5,s11
     c28:	eae799e3          	bne	a5,a4,ada <perf_monitor_end+0xca>
     c2c:	4762                	lw	a4,24(sp)
     c2e:	479d                	li	a5,7
     c30:	eaf715e3          	bne	a4,a5,ada <perf_monitor_end+0xca>
     c34:	47f2                	lw	a5,28(sp)
     c36:	ea8792e3          	bne	a5,s0,ada <perf_monitor_end+0xca>
     c3a:	6795                	lui	a5,0x5
     c3c:	54078593          	addi	a1,a5,1344 # 5540 <__errno+0x1a4>
     c40:	1008                	addi	a0,sp,32
     c42:	00e040ef          	jal	4c50 <strcmp>
     c46:	e8051ae3          	bnez	a0,ada <perf_monitor_end+0xca>
     c4a:	6795                	lui	a5,0x5
     c4c:	56078593          	addi	a1,a5,1376 # 5560 <__errno+0x1c4>
     c50:	0088                	addi	a0,sp,64
     c52:	7ff030ef          	jal	4c50 <strcmp>
     c56:	e80512e3          	bnez	a0,ada <perf_monitor_end+0xca>
     c5a:	6515                	lui	a0,0x5
     c5c:	58050513          	addi	a0,a0,1408 # 5580 <__errno+0x1e4>
     c60:	280030ef          	jal	3ee0 <puts>
     c64:	b541                	j	ae4 <perf_monitor_end+0xd4>
	...

0000000000000c70 <Proc_6>:
     c70:	4789                	li	a5,2
     c72:	02f50963          	beq	a0,a5,ca4 <Proc_6+0x34>
     c76:	470d                	li	a4,3
     c78:	c198                	sw	a4,0(a1)
     c7a:	4705                	li	a4,1
     c7c:	00e50863          	beq	a0,a4,c8c <Proc_6+0x1c>
     c80:	4711                	li	a4,4
     c82:	02e50563          	beq	a0,a4,cac <Proc_6+0x3c>
     c86:	c919                	beqz	a0,c9c <Proc_6+0x2c>
     c88:	8082                	ret
     c8a:	0001                	nop
     c8c:	000417b7          	lui	a5,0x41
     c90:	0f87a703          	lw	a4,248(a5) # 410f8 <Int_Glob>
     c94:	06400793          	li	a5,100
     c98:	fee7d8e3          	bge	a5,a4,c88 <Proc_6+0x18>
     c9c:	0005a023          	sw	zero,0(a1)
     ca0:	8082                	ret
     ca2:	0001                	nop
     ca4:	4785                	li	a5,1
     ca6:	c19c                	sw	a5,0(a1)
     ca8:	8082                	ret
     caa:	0001                	nop
     cac:	c19c                	sw	a5,0(a1)
     cae:	8082                	ret

0000000000000cb0 <Proc_7>:
     cb0:	2509                	addiw	a0,a0,2
     cb2:	9d2d                	addw	a0,a0,a1
     cb4:	c208                	sw	a0,0(a2)
     cb6:	8082                	ret
     cb8:	00000013          	nop
     cbc:	00000013          	nop

0000000000000cc0 <Proc_8>:
     cc0:	0056079b          	addiw	a5,a2,5
     cc4:	0c800813          	li	a6,200
     cc8:	03078833          	mul	a6,a5,a6
     ccc:	060a                	slli	a2,a2,0x2
     cce:	44f5568b          	th.srw	a3,a0,a5,2
     cd2:	04f5188b          	th.addsl	a7,a0,a5,2
     cd6:	00c80733          	add	a4,a6,a2
     cda:	06f8ac23          	sw	a5,120(a7)
     cde:	00d8a223          	sw	a3,4(a7)
     ce2:	972e                	add	a4,a4,a1
     ce4:	4b14                	lw	a3,16(a4)
     ce6:	cf1c                	sw	a5,24(a4)
     ce8:	95c2                	add	a1,a1,a6
     cea:	2685                	addiw	a3,a3,1
     cec:	e4f7568b          	th.swd	a3,a5,(a4),2,3
     cf0:	44f5468b          	th.lrw	a3,a0,a5,2
     cf4:	95b2                	add	a1,a1,a2
     cf6:	7ff58593          	addi	a1,a1,2047
     cfa:	000417b7          	lui	a5,0x41
     cfe:	4715                	li	a4,5
     d00:	0ee7ac23          	sw	a4,248(a5) # 410f8 <Int_Glob>
     d04:	7ad5aaa3          	sw	a3,1973(a1)
     d08:	8082                	ret
     d0a:	00000013          	nop
     d0e:	0001                	nop

0000000000000d10 <Func_1>:
     d10:	0ff57513          	zext.b	a0,a0
     d14:	0ff5f593          	zext.b	a1,a1
     d18:	00b50463          	beq	a0,a1,d20 <Func_1+0x10>
     d1c:	4501                	li	a0,0
     d1e:	8082                	ret
     d20:	000417b7          	lui	a5,0x41
     d24:	02a78023          	sb	a0,32(a5) # 41020 <Ch_1_Glob>
     d28:	4505                	li	a0,1
     d2a:	8082                	ret
     d2c:	00000013          	nop

0000000000000d30 <Func_2>:
     d30:	00254703          	lbu	a4,2(a0)
     d34:	0035c783          	lbu	a5,3(a1)
     d38:	02f70363          	beq	a4,a5,d5e <Func_2+0x2e>
     d3c:	1141                	addi	sp,sp,-16
     d3e:	e406                	sd	ra,8(sp)
     d40:	711030ef          	jal	4c50 <strcmp>
     d44:	4781                	li	a5,0
     d46:	00a05863          	blez	a0,d56 <Func_2+0x26>
     d4a:	000417b7          	lui	a5,0x41
     d4e:	4729                	li	a4,10
     d50:	0ee7ac23          	sw	a4,248(a5) # 410f8 <Int_Glob>
     d54:	4785                	li	a5,1
     d56:	60a2                	ld	ra,8(sp)
     d58:	853e                	mv	a0,a5
     d5a:	0141                	addi	sp,sp,16
     d5c:	8082                	ret
     d5e:	a001                	j	d5e <Func_2+0x2e>

0000000000000d60 <Func_3>:
     d60:	1579                	addi	a0,a0,-2
     d62:	00153513          	seqz	a0,a0
     d66:	8082                	ret
	...

0000000000000d70 <fputc>:
     d70:	020007b7          	lui	a5,0x2000
     d74:	fea7a823          	sw	a0,-16(a5) # 1fffff0 <__kernel_stack+0x1f11ff0>
     d78:	8082                	ret
     d7a:	00000013          	nop
     d7e:	0001                	nop

0000000000000d80 <os_critical_enter>:
     d80:	8082                	ret
     d82:	0001                	nop
     d84:	00000013          	nop
     d88:	00000013          	nop
     d8c:	00000013          	nop

0000000000000d90 <os_critical_exit>:
     d90:	8082                	ret
	...

0000000000000da0 <_out_buffer>:
     da0:	00d67463          	bgeu	a2,a3,da8 <_out_buffer+0x8>
     da4:	00c5d50b          	th.srb	a0,a1,a2,0
     da8:	8082                	ret
     daa:	00000013          	nop
     dae:	0001                	nop

0000000000000db0 <_out_null>:
     db0:	8082                	ret
     db2:	0001                	nop
     db4:	00000013          	nop
     db8:	00000013          	nop
     dbc:	00000013          	nop

0000000000000dc0 <_out_fct>:
     dc0:	c501                	beqz	a0,dc8 <_out_fct+0x8>
     dc2:	619c                	ld	a5,0(a1)
     dc4:	658c                	ld	a1,8(a1)
     dc6:	8782                	jr	a5
     dc8:	8082                	ret
     dca:	00000013          	nop
     dce:	0001                	nop

0000000000000dd0 <_out_char>:
     dd0:	e111                	bnez	a0,dd4 <_out_char+0x4>
     dd2:	8082                	ret
     dd4:	55fd                	li	a1,-1
     dd6:	bf69                	j	d70 <fputc>
     dd8:	00000013          	nop
     ddc:	00000013          	nop

0000000000000de0 <_ftoa>:
     de0:	7119                	addi	sp,sp,-128
     de2:	fc5e                	sd	s7,56(sp)
     de4:	e0da                	sd	s6,64(sp)
     de6:	8b3e                	mv	s6,a5
     de8:	a2a527d3          	feq.d	a5,fa0,fa0
     dec:	e4d6                	sd	s5,72(sp)
     dee:	e8d2                	sd	s4,80(sp)
     df0:	ecce                	sd	s3,88(sp)
     df2:	f0ca                	sd	s2,96(sp)
     df4:	f4a6                	sd	s1,104(sp)
     df6:	f8a2                	sd	s0,112(sp)
     df8:	f466                	sd	s9,40(sp)
     dfa:	fc86                	sd	ra,120(sp)
     dfc:	892a                	mv	s2,a0
     dfe:	89ae                	mv	s3,a1
     e00:	8ab2                	mv	s5,a2
     e02:	8a36                	mv	s4,a3
     e04:	8bc2                	mv	s7,a6
     e06:	1c078163          	beqz	a5,fc8 <_ftoa+0x1e8>
     e0a:	6795                	lui	a5,0x5
     e0c:	7e07b787          	fld	fa5,2016(a5) # 57e0 <pow10.0+0x50>
     e10:	a2f517d3          	flt.d	a5,fa0,fa5
     e14:	36079263          	bnez	a5,1178 <_ftoa+0x398>
     e18:	6795                	lui	a5,0x5
     e1a:	7e87b787          	fld	fa5,2024(a5) # 57e8 <pow10.0+0x58>
     e1e:	f06a                	sd	s10,32(sp)
     e20:	a2a797d3          	flt.d	a5,fa5,fa0
     e24:	e7e5                	bnez	a5,f0c <_ftoa+0x12c>
     e26:	6795                	lui	a5,0x5
     e28:	7f07b787          	fld	fa5,2032(a5) # 57f0 <pow10.0+0x60>
     e2c:	f862                	sd	s8,48(sp)
     e2e:	a2a797d3          	flt.d	a5,fa5,fa0
     e32:	44079363          	bnez	a5,1278 <_ftoa+0x498>
     e36:	6795                	lui	a5,0x5
     e38:	7f87b787          	fld	fa5,2040(a5) # 57f8 <pow10.0+0x68>
     e3c:	a2f517d3          	flt.d	a5,fa0,fa5
     e40:	6c079a63          	bnez	a5,1514 <_ftoa+0x734>
     e44:	f20007d3          	fmv.d.x	fa5,zero
     e48:	a2f517d3          	flt.d	a5,fa0,fa5
     e4c:	4501                	li	a0,0
     e4e:	32079163          	bnez	a5,1170 <_ftoa+0x390>
     e52:	400bf693          	andi	a3,s7,1024
     e56:	4799                	li	a5,6
     e58:	40d7970b          	th.mveqz	a4,a5,a3
     e5c:	fe07059b          	addiw	a1,a4,-32
     e60:	4401                	li	s0,0
     e62:	8c0a                	mv	s8,sp
     e64:	46a5                	li	a3,9
     e66:	03000613          	li	a2,48
     e6a:	0001                	nop
     e6c:	00000013          	nop
     e70:	00e6fc63          	bgeu	a3,a4,e88 <_ftoa+0xa8>
     e74:	0405                	addi	s0,s0,1
     e76:	008c07b3          	add	a5,s8,s0
     e7a:	377d                	addiw	a4,a4,-1
     e7c:	fec78fa3          	sb	a2,-1(a5)
     e80:	feb718e3          	bne	a4,a1,e70 <_ftoa+0x90>
     e84:	02000413          	li	s0,32
     e88:	c2051653          	fcvt.w.d	a2,fa0,rtz
     e8c:	6795                	lui	a5,0x5
     e8e:	d20607d3          	fcvt.d.w	fa5,a2
     e92:	79078793          	addi	a5,a5,1936 # 5790 <pow10.0>
     e96:	76e7e68b          	th.flurd	fa3,a5,a4,3
     e9a:	0af577d3          	fsub.d	fa5,fa0,fa5
     e9e:	6599                	lui	a1,0x6
     ea0:	8285b707          	fld	fa4,-2008(a1) # 5828 <pow10.0+0x98>
     ea4:	12d7f7d3          	fmul.d	fa5,fa5,fa3
     ea8:	0006079b          	sext.w	a5,a2
     eac:	c23796d3          	fcvt.lu.d	a3,fa5,rtz
     eb0:	d236f653          	fcvt.d.lu	fa2,a3
     eb4:	0ac7f7d3          	fsub.d	fa5,fa5,fa2
     eb8:	a2f71853          	flt.d	a6,fa4,fa5
     ebc:	1a080863          	beqz	a6,106c <_ftoa+0x28c>
     ec0:	0685                	addi	a3,a3,1
     ec2:	d236f7d3          	fcvt.d.lu	fa5,a3
     ec6:	a2f68853          	fle.d	a6,fa3,fa5
     eca:	00080563          	beqz	a6,ed4 <_ftoa+0xf4>
     ece:	0016079b          	addiw	a5,a2,1
     ed2:	4681                	li	a3,0
     ed4:	1a070663          	beqz	a4,1080 <_ftoa+0x2a0>
     ed8:	fe07089b          	addiw	a7,a4,-32
     edc:	008888bb          	addw	a7,a7,s0
     ee0:	45a9                	li	a1,10
     ee2:	4325                	li	t1,9
     ee4:	00000013          	nop
     ee8:	39170563          	beq	a4,a7,1272 <_ftoa+0x492>
     eec:	02b6f633          	remu	a2,a3,a1
     ef0:	0405                	addi	s0,s0,1
     ef2:	008c0833          	add	a6,s8,s0
     ef6:	377d                	addiw	a4,a4,-1
     ef8:	0306061b          	addiw	a2,a2,48
     efc:	fec80fa3          	sb	a2,-1(a6)
     f00:	02b6d633          	divu	a2,a3,a1
     f04:	34d37463          	bgeu	t1,a3,124c <_ftoa+0x46c>
     f08:	86b2                	mv	a3,a2
     f0a:	bff9                	j	ee8 <_ftoa+0x108>
     f0c:	00487793          	andi	a5,a6,4
     f10:	24079a63          	bnez	a5,1164 <_ftoa+0x384>
     f14:	6c95                	lui	s9,0x5
     f16:	5c8c8c93          	addi	s9,s9,1480 # 55c8 <__errno+0x22c>
     f1a:	4d0d                	li	s10,3
     f1c:	003bf793          	andi	a5,s7,3
     f20:	84d6                	mv	s1,s5
     f22:	eb95                	bnez	a5,f56 <_ftoa+0x176>
     f24:	f862                	sd	s8,48(sp)
     f26:	7c0b3c0b          	th.extu	s8,s6,31,0
     f2a:	678d7263          	bgeu	s10,s8,158e <_ftoa+0x7ae>
     f2e:	8456                	mv	s0,s5
     f30:	415d04b3          	sub	s1,s10,s5
     f34:	00000013          	nop
     f38:	8622                	mv	a2,s0
     f3a:	86d2                	mv	a3,s4
     f3c:	85ce                	mv	a1,s3
     f3e:	02000513          	li	a0,32
     f42:	0405                	addi	s0,s0,1
     f44:	9902                	jalr	s2
     f46:	008487b3          	add	a5,s1,s0
     f4a:	ff87e7e3          	bltu	a5,s8,f38 <_ftoa+0x158>
     f4e:	9c56                	add	s8,s8,s5
     f50:	41ac04b3          	sub	s1,s8,s10
     f54:	7c42                	ld	s8,48(sp)
     f56:	01ac8433          	add	s0,s9,s10
     f5a:	fff44503          	lbu	a0,-1(s0)
     f5e:	86d2                	mv	a3,s4
     f60:	8626                	mv	a2,s1
     f62:	85ce                	mv	a1,s3
     f64:	9902                	jalr	s2
     f66:	ffe44503          	lbu	a0,-2(s0)
     f6a:	86d2                	mv	a3,s4
     f6c:	00148613          	addi	a2,s1,1
     f70:	85ce                	mv	a1,s3
     f72:	9902                	jalr	s2
     f74:	ffdd0413          	addi	s0,s10,-3
     f78:	808cc50b          	th.lrbu	a0,s9,s0,0
     f7c:	86d2                	mv	a3,s4
     f7e:	00248613          	addi	a2,s1,2
     f82:	85ce                	mv	a1,s3
     f84:	9902                	jalr	s2
     f86:	c801                	beqz	s0,f96 <_ftoa+0x1b6>
     f88:	000cc503          	lbu	a0,0(s9)
     f8c:	86d2                	mv	a3,s4
     f8e:	00348613          	addi	a2,s1,3
     f92:	85ce                	mv	a1,s3
     f94:	9902                	jalr	s2
     f96:	002bfb93          	andi	s7,s7,2
     f9a:	94ea                	add	s1,s1,s10
     f9c:	020b8463          	beqz	s7,fc4 <_ftoa+0x1e4>
     fa0:	41548ab3          	sub	s5,s1,s5
     fa4:	7c0b3b0b          	th.extu	s6,s6,31,0
     fa8:	016afe63          	bgeu	s5,s6,fc4 <_ftoa+0x1e4>
     fac:	00000013          	nop
     fb0:	8626                	mv	a2,s1
     fb2:	86d2                	mv	a3,s4
     fb4:	85ce                	mv	a1,s3
     fb6:	02000513          	li	a0,32
     fba:	0a85                	addi	s5,s5,1
     fbc:	0485                	addi	s1,s1,1
     fbe:	9902                	jalr	s2
     fc0:	ff6ae8e3          	bltu	s5,s6,fb0 <_ftoa+0x1d0>
     fc4:	7d02                	ld	s10,32(sp)
     fc6:	a069                	j	1050 <_ftoa+0x270>
     fc8:	00387793          	andi	a5,a6,3
     fcc:	f862                	sd	s8,48(sp)
     fce:	84b2                	mv	s1,a2
     fd0:	e78d                	bnez	a5,ffa <_ftoa+0x21a>
     fd2:	478d                	li	a5,3
     fd4:	7c0b370b          	th.extu	a4,s6,31,0
     fd8:	0367f163          	bgeu	a5,s6,ffa <_ftoa+0x21a>
     fdc:	ffd60493          	addi	s1,a2,-3
     fe0:	94ba                	add	s1,s1,a4
     fe2:	8432                	mv	s0,a2
     fe4:	00000013          	nop
     fe8:	8622                	mv	a2,s0
     fea:	86d2                	mv	a3,s4
     fec:	0405                	addi	s0,s0,1
     fee:	85ce                	mv	a1,s3
     ff0:	02000513          	li	a0,32
     ff4:	9902                	jalr	s2
     ff6:	fe9419e3          	bne	s0,s1,fe8 <_ftoa+0x208>
     ffa:	6c15                	lui	s8,0x5
     ffc:	5d2c0c13          	addi	s8,s8,1490 # 55d2 <__errno+0x236>
    1000:	4401                	li	s0,0
    1002:	5cf5                	li	s9,-3
    1004:	00000013          	nop
    1008:	808c450b          	th.lrbu	a0,s8,s0,0
    100c:	40848633          	sub	a2,s1,s0
    1010:	86d2                	mv	a3,s4
    1012:	85ce                	mv	a1,s3
    1014:	147d                	addi	s0,s0,-1
    1016:	9902                	jalr	s2
    1018:	ff9418e3          	bne	s0,s9,1008 <_ftoa+0x228>
    101c:	002bfb93          	andi	s7,s7,2
    1020:	048d                	addi	s1,s1,3
    1022:	020b8663          	beqz	s7,104e <_ftoa+0x26e>
    1026:	7c0b3b0b          	th.extu	s6,s6,31,0
    102a:	415487b3          	sub	a5,s1,s5
    102e:	0367f063          	bgeu	a5,s6,104e <_ftoa+0x26e>
    1032:	0001                	nop
    1034:	00000013          	nop
    1038:	8626                	mv	a2,s1
    103a:	86d2                	mv	a3,s4
    103c:	85ce                	mv	a1,s3
    103e:	02000513          	li	a0,32
    1042:	0485                	addi	s1,s1,1
    1044:	9902                	jalr	s2
    1046:	415487b3          	sub	a5,s1,s5
    104a:	ff67e7e3          	bltu	a5,s6,1038 <_ftoa+0x258>
    104e:	7c42                	ld	s8,48(sp)
    1050:	70e6                	ld	ra,120(sp)
    1052:	8526                	mv	a0,s1
    1054:	74a6                	ld	s1,104(sp)
    1056:	7446                	ld	s0,112(sp)
    1058:	7be2                	ld	s7,56(sp)
    105a:	6b06                	ld	s6,64(sp)
    105c:	6aa6                	ld	s5,72(sp)
    105e:	6a46                	ld	s4,80(sp)
    1060:	69e6                	ld	s3,88(sp)
    1062:	7906                	ld	s2,96(sp)
    1064:	7ca2                	ld	s9,40(sp)
    1066:	6109                	addi	sp,sp,128
    1068:	8082                	ret
    106a:	0001                	nop
    106c:	a2e79653          	flt.d	a2,fa5,fa4
    1070:	e60612e3          	bnez	a2,ed4 <_ftoa+0xf4>
    1074:	48069063          	bnez	a3,14f4 <_ftoa+0x714>
    1078:	0685                	addi	a3,a3,1
    107a:	e4071fe3          	bnez	a4,ed8 <_ftoa+0xf8>
    107e:	0001                	nop
    1080:	d2078753          	fcvt.d.w	fa4,a5
    1084:	8285b787          	fld	fa5,-2008(a1)
    1088:	0ae57553          	fsub.d	fa0,fa0,fa4
    108c:	0017871b          	addiw	a4,a5,1
    1090:	9b79                	andi	a4,a4,-2
    1092:	a2f516d3          	flt.d	a3,fa0,fa5
    1096:	40d7178b          	th.mveqz	a5,a4,a3
    109a:	02000593          	li	a1,32
    109e:	4629                	li	a2,10
    10a0:	02b40363          	beq	s0,a1,10c6 <_ftoa+0x2e6>
    10a4:	00000013          	nop
    10a8:	02c7e73b          	remw	a4,a5,a2
    10ac:	00140693          	addi	a3,s0,1
    10b0:	02c7c7bb          	divw	a5,a5,a2
    10b4:	0307071b          	addiw	a4,a4,48
    10b8:	008c570b          	th.srb	a4,s8,s0,0
    10bc:	14078263          	beqz	a5,1200 <_ftoa+0x420>
    10c0:	8436                	mv	s0,a3
    10c2:	feb413e3          	bne	s0,a1,10a8 <_ftoa+0x2c8>
    10c6:	003bf793          	andi	a5,s7,3
    10ca:	4705                	li	a4,1
    10cc:	14e79963          	bne	a5,a4,121e <_ftoa+0x43e>
    10d0:	8cd6                	mv	s9,s5
    10d2:	040b0363          	beqz	s6,1118 <_ftoa+0x338>
    10d6:	44050b63          	beqz	a0,152c <_ftoa+0x74c>
    10da:	3b7d                	addiw	s6,s6,-1
    10dc:	7c0b368b          	th.extu	a3,s6,31,0
    10e0:	03647c63          	bgeu	s0,s6,1118 <_ftoa+0x338>
    10e4:	02000713          	li	a4,32
    10e8:	03000613          	li	a2,48
    10ec:	00000013          	nop
    10f0:	40e40863          	beq	s0,a4,1500 <_ftoa+0x720>
    10f4:	0405                	addi	s0,s0,1
    10f6:	008c07b3          	add	a5,s8,s0
    10fa:	fec78fa3          	sb	a2,-1(a5)
    10fe:	fed419e3          	bne	s0,a3,10f0 <_ftoa+0x310>
    1102:	3ee40f63          	beq	s0,a4,1500 <_ftoa+0x720>
    1106:	46050963          	beqz	a0,1578 <_ftoa+0x798>
    110a:	968a                	add	a3,a3,sp
    110c:	02d00793          	li	a5,45
    1110:	0405                	addi	s0,s0,1
    1112:	00f68023          	sb	a5,0(a3)
    1116:	8cd6                	mv	s9,s5
    1118:	9ca2                	add	s9,s9,s0
    111a:	019c0d33          	add	s10,s8,s9
    111e:	9462                	add	s0,s0,s8
    1120:	408d0633          	sub	a2,s10,s0
    1124:	89f4450b          	th.lbuib	a0,(s0),-1,0
    1128:	86d2                	mv	a3,s4
    112a:	85ce                	mv	a1,s3
    112c:	84e6                	mv	s1,s9
    112e:	9902                	jalr	s2
    1130:	fe8c18e3          	bne	s8,s0,1120 <_ftoa+0x340>
    1134:	002bfb93          	andi	s7,s7,2
    1138:	020b8263          	beqz	s7,115c <_ftoa+0x37c>
    113c:	415c8ab3          	sub	s5,s9,s5
    1140:	7c0b3b0b          	th.extu	s6,s6,31,0
    1144:	016afc63          	bgeu	s5,s6,115c <_ftoa+0x37c>
    1148:	8626                	mv	a2,s1
    114a:	86d2                	mv	a3,s4
    114c:	85ce                	mv	a1,s3
    114e:	02000513          	li	a0,32
    1152:	0a85                	addi	s5,s5,1
    1154:	0485                	addi	s1,s1,1
    1156:	9902                	jalr	s2
    1158:	ff6ae8e3          	bltu	s5,s6,1148 <_ftoa+0x368>
    115c:	7c42                	ld	s8,48(sp)
    115e:	7d02                	ld	s10,32(sp)
    1160:	bdc5                	j	1050 <_ftoa+0x270>
    1162:	0001                	nop
    1164:	6c95                	lui	s9,0x5
    1166:	5c0c8c93          	addi	s9,s9,1472 # 55c0 <__errno+0x224>
    116a:	4d11                	li	s10,4
    116c:	bb45                	j	f1c <_ftoa+0x13c>
    116e:	0001                	nop
    1170:	0aa7f553          	fsub.d	fa0,fa5,fa0
    1174:	4505                	li	a0,1
    1176:	b9f1                	j	e52 <_ftoa+0x72>
    1178:	00387793          	andi	a5,a6,3
    117c:	f862                	sd	s8,48(sp)
    117e:	84b2                	mv	s1,a2
    1180:	e78d                	bnez	a5,11aa <_ftoa+0x3ca>
    1182:	4791                	li	a5,4
    1184:	7c0b370b          	th.extu	a4,s6,31,0
    1188:	0367f163          	bgeu	a5,s6,11aa <_ftoa+0x3ca>
    118c:	ffc60493          	addi	s1,a2,-4
    1190:	94ba                	add	s1,s1,a4
    1192:	8432                	mv	s0,a2
    1194:	00000013          	nop
    1198:	8622                	mv	a2,s0
    119a:	86d2                	mv	a3,s4
    119c:	0405                	addi	s0,s0,1
    119e:	85ce                	mv	a1,s3
    11a0:	02000513          	li	a0,32
    11a4:	9902                	jalr	s2
    11a6:	fe9419e3          	bne	s0,s1,1198 <_ftoa+0x3b8>
    11aa:	6c15                	lui	s8,0x5
    11ac:	5dbc0c13          	addi	s8,s8,1499 # 55db <__errno+0x23f>
    11b0:	4401                	li	s0,0
    11b2:	5cf1                	li	s9,-4
    11b4:	00000013          	nop
    11b8:	808c450b          	th.lrbu	a0,s8,s0,0
    11bc:	40848633          	sub	a2,s1,s0
    11c0:	86d2                	mv	a3,s4
    11c2:	85ce                	mv	a1,s3
    11c4:	147d                	addi	s0,s0,-1
    11c6:	9902                	jalr	s2
    11c8:	ff9418e3          	bne	s0,s9,11b8 <_ftoa+0x3d8>
    11cc:	002bfb93          	andi	s7,s7,2
    11d0:	0491                	addi	s1,s1,4
    11d2:	e60b8ee3          	beqz	s7,104e <_ftoa+0x26e>
    11d6:	7c0b3b0b          	th.extu	s6,s6,31,0
    11da:	415487b3          	sub	a5,s1,s5
    11de:	e767f8e3          	bgeu	a5,s6,104e <_ftoa+0x26e>
    11e2:	0001                	nop
    11e4:	00000013          	nop
    11e8:	8626                	mv	a2,s1
    11ea:	86d2                	mv	a3,s4
    11ec:	85ce                	mv	a1,s3
    11ee:	02000513          	li	a0,32
    11f2:	0485                	addi	s1,s1,1
    11f4:	9902                	jalr	s2
    11f6:	415487b3          	sub	a5,s1,s5
    11fa:	ff67e7e3          	bltu	a5,s6,11e8 <_ftoa+0x408>
    11fe:	bd81                	j	104e <_ftoa+0x26e>
    1200:	003bf793          	andi	a5,s7,3
    1204:	4705                	li	a4,1
    1206:	3ae78d63          	beq	a5,a4,15c0 <_ftoa+0x7e0>
    120a:	3ab68963          	beq	a3,a1,15bc <_ftoa+0x7dc>
    120e:	2a050563          	beqz	a0,14b8 <_ftoa+0x6d8>
    1212:	968a                	add	a3,a3,sp
    1214:	02d00713          	li	a4,45
    1218:	0409                	addi	s0,s0,2
    121a:	00e68023          	sb	a4,0(a3)
    121e:	ee079ce3          	bnez	a5,1116 <_ftoa+0x336>
    1222:	7c0b3c8b          	th.extu	s9,s6,31,0
    1226:	ef9478e3          	bgeu	s0,s9,1116 <_ftoa+0x336>
    122a:	408c8cb3          	sub	s9,s9,s0
    122e:	9cd6                	add	s9,s9,s5
    1230:	84d6                	mv	s1,s5
    1232:	0001                	nop
    1234:	00000013          	nop
    1238:	8626                	mv	a2,s1
    123a:	86d2                	mv	a3,s4
    123c:	0485                	addi	s1,s1,1
    123e:	85ce                	mv	a1,s3
    1240:	02000513          	li	a0,32
    1244:	9902                	jalr	s2
    1246:	fe9c99e3          	bne	s9,s1,1238 <_ftoa+0x458>
    124a:	b5f9                	j	1118 <_ftoa+0x338>
    124c:	02000613          	li	a2,32
    1250:	02c40163          	beq	s0,a2,1272 <_ftoa+0x492>
    1254:	7c07370b          	th.extu	a4,a4,31,0
    1258:	9722                	add	a4,a4,s0
    125a:	03000593          	li	a1,48
    125e:	0001                	nop
    1260:	24870463          	beq	a4,s0,14a8 <_ftoa+0x6c8>
    1264:	0405                	addi	s0,s0,1
    1266:	008c06b3          	add	a3,s8,s0
    126a:	feb68fa3          	sb	a1,-1(a3)
    126e:	fec419e3          	bne	s0,a2,1260 <_ftoa+0x480>
    1272:	02000413          	li	s0,32
    1276:	b515                	j	109a <_ftoa+0x2ba>
    1278:	e20506d3          	fmv.x.d	a3,fa0
    127c:	6599                	lui	a1,0x6
    127e:	6619                	lui	a2,0x6
    1280:	fb46b78b          	th.extu	a5,a3,62,52
    1284:	8005b607          	fld	fa2,-2048(a1) # 5800 <pow10.0+0x70>
    1288:	80863687          	fld	fa3,-2040(a2) # 5808 <pow10.0+0x78>
    128c:	c017879b          	addiw	a5,a5,-1023
    1290:	d2078753          	fcvt.d.w	fa4,a5
    1294:	3ff00613          	li	a2,1023
    1298:	6799                	lui	a5,0x6
    129a:	8107b787          	fld	fa5,-2032(a5) # 5810 <pow10.0+0x80>
    129e:	1652                	slli	a2,a2,0x34
    12a0:	cc06b78b          	th.extu	a5,a3,51,0
    12a4:	6ac77743          	fmadd.d	fa4,fa4,fa2,fa3
    12a8:	8fd1                	or	a5,a5,a2
    12aa:	f20786d3          	fmv.d.x	fa3,a5
    12ae:	6619                	lui	a2,0x6
    12b0:	0af6f7d3          	fsub.d	fa5,fa3,fa5
    12b4:	81863687          	fld	fa3,-2024(a2) # 5818 <pow10.0+0x88>
    12b8:	6619                	lui	a2,0x6
    12ba:	6799                	lui	a5,0x6
    12bc:	72d7f7c3          	fmadd.d	fa5,fa5,fa3,fa4
    12c0:	82063707          	fld	fa4,-2016(a2) # 5820 <pow10.0+0x90>
    12c4:	8287b687          	fld	fa3,-2008(a5) # 5828 <pow10.0+0x98>
    12c8:	6799                	lui	a5,0x6
    12ca:	8307b007          	fld	ft0,-2000(a5) # 5830 <pow10.0+0xa0>
    12ce:	c2079653          	fcvt.w.d	a2,fa5,rtz
    12d2:	6799                	lui	a5,0x6
    12d4:	d20607d3          	fcvt.d.w	fa5,a2
    12d8:	8387b607          	fld	fa2,-1992(a5) # 5838 <pow10.0+0xa8>
    12dc:	6ae7f6c3          	fmadd.d	fa3,fa5,fa4,fa3
    12e0:	6799                	lui	a5,0x6
    12e2:	8407b707          	fld	fa4,-1984(a5) # 5840 <pow10.0+0xb0>
    12e6:	6799                	lui	a5,0x6
    12e8:	8487b587          	fld	fa1,-1976(a5) # 5848 <pow10.0+0xb8>
    12ec:	c20697d3          	fcvt.w.d	a5,fa3,rtz
    12f0:	6599                	lui	a1,0x6
    12f2:	d20786d3          	fcvt.d.w	fa3,a5
    12f6:	8505b087          	fld	ft1,-1968(a1) # 5850 <pow10.0+0xc0>
    12fa:	1206f6d3          	fmul.d	fa3,fa3,ft0
    12fe:	6599                	lui	a1,0x6
    1300:	3ff7879b          	addiw	a5,a5,1023
    1304:	17d2                	slli	a5,a5,0x34
    1306:	6ac7f7c7          	fmsub.d	fa5,fa5,fa2,fa3
    130a:	8585b607          	fld	fa2,-1960(a1) # 5858 <pow10.0+0xc8>
    130e:	6599                	lui	a1,0x6
    1310:	8605b007          	fld	ft0,-1952(a1) # 5860 <pow10.0+0xd0>
    1314:	4519                	li	a0,6
    1316:	12f7f6d3          	fmul.d	fa3,fa5,fa5
    131a:	0af67653          	fsub.d	fa2,fa2,fa5
    131e:	02f7f7d3          	fadd.d	fa5,fa5,fa5
    1322:	400bf593          	andi	a1,s7,1024
    1326:	1ae6f753          	fdiv.d	fa4,fa3,fa4
    132a:	40b5170b          	th.mveqz	a4,a0,a1
    132e:	00060c9b          	sext.w	s9,a2
    1332:	02b77753          	fadd.d	fa4,fa4,fa1
    1336:	1ae6f753          	fdiv.d	fa4,fa3,fa4
    133a:	02177753          	fadd.d	fa4,fa4,ft1
    133e:	1ae6f6d3          	fdiv.d	fa3,fa3,fa4
    1342:	f2078753          	fmv.d.x	fa4,a5
    1346:	02c6f6d3          	fadd.d	fa3,fa3,fa2
    134a:	1ad7f7d3          	fdiv.d	fa5,fa5,fa3
    134e:	0207f7d3          	fadd.d	fa5,fa5,ft0
    1352:	12e7f7d3          	fmul.d	fa5,fa5,fa4
    1356:	f2068753          	fmv.d.x	fa4,a3
    135a:	a2f717d3          	flt.d	a5,fa4,fa5
    135e:	c789                	beqz	a5,1368 <_ftoa+0x588>
    1360:	1ab7f7d3          	fdiv.d	fa5,fa5,fa1
    1364:	fff60c9b          	addiw	s9,a2,-1
    1368:	063c879b          	addiw	a5,s9,99
    136c:	0c600613          	li	a2,198
    1370:	14f67e63          	bgeu	a2,a5,14cc <_ftoa+0x6ec>
    1374:	4d0d                	li	s10,3
    1376:	4615                	li	a2,5
    1378:	6785                	lui	a5,0x1
    137a:	80078793          	addi	a5,a5,-2048 # 800 <main+0x40>
    137e:	00fbf7b3          	and	a5,s7,a5
    1382:	002bf413          	andi	s0,s7,2
    1386:	18078163          	beqz	a5,1508 <_ftoa+0x728>
    138a:	18070a63          	beqz	a4,151e <_ftoa+0x73e>
    138e:	18058863          	beqz	a1,151e <_ftoa+0x73e>
    1392:	377d                	addiw	a4,a4,-1
    1394:	01667563          	bgeu	a2,s6,139e <_ftoa+0x5be>
    1398:	1c040d63          	beqz	s0,1572 <_ftoa+0x792>
    139c:	4409                	li	s0,2
    139e:	4781                	li	a5,0
    13a0:	000c8863          	beqz	s9,13b0 <_ftoa+0x5d0>
    13a4:	f2068753          	fmv.d.x	fa4,a3
    13a8:	1af777d3          	fdiv.d	fa5,fa4,fa5
    13ac:	e20786d3          	fmv.x.d	a3,fa5
    13b0:	f20007d3          	fmv.d.x	fa5,zero
    13b4:	a2f51653          	flt.d	a2,fa0,fa5
    13b8:	c619                	beqz	a2,13c6 <_ftoa+0x5e6>
    13ba:	f20687d3          	fmv.d.x	fa5,a3
    13be:	22f797d3          	fneg.d	fa5,fa5
    13c2:	e20786d3          	fmv.x.d	a3,fa5
    13c6:	787d                	lui	a6,0xfffff
    13c8:	7ff80813          	addi	a6,a6,2047 # fffffffffffff7ff <__kernel_stack+0xfffffffffff117ff>
    13cc:	010bf833          	and	a6,s7,a6
    13d0:	f2068553          	fmv.d.x	fa0,a3
    13d4:	8656                	mv	a2,s5
    13d6:	86d2                	mv	a3,s4
    13d8:	85ce                	mv	a1,s3
    13da:	854a                	mv	a0,s2
    13dc:	a05ff0ef          	jal	de0 <_ftoa>
    13e0:	862a                	mv	a2,a0
    13e2:	06500793          	li	a5,101
    13e6:	020bfb93          	andi	s7,s7,32
    13ea:	04500513          	li	a0,69
    13ee:	4177950b          	th.mveqz	a0,a5,s7
    13f2:	86d2                	mv	a3,s4
    13f4:	85ce                	mv	a1,s3
    13f6:	00160493          	addi	s1,a2,1
    13fa:	9902                	jalr	s2
    13fc:	41fcd79b          	sraiw	a5,s9,0x1f
    1400:	00fcc733          	xor	a4,s9,a5
    1404:	9f1d                	subw	a4,a4,a5
    1406:	8c0a                	mv	s8,sp
    1408:	4681                	li	a3,0
    140a:	45a9                	li	a1,10
    140c:	4825                	li	a6,9
    140e:	02000893          	li	a7,32
    1412:	a019                	j	1418 <_ftoa+0x638>
    1414:	15168a63          	beq	a3,a7,1568 <_ftoa+0x788>
    1418:	02b77633          	remu	a2,a4,a1
    141c:	0685                	addi	a3,a3,1
    141e:	00dc07b3          	add	a5,s8,a3
    1422:	853a                	mv	a0,a4
    1424:	0306061b          	addiw	a2,a2,48
    1428:	fec78fa3          	sb	a2,-1(a5)
    142c:	02b75733          	divu	a4,a4,a1
    1430:	fea862e3          	bltu	a6,a0,1414 <_ftoa+0x634>
    1434:	13a6f663          	bgeu	a3,s10,1560 <_ftoa+0x780>
    1438:	01ac06b3          	add	a3,s8,s10
    143c:	03000713          	li	a4,48
    1440:	1817d70b          	th.sbia	a4,(a5),1,0
    1444:	fef69ee3          	bne	a3,a5,1440 <_ftoa+0x660>
    1448:	001d0b93          	addi	s7,s10,1
    144c:	140cda63          	bgez	s9,15a0 <_ftoa+0x7c0>
    1450:	02d00513          	li	a0,45
    1454:	01ac550b          	th.srb	a0,s8,s10,0
    1458:	01748cb3          	add	s9,s1,s7
    145c:	a031                	j	1468 <_ftoa+0x688>
    145e:	0001                	nop
    1460:	017c07b3          	add	a5,s8,s7
    1464:	fff7c503          	lbu	a0,-1(a5)
    1468:	417c8633          	sub	a2,s9,s7
    146c:	86d2                	mv	a3,s4
    146e:	1bfd                	addi	s7,s7,-1
    1470:	85ce                	mv	a1,s3
    1472:	84e6                	mv	s1,s9
    1474:	9902                	jalr	s2
    1476:	fe0b95e3          	bnez	s7,1460 <_ftoa+0x680>
    147a:	ce0401e3          	beqz	s0,115c <_ftoa+0x37c>
    147e:	415c8ab3          	sub	s5,s9,s5
    1482:	7c0b3b0b          	th.extu	s6,s6,31,0
    1486:	cd6afbe3          	bgeu	s5,s6,115c <_ftoa+0x37c>
    148a:	0001                	nop
    148c:	00000013          	nop
    1490:	8626                	mv	a2,s1
    1492:	86d2                	mv	a3,s4
    1494:	85ce                	mv	a1,s3
    1496:	02000513          	li	a0,32
    149a:	0a85                	addi	s5,s5,1
    149c:	0485                	addi	s1,s1,1
    149e:	9902                	jalr	s2
    14a0:	ff6ae8e3          	bltu	s5,s6,1490 <_ftoa+0x6b0>
    14a4:	7c42                	ld	s8,48(sp)
    14a6:	b965                	j	115e <_ftoa+0x37e>
    14a8:	970a                	add	a4,a4,sp
    14aa:	02e00693          	li	a3,46
    14ae:	0405                	addi	s0,s0,1
    14b0:	00d70023          	sb	a3,0(a4)
    14b4:	b6dd                	j	109a <_ftoa+0x2ba>
    14b6:	0001                	nop
    14b8:	004bf713          	andi	a4,s7,4
    14bc:	cf11                	beqz	a4,14d8 <_ftoa+0x6f8>
    14be:	968a                	add	a3,a3,sp
    14c0:	02b00713          	li	a4,43
    14c4:	0409                	addi	s0,s0,2
    14c6:	00e68023          	sb	a4,0(a3)
    14ca:	bb91                	j	121e <_ftoa+0x43e>
    14cc:	4d09                	li	s10,2
    14ce:	4611                	li	a2,4
    14d0:	b565                	j	1378 <_ftoa+0x598>
    14d2:	4785                	li	a5,1
    14d4:	00000013          	nop
    14d8:	008bf713          	andi	a4,s7,8
    14dc:	8436                	mv	s0,a3
    14de:	d40700e3          	beqz	a4,121e <_ftoa+0x43e>
    14e2:	00268733          	add	a4,a3,sp
    14e6:	02000613          	li	a2,32
    14ea:	00168413          	addi	s0,a3,1
    14ee:	00c70023          	sb	a2,0(a4)
    14f2:	b335                	j	121e <_ftoa+0x43e>
    14f4:	0016f613          	andi	a2,a3,1
    14f8:	9c060ee3          	beqz	a2,ed4 <_ftoa+0xf4>
    14fc:	0685                	addi	a3,a3,1
    14fe:	beb5                	j	107a <_ftoa+0x29a>
    1500:	02000413          	li	s0,32
    1504:	8cd6                	mv	s9,s5
    1506:	b909                	j	1118 <_ftoa+0x338>
    1508:	e9667ce3          	bgeu	a2,s6,13a0 <_ftoa+0x5c0>
    150c:	c03d                	beqz	s0,1572 <_ftoa+0x792>
    150e:	4409                	li	s0,2
    1510:	bd41                	j	13a0 <_ftoa+0x5c0>
    1512:	0001                	nop
    1514:	22a517d3          	fneg.d	fa5,fa0
    1518:	e20786d3          	fmv.x.d	a3,fa5
    151c:	b385                	j	127c <_ftoa+0x49c>
    151e:	e96670e3          	bgeu	a2,s6,139e <_ftoa+0x5be>
    1522:	c821                	beqz	s0,1572 <_ftoa+0x792>
    1524:	4781                	li	a5,0
    1526:	4409                	li	s0,2
    1528:	bda5                	j	13a0 <_ftoa+0x5c0>
    152a:	8436                	mv	s0,a3
    152c:	00cbf793          	andi	a5,s7,12
    1530:	c3ad                	beqz	a5,1592 <_ftoa+0x7b2>
    1532:	3b7d                	addiw	s6,s6,-1
    1534:	7c0b368b          	th.extu	a3,s6,31,0
    1538:	bad466e3          	bltu	s0,a3,10e4 <_ftoa+0x304>
    153c:	02000793          	li	a5,32
    1540:	bcf40be3          	beq	s0,a5,1116 <_ftoa+0x336>
    1544:	004bf793          	andi	a5,s7,4
    1548:	c3bd                	beqz	a5,15ae <_ftoa+0x7ce>
    154a:	02040793          	addi	a5,s0,32
    154e:	02b00713          	li	a4,43
    1552:	978a                	add	a5,a5,sp
    1554:	fee78023          	sb	a4,-32(a5)
    1558:	0405                	addi	s0,s0,1
    155a:	8cd6                	mv	s9,s5
    155c:	be75                	j	1118 <_ftoa+0x338>
    155e:	0001                	nop
    1560:	02000793          	li	a5,32
    1564:	04f69363          	bne	a3,a5,15aa <_ftoa+0x7ca>
    1568:	01f14503          	lbu	a0,31(sp)
    156c:	02000b93          	li	s7,32
    1570:	b5e5                	j	1458 <_ftoa+0x678>
    1572:	40cb07bb          	subw	a5,s6,a2
    1576:	b52d                	j	13a0 <_ftoa+0x5c0>
    1578:	004bf793          	andi	a5,s7,4
    157c:	dbb9                	beqz	a5,14d2 <_ftoa+0x6f2>
    157e:	968a                	add	a3,a3,sp
    1580:	02b00793          	li	a5,43
    1584:	0405                	addi	s0,s0,1
    1586:	00f68023          	sb	a5,0(a3)
    158a:	8cd6                	mv	s9,s5
    158c:	b671                	j	1118 <_ftoa+0x338>
    158e:	7c42                	ld	s8,48(sp)
    1590:	b2d9                	j	f56 <_ftoa+0x176>
    1592:	7c0b368b          	th.extu	a3,s6,31,0
    1596:	b4d467e3          	bltu	s0,a3,10e4 <_ftoa+0x304>
    159a:	8cd6                	mv	s9,s5
    159c:	beb5                	j	1118 <_ftoa+0x338>
    159e:	0001                	nop
    15a0:	02b00513          	li	a0,43
    15a4:	01ac550b          	th.srb	a0,s8,s10,0
    15a8:	bd45                	j	1458 <_ftoa+0x678>
    15aa:	8d36                	mv	s10,a3
    15ac:	bd71                	j	1448 <_ftoa+0x668>
    15ae:	008bf793          	andi	a5,s7,8
    15b2:	b60782e3          	beqz	a5,1116 <_ftoa+0x336>
    15b6:	86a2                	mv	a3,s0
    15b8:	4785                	li	a5,1
    15ba:	b725                	j	14e2 <_ftoa+0x702>
    15bc:	842e                	mv	s0,a1
    15be:	b185                	j	121e <_ftoa+0x43e>
    15c0:	000b0b63          	beqz	s6,15d6 <_ftoa+0x7f6>
    15c4:	d13d                	beqz	a0,152a <_ftoa+0x74a>
    15c6:	3b7d                	addiw	s6,s6,-1
    15c8:	7c0b378b          	th.extu	a5,s6,31,0
    15cc:	02f6f763          	bgeu	a3,a5,15fa <_ftoa+0x81a>
    15d0:	8436                	mv	s0,a3
    15d2:	86be                	mv	a3,a5
    15d4:	be01                	j	10e4 <_ftoa+0x304>
    15d6:	02b68c63          	beq	a3,a1,160e <_ftoa+0x82e>
    15da:	e115                	bnez	a0,15fe <_ftoa+0x81e>
    15dc:	004bf713          	andi	a4,s7,4
    15e0:	ee070ce3          	beqz	a4,14d8 <_ftoa+0x6f8>
    15e4:	02068793          	addi	a5,a3,32
    15e8:	002786b3          	add	a3,a5,sp
    15ec:	02b00793          	li	a5,43
    15f0:	0409                	addi	s0,s0,2
    15f2:	fef68023          	sb	a5,-32(a3)
    15f6:	8cd6                	mv	s9,s5
    15f8:	b605                	j	1118 <_ftoa+0x338>
    15fa:	00b68a63          	beq	a3,a1,160e <_ftoa+0x82e>
    15fe:	968a                	add	a3,a3,sp
    1600:	02d00793          	li	a5,45
    1604:	0409                	addi	s0,s0,2
    1606:	00f68023          	sb	a5,0(a3)
    160a:	8cd6                	mv	s9,s5
    160c:	b631                	j	1118 <_ftoa+0x338>
    160e:	842e                	mv	s0,a1
    1610:	8cd6                	mv	s9,s5
    1612:	b619                	j	1118 <_ftoa+0x338>
    1614:	00000013          	nop
    1618:	00000013          	nop
    161c:	00000013          	nop

0000000000001620 <_vsnprintf>:
    1620:	7171                	addi	sp,sp,-176
    1622:	f8da                	sd	s6,112(sp)
    1624:	fcd6                	sd	s5,120(sp)
    1626:	ed26                	sd	s1,152(sp)
    1628:	f122                	sd	s0,160(sp)
    162a:	e152                	sd	s4,128(sp)
    162c:	f506                	sd	ra,168(sp)
    162e:	0006c783          	lbu	a5,0(a3)
    1632:	6a05                	lui	s4,0x1
    1634:	db0a0a13          	addi	s4,s4,-592 # db0 <_out_null>
    1638:	8b2e                	mv	s6,a1
    163a:	8ab2                	mv	s5,a2
    163c:	42b51a0b          	th.mvnez	s4,a0,a1
    1640:	4481                	li	s1,0
    1642:	30078ee3          	beqz	a5,215e <_vsnprintf+0xb3e>
    1646:	e4ee                	sd	s11,72(sp)
    1648:	e8ea                	sd	s10,80(sp)
    164a:	8dba                	mv	s11,a4
    164c:	6715                	lui	a4,0x5
    164e:	ece6                	sd	s9,88(sp)
    1650:	f0e2                	sd	s8,96(sp)
    1652:	63470713          	addi	a4,a4,1588 # 5634 <__errno+0x298>
    1656:	6c15                	lui	s8,0x5
    1658:	f4de                	sd	s7,104(sp)
    165a:	e54e                	sd	s3,136(sp)
    165c:	e94a                	sd	s2,144(sp)
    165e:	853e                	mv	a0,a5
    1660:	8936                	mv	s2,a3
    1662:	5f0c0c13          	addi	s8,s8,1520 # 55f0 <__errno+0x254>
    1666:	02500c93          	li	s9,37
    166a:	4bc1                	li	s7,16
    166c:	e03a                	sd	a4,0(sp)
    166e:	a811                	j	1682 <_vsnprintf+0x62>
    1670:	8626                	mv	a2,s1
    1672:	86d6                	mv	a3,s5
    1674:	85da                	mv	a1,s6
    1676:	0485                	addi	s1,s1,1
    1678:	9a02                	jalr	s4
    167a:	00094503          	lbu	a0,0(s2)
    167e:	14050163          	beqz	a0,17c0 <_vsnprintf+0x1a0>
    1682:	0905                	addi	s2,s2,1
    1684:	ff9516e3          	bne	a0,s9,1670 <_vsnprintf+0x50>
    1688:	4401                	li	s0,0
    168a:	0001                	nop
    168c:	00000013          	nop
    1690:	87ca                	mv	a5,s2
    1692:	9817c50b          	th.lbuia	a0,(a5),1,0
    1696:	fe05071b          	addiw	a4,a0,-32
    169a:	0ff77713          	zext.b	a4,a4
    169e:	00ebe563          	bltu	s7,a4,16a8 <_vsnprintf+0x88>
    16a2:	44ec470b          	th.lrw	a4,s8,a4,2
    16a6:	8702                	jr	a4
    16a8:	fd05071b          	addiw	a4,a0,-48
    16ac:	0ff77713          	zext.b	a4,a4
    16b0:	46a5                	li	a3,9
    16b2:	0ae6f363          	bgeu	a3,a4,1758 <_vsnprintf+0x138>
    16b6:	02a00713          	li	a4,42
    16ba:	4981                	li	s3,0
    16bc:	34e50863          	beq	a0,a4,1a0c <_vsnprintf+0x3ec>
    16c0:	02e00693          	li	a3,46
    16c4:	4701                	li	a4,0
    16c6:	0cd50863          	beq	a0,a3,1796 <_vsnprintf+0x176>
    16ca:	f985069b          	addiw	a3,a0,-104
    16ce:	0ff6f693          	zext.b	a3,a3
    16d2:	4649                	li	a2,18
    16d4:	04d66a63          	bltu	a2,a3,1728 <_vsnprintf+0x108>
    16d8:	6602                	ld	a2,0(sp)
    16da:	44d6468b          	th.lrw	a3,a2,a3,2
    16de:	8682                	jr	a3
    16e0:	00146413          	ori	s0,s0,1
    16e4:	2401                	sext.w	s0,s0
    16e6:	893e                	mv	s2,a5
    16e8:	b765                	j	1690 <_vsnprintf+0x70>
    16ea:	0001                	nop
    16ec:	00246413          	ori	s0,s0,2
    16f0:	2401                	sext.w	s0,s0
    16f2:	893e                	mv	s2,a5
    16f4:	bf71                	j	1690 <_vsnprintf+0x70>
    16f6:	0001                	nop
    16f8:	00446413          	ori	s0,s0,4
    16fc:	2401                	sext.w	s0,s0
    16fe:	893e                	mv	s2,a5
    1700:	bf41                	j	1690 <_vsnprintf+0x70>
    1702:	0001                	nop
    1704:	01046413          	ori	s0,s0,16
    1708:	2401                	sext.w	s0,s0
    170a:	893e                	mv	s2,a5
    170c:	b751                	j	1690 <_vsnprintf+0x70>
    170e:	0001                	nop
    1710:	00846413          	ori	s0,s0,8
    1714:	2401                	sext.w	s0,s0
    1716:	893e                	mv	s2,a5
    1718:	bfa5                	j	1690 <_vsnprintf+0x70>
    171a:	0001                	nop
    171c:	00194503          	lbu	a0,1(s2)
    1720:	10046413          	ori	s0,s0,256
    1724:	2401                	sext.w	s0,s0
    1726:	0785                	addi	a5,a5,1
    1728:	06700693          	li	a3,103
    172c:	893e                	mv	s2,a5
    172e:	0ca6e563          	bltu	a3,a0,17f8 <_vsnprintf+0x1d8>
    1732:	02400793          	li	a5,36
    1736:	f2a7fde3          	bgeu	a5,a0,1670 <_vsnprintf+0x50>
    173a:	fdb5079b          	addiw	a5,a0,-37
    173e:	0ff7f793          	zext.b	a5,a5
    1742:	04200693          	li	a3,66
    1746:	f2f6e5e3          	bltu	a3,a5,1670 <_vsnprintf+0x50>
    174a:	6695                	lui	a3,0x5
    174c:	68068693          	addi	a3,a3,1664 # 5680 <__errno+0x2e4>
    1750:	44f6c78b          	th.lrw	a5,a3,a5,2
    1754:	8782                	jr	a5
    1756:	0001                	nop
    1758:	4981                	li	s3,0
    175a:	864e                	mv	a2,s3
    175c:	a019                	j	1762 <_vsnprintf+0x142>
    175e:	0001                	nop
    1760:	0785                	addi	a5,a5,1
    1762:	0026199b          	slliw	s3,a2,0x2
    1766:	00c989bb          	addw	s3,s3,a2
    176a:	0019999b          	slliw	s3,s3,0x1
    176e:	00a989bb          	addw	s3,s3,a0
    1772:	0007c503          	lbu	a0,0(a5)
    1776:	fd09861b          	addiw	a2,s3,-48
    177a:	893e                	mv	s2,a5
    177c:	fd05071b          	addiw	a4,a0,-48
    1780:	0ff77713          	zext.b	a4,a4
    1784:	fce6fee3          	bgeu	a3,a4,1760 <_vsnprintf+0x140>
    1788:	02e00693          	li	a3,46
    178c:	89b2                	mv	s3,a2
    178e:	0785                	addi	a5,a5,1
    1790:	4701                	li	a4,0
    1792:	f2d51ce3          	bne	a0,a3,16ca <_vsnprintf+0xaa>
    1796:	00194503          	lbu	a0,1(s2)
    179a:	40046413          	ori	s0,s0,1024
    179e:	4625                	li	a2,9
    17a0:	fd05059b          	addiw	a1,a0,-48
    17a4:	0ff5f593          	zext.b	a1,a1
    17a8:	2401                	sext.w	s0,s0
    17aa:	86be                	mv	a3,a5
    17ac:	22b67c63          	bgeu	a2,a1,19e4 <_vsnprintf+0x3c4>
    17b0:	02a00693          	li	a3,42
    17b4:	56d50c63          	beq	a0,a3,1d2c <_vsnprintf+0x70c>
    17b8:	893e                	mv	s2,a5
    17ba:	0785                	addi	a5,a5,1
    17bc:	b739                	j	16ca <_vsnprintf+0xaa>
    17be:	0001                	nop
    17c0:	6da6                	ld	s11,72(sp)
    17c2:	6d46                	ld	s10,80(sp)
    17c4:	6ce6                	ld	s9,88(sp)
    17c6:	7c06                	ld	s8,96(sp)
    17c8:	69aa                	ld	s3,136(sp)
    17ca:	694a                	ld	s2,144(sp)
    17cc:	7ba6                	ld	s7,104(sp)
    17ce:	0004841b          	sext.w	s0,s1
    17d2:	0154b7b3          	sltu	a5,s1,s5
    17d6:	fffa8613          	addi	a2,s5,-1
    17da:	85da                	mv	a1,s6
    17dc:	42f4960b          	th.mvnez	a2,s1,a5
    17e0:	86d6                	mv	a3,s5
    17e2:	4501                	li	a0,0
    17e4:	9a02                	jalr	s4
    17e6:	70aa                	ld	ra,168(sp)
    17e8:	8522                	mv	a0,s0
    17ea:	64ea                	ld	s1,152(sp)
    17ec:	740a                	ld	s0,160(sp)
    17ee:	7b46                	ld	s6,112(sp)
    17f0:	7ae6                	ld	s5,120(sp)
    17f2:	6a0a                	ld	s4,128(sp)
    17f4:	614d                	addi	sp,sp,176
    17f6:	8082                	ret
    17f8:	f975079b          	addiw	a5,a0,-105
    17fc:	0ff7f793          	zext.b	a5,a5
    1800:	46bd                	li	a3,15
    1802:	e6f6e7e3          	bltu	a3,a5,1670 <_vsnprintf+0x50>
    1806:	4605                	li	a2,1
    1808:	66a5                	lui	a3,0x9
    180a:	00f61d33          	sll	s10,a2,a5
    180e:	04168693          	addi	a3,a3,65 # 9041 <_global_impure_ptr+0x37c1>
    1812:	00dd7d33          	and	s10,s10,a3
    1816:	4e0d1c63          	bnez	s10,1d0e <_vsnprintf+0x6ee>
    181a:	46a9                	li	a3,10
    181c:	20d78263          	beq	a5,a3,1a20 <_vsnprintf+0x400>
    1820:	469d                	li	a3,7
    1822:	e4d797e3          	bne	a5,a3,1670 <_vsnprintf+0x50>
    1826:	85ee                	mv	a1,s11
    1828:	7885c68b          	th.ldia	a3,(a1),8,0
    182c:	87a2                	mv	a5,s0
    182e:	40047e13          	andi	t3,s0,1024
    1832:	50069a63          	bnez	a3,1d46 <_vsnprintf+0x726>
    1836:	fef47313          	andi	t1,s0,-17
    183a:	02136313          	ori	t1,t1,33
    183e:	2301                	sext.w	t1,t1
    1840:	1a0e1ae3          	bnez	t3,21f4 <_vsnprintf+0xbd4>
    1844:	4801                	li	a6,0
    1846:	4681                	li	a3,0
    1848:	1000                	addi	s0,sp,32
    184a:	48a5                	li	a7,9
    184c:	453d                	li	a0,15
    184e:	02000e93          	li	t4,32
    1852:	a029                	j	185c <_vsnprintf+0x23c>
    1854:	17d78ee3          	beq	a5,t4,21d0 <_vsnprintf+0xbb0>
    1858:	8d3e                	mv	s10,a5
    185a:	86b2                	mv	a3,a2
    185c:	00f6f613          	andi	a2,a3,15
    1860:	87b2                	mv	a5,a2
    1862:	03078f13          	addi	t5,a5,48
    1866:	00c8b633          	sltu	a2,a7,a2
    186a:	03778793          	addi	a5,a5,55
    186e:	40cf178b          	th.mveqz	a5,t5,a2
    1872:	01a4578b          	th.srb	a5,s0,s10,0
    1876:	0046d613          	srli	a2,a3,0x4
    187a:	001d0793          	addi	a5,s10,1
    187e:	fcd56be3          	bltu	a0,a3,1854 <_vsnprintf+0x234>
    1882:	00237693          	andi	a3,t1,2
    1886:	06069ce3          	bnez	a3,20fe <_vsnprintf+0xade>
    188a:	00c37693          	andi	a3,t1,12
    188e:	48069ee3          	bnez	a3,252a <_vsnprintf+0xf0a>
    1892:	4541                	li	a0,16
    1894:	86aa                	mv	a3,a0
    1896:	7c07360b          	th.extu	a2,a4,31,0
    189a:	44c7e7e3          	bltu	a5,a2,24e8 <_vsnprintf+0xec8>
    189e:	866a                	mv	a2,s10
    18a0:	8d3e                	mv	s10,a5
    18a2:	87b2                	mv	a5,a2
    18a4:	00ad6463          	bltu	s10,a0,18ac <_vsnprintf+0x28c>
    18a8:	4200206f          	j	3cc8 <_vsnprintf+0x26a8>
    18ac:	03000893          	li	a7,48
    18b0:	002d07b3          	add	a5,s10,sp
    18b4:	03178023          	sb	a7,32(a5)
    18b8:	001d0613          	addi	a2,s10,1
    18bc:	0ea67c63          	bgeu	a2,a0,19b4 <_vsnprintf+0x394>
    18c0:	1000                	addi	s0,sp,32
    18c2:	008607b3          	add	a5,a2,s0
    18c6:	01178023          	sb	a7,0(a5)
    18ca:	002d0793          	addi	a5,s10,2
    18ce:	0ea7f363          	bgeu	a5,a0,19b4 <_vsnprintf+0x394>
    18d2:	008d07b3          	add	a5,s10,s0
    18d6:	01178123          	sb	a7,2(a5)
    18da:	003d0793          	addi	a5,s10,3
    18de:	0ca7fb63          	bgeu	a5,a0,19b4 <_vsnprintf+0x394>
    18e2:	002788b3          	add	a7,a5,sp
    18e6:	03000793          	li	a5,48
    18ea:	02f88023          	sb	a5,32(a7)
    18ee:	004d0893          	addi	a7,s10,4
    18f2:	0ca8f163          	bgeu	a7,a0,19b4 <_vsnprintf+0x394>
    18f6:	002d08b3          	add	a7,s10,sp
    18fa:	02f88223          	sb	a5,36(a7)
    18fe:	005d0893          	addi	a7,s10,5
    1902:	0aa8f963          	bgeu	a7,a0,19b4 <_vsnprintf+0x394>
    1906:	002d08b3          	add	a7,s10,sp
    190a:	02f882a3          	sb	a5,37(a7)
    190e:	006d0893          	addi	a7,s10,6
    1912:	0aa8f163          	bgeu	a7,a0,19b4 <_vsnprintf+0x394>
    1916:	002d08b3          	add	a7,s10,sp
    191a:	02f88323          	sb	a5,38(a7)
    191e:	007d0893          	addi	a7,s10,7
    1922:	08a8f963          	bgeu	a7,a0,19b4 <_vsnprintf+0x394>
    1926:	002d08b3          	add	a7,s10,sp
    192a:	02f883a3          	sb	a5,39(a7)
    192e:	008d0893          	addi	a7,s10,8
    1932:	08a8f163          	bgeu	a7,a0,19b4 <_vsnprintf+0x394>
    1936:	002d08b3          	add	a7,s10,sp
    193a:	02f88423          	sb	a5,40(a7)
    193e:	009d0893          	addi	a7,s10,9
    1942:	06a8f963          	bgeu	a7,a0,19b4 <_vsnprintf+0x394>
    1946:	002d08b3          	add	a7,s10,sp
    194a:	02f884a3          	sb	a5,41(a7)
    194e:	00ad0893          	addi	a7,s10,10
    1952:	06a8f163          	bgeu	a7,a0,19b4 <_vsnprintf+0x394>
    1956:	002d08b3          	add	a7,s10,sp
    195a:	02f88523          	sb	a5,42(a7)
    195e:	00bd0893          	addi	a7,s10,11
    1962:	04a8f963          	bgeu	a7,a0,19b4 <_vsnprintf+0x394>
    1966:	002d08b3          	add	a7,s10,sp
    196a:	02f885a3          	sb	a5,43(a7)
    196e:	00cd0893          	addi	a7,s10,12
    1972:	04a8f163          	bgeu	a7,a0,19b4 <_vsnprintf+0x394>
    1976:	002d08b3          	add	a7,s10,sp
    197a:	02f88623          	sb	a5,44(a7)
    197e:	00dd0793          	addi	a5,s10,13
    1982:	02a7f963          	bgeu	a5,a0,19b4 <_vsnprintf+0x394>
    1986:	1000                	addi	s0,sp,32
    1988:	008d07b3          	add	a5,s10,s0
    198c:	03000893          	li	a7,48
    1990:	011786a3          	sb	a7,13(a5)
    1994:	00ed0793          	addi	a5,s10,14
    1998:	00a7fe63          	bgeu	a5,a0,19b4 <_vsnprintf+0x394>
    199c:	008d07b3          	add	a5,s10,s0
    19a0:	01a03eb3          	snez	t4,s10
    19a4:	01178723          	sb	a7,14(a5)
    19a8:	0ebd                	addi	t4,t4,15
    19aa:	00aef563          	bgeu	t4,a0,19b4 <_vsnprintf+0x394>
    19ae:	031107a3          	sb	a7,47(sp)
    19b2:	4541                	li	a0,16
    19b4:	fff50793          	addi	a5,a0,-1
    19b8:	41a787b3          	sub	a5,a5,s10
    19bc:	00c53633          	sltu	a2,a0,a2
    19c0:	42c0178b          	th.mvnez	a5,zero,a2
    19c4:	9d3e                	add	s10,s10,a5
    19c6:	001d0793          	addi	a5,s10,1
    19ca:	0e0802e3          	beqz	a6,22ae <_vsnprintf+0xc8e>
    19ce:	000e1863          	bnez	t3,19de <_vsnprintf+0x3be>
    19d2:	7c07370b          	th.extu	a4,a4,31,0
    19d6:	0cf702e3          	beq	a4,a5,229a <_vsnprintf+0xc7a>
    19da:	40f501e3          	beq	a0,a5,25dc <_vsnprintf+0xfbc>
    19de:	4801                	li	a6,0
    19e0:	a789                	j	2122 <_vsnprintf+0xb02>
    19e2:	0001                	nop
    19e4:	0027179b          	slliw	a5,a4,0x2
    19e8:	9fb9                	addw	a5,a5,a4
    19ea:	0017979b          	slliw	a5,a5,0x1
    19ee:	9fa9                	addw	a5,a5,a0
    19f0:	8816c50b          	th.lbuib	a0,(a3),1,0
    19f4:	fd07871b          	addiw	a4,a5,-48
    19f8:	fd05079b          	addiw	a5,a0,-48
    19fc:	0ff7f793          	zext.b	a5,a5
    1a00:	fef672e3          	bgeu	a2,a5,19e4 <_vsnprintf+0x3c4>
    1a04:	8936                	mv	s2,a3
    1a06:	00168793          	addi	a5,a3,1
    1a0a:	b1c1                	j	16ca <_vsnprintf+0xaa>
    1a0c:	588dc98b          	th.lwia	s3,(s11),8,0
    1a10:	0809c063          	bltz	s3,1a90 <_vsnprintf+0x470>
    1a14:	00194503          	lbu	a0,1(s2)
    1a18:	893e                	mv	s2,a5
    1a1a:	0785                	addi	a5,a5,1
    1a1c:	b155                	j	16c0 <_vsnprintf+0xa0>
    1a1e:	0001                	nop
    1a20:	85ee                	mv	a1,s11
    1a22:	7885c80b          	th.ldia	a6,(a1),8,0
    1a26:	57fd                	li	a5,-1
    1a28:	7c07360b          	th.extu	a2,a4,31,0
    1a2c:	00084503          	lbu	a0,0(a6)
    1a30:	40e7960b          	th.mveqz	a2,a5,a4
    1a34:	9642                	add	a2,a2,a6
    1a36:	87c2                	mv	a5,a6
    1a38:	320500e3          	beqz	a0,2558 <_vsnprintf+0xf38>
    1a3c:	00000013          	nop
    1a40:	00c78563          	beq	a5,a2,1a4a <_vsnprintf+0x42a>
    1a44:	8817c68b          	th.lbuib	a3,(a5),1,0
    1a48:	fee5                	bnez	a3,1a40 <_vsnprintf+0x420>
    1a4a:	40047693          	andi	a3,s0,1024
    1a4e:	410787bb          	subw	a5,a5,a6
    1a52:	30069063          	bnez	a3,1d52 <_vsnprintf+0x732>
    1a56:	8809                	andi	s0,s0,2
    1a58:	300407e3          	beqz	s0,2566 <_vsnprintf+0xf46>
    1a5c:	8da6                	mv	s11,s1
    1a5e:	4409                	li	s0,2
    1a60:	84ee                	mv	s1,s11
    1a62:	41b80d33          	sub	s10,a6,s11
    1a66:	e422                	sd	s0,8(sp)
    1a68:	8dbe                	mv	s11,a5
    1a6a:	8426                	mv	s0,s1
    1a6c:	84ae                	mv	s1,a1
    1a6e:	0001                	nop
    1a70:	8622                	mv	a2,s0
    1a72:	86d6                	mv	a3,s5
    1a74:	85da                	mv	a1,s6
    1a76:	0405                	addi	s0,s0,1
    1a78:	9a02                	jalr	s4
    1a7a:	808d450b          	th.lrbu	a0,s10,s0,0
    1a7e:	f96d                	bnez	a0,1a70 <_vsnprintf+0x450>
    1a80:	85a6                	mv	a1,s1
    1a82:	84a2                	mv	s1,s0
    1a84:	6422                	ld	s0,8(sp)
    1a86:	87ee                	mv	a5,s11
    1a88:	50041963          	bnez	s0,1f9a <_vsnprintf+0x97a>
    1a8c:	8dae                	mv	s11,a1
    1a8e:	b6f5                	j	167a <_vsnprintf+0x5a>
    1a90:	00246413          	ori	s0,s0,2
    1a94:	00194503          	lbu	a0,1(s2)
    1a98:	2401                	sext.w	s0,s0
    1a9a:	893e                	mv	s2,a5
    1a9c:	413009bb          	negw	s3,s3
    1aa0:	0785                	addi	a5,a5,1
    1aa2:	b939                	j	16c0 <_vsnprintf+0xa0>
    1aa4:	00194503          	lbu	a0,1(s2)
    1aa8:	06800693          	li	a3,104
    1aac:	6ad50063          	beq	a0,a3,214c <_vsnprintf+0xb2c>
    1ab0:	08046413          	ori	s0,s0,128
    1ab4:	2401                	sext.w	s0,s0
    1ab6:	0785                	addi	a5,a5,1
    1ab8:	b985                	j	1728 <_vsnprintf+0x108>
    1aba:	00194503          	lbu	a0,1(s2)
    1abe:	06c00693          	li	a3,108
    1ac2:	c4d51fe3          	bne	a0,a3,1720 <_vsnprintf+0x100>
    1ac6:	30046413          	ori	s0,s0,768
    1aca:	00294503          	lbu	a0,2(s2)
    1ace:	2401                	sext.w	s0,s0
    1ad0:	00390793          	addi	a5,s2,3
    1ad4:	b991                	j	1728 <_vsnprintf+0x108>
    1ad6:	06700793          	li	a5,103
    1ada:	2cf50563          	beq	a0,a5,1da4 <_vsnprintf+0x784>
    1ade:	04700793          	li	a5,71
    1ae2:	60f50463          	beq	a0,a5,20ea <_vsnprintf+0xaca>
    1ae6:	04500793          	li	a5,69
    1aea:	60f50663          	beq	a0,a5,20f6 <_vsnprintf+0xad6>
    1aee:	000db507          	fld	fa0,0(s11)
    1af2:	008d8793          	addi	a5,s11,8
    1af6:	e43e                	sd	a5,8(sp)
    1af8:	a2a527d3          	feq.d	a5,fa0,fa0
    1afc:	5c078b63          	beqz	a5,20d2 <_vsnprintf+0xab2>
    1b00:	6795                	lui	a5,0x5
    1b02:	7e87b787          	fld	fa5,2024(a5) # 57e8 <pow10.0+0x58>
    1b06:	a2a797d3          	flt.d	a5,fa5,fa0
    1b0a:	5c079463          	bnez	a5,20d2 <_vsnprintf+0xab2>
    1b0e:	6795                	lui	a5,0x5
    1b10:	7e07b787          	fld	fa5,2016(a5) # 57e0 <pow10.0+0x50>
    1b14:	a2f517d3          	flt.d	a5,fa0,fa5
    1b18:	5a079d63          	bnez	a5,20d2 <_vsnprintf+0xab2>
    1b1c:	f20007d3          	fmv.d.x	fa5,zero
    1b20:	a2f517d3          	flt.d	a5,fa0,fa5
    1b24:	e20506d3          	fmv.x.d	a3,fa0
    1b28:	c789                	beqz	a5,1b32 <_vsnprintf+0x512>
    1b2a:	22a517d3          	fneg.d	fa5,fa0
    1b2e:	e20786d3          	fmv.x.d	a3,fa5
    1b32:	6599                	lui	a1,0x6
    1b34:	6619                	lui	a2,0x6
    1b36:	fb46b78b          	th.extu	a5,a3,62,52
    1b3a:	80863687          	fld	fa3,-2040(a2) # 5808 <pow10.0+0x78>
    1b3e:	8005b607          	fld	fa2,-2048(a1) # 5800 <pow10.0+0x70>
    1b42:	c017879b          	addiw	a5,a5,-1023
    1b46:	d20787d3          	fcvt.d.w	fa5,a5
    1b4a:	3ff00613          	li	a2,1023
    1b4e:	6799                	lui	a5,0x6
    1b50:	8107b707          	fld	fa4,-2032(a5) # 5810 <pow10.0+0x80>
    1b54:	1652                	slli	a2,a2,0x34
    1b56:	cc06b78b          	th.extu	a5,a3,51,0
    1b5a:	6ac7f643          	fmadd.d	fa2,fa5,fa2,fa3
    1b5e:	8fd1                	or	a5,a5,a2
    1b60:	f20787d3          	fmv.d.x	fa5,a5
    1b64:	6619                	lui	a2,0x6
    1b66:	0ae7f7d3          	fsub.d	fa5,fa5,fa4
    1b6a:	81863707          	fld	fa4,-2024(a2) # 5818 <pow10.0+0x88>
    1b6e:	6619                	lui	a2,0x6
    1b70:	6799                	lui	a5,0x6
    1b72:	62e7f643          	fmadd.d	fa2,fa5,fa4,fa2
    1b76:	82063707          	fld	fa4,-2016(a2) # 5820 <pow10.0+0x90>
    1b7a:	8287b687          	fld	fa3,-2008(a5) # 5828 <pow10.0+0x98>
    1b7e:	6799                	lui	a5,0x6
    1b80:	8307b007          	fld	ft0,-2000(a5) # 5830 <pow10.0+0xa0>
    1b84:	c2061653          	fcvt.w.d	a2,fa2,rtz
    1b88:	6799                	lui	a5,0x6
    1b8a:	d20607d3          	fcvt.d.w	fa5,a2
    1b8e:	8387b607          	fld	fa2,-1992(a5) # 5838 <pow10.0+0xa8>
    1b92:	6ae7f6c3          	fmadd.d	fa3,fa5,fa4,fa3
    1b96:	6799                	lui	a5,0x6
    1b98:	8407b707          	fld	fa4,-1984(a5) # 5840 <pow10.0+0xb0>
    1b9c:	6799                	lui	a5,0x6
    1b9e:	8487b587          	fld	fa1,-1976(a5) # 5848 <pow10.0+0xb8>
    1ba2:	c20697d3          	fcvt.w.d	a5,fa3,rtz
    1ba6:	6599                	lui	a1,0x6
    1ba8:	d20786d3          	fcvt.d.w	fa3,a5
    1bac:	8505b087          	fld	ft1,-1968(a1) # 5850 <pow10.0+0xc0>
    1bb0:	1206f6d3          	fmul.d	fa3,fa3,ft0
    1bb4:	6599                	lui	a1,0x6
    1bb6:	3ff7879b          	addiw	a5,a5,1023
    1bba:	17d2                	slli	a5,a5,0x34
    1bbc:	6ac7f7c7          	fmsub.d	fa5,fa5,fa2,fa3
    1bc0:	8585b607          	fld	fa2,-1960(a1) # 5858 <pow10.0+0xc8>
    1bc4:	6599                	lui	a1,0x6
    1bc6:	8605b007          	fld	ft0,-1952(a1) # 5860 <pow10.0+0xd0>
    1bca:	4519                	li	a0,6
    1bcc:	12f7f6d3          	fmul.d	fa3,fa5,fa5
    1bd0:	0af67653          	fsub.d	fa2,fa2,fa5
    1bd4:	02f7f7d3          	fadd.d	fa5,fa5,fa5
    1bd8:	40047593          	andi	a1,s0,1024
    1bdc:	1ae6f753          	fdiv.d	fa4,fa3,fa4
    1be0:	40b5170b          	th.mveqz	a4,a0,a1
    1be4:	00060d1b          	sext.w	s10,a2
    1be8:	02b77753          	fadd.d	fa4,fa4,fa1
    1bec:	1ae6f753          	fdiv.d	fa4,fa3,fa4
    1bf0:	02177753          	fadd.d	fa4,fa4,ft1
    1bf4:	1ae6f6d3          	fdiv.d	fa3,fa3,fa4
    1bf8:	f2078753          	fmv.d.x	fa4,a5
    1bfc:	02c6f6d3          	fadd.d	fa3,fa3,fa2
    1c00:	1ad7f7d3          	fdiv.d	fa5,fa5,fa3
    1c04:	0207f7d3          	fadd.d	fa5,fa5,ft0
    1c08:	12e7f7d3          	fmul.d	fa5,fa5,fa4
    1c0c:	f2068753          	fmv.d.x	fa4,a3
    1c10:	a2f717d3          	flt.d	a5,fa4,fa5
    1c14:	c789                	beqz	a5,1c1e <_vsnprintf+0x5fe>
    1c16:	1ab7f7d3          	fdiv.d	fa5,fa5,fa1
    1c1a:	fff60d1b          	addiw	s10,a2,-1
    1c1e:	6785                	lui	a5,0x1
    1c20:	80078793          	addi	a5,a5,-2048 # 800 <main+0x40>
    1c24:	063d031b          	addiw	t1,s10,99
    1c28:	0c600613          	li	a2,198
    1c2c:	00663333          	sltu	t1,a2,t1
    1c30:	8fe1                	and	a5,a5,s0
    1c32:	0311                	addi	t1,t1,4
    1c34:	00247893          	andi	a7,s0,2
    1c38:	76078363          	beqz	a5,239e <_vsnprintf+0xd7e>
    1c3c:	6799                	lui	a5,0x6
    1c3e:	8687b707          	fld	fa4,-1944(a5) # 5868 <pow10.0+0xd8>
    1c42:	f20686d3          	fmv.d.x	fa3,a3
    1c46:	a2d707d3          	fle.d	a5,fa4,fa3
    1c4a:	3e0783e3          	beqz	a5,2830 <_vsnprintf+0x1210>
    1c4e:	6799                	lui	a5,0x6
    1c50:	8707b707          	fld	fa4,-1936(a5) # 5870 <pow10.0+0xe0>
    1c54:	a2e697d3          	flt.d	a5,fa3,fa4
    1c58:	3c078ce3          	beqz	a5,2830 <_vsnprintf+0x1210>
    1c5c:	41a707bb          	subw	a5,a4,s10
    1c60:	37fd                	addiw	a5,a5,-1
    1c62:	00ed2d33          	slt	s10,s10,a4
    1c66:	41a0178b          	th.mveqz	a5,zero,s10
    1c6a:	f20007d3          	fmv.d.x	fa5,zero
    1c6e:	873e                	mv	a4,a5
    1c70:	a2f517d3          	flt.d	a5,fa0,fa5
    1c74:	c399                	beqz	a5,1c7a <_vsnprintf+0x65a>
    1c76:	0b10106f          	j	3526 <_vsnprintf+0x1f06>
    1c7a:	787d                	lui	a6,0xfffff
    1c7c:	7ff80813          	addi	a6,a6,2047 # fffffffffffff7ff <__kernel_stack+0xfffffffffff117ff>
    1c80:	01047833          	and	a6,s0,a6
    1c84:	40086813          	ori	a6,a6,1024
    1c88:	f2068553          	fmv.d.x	fa0,a3
    1c8c:	87ce                	mv	a5,s3
    1c8e:	8626                	mv	a2,s1
    1c90:	2801                	sext.w	a6,a6
    1c92:	a199                	j	20d8 <_vsnprintf+0xab8>
    1c94:	04600793          	li	a5,70
    1c98:	10f50263          	beq	a0,a5,1d9c <_vsnprintf+0x77c>
    1c9c:	000db507          	fld	fa0,0(s11)
    1ca0:	8626                	mv	a2,s1
    1ca2:	8822                	mv	a6,s0
    1ca4:	87ce                	mv	a5,s3
    1ca6:	86d6                	mv	a3,s5
    1ca8:	85da                	mv	a1,s6
    1caa:	8552                	mv	a0,s4
    1cac:	934ff0ef          	jal	de0 <_ftoa>
    1cb0:	0da1                	addi	s11,s11,8
    1cb2:	84aa                	mv	s1,a0
    1cb4:	b2d9                	j	167a <_vsnprintf+0x5a>
    1cb6:	00247793          	andi	a5,s0,2
    1cba:	00148d13          	addi	s10,s1,1
    1cbe:	008d8413          	addi	s0,s11,8
    1cc2:	4c078463          	beqz	a5,218a <_vsnprintf+0xb6a>
    1cc6:	000dc503          	lbu	a0,0(s11)
    1cca:	86d6                	mv	a3,s5
    1ccc:	8626                	mv	a2,s1
    1cce:	85da                	mv	a1,s6
    1cd0:	9a02                	jalr	s4
    1cd2:	4785                	li	a5,1
    1cd4:	1137f0e3          	bgeu	a5,s3,25d4 <_vsnprintf+0xfb4>
    1cd8:	ffe9879b          	addiw	a5,s3,-2
    1cdc:	7c07b78b          	th.extu	a5,a5,31,0
    1ce0:	0489                	addi	s1,s1,2
    1ce2:	94be                	add	s1,s1,a5
    1ce4:	00000013          	nop
    1ce8:	866a                	mv	a2,s10
    1cea:	86d6                	mv	a3,s5
    1cec:	0d05                	addi	s10,s10,1
    1cee:	85da                	mv	a1,s6
    1cf0:	02000513          	li	a0,32
    1cf4:	9a02                	jalr	s4
    1cf6:	fe9d19e3          	bne	s10,s1,1ce8 <_vsnprintf+0x6c8>
    1cfa:	8da2                	mv	s11,s0
    1cfc:	babd                	j	167a <_vsnprintf+0x5a>
    1cfe:	8626                	mv	a2,s1
    1d00:	86d6                	mv	a3,s5
    1d02:	85da                	mv	a1,s6
    1d04:	02500513          	li	a0,37
    1d08:	0485                	addi	s1,s1,1
    1d0a:	9a02                	jalr	s4
    1d0c:	b2bd                	j	167a <_vsnprintf+0x5a>
    1d0e:	06f00793          	li	a5,111
    1d12:	0af50063          	beq	a0,a5,1db2 <_vsnprintf+0x792>
    1d16:	40a7f0e3          	bgeu	a5,a0,2916 <_vsnprintf+0x12f6>
    1d1a:	07800793          	li	a5,120
    1d1e:	02f504e3          	beq	a0,a5,2546 <_vsnprintf+0xf26>
    1d22:	983d                	andi	s0,s0,-17
    1d24:	46a9                	li	a3,10
    1d26:	2401                	sext.w	s0,s0
    1d28:	88b6                	mv	a7,a3
    1d2a:	a071                	j	1db6 <_vsnprintf+0x796>
    1d2c:	588dc70b          	th.lwia	a4,(s11),8,0
    1d30:	00294503          	lbu	a0,2(s2)
    1d34:	0909                	addi	s2,s2,2
    1d36:	00072793          	slti	a5,a4,0
    1d3a:	42f0170b          	th.mvnez	a4,zero,a5
    1d3e:	2701                	sext.w	a4,a4
    1d40:	00190793          	addi	a5,s2,1
    1d44:	b259                	j	16ca <_vsnprintf+0xaa>
    1d46:	02146313          	ori	t1,s0,33
    1d4a:	2301                	sext.w	t1,t1
    1d4c:	01047813          	andi	a6,s0,16
    1d50:	bce5                	j	1848 <_vsnprintf+0x228>
    1d52:	00e7b6b3          	sltu	a3,a5,a4
    1d56:	8809                	andi	s0,s0,2
    1d58:	40d7178b          	th.mveqz	a5,a4,a3
    1d5c:	2a040fe3          	beqz	s0,281a <_vsnprintf+0x11fa>
    1d60:	8da6                	mv	s11,s1
    1d62:	4409                	li	s0,2
    1d64:	866e                	mv	a2,s11
    1d66:	7c07370b          	th.extu	a4,a4,31,0
    1d6a:	e43e                	sd	a5,8(sp)
    1d6c:	e822                	sd	s0,16(sp)
    1d6e:	01b704b3          	add	s1,a4,s11
    1d72:	41b80d33          	sub	s10,a6,s11
    1d76:	87b2                	mv	a5,a2
    1d78:	8dae                	mv	s11,a1
    1d7a:	0001                	nop
    1d7c:	00000013          	nop
    1d80:	3ef48863          	beq	s1,a5,2170 <_vsnprintf+0xb50>
    1d84:	86d6                	mv	a3,s5
    1d86:	863e                	mv	a2,a5
    1d88:	85da                	mv	a1,s6
    1d8a:	00178413          	addi	s0,a5,1
    1d8e:	9a02                	jalr	s4
    1d90:	808d450b          	th.lrbu	a0,s10,s0,0
    1d94:	3e050463          	beqz	a0,217c <_vsnprintf+0xb5c>
    1d98:	87a2                	mv	a5,s0
    1d9a:	b7dd                	j	1d80 <_vsnprintf+0x760>
    1d9c:	02046413          	ori	s0,s0,32
    1da0:	2401                	sext.w	s0,s0
    1da2:	bded                	j	1c9c <_vsnprintf+0x67c>
    1da4:	6785                	lui	a5,0x1
    1da6:	80078793          	addi	a5,a5,-2048 # 800 <main+0x40>
    1daa:	8fc1                	or	a5,a5,s0
    1dac:	0007841b          	sext.w	s0,a5
    1db0:	bb3d                	j	1aee <_vsnprintf+0x4ce>
    1db2:	46a1                	li	a3,8
    1db4:	88b6                	mv	a7,a3
    1db6:	ff247793          	andi	a5,s0,-14
    1dba:	ff347613          	andi	a2,s0,-13
    1dbe:	2781                	sext.w	a5,a5
    1dc0:	2601                	sext.w	a2,a2
    1dc2:	40047813          	andi	a6,s0,1024
    1dc6:	4307960b          	th.mvnez	a2,a5,a6
    1dca:	008d8593          	addi	a1,s11,8
    1dce:	20067793          	andi	a5,a2,512
    1dd2:	e42e                	sd	a1,8(sp)
    1dd4:	8e32                	mv	t3,a2
    1dd6:	0a0791e3          	bnez	a5,2678 <_vsnprintf+0x1058>
    1dda:	10067793          	andi	a5,a2,256
    1dde:	4a0796e3          	bnez	a5,2a8a <_vsnprintf+0x146a>
    1de2:	04067793          	andi	a5,a2,64
    1de6:	76079663          	bnez	a5,2552 <_vsnprintf+0xf32>
    1dea:	080e7e13          	andi	t3,t3,128
    1dee:	000e1463          	bnez	t3,1df6 <_vsnprintf+0x7d6>
    1df2:	26e0106f          	j	3060 <_vsnprintf+0x1a40>
    1df6:	000dd583          	lhu	a1,0(s11)
    1dfa:	7c05b58b          	th.extu	a1,a1,31,0
    1dfe:	5e059be3          	bnez	a1,2bf4 <_vsnprintf+0x15d4>
    1e02:	87b2                	mv	a5,a2
    1e04:	fe367f13          	andi	t5,a2,-29
    1e08:	00080463          	beqz	a6,1e10 <_vsnprintf+0x7f0>
    1e0c:	27c0106f          	j	3088 <_vsnprintf+0x1a68>
    1e10:	4e01                	li	t3,0
    1e12:	145f360b          	th.extu	a2,t5,5,5
    1e16:	06100793          	li	a5,97
    1e1a:	c219                	beqz	a2,1e20 <_vsnprintf+0x800>
    1e1c:	04100793          	li	a5,65
    1e20:	ff678e9b          	addiw	t4,a5,-10
    1e24:	4501                	li	a0,0
    1e26:	1000                	addi	s0,sp,32
    1e28:	42a5                	li	t0,9
    1e2a:	02000f93          	li	t6,32
    1e2e:	a039                	j	1e3c <_vsnprintf+0x81c>
    1e30:	01fd9463          	bne	s11,t6,1e38 <_vsnprintf+0x818>
    1e34:	1920106f          	j	2fc6 <_vsnprintf+0x19a6>
    1e38:	856e                	mv	a0,s11
    1e3a:	859a                	mv	a1,t1
    1e3c:	02d5d333          	divu	t1,a1,a3
    1e40:	862e                	mv	a2,a1
    1e42:	00150d93          	addi	s11,a0,1
    1e46:	22d3160b          	th.muls	a2,t1,a3
    1e4a:	0ff67793          	zext.b	a5,a2
    1e4e:	0307839b          	addiw	t2,a5,48
    1e52:	00fe87bb          	addw	a5,t4,a5
    1e56:	00c2b633          	sltu	a2,t0,a2
    1e5a:	0ff3f393          	zext.b	t2,t2
    1e5e:	0ff7f793          	zext.b	a5,a5
    1e62:	40c3978b          	th.mveqz	a5,t2,a2
    1e66:	00a4578b          	th.srb	a5,s0,a0,0
    1e6a:	fcd5f3e3          	bgeu	a1,a3,1e30 <_vsnprintf+0x810>
    1e6e:	002f7693          	andi	a3,t5,2
    1e72:	87fa                	mv	a5,t5
    1e74:	5a0687e3          	beqz	a3,2c22 <_vsnprintf+0x1602>
    1e78:	000e1463          	bnez	t3,1e80 <_vsnprintf+0x860>
    1e7c:	7ce0106f          	j	364a <_vsnprintf+0x202a>
    1e80:	00080463          	beqz	a6,1e88 <_vsnprintf+0x868>
    1e84:	7dc0106f          	j	3660 <_vsnprintf+0x2040>
    1e88:	7c07370b          	th.extu	a4,a4,31,0
    1e8c:	4809                	li	a6,2
    1e8e:	01b71463          	bne	a4,s11,1e96 <_vsnprintf+0x876>
    1e92:	0b90106f          	j	374a <_vsnprintf+0x212a>
    1e96:	7c09b78b          	th.extu	a5,s3,31,0
    1e9a:	01b79463          	bne	a5,s11,1ea2 <_vsnprintf+0x882>
    1e9e:	0ad0106f          	j	374a <_vsnprintf+0x212a>
    1ea2:	003f7793          	andi	a5,t5,3
    1ea6:	46c1                	li	a3,16
    1ea8:	873e                	mv	a4,a5
    1eaa:	8e42                	mv	t3,a6
    1eac:	00d89463          	bne	a7,a3,1eb4 <_vsnprintf+0x894>
    1eb0:	06b0106f          	j	371a <_vsnprintf+0x20fa>
    1eb4:	4689                	li	a3,2
    1eb6:	00d89463          	bne	a7,a3,1ebe <_vsnprintf+0x89e>
    1eba:	0b10106f          	j	376a <_vsnprintf+0x214a>
    1ebe:	02000713          	li	a4,32
    1ec2:	00078f1b          	sext.w	t5,a5
    1ec6:	72ed9863          	bne	s11,a4,25f6 <_vsnprintf+0xfd6>
    1eca:	000f0463          	beqz	t5,1ed2 <_vsnprintf+0x8b2>
    1ece:	4f00106f          	j	33be <_vsnprintf+0x1d9e>
    1ed2:	02000d93          	li	s11,32
    1ed6:	7c09b40b          	th.extu	s0,s3,31,0
    1eda:	013de463          	bltu	s11,s3,1ee2 <_vsnprintf+0x8c2>
    1ede:	0ad0106f          	j	378a <_vsnprintf+0x216a>
    1ee2:	874a                	mv	a4,s2
    1ee4:	409d87b3          	sub	a5,s11,s1
    1ee8:	8926                	mv	s2,s1
    1eea:	fbc1548b          	th.sdd	s1,t3,(sp),1,4
    1eee:	8d3a                	mv	s10,a4
    1ef0:	84be                	mv	s1,a5
    1ef2:	0001                	nop
    1ef4:	00000013          	nop
    1ef8:	864a                	mv	a2,s2
    1efa:	86d6                	mv	a3,s5
    1efc:	85da                	mv	a1,s6
    1efe:	02000513          	li	a0,32
    1f02:	0905                	addi	s2,s2,1
    1f04:	9a02                	jalr	s4
    1f06:	01248733          	add	a4,s1,s2
    1f0a:	fe8767e3          	bltu	a4,s0,1ef8 <_vsnprintf+0x8d8>
    1f0e:	fbc1448b          	th.ldd	s1,t3,(sp),1,4
    1f12:	fff40793          	addi	a5,s0,-1
    1f16:	001d8693          	addi	a3,s11,1
    1f1a:	00d43733          	sltu	a4,s0,a3
    1f1e:	41b787b3          	sub	a5,a5,s11
    1f22:	42e0178b          	th.mvnez	a5,zero,a4
    1f26:	00148713          	addi	a4,s1,1
    1f2a:	896a                	mv	s2,s10
    1f2c:	97ba                	add	a5,a5,a4
    1f2e:	020d8d63          	beqz	s11,1f68 <_vsnprintf+0x948>
    1f32:	002d8733          	add	a4,s11,sp
    1f36:	01f74503          	lbu	a0,31(a4)
    1f3a:	00fd8d33          	add	s10,s11,a5
    1f3e:	fa915d0b          	th.sdd	s10,s1,(sp),1,4
    1f42:	1000                	addi	s0,sp,32
    1f44:	84ee                	mv	s1,s11
    1f46:	8df2                	mv	s11,t3
    1f48:	a031                	j	1f54 <_vsnprintf+0x934>
    1f4a:	0001                	nop
    1f4c:	00940733          	add	a4,s0,s1
    1f50:	fff74503          	lbu	a0,-1(a4)
    1f54:	409d0633          	sub	a2,s10,s1
    1f58:	86d6                	mv	a3,s5
    1f5a:	14fd                	addi	s1,s1,-1
    1f5c:	85da                	mv	a1,s6
    1f5e:	9a02                	jalr	s4
    1f60:	f4f5                	bnez	s1,1f4c <_vsnprintf+0x92c>
    1f62:	fa91478b          	th.ldd	a5,s1,(sp),1,4
    1f66:	8e6e                	mv	t3,s11
    1f68:	1c0e0be3          	beqz	t3,293e <_vsnprintf+0x131e>
    1f6c:	409785b3          	sub	a1,a5,s1
    1f70:	7c09b98b          	th.extu	s3,s3,31,0
    1f74:	1d35f5e3          	bgeu	a1,s3,293e <_vsnprintf+0x131e>
    1f78:	40978433          	sub	s0,a5,s1
    1f7c:	84be                	mv	s1,a5
    1f7e:	0001                	nop
    1f80:	8626                	mv	a2,s1
    1f82:	86d6                	mv	a3,s5
    1f84:	85da                	mv	a1,s6
    1f86:	02000513          	li	a0,32
    1f8a:	0405                	addi	s0,s0,1
    1f8c:	0485                	addi	s1,s1,1
    1f8e:	9a02                	jalr	s4
    1f90:	ff3468e3          	bltu	s0,s3,1f80 <_vsnprintf+0x960>
    1f94:	6da2                	ld	s11,8(sp)
    1f96:	ee4ff06f          	j	167a <_vsnprintf+0x5a>
    1f9a:	8426                	mv	s0,s1
    1f9c:	af37f8e3          	bgeu	a5,s3,1a8c <_vsnprintf+0x46c>
    1fa0:	39fd                	addiw	s3,s3,-1
    1fa2:	40f987bb          	subw	a5,s3,a5
    1fa6:	7c07b78b          	th.extu	a5,a5,31,0
    1faa:	0485                	addi	s1,s1,1
    1fac:	94be                	add	s1,s1,a5
    1fae:	89ae                	mv	s3,a1
    1fb0:	8622                	mv	a2,s0
    1fb2:	86d6                	mv	a3,s5
    1fb4:	0405                	addi	s0,s0,1
    1fb6:	85da                	mv	a1,s6
    1fb8:	02000513          	li	a0,32
    1fbc:	9a02                	jalr	s4
    1fbe:	fe9419e3          	bne	s0,s1,1fb0 <_vsnprintf+0x990>
    1fc2:	85ce                	mv	a1,s3
    1fc4:	8dae                	mv	s11,a1
    1fc6:	eb4ff06f          	j	167a <_vsnprintf+0x5a>
    1fca:	05800793          	li	a5,88
    1fce:	18f50b63          	beq	a0,a5,2164 <_vsnprintf+0xb44>
    1fd2:	4689                	li	a3,2
    1fd4:	06200793          	li	a5,98
    1fd8:	88b6                	mv	a7,a3
    1fda:	dcf50ee3          	beq	a0,a5,1db6 <_vsnprintf+0x796>
    1fde:	40047793          	andi	a5,s0,1024
    1fe2:	2e079363          	bnez	a5,22c8 <_vsnprintf+0xca8>
    1fe6:	fef47893          	andi	a7,s0,-17
    1fea:	20047693          	andi	a3,s0,512
    1fee:	2881                	sext.w	a7,a7
    1ff0:	008d8813          	addi	a6,s11,8
    1ff4:	2e068563          	beqz	a3,22de <_vsnprintf+0xcbe>
    1ff8:	000dbe83          	ld	t4,0(s11)
    1ffc:	4681                	li	a3,0
    1ffe:	8dc2                	mv	s11,a6
    2000:	000e8763          	beqz	t4,200e <_vsnprintf+0x9ee>
    2004:	43fed793          	srai	a5,t4,0x3f
    2008:	01d7c6b3          	xor	a3,a5,t4
    200c:	8e9d                	sub	a3,a3,a5
    200e:	4781                	li	a5,0
    2010:	1000                	addi	s0,sp,32
    2012:	45a9                	li	a1,10
    2014:	4325                	li	t1,9
    2016:	02000e13          	li	t3,32
    201a:	a029                	j	2024 <_vsnprintf+0xa04>
    201c:	01c79463          	bne	a5,t3,2024 <_vsnprintf+0xa04>
    2020:	0480106f          	j	3068 <_vsnprintf+0x1a48>
    2024:	02b6f633          	remu	a2,a3,a1
    2028:	8f3e                	mv	t5,a5
    202a:	0785                	addi	a5,a5,1
    202c:	00f40833          	add	a6,s0,a5
    2030:	8536                	mv	a0,a3
    2032:	0306061b          	addiw	a2,a2,48
    2036:	fec80fa3          	sb	a2,-1(a6)
    203a:	02b6d6b3          	divu	a3,a3,a1
    203e:	fca36fe3          	bltu	t1,a0,201c <_vsnprintf+0x9fc>
    2042:	0028f613          	andi	a2,a7,2
    2046:	86c6                	mv	a3,a7
    2048:	e219                	bnez	a2,204e <_vsnprintf+0xa2e>
    204a:	0700106f          	j	30ba <_vsnprintf+0x1a9a>
    204e:	02000513          	li	a0,32
    2052:	00a79463          	bne	a5,a0,205a <_vsnprintf+0xa3a>
    2056:	0a20106f          	j	30f8 <_vsnprintf+0x1ad8>
    205a:	000ec463          	bltz	t4,2062 <_vsnprintf+0xa42>
    205e:	6250106f          	j	3e82 <_vsnprintf+0x2862>
    2062:	02d00693          	li	a3,45
    2066:	978a                	add	a5,a5,sp
    2068:	02d78023          	sb	a3,32(a5)
    206c:	002f0713          	addi	a4,t5,2
    2070:	4689                	li	a3,2
    2072:	87a6                	mv	a5,s1
    2074:	02d00513          	li	a0,45
    2078:	00e78d33          	add	s10,a5,a4
    207c:	e426                	sd	s1,8(sp)
    207e:	e84a                	sd	s2,16(sp)
    2080:	84ba                	mv	s1,a4
    2082:	896a                	mv	s2,s10
    2084:	8d36                	mv	s10,a3
    2086:	a029                	j	2090 <_vsnprintf+0xa70>
    2088:	002486b3          	add	a3,s1,sp
    208c:	01f6c503          	lbu	a0,31(a3)
    2090:	40990633          	sub	a2,s2,s1
    2094:	86d6                	mv	a3,s5
    2096:	14fd                	addi	s1,s1,-1
    2098:	85da                	mv	a1,s6
    209a:	844a                	mv	s0,s2
    209c:	9a02                	jalr	s4
    209e:	f4ed                	bnez	s1,2088 <_vsnprintf+0xa68>
    20a0:	64a2                	ld	s1,8(sp)
    20a2:	6942                	ld	s2,16(sp)
    20a4:	86ea                	mv	a3,s10
    20a6:	c29d                	beqz	a3,20cc <_vsnprintf+0xaac>
    20a8:	409404b3          	sub	s1,s0,s1
    20ac:	7c09b98b          	th.extu	s3,s3,31,0
    20b0:	0134fe63          	bgeu	s1,s3,20cc <_vsnprintf+0xaac>
    20b4:	00000013          	nop
    20b8:	8622                	mv	a2,s0
    20ba:	86d6                	mv	a3,s5
    20bc:	85da                	mv	a1,s6
    20be:	02000513          	li	a0,32
    20c2:	0485                	addi	s1,s1,1
    20c4:	0405                	addi	s0,s0,1
    20c6:	9a02                	jalr	s4
    20c8:	ff34e8e3          	bltu	s1,s3,20b8 <_vsnprintf+0xa98>
    20cc:	84a2                	mv	s1,s0
    20ce:	dacff06f          	j	167a <_vsnprintf+0x5a>
    20d2:	8822                	mv	a6,s0
    20d4:	87ce                	mv	a5,s3
    20d6:	8626                	mv	a2,s1
    20d8:	86d6                	mv	a3,s5
    20da:	85da                	mv	a1,s6
    20dc:	8552                	mv	a0,s4
    20de:	d03fe0ef          	jal	de0 <_ftoa>
    20e2:	84aa                	mv	s1,a0
    20e4:	6da2                	ld	s11,8(sp)
    20e6:	d94ff06f          	j	167a <_vsnprintf+0x5a>
    20ea:	6785                	lui	a5,0x1
    20ec:	80078793          	addi	a5,a5,-2048 # 800 <main+0x40>
    20f0:	8fc1                	or	a5,a5,s0
    20f2:	0007841b          	sext.w	s0,a5
    20f6:	02046413          	ori	s0,s0,32
    20fa:	2401                	sext.w	s0,s0
    20fc:	bacd                	j	1aee <_vsnprintf+0x4ce>
    20fe:	10080d63          	beqz	a6,2218 <_vsnprintf+0xbf8>
    2102:	440e1563          	bnez	t3,254c <_vsnprintf+0xf2c>
    2106:	7c07370b          	th.extu	a4,a4,31,0
    210a:	18e78663          	beq	a5,a4,2296 <_vsnprintf+0xc76>
    210e:	4541                	li	a0,16
    2110:	86aa                	mv	a3,a0
    2112:	4e09                	li	t3,2
    2114:	8872                	mv	a6,t3
    2116:	4cf50363          	beq	a0,a5,25dc <_vsnprintf+0xfbc>
    211a:	02000713          	li	a4,32
    211e:	10e78363          	beq	a5,a4,2224 <_vsnprintf+0xc04>
    2122:	00278733          	add	a4,a5,sp
    2126:	05800613          	li	a2,88
    212a:	02c70023          	sb	a2,32(a4)
    212e:	00178d13          	addi	s10,a5,1
    2132:	02000713          	li	a4,32
    2136:	0789                	addi	a5,a5,2
    2138:	00ed1463          	bne	s10,a4,2140 <_vsnprintf+0xb20>
    213c:	4b80106f          	j	35f4 <_vsnprintf+0x1fd4>
    2140:	9d0a                	add	s10,s10,sp
    2142:	03000713          	li	a4,48
    2146:	02ed0023          	sb	a4,32(s10)
    214a:	a8c9                	j	221c <_vsnprintf+0xbfc>
    214c:	0c046413          	ori	s0,s0,192
    2150:	00294503          	lbu	a0,2(s2)
    2154:	2401                	sext.w	s0,s0
    2156:	00390793          	addi	a5,s2,3
    215a:	dceff06f          	j	1728 <_vsnprintf+0x108>
    215e:	4401                	li	s0,0
    2160:	e72ff06f          	j	17d2 <_vsnprintf+0x1b2>
    2164:	02046413          	ori	s0,s0,32
    2168:	46c1                	li	a3,16
    216a:	2401                	sext.w	s0,s0
    216c:	88b6                	mv	a7,a3
    216e:	b1a1                	j	1db6 <_vsnprintf+0x796>
    2170:	67a2                	ld	a5,8(sp)
    2172:	6442                	ld	s0,16(sp)
    2174:	85ee                	mv	a1,s11
    2176:	90040be3          	beqz	s0,1a8c <_vsnprintf+0x46c>
    217a:	b505                	j	1f9a <_vsnprintf+0x97a>
    217c:	84a2                	mv	s1,s0
    217e:	67a2                	ld	a5,8(sp)
    2180:	6442                	ld	s0,16(sp)
    2182:	85ee                	mv	a1,s11
    2184:	900404e3          	beqz	s0,1a8c <_vsnprintf+0x46c>
    2188:	bd09                	j	1f9a <_vsnprintf+0x97a>
    218a:	4785                	li	a5,1
    218c:	4337fe63          	bgeu	a5,s3,25c8 <_vsnprintf+0xfa8>
    2190:	ffe9879b          	addiw	a5,s3,-2
    2194:	7c07b78b          	th.extu	a5,a5,31,0
    2198:	e422                	sd	s0,8(sp)
    219a:	9d3e                	add	s10,s10,a5
    219c:	8426                	mv	s0,s1
    219e:	89be                	mv	s3,a5
    21a0:	8622                	mv	a2,s0
    21a2:	86d6                	mv	a3,s5
    21a4:	0405                	addi	s0,s0,1
    21a6:	85da                	mv	a1,s6
    21a8:	02000513          	li	a0,32
    21ac:	9a02                	jalr	s4
    21ae:	ffa419e3          	bne	s0,s10,21a0 <_vsnprintf+0xb80>
    21b2:	000dc503          	lbu	a0,0(s11)
    21b6:	6422                	ld	s0,8(sp)
    21b8:	013487b3          	add	a5,s1,s3
    21bc:	00178613          	addi	a2,a5,1
    21c0:	86d6                	mv	a3,s5
    21c2:	85da                	mv	a1,s6
    21c4:	00278493          	addi	s1,a5,2
    21c8:	8da2                	mv	s11,s0
    21ca:	9a02                	jalr	s4
    21cc:	caeff06f          	j	167a <_vsnprintf+0x5a>
    21d0:	00237693          	andi	a3,t1,2
    21d4:	30068263          	beqz	a3,24d8 <_vsnprintf+0xeb8>
    21d8:	00080b63          	beqz	a6,21ee <_vsnprintf+0xbce>
    21dc:	000e1963          	bnez	t3,21ee <_vsnprintf+0xbce>
    21e0:	01d71763          	bne	a4,t4,21ee <_vsnprintf+0xbce>
    21e4:	678d                	lui	a5,0x3
    21e6:	05878793          	addi	a5,a5,88 # 3058 <_vsnprintf+0x1a38>
    21ea:	02f11f23          	sh	a5,62(sp)
    21ee:	4809                	li	a6,2
    21f0:	46c1                	li	a3,16
    21f2:	a80d                	j	2224 <_vsnprintf+0xc04>
    21f4:	00247693          	andi	a3,s0,2
    21f8:	32069d63          	bnez	a3,2532 <_vsnprintf+0xf12>
    21fc:	00c47813          	andi	a6,s0,12
    2200:	3c080ce3          	beqz	a6,2dd8 <_vsnprintf+0x17b8>
    2204:	e319                	bnez	a4,220a <_vsnprintf+0xbea>
    2206:	35d0106f          	j	3d62 <_vsnprintf+0x2742>
    220a:	453d                	li	a0,15
    220c:	86aa                	mv	a3,a0
    220e:	4801                	li	a6,0
    2210:	4781                	li	a5,0
    2212:	40000e13          	li	t3,1024
    2216:	acc9                	j	24e8 <_vsnprintf+0xec8>
    2218:	4809                	li	a6,2
    221a:	46c1                	li	a3,16
    221c:	02000713          	li	a4,32
    2220:	08e79763          	bne	a5,a4,22ae <_vsnprintf+0xc8e>
    2224:	03f14503          	lbu	a0,63(sp)
    2228:	02000d13          	li	s10,32
    222c:	01a48db3          	add	s11,s1,s10
    2230:	e426                	sd	s1,8(sp)
    2232:	fb21580b          	th.sdd	a6,s2,(sp),1,4
    2236:	84ea                	mv	s1,s10
    2238:	896e                	mv	s2,s11
    223a:	89ae                	mv	s3,a1
    223c:	8db6                	mv	s11,a3
    223e:	a029                	j	2248 <_vsnprintf+0xc28>
    2240:	002486b3          	add	a3,s1,sp
    2244:	01f6c503          	lbu	a0,31(a3)
    2248:	40990633          	sub	a2,s2,s1
    224c:	86d6                	mv	a3,s5
    224e:	14fd                	addi	s1,s1,-1
    2250:	85da                	mv	a1,s6
    2252:	844a                	mv	s0,s2
    2254:	9a02                	jalr	s4
    2256:	f4ed                	bnez	s1,2240 <_vsnprintf+0xc20>
    2258:	fb21480b          	th.ldd	a6,s2,(sp),1,4
    225c:	64a2                	ld	s1,8(sp)
    225e:	85ce                	mv	a1,s3
    2260:	02080763          	beqz	a6,228e <_vsnprintf+0xc6e>
    2264:	7c0db98b          	th.extu	s3,s11,31,0
    2268:	03bd7363          	bgeu	s10,s11,228e <_vsnprintf+0xc6e>
    226c:	409404b3          	sub	s1,s0,s1
    2270:	8d2e                	mv	s10,a1
    2272:	0001                	nop
    2274:	00000013          	nop
    2278:	8622                	mv	a2,s0
    227a:	86d6                	mv	a3,s5
    227c:	85da                	mv	a1,s6
    227e:	02000513          	li	a0,32
    2282:	0485                	addi	s1,s1,1
    2284:	0405                	addi	s0,s0,1
    2286:	9a02                	jalr	s4
    2288:	ff34e8e3          	bltu	s1,s3,2278 <_vsnprintf+0xc58>
    228c:	85ea                	mv	a1,s10
    228e:	8dae                	mv	s11,a1
    2290:	84a2                	mv	s1,s0
    2292:	be8ff06f          	j	167a <_vsnprintf+0x5a>
    2296:	4e09                	li	t3,2
    2298:	46c1                	li	a3,16
    229a:	4705                	li	a4,1
    229c:	4ae79fe3          	bne	a5,a4,2f5a <_vsnprintf+0x193a>
    22a0:	678d                	lui	a5,0x3
    22a2:	05878793          	addi	a5,a5,88 # 3058 <_vsnprintf+0x1a38>
    22a6:	02f11023          	sh	a5,32(sp)
    22aa:	8872                	mv	a6,t3
    22ac:	4789                	li	a5,2
    22ae:	00437713          	andi	a4,t1,4
    22b2:	26070263          	beqz	a4,2516 <_vsnprintf+0xef6>
    22b6:	1000                	addi	s0,sp,32
    22b8:	943e                	add	s0,s0,a5
    22ba:	00178d13          	addi	s10,a5,1
    22be:	02b00513          	li	a0,43
    22c2:	00a40023          	sb	a0,0(s0)
    22c6:	b79d                	j	222c <_vsnprintf+0xc0c>
    22c8:	fee47893          	andi	a7,s0,-18
    22cc:	20047413          	andi	s0,s0,512
    22d0:	2881                	sext.w	a7,a7
    22d2:	008d8813          	addi	a6,s11,8
    22d6:	40000693          	li	a3,1024
    22da:	66041d63          	bnez	s0,2954 <_vsnprintf+0x1334>
    22de:	1008f593          	andi	a1,a7,256
    22e2:	87c6                	mv	a5,a7
    22e4:	56059263          	bnez	a1,2848 <_vsnprintf+0x1228>
    22e8:	0408f613          	andi	a2,a7,64
    22ec:	000dae03          	lw	t3,0(s11)
    22f0:	20061f63          	bnez	a2,250e <_vsnprintf+0xeee>
    22f4:	0807f793          	andi	a5,a5,128
    22f8:	2e0789e3          	beqz	a5,2dea <_vsnprintf+0x17ca>
    22fc:	3c0e2e0b          	th.ext	t3,t3,15,0
    2300:	40fe579b          	sraiw	a5,t3,0xf
    2304:	00fe4633          	xor	a2,t3,a5
    2308:	9e1d                	subw	a2,a2,a5
    230a:	3c06360b          	th.extu	a2,a2,15,0
    230e:	300e1463          	bnez	t3,2616 <_vsnprintf+0xff6>
    2312:	30068263          	beqz	a3,2616 <_vsnprintf+0xff6>
    2316:	0028f693          	andi	a3,a7,2
    231a:	87c6                	mv	a5,a7
    231c:	740688e3          	beqz	a3,326c <_vsnprintf+0x1c4c>
    2320:	0048f793          	andi	a5,a7,4
    2324:	e399                	bnez	a5,232a <_vsnprintf+0xd0a>
    2326:	5e60106f          	j	390c <_vsnprintf+0x22ec>
    232a:	02b00513          	li	a0,43
    232e:	02a10023          	sb	a0,32(sp)
    2332:	8426                	mv	s0,s1
    2334:	4589                	li	a1,2
    2336:	4705                	li	a4,1
    2338:	00870d33          	add	s10,a4,s0
    233c:	e426                	sd	s1,8(sp)
    233e:	e84a                	sd	s2,16(sp)
    2340:	84ba                	mv	s1,a4
    2342:	896a                	mv	s2,s10
    2344:	8dc2                	mv	s11,a6
    2346:	8d2e                	mv	s10,a1
    2348:	a031                	j	2354 <_vsnprintf+0xd34>
    234a:	0001                	nop
    234c:	002486b3          	add	a3,s1,sp
    2350:	01f6c503          	lbu	a0,31(a3)
    2354:	40990633          	sub	a2,s2,s1
    2358:	86d6                	mv	a3,s5
    235a:	14fd                	addi	s1,s1,-1
    235c:	85da                	mv	a1,s6
    235e:	844a                	mv	s0,s2
    2360:	9a02                	jalr	s4
    2362:	f4ed                	bnez	s1,234c <_vsnprintf+0xd2c>
    2364:	64a2                	ld	s1,8(sp)
    2366:	6942                	ld	s2,16(sp)
    2368:	85ea                	mv	a1,s10
    236a:	886e                	mv	a6,s11
    236c:	c58d                	beqz	a1,2396 <_vsnprintf+0xd76>
    236e:	409404b3          	sub	s1,s0,s1
    2372:	7c09b98b          	th.extu	s3,s3,31,0
    2376:	0334f063          	bgeu	s1,s3,2396 <_vsnprintf+0xd76>
    237a:	8d42                	mv	s10,a6
    237c:	00000013          	nop
    2380:	8622                	mv	a2,s0
    2382:	86d6                	mv	a3,s5
    2384:	85da                	mv	a1,s6
    2386:	02000513          	li	a0,32
    238a:	0485                	addi	s1,s1,1
    238c:	0405                	addi	s0,s0,1
    238e:	9a02                	jalr	s4
    2390:	ff34e8e3          	bltu	s1,s3,2380 <_vsnprintf+0xd60>
    2394:	886a                	mv	a6,s10
    2396:	8dc2                	mv	s11,a6
    2398:	84a2                	mv	s1,s0
    239a:	ae0ff06f          	j	167a <_vsnprintf+0x5a>
    239e:	01337563          	bgeu	t1,s3,23a8 <_vsnprintf+0xd88>
    23a2:	0e088ae3          	beqz	a7,2c96 <_vsnprintf+0x1676>
    23a6:	4889                	li	a7,2
    23a8:	000d0863          	beqz	s10,23b8 <_vsnprintf+0xd98>
    23ac:	f2068753          	fmv.d.x	fa4,a3
    23b0:	1af777d3          	fdiv.d	fa5,fa4,fa5
    23b4:	e20786d3          	fmv.x.d	a3,fa5
    23b8:	f20007d3          	fmv.d.x	fa5,zero
    23bc:	a2f51653          	flt.d	a2,fa0,fa5
    23c0:	c219                	beqz	a2,23c6 <_vsnprintf+0xda6>
    23c2:	0330106f          	j	3bf4 <_vsnprintf+0x25d4>
    23c6:	787d                	lui	a6,0xfffff
    23c8:	7ff80813          	addi	a6,a6,2047 # fffffffffffff7ff <__kernel_stack+0xfffffffffff117ff>
    23cc:	01047833          	and	a6,s0,a6
    23d0:	f2068553          	fmv.d.x	fa0,a3
    23d4:	fb11530b          	th.sdd	t1,a7,(sp),1,4
    23d8:	2801                	sext.w	a6,a6
    23da:	86d6                	mv	a3,s5
    23dc:	8626                	mv	a2,s1
    23de:	85da                	mv	a1,s6
    23e0:	8552                	mv	a0,s4
    23e2:	9fffe0ef          	jal	de0 <_ftoa>
    23e6:	fb11430b          	th.ldd	t1,a7,(sp),1,4
    23ea:	862a                	mv	a2,a0
    23ec:	06500793          	li	a5,101
    23f0:	02047413          	andi	s0,s0,32
    23f4:	04500513          	li	a0,69
    23f8:	4087950b          	th.mveqz	a0,a5,s0
    23fc:	86d6                	mv	a3,s5
    23fe:	85da                	mv	a1,s6
    2400:	fb11530b          	th.sdd	t1,a7,(sp),1,4
    2404:	00160d93          	addi	s11,a2,1
    2408:	9a02                	jalr	s4
    240a:	41fd579b          	sraiw	a5,s10,0x1f
    240e:	00fd4733          	xor	a4,s10,a5
    2412:	fb11430b          	th.ldd	t1,a7,(sp),1,4
    2416:	1000                	addi	s0,sp,32
    2418:	9f1d                	subw	a4,a4,a5
    241a:	4681                	li	a3,0
    241c:	45a9                	li	a1,10
    241e:	4e25                	li	t3,9
    2420:	02000e93          	li	t4,32
    2424:	a021                	j	242c <_vsnprintf+0xe0c>
    2426:	0001                	nop
    2428:	7dd68f63          	beq	a3,t4,2c06 <_vsnprintf+0x15e6>
    242c:	02b77633          	remu	a2,a4,a1
    2430:	0685                	addi	a3,a3,1
    2432:	00d407b3          	add	a5,s0,a3
    2436:	853a                	mv	a0,a4
    2438:	0306061b          	addiw	a2,a2,48
    243c:	fec78fa3          	sb	a2,-1(a5)
    2440:	02b75733          	divu	a4,a4,a1
    2444:	feae62e3          	bltu	t3,a0,2428 <_vsnprintf+0xe08>
    2448:	ffe3061b          	addiw	a2,t1,-2
    244c:	7c06360b          	th.extu	a2,a2,31,0
    2450:	7cc6f063          	bgeu	a3,a2,2c10 <_vsnprintf+0x15f0>
    2454:	00c406b3          	add	a3,s0,a2
    2458:	03000713          	li	a4,48
    245c:	00000013          	nop
    2460:	1817d70b          	th.sbia	a4,(a5),1,0
    2464:	fef69ee3          	bne	a3,a5,2460 <_vsnprintf+0xe40>
    2468:	00160793          	addi	a5,a2,1
    246c:	420d5ce3          	bgez	s10,30a4 <_vsnprintf+0x1a84>
    2470:	02d00513          	li	a0,45
    2474:	00c4550b          	th.srb	a0,s0,a2,0
    2478:	00fd8833          	add	a6,s11,a5
    247c:	fb21548b          	th.sdd	s1,s2,(sp),1,4
    2480:	8d22                	mv	s10,s0
    2482:	8dc6                	mv	s11,a7
    2484:	84be                	mv	s1,a5
    2486:	8442                	mv	s0,a6
    2488:	a031                	j	2494 <_vsnprintf+0xe74>
    248a:	0001                	nop
    248c:	009d0733          	add	a4,s10,s1
    2490:	fff74503          	lbu	a0,-1(a4)
    2494:	40940633          	sub	a2,s0,s1
    2498:	86d6                	mv	a3,s5
    249a:	14fd                	addi	s1,s1,-1
    249c:	85da                	mv	a1,s6
    249e:	9a02                	jalr	s4
    24a0:	f4f5                	bnez	s1,248c <_vsnprintf+0xe6c>
    24a2:	88ee                	mv	a7,s11
    24a4:	fb21448b          	th.ldd	s1,s2,(sp),1,4
    24a8:	8da2                	mv	s11,s0
    24aa:	8822                	mv	a6,s0
    24ac:	74088963          	beqz	a7,2bfe <_vsnprintf+0x15de>
    24b0:	409404b3          	sub	s1,s0,s1
    24b4:	7c09b98b          	th.extu	s3,s3,31,0
    24b8:	7534f363          	bgeu	s1,s3,2bfe <_vsnprintf+0x15de>
    24bc:	866e                	mv	a2,s11
    24be:	86d6                	mv	a3,s5
    24c0:	85da                	mv	a1,s6
    24c2:	02000513          	li	a0,32
    24c6:	0485                	addi	s1,s1,1
    24c8:	0d85                	addi	s11,s11,1
    24ca:	9a02                	jalr	s4
    24cc:	ff34e8e3          	bltu	s1,s3,24bc <_vsnprintf+0xe9c>
    24d0:	84ee                	mv	s1,s11
    24d2:	6da2                	ld	s11,8(sp)
    24d4:	9a6ff06f          	j	167a <_vsnprintf+0x5a>
    24d8:	00c37693          	andi	a3,t1,12
    24dc:	260682e3          	beqz	a3,2f40 <_vsnprintf+0x1920>
    24e0:	453d                	li	a0,15
    24e2:	86aa                	mv	a3,a0
    24e4:	26eef2e3          	bgeu	t4,a4,2f48 <_vsnprintf+0x1928>
    24e8:	02000613          	li	a2,32
    24ec:	03000e93          	li	t4,48
    24f0:	7c07388b          	th.extu	a7,a4,31,0
    24f4:	00000013          	nop
    24f8:	78c780e3          	beq	a5,a2,3478 <_vsnprintf+0x1e58>
    24fc:	1000                	addi	s0,sp,32
    24fe:	00f45e8b          	th.srb	t4,s0,a5,0
    2502:	00178d13          	addi	s10,a5,1
    2506:	b91d7f63          	bgeu	s10,a7,18a4 <_vsnprintf+0x284>
    250a:	87ea                	mv	a5,s10
    250c:	b7f5                	j	24f8 <_vsnprintf+0xed8>
    250e:	0ffe7e13          	zext.b	t3,t3
    2512:	8672                	mv	a2,t3
    2514:	bbed                	j	230e <_vsnprintf+0xcee>
    2516:	00837313          	andi	t1,t1,8
    251a:	0c031fe3          	bnez	t1,2df8 <_vsnprintf+0x17d8>
    251e:	00278733          	add	a4,a5,sp
    2522:	01f74503          	lbu	a0,31(a4)
    2526:	8d3e                	mv	s10,a5
    2528:	b311                	j	222c <_vsnprintf+0xc0c>
    252a:	453d                	li	a0,15
    252c:	86aa                	mv	a3,a0
    252e:	b68ff06f          	j	1896 <_vsnprintf+0x276>
    2532:	0047f713          	andi	a4,a5,4
    2536:	0c071be3          	bnez	a4,2e0c <_vsnprintf+0x17ec>
    253a:	8ba1                	andi	a5,a5,8
    253c:	5c0796e3          	bnez	a5,3308 <_vsnprintf+0x1ce8>
    2540:	8426                	mv	s0,s1
    2542:	49c1                	li	s3,16
    2544:	b325                	j	226c <_vsnprintf+0xc4c>
    2546:	46c1                	li	a3,16
    2548:	88b6                	mv	a7,a3
    254a:	b0b5                	j	1db6 <_vsnprintf+0x796>
    254c:	4809                	li	a6,2
    254e:	46c1                	li	a3,16
    2550:	b6e9                	j	211a <_vsnprintf+0xafa>
    2552:	000dc583          	lbu	a1,0(s11)
    2556:	b055                	j	1dfa <_vsnprintf+0x7da>
    2558:	40047793          	andi	a5,s0,1024
    255c:	5c079ce3          	bnez	a5,3334 <_vsnprintf+0x1d14>
    2560:	8809                	andi	s0,s0,2
    2562:	a2041ce3          	bnez	s0,1f9a <_vsnprintf+0x97a>
    2566:	4401                	li	s0,0
    2568:	0137e463          	bltu	a5,s3,2570 <_vsnprintf+0xf50>
    256c:	03c0106f          	j	35a8 <_vsnprintf+0x1f88>
    2570:	fff98d9b          	addiw	s11,s3,-1
    2574:	40fd8dbb          	subw	s11,s11,a5
    2578:	00148d13          	addi	s10,s1,1
    257c:	7c0dbd8b          	th.extu	s11,s11,31,0
    2580:	fb21540b          	th.sdd	s0,s2,(sp),1,4
    2584:	9dea                	add	s11,s11,s10
    2586:	8426                	mv	s0,s1
    2588:	e442                	sd	a6,8(sp)
    258a:	84ea                	mv	s1,s10
    258c:	892e                	mv	s2,a1
    258e:	8d3a                	mv	s10,a4
    2590:	a019                	j	2596 <_vsnprintf+0xf76>
    2592:	0001                	nop
    2594:	0485                	addi	s1,s1,1
    2596:	8622                	mv	a2,s0
    2598:	86d6                	mv	a3,s5
    259a:	85da                	mv	a1,s6
    259c:	02000513          	li	a0,32
    25a0:	8426                	mv	s0,s1
    25a2:	9a02                	jalr	s4
    25a4:	ffb498e3          	bne	s1,s11,2594 <_vsnprintf+0xf74>
    25a8:	6822                	ld	a6,8(sp)
    25aa:	85ca                	mv	a1,s2
    25ac:	876a                	mv	a4,s10
    25ae:	00084503          	lbu	a0,0(a6)
    25b2:	fb21440b          	th.ldd	s0,s2,(sp),1,4
    25b6:	0019879b          	addiw	a5,s3,1
    25ba:	cc050963          	beqz	a0,1a8c <_vsnprintf+0x46c>
    25be:	ca040163          	beqz	s0,1a60 <_vsnprintf+0x440>
    25c2:	4401                	li	s0,0
    25c4:	fa0ff06f          	j	1d64 <_vsnprintf+0x744>
    25c8:	000dc503          	lbu	a0,0(s11)
    25cc:	8626                	mv	a2,s1
    25ce:	86d6                	mv	a3,s5
    25d0:	85da                	mv	a1,s6
    25d2:	9a02                	jalr	s4
    25d4:	84ea                	mv	s1,s10
    25d6:	8da2                	mv	s11,s0
    25d8:	8a2ff06f          	j	167a <_vsnprintf+0x5a>
    25dc:	00278733          	add	a4,a5,sp
    25e0:	05800613          	li	a2,88
    25e4:	00c70f23          	sb	a2,30(a4)
    25e8:	9d0a                	add	s10,s10,sp
    25ea:	03000713          	li	a4,48
    25ee:	8872                	mv	a6,t3
    25f0:	02ed0023          	sb	a4,32(s10)
    25f4:	b96d                	j	22ae <_vsnprintf+0xc8e>
    25f6:	00e10433          	add	s0,sp,a4
    25fa:	01b40733          	add	a4,s0,s11
    25fe:	0d85                	addi	s11,s11,1
    2600:	03000513          	li	a0,48
    2604:	00a70023          	sb	a0,0(a4)
    2608:	e789                	bnez	a5,2612 <_vsnprintf+0xff2>
    260a:	7c09b40b          	th.extu	s0,s3,31,0
    260e:	8c8deae3          	bltu	s11,s0,1ee2 <_vsnprintf+0x8c2>
    2612:	87a6                	mv	a5,s1
    2614:	b21d                	j	1f3a <_vsnprintf+0x91a>
    2616:	4781                	li	a5,0
    2618:	1000                	addi	s0,sp,32
    261a:	4329                	li	t1,10
    261c:	4f25                	li	t5,9
    261e:	02000f93          	li	t6,32
    2622:	a019                	j	2628 <_vsnprintf+0x1008>
    2624:	01f782e3          	beq	a5,t6,2e28 <_vsnprintf+0x1808>
    2628:	02667533          	remu	a0,a2,t1
    262c:	86be                	mv	a3,a5
    262e:	0785                	addi	a5,a5,1
    2630:	00f402b3          	add	t0,s0,a5
    2634:	8eb2                	mv	t4,a2
    2636:	0305051b          	addiw	a0,a0,48
    263a:	fea28fa3          	sb	a0,-1(t0)
    263e:	02665633          	divu	a2,a2,t1
    2642:	ffdf61e3          	bltu	t5,t4,2624 <_vsnprintf+0x1004>
    2646:	0028f513          	andi	a0,a7,2
    264a:	8646                	mv	a2,a7
    264c:	120500e3          	beqz	a0,2f6c <_vsnprintf+0x194c>
    2650:	02000713          	li	a4,32
    2654:	7ce78263          	beq	a5,a4,2e18 <_vsnprintf+0x17f8>
    2658:	000e4463          	bltz	t3,2660 <_vsnprintf+0x1040>
    265c:	6b20106f          	j	3d0e <_vsnprintf+0x26ee>
    2660:	978a                	add	a5,a5,sp
    2662:	02d00613          	li	a2,45
    2666:	00268713          	addi	a4,a3,2
    266a:	02c78023          	sb	a2,32(a5)
    266e:	4589                	li	a1,2
    2670:	8426                	mv	s0,s1
    2672:	02d00513          	li	a0,45
    2676:	b1c9                	j	2338 <_vsnprintf+0xd18>
    2678:	000db303          	ld	t1,0(s11)
    267c:	5a031063          	bnez	t1,2c1c <_vsnprintf+0x15fc>
    2680:	fefe7613          	andi	a2,t3,-17
    2684:	2601                	sext.w	a2,a2
    2686:	36081be3          	bnez	a6,31fc <_vsnprintf+0x1bdc>
    268a:	4581                	li	a1,0
    268c:	1456350b          	th.extu	a0,a2,5,5
    2690:	06100793          	li	a5,97
    2694:	c119                	beqz	a0,269a <_vsnprintf+0x107a>
    2696:	04100793          	li	a5,65
    269a:	ff678f1b          	addiw	t5,a5,-10
    269e:	4e01                	li	t3,0
    26a0:	1000                	addi	s0,sp,32
    26a2:	42a5                	li	t0,9
    26a4:	02000f93          	li	t6,32
    26a8:	a031                	j	26b4 <_vsnprintf+0x1094>
    26aa:	0001                	nop
    26ac:	39fd80e3          	beq	s11,t6,322c <_vsnprintf+0x1c0c>
    26b0:	8e6e                	mv	t3,s11
    26b2:	8376                	mv	t1,t4
    26b4:	02d35eb3          	divu	t4,t1,a3
    26b8:	851a                	mv	a0,t1
    26ba:	001e0d93          	addi	s11,t3,1
    26be:	22de950b          	th.muls	a0,t4,a3
    26c2:	0ff57793          	zext.b	a5,a0
    26c6:	0307839b          	addiw	t2,a5,48
    26ca:	00ff07bb          	addw	a5,t5,a5
    26ce:	00a2b533          	sltu	a0,t0,a0
    26d2:	0ff3f393          	zext.b	t2,t2
    26d6:	0ff7f793          	zext.b	a5,a5
    26da:	40a3978b          	th.mveqz	a5,t2,a0
    26de:	01c4578b          	th.srb	a5,s0,t3,0
    26e2:	fcd375e3          	bgeu	t1,a3,26ac <_vsnprintf+0x108c>
    26e6:	00267693          	andi	a3,a2,2
    26ea:	87b2                	mv	a5,a2
    26ec:	100686e3          	beqz	a3,2ff8 <_vsnprintf+0x19d8>
    26f0:	e199                	bnez	a1,26f6 <_vsnprintf+0x10d6>
    26f2:	0420106f          	j	3734 <_vsnprintf+0x2114>
    26f6:	720818e3          	bnez	a6,3626 <_vsnprintf+0x2006>
    26fa:	7c07370b          	th.extu	a4,a4,31,0
    26fe:	4809                	li	a6,2
    2700:	01b71463          	bne	a4,s11,2708 <_vsnprintf+0x10e8>
    2704:	1ac0106f          	j	38b0 <_vsnprintf+0x2290>
    2708:	7c09b78b          	th.extu	a5,s3,31,0
    270c:	01b79463          	bne	a5,s11,2714 <_vsnprintf+0x10f4>
    2710:	1a00106f          	j	38b0 <_vsnprintf+0x2290>
    2714:	00367713          	andi	a4,a2,3
    2718:	46c1                	li	a3,16
    271a:	87ba                	mv	a5,a4
    271c:	85c2                	mv	a1,a6
    271e:	6ed881e3          	beq	a7,a3,3600 <_vsnprintf+0x1fe0>
    2722:	4689                	li	a3,2
    2724:	00d89463          	bne	a7,a3,272c <_vsnprintf+0x110c>
    2728:	15e0106f          	j	3886 <_vsnprintf+0x2266>
    272c:	02000693          	li	a3,32
    2730:	0007079b          	sext.w	a5,a4
    2734:	0cdd9363          	bne	s11,a3,27fa <_vsnprintf+0x11da>
    2738:	5e0790e3          	bnez	a5,3518 <_vsnprintf+0x1ef8>
    273c:	02000d93          	li	s11,32
    2740:	7c09b40b          	th.extu	s0,s3,31,0
    2744:	013de463          	bltu	s11,s3,274c <_vsnprintf+0x112c>
    2748:	15e0106f          	j	38a6 <_vsnprintf+0x2286>
    274c:	874a                	mv	a4,s2
    274e:	409d87b3          	sub	a5,s11,s1
    2752:	8926                	mv	s2,s1
    2754:	fab1548b          	th.sdd	s1,a1,(sp),1,4
    2758:	8d3a                	mv	s10,a4
    275a:	84be                	mv	s1,a5
    275c:	864a                	mv	a2,s2
    275e:	86d6                	mv	a3,s5
    2760:	85da                	mv	a1,s6
    2762:	02000513          	li	a0,32
    2766:	0905                	addi	s2,s2,1
    2768:	9a02                	jalr	s4
    276a:	01248733          	add	a4,s1,s2
    276e:	fe8767e3          	bltu	a4,s0,275c <_vsnprintf+0x113c>
    2772:	fab1448b          	th.ldd	s1,a1,(sp),1,4
    2776:	fff40793          	addi	a5,s0,-1
    277a:	001d8693          	addi	a3,s11,1
    277e:	00d43733          	sltu	a4,s0,a3
    2782:	41b787b3          	sub	a5,a5,s11
    2786:	42e0178b          	th.mvnez	a5,zero,a4
    278a:	00148713          	addi	a4,s1,1
    278e:	896a                	mv	s2,s10
    2790:	97ba                	add	a5,a5,a4
    2792:	000d9463          	bnez	s11,279a <_vsnprintf+0x117a>
    2796:	1700106f          	j	3906 <_vsnprintf+0x22e6>
    279a:	002d8733          	add	a4,s11,sp
    279e:	01f74503          	lbu	a0,31(a4)
    27a2:	00fd8d33          	add	s10,s11,a5
    27a6:	e826                	sd	s1,16(sp)
    27a8:	84ea                	mv	s1,s10
    27aa:	8d4a                	mv	s10,s2
    27ac:	892e                	mv	s2,a1
    27ae:	a029                	j	27b8 <_vsnprintf+0x1198>
    27b0:	002d8733          	add	a4,s11,sp
    27b4:	01f74503          	lbu	a0,31(a4)
    27b8:	41b48633          	sub	a2,s1,s11
    27bc:	86d6                	mv	a3,s5
    27be:	1dfd                	addi	s11,s11,-1
    27c0:	85da                	mv	a1,s6
    27c2:	8426                	mv	s0,s1
    27c4:	9a02                	jalr	s4
    27c6:	fe0d95e3          	bnez	s11,27b0 <_vsnprintf+0x1190>
    27ca:	64c2                	ld	s1,16(sp)
    27cc:	85ca                	mv	a1,s2
    27ce:	896a                	mv	s2,s10
    27d0:	c18d                	beqz	a1,27f2 <_vsnprintf+0x11d2>
    27d2:	409404b3          	sub	s1,s0,s1
    27d6:	7c09b98b          	th.extu	s3,s3,31,0
    27da:	0134fc63          	bgeu	s1,s3,27f2 <_vsnprintf+0x11d2>
    27de:	8622                	mv	a2,s0
    27e0:	86d6                	mv	a3,s5
    27e2:	85da                	mv	a1,s6
    27e4:	02000513          	li	a0,32
    27e8:	0485                	addi	s1,s1,1
    27ea:	0405                	addi	s0,s0,1
    27ec:	9a02                	jalr	s4
    27ee:	ff34e8e3          	bltu	s1,s3,27de <_vsnprintf+0x11be>
    27f2:	6da2                	ld	s11,8(sp)
    27f4:	84a2                	mv	s1,s0
    27f6:	e85fe06f          	j	167a <_vsnprintf+0x5a>
    27fa:	00d10433          	add	s0,sp,a3
    27fe:	01b407b3          	add	a5,s0,s11
    2802:	0d85                	addi	s11,s11,1
    2804:	03000513          	li	a0,48
    2808:	00a78023          	sb	a0,0(a5)
    280c:	e709                	bnez	a4,2816 <_vsnprintf+0x11f6>
    280e:	7c09b40b          	th.extu	s0,s3,31,0
    2812:	f28dede3          	bltu	s11,s0,274c <_vsnprintf+0x112c>
    2816:	87a6                	mv	a5,s1
    2818:	b769                	j	27a2 <_vsnprintf+0x1182>
    281a:	40000413          	li	s0,1024
    281e:	d537e9e3          	bltu	a5,s3,2570 <_vsnprintf+0xf50>
    2822:	a6050563          	beqz	a0,1a8c <_vsnprintf+0x46c>
    2826:	2785                	addiw	a5,a5,1
    2828:	8da6                	mv	s11,s1
    282a:	4401                	li	s0,0
    282c:	d38ff06f          	j	1d64 <_vsnprintf+0x744>
    2830:	10070b63          	beqz	a4,2946 <_vsnprintf+0x1326>
    2834:	10058963          	beqz	a1,2946 <_vsnprintf+0x1326>
    2838:	377d                	addiw	a4,a4,-1
    283a:	01337563          	bgeu	t1,s3,2844 <_vsnprintf+0x1224>
    283e:	44088c63          	beqz	a7,2c96 <_vsnprintf+0x1676>
    2842:	4889                	li	a7,2
    2844:	4781                	li	a5,0
    2846:	b68d                	j	23a8 <_vsnprintf+0xd88>
    2848:	000db303          	ld	t1,0(s11)
    284c:	44030963          	beqz	t1,2c9e <_vsnprintf+0x167e>
    2850:	43f35793          	srai	a5,t1,0x3f
    2854:	0067c6b3          	xor	a3,a5,t1
    2858:	8e9d                	sub	a3,a3,a5
    285a:	4781                	li	a5,0
    285c:	1000                	addi	s0,sp,32
    285e:	45a9                	li	a1,10
    2860:	4e25                	li	t3,9
    2862:	02000e93          	li	t4,32
    2866:	a019                	j	286c <_vsnprintf+0x124c>
    2868:	11d783e3          	beq	a5,t4,316e <_vsnprintf+0x1b4e>
    286c:	02b6f633          	remu	a2,a3,a1
    2870:	8d3e                	mv	s10,a5
    2872:	0785                	addi	a5,a5,1
    2874:	00f40f33          	add	t5,s0,a5
    2878:	8536                	mv	a0,a3
    287a:	0306061b          	addiw	a2,a2,48
    287e:	fecf0fa3          	sb	a2,-1(t5)
    2882:	02b6d6b3          	divu	a3,a3,a1
    2886:	feae61e3          	bltu	t3,a0,2868 <_vsnprintf+0x1248>
    288a:	0028f613          	andi	a2,a7,2
    288e:	86c6                	mv	a3,a7
    2890:	280601e3          	beqz	a2,3312 <_vsnprintf+0x1cf2>
    2894:	02000513          	li	a0,32
    2898:	1ca782e3          	beq	a5,a0,325c <_vsnprintf+0x1c3c>
    289c:	00034463          	bltz	t1,28a4 <_vsnprintf+0x1284>
    28a0:	2440106f          	j	3ae4 <_vsnprintf+0x24c4>
    28a4:	02d00713          	li	a4,45
    28a8:	978a                	add	a5,a5,sp
    28aa:	02e78023          	sb	a4,32(a5)
    28ae:	0d09                	addi	s10,s10,2
    28b0:	4709                	li	a4,2
    28b2:	8426                	mv	s0,s1
    28b4:	02d00513          	li	a0,45
    28b8:	008d0db3          	add	s11,s10,s0
    28bc:	87ee                	mv	a5,s11
    28be:	e426                	sd	s1,8(sp)
    28c0:	e83a                	sd	a4,16(sp)
    28c2:	8dca                	mv	s11,s2
    28c4:	84ea                	mv	s1,s10
    28c6:	893e                	mv	s2,a5
    28c8:	8d42                	mv	s10,a6
    28ca:	a029                	j	28d4 <_vsnprintf+0x12b4>
    28cc:	002486b3          	add	a3,s1,sp
    28d0:	01f6c503          	lbu	a0,31(a3)
    28d4:	40990633          	sub	a2,s2,s1
    28d8:	86d6                	mv	a3,s5
    28da:	14fd                	addi	s1,s1,-1
    28dc:	85da                	mv	a1,s6
    28de:	844a                	mv	s0,s2
    28e0:	9a02                	jalr	s4
    28e2:	f4ed                	bnez	s1,28cc <_vsnprintf+0x12ac>
    28e4:	64a2                	ld	s1,8(sp)
    28e6:	6742                	ld	a4,16(sp)
    28e8:	886a                	mv	a6,s10
    28ea:	896e                	mv	s2,s11
    28ec:	aa0705e3          	beqz	a4,2396 <_vsnprintf+0xd76>
    28f0:	409404b3          	sub	s1,s0,s1
    28f4:	7c09b98b          	th.extu	s3,s3,31,0
    28f8:	a934ffe3          	bgeu	s1,s3,2396 <_vsnprintf+0xd76>
    28fc:	8d42                	mv	s10,a6
    28fe:	8622                	mv	a2,s0
    2900:	86d6                	mv	a3,s5
    2902:	85da                	mv	a1,s6
    2904:	02000513          	li	a0,32
    2908:	0485                	addi	s1,s1,1
    290a:	0405                	addi	s0,s0,1
    290c:	9a02                	jalr	s4
    290e:	ff34e8e3          	bltu	s1,s3,28fe <_vsnprintf+0x12de>
    2912:	886a                	mv	a6,s10
    2914:	b449                	j	2396 <_vsnprintf+0xd76>
    2916:	fef47893          	andi	a7,s0,-17
    291a:	06900793          	li	a5,105
    291e:	2881                	sext.w	a7,a7
    2920:	86a2                	mv	a3,s0
    2922:	78f51763          	bne	a0,a5,30b0 <_vsnprintf+0x1a90>
    2926:	40047793          	andi	a5,s0,1024
    292a:	98079fe3          	bnez	a5,22c8 <_vsnprintf+0xca8>
    292e:	2006f693          	andi	a3,a3,512
    2932:	008d8813          	addi	a6,s11,8
    2936:	9a0684e3          	beqz	a3,22de <_vsnprintf+0xcbe>
    293a:	ebeff06f          	j	1ff8 <_vsnprintf+0x9d8>
    293e:	6da2                	ld	s11,8(sp)
    2940:	84be                	mv	s1,a5
    2942:	d39fe06f          	j	167a <_vsnprintf+0x5a>
    2946:	ef337fe3          	bgeu	t1,s3,2844 <_vsnprintf+0x1224>
    294a:	34088663          	beqz	a7,2c96 <_vsnprintf+0x1676>
    294e:	4781                	li	a5,0
    2950:	4889                	li	a7,2
    2952:	bc99                	j	23a8 <_vsnprintf+0xd88>
    2954:	000dbe83          	ld	t4,0(s11)
    2958:	8dc2                	mv	s11,a6
    295a:	ea0e9563          	bnez	t4,2004 <_vsnprintf+0x9e4>
    295e:	0028f693          	andi	a3,a7,2
    2962:	87c6                	mv	a5,a7
    2964:	2e0692e3          	bnez	a3,3448 <_vsnprintf+0x1e28>
    2968:	7c07370b          	th.extu	a4,a4,31,0
    296c:	4781                	li	a5,0
    296e:	4e81                	li	t4,0
    2970:	280996e3          	bnez	s3,33fc <_vsnprintf+0x1ddc>
    2974:	e319                	bnez	a4,297a <_vsnprintf+0x135a>
    2976:	14c0106f          	j	3ac2 <_vsnprintf+0x24a2>
    297a:	0018f613          	andi	a2,a7,1
    297e:	4981                	li	s3,0
    2980:	02000593          	li	a1,32
    2984:	00b10833          	add	a6,sp,a1
    2988:	03000513          	li	a0,48
    298c:	00000013          	nop
    2990:	70b78363          	beq	a5,a1,3096 <_vsnprintf+0x1a76>
    2994:	0785                	addi	a5,a5,1
    2996:	00f806b3          	add	a3,a6,a5
    299a:	fea68fa3          	sb	a0,-1(a3)
    299e:	fee7e9e3          	bltu	a5,a4,2990 <_vsnprintf+0x1370>
    29a2:	3e0600e3          	beqz	a2,3582 <_vsnprintf+0x1f62>
    29a6:	7c09b70b          	th.extu	a4,s3,31,0
    29aa:	00e7e463          	bltu	a5,a4,29b2 <_vsnprintf+0x1392>
    29ae:	3d20106f          	j	3d80 <_vsnprintf+0x2760>
    29b2:	02000613          	li	a2,32
    29b6:	00c10533          	add	a0,sp,a2
    29ba:	03000593          	li	a1,48
    29be:	0001                	nop
    29c0:	0ac78363          	beq	a5,a2,2a66 <_vsnprintf+0x1446>
    29c4:	0785                	addi	a5,a5,1
    29c6:	00f506b3          	add	a3,a0,a5
    29ca:	feb68fa3          	sb	a1,-1(a3)
    29ce:	fee799e3          	bne	a5,a4,29c0 <_vsnprintf+0x13a0>
    29d2:	0038f693          	andi	a3,a7,3
    29d6:	02000793          	li	a5,32
    29da:	8636                	mv	a2,a3
    29dc:	08f70763          	beq	a4,a5,2a6a <_vsnprintf+0x144a>
    29e0:	7e0ecb63          	bltz	t4,31d6 <_vsnprintf+0x1bb6>
    29e4:	0048f793          	andi	a5,a7,4
    29e8:	2681                	sext.w	a3,a3
    29ea:	76078be3          	beqz	a5,3960 <_vsnprintf+0x2340>
    29ee:	002707b3          	add	a5,a4,sp
    29f2:	02b00513          	li	a0,43
    29f6:	02a78023          	sb	a0,32(a5)
    29fa:	0705                	addi	a4,a4,1
    29fc:	c299                	beqz	a3,2a02 <_vsnprintf+0x13e2>
    29fe:	2e40106f          	j	3ce2 <_vsnprintf+0x26c2>
    2a02:	7c09b40b          	th.extu	s0,s3,31,0
    2a06:	6e877de3          	bgeu	a4,s0,3900 <_vsnprintf+0x22e0>
    2a0a:	409707b3          	sub	a5,a4,s1
    2a0e:	fae1568b          	th.sdd	a3,a4,(sp),1,4
    2a12:	874a                	mv	a4,s2
    2a14:	e426                	sd	s1,8(sp)
    2a16:	8926                	mv	s2,s1
    2a18:	8d3a                	mv	s10,a4
    2a1a:	84be                	mv	s1,a5
    2a1c:	00000013          	nop
    2a20:	864a                	mv	a2,s2
    2a22:	86d6                	mv	a3,s5
    2a24:	85da                	mv	a1,s6
    2a26:	02000513          	li	a0,32
    2a2a:	0905                	addi	s2,s2,1
    2a2c:	9a02                	jalr	s4
    2a2e:	01248733          	add	a4,s1,s2
    2a32:	fe8767e3          	bltu	a4,s0,2a20 <_vsnprintf+0x1400>
    2a36:	fae1468b          	th.ldd	a3,a4,(sp),1,4
    2a3a:	64a2                	ld	s1,8(sp)
    2a3c:	fff40793          	addi	a5,s0,-1
    2a40:	00170613          	addi	a2,a4,1
    2a44:	00c435b3          	sltu	a1,s0,a2
    2a48:	8f99                	sub	a5,a5,a4
    2a4a:	42b0178b          	th.mvnez	a5,zero,a1
    2a4e:	00148613          	addi	a2,s1,1
    2a52:	896a                	mv	s2,s10
    2a54:	97b2                	add	a5,a5,a2
    2a56:	32070ee3          	beqz	a4,3592 <_vsnprintf+0x1f72>
    2a5a:	00270633          	add	a2,a4,sp
    2a5e:	01f64503          	lbu	a0,31(a2)
    2a62:	e16ff06f          	j	2078 <_vsnprintf+0xa58>
    2a66:	0038f613          	andi	a2,a7,3
    2a6a:	ea01                	bnez	a2,2a7a <_vsnprintf+0x145a>
    2a6c:	02000713          	li	a4,32
    2a70:	7c09b40b          	th.extu	s0,s3,31,0
    2a74:	4681                	li	a3,0
    2a76:	f9376ae3          	bltu	a4,s3,2a0a <_vsnprintf+0x13ea>
    2a7a:	03f14503          	lbu	a0,63(sp)
    2a7e:	87a6                	mv	a5,s1
    2a80:	4681                	li	a3,0
    2a82:	02000713          	li	a4,32
    2a86:	df2ff06f          	j	2078 <_vsnprintf+0xa58>
    2a8a:	000db503          	ld	a0,0(s11)
    2a8e:	52051963          	bnez	a0,2fc0 <_vsnprintf+0x19a0>
    2a92:	fefe7613          	andi	a2,t3,-17
    2a96:	2601                	sext.w	a2,a2
    2a98:	0e0815e3          	bnez	a6,3382 <_vsnprintf+0x1d62>
    2a9c:	4281                	li	t0,0
    2a9e:	1456358b          	th.extu	a1,a2,5,5
    2aa2:	06100793          	li	a5,97
    2aa6:	c199                	beqz	a1,2aac <_vsnprintf+0x148c>
    2aa8:	04100793          	li	a5,65
    2aac:	ff678e9b          	addiw	t4,a5,-10
    2ab0:	4301                	li	t1,0
    2ab2:	1000                	addi	s0,sp,32
    2ab4:	4fa5                	li	t6,9
    2ab6:	02000f13          	li	t5,32
    2aba:	a029                	j	2ac4 <_vsnprintf+0x14a4>
    2abc:	11ed88e3          	beq	s11,t5,33cc <_vsnprintf+0x1dac>
    2ac0:	836e                	mv	t1,s11
    2ac2:	8572                	mv	a0,t3
    2ac4:	02d55e33          	divu	t3,a0,a3
    2ac8:	85aa                	mv	a1,a0
    2aca:	00130d93          	addi	s11,t1,1
    2ace:	22de158b          	th.muls	a1,t3,a3
    2ad2:	0ff5f793          	zext.b	a5,a1
    2ad6:	0307839b          	addiw	t2,a5,48
    2ada:	00fe87bb          	addw	a5,t4,a5
    2ade:	00bfb5b3          	sltu	a1,t6,a1
    2ae2:	0ff3f393          	zext.b	t2,t2
    2ae6:	0ff7f793          	zext.b	a5,a5
    2aea:	40b3978b          	th.mveqz	a5,t2,a1
    2aee:	0064578b          	th.srb	a5,s0,t1,0
    2af2:	fcd575e3          	bgeu	a0,a3,2abc <_vsnprintf+0x149c>
    2af6:	00267693          	andi	a3,a2,2
    2afa:	87b2                	mv	a5,a2
    2afc:	60068663          	beqz	a3,3108 <_vsnprintf+0x1ae8>
    2b00:	4c0285e3          	beqz	t0,37ca <_vsnprintf+0x21aa>
    2b04:	700810e3          	bnez	a6,3a04 <_vsnprintf+0x23e4>
    2b08:	7c07370b          	th.extu	a4,a4,31,0
    2b0c:	4809                	li	a6,2
    2b0e:	6bb70be3          	beq	a4,s11,39c4 <_vsnprintf+0x23a4>
    2b12:	7c09b78b          	th.extu	a5,s3,31,0
    2b16:	6bb787e3          	beq	a5,s11,39c4 <_vsnprintf+0x23a4>
    2b1a:	00367713          	andi	a4,a2,3
    2b1e:	46c1                	li	a3,16
    2b20:	87ba                	mv	a5,a4
    2b22:	68d884e3          	beq	a7,a3,39aa <_vsnprintf+0x238a>
    2b26:	4689                	li	a3,2
    2b28:	52d88de3          	beq	a7,a3,3862 <_vsnprintf+0x2242>
    2b2c:	02000693          	li	a3,32
    2b30:	0007079b          	sext.w	a5,a4
    2b34:	70dd96e3          	bne	s11,a3,3a40 <_vsnprintf+0x2420>
    2b38:	6a079fe3          	bnez	a5,39f6 <_vsnprintf+0x23d6>
    2b3c:	02000d93          	li	s11,32
    2b40:	7c09b40b          	th.extu	s0,s3,31,0
    2b44:	013de463          	bltu	s11,s3,2b4c <_vsnprintf+0x152c>
    2b48:	7f50006f          	j	3b3c <_vsnprintf+0x251c>
    2b4c:	409d87b3          	sub	a5,s11,s1
    2b50:	8d4a                	mv	s10,s2
    2b52:	fb01548b          	th.sdd	s1,a6,(sp),1,4
    2b56:	893e                	mv	s2,a5
    2b58:	8626                	mv	a2,s1
    2b5a:	86d6                	mv	a3,s5
    2b5c:	85da                	mv	a1,s6
    2b5e:	02000513          	li	a0,32
    2b62:	0485                	addi	s1,s1,1
    2b64:	9a02                	jalr	s4
    2b66:	00990733          	add	a4,s2,s1
    2b6a:	fe8767e3          	bltu	a4,s0,2b58 <_vsnprintf+0x1538>
    2b6e:	fb01448b          	th.ldd	s1,a6,(sp),1,4
    2b72:	fff40793          	addi	a5,s0,-1
    2b76:	001d8693          	addi	a3,s11,1
    2b7a:	00d43733          	sltu	a4,s0,a3
    2b7e:	41b787b3          	sub	a5,a5,s11
    2b82:	42e0178b          	th.mvnez	a5,zero,a4
    2b86:	00148713          	addi	a4,s1,1
    2b8a:	896a                	mv	s2,s10
    2b8c:	97ba                	add	a5,a5,a4
    2b8e:	5a0d8ae3          	beqz	s11,3942 <_vsnprintf+0x2322>
    2b92:	002d8733          	add	a4,s11,sp
    2b96:	01f74503          	lbu	a0,31(a4)
    2b9a:	8d6e                	mv	s10,s11
    2b9c:	9dbe                	add	s11,s11,a5
    2b9e:	e826                	sd	s1,16(sp)
    2ba0:	84ee                	mv	s1,s11
    2ba2:	8dca                	mv	s11,s2
    2ba4:	8942                	mv	s2,a6
    2ba6:	a029                	j	2bb0 <_vsnprintf+0x1590>
    2ba8:	002d0733          	add	a4,s10,sp
    2bac:	01f74503          	lbu	a0,31(a4)
    2bb0:	41a48633          	sub	a2,s1,s10
    2bb4:	86d6                	mv	a3,s5
    2bb6:	1d7d                	addi	s10,s10,-1
    2bb8:	85da                	mv	a1,s6
    2bba:	8426                	mv	s0,s1
    2bbc:	9a02                	jalr	s4
    2bbe:	fe0d15e3          	bnez	s10,2ba8 <_vsnprintf+0x1588>
    2bc2:	64c2                	ld	s1,16(sp)
    2bc4:	884a                	mv	a6,s2
    2bc6:	896e                	mv	s2,s11
    2bc8:	02080263          	beqz	a6,2bec <_vsnprintf+0x15cc>
    2bcc:	409404b3          	sub	s1,s0,s1
    2bd0:	7c09b98b          	th.extu	s3,s3,31,0
    2bd4:	0134fc63          	bgeu	s1,s3,2bec <_vsnprintf+0x15cc>
    2bd8:	8622                	mv	a2,s0
    2bda:	86d6                	mv	a3,s5
    2bdc:	85da                	mv	a1,s6
    2bde:	02000513          	li	a0,32
    2be2:	0485                	addi	s1,s1,1
    2be4:	0405                	addi	s0,s0,1
    2be6:	9a02                	jalr	s4
    2be8:	ff34e8e3          	bltu	s1,s3,2bd8 <_vsnprintf+0x15b8>
    2bec:	6da2                	ld	s11,8(sp)
    2bee:	84a2                	mv	s1,s0
    2bf0:	a8bfe06f          	j	167a <_vsnprintf+0x5a>
    2bf4:	01067e13          	andi	t3,a2,16
    2bf8:	8f32                	mv	t5,a2
    2bfa:	a18ff06f          	j	1e12 <_vsnprintf+0x7f2>
    2bfe:	6da2                	ld	s11,8(sp)
    2c00:	84c2                	mv	s1,a6
    2c02:	a79fe06f          	j	167a <_vsnprintf+0x5a>
    2c06:	03f14503          	lbu	a0,63(sp)
    2c0a:	02000793          	li	a5,32
    2c0e:	b0ad                	j	2478 <_vsnprintf+0xe58>
    2c10:	02000793          	li	a5,32
    2c14:	fef689e3          	beq	a3,a5,2c06 <_vsnprintf+0x15e6>
    2c18:	8636                	mv	a2,a3
    2c1a:	b0b9                	j	2468 <_vsnprintf+0xe48>
    2c1c:	010e7593          	andi	a1,t3,16
    2c20:	b4b5                	j	268c <_vsnprintf+0x106c>
    2c22:	7c07370b          	th.extu	a4,a4,31,0
    2c26:	02edf263          	bgeu	s11,a4,2c4a <_vsnprintf+0x162a>
    2c2a:	02000593          	li	a1,32
    2c2e:	00b10633          	add	a2,sp,a1
    2c32:	03000693          	li	a3,48
    2c36:	0001                	nop
    2c38:	00bd8963          	beq	s11,a1,2c4a <_vsnprintf+0x162a>
    2c3c:	0d85                	addi	s11,s11,1
    2c3e:	01b607b3          	add	a5,a2,s11
    2c42:	fed78fa3          	sb	a3,-1(a5)
    2c46:	ffb719e3          	bne	a4,s11,2c38 <_vsnprintf+0x1618>
    2c4a:	001f7793          	andi	a5,t5,1
    2c4e:	54078063          	beqz	a5,318e <_vsnprintf+0x1b6e>
    2c52:	7c09b68b          	th.extu	a3,s3,31,0
    2c56:	00dde463          	bltu	s11,a3,2c5e <_vsnprintf+0x163e>
    2c5a:	2160106f          	j	3e70 <_vsnprintf+0x2850>
    2c5e:	02000513          	li	a0,32
    2c62:	00a105b3          	add	a1,sp,a0
    2c66:	03000613          	li	a2,48
    2c6a:	0001                	nop
    2c6c:	00000013          	nop
    2c70:	00ad8963          	beq	s11,a0,2c82 <_vsnprintf+0x1662>
    2c74:	0d85                	addi	s11,s11,1
    2c76:	01b587b3          	add	a5,a1,s11
    2c7a:	fec78fa3          	sb	a2,-1(a5)
    2c7e:	fedd99e3          	bne	s11,a3,2c70 <_vsnprintf+0x1650>
    2c82:	640e1763          	bnez	t3,32d0 <_vsnprintf+0x1cb0>
    2c86:	002d87b3          	add	a5,s11,sp
    2c8a:	01f7c503          	lbu	a0,31(a5)
    2c8e:	4e01                	li	t3,0
    2c90:	87a6                	mv	a5,s1
    2c92:	aa8ff06f          	j	1f3a <_vsnprintf+0x91a>
    2c96:	406987bb          	subw	a5,s3,t1
    2c9a:	f0eff06f          	j	23a8 <_vsnprintf+0xd88>
    2c9e:	6c068f63          	beqz	a3,337c <_vsnprintf+0x1d5c>
    2ca2:	0027f693          	andi	a3,a5,2
    2ca6:	0a069fe3          	bnez	a3,3564 <_vsnprintf+0x1f44>
    2caa:	7c07370b          	th.extu	a4,a4,31,0
    2cae:	460987e3          	beqz	s3,391c <_vsnprintf+0x22fc>
    2cb2:	8b85                	andi	a5,a5,1
    2cb4:	080784e3          	beqz	a5,353c <_vsnprintf+0x1f1c>
    2cb8:	4781                	li	a5,0
    2cba:	fff9861b          	addiw	a2,s3,-1
    2cbe:	00c8f693          	andi	a3,a7,12
    2cc2:	42d6198b          	th.mvnez	s3,a2,a3
    2cc6:	4605                	li	a2,1
    2cc8:	00e7e463          	bltu	a5,a4,2cd0 <_vsnprintf+0x16b0>
    2ccc:	0680106f          	j	3d34 <_vsnprintf+0x2714>
    2cd0:	02000593          	li	a1,32
    2cd4:	00b10e33          	add	t3,sp,a1
    2cd8:	03000513          	li	a0,48
    2cdc:	68b78863          	beq	a5,a1,336c <_vsnprintf+0x1d4c>
    2ce0:	0785                	addi	a5,a5,1
    2ce2:	00fe06b3          	add	a3,t3,a5
    2ce6:	fea68fa3          	sb	a0,-1(a3)
    2cea:	fee7e9e3          	bltu	a5,a4,2cdc <_vsnprintf+0x16bc>
    2cee:	c615                	beqz	a2,2d1a <_vsnprintf+0x16fa>
    2cf0:	7c09b70b          	th.extu	a4,s3,31,0
    2cf4:	00e7e463          	bltu	a5,a4,2cfc <_vsnprintf+0x16dc>
    2cf8:	0580106f          	j	3d50 <_vsnprintf+0x2730>
    2cfc:	02000513          	li	a0,32
    2d00:	00a105b3          	add	a1,sp,a0
    2d04:	03000613          	li	a2,48
    2d08:	0aa78763          	beq	a5,a0,2db6 <_vsnprintf+0x1796>
    2d0c:	0785                	addi	a5,a5,1
    2d0e:	00f586b3          	add	a3,a1,a5
    2d12:	fec68fa3          	sb	a2,-1(a3)
    2d16:	fee799e3          	bne	a5,a4,2d08 <_vsnprintf+0x16e8>
    2d1a:	0038f693          	andi	a3,a7,3
    2d1e:	02000713          	li	a4,32
    2d22:	8636                	mv	a2,a3
    2d24:	08e78b63          	beq	a5,a4,2dba <_vsnprintf+0x179a>
    2d28:	7c034563          	bltz	t1,34f2 <_vsnprintf+0x1ed2>
    2d2c:	0048f613          	andi	a2,a7,4
    2d30:	0006871b          	sext.w	a4,a3
    2d34:	e219                	bnez	a2,2d3a <_vsnprintf+0x171a>
    2d36:	0d80106f          	j	3e0e <_vsnprintf+0x27ee>
    2d3a:	1010                	addi	a2,sp,32
    2d3c:	02078693          	addi	a3,a5,32
    2d40:	96b2                	add	a3,a3,a2
    2d42:	02b00613          	li	a2,43
    2d46:	fec68023          	sb	a2,-32(a3)
    2d4a:	00178d13          	addi	s10,a5,1
    2d4e:	c319                	beqz	a4,2d54 <_vsnprintf+0x1734>
    2d50:	0540106f          	j	3da4 <_vsnprintf+0x2784>
    2d54:	7c09b68b          	th.extu	a3,s3,31,0
    2d58:	02dd70e3          	bgeu	s10,a3,3578 <_vsnprintf+0x1f58>
    2d5c:	409d0433          	sub	s0,s10,s1
    2d60:	87ca                	mv	a5,s2
    2d62:	e426                	sd	s1,8(sp)
    2d64:	8926                	mv	s2,s1
    2d66:	8dbe                	mv	s11,a5
    2d68:	84a2                	mv	s1,s0
    2d6a:	fb01570b          	th.sdd	a4,a6,(sp),1,4
    2d6e:	8436                	mv	s0,a3
    2d70:	864a                	mv	a2,s2
    2d72:	86d6                	mv	a3,s5
    2d74:	85da                	mv	a1,s6
    2d76:	02000513          	li	a0,32
    2d7a:	0905                	addi	s2,s2,1
    2d7c:	9a02                	jalr	s4
    2d7e:	01248733          	add	a4,s1,s2
    2d82:	fe8767e3          	bltu	a4,s0,2d70 <_vsnprintf+0x1750>
    2d86:	64a2                	ld	s1,8(sp)
    2d88:	86a2                	mv	a3,s0
    2d8a:	001d0793          	addi	a5,s10,1
    2d8e:	147d                	addi	s0,s0,-1
    2d90:	00f6b6b3          	sltu	a3,a3,a5
    2d94:	41a40433          	sub	s0,s0,s10
    2d98:	fb01470b          	th.ldd	a4,a6,(sp),1,4
    2d9c:	42d0140b          	th.mvnez	s0,zero,a3
    2da0:	00148793          	addi	a5,s1,1
    2da4:	896e                	mv	s2,s11
    2da6:	943e                	add	s0,s0,a5
    2da8:	b40d02e3          	beqz	s10,28ec <_vsnprintf+0x12cc>
    2dac:	002d07b3          	add	a5,s10,sp
    2db0:	01f7c503          	lbu	a0,31(a5)
    2db4:	b611                	j	28b8 <_vsnprintf+0x1298>
    2db6:	0038f613          	andi	a2,a7,3
    2dba:	ea01                	bnez	a2,2dca <_vsnprintf+0x17aa>
    2dbc:	02000d13          	li	s10,32
    2dc0:	7c09b68b          	th.extu	a3,s3,31,0
    2dc4:	4701                	li	a4,0
    2dc6:	f93d6be3          	bltu	s10,s3,2d5c <_vsnprintf+0x173c>
    2dca:	03f14503          	lbu	a0,63(sp)
    2dce:	8426                	mv	s0,s1
    2dd0:	4701                	li	a4,0
    2dd2:	02000d13          	li	s10,32
    2dd6:	b4cd                	j	28b8 <_vsnprintf+0x1298>
    2dd8:	700709e3          	beqz	a4,3cea <_vsnprintf+0x26ca>
    2ddc:	4541                	li	a0,16
    2dde:	86aa                	mv	a3,a0
    2de0:	4781                	li	a5,0
    2de2:	40000e13          	li	t3,1024
    2de6:	f02ff06f          	j	24e8 <_vsnprintf+0xec8>
    2dea:	41fe579b          	sraiw	a5,t3,0x1f
    2dee:	00fe4633          	xor	a2,t3,a5
    2df2:	9e1d                	subw	a2,a2,a5
    2df4:	d1aff06f          	j	230e <_vsnprintf+0xcee>
    2df8:	1000                	addi	s0,sp,32
    2dfa:	943e                	add	s0,s0,a5
    2dfc:	00178d13          	addi	s10,a5,1
    2e00:	02000513          	li	a0,32
    2e04:	00a40023          	sb	a0,0(s0)
    2e08:	c24ff06f          	j	222c <_vsnprintf+0xc0c>
    2e0c:	8d32                	mv	s10,a2
    2e0e:	1000                	addi	s0,sp,32
    2e10:	46c1                	li	a3,16
    2e12:	4809                	li	a6,2
    2e14:	caaff06f          	j	22be <_vsnprintf+0xc9e>
    2e18:	03f14503          	lbu	a0,63(sp)
    2e1c:	8426                	mv	s0,s1
    2e1e:	4589                	li	a1,2
    2e20:	02000713          	li	a4,32
    2e24:	d14ff06f          	j	2338 <_vsnprintf+0xd18>
    2e28:	0028f693          	andi	a3,a7,2
    2e2c:	8646                	mv	a2,a7
    2e2e:	f6ed                	bnez	a3,2e18 <_vsnprintf+0x17f8>
    2e30:	7c07370b          	th.extu	a4,a4,31,0
    2e34:	16099263          	bnez	s3,2f98 <_vsnprintf+0x1978>
    2e38:	00367993          	andi	s3,a2,3
    2e3c:	14e7f463          	bgeu	a5,a4,2f84 <_vsnprintf+0x1964>
    2e40:	0018f513          	andi	a0,a7,1
    2e44:	4981                	li	s3,0
    2e46:	02000613          	li	a2,32
    2e4a:	00c10eb3          	add	t4,sp,a2
    2e4e:	03000313          	li	t1,48
    2e52:	0001                	nop
    2e54:	00000013          	nop
    2e58:	12c78a63          	beq	a5,a2,2f8c <_vsnprintf+0x196c>
    2e5c:	0785                	addi	a5,a5,1
    2e5e:	00fe86b3          	add	a3,t4,a5
    2e62:	fe668fa3          	sb	t1,-1(a3)
    2e66:	fee7e9e3          	bltu	a5,a4,2e58 <_vsnprintf+0x1838>
    2e6a:	66050263          	beqz	a0,34ce <_vsnprintf+0x1eae>
    2e6e:	7c09b70b          	th.extu	a4,s3,31,0
    2e72:	48e7f7e3          	bgeu	a5,a4,3b00 <_vsnprintf+0x24e0>
    2e76:	02000613          	li	a2,32
    2e7a:	00c10333          	add	t1,sp,a2
    2e7e:	03000513          	li	a0,48
    2e82:	0001                	nop
    2e84:	00000013          	nop
    2e88:	08c78c63          	beq	a5,a2,2f20 <_vsnprintf+0x1900>
    2e8c:	0785                	addi	a5,a5,1
    2e8e:	00f306b3          	add	a3,t1,a5
    2e92:	fea68fa3          	sb	a0,-1(a3)
    2e96:	fee799e3          	bne	a5,a4,2e88 <_vsnprintf+0x1868>
    2e9a:	0038f693          	andi	a3,a7,3
    2e9e:	02000793          	li	a5,32
    2ea2:	8536                	mv	a0,a3
    2ea4:	08f70063          	beq	a4,a5,2f24 <_vsnprintf+0x1904>
    2ea8:	3e0e5d63          	bgez	t3,32a2 <_vsnprintf+0x1c82>
    2eac:	002707b3          	add	a5,a4,sp
    2eb0:	02d00693          	li	a3,45
    2eb4:	02d78023          	sb	a3,32(a5)
    2eb8:	0705                	addi	a4,a4,1
    2eba:	fa051b63          	bnez	a0,2670 <_vsnprintf+0x1050>
    2ebe:	7c09bd8b          	th.extu	s11,s3,31,0
    2ec2:	fbb77763          	bgeu	a4,s11,2670 <_vsnprintf+0x1050>
    2ec6:	8d4a                	mv	s10,s2
    2ec8:	40970433          	sub	s0,a4,s1
    2ecc:	e43a                	sd	a4,8(sp)
    2ece:	fb01548b          	th.sdd	s1,a6,(sp),1,4
    2ed2:	892e                	mv	s2,a1
    2ed4:	00000013          	nop
    2ed8:	8626                	mv	a2,s1
    2eda:	86d6                	mv	a3,s5
    2edc:	85da                	mv	a1,s6
    2ede:	02000513          	li	a0,32
    2ee2:	0485                	addi	s1,s1,1
    2ee4:	9a02                	jalr	s4
    2ee6:	00940733          	add	a4,s0,s1
    2eea:	ffb767e3          	bltu	a4,s11,2ed8 <_vsnprintf+0x18b8>
    2eee:	6722                	ld	a4,8(sp)
    2ef0:	fb01448b          	th.ldd	s1,a6,(sp),1,4
    2ef4:	fffd8413          	addi	s0,s11,-1
    2ef8:	00170793          	addi	a5,a4,1
    2efc:	00fdbdb3          	sltu	s11,s11,a5
    2f00:	8c19                	sub	s0,s0,a4
    2f02:	43b0140b          	th.mvnez	s0,zero,s11
    2f06:	00148793          	addi	a5,s1,1
    2f0a:	85ca                	mv	a1,s2
    2f0c:	943e                	add	s0,s0,a5
    2f0e:	896a                	mv	s2,s10
    2f10:	c4070e63          	beqz	a4,236c <_vsnprintf+0xd4c>
    2f14:	002707b3          	add	a5,a4,sp
    2f18:	01f7c503          	lbu	a0,31(a5)
    2f1c:	c1cff06f          	j	2338 <_vsnprintf+0xd18>
    2f20:	0038f513          	andi	a0,a7,3
    2f24:	e519                	bnez	a0,2f32 <_vsnprintf+0x1912>
    2f26:	02000713          	li	a4,32
    2f2a:	7c09bd8b          	th.extu	s11,s3,31,0
    2f2e:	f9376ce3          	bltu	a4,s3,2ec6 <_vsnprintf+0x18a6>
    2f32:	03f14503          	lbu	a0,63(sp)
    2f36:	8426                	mv	s0,s1
    2f38:	02000713          	li	a4,32
    2f3c:	bfcff06f          	j	2338 <_vsnprintf+0xd18>
    2f40:	4541                	li	a0,16
    2f42:	86aa                	mv	a3,a0
    2f44:	daeee263          	bltu	t4,a4,24e8 <_vsnprintf+0xec8>
    2f48:	4d7d                	li	s10,31
    2f4a:	ac080963          	beqz	a6,221c <_vsnprintf+0xbfc>
    2f4e:	520e1d63          	bnez	t3,3488 <_vsnprintf+0x1e68>
    2f52:	7c07370b          	th.extu	a4,a4,31,0
    2f56:	9af71f63          	bne	a4,a5,2114 <_vsnprintf+0xaf4>
    2f5a:	05800613          	li	a2,88
    2f5e:	00278733          	add	a4,a5,sp
    2f62:	8872                	mv	a6,t3
    2f64:	00c70f23          	sb	a2,30(a4)
    2f68:	9d8ff06f          	j	2140 <_vsnprintf+0xb20>
    2f6c:	7c07370b          	th.extu	a4,a4,31,0
    2f70:	02099463          	bnez	s3,2f98 <_vsnprintf+0x1978>
    2f74:	ece7e6e3          	bltu	a5,a4,2e40 <_vsnprintf+0x1820>
    2f78:	02000713          	li	a4,32
    2f7c:	00367993          	andi	s3,a2,3
    2f80:	4ee796e3          	bne	a5,a4,3c6c <_vsnprintf+0x264c>
    2f84:	fa0987e3          	beqz	s3,2f32 <_vsnprintf+0x1912>
    2f88:	4981                	li	s3,0
    2f8a:	b765                	j	2f32 <_vsnprintf+0x1912>
    2f8c:	d951                	beqz	a0,2f20 <_vsnprintf+0x1900>
    2f8e:	7c09b70b          	th.extu	a4,s3,31,0
    2f92:	eee7e2e3          	bltu	a5,a4,2e76 <_vsnprintf+0x1856>
    2f96:	bf71                	j	2f32 <_vsnprintf+0x1912>
    2f98:	0018f513          	andi	a0,a7,1
    2f9c:	3a050463          	beqz	a0,3344 <_vsnprintf+0x1d24>
    2fa0:	2c0e5d63          	bgez	t3,327a <_vsnprintf+0x1c5a>
    2fa4:	39fd                	addiw	s3,s3,-1
    2fa6:	eae7e0e3          	bltu	a5,a4,2e46 <_vsnprintf+0x1826>
    2faa:	7c09b70b          	th.extu	a4,s3,31,0
    2fae:	ece7e4e3          	bltu	a5,a4,2e76 <_vsnprintf+0x1856>
    2fb2:	02000713          	li	a4,32
    2fb6:	f6e78ee3          	beq	a5,a4,2f32 <_vsnprintf+0x1912>
    2fba:	873e                	mv	a4,a5
    2fbc:	bdc5                	j	2eac <_vsnprintf+0x188c>
    2fbe:	0001                	nop
    2fc0:	010e7293          	andi	t0,t3,16
    2fc4:	bce9                	j	2a9e <_vsnprintf+0x147e>
    2fc6:	002f7693          	andi	a3,t5,2
    2fca:	87fa                	mv	a5,t5
    2fcc:	c4068be3          	beqz	a3,2c22 <_vsnprintf+0x1602>
    2fd0:	4a0e0f63          	beqz	t3,348e <_vsnprintf+0x1e6e>
    2fd4:	14081ce3          	bnez	a6,392c <_vsnprintf+0x230c>
    2fd8:	67f70fe3          	beq	a4,t6,3e56 <_vsnprintf+0x2836>
    2fdc:	7df98863          	beq	s3,t6,37ac <_vsnprintf+0x218c>
    2fe0:	46c1                	li	a3,16
    2fe2:	0037f713          	andi	a4,a5,3
    2fe6:	4e09                	li	t3,2
    2fe8:	72d88963          	beq	a7,a3,371a <_vsnprintf+0x20fa>
    2fec:	79c88463          	beq	a7,t3,3774 <_vsnprintf+0x2154>
    2ff0:	003f7793          	andi	a5,t5,3
    2ff4:	ecbfe06f          	j	1ebe <_vsnprintf+0x89e>
    2ff8:	7c07370b          	th.extu	a4,a4,31,0
    2ffc:	02edf163          	bgeu	s11,a4,301e <_vsnprintf+0x19fe>
    3000:	02000313          	li	t1,32
    3004:	00610533          	add	a0,sp,t1
    3008:	03000693          	li	a3,48
    300c:	006d8963          	beq	s11,t1,301e <_vsnprintf+0x19fe>
    3010:	0d85                	addi	s11,s11,1
    3012:	01b507b3          	add	a5,a0,s11
    3016:	fed78fa3          	sb	a3,-1(a5)
    301a:	feed99e3          	bne	s11,a4,300c <_vsnprintf+0x19ec>
    301e:	00167793          	andi	a5,a2,1
    3022:	44078063          	beqz	a5,3462 <_vsnprintf+0x1e42>
    3026:	7c09b68b          	th.extu	a3,s3,31,0
    302a:	68ddfbe3          	bgeu	s11,a3,3ec0 <_vsnprintf+0x28a0>
    302e:	02000e13          	li	t3,32
    3032:	01c10333          	add	t1,sp,t3
    3036:	03000513          	li	a0,48
    303a:	01cd8963          	beq	s11,t3,304c <_vsnprintf+0x1a2c>
    303e:	0d85                	addi	s11,s11,1
    3040:	01b307b3          	add	a5,t1,s11
    3044:	fea78fa3          	sb	a0,-1(a5)
    3048:	ffb699e3          	bne	a3,s11,303a <_vsnprintf+0x1a1a>
    304c:	44059963          	bnez	a1,349e <_vsnprintf+0x1e7e>
    3050:	002d87b3          	add	a5,s11,sp
    3054:	01f7c503          	lbu	a0,31(a5)
    3058:	4581                	li	a1,0
    305a:	87a6                	mv	a5,s1
    305c:	f46ff06f          	j	27a2 <_vsnprintf+0x1182>
    3060:	000da583          	lw	a1,0(s11)
    3064:	d97fe06f          	j	1dfa <_vsnprintf+0x7da>
    3068:	0028f693          	andi	a3,a7,2
    306c:	8646                	mv	a2,a7
    306e:	e6c9                	bnez	a3,30f8 <_vsnprintf+0x1ad8>
    3070:	7c07370b          	th.extu	a4,a4,31,0
    3074:	12099e63          	bnez	s3,31b0 <_vsnprintf+0x1b90>
    3078:	00367993          	andi	s3,a2,3
    307c:	8ee7efe3          	bltu	a5,a4,297a <_vsnprintf+0x135a>
    3080:	9e098de3          	beqz	s3,2a7a <_vsnprintf+0x145a>
    3084:	4981                	li	s3,0
    3086:	bad5                	j	2a7a <_vsnprintf+0x145a>
    3088:	00267e13          	andi	t3,a2,2
    308c:	380e0c63          	beqz	t3,3424 <_vsnprintf+0x1e04>
    3090:	87a6                	mv	a5,s1
    3092:	edffe06f          	j	1f70 <_vsnprintf+0x950>
    3096:	9c0608e3          	beqz	a2,2a66 <_vsnprintf+0x1446>
    309a:	7c09b70b          	th.extu	a4,s3,31,0
    309e:	90e7eae3          	bltu	a5,a4,29b2 <_vsnprintf+0x1392>
    30a2:	bae1                	j	2a7a <_vsnprintf+0x145a>
    30a4:	02b00513          	li	a0,43
    30a8:	00c4550b          	th.srb	a0,s0,a2,0
    30ac:	bccff06f          	j	2478 <_vsnprintf+0xe58>
    30b0:	46a9                	li	a3,10
    30b2:	8446                	mv	s0,a7
    30b4:	88b6                	mv	a7,a3
    30b6:	d01fe06f          	j	1db6 <_vsnprintf+0x796>
    30ba:	7c07370b          	th.extu	a4,a4,31,0
    30be:	0e099963          	bnez	s3,31b0 <_vsnprintf+0x1b90>
    30c2:	8ae7ece3          	bltu	a5,a4,297a <_vsnprintf+0x135a>
    30c6:	02000713          	li	a4,32
    30ca:	0036f993          	andi	s3,a3,3
    30ce:	fae789e3          	beq	a5,a4,3080 <_vsnprintf+0x1a60>
    30d2:	873e                	mv	a4,a5
    30d4:	1e0ed7e3          	bgez	t4,3ac2 <_vsnprintf+0x24a2>
    30d8:	1014                	addi	a3,sp,32
    30da:	02078713          	addi	a4,a5,32
    30de:	9736                	add	a4,a4,a3
    30e0:	02d00513          	li	a0,45
    30e4:	fea70023          	sb	a0,-32(a4)
    30e8:	4681                	li	a3,0
    30ea:	00178713          	addi	a4,a5,1
    30ee:	000989e3          	beqz	s3,3900 <_vsnprintf+0x22e0>
    30f2:	4981                	li	s3,0
    30f4:	f7ffe06f          	j	2072 <_vsnprintf+0xa52>
    30f8:	03f14503          	lbu	a0,63(sp)
    30fc:	87a6                	mv	a5,s1
    30fe:	4689                	li	a3,2
    3100:	02000713          	li	a4,32
    3104:	f75fe06f          	j	2078 <_vsnprintf+0xa58>
    3108:	7c07370b          	th.extu	a4,a4,31,0
    310c:	02edf163          	bgeu	s11,a4,312e <_vsnprintf+0x1b0e>
    3110:	02000513          	li	a0,32
    3114:	00a105b3          	add	a1,sp,a0
    3118:	03000693          	li	a3,48
    311c:	00ad8963          	beq	s11,a0,312e <_vsnprintf+0x1b0e>
    3120:	0d85                	addi	s11,s11,1
    3122:	01b587b3          	add	a5,a1,s11
    3126:	fed78fa3          	sb	a3,-1(a5)
    312a:	ffb719e3          	bne	a4,s11,311c <_vsnprintf+0x1afc>
    312e:	00167793          	andi	a5,a2,1
    3132:	54078f63          	beqz	a5,3690 <_vsnprintf+0x2070>
    3136:	7c09b68b          	th.extu	a3,s3,31,0
    313a:	3addf0e3          	bgeu	s11,a3,3cda <_vsnprintf+0x26ba>
    313e:	02000313          	li	t1,32
    3142:	00610533          	add	a0,sp,t1
    3146:	03000593          	li	a1,48
    314a:	006d8963          	beq	s11,t1,315c <_vsnprintf+0x1b3c>
    314e:	0d85                	addi	s11,s11,1
    3150:	01b507b3          	add	a5,a0,s11
    3154:	feb78fa3          	sb	a1,-1(a5)
    3158:	ffb699e3          	bne	a3,s11,314a <_vsnprintf+0x1b2a>
    315c:	56029063          	bnez	t0,36bc <_vsnprintf+0x209c>
    3160:	002d87b3          	add	a5,s11,sp
    3164:	01f7c503          	lbu	a0,31(a5)
    3168:	4801                	li	a6,0
    316a:	87a6                	mv	a5,s1
    316c:	b43d                	j	2b9a <_vsnprintf+0x157a>
    316e:	0028f693          	andi	a3,a7,2
    3172:	8646                	mv	a2,a7
    3174:	e6e5                	bnez	a3,325c <_vsnprintf+0x1c3c>
    3176:	7c07370b          	th.extu	a4,a4,31,0
    317a:	34099c63          	bnez	s3,34d2 <_vsnprintf+0x1eb2>
    317e:	00367993          	andi	s3,a2,3
    3182:	1ae7f463          	bgeu	a5,a4,332a <_vsnprintf+0x1d0a>
    3186:	0018f613          	andi	a2,a7,1
    318a:	4981                	li	s3,0
    318c:	b691                	j	2cd0 <_vsnprintf+0x16b0>
    318e:	000e0963          	beqz	t3,31a0 <_vsnprintf+0x1b80>
    3192:	00081463          	bnez	a6,319a <_vsnprintf+0x1b7a>
    3196:	cf9fe06f          	j	1e8e <_vsnprintf+0x86e>
    319a:	4801                	li	a6,0
    319c:	d07fe06f          	j	1ea2 <_vsnprintf+0x882>
    31a0:	7c09b40b          	th.extu	s0,s3,31,0
    31a4:	008df463          	bgeu	s11,s0,31ac <_vsnprintf+0x1b8c>
    31a8:	d3bfe06f          	j	1ee2 <_vsnprintf+0x8c2>
    31ac:	bce9                	j	2c86 <_vsnprintf+0x1666>
    31ae:	0001                	nop
    31b0:	0018f613          	andi	a2,a7,1
    31b4:	86c6                	mv	a3,a7
    31b6:	24060363          	beqz	a2,33fc <_vsnprintf+0x1ddc>
    31ba:	520ed963          	bgez	t4,36ec <_vsnprintf+0x20cc>
    31be:	39fd                	addiw	s3,s3,-1
    31c0:	fce7e063          	bltu	a5,a4,2980 <_vsnprintf+0x1360>
    31c4:	7c09b70b          	th.extu	a4,s3,31,0
    31c8:	fee7e563          	bltu	a5,a4,29b2 <_vsnprintf+0x1392>
    31cc:	02000713          	li	a4,32
    31d0:	8ae785e3          	beq	a5,a4,2a7a <_vsnprintf+0x145a>
    31d4:	873e                	mv	a4,a5
    31d6:	002707b3          	add	a5,a4,sp
    31da:	02d00693          	li	a3,45
    31de:	02d78023          	sb	a3,32(a5)
    31e2:	0705                	addi	a4,a4,1
    31e4:	4681                	li	a3,0
    31e6:	c219                	beqz	a2,31ec <_vsnprintf+0x1bcc>
    31e8:	e8bfe06f          	j	2072 <_vsnprintf+0xa52>
    31ec:	7c09b40b          	th.extu	s0,s3,31,0
    31f0:	4681                	li	a3,0
    31f2:	80876ce3          	bltu	a4,s0,2a0a <_vsnprintf+0x13ea>
    31f6:	e7dfe06f          	j	2072 <_vsnprintf+0xa52>
    31fa:	0001                	nop
    31fc:	002e7593          	andi	a1,t3,2
    3200:	8426                	mv	s0,s1
    3202:	dc059863          	bnez	a1,27d2 <_vsnprintf+0x11b2>
    3206:	7c07370b          	th.extu	a4,a4,31,0
    320a:	4d81                	li	s11,0
    320c:	40000813          	li	a6,1024
    3210:	de0718e3          	bnez	a4,3000 <_vsnprintf+0x19e0>
    3214:	001e7e13          	andi	t3,t3,1
    3218:	140e0ce3          	beqz	t3,3b70 <_vsnprintf+0x2550>
    321c:	7c09b68b          	th.extu	a3,s3,31,0
    3220:	e00697e3          	bnez	a3,302e <_vsnprintf+0x1a0e>
    3224:	6da2                	ld	s11,8(sp)
    3226:	c54fe06f          	j	167a <_vsnprintf+0x5a>
    322a:	0001                	nop
    322c:	00267693          	andi	a3,a2,2
    3230:	87b2                	mv	a5,a2
    3232:	dc0683e3          	beqz	a3,2ff8 <_vsnprintf+0x19d8>
    3236:	46058b63          	beqz	a1,36ac <_vsnprintf+0x208c>
    323a:	60081a63          	bnez	a6,384e <_vsnprintf+0x222e>
    323e:	27f708e3          	beq	a4,t6,3cae <_vsnprintf+0x268e>
    3242:	15f98ce3          	beq	s3,t6,3b9a <_vsnprintf+0x257a>
    3246:	4741                	li	a4,16
    3248:	8b8d                	andi	a5,a5,3
    324a:	4589                	li	a1,2
    324c:	3ae88a63          	beq	a7,a4,3600 <_vsnprintf+0x1fe0>
    3250:	64b88063          	beq	a7,a1,3890 <_vsnprintf+0x2270>
    3254:	00367713          	andi	a4,a2,3
    3258:	cd4ff06f          	j	272c <_vsnprintf+0x110c>
    325c:	03f14503          	lbu	a0,63(sp)
    3260:	8426                	mv	s0,s1
    3262:	4709                	li	a4,2
    3264:	02000d13          	li	s10,32
    3268:	e50ff06f          	j	28b8 <_vsnprintf+0x1298>
    326c:	7c07370b          	th.extu	a4,a4,31,0
    3270:	32098463          	beqz	s3,3598 <_vsnprintf+0x1f78>
    3274:	8b85                	andi	a5,a5,1
    3276:	c7f9                	beqz	a5,3344 <_vsnprintf+0x1d24>
    3278:	4781                	li	a5,0
    327a:	00c8f693          	andi	a3,a7,12
    327e:	fff9861b          	addiw	a2,s3,-1
    3282:	42d6198b          	th.mvnez	s3,a2,a3
    3286:	4505                	li	a0,1
    3288:	bae7efe3          	bltu	a5,a4,2e46 <_vsnprintf+0x1826>
    328c:	7c09b70b          	th.extu	a4,s3,31,0
    3290:	bee7e3e3          	bltu	a5,a4,2e76 <_vsnprintf+0x1856>
    3294:	02000713          	li	a4,32
    3298:	c8e78de3          	beq	a5,a4,2f32 <_vsnprintf+0x1912>
    329c:	873e                	mv	a4,a5
    329e:	0038f693          	andi	a3,a7,3
    32a2:	0048f793          	andi	a5,a7,4
    32a6:	0006831b          	sext.w	t1,a3
    32aa:	30078763          	beqz	a5,35b8 <_vsnprintf+0x1f98>
    32ae:	002707b3          	add	a5,a4,sp
    32b2:	02b00513          	li	a0,43
    32b6:	02a78023          	sb	a0,32(a5)
    32ba:	0705                	addi	a4,a4,1
    32bc:	00031763          	bnez	t1,32ca <_vsnprintf+0x1caa>
    32c0:	7c09bd8b          	th.extu	s11,s3,31,0
    32c4:	4581                	li	a1,0
    32c6:	c1b760e3          	bltu	a4,s11,2ec6 <_vsnprintf+0x18a6>
    32ca:	8426                	mv	s0,s1
    32cc:	86cff06f          	j	2338 <_vsnprintf+0xd18>
    32d0:	00081463          	bnez	a6,32d8 <_vsnprintf+0x1cb8>
    32d4:	bbbfe06f          	j	1e8e <_vsnprintf+0x86e>
    32d8:	47c1                	li	a5,16
    32da:	5af88363          	beq	a7,a5,3880 <_vsnprintf+0x2260>
    32de:	4709                	li	a4,2
    32e0:	003f7793          	andi	a5,t5,3
    32e4:	4e01                	li	t3,0
    32e6:	00e88463          	beq	a7,a4,32ee <_vsnprintf+0x1cce>
    32ea:	bd5fe06f          	j	1ebe <_vsnprintf+0x89e>
    32ee:	02000713          	li	a4,32
    32f2:	4881                	li	a7,0
    32f4:	38ed9463          	bne	s11,a4,367c <_vsnprintf+0x205c>
    32f8:	03f14503          	lbu	a0,63(sp)
    32fc:	8e46                	mv	t3,a7
    32fe:	87a6                	mv	a5,s1
    3300:	02000d93          	li	s11,32
    3304:	c37fe06f          	j	1f3a <_vsnprintf+0x91a>
    3308:	1000                	addi	s0,sp,32
    330a:	4d05                	li	s10,1
    330c:	46c1                	li	a3,16
    330e:	4809                	li	a6,2
    3310:	bcc5                	j	2e00 <_vsnprintf+0x17e0>
    3312:	7c07370b          	th.extu	a4,a4,31,0
    3316:	1a099e63          	bnez	s3,34d2 <_vsnprintf+0x1eb2>
    331a:	e6e7e6e3          	bltu	a5,a4,3186 <_vsnprintf+0x1b66>
    331e:	02000713          	li	a4,32
    3322:	0036f993          	andi	s3,a3,3
    3326:	0ee794e3          	bne	a5,a4,3c0e <_vsnprintf+0x25ee>
    332a:	aa0980e3          	beqz	s3,2dca <_vsnprintf+0x17aa>
    332e:	4981                	li	s3,0
    3330:	bc69                	j	2dca <_vsnprintf+0x17aa>
    3332:	0001                	nop
    3334:	00247793          	andi	a5,s0,2
    3338:	ce078163          	beqz	a5,281a <_vsnprintf+0x11fa>
    333c:	8426                	mv	s0,s1
    333e:	4781                	li	a5,0
    3340:	c5dfe06f          	j	1f9c <_vsnprintf+0x97c>
    3344:	4501                	li	a0,0
    3346:	b0e7e0e3          	bltu	a5,a4,2e46 <_vsnprintf+0x1826>
    334a:	02000713          	li	a4,32
    334e:	bce78ce3          	beq	a5,a4,2f26 <_vsnprintf+0x1906>
    3352:	f40e55e3          	bgez	t3,329c <_vsnprintf+0x1c7c>
    3356:	973e                	add	a4,a4,a5
    3358:	1014                	addi	a3,sp,32
    335a:	96ba                	add	a3,a3,a4
    335c:	02d00613          	li	a2,45
    3360:	00178713          	addi	a4,a5,1
    3364:	fec68023          	sb	a2,-32(a3)
    3368:	be99                	j	2ebe <_vsnprintf+0x189e>
    336a:	0001                	nop
    336c:	a40605e3          	beqz	a2,2db6 <_vsnprintf+0x1796>
    3370:	7c09b70b          	th.extu	a4,s3,31,0
    3374:	98e7e4e3          	bltu	a5,a4,2cfc <_vsnprintf+0x16dc>
    3378:	bc89                	j	2dca <_vsnprintf+0x17aa>
    337a:	0001                	nop
    337c:	4681                	li	a3,0
    337e:	cdcff06f          	j	285a <_vsnprintf+0x123a>
    3382:	002e7293          	andi	t0,t3,2
    3386:	8426                	mv	s0,s1
    3388:	840292e3          	bnez	t0,2bcc <_vsnprintf+0x15ac>
    338c:	7c07370b          	th.extu	a4,a4,31,0
    3390:	4d81                	li	s11,0
    3392:	40000813          	li	a6,1024
    3396:	d6071de3          	bnez	a4,3110 <_vsnprintf+0x1af0>
    339a:	001e7813          	andi	a6,t3,1
    339e:	1c0809e3          	beqz	a6,3d70 <_vsnprintf+0x2750>
    33a2:	7c09b68b          	th.extu	a3,s3,31,0
    33a6:	40000813          	li	a6,1024
    33aa:	d8069ae3          	bnez	a3,313e <_vsnprintf+0x1b1e>
    33ae:	8426                	mv	s0,s1
    33b0:	b835                	j	2bec <_vsnprintf+0x15cc>
    33b2:	0037f713          	andi	a4,a5,3
    33b6:	4e09                	li	t3,2
    33b8:	e319                	bnez	a4,33be <_vsnprintf+0x1d9e>
    33ba:	b19fe06f          	j	1ed2 <_vsnprintf+0x8b2>
    33be:	03f14503          	lbu	a0,63(sp)
    33c2:	87a6                	mv	a5,s1
    33c4:	02000d93          	li	s11,32
    33c8:	b73fe06f          	j	1f3a <_vsnprintf+0x91a>
    33cc:	00267693          	andi	a3,a2,2
    33d0:	87b2                	mv	a5,a2
    33d2:	d2068be3          	beqz	a3,3108 <_vsnprintf+0x1ae8>
    33d6:	20028763          	beqz	t0,35e4 <_vsnprintf+0x1fc4>
    33da:	40081363          	bnez	a6,37e0 <_vsnprintf+0x21c0>
    33de:	05e709e3          	beq	a4,t5,3c30 <_vsnprintf+0x2610>
    33e2:	69e98763          	beq	s3,t5,3a70 <_vsnprintf+0x2450>
    33e6:	4741                	li	a4,16
    33e8:	8b8d                	andi	a5,a5,3
    33ea:	4809                	li	a6,2
    33ec:	5ae88f63          	beq	a7,a4,39aa <_vsnprintf+0x238a>
    33f0:	73088b63          	beq	a7,a6,3b26 <_vsnprintf+0x2506>
    33f4:	00367713          	andi	a4,a2,3
    33f8:	f34ff06f          	j	2b2c <_vsnprintf+0x150c>
    33fc:	4601                	li	a2,0
    33fe:	d8e7e163          	bltu	a5,a4,2980 <_vsnprintf+0x1360>
    3402:	02000713          	li	a4,32
    3406:	e6e78363          	beq	a5,a4,2a6c <_vsnprintf+0x144c>
    340a:	300ed063          	bgez	t4,370a <_vsnprintf+0x20ea>
    340e:	973e                	add	a4,a4,a5
    3410:	1014                	addi	a3,sp,32
    3412:	96ba                	add	a3,a3,a4
    3414:	02d00613          	li	a2,45
    3418:	00178713          	addi	a4,a5,1
    341c:	fec68023          	sb	a2,-32(a3)
    3420:	b3f1                	j	31ec <_vsnprintf+0x1bcc>
    3422:	0001                	nop
    3424:	7c07370b          	th.extu	a4,a4,31,0
    3428:	4d81                	li	s11,0
    342a:	40000813          	li	a6,1024
    342e:	fe071e63          	bnez	a4,2c2a <_vsnprintf+0x160a>
    3432:	8b85                	andi	a5,a5,1
    3434:	70078963          	beqz	a5,3b46 <_vsnprintf+0x2526>
    3438:	7c09b68b          	th.extu	a3,s3,31,0
    343c:	820691e3          	bnez	a3,2c5e <_vsnprintf+0x163e>
    3440:	6da2                	ld	s11,8(sp)
    3442:	a38fe06f          	j	167a <_vsnprintf+0x5a>
    3446:	0001                	nop
    3448:	0048f893          	andi	a7,a7,4
    344c:	12088e63          	beqz	a7,3588 <_vsnprintf+0x1f68>
    3450:	02b00513          	li	a0,43
    3454:	02a10023          	sb	a0,32(sp)
    3458:	87a6                	mv	a5,s1
    345a:	4689                	li	a3,2
    345c:	4705                	li	a4,1
    345e:	c1bfe06f          	j	2078 <_vsnprintf+0xa58>
    3462:	c591                	beqz	a1,346e <_vsnprintf+0x1e4e>
    3464:	a8080e63          	beqz	a6,2700 <_vsnprintf+0x10e0>
    3468:	4801                	li	a6,0
    346a:	aaaff06f          	j	2714 <_vsnprintf+0x10f4>
    346e:	7c09b40b          	th.extu	s0,s3,31,0
    3472:	ac8ded63          	bltu	s11,s0,274c <_vsnprintf+0x112c>
    3476:	bee9                	j	3050 <_vsnprintf+0x1a30>
    3478:	00081463          	bnez	a6,3480 <_vsnprintf+0x1e60>
    347c:	da9fe06f          	j	2224 <_vsnprintf+0xc04>
    3480:	5a0e1a63          	bnez	t3,3a34 <_vsnprintf+0x2414>
    3484:	5af70b63          	beq	a4,a5,3a3a <_vsnprintf+0x241a>
    3488:	4801                	li	a6,0
    348a:	c91fe06f          	j	211a <_vsnprintf+0xafa>
    348e:	03f14503          	lbu	a0,63(sp)
    3492:	87a6                	mv	a5,s1
    3494:	4e09                	li	t3,2
    3496:	02000d93          	li	s11,32
    349a:	aa1fe06f          	j	1f3a <_vsnprintf+0x91a>
    349e:	a6080163          	beqz	a6,2700 <_vsnprintf+0x10e0>
    34a2:	47c1                	li	a5,16
    34a4:	14f88c63          	beq	a7,a5,35fc <_vsnprintf+0x1fdc>
    34a8:	4789                	li	a5,2
    34aa:	00367713          	andi	a4,a2,3
    34ae:	4581                	li	a1,0
    34b0:	a6f89e63          	bne	a7,a5,272c <_vsnprintf+0x110c>
    34b4:	02000793          	li	a5,32
    34b8:	4881                	li	a7,0
    34ba:	18fd9463          	bne	s11,a5,3642 <_vsnprintf+0x2022>
    34be:	03f14503          	lbu	a0,63(sp)
    34c2:	85c6                	mv	a1,a7
    34c4:	87a6                	mv	a5,s1
    34c6:	02000d93          	li	s11,32
    34ca:	ad8ff06f          	j	27a2 <_vsnprintf+0x1182>
    34ce:	873e                	mv	a4,a5
    34d0:	b2e9                	j	2e9a <_vsnprintf+0x187a>
    34d2:	0018f613          	andi	a2,a7,1
    34d6:	c23d                	beqz	a2,353c <_vsnprintf+0x1f1c>
    34d8:	fe035163          	bgez	t1,2cba <_vsnprintf+0x169a>
    34dc:	39fd                	addiw	s3,s3,-1
    34de:	fee7e963          	bltu	a5,a4,2cd0 <_vsnprintf+0x16b0>
    34e2:	7c09b70b          	th.extu	a4,s3,31,0
    34e6:	80e7ebe3          	bltu	a5,a4,2cfc <_vsnprintf+0x16dc>
    34ea:	02000713          	li	a4,32
    34ee:	8ce78ee3          	beq	a5,a4,2dca <_vsnprintf+0x17aa>
    34f2:	00278733          	add	a4,a5,sp
    34f6:	02d00693          	li	a3,45
    34fa:	02d70023          	sb	a3,32(a4)
    34fe:	00178d13          	addi	s10,a5,1
    3502:	4701                	li	a4,0
    3504:	ba061763          	bnez	a2,28b2 <_vsnprintf+0x1292>
    3508:	7c09b68b          	th.extu	a3,s3,31,0
    350c:	4701                	li	a4,0
    350e:	84dd67e3          	bltu	s10,a3,2d5c <_vsnprintf+0x173c>
    3512:	ba0ff06f          	j	28b2 <_vsnprintf+0x1292>
    3516:	0001                	nop
    3518:	03f14503          	lbu	a0,63(sp)
    351c:	87a6                	mv	a5,s1
    351e:	02000d93          	li	s11,32
    3522:	a80ff06f          	j	27a2 <_vsnprintf+0x1182>
    3526:	787d                	lui	a6,0xfffff
    3528:	7ff80813          	addi	a6,a6,2047 # fffffffffffff7ff <__kernel_stack+0xfffffffffff117ff>
    352c:	01047833          	and	a6,s0,a6
    3530:	22d69553          	fneg.d	fa0,fa3
    3534:	40086813          	ori	a6,a6,1024
    3538:	f54fe06f          	j	1c8c <_vsnprintf+0x66c>
    353c:	4601                	li	a2,0
    353e:	f8e7e963          	bltu	a5,a4,2cd0 <_vsnprintf+0x16b0>
    3542:	02000713          	li	a4,32
    3546:	86e78be3          	beq	a5,a4,2dbc <_vsnprintf+0x179c>
    354a:	3c035d63          	bgez	t1,3924 <_vsnprintf+0x2304>
    354e:	1014                	addi	a3,sp,32
    3550:	02078713          	addi	a4,a5,32
    3554:	9736                	add	a4,a4,a3
    3556:	02d00693          	li	a3,45
    355a:	00178d13          	addi	s10,a5,1
    355e:	fed70023          	sb	a3,-32(a4)
    3562:	b75d                	j	3508 <_vsnprintf+0x1ee8>
    3564:	0047f713          	andi	a4,a5,4
    3568:	2a070863          	beqz	a4,3818 <_vsnprintf+0x21f8>
    356c:	02b00793          	li	a5,43
    3570:	02f10023          	sb	a5,32(sp)
    3574:	4709                	li	a4,2
    3576:	4d05                	li	s10,1
    3578:	8426                	mv	s0,s1
    357a:	02b00513          	li	a0,43
    357e:	b3aff06f          	j	28b8 <_vsnprintf+0x1298>
    3582:	873e                	mv	a4,a5
    3584:	c4eff06f          	j	29d2 <_vsnprintf+0x13b2>
    3588:	8ba1                	andi	a5,a5,8
    358a:	34079f63          	bnez	a5,38e8 <_vsnprintf+0x22c8>
    358e:	87a6                	mv	a5,s1
    3590:	4689                	li	a3,2
    3592:	843e                	mv	s0,a5
    3594:	b13fe06f          	j	20a6 <_vsnprintf+0xa86>
    3598:	4781                	li	a5,0
    359a:	8a0713e3          	bnez	a4,2e40 <_vsnprintf+0x1820>
    359e:	4981                	li	s3,0
    35a0:	0038f693          	andi	a3,a7,3
    35a4:	b9fd                	j	32a2 <_vsnprintf+0x1c82>
    35a6:	0001                	nop
    35a8:	2785                	addiw	a5,a5,1
    35aa:	8da6                	mv	s11,s1
    35ac:	c119                	beqz	a0,35b2 <_vsnprintf+0x1f92>
    35ae:	cb2fe06f          	j	1a60 <_vsnprintf+0x440>
    35b2:	8dae                	mv	s11,a1
    35b4:	8c6fe06f          	j	167a <_vsnprintf+0x5a>
    35b8:	0088f593          	andi	a1,a7,8
    35bc:	22059b63          	bnez	a1,37f2 <_vsnprintf+0x21d2>
    35c0:	54031c63          	bnez	t1,3b18 <_vsnprintf+0x24f8>
    35c4:	7c09bd8b          	th.extu	s11,s3,31,0
    35c8:	8fb76fe3          	bltu	a4,s11,2ec6 <_vsnprintf+0x18a6>
    35cc:	020700e3          	beqz	a4,3dec <_vsnprintf+0x27cc>
    35d0:	02070793          	addi	a5,a4,32
    35d4:	1014                	addi	a3,sp,32
    35d6:	97b6                	add	a5,a5,a3
    35d8:	fdf7c503          	lbu	a0,-33(a5)
    35dc:	8426                	mv	s0,s1
    35de:	d5bfe06f          	j	2338 <_vsnprintf+0xd18>
    35e2:	0001                	nop
    35e4:	03f14503          	lbu	a0,63(sp)
    35e8:	87a6                	mv	a5,s1
    35ea:	4809                	li	a6,2
    35ec:	02000d93          	li	s11,32
    35f0:	daaff06f          	j	2b9a <_vsnprintf+0x157a>
    35f4:	03f14503          	lbu	a0,63(sp)
    35f8:	c35fe06f          	j	222c <_vsnprintf+0xc0c>
    35fc:	4785                	li	a5,1
    35fe:	4581                	li	a1,0
    3600:	02067713          	andi	a4,a2,32
    3604:	2c070763          	beqz	a4,38d2 <_vsnprintf+0x22b2>
    3608:	02000713          	li	a4,32
    360c:	92ed8663          	beq	s11,a4,2738 <_vsnprintf+0x1118>
    3610:	05800693          	li	a3,88
    3614:	00367713          	andi	a4,a2,3
    3618:	002d87b3          	add	a5,s11,sp
    361c:	02d78023          	sb	a3,32(a5)
    3620:	0d85                	addi	s11,s11,1
    3622:	90aff06f          	j	272c <_vsnprintf+0x110c>
    3626:	4741                	li	a4,16
    3628:	8b8d                	andi	a5,a5,3
    362a:	4589                	li	a1,2
    362c:	fce88ae3          	beq	a7,a4,3600 <_vsnprintf+0x1fe0>
    3630:	4589                	li	a1,2
    3632:	00367713          	andi	a4,a2,3
    3636:	8eb89b63          	bne	a7,a1,272c <_vsnprintf+0x110c>
    363a:	02000793          	li	a5,32
    363e:	e8fd80e3          	beq	s11,a5,34be <_vsnprintf+0x1e9e>
    3642:	06200693          	li	a3,98
    3646:	85c6                	mv	a1,a7
    3648:	bfc1                	j	3618 <_vsnprintf+0x1ff8>
    364a:	02000793          	li	a5,32
    364e:	e4fd80e3          	beq	s11,a5,348e <_vsnprintf+0x1e6e>
    3652:	950a                	add	a0,a0,sp
    3654:	02054503          	lbu	a0,32(a0)
    3658:	87a6                	mv	a5,s1
    365a:	4e09                	li	t3,2
    365c:	8dffe06f          	j	1f3a <_vsnprintf+0x91a>
    3660:	4741                	li	a4,16
    3662:	0ae88963          	beq	a7,a4,3714 <_vsnprintf+0x20f4>
    3666:	4e09                	li	t3,2
    3668:	003f7793          	andi	a5,t5,3
    366c:	01c88463          	beq	a7,t3,3674 <_vsnprintf+0x2054>
    3670:	84ffe06f          	j	1ebe <_vsnprintf+0x89e>
    3674:	02000713          	li	a4,32
    3678:	c8ed80e3          	beq	s11,a4,32f8 <_vsnprintf+0x1cd8>
    367c:	06200693          	li	a3,98
    3680:	8e46                	mv	t3,a7
    3682:	002d8733          	add	a4,s11,sp
    3686:	02d70023          	sb	a3,32(a4)
    368a:	0d85                	addi	s11,s11,1
    368c:	833fe06f          	j	1ebe <_vsnprintf+0x89e>
    3690:	00028763          	beqz	t0,369e <_vsnprintf+0x207e>
    3694:	c6080d63          	beqz	a6,2b0e <_vsnprintf+0x14ee>
    3698:	4801                	li	a6,0
    369a:	c80ff06f          	j	2b1a <_vsnprintf+0x14fa>
    369e:	7c09b40b          	th.extu	s0,s3,31,0
    36a2:	4801                	li	a6,0
    36a4:	ca8de463          	bltu	s11,s0,2b4c <_vsnprintf+0x152c>
    36a8:	bc65                	j	3160 <_vsnprintf+0x1b40>
    36aa:	0001                	nop
    36ac:	03f14503          	lbu	a0,63(sp)
    36b0:	87a6                	mv	a5,s1
    36b2:	4589                	li	a1,2
    36b4:	02000d93          	li	s11,32
    36b8:	8eaff06f          	j	27a2 <_vsnprintf+0x1182>
    36bc:	c4080963          	beqz	a6,2b0e <_vsnprintf+0x14ee>
    36c0:	47c1                	li	a5,16
    36c2:	2ef88263          	beq	a7,a5,39a6 <_vsnprintf+0x2386>
    36c6:	4789                	li	a5,2
    36c8:	00367713          	andi	a4,a2,3
    36cc:	4801                	li	a6,0
    36ce:	c4f89f63          	bne	a7,a5,2b2c <_vsnprintf+0x150c>
    36d2:	02000793          	li	a5,32
    36d6:	4881                	li	a7,0
    36d8:	18fd9a63          	bne	s11,a5,386c <_vsnprintf+0x224c>
    36dc:	03f14503          	lbu	a0,63(sp)
    36e0:	8846                	mv	a6,a7
    36e2:	87a6                	mv	a5,s1
    36e4:	02000d93          	li	s11,32
    36e8:	cb2ff06f          	j	2b9a <_vsnprintf+0x157a>
    36ec:	8ab1                	andi	a3,a3,12
    36ee:	fff9859b          	addiw	a1,s3,-1
    36f2:	42d5998b          	th.mvnez	s3,a1,a3
    36f6:	a8e7e563          	bltu	a5,a4,2980 <_vsnprintf+0x1360>
    36fa:	7c09b70b          	th.extu	a4,s3,31,0
    36fe:	aae7ea63          	bltu	a5,a4,29b2 <_vsnprintf+0x1392>
    3702:	02000713          	li	a4,32
    3706:	b6e78a63          	beq	a5,a4,2a7a <_vsnprintf+0x145a>
    370a:	873e                	mv	a4,a5
    370c:	0038f693          	andi	a3,a7,3
    3710:	ad4ff06f          	j	29e4 <_vsnprintf+0x13c4>
    3714:	0037f713          	andi	a4,a5,3
    3718:	4e09                	li	t3,2
    371a:	020f7793          	andi	a5,t5,32
    371e:	26078763          	beqz	a5,398c <_vsnprintf+0x236c>
    3722:	02000793          	li	a5,32
    3726:	c8fd89e3          	beq	s11,a5,33b8 <_vsnprintf+0x1d98>
    372a:	05800693          	li	a3,88
    372e:	003f7793          	andi	a5,t5,3
    3732:	bf81                	j	3682 <_vsnprintf+0x2062>
    3734:	02000793          	li	a5,32
    3738:	f6fd8ae3          	beq	s11,a5,36ac <_vsnprintf+0x208c>
    373c:	9e0a                	add	t3,t3,sp
    373e:	020e4503          	lbu	a0,32(t3)
    3742:	87a6                	mv	a5,s1
    3744:	4589                	li	a1,2
    3746:	85cff06f          	j	27a2 <_vsnprintf+0x1182>
    374a:	fffd8713          	addi	a4,s11,-1
    374e:	e32d                	bnez	a4,37b0 <_vsnprintf+0x2190>
    3750:	47c1                	li	a5,16
    3752:	68f88563          	beq	a7,a5,3ddc <_vsnprintf+0x27bc>
    3756:	4789                	li	a5,2
    3758:	02f88e63          	beq	a7,a5,3794 <_vsnprintf+0x2174>
    375c:	8e42                	mv	t3,a6
    375e:	003f7793          	andi	a5,t5,3
    3762:	1018                	addi	a4,sp,32
    3764:	4d85                	li	s11,1
    3766:	e9bfe06f          	j	2600 <_vsnprintf+0xfe0>
    376a:	02000693          	li	a3,32
    376e:	88c2                	mv	a7,a6
    3770:	f0dd96e3          	bne	s11,a3,367c <_vsnprintf+0x205c>
    3774:	b80712e3          	bnez	a4,32f8 <_vsnprintf+0x1cd8>
    3778:	02000d93          	li	s11,32
    377c:	8e46                	mv	t3,a7
    377e:	7c09b40b          	th.extu	s0,s3,31,0
    3782:	013df463          	bgeu	s11,s3,378a <_vsnprintf+0x216a>
    3786:	f5cfe06f          	j	1ee2 <_vsnprintf+0x8c2>
    378a:	03f14503          	lbu	a0,63(sp)
    378e:	87a6                	mv	a5,s1
    3790:	faafe06f          	j	1f3a <_vsnprintf+0x91a>
    3794:	06200793          	li	a5,98
    3798:	02f10023          	sb	a5,32(sp)
    379c:	8e42                	mv	t3,a6
    379e:	003f7793          	andi	a5,t5,3
    37a2:	02110713          	addi	a4,sp,33
    37a6:	4d89                	li	s11,2
    37a8:	e59fe06f          	j	2600 <_vsnprintf+0xfe0>
    37ac:	477d                	li	a4,31
    37ae:	4809                	li	a6,2
    37b0:	47c1                	li	a5,16
    37b2:	60f88163          	beq	a7,a5,3db4 <_vsnprintf+0x2794>
    37b6:	4789                	li	a5,2
    37b8:	5ef88963          	beq	a7,a5,3daa <_vsnprintf+0x278a>
    37bc:	1000                	addi	s0,sp,32
    37be:	8e42                	mv	t3,a6
    37c0:	003f7793          	andi	a5,t5,3
    37c4:	9722                	add	a4,a4,s0
    37c6:	e3bfe06f          	j	2600 <_vsnprintf+0xfe0>
    37ca:	02000793          	li	a5,32
    37ce:	e0fd8be3          	beq	s11,a5,35e4 <_vsnprintf+0x1fc4>
    37d2:	930a                	add	t1,t1,sp
    37d4:	02034503          	lbu	a0,32(t1)
    37d8:	87a6                	mv	a5,s1
    37da:	4809                	li	a6,2
    37dc:	bbeff06f          	j	2b9a <_vsnprintf+0x157a>
    37e0:	4741                	li	a4,16
    37e2:	32e88e63          	beq	a7,a4,3b1e <_vsnprintf+0x24fe>
    37e6:	4809                	li	a6,2
    37e8:	ef088ae3          	beq	a7,a6,36dc <_vsnprintf+0x20bc>
    37ec:	8b8d                	andi	a5,a5,3
    37ee:	b4aff06f          	j	2b38 <_vsnprintf+0x1518>
    37f2:	87ba                	mv	a5,a4
    37f4:	4581                	li	a1,0
    37f6:	00278733          	add	a4,a5,sp
    37fa:	02000513          	li	a0,32
    37fe:	02a70023          	sb	a0,32(a4)
    3802:	00178713          	addi	a4,a5,1
    3806:	ac0312e3          	bnez	t1,32ca <_vsnprintf+0x1caa>
    380a:	7c09bd8b          	th.extu	s11,s3,31,0
    380e:	ebb76c63          	bltu	a4,s11,2ec6 <_vsnprintf+0x18a6>
    3812:	8426                	mv	s0,s1
    3814:	b25fe06f          	j	2338 <_vsnprintf+0xd18>
    3818:	0087f713          	andi	a4,a5,8
    381c:	c70d                	beqz	a4,3846 <_vsnprintf+0x2226>
    381e:	0037f693          	andi	a3,a5,3
    3822:	4709                	li	a4,2
    3824:	4781                	li	a5,0
    3826:	00278633          	add	a2,a5,sp
    382a:	02000513          	li	a0,32
    382e:	02a60023          	sb	a0,32(a2)
    3832:	00178d13          	addi	s10,a5,1
    3836:	e689                	bnez	a3,3840 <_vsnprintf+0x2220>
    3838:	7c09b68b          	th.extu	a3,s3,31,0
    383c:	d2dd6063          	bltu	s10,a3,2d5c <_vsnprintf+0x173c>
    3840:	8426                	mv	s0,s1
    3842:	876ff06f          	j	28b8 <_vsnprintf+0x1298>
    3846:	8426                	mv	s0,s1
    3848:	4709                	li	a4,2
    384a:	8a2ff06f          	j	28ec <_vsnprintf+0x12cc>
    384e:	4741                	li	a4,16
    3850:	2ce88063          	beq	a7,a4,3b10 <_vsnprintf+0x24f0>
    3854:	4589                	li	a1,2
    3856:	8b8d                	andi	a5,a5,3
    3858:	00b88463          	beq	a7,a1,3860 <_vsnprintf+0x2240>
    385c:	eddfe06f          	j	2738 <_vsnprintf+0x1118>
    3860:	b9b9                	j	34be <_vsnprintf+0x1e9e>
    3862:	02000693          	li	a3,32
    3866:	88c2                	mv	a7,a6
    3868:	2add8f63          	beq	s11,a3,3b26 <_vsnprintf+0x2506>
    386c:	06200693          	li	a3,98
    3870:	8846                	mv	a6,a7
    3872:	002d87b3          	add	a5,s11,sp
    3876:	02d78023          	sb	a3,32(a5)
    387a:	0d85                	addi	s11,s11,1
    387c:	ab0ff06f          	j	2b2c <_vsnprintf+0x150c>
    3880:	4e01                	li	t3,0
    3882:	4705                	li	a4,1
    3884:	bd59                	j	371a <_vsnprintf+0x20fa>
    3886:	02000693          	li	a3,32
    388a:	88c2                	mv	a7,a6
    388c:	dadd9be3          	bne	s11,a3,3642 <_vsnprintf+0x2022>
    3890:	c20797e3          	bnez	a5,34be <_vsnprintf+0x1e9e>
    3894:	02000d93          	li	s11,32
    3898:	85c6                	mv	a1,a7
    389a:	7c09b40b          	th.extu	s0,s3,31,0
    389e:	013df463          	bgeu	s11,s3,38a6 <_vsnprintf+0x2286>
    38a2:	eabfe06f          	j	274c <_vsnprintf+0x112c>
    38a6:	03f14503          	lbu	a0,63(sp)
    38aa:	87a6                	mv	a5,s1
    38ac:	ef7fe06f          	j	27a2 <_vsnprintf+0x1182>
    38b0:	fffd8793          	addi	a5,s11,-1
    38b4:	2e079563          	bnez	a5,3b9e <_vsnprintf+0x257e>
    38b8:	47c1                	li	a5,16
    38ba:	2cf88863          	beq	a7,a5,3b8a <_vsnprintf+0x256a>
    38be:	4789                	li	a5,2
    38c0:	08f88463          	beq	a7,a5,3948 <_vsnprintf+0x2328>
    38c4:	85c2                	mv	a1,a6
    38c6:	00367713          	andi	a4,a2,3
    38ca:	101c                	addi	a5,sp,32
    38cc:	4d85                	li	s11,1
    38ce:	f37fe06f          	j	2804 <_vsnprintf+0x11e4>
    38d2:	02000713          	li	a4,32
    38d6:	00ed9463          	bne	s11,a4,38de <_vsnprintf+0x22be>
    38da:	e5ffe06f          	j	2738 <_vsnprintf+0x1118>
    38de:	07800693          	li	a3,120
    38e2:	00367713          	andi	a4,a2,3
    38e6:	bb0d                	j	3618 <_vsnprintf+0x1ff8>
    38e8:	4789                	li	a5,2
    38ea:	86be                	mv	a3,a5
    38ec:	4701                	li	a4,0
    38ee:	00270633          	add	a2,a4,sp
    38f2:	02000513          	li	a0,32
    38f6:	02a60023          	sb	a0,32(a2)
    38fa:	0705                	addi	a4,a4,1
    38fc:	90078363          	beqz	a5,2a02 <_vsnprintf+0x13e2>
    3900:	87a6                	mv	a5,s1
    3902:	f76fe06f          	j	2078 <_vsnprintf+0xa58>
    3906:	843e                	mv	s0,a5
    3908:	ec9fe06f          	j	27d0 <_vsnprintf+0x11b0>
    390c:	0088f793          	andi	a5,a7,8
    3910:	c7d9                	beqz	a5,399e <_vsnprintf+0x237e>
    3912:	0038f313          	andi	t1,a7,3
    3916:	4781                	li	a5,0
    3918:	4589                	li	a1,2
    391a:	bdf1                	j	37f6 <_vsnprintf+0x21d6>
    391c:	4781                	li	a5,0
    391e:	860714e3          	bnez	a4,3186 <_vsnprintf+0x1b66>
    3922:	4981                	li	s3,0
    3924:	0038f693          	andi	a3,a7,3
    3928:	c04ff06f          	j	2d2c <_vsnprintf+0x170c>
    392c:	4741                	li	a4,16
    392e:	a8e882e3          	beq	a7,a4,33b2 <_vsnprintf+0x1d92>
    3932:	4e09                	li	t3,2
    3934:	003f7f13          	andi	t5,t5,3
    3938:	01c88463          	beq	a7,t3,3940 <_vsnprintf+0x2320>
    393c:	d8efe06f          	j	1eca <_vsnprintf+0x8aa>
    3940:	ba65                	j	32f8 <_vsnprintf+0x1cd8>
    3942:	843e                	mv	s0,a5
    3944:	a84ff06f          	j	2bc8 <_vsnprintf+0x15a8>
    3948:	06200793          	li	a5,98
    394c:	02f10023          	sb	a5,32(sp)
    3950:	85c2                	mv	a1,a6
    3952:	00367713          	andi	a4,a2,3
    3956:	02110793          	addi	a5,sp,33
    395a:	4d89                	li	s11,2
    395c:	ea9fe06f          	j	2804 <_vsnprintf+0x11e4>
    3960:	0088f893          	andi	a7,a7,8
    3964:	34089263          	bnez	a7,3ca8 <_vsnprintf+0x2688>
    3968:	32069c63          	bnez	a3,3ca0 <_vsnprintf+0x2680>
    396c:	7c09b40b          	th.extu	s0,s3,31,0
    3970:	88876d63          	bltu	a4,s0,2a0a <_vsnprintf+0x13ea>
    3974:	30070f63          	beqz	a4,3c92 <_vsnprintf+0x2672>
    3978:	02070793          	addi	a5,a4,32
    397c:	1010                	addi	a2,sp,32
    397e:	97b2                	add	a5,a5,a2
    3980:	fdf7c503          	lbu	a0,-33(a5)
    3984:	87a6                	mv	a5,s1
    3986:	ef2fe06f          	j	2078 <_vsnprintf+0xa58>
    398a:	0001                	nop
    398c:	02000793          	li	a5,32
    3990:	a2fd84e3          	beq	s11,a5,33b8 <_vsnprintf+0x1d98>
    3994:	07800693          	li	a3,120
    3998:	003f7793          	andi	a5,t5,3
    399c:	b1dd                	j	3682 <_vsnprintf+0x2062>
    399e:	8426                	mv	s0,s1
    39a0:	4589                	li	a1,2
    39a2:	9cbfe06f          	j	236c <_vsnprintf+0xd4c>
    39a6:	4801                	li	a6,0
    39a8:	4785                	li	a5,1
    39aa:	02067713          	andi	a4,a2,32
    39ae:	cb35                	beqz	a4,3a22 <_vsnprintf+0x2402>
    39b0:	02000713          	li	a4,32
    39b4:	98ed8263          	beq	s11,a4,2b38 <_vsnprintf+0x1518>
    39b8:	05800693          	li	a3,88
    39bc:	00367713          	andi	a4,a2,3
    39c0:	bd4d                	j	3872 <_vsnprintf+0x2252>
    39c2:	0001                	nop
    39c4:	fffd8793          	addi	a5,s11,-1
    39c8:	e7d5                	bnez	a5,3a74 <_vsnprintf+0x2454>
    39ca:	47c1                	li	a5,16
    39cc:	08f88a63          	beq	a7,a5,3a60 <_vsnprintf+0x2440>
    39d0:	4789                	li	a5,2
    39d2:	06f88d63          	beq	a7,a5,3a4c <_vsnprintf+0x242c>
    39d6:	00367713          	andi	a4,a2,3
    39da:	101c                	addi	a5,sp,32
    39dc:	4d85                	li	s11,1
    39de:	03000513          	li	a0,48
    39e2:	00a78023          	sb	a0,0(a5)
    39e6:	e709                	bnez	a4,39f0 <_vsnprintf+0x23d0>
    39e8:	7c09b40b          	th.extu	s0,s3,31,0
    39ec:	968de063          	bltu	s11,s0,2b4c <_vsnprintf+0x152c>
    39f0:	87a6                	mv	a5,s1
    39f2:	9a8ff06f          	j	2b9a <_vsnprintf+0x157a>
    39f6:	03f14503          	lbu	a0,63(sp)
    39fa:	87a6                	mv	a5,s1
    39fc:	02000d93          	li	s11,32
    3a00:	99aff06f          	j	2b9a <_vsnprintf+0x157a>
    3a04:	4741                	li	a4,16
    3a06:	8b8d                	andi	a5,a5,3
    3a08:	4809                	li	a6,2
    3a0a:	fae880e3          	beq	a7,a4,39aa <_vsnprintf+0x238a>
    3a0e:	4809                	li	a6,2
    3a10:	00367713          	andi	a4,a2,3
    3a14:	91089c63          	bne	a7,a6,2b2c <_vsnprintf+0x150c>
    3a18:	02000793          	li	a5,32
    3a1c:	ccfd80e3          	beq	s11,a5,36dc <_vsnprintf+0x20bc>
    3a20:	b5b1                	j	386c <_vsnprintf+0x224c>
    3a22:	02000713          	li	a4,32
    3a26:	90ed8963          	beq	s11,a4,2b38 <_vsnprintf+0x1518>
    3a2a:	07800693          	li	a3,120
    3a2e:	00367713          	andi	a4,a2,3
    3a32:	b581                	j	3872 <_vsnprintf+0x2252>
    3a34:	4801                	li	a6,0
    3a36:	feefe06f          	j	2224 <_vsnprintf+0xc04>
    3a3a:	4d7d                	li	s10,31
    3a3c:	d1eff06f          	j	2f5a <_vsnprintf+0x193a>
    3a40:	00d10433          	add	s0,sp,a3
    3a44:	01b407b3          	add	a5,s0,s11
    3a48:	0d85                	addi	s11,s11,1
    3a4a:	bf51                	j	39de <_vsnprintf+0x23be>
    3a4c:	06200793          	li	a5,98
    3a50:	02f10023          	sb	a5,32(sp)
    3a54:	00367713          	andi	a4,a2,3
    3a58:	02110793          	addi	a5,sp,33
    3a5c:	4d89                	li	s11,2
    3a5e:	b741                	j	39de <_vsnprintf+0x23be>
    3a60:	02067793          	andi	a5,a2,32
    3a64:	e785                	bnez	a5,3a8c <_vsnprintf+0x246c>
    3a66:	07800793          	li	a5,120
    3a6a:	02f10023          	sb	a5,32(sp)
    3a6e:	b7dd                	j	3a54 <_vsnprintf+0x2434>
    3a70:	4809                	li	a6,2
    3a72:	47fd                	li	a5,31
    3a74:	4741                	li	a4,16
    3a76:	1000                	addi	s0,sp,32
    3a78:	02e88463          	beq	a7,a4,3aa0 <_vsnprintf+0x2480>
    3a7c:	4709                	li	a4,2
    3a7e:	00e88c63          	beq	a7,a4,3a96 <_vsnprintf+0x2476>
    3a82:	1000                	addi	s0,sp,32
    3a84:	00367713          	andi	a4,a2,3
    3a88:	97a2                	add	a5,a5,s0
    3a8a:	bf91                	j	39de <_vsnprintf+0x23be>
    3a8c:	05800793          	li	a5,88
    3a90:	02f10023          	sb	a5,32(sp)
    3a94:	b7c1                	j	3a54 <_vsnprintf+0x2434>
    3a96:	88c2                	mv	a7,a6
    3a98:	8dbe                	mv	s11,a5
    3a9a:	00367713          	andi	a4,a2,3
    3a9e:	b3f9                	j	386c <_vsnprintf+0x224c>
    3aa0:	02067713          	andi	a4,a2,32
    3aa4:	ffed8793          	addi	a5,s11,-2
    3aa8:	e315                	bnez	a4,3acc <_vsnprintf+0x24ac>
    3aaa:	1018                	addi	a4,sp,32
    3aac:	02078793          	addi	a5,a5,32
    3ab0:	97ba                	add	a5,a5,a4
    3ab2:	07800693          	li	a3,120
    3ab6:	1dfd                	addi	s11,s11,-1
    3ab8:	00367713          	andi	a4,a2,3
    3abc:	fed78023          	sb	a3,-32(a5)
    3ac0:	b751                	j	3a44 <_vsnprintf+0x2424>
    3ac2:	4981                	li	s3,0
    3ac4:	0038f693          	andi	a3,a7,3
    3ac8:	f1dfe06f          	j	29e4 <_vsnprintf+0x13c4>
    3acc:	1018                	addi	a4,sp,32
    3ace:	02078793          	addi	a5,a5,32
    3ad2:	97ba                	add	a5,a5,a4
    3ad4:	05800693          	li	a3,88
    3ad8:	1dfd                	addi	s11,s11,-1
    3ada:	00367713          	andi	a4,a2,3
    3ade:	fed78023          	sb	a3,-32(a5)
    3ae2:	b78d                	j	3a44 <_vsnprintf+0x2424>
    3ae4:	0046f713          	andi	a4,a3,4
    3ae8:	c73d                	beqz	a4,3b56 <_vsnprintf+0x2536>
    3aea:	1018                	addi	a4,sp,32
    3aec:	02078793          	addi	a5,a5,32
    3af0:	97ba                	add	a5,a5,a4
    3af2:	02b00713          	li	a4,43
    3af6:	fee78023          	sb	a4,-32(a5)
    3afa:	0d09                	addi	s10,s10,2
    3afc:	4709                	li	a4,2
    3afe:	bcad                	j	3578 <_vsnprintf+0x1f58>
    3b00:	0038f693          	andi	a3,a7,3
    3b04:	873e                	mv	a4,a5
    3b06:	8536                	mv	a0,a3
    3b08:	bac79063          	bne	a5,a2,2ea8 <_vsnprintf+0x1888>
    3b0c:	c26ff06f          	j	2f32 <_vsnprintf+0x1912>
    3b10:	8b8d                	andi	a5,a5,3
    3b12:	4589                	li	a1,2
    3b14:	c25fe06f          	j	2738 <_vsnprintf+0x1118>
    3b18:	8426                	mv	s0,s1
    3b1a:	bf6ff06f          	j	2f10 <_vsnprintf+0x18f0>
    3b1e:	8b8d                	andi	a5,a5,3
    3b20:	4809                	li	a6,2
    3b22:	816ff06f          	j	2b38 <_vsnprintf+0x1518>
    3b26:	ba079be3          	bnez	a5,36dc <_vsnprintf+0x20bc>
    3b2a:	02000d93          	li	s11,32
    3b2e:	8846                	mv	a6,a7
    3b30:	7c09b40b          	th.extu	s0,s3,31,0
    3b34:	013df463          	bgeu	s11,s3,3b3c <_vsnprintf+0x251c>
    3b38:	814ff06f          	j	2b4c <_vsnprintf+0x152c>
    3b3c:	03f14503          	lbu	a0,63(sp)
    3b40:	87a6                	mv	a5,s1
    3b42:	858ff06f          	j	2b9a <_vsnprintf+0x157a>
    3b46:	7c09b40b          	th.extu	s0,s3,31,0
    3b4a:	c019                	beqz	s0,3b50 <_vsnprintf+0x2530>
    3b4c:	b96fe06f          	j	1ee2 <_vsnprintf+0x8c2>
    3b50:	6da2                	ld	s11,8(sp)
    3b52:	b29fd06f          	j	167a <_vsnprintf+0x5a>
    3b56:	8aa1                	andi	a3,a3,8
    3b58:	c685                	beqz	a3,3b80 <_vsnprintf+0x2560>
    3b5a:	1018                	addi	a4,sp,32
    3b5c:	02078793          	addi	a5,a5,32
    3b60:	97ba                	add	a5,a5,a4
    3b62:	fea78023          	sb	a0,-32(a5)
    3b66:	0d09                	addi	s10,s10,2
    3b68:	8426                	mv	s0,s1
    3b6a:	4709                	li	a4,2
    3b6c:	d4dfe06f          	j	28b8 <_vsnprintf+0x1298>
    3b70:	7c09b40b          	th.extu	s0,s3,31,0
    3b74:	c019                	beqz	s0,3b7a <_vsnprintf+0x255a>
    3b76:	bd7fe06f          	j	274c <_vsnprintf+0x112c>
    3b7a:	6da2                	ld	s11,8(sp)
    3b7c:	afffd06f          	j	167a <_vsnprintf+0x5a>
    3b80:	8d3e                	mv	s10,a5
    3b82:	8426                	mv	s0,s1
    3b84:	4709                	li	a4,2
    3b86:	a26ff06f          	j	2dac <_vsnprintf+0x178c>
    3b8a:	02067793          	andi	a5,a2,32
    3b8e:	e78d                	bnez	a5,3bb8 <_vsnprintf+0x2598>
    3b90:	07800793          	li	a5,120
    3b94:	02f10023          	sb	a5,32(sp)
    3b98:	bb65                	j	3950 <_vsnprintf+0x2330>
    3b9a:	4809                	li	a6,2
    3b9c:	47fd                	li	a5,31
    3b9e:	4741                	li	a4,16
    3ba0:	02e88663          	beq	a7,a4,3bcc <_vsnprintf+0x25ac>
    3ba4:	4709                	li	a4,2
    3ba6:	00e88e63          	beq	a7,a4,3bc2 <_vsnprintf+0x25a2>
    3baa:	1000                	addi	s0,sp,32
    3bac:	85c2                	mv	a1,a6
    3bae:	00367713          	andi	a4,a2,3
    3bb2:	97a2                	add	a5,a5,s0
    3bb4:	c51fe06f          	j	2804 <_vsnprintf+0x11e4>
    3bb8:	05800793          	li	a5,88
    3bbc:	02f10023          	sb	a5,32(sp)
    3bc0:	bb41                	j	3950 <_vsnprintf+0x2330>
    3bc2:	88c2                	mv	a7,a6
    3bc4:	8dbe                	mv	s11,a5
    3bc6:	00367713          	andi	a4,a2,3
    3bca:	bca5                	j	3642 <_vsnprintf+0x2022>
    3bcc:	85c2                	mv	a1,a6
    3bce:	1000                	addi	s0,sp,32
    3bd0:	02067713          	andi	a4,a2,32
    3bd4:	ffed8793          	addi	a5,s11,-2
    3bd8:	eb2d                	bnez	a4,3c4a <_vsnprintf+0x262a>
    3bda:	1018                	addi	a4,sp,32
    3bdc:	02078793          	addi	a5,a5,32
    3be0:	97ba                	add	a5,a5,a4
    3be2:	07800693          	li	a3,120
    3be6:	1dfd                	addi	s11,s11,-1
    3be8:	00367713          	andi	a4,a2,3
    3bec:	fed78023          	sb	a3,-32(a5)
    3bf0:	c0ffe06f          	j	27fe <_vsnprintf+0x11de>
    3bf4:	787d                	lui	a6,0xfffff
    3bf6:	7ff80813          	addi	a6,a6,2047 # fffffffffffff7ff <__kernel_stack+0xfffffffffff117ff>
    3bfa:	f20687d3          	fmv.d.x	fa5,a3
    3bfe:	22f79553          	fneg.d	fa0,fa5
    3c02:	01047833          	and	a6,s0,a6
    3c06:	fb11530b          	th.sdd	t1,a7,(sp),1,4
    3c0a:	fcefe06f          	j	23d8 <_vsnprintf+0xdb8>
    3c0e:	d0035ae3          	bgez	t1,3922 <_vsnprintf+0x2302>
    3c12:	973e                	add	a4,a4,a5
    3c14:	1014                	addi	a3,sp,32
    3c16:	9736                	add	a4,a4,a3
    3c18:	02d00513          	li	a0,45
    3c1c:	fea70023          	sb	a0,-32(a4)
    3c20:	00178d13          	addi	s10,a5,1
    3c24:	4701                	li	a4,0
    3c26:	c0098de3          	beqz	s3,3840 <_vsnprintf+0x2220>
    3c2a:	4981                	li	s3,0
    3c2c:	c87fe06f          	j	28b2 <_vsnprintf+0x1292>
    3c30:	47c1                	li	a5,16
    3c32:	4809                	li	a6,2
    3c34:	e6f886e3          	beq	a7,a5,3aa0 <_vsnprintf+0x2480>
    3c38:	03088663          	beq	a7,a6,3c64 <_vsnprintf+0x2644>
    3c3c:	03000513          	li	a0,48
    3c40:	02a10fa3          	sb	a0,63(sp)
    3c44:	87a6                	mv	a5,s1
    3c46:	f55fe06f          	j	2b9a <_vsnprintf+0x157a>
    3c4a:	1018                	addi	a4,sp,32
    3c4c:	02078793          	addi	a5,a5,32
    3c50:	97ba                	add	a5,a5,a4
    3c52:	05800693          	li	a3,88
    3c56:	1dfd                	addi	s11,s11,-1
    3c58:	00367713          	andi	a4,a2,3
    3c5c:	fed78023          	sb	a3,-32(a5)
    3c60:	b9ffe06f          	j	27fe <_vsnprintf+0x11de>
    3c64:	00367713          	andi	a4,a2,3
    3c68:	4dfd                	li	s11,31
    3c6a:	b109                	j	386c <_vsnprintf+0x224c>
    3c6c:	873e                	mv	a4,a5
    3c6e:	920e58e3          	bgez	t3,359e <_vsnprintf+0x1f7e>
    3c72:	02078713          	addi	a4,a5,32
    3c76:	1014                	addi	a3,sp,32
    3c78:	9736                	add	a4,a4,a3
    3c7a:	02d00513          	li	a0,45
    3c7e:	fea70023          	sb	a0,-32(a4)
    3c82:	00178713          	addi	a4,a5,1
    3c86:	00099a63          	bnez	s3,3c9a <_vsnprintf+0x267a>
    3c8a:	4581                	li	a1,0
    3c8c:	8426                	mv	s0,s1
    3c8e:	eaafe06f          	j	2338 <_vsnprintf+0xd18>
    3c92:	8426                	mv	s0,s1
    3c94:	84a2                	mv	s1,s0
    3c96:	9e5fd06f          	j	167a <_vsnprintf+0x5a>
    3c9a:	4981                	li	s3,0
    3c9c:	9d5fe06f          	j	2670 <_vsnprintf+0x1050>
    3ca0:	4681                	li	a3,0
    3ca2:	87a6                	mv	a5,s1
    3ca4:	db3fe06f          	j	2a56 <_vsnprintf+0x1436>
    3ca8:	87b6                	mv	a5,a3
    3caa:	4681                	li	a3,0
    3cac:	b189                	j	38ee <_vsnprintf+0x22ce>
    3cae:	47c1                	li	a5,16
    3cb0:	4589                	li	a1,2
    3cb2:	f0f88fe3          	beq	a7,a5,3bd0 <_vsnprintf+0x25b0>
    3cb6:	00b88e63          	beq	a7,a1,3cd2 <_vsnprintf+0x26b2>
    3cba:	03000513          	li	a0,48
    3cbe:	02a10fa3          	sb	a0,63(sp)
    3cc2:	87a6                	mv	a5,s1
    3cc4:	adffe06f          	j	27a2 <_vsnprintf+0x1182>
    3cc8:	866a                	mv	a2,s10
    3cca:	8d3e                	mv	s10,a5
    3ccc:	87b2                	mv	a5,a2
    3cce:	a7cff06f          	j	2f4a <_vsnprintf+0x192a>
    3cd2:	00367713          	andi	a4,a2,3
    3cd6:	4dfd                	li	s11,31
    3cd8:	b2ad                	j	3642 <_vsnprintf+0x2022>
    3cda:	9a029de3          	bnez	t0,3694 <_vsnprintf+0x2074>
    3cde:	c82ff06f          	j	3160 <_vsnprintf+0x1b40>
    3ce2:	87a6                	mv	a5,s1
    3ce4:	4681                	li	a3,0
    3ce6:	b92fe06f          	j	2078 <_vsnprintf+0xa58>
    3cea:	03000793          	li	a5,48
    3cee:	46c1                	li	a3,16
    3cf0:	02f10023          	sb	a5,32(sp)
    3cf4:	8536                	mv	a0,a3
    3cf6:	678d                	lui	a5,0x3
    3cf8:	03078793          	addi	a5,a5,48 # 3030 <_vsnprintf+0x1a10>
    3cfc:	02f110a3          	sh	a5,33(sp)
    3d00:	4801                	li	a6,0
    3d02:	478d                	li	a5,3
    3d04:	40000e13          	li	t3,1024
    3d08:	4605                	li	a2,1
    3d0a:	bd9fd06f          	j	18e2 <_vsnprintf+0x2c2>
    3d0e:	00467713          	andi	a4,a2,4
    3d12:	00367313          	andi	t1,a2,3
    3d16:	cf3d                	beqz	a4,3d94 <_vsnprintf+0x2774>
    3d18:	1018                	addi	a4,sp,32
    3d1a:	02078793          	addi	a5,a5,32
    3d1e:	97ba                	add	a5,a5,a4
    3d20:	02b00513          	li	a0,43
    3d24:	00268713          	addi	a4,a3,2
    3d28:	fea78023          	sb	a0,-32(a5)
    3d2c:	8426                	mv	s0,s1
    3d2e:	4589                	li	a1,2
    3d30:	e08fe06f          	j	2338 <_vsnprintf+0xd18>
    3d34:	7c09b70b          	th.extu	a4,s3,31,0
    3d38:	00e7f463          	bgeu	a5,a4,3d40 <_vsnprintf+0x2720>
    3d3c:	fc1fe06f          	j	2cfc <_vsnprintf+0x16dc>
    3d40:	02000713          	li	a4,32
    3d44:	88e78363          	beq	a5,a4,2dca <_vsnprintf+0x17aa>
    3d48:	0038f693          	andi	a3,a7,3
    3d4c:	fe1fe06f          	j	2d2c <_vsnprintf+0x170c>
    3d50:	0038f693          	andi	a3,a7,3
    3d54:	8636                	mv	a2,a3
    3d56:	00b78463          	beq	a5,a1,3d5e <_vsnprintf+0x273e>
    3d5a:	fcffe06f          	j	2d28 <_vsnprintf+0x1708>
    3d5e:	86cff06f          	j	2dca <_vsnprintf+0x17aa>
    3d62:	03000793          	li	a5,48
    3d66:	46bd                	li	a3,15
    3d68:	02f10023          	sb	a5,32(sp)
    3d6c:	8536                	mv	a0,a3
    3d6e:	b761                	j	3cf6 <_vsnprintf+0x26d6>
    3d70:	7c09b40b          	th.extu	s0,s3,31,0
    3d74:	c019                	beqz	s0,3d7a <_vsnprintf+0x275a>
    3d76:	dd7fe06f          	j	2b4c <_vsnprintf+0x152c>
    3d7a:	8426                	mv	s0,s1
    3d7c:	e71fe06f          	j	2bec <_vsnprintf+0x15cc>
    3d80:	0038f693          	andi	a3,a7,3
    3d84:	873e                	mv	a4,a5
    3d86:	8636                	mv	a2,a3
    3d88:	00b78463          	beq	a5,a1,3d90 <_vsnprintf+0x2770>
    3d8c:	c55fe06f          	j	29e0 <_vsnprintf+0x13c0>
    3d90:	cebfe06f          	j	2a7a <_vsnprintf+0x145a>
    3d94:	8a21                	andi	a2,a2,8
    3d96:	12061963          	bnez	a2,3ec8 <_vsnprintf+0x28a8>
    3d9a:	873e                	mv	a4,a5
    3d9c:	8426                	mv	s0,s1
    3d9e:	4589                	li	a1,2
    3da0:	970ff06f          	j	2f10 <_vsnprintf+0x18f0>
    3da4:	4701                	li	a4,0
    3da6:	fd2ff06f          	j	3578 <_vsnprintf+0x1f58>
    3daa:	88c2                	mv	a7,a6
    3dac:	8dba                	mv	s11,a4
    3dae:	003f7793          	andi	a5,t5,3
    3db2:	b0e9                	j	367c <_vsnprintf+0x205c>
    3db4:	8e42                	mv	t3,a6
    3db6:	1000                	addi	s0,sp,32
    3db8:	020f7713          	andi	a4,t5,32
    3dbc:	ffed8793          	addi	a5,s11,-2
    3dc0:	eb15                	bnez	a4,3df4 <_vsnprintf+0x27d4>
    3dc2:	02078793          	addi	a5,a5,32
    3dc6:	1018                	addi	a4,sp,32
    3dc8:	973e                	add	a4,a4,a5
    3dca:	07800693          	li	a3,120
    3dce:	1dfd                	addi	s11,s11,-1
    3dd0:	003f7793          	andi	a5,t5,3
    3dd4:	fed70023          	sb	a3,-32(a4)
    3dd8:	823fe06f          	j	25fa <_vsnprintf+0xfda>
    3ddc:	020f7793          	andi	a5,t5,32
    3de0:	e3b9                	bnez	a5,3e26 <_vsnprintf+0x2806>
    3de2:	07800793          	li	a5,120
    3de6:	02f10023          	sb	a5,32(sp)
    3dea:	ba4d                	j	379c <_vsnprintf+0x217c>
    3dec:	8426                	mv	s0,s1
    3dee:	8dc2                	mv	s11,a6
    3df0:	da8fe06f          	j	2398 <_vsnprintf+0xd78>
    3df4:	02078793          	addi	a5,a5,32
    3df8:	1018                	addi	a4,sp,32
    3dfa:	973e                	add	a4,a4,a5
    3dfc:	05800693          	li	a3,88
    3e00:	1dfd                	addi	s11,s11,-1
    3e02:	003f7793          	andi	a5,t5,3
    3e06:	fed70023          	sb	a3,-32(a4)
    3e0a:	ff0fe06f          	j	25fa <_vsnprintf+0xfda>
    3e0e:	0088f893          	andi	a7,a7,8
    3e12:	02089f63          	bnez	a7,3e50 <_vsnprintf+0x2830>
    3e16:	eb05                	bnez	a4,3e46 <_vsnprintf+0x2826>
    3e18:	7c09b68b          	th.extu	a3,s3,31,0
    3e1c:	00d7fa63          	bgeu	a5,a3,3e30 <_vsnprintf+0x2810>
    3e20:	8d3e                	mv	s10,a5
    3e22:	f3bfe06f          	j	2d5c <_vsnprintf+0x173c>
    3e26:	05800793          	li	a5,88
    3e2a:	02f10023          	sb	a5,32(sp)
    3e2e:	b2bd                	j	379c <_vsnprintf+0x217c>
    3e30:	dfd5                	beqz	a5,3dec <_vsnprintf+0x27cc>
    3e32:	02078693          	addi	a3,a5,32
    3e36:	1010                	addi	a2,sp,32
    3e38:	96b2                	add	a3,a3,a2
    3e3a:	fdf6c503          	lbu	a0,-33(a3)
    3e3e:	8d3e                	mv	s10,a5
    3e40:	8426                	mv	s0,s1
    3e42:	a77fe06f          	j	28b8 <_vsnprintf+0x1298>
    3e46:	8d3e                	mv	s10,a5
    3e48:	4701                	li	a4,0
    3e4a:	8426                	mv	s0,s1
    3e4c:	f5dfe06f          	j	2da8 <_vsnprintf+0x1788>
    3e50:	86ba                	mv	a3,a4
    3e52:	4701                	li	a4,0
    3e54:	bac9                	j	3826 <_vsnprintf+0x2206>
    3e56:	47c1                	li	a5,16
    3e58:	4e09                	li	t3,2
    3e5a:	f4f88fe3          	beq	a7,a5,3db8 <_vsnprintf+0x2798>
    3e5e:	01c88d63          	beq	a7,t3,3e78 <_vsnprintf+0x2858>
    3e62:	03000513          	li	a0,48
    3e66:	02a10fa3          	sb	a0,63(sp)
    3e6a:	87a6                	mv	a5,s1
    3e6c:	8cefe06f          	j	1f3a <_vsnprintf+0x91a>
    3e70:	b20e1163          	bnez	t3,3192 <_vsnprintf+0x1b72>
    3e74:	e13fe06f          	j	2c86 <_vsnprintf+0x1666>
    3e78:	003f7793          	andi	a5,t5,3
    3e7c:	4dfd                	li	s11,31
    3e7e:	ffeff06f          	j	367c <_vsnprintf+0x205c>
    3e82:	0046f713          	andi	a4,a3,4
    3e86:	cf19                	beqz	a4,3ea4 <_vsnprintf+0x2884>
    3e88:	1018                	addi	a4,sp,32
    3e8a:	02078793          	addi	a5,a5,32
    3e8e:	97ba                	add	a5,a5,a4
    3e90:	02b00513          	li	a0,43
    3e94:	fea78023          	sb	a0,-32(a5)
    3e98:	002f0713          	addi	a4,t5,2
    3e9c:	87a6                	mv	a5,s1
    3e9e:	4689                	li	a3,2
    3ea0:	9d8fe06f          	j	2078 <_vsnprintf+0xa58>
    3ea4:	8aa1                	andi	a3,a3,8
    3ea6:	c29d                	beqz	a3,3ecc <_vsnprintf+0x28ac>
    3ea8:	1018                	addi	a4,sp,32
    3eaa:	02078793          	addi	a5,a5,32
    3eae:	97ba                	add	a5,a5,a4
    3eb0:	fea78023          	sb	a0,-32(a5)
    3eb4:	002f0713          	addi	a4,t5,2
    3eb8:	87a6                	mv	a5,s1
    3eba:	4689                	li	a3,2
    3ebc:	9bcfe06f          	j	2078 <_vsnprintf+0xa58>
    3ec0:	da059263          	bnez	a1,3464 <_vsnprintf+0x1e44>
    3ec4:	98cff06f          	j	3050 <_vsnprintf+0x1a30>
    3ec8:	4589                	li	a1,2
    3eca:	b235                	j	37f6 <_vsnprintf+0x21d6>
    3ecc:	873e                	mv	a4,a5
    3ece:	4689                	li	a3,2
    3ed0:	87a6                	mv	a5,s1
    3ed2:	b89fe06f          	j	2a5a <_vsnprintf+0x143a>
    3ed6:	00000013          	nop
    3eda:	00000013          	nop
    3ede:	0001                	nop

0000000000003ee0 <puts>:
    3ee0:	1141                	addi	sp,sp,-16
    3ee2:	f811540b          	th.sdd	s0,ra,(sp),0,4
    3ee6:	842a                	mv	s0,a0
    3ee8:	00054503          	lbu	a0,0(a0)
    3eec:	c901                	beqz	a0,3efc <puts+0x1c>
    3eee:	0001                	nop
    3ef0:	55fd                	li	a1,-1
    3ef2:	e7ffc0ef          	jal	d70 <fputc>
    3ef6:	8814450b          	th.lbuib	a0,(s0),1,0
    3efa:	f97d                	bnez	a0,3ef0 <puts+0x10>
    3efc:	55fd                	li	a1,-1
    3efe:	4529                	li	a0,10
    3f00:	e71fc0ef          	jal	d70 <fputc>
    3f04:	f811440b          	th.ldd	s0,ra,(sp),0,4
    3f08:	4501                	li	a0,0
    3f0a:	0141                	addi	sp,sp,16
    3f0c:	8082                	ret
    3f0e:	0001                	nop

0000000000003f10 <_putchar>:
    3f10:	55fd                	li	a1,-1
    3f12:	e5ffc06f          	j	d70 <fputc>
    3f16:	00000013          	nop
    3f1a:	00000013          	nop
    3f1e:	0001                	nop

0000000000003f20 <putchar>:
    3f20:	1141                	addi	sp,sp,-16
    3f22:	0ff57513          	zext.b	a0,a0
    3f26:	55fd                	li	a1,-1
    3f28:	e406                	sd	ra,8(sp)
    3f2a:	e47fc0ef          	jal	d70 <fputc>
    3f2e:	60a2                	ld	ra,8(sp)
    3f30:	4501                	li	a0,0
    3f32:	0141                	addi	sp,sp,16
    3f34:	8082                	ret
    3f36:	00000013          	nop
    3f3a:	00000013          	nop
    3f3e:	0001                	nop

0000000000003f40 <printf>:
    3f40:	711d                	addi	sp,sp,-96
    3f42:	02810313          	addi	t1,sp,40
    3f46:	6e05                	lui	t3,0x1
    3f48:	fed1560b          	th.sdd	a2,a3,(sp),3,4
    3f4c:	e0ba                	sd	a4,64(sp)
    3f4e:	e4be                	sd	a5,72(sp)
    3f50:	f42e                	sd	a1,40(sp)
    3f52:	86aa                	mv	a3,a0
    3f54:	858a                	mv	a1,sp
    3f56:	871a                	mv	a4,t1
    3f58:	dd0e0513          	addi	a0,t3,-560 # dd0 <_out_char>
    3f5c:	567d                	li	a2,-1
    3f5e:	ec06                	sd	ra,24(sp)
    3f60:	e8c2                	sd	a6,80(sp)
    3f62:	ecc6                	sd	a7,88(sp)
    3f64:	e41a                	sd	t1,8(sp)
    3f66:	ebafd0ef          	jal	1620 <_vsnprintf>
    3f6a:	60e2                	ld	ra,24(sp)
    3f6c:	6125                	addi	sp,sp,96
    3f6e:	8082                	ret

0000000000003f70 <sprintf>:
    3f70:	715d                	addi	sp,sp,-80
    3f72:	02010313          	addi	t1,sp,32
    3f76:	8eae                	mv	t4,a1
    3f78:	6e05                	lui	t3,0x1
    3f7a:	fcd1560b          	th.sdd	a2,a3,(sp),2,4
    3f7e:	fef1570b          	th.sdd	a4,a5,(sp),3,4
    3f82:	85aa                	mv	a1,a0
    3f84:	86f6                	mv	a3,t4
    3f86:	da0e0513          	addi	a0,t3,-608 # da0 <_out_buffer>
    3f8a:	871a                	mv	a4,t1
    3f8c:	567d                	li	a2,-1
    3f8e:	ec06                	sd	ra,24(sp)
    3f90:	e0c2                	sd	a6,64(sp)
    3f92:	e4c6                	sd	a7,72(sp)
    3f94:	e41a                	sd	t1,8(sp)
    3f96:	e8afd0ef          	jal	1620 <_vsnprintf>
    3f9a:	60e2                	ld	ra,24(sp)
    3f9c:	6161                	addi	sp,sp,80
    3f9e:	8082                	ret

0000000000003fa0 <snprintf>:
    3fa0:	715d                	addi	sp,sp,-80
    3fa2:	02810313          	addi	t1,sp,40
    3fa6:	8eae                	mv	t4,a1
    3fa8:	6e05                	lui	t3,0x1
    3faa:	f436                	sd	a3,40(sp)
    3fac:	fef1570b          	th.sdd	a4,a5,(sp),3,4
    3fb0:	85aa                	mv	a1,a0
    3fb2:	86b2                	mv	a3,a2
    3fb4:	da0e0513          	addi	a0,t3,-608 # da0 <_out_buffer>
    3fb8:	8676                	mv	a2,t4
    3fba:	871a                	mv	a4,t1
    3fbc:	ec06                	sd	ra,24(sp)
    3fbe:	e0c2                	sd	a6,64(sp)
    3fc0:	e4c6                	sd	a7,72(sp)
    3fc2:	e41a                	sd	t1,8(sp)
    3fc4:	e5cfd0ef          	jal	1620 <_vsnprintf>
    3fc8:	60e2                	ld	ra,24(sp)
    3fca:	6161                	addi	sp,sp,80
    3fcc:	8082                	ret
    3fce:	0001                	nop

0000000000003fd0 <vprintf>:
    3fd0:	1101                	addi	sp,sp,-32
    3fd2:	86aa                	mv	a3,a0
    3fd4:	6505                	lui	a0,0x1
    3fd6:	872e                	mv	a4,a1
    3fd8:	dd050513          	addi	a0,a0,-560 # dd0 <_out_char>
    3fdc:	002c                	addi	a1,sp,8
    3fde:	567d                	li	a2,-1
    3fe0:	ec06                	sd	ra,24(sp)
    3fe2:	e3efd0ef          	jal	1620 <_vsnprintf>
    3fe6:	60e2                	ld	ra,24(sp)
    3fe8:	6105                	addi	sp,sp,32
    3fea:	8082                	ret
    3fec:	00000013          	nop

0000000000003ff0 <vsnprintf>:
    3ff0:	88ae                	mv	a7,a1
    3ff2:	8832                	mv	a6,a2
    3ff4:	6785                	lui	a5,0x1
    3ff6:	8736                	mv	a4,a3
    3ff8:	85aa                	mv	a1,a0
    3ffa:	8646                	mv	a2,a7
    3ffc:	86c2                	mv	a3,a6
    3ffe:	da078513          	addi	a0,a5,-608 # da0 <_out_buffer>
    4002:	e1efd06f          	j	1620 <_vsnprintf>
    4006:	00000013          	nop
    400a:	00000013          	nop
    400e:	0001                	nop

0000000000004010 <fctprintf>:
    4010:	711d                	addi	sp,sp,-96
    4012:	03810313          	addi	t1,sp,56
    4016:	6f05                	lui	t5,0x1
    4018:	fc36                	sd	a3,56(sp)
    401a:	e0ba                	sd	a4,64(sp)
    401c:	8e2a                	mv	t3,a0
    401e:	8eae                	mv	t4,a1
    4020:	86b2                	mv	a3,a2
    4022:	080c                	addi	a1,sp,16
    4024:	dc0f0513          	addi	a0,t5,-576 # dc0 <_out_fct>
    4028:	871a                	mv	a4,t1
    402a:	567d                	li	a2,-1
    402c:	f406                	sd	ra,40(sp)
    402e:	e4be                	sd	a5,72(sp)
    4030:	e8c2                	sd	a6,80(sp)
    4032:	e41a                	sd	t1,8(sp)
    4034:	fbd15e0b          	th.sdd	t3,t4,(sp),1,4
    4038:	ecc6                	sd	a7,88(sp)
    403a:	de6fd0ef          	jal	1620 <_vsnprintf>
    403e:	70a2                	ld	ra,40(sp)
    4040:	6125                	addi	sp,sp,96
    4042:	8082                	ret
	...

0000000000004050 <__thead_vprintfsprintf>:
    4050:	4501                	li	a0,0
    4052:	8082                	ret
    4054:	00000013          	nop
    4058:	00000013          	nop
    405c:	00000013          	nop

0000000000004060 <__thead_vprintfprintf>:
    4060:	4501                	li	a0,0
    4062:	8082                	ret
    4064:	00000013          	nop
    4068:	00000013          	nop
    406c:	00000013          	nop

0000000000004070 <stdout>:
    4070:	4501                	li	a0,0
    4072:	8082                	ret
	...

0000000000004080 <ck_uart_set_baudrate>:
    4080:	05f5e7b7          	lui	a5,0x5f5e
    4084:	1007879b          	addiw	a5,a5,256 # 5f5e100 <__kernel_stack+0x5e70100>
    4088:	02b7d7bb          	divuw	a5,a5,a1
    408c:	6518                	ld	a4,8(a0)
    408e:	c90c                	sw	a1,16(a0)
    4090:	00c74683          	lbu	a3,12(a4)
    4094:	0806e693          	ori	a3,a3,128
    4098:	00d70623          	sb	a3,12(a4)
    409c:	2c47b68b          	th.extu	a3,a5,11,4
    40a0:	00d70023          	sb	a3,0(a4)
    40a4:	4cc7b78b          	th.extu	a5,a5,19,12
    40a8:	00f70223          	sb	a5,4(a4)
    40ac:	00c74783          	lbu	a5,12(a4)
    40b0:	07f7f793          	andi	a5,a5,127
    40b4:	00f70623          	sb	a5,12(a4)
    40b8:	8082                	ret
    40ba:	00000013          	nop
    40be:	0001                	nop

00000000000040c0 <ck_uart_set_parity>:
    40c0:	4785                	li	a5,1
    40c2:	c94c                	sw	a1,20(a0)
    40c4:	02f58e63          	beq	a1,a5,4100 <ck_uart_set_parity+0x40>
    40c8:	4789                	li	a5,2
    40ca:	00f58b63          	beq	a1,a5,40e0 <ck_uart_set_parity+0x20>
    40ce:	e59d                	bnez	a1,40fc <ck_uart_set_parity+0x3c>
    40d0:	6518                	ld	a4,8(a0)
    40d2:	00c74783          	lbu	a5,12(a4)
    40d6:	0f77f793          	andi	a5,a5,247
    40da:	00f70623          	sb	a5,12(a4)
    40de:	8082                	ret
    40e0:	6518                	ld	a4,8(a0)
    40e2:	00c74783          	lbu	a5,12(a4)
    40e6:	0087e793          	ori	a5,a5,8
    40ea:	00f70623          	sb	a5,12(a4)
    40ee:	6518                	ld	a4,8(a0)
    40f0:	00c74783          	lbu	a5,12(a4)
    40f4:	0107e793          	ori	a5,a5,16
    40f8:	00f70623          	sb	a5,12(a4)
    40fc:	8082                	ret
    40fe:	0001                	nop
    4100:	6518                	ld	a4,8(a0)
    4102:	00c74783          	lbu	a5,12(a4)
    4106:	0087e793          	ori	a5,a5,8
    410a:	00f70623          	sb	a5,12(a4)
    410e:	6518                	ld	a4,8(a0)
    4110:	00c74783          	lbu	a5,12(a4)
    4114:	0ef7f793          	andi	a5,a5,239
    4118:	00f70623          	sb	a5,12(a4)
    411c:	8082                	ret
    411e:	0001                	nop

0000000000004120 <ck_uart_set_wordsize>:
    4120:	4789                	li	a5,2
    4122:	cd4c                	sw	a1,28(a0)
    4124:	04f58063          	beq	a1,a5,4164 <ck_uart_set_wordsize+0x44>
    4128:	02b7e263          	bltu	a5,a1,414c <ck_uart_set_wordsize+0x2c>
    412c:	cda1                	beqz	a1,4184 <ck_uart_set_wordsize+0x64>
    412e:	6518                	ld	a4,8(a0)
    4130:	00c74783          	lbu	a5,12(a4)
    4134:	0fd7f793          	andi	a5,a5,253
    4138:	00f70623          	sb	a5,12(a4)
    413c:	6518                	ld	a4,8(a0)
    413e:	00c74783          	lbu	a5,12(a4)
    4142:	0017e793          	ori	a5,a5,1
    4146:	00f70623          	sb	a5,12(a4)
    414a:	8082                	ret
    414c:	478d                	li	a5,3
    414e:	04f59363          	bne	a1,a5,4194 <ck_uart_set_wordsize+0x74>
    4152:	6518                	ld	a4,8(a0)
    4154:	00c74783          	lbu	a5,12(a4)
    4158:	0037e793          	ori	a5,a5,3
    415c:	00f70623          	sb	a5,12(a4)
    4160:	8082                	ret
    4162:	0001                	nop
    4164:	6518                	ld	a4,8(a0)
    4166:	00c74783          	lbu	a5,12(a4)
    416a:	0fe7f793          	andi	a5,a5,254
    416e:	00f70623          	sb	a5,12(a4)
    4172:	6518                	ld	a4,8(a0)
    4174:	00c74783          	lbu	a5,12(a4)
    4178:	0027e793          	ori	a5,a5,2
    417c:	00f70623          	sb	a5,12(a4)
    4180:	8082                	ret
    4182:	0001                	nop
    4184:	6518                	ld	a4,8(a0)
    4186:	00c74783          	lbu	a5,12(a4)
    418a:	0fc7f793          	andi	a5,a5,252
    418e:	00f70623          	sb	a5,12(a4)
    4192:	8082                	ret
    4194:	8082                	ret
    4196:	00000013          	nop
    419a:	00000013          	nop
    419e:	0001                	nop

00000000000041a0 <ck_uart_set_stopbit>:
    41a0:	cd0c                	sw	a1,24(a0)
    41a2:	cd89                	beqz	a1,41bc <ck_uart_set_stopbit+0x1c>
    41a4:	4785                	li	a5,1
    41a6:	00f58363          	beq	a1,a5,41ac <ck_uart_set_stopbit+0xc>
    41aa:	8082                	ret
    41ac:	6518                	ld	a4,8(a0)
    41ae:	00c74783          	lbu	a5,12(a4)
    41b2:	0047e793          	ori	a5,a5,4
    41b6:	00f70623          	sb	a5,12(a4)
    41ba:	8082                	ret
    41bc:	6518                	ld	a4,8(a0)
    41be:	00c74783          	lbu	a5,12(a4)
    41c2:	0fb7f793          	andi	a5,a5,251
    41c6:	00f70623          	sb	a5,12(a4)
    41ca:	8082                	ret
    41cc:	00000013          	nop

00000000000041d0 <ck_uart_set_rxmode>:
    41d0:	d10c                	sw	a1,32(a0)
    41d2:	8082                	ret
    41d4:	00000013          	nop
    41d8:	00000013          	nop
    41dc:	00000013          	nop

00000000000041e0 <ck_uart_set_txmode>:
    41e0:	d14c                	sw	a1,36(a0)
    41e2:	8082                	ret
    41e4:	00000013          	nop
    41e8:	00000013          	nop
    41ec:	00000013          	nop

00000000000041f0 <ck_uart_open>:
    41f0:	e981                	bnez	a1,4200 <ck_uart_open+0x10>
    41f2:	100157b7          	lui	a5,0x10015
    41f6:	00052023          	sw	zero,0(a0)
    41fa:	e51c                	sd	a5,8(a0)
    41fc:	4501                	li	a0,0
    41fe:	8082                	ret
    4200:	4505                	li	a0,1
    4202:	8082                	ret
    4204:	00000013          	nop
    4208:	00000013          	nop
    420c:	00000013          	nop

0000000000004210 <ck_uart_init>:
    4210:	4114                	lw	a3,0(a0)
    4212:	6741                	lui	a4,0x10
    4214:	177d                	addi	a4,a4,-1 # ffff <_global_impure_ptr+0xa77f>
    4216:	87aa                	mv	a5,a0
    4218:	0ae68263          	beq	a3,a4,42bc <ck_uart_init+0xac>
    421c:	4190                	lw	a2,0(a1)
    421e:	05f5e737          	lui	a4,0x5f5e
    4222:	1007071b          	addiw	a4,a4,256 # 5f5e100 <__kernel_stack+0x5e70100>
    4226:	02c7573b          	divuw	a4,a4,a2
    422a:	6794                	ld	a3,8(a5)
    422c:	cb90                	sw	a2,16(a5)
    422e:	4505                	li	a0,1
    4230:	00c6c603          	lbu	a2,12(a3)
    4234:	08066613          	ori	a2,a2,128
    4238:	00c68623          	sb	a2,12(a3)
    423c:	2c47360b          	th.extu	a2,a4,11,4
    4240:	00c68023          	sb	a2,0(a3)
    4244:	4cc7370b          	th.extu	a4,a4,19,12
    4248:	00e68223          	sb	a4,4(a3)
    424c:	00c6c703          	lbu	a4,12(a3)
    4250:	07f77713          	andi	a4,a4,127
    4254:	00e68623          	sb	a4,12(a3)
    4258:	4598                	lw	a4,8(a1)
    425a:	cbd8                	sw	a4,20(a5)
    425c:	0aa70c63          	beq	a4,a0,4314 <ck_uart_init+0x104>
    4260:	4689                	li	a3,2
    4262:	0ed70d63          	beq	a4,a3,435c <ck_uart_init+0x14c>
    4266:	cf29                	beqz	a4,42c0 <ck_uart_init+0xb0>
    4268:	45d8                	lw	a4,12(a1)
    426a:	4689                	li	a3,2
    426c:	cfd8                	sw	a4,28(a5)
    426e:	06d70563          	beq	a4,a3,42d8 <ck_uart_init+0xc8>
    4272:	0ce6e963          	bltu	a3,a4,4344 <ck_uart_init+0x134>
    4276:	cf5d                	beqz	a4,4334 <ck_uart_init+0x124>
    4278:	6794                	ld	a3,8(a5)
    427a:	00c6c703          	lbu	a4,12(a3)
    427e:	0fd77713          	andi	a4,a4,253
    4282:	00e68623          	sb	a4,12(a3)
    4286:	6794                	ld	a3,8(a5)
    4288:	00c6c703          	lbu	a4,12(a3)
    428c:	00176713          	ori	a4,a4,1
    4290:	00e68623          	sb	a4,12(a3)
    4294:	41d8                	lw	a4,4(a1)
    4296:	cf98                	sw	a4,24(a5)
    4298:	c32d                	beqz	a4,42fa <ck_uart_init+0xea>
    429a:	4685                	li	a3,1
    429c:	00d71963          	bne	a4,a3,42ae <ck_uart_init+0x9e>
    42a0:	6794                	ld	a3,8(a5)
    42a2:	00c6c703          	lbu	a4,12(a3)
    42a6:	00476713          	ori	a4,a4,4
    42aa:	00e68623          	sb	a4,12(a3)
    42ae:	e4e5c68b          	th.lwd	a3,a4,(a1),2,3
    42b2:	4501                	li	a0,0
    42b4:	d394                	sw	a3,32(a5)
    42b6:	d3d8                	sw	a4,36(a5)
    42b8:	8082                	ret
    42ba:	0001                	nop
    42bc:	4505                	li	a0,1
    42be:	8082                	ret
    42c0:	6794                	ld	a3,8(a5)
    42c2:	00c6c703          	lbu	a4,12(a3)
    42c6:	0f777713          	andi	a4,a4,247
    42ca:	00e68623          	sb	a4,12(a3)
    42ce:	45d8                	lw	a4,12(a1)
    42d0:	4689                	li	a3,2
    42d2:	cfd8                	sw	a4,28(a5)
    42d4:	f8d71fe3          	bne	a4,a3,4272 <ck_uart_init+0x62>
    42d8:	6794                	ld	a3,8(a5)
    42da:	00c6c703          	lbu	a4,12(a3)
    42de:	0fe77713          	andi	a4,a4,254
    42e2:	00e68623          	sb	a4,12(a3)
    42e6:	6794                	ld	a3,8(a5)
    42e8:	00c6c703          	lbu	a4,12(a3)
    42ec:	00276713          	ori	a4,a4,2
    42f0:	00e68623          	sb	a4,12(a3)
    42f4:	41d8                	lw	a4,4(a1)
    42f6:	cf98                	sw	a4,24(a5)
    42f8:	f34d                	bnez	a4,429a <ck_uart_init+0x8a>
    42fa:	6794                	ld	a3,8(a5)
    42fc:	4501                	li	a0,0
    42fe:	00c6c703          	lbu	a4,12(a3)
    4302:	0fb77713          	andi	a4,a4,251
    4306:	00e68623          	sb	a4,12(a3)
    430a:	e4e5c68b          	th.lwd	a3,a4,(a1),2,3
    430e:	d394                	sw	a3,32(a5)
    4310:	d3d8                	sw	a4,36(a5)
    4312:	8082                	ret
    4314:	6794                	ld	a3,8(a5)
    4316:	00c6c703          	lbu	a4,12(a3)
    431a:	00876713          	ori	a4,a4,8
    431e:	00e68623          	sb	a4,12(a3)
    4322:	6794                	ld	a3,8(a5)
    4324:	00c6c703          	lbu	a4,12(a3)
    4328:	0ef77713          	andi	a4,a4,239
    432c:	00e68623          	sb	a4,12(a3)
    4330:	bf25                	j	4268 <ck_uart_init+0x58>
    4332:	0001                	nop
    4334:	6794                	ld	a3,8(a5)
    4336:	00c6c703          	lbu	a4,12(a3)
    433a:	0fc77713          	andi	a4,a4,252
    433e:	00e68623          	sb	a4,12(a3)
    4342:	bf89                	j	4294 <ck_uart_init+0x84>
    4344:	468d                	li	a3,3
    4346:	f4d717e3          	bne	a4,a3,4294 <ck_uart_init+0x84>
    434a:	6794                	ld	a3,8(a5)
    434c:	00c6c703          	lbu	a4,12(a3)
    4350:	00376713          	ori	a4,a4,3
    4354:	00e68623          	sb	a4,12(a3)
    4358:	bf35                	j	4294 <ck_uart_init+0x84>
    435a:	0001                	nop
    435c:	6794                	ld	a3,8(a5)
    435e:	00c6c703          	lbu	a4,12(a3)
    4362:	00876713          	ori	a4,a4,8
    4366:	00e68623          	sb	a4,12(a3)
    436a:	6794                	ld	a3,8(a5)
    436c:	00c6c703          	lbu	a4,12(a3)
    4370:	01076713          	ori	a4,a4,16
    4374:	00e68623          	sb	a4,12(a3)
    4378:	bdc5                	j	4268 <ck_uart_init+0x58>
    437a:	00000013          	nop
    437e:	0001                	nop

0000000000004380 <ck_uart_close>:
    4380:	67c1                	lui	a5,0x10
    4382:	17fd                	addi	a5,a5,-1 # ffff <_global_impure_ptr+0xa77f>
    4384:	c11c                	sw	a5,0(a0)
    4386:	02053023          	sd	zero,32(a0)
    438a:	4501                	li	a0,0
    438c:	8082                	ret
    438e:	0001                	nop

0000000000004390 <ck_uart_putc>:
    4390:	515c                	lw	a5,36(a0)
    4392:	cf89                	beqz	a5,43ac <ck_uart_putc+0x1c>
    4394:	6518                	ld	a4,8(a0)
    4396:	0001                	nop
    4398:	01474783          	lbu	a5,20(a4)
    439c:	0207f793          	andi	a5,a5,32
    43a0:	dfe5                	beqz	a5,4398 <ck_uart_putc+0x8>
    43a2:	00b70023          	sb	a1,0(a4)
    43a6:	4501                	li	a0,0
    43a8:	8082                	ret
    43aa:	0001                	nop
    43ac:	4505                	li	a0,1
    43ae:	8082                	ret

00000000000043b0 <ck_uart_status>:
    43b0:	4505                	li	a0,1
    43b2:	8082                	ret
	...

00000000000043d0 <vasprintf>:
    43d0:	7139                	addi	sp,sp,-64
    43d2:	f9515b0b          	th.sdd	s6,s5,(sp),0,4
    43d6:	8b2a                	mv	s6,a0
    43d8:	852e                	mv	a0,a1
    43da:	fb315a0b          	th.sdd	s4,s3,(sp),1,4
    43de:	fc91590b          	th.sdd	s2,s1,(sp),2,4
    43e2:	fe11540b          	th.sdd	s0,ra,(sp),3,4
    43e6:	8a2e                	mv	s4,a1
    43e8:	8ab2                	mv	s5,a2
    43ea:	197000ef          	jal	4d80 <strlen>
    43ee:	00150993          	addi	s3,a0,1
    43f2:	f009f993          	andi	s3,s3,-256
    43f6:	10098913          	addi	s2,s3,256
    43fa:	000b3023          	sd	zero,0(s6)
    43fe:	20098993          	addi	s3,s3,512
    4402:	0001                	nop
    4404:	00000013          	nop
    4408:	854a                	mv	a0,s2
    440a:	17c000ef          	jal	4586 <malloc>
    440e:	84aa                	mv	s1,a0
    4410:	c525                	beqz	a0,4478 <vasprintf+0xa8>
    4412:	86d6                	mv	a3,s5
    4414:	8652                	mv	a2,s4
    4416:	85ca                	mv	a1,s2
    4418:	bd9ff0ef          	jal	3ff0 <vsnprintf>
    441c:	842a                	mv	s0,a0
    441e:	00054f63          	bltz	a0,443c <vasprintf+0x6c>
    4422:	197d                	addi	s2,s2,-1
    4424:	03256463          	bltu	a0,s2,444c <vasprintf+0x7c>
    4428:	8526                	mv	a0,s1
    442a:	168000ef          	jal	4592 <free>
    442e:	01346a63          	bltu	s0,s3,4442 <vasprintf+0x72>
    4432:	0014091b          	addiw	s2,s0,1
    4436:	10098993          	addi	s3,s3,256
    443a:	b7f9                	j	4408 <vasprintf+0x38>
    443c:	8526                	mv	a0,s1
    443e:	154000ef          	jal	4592 <free>
    4442:	894e                	mv	s2,s3
    4444:	10098993          	addi	s3,s3,256
    4448:	b7c1                	j	4408 <vasprintf+0x38>
    444a:	0001                	nop
    444c:	ed01                	bnez	a0,4464 <vasprintf+0x94>
    444e:	8522                	mv	a0,s0
    4450:	fe11440b          	th.ldd	s0,ra,(sp),3,4
    4454:	fc91490b          	th.ldd	s2,s1,(sp),2,4
    4458:	fb314a0b          	th.ldd	s4,s3,(sp),1,4
    445c:	f9514b0b          	th.ldd	s6,s5,(sp),0,4
    4460:	6121                	addi	sp,sp,64
    4462:	8082                	ret
    4464:	8526                	mv	a0,s1
    4466:	0d5000ef          	jal	4d3a <strdup>
    446a:	00ab3023          	sd	a0,0(s6)
    446e:	c519                	beqz	a0,447c <vasprintf+0xac>
    4470:	8526                	mv	a0,s1
    4472:	120000ef          	jal	4592 <free>
    4476:	bfe1                	j	444e <vasprintf+0x7e>
    4478:	5451                	li	s0,-12
    447a:	bfd1                	j	444e <vasprintf+0x7e>
    447c:	009b3023          	sd	s1,0(s6)
    4480:	b7f9                	j	444e <vasprintf+0x7e>
    4482:	0001                	nop
    4484:	00000013          	nop
    4488:	00000013          	nop
    448c:	00000013          	nop

0000000000004490 <asprintf>:
    4490:	7119                	addi	sp,sp,-128
    4492:	fb515b0b          	th.sdd	s6,s5,(sp),1,4
    4496:	8b2a                	mv	s6,a0
    4498:	05010a93          	addi	s5,sp,80
    449c:	852e                	mv	a0,a1
    449e:	fd315a0b          	th.sdd	s4,s3,(sp),2,4
    44a2:	fe91590b          	th.sdd	s2,s1,(sp),3,4
    44a6:	e0a2                	sd	s0,64(sp)
    44a8:	e486                	sd	ra,72(sp)
    44aa:	e8b2                	sd	a2,80(sp)
    44ac:	ecb6                	sd	a3,88(sp)
    44ae:	f0ba                	sd	a4,96(sp)
    44b0:	f4be                	sd	a5,104(sp)
    44b2:	f8c2                	sd	a6,112(sp)
    44b4:	fcc6                	sd	a7,120(sp)
    44b6:	8a2e                	mv	s4,a1
    44b8:	e456                	sd	s5,8(sp)
    44ba:	0c7000ef          	jal	4d80 <strlen>
    44be:	00150993          	addi	s3,a0,1
    44c2:	f009f993          	andi	s3,s3,-256
    44c6:	10098913          	addi	s2,s3,256
    44ca:	000b3023          	sd	zero,0(s6)
    44ce:	20098993          	addi	s3,s3,512
    44d2:	0001                	nop
    44d4:	00000013          	nop
    44d8:	854a                	mv	a0,s2
    44da:	0ac000ef          	jal	4586 <malloc>
    44de:	84aa                	mv	s1,a0
    44e0:	c525                	beqz	a0,4548 <asprintf+0xb8>
    44e2:	86d6                	mv	a3,s5
    44e4:	8652                	mv	a2,s4
    44e6:	85ca                	mv	a1,s2
    44e8:	b09ff0ef          	jal	3ff0 <vsnprintf>
    44ec:	842a                	mv	s0,a0
    44ee:	00054f63          	bltz	a0,450c <asprintf+0x7c>
    44f2:	197d                	addi	s2,s2,-1
    44f4:	03256463          	bltu	a0,s2,451c <asprintf+0x8c>
    44f8:	8526                	mv	a0,s1
    44fa:	098000ef          	jal	4592 <free>
    44fe:	01346a63          	bltu	s0,s3,4512 <asprintf+0x82>
    4502:	0014091b          	addiw	s2,s0,1
    4506:	10098993          	addi	s3,s3,256
    450a:	b7f9                	j	44d8 <asprintf+0x48>
    450c:	8526                	mv	a0,s1
    450e:	084000ef          	jal	4592 <free>
    4512:	894e                	mv	s2,s3
    4514:	10098993          	addi	s3,s3,256
    4518:	b7c1                	j	44d8 <asprintf+0x48>
    451a:	0001                	nop
    451c:	ed01                	bnez	a0,4534 <asprintf+0xa4>
    451e:	8522                	mv	a0,s0
    4520:	6406                	ld	s0,64(sp)
    4522:	60a6                	ld	ra,72(sp)
    4524:	fe91490b          	th.ldd	s2,s1,(sp),3,4
    4528:	fd314a0b          	th.ldd	s4,s3,(sp),2,4
    452c:	fb514b0b          	th.ldd	s6,s5,(sp),1,4
    4530:	6109                	addi	sp,sp,128
    4532:	8082                	ret
    4534:	8526                	mv	a0,s1
    4536:	005000ef          	jal	4d3a <strdup>
    453a:	00ab3023          	sd	a0,0(s6)
    453e:	c519                	beqz	a0,454c <asprintf+0xbc>
    4540:	8526                	mv	a0,s1
    4542:	050000ef          	jal	4592 <free>
    4546:	bfe1                	j	451e <asprintf+0x8e>
    4548:	5451                	li	s0,-12
    454a:	bfd1                	j	451e <asprintf+0x8e>
    454c:	009b3023          	sd	s1,0(s6)
    4550:	b7f9                	j	451e <asprintf+0x8e>
	...

0000000000004560 <get_vtimer>:
    4560:	1141                	addi	sp,sp,-16
    4562:	c01027f3          	rdtime	a5
    4566:	c63e                	sw	a5,12(sp)
    4568:	4532                	lw	a0,12(sp)
    456a:	0141                	addi	sp,sp,16
    456c:	8082                	ret
    456e:	0001                	nop

0000000000004570 <sim_end>:
    4570:	050017b7          	lui	a5,0x5001
    4574:	44333737          	lui	a4,0x44333
    4578:	0796                	slli	a5,a5,0x5
    457a:	22270713          	addi	a4,a4,546 # 44333222 <__kernel_stack+0x44245222>
    457e:	f4e7a423          	sw	a4,-184(a5) # 5000f48 <__kernel_stack+0x4f12f48>
    4582:	8082                	ret
	...

0000000000004586 <malloc>:
    4586:	85aa                	mv	a1,a0
    4588:	0003d517          	auipc	a0,0x3d
    458c:	a0053503          	ld	a0,-1536(a0) # 40f88 <_impure_ptr>
    4590:	a801                	j	45a0 <_malloc_r>

0000000000004592 <free>:
    4592:	85aa                	mv	a1,a0
    4594:	0003d517          	auipc	a0,0x3d
    4598:	9f453503          	ld	a0,-1548(a0) # 40f88 <_impure_ptr>
    459c:	15d0006f          	j	4ef8 <_free_r>

00000000000045a0 <_malloc_r>:
    45a0:	711d                	addi	sp,sp,-96
    45a2:	e4a6                	sd	s1,72(sp)
    45a4:	e0ca                	sd	s2,64(sp)
    45a6:	ec86                	sd	ra,88(sp)
    45a8:	e8a2                	sd	s0,80(sp)
    45aa:	fc4e                	sd	s3,56(sp)
    45ac:	01758493          	addi	s1,a1,23
    45b0:	02e00793          	li	a5,46
    45b4:	892a                	mv	s2,a0
    45b6:	0497ec63          	bltu	a5,s1,460e <_malloc_r+0x6e>
    45ba:	02000493          	li	s1,32
    45be:	18b4eb63          	bltu	s1,a1,4754 <_malloc_r+0x1b4>
    45c2:	63c000ef          	jal	4bfe <__malloc_lock>
    45c6:	05000793          	li	a5,80
    45ca:	4591                	li	a1,4
    45cc:	0003c997          	auipc	s3,0x3c
    45d0:	a3c98993          	addi	s3,s3,-1476 # 40008 <__malloc_av_>
    45d4:	97ce                	add	a5,a5,s3
    45d6:	6780                	ld	s0,8(a5)
    45d8:	ff078713          	addi	a4,a5,-16
    45dc:	34e40b63          	beq	s0,a4,4932 <_malloc_r+0x392>
    45e0:	641c                	ld	a5,8(s0)
    45e2:	6c14                	ld	a3,24(s0)
    45e4:	6810                	ld	a2,16(s0)
    45e6:	9bf1                	andi	a5,a5,-4
    45e8:	97a2                	add	a5,a5,s0
    45ea:	6798                	ld	a4,8(a5)
    45ec:	ee14                	sd	a3,24(a2)
    45ee:	ea90                	sd	a2,16(a3)
    45f0:	00176713          	ori	a4,a4,1
    45f4:	854a                	mv	a0,s2
    45f6:	e798                	sd	a4,8(a5)
    45f8:	612000ef          	jal	4c0a <__malloc_unlock>
    45fc:	60e6                	ld	ra,88(sp)
    45fe:	01040513          	addi	a0,s0,16
    4602:	6446                	ld	s0,80(sp)
    4604:	64a6                	ld	s1,72(sp)
    4606:	6906                	ld	s2,64(sp)
    4608:	79e2                	ld	s3,56(sp)
    460a:	6125                	addi	sp,sp,96
    460c:	8082                	ret
    460e:	800007b7          	lui	a5,0x80000
    4612:	98c1                	andi	s1,s1,-16
    4614:	fff7c793          	not	a5,a5
    4618:	1297ee63          	bltu	a5,s1,4754 <_malloc_r+0x1b4>
    461c:	12b4ec63          	bltu	s1,a1,4754 <_malloc_r+0x1b4>
    4620:	5de000ef          	jal	4bfe <__malloc_lock>
    4624:	1f700793          	li	a5,503
    4628:	4097f063          	bgeu	a5,s1,4a28 <_malloc_r+0x488>
    462c:	0094d793          	srli	a5,s1,0x9
    4630:	12078d63          	beqz	a5,476a <_malloc_r+0x1ca>
    4634:	4711                	li	a4,4
    4636:	34f76563          	bltu	a4,a5,4980 <_malloc_r+0x3e0>
    463a:	0064d793          	srli	a5,s1,0x6
    463e:	0397859b          	addiw	a1,a5,57 # ffffffff80000039 <__kernel_stack+0xffffffff7ff12039>
    4642:	0015961b          	slliw	a2,a1,0x1
    4646:	0387881b          	addiw	a6,a5,56
    464a:	060e                	slli	a2,a2,0x3
    464c:	0003c997          	auipc	s3,0x3c
    4650:	9bc98993          	addi	s3,s3,-1604 # 40008 <__malloc_av_>
    4654:	964e                	add	a2,a2,s3
    4656:	6600                	ld	s0,8(a2)
    4658:	1641                	addi	a2,a2,-16
    465a:	02860163          	beq	a2,s0,467c <_malloc_r+0xdc>
    465e:	457d                	li	a0,31
    4660:	a039                	j	466e <_malloc_r+0xce>
    4662:	6c14                	ld	a3,24(s0)
    4664:	2a075363          	bgez	a4,490a <_malloc_r+0x36a>
    4668:	00d60a63          	beq	a2,a3,467c <_malloc_r+0xdc>
    466c:	8436                	mv	s0,a3
    466e:	641c                	ld	a5,8(s0)
    4670:	9bf1                	andi	a5,a5,-4
    4672:	40978733          	sub	a4,a5,s1
    4676:	fee556e3          	bge	a0,a4,4662 <_malloc_r+0xc2>
    467a:	85c2                	mv	a1,a6
    467c:	0209b403          	ld	s0,32(s3)
    4680:	0003c897          	auipc	a7,0x3c
    4684:	99888893          	addi	a7,a7,-1640 # 40018 <__malloc_av_+0x10>
    4688:	27140e63          	beq	s0,a7,4904 <_malloc_r+0x364>
    468c:	641c                	ld	a5,8(s0)
    468e:	46fd                	li	a3,31
    4690:	9bf1                	andi	a5,a5,-4
    4692:	40978733          	sub	a4,a5,s1
    4696:	36e6c263          	blt	a3,a4,49fa <_malloc_r+0x45a>
    469a:	0319b423          	sd	a7,40(s3)
    469e:	0319b023          	sd	a7,32(s3)
    46a2:	34075163          	bgez	a4,49e4 <_malloc_r+0x444>
    46a6:	1ff00713          	li	a4,511
    46aa:	0089b503          	ld	a0,8(s3)
    46ae:	28f76763          	bltu	a4,a5,493c <_malloc_r+0x39c>
    46b2:	838d                	srli	a5,a5,0x3
    46b4:	2781                	sext.w	a5,a5
    46b6:	0017871b          	addiw	a4,a5,1
    46ba:	0017171b          	slliw	a4,a4,0x1
    46be:	070e                	slli	a4,a4,0x3
    46c0:	974e                	add	a4,a4,s3
    46c2:	6310                	ld	a2,0(a4)
    46c4:	4027d79b          	sraiw	a5,a5,0x2
    46c8:	4685                	li	a3,1
    46ca:	00f697b3          	sll	a5,a3,a5
    46ce:	8d5d                	or	a0,a0,a5
    46d0:	ff070793          	addi	a5,a4,-16
    46d4:	e810                	sd	a2,16(s0)
    46d6:	ec1c                	sd	a5,24(s0)
    46d8:	00a9b423          	sd	a0,8(s3)
    46dc:	e300                	sd	s0,0(a4)
    46de:	ee00                	sd	s0,24(a2)
    46e0:	4025d79b          	sraiw	a5,a1,0x2
    46e4:	4605                	li	a2,1
    46e6:	00f61633          	sll	a2,a2,a5
    46ea:	08c56763          	bltu	a0,a2,4778 <_malloc_r+0x1d8>
    46ee:	00a677b3          	and	a5,a2,a0
    46f2:	ef81                	bnez	a5,470a <_malloc_r+0x16a>
    46f4:	0606                	slli	a2,a2,0x1
    46f6:	99f1                	andi	a1,a1,-4
    46f8:	00a677b3          	and	a5,a2,a0
    46fc:	2591                	addiw	a1,a1,4
    46fe:	e791                	bnez	a5,470a <_malloc_r+0x16a>
    4700:	0606                	slli	a2,a2,0x1
    4702:	00a677b3          	and	a5,a2,a0
    4706:	2591                	addiw	a1,a1,4
    4708:	dfe5                	beqz	a5,4700 <_malloc_r+0x160>
    470a:	487d                	li	a6,31
    470c:	0015831b          	addiw	t1,a1,1
    4710:	0013131b          	slliw	t1,t1,0x1
    4714:	030e                	slli	t1,t1,0x3
    4716:	1341                	addi	t1,t1,-16
    4718:	934e                	add	t1,t1,s3
    471a:	851a                	mv	a0,t1
    471c:	6d1c                	ld	a5,24(a0)
    471e:	8e2e                	mv	t3,a1
    4720:	28f50163          	beq	a0,a5,49a2 <_malloc_r+0x402>
    4724:	6798                	ld	a4,8(a5)
    4726:	843e                	mv	s0,a5
    4728:	6f9c                	ld	a5,24(a5)
    472a:	9b71                	andi	a4,a4,-4
    472c:	409706b3          	sub	a3,a4,s1
    4730:	28d84063          	blt	a6,a3,49b0 <_malloc_r+0x410>
    4734:	fe06c6e3          	bltz	a3,4720 <_malloc_r+0x180>
    4738:	9722                	add	a4,a4,s0
    473a:	6714                	ld	a3,8(a4)
    473c:	6810                	ld	a2,16(s0)
    473e:	854a                	mv	a0,s2
    4740:	0016e693          	ori	a3,a3,1
    4744:	e714                	sd	a3,8(a4)
    4746:	ee1c                	sd	a5,24(a2)
    4748:	eb90                	sd	a2,16(a5)
    474a:	4c0000ef          	jal	4c0a <__malloc_unlock>
    474e:	01040513          	addi	a0,s0,16
    4752:	a029                	j	475c <_malloc_r+0x1bc>
    4754:	47b1                	li	a5,12
    4756:	00f92023          	sw	a5,0(s2)
    475a:	4501                	li	a0,0
    475c:	60e6                	ld	ra,88(sp)
    475e:	6446                	ld	s0,80(sp)
    4760:	64a6                	ld	s1,72(sp)
    4762:	6906                	ld	s2,64(sp)
    4764:	79e2                	ld	s3,56(sp)
    4766:	6125                	addi	sp,sp,96
    4768:	8082                	ret
    476a:	40000613          	li	a2,1024
    476e:	04000593          	li	a1,64
    4772:	03f00813          	li	a6,63
    4776:	bdd9                	j	464c <_malloc_r+0xac>
    4778:	0109b403          	ld	s0,16(s3)
    477c:	f456                	sd	s5,40(sp)
    477e:	641c                	ld	a5,8(s0)
    4780:	ffc7fa93          	andi	s5,a5,-4
    4784:	009ae763          	bltu	s5,s1,4792 <_malloc_r+0x1f2>
    4788:	409a8733          	sub	a4,s5,s1
    478c:	47fd                	li	a5,31
    478e:	14e7c563          	blt	a5,a4,48d8 <_malloc_r+0x338>
    4792:	e862                	sd	s8,16(sp)
    4794:	0003cc17          	auipc	s8,0x3c
    4798:	7e4c0c13          	addi	s8,s8,2020 # 40f78 <__malloc_sbrk_base>
    479c:	f852                	sd	s4,48(sp)
    479e:	000c3703          	ld	a4,0(s8)
    47a2:	0003fa17          	auipc	s4,0x3f
    47a6:	0bea3a03          	ld	s4,190(s4) # 43860 <__malloc_top_pad>
    47aa:	ec5e                	sd	s7,24(sp)
    47ac:	f05a                	sd	s6,32(sp)
    47ae:	57fd                	li	a5,-1
    47b0:	01540bb3          	add	s7,s0,s5
    47b4:	9a26                	add	s4,s4,s1
    47b6:	2ef70f63          	beq	a4,a5,4ab4 <_malloc_r+0x514>
    47ba:	6785                	lui	a5,0x1
    47bc:	07fd                	addi	a5,a5,31 # 101f <_ftoa+0x23f>
    47be:	9a3e                	add	s4,s4,a5
    47c0:	77fd                	lui	a5,0xfffff
    47c2:	00fa7a33          	and	s4,s4,a5
    47c6:	85d2                	mv	a1,s4
    47c8:	854a                	mv	a0,s2
    47ca:	44c000ef          	jal	4c16 <_sbrk_r>
    47ce:	57fd                	li	a5,-1
    47d0:	8b2a                	mv	s6,a0
    47d2:	38f50363          	beq	a0,a5,4b58 <_malloc_r+0x5b8>
    47d6:	e466                	sd	s9,8(sp)
    47d8:	0d756e63          	bltu	a0,s7,48b4 <_malloc_r+0x314>
    47dc:	0003f717          	auipc	a4,0x3f
    47e0:	04c72703          	lw	a4,76(a4) # 43828 <__malloc_current_mallinfo>
    47e4:	0003fc97          	auipc	s9,0x3f
    47e8:	044c8c93          	addi	s9,s9,68 # 43828 <__malloc_current_mallinfo>
    47ec:	0147073b          	addw	a4,a4,s4
    47f0:	00eca023          	sw	a4,0(s9)
    47f4:	86ba                	mv	a3,a4
    47f6:	36ab8563          	beq	s7,a0,4b60 <_malloc_r+0x5c0>
    47fa:	000c3703          	ld	a4,0(s8)
    47fe:	57fd                	li	a5,-1
    4800:	36f70d63          	beq	a4,a5,4b7a <_malloc_r+0x5da>
    4804:	417b07b3          	sub	a5,s6,s7
    4808:	9fb5                	addw	a5,a5,a3
    480a:	00fca023          	sw	a5,0(s9)
    480e:	00fb7c13          	andi	s8,s6,15
    4812:	2a0c0d63          	beqz	s8,4acc <_malloc_r+0x52c>
    4816:	418b0b33          	sub	s6,s6,s8
    481a:	6685                	lui	a3,0x1
    481c:	0b41                	addi	s6,s6,16
    481e:	06c1                	addi	a3,a3,16 # 1010 <_ftoa+0x230>
    4820:	9a5a                	add	s4,s4,s6
    4822:	418686b3          	sub	a3,a3,s8
    4826:	414686b3          	sub	a3,a3,s4
    482a:	16d2                	slli	a3,a3,0x34
    482c:	0346db93          	srli	s7,a3,0x34
    4830:	85de                	mv	a1,s7
    4832:	854a                	mv	a0,s2
    4834:	3e2000ef          	jal	4c16 <_sbrk_r>
    4838:	57fd                	li	a5,-1
    483a:	36f50f63          	beq	a0,a5,4bb8 <_malloc_r+0x618>
    483e:	41650533          	sub	a0,a0,s6
    4842:	01750a33          	add	s4,a0,s7
    4846:	000b869b          	sext.w	a3,s7
    484a:	0003f717          	auipc	a4,0x3f
    484e:	fde72703          	lw	a4,-34(a4) # 43828 <__malloc_current_mallinfo>
    4852:	0169b823          	sd	s6,16(s3)
    4856:	001a6793          	ori	a5,s4,1
    485a:	9f35                	addw	a4,a4,a3
    485c:	00fb3423          	sd	a5,8(s6)
    4860:	00eca023          	sw	a4,0(s9)
    4864:	03340563          	beq	s0,s3,488e <_malloc_r+0x2ee>
    4868:	467d                	li	a2,31
    486a:	29567163          	bgeu	a2,s5,4aec <_malloc_r+0x54c>
    486e:	6414                	ld	a3,8(s0)
    4870:	fe8a8793          	addi	a5,s5,-24
    4874:	9bc1                	andi	a5,a5,-16
    4876:	8a85                	andi	a3,a3,1
    4878:	8edd                	or	a3,a3,a5
    487a:	e414                	sd	a3,8(s0)
    487c:	45a5                	li	a1,9
    487e:	00f406b3          	add	a3,s0,a5
    4882:	e68c                	sd	a1,8(a3)
    4884:	ea8c                	sd	a1,16(a3)
    4886:	20f66b63          	bltu	a2,a5,4a9c <_malloc_r+0x4fc>
    488a:	008b3783          	ld	a5,8(s6)
    488e:	0003f697          	auipc	a3,0x3f
    4892:	fca68693          	addi	a3,a3,-54 # 43858 <__malloc_max_sbrked_mem>
    4896:	6290                	ld	a2,0(a3)
    4898:	00e67363          	bgeu	a2,a4,489e <_malloc_r+0x2fe>
    489c:	e298                	sd	a4,0(a3)
    489e:	0003f697          	auipc	a3,0x3f
    48a2:	fb268693          	addi	a3,a3,-78 # 43850 <__malloc_max_total_mem>
    48a6:	6290                	ld	a2,0(a3)
    48a8:	00e67363          	bgeu	a2,a4,48ae <_malloc_r+0x30e>
    48ac:	e298                	sd	a4,0(a3)
    48ae:	6ca2                	ld	s9,8(sp)
    48b0:	845a                	mv	s0,s6
    48b2:	a039                	j	48c0 <_malloc_r+0x320>
    48b4:	29340563          	beq	s0,s3,4b3e <_malloc_r+0x59e>
    48b8:	0109b403          	ld	s0,16(s3)
    48bc:	6ca2                	ld	s9,8(sp)
    48be:	641c                	ld	a5,8(s0)
    48c0:	9bf1                	andi	a5,a5,-4
    48c2:	40978733          	sub	a4,a5,s1
    48c6:	2297e763          	bltu	a5,s1,4af4 <_malloc_r+0x554>
    48ca:	47fd                	li	a5,31
    48cc:	22e7d463          	bge	a5,a4,4af4 <_malloc_r+0x554>
    48d0:	7a42                	ld	s4,48(sp)
    48d2:	7b02                	ld	s6,32(sp)
    48d4:	6be2                	ld	s7,24(sp)
    48d6:	6c42                	ld	s8,16(sp)
    48d8:	0014e793          	ori	a5,s1,1
    48dc:	e41c                	sd	a5,8(s0)
    48de:	94a2                	add	s1,s1,s0
    48e0:	0099b823          	sd	s1,16(s3)
    48e4:	00176713          	ori	a4,a4,1
    48e8:	854a                	mv	a0,s2
    48ea:	e498                	sd	a4,8(s1)
    48ec:	31e000ef          	jal	4c0a <__malloc_unlock>
    48f0:	60e6                	ld	ra,88(sp)
    48f2:	01040513          	addi	a0,s0,16
    48f6:	6446                	ld	s0,80(sp)
    48f8:	7aa2                	ld	s5,40(sp)
    48fa:	64a6                	ld	s1,72(sp)
    48fc:	6906                	ld	s2,64(sp)
    48fe:	79e2                	ld	s3,56(sp)
    4900:	6125                	addi	sp,sp,96
    4902:	8082                	ret
    4904:	0089b503          	ld	a0,8(s3)
    4908:	bbe1                	j	46e0 <_malloc_r+0x140>
    490a:	6810                	ld	a2,16(s0)
    490c:	97a2                	add	a5,a5,s0
    490e:	6798                	ld	a4,8(a5)
    4910:	ee14                	sd	a3,24(a2)
    4912:	ea90                	sd	a2,16(a3)
    4914:	00176713          	ori	a4,a4,1
    4918:	854a                	mv	a0,s2
    491a:	e798                	sd	a4,8(a5)
    491c:	2ee000ef          	jal	4c0a <__malloc_unlock>
    4920:	60e6                	ld	ra,88(sp)
    4922:	01040513          	addi	a0,s0,16
    4926:	6446                	ld	s0,80(sp)
    4928:	64a6                	ld	s1,72(sp)
    492a:	6906                	ld	s2,64(sp)
    492c:	79e2                	ld	s3,56(sp)
    492e:	6125                	addi	sp,sp,96
    4930:	8082                	ret
    4932:	6f80                	ld	s0,24(a5)
    4934:	2589                	addiw	a1,a1,2
    4936:	d48783e3          	beq	a5,s0,467c <_malloc_r+0xdc>
    493a:	b15d                	j	45e0 <_malloc_r+0x40>
    493c:	0097d713          	srli	a4,a5,0x9
    4940:	4691                	li	a3,4
    4942:	0ee6fc63          	bgeu	a3,a4,4a3a <_malloc_r+0x49a>
    4946:	46d1                	li	a3,20
    4948:	1ae6ef63          	bltu	a3,a4,4b06 <_malloc_r+0x566>
    494c:	05c7061b          	addiw	a2,a4,92
    4950:	0016161b          	slliw	a2,a2,0x1
    4954:	060e                	slli	a2,a2,0x3
    4956:	05b7069b          	addiw	a3,a4,91
    495a:	964e                	add	a2,a2,s3
    495c:	6218                	ld	a4,0(a2)
    495e:	1641                	addi	a2,a2,-16
    4960:	00e61663          	bne	a2,a4,496c <_malloc_r+0x3cc>
    4964:	aa99                	j	4aba <_malloc_r+0x51a>
    4966:	6b18                	ld	a4,16(a4)
    4968:	00e60663          	beq	a2,a4,4974 <_malloc_r+0x3d4>
    496c:	6714                	ld	a3,8(a4)
    496e:	9af1                	andi	a3,a3,-4
    4970:	fed7ebe3          	bltu	a5,a3,4966 <_malloc_r+0x3c6>
    4974:	6f10                	ld	a2,24(a4)
    4976:	ec10                	sd	a2,24(s0)
    4978:	e818                	sd	a4,16(s0)
    497a:	ea00                	sd	s0,16(a2)
    497c:	ef00                	sd	s0,24(a4)
    497e:	b38d                	j	46e0 <_malloc_r+0x140>
    4980:	4751                	li	a4,20
    4982:	0cf77663          	bgeu	a4,a5,4a4e <_malloc_r+0x4ae>
    4986:	05400713          	li	a4,84
    498a:	18f76c63          	bltu	a4,a5,4b22 <_malloc_r+0x582>
    498e:	00c4d793          	srli	a5,s1,0xc
    4992:	06f7859b          	addiw	a1,a5,111 # fffffffffffff06f <__kernel_stack+0xfffffffffff1106f>
    4996:	0015961b          	slliw	a2,a1,0x1
    499a:	06e7881b          	addiw	a6,a5,110
    499e:	060e                	slli	a2,a2,0x3
    49a0:	b175                	j	464c <_malloc_r+0xac>
    49a2:	2e05                	addiw	t3,t3,1
    49a4:	003e7793          	andi	a5,t3,3
    49a8:	0541                	addi	a0,a0,16
    49aa:	cfdd                	beqz	a5,4a68 <_malloc_r+0x4c8>
    49ac:	6d1c                	ld	a5,24(a0)
    49ae:	bb8d                	j	4720 <_malloc_r+0x180>
    49b0:	6810                	ld	a2,16(s0)
    49b2:	0014e593          	ori	a1,s1,1
    49b6:	e40c                	sd	a1,8(s0)
    49b8:	ee1c                	sd	a5,24(a2)
    49ba:	eb90                	sd	a2,16(a5)
    49bc:	94a2                	add	s1,s1,s0
    49be:	0299b423          	sd	s1,40(s3)
    49c2:	0299b023          	sd	s1,32(s3)
    49c6:	0016e793          	ori	a5,a3,1
    49ca:	9722                	add	a4,a4,s0
    49cc:	0114bc23          	sd	a7,24(s1)
    49d0:	0114b823          	sd	a7,16(s1)
    49d4:	e49c                	sd	a5,8(s1)
    49d6:	854a                	mv	a0,s2
    49d8:	e314                	sd	a3,0(a4)
    49da:	230000ef          	jal	4c0a <__malloc_unlock>
    49de:	01040513          	addi	a0,s0,16
    49e2:	bbad                	j	475c <_malloc_r+0x1bc>
    49e4:	97a2                	add	a5,a5,s0
    49e6:	6798                	ld	a4,8(a5)
    49e8:	854a                	mv	a0,s2
    49ea:	00176713          	ori	a4,a4,1
    49ee:	e798                	sd	a4,8(a5)
    49f0:	21a000ef          	jal	4c0a <__malloc_unlock>
    49f4:	01040513          	addi	a0,s0,16
    49f8:	b395                	j	475c <_malloc_r+0x1bc>
    49fa:	0014e693          	ori	a3,s1,1
    49fe:	e414                	sd	a3,8(s0)
    4a00:	94a2                	add	s1,s1,s0
    4a02:	0299b423          	sd	s1,40(s3)
    4a06:	0299b023          	sd	s1,32(s3)
    4a0a:	00176693          	ori	a3,a4,1
    4a0e:	97a2                	add	a5,a5,s0
    4a10:	0114bc23          	sd	a7,24(s1)
    4a14:	0114b823          	sd	a7,16(s1)
    4a18:	e494                	sd	a3,8(s1)
    4a1a:	854a                	mv	a0,s2
    4a1c:	e398                	sd	a4,0(a5)
    4a1e:	1ec000ef          	jal	4c0a <__malloc_unlock>
    4a22:	01040513          	addi	a0,s0,16
    4a26:	bb1d                	j	475c <_malloc_r+0x1bc>
    4a28:	0034d593          	srli	a1,s1,0x3
    4a2c:	0015879b          	addiw	a5,a1,1
    4a30:	0017979b          	slliw	a5,a5,0x1
    4a34:	078e                	slli	a5,a5,0x3
    4a36:	2581                	sext.w	a1,a1
    4a38:	be51                	j	45cc <_malloc_r+0x2c>
    4a3a:	0067d713          	srli	a4,a5,0x6
    4a3e:	0397061b          	addiw	a2,a4,57
    4a42:	0016161b          	slliw	a2,a2,0x1
    4a46:	060e                	slli	a2,a2,0x3
    4a48:	0387069b          	addiw	a3,a4,56
    4a4c:	b739                	j	495a <_malloc_r+0x3ba>
    4a4e:	05c7859b          	addiw	a1,a5,92
    4a52:	0015961b          	slliw	a2,a1,0x1
    4a56:	05b7881b          	addiw	a6,a5,91
    4a5a:	060e                	slli	a2,a2,0x3
    4a5c:	bec5                	j	464c <_malloc_r+0xac>
    4a5e:	01033783          	ld	a5,16(t1)
    4a62:	35fd                	addiw	a1,a1,-1
    4a64:	18679a63          	bne	a5,t1,4bf8 <_malloc_r+0x658>
    4a68:	0035f793          	andi	a5,a1,3
    4a6c:	1341                	addi	t1,t1,-16
    4a6e:	fbe5                	bnez	a5,4a5e <_malloc_r+0x4be>
    4a70:	0089b703          	ld	a4,8(s3)
    4a74:	fff64793          	not	a5,a2
    4a78:	8ff9                	and	a5,a5,a4
    4a7a:	00f9b423          	sd	a5,8(s3)
    4a7e:	0606                	slli	a2,a2,0x1
    4a80:	cec7ece3          	bltu	a5,a2,4778 <_malloc_r+0x1d8>
    4a84:	ce060ae3          	beqz	a2,4778 <_malloc_r+0x1d8>
    4a88:	00f67733          	and	a4,a2,a5
    4a8c:	e711                	bnez	a4,4a98 <_malloc_r+0x4f8>
    4a8e:	0606                	slli	a2,a2,0x1
    4a90:	00f67733          	and	a4,a2,a5
    4a94:	2e11                	addiw	t3,t3,4
    4a96:	df65                	beqz	a4,4a8e <_malloc_r+0x4ee>
    4a98:	85f2                	mv	a1,t3
    4a9a:	b98d                	j	470c <_malloc_r+0x16c>
    4a9c:	01040593          	addi	a1,s0,16
    4aa0:	854a                	mv	a0,s2
    4aa2:	456000ef          	jal	4ef8 <_free_r>
    4aa6:	0003f717          	auipc	a4,0x3f
    4aaa:	d8272703          	lw	a4,-638(a4) # 43828 <__malloc_current_mallinfo>
    4aae:	0109bb03          	ld	s6,16(s3)
    4ab2:	bbe1                	j	488a <_malloc_r+0x2ea>
    4ab4:	020a0a13          	addi	s4,s4,32
    4ab8:	b339                	j	47c6 <_malloc_r+0x226>
    4aba:	4026d69b          	sraiw	a3,a3,0x2
    4abe:	4785                	li	a5,1
    4ac0:	00d797b3          	sll	a5,a5,a3
    4ac4:	8d5d                	or	a0,a0,a5
    4ac6:	00a9b423          	sd	a0,8(s3)
    4aca:	b575                	j	4976 <_malloc_r+0x3d6>
    4acc:	014b0bb3          	add	s7,s6,s4
    4ad0:	41700bb3          	neg	s7,s7
    4ad4:	1bd2                	slli	s7,s7,0x34
    4ad6:	034bdb93          	srli	s7,s7,0x34
    4ada:	85de                	mv	a1,s7
    4adc:	854a                	mv	a0,s2
    4ade:	138000ef          	jal	4c16 <_sbrk_r>
    4ae2:	57fd                	li	a5,-1
    4ae4:	4681                	li	a3,0
    4ae6:	d4f51ce3          	bne	a0,a5,483e <_malloc_r+0x29e>
    4aea:	b385                	j	484a <_malloc_r+0x2aa>
    4aec:	6ca2                	ld	s9,8(sp)
    4aee:	4785                	li	a5,1
    4af0:	00fb3423          	sd	a5,8(s6)
    4af4:	854a                	mv	a0,s2
    4af6:	114000ef          	jal	4c0a <__malloc_unlock>
    4afa:	7a42                	ld	s4,48(sp)
    4afc:	7aa2                	ld	s5,40(sp)
    4afe:	7b02                	ld	s6,32(sp)
    4b00:	6be2                	ld	s7,24(sp)
    4b02:	6c42                	ld	s8,16(sp)
    4b04:	b999                	j	475a <_malloc_r+0x1ba>
    4b06:	05400693          	li	a3,84
    4b0a:	06e6eb63          	bltu	a3,a4,4b80 <_malloc_r+0x5e0>
    4b0e:	00c7d713          	srli	a4,a5,0xc
    4b12:	06f7061b          	addiw	a2,a4,111
    4b16:	0016161b          	slliw	a2,a2,0x1
    4b1a:	060e                	slli	a2,a2,0x3
    4b1c:	06e7069b          	addiw	a3,a4,110
    4b20:	bd2d                	j	495a <_malloc_r+0x3ba>
    4b22:	15400713          	li	a4,340
    4b26:	06f76b63          	bltu	a4,a5,4b9c <_malloc_r+0x5fc>
    4b2a:	00f4d793          	srli	a5,s1,0xf
    4b2e:	0787859b          	addiw	a1,a5,120
    4b32:	0015961b          	slliw	a2,a1,0x1
    4b36:	0777881b          	addiw	a6,a5,119
    4b3a:	060e                	slli	a2,a2,0x3
    4b3c:	be01                	j	464c <_malloc_r+0xac>
    4b3e:	0003f697          	auipc	a3,0x3f
    4b42:	cea6a683          	lw	a3,-790(a3) # 43828 <__malloc_current_mallinfo>
    4b46:	0003fc97          	auipc	s9,0x3f
    4b4a:	ce2c8c93          	addi	s9,s9,-798 # 43828 <__malloc_current_mallinfo>
    4b4e:	014686bb          	addw	a3,a3,s4
    4b52:	00dca023          	sw	a3,0(s9)
    4b56:	b155                	j	47fa <_malloc_r+0x25a>
    4b58:	0109b403          	ld	s0,16(s3)
    4b5c:	641c                	ld	a5,8(s0)
    4b5e:	b38d                	j	48c0 <_malloc_r+0x320>
    4b60:	03451793          	slli	a5,a0,0x34
    4b64:	c8079be3          	bnez	a5,47fa <_malloc_r+0x25a>
    4b68:	0109bb03          	ld	s6,16(s3)
    4b6c:	014a87b3          	add	a5,s5,s4
    4b70:	0017e793          	ori	a5,a5,1
    4b74:	00fb3423          	sd	a5,8(s6)
    4b78:	bb19                	j	488e <_malloc_r+0x2ee>
    4b7a:	016c3023          	sd	s6,0(s8)
    4b7e:	b941                	j	480e <_malloc_r+0x26e>
    4b80:	15400693          	li	a3,340
    4b84:	04e6e063          	bltu	a3,a4,4bc4 <_malloc_r+0x624>
    4b88:	00f7d713          	srli	a4,a5,0xf
    4b8c:	0787061b          	addiw	a2,a4,120
    4b90:	0016161b          	slliw	a2,a2,0x1
    4b94:	060e                	slli	a2,a2,0x3
    4b96:	0777069b          	addiw	a3,a4,119
    4b9a:	b3c1                	j	495a <_malloc_r+0x3ba>
    4b9c:	55400713          	li	a4,1364
    4ba0:	04f76063          	bltu	a4,a5,4be0 <_malloc_r+0x640>
    4ba4:	0124d793          	srli	a5,s1,0x12
    4ba8:	07d7859b          	addiw	a1,a5,125
    4bac:	0015961b          	slliw	a2,a1,0x1
    4bb0:	07c7881b          	addiw	a6,a5,124
    4bb4:	060e                	slli	a2,a2,0x3
    4bb6:	bc59                	j	464c <_malloc_r+0xac>
    4bb8:	1c41                	addi	s8,s8,-16
    4bba:	9a62                	add	s4,s4,s8
    4bbc:	416a0a33          	sub	s4,s4,s6
    4bc0:	4681                	li	a3,0
    4bc2:	b161                	j	484a <_malloc_r+0x2aa>
    4bc4:	55400693          	li	a3,1364
    4bc8:	02e6e363          	bltu	a3,a4,4bee <_malloc_r+0x64e>
    4bcc:	0127d713          	srli	a4,a5,0x12
    4bd0:	07d7061b          	addiw	a2,a4,125
    4bd4:	0016161b          	slliw	a2,a2,0x1
    4bd8:	060e                	slli	a2,a2,0x3
    4bda:	07c7069b          	addiw	a3,a4,124
    4bde:	bbb5                	j	495a <_malloc_r+0x3ba>
    4be0:	7f000613          	li	a2,2032
    4be4:	07f00593          	li	a1,127
    4be8:	07e00813          	li	a6,126
    4bec:	b485                	j	464c <_malloc_r+0xac>
    4bee:	7f000613          	li	a2,2032
    4bf2:	07e00693          	li	a3,126
    4bf6:	b395                	j	495a <_malloc_r+0x3ba>
    4bf8:	0089b783          	ld	a5,8(s3)
    4bfc:	b549                	j	4a7e <_malloc_r+0x4de>

0000000000004bfe <__malloc_lock>:
    4bfe:	0003f517          	auipc	a0,0x3f
    4c02:	c8a50513          	addi	a0,a0,-886 # 43888 <__lock___malloc_recursive_mutex>
    4c06:	5460006f          	j	514c <__retarget_lock_acquire_recursive>

0000000000004c0a <__malloc_unlock>:
    4c0a:	0003f517          	auipc	a0,0x3f
    4c0e:	c7e50513          	addi	a0,a0,-898 # 43888 <__lock___malloc_recursive_mutex>
    4c12:	5460006f          	j	5158 <__retarget_lock_release_recursive>

0000000000004c16 <_sbrk_r>:
    4c16:	1141                	addi	sp,sp,-16
    4c18:	e022                	sd	s0,0(sp)
    4c1a:	842a                	mv	s0,a0
    4c1c:	852e                	mv	a0,a1
    4c1e:	0003f797          	auipc	a5,0x3f
    4c22:	c807a723          	sw	zero,-882(a5) # 438ac <errno>
    4c26:	e406                	sd	ra,8(sp)
    4c28:	706000ef          	jal	532e <_sbrk>
    4c2c:	57fd                	li	a5,-1
    4c2e:	00f50663          	beq	a0,a5,4c3a <_sbrk_r+0x24>
    4c32:	60a2                	ld	ra,8(sp)
    4c34:	6402                	ld	s0,0(sp)
    4c36:	0141                	addi	sp,sp,16
    4c38:	8082                	ret
    4c3a:	0003f797          	auipc	a5,0x3f
    4c3e:	c727a783          	lw	a5,-910(a5) # 438ac <errno>
    4c42:	dbe5                	beqz	a5,4c32 <_sbrk_r+0x1c>
    4c44:	60a2                	ld	ra,8(sp)
    4c46:	c01c                	sw	a5,0(s0)
    4c48:	6402                	ld	s0,0(sp)
    4c4a:	0141                	addi	sp,sp,16
    4c4c:	8082                	ret
	...

0000000000004c50 <strcmp>:
    4c50:	00b56733          	or	a4,a0,a1
    4c54:	53fd                	li	t2,-1
    4c56:	8b1d                	andi	a4,a4,7
    4c58:	eb4d                	bnez	a4,4d0a <strcmp+0xba>
    4c5a:	00001797          	auipc	a5,0x1
    4c5e:	c1e7b783          	ld	a5,-994(a5) # 5878 <mask>
    4c62:	6110                	ld	a2,0(a0)
    4c64:	6194                	ld	a3,0(a1)
    4c66:	00f672b3          	and	t0,a2,a5
    4c6a:	00f66333          	or	t1,a2,a5
    4c6e:	92be                	add	t0,t0,a5
    4c70:	0062e2b3          	or	t0,t0,t1
    4c74:	0a729963          	bne	t0,t2,4d26 <strcmp+0xd6>
    4c78:	02d61e63          	bne	a2,a3,4cb4 <strcmp+0x64>
    4c7c:	6510                	ld	a2,8(a0)
    4c7e:	6594                	ld	a3,8(a1)
    4c80:	00f672b3          	and	t0,a2,a5
    4c84:	00f66333          	or	t1,a2,a5
    4c88:	92be                	add	t0,t0,a5
    4c8a:	0062e2b3          	or	t0,t0,t1
    4c8e:	08729a63          	bne	t0,t2,4d22 <strcmp+0xd2>
    4c92:	02d61163          	bne	a2,a3,4cb4 <strcmp+0x64>
    4c96:	6910                	ld	a2,16(a0)
    4c98:	6994                	ld	a3,16(a1)
    4c9a:	00f672b3          	and	t0,a2,a5
    4c9e:	00f66333          	or	t1,a2,a5
    4ca2:	92be                	add	t0,t0,a5
    4ca4:	0062e2b3          	or	t0,t0,t1
    4ca8:	08729363          	bne	t0,t2,4d2e <strcmp+0xde>
    4cac:	0561                	addi	a0,a0,24
    4cae:	05e1                	addi	a1,a1,24
    4cb0:	fad609e3          	beq	a2,a3,4c62 <strcmp+0x12>
    4cb4:	03061713          	slli	a4,a2,0x30
    4cb8:	03069793          	slli	a5,a3,0x30
    4cbc:	02f71863          	bne	a4,a5,4cec <strcmp+0x9c>
    4cc0:	02061713          	slli	a4,a2,0x20
    4cc4:	02069793          	slli	a5,a3,0x20
    4cc8:	02f71263          	bne	a4,a5,4cec <strcmp+0x9c>
    4ccc:	01061713          	slli	a4,a2,0x10
    4cd0:	01069793          	slli	a5,a3,0x10
    4cd4:	00f71c63          	bne	a4,a5,4cec <strcmp+0x9c>
    4cd8:	03065713          	srli	a4,a2,0x30
    4cdc:	0306d793          	srli	a5,a3,0x30
    4ce0:	40f70533          	sub	a0,a4,a5
    4ce4:	0ff57593          	zext.b	a1,a0
    4ce8:	e991                	bnez	a1,4cfc <strcmp+0xac>
    4cea:	8082                	ret
    4cec:	9341                	srli	a4,a4,0x30
    4cee:	93c1                	srli	a5,a5,0x30
    4cf0:	40f70533          	sub	a0,a4,a5
    4cf4:	0ff57593          	zext.b	a1,a0
    4cf8:	e191                	bnez	a1,4cfc <strcmp+0xac>
    4cfa:	8082                	ret
    4cfc:	0ff77713          	zext.b	a4,a4
    4d00:	0ff7f793          	zext.b	a5,a5
    4d04:	40f70533          	sub	a0,a4,a5
    4d08:	8082                	ret
    4d0a:	00054603          	lbu	a2,0(a0)
    4d0e:	0005c683          	lbu	a3,0(a1)
    4d12:	0505                	addi	a0,a0,1
    4d14:	0585                	addi	a1,a1,1
    4d16:	00d61363          	bne	a2,a3,4d1c <strcmp+0xcc>
    4d1a:	fa65                	bnez	a2,4d0a <strcmp+0xba>
    4d1c:	40d60533          	sub	a0,a2,a3
    4d20:	8082                	ret
    4d22:	0521                	addi	a0,a0,8
    4d24:	05a1                	addi	a1,a1,8
    4d26:	fed612e3          	bne	a2,a3,4d0a <strcmp+0xba>
    4d2a:	4501                	li	a0,0
    4d2c:	8082                	ret
    4d2e:	0541                	addi	a0,a0,16
    4d30:	05c1                	addi	a1,a1,16
    4d32:	fcd61ce3          	bne	a2,a3,4d0a <strcmp+0xba>
    4d36:	4501                	li	a0,0
    4d38:	8082                	ret

0000000000004d3a <strdup>:
    4d3a:	85aa                	mv	a1,a0
    4d3c:	0003c517          	auipc	a0,0x3c
    4d40:	24c53503          	ld	a0,588(a0) # 40f88 <_impure_ptr>
    4d44:	a009                	j	4d46 <_strdup_r>

0000000000004d46 <_strdup_r>:
    4d46:	1101                	addi	sp,sp,-32
    4d48:	e822                	sd	s0,16(sp)
    4d4a:	842a                	mv	s0,a0
    4d4c:	852e                	mv	a0,a1
    4d4e:	ec06                	sd	ra,24(sp)
    4d50:	e426                	sd	s1,8(sp)
    4d52:	e04a                	sd	s2,0(sp)
    4d54:	84ae                	mv	s1,a1
    4d56:	02a000ef          	jal	4d80 <strlen>
    4d5a:	00150913          	addi	s2,a0,1
    4d5e:	85ca                	mv	a1,s2
    4d60:	8522                	mv	a0,s0
    4d62:	83fff0ef          	jal	45a0 <_malloc_r>
    4d66:	842a                	mv	s0,a0
    4d68:	c509                	beqz	a0,4d72 <_strdup_r+0x2c>
    4d6a:	864a                	mv	a2,s2
    4d6c:	85a6                	mv	a1,s1
    4d6e:	3ee000ef          	jal	515c <memcpy>
    4d72:	60e2                	ld	ra,24(sp)
    4d74:	8522                	mv	a0,s0
    4d76:	6442                	ld	s0,16(sp)
    4d78:	64a2                	ld	s1,8(sp)
    4d7a:	6902                	ld	s2,0(sp)
    4d7c:	6105                	addi	sp,sp,32
    4d7e:	8082                	ret

0000000000004d80 <strlen>:
    4d80:	00757793          	andi	a5,a0,7
    4d84:	872a                	mv	a4,a0
    4d86:	efb1                	bnez	a5,4de2 <strlen+0x62>
    4d88:	7f7f87b7          	lui	a5,0x7f7f8
    4d8c:	f7f78793          	addi	a5,a5,-129 # 7f7f7f7f <__kernel_stack+0x7f709f7f>
    4d90:	02079693          	slli	a3,a5,0x20
    4d94:	96be                	add	a3,a3,a5
    4d96:	55fd                	li	a1,-1
    4d98:	6310                	ld	a2,0(a4)
    4d9a:	0721                	addi	a4,a4,8
    4d9c:	00d677b3          	and	a5,a2,a3
    4da0:	97b6                	add	a5,a5,a3
    4da2:	8fd1                	or	a5,a5,a2
    4da4:	8fd5                	or	a5,a5,a3
    4da6:	feb789e3          	beq	a5,a1,4d98 <strlen+0x18>
    4daa:	ff874683          	lbu	a3,-8(a4)
    4dae:	40a707b3          	sub	a5,a4,a0
    4db2:	c6a9                	beqz	a3,4dfc <strlen+0x7c>
    4db4:	ff974683          	lbu	a3,-7(a4)
    4db8:	ce9d                	beqz	a3,4df6 <strlen+0x76>
    4dba:	ffa74683          	lbu	a3,-6(a4)
    4dbe:	c6a9                	beqz	a3,4e08 <strlen+0x88>
    4dc0:	ffb74683          	lbu	a3,-5(a4)
    4dc4:	ce9d                	beqz	a3,4e02 <strlen+0x82>
    4dc6:	ffc74683          	lbu	a3,-4(a4)
    4dca:	c2b1                	beqz	a3,4e0e <strlen+0x8e>
    4dcc:	ffd74683          	lbu	a3,-3(a4)
    4dd0:	c2b1                	beqz	a3,4e14 <strlen+0x94>
    4dd2:	ffe74503          	lbu	a0,-2(a4)
    4dd6:	00a03533          	snez	a0,a0
    4dda:	953e                	add	a0,a0,a5
    4ddc:	1579                	addi	a0,a0,-2
    4dde:	8082                	ret
    4de0:	d6c5                	beqz	a3,4d88 <strlen+0x8>
    4de2:	00074783          	lbu	a5,0(a4)
    4de6:	0705                	addi	a4,a4,1
    4de8:	00777693          	andi	a3,a4,7
    4dec:	fbf5                	bnez	a5,4de0 <strlen+0x60>
    4dee:	8f09                	sub	a4,a4,a0
    4df0:	fff70513          	addi	a0,a4,-1
    4df4:	8082                	ret
    4df6:	ff978513          	addi	a0,a5,-7
    4dfa:	8082                	ret
    4dfc:	ff878513          	addi	a0,a5,-8
    4e00:	8082                	ret
    4e02:	ffb78513          	addi	a0,a5,-5
    4e06:	8082                	ret
    4e08:	ffa78513          	addi	a0,a5,-6
    4e0c:	8082                	ret
    4e0e:	ffc78513          	addi	a0,a5,-4
    4e12:	8082                	ret
    4e14:	ffd78513          	addi	a0,a5,-3
    4e18:	8082                	ret

0000000000004e1a <_malloc_trim_r>:
    4e1a:	7179                	addi	sp,sp,-48
    4e1c:	f022                	sd	s0,32(sp)
    4e1e:	ec26                	sd	s1,24(sp)
    4e20:	e84a                	sd	s2,16(sp)
    4e22:	e44e                	sd	s3,8(sp)
    4e24:	e052                	sd	s4,0(sp)
    4e26:	89ae                	mv	s3,a1
    4e28:	f406                	sd	ra,40(sp)
    4e2a:	892a                	mv	s2,a0
    4e2c:	0003ba17          	auipc	s4,0x3b
    4e30:	1dca0a13          	addi	s4,s4,476 # 40008 <__malloc_av_>
    4e34:	dcbff0ef          	jal	4bfe <__malloc_lock>
    4e38:	010a3783          	ld	a5,16(s4)
    4e3c:	6405                	lui	s0,0x1
    4e3e:	fdf40413          	addi	s0,s0,-33 # fdf <_ftoa+0x1ff>
    4e42:	6784                	ld	s1,8(a5)
    4e44:	6785                	lui	a5,0x1
    4e46:	98f1                	andi	s1,s1,-4
    4e48:	9426                	add	s0,s0,s1
    4e4a:	41340433          	sub	s0,s0,s3
    4e4e:	8031                	srli	s0,s0,0xc
    4e50:	147d                	addi	s0,s0,-1
    4e52:	0432                	slli	s0,s0,0xc
    4e54:	00f44b63          	blt	s0,a5,4e6a <_malloc_trim_r+0x50>
    4e58:	4581                	li	a1,0
    4e5a:	854a                	mv	a0,s2
    4e5c:	dbbff0ef          	jal	4c16 <_sbrk_r>
    4e60:	010a3783          	ld	a5,16(s4)
    4e64:	97a6                	add	a5,a5,s1
    4e66:	00f50e63          	beq	a0,a5,4e82 <_malloc_trim_r+0x68>
    4e6a:	854a                	mv	a0,s2
    4e6c:	d9fff0ef          	jal	4c0a <__malloc_unlock>
    4e70:	70a2                	ld	ra,40(sp)
    4e72:	7402                	ld	s0,32(sp)
    4e74:	64e2                	ld	s1,24(sp)
    4e76:	6942                	ld	s2,16(sp)
    4e78:	69a2                	ld	s3,8(sp)
    4e7a:	6a02                	ld	s4,0(sp)
    4e7c:	4501                	li	a0,0
    4e7e:	6145                	addi	sp,sp,48
    4e80:	8082                	ret
    4e82:	408005b3          	neg	a1,s0
    4e86:	854a                	mv	a0,s2
    4e88:	d8fff0ef          	jal	4c16 <_sbrk_r>
    4e8c:	57fd                	li	a5,-1
    4e8e:	02f50d63          	beq	a0,a5,4ec8 <_malloc_trim_r+0xae>
    4e92:	010a3703          	ld	a4,16(s4)
    4e96:	0003f797          	auipc	a5,0x3f
    4e9a:	9927a783          	lw	a5,-1646(a5) # 43828 <__malloc_current_mallinfo>
    4e9e:	8c81                	sub	s1,s1,s0
    4ea0:	0014e493          	ori	s1,s1,1
    4ea4:	e704                	sd	s1,8(a4)
    4ea6:	854a                	mv	a0,s2
    4ea8:	9f81                	subw	a5,a5,s0
    4eaa:	0003f717          	auipc	a4,0x3f
    4eae:	96f72f23          	sw	a5,-1666(a4) # 43828 <__malloc_current_mallinfo>
    4eb2:	d59ff0ef          	jal	4c0a <__malloc_unlock>
    4eb6:	70a2                	ld	ra,40(sp)
    4eb8:	7402                	ld	s0,32(sp)
    4eba:	64e2                	ld	s1,24(sp)
    4ebc:	6942                	ld	s2,16(sp)
    4ebe:	69a2                	ld	s3,8(sp)
    4ec0:	6a02                	ld	s4,0(sp)
    4ec2:	4505                	li	a0,1
    4ec4:	6145                	addi	sp,sp,48
    4ec6:	8082                	ret
    4ec8:	4581                	li	a1,0
    4eca:	854a                	mv	a0,s2
    4ecc:	d4bff0ef          	jal	4c16 <_sbrk_r>
    4ed0:	010a3703          	ld	a4,16(s4)
    4ed4:	46fd                	li	a3,31
    4ed6:	40e507b3          	sub	a5,a0,a4
    4eda:	f8f6d8e3          	bge	a3,a5,4e6a <_malloc_trim_r+0x50>
    4ede:	0003c697          	auipc	a3,0x3c
    4ee2:	09a6b683          	ld	a3,154(a3) # 40f78 <__malloc_sbrk_base>
    4ee6:	0017e793          	ori	a5,a5,1
    4eea:	e71c                	sd	a5,8(a4)
    4eec:	8d15                	sub	a0,a0,a3
    4eee:	0003f797          	auipc	a5,0x3f
    4ef2:	92a7ad23          	sw	a0,-1734(a5) # 43828 <__malloc_current_mallinfo>
    4ef6:	bf95                	j	4e6a <_malloc_trim_r+0x50>

0000000000004ef8 <_free_r>:
    4ef8:	c1fd                	beqz	a1,4fde <_free_r+0xe6>
    4efa:	1101                	addi	sp,sp,-32
    4efc:	e822                	sd	s0,16(sp)
    4efe:	e426                	sd	s1,8(sp)
    4f00:	842e                	mv	s0,a1
    4f02:	84aa                	mv	s1,a0
    4f04:	ec06                	sd	ra,24(sp)
    4f06:	cf9ff0ef          	jal	4bfe <__malloc_lock>
    4f0a:	ff843583          	ld	a1,-8(s0)
    4f0e:	ff040713          	addi	a4,s0,-16
    4f12:	0003b817          	auipc	a6,0x3b
    4f16:	0f680813          	addi	a6,a6,246 # 40008 <__malloc_av_>
    4f1a:	ffe5f793          	andi	a5,a1,-2
    4f1e:	00f70633          	add	a2,a4,a5
    4f22:	6614                	ld	a3,8(a2)
    4f24:	01083503          	ld	a0,16(a6)
    4f28:	0015f893          	andi	a7,a1,1
    4f2c:	9af1                	andi	a3,a3,-4
    4f2e:	12c50563          	beq	a0,a2,5058 <_free_r+0x160>
    4f32:	e614                	sd	a3,8(a2)
    4f34:	00d60533          	add	a0,a2,a3
    4f38:	6508                	ld	a0,8(a0)
    4f3a:	8905                	andi	a0,a0,1
    4f3c:	06089e63          	bnez	a7,4fb8 <_free_r+0xc0>
    4f40:	ff043303          	ld	t1,-16(s0)
    4f44:	0003b897          	auipc	a7,0x3b
    4f48:	0d488893          	addi	a7,a7,212 # 40018 <__malloc_av_+0x10>
    4f4c:	40670733          	sub	a4,a4,t1
    4f50:	6b0c                	ld	a1,16(a4)
    4f52:	979a                	add	a5,a5,t1
    4f54:	0f158663          	beq	a1,a7,5040 <_free_r+0x148>
    4f58:	01873303          	ld	t1,24(a4)
    4f5c:	0065bc23          	sd	t1,24(a1)
    4f60:	00b33823          	sd	a1,16(t1)
    4f64:	12050863          	beqz	a0,5094 <_free_r+0x19c>
    4f68:	0017e693          	ori	a3,a5,1
    4f6c:	e714                	sd	a3,8(a4)
    4f6e:	e21c                	sd	a5,0(a2)
    4f70:	1ff00693          	li	a3,511
    4f74:	06f6ef63          	bltu	a3,a5,4ff2 <_free_r+0xfa>
    4f78:	838d                	srli	a5,a5,0x3
    4f7a:	2781                	sext.w	a5,a5
    4f7c:	0017869b          	addiw	a3,a5,1
    4f80:	0016969b          	slliw	a3,a3,0x1
    4f84:	068e                	slli	a3,a3,0x3
    4f86:	00883503          	ld	a0,8(a6)
    4f8a:	96c2                	add	a3,a3,a6
    4f8c:	628c                	ld	a1,0(a3)
    4f8e:	4605                	li	a2,1
    4f90:	4027d79b          	sraiw	a5,a5,0x2
    4f94:	00f617b3          	sll	a5,a2,a5
    4f98:	8fc9                	or	a5,a5,a0
    4f9a:	ff068613          	addi	a2,a3,-16
    4f9e:	eb0c                	sd	a1,16(a4)
    4fa0:	ef10                	sd	a2,24(a4)
    4fa2:	00f83423          	sd	a5,8(a6)
    4fa6:	e298                	sd	a4,0(a3)
    4fa8:	ed98                	sd	a4,24(a1)
    4faa:	6442                	ld	s0,16(sp)
    4fac:	60e2                	ld	ra,24(sp)
    4fae:	8526                	mv	a0,s1
    4fb0:	64a2                	ld	s1,8(sp)
    4fb2:	6105                	addi	sp,sp,32
    4fb4:	c57ff06f          	j	4c0a <__malloc_unlock>
    4fb8:	e505                	bnez	a0,4fe0 <_free_r+0xe8>
    4fba:	97b6                	add	a5,a5,a3
    4fbc:	0003b897          	auipc	a7,0x3b
    4fc0:	05c88893          	addi	a7,a7,92 # 40018 <__malloc_av_+0x10>
    4fc4:	6a14                	ld	a3,16(a2)
    4fc6:	0017e513          	ori	a0,a5,1
    4fca:	00f705b3          	add	a1,a4,a5
    4fce:	11168363          	beq	a3,a7,50d4 <_free_r+0x1dc>
    4fd2:	6e10                	ld	a2,24(a2)
    4fd4:	ee90                	sd	a2,24(a3)
    4fd6:	ea14                	sd	a3,16(a2)
    4fd8:	e708                	sd	a0,8(a4)
    4fda:	e19c                	sd	a5,0(a1)
    4fdc:	bf51                	j	4f70 <_free_r+0x78>
    4fde:	8082                	ret
    4fe0:	0015e593          	ori	a1,a1,1
    4fe4:	feb43c23          	sd	a1,-8(s0)
    4fe8:	e21c                	sd	a5,0(a2)
    4fea:	1ff00693          	li	a3,511
    4fee:	f8f6f5e3          	bgeu	a3,a5,4f78 <_free_r+0x80>
    4ff2:	0097d693          	srli	a3,a5,0x9
    4ff6:	4611                	li	a2,4
    4ff8:	0ad66063          	bltu	a2,a3,5098 <_free_r+0x1a0>
    4ffc:	0067d693          	srli	a3,a5,0x6
    5000:	0396859b          	addiw	a1,a3,57
    5004:	0015959b          	slliw	a1,a1,0x1
    5008:	058e                	slli	a1,a1,0x3
    500a:	0386861b          	addiw	a2,a3,56
    500e:	95c2                	add	a1,a1,a6
    5010:	6194                	ld	a3,0(a1)
    5012:	15c1                	addi	a1,a1,-16
    5014:	00d59663          	bne	a1,a3,5020 <_free_r+0x128>
    5018:	a8c9                	j	50ea <_free_r+0x1f2>
    501a:	6a94                	ld	a3,16(a3)
    501c:	00d58663          	beq	a1,a3,5028 <_free_r+0x130>
    5020:	6690                	ld	a2,8(a3)
    5022:	9a71                	andi	a2,a2,-4
    5024:	fec7ebe3          	bltu	a5,a2,501a <_free_r+0x122>
    5028:	6e8c                	ld	a1,24(a3)
    502a:	ef0c                	sd	a1,24(a4)
    502c:	eb14                	sd	a3,16(a4)
    502e:	6442                	ld	s0,16(sp)
    5030:	60e2                	ld	ra,24(sp)
    5032:	e998                	sd	a4,16(a1)
    5034:	8526                	mv	a0,s1
    5036:	64a2                	ld	s1,8(sp)
    5038:	ee98                	sd	a4,24(a3)
    503a:	6105                	addi	sp,sp,32
    503c:	bcfff06f          	j	4c0a <__malloc_unlock>
    5040:	ed2d                	bnez	a0,50ba <_free_r+0x1c2>
    5042:	6e0c                	ld	a1,24(a2)
    5044:	6a10                	ld	a2,16(a2)
    5046:	96be                	add	a3,a3,a5
    5048:	0016e793          	ori	a5,a3,1
    504c:	ee0c                	sd	a1,24(a2)
    504e:	e990                	sd	a2,16(a1)
    5050:	e71c                	sd	a5,8(a4)
    5052:	9736                	add	a4,a4,a3
    5054:	e314                	sd	a3,0(a4)
    5056:	bf91                	j	4faa <_free_r+0xb2>
    5058:	96be                	add	a3,a3,a5
    505a:	00089a63          	bnez	a7,506e <_free_r+0x176>
    505e:	ff043583          	ld	a1,-16(s0)
    5062:	8f0d                	sub	a4,a4,a1
    5064:	6f1c                	ld	a5,24(a4)
    5066:	6b10                	ld	a2,16(a4)
    5068:	96ae                	add	a3,a3,a1
    506a:	ee1c                	sd	a5,24(a2)
    506c:	eb90                	sd	a2,16(a5)
    506e:	0016e613          	ori	a2,a3,1
    5072:	0003c797          	auipc	a5,0x3c
    5076:	f0e7b783          	ld	a5,-242(a5) # 40f80 <__malloc_trim_threshold>
    507a:	e710                	sd	a2,8(a4)
    507c:	00e83823          	sd	a4,16(a6)
    5080:	f2f6e5e3          	bltu	a3,a5,4faa <_free_r+0xb2>
    5084:	0003e597          	auipc	a1,0x3e
    5088:	7dc5b583          	ld	a1,2012(a1) # 43860 <__malloc_top_pad>
    508c:	8526                	mv	a0,s1
    508e:	d8dff0ef          	jal	4e1a <_malloc_trim_r>
    5092:	bf21                	j	4faa <_free_r+0xb2>
    5094:	97b6                	add	a5,a5,a3
    5096:	b73d                	j	4fc4 <_free_r+0xcc>
    5098:	4651                	li	a2,20
    509a:	02d67563          	bgeu	a2,a3,50c4 <_free_r+0x1cc>
    509e:	05400613          	li	a2,84
    50a2:	04d66f63          	bltu	a2,a3,5100 <_free_r+0x208>
    50a6:	00c7d693          	srli	a3,a5,0xc
    50aa:	06f6859b          	addiw	a1,a3,111
    50ae:	0015959b          	slliw	a1,a1,0x1
    50b2:	058e                	slli	a1,a1,0x3
    50b4:	06e6861b          	addiw	a2,a3,110
    50b8:	bf99                	j	500e <_free_r+0x116>
    50ba:	0017e693          	ori	a3,a5,1
    50be:	e714                	sd	a3,8(a4)
    50c0:	e21c                	sd	a5,0(a2)
    50c2:	b5e5                	j	4faa <_free_r+0xb2>
    50c4:	05c6859b          	addiw	a1,a3,92
    50c8:	0015959b          	slliw	a1,a1,0x1
    50cc:	058e                	slli	a1,a1,0x3
    50ce:	05b6861b          	addiw	a2,a3,91
    50d2:	bf35                	j	500e <_free_r+0x116>
    50d4:	02e83423          	sd	a4,40(a6)
    50d8:	02e83023          	sd	a4,32(a6)
    50dc:	01173c23          	sd	a7,24(a4)
    50e0:	01173823          	sd	a7,16(a4)
    50e4:	e708                	sd	a0,8(a4)
    50e6:	e19c                	sd	a5,0(a1)
    50e8:	b5c9                	j	4faa <_free_r+0xb2>
    50ea:	00883503          	ld	a0,8(a6)
    50ee:	4026561b          	sraiw	a2,a2,0x2
    50f2:	4785                	li	a5,1
    50f4:	00c797b3          	sll	a5,a5,a2
    50f8:	8fc9                	or	a5,a5,a0
    50fa:	00f83423          	sd	a5,8(a6)
    50fe:	b735                	j	502a <_free_r+0x132>
    5100:	15400613          	li	a2,340
    5104:	00d66c63          	bltu	a2,a3,511c <_free_r+0x224>
    5108:	00f7d693          	srli	a3,a5,0xf
    510c:	0786859b          	addiw	a1,a3,120
    5110:	0015959b          	slliw	a1,a1,0x1
    5114:	058e                	slli	a1,a1,0x3
    5116:	0776861b          	addiw	a2,a3,119
    511a:	bdd5                	j	500e <_free_r+0x116>
    511c:	55400613          	li	a2,1364
    5120:	00d66c63          	bltu	a2,a3,5138 <_free_r+0x240>
    5124:	0127d693          	srli	a3,a5,0x12
    5128:	07d6859b          	addiw	a1,a3,125
    512c:	0015959b          	slliw	a1,a1,0x1
    5130:	058e                	slli	a1,a1,0x3
    5132:	07c6861b          	addiw	a2,a3,124
    5136:	bde1                	j	500e <_free_r+0x116>
    5138:	7f000593          	li	a1,2032
    513c:	07e00613          	li	a2,126
    5140:	b5f9                	j	500e <_free_r+0x116>

0000000000005142 <__retarget_lock_init>:
    5142:	8082                	ret

0000000000005144 <__retarget_lock_init_recursive>:
    5144:	8082                	ret

0000000000005146 <__retarget_lock_close>:
    5146:	8082                	ret

0000000000005148 <__retarget_lock_close_recursive>:
    5148:	8082                	ret

000000000000514a <__retarget_lock_acquire>:
    514a:	8082                	ret

000000000000514c <__retarget_lock_acquire_recursive>:
    514c:	8082                	ret

000000000000514e <__retarget_lock_try_acquire>:
    514e:	4505                	li	a0,1
    5150:	8082                	ret

0000000000005152 <__retarget_lock_try_acquire_recursive>:
    5152:	4505                	li	a0,1
    5154:	8082                	ret

0000000000005156 <__retarget_lock_release>:
    5156:	8082                	ret

0000000000005158 <__retarget_lock_release_recursive>:
    5158:	8082                	ret
	...

000000000000515c <memcpy>:
    515c:	00863693          	sltiu	a3,a2,8
    5160:	82aa                	mv	t0,a0
    5162:	00c50333          	add	t1,a0,a2
    5166:	eeb5                	bnez	a3,51e2 <memcpy+0x86>
    5168:	00b546b3          	xor	a3,a0,a1
    516c:	8a9d                	andi	a3,a3,7
    516e:	eab5                	bnez	a3,51e2 <memcpy+0x86>
    5170:	00757693          	andi	a3,a0,7
    5174:	43a1                	li	t2,8
    5176:	e2c9                	bnez	a3,51f8 <memcpy+0x9c>
    5178:	ff837393          	andi	t2,t1,-8
    517c:	fc038313          	addi	t1,t2,-64
    5180:	04a36263          	bltu	t1,a0,51c4 <memcpy+0x68>
    5184:	03f67613          	andi	a2,a2,63
    5188:	6198                	ld	a4,0(a1)
    518a:	e118                	sd	a4,0(a0)
    518c:	659c                	ld	a5,8(a1)
    518e:	e51c                	sd	a5,8(a0)
    5190:	0105b803          	ld	a6,16(a1)
    5194:	01053823          	sd	a6,16(a0)
    5198:	0185b883          	ld	a7,24(a1)
    519c:	01153c23          	sd	a7,24(a0)
    51a0:	7198                	ld	a4,32(a1)
    51a2:	f118                	sd	a4,32(a0)
    51a4:	759c                	ld	a5,40(a1)
    51a6:	f51c                	sd	a5,40(a0)
    51a8:	0305b803          	ld	a6,48(a1)
    51ac:	03053823          	sd	a6,48(a0)
    51b0:	0385b883          	ld	a7,56(a1)
    51b4:	04058593          	addi	a1,a1,64
    51b8:	03153c23          	sd	a7,56(a0)
    51bc:	04050513          	addi	a0,a0,64
    51c0:	fca374e3          	bgeu	t1,a0,5188 <memcpy+0x2c>
    51c4:	ff837393          	andi	t2,t1,-8
    51c8:	ff838313          	addi	t1,t2,-8
    51cc:	00a36963          	bltu	t1,a0,51de <memcpy+0x82>
    51d0:	8a0d                	andi	a2,a2,3
    51d2:	4198                	lw	a4,0(a1)
    51d4:	0591                	addi	a1,a1,4
    51d6:	c118                	sw	a4,0(a0)
    51d8:	0511                	addi	a0,a0,4
    51da:	fea37ce3          	bgeu	t1,a0,51d2 <memcpy+0x76>
    51de:	00c50333          	add	t1,a0,a2
    51e2:	ca09                	beqz	a2,51f4 <memcpy+0x98>
    51e4:	00058703          	lb	a4,0(a1)
    51e8:	0585                	addi	a1,a1,1
    51ea:	00e50023          	sb	a4,0(a0)
    51ee:	0505                	addi	a0,a0,1
    51f0:	fe656ae3          	bltu	a0,t1,51e4 <memcpy+0x88>
    51f4:	8516                	mv	a0,t0
    51f6:	8082                	ret
    51f8:	40d386b3          	sub	a3,t2,a3
    51fc:	83b6                	mv	t2,a3
    51fe:	00058703          	lb	a4,0(a1)
    5202:	0585                	addi	a1,a1,1
    5204:	16fd                	addi	a3,a3,-1
    5206:	00e50023          	sb	a4,0(a0)
    520a:	0505                	addi	a0,a0,1
    520c:	faed                	bnez	a3,51fe <memcpy+0xa2>
    520e:	40760633          	sub	a2,a2,t2
    5212:	00263693          	sltiu	a3,a2,2
    5216:	f6f1                	bnez	a3,51e2 <memcpy+0x86>
    5218:	b785                	j	5178 <memcpy+0x1c>

000000000000521a <cleanup_glue>:
    521a:	7179                	addi	sp,sp,-48
    521c:	e84a                	sd	s2,16(sp)
    521e:	0005b903          	ld	s2,0(a1)
    5222:	f022                	sd	s0,32(sp)
    5224:	ec26                	sd	s1,24(sp)
    5226:	f406                	sd	ra,40(sp)
    5228:	842e                	mv	s0,a1
    522a:	84aa                	mv	s1,a0
    522c:	02090f63          	beqz	s2,526a <cleanup_glue+0x50>
    5230:	e44e                	sd	s3,8(sp)
    5232:	00093983          	ld	s3,0(s2)
    5236:	02098563          	beqz	s3,5260 <cleanup_glue+0x46>
    523a:	e052                	sd	s4,0(sp)
    523c:	0009ba03          	ld	s4,0(s3)
    5240:	000a0b63          	beqz	s4,5256 <cleanup_glue+0x3c>
    5244:	000a3583          	ld	a1,0(s4)
    5248:	c199                	beqz	a1,524e <cleanup_glue+0x34>
    524a:	fd1ff0ef          	jal	521a <cleanup_glue>
    524e:	85d2                	mv	a1,s4
    5250:	8526                	mv	a0,s1
    5252:	ca7ff0ef          	jal	4ef8 <_free_r>
    5256:	85ce                	mv	a1,s3
    5258:	8526                	mv	a0,s1
    525a:	c9fff0ef          	jal	4ef8 <_free_r>
    525e:	6a02                	ld	s4,0(sp)
    5260:	85ca                	mv	a1,s2
    5262:	8526                	mv	a0,s1
    5264:	c95ff0ef          	jal	4ef8 <_free_r>
    5268:	69a2                	ld	s3,8(sp)
    526a:	85a2                	mv	a1,s0
    526c:	7402                	ld	s0,32(sp)
    526e:	70a2                	ld	ra,40(sp)
    5270:	6942                	ld	s2,16(sp)
    5272:	8526                	mv	a0,s1
    5274:	64e2                	ld	s1,24(sp)
    5276:	6145                	addi	sp,sp,48
    5278:	c81ff06f          	j	4ef8 <_free_r>

000000000000527c <_reclaim_reent>:
    527c:	0003c797          	auipc	a5,0x3c
    5280:	d0c7b783          	ld	a5,-756(a5) # 40f88 <_impure_ptr>
    5284:	0aa78463          	beq	a5,a0,532c <_reclaim_reent+0xb0>
    5288:	7d2c                	ld	a1,120(a0)
    528a:	7179                	addi	sp,sp,-48
    528c:	ec26                	sd	s1,24(sp)
    528e:	f406                	sd	ra,40(sp)
    5290:	f022                	sd	s0,32(sp)
    5292:	e84a                	sd	s2,16(sp)
    5294:	84aa                	mv	s1,a0
    5296:	c59d                	beqz	a1,52c4 <_reclaim_reent+0x48>
    5298:	e44e                	sd	s3,8(sp)
    529a:	4901                	li	s2,0
    529c:	20000993          	li	s3,512
    52a0:	012587b3          	add	a5,a1,s2
    52a4:	6380                	ld	s0,0(a5)
    52a6:	c801                	beqz	s0,52b6 <_reclaim_reent+0x3a>
    52a8:	85a2                	mv	a1,s0
    52aa:	6000                	ld	s0,0(s0)
    52ac:	8526                	mv	a0,s1
    52ae:	c4bff0ef          	jal	4ef8 <_free_r>
    52b2:	f87d                	bnez	s0,52a8 <_reclaim_reent+0x2c>
    52b4:	7cac                	ld	a1,120(s1)
    52b6:	0921                	addi	s2,s2,8
    52b8:	ff3914e3          	bne	s2,s3,52a0 <_reclaim_reent+0x24>
    52bc:	8526                	mv	a0,s1
    52be:	c3bff0ef          	jal	4ef8 <_free_r>
    52c2:	69a2                	ld	s3,8(sp)
    52c4:	70ac                	ld	a1,96(s1)
    52c6:	c581                	beqz	a1,52ce <_reclaim_reent+0x52>
    52c8:	8526                	mv	a0,s1
    52ca:	c2fff0ef          	jal	4ef8 <_free_r>
    52ce:	1f84b403          	ld	s0,504(s1)
    52d2:	cc01                	beqz	s0,52ea <_reclaim_reent+0x6e>
    52d4:	20048913          	addi	s2,s1,512
    52d8:	01240963          	beq	s0,s2,52ea <_reclaim_reent+0x6e>
    52dc:	85a2                	mv	a1,s0
    52de:	6000                	ld	s0,0(s0)
    52e0:	8526                	mv	a0,s1
    52e2:	c17ff0ef          	jal	4ef8 <_free_r>
    52e6:	fe891be3          	bne	s2,s0,52dc <_reclaim_reent+0x60>
    52ea:	64cc                	ld	a1,136(s1)
    52ec:	c581                	beqz	a1,52f4 <_reclaim_reent+0x78>
    52ee:	8526                	mv	a0,s1
    52f0:	c09ff0ef          	jal	4ef8 <_free_r>
    52f4:	48bc                	lw	a5,80(s1)
    52f6:	c78d                	beqz	a5,5320 <_reclaim_reent+0xa4>
    52f8:	6cbc                	ld	a5,88(s1)
    52fa:	8526                	mv	a0,s1
    52fc:	9782                	jalr	a5
    52fe:	5204b403          	ld	s0,1312(s1)
    5302:	cc19                	beqz	s0,5320 <_reclaim_reent+0xa4>
    5304:	600c                	ld	a1,0(s0)
    5306:	c581                	beqz	a1,530e <_reclaim_reent+0x92>
    5308:	8526                	mv	a0,s1
    530a:	f11ff0ef          	jal	521a <cleanup_glue>
    530e:	85a2                	mv	a1,s0
    5310:	7402                	ld	s0,32(sp)
    5312:	70a2                	ld	ra,40(sp)
    5314:	6942                	ld	s2,16(sp)
    5316:	8526                	mv	a0,s1
    5318:	64e2                	ld	s1,24(sp)
    531a:	6145                	addi	sp,sp,48
    531c:	bddff06f          	j	4ef8 <_free_r>
    5320:	70a2                	ld	ra,40(sp)
    5322:	7402                	ld	s0,32(sp)
    5324:	64e2                	ld	s1,24(sp)
    5326:	6942                	ld	s2,16(sp)
    5328:	6145                	addi	sp,sp,48
    532a:	8082                	ret
    532c:	8082                	ret

000000000000532e <_sbrk>:
    532e:	0003e317          	auipc	t1,0x3e
    5332:	58230313          	addi	t1,t1,1410 # 438b0 <heap_end.0>
    5336:	00033783          	ld	a5,0(t1)
    533a:	1141                	addi	sp,sp,-16
    533c:	e406                	sd	ra,8(sp)
    533e:	882a                	mv	a6,a0
    5340:	e385                	bnez	a5,5360 <_sbrk+0x32>
    5342:	4501                	li	a0,0
    5344:	4581                	li	a1,0
    5346:	4601                	li	a2,0
    5348:	4681                	li	a3,0
    534a:	4701                	li	a4,0
    534c:	0d600893          	li	a7,214
    5350:	00000073          	ecall
    5354:	577d                	li	a4,-1
    5356:	87aa                	mv	a5,a0
    5358:	02e50a63          	beq	a0,a4,538c <_sbrk+0x5e>
    535c:	00a33023          	sd	a0,0(t1)
    5360:	00f80533          	add	a0,a6,a5
    5364:	4581                	li	a1,0
    5366:	4601                	li	a2,0
    5368:	4681                	li	a3,0
    536a:	4701                	li	a4,0
    536c:	4781                	li	a5,0
    536e:	0d600893          	li	a7,214
    5372:	00000073          	ecall
    5376:	00033783          	ld	a5,0(t1)
    537a:	983e                	add	a6,a6,a5
    537c:	01051863          	bne	a0,a6,538c <_sbrk+0x5e>
    5380:	60a2                	ld	ra,8(sp)
    5382:	00a33023          	sd	a0,0(t1)
    5386:	853e                	mv	a0,a5
    5388:	0141                	addi	sp,sp,16
    538a:	8082                	ret
    538c:	010000ef          	jal	539c <__errno>
    5390:	60a2                	ld	ra,8(sp)
    5392:	47b1                	li	a5,12
    5394:	c11c                	sw	a5,0(a0)
    5396:	557d                	li	a0,-1
    5398:	0141                	addi	sp,sp,16
    539a:	8082                	ret

000000000000539c <__errno>:
    539c:	0003c517          	auipc	a0,0x3c
    53a0:	bec53503          	ld	a0,-1044(a0) # 40f88 <_impure_ptr>
    53a4:	8082                	ret
