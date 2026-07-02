
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
      92:	1ff1819b          	addiw	gp,gp,511 # 11ff <_ftoa+0x3ef>
      96:	7c11a073          	csrs	mhcr,gp

000000000000009a <after_l2en>:
      9a:	6185                	lui	gp,0x1
      9c:	1ff1819b          	addiw	gp,gp,511 # 11ff <_ftoa+0x3ef>
      a0:	7c11a073          	csrs	mhcr,gp
      a4:	0006e1b7          	lui	gp,0x6e
      a8:	30c1819b          	addiw	gp,gp,780 # 6e30c <heap_end.0+0x2aa5c>
      ac:	7c51a073          	csrs	mhint,gp
      b0:	0070019b          	addiw	gp,zero,7
      b4:	01f6                	slli	gp,gp,0x1d
      b6:	01a5                	addi	gp,gp,9
      b8:	7c31a073          	csrs	mccr2,gp
      bc:	734000ef          	jal	7f0 <main>

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

00000000000006a0 <Proc_1>:
     6a0:	1101                	addi	sp,sp,-32
     6a2:	f891590b          	th.sdd	s2,s1,(sp),0,4
     6a6:	00041937          	lui	s2,0x41
     6aa:	f9090913          	addi	s2,s2,-112 # 40f90 <Next_Ptr_Glob>
     6ae:	04093783          	ld	a5,64(s2)
     6b2:	fa11540b          	th.sdd	s0,ra,(sp),1,4
     6b6:	6100                	ld	s0,0(a0)
     6b8:	f8d7c88b          	th.ldd	a7,a3,(a5),0,4
     6bc:	fcc7c58b          	th.ldd	a1,a2,(a5),2,4
     6c0:	7b98                	ld	a4,48(a5)
     6c2:	84aa                	mv	s1,a0
     6c4:	faa7c80b          	th.ldd	a6,a0,(a5),1,4
     6c8:	f8d4588b          	th.sdd	a7,a3,(s0),0,4
     6cc:	6094                	ld	a3,0(s1)
     6ce:	faa4580b          	th.sdd	a6,a0,(s0),1,4
     6d2:	fcc4558b          	th.sdd	a1,a2,(s0),2,4
     6d6:	f818                	sd	a4,48(s0)
     6d8:	4715                	li	a4,5
     6da:	c898                	sw	a4,16(s1)
     6dc:	e014                	sd	a3,0(s0)
     6de:	639c                	ld	a5,0(a5)
     6e0:	16892583          	lw	a1,360(s2)
     6e4:	4529                	li	a0,10
     6e6:	e01c                	sd	a5,0(s0)
     6e8:	04093603          	ld	a2,64(s2)
     6ec:	c818                	sw	a4,16(s0)
     6ee:	0641                	addi	a2,a2,16
     6f0:	5f0000ef          	jal	ce0 <Proc_7>
     6f4:	441c                	lw	a5,8(s0)
     6f6:	c79d                	beqz	a5,724 <Proc_1+0x84>
     6f8:	609c                	ld	a5,0(s1)
     6fa:	fa11440b          	th.ldd	s0,ra,(sp),1,4
     6fe:	f8a7c80b          	th.ldd	a6,a0,(a5),0,4
     702:	fac7c58b          	th.ldd	a1,a2,(a5),1,4
     706:	fce7c68b          	th.ldd	a3,a4,(a5),2,4
     70a:	7b9c                	ld	a5,48(a5)
     70c:	f8a4d80b          	th.sdd	a6,a0,(s1),0,4
     710:	fac4d58b          	th.sdd	a1,a2,(s1),1,4
     714:	fce4d68b          	th.sdd	a3,a4,(s1),2,4
     718:	f89c                	sd	a5,48(s1)
     71a:	f891490b          	th.ldd	s2,s1,(sp),0,4
     71e:	6105                	addi	sp,sp,32
     720:	8082                	ret
     722:	0001                	nop
     724:	44c8                	lw	a0,12(s1)
     726:	4799                	li	a5,6
     728:	00c40593          	addi	a1,s0,12
     72c:	c81c                	sw	a5,16(s0)
     72e:	572000ef          	jal	ca0 <Proc_6>
     732:	04093783          	ld	a5,64(s2)
     736:	8622                	mv	a2,s0
     738:	fa11440b          	th.ldd	s0,ra,(sp),1,4
     73c:	639c                	ld	a5,0(a5)
     73e:	f891490b          	th.ldd	s2,s1,(sp),0,4
     742:	4a08                	lw	a0,16(a2)
     744:	7a86578b          	th.sdia	a5,(a2),8,1
     748:	45a9                	li	a1,10
     74a:	6105                	addi	sp,sp,32
     74c:	5940006f          	j	ce0 <Proc_7>

0000000000000750 <Proc_2>:
     750:	000417b7          	lui	a5,0x41
     754:	f9078793          	addi	a5,a5,-112 # 40f90 <Next_Ptr_Glob>
     758:	0907c683          	lbu	a3,144(a5)
     75c:	04100713          	li	a4,65
     760:	00e68463          	beq	a3,a4,768 <Proc_2+0x18>
     764:	8082                	ret
     766:	0001                	nop
     768:	4118                	lw	a4,0(a0)
     76a:	1687a683          	lw	a3,360(a5)
     76e:	0097079b          	addiw	a5,a4,9
     772:	9f95                	subw	a5,a5,a3
     774:	c11c                	sw	a5,0(a0)
     776:	8082                	ret
     778:	00000013          	nop
     77c:	00000013          	nop

0000000000000780 <Proc_3>:
     780:	000417b7          	lui	a5,0x41
     784:	f9078793          	addi	a5,a5,-112 # 40f90 <Next_Ptr_Glob>
     788:	63b0                	ld	a2,64(a5)
     78a:	c601                	beqz	a2,792 <Proc_3+0x12>
     78c:	6218                	ld	a4,0(a2)
     78e:	e118                	sd	a4,0(a0)
     790:	63b0                	ld	a2,64(a5)
     792:	1687a583          	lw	a1,360(a5)
     796:	0641                	addi	a2,a2,16
     798:	4529                	li	a0,10
     79a:	5460006f          	j	ce0 <Proc_7>
     79e:	0001                	nop

00000000000007a0 <Proc_4>:
     7a0:	000417b7          	lui	a5,0x41
     7a4:	f9078793          	addi	a5,a5,-112 # 40f90 <Next_Ptr_Glob>
     7a8:	0907c703          	lbu	a4,144(a5)
     7ac:	0947a683          	lw	a3,148(a5)
     7b0:	04200613          	li	a2,66
     7b4:	fbf70713          	addi	a4,a4,-65
     7b8:	00173713          	seqz	a4,a4
     7bc:	8f55                	or	a4,a4,a3
     7be:	08c78c23          	sb	a2,152(a5)
     7c2:	08e7aa23          	sw	a4,148(a5)
     7c6:	8082                	ret
     7c8:	00000013          	nop
     7cc:	00000013          	nop

00000000000007d0 <Proc_5>:
     7d0:	000417b7          	lui	a5,0x41
     7d4:	f9078793          	addi	a5,a5,-112 # 40f90 <Next_Ptr_Glob>
     7d8:	04100713          	li	a4,65
     7dc:	08e78823          	sb	a4,144(a5)
     7e0:	0807aa23          	sw	zero,148(a5)
     7e4:	8082                	ret
	...

00000000000007f0 <main>:
     7f0:	6795                	lui	a5,0x5
     7f2:	54078713          	addi	a4,a5,1344 # 5540 <__errno+0x1a4>
     7f6:	6795                	lui	a5,0x5
     7f8:	7155                	addi	sp,sp,-208
     7fa:	52078793          	addi	a5,a5,1312 # 5520 <__errno+0x184>
     7fe:	e1f7c68b          	th.lwd	a3,t6,(a5),0,3
     802:	e3e7c60b          	th.lwd	a2,t5,(a5),1,3
     806:	e5c7ce8b          	th.lwd	t4,t3,(a5),2,3
     80a:	01c7d883          	lhu	a7,28(a5)
     80e:	01e7c803          	lbu	a6,30(a5)
     812:	0187a303          	lw	t1,24(a5)
     816:	f8b7428b          	th.ldd	t0,a1,(a4),0,4
     81a:	fd26                	sd	s1,184(sp)
     81c:	e1a2                	sd	s0,192(sp)
     81e:	4785                	li	a5,1
     820:	00041437          	lui	s0,0x41
     824:	f9040413          	addi	s0,s0,-112 # 40f90 <Next_Ptr_Glob>
     828:	e586                	sd	ra,200(sp)
     82a:	e55e                	sd	s7,136(sp)
     82c:	e95a                	sd	s6,144(sp)
     82e:	f4ee                	sd	s11,104(sp)
     830:	f8ea                	sd	s10,112(sp)
     832:	fce6                	sd	s9,120(sp)
     834:	e162                	sd	s8,128(sp)
     836:	ed56                	sd	s5,152(sp)
     838:	f152                	sd	s4,160(sp)
     83a:	f54e                	sd	s3,168(sp)
     83c:	f94a                	sd	s2,176(sp)
     83e:	1786                	slli	a5,a5,0x21
     840:	e83c                	sd	a5,80(s0)
     842:	02800793          	li	a5,40
     846:	fcb1528b          	th.sdd	t0,a1,(sp),2,4
     84a:	cc3c                	sw	a5,88(s0)
     84c:	cc74                	sw	a3,92(s0)
     84e:	87a2                	mv	a5,s0
     850:	00840693          	addi	a3,s0,8
     854:	6b08                	ld	a0,16(a4)
     856:	4f0c                	lw	a1,24(a4)
     858:	07f42023          	sw	t6,96(s0)
     85c:	d070                	sw	a2,100(s0)
     85e:	7e97d68b          	th.sdia	a3,(a5),9,3
     862:	e03c                	sd	a5,64(s0)
     864:	e434                	sd	a3,72(s0)
     866:	01e74783          	lbu	a5,30(a4)
     86a:	01c75603          	lhu	a2,28(a4)
     86e:	44a9                	li	s1,10
     870:	00041bb7          	lui	s7,0x41
     874:	f82a                	sd	a0,48(sp)
     876:	02f10f23          	sb	a5,62(sp)
     87a:	8526                	mv	a0,s1
     87c:	118b8793          	addi	a5,s7,280 # 41118 <Arr_2_Glob>
     880:	07e42423          	sw	t5,104(s0)
     884:	07d42623          	sw	t4,108(s0)
     888:	07c42823          	sw	t3,112(s0)
     88c:	06642a23          	sw	t1,116(s0)
     890:	6497ae23          	sw	s1,1628(a5)
     894:	07141c23          	sh	a7,120(s0)
     898:	07040d23          	sb	a6,122(s0)
     89c:	02c11e23          	sh	a2,60(sp)
     8a0:	dc2e                	sw	a1,56(sp)
     8a2:	6ae030ef          	jal	3f50 <putchar>
     8a6:	6515                	lui	a0,0x5
     8a8:	3a850513          	addi	a0,a0,936 # 53a8 <__errno+0xc>
     8ac:	664030ef          	jal	3f10 <puts>
     8b0:	8526                	mv	a0,s1
     8b2:	69e030ef          	jal	3f50 <putchar>
     8b6:	08042783          	lw	a5,128(s0)
     8ba:	2e078a63          	beqz	a5,bae <perf_monitor_end+0x16e>
     8be:	6515                	lui	a0,0x5
     8c0:	3e050513          	addi	a0,a0,992 # 53e0 <__errno+0x44>
     8c4:	64c030ef          	jal	3f10 <puts>
     8c8:	8526                	mv	a0,s1
     8ca:	686030ef          	jal	3f50 <putchar>
     8ce:	4529                	li	a0,10
     8d0:	680030ef          	jal	3f50 <putchar>
     8d4:	6515                	lui	a0,0x5
     8d6:	3e800593          	li	a1,1000
     8da:	44050513          	addi	a0,a0,1088 # 5440 <__errno+0xa4>
     8de:	692030ef          	jal	3f70 <printf>
     8e2:	47f030ef          	jal	4560 <get_vtimer>
     8e6:	7c05378b          	th.extu	a5,a0,31,0
     8ea:	e45c                	sd	a5,136(s0)

00000000000008ec <perf_monitor_start>:
     8ec:	6795                	lui	a5,0x5
     8ee:	56078a13          	addi	s4,a5,1376 # 5560 <__errno+0x1c4>
     8f2:	f99a4d0b          	th.ldd	s10,s9,(s4),0,4
     8f6:	010a3c03          	ld	s8,16(s4)
     8fa:	00041b37          	lui	s6,0x41
     8fe:	6495                	lui	s1,0x5
     900:	030b0b13          	addi	s6,s6,48 # 41030 <Arr_1_Glob>
     904:	5a048493          	addi	s1,s1,1440 # 55a0 <__errno+0x204>
     908:	4905                	li	s2,1
     90a:	04100a93          	li	s5,65
     90e:	0001                	nop
     910:	018a2683          	lw	a3,24(s4)
     914:	01ca5703          	lhu	a4,28(s4)
     918:	01ea4783          	lbu	a5,30(s4)
     91c:	04200813          	li	a6,66
     920:	4605                	li	a2,1
     922:	008c                	addi	a1,sp,64
     924:	1008                	addi	a0,sp,32
     926:	09040c23          	sb	a6,152(s0)
     92a:	ccb6                	sw	a3,88(sp)
     92c:	04e11e23          	sh	a4,92(sp)
     930:	04f10f23          	sb	a5,94(sp)
     934:	ce32                	sw	a2,28(sp)
     936:	e0ea                	sd	s10,64(sp)
     938:	e4e6                	sd	s9,72(sp)
     93a:	08c42a23          	sw	a2,148(s0)
     93e:	09540823          	sb	s5,144(s0)
     942:	e8e2                	sd	s8,80(sp)
     944:	41c000ef          	jal	d60 <Func_2>
     948:	00153793          	seqz	a5,a0
     94c:	471d                	li	a4,7
     94e:	0830                	addi	a2,sp,24
     950:	458d                	li	a1,3
     952:	4509                	li	a0,2
     954:	cc3a                	sw	a4,24(sp)
     956:	08f42a23          	sw	a5,148(s0)
     95a:	386000ef          	jal	ce0 <Proc_7>
     95e:	46e2                	lw	a3,24(sp)
     960:	118b8593          	addi	a1,s7,280
     964:	460d                	li	a2,3
     966:	855a                	mv	a0,s6
     968:	388000ef          	jal	cf0 <Proc_8>
     96c:	04043983          	ld	s3,64(s0)
     970:	4715                	li	a4,5
     972:	16842583          	lw	a1,360(s0)
     976:	f8c9cd8b          	th.ldd	s11,a2,(s3),0,4
     97a:	fa69c68b          	th.ldd	a3,t1,(s3),1,4
     97e:	0309b503          	ld	a0,48(s3)
     982:	fd09c88b          	th.ldd	a7,a6,(s3),2,4
     986:	f8cddd8b          	th.sdd	s11,a2,(s11),0,4
     98a:	864e                	mv	a2,s3
     98c:	00ddb823          	sd	a3,16(s11)
     990:	7a86468b          	th.ldia	a3,(a2),8,1
     994:	02adb823          	sd	a0,48(s11)
     998:	006dbc23          	sd	t1,24(s11)
     99c:	fd0dd88b          	th.sdd	a7,a6,(s11),2,4
     9a0:	00e9a823          	sw	a4,16(s3)
     9a4:	00eda823          	sw	a4,16(s11)
     9a8:	4529                	li	a0,10
     9aa:	00ddb023          	sd	a3,0(s11)
     9ae:	332000ef          	jal	ce0 <Proc_7>
     9b2:	008da703          	lw	a4,8(s11)
     9b6:	1c070163          	beqz	a4,b78 <perf_monitor_end+0x138>
     9ba:	0009b783          	ld	a5,0(s3)
     9be:	fce7c68b          	th.ldd	a3,a4,(a5),2,4
     9c2:	f8a7c80b          	th.ldd	a6,a0,(a5),0,4
     9c6:	fac7c58b          	th.ldd	a1,a2,(a5),1,4
     9ca:	7b9c                	ld	a5,48(a5)
     9cc:	fce9d68b          	th.sdd	a3,a4,(s3),2,4
     9d0:	09844703          	lbu	a4,152(s0)
     9d4:	02f9b823          	sd	a5,48(s3)
     9d8:	f8a9d80b          	th.sdd	a6,a0,(s3),0,4
     9dc:	fac9d58b          	th.sdd	a1,a2,(s3),1,4
     9e0:	04000793          	li	a5,64
     9e4:	1ce7f363          	bgeu	a5,a4,baa <perf_monitor_end+0x16a>
     9e8:	04100d93          	li	s11,65
     9ec:	498d                	li	s3,3
     9ee:	0001                	nop
     9f0:	04300593          	li	a1,67
     9f4:	856e                	mv	a0,s11
     9f6:	34a000ef          	jal	d40 <Func_1>
     9fa:	4772                	lw	a4,28(sp)
     9fc:	12a70e63          	beq	a4,a0,b38 <perf_monitor_end+0xf8>
     a00:	09844703          	lbu	a4,152(s0)
     a04:	001d879b          	addiw	a5,s11,1
     a08:	0ff7fd93          	zext.b	s11,a5
     a0c:	ffb772e3          	bgeu	a4,s11,9f0 <perf_monitor_start+0x104>
     a10:	0019979b          	slliw	a5,s3,0x1
     a14:	013789bb          	addw	s3,a5,s3
     a18:	4662                	lw	a2,24(sp)
     a1a:	09044703          	lbu	a4,144(s0)
     a1e:	02c9cdbb          	divw	s11,s3,a2
     a22:	87ee                	mv	a5,s11
     a24:	01571763          	bne	a4,s5,a32 <perf_monitor_start+0x146>
     a28:	16842703          	lw	a4,360(s0)
     a2c:	009d879b          	addiw	a5,s11,9
     a30:	9f99                	subw	a5,a5,a4
     a32:	2905                	addiw	s2,s2,1
     a34:	3e900713          	li	a4,1001
     a38:	ece91ce3          	bne	s2,a4,910 <perf_monitor_start+0x24>
     a3c:	f8f1560b          	th.sdd	a2,a5,(sp),0,4

0000000000000a40 <perf_monitor_end>:
     a40:	321030ef          	jal	4560 <get_vtimer>
     a44:	872a                	mv	a4,a0
     a46:	6515                	lui	a0,0x5
     a48:	7c07370b          	th.extu	a4,a4,31,0
     a4c:	47050513          	addi	a0,a0,1136 # 5470 <__errno+0xd4>
     a50:	16e43823          	sd	a4,368(s0)
     a54:	4bc030ef          	jal	3f10 <puts>
     a58:	08843803          	ld	a6,136(s0)
     a5c:	17043703          	ld	a4,368(s0)
     a60:	6595                	lui	a1,0x5
     a62:	6515                	lui	a0,0x5
     a64:	41070733          	sub	a4,a4,a6
     a68:	5e052707          	flw	fa4,1504(a0) # 55e0 <__errno+0x244>
     a6c:	5e45a787          	flw	fa5,1508(a1) # 55e4 <__errno+0x248>
     a70:	d02776d3          	fcvt.s.l	fa3,a4
     a74:	6515                	lui	a0,0x5
     a76:	18e6f753          	fdiv.s	fa4,fa3,fa4
     a7a:	48050513          	addi	a0,a0,1152 # 5480 <__errno+0xe4>
     a7e:	16e43c23          	sd	a4,376(s0)
     a82:	6495                	lui	s1,0x5
     a84:	18d7f7d3          	fdiv.s	fa5,fa5,fa3
     a88:	18e42027          	fsw	fa4,384(s0)
     a8c:	18f42227          	fsw	fa5,388(s0)
     a90:	4e0030ef          	jal	3f70 <printf>
     a94:	18042787          	flw	fa5,384(s0)
     a98:	4b048513          	addi	a0,s1,1200 # 54b0 <__errno+0x114>
     a9c:	420787d3          	fcvt.d.s	fa5,fa5
     aa0:	e20785d3          	fmv.x.d	a1,fa5
     aa4:	4cc030ef          	jal	3f70 <printf>
     aa8:	6515                	lui	a0,0x5
     aaa:	4b850513          	addi	a0,a0,1208 # 54b8 <__errno+0x11c>
     aae:	4c2030ef          	jal	3f70 <printf>
     ab2:	18442787          	flw	fa5,388(s0)
     ab6:	4b048513          	addi	a0,s1,1200
     aba:	420787d3          	fcvt.d.s	fa5,fa5
     abe:	e20785d3          	fmv.x.d	a1,fa5
     ac2:	4ae030ef          	jal	3f70 <printf>
     ac6:	6515                	lui	a0,0x5
     ac8:	4e850513          	addi	a0,a0,1256 # 54e8 <__errno+0x14c>
     acc:	4a4030ef          	jal	3f70 <printf>
     ad0:	6715                	lui	a4,0x5
     ad2:	5e872707          	flw	fa4,1512(a4) # 55e8 <__errno+0x24c>
     ad6:	18442787          	flw	fa5,388(s0)
     ada:	6515                	lui	a0,0x5
     adc:	51850513          	addi	a0,a0,1304 # 5518 <__errno+0x17c>
     ae0:	18e7f7d3          	fdiv.s	fa5,fa5,fa4
     ae4:	420787d3          	fcvt.d.s	fa5,fa5
     ae8:	e20785d3          	fmv.x.d	a1,fa5
     aec:	484030ef          	jal	3f70 <printf>
     af0:	4529                	li	a0,10
     af2:	45e030ef          	jal	3f50 <putchar>
     af6:	16842583          	lw	a1,360(s0)
     afa:	4715                	li	a4,5
     afc:	00e59763          	bne	a1,a4,b0a <perf_monitor_end+0xca>
     b00:	09442703          	lw	a4,148(s0)
     b04:	4585                	li	a1,1
     b06:	0ab70d63          	beq	a4,a1,bc0 <perf_monitor_end+0x180>
     b0a:	6515                	lui	a0,0x5
     b0c:	59050513          	addi	a0,a0,1424 # 5590 <__errno+0x1f4>
     b10:	400030ef          	jal	3f10 <puts>
     b14:	25d030ef          	jal	4570 <sim_end>
     b18:	60ae                	ld	ra,200(sp)
     b1a:	74ea                	ld	s1,184(sp)
     b1c:	640e                	ld	s0,192(sp)
     b1e:	7da6                	ld	s11,104(sp)
     b20:	7d46                	ld	s10,112(sp)
     b22:	7ce6                	ld	s9,120(sp)
     b24:	6c0a                	ld	s8,128(sp)
     b26:	6baa                	ld	s7,136(sp)
     b28:	6b4a                	ld	s6,144(sp)
     b2a:	6aea                	ld	s5,152(sp)
     b2c:	7a0a                	ld	s4,160(sp)
     b2e:	79aa                	ld	s3,168(sp)
     b30:	794a                	ld	s2,176(sp)
     b32:	4501                	li	a0,0
     b34:	6169                	addi	sp,sp,208
     b36:	8082                	ret
     b38:	086c                	addi	a1,sp,28
     b3a:	4501                	li	a0,0
     b3c:	164000ef          	jal	ca0 <Proc_6>
     b40:	01c4d683          	lhu	a3,28(s1)
     b44:	01e4c703          	lbu	a4,30(s1)
     b48:	4c90                	lw	a2,24(s1)
     b4a:	f904c88b          	th.ldd	a7,a6,(s1),0,4
     b4e:	6888                	ld	a0,16(s1)
     b50:	09844583          	lbu	a1,152(s0)
     b54:	001d879b          	addiw	a5,s11,1
     b58:	e0c6                	sd	a7,64(sp)
     b5a:	e4c2                	sd	a6,72(sp)
     b5c:	0ff7fd93          	zext.b	s11,a5
     b60:	04d11e23          	sh	a3,92(sp)
     b64:	04e10f23          	sb	a4,94(sp)
     b68:	e8aa                	sd	a0,80(sp)
     b6a:	ccb2                	sw	a2,88(sp)
     b6c:	17242423          	sw	s2,360(s0)
     b70:	89ca                	mv	s3,s2
     b72:	e7b5ffe3          	bgeu	a1,s11,9f0 <perf_monitor_start+0x104>
     b76:	bd69                	j	a10 <perf_monitor_start+0x124>
     b78:	00c9a503          	lw	a0,12(s3)
     b7c:	4719                	li	a4,6
     b7e:	00cd8593          	addi	a1,s11,12
     b82:	00eda823          	sw	a4,16(s11)
     b86:	11a000ef          	jal	ca0 <Proc_6>
     b8a:	6038                	ld	a4,64(s0)
     b8c:	010da503          	lw	a0,16(s11)
     b90:	866e                	mv	a2,s11
     b92:	631c                	ld	a5,0(a4)
     b94:	45a9                	li	a1,10
     b96:	7a86578b          	th.sdia	a5,(a2),8,1
     b9a:	146000ef          	jal	ce0 <Proc_7>
     b9e:	09844703          	lbu	a4,152(s0)
     ba2:	04000793          	li	a5,64
     ba6:	e4e7e1e3          	bltu	a5,a4,9e8 <perf_monitor_start+0xfc>
     baa:	49a5                	li	s3,9
     bac:	b5b5                	j	a18 <perf_monitor_start+0x12c>
     bae:	6515                	lui	a0,0x5
     bb0:	41050513          	addi	a0,a0,1040 # 5410 <__errno+0x74>
     bb4:	35c030ef          	jal	3f10 <puts>
     bb8:	8526                	mv	a0,s1
     bba:	396030ef          	jal	3f50 <putchar>
     bbe:	bb01                	j	8ce <main+0xde>
     bc0:	09044503          	lbu	a0,144(s0)
     bc4:	04100593          	li	a1,65
     bc8:	f4b511e3          	bne	a0,a1,b0a <perf_monitor_end+0xca>
     bcc:	09844503          	lbu	a0,152(s0)
     bd0:	04200593          	li	a1,66
     bd4:	f2b51be3          	bne	a0,a1,b0a <perf_monitor_end+0xca>
     bd8:	0c042503          	lw	a0,192(s0)
     bdc:	459d                	li	a1,7
     bde:	f2b516e3          	bne	a0,a1,b0a <perf_monitor_end+0xca>
     be2:	000416b7          	lui	a3,0x41
     be6:	11868693          	addi	a3,a3,280 # 41118 <Arr_2_Glob>
     bea:	65c6a503          	lw	a0,1628(a3)
     bee:	3f200593          	li	a1,1010
     bf2:	f0b51ce3          	bne	a0,a1,b0a <perf_monitor_end+0xca>
     bf6:	6028                	ld	a0,64(s0)
     bf8:	1706                	slli	a4,a4,0x21
     bfa:	650c                	ld	a1,8(a0)
     bfc:	f0e597e3          	bne	a1,a4,b0a <perf_monitor_end+0xca>
     c00:	490c                	lw	a1,16(a0)
     c02:	4745                	li	a4,17
     c04:	f0e593e3          	bne	a1,a4,b0a <perf_monitor_end+0xca>
     c08:	6795                	lui	a5,0x5
     c0a:	0551                	addi	a0,a0,20
     c0c:	52078593          	addi	a1,a5,1312 # 5520 <__errno+0x184>
     c10:	040040ef          	jal	4c50 <strcmp>
     c14:	ee051be3          	bnez	a0,b0a <perf_monitor_end+0xca>
     c18:	6008                	ld	a0,0(s0)
     c1a:	4705                	li	a4,1
     c1c:	1702                	slli	a4,a4,0x20
     c1e:	650c                	ld	a1,8(a0)
     c20:	4405                	li	s0,1
     c22:	eee594e3          	bne	a1,a4,b0a <perf_monitor_end+0xca>
     c26:	490c                	lw	a1,16(a0)
     c28:	4749                	li	a4,18
     c2a:	eee590e3          	bne	a1,a4,b0a <perf_monitor_end+0xca>
     c2e:	6795                	lui	a5,0x5
     c30:	52078593          	addi	a1,a5,1312 # 5520 <__errno+0x184>
     c34:	0551                	addi	a0,a0,20
     c36:	01a040ef          	jal	4c50 <strcmp>
     c3a:	ec0518e3          	bnez	a0,b0a <perf_monitor_end+0xca>
     c3e:	f8f1460b          	th.ldd	a2,a5,(sp),0,4
     c42:	4715                	li	a4,5
     c44:	ece793e3          	bne	a5,a4,b0a <perf_monitor_end+0xca>
     c48:	40c989bb          	subw	s3,s3,a2
     c4c:	479d                	li	a5,7
     c4e:	033787bb          	mulw	a5,a5,s3
     c52:	4735                	li	a4,13
     c54:	41b787bb          	subw	a5,a5,s11
     c58:	eae799e3          	bne	a5,a4,b0a <perf_monitor_end+0xca>
     c5c:	4762                	lw	a4,24(sp)
     c5e:	479d                	li	a5,7
     c60:	eaf715e3          	bne	a4,a5,b0a <perf_monitor_end+0xca>
     c64:	47f2                	lw	a5,28(sp)
     c66:	ea8792e3          	bne	a5,s0,b0a <perf_monitor_end+0xca>
     c6a:	6795                	lui	a5,0x5
     c6c:	54078593          	addi	a1,a5,1344 # 5540 <__errno+0x1a4>
     c70:	1008                	addi	a0,sp,32
     c72:	7df030ef          	jal	4c50 <strcmp>
     c76:	e8051ae3          	bnez	a0,b0a <perf_monitor_end+0xca>
     c7a:	6795                	lui	a5,0x5
     c7c:	56078593          	addi	a1,a5,1376 # 5560 <__errno+0x1c4>
     c80:	0088                	addi	a0,sp,64
     c82:	7cf030ef          	jal	4c50 <strcmp>
     c86:	e80512e3          	bnez	a0,b0a <perf_monitor_end+0xca>
     c8a:	6515                	lui	a0,0x5
     c8c:	58050513          	addi	a0,a0,1408 # 5580 <__errno+0x1e4>
     c90:	280030ef          	jal	3f10 <puts>
     c94:	b541                	j	b14 <perf_monitor_end+0xd4>
	...

0000000000000ca0 <Proc_6>:
     ca0:	4789                	li	a5,2
     ca2:	02f50963          	beq	a0,a5,cd4 <Proc_6+0x34>
     ca6:	470d                	li	a4,3
     ca8:	c198                	sw	a4,0(a1)
     caa:	4705                	li	a4,1
     cac:	00e50863          	beq	a0,a4,cbc <Proc_6+0x1c>
     cb0:	4711                	li	a4,4
     cb2:	02e50563          	beq	a0,a4,cdc <Proc_6+0x3c>
     cb6:	c919                	beqz	a0,ccc <Proc_6+0x2c>
     cb8:	8082                	ret
     cba:	0001                	nop
     cbc:	000417b7          	lui	a5,0x41
     cc0:	0f87a703          	lw	a4,248(a5) # 410f8 <Int_Glob>
     cc4:	06400793          	li	a5,100
     cc8:	fee7d8e3          	bge	a5,a4,cb8 <Proc_6+0x18>
     ccc:	0005a023          	sw	zero,0(a1)
     cd0:	8082                	ret
     cd2:	0001                	nop
     cd4:	4785                	li	a5,1
     cd6:	c19c                	sw	a5,0(a1)
     cd8:	8082                	ret
     cda:	0001                	nop
     cdc:	c19c                	sw	a5,0(a1)
     cde:	8082                	ret

0000000000000ce0 <Proc_7>:
     ce0:	2509                	addiw	a0,a0,2
     ce2:	9d2d                	addw	a0,a0,a1
     ce4:	c208                	sw	a0,0(a2)
     ce6:	8082                	ret
     ce8:	00000013          	nop
     cec:	00000013          	nop

0000000000000cf0 <Proc_8>:
     cf0:	0056079b          	addiw	a5,a2,5
     cf4:	0c800813          	li	a6,200
     cf8:	03078833          	mul	a6,a5,a6
     cfc:	060a                	slli	a2,a2,0x2
     cfe:	44f5568b          	th.srw	a3,a0,a5,2
     d02:	04f5188b          	th.addsl	a7,a0,a5,2
     d06:	00c80733          	add	a4,a6,a2
     d0a:	06f8ac23          	sw	a5,120(a7)
     d0e:	00d8a223          	sw	a3,4(a7)
     d12:	972e                	add	a4,a4,a1
     d14:	4b14                	lw	a3,16(a4)
     d16:	cf1c                	sw	a5,24(a4)
     d18:	95c2                	add	a1,a1,a6
     d1a:	2685                	addiw	a3,a3,1
     d1c:	e4f7568b          	th.swd	a3,a5,(a4),2,3
     d20:	44f5468b          	th.lrw	a3,a0,a5,2
     d24:	95b2                	add	a1,a1,a2
     d26:	7ff58593          	addi	a1,a1,2047
     d2a:	000417b7          	lui	a5,0x41
     d2e:	4715                	li	a4,5
     d30:	0ee7ac23          	sw	a4,248(a5) # 410f8 <Int_Glob>
     d34:	7ad5aaa3          	sw	a3,1973(a1)
     d38:	8082                	ret
     d3a:	00000013          	nop
     d3e:	0001                	nop

0000000000000d40 <Func_1>:
     d40:	0ff57513          	zext.b	a0,a0
     d44:	0ff5f593          	zext.b	a1,a1
     d48:	00b50463          	beq	a0,a1,d50 <Func_1+0x10>
     d4c:	4501                	li	a0,0
     d4e:	8082                	ret
     d50:	000417b7          	lui	a5,0x41
     d54:	02a78023          	sb	a0,32(a5) # 41020 <Ch_1_Glob>
     d58:	4505                	li	a0,1
     d5a:	8082                	ret
     d5c:	00000013          	nop

0000000000000d60 <Func_2>:
     d60:	00254703          	lbu	a4,2(a0)
     d64:	0035c783          	lbu	a5,3(a1)
     d68:	02f70363          	beq	a4,a5,d8e <Func_2+0x2e>
     d6c:	1141                	addi	sp,sp,-16
     d6e:	e406                	sd	ra,8(sp)
     d70:	6e1030ef          	jal	4c50 <strcmp>
     d74:	4781                	li	a5,0
     d76:	00a05863          	blez	a0,d86 <Func_2+0x26>
     d7a:	000417b7          	lui	a5,0x41
     d7e:	4729                	li	a4,10
     d80:	0ee7ac23          	sw	a4,248(a5) # 410f8 <Int_Glob>
     d84:	4785                	li	a5,1
     d86:	60a2                	ld	ra,8(sp)
     d88:	853e                	mv	a0,a5
     d8a:	0141                	addi	sp,sp,16
     d8c:	8082                	ret
     d8e:	a001                	j	d8e <Func_2+0x2e>

0000000000000d90 <Func_3>:
     d90:	1579                	addi	a0,a0,-2
     d92:	00153513          	seqz	a0,a0
     d96:	8082                	ret
	...

0000000000000da0 <fputc>:
     da0:	020007b7          	lui	a5,0x2000
     da4:	fea7a823          	sw	a0,-16(a5) # 1fffff0 <__kernel_stack+0x1f11ff0>
     da8:	8082                	ret
     daa:	00000013          	nop
     dae:	0001                	nop

0000000000000db0 <os_critical_enter>:
     db0:	8082                	ret
     db2:	0001                	nop
     db4:	00000013          	nop
     db8:	00000013          	nop
     dbc:	00000013          	nop

0000000000000dc0 <os_critical_exit>:
     dc0:	8082                	ret
	...

0000000000000dd0 <_out_buffer>:
     dd0:	00d67463          	bgeu	a2,a3,dd8 <_out_buffer+0x8>
     dd4:	00c5d50b          	th.srb	a0,a1,a2,0
     dd8:	8082                	ret
     dda:	00000013          	nop
     dde:	0001                	nop

0000000000000de0 <_out_null>:
     de0:	8082                	ret
     de2:	0001                	nop
     de4:	00000013          	nop
     de8:	00000013          	nop
     dec:	00000013          	nop

0000000000000df0 <_out_fct>:
     df0:	c501                	beqz	a0,df8 <_out_fct+0x8>
     df2:	619c                	ld	a5,0(a1)
     df4:	658c                	ld	a1,8(a1)
     df6:	8782                	jr	a5
     df8:	8082                	ret
     dfa:	00000013          	nop
     dfe:	0001                	nop

0000000000000e00 <_out_char>:
     e00:	e111                	bnez	a0,e04 <_out_char+0x4>
     e02:	8082                	ret
     e04:	55fd                	li	a1,-1
     e06:	bf69                	j	da0 <fputc>
     e08:	00000013          	nop
     e0c:	00000013          	nop

0000000000000e10 <_ftoa>:
     e10:	7119                	addi	sp,sp,-128
     e12:	fc5e                	sd	s7,56(sp)
     e14:	e0da                	sd	s6,64(sp)
     e16:	8b3e                	mv	s6,a5
     e18:	a2a527d3          	feq.d	a5,fa0,fa0
     e1c:	e4d6                	sd	s5,72(sp)
     e1e:	e8d2                	sd	s4,80(sp)
     e20:	ecce                	sd	s3,88(sp)
     e22:	f0ca                	sd	s2,96(sp)
     e24:	f4a6                	sd	s1,104(sp)
     e26:	f8a2                	sd	s0,112(sp)
     e28:	f466                	sd	s9,40(sp)
     e2a:	fc86                	sd	ra,120(sp)
     e2c:	892a                	mv	s2,a0
     e2e:	89ae                	mv	s3,a1
     e30:	8ab2                	mv	s5,a2
     e32:	8a36                	mv	s4,a3
     e34:	8bc2                	mv	s7,a6
     e36:	1c078163          	beqz	a5,ff8 <_ftoa+0x1e8>
     e3a:	6795                	lui	a5,0x5
     e3c:	7e07b787          	fld	fa5,2016(a5) # 57e0 <pow10.0+0x50>
     e40:	a2f517d3          	flt.d	a5,fa0,fa5
     e44:	36079263          	bnez	a5,11a8 <_ftoa+0x398>
     e48:	6795                	lui	a5,0x5
     e4a:	7e87b787          	fld	fa5,2024(a5) # 57e8 <pow10.0+0x58>
     e4e:	f06a                	sd	s10,32(sp)
     e50:	a2a797d3          	flt.d	a5,fa5,fa0
     e54:	e7e5                	bnez	a5,f3c <_ftoa+0x12c>
     e56:	6795                	lui	a5,0x5
     e58:	7f07b787          	fld	fa5,2032(a5) # 57f0 <pow10.0+0x60>
     e5c:	f862                	sd	s8,48(sp)
     e5e:	a2a797d3          	flt.d	a5,fa5,fa0
     e62:	44079363          	bnez	a5,12a8 <_ftoa+0x498>
     e66:	6795                	lui	a5,0x5
     e68:	7f87b787          	fld	fa5,2040(a5) # 57f8 <pow10.0+0x68>
     e6c:	a2f517d3          	flt.d	a5,fa0,fa5
     e70:	6c079a63          	bnez	a5,1544 <_ftoa+0x734>
     e74:	f20007d3          	fmv.d.x	fa5,zero
     e78:	a2f517d3          	flt.d	a5,fa0,fa5
     e7c:	4501                	li	a0,0
     e7e:	32079163          	bnez	a5,11a0 <_ftoa+0x390>
     e82:	400bf693          	andi	a3,s7,1024
     e86:	4799                	li	a5,6
     e88:	40d7970b          	th.mveqz	a4,a5,a3
     e8c:	fe07059b          	addiw	a1,a4,-32
     e90:	4401                	li	s0,0
     e92:	8c0a                	mv	s8,sp
     e94:	46a5                	li	a3,9
     e96:	03000613          	li	a2,48
     e9a:	0001                	nop
     e9c:	00000013          	nop
     ea0:	00e6fc63          	bgeu	a3,a4,eb8 <_ftoa+0xa8>
     ea4:	0405                	addi	s0,s0,1
     ea6:	008c07b3          	add	a5,s8,s0
     eaa:	377d                	addiw	a4,a4,-1
     eac:	fec78fa3          	sb	a2,-1(a5)
     eb0:	feb718e3          	bne	a4,a1,ea0 <_ftoa+0x90>
     eb4:	02000413          	li	s0,32
     eb8:	c2051653          	fcvt.w.d	a2,fa0,rtz
     ebc:	6795                	lui	a5,0x5
     ebe:	d20607d3          	fcvt.d.w	fa5,a2
     ec2:	79078793          	addi	a5,a5,1936 # 5790 <pow10.0>
     ec6:	76e7e68b          	th.flurd	fa3,a5,a4,3
     eca:	0af577d3          	fsub.d	fa5,fa0,fa5
     ece:	6599                	lui	a1,0x6
     ed0:	8285b707          	fld	fa4,-2008(a1) # 5828 <pow10.0+0x98>
     ed4:	12d7f7d3          	fmul.d	fa5,fa5,fa3
     ed8:	0006079b          	sext.w	a5,a2
     edc:	c23796d3          	fcvt.lu.d	a3,fa5,rtz
     ee0:	d236f653          	fcvt.d.lu	fa2,a3
     ee4:	0ac7f7d3          	fsub.d	fa5,fa5,fa2
     ee8:	a2f71853          	flt.d	a6,fa4,fa5
     eec:	1a080863          	beqz	a6,109c <_ftoa+0x28c>
     ef0:	0685                	addi	a3,a3,1
     ef2:	d236f7d3          	fcvt.d.lu	fa5,a3
     ef6:	a2f68853          	fle.d	a6,fa3,fa5
     efa:	00080563          	beqz	a6,f04 <_ftoa+0xf4>
     efe:	0016079b          	addiw	a5,a2,1
     f02:	4681                	li	a3,0
     f04:	1a070663          	beqz	a4,10b0 <_ftoa+0x2a0>
     f08:	fe07089b          	addiw	a7,a4,-32
     f0c:	008888bb          	addw	a7,a7,s0
     f10:	45a9                	li	a1,10
     f12:	4325                	li	t1,9
     f14:	00000013          	nop
     f18:	39170563          	beq	a4,a7,12a2 <_ftoa+0x492>
     f1c:	02b6f633          	remu	a2,a3,a1
     f20:	0405                	addi	s0,s0,1
     f22:	008c0833          	add	a6,s8,s0
     f26:	377d                	addiw	a4,a4,-1
     f28:	0306061b          	addiw	a2,a2,48
     f2c:	fec80fa3          	sb	a2,-1(a6)
     f30:	02b6d633          	divu	a2,a3,a1
     f34:	34d37463          	bgeu	t1,a3,127c <_ftoa+0x46c>
     f38:	86b2                	mv	a3,a2
     f3a:	bff9                	j	f18 <_ftoa+0x108>
     f3c:	00487793          	andi	a5,a6,4
     f40:	24079a63          	bnez	a5,1194 <_ftoa+0x384>
     f44:	6c95                	lui	s9,0x5
     f46:	5c8c8c93          	addi	s9,s9,1480 # 55c8 <__errno+0x22c>
     f4a:	4d0d                	li	s10,3
     f4c:	003bf793          	andi	a5,s7,3
     f50:	84d6                	mv	s1,s5
     f52:	eb95                	bnez	a5,f86 <_ftoa+0x176>
     f54:	f862                	sd	s8,48(sp)
     f56:	7c0b3c0b          	th.extu	s8,s6,31,0
     f5a:	678d7263          	bgeu	s10,s8,15be <_ftoa+0x7ae>
     f5e:	8456                	mv	s0,s5
     f60:	415d04b3          	sub	s1,s10,s5
     f64:	00000013          	nop
     f68:	8622                	mv	a2,s0
     f6a:	86d2                	mv	a3,s4
     f6c:	85ce                	mv	a1,s3
     f6e:	02000513          	li	a0,32
     f72:	0405                	addi	s0,s0,1
     f74:	9902                	jalr	s2
     f76:	008487b3          	add	a5,s1,s0
     f7a:	ff87e7e3          	bltu	a5,s8,f68 <_ftoa+0x158>
     f7e:	9c56                	add	s8,s8,s5
     f80:	41ac04b3          	sub	s1,s8,s10
     f84:	7c42                	ld	s8,48(sp)
     f86:	01ac8433          	add	s0,s9,s10
     f8a:	fff44503          	lbu	a0,-1(s0)
     f8e:	86d2                	mv	a3,s4
     f90:	8626                	mv	a2,s1
     f92:	85ce                	mv	a1,s3
     f94:	9902                	jalr	s2
     f96:	ffe44503          	lbu	a0,-2(s0)
     f9a:	86d2                	mv	a3,s4
     f9c:	00148613          	addi	a2,s1,1
     fa0:	85ce                	mv	a1,s3
     fa2:	9902                	jalr	s2
     fa4:	ffdd0413          	addi	s0,s10,-3
     fa8:	808cc50b          	th.lrbu	a0,s9,s0,0
     fac:	86d2                	mv	a3,s4
     fae:	00248613          	addi	a2,s1,2
     fb2:	85ce                	mv	a1,s3
     fb4:	9902                	jalr	s2
     fb6:	c801                	beqz	s0,fc6 <_ftoa+0x1b6>
     fb8:	000cc503          	lbu	a0,0(s9)
     fbc:	86d2                	mv	a3,s4
     fbe:	00348613          	addi	a2,s1,3
     fc2:	85ce                	mv	a1,s3
     fc4:	9902                	jalr	s2
     fc6:	002bfb93          	andi	s7,s7,2
     fca:	94ea                	add	s1,s1,s10
     fcc:	020b8463          	beqz	s7,ff4 <_ftoa+0x1e4>
     fd0:	41548ab3          	sub	s5,s1,s5
     fd4:	7c0b3b0b          	th.extu	s6,s6,31,0
     fd8:	016afe63          	bgeu	s5,s6,ff4 <_ftoa+0x1e4>
     fdc:	00000013          	nop
     fe0:	8626                	mv	a2,s1
     fe2:	86d2                	mv	a3,s4
     fe4:	85ce                	mv	a1,s3
     fe6:	02000513          	li	a0,32
     fea:	0a85                	addi	s5,s5,1
     fec:	0485                	addi	s1,s1,1
     fee:	9902                	jalr	s2
     ff0:	ff6ae8e3          	bltu	s5,s6,fe0 <_ftoa+0x1d0>
     ff4:	7d02                	ld	s10,32(sp)
     ff6:	a069                	j	1080 <_ftoa+0x270>
     ff8:	00387793          	andi	a5,a6,3
     ffc:	f862                	sd	s8,48(sp)
     ffe:	84b2                	mv	s1,a2
    1000:	e78d                	bnez	a5,102a <_ftoa+0x21a>
    1002:	478d                	li	a5,3
    1004:	7c0b370b          	th.extu	a4,s6,31,0
    1008:	0367f163          	bgeu	a5,s6,102a <_ftoa+0x21a>
    100c:	ffd60493          	addi	s1,a2,-3
    1010:	94ba                	add	s1,s1,a4
    1012:	8432                	mv	s0,a2
    1014:	00000013          	nop
    1018:	8622                	mv	a2,s0
    101a:	86d2                	mv	a3,s4
    101c:	0405                	addi	s0,s0,1
    101e:	85ce                	mv	a1,s3
    1020:	02000513          	li	a0,32
    1024:	9902                	jalr	s2
    1026:	fe9419e3          	bne	s0,s1,1018 <_ftoa+0x208>
    102a:	6c15                	lui	s8,0x5
    102c:	5d2c0c13          	addi	s8,s8,1490 # 55d2 <__errno+0x236>
    1030:	4401                	li	s0,0
    1032:	5cf5                	li	s9,-3
    1034:	00000013          	nop
    1038:	808c450b          	th.lrbu	a0,s8,s0,0
    103c:	40848633          	sub	a2,s1,s0
    1040:	86d2                	mv	a3,s4
    1042:	85ce                	mv	a1,s3
    1044:	147d                	addi	s0,s0,-1
    1046:	9902                	jalr	s2
    1048:	ff9418e3          	bne	s0,s9,1038 <_ftoa+0x228>
    104c:	002bfb93          	andi	s7,s7,2
    1050:	048d                	addi	s1,s1,3
    1052:	020b8663          	beqz	s7,107e <_ftoa+0x26e>
    1056:	7c0b3b0b          	th.extu	s6,s6,31,0
    105a:	415487b3          	sub	a5,s1,s5
    105e:	0367f063          	bgeu	a5,s6,107e <_ftoa+0x26e>
    1062:	0001                	nop
    1064:	00000013          	nop
    1068:	8626                	mv	a2,s1
    106a:	86d2                	mv	a3,s4
    106c:	85ce                	mv	a1,s3
    106e:	02000513          	li	a0,32
    1072:	0485                	addi	s1,s1,1
    1074:	9902                	jalr	s2
    1076:	415487b3          	sub	a5,s1,s5
    107a:	ff67e7e3          	bltu	a5,s6,1068 <_ftoa+0x258>
    107e:	7c42                	ld	s8,48(sp)
    1080:	70e6                	ld	ra,120(sp)
    1082:	8526                	mv	a0,s1
    1084:	74a6                	ld	s1,104(sp)
    1086:	7446                	ld	s0,112(sp)
    1088:	7be2                	ld	s7,56(sp)
    108a:	6b06                	ld	s6,64(sp)
    108c:	6aa6                	ld	s5,72(sp)
    108e:	6a46                	ld	s4,80(sp)
    1090:	69e6                	ld	s3,88(sp)
    1092:	7906                	ld	s2,96(sp)
    1094:	7ca2                	ld	s9,40(sp)
    1096:	6109                	addi	sp,sp,128
    1098:	8082                	ret
    109a:	0001                	nop
    109c:	a2e79653          	flt.d	a2,fa5,fa4
    10a0:	e60612e3          	bnez	a2,f04 <_ftoa+0xf4>
    10a4:	48069063          	bnez	a3,1524 <_ftoa+0x714>
    10a8:	0685                	addi	a3,a3,1
    10aa:	e4071fe3          	bnez	a4,f08 <_ftoa+0xf8>
    10ae:	0001                	nop
    10b0:	d2078753          	fcvt.d.w	fa4,a5
    10b4:	8285b787          	fld	fa5,-2008(a1)
    10b8:	0ae57553          	fsub.d	fa0,fa0,fa4
    10bc:	0017871b          	addiw	a4,a5,1
    10c0:	9b79                	andi	a4,a4,-2
    10c2:	a2f516d3          	flt.d	a3,fa0,fa5
    10c6:	40d7178b          	th.mveqz	a5,a4,a3
    10ca:	02000593          	li	a1,32
    10ce:	4629                	li	a2,10
    10d0:	02b40363          	beq	s0,a1,10f6 <_ftoa+0x2e6>
    10d4:	00000013          	nop
    10d8:	02c7e73b          	remw	a4,a5,a2
    10dc:	00140693          	addi	a3,s0,1
    10e0:	02c7c7bb          	divw	a5,a5,a2
    10e4:	0307071b          	addiw	a4,a4,48
    10e8:	008c570b          	th.srb	a4,s8,s0,0
    10ec:	14078263          	beqz	a5,1230 <_ftoa+0x420>
    10f0:	8436                	mv	s0,a3
    10f2:	feb413e3          	bne	s0,a1,10d8 <_ftoa+0x2c8>
    10f6:	003bf793          	andi	a5,s7,3
    10fa:	4705                	li	a4,1
    10fc:	14e79963          	bne	a5,a4,124e <_ftoa+0x43e>
    1100:	8cd6                	mv	s9,s5
    1102:	040b0363          	beqz	s6,1148 <_ftoa+0x338>
    1106:	44050b63          	beqz	a0,155c <_ftoa+0x74c>
    110a:	3b7d                	addiw	s6,s6,-1
    110c:	7c0b368b          	th.extu	a3,s6,31,0
    1110:	03647c63          	bgeu	s0,s6,1148 <_ftoa+0x338>
    1114:	02000713          	li	a4,32
    1118:	03000613          	li	a2,48
    111c:	00000013          	nop
    1120:	40e40863          	beq	s0,a4,1530 <_ftoa+0x720>
    1124:	0405                	addi	s0,s0,1
    1126:	008c07b3          	add	a5,s8,s0
    112a:	fec78fa3          	sb	a2,-1(a5)
    112e:	fed419e3          	bne	s0,a3,1120 <_ftoa+0x310>
    1132:	3ee40f63          	beq	s0,a4,1530 <_ftoa+0x720>
    1136:	46050963          	beqz	a0,15a8 <_ftoa+0x798>
    113a:	968a                	add	a3,a3,sp
    113c:	02d00793          	li	a5,45
    1140:	0405                	addi	s0,s0,1
    1142:	00f68023          	sb	a5,0(a3)
    1146:	8cd6                	mv	s9,s5
    1148:	9ca2                	add	s9,s9,s0
    114a:	019c0d33          	add	s10,s8,s9
    114e:	9462                	add	s0,s0,s8
    1150:	408d0633          	sub	a2,s10,s0
    1154:	89f4450b          	th.lbuib	a0,(s0),-1,0
    1158:	86d2                	mv	a3,s4
    115a:	85ce                	mv	a1,s3
    115c:	84e6                	mv	s1,s9
    115e:	9902                	jalr	s2
    1160:	fe8c18e3          	bne	s8,s0,1150 <_ftoa+0x340>
    1164:	002bfb93          	andi	s7,s7,2
    1168:	020b8263          	beqz	s7,118c <_ftoa+0x37c>
    116c:	415c8ab3          	sub	s5,s9,s5
    1170:	7c0b3b0b          	th.extu	s6,s6,31,0
    1174:	016afc63          	bgeu	s5,s6,118c <_ftoa+0x37c>
    1178:	8626                	mv	a2,s1
    117a:	86d2                	mv	a3,s4
    117c:	85ce                	mv	a1,s3
    117e:	02000513          	li	a0,32
    1182:	0a85                	addi	s5,s5,1
    1184:	0485                	addi	s1,s1,1
    1186:	9902                	jalr	s2
    1188:	ff6ae8e3          	bltu	s5,s6,1178 <_ftoa+0x368>
    118c:	7c42                	ld	s8,48(sp)
    118e:	7d02                	ld	s10,32(sp)
    1190:	bdc5                	j	1080 <_ftoa+0x270>
    1192:	0001                	nop
    1194:	6c95                	lui	s9,0x5
    1196:	5c0c8c93          	addi	s9,s9,1472 # 55c0 <__errno+0x224>
    119a:	4d11                	li	s10,4
    119c:	bb45                	j	f4c <_ftoa+0x13c>
    119e:	0001                	nop
    11a0:	0aa7f553          	fsub.d	fa0,fa5,fa0
    11a4:	4505                	li	a0,1
    11a6:	b9f1                	j	e82 <_ftoa+0x72>
    11a8:	00387793          	andi	a5,a6,3
    11ac:	f862                	sd	s8,48(sp)
    11ae:	84b2                	mv	s1,a2
    11b0:	e78d                	bnez	a5,11da <_ftoa+0x3ca>
    11b2:	4791                	li	a5,4
    11b4:	7c0b370b          	th.extu	a4,s6,31,0
    11b8:	0367f163          	bgeu	a5,s6,11da <_ftoa+0x3ca>
    11bc:	ffc60493          	addi	s1,a2,-4
    11c0:	94ba                	add	s1,s1,a4
    11c2:	8432                	mv	s0,a2
    11c4:	00000013          	nop
    11c8:	8622                	mv	a2,s0
    11ca:	86d2                	mv	a3,s4
    11cc:	0405                	addi	s0,s0,1
    11ce:	85ce                	mv	a1,s3
    11d0:	02000513          	li	a0,32
    11d4:	9902                	jalr	s2
    11d6:	fe9419e3          	bne	s0,s1,11c8 <_ftoa+0x3b8>
    11da:	6c15                	lui	s8,0x5
    11dc:	5dbc0c13          	addi	s8,s8,1499 # 55db <__errno+0x23f>
    11e0:	4401                	li	s0,0
    11e2:	5cf1                	li	s9,-4
    11e4:	00000013          	nop
    11e8:	808c450b          	th.lrbu	a0,s8,s0,0
    11ec:	40848633          	sub	a2,s1,s0
    11f0:	86d2                	mv	a3,s4
    11f2:	85ce                	mv	a1,s3
    11f4:	147d                	addi	s0,s0,-1
    11f6:	9902                	jalr	s2
    11f8:	ff9418e3          	bne	s0,s9,11e8 <_ftoa+0x3d8>
    11fc:	002bfb93          	andi	s7,s7,2
    1200:	0491                	addi	s1,s1,4
    1202:	e60b8ee3          	beqz	s7,107e <_ftoa+0x26e>
    1206:	7c0b3b0b          	th.extu	s6,s6,31,0
    120a:	415487b3          	sub	a5,s1,s5
    120e:	e767f8e3          	bgeu	a5,s6,107e <_ftoa+0x26e>
    1212:	0001                	nop
    1214:	00000013          	nop
    1218:	8626                	mv	a2,s1
    121a:	86d2                	mv	a3,s4
    121c:	85ce                	mv	a1,s3
    121e:	02000513          	li	a0,32
    1222:	0485                	addi	s1,s1,1
    1224:	9902                	jalr	s2
    1226:	415487b3          	sub	a5,s1,s5
    122a:	ff67e7e3          	bltu	a5,s6,1218 <_ftoa+0x408>
    122e:	bd81                	j	107e <_ftoa+0x26e>
    1230:	003bf793          	andi	a5,s7,3
    1234:	4705                	li	a4,1
    1236:	3ae78d63          	beq	a5,a4,15f0 <_ftoa+0x7e0>
    123a:	3ab68963          	beq	a3,a1,15ec <_ftoa+0x7dc>
    123e:	2a050563          	beqz	a0,14e8 <_ftoa+0x6d8>
    1242:	968a                	add	a3,a3,sp
    1244:	02d00713          	li	a4,45
    1248:	0409                	addi	s0,s0,2
    124a:	00e68023          	sb	a4,0(a3)
    124e:	ee079ce3          	bnez	a5,1146 <_ftoa+0x336>
    1252:	7c0b3c8b          	th.extu	s9,s6,31,0
    1256:	ef9478e3          	bgeu	s0,s9,1146 <_ftoa+0x336>
    125a:	408c8cb3          	sub	s9,s9,s0
    125e:	9cd6                	add	s9,s9,s5
    1260:	84d6                	mv	s1,s5
    1262:	0001                	nop
    1264:	00000013          	nop
    1268:	8626                	mv	a2,s1
    126a:	86d2                	mv	a3,s4
    126c:	0485                	addi	s1,s1,1
    126e:	85ce                	mv	a1,s3
    1270:	02000513          	li	a0,32
    1274:	9902                	jalr	s2
    1276:	fe9c99e3          	bne	s9,s1,1268 <_ftoa+0x458>
    127a:	b5f9                	j	1148 <_ftoa+0x338>
    127c:	02000613          	li	a2,32
    1280:	02c40163          	beq	s0,a2,12a2 <_ftoa+0x492>
    1284:	7c07370b          	th.extu	a4,a4,31,0
    1288:	9722                	add	a4,a4,s0
    128a:	03000593          	li	a1,48
    128e:	0001                	nop
    1290:	24870463          	beq	a4,s0,14d8 <_ftoa+0x6c8>
    1294:	0405                	addi	s0,s0,1
    1296:	008c06b3          	add	a3,s8,s0
    129a:	feb68fa3          	sb	a1,-1(a3)
    129e:	fec419e3          	bne	s0,a2,1290 <_ftoa+0x480>
    12a2:	02000413          	li	s0,32
    12a6:	b515                	j	10ca <_ftoa+0x2ba>
    12a8:	e20506d3          	fmv.x.d	a3,fa0
    12ac:	6599                	lui	a1,0x6
    12ae:	6619                	lui	a2,0x6
    12b0:	fb46b78b          	th.extu	a5,a3,62,52
    12b4:	8005b607          	fld	fa2,-2048(a1) # 5800 <pow10.0+0x70>
    12b8:	80863687          	fld	fa3,-2040(a2) # 5808 <pow10.0+0x78>
    12bc:	c017879b          	addiw	a5,a5,-1023
    12c0:	d2078753          	fcvt.d.w	fa4,a5
    12c4:	3ff00613          	li	a2,1023
    12c8:	6799                	lui	a5,0x6
    12ca:	8107b787          	fld	fa5,-2032(a5) # 5810 <pow10.0+0x80>
    12ce:	1652                	slli	a2,a2,0x34
    12d0:	cc06b78b          	th.extu	a5,a3,51,0
    12d4:	6ac77743          	fmadd.d	fa4,fa4,fa2,fa3
    12d8:	8fd1                	or	a5,a5,a2
    12da:	f20786d3          	fmv.d.x	fa3,a5
    12de:	6619                	lui	a2,0x6
    12e0:	0af6f7d3          	fsub.d	fa5,fa3,fa5
    12e4:	81863687          	fld	fa3,-2024(a2) # 5818 <pow10.0+0x88>
    12e8:	6619                	lui	a2,0x6
    12ea:	6799                	lui	a5,0x6
    12ec:	72d7f7c3          	fmadd.d	fa5,fa5,fa3,fa4
    12f0:	82063707          	fld	fa4,-2016(a2) # 5820 <pow10.0+0x90>
    12f4:	8287b687          	fld	fa3,-2008(a5) # 5828 <pow10.0+0x98>
    12f8:	6799                	lui	a5,0x6
    12fa:	8307b007          	fld	ft0,-2000(a5) # 5830 <pow10.0+0xa0>
    12fe:	c2079653          	fcvt.w.d	a2,fa5,rtz
    1302:	6799                	lui	a5,0x6
    1304:	d20607d3          	fcvt.d.w	fa5,a2
    1308:	8387b607          	fld	fa2,-1992(a5) # 5838 <pow10.0+0xa8>
    130c:	6ae7f6c3          	fmadd.d	fa3,fa5,fa4,fa3
    1310:	6799                	lui	a5,0x6
    1312:	8407b707          	fld	fa4,-1984(a5) # 5840 <pow10.0+0xb0>
    1316:	6799                	lui	a5,0x6
    1318:	8487b587          	fld	fa1,-1976(a5) # 5848 <pow10.0+0xb8>
    131c:	c20697d3          	fcvt.w.d	a5,fa3,rtz
    1320:	6599                	lui	a1,0x6
    1322:	d20786d3          	fcvt.d.w	fa3,a5
    1326:	8505b087          	fld	ft1,-1968(a1) # 5850 <pow10.0+0xc0>
    132a:	1206f6d3          	fmul.d	fa3,fa3,ft0
    132e:	6599                	lui	a1,0x6
    1330:	3ff7879b          	addiw	a5,a5,1023
    1334:	17d2                	slli	a5,a5,0x34
    1336:	6ac7f7c7          	fmsub.d	fa5,fa5,fa2,fa3
    133a:	8585b607          	fld	fa2,-1960(a1) # 5858 <pow10.0+0xc8>
    133e:	6599                	lui	a1,0x6
    1340:	8605b007          	fld	ft0,-1952(a1) # 5860 <pow10.0+0xd0>
    1344:	4519                	li	a0,6
    1346:	12f7f6d3          	fmul.d	fa3,fa5,fa5
    134a:	0af67653          	fsub.d	fa2,fa2,fa5
    134e:	02f7f7d3          	fadd.d	fa5,fa5,fa5
    1352:	400bf593          	andi	a1,s7,1024
    1356:	1ae6f753          	fdiv.d	fa4,fa3,fa4
    135a:	40b5170b          	th.mveqz	a4,a0,a1
    135e:	00060c9b          	sext.w	s9,a2
    1362:	02b77753          	fadd.d	fa4,fa4,fa1
    1366:	1ae6f753          	fdiv.d	fa4,fa3,fa4
    136a:	02177753          	fadd.d	fa4,fa4,ft1
    136e:	1ae6f6d3          	fdiv.d	fa3,fa3,fa4
    1372:	f2078753          	fmv.d.x	fa4,a5
    1376:	02c6f6d3          	fadd.d	fa3,fa3,fa2
    137a:	1ad7f7d3          	fdiv.d	fa5,fa5,fa3
    137e:	0207f7d3          	fadd.d	fa5,fa5,ft0
    1382:	12e7f7d3          	fmul.d	fa5,fa5,fa4
    1386:	f2068753          	fmv.d.x	fa4,a3
    138a:	a2f717d3          	flt.d	a5,fa4,fa5
    138e:	c789                	beqz	a5,1398 <_ftoa+0x588>
    1390:	1ab7f7d3          	fdiv.d	fa5,fa5,fa1
    1394:	fff60c9b          	addiw	s9,a2,-1
    1398:	063c879b          	addiw	a5,s9,99
    139c:	0c600613          	li	a2,198
    13a0:	14f67e63          	bgeu	a2,a5,14fc <_ftoa+0x6ec>
    13a4:	4d0d                	li	s10,3
    13a6:	4615                	li	a2,5
    13a8:	6785                	lui	a5,0x1
    13aa:	80078793          	addi	a5,a5,-2048 # 800 <main+0x10>
    13ae:	00fbf7b3          	and	a5,s7,a5
    13b2:	002bf413          	andi	s0,s7,2
    13b6:	18078163          	beqz	a5,1538 <_ftoa+0x728>
    13ba:	18070a63          	beqz	a4,154e <_ftoa+0x73e>
    13be:	18058863          	beqz	a1,154e <_ftoa+0x73e>
    13c2:	377d                	addiw	a4,a4,-1
    13c4:	01667563          	bgeu	a2,s6,13ce <_ftoa+0x5be>
    13c8:	1c040d63          	beqz	s0,15a2 <_ftoa+0x792>
    13cc:	4409                	li	s0,2
    13ce:	4781                	li	a5,0
    13d0:	000c8863          	beqz	s9,13e0 <_ftoa+0x5d0>
    13d4:	f2068753          	fmv.d.x	fa4,a3
    13d8:	1af777d3          	fdiv.d	fa5,fa4,fa5
    13dc:	e20786d3          	fmv.x.d	a3,fa5
    13e0:	f20007d3          	fmv.d.x	fa5,zero
    13e4:	a2f51653          	flt.d	a2,fa0,fa5
    13e8:	c619                	beqz	a2,13f6 <_ftoa+0x5e6>
    13ea:	f20687d3          	fmv.d.x	fa5,a3
    13ee:	22f797d3          	fneg.d	fa5,fa5
    13f2:	e20786d3          	fmv.x.d	a3,fa5
    13f6:	787d                	lui	a6,0xfffff
    13f8:	7ff80813          	addi	a6,a6,2047 # fffffffffffff7ff <__kernel_stack+0xfffffffffff117ff>
    13fc:	010bf833          	and	a6,s7,a6
    1400:	f2068553          	fmv.d.x	fa0,a3
    1404:	8656                	mv	a2,s5
    1406:	86d2                	mv	a3,s4
    1408:	85ce                	mv	a1,s3
    140a:	854a                	mv	a0,s2
    140c:	a05ff0ef          	jal	e10 <_ftoa>
    1410:	862a                	mv	a2,a0
    1412:	06500793          	li	a5,101
    1416:	020bfb93          	andi	s7,s7,32
    141a:	04500513          	li	a0,69
    141e:	4177950b          	th.mveqz	a0,a5,s7
    1422:	86d2                	mv	a3,s4
    1424:	85ce                	mv	a1,s3
    1426:	00160493          	addi	s1,a2,1
    142a:	9902                	jalr	s2
    142c:	41fcd79b          	sraiw	a5,s9,0x1f
    1430:	00fcc733          	xor	a4,s9,a5
    1434:	9f1d                	subw	a4,a4,a5
    1436:	8c0a                	mv	s8,sp
    1438:	4681                	li	a3,0
    143a:	45a9                	li	a1,10
    143c:	4825                	li	a6,9
    143e:	02000893          	li	a7,32
    1442:	a019                	j	1448 <_ftoa+0x638>
    1444:	15168a63          	beq	a3,a7,1598 <_ftoa+0x788>
    1448:	02b77633          	remu	a2,a4,a1
    144c:	0685                	addi	a3,a3,1
    144e:	00dc07b3          	add	a5,s8,a3
    1452:	853a                	mv	a0,a4
    1454:	0306061b          	addiw	a2,a2,48
    1458:	fec78fa3          	sb	a2,-1(a5)
    145c:	02b75733          	divu	a4,a4,a1
    1460:	fea862e3          	bltu	a6,a0,1444 <_ftoa+0x634>
    1464:	13a6f663          	bgeu	a3,s10,1590 <_ftoa+0x780>
    1468:	01ac06b3          	add	a3,s8,s10
    146c:	03000713          	li	a4,48
    1470:	1817d70b          	th.sbia	a4,(a5),1,0
    1474:	fef69ee3          	bne	a3,a5,1470 <_ftoa+0x660>
    1478:	001d0b93          	addi	s7,s10,1
    147c:	140cda63          	bgez	s9,15d0 <_ftoa+0x7c0>
    1480:	02d00513          	li	a0,45
    1484:	01ac550b          	th.srb	a0,s8,s10,0
    1488:	01748cb3          	add	s9,s1,s7
    148c:	a031                	j	1498 <_ftoa+0x688>
    148e:	0001                	nop
    1490:	017c07b3          	add	a5,s8,s7
    1494:	fff7c503          	lbu	a0,-1(a5)
    1498:	417c8633          	sub	a2,s9,s7
    149c:	86d2                	mv	a3,s4
    149e:	1bfd                	addi	s7,s7,-1
    14a0:	85ce                	mv	a1,s3
    14a2:	84e6                	mv	s1,s9
    14a4:	9902                	jalr	s2
    14a6:	fe0b95e3          	bnez	s7,1490 <_ftoa+0x680>
    14aa:	ce0401e3          	beqz	s0,118c <_ftoa+0x37c>
    14ae:	415c8ab3          	sub	s5,s9,s5
    14b2:	7c0b3b0b          	th.extu	s6,s6,31,0
    14b6:	cd6afbe3          	bgeu	s5,s6,118c <_ftoa+0x37c>
    14ba:	0001                	nop
    14bc:	00000013          	nop
    14c0:	8626                	mv	a2,s1
    14c2:	86d2                	mv	a3,s4
    14c4:	85ce                	mv	a1,s3
    14c6:	02000513          	li	a0,32
    14ca:	0a85                	addi	s5,s5,1
    14cc:	0485                	addi	s1,s1,1
    14ce:	9902                	jalr	s2
    14d0:	ff6ae8e3          	bltu	s5,s6,14c0 <_ftoa+0x6b0>
    14d4:	7c42                	ld	s8,48(sp)
    14d6:	b965                	j	118e <_ftoa+0x37e>
    14d8:	970a                	add	a4,a4,sp
    14da:	02e00693          	li	a3,46
    14de:	0405                	addi	s0,s0,1
    14e0:	00d70023          	sb	a3,0(a4)
    14e4:	b6dd                	j	10ca <_ftoa+0x2ba>
    14e6:	0001                	nop
    14e8:	004bf713          	andi	a4,s7,4
    14ec:	cf11                	beqz	a4,1508 <_ftoa+0x6f8>
    14ee:	968a                	add	a3,a3,sp
    14f0:	02b00713          	li	a4,43
    14f4:	0409                	addi	s0,s0,2
    14f6:	00e68023          	sb	a4,0(a3)
    14fa:	bb91                	j	124e <_ftoa+0x43e>
    14fc:	4d09                	li	s10,2
    14fe:	4611                	li	a2,4
    1500:	b565                	j	13a8 <_ftoa+0x598>
    1502:	4785                	li	a5,1
    1504:	00000013          	nop
    1508:	008bf713          	andi	a4,s7,8
    150c:	8436                	mv	s0,a3
    150e:	d40700e3          	beqz	a4,124e <_ftoa+0x43e>
    1512:	00268733          	add	a4,a3,sp
    1516:	02000613          	li	a2,32
    151a:	00168413          	addi	s0,a3,1
    151e:	00c70023          	sb	a2,0(a4)
    1522:	b335                	j	124e <_ftoa+0x43e>
    1524:	0016f613          	andi	a2,a3,1
    1528:	9c060ee3          	beqz	a2,f04 <_ftoa+0xf4>
    152c:	0685                	addi	a3,a3,1
    152e:	beb5                	j	10aa <_ftoa+0x29a>
    1530:	02000413          	li	s0,32
    1534:	8cd6                	mv	s9,s5
    1536:	b909                	j	1148 <_ftoa+0x338>
    1538:	e9667ce3          	bgeu	a2,s6,13d0 <_ftoa+0x5c0>
    153c:	c03d                	beqz	s0,15a2 <_ftoa+0x792>
    153e:	4409                	li	s0,2
    1540:	bd41                	j	13d0 <_ftoa+0x5c0>
    1542:	0001                	nop
    1544:	22a517d3          	fneg.d	fa5,fa0
    1548:	e20786d3          	fmv.x.d	a3,fa5
    154c:	b385                	j	12ac <_ftoa+0x49c>
    154e:	e96670e3          	bgeu	a2,s6,13ce <_ftoa+0x5be>
    1552:	c821                	beqz	s0,15a2 <_ftoa+0x792>
    1554:	4781                	li	a5,0
    1556:	4409                	li	s0,2
    1558:	bda5                	j	13d0 <_ftoa+0x5c0>
    155a:	8436                	mv	s0,a3
    155c:	00cbf793          	andi	a5,s7,12
    1560:	c3ad                	beqz	a5,15c2 <_ftoa+0x7b2>
    1562:	3b7d                	addiw	s6,s6,-1
    1564:	7c0b368b          	th.extu	a3,s6,31,0
    1568:	bad466e3          	bltu	s0,a3,1114 <_ftoa+0x304>
    156c:	02000793          	li	a5,32
    1570:	bcf40be3          	beq	s0,a5,1146 <_ftoa+0x336>
    1574:	004bf793          	andi	a5,s7,4
    1578:	c3bd                	beqz	a5,15de <_ftoa+0x7ce>
    157a:	02040793          	addi	a5,s0,32
    157e:	02b00713          	li	a4,43
    1582:	978a                	add	a5,a5,sp
    1584:	fee78023          	sb	a4,-32(a5)
    1588:	0405                	addi	s0,s0,1
    158a:	8cd6                	mv	s9,s5
    158c:	be75                	j	1148 <_ftoa+0x338>
    158e:	0001                	nop
    1590:	02000793          	li	a5,32
    1594:	04f69363          	bne	a3,a5,15da <_ftoa+0x7ca>
    1598:	01f14503          	lbu	a0,31(sp)
    159c:	02000b93          	li	s7,32
    15a0:	b5e5                	j	1488 <_ftoa+0x678>
    15a2:	40cb07bb          	subw	a5,s6,a2
    15a6:	b52d                	j	13d0 <_ftoa+0x5c0>
    15a8:	004bf793          	andi	a5,s7,4
    15ac:	dbb9                	beqz	a5,1502 <_ftoa+0x6f2>
    15ae:	968a                	add	a3,a3,sp
    15b0:	02b00793          	li	a5,43
    15b4:	0405                	addi	s0,s0,1
    15b6:	00f68023          	sb	a5,0(a3)
    15ba:	8cd6                	mv	s9,s5
    15bc:	b671                	j	1148 <_ftoa+0x338>
    15be:	7c42                	ld	s8,48(sp)
    15c0:	b2d9                	j	f86 <_ftoa+0x176>
    15c2:	7c0b368b          	th.extu	a3,s6,31,0
    15c6:	b4d467e3          	bltu	s0,a3,1114 <_ftoa+0x304>
    15ca:	8cd6                	mv	s9,s5
    15cc:	beb5                	j	1148 <_ftoa+0x338>
    15ce:	0001                	nop
    15d0:	02b00513          	li	a0,43
    15d4:	01ac550b          	th.srb	a0,s8,s10,0
    15d8:	bd45                	j	1488 <_ftoa+0x678>
    15da:	8d36                	mv	s10,a3
    15dc:	bd71                	j	1478 <_ftoa+0x668>
    15de:	008bf793          	andi	a5,s7,8
    15e2:	b60782e3          	beqz	a5,1146 <_ftoa+0x336>
    15e6:	86a2                	mv	a3,s0
    15e8:	4785                	li	a5,1
    15ea:	b725                	j	1512 <_ftoa+0x702>
    15ec:	842e                	mv	s0,a1
    15ee:	b185                	j	124e <_ftoa+0x43e>
    15f0:	000b0b63          	beqz	s6,1606 <_ftoa+0x7f6>
    15f4:	d13d                	beqz	a0,155a <_ftoa+0x74a>
    15f6:	3b7d                	addiw	s6,s6,-1
    15f8:	7c0b378b          	th.extu	a5,s6,31,0
    15fc:	02f6f763          	bgeu	a3,a5,162a <_ftoa+0x81a>
    1600:	8436                	mv	s0,a3
    1602:	86be                	mv	a3,a5
    1604:	be01                	j	1114 <_ftoa+0x304>
    1606:	02b68c63          	beq	a3,a1,163e <_ftoa+0x82e>
    160a:	e115                	bnez	a0,162e <_ftoa+0x81e>
    160c:	004bf713          	andi	a4,s7,4
    1610:	ee070ce3          	beqz	a4,1508 <_ftoa+0x6f8>
    1614:	02068793          	addi	a5,a3,32
    1618:	002786b3          	add	a3,a5,sp
    161c:	02b00793          	li	a5,43
    1620:	0409                	addi	s0,s0,2
    1622:	fef68023          	sb	a5,-32(a3)
    1626:	8cd6                	mv	s9,s5
    1628:	b605                	j	1148 <_ftoa+0x338>
    162a:	00b68a63          	beq	a3,a1,163e <_ftoa+0x82e>
    162e:	968a                	add	a3,a3,sp
    1630:	02d00793          	li	a5,45
    1634:	0409                	addi	s0,s0,2
    1636:	00f68023          	sb	a5,0(a3)
    163a:	8cd6                	mv	s9,s5
    163c:	b631                	j	1148 <_ftoa+0x338>
    163e:	842e                	mv	s0,a1
    1640:	8cd6                	mv	s9,s5
    1642:	b619                	j	1148 <_ftoa+0x338>
    1644:	00000013          	nop
    1648:	00000013          	nop
    164c:	00000013          	nop

0000000000001650 <_vsnprintf>:
    1650:	7171                	addi	sp,sp,-176
    1652:	f8da                	sd	s6,112(sp)
    1654:	fcd6                	sd	s5,120(sp)
    1656:	ed26                	sd	s1,152(sp)
    1658:	f122                	sd	s0,160(sp)
    165a:	e152                	sd	s4,128(sp)
    165c:	f506                	sd	ra,168(sp)
    165e:	0006c783          	lbu	a5,0(a3)
    1662:	6a05                	lui	s4,0x1
    1664:	de0a0a13          	addi	s4,s4,-544 # de0 <_out_null>
    1668:	8b2e                	mv	s6,a1
    166a:	8ab2                	mv	s5,a2
    166c:	42b51a0b          	th.mvnez	s4,a0,a1
    1670:	4481                	li	s1,0
    1672:	30078ee3          	beqz	a5,218e <_vsnprintf+0xb3e>
    1676:	e4ee                	sd	s11,72(sp)
    1678:	e8ea                	sd	s10,80(sp)
    167a:	8dba                	mv	s11,a4
    167c:	6715                	lui	a4,0x5
    167e:	ece6                	sd	s9,88(sp)
    1680:	f0e2                	sd	s8,96(sp)
    1682:	63470713          	addi	a4,a4,1588 # 5634 <__errno+0x298>
    1686:	6c15                	lui	s8,0x5
    1688:	f4de                	sd	s7,104(sp)
    168a:	e54e                	sd	s3,136(sp)
    168c:	e94a                	sd	s2,144(sp)
    168e:	853e                	mv	a0,a5
    1690:	8936                	mv	s2,a3
    1692:	5f0c0c13          	addi	s8,s8,1520 # 55f0 <__errno+0x254>
    1696:	02500c93          	li	s9,37
    169a:	4bc1                	li	s7,16
    169c:	e03a                	sd	a4,0(sp)
    169e:	a811                	j	16b2 <_vsnprintf+0x62>
    16a0:	8626                	mv	a2,s1
    16a2:	86d6                	mv	a3,s5
    16a4:	85da                	mv	a1,s6
    16a6:	0485                	addi	s1,s1,1
    16a8:	9a02                	jalr	s4
    16aa:	00094503          	lbu	a0,0(s2)
    16ae:	14050163          	beqz	a0,17f0 <_vsnprintf+0x1a0>
    16b2:	0905                	addi	s2,s2,1
    16b4:	ff9516e3          	bne	a0,s9,16a0 <_vsnprintf+0x50>
    16b8:	4401                	li	s0,0
    16ba:	0001                	nop
    16bc:	00000013          	nop
    16c0:	87ca                	mv	a5,s2
    16c2:	9817c50b          	th.lbuia	a0,(a5),1,0
    16c6:	fe05071b          	addiw	a4,a0,-32
    16ca:	0ff77713          	zext.b	a4,a4
    16ce:	00ebe563          	bltu	s7,a4,16d8 <_vsnprintf+0x88>
    16d2:	44ec470b          	th.lrw	a4,s8,a4,2
    16d6:	8702                	jr	a4
    16d8:	fd05071b          	addiw	a4,a0,-48
    16dc:	0ff77713          	zext.b	a4,a4
    16e0:	46a5                	li	a3,9
    16e2:	0ae6f363          	bgeu	a3,a4,1788 <_vsnprintf+0x138>
    16e6:	02a00713          	li	a4,42
    16ea:	4981                	li	s3,0
    16ec:	34e50863          	beq	a0,a4,1a3c <_vsnprintf+0x3ec>
    16f0:	02e00693          	li	a3,46
    16f4:	4701                	li	a4,0
    16f6:	0cd50863          	beq	a0,a3,17c6 <_vsnprintf+0x176>
    16fa:	f985069b          	addiw	a3,a0,-104
    16fe:	0ff6f693          	zext.b	a3,a3
    1702:	4649                	li	a2,18
    1704:	04d66a63          	bltu	a2,a3,1758 <_vsnprintf+0x108>
    1708:	6602                	ld	a2,0(sp)
    170a:	44d6468b          	th.lrw	a3,a2,a3,2
    170e:	8682                	jr	a3
    1710:	00146413          	ori	s0,s0,1
    1714:	2401                	sext.w	s0,s0
    1716:	893e                	mv	s2,a5
    1718:	b765                	j	16c0 <_vsnprintf+0x70>
    171a:	0001                	nop
    171c:	00246413          	ori	s0,s0,2
    1720:	2401                	sext.w	s0,s0
    1722:	893e                	mv	s2,a5
    1724:	bf71                	j	16c0 <_vsnprintf+0x70>
    1726:	0001                	nop
    1728:	00446413          	ori	s0,s0,4
    172c:	2401                	sext.w	s0,s0
    172e:	893e                	mv	s2,a5
    1730:	bf41                	j	16c0 <_vsnprintf+0x70>
    1732:	0001                	nop
    1734:	01046413          	ori	s0,s0,16
    1738:	2401                	sext.w	s0,s0
    173a:	893e                	mv	s2,a5
    173c:	b751                	j	16c0 <_vsnprintf+0x70>
    173e:	0001                	nop
    1740:	00846413          	ori	s0,s0,8
    1744:	2401                	sext.w	s0,s0
    1746:	893e                	mv	s2,a5
    1748:	bfa5                	j	16c0 <_vsnprintf+0x70>
    174a:	0001                	nop
    174c:	00194503          	lbu	a0,1(s2)
    1750:	10046413          	ori	s0,s0,256
    1754:	2401                	sext.w	s0,s0
    1756:	0785                	addi	a5,a5,1
    1758:	06700693          	li	a3,103
    175c:	893e                	mv	s2,a5
    175e:	0ca6e563          	bltu	a3,a0,1828 <_vsnprintf+0x1d8>
    1762:	02400793          	li	a5,36
    1766:	f2a7fde3          	bgeu	a5,a0,16a0 <_vsnprintf+0x50>
    176a:	fdb5079b          	addiw	a5,a0,-37
    176e:	0ff7f793          	zext.b	a5,a5
    1772:	04200693          	li	a3,66
    1776:	f2f6e5e3          	bltu	a3,a5,16a0 <_vsnprintf+0x50>
    177a:	6695                	lui	a3,0x5
    177c:	68068693          	addi	a3,a3,1664 # 5680 <__errno+0x2e4>
    1780:	44f6c78b          	th.lrw	a5,a3,a5,2
    1784:	8782                	jr	a5
    1786:	0001                	nop
    1788:	4981                	li	s3,0
    178a:	864e                	mv	a2,s3
    178c:	a019                	j	1792 <_vsnprintf+0x142>
    178e:	0001                	nop
    1790:	0785                	addi	a5,a5,1
    1792:	0026199b          	slliw	s3,a2,0x2
    1796:	00c989bb          	addw	s3,s3,a2
    179a:	0019999b          	slliw	s3,s3,0x1
    179e:	00a989bb          	addw	s3,s3,a0
    17a2:	0007c503          	lbu	a0,0(a5)
    17a6:	fd09861b          	addiw	a2,s3,-48
    17aa:	893e                	mv	s2,a5
    17ac:	fd05071b          	addiw	a4,a0,-48
    17b0:	0ff77713          	zext.b	a4,a4
    17b4:	fce6fee3          	bgeu	a3,a4,1790 <_vsnprintf+0x140>
    17b8:	02e00693          	li	a3,46
    17bc:	89b2                	mv	s3,a2
    17be:	0785                	addi	a5,a5,1
    17c0:	4701                	li	a4,0
    17c2:	f2d51ce3          	bne	a0,a3,16fa <_vsnprintf+0xaa>
    17c6:	00194503          	lbu	a0,1(s2)
    17ca:	40046413          	ori	s0,s0,1024
    17ce:	4625                	li	a2,9
    17d0:	fd05059b          	addiw	a1,a0,-48
    17d4:	0ff5f593          	zext.b	a1,a1
    17d8:	2401                	sext.w	s0,s0
    17da:	86be                	mv	a3,a5
    17dc:	22b67c63          	bgeu	a2,a1,1a14 <_vsnprintf+0x3c4>
    17e0:	02a00693          	li	a3,42
    17e4:	56d50c63          	beq	a0,a3,1d5c <_vsnprintf+0x70c>
    17e8:	893e                	mv	s2,a5
    17ea:	0785                	addi	a5,a5,1
    17ec:	b739                	j	16fa <_vsnprintf+0xaa>
    17ee:	0001                	nop
    17f0:	6da6                	ld	s11,72(sp)
    17f2:	6d46                	ld	s10,80(sp)
    17f4:	6ce6                	ld	s9,88(sp)
    17f6:	7c06                	ld	s8,96(sp)
    17f8:	69aa                	ld	s3,136(sp)
    17fa:	694a                	ld	s2,144(sp)
    17fc:	7ba6                	ld	s7,104(sp)
    17fe:	0004841b          	sext.w	s0,s1
    1802:	0154b7b3          	sltu	a5,s1,s5
    1806:	fffa8613          	addi	a2,s5,-1
    180a:	85da                	mv	a1,s6
    180c:	42f4960b          	th.mvnez	a2,s1,a5
    1810:	86d6                	mv	a3,s5
    1812:	4501                	li	a0,0
    1814:	9a02                	jalr	s4
    1816:	70aa                	ld	ra,168(sp)
    1818:	8522                	mv	a0,s0
    181a:	64ea                	ld	s1,152(sp)
    181c:	740a                	ld	s0,160(sp)
    181e:	7b46                	ld	s6,112(sp)
    1820:	7ae6                	ld	s5,120(sp)
    1822:	6a0a                	ld	s4,128(sp)
    1824:	614d                	addi	sp,sp,176
    1826:	8082                	ret
    1828:	f975079b          	addiw	a5,a0,-105
    182c:	0ff7f793          	zext.b	a5,a5
    1830:	46bd                	li	a3,15
    1832:	e6f6e7e3          	bltu	a3,a5,16a0 <_vsnprintf+0x50>
    1836:	4605                	li	a2,1
    1838:	66a5                	lui	a3,0x9
    183a:	00f61d33          	sll	s10,a2,a5
    183e:	04168693          	addi	a3,a3,65 # 9041 <_global_impure_ptr+0x37c1>
    1842:	00dd7d33          	and	s10,s10,a3
    1846:	4e0d1c63          	bnez	s10,1d3e <_vsnprintf+0x6ee>
    184a:	46a9                	li	a3,10
    184c:	20d78263          	beq	a5,a3,1a50 <_vsnprintf+0x400>
    1850:	469d                	li	a3,7
    1852:	e4d797e3          	bne	a5,a3,16a0 <_vsnprintf+0x50>
    1856:	85ee                	mv	a1,s11
    1858:	7885c68b          	th.ldia	a3,(a1),8,0
    185c:	87a2                	mv	a5,s0
    185e:	40047e13          	andi	t3,s0,1024
    1862:	50069a63          	bnez	a3,1d76 <_vsnprintf+0x726>
    1866:	fef47313          	andi	t1,s0,-17
    186a:	02136313          	ori	t1,t1,33
    186e:	2301                	sext.w	t1,t1
    1870:	1a0e1ae3          	bnez	t3,2224 <_vsnprintf+0xbd4>
    1874:	4801                	li	a6,0
    1876:	4681                	li	a3,0
    1878:	1000                	addi	s0,sp,32
    187a:	48a5                	li	a7,9
    187c:	453d                	li	a0,15
    187e:	02000e93          	li	t4,32
    1882:	a029                	j	188c <_vsnprintf+0x23c>
    1884:	17d78ee3          	beq	a5,t4,2200 <_vsnprintf+0xbb0>
    1888:	8d3e                	mv	s10,a5
    188a:	86b2                	mv	a3,a2
    188c:	00f6f613          	andi	a2,a3,15
    1890:	87b2                	mv	a5,a2
    1892:	03078f13          	addi	t5,a5,48
    1896:	00c8b633          	sltu	a2,a7,a2
    189a:	03778793          	addi	a5,a5,55
    189e:	40cf178b          	th.mveqz	a5,t5,a2
    18a2:	01a4578b          	th.srb	a5,s0,s10,0
    18a6:	0046d613          	srli	a2,a3,0x4
    18aa:	001d0793          	addi	a5,s10,1
    18ae:	fcd56be3          	bltu	a0,a3,1884 <_vsnprintf+0x234>
    18b2:	00237693          	andi	a3,t1,2
    18b6:	06069ce3          	bnez	a3,212e <_vsnprintf+0xade>
    18ba:	00c37693          	andi	a3,t1,12
    18be:	48069ee3          	bnez	a3,255a <_vsnprintf+0xf0a>
    18c2:	4541                	li	a0,16
    18c4:	86aa                	mv	a3,a0
    18c6:	7c07360b          	th.extu	a2,a4,31,0
    18ca:	44c7e7e3          	bltu	a5,a2,2518 <_vsnprintf+0xec8>
    18ce:	866a                	mv	a2,s10
    18d0:	8d3e                	mv	s10,a5
    18d2:	87b2                	mv	a5,a2
    18d4:	00ad6463          	bltu	s10,a0,18dc <_vsnprintf+0x28c>
    18d8:	4200206f          	j	3cf8 <_vsnprintf+0x26a8>
    18dc:	03000893          	li	a7,48
    18e0:	002d07b3          	add	a5,s10,sp
    18e4:	03178023          	sb	a7,32(a5)
    18e8:	001d0613          	addi	a2,s10,1
    18ec:	0ea67c63          	bgeu	a2,a0,19e4 <_vsnprintf+0x394>
    18f0:	1000                	addi	s0,sp,32
    18f2:	008607b3          	add	a5,a2,s0
    18f6:	01178023          	sb	a7,0(a5)
    18fa:	002d0793          	addi	a5,s10,2
    18fe:	0ea7f363          	bgeu	a5,a0,19e4 <_vsnprintf+0x394>
    1902:	008d07b3          	add	a5,s10,s0
    1906:	01178123          	sb	a7,2(a5)
    190a:	003d0793          	addi	a5,s10,3
    190e:	0ca7fb63          	bgeu	a5,a0,19e4 <_vsnprintf+0x394>
    1912:	002788b3          	add	a7,a5,sp
    1916:	03000793          	li	a5,48
    191a:	02f88023          	sb	a5,32(a7)
    191e:	004d0893          	addi	a7,s10,4
    1922:	0ca8f163          	bgeu	a7,a0,19e4 <_vsnprintf+0x394>
    1926:	002d08b3          	add	a7,s10,sp
    192a:	02f88223          	sb	a5,36(a7)
    192e:	005d0893          	addi	a7,s10,5
    1932:	0aa8f963          	bgeu	a7,a0,19e4 <_vsnprintf+0x394>
    1936:	002d08b3          	add	a7,s10,sp
    193a:	02f882a3          	sb	a5,37(a7)
    193e:	006d0893          	addi	a7,s10,6
    1942:	0aa8f163          	bgeu	a7,a0,19e4 <_vsnprintf+0x394>
    1946:	002d08b3          	add	a7,s10,sp
    194a:	02f88323          	sb	a5,38(a7)
    194e:	007d0893          	addi	a7,s10,7
    1952:	08a8f963          	bgeu	a7,a0,19e4 <_vsnprintf+0x394>
    1956:	002d08b3          	add	a7,s10,sp
    195a:	02f883a3          	sb	a5,39(a7)
    195e:	008d0893          	addi	a7,s10,8
    1962:	08a8f163          	bgeu	a7,a0,19e4 <_vsnprintf+0x394>
    1966:	002d08b3          	add	a7,s10,sp
    196a:	02f88423          	sb	a5,40(a7)
    196e:	009d0893          	addi	a7,s10,9
    1972:	06a8f963          	bgeu	a7,a0,19e4 <_vsnprintf+0x394>
    1976:	002d08b3          	add	a7,s10,sp
    197a:	02f884a3          	sb	a5,41(a7)
    197e:	00ad0893          	addi	a7,s10,10
    1982:	06a8f163          	bgeu	a7,a0,19e4 <_vsnprintf+0x394>
    1986:	002d08b3          	add	a7,s10,sp
    198a:	02f88523          	sb	a5,42(a7)
    198e:	00bd0893          	addi	a7,s10,11
    1992:	04a8f963          	bgeu	a7,a0,19e4 <_vsnprintf+0x394>
    1996:	002d08b3          	add	a7,s10,sp
    199a:	02f885a3          	sb	a5,43(a7)
    199e:	00cd0893          	addi	a7,s10,12
    19a2:	04a8f163          	bgeu	a7,a0,19e4 <_vsnprintf+0x394>
    19a6:	002d08b3          	add	a7,s10,sp
    19aa:	02f88623          	sb	a5,44(a7)
    19ae:	00dd0793          	addi	a5,s10,13
    19b2:	02a7f963          	bgeu	a5,a0,19e4 <_vsnprintf+0x394>
    19b6:	1000                	addi	s0,sp,32
    19b8:	008d07b3          	add	a5,s10,s0
    19bc:	03000893          	li	a7,48
    19c0:	011786a3          	sb	a7,13(a5)
    19c4:	00ed0793          	addi	a5,s10,14
    19c8:	00a7fe63          	bgeu	a5,a0,19e4 <_vsnprintf+0x394>
    19cc:	008d07b3          	add	a5,s10,s0
    19d0:	01a03eb3          	snez	t4,s10
    19d4:	01178723          	sb	a7,14(a5)
    19d8:	0ebd                	addi	t4,t4,15
    19da:	00aef563          	bgeu	t4,a0,19e4 <_vsnprintf+0x394>
    19de:	031107a3          	sb	a7,47(sp)
    19e2:	4541                	li	a0,16
    19e4:	fff50793          	addi	a5,a0,-1
    19e8:	41a787b3          	sub	a5,a5,s10
    19ec:	00c53633          	sltu	a2,a0,a2
    19f0:	42c0178b          	th.mvnez	a5,zero,a2
    19f4:	9d3e                	add	s10,s10,a5
    19f6:	001d0793          	addi	a5,s10,1
    19fa:	0e0802e3          	beqz	a6,22de <_vsnprintf+0xc8e>
    19fe:	000e1863          	bnez	t3,1a0e <_vsnprintf+0x3be>
    1a02:	7c07370b          	th.extu	a4,a4,31,0
    1a06:	0cf702e3          	beq	a4,a5,22ca <_vsnprintf+0xc7a>
    1a0a:	40f501e3          	beq	a0,a5,260c <_vsnprintf+0xfbc>
    1a0e:	4801                	li	a6,0
    1a10:	a789                	j	2152 <_vsnprintf+0xb02>
    1a12:	0001                	nop
    1a14:	0027179b          	slliw	a5,a4,0x2
    1a18:	9fb9                	addw	a5,a5,a4
    1a1a:	0017979b          	slliw	a5,a5,0x1
    1a1e:	9fa9                	addw	a5,a5,a0
    1a20:	8816c50b          	th.lbuib	a0,(a3),1,0
    1a24:	fd07871b          	addiw	a4,a5,-48
    1a28:	fd05079b          	addiw	a5,a0,-48
    1a2c:	0ff7f793          	zext.b	a5,a5
    1a30:	fef672e3          	bgeu	a2,a5,1a14 <_vsnprintf+0x3c4>
    1a34:	8936                	mv	s2,a3
    1a36:	00168793          	addi	a5,a3,1
    1a3a:	b1c1                	j	16fa <_vsnprintf+0xaa>
    1a3c:	588dc98b          	th.lwia	s3,(s11),8,0
    1a40:	0809c063          	bltz	s3,1ac0 <_vsnprintf+0x470>
    1a44:	00194503          	lbu	a0,1(s2)
    1a48:	893e                	mv	s2,a5
    1a4a:	0785                	addi	a5,a5,1
    1a4c:	b155                	j	16f0 <_vsnprintf+0xa0>
    1a4e:	0001                	nop
    1a50:	85ee                	mv	a1,s11
    1a52:	7885c80b          	th.ldia	a6,(a1),8,0
    1a56:	57fd                	li	a5,-1
    1a58:	7c07360b          	th.extu	a2,a4,31,0
    1a5c:	00084503          	lbu	a0,0(a6)
    1a60:	40e7960b          	th.mveqz	a2,a5,a4
    1a64:	9642                	add	a2,a2,a6
    1a66:	87c2                	mv	a5,a6
    1a68:	320500e3          	beqz	a0,2588 <_vsnprintf+0xf38>
    1a6c:	00000013          	nop
    1a70:	00c78563          	beq	a5,a2,1a7a <_vsnprintf+0x42a>
    1a74:	8817c68b          	th.lbuib	a3,(a5),1,0
    1a78:	fee5                	bnez	a3,1a70 <_vsnprintf+0x420>
    1a7a:	40047693          	andi	a3,s0,1024
    1a7e:	410787bb          	subw	a5,a5,a6
    1a82:	30069063          	bnez	a3,1d82 <_vsnprintf+0x732>
    1a86:	8809                	andi	s0,s0,2
    1a88:	300407e3          	beqz	s0,2596 <_vsnprintf+0xf46>
    1a8c:	8da6                	mv	s11,s1
    1a8e:	4409                	li	s0,2
    1a90:	84ee                	mv	s1,s11
    1a92:	41b80d33          	sub	s10,a6,s11
    1a96:	e422                	sd	s0,8(sp)
    1a98:	8dbe                	mv	s11,a5
    1a9a:	8426                	mv	s0,s1
    1a9c:	84ae                	mv	s1,a1
    1a9e:	0001                	nop
    1aa0:	8622                	mv	a2,s0
    1aa2:	86d6                	mv	a3,s5
    1aa4:	85da                	mv	a1,s6
    1aa6:	0405                	addi	s0,s0,1
    1aa8:	9a02                	jalr	s4
    1aaa:	808d450b          	th.lrbu	a0,s10,s0,0
    1aae:	f96d                	bnez	a0,1aa0 <_vsnprintf+0x450>
    1ab0:	85a6                	mv	a1,s1
    1ab2:	84a2                	mv	s1,s0
    1ab4:	6422                	ld	s0,8(sp)
    1ab6:	87ee                	mv	a5,s11
    1ab8:	50041963          	bnez	s0,1fca <_vsnprintf+0x97a>
    1abc:	8dae                	mv	s11,a1
    1abe:	b6f5                	j	16aa <_vsnprintf+0x5a>
    1ac0:	00246413          	ori	s0,s0,2
    1ac4:	00194503          	lbu	a0,1(s2)
    1ac8:	2401                	sext.w	s0,s0
    1aca:	893e                	mv	s2,a5
    1acc:	413009bb          	negw	s3,s3
    1ad0:	0785                	addi	a5,a5,1
    1ad2:	b939                	j	16f0 <_vsnprintf+0xa0>
    1ad4:	00194503          	lbu	a0,1(s2)
    1ad8:	06800693          	li	a3,104
    1adc:	6ad50063          	beq	a0,a3,217c <_vsnprintf+0xb2c>
    1ae0:	08046413          	ori	s0,s0,128
    1ae4:	2401                	sext.w	s0,s0
    1ae6:	0785                	addi	a5,a5,1
    1ae8:	b985                	j	1758 <_vsnprintf+0x108>
    1aea:	00194503          	lbu	a0,1(s2)
    1aee:	06c00693          	li	a3,108
    1af2:	c4d51fe3          	bne	a0,a3,1750 <_vsnprintf+0x100>
    1af6:	30046413          	ori	s0,s0,768
    1afa:	00294503          	lbu	a0,2(s2)
    1afe:	2401                	sext.w	s0,s0
    1b00:	00390793          	addi	a5,s2,3
    1b04:	b991                	j	1758 <_vsnprintf+0x108>
    1b06:	06700793          	li	a5,103
    1b0a:	2cf50563          	beq	a0,a5,1dd4 <_vsnprintf+0x784>
    1b0e:	04700793          	li	a5,71
    1b12:	60f50463          	beq	a0,a5,211a <_vsnprintf+0xaca>
    1b16:	04500793          	li	a5,69
    1b1a:	60f50663          	beq	a0,a5,2126 <_vsnprintf+0xad6>
    1b1e:	000db507          	fld	fa0,0(s11)
    1b22:	008d8793          	addi	a5,s11,8
    1b26:	e43e                	sd	a5,8(sp)
    1b28:	a2a527d3          	feq.d	a5,fa0,fa0
    1b2c:	5c078b63          	beqz	a5,2102 <_vsnprintf+0xab2>
    1b30:	6795                	lui	a5,0x5
    1b32:	7e87b787          	fld	fa5,2024(a5) # 57e8 <pow10.0+0x58>
    1b36:	a2a797d3          	flt.d	a5,fa5,fa0
    1b3a:	5c079463          	bnez	a5,2102 <_vsnprintf+0xab2>
    1b3e:	6795                	lui	a5,0x5
    1b40:	7e07b787          	fld	fa5,2016(a5) # 57e0 <pow10.0+0x50>
    1b44:	a2f517d3          	flt.d	a5,fa0,fa5
    1b48:	5a079d63          	bnez	a5,2102 <_vsnprintf+0xab2>
    1b4c:	f20007d3          	fmv.d.x	fa5,zero
    1b50:	a2f517d3          	flt.d	a5,fa0,fa5
    1b54:	e20506d3          	fmv.x.d	a3,fa0
    1b58:	c789                	beqz	a5,1b62 <_vsnprintf+0x512>
    1b5a:	22a517d3          	fneg.d	fa5,fa0
    1b5e:	e20786d3          	fmv.x.d	a3,fa5
    1b62:	6599                	lui	a1,0x6
    1b64:	6619                	lui	a2,0x6
    1b66:	fb46b78b          	th.extu	a5,a3,62,52
    1b6a:	80863687          	fld	fa3,-2040(a2) # 5808 <pow10.0+0x78>
    1b6e:	8005b607          	fld	fa2,-2048(a1) # 5800 <pow10.0+0x70>
    1b72:	c017879b          	addiw	a5,a5,-1023
    1b76:	d20787d3          	fcvt.d.w	fa5,a5
    1b7a:	3ff00613          	li	a2,1023
    1b7e:	6799                	lui	a5,0x6
    1b80:	8107b707          	fld	fa4,-2032(a5) # 5810 <pow10.0+0x80>
    1b84:	1652                	slli	a2,a2,0x34
    1b86:	cc06b78b          	th.extu	a5,a3,51,0
    1b8a:	6ac7f643          	fmadd.d	fa2,fa5,fa2,fa3
    1b8e:	8fd1                	or	a5,a5,a2
    1b90:	f20787d3          	fmv.d.x	fa5,a5
    1b94:	6619                	lui	a2,0x6
    1b96:	0ae7f7d3          	fsub.d	fa5,fa5,fa4
    1b9a:	81863707          	fld	fa4,-2024(a2) # 5818 <pow10.0+0x88>
    1b9e:	6619                	lui	a2,0x6
    1ba0:	6799                	lui	a5,0x6
    1ba2:	62e7f643          	fmadd.d	fa2,fa5,fa4,fa2
    1ba6:	82063707          	fld	fa4,-2016(a2) # 5820 <pow10.0+0x90>
    1baa:	8287b687          	fld	fa3,-2008(a5) # 5828 <pow10.0+0x98>
    1bae:	6799                	lui	a5,0x6
    1bb0:	8307b007          	fld	ft0,-2000(a5) # 5830 <pow10.0+0xa0>
    1bb4:	c2061653          	fcvt.w.d	a2,fa2,rtz
    1bb8:	6799                	lui	a5,0x6
    1bba:	d20607d3          	fcvt.d.w	fa5,a2
    1bbe:	8387b607          	fld	fa2,-1992(a5) # 5838 <pow10.0+0xa8>
    1bc2:	6ae7f6c3          	fmadd.d	fa3,fa5,fa4,fa3
    1bc6:	6799                	lui	a5,0x6
    1bc8:	8407b707          	fld	fa4,-1984(a5) # 5840 <pow10.0+0xb0>
    1bcc:	6799                	lui	a5,0x6
    1bce:	8487b587          	fld	fa1,-1976(a5) # 5848 <pow10.0+0xb8>
    1bd2:	c20697d3          	fcvt.w.d	a5,fa3,rtz
    1bd6:	6599                	lui	a1,0x6
    1bd8:	d20786d3          	fcvt.d.w	fa3,a5
    1bdc:	8505b087          	fld	ft1,-1968(a1) # 5850 <pow10.0+0xc0>
    1be0:	1206f6d3          	fmul.d	fa3,fa3,ft0
    1be4:	6599                	lui	a1,0x6
    1be6:	3ff7879b          	addiw	a5,a5,1023
    1bea:	17d2                	slli	a5,a5,0x34
    1bec:	6ac7f7c7          	fmsub.d	fa5,fa5,fa2,fa3
    1bf0:	8585b607          	fld	fa2,-1960(a1) # 5858 <pow10.0+0xc8>
    1bf4:	6599                	lui	a1,0x6
    1bf6:	8605b007          	fld	ft0,-1952(a1) # 5860 <pow10.0+0xd0>
    1bfa:	4519                	li	a0,6
    1bfc:	12f7f6d3          	fmul.d	fa3,fa5,fa5
    1c00:	0af67653          	fsub.d	fa2,fa2,fa5
    1c04:	02f7f7d3          	fadd.d	fa5,fa5,fa5
    1c08:	40047593          	andi	a1,s0,1024
    1c0c:	1ae6f753          	fdiv.d	fa4,fa3,fa4
    1c10:	40b5170b          	th.mveqz	a4,a0,a1
    1c14:	00060d1b          	sext.w	s10,a2
    1c18:	02b77753          	fadd.d	fa4,fa4,fa1
    1c1c:	1ae6f753          	fdiv.d	fa4,fa3,fa4
    1c20:	02177753          	fadd.d	fa4,fa4,ft1
    1c24:	1ae6f6d3          	fdiv.d	fa3,fa3,fa4
    1c28:	f2078753          	fmv.d.x	fa4,a5
    1c2c:	02c6f6d3          	fadd.d	fa3,fa3,fa2
    1c30:	1ad7f7d3          	fdiv.d	fa5,fa5,fa3
    1c34:	0207f7d3          	fadd.d	fa5,fa5,ft0
    1c38:	12e7f7d3          	fmul.d	fa5,fa5,fa4
    1c3c:	f2068753          	fmv.d.x	fa4,a3
    1c40:	a2f717d3          	flt.d	a5,fa4,fa5
    1c44:	c789                	beqz	a5,1c4e <_vsnprintf+0x5fe>
    1c46:	1ab7f7d3          	fdiv.d	fa5,fa5,fa1
    1c4a:	fff60d1b          	addiw	s10,a2,-1
    1c4e:	6785                	lui	a5,0x1
    1c50:	80078793          	addi	a5,a5,-2048 # 800 <main+0x10>
    1c54:	063d031b          	addiw	t1,s10,99
    1c58:	0c600613          	li	a2,198
    1c5c:	00663333          	sltu	t1,a2,t1
    1c60:	8fe1                	and	a5,a5,s0
    1c62:	0311                	addi	t1,t1,4
    1c64:	00247893          	andi	a7,s0,2
    1c68:	76078363          	beqz	a5,23ce <_vsnprintf+0xd7e>
    1c6c:	6799                	lui	a5,0x6
    1c6e:	8687b707          	fld	fa4,-1944(a5) # 5868 <pow10.0+0xd8>
    1c72:	f20686d3          	fmv.d.x	fa3,a3
    1c76:	a2d707d3          	fle.d	a5,fa4,fa3
    1c7a:	3e0783e3          	beqz	a5,2860 <_vsnprintf+0x1210>
    1c7e:	6799                	lui	a5,0x6
    1c80:	8707b707          	fld	fa4,-1936(a5) # 5870 <pow10.0+0xe0>
    1c84:	a2e697d3          	flt.d	a5,fa3,fa4
    1c88:	3c078ce3          	beqz	a5,2860 <_vsnprintf+0x1210>
    1c8c:	41a707bb          	subw	a5,a4,s10
    1c90:	37fd                	addiw	a5,a5,-1
    1c92:	00ed2d33          	slt	s10,s10,a4
    1c96:	41a0178b          	th.mveqz	a5,zero,s10
    1c9a:	f20007d3          	fmv.d.x	fa5,zero
    1c9e:	873e                	mv	a4,a5
    1ca0:	a2f517d3          	flt.d	a5,fa0,fa5
    1ca4:	c399                	beqz	a5,1caa <_vsnprintf+0x65a>
    1ca6:	0b10106f          	j	3556 <_vsnprintf+0x1f06>
    1caa:	787d                	lui	a6,0xfffff
    1cac:	7ff80813          	addi	a6,a6,2047 # fffffffffffff7ff <__kernel_stack+0xfffffffffff117ff>
    1cb0:	01047833          	and	a6,s0,a6
    1cb4:	40086813          	ori	a6,a6,1024
    1cb8:	f2068553          	fmv.d.x	fa0,a3
    1cbc:	87ce                	mv	a5,s3
    1cbe:	8626                	mv	a2,s1
    1cc0:	2801                	sext.w	a6,a6
    1cc2:	a199                	j	2108 <_vsnprintf+0xab8>
    1cc4:	04600793          	li	a5,70
    1cc8:	10f50263          	beq	a0,a5,1dcc <_vsnprintf+0x77c>
    1ccc:	000db507          	fld	fa0,0(s11)
    1cd0:	8626                	mv	a2,s1
    1cd2:	8822                	mv	a6,s0
    1cd4:	87ce                	mv	a5,s3
    1cd6:	86d6                	mv	a3,s5
    1cd8:	85da                	mv	a1,s6
    1cda:	8552                	mv	a0,s4
    1cdc:	934ff0ef          	jal	e10 <_ftoa>
    1ce0:	0da1                	addi	s11,s11,8
    1ce2:	84aa                	mv	s1,a0
    1ce4:	b2d9                	j	16aa <_vsnprintf+0x5a>
    1ce6:	00247793          	andi	a5,s0,2
    1cea:	00148d13          	addi	s10,s1,1
    1cee:	008d8413          	addi	s0,s11,8
    1cf2:	4c078463          	beqz	a5,21ba <_vsnprintf+0xb6a>
    1cf6:	000dc503          	lbu	a0,0(s11)
    1cfa:	86d6                	mv	a3,s5
    1cfc:	8626                	mv	a2,s1
    1cfe:	85da                	mv	a1,s6
    1d00:	9a02                	jalr	s4
    1d02:	4785                	li	a5,1
    1d04:	1137f0e3          	bgeu	a5,s3,2604 <_vsnprintf+0xfb4>
    1d08:	ffe9879b          	addiw	a5,s3,-2
    1d0c:	7c07b78b          	th.extu	a5,a5,31,0
    1d10:	0489                	addi	s1,s1,2
    1d12:	94be                	add	s1,s1,a5
    1d14:	00000013          	nop
    1d18:	866a                	mv	a2,s10
    1d1a:	86d6                	mv	a3,s5
    1d1c:	0d05                	addi	s10,s10,1
    1d1e:	85da                	mv	a1,s6
    1d20:	02000513          	li	a0,32
    1d24:	9a02                	jalr	s4
    1d26:	fe9d19e3          	bne	s10,s1,1d18 <_vsnprintf+0x6c8>
    1d2a:	8da2                	mv	s11,s0
    1d2c:	babd                	j	16aa <_vsnprintf+0x5a>
    1d2e:	8626                	mv	a2,s1
    1d30:	86d6                	mv	a3,s5
    1d32:	85da                	mv	a1,s6
    1d34:	02500513          	li	a0,37
    1d38:	0485                	addi	s1,s1,1
    1d3a:	9a02                	jalr	s4
    1d3c:	b2bd                	j	16aa <_vsnprintf+0x5a>
    1d3e:	06f00793          	li	a5,111
    1d42:	0af50063          	beq	a0,a5,1de2 <_vsnprintf+0x792>
    1d46:	40a7f0e3          	bgeu	a5,a0,2946 <_vsnprintf+0x12f6>
    1d4a:	07800793          	li	a5,120
    1d4e:	02f504e3          	beq	a0,a5,2576 <_vsnprintf+0xf26>
    1d52:	983d                	andi	s0,s0,-17
    1d54:	46a9                	li	a3,10
    1d56:	2401                	sext.w	s0,s0
    1d58:	88b6                	mv	a7,a3
    1d5a:	a071                	j	1de6 <_vsnprintf+0x796>
    1d5c:	588dc70b          	th.lwia	a4,(s11),8,0
    1d60:	00294503          	lbu	a0,2(s2)
    1d64:	0909                	addi	s2,s2,2
    1d66:	00072793          	slti	a5,a4,0
    1d6a:	42f0170b          	th.mvnez	a4,zero,a5
    1d6e:	2701                	sext.w	a4,a4
    1d70:	00190793          	addi	a5,s2,1
    1d74:	b259                	j	16fa <_vsnprintf+0xaa>
    1d76:	02146313          	ori	t1,s0,33
    1d7a:	2301                	sext.w	t1,t1
    1d7c:	01047813          	andi	a6,s0,16
    1d80:	bce5                	j	1878 <_vsnprintf+0x228>
    1d82:	00e7b6b3          	sltu	a3,a5,a4
    1d86:	8809                	andi	s0,s0,2
    1d88:	40d7178b          	th.mveqz	a5,a4,a3
    1d8c:	2a040fe3          	beqz	s0,284a <_vsnprintf+0x11fa>
    1d90:	8da6                	mv	s11,s1
    1d92:	4409                	li	s0,2
    1d94:	866e                	mv	a2,s11
    1d96:	7c07370b          	th.extu	a4,a4,31,0
    1d9a:	e43e                	sd	a5,8(sp)
    1d9c:	e822                	sd	s0,16(sp)
    1d9e:	01b704b3          	add	s1,a4,s11
    1da2:	41b80d33          	sub	s10,a6,s11
    1da6:	87b2                	mv	a5,a2
    1da8:	8dae                	mv	s11,a1
    1daa:	0001                	nop
    1dac:	00000013          	nop
    1db0:	3ef48863          	beq	s1,a5,21a0 <_vsnprintf+0xb50>
    1db4:	86d6                	mv	a3,s5
    1db6:	863e                	mv	a2,a5
    1db8:	85da                	mv	a1,s6
    1dba:	00178413          	addi	s0,a5,1
    1dbe:	9a02                	jalr	s4
    1dc0:	808d450b          	th.lrbu	a0,s10,s0,0
    1dc4:	3e050463          	beqz	a0,21ac <_vsnprintf+0xb5c>
    1dc8:	87a2                	mv	a5,s0
    1dca:	b7dd                	j	1db0 <_vsnprintf+0x760>
    1dcc:	02046413          	ori	s0,s0,32
    1dd0:	2401                	sext.w	s0,s0
    1dd2:	bded                	j	1ccc <_vsnprintf+0x67c>
    1dd4:	6785                	lui	a5,0x1
    1dd6:	80078793          	addi	a5,a5,-2048 # 800 <main+0x10>
    1dda:	8fc1                	or	a5,a5,s0
    1ddc:	0007841b          	sext.w	s0,a5
    1de0:	bb3d                	j	1b1e <_vsnprintf+0x4ce>
    1de2:	46a1                	li	a3,8
    1de4:	88b6                	mv	a7,a3
    1de6:	ff247793          	andi	a5,s0,-14
    1dea:	ff347613          	andi	a2,s0,-13
    1dee:	2781                	sext.w	a5,a5
    1df0:	2601                	sext.w	a2,a2
    1df2:	40047813          	andi	a6,s0,1024
    1df6:	4307960b          	th.mvnez	a2,a5,a6
    1dfa:	008d8593          	addi	a1,s11,8
    1dfe:	20067793          	andi	a5,a2,512
    1e02:	e42e                	sd	a1,8(sp)
    1e04:	8e32                	mv	t3,a2
    1e06:	0a0791e3          	bnez	a5,26a8 <_vsnprintf+0x1058>
    1e0a:	10067793          	andi	a5,a2,256
    1e0e:	4a0796e3          	bnez	a5,2aba <_vsnprintf+0x146a>
    1e12:	04067793          	andi	a5,a2,64
    1e16:	76079663          	bnez	a5,2582 <_vsnprintf+0xf32>
    1e1a:	080e7e13          	andi	t3,t3,128
    1e1e:	000e1463          	bnez	t3,1e26 <_vsnprintf+0x7d6>
    1e22:	26e0106f          	j	3090 <_vsnprintf+0x1a40>
    1e26:	000dd583          	lhu	a1,0(s11)
    1e2a:	7c05b58b          	th.extu	a1,a1,31,0
    1e2e:	5e059be3          	bnez	a1,2c24 <_vsnprintf+0x15d4>
    1e32:	87b2                	mv	a5,a2
    1e34:	fe367f13          	andi	t5,a2,-29
    1e38:	00080463          	beqz	a6,1e40 <_vsnprintf+0x7f0>
    1e3c:	27c0106f          	j	30b8 <_vsnprintf+0x1a68>
    1e40:	4e01                	li	t3,0
    1e42:	145f360b          	th.extu	a2,t5,5,5
    1e46:	06100793          	li	a5,97
    1e4a:	c219                	beqz	a2,1e50 <_vsnprintf+0x800>
    1e4c:	04100793          	li	a5,65
    1e50:	ff678e9b          	addiw	t4,a5,-10
    1e54:	4501                	li	a0,0
    1e56:	1000                	addi	s0,sp,32
    1e58:	42a5                	li	t0,9
    1e5a:	02000f93          	li	t6,32
    1e5e:	a039                	j	1e6c <_vsnprintf+0x81c>
    1e60:	01fd9463          	bne	s11,t6,1e68 <_vsnprintf+0x818>
    1e64:	1920106f          	j	2ff6 <_vsnprintf+0x19a6>
    1e68:	856e                	mv	a0,s11
    1e6a:	859a                	mv	a1,t1
    1e6c:	02d5d333          	divu	t1,a1,a3
    1e70:	862e                	mv	a2,a1
    1e72:	00150d93          	addi	s11,a0,1
    1e76:	22d3160b          	th.muls	a2,t1,a3
    1e7a:	0ff67793          	zext.b	a5,a2
    1e7e:	0307839b          	addiw	t2,a5,48
    1e82:	00fe87bb          	addw	a5,t4,a5
    1e86:	00c2b633          	sltu	a2,t0,a2
    1e8a:	0ff3f393          	zext.b	t2,t2
    1e8e:	0ff7f793          	zext.b	a5,a5
    1e92:	40c3978b          	th.mveqz	a5,t2,a2
    1e96:	00a4578b          	th.srb	a5,s0,a0,0
    1e9a:	fcd5f3e3          	bgeu	a1,a3,1e60 <_vsnprintf+0x810>
    1e9e:	002f7693          	andi	a3,t5,2
    1ea2:	87fa                	mv	a5,t5
    1ea4:	5a0687e3          	beqz	a3,2c52 <_vsnprintf+0x1602>
    1ea8:	000e1463          	bnez	t3,1eb0 <_vsnprintf+0x860>
    1eac:	7ce0106f          	j	367a <_vsnprintf+0x202a>
    1eb0:	00080463          	beqz	a6,1eb8 <_vsnprintf+0x868>
    1eb4:	7dc0106f          	j	3690 <_vsnprintf+0x2040>
    1eb8:	7c07370b          	th.extu	a4,a4,31,0
    1ebc:	4809                	li	a6,2
    1ebe:	01b71463          	bne	a4,s11,1ec6 <_vsnprintf+0x876>
    1ec2:	0b90106f          	j	377a <_vsnprintf+0x212a>
    1ec6:	7c09b78b          	th.extu	a5,s3,31,0
    1eca:	01b79463          	bne	a5,s11,1ed2 <_vsnprintf+0x882>
    1ece:	0ad0106f          	j	377a <_vsnprintf+0x212a>
    1ed2:	003f7793          	andi	a5,t5,3
    1ed6:	46c1                	li	a3,16
    1ed8:	873e                	mv	a4,a5
    1eda:	8e42                	mv	t3,a6
    1edc:	00d89463          	bne	a7,a3,1ee4 <_vsnprintf+0x894>
    1ee0:	06b0106f          	j	374a <_vsnprintf+0x20fa>
    1ee4:	4689                	li	a3,2
    1ee6:	00d89463          	bne	a7,a3,1eee <_vsnprintf+0x89e>
    1eea:	0b10106f          	j	379a <_vsnprintf+0x214a>
    1eee:	02000713          	li	a4,32
    1ef2:	00078f1b          	sext.w	t5,a5
    1ef6:	72ed9863          	bne	s11,a4,2626 <_vsnprintf+0xfd6>
    1efa:	000f0463          	beqz	t5,1f02 <_vsnprintf+0x8b2>
    1efe:	4f00106f          	j	33ee <_vsnprintf+0x1d9e>
    1f02:	02000d93          	li	s11,32
    1f06:	7c09b40b          	th.extu	s0,s3,31,0
    1f0a:	013de463          	bltu	s11,s3,1f12 <_vsnprintf+0x8c2>
    1f0e:	0ad0106f          	j	37ba <_vsnprintf+0x216a>
    1f12:	874a                	mv	a4,s2
    1f14:	409d87b3          	sub	a5,s11,s1
    1f18:	8926                	mv	s2,s1
    1f1a:	fbc1548b          	th.sdd	s1,t3,(sp),1,4
    1f1e:	8d3a                	mv	s10,a4
    1f20:	84be                	mv	s1,a5
    1f22:	0001                	nop
    1f24:	00000013          	nop
    1f28:	864a                	mv	a2,s2
    1f2a:	86d6                	mv	a3,s5
    1f2c:	85da                	mv	a1,s6
    1f2e:	02000513          	li	a0,32
    1f32:	0905                	addi	s2,s2,1
    1f34:	9a02                	jalr	s4
    1f36:	01248733          	add	a4,s1,s2
    1f3a:	fe8767e3          	bltu	a4,s0,1f28 <_vsnprintf+0x8d8>
    1f3e:	fbc1448b          	th.ldd	s1,t3,(sp),1,4
    1f42:	fff40793          	addi	a5,s0,-1
    1f46:	001d8693          	addi	a3,s11,1
    1f4a:	00d43733          	sltu	a4,s0,a3
    1f4e:	41b787b3          	sub	a5,a5,s11
    1f52:	42e0178b          	th.mvnez	a5,zero,a4
    1f56:	00148713          	addi	a4,s1,1
    1f5a:	896a                	mv	s2,s10
    1f5c:	97ba                	add	a5,a5,a4
    1f5e:	020d8d63          	beqz	s11,1f98 <_vsnprintf+0x948>
    1f62:	002d8733          	add	a4,s11,sp
    1f66:	01f74503          	lbu	a0,31(a4)
    1f6a:	00fd8d33          	add	s10,s11,a5
    1f6e:	fa915d0b          	th.sdd	s10,s1,(sp),1,4
    1f72:	1000                	addi	s0,sp,32
    1f74:	84ee                	mv	s1,s11
    1f76:	8df2                	mv	s11,t3
    1f78:	a031                	j	1f84 <_vsnprintf+0x934>
    1f7a:	0001                	nop
    1f7c:	00940733          	add	a4,s0,s1
    1f80:	fff74503          	lbu	a0,-1(a4)
    1f84:	409d0633          	sub	a2,s10,s1
    1f88:	86d6                	mv	a3,s5
    1f8a:	14fd                	addi	s1,s1,-1
    1f8c:	85da                	mv	a1,s6
    1f8e:	9a02                	jalr	s4
    1f90:	f4f5                	bnez	s1,1f7c <_vsnprintf+0x92c>
    1f92:	fa91478b          	th.ldd	a5,s1,(sp),1,4
    1f96:	8e6e                	mv	t3,s11
    1f98:	1c0e0be3          	beqz	t3,296e <_vsnprintf+0x131e>
    1f9c:	409785b3          	sub	a1,a5,s1
    1fa0:	7c09b98b          	th.extu	s3,s3,31,0
    1fa4:	1d35f5e3          	bgeu	a1,s3,296e <_vsnprintf+0x131e>
    1fa8:	40978433          	sub	s0,a5,s1
    1fac:	84be                	mv	s1,a5
    1fae:	0001                	nop
    1fb0:	8626                	mv	a2,s1
    1fb2:	86d6                	mv	a3,s5
    1fb4:	85da                	mv	a1,s6
    1fb6:	02000513          	li	a0,32
    1fba:	0405                	addi	s0,s0,1
    1fbc:	0485                	addi	s1,s1,1
    1fbe:	9a02                	jalr	s4
    1fc0:	ff3468e3          	bltu	s0,s3,1fb0 <_vsnprintf+0x960>
    1fc4:	6da2                	ld	s11,8(sp)
    1fc6:	ee4ff06f          	j	16aa <_vsnprintf+0x5a>
    1fca:	8426                	mv	s0,s1
    1fcc:	af37f8e3          	bgeu	a5,s3,1abc <_vsnprintf+0x46c>
    1fd0:	39fd                	addiw	s3,s3,-1
    1fd2:	40f987bb          	subw	a5,s3,a5
    1fd6:	7c07b78b          	th.extu	a5,a5,31,0
    1fda:	0485                	addi	s1,s1,1
    1fdc:	94be                	add	s1,s1,a5
    1fde:	89ae                	mv	s3,a1
    1fe0:	8622                	mv	a2,s0
    1fe2:	86d6                	mv	a3,s5
    1fe4:	0405                	addi	s0,s0,1
    1fe6:	85da                	mv	a1,s6
    1fe8:	02000513          	li	a0,32
    1fec:	9a02                	jalr	s4
    1fee:	fe9419e3          	bne	s0,s1,1fe0 <_vsnprintf+0x990>
    1ff2:	85ce                	mv	a1,s3
    1ff4:	8dae                	mv	s11,a1
    1ff6:	eb4ff06f          	j	16aa <_vsnprintf+0x5a>
    1ffa:	05800793          	li	a5,88
    1ffe:	18f50b63          	beq	a0,a5,2194 <_vsnprintf+0xb44>
    2002:	4689                	li	a3,2
    2004:	06200793          	li	a5,98
    2008:	88b6                	mv	a7,a3
    200a:	dcf50ee3          	beq	a0,a5,1de6 <_vsnprintf+0x796>
    200e:	40047793          	andi	a5,s0,1024
    2012:	2e079363          	bnez	a5,22f8 <_vsnprintf+0xca8>
    2016:	fef47893          	andi	a7,s0,-17
    201a:	20047693          	andi	a3,s0,512
    201e:	2881                	sext.w	a7,a7
    2020:	008d8813          	addi	a6,s11,8
    2024:	2e068563          	beqz	a3,230e <_vsnprintf+0xcbe>
    2028:	000dbe83          	ld	t4,0(s11)
    202c:	4681                	li	a3,0
    202e:	8dc2                	mv	s11,a6
    2030:	000e8763          	beqz	t4,203e <_vsnprintf+0x9ee>
    2034:	43fed793          	srai	a5,t4,0x3f
    2038:	01d7c6b3          	xor	a3,a5,t4
    203c:	8e9d                	sub	a3,a3,a5
    203e:	4781                	li	a5,0
    2040:	1000                	addi	s0,sp,32
    2042:	45a9                	li	a1,10
    2044:	4325                	li	t1,9
    2046:	02000e13          	li	t3,32
    204a:	a029                	j	2054 <_vsnprintf+0xa04>
    204c:	01c79463          	bne	a5,t3,2054 <_vsnprintf+0xa04>
    2050:	0480106f          	j	3098 <_vsnprintf+0x1a48>
    2054:	02b6f633          	remu	a2,a3,a1
    2058:	8f3e                	mv	t5,a5
    205a:	0785                	addi	a5,a5,1
    205c:	00f40833          	add	a6,s0,a5
    2060:	8536                	mv	a0,a3
    2062:	0306061b          	addiw	a2,a2,48
    2066:	fec80fa3          	sb	a2,-1(a6)
    206a:	02b6d6b3          	divu	a3,a3,a1
    206e:	fca36fe3          	bltu	t1,a0,204c <_vsnprintf+0x9fc>
    2072:	0028f613          	andi	a2,a7,2
    2076:	86c6                	mv	a3,a7
    2078:	e219                	bnez	a2,207e <_vsnprintf+0xa2e>
    207a:	0700106f          	j	30ea <_vsnprintf+0x1a9a>
    207e:	02000513          	li	a0,32
    2082:	00a79463          	bne	a5,a0,208a <_vsnprintf+0xa3a>
    2086:	0a20106f          	j	3128 <_vsnprintf+0x1ad8>
    208a:	000ec463          	bltz	t4,2092 <_vsnprintf+0xa42>
    208e:	6250106f          	j	3eb2 <_vsnprintf+0x2862>
    2092:	02d00693          	li	a3,45
    2096:	978a                	add	a5,a5,sp
    2098:	02d78023          	sb	a3,32(a5)
    209c:	002f0713          	addi	a4,t5,2
    20a0:	4689                	li	a3,2
    20a2:	87a6                	mv	a5,s1
    20a4:	02d00513          	li	a0,45
    20a8:	00e78d33          	add	s10,a5,a4
    20ac:	e426                	sd	s1,8(sp)
    20ae:	e84a                	sd	s2,16(sp)
    20b0:	84ba                	mv	s1,a4
    20b2:	896a                	mv	s2,s10
    20b4:	8d36                	mv	s10,a3
    20b6:	a029                	j	20c0 <_vsnprintf+0xa70>
    20b8:	002486b3          	add	a3,s1,sp
    20bc:	01f6c503          	lbu	a0,31(a3)
    20c0:	40990633          	sub	a2,s2,s1
    20c4:	86d6                	mv	a3,s5
    20c6:	14fd                	addi	s1,s1,-1
    20c8:	85da                	mv	a1,s6
    20ca:	844a                	mv	s0,s2
    20cc:	9a02                	jalr	s4
    20ce:	f4ed                	bnez	s1,20b8 <_vsnprintf+0xa68>
    20d0:	64a2                	ld	s1,8(sp)
    20d2:	6942                	ld	s2,16(sp)
    20d4:	86ea                	mv	a3,s10
    20d6:	c29d                	beqz	a3,20fc <_vsnprintf+0xaac>
    20d8:	409404b3          	sub	s1,s0,s1
    20dc:	7c09b98b          	th.extu	s3,s3,31,0
    20e0:	0134fe63          	bgeu	s1,s3,20fc <_vsnprintf+0xaac>
    20e4:	00000013          	nop
    20e8:	8622                	mv	a2,s0
    20ea:	86d6                	mv	a3,s5
    20ec:	85da                	mv	a1,s6
    20ee:	02000513          	li	a0,32
    20f2:	0485                	addi	s1,s1,1
    20f4:	0405                	addi	s0,s0,1
    20f6:	9a02                	jalr	s4
    20f8:	ff34e8e3          	bltu	s1,s3,20e8 <_vsnprintf+0xa98>
    20fc:	84a2                	mv	s1,s0
    20fe:	dacff06f          	j	16aa <_vsnprintf+0x5a>
    2102:	8822                	mv	a6,s0
    2104:	87ce                	mv	a5,s3
    2106:	8626                	mv	a2,s1
    2108:	86d6                	mv	a3,s5
    210a:	85da                	mv	a1,s6
    210c:	8552                	mv	a0,s4
    210e:	d03fe0ef          	jal	e10 <_ftoa>
    2112:	84aa                	mv	s1,a0
    2114:	6da2                	ld	s11,8(sp)
    2116:	d94ff06f          	j	16aa <_vsnprintf+0x5a>
    211a:	6785                	lui	a5,0x1
    211c:	80078793          	addi	a5,a5,-2048 # 800 <main+0x10>
    2120:	8fc1                	or	a5,a5,s0
    2122:	0007841b          	sext.w	s0,a5
    2126:	02046413          	ori	s0,s0,32
    212a:	2401                	sext.w	s0,s0
    212c:	bacd                	j	1b1e <_vsnprintf+0x4ce>
    212e:	10080d63          	beqz	a6,2248 <_vsnprintf+0xbf8>
    2132:	440e1563          	bnez	t3,257c <_vsnprintf+0xf2c>
    2136:	7c07370b          	th.extu	a4,a4,31,0
    213a:	18e78663          	beq	a5,a4,22c6 <_vsnprintf+0xc76>
    213e:	4541                	li	a0,16
    2140:	86aa                	mv	a3,a0
    2142:	4e09                	li	t3,2
    2144:	8872                	mv	a6,t3
    2146:	4cf50363          	beq	a0,a5,260c <_vsnprintf+0xfbc>
    214a:	02000713          	li	a4,32
    214e:	10e78363          	beq	a5,a4,2254 <_vsnprintf+0xc04>
    2152:	00278733          	add	a4,a5,sp
    2156:	05800613          	li	a2,88
    215a:	02c70023          	sb	a2,32(a4)
    215e:	00178d13          	addi	s10,a5,1
    2162:	02000713          	li	a4,32
    2166:	0789                	addi	a5,a5,2
    2168:	00ed1463          	bne	s10,a4,2170 <_vsnprintf+0xb20>
    216c:	4b80106f          	j	3624 <_vsnprintf+0x1fd4>
    2170:	9d0a                	add	s10,s10,sp
    2172:	03000713          	li	a4,48
    2176:	02ed0023          	sb	a4,32(s10)
    217a:	a8c9                	j	224c <_vsnprintf+0xbfc>
    217c:	0c046413          	ori	s0,s0,192
    2180:	00294503          	lbu	a0,2(s2)
    2184:	2401                	sext.w	s0,s0
    2186:	00390793          	addi	a5,s2,3
    218a:	dceff06f          	j	1758 <_vsnprintf+0x108>
    218e:	4401                	li	s0,0
    2190:	e72ff06f          	j	1802 <_vsnprintf+0x1b2>
    2194:	02046413          	ori	s0,s0,32
    2198:	46c1                	li	a3,16
    219a:	2401                	sext.w	s0,s0
    219c:	88b6                	mv	a7,a3
    219e:	b1a1                	j	1de6 <_vsnprintf+0x796>
    21a0:	67a2                	ld	a5,8(sp)
    21a2:	6442                	ld	s0,16(sp)
    21a4:	85ee                	mv	a1,s11
    21a6:	90040be3          	beqz	s0,1abc <_vsnprintf+0x46c>
    21aa:	b505                	j	1fca <_vsnprintf+0x97a>
    21ac:	84a2                	mv	s1,s0
    21ae:	67a2                	ld	a5,8(sp)
    21b0:	6442                	ld	s0,16(sp)
    21b2:	85ee                	mv	a1,s11
    21b4:	900404e3          	beqz	s0,1abc <_vsnprintf+0x46c>
    21b8:	bd09                	j	1fca <_vsnprintf+0x97a>
    21ba:	4785                	li	a5,1
    21bc:	4337fe63          	bgeu	a5,s3,25f8 <_vsnprintf+0xfa8>
    21c0:	ffe9879b          	addiw	a5,s3,-2
    21c4:	7c07b78b          	th.extu	a5,a5,31,0
    21c8:	e422                	sd	s0,8(sp)
    21ca:	9d3e                	add	s10,s10,a5
    21cc:	8426                	mv	s0,s1
    21ce:	89be                	mv	s3,a5
    21d0:	8622                	mv	a2,s0
    21d2:	86d6                	mv	a3,s5
    21d4:	0405                	addi	s0,s0,1
    21d6:	85da                	mv	a1,s6
    21d8:	02000513          	li	a0,32
    21dc:	9a02                	jalr	s4
    21de:	ffa419e3          	bne	s0,s10,21d0 <_vsnprintf+0xb80>
    21e2:	000dc503          	lbu	a0,0(s11)
    21e6:	6422                	ld	s0,8(sp)
    21e8:	013487b3          	add	a5,s1,s3
    21ec:	00178613          	addi	a2,a5,1
    21f0:	86d6                	mv	a3,s5
    21f2:	85da                	mv	a1,s6
    21f4:	00278493          	addi	s1,a5,2
    21f8:	8da2                	mv	s11,s0
    21fa:	9a02                	jalr	s4
    21fc:	caeff06f          	j	16aa <_vsnprintf+0x5a>
    2200:	00237693          	andi	a3,t1,2
    2204:	30068263          	beqz	a3,2508 <_vsnprintf+0xeb8>
    2208:	00080b63          	beqz	a6,221e <_vsnprintf+0xbce>
    220c:	000e1963          	bnez	t3,221e <_vsnprintf+0xbce>
    2210:	01d71763          	bne	a4,t4,221e <_vsnprintf+0xbce>
    2214:	678d                	lui	a5,0x3
    2216:	05878793          	addi	a5,a5,88 # 3058 <_vsnprintf+0x1a08>
    221a:	02f11f23          	sh	a5,62(sp)
    221e:	4809                	li	a6,2
    2220:	46c1                	li	a3,16
    2222:	a80d                	j	2254 <_vsnprintf+0xc04>
    2224:	00247693          	andi	a3,s0,2
    2228:	32069d63          	bnez	a3,2562 <_vsnprintf+0xf12>
    222c:	00c47813          	andi	a6,s0,12
    2230:	3c080ce3          	beqz	a6,2e08 <_vsnprintf+0x17b8>
    2234:	e319                	bnez	a4,223a <_vsnprintf+0xbea>
    2236:	35d0106f          	j	3d92 <_vsnprintf+0x2742>
    223a:	453d                	li	a0,15
    223c:	86aa                	mv	a3,a0
    223e:	4801                	li	a6,0
    2240:	4781                	li	a5,0
    2242:	40000e13          	li	t3,1024
    2246:	acc9                	j	2518 <_vsnprintf+0xec8>
    2248:	4809                	li	a6,2
    224a:	46c1                	li	a3,16
    224c:	02000713          	li	a4,32
    2250:	08e79763          	bne	a5,a4,22de <_vsnprintf+0xc8e>
    2254:	03f14503          	lbu	a0,63(sp)
    2258:	02000d13          	li	s10,32
    225c:	01a48db3          	add	s11,s1,s10
    2260:	e426                	sd	s1,8(sp)
    2262:	fb21580b          	th.sdd	a6,s2,(sp),1,4
    2266:	84ea                	mv	s1,s10
    2268:	896e                	mv	s2,s11
    226a:	89ae                	mv	s3,a1
    226c:	8db6                	mv	s11,a3
    226e:	a029                	j	2278 <_vsnprintf+0xc28>
    2270:	002486b3          	add	a3,s1,sp
    2274:	01f6c503          	lbu	a0,31(a3)
    2278:	40990633          	sub	a2,s2,s1
    227c:	86d6                	mv	a3,s5
    227e:	14fd                	addi	s1,s1,-1
    2280:	85da                	mv	a1,s6
    2282:	844a                	mv	s0,s2
    2284:	9a02                	jalr	s4
    2286:	f4ed                	bnez	s1,2270 <_vsnprintf+0xc20>
    2288:	fb21480b          	th.ldd	a6,s2,(sp),1,4
    228c:	64a2                	ld	s1,8(sp)
    228e:	85ce                	mv	a1,s3
    2290:	02080763          	beqz	a6,22be <_vsnprintf+0xc6e>
    2294:	7c0db98b          	th.extu	s3,s11,31,0
    2298:	03bd7363          	bgeu	s10,s11,22be <_vsnprintf+0xc6e>
    229c:	409404b3          	sub	s1,s0,s1
    22a0:	8d2e                	mv	s10,a1
    22a2:	0001                	nop
    22a4:	00000013          	nop
    22a8:	8622                	mv	a2,s0
    22aa:	86d6                	mv	a3,s5
    22ac:	85da                	mv	a1,s6
    22ae:	02000513          	li	a0,32
    22b2:	0485                	addi	s1,s1,1
    22b4:	0405                	addi	s0,s0,1
    22b6:	9a02                	jalr	s4
    22b8:	ff34e8e3          	bltu	s1,s3,22a8 <_vsnprintf+0xc58>
    22bc:	85ea                	mv	a1,s10
    22be:	8dae                	mv	s11,a1
    22c0:	84a2                	mv	s1,s0
    22c2:	be8ff06f          	j	16aa <_vsnprintf+0x5a>
    22c6:	4e09                	li	t3,2
    22c8:	46c1                	li	a3,16
    22ca:	4705                	li	a4,1
    22cc:	4ae79fe3          	bne	a5,a4,2f8a <_vsnprintf+0x193a>
    22d0:	678d                	lui	a5,0x3
    22d2:	05878793          	addi	a5,a5,88 # 3058 <_vsnprintf+0x1a08>
    22d6:	02f11023          	sh	a5,32(sp)
    22da:	8872                	mv	a6,t3
    22dc:	4789                	li	a5,2
    22de:	00437713          	andi	a4,t1,4
    22e2:	26070263          	beqz	a4,2546 <_vsnprintf+0xef6>
    22e6:	1000                	addi	s0,sp,32
    22e8:	943e                	add	s0,s0,a5
    22ea:	00178d13          	addi	s10,a5,1
    22ee:	02b00513          	li	a0,43
    22f2:	00a40023          	sb	a0,0(s0)
    22f6:	b79d                	j	225c <_vsnprintf+0xc0c>
    22f8:	fee47893          	andi	a7,s0,-18
    22fc:	20047413          	andi	s0,s0,512
    2300:	2881                	sext.w	a7,a7
    2302:	008d8813          	addi	a6,s11,8
    2306:	40000693          	li	a3,1024
    230a:	66041d63          	bnez	s0,2984 <_vsnprintf+0x1334>
    230e:	1008f593          	andi	a1,a7,256
    2312:	87c6                	mv	a5,a7
    2314:	56059263          	bnez	a1,2878 <_vsnprintf+0x1228>
    2318:	0408f613          	andi	a2,a7,64
    231c:	000dae03          	lw	t3,0(s11)
    2320:	20061f63          	bnez	a2,253e <_vsnprintf+0xeee>
    2324:	0807f793          	andi	a5,a5,128
    2328:	2e0789e3          	beqz	a5,2e1a <_vsnprintf+0x17ca>
    232c:	3c0e2e0b          	th.ext	t3,t3,15,0
    2330:	40fe579b          	sraiw	a5,t3,0xf
    2334:	00fe4633          	xor	a2,t3,a5
    2338:	9e1d                	subw	a2,a2,a5
    233a:	3c06360b          	th.extu	a2,a2,15,0
    233e:	300e1463          	bnez	t3,2646 <_vsnprintf+0xff6>
    2342:	30068263          	beqz	a3,2646 <_vsnprintf+0xff6>
    2346:	0028f693          	andi	a3,a7,2
    234a:	87c6                	mv	a5,a7
    234c:	740688e3          	beqz	a3,329c <_vsnprintf+0x1c4c>
    2350:	0048f793          	andi	a5,a7,4
    2354:	e399                	bnez	a5,235a <_vsnprintf+0xd0a>
    2356:	5e60106f          	j	393c <_vsnprintf+0x22ec>
    235a:	02b00513          	li	a0,43
    235e:	02a10023          	sb	a0,32(sp)
    2362:	8426                	mv	s0,s1
    2364:	4589                	li	a1,2
    2366:	4705                	li	a4,1
    2368:	00870d33          	add	s10,a4,s0
    236c:	e426                	sd	s1,8(sp)
    236e:	e84a                	sd	s2,16(sp)
    2370:	84ba                	mv	s1,a4
    2372:	896a                	mv	s2,s10
    2374:	8dc2                	mv	s11,a6
    2376:	8d2e                	mv	s10,a1
    2378:	a031                	j	2384 <_vsnprintf+0xd34>
    237a:	0001                	nop
    237c:	002486b3          	add	a3,s1,sp
    2380:	01f6c503          	lbu	a0,31(a3)
    2384:	40990633          	sub	a2,s2,s1
    2388:	86d6                	mv	a3,s5
    238a:	14fd                	addi	s1,s1,-1
    238c:	85da                	mv	a1,s6
    238e:	844a                	mv	s0,s2
    2390:	9a02                	jalr	s4
    2392:	f4ed                	bnez	s1,237c <_vsnprintf+0xd2c>
    2394:	64a2                	ld	s1,8(sp)
    2396:	6942                	ld	s2,16(sp)
    2398:	85ea                	mv	a1,s10
    239a:	886e                	mv	a6,s11
    239c:	c58d                	beqz	a1,23c6 <_vsnprintf+0xd76>
    239e:	409404b3          	sub	s1,s0,s1
    23a2:	7c09b98b          	th.extu	s3,s3,31,0
    23a6:	0334f063          	bgeu	s1,s3,23c6 <_vsnprintf+0xd76>
    23aa:	8d42                	mv	s10,a6
    23ac:	00000013          	nop
    23b0:	8622                	mv	a2,s0
    23b2:	86d6                	mv	a3,s5
    23b4:	85da                	mv	a1,s6
    23b6:	02000513          	li	a0,32
    23ba:	0485                	addi	s1,s1,1
    23bc:	0405                	addi	s0,s0,1
    23be:	9a02                	jalr	s4
    23c0:	ff34e8e3          	bltu	s1,s3,23b0 <_vsnprintf+0xd60>
    23c4:	886a                	mv	a6,s10
    23c6:	8dc2                	mv	s11,a6
    23c8:	84a2                	mv	s1,s0
    23ca:	ae0ff06f          	j	16aa <_vsnprintf+0x5a>
    23ce:	01337563          	bgeu	t1,s3,23d8 <_vsnprintf+0xd88>
    23d2:	0e088ae3          	beqz	a7,2cc6 <_vsnprintf+0x1676>
    23d6:	4889                	li	a7,2
    23d8:	000d0863          	beqz	s10,23e8 <_vsnprintf+0xd98>
    23dc:	f2068753          	fmv.d.x	fa4,a3
    23e0:	1af777d3          	fdiv.d	fa5,fa4,fa5
    23e4:	e20786d3          	fmv.x.d	a3,fa5
    23e8:	f20007d3          	fmv.d.x	fa5,zero
    23ec:	a2f51653          	flt.d	a2,fa0,fa5
    23f0:	c219                	beqz	a2,23f6 <_vsnprintf+0xda6>
    23f2:	0330106f          	j	3c24 <_vsnprintf+0x25d4>
    23f6:	787d                	lui	a6,0xfffff
    23f8:	7ff80813          	addi	a6,a6,2047 # fffffffffffff7ff <__kernel_stack+0xfffffffffff117ff>
    23fc:	01047833          	and	a6,s0,a6
    2400:	f2068553          	fmv.d.x	fa0,a3
    2404:	fb11530b          	th.sdd	t1,a7,(sp),1,4
    2408:	2801                	sext.w	a6,a6
    240a:	86d6                	mv	a3,s5
    240c:	8626                	mv	a2,s1
    240e:	85da                	mv	a1,s6
    2410:	8552                	mv	a0,s4
    2412:	9fffe0ef          	jal	e10 <_ftoa>
    2416:	fb11430b          	th.ldd	t1,a7,(sp),1,4
    241a:	862a                	mv	a2,a0
    241c:	06500793          	li	a5,101
    2420:	02047413          	andi	s0,s0,32
    2424:	04500513          	li	a0,69
    2428:	4087950b          	th.mveqz	a0,a5,s0
    242c:	86d6                	mv	a3,s5
    242e:	85da                	mv	a1,s6
    2430:	fb11530b          	th.sdd	t1,a7,(sp),1,4
    2434:	00160d93          	addi	s11,a2,1
    2438:	9a02                	jalr	s4
    243a:	41fd579b          	sraiw	a5,s10,0x1f
    243e:	00fd4733          	xor	a4,s10,a5
    2442:	fb11430b          	th.ldd	t1,a7,(sp),1,4
    2446:	1000                	addi	s0,sp,32
    2448:	9f1d                	subw	a4,a4,a5
    244a:	4681                	li	a3,0
    244c:	45a9                	li	a1,10
    244e:	4e25                	li	t3,9
    2450:	02000e93          	li	t4,32
    2454:	a021                	j	245c <_vsnprintf+0xe0c>
    2456:	0001                	nop
    2458:	7dd68f63          	beq	a3,t4,2c36 <_vsnprintf+0x15e6>
    245c:	02b77633          	remu	a2,a4,a1
    2460:	0685                	addi	a3,a3,1
    2462:	00d407b3          	add	a5,s0,a3
    2466:	853a                	mv	a0,a4
    2468:	0306061b          	addiw	a2,a2,48
    246c:	fec78fa3          	sb	a2,-1(a5)
    2470:	02b75733          	divu	a4,a4,a1
    2474:	feae62e3          	bltu	t3,a0,2458 <_vsnprintf+0xe08>
    2478:	ffe3061b          	addiw	a2,t1,-2
    247c:	7c06360b          	th.extu	a2,a2,31,0
    2480:	7cc6f063          	bgeu	a3,a2,2c40 <_vsnprintf+0x15f0>
    2484:	00c406b3          	add	a3,s0,a2
    2488:	03000713          	li	a4,48
    248c:	00000013          	nop
    2490:	1817d70b          	th.sbia	a4,(a5),1,0
    2494:	fef69ee3          	bne	a3,a5,2490 <_vsnprintf+0xe40>
    2498:	00160793          	addi	a5,a2,1
    249c:	420d5ce3          	bgez	s10,30d4 <_vsnprintf+0x1a84>
    24a0:	02d00513          	li	a0,45
    24a4:	00c4550b          	th.srb	a0,s0,a2,0
    24a8:	00fd8833          	add	a6,s11,a5
    24ac:	fb21548b          	th.sdd	s1,s2,(sp),1,4
    24b0:	8d22                	mv	s10,s0
    24b2:	8dc6                	mv	s11,a7
    24b4:	84be                	mv	s1,a5
    24b6:	8442                	mv	s0,a6
    24b8:	a031                	j	24c4 <_vsnprintf+0xe74>
    24ba:	0001                	nop
    24bc:	009d0733          	add	a4,s10,s1
    24c0:	fff74503          	lbu	a0,-1(a4)
    24c4:	40940633          	sub	a2,s0,s1
    24c8:	86d6                	mv	a3,s5
    24ca:	14fd                	addi	s1,s1,-1
    24cc:	85da                	mv	a1,s6
    24ce:	9a02                	jalr	s4
    24d0:	f4f5                	bnez	s1,24bc <_vsnprintf+0xe6c>
    24d2:	88ee                	mv	a7,s11
    24d4:	fb21448b          	th.ldd	s1,s2,(sp),1,4
    24d8:	8da2                	mv	s11,s0
    24da:	8822                	mv	a6,s0
    24dc:	74088963          	beqz	a7,2c2e <_vsnprintf+0x15de>
    24e0:	409404b3          	sub	s1,s0,s1
    24e4:	7c09b98b          	th.extu	s3,s3,31,0
    24e8:	7534f363          	bgeu	s1,s3,2c2e <_vsnprintf+0x15de>
    24ec:	866e                	mv	a2,s11
    24ee:	86d6                	mv	a3,s5
    24f0:	85da                	mv	a1,s6
    24f2:	02000513          	li	a0,32
    24f6:	0485                	addi	s1,s1,1
    24f8:	0d85                	addi	s11,s11,1
    24fa:	9a02                	jalr	s4
    24fc:	ff34e8e3          	bltu	s1,s3,24ec <_vsnprintf+0xe9c>
    2500:	84ee                	mv	s1,s11
    2502:	6da2                	ld	s11,8(sp)
    2504:	9a6ff06f          	j	16aa <_vsnprintf+0x5a>
    2508:	00c37693          	andi	a3,t1,12
    250c:	260682e3          	beqz	a3,2f70 <_vsnprintf+0x1920>
    2510:	453d                	li	a0,15
    2512:	86aa                	mv	a3,a0
    2514:	26eef2e3          	bgeu	t4,a4,2f78 <_vsnprintf+0x1928>
    2518:	02000613          	li	a2,32
    251c:	03000e93          	li	t4,48
    2520:	7c07388b          	th.extu	a7,a4,31,0
    2524:	00000013          	nop
    2528:	78c780e3          	beq	a5,a2,34a8 <_vsnprintf+0x1e58>
    252c:	1000                	addi	s0,sp,32
    252e:	00f45e8b          	th.srb	t4,s0,a5,0
    2532:	00178d13          	addi	s10,a5,1
    2536:	b91d7f63          	bgeu	s10,a7,18d4 <_vsnprintf+0x284>
    253a:	87ea                	mv	a5,s10
    253c:	b7f5                	j	2528 <_vsnprintf+0xed8>
    253e:	0ffe7e13          	zext.b	t3,t3
    2542:	8672                	mv	a2,t3
    2544:	bbed                	j	233e <_vsnprintf+0xcee>
    2546:	00837313          	andi	t1,t1,8
    254a:	0c031fe3          	bnez	t1,2e28 <_vsnprintf+0x17d8>
    254e:	00278733          	add	a4,a5,sp
    2552:	01f74503          	lbu	a0,31(a4)
    2556:	8d3e                	mv	s10,a5
    2558:	b311                	j	225c <_vsnprintf+0xc0c>
    255a:	453d                	li	a0,15
    255c:	86aa                	mv	a3,a0
    255e:	b68ff06f          	j	18c6 <_vsnprintf+0x276>
    2562:	0047f713          	andi	a4,a5,4
    2566:	0c071be3          	bnez	a4,2e3c <_vsnprintf+0x17ec>
    256a:	8ba1                	andi	a5,a5,8
    256c:	5c0796e3          	bnez	a5,3338 <_vsnprintf+0x1ce8>
    2570:	8426                	mv	s0,s1
    2572:	49c1                	li	s3,16
    2574:	b325                	j	229c <_vsnprintf+0xc4c>
    2576:	46c1                	li	a3,16
    2578:	88b6                	mv	a7,a3
    257a:	b0b5                	j	1de6 <_vsnprintf+0x796>
    257c:	4809                	li	a6,2
    257e:	46c1                	li	a3,16
    2580:	b6e9                	j	214a <_vsnprintf+0xafa>
    2582:	000dc583          	lbu	a1,0(s11)
    2586:	b055                	j	1e2a <_vsnprintf+0x7da>
    2588:	40047793          	andi	a5,s0,1024
    258c:	5c079ce3          	bnez	a5,3364 <_vsnprintf+0x1d14>
    2590:	8809                	andi	s0,s0,2
    2592:	a2041ce3          	bnez	s0,1fca <_vsnprintf+0x97a>
    2596:	4401                	li	s0,0
    2598:	0137e463          	bltu	a5,s3,25a0 <_vsnprintf+0xf50>
    259c:	03c0106f          	j	35d8 <_vsnprintf+0x1f88>
    25a0:	fff98d9b          	addiw	s11,s3,-1
    25a4:	40fd8dbb          	subw	s11,s11,a5
    25a8:	00148d13          	addi	s10,s1,1
    25ac:	7c0dbd8b          	th.extu	s11,s11,31,0
    25b0:	fb21540b          	th.sdd	s0,s2,(sp),1,4
    25b4:	9dea                	add	s11,s11,s10
    25b6:	8426                	mv	s0,s1
    25b8:	e442                	sd	a6,8(sp)
    25ba:	84ea                	mv	s1,s10
    25bc:	892e                	mv	s2,a1
    25be:	8d3a                	mv	s10,a4
    25c0:	a019                	j	25c6 <_vsnprintf+0xf76>
    25c2:	0001                	nop
    25c4:	0485                	addi	s1,s1,1
    25c6:	8622                	mv	a2,s0
    25c8:	86d6                	mv	a3,s5
    25ca:	85da                	mv	a1,s6
    25cc:	02000513          	li	a0,32
    25d0:	8426                	mv	s0,s1
    25d2:	9a02                	jalr	s4
    25d4:	ffb498e3          	bne	s1,s11,25c4 <_vsnprintf+0xf74>
    25d8:	6822                	ld	a6,8(sp)
    25da:	85ca                	mv	a1,s2
    25dc:	876a                	mv	a4,s10
    25de:	00084503          	lbu	a0,0(a6)
    25e2:	fb21440b          	th.ldd	s0,s2,(sp),1,4
    25e6:	0019879b          	addiw	a5,s3,1
    25ea:	cc050963          	beqz	a0,1abc <_vsnprintf+0x46c>
    25ee:	ca040163          	beqz	s0,1a90 <_vsnprintf+0x440>
    25f2:	4401                	li	s0,0
    25f4:	fa0ff06f          	j	1d94 <_vsnprintf+0x744>
    25f8:	000dc503          	lbu	a0,0(s11)
    25fc:	8626                	mv	a2,s1
    25fe:	86d6                	mv	a3,s5
    2600:	85da                	mv	a1,s6
    2602:	9a02                	jalr	s4
    2604:	84ea                	mv	s1,s10
    2606:	8da2                	mv	s11,s0
    2608:	8a2ff06f          	j	16aa <_vsnprintf+0x5a>
    260c:	00278733          	add	a4,a5,sp
    2610:	05800613          	li	a2,88
    2614:	00c70f23          	sb	a2,30(a4)
    2618:	9d0a                	add	s10,s10,sp
    261a:	03000713          	li	a4,48
    261e:	8872                	mv	a6,t3
    2620:	02ed0023          	sb	a4,32(s10)
    2624:	b96d                	j	22de <_vsnprintf+0xc8e>
    2626:	00e10433          	add	s0,sp,a4
    262a:	01b40733          	add	a4,s0,s11
    262e:	0d85                	addi	s11,s11,1
    2630:	03000513          	li	a0,48
    2634:	00a70023          	sb	a0,0(a4)
    2638:	e789                	bnez	a5,2642 <_vsnprintf+0xff2>
    263a:	7c09b40b          	th.extu	s0,s3,31,0
    263e:	8c8deae3          	bltu	s11,s0,1f12 <_vsnprintf+0x8c2>
    2642:	87a6                	mv	a5,s1
    2644:	b21d                	j	1f6a <_vsnprintf+0x91a>
    2646:	4781                	li	a5,0
    2648:	1000                	addi	s0,sp,32
    264a:	4329                	li	t1,10
    264c:	4f25                	li	t5,9
    264e:	02000f93          	li	t6,32
    2652:	a019                	j	2658 <_vsnprintf+0x1008>
    2654:	01f782e3          	beq	a5,t6,2e58 <_vsnprintf+0x1808>
    2658:	02667533          	remu	a0,a2,t1
    265c:	86be                	mv	a3,a5
    265e:	0785                	addi	a5,a5,1
    2660:	00f402b3          	add	t0,s0,a5
    2664:	8eb2                	mv	t4,a2
    2666:	0305051b          	addiw	a0,a0,48
    266a:	fea28fa3          	sb	a0,-1(t0)
    266e:	02665633          	divu	a2,a2,t1
    2672:	ffdf61e3          	bltu	t5,t4,2654 <_vsnprintf+0x1004>
    2676:	0028f513          	andi	a0,a7,2
    267a:	8646                	mv	a2,a7
    267c:	120500e3          	beqz	a0,2f9c <_vsnprintf+0x194c>
    2680:	02000713          	li	a4,32
    2684:	7ce78263          	beq	a5,a4,2e48 <_vsnprintf+0x17f8>
    2688:	000e4463          	bltz	t3,2690 <_vsnprintf+0x1040>
    268c:	6b20106f          	j	3d3e <_vsnprintf+0x26ee>
    2690:	978a                	add	a5,a5,sp
    2692:	02d00613          	li	a2,45
    2696:	00268713          	addi	a4,a3,2
    269a:	02c78023          	sb	a2,32(a5)
    269e:	4589                	li	a1,2
    26a0:	8426                	mv	s0,s1
    26a2:	02d00513          	li	a0,45
    26a6:	b1c9                	j	2368 <_vsnprintf+0xd18>
    26a8:	000db303          	ld	t1,0(s11)
    26ac:	5a031063          	bnez	t1,2c4c <_vsnprintf+0x15fc>
    26b0:	fefe7613          	andi	a2,t3,-17
    26b4:	2601                	sext.w	a2,a2
    26b6:	36081be3          	bnez	a6,322c <_vsnprintf+0x1bdc>
    26ba:	4581                	li	a1,0
    26bc:	1456350b          	th.extu	a0,a2,5,5
    26c0:	06100793          	li	a5,97
    26c4:	c119                	beqz	a0,26ca <_vsnprintf+0x107a>
    26c6:	04100793          	li	a5,65
    26ca:	ff678f1b          	addiw	t5,a5,-10
    26ce:	4e01                	li	t3,0
    26d0:	1000                	addi	s0,sp,32
    26d2:	42a5                	li	t0,9
    26d4:	02000f93          	li	t6,32
    26d8:	a031                	j	26e4 <_vsnprintf+0x1094>
    26da:	0001                	nop
    26dc:	39fd80e3          	beq	s11,t6,325c <_vsnprintf+0x1c0c>
    26e0:	8e6e                	mv	t3,s11
    26e2:	8376                	mv	t1,t4
    26e4:	02d35eb3          	divu	t4,t1,a3
    26e8:	851a                	mv	a0,t1
    26ea:	001e0d93          	addi	s11,t3,1
    26ee:	22de950b          	th.muls	a0,t4,a3
    26f2:	0ff57793          	zext.b	a5,a0
    26f6:	0307839b          	addiw	t2,a5,48
    26fa:	00ff07bb          	addw	a5,t5,a5
    26fe:	00a2b533          	sltu	a0,t0,a0
    2702:	0ff3f393          	zext.b	t2,t2
    2706:	0ff7f793          	zext.b	a5,a5
    270a:	40a3978b          	th.mveqz	a5,t2,a0
    270e:	01c4578b          	th.srb	a5,s0,t3,0
    2712:	fcd375e3          	bgeu	t1,a3,26dc <_vsnprintf+0x108c>
    2716:	00267693          	andi	a3,a2,2
    271a:	87b2                	mv	a5,a2
    271c:	100686e3          	beqz	a3,3028 <_vsnprintf+0x19d8>
    2720:	e199                	bnez	a1,2726 <_vsnprintf+0x10d6>
    2722:	0420106f          	j	3764 <_vsnprintf+0x2114>
    2726:	720818e3          	bnez	a6,3656 <_vsnprintf+0x2006>
    272a:	7c07370b          	th.extu	a4,a4,31,0
    272e:	4809                	li	a6,2
    2730:	01b71463          	bne	a4,s11,2738 <_vsnprintf+0x10e8>
    2734:	1ac0106f          	j	38e0 <_vsnprintf+0x2290>
    2738:	7c09b78b          	th.extu	a5,s3,31,0
    273c:	01b79463          	bne	a5,s11,2744 <_vsnprintf+0x10f4>
    2740:	1a00106f          	j	38e0 <_vsnprintf+0x2290>
    2744:	00367713          	andi	a4,a2,3
    2748:	46c1                	li	a3,16
    274a:	87ba                	mv	a5,a4
    274c:	85c2                	mv	a1,a6
    274e:	6ed881e3          	beq	a7,a3,3630 <_vsnprintf+0x1fe0>
    2752:	4689                	li	a3,2
    2754:	00d89463          	bne	a7,a3,275c <_vsnprintf+0x110c>
    2758:	15e0106f          	j	38b6 <_vsnprintf+0x2266>
    275c:	02000693          	li	a3,32
    2760:	0007079b          	sext.w	a5,a4
    2764:	0cdd9363          	bne	s11,a3,282a <_vsnprintf+0x11da>
    2768:	5e0790e3          	bnez	a5,3548 <_vsnprintf+0x1ef8>
    276c:	02000d93          	li	s11,32
    2770:	7c09b40b          	th.extu	s0,s3,31,0
    2774:	013de463          	bltu	s11,s3,277c <_vsnprintf+0x112c>
    2778:	15e0106f          	j	38d6 <_vsnprintf+0x2286>
    277c:	874a                	mv	a4,s2
    277e:	409d87b3          	sub	a5,s11,s1
    2782:	8926                	mv	s2,s1
    2784:	fab1548b          	th.sdd	s1,a1,(sp),1,4
    2788:	8d3a                	mv	s10,a4
    278a:	84be                	mv	s1,a5
    278c:	864a                	mv	a2,s2
    278e:	86d6                	mv	a3,s5
    2790:	85da                	mv	a1,s6
    2792:	02000513          	li	a0,32
    2796:	0905                	addi	s2,s2,1
    2798:	9a02                	jalr	s4
    279a:	01248733          	add	a4,s1,s2
    279e:	fe8767e3          	bltu	a4,s0,278c <_vsnprintf+0x113c>
    27a2:	fab1448b          	th.ldd	s1,a1,(sp),1,4
    27a6:	fff40793          	addi	a5,s0,-1
    27aa:	001d8693          	addi	a3,s11,1
    27ae:	00d43733          	sltu	a4,s0,a3
    27b2:	41b787b3          	sub	a5,a5,s11
    27b6:	42e0178b          	th.mvnez	a5,zero,a4
    27ba:	00148713          	addi	a4,s1,1
    27be:	896a                	mv	s2,s10
    27c0:	97ba                	add	a5,a5,a4
    27c2:	000d9463          	bnez	s11,27ca <_vsnprintf+0x117a>
    27c6:	1700106f          	j	3936 <_vsnprintf+0x22e6>
    27ca:	002d8733          	add	a4,s11,sp
    27ce:	01f74503          	lbu	a0,31(a4)
    27d2:	00fd8d33          	add	s10,s11,a5
    27d6:	e826                	sd	s1,16(sp)
    27d8:	84ea                	mv	s1,s10
    27da:	8d4a                	mv	s10,s2
    27dc:	892e                	mv	s2,a1
    27de:	a029                	j	27e8 <_vsnprintf+0x1198>
    27e0:	002d8733          	add	a4,s11,sp
    27e4:	01f74503          	lbu	a0,31(a4)
    27e8:	41b48633          	sub	a2,s1,s11
    27ec:	86d6                	mv	a3,s5
    27ee:	1dfd                	addi	s11,s11,-1
    27f0:	85da                	mv	a1,s6
    27f2:	8426                	mv	s0,s1
    27f4:	9a02                	jalr	s4
    27f6:	fe0d95e3          	bnez	s11,27e0 <_vsnprintf+0x1190>
    27fa:	64c2                	ld	s1,16(sp)
    27fc:	85ca                	mv	a1,s2
    27fe:	896a                	mv	s2,s10
    2800:	c18d                	beqz	a1,2822 <_vsnprintf+0x11d2>
    2802:	409404b3          	sub	s1,s0,s1
    2806:	7c09b98b          	th.extu	s3,s3,31,0
    280a:	0134fc63          	bgeu	s1,s3,2822 <_vsnprintf+0x11d2>
    280e:	8622                	mv	a2,s0
    2810:	86d6                	mv	a3,s5
    2812:	85da                	mv	a1,s6
    2814:	02000513          	li	a0,32
    2818:	0485                	addi	s1,s1,1
    281a:	0405                	addi	s0,s0,1
    281c:	9a02                	jalr	s4
    281e:	ff34e8e3          	bltu	s1,s3,280e <_vsnprintf+0x11be>
    2822:	6da2                	ld	s11,8(sp)
    2824:	84a2                	mv	s1,s0
    2826:	e85fe06f          	j	16aa <_vsnprintf+0x5a>
    282a:	00d10433          	add	s0,sp,a3
    282e:	01b407b3          	add	a5,s0,s11
    2832:	0d85                	addi	s11,s11,1
    2834:	03000513          	li	a0,48
    2838:	00a78023          	sb	a0,0(a5)
    283c:	e709                	bnez	a4,2846 <_vsnprintf+0x11f6>
    283e:	7c09b40b          	th.extu	s0,s3,31,0
    2842:	f28dede3          	bltu	s11,s0,277c <_vsnprintf+0x112c>
    2846:	87a6                	mv	a5,s1
    2848:	b769                	j	27d2 <_vsnprintf+0x1182>
    284a:	40000413          	li	s0,1024
    284e:	d537e9e3          	bltu	a5,s3,25a0 <_vsnprintf+0xf50>
    2852:	a6050563          	beqz	a0,1abc <_vsnprintf+0x46c>
    2856:	2785                	addiw	a5,a5,1
    2858:	8da6                	mv	s11,s1
    285a:	4401                	li	s0,0
    285c:	d38ff06f          	j	1d94 <_vsnprintf+0x744>
    2860:	10070b63          	beqz	a4,2976 <_vsnprintf+0x1326>
    2864:	10058963          	beqz	a1,2976 <_vsnprintf+0x1326>
    2868:	377d                	addiw	a4,a4,-1
    286a:	01337563          	bgeu	t1,s3,2874 <_vsnprintf+0x1224>
    286e:	44088c63          	beqz	a7,2cc6 <_vsnprintf+0x1676>
    2872:	4889                	li	a7,2
    2874:	4781                	li	a5,0
    2876:	b68d                	j	23d8 <_vsnprintf+0xd88>
    2878:	000db303          	ld	t1,0(s11)
    287c:	44030963          	beqz	t1,2cce <_vsnprintf+0x167e>
    2880:	43f35793          	srai	a5,t1,0x3f
    2884:	0067c6b3          	xor	a3,a5,t1
    2888:	8e9d                	sub	a3,a3,a5
    288a:	4781                	li	a5,0
    288c:	1000                	addi	s0,sp,32
    288e:	45a9                	li	a1,10
    2890:	4e25                	li	t3,9
    2892:	02000e93          	li	t4,32
    2896:	a019                	j	289c <_vsnprintf+0x124c>
    2898:	11d783e3          	beq	a5,t4,319e <_vsnprintf+0x1b4e>
    289c:	02b6f633          	remu	a2,a3,a1
    28a0:	8d3e                	mv	s10,a5
    28a2:	0785                	addi	a5,a5,1
    28a4:	00f40f33          	add	t5,s0,a5
    28a8:	8536                	mv	a0,a3
    28aa:	0306061b          	addiw	a2,a2,48
    28ae:	fecf0fa3          	sb	a2,-1(t5)
    28b2:	02b6d6b3          	divu	a3,a3,a1
    28b6:	feae61e3          	bltu	t3,a0,2898 <_vsnprintf+0x1248>
    28ba:	0028f613          	andi	a2,a7,2
    28be:	86c6                	mv	a3,a7
    28c0:	280601e3          	beqz	a2,3342 <_vsnprintf+0x1cf2>
    28c4:	02000513          	li	a0,32
    28c8:	1ca782e3          	beq	a5,a0,328c <_vsnprintf+0x1c3c>
    28cc:	00034463          	bltz	t1,28d4 <_vsnprintf+0x1284>
    28d0:	2440106f          	j	3b14 <_vsnprintf+0x24c4>
    28d4:	02d00713          	li	a4,45
    28d8:	978a                	add	a5,a5,sp
    28da:	02e78023          	sb	a4,32(a5)
    28de:	0d09                	addi	s10,s10,2
    28e0:	4709                	li	a4,2
    28e2:	8426                	mv	s0,s1
    28e4:	02d00513          	li	a0,45
    28e8:	008d0db3          	add	s11,s10,s0
    28ec:	87ee                	mv	a5,s11
    28ee:	e426                	sd	s1,8(sp)
    28f0:	e83a                	sd	a4,16(sp)
    28f2:	8dca                	mv	s11,s2
    28f4:	84ea                	mv	s1,s10
    28f6:	893e                	mv	s2,a5
    28f8:	8d42                	mv	s10,a6
    28fa:	a029                	j	2904 <_vsnprintf+0x12b4>
    28fc:	002486b3          	add	a3,s1,sp
    2900:	01f6c503          	lbu	a0,31(a3)
    2904:	40990633          	sub	a2,s2,s1
    2908:	86d6                	mv	a3,s5
    290a:	14fd                	addi	s1,s1,-1
    290c:	85da                	mv	a1,s6
    290e:	844a                	mv	s0,s2
    2910:	9a02                	jalr	s4
    2912:	f4ed                	bnez	s1,28fc <_vsnprintf+0x12ac>
    2914:	64a2                	ld	s1,8(sp)
    2916:	6742                	ld	a4,16(sp)
    2918:	886a                	mv	a6,s10
    291a:	896e                	mv	s2,s11
    291c:	aa0705e3          	beqz	a4,23c6 <_vsnprintf+0xd76>
    2920:	409404b3          	sub	s1,s0,s1
    2924:	7c09b98b          	th.extu	s3,s3,31,0
    2928:	a934ffe3          	bgeu	s1,s3,23c6 <_vsnprintf+0xd76>
    292c:	8d42                	mv	s10,a6
    292e:	8622                	mv	a2,s0
    2930:	86d6                	mv	a3,s5
    2932:	85da                	mv	a1,s6
    2934:	02000513          	li	a0,32
    2938:	0485                	addi	s1,s1,1
    293a:	0405                	addi	s0,s0,1
    293c:	9a02                	jalr	s4
    293e:	ff34e8e3          	bltu	s1,s3,292e <_vsnprintf+0x12de>
    2942:	886a                	mv	a6,s10
    2944:	b449                	j	23c6 <_vsnprintf+0xd76>
    2946:	fef47893          	andi	a7,s0,-17
    294a:	06900793          	li	a5,105
    294e:	2881                	sext.w	a7,a7
    2950:	86a2                	mv	a3,s0
    2952:	78f51763          	bne	a0,a5,30e0 <_vsnprintf+0x1a90>
    2956:	40047793          	andi	a5,s0,1024
    295a:	98079fe3          	bnez	a5,22f8 <_vsnprintf+0xca8>
    295e:	2006f693          	andi	a3,a3,512
    2962:	008d8813          	addi	a6,s11,8
    2966:	9a0684e3          	beqz	a3,230e <_vsnprintf+0xcbe>
    296a:	ebeff06f          	j	2028 <_vsnprintf+0x9d8>
    296e:	6da2                	ld	s11,8(sp)
    2970:	84be                	mv	s1,a5
    2972:	d39fe06f          	j	16aa <_vsnprintf+0x5a>
    2976:	ef337fe3          	bgeu	t1,s3,2874 <_vsnprintf+0x1224>
    297a:	34088663          	beqz	a7,2cc6 <_vsnprintf+0x1676>
    297e:	4781                	li	a5,0
    2980:	4889                	li	a7,2
    2982:	bc99                	j	23d8 <_vsnprintf+0xd88>
    2984:	000dbe83          	ld	t4,0(s11)
    2988:	8dc2                	mv	s11,a6
    298a:	ea0e9563          	bnez	t4,2034 <_vsnprintf+0x9e4>
    298e:	0028f693          	andi	a3,a7,2
    2992:	87c6                	mv	a5,a7
    2994:	2e0692e3          	bnez	a3,3478 <_vsnprintf+0x1e28>
    2998:	7c07370b          	th.extu	a4,a4,31,0
    299c:	4781                	li	a5,0
    299e:	4e81                	li	t4,0
    29a0:	280996e3          	bnez	s3,342c <_vsnprintf+0x1ddc>
    29a4:	e319                	bnez	a4,29aa <_vsnprintf+0x135a>
    29a6:	14c0106f          	j	3af2 <_vsnprintf+0x24a2>
    29aa:	0018f613          	andi	a2,a7,1
    29ae:	4981                	li	s3,0
    29b0:	02000593          	li	a1,32
    29b4:	00b10833          	add	a6,sp,a1
    29b8:	03000513          	li	a0,48
    29bc:	00000013          	nop
    29c0:	70b78363          	beq	a5,a1,30c6 <_vsnprintf+0x1a76>
    29c4:	0785                	addi	a5,a5,1
    29c6:	00f806b3          	add	a3,a6,a5
    29ca:	fea68fa3          	sb	a0,-1(a3)
    29ce:	fee7e9e3          	bltu	a5,a4,29c0 <_vsnprintf+0x1370>
    29d2:	3e0600e3          	beqz	a2,35b2 <_vsnprintf+0x1f62>
    29d6:	7c09b70b          	th.extu	a4,s3,31,0
    29da:	00e7e463          	bltu	a5,a4,29e2 <_vsnprintf+0x1392>
    29de:	3d20106f          	j	3db0 <_vsnprintf+0x2760>
    29e2:	02000613          	li	a2,32
    29e6:	00c10533          	add	a0,sp,a2
    29ea:	03000593          	li	a1,48
    29ee:	0001                	nop
    29f0:	0ac78363          	beq	a5,a2,2a96 <_vsnprintf+0x1446>
    29f4:	0785                	addi	a5,a5,1
    29f6:	00f506b3          	add	a3,a0,a5
    29fa:	feb68fa3          	sb	a1,-1(a3)
    29fe:	fee799e3          	bne	a5,a4,29f0 <_vsnprintf+0x13a0>
    2a02:	0038f693          	andi	a3,a7,3
    2a06:	02000793          	li	a5,32
    2a0a:	8636                	mv	a2,a3
    2a0c:	08f70763          	beq	a4,a5,2a9a <_vsnprintf+0x144a>
    2a10:	7e0ecb63          	bltz	t4,3206 <_vsnprintf+0x1bb6>
    2a14:	0048f793          	andi	a5,a7,4
    2a18:	2681                	sext.w	a3,a3
    2a1a:	76078be3          	beqz	a5,3990 <_vsnprintf+0x2340>
    2a1e:	002707b3          	add	a5,a4,sp
    2a22:	02b00513          	li	a0,43
    2a26:	02a78023          	sb	a0,32(a5)
    2a2a:	0705                	addi	a4,a4,1
    2a2c:	c299                	beqz	a3,2a32 <_vsnprintf+0x13e2>
    2a2e:	2e40106f          	j	3d12 <_vsnprintf+0x26c2>
    2a32:	7c09b40b          	th.extu	s0,s3,31,0
    2a36:	6e877de3          	bgeu	a4,s0,3930 <_vsnprintf+0x22e0>
    2a3a:	409707b3          	sub	a5,a4,s1
    2a3e:	fae1568b          	th.sdd	a3,a4,(sp),1,4
    2a42:	874a                	mv	a4,s2
    2a44:	e426                	sd	s1,8(sp)
    2a46:	8926                	mv	s2,s1
    2a48:	8d3a                	mv	s10,a4
    2a4a:	84be                	mv	s1,a5
    2a4c:	00000013          	nop
    2a50:	864a                	mv	a2,s2
    2a52:	86d6                	mv	a3,s5
    2a54:	85da                	mv	a1,s6
    2a56:	02000513          	li	a0,32
    2a5a:	0905                	addi	s2,s2,1
    2a5c:	9a02                	jalr	s4
    2a5e:	01248733          	add	a4,s1,s2
    2a62:	fe8767e3          	bltu	a4,s0,2a50 <_vsnprintf+0x1400>
    2a66:	fae1468b          	th.ldd	a3,a4,(sp),1,4
    2a6a:	64a2                	ld	s1,8(sp)
    2a6c:	fff40793          	addi	a5,s0,-1
    2a70:	00170613          	addi	a2,a4,1
    2a74:	00c435b3          	sltu	a1,s0,a2
    2a78:	8f99                	sub	a5,a5,a4
    2a7a:	42b0178b          	th.mvnez	a5,zero,a1
    2a7e:	00148613          	addi	a2,s1,1
    2a82:	896a                	mv	s2,s10
    2a84:	97b2                	add	a5,a5,a2
    2a86:	32070ee3          	beqz	a4,35c2 <_vsnprintf+0x1f72>
    2a8a:	00270633          	add	a2,a4,sp
    2a8e:	01f64503          	lbu	a0,31(a2)
    2a92:	e16ff06f          	j	20a8 <_vsnprintf+0xa58>
    2a96:	0038f613          	andi	a2,a7,3
    2a9a:	ea01                	bnez	a2,2aaa <_vsnprintf+0x145a>
    2a9c:	02000713          	li	a4,32
    2aa0:	7c09b40b          	th.extu	s0,s3,31,0
    2aa4:	4681                	li	a3,0
    2aa6:	f9376ae3          	bltu	a4,s3,2a3a <_vsnprintf+0x13ea>
    2aaa:	03f14503          	lbu	a0,63(sp)
    2aae:	87a6                	mv	a5,s1
    2ab0:	4681                	li	a3,0
    2ab2:	02000713          	li	a4,32
    2ab6:	df2ff06f          	j	20a8 <_vsnprintf+0xa58>
    2aba:	000db503          	ld	a0,0(s11)
    2abe:	52051963          	bnez	a0,2ff0 <_vsnprintf+0x19a0>
    2ac2:	fefe7613          	andi	a2,t3,-17
    2ac6:	2601                	sext.w	a2,a2
    2ac8:	0e0815e3          	bnez	a6,33b2 <_vsnprintf+0x1d62>
    2acc:	4281                	li	t0,0
    2ace:	1456358b          	th.extu	a1,a2,5,5
    2ad2:	06100793          	li	a5,97
    2ad6:	c199                	beqz	a1,2adc <_vsnprintf+0x148c>
    2ad8:	04100793          	li	a5,65
    2adc:	ff678e9b          	addiw	t4,a5,-10
    2ae0:	4301                	li	t1,0
    2ae2:	1000                	addi	s0,sp,32
    2ae4:	4fa5                	li	t6,9
    2ae6:	02000f13          	li	t5,32
    2aea:	a029                	j	2af4 <_vsnprintf+0x14a4>
    2aec:	11ed88e3          	beq	s11,t5,33fc <_vsnprintf+0x1dac>
    2af0:	836e                	mv	t1,s11
    2af2:	8572                	mv	a0,t3
    2af4:	02d55e33          	divu	t3,a0,a3
    2af8:	85aa                	mv	a1,a0
    2afa:	00130d93          	addi	s11,t1,1
    2afe:	22de158b          	th.muls	a1,t3,a3
    2b02:	0ff5f793          	zext.b	a5,a1
    2b06:	0307839b          	addiw	t2,a5,48
    2b0a:	00fe87bb          	addw	a5,t4,a5
    2b0e:	00bfb5b3          	sltu	a1,t6,a1
    2b12:	0ff3f393          	zext.b	t2,t2
    2b16:	0ff7f793          	zext.b	a5,a5
    2b1a:	40b3978b          	th.mveqz	a5,t2,a1
    2b1e:	0064578b          	th.srb	a5,s0,t1,0
    2b22:	fcd575e3          	bgeu	a0,a3,2aec <_vsnprintf+0x149c>
    2b26:	00267693          	andi	a3,a2,2
    2b2a:	87b2                	mv	a5,a2
    2b2c:	60068663          	beqz	a3,3138 <_vsnprintf+0x1ae8>
    2b30:	4c0285e3          	beqz	t0,37fa <_vsnprintf+0x21aa>
    2b34:	700810e3          	bnez	a6,3a34 <_vsnprintf+0x23e4>
    2b38:	7c07370b          	th.extu	a4,a4,31,0
    2b3c:	4809                	li	a6,2
    2b3e:	6bb70be3          	beq	a4,s11,39f4 <_vsnprintf+0x23a4>
    2b42:	7c09b78b          	th.extu	a5,s3,31,0
    2b46:	6bb787e3          	beq	a5,s11,39f4 <_vsnprintf+0x23a4>
    2b4a:	00367713          	andi	a4,a2,3
    2b4e:	46c1                	li	a3,16
    2b50:	87ba                	mv	a5,a4
    2b52:	68d884e3          	beq	a7,a3,39da <_vsnprintf+0x238a>
    2b56:	4689                	li	a3,2
    2b58:	52d88de3          	beq	a7,a3,3892 <_vsnprintf+0x2242>
    2b5c:	02000693          	li	a3,32
    2b60:	0007079b          	sext.w	a5,a4
    2b64:	70dd96e3          	bne	s11,a3,3a70 <_vsnprintf+0x2420>
    2b68:	6a079fe3          	bnez	a5,3a26 <_vsnprintf+0x23d6>
    2b6c:	02000d93          	li	s11,32
    2b70:	7c09b40b          	th.extu	s0,s3,31,0
    2b74:	013de463          	bltu	s11,s3,2b7c <_vsnprintf+0x152c>
    2b78:	7f50006f          	j	3b6c <_vsnprintf+0x251c>
    2b7c:	409d87b3          	sub	a5,s11,s1
    2b80:	8d4a                	mv	s10,s2
    2b82:	fb01548b          	th.sdd	s1,a6,(sp),1,4
    2b86:	893e                	mv	s2,a5
    2b88:	8626                	mv	a2,s1
    2b8a:	86d6                	mv	a3,s5
    2b8c:	85da                	mv	a1,s6
    2b8e:	02000513          	li	a0,32
    2b92:	0485                	addi	s1,s1,1
    2b94:	9a02                	jalr	s4
    2b96:	00990733          	add	a4,s2,s1
    2b9a:	fe8767e3          	bltu	a4,s0,2b88 <_vsnprintf+0x1538>
    2b9e:	fb01448b          	th.ldd	s1,a6,(sp),1,4
    2ba2:	fff40793          	addi	a5,s0,-1
    2ba6:	001d8693          	addi	a3,s11,1
    2baa:	00d43733          	sltu	a4,s0,a3
    2bae:	41b787b3          	sub	a5,a5,s11
    2bb2:	42e0178b          	th.mvnez	a5,zero,a4
    2bb6:	00148713          	addi	a4,s1,1
    2bba:	896a                	mv	s2,s10
    2bbc:	97ba                	add	a5,a5,a4
    2bbe:	5a0d8ae3          	beqz	s11,3972 <_vsnprintf+0x2322>
    2bc2:	002d8733          	add	a4,s11,sp
    2bc6:	01f74503          	lbu	a0,31(a4)
    2bca:	8d6e                	mv	s10,s11
    2bcc:	9dbe                	add	s11,s11,a5
    2bce:	e826                	sd	s1,16(sp)
    2bd0:	84ee                	mv	s1,s11
    2bd2:	8dca                	mv	s11,s2
    2bd4:	8942                	mv	s2,a6
    2bd6:	a029                	j	2be0 <_vsnprintf+0x1590>
    2bd8:	002d0733          	add	a4,s10,sp
    2bdc:	01f74503          	lbu	a0,31(a4)
    2be0:	41a48633          	sub	a2,s1,s10
    2be4:	86d6                	mv	a3,s5
    2be6:	1d7d                	addi	s10,s10,-1
    2be8:	85da                	mv	a1,s6
    2bea:	8426                	mv	s0,s1
    2bec:	9a02                	jalr	s4
    2bee:	fe0d15e3          	bnez	s10,2bd8 <_vsnprintf+0x1588>
    2bf2:	64c2                	ld	s1,16(sp)
    2bf4:	884a                	mv	a6,s2
    2bf6:	896e                	mv	s2,s11
    2bf8:	02080263          	beqz	a6,2c1c <_vsnprintf+0x15cc>
    2bfc:	409404b3          	sub	s1,s0,s1
    2c00:	7c09b98b          	th.extu	s3,s3,31,0
    2c04:	0134fc63          	bgeu	s1,s3,2c1c <_vsnprintf+0x15cc>
    2c08:	8622                	mv	a2,s0
    2c0a:	86d6                	mv	a3,s5
    2c0c:	85da                	mv	a1,s6
    2c0e:	02000513          	li	a0,32
    2c12:	0485                	addi	s1,s1,1
    2c14:	0405                	addi	s0,s0,1
    2c16:	9a02                	jalr	s4
    2c18:	ff34e8e3          	bltu	s1,s3,2c08 <_vsnprintf+0x15b8>
    2c1c:	6da2                	ld	s11,8(sp)
    2c1e:	84a2                	mv	s1,s0
    2c20:	a8bfe06f          	j	16aa <_vsnprintf+0x5a>
    2c24:	01067e13          	andi	t3,a2,16
    2c28:	8f32                	mv	t5,a2
    2c2a:	a18ff06f          	j	1e42 <_vsnprintf+0x7f2>
    2c2e:	6da2                	ld	s11,8(sp)
    2c30:	84c2                	mv	s1,a6
    2c32:	a79fe06f          	j	16aa <_vsnprintf+0x5a>
    2c36:	03f14503          	lbu	a0,63(sp)
    2c3a:	02000793          	li	a5,32
    2c3e:	b0ad                	j	24a8 <_vsnprintf+0xe58>
    2c40:	02000793          	li	a5,32
    2c44:	fef689e3          	beq	a3,a5,2c36 <_vsnprintf+0x15e6>
    2c48:	8636                	mv	a2,a3
    2c4a:	b0b9                	j	2498 <_vsnprintf+0xe48>
    2c4c:	010e7593          	andi	a1,t3,16
    2c50:	b4b5                	j	26bc <_vsnprintf+0x106c>
    2c52:	7c07370b          	th.extu	a4,a4,31,0
    2c56:	02edf263          	bgeu	s11,a4,2c7a <_vsnprintf+0x162a>
    2c5a:	02000593          	li	a1,32
    2c5e:	00b10633          	add	a2,sp,a1
    2c62:	03000693          	li	a3,48
    2c66:	0001                	nop
    2c68:	00bd8963          	beq	s11,a1,2c7a <_vsnprintf+0x162a>
    2c6c:	0d85                	addi	s11,s11,1
    2c6e:	01b607b3          	add	a5,a2,s11
    2c72:	fed78fa3          	sb	a3,-1(a5)
    2c76:	ffb719e3          	bne	a4,s11,2c68 <_vsnprintf+0x1618>
    2c7a:	001f7793          	andi	a5,t5,1
    2c7e:	54078063          	beqz	a5,31be <_vsnprintf+0x1b6e>
    2c82:	7c09b68b          	th.extu	a3,s3,31,0
    2c86:	00dde463          	bltu	s11,a3,2c8e <_vsnprintf+0x163e>
    2c8a:	2160106f          	j	3ea0 <_vsnprintf+0x2850>
    2c8e:	02000513          	li	a0,32
    2c92:	00a105b3          	add	a1,sp,a0
    2c96:	03000613          	li	a2,48
    2c9a:	0001                	nop
    2c9c:	00000013          	nop
    2ca0:	00ad8963          	beq	s11,a0,2cb2 <_vsnprintf+0x1662>
    2ca4:	0d85                	addi	s11,s11,1
    2ca6:	01b587b3          	add	a5,a1,s11
    2caa:	fec78fa3          	sb	a2,-1(a5)
    2cae:	fedd99e3          	bne	s11,a3,2ca0 <_vsnprintf+0x1650>
    2cb2:	640e1763          	bnez	t3,3300 <_vsnprintf+0x1cb0>
    2cb6:	002d87b3          	add	a5,s11,sp
    2cba:	01f7c503          	lbu	a0,31(a5)
    2cbe:	4e01                	li	t3,0
    2cc0:	87a6                	mv	a5,s1
    2cc2:	aa8ff06f          	j	1f6a <_vsnprintf+0x91a>
    2cc6:	406987bb          	subw	a5,s3,t1
    2cca:	f0eff06f          	j	23d8 <_vsnprintf+0xd88>
    2cce:	6c068f63          	beqz	a3,33ac <_vsnprintf+0x1d5c>
    2cd2:	0027f693          	andi	a3,a5,2
    2cd6:	0a069fe3          	bnez	a3,3594 <_vsnprintf+0x1f44>
    2cda:	7c07370b          	th.extu	a4,a4,31,0
    2cde:	460987e3          	beqz	s3,394c <_vsnprintf+0x22fc>
    2ce2:	8b85                	andi	a5,a5,1
    2ce4:	080784e3          	beqz	a5,356c <_vsnprintf+0x1f1c>
    2ce8:	4781                	li	a5,0
    2cea:	fff9861b          	addiw	a2,s3,-1
    2cee:	00c8f693          	andi	a3,a7,12
    2cf2:	42d6198b          	th.mvnez	s3,a2,a3
    2cf6:	4605                	li	a2,1
    2cf8:	00e7e463          	bltu	a5,a4,2d00 <_vsnprintf+0x16b0>
    2cfc:	0680106f          	j	3d64 <_vsnprintf+0x2714>
    2d00:	02000593          	li	a1,32
    2d04:	00b10e33          	add	t3,sp,a1
    2d08:	03000513          	li	a0,48
    2d0c:	68b78863          	beq	a5,a1,339c <_vsnprintf+0x1d4c>
    2d10:	0785                	addi	a5,a5,1
    2d12:	00fe06b3          	add	a3,t3,a5
    2d16:	fea68fa3          	sb	a0,-1(a3)
    2d1a:	fee7e9e3          	bltu	a5,a4,2d0c <_vsnprintf+0x16bc>
    2d1e:	c615                	beqz	a2,2d4a <_vsnprintf+0x16fa>
    2d20:	7c09b70b          	th.extu	a4,s3,31,0
    2d24:	00e7e463          	bltu	a5,a4,2d2c <_vsnprintf+0x16dc>
    2d28:	0580106f          	j	3d80 <_vsnprintf+0x2730>
    2d2c:	02000513          	li	a0,32
    2d30:	00a105b3          	add	a1,sp,a0
    2d34:	03000613          	li	a2,48
    2d38:	0aa78763          	beq	a5,a0,2de6 <_vsnprintf+0x1796>
    2d3c:	0785                	addi	a5,a5,1
    2d3e:	00f586b3          	add	a3,a1,a5
    2d42:	fec68fa3          	sb	a2,-1(a3)
    2d46:	fee799e3          	bne	a5,a4,2d38 <_vsnprintf+0x16e8>
    2d4a:	0038f693          	andi	a3,a7,3
    2d4e:	02000713          	li	a4,32
    2d52:	8636                	mv	a2,a3
    2d54:	08e78b63          	beq	a5,a4,2dea <_vsnprintf+0x179a>
    2d58:	7c034563          	bltz	t1,3522 <_vsnprintf+0x1ed2>
    2d5c:	0048f613          	andi	a2,a7,4
    2d60:	0006871b          	sext.w	a4,a3
    2d64:	e219                	bnez	a2,2d6a <_vsnprintf+0x171a>
    2d66:	0d80106f          	j	3e3e <_vsnprintf+0x27ee>
    2d6a:	1010                	addi	a2,sp,32
    2d6c:	02078693          	addi	a3,a5,32
    2d70:	96b2                	add	a3,a3,a2
    2d72:	02b00613          	li	a2,43
    2d76:	fec68023          	sb	a2,-32(a3)
    2d7a:	00178d13          	addi	s10,a5,1
    2d7e:	c319                	beqz	a4,2d84 <_vsnprintf+0x1734>
    2d80:	0540106f          	j	3dd4 <_vsnprintf+0x2784>
    2d84:	7c09b68b          	th.extu	a3,s3,31,0
    2d88:	02dd70e3          	bgeu	s10,a3,35a8 <_vsnprintf+0x1f58>
    2d8c:	409d0433          	sub	s0,s10,s1
    2d90:	87ca                	mv	a5,s2
    2d92:	e426                	sd	s1,8(sp)
    2d94:	8926                	mv	s2,s1
    2d96:	8dbe                	mv	s11,a5
    2d98:	84a2                	mv	s1,s0
    2d9a:	fb01570b          	th.sdd	a4,a6,(sp),1,4
    2d9e:	8436                	mv	s0,a3
    2da0:	864a                	mv	a2,s2
    2da2:	86d6                	mv	a3,s5
    2da4:	85da                	mv	a1,s6
    2da6:	02000513          	li	a0,32
    2daa:	0905                	addi	s2,s2,1
    2dac:	9a02                	jalr	s4
    2dae:	01248733          	add	a4,s1,s2
    2db2:	fe8767e3          	bltu	a4,s0,2da0 <_vsnprintf+0x1750>
    2db6:	64a2                	ld	s1,8(sp)
    2db8:	86a2                	mv	a3,s0
    2dba:	001d0793          	addi	a5,s10,1
    2dbe:	147d                	addi	s0,s0,-1
    2dc0:	00f6b6b3          	sltu	a3,a3,a5
    2dc4:	41a40433          	sub	s0,s0,s10
    2dc8:	fb01470b          	th.ldd	a4,a6,(sp),1,4
    2dcc:	42d0140b          	th.mvnez	s0,zero,a3
    2dd0:	00148793          	addi	a5,s1,1
    2dd4:	896e                	mv	s2,s11
    2dd6:	943e                	add	s0,s0,a5
    2dd8:	b40d02e3          	beqz	s10,291c <_vsnprintf+0x12cc>
    2ddc:	002d07b3          	add	a5,s10,sp
    2de0:	01f7c503          	lbu	a0,31(a5)
    2de4:	b611                	j	28e8 <_vsnprintf+0x1298>
    2de6:	0038f613          	andi	a2,a7,3
    2dea:	ea01                	bnez	a2,2dfa <_vsnprintf+0x17aa>
    2dec:	02000d13          	li	s10,32
    2df0:	7c09b68b          	th.extu	a3,s3,31,0
    2df4:	4701                	li	a4,0
    2df6:	f93d6be3          	bltu	s10,s3,2d8c <_vsnprintf+0x173c>
    2dfa:	03f14503          	lbu	a0,63(sp)
    2dfe:	8426                	mv	s0,s1
    2e00:	4701                	li	a4,0
    2e02:	02000d13          	li	s10,32
    2e06:	b4cd                	j	28e8 <_vsnprintf+0x1298>
    2e08:	700709e3          	beqz	a4,3d1a <_vsnprintf+0x26ca>
    2e0c:	4541                	li	a0,16
    2e0e:	86aa                	mv	a3,a0
    2e10:	4781                	li	a5,0
    2e12:	40000e13          	li	t3,1024
    2e16:	f02ff06f          	j	2518 <_vsnprintf+0xec8>
    2e1a:	41fe579b          	sraiw	a5,t3,0x1f
    2e1e:	00fe4633          	xor	a2,t3,a5
    2e22:	9e1d                	subw	a2,a2,a5
    2e24:	d1aff06f          	j	233e <_vsnprintf+0xcee>
    2e28:	1000                	addi	s0,sp,32
    2e2a:	943e                	add	s0,s0,a5
    2e2c:	00178d13          	addi	s10,a5,1
    2e30:	02000513          	li	a0,32
    2e34:	00a40023          	sb	a0,0(s0)
    2e38:	c24ff06f          	j	225c <_vsnprintf+0xc0c>
    2e3c:	8d32                	mv	s10,a2
    2e3e:	1000                	addi	s0,sp,32
    2e40:	46c1                	li	a3,16
    2e42:	4809                	li	a6,2
    2e44:	caaff06f          	j	22ee <_vsnprintf+0xc9e>
    2e48:	03f14503          	lbu	a0,63(sp)
    2e4c:	8426                	mv	s0,s1
    2e4e:	4589                	li	a1,2
    2e50:	02000713          	li	a4,32
    2e54:	d14ff06f          	j	2368 <_vsnprintf+0xd18>
    2e58:	0028f693          	andi	a3,a7,2
    2e5c:	8646                	mv	a2,a7
    2e5e:	f6ed                	bnez	a3,2e48 <_vsnprintf+0x17f8>
    2e60:	7c07370b          	th.extu	a4,a4,31,0
    2e64:	16099263          	bnez	s3,2fc8 <_vsnprintf+0x1978>
    2e68:	00367993          	andi	s3,a2,3
    2e6c:	14e7f463          	bgeu	a5,a4,2fb4 <_vsnprintf+0x1964>
    2e70:	0018f513          	andi	a0,a7,1
    2e74:	4981                	li	s3,0
    2e76:	02000613          	li	a2,32
    2e7a:	00c10eb3          	add	t4,sp,a2
    2e7e:	03000313          	li	t1,48
    2e82:	0001                	nop
    2e84:	00000013          	nop
    2e88:	12c78a63          	beq	a5,a2,2fbc <_vsnprintf+0x196c>
    2e8c:	0785                	addi	a5,a5,1
    2e8e:	00fe86b3          	add	a3,t4,a5
    2e92:	fe668fa3          	sb	t1,-1(a3)
    2e96:	fee7e9e3          	bltu	a5,a4,2e88 <_vsnprintf+0x1838>
    2e9a:	66050263          	beqz	a0,34fe <_vsnprintf+0x1eae>
    2e9e:	7c09b70b          	th.extu	a4,s3,31,0
    2ea2:	48e7f7e3          	bgeu	a5,a4,3b30 <_vsnprintf+0x24e0>
    2ea6:	02000613          	li	a2,32
    2eaa:	00c10333          	add	t1,sp,a2
    2eae:	03000513          	li	a0,48
    2eb2:	0001                	nop
    2eb4:	00000013          	nop
    2eb8:	08c78c63          	beq	a5,a2,2f50 <_vsnprintf+0x1900>
    2ebc:	0785                	addi	a5,a5,1
    2ebe:	00f306b3          	add	a3,t1,a5
    2ec2:	fea68fa3          	sb	a0,-1(a3)
    2ec6:	fee799e3          	bne	a5,a4,2eb8 <_vsnprintf+0x1868>
    2eca:	0038f693          	andi	a3,a7,3
    2ece:	02000793          	li	a5,32
    2ed2:	8536                	mv	a0,a3
    2ed4:	08f70063          	beq	a4,a5,2f54 <_vsnprintf+0x1904>
    2ed8:	3e0e5d63          	bgez	t3,32d2 <_vsnprintf+0x1c82>
    2edc:	002707b3          	add	a5,a4,sp
    2ee0:	02d00693          	li	a3,45
    2ee4:	02d78023          	sb	a3,32(a5)
    2ee8:	0705                	addi	a4,a4,1
    2eea:	fa051b63          	bnez	a0,26a0 <_vsnprintf+0x1050>
    2eee:	7c09bd8b          	th.extu	s11,s3,31,0
    2ef2:	fbb77763          	bgeu	a4,s11,26a0 <_vsnprintf+0x1050>
    2ef6:	8d4a                	mv	s10,s2
    2ef8:	40970433          	sub	s0,a4,s1
    2efc:	e43a                	sd	a4,8(sp)
    2efe:	fb01548b          	th.sdd	s1,a6,(sp),1,4
    2f02:	892e                	mv	s2,a1
    2f04:	00000013          	nop
    2f08:	8626                	mv	a2,s1
    2f0a:	86d6                	mv	a3,s5
    2f0c:	85da                	mv	a1,s6
    2f0e:	02000513          	li	a0,32
    2f12:	0485                	addi	s1,s1,1
    2f14:	9a02                	jalr	s4
    2f16:	00940733          	add	a4,s0,s1
    2f1a:	ffb767e3          	bltu	a4,s11,2f08 <_vsnprintf+0x18b8>
    2f1e:	6722                	ld	a4,8(sp)
    2f20:	fb01448b          	th.ldd	s1,a6,(sp),1,4
    2f24:	fffd8413          	addi	s0,s11,-1
    2f28:	00170793          	addi	a5,a4,1
    2f2c:	00fdbdb3          	sltu	s11,s11,a5
    2f30:	8c19                	sub	s0,s0,a4
    2f32:	43b0140b          	th.mvnez	s0,zero,s11
    2f36:	00148793          	addi	a5,s1,1
    2f3a:	85ca                	mv	a1,s2
    2f3c:	943e                	add	s0,s0,a5
    2f3e:	896a                	mv	s2,s10
    2f40:	c4070e63          	beqz	a4,239c <_vsnprintf+0xd4c>
    2f44:	002707b3          	add	a5,a4,sp
    2f48:	01f7c503          	lbu	a0,31(a5)
    2f4c:	c1cff06f          	j	2368 <_vsnprintf+0xd18>
    2f50:	0038f513          	andi	a0,a7,3
    2f54:	e519                	bnez	a0,2f62 <_vsnprintf+0x1912>
    2f56:	02000713          	li	a4,32
    2f5a:	7c09bd8b          	th.extu	s11,s3,31,0
    2f5e:	f9376ce3          	bltu	a4,s3,2ef6 <_vsnprintf+0x18a6>
    2f62:	03f14503          	lbu	a0,63(sp)
    2f66:	8426                	mv	s0,s1
    2f68:	02000713          	li	a4,32
    2f6c:	bfcff06f          	j	2368 <_vsnprintf+0xd18>
    2f70:	4541                	li	a0,16
    2f72:	86aa                	mv	a3,a0
    2f74:	daeee263          	bltu	t4,a4,2518 <_vsnprintf+0xec8>
    2f78:	4d7d                	li	s10,31
    2f7a:	ac080963          	beqz	a6,224c <_vsnprintf+0xbfc>
    2f7e:	520e1d63          	bnez	t3,34b8 <_vsnprintf+0x1e68>
    2f82:	7c07370b          	th.extu	a4,a4,31,0
    2f86:	9af71f63          	bne	a4,a5,2144 <_vsnprintf+0xaf4>
    2f8a:	05800613          	li	a2,88
    2f8e:	00278733          	add	a4,a5,sp
    2f92:	8872                	mv	a6,t3
    2f94:	00c70f23          	sb	a2,30(a4)
    2f98:	9d8ff06f          	j	2170 <_vsnprintf+0xb20>
    2f9c:	7c07370b          	th.extu	a4,a4,31,0
    2fa0:	02099463          	bnez	s3,2fc8 <_vsnprintf+0x1978>
    2fa4:	ece7e6e3          	bltu	a5,a4,2e70 <_vsnprintf+0x1820>
    2fa8:	02000713          	li	a4,32
    2fac:	00367993          	andi	s3,a2,3
    2fb0:	4ee796e3          	bne	a5,a4,3c9c <_vsnprintf+0x264c>
    2fb4:	fa0987e3          	beqz	s3,2f62 <_vsnprintf+0x1912>
    2fb8:	4981                	li	s3,0
    2fba:	b765                	j	2f62 <_vsnprintf+0x1912>
    2fbc:	d951                	beqz	a0,2f50 <_vsnprintf+0x1900>
    2fbe:	7c09b70b          	th.extu	a4,s3,31,0
    2fc2:	eee7e2e3          	bltu	a5,a4,2ea6 <_vsnprintf+0x1856>
    2fc6:	bf71                	j	2f62 <_vsnprintf+0x1912>
    2fc8:	0018f513          	andi	a0,a7,1
    2fcc:	3a050463          	beqz	a0,3374 <_vsnprintf+0x1d24>
    2fd0:	2c0e5d63          	bgez	t3,32aa <_vsnprintf+0x1c5a>
    2fd4:	39fd                	addiw	s3,s3,-1
    2fd6:	eae7e0e3          	bltu	a5,a4,2e76 <_vsnprintf+0x1826>
    2fda:	7c09b70b          	th.extu	a4,s3,31,0
    2fde:	ece7e4e3          	bltu	a5,a4,2ea6 <_vsnprintf+0x1856>
    2fe2:	02000713          	li	a4,32
    2fe6:	f6e78ee3          	beq	a5,a4,2f62 <_vsnprintf+0x1912>
    2fea:	873e                	mv	a4,a5
    2fec:	bdc5                	j	2edc <_vsnprintf+0x188c>
    2fee:	0001                	nop
    2ff0:	010e7293          	andi	t0,t3,16
    2ff4:	bce9                	j	2ace <_vsnprintf+0x147e>
    2ff6:	002f7693          	andi	a3,t5,2
    2ffa:	87fa                	mv	a5,t5
    2ffc:	c4068be3          	beqz	a3,2c52 <_vsnprintf+0x1602>
    3000:	4a0e0f63          	beqz	t3,34be <_vsnprintf+0x1e6e>
    3004:	14081ce3          	bnez	a6,395c <_vsnprintf+0x230c>
    3008:	67f70fe3          	beq	a4,t6,3e86 <_vsnprintf+0x2836>
    300c:	7df98863          	beq	s3,t6,37dc <_vsnprintf+0x218c>
    3010:	46c1                	li	a3,16
    3012:	0037f713          	andi	a4,a5,3
    3016:	4e09                	li	t3,2
    3018:	72d88963          	beq	a7,a3,374a <_vsnprintf+0x20fa>
    301c:	79c88463          	beq	a7,t3,37a4 <_vsnprintf+0x2154>
    3020:	003f7793          	andi	a5,t5,3
    3024:	ecbfe06f          	j	1eee <_vsnprintf+0x89e>
    3028:	7c07370b          	th.extu	a4,a4,31,0
    302c:	02edf163          	bgeu	s11,a4,304e <_vsnprintf+0x19fe>
    3030:	02000313          	li	t1,32
    3034:	00610533          	add	a0,sp,t1
    3038:	03000693          	li	a3,48
    303c:	006d8963          	beq	s11,t1,304e <_vsnprintf+0x19fe>
    3040:	0d85                	addi	s11,s11,1
    3042:	01b507b3          	add	a5,a0,s11
    3046:	fed78fa3          	sb	a3,-1(a5)
    304a:	feed99e3          	bne	s11,a4,303c <_vsnprintf+0x19ec>
    304e:	00167793          	andi	a5,a2,1
    3052:	44078063          	beqz	a5,3492 <_vsnprintf+0x1e42>
    3056:	7c09b68b          	th.extu	a3,s3,31,0
    305a:	68ddfbe3          	bgeu	s11,a3,3ef0 <_vsnprintf+0x28a0>
    305e:	02000e13          	li	t3,32
    3062:	01c10333          	add	t1,sp,t3
    3066:	03000513          	li	a0,48
    306a:	01cd8963          	beq	s11,t3,307c <_vsnprintf+0x1a2c>
    306e:	0d85                	addi	s11,s11,1
    3070:	01b307b3          	add	a5,t1,s11
    3074:	fea78fa3          	sb	a0,-1(a5)
    3078:	ffb699e3          	bne	a3,s11,306a <_vsnprintf+0x1a1a>
    307c:	44059963          	bnez	a1,34ce <_vsnprintf+0x1e7e>
    3080:	002d87b3          	add	a5,s11,sp
    3084:	01f7c503          	lbu	a0,31(a5)
    3088:	4581                	li	a1,0
    308a:	87a6                	mv	a5,s1
    308c:	f46ff06f          	j	27d2 <_vsnprintf+0x1182>
    3090:	000da583          	lw	a1,0(s11)
    3094:	d97fe06f          	j	1e2a <_vsnprintf+0x7da>
    3098:	0028f693          	andi	a3,a7,2
    309c:	8646                	mv	a2,a7
    309e:	e6c9                	bnez	a3,3128 <_vsnprintf+0x1ad8>
    30a0:	7c07370b          	th.extu	a4,a4,31,0
    30a4:	12099e63          	bnez	s3,31e0 <_vsnprintf+0x1b90>
    30a8:	00367993          	andi	s3,a2,3
    30ac:	8ee7efe3          	bltu	a5,a4,29aa <_vsnprintf+0x135a>
    30b0:	9e098de3          	beqz	s3,2aaa <_vsnprintf+0x145a>
    30b4:	4981                	li	s3,0
    30b6:	bad5                	j	2aaa <_vsnprintf+0x145a>
    30b8:	00267e13          	andi	t3,a2,2
    30bc:	380e0c63          	beqz	t3,3454 <_vsnprintf+0x1e04>
    30c0:	87a6                	mv	a5,s1
    30c2:	edffe06f          	j	1fa0 <_vsnprintf+0x950>
    30c6:	9c0608e3          	beqz	a2,2a96 <_vsnprintf+0x1446>
    30ca:	7c09b70b          	th.extu	a4,s3,31,0
    30ce:	90e7eae3          	bltu	a5,a4,29e2 <_vsnprintf+0x1392>
    30d2:	bae1                	j	2aaa <_vsnprintf+0x145a>
    30d4:	02b00513          	li	a0,43
    30d8:	00c4550b          	th.srb	a0,s0,a2,0
    30dc:	bccff06f          	j	24a8 <_vsnprintf+0xe58>
    30e0:	46a9                	li	a3,10
    30e2:	8446                	mv	s0,a7
    30e4:	88b6                	mv	a7,a3
    30e6:	d01fe06f          	j	1de6 <_vsnprintf+0x796>
    30ea:	7c07370b          	th.extu	a4,a4,31,0
    30ee:	0e099963          	bnez	s3,31e0 <_vsnprintf+0x1b90>
    30f2:	8ae7ece3          	bltu	a5,a4,29aa <_vsnprintf+0x135a>
    30f6:	02000713          	li	a4,32
    30fa:	0036f993          	andi	s3,a3,3
    30fe:	fae789e3          	beq	a5,a4,30b0 <_vsnprintf+0x1a60>
    3102:	873e                	mv	a4,a5
    3104:	1e0ed7e3          	bgez	t4,3af2 <_vsnprintf+0x24a2>
    3108:	1014                	addi	a3,sp,32
    310a:	02078713          	addi	a4,a5,32
    310e:	9736                	add	a4,a4,a3
    3110:	02d00513          	li	a0,45
    3114:	fea70023          	sb	a0,-32(a4)
    3118:	4681                	li	a3,0
    311a:	00178713          	addi	a4,a5,1
    311e:	000989e3          	beqz	s3,3930 <_vsnprintf+0x22e0>
    3122:	4981                	li	s3,0
    3124:	f7ffe06f          	j	20a2 <_vsnprintf+0xa52>
    3128:	03f14503          	lbu	a0,63(sp)
    312c:	87a6                	mv	a5,s1
    312e:	4689                	li	a3,2
    3130:	02000713          	li	a4,32
    3134:	f75fe06f          	j	20a8 <_vsnprintf+0xa58>
    3138:	7c07370b          	th.extu	a4,a4,31,0
    313c:	02edf163          	bgeu	s11,a4,315e <_vsnprintf+0x1b0e>
    3140:	02000513          	li	a0,32
    3144:	00a105b3          	add	a1,sp,a0
    3148:	03000693          	li	a3,48
    314c:	00ad8963          	beq	s11,a0,315e <_vsnprintf+0x1b0e>
    3150:	0d85                	addi	s11,s11,1
    3152:	01b587b3          	add	a5,a1,s11
    3156:	fed78fa3          	sb	a3,-1(a5)
    315a:	ffb719e3          	bne	a4,s11,314c <_vsnprintf+0x1afc>
    315e:	00167793          	andi	a5,a2,1
    3162:	54078f63          	beqz	a5,36c0 <_vsnprintf+0x2070>
    3166:	7c09b68b          	th.extu	a3,s3,31,0
    316a:	3addf0e3          	bgeu	s11,a3,3d0a <_vsnprintf+0x26ba>
    316e:	02000313          	li	t1,32
    3172:	00610533          	add	a0,sp,t1
    3176:	03000593          	li	a1,48
    317a:	006d8963          	beq	s11,t1,318c <_vsnprintf+0x1b3c>
    317e:	0d85                	addi	s11,s11,1
    3180:	01b507b3          	add	a5,a0,s11
    3184:	feb78fa3          	sb	a1,-1(a5)
    3188:	ffb699e3          	bne	a3,s11,317a <_vsnprintf+0x1b2a>
    318c:	56029063          	bnez	t0,36ec <_vsnprintf+0x209c>
    3190:	002d87b3          	add	a5,s11,sp
    3194:	01f7c503          	lbu	a0,31(a5)
    3198:	4801                	li	a6,0
    319a:	87a6                	mv	a5,s1
    319c:	b43d                	j	2bca <_vsnprintf+0x157a>
    319e:	0028f693          	andi	a3,a7,2
    31a2:	8646                	mv	a2,a7
    31a4:	e6e5                	bnez	a3,328c <_vsnprintf+0x1c3c>
    31a6:	7c07370b          	th.extu	a4,a4,31,0
    31aa:	34099c63          	bnez	s3,3502 <_vsnprintf+0x1eb2>
    31ae:	00367993          	andi	s3,a2,3
    31b2:	1ae7f463          	bgeu	a5,a4,335a <_vsnprintf+0x1d0a>
    31b6:	0018f613          	andi	a2,a7,1
    31ba:	4981                	li	s3,0
    31bc:	b691                	j	2d00 <_vsnprintf+0x16b0>
    31be:	000e0963          	beqz	t3,31d0 <_vsnprintf+0x1b80>
    31c2:	00081463          	bnez	a6,31ca <_vsnprintf+0x1b7a>
    31c6:	cf9fe06f          	j	1ebe <_vsnprintf+0x86e>
    31ca:	4801                	li	a6,0
    31cc:	d07fe06f          	j	1ed2 <_vsnprintf+0x882>
    31d0:	7c09b40b          	th.extu	s0,s3,31,0
    31d4:	008df463          	bgeu	s11,s0,31dc <_vsnprintf+0x1b8c>
    31d8:	d3bfe06f          	j	1f12 <_vsnprintf+0x8c2>
    31dc:	bce9                	j	2cb6 <_vsnprintf+0x1666>
    31de:	0001                	nop
    31e0:	0018f613          	andi	a2,a7,1
    31e4:	86c6                	mv	a3,a7
    31e6:	24060363          	beqz	a2,342c <_vsnprintf+0x1ddc>
    31ea:	520ed963          	bgez	t4,371c <_vsnprintf+0x20cc>
    31ee:	39fd                	addiw	s3,s3,-1
    31f0:	fce7e063          	bltu	a5,a4,29b0 <_vsnprintf+0x1360>
    31f4:	7c09b70b          	th.extu	a4,s3,31,0
    31f8:	fee7e563          	bltu	a5,a4,29e2 <_vsnprintf+0x1392>
    31fc:	02000713          	li	a4,32
    3200:	8ae785e3          	beq	a5,a4,2aaa <_vsnprintf+0x145a>
    3204:	873e                	mv	a4,a5
    3206:	002707b3          	add	a5,a4,sp
    320a:	02d00693          	li	a3,45
    320e:	02d78023          	sb	a3,32(a5)
    3212:	0705                	addi	a4,a4,1
    3214:	4681                	li	a3,0
    3216:	c219                	beqz	a2,321c <_vsnprintf+0x1bcc>
    3218:	e8bfe06f          	j	20a2 <_vsnprintf+0xa52>
    321c:	7c09b40b          	th.extu	s0,s3,31,0
    3220:	4681                	li	a3,0
    3222:	80876ce3          	bltu	a4,s0,2a3a <_vsnprintf+0x13ea>
    3226:	e7dfe06f          	j	20a2 <_vsnprintf+0xa52>
    322a:	0001                	nop
    322c:	002e7593          	andi	a1,t3,2
    3230:	8426                	mv	s0,s1
    3232:	dc059863          	bnez	a1,2802 <_vsnprintf+0x11b2>
    3236:	7c07370b          	th.extu	a4,a4,31,0
    323a:	4d81                	li	s11,0
    323c:	40000813          	li	a6,1024
    3240:	de0718e3          	bnez	a4,3030 <_vsnprintf+0x19e0>
    3244:	001e7e13          	andi	t3,t3,1
    3248:	140e0ce3          	beqz	t3,3ba0 <_vsnprintf+0x2550>
    324c:	7c09b68b          	th.extu	a3,s3,31,0
    3250:	e00697e3          	bnez	a3,305e <_vsnprintf+0x1a0e>
    3254:	6da2                	ld	s11,8(sp)
    3256:	c54fe06f          	j	16aa <_vsnprintf+0x5a>
    325a:	0001                	nop
    325c:	00267693          	andi	a3,a2,2
    3260:	87b2                	mv	a5,a2
    3262:	dc0683e3          	beqz	a3,3028 <_vsnprintf+0x19d8>
    3266:	46058b63          	beqz	a1,36dc <_vsnprintf+0x208c>
    326a:	60081a63          	bnez	a6,387e <_vsnprintf+0x222e>
    326e:	27f708e3          	beq	a4,t6,3cde <_vsnprintf+0x268e>
    3272:	15f98ce3          	beq	s3,t6,3bca <_vsnprintf+0x257a>
    3276:	4741                	li	a4,16
    3278:	8b8d                	andi	a5,a5,3
    327a:	4589                	li	a1,2
    327c:	3ae88a63          	beq	a7,a4,3630 <_vsnprintf+0x1fe0>
    3280:	64b88063          	beq	a7,a1,38c0 <_vsnprintf+0x2270>
    3284:	00367713          	andi	a4,a2,3
    3288:	cd4ff06f          	j	275c <_vsnprintf+0x110c>
    328c:	03f14503          	lbu	a0,63(sp)
    3290:	8426                	mv	s0,s1
    3292:	4709                	li	a4,2
    3294:	02000d13          	li	s10,32
    3298:	e50ff06f          	j	28e8 <_vsnprintf+0x1298>
    329c:	7c07370b          	th.extu	a4,a4,31,0
    32a0:	32098463          	beqz	s3,35c8 <_vsnprintf+0x1f78>
    32a4:	8b85                	andi	a5,a5,1
    32a6:	c7f9                	beqz	a5,3374 <_vsnprintf+0x1d24>
    32a8:	4781                	li	a5,0
    32aa:	00c8f693          	andi	a3,a7,12
    32ae:	fff9861b          	addiw	a2,s3,-1
    32b2:	42d6198b          	th.mvnez	s3,a2,a3
    32b6:	4505                	li	a0,1
    32b8:	bae7efe3          	bltu	a5,a4,2e76 <_vsnprintf+0x1826>
    32bc:	7c09b70b          	th.extu	a4,s3,31,0
    32c0:	bee7e3e3          	bltu	a5,a4,2ea6 <_vsnprintf+0x1856>
    32c4:	02000713          	li	a4,32
    32c8:	c8e78de3          	beq	a5,a4,2f62 <_vsnprintf+0x1912>
    32cc:	873e                	mv	a4,a5
    32ce:	0038f693          	andi	a3,a7,3
    32d2:	0048f793          	andi	a5,a7,4
    32d6:	0006831b          	sext.w	t1,a3
    32da:	30078763          	beqz	a5,35e8 <_vsnprintf+0x1f98>
    32de:	002707b3          	add	a5,a4,sp
    32e2:	02b00513          	li	a0,43
    32e6:	02a78023          	sb	a0,32(a5)
    32ea:	0705                	addi	a4,a4,1
    32ec:	00031763          	bnez	t1,32fa <_vsnprintf+0x1caa>
    32f0:	7c09bd8b          	th.extu	s11,s3,31,0
    32f4:	4581                	li	a1,0
    32f6:	c1b760e3          	bltu	a4,s11,2ef6 <_vsnprintf+0x18a6>
    32fa:	8426                	mv	s0,s1
    32fc:	86cff06f          	j	2368 <_vsnprintf+0xd18>
    3300:	00081463          	bnez	a6,3308 <_vsnprintf+0x1cb8>
    3304:	bbbfe06f          	j	1ebe <_vsnprintf+0x86e>
    3308:	47c1                	li	a5,16
    330a:	5af88363          	beq	a7,a5,38b0 <_vsnprintf+0x2260>
    330e:	4709                	li	a4,2
    3310:	003f7793          	andi	a5,t5,3
    3314:	4e01                	li	t3,0
    3316:	00e88463          	beq	a7,a4,331e <_vsnprintf+0x1cce>
    331a:	bd5fe06f          	j	1eee <_vsnprintf+0x89e>
    331e:	02000713          	li	a4,32
    3322:	4881                	li	a7,0
    3324:	38ed9463          	bne	s11,a4,36ac <_vsnprintf+0x205c>
    3328:	03f14503          	lbu	a0,63(sp)
    332c:	8e46                	mv	t3,a7
    332e:	87a6                	mv	a5,s1
    3330:	02000d93          	li	s11,32
    3334:	c37fe06f          	j	1f6a <_vsnprintf+0x91a>
    3338:	1000                	addi	s0,sp,32
    333a:	4d05                	li	s10,1
    333c:	46c1                	li	a3,16
    333e:	4809                	li	a6,2
    3340:	bcc5                	j	2e30 <_vsnprintf+0x17e0>
    3342:	7c07370b          	th.extu	a4,a4,31,0
    3346:	1a099e63          	bnez	s3,3502 <_vsnprintf+0x1eb2>
    334a:	e6e7e6e3          	bltu	a5,a4,31b6 <_vsnprintf+0x1b66>
    334e:	02000713          	li	a4,32
    3352:	0036f993          	andi	s3,a3,3
    3356:	0ee794e3          	bne	a5,a4,3c3e <_vsnprintf+0x25ee>
    335a:	aa0980e3          	beqz	s3,2dfa <_vsnprintf+0x17aa>
    335e:	4981                	li	s3,0
    3360:	bc69                	j	2dfa <_vsnprintf+0x17aa>
    3362:	0001                	nop
    3364:	00247793          	andi	a5,s0,2
    3368:	ce078163          	beqz	a5,284a <_vsnprintf+0x11fa>
    336c:	8426                	mv	s0,s1
    336e:	4781                	li	a5,0
    3370:	c5dfe06f          	j	1fcc <_vsnprintf+0x97c>
    3374:	4501                	li	a0,0
    3376:	b0e7e0e3          	bltu	a5,a4,2e76 <_vsnprintf+0x1826>
    337a:	02000713          	li	a4,32
    337e:	bce78ce3          	beq	a5,a4,2f56 <_vsnprintf+0x1906>
    3382:	f40e55e3          	bgez	t3,32cc <_vsnprintf+0x1c7c>
    3386:	973e                	add	a4,a4,a5
    3388:	1014                	addi	a3,sp,32
    338a:	96ba                	add	a3,a3,a4
    338c:	02d00613          	li	a2,45
    3390:	00178713          	addi	a4,a5,1
    3394:	fec68023          	sb	a2,-32(a3)
    3398:	be99                	j	2eee <_vsnprintf+0x189e>
    339a:	0001                	nop
    339c:	a40605e3          	beqz	a2,2de6 <_vsnprintf+0x1796>
    33a0:	7c09b70b          	th.extu	a4,s3,31,0
    33a4:	98e7e4e3          	bltu	a5,a4,2d2c <_vsnprintf+0x16dc>
    33a8:	bc89                	j	2dfa <_vsnprintf+0x17aa>
    33aa:	0001                	nop
    33ac:	4681                	li	a3,0
    33ae:	cdcff06f          	j	288a <_vsnprintf+0x123a>
    33b2:	002e7293          	andi	t0,t3,2
    33b6:	8426                	mv	s0,s1
    33b8:	840292e3          	bnez	t0,2bfc <_vsnprintf+0x15ac>
    33bc:	7c07370b          	th.extu	a4,a4,31,0
    33c0:	4d81                	li	s11,0
    33c2:	40000813          	li	a6,1024
    33c6:	d6071de3          	bnez	a4,3140 <_vsnprintf+0x1af0>
    33ca:	001e7813          	andi	a6,t3,1
    33ce:	1c0809e3          	beqz	a6,3da0 <_vsnprintf+0x2750>
    33d2:	7c09b68b          	th.extu	a3,s3,31,0
    33d6:	40000813          	li	a6,1024
    33da:	d8069ae3          	bnez	a3,316e <_vsnprintf+0x1b1e>
    33de:	8426                	mv	s0,s1
    33e0:	b835                	j	2c1c <_vsnprintf+0x15cc>
    33e2:	0037f713          	andi	a4,a5,3
    33e6:	4e09                	li	t3,2
    33e8:	e319                	bnez	a4,33ee <_vsnprintf+0x1d9e>
    33ea:	b19fe06f          	j	1f02 <_vsnprintf+0x8b2>
    33ee:	03f14503          	lbu	a0,63(sp)
    33f2:	87a6                	mv	a5,s1
    33f4:	02000d93          	li	s11,32
    33f8:	b73fe06f          	j	1f6a <_vsnprintf+0x91a>
    33fc:	00267693          	andi	a3,a2,2
    3400:	87b2                	mv	a5,a2
    3402:	d2068be3          	beqz	a3,3138 <_vsnprintf+0x1ae8>
    3406:	20028763          	beqz	t0,3614 <_vsnprintf+0x1fc4>
    340a:	40081363          	bnez	a6,3810 <_vsnprintf+0x21c0>
    340e:	05e709e3          	beq	a4,t5,3c60 <_vsnprintf+0x2610>
    3412:	69e98763          	beq	s3,t5,3aa0 <_vsnprintf+0x2450>
    3416:	4741                	li	a4,16
    3418:	8b8d                	andi	a5,a5,3
    341a:	4809                	li	a6,2
    341c:	5ae88f63          	beq	a7,a4,39da <_vsnprintf+0x238a>
    3420:	73088b63          	beq	a7,a6,3b56 <_vsnprintf+0x2506>
    3424:	00367713          	andi	a4,a2,3
    3428:	f34ff06f          	j	2b5c <_vsnprintf+0x150c>
    342c:	4601                	li	a2,0
    342e:	d8e7e163          	bltu	a5,a4,29b0 <_vsnprintf+0x1360>
    3432:	02000713          	li	a4,32
    3436:	e6e78363          	beq	a5,a4,2a9c <_vsnprintf+0x144c>
    343a:	300ed063          	bgez	t4,373a <_vsnprintf+0x20ea>
    343e:	973e                	add	a4,a4,a5
    3440:	1014                	addi	a3,sp,32
    3442:	96ba                	add	a3,a3,a4
    3444:	02d00613          	li	a2,45
    3448:	00178713          	addi	a4,a5,1
    344c:	fec68023          	sb	a2,-32(a3)
    3450:	b3f1                	j	321c <_vsnprintf+0x1bcc>
    3452:	0001                	nop
    3454:	7c07370b          	th.extu	a4,a4,31,0
    3458:	4d81                	li	s11,0
    345a:	40000813          	li	a6,1024
    345e:	fe071e63          	bnez	a4,2c5a <_vsnprintf+0x160a>
    3462:	8b85                	andi	a5,a5,1
    3464:	70078963          	beqz	a5,3b76 <_vsnprintf+0x2526>
    3468:	7c09b68b          	th.extu	a3,s3,31,0
    346c:	820691e3          	bnez	a3,2c8e <_vsnprintf+0x163e>
    3470:	6da2                	ld	s11,8(sp)
    3472:	a38fe06f          	j	16aa <_vsnprintf+0x5a>
    3476:	0001                	nop
    3478:	0048f893          	andi	a7,a7,4
    347c:	12088e63          	beqz	a7,35b8 <_vsnprintf+0x1f68>
    3480:	02b00513          	li	a0,43
    3484:	02a10023          	sb	a0,32(sp)
    3488:	87a6                	mv	a5,s1
    348a:	4689                	li	a3,2
    348c:	4705                	li	a4,1
    348e:	c1bfe06f          	j	20a8 <_vsnprintf+0xa58>
    3492:	c591                	beqz	a1,349e <_vsnprintf+0x1e4e>
    3494:	a8080e63          	beqz	a6,2730 <_vsnprintf+0x10e0>
    3498:	4801                	li	a6,0
    349a:	aaaff06f          	j	2744 <_vsnprintf+0x10f4>
    349e:	7c09b40b          	th.extu	s0,s3,31,0
    34a2:	ac8ded63          	bltu	s11,s0,277c <_vsnprintf+0x112c>
    34a6:	bee9                	j	3080 <_vsnprintf+0x1a30>
    34a8:	00081463          	bnez	a6,34b0 <_vsnprintf+0x1e60>
    34ac:	da9fe06f          	j	2254 <_vsnprintf+0xc04>
    34b0:	5a0e1a63          	bnez	t3,3a64 <_vsnprintf+0x2414>
    34b4:	5af70b63          	beq	a4,a5,3a6a <_vsnprintf+0x241a>
    34b8:	4801                	li	a6,0
    34ba:	c91fe06f          	j	214a <_vsnprintf+0xafa>
    34be:	03f14503          	lbu	a0,63(sp)
    34c2:	87a6                	mv	a5,s1
    34c4:	4e09                	li	t3,2
    34c6:	02000d93          	li	s11,32
    34ca:	aa1fe06f          	j	1f6a <_vsnprintf+0x91a>
    34ce:	a6080163          	beqz	a6,2730 <_vsnprintf+0x10e0>
    34d2:	47c1                	li	a5,16
    34d4:	14f88c63          	beq	a7,a5,362c <_vsnprintf+0x1fdc>
    34d8:	4789                	li	a5,2
    34da:	00367713          	andi	a4,a2,3
    34de:	4581                	li	a1,0
    34e0:	a6f89e63          	bne	a7,a5,275c <_vsnprintf+0x110c>
    34e4:	02000793          	li	a5,32
    34e8:	4881                	li	a7,0
    34ea:	18fd9463          	bne	s11,a5,3672 <_vsnprintf+0x2022>
    34ee:	03f14503          	lbu	a0,63(sp)
    34f2:	85c6                	mv	a1,a7
    34f4:	87a6                	mv	a5,s1
    34f6:	02000d93          	li	s11,32
    34fa:	ad8ff06f          	j	27d2 <_vsnprintf+0x1182>
    34fe:	873e                	mv	a4,a5
    3500:	b2e9                	j	2eca <_vsnprintf+0x187a>
    3502:	0018f613          	andi	a2,a7,1
    3506:	c23d                	beqz	a2,356c <_vsnprintf+0x1f1c>
    3508:	fe035163          	bgez	t1,2cea <_vsnprintf+0x169a>
    350c:	39fd                	addiw	s3,s3,-1
    350e:	fee7e963          	bltu	a5,a4,2d00 <_vsnprintf+0x16b0>
    3512:	7c09b70b          	th.extu	a4,s3,31,0
    3516:	80e7ebe3          	bltu	a5,a4,2d2c <_vsnprintf+0x16dc>
    351a:	02000713          	li	a4,32
    351e:	8ce78ee3          	beq	a5,a4,2dfa <_vsnprintf+0x17aa>
    3522:	00278733          	add	a4,a5,sp
    3526:	02d00693          	li	a3,45
    352a:	02d70023          	sb	a3,32(a4)
    352e:	00178d13          	addi	s10,a5,1
    3532:	4701                	li	a4,0
    3534:	ba061763          	bnez	a2,28e2 <_vsnprintf+0x1292>
    3538:	7c09b68b          	th.extu	a3,s3,31,0
    353c:	4701                	li	a4,0
    353e:	84dd67e3          	bltu	s10,a3,2d8c <_vsnprintf+0x173c>
    3542:	ba0ff06f          	j	28e2 <_vsnprintf+0x1292>
    3546:	0001                	nop
    3548:	03f14503          	lbu	a0,63(sp)
    354c:	87a6                	mv	a5,s1
    354e:	02000d93          	li	s11,32
    3552:	a80ff06f          	j	27d2 <_vsnprintf+0x1182>
    3556:	787d                	lui	a6,0xfffff
    3558:	7ff80813          	addi	a6,a6,2047 # fffffffffffff7ff <__kernel_stack+0xfffffffffff117ff>
    355c:	01047833          	and	a6,s0,a6
    3560:	22d69553          	fneg.d	fa0,fa3
    3564:	40086813          	ori	a6,a6,1024
    3568:	f54fe06f          	j	1cbc <_vsnprintf+0x66c>
    356c:	4601                	li	a2,0
    356e:	f8e7e963          	bltu	a5,a4,2d00 <_vsnprintf+0x16b0>
    3572:	02000713          	li	a4,32
    3576:	86e78be3          	beq	a5,a4,2dec <_vsnprintf+0x179c>
    357a:	3c035d63          	bgez	t1,3954 <_vsnprintf+0x2304>
    357e:	1014                	addi	a3,sp,32
    3580:	02078713          	addi	a4,a5,32
    3584:	9736                	add	a4,a4,a3
    3586:	02d00693          	li	a3,45
    358a:	00178d13          	addi	s10,a5,1
    358e:	fed70023          	sb	a3,-32(a4)
    3592:	b75d                	j	3538 <_vsnprintf+0x1ee8>
    3594:	0047f713          	andi	a4,a5,4
    3598:	2a070863          	beqz	a4,3848 <_vsnprintf+0x21f8>
    359c:	02b00793          	li	a5,43
    35a0:	02f10023          	sb	a5,32(sp)
    35a4:	4709                	li	a4,2
    35a6:	4d05                	li	s10,1
    35a8:	8426                	mv	s0,s1
    35aa:	02b00513          	li	a0,43
    35ae:	b3aff06f          	j	28e8 <_vsnprintf+0x1298>
    35b2:	873e                	mv	a4,a5
    35b4:	c4eff06f          	j	2a02 <_vsnprintf+0x13b2>
    35b8:	8ba1                	andi	a5,a5,8
    35ba:	34079f63          	bnez	a5,3918 <_vsnprintf+0x22c8>
    35be:	87a6                	mv	a5,s1
    35c0:	4689                	li	a3,2
    35c2:	843e                	mv	s0,a5
    35c4:	b13fe06f          	j	20d6 <_vsnprintf+0xa86>
    35c8:	4781                	li	a5,0
    35ca:	8a0713e3          	bnez	a4,2e70 <_vsnprintf+0x1820>
    35ce:	4981                	li	s3,0
    35d0:	0038f693          	andi	a3,a7,3
    35d4:	b9fd                	j	32d2 <_vsnprintf+0x1c82>
    35d6:	0001                	nop
    35d8:	2785                	addiw	a5,a5,1
    35da:	8da6                	mv	s11,s1
    35dc:	c119                	beqz	a0,35e2 <_vsnprintf+0x1f92>
    35de:	cb2fe06f          	j	1a90 <_vsnprintf+0x440>
    35e2:	8dae                	mv	s11,a1
    35e4:	8c6fe06f          	j	16aa <_vsnprintf+0x5a>
    35e8:	0088f593          	andi	a1,a7,8
    35ec:	22059b63          	bnez	a1,3822 <_vsnprintf+0x21d2>
    35f0:	54031c63          	bnez	t1,3b48 <_vsnprintf+0x24f8>
    35f4:	7c09bd8b          	th.extu	s11,s3,31,0
    35f8:	8fb76fe3          	bltu	a4,s11,2ef6 <_vsnprintf+0x18a6>
    35fc:	020700e3          	beqz	a4,3e1c <_vsnprintf+0x27cc>
    3600:	02070793          	addi	a5,a4,32
    3604:	1014                	addi	a3,sp,32
    3606:	97b6                	add	a5,a5,a3
    3608:	fdf7c503          	lbu	a0,-33(a5)
    360c:	8426                	mv	s0,s1
    360e:	d5bfe06f          	j	2368 <_vsnprintf+0xd18>
    3612:	0001                	nop
    3614:	03f14503          	lbu	a0,63(sp)
    3618:	87a6                	mv	a5,s1
    361a:	4809                	li	a6,2
    361c:	02000d93          	li	s11,32
    3620:	daaff06f          	j	2bca <_vsnprintf+0x157a>
    3624:	03f14503          	lbu	a0,63(sp)
    3628:	c35fe06f          	j	225c <_vsnprintf+0xc0c>
    362c:	4785                	li	a5,1
    362e:	4581                	li	a1,0
    3630:	02067713          	andi	a4,a2,32
    3634:	2c070763          	beqz	a4,3902 <_vsnprintf+0x22b2>
    3638:	02000713          	li	a4,32
    363c:	92ed8663          	beq	s11,a4,2768 <_vsnprintf+0x1118>
    3640:	05800693          	li	a3,88
    3644:	00367713          	andi	a4,a2,3
    3648:	002d87b3          	add	a5,s11,sp
    364c:	02d78023          	sb	a3,32(a5)
    3650:	0d85                	addi	s11,s11,1
    3652:	90aff06f          	j	275c <_vsnprintf+0x110c>
    3656:	4741                	li	a4,16
    3658:	8b8d                	andi	a5,a5,3
    365a:	4589                	li	a1,2
    365c:	fce88ae3          	beq	a7,a4,3630 <_vsnprintf+0x1fe0>
    3660:	4589                	li	a1,2
    3662:	00367713          	andi	a4,a2,3
    3666:	8eb89b63          	bne	a7,a1,275c <_vsnprintf+0x110c>
    366a:	02000793          	li	a5,32
    366e:	e8fd80e3          	beq	s11,a5,34ee <_vsnprintf+0x1e9e>
    3672:	06200693          	li	a3,98
    3676:	85c6                	mv	a1,a7
    3678:	bfc1                	j	3648 <_vsnprintf+0x1ff8>
    367a:	02000793          	li	a5,32
    367e:	e4fd80e3          	beq	s11,a5,34be <_vsnprintf+0x1e6e>
    3682:	950a                	add	a0,a0,sp
    3684:	02054503          	lbu	a0,32(a0)
    3688:	87a6                	mv	a5,s1
    368a:	4e09                	li	t3,2
    368c:	8dffe06f          	j	1f6a <_vsnprintf+0x91a>
    3690:	4741                	li	a4,16
    3692:	0ae88963          	beq	a7,a4,3744 <_vsnprintf+0x20f4>
    3696:	4e09                	li	t3,2
    3698:	003f7793          	andi	a5,t5,3
    369c:	01c88463          	beq	a7,t3,36a4 <_vsnprintf+0x2054>
    36a0:	84ffe06f          	j	1eee <_vsnprintf+0x89e>
    36a4:	02000713          	li	a4,32
    36a8:	c8ed80e3          	beq	s11,a4,3328 <_vsnprintf+0x1cd8>
    36ac:	06200693          	li	a3,98
    36b0:	8e46                	mv	t3,a7
    36b2:	002d8733          	add	a4,s11,sp
    36b6:	02d70023          	sb	a3,32(a4)
    36ba:	0d85                	addi	s11,s11,1
    36bc:	833fe06f          	j	1eee <_vsnprintf+0x89e>
    36c0:	00028763          	beqz	t0,36ce <_vsnprintf+0x207e>
    36c4:	c6080d63          	beqz	a6,2b3e <_vsnprintf+0x14ee>
    36c8:	4801                	li	a6,0
    36ca:	c80ff06f          	j	2b4a <_vsnprintf+0x14fa>
    36ce:	7c09b40b          	th.extu	s0,s3,31,0
    36d2:	4801                	li	a6,0
    36d4:	ca8de463          	bltu	s11,s0,2b7c <_vsnprintf+0x152c>
    36d8:	bc65                	j	3190 <_vsnprintf+0x1b40>
    36da:	0001                	nop
    36dc:	03f14503          	lbu	a0,63(sp)
    36e0:	87a6                	mv	a5,s1
    36e2:	4589                	li	a1,2
    36e4:	02000d93          	li	s11,32
    36e8:	8eaff06f          	j	27d2 <_vsnprintf+0x1182>
    36ec:	c4080963          	beqz	a6,2b3e <_vsnprintf+0x14ee>
    36f0:	47c1                	li	a5,16
    36f2:	2ef88263          	beq	a7,a5,39d6 <_vsnprintf+0x2386>
    36f6:	4789                	li	a5,2
    36f8:	00367713          	andi	a4,a2,3
    36fc:	4801                	li	a6,0
    36fe:	c4f89f63          	bne	a7,a5,2b5c <_vsnprintf+0x150c>
    3702:	02000793          	li	a5,32
    3706:	4881                	li	a7,0
    3708:	18fd9a63          	bne	s11,a5,389c <_vsnprintf+0x224c>
    370c:	03f14503          	lbu	a0,63(sp)
    3710:	8846                	mv	a6,a7
    3712:	87a6                	mv	a5,s1
    3714:	02000d93          	li	s11,32
    3718:	cb2ff06f          	j	2bca <_vsnprintf+0x157a>
    371c:	8ab1                	andi	a3,a3,12
    371e:	fff9859b          	addiw	a1,s3,-1
    3722:	42d5998b          	th.mvnez	s3,a1,a3
    3726:	a8e7e563          	bltu	a5,a4,29b0 <_vsnprintf+0x1360>
    372a:	7c09b70b          	th.extu	a4,s3,31,0
    372e:	aae7ea63          	bltu	a5,a4,29e2 <_vsnprintf+0x1392>
    3732:	02000713          	li	a4,32
    3736:	b6e78a63          	beq	a5,a4,2aaa <_vsnprintf+0x145a>
    373a:	873e                	mv	a4,a5
    373c:	0038f693          	andi	a3,a7,3
    3740:	ad4ff06f          	j	2a14 <_vsnprintf+0x13c4>
    3744:	0037f713          	andi	a4,a5,3
    3748:	4e09                	li	t3,2
    374a:	020f7793          	andi	a5,t5,32
    374e:	26078763          	beqz	a5,39bc <_vsnprintf+0x236c>
    3752:	02000793          	li	a5,32
    3756:	c8fd89e3          	beq	s11,a5,33e8 <_vsnprintf+0x1d98>
    375a:	05800693          	li	a3,88
    375e:	003f7793          	andi	a5,t5,3
    3762:	bf81                	j	36b2 <_vsnprintf+0x2062>
    3764:	02000793          	li	a5,32
    3768:	f6fd8ae3          	beq	s11,a5,36dc <_vsnprintf+0x208c>
    376c:	9e0a                	add	t3,t3,sp
    376e:	020e4503          	lbu	a0,32(t3)
    3772:	87a6                	mv	a5,s1
    3774:	4589                	li	a1,2
    3776:	85cff06f          	j	27d2 <_vsnprintf+0x1182>
    377a:	fffd8713          	addi	a4,s11,-1
    377e:	e32d                	bnez	a4,37e0 <_vsnprintf+0x2190>
    3780:	47c1                	li	a5,16
    3782:	68f88563          	beq	a7,a5,3e0c <_vsnprintf+0x27bc>
    3786:	4789                	li	a5,2
    3788:	02f88e63          	beq	a7,a5,37c4 <_vsnprintf+0x2174>
    378c:	8e42                	mv	t3,a6
    378e:	003f7793          	andi	a5,t5,3
    3792:	1018                	addi	a4,sp,32
    3794:	4d85                	li	s11,1
    3796:	e9bfe06f          	j	2630 <_vsnprintf+0xfe0>
    379a:	02000693          	li	a3,32
    379e:	88c2                	mv	a7,a6
    37a0:	f0dd96e3          	bne	s11,a3,36ac <_vsnprintf+0x205c>
    37a4:	b80712e3          	bnez	a4,3328 <_vsnprintf+0x1cd8>
    37a8:	02000d93          	li	s11,32
    37ac:	8e46                	mv	t3,a7
    37ae:	7c09b40b          	th.extu	s0,s3,31,0
    37b2:	013df463          	bgeu	s11,s3,37ba <_vsnprintf+0x216a>
    37b6:	f5cfe06f          	j	1f12 <_vsnprintf+0x8c2>
    37ba:	03f14503          	lbu	a0,63(sp)
    37be:	87a6                	mv	a5,s1
    37c0:	faafe06f          	j	1f6a <_vsnprintf+0x91a>
    37c4:	06200793          	li	a5,98
    37c8:	02f10023          	sb	a5,32(sp)
    37cc:	8e42                	mv	t3,a6
    37ce:	003f7793          	andi	a5,t5,3
    37d2:	02110713          	addi	a4,sp,33
    37d6:	4d89                	li	s11,2
    37d8:	e59fe06f          	j	2630 <_vsnprintf+0xfe0>
    37dc:	477d                	li	a4,31
    37de:	4809                	li	a6,2
    37e0:	47c1                	li	a5,16
    37e2:	60f88163          	beq	a7,a5,3de4 <_vsnprintf+0x2794>
    37e6:	4789                	li	a5,2
    37e8:	5ef88963          	beq	a7,a5,3dda <_vsnprintf+0x278a>
    37ec:	1000                	addi	s0,sp,32
    37ee:	8e42                	mv	t3,a6
    37f0:	003f7793          	andi	a5,t5,3
    37f4:	9722                	add	a4,a4,s0
    37f6:	e3bfe06f          	j	2630 <_vsnprintf+0xfe0>
    37fa:	02000793          	li	a5,32
    37fe:	e0fd8be3          	beq	s11,a5,3614 <_vsnprintf+0x1fc4>
    3802:	930a                	add	t1,t1,sp
    3804:	02034503          	lbu	a0,32(t1)
    3808:	87a6                	mv	a5,s1
    380a:	4809                	li	a6,2
    380c:	bbeff06f          	j	2bca <_vsnprintf+0x157a>
    3810:	4741                	li	a4,16
    3812:	32e88e63          	beq	a7,a4,3b4e <_vsnprintf+0x24fe>
    3816:	4809                	li	a6,2
    3818:	ef088ae3          	beq	a7,a6,370c <_vsnprintf+0x20bc>
    381c:	8b8d                	andi	a5,a5,3
    381e:	b4aff06f          	j	2b68 <_vsnprintf+0x1518>
    3822:	87ba                	mv	a5,a4
    3824:	4581                	li	a1,0
    3826:	00278733          	add	a4,a5,sp
    382a:	02000513          	li	a0,32
    382e:	02a70023          	sb	a0,32(a4)
    3832:	00178713          	addi	a4,a5,1
    3836:	ac0312e3          	bnez	t1,32fa <_vsnprintf+0x1caa>
    383a:	7c09bd8b          	th.extu	s11,s3,31,0
    383e:	ebb76c63          	bltu	a4,s11,2ef6 <_vsnprintf+0x18a6>
    3842:	8426                	mv	s0,s1
    3844:	b25fe06f          	j	2368 <_vsnprintf+0xd18>
    3848:	0087f713          	andi	a4,a5,8
    384c:	c70d                	beqz	a4,3876 <_vsnprintf+0x2226>
    384e:	0037f693          	andi	a3,a5,3
    3852:	4709                	li	a4,2
    3854:	4781                	li	a5,0
    3856:	00278633          	add	a2,a5,sp
    385a:	02000513          	li	a0,32
    385e:	02a60023          	sb	a0,32(a2)
    3862:	00178d13          	addi	s10,a5,1
    3866:	e689                	bnez	a3,3870 <_vsnprintf+0x2220>
    3868:	7c09b68b          	th.extu	a3,s3,31,0
    386c:	d2dd6063          	bltu	s10,a3,2d8c <_vsnprintf+0x173c>
    3870:	8426                	mv	s0,s1
    3872:	876ff06f          	j	28e8 <_vsnprintf+0x1298>
    3876:	8426                	mv	s0,s1
    3878:	4709                	li	a4,2
    387a:	8a2ff06f          	j	291c <_vsnprintf+0x12cc>
    387e:	4741                	li	a4,16
    3880:	2ce88063          	beq	a7,a4,3b40 <_vsnprintf+0x24f0>
    3884:	4589                	li	a1,2
    3886:	8b8d                	andi	a5,a5,3
    3888:	00b88463          	beq	a7,a1,3890 <_vsnprintf+0x2240>
    388c:	eddfe06f          	j	2768 <_vsnprintf+0x1118>
    3890:	b9b9                	j	34ee <_vsnprintf+0x1e9e>
    3892:	02000693          	li	a3,32
    3896:	88c2                	mv	a7,a6
    3898:	2add8f63          	beq	s11,a3,3b56 <_vsnprintf+0x2506>
    389c:	06200693          	li	a3,98
    38a0:	8846                	mv	a6,a7
    38a2:	002d87b3          	add	a5,s11,sp
    38a6:	02d78023          	sb	a3,32(a5)
    38aa:	0d85                	addi	s11,s11,1
    38ac:	ab0ff06f          	j	2b5c <_vsnprintf+0x150c>
    38b0:	4e01                	li	t3,0
    38b2:	4705                	li	a4,1
    38b4:	bd59                	j	374a <_vsnprintf+0x20fa>
    38b6:	02000693          	li	a3,32
    38ba:	88c2                	mv	a7,a6
    38bc:	dadd9be3          	bne	s11,a3,3672 <_vsnprintf+0x2022>
    38c0:	c20797e3          	bnez	a5,34ee <_vsnprintf+0x1e9e>
    38c4:	02000d93          	li	s11,32
    38c8:	85c6                	mv	a1,a7
    38ca:	7c09b40b          	th.extu	s0,s3,31,0
    38ce:	013df463          	bgeu	s11,s3,38d6 <_vsnprintf+0x2286>
    38d2:	eabfe06f          	j	277c <_vsnprintf+0x112c>
    38d6:	03f14503          	lbu	a0,63(sp)
    38da:	87a6                	mv	a5,s1
    38dc:	ef7fe06f          	j	27d2 <_vsnprintf+0x1182>
    38e0:	fffd8793          	addi	a5,s11,-1
    38e4:	2e079563          	bnez	a5,3bce <_vsnprintf+0x257e>
    38e8:	47c1                	li	a5,16
    38ea:	2cf88863          	beq	a7,a5,3bba <_vsnprintf+0x256a>
    38ee:	4789                	li	a5,2
    38f0:	08f88463          	beq	a7,a5,3978 <_vsnprintf+0x2328>
    38f4:	85c2                	mv	a1,a6
    38f6:	00367713          	andi	a4,a2,3
    38fa:	101c                	addi	a5,sp,32
    38fc:	4d85                	li	s11,1
    38fe:	f37fe06f          	j	2834 <_vsnprintf+0x11e4>
    3902:	02000713          	li	a4,32
    3906:	00ed9463          	bne	s11,a4,390e <_vsnprintf+0x22be>
    390a:	e5ffe06f          	j	2768 <_vsnprintf+0x1118>
    390e:	07800693          	li	a3,120
    3912:	00367713          	andi	a4,a2,3
    3916:	bb0d                	j	3648 <_vsnprintf+0x1ff8>
    3918:	4789                	li	a5,2
    391a:	86be                	mv	a3,a5
    391c:	4701                	li	a4,0
    391e:	00270633          	add	a2,a4,sp
    3922:	02000513          	li	a0,32
    3926:	02a60023          	sb	a0,32(a2)
    392a:	0705                	addi	a4,a4,1
    392c:	90078363          	beqz	a5,2a32 <_vsnprintf+0x13e2>
    3930:	87a6                	mv	a5,s1
    3932:	f76fe06f          	j	20a8 <_vsnprintf+0xa58>
    3936:	843e                	mv	s0,a5
    3938:	ec9fe06f          	j	2800 <_vsnprintf+0x11b0>
    393c:	0088f793          	andi	a5,a7,8
    3940:	c7d9                	beqz	a5,39ce <_vsnprintf+0x237e>
    3942:	0038f313          	andi	t1,a7,3
    3946:	4781                	li	a5,0
    3948:	4589                	li	a1,2
    394a:	bdf1                	j	3826 <_vsnprintf+0x21d6>
    394c:	4781                	li	a5,0
    394e:	860714e3          	bnez	a4,31b6 <_vsnprintf+0x1b66>
    3952:	4981                	li	s3,0
    3954:	0038f693          	andi	a3,a7,3
    3958:	c04ff06f          	j	2d5c <_vsnprintf+0x170c>
    395c:	4741                	li	a4,16
    395e:	a8e882e3          	beq	a7,a4,33e2 <_vsnprintf+0x1d92>
    3962:	4e09                	li	t3,2
    3964:	003f7f13          	andi	t5,t5,3
    3968:	01c88463          	beq	a7,t3,3970 <_vsnprintf+0x2320>
    396c:	d8efe06f          	j	1efa <_vsnprintf+0x8aa>
    3970:	ba65                	j	3328 <_vsnprintf+0x1cd8>
    3972:	843e                	mv	s0,a5
    3974:	a84ff06f          	j	2bf8 <_vsnprintf+0x15a8>
    3978:	06200793          	li	a5,98
    397c:	02f10023          	sb	a5,32(sp)
    3980:	85c2                	mv	a1,a6
    3982:	00367713          	andi	a4,a2,3
    3986:	02110793          	addi	a5,sp,33
    398a:	4d89                	li	s11,2
    398c:	ea9fe06f          	j	2834 <_vsnprintf+0x11e4>
    3990:	0088f893          	andi	a7,a7,8
    3994:	34089263          	bnez	a7,3cd8 <_vsnprintf+0x2688>
    3998:	32069c63          	bnez	a3,3cd0 <_vsnprintf+0x2680>
    399c:	7c09b40b          	th.extu	s0,s3,31,0
    39a0:	88876d63          	bltu	a4,s0,2a3a <_vsnprintf+0x13ea>
    39a4:	30070f63          	beqz	a4,3cc2 <_vsnprintf+0x2672>
    39a8:	02070793          	addi	a5,a4,32
    39ac:	1010                	addi	a2,sp,32
    39ae:	97b2                	add	a5,a5,a2
    39b0:	fdf7c503          	lbu	a0,-33(a5)
    39b4:	87a6                	mv	a5,s1
    39b6:	ef2fe06f          	j	20a8 <_vsnprintf+0xa58>
    39ba:	0001                	nop
    39bc:	02000793          	li	a5,32
    39c0:	a2fd84e3          	beq	s11,a5,33e8 <_vsnprintf+0x1d98>
    39c4:	07800693          	li	a3,120
    39c8:	003f7793          	andi	a5,t5,3
    39cc:	b1dd                	j	36b2 <_vsnprintf+0x2062>
    39ce:	8426                	mv	s0,s1
    39d0:	4589                	li	a1,2
    39d2:	9cbfe06f          	j	239c <_vsnprintf+0xd4c>
    39d6:	4801                	li	a6,0
    39d8:	4785                	li	a5,1
    39da:	02067713          	andi	a4,a2,32
    39de:	cb35                	beqz	a4,3a52 <_vsnprintf+0x2402>
    39e0:	02000713          	li	a4,32
    39e4:	98ed8263          	beq	s11,a4,2b68 <_vsnprintf+0x1518>
    39e8:	05800693          	li	a3,88
    39ec:	00367713          	andi	a4,a2,3
    39f0:	bd4d                	j	38a2 <_vsnprintf+0x2252>
    39f2:	0001                	nop
    39f4:	fffd8793          	addi	a5,s11,-1
    39f8:	e7d5                	bnez	a5,3aa4 <_vsnprintf+0x2454>
    39fa:	47c1                	li	a5,16
    39fc:	08f88a63          	beq	a7,a5,3a90 <_vsnprintf+0x2440>
    3a00:	4789                	li	a5,2
    3a02:	06f88d63          	beq	a7,a5,3a7c <_vsnprintf+0x242c>
    3a06:	00367713          	andi	a4,a2,3
    3a0a:	101c                	addi	a5,sp,32
    3a0c:	4d85                	li	s11,1
    3a0e:	03000513          	li	a0,48
    3a12:	00a78023          	sb	a0,0(a5)
    3a16:	e709                	bnez	a4,3a20 <_vsnprintf+0x23d0>
    3a18:	7c09b40b          	th.extu	s0,s3,31,0
    3a1c:	968de063          	bltu	s11,s0,2b7c <_vsnprintf+0x152c>
    3a20:	87a6                	mv	a5,s1
    3a22:	9a8ff06f          	j	2bca <_vsnprintf+0x157a>
    3a26:	03f14503          	lbu	a0,63(sp)
    3a2a:	87a6                	mv	a5,s1
    3a2c:	02000d93          	li	s11,32
    3a30:	99aff06f          	j	2bca <_vsnprintf+0x157a>
    3a34:	4741                	li	a4,16
    3a36:	8b8d                	andi	a5,a5,3
    3a38:	4809                	li	a6,2
    3a3a:	fae880e3          	beq	a7,a4,39da <_vsnprintf+0x238a>
    3a3e:	4809                	li	a6,2
    3a40:	00367713          	andi	a4,a2,3
    3a44:	91089c63          	bne	a7,a6,2b5c <_vsnprintf+0x150c>
    3a48:	02000793          	li	a5,32
    3a4c:	ccfd80e3          	beq	s11,a5,370c <_vsnprintf+0x20bc>
    3a50:	b5b1                	j	389c <_vsnprintf+0x224c>
    3a52:	02000713          	li	a4,32
    3a56:	90ed8963          	beq	s11,a4,2b68 <_vsnprintf+0x1518>
    3a5a:	07800693          	li	a3,120
    3a5e:	00367713          	andi	a4,a2,3
    3a62:	b581                	j	38a2 <_vsnprintf+0x2252>
    3a64:	4801                	li	a6,0
    3a66:	feefe06f          	j	2254 <_vsnprintf+0xc04>
    3a6a:	4d7d                	li	s10,31
    3a6c:	d1eff06f          	j	2f8a <_vsnprintf+0x193a>
    3a70:	00d10433          	add	s0,sp,a3
    3a74:	01b407b3          	add	a5,s0,s11
    3a78:	0d85                	addi	s11,s11,1
    3a7a:	bf51                	j	3a0e <_vsnprintf+0x23be>
    3a7c:	06200793          	li	a5,98
    3a80:	02f10023          	sb	a5,32(sp)
    3a84:	00367713          	andi	a4,a2,3
    3a88:	02110793          	addi	a5,sp,33
    3a8c:	4d89                	li	s11,2
    3a8e:	b741                	j	3a0e <_vsnprintf+0x23be>
    3a90:	02067793          	andi	a5,a2,32
    3a94:	e785                	bnez	a5,3abc <_vsnprintf+0x246c>
    3a96:	07800793          	li	a5,120
    3a9a:	02f10023          	sb	a5,32(sp)
    3a9e:	b7dd                	j	3a84 <_vsnprintf+0x2434>
    3aa0:	4809                	li	a6,2
    3aa2:	47fd                	li	a5,31
    3aa4:	4741                	li	a4,16
    3aa6:	1000                	addi	s0,sp,32
    3aa8:	02e88463          	beq	a7,a4,3ad0 <_vsnprintf+0x2480>
    3aac:	4709                	li	a4,2
    3aae:	00e88c63          	beq	a7,a4,3ac6 <_vsnprintf+0x2476>
    3ab2:	1000                	addi	s0,sp,32
    3ab4:	00367713          	andi	a4,a2,3
    3ab8:	97a2                	add	a5,a5,s0
    3aba:	bf91                	j	3a0e <_vsnprintf+0x23be>
    3abc:	05800793          	li	a5,88
    3ac0:	02f10023          	sb	a5,32(sp)
    3ac4:	b7c1                	j	3a84 <_vsnprintf+0x2434>
    3ac6:	88c2                	mv	a7,a6
    3ac8:	8dbe                	mv	s11,a5
    3aca:	00367713          	andi	a4,a2,3
    3ace:	b3f9                	j	389c <_vsnprintf+0x224c>
    3ad0:	02067713          	andi	a4,a2,32
    3ad4:	ffed8793          	addi	a5,s11,-2
    3ad8:	e315                	bnez	a4,3afc <_vsnprintf+0x24ac>
    3ada:	1018                	addi	a4,sp,32
    3adc:	02078793          	addi	a5,a5,32
    3ae0:	97ba                	add	a5,a5,a4
    3ae2:	07800693          	li	a3,120
    3ae6:	1dfd                	addi	s11,s11,-1
    3ae8:	00367713          	andi	a4,a2,3
    3aec:	fed78023          	sb	a3,-32(a5)
    3af0:	b751                	j	3a74 <_vsnprintf+0x2424>
    3af2:	4981                	li	s3,0
    3af4:	0038f693          	andi	a3,a7,3
    3af8:	f1dfe06f          	j	2a14 <_vsnprintf+0x13c4>
    3afc:	1018                	addi	a4,sp,32
    3afe:	02078793          	addi	a5,a5,32
    3b02:	97ba                	add	a5,a5,a4
    3b04:	05800693          	li	a3,88
    3b08:	1dfd                	addi	s11,s11,-1
    3b0a:	00367713          	andi	a4,a2,3
    3b0e:	fed78023          	sb	a3,-32(a5)
    3b12:	b78d                	j	3a74 <_vsnprintf+0x2424>
    3b14:	0046f713          	andi	a4,a3,4
    3b18:	c73d                	beqz	a4,3b86 <_vsnprintf+0x2536>
    3b1a:	1018                	addi	a4,sp,32
    3b1c:	02078793          	addi	a5,a5,32
    3b20:	97ba                	add	a5,a5,a4
    3b22:	02b00713          	li	a4,43
    3b26:	fee78023          	sb	a4,-32(a5)
    3b2a:	0d09                	addi	s10,s10,2
    3b2c:	4709                	li	a4,2
    3b2e:	bcad                	j	35a8 <_vsnprintf+0x1f58>
    3b30:	0038f693          	andi	a3,a7,3
    3b34:	873e                	mv	a4,a5
    3b36:	8536                	mv	a0,a3
    3b38:	bac79063          	bne	a5,a2,2ed8 <_vsnprintf+0x1888>
    3b3c:	c26ff06f          	j	2f62 <_vsnprintf+0x1912>
    3b40:	8b8d                	andi	a5,a5,3
    3b42:	4589                	li	a1,2
    3b44:	c25fe06f          	j	2768 <_vsnprintf+0x1118>
    3b48:	8426                	mv	s0,s1
    3b4a:	bf6ff06f          	j	2f40 <_vsnprintf+0x18f0>
    3b4e:	8b8d                	andi	a5,a5,3
    3b50:	4809                	li	a6,2
    3b52:	816ff06f          	j	2b68 <_vsnprintf+0x1518>
    3b56:	ba079be3          	bnez	a5,370c <_vsnprintf+0x20bc>
    3b5a:	02000d93          	li	s11,32
    3b5e:	8846                	mv	a6,a7
    3b60:	7c09b40b          	th.extu	s0,s3,31,0
    3b64:	013df463          	bgeu	s11,s3,3b6c <_vsnprintf+0x251c>
    3b68:	814ff06f          	j	2b7c <_vsnprintf+0x152c>
    3b6c:	03f14503          	lbu	a0,63(sp)
    3b70:	87a6                	mv	a5,s1
    3b72:	858ff06f          	j	2bca <_vsnprintf+0x157a>
    3b76:	7c09b40b          	th.extu	s0,s3,31,0
    3b7a:	c019                	beqz	s0,3b80 <_vsnprintf+0x2530>
    3b7c:	b96fe06f          	j	1f12 <_vsnprintf+0x8c2>
    3b80:	6da2                	ld	s11,8(sp)
    3b82:	b29fd06f          	j	16aa <_vsnprintf+0x5a>
    3b86:	8aa1                	andi	a3,a3,8
    3b88:	c685                	beqz	a3,3bb0 <_vsnprintf+0x2560>
    3b8a:	1018                	addi	a4,sp,32
    3b8c:	02078793          	addi	a5,a5,32
    3b90:	97ba                	add	a5,a5,a4
    3b92:	fea78023          	sb	a0,-32(a5)
    3b96:	0d09                	addi	s10,s10,2
    3b98:	8426                	mv	s0,s1
    3b9a:	4709                	li	a4,2
    3b9c:	d4dfe06f          	j	28e8 <_vsnprintf+0x1298>
    3ba0:	7c09b40b          	th.extu	s0,s3,31,0
    3ba4:	c019                	beqz	s0,3baa <_vsnprintf+0x255a>
    3ba6:	bd7fe06f          	j	277c <_vsnprintf+0x112c>
    3baa:	6da2                	ld	s11,8(sp)
    3bac:	afffd06f          	j	16aa <_vsnprintf+0x5a>
    3bb0:	8d3e                	mv	s10,a5
    3bb2:	8426                	mv	s0,s1
    3bb4:	4709                	li	a4,2
    3bb6:	a26ff06f          	j	2ddc <_vsnprintf+0x178c>
    3bba:	02067793          	andi	a5,a2,32
    3bbe:	e78d                	bnez	a5,3be8 <_vsnprintf+0x2598>
    3bc0:	07800793          	li	a5,120
    3bc4:	02f10023          	sb	a5,32(sp)
    3bc8:	bb65                	j	3980 <_vsnprintf+0x2330>
    3bca:	4809                	li	a6,2
    3bcc:	47fd                	li	a5,31
    3bce:	4741                	li	a4,16
    3bd0:	02e88663          	beq	a7,a4,3bfc <_vsnprintf+0x25ac>
    3bd4:	4709                	li	a4,2
    3bd6:	00e88e63          	beq	a7,a4,3bf2 <_vsnprintf+0x25a2>
    3bda:	1000                	addi	s0,sp,32
    3bdc:	85c2                	mv	a1,a6
    3bde:	00367713          	andi	a4,a2,3
    3be2:	97a2                	add	a5,a5,s0
    3be4:	c51fe06f          	j	2834 <_vsnprintf+0x11e4>
    3be8:	05800793          	li	a5,88
    3bec:	02f10023          	sb	a5,32(sp)
    3bf0:	bb41                	j	3980 <_vsnprintf+0x2330>
    3bf2:	88c2                	mv	a7,a6
    3bf4:	8dbe                	mv	s11,a5
    3bf6:	00367713          	andi	a4,a2,3
    3bfa:	bca5                	j	3672 <_vsnprintf+0x2022>
    3bfc:	85c2                	mv	a1,a6
    3bfe:	1000                	addi	s0,sp,32
    3c00:	02067713          	andi	a4,a2,32
    3c04:	ffed8793          	addi	a5,s11,-2
    3c08:	eb2d                	bnez	a4,3c7a <_vsnprintf+0x262a>
    3c0a:	1018                	addi	a4,sp,32
    3c0c:	02078793          	addi	a5,a5,32
    3c10:	97ba                	add	a5,a5,a4
    3c12:	07800693          	li	a3,120
    3c16:	1dfd                	addi	s11,s11,-1
    3c18:	00367713          	andi	a4,a2,3
    3c1c:	fed78023          	sb	a3,-32(a5)
    3c20:	c0ffe06f          	j	282e <_vsnprintf+0x11de>
    3c24:	787d                	lui	a6,0xfffff
    3c26:	7ff80813          	addi	a6,a6,2047 # fffffffffffff7ff <__kernel_stack+0xfffffffffff117ff>
    3c2a:	f20687d3          	fmv.d.x	fa5,a3
    3c2e:	22f79553          	fneg.d	fa0,fa5
    3c32:	01047833          	and	a6,s0,a6
    3c36:	fb11530b          	th.sdd	t1,a7,(sp),1,4
    3c3a:	fcefe06f          	j	2408 <_vsnprintf+0xdb8>
    3c3e:	d0035ae3          	bgez	t1,3952 <_vsnprintf+0x2302>
    3c42:	973e                	add	a4,a4,a5
    3c44:	1014                	addi	a3,sp,32
    3c46:	9736                	add	a4,a4,a3
    3c48:	02d00513          	li	a0,45
    3c4c:	fea70023          	sb	a0,-32(a4)
    3c50:	00178d13          	addi	s10,a5,1
    3c54:	4701                	li	a4,0
    3c56:	c0098de3          	beqz	s3,3870 <_vsnprintf+0x2220>
    3c5a:	4981                	li	s3,0
    3c5c:	c87fe06f          	j	28e2 <_vsnprintf+0x1292>
    3c60:	47c1                	li	a5,16
    3c62:	4809                	li	a6,2
    3c64:	e6f886e3          	beq	a7,a5,3ad0 <_vsnprintf+0x2480>
    3c68:	03088663          	beq	a7,a6,3c94 <_vsnprintf+0x2644>
    3c6c:	03000513          	li	a0,48
    3c70:	02a10fa3          	sb	a0,63(sp)
    3c74:	87a6                	mv	a5,s1
    3c76:	f55fe06f          	j	2bca <_vsnprintf+0x157a>
    3c7a:	1018                	addi	a4,sp,32
    3c7c:	02078793          	addi	a5,a5,32
    3c80:	97ba                	add	a5,a5,a4
    3c82:	05800693          	li	a3,88
    3c86:	1dfd                	addi	s11,s11,-1
    3c88:	00367713          	andi	a4,a2,3
    3c8c:	fed78023          	sb	a3,-32(a5)
    3c90:	b9ffe06f          	j	282e <_vsnprintf+0x11de>
    3c94:	00367713          	andi	a4,a2,3
    3c98:	4dfd                	li	s11,31
    3c9a:	b109                	j	389c <_vsnprintf+0x224c>
    3c9c:	873e                	mv	a4,a5
    3c9e:	920e58e3          	bgez	t3,35ce <_vsnprintf+0x1f7e>
    3ca2:	02078713          	addi	a4,a5,32
    3ca6:	1014                	addi	a3,sp,32
    3ca8:	9736                	add	a4,a4,a3
    3caa:	02d00513          	li	a0,45
    3cae:	fea70023          	sb	a0,-32(a4)
    3cb2:	00178713          	addi	a4,a5,1
    3cb6:	00099a63          	bnez	s3,3cca <_vsnprintf+0x267a>
    3cba:	4581                	li	a1,0
    3cbc:	8426                	mv	s0,s1
    3cbe:	eaafe06f          	j	2368 <_vsnprintf+0xd18>
    3cc2:	8426                	mv	s0,s1
    3cc4:	84a2                	mv	s1,s0
    3cc6:	9e5fd06f          	j	16aa <_vsnprintf+0x5a>
    3cca:	4981                	li	s3,0
    3ccc:	9d5fe06f          	j	26a0 <_vsnprintf+0x1050>
    3cd0:	4681                	li	a3,0
    3cd2:	87a6                	mv	a5,s1
    3cd4:	db3fe06f          	j	2a86 <_vsnprintf+0x1436>
    3cd8:	87b6                	mv	a5,a3
    3cda:	4681                	li	a3,0
    3cdc:	b189                	j	391e <_vsnprintf+0x22ce>
    3cde:	47c1                	li	a5,16
    3ce0:	4589                	li	a1,2
    3ce2:	f0f88fe3          	beq	a7,a5,3c00 <_vsnprintf+0x25b0>
    3ce6:	00b88e63          	beq	a7,a1,3d02 <_vsnprintf+0x26b2>
    3cea:	03000513          	li	a0,48
    3cee:	02a10fa3          	sb	a0,63(sp)
    3cf2:	87a6                	mv	a5,s1
    3cf4:	adffe06f          	j	27d2 <_vsnprintf+0x1182>
    3cf8:	866a                	mv	a2,s10
    3cfa:	8d3e                	mv	s10,a5
    3cfc:	87b2                	mv	a5,a2
    3cfe:	a7cff06f          	j	2f7a <_vsnprintf+0x192a>
    3d02:	00367713          	andi	a4,a2,3
    3d06:	4dfd                	li	s11,31
    3d08:	b2ad                	j	3672 <_vsnprintf+0x2022>
    3d0a:	9a029de3          	bnez	t0,36c4 <_vsnprintf+0x2074>
    3d0e:	c82ff06f          	j	3190 <_vsnprintf+0x1b40>
    3d12:	87a6                	mv	a5,s1
    3d14:	4681                	li	a3,0
    3d16:	b92fe06f          	j	20a8 <_vsnprintf+0xa58>
    3d1a:	03000793          	li	a5,48
    3d1e:	46c1                	li	a3,16
    3d20:	02f10023          	sb	a5,32(sp)
    3d24:	8536                	mv	a0,a3
    3d26:	678d                	lui	a5,0x3
    3d28:	03078793          	addi	a5,a5,48 # 3030 <_vsnprintf+0x19e0>
    3d2c:	02f110a3          	sh	a5,33(sp)
    3d30:	4801                	li	a6,0
    3d32:	478d                	li	a5,3
    3d34:	40000e13          	li	t3,1024
    3d38:	4605                	li	a2,1
    3d3a:	bd9fd06f          	j	1912 <_vsnprintf+0x2c2>
    3d3e:	00467713          	andi	a4,a2,4
    3d42:	00367313          	andi	t1,a2,3
    3d46:	cf3d                	beqz	a4,3dc4 <_vsnprintf+0x2774>
    3d48:	1018                	addi	a4,sp,32
    3d4a:	02078793          	addi	a5,a5,32
    3d4e:	97ba                	add	a5,a5,a4
    3d50:	02b00513          	li	a0,43
    3d54:	00268713          	addi	a4,a3,2
    3d58:	fea78023          	sb	a0,-32(a5)
    3d5c:	8426                	mv	s0,s1
    3d5e:	4589                	li	a1,2
    3d60:	e08fe06f          	j	2368 <_vsnprintf+0xd18>
    3d64:	7c09b70b          	th.extu	a4,s3,31,0
    3d68:	00e7f463          	bgeu	a5,a4,3d70 <_vsnprintf+0x2720>
    3d6c:	fc1fe06f          	j	2d2c <_vsnprintf+0x16dc>
    3d70:	02000713          	li	a4,32
    3d74:	88e78363          	beq	a5,a4,2dfa <_vsnprintf+0x17aa>
    3d78:	0038f693          	andi	a3,a7,3
    3d7c:	fe1fe06f          	j	2d5c <_vsnprintf+0x170c>
    3d80:	0038f693          	andi	a3,a7,3
    3d84:	8636                	mv	a2,a3
    3d86:	00b78463          	beq	a5,a1,3d8e <_vsnprintf+0x273e>
    3d8a:	fcffe06f          	j	2d58 <_vsnprintf+0x1708>
    3d8e:	86cff06f          	j	2dfa <_vsnprintf+0x17aa>
    3d92:	03000793          	li	a5,48
    3d96:	46bd                	li	a3,15
    3d98:	02f10023          	sb	a5,32(sp)
    3d9c:	8536                	mv	a0,a3
    3d9e:	b761                	j	3d26 <_vsnprintf+0x26d6>
    3da0:	7c09b40b          	th.extu	s0,s3,31,0
    3da4:	c019                	beqz	s0,3daa <_vsnprintf+0x275a>
    3da6:	dd7fe06f          	j	2b7c <_vsnprintf+0x152c>
    3daa:	8426                	mv	s0,s1
    3dac:	e71fe06f          	j	2c1c <_vsnprintf+0x15cc>
    3db0:	0038f693          	andi	a3,a7,3
    3db4:	873e                	mv	a4,a5
    3db6:	8636                	mv	a2,a3
    3db8:	00b78463          	beq	a5,a1,3dc0 <_vsnprintf+0x2770>
    3dbc:	c55fe06f          	j	2a10 <_vsnprintf+0x13c0>
    3dc0:	cebfe06f          	j	2aaa <_vsnprintf+0x145a>
    3dc4:	8a21                	andi	a2,a2,8
    3dc6:	12061963          	bnez	a2,3ef8 <_vsnprintf+0x28a8>
    3dca:	873e                	mv	a4,a5
    3dcc:	8426                	mv	s0,s1
    3dce:	4589                	li	a1,2
    3dd0:	970ff06f          	j	2f40 <_vsnprintf+0x18f0>
    3dd4:	4701                	li	a4,0
    3dd6:	fd2ff06f          	j	35a8 <_vsnprintf+0x1f58>
    3dda:	88c2                	mv	a7,a6
    3ddc:	8dba                	mv	s11,a4
    3dde:	003f7793          	andi	a5,t5,3
    3de2:	b0e9                	j	36ac <_vsnprintf+0x205c>
    3de4:	8e42                	mv	t3,a6
    3de6:	1000                	addi	s0,sp,32
    3de8:	020f7713          	andi	a4,t5,32
    3dec:	ffed8793          	addi	a5,s11,-2
    3df0:	eb15                	bnez	a4,3e24 <_vsnprintf+0x27d4>
    3df2:	02078793          	addi	a5,a5,32
    3df6:	1018                	addi	a4,sp,32
    3df8:	973e                	add	a4,a4,a5
    3dfa:	07800693          	li	a3,120
    3dfe:	1dfd                	addi	s11,s11,-1
    3e00:	003f7793          	andi	a5,t5,3
    3e04:	fed70023          	sb	a3,-32(a4)
    3e08:	823fe06f          	j	262a <_vsnprintf+0xfda>
    3e0c:	020f7793          	andi	a5,t5,32
    3e10:	e3b9                	bnez	a5,3e56 <_vsnprintf+0x2806>
    3e12:	07800793          	li	a5,120
    3e16:	02f10023          	sb	a5,32(sp)
    3e1a:	ba4d                	j	37cc <_vsnprintf+0x217c>
    3e1c:	8426                	mv	s0,s1
    3e1e:	8dc2                	mv	s11,a6
    3e20:	da8fe06f          	j	23c8 <_vsnprintf+0xd78>
    3e24:	02078793          	addi	a5,a5,32
    3e28:	1018                	addi	a4,sp,32
    3e2a:	973e                	add	a4,a4,a5
    3e2c:	05800693          	li	a3,88
    3e30:	1dfd                	addi	s11,s11,-1
    3e32:	003f7793          	andi	a5,t5,3
    3e36:	fed70023          	sb	a3,-32(a4)
    3e3a:	ff0fe06f          	j	262a <_vsnprintf+0xfda>
    3e3e:	0088f893          	andi	a7,a7,8
    3e42:	02089f63          	bnez	a7,3e80 <_vsnprintf+0x2830>
    3e46:	eb05                	bnez	a4,3e76 <_vsnprintf+0x2826>
    3e48:	7c09b68b          	th.extu	a3,s3,31,0
    3e4c:	00d7fa63          	bgeu	a5,a3,3e60 <_vsnprintf+0x2810>
    3e50:	8d3e                	mv	s10,a5
    3e52:	f3bfe06f          	j	2d8c <_vsnprintf+0x173c>
    3e56:	05800793          	li	a5,88
    3e5a:	02f10023          	sb	a5,32(sp)
    3e5e:	b2bd                	j	37cc <_vsnprintf+0x217c>
    3e60:	dfd5                	beqz	a5,3e1c <_vsnprintf+0x27cc>
    3e62:	02078693          	addi	a3,a5,32
    3e66:	1010                	addi	a2,sp,32
    3e68:	96b2                	add	a3,a3,a2
    3e6a:	fdf6c503          	lbu	a0,-33(a3)
    3e6e:	8d3e                	mv	s10,a5
    3e70:	8426                	mv	s0,s1
    3e72:	a77fe06f          	j	28e8 <_vsnprintf+0x1298>
    3e76:	8d3e                	mv	s10,a5
    3e78:	4701                	li	a4,0
    3e7a:	8426                	mv	s0,s1
    3e7c:	f5dfe06f          	j	2dd8 <_vsnprintf+0x1788>
    3e80:	86ba                	mv	a3,a4
    3e82:	4701                	li	a4,0
    3e84:	bac9                	j	3856 <_vsnprintf+0x2206>
    3e86:	47c1                	li	a5,16
    3e88:	4e09                	li	t3,2
    3e8a:	f4f88fe3          	beq	a7,a5,3de8 <_vsnprintf+0x2798>
    3e8e:	01c88d63          	beq	a7,t3,3ea8 <_vsnprintf+0x2858>
    3e92:	03000513          	li	a0,48
    3e96:	02a10fa3          	sb	a0,63(sp)
    3e9a:	87a6                	mv	a5,s1
    3e9c:	8cefe06f          	j	1f6a <_vsnprintf+0x91a>
    3ea0:	b20e1163          	bnez	t3,31c2 <_vsnprintf+0x1b72>
    3ea4:	e13fe06f          	j	2cb6 <_vsnprintf+0x1666>
    3ea8:	003f7793          	andi	a5,t5,3
    3eac:	4dfd                	li	s11,31
    3eae:	ffeff06f          	j	36ac <_vsnprintf+0x205c>
    3eb2:	0046f713          	andi	a4,a3,4
    3eb6:	cf19                	beqz	a4,3ed4 <_vsnprintf+0x2884>
    3eb8:	1018                	addi	a4,sp,32
    3eba:	02078793          	addi	a5,a5,32
    3ebe:	97ba                	add	a5,a5,a4
    3ec0:	02b00513          	li	a0,43
    3ec4:	fea78023          	sb	a0,-32(a5)
    3ec8:	002f0713          	addi	a4,t5,2
    3ecc:	87a6                	mv	a5,s1
    3ece:	4689                	li	a3,2
    3ed0:	9d8fe06f          	j	20a8 <_vsnprintf+0xa58>
    3ed4:	8aa1                	andi	a3,a3,8
    3ed6:	c29d                	beqz	a3,3efc <_vsnprintf+0x28ac>
    3ed8:	1018                	addi	a4,sp,32
    3eda:	02078793          	addi	a5,a5,32
    3ede:	97ba                	add	a5,a5,a4
    3ee0:	fea78023          	sb	a0,-32(a5)
    3ee4:	002f0713          	addi	a4,t5,2
    3ee8:	87a6                	mv	a5,s1
    3eea:	4689                	li	a3,2
    3eec:	9bcfe06f          	j	20a8 <_vsnprintf+0xa58>
    3ef0:	da059263          	bnez	a1,3494 <_vsnprintf+0x1e44>
    3ef4:	98cff06f          	j	3080 <_vsnprintf+0x1a30>
    3ef8:	4589                	li	a1,2
    3efa:	b235                	j	3826 <_vsnprintf+0x21d6>
    3efc:	873e                	mv	a4,a5
    3efe:	4689                	li	a3,2
    3f00:	87a6                	mv	a5,s1
    3f02:	b89fe06f          	j	2a8a <_vsnprintf+0x143a>
    3f06:	00000013          	nop
    3f0a:	00000013          	nop
    3f0e:	0001                	nop

0000000000003f10 <puts>:
    3f10:	1141                	addi	sp,sp,-16
    3f12:	f811540b          	th.sdd	s0,ra,(sp),0,4
    3f16:	842a                	mv	s0,a0
    3f18:	00054503          	lbu	a0,0(a0)
    3f1c:	c901                	beqz	a0,3f2c <puts+0x1c>
    3f1e:	0001                	nop
    3f20:	55fd                	li	a1,-1
    3f22:	e7ffc0ef          	jal	da0 <fputc>
    3f26:	8814450b          	th.lbuib	a0,(s0),1,0
    3f2a:	f97d                	bnez	a0,3f20 <puts+0x10>
    3f2c:	55fd                	li	a1,-1
    3f2e:	4529                	li	a0,10
    3f30:	e71fc0ef          	jal	da0 <fputc>
    3f34:	f811440b          	th.ldd	s0,ra,(sp),0,4
    3f38:	4501                	li	a0,0
    3f3a:	0141                	addi	sp,sp,16
    3f3c:	8082                	ret
    3f3e:	0001                	nop

0000000000003f40 <_putchar>:
    3f40:	55fd                	li	a1,-1
    3f42:	e5ffc06f          	j	da0 <fputc>
    3f46:	00000013          	nop
    3f4a:	00000013          	nop
    3f4e:	0001                	nop

0000000000003f50 <putchar>:
    3f50:	1141                	addi	sp,sp,-16
    3f52:	0ff57513          	zext.b	a0,a0
    3f56:	55fd                	li	a1,-1
    3f58:	e406                	sd	ra,8(sp)
    3f5a:	e47fc0ef          	jal	da0 <fputc>
    3f5e:	60a2                	ld	ra,8(sp)
    3f60:	4501                	li	a0,0
    3f62:	0141                	addi	sp,sp,16
    3f64:	8082                	ret
    3f66:	00000013          	nop
    3f6a:	00000013          	nop
    3f6e:	0001                	nop

0000000000003f70 <printf>:
    3f70:	711d                	addi	sp,sp,-96
    3f72:	02810313          	addi	t1,sp,40
    3f76:	6e05                	lui	t3,0x1
    3f78:	fed1560b          	th.sdd	a2,a3,(sp),3,4
    3f7c:	e0ba                	sd	a4,64(sp)
    3f7e:	e4be                	sd	a5,72(sp)
    3f80:	f42e                	sd	a1,40(sp)
    3f82:	86aa                	mv	a3,a0
    3f84:	858a                	mv	a1,sp
    3f86:	871a                	mv	a4,t1
    3f88:	e00e0513          	addi	a0,t3,-512 # e00 <_out_char>
    3f8c:	567d                	li	a2,-1
    3f8e:	ec06                	sd	ra,24(sp)
    3f90:	e8c2                	sd	a6,80(sp)
    3f92:	ecc6                	sd	a7,88(sp)
    3f94:	e41a                	sd	t1,8(sp)
    3f96:	ebafd0ef          	jal	1650 <_vsnprintf>
    3f9a:	60e2                	ld	ra,24(sp)
    3f9c:	6125                	addi	sp,sp,96
    3f9e:	8082                	ret

0000000000003fa0 <sprintf>:
    3fa0:	715d                	addi	sp,sp,-80
    3fa2:	02010313          	addi	t1,sp,32
    3fa6:	8eae                	mv	t4,a1
    3fa8:	6e05                	lui	t3,0x1
    3faa:	fcd1560b          	th.sdd	a2,a3,(sp),2,4
    3fae:	fef1570b          	th.sdd	a4,a5,(sp),3,4
    3fb2:	85aa                	mv	a1,a0
    3fb4:	86f6                	mv	a3,t4
    3fb6:	dd0e0513          	addi	a0,t3,-560 # dd0 <_out_buffer>
    3fba:	871a                	mv	a4,t1
    3fbc:	567d                	li	a2,-1
    3fbe:	ec06                	sd	ra,24(sp)
    3fc0:	e0c2                	sd	a6,64(sp)
    3fc2:	e4c6                	sd	a7,72(sp)
    3fc4:	e41a                	sd	t1,8(sp)
    3fc6:	e8afd0ef          	jal	1650 <_vsnprintf>
    3fca:	60e2                	ld	ra,24(sp)
    3fcc:	6161                	addi	sp,sp,80
    3fce:	8082                	ret

0000000000003fd0 <snprintf>:
    3fd0:	715d                	addi	sp,sp,-80
    3fd2:	02810313          	addi	t1,sp,40
    3fd6:	8eae                	mv	t4,a1
    3fd8:	6e05                	lui	t3,0x1
    3fda:	f436                	sd	a3,40(sp)
    3fdc:	fef1570b          	th.sdd	a4,a5,(sp),3,4
    3fe0:	85aa                	mv	a1,a0
    3fe2:	86b2                	mv	a3,a2
    3fe4:	dd0e0513          	addi	a0,t3,-560 # dd0 <_out_buffer>
    3fe8:	8676                	mv	a2,t4
    3fea:	871a                	mv	a4,t1
    3fec:	ec06                	sd	ra,24(sp)
    3fee:	e0c2                	sd	a6,64(sp)
    3ff0:	e4c6                	sd	a7,72(sp)
    3ff2:	e41a                	sd	t1,8(sp)
    3ff4:	e5cfd0ef          	jal	1650 <_vsnprintf>
    3ff8:	60e2                	ld	ra,24(sp)
    3ffa:	6161                	addi	sp,sp,80
    3ffc:	8082                	ret
    3ffe:	0001                	nop

0000000000004000 <vprintf>:
    4000:	1101                	addi	sp,sp,-32
    4002:	86aa                	mv	a3,a0
    4004:	6505                	lui	a0,0x1
    4006:	872e                	mv	a4,a1
    4008:	e0050513          	addi	a0,a0,-512 # e00 <_out_char>
    400c:	002c                	addi	a1,sp,8
    400e:	567d                	li	a2,-1
    4010:	ec06                	sd	ra,24(sp)
    4012:	e3efd0ef          	jal	1650 <_vsnprintf>
    4016:	60e2                	ld	ra,24(sp)
    4018:	6105                	addi	sp,sp,32
    401a:	8082                	ret
    401c:	00000013          	nop

0000000000004020 <vsnprintf>:
    4020:	88ae                	mv	a7,a1
    4022:	8832                	mv	a6,a2
    4024:	6785                	lui	a5,0x1
    4026:	8736                	mv	a4,a3
    4028:	85aa                	mv	a1,a0
    402a:	8646                	mv	a2,a7
    402c:	86c2                	mv	a3,a6
    402e:	dd078513          	addi	a0,a5,-560 # dd0 <_out_buffer>
    4032:	e1efd06f          	j	1650 <_vsnprintf>
    4036:	00000013          	nop
    403a:	00000013          	nop
    403e:	0001                	nop

0000000000004040 <fctprintf>:
    4040:	711d                	addi	sp,sp,-96
    4042:	03810313          	addi	t1,sp,56
    4046:	6f05                	lui	t5,0x1
    4048:	fc36                	sd	a3,56(sp)
    404a:	e0ba                	sd	a4,64(sp)
    404c:	8e2a                	mv	t3,a0
    404e:	8eae                	mv	t4,a1
    4050:	86b2                	mv	a3,a2
    4052:	080c                	addi	a1,sp,16
    4054:	df0f0513          	addi	a0,t5,-528 # df0 <_out_fct>
    4058:	871a                	mv	a4,t1
    405a:	567d                	li	a2,-1
    405c:	f406                	sd	ra,40(sp)
    405e:	e4be                	sd	a5,72(sp)
    4060:	e8c2                	sd	a6,80(sp)
    4062:	e41a                	sd	t1,8(sp)
    4064:	fbd15e0b          	th.sdd	t3,t4,(sp),1,4
    4068:	ecc6                	sd	a7,88(sp)
    406a:	de6fd0ef          	jal	1650 <_vsnprintf>
    406e:	70a2                	ld	ra,40(sp)
    4070:	6125                	addi	sp,sp,96
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
    4418:	c09ff0ef          	jal	4020 <vsnprintf>
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
    44e8:	b39ff0ef          	jal	4020 <vsnprintf>
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
    47bc:	07fd                	addi	a5,a5,31 # 101f <_ftoa+0x20f>
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
    481e:	06c1                	addi	a3,a3,16 # 1010 <_ftoa+0x200>
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
    4e3e:	fdf40413          	addi	s0,s0,-33 # fdf <_ftoa+0x1cf>
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
